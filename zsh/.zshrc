# ── Completion & Plugins ──────────────────────────────────────────────────────
autoload -Uz compinit && compinit

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.local/share/zsh/history"
mkdir -p "$HOME/.local/share/zsh"
setopt share_history hist_ignore_dups hist_ignore_space

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ll='eza -l'
alias ls='eza'
alias cat='bat'
alias plz='sudo'
alias s='sudo'
alias C='code'
alias c='code .'
alias cd='z'

alias tmuxhelp='echo "
TMUX CHEATSHEET
Prefix is \`  (backtick)

PANES
  prefix + s/|    Split horizontal/vertical
  prefix + h/j/k/l  Navigate panes
  prefix + f      Zoom toggle
  prefix + z      Zoom pane (tmux native)

WINDOWS
  prefix + c      New window
  prefix + n/p    Next/prev window
  prefix + ,      Rename window
  prefix + &      Kill window

SESSIONS
  prefix + d      Detach
  tmux ls         List sessions
  tmux attach     Attach

MISC
  prefix + g      Lazygit popup
  prefix + [      Copy mode (vim keys, y to yank)
  prefix + p      Paste
"'

# ── Zoxide (replaces cd) ──────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Starship prompt ───────────────────────────────────────────────────────────
eval "$(starship init zsh)"


export PATH=/home/shlok/.opencode/bin:$PATH
