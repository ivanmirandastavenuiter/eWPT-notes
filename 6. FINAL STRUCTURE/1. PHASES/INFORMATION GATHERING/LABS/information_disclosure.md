### [PS-INFO-01] Information Disclosure in Error Messages

**Scenario:** The target e-commerce application leaks third-party framework details in verbose stack traces when handled endpoints receive unexpected data types.

**Solution:**

1. Navigate to any product page (e.g., `/product?productId=1`).
2. Intercept request in Burp Suite and send to **Repeater** (`Ctrl + R`).
3. Modify parameter from integer (`productId=1`) to string (`productId=abc` or `productId='`) to trigger an unhandled type mismatch error.
4. Send request and inspect HTTP 500 response body for framework headers: `Apache Struts 2 2.3.31`.
5. Submit `Apache Struts 2 2.3.31` into the solution box.

> **Key Takeaway:** Passing invalid data types (strings/symbols into integer fields) is a reliable method to bypass default error handlers and leak exact framework versions for CVE mapping.

### [PS-INFO-02] Information disclosure on debug page

**Scenario:** The target application contains a publicly accessible debug page left enabled in production, exposing sensitive system environment variables including the application's secret key.

**Solution:**

1. Open the target homepage and inspect the HTML source code (`Ctrl + U` or right-click -> View Page Source).
2. Search for comments or debug links to find the hidden path (e.g., `<!-- Debug page: /cgi-bin/phpinfo.php -->`).
3. Navigate directly to the debug endpoint in your browser (`/cgi-bin/phpinfo.php`).
4. Search the rendered page (`Ctrl + F`) for the environment variable `SECRET_KEY`.
5. Copy the corresponding secret key value and submit it via the solution banner.

> **Key Takeaway:** Developer debug files (e.g., `phpinfo()`, `/debug`, Django debug pages) left in production environments expose critical secrets, framework configurations, and internal file paths. Always inspect HTML source comments during initial web recon.

### [PS-INFO-03] Source code disclosure via backup files

**Scenario:** The target web application exposes its raw backend source code via a backup file left in a publicly accessible directory, revealing hardcoded database credentials.

**Solution:**

1. Navigate to `/robots.txt` in your browser to inspect crawl directives and locate hidden endpoints (e.g., `Disallow: /backup/`).
2. Access the `/backup/` path in your browser to view directory listing permissions.
3. Download or view the backup file (e.g., `ProductTemplate.java.bak`).
4. Inspect the source code for hardcoded configuration strings to find the database connection password.
5. Copy the extracted password and submit it via the lab solution box.

> **Key Takeaway:** Text editors, deployment scripts, and manual backup routines often leave hidden or renamed files (`.bak`, `.old`, `.swp`, `~`) in web roots. Always check `/robots.txt` and fuzz for common backup extensions during directory enumeration.

### [PS-INFO-04] Authentication bypass via information disclosure

**Scenario:** The target application restricts its admin panel (`/admin`) to local users only. A front-end reverse proxy appends an internal HTTP header to validate client IP addresses, which can be disclosed using the HTTP `TRACE` method.

**Solution:**

1. Send a request to `/admin` in Burp Repeater and observe the access restriction message.
2. Change the HTTP request method from `GET` to `TRACE` (e.g., `TRACE /admin` or `TRACE /`) and send the request.
3. Inspect the response body to discover internal headers appended by the reverse proxy (e.g., `X-Custom-IP-Authorization: <IP_ADDRESS>`).
4. Revert request method to `GET /admin` and add the disclosed header with a local loopback value: `X-Custom-IP-Authorization: 127.0.0.1`.
5. Send the modified request to bypass authentication, access the admin panel, and delete target user `carlos`.

> **Key Takeaway:** Reverse proxies and load balancers often pass client metadata via custom HTTP headers (`X-Custom-IP-Authorization`, `X-Forwarded-For`). Identifying these headers via verbose methods like `TRACE` enables header spoofing to bypass IP-based access controls.

### [PS-INFO-05] Information disclosure in version control history

**Scenario:** The target application exposes its public `.git` directory, allowing attackers to download the version control history, review previous commits, and recover hardcoded administrative credentials that were removed in later commits.

**Solution:**

1. Append `/.git` (or `/.git/HEAD`) to the target domain URL in the browser to confirm exposure of the Git repository.
2. Open a Kali terminal and download the entire Git repository using `git-dumper`:
```bash
git-dumper https://target.web-security-academy.net/.git ./target_git

```


*(Alternative native Kali command using `wget`: `wget -r -np -P ./target_git [https://target.web-security-academy.net/.git/](https://target.web-security-academy.net/.git/)`)*
3. Navigate into the downloaded directory:
```bash
cd ./target_git

```


4. Review the commit history:
```bash
git log --oneline

```


5. Locate the commit message referencing credential removal or setup (e.g., "Remove admin password") and view the code diff:
```bash
git show <COMMIT_HASH>

```


6. Copy the exposed administrator password, log in as `administrator` in your browser, and access the admin panel to delete user `carlos`.

> **Key Takeaway:** Exposing `/.git` directories allows complete reconstruction of application source code and revision history. Secrets committed to Git remain permanently accessible in past commit logs even if deleted or refactored in later updates.

### [INE-INFO-01] Apache Web Server Fingerprinting & Reconnaissance

**Scenario:** Perform web server fingerprinting, CLI content inspection, directory brute-forcing, and robot enumeration against a target Apache web server (`demo.ine.local`) to identify web app stack details and restricted crawlers.

**Solution:**

1. Verify target host reachability:
```bash
ping -c 4 demo.ine.local

```


2. Fingerprint web server software and banner information using Nmap:
```bash
nmap -sV --script banner demo.ine.local

```


3. Fingerprint web application version via Metasploit auxiliary module:
```bash
msfconsole -q -x "use auxiliary/scanner/http/http_version; set RHOSTS demo.ine.local; run; exit"

```


4. Inspect hosted web content directly via CLI tools:
```bash
curl -s http://demo.ine.local/
# Alternatively view via text browser:
lynx http://demo.ine.local

```


5. Perform directory brute-forcing using `dirb` and Metasploit wordlists:
```bash
dirb http://demo.ine.local /usr/share/metasploit-framework/data/wordlists/directory.txt

```


6. Identify disallowed bots and restricted paths via Metasploit `robots_txt` scanner:
```bash
msfconsole -q -x "use auxiliary/scanner/http/robots_txt; set RHOSTS demo.ine.local; run; exit"

```



> **Key Takeaway:** Combining automated server fingerprinting (Nmap/Metasploit) with directory fuzzing (`dirb`) and `robots.txt` parsing quickly reveals web stack versions, unlinked endpoints, and crawler restrictions.

### [INE-INFO-02] DNS Zone Transfer & Subdomain Interrogation

**Scenario:** Interrogate an internal DNS server (`192.84.45.3`) hosting domain `witrap.com` to perform an unauthorized AXFR zone transfer, uncover subdomains, extract secret TXT records, and map reverse DNS entries across the internal IP subnet (`192.168.0.0/16`).

**Solution:**

1. Execute an AXFR zone transfer to enumerate all A records and subdomains:
```bash
dig axfr witrap.com @192.84.45.3

```


2. Identify internal host IPs from returned zone records (e.g., LDAP service running at `192.168.62.11`).
3. Locate sensitive information stored inside subdomain TXT records (e.g., `my_s3cr3t_fl4g`).
4. Perform reverse DNS zone transfer across the target IP range (`192.168.0.0/16`) to uncover non-contiguous hostnames:
```bash
dig axfr -x 192.168 @192.84.45.3

```



> **Key Takeaway:** Misconfigured DNS servers allowing unauthenticated AXFR zone transfers leak the entire internal domain topology, host IP mapping, and sensitive TXT metadata in a single query.

### [INE-INFO-03] Directory and File Enumeration with Gobuster

**Scenario:** Perform directory and file extension brute-forcing against a target web server (`192.137.160.3`) while filtering out noise status codes to discover hidden web pages and configuration files.

**Solution:**

1. Execute basic directory brute-forcing using `gobuster`:
```bash
gobuster dir -u http://192.137.160.3 -w /usr/share/wordlists/dirb/common.txt

```


2. Exclude HTTP status codes `403` and `404` to eliminate terminal noise:
```bash
gobuster dir -u http://192.137.160.3 -w /usr/share/wordlists/dirb/common.txt -b 403,404

```


3. Search specifically for hidden file extensions (`.php`, `.txt`, `.xml`) with HTTP redirect following enabled (`-r`):
```bash
gobuster dir -u http://192.137.160.3 -w /usr/share/wordlists/dirb/common.txt -b 403,404 -x .php,.txt,.xml -r

```



> **Key Takeaway:** Adding file extension flags (`-x .php,.txt,.xml`) and filtering negative HTTP status codes (`-b 403,404`) during `gobuster` execution significantly increases signal-to-noise ratio when hunting for sensitive files.

### [INE-INFO-04] Automated Attack Surface Mapping with OWASP Amass

**Scenario:** Map the external attack surface of target domain `zonetransfer.me` using OWASP Amass to perform passive OSINT enumeration, active DNS brute-forcing, WHOIS infrastructure mapping, and visual graph generation.

**Solution:**

1. Run passive subdomain discovery displaying data sources:
```bash
amass enum -passive -d zonetransfer.me -src -dir ./ZTME

```


2. Run active subdomain brute-forcing with IP resolution:
```bash
amass enum -d zonetransfer.me -src -ip -brute -dir ./ZTME_Brute

```


3. Discover additional root domains and infrastructure using active WHOIS intelligence:
```bash
amass intel -active -whois -d zonetransfer.me -dir ./ZTME_Intel

```


4. Generate a D3 network visualization graph from stored enumeration data:
```bash
amass viz -dir ./ZTME -d3

```



> **Key Takeaway:** Amass merges OSINT search APIs with active DNS brute-forcing and WHOIS correlation to map a target's complete external perimeter and domain infrastructure.