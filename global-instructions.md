## Global eWPT road map 

### Main target

Create a documentation source environment or wiki that maximize execution workflow, speeds up accessibility and eases understanding for a candidate during the eWPTv2 INE exam.

The expected output is having a vault or wiki that acts both as a solid but also highly effective database for the user, so you can easily advance without blocking during the exam.

### Context

eWPTv2 stands for web penetration test version 2. It is delivered by the INE organization. The candidate (me) has completed the full Alexis Ahmed course in the INE's platform, but it is highly advised to complete the study preparation with other sources, such as Hack the box, TryHackMe or PortSwigger. In my case, I'm completing PortSwigger academy labs which belong to the relevant sections and that's all in order to avoid overhead from many sources. 

The eWPTv2 has the following characteristics:

- It lasts 10 hours
- It consists in 50 questions
- You can paste text but not upload complex files, such as scripts
- The environment is a Kali Guacamole distro, which is reported to get frozen sometimes. Because of that, you need to be careful when applying heavy commands and restrict them as much as possible. You have the option of resetting, but that might change some of the values. As it seems, it's recommended to answer the questions as you progress.

### Repository structure and files

1. NOTES. Contains notes taken by me from the INE tutorials. Inside, there's a structure of folders following the same division that INE uses for the course.
- Types of files:
    - notes.md. Raw notes from the videos
    - ine_labs.md. Solution and steps to solve each INE lab
    - port_swigger_labs.md. Solutions for PortSwigger labs
    - Additional: you might encounter more files, such as the WSTG guide and such.
2. REPORTS. One of the things that seem to be very important and crucial for the penetration test is gathering and storing information. In order to structure and organize this process, a good idea is creating a template that allows you to save critical information in a simple and comprehensible way. The file inside is a first approach to achieve this objective.
3. TIPS. The intention was to investigate all information available about the exam in order to know how it's really like and get useful insights from real experiences of candidates. 
4. RESOURCES. Contains a guideline that list the activities or steps you must follow in order to perform the full pentest. It's divided in checkboxes that you need to complete, each representing a different task. This format is going to be important later. It responds to the most important question the candidate could make: how do I address this exam and how can I approach to it? It contains two files. Second one is intended to be a list of external resources, but didn't advance that much there (it contains one file pointing to a repo of exam notes in form of a theory database, and a web about pentest reports).
5. EXAM PROCEDURE. It contains responses for doubts I had about the exam. The second file tells you how to proceed effectively during the exam.
6. FINAL STRUCTURE. After completing the videos and analyzing how the exam was, I tried to construct the best structure possible for the exam day, so it was as solid, neat and effective as it could be. 
- Files
    - structure_example. **Important**. It lays out the final structure for the notes for the exam day. The organization follows the same division as INE in its tutorials, for clarity.
        - checklist-xxx.md. Following the file you saw before, addresses exactly which are the steps and tasks you must perform regarding that category. The idea is avoiding the candidate to freeze
        - attacks_and_payloads.md. A list of commands that acts like a cheatsheet, but with more context. It follows the order in the checklist so the workflow feels in harmony. 
        - cheatsheet.md. Additional commands the other file might not list. Thought to be a quick database for fallback options.
        - notes.md. User notes taken in point 1 enhanced by AI.
        - automation_and_scripting.md. Aimed to be a series of automation and script files, but they are not applying, as you cannot upload that content at the eWPTv2 exam.
        - LABS folder. Contains solution for labs both from INE and PortSwigger related to that category
    - ine-to-wstg.md. Tries to find and establish cohesive links between INE and the WSTG for a global comprehension.
    - port_swigger_categories.md. Tries to find and establish cohesive links between port swigger labs and the INE materials for a global comprehension.
- Folders
    - PHASES. This holds the content of the files we saw indexed in structure_example.md. There's one extra phase listed, the 00, which contains basic configuration steps to be performed at the very beginning
    - TARGETS. This shouldn't really be a folder, as it adds unnecessary complexity. A division of one markdown file per target would be enough. More details on section 7.
7. DRILL. It is an attempt of exam simulation. What I did was setting locally the Metasploitable2 and intiating the info gathering and recon phase against it. Still on progress. It contains one folder per phase and a markdown file for each target.
- global-instructions.md. This file
- study-plan.md. Another file trying to decipher elements in order to crack the exam and also some advice.

### Skills

- Learn repeatable skills: construct and generate the content for the rest of phases based on the structure and content created for the first. Follow the same patterns of work.
The skill action should address one phase per execution. For example, /construct-phase and then continue with a specific one, such as 'Cross-Site Scripting'
- Add more skills that you think might be appropriate for the purpose.

### Connections

- Connect to Github repository
- Connect to Reddit

### Documents

- Instructions
- Repository
    - Source repo
    - Notes repo

### Additional values

**These are not a priority now. TBD**

- Generate drill questions for simulation of the exam environment
- Generate statistics (missing gaps). Analyze the progress of the student based on the drills folder status. Identify knowledge gaps, missing topics, wrong assumptions and suggestions and represent those in a visual, comprehensible manner. 

### Doubts

**These are not a priority now. TBD**

- Is the structure of the contents and the guideline correct or would it be too much?
- Do I have to perform all the steps listed or are they dynamic depending on the exam questions?

### Status

At the moment, the drill folder is in progress. What it does is, based on the theory and files in '6. FINAL STRUCTURE', following the next steps:
 - Read checklist first. This allows the user to know exactly what to do.
 - Jump into attacks and payloads. The direct representation of the tasks listed in the checklist are materialized here in form of explicit commands. 
 - The cheatsheet server as an additional database in order to count with an extensive command source.
 - Labs folder content can help in case the student indentifies a scenario similar to the one presented in the practice.
 - Notes contain theory notes and details

The result is what you see in the drill folder. And the idea is keep doing that for the rest of the phases. I'm on the first iteration, so there will probably be things to refine and details to polish, specially in what regards to the report template content (the target md file). 

The target is both optimizing these files so they are shaped in the most efficient way possible for the exam.
