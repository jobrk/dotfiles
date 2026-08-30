# dotfiles

Stow-managed dotfiles. One package per tool; `install.sh` stows the set for
the current OS.

```sh
git clone --recurse-submodules https://github.com/jobrk/dotfiles ~/projects/dotfiles
cd ~/projects/dotfiles && ./install.sh
```

Machine provisioning (packages, shell frameworks, fonts, third-party shell
plugins) is handled by [jobrk/ansible](https://github.com/jobrk/ansible), which
clones this repo to `~/projects/dotfiles` and runs `install.sh` as its dotfiles
step. Config files live here only; that repo owns machine state.

## Machine-local overrides

Tracked files contain generic config only. Each sources an untracked local
counterpart; `templates/` has commented examples for all of them. Ansible seeds
these on provision (`force: false`, so edits survive re-runs):

| Tracked | Local override |
|---|---|
| `zsh/.zshrc` | `~/.zshrc.local` |
| `git/.gitconfig` | `~/.gitconfig.local` (identity lives here) |
| `tmux/.tmux.conf` | `~/.tmux.local.conf` |
| `ghostty/…/config.ghostty` | `~/.config/ghostty/local.ghostty` (font/window) |
| `scripts/…/tmux-sessionizer` | `~/.config/sessionizer/paths` |

`templates/secrets.zsh.example` → `~/.config/zsh/secrets.zsh` is copied by hand
(chmod 600), never by ansible.

## Packages

- `zsh` — .zshrc, .p10k.zsh (framework: oh-my-zsh + p10k, installed by ansible)
- `git` — .gitconfig, global .gitignore (`.stow-local-ignore` makes stow
  track a .gitignore it would otherwise skip)
- `tmux` — .tmux.conf (plugins via tpm)
- `ghostty` — colors/keys/integration; font+window per machine via local.ghostty
- `bat` — catppuccin themes
- `scripts` — tmux-sessionizer
- `nvim` — submodule → [jobrk/neovim-config](https://github.com/jobrk/neovim-config)
- `zen` — Zen Browser policies + portable prefs
- `hyprland` — Linux desktop: hypr, waybar, wofi, mako, .dmrc
- `skhd`, `yabai` — macOS window management

`install.sh` stows `common` everywhere, then `hyprland` on Linux or
`skhd`/`yabai` on macOS. Files it owns (`.zshrc`, `.gitconfig`, …) are removed
if they exist as real files, so stow can link them; config *directories* are
left alone so stow merges into them.

The zsh config sources `~/.local/share/fzf-git/fzf-git.sh` when present
([junegunn/fzf-git.sh](https://github.com/junegunn/fzf-git.sh), the `<C-g>`
git pickers listed by `gcheat`). Ansible clones it — it is not vendored here.
