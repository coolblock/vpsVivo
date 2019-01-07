rm -rf vpsVIVO/

MNPK=
echo "Please enter masternode private key and copy it here:"
while :
do
	echo -n "MNPK: "
	read MNPK < /proc/self/fd/2
	if [ ! "$(echo -n $MNPK | wc -c)" = "51" ]
	then
		echo "Invalid masternode private key given, try again"
	else
		echo "OK"
		break
	fi
done

echo "masternode private key is $MNPK"

echo "masternodeprivkey=$MNPK" > pk_vivo_1.txt

apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
rm -rf vpsVIVO/
cd;apt install -y git screen;
git clone https://github.com/coolblock/vpsVivo.git;
cd vpsVIVO
./installNG.sh -p vivo -n 4 -c 1 -s -d -b
echo "To look at status of the masternode run:"
echo "/root/vpsVIVO/overAllMnStat.sh"
echo "in fact, I will run it in 20 seconds ..."
sleep 20
/root/vpsVIVO/overAllMnStat.sh
echo "The masternode will start and stop on its own, it is a service."
