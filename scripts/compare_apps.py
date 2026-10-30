import sys

def get_packages(filename):
    pkgs = {'apt': set(), 'snap': set(), 'brew': set()}
    current = None
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line: continue
            if line.startswith('==='):
                if 'APT' in line: current = 'apt'
                elif 'Snap' in line: current = 'snap'
                elif 'Homebrew' in line: current = 'brew'
                continue
            if current == 'apt':
                pkgs['apt'].add(line)
            elif current == 'snap':
                if line.startswith('Name') or line.startswith('No snap'): continue
                pkgs['snap'].add(line.split()[0])
            elif current == 'brew':
                pkgs['brew'].add(line.split()[0])
    return pkgs

ubu2 = get_packages("ubu2_installed_apps.txt.")
ubu1 = get_packages("ubu1_installed_apps.txt")

print("#!/bin/bash\n")

missing_apt = sorted(ubu2['apt'] - ubu1['apt'])
if missing_apt:
    print("echo '--- Installing missing APT packages ---'")
    print(f"sudo apt update && sudo apt install -y {' '.join(missing_apt)}\n")

missing_snap = sorted(ubu2['snap'] - ubu1['snap'])
if missing_snap:
    print("echo '--- Installing missing Snap packages ---'")
    for pkg in missing_snap:
        print(f"sudo snap install {pkg}  # Note: Add --classic if an app requires it")
    print("")

missing_brew = sorted(ubu2['brew'] - ubu1['brew'])
if missing_brew:
    print("echo '--- Installing missing Homebrew packages ---'")
    print(f"brew install {' '.join(missing_brew)}\n")
