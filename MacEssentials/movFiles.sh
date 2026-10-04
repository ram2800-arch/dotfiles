#!/bin/bash

SOURCE_DIR="/Users/ramr/ExportedLivePhotos"
DEST_DIR="/Users/ramr/excludedLiveMovs"

# Ensure destination exists
mkdir -p "$DEST_DIR"

# Loop through each .mov file found in the source
for file in "$SOURCE_DIR"/*.mov; do
    # Check if any .mov files actually exist to avoid the "no such file" error
    [ -e "$file" ] || continue

    echo "Processing: $(basename "$file")"

    # 1. Copy the file, preserving system metadata
    cp -p "$file" "$DEST_DIR/"

    # 2. Force the filesystem date to match ANY available internal date tag
    exiftool -P -overwrite_original \
             "-FileCreateDate<DateTimeOriginal" \
             "-FileCreateDate<MediaCreateDate" \
             "-FileCreateDate<ContentCreateDate" \
             "-FileModifyDate<DateTimeOriginal" \
             "-FileModifyDate<MediaCreateDate" \
             "-FileModifyDate<ContentCreateDate" \
             "$DEST_DIR/$(basename "$file")"
    # 3. Only remove the source file if the exit code (last command) was successful
    if [ $? -eq 0 ]; then
        rm "$file"
    else
        echo "Error processing $file - skipping deletion."
    fi
done

echo "Batch processing complete."
