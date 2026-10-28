#!/usr/bin/env python3
import os
import hashlib
import argparse

def get_file_hash(filepath, chunk_size=8192):
    hasher = hashlib.md5()
    try:
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(chunk_size), b''):
                hasher.update(chunk)
        return hasher.hexdigest()
    except Exception:
        return None

def build_hash_database(directories):
    print(f"Building hash database from target folders...")
    known_hashes = set()
    for d in directories:
        if not os.path.exists(d): continue
        for root, _, files in os.walk(d):
            for filename in files:
                if filename.startswith('.'): continue
                filepath = os.path.join(root, filename)
                file_hash = get_file_hash(filepath)
                if file_hash:
                    known_hashes.add(file_hash)
    return known_hashes

def main():
    parser = argparse.ArgumentParser(description="Check folder for duplicates against master directories.")
    parser.add_argument("--check", required=True, help="Folder to check (e.g., work folder)")
    parser.add_argument("--against", nargs='+', required=True, help="Master folders to check against")
    args = parser.parse_args()

    known_hashes = build_hash_database(args.against)
    print(f"Cataloged {len(known_hashes)} unique files in master folders.\n")
    
    print(f"Scanning {args.check}...")
    duplicate_count = 0
    unique_count = 0
    
    for root, _, files in os.walk(args.check):
        for filename in files:
            if filename.startswith('.'): continue
            filepath = os.path.join(root, filename)
            
            file_hash = get_file_hash(filepath)
            if file_hash in known_hashes:
                duplicate_count += 1
            else:
                unique_count += 1
                
    print("\n--- Results ---")
    print(f"Duplicates already in master: {duplicate_count}")
    print(f"New/Unique files found:       {unique_count}")

if __name__ == "__main__":
    main()
