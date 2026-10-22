#!/bin/bash

# Check if a folder was provided
if [ -z "$1" ]; then
    echo "Usage: rename_scans.sh /path/to/scan/folder"
    exit 1
fi

cd "$1" || exit

SERIAL=1

# Loop through all JPGs in the folder
for file in *.jpg *.jpeg *.JPG *.JPEG; do
    # Skip if the folder is empty
    [ -e "$file" ] || continue
    
    # Extract the Mac file creation time (Birth time) in YYYY-MM-DD-HHMM format
    FILE_DATE=$(stat -f "%SB" -t "%Y-%m-%d-%H%M" "$file")
    
    # Pad the serial number to 3 digits (001, 002, etc.)
    PADDED_SERIAL=$(printf "%03d" $SERIAL)
    
    # Construct the new name
    NEW_NAME="${FILE_DATE}-${PADDED_SERIAL}.JPG"
    
    # Rename the file
    mv "$file" "$NEW_NAME"
    echo "Renamed: $file  ->  $NEW_NAME"
    
    ((SERIAL++))
done

echo "All scans renamed successfully!"
