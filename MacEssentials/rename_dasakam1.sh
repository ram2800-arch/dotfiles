#!/bin/zsh

# Move directly into your high-capacity media storage directory
cd "/Volumes/Ram4TB/Ram1TB/Music/SaraOk/099 Narayaneyam"

echo "--- DRY RUN START ---"

# Loop through all .m4a files matching the pattern
for file in Narayaneeyam\ -\ Dasakam\ *.m4a; do
    # Skip if the file doesn't actually exist
    [[ -e "$file" ]] || continue

    # Extract the number right after "Dasakam " using regex matching
    if [[ "$file" =~ "Dasakam ([0-9]+)" ]]; then
        num=$match[1]
        
        # Pad the number with leading zeros to guarantee it is 3 digits long
        padded_num=$(printf "%03d" $num)
        
        # Strips out " 18" (the space and the number) completely from the middle
        new_name="${file/ $num/}"
        
        # Prepend the 3-digit padded number to the very front
        final_name="${padded_num} ${new_name}"
        
        # 1. Prints your verification check line
        echo "#Renaming: '$file' -> '$final_name'"
        
        # 2. Prints the exact command that would be executed
        echo "mv \"$file\" \"$final_name\""
        
        # Print a tiny blank space to make reading the pairs easy on your eyes
        echo ""
    fi
done

echo "--- DRY RUN COMPLETE ---"
