alias vim="nvim"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME' 
alias doom="~/.emacs.d/bin/doom"

export BAT_THEME="dracula"
export RIPGREP_CONFIG_PATH="/Users/fredricwaadeland/.ripgreprc"

alias config='/usr/bin/git --git-dir=/Users/fredricwaadeland/.cfg/ --work-tree=/Users/fredricwaadeland'
alias config='/usr/bin/git --git-dir=/Users/fredricwaadeland/.cfg/ --work-tree=/Users/fredricwaadeland'

. ~/.bash_profile

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# .NET Core SDK settings
export DOTNET_CLI_ELEMETRY_OPTOUT=true
# Development / Staging / Production
export DOTNET_ENVIRONMENT='Development'
. "$HOME/.cargo/env"
