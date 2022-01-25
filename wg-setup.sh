#! /bin/bash
if [ "$(whoami)" != "root" ]; then
    echo Please run with root privileges.
    exit 1
fi

echo -n "Server public key: "
read -r serverPubKey
echo -n "LXC id: "
read -r lxcid
echo -n "Endpoint (IP:Port): "
read -r endpoint

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
