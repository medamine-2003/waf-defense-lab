#!/bin/bash
# Logs into DVWA and captures a valid session cookie for use in other scripts.
# DVWA requires a fresh CSRF token (user_token) per login attempt.

TARGET_BASE="http://dvwa.lab"
USERNAME="admin"
PASSWORD="password"

# Fetch login page and cookie jar
curl -c cookies.txt "$TARGET_BASE/login.php" -o login.html

# Extract CSRF token from the login form
TOKEN=$(grep -oP "user_token' value='\K[^']+" login.html)
echo "Token: $TOKEN"

# Submit login
curl -v -b cookies.txt -c cookies.txt \
  -d "username=$USERNAME&password=$PASSWORD&Login=Login&user_token=$TOKEN" \
  "$TARGET_BASE/login.php"

# Confirm session and print the cookie to use in other scripts
echo "---"
echo "Session cookie:"
grep PHPSESSID cookies.txt
