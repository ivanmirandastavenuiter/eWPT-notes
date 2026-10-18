# 📜 Phase 1 Cheatsheet: Fallback Variants

**Primary playbook:** [📋 checklist-and-commands.md](<./📋 checklist-and-commands.md>). Use this file only when the primary commands don't fit: a different flag, a filter, a proxy, or an optional tool.

Placeholders and output naming follow the checklist (`<IP>`, `<DOMAIN>`, `<VHOST>`, `<SCHEME>`, `<PORT>`, `<BASELINE>`, `<COOKIE>`, `<PROXY>` = `127.0.0.1:8080`, `<SUBNET>`). Save output under `recon/`. Keep ffuf/gobuster at `-t 5` to `-t 10`.

Tools marked **[optional]** may not be on the exam Kali. Check them with the Phase 0 `command -v` line first.

---

## Nmap

```bash
# Top-100 ports, quick sanity check only
nmap -F -Pn <IP>

# Full TCP, no ping (host blocks ICMP)
nmap -Pn -sC -sV -p- --min-rate 1000 <IP> -oN recon/nmap-full-<IP>.txt

# Custom ranges and common alternate web ports
nmap -sV -p 1-1024,8000,8080,8443,8888,9000,9443 <IP> -oN recon/nmap-custom-<IP>.txt

# Aggressive (OS, versions, scripts, traceroute)
sudo nmap -A -T4 <IP> -oN recon/nmap-aggressive-<IP>.txt

# UDP top ports (situational, needs root)
sudo nmap -sU --top-ports 20 <IP> -oN recon/nmap-udp-<IP>.txt

# Target list from file
nmap -sV -iL hosts.txt -oN recon/nmap-hosts.txt

# Scripts: banners, WebDAV/methods, TLS ciphers
nmap -sV -p <WEB_PORTS> --script=banner <IP> -oN recon/nmap-banner-<IP>.txt
nmap -p <WEB_PORTS> --script=http-webdav-scan,http-methods --script-args http-methods.url-path=/ <IP> -oN recon/nmap-webdav-<IP>.txt
nmap -sV -p 443 --script=ssl-enum-ciphers,ssl-cert <IP> -oN recon/nmap-ssl-<IP>.txt

# Grepable output and a time cap
nmap -sV -p- --max-retries 2 --host-timeout 10m -oG recon/nmap-grep-<IP>.txt <IP>
```

---

## ffuf

Output is `-of md` for readability. Switch to `-of json` only if you need to script over the results.

```bash
# Backup-style suffix on a known page (index.phpFUZZ)
ffuf -u "<SCHEME>://<VHOST>/index.phpFUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e .bak,.old,.swp,~ -mc 200 -fs <BASELINE> -t 10 -of md -o recon/ffuf-bak-<VHOST>.md

# Recursive, depth 2
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-small.txt -recursion -recursion-depth 2 -mc 200,301,302,403 -t 10 -of md -o recon/ffuf-recursive-<VHOST>.md

# Auto-calibrate instead of a manual baseline (use when the size filter is unclear)
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -ac -t 10 -of md -o recon/ffuf-ac-<VHOST>.md

# Two-position fuzzing (path components)
ffuf -u "<SCHEME>://<VHOST>/FUZZ1/FUZZ2" -w dirs.txt:FUZZ1 -w files.txt:FUZZ2 -mc 200,301,302 -t 5 -of md -o recon/ffuf-multipos-<VHOST>.md

# Header names (X-Original-URL, X-Forwarded-For, ...)
ffuf -u "<SCHEME>://<VHOST>/" -H "FUZZ: test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc 200,302,403 -t 5 -of md -o recon/ffuf-headers-<VHOST>.md

# Combined filters (read the values from a baseline, never copy them)
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w dirs.txt -fs <BASELINE> -fw <WORDS> -fl <LINES> -fc 404 -t 10 -of md -o recon/ffuf-filtered-<VHOST>.md

# JSON API value fuzzing
ffuf -u "<SCHEME>://<VHOST>/api" -X POST -H "Content-Type: application/json" -d '{"user":"FUZZ"}' -w users.txt -mc 200,401 -t 5 -of md -o recon/ffuf-json-<VHOST>.md

# Through Burp: delay and proxy, or replay matched hits into Burp
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w dirs.txt -p 0.5 -x http://<PROXY> -t 10 -of md -o recon/ffuf-proxy-<VHOST>.md
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w dirs.txt -replay-proxy http://<PROXY> -t 10 -of md -o recon/ffuf-replay-<VHOST>.md
```

---

## gobuster

```bash
# Only show chosen status codes
gobuster dir -u "<SCHEME>://<VHOST>/" -w dirs.txt -s 200,301,302 -t 10 -o recon/gobuster-status-<VHOST>.txt

# Through Burp
gobuster dir -u "<SCHEME>://<VHOST>/" -w dirs.txt -p http://<PROXY> -t 10 -o recon/gobuster-proxy-<VHOST>.txt

# DNS subdomains with IPs and CNAMEs (takeover hints) and a fixed resolver
gobuster dns -d <DOMAIN> -w subdomains.txt --show-ips --show-cname -r <NAMESERVER> -t 10 -o recon/gobuster-dns-<DOMAIN>.txt

# VHost: append domain to entries, or drop responses of the baseline length
gobuster vhost -u "<SCHEME>://<IP>/" -w vhosts.txt --append-domain -t 10 -o recon/gobuster-vhost-append-<IP>.txt
gobuster vhost -u "<SCHEME>://<IP>/" -w vhosts.txt --exclude-length <BASELINE> -t 10 -o recon/gobuster-vhost-exclen-<IP>.txt
```

---

## DNS

Attempt AXFR once per domain. If it fails, move on.

```bash
host <DOMAIN>
dig <DOMAIN> +short
dig -x <IP> +short

# Common records, one at a time (ANY is often refused)
for t in A AAAA MX NS TXT SOA; do echo "== $t"; dig <DOMAIN> $t +short; done

# SPF and DMARC
dig TXT <DOMAIN> +short
dig TXT _dmarc.<DOMAIN> +short
```

**[optional]** DNS enumeration tools (install-dependent): `dnsrecon -d <DOMAIN> -o recon/dnsrecon-<DOMAIN>.json`, `dnsenum <DOMAIN> --dnsserver <NAMESERVER> --enum --out recon/dnsenum-<DOMAIN>.xml`.

---

## Nikto

```bash
# Low-noise, misconfiguration and information disclosure only
nikto -h "<SCHEME>://<VHOST>/" -Tuning 23 -o recon/nikto-lownoise-<VHOST>.txt -Format txt

# Custom user agent
nikto -h "<SCHEME>://<VHOST>/" -useragent "Mozilla/5.0 (Nikto)" -o recon/nikto-ua-<VHOST>.txt -Format txt
```

---

## TLS & Raw Probes

```bash
# Handshake with SNI
openssl s_client -connect <IP>:443 -servername <DOMAIN>

# Full certificate text
openssl s_client -connect <DOMAIN>:443 -servername <DOMAIN> 2>/dev/null | openssl x509 -noout -text

# Netcat: open check, port range, raw HTTP request
nc -zv <IP> <PORT>
nc -zvw10 <IP> 20-80
printf "GET / HTTP/1.1\r\nHost: <VHOST>\r\n\r\n" | nc -v <IP> <PORT>
```

---

## Fingerprinting & WAF

```bash
whatweb -a 3 "<SCHEME>://<VHOST>/" > recon/whatweb-aggressive-<VHOST>.txt
wafw00f -i urls.txt > recon/wafw00f-bulk.txt
```

---

## OSINT **[optional, only if in scope]**

Google dorks are in the checklist.

```bash
whois <DOMAIN>
whois <IP>
shodan host <IP>
shodan domain <DOMAIN>
theHarvester -d <DOMAIN> -b all -l 500 -f recon/theharvester-<DOMAIN>.html
```

---

## Kali Host Awareness (situational)

These describe the attacker machine, not the target. Use them only when the network setup is unclear.

```bash
ip -br -c a
ip route
ip neighbour
ss -tulpn
lsof -n -i4TCP -i4UDP
```

---

## Host Discovery (only when the scope lists a subnet)

```bash
sudo nmap -sn <SUBNET> -oN recon/nmap-pingsweep.txt
nmap -sn -T4 <SUBNET> -oG - | awk '/Up$/{print $2}' > recon/live_hosts.txt
sudo arp-scan -I eth0 <SUBNET> > recon/arp-scan.txt
traceroute <HOST>        # tracert on Windows
```

---

## Subdomain Takeover

```bash
dig CNAME <SUBDOMAIN> +short
```

---

## CMS (only when the fingerprint shows WordPress or Drupal)

```bash
# WordPress
wpscan --url "<SCHEME>://<VHOST>/" -e u,vp,vt --api-token <TOKEN> -o recon/wpscan-<VHOST>.txt
curl -sk "<SCHEME>://<VHOST>/wp-json/wp/v2/users"
curl -sk -I "<SCHEME>://<VHOST>/?author=1"

# Drupal
curl -sk "<SCHEME>://<VHOST>/CHANGELOG.txt" | head -5
```

---

## Metasploit Auxiliary Recon **[optional]**

```text
msfconsole -q
use auxiliary/scanner/http/http_version     # set RHOSTS <IP>, set RPORT <PORT>, run
use auxiliary/scanner/http/http_header
use auxiliary/scanner/http/robots_txt
use auxiliary/scanner/http/brute_dirs
```
