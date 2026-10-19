# eWPTv2 Exam: Doubts, FAQ and Exam-Day Mechanics

## Status legend

| Mark | Meaning |
|---|---|
| ✅ | Corroborated by two or more independent sources |
| ⚠️ | Single source (one candidate write-up or your own notes), or a recommendation |
| ❓ | Not verified. Confirm before exam day |

**Sources**

- **S1**: candidate write-up, void4m0n.com (Jan 2024). Passed with 44/50 (88%).
- **S2**: candidate write-up, iworkwithit.blogspot.com, "How I passed the eWPTv2" (Jul 2024).
- **Your notes**: `global-instructions.md`, `study-plan.md`, and the original doubts files.
- **INE official pages**: not reachable when this file was written (the exam page redirects, the pre-exam PDF returns 403). Official confirmation is still needed for every ❓ item.

Ignore blog or cram-site claims of 14 hours, 100 questions, or a PDF report. They conflict with both candidate write-ups and with the INE format in your notes.

---

## 1. Exam at a glance

| Item | Value | Status |
|---|---|---|
| Duration | 10 hours | ✅ S1, S2 |
| Pause behaviour | Assume the timer never stops, including for breaks | ❓ |
| Questions | 50 | ✅ S1, S2 |
| Question types | Mostly multiple choice (4 options). Short-answer questions require exploiting or enumerating to get the exact value (for example a DB name, a version, a password) | ✅ S1 |
| Pass mark | 70% (35 of 50) | ✅ S1 |
| Reporting | No report. You only answer questions | ✅ S1, your notes |
| Previous format | 7 days of lab + 7 days for a PDF report (eWPTv1) | ✅ S1 |
| Proctoring | Unproctored | ⚠️ your notes |
| Grading | Auto-graded. Whether you get results immediately is unknown | ⚠️ / ❓ |
| Access | Browser (Apache Guacamole) into a Kali machine with **no internet access**. Tools are preinstalled | ✅ S1 |
| Host PC | Full internet access. Used for notes, OWASP WSTG, and AI | ⚠️ your notes, ❓ AI use |
| Lab targets | Several web apps on an internal network reachable only from Kali. Web services/APIs and CMS are a large share | ✅ S1, S2 |
| Scoring fine print | Some questions ask for counts (for example "how many SQLi exist"). Missing one costs points | ✅ S1 |
| Reset | Deletes everything on the Kali machine. The lab stays the same and flags already found stay valid unless you change region. Reset button name ❓ | ✅ S1 |
| Lab stability | One candidate had no stability problems that were not self-inflicted. Heavy sqlmap time-based queries were the main cause of freezes | ✅ S1 |

**What this means on the day:** nothing you write on Kali is safe. A reset wipes it. Every answer and every finding must be copied to your host PC or submitted into the portal as soon as you have it.

---

## 2. Doubts answered

### 2.1 Can I install Firefox extensions in the exam (Wappalyzer, FoxyProxy)?

❓ Not confirmed. Plan without them.

- Route the browser through Burp by setting the proxy manually to `127.0.0.1:8080`. This needs no extension.
- For fingerprinting, use the `whatweb` CLI from Kali instead of Wappalyzer. ⚠️
- Kali has no internet access (S1), so you cannot install anything during the exam.

### 2.2 Does `/etc/hosts` accept several domains on one line?

✅ Yes, but separate them with **spaces**, not commas. Commas are not separators in `/etc/hosts`. `10.0.0.5,app.local,api.local` would create one hostname called `app.local,api.local`.

```text
10.0.0.5    app.local api.local shop.local
```

### 2.3 Can I install extensions in Burp's embedded browser?

❓ Unknown. Test it early in the lab environment before relying on it. Do not make your workflow depend on it.

### 2.4 Should I run each phase on all machines at once, or finish one machine at a time?

⚠️ Recommended: **wide first, then deep.** Both candidates used a version of this.

1. Read all questions (10–15 min). This maps the targets and the expected answer types. S1 and S2 both recommend it.
2. Run discovery (`nmap`, low-thread directory discovery, fingerprinting) on **every** target.
3. Pick the target with the most surface. Work its questions until solved or stuck for 30–45 min.
4. Move on and come back later.

The "two passes" method from S2 fits here. Pass 1 is a quick, shallow note on every target. Pass 2 is depth per target, marking ideas as promising or dead.

### 2.5 Screenshots or file redirections for evidence?

⚠️ Recommended: **redirections for command output, screenshots only when needed.**

- The exam has no report, so there is no evidence package to build. Evidence only matters to answer a question.
- Save command output to files with `tee` (for example `nikto -h http://app.local | tee 04-nikto.txt`). This matches the note-the-command, save-the-output method you used for the Drill.
- Screenshot a page only when the answer is visual (a flag on screen, a rendered error). Do not screenshot every exploit, as that costs time.
- `guideline.md` says to "Take screenshots". That conflicts with the "copy to notes, not screenshots" stance above. Use the approach above and keep `guideline.md` in mind for the visual cases.

### 2.6 Is Metasploitable 2 enough to cover the exam?

✅ No. Metasploitable 2 is not a proxy for the exam. It covers some classic vulnerabilities, but the exam targets are separate applications with their own paths and parameters.

Use it as a **practice range** for the commands, the notes workflow, and the target report. Use the exam-style checklist (`4. FINAL STRUCTURE/01 - Info-Gathering-and-Recon/`) to drive the testing.

### 2.7 Should I test endpoints by exact URL or by IP?

✅ Use whatever the question gives you.

- If the question uses a hostname, add it to `/etc/hosts` and test by hostname. Many apps route by the `Host` header, so an IP can return a different site.
- If the question gives an IP, test by IP.
- In your notes, always record the **full URL** (scheme, host, path, parameter) for every finding. That is what questions usually ask for.

### 2.8 What is the approach and set of steps for each phase? How do I find each vulnerability type after enumeration?

⚠️ Use the phase checklist and mapping:

- Phase checklist: `4. FINAL STRUCTURE/01 - Info-Gathering-and-Recon/📋 checklist-and-commands.md`
- INE-to-WSTG mapping: `4. FINAL STRUCTURE/ine-to-wstg.md`

Quick triggers (general method, not INE-specific):

| You see | Test next |
|---|---|
| A parameter reflected in the HTML | XSS. Send a unique marker first, then a context-specific payload |
| SQL error text, or a quote changes the response | SQLi. Manual `'` and boolean tests first, then `sqlmap` with `--technique=BEUSQ --risk=1` (no time-based) |
| A parameter named `file`, `page`, `template`, `include`, `path` | LFI/path traversal (`../../../../etc/passwd`, `php://filter`) |
| A numeric id in a URL or body | IDOR. Change the id and compare responses |
| An upload form | Extension, content-type and double-extension bypasses. Then a web shell |
| `/wp-login.php`, `/wp-content/`, `/wp-json/` | WordPress. `wpscan`, then manual REST calls |
| Base64, hex or JWT-looking values in params or cookies | Decode (CyberChef or `base64 -d`). Check for encoding-based bypasses |
| JSON or XML endpoints | Web services/API. Check methods, content-types, and parameters. S2 says the wordlist choice decides most of this section |

### 2.9 I think I'm overthinking and overworking for the exam

⚠️ Time-box every target. The 30–45 minute rule from section 5 applies. Do not re-check a finished target more than once. S1 spent a lot of time on "did I miss one?" checks. Do one completeness pass per target at the end, not one per finding.

### 2.10 Refine the checklist: reduce phase 0.1 data, note discovery results in phase 1

✅ Done in the Phase 1 checklist. Phase 0.1 holds setup only. Phase 1 holds discovery and enumeration results, one line per host or port.

---

## 3. Exam-day workflow

1. **Read all 50 questions first** (10–15 min). S1 and S2 both recommend this. Note targets, expected answer types, and which questions ask for counts.
2. **Discovery on every target**, low threads (section 6).
3. **Deep dive per target**, using the trigger table in 2.8. Log every finding in the target note (section 5). Start with simple, standard payloads (for example `' OR 1=1-- -`, `<script>alert(1)</script>`, `../../../../etc/passwd`) before any WAF bypass strings. Most exam vulnerabilities use fundamental payloads. (Reddit advice in the original doubts file.)
4. **Submit every answer as soon as you have it.** Do not wait until the end.
5. **Breaks.** A 10-minute break every 2 hours helps fatigue. This is a recommendation only.
6. **Stuck for 30–45 min?** Bookmark it and move to another target.
7. **Freeze or unresponsive target?** Follow the Golden Reset Protocol (section 7).

---

## 4. What to master

Built from S1 and S2. Each item maps to a folder in `4. FINAL STRUCTURE/`.

| Area | Why it matters | Where |
|---|---|---|
| OWASP Top 10 core: SQLi, XSS, file upload, LFI/RFI | Most questions are one of these | `02 - XSS-and-Client-Side/` exists. SQLi, file upload and LFI notes are not yet in the repo |
| Reconnaissance: server and application level | S1 says reconnaissance is the real difficulty. Missing one endpoint means a missed question | `01 - Info-Gathering-and-Recon/` |
| CSRF, path traversal, IDOR | Listed as core topics by S2 | `4. FINAL STRUCTURE/ine-to-wstg.md` |
| CMS: WordPress, Joomla | Called out by S1 and by your notes | Not yet in the repo. Add a `wpscan`/`joomscan` note |
| Web services and APIs | S2: the web services section depends mostly on the wordlist. Know your wordlists | Notes and wordlists |
| Completeness (counts) | S1: questions ask "how many of type X" | Target note, "Vulnerabilities" section |
| Note-taking discipline | S1 and S2 both credit it for speed | Section 5 |

**Not verified:** "API pentesting is a major pillar of v2" (from `study-plan.md`) and "Session Fixation and NoSQL injection" as critical topics. Both are unverified. Treat them as nice-to-know until INE confirms them.

---

## 5. Live documentation

### 5.1 Setup

Use a second screen for the host PC (Obsidian or similar) and the Guacamole session on the first.

Two structures work. Pick one and stay consistent:

**Option A: per-target note (your current idea)**

```text
📁 Exam-Vault/
├── 00-Questions-Map.md          (50 questions, answer, status)
├── Target-A/
│   ├── Recon.md                 (open ports, tech, first pass)
│   ├── Findings.md              (vulns, full URLs, evidence)
│   └── Credentials.md
└── Target-B/
    └── ...
```

**Option B: per-port note (S1, Obsidian)**

```text
Host 1/
  Port 80/  -> Recon, Exploitation, Questions for this port
  Port 443/ -> ...
  Host 1 note -> questions across all ports
All hosts note -> questions for all hosts
```

### 5.2 Live target template

```markdown
# Target: 10.0.X.X (App: [Name])

## Quick Status & Question Mapping
- [ ] Q1: What database version is running? -> Answer: MySQL 8.0.28
- [ ] Q2: Find the admin password in table 'users' -> Answer: P@ssword123!

## Reconnaissance
- Open ports: 80, 443, 8080
- Technologies: PHP 8.1, Apache, MySQL, WordPress

## Intercepted requests & exploit logs
- Vulnerable endpoint: `/api/v1/user?id=1` (IDOR / SQLi)
- Working SQLi payload: `1 UNION SELECT 1,group_concat(username,':',password),3 FROM users-- -`

## Stash / credentials
- admin : $2a$10$...
- user2 : secret2026
```

### 5.3 Findings template

Use this for the Findings file of each target. Keep the format identical across targets so answers are quick to find later.

```markdown
Target: 10.x.x.x (hostname if any)
- Service/tech: Apache 2.4, PHP 8.0
- Vulnerability: SQL injection on https://app.local/login.php, parameter `user`
- Evidence: database name is `production_db`
- Screenshot (only if needed): ./screenshots/sqli_proof.png
```

### 5.4 Clipboard

Guacamole clipboard drawer: `Ctrl` + `Alt` + `Shift` (Windows/Linux). Mac shortcut ❓. Check it in the lab before the exam.

---

## 6. Tools, stability and thread limits

### 6.1 Tools

| Tool | Reported by | Status / note |
|---|---|---|
| Burp Suite (Community) | Your notes | ❓ Edition. Assume CE |
| nmap | S1, your notes | ✅ Essential |
| nikto | S1, your notes | ✅ S1 used it at the end as a completeness check |
| feroxbuster | S1 (favourite) | ✅ S1 |
| wfuzz | S1 | ✅ S1 |
| gobuster | Your notes | ⚠️ |
| ffuf | Your notes | ⚠️ |
| dirbuster | Your notes | ❓ Not confirmed on the exam image |
| sqlmap | S1, your notes | ✅ |
| hydra | S1, your notes | ✅ S1: brute force is low priority |
| wpscan | S1, your notes | ✅ |
| joomscan | S1 | ✅ S1 |
| hashcat | S1, your notes | ⚠️ S1's copy did not work in the lab. Have John the Ripper as backup |
| John the Ripper | S1 | ✅ Works in the lab |
| msfconsole | Your notes | ❓ |
| CyberChef | Your notes | ❓ Web app on host works regardless |
| searchsploit | Your notes | ❓ |
| SecLists / rockyou | Your notes | ❓ Confirm paths on the exam image |
| Python 3, curl, netcat | Your notes | ❓ Confirm |

**Action:** before the exam, run `which <tool>` in the lab (or the practice image) for every ❓ tool.

### 6.2 Thread and stability limits

- `gobuster` / `ffuf` / `feroxbuster`: `-t 10` to `-t 20`. Do not run `-t 100`. (Your notes.)
- `sqlmap`: `--threads=1` or `2`. Use `--risk=1` (the default) and `--technique=BEUSQ`, which excludes time-based. S1 says time-based queries made the lab unresponsive and forced a reset. (S1, your notes.)
- Run one heavy tool at a time. Stop background brute-force scripts before doing anything else.

### 6.3 Automation templates (host PC only)

Do not write full frameworks during the exam. Keep these ready on the host.

**Python `requests` (authenticated repeated requests)**

```python
import requests

url = "http://TARGET_IP/vulnerable_endpoint.php"
cookies = {"PHPSESSID": "YOUR_EXAM_SESSION_COOKIE"}
headers = {"User-Agent": "Mozilla/5.0"}

for i in range(1, 100):
    params = {"id": f"{i}"}
    r = requests.get(url, params=params, cookies=cookies, headers=headers)
    if "admin" in r.text:
        print(f"[+] Found matching ID: {i}")
```

**sqlmap one-liners**

```bash
sqlmap -u "http://TARGET/page.php?id=1" --cookie="PHPSESSID=xxx" --batch --dbs --risk=1 --technique=BEUSQ --threads=2
sqlmap -u "http://TARGET/page.php?id=1" -D target_db -T users --dump --batch --threads=2
sqlmap -r request.txt --batch --dbs
```

---

## 7. Golden Reset Protocol (corrected)

The original protocol only covered submitting answers. S1 shows a reset also **wipes the Kali machine**, so notes stored there are lost. The protocol now includes copying notes out.

1. **Pause:** stop all scans and background brute-force jobs.
2. **Flush to the portal:** submit every answer you have found into the INE exam interface.
3. **Flush to the host:** copy your notes and any useful output from Kali to the host PC (Guacamole clipboard or a text file you copy across).
4. **Reset:** click the reset button in the exam interface.
5. **Verify:** check that the submitted answers are still there. Continue with the remaining targets. S1 says found flags stay valid after a reset.

---

## 8. Vault structure (kept from the root doubts file)

```text
📁 My-eWPT-Vault/
│
├── 📋 01-Phases-and-Checklists/         <-- (High-level process)
│   ├── 01-Recon-and-Directory-Enum.md
│   ├── 02-Authentication-and-Sessions.md
│   ├── 03-Input-Validation-Checklist.md
│   └── 04-CMS-and-Web-Services-Checklist.md
│
├── 💣 02-Vulnerabilities-and-Payloads/  <-- (Exploit reference)
│   ├── 01-SQL-Injection/                (Bypasses, sqlmap cheat sheets, UNION payloads)
│   ├── 02-XSS-Reflected-and-Stored/     (Context bypasses, polyglots)
│   ├── 03-File-Inclusion-LFI-RFI/       (Wrappers, path traversals, log poisoning)
│   ├── 04-File-Upload-to-RCE/           (Bypasses, web shells: PHP, ASPX)
│   ├── 05-IDOR-and-CSRF/                (Logic bypasses, token analysis)
│   └── 06-CMS-WordPress/                (wpscan flags, API enumeration)
│
├── 🛠️ 03-Tools-and-Automation/           <-- (Commands and scripts)
│   ├── Burp-and-ZAP-Cheatsheet.md
│   ├── Python-Requests-Template.py
│   └── Fuzzing-Wordlists.md
│
└── 🎯 04-Exam-Workspace/                 <-- (Used on exam day)
    └── Target-Scratchpad-Template.md
```

The repo's `4. FINAL STRUCTURE/` already follows this layout for the Phase 1 material. Keep the two in sync.

---

## 9. Methodology notes (summarised from `guideline.md`)

`guideline.md` stays as its own file. This section keeps the points that matter on exam day.

- **Question hunt (first 15 min):** read all 50 questions before touching a tool.
- **Wide discovery (first ~2 h):** start scans on every target. Nmap, low-thread directory discovery, fingerprinting.
- **Deep dive:** pick the target with the most surface and work it.
- **Core WSTG categories to prioritise:** INFO (information gathering, banners, hidden files), ATHN/ATHZ (authentication and authorisation, brute force, IDOR), INPV (input validation: SQLi, XSS, command injection), SESS (session management: cookie flags, fixation).
- **Use the WSTG as a checklist, not a textbook.** It is too dense to read during the exam. When a target is done, check your one-page list for missed IDs, for example `WSTG-INFO-03` (metadata leakage).
- **Find commands fast:** keep the notes searchable. Any command should be findable in under 5 seconds. Short bullets, bold for key flags.
- **Division of labour:** the checklist says *what* to test, your notes say *how* (commands and payloads), and the findings file records the *result*.
- **Tool preparation:** keep one cheat sheet per tool, for example `sqlmap -r request.txt --batch --dbs`, `ffuf -u http://target/FUZZ -w <wordlist>`, and PHP and Bash reverse-shell one-liners.

---

## 10. Interface reference (illustrative, not verified)

```text
 ┌────────────────────────────────────────────────────────────────────────┐
 │                      INE EXAM INTERFACE (Browser)                      │
 ├───────────────────────────────────┬────────────────────────────────────┤
 │  LEFT PANE: EXAM PLATFORM         │ RIGHT PANE: VIRTUAL KALI DESKTOP   │
 │                                   │ (Apache Guacamole HTML5 canvas)    │
 │  • Exam timer                     │                                    │
 │  • Target network scope info      │  ┌──────────────────────────────┐  │
 │  • 50 questions and input fields  │  │ Kali terminal / Burp Suite   │  │
 │  • [ Submit answer ] buttons      │  │                              │  │
 │  • [ Reset lab ] button           │  │                              │  │
 │                                   │  └──────────────────────────────┘  │
 └───────────────────────────────────┴────────────────────────────────────┘
```

- Navigation between questions: ❓ (the original notes say "freely"). Confirm in the lab.
- Answer feedback: ❓. The original notes say no instant right/wrong feedback. Confirm in the lab.

---

## 11. Open questions and loose ends

These are the items still needing an answer. Confirm each from the INE pre-exam manual or support before exam day.

| # | Question | Current understanding | Status |
|---|---|---|---|
| 1 | Is any report required? | No (S1, your notes) | ✅ / confirm |
| 2 | Are browser extensions allowed in Kali? | Plan without them | ❓ |
| 3 | Can Burp's embedded browser use extensions? | Unknown | ❓ |
| 4 | Does the Kali VM have any internet access? | No (S1) | ✅ / confirm |
| 5 | Is AI use on the host PC allowed? | Unknown. Assume not until confirmed | ❓ |
| 6 | Is the exam proctored? | Unproctored (your notes) | ⚠️ |
| 7 | Does the timer pause for breaks? | Assume not | ❓ |
| 8 | Do answers get instant feedback? | Unknown | ❓ |
| 9 | Exact tool list on the exam image | See section 6.1 | ❓ |
| 10 | Screenshots vs redirects | Section 2.5: redirects for output, screenshots when needed | ⚠️ |
| 11 | Symptoms: patterns for each scenario | Use the trigger table in 2.8 and add to it as you practise | ⚠️ |
| 12 | WSTG has 182 scenarios. How to use it for these questions | Do not read the whole WSTG. Use `ine-to-wstg.md` and only the categories it maps | ⚠️ |
| 13 | Voucher: has the 6-month wait affected it? Does the expiry start at purchase? | Unknown. Check the expiry date in your INE account and ask INE support | ❓ |

---

## 12. Repo items that need correcting

These mismatches with the eWPTv2 exam were found while merging. The FAQ above is the source of truth for them until the other files are updated.

| File | Problem | Action |
|---|---|---|
| `global-instructions.md` | Old folder names (`6. FINAL STRUCTURE`, `7. DRILL`, `5. EXAM PROCEDURE`). Exam facts unverified | Update folder names and link this FAQ |
| `study-plan.md` | "Auto-graded" and "no report" match your notes, but the "Reddit-gold" and "3 critical factors" section has unverified claims (for example "VPN stability in Spain", "API pentesting is a major pillar", "Session Fixation and NoSQL injection") | Mark as unverified or remove |
| `3. EXAM STRATEGY/guideline.md` | "Take screenshots", `FINDINGS.txt`, and reverse-shell advice conflict with section 2.5 | Align with section 2.5 |
| `4. FINAL STRUCTURE/...` | Phase 1 is aligned. Other phases still need the same review | Phase 2 is out of scope for now |

---

## Sources

- void4m0n.com, "eWPTv2" (Jan 2024). Candidate write-up, 88%.
- iworkwithit.blogspot.com, "How I passed the eWPTv2" (Jul 2024). Candidate write-up.
- Your own notes: `global-instructions.md`, `study-plan.md`, `3. EXAM STRATEGY/guideline.md`, and the original doubts files.
- Not used: a Medium write-up (403), and cram or blog sites whose formats conflict with the candidate write-ups.
