# eWPTv2 EXAM SESSION: `YYYY-MM-DD`

**Start:** `HH:MM` · **Stop:** `HH:MM` · **Passing score:** `35 / 50 (70%)`

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
| `<IP>` | `<app>` | `<stack>` | [ ] |

***

## 📜 LOG

*One line per command. Newest at the bottom.*

| # | Time | Command (short) | Result (one line) | Output file |
| :- | :--- | :-------------- | :---------------- | :---------- |
| 1 | `HH:MM` | `nmap -sC -sV <IP>` | `21 ftp, 80 http Apache 2.2.8` | `recon/nmap-full-<IP>.txt` |

***

## 🛠 TARGET: `<IP>`

### 0. Overview & questions

- **Role / description:** `<role>`
- **Related questions:** `Qxx, Qyy`

### 1. Discoveries

*Facts that look like exam material: versions, paths, headers, error messages, parameters. Each one carries its pivot.*

- **Server banner:** `<banner>` → pivot: `<next step>`
- **Accepted methods:** `<methods>` (from `curl -i -X OPTIONS`)
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
