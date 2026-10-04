#!/bin/zsh

# Move directly into your target directory
cd "/Volumes/Ram4TB/Ram1TB/Music/SaraOk/099 - Narayaneyam-1"

echo "#--- DRY RUN START (PATTERN 2 - FLEXIBLE SPACES) ---"

# Loop through files using a wildcard to catch single or double spaces
for file in Narayaneeya\ Parayanam*Dasakam\ *.m4a; do
    # Skip if the file doesn't actually exist
    [[ -e "$file" ]] || continue

    # The [[:space:]]+ tells regex to match 1 OR MORE spaces flawlessly
    if [[ "$file" =~ "(Narayaneeya Parayanam)[[:space:]]+(Dasakam)[[:space:]]+([0-9]+).+(\[[^]]+\])" ]]; then
        
        p_text=$match[1]
        d_text=$match[2]
        num=$match[3]
        yt_id=$match[4]
        
        # Pad the number to 3 digits (e.g., 13 -> 013)
        padded_num=$(printf "%03d" $num)
        
        # Assemble the final name with exact single spacing
        final_name="${padded_num} ${p_text} ${d_text} ${yt_id}.m4a"
        
        # 1. Prints your verification check line
        echo "#Renaming: '$file' -> '$final_name'"
        
        # 2. Prints the exact command that would be executed
        echo "mv \"$file\" \"$final_name\""
        
        # Print a tiny blank space to make reading the pairs easy on your eyes
        echo ""
    fi
done

echo "#--- DRY RUN COMPLETE ---"
