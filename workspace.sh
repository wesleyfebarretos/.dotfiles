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

info "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.zshrc
info_done

info "Installing node 20 and tools"
    nvm install 20
    nvm use 20
    npm install -g @angular/cli@17
    npm install -g ntl
info_done

info "Installing node 18 and tools"
    nvm install 18
    nvm use 18
    npm install -g @angular/cli@17
    npm install -g ntl
info_done

info "Installing node 16 and tools"
    nvm install 16
    nvm use 16
    npm i -g @adonisjs/cli
    npm install -g ntl
info_done

info "Installing postman"
    sudo snap install postman
info_done

info "Installing dbeaver"
    curl -Lo dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    sudo dpkg -i ./dbeaver.deb
    rm -rf ./dbeaver.deb
info_done
