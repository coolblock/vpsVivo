rm -rf vpsVIVO/

if [ $# -le 1 ]; then
    echo $0: usage: you have to give how many masternodes after
    exit 1
fi
apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
rm -rf vpsVivo/
cd;apt install -y git screen;
git clone https://github.com/coolblock/vpsVivo.git;
cd vpsVivo
rm -rf /usr/local/bin/vivod
rm -rf /usr/local/bin/vivo-cli
./installNG.sh -p vivo -n 4 -c $1 -s -d -b
echo "To look at status of the masternode run:"
echo "/root/vpsVivo/overAllMnStat.sh"
echo "in fact, I will run it in 20 seconds ..."
sleep 20
/root/vpsVivo/overAllMnStat.sh
echo "The masternode will start and stop on its own, it is a service."
