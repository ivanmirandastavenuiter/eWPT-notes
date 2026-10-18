### 2. PortSwigger Categories Mapped to INE Vault Folders (exhaustive, not all apply to eWPT exam)

Here is where every PortSwigger Web Security Academy topic maps across your 8 INE tutorial folders so your lab writeups land in the right directory:

#### `01-Info-Gathering-and-Proxies`

* Essential Skills (HTTP basics, Burp Repeater/Proxy workflows)
* Information Disclosure
* Host Header Attacks
* Web Cache Poisoning

#### `02-XSS-and-Client-Side`

* Cross-Site Scripting (XSS)
* DOM-Based Vulnerabilities
* Cross-Origin Resource Sharing (CORS)
* Clickjacking
* Prototype Pollution

#### `03-SQL-Injection`

* SQL Injection
* NoSQL Injection

#### `04-File-and-Resource-Attacks`

* Directory Traversal (LFI / Path Traversal)
* File Upload Vulnerabilities
* XML External Entity (XXE) Injection
* Insecure Deserialization
* OS Command Injection

#### `05-Common-Attacks-Auth-Session`

* Authentication
* Access Control Vulnerabilities & IDOR
* Cross-Site Request Forgery (CSRF)
* Business Logic Vulnerabilities
* OAuth Authentication
* JWT (JSON Web Tokens)
* Race Conditions

#### `06-Web-Services-and-APIs`

* API Testing
* GraphQL API Vulnerabilities
* Server-Side Request Forgery (SSRF)
* WebSockets

#### `07-CMS-Security-Testing`

*(Note: PortSwigger does not have a dedicated "CMS" module, but specific WordPress & Drupal exploit scenarios appear inside **Information Disclosure**, **File Uploads**, and **SQL Injection** labs. Store those specific CMS writeups here).*

#### `08-Encoding-Filtering-Evasion`

* Server-Side Template Injection (SSTI)
* HTTP Request Smuggling

---

**Chapter 1–3: Recon & Proxies (WSTG-INFO, WSTG-CONF)**

| PortSwigger Category | Lab Name | Level | Core Concept / Skill |
| --- | --- | --- | --- |
| **Information disclosure** | Information disclosure in error messages | Apprentice | Analyzing verbose stack traces to reveal backend frameworks and versions |
| **Information disclosure** | Information disclosure on debug page | Apprentice | Uncovering unlinked administrative/debug endpoints containing sensitive data |
| **Information disclosure** | Source code disclosure via backup files | Apprentice | Locating exposed backup files (`.bak`, `.old`) to extract source code |
| **Information disclosure** | Information disclosure in version control history | Practitioner | Extracting sensitive credentials and code changes from exposed `.git` directories |
| **Information disclosure** | Authentication bypass via information disclosure | Practitioner | Finding leaked administrative endpoints or headers to bypass authentication |
| **Access control** | Unprotected admin functionality | Apprentice | Discovering hidden admin panels listed in `robots.txt` or HTML comments |
| **Access control** | Unprotected admin functionality with unpredictable URL | Apprentice | Crawling inline JavaScript files to expose unlinked administrative routes |

---

**Chapter 4: Cross-Site Scripting (XSS) (WSTG-INPV, WSTG-CLNT)**

| PortSwigger Category | Lab Name | Level | Core Concept / Skill |
| --- | --- | --- | --- |
| **Cross-site scripting** | Reflected XSS into HTML context with nothing encoded | Apprentice | Basic reflected XSS entry point |
| **Cross-site scripting** | Stored XSS into HTML context with nothing encoded | Apprentice | Persistent XSS stored in application database |
| **Cross-site scripting** | DOM XSS in `document.write` sink using source `location.search` | Apprentice | Source-to-sink DOM manipulation via URL query parameters |
| **Cross-site scripting** | DOM XSS in `innerHTML` sink using source `location.search` | Apprentice | Injecting HTML into sink without sanitization |
| **Cross-site scripting** | DOM XSS in jQuery anchor `href` attribute sink using `location.search` source | Apprentice | Manipulating JavaScript library sinks (`javascript:` URI scheme) |
| **Cross-site scripting** | DOM XSS in jQuery selector sink using a `hashchange` event | Apprentice | Exploiting `location.hash` and jQuery selector parsing flaws |
| **Cross-site scripting** | Reflected XSS into attribute with angle brackets HTML-encoded | Apprentice | Attribute breakout using quote delimiters (`" onfocus="...`) |
| **Cross-site scripting** | Stored XSS into anchor `href` attribute with double quotes HTML-encoded | Apprentice | Injecting payloads into URL attributes |
| **Cross-site scripting** | Reflected XSS into a JavaScript string with angle brackets HTML-encoded | Apprentice | Breaking out of JS string variables using quotes and semicolons |
| **Cross-site scripting** | Reflected XSS into a JavaScript string with single quote and backslash escaped | Practitioner | Bypassing string escaping using `</script>` tag breakout |
| **Cross-site scripting** | Reflected XSS into HTML context with most tags and attributes blocked | Practitioner | Enumerating allowed HTML tags and event handlers to bypass filters |
| **Cross-site scripting** | Reflected XSS into HTML context with all tags blocked except custom ones | Practitioner | Bypassing tag filters using custom tags and `onfocus` events |
| **Cross-site scripting** | Reflected XSS with event handlers blocked and attribute extras allowed | Practitioner | Exploiting allowed attributes (`canonical`, `href`, `src`) without event handlers |
| **Cross-site scripting** | Reflected XSS with some SVG markup allowed | Practitioner | Using SVG tags (`<svg><animatetransform>`) for XSS filter bypasses |
| **Cross-site scripting** | Reflected XSS in canonical link tag | Practitioner | Injecting access keys or query parameters into canonical tags |
| **Cross-site scripting** | Exploiting XSS to steal cookies | Practitioner | Exfiltrating session tokens to an external server via XSS |
| **Cross-site scripting** | Exploiting XSS to capture passwords | Practitioner | Injecting fake form fields to trigger browser password autocompletion |
| **Cross-site scripting** | Exploiting XSS to perform CSRF | Practitioner | Chaining XSS to read anti-CSRF tokens and perform privileged actions |

---

**Chapter 5: SQL Injection (WSTG-INPV-05)**

| PortSwigger Category | Lab Name | Level | Core Concept / Skill |
| --- | --- | --- | --- |
| **SQL injection** | SQL injection vulnerability in WHERE clause allowing retrieval of hidden data | Apprentice | Basic boolean OR injection (`' OR 1=1--`) to bypass query logic |
| **SQL injection** | SQL injection vulnerability allowing login bypass | Apprentice | Authentication bypass via SQL statement truncation |
| **SQL injection** | SQL injection UNION attack, determining the number of columns returned | Practitioner | Using `UNION SELECT NULL` to match query column count |
| **SQL injection** | SQL injection UNION attack, finding a column containing text | Practitioner | Mapping compatible data types across UNION columns |
| **SQL injection** | SQL injection UNION attack, retrieving data from other tables | Practitioner | Exfiltrating database tables/columns via `UNION SELECT` |
| **SQL injection** | SQL injection UNION attack, retrieving multiple values in a single column | Practitioner | Concatenating string outputs (e.g., `username || '~' || password`) |
| **SQL injection** | SQL injection attack, querying the database type and version on Oracle | Practitioner | Fingerprinting Oracle syntax (`FROM dual`, version tables) |
| **SQL injection** | SQL injection attack, querying the database type and version on MySQL/Microsoft | Practitioner | Fingerprinting MySQL/MSSQL specific comment styles and system variables |
| **SQL injection** | SQL injection attack, listing the database contents on non-Oracle databases | Practitioner | Querying `information_schema.tables` and `information_schema.columns` |
| **SQL injection** | SQL injection attack, listing the database contents on Oracle | Practitioner | Enumerating schema metadata using `all_tables` and `all_tab_columns` |
| **SQL injection** | Blind SQL injection with conditional responses | Practitioner | Extracting data character-by-character using true/false boolean responses |
| **SQL injection** | Blind SQL injection with conditional errors | Practitioner | Triggering runtime errors (e.g., divide-by-zero) to infer database values |
| **SQL injection** | Visible error-based SQL injection | Practitioner | Extracting data directly inside error message outputs (e.g., `CAST()`) |
| **SQL injection** | Blind SQL injection with time delays | Practitioner | Inferring execution state using time-delay functions (`pg_sleep`, `WAITFOR DELAY`) |
| **SQL injection** | Blind SQL injection with time delays and information retrieval | Practitioner | Exfiltrating credentials character-by-character via conditional time delays |

---

**Chapter 6: Common Attacks (WSTG-ATHN, WSTG-ATHZ, WSTG-SESS)**

| PortSwigger Category | Lab Name | Level | Core Concept / Skill |
| --- | --- | --- | --- |
| **Authentication** | Username enumeration via different responses | Apprentice | Identifying valid users based on subtle login error message changes |
| **Authentication** | Username enumeration via different response times | Practitioner | Identifying valid users via timing differences in password hash processing |
| **Authentication** | Username enumeration via subtly different responses | Practitioner | Detecting typo/spacing variations in error messages during brute forcing |
| **Authentication** | 2FA simple bypass | Apprentice | Bypassing 2FA verification steps via direct URL navigation |
| **Authentication** | 2FA broken logic | Practitioner | Exploiting session cookie flaws during the 2FA verification stage |
| **Authentication** | Password reset broken logic | Practitioner | Manipulating hidden parameters or session tokens during password resets |
| **Authentication** | Password brute-forcing via password change | Practitioner | Exploiting password change endpoints that lack rate limiting |
| **Access control** | User role can be modified in user profile | Apprentice | Mass assignment / privilege escalation via JSON parameters |
| **Access control** | User role controlled by request parameter | Apprentice | Tampering with role parameters (`admin=true`, `role=1`) |
| **Access control** | User ID controlled by request parameter (IDOR) | Apprentice | Horizontal privilege escalation by modifying numeric user IDs |
| **Access control** | User ID controlled by request parameter with data leakage in redirect | Practitioner | Intercepting sensitive user data in 302 redirect response bodies |
| **Access control** | User ID controlled by request parameter with unpredictable user IDs | Practitioner | Finding GUIDs/UUIDs leaked in public profiles or comments to perform IDOR |
| **Access control** | Method-based access control can be bypassed | Practitioner | Bypassing verb restrictions (switching `POST` to `GET` or `PUT`) |
| **CSRF** | CSRF vulnerability with no defenses | Apprentice | Classic cross-site request forgery against state-changing POST endpoints |
| **CSRF** | CSRF where token validation depends on request method | Practitioner | Bypassing CSRF checks by converting `POST` requests to `GET` |
| **CSRF** | CSRF where token validation depends on token being present | Practitioner | Bypassing CSRF checks by completely removing the token parameter |
| **CSRF** | CSRF where token is not tied to user session | Practitioner | Using a valid token from an attacker account to execute CSRF on a victim |
| **CSRF** | CSRF where token is tied to non-session cookie | Practitioner | Injecting a matching CSRF cookie via cookie-setting vulnerabilities |
| **CSRF** | CSRF where token is duplicated in cookie | Practitioner | Exploiting double-submit cookie patterns by manipulating cookie headers |
| **CSRF** | SameSite Lax bypass via method change | Practitioner | Bypassing `SameSite=Lax` controls by converting requests to top-level `GET` |
| **CSRF** | SameSite Strict bypass via client-side redirect | Practitioner | Bypassing `SameSite=Strict` via same-site client-side redirects |
| **JWT** | JWT authentication bypass via unverified signature | Apprentice | Stripping or ignoring the JWT signature block to forge administrative claims |
| **JWT** | JWT authentication bypass via flawed signature verification | Practitioner | Changing the JWT algorithm header to `"alg": "none"` |
| **JWT** | JWT authentication bypass via weak HMAC secret | Practitioner | Brute-forcing weak symmetric HMAC secrets (`secret`, `123456`) with Hashcat |

---

**Chapter 7: File & Resource Attacks (WSTG-INPV-11, WSTG-INPV-12)**

| PortSwigger Category | Lab Name | Level | Core Concept / Skill |
| --- | --- | --- | --- |
| **Path traversal** | File path traversal, simple case | Apprentice | Arbitrary file reading using basic `../` sequences |
| **Path traversal** | File path traversal, traversal sequences stripped non-recursively | Practitioner | Bypassing simple string filters using nested sequences (`....//....//`) |
| **Path traversal** | File path traversal, traversal sequences stripped with superfluous URL-decode | Practitioner | Bypassing filters using double URL-encoding (`%252e%252e%252f`) |
| **Path traversal** | File path traversal, validation of start of path | Practitioner | Traversing directories while satisfying base folder checks (`/var/www/images/../../../etc/passwd`) |
| **Path traversal** | File path traversal, validation of file extension with null byte bypass | Practitioner | Truncating file extension checks using `%00` null byte injection |
| **File upload vulnerabilities** | Remote code execution via web shell upload | Apprentice | Unrestricted upload of executable PHP code to obtain RCE |
| **File upload vulnerabilities** | Web shell upload via Content-Type restriction bypass | Apprentice | Changing `Content-Type: application/x-php` to `image/jpeg` in Burp |
| **File upload vulnerabilities** | Web shell upload via path traversal | Practitioner | Uploading web shells outside execution-blocked directories using `../` in filename |
| **File upload vulnerabilities** | Web shell upload via extension blacklist bypass | Practitioner | Overriding server configuration files (`.htaccess` / Apache directives) |
| **File upload vulnerabilities** | Web shell upload via obfuscated file extension | Practitioner | Using null bytes (`shell.php%00.jpg`) or multi-extensions (`shell.php.jpg`) |
| **File upload vulnerabilities** | Remote code execution via polyglot web shell upload | Practitioner | Embedding PHP code into image metadata (EXIF) to bypass magic byte checks |
| **OS command injection** | OS command injection, simple case | Apprentice | Arbitrary command execution using command separators (`;`, `|`, `&&`) |
| **OS command injection** | Blind OS command injection with time delays | Practitioner | Confirming blind injection using sleep commands (`ping -c 10 127.0.0.1`) |
| **OS command injection** | Blind OS command injection with output redirection | Practitioner | Redirecting command output to accessible static folders (`> /var/www/static/out.txt`) |

---

**Chapter 8: Web Services & APIs (WSTG-APIT)**

| PortSwigger Category | Lab Name | Level | Core Concept / Skill |
| --- | --- | --- | --- |
| **API testing** | Exploiting an API endpoint using documentation | Apprentice | Discovering interactive API docs (Swagger/OpenAPI) to identify hidden methods |
| **API testing** | Finding and exploiting an unused API endpoint | Practitioner | Fuzzing HTTP methods (`GET`, `POST`, `PUT`, `DELETE`) on unlinked API paths |
| **API testing** | Exploiting a mass assignment vulnerability | Practitioner | Adding hidden JSON attributes (`"is_admin": true`) to user modification calls |
| **Server-side parameter pollution** | Exploiting server-side parameter pollution in a query string | Practitioner | Overriding API parameters by injecting URL-encoded parameter delimiters (`%26`) |

---

**Chapter 9: CMS Security (WSTG-INFO, WSTG-INPV, WSTG-ATHN)**

| PortSwigger Category | Crossover Lab Name | Level | OWASP / CMS Application Context |
| --- | --- | --- | --- |
| **Information disclosure** | Source code disclosure via backup files | Apprentice | Finding exposed `wp-config.php.bak` or configuration backups |
| **Authentication** | Username enumeration via different responses | Apprentice | Enumerating authors/users (mimicking WP `/author=1` or XML-RPC enumeration) |
| **File upload vulnerabilities** | Web shell upload via extension blacklist bypass | Practitioner | Exploiting vulnerable plugin upload functions to deploy web shells |
| **SQL injection** | SQL injection vulnerability in WHERE clause | Apprentice | Exploiting unpatched plugin/theme database queries |
| **Information disclosure** | Authentication bypass via information disclosure | Practitioner | Extracting API tokens or session keys from exposed plugin settings |

---

**Chapter 10: Encoding & Evasion (Cross-Cutting WAF Bypasses)**

| PortSwigger Category | Lab Name | Level | Core Concept / Skill |
| --- | --- | --- | --- |
| **Cross-site scripting** | Reflected XSS into attribute with angle brackets HTML-encoded | Apprentice | Bypassing context-specific sanitization using attribute quote breakout |
| **Path traversal** | File path traversal, traversal sequences stripped with superfluous URL-decode | Practitioner | Double URL-encoding to bypass WAF path normalization layers |
| **File upload vulnerabilities** | Web shell upload via obfuscated file extension | Practitioner | Extension obfuscation (`.php.`, `.pHp`, trailing dots/spaces) for filter evasion |
| **SQL injection** | SQL injection with filter bypass via XML encoding | Practitioner | Encoding SQL payloads into XML entities to bypass WAF inspection |
| **Cross-site scripting** | Reflected XSS into HTML context with most tags and attributes blocked | Practitioner | Systematic tag/attribute brute-forcing to bypass WAF restriction lists |
| **Cross-site scripting** | Reflected XSS with event handlers blocked and attribute extras allowed | Practitioner | Alternate vector execution when standard event handlers are scrubbed |

---

You are completely right to point this out—that difference needs a clear explanation.

The shift in scope comes down to the difference between **Vault Storage Architecture** (where *all* PortSwigger labs live) and **Exam-Targeted Curation** (the *88 labs filtered strictly for eWPT*).

### Why the 88-Lab List Contains Fewer Topics

When building your **8 INE Vault Folders**, the goal was to create a future-proof note-taking layout for the *entire* PortSwigger Academy so no lab writeup ever ends up without a home.

However, when narrowing down the labs to **eWPT/eWPTv2 specific preparation**, non-exam topics were deliberately pruned.

* **Pruned (Out of Scope for eWPT):** Topics like *HTTP Request Smuggling, Web Cache Poisoning, Prototype Pollution, Race Conditions, OAuth complex flows,* and *Advanced GraphQL* are advanced PortSwigger research modules. INE's official eWPT syllabus does not test these. Keeping them in the 88-lab list would add 40+ hours of prep time for concepts that will not appear on your exam.
* **Retained (In Scope for eWPT):** XSS, SQL Injection, Path Traversal, File Uploads, Command Injection, Auth/Session issues, CORS, XXE, SSRF, CMS security, and Web Services.

---

### Folder-to-Exam Alignment Matrix

| INE Vault Folder | eWPT Master Chapter | PortSwigger Scope Included in 88 Labs |
| --- | --- | --- |
| `01-Info-Gathering-and-Proxies` | **Ch 1–3: Recon & Proxies** | Essential Skills, Information Disclosure, HTTP basics |
| `02-XSS-and-Client-Side` | **Ch 4: XSS & Client-Side** | XSS (Reflected, Stored, DOM), CORS, Clickjacking |
| `03-SQL-Injection` | **Ch 5: SQL Injection** | In-band SQLi, Blind SQLi, Error-based SQLi |
| `04-File-and-Resource-Attacks` | **Ch 7: File & Resource Attacks** | Path Traversal, File Uploads, XXE, Command Injection |
| `05-Common-Attacks-Auth-Session` | **Ch 6: Common Attacks** | Authentication bypass, Session security, CSRF, IDOR/Access Control |
| `06-Web-Services-and-APIs` | **Ch 8: Web Services & APIs** | API Enumeration, SSRF, Web Service Endpoints |
| `07-CMS-Security-Testing` | **Ch 9: CMS Security** | CMS-specific SQLi, Uploads, & Auth bypasses |
| `08-Encoding-Filtering-Evasion` | **Ch 10: Encoding & Evasion** | WAF bypasses, obfuscation, input filter evasion |
