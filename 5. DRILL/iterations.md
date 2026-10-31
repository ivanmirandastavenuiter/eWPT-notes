## Iterations

Each cycle reviews Phase 1 (recon) content and either runs it against a target or refines it. Every entry below uses the same shape: **Status**, **Goal**, **Changes made** (what actually got done), and **Carried forward** (what was left, and which later iteration — if any — picked it up).

### Iteration 1 — First full run

| | |
|---|---|
| **Status** | ✅ Completed |
| **Goal** | Run the existing checklist end to end against a lab target to see where it breaks down in practice. |

**Changes made**

| # | Change |
|---|---|
| 1 | Completed Phase 1 end to end, following the checklist's steps and attacks |
| 2 | Logged the doubts that came up during the run |
| 3 | Started saving command outputs to files instead of only reading them in the terminal |

**Carried forward**

| Item | Picked up in |
|---|---|
| Efficient, optimized way of storing content | Iteration 2 — `target-report-template.md`, `recon/` convention |
| Efficient way of analyzing command outputs | Iteration 2 — standard `awk`/`grep` read lines |
| Decide whether to drop tools/commands not in the exam environment | Iteration 2 — trimmed the Kali tool list |
| Best way to take notes while progressing | Iteration 2 — `target-report-template.md` |
| How to interpret results as anchors for later phases | Iteration 3 — "what depends on what" table, branch/trigger model |

---

### Iteration 2 — Consolidating the structure

| | |
|---|---|
| **Status** | ✅ Completed |
| **Goal** | Refine `4. FINAL STRUCTURE` for eWPTv2 exam efficiency: merge the checklist and the payload file, trim the cheatsheet and notes, fix the lab setup, and decide the drill-report format. |

**Scope set for this iteration**

| Area | Instruction |
|---|---|
| `startup-checklist.md` | Free to edit |
| `LABS/` | Out of scope, already refined |
| `automation_and_scripting.md` | Delete if confirmed unusable in the exam |
| `checklist-WSTG-INFO-CONF.md` + `attacks_and_payloads.md` | Merge into one practical, exam-usable file |
| `cheatsheet.md` / `notes.md` | Improve and condense |
| `docker-compose.yml` / `init.sh` | Move into a `Metasploitable2/` folder, improve |
| Phase 2 | Do not touch |
| Per-target folders | Replace with one target-agnostic file |
| `7. DRILL` | Review the note-taking approach (raw output vs. files) |
| `target-172.20.0.2.md` insights | Integrate points 1–8, 12–16, 18; ignore 9, 10, 11, 17 |

**Changes made**

| # | Change |
|---|---|
| 1 | Merged `checklist-WSTG-INFO-CONF.md` + `attacks_and_payloads.md` → `📋 checklist-and-commands.md` (WSTG order, appendix for variants) |
| 2 | Deleted `automation_and_scripting.md`, `checklist-WSTG-INFO-CONF.md`, `attacks_and_payloads.md` |
| 3 | Moved `docker-compose.yml`, `init.sh` → `Metasploitable2/`, improved both |
| 4 | Condensed `📜 cheatsheet.md` (24 KB → ~8 KB), recreated from scratch |
| 5 | Rebuilt `📝 notes.md` around a tool-decision table; removed citations/lab IPs, added a scenario table |
| 6 | Added `7. DRILL/target-report-template.md`: target-agnostic, with a note-taking guide and a "where information goes" table |
| 7 | Integrated insights 1–8, 12–16, 18 from `target-172.20.0.2.md`; ignored 9, 10, 11, 17 |
| 8 | Startup checklist: tool check, `mkdir -p recon`, unified placeholders, Burp scope fix, single report file |
| 9 | Grouped commands into relevance classes (critical vs. context-dependent) and by recon category (subdomains, brute force, etc.) |
| 10 | Unified every ffuf command on `-of all`; documented reading the `.csv` with `awk`/`grep` instead |
| 11 | Report template: replaced the log's time column with a title, removed the index number |
| 12 | Scoped `searchsploit` guidance to layer-7 targets only |
| 13 | Added explicit thread/concurrency limits to stop the Kali VM freezing |
| 14 | Logging guidance: record only what's relevant, not full raw output |
| 15 | Replaced "find it in comments via regex" commands with "inspect manually in Burp" where a human does it better |
| 16 | Added a "When to use" trigger line per command, so it's clear when one can be skipped |

**Open decisions**

| Decision point | Resolution |
|---|---|
| `target-172.20.0.2.md` findings with no matching saved evidence (SQLi, LFI, flags, credentials) | Kept as-is |
| Target report format | Converted to the target-agnostic template; the LOG reflects the saved outputs on disk |
| Exam Kali tool list | Dropped `testssl.sh`, `subzy`, `amass`, `sublist3r`, `fierce`, `eyewitness`, `httrack`, `lynx`, `browsh`, `droopescan`. Kept `wafw00f`, `dnsenum`, `wpscan` |
| `init.sh` CRLF handling | Compose strips CRs with `tr` at runtime, runs the script via `exec`; not yet tested in-container |
| `global-instructions.md` file names | Updated |
| `structure_example.md` phases 02–08 | Still reference the old file names; deferred |

**Carried forward**

| Item | Picked up in |
|---|---|
| Merge study-plan and guideline into one file, workflow aligned strictly with eWPTv2 | Iteration 3 |
| "What am I missing — does the exam require more?" | Still open |
| Chain command outcomes into later steps (dependencies between commands) | Iteration 3 — "what depends on what" table |
| Understand the exam's environment | Still open |
| Targeted FAQs: inline per phase, or a separate exam-FAQ file | Iteration 3 — answered inline, no separate file needed |
| Guideline/workflow for Burp Suite usage during recon | Iteration 3 — Burp-scope conventions, block C |
| How to adapt when the command list isn't enough (e.g. curl/ffuf "angles" to try) | Still open |
| Reduce noise in the checklist, prioritize quick access | Iteration 3 — colour-coded mandatory/optional steps |
| Confirm every WSTG key the eWPTv2 addresses is covered | Still open |
| Document command order/dependencies; merge that explanation into the checklist | Iteration 3 — `walkthrough.md`, later folded into the Summary |

---

### Iteration 3 — Theory, clarifications and the final merge

| | |
|---|---|
| **Status** | ✅ Completed |
| **Goal** | Turn the checklist into a self-contained study-and-exam-day document: answer the open methodology questions from Iteration 2, add a real theory summary, colour-code mandatory vs. optional steps, and fold every separate explanatory file into one. |

**Changes made**

| # | Change | File(s) |
|---|---|---|
| 1 | Added `Summary`: one block merging the former "Big picture", "Exam rules" and "Run order" sections into a single 12-stage, start-to-finish narrative (goal, ground rules, root-checks/restart/branch rules, per-stage why/output/terminal/block, terminal map, foundational-techniques table, dependency table) | `🧭 phase-walkthrough.md` |
| 2 | Colour-coded all 52 step headings — 🟩 mandatory / 🟨 optional — with a legend | `🧭 phase-walkthrough.md` |
| 3 | Added **Non-web services** section: FTP, SMB, NFS, MySQL/MSSQL/PostgreSQL, Redis, MongoDB | `📜 cheatsheet.md` |
| 4 | Added **Stack playbooks** section: Tomcat, Spring Actuator, Struts, IIS/ASP.NET, Node.js, phpMyAdmin, Jenkins | `📜 cheatsheet.md` |
| 5 | Added `searchsploit` selection criteria (5-step tie-break order) and the DoS-exclusion rationale | `📜 cheatsheet.md` |
| 6 | Clarified Burp scope: anchored regex vs. loose-keyword risk, and what "add a path to scope" actually means | `🧭 phase-walkthrough.md` |
| 7 | Marked branch-only steps (e.g. DNS) explicitly as "don't block on this" | `🧭 phase-walkthrough.md` |
| 8 | Downgraded Metasploit to "avoid on exam" per eWPTv2's manual-methodology rule | `📜 cheatsheet.md`, `📝 notes.md` |
| 9 | Fixed the Burp scope regex example to the anchored form | `startup-checklist.md` |
| 10 | Deleted `🧭 walkthrough.md`: its goal/terminal/step/FAQ/troubleshooting content is now fully covered by the Summary, the *Question → where to look* table and the *Troubleshooting* table, so merging it in added nothing the checklist didn't already have | `🧭 walkthrough.md` (removed) |
| 11 | Renamed `📋 checklist-and-commands.md` → `🧭 phase-walkthrough.md` (it had stopped being just a checklist once the Summary and the colour code went in) and updated every live cross-reference to it (`📜 cheatsheet.md`, `📝 notes.md`, `2. REPORTS/target-report-template.md`, `structure_example.md`, `exam_doubts_faq.md`, `guideline.md`) | repo-wide |

**Questions resolved this iteration**

| Question | Answer location |
|---|---|
| Which ports count as "web ports"? | Conventions table (`<WEB_PORTS>`, by nmap service name, not port number) |
| Command-by-command or target-by-target? | Summary → "Command by command, or target by target?" |
| Non-web services (FTP/SMB/NFS/DB) commands | Cheatsheet → *Non-web services* |
| Loose vs. anchored Burp scope regex; what "a path in scope" means | Conventions → *Burp scope* |
| Why DoS is excluded from searchsploit | Cheatsheet → *searchsploit* |
| How to pick among several searchsploit hits | Cheatsheet → *searchsploit* |
| Does `<DOMAIN>` ever mean an IP? | Conventions (`<DOMAIN>`: a name only, never an IP) |
| Do "jump to block X" pointers block the main line? | Summary → "Branch, not gate" |
| Is Metasploit allowed in the exam? | Cheatsheet / notes.md → "avoid on exam" |

**Carried forward**

| Item | Status |
|---|---|
| "What am I missing — does the exam require more?" | Still open |
| How to adapt when the command list isn't enough (generalizing curl verbs, ffuf wordlist swaps, etc. as a reusable skill) | Still open |
| Confirm every WSTG key the eWPTv2 addresses is covered | Still open |

---

*Next iteration: keep this same Status / Goal / Changes made / Carried forward shape, and resolve or re-carry every open item above instead of letting it silently drop.*
