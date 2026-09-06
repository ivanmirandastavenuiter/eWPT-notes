### Nmap

**Description:** Network exploration tool and security port scanner used to discover active services.

* **Target:** Fast scan of the 100 most common ports.
```bash
nmap -F <TARGET_IP>

```


* **Target:** Full TCP port scan with service version detection and default scripts (optimal for async background running).
```bash
nmap -sC -sV -p- --min-rate 1000 <TARGET_IP>

```


* **Target:** Discover web applications hiding on non-standard ports.
```bash
nmap -p 80,443,8000,8080,8443,8888 -sV <TARGET_IP>

```


* **Target:** Run automated HTTP enumeration scripts to find common web directories.
```bash
nmap -sV -p 80,443 --script=http-enum <TARGET_IP>

```



---

### ffuf (Fuzz Faster U Fool)

**Description:** Extremely fast web fuzzer written in Go, ideal for directory brute-forcing and virtual host discovery.

* **Target:** Discover hidden directories and administrative panels, filtering out 404 responses.
```bash
ffuf -u http://<TARGET_IP>/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403

```


* **Target:** Discover virtual hosts (VHosts) by fuzzing the HTTP Host header (filter by the default response size to exclude false positives).
```bash
ffuf -u http://<TARGET_IP> -H "Host: FUZZ.<DOMAIN>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs <DEFAULT_RESPONSE_SIZE>

```


* **Target:** Fuzz for backup and temporary files by appending extensions to a known file.
```bash
ffuf -u http://<TARGET_IP>/index.phpFUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e .bak,.old,.swp,.tmp,~

```



---

### Gobuster

**Description:** Tool used to brute-force URIs (directories and files) and DNS subdomains.

* **Target:** Standard directory brute-forcing while explicitly blacklisting unhelpful status codes.
```bash
gobuster dir -u http://<TARGET_IP> -w /usr/share/wordlists/dirb/common.txt -b 403,404

```


* **Target:** Search for specific file extensions (e.g., config files, backups, or scripts).
```bash
gobuster dir -u http://<TARGET_IP> -w /usr/share/wordlists/dirb/common.txt -x php,txt,bak,old

```



---

### cURL

**Description:** Command-line tool to transfer data to or from a server, excellent for raw HTTP request manipulation.

* **Target:** Fetch HTTP headers only to fingerprint the server (`Server`, `X-Powered-By`).
```bash
curl -I -s http://<TARGET_IP>

```


* **Target:** Determine enabled HTTP methods by inspecting the `Allow` header.
```bash
curl -X OPTIONS -I http://<TARGET_IP>

```


* **Target:** Test HTTP verb tampering (e.g., attempting to bypass a GET restriction by sending a POST).
```bash
curl -X POST http://<TARGET_IP>/admin

```



---

### WhatWeb

**Description:** Next-generation web scanner used for fingerprinting web technologies, CMS platforms, and underlying frameworks.

* **Target:** Standard tech stack fingerprinting.
```bash
whatweb http://<TARGET_IP>

```


* **Target:** Verbose fingerprinting to extract detailed plugin versions, email addresses, and header data.
```bash
whatweb -v http://<TARGET_IP>

```



---

### testssl.sh

**Description:** Command-line tool that checks a server's service on any port for the support of TLS/SSL ciphers and cryptographic flaws.

* **Target:** Full SSL/TLS audit for weak ciphers and certificate misconfigurations.
```bash
testssl.sh https://<TARGET_IP>

```


* **Target:** Extract Subject Alternative Names (SANs) from the certificate to discover associated subdomains.
```bash
testssl.sh -S https://<TARGET_IP>

```



---

### Dig

**Description:** Flexible tool for interrogating DNS name servers.

* **Target:** Attempt a DNS Zone Transfer (AXFR) to dump all domain records.
```bash
dig axfr @<TARGET_IP> <DOMAIN>

```


* **Target:** Query CNAME records to check for dangling pointers (Subdomain Takeover).
```bash
dig CNAME <SUBDOMAIN>

```


* **Target:** Perform a reverse DNS lookup to find the hostname associated with an IP.
```bash
dig -x <TARGET_IP>

```



---

### wafw00f

**Description:** Web Application Firewall (WAF) fingerprinting tool.

* **Target:** Identify if a WAF is protecting the target application and determine its vendor.
```bash
wafw00f http://<TARGET_IP>

```


* **Target:** Exhaustively test all known WAF signatures if the standard check is inconclusive.
```bash
wafw00f -a http://<TARGET_IP>

```



---

### Nikto

**Description:** Open-source web server scanner that performs comprehensive tests against web servers for multiple items, including outdated software and misconfigurations.

* **Target:** Quick, automated scan of a web server for low-hanging configuration flaws.
```bash
nikto -h http://<TARGET_IP>

```


* **Target:** Scan a specific virtual host mapped to the same IP.
```bash
nikto -h http://<TARGET_IP> -vhost <DOMAIN>

```



---

### Subzy

**Description:** Subdomain takeover vulnerability checker.

* **Target:** Automate the verification of CNAME dangling pointers across a list of discovered subdomains.
```bash
subzy run --targets subdomains.txt

```