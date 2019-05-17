#!/bin/bash
cd
mkdir /root/vivomisc
cd /root/vivomisc
rm -f minver*
rm -f curver*

wget https://raw.githubusercontent.com/vivocoin/centralstrings/master/minver
/root/mnTroubleshoot/vivo/vivo1_getInfo.sh | grep "\"version"| cut -d: -f2 | cut -d" " -f2 | cut -d"," -f1 > curver

typeset -i currentVersion=$(cat curver)
typeset -i minimumVersion=$(cat minver)

if [ "$currentVersion" -lt "$minimumVersion" ] ; then
	echo "needs updating"
	bash <(curl -s https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/UpdateAutomaticMnBinMulti.sh)
else
	echo "is updated -no change is necessary"
fi

cd




