# 📝 Phase 1: Information Gathering – Study Notes

Theory, tool purpose, and "when to use" from the INE tutorials and OWASP WSTG 4.2 (INFO / CONF). Commands for the exam live in [📋 checklist-and-commands.md](<./📋 checklist-and-commands.md>). Variants live in [📜 cheatsheet.md](<./📜 cheatsheet.md>). This file explains *why* and *when*.

Placeholders: `<DOMAIN>`, `<IP>`, `<URL>`, `<NAMESERVER>`.

---

## Quick Decision Table

| Question during the exam | Tool | Type |
|---|---|---|
| Who owns it, which IP block? | `whois`, `host`, Netcraft site report | Passive |
| Which DNS records, zone transfer? | `dig`, `dnsrecon`, `dnsenum`, DNSdumpster | Active / passive |
| Which subdomains exist? | `dnsrecon`, SecLists DNS lists | Passive + active |
| Which files are published? | `robots.txt`, `sitemap.xml`, `curl` | Active |
| What is it built on? | `whatweb`, `nmap --script=banner`, `curl -I`, BuiltWith / Wappalyzer | Passive / active |
| Is there a WAF? | `wafw00f` | Active |
| What do the pages look like? | Burp Site Map | Active |
| What is exposed on the server? | `nikto`, `gobuster`, `ffuf`, `dirb` | Active |
| What did the site look like before? | Wayback Machine | Passive |

---

## 1. Methodology (WSTG)

- **WSTG** is the standard for what to test and why. The INFO section covers search engines, fingerprinting, metafiles, entry points, and execution paths. The CONF section covers configuration.
- **Use when:** before any hands-on work, skim the WSTG INFO items and make sure each one has a command in the checklist.
- **Reporting:** the same WSTG IDs are used in the report's findings table.

---

## 2. Ownership & IP Discovery

- **WHOIS** (passive): registrar, dates, name servers, org and allocation for an IP block. Use it to decide scope: related domains and IP ranges.
- **`host <DOMAIN>`**: forward lookup, like `nslookup` on Windows.
- **Netcraft site report:** hosting provider, IP addresses, name servers, and stack hints. Use it before active scanning to confirm the hosting provider and rough stack.

---

## 3. DNS

**Record types** (what each one tells you):

| Record | Meaning for recon |
|---|---|
| A / AAAA | Hostname → IPv4 / IPv6. Map each one to a web app. |
| NS | Name servers. Candidates for zone transfer. |
| MX | Mail hosts. Can share infrastructure with web apps. |
| CNAME | Alias. Dangling CNAMEs point to takeover candidates. |
| TXT | SPF, DMARC, verification tokens. Often leak third-party services. |
| SOA | Zone authority data. |
| SRV | Service locations, e.g. `_ldap._tcp.<DOMAIN>`. |
| PTR | IP → hostname (reverse DNS). |

- **Zone transfer (AXFR):** a misconfigured name server returns the full zone. Try it once per name server. If refused, move on. Reverse zones are transferred by their `in-addr.arpa` name, not by a single IP.
- **Tools:** `dnsrecon` (with `-t axfr` for transfer), `dnsenum`, DNSdumpster (web UI with graph).
- **Use when:** every in-scope domain gets at least one DNS enumerator. Check AXFR whenever a name server is listed.

---

## 4. Subdomains

- **SecLists** `Discovery/DNS/` provides the wordlists. Feed the results into vhost fuzzing and `/etc/hosts`.
- **Use when:** a domain has many possible hosts. Results feed directly into the checklist's VHost step.

---

## 5. Metafiles

- `robots.txt`, `sitemap.xml`, `.well-known/security.txt`, `crossdomain.xml`, `humans.txt`.
- Disallowed paths are often the most interesting. Each path goes into Burp scope and the directory brute force list.
- **Use when:** always, early. It costs one request per file.

---

## 6. OSINT & Search Engine Discovery

- **Google dorks:** `site:`, `inurl:`, `intitle:`, `filetype:`, `intitle:"index of"`, `cache:`. Targeted dorks find admin pages, backups, and config leaks.
- **Wayback Machine:** shows older versions of the site. Old endpoints and removed features are often still live.
- **GHDB** (Google Hacking Database): ready-made dorks for common leaks.
- **Use when:** the exam mentions OSINT or external discovery. Run a few targeted dorks and record any hits.

---

## 7. Fingerprinting

- **Browser add-ons** (BuiltWith, Wappalyzer): fast passive hints at server, framework, or CMS.
- **WhatWeb:** CLI stack detection. Run it once per host or VHost.
- **Nmap banners:** `--script=banner` for service versions. `http-enum` and `http-methods` for the web layer.
- **Metasploit auxiliary modules:** `http_version`, `http_header`, `robots_txt`, `brute_dirs`. Use them only when Metasploit is available.
- **curl:** raw headers and HTML without a browser. `curl -I` shows the server header, `curl -i` shows error pages.
- **wafw00f:** identifies a WAF. Run it when payloads start getting blocked, so you can adjust fuzzing speed and payloads.

---

## 8. Crawling & Visual Recon

- **Burp Suite:** Intercept **off**, browse the whole app manually with Burp capturing. The **Target → Site map** and **Proxy → HTTP history** are the base for entry-point mapping. This is mandatory, not optional.
- **OWASP ZAP:** same idea with its spider (Standard mode, recurse on). Use it when Burp isn't available or ZAP is named.
- **wget:** downloads a file for offline grep.

---

## 9. Vulnerability Scanning & Content Discovery

- **Nikto:** finds known vulnerabilities, misconfigurations, and dangerous files. Treat the output as leads and verify each one by hand.
- **Gobuster dir:** when a folder returns 200, run the search inside it too. Use `-b 403,404` to hide noise and `-r` to follow redirects.
- **ffuf:** more flexible than gobuster (fuzzing any position, header and parameter fuzzing, filters). Prefer it when you need more than a path list.
- **dirb:** older, but its wordlists still work. Use it as a fallback.
- **Use when:** after the main apps are identified. Run directory discovery on the root and on every 200, 301, 302, and 403 endpoint.

---

## 10. Lab Patterns (INE)

These repeat across the labs. The exam will be similar.

- **Port and service scan → Burp crawl → directory fuzzing → vulnerability scan.** This is the core flow.
- **DNS lab questions** map to these queries. This mapping is mine, derived from the question types, not taken from the INE solutions. Verify it on a lab before relying on it:
  - Count A records: `dig <DOMAIN> A +short`.
  - Find an LDAP host: `dig _ldap._tcp.<DOMAIN> SRV +short`.
  - Find a TXT flag: `dig <DOMAIN> TXT +short`.
  - Find a host with only a PTR record: `dig -x <IP> +short`.
  - Count reverse-zone records: transfer the reverse zone with `dig axfr <REVERSE_ZONE>.in-addr.arpa @<NAMESERVER>`, then count the records.

---

## 11. Scenario → Commands

| Scenario | Start with | Then |
|---|---|---|
| New exam IP, nothing known | Port scan, banner check, WhatWeb | Burp crawl, metafiles |
| Domain with unknown hosts | `dnsrecon`, SecLists DNS lists | VHost fuzzing |
| Web app found | Metafiles, Burp Site Map, WhatWeb | `gobuster` / `ffuf`, `nikto` |
| Payloads get blocked | `wafw00f` | Lower the fuzzing rate and vary payloads |
| TLS on 443 | `openssl s_client` | Check SANs for new hosts |
| Mentions WordPress or Drupal | `wpscan` | Check author enumeration and REST endpoints |

Exact commands for each row are in the checklist, with variants in the cheatsheet.
