#!/usr/bin/env bash
set -euo pipefail

# Vibe Config backup/restore — mirrors the Claude-Config workflow.
# The ~/.vibe directory is itself a git repo; portable config is tracked,
# secrets (.env) and ephemeral state (logs, caches) are gitignored.

VIBE_DIR="${VIBE_HOME:-$HOME/.vibe}"

cmd="${1:-auto}"

do_backup() {
    cd "$VIBE_DIR"
    if [[ -z "$(git status --porcelain 2>/dev/null || true)" ]]; then
        echo "No changes to back up."
        return
    fi
    echo "Changed files:"
    git status --short
    git add -A
    git commit -m "config backup $(date '+%Y-%m-%d %H:%M:%S')"
    if git remote get-url origin >/dev/null 2>&1; then
        git push origin main
        echo "Pushed to origin."
    else
        echo "Committed locally. No 'origin' remote set — push skipped."
        echo "Set one with: git remote add origin <url>"
    fi
}

do_restore() {
    cd "$VIBE_DIR"
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "~/.vibe is not a git repo."
        echo "On a new machine, restore with:"
        echo "  git clone <repo-url> ~/.vibe"
        exit 1
    fi
    git pull --ff-only origin main 2>/dev/null || echo "No remote to pull from (local-only repo)."
    echo "Restored. Remember to recreate ~/.vibe/.env with your API keys."
}

do_status() {
    cd "$VIBE_DIR"
    git status --short --branch
}

case "$cmd" in
    backup)   do_backup ;;
    restore)  do_restore ;;
    status)   do_status ;;
    auto)     if git -C "$VIBE_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then do_backup; else echo "Not a repo yet — run: git -C ~/.vibe init"; fi ;;
    *)        echo "Usage: install.sh [backup|restore|status]" ;;
esac
