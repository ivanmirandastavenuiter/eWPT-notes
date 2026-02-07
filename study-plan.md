## The 14-Week "Mastery" Study Plan (8 hrs/week)

### Phase 1: Recon & Setup (Weeks 1–3)

*Focus: Information Gathering & Environment*

* **Content:** HTTP/S fundamentals, Burp Suite/ZAP setup, and passive/active reconnaissance.
* **Key Detail:** Spend extra time on **Subdomain Enumeration** and **Directory Brute Forcing**. The exam has multiple targets; if you don't find the "hidden" folder, you'll miss the vulnerability entirely.
* **PortSwigger Complement:** Do the **"Information Disclosure"** labs.

### Phase 2: The "Big Three" Attacks (Weeks 4–8)

*Focus: XSS, SQLi, and Authentication*

* **Week 4-5: SQL Injection.** INE covers In-band, Error, and Blind.
* *PortSwigger:* Do the Apprentice SQLi labs to practice manual exploitation.


* **Week 6-7: Cross-Site Scripting (XSS).** * *PortSwigger:* Focus on "Stored XSS" and "DOM-based XSS."
* **Week 8: Broken Authentication & Session Management.** * *Key Detail:* Practice bypassing login screens and stealing cookies.

### Phase 3: Modern & Legacy Attacks (Weeks 9–11)

*Focus: LFI/RFI, File Uploads, and Web Services*

* **Week 9: File & Resource Attacks.** (LFI, RFI, Path Traversal).
* **Week 10: Web Services (SOAP/REST).** * *Crucial:* This is often a weak point. Practice using Burp to parse **WSDL** files.
* **Week 11: CMS Pentesting.** Specifically WordPress/Joomla vulnerabilities.

### Phase 4: Exam Simulation (Weeks 12–14)

*Focus: Speed, Documentation, and Review*

* **Week 12:** Re-run all INE labs without using the "solutions" guide.
* **Week 13:** Practice "Reporting" (even though the exam is auto-graded). Create a markdown file for a mock target.
* **Week 14:** Final review of your "Cheat Sheet" and the **OWASP Web Security Testing Guide (WSTG).**

---

## 3 Critical Factors for the eWPTv2

### 1. The Exam Format (The 10-Hour Sprint)

The exam is **10 hours long** and consists of **50 dynamic questions**.

* It is **Auto-Graded**. You submit answers into a portal (flags, usernames, database names, etc.).
* There is **no manual PDF report**, but you must document like a pro to answer the questions. If a question asks for a specific database version and you didn't save it during your SQLi session, you'll lose time re-exploiting it.

### 2. Documentation is your "Save Game"

Because the exam is 10 hours, "burnout" is a real threat.

* **Take Screenshots:** Every time you find a vulnerability, screenshot the request and the response.
* **Organize by Target:** You will likely have 3-4 different targets. Create a folder for each.
* **Note the Flags:** Some questions are simple "flags" found in `/var/www/html/flag.txt`. Others are "data" (e.g., "What is the password hash for the user 'developer'?").

### 3. Latency & The "Lab Reset"

* **VPN Stability:** Since you are in Spain, latency to US-based labs can occasionally cause Burp Suite Intruder to drop requests.
* **Tip:** If the target stops responding, **reset the lab environment** immediately. This clears the "stuck" services but does **not** reset your 10-hour exam timer.

---

## Extra Tip: The "WSTG" Advantage

The exam is heavily mapped to the **OWASP Web Security Testing Guide (WSTG)**.

* **Action:** Download the WSTG PDF. During the exam, if you find a login page and don't know what to test, search the WSTG for "Authentication Testing" to get a checklist of attacks (e.g., brute force, session fixation, account lockout).

## Doubts and additional information

Getting ready for the eWPT is as much about your **workflow** as it is about your hacking skills. Since the exam moved to the **v2 format**, the process has shifted from a written report to a "dynamic question" format, but your documentation remains the key to not getting lost.

Here is the deep dive into the most delicate topics, the exact documentation process, and the "Reddit-gold" tips for success.

---

## 1. The "Delicate" Topics

These are the areas where students most often get stuck or fail to find the "intended" path. Do not skip these in your review:

* **API Penetration Testing:** This is a major pillar of v2. Review how to enumerate endpoints using a spec file (like Swagger/OpenAPI) and how to test for **BOLA (IDOR)**. Many students forget to check if they can access another user's data by simply changing an ID in the URL/Body.
* **Authentication & Session Management:** Specifically, look for **Session Fixation** and **NoSQL Injection** in login forms. Don't just rely on standard SQLi; if a login feels "different," test for NoSQL syntax (like `{"$gt": ""}`).
* **Filter Evasion & WAF Bypass:** You will likely encounter a basic WAF or a regex filter. Practice **double encoding**, changing case (e.g., `<sCrIpT>`), and using alternative tags (like `<img src=x onerror=...>`) for XSS.
* **File Upload Vulnerabilities:** Don't just try for a shell. Review how to bypass extensions (e.g., `.php5`, `.phtml`, or adding a null byte `%00.jpg`) and how to check if the server is executing the file or just storing it.
* **Information Disclosure:** Pay close attention to **metafiles** (`/robots.txt`, `/.git`, `/.env`). In eWPTv2, finding a hidden config file is often the "key" that unlocks the next stage.

---

## 2. The Documentation Process

In v2, you **do not submit a PDF report**; you answer **50 questions**. However, you cannot answer those questions accurately if your notes are a mess.

### Tools to Use

* **Obsidian (Top Recommendation):** Use the "Markdown" format. It's fast, local, and allows you to link notes.
* **CherryTree:** The "old school" favorite for pentesting. Its hierarchical tree structure is perfect for organizing by "Target IP > Service > Vulnerability."
* **Notion:** Great if you want a beautiful UI and easy-to-use templates, but it requires an internet connection (Obsidian is safer for exam stability).

### The "Atomic" Note-Taking Method

Don't write a diary. Write **reproducible steps**. Your notes should follow this format for every finding:

1. **Vulnerability Name:** (e.g., Reflected XSS)
2. **Target URL/Parameter:** (e.g., `http://target.local/search.php?q=`)
3. **Proof of Concept (Payload):** Paste the exact string you used.
4. **Evidence:** Screenshot of the "alert" box or the leaked data. **Crucial:** In v2, questions often ask for a specific string found in a database or a file. If you find it, **copy-paste it into your notes immediately.**

> **Pro Tip:** Create a "Cheat Sheet" page in your notes before the exam. List your 5 favorite payloads for SQLi, XSS, and LFI. When you’re 8 hours into the exam and tired, you don't want to be googling payloads.

---

## 3. Exam Tips (The "Reddit Wisdom")

I’ve synthesized the most valuable advice from successful eWPTv2 candidates:

* **The 10-Hour Clock:** The exam is **10 hours long**. It is a sprint, not a marathon like the OSCP. Do not take 2-hour lunch breaks. Eat at your desk or take 15-minute breathers.
* **Trust Your Labs:** The exam environment is very similar to the INE labs. If a lab felt important (like the SQLi or API labs), it is likely mirrored in the exam.
* **"Reset" with Caution:** You can reset the environment if it gets buggy (common with the "Guacamole" server), but **be careful.** Dynamic questions might change their "answers" (like a specific token or filename) after a reset. Always check your answers against the *new* environment after a reset.
* **The Browser Matters:** Many users on Reddit report issues with Firefox or Safari. **Use Google Chrome** for the exam portal to ensure the in-browser Kali instance works smoothly.
* **Don't Over-Automate:** Tools like `sqlmap` or `dirb` are great, but the exam often requires **manual** tweaks. If a tool fails, try a manual bypass. The "intended path" is usually a mix of a tool finding the entry point and you manually exploiting it.

---
