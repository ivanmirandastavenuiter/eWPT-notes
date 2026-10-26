# eWPTv2 EXAM SESSION: `YYYY-MM-DD`

**Start:** `16:19` · **Stop:** `HH:MM` · **Passing score:** `35 / 50 (70%)`

Command conventions, placeholders and output file naming are in [📋 checklist-and-commands.md](<../6. FINAL STRUCTURE/PHASES/01 - Info-Gathering-and-Recon/📋 checklist-and-commands.md>). Do not repeat them here.

***

## 🧭 How to take notes

**Note first, paste nothing.** Write the command and one line of result, then save raw output to `recon/` and link the path. Pasting raw output costs time you need on the exam.

**Log every command** (one line each, in the Log section):

- Time, short command, and the question number if one applies.
- One-line result with the anchor you would need to reproduce it (port, version, path, status, size, param name).
- Output file path, if the output was saved.

**Save to a file** when the output is longer than one screen (nmap, ffuf, gobuster, nikto, `openssl s_client`, `dig axfr`) or when you will need to grep it again. Quick `curl -I` or `dig +short` checks do not need a file.

**Do not note:** raw output, tool banners, wordlist progress, repeated 404s, or the same scan run twice. Write a dead end in one line only when it rules out a path, so you do not retry it.

**Pivot anchors:** every discovery names the next step. Examples: `Apache 2.2.8 → check version-specific CVEs`, `robots Disallow /private/ → add to Burp scope and ffuf list`, `param id numeric → SQLi check`.

**Big-picture check** before you switch phase:
- Every open web port is mapped to a host in the target map.
- Every web host has a root crawl and a directory brute force.
- Subdomains from DNS and SecLists brute force are either tested or ruled out.

***

## 🗂 Where information goes

| Section | Holds | Updated |
|---|---|---|
| Target map | IP, app name, stack, status | Once at start, then per target |
| Log | Every command, one line | Live, as you run each command |
| Discoveries (per target) | Facts with anchors: versions, paths, headers, params | After each scan |
| Findings | Confirmed vulnerabilities only, with evidence file | When confirmed |
| Credentials tracker | Every cred, hash, token and key | When found |
| Question scratchpad | Question number → where the answer is | When a question is read |
| Next steps | Ideas that came from discoveries | Continuously |

***

## 🗺 TARGET INFRASTRUCTURE MAP

*Map IPs to apps and technologies as soon as the exam starts, so each question stays tied to the right host.*

| Target | App / role | Stack (web, lang, DB, OS) | Status |
| :----- | :--------- | :------------------------ | :----- |
| `172.20.0.2 | `Mutillidae` | `Apache, phpMyAdmin, MySQL, JQuery, PHP, Ubuntu` | [ ] |

***

## 📜 LOG

*One line per command. Newest at the bottom.*

| # | Time | Command (short) | Result (one line) | Output file |
| :- | :--- | :-------------- | :---------------- | :---------- |
| 1 | `HH:MM` | `curl -sk -o /dev/null -w "%{size_download}\n" "http://meta2/mutillidae/notfound"` | `293` | |
| 2 | `HH:MM` | `nmap -sC -sV --exclude-ports 1524 --min-rate 1000 meta2 -oN meta2/nmap-full.txt"` | `21,22,23,25,80,111,139,445,512,513,1099,2121,3306,5432,5900,6000,6667,8009,8180` | `meta2/nmap-full.txt"` | |
| 3 | `HH:MM` | `for e in php php7 phtml inc bak old; do curl -sk -o /dev/null -w "%{http_code} %{size_download} index.$e\n" "http://meta2/mutillidae/index.$e"; done` | `200 24198 index.php, 200 178 config.inc` | |
| 4 | `HH:MM` | `ffuf -u "http://meta2/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -e .bak,.old,.swp,.tmp,~ -mc 200 -fs 293 -t 10 -o meta2/ffuf-backups -of all` | `Several hits. Check html file` | `ffuf-backups-mutillidae.html` |
| 5 | `HH:MM` | `ffuf -u "http://meta2/mutillidae/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -e .bak,.old,.swp,.tmp,~ -mc 200 -fs 293 -t 10 -o meta2/ffuf-backups-mutillidae -of all` | `Several hits. Check html file` | `ffuf-backups-mutillidae.html` |
| 6 | `HH:MM` | `for p in .git/HEAD .svn/entries .env .DS_Store; do curl -sk -o /dev/null -w "%{http_code} $p\n" "http://meta2/$p"; done` | `404 .git/HEAD, 404 .svn/entries, 404 .env, 404 .DS_Store` | `None` |
| 7 | `HH:MM` | `for p in .git/HEAD .svn/entries .env .DS_Store; do curl -sk -o /dev/null -w "%{http_code} $p\n" "http://meta2/mutillidae/$p"; done` | `404 .git/HEAD, 404 .svn/entries, 404 .env, 404 .DS_Store` | `None` |
| 8 | `HH:MM` | `for p in _profiler phpinfo.php actuator/env server-status console; do curl -sk -o /dev/null -w "%{http_code} $p\n" "http://meta2/$p"; done` | `200 phpinfo.php, 403 server-status` | `None` |
| 9 | `HH:MM` | `for p in _profiler phpinfo.php actuator/env server-status console; do curl -sk -o /dev/null -w "%{http_code} $p\n" "http://meta2/mutillidae/$p"; done` | `200 phpinfo.php` | `None` |
| 10 | `HH:MM` | `ffuf -u "http://meta2/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403 -fs 293 -t 10 -o meta2/ffuf-dirs -of all` | `Several hits. Check files` | `ffuf-dirs` |
| 11 | `HH:MM` | `ffuf -u "http://meta2/mutillidae/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403 -fs 293 -t 10 -o meta2/ffuf-dirs -of all` | `Several hits. Check files` | `ffuf-dirs-mutillidae` |
| 12 | `HH:MM` | `for p in admin manage dashboard phpmyadmin grafana jenkins; do curl -sk -o /dev/null -w "%{http_code} $p\n" "http://meta2/$p/"; done` | `404` | `None` |
| 13 | `HH:MM` | `for p in admin manage dashboard phpmyadmin grafana jenkins; do curl -sk -o /dev/null -w "%{http_code} $p\n" "http://meta2/mutillidae/$p/"; done` | `404` | `None` |
| 14 | `HH:MM` | `grep "403" meta2/ffuf-dirs.csv > meta2/forbidden-dirs.txt ` | `server-status` | `forbidden-dirs` |
| 15 | `HH:MM` | `grep "403" meta2/mutillidae/ffuf-dirs.csv > meta2/forbidden-dirs-mutillidae.txt ` | `None` | `forbidden-dirs-mutillidae` |
| 16 | `HH:MM` | `whatweb -v http://meta2 > meta2/whatweb.txt` | `Apache 2.2.8 (Ubuntu) DAV/2, PHP (5.2.4-2ubuntu5.10), WebDav, X-Powered-By` | `whatweb.txt` |
| 17 | `HH:MM` | `whatweb -v http://meta2/mutillidae > meta2/whatweb-mutillidae.txt` | `All above, JQuery, Cookie PHPSESSID ` | `whatweb.txt` |
| 18 | `HH:MM` | `searchsploit "Apache 2.2.8" > meta2/searchsploit-apache.txt` | `Several hits` | `searchsploit-apache.txt` |
| 19 | `HH:MM` | `nikto -h "http://meta2" -o meta2/nikto.txt` | `Several hits` | `nikto.txt` |
| 20 | `HH:MM` | `nikto -h "http://meta2/mutillidae" -o meta2/nikto-mutillidae.txt` | `Several hits` | `nikto-mutillidae.txt` |
| 21 | `HH:MM` | `for f in robots.txt sitemap.xml .well-known/security.txt crossdomain.xml clientaccesspolicy.xml humans.txt; do curl -sk -o /dev/null -w "%{http_code} $f\n" "http://meta2/mutillidae/$f"; done` | `robots.txt` | `None` |
| 22 | `HH:MM` | `curl -sk "http://meta2/mutillidae/index.php" \| grep -Eio '<!--.*-->\|src="[^"]+\.js"\|type="hidden"[^>]*' \| sort -u` | `<!-- Begin Content -->,<!-- End Content -->, src="./javascript/bookmark-site.js", src="./javascript/ddsmoothmenu/ddsmoothmenu.js", src="./javascript/ddsmoothmenu/jquery.min.js"` | `None` |
| 23 | `HH:MM` | `ffuf -u "http://meta2/mutillidae/index.php?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -ac -mc all -t 5 -o meta2/ffuf-get-params -of all` | `page` | `ffuf-get-params` |

## 🛠 TARGET: `meta2/mutillidae (172.20.0.2)`

### 0. Overview & questions

- *Role / description:** `Web application`
- **Related questions:** `Qxx, Qyy`

### 1. Discoveries

*Facts that look like exam material: versions, paths, headers, error messages, parameters. Each one carries its pivot.*

- **Server banner:** `Apache httpod 2.2.8 ((Ubuntu) DAV/2)` → pivot: `<next step>`
- **Accepted methods:** `GET,HEAD,POST,OPTIONS` (from `curl -i -X OPTIONS`)
- **Framework / tech:** `<tech>` → pivot: `<next step>`
- **Hidden paths / files:** 
    - `/test`
    - `/phpinfo.php`
    - `/phpMYAdmin`
    - `/doc`
    - `/icons`
    - `/index`
- **Metafiles:** `robots.txt` Disallow `<paths>` → pivot: `<next step>`
- **Parameters:** `<METHOD> <PATH>?<param>=` → pivot: `<next step>`

### 2. Findings

*Use one block per confirmed vulnerability.*

#### `<WSTG-ID>` · `<Finding title>`

- **Related questions:** `Qxx`
- **URL / parameter:** `<URL>` / `<param>`
- **Type and technique:** `<type>`, `<payload or technique>`
- **Evidence:** `recon/<file>` (line `<n>`), or screenshot
- **Flag / value:** `<value>`
- **Impact:** `<one line>`

### 3. Next steps

- [ ] `<next step>` (from discovery `<n>`)

### 4. Lessons (optional)

- `<what to do differently next time>`

***

## 🔑 CREDENTIALS TRACKER (all targets)

*Update live for any credential, hash, token or key.*

| Username | Password / hash / token | Source | Works on | Notes |
| :------- | :---------------------- | :----- | :------- | :---- |
| `<user>` | `<secret>` | `<where it came from>` | `<URL or service>` | `<access level>` |

***

## 📝 EXAM QUESTION SCRATCHPAD

- **`Qxx`:** `<what it asks>` → `<where the answer is or will be>`

***

## 💡 QUICK TIPS

1. Read all exam questions at the start. Group them by target and note the group in each target's overview.
2. Screenshot key request/response pairs (flags, version banners, successful exploits) from Burp Repeater.
3. Verify versions in HTTP responses or the application UI, not only in service scans.
4. Keep this file local and offline. Have tools and wordlists ready before you start.

***

To add a target, copy the `🛠 TARGET:` block and change the IP, role and related questions.
