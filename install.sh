#!/usr/bin/env bash
set -euo pipefail

common=(zsh git tmux alacritty bat scripts nvim)
darwin_only=(skhd yabai)

# Replace the top-level files owned by these dotfiles. Directories under
# ~/.config are left alone so Stow can merge them.
for target in .zshrc .p10k.zsh .gitconfig .gitignore .tmux.conf; do
    if [[ -e "$HOME/$target" && ! -L "$HOME/$target" ]]; then
        rm -f "$HOME/$target"
    fi
done

stow --target="$HOME" --verbose "${common[@]}"
if [[ "$(uname -s)" == "Darwin" ]]; then
    stow --target="$HOME" --verbose "${darwin_only[@]}"
fi
