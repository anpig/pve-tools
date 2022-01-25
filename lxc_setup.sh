#! /bin/sh
if [ "$(whoami)" != "root" ]; then
    echo Please run with root privileges.
    exit 1
fi
if [ $# -eq 2 ]; then
    apt update -y;
    apt upgrade -y;
    apt install vim tmux wireguard git zsh -y;
    useradd anpig -s /usr/bin/zsh -m;
    echo "$1":"$2" | chpasswd;
    su - "$1" -c '
        cd || exit
        sh -c "$(wget https://raw.githubusercontent.com/anpig/pve-tools/main/install_ohmyzsh.sh -O -)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
        git clone https://github.com/anpig/dotfiles.git
        cp -a dotfiles/. .
        rm -rf dotfiles .git
        rm .profile .bash* .zcomp* .wget* .shell*
        exit
    '
else
    echo Usage: ./lxc_setup username password
    exit 1
fi