#!/usr/bin/env fish

set -l src "$HOME/.config/Code/User/settings.json"
set -l dest_dir "$HOME/dotfiles/backup/vscode"
set -l dest "$dest_dir/settings.json"

if not test -f "$src"
    echo "Error: $src not found. Nothing to back up."
    exit 1
end

mkdir -p "$dest_dir"
cp "$src" "$dest"

if test $status -eq 0
    echo "Backed up settings.json -> $dest"
else
    echo "Error: failed to copy settings.json"
    exit 1
end