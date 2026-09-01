# OWASP WSTG v4.2 Assessment Checklist
## Vault 01: Information Gathering & Proxies (`01-Info-Gathering-and-Proxies`)

**Target Scope:** `https://target.example.com`  
**Assessor:** PenTester / Security Engineer  
**Start Date:** YYYY-MM-DD  
**Status Legend:** `[ ] Pending` | `[x] Completed` | `[-] N/A` | `[!] Flagged / Finding Found`

---

### Executive Summary / Progress Tracker
- **Total Tasks:** 13
- **Completed:** 0 / 13
- **Pending:** 13 / 13
- **Findings Identified:** 0

---

## 📋 Comprehensive Assessment Checklist

| WSTG Key | Test Name | Key Objectives | Recommended Tools | Status | Notes / Findings |
| :--- | :--- | :--- | :--- | :---: | :--- |
| **WSTG-INFO-01** | Conduct Search Engine Discovery Recon for Info Leakage | Gather sensitive info, indexed staging/admin portals, leaked docs, configuration files, and credentials using OSINT search dorks. | Google, Bing, DuckDuckGo, `ghdb`, `theHarvester`, Shodan | `[ ] Pending` | |
| **WSTG-INFO-02** | Fingerprint Web Server | Identify web server software, exact version numbers, operating system, and underlying service stack. | Burp Suite, Nmap, `whatweb`, Wappalyzer, `cURL -I` | `[ ] Pending` | |
| **WSTG-INFO-03** | Review Webserver Metafiles for Info Leakage | Analyze `robots.txt`, `sitemap.xml`, `.well-known/`, `security.txt`, and crawler directives for hidden paths/endpoints. | Burp Suite, `cURL`, Browser DevTools | `[ ] Pending` | |
| **WSTG-INFO-04** | Enumerate Applications on Webserver | Uncover non-standard virtual hosts, co-hosted applications, IP-aliased sites, and secondary domains. | `gobuster vhost`, `ffuf`, Nmap, Reverse IP Lookup | `[ ] Pending` | |
| **WSTG-INFO-05** | Review Webpage Content for Info Leakage | Inspect HTML source code, client-side JS files, inline comments, internal IP addresses, API keys, and dev credentials. | Burp Match & Replace, `JSFinder`, `SecretFinder`, DevTools | `[ ] Pending` | |
| **WSTG-INFO-06** | Identify Application Entry Points | Map all HTTP requests/responses, parameters, headers, POST bodies, REST/GraphQL endpoints, and upload forms. | Burp Suite Proxy, OWASP ZAP, `arfind`, ParamSpider | `[ ] Pending` | |
| **WSTG-INFO-07** | Map Execution Paths Through Application | Trace request flows, user workflows (registration, checkout, password reset), and multi-step business state transitions. | Burp Target Site Map, Mermaid diagrams, OWASP ZAP | `[ ] Pending` | |
| **WSTG-INFO-10** | Map Application Architecture | Determine reverse proxies, load balancers, WAFs, application servers, database backends, and cloud infrastructure. | `wafw00f`, Nmap traceroute, CDN finder, Burp Suite | `[ ] Pending` | |
| **WSTG-CONF-01** | Test Network Infrastructure Configuration | Check for open management ports, insecure SSL/TLS configurations, outdated services, and DNS zone transfer issues. | Nmap, Masscan, SSL Labs, `dig axfr`, `testssl.sh` | `[ ] Pending` | |
| **WSTG-CONF-02** | Test Application Platform Configuration | Identify default framework installation files, exposed admin consoles, debug flags enabled, and sample applications. | Burp Suite, `nikto`, `gobuster dir`, `ffuf` | `[ ] Pending` | |
| **WSTG-CONF-05** | Enumerate Infrastructure & App Admin Interfaces | Discover unlinked management panels (e.g., `/admin`, `/dashboard`, `/phpmyadmin`, `/grafana`, `/jenkins`). | `gobuster dir`, `ffuf`, Dirsearch, SecLists | `[ ] Pending` | |
| **WSTG-CONF-06** | Test HTTP Methods | Determine enabled HTTP methods (`TRACE`, `TRACK`, `PUT`, `DELETE`, `OPTIONS`) and test for dangerous verb behavior. | Burp Repeater, `cURL -X OPTIONS`, Nmap `http-methods` | `[ ] Pending` | |
| **WSTG-CONF-10** | Test for Subdomain Takeover | Verify CNAME records pointing to unclaimed third-party services (S3 buckets, GitHub Pages, Heroku, Azure, Zendesk). | `subzy`, `subfinder`, `can-i-take-over-xyz`, `dig` | `[ ] Pending` | |

---

## 🛠️ Step-by-Step Testing Procedure Template

For each task in this vault, follow this standard procedure:

### Example: WSTG-INFO-01 (Search Engine Reconnaissance)
1. **Dorking Executions:**
   - `site:target.com filetype:pdf OR filetype:docx OR filetype:xlsx`
   - `site:target.com inurl:admin OR inurl:login OR inurl:staging`
   - `site:target.com ext:log OR ext:env OR ext:bak OR ext:conf`
2. **Shodan / OSINT Checks:**
   - Query IP addresses and SSL certificates for host identification.
3. **Evidence Logging:**
   - Save HTTP response screenshots and URL lists under `./evidence/WSTG-INFO-01/`.

---

## 📌 Finding Log Summary

| Finding ID | Related WSTG Key | Severity | Short Description | Remediation Status |
| :---: | :---: | :---: | :--- | :---: |
| `FIND-01` | *e.g., WSTG-CONF-05* | High | Exposed Unauthenticated Admin Interface at `/admin/db` | Open |
| `FIND-02` | *e.g., WSTG-INFO-05* | Medium | API Key exposed in public JavaScript file `main.chunk.js` | Open |
