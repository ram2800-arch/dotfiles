import os
import shutil
import argparse
import sys
from PIL import Image
import imagehash

def find_and_move_duplicates(scan_dir, dup_dir, hash_size=8, cutoff=4):
    """Finds perceptually similar duplicate images and moves them to a separate folder."""
    if not os.path.exists(dup_dir):
        os.makedirs(dup_dir)

    hashes = {}
    moved_count = 0

    print(f"Scanning {scan_dir} for duplicates...")
    
    for filename in sorted(os.listdir(scan_dir)):
        if not filename.lower().endswith(('.tif', '.tiff', '.jpg', '.jpeg')):
            continue
            
        filepath = os.path.join(scan_dir, filename)
        
        try:
            with Image.open(filepath) as img:
                img_hash = imagehash.phash(img, hash_size=hash_size)
                
                is_duplicate = False
                for existing_hash, original_file in hashes.items():
                    if img_hash - existing_hash <= cutoff:
                        is_duplicate = True
                        print(f"Match: {filename} looks like a duplicate of {original_file}")
                        break
                
                if is_duplicate:
                    dest_path = os.path.join(dup_dir, filename)
                    shutil.move(filepath, dest_path)
                    moved_count += 1
                else:
                    hashes[img_hash] = filename
                    
        except Exception as e:
            print(f"Error processing {filename}: {e}")

    print(f"\nDone. Moved {moved_count} duplicates to {dup_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Deduplicate scanned photos by year.")
    parser.add_argument("year", help="The 4-digit year folder to process (e.g., 1989)")
    args = parser.parse_args()
    
    base_path = "/Volumes/SandSSD01/Ram1TB/Scanned"
    target_directory = os.path.join(base_path, args.year)
    duplicates_directory = os.path.join(base_path, f"Duplicates_{args.year}")
    
    if not os.path.exists(target_directory):
        print(f"Error: The directory {target_directory} does not exist.")
        sys.exit(1)
        
    find_and_move_duplicates(target_directory, duplicates_directory)