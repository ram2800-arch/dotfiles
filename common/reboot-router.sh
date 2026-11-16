#!/bin/bash
ROUTER_IP="192.168.1.1"
ACCESS_CODE="664*=9<%#@"
COOKIE_FILE="/tmp/router_cookies.txt"

echo "Initiating AT&T BGW320 reboot sequence..."

# Ensure clean slate
rm -f "$COOKIE_FILE"

# --- STAGE 1: PRIME THE COOKIE JAR ---
curl -s -c "$COOKIE_FILE" "http://$ROUTER_IP/cgi-bin/restart.ha" > /dev/null

# --- STAGE 2: GET LOGIN TOKEN ---
LOGIN_HTML=$(curl -s -c "$COOKIE_FILE" -b "$COOKIE_FILE" "http://$ROUTER_IP/cgi-bin/restart.ha")
LOGIN_NONCE=$(echo "$LOGIN_HTML" | grep 'name="nonce"' | head -n 1 | sed 's/.*value="\([^"]*\)".*/\1/')

if [ -z "$LOGIN_NONCE" ]; then
    echo "Error: Could not retrieve the login token."
    rm -f "$COOKIE_FILE"
    exit 1
fi

# --- STAGE 3: AUTHENTICATE (Simulate JavaScript Hashing) ---
# Cross-platform MD5 hash generation to bypass the errlogin rejection
if command -v md5sum >/dev/null 2>&1; then
    HASH=$(printf "%s" "${ACCESS_CODE}${LOGIN_NONCE}" | md5sum | awk '{print $1}')
else
    HASH=$(printf "%s" "${ACCESS_CODE}${LOGIN_NONCE}" | md5 -q)
fi

# Send the exact payload the router's backend expects
curl -s -c "$COOKIE_FILE" -b "$COOKIE_FILE" -X POST "http://$ROUTER_IP/cgi-bin/login.ha" \
     -d "nonce=$LOGIN_NONCE" \
     -d "password=" \
     -d "hashpassword=$HASH" \
     -d "Continue=Continue" > /dev/null
     
# --- STAGE 4: GET REBOOT TOKEN ---
RESTART_HTML=$(curl -s -b "$COOKIE_FILE" "http://$ROUTER_IP/cgi-bin/restart.ha")
REBOOT_NONCE=$(echo "$RESTART_HTML" | grep 'name="nonce"' | head -n 1 | sed 's/.*value="\([^"]*\)".*/\1/')

if [ -z "$REBOOT_NONCE" ]; then
    echo "Error: Could not retrieve the reboot token. Authentication failed."
    rm -f "$COOKIE_FILE"
    exit 1
fi

echo "Tokens acquired successfully. Sending reboot command..."

# --- STAGE 5: REBOOT ---
# Send the reboot command with strict browser headers
curl -s -b "$COOKIE_FILE" -X POST "http://$ROUTER_IP/cgi-bin/restart.ha" \
     -H "Origin: http://$ROUTER_IP" \
     -H "Referer: http://$ROUTER_IP/cgi-bin/restart.ha" \
     -d "nonce=$REBOOT_NONCE" \
     -d "Restart=Restart" > /dev/null
     
# --- STAGE 6: FINALIZE SEQUENCE ---
# Follow the meta-refresh redirect to trigger the final power cycle
curl -s -b "$COOKIE_FILE" "http://$ROUTER_IP/cgi-bin/restarting.ha" > /dev/null
     
echo "Reboot command sent to $ROUTER_IP successfully."

# Clean up
rm -f "$COOKIE_FILE"
