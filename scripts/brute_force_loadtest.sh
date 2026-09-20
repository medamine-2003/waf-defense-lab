#!/bin/bash
# Simulates a brute-force login attack against DVWA's Brute Force page,
# used to test SafeLine WAF's rate-limiting (HTTP Flood / Basic Access Limit).
#
# Run BEFORE enabling any rate-limiting rule to establish a baseline (expect all 302),
# then again AFTER enabling a rule to confirm it triggers (expect 403 or 468).

TARGET="http://dvwa.lab/vulnerabilities/brute/"
COOKIE="PHPSESSID=<your_session_id>; security=low"
REQUEST_COUNT=120
CONCURRENCY=20

seq 1 "$REQUEST_COUNT" | xargs -P "$CONCURRENCY" -I{} curl -s -o /dev/null -w "%{http_code}\n" \
  "${TARGET}?username=admin&password=wrong{}&Login=Login" \
  -b "$COOKIE" | sort | uniq -c

# Baseline result (no rate limiting): 120x 302
# After enabling SafeLine's "Basic Access Limit" preset (100 req/10s -> Anti-Bot challenge):
# 120x HTTP 468 (SafeLine's custom Anti-Bot Challenge status code)
