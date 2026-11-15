#!/bin/bash
ROUTER_IP="192.168.1.1"
ACCESS_CODE="664*=9<%#@"

echo "Initiating AT&T BGW320 reboot sequence..."

# Step 1: Request the restart page to grab the dynamic security token (nonce)
HTML_RESPONSE=$(curl -s "http://$ROUTER_IP/cgi-bin/restart.ha")
NONCE=$(echo "$HTML_RESPONSE" | grep -oP 'name="nonce" value="\K[^"]+')

if [ -z "$NONCE" ]; then
    echo "Error: Could not retrieve the security token. Ensure the IP is correct."
    exit 1
fi
echo $NONCE
# Step 2: Post the restart command using the captured token and your access code
#curl -s -X POST "http://$ROUTER_IP/cgi-bin/restart.ha" \
     -d "nonce=$NONCE" \
     -d "password=$ACCESS_CODE" \
     -d "Restart=Restart"

#echo "Reboot command sent to $ROUTER_IP successfully."
