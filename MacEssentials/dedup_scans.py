import os
import shutil
from PIL import Image
import imagehash

def find_and_move_duplicates(scan_dir, dup_dir, hash_size=8, cutoff=4):
    """
    Finds perceptually similar duplicate images and moves them to a separate folder.
    """
    if not os.path.exists(dup_dir):
        os.makedirs(dup_dir)

    hashes = {}
    moved_count = 0

    print(f"Scanning {scan_dir} for duplicates...")
    
    # Process only TIFF and JPG files
    for filename in sorted(os.listdir(scan_dir)):
        if not filename.lower().endswith(('.tif', '.tiff', '.jpg', '.jpeg')):
            continue
            
        filepath = os.path.join(scan_dir, filename)
        
        try:
            with Image.open(filepath) as img:
                # phash calculates a perceptual signature of the image
                img_hash = imagehash.phash(img, hash_size=hash_size)
                
                is_duplicate = False
                # Compare current hash against all previously seen hashes
                for existing_hash, original_file in hashes.items():
                    # The 'cutoff' determines how aggressive the matching is. 
                    # A difference of <= 4 means the images are virtually identical.
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
    # Pre-configured based on your active working directory
    target_directory = "/Volumes/SandSSD01/Ram1TB/Scanned/1987"
    duplicates_directory = "/Volumes/SandSSD01/Ram1TB/Scanned/Duplicates_1987"
    
    find_and_move_duplicates(target_directory, duplicates_directory)
