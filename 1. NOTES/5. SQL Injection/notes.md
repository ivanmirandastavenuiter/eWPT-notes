## SQL Injection

### 1. SQL Injection fundamentals

#### 📌 1.1. Types of SQL Injection vulnerabilities

- **Actions**
    - In-Band → the attacker uses the same communication channel to attack and receive the results (the web application)
        - Error based → the attack aims to reflect an error message as a result of the sql command/query
        - Union based → the attacker uses the UNION clause in order to combine two or more SQL statements
    - Blind injection → those are the ones that do not directly reveal the information about the database or the results of the injected SQL statement. Communication channel is the same, but the results are not directly exposed.
        - Time based → the attacker studies the time it takes for the database to retrieve the information in order to guess or infer information about it
        - Boolean based → the attacker infers information about the database based on whether the query result is successful or not (boolean condition) 
    - Out-Band → least common. It uses a communication channel different than the web application. The results of the attack are sent to an alternate service, such as an HTTP/DNS monitoring service.

### 3. SQL Primer

#### 📌 3.1. Introduction to SQL

- **Commands**
    - ' OR " → character string indicator
    - /*..*/ → Multi-line comment
    - + → Addition or concatenation
    - '#' or -- → single line comment
    - || → double pipe
    - % → wildcard attribute indicator
    - @variable → local variable
    - @@variable → global variable
    - waitfor delay '00:00:10' → time delay

#### 📌 3.2. SQL fundamentals

- **Commands**
    - List databases → ```show databases```
    - Use database → ```use wpdatabase```
    - List tables → ```show tables```

### 4. Finding SQLi Vulnerabilities

#### 📌 4.1. Hunting SQL injection vulnerabilities

- **Actions**
    - Common injectable fields 
        - Login forms
        - Search fields
        - Url parameters
        - Form fields
        - Comment fields 
        - Hidden fields
        - Cookies
    - Testing
        - Manual testing
        - Error based testing
        - Union based testing
        - Boolean based testing
        - Time based testing
    - Input validation and sanitization → review application's code to see if proper input validation and sanitization measures are in place
    - Automated testing
        - sqlmap
        - OWASP ZAP
        - Burp Suite
    - SQL injection testing
        - Check for string terminators: ' or "
        - Check for commands: SELECT, UNION, others
        - Check for comments: #, --
        - Check if injectable parameter is integer or string based
    - Integer based injection
        - Payload does not include statement termination characters
    - String based injection
        - Here the string termination (') is needed
    - Database fingerprinting
        - Cause errors in order to identify underlying RDMBS

#### 📌 4.2. Finding SQL injection vulnerabilities manually

- **Actions**
    - Login page → single quote and enter to generate an error
        - The response highlights underlying database engine and language
    - String injection → must be closed with '
        - Then injection + comment to invalidate remaining SQL statement
    - If parameters are passed by the url, url encode it (Cntrl + U in BurpSuite or decoder)
- **Payloads**: https://github.com/payload-box/sql-injection-payload-list
- **Hidden fields**:
    - Body parameters in POST requests that appear on BurpSuite but not in the browser
- **Types**:
    - String based
    - Boolean based
    - Union based
        - ```' UNION SELECT * FROM accounts#```
    - Time based
        - ```' or sleep(5)#```
    - **Don't forget to url encode when parameters are passed in the query**

#### 📌 4.3. Finding SQL injection vulnerabilities with OWASP ZAP

- **Actions**
    - Access from firefox builtin in OWASP ZAP
    - **Fuzzer**
        - 1. Intercept request with OWASP
        - 2. Right click → fuzzer
        - 3. Select blank space, add, file fuzzers (jbrofuzz), sql injection (select everything)
        - 4. Start fuzzer
    - State → reflected (means error based injection). This means that the attack was reflected (in-band)
            - It could include false positives
    - Process: intercept the request, send to fuzzer (it is per request)
    
### 5. In-Band SQL Injection

#### 📌 5.2. Exploiting union based sql injection vulnerabilities

- **Basic concepts**
    - Definition → the result uses the same input / output channel, so the information is revealed to the user (an error is shown)
    - Types:
        - Error based
        - Union based
    - You can use union to merge columns from different tables (you need to know the database tables and columns)

### 6. Blind SQL Injection

#### 📌6.1. Introduction to Blind SQL Injections

- **Basic concepts**
    - Definition → the result does not directly return information about the database
    - Types:
        - Boolean based
        - Time based

### 7. NoSQL Injection

#### 📌 7.1. NoSQL fundamentals

- **Basic concepts**
    - Not only SQL → database system that provide a non-relational approach for storing and retrieving data
    - Flexible models → unstructured, semi-structured
    - Target → highly scalable environments, performance, and agility
    - Types
        - Key value pairs
        - Documents
        - Columnar
    - Languages
        - MongoDB - MQL or mongo query language
        - Redis - Its own commands

