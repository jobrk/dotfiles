#!/usr/bin/env bash
set -euo pipefail

common=(zsh git tmux alacritty bat scripts nvim)
darwin_only=(skhd yabai)
backup_root="${DOTFILES_BACKUP_DIR:-$HOME/.local/state/dotfiles/backups/$(date +%Y%m%d-%H%M%S)}"

backup_conflict() {
    local target="$HOME/$1"
    local backup="$backup_root/$1"

    if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$(dirname "$backup")"
        chmod 700 "$backup_root"
        mv "$target" "$backup"
        chmod 600 "$backup"
        echo "Backed up $target to $backup"
    fi
}

# These are the top-level files managed by Stow that commonly predate the
# dotfiles checkout. Package directories under ~/.config can be merged safely.
for target in .zshrc .p10k.zsh .gitconfig .gitignore .tmux.conf .local/bin/tmux-sessionizer; do
    backup_conflict "$target"
done

echo "Stowing dotfiles..."
stow --target="$HOME" --verbose "${common[@]}"
if [[ "$(uname -s)" == "Darwin" ]]; then
    stow --target="$HOME" --verbose "${darwin_only[@]}"
fi

echo "Done. Machine-local overrides (untracked):"
echo "  ~/.zshrc.local ~/.gitconfig.local ~/.tmux.local.conf"
echo "  ~/.config/alacritty/local.toml ~/.config/sessionizer/paths"
echo "  ~/.config/zsh/secrets.zsh"
