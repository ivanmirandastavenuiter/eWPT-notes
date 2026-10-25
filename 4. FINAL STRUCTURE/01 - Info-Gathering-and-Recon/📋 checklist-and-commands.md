# Phase 1 – WSTG Recon: Checklist + Commands

**Tags:** `ASYNC` start at once, read later · `MANUAL` Burp/browser while scans run · `EXTRA` only when a question or a blocker (403, WAF, OSINT question) points to it.

***

## Conventions

| Placeholder | Meaning |
|---|---|
| `<IP>` | Exam IP |
| `<DOMAIN>` | Registered domain (`target.com`) |
| `<VHOST>` | Host to request (`app.target.com`, or `<IP>` if none) |
| `<SCHEME>` / `<PORT>` | `http`/`https` and port |
| `<BASELINE>` | Response size of a non-existent page, see below |
| `<COOKIE>` / `<PROXY>` | `PHPSESSID=...` / `127.0.0.1:8080` |
| `<WEB_PORTS>` | Comma list of open HTTP(S) ports from the full scan, e.g. `80,443,8080` |
| `<NAMESERVER>` | One name server from `dig NS` |
| `<PAGE>` / `<PATH>` | Page or path (`login.php`, `/api/user`) |
| `<NAME>` | Page name without its extension (`login` for `login.php`) |
| `<PRODUCT>` / `<VERSION>` | Software name and version from whatweb or headers (`apache`, `2.4.49`) |
| `<JS_URL>` | Full URL of a `.js` file found in the page |
| `<METHOD>` / `<BODY>` | HTTP verb and request body (Appendix A) |
| `<SUBDOMAIN>` | Subdomain from DNS or vhost results (`dev.target.com`) |
| `<SUBNET>` | CIDR range from the scope (`172.20.0.0/24`), only when a subnet is in scope |
| `<TOKEN>` | WPScan API token (optional tool) |

- **Baseline (once per host or vhost):** size of a page that does not exist, so `-fs` can hide soft-404s.
  ```bash
  curl -sk -o /dev/null -w "%{size_download}\n" "<SCHEME>://<VHOST>/nohost-zz9"
  # vhost fuzzing: use a random Host instead
  curl -sk -o /dev/null -w "%{size_download}\n" -H "Host: nohost-zz9.<DOMAIN>" "http://<IP>/"
  ```
- **Start at the root** of each web host (`<SCHEME>://<VHOST>/`). A path-specific result can differ from the root, so only go deeper when the root gives you something.
- **Save to file flag:** every step's table has `[x]` or `[ ]` under Save to file. `[x]` means the command writes to `recon/` with `-o`; `[ ]` means you read the output in the terminal only. Long outputs (nmap, ffuf, gobuster, nikto, wpscan) are `[x]`.
- **Step format:** a heading with tags, a one-line description, the command, a **Read** quote, and a table with the save flag and next action.
- **Output folder:** run `mkdir -p recon` once in the working directory before the first scan.
- **Naming:** `recon/<tool>-<target>-<context>.<ext>`, e.g. `recon/nmap-full-172.20.0.2.txt`, `recon/ffuf-dirs-app.target.com.md`.
- **Read big output with grep, not by scrolling:** `grep -E "open" recon/nmap-full-<IP>.txt`, `grep -c "^[^#]" file`, `grep -v " 404 "`.

***

## WSTG-CONF-01 · Network infrastructure

### Full port scan · `ASYNC`

Most important async job; it also covers non-standard web ports.

```bash
nmap -sC -sV -p- --min-rate 1000 <IP> -oN recon/nmap-full-<IP>.txt
```

> **Read:** `grep -E "open" recon/nmap-full-<IP>.txt`. Each line is an open port with its service and version. Every HTTP(S) port goes into `<WEB_PORTS>`.

| Save to file | Next |
|:---:|---|
| `[x]` | Run the HTTP scripts step on `<WEB_PORTS>`, then WSTG-INFO-02 on each web port. |

### HTTP scripts on the open web ports · `ASYNC`

Run after the full scan, using its ports.

```bash
nmap -sV -p <WEB_PORTS> --script http-enum,http-title,http-methods,http-robots.txt <IP> -oN recon/nmap-http-<IP>.txt
```

> **Read:** `grep "|" recon/nmap-http-<IP>.txt`. `http-methods` lists allowed verbs (CONF-06). `http-enum` lists directories and files (CONF-05). `http-robots.txt` lists Disallow paths (INFO-03).

| Save to file | Next |
|:---:|---|
| `[x]` | Add every found path to Burp scope and test it. |

### TLS certificate SANs

Extra hostnames for `/etc/hosts`.

```bash
echo | openssl s_client -connect <IP>:443 -servername <DOMAIN> 2>/dev/null | openssl x509 -noout -ext subjectAltName
```

> **Read:** Each `DNS:` entry is a hostname. Keep it as a `<SUBDOMAIN>` candidate.

| Save to file | Next |
|:---:|---|
| `[ ]` | Add each name to `/etc/hosts` and Burp scope, then run the root checks on it. |

### DNS zone transfer (AXFR)

Get the name servers first, then ask each one.

```bash
dig NS <DOMAIN> +short
dig axfr <DOMAIN> @<NAMESERVER> > recon/dns-axfr-<DOMAIN>.txt
grep -c "IN" recon/dns-axfr-<DOMAIN>.txt
```

> **Read:** The count from `grep -c` is the record total. Real hostnames mean the zone transferred. `Transfer failed.` in the file means it was refused.

| Save to file | Next |
|:---:|---|
| `[x]` | Each hostname goes to the SAN and vhost checks. |

## WSTG-CONF-03 · File extension handling

### Alternate extensions on a known page

```bash
for e in php php7 phtml inc bak old; do curl -sk -o /dev/null -w "%{http_code} %{size_download} <NAME>.$e\n" "<SCHEME>://<VHOST>/<NAME>.$e"; done
```

> **Read:** Compare each line with the `php` line. A `200` on `php7`, `phtml`, `inc`, or `bak` with source code in the body means the server serves that extension as plain text. A different size from `php` means a separate handler.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each `200` in Burp and read the body. Source code in the response is a finding. |

`Not critical`

## WSTG-CONF-04 · Backup and unreferenced files

### Backup and temp files · `ASYNC`

On the root and known files.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -e .bak,.old,.swp,.tmp,~ -mc 200 -fs <BASELINE> -t 10 -o recon/ffuf-backups-<VHOST>.md -of md
```

> **Read:** `grep -iE "bak|old|swp|tmp" recon/ffuf-backups-<VHOST>.md`. Each hit is a file that exists.

| Save to file | Next |
|:---:|---|
| `[x]` | Download each hit and read it before anything else. |

## WSTG-CONF-02 · Application platform configuration

### Source control and env leaks

```bash
for p in .git/HEAD .svn/entries .env .DS_Store; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** Only `200` lines matter. `403` means the file exists but is blocked.

| Save to file | Next |
|:---:|---|
| `[ ]` | `.git/HEAD` at `200`: dump the repo with `wget -r` and read its config. `.env` at `200`: read it for credentials. |

### Debug and default endpoints

```bash
for p in _profiler phpinfo.php actuator/env server-status console; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** `200` means the endpoint is live. `403` means present but blocked, so send it to CONF-06.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each live endpoint in Burp and record it as a finding. |

## WSTG-CONF-05 · Admin interfaces and directories

### Directory brute force · `ASYNC`

On each web host. This is the main directory scan.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403 -fs <BASELINE> -t 10 -o recon/ffuf-dirs-<VHOST>.md -of md
```

> **Read:** Open the `.md` report and sort by status. `200`, `301`, and `302` are pages to open in Burp. `403` goes to CONF-06.

| Save to file | Next |
|:---:|---|
| `[x]` | Add each hit to the Burp Site map. A new directory repeats INFO-06 on it. |

### Admin keywords

Quick check of the paths most likely to matter.

```bash
for p in admin manage dashboard phpmyadmin grafana jenkins; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p/"; done
```

> **Read:** `200`, `301`, `302`, `401`, and `403` are leads. `404` means nothing is there.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each lead in Burp. A login page goes to the auth tests. |

### Log every 403

```bash
grep "403" recon/ffuf-dirs-<VHOST>.md > recon/forbidden-<VHOST>.txt
```

> **Read:** Each line is a path to test in CONF-06.

| Save to file | Next |
|:---:|---|
| `[x]` | Run the verb tampering check in CONF-06 on each path. |

## WSTG-INFO-01 · Search engine discovery ❓ EXTRA (OSINT questions)

### Google dorks

```text
site:<DOMAIN> ext:xml OR ext:conf OR ext:bak
site:<DOMAIN> inurl:admin OR inurl:staging
site:<DOMAIN> "index of" "backup"
```

> **Read:** Open each result. The search snippet can be stale.

| Save to file | Next |
|:---:|---|
| `[x]` (keep confirmed URLs in `recon/osint-<DOMAIN>.txt`) | Any live URL goes to Burp scope and INFO-05. |

### Code repos

```text
GitHub search: "<DOMAIN>" "API_KEY"
GitHub search: "<DOMAIN>" "secret" "token"
```

> **Read:** Open the matching file and confirm the value is real, not a placeholder.

| Save to file | Next |
|:---:|---|
| `[ ]` | A real credential gets tested on the login page. Screenshot the file. |

### Host lookup

Also search the certificate by `<DOMAIN>` on the same site.

```text
https://www.shodan.io/host/<IP>
```

> **Read:** Compare ports and banners with the nmap scan. A port that nmap did not show is a lead.

| Save to file | Next |
|:---:|---|
| `[ ]` | Each new port goes to WSTG-INFO-02. |

## WSTG-INFO-02 · Web server and stack fingerprint

### Tech stack · `ASYNC`

CMS, frameworks, and plugins.

```bash
whatweb -v "<SCHEME>://<VHOST>/" > recon/whatweb-<VHOST>.txt
```

> **Read:** Read the plugin names and version numbers in brackets, for example `Apache[2.4.x]`.

| Save to file | Next |
|:---:|---|
| `[x]` | CMS detected goes to WSTG-INFO-08. A framework version goes to a CVE search. |

### Known exploits for the detected version

Run once per product from whatweb or the headers.

```bash
searchsploit "<PRODUCT> <VERSION>" > recon/searchsploit-<PRODUCT>.txt
```

> **Read:** Each line is an exploit title and its path. Match the title to the exact version before using it.

| Save to file | Next |
|:---:|---|
| `[x]` | A version-matched exploit is a lead to verify in Burp, not a finding. |

### Quick vulnerability scan · `ASYNC`

Treat results as leads to verify, not findings.

```bash
nikto -h "<SCHEME>://<VHOST>:<PORT>/" -o recon/nikto-<VHOST>.txt
```

> **Read:** `grep "^+" recon/nikto-<VHOST>.txt` shows the findings. Each one is a lead.

| Save to file | Next |
|:---:|---|
| `[x]` | Verify each lead in Burp before it goes in the report. |

### Headers · `MANUAL`

```bash
curl -sk -I "<SCHEME>://<VHOST>:<PORT>/" | grep -iE "^(server|x-powered-by|x-aspnet-version|strict-transport-security|content-security-policy|x-frame-options|x-content-type-options|set-cookie)"
```

> **Read:** `Server` and `X-Powered-By` with version numbers are findings. Missing security headers are informational. `Set-Cookie` without `HttpOnly`, `Secure`, or `SameSite` is a lead for session tests.

| Save to file | Next |
|:---:|---|
| `[ ]` | A version string goes to whatweb and searchsploit. Cookie flags go to the auth and session tests. |

### Verbose error · `MANUAL`

Force a 404 and look for version strings.

```bash
curl -sk -i "<SCHEME>://<VHOST>:<PORT>/nohost-zz9.php" | grep -iE "apache|php|tomcat|nginx|version|exception"
```

> **Read:** A stack trace or version in the body is a finding. Read the full body in Burp.

| Save to file | Next |
|:---:|---|
| `[ ]` | Record the version. A stack trace goes to the input validation tests. |

## WSTG-INFO-03 · Webserver metafiles

### Status of each metafile · `MANUAL`

Then read only the ones that exist.

```bash
for f in robots.txt sitemap.xml .well-known/security.txt crossdomain.xml clientaccesspolicy.xml humans.txt; do curl -sk -o /dev/null -w "%{http_code} $f\n" "<SCHEME>://<VHOST>/$f"; done
curl -sk "<SCHEME>://<VHOST>/robots.txt" | grep -i disallow
```

> **Read:** `200` means read the file. `404` means it is absent. The `Disallow:` lines are the paths to test.

| Save to file | Next |
|:---:|---|
| `[ ]` | Add every `Disallow:` path to Burp scope and test it like a discovered directory. |

## WSTG-INFO-04 · Virtual hosts and applications

### VHost fuzzing · `ASYNC`

Use the baseline from the conventions section.

```bash
ffuf -u "<SCHEME>://<IP>/" -H "Host: FUZZ.<DOMAIN>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs <BASELINE> -t 10 -o recon/ffuf-vhosts-<DOMAIN>.md -of md
```

> **Read:** Each hit is a vhost name. Read the size and status columns in the `.md` report.

| Save to file | Next |
|:---:|---|
| `[x]` | Add each hit to `/etc/hosts` on the same line as the target and to Burp scope, then run the root checks on it. |

### DNS brute force · `ASYNC`

Finds subdomains that have DNS records, which vhost fuzzing can miss.

```bash
dnsenum --noreverse -f /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -o recon/dnsenum-<DOMAIN>.xml <DOMAIN>
```

> **Read:** `grep -oE "[a-z0-9.-]+\.<DOMAIN>" recon/dnsenum-<DOMAIN>.xml | sort -u` lists each unique name.

| Save to file | Next |
|:---:|---|
| `[x]` | Each new name goes to `/etc/hosts` and the root checks, the same as the vhost hits. |

### Non-standard web ports

The full scan already covers them, so no new scan is needed.

```bash
grep "open" recon/nmap-full-<IP>.txt
```

> **Read:** Each port with an http or https service is a web host.

| Save to file | Next |
|:---:|---|
| `[ ]` | Each one becomes a `<WEB_PORTS>` entry for WSTG-INFO-02. |

## WSTG-INFO-05 · Webpage content and source code

### Comments, JS, and hidden fields on the root page · `MANUAL`

```bash
curl -sk "<SCHEME>://<VHOST>/" | grep -Eio '<!--.*-->|src="[^"]+\.js"|type="hidden"[^>]*' | sort -u
```

> **Read:** Comments and hidden values can show internal paths or debug notes. Each `.js` path is a file to open.

| Save to file | Next |
|:---:|---|
| `[ ]` | Each JS URL goes to the next step. A hidden value is a parameter for INFO-06. |

### Secrets and internal IPs in a JS file · `MANUAL`

```bash
curl -sk "<JS_URL>" | grep -Eio '(api_key|secret|token|jwt)[^,;]{0,60}|10\.[0-9]+\.[0-9]+\.[0-9]+'
```

> **Read:** Each match shows a key name and its value. `10.x.x.x` addresses are internal hosts for the report.

| Save to file | Next |
|:---:|---|
| `[ ]` | A real secret gets tested. An internal IP gets noted and checked in the SSRF tests. |

## WSTG-INFO-06 · Application entry points

### Walk the app in Burp · `MANUAL`

Proxy on. Build the list from Target → Site map.

> **Read:** Sort the Site map by URL. Note each GET parameter, POST body, custom header, and API path.

| Save to file | Next |
|:---:|---|
| `[ ]` | Parameters go to the fuzz steps below. |

### GET parameter names · `ASYNC`

Set `<BASELINE>` to that page's size with a random parameter.

```bash
ffuf -u "<SCHEME>://<VHOST>/<PAGE>?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -fs <BASELINE> -mc all -t 5 -o recon/ffuf-get-params.md -of md
```

> **Read:** `-fs` hides the baseline size, so each hit is a parameter that changes the response.

| Save to file | Next |
|:---:|---|
| `[x]` | A confirmed parameter goes to the value fuzz below. Note it for SQLi and XSS tests. |

### POST parameter names · `ASYNC`

Form-encoded.

```bash
ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "FUZZ=test" -H "Content-Type: application/x-www-form-urlencoded" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -fs <BASELINE> -mc all -t 5 -o recon/ffuf-post-params.md -of md
```

> **Read:** Same as GET. Each hit is a body field that changes the response.

| Save to file | Next |
|:---:|---|
| `[x]` | Note it for SQLi, XSS, and logic tests. |

### Parameter values once a parameter is confirmed

Numeric IDs.

```bash
seq 1 1000 > recon/ids.txt
ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "id=FUZZ" -H "Content-Type: application/x-www-form-urlencoded" -w recon/ids.txt -fs <BASELINE> -t 5 -o recon/ffuf-id-values.md -of md
```

> **Read:** A `200` with a different size from the baseline is another record.

| Save to file | Next |
|:---:|---|
| `[x]` | A record ID that exposes another user's data goes to the IDOR test. |

### API endpoints · `ASYNC`

Only when the app has an `/api` path.

```bash
gobuster dir -u "<SCHEME>://<VHOST>/api" -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -b 403,404 -t 10 -o recon/gobuster-api-<VHOST>.txt
```

> **Read:** Each `200` is an endpoint. Read its response in Burp.

| Save to file | Next |
|:---:|---|
| `[x]` | Each endpoint goes to Burp Repeater and the web service tests. |

## WSTG-INFO-07 · Execution paths

### Map the workflows · `MANUAL`

Registration, login, profile edit, checkout, and password reset. Replay any request with the Appendix A template.

> **Read:** In Burp HTTP history, note where session tokens change between steps.

| Save to file | Next |
|:---:|---|
| `[ ]` | Multi-step flows go to the logic tests. |

## WSTG-INFO-08 · CMS fingerprint ❓ EXTRA (only when whatweb or headers suggest a CMS)

### Check for WordPress markers

```bash
curl -sk "<SCHEME>://<VHOST>/" | grep -Eio 'wp-content|wp-includes|name="generator"[^>]*'
for p in wp-login.php wp-json/ xmlrpc.php readme.html; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** `wp-content` or `wp-includes` in the source means WordPress. A `200` on `wp-login.php`, `wp-json/`, or `xmlrpc.php` confirms it. The generator tag shows the version.

| Save to file | Next |
|:---:|---|
| `[ ]` | WordPress confirmed goes to WSTG-INFO-09. Anything else goes to the other CMS tools below. |

### WordPress version

```bash
curl -sk "<SCHEME>://<VHOST>/readme.html" | grep -i "version"
```

> **Read:** Compare the version with CVE lists. Hardened sites remove this file, so use the version from the wpscan report instead.

| Save to file | Next |
|:---:|---|
| `[ ]` | The version goes to searchsploit and the wpscan report. |

## WSTG-INFO-09 · WordPress with wpscan ❓ EXTRA (only when WordPress is confirmed)

### Full wpscan enumeration · `ASYNC`

```bash
wpscan --url "<SCHEME>://<VHOST>/" --disable-tls-checks -e u,vp,vt,cb,dbe --api-token <TOKEN> -o recon/wpscan-<VHOST>.txt
```

> **Read:** `grep -E "\[\+\]|\[!\]" recon/wpscan-<VHOST>.txt`. `[+]` is a finding (version, theme, plugin, user). `[!]` is a warning or vulnerability. Drop `--api-token <TOKEN>` if you have no token. Vulnerability details are then missing.

| Save to file | Next |
|:---:|---|
| `[x]` | A vulnerable plugin or theme goes to a CVE search. Each user goes to the user step below. |

### Users only

```bash
wpscan --url "<SCHEME>://<VHOST>/" --disable-tls-checks -e u
curl -sk "<SCHEME>://<VHOST>/wp-json/wp/v2/users" | grep -Eo '"slug":"[^"]+"'
```

> **Read:** Each username from either output is a login candidate.

| Save to file | Next |
|:---:|---|
| `[ ]` | Usernames go to the password test below. Lab scope only. |

### Aggressive plugin detection

Finds plugins the passive scan missed.

```bash
wpscan --url "<SCHEME>://<VHOST>/" --disable-tls-checks --plugins-detection aggressive -e vp -o recon/wpscan-plugins-<VHOST>.txt
```

> **Read:** Read each `[+]` plugin line and its version. Match the version against the `[!]` vulnerability lines below it.

| Save to file | Next |
|:---:|---|
| `[x]` | A vulnerable plugin goes to `searchsploit <PLUGIN_NAME>`. |

### Password test · lab scope only

Only with a username from the users step.

```bash
gunzip -k /usr/share/wordlists/rockyou.txt.gz   # only if rockyou.txt is still gzipped
wpscan --url "<SCHEME>://<VHOST>/" --disable-tls-checks -U <USER> -P /usr/share/wordlists/rockyou.txt -o recon/wpscan-bruteforce-<VHOST>.txt
```

> **Read:** `grep "SUCCESS" recon/wpscan-bruteforce-<VHOST>.txt` shows the valid user and password.

| Save to file | Next |
|:---:|---|
| `[x]` | Log in. Check the theme and plugin editors and the upload page for admin-level attack paths. |

**Other CMS tools (mention only, no command set here).** If wpscan is not the right tool, use the one that matches the fingerprint: `joomscan` for Joomla, `droopescan` for Drupal, SilverStripe, and Moodle, and `CMSmap` for WordPress, Joomla, Drupal, and Moodle.

## WSTG-INFO-10 · Application architecture and WAF ❓ EXTRA (payloads blocked)

### WAF detection

```bash
wafw00f "<SCHEME>://<VHOST>/" > recon/wafw00f-<VHOST>.txt
```

> **Read:** The WAF name is in the output. A "no WAF" result means none was found.

| Save to file | Next |
|:---:|---|
| `[x]` | A WAF found means: lower `-t`, encode payloads, and note the WAF in the report. |

### Compare a benign and a suspicious request

```bash
curl -sk -o /dev/null -w "benign %{http_code}\n" "<SCHEME>://<VHOST>/?q=test"
curl -sk -o /dev/null -w "payload %{http_code}\n" "<SCHEME>://<VHOST>/?q=<script>alert(1)</script>"
curl -skI "<SCHEME>://<VHOST>/" | grep -iE "via|x-cache|cf-ray|x-forwarded"
```

> **Read:** A different status (403, 406) or a block page for the payload means a WAF is in front. The `via`, `x-cache`, and `cf-ray` headers name the proxy.

| Save to file | Next |
|:---:|---|
| `[ ]` | Same as above. |

## WSTG-CONF-06 · HTTP methods ❓ EXTRA (403 pages)

### Allowed methods

```bash
curl -sk -i -X OPTIONS "<SCHEME>://<VHOST>:<PORT>/" | grep -i allow
```

> **Read:** The `Allow:` header lists the verbs the server accepts.

| Save to file | Next |
|:---:|---|
| `[ ]` | Verbs that are missing from `Allow:` but still work go to the verb tampering step below. |

### Verb tampering on a restricted path

```bash
for m in GET HEAD POST PUT DELETE TRACE; do curl -sk --max-time 10 -o /dev/null -w "$m %{http_code}\n" -X $m "<SCHEME>://<VHOST>:<PORT>/admin/"; done
```

> **Read:** Any code other than `403` is a lead. A `200` with a different verb is a bypass candidate.

| Save to file | Next |
|:---:|---|
| `[ ]` | A `200` opens in Burp Repeater with that verb, and the body is checked. |

## WSTG-CONF-10 · Subdomain takeover ❓ EXTRA (cloud or dangling DNS)

### CNAME target of each subdomain

```bash
dig CNAME <SUBDOMAIN> +short
```

> **Read:** A provider name (S3, GitHub Pages, Azure) means the subdomain points to a third party.

| Save to file | Next |
|:---:|---|
| `[ ]` | Check the response in the next step. |

### Takeover check

Save the provider response as evidence.

```bash
curl -sk "<SCHEME>://<SUBDOMAIN>/" -o recon/takeover-<SUBDOMAIN>.html
```

> **Read:** A "NoSuchBucket" or 404 page from the provider is the takeover condition. Document the CNAME and the provider error.

| Save to file | Next |
|:---:|---|
| `[x]` | Report the finding with the CNAME and the saved response. |

***

## Discovery → next step

| What you found | Do next |
|---|---|
| Open web port | Run INFO-02 and CONF-05 on `<SCHEME>://<IP>:<PORT>` |
| SAN, AXFR, or vhost hit | Add to `/etc/hosts` and Burp scope, then run the root checks on it |
| 200 / 301 / 302 / 403 path | Open in Burp, add to Site map; a 403 goes to CONF-06 |
| Parameter that changes output | INFO-06 value fuzz; note it for SQLi, IDOR, and logic tests |
| WAF or blocked payload | Lower `-t`, encode payloads, note the WAF in the report |
| Backup, `.git`, or `.env` file | Download it and read it before anything else |
| WordPress or Drupal fingerprint | WSTG-INFO-08, then WSTG-INFO-09 for WordPress or the other CMS tools list |

***

## Appendix A · Request template

```bash
curl -sk -i -X <METHOD> "<SCHEME>://<VHOST>:<PORT><PATH>" \
  -H "Cookie: <COOKIE>" -H "Content-Type: application/json" \
  --data '<BODY>' --proxy http://<PROXY>
```

Change one thing at a time (method, header, or one body field) so you can tell what caused the result.

## Appendix B · Optional tools

Check at the start of the exam which of these exist, and skip the ones that are missing:

```bash
command -v wafw00f whatweb nikto gobuster dnsenum wpscan
```

**Alternatives (mention only, no commands here):**
- `dirb`: alternative to `ffuf` or `gobuster` for directory brute force.
- `netscan`: alternative to `nmap` for network and port discovery.

## Appendix C · Variants

```bash
# ffuf: recursion one level down
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-small.txt -recursion -recursion-depth 1 -e .php -mc 200,301,302,403 -t 10

# gobuster: extensions, and exclude noise codes
gobuster dir -u "<SCHEME>://<VHOST>/" -w /usr/share/wordlists/dirb/common.txt -x php,html,txt,bak -b 403,404 -t 10 -o recon/gobuster-root-<VHOST>.txt

# nikto through Burp, with a session cookie
nikto -h "<SCHEME>://<VHOST>:<PORT>/" -useproxy http://<PROXY> -cookie "<COOKIE>" -o recon/nikto-proxy-<VHOST>.txt

# gobuster with a session cookie (authenticated directory scan)
gobuster dir -u "<SCHEME>://<VHOST>/" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -c "<COOKIE>" -t 10 -o recon/gobuster-auth-<VHOST>.txt

# nikto multi-port, HTTPS-aware, slower tuning
nikto -h "<SCHEME>://<VHOST>/" -p 80,443,8080,8443 -ssl -Tuning x6 -o recon/nikto-multi-<VHOST>.txt

# wafw00f aggressive signature search
wafw00f -a "<SCHEME>://<VHOST>/" > recon/wafw00f-all-<VHOST>.txt

# reverse DNS
dig -x <IP> +short > recon/dns-reverse-<IP>.txt
```
