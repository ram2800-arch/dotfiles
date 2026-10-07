#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$HOME/dotfiles"
cd "$REPO_DIR"

echo "==> [1/3] Pulling incoming updates from GitHub..."
# --autostash automatically shelves local edits, rebases, and reapplies them
git pull --rebase --autostash origin main

echo "==> [2/3] Checking for local changes..."
if [[ -n $(git status --porcelain) ]]; then
    echo "==> Staging and committing local changes..."
    git add -A
    git commit -m "Auto-sync from $(hostname -s): $(date '+%b %d %H:%M')"

    echo "==> [3/3] Pushing to GitHub..."
    git pull --rebase --autostash origin main
    git push origin main
    echo "==> Sync complete!"
else
    echo "==> [3/3] No local changes to commit. Repo is clean and up to date!"
fi
