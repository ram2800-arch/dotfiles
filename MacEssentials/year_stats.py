#!/usr/bin/env python3
import os
import argparse
from collections import defaultdict

def format_size(size):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024:
            return f"{size:7.2f} {unit}"
        size /= 1024

def main():
    parser = argparse.ArgumentParser(description="Get stats for renamed files.")
    parser.add_argument("dir", help="Target directory")
    parser.add_argument("--group", choices=['year', 'month', 'day'], default='year', 
                        help="Level of grouping (year, month, or day)")
    args = parser.parse_args()

    stats = defaultdict(lambda: {'count': 0, 'size': 0})

    for root, _, files in os.walk(args.dir):
        for file in files:
            if file.startswith('.'): continue
            
            parts = file.split('-')
            # Check if it matches our Prefix-YYYY-MM-DD format
            if len(parts) >= 2 and parts[1].isdigit() and len(parts[1]) == 4:
                prefix = parts[0]
                year = parts[1]
                
                if args.group == 'year':
                    group_key = f"{prefix}-{year}"
                elif args.group == 'month' and len(parts) >= 3:
                    month = parts[2]
                    group_key = f"{prefix}-{year}-{month}"
                elif args.group == 'day' and len(parts) >= 4:
                    month = parts[2]
                    day = parts[3]
                    group_key = f"{prefix}-{year}-{month}-{day}"
                else:
                    group_key = f"{prefix}-{year}" # Fallback if name is incomplete
            else:
                group_key = "Other/Unmatched"
                
            filepath = os.path.join(root, file)
            try:
                size = os.path.getsize(filepath)
                stats[group_key]['count'] += 1
                stats[group_key]['size'] += size
            except OSError:
                pass

    print(f"\n{'Grouping':<25} | {'Count':<8} | {'Total Size'}")
    print("-" * 55)
    
    for key in sorted(stats.keys()):
        count = stats[key]['count']
        size = stats[key]['size']
        print(f"{key:<25} | {count:<8} | {format_size(size)}")
    print("-" * 55)

if __name__ == "__main__":
    main()
