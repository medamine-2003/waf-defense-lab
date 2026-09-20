# SafeLine WAF — Custom Rules Reference

Sanitized configuration of the custom rules built to close gaps found during baseline
testing. All three were created under **Allow & Deny → Custom Rules** unless noted.

---

## 1. Command Injection — Deny Rule

| Field | Value |
|---|---|
| Name | `Block-CommandInjection` |
| Type | Deny Rule |
| Insert Position | First |
| Match Target | POST (Header Field: `ip`) |
| Operator | Regex Match |
| Content | `;.*\b(whoami|id|cat|ls|wget|curl)\b` |
| Enabled | Yes |

**Why POST and not URL Path:** DVWA's Command Injection form submits the target IP
via a POST body field named `ip`, not a query string — an initial rule matching
`URL Path` never saw the payload and had to be corrected.

---

## 2. CSRF — Deny Rule

| Field | Value |
|---|---|
| Name | `Block-CSRF-PasswordChange` |
| Type | Deny Rule |
| Match Target | URL Path |
| Operator | Regex Match |
| Content | `/vulnerabilities/csrf/\?password_new=.+&password_conf=.+&Change=Change` |
| Enabled | Yes |

---

## 3. Brute Force — Rate Limiting

Custom HTTP Flood rule (path `/vulnerabilities/brute/`, 8 req/10s, Block action) was
**configured but not activated** — SafeLine Community Edition gates the custom HTTP
Flood rule engine behind a Pro license. Configuration is documented below for
reference; the working free-tier alternative used instead is listed after it.

### 3a. Custom rule (documented, not activated — requires Pro license)

| Field | Value |
|---|---|
| Name | `Brute-Force-RateLimit` |
| Match Target | URL Path — Equals — `/vulnerabilities/brute` |
| Duration | 10 sec |
| Access (threshold) | 8 requests |
| Action | Block |

### 3b. Working alternative — built-in preset (free tier)

Dashboard: Applications → [App] → HTTP Flood → Rate Limiting → **Basic Access Limit** (toggled on)

| Field | Value |
|---|---|
| Threshold | 100 requests / 10 sec |
| Action | Anti-Bot Challenge |
| Challenge validity | 60 minutes |

Confirmed functional: a 120-request parallel load test against the brute-force
endpoint returned HTTP 468 (SafeLine's custom Anti-Bot Challenge code) on all
requests once enabled, versus HTTP 302 (unthrottled) on the same test beforehand.
