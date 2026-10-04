#!/bin/zsh

# Initialize variable
INPUT_FILE=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INNER_SCRIPT="$SCRIPT_DIR/getInstareel.sh"

# Parse command-line options using lowercase f
while getopts "f:" opt; do
  case ${opt} in
    f )
      INPUT_FILE=$OPTARG
      ;;
    \? )
      echo "Usage: ./batchInstareel.sh -f <text_file>"
      return 1
      ;;
  esac
done

# Validate that a file was specified
if [ -z "$INPUT_FILE" ]; then
    echo "Error: Missing input file parameter."
    echo "Usage: ./batchInstareel.sh -f links.txt"
    return 1
fi

# Validate that the file actually exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found -> $INPUT_FILE"
    return 1
fi

# Validate that the core download script exists in the same folder
if [ ! -f "$INNER_SCRIPT" ]; then
    echo "Error: Core download script missing -> $INNER_SCRIPT"
    return 1
fi

echo "Starting batch processing for file: $INPUT_FILE"
echo "--------------------------------------------------"

# Initialize line counter
COUNT=0

# Read the file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Trim leading/trailing whitespace
    line=$(echo "$line" | xargs)
    
    # Skip completely empty lines or lines starting with a comment symbol (#)
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi
    
    # Smart ID Parsing Logic:
    # If it's a full URL (e.g., https://www.instagram.com/reel/DTSmjS0Evgp/), 
    # extract just the 11-character alphanumeric token after "/reel/".
    # Otherwise, assume the line is already a raw Reel ID.
    if [[ "$line" =~ "/reel/([A-Za-z0-9_-]{11})" ]]; then
        REEL_ID="${match[1]}"
    else
        REEL_ID="$line"
    fi
    
    # Extra validation to ensure the parsed ID format is exactly 11 characters
    if [[ ! "$REEL_ID" =~ ^[A-Za-z0-9_-]{11}$ ]]; then
        echo "Skipping invalid entry: $line"
        continue
    fi
    
    ((COUNT++))
    echo "\n[Batch Item #$COUNT] Processing ID: $REEL_ID"
    
    # Execute your existing getInstareel.sh as a clean standalone subshell execution
    "$INNER_SCRIPT" -i "$REEL_ID"
    
done < "$INPUT_FILE"

echo "--------------------------------------------------"
echo "Batch process finalized. Total items processed: $COUNT"