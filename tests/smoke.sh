#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT

step() {
  printf '\n==> %s\n' "$1"
}

step 'Checking shell syntax'
bash -n "$repo_root/install.sh" "$repo_root/scripts/.local/bin/tmux-sessionizer"

step 'Stowing into an empty home'
(
  cd "$repo_root"
  HOME="$test_home" ./install.sh
)

targets=(
  .zshrc
  .p10k.zsh
  .gitconfig
  .gitignore
  .tmux.conf
  .config/alacritty
  .config/bat
  .config/direnv
  .config/nvim
  .config/zen
  .local/bin/tmux-sessionizer
)

if [[ $(uname -s) == Darwin ]]; then
  targets+=(.config/skhd .config/yabai)
else
  targets+=(.dmrc .config/hypr .config/mako .config/waybar .config/wofi)
fi

step 'Checking installed links'
for target in "${targets[@]}"; do
  [[ -e "$test_home/$target" ]] || {
    printf 'missing target: %s\n' "$target" >&2
    exit 1
  }
  resolved=$(realpath "$test_home/$target")
  [[ $resolved == "$repo_root"/* ]] || {
    printf 'target does not resolve into the repository: %s -> %s\n' "$target" "$resolved" >&2
    exit 1
  }
  printf '    %s -> %s\n' "$target" "$resolved"
done

step 'Checking a second install'
(
  cd "$repo_root"
  HOME="$test_home" ./install.sh
)

printf '\nDotfiles smoke test passed\n'
