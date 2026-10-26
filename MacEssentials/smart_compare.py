#!/usr/bin/env python3
import os
import hashlib
import shutil
import argparse

def get_file_hash(filepath):
    hasher = hashlib.md5()
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(8192):
                hasher.update(chunk)
        return hasher.hexdigest()
    except Exception:
        return None

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--master", required=True, help="Directory of files to KEEP")
    parser.add_argument("--target", required=True, help="Directory to scan and REMOVE duplicates from")
    parser.add_argument("--exclude", help="Directory to IGNORE (e.g., memories folder)")
    args = parser.parse_args()

    master_dir = os.path.abspath(args.master)
    target_dir = os.path.abspath(args.target)
    exclude_dir = os.path.abspath(args.exclude) if args.exclude else None

    # Create a Duplicates folder at the root of the target's drive
    drive_root = target_dir.split(os.sep)[:3] # e.g., ['/', 'Volumes', 'SandSSD01']
    dup_folder = os.path.join(os.sep.join(drive_root), "Duplicates_Found")
    os.makedirs(dup_folder, exist_ok=True)

    print(f"1. Scanning Master Archive: {master_dir}")
    master_hashes = set()
    for root, _, files in os.walk(master_dir):
        for file in files:
            if file.startswith('.'): continue
            filepath = os.path.join(root, file)
            file_hash = get_file_hash(filepath)
            if file_hash:
                master_hashes.add(file_hash)
    print(f"   Cataloged {len(master_hashes)} unique master files.")

    print(f"2. Scanning Target for duplicates: {target_dir}")
    if exclude_dir:
        print(f"   Excluding: {exclude_dir}")
        
    dup_count = 0
    for root, dirs, files in os.walk(target_dir):
        # Skip the exclude directory
        if exclude_dir and root.startswith(exclude_dir):
            continue
            
        for file in files:
            if file.startswith('.'): continue
            filepath = os.path.join(root, file)
            
            file_hash = get_file_hash(filepath)
            if file_hash in master_hashes:
                # Move duplicate
                try:
                    shutil.move(filepath, os.path.join(dup_folder, file))
                    dup_count += 1
                except Exception:
                    pass # Ignore if file with same name already exists in Duplicates_Found

    print(f"\nDone! Found and moved {dup_count} duplicates to {dup_folder}")

if __name__ == "__main__":
    main()
