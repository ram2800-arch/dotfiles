#!/usr/bin/env python3
import os
import hashlib
import shutil
import argparse

def get_file_hash(filepath, chunk_size=8192):
    hasher = hashlib.md5()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(chunk_size), b''):
            hasher.update(chunk)
    return hasher.hexdigest()

def main():
    parser = argparse.ArgumentParser(description="Extract unique files from backup to staging.")
    parser.add_argument("--master", required=True, help="Backup folder (e.g., RamSegate-backup)")
    parser.add_argument("--memories", required=True, help="Curated memories folder")
    parser.add_argument("--staging", required=True, help="Output folder for missing files")
    args = parser.parse_args()

    master_dir = args.master
    memories_dir = args.memories
    staging_dir = args.staging

    if not os.path.exists(staging_dir):
        os.makedirs(staging_dir)

    print(f"Step 1: Cataloging existing files in {memories_dir}...")
    existing_hashes = set()
    for root, _, files in os.walk(memories_dir):
        for filename in files:
            if filename.startswith('.'): continue
            filepath = os.path.join(root, filename)
            try:
                existing_hashes.add(get_file_hash(filepath))
            except Exception as e:
                pass
    
    print(f"Cataloged {len(existing_hashes)} unique files in memories.")

    print(f"\nStep 2: Scanning master backup for missing files...")
    copied_count = 0
    for root, _, files in os.walk(master_dir):
        for filename in files:
            if filename.startswith('.'): continue
            filepath = os.path.join(root, filename)
            
            try:
                file_hash = get_file_hash(filepath)
                if file_hash not in existing_hashes:
                    # Found a missing file!
                    dest_path = os.path.join(staging_dir, filename)
                    
                    # Handle filename collisions in staging (e.g., two files named IMG_001.JPG)
                    counter = 1
                    name, ext = os.path.splitext(filename)
                    while os.path.exists(dest_path):
                        dest_path = os.path.join(staging_dir, f"{name}_{counter}{ext}")
                        counter += 1
                        
                    # Use copy2 to preserve the original creation/modification metadata
                    shutil.copy2(filepath, dest_path)
                    
                    # Add to our known hashes so we don't pull duplicates of the same missing file
                    existing_hashes.add(file_hash) 
                    copied_count += 1
                    print(f"Extracted: {filename}")
            except Exception as e:
                pass

    print(f"\nDone! Extracted {copied_count} missing files to {staging_dir}")

if __name__ == "__main__":
    main()
