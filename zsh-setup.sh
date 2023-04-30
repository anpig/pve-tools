#! /bin/bash
username=YOUR_USER_NAME
password=YOUR_PASSWORD

# update/install packages
apt update -y;
apt upgrade -y;
apt install htop vim tmux git zsh curl -y;

# add a new user
useradd "$username" -s /usr/bin/zsh -m
usermod -aG sudo "$username"
echo "$username":"$password" | chpasswd

# setting zsh and powerlevel10k for the user
su - "$username" -c '
    cd || exit
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
    git clone https://github.com/anpig/dotfiles.git
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    cp -a dotfiles/. .
    rm -rf dotfiles .git
    rm .profile .bash* .wget* .zcomp* 2> /dev/null
    exit
'

echo "You can now login as $username."
