# MacEssentials Media Management Suite

A custom collection of Python utilities designed to deduplicate, analyze, and standardize massive personal media archives safely. These scripts are maintained in `~/dotfiles/Macessentials` and symlinked to `~/.local/bin` for global execution.

### Storage Analysis & Validation
*   **`dir_sizes.py`**
    *   **Purpose:** Directory size analysis.
    *   **Function:** Scans a target directory, calculates the deep total size of every immediate subdirectory (and root-level loose files), and outputs a clean table sorted from largest to smallest.
*   **`ext_stats.py`**
    *   **Purpose:** File extension space analysis.
    *   **Function:** Scans any directory and generates a sorted, human-readable table of file extensions, exact file counts, and total disk space consumed. Used to quickly identify and purge hidden system junk (e.g., `.ithmb`, `.js`, `.css`).
*   **`year_stats.py`**
    *   **Purpose:** Chronological archive analysis.
    *   **Function:** Parses standardized filenames to generate a chronological breakdown of your media archive. Includes a `--group` parameter to instantly drill down statistics by `year`, `month`, or `day`.
*   **`check_folder.py`**
    *   **Purpose:** Multi-directory duplicate validation.
    *   **Function:** Hashes files in an unsorted target directory (like a `work` folder) and compares them against multiple master directories simultaneously. Outputs an exact count of unique files versus files that already exist in the master archives.

### File Deduplication & Extraction
*   **`smart_compare.py`**
    *   **Purpose:** Hash-based file deduplication.
    *   **Function:** Scans a target directory against a master backup archive. Instead of deleting duplicates, it safely isolates redundant files into a dedicated `Duplicates_Found` folder to free up storage space.
*   **`extract_missing.py`**
    *   **Purpose:** Safe delta extraction.
    *   **Function:** Scans a massive backup archive, calculates file hashes, and compares them against a curated master folder (e.g., `memories`). Safely *copies* any genuinely missing files into a `Staging` folder without modifying the original backup.
*   **`compare.py`**
    *   **Purpose:** Legacy file comparison.
    *   **Function:** Standard utility for basic directory and file comparison operations.

### Metadata & Renaming
*   **`format_memories.py`**
    *   **Purpose:** EXIF-based file standardization.
    *   **Function:** Reads embedded `DateTimeOriginal` EXIF metadata from media files and standardizes the filenames to a strictly structured format (`Prefix-YYYY-MM-DD-HHMI-XXX.ext`). 
    *   **Dependencies:** Requires the `Pillow` library (`pip3 install --user --break-system-packages pillow`).
