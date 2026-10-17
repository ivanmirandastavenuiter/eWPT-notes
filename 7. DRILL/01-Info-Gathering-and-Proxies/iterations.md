## Iterations

### Iteration 1

#### Status

Completed

#### Milestones

- Phase 1 completed with attacks and steps indicated by checklist
- Doubts noted
- Command outputs stored in files

#### Pending

- Efficient and optimized way of storing content
- Efficient and optimized way of analyzing command outputs
- Decide whether eliminating tools or commands that are repetitive or not present in the exam's environment.
- Best way to note down and take notes of the commands you execute while progressing
- How to interpret results so they're used as anchors in order to leverage for further phases

### Iteration 2

#### Status

In progress

#### Instructions

In order to understand the context of this project, first go to the root of the repository and read the following parts from the file `global-instructions.md`

- Repository structure and files
- Status

Once you've read that, analyze the whole content of the repository to understand what was previously explained.
Next, refine as much as possible the content in '6. FINAL STRUCTURE', so it's maximized in terms of efficiency for the INE's eWPTv2 exam content.
Next, read what's been done at iteration 1.

**Very important**: at the time of performing this second iteration, bear in mind the following restrictions:

- startup-checklist.md was a checklist recently created in order to prepare the environment. You can add/modify whatever it's needed there if you consider so.
- Ignore LABS. That content is already refined
- automation_and_scripting.md aimed to be a set of automations to perform at the exam's day. Seems that's not possible in the exam. Delete if confirmed.
- attacks_and_payloads.md and checklist-WSTG-INFO-CONF.md. The checklist is the series of the steps that must be followed according to the WSTG and the attacks_and_payloads contains the explicit commands harmonized with the checklist's ordering. I found this a bit annoying and difficult to handle. The reason is that you end up looking only at one file. I've thought it could be more efficient if we merge both files in just one single.md. Take into account that information needs to be summarized because the idea is that it's not a massive file, as it needs to be practical and easy to comprehend. Bear in mind this will be used and read during the exam. Offer me alternatives in this sense so we can accomplish this goal
- cheatsheet.md and notes.md. First is a larger set of commands in case something is missing from the previous ones. Notes are my notes from the INE's tutorials. Consider improvements / optimizations here.
- docker-compose.yml and init.sh. Configuration files for metasploitable2 deployment. Create a new folder called Metasploitable2 and save these files there. Consider improvements.
- Don't do nothing for now with phase 2.
- Regarding targets. I thought initially to separate the content for the different machines in several folders. I think that's not practical, and probably better to create just one md file for all.
- Regarding '7.DRILL'. This is a simulation for the first phases. target-172.20.0.2.md represents the attempt of real reporting, using metasploitable as the target for practice. I started noting down the raw output of commands, but that demonstrated to be really cumbersome and time consuming. That's why I changed to a file approach: I just note the command and save the content in files. This, though, it's also really problematic in terms of time, as it takes a lot. The sections seem to be properly separated: I'm comfortable with the idea of noting first what I do, then writing the main discoverings and findings and continuing with vulnerabilities. Other categories, such as notes, pass registries and so on seem to be correct too. Offer guidance in how to efficiently approach the part of what to note down, and what not.
- Read and integrate into your work the points established at file target-172.20.0.2.md at the `PHASE INSIGHTS AND ENHANCEMENTS` phase. From them, ignore points 9, 10, 11, 17.