# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export VISUAL="lvim"
export EDITOR="lvim"
# source ~/.dotfile/tmuxinator.zsh
export VAULT_ADDR="https://vault.test-elvia.io/"

export PATH=/opt/homebrew/bin:~/.local/bin:$HOME/bin:$PATH
# export PATH=$HOME/bin:$PATH
# export PATH=/Users/fredricwaadeland/.local/bin/lvim:$PATH
#alias lvim="/Users/fredricwaadeland/.local/bin/lvim"

# # .NET Core SDK settings
export DOTNET_CLI_TELEMETRY_OPTOUT=true
# Development / Staging / Production
export DOTNET_ENVIRONMENT='Development'

alias ls="ls -1a"

alias vi="nvim"

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

alias doom="~/.emacs.d/bin/doom"

alias note="cd ~/Documents/Notes && vim ."
alias mux="tmuxinator"
alias commit="git-cz"
alias reload="source ~/.zshrc"
alias vrc="nvim ~/dotfiles/macos/.vimrc"
alias brc="nvim ~/dotfiles/macos/.bashrc"
alias zrc="nvim ~/dotfiles/macos/.zshrc"
alias bashprofile="vim ~/.bash_profile"
alias dotfiles='cd ~/dotfiles' 
alias discard="hub checkout -- ."
alias clean="hub clean -df"
alias diff="hub diff --name-only develop..."
alias pull="hub pull"
alias push="hub push"
alias branch="hub checkout -b"
alias trunk="hub checkout trunk"
alias pr="hub pr list"
alias checkpr="hub pr checkout"

# fbr - checkout git branch (including remote branches)
chk() {
 local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

alias dev="tmuxinator start -p ~/.config/tmuxinator/hafslund.yml"
renametab() {
    echo -ne "\033]0;"$@"\007"
}

# NPM
alias nr="npm run"
alias ns="npm start"

# Network
alias ip="echo \"local: \$(ifconfig | grep \"inet \" | grep -Fv 127.0.0.1 | awk '{print \$2}')\" && echo \"public: \" && curl ifconfig.me || echo"
# ZSH_DISABLE_COMPFIX=true
# Path to your oh-my-zsh installation.
export ZSH="/Users/fredricwaadeland/.oh-my-zsh"
# source ~/.bin/tmuxinator.zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="avit"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
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

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  npm
  fzf
  ripgrep
  tmuxinator
  docker
  rust
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="$PATH:./node_modules/.bin"

# bindkey -v # vimmode
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# History search
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# History search with cursor at the end
# autoload -U history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# bindkey "^[[A" history-beginning-search-backward-end
# bindkey "^[[B" history-beginning-search-forward-end

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$(git_custom_status) $EPS1"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

export BAT_THEME="Dracula"
export RIPGREP_CONFIG_PATH=/Users/hansfredricwaadeland/.ripgreprc
# Feed the output of ag into fzf
# ag -g "" | fzf

# Setting ag as the default source for fzf
# export FZF_DEFAULT_COMMAND='ag -g ""'

# Now fzf (w/o pipe) will use ag instead of find
# fzf

# To apply the command to CTRL-T as well
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_DEFAULT_COMMAND='ag -g ""'



export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#compdef bit
###-begin-bit-completions-###
#
# yargs command completion script
#
# Installation: /Users/fredricwaadeland/bin/bit completion >> ~/.zshrc
#    or /Users/fredricwaadeland/bin/bit completion >> ~/.zsh_profile on OSX.
#
_bit_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" /Users/fredricwaadeland/bin/bit --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _bit_yargs_completions bit
###-end-bit-completions-###

