# Attacks & Payloads – Phase 1: Information Gathering & Proxies

## Global conventions

- `<IP>` – Exam IP (bare address).  
- `<HOST>` – Resolved hostname (e.g., `app.target.com`).  
- `<SCHEME>` – `http` or `https`.  
- `<PORT>` – Explicit port (80, 443, 8080, 8443, etc.).  
- `<VHOST>` – Virtual host in a `Host` header (e.g., `admin.target.com`).  
- `<DOMAIN>` – Registered domain (`target.com`).  
- `<SUBDOMAIN>` – Subdomain (`dev.target.com`).  
- `<WORDLIST>` – Path to wordlist.  
- `<COOKIE>` – Session cookie string (`PHPSESSID=...`).  
- `<PROXY>` – HTTP proxy (e.g., `127.0.0.1:8080`).

Use `mkdir -p recon/` and keep outputs there for reporting and retesting.

***

## 🔴 Mandatory: Asynchronous (Fire & Forget)

Run these as soon as you see the exam IPs; let them complete in the background while you read questions and set up Burp.

***

### Nmap – Network & Web Service Discovery

**Description:** Port scanner for discovering services, versions, and HTTP-related metadata. [adhdecode](https://adhdecode.com/articles/nmap/nmap-http-enumeration-web-discovery/)

**Use when (Checklist):**

- WSTG-CONF-01 – Full port scan.  
- WSTG-INFO-04 – Enumerate web apps on non-standard ports. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

**Commands:**

- Full TCP scan + default scripts + version detection (main async scan):

```bash
nmap -sC -sV -p- --min-rate 1000 <IP> \
  -oN recon/nmap-full.txt -oX recon/nmap-full.xml
```

- Fast top-ports baseline:

```bash
nmap -F <IP> -oN recon/nmap-fast.txt
```

- Focus on common web ports (quick web map):

```bash
nmap -sV -p 80,443,8000,8080,8443,8888 <IP> \
  -oN recon/nmap-web-ports.txt
```

- HTTP enumeration on known web ports (titles, robots, methods, etc.): [adhdecode](https://adhdecode.com/articles/nmap/nmap-http-enumeration-web-discovery/)

```bash
nmap -sV -p 80,443 \
  --script=http-enum,http-title,http-methods,http-robots.txt \
  <IP> \
  -oN recon/nmap-http-enum.txt
```

**Pivot:**

- For each open web port, set `<SCHEME>://<VHOST>:<PORT>` in Burp and feed into ffuf/Gobuster and Nikto.

***

### testssl.sh – TLS/Certificate Recon

**Description:** TLS/SSL scanner for weak ciphers and certificates, including SANs (Subject Alternative Names). [owasp](https://owasp.org/www-project-web-security-testing-guide/)

**Use when (Checklist):**

- WSTG-CONF-01 – Audit TLS/SSL for misconfigurations and extra domains.

**Commands:**

- Full TLS scan:

```bash
testssl.sh "<SCHEME>://<HOST>:<PORT>" \
  > recon/testssl-full.txt
```

- SAN extraction to discover additional hostnames:

```bash
testssl.sh -S "<SCHEME>://<HOST>:<PORT>" \
  > recon/testssl-sans.txt
```

**Pivot:**

- Add SAN hostnames to `/etc/hosts`, Burp scope, and ffuf/Gobuster scans.

***

### Dig – DNS / Zone Transfer / CNAME

**Description:** DNS query tool for AXFR (zone transfer), CNAMEs, and reverse records.

**Use when (Checklist):**

- WSTG-CONF-01 – Attempt DNS zone transfer.  
- WSTG-CONF-10 – Subdomain takeover (later, but start collecting data here). [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

**Commands:**

- Find authoritative nameservers:

```bash
dig NS <DOMAIN> +short
```

- Attempt AXFR against each authoritative NS:

```bash
dig axfr <DOMAIN> @<NAMESERVER> \
  > recon/dns-zone-transfer.txt
```

- Reverse DNS for IP:

```bash
dig -x <IP> +short \
  > recon/dns-reverse.txt
```

**Pivot:**

- If AXFR succeeds, you get full DNS records—extract subdomains, IPs, and MX/NS/WWW records for mapping.

***

### ffuf – Async Discovery (VHosts, Directories, Backups)

**Description:** High-speed fuzzer for directories, virtual hosts, files, and backups. [adminions](https://adminions.ca/books/web-attacks/page/ffuf)

**Use when (Checklist):**

- WSTG-INFO-04 – Fuzz virtual hosts (Host header).  
- WSTG-CONF-05 – Enumerate admin interfaces (directories).  
- WSTG-CONF-02 – Fuzz for backups/temp files. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Baseline soft-404 detection (do once per host)

```bash
curl -sk "<SCHEME>://<VHOST>/this_should_not_exist_123" | wc -c
# Note the size as <BASELINE_SIZE>
```

#### VHost fuzzing (Host header)

```bash
ffuf -u "http://<IP>/" \
     -H "Host: FUZZ.<DOMAIN>" \
     -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -fs <BASELINE_SIZE> \
     -t 10 \
     -o recon/ffuf-vhosts.json -of json
```

**Extra examples:** [phrack](https://www.phrack.me/tools/2022/07/06/Ffuf-cheatsheet.html)

- Slow but safer (fewer bans):

```bash
ffuf -u "http://<IP>/" \
     -H "Host: FUZZ.<DOMAIN>" \
     -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -fs <BASELINE_SIZE> \
     -t 5 \
     -o recon/ffuf-vhosts-slow.json -of json
```

#### Directory & admin panel discovery

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
     -mc 200,301,302,403 \
     -t 10 \
     -o recon/ffuf-root.json -of json
```

- Recursive scan for deeper paths: [phrack](https://www.phrack.me/tools/2022/07/06/Ffuf-cheatsheet.html)

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-small.txt:FUZZ \
     -recursion -recursion-depth 1 \
     -e .php \
     -mc 200,301,302,403 \
     -t 10 \
     -o recon/ffuf-root-recursive.json -of json
```

#### Backup & temp files on known resources

```bash
ffuf -u "<SCHEME>://<VHOST>/index.phpFUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt \
     -e .bak,.old,.swp,.tmp,~ \
     -t 10 \
     -o recon/ffuf-backups-index.json -of json
```

- Against an admin or config path:

```bash
ffuf -u "<SCHEME>://<VHOST>/configFUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt \
     -e .bak,.old,.zip,.tar.gz \
     -t 10 \
     -o recon/ffuf-backups-config.json -of json
```

**Pivot:**

- For each `200/302/403` hit, verify manually in Burp; mark admin-like paths (`/admin`, `/manage`, `/dashboard`, etc.) for later auth testing.

***

### Gobuster – Async Alternative for Directories & Files

**Description:** Directory/file and DNS brute-forcing tool, useful if you prefer its interface or need more filtering options. [hackertarget](https://hackertarget.com/gobuster-tutorial/)

**Use when (Checklist):**

- WSTG-CONF-05 – Enumerate admin interfaces (alternative to ffuf).  
- WSTG-CONF-02 – Discover backup/config files. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Basic directory scan

```bash
gobuster dir \
  -u "<SCHEME>://<VHOST>/" \
  -w /usr/share/wordlists/dirb/common.txt \
  -t 10 \
  -o recon/gobuster-root.txt
```

#### Directories + file extensions

```bash
gobuster dir \
  -u "<SCHEME>://<VHOST>/" \
  -w /usr/share/wordlists/dirb/common.txt \
  -x php,html,txt,bak \
  -t 10 \
  -o recon/gobuster-root-ext.txt
```

#### Filter or exclude by status/content length: [hackviser](https://hackviser.com/tactics/tools/gobuster)

```bash
gobuster dir \
  -u "<SCHEME>://<VHOST>/" \
  -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
  -s 200,204,301,302,307 \
  --exclude-length 1234 \
  -t 10 \
  -o recon/gobuster-filtered.txt
```

**Pivot:**

- Treat Gobuster hits like ffuf hits—verify in browser/Burp, record admin and backup endpoints.

***

### WhatWeb – Automated Tech Stack Fingerprint

**Description:** Web technology fingerprinting (CMS, frameworks, plugins, and headers). [owasp](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/)

**Use when (Checklist):**

- WSTG-INFO-02 (Automated) – Fingerprint web server and stack. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Standard fingerprint

```bash
whatweb "<SCHEME>://<VHOST>/" \
  > recon/whatweb.txt
```

#### Verbose fingerprint

```bash
whatweb -v "<SCHEME>://<VHOST>/" \
  > recon/whatweb-verbose.txt
```

**Pivot:**

- Use CMS/framework findings (WordPress, Drupal, Laravel, ASP.NET, Spring, etc.) to plan stack-specific checks later (default admin paths, framework debug endpoints).

***

### Nikto – Automated Web Server Scan

**Description:** Web server scanner for misconfigurations, dangerous files, and some injection/info-disclosure checks. [cirt](https://cirt.net/nikto/)

**Use when (Checklist):**

- WSTG-INFO-02 (Automated) – Quick vulnerability scan after basic fingerprinting. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Focused low-noise scan

```bash
nikto -h "<SCHEME>://<VHOST>/" \
      -Tuning 23 \
      -o recon/nikto-quiet.txt \
      -Format txt
```

#### Multi-port HTTPS-aware scan

```bash
nikto -h "<SCHEME>://<VHOST>/" \
      -p 80,443,8080,8443 \
      -ssl \
      -Tuning x6 \
      -o recon/nikto-multi.txt \
      -Format txt
```

#### Through Burp proxy with cookies

```bash
nikto -h "<SCHEME>://<VHOST>/" \
      -useproxy http://<PROXY> \
      -cookie "<COOKIE>" \
      -o recon/nikto-proxy.txt \
      -Format txt
```

**Pivot:**

- For each “interesting” finding (backup files, admin panels, verbose errors, default scripts), confirm manually and tie back to checklist items (admin interfaces, platform configuration, error handling).

***

## 🟡 Mandatory: Active / Passive Manual Recon

Carry these out while async tools run, mainly via Burp + browser, but CLI helps for quick checks and reproductions.

***

### cURL – Headers, Errors, Metafiles

**Description:** Simple HTTP client for quick header checks, method tests, and metafile requests.

**Use when (Checklist):**

- WSTG-INFO-02 (Manual) – Inspect headers, trigger errors.  
- WSTG-INFO-03 – Request metafiles. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Fetch headers only (server fingerprint)

```bash
curl -sk -I "<SCHEME>://<VHOST>:<PORT>/" 
```

- Note `Server`, `X-Powered-By`, framework/version headers, and security headers.

#### Trigger verbose 404/500 errors

```bash
curl -sk -i "<SCHEME>://<VHOST>:<PORT>/nonexistent_test_page_123"
```

- Compare error page content with normal pages; look for version strings or stack traces.

#### Request common metafiles (robots, sitemap, etc.)

```bash
curl -sk "<SCHEME>://<VHOST>/robots.txt" \
  > recon/robots.txt

curl -sk "<SCHEME>://<VHOST>/sitemap.xml" \
  > recon/sitemap.xml

curl -sk "<SCHEME>://<VHOST>/.well-known/security.txt" \
  > recon/security.txt

curl -sk "<SCHEME>://<VHOST>/crossdomain.xml" \
  > recon/crossdomain.xml

curl -sk "<SCHEME>://<VHOST>/humans.txt" \
  > recon/humans.txt
```

**Pivot:**

- Parse `Disallow:` entries, API paths, staging URLs, and contact emails; add any hidden paths to Burp scope.

***

### HTTP Request Primitives (curl)

**Description:** Reusable template for controlled HTTP requests (methods, headers, cookies, bodies).

**Use when (Checklist):**

- WSTG-INFO-06/07 – Reproducing workflow requests outside the browser.  
- WSTG-CONF-06 – HTTP method testing. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Generic template

```bash
curl -sk -i --path-as-is \
  -H "Host: <VHOST>" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -b "<COOKIE>" \
  -X <METHOD> \
  --data '<BODY>' \
  "<SCHEME>://<IP>:<PORT><PATH>"
```

**Examples:**

- Authenticated GET on profile:

```bash
curl -sk -i \
  -H "Host: <VHOST>" \
  -b "<COOKIE>" \
  "<SCHEME>://<IP>:<PORT>/profile"
```

- JSON POST to API:

```bash
curl -sk -i \
  -H "Host: <VHOST>" \
  -H "Content-Type: application/json" \
  -b "<COOKIE>" \
  -X POST \
  --data '{"action":"update","field":"email","value":"test@example.com"}' \
  "<SCHEME>://<IP>:<PORT>/api/user"
```

- Through Burp proxy:

```bash
curl -sk -i \
  --proxy http://<PROXY> \
  -H "Host: <VHOST>" \
  "<SCHEME>://<IP>:<PORT>/"
```

**Pivot:**

- Use this template to mirror Burp requests but change one variable (method, header, body field) at a time for later auth/logic testing.

***

### ffuf – Parameter & API Discovery

**Description:** Fuzz parameter names and values (GET/POST) to discover hidden inputs and API behavior. [hackersghost](https://hackersghost.com/ffuf-tutorial/)

**Use when (Checklist):**

- WSTG-INFO-06 – Identify application entry points beyond visible forms.  
- WSTG-INFO-07 – Map multi-step workflows and hidden parameters. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Fuzz GET parameter names

```bash
ffuf -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt:FUZZ \
     -u "http://<VHOST>/search.php?FUZZ=test" \
     -mc all \
     -fs <BASELINE_SIZE> \
     -t 5 \
     -o recon/ffuf-get-params.json -of json
```

#### Fuzz POST parameter names (form-encoded)

```bash
ffuf -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt:FUZZ \
     -u "http://<VHOST>/admin/admin.php" \
     -X POST \
     -d 'FUZZ=key' \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -fs <BASELINE_SIZE> \
     -t 5 \
     -o recon/ffuf-post-params.json -of json
```

#### Fuzz parameter values after finding a valid parameter

Create a numeric list:

```bash
for i in $(seq 1 1000); do echo $i >> ids.txt; done
```

Then fuzz the `id` parameter:

```bash
ffuf -w ids.txt:FUZZ \
     -u "http://<VHOST>/admin/admin.php" \
     -X POST \
     -d 'id=FUZZ' \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -fs <BASELINE_SIZE> \
     -t 5 \
     -o recon/ffuf-id-values.json -of json
```

**Pivot:**

- Valid new parameters often indicate hidden functionality; map where they appear in workflows and mark candidates for IDOR, injection, and logic tests.

***

### Gobuster – API & Auth-Context Discovery

**Description:** Directory enumeration in authenticated or API contexts. [hackerdna](https://hackerdna.com/blog/how-to-use-gobuster)

**Use when (Checklist):**

- WSTG-INFO-06 – Discover API endpoints and entry points.  
- WSTG-INFO-07 – Explore nested workflow URLs. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Authenticated directory scan with cookies

```bash
gobuster dir \
  -u "<SCHEME>://<VHOST>/" \
  -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
  -c "session=<COOKIE>" \
  -t 10 \
  -o recon/gobuster-auth.txt
```

#### API endpoint discovery

```bash
gobuster dir \
  -u "<SCHEME>://<VHOST>/api" \
  -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt \
  -t 10 \
  -o recon/gobuster-api.txt
```

**Pivot:**

- Feed discovered API routes into parameter fuzzing (ffuf) and later business logic testing.

***

## ⚪ Extra / Situational (Question-Driven)

Use these only when a question hints at them or when you hit blockers like WAF, 403s, or explicit OSINT tasks.

***

### HTTP Methods – OPTIONS / PUT / DELETE / TRACE

**Description:** Test which methods are enabled and whether dangerous verbs are misused. WSTG recommends checking OPTIONS, then attempting other methods on target resources. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

**Use when (Checklist):**

- WSTG-CONF-06 – Test HTTP methods on 403 or restricted pages. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Global OPTIONS on root

```bash
curl -sk -i -X OPTIONS "<SCHEME>://<VHOST>:<PORT>/" 
```

- Inspect `Allow:` header for `PUT`, `DELETE`, `TRACE`, etc.

#### Method probing on a restricted resource

```bash
curl -sk -i -X OPTIONS "<SCHEME>://<VHOST>:<PORT>/admin"
curl -sk -i -X PUT "<SCHEME>://<VHOST>:<PORT>/admin" \
  -d 'test=data'
curl -sk -i -X DELETE "<SCHEME>://<VHOST>:<PORT>/admin/test"
curl -sk -i -X TRACE "<SCHEME>://<VHOST>:<PORT>/admin"
```

**Pivot:**

- If non-GET methods succeed where GET fails, record as potential method-based access control issue; retest carefully in later phases.

***

### wafw00f – WAF Detection & Behavior

**Description:** Detect presence and type of WAF protecting the application. [darknet.org](https://www.darknet.org.uk/2016/05/wafw00f-fingerprint-identify-web-application-firewall-waf-products/)

**Use when (Checklist):**

- WSTG-INFO-10 – Map application architecture when payloads are blocked. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Standard fingerprint

```bash
wafw00f "<SCHEME>://<VHOST>/" \
  > recon/wafw00f.txt
```

#### Aggressive signature search

```bash
wafw00f -a "<SCHEME>://<VHOST>/" \
  > recon/wafw00f-all.txt
```

**Behavior probing (with curl):**

```bash
curl -sk -i "<SCHEME>://<VHOST>/?q=' OR 1=1" 
curl -sk -i "<SCHEME>://<VHOST>/?q=<script>alert(1)</script>"
```

- Compare responses with benign queries; note status codes, error pages, and block messages.

**Pivot:**

- Adjust fuzzing rate, randomize payloads, and consider encodings if WAF is detected; document its presence for the exam.

***

### OSINT – Search Engine / Shodan / Code Repos

**Description:** External recon using search engines and OSINT platforms; mostly manual but keep example queries handy. [medium](https://medium.com/@cuncis/how-to-use-owasp-web-security-testing-guide-wstg-to-improve-your-web-application-security-94e8b17d589d)

**Use when (Checklist):**

- WSTG-INFO-01 – Explicit OSINT questions. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

**Example Google dorks:**

```text
site:<DOMAIN> ext:xml OR ext:conf OR ext:bak
site:<DOMAIN> inurl:admin OR inurl:staging OR inurl:test
site:<DOMAIN> "index of" "backup"
```

**Example code repo searches:**

```text
"<DOMAIN>" "API_KEY"
"<DOMAIN>" "secret" "token"
"<DOMAIN>" path:config
```

**Pivot:**

- Add any discovered admin portals, staging systems, or leaked repos into your scope (if still in exam scope) and note them in the report.

***

### Subzy – Subdomain Takeover Check

**Description:** Subdomain takeover checker using fingerprints for common cloud providers. [trickest](https://trickest.com/tools/subzy)

**Use when (Checklist):**

- WSTG-CONF-10 – Test for subdomain takeover (cloud questions / dangling CNAMEs). [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

#### Create `subdomains.txt` from earlier recon

```text
dev.<DOMAIN>
staging.<DOMAIN>
files.<DOMAIN>
...
```

#### Run Subzy

```bash
subzy run --targets subdomains.txt \
          --concurrency 20 \
          --hide_fails \
          --output recon/subzy-results.txt
```

#### Manual CNAME verification with Dig

```bash
dig CNAME <SUBDOMAIN> +short \
  > recon/dns-cname-<SUBDOMAIN>.txt
```

- Look for cloud providers (S3, GitHub Pages, Azure, etc.) that return “NoSuchBucket” or similar error pages in the browser.

**Pivot:**

- In a real engagement, you’d attempt to claim vulnerable resources; in the exam, fully document the takeover condition, including CNAME target and provider error messages.
