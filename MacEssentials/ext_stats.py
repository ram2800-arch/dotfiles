#!/usr/bin/env python3
import os
import sys
from collections import defaultdict

def format_size(size):
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024:
            return f"{size:7.2f} {unit}"
        size /= 1024

if len(sys.argv) < 2:
    print("Usage: ext_stats.py <directory>")
    sys.exit(1)

target_dir = sys.argv[1]
ext_counts = defaultdict(int)
ext_sizes = defaultdict(int)

for root, _, files in os.walk(target_dir):
    for file in files:
        if file.startswith('.'): continue
        
        ext = os.path.splitext(file)[1].lower().replace('.', '')
        if not ext:
            ext = 'no_extension'
            
        filepath = os.path.join(root, file)
        try:
            size = os.path.getsize(filepath)
            ext_counts[ext] += 1
            ext_sizes[ext] += size
        except OSError:
            pass

print(f"\n{'Extension':<15} | {'Count':<8} | {'Total Size'}")
print("-" * 45)

# Sort by total size (descending)
for ext, size in sorted(ext_sizes.items(), key=lambda item: item[1], reverse=True):
    print(f"{ext:<15} | {ext_counts[ext]:<8} | {format_size(size)}")
print("-" * 45)
