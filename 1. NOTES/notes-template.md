
# eWPT Study Note Template

**Video/Lesson Title:**  
**Category:** #Exploit | #Methodology | #Theory | #Config  
**Topic:** SQL Injection | XSS | File Upload | Auth Bypass  
**Module:** [[Module Name]]

---

### 🎯 The "Rule of 3" Summary

- **Core Concept (What):**  
- **Detection (Sign it exists):**  
- **Solution (Main tool/command):**  

---

### 🛠️ 1. Technical Exploit (Payloads)

> Use for: SQLi, XSS, LFI, RCE, etc.

- **Attack logic:**  
- **Target parameter(s):** `id=`, `search=`, `User-Agent`, etc.  
- **Payloads (several variants):**
```http
# Basic payload
' OR 1=1 --

# Time-based  
' AND (SELECT SLEEP(5)) --

# Union-based
' UNION SELECT 1,2,database(),version() --
```

- **Bypass techniques:**  
  - Double URL encoding  
  - Case changes  
  - Alternate headers  
  - Time-based vs error-based  

- **Proof of Concept:** ![[Screenshot_Path]]

---

### 🗺️ 2. Methodology & Workflow

> Use for: Recon, scanning, enumeration, manual testing approaches.

- **Step-by-step process:**
  1. Nmap scan: `nmap -sV -Pn 10.x.x.x`  
  2. Directory brute-force: `ffuf -u http://target/FUZZ -w wordlist.txt`  
  3. Parameter discovery in Burp → Send to Intruder  

- **IF / THEN logic:**
  - **IF** status code 403 → **THEN** header bypass (`X-Forwarded-For: 127.0.0.1`)  
  - **IF** Port 80 open → **THEN** check `/robots.txt`, `/sitemap.xml`, default paths  

---

### 🧠 3. Theory & Fundamentals

> Use for: HTTP basics, cookies, SOP, CORS, auth flows, API design, etc.

- **Simple explanation:**  
- **Hacker's perspective:**  
- **Mental model / analogy:**  
  - "A JWT is like a sealed envelope: you can read who sent it and what it's for, but you shouldn't be able to change it without breaking the seal."

---

### 🔧 4. Tool & Environment Config

> Use for: Burp Suite setup, browser add-ons, sqlmap flags, ffuf options.

- **Setup steps:**  
  - Configure Burp proxy and import certificate  
  - Install FoxyProxy browser extension  

- **Common errors & fixes:**
  - **Problem:** Scan is too slow  
    **Fix:** Reduce threads to 5 (`ffuf -t 5`)  
  - **Problem:** Proxy errors in browser  
    **Fix:** Check proxy settings and Burp certificate  

- **Shortcuts / efficiency tips:**  
  - Right-click → Send to Repeater/Intruder  
  - Ctrl+Shift+R (Burp Repeater)  

---

### 🔗 Reference Snippets

- **Related lab:** [[Lab_Name_Link]]  
- **External resource:** [PayloadAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)

---

### 📝 Exam hooks

- **Typical question angles:**  
  - Ask for DB name / version after SQLi  
  - Specific header values  
  - Exact path of sensitive file  

- **Things to screenshot:**  
  - First successful payload + response  
  - Version output  
  - Flag locations  
  - Sensitive info pages  

---

### How to use this

1. Duplicate this template for every new video or lesson.  
2. Delete sections that do not apply (e.g., pure theory → keep Rule of 3 + Theory).  
3. Keep commands and payloads inside code blocks for easy copy-paste during exam.