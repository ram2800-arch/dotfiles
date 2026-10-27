find /Volumes/SandSSD01/Staging -type f | awk -F. '{if (NF>1) print tolower($NF); else print "no_extension"}' | sort | uniq -c | sort -nr
mkdir -p /Volumes/SandSSD01/Staging_Other

find /Volumes/SandSSD01/Staging -type f \
  ! -iname "*.jpg" \
  ! -iname "*.jpeg" \
  ! -iname "*.mov" \
  ! -iname "*.heic" \
  ! -iname "*.mp4" \
  ! -iname "*.png" \
  -exec mv {} /Volumes/SandSSD01/Staging_Other/ \;


find /Volumes/SandSSD01/RamSegate-backup -iname "*.ithmb" -delete
