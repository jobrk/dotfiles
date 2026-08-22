#!/usr/bin/env bash
set -euo pipefail

common=(zsh git tmux alacritty bat scripts nvim)
darwin_only=(skhd yabai)
linux_only=(i3)
owned=(.zshrc .p10k.zsh .gitconfig .gitignore .tmux.conf)

if [[ "$(uname -s)" == "Linux" ]]; then
    owned+=(.dmrc)
    if [[ ! -L "$HOME/.config/i3" ]]; then
        owned+=(.config/i3/config)
    fi
fi

# Replace files owned by these dotfiles. Configuration directories are left
# alone so Stow can merge them.
for target in "${owned[@]}"; do
    if [[ -e "$HOME/$target" && ! -L "$HOME/$target" ]]; then
        rm -f "$HOME/$target"
    fi
done

stow --target="$HOME" --verbose "${common[@]}"
if [[ "$(uname -s)" == "Darwin" ]]; then
    stow --target="$HOME" --verbose "${darwin_only[@]}"
else
    stow --target="$HOME" --verbose "${linux_only[@]}"
fi
