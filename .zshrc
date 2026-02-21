# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
zstyle ':catppuccin:p10k' 'theme' 'lean'
zstyle ':catppuccin:p10k' 'flavour' 'mocha'

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Path stuff
export PATH="$HOME/.cargo/env:$PATH"
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="$HOME/.local/npm-global/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$(ruby -e 'print Gem.bindir'):$PATH"

# Plugins
zinit light romkatv/powerlevel10k
zinit light tolkonepiu/catppuccin-powerlevel10k-themes
zinit light zsh-users/zsh-history-substring-search
zinit light Aloxaf/fzf-tab
typeset -g ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zinit for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    blockf \
        zsh-users/zsh-completions
if [[ -z "${DOTFILES_FSH_LOADED:-}" ]]; then
  DOTFILES_FSH_LOADED=1
  zinit light zdharma-continuum/fast-syntax-highlighting
  command -v fast-theme >/dev/null 2>&1 && fast-theme XDG:catppuccin-mocha >/dev/null 2>&1
else
  command -v fast-theme >/dev/null 2>&1 && fast-theme XDG:catppuccin-mocha >/dev/null 2>&1
fi
if [[ -z "${DOTFILES_ZSH_AUTOSUGGEST_LOADED:-}" ]]; then
  DOTFILES_ZSH_AUTOSUGGEST_LOADED=1
  zinit light zsh-users/zsh-autosuggestions
fi
zinit wait lucid for p1r473/zsh-color-logging
# zinit wait lucid for vineyardbovines/auto-color-ls
# zinit snippet OMZ::plugins/grc/grc.plugin.zsh
# zinit snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh
# zinit snippet OMZ::plugins/alias-finder/alias-finder.plugin.zsh
# zinit snippet OMZ::plugins/extract/extract.plugin.zsh
if command -v fzf >/dev/null 2>&1; then
  zinit snippet OMZ::plugins/fzf/fzf.plugin.zsh
fi
zstyle ':omz:plugins:eza' header yes
zstyle ':omz:plugins:eza' dirs-first yes
zstyle ':omz:plugins:eza' git-status yes
zstyle ':omz:plugins:eza' icons yes
if command -v eza >/dev/null 2>&1; then
  zinit snippet OMZ::plugins/eza/eza.plugin.zsh
fi
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit snippet OMZ::plugins/colorize/colorize.plugin.zsh
zinit light chrissicool/zsh-256color
zinit light joknarf/shell-ng
zinit light Freed-Wu/zsh-help
-help-() {
    bat --color=always -pplhelp --paging=always
}
alias -g -- '-h=-h 2>&1 | -help-'


# history-substring-search keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Prefer 'bat' for previews; fall back to 'batcat', then sed/awk
if command -v bat >/dev/null 2>&1; then
  _PREVIEW_FILE='bat --style=numbers --paging=never --color=always {}'
  _PREVIEW_RG='bat --style=numbers --paging=never --color=always {1} --line-range {2}'
elif command -v batcat >/dev/null 2>&1; then
  _PREVIEW_FILE='batcat --style=numbers --paging=never --color=always {}'
  _PREVIEW_RG='batcat --style=numbers --paging=never --color=always {1} --line-range {2}'
else
  _PREVIEW_FILE="sed -n '1,200p' {}"
  # Show 200 lines starting from the match line for rg previews
  _PREVIEW_RG='awk "NR>={2} && NR<{2}+200 {print}" {1}'
fi

# Catppuccin Mocha for bat/cat when available.
if command -v bat >/dev/null 2>&1; then
  export BAT_THEME="Catppuccin Mocha"
  alias cat="bat --style=plain --paging=never --theme=\"Catppuccin Mocha\""
elif command -v batcat >/dev/null 2>&1; then
  export BAT_THEME="Catppuccin Mocha"
  alias cat="batcat --style=plain --paging=never --theme=\"Catppuccin Mocha\""
fi

# less + lesspipe with Catppuccin-friendly colors.
if command -v lesspipe.sh >/dev/null 2>&1; then
  export LESSPIPE="lesspipe.sh"
  export LESSOPEN="| $LESSPIPE %s"
elif command -v lesspipe >/dev/null 2>&1; then
  export LESSPIPE="lesspipe"
  export LESSOPEN="| $LESSPIPE %s"
fi
export LESS="-R"
export LESS_TERMCAP_mb=$'\e[1;38;2;243;139;168m'   # red (#f38ba8)
export LESS_TERMCAP_md=$'\e[1;38;2;180;190;254m'   # lavender (#b4befe)
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[48;2;69;71;90m\e[38;2;205;214;244m' # surface1 + text
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;38;2;245;194;231m'   # pink (#f5c2e7)
export LESS_TERMCAP_ue=$'\e[0m'

# Pager: prefer bat when available, otherwise fall back to less.
if command -v bat >/dev/null 2>&1; then
  export PAGER="bat --plain"
elif command -v batcat >/dev/null 2>&1; then
  export PAGER="batcat --plain"
else
  export PAGER="less -R"
fi

# Catppuccin Mocha file colors when vivid is available.
if command -v vivid >/dev/null 2>&1; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Defining deault editor as nvim
export EDITOR="nvim"

autoload -Uz edit-command-line
zle -N edit-command-line

function kitty_scrollback_edit_command_line() {
  local VISUAL="$HOME/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.sh"
  zle edit-command-line
  zle kill-whole-line
}
zle -N kitty_scrollback_edit_command_line

bindkey "^X^E" kitty_scrollback_edit_command_line
# Zoxide config
# Zoxide config
# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
# shellcheck disable=SC2154
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

__zoxide_z_prefix='z#'

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    elif [[ "$@[-1]" == "${__zoxide_z_prefix}"?* ]]; then
        # shellcheck disable=SC2124
        \builtin local result="${@[-1]}"
        __zoxide_cd "${result:${#__zoxide_z_prefix}}"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" &&
            __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# Completions.
if [[ -o zle ]]; then
    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            _files -/
        elif [[ "${words[-1]}" == '' ]] && [[ "${words[-2]}" != "${__zoxide_z_prefix}"?* ]]; then
            \builtin local result
            # shellcheck disable=SC2086,SC2312
            if result="$(\command zoxide query --exclude "$(__zoxide_pwd)" --interactive -- ${words[2,-1]})"; then
                result="${__zoxide_z_prefix}${result}"
                # shellcheck disable=SC2296
                compadd -Q "${(q-)result}"
            fi
            \builtin printf '\e[5n'
        fi
        return 0
    }

    \builtin bindkey '\e[0n' 'reset-prompt'
    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete __zoxide_z
fi

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

\builtin alias z=__zoxide_z
\builtin alias zi=__zoxide_zi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually ~/.zshrc):
#
# eval "$(zoxide init zsh)"
#
# Lazygit alias
LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"


# ===================== fd + fzf + ripgrep power-ups ==========================
# Detect fd/fdfind once (fzf runs via /bin/sh, so aliases won't work there)
if command -v fd >/dev/null 2>&1; then
  _FD_BIN=fd
elif command -v fdfind >/dev/null 2>&1; then
  _FD_BIN=fdfind
else
  _FD_BIN=""
fi


# fd-powered fzf defaults (with ripgrep fallback if fd/fdfind missing)
if [[ -n "$_FD_BIN" ]]; then
  export FZF_DEFAULT_COMMAND="$_FD_BIN --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_FD_BIN --type d --hidden --follow --exclude .git"
else
  export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!{.git,node_modules,dist,build,.venv,venv}"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='rg --files --hidden -g "!.git" | xargs -r -n1 dirname | sort -u'
fi

# fzf UI & keybinds
export FZF_DEFAULT_OPTS=$'
  --height 80%
  --layout=reverse
  --border
  --ansi
  --preview-window=right:60%:wrap
  --bind=ctrl-/:toggle-preview,ctrl-a:select-all,ctrl-d:deselect-all
  --bind=ctrl-u:preview-top,ctrl-d:preview-bottom
  --bind=shift-up:preview-page-up,shift-down:preview-page-down
  --bind=shift-left:preview-up,shift-right:preview-down
'

# If you installed fzf keybindings (brew/apt), source them
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ------------------------- ripgrep aliases -----------------------------------
alias rgh='rg --hidden --line-number --smart-case -g "!{.git,node_modules,dist,build,.venv,venv}"'
alias rgw='rgh --word-regexp'
alias rgf='rgh --fixed-strings'
alias rgc='rgh -C 3'   # show 3 lines of context

# ------------------------- fuzzy pickers -------------------------------------
# ff: pick a file and open in $EDITOR
# ff() {
#   local file
#   file=$(fzf --preview "$_PREVIEW_FILE") || return
#   "${EDITOR:-nvim}" "$file"
# }

# ffa: pick multiple files and open
ffa() {
  local files
  mapfile -t files < <(fzf --multi --preview "$_PREVIEW_FILE") || return
  (( ${#files[@]} )) && "${EDITOR:-nvim}" "${files[@]}"
}

# fd pickers (use the detected binary; fall back to fdfind name)
fdf() { ${_FD_BIN:-fdfind} --type f "$@" | fzf --preview "$_PREVIEW_FILE"; }
fdd() { ${_FD_BIN:-fdfind} --type d "$@" | fzf --preview 'ls -la --color=always {}'; }
fdl() { ${_FD_BIN:-fdfind} --type l "$@" | fzf --preview 'ls -la --color=always {}'; }

# fcd: fuzzy cd into a directory
fcd() {
  local dir
  if [[ "$#" -eq 1 ]]; then
    cd "$1"
  fi
  dir=$(${_FD_BIN:-fdfind} --type d | fzf --preview 'du -sh {} 2>/dev/null') || return
  cd "$dir" || return
}

# fh: fuzzy search shell history and execute
fh() {
  local cmd
  cmd=$(fc -rl 1 | fzf --tac --no-sort --height=80% --preview 'echo {}') || return
  print -s "$cmd"
  eval "$cmd"
}

# frg: ripgrep → fzf (select match) → open $EDITOR at that line
frg() {
  local q="${*:-}"
  local line file lno
  line=$(rg --hidden --line-number --column --no-heading --smart-case \
           -g "!{.git,node_modules,dist,build,.venv,venv}" "${q:-.}" \
        | fzf --delimiter : --nth=4.. --preview "$_PREVIEW_RG" --preview-label 'rg preview') || return
  file=${line%%:*}
  lno=$(printf '%s' "$line" | cut -d: -f2)
  "${EDITOR:-nvim}" "+${lno}" "$file"
}

# fps: shortcut to frg
fps() { frg "$@"; }

# v: open $PWD in editor if no args, else open args
v() { if [ $# -eq 0 ]; then "${EDITOR:-nvim}"; else "${EDITOR:-nvim}" "$@"; fi }

# fzg: fuzzy-pick tracked git files
fzg() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repo"; return 1; }
  git ls-files | fzf --preview "$_PREVIEW_FILE" | xargs -r "${EDITOR:-nvim}"
}

# gcof: fuzzy checkout branches
gcof() {
  git rev-parse --git-dir >/dev/null 2>&1 || return
  local b
  b=$(git branch --all --color=always --format='%(refname:short)' \
      | sed 's#^remotes/##' \
      | awk '!seen[$0]++' \
      | fzf --ansi --preview 'git log --oneline --decorate --graph --color=always --max-count=200 {1}') || return
  git checkout "$b"
}

# QoL envs (optional)
export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-$HOME/.ripgreprc}"
export FD_OPTIONS="${FD_OPTIONS:-}"
# ~/.fdignore is honored by fd/fdfind; e.g.:
# printf ".git\nnode_modules\ndist\nbuild\n.venv\n" >> ~/.fdignore
# =============================================================================
# checking


# yazi shell wrapper for changing cwd to directory navigated to in yazi. Q to quit yazi without changing
function y() {
alias y='yazi'
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# source $(dirname $(gem which colorls))/tab_complete.sh

alias dl='cd ~/Downloads'
alias dc='cd ~/Documents'
alias pc='cd ~/Pictures'
alias wf='cd /home/kaisawa/Desktop/Docs/Work'
alias gf='cd /home/kaisawa/Desktop/Docs/git_files'
alias icat="kitten icat"
alias cx="codex"
alias cxr="codex resume"
alias lg='lazygit'
alias wz='wezterm'

# Created by `pipx` on 2026-02-21 18:02:16
export PATH="$PATH:/home/kaisawa/.local/bin"
