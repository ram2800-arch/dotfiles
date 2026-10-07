#!/usr/bin/env bash
# dotsync.sh - Multi-machine resilient dotfiles synchronizer
set -euo pipefail

REPO_DIR="$HOME/dotfiles"
cd "$REPO_DIR"

echo "==> [1/4] Pulling incoming updates from GitHub..."
# Fetch and rebase any remote commits first
git pull --rebase origin main

echo "==> [2/4] Checking for local changes..."
if [[ -n $(git status --porcelain) ]]; then
    echo "==> [3/4] Staging and committing local changes..."
    git add -A
    git commit -m "Auto-sync from $(hostname -s): $(date '+%b %d %H:%M')"
    
    echo "==> [4/4] Pushing to GitHub..."
    # Rebase once more in case an ubu1 cron pushed in the intervening few seconds
    git pull --rebase origin main
    git push origin main
    echo "==> Sync complete!"
else
    echo "==> [3/4] No local changes to commit."
    echo "==> Repo is clean and up to date!"
fi
