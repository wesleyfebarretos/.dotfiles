need to remove the link between omarchy and mako config folder and link my mako config with the omarchy theme state and after stow

ln -s -f ~/.dotfiles/omarchy/mako/.config/mako/config ~/.config/omarchy/current/theme/mako.ini

example stow

stow -t $HOME mako
