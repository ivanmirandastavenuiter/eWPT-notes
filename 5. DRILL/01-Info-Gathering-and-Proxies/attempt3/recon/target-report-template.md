# eWPTv2 EXAM SESSION: `YYYY-MM-DD`

**Start:** `HH:MM` · **Stop:** `HH:MM` · **Passing score:** `35 / 50 (70%)`

Command conventions, placeholders and output file naming are in [🧭 phase-walkthrough.md](<../4. FINAL STRUCTURE/01 - Info-Gathering-and-Recon/🧭 phase-walkthrough.md>). Do not repeat them here.

***

## 🧭 How to take notes

**Note first, paste nothing.** Write the command and one line of result, then save raw output to `recon/` and link the path. Pasting raw output costs time you need on the exam.

**Log only what matters** (one line each, in the Log section):

- Short title for the step, the command, and the question number if one applies.
- One-line result with the anchor you would need to reproduce it (port, version, path, status, size, param name).
- Output file path, if the output was saved.
- Skip a row entirely when the command found nothing new — a clean scan doesn't need a log line.

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
| Log | Commands with a relevant result, one line each | Live, as you run each command |
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
| `172.20.0.2` | `Metasploitable2` | `` | [ ] |

***

## 📜 LOG

*One line per command. Newest at the bottom.*

| Title | Command (short) | Result (one line) | Output file |
| :---- | :--------------- | :----------------- | :----------- |
| `Full port scan` | `nmap -Pn -n -sC -sV -p- --min-rate 1000 meta2 -oN recon/nmap-full-meta2.txt` | `Main services: ftp, http, mysql, postgresql, ` | `recon/nmap-full-meta2.txt` |
| `Web ports scan` | `nmap -Pn -n -sV -p 80,514 --script http-enum,http-title,http-methods,http-robots.txt meta2 -oN recon/nmap-http-meta2.txt` | `Apache, methods allowed, ` | `recon/nmap-http-meta2.txt` |

***

## 🛠 TARGET: `172.20.0.2 (meta2)`

### 0. Overview & questions

- **Role / description:** `Entry point for further services / apps / db's`
- **Related questions:** `Qxx, Qyy`

### 1. Discoveries Metasploitable 2

- **Server banner:** `Apache httpd 2.2.8 ((Ubuntu) DAV/2)`
- **Title**: `Metasploitable2 - Linux`
- **Accepted methods:** `GET HEAD POST OPTIONS`
- **Hidden paths**:
```markdown
|   /test/: Test page
|   /phpinfo.php: Possible information file
|   /phpMyAdmin/: phpMyAdmin
|   /doc/: Potentially interesting directory w/ listing on 'apache/2.2.8 (ubuntu) dav/2'
|   /icons/: Potentially interesting folder w/ directory listing
|_  /index/: Potentially interesting folder
```
- **Stack**: 
    - `PHP Version 5.2.4-2ubuntu5.10`    
    - `FTP enabled`
    - `MySQL 5.0.51a`
    - `OpenSSL 0.9.8g 19 Oct 2007`
    - `Session cookie: PHPSESSID=a894c3102d120b1a9d5c9cddaef5eb9f`


#### 1.1 Discoveries Mutillidae

*Facts that look like exam material: versions, paths, headers, error messages, parameters. Each one carries its pivot.*

- **Server banner:** `Apache httpd 2.2.8 ((Ubuntu) DAV/2)` → pivot: `<next step>`
- **Title**: `Metasploitable2 - Linux`
- **Accepted methods:** `GET HEAD POST OPTIONS` (from `curl -i -X OPTIONS`)
- **Framework / tech:** `<tech>` → pivot: `<next step>`
- **Hidden paths / files:** `<path>` (status `<code>`, size `<size>`) → pivot: `<next step>`
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
