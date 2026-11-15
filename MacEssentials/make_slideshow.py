import os
import subprocess
import argparse
import sys

def create_slideshow(year, duration):
    base_path = "/Volumes/SandSSD01/Ram1TB/Scanned"
    target_dir = os.path.join(base_path, year)
    output_file = os.path.join(base_path, f"Slideshow_{year}.mp4")
    list_file = os.path.join(base_path, f"list_{year}.txt")

    # Verify directory and ffmpeg installation
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        sys.exit(1)
        
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: FFmpeg is not installed. Run 'brew install ffmpeg'.")
        sys.exit(1)

    images = [f for f in sorted(os.listdir(target_dir)) if f.lower().endswith(('.tif', '.tiff', '.jpg', '.jpeg'))]
    
    if not images:
        print(f"No images found in {target_dir}.")
        sys.exit(1)

    print(f"Found {len(images)} images in {year}. Generating {duration}-second slides...")

    # Create a staging file for FFmpeg's concat demuxer
    with open(list_file, 'w') as f:
        for img in images:
            f.write(f"file '{os.path.join(target_dir, img)}'\n")
            f.write(f"duration {duration}\n")
        # FFmpeg requires the last file to be specified again without a duration
        f.write(f"file '{os.path.join(target_dir, images[-1])}'\n")

    # FFmpeg command optimized for YouTube (1080p, libx264, standard color space)
    cmd = [
        "ffmpeg",
        "-y",               # Overwrite existing output files
        "-f", "concat",     # Use the concat demuxer
        "-safe", "0",       # Allow absolute file paths
        "-i", list_file,
        "-c:v", "libx264",  # YouTube's preferred video codec
        "-pix_fmt", "yuv420p", # Ensures web and mobile playback compatibility
        "-r", "30",         # 30 Frames Per Second
        # Scale filter: fits image inside 1920x1080 without stretching, pads remaining space with black
        "-vf", "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2",
        output_file
    ]

    try:
        subprocess.run(cmd, check=True)
        print(f"\nSuccess! Slideshow saved to: {output_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error generating video: {e}")
    finally:
        # Clean up the temporary text file
        if os.path.exists(list_file):
            os.remove(list_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create a YouTube-ready MP4 slideshow from a folder of images.")
    parser.add_argument("year", help="The 4-digit year folder to process (e.g., 1992)")
    parser.add_argument("--duration", type=int, default=4, help="Seconds to display each photo (default: 4)")
    args = parser.parse_args()
    
    create_slideshow(args.year, args.duration)
