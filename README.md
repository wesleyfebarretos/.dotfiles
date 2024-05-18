# Backup

## Install Stow
```bash
$ sudo apt-get update -y && sudo apt-get install -y stow
```
## Dump
Clone this repository in your $HOME
```bash
$ cd ~ && git clone git@github.com:wesleyfebarretos/.dotfiles.git
```
After cloning you must enter the ~/.dotfiles folder and run the stow command for each folder

#### Example:
```bash
$ cd ~/.dotfiles && stow git
```

#### Next Features:
- create a shell script to automatically stow all files when cloning the repository, ensuring no previous links exist
