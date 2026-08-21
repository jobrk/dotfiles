#!/usr/bin/env bash
set -euo pipefail

common=(zsh git tmux alacritty bat scripts nvim)
darwin_only=(skhd yabai)

echo "Stowing dotfiles..."
stow --target="$HOME" --verbose "${common[@]}"
if [[ "$(uname -s)" == "Darwin" ]]; then
    stow --target="$HOME" --verbose "${darwin_only[@]}"
fi

echo "Done. Machine-local overrides (untracked):"
echo "  ~/.zshrc.local ~/.gitconfig.local ~/.tmux.local.conf"
echo "  ~/.config/alacritty/local.toml ~/.config/sessionizer/paths"
echo "  ~/.config/zsh/secrets.zsh"
