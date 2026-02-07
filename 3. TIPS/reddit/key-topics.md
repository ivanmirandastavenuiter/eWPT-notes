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
7. Organize the notes as a cheatsheet, with index points for quick access during the exam

## Snippets

In my opinion, the course is sufficient to pass this certification, but not just by watching the videos. I cannot emphasize enough how important it is to adapt to the tools, try them in different scenarios in the labs, not just stick to a screenshot of tool execution in a video. On the other hand, my big mistake, and why I feel I didn't score higher, is the lack of organization. In the exam, there are questions that you must answer based on the applications to attack. I followed the methodology of guiding the tests with the exam questions, and after finishing, I can say that it was a mistake. You have the OWASP checklist, you even have the Excel version with suggested tools; USE IT! Be methodical, save every result from nmap, nikto, etc.

**Key takeaways here**:
    - Adapting the tools
        - Check with AI to generate clear / concise snippets for **Purpose** - **Command**
    - Learn how to use the security testing guide
        - Get deep knowledge about this (it seems it's the way of performing a penetration test)

