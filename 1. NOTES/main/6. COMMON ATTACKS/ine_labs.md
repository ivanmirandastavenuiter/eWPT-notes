## 6. COMMON ATTACKS

### 6.1. HTTP method tampering

- **Actions**:
  - Directory brute force → dirb ```url```
  - Get with curl → curl -v ```url```
  - Select method with curl → curl -v -X POST ```url```
  - Select method with curl and data → curl -v -X POST -d "name=test&password=pass" ```url```

  ### 6.2. Attacking basic HTTP authentication

- **Automation of attack with Intruder**:
  1. Send to repeater
  2. Select the base64 value
  3. Payload → load list
  4. Configure payload process rules → add prefix → ```username:```
  5. Add → encode → base64
  6. Separate into different variables if want to address also username

### 6.3. Attacking HTTP Digest Authentication

1. Command → ```hydra -l admin -P /root/Desktop/wordlists/100-common-passwords.txt 192.152.221.3 http-get /digest/```

### 6.4. Sensitive data exposure

1. Directory brute force → ```dirb [url] [wordlist]```
2. Listing directory enabled. Use nikto → ```nikto -h [url]```

### 6.5. Attacking login forms with OTP security

 1. Intercept the request with Burp Suite
 2. Forward requests until hitting the POST request: ```/dev/verify```
 3. Send to repeater
 4. Check session ID changes on each request
 5. Use OWASP ZAP intruder (no restrictions on rate limiting)
 6. Open OWASP ZAP browser
 7. Left panel → browse the endpoint → right click → fuzz
 8. Specify position → add → numbers → 1000 to 9999
 9. Filter result in Message Processor tab → ```.*failed*``` → tab name 'Field'
 10. Start fuzzer

### 6.6. Session hijacking via cookie tampering

1. You are presented with a form
2. Enter credentials and intercept it with BS
3. Check the response in http history → session id is in base64
4. Decoder → decode base64
5. Encode admin to true and modify request
6. Check the port and url you're sending the POST request. If not working try from BS

### 6.7. Advanced electron forum CSRF

1. CLI to search for exploits → ```searchsploit "Advanced Electron Forum"
2. When copying → paste the path with this prefix: ```usr/share/exploitdb/exploits/php/webapps/whatever.txt```
3. Check the html payload. Copy it.
4. Change the url in the form. Save it in the desktop
5. Change the name of the database
6. Double click on the html and it'll execute. 
