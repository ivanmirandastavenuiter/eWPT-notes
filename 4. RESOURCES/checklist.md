# eWPTv2 Exam Checklist / Table of Contents

### 1. Information Gathering & Recon

* [ ] **Service Fingerprinting:** Identify OS, Web Server (Apache/Nginx), and Frameworks (React, PHP, etc.).
* [ ] **Metafiles:** Check `robots.txt`, `sitemap.xml`, `/.git`, `/.env`, and `/.svn`.
* [ ] **Directory Brute-forcing:** Run `ffuf` or `Gobuster` (use small and medium lists).
* [ ] **WAF Detection:** Check if a WAF is blocking common payloads.

### 2. Authentication & Session Management

* [ ] **Login Bypass:** Test for SQLi (`' OR 1=1--`) and NoSQL Injection (`{"$gt": ""}`).
* [ ] **Brute Force:** Use Burp Intruder on login forms.
* [ ] **Session Fixation:** Does the Session ID stay the same before and after login?
* [ ] **Cookie Security:** Check for `HttpOnly`, `Secure`, and `SameSite` flags.
* [ ] **JWT Analysis:** Check for "None" algorithm or weak signing keys.

### 3. Injection Vulnerabilities (The "Big Three")

* [ ] **SQL Injection:**
* [ ] Error-based (Finding the DB version).
* [ ] Union-based (Extracting table names/credentials).
* [ ] Blind (Boolean or Time-based).


* [ ] **Cross-Site Scripting (XSS):**
* [ ] Reflected (Check URL parameters).
* [ ] Stored (Check profile fields/comments).
* [ ] Filter Evasion (Double encoding, script-tag variations).


* [ ] **Command Injection:**
* [ ] Test for `;`, `&&`, `|`, and backticks ```.



### 4. Broken Access Control (BAC)

* [ ] **IDOR / BOLA:** Change IDs in the URL (e.g., `/api/user/10` -> `/api/user/11`).
* [ ] **Function Level Access:** Can a "user" access `/admin` or `/delete` endpoints?
* [ ] **API Testing:** Enumerate hidden API endpoints using a tool like Postman or Burp.

### 5. File & Resource Attacks

* [ ] **File Upload:**
* [ ] Bypass Extension checks (`.php.jpg`, `.phtml`).
* [ ] Bypass MIME type (`image/jpeg`).
* [ ] Check for Magic Bytes.


* [ ] **LFI / RFI:**
* [ ] Check for `/etc/passwd` or `C:\Windows\System32\drivers\etc\hosts`.
* [ ] Log Poisoning (if LFI is found).


* [ ] **SSRF:** Can the server be made to request internal resources?

### 6. Evidence & Documentation (Per Finding)

* [ ] **URL / Endpoint:**
* [ ] **Vulnerability Type:**
* [ ] **Proof of Concept (Payload):**
* [ ] **Screenshot/String:** (Essential for answering the 50 exam questions!)

---

### Tips for your Obsidian Workflow:

1. **Create a "Master Note"** with this checklist.
2. **Make a sub-folder** for each target site/IP you find during the exam.
3. **Use the "Copy as Markdown"** plugin in Burp Suite to instantly paste your request/response evidence into your notes.