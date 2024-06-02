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

info_ascii() {
	printf "${GREEN}${BOLD}"
	cat <<'EOF'
 ____      ____  ________    ______    _____      ____  ____   ____  _____
|_  _|    |_  _||_   __  | .' ____ \  |_   _|    |_  _||_  _| |_   \|_   _|
  \ \  /\  / /    | |_ \_| | (___ \_|   | |        \ \  / /     |   \ | |
   \ \/  \/ /     |  _| _   _.____`.    | |   _     \ \/ /      | |\ \| |
    \  /\  /     _| |__/ | | \____) |  _| |__/ |    _|  |_     _| |_\   |_
     \/  \/     |________|  \______.' |________|   |______|   |_____|\____|
EOF
	printf "${NORMAL}"
	sleep 1
}

reset
info_ascii

if (($EUID == 0)); then
	info_error "Do not run this script as root"
fi

info "Please enter your password so that this script can sudo:\n*** (hopefully sudo will remember your authentication and not prompt you again)"
sudo -k printf "${BLUE}${BOLD}!!! Successfully elevated priviledges.${NORMAL}\n"

cd ~

info "Updating packages"
sudo apt update && sudo apt-get update && sudo apt-get install -y build-essential
info_done

if ! which fusermount &>/dev/null; then
	info "Instaling fuse"
	sudo apt -y install fuse
	info_done
fi

info "Installing git"
sudo apt install -y git
info_done

info "Installing stow"
sudo apt install -y stow
info_done

info "Cloning wesleyfebarretos/.dotfiles"
if ! [[ -d ~/dots/.git ]]; then
	rm -rf ~/.dotfiles
	git clone https://github.com/wesleyfebarretos/.dotfiles
	cd .dotfiles
	git init
	git pull origin master
	git submodule init
	git submodule update
	cd ../
else
	info ".dotfiles already exists, performing git pull"
	cd ~/.dotifles
	git pull
	cd ../
fi
info_done

info "Installing I3WM"
cd ~
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
sudo apt install ./keyring.deb
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt update
sudo apt install -y i3
info_done

info "Installing Tmux"
sudo apt install -y autoconf automake pkg-config libevent-dev libncurses-dev bison
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure && make
cd ~ && mkdir -p usr/bin
mv ./tmux ~/usr/bin/tmux
cd ~ && rm -rf tmux
info_done

info "Installing Tmux Plugin Manager [TPM]"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
info_done

if ! which curl &>/dev/null; then
	info "Instaling curl"
	sudo apt -y install curl
	info_done
fi

info "Installing zsh"
sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting zsh
info_done

info "Installing fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install
info_done

info "Installing fd"
sudo apt install -y fd-find
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd
info_done

info "Installing bat"
sudo apt install -y bat
ln -s /usr/bin/batcat ~/.local/bin/bat
mkdir -p "$(~/.local/bin/bat --config-dir)/themes"
cd "$(~/.local/bin/bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
~/.local/bin/bat cache --build
cd ~
info_done

info "Cloning fzf-git"
rm -rf ~/fzf-git.sh
cd ~
git clone https://github.com/junegunn/fzf-git.sh.git
info_done

info "Installing Nvim"
cd ~
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
mkdir -p usr/bin
mv nvim.appimage usr/bin/nvim
chmod u+x usr/bin/nvim
info_done

info "Configuring Nvim"
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
cd ~/.dotfiles && stow nvim && cd ~
info_done

info "Installing Lazygit"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
info_done

info "Configuring Layzigt"
rm -rf ~/.config/lazygit
cd ~/.dotfiles && stow lazygit
cd ~
info_done

info "Installing Cargo and Rust"
curl https://sh.rustup.rs -sSf | sh
info_done

info "Installing Atuin"
/.cargo/bin/cargo install atuin
info_done

info "Installing Git-delta"
~/.cargo/bin/cargo install git-delta
info_done

info "Configuring Git-delta"
rm -rf ~/.config/delta
cd ~/.dotfiles && stow delta
cd ~
info_done

info "Installing oh-my-zsh"
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
info_done

info "Installing zsh plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ~/.oh-my-zsh/custom/plugins/zsh-autocomplete
info_done

info "Installing Zsh Dracula Theme"
git clone https://github.com/dracula/zsh.git ~/dracula-zsh-theme
mv ~/dracula-zsh-theme/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme
mkdir ~/.oh-my-zsh/themes/lib
mv ~/dracula-zsh-theme/lib/* ~/.oh-my-zsh/themes/lib
rm -rf ~/dracula-zsh-theme
info_done

info "Configuring zsh"
rm -rf ~/.zsh*
rm -rf ~/.bash_history
cd ~/.dotfiles
stow zsh
zsh ~/.zshrc
sudo usermod --shell /usr/bin/zsh $USER
info_done

info "Setup All Configs"
cd ~/.dotfiles
rm -rf ~/.gitconfig && stow git
rm -rf ~/.config/delta && stow delta
rm -rf ~/.config/gtk-3.0 && stow gtk-3.0
rm -rf ~/.config/i3 && stow i3
rm -rf ~/.config/lazygit && stow lazygit
rm -rf ~/.config/nvim && stow nvim
rm -rf ~/.config/tmux && stow tmux
rm -rf ~/.local/scripts && stow scripts
rm -rf ~/.zsh* && stow zsh
cd ~
info_done

info_important "Finish Setup Dump!!!"
#WARNING: Verificar se o tmux está sendo instalado corretamente e ver as configurações
#TODO:
#Delta
#I3WM
#Tmux
#stow to config all programs
