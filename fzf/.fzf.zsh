# Setup fzf
# ---------
if [[ ! "$PATH" == */home/wesley/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/wesley/.fzf/bin"
fi

eval "$(fzf --zsh)"
