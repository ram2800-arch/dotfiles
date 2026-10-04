# 1. Install Homebrew (The -c flag keeps it quiet)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Add Homebrew to PATH (Ensures 'brew' works immediately)
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Install iTerm2 via Brew Cask
brew install --cask iterm2

# 4. Install Oh My Zsh (The --unattended flag prevents it from jumping into a new shell mid-script)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 5. Final Touch: Refresh the shell
source ~/.zshrc
echo "Setup Complete. iTerm2 is in your Applications folder."