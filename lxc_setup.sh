#! /bin/sh
if [ $# -lt 2 ]; then
    exit 1
fi
if [ "$(whoami)" != "root" ]; then
    exit 1
fi
apt update -y;
apt upgrade -y;
apt install vim tmux wireguard zsh -y;
useradd anpig -s /usr/bin/zsh -m;
touch /home/anpig/.zshrc;
echo "$1":"$2" | chpasswd;
su - "$1";
cd /home/"$1" || exit
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k;
mv "$(dirname "$0")"/dotfiles/.p10k.zsh /home/"$1";
mv "$(dirname "$0")"dotfiles/.zshrc /home/"$1";
exit;
exit
