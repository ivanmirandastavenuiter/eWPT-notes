# Phase 1 – WSTG Recon: Checklist + Commands

**Tags:** `ASYNC` start at once, read later · `MANUAL` Burp/ZAP/browser while scans run · `EXTRA` only when a question or a blocker points to it. Every block keeps its WSTG ID.

**Layout:** [Run order](#run-order-one-target-at-a-time) → [Main Commands](#main-commands) (tool-driven, run on every web host) → [Context-Dependent & Extra Commands](#context-dependent--extra-commands) (each has a *When* line). Main blocks end with **If it fails**, which points to a section of [📜 cheatsheet.md](<./📜 cheatsheet.md>).

**Exam reality:** Kali has no internet. Tools run against internal hosts only. Anything that needs the internet is in Appendix B (host PC only).

***

## Run order (one target at a time)

1. `mkdir -p recon`, then the tool and wordlist check below.
2. **Full nmap** (`ASYNC`). Build `<WEB_PORTS>` from it.
3. While nmap runs: open the root in the Burp browser (`MANUAL`) and read the page.
4. **whatweb + headers** on each web port (5 seconds each). Choose `<EXT>`. Run searchsploit on what you identify.
5. **Directory/file scan** and **backup scan** (`ASYNC`, at most 2 fuzzers at once).
6. If the exam gives a `<DOMAIN>`: **vhost fuzzing**. If nmap shows port 53 open: **dnsenum**.
7. Spider with ZAP if a question asks for counts. Probe web-service paths. Work the context blocks as triggers appear.
8. **nikto last, alone.** Then one completeness pass.
9. Copy `recon/` and your notes to the host PC. A Kali reset wipes them.

```bash
command -v nmap ffuf feroxbuster wfuzz gobuster nikto whatweb dnsenum dnsrecon wpscan joomscan searchsploit zaproxy
ls -d /usr/share/seclists /usr/share/wordlists/dirb /usr/share/wordlists/dirbuster 2>&1
```

Missing tool or wordlist: use the substitute from cheatsheet → *Wordlist fallbacks* and the matching fuzzer section. Do not install anything.

***

## Conventions

| Placeholder | Meaning |
|---|---|
| `<IP>` | Exam IP |
| `<DOMAIN>` | Domain from the exam letter or questions. No domain means skip vhost fuzzing and DNS |
| `<VHOST>` | Host to request (`app.target.com`, or `<IP>` if none) |
| `<SCHEME>` / `<PORT>` | `http`/`https` and port. A service shown as `https` or `ssl/http` by nmap is `https` |
| `<WEB_PORTS>` | Comma list of open HTTP(S) ports, built from the full scan (see Run order step 2) |
| `<HTTPS_PORTS>` | Subset of `<WEB_PORTS>` that speaks TLS (`ssl/http` or `https` in nmap) |
| `<EXT>` | `-e` value for the stack: `.php,.txt` (PHP), `.aspx,.txt` (ASP.NET), `.jsp,.txt` (Java) |
| `<BASELINE>` | Size of a non-existent page. Only needed when `-ac` misbehaves |
| `<COOKIE>` / `<PROXY>` | `PHPSESSID=...` / `127.0.0.1:8080` |
| `<NAMESERVER>` | Name server to query. In the exam this is usually `<IP>` itself |
| `<PAGE>` / `<PATH>` / `<NAME>` | Page (`login.php`), path (`/api/user`), page name without extension (`login`) |
| `<PRODUCT>` / `<VERSION>` | Software and version from whatweb or headers (`apache`, `2.4.49`) |
| `<JS_URL>` | Full URL of a `.js` file found in the page |
| `<METHOD>` / `<BODY>` | HTTP verb and request body (Appendix A) |
| `<SUBDOMAIN>` | Subdomain from DNS or vhost results |
| `<SUBNET>` | CIDR range from the scope, only when a subnet is in scope (cheatsheet) |

- **Calibration:** every ffuf command uses `-ac` (auto-calibrate), so no baseline is needed. If `-ac` hides real hits or lets noise through, measure a baseline and swap `-ac` for `-fs <BASELINE>`:
  ```bash
  curl -sk -o /dev/null -w "%{size_download}\n" "<SCHEME>://<VHOST>/nohost-zz9"
  ```
- **Start at the root** of each web host. A path-specific result can differ from the root, so go deeper only when the root gives you something.
- **Authenticated re-scan:** whenever you get a working session or credentials, re-run the directory scan and API probe with the cookie (context block M). Most of the surface hides behind the login.
- **Save to file flag:** `[x]` means the command writes to `recon/`; `[ ]` means read it in the terminal only. Every ffuf command writes `-of all`: six files per run (`.json`, `.ejson`, `.csv`, `.ecsv`, `.html`, `.md`). Read the `.csv`.
- **Naming:** `recon/<tool>-<context>-<target>`, e.g. `recon/nmap-full-172.20.0.2.txt`, `recon/ffuf-dirs-app.target.com.csv`.
- **Read ffuf output with awk, not grep.** CSV columns: `1 FUZZ, 2 url, 3 redirect, 4 position, 5 status, 6 size`. `grep ",200,"` also matches size or position values, so use field 5:
  ```bash
  awk -F, 'NR>1 && $5==200 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv           # one status
  awk -F, 'NR>1 && $5~/^(200|301|302)$/ {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv  # several
  awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv | sort -n             # everything, by status
  ```
  Open the `.html` file instead if you prefer a sortable table.
- **Read other output with grep:** `grep -E "open" recon/nmap-full-<IP>.txt`, `grep "^+" recon/nikto-<VHOST>.txt`.
- **Threads and concurrency:** `ASYNC` jobs run in parallel to save time, with limits that stop the Kali VM from freezing.
  - Fuzzers (ffuf, feroxbuster, wfuzz, gobuster): `-t 10`. feroxbuster defaults to 50 threads, so always set `-t`.
  - At most 2 fuzzers at once. The full nmap counts as one job.
  - nikto and `wpscan --plugins-detection aggressive` run alone.
  - If the VM lags, check `htop` and stop the newest job.
- **Step format:** heading with tags, one-line description, command, **Read** quote, table (save flag, next action). Main blocks add **If it fails**. Context blocks add a *When* line.

***

## Main Commands

### A. Network & port discovery

#### Full port scan · `WSTG-CONF-01` · `ASYNC`

Most important async job. It covers non-standard web ports, and `-sC` already runs `ftp-anon` and similar default scripts.

```bash
nmap -Pn -n -sC -sV -p- --min-rate 1000 <IP> -oN recon/nmap-full-<IP>.txt
```

> **Read:** `grep -E "open" recon/nmap-full-<IP>.txt`. Build `<WEB_PORTS>` with:
> `grep -E "^[0-9]+/tcp +open +(ssl/)?http" recon/nmap-full-<IP>.txt | cut -d/ -f1 | paste -sd,`
> Every web port is a separate host to test. `53` open means DNS tests apply (block B).

| Save to file | Next |
|:---:|---|
| `[x]` | HTTP scripts on `<WEB_PORTS>`, then whatweb on each web port. |

**If it fails →** cheatsheet: *Nmap*.

#### HTTP scripts on the open web ports · `WSTG-CONF-01` · `ASYNC`

Run after the full scan, using its ports.

```bash
nmap -Pn -n -sV -p <WEB_PORTS> --script http-enum,http-title,http-methods,http-robots.txt <IP> -oN recon/nmap-http-<IP>.txt
```

> **Read:** `grep "|" recon/nmap-http-<IP>.txt`. `http-methods` lists allowed verbs (CONF-06). `http-enum` lists directories and files (CONF-05). `http-robots.txt` lists Disallow paths (INFO-03), so you can skip the metafile curl loop for robots.

| Save to file | Next |
|:---:|---|
| `[x]` | Add every found path to Burp scope and test it. |

**If it fails →** cheatsheet: *Nmap*.

### B. Subdomain & DNS enumeration

Needs a `<DOMAIN>`. Without one, skip this block.

#### VHost fuzzing · `WSTG-INFO-04` · `ASYNC`

Works without a DNS server: it only needs the web server on `<IP>`. This is the primary subdomain tool.

```bash
ffuf -u "<SCHEME>://<IP>/" -H "Host: FUZZ.<DOMAIN>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -ac -t 10 -o recon/ffuf-vhosts-<DOMAIN> -of all
```

> **Read:** `awk -F, 'NR>1 {print $1,$5,$6}' recon/ffuf-vhosts-<DOMAIN>.csv`. Each row is a hostname (`$1`) whose response differs from the default site.

| Save to file | Next |
|:---:|---|
| `[x]` | Add each hit to `/etc/hosts` on the same line as the target and to Burp scope, then run the root checks on it. |

**If it fails →** cheatsheet: *ffuf* (`-fs`), *wfuzz* (vhost), *gobuster* (vhost), *Wordlist fallbacks*.

#### DNS brute force · `WSTG-INFO-04` · `ASYNC`

*Only if nmap shows port 53 open on `<IP>`.* Finds names with DNS records and tries a zone transfer on its own, so no separate AXFR step is needed.

```bash
dnsenum --dnsserver <IP> --noreverse -f /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -o recon/dnsenum-<DOMAIN>.xml <DOMAIN>
```

> **Read:** `grep -oE "[a-z0-9.-]+\.<DOMAIN>" recon/dnsenum-<DOMAIN>.xml | sort -u` lists each unique name. A zone transfer shows as many records at once.

| Save to file | Next |
|:---:|---|
| `[x]` | Each new name goes to `/etc/hosts` and the root checks, the same as vhost hits. |

**If it fails →** cheatsheet: *DNS* (`dnsrecon`, `dig axfr`, gobuster dns).

### C. Directory, file & backup brute force

#### Directory and file brute force · `WSTG-CONF-05` · `ASYNC`

On each web host, after whatweb gives `<EXT>`. This is the main content scan: `-e` adds the stack's extension to every word, and `-mc all -fc 404` keeps `401`, `403`, `405`, and `500` as leads.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e <EXT> -mc all -fc 404 -ac -t 10 -o recon/ffuf-dirs-<VHOST> -of all
```

> **Read:** `awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv | sort -n`. `200`/`301`/`302` are pages to open in Burp. `401` is basic auth. `403` goes to CONF-06. `405` and `500` are leads, often an API path or an error to read.

| Save to file | Next |
|:---:|---|
| `[x]` | Add each hit to the Burp Site map. A new directory repeats the scan on it. The admin-keyword curl loop in block H is redundant once this finishes. |

**If it fails →** cheatsheet: *ffuf*, *feroxbuster*, *wfuzz*, *gobuster*, *Wordlist fallbacks*.

#### Backup and temp files · `WSTG-CONF-04` · `ASYNC`

On the root. For a known file (`index.php`), use the `index.phpFUZZ` variant in the cheatsheet.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -e .bak,.old,.swp,.tmp,~,.zip,.tar.gz,.sql,.orig,.save -mc 200 -ac -t 10 -o recon/ffuf-backups-<VHOST> -of all
```

> **Read:** `awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-backups-<VHOST>.csv`. Each row is a file that exists. Archives and `.sql` files are the high-value ones.

| Save to file | Next |
|:---:|---|
| `[x]` | Download each hit and read it before anything else. |

**If it fails →** cheatsheet: *ffuf*, *feroxbuster* (backups), *Wordlist fallbacks*.

### D. Stack fingerprinting & known exploits

#### Tech stack · `WSTG-INFO-02` · `ASYNC`

Run first on each web port (about 5 seconds). CMS, frameworks, plugins, and the language that sets `<EXT>`.

```bash
whatweb -v "<SCHEME>://<VHOST>:<PORT>/" > recon/whatweb-<VHOST>-<PORT>.txt
```

> **Read:** Read the plugin names and versions in brackets, for example `Apache[2.4.x]`, `PHP[5.x]`. `PHP` gives `.php`, `ASP_NET` gives `.aspx`, `Tomcat` or `JSP` gives `.jsp`.

| Save to file | Next |
|:---:|---|
| `[x]` | Set `<EXT>`. A CMS goes to block N. A product and version go to searchsploit. |

**If it fails →** cheatsheet: *Fingerprinting*.

#### Known exploits for the detected version · `WSTG-INFO-02`

Run once per web product (web server, CMS, plugin, JS library, framework). The database is local, so it works offline.

```bash
searchsploit "<PRODUCT> <VERSION>" > recon/searchsploit-<PRODUCT>.txt
```

> **Read:** Each line is an exploit title and path. Match the title to the exact version. **Layer 7 only:** skip OS-level services (ssh, smtp, samba, kernel). eWPTv2 tests the web application, so those are out of scope.

| Save to file | Next |
|:---:|---|
| `[x]` | A version-matched exploit is a lead to verify in Burp, not a finding. |

**If it fails →** cheatsheet: *searchsploit*.

#### Quick vulnerability scan · `WSTG-INFO-02` · `ASYNC` · run last, alone

Completeness check once the other scans are done. Treat results as leads, not findings.

```bash
nikto -h "<SCHEME>://<VHOST>:<PORT>/" -o recon/nikto-<VHOST>-<PORT>.txt
```

> **Read:** `grep "^+" recon/nikto-<VHOST>-<PORT>.txt` shows the findings. Each one is a lead.

| Save to file | Next |
|:---:|---|
| `[x]` | Verify each lead in Burp before it goes in your notes. |

**If it fails →** cheatsheet: *Nikto*.

### E. Application mapping & web services

#### Walk the app in Burp · `WSTG-INFO-06` · `MANUAL`

Start this while nmap runs. Proxy on. Build the list from Target → Site map. Read the page source (Ctrl+U) and look for comments, hidden fields, and script paths yourself; this beats a regex.

> **Read:** Sort the Site map by URL. Note each GET parameter, POST body, custom header, and API path. Note every comment you spot, and every `.js` file to open.

| Save to file | Next |
|:---:|---|
| `[ ]` | Parameters go to the vuln-testing phases. Each `.js` file goes to the JS-secrets block (J). |

**If it fails →** the ZAP spider below.

#### Spider the app in ZAP · `WSTG-INFO-06` · `MANUAL`

For "how many pages, forms, or parameters" questions, or an app too big to walk by hand. Burp Community has no crawler. ⚠️ Confirm ZAP is installed (`command -v zaproxy`).

```bash
zaproxy -port 8081 &
```

> **Read:** Port `8081` avoids clashing with Burp on `8080`. In ZAP, log in once with Manual Explore, then right-click the site in the Sites tree → Attack → Spider. The Sites tree lists every URL. The Params tab lists every GET/POST parameter. Passive Alerts are leads. **Do not run Active Scan:** it is heavy and freezes the VM.

| Save to file | Next |
|:---:|---|
| `[ ]` | Copy the URL and parameter counts into your notes. New URLs go into Burp scope. |

**If it fails →** walk the app by hand in Burp.

#### Web-service and API paths · `WSTG-INFO-06`

Run on every web host. Web services are a large share of the exam. A page that you know serves SOAP can also be probed directly with `<PATH>?wsdl`.

```bash
for p in "?wsdl" service?wsdl swagger.json swagger/index.html openapi.json v2/api-docs v3/api-docs api-docs graphql services api; do curl -sk -o /dev/null -w "%{http_code} %{size_download} $p\n" "<SCHEME>://<VHOST>:<PORT>/$p"; done
```

> **Read:** `200` on a WSDL, Swagger, or OpenAPI path is a full endpoint list. `401`, `405`, and `415` mean the endpoint exists and wants other credentials, a different verb, or a different content type. `400` from `graphql` means GraphQL is there.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each live path in Burp Repeater. Endpoints go to the web service tests. |

**If it fails →** cheatsheet: *Web services*.

***

## Context-Dependent & Extra Commands

Run these only when a finding, blocker, or question points here.

### F. Extra hosts & services

#### DNS zone transfer (AXFR) · `WSTG-CONF-01`

*When:* nmap shows port 53 open and `dnsenum` is missing or you want a quick manual check.

```bash
dig axfr <DOMAIN> @<NAMESERVER> > recon/dns-axfr-<DOMAIN>.txt
grep -c "IN" recon/dns-axfr-<DOMAIN>.txt
```

> **Read:** The count is the record total. `Transfer failed.` in the file means it was refused.

| Save to file | Next |
|:---:|---|
| `[x]` | Each hostname goes to `/etc/hosts` and the root checks. |

#### TLS certificate SANs · `WSTG-CONF-01`

*When:* a host answers on HTTPS. It can surface hostnames that vhost fuzzing misses.

```bash
echo | openssl s_client -connect <IP>:<PORT> -servername <DOMAIN> 2>/dev/null | openssl x509 -noout -ext subjectAltName
```

> **Read:** Each `DNS:` entry is a hostname. Keep it as a `<SUBDOMAIN>` candidate.

| Save to file | Next |
|:---:|---|
| `[ ]` | Add each name to `/etc/hosts` and Burp scope, then run the root checks on it. |

#### TLS weaknesses · `WSTG-CRYP-01`

*When:* a host answers on HTTPS, or a question asks about TLS, ciphers, or certificates.

```bash
nmap -Pn -n -sV -p <HTTPS_PORTS> --script ssl-enum-ciphers,ssl-cert,ssl-heartbleed <IP> -oN recon/nmap-tls-<IP>.txt
```

> **Read:** `grep -E "SSLv|TLSv1\.0|TLSv1\.1|least strength|VULNERABLE|RC4|3DES|Not valid after" recon/nmap-tls-<IP>.txt`. SSLv3, TLS 1.0 or 1.1 enabled, `least strength` of C or worse, RC4 or 3DES, or an expired cert are findings.

| Save to file | Next |
|:---:|---|
| `[x]` | Record the port and the weak protocol or cipher. |

#### Non-web services that expose web content

*When:* nmap lists FTP, rsync, NFS, or a database port. This only matters when it leaks source code, config files, or credentials for the web app. Ignore other network services (layer 7 scope).

```bash
grep -A2 "ftp-anon" recon/nmap-full-<IP>.txt
curl -s --user anonymous:anonymous "ftp://<IP>/"
```

> **Read:** An anonymous listing that contains web files (`index.php`, `wp-config.php`, `.sql`) means the web root or its backups are reachable.

| Save to file | Next |
|:---:|---|
| `[ ]` | Download the file, read the config for credentials, and try them on the web login. |

### G. Platform & config leaks

#### Source control and env leaks · `WSTG-CONF-02`

*When:* once per web root. Directory wordlists skip dotfiles, so this finds what the ffuf scan won't.

```bash
for p in .git/HEAD .svn/entries .env .DS_Store; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** Only `200` lines matter. `403` means the file exists but is blocked.

| Save to file | Next |
|:---:|---|
| `[ ]` | `.git/HEAD` at `200`: dump the repo with `wget -r` and read its config. `.env` at `200`: read it for credentials. |

#### Debug and default endpoints · `WSTG-CONF-02`

*When:* whatweb or headers point to a framework that ships these paths (Spring, Symfony, PHP), or a question mentions debug exposure.

```bash
for p in _profiler phpinfo.php actuator/env server-status console; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** `200` means the endpoint is live. `403` means present but blocked, so send it to CONF-06.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each live endpoint in Burp. |

#### Alternate extensions on a known page · `WSTG-CONF-03`

*When:* you hold one specific page and want to see if the server also exposes its source or backup. This is the single-file version of the backup scan.

```bash
for e in php php7 phtml inc bak old; do curl -sk -o /dev/null -w "%{http_code} %{size_download} <NAME>.$e\n" "<SCHEME>://<VHOST>/<NAME>.$e"; done
```

> **Read:** Compare each line with the `php` line. A `200` on `php7`, `phtml`, `inc`, or `bak` with source in the body means that extension is served as plain text.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each `200` in Burp and read the body. Source code in the response is a finding. |

#### Directory listing · `WSTG-CONF-04`

*When:* the directory scan has returned `200` or `301` hits.

```bash
awk -F, 'NR>1 && $5~/^(200|301)$/ {print $2}' recon/ffuf-dirs-<VHOST>.csv | while read u; do curl -sk "${u%/}/" | grep -qi "<title>Index of" && echo "LISTING ${u%/}/"; done
```

> **Read:** Each `LISTING` line is a directory with indexing enabled. Browse it for backups, config, and uploads.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each listing in Burp and read the files in it. |

### H. Admin paths, verbs & forbidden paths

#### Admin keywords · `WSTG-CONF-05`

*When:* only if the directory scan has not finished and you want an instant read. **Skip it once the scan runs**, since `raft-medium-words.txt` already contains these words.

```bash
for p in admin manage dashboard phpmyadmin grafana jenkins; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p/"; done
```

> **Read:** `200`, `301`, `302`, `401`, and `403` are leads. `404` means nothing is there.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each lead in Burp. A login page goes to the auth tests. |

#### Log every 403 · `WSTG-CONF-05`

*When:* the directory scan returned `403` rows and you want them queued for verb tampering.

```bash
awk -F, 'NR>1 && $5==403 {print $2}' recon/ffuf-dirs-<VHOST>.csv > recon/forbidden-<VHOST>.txt
```

> **Read:** Each line is a path to test in CONF-06.

| Save to file | Next |
|:---:|---|
| `[x]` | Run the verb tampering check below on each path. |

#### Allowed methods · `WSTG-CONF-06`

*When:* a path answered 403, a question asks about HTTP methods, or the nmap `http-methods` output looks odd.

```bash
curl -sk -i -X OPTIONS "<SCHEME>://<VHOST>:<PORT>/" | grep -i allow
```

> **Read:** The `Allow:` header lists the verbs the server accepts.

| Save to file | Next |
|:---:|---|
| `[ ]` | Verbs missing from `Allow:` but still working go to the verb tampering step. |

#### Verb tampering on a restricted path · `WSTG-CONF-06`

*When:* `Allow:` lists a verb beyond GET, HEAD, and POST, or a 403 path needs a bypass attempt.

```bash
for m in GET HEAD POST PUT DELETE TRACE; do curl -sk --max-time 10 -o /dev/null -w "$m %{http_code}\n" -X $m "<SCHEME>://<VHOST>:<PORT>/admin/"; done
```

> **Read:** Any code other than `403` is a lead. A `200` with a different verb is a bypass candidate.

| Save to file | Next |
|:---:|---|
| `[ ]` | A `200` opens in Burp Repeater with that verb, and the body is checked. |

### I. Headers, errors & metafiles

#### Headers · `WSTG-INFO-02`

*When:* once per vhost, right after whatweb. It uses GET, because some servers answer `HEAD` with `405` or fewer headers.

```bash
curl -sk -D - -o /dev/null "<SCHEME>://<VHOST>:<PORT>/" | grep -iE "^(server|x-powered-by|x-aspnet-version|strict-transport-security|content-security-policy|x-frame-options|x-content-type-options|set-cookie)"
```

> **Read:** `Server` and `X-Powered-By` with version numbers are findings. Missing security headers are informational. `Set-Cookie` without `HttpOnly`, `Secure`, or `SameSite` is a lead for session tests.

| Save to file | Next |
|:---:|---|
| `[ ]` | A version string goes to searchsploit. Cookie flags go to the auth and session tests. |

#### Verbose error · `WSTG-INFO-02`

*When:* a 404 or 500 page looks custom, or whatweb and headers showed no version.

```bash
curl -sk -i "<SCHEME>://<VHOST>:<PORT>/nohost-zz9.php" | grep -iE "apache|php|tomcat|nginx|version|exception"
```

> **Read:** A stack trace or version in the body is a finding. Read the full body in Burp.

| Save to file | Next |
|:---:|---|
| `[ ]` | Record the version. A stack trace goes to the input validation tests. |

#### Status of each metafile · `WSTG-INFO-03`

*When:* once per vhost. Skip `robots.txt` if the nmap `http-robots.txt` script already reported it.

```bash
for f in robots.txt sitemap.xml .well-known/security.txt crossdomain.xml clientaccesspolicy.xml humans.txt; do curl -sk -o /dev/null -w "%{http_code} $f\n" "<SCHEME>://<VHOST>/$f"; done
curl -sk "<SCHEME>://<VHOST>/robots.txt" | grep -i disallow
```

> **Read:** `200` means read the file. `404` means absent. The `Disallow:` lines are the paths to test.

| Save to file | Next |
|:---:|---|
| `[ ]` | Add every `Disallow:` path to Burp scope and test it like a discovered directory. |

### J. Page content

#### Comments, JS, and hidden fields on the root page · `WSTG-INFO-05`

*When:* a quick first pass while a scan runs. It does not replace reading the page source in the browser; a regex misses multi-line comments and minified JS.

```bash
curl -sk "<SCHEME>://<VHOST>/" | grep -Eio '<!--.*-->|src="[^"]+\.js"|type="hidden"[^>]*' | sort -u
```

> **Read:** Comments and hidden values can show internal paths or debug notes. Each `.js` path is a file to open.

| Save to file | Next |
|:---:|---|
| `[ ]` | Each JS URL goes to the next step. A hidden value is a parameter for INFO-06. |

#### Secrets and internal IPs in a JS file · `WSTG-INFO-05`

*When:* a `.js` file was found and is too large to read in Burp.

```bash
curl -sk "<JS_URL>" | grep -Eio '(api_key|secret|token|jwt)[^,;]{0,60}|10\.[0-9]+\.[0-9]+\.[0-9]+'
```

> **Read:** Each match shows a key name and its value. `10.x.x.x` addresses are internal hosts to note.

| Save to file | Next |
|:---:|---|
| `[ ]` | A real secret gets tested. An internal IP goes to the SSRF tests. |

### K. Parameter discovery

Parameters are usually visible in forms, links, and Burp. Fuzz names only when a page seems to accept input that you can't see.

#### GET parameter names · `WSTG-INFO-06` · `ASYNC`

*When:* a page behaves differently with unknown input, or you suspect hidden functionality.

```bash
ffuf -u "<SCHEME>://<VHOST>/<PAGE>?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc all -ac -t 5 -o recon/ffuf-get-params -of all
```

> **Read:** `awk -F, 'NR>1 {print $1,$5,$6}' recon/ffuf-get-params.csv`. With `-ac`, every row is a parameter that changes the response.

| Save to file | Next |
|:---:|---|
| `[x]` | Note it for SQLi and XSS tests. Fuzz its values below. |

#### POST parameter names · `WSTG-INFO-06` · `ASYNC`

*When:* as above, for a form-encoded POST.

```bash
ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "FUZZ=test" -H "Content-Type: application/x-www-form-urlencoded" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc all -ac -t 5 -o recon/ffuf-post-params -of all
```

> **Read:** Same as GET: each row is a body field that changes the response.

| Save to file | Next |
|:---:|---|
| `[x]` | Note it for SQLi, XSS, and logic tests. |

**If it fails →** cheatsheet: *Wordlist fallbacks* (parameter names), *wfuzz*.

#### Parameter values once a parameter is confirmed · `WSTG-INFO-06`

*When:* a numeric ID parameter is confirmed and you suspect IDOR.

```bash
seq 1 1000 > recon/ids.txt
ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "id=FUZZ" -H "Content-Type: application/x-www-form-urlencoded" -w recon/ids.txt -ac -t 5 -o recon/ffuf-id-values -of all
```

> **Read:** `awk -F, 'NR>1 && $5==200 {print $1,$6}' recon/ffuf-id-values.csv`. A `200` that differs from the calibrated baseline is another record.

| Save to file | Next |
|:---:|---|
| `[x]` | A record ID that exposes another user's data goes to the IDOR test. |

#### API endpoint brute force · `WSTG-INFO-06` · `ASYNC`

*When:* the web-service probe, Burp, JS, or robots.txt shows an `/api` path.

```bash
ffuf -u "<SCHEME>://<VHOST>/api/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -mc all -fc 404 -ac -t 10 -o recon/ffuf-api-<VHOST> -of all
```

> **Read:** `awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-api-<VHOST>.csv | sort -n`. `200` is an endpoint. `401` and `405` also mean it exists.

| Save to file | Next |
|:---:|---|
| `[x]` | Each endpoint goes to Burp Repeater and the web service tests. |

**If it fails →** cheatsheet: *Wordlist fallbacks*, *Web services*.

### L. Execution paths

#### Map the workflows · `WSTG-INFO-07` · `MANUAL`

*When:* once you have a login. Do it while other scans run.

Registration, login, profile edit, checkout, and password reset. Replay any request with the Appendix A template.

> **Read:** In Burp HTTP history, note where session tokens change between steps.

| Save to file | Next |
|:---:|---|
| `[ ]` | Multi-step flows go to the logic tests. |

### M. Authenticated re-scan

#### Directory scan with a session · `WSTG-CONF-05` · `ASYNC`

*When:* you hold a working session cookie or credentials. Repeat the API probe and parameter checks with the same header.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e <EXT> -H "Cookie: <COOKIE>" -mc all -fc 404 -ac -t 10 -o recon/ffuf-dirs-auth-<VHOST> -of all
comm -13 <(awk -F, 'NR>1{print $2}' recon/ffuf-dirs-<VHOST>.csv | sort) <(awk -F, 'NR>1{print $2}' recon/ffuf-dirs-auth-<VHOST>.csv | sort)
```

> **Read:** The `comm` line prints only URLs that exist after login and not before. Those are the new pages.

| Save to file | Next |
|:---:|---|
| `[x]` | Open each new URL in Burp. Admin and account pages are the usual targets. |

**If it fails →** cheatsheet: *Authenticated scans*.

### N. CMS fingerprint & wpscan

Kali has no internet, so wpscan runs **without** an API token and **without** a vulnerability database: it lists versions, plugins, themes, and users. Match versions with searchsploit. ⚠️ Confirm the flags on the exam image.

#### Check for WordPress markers · `WSTG-INFO-08`

*When:* whatweb or headers hint at WordPress without confirming it.

```bash
curl -sk "<SCHEME>://<VHOST>/" | grep -Eio 'wp-content|wp-includes|name="generator"[^>]*'
for p in wp-login.php wp-json/ xmlrpc.php readme.html; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** `wp-content` or `wp-includes` in the source means WordPress. A `200` on `wp-login.php`, `wp-json/`, or `xmlrpc.php` confirms it. The generator tag shows the version.

| Save to file | Next |
|:---:|---|
| `[ ]` | WordPress confirmed goes to the wpscan blocks. Another CMS goes to cheatsheet: *CMS*. |

#### WordPress version · `WSTG-INFO-08`

*When:* WordPress is confirmed and `readme.html` still exists.

```bash
curl -sk "<SCHEME>://<VHOST>/readme.html" | grep -i "version"
```

> **Read:** Hardened sites remove this file, so use the wpscan version instead.

| Save to file | Next |
|:---:|---|
| `[ ]` | The version goes to searchsploit. |

#### Full wpscan enumeration · `WSTG-INFO-09` · `ASYNC`

*When:* WordPress is confirmed.

```bash
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -e u,ap,at,cb,dbe -o recon/wpscan-<VHOST>.txt
```

> **Read:** `grep -E "\[\+\]|\[!\]" recon/wpscan-<VHOST>.txt`. `[+]` lists version, theme, plugins, and users. `[!]` is a warning. With no vulnerability data, `[!]` rarely names a CVE, so run searchsploit on each plugin and theme name and version.

| Save to file | Next |
|:---:|---|
| `[x]` | Each plugin and theme goes to searchsploit. Each user goes to the password test. |

**If it fails →** cheatsheet: *CMS* (wpscan variants).

#### Users only · `WSTG-INFO-09`

*When:* the full enumeration listed no users, or you want them on their own.

```bash
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -e u
curl -sk "<SCHEME>://<VHOST>/wp-json/wp/v2/users" | grep -Eo '"slug":"[^"]+"'
```

> **Read:** Each username from either output is a login candidate.

| Save to file | Next |
|:---:|---|
| `[ ]` | Usernames go to the password test. Lab scope only. |

#### Aggressive plugin detection · `WSTG-INFO-09`

*When:* the default scan found few or no plugins, yet the site clearly uses some. Heavy: run it alone.

```bash
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks --plugins-detection aggressive -e ap -o recon/wpscan-plugins-<VHOST>.txt
```

> **Read:** Read each `[+]` plugin line and its version.

| Save to file | Next |
|:---:|---|
| `[x]` | Each plugin and version goes to `searchsploit "<PLUGIN_NAME> <VERSION>"`. |

#### Password test · `WSTG-INFO-09` · lab scope only

*When:* a username is confirmed and brute force is in scope. Brute force is rarely the answer, so try it after the other leads.

```bash
gunzip -k /usr/share/wordlists/rockyou.txt.gz   # only if rockyou.txt is still gzipped
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -U <USER> -P /usr/share/wordlists/rockyou.txt -o recon/wpscan-bruteforce-<VHOST>.txt
```

> **Read:** `grep "SUCCESS" recon/wpscan-bruteforce-<VHOST>.txt` shows the valid user and password.

| Save to file | Next |
|:---:|---|
| `[x]` | Log in. Check the theme and plugin editors and the upload page. |

**Other CMS** (Joomla, Drupal): see cheatsheet → *CMS*.

### O. WAF & architecture

#### WAF detection · `WSTG-INFO-10`

*When:* payloads get blocked or altered, or every request returns an identical page.

```bash
wafw00f "<SCHEME>://<VHOST>/" > recon/wafw00f-<VHOST>.txt
```

> **Read:** The WAF name is in the output. A "no WAF" result means none was found.

| Save to file | Next |
|:---:|---|
| `[x]` | A WAF found means: lower `-t`, encode payloads, and note it. |

#### Compare a benign and a suspicious request · `WSTG-INFO-10`

*When:* `wafw00f` was inconclusive, or you want to confirm a WAF before changing tactics.

```bash
curl -sk -o /dev/null -w "benign %{http_code}\n" "<SCHEME>://<VHOST>/?q=test"
curl -sk -o /dev/null -w "payload %{http_code}\n" "<SCHEME>://<VHOST>/?q=<script>alert(1)</script>"
curl -sk -D - -o /dev/null "<SCHEME>://<VHOST>/" | grep -iE "via|x-cache|cf-ray|x-forwarded"
```

> **Read:** A different status (403, 406) or a block page for the payload means a WAF is in front. The `via`, `x-cache`, and `cf-ray` headers name the proxy.

| Save to file | Next |
|:---:|---|
| `[ ]` | Same as above. |

***

## Discovery → next step

| What you found | Do next |
|---|---|
| Open web port | whatweb, headers, then the directory scan on `<SCHEME>://<IP>:<PORT>` |
| SAN, AXFR, or vhost hit | Add to `/etc/hosts` and Burp scope, then run the root checks on it |
| 200 / 301 / 302 path | Open in Burp, add to Site map |
| 401 / 405 / 500 path | An API or an error: read it in Burp Repeater, try other verbs |
| 403 path | Verb tampering (block H) |
| Login works, or you hold a cookie | Authenticated re-scan (block M) and the API probe with the cookie |
| WSDL, Swagger, or `/api` | Web service tests |
| HTTPS port | TLS weaknesses (block F) |
| FTP anonymous or open rsync/NFS | Check for web files (block F) |
| WAF or blocked payload | Lower `-t`, encode payloads, note the WAF |
| Backup, `.git`, `.env`, or an archive | Download it and read it before anything else |
| WordPress fingerprint | Block N. Joomla or Drupal: cheatsheet → *CMS* |
| Parameter that changes output | Note it for SQLi, XSS, IDOR, and logic tests |

***