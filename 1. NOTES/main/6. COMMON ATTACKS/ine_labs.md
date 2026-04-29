## 6. COMMON ATTACKS

### 6.1. HTTP method tampering

- **Actions**:
  - Directory brute force → dirb ```url```
  - Get with curl → curl -v ```url```
  - Select method with curl → curl -v -X POST ```url```
  - Select method with curl and data → curl -v -X POST -d "name=test&password=pass" ```url```

  ### 6.2. Attacking basic HTTP authentication

- **Automation of attack with Intruder**:
  1. Send to repeater
  2. Select the base64 value
  3. Payload → load list
  4. Configure payload process rules → add prefix → ```username:```
  5. Add → encode → base64
  6. Separate into different variables if want to address also username

### 6.3. Attacking HTTP Digest Authentication

1. Command → ```hydra -l admin -P /root/Desktop/wordlists/100-common-passwords.txt 192.152.221.3 http-get /digest/```




