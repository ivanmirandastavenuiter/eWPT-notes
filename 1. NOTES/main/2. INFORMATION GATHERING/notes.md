## Information gathering

### 🧠 1. Web security testing guide and checklist

**Category:** Theory
**Module:** Web enumeration and information gathering

📌 **WSTG**

**Guide**

- Offers guidance and theoretical approach about the steps you must follow

**Checklist**

- Summarized steps
- Findings
- Summary
- Risk calculator

### 🗺️ 2. Enumeration and fingerprinting with whois / netcraft / dnsrecon

**Category:** Workflow/Methodology
**Module:** Finding ownership and ip addresses

📌 **WHOIS**

- **Definition:**
  - Query and response protocol used to query databases that store the registered users or organizations of an internet resource like a domain name or an IP address block
- **Tool type**: Passive
- **Action type**: enumeration
- **Examples**:

```code
## Help

whois --help

## Check domain

whois hackersploit.org

## Combine with host

host hackersploit.org

whois [ipfromresult]
```

- **Extra**:
    - whois.domaintools.com. Online tool that uses WHOIS in the background. 
    - Better format and GUI

📌 **Netcraft**

- **Definition:**
  - Online tool to discover the web application underlying infrastructure details
- **Tool type**: Passive
- **Action type**: fingerprinting
- **Resource**: netcraft.com

📌 **DNS enumeration**

- **Name**: dnsrecon
- **Example**:

```code
## Recon a domain

dnsrecon -d hackersplot.org
```
- **Extra**: dnsdumpser.com
    - Same tool type but online with better GUI
    - Graph tool
- **Reference table**:

    | Key | Description |
    | --- | --- |
    | **A** | Resolves hostname to IPv4
    | **AAAA** | Resolves hostname to IPv6
    | **NS** | Reference to nameserver
    | **MX** | Reference to mail server
    | **CNAME** | Domain aliases
    | **TXT** | Text records
    | **HINFO** | Host information
    | **SOA** | Domain authority
    | **SRV** | Service records
    | **PTR** | Resolves an IP to a hostname

### 🧠 3. Server metafiles

**Category:** Theory
**Module:** Reviewing webserver metafiles for information leakage

📌 **Robots**

- A file for stating directives to browsers
- Items: 
  - Key details (infrastructure)
  - Sitemaps
  - Folders / Directory structure

### 🗺️ 4. Google dorks

**Category:** Workflow/Methodology
**Module:** Search engine discovery

📌 **Google dorks**

- **Example**:

```code
## Find by specific site / domain

site:ine.com

## Find in url 

inurl:admin

## Show subdomains

site:*.ine.com

## Search in title

intitle:admin

## Find files

filetype:pdf

## Intitle index of (Common vulnerability)

intitle:index of

## Cache (previous versions)

cache:ine.com

## In url auth user details

inurl:auth_user_file.txt
inurl:passwd.txt
```

📌 **Wayback machine**

- Can explore how websites looked like in the past

📌 **Google hacking database**

- Predefined google dorks

### 🗺️ 5. Web app fingerprinting

**Category:** Workflow/Methodology
**Module:** Web app fingerprinting

📌 **Firefox addons**

- **BuiltWith** (website profiling and fingerprinting)
- **Wappalyzer** (same)

📌 **Whatweb**

- CLI command that tells you the stack of a given domain

### 🗺️ 6. WAF detection

**Category:** Workflow/Methodology
**Module:** Web app fingerprinting

📌 **Wafw00f**

- **Example**:

```code
## Check site waf

wafw00f hackersploit.org
```

### 🗺️ 7. Source code analysis - Copying websites with Httrack

**Category:** Workflow/Methodology
**Module:** Source code analysis

📌 **HTTRack**

- **Takeway**: see the source files
- **Example**:

```code
## Copy website

httrack --help
httrack www.zonetransfer.me -O zonetransfer/

## Doing it through the wizard

httrack

1. Enter project name
2. Enter base path
3. Enter urls
4. Select option

Launch
```

### 🗺️ 8. Screenshots with EyeWitness

**Category:** Workflow/Methodology
**Module:** Source code analysis

- **Description**: designed to take screenshots of websites and provide some server header info, and identity default credentials if known.
- Creates report automatically
- **Example**:

```code
## Might need to be installed

## Create domains file

vim domains.txt

hackersploit.org
forum.hackersploit.org

## Help

eyewitness --help

## Take screenshots of one domain

eyewitness --web -f domains.txt -d hackersploit
```

### 🗺️ 9. Passive crawling and spidering with burp suite and OWASP ZAP

**Category:** Workflow/Methodology
**Module:** Website crawling and spidering

**Burp suite**

- Steps
  - Ensure Dashboard, capturing is on
  - As you click on different parts of the application, select target and site map, and the site maps will be constructed (proxy intercept must be off )

**OWASP Zap**

- Select the standard mode
- Once site is on the screens
  - Tools, select, website
  - Recurse enabled
- Browse files
  - Right click, open in browser

### 🗺️ 10. Burp suite and nmap lab

**Category:** Workflow/Methodology
**Module:** Website crawling and spidering

**Nmap**

- Run nmap scan against the target

```code
nmap -sS -sV demo.ine.local
```

**Burp suite**

- Navigate through the web in order to get more results
- Http history under Proxy to view visited pages

### 🗺️ 11. Web server fingerprinting

**Category:** Workflow/Methodology
**Module:** web servers

**Nmap**

- **Tool type**: active
- **Automated scripts**:
  - Automated scans 
  - Stored in /usr/share/nmap/scripts/
- **Example**

```code
## Fast scan with nmap

nmap -sV -F 192.212.206.3

## Automated script with ranged ports

nmap -sV -p 80 --script=http-enum 192.212.206.3

## Check for banner

nmap -sV -script banner demo.ine.local
```

**Metasploit**

- **Example**

```code
## Metasploit console

msfconsole

## Search module

search auxiliary/scanner/http/http_version
use 0
show options
set RHOSTS 192.212.206.3
run
```

**Curl**

- **Example**

```code
## Curl

curl http://192.212.206.3
```

**Dirb**

- **Example**

```code
## Use with dictionary

dirb http://192.212.206.3 /user/shre/metasploit-framework/data/wordlist/directory.txt
```

### 🛠️ 12. Apache recon lab - fingerprinting

**Category:** Exploit/payload
**Module:** Web servers

10. (Flag) Which bot is specifically banned from accessing a specific directory?

**Actions & commands**

```code
# Check target machine is reachable

ping -c 4 demo.ine.local

# Check which web server software is running on the target server with nmap

nmap -sV -script banner demo.ine.local

# Check which web server software is running on the target server with metasploit

msfconsole

use auxiliary/scanner/http/http_version
set RHOSTS demo.ine.local
exploit

# Check what web app is hosted on the web server using curl command

curl http://demo.ine.local/

# Check what web app is hosted on the web server using wget command

wget http://demo.ine.local/index
ls
cat index

# Check what web app is hosted on the web server using browsh CLI based browser

browsh --startup-url demo.ine.local

# Check what web app is hosted on the web server using lynx CLI based browser

lynx http://demo.ine.local

# Perform bruteforce on webserver directories and list the names of directories found. Use brute_dirs metasploit module.

use auxiliary/scanner/http/brute_dirs
set RHOSTS demo.ine.local
exploit

# Use the directory buster (dirb) with "/usr/share/metasploit-framework/data/wordlists/directory.txt" dictionary to check if any directory is present in the root folder of the web server. List the names of found directories.

dirb http://demo.ine.local /usr/share/metasploit-framework/data/wordlists/directory.txt

# Check which bot is specifically banned from accessing a specific directory?

use auxiliary/scanner/http/robots_txt
set RHOSTS demo.ine.local
exploit

```
- **Clarifications**:
  - wget: downloads files
  - lynx: text browser
  - browsh: modern terminal browser

### 🗺️ 13. DNS enumeration and zone transfers

**Category:** Workflow/Methodology
**Module:** DNS enumeration

📌 **DNS zone transfer**

- DNS interrogation
  - Enumerating dns records
- Zone transfer
  - Moving configuration files from one DNS server to another
  - This can be abused by attackers if functionality is misconfigured and left unsecured

📌 **Demo**

- Default hosts location:
  - /etc/hosts

 - **Example**

```code
## Dns dumpster

Go to: dnsdumpster.com, type the domain

## Dns recon

dnsrecon -d zonetransfer.me

## Dnsenum

Can perform zone transfer and brute force (active recon)

dnsenum zonetransfer.me

## What is

Returns a one line description of the tool

whatis dig 

## Dig zone transfer

dig axfr #nsztm1.digi.ninja zonetransfer.me

## Fierce bruteforce

Semi light weight scanner that helps locate non-contiguous IP space and hostnames against specific domains.

fierce -dns zonetransfer.me
```

### 🛠️ 14. DNS Zone transfer lab

**Category:** Exploit/payload
**Module:** DNS enumeration

 - **Lab**

```code

IP: 192.84.45.3

# How many A Records are present for witrap.com and its subdomains?

dig axfr witrap.com @192.84.45.3

# What is the IP address of machine which support LDAP over TCP on witrap.com?

192.168.62.11

# Can you find the secret flag in TXT record of a subdomain of witrap.com?

my_s3cr3t_fl4g

# What is the subdomain for which only reverse dns entry exists for witrap.com? witrap owns the ip address range: 192.168..

dig axfr -x 192.168 @192.84.45.3

# How many records are present in reverse zone for witrap.com (excluding SOA)? witrap owns the ip address range: 192.168..

dig axfr -x 192.168 @192.84.45.3
```

### 🗺️ 15. Subdomains

**Category:** Workflow/Methodology
**Module:** Subdomains

📌 **Sublist3r**

- It includes subbrute
- **SecLists**: collection of multiple types of lists used during security assessments.
- For DNS discovery: https://github.com/danielmiessler/SecLists/tree/master/Discovery/DNS
 
**Lab**

```code
# List subdomains for a specific domain

sublist3r -d google.com

# Specify search engine

sublist3r -d google.com -e google.com

# Bruteforce

fierce --domain ine.com --subdomain-file fierce-hostlist.txt
```

### 🗺️ 16. Web server vulnerability scanning with Nikto

**Category:** Workflow/Methodology
**Module:** Web server vulnerability scanning

📌 **Nikto**

- It provides a summary / report of vulnerabilities.

**Lab**

- Check carefully the discoverings
  - Vulnerabilities highlighted
  - Files: for example, passwd files
  - Additional links to analyze with Nikto. **Important**: result is not the same depending on the route analyzed

  
### 🗺️ 17. Files and directory enumeration

**Category:** Workflow/Methodology
**Module:** Files and directory enumeration

📌 **Gobuster**

- When you find folders in the results, you can perform searches over those folders as well (the ones with 200 http status code)

**Lab**

```code
# Gobuster dir 

gobuster dir -u http://192.137.160.3 -w /usr/share/wordlists/dirb/common.txt

# Gobuster dir - exclude http status codes

gobuster dir -u http://192.137.160.3 -w /usr/share/wordlists/dirb/common.txt -b 403,404

# Gobuster dir - find file extensions (r is from redirect)

gobuster dir -u http://192.137.160.3 -w /usr/share/wordlists/dirb/common.txt -b 403,404 -x .php,.txt,.xml -r 
```

### 🗺️ 18. OWASP Amass

**Category:** Workflow/Methodology
**Module:** Automated recon framework

📌 **Amass**

- Performs network mapping of attack surfaces and external asset discovery using open source information gathering and active reconnaissance techniques.

**Lab**

```code

# Subdomain enumeration

amass enum -d zonetransfer.me

# Subdomain enumeration (passive)

amass enum -passive -d zonetransfer.me

# Display sources and store to directory

amass enum -d zonetransfer.me -passive -src -dir /home/kali/Desktop/ZTME

# Using brute force

amass enum -d zonetransfer.me -src -ip -brute -dir /home/kali/Desktop/ZTME_Brute

# Using intel for initial target discovery. Intel broadens the scope by finding additional root domains and infrastructure

amass intel -active -whois -d zonetransfer.me -dir /home/kali/Desktop/ZTME_Intel

# Visualize enumeration results (done against existing reports)

amass viz -dir /home/kali/Desktop/ZTME -d3
```