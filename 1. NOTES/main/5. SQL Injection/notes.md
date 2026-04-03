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
    - # or -- → single line comment
    - || → double pipe
    - % → wildcard attribute indicator
    - @variable → local variable
    - @@variable → global variable
    - waitfor delay '00:00:10' → time delay

### 4. Finding SQLi Vulnerabilities

#### 📌 4.1. xx

- **Actions**
    - Stored → goes to DB

### 5. In-Band SQL Injection

#### 📌 5.1. xx

- **Actions**
    - Stored → goes to DB

### 6. Blind SQL Injection

#### 📌6.1. xx

- **Actions**
    - Stored → goes to DB

### 7. NoSQL Injection

#### 📌 7.1. xx

- **Actions**
    - Stored → goes to DB