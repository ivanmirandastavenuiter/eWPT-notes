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

Completed

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

#### Outcome

- Merged `checklist-WSTG-INFO-CONF.md` and `attacks_and_payloads.md` into `📋 checklist-and-commands.md` (layout A: one file in WSTG ID order, appendices for variants).
- Deleted `automation_and_scripting.md`, `checklist-WSTG-INFO-CONF.md`, `attacks_and_payloads.md`.
- Moved `docker-compose.yml` and `init.sh` into `Metasploitable2/` and improved both.
- Condensed `📜 cheatsheet.md` (24 KB → ~8 KB). The file was deleted and recreated, not edited. The original is in git HEAD.
- Rebuilt `📝 notes.md` around a tool decision table. Citations and lab IPs removed; a scenario table added.
- Added `7. DRILL/target-report-template.md`: target-agnostic, with a note-taking guide and a "where information goes" table.
- Integrated insights 1–8, 12–16, 18. Ignored 9, 10, 11, 17.
- Startup checklist: tool check, `mkdir -p recon`, placeholders unified, Burp scope fix, single report file.

#### Open decisions

- `target-172.20.0.2.md` kept as-is (findings, credentials, scratchpad, tips and insights verbatim). Its SQLi and LFI findings, `FLAG{...}` values and credential rows have no matching evidence in the saved outputs. Decision: keep.
- Target report converted to the target-agnostic template layout. The LOG reflects the saved outputs on disk. Decision: done.
- Exam Kali tool list: optional tools dropped (`testssl.sh`, `subzy`, `amass`, `sublist3r`, `fierce`, `eyewitness`, `httrack`, `lynx`, `browsh`, `droopescan`). Kept: `wafw00f`, `dnsenum`, `wpscan`. Decision: done.
- `init.sh` CRLF: the Metasploitable2 compose command strips CRs at runtime with `tr` and runs the script with `exec`. Not yet tested in the container.
- `global-instructions.md` updated to the new file names. Decision: done.
- `structure_example.md` Phases 02–08 still list the old file names. Deferred to a later iteration, per the user.

#### Pending

- Merge study-plan and guideline in the same file. Preserve and merge organically. Main, critical point: optimize the workflow aligning exactly with what eWPTv2 requires. Not more, not less.
- What I'm missing in my current iteration? Is the exam requiring more?
- Understand how to cohesively execute commands: how to chain outcomes with further steps.
- Understand exam's environment
- Targeted FAQ's. Decide if segregate into the phases or rather place it into the exam faq file.

#### Improvements

1. Mark or remove non-critical operations. Can be flag set along with the 'Save to file' one. This decision relies in the fact that there seem to be operations that cover what other commands do, so we can skip steps and save time
    - Note: all non-critical operations have been marked with the 'non-critical' tag at the bottom of each block.
    - Analyze which commands are addressing the same in different ways and maintain just the optimal one. For example, I saw an intersection between ffuf and for + curl. The second one directly feeds a few keyword in order to find hidden files or directories, while ffuf feeds an entire list from a file. I see, in this case, ffuf option has way more possibilities, as the list is larger by far.
2. Change output here in all ffuf commands to 'all'. Offer how to read csv with grep instead for each one
3. In logs section of the report template, change time for title. Remove index number.
4. Reframe searchsploit so it address only eWPTv2 potential targets (layer 7)
5. Review threads to avoid Kali machine freezing
6. Do not log everything: just what contains something relevant
7. Some commands try to find something in comments. Wouldn't be better to manually inspect files when browsing?
8. Add autocalibrations for ffuf commands in case of dynamic page sizes
9. Think about commands: when are they needed / when not? That can allow you to skip some of them during the exam
    - Maybe add a 'When to use flag'?

#### Fixes

Apply fixes for the indicated points and take into account the following

- I want to relocate the commands that are critical to the top. For example, nmap scan, ffuf or dnsenum/dnsrecon for me are first class citizens here. Others, however, like some specific curl statements, the for loops and so on seem to be quite contextual. I want you to readdress this and split into critical commands and context-dependent. Move also to this second block the extra statements.
- Instead of removing the non-critical, duplicated commands, what you can do is organize each of the tags in relevance classes. So it'd be like the following
    - The key, most relevant commands for the trhee categories (async, manual and extra) go first. You can create a separate layer called 'Main commands' or just leave it as it is and include the rest, non crucial items in the Appendix, mixing it with the rest of the content is already there
- Also group by category of the recon phase: subdomain enumeration, brute force, and so on. Whatever you find more suitable for better comprehension
- Most of the 9 points above include fixes and enhancement to perform. Do it.

#### Pending

- Including guideline and workflow for burpsuite usage during recon phase
- What if my list of commands is not enought? How can I adapt to a different scenario the day of the exam?
    - In this sense, it'd be quite useful to know what are the crucial 'aspects' the commands can take. For example, what you can potentially do with curl if you change the method, with ffuf if you change the wordlist, ... and so on. To have a guide to quickly look up for action advice.