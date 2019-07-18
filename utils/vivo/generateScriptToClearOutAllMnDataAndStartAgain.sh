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
        echo "echo \"vivo${index}\"" >> /root/clearAllMasternodes.sh
        echo "/root/mnTroubleshoot/vivo/vivo${index}_clear_out_data_restart_with_blank_data.sh" >> /root/clearAllMasternodes.sh
        echo "included vivo${index}"
}

main() {
    echo "-------------------------------"

	if [ -f /root/clearAllMasternodes.sh ]; then
		rm -f /root/clearAllMasternodes.sh
		echo "Cleared old File"
	fi
	
	getMasternodeCount

for (( index=1; $index < $mncount; ++index)); do
    insertLine	
done
rm totalmasternodes

}

main
