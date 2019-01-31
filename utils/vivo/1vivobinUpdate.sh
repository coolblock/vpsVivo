rm -rf vpsVIVO/

apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
rm -rf vpsVivo/
cd;apt install -y git screen;
git clone https://github.com/coolblock/vpsVivo.git;
cd vpsVivo
rm -rf /usr/local/bin/vivod
rm -rf /usr/local/bin/vivo-cli
./installNG.sh -p vivo -n 4 -c 1 -s -d -b
echo "The masternode will start and stop on its own, it is a service."
echo "To look at status of the masternode run:"
echo "/root/vpsVivo/overAllMnStat.sh"
