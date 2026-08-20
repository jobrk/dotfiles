#!/usr/bin/env bash
set -e

common="zsh git tmux alacritty bat scripts nvim"
darwin_only="skhd yabai"

echo "Stowing dotfiles..."
stow $common
if [[ "$(uname -s)" == "Darwin" ]]; then
    stow $darwin_only
fi

echo "Done. Machine-local overrides (untracked):"
echo "  ~/.zshrc.local ~/.gitconfig.local ~/.tmux.local.conf"
echo "  ~/.config/alacritty/local.toml ~/.config/sessionizer/paths"
