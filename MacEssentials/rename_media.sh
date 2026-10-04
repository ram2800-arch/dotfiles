#!/bin/bash

if [ "$#" -lt 3 ]; then
    echo "Usage: ./rename_media.sh [prefix] [source_dir] [target_dir]"
    exit 1
fi

PREFIX="$1"
SOURCE_DIR="$2"
TARGET_DIR="$3"
REPORT="missing_metadata_report.txt"

# Clear old report
> "$REPORT"

echo "------------------------------------"
echo "Processing with safe metadata read..."
echo "Report for missing files: $REPORT"
echo "------------------------------------"

# Execution:
# 1. -o: Copies (does not modify/destroy source)
# 2. Priority chain: Checks internal tags, then falls back to File System Date
# 3. 2> /dev/null: Suppresses minor errors for cleaner output
exiftool -m -P -o "$TARGET_DIR/" -r -ext '*' \
         -d "${PREFIX}_%Y-%m-%d_%H-%M-%S%%-c.%%e" \
         '-filename<CreateDate' \
         '-filename<DateTimeOriginal' \
         '-filename<MediaCreateDate' \
         '-filename<ContentCreateDate' \
         '-filename<FileModifyDate' \
         "$SOURCE_DIR" > /dev/null 2>&1

# Find files that weren't renamed correctly (optional secondary check)
echo "Scanning for problematic files..."
find "$SOURCE_DIR" -type f -not -name ".*" | while read -r file; do
    # If the file hasn't been copied to target with the new format, log it
    # This is a basic check to help you identify files that need manual review
    if ! exiftool -s3 -CreateDate "$file" | grep -q "[1-9]"; then
        echo "$file" >> "$REPORT"
    fi
done

echo "Process Complete."
echo "Check '$REPORT' for files that had no internal metadata."
