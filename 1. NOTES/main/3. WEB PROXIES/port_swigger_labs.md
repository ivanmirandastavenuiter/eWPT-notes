## 2. HTTP Host header attacks

**Description**: the host header tells where the request is targeted. Modifying the "Host" header request in order to trick the server into redirecting the request to your own infrastructure.

### 2.1. Basic password reset poisoning

- **Scenario**: change host header on password request to steal user reset password secret token.
- **Attack**: 
    - 1. Intercept http request for password reset
    - 2. Change host header
    - 3. Intercept the token in the logs
    - 4. Visit the genuine url with the user's token and reset the password