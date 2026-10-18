# eWPTv2 EXAM SESSION: `2026‑09‑19`

**Start:** `HH:MM` · **Stop:** `HH:MM` · **Passing score:** `35 / 50 (70%)`

Command conventions, placeholders and output file naming are in [📋 checklist-and-commands.md](<../6. FINAL STRUCTURE/PHASES/01 - Info-Gathering-and-Recon/📋 checklist-and-commands.md>). Do not repeat them here.

***

## 🗺 TARGET INFRASTRUCTURE MAP

*Map IPs to apps and technologies as soon as the exam starts, so each question stays tied to the right host.*

| Target | App / role | Stack (web, lang, DB, OS) | Status |
| :----- | :--------- | :------------------------ | :----- |
| `172.20.0.2` | Reverse proxy | Apache, PHP, MySQL, Linux, Samba, PostgreSQL | [ ] Mutillidae, DVWA, WebDAV, phpMyAdmin, login |

***

## 📜 LOG

*One line per command. Output files are in `01-Info-Gathering-and-Proxies/`. Times were not recorded for these runs (`—`).*

| # | Time | Command (short) | Result (one line) | Output file |
| :- | :--- | :-------------- | :---------------- | :---------- |
| 1 | — | `nmap -sC -sV --exclude-ports 1524,6667 172.20.0.2` | 17 open ports (see Discoveries) | `nmap-172.20.0.2.txt` |
| 2 | — | `nmap -sV -p 80,443,8000,8080,8443,8888` (command from file header) | 80 open (Apache 2.2.8), the rest closed | `nmap-172.20.0.2(2).txt` |
| 3 | — | `nmap` runs (1) and (3), commands not logged | 14 open ports and 1 open port | `nmap-172.20.0.2(1).txt`, `nmap-172.20.0.2(3).txt` |
| 4 | — | `dig NS meta2` | NXDOMAIN, no NS record | `dig-ns-meta2.txt` |
| 5 | — | `dig axfr meta2 @46.6.113.34` | Transfer failed | `dig-axfr-meta2.txt` |
| 6 | — | `curl -skv http://meta2/fjdfdf` | 404, `Apache/2.2.8 (Ubuntu) DAV/2` | `curl-meta2.txt` |
| 7 | — | `curl -sk http://meta2/fjdfdf \| wc -c` | 123 bytes | `curl-meta2(1).txt` |
| 8 | — | `curl -sk -I "http://meta2:80"` | 200, `X-Powered-By: PHP/5.2.4` | `curl-head-80.txt` |
| 9 | — | `curl -sk -i "http://meta2/nonexistent_test_page_123"` | 404 | `curl-trigger-error-verbose.txt` |
| 10 | — | `curl -sk "http://meta2/mutillidae/robots.txt"` | 200, 401 bytes | `curl-common-metafiles.txt` |
| 11 | — | `curl -sk -i -X POST` `dns-lookup.php`, body `target_host=dsad` | 200, 24 KB response | `curl-post-json.txt` |
| 12 | — | `curl -sk -i -X OPTIONS "http://meta2/mutillidae:80"` | `Allow: GET,HEAD,POST,OPTIONS,TRACE` | `curl-options-80.txt` |
| 13 | — | `ffuf` Host `FUZZ.meta2`, `-fs 280`, subdomains top 5000 | 4,967 hits, all on `/`, so the filter missed | `ffuf-meta2-subdomains.json` |
| 14 | — | `ffuf` raft-medium-directories, `-mc 200,301,302,403` | 9 hits: `/test`, `/phpMyAdmin`, `/twiki`, `/phpinfo`, `/dav` | `ffuf-meta2-directory-admin.json` |
| 15 | — | `ffuf` DirBuster small, `-recursion -recursion-depth 1 -e .php` | 233 hits, many are wordlist comment lines | `ffuf-meta2-recursive-deeper-paths.json` |
| 16 | — | `ffuf index.phpFUZZ` (backup extensions) | 1 result line, URL shows literal `FUZZ` | `ffuf-backups-index.json` |
| 17 | — | `ffuf configFUZZ` (backup extensions) | 1 result line, URL shows literal `FUZZ` | `ffuf-backups-config.json` |
| 18 | — | `ffuf` burp-parameter-names on `index.php?FUZZ=test`, `-ac` | 1 hit: `page` (200, 21713 B) | `ffuf-fuzz-parameters-get.json` |
| 19 | — | `ffuf` burp-parameter-names on `index.php?FUZZ=test`, `-fs 24198` | 6,448 hits, filter missed | `ffuf-get-params.json` |
| 20 | — | `ffuf` burp-parameter-names POST on `dns-lookup.php`, no filter | 6,455 hits, noise | `ffuf-fuzz-parameters-post.json` |
| 21 | — | `ffuf` burp-parameter-names POST on `login.php`, `-fs 25391` | 1 hit: `page` (200, 21708 B) | `ffuf-post-params.json` |
| 22 | — | `gobuster dir` common.txt | `index`, `dav`, `phpMyAdmin`, `phpinfo.php`, `test`; 403 on `server-status`, `cgi-bin/` | `gobuster-root.txt` |
| 23 | — | `gobuster dir -x php,html,txt,bak` | 403 on `.ht*` files; 200/301 on `index`, `dav`, `phpMyAdmin`, `phpinfo`, `test`, `twiki` | `gobuster-root-ext.txt` |
| 24 | — | `gobuster dir` medium, `-s 200,204,301,302,307` | 6 hits: `index`, `test`, `twiki`, `tikiwiki`, `phpinfo`, `phpMyAdmin` | `gobuster-filtered.txt` |
| 25 | — | `gobuster dir -u /mutillidae -c <COOKIE>` | `robots.txt` (200, 160 B), `passwords/` (301), `installation` (200), `phpinfo` (200), `phpMyAdmin` (200) | `gobuster-auth-scan.txt` |
| 26 | — | `gobuster dir` api-endpoints | Empty (0 bytes) | `gobuster-api-scan.txt` |
| 27 | — | `whatweb http://meta2/` | Apache 2.2.8, PHP 5.2.4, title `Metasploitable2 - Linux`, WebDAV | `whatweb.txt` |
| 28 | — | `whatweb -v http://meta2/` | Not on disk | `whatweb-verbose.txt` (missing) |
| 29 | — | `nikto -Tuning 23` | `/icons/` listing; Apache and PHP outdated; missing `X-Content-Type-Options` and HSTS | `nikto-quiet.txt.txt` |
| 30 | — | `nikto -p 80,443,8080,8443 -ssl -Tuning x6` | Not on disk | `nikto-multi.txt` (missing) |

***

## 🛠 TARGET: `172.20.0.2`

### 0. Overview & questions

- **Role / description:** `Reverse proxy`
- **Related questions:** `?`

### 1. Discoveries

*Facts that look like exam material: versions, paths, headers, error messages, parameters. Each one carries its pivot.*

- **Open ports (nmap, 17):** `21` ftp vsftpd 2.3.4 · `22` ssh OpenSSH 4.7p1 · `23` telnet · `25` smtp Postfix · `80` http Apache 2.2.8 · `111` rpcbind · `139` / `445` Samba smbd · `512` exec · `513` login · `514` tcpwrapped · `1099` java-rmi GNU Classpath · `2121` ftp ProFTPD 1.3.1 · `3306` mysql 5.0.51a · `5432` postgresql 8.3.x · `8009` ajp13 · `8180` Tomcat/Coyote 1.1
  - Closed web ports (nmap): `443`, `8000`, `8080`, `8443`, `8888` → pivot: nothing to test there.
  - Pivot: vsftpd 2.3.4 and ProFTPD 1.3.1 → version-specific checks; mysql 5.0.51a → check remote login.
- **nmap http-enum paths:** `/tikiwiki/`, `/test/`, `/phpinfo.php`, `/phpMyAdmin/`, `/doc/`, `/icons/`, `/index/` → pivot: `/doc/` and `/icons/` list directories.
- **Server banner:** `Apache/2.2.8 (Ubuntu) DAV/2` (`curl-head-80.txt`) → pivot: Apache 2.2.8 version-specific checks.
- **Accepted methods:** `GET, HEAD, POST, OPTIONS, TRACE` (`curl-options-80.txt`) → pivot: TRACE is enabled; test WebDAV methods on `/dav/`.
- **X-Powered-By / framework:** `PHP/5.2.4-2ubuntu5.10` (`curl-head-80.txt`, `whatweb.txt`); title `Metasploitable2 - Linux` → pivot: `phpinfo.php` shows the full PHP config.
- **Hidden directories / files** (`gobuster-root.txt`, `gobuster-filtered.txt`, `ffuf-meta2-directory-admin.json`):
  - `/dav/` (301), `/phpMyAdmin/` (301), `/phpinfo.php` (200), `/test/` (301), `/twiki/`, `/tikiwiki/`; `/server-status` and `/cgi-bin/` (403).
  - `/mutillidae/robots.txt` (200, 160 B), `/mutillidae/passwords/` (301), `/mutillidae/installation` (200) (`gobuster-auth-scan.txt`) → pivot: read `robots.txt`; check `passwords/` and `installation` for exposed content.
  - Pivot: `/dav/` → WebDAV methods; `/phpMyAdmin/` → login checks.
- **Missing security headers (nikto):** `X-Content-Type-Options`, `Strict-Transport-Security` (`nikto-quiet.txt.txt`).
- **Subdomains:** none found. `meta2` has no NS record (`dig-ns-meta2.txt`), AXFR was refused (`dig-axfr-meta2.txt`), and the Host-header run was unfiltered (see Lessons) → pivot: re-run vhost fuzzing with the root response size filtered.
- **Interesting parameters / behaviours:**
  - `GET /mutillidae/index.php?page=` (`ffuf-fuzz-parameters-get.json`, only hit `page`, 200, 21713 B) → pivot: test `page` for file inclusion (see Finding 2).
  - `POST /mutillidae/index.php?page=dns-lookup.php`, body `target_host=` (`curl-post-json.txt`, 200) → pivot: test `target_host` for injection.
  - `POST /mutillidae/index.php?page=login.php`: the only POST hit is `page` (`ffuf-post-params.json`) → pivot: no login field found by ffuf; check the form in Burp.
  - Unverified (noted before the saved outputs existed; not in any file): `GET /search.php?q=`, `GET /product.php?id=`, `POST /login.php` with `username` and `password`.
- **Unverified paths (noted before the saved outputs existed):** `/backup/` (`config.php.bak`), `/dev/` (`/dev/api-docs/`), `/uploads/`, `/robots.txt` Disallow `/private/`, `/beta/`, `.git/`, `.env`.

### 2. Findings

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

### 3. Next steps

- [ ] Test file upload in `/uploads/` for extension bypass and RCE.  
- [ ] Check password reset / account recovery for token predictability.  
- [ ] Look for IDOR in profile or order endpoints.  
- [ ] Re-run vhost fuzzing with the root response size filtered (from Discoveries: subdomains).  
- [ ] Test `page` and `target_host` for injection (from Discoveries: parameters).  
- [ ] Check `/dav/` methods and `/mutillidae/passwords/` (from Discoveries: paths).  

### 4. Lessons (optional)

- `e.g., Forgot to check HTTP methods; remember OPTIONS/PROPFIND next time.`  
- `e.g., SQLi payload X worked better on this stack.`  
- `When doing curl for options, add port to make response showing Allow header`  
- Calibrate ffuf filters against the root response first (`-ac`, or a measured `-fs`). The runs without a valid filter gave thousands of hits (log rows 13, 19 and 20).  
- Drop wordlist comment lines with `-ic`. The recursive run (row 15) matched `# ...` comment lines as paths.  
- Log the command next to every saved file. The nmap runs (1) and (3) were not logged with commands (the file header has them), and one blank-command row pointed at `curl-common-metafiles.txt`, so it was dropped from the log.  
- Check output names after each run. Some report names did not match the disk (`fffuf-…`, `nikto-quiet.txt.txt`), and `whatweb-verbose.txt` and `nikto-multi.txt` are missing.  
- `gobuster-api-scan.txt` is empty (0 bytes). Check the wordlist path before reading it as "no endpoints".  

***

## 🔑 CREDENTIALS TRACKER (all targets)

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

## 💡 PHASE INSIGHTS AND ENHANCEMENTS

1. Check commands to process source file information quicker and more efficiently (grep, wc, and so on)
2. Attach notes to each command on attacks and payloads md in order to ease interpretation
3. Review and anchor pivot movements, so whatever the data you need to persist is there at hand
4. Establish conventions for naming files: command-domain-context. Or such.
5. It is difficult to identify sections or where I should put each piece of info in the target markdown report. Clarify this and find the best distribution
6. Gain some time by directly saving files and not pasting content here (just the relevant details when later you review the discoverings)
7. Discovery findings can really establish the direction of the commands and attacks in next phases. Bear that in mind
8. Some commands are repetitive. Eliminate everything is not fully needed.
9. These commands (curl, ffuf, etc) can throw different results depending on the path you use as a target. This is overwhelming for the exam. Where should I concentrate on?
10. Which wordlists will there be in the exam?
11. How do I exactly calculate baseline size for ffuf?
12. How can I optimize for reading discovery commands results?
13. Eliminate any tools are not in the kali machine at the exam
14. Eliminate repetitive commands
15. Merge attacks and payloads with checklist
16. Analyze and decide when to save command outputs into files vs when not
17. Is OWASP ZAP available at the exam?
18. Don't forget the big picture: subdomain enumeration, directory brute forcing. Correct the content of the file contents if diverting from what exam is going to ask.
