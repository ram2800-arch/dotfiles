#!/bin/bash

# Ensure the script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo."
   exit 1
fi

TARGET_USER="ram2800"
SUDOERS_DIR="/etc/sudoers.d"
SUDOERS_FILE="$SUDOERS_DIR/90-$TARGET_USER-nopasswd"

echo "Setting up passwordless sudo for $TARGET_USER on $(uname -s)..."

# macOS sometimes does not generate the sudoers.d directory by default
if [[ ! -d "$SUDOERS_DIR" ]]; then
    mkdir -p "$SUDOERS_DIR"
    chmod 0755 "$SUDOERS_DIR"
fi

# Write the permission rule
echo "$TARGET_USER ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"

# Strict permissions are required by the OS
chmod 0440 "$SUDOERS_FILE"

# Safely validate the syntax to prevent locking yourself out of root
if visudo -c -f "$SUDOERS_FILE"; then
    echo "Success: Passwordless sudo drop-in created at $SUDOERS_FILE."
    
    # macOS specific dependency check
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo ""
        echo "Note for macOS: Ensure your system is configured to read drop-in files."
        echo "If passwordless sudo doesn't work immediately on the Mac mini, run 'sudo visudo'"
        echo "and verify this exact line is at the bottom of the file (the # is required, it is a directive, not a comment):"
        echo "#includedir /private/etc/sudoers.d"
    fi
else
    echo "Error: Syntax issue detected. Reverting to protect sudo access..."
    rm -f "$SUDOERS_FILE"
    exit 1
fi
