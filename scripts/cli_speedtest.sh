#!/usr/bin/env bash
# cli_speedtest.sh
# Installs and runs the official Ookla Speedtest CLI across Linux and macOS

set -e

if ! command -v speedtest >/dev/null 2>&1; then
    echo "==> Official Ookla Speedtest CLI not found. Installing..."
    OS="$(uname -s)"
    
    if [[ "$OS" == "Darwin" ]]; then
        # Mac mini installation
        echo "==> Detected macOS. Installing via Homebrew..."
        brew tap teamookla/speedtest
        brew install speedtest
    elif [[ "$OS" == "Linux" ]]; then
        # Ubuntu installation
        echo "==> Detected Linux. Downloading standalone binary..."
        cd /tmp
        wget -q https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz
        tar -xzf ookla-speedtest-1.2.0-linux-x86_64.tgz speedtest
        
        echo "==> Moving to /usr/local/bin (requires sudo password)..."
        sudo mv speedtest /usr/local/bin/
        rm ookla-speedtest-1.2.0-linux-x86_64.tgz
    else
        echo "Error: Unsupported operating system."
        exit 1
    fi
    echo "==> Installation complete!"
fi

echo "==> Running Speedtest..."
speedtest
