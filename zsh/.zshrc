# ── p10k instant prompt (keep first) ─────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── oh-my-zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git tmux fzf-tab zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode)
source $ZSH/oh-my-zsh.sh

# ── environment ───────────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export COLORTERM="truecolor"
export GOPATH=$HOME/go
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"
export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
export MANPATH=$HOME/.local/share/man:$MANPATH

# ── fzf ───────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
# catppuccin mocha, bg omitted so the terminal background shows through
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
alias fzf="fzf --height=20% --reverse --info=inline"

# ── bat ───────────────────────────────────────────────────────────────────────
export BAT_THEME="Catppuccin Mocha"

# ── aliases: git ──────────────────────────────────────────────────────────────
alias ga="git add"
alias gabs="git absorb --and-rebase"
alias gb="git branch"
alias gc="git commit"
alias gca="git commit --amend --no-edit"
alias gch="git checkout"
alias gcm="git commit -m"
alias gd="git diff"
alias gf="git fetch -j 20"
alias gl="git log"
alias gmc="git merge --continue"
alias gp="git pull -j 20"
alias gpf="git push --force-with-lease"
alias gpp="git push"
alias gps="git pull --recurse-submodules -j 20"
alias grc="git rebase --continue"
alias gs="git status -s"
alias gsu="git status -s | grep UU"

# fzf-git bindings cheat sheet (fb/cb/rb replaced by inline <C-g> pickers)
gcheat() {
  cat << 'EOF'
fzf-git: press inside any command line
  <C-g><C-b>  branches      <C-g><C-h>  commit hashes
  <C-g><C-f>  changed files <C-g><C-t>  tags
  checkout:  git checkout <C-g><C-b>
  rebase:    git rebase -i <C-g><C-b>
EOF
}

# ── aliases: editor & misc ────────────────────────────────────────────────────
alias v="nvim"
alias vi="nvim"
alias nprof='nvim ~/.config/nvim'
alias prof="nvim ~/.zshrc"
alias ta="tmux attach"
alias p="pnpm"
alias pi="pnpm install"
alias pnd="pnpm run dev"

# ── lazy-loaded toolchains ────────────────────────────────────────────────────
# conda: only initialize when first invoked (saves ~930ms startup)
conda() {
  unfunction conda 2>/dev/null
  __conda_setup="$('/opt/miniconda/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "/opt/miniconda/etc/profile.d/conda.sh" ]; then
      . "/opt/miniconda/etc/profile.d/conda.sh"
    else
      export PATH="/opt/miniconda/bin:$PATH"
    fi
  fi
  unset __conda_setup
  conda "$@"
}

# SDKMAN: only initialize when first invoked (saves ~137ms startup)
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unfunction sdk 2>/dev/null
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

# ── hooks & integrations ──────────────────────────────────────────────────────
command -v fnm > /dev/null && eval "$(fnm env --shell zsh --corepack-enabled)"
command -v direnv > /dev/null && eval "$(direnv hook zsh)"
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
zvm_after_init_commands+=('[ -f ~/.local/share/fzf-git/fzf-git.sh ] && source ~/.local/share/fzf-git/fzf-git.sh')

# ── machine-local (untracked: work config, secrets, host-specific paths) ──────
[[ -r "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ── p10k config ───────────────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
