#!/usr/bin/env python3
import os
import sys
import csv
import re
import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser(description="Batch process Instagram Reels from Excel Export")
    parser.add_argument("-f", required=True, help="Path to the tab-separated export text file")
    args = parser.parse_args()

    input_file = args.f
    target_dir = os.path.expanduser("~/Downloads")

    if not os.path.exists(input_file):
        print(f"Error: Input file not found at {input_file}")
        sys.exit(1)

    print(f"Starting spreadsheet batch processing: {input_file}")
    print("--------------------------------------------------")

    count = 0

    with open(input_file, "r", encoding="utf-8", errors="replace") as f:
        reader = csv.reader(f, delimiter="\t")
        
        for row in reader:
            if not row or len(row) < 3:
                continue
                
            col1 = row[0].strip()
            col2 = row[1].strip()
            col3 = row[2].strip()
            
            if col2.upper() == "URL" or not col2:
                continue
                
            match = re.search(r"/(reel|p)/([A-Za-z0-9_-]{11})", col2)
            if not match:
                print(f" -> Skipping unrecognized URL layout: {col2}")
                continue
                
            reel_id = match.group(2)
            count += 1
            
            print(f"\n[Item #{count}] Processing Reel ID: {reel_id}")
            print(f"Group Prefix: {col1}")
            
            # 1. Download asset via yt-dlp using standard naming template
            output_template = os.path.join(target_dir, f"%(uploader)s | %(title)s_{reel_id}.%(ext)s")
            yt_cmd = [
                "yt-dlp",
                "--write-description",
                "-o", output_template,
                col2
            ]
            
            print(" -> Downloading asset via yt-dlp...")
            subprocess.run(yt_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            # 2. Track down the newly downloaded target items using the unique Reel ID
            find_cmd = f"ls {target_dir}/*_{reel_id}.* 2>/dev/null"
            try:
                found_files = subprocess.check_output(find_cmd, shell=True).decode("utf-8").strip().split('\n')
            except:
                print(f" -> Error: Missing downloaded assets for ID {reel_id}")
                continue
            
            # 3. Rename files to inject the custom "Prefix - " grouping format
            # and write out the clean .comments sidecar file
            for old_path in found_files:
                old_path = old_path.strip()
                if not old_path or not os.path.exists(old_path):
                    continue
                    
                file_dir, file_name = os.path.split(old_path)
                expected_start = f"{col1} - "
                
                if not file_name.startswith(expected_start):
                    new_name = f"{expected_start}{file_name}"
                    new_path = os.path.join(file_dir, new_name)
                    os.rename(old_path, new_path)
                    current_path = new_path
                else:
                    current_path = old_path
                
                # Once we identify the newly renamed MP4 path, generate its matching .comments sidecar
                if current_path.endswith(".mp4"):
                    # Swap out the .mp4 extension for .comments
                    comments_path = os.path.splitext(current_path)[0] + ".comments"
                    
                    # Write her clean spreadsheet formatting structure straight into the file
                    with open(comments_path, "w", encoding="utf-8") as cf:
                        cf.write(col3)
                        
            print(" -> Success: Group prefix applied and clean .comments sidecar generated.")

    print("--------------------------------------------------")
    print(f"Batch pipeline complete. Processed {count} items.")

if __name__ == "__main__":
    main()