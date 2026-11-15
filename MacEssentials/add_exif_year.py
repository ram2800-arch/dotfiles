import os
import subprocess
import re
import argparse
import sys

def add_year_metadata(target_dir):
    print(f"Scanning {target_dir} for files to update...")
    
    try:
        subprocess.run(["exiftool", "-ver"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: exiftool is not installed. Please run 'brew install exiftool'.")
        return

    processed_count = 0
    
    for filename in sorted(os.listdir(target_dir)):
        if not filename.lower().endswith(('.tif', '.tiff', '.jpg', '.jpeg')):
            continue
            
        match = re.match(r'^(\d{4})', filename)
        if match:
            year = match.group(1)
            filepath = os.path.join(target_dir, filename)
            
            date_string = f"{year}:01:01 12:00:00"
            
            cmd = [
                "exiftool", 
                "-overwrite_original",
                f"-DateTimeOriginal={date_string}",
                f"-CreateDate={date_string}",
                "-q",
                filepath
            ]
            
            subprocess.run(cmd)
            print(f"Updated {filename} -> {date_string}")
            processed_count += 1

    print(f"\nDone! Injected EXIF metadata into {processed_count} files.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Inject EXIF year metadata into scanned photos.")
    parser.add_argument("year", help="The 4-digit year folder to process (e.g., 1989)")
    args = parser.parse_args()
    
    target_directory = f"/Volumes/SandSSD01/Ram1TB/Scanned/{args.year}"
    
    if not os.path.exists(target_directory):
        print(f"Error: The directory {target_directory} does not exist.")
        sys.exit(1)
        
    add_year_metadata(target_directory)