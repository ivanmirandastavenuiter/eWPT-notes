## 9. CMS SECURITY TESTING

### 9.1. Information gathering and enumeration

**Manual techniques**

1. Check wordpress meta generator tag
2. Check wordpress readme.html/license.txt file
3. Inspect HTTP response headers for vesion information (X-Powered-By)
4. Check the login page for the wordpress version as it is usually displayed
5. Check the wordpress rest api and look for the version field in the json response
    - http://example.com/wp-json
6. Analyze JS and CSS files for version information
7. Examine the wordpress changelog files with information on version updates. Look for files like changelog.txt or readme.txt in the wordpress directory

**Automated techniques**

- Tools like WPScan, CMSmap and others are designed specifically for wordpress version enumeration and vulnerability assessment
- These tools can automate the process and provide additional information about the site's configuration

**Lab**

1. Check the wordpress version → CTRL + U or right click, view source. Meta generator tag reveals the version
    - Other techniques: access the readme.html
    - Check the link at the bottom of the html, as well
2. Check response header → burp suite or curl
    - Header name → X-Powered By
3. Check wordpress login → /wp-login.php
    - Check source code CTRL + U or right click, view source
4. Check wordpress admin → /wp-admin
    - You can also check the source here
5. Check wordpress json → /wp-json
6. Check wordpress xml rpc → xmlrpc.php
7. In the source code, you can check that resources may reflect the current version of wordpress
    - Curl command to automate this step → ```curl -s -X GET [url] | grep http | grep -E '?ver=' | sed -E 's,href=|src=THIIIIS,g' | awk -F "THIIIIS" '{print $2}' cut -d "'" -f2```
8. Check /changelog.txt
    - Also /readme.txt
9. wpscan
    - ```wpscan --url [url]```

### 9.2. Enumerating wordpress users, plugins and themes

**Manual techniques**

1. Username ID brute force → ```curl -s -I -X GET http://wordpress.com/?author=1```
    - Automate with burp suite and look for different http codes
2. Enumerate users querying wordpress API on wp-json → ```curl http://wordpress.com/wp-json/wp/v2/users```
3. Automate with burp suite and analyze response. If mentions password is wrong, means the username exists
    - wp-login.php

**Role permissions**

- Admin → highest permission
- Editor
- Author
- Contributor
- Subscriber

**User, plugin and theme enumeration methodology**

- Plugin enumeration → ```curl -s -X GET https://wordpress.com/ | grep -E 'wp-content/plugins/' | sed -E 's,href=|src=,THIIIIS,g' | awk -F "THIIIIS" '{print $2}' | cut -d "'" -f2 ```
- Theme enumeration → ```curl -s -X GET https://wordpress.com/ | grep -E 'wp-content/themes' | sed -E 's,href=|src,THIIIIS,g' | awk -F "THIIIIS" '{print $2}' | cut -d "'" -f2```

**Automated**

- wpscan enumerating users → ````wpscan --url [url] --enumerate u```
- xml rpc post request in burp suite
    - intercept in burp
    - set the payload → 
    ```xml
     <methodCall>
        <methodName>
            system.listMethods
        </methodName>
        <params></params>
    </methodCall>
    ```
    - With the response, set a new payload 
    ```xml
     <methodCall>
        <methodName>
            wp.getUsersBlogs
        </methodName>
        <params>
            <param>
                <value>admin</value>
            </param>
            <param>
                <value>password</value>
            </param>
        </params>
    </methodCall>
    ```
    - brute force setting the position in the value of the password

### 9.3. Enumerating hidden files and sensitive information

1. Using gobuster
    - Use github SecLists → web content → CMS
    - Download seclist → sudo apt-get install seclists
        - Downloaded under → ``lsz -al /usr/share/seclists/``
    - ``gobuster dir --url [url] --wordlist /usr/share/seclists/Discovery/Web-Content/CMS/wordpress.fuzz.txt -b '404' -t 20``
    - Themes → ``gobuster dir --url [url] --wordlist /usr/share/seclists/Discovery/Web-Content/CMS/wp-themes.fuzz.txt -b '404' -t 20``
    - Common → ``gobuster dir --url [url] --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt -b '404' -t 20``
2. Using wpscan
    - ``wpscan --url [url]``

### 9.4. Wordpress enumeration with nmap NSE scripts

1. Execute nmap → `sudo nmap -sS -sV https://22gsy9qzjbuuh129id8kwdnc8.eu-central-6.attackdefensecloudlabs.com/`
    - SYN scan and version scan
2. Nmap with sC for default scripts → `sudo nmap -sS -sV -sC https://22gsy9qzjbuuh129id8kwdnc8.eu-central-6.attackdefensecloudlabs.com/`
3. Look for specific scripts for wordpress → `ls -al /usr/share/nmap/scripts | grep wordpress`
4. Using one of the scripts → `sudo nmap -sS -sV --script=http-wordpress-enum https://22gsy9qzjbuuh129id8kwdnc8.eu-central-6.attackdefensecloudlabs.com/`
5. Using one of the scripts with args → `sudo nmap -sS -sV --script=http-wordpress-enum --script-args type="themes" https://22gsy9qzjbuuh129id8kwdnc8.eu-central-6.attackdefensecloudlabs.com/`
    - Change themes for plugins for plugins scan
6. Nmap with ports and scanning users → `sudo nmap -sS -sV -p80,443 --script=http-wordpress-users https://22gsy9qzjbuuh129id8kwdnc8.eu-central-6.attackdefensecloudlabs.com/`

### 9.5 Wordpress vulnerability scan with WPScan

1. Create a wordpress account → `https://wpscan.com`
2. Grab the API token
3. Feature vulnerability scan → `wpscan --url [url] --enumerate u --api-token "token"`
    - Results will show the vulnerabilities behind the threats
4. Go to the unauthenticated SQL injection
5. Copy the exploit and replace the url with yours
    - An error will be thrown because you have to make it readable
6. Execute the second command on exploit db