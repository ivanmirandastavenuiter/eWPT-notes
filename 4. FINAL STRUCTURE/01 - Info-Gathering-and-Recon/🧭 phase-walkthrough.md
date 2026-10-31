# Phase 1 – WSTG Recon: Walkthrough + Guide

**Tags:** `ASYNC` start at once, read later · `MANUAL` Burp/ZAP/browser while scans run · `EXTRA` only when a question or a blocker points to it. Every block keeps its WSTG ID.

**Colour code (on every step heading):** <span style="background:#b7e4c7;color:#000">&nbsp;🟩 Green = mandatory&nbsp;</span> run it on every target, or as soon as the fact that triggers it appears (a branch, queued without waiting). <span style="background:#fff9b0;color:#000">&nbsp;🟨 Light yellow = optional&nbsp;</span> run it only when a question points to it, as a fallback, or if time allows. The emoji squares keep the code visible in viewers that ignore background colours.

**How to use it:** *Study* by reading the context lines and **Watch** notes. *Execute* by jumping to the commands and reading only the **Read** line. Blocks A–O follow the order you work in. Inside each block, core commands come first and the ones with a *When* line are triggered extras. Every block ends with a **Next** column. It is a pointer, not a gate: the numbered stages in the *Summary* set the sequence, and a branch (DNS, CMS, 403s) is queued when its trigger shows, without waiting for it. **If it fails** points to a section of [📜 cheatsheet.md](<./📜 cheatsheet.md>). The question lookup, the discovery map and troubleshooting are at the end.

***

## Summary

**Goal.** Turn "an IP" into a map: every host, every web port, every vhost, and for each of them the stack, files, directories, parameters and APIs. Recon outputs **targets and leads**, not findings. Every later phase (XSS, SQLi, auth, uploads) attacks an entry point that recon found, so a missed entry point is a missed question.

**Ground rules (they apply to every stage).**
- **Read all 50 questions first** (10–15 min). Note the target, the answer type and which ones are count questions. They decide which triggered blocks you run and how deep you go.
- **Wide first, deep later.** Run the main line (stages 1–6 and 8) on every target before going deep on one.
- **Layer 7 only.** The exam tests web applications. OS services (SSH, SMB, kernel) matter only when they leak web files.
- **Kali has no internet.** Everything runs against internal hosts. `searchsploit` is local, `wpscan` has no API token, OSINT is done on the host PC.
- **Count questions** ("how many pages, parameters, subdomains") need the scans finished and every endpoint re-checked, not the first hit.
- **Answers are exact strings.** Copy the value from the output.
- **A Kali reset wipes everything.** Copy `recon/` and your notes to the host PC as you go.

**Three ideas hold the process together.**
- **Root checks.** What every web host, every vhost and every web port gets, in this order: fingerprint (whatweb) → headers → known-exploit lookup (searchsploit) → directory and backup scan → metafiles → web-service probe (blocks D, E, G, I).
- **Restart rule.** Every new hostname, web port or credential re-enters the process at the root checks. That loop is what makes recon complete.
- **Branch, not gate.** Many steps point to a further block (DNS, CMS, 403s, TLS). That is a pointer: queue the branch in a free slot and keep going with the main line. The **Next** column at the end of each block works the same way. The only real order is the one in the stages below.

**The process in twelve stages.** Each one says why it exists, what it hands to the next, where it runs and which block holds its commands. Read it once before the exam and again when you feel lost.

**Stage 0 · Prepare (before touching anything; block A).** Read all 50 questions first (10–15 min), because they tell you which parts of the app matter, which answers are counts, names or exact strings, and which triggered blocks you will need. Then create the working folder for evidence, check which tools and wordlists exist (a missing one is replaced from the cheatsheet, never installed), tell Burp which hosts are allowed (scope), and write the hosts file, one line per IP with every name found so far. This is the only stage with no target traffic. Its purpose is to make everything afterwards repeatable and safe: you never test a host that is not yours to test, and nothing you find is lost.

**Stage 1 · Know the targets (block B, host discovery).** If the scope is a network range, find which machines are alive first; each live machine is a separate target. If you were given a single address, skip this. Output: the complete list of targets. Everything that follows is repeated per target.

**Stage 2 · Find every door (the slow job; block B, terminal 1).** A full scan of all ports on each target tells you what is listening and which program answers. It is the longest job, so it starts first, in terminal 1, and runs without you. Targets are scanned one after another, not in parallel. Web servers do not always live on the usual ports, which is why every port is scanned and why a port is called "web" by the service it speaks, not by its number. Output: the web ports (each one is a separate website to test), the non-web services, and whether a DNS server exists. Every later step needs these ports, which is why this job goes first. With many hosts and little time, sweep only the usual web ports first so Burp can start on every host while the full scans queue.

**Stage 3 · Use the waiting time (the human channel; block C, Burp browser).** While the scan runs, you open the application in the Burp browser and walk it by hand: read the page source, click every link, submit every form harmlessly. Burp records everything, and that record (the Site map) becomes your list of entry points. This is the one thing no tool replicates, because only a person notices odd comments, hidden fields, workflows and parameters. It continues in the background of the whole exam, one target at a time and completely. A spider (ZAP) is only a fallback for "how many" questions or apps too big to walk by hand, and its active scan is never run.

**Stage 4 · Sort what the scan found (block B).** When the scan ends, split the findings into three piles. *Web ports* continue down the main line. A *DNS server* opens a side branch (names and records). *Other services* (file sharing, databases) are checked only for what they leak about the web application: source code, configuration, credentials. These side branches are queued in a free slot and never block the main line. In this stage you also build the list of web ports (by the service nmap reports, not by number) and run a few quick HTTP scripts on them. If the TCP scan shows no DNS server but a domain is in play, check UDP too, since DNS is normally UDP.

**Stage 5 · Identify each website (block D; the start of the root checks, terminal 2).** For every web port, ask the server what it is: language, framework, product, version, CMS, and what it says in its headers. These checks take seconds, so run them across all targets in one sweep to see the whole attack surface before choosing where to dig. Two outputs matter most: the **file extension** of the stack (it tunes the next stage) and the **product + version** (looked up offline for known weaknesses, as leads only). A recognised stack or CMS also unlocks its own specialised checks.

**Stage 6 · Discover hidden content (brute forcing; block E).** Now you guess names: directories, files, backups and leftovers, using wordlists and watching which guesses the server answers differently from its default "not found". Calibration is what makes this reliable; without it you drown in false hits. Each answer code means something (exists, redirects, needs login, forbidden, wrong method, error), and each class has its own follow-up. This stage is the longest after the port scan, so it runs in terminal 3, and never more than two fuzzers run together or the machine freezes. New directories found here are scanned again, one level at a time, only when the previous level gave something.

**Stage 7 · Discover more hosts (block F).** One IP can serve many sites, selected by the name in the request. If a domain name is known (it must be a real name, never an IP), you look for other names through three independent routes: guessing names against the web server, asking the DNS server (records, zone transfer, guessing), and reading names that certificates, redirects and page content give away. Every new name is a new target and **re-enters the process at Stage 5**. This is the loop that makes recon complete. Guessing names against the web server needs only a domain and a web port, and counts as a fuzzer; the DNS routes need an open DNS port and are not fuzzers, since they query DNS, not the web server. Both are branches: start them in a free slot while Stage 6 runs. If no domain name is known, look for one in redirects, the TLS certificate and reverse lookups; if none shows up, skip these routes.

**Stage 8 · Collect the cheap, high-reward files (blocks G and I).** In parallel with the fuzzers, in terminal 2, fetch the files that owners publish or forget: robots and sitemap, security contact, version-control folders, environment files, debug and status pages, comments and scripts in the page. They are single requests with no wordlist, and they leak the most per second spent. Anything that looks like a secret or an internal address is noted as a lead. The same quick probes also look for web-service and API entry points (service descriptions, API documentation, GraphQL, `/api`).

**Stage 9 · Follow the triggers (branches; blocks H, I, J, L, M, N).** Some results open a branch, and each branch starts only when its trigger appears:
- *Forbidden paths* lead to checking which HTTP methods are allowed and whether another method gets through.
- *An API or web-service path* leads to finding its endpoints and the verbs and content types they accept.
- *A page that takes input* leads to discovering parameter names and, for IDs, values.
- *A recognised CMS* leads to its dedicated enumeration (version, plugins, themes, users).
- *An HTTPS port* leads to a look at the certificate, protocol and headers.
- *Blocked or altered requests* lead to identifying a firewall and slowing down.
A branch is a **parallel task, not a gate**: you queue it in a free terminal and keep going with the main line.

**Stage 10 · Go behind the login (block K).** The moment you hold a cookie or credentials, the whole discovery is repeated with that identity, and the new results are compared with the anonymous run. Most of the application usually hides here. Workflows (registration, checkout, reset) are walked by hand in Burp and their tokens observed.

**Stage 11 · Close out (block O).** Last, and alone because it is noisy, a general scanner gives a final set of leads. Then a completeness pass asks, per target and not per finding: did every web port get the basic set, was every forbidden path tested, did every new name and port go through the loop, were count questions re-checked on every endpoint. Finally, answers are copied exactly as shown by the output, and evidence is copied to the host PC, because a reset of the Kali machine erases everything.

**Where things run (never more than four channels).**
- **Terminal 1, the slow queue:** port scans, one target after another. When they finish, it becomes the free slot for a second fuzzer or a branch.
- **Terminal 2, the quick probes (from the moment nmap gives the web ports):** fingerprinting, headers, metafiles, API paths, DNS queries and anything that finishes in seconds. It is also where branches are fired.
- **Terminal 3, the fuzzers (once whatweb has given the extension):** directories first, then backups, then vhosts and parameters as they apply. At most two fuzzers at the same time across terminals 1 and 3.
- **Burp browser, the human channel:** the manual walk, which starts with the port scan and never stops.
- **Last, alone:** the noisy general scanner, with nothing else running.

**Three questions to ask after every result.** (1) *What did this give me?* A host, a port, a name, a path, a version, a credential. (2) *What does it unlock?* Which stage or branch should now start. (3) *Is it new?* A new host, port, name or login goes back to the start of the per-target process.

**What recon is not.** It does not exploit, and it does not prove anything. Every output is a **lead** that becomes a finding only after you reproduce it in Burp, and every lead is judged against the questions you read in Stage 0.

**Five foundational techniques.** Every block below is one of them.

| Technique | What it is | Tools | Blocks |
|---|---|---|---|
| Enumeration | Asking the target what it is: open ports, services, versions, stack, allowed methods, DNS records | nmap, whatweb, curl headers, dig | B, D, H |
| Brute forcing (content discovery) | Replacing `FUZZ` with wordlist words and reading which requests the server answers differently: directories, files, backups, vhosts, parameter names, API endpoints, IDs. Quality = wordlist + calibration (`-ac`) | ffuf (feroxbuster, wfuzz, gobuster as fallbacks) | E, F, I, J |
| Subdomain / vhost discovery | Three independent sources: **vhost fuzzing** (`Host` header sent to the IP, needs no DNS), **DNS** (records, zone transfer, brute force) and **certificates / page content** (SANs, redirects). Every new name is a new host | ffuf, dnsenum, dig, openssl | F |
| Config and metafiles | Files the owner publishes or forgets: `robots.txt`, `sitemap.xml`, `security.txt`, `.git`, `.env`, `phpinfo.php`, actuator, backups. One request each, no wordlist, best reward per second | curl | G, E |
| Manual mapping | A human reads the page source, comments, JS, forms and parameters, and walks the workflows. This is what finds logic and multi-step features and fills the Burp Site map, which is the entry-point list | Burp, ZAP | C, K |

On top of these sit **version → known exploit lookup** (searchsploit) and **triggered specialisations** (CMS, TLS, WAF, stack playbooks). They run only when a result points to them.

**What depends on what.** This is why the stage order above is fixed, not arbitrary.

| Step | Needs | Produces |
|---|---|---|
| Full nmap | `<IP>` | Web ports, non-web services, DNS yes/no |
| whatweb + headers | A web port | Stack, `<EXT>`, versions, CMS |
| searchsploit | A product and version | Exploit leads |
| Directory + backup scan | A web port and `<EXT>` | Pages, `403`s, listings, API paths, backups |
| VHost fuzzing / dnsenum | `<DOMAIN>` (and a web port / port 53) | New hostnames, each one a new host |
| Verb tampering, API brute force, parameter fuzzing | A `403`, an `/api` path, a page that takes input | Bypasses, endpoints, parameter names |
| Authenticated re-scan | A cookie or credentials | The surface behind the login |

**Command by command, or target by target?** Both, by speed:

- **Seconds-long commands (whatweb, headers, metafiles, web-service probe):** go wide. Loop over every web host and port in one pass (`whatweb --no-errors -i recon/urls.txt`, a `for` loop for curl). You see the whole attack surface before choosing where to dig.
- **Slow commands (full nmap, ffuf, nikto):** go target by target, queued in one terminal. Never run the same fuzzer on several targets in parallel: the VM freezes and the results blur. Each target needs its own `<EXT>`, so read its whatweb result first.
- **Burp walk:** one target at a time, completely.
- **Then go deep** on the target and block that the exam questions point to.

***

## Conventions

| Placeholder | Meaning |
|---|---|
| `<IP>` | Exam IP |
| `<SUBNET>` | CIDR range from the scope, only when a subnet is in scope |
| `<DOMAIN>` | A DNS **name** from the exam letter or questions (`target.com`), never an IP. No name yet: look for one in redirects, the TLS certificate and `dig -x` (block F). Still none: skip vhost fuzzing and DNS |
| `<VHOST>` | Host to request (`app.target.com`, or `<IP>` if none) |
| `<SCHEME>` / `<PORT>` | `http`/`https` and port. A service shown as `https` or `ssl/http` by nmap is `https` |
| `<WEB_PORTS>` | Comma list of ports that speak HTTP(S), picked by the **service** nmap reports, not by number (80, 443, 8080, 8180, 8443, 9443 are only the usual ones) |
| `<HTTPS_PORTS>` | Subset of `<WEB_PORTS>` that speaks TLS (`ssl/http` or `https` in nmap) |
| `<EXT>` | `-e` value for the stack: `.php,.txt` (PHP), `.aspx,.txt` (ASP.NET), `.jsp,.txt` (Java) |
| `<BASELINE>` | Size of a non-existent page. Only needed when `-ac` misbehaves |
| `<COOKIE>` / `<PROXY>` | `PHPSESSID=...` / `127.0.0.1:8080` |
| `<NAMESERVER>` | Name server to query. In the exam this is usually `<IP>` itself |
| `<REVERSE_ZONE>` | Network octets reversed, e.g. `0.20.172` for 172.20.0.0/24 |
| `<PAGE>` / `<NAME>` | Page (`login.php`), page name without extension (`login`) |
| `<PRODUCT>` / `<VERSION>` | Software and version from whatweb or headers (`apache`, `2.4.49`) |
| `<EDB-ID>` | Exploit ID from a searchsploit line |
| `<JS_URL>` | Full URL of a `.js` file found in the page |
| `<SUBDOMAIN>` / `<USER>` | Subdomain from DNS or vhost results / a confirmed username |

**HTTP status codes in recon**

| Code | Meaning | Do |
|---|---|---|
| 200 | Exists, readable | Open in Burp |
| 301 / 302 | Exists, redirects | Follow it, note the target |
| 401 | Exists, needs login (basic auth) | Note it, test credentials later |
| 403 | Exists, blocked | Block H |
| 405 / 415 | Exists, wrong verb / content type | Likely an API: other verbs, other `Content-Type` |
| 500 | Exists, server error | Read the body, it may leak data |
| 404 | Not found | Ignore |

- **Burp scope:** Target → Scope → Include: `<IP>` and `^(.*\.)?<DOMAIN>$` (the bare domain and every subdomain; `.*\.<DOMAIN>` alone misses the bare domain). Leave Port and File empty: then every port and path on those hosts is already in scope, so new ports, vhosts under `<DOMAIN>` and every discovered path need no scope edit. Add an entry only for a host outside both patterns.
  - **Anchor the regex, don't loosen it.** A bare keyword like `.*meta2.*` is *not* safer: it matches anywhere in the hostname, so it silently pulls in unrelated hosts that happen to contain the word (another student's VM, a shared lab box, a third-party domain in a redirect) and you'd be sending requests to them without meaning to — a scope violation, not a convenience. `^(.*\.)?<DOMAIN>$` matches only the exact domain and its subdomains, nothing else, so it is both wider (catches every real subdomain) and safer (catches nothing extra).
  - **A "path" is never a scope entry.** The Scope dialog only takes host/port/file patterns, not navigation history. "Adding a path to scope" means *opening it through Burp* (browser, Repeater, `curl -x http://<PROXY>`, or ffuf `-replay-proxy`) so the request lands in the Site map — the path is then just another row under a host that's already in scope, no scope edit required.
- **Calibration:** every ffuf command uses `-ac`, which hides responses that look like the server's default one (a custom 404 that returns 200). If `-ac` hides real hits or lets noise through, measure a baseline and swap `-ac` for `-fs <BASELINE>`:
  ```bash
  curl -sk -o /dev/null -w "%{size_download}\n" "<SCHEME>://<VHOST>/nohost-zz9"
  ```
- **The wordlist is the limit.** A word that is not in the list is a path you miss. Medium list for content, small list for backups, fallbacks in the cheatsheet.
- **Start at the root** of each web host. Go deeper only when the root gives you something.
- **Authenticated re-scan:** whenever you get a working session or credentials, redo the directory scan and API probe with the cookie (block K). Most of the surface hides behind the login.
- **Save to file flag:** `[x]` means the command writes to `recon/`; `[ ]` means read it in the terminal only. Every ffuf command writes `-of all`: six files per run (`.json`, `.ejson`, `.csv`, `.ecsv`, `.html`, `.md`). Read the `.csv`.
- **Naming:** `recon/<tool>-<context>-<target>`, e.g. `recon/nmap-full-172.20.0.2.txt`, `recon/ffuf-dirs-app.target.com.csv`.
- **Read ffuf output with awk, not grep.** CSV columns: `1 FUZZ, 2 url, 3 redirect, 4 position, 5 status, 6 size`. `grep ",200,"` also matches size or position values, so use field 5:
  ```bash
  awk -F, 'NR>1 && $5==200 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv           # one status
  awk -F, 'NR>1 && $5~/^(200|301|302)$/ {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv  # several
  awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv | sort -n             # everything, by status
  ```
  Open the `.html` file instead if you prefer a sortable table.
- **Read other output with grep:** `grep -E "open" recon/nmap-full-<IP>.txt`, `grep "^+" recon/nikto-<VHOST>.txt`.
- **Threads and concurrency:** `ASYNC` jobs run in parallel to save time, with limits that stop the Kali VM from freezing.
  - Fuzzers (ffuf, feroxbuster, wfuzz, gobuster): `-t 10`. feroxbuster defaults to 50 threads, so always set `-t`.
  - At most 2 fuzzers at once. The full nmap counts as one job, not a fuzzer.
  - nikto and `wpscan --plugins-detection aggressive` run alone.
  - If the VM lags, check `htop` and stop the newest job.
- **Step format:** heading with tags, context line, command, **Read** quote, optional **Watch** note, table (save flag, next action). Extra blocks add a *When* line. Main blocks add **If it fails**.

***

## A. Setup & scope

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Workspace, tools and hosts file&nbsp;</span>

Two minutes, before any scan. Everything below writes to `recon/`.

```bash
mkdir -p recon
command -v nmap ffuf feroxbuster wfuzz gobuster nikto whatweb dnsenum dnsrecon wpscan joomscan searchsploit zaproxy
ls -d /usr/share/seclists /usr/share/wordlists/dirb /usr/share/wordlists/dirbuster 2>&1
```

> **Read:** A tool that prints no path is missing. Use the substitute from cheatsheet → *Wordlist fallbacks* and the matching fuzzer section. Do not install anything.
> **Watch:** `/etc/hosts` takes one line per IP, with names separated by **spaces**, not commas: `10.0.0.5 app.local api.local`. Add every new hostname there the moment you find it. Many apps answer by `Host` header, so the IP and the name can show different sites.

| Save to file | Next |
|:---:|---|
| `[ ]` | Subnet in scope: host discovery. Otherwise: full port scan. |

***

## B. Network & port discovery

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Host discovery&nbsp;</span> · `WSTG-CONF-01` · `ASYNC`

*When:* the scope lists a subnet (`<SUBNET>`) instead of single IPs. It goes first so you know every target before scanning ports. Skip it for a single IP.

```bash
sudo nmap -sn -T4 <SUBNET> -oG - | awk '/Up$/{print $2}' > recon/live_hosts.txt
wc -l recon/live_hosts.txt
```

> **Read:** Each line of `recon/live_hosts.txt` is a live host and a separate target.
> **Watch:** With `sudo` on the local network nmap uses ARP, which hosts cannot block. Without root it uses ICMP and TCP probes and can miss hosts. Missing hosts: `sudo arp-scan -I eth0 <SUBNET>` (cheatsheet → *Host discovery*).

| Save to file | Next |
|:---:|---|
| `[x]` | Run the full port scan on each live host. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Full port scan&nbsp;</span> · `WSTG-CONF-01` · `ASYNC`

Most important async job. It covers non-standard web ports, and `-sC` already runs `ftp-anon` and similar default scripts. Start it first and do other work while it runs.

```bash
nmap -Pn -n -sC -sV -p- --min-rate 1000 <IP> -oN recon/nmap-full-<IP>.txt
```

> **Read:** `grep -E "open" recon/nmap-full-<IP>.txt`. Build `<WEB_PORTS>` with:
> `grep -E "^[0-9]+/tcp +open +(ssl/)?http" recon/nmap-full-<IP>.txt | cut -d/ -f1 | paste -sd,`
> **Watch:** Every web port is a separate host to test. Several hosts: run them one after another in the same terminal, not in parallel:
> `for ip in $(cat recon/live_hosts.txt); do nmap -Pn -n -sC -sV -p- --min-rate 1000 $ip -oN recon/nmap-full-$ip.txt; done`
> Many hosts and little time: sweep only the usual web ports first (cheatsheet → *Nmap*), so you can start Burp on every host while the full scans queue.
> A web port is any port whose service is `http`, `https`, `ssl/http`, `http-proxy` or `http-alt`; the grep above catches them all. A port shown as `unknown` or `tcpwrapped` can still be web, so probe it: `for s in http https; do curl -sk -m5 -o /dev/null -w "$s %{http_code}\n" "$s://<IP>:<PORT>/"; done` (`000` means no HTTP answer).

| Save to file | Next |
|:---:|---|
| `[x]` | Port 53 open: DNS tests (block F). No TCP 53 but a `<DOMAIN>` or a DNS question: UDP check below. Then HTTP scripts, then whatweb on each web port. |

**If it fails →** cheatsheet: *Nmap*.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;UDP 53 check&nbsp;</span> · `WSTG-CONF-01`

*When:* a `<DOMAIN>` is in scope or a question mentions names, zones or DNS records, and the TCP scan shows no port 53. DNS is normally **UDP**, so the default TCP scan can miss it.

```bash
sudo nmap -Pn -n -sU -p 53 <IP> -oN recon/nmap-udp53-<IP>.txt
dig @<IP> <DOMAIN> +short
```

> **Read:** `53/udp open` is a DNS server. `open|filtered` is inconclusive, so trust the `dig` line: any answer means a live resolver.
> **Watch:** A zone transfer (AXFR) needs **TCP** 53. A UDP-only server answers `dig` queries and `dnsenum` brute force but refuses transfers. Add `+tcp` to a `dig` to force TCP.

| Save to file | Next |
|:---:|---|
| `[x]` | DNS is live: dnsenum and DNS records (block F) — *branch*: start it in a free slot and keep moving through whatweb/headers/ffuf below, don't wait for it to finish. Set `<NAMESERVER>` to `<IP>`. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;HTTP scripts on the open web ports&nbsp;</span> · `WSTG-CONF-01` · `ASYNC`

Run after the full scan, using its ports.

```bash
nmap -Pn -n -sV -p <WEB_PORTS> --script http-enum,http-title,http-methods,http-robots.txt <IP> -oN recon/nmap-http-<IP>.txt
```

> **Read:** `grep "|" recon/nmap-http-<IP>.txt`. `http-methods` lists allowed verbs (CONF-06). `http-enum` lists directories and files (CONF-05). `http-robots.txt` lists Disallow paths (INFO-03), so you can skip the robots curl in block G.

| Save to file | Next |
|:---:|---|
| `[x]` | Open every found path through Burp so it lands in the Site map. Then whatweb on each web port. |

**If it fails →** cheatsheet: *Nmap*.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Non-web services that expose web content&nbsp;</span> · `WSTG-CONF-01`

*When:* nmap lists FTP, rsync, NFS, or a database port. It matters only when it leaks source code, config files, or credentials for the web app. Ignore other network services (layer 7 scope).

```bash
grep -A2 "ftp-anon" recon/nmap-full-<IP>.txt
curl -s --user anonymous:anonymous "ftp://<IP>/"
```

> **Read:** An anonymous listing that contains web files (`index.php`, `wp-config.php`, `.sql`) means the web root or its backups are reachable.

| Save to file | Next |
|:---:|---|
| `[ ]` | Download the file, read the config for credentials, and try them on the web login. Commands per service: cheatsheet → *Non-web services*. |

***

## C. Burp & application mapping

Burp is your notebook for the whole exam: everything you open through it is recorded in the Site map and HTTP history.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Burp Suite walk&nbsp;</span> · `WSTG-INFO-06` · `MANUAL`

Start it while nmap runs, since the browser is idle anyway. Burp Community has no crawler, no scanner and a throttled Intruder, so the mapping is manual. Scope and browser setup are in the [startup checklist](<../00-Exam-Setup-and-Proxies/startup-checklist.md>).

1. **Scope:** Target → Scope holds `<IP>` and `^(.*\.)?<DOMAIN>$` (see Conventions → *Burp scope*). New vhosts under `<DOMAIN>` and new ports are already covered.
2. **Intercept off.** Open the root in the Burp browser and read the page source (Ctrl+U). Look for comments, hidden fields and `.js` paths yourself; this beats a regex.
3. **Click everything once:** every link, menu and form. Submit each form with harmless data (search, login, register, contact) so the POST requests get recorded.
4. **Target → Site map:** show only in-scope items and sort by URL. Greyed entries were linked but never requested, so visit them.
5. **Proxy → HTTP history:** filter by status (3xx, 4xx, 5xx) and MIME type. Search the history for `api`, `token`, `password`, `admin`, `<!--`.
6. **Interesting request → Send to Repeater** (Ctrl+R). Rename the tab. Change the method, a parameter or a header and compare the responses.
7. **Record:** each GET parameter, POST body field, custom header, cookie and `.js` file.

> **Read:** The Site map is the entry-point list that later phases use. Each `.js` file is a block G lead. Each `Set-Cookie` goes to the session tests.
> **Watch:** Intercept stays off except when you edit a request on purpose. A forgotten Intercept freezes the browser and looks like a dead target.

| Save to file | Next |
|:---:|---|
| `[ ]` | Parameters go to the vuln-testing phases. Each `.js` file goes to block G. New hostnames go to `/etc/hosts` (and to Burp scope only if outside the `<DOMAIN>` pattern). |

**If it fails →** the ZAP spider below, or check the browser proxy is `<PROXY>`.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Spider the app in ZAP&nbsp;</span> · `WSTG-INFO-06` · `MANUAL`

*When:* a question asks "how many pages, forms, or parameters", or the app is too big to walk by hand. ⚠️ Confirm ZAP is installed (`command -v zaproxy`).

```bash
zaproxy -port 8081 &
```

> **Read:** Port `8081` avoids clashing with Burp on `8080`. In ZAP, log in once with Manual Explore, then right-click the site in the Sites tree → Attack → Spider. The Sites tree lists every URL. The Params tab lists every GET/POST parameter. Passive Alerts are leads.
> **Watch:** **Do not run Active Scan.** It is heavy and freezes the VM.

| Save to file | Next |
|:---:|---|
| `[ ]` | Copy the URL and parameter counts into your notes. Open new URLs in Burp so they show in the Site map. |

**If it fails →** walk the app by hand in Burp.

***

## D. Stack fingerprinting & known exploits

The stack decides the extension for the directory scan and the version decides the exploits to check. Do this on every web port before block E.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Tech stack&nbsp;</span> · `WSTG-INFO-02` · `ASYNC`

Run first on each web port (about 5 seconds). CMS, frameworks, plugins, and the language that sets `<EXT>`.

```bash
whatweb -v "<SCHEME>://<VHOST>:<PORT>/" > recon/whatweb-<VHOST>-<PORT>.txt
```

> **Read:** Read the plugin names and versions in brackets, for example `Apache[2.4.x]`, `PHP[5.x]`. `PHP` gives `.php`, `ASP_NET` gives `.aspx`, `Tomcat` or `JSP` gives `.jsp`.

| Save to file | Next |
|:---:|---|
| `[x]` | Set `<EXT>`. Headers next. A CMS goes to block L. A product and version go to searchsploit. A known stack or framework: cheatsheet → *Stack playbooks*. |

**If it fails →** cheatsheet: *Fingerprinting*.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Headers&nbsp;</span> · `WSTG-INFO-02`

Once per vhost, right after whatweb. It uses GET, because some servers answer `HEAD` with `405` or fewer headers.

```bash
curl -sk -D - -o /dev/null "<SCHEME>://<VHOST>:<PORT>/" | grep -iE "^(server|x-powered-by|x-aspnet-version|strict-transport-security|content-security-policy|x-frame-options|x-content-type-options|set-cookie)"
```

> **Read:** `Server` and `X-Powered-By` with version numbers are findings. Missing security headers are informational. `Set-Cookie` without `HttpOnly`, `Secure`, or `SameSite` is a lead for session tests.

| Save to file | Next |
|:---:|---|
| `[ ]` | A version string goes to searchsploit. Cookie flags go to the auth and session tests. No version shown: verbose error below. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Known exploits for the detected version&nbsp;</span> · `WSTG-INFO-02`

Run once per web product (web server, CMS, plugin, JS library, framework). The database is local, so it works offline.

```bash
searchsploit "<PRODUCT> <VERSION>" > recon/searchsploit-<PRODUCT>.txt
searchsploit -t "<PRODUCT> 2.4" --exclude="dos|DoS"   # no hit: major version, titles only, no DoS
searchsploit -x <EDB-ID>                               # read one entry
```

> **Read:** Each line is an exploit title and path. Match the title to your exact version. **Layer 7 only:** skip OS-level services (ssh, smtp, samba, kernel).
> **Watch:** Titles often show a range (`2.4.17 < 2.4.38`), so check that your version falls inside it. Too much noise: `-t` limits the match to titles.
> **Choose:** keep entries with the same product and component, a version range that contains yours, type `webapps` or `remote`, and no login needed first. Skip other products with a similar name, `local`/privesc entries and DoS: a DoS exploit crashes the target (a reset risk in a shared lab) and answers no recon question. Full criteria: cheatsheet → *searchsploit*.

| Save to file | Next |
|:---:|---|
| `[x]` | A version-matched exploit is a lead to verify in Burp, not a finding. Next: directory scan (block E). |

**If it fails →** cheatsheet: *searchsploit*.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Verbose error&nbsp;</span> · `WSTG-INFO-02`

*When:* a 404 or 500 page looks custom, or whatweb and headers showed no version.

```bash
curl -sk -i "<SCHEME>://<VHOST>:<PORT>/nohost-zz9.php" | grep -iE "apache|php|tomcat|nginx|version|exception"
```

> **Read:** A stack trace or version in the body is a finding. Read the full body in Burp.

| Save to file | Next |
|:---:|---|
| `[ ]` | Record the version. A stack trace goes to the input validation tests. |

***

## E. Directory, file & backup brute force

Start these as soon as `<EXT>` is known. They are the longest fuzz jobs, so run them in Terminal 3 and work on block G in the meantime.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Directory and file brute force&nbsp;</span> · `WSTG-CONF-05` · `ASYNC`

On each web host. This is the main content scan: `-e` adds the stack's extension to every word, and `-mc all -fc 404` keeps `401`, `403`, `405`, and `500` as leads.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e <EXT> -mc all -fc 404 -ac -t 10 -o recon/ffuf-dirs-<VHOST> -of all
```

> **Read:** `awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-dirs-<VHOST>.csv | sort -n`. See the status table in Conventions: `200`/`301`/`302` open in Burp, `403` goes to block H, `401`/`405`/`500` are leads.
> **Watch:** Hundreds of hits or none at all means the calibration is wrong (Conventions → *Calibration*).

| Save to file | Next |
|:---:|---|
| `[x]` | Add each hit to the Burp Site map. A new directory repeats the scan on it. `403` rows go to block H. |

**If it fails →** cheatsheet: *ffuf*, *feroxbuster*, *wfuzz*, *gobuster*, *Wordlist fallbacks*.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Backup and temp files&nbsp;</span> · `WSTG-CONF-04` · `ASYNC`

On the root, after or next to the directory scan (2 fuzzers at most). For a known file (`index.php`), use the `index.phpFUZZ` variant in the cheatsheet.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -e .bak,.old,.swp,.tmp,~,.zip,.tar.gz,.sql,.orig,.save -mc 200 -ac -t 10 -o recon/ffuf-backups-<VHOST> -of all
```

> **Read:** `awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-backups-<VHOST>.csv`. Each row is a file that exists. Archives and `.sql` files are the high-value ones.

| Save to file | Next |
|:---:|---|
| `[x]` | Download each hit and read it before anything else. |

**If it fails →** cheatsheet: *ffuf*, *feroxbuster* (backups), *Wordlist fallbacks*.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Directory listing&nbsp;</span> · `WSTG-CONF-04`

*When:* the directory scan has returned `200` or `301` hits.

```bash
awk -F, 'NR>1 && $5~/^(200|301)$/ {print $2}' recon/ffuf-dirs-<VHOST>.csv | while read u; do curl -sk "${u%/}/" | grep -qi "<title>Index of" && echo "LISTING ${u%/}/"; done
```

> **Read:** Each `LISTING` line is a directory with indexing enabled. Browse it for backups, config, and uploads.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each listing in Burp and read the files in it. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Alternate extensions on a known page&nbsp;</span> · `WSTG-CONF-03`

*When:* you hold one specific page and want to see if the server also exposes its source or backup. This is the single-file version of the backup scan.

```bash
for e in php php7 phtml inc bak old; do curl -sk -o /dev/null -w "%{http_code} %{size_download} <NAME>.$e\n" "<SCHEME>://<VHOST>/<NAME>.$e"; done
```

> **Read:** Compare each line with the `php` line. A `200` on `php7`, `phtml`, `inc`, or `bak` with source in the body means that extension is served as plain text.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each `200` in Burp and read the body. Source code in the response is a finding. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Admin keywords&nbsp;</span> · `WSTG-CONF-05`

*When:* only if the directory scan has not finished and you want an instant read. **Skip it once the scan runs**, since `raft-medium-words.txt` already contains these words.

```bash
for p in admin manage dashboard phpmyadmin grafana jenkins; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p/"; done
```

> **Read:** `200`, `301`, `302`, `401`, and `403` are leads. `404` means nothing is there.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each lead in Burp. A login page goes to the auth tests. |

***

## F. Subdomains, DNS & certificates

Needs a `<DOMAIN>`: a DNS **name** such as `target.com`, not an IP, because fuzzing builds `Host: FUZZ.<DOMAIN>` and DNS queries ask about a name. It comes from the exam letter or questions, or from a hostname that a redirect (`Location:`), the TLS certificate or `dig -x <IP>` reveals. No name from any of these: skip vhost fuzzing and dnsenum. Every name you find goes to `/etc/hosts` (and to Burp scope if it is outside the `<DOMAIN>` pattern), then gets the root checks.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;VHost fuzzing&nbsp;</span> · `WSTG-INFO-04` · `ASYNC`

Works without a DNS server: it sends `Host: FUZZ.<DOMAIN>` straight to the web server on `<IP>`, so it finds vhosts that have no DNS record. This is the primary subdomain tool. Repeat it for each web port, since each port can serve different vhosts.

```bash
ffuf -u "<SCHEME>://<IP>:<PORT>/" -H "Host: FUZZ.<DOMAIN>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -ac -t 10 -o recon/ffuf-vhosts-<DOMAIN> -of all
```

> **Read:** `awk -F, 'NR>1 {print $1,$5,$6}' recon/ffuf-vhosts-<DOMAIN>.csv`. Each row is a hostname (`$1`) whose response differs from the default site.

| Save to file | Next |
|:---:|---|
| `[x]` | Add each hit to `/etc/hosts` on the same line as the target, then run the root checks on it. |

**If it fails →** cheatsheet: *ffuf* (`-fs`), *wfuzz* (vhost), *gobuster* (vhost), *Wordlist fallbacks*.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;DNS brute force&nbsp;</span> · `WSTG-INFO-04` · `ASYNC`

*Only if port 53 is open on `<IP>` (TCP or UDP).* Finds names with DNS records and tries a zone transfer on its own, so no separate AXFR step is needed.

```bash
dnsenum --dnsserver <IP> --noreverse -f /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -o recon/dnsenum-<DOMAIN>.xml <DOMAIN>
```

> **Read:** `grep -oE "[a-z0-9.-]+\.<DOMAIN>" recon/dnsenum-<DOMAIN>.xml | sort -u` lists each unique name. A zone transfer shows as many records at once.

| Save to file | Next |
|:---:|---|
| `[x]` | Each new name goes to `/etc/hosts` and the root checks, the same as vhost hits. |

**If it fails →** cheatsheet: *DNS* (`dnsrecon`, `dig axfr`, gobuster dns).

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;DNS records&nbsp;</span> · `WSTG-INFO-04`

*When:* a question asks for a record type, a count, or a flag held in a record. Use the exam's name server. The mapping from lab question to query comes from your [notes](<./📝 notes.md>) (section 10), so verify it on a lab.

```bash
for t in A AAAA NS MX TXT SOA; do echo "== $t"; dig <DOMAIN> $t +short @<NAMESERVER>; done
dig _ldap._tcp.<DOMAIN> SRV +short @<NAMESERVER>
dig -x <IP> +short @<NAMESERVER>
```

> **Read:** `A` lines are hosts to map. `TXT` can hold flags and third-party services. `SRV` names service hosts. `-x` gives the PTR name of an IP, which is how you find a host that has only a reverse record.
> **Watch:** `dig` uses UDP. No answer from a server that you know is up: retry with `+tcp`.

| Save to file | Next |
|:---:|---|
| `[ ]` | Each new hostname goes to `/etc/hosts` and the root checks. Answer the question from the output. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;DNS zone transfer (AXFR)&nbsp;</span> · `WSTG-CONF-01`

*When:* port 53 is open on TCP and `dnsenum` is missing, or you want a quick manual check. Try it once per name server; if refused, move on.

```bash
dig axfr <DOMAIN> @<NAMESERVER> > recon/dns-axfr-<DOMAIN>.txt
grep -c "IN" recon/dns-axfr-<DOMAIN>.txt
dig axfr <REVERSE_ZONE>.in-addr.arpa @<NAMESERVER>   # reverse zone, for reverse-record counts
```

> **Read:** The count is the record total. `Transfer failed.` in the file means it was refused. A reverse zone is transferred by its `in-addr.arpa` name, not by a single IP.

| Save to file | Next |
|:---:|---|
| `[x]` | Each hostname goes to `/etc/hosts` and the root checks. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Dangling CNAME check&nbsp;</span> · `WSTG-CONF-10`

*When:* a `<DOMAIN>` is in scope and a discovered subdomain has a CNAME record.

```bash
for s in <SUBDOMAIN>; do t=$(dig +short CNAME "$s"); [ -n "$t" ] && echo "$s -> $t resolves to: $(dig +short "$t" | head -1)"; done
```

> **Read:** An empty `resolves to:` value means the CNAME target does not exist. That is a takeover candidate, recorded as a lead only.

| Save to file | Next |
|:---:|---|
| `[ ]` | Record the subdomain and target. Do not claim the name. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;TLS certificate SANs&nbsp;</span> · `WSTG-CONF-01`

*When:* a host answers on HTTPS. It can surface hostnames that vhost fuzzing misses.

```bash
echo | openssl s_client -connect <IP>:<PORT> -servername <DOMAIN> 2>/dev/null | openssl x509 -noout -ext subjectAltName
```

> **Read:** Each `DNS:` entry is a hostname. Keep it as a `<SUBDOMAIN>` candidate.
> **Watch:** No `<DOMAIN>` yet: drop `-servername <DOMAIN>`. The certificate still lists its names, and that is one way to obtain a domain.

| Save to file | Next |
|:---:|---|
| `[ ]` | Add each name to `/etc/hosts`, then run the root checks on it. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;OSINT&nbsp;</span> · `WSTG-INFO-01` · `MANUAL` · host PC only

*When:* the exam letter names an external domain, or a question asks about public exposure. Kali has no internet, so do this on the host PC and record the result in your notes.

```text
site:<DOMAIN>
site:<DOMAIN> inurl:admin
site:<DOMAIN> filetype:sql OR filetype:env OR filetype:bak
site:<DOMAIN> intitle:"index of"
```

Archived copies: `https://web.archive.org/web/*/<DOMAIN>/*`. Registration data: `whois <DOMAIN>`.

> **Read:** A hit that names a path, backup, or admin page goes to the root checks on the lab host, if that host is in scope. Anything outside scope is noted, not tested.

| Save to file | Next |
|:---:|---|
| `[ ]` | Record the hits in your notes. |

***

## G. Metafiles, leaks & page content

Quick curl probes. Run them in Terminal 2 while the fuzzers work. They find what wordlists miss (dotfiles) and what only a human reads (comments).

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Status of each metafile&nbsp;</span> · `WSTG-INFO-03`

Once per vhost. Skip `robots.txt` if the nmap `http-robots.txt` script already reported it.

```bash
for f in robots.txt sitemap.xml .well-known/security.txt crossdomain.xml clientaccesspolicy.xml humans.txt; do curl -sk -o /dev/null -w "%{http_code} $f\n" "<SCHEME>://<VHOST>/$f"; done
curl -sk "<SCHEME>://<VHOST>/robots.txt" | grep -i disallow
```

> **Read:** `200` means read the file. `404` means absent. The `Disallow:` lines are the paths to test.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open every `Disallow:` path through Burp and test it like a discovered directory. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Source control and env leaks&nbsp;</span> · `WSTG-CONF-02`

Once per web root. Directory wordlists skip dotfiles, so this finds what the ffuf scan won't.

```bash
for p in .git/HEAD .svn/entries .env .DS_Store; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** Only `200` lines matter. `403` means the file exists but is blocked.

| Save to file | Next |
|:---:|---|
| `[ ]` | `.git/HEAD` at `200`: dump the repo with `wget -r` and read its config. `.env` at `200`: read it for credentials. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Debug and default endpoints&nbsp;</span> · `WSTG-CONF-02`

*When:* whatweb or headers point to a framework that ships these paths (Spring, Symfony, PHP), or a question mentions debug exposure.

```bash
for p in _profiler phpinfo.php actuator/env server-status console; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** `200` means the endpoint is live. `403` means present but blocked, so send it to block H.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each live endpoint in Burp. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Comments, JS, and hidden fields on the root page&nbsp;</span> · `WSTG-INFO-05`

A quick first pass while a scan runs. It does not replace reading the page source in the browser (block C); a regex misses multi-line comments and minified JS.

```bash
curl -sk "<SCHEME>://<VHOST>/" | grep -Eio '<!--.*-->|src="[^"]+\.js"|type="hidden"[^>]*' | sort -u
```

> **Read:** Comments and hidden values can show internal paths or debug notes. Each `.js` path is a file to open.

| Save to file | Next |
|:---:|---|
| `[ ]` | Each JS URL goes to the next step. A hidden value is a parameter for block J. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Secrets and internal IPs in a JS file&nbsp;</span> · `WSTG-INFO-05`

*When:* a `.js` file was found and is too large to read in Burp.

```bash
curl -sk "<JS_URL>" | grep -Eio '(api_key|secret|token|jwt)[^,;]{0,60}|10\.[0-9]+\.[0-9]+\.[0-9]+'
```

> **Read:** Each match shows a key name and its value. `10.x.x.x` addresses are internal hosts to note.

| Save to file | Next |
|:---:|---|
| `[ ]` | A real secret gets tested. An internal IP goes to the SSRF tests. |

***

## H. HTTP methods & forbidden paths

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Log every 403&nbsp;</span> · `WSTG-CONF-05`

*When:* the directory scan returned `403` rows. It queues them for verb tampering.

```bash
awk -F, 'NR>1 && $5==403 {print $2}' recon/ffuf-dirs-<VHOST>.csv > recon/forbidden-<VHOST>.txt
```

> **Read:** Each line is a path to test below.

| Save to file | Next |
|:---:|---|
| `[x]` | Run the verb tampering check on each path. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Allowed methods&nbsp;</span> · `WSTG-CONF-06`

*When:* a path answered 403, a question asks about HTTP methods, or the nmap `http-methods` output looks odd.

```bash
curl -sk -i -X OPTIONS "<SCHEME>://<VHOST>:<PORT>/" | grep -i allow
```

> **Read:** The `Allow:` header lists the verbs the server accepts. `PUT`, `DELETE` or `TRACE` listed are findings on their own.

| Save to file | Next |
|:---:|---|
| `[ ]` | Verbs missing from `Allow:` but still working go to the verb tampering step. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Verb tampering on a restricted path&nbsp;</span> · `WSTG-CONF-06`

*When:* `Allow:` lists a verb beyond GET, HEAD, and POST, or a 403 path needs a bypass attempt.

```bash
for m in GET HEAD POST PUT DELETE TRACE; do curl -sk --max-time 10 -o /dev/null -w "$m %{http_code}\n" -X $m "<SCHEME>://<VHOST>:<PORT>/admin/"; done
```

> **Read:** Any code other than `403` is a lead. A `200` with a different verb is a bypass candidate.
> **Watch:** A verb that answers differently on every path means the server treats it specially. To replay one request by hand, use Burp Repeater: right-click → *Change request method*.

| Save to file | Next |
|:---:|---|
| `[ ]` | A `200` opens in Burp Repeater with that verb, and the body is checked. |

***

## I. Web services & APIs

Web services are a large share of the exam. The goal here is only to find the endpoints; testing them is a later phase.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Web-service and API paths&nbsp;</span> · `WSTG-INFO-06`

Run on every web host. A page that you know serves SOAP can also be probed directly with `<PAGE>?wsdl`.

```bash
for p in "?wsdl" service?wsdl swagger.json swagger/index.html openapi.json v2/api-docs v3/api-docs api-docs graphql services api; do curl -sk -o /dev/null -w "%{http_code} %{size_download} $p\n" "<SCHEME>://<VHOST>:<PORT>/$p"; done
```

> **Read:** `200` on a WSDL, Swagger, or OpenAPI path is a full endpoint list. `401`, `405`, and `415` mean the endpoint exists and wants other credentials, a different verb, or a different content type. `400` from `graphql` means GraphQL is there.

| Save to file | Next |
|:---:|---|
| `[ ]` | Open each live path in Burp Repeater. An `/api` path goes to the endpoint brute force. Endpoints go to the web service tests. |

**If it fails →** cheatsheet: *Web services*.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;API endpoint brute force&nbsp;</span> · `WSTG-INFO-06` · `ASYNC`

*When:* the web-service probe, Burp, JS, or robots.txt shows an `/api` path.

```bash
ffuf -u "<SCHEME>://<VHOST>/api/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -mc all -fc 404 -ac -t 10 -o recon/ffuf-api-<VHOST> -of all
```

> **Read:** `awk -F, 'NR>1 {print $5,$6,$2}' recon/ffuf-api-<VHOST>.csv | sort -n`. `200` is an endpoint. `401` and `405` also mean it exists.
> **Watch:** For a `405` or `415` endpoint, retry the same path with the other verbs and with `Content-Type: application/json` or `text/xml` in Repeater.

| Save to file | Next |
|:---:|---|
| `[x]` | Each endpoint goes to Burp Repeater and the web service tests. |

**If it fails →** cheatsheet: *Wordlist fallbacks*, *Web services*.

***

## J. Parameter discovery

Parameters are usually visible in forms, links, and Burp. Fuzz names only when a page seems to accept input that you can't see. Keep `-t 5`: these requests hit application code, which is slower than static paths.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;GET parameter names&nbsp;</span> · `WSTG-INFO-06` · `ASYNC`

*When:* a page behaves differently with unknown input, or you suspect hidden functionality.

```bash
ffuf -u "<SCHEME>://<VHOST>/<PAGE>?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc all -ac -t 5 -o recon/ffuf-get-params -of all
```

> **Read:** `awk -F, 'NR>1 {print $1,$5,$6}' recon/ffuf-get-params.csv`. With `-ac`, every row is a parameter that changes the response.

| Save to file | Next |
|:---:|---|
| `[x]` | Note it for SQLi and XSS tests. Fuzz its values below. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;POST parameter names&nbsp;</span> · `WSTG-INFO-06` · `ASYNC`

*When:* as above, for a form-encoded POST.

```bash
ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "FUZZ=test" -H "Content-Type: application/x-www-form-urlencoded" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc all -ac -t 5 -o recon/ffuf-post-params -of all
```

> **Read:** Same as GET: each row is a body field that changes the response.

| Save to file | Next |
|:---:|---|
| `[x]` | Note it for SQLi, XSS, and logic tests. |

**If it fails →** cheatsheet: *Wordlist fallbacks* (parameter names), *wfuzz*.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Parameter values once a parameter is confirmed&nbsp;</span> · `WSTG-INFO-06`

*When:* a numeric ID parameter is confirmed and you suspect IDOR.

```bash
seq 1 1000 > recon/ids.txt
ffuf -u "<SCHEME>://<VHOST>/<PAGE>" -X POST -d "id=FUZZ" -H "Content-Type: application/x-www-form-urlencoded" -w recon/ids.txt -ac -t 5 -o recon/ffuf-id-values -of all
```

> **Read:** `awk -F, 'NR>1 && $5==200 {print $1,$6}' recon/ffuf-id-values.csv`. A `200` that differs from the calibrated baseline is another record.

| Save to file | Next |
|:---:|---|
| `[x]` | A record ID that exposes another user's data goes to the IDOR test. |

***

## K. Logged-in surface

Most of the application hides behind the login. Come back here as soon as you hold a cookie or credentials.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Directory scan with a session&nbsp;</span> · `WSTG-CONF-05` · `ASYNC`

*When:* you hold a working session cookie or credentials. Repeat the API probe (block I) and parameter checks with the same header.

```bash
ffuf -u "<SCHEME>://<VHOST>/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-medium-words.txt -e <EXT> -H "Cookie: <COOKIE>" -mc all -fc 404 -ac -t 10 -o recon/ffuf-dirs-auth-<VHOST> -of all
comm -13 <(awk -F, 'NR>1{print $2}' recon/ffuf-dirs-<VHOST>.csv | sort) <(awk -F, 'NR>1{print $2}' recon/ffuf-dirs-auth-<VHOST>.csv | sort)
```

> **Read:** The `comm` line prints only URLs that exist after login and not before. Those are the new pages.

| Save to file | Next |
|:---:|---|
| `[x]` | Open each new URL in Burp. Admin and account pages are the usual targets. |

**If it fails →** cheatsheet: *Authenticated scans*.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Map the workflows&nbsp;</span> · `WSTG-INFO-07` · `MANUAL`

*When:* once you have a login. Do it while other scans run.

Walk registration, login, profile edit, checkout, and password reset in the Burp browser. Replay any step in Repeater.

> **Read:** In Burp HTTP history, note where session tokens change between steps.

| Save to file | Next |
|:---:|---|
| `[ ]` | Multi-step flows go to the logic tests. |

***

## L. CMS (WordPress)

Kali has no internet, so wpscan runs **without** an API token and **without** a vulnerability database: it lists versions, plugins, themes, and users. Match versions with searchsploit. ⚠️ Confirm the flags on the exam image. Other CMS (Joomla, Drupal): cheatsheet → *CMS*.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Check for WordPress markers&nbsp;</span> · `WSTG-INFO-08`

*When:* whatweb or headers hint at WordPress without confirming it.

```bash
curl -sk "<SCHEME>://<VHOST>/" | grep -Eio 'wp-content|wp-includes|name="generator"[^>]*'
for p in wp-login.php wp-json/ xmlrpc.php readme.html; do curl -sk -o /dev/null -w "%{http_code} $p\n" "<SCHEME>://<VHOST>/$p"; done
```

> **Read:** `wp-content` or `wp-includes` in the source means WordPress. A `200` on `wp-login.php`, `wp-json/`, or `xmlrpc.php` confirms it. The generator tag shows the version.

| Save to file | Next |
|:---:|---|
| `[ ]` | WordPress confirmed goes to the blocks below. Another CMS goes to cheatsheet: *CMS*. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;WordPress version&nbsp;</span> · `WSTG-INFO-08`

*When:* WordPress is confirmed and `readme.html` still exists.

```bash
curl -sk "<SCHEME>://<VHOST>/readme.html" | grep -i "version"
```

> **Read:** Hardened sites remove this file, so use the wpscan version instead.

| Save to file | Next |
|:---:|---|
| `[ ]` | The version goes to searchsploit. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Full wpscan enumeration&nbsp;</span> · `WSTG-INFO-09` · `ASYNC`

*When:* WordPress is confirmed.

```bash
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -e u,ap,at,cb,dbe -o recon/wpscan-<VHOST>.txt
```

> **Read:** `grep -E "\[\+\]|\[!\]" recon/wpscan-<VHOST>.txt`. `[+]` lists version, theme, plugins, and users. `[!]` is a warning. With no vulnerability data, `[!]` rarely names a CVE, so run searchsploit on each plugin and theme name and version.

| Save to file | Next |
|:---:|---|
| `[x]` | Each plugin and theme goes to searchsploit. Each user goes to the password test. |

**If it fails →** cheatsheet: *CMS* (wpscan variants).

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Users only&nbsp;</span> · `WSTG-INFO-09`

*When:* the full enumeration listed no users, or you want them on their own.

```bash
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -e u
curl -sk "<SCHEME>://<VHOST>/wp-json/wp/v2/users" | grep -Eo '"slug":"[^"]+"'
```

> **Read:** Each username from either output is a login candidate.

| Save to file | Next |
|:---:|---|
| `[ ]` | Usernames go to the password test. Lab scope only. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Aggressive plugin detection&nbsp;</span> · `WSTG-INFO-09`

*When:* the default scan found few or no plugins, yet the site clearly uses some. Heavy: run it alone.

```bash
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks --plugins-detection aggressive -e ap -o recon/wpscan-plugins-<VHOST>.txt
```

> **Read:** Read each `[+]` plugin line and its version.

| Save to file | Next |
|:---:|---|
| `[x]` | Each plugin and version goes to `searchsploit "<PRODUCT> <VERSION>"`. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Password test&nbsp;</span> · `WSTG-INFO-09` · lab scope only

*When:* a username is confirmed and brute force is in scope. Brute force is rarely the answer, so try it after the other leads.

```bash
gunzip -k /usr/share/wordlists/rockyou.txt.gz   # only if rockyou.txt is still gzipped
wpscan --url "<SCHEME>://<VHOST>/" --no-update --disable-tls-checks -U <USER> -P /usr/share/wordlists/rockyou.txt -o recon/wpscan-bruteforce-<VHOST>.txt
```

> **Read:** `grep "SUCCESS" recon/wpscan-bruteforce-<VHOST>.txt` shows the valid user and password.

| Save to file | Next |
|:---:|---|
| `[x]` | Log in (then block K). Check the theme and plugin editors and the upload page. |

***

## M. TLS & HTTPS configuration

*When:* a host answers on HTTPS, or a question asks about TLS, ciphers, certificates or HSTS. Certificate names (SANs) are in block F.

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;TLS weaknesses&nbsp;</span> · `WSTG-CRYP-01`

```bash
nmap -Pn -n -sV -p <HTTPS_PORTS> --script ssl-enum-ciphers,ssl-cert,ssl-heartbleed <IP> -oN recon/nmap-tls-<IP>.txt
```

> **Read:** `grep -E "SSLv|TLSv1\.0|TLSv1\.1|least strength|VULNERABLE|RC4|3DES|Not valid after" recon/nmap-tls-<IP>.txt`. SSLv3, TLS 1.0 or 1.1 enabled, `least strength` of C or worse, RC4 or 3DES, or an expired cert are findings.

| Save to file | Next |
|:---:|---|
| `[x]` | Record the port and the weak protocol or cipher. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;HSTS header&nbsp;</span> · `WSTG-CONF-07`

```bash
curl -sk -D - -o /dev/null "<SCHEME>://<VHOST>:<PORT>/" | grep -i "strict-transport-security"
```

> **Read:** No output means HSTS is missing. A `max-age` of 0 or a very short value is weak.

| Save to file | Next |
|:---:|---|
| `[ ]` | Missing or weak HSTS is a configuration finding to note. |

***

## N. WAF & architecture

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;WAF detection&nbsp;</span> · `WSTG-INFO-10`

*When:* payloads get blocked or altered, or every request returns an identical page.

```bash
wafw00f "<SCHEME>://<VHOST>/" > recon/wafw00f-<VHOST>.txt
```

> **Read:** The WAF name is in the output. A "no WAF" result means none was found.

| Save to file | Next |
|:---:|---|
| `[x]` | A WAF found means: lower `-t`, encode payloads, and note it. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Compare a benign and a suspicious request&nbsp;</span> · `WSTG-INFO-10`

*When:* `wafw00f` was inconclusive, or you want to confirm a WAF before changing tactics.

```bash
curl -sk -o /dev/null -w "benign %{http_code}\n" "<SCHEME>://<VHOST>/?q=test"
curl -sk -o /dev/null -w "payload %{http_code}\n" "<SCHEME>://<VHOST>/?q=<script>alert(1)</script>"
curl -sk -D - -o /dev/null "<SCHEME>://<VHOST>/" | grep -iE "via|x-cache|cf-ray|x-forwarded"
```

> **Read:** A different status (403, 406) or a block page for the payload means a WAF is in front. The `via`, `x-cache`, and `cf-ray` headers name the proxy.

| Save to file | Next |
|:---:|---|
| `[ ]` | Same as above. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Map the architecture&nbsp;</span> · `WSTG-INFO-10` · `MANUAL`

*When:* after the Burp site map has enough pages, or a question asks about components.

Build a component list: front-end host, API hosts, third-party script hosts, and any reverse proxy or CDN.

```bash
curl -sk "<SCHEME>://<VHOST>/" | grep -Eo '(src|href)="https?://[^"/]+' | sort -u
```

> **Read:** Each host that differs from `<VHOST>` is a separate component. Same-host paths belong to the app itself.

| Save to file | Next |
|:---:|---|
| `[ ]` | Write the component list in your notes. Each separate in-scope host gets the root checks. |

***

## O. Close out

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Quick vulnerability scan&nbsp;</span> · `WSTG-INFO-02` · `ASYNC` · run last, alone

Completeness check once every other scan is done. It is the noisiest tool, so it runs by itself. Treat results as leads, not findings.

```bash
nikto -h "<SCHEME>://<VHOST>:<PORT>/" -o recon/nikto-<VHOST>-<PORT>.txt
```

> **Read:** `grep "^+" recon/nikto-<VHOST>-<PORT>.txt` shows the findings. Each one is a lead.

| Save to file | Next |
|:---:|---|
| `[x]` | Verify each lead in Burp before it goes in your notes. |

**If it fails →** cheatsheet: *Nikto*.

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Completeness pass&nbsp;</span> · `MANUAL`

One pass per target, not one per finding.

- Each web port has: whatweb, headers, directories, backups, metafiles, web-service probe.
- Each `403` was tested for verbs.
- Each discovered hostname and port got the root checks.
- Count questions: every endpoint was re-checked, not just the first one.
- Each answer is submitted, and `recon/` and your notes are copied to the host PC (paste the output, since files cannot be uploaded).

***

## Question → where to look

When a question mentions one of these, run the matching block. Skip the rest.

| The question mentions | Run | WSTG |
|---|---|---|
| Open ports, what runs on a port, how many hosts | Full scan, host discovery (B) | CONF-01 |
| FTP, rsync, NFS exposing files | Non-web services (B) | CONF-01 |
| Web server, language, framework, version | whatweb, headers (D) | INFO-02 |
| Known vulnerability for a version | searchsploit (D) | INFO-02 |
| Error message, stack trace | Verbose error (D) | INFO-02 |
| Hidden page, directory, admin panel | Directory scan (E), admin keywords (E) | CONF-05 |
| Backup, old or source file | Backup scan, alternate extensions (E) | CONF-04, CONF-03 |
| Directory listing, "Index of" | Directory listing (E) | CONF-04 |
| Subdomain, vhost | VHost fuzzing, dnsenum (F) | INFO-04 |
| DNS record, A/TXT/SRV/PTR, zone, name server | DNS records, AXFR, UDP 53 (F, B) | INFO-04, CONF-01 |
| Takeover, CNAME | Dangling CNAME (F) | CONF-10 |
| Certificate, SAN, HTTPS name | TLS SANs (F) | CONF-01 |
| Public exposure, Google, archived pages | OSINT (F, host PC) | INFO-01 |
| robots.txt, sitemap, security.txt | Metafiles (G) | INFO-03 |
| Comments, hidden fields, JS, API keys, internal IPs | Page content, JS secrets (G) | INFO-05 |
| `.git`, `.env`, debug, actuator, phpinfo, status page | Leaks, debug endpoints (G) | CONF-02 |
| HTTP methods, TRACE, OPTIONS, PUT | Allowed methods (H) | CONF-06 |
| Forbidden page, 403 bypass | Log 403s, verb tampering (H) | CONF-06, CONF-05 |
| Security headers, cookie flags, server banner | Headers (D) | INFO-02 |
| WSDL, SOAP, REST, Swagger, GraphQL, API endpoint | Web-service probe, API brute force (I) | INFO-06 |
| How many pages, forms, parameters, entry points | Burp walk, ZAP spider (C) | INFO-06 |
| Hidden parameter, ID values, IDOR | Parameter discovery (J) | INFO-06 |
| Login, session, pages behind login | Logged-in surface (K) | CONF-05 |
| Registration, checkout, reset, workflow | Map the workflows (K) | INFO-07 |
| WordPress, plugin, theme, user, CMS version | CMS (L) | INFO-08, INFO-09 |
| Cipher, TLS version, protocol | TLS weaknesses (M) | CRYP-01 |
| HSTS | HSTS header (M) | CONF-07 |
| WAF, blocked payload | WAF detection (N) | INFO-10 |
| Third-party hosts, architecture, CDN | Map the architecture (N) | INFO-10 |

***

## Discovery → next step

| What you found | Do next |
|---|---|
| Subnet in scope | Host discovery, then a full scan per live host (B) |
| Open web port | whatweb, headers, then the directory scan on `<SCHEME>://<IP>:<PORT>` (D, E) |
| Port 53 open, or a domain question | dnsenum, DNS records (F). No TCP 53: UDP check (B) |
| SAN, AXFR, or vhost hit | Add to `/etc/hosts`, then run the root checks on it |
| 200 / 301 / 302 path | Open in Burp, add to Site map |
| 401 / 405 / 500 path | An API or an error: read it in Burp Repeater, try other verbs and content types |
| 403 path | Verb tampering (H) |
| Login works, or you hold a cookie | Logged-in surface (K) and the API probe with the cookie |
| WSDL, Swagger, or `/api` | API endpoint brute force (I), then the web service tests |
| HTTPS port | TLS weaknesses (M) |
| FTP anonymous or open rsync/NFS | Check for web files (B) |
| WAF or blocked payload | Lower `-t`, encode payloads, note the WAF (N) |
| Backup, `.git`, `.env`, or an archive | Download it and read it before anything else |
| WordPress fingerprint | Block L. Joomla or Drupal: cheatsheet → *CMS* |
| Parameter that changes output | Note it for SQLi, XSS, IDOR, and logic tests |
| Subdomain with a CNAME | Dangling CNAME check (F) |
| Version string anywhere | searchsploit (D) |
| Exam names an external domain | OSINT on the host PC (F) |

***

## Troubleshooting

| What happens | What to do |
|---|---|
| nmap is slow or times out | Slow variant in the cheatsheet (`-T3 --max-retries 2 --host-timeout 20m`) |
| Fuzzer gives hundreds of hits | The calibration is wrong. Measure a baseline and use `-fs <BASELINE>` instead of `-ac` |
| Fuzzer gives nothing | Check the wordlist path, then try the small list, then the cheatsheet fallback |
| Everything returns 403 | Verb tampering (H), then the API probe (I) |
| Everything returns 200 | Custom error page. Use `-fs` with the size from the baseline command |
| Tool or wordlist missing | Cheatsheet → *Wordlist fallbacks* and the substitute tool for that section. Do not install |
| VM freezes | `htop`, stop the newest job, run fewer jobs |
| Port 53 not visible in the TCP scan | UDP check (B). DNS is usually UDP |
| Zone transfer refused or times out | AXFR needs TCP 53. Fall back to dnsenum brute force and DNS records (F) |
| No web ports found | Re-read the full scan, then the UDP scan, then the non-web services (B), then the other hosts |
| A name shows a different site than the IP | Add the name to `/etc/hosts`, or send the `Host` header by hand |
| HTTPS certificate errors | Every command here already uses `-k` or `--disable-tls-checks` |
| Burp history stays empty | Check the browser proxy is `<PROXY>`, Intercept is off, and the host is in scope |
| wpscan asks for an API token | Expected without internet. Use `--no-update` and run searchsploit on each version |
| Login page found | Logged-in surface (K) |
| Anonymous FTP shows web files | Non-web services (B) |
| Kali reset | Re-create `recon/` and `/etc/hosts`, restore notes from the host PC. Found flags stay valid |

***
