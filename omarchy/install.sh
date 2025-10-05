#!/bin/bash

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

info() {
    printf "${RED}${BOLD}*** $1 ${NORMAL}\n"
}

info_done() {
    printf "${RED}${BOLD}*** Done! ${NORMAL}\n\n"
    sleep 1
}

info_error() {
    printf "${BLUE}${BOLD}!!!ERROR: $1 ${NORMAL}\n"
    exit 1
}

info_important() {
    printf "${BLUE}${BOLD}!!! $1 ${NORMAL}\n"
}

# Dependencies
info "Install dependencies..."

yay -S --noconfirm zsh stow atuin git-delta go docker tmux

yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

go install github.com/charmbracelet/gum@latest
go install github.com/joshmedeski/sesh@latest

info_done

# Submodules init
info "Initializing submodules from .dotfiles ..."

cd ~/.dotfiles
git init
git pull origin master
git submodule init
git submodule update
cd ../

info_done

# Environment configuration
info "Initializing environment configurations..."

sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

mkdir -p "$(/usr/bin/bat --config-dir)/themes"
cd "$(/usr/bin/bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
/usr/bin/bat cache --build
cd ~

git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/zsh-autocomplete
cd ~/zsh-autocomplete && git checkout adfade31a84dfa512a7e3583d567ee19ac4a7936 && cd ~
cp -r zsh-autocomplete /home/weslyn/.oh-my-zsh/custom/plugins && rm -rf ~/zsh-autocomplete

rm -rf ~/fzf-git.sh
cd ~
git clone https://github.com/junegunn/fzf-git.sh.git

git clone https://github.com/dracula/zsh.git ~/dracula-zsh-theme
mv ~/dracula-zsh-theme/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme
mkdir ~/.oh-my-zsh/themes/lib
mv ~/dracula-zsh-theme/lib/* ~/.oh-my-zsh/themes/lib
rm -rf ~/dracula-zsh-theme

rm -rf ~/.zsh*
rm -rf ~/.bash_history
cd ~/.dotfiles
stow zsh
zsh ~/.zshrc
sudo usermod --shell /usr/bin/zsh $USER

cd ~/.dotfiles
rm -rf ~/.gitconfig && stow git
rm -rf ~/.config/delta && stow delta
rm -rf ~/.config/lazygit && stow lazygit
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim && stow nvim
ln -s /home/weslyn/.config/omarchy/current/theme/neovim.lua /home/weslyn/.config/nvim/lua/theme.lua
rm -rf ~/.local/scripts && stow scripts
rm -rf ~/.zsh* && stow zsh
rm -rf ~/.ideavimrc && stow ideavim
cd ~

info_done
