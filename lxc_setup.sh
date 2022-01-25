#! /bin/sh
if [ "$(whoami)" != "root" ]; then
    echo Please run with root privileges.
    exit 1
fi
if [ $# -eq 2 ]; then
    apt update -y;
    apt upgrade -y;
    apt install vim tmux wireguard git -y;
    useradd anpig -m;
    echo "$1":"$2" | chpasswd;
    su - "$1" -c '
        cd || exit
        sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
        git clone https://github.com/anpig/dotfiles.git
        rm -rf dotfile/.git
        cp -a dotfiles/. .
        rm -rf dotfiles
        rm -rf .git
        rm .profile
        rm .bashrc
        rm .bash_profile
        exit
    '
    apt install zsh -y
else
    echo Usage: ./lxc_setup username password
    exit 1
fi