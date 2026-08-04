## 2. HTTP Host header attacks

**Description**: the host header tells where the request is targeted. Modifying the "Host" header request in order to trick the server into redirecting the request to your own infrastructure.

### 2.1. Basic password reset poisoning

- **Scenario**: change host header on password request to steal user reset password secret token.
- **Attack**: 
    - 1. Intercept http request for password reset
    - 2. Change host header
    - 3. Intercept the token in the logs
    - 4. Visit the genuine url with the user's token and reset the password

### 2.2. Host header authentication bypass

- **Scenario**: elevate privileges by abusing host header validation in the server
- **Attack**: 
    - 1. Access /admin panel
    - 2. As it's only allowed for "local users", change the Host header to localhost
    - 3. Add that as a match & replace rule in Burp Suite to automate all requests

### 2.3. Web cache poisoning through ambiguous requests

- **Scenario**: web application vulnerable to ambiguous host requests
- **Attack**: 
    - 1. Duplicate host header. Try different orders (preference)
        - Front end may validate one way / back end other
    - 2. Other options
        - Indentation
        - Absolute url in the route on top vs payload in Host field
        - Alternative headers in combination
            - X-Forwarded-Host
            - X-Host
            - X-HTTP-Host-Override
            - Forwarded

### 2.4. Routing-based SSRF

- **Scenario**: vulnerability that abuses lack of validation to internal, privileged networks
- **Attack**: 
    - 1. Go to intruder
    - 2. Replace addresses with a sequence of numbers
    - 3. Replace the host
- **Additional**: 
    - 1. The collaborator. This is supposed to be a server / network service that detects the DNS lookup by the target server
        - This shouldn't happen and means that the web application unsafely using user defined host header values (as it proves it the fact that the request bounces back to the collaborator)
        - Collaborator does not reveal addresses though

### 2.5. SSRF via flawed request parsing

- **Scenario**: vulnerability lies on the request line parsing mechanism
- **Attack**: 
    - 1. Use the genuine, valid url as absolute in the request line
    - 2. In host, set the intranet address. Such as 192.168.0.157

### 2.6. Host validation bypass via connection state attack

- **Scenario**: server trusts that subsequent requests will refer to the same host as the first request
- **Attack**: 
    - 1. Send requests using grouped tabs in repeated over a single connection
    - 2. Modify host header accordingly
