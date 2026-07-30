Here is a detailed, comprehensive breakdown of everything you need to know about the INE eWPT exam, addressing all 10 of your questions.

---

## 1. Exam Mechanics & Structure

The eWPT (eWPTv2) is a **100% hands-on, practical CTF-style web application penetration test**.

* **Duration:** **10 hours continuous**. The timer starts the second you click "Start Exam" and does *not* pause for breaks, meals, or sleep.
* **Questions:** **50 questions** in total. These consist of multiple-choice, multi-select, and fill-in-the-blank text inputs (e.g., entering extracted database names, specific admin passwords, or vulnerability flags).
* **Passing Score:** **70%** (you need roughly 35 out of 50 correct answers to pass).
* **Target Environment:** You are dropped into a virtual network containing multiple target web applications hosting various vulnerabilities (SQLi, XSS, File Upload, LFI/RFI, CSRF, IDOR, Web Services/APIs, CMS platforms).

---

## 2. Available Resources & Tools

You perform the entire exam inside an **in-browser virtual desktop (Apache Guacamole)** running a fully equipped **Kali Linux VM**.

### Installed Tools on the Exam Kali Machine

* **Proxy & Interception:** Burp Suite (Community Edition).
* **Reconnaissance & Scanning:** `nmap`, `nikto`, `wpscan`, `dirbuster`, `gobuster`, `ffuf`.
* **Exploitation & Frameworks:** `sqlmap`, Metasploit Framework (`msfconsole`), Hydra, John the Ripper, Hashcat.
* **Standard Utility Tools:** Python 3, Curl, Netcat, CyberChef, Searchsploit, common Linux wordlists (SecLists / RockYou).

### Network & Resource Isolation

* **Inside the Kali VM:** There is **NO internet connection**. The VM can only reach internal lab IPs. You cannot `apt-get install` new tools or `git clone` repositories dynamically during the exam.
* **On Your Host PC:** You have **FULL internet access**. You can browse Google, read the OWASP WSTG, check your personal notes, or consult AI.

---

## 3. Handling Environment Freezes & Stability Issues

Reddit threads frequently mention lab freezes or targets failing to respond. Web application DBs or web servers can freeze if flooded with aggressive traffic.

### Best Practices to Prevent and Handle Environment Freezes

1. **Never Over-Thread Your Tools:** This is the #1 cause of crashes. Keep tool threads low:
* `gobuster` / `ffuf`: Limit to `-t 10` or `-t 20` max (do NOT run `-t 100`).
* `sqlmap`: Keep `--threads=1` or `2` max.


2. **Submit Answers IMMEDIATELY:** Once you uncover a flag, password, or answer, **type and submit it into the exam question panel right away**. Do *not* wait until the end of the exam.
3. **Copy Proof to Host PC in Real-Time:** Do not store critical notes or extracted payloads solely inside Kali's temporary memory or volatile files. Use the shared clipboard to back up findings to Obsidian/Notion on your host machine instantly.
4. **Use the "Reset Environment" Button Wisely:** If a target web app crashes or stops responding to payloads that should work, use the "Reset Lab" button in the INE exam interface.
* *Note:* Resetting restores target applications to their original state. The exam timer keeps running, but your previously submitted answers remain saved.



---

## 4. Live Documentation Strategy

Because you do not submit a report, exam documentation serves one purpose: **preventing lost time, re-running redundant attacks, or losing track of progress.**

### Recommended Setup: Dual Screen / Split View

Keep your **Exam Browser (Guacamole)** on one screen and **Obsidian** on your host PC on the second screen.

### Live Exam Logging Structure

Set up an "Exam Target Workspace" note in Obsidian using this structure:

```markdown
# Target: 10.0.X.X (App: [Name])

## Quick Status & Question Mapping
- [ ] Q1: What database version is running? -> Answer: MySQL 8.0.28
- [ ] Q2: Find the admin password in table 'users' -> Answer: P@ssword123!

## Reconnaissance
- Open Ports: 80, 443, 8080
- Technologies: PHP 8.1, Apache, MySQL, WordPress

## Intercepted Requests & Exploit Logs
- Vulnerable Endpoint: `/api/v1/user?id=1` (Vulnerable to IDOR / SQLi)
- Working SQLi Payload: `1 UNION SELECT 1,group_concat(username,':',password),3 FROM users-- -`

## Stash / Credentials
- admin : $2a$10$...
- user2 : secret2026

```

Use the Apache Guacamole slide-out menu (`Ctrl` + `Alt` + `Shift` on Windows/Linux or `Cmd` + `Ctrl` + `Shift` on Mac) to copy text between Kali and host PC smoothly.

---

## 5. Top Reddit Advice for eWPT

1. **Preview ALL 50 Questions FIRST:** Before running single port scans, spend 10 minutes reading every question. The questions act as a roadmap: they tell you which target IPs exist, what directories/parameters to look for, and what vulnerability types to focus on.
2. **Follow a Strict Methodology (Don't Tunnel Vision):** If you spend more than 30–45 minutes stuck on one question or parameter, leave a bookmark and move to another target app.
3. **Master CMS Enumeration (`WPScan`):** WordPress and other CMS targets feature prominently. Know how to enumerate plugins, themes, and users via `wpscan --api-token` or manual REST API endpoints (`/wp-json/wp/v2/users`).
4. **Don't Over-Complicate Payloads:** Most exam vulnerabilities use standard, fundamental payloads. Start simple (e.g., standard `' OR 1=1-- -`, basic `<script>alert(1)</script>`, standard relative path traversal `../../../../etc/passwd`) before trying complex WAF bypass strings.
5. **Take Mandatory Rest Breaks:** 10 hours is long enough to cause severe cognitive fatigue. Taking a 10-minute break every 2 hours to step away from the monitor re-energizes your analysis.

---

## 6. Format Verification

> **Is it true that the new format is 10 hours and 50 questions, with NO report?**

**Yes, this is 100% correct.**

The legacy eWPTv1 format (which allowed 7 days of lab access followed by 7 days for PDF report writing) was retired. The current INE eWPT format is strictly a **10-hour practical CTF exam with 50 platform questions and zero report delivery.**

---

## 7. Automation & Scripting Strategy

Do **not** waste time attempting to write complex full-application automation frameworks during or prior to the exam.

Instead, prepare **micro-scripting templates** on your host PC:

### 1. Python `requests` Template

Have a ready-to-use Python snippet for authenticated web requests to automate repetitive string testing or multi-step requests:

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

### 2. Standard Command One-Liners

Keep command line cheat sheets for tools like `sqlmap` ready:

* `sqlmap -u "http://TARGET/page.php?id=1" --cookie="PHPSESSID=xxx" --batch --dbs`
* `sqlmap -u "http://TARGET/page.php?id=1" -D target_db -T users --dump`

---

## 8. Internet Access, AI, and Proctoring

* **Proctoring:** The eWPT exam is **UNPROCTORED**. There is no webcam monitoring, no microphone recording, and no live screen-sharing monitor watching you.
* **Internet Usage:** You have unrestricted internet access on your host machine.
* **Using AI:** You can freely use AI models (Gemini Pro, Copilot, ChatGPT) on your host PC during the exam.
* *Note:* Because the AI cannot connect to your air-gapped exam environment, you will manually paste intercepted HTTP requests, source code snippets, or error messages into the AI to ask for payload suggestions or script modifications.



---

## 9. Exam UI & Functionality

```
 ┌────────────────────────────────────────────────────────────────────────┐
 │                      INE EXAM INTERFACE (Browser)                      │
 ├───────────────────────────────────┬────────────────────────────────────┤
 │  LEFT PANE: EXAM PLATFORM         │ RIGHT PANE: VIRTUAL KALI DESKTOP   │
 │                                   │ (Apache Guacamole HTML5 Canvas)    │
 │  • Exam Timer (e.g., 09:42:15)    │                                    │
 │  • Target Network Scope Info      │  ┌──────────────────────────────┐  │
 │  • 50 Questions & Input Fields    │  │ Kali Terminal / Burp Suite   │  │
 │  • [ Submit Answer ] Buttons      │  │                              │  │
 │  • [ Reset Lab Environment ]      │  │                              │  │
 │                                   │  └──────────────────────────────┘  │
 └───────────────────────────────────┴────────────────────────────────────┘

```

* **Dynamic Navigation:** You can jump between any of the 50 questions freely.
* **Answer Validation:** When you click "Submit" on a question, it saves your answer. (You do not get instant right/wrong feedback on questions; final grading occurs when you finish or the timer expires).
* **Shared Clipboard Drawer:** Pressing `Ctrl` + `Alt` + `Shift` inside the virtual desktop brings up an slide-out text box that bridges host PC copy-pasting to Kali VM text buffers.

---

To pass the eWPT smoothly, begin by reading all 50 questions to build a map of your targets. Treat the WSTG as a step-by-step checklist, run directory enumeration tools with low thread counts to maintain lab stability, and enter every flag into the portal as soon as it is found. Keeping your Obsidian vault structured on a second monitor while using your work AI tools for quick payload troubleshooting will keep your workflow fast, calm, and organized.

---

## 10. Doubts

### The Golden Reset Protocol

What happens if I have answers in my notepad but not submitted, and the environment freezes?

To prevent losing progress or having to re-exploit targets, follow this exact 3-step checklist whenever you need to trigger a lab reset:

1. **Pause:** Stop all active terminal scans or background brute-force scripts.
2. **Flush to Portal:** Review your notepad and **copy/submit every discovered flag or answer directly into the INE exam interface** before touching the reset button.
3. **Execute Reset:** Once all discovered answers are submitted into the web portal, click **Reset Lab Environment**.

Once the new lab loads, your previously submitted answers stay saved in the portal, and you can focus entirely on the remaining targets without repeating past work.

### About structure

#### Recommended Optimized Vault Structure

```text
📁 My-eWPT-Vault/
│
├── 📋 01-Phases-and-Checklists/         <-- (High-Level Process)
│   ├── 01-Recon-and-Directory-Enum.md
│   ├── 02-Authentication-and-Sessions.md
│   ├── 03-Input-Validation-Checklist.md
│   └── 04-CMS-and-Web-Services-Checklist.md
│
├── 💣 02-Vulnerabilities-and-Payloads/  <-- (Direct Access to Exploit Reference)
│   ├── 01-SQL-Injection/                (Bypasses, sqlmap cheat sheets, UNION payloads)
│   ├── 02-XSS-Reflected-and-Stored/     (Context bypasses, polyglots)
│   ├── 03-File-Inclusion-LFI-RFI/       (Wrappers, path traversals, log poisoning)
│   ├── 04-File-Upload-to-RCE/           (Bypasses, web shells: PHP, ASPX)
│   ├── 05-IDOR-and-CSRF/                (Logic bypasses, token analysis)
│   └── 06-CMS-WordPress/                (wpscan flags, API enumeration)
│
├── 🛠️ 03-Tools-and-Automation/           <-- (Commands & Scripts)
│   ├── Burp-and-ZAP-Cheatsheet.md
│   ├── Python-Requests-Template.py
│   └── Fuzzing-Wordlists.md
│
└── 🎯 04-Exam-Workspace/                 <-- (Used on Exam Day)
    └── Target-Scratchpad-Template.md

```
### Loose ends

- Screenshots
- Symptoms. Knowing the steps for each scenario. Identify patterns.
- When applying WSTG, the list has 182 vulnerability scenarios. How do I adjust my usage of the guide to the questions of the exam.
- Voucher: 6 months have passed since I subscribed. Does it affect my voucher somehow? I think the expiration starts since the confirmation of the purchase, right?