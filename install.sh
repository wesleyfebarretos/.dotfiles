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

if ! which curl &>/dev/null; then
    sudo apt -y install curl
fi

if ! which fusermount &>/dev/null; then
    sudo apt -y install fuse
fi

if ! which unzip &>/dev/null; then
    sudo apt -y install unzip
fi
info_done

info "Installing git"
sudo apt install -y git
info_done

info "Installing stow"
sudo apt install -y stow
info_done

info "Initializing submodules from .dotfiles ..."
cd ~/.dotfiles
git init
git pull origin master
git submodule init
git submodule update
cd ../
info_done

info "Installing kitty"
mkdir ~/.local
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    installer=nightly
info_done

info "Installing gnome-screenshot"
sudo apt install gnome-screenshot
info_done

info "Installing i3wm"
cd ~
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
sudo apt install ./keyring.deb
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt update
sudo apt install -y i3
rm -rf keyring.deb
info_done

info "Installing i3wm audio software control"
sudo apt install pulseaudio-utils
info_done

info "Installing pip3"
sudo apt install -y python3-pip
info_done

info "Installing i3-resurrect"
pip3 install --user --upgrade i3-resurrect
info_done

info "Installing tmux"
sudo apt install -y autoconf automake pkg-config libevent-dev libncurses-dev bison
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure && make
cd ~ && mkdir -p usr/bin
mv ./tmux/tmux ~/usr/bin/tmux
cd ~ && rm -rf tmux
info_done

info "Configuring tmux"
rm -rf ~/.config/tmux
cd ~/.dotfiles && stow tmux
export PATH=$PATH:$HOME/usr/bin
cd ~
info_done

info "Installing tmux plugin manager [TPM]"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
info_done

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

info "Installing nvim"
cd ~
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
mkdir -p usr/bin
mv nvim.appimage usr/bin/nvim
chmod u+x usr/bin/nvim
info_done

info "Configuring nvim"
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
cd ~/.dotfiles && stow nvim && cd ~
info_done

info "Installing lib fuse"
sudo apt install -y libfuse2 libfuse-dev
info_done

info "Installing fira code"
curl -Lo FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
unzip FiraCode.zip -d FiraCode
mkdir -p ~/.local/share/fonts
mv FiraCode/*.ttf ~/.local/share/fonts/
fc-cache -fv
rm -rf FiraCode.zip FiraCode
info_done

info "Installing comic mono"
curl -o ComicMono.ttf https://dtinth.github.io/comic-mono-font/ComicMono.ttf
curl -o ComicMono-Bold.ttf https://dtinth.github.io/comic-mono-font/ComicMono-Bold.ttf
mv ComicMono* ~/.local/share/fonts/
fc-cache -fv
info_done

info "Installing lazygit"
LAZYGIT_VERSION="0.39.3"
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm -rf lazygit*
info_done

info "Configuring lazygit"
rm -rf ~/.config/lazygit
cd ~/.dotfiles && stow lazygit
cd ~
info_done

info "Installing cargo and rust"
curl https://sh.rustup.rs -sSf | sh
export PATH=$PATH:$HOME/.cargo/bin
info_done

info "Installing atuin"
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
info_done

info "Installing git-delta"
cargo install git-delta
info_done

info "Installing eza"
cargo install eza
info_done

info "Configuring git-delta"
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
git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/zsh-autocomplete
cd ~/zsh-autocomplete && git checkout adfade31a84dfa512a7e3583d567ee19ac4a7936 && cd ~
cp -r zsh-autocomplete /home/weslyn/.oh-my-zsh/custom/plugins && rm -rf ~/zsh-autocomplete
info_done

info "Installing zsh dracula theme"
git clone https://github.com/dracula/zsh.git ~/dracula-zsh-theme
mv ~/dracula-zsh-theme/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme
mkdir ~/.oh-my-zsh/themes/lib
mv ~/dracula-zsh-theme/lib/* ~/.oh-my-zsh/themes/lib
rm -rf ~/dracula-zsh-theme
info_done

info "Install zoxide"
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
info_done

info "Install golang"
GO_INSTALL_DIR="/usr/local/go"
LATEST_GO_VERSION=$(curl -sSL https://golang.org/VERSION\?m\=text | grep -o '^go[0-9\.]*')
GO_DOWNLOAD_URL="https://golang.org/dl/${LATEST_GO_VERSION}.linux-amd64.tar.gz"
curl -sSL -o go_latest.tar.gz $GO_DOWNLOAD_URL
sudo rm -rf $GO_INSTALL_DIR
sudo tar -C /usr/local -xzf go_latest.tar.gz
rm go_latest.tar.gz
export PATH=$PATH:/usr/local/go/bin
info_done

info "Installing gum"
go install github.com/charmbracelet/gum@latest
info_done

info "Installing sesh"
go install github.com/joshmedeski/sesh@latest
info_done

info "Installing postman"
curl -sSL https://dl.pstmn.io/download/latest/linux_64 -o postman.tar.gz
tar -xzf postman.tar.gz
mv Postman ~/.local/share
rm -rf postman.tar.gz
info_done

info "Installing dbeaver"
curl -Lo dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
sudo dpkg -i ./dbeaver.deb
rm -rf ./dbeaver.deb
info_done

info "Configuring zsh"
rm -rf ~/.zsh*
rm -rf ~/.bash_history
cd ~/.dotfiles
stow zsh
zsh ~/.zshrc
sudo usermod --shell /usr/bin/zsh $USER
info_done

info "Setup all configs"
cd ~/.dotfiles
rm -rf ~/.gitconfig && stow git
rm -rf ~/.config/delta && stow delta
rm -rf ~/.config/gtk-3.0 && stow gtk-3.0
rm -rf ~/.config/i3 && stow i3
rm -rf ~/.config/i3status && stow i3status
rm -rf ~/.config/lazygit && stow lazygit
rm -rf ~/.config/nvim && stow nvim
rm -rf ~/.config/kitty && stow kitty
rm -rf ~/.local/scripts && stow scripts
rm -rf ~/.zsh* && stow zsh
rm -rf ~/.ideavimrc && stow ideavim
cd ~
info_done

info "Removing unnecessary files"
rm -rf ~/install.sh
info_done

info "Installing docker"
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker

sudo usermod -aG docker $USER

newgrp docker
info_done

info_important "Finish Setup Dump!!!"
