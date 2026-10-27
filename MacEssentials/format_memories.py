#!/usr/bin/env python3
import os
import argparse
from datetime import datetime
from PIL import Image, ExifTags

def get_capture_time(filepath):
    # 1. Try to extract the embedded EXIF DateTimeOriginal
    try:
        with Image.open(filepath) as img:
            # Some EXIF data is in getexif(), some in _getexif()
            exif = img._getexif() or img.getexif()
            if exif:
                for tag_id, value in exif.items():
                    tag_name = ExifTags.TAGS.get(tag_id, tag_id)
                    if tag_name == 'DateTimeOriginal':
                        # EXIF format is typically 'YYYY:MM:DD HH:MM:SS'
                        return datetime.strptime(str(value).strip(), '%Y:%m:%d %H:%M:%S')
    except Exception:
        pass # Not an image, or no EXIF data found

    # 2. Fallback to file system modification time for videos/PNGs
    mtime = os.path.getmtime(filepath)
    return datetime.fromtimestamp(mtime)

def rename_files(target_dir, prefix):
    print(f"Scanning {target_dir} for EXIF capture dates...")
    
    for root, _, files in os.walk(target_dir):
        files.sort() 
        serial_counter = 1
        
        for filename in files:
            if filename.startswith('.'): continue
            
            filepath = os.path.join(root, filename)
            ext = os.path.splitext(filename)[1].lower()
            
            try:
                # Get the true capture date
                dt = get_capture_time(filepath)
                
                # Format: PREFIX-YYYY-MM-DD-HHMM-XXX.ext
                new_name = f"{prefix}-{dt.strftime('%Y-%m-%d-%H%M')}-{serial_counter:03d}{ext}"
                new_filepath = os.path.join(root, new_name)
                
                if filepath != new_filepath and not os.path.exists(new_filepath):
                    os.rename(filepath, new_filepath)
                    print(f"Renamed: {filename} -> {new_name}")
                    serial_counter += 1
                    
            except Exception as e:
                print(f"Error processing {filename}: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dir", required=True, help="Directory containing files to rename")
    parser.add_argument("--prefix", required=True, help="Prefix to use (e.g., Ram)")
    args = parser.parse_args()
    
    rename_files(args.dir, args.prefix)
    print("\nRenaming complete!")
