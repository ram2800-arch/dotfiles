i#!/bin/bash

# 1. Create a dedicated directory for server management
mkdir -p ~/.server_setup
cd ~/.server_setup

echo "=========================================="
echo " Starting Headless Server Setup for Mac   "
echo "=========================================="

# 2. Install Tailscale and Jellyfin via Homebrew
echo "--> Installing Tailscale and Jellyfin..."
brew install tailscale jellyfin

# 3. Configure them to start automatically on system boot
echo "--> Registering background services..."
brew services start tailscale
brew services start jellyfin

# 4. Generate the robust caffeinate manager script
echo "--> Generating caffeinate_mgr.sh..."
cat << 'EOF' > caffeinate_mgr.sh
#!/bin/bash

# Configuration
PID_FILE="$HOME/.server_setup/caffeinate.pid"
LOG_FILE="$HOME/.server_setup/caffeinate.log"

# Detailed options: 
# -i (prevent idle sleep), -d (prevent display sleep), -m (prevent disk sleep), -s (prevent system sleep when on AC)
CAFFEINATE_OPTS="-idms"

case "$1" in
    load)
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Server protection is already running (PID: $(cat "$PID_FILE"))."
        else
            echo "Activating sleep prevention (Headless Mode)..."
            nohup caffeinate $CAFFEINATE_OPTS > "$LOG_FILE" 2>&1 &
            echo $! > "$PID_FILE"
            echo "Server successfully protected from sleep."
        fi
        ;;
    unload)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo "Deactivating sleep prevention (PID: $PID)..."
            kill "$PID" 2>/dev/null
            rm -f "$PID_FILE"
            echo "Sleep prevention disabled."
        else
            echo "No active sleep prevention process found."
            # Fallback cleanup
            pkill -f "caffeinate $CAFFEINATE_OPTS" && echo "Cleaned up orphaned processes."
        fi
        ;;
    status)
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Status: PROTECTED (caffeinate is actively running, PID: $(cat "$PID_FILE"))."
        else
            echo "Status: UNPROTECTED (System may go to sleep)."
        fi
        ;;
    *)
        echo "Usage: $0 {load|unload|status}"
        exit 1
        ;;
esac
EOF

# 5. Make the management script executable
chmod +x caffeinate_mgr.sh

echo "=========================================="
echo " Setup Complete! Next Steps:             "
echo "=========================================="
echo " 1. Log into Tailscale: sudo tailscale up"
echo " 2. Open Jellyfin UI: http://localhost:8096"
echo " 3. Lock the server down with: ./caffeinate_mgr.sh load"
echo "=========================================="
