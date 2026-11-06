import os
import subprocess
import re

def add_year_metadata(target_dir):
    print(f"Scanning {target_dir} for files to update...")
    
    # Verify exiftool is installed
    try:
        subprocess.run(["exiftool", "-ver"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: exiftool is not installed. Please run 'brew install exiftool'.")
        return

    processed_count = 0
    
    for filename in sorted(os.listdir(target_dir)):
        if not filename.lower().endswith(('.tif', '.tiff', '.jpg', '.jpeg')):
            continue
            
        # Extract the 4-digit year from the start of the filename (e.g., "1987")
        match = re.match(r'^(\d{4})', filename)
        if match:
            year = match.group(1)
            filepath = os.path.join(target_dir, filename)
            
            # Format: YYYY:MM:DD HH:MM:SS (Defaulting to Jan 1st, 12:00 PM)
            date_string = f"{year}:01:01 12:00:00"
            
            # -overwrite_original prevents exiftool from creating backup copies of every 30MB TIFF
            # -q suppresses standard output to keep the terminal clean
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
    # Adjust this to point to your deduplicated/final folder
    directory = "/Volumes/SandSSD01/Ram1TB/Scanned/1987"
    add_year_metadata(directory)
