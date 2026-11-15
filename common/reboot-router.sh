#!/bin/bash
ROUTER_IP="192.168.1.1"
ACCESS_CODE="664*=9<%#@"
COOKIE_FILE="/tmp/router_cookies.txt"

echo "Initiating AT&T BGW320 reboot sequence..."

# Ensure clean slate
rm -f "$COOKIE_FILE"

# --- STAGE 1: PRIME THE COOKIE JAR ---
# The BGW320 always rejects the first request. This dummy request grabs the session cookie.
curl -s -c "$COOKIE_FILE" "http://$ROUTER_IP/cgi-bin/restart.ha" > /dev/null

# --- STAGE 2: GET LOGIN TOKEN ---
# Request the page again WITH the cookie to finally get the login form
LOGIN_HTML=$(curl -s -c "$COOKIE_FILE" -b "$COOKIE_FILE" "http://$ROUTER_IP/cgi-bin/restart.ha")
LOGIN_NONCE=$(echo "$LOGIN_HTML" | grep 'name="nonce"' | head -n 1 | sed 's/.*value="\([^"]*\)".*/\1/')

if [ -z "$LOGIN_NONCE" ]; then
    echo "Error: Could not retrieve the login token."
    rm -f "$COOKIE_FILE"
    exit 1
fi

# --- STAGE 3: AUTHENTICATE ---
# Submit the Access Code to authenticate the session
curl -s -c "$COOKIE_FILE" -b "$COOKIE_FILE" -X POST "http://$ROUTER_IP/cgi-bin/restart.ha" \
     -d "nonce=$LOGIN_NONCE" \
     -d "password=$ACCESS_CODE" > /dev/null
     
# --- STAGE 4: GET REBOOT TOKEN ---
# Request the restart page again as an authenticated user to get the final reboot token
RESTART_HTML=$(curl -s -b "$COOKIE_FILE" "http://$ROUTER_IP/cgi-bin/restart.ha")
REBOOT_NONCE=$(echo "$RESTART_HTML" | grep 'name="nonce"' | head -n 1 | sed 's/.*value="\([^"]*\)".*/\1/')

if [ -z "$REBOOT_NONCE" ]; then
    echo "Error: Could not retrieve the reboot token. Authentication failed."
    rm -f "$COOKIE_FILE"
    exit 1
fi

echo "Tokens acquired successfully. Sending reboot command..."

# --- STAGE 5: REBOOT ---
# Execute the reboot (Remove the # on the next 3 lines to make it live)
curl -s -b "$COOKIE_FILE" -X POST "http://$ROUTER_IP/cgi-bin/restart.ha" \
     -d "nonce=$REBOOT_NONCE" \
     -d "Restart=Restart" > /dev/null
     
echo "Reboot command sent to $ROUTER_IP successfully."

# Clean up
rm -f "$COOKIE_FILE"
