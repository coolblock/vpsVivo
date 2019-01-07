echo "Will build from Source"

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

rm -rf vpsVIVO/
cd;apt install -y git screen;git clone https://github.com/coolblock/vpsVIVO.git;screen -dmS new_screen bash;sleep 5;screen -S new_screen -p 0 -X exec /root/vpsVIVO/coinMnInstall.sh vivo 1
echo "Process is just starting... Will take 15 minutes and will reboot. You will be disconnected then. If you need to see it run in the background you can type in: screen -r"