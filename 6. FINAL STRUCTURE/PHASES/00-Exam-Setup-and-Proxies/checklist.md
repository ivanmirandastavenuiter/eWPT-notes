# 00-Exam-Setup: Pre-Flight Checklist

### Phase 1: Network & Target Verification

* [ ] Connect to the exam VPN environment.
* [ ] Verify routing to the target IP(s) provided in the exam letter:
`ping -c 4 [TARGET_IP]`
* [ ] Run a rapid, non-intrusive scan to confirm web ports are accessible (ignore legacy network ports):
`nmap -Pn -n -T4 -p 80,443,8080,8180,8443 [TARGET_IP]`

### Phase 2: DNS & Virtual Host Mapping

* [ ] Identify the primary root domain (e.g., `target.com`) provided in the exam letter.
* [ ] Edit local DNS routing to map the IP to the domain:
`sudo nano /etc/hosts`
* [ ] Add the entry: `[TARGET_IP] target.com`
* [ ] Verify local DNS resolution is working:
`ping -c 1 target.com`
* [ ] *Note: Keep `/etc/hosts` open or easily accessible. As you discover subdomains (like `admin.target.com`) during Information Gathering, immediately append them to this line.*

### Phase 3: Browser & Certificate Configuration

*Choose ONE browser method below before starting:*

**Option A: Burp Embedded Browser (Fastest)**

* [ ] Navigate to **Proxy > Intercept** and click **Open Browser**.
* [ ] Verify traffic populates the HTTP history.

**Option B: Kali Firefox (For custom extensions/Wappalyzer)**

* [ ] Start Firefox and enable FoxyProxy (routing to `127.0.0.1:8080`).
* [ ] Navigate to `http://burp` and download `cacert.der`.
* [ ] Go to Firefox Settings > Certificates > View Certificates > Authorities > Import.
* [ ] Import `cacert.der` and check **"Trust this CA to identify websites"**.
* [ ] Navigate to an HTTPS target page and confirm the traffic appears cleanly in Burp.

### Phase 4: Burp Suite Scoping & Filtering

* [ ] Open Burp Suite (Community Edition).
* [ ] Navigate to **Target > Scope settings** and check **Use advanced scope control**.
* [ ] Click **Add** under "Include in scope". Leave protocol as `Any`.
* [ ] Add the raw target IP: e.g., `10.0.x.x`
* [ ] Add the wildcard for the root domain: e.g., `.*\.target\.com`
* [ ] Navigate to **Proxy > HTTP history**. Click the filter bar at the top.
* [ ] Check **Show only in-scope items**.
* [ ] Check **Hide uninteresting content** (filters out CSS, JS, images).
* [ ] Turn Intercept ON, click through the main application pages normally to populate the **Target > Site map** tab, then turn Intercept OFF.
* [ ] For filtering proxy interceptor, go to proxy settings > and, url is in target scope.

### Phase 5: Evidence Preservation Strategy (Burp Community)

*Because Burp Community cannot save project files, set up your backup habits now:*

* [ ] Open your `target_scratchpad_template.md` to log findings.
* [ ] Rule established: The moment a vulnerability is confirmed, right-click the Request/Response in Burp and paste the raw text into the scratchpad.
* [ ] Rule established: Use **Repeater** tabs as a workspace. Double-click tab headers to rename them (e.g., `SQLi-Login`, `XSS-Search`).
* [ ] Rule established: For critical exploit chains, right-click the request in Burp and select **Save item** to export the XML backup to your Kali host.