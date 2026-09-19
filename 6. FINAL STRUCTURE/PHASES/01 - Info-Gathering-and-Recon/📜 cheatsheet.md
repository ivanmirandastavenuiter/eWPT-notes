# 📖 Phase 1 Cheatsheet: Information Gathering & Reconnaissance

Use `attacks_and_payloads.md` as your primary playbook.  
Use this cheatsheet as an **extensive fallback/dictionary** when you need extra variants or when the attacks file doesn’t cover a scenario directly. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

***

## 🔴 Active Nmap Port Scanning & NSE Web Scripts

**Priority:** 🔴 Async (Fire & Forget)  
**Use when:** You need broad or targeted port scans and HTTP‑specific NSE scripts beyond the base examples in `attacks_and_payloads.md`. [adhdecode](https://adhdecode.com/articles/nmap/nmap-http-enumeration-web-discovery/)
**Exam note:** Main Nmap commands live in `attacks_and_payloads.md`; treat this section as extended coverage.

### Base Scanning Profiles

_Core examples: see `attacks_and_payloads.md → Nmap`._

- **Fast scan (top 100 common ports):**
```bash
nmap -F <IP>
```

- **Full TCP port scan + default scripts + version detection:**
```bash
nmap -sC -sV -p- --min-rate 1000 <IP> \
  -oN recon/nmap-full.txt -oX recon/nmap-full.xml
```

- **No ping (host blocks ICMP):**
```bash
nmap -Pn -sC -sV <IP> \
  -oN recon/nmap-nopin.txt
```

- **Scan specific port ranges:**
```bash
nmap -sV -p 1-1024,8080,8443 <IP> \
  -oN recon/nmap-custom-ports.txt
```

- **UDP top ports (situational):**
```bash
sudo nmap -sU --top-ports 20 <IP> \
  -oN recon/nmap-udp-top.txt
```

- **Aggressive scan (OS, versions, scripts, traceroute):**
```bash
sudo nmap -A -T4 <IP> \
  -oN recon/nmap-aggressive.txt
```

- **Scan from host list file:**
```bash
nmap -sV -iL hosts.txt \
  -oN recon/nmap-hostlist.txt
```

### HTTP & Web‑Focused Scripts

- **Non‑standard web ports:**
```bash
nmap -p 80,443,8000,8080,8443,8888,9000,9443 -sV <IP> \
  -oN recon/nmap-web-ports.txt
```

- **HTTP enumeration bundle:**
```bash
nmap -sV -p 80,443 \
  --script=http-enum,http-title,http-methods,http-robots.txt \
  <IP> \
  -oN recon/nmap-http-enum.txt
```

- **Banner grabbing across open services:**
```bash
nmap -sV --script=banner <IP> \
  -oN recon/nmap-banner.txt
```

- **WebDAV & method checks:**
```bash
nmap -p 80,443 \
  --script=http-webdav-scan,http-methods \
  --script-args http-methods.url-path=/ \
  <IP> \
  -oN recon/nmap-webdav.txt
```

- **SSL/TLS version and cipher inspection:**
```bash
nmap -sV -p 443 \
  --script=ssl-enum-ciphers,ssl-cert \
  <IP> \
  -oN recon/nmap-ssl.txt
```

### Output & Performance Options

- **Machine‑readable output (grepable + XML):**
```bash
nmap -sV <IP> \
  -oG recon/nmap-grepable.txt \
  -oX recon/nmap.xml
```

- **Limit scan time:**
```bash
nmap -sV -p- --max-retries 2 --host-timeout 10m <IP>
```

***

## 🔴 Web Fuzzing, Directory & VHost Discovery

**Priority:** 🔴 Async (Fire & Forget)  
**Use when:** You need fuzzing variants beyond those in `attacks_and_payloads.md` (recursion, extra extensions, multi‑position wordlists, header fuzzing, parameter fuzzing). [cybercheatsheets](https://www.cybercheatsheets.org/en/tools/ffuf)
**Exam note:** All commands here use **low threads** (`-t 5` or `-t 10`) to protect the Guacamole environment. [hackerdna](https://hackerdna.com/courses/cheat-sheets/gobuster-cheat-sheet)

### ffuf – Advanced Usage

_Core workflows: see `attacks_and_payloads.md → ffuf`._

#### Directory & File Discovery

- **Standard directory scan:**
```bash
ffuf -u http://<IP>/FUZZ \
     -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
     -mc 200,301,302,403 \
     -t 10 \
     -o recon/ffuf-dirs.json -of json
```

- **Directories with multiple extensions:**
```bash
ffuf -u http://<IP>/FUZZ \
     -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt \
     -e .php,.html,.txt,.bak,.json \
     -mc 200,301,302,403 \
     -t 10 \
     -o recon/ffuf-dirs-ext.json -of json
```

- **Recursive directory search:**
```bash
ffuf -u http://<IP>/FUZZ \
     -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-small.txt \
     -recursion -recursion-depth 2 \
     -mc 200,301,302,403 \
     -t 10 \
     -o recon/ffuf-recursive.json -of json
```

#### Virtual Host & Subdomain Discovery

- **Baseline soft‑404 response length:**
```bash
curl -sk "http://<IP>/" -H "Host: invalid123.<DOMAIN>" | wc -c
# -> <BASELINE_LENGTH>
```

- **VHost fuzzing (Host header):**
```bash
ffuf -u http://<IP>/ \
     -H "Host: FUZZ.<DOMAIN>" \
     -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -fs <BASELINE_LENGTH> \
     -t 10 \
     -o recon/ffuf-vhosts.json -of json
```

- **Auto‑calibrate filtering (ffuf auto‑calibrate):** [purplesec](https://purplesec.org/knowledge-base/web-attacks/ffuf/cheatsheet/)
```bash
ffuf -u http://<IP>/ \
     -H "Host: FUZZ.<DOMAIN>" \
     -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -ac \
     -t 10 \
     -o recon/ffuf-vhosts-ac.json -of json
```

#### Backup & Temp Files

- **Backup and swap file hunting:**
```bash
ffuf -u http://<IP>/index.phpFUZZ \
     -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt \
     -e .bak,.old,.swp,.tmp,~,.zip \
     -t 10 \
     -o recon/ffuf-backups.json -of json
```

#### Parameter & Value Fuzzing

- **GET parameter names:** [cybercheatsheets](https://www.cybercheatsheets.org/en/tools/ffuf)
```bash
ffuf -u "http://<IP>/search.php?FUZZ=test" \
     -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
     -fc 404 \
     -t 5 \
     -o recon/ffuf-get-params.json -of json
```

- **POST form parameter names:**
```bash
ffuf -u http://<IP>/login.php \
     -X POST \
     -d "FUZZ=test" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -fc 404 \
     -t 5 \
     -o recon/ffuf-post-params.json -of json
```

- **POST JSON API parameter values:** [cybercheatsheets](https://www.cybercheatsheets.org/en/tools/ffuf)
```bash
ffuf -u https://<VHOST>/api \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{"user":"FUZZ"}' \
     -w users.txt:FUZZ \
     -mc 200,401 \
     -t 5 \
     -o recon/ffuf-json-values.json -of json
```

#### Multi‑Position Wordlists & Headers

- **Multiple positions (path components):** [phrack](https://www.phrack.me/tools/2022/07/06/Ffuf-cheatsheet.html)
```bash
ffuf -u http://<IP>/FUZZ1/FUZZ2 \
     -w dirs.txt:FUZZ1 \
     -w files.txt:FUZZ2 \
     -mc 200,301,302 \
     -t 5 \
     -o recon/ffuf-multipos.json -of json
```

- **Header fuzzing (e.g., `X-Original-URL` or `X-Forwarded-For`):**
```bash
ffuf -u http://<IP>/ \
     -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt:FUZZ \
     -H "FUZZ: test" \
     -mc 200,302,403 \
     -t 5 \
     -o recon/ffuf-header-fuzz.json -of json
```

#### Filters, Output & Proxy

- **Filter by status / size / words / lines:** [purplesec](https://purplesec.org/knowledge-base/web-attacks/ffuf/cheatsheet/)
```bash
ffuf -u http://<IP>/FUZZ \
     -w dirs.txt \
     -fs 1234 -fw 12 -fl 10 -fc 404 \
     -t 10 \
     -o recon/ffuf-filtered.json -of json
```

- **Proxy and delay:** [cybercheatsheets](https://www.cybercheatsheets.org/en/tools/ffuf)
```bash
ffuf -u http://<IP>/FUZZ \
     -w dirs.txt \
     -t 10 -p 0.5 \
     -x http://127.0.0.1:8080 \
     -o recon/ffuf-proxy.json -of json
```

- **Replay through proxy (Burp):** [phrack](https://www.phrack.me/tools/2022/07/06/Ffuf-cheatsheet.html)
```bash
ffuf -u http://<IP>/FUZZ \
     -w dirs.txt \
     -replay-proxy http://127.0.0.1:8080 \
     -t 10 \
     -o recon/ffuf-replay.json -of json
```

***

### Gobuster – Advanced Usage

_Core workflows: see `attacks_and_payloads.md → Gobuster`._

#### Directory Mode (`dir`)

- **Basic directory brute force:** [lazyhackers](https://lazyhackers.in/cheatsheets.php?slug=gobuster-directory-dns-brute-force)
```bash
gobuster dir -u http://<IP>/ \
  -w /usr/share/wordlists/dirb/common.txt \
  -t 10 \
  -o recon/gobuster-dir.txt
```

- **With file extensions:**
```bash
gobuster dir -u http://<IP>/ \
  -w /usr/share/wordlists/dirb/common.txt \
  -x php,html,txt,bak,zip \
  -t 10 \
  -o recon/gobuster-dir-ext.txt
```

- **Include specific status codes:**
```bash
gobuster dir -u http://<IP>/ \
  -w dirs.txt \
  -s 200,301,302 \
  -t 10 \
  -o recon/gobuster-dir-status.txt
```

- **Blacklist status codes (hide 403/404):**
```bash
gobuster dir -u http://<IP>/ \
  -w dirs.txt \
  -b 403,404 \
  -t 10 \
  -o recon/gobuster-dir-blacklist.txt
```

- **With cookies & headers (auth context):** [netwerklabs](https://netwerklabs.com/gobuster-cheat-sheet/)
```bash
gobuster dir -u http://<VHOST>/ \
  -w dirs.txt \
  -c "session=<COOKIE>" \
  -H "Authorization: Bearer <TOKEN>" \
  -t 10 \
  -o recon/gobuster-dir-auth.txt
```

- **Through Burp proxy:** [lazyhackers](https://lazyhackers.in/cheatsheets.php?slug=gobuster-directory-dns-brute-force)
```bash
gobuster dir -u http://<VHOST>/ \
  -w dirs.txt \
  -p http://127.0.0.1:8080 \
  -t 10 \
  -o recon/gobuster-dir-proxy.txt
```

#### DNS Mode (`dns`)

- **DNS subdomain enumeration:** [cybercheatsheets](https://www.cybercheatsheets.org/en/tools/gobuster)
```bash
gobuster dns -d <DOMAIN> \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -t 10 \
  -o recon/gobuster-dns.txt
```

- **Show IP addresses and CNAME (takeover hints):** [3os](https://3os.org/penetration-testing/cheatsheets/gobuster-cheatsheet/)
```bash
gobuster dns -d <DOMAIN> \
  -w subdomains.txt \
  --show-ips --show-cname \
  -t 10 \
  -o recon/gobuster-dns-ips-cname.txt
```

- **Use custom DNS resolver:** [netwerklabs](https://netwerklabs.com/gobuster-cheat-sheet/)
```bash
gobuster dns -d <DOMAIN> \
  -w subdomains.txt \
  -r 8.8.8.8 \
  -t 10 \
  -o recon/gobuster-dns-resolver.txt
```

#### VHost Mode (`vhost`)

- **Basic vhost scan:** [cybercheatsheets](https://www.cybercheatsheets.org/en/tools/gobuster)
```bash
gobuster vhost -u http://<IP>/ \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -t 10 \
  -o recon/gobuster-vhost.txt
```

- **Append domain to wordlist entries:** [3os](https://3os.org/penetration-testing/cheatsheets/gobuster-cheatsheet/)
```bash
gobuster vhost -u http://<IP>/ \
  -w vhosts.txt \
  --append-domain \
  -t 10 \
  -o recon/gobuster-vhost-append.txt
```

- **Exclude responses of a given length:** [lazyhackers](https://lazyhackers.in/cheatsheets.php?slug=gobuster-directory-dns-brute-force)
```bash
gobuster vhost -u http://<IP>/ \
  -w vhosts.txt \
  --exclude-length 1234 \
  -t 10 \
  -o recon/gobuster-vhost-exclen.txt
```

***

## 🔴 DNS Enumeration & Zone Transfers

**Priority:** 🔴 Async (Fire & Forget)  
**Use when:** WSTG‑CONF‑01/INFO‑04 tests or exam hints mention DNS, domains, or subdomains. [owasp](https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/)
**Exam note:** Attempt AXFR once per domain; if it fails, don’t sink time into it.

### Host Resolution & Reverse Lookups

- **A record lookup:**
```bash
host <DOMAIN>
dig <DOMAIN> +short
```

- **Reverse lookup (IP → hostname):**
```bash
dig -x <IP> +short
host <IP>
```

- **Add mapping to `/etc/hosts`:**
```bash
echo "<IP> <HOST>" | sudo tee -a /etc/hosts
```

### Record Type Queries

- **Common record types:**
```bash
dig <DOMAIN> A
dig <DOMAIN> AAAA
dig <DOMAIN> MX
dig <DOMAIN> NS
dig <DOMAIN> TXT
dig <DOMAIN> SOA
dig <DOMAIN> ANY
```

- **SPF & DMARC (TXT):**
```bash
dig TXT <DOMAIN> +short
dig TXT _dmarc.<DOMAIN> +short
```

### Zone Transfer (AXFR)

- **Get authoritative nameservers:**
```bash
dig NS <DOMAIN> +short
```

- **Attempt AXFR against nameserver:**
```bash
dig axfr @<NAMESERVER> <DOMAIN> \
  > recon/dns-zone-transfer.txt
```

- **Reverse zone transfer over IP range:**
```bash
dig axfr -x 192.168 @<NAMESERVER> \
  > recon/dns-reverse-axfr.txt
```

### Automated DNS Enum Tools (Optional)

_May not be installed; treat as bonus._

- **dnsrecon baseline:**
```bash
dnsrecon -d <DOMAIN> \
  -o recon/dnsrecon.json
```

- **dnsenum with brute force:**
```bash
dnsenum <DOMAIN> \
  --threads 5 \
  --dnsserver <NAMESERVER> \
  --enum \
  --out recon/dnsenum.xml
```

- **fierce scanner:**
```bash
fierce --domain <DOMAIN> \
  --subdomain-file /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  --output recon/fierce.txt
```

***

## 🔴 Automated Vulnerability Scanners & Metasploit Modules

**Priority:** 🔴 Async (Fire & Forget)  
**Use when:** You want automated sweeps beyond manual inspection. [cirt](https://cirt.net/nikto/)
**Exam note:** Use Nikto as the core; Metasploit recon is optional.

### Nikto – More Options

_Core workflows: see `attacks_and_payloads.md → Nikto`._

- **Standard scan:**
```bash
nikto -h http://<VHOST>/ \
      -o recon/nikto-standard.txt \
      -Format txt
```

- **Low‑noise misconfig/info‑disclosure tuning:**
```bash
nikto -h http://<VHOST>/ \
      -Tuning 23 \
      -o recon/nikto-low-noise.txt \
      -Format txt
```

- **Specific port & SSL:**
```bash
nikto -h http://<VHOST>/ \
      -p 80,443,8080,8443 \
      -ssl \
      -o recon/nikto-ports-ssl.txt \
      -Format txt
```

- **Custom user‑agent / header:**
```bash
nikto -h http://<VHOST>/ \
      -useragent "Mozilla/5.0 (Nikto)" \
      -o recon/nikto-ua.txt \
      -Format txt
```

- **Proxy + cookie (through Burp):**
```bash
nikto -h http://<VHOST>/ \
      -useproxy http://127.0.0.1:8080 \
      -cookie "session=<COOKIE>" \
      -o recon/nikto-proxy.txt \
      -Format txt
```

### Metasploit Auxiliary Recon (Optional)

- **Start Metasploit:**
```bash
msfconsole -q
```

- **HTTP version scanner:**
```text
use auxiliary/scanner/http/http_version
set RHOSTS <IP>
run
```

- **HTTP headers scanner:**
```text
use auxiliary/scanner/http/http_header
set RHOSTS <IP>
run
```

- **robots.txt extractor:**
```text
use auxiliary/scanner/http/robots_txt
set RHOSTS <IP>
run
```

- **Directory brute‑forcer:**
```text
use auxiliary/scanner/http/brute_dirs
set RHOSTS <IP>
run
```

***

## 🔴 Active Probing, Netcat & TLS/SSL Audit

**Priority:** 🔴 Async (or quick manual probes)  
**Use when:** You need low‑level banner/TLS inspection beyond Nmap/testssl. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

### Netcat

- **Plain banner grab:**
```bash
nc -v <IP> <PORT>
```

- **Zero‑I/O port check:**
```bash
nc -zv <IP> <PORT>
```

- **Scan port range:**
```bash
nc -zvw10 <IP> 20-80
```

- **Send raw HTTP request:**
```bash
printf "GET / HTTP/1.1\r\nHost: <VHOST>\r\n\r\n" | nc -v <IP> <PORT>
```

### OpenSSL s_client

- **Basic TLS handshake:**
```bash
openssl s_client -connect <HOST>:<PORT>
```

- **Specify SNI hostname:**
```bash
openssl s_client -connect <IP>:443 -servername <HOST>
```

- **Full certificate text:**
```bash
openssl s_client -connect <HOST>:443 2>/dev/null | openssl x509 -noout -text
```

- **Show protocol/cipher negotiated:**
```bash
openssl s_client -connect <HOST>:443 | grep "Protocol\|Cipher"
```

### testssl.sh (extra flags)

_Core: see `attacks_and_payloads.md → testssl.sh`._

- **Full scan:**
```bash
testssl.sh https://<HOST>:<PORT> \
  > recon/testssl-full.txt
```

- **SANs only:**
```bash
testssl.sh -S https://<HOST>:<PORT> \
  > recon/testssl-sans.txt
```

- **Specific vulnerability checks:**
```bash
testssl.sh -U https://<HOST>:<PORT> \
  > recon/testssl-vulns.txt
```

- **Fast, minimal checks (e.g., supported protocols):**
```bash
testssl.sh --fast https://<HOST>:<PORT> \
  > recon/testssl-fast.txt
```

***

## 🟡 Tech Stack Fingerprinting, WAF & Method Testing

**Priority:** 🟡 Mandatory Manual Recon  
**Use when:** Fingerprinting stacks, understanding WAF behavior, and mapping HTTP verbs. [darknet.org](https://www.darknet.org.uk/2016/05/wafw00f-fingerprint-identify-web-application-firewall-waf-products/)

### WhatWeb – Extra Variants

_Core: see `attacks_and_payloads.md → WhatWeb`._

- **Standard tech stack:**
```bash
whatweb http://<VHOST>/ \
  > recon/whatweb.txt
```

- **Verbose with plugin and email extraction:**
```bash
whatweb -v http://<VHOST>/ \
  > recon/whatweb-verbose.txt
```

- **Aggressive plugin search:**
```bash
whatweb -a 3 http://<VHOST>/ \
  > recon/whatweb-aggressive.txt
```

### wafw00f – Extra Options

_Core: see `attacks_and_payloads.md → wafw00f`._

- **Basic WAF detection:**
```bash
wafw00f http://<VHOST>/ \
  > recon/wafw00f.txt
```

- **All signatures:**
```bash
wafw00f -a http://<VHOST>/ \
  > recon/wafw00f-all.txt
```

- **Multiple targets from file (if supported in environment):**
```bash
wafw00f -i urls.txt \
  > recon/wafw00f-bulk.txt
```

### cURL – Manual Probing

_Core: see `attacks_and_payloads.md → cURL`._

- **Headers only:**
```bash
curl -sk -I "http://<VHOST>:<PORT>/"
```

- **Trigger error pages:**
```bash
curl -sk -i "http://<VHOST>:<PORT>/nonexistent_test_page_123"
```

- **Metafiles:**
```bash
curl -sk "http://<VHOST>/robots.txt"        > recon/robots.txt
curl -sk "http://<VHOST>/sitemap.xml"      > recon/sitemap.xml
curl -sk "http://<VHOST>/.well-known/security.txt" > recon/security.txt
curl -sk "http://<VHOST>/crossdomain.xml"  > recon/crossdomain.xml
curl -sk "http://<VHOST>/humans.txt"       > recon/humans.txt
```

### HTTP Method Testing

_Core: see `attacks_and_payloads.md → HTTP methods`._

- **Global OPTIONS:**
```bash
curl -sk -i -X OPTIONS "http://<VHOST>:<PORT>/"
```

- **OPTIONS on restricted paths:**
```bash
curl -sk -i -X OPTIONS "http://<VHOST>:<PORT>/admin"
```

- **PUT / DELETE / TRACE tests:**
```bash
curl -sk -i -X PUT "http://<VHOST>/uploads/test.txt" -d "test content"
curl -sk -i -X DELETE "http://<VHOST>/uploads/test.txt"
curl -sk -i -X TRACE "http://<VHOST>/"
```

- **Authenticated method test (include cookies):**
```bash
curl -sk -i -X POST \
  -b "session=<COOKIE>" \
  "http://<VHOST>/admin"
```

***

## 🟡 Passive OSINT & Attack Surface Discovery

**Priority:** 🟡 Manual (when OSINT is in scope)  
**Use when:** WSTG‑INFO‑01 tasks or questions explicitly mention OSINT or external discovery. [security.furybee](https://security.furybee.org/articles/modern-osint-tools/)

### WHOIS & Registration

- **Domain WHOIS:**
```bash
whois <DOMAIN>
```

- **IP WHOIS:**
```bash
whois <IP>
```

### Google Dorks (extended)

- Administrative portals:  
  `site:<DOMAIN> inurl:admin OR inurl:login OR inurl:controlpanel`  
- Backups/config files:  
  `site:<DOMAIN> ext:log OR ext:env OR ext:bak OR ext:conf OR ext:swp`  
- Indexable directories:  
  `site:<DOMAIN> intitle:"index of"`  
- Docs:  
  `site:<DOMAIN> filetype:pdf OR filetype:docx OR filetype:xlsx`  
- API endpoints:  
  `site:<DOMAIN> "api" "v1" OR "v2"`  

### Shodan (Optional)

_May not be available in exam; treat as bonus OSINT tool. _ [security.furybee](https://security.furybee.org/articles/modern-osint-tools/)

- **Search by IP:**
```bash
shodan host <IP>
```

- **Search by domain:**
```bash
shodan domain <DOMAIN>
```

### theHarvester (Optional)

- **Gather emails, hosts, and subdomains:**
```bash
theHarvester -d <DOMAIN> -b all -l 500 \
  -f recon/theharvester.html
```

### Amass (Optional but powerful) [security.furybee](https://security.furybee.org/articles/modern-osint-tools/)

- **Passive domain enumeration:**
```bash
amass enum -passive -d <DOMAIN> \
  -o recon/amass-passive.txt
```

- **Active enumeration:**
```bash
amass enum -active -d <DOMAIN> -src \
  -o recon/amass-active.txt
```

- **Infrastructure intel (WHOIS, netblocks):**
```bash
amass intel -whois -d <DOMAIN> \
  -o recon/amass-intel.txt
```

***

## 🟡 Network Interfaces, Routing & Socket Analysis

**Priority:** 🟡 Manual (host awareness)  
**Use when:** You need to understand the lab environment’s network configuration. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

### Interfaces & Addresses

- **Compact view:**
```bash
ip -br -c a
```

- **Detailed view:**
```bash
ip a
ifconfig
```

- **Interface statistics:**
```bash
ip -s link
```

### Routing & Neighbors

- **Routing table:**
```bash
ip route
netstat -r
route print
```

- **ARP/neighbor table:**
```bash
ip neighbour
arp -a
```

### Sockets & Listening Ports

- **Listening ports (TCP/UDP):**
```bash
netstat -tulpn
ss -tnl
```

- **All TCP sockets (established + listening):**
```bash
ss -tp
netstat -tunp
```

- **Processes using network sockets:**
```bash
lsof -n -i4TCP -i4UDP
```

***

## ⚪ Host Discovery & Subnet Mapping

**Priority:** ⚪ Extra / Situational  
**Use when:** Scope includes multiple hosts or a subnet. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

### Ping Sweeps

- **ICMP sweep:**
```bash
sudo nmap -sn <IP/SUBNET> \
  -oN recon/nmap-pingsweep.txt
```

- **Extract live hosts:**
```bash
nmap -sn -T4 <IP/SUBNET> -oG - | awk '/Up$/{print $2}' > live_hosts.txt
```

### ARP & Local Discovery

- **ARP scan:**
```bash
sudo arp-scan -I eth0 <IP/SUBNET> \
  > recon/arp-scan.txt
```

- **Netdiscover:**
```bash
netdiscover -i eth0 -r <IP/SUBNET> \
  > recon/netdiscover.txt
```

### Traceroute

- **Linux traceroute:**
```bash
traceroute <HOST>
```

- **Windows traceroute:**
```bash
tracert <HOST>
```

***

## ⚪ Subdomain Takeover Checking

**Priority:** ⚪ Extra / Situational  
**Use when:** DNS points to cloud providers or dangling records. [trickest](https://trickest.com/tools/subzy)

_Core workflows: see `attacks_and_payloads.md → Subzy`._

- **Subzy scan (conservative concurrency):**
```bash
subzy run --targets subdomains.txt \
          --concurrency 20 \
          --hide_fails \
          --output recon/subzy-results.txt
```

- **Manual CNAME verification:**
```bash
dig CNAME <SUBDOMAIN> +short \
  > recon/dns-cname-<SUBDOMAIN>.txt
```

***

## ⚪ Site Mirroring, Screenshots & Terminal Browsers

**Priority:** ⚪ Extra / Situational  
**Use when:** You want offline copies or visual reports. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

### HTTrack (Optional)

- **Mirror site:**
```bash
httrack http://<VHOST>/ -O ./mirrored_site/
```

### EyeWitness (Optional)

- **Screenshots and HTML report:**
```bash
eyewitness --web -f domains.txt -d ./eyewitness_report/
```

### Terminal Browsers (Optional)

- **Lynx:**
```bash
lynx http://<VHOST>/
```

- **Browsh:**
```bash
browsh --startup-url http://<VHOST>/
```

***

## ⚪ CMS‑Specific Reconnaissance (WordPress & Drupal)

**Priority:** ⚪ Extra / Situational  
**Use when:** Stack fingerprints clearly show WordPress/Drupal. [owasp](https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/01-Information_Gathering/)

### WordPress

- **WPScan (if installed):**
```bash
wpscan --url http://<VHOST>/ -e u,vp,vt \
       --api-token <TOKEN> \
       --output recon/wpscan.txt
```

- **Author enum via `?author=`:**
```bash
curl -sk -I "http://<VHOST>/?author=1"
```

- **REST API users:**
```bash
curl -sk "http://<VHOST>/wp-json/wp/v2/users"
```

- **Common WP endpoints:**
```bash
curl -sk "http://<VHOST>/wp-login.php"
curl -sk "http://<VHOST>/xmlrpc.php"
curl -sk "http://<VHOST>/wp-admin/"
```

### Drupal

- **Droopescan (if installed):**
```bash
droopescan scan drupal -u http://<VHOST>/ \
  > recon/droopescan.txt
```

- **Drupal CHANGELOG:**
```bash
curl -sk "http://<VHOST>/CHANGELOG.txt" | head -n 5
```

- **Node probing:**
```bash
curl -sk "http://<VHOST>/node/1"
curl -sk "http://<VHOST>/node/2"
```