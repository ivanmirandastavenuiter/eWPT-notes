# 📜 Phase 1 Cheatsheet: Fallbacks and Variants

**Primary playbook:** [📋 checklist-and-commands.md](<./📋 checklist-and-commands.md>). Use this file when a checklist command fails, a tool or wordlist is missing, or you need another flag, filter, proxy, or session header. Section names match the checklist's **If it fails** lines.

Placeholders and output naming follow the checklist. Save output under `recon/`. Keep fuzzers at `-t 5` to `-t 10`. Kali has no internet, so nothing here needs it.

⚠️ marks a flag I could not confirm against your exam image. Test it once in the drill before relying on it.

---

## Wordlist fallbacks

Check what exists first: `ls /usr/share/seclists /usr/share/wordlists`.

| Purpose | Primary (SecLists) | Fallback if SecLists is missing |
|---|---|---|
| Directories and files | `Discovery/Web-Content/raft-medium-words.txt` | `/usr/share/wordlists/dirb/common.txt` (small, fast), `/usr/share/wordlists/dirb/big.txt`, `/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt` |
| Backups | `Discovery/Web-Content/raft-small-words.txt` | `/usr/share/wordlists/dirb/common.txt` |
| Subdomains and vhosts | `Discovery/DNS/subdomains-top1million-5000.txt` | `/usr/share/nmap/nselib/data/vhosts-full.lst`, `/usr/share/dnsenum/dns.txt` ⚠️ |
| Parameter names | `Discovery/Web-Content/burp-parameter-names.txt` | `/usr/share/wordlists/wfuzz/general/common.txt` ⚠️, or the inline list below |
| API endpoints | `Discovery/Web-Content/api/api-endpoints.txt` | `/usr/share/wordlists/dirb/common.txt` |
| Passwords | `/usr/share/wordlists/rockyou.txt` | `gunzip -k /usr/share/wordlists/rockyou.txt.gz` if still gzipped |

```bash
# Inline parameter list when no wordlist exists
printf "id\npage\nfile\npath\nview\nlang\nuser\nq\nsearch\ncat\nitem\nname\nurl\nredirect\ndir\ndoc\ntemplate\nlogin\n" > recon/params.txt

# Find a wordlist by name
find /usr/share -iname "*common*.txt" 2>/dev/null | head
```

---

## Nmap

```bash
# Quick sanity check on top ports
nmap -F -Pn -n <IP>

# Full TCP, host blocks ping, no DNS lookups (the checklist default)
nmap -Pn -n -sC -sV -p- --min-rate 1000 <IP> -oN recon/nmap-full-<IP>.txt

# Slower, for a fragile or rate-limited host
nmap -Pn -n -sC -sV -p- -T3 --max-retries 2 --host-timeout 20m <IP> -oN recon/nmap-slow-<IP>.txt

# Common and alternate web ports only
nmap -Pn -n -sV -p 80,443,8000,8008,8080,8081,8180,8443,8888,9000,9443 <IP> -oN recon/nmap-web-<IP>.txt

# Several targets from a file
nmap -Pn -n -sV -iL hosts.txt -oN recon/nmap-hosts.txt

# Aggressive (OS, versions, scripts, traceroute)
sudo nmap -A -T4 <IP> -oN recon/nmap-aggressive-<IP>.txt

# UDP top ports (needs root, slow)
sudo nmap -sU --top-ports 20 <IP> -oN recon/nmap-udp-<IP>.txt

# Web scripts: banners, headers, WebDAV, methods, generator
nmap -Pn -n -sV -p <WEB_PORTS> --script=banner,http-headers,http-generator <IP> -oN recon/nmap-banner-<IP>.txt
nmap -Pn -n -p <WEB_PORTS> --script=http-webdav-scan,http-methods --script-args http-methods.url-path=/ <IP> -oN recon/nmap-webdav-<IP>.txt

# Grepable output
nmap -Pn -n -sV -p- --max-retries 2 --host-timeout 10m -oG recon/nmap-grep-<IP>.txt <IP>
```

---

## ffuf

Every command writes `-of all` (six files; read the `.csv` with the awk lines in *Reading output*). `-ac` is the default calibration. Replace it with `-fs <BASELINE>` if it over-filters.

```bash
# Backup suffix on a known page (index.phpFUZZ)
ffuf -u "<SCHEME>://<VHOST>/index.phpFUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e .bak,.old,.swp,~ -mc 200 -ac -t 10 -o recon/ffuf-bak-<VHOST> -of all

# Manual baseline instead of -ac
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc all -fc 404 -fs <BASELINE> -t 10 -o recon/ffuf-fs-<VHOST> -of all

# Recursive, depth 2
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-small.txt -recursion -recursion-depth 2 -mc all -fc 404 -ac -t 10 -o recon/ffuf-recursive-<VHOST> -of all

# Directories only (quick, fewer requests)
ffuf -u "<SCHEME>://<VHOST>/FUZZ/" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc all -fc 404 -ac -t 10 -o recon/ffuf-dironly-<VHOST> -of all

# Vhost fuzzing with a manual baseline (use if -ac misses)
ffuf -u "<SCHEME>://<IP>/" -H "Host: FUZZ.<DOMAIN>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs <BASELINE> -t 10 -o recon/ffuf-vhosts-fs-<DOMAIN> -of all

# Two-position fuzzing (path components)
ffuf -u "<SCHEME>://<VHOST>/FUZZ1/FUZZ2" -w dirs.txt:FUZZ1 -w files.txt:FUZZ2 -mc 200,301,302 -t 5 -o recon/ffuf-multipos-<VHOST> -of all

# Header names (X-Original-URL, X-Forwarded-For, ...)
ffuf -u "<SCHEME>://<VHOST>/" -H "FUZZ: test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc 200,302,403 -t 5 -o recon/ffuf-headers-<VHOST> -of all

# Combined filters (read the values from a baseline, never copy them)
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w dirs.txt -fs <BASELINE> -fw <WORDS> -fl <LINES> -fc 404 -t 10 -o recon/ffuf-filtered-<VHOST> -of all

# JSON API value fuzzing
ffuf -u "<SCHEME>://<VHOST>/api" -X POST -H "Content-Type: application/json" -d '{"user":"FUZZ"}' -w users.txt -mc 200,401 -t 5 -o recon/ffuf-json-<VHOST> -of all

# Through Burp: delay and proxy, or replay only the matches into Burp
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w dirs.txt -p 0.5 -x http://<PROXY> -t 10 -o recon/ffuf-proxy-<VHOST> -of all
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w dirs.txt -replay-proxy http://<PROXY> -t 10 -o recon/ffuf-replay-<VHOST> -of all
```

---

## feroxbuster

Confirmed on past exams. Its default is 50 threads and recursion depth 4, so always set `-t` and `-d`. `--no-state` stops it writing state files; `-k` skips TLS checks.

```bash
# Directories and files, stack extension, depth 2
feroxbuster -u "<SCHEME>://<VHOST>/" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -x php,txt -t 10 -d 2 -k --no-state -o recon/ferox-<VHOST>.txt

# No recursion (matches the ffuf scan)
feroxbuster -u "<SCHEME>://<VHOST>/" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -x php,txt -t 10 -n -k --no-state -o recon/ferox-flat-<VHOST>.txt

# Backups and archives
feroxbuster -u "<SCHEME>://<VHOST>/" -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -x bak,old,swp,tmp,zip,sql,orig,save -t 10 -n -k --no-state -o recon/ferox-backups-<VHOST>.txt

# Keep only chosen status codes, or hide some
feroxbuster -u "<SCHEME>://<VHOST>/" -w dirs.txt -s 200,301,302,401,403,405,500 -t 10 -k --no-state -o recon/ferox-status-<VHOST>.txt
feroxbuster -u "<SCHEME>://<VHOST>/" -w dirs.txt -C 404 -t 10 -k --no-state

# Authenticated, and through Burp
feroxbuster -u "<SCHEME>://<VHOST>/" -w dirs.txt -H "Cookie: <COOKIE>" -t 10 -k --no-state -o recon/ferox-auth-<VHOST>.txt
feroxbuster -u "<SCHEME>://<VHOST>/" -w dirs.txt -p http://<PROXY> -t 10 -k --no-state

# Collect backup copies of found files (newer versions only) ⚠️
feroxbuster -u "<SCHEME>://<VHOST>/" -w dirs.txt -B -t 10 -k --no-state
```

---

## wfuzz

Confirmed on past exams. `--hc/--hl/--hw/--hh` hide by status, lines, words, or characters. Take the baseline value from a first run with no filter.

```bash
# Directories
wfuzz -c -t 10 --hc 404 -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt "<SCHEME>://<VHOST>/FUZZ"

# Files with extensions (second list is extensions, joined with a dash)
wfuzz -c -t 10 --hc 404 -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -z list,php-txt-bak-old "<SCHEME>://<VHOST>/FUZZ.FUZ2Z"

# Vhosts, hiding the default response size
wfuzz -c -t 10 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -H "Host: FUZZ.<DOMAIN>" --hh <BASELINE> "<SCHEME>://<IP>/"

# GET and POST parameter names
wfuzz -c -t 5 --hc 404 --hh <BASELINE> -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt "<SCHEME>://<VHOST>/<PAGE>?FUZZ=test"
wfuzz -c -t 5 --hh <BASELINE> -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -d "FUZZ=test" "<SCHEME>://<VHOST>/<PAGE>"

# Numeric IDs
wfuzz -c -t 5 -z range,1-1000 --hh <BASELINE> "<SCHEME>://<VHOST>/<PAGE>?id=FUZZ"

# Authenticated, through Burp, with a delay, saved to a file
wfuzz -c -t 10 --hc 404 -b "<COOKIE>" -w dirs.txt "<SCHEME>://<VHOST>/FUZZ"
wfuzz -c -t 10 --hc 404 -p 127.0.0.1:8080:HTTP -w dirs.txt "<SCHEME>://<VHOST>/FUZZ"
wfuzz -c -t 10 -s 0.2 --hc 404 -f recon/wfuzz-dirs-<VHOST>.csv,csv -w dirs.txt "<SCHEME>://<VHOST>/FUZZ"
```

---

## gobuster

```bash
# Directories and files, noise codes excluded
gobuster dir -u "<SCHEME>://<VHOST>/" -w /usr/share/wordlists/dirb/common.txt -x php,html,txt,bak -b 403,404 -t 10 -k -o recon/gobuster-root-<VHOST>.txt

# Show only chosen codes (clear the default blacklist) ⚠️
gobuster dir -u "<SCHEME>://<VHOST>/" -w dirs.txt -s 200,301,302 -b "" -t 10 -k -o recon/gobuster-status-<VHOST>.txt

# Session cookie, and through Burp
gobuster dir -u "<SCHEME>://<VHOST>/" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -c "<COOKIE>" -t 10 -k -o recon/gobuster-auth-<VHOST>.txt
gobuster dir -u "<SCHEME>://<VHOST>/" -w dirs.txt -p http://<PROXY> -t 10 -k

# API endpoints
gobuster dir -u "<SCHEME>://<VHOST>/api" -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -b 403,404 -t 10 -k -o recon/gobuster-api-<VHOST>.txt

# VHost: append the domain to each word, or drop the default response length
gobuster vhost -u "<SCHEME>://<IP>/" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt --append-domain --domain <DOMAIN> -t 10 -o recon/gobuster-vhost-<IP>.txt
gobuster vhost -u "<SCHEME>://<IP>/" -w vhosts.txt --exclude-length <BASELINE> -t 10 -o recon/gobuster-vhost-exclen-<IP>.txt

# DNS subdomains against a chosen resolver
gobuster dns -d <DOMAIN> -w subdomains.txt --show-ips --show-cname -r <NAMESERVER>:53 -t 10 -o recon/gobuster-dns-<DOMAIN>.txt
```

---

## DNS

Only useful when nmap shows port 53 open. Try AXFR once per domain; if it fails, move on.

```bash
# Zone transfer
dig axfr <DOMAIN> @<NAMESERVER>
host -t axfr <DOMAIN> <NAMESERVER>
nmap -Pn -n -p 53 --script dns-zone-transfer --script-args dns-zone-transfer.domain=<DOMAIN> <IP>

# Records from the exam's DNS server
dig @<NAMESERVER> <DOMAIN> +short
dig @<NAMESERVER> -x <IP> +short
for t in A AAAA MX NS TXT SOA; do echo "== $t"; dig @<NAMESERVER> <DOMAIN> $t +short; done

# dnsenum: with the exam DNS server, with and without brute force
dnsenum --dnsserver <NAMESERVER> --enum <DOMAIN> -o recon/dnsenum-enum-<DOMAIN>.xml
dnsenum --dnsserver <NAMESERVER> --noreverse -f /usr/share/dnsenum/dns.txt <DOMAIN> -o recon/dnsenum-<DOMAIN>.xml

# dnsrecon: standard records plus AXFR, then brute force
dnsrecon -d <DOMAIN> -n <NAMESERVER> -t std,axfr -j recon/dnsrecon-std-<DOMAIN>.json
dnsrecon -d <DOMAIN> -n <NAMESERVER> -t brt -D /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -j recon/dnsrecon-brt-<DOMAIN>.json
```

---

## Fingerprinting

```bash
whatweb -a 3 "<SCHEME>://<VHOST>:<PORT>/" > recon/whatweb-aggressive-<VHOST>.txt      # more probes
whatweb -a 1 "<SCHEME>://<VHOST>:<PORT>/"                                              # one request, quiet
whatweb --no-errors -i urls.txt > recon/whatweb-bulk.txt                               # many hosts

# By hand: full response, generator tag, cookie names
curl -sk -i "<SCHEME>://<VHOST>:<PORT>/"
curl -sk "<SCHEME>://<VHOST>:<PORT>/" | grep -Eio '<meta name="generator"[^>]*|<title>[^<]*'
curl -sk -D - -o /dev/null "<SCHEME>://<VHOST>:<PORT>/" | grep -i "set-cookie"        # PHPSESSID, JSESSIONID, ASP.NET_SessionId name the stack

# WAF
wafw00f -a "<SCHEME>://<VHOST>/" > recon/wafw00f-all-<VHOST>.txt
wafw00f -i urls.txt > recon/wafw00f-bulk.txt
```

---

## Nikto

Run it last and alone. It is slow and noisy.

```bash
# Misconfiguration and information disclosure only (quieter)
nikto -h "<SCHEME>://<VHOST>:<PORT>/" -Tuning 23 -o recon/nikto-lownoise-<VHOST>.txt -Format txt

# HTTPS, several ports, time cap
nikto -h "<SCHEME>://<VHOST>/" -p 80,443,8080,8443 -ssl -maxtime 15m -o recon/nikto-multi-<VHOST>.txt -Format txt

# Through Burp, and against a named vhost
nikto -h "<SCHEME>://<IP>:<PORT>/" -vhost <VHOST> -useproxy http://<PROXY> -o recon/nikto-proxy-<VHOST>.txt -Format txt
```

Authenticated nikto: basic auth uses `-id user:pass`. For a session cookie, nikto has no command-line option; set `STATIC-COOKIE="name=value"` in `/etc/nikto.conf` ⚠️.

---

## searchsploit

The database is local and works offline. Layer 7 only: web server, CMS, plugin, JS library, application.

```bash
searchsploit "<PRODUCT> <VERSION>"
searchsploit -t "<PRODUCT> <VERSION>"          # title only, less noise
searchsploit "<PRODUCT>" --exclude="dos|DoS"   # hide denial of service
searchsploit -x <EDB-ID>                       # read the exploit
searchsploit -m <EDB-ID>                       # copy it to the working directory
searchsploit -p <EDB-ID>                       # path and URL of the entry
searchsploit -w "<PRODUCT>"                    # show the exploit-db URL (read it on the host PC)
```

Search the major version too (`apache 2.2`) when the exact version returns nothing. A match is a lead until a request in Burp confirms it.

---

## TLS & raw probes

```bash
# Handshake and full certificate
openssl s_client -connect <IP>:<PORT> -servername <DOMAIN>
openssl s_client -connect <IP>:<PORT> -servername <DOMAIN> 2>/dev/null | openssl x509 -noout -text

# Weak protocol checks, one at a time
openssl s_client -connect <IP>:<PORT> -tls1 2>&1 | grep -E "Protocol|Cipher"
openssl s_client -connect <IP>:<PORT> -ssl3 2>&1 | grep -E "Protocol|Cipher"

# Nmap scripts
nmap -Pn -n -sV -p <HTTPS_PORTS> --script ssl-enum-ciphers,ssl-cert,ssl-heartbleed,ssl-poodle,ssl-ccs-injection <IP> -oN recon/nmap-tls-<IP>.txt

# sslscan and testssl.sh, if installed
sslscan <IP>:<PORT> | tee recon/sslscan-<IP>.txt
testssl.sh <IP>:<PORT> | tee recon/testssl-<IP>.txt

# Netcat: port check, range, raw HTTP request
nc -zv <IP> <PORT>
nc -zvw10 <IP> 20-80
printf "GET / HTTP/1.1\r\nHost: <VHOST>\r\nConnection: close\r\n\r\n" | nc -v <IP> <PORT>
```

---

## Web services

```bash
# SOAP: fetch the WSDL and list its operations
curl -sk "<SCHEME>://<VHOST>:<PORT><PATH>?wsdl" -o recon/wsdl-<VHOST>.xml
grep -oE 'operation name="[^"]+"' recon/wsdl-<VHOST>.xml | sort -u

# Swagger or OpenAPI: list the paths
curl -sk "<SCHEME>://<VHOST>:<PORT>/swagger.json" | grep -oE '"/[^"]*":' | sort -u
curl -sk "<SCHEME>://<VHOST>:<PORT>/openapi.json" | grep -oE '"/[^"]*":' | sort -u

# GraphQL: introspection
curl -sk -X POST "<SCHEME>://<VHOST>:<PORT>/graphql" -H "Content-Type: application/json" --data '{"query":"{__schema{types{name}}}"}'

# REST: allowed methods and content-type handling on one endpoint
curl -sk -i -X OPTIONS "<SCHEME>://<VHOST>:<PORT>/api/<PATH>" | grep -i allow
for m in GET POST PUT DELETE PATCH; do curl -sk -o /dev/null -w "$m %{http_code}\n" -X $m "<SCHEME>://<VHOST>:<PORT>/api/<PATH>"; done
curl -sk -i -X POST "<SCHEME>://<VHOST>:<PORT>/api/<PATH>" -H "Content-Type: application/xml" --data '<a>1</a>'
curl -sk -i -X POST "<SCHEME>://<VHOST>:<PORT>/api/<PATH>" -H "Content-Type: application/json" --data '{"a":1}'

# Endpoints by wordlist, with other verbs
ffuf -u "<SCHEME>://<VHOST>/api/FUZZ" -X POST -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -mc all -fc 404 -ac -t 10 -o recon/ffuf-api-post-<VHOST> -of all
```

---

## CMS

Kali is offline: wpscan has no vulnerability database or API token, so pair every version with searchsploit. Always add `--no-update`.

```bash
# WordPress
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -e u,ap,at -o recon/wpscan-<VHOST>.txt
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -e vp,vt --plugins-detection mixed
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks --passwords /usr/share/wordlists/rockyou.txt -U <USER> --max-threads 5
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks --random-user-agent -e u    # when a plain UA is blocked
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks --cookie-string "<COOKIE>" -e ap    # authenticated

# WordPress by hand
curl -sk "<SCHEME>://<VHOST>/wp-json/wp/v2/users" | grep -Eo '"slug":"[^"]+"'
for i in 1 2 3 4 5; do curl -sk -o /dev/null -w "$i %{http_code} %{redirect_url}\n" "<SCHEME>://<VHOST>/?author=$i"; done    # redirect shows the username
curl -sk "<SCHEME>://<VHOST>/wp-content/plugins/" | grep -io 'href="[^"]*/"'                   # directory listing of plugins
curl -sk "<SCHEME>://<VHOST>/wp-content/plugins/<PLUGIN>/readme.txt" | grep -i "stable tag"    # plugin version
curl -sk "<SCHEME>://<VHOST>/xmlrpc.php" -d '<methodCall><methodName>system.listMethods</methodName></methodCall>'

# Joomla
joomscan -u "<SCHEME>://<VHOST>/" -ec | tee recon/joomscan-<VHOST>.txt
curl -sk "<SCHEME>://<VHOST>/administrator/manifest/files/joomla.xml" | grep -i "<version>"
curl -sk "<SCHEME>://<VHOST>/language/en-GB/en-GB.xml" | grep -i "<version>"
curl -sk -o /dev/null -w "%{http_code}\n" "<SCHEME>://<VHOST>/administrator/"
curl -sk "<SCHEME>://<VHOST>/" | grep -io 'name="generator"[^>]*'

# Drupal
curl -sk "<SCHEME>://<VHOST>/CHANGELOG.txt" | head -5
curl -sk "<SCHEME>://<VHOST>/core/CHANGELOG.txt" | head -5        # Drupal 8 and later
droopescan scan drupal -u "<SCHEME>://<VHOST>/"                   # if installed
```

Other generic CMS scanners, if installed: `cmsmap`, `whatweb -a 3`.

---

## Authenticated scans

Use these once you hold a session cookie. Compare against the unauthenticated run with the `comm` line in the checklist (block K).

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e <EXT> -H "Cookie: <COOKIE>" -mc all -fc 404 -ac -t 10 -o recon/ffuf-dirs-auth-<VHOST> -of all
feroxbuster -u "<SCHEME>://<VHOST>/" -w dirs.txt -H "Cookie: <COOKIE>" -t 10 -k --no-state -o recon/ferox-auth-<VHOST>.txt
wfuzz -c -t 10 --hc 404 -b "<COOKIE>" -w dirs.txt "<SCHEME>://<VHOST>/FUZZ"
gobuster dir -u "<SCHEME>://<VHOST>/" -w dirs.txt -c "<COOKIE>" -t 10 -k
curl -sk -i -H "Cookie: <COOKIE>" "<SCHEME>://<VHOST>/<PATH>"
```

A bearer token goes in the same place: `-H "Authorization: Bearer <TOKEN>"`.

---

## Reading output

```bash
# ffuf csv: 1 FUZZ, 2 url, 3 redirect, 4 position, 5 status, 6 size
awk -F, 'NR>1 && $5==200 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv
awk -F, 'NR>1 && $5~/^(200|301|302)$/ {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv
awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv | sort -n
awk -F, 'NR>1 {print $5}' recon/ffuf-dirs-<VHOST>.csv | sort | uniq -c        # count by status
awk -F, 'NR>1 {print $1,$5,$6}' recon/ffuf-vhosts-<DOMAIN>.csv                 # vhost and parameter names are in $1

# nmap
grep -E "open" recon/nmap-full-<IP>.txt
grep -E "^[0-9]+/tcp +open +(ssl/)?http" recon/nmap-full-<IP>.txt | cut -d/ -f1 | paste -sd,      # <WEB_PORTS>
grep "|" recon/nmap-http-<IP>.txt                                                                 # script output

# nikto, wpscan, general
grep "^+" recon/nikto-<VHOST>-<PORT>.txt
grep -E "\[\+\]|\[!\]" recon/wpscan-<VHOST>.txt
grep -rniE "password|passwd|secret|api_key|token" recon/                       # anything sensitive in saved output
```

---

## Host discovery (only when the scope lists a subnet)

```bash
sudo nmap -sn <SUBNET> -oN recon/nmap-pingsweep.txt
nmap -sn -T4 <SUBNET> -oG - | awk '/Up$/{print $2}' > recon/live_hosts.txt
sudo arp-scan -I eth0 <SUBNET> > recon/arp-scan.txt
ip -br -c a; ip route; ip neighbour            # your own addresses and routes, when the network setup is unclear
```

---

## Metasploit auxiliary recon **[optional]**

```text
msfconsole -q
use auxiliary/scanner/http/http_version     # set RHOSTS <IP>, set RPORT <PORT>, run
use auxiliary/scanner/http/http_header
use auxiliary/scanner/http/robots_txt
use auxiliary/scanner/http/dir_scanner
use auxiliary/scanner/http/files_dir
```
