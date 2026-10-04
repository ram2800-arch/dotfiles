#!/bin/bash

# 1. Install Homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Add Homebrew to PATH immediately for the installation session
# eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Define and Install All Formulae (CLI tools, libraries, dependencies)
formulae=(
  atomicparsley ca-certificates certifi coreutils csvkit 
  dav1d deno emacs exiftool ffmpeg gettext gmp gnutls 
  jpeg-turbo lame libevent libidn2 libnghttp2 libtasn1 
  libtiff libunistring libvmaf libvpx little-cms2 lz4 
  mas mpdecimal ncurses nettle openssl@3 opus p11-kit 
  pcre2 pipx python@3.14 readline sdl2 sqlite starship 
  svt-av1 tree-sitter@0.25 unbound wget x264 x265 xz 
  yt-dlp zsh zstd
)

echo "Installing Homebrew formulae..."
brew install "${formulae[@]}"

# 4. Define and Install All Casks (GUI Applications)
casks=(
  1password bbedit brave-browser google-chrome iterm2 
  microsoft-office-businesspro proton-drive vlc whatsapp 
  yt-music
)

echo "Installing Homebrew casks..."
brew install --cask "${casks[@]}"

# 5. Install Oh My Zsh (with --unattended flag to keep script running)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 6. Ensure Homebrew environment persists for future sessions
if ! grep -q "brew shellenv" ~/.zshrc; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
fi

# 7. Final Touch: Refresh shell environment
source ~/.zshrc
echo "Setup Complete! Your new M4 media environment is locked and loaded."
