#!/bin/bash
set -e

# 1. Synchronize username from mahesh to ram2800 (Run as root/sudo)
if id "mahesh" &>/dev/null && ! id "ram2800" &>/dev/null; then
    echo "Renaming user mahesh to ram2800..."
    pkill -u mahesh || true
    usermod -l ram2800 mahesh
    groupmod -n ram2800 mahesh 2>/dev/null || true
    usermod -d /home/ram2800 -m ram2800
    echo "User renamed successfully."
fi

# 2. Create the docagent system user
if ! id "docagent" &>/dev/null; then
    echo "Creating docagent system user..."
    sudo useradd -r -s /bin/false -m -d /var/lib/docagent docagent
fi

# 3. Add docagent to docker group
sudo usermod -aG docker docagent

# 4. Set up shared directories for Docker, Jellyfin, and Tailscale
sudo mkdir -p /var/lib/docagent/docker /var/lib/docagent/jellyfin
sudo chown -R docagent:docagent /var/lib/docagent
sudo chmod -R 775 /var/lib/docagent

# 5. Ensure Tailscale runs as a system daemon accessible globally
sudo systemctl enable --now tailscaled

echo "Migration setup script completed successfully on $(hostname)."
