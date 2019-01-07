rm -rf vpsVIVO/

apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
rm -rf vpsVIVO/
cd;apt install -y git screen;
git clone https://github.com/coolblock/vpsVivo.git;
cd vpsVIVO
rm -rf /usr/local/bin/vivod
rm -rf /usr/local/bin/vivo-cli
./installNG.sh -p vivo -n 4 -c 1 -s -d -b
echo "To look at status of the masternode run:"
echo "/root/vpsVIVO/overAllMnStat.sh"
echo "in fact, I will run it in 20 seconds ..."
sleep 20
/root/vpsVIVO/overAllMnStat.sh
echo "The masternode will start and stop on its own, it is a service."
