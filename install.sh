#!/usr/bin/env bash
set -euo pipefail

common=(zsh git tmux alacritty bat scripts nvim)
darwin_only=(skhd yabai)
linux_only=(hyprland)
owned=(.zshrc .p10k.zsh .gitconfig .gitignore .tmux.conf)

if [[ "$(uname -s)" == "Linux" ]]; then
    # Remove links from the retired i3 package after pulling this repository.
    [[ -L "$HOME/.config/i3" ]] && rm "$HOME/.config/i3"
    [[ -L "$HOME/.dmrc" && ! -e "$HOME/.dmrc" ]] && rm "$HOME/.dmrc"

    owned+=(.dmrc)
    if [[ ! -L "$HOME/.config/hypr" ]]; then
        owned+=(.config/hypr/hyprland.conf .config/hypr/hypridle.conf .config/hypr/hyprlock.conf)
    fi
    if [[ ! -L "$HOME/.config/wofi" ]]; then
        owned+=(.config/wofi/style.css)
    fi
    if [[ ! -L "$HOME/.config/waybar" ]]; then
        owned+=(.config/waybar/config.jsonc .config/waybar/mocha.css .config/waybar/style.css)
    fi
    if [[ ! -L "$HOME/.config/mako" ]]; then
        owned+=(.config/mako/config)
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
