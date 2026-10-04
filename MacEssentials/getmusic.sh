#!/bin/bash

# Default values
TYPE="v"
URL=""
ID=""
SERVICE="y" # Default to standard YouTube

# Parse the flags
while getopts "u:t:i:s:" opt; do
  case $opt in
    u) URL="$OPTARG" ;;
    t) TYPE="$OPTARG" ;;     # 'p' for playlist, 'v' for video
    i) ID="$OPTARG" ;;       # YouTube ID (MANDATORY)
    s) SERVICE="$OPTARG" ;;  # 'm' for music, 'y' for youtube
    *) echo "Usage: getmusic -i [id] -t [p/v] -s [m/y]"; exit 1 ;;
  esac
done

# --- MANDATORY ID CHECK ---
if [ -z "$ID" ]; then
    echo "ERROR: YouTube ID (-i) is mandatory."
    echo "Usage: getmusic -i <ID> [-t p/v] [-s m/y]"
    exit 1
fi

# 1. URL Builder (Strictly using ID)
if [ "$SERVICE" == "m" ]; then
    DOMAIN="music.youtube.com"
else
    DOMAIN="youtube.com"
fi

if [ "$TYPE" == "p" ]; then
    URL="https://$DOMAIN/playlist?list=$ID"
else
    URL="https://$DOMAIN/watch?v=$ID"
fi

# 2. Destination setup
DEST_DIR=~/Music/YouTube_Downloads
mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit

# 3. Set formatting based on Type

if [ "$TYPE" == "p" ]; then
    echo "--- Mode: Playlist ($SERVICE) ---"
    PL_FLAG="--yes-playlist"
    # CHANGE THE LINE BELOW:
    OUT_PATH="%(playlist_title)s/%(playlist_index)03d - %(title)s [%(id)s].%(ext)s"
else
    echo "--- Mode: Single Video ($SERVICE) ---"
    PL_FLAG="--no-playlist"
    OUT_PATH="%(title)s [%(id)s].%(ext)s"
fi

# 4. The Download Command
yt-dlp -f "ba[ext=m4a]" \
    --extract-audio --audio-format m4a \
    --add-metadata --embed-thumbnail --convert-thumbnails jpg \
    --ignore-errors \
    --no-abort-on-error \
    --fragment-retries infinite \
    $PL_FLAG \
    --download-archive "$DEST_DIR/downloaded.txt" \
    --parse-metadata "webpage_url:%(comment)s" \
    -o "$OUT_PATH" \
    "$URL"

# 5. Mac Notifications
say "Music download complete"
osascript -e 'display notification "Tracks saved to Music folder" with title "yt-dlp Success"'
open .
