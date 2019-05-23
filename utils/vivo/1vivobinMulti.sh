#!/bin/bash

# Variable for config file path
vpsVIVODefinitionFile=vpsVIVoDefs.txt

# Each masternode needs:
# - Index
# - Port
# - IP Address (Singular to begin)

mncount=0
index=0
initialise() {
    echo "Cleaning up existing vpsVIVO deployment"
	apt-get update -y
	apt-get install git -y
    rm -rf vpsVIVO/
	rm allowport.sh
    # This should be changed to ensure we are in a specific directory first.
	cd
}

deployPrereqs() {
    apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils screen git
}

getMasternodeCount() {
    echo "How many Vivo masternodes are you deploying? :"
    while :
        do
        echo -n "Masternode Count: "
        read mncount
        if [ $mncount -eq $mncount 2>/dev/null ] && [ "$mncount" -ge "1" ]
        then
            echo "$mncount Vivo Masternodes will be deployed."
		((mncount++))
             break
        else
            echo "$mncount is not valid"
		index=0
        fi
    done
}

getMasternodePrivKey() {
    #echo "Please enter masternode private key and copy it here:"
    while :
        do
        echo -n "Private Key for masternode $index: "
        read mnprivkey < /proc/self/fd/2
        if [ ! "$(echo -n $mnprivkey | wc -c)" = "51" ]
        then
            echo "Invalid masternode private key given, try again"
        else
	echo "masternodeprivkey=$mnprivkey" > pk_vivo_$index.txt
            break
        fi
    done
}
 

getMasternodePort() {
    declare -i port_num
    echo "Please enter masternode port for masternode $index:"
    while :
        do
        echo -n "port: "
        read mnport < /proc/self/fd/2

	if [ $mnport -eq $mnport 2>/dev/null ]

	then
		port_num=$((10#$mnport + 0))

                echo "portnum is:${port_num}"

		if (( $port_num < 1 || $port_num > 65535 )) ; then
			echo "*** ${mnport} is not a valid port try again"
		else
			echo "$mnport" > mnport_vivo_$index.txt
			echo "ufw allow $mnport" >> allowport.sh
                break
		fi



	else
		echo " not an integer"
	fi
    done
}

deployMasternodes() {
    # Some additional directory structure and management will be needed here
    # The RPC port will also need to be unique for each daemon

    git clone https://github.com/coolblock/vpsVivo.git
    cd vpsVivo
    ((mncount--))
    echo "masternodecount to deploy $mncount" > ~/masternodecount.txt
    ./installNG.sh -p vivo -n 4 -c $mncount -s -d -b
    echo "To look at status of the masternode run:"
    echo "/root/vpsVivo/overAllMnStat.sh"
    echo "The masternode will start and stop on its own, it is a service."
}

main() {
    initialise
    deployPrereqs
    getMasternodeCount
    # For number of masternodes do: # AND store in array with Index


for (( index=1; $index < $mncount; ++index)); do
    getMasternodePrivKey
    #getMasternodeIP
    getMasternodePort
done
	chmod +x allowport.sh
	./allowport.sh
	rm allowport.sh
    deployMasternodes
    # Done
}

main
