#! /bin/sh
if [ "$(whoami)" != "root" ]; then
    echo Please run with root privileges.
    exit 1
fi

# update/install packages
apt update -y;
apt upgrade -y;
apt install vim tmux wireguard git zsh -y;

# add a new user
useradd anpig -s /usr/bin/zsh -m;

if [ $# -lt 2 ]; then
    echo ""
    echo "Username: "
    read -r username
    echo "Password: "
    stty -echo
    read -r password
    stty echo
    echo ""
else
    username=$1
    password=$2
fi

echo "$username":"$password" | chpasswd;

# setting zsh for the user
su - "$username" -c '
    cd || exit
    sh -c "$(wget https://raw.githubusercontent.com/anpig/pve-tools/main/install-ohmyzsh.sh -O -)"
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

# setting up wireguard
sh -c 'umask 077; touch /etc/wireguard/wg0.conf'
cd /etc/wireguard/ || exit
umask 077; wg genkey | tee privatekey | wg pubkey > publickey
privateKey=$(cat privatekey)
publicKey=$(cat publickey)
echo ""
echo "Server public key: "
read -r serverPubKey
echo "LXC id:"
read -r lxcid
echo "Endpoint: (IP:Port)"
read -r endpoint
{
    echo "[Interface]";
    echo "PrivateKey = $privateKey";
    echo "Address = 10.6.11.$lxcid/24";
    echo "";
    echo "[Peer]";
    echo "PublicKey = $serverPubKey";
    echo "AllowedIPs = 10.6.11.0/24";
    echo "Endpoint = $endpoint";
    echo "PersistentKeepalive = 15";
} >> /etc/wireguard/wg0.conf
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
systemctl status wg-quick@wg0
echo ""
echo "Run this on the server: "
echo "echo \"
[Peer]
PublicKey = $publicKey
AllowdIPs = 10.6.11.$lxcid/32; sudo systemctl restart wg-quick@wg0\" | sudo tee -a /etc/wireguard/wg0.conf"
echo "You can now login as $username."
