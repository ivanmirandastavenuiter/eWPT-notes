### Phase 1: Information Gathering & Proxies (Exam-Optimized)

**Target Scope:** `[Insert Target URL/IP]`

**Assessor:** `[Your Name]`

**Start Date:** `[YYYY-MM-DD]`

---

## 🔴 MANDATORY: ASYNCHRONOUS (Fire & Forget)

*Launch these the second you receive your exam IPs. Let them run in the background while you read the exam questions and set up your proxy.*

### WSTG-CONF-01: Test Network Infrastructure Configuration

* [ ] **Perform Full Port Scan:** Execute `nmap -sC -sV -p- --min-rate 1000 <TARGET_IP>`.
* [ ] **Audit TLS/SSL:** Run `testssl.sh https://<TARGET_IP>` and inspect certificates for Subject Alternative Names (SANs) revealing extra domains.
* [ ] **Attempt Zone Transfer:** Run `dig axfr @<TARGET_IP> <DOMAIN>` to check for exposed DNS zone records.

### WSTG-INFO-04: Enumerate Applications (Virtual Hosts)

* [ ] **Fuzz Virtual Hosts:** Run `ffuf -u http://<TARGET_IP> -H "Host: FUZZ.<DOMAIN>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs <DEFAULT_RESPONSE_SIZE>`.
* [ ] **Scan Non-Standard Ports:** Execute `nmap -p 80,443,8000,8080,8443,8888 -sV <TARGET_IP>` to uncover web applications running on alternate ports.
* [ ] **Map Discovered VHosts:** Add any identified subdomains to your local `/etc/hosts` file.

### WSTG-CONF-05: Enumerate Admin Interfaces

* [ ] **Brute-Force Directories:** Run `ffuf -u http://<TARGET>/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403`.
* [ ] **Target Admin Keywords:** Specifically test `/admin`, `/manage`, `/dashboard`, `/phpmyadmin`, `/grafana`, and `/jenkins`.
* [ ] **Log Access Denials:** Record all `403 Forbidden` responses for verb tampering and header bypass attempts during Phase 4 (Authorization).

### WSTG-CONF-02: Test Application Platform Configuration

* [ ] **Fuzz for Backups:** Run `ffuf` to test for backup extensions (`.bak`, `.old`, `.swp`, `.tmp`, `~`) on known files.
* [ ] **Check Source/Env Leaks:** Request `/.git/HEAD`, `/.svn/entries`, `/.env`, and `/.DS_Store`.
* [ ] **Probe Default/Debug Endpoints:** Request common paths like `/_profiler`, `/phpinfo.php`, `/actuator/env`, `/server-status`, and `/console`.

### WSTG-INFO-02: Fingerprint Web Server (Automated portion)

* [ ] **Run Automated Detection:** Execute `whatweb http://<TARGET>` to fingerprint the technology stack.

---

## 🟡 MANDATORY: ACTIVE / PASSIVE MANUAL RECON

*Perform these tasks while your automated tools are running. This builds your proxy history for the rest of the exam.*

### WSTG-INFO-06: Identify Application Entry Points

* [ ] **Perform Manual Proxy Crawl:** Walk through the application with Burp Proxy enabled, clicking every link, button, and submitting every form.
* [ ] **Audit Site Map Parameters:** Review `Burp -> Target -> Site Map`. List all GET parameters (`?id=`, `?file=`, `?page=`), POST bodies, and custom HTTP headers.
* [ ] **Identify API Endpoints:** Note all REST and GraphQL endpoints triggered by client-side actions.

### WSTG-INFO-07: Map Execution Paths

* [ ] **Document Core Workflows:** Map the exact step-by-step logic for Registration, Login, Profile Edit, Checkout, and Password Reset.
* [ ] **Track State & Tokens:** Analyze Burp HTTP History to identify how session identifiers and authorization headers transition between workflow steps.
* [ ] **Flag for Logic Testing:** Mark multi-step processes for later business logic testing (e.g., skipping straight to `/checkout/success`).

### WSTG-INFO-05: Review Webpage Content & Source Code

* [ ] **Mine HTML Comments:** Open page source and regex-search for developer notes (`<!--`, `/*`, `//`).
* [ ] **Extract JavaScript Bundles:** Analyze `.js` files for internal IP ranges (`10.x.x.x`), unlinked API routes (`/api/v1/`), and hardcoded tokens (`api_key`, `secret`, `jwt`).
* [ ] **Inspect Hidden DOM Elements:** Search the DOM for hidden form fields (`<input type="hidden">`) that dictate application logic or pricing.

### WSTG-INFO-03: Review Webserver Metafiles

* [ ] **Request Standard Metafiles:** Pull `/robots.txt`, `/sitemap.xml`, `/.well-known/security.txt`, `/crossdomain.xml`, and `/humans.txt`.
* [ ] **Extract Restricted Paths:** Parse every `Disallow:` entry from `robots.txt`.
* [ ] **Update Scope:** Add all discovered hidden paths directly into your Burp Target Scope for high-priority inspection.

### WSTG-INFO-02: Fingerprint Web Server (Manual portion)

* [ ] **Inspect HTTP Headers:** Run `curl -I -s http://<TARGET>` and document `Server`, `X-Powered-By`, `X-AspNet-Version`, and `X-Frame-Options`.
* [ ] **Trigger Verbose Errors:** Send malformed requests (e.g., `GET /nonexistent_test_page_123 HTTP/1.1`) to force a 404/500 error and expose server version strings.

---

## ⚪ EXTRA / SITUATIONAL (Question-Driven)

*Only execute these if explicitly hinted at by an exam question, or if you hit a roadblock (like a WAF blocking your payloads or a 403 Forbidden page).*

### WSTG-CONF-06: Test HTTP Methods (Trigger: 403 Forbidden pages)

* [ ] **Probe OPTIONS:** Send `OPTIONS / HTTP/1.1` in Burp Repeater and inspect the `Allow:` header.
* [ ] **Verify Dangerous Verbs:** Attempt to use `PUT`, `DELETE`, and `TRACE` against static files or upload endpoints.
* [ ] **Test Verb Tampering:** Change HTTP methods on restricted endpoints (e.g., swapping `GET /admin` to `POST /admin` or `HEAD /admin`) to bypass basic access controls.

### WSTG-INFO-10: Map Application Architecture (Trigger: Blocked payloads)

* [ ] **Detect WAF:** Run `wafw00f http://<TARGET>`.
* [ ] **Analyze Proxy Headers:** Inspect HTTP responses for infrastructure headers like `Via`, `X-Cache`, `CF-Ray`, and `X-Forwarded-For`.
* [ ] **Probe WAF Behavior:** Send test payloads (`' OR 1=1`, `<script>`) to determine if requests are dropped by a WAF or handled by the backend application.

### WSTG-INFO-01: Conduct Search Engine Discovery Recon (Trigger: OSINT explicit questions)

* [ ] **Execute Google Dorks:** Search for exposed files and portals (`site:target.com ext:xml OR ext:conf OR ext:bak`, `site:target.com inurl:admin OR inurl:staging`).
* [ ] **Check OSINT / Shodan:** Query target IP addresses and SSL certificates for host identification and exposed secondary services.
* [ ] **Scan Code Repositories:** Search GitHub/GitLab for leaked repositories, API keys, or hardcoded credentials associated with the target domain.
* [ ] **Log Evidence:** Save HTTP response screenshots and URL lists.

### WSTG-CONF-10: Test for Subdomain Takeover (Trigger: Cloud infrastructure questions)

* [ ] **Query CNAME Records:** Run `dig CNAME <SUBDOMAIN>` for all discovered targets.
* [ ] **Verify Dangling Pointers:** If a CNAME points to AWS S3, GitHub Pages, or Azure, access the URL and look for "NoSuchBucket" or "404 Not Found".
* [ ] **Run Automated Check:** Execute `subzy run --targets subdomains.txt` to identify vulnerable domain mappings.