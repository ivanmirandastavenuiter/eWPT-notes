## 8. WEB SERVICE SECURITY TESTING

### 8.1 WSDL disclosure

**Intro**

1. Append wsdl, .wsdl or ?disco to the url/endpoint → ```https://soap.site/page.php?wsdl```

**Lab**

1. Open firefox → access ```demo.ine.local```
2. Go web services / soap / user enumeration / lookup user
 - ```http://demo.ine.local/webservices/soap/ws-user-account.php?wsdl```
3. Analysis of WSDL items
    - Types → shows data types used
    - Messages → shows operations
    - PortType → information/documentation about how to use and consume those operations. If present, means it's **WSDL version 1.1**
4. Open BurpSuite → go to the repeater
5. Copy get user request in the browser UI and paste it into the repeater
6. Hit the send button
    - Host: ```demo.ine.local```
    - Port: 80
7. To review in the response
    - Headers → ```X-SOAP-Server```

### 8.2. Invoking hidden methods

1. Go again web services / soap / user enumeration / lookup user
2. Try replacing username by an id
3. Replace the operation by deleteUser → the code should represent if the operation ran successfully or not
4. In the response
    - Namespaces for custom data types
5. Go to the definition of the WSDL in the browser UI and copy the password xml parameter line in the port type section of delete user
6. The input string seems to be used in the response → try injection here
    - Error based SQL injection (add a ' to the input string)
7. Another operation to try → get admin info, copy the request from the WSDL file and paste it into the decoder. Decode it to HTML. Remove br tags and format it as a SOAP request.
8. Reuse the code of the previous request in the repeater → within the body, add the new payload from the get admin info.
9. If 500 server error → might mean the specification is incorrect
    - Look at the error and inspect the message in the response
10. SOAP can have a few security restrictions → implemented through **headers**
    - Soap action header → SOAPAction
    - Extracting the value → go to a protected endpoint in the SOAP wsdl file and look for 'soapAction'. The value of that attribute will be the value of the header.
    - If response shows an error, remove header and body tag content from the payload

### 8.3. SQL injection

1. Recycle the paylod from previous requests    
    - Go to intruder
    - Change username to admin
    - Set a position in the password field
    - Attack type → sniper
    - Payloads → load desktop/wordlists/100-common-passwords.txt
    - Start attack
    - If error in host, change it to → ```demo.ine.local```
    - Check for variations in the response length
2. Repeat the same process with → 'Admin' with A in capital case
    - Repeat the steps above
3. Change the brute force to hit the get user info
    - Why? → you can check whether or not admin user exist and which could be the actual admins
    - Set the username field as the position
    - Sniper
    - Load the unix users wodlist under the metasploit folder
    - Remember to set the host to demo.ine.local
    - The length changes because username field is being used to construct the response
    - Order by length → the large ones seem to be successful
4. Check the SQL injection errors
    - Error based → ' in the password parameter. You can check with one ('), two ('') or three (''')
    - Boolean based SQL injection → ```' or '1'='1```
        - If that one doesn't work, it's because the vulnerable field seems to be at the username, not the password
        - ````Jeremy' or '1'='1```
5. Fuzz with the intruder
    - Send the delete request to the intruder
    - Password as position field
    - Go to share/seclists/fuzzing/quickSQL.txt
    - Change host header to demo.ine.local
    - Monitor responses

### 8.4. Command line injection

1. Navigate demo.ine.local → web services/soap/command line/dns look up
2. Copy the payload of the request 
3. Paste it into the repeater
    - Remove mutilidate prefix (starts with /webservices)
4. When sending
    - Host → ```demo.ine.local```
    - Port → 80
5. Response will be empty because it's a lab → if you hit the local IP it will work
    - If not, move to command injection 
        - ```;id```
        - ```;ls```
        - ```;pwd```
        - ```;ls -al /app```
        - ```;cat /app/set-up-database.php```
        - ```;find / -iname *flag* 2>/dev/null```
        - ```;cat /app/flag3```
