#!/bin/bash

# 1. Turn on the global macOS File Sharing engine
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist

# 2. Add your primary user account to the SMB authentication database
sudo dscl . -append /Groups/com.apple.access_smb GroupMembership $USER

# 3. Create a dedicated Media folder if it doesn't exist yet
mkdir -p "$HOME/Movies/Media"

# 4. Explicitly share that folder out over SMB under the network label "Media"
sudo sharing -a "$HOME/Movies/Media" -s 111 -g 111 -n "Media"

echo "================================================="
echo "🚀 SMB Sharing Engine Initialized!"
echo "📍 Share Path: smb://$(hostname)/Media"
echo "================================================="
