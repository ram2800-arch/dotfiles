curl -I https://api.snapcraft.io   
sudo systemctl restart snapd snapd.socket
sudo snap refresh   

# Can your system resolve and reach the API at all?
resolvectl query api.snapcraft.io
curl -I https://api.snapcraft.io

# Check for stale proxy settings
env | grep -i proxy   
sudo systemctl restart snapd snapd.socket
sudo resolvectl flush-caches
sudo snap refresh --list   
sudo snap set system proxy.http=""
sudo snap set system proxy.https=""   
# Test with a public resolver
sudo resolvectl flush-caches
# Or set a DNS override for the VM's network config   

