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
else
	info ".dotfiles already exists, performing git pull"
	cd ~/.dotifles
	git pull
	cd ../
fi
info_done

if ! which curl &>/dev/null; then
	info "Instaling curl"
	sudo apt -y install curl
	info_done
fi

info "Installing fzf"
sudo apt install -y fzf
info_done

info "Installing fd"
sudo apt install -y fd-find
info_done

info "Installing zsh"
sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting zsh
info_done

info "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
info_done

info "Installing zsh plugins"
sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
sudo git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
sudo git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ~/.oh-my-zsh/custom/plugins/zsh-autocomplete
info_done

info "Installing bat"
sudo apt install -y bat
sudo mkdir -p ~/.local/bin
sudo ln -s /usr/bin/batcat ~/.local/bin/bat
sudo mkdir -p "$(~/.local/bin/bat --config-dir)/themes"
cd "$(~/.local/bin/bat --config-dir)/themes"
sudo curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
cd ~
info_done

info "Cloning fzf-git"
rm -rf ~/fzf-git.sh
git clone https://github.com/junegunn/fzf-git.sh.git
info_done

info "Installing Zsh Dracula Theme"
sudo git clone https://github.com/dracula/zsh.git ~/dracula-zsh-theme
sudo mv ~/dracula-zsh-theme/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme
sudo mkdir ~/.oh-my-zsh/themes/lib
sudo mv ~/dracula-zsh-theme/lib/* ~/.oh-my-zsh/themes/lib
sudo rm -rf ~/dracula-zsh-theme
info_done

info "Installing Cargo and Rust"
curl https://sh.rustup.rs -sSf | sh
info_done

info "Installing Atuin"
~/.cargo/bin/cargo install atuin
info_done

info "Configuring zsh"
sudo rm -rf ~/.zsh*
sudo rm -rf ~/.bash_history
cd ~/.dotfiles
sudo stow zsh
sudo zsh ~/.zshrc
sudo usermod --shell /usr/bin/zsh $USER
info_important "Installed zsh"
info_done

#TODO: Verificar Erro ao tentar configurar o zsh
