# eWPTv2 Guideline

One file for the eWPTv2 exam: facts, scope, workflow and preparation. Per-category commands live in `4. FINAL STRUCTURE/`. Source-backed exam details and open questions live in [exam_doubts_faq.md](<exam_doubts_faq.md>).

Status marks: ✅ corroborated by two or more sources · ⚠️ single source or recommendation · ❓ unverified, confirm before exam day.

---

## 1. Exam facts

| Item | Value | Status |
| --- | --- | --- |
| Duration | 10 hours. Assume the timer never pauses, breaks included | ✅ / ❓ |
| Questions | 50, mostly multiple choice. Some need an exact value (DB name, version, password, flag) | ✅ |
| Pass mark | 35 of 50 (70%) | ✅ |
| Deliverable | No report. Answers only | ✅ |
| Grading | Auto-graded, unproctored | ✅ / ⚠️ |
| Access | Browser (Apache Guacamole) into Kali. Tools preinstalled. **No internet on Kali** | ✅ |
| Host PC | Internet access. Use it for notes, the WSTG and copying output | ⚠️ |
| Targets | Several web apps on an internal network, reachable only from Kali. Web services/APIs and CMS are a large share | ✅ |
| Input | Paste text only. Complex files and scripts cannot be uploaded | ⚠️ |
| Reset | Wipes the Kali machine, so local notes are lost. Found flags stay valid | ✅ |

**What this means on the day**

- **Nothing on Kali survives a reset.** Copy notes and answers to the host after each finding.
- **You can miss 15 questions.** Two hours on one question is a bad trade. Park it and come back.
- **Answers are exact strings or options.** Copy the value from the response; do not paraphrase it.

---

## 2. Scope: what gets tested

Source: [ine-to-wstg.md](<../4. FINAL STRUCTURE/ine-to-wstg.md>). Use the WSTG IDs below as a checklist. Do not read the full WSTG (182 scenarios).

| # | Area (INE folder) | WSTG IDs | Why it is in scope |
| --- | --- | --- | --- |
| 1 | Recon and metafiles (`01`) | INFO-01 to 07, 10; CONF-01, 02, 05, 06, 10 | A missed endpoint loses every question behind it |
| 2 | SQL injection (`03`) | INPV-05 | Core OWASP. Count questions |
| 3 | XSS and client side (`02`) | INPV-01, 02; CLNT-01 to 14 | Reflected, stored and DOM. Filter bypass |
| 4 | File and resource attacks (`04`) | INPV-07, 11, 12; ATHZ-01; CONF-03, 04, 09, 11 | LFI/RFI, path traversal, uploads, command injection, XXE, backups |
| 5 | Auth, session, access control (`05`) | IDNT, ATHN, ATHZ-02 to 05, SESS-01 to 10 | IDOR, CSRF, auth bypass, cookie flags |
| 6 | Web services and APIs (`06`) | APIT-01; INPV-03, 19, 20 | Large share. Wordlist choice drives results. SSRF |
| 7 | CMS (`07`) | INFO-08, 09 | WordPress and Joomla. wpscan, joomscan |
| 8 | Encoding, filters, evasion (`08`) | INPV-04, 06, 08 to 10, 13 to 18; ERRH; CRYP | WAF bypass, SSTI, HPP, smuggling, error traces |

Not prioritised (unverified in the FAQ): NoSQL injection as a login-form specialty, and session fixation as a must-have. Test them only when a symptom appears.

---

## 3. Workflow

**Why this order:** 35 of 50 rewards breadth. Recon comes first, then depth on the best target. Submit each answer as soon as you have it.

### 3.1 Before exam day

1. Run the practice loop on the Metasploitable2 range (`4. FINAL STRUCTURE/01 - Info-Gathering-and-Recon/Metasploitable2/`). It is a practice range, not a proxy for the exam.
2. Run the tool check on the practice image. Missing tools are skipped on exam day, not installed. See [startup-checklist](<../4. FINAL STRUCTURE/00-Exam-Setup-and-Proxies/startup-checklist.md>).
3. Prepare the single target file from [target-report-template](<../2. REPORTS/target-report-template.md>) and your cheatsheet.
4. Clear the open items in section 6.

### 3.2 Hour 0 to 0:20: map

1. Read all 50 questions. For each, note the number, target, answer type (value, count, option) and any dependency.
2. Map every IP to its app, stack and questions in the target map.
3. Add hostnames to `/etc/hosts` on one line, separated by spaces.
4. Set up Burp: scope, intercept off. Use Burp's embedded browser, or a browser proxied to `127.0.0.1:8080`.

### 3.3 Hour 0:20 to 2:00: wide discovery (every target)

1. Nmap the web ports of every target, then `-sC -sV` per host.
2. Fingerprint each web host with `whatweb`.
3. Directory brute force each web host with `-t 10` to `-t 20`.
4. Save output with `tee` into `recon/`. Log each command in one line.

### 3.4 Hour 2:00 to 7:30: deep dive, one target at a time

1. Pick the target with the most surface (open ports, most questions).
2. For each endpoint, match the trigger table, test, confirm, log, submit.
3. Stuck for 30 to 45 minutes? Park it and move on.

| You see | Test next |
| --- | --- |
| Parameter reflected in HTML | XSS. Send a unique marker first, then a context payload |
| SQL error, or a quote changes the response | SQLi. Manual `'` and boolean tests, then sqlmap (section 5) |
| Parameter named `file`, `page`, `template`, `include`, `path` | LFI and path traversal (`../../../../etc/passwd`, `php://filter`) |
| Numeric ID in URL or body | IDOR. Change the ID and compare responses |
| Upload form | Extension, content-type and double-extension bypass. Then a web shell |
| `/wp-login.php`, `/wp-content/`, `/wp-json/` | WordPress. wpscan, then manual REST calls |
| Base64, hex or JWT-looking values | Decode (`base64 -d`, CyberChef on host). Check encoding bypasses |
| JSON or XML endpoints | API or web service. Check methods, content types, parameters |

Start with standard payloads (`' OR 1=1-- -`, `<script>alert(1)</script>`, `../../../../etc/passwd`). Bypass strings come after.

### 3.5 Hour 7:30 to 9:00: completeness

1. One pass per target against the WSTG walkthrough (`🧭 phase-walkthrough.md`), only the IDs that apply.
2. For count questions ("how many X"), re-test every endpoint, not only the first one you found.
3. Finished targets get one completeness pass, not one per finding.

### 3.6 Hour 9:00 to 10:00: close out

1. Submit everything. For unsolved options, submit your best guess (no penalty is documented ❓).
2. After any reset, check that the answers still show.

Breaks: 10 minutes every 2 hours (⚠️ recommendation). The hour markers are a plan, not measured data.

### 3.7 Freeze or reset

1. Stop all scans and background jobs.
2. Submit every answer you have.
3. Copy notes and useful output from Kali to the host.
4. Reset, verify the submitted answers, and continue.

---

## 4. Notes: what to record

- **Note first, paste nothing.** One line per command: command, result, pivot. Example pivot: `Apache 2.2.8 → check version CVEs`.
- **Save long output.** Anything longer than one screen goes to `recon/` via `tee`. Quick `curl -I` or `dig +short` checks need no file.
- **Record the full URL** (scheme, host, path, parameter) for every finding. Questions ask for it.
- **Screenshot only visual answers** (a flag on screen, a rendered error). Do not screenshot every exploit.
- **Skip:** banners, wordlist progress, repeated 404s, the same scan twice. Log a dead end in one line only if it rules out a path.
- **Where things go** in the target file: target map, log, discoveries, findings, credentials, question scratchpad, next steps.

---

## 5. Tool rules

| Tool | Rule |
| --- | --- |
| gobuster, ffuf, feroxbuster | `-t 10` to `-t 20`. Never `-t 100` |
| sqlmap | `--technique=BEUSQ --risk=1 --threads=2 --batch`. Never time-based (`T`). Example: `sqlmap -r request.txt --batch --dbs` |
| Heavy tools | One at a time. Stop background brute force first |
| hydra | Low priority. Brute force is rarely the answer (S1) |
| hashcat | Unreliable in S1's lab. Use John the Ripper as the fallback |
| nikto | Completeness check at the end |
| Scripts | Cannot be uploaded. Paste one-liners, or go manual |

If a tool fails, switch to a manual payload. Commands: [📜 cheatsheet](<../4. FINAL STRUCTURE/01 - Info-Gathering-and-Recon/📜 cheatsheet.md>). Theory: [📝 notes](<../4. FINAL STRUCTURE/01 - Info-Gathering-and-Recon/📝 notes.md>).

---

## 6. Open items: confirm before exam day

The default applies if you cannot confirm it.

| Item | Default |
| --- | --- |
| Timer pauses for breaks | No pause |
| Firefox extensions in Kali (Wappalyzer, FoxyProxy) | Not available. Set the proxy manually and use `whatweb` |
| Extensions in Burp's embedded browser | Do not depend on them |
| Exam browser | Chrome (community advice ⚠️). Test in the lab |
| Clipboard shortcut in Guacamole | `Ctrl` + `Alt` + `Shift`. Test in the lab |
| Exact tool list (dirbuster, msfconsole, searchsploit, SecLists path) | Run `command -v` on the practice image |
| Burp edition | Community. Projects cannot be saved, so export items with Save item |
| AI use on the host PC | Not allowed until confirmed |
| Answer feedback, question navigation | None, free navigation |
| INE voucher expiry | Check the account now and ask INE support |

---

## 7. Preparation order and readiness gates

Gates are recommendations (⚠️). The course is complete per your notes, so use labs to build speed, not to learn from scratch.

| Order | Topic | Practice | Ready when |
| --- | --- | --- | --- |
| 1 | Recon and metafiles | Recon checklist on Metasploitable2 | You list hosts, ports, stack and hidden paths on a fresh target in under 30 min |
| 2 | SQL injection | `1. NOTES/5. SQL Injection/`, PortSwigger SQLi labs ([map](<../4. FINAL STRUCTURE/port_swigger_categories.md>)) | You get the DB version and a table dump by hand, and with sqlmap using BEUSQ |
| 3 | XSS | `1. NOTES/4. CROSS-SITE SCRIPTING (XSS)/` | You write a working payload for HTML, attribute and JS-string contexts without notes |
| 4 | File attacks: LFI, traversal, upload, command injection | `1. NOTES/7. FILE AND RESOURCE ATTACKS/` | You read a file via traversal and reach a web shell through an upload |
| 5 | Auth, session, IDOR, CSRF | `1. NOTES/6. COMMON ATTACKS/` | You find an IDOR by changing an ID and comparing responses |
| 6 | Web services, APIs, SSRF | `1. NOTES/8. WEB SERVICE SECURITY TESTING/` | You enumerate endpoints from a spec and test methods and content types |
| 7 | CMS | `1. NOTES/9. CMS SECURITY TESTING/` | wpscan and joomscan give the version and a vulnerable plugin |
| 8 | Encoding and WAF bypass | `1. NOTES/10. ENCODING, FILTERING AND EVASION BASICS/` | You bypass a basic filter with encoding or case change |
| Last | Full re-run | INE labs, reading only the statement | Each category solved cold |

**Go to the exam only when:** every row meets its gate, a full Metasploitable2 dry run (recon, checklist, findings file) fits your time plan, and every item in section 6 is answered.

---

## 8. Do not

- Read the full WSTG during the exam. Use the IDs in section 2.
- Test a hostname by IP. Many apps route on the `Host` header.
- Run time-based sqlmap, `-t 100`, or two heavy tools at once. A freeze forces a reset.
- Screenshot every exploit, or paste raw output into notes.
- Chase NoSQL injection or session fixation without a symptom.
- Hold answers until the end. Submit each one as soon as you have it.
- Re-check a finished target more than once.
