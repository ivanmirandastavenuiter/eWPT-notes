# eWPTv2 EXAM SESSION: `2026‑09‑19`

**Start Time:** `HH:MM`  
**Stop Time:** `HH:MM`  
**Passing Score:** `35 / 50 (70%)`  

***

## 🎯 TARGET INFRASTRUCTURE MAPPING

*Map IPs to app names and technologies as soon as the exam starts to keep questions tied to the right host.*  

| Target IP | Site/App Name        | Tech Stack (Web, Lang, DB, OS) | Status / Notes               |
| :-------- | :------------------- | :----------------------------- | :--------------------------- |
| 172.20.0.2 | Reverse proxy     | Apache, PHP, MySQL, Linux, Samba, PostgreSQL   | [ ] Mutillidae, DVWA, WebDAV, phpMyAdmin, login |

***

## 🛠 TARGET: `172.20.0.2`

### 0. TARGET OVERVIEW & QUESTIONS

- Role / description: `Reverse proxy`  
- Related questions: `?`  

### 0.1 SCANS & TOOLS

- nmap:  
  - Command:  
    `nmap -sC -sV --exclude-ports 1524,6667 172.20.0.2 -oN nmap-172.20.0.2.txt
`  
  - Key results:  
    - `21/tcp  open  ftp   vsftpd 2.3.4`  
    - `22/tcp  open  ssh   OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)`  
    - `23/tcp  open  telnet   Linux telnet`  
    - `25/tcp  open  smtp   Postfix smtpd`  
    - `80/tcp  open  http   Apache/2.2.8 ((Ubuntu) DAV/2)`  
    - `111/tcp  open  rpcbind   2 (RPC #1000000)`  
    - `139/tcp  open  netbios-ssn   Samba smbd 3.X - 4.X`  
    - `445/tcp  open  netbios-ssn   Samba smbd 3.0.20-Debian`  
    - `512/tcp  open  exec   netkit-rsh rexecd`  
    - `513/tcp  open  login`
    - `514/tcp  open  tcpwrapped`
    - `1099/tcp open  java-rmi    GNU Classpath grmiregistry`
    - `2121/tcp open  ftp         ProFTPD 1.3.1`
    - `3306/tcp open  mysql       MySQL 5.0.51a-3ubuntu5`
    - `5432/tcp open  postgresql  PostgreSQL DB 8.3.0 - 8.3.7`
    - `8009/tcp open  ajp13       Apache Jserv (Protocol v1.3)`
    - `8180/tcp open  http        Apache Tomcat/Coyote JSP engine 1.1`

  - Nmap directories
    - `/tikiwiki/: Tikiwiki`
    - `/test/: Test page`
    - `/phpinfo.php: Possible information file`
    - `/phpMyAdmin/: phpMyAdmin`
    - `/doc/: Potentially interesting directory w/ listing on 'apache/2.2.8 (ubuntu) dav/2'`
    - `/icons/: Potentially interesting folder w/ directory listing`
    - `/index/: Potentially interesting folder`

  - Nmap http ports:
    - `80/tcp   open   http           Apache httpd 2.2.8 ((Ubuntu) DAV/2)`
    - `443/tcp  closed https`
    - `8000/tcp closed http-alt`
    - `8080/tcp closed http-proxy`
    - `8443/tcp closed https-alt`
    - `8888/tcp closed sun-answerbook`

- Web enumeration:  
  - Directory brute force
    - Command: `ffuf -u http://10.x.x.10/FUZZ -w /usr/share/wordlists/...`  
      - Result: `/admin/`, `/backup/`, `/uploads/`  
    - Command: `dirsearch -u http://10.x.x.10/ -w ...`  
      - Result: `/dev/`, `/old/`  
  - Subdomain
    - Command: `dig NS meta2`
      - Result: 
        ```
        ; <<>> DiG 9.20.24-1+b1-Debian <<>> NS meta2
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 40991
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 512
        ;; QUESTION SECTION:
        ;meta2.				IN	NS

        ;; AUTHORITY SECTION:
        .			332	IN	SOA	a.root-servers.net. nstld.verisign-grs.com. 2026091900 1800 900 604800 86400

        ;; Query time: 12 msec
        ;; SERVER: 46.6.113.34#53(46.6.113.34) (UDP)
        ;; WHEN: Sat Sep 19 13:08:04 CEST 2026
        ;; MSG SIZE  rcvd: 109
        ```
    - Command: `dig axfr meta2 @46.6.113.34 > dig-axfr-meta2.txt`
        - Result: 
        ```
        ; <<>> DiG 9.20.24-1+b1-Debian <<>> axfr meta2@46.6.113.34#53
        ;; global options: +cmd
        ; Transfer failed.
        ```

- curl:  
  - Command:  
    `curl -skv http://meta2/fjdfdf > curl-meta2.txt`  
    - Results:  
    ```
    * Host meta2:80 was resolved.
    * IPv6: (none)
    * IPv4: 172.20.0.2
    *   Trying 172.20.0.2:80...
    * Established connection to meta2 (172.20.0.2 port 80) from 172.20.0.1 port 45156 
    * using HTTP/1.x
    > GET /fjdfdf HTTP/1.1
    > Host: meta2
    > User-Agent: curl/8.21.0
    > Accept: */*
    > 
    * Request completely sent off
    < HTTP/1.1 404 Not Found
    < Date: Mon, 21 Sep 2026 16:43:33 GMT
    < Server: Apache/2.2.8 (Ubuntu) DAV/2
    < Content-Length: 280
    < Content-Type: text/html; charset=iso-8859-1
    < 
    { [280 bytes data]
    * Connection #0 to host meta2:80 left intact

    ```
  - Command:  
    `curl -sk http://meta2/fjdfdf | wc -c > curl-meta2(1).txt`  
    - Results:  
    ```
    123
    ```

- ffuf:
  - Command: `ffuf -u "http://meta2/" \
     -H "Host: FUZZ.meta2" \
     -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -fs 280 \
     -t 10 \
     -o ffuf-meta2-subdomains.json -of json`
    - Results:  
      ```
      Note relevant
      ```
    - Advice: pay attention to response sizes, redirections and different word/line counts
  - Command: `ffuf -u "http://meta2/FUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt \
     -mc 200,301,302,403 \
     -t 10 \
     -o ffuf-meta2-directory-admin.json -of json`
    - Results: `ffuf-meta2-directory-admin.json`
  - Command: `ffuf -u "http://meta2/FUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-small.txt:FUZZ \
     -recursion -recursion-depth 1 \
     -e .php \
     -mc 200,301,302,403 \
     -t 10 \
     -o ffuf-meta2-recursive-deeper-paths -of json`
     - Result: `ffuf-meta2-recursive-deeper-paths.json`
  - Command: `ffuf -u "http://meta2/index.phpFUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt \
     -e .bak,.old,.swp,.tmp,~ \
     -t 10 \
     -o ffuf-backups-index.json -of json`
     - Result: `fffuf-backups-index.json`
  - Command: `ffuf -u "http://meta2/configFUZZ" \
     -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt \
     -e .bak,.old,.zip,.tar.gz \
     -t 10 \
     -o ffuf-backups-config.json -of json`
     - Result: `ffuf-backups-config.json`

- gobuster:
  - Command: `gobuster dir \
    -u "http://meta2/" \
    -w /usr/share/wordlists/dirb/common.txt \
    -t 10 \
    -o gobuster-root.txt`
    - Result: `gobuster-root.txt`
  - Command: `gobuster dir \
    -u "http://meta2/" \
    -w /usr/share/wordlists/dirb/common.txt \
    -x php,html,txt,bak \
    -t 10 \
    -o gobuster-root-ext.txt`
    - Result: `gobuster-root-ext.txt`
  - Command: `gobuster dir \
    -u "http://meta2/" \
    -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
    -s 200,204,301,302,307 \
    --exclude-length 1234 \
    -t 10 \
    -b '' \
    -o gobuster-filtered.txt`
    - Result: `gobuster-filtered.txt`

- Other tools:  
  - `nikto -h http://10.x.x.10` → `X‑Powered‑By`, outdated components, interesting headers.  

***

### 1. DISCOVERY & ENUMERATION

*Capture facts that look like “exam question material”: versions, paths, headers, error messages, etc.*  

- **Server banner:**  
  - `Apache httpd 2.2.8 ((Ubuntu) DAV/2)`
- **Accepted methods:**
  - `GET HEAD POST OPTIONS ` 
- **X‑Powered‑By / framework clues:**  
  - Example: `X‑Powered‑By: PHP/8.1.0`  
- **Hidden directories / files:**   
  - From `ffuf` / `dirsearch`:  
    - `/backup/` → Contains `config.php.bak`  
    - `/dev/` → Contains API documentation `/dev/api-docs/`  
    - `/uploads/` → User-uploaded files, potential upload vuln  
  - Common files checked:  
    - `/robots.txt` → Disallowed paths: `/private/`, `/beta/`  
    - `.git/` → Repository exposure?  
    - `.env` → Environment vars (DB creds, keys)  

- **Interesting parameters / behaviours:**  
  - `GET /search.php?q=` → Reflects user input (XSS candidate)  
  - `GET /product.php?id=` → Numeric ID, SQLi candidate  
  - `POST /login.php` → Parameter names: `username`, `password`  

***

### 2. VULNERABILITIES & FLAGS

*Each finding in a standard mini‑report format, linked to exam questions where relevant.*  

#### Finding 1: SQL Injection on `search.php?id`

- Related questions: `Q4, Q6`  
- URL / Parameter:  
  - `http://10.x.x.10/search.php?id=[INJECT]`  
- Method:  
  - `Union-based` / `Error-based`  
- Payload used:  
  - `' UNION SELECT 1,2,database(),version()-- -`  
- Evidence (data extracted):  
  - DB name: `user_db`  
  - DB version: `MariaDB 10.6`  
  - Table(s): `users`, `admins`  
  - Admin password hash: ``$2y$10$abcdef...``  
  - Flag: `FLAG{SQLI_SUCCESS_99}`  
- Impact:  
  - Full DB enumeration and credential disclosure; potential account takeover.  

***

#### Finding 2: Local File Inclusion (LFI)

- Related questions: `Q9`  
- URL / Parameter:  
  - `http://10.x.x.10/index.php?page=../../../../etc/passwd`  
- Payloads used:  
  - `?page=../../../../etc/passwd`  
  - `?page=php://filter/convert.base64-encode/resource=index.php`  
- Evidence:  
  - `/etc/passwd` loaded; users like `root`, `www-data`, `john_dev`.  
  - `/var/www/html/config.php` revealed app secret and DB creds.  
- Flag / secret:  
  - `FLAG{LFI_FILE_DISCLOSURE}`  
  - `app_secret_key=...`  
- Impact:  
  - Arbitrary file read, potential credential/secret exposure and RCE depending on files found.  

***

#### Finding 3: [Finding title]

- Related questions: `Qxx`  
- URL / Parameter:  
- Method / vulnerability type:  
- Payload / technique:  
- Evidence (for questions):  
  - [Version / path / value / flag]  
- Impact:  

***

### 3. TODO / IDEAS FOR THIS TARGET

- [ ] Test file upload in `/uploads/` for extension bypass and RCE.  
- [ ] Check password reset / account recovery for token predictability.  
- [ ] Look for IDOR in profile or order endpoints.  

***

### 4. NOTES / LESSONS (OPTIONAL)

- `e.g., Forgot to check HTTP methods; remember OPTIONS/PROPFIND next time.`  
- `e.g., SQLi payload X worked better on this stack.`  

***

## 🔑 MASTER CREDENTIALS TRACKER (ALL TARGETS)

*Update this live for any creds, hashes, or tokens.*  

| Username | Password / Hash          | Source (SQLi, LFI, brute, etc.) | Works on (URL / service)        | Notes                    |
| :------- | :----------------------- | :------------------------------ | :------------------------------ | :----------------------- |
| admin    | `P@ssw0rd!123`          | Hydra on `/admin/login`         | `http://10.x.x.10/admin/login`  | Full admin access        |
| developer| `$2y$10$abcdef...`      | SQLi dump (`admins` table)      | Needs cracking                  | Possibly high privilege  |
| apiuser  | `apitoken-1234...`      | LFI → config.php                | API auth header `X-API-Key`     | Token‑based auth         |

***

## 📝 EXAM QUESTION SCRATCHPAD

*Track questions to revisit and what they likely depend on.*  

- **Q14:** Needs exact CMS version. Likely from HTTP headers, `/admin` footer, or `/CHANGELOG`.  
- **Q29:** Flag in `/uploads`. Need upload bypass and successful web shell / file access.  
- **Q33:** Asks for parameter name used in password reset. Review `/reset.php` traffic.  

***

## 💡 QUICK TIPS FOR YOURSELF

1. Read all 50 questions quickly at start; roughly group them by target (note in each target’s “Overview & questions”).  
2. Screenshot key request/response pairs (especially flags, version banners, successful exploits) from Burp Repeater.  
3. Always verify versions via HTTP responses or application UI, not only service scans.  
4. Keep this file locally and offline; ensure tools and wordlists are ready before starting.  

***

You can duplicate the whole `🛠 TARGET:` block for each IP and just change the IP, role, and related questions.

## 💡 ENHANCEMENTS

1. Check commands to process source file information quicker and more efficiently (grep, wc, and so on)
2. Attach notes to each command on attacks and payloads md in order to ease interpretation
3. Review and anchor pivot movements, so whatever the data you need to persist is there at hand
4. Establish conventions for naming files: command-domain-context. Or such.
5. It is difficult to identify sections or where I should put each piece of info in the target markdown report. Clarify this and find the best distribution
6. Gain some time by directly saving files and not pasting content here (just the relevant details when later you review the discoverings)