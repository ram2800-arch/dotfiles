#!/bin/bash

echo "Politely closing applications and shutting down..."

# Use AppleScript to command the system to shut down cleanly
osascript -e 'tell application "System Events" to shut down'

