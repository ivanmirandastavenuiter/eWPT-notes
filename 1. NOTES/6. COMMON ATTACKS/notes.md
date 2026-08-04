## COMMON ATTACKS

### 1. HTTP

#### 📌 1.1. HTTP method tampering

- **Basic concepts**
    - Definition → modifying the http method in the request

#### 📌 1.2. Attacking basic HTTP authentication

- **Basic concepts**
    - Definition → simple authentication mechanism used in web applications
    - Unencrypted
    - Should be used with HTTPS
    - Workflow
        1. Client makes a request to a protected resource and receives a 401 Unauthorized code
        2. The response of the server includes a WWW-Authenticate header with value 'Basic'.
        3. Request includes → ```Authorization: Basic + base64(username:password)```

#### 📌 1.3. Attacking HTTP Digest Authentication

- **Basic concepts**
    - Definition → simple authentication mechanism used in web applications to identify users
    - Applies challenge-response mechanism and hashing to protect user credentials during transmission
    - Workflow
        1. Request is sent → 401 is returned
        2. Response includes → WWW-Authenticate "Digest"
        3. Request is sent with different values
            - realm
            - qoa
            - nonce
            - opaque
        4. Client crafts a response calculating a hash based on the components
        5. Server validates it
 
### 2. Sensitive data exposure

#### 📌 2.1. Sensitive data exposure vulnerabilities

**Examples**
    - Weak password storage
    - Information disclosure of error messages
    - Directory traversal
    - Unencrypted backups

### 3. Broken authentication

#### 📌 3.1. Attacking login forms with burp suite

1. Proxy request with BS
2. Send to intruder
3. Nmap command → ```nmap -sS -sV -p 8000 192.148.7.3```
4. Add position in the password
5. Set in payload options the wordlist from Desktop
6. Start the attack
7. Check the length of the response. If different, is valid.

#### 📌 3.2. Attacking login forms with OTP security

**Basic concepts**
    - OTP → one time password
    - Short life
    - Endpoints should implement rate limiting to prevent brute force attacks
    - Types
        - TOTP → based on secret key and current time
        - SOTP → OTP is sent to the mobile phone

### 4. Session management

#### 📌 4.1. Session IDs and cookies

**Basic concepts**
    - Session IDs are uniquely created in the web application
    - Cookies are the mechanisms used to carry the value of the sessions

#### 📌 4.2. Session fixation and session hijacking

**Session hijacking**
    - Definiton → an attacker takes over the session of the victim user
    - Token acquisition
        - Session prediction (poor encoding, weak/predictable code generation)
        - Session sniffing (not very common now)
        - XSS → steal session cookie through this attack
**Session fixation**
    - Definition → an attacker fixes a value for the Session ID
    - Then the attacker tricks the victim to use this fixed session in order to gain unauthorized access

### 6. Injection and input validation

#### 📌 6.1. Command injections

**Definition**
    - The ability to execute remote commands in the server through inputs of the web application
**Causes**
    - User input handling
    - Lack of input sanitization
    - Injection points

#### 📌 6.2. PHP code injection

**Basic concepts**
    - Inject arbitrary php code in the web application
    - Scoped to PHP
**Exploitation**
    - Attacks include php tags
    - The malicious injection in php is executed by the application

### 7. Security misconfigurations

#### 📌 7.1. RCE Via MySQL

