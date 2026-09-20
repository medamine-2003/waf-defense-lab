# WAF Defense Lab — SafeLine WAF vs. DVWA

Deployment, attack testing, and custom rule hardening of a Web Application Firewall (SafeLine WAF, Chaitin Tech) protecting a deliberately vulnerable web application (DVWA).

## Overview

This project evaluates a production-grade WAF's default protection against common web attack classes, identifies gaps through manual and automated testing (including `sqlmap`), and closes those gaps with custom deny rules and rate-limiting configuration.

**Stack:** Docker (WSL2 backend) · SafeLine WAF · DVWA (Apache/PHP/MySQL) · Kali Linux (attacker VM)

## Architecture

```
Kali Linux (attacker VM)
        │
        ▼
 SafeLine WAF (reverse proxy, port 80/443)
        │
        ▼
 DVWA container (port 8888, upstream)
```

Windows host running Docker Desktop (WSL2) hosts both the WAF and target application as containers; a separate Kali VM, bridged onto the same network, acts as the attacker.

## Methodology

1. **Setup** — deployed SafeLine WAF and DVWA via Docker, registered the application, routed traffic through the WAF via a custom domain.
2. **Baseline testing** — ran each major DVWA vulnerability class against the WAF's default ruleset (Low security level).
3. **Automated bypass attempts** — used `sqlmap` with escalating tamper scripts to test whether default rules could be evaded.
4. **Gap analysis** — identified which attack classes the WAF detected-but-didn't-block vs. fully missed.
5. **Custom rule development** — wrote deny rules and rate-limiting configuration to close the identified gaps.
6. **Validation** — retested every closed gap to confirm the fix.

## Results — Default Ruleset

| Attack | Result |
|---|---|
| SQL Injection (manual + sqlmap, 3 tamper-script attempts) | Blocked |
| XSS (Reflected, Stored, DOM) | Blocked |
| Blind SQL Injection | Blocked |
| File Upload | Blocked |
| File Inclusion (LFI) | Blocked |
| CSRF | Audited only (not blocked) |
| Command Injection | Audited only (not blocked) |
| Brute Force | Unprotected (no rate limiting by default) |

## Results — After Custom Hardening

| Gap | Fix | Result |
|---|---|---|
| Command Injection | Deny rule — regex match on POST field `ip` | Blocked |
| CSRF | Deny rule — regex match on URL path/query pattern | Blocked |
| Brute Force | Built-in rate-limiting preset (100 req/10s → Anti-Bot challenge) | Confirmed working (HTTP 468 challenge triggered under load test) |

## Key Findings

- SafeLine correctly fingerprinted itself to `sqlmap` ("SafeLine Next Gen WAF") and held under three escalating bypass attempts (space2comment/charencode, between/randomcase, default) — zero successful injection across all runs.
- **Default policy differs by attack class**: signature-matchable payload attacks (SQLi, XSS) are blocked outright; logic/execution-style attacks (CSRF, Command Injection) are detected but only logged ("Audited") by default — closing this gap required explicit custom rules.
- **Licensing boundary**: SafeLine Community Edition gates custom HTTP Flood (rate-limiting) rules behind a Pro license; the built-in "Basic Access Limit" preset remained usable and was confirmed functional as a free-tier alternative.
- **Infrastructure limitation**: WSL2's NAT layer caused all attacker source IPs to be logged as `127.0.0.1` at the WAF layer — a known infra-level constraint, not a WAF misconfiguration; documented rather than worked around.

## Limitations

- Some DVWA categories (Insecure CAPTCHA, Weak Session IDs, client-side JavaScript challenges) were excluded — these are application-logic or client-side flaws outside a network WAF's inspection scope.
- Custom Allow & Deny rules and SafeLine's semantic attack-detection engine log to separate dashboards; this is a product design detail worth knowing when auditing WAF logs.

## Repository Contents

```
/screenshots   — key evidence (blocks, sqlmap output, rule configuration)
/scripts       — attack scripts (sqlmap commands, curl load-test loops)
/configs       — sanitized SafeLine rule exports, docker-compose reference
```

## Full Write-Up

A detailed technical report (setup, troubleshooting, full test log) is available [here](#) *(link to blog post / full report if published)*.
