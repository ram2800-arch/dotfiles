#!/usr/bin/env python3
import os
import argparse

def format_size(size):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024:
            return f"{size:7.2f} {unit}"
        size /= 1024

def get_dir_size(path):
    total_size = 0
    for root, _, files in os.walk(path):
        for file in files:
            filepath = os.path.join(root, file)
            # Skip symlinks to avoid double-counting or loops
            if not os.path.islink(filepath):
                try:
                    total_size += os.path.getsize(filepath)
                except OSError:
                    pass
    return total_size

def main():
    parser = argparse.ArgumentParser(description="Get total sizes of immediate subdirectories.")
    parser.add_argument("dir", help="Target directory to scan")
    args = parser.parse_args()

    if not os.path.isdir(args.dir):
        print(f"Error: '{args.dir}' is not a valid directory.")
        return

    dir_stats = []
    root_files_size = 0

    print(f"Scanning '{args.dir}'...\n")

    for item in os.listdir(args.dir):
        item_path = os.path.join(args.dir, item)
        if os.path.isdir(item_path):
            size = get_dir_size(item_path)
            dir_stats.append((item, size))
        elif os.path.isfile(item_path) and not os.path.islink(item_path):
            try:
                root_files_size += os.path.getsize(item_path)
            except OSError:
                pass

    print(f"{'Directory Name':<35} | {'Total Size'}")
    print("-" * 50)
    
    # Sort by size (descending)
    for name, size in sorted(dir_stats, key=lambda x: x[1], reverse=True):
        print(f"{name:<35} | {format_size(size)}")
        
    if root_files_size > 0:
        print("-" * 50)
        print(f"{'[Loose Files in Root]':<35} | {format_size(root_files_size)}")
    print("-" * 50)

if __name__ == "__main__":
    main()
