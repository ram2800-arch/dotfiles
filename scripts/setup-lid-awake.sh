#!/usr/bin/env bash
# ==============================================================================
# UBUNTU LAPTOP LID ALWAYS-AWAKE CONFIGURATION SCRIPT
# Prevents Ubuntu from sleeping or suspending when closing the laptop lid.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. SET LID SWITCH TO IGNORE IN LOGIND.CONF
# ------------------------------------------------------------------------------

echo "Updating /etc/systemd/logind.conf settings..."
sudo sed -i 's/#\?HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#\?HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#\?HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf

echo "Settings applied. Current configuration:"
grep HandleLidSwitch /etc/systemd/logind.conf

echo ""
echo "Note: Settings take full effect upon reboot."
echo "If you restart systemd-logind now (sudo systemctl restart systemd-logind),"
echo "it will lock or interrupt active graphical desktop sessions."

# ------------------------------------------------------------------------------
# 2. RESET TO DEFAULT (SUSPEND ON LID CLOSE) - FOR REFERENCE
# ------------------------------------------------------------------------------
# To revert back to standard sleep/suspend on lid close, run:
# sudo sed -i 's/#\?HandleLidSwitch=.*/HandleLidSwitch=suspend/' /etc/systemd/logind.conf
# sudo sed -i 's/#\?HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=suspend/' /etc/systemd/logind.conf
# sudo sed -i 's/#\?HandleLidSwitchDocked=.*/HandleLidSwitchDocked=suspend/' /etc/systemd/logind.conf
