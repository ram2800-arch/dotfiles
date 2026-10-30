#!/usr/bin/env python3
import os
import hashlib
import shutil

# Exact paths based on your Mac Finder
#master_folder = '/Volumes/Ram4TB/Ram1TB'
#target_folder = '/Volumes/Ram4TB/Allon1Tb'
#duplicates_folder = '/Volumes/Ram4TB/Duplicates_Found'
import sys
master_folder = sys.argv[1]
target_folder = sys.argv[2]
duplicates_folder = sys.argv[3]
def get_file_hash(filepath):
    """Generates a digital fingerprint for the file content."""
    h = hashlib.md5()
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(8192):
                h.update(chunk)
        return h.hexdigest()
    except Exception:
        return None

print(f"1. Scanning Master Archive ({master_folder})...")
master_hashes = set()
for root, dirs, files in os.walk(master_folder):
    for file in files:
        # Skip hidden Mac system files
        if file.startswith('.'): continue
        
        filepath = os.path.join(root, file)
        file_hash = get_file_hash(filepath)
        if file_hash:
            master_hashes.add(file_hash)

print(f"Cataloged {len(master_hashes)} unique master files.")
print(f"2. Scanning {target_folder} for duplicates...")

# Create the safety folder for duplicates
if not os.path.exists(duplicates_folder):
    os.makedirs(duplicates_folder)

dupe_count = 0
for root, dirs, files in os.walk(target_folder):
    for file in files:
        if file.startswith('.'): continue
            
        filepath = os.path.join(root, file)
        file_hash = get_file_hash(filepath)
        
        if file_hash and file_hash in master_hashes:
            dupe_count += 1
            dest_path = os.path.join(duplicates_folder, file)
            
            # Prevent overwriting if two dupes have the exact same name
            base, ext = os.path.splitext(file)
            counter = 1
            while os.path.exists(dest_path):
                dest_path = os.path.join(duplicates_folder, f"{base}_{counter}{ext}")
                counter += 1
                
            shutil.move(filepath, dest_path)

print(f"\nDone! Found and moved {dupe_count} duplicates to the 'Duplicates_Found' folder.")
