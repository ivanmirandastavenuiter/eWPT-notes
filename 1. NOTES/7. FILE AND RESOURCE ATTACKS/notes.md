## FILE AND RESOURCE ATTACKS

### 1. Directory path traversal

#### 📌 1.1. Local file inclusion (LFI)

**Basic concepts**
    - Definition → adding files into a web server
    - Cause → poor input validation
    - Locations where they can exist
        - File inclusion functions
        - Http parameters
        - Cookies
        - Session variables
    - Impact
        - Information disclosure
        - Remote code execution
        - Directory traversal

