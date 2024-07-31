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

#Enable touch pad in i3wm

Copy this 90-touchpad.conf to /etc/X11/xorg.conf.d/90-touchpad.conf


#### Next Features:
- create a shell script to automatically stow all files when cloning the repository, ensuring no previous links exist

### Hacks
If i3-ressurect fail i have to break the rules 
    ```bash
        pip3 install --user --upgrade i3-resurrect --break-system-packages
    ```
