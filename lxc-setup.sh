#! /bin/bash
if [ "$(whoami)" != "root" ]; then
    echo Please run with root privileges.
    exit 1
fi

# input
if [ $# -lt 2 ]; then
    echo ""
    echo -n "Username: "
    read -r username
    echo ""
    echo -n "Password: "
    read -rs password
    echo ""
else
    username=$1
    password=$2
fi
echo -n "Server public key: "
read -r serverPubKey
echo -n "LXC id: "
read -r lxcid
echo -n "Endpoint (IP:Port): "
read -r endpoint

# update/install packages
apt update -y;
apt upgrade -y;
apt install vim tmux wireguard git zsh curl -y;

# add a new user

useradd "$username" -s /usr/bin/zsh -m;
usermod -aG sudo "$username"
echo "$username":"$password" | chpasswd;

# setting zsh for the user
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

# setting up wireguard
sh -c 'umask 077; touch /etc/wireguard/wg0.conf'
cd /etc/wireguard/ || exit
umask 077; wg genkey | tee privatekey | wg pubkey > publickey
privateKey=$(cat privatekey)
publicKey=$(cat publickey)
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
echo "**************************************"
echo "Run the following on the server: "
echo "echo \"
[Peer]
PublicKey = $publicKey
AllowedIPs = 10.6.11.$lxcid/32\"
| sudo tee -a /etc/wireguard/wg0.conf
sudo systemctl restart wg-quick@wg0"
echo "**************************************"
echo "You can now login as $username."
