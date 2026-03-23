## 4. Cross-site scripting

### 4.1. Cross-site scripting attacks

- **Actions**:
  - Query parameters → indicative of reflected
  - Filter applies first of all to delicate, escape characters (<>, for example) → if the input has a text value, deal with enclosing it ```"><script>alert('posok')</script>!--```
