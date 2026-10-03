# Load machine-specific settings dynamically
LOCAL_CONF="$HOME/dotfiles/ubuntu/$(hostname)/.zshrc.local"
if [[ -f "$LOCAL_CONF" ]]; then
    source "$LOCAL_CONF"
fi
