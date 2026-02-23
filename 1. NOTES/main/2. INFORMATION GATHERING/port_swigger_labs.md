## 1. Information gathering

### 1.1. Error information leakage (url params)

- **Scenario**: Browse urls and analyze potential errors they could throw (ie: query parameters)
- **Attack**: 
    - 1. Abuse through malicious input (Burp Suite)

### 1.2. Information leakage (hidden/debug pages)

- **Scenario**: Browse through the page and go to the Burp Suite site map for finding hidden web pages
- **Attack**: 
    - 1. Inspect those pages and browse the sitemap
- **Additional**: engagement tools -> find comments (only pro version)

### 1.3. Information leakage (hidden directories)

- **Scenario**: Navigate to /robots.txt
- **Attack**: 
    - 1. /robots.txt in the main app url. 
- **Additional**: engagement tools -> discover content (only pro version)

### 1.4. Authentication bypass 

- **Scenario**: Navigate to /admin
- **Attack**: 
    - 1. In Burp repeater, use TRACE with the route /admin
    - 2. Check the X-Custom-Ip-Authorization and change it to 127.0.0.1 in match and replace

### 1.5. Information leakage from control version

- **Scenario**: Go to /.git
- **Attack**: 
    - 1. Navigate there
    - 2. Download the folder with wget -r url (Windows may need to use other alternative, such as Cygwin)
    - 3. Use git log / git diff / git show to see the changes
