# Phase 1 – WSTG Recon: Checklist + Commands

Work top-down by WSTG ID. Each item = what to do, the command, and what to look for.

**Tags:** ⏱ **ASYNC** start at once, read later · 🖐 **MANUAL** Burp/browser while scans run · ❓ **EXTRA** only when a question or a blocker (403, WAF, OSINT question) points to it.

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
| `<JS_URL>` | Full URL of a `.js` file found in the page |
| `<METHOD>` / `<BODY>` | HTTP verb and request body (Appendix A) |

- **Baseline (once per host or vhost):** size of a page that does not exist, so `-fs` can hide soft-404s.
  ```bash
  curl -sk -o /dev/null -w "%{size_download}\n" "<SCHEME>://<VHOST>/nohost-zz9"
  # vhost fuzzing: use a random Host instead
  curl -sk -o /dev/null -w "%{size_download}\n" -H "Host: nohost-zz9.<DOMAIN>" "http://<IP>/"
  ```
- **Start at the root** of each web host (`<SCHEME>://<VHOST>/`). A path-specific result can differ from the root, so only go deeper when the root gives you something.
- **Output files:** redirect only the long outputs (nmap, ffuf, gobuster, nikto). Quick `curl`/`dig` checks print to the terminal and you read them there.
- **Naming:** `recon/<tool>-<target>-<context>.<ext>`, e.g. `recon/nmap-full-172.20.0.2.txt`, `recon/ffuf-dirs-app.target.com.md`.
- **Read big output with grep, not by scrolling:** `grep -E "open" recon/nmap-full-<IP>.txt`, `grep -c "^[^#]" file`, `grep -v " 404 "`.

***

## WSTG-CONF-01 · Network infrastructure

- [ ] ⏱ **Full port scan.** Most important async job; it also covers non-standard web ports (no separate port scan needed).
  ```bash
  nmap -sC -sV -p- --min-rate 1000 <IP> -oN recon/nmap-full-<IP>.txt
  grep -E "open" recon/nmap-full-<IP>.txt
  ```
- [ ] ⏱ **HTTP scripts on the open web ports** (run after the scan above, using its ports).
  ```bash
  nmap -sV -p <WEB_PORTS> --script http-enum,http-title,http-methods,http-robots.txt <IP> -oN recon/nmap-http-<IP>.txt
  ```
- [ ] ⏱ **TLS certificate SANs** (extra hostnames to add to `/etc/hosts`).
  ```bash
  echo | openssl s_client -connect <IP>:443 -servername <DOMAIN> 2>/dev/null | openssl x509 -noout -ext subjectAltName
  ```
- [ ] ⏱ **DNS zone transfer** (AXFR). Get the name servers first, then ask each one.
  ```bash
  dig NS <DOMAIN> +short
  dig axfr <DOMAIN> @<NAMESERVER> > recon/dns-axfr-<DOMAIN>.txt
  grep -c "IN" recon/dns-axfr-<DOMAIN>.txt
  ```

## WSTG-CONF-02 · Application platform configuration

- [ ] ⏱ **Backup and temp files** on the root and on known files.
  ```bash
  ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -e .bak,.old,.swp,.tmp,~ -mc 200 -fs <BASELINE> -t 10 -o recon/ffuf-backups-<VHOST>.md -of md
  ```
- [ ] ⏱ **Source control and env leaks.**
  ```bash
  for p in .git/HEAD .svn/entries .env .DS_Store; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
  ```
- [ ] ⏱ **Debug and default endpoints.**
  ```bash
  for p in _profiler phpinfo.php actuator/env server-status console; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
  ```

## WSTG-CONF-05 · Admin interfaces and directories

- [ ] ⏱ **Directory brute force** on each web host (this is the main directory scan).
  ```bash
  ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403 -fs <BASELINE> -t 10 -o recon/ffuf-dirs-<VHOST>.md -of md
  ```
- [ ] **Admin keywords** (quick check of the paths most likely to matter).
  ```bash
  for p in admin manage dashboard phpmyadmin grafana jenkins; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p/"; done
  ```
- [ ] **Log every 403.** Each one is a candidate for WSTG-CONF-06.

## WSTG-INFO-01 · Search engine discovery ❓ EXTRA (OSINT questions)

- [ ] **Google dorks:** `site:<DOMAIN> ext:xml OR ext:conf OR ext:bak`, `site:<DOMAIN> inurl:admin OR inurl:staging`, `site:<DOMAIN> "index of" "backup"`.
- [ ] **Code repos:** GitHub search for `"<DOMAIN>" "API_KEY"`, `"<DOMAIN>" "secret" "token"`.
- [ ] **Host lookup:** `https://www.shodan.io/host/<IP>` and certificate search by `<DOMAIN>`.
- [ ] **Save evidence:** screenshot each hit and keep the URL list in `recon/osint-<DOMAIN>.txt`.

## WSTG-INFO-02 · Web server and stack fingerprint

- [ ] ⏱ **Tech stack** (CMS, frameworks, plugins).
  ```bash
  whatweb -v "<SCHEME>://<VHOST>/" > recon/whatweb-<VHOST>.txt
  ```
- [ ] ⏱ **Quick vulnerability scan.** Treat results as leads to verify, not findings.
  ```bash
  nikto -h "<SCHEME>://<VHOST>:<PORT>/" -o recon/nikto-<VHOST>.txt
  ```
- [ ] 🖐 **Headers.** Read `Server`, `X-Powered-By`, `X-AspNet-Version`, `X-Frame-Options`.
  ```bash
  curl -sk -I "<SCHEME>://<VHOST>:<PORT>/" | grep -iE "^(server|x-powered-by|x-aspnet-version|x-frame-options)"
  ```
- [ ] 🖐 **Verbose error.** Force a 404 and look for version strings.
  ```bash
  curl -sk -i "<SCHEME>://<VHOST>:<PORT>/nohost-zz9.php" | grep -iE "apache|php|tomcat|nginx|version|exception"
  ```

## WSTG-INFO-03 · Webserver metafiles

- [ ] 🖐 **Status of each metafile**, then read only the ones that exist.
  ```bash
  for f in robots.txt sitemap.xml .well-known/security.txt crossdomain.xml humans.txt; do curl -sk -o /dev/null -w "%{http_code} $f\n" "<SCHEME>://<VHOST>/$f"; done
  curl -sk "<SCHEME>://<VHOST>/robots.txt" | grep -i disallow
  ```
- [ ] 🖐 Add every `Disallow:` path to Burp scope.

## WSTG-INFO-04 · Virtual hosts and applications

- [ ] ⏱ **VHost fuzzing** (use the baseline from the conventions section).
  ```bash
  ffuf -u "http://<IP>/" -H "Host: FUZZ.<DOMAIN>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs <BASELINE> -t 10 -o recon/ffuf-vhosts-<DOMAIN>.md -of md
  ```
- [ ] ⏱ Add each hit to `/etc/hosts` on the same line as the target and to Burp scope.
- [ ] Non-standard ports are already covered by the full scan (CONF-01). Check them with `grep open`.

## WSTG-INFO-05 · Webpage content and source code

- [ ] 🖐 **Comments, JS, and hidden fields** on the root page.
  ```bash
  curl -sk "<SCHEME>://<VHOST>/" | grep -Eio '<!--.*-->|src="[^"]+\.js"|type="hidden"[^>]*' | sort -u
  ```
- [ ] 🖐 **Secrets and internal IPs in a JS file.**
  ```bash
  curl -sk "<JS_URL>" | grep -Eio '(api_key|secret|token|jwt)[^,;]{0,60}|10\.[0-9]+\.[0-9]+\.[0-9]+'
  ```

## WSTG-INFO-06 · Application entry points

- [ ] 🖐 **Walk the app in Burp** with Proxy on. Build the list of GET parameters, POST bodies, custom headers, and API endpoints from Target → Site map.
- [ ] ⏱ **GET parameter names** on a page (set `<BASELINE>` to that page's size with a random parameter).
  ```bash
  ffuf -u "<SCHEME>://<VHOST>/<PAGE>?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -fs <BASELINE> -mc all -t 5 -o recon/ffuf-get-params.md -of md
  ```
- [ ] ⏱ **POST parameter names**, form-encoded.
  ```bash
  ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "FUZZ=test" -H "Content-Type: application/x-www-form-urlencoded" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -fs <BASELINE> -mc all -t 5 -o recon/ffuf-post-params.md -of md
  ```
- [ ] **Parameter values** once a parameter is confirmed (numeric IDs).
  ```bash
  seq 1 1000 > recon/ids.txt
  ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "id=FUZZ" -H "Content-Type: application/x-www-form-urlencoded" -w recon/ids.txt -fs <BASELINE> -t 5 -o recon/ffuf-id-values.md -of md
  ```
- [ ] ⏱ **API endpoints** (only when the app has an `/api` path).
  ```bash
  gobuster dir -u "<SCHEME>://<VHOST>/api" -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -b 403,404 -t 10 -o recon/gobuster-api-<VHOST>.txt
  ```

## WSTG-INFO-07 · Execution paths

- [ ] 🖐 **Map the workflows** (registration, login, profile edit, checkout, password reset) in Burp HTTP history. Note where session tokens change between steps and mark multi-step flows for logic testing.
  - No command. Replay any request with the template in Appendix A when you need to change one value.

## WSTG-INFO-10 · Application architecture and WAF ❓ EXTRA (payloads blocked)

- [ ] **WAF detection.**
  ```bash
  wafw00f "<SCHEME>://<VHOST>/" > recon/wafw00f-<VHOST>.txt
  ```
- [ ] **Compare a benign and a suspicious request.** Different status codes or a block page means a WAF is in front.
  ```bash
  curl -sk -o /dev/null -w "benign %{http_code}\n" "<SCHEME>://<VHOST>/?q=test"
  curl -sk -o /dev/null -w "payload %{http_code}\n" "<SCHEME>://<VHOST>/?q=<script>alert(1)</script>"
  curl -skI "<SCHEME>://<VHOST>/" | grep -iE "via|x-cache|cf-ray|x-forwarded"
  ```

## WSTG-CONF-06 · HTTP methods ❓ EXTRA (403 pages)

- [ ] **Allowed methods.**
  ```bash
  curl -sk -i -X OPTIONS "<SCHEME>://<VHOST>:<PORT>/" | grep -i allow
  ```
- [ ] **Verb tampering** on a restricted path. Any change from 403 is a lead.
  ```bash
  for m in GET HEAD POST PUT DELETE TRACE; do curl -sk -o /dev/null -w "$m %{http_code}\n" -X $m "<SCHEME>://<VHOST>:<PORT>/admin/"; done
  ```

## WSTG-CONF-10 · Subdomain takeover ❓ EXTRA (cloud or dangling DNS)

- [ ] **CNAME target** of each subdomain.
  ```bash
  dig CNAME <SUBDOMAIN> +short
  ```
- [ ] A dangling CNAME to S3, GitHub Pages, or Azure with a "NoSuchBucket" or 404 page is the takeover condition. Document the CNAME and the provider error.

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
