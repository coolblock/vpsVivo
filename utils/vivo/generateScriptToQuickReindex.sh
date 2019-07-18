#!/bin/bash

# Each masternode needs:
# - Index

typeset -i mncount=0
index=0

getMasternodeCount() {
	echo "++++++++++++++++"
	echo "There seems to be a total masternodes of:"
	rm -f totalmasternodes*
	ls /root/masternode_conf_files/vivo_* | wc -l > totalmasternodes
	mncount=$(cat totalmasternodes)
	echo "total masternodes to consider $mncount"
	mncount=mncount+1
}

insertLine() {

        echo "echo \"--------- vivo${index}\"" >> /root/quickReindexAllMasternodes.sh

        echo "echo \"stage 1\"" >> /root/quickReindexAllMasternodes.sh
        echo "cd" >> /root/quickReindexAllMasternodes.sh
        echo "/usr/local/bin/vivo-cli -conf=/etc/masternodes/vivo_n${index}.conf invalidateblock 0000000096841a061fa7f61cf836a6d2d857b68f7a8d60785e0078444feccb6b" >> /root/quickReindexAllMasternodes.sh
        echo "echo \"stage 2\"" >> /root/quickReindexAllMasternodes.sh
        echo "mnTroubleshoot/vivo/vivo${index}_stopService.sh" >> /root/quickReindexAllMasternodes.sh
        echo "echo \"stage 3\"" >> /root/quickReindexAllMasternodes.sh
        echo "sleep 10" >> /root/quickReindexAllMasternodes.sh
        echo "echo \"stage 4\"" >> /root/quickReindexAllMasternodes.sh
        echo "mnTroubleshoot/vivo/vivo${index}_startService.sh" >> /root/quickReindexAllMasternodes.sh
        echo "echo \"stage 6\"" >> /root/quickReindexAllMasternodes.sh
        echo "sleep 200" >> /root/quickReindexAllMasternodes.sh
        echo "echo \"stage 7\"" >> /root/quickReindexAllMasternodes.sh
        echo "/usr/local/bin/vivo-cli -conf=/etc/masternodes/vivo_n${index}.conf reconsiderblock 0000000096841a061fa7f61cf836a6d2d857b68f7a8d60785e0078444feccb6b" >> /root/quickReindexAllMasternodes.sh
        echo "echo \"stage 8 done\"" >> /root/quickReindexAllMasternodes.sh
        echo "included vivo${index}"


}

main() {
    echo "-------------------------------"

	if [ -f /root/quickReindexAllMasternodes.sh ]; then
		rm -f /root/quickReindexAllMasternodes.sh
		echo "Cleared old File"
	fi
	
	getMasternodeCount

for (( index=1; $index < $mncount; ++index)); do
    insertLine	
done
rm totalmasternodes

}

main
