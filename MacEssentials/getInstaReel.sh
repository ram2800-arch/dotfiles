#!/bin/zsh

# Initialize variable
REEL_ID=""

# Parse command-line options using lowercase i
while getopts "i:" opt; do
  case ${opt} in
    i )
      REEL_ID=$OPTARG
      ;;
    \? )
      echo "Usage: ./getInstareel.sh -i <Reel_ID>"
      return 1
      ;;
  esac
done

# Validate that an ID was actually passed
if [ -z "$REEL_ID" ]; then
    echo "Error: Missing Reel ID."
    echo "Usage: ./getInstareel.sh -i TSmjS0Evgp"
    return 1
fi

# Construct the static URL target
BASE_URL="https://www.instagram.com/reel/"
FULL_URL="${BASE_URL}${REEL_ID}/"
TARGET_DIR="$HOME/Downloads"

echo "Processing Instagram Reel ID: $REEL_ID"
echo "Target URL: $FULL_URL"

# 1. Execute yt-dlp to save pristine MP4 and sidecar description
yt-dlp \
    --paths "$TARGET_DIR" \
    --format "bv*+ba/b" \
    --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    --referer "https://www.instagram.com/" \
    --merge-output-format mp4 \
    --output "%(uploader)s_%(id)s.%(ext)s" \
    --no-playlist \
    --write-description \
    --embed-metadata \
    "$FULL_URL"

if [ $? -eq 0 ]; then
    echo "Download step complete. Injecting Finder comments via AppleScript..."
    
    # 2. Locate the precise files that were just generated
    TARGET_MP4=( $TARGET_DIR/*_${REEL_ID}.mp4(N) )
    TARGET_DESC=( $TARGET_DIR/*_${REEL_ID}.description(N) )
    
    if [ -f "$TARGET_MP4" ] && [ -f "$TARGET_DESC" ]; then
        # 3. Safely read description file contents into a variable
        local DESCR_CONTENT=$(<"$TARGET_DESC")
        
        # 4. Use native AppleScript to inject text directly into Finder's UI engine
        /usr/bin/osascript <<EOT
            tell application "Finder"
                set MacFile to (posix file "$TARGET_MP4") as alias
                set comment of MacFile to "$DESCR_CONTENT"
            end tell
EOT
            
        echo "Success! Video, text sidecar, and Finder UI metadata updated in $TARGET_DIR"
    else
        echo "Warning: Media files found, but metadata synchronization skipped."
    fi
else
    echo "Error: Download failed."
fi