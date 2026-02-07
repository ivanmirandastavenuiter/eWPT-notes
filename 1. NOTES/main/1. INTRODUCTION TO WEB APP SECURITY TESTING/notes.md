**HTTP lab 1**  
**Category:** Workflow/Methodology
**Topic:** Http handshake inspection on wireshark
**Module:** Fundamentals

### 🗺️ 1. HTTP request workflow 

**Wireshark**

- Http runs on **TCP**
- Open wireshark from CLI: ```wireshark -i eth1```
- TCP handshake: 
    - **1.SYN** (client to server)
    - **2.SYN/ACK** (server to client)
    - **3.ACK** (client to server)
- Check sessions opened: ```netstat --antp```
- Follow TCP stream, right click
    - Can see the gzip encoded content of the request
- File -> export objects -> HTTP objects

**Curl**

- curl -v [address]
- Metadata in response: method, host, user-agent, accept. 
- Also **headers** (server, OS, cookies)
- Check headers: curl -I [address]
- Select method: curl -X OPTIONS [address] (this one offers the available methods of the request)

### 🔧 2. Burp suite

- **Setup steps:**  
    - Open: web application analysis, burpsuite
    - Proxy, set on
    - Forward for confirming sending the request
    - Repeater: modification of requests
        - Reload, right click, send to repeater
        - Left modify, right shows the result

### 🔧 3. Dirb (directory brute force)

- **Commands**
    - ```dirb [address]```
    - Upload file: ```curl [address] --upload-file [filepath]```

### 🔧 4. Cheat sheet

```code

Maybe some commands from the http lab?

```

**OWASP Web Security Testing Guide**  
**Category:** Workflow/Methodology
**Topic:** OWASP Web Security Testing Guide theory and practice
**Module:** Testing Lifecycle

### 🗺️ 1. OWASP Web Security Testing Guide

- **Definition**: comprehensive and community-driven resource provided by the OWASP project
- **OWASP Web Security Testing Checklist**: spreadsheet based checklist that can be used to help you track status of completed and pending test cases
    - Provides a pentesting framework
    - Includes web app security tests
    - Includes OWASP risk assessment calculator and Summary Findings

**Using the guide**

- **Check id**: can be used in the report
- Steps:
    - Objectives
    - How to test 
    - Tools
    - Examples
- **Checklists**: https://github.com/OWASP/wstg/tree/master/checklists
- **Spreadsheet sections**:
    - Testing checklist
    - Summary findings
    - Risk assessment calculator
    - References
 