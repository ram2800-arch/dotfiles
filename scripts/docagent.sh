
#Step 1: Create the system user
sudo useradd -r -s /bin/false -m -d /var/lib/docagent docagent
sudo usermod -aG docker docagent

#Step 2: Establish centralized directories

sudo mkdir -p /opt/docagent/bin
sudo mkdir -p /opt/docagent/jellyfin
sudo mkdir -p /opt/docagent/docker

#Step 3: Assign user access permissions
sudo chown -R ram2800:ram2800 /opt/docagent
sudo chmod -R 775 /opt/docagent

#Step 4: Restart system daemons

sudo systemctl start docker docker.socket containerd tailscaled

#Migrate your existing Docker configurations and Jellyfin files from your home directory to the new centralized /opt/docagent

sudo cp -r ~/docker/* /opt/docagent/docker/ 2>/dev/null || true
sudo cp -r ~/jellyfin/* /opt/docagent/jellyfin/ 2>/dev/null || true
#
#Verification: Run ls -la /opt/docagent/docker /opt/docagent/jellyfin to confirm files were copied successfully.

#Update volume paths inside your compose files (such as compose.wireguard.yaml) to point to /opt/docagent instead of your home directory:

cd /opt/docagent/docker
sudo sed -i 's|/home/ram2800|/opt/docagent|g' *.yaml *.yml 2>/dev/null || true
sudo sed -i 's|/home/mahesh|/opt/docagent|g' *.yaml *.yml 2>/dev/null || true

grep -rn '/opt/docagent' *.yaml

sed -i 's|export DOCKER_PATH=.*|export DOCKER_PATH="/opt/docagent/docker/household-exit-node"|' ~/.zshrc
source ~/.zshrc

#Verification: Run grep -rn "/opt/docagent" /opt/docagent/docker/ to verify that volume mounts have been correctly updated.



#Define the centralized DOCKER_PATH environment variable near the top of your configuration file so all compose aliases point correctly to /opt/docagent/docker

export DOCKER_PATH="/opt/docagent/docker"

alias getmusic="/opt/docagent/bin/getmusic.sh"
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="/opt/docagent/docker:/opt/docagent/docker/household-exit-node:$PATH"

#Update the path references in docker.sh to point to the new centralized /opt/docagent/docker directory instead of your home path.
#Replace the top variable definitions and paths in your editor with the updated locations:
Bash
COMPOSE_FILE="/opt/docagent/docker/household-exit-node/compose.wireguard.yaml"
VM_NAME="household-exit-node"
#Update all occurrences of $HOME/docker inside the script commands to use /opt/docagent/docker:
#Change --env-file "$HOME/docker/household-exit-node/.env" to --env-file "/opt/docagent/docker/household-exit-node/.env" across the start, stop, restart, and status blocks.

sudo systemctl start docker docker.socket containerd
sudo systemctl enable docker docker.socket containerd

sudo usermod -aG docker ram2800

sudo chown -R ram2800:ram2800 /opt/docagent/jellyfin
sudo chmod -R 775 /opt/docagent/jellyfin

curl -I http://127.0.0.1:8096/
sudo systemctl enable docker.
sudo systemctl is-enabled docker
docker exec -it household-exit-node-gluetun cat /etc/resolv.conf

docker exec -it household-exit-node-gluetun wget -qO- https://ipinfo.io
