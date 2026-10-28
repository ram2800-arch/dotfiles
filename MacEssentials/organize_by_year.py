#!/usr/bin/env python3
import os
import shutil
import argparse
import re

def organize_files(source_dir, dest_dir):
    print(f"Organizing files from '{source_dir}' to '{dest_dir}' by year...\n")
    
    if not os.path.exists(dest_dir):
        print(f"Error: Destination '{dest_dir}' does not exist.")
        return

    moved_count = 0
    skipped_count = 0

    # Looks for a word prefix followed by a hyphen and a 4-digit year (e.g., Ram-2018-..., Work-2019-...)
    pattern = re.compile(r'^[a-zA-Z]+-(\d{4})-')

    for filename in os.listdir(source_dir):
        if filename.startswith('.'): continue
        
        source_path = os.path.join(source_dir, filename)
        if not os.path.isfile(source_path): continue

        match = pattern.match(filename)
        if match:
            year = match.group(1)
            year_dir = os.path.join(dest_dir, year)
            
            # Create the year directory if it doesn't exist
            if not os.path.exists(year_dir):
                os.makedirs(year_dir)
                print(f"Created new folder: {year_dir}")
            
            dest_path = os.path.join(year_dir, filename)
            
            # Move the file safely
            if not os.path.exists(dest_path):
                shutil.move(source_path, dest_path)
                moved_count += 1
            else:
                print(f"Skip (Already exists): {filename}")
                skipped_count += 1
        else:
            skipped_count += 1
            
    print(f"\n--- Organizing Complete ---")
    print(f"Successfully moved: {moved_count} files")
    print(f"Skipped (format mismatch/exists): {skipped_count} files")

def main():
    parser = argparse.ArgumentParser(description="Organize prefixed files into year directories.")
    parser.add_argument("--source", required=True, help="Source directory (e.g., Staging)")
    parser.add_argument("--dest", required=True, help="Destination master directory (e.g., memories)")
    args = parser.parse_args()

    organize_files(args.source, args.dest)

if __name__ == "__main__":
    main()
