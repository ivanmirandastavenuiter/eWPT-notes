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

