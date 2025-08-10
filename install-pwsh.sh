apt update
apt install -y wget apt-transport-https software-properties-common
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
dpkg -i packages-microsoft-prod.deb
apt update
apt install -y powershell
