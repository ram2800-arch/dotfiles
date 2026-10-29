{
  echo "=== APT Packages (Manual) ==="
  apt-mark showmanual
  echo -e "\n=== Snap Packages ==="
  snap list
  echo -e "\n=== Homebrew Packages ==="
  brew leaves
} > ~/installed_apps.txt
