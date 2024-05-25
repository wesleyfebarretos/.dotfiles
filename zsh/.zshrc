export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/usr/bin:$HOME/go/bin:$PATH:/usr/local/go/bin:$HOME/apache-maven-3.9.6/bin:$HOME/.local/bin:/opt/docker-desktop/bin"

ZSH_THEME="dracula"
DRACULA_DISPLAY_FULL_CWD=1
DRACULA_DISPLAY_NEW_LINE=1

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)

source $ZSH/oh-my-zsh.sh

#Import zsh_aliases
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

#Import zsh_functions
if [ -f ~/.zsh_functions ]; then
    . ~/.zsh_functions
fi

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZD_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_T_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}

eval "$(atuin init zsh)"

#Appointment to fzf git file to have actions on terminal
source ~/fzf-git.sh/fzf-git.sh

#bat better than cat
export BAT_THEME="tokyonight_night"

#fzf keys
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
