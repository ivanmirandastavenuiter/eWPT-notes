## Web proxies

### 1. Web proxies

- **Takeaways**
    - **Proxy vs web proxy**
        - **Proxy** (Burp Suite or OWASP zap). Intercept, analyze or modify HTTP/HTTPS requests sent between client and server
        - **Web proxy**: used to proxy internet traffic, filter specific traffic and optimize bandwidth

### 2. Burp Suite

#### 📌 2.1. Configuring Burp proxy

- **Actions**
  1. Proxy tab
        - Forward: send request to server
        - Drop: cancel request to server
        - Open browser: browser already configured for proxy with BS
  2. Http history & Web Socket history
        - Even with interceptor off, it records history of both
        - Can check **responses**
  3. Options
    - Check domain → export certificate from BurpSuite (DER) and import from browser 

#### 📌 2.2. Dashboard & UI

- **Actions**
    - Events log → records all actions done in the program
    - Tasks → crawling enabled by default
        - Can configure scopes with urls and subdomains. Also with special options, like form submission
    - Issue activity → displays vulnerabilities

#### 📌 2.3. Target and scope

- **Actions**
    - Scopes 
        - It allows for filtering domain not included in the scope
        - Be careful to not filter too much, like subdomains
        - Add scope → don't add protocol
            - ine.com
            - Advance control allows to add regexp
        - Filter 
            - By request type
            - By MIME type
            - By file extensions
            - By HTTP status codes

#### 📌 2.5. Burp Suite intruder

- **Definition**: fuzzing module that uses requests as templates in order to be modified and resent
- **Actions**:
    - Difference vs repeater → repeater is manual. Intruder automates requests.
    - Commonly used for brute-force attacks on web applications by modifying specific HTTP parameters
    - Positions and payloads → position is the parameter or variable, while payload allows you to specify values for substitution (wordlists in case of brute force attacks)
    - Attack types:
        - Sniper: single set of payloads with one or more positions
        - Battering ram: single set of payloads and iterates through each payload putting the same payload in every position
        - Pitchfork: multiple payloads sets where a different payload set is used for each defined position
    - Wordlists → ``usr/share/wordlists``
    - Options for payloads
        - Add payload items
        - Add rules:
            - Case
            - Encoding
            - Add suffixes and prefixes
        - Throttling options
        - Type of attack results
        - Grep filtering
        
#### 📌 2.6. Attacking basic auth with intruder and encoder

- **Actions**:
    - Goboster alternative for directory brute force with BS → ``gobuster dir --url http://192.229.235.3 --wordlist /usr/share/wordlists/dirb/common.txt``
    - Intruder → add position in basic authorization and use wordlist payload. Use payload processing: encoding into base64
        - Add prefix → admin:
        - Add encoding → base64

#### 📌 2.7. Repeater

- **Actions**:
    - Fuzz endpoints with custom modifications
    - **Specially used for** → 
        - Command injection
        - SQLi
        - XSS 
 
### 3. OWASP ZAP

#### 📌 3.1. Dashboard and UI

- **Actions**:
    - Panels → 
        - 1. Sites / Context: narrow down the scope
            - Site → site map or tree
        - 2. Right panel
            - Quick start →
                - Active scanning
                - Manual scanning (passive crawling)
            - Request
            - Response
            - Requester → repeater
        - 3. Bottom panel
            - History
            - Search: browse over results (regex options)
            - Alerts: similar to issues in BS
    - Attack mode
        - Standard → not recommended, as it can be dangerous
        - Protected → recommended
    - Session properties → establish filters
    - Layout options → also in toolbar
    - Addons / Marketplace → TreeTools, Reflect, Wappalyzer (for example)
    - Buttons
        - Interceptor
        - Forward
        - Drop

#### 📌 3.2. Configure OWASP ZAP Proxy

- **Actions**:
    - Options → local proxy
        - Certificates → generate one
            - Go firefox → add ZAP to FoxyProxy configuration
    - Open with requester with right click (repeater)
    - Same for fuzzer (intruder)
    - Extra options
        - Add alerts
        - Highlight characters

#### 📌 3.3. OWASP ZAP Context and Scope
    
- **Actions**:
    - Identify site on passive crawling → include in context
    - Bullseye → applies scope for filtering
    - Session options → automate authentication (for example)
    - Right click on site 
        - Active scan
        - Fuzzing
        - Forced browse directory (and children)
        - Spider

#### 📌 3.4. Directory enumeration
    
- **Actions**:
    - Nmap fast scan → ``nmap -sV -F 192.13.236.3``
    - Copy brute force wordlists → ``cp /usr/share/wordlists/dirb/common.txt ~/.ZAP/fuzzers/dirbuster/``
    - Do passive crawling with manual scan
    - Directory brute force → right click on resource / Attack / forced browse directory (and children)
        - Below → specify the wordlist

#### 📌 3.5. Web app scanning
    
- **Actions**:
    - Web app scan → vulnerability scan
    - Option in Owasp ZAP → Active scan
        - Set automatic authentication
            - 1. Right click → include in context → default context
            - 2. Add the get url for the login and POST body data → form based authentication
            - 3. Set parameters
            - 4. Regex patterns in logout responses
            - 5. Set the users
        - Right click → Attack → Spider 
            - Allows to find new urls for alerts
        - Right click → Attack → Active scan

#### 📌 3.6. Spidering with OWASP ZAP
    
- **Actions**:
    - Used for → discover new resources and urls on a specific site
        - Recursive and cyclic
        - Identify files, folders, hidden items, hyperlinks
    - Default options are usually good