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
    


    
    

