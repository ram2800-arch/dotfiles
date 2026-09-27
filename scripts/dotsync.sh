#!/bin/bash

# Navigate directly to the main dotfiles repository
cd ~/dotfiles

echo "==> Checking git status..."
git status

# Check if there are any changes (staged or unstaged)
if [[ -z $(git status -s) ]]; then
    echo "==> No changes to sync. Everything is up to date!"
    exit 0
fi

echo "==> Staging all changes..."
git add -A

# Use the argument passed to dotsync as the commit message, 
# or fall back to a default automated message with a timestamp
COMMIT_MSG="${1:-Auto-sync: $(date '+%b %d %H:%M')}"

echo "==> Committing with message: '$COMMIT_MSG'"
git commit -m "$COMMIT_MSG"

echo "==> Pushing to GitHub..."
git push
echo "==> Sync complete!"
