## CMS SECURITY TESTING

### 1. Security testing introduction

#### 📌 1.1. Security testing

**Basic concepts**

- Definition → software application or platform that allows users to create, manage and publish digital content on the web
- High audience → specially targeted due to its widespread use  
- Reasons behind attacks
    - Widespread use, as mentioned
    - Rich functionality → more attack surface
    - External plugins → it increases the possibility of outdated, vulnerable code from third party software
    - User data present

**Vulnerabilities**

- SQL injection, XSS, CSRF and more
- Authentication and authorization: authentication bypass, brute force, session hijacking
- Plugin security

**Methodology**

- Information gathering and enumeration
    - CMS and CMS version
    - Identify users, plugins and themes
    - Perform directory and file enumeration
- Vulnerability scanning
    - Test for common misconfiguration and vulnerabilities
    - Perform vulnerability scanning/analysis to identify potential vulnerabilies/misconfigurations in plugins and themes
- Authentication testing
    - Perform username enumeration and brute force attacks on login pages.
    - Assess session handling for weaknesses and potential session fixation vulnerabilities.
- Exploitation 
    - Identify and exploit vulnerabilities on CMS core
    - Identify and exploit vulnerabilities in plugins/extensions
- Post exploitation
    - Identify ways to maintain access to CMS after exploitation in the form of a backdoor or web shell
    - Attempt to extract data from the CMS or the underlying server

#### 📌 1.2. Wordpress security testing

- Wordpress is open source
- Highly modular through plugins and themes
- Key in AppSec → due to its prevalence, it is a prime target for attackers

**Methodology in Wordpress**

1. Information gathering and enumeration
    - Port scanning and service enumeration
    - Identify the Wordpress' version
    - Enumerate/identify list of themes and plugins installed on the wordpress site as well as their respective versions
    - Perform file and directory enumeration to identify hidden or sensitive resources
2. Vulnerability scanning
    - Identify common wordpress misconfigurations and vulnerabilities
    - Perform automated vulnerability scanning with tools like wpscan to identify vulnerabilities in wordpress plugins and themes
3. Authentication testing
    - Perform brute-force attacks on /wp-admin.php or /wp-login.php to obtain valid credentials.
    - Test WordPress for session management vulnerabilities
4. Exploitation
    - Identify and exploit publicly known vulnerabilities in Wordpress themes and plugins
5. Post exploitation
    - Establish persistence in wordpress site or server via web shells or backdoors to maintain access
    - Exfiltrate sensitive data