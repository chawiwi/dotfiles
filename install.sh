#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-$HOME/git_files/dotfiles}"
DEST="${2:-$HOME/.config}"

mkdir -p "$DEST"

# Top-level dirs in $REPO, excluding a few names
find "$REPO" -mindepth 1 -maxdepth 1 -type d \
  ! -name '.git' \
  ! -name '.github' \
  ! -name 'scripts' \
  -print0 |
while IFS= read -r -d '' src; do
  base=$(basename "$src")
  # -sfnr: symlink, force/replace, no-deref, make *relative* link (GNU ln)
  ln -sfnr "$src" "$DEST/$base"
  echo "Linked $DEST/$base -> $(realpath --relative-to="$DEST" "$src")"
done
