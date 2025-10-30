# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

#POWERLEVEL9K_MODE='nerdfont-patched'
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir dir_writable vcs)
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
#POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
#POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND="black"
#POWERLEVEL9K_STATUS_VERBOSE=false
#POWERLEVEL9K_TIME_BACKGROUND="black"
#POWERLEVEL9K_TIME_FOREGROUND="249"
#POWERLEVEL9K_TIME_FORMAT="%D{%H:%M} \uE12E"
#POWERLEVEL9K_COLOR_SCHEME='dark'
#POWERLEVEL9K_VCS_GIT_ICON='\uF408'
#POWERLEVEL9K_VCS_GIT_GITHUB_ICON='\uF408'
#POWERLEVEL9K_HIDE_BRANCH_ICON=true

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)
#source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Defining deault editor as nvim
export EDITOR=nvim

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias dl='cd ~/Downloads'
alias dc='cd ~/Documents'
alias pc='cd ~/Pictures'
alias wf='cd /home/kaisawa/Desktop/Docs/Work'
alias gf='cd /home/kaisawa/Desktop/Docs/git_files'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source $ZSH/oh-my-zsh.sh

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
# Adding go to path
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
# Lazygit alias
alias lg='lazygit'
LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# Homebrew stuff
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="$HOME/.local/npm-global/bin:$PATH"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
alias wz='wezterm'

# ===================== fd + fzf + ripgrep power-ups ==========================
# Detect fd/fdfind once (fzf runs via /bin/sh, so aliases won't work there)
if command -v fd >/dev/null 2>&1; then
  _FD_BIN=fd
elif command -v fdfind >/dev/null 2>&1; then
  _FD_BIN=fdfind
else
  _FD_BIN=""
fi

# Prefer 'bat' for previews; fall back to 'batcat', then sed/awk
if command -v bat >/dev/null 2>&1; then
  _PREVIEW_FILE='bat --style=numbers --paging=never --color=always {}'
  _PREVIEW_RG='bat --style=numbers --paging=never --color=always {1} --line-range {2}:+'
elif command -v batcat >/dev/null 2>&1; then
  _PREVIEW_FILE='batcat --style=numbers --paging=never --color=always {}'
  _PREVIEW_RG='batcat --style=numbers --paging=never --color=always {1} --line-range {2}:+'
else
  _PREVIEW_FILE="sed -n '1,200p' {}"
  # Show 200 lines starting from the match line for rg previews
  _PREVIEW_RG='awk "NR>={2} && NR<{2}+200 {print}" {1}'
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
ff() {
  local file
  file=$(fzf --preview "$_PREVIEW_FILE") || return
  "${EDITOR:-nvim}" "$file"
}

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
v() { if [ $# -eq 0 ]; then ff; else "${EDITOR:-nvim}" "$@"; fi }

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
