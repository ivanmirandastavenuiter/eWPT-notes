## Key topics

1. Organize content. 
    - Recommended approach is by targets -> phase

```code
/eWPTv2_Exam/
└── /Target_10.10.x.10/           <-- Folder for each IP/Host
    ├── /01_Recon/                 <-- Initial discovery
    │   ├── nmap_full.txt
    │   ├── gobuster_dirs.txt
    │   └── whatweb_output.txt
    ├── /02_Exploitation/          <-- Payloads and successful hits
    │   ├── sqli_payloads.txt
    │   ├── xss_proofs/
    │   └── reverse_shell.py
    ├── /03_Screenshots/           <-- The most important folder
    │   ├── login_bypass.png
    │   └── db_dump.png
    └── /04_Loot/                  <-- Anything you "steal"
        ├── config_backup.php
        └── users_list.csv
```
2. Lab has local access: some tools are not reachable.
3. Some post recommends THM and HTB machines. Saying INE course is not enough to pass the exam.
4. Get hands on
5. Prepare and train your methodology
6. Extra resources: THM - Web fundamentals, PortSwigger, OWASP Juice Shop