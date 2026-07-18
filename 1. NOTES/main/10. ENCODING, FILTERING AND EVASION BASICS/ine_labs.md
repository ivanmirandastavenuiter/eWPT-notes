## 10. ENCODING, FILTERING AND EVASION BASICS

### 10.1. Charset encoding

- ASCII table → `https://www.ascii-code.com/`

### 10.2. Bypassing client side filtering

1. Access mutilidae
2. Go to owasp 2017 - XSS - Reflected - DNS lookup
3. CTRL+U to check source code for the page (javascript and input validation)
4. Bypass any client validations with interceptor in BurpSuite

### 10.3. Bypassing server side filters

1. Go to the DVWA application, section XSS
2. Inspect source code of the server side
3. Type → `<script>alert(1)</script>`
4. Move up to medium → it won't accept script tags. Also can be bypassed with uppercase
5. Black box approach → owasp cheat sheet for filter evasion
6. Go to BurpSuite
7. Use the intruder module with a list of parameters as url query parameters with intruders
    - Use seclists → fuzzing payloads. Under `/usr/share/seclists`
    - Use fuzzing list
8. Create a request and intercept it with bs
    - Send to intruder
    - Sniper type
    - Add the parameter as position
    - Inside fuzzing lists, XSS → the brute logic one
    - Settings → follow redirects
    - If you don't see the the content reflected → could mean it worked
9. Set level to highest
    - Try to black box it and understand what's going on