#!/bin/bash
#  ███╗   ██╗ ██████╗ ██████╗ ███████╗███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗ 
#  ████╗  ██║██╔═══██╗██╔══██╗██╔════╝████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
#  ██╔██╗ ██║██║   ██║██║  ██║█████╗  ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
#  ██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
#  ██║ ╚████║╚██████╔╝██████╔╝███████╗██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
#  ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
#                                                              ╚╗ @marsmensch 2016-2017 ╔╝                   				
#                   
# version 	v0.9.1
# date    	2018-02-02
#
# function:	part of the masternode scripts, source the proper config file
#                                                                      
# 	Instructions:
#               Run this script w/ the desired parameters. Leave blank or use -h for help.
#
#	Platforms: 	
#               - Linux Ubuntu 16.04 LTS ONLY on a Vultr, Hetzner or DigitalOcean VPS
#               - Generic Ubuntu support will be added at a later point in time
#
# Twitter 	@marsmensch

# Useful variables
declare -r CRYPTOS=`ls -l config/ | egrep '^d' | awk '{print $9}' | xargs echo -n; echo`
declare -r DATE_STAMP="$(date +%y-%m-%d-%s)"
declare -r SCRIPTPATH=$( cd $(dirname ${BASH_SOURCE[0]}) > /dev/null; pwd -P )
declare -r MASTERPATH="$(dirname "${SCRIPTPATH}")"
declare -r SCRIPT_VERSION="v0.9.1"
declare -r SCRIPT_LOGFILE="/tmp/nodemaster_${DATE_STAMP}_out.log"
declare -r IPV4_DOC_LINK="https://www.vultr.com/docs/add-secondary-ipv4-address"
declare -r DO_NET_CONF="/etc/network/interfaces.d/50-cloud-init.cfg"

function showbanner() {
cat << "EOF"
 ███╗   ██╗ ██████╗ ██████╗ ███████╗███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗ 
 ████╗  ██║██╔═══██╗██╔══██╗██╔════╝████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
 ██╔██╗ ██║██║   ██║██║  ██║█████╗  ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
 ██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
 ██║ ╚████║╚██████╔╝██████╔╝███████╗██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
 ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
                                                             ╚╗ @marsmensch 2016-2018 ╔╝                   				
EOF
}

# /*
# confirmation message as optional parameter, asks for confirmation
# get_confirmation && COMMAND_TO_RUN or prepend a message
# */
# 
function get_confirmation() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

#
# /* no parameters, displays the help message */
#
function show_help(){
    clear
    showbanner
    echo "install.sh, version $SCRIPT_VERSION";
    echo "Usage example:";
    echo "install.sh (-p|--project) string [(-h|--help)] [(-n|--net) int] [(-c|--count) int] [(-r|--release) string] [(-w|--wipe)] [(-u|--update)]";
    echo "Options:";
    echo "-h or --help: Displays this information.";
    echo "-p or --project string: Project to be installed. REQUIRED.";
    echo "-n or --net: IP address type t be used (4 vs. 6).";
    echo "-c or --count: Number of masternodes to be installed.";
    echo "-r or --release: Release version to be installed.";
    echo "-s or --sentinel: Add sentinel monitoring for a node type. Combine with the -p option";    
    echo "-w or --wipe: Wipe ALL local data for a node type. Combine with the -p option";
    echo "-u or --update: Update a specific masternode daemon. Combine with the -p option";
    echo "-r or --release: Release version to be installed.";    
    exit 1;
}

#
# /* no parameters, checks if we are running on a supported Ubuntu release */
#
function check_distro() {
	# currently only for Ubuntu 16.04
	if [[ -r /etc/os-release ]]; then
		. /etc/os-release
		if [[ "${VERSION_ID}" < "16.04" ]]; then
			echo "This script only supports ubuntu 16.04 and above LTS, exiting."
			exit 1
		fi
	else
		# unfortunately 
		echo "This script only supports ubuntu 16.04 and above LTS, exiting."	
		exit 1
	fi
}

#
# /* no parameters, installs the base set of packages that are required for all projects */
#
function install_packages() {
	# development and build packages
	# these are common on all cryptos
	echo "* Package installation!"
	apt-get -qq -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true update
	apt-get -qqy -o=Dpkg::Use-Pty=0 -o=Acquire::ForceIPv4=true install build-essential g++ \
	protobuf-compiler libboost-all-dev autotools-dev \
    automake libcurl4-openssl-dev libboost-all-dev libssl-dev libdb++-dev \
    make autoconf automake libtool git apt-utils libprotobuf-dev pkg-config \
    libcurl3-dev libudev-dev libqrencode-dev bsdmainutils pkg-config libssl-dev \
    libgmp3-dev libevent-dev jp2a pv virtualenv	&>> ${SCRIPT_LOGFILE}
}

#
# /* no parameters, creates and activates a swapfile since VPS servers often do not have enough RAM for compilation */
#
function swaphack() { 
#check if swap is available
if [ $(free | awk '/^Swap:/ {exit !$2}') ] || [ ! -f "/var/mnode_swap.img" ];then
	echo "* No proper swap, creating it" 
	# needed because ant servers are ants
	rm -f /var/mnode_swap.img
	dd if=/dev/zero of=/var/mnode_swap.img bs=2048k count=${MNODE_SWAPSIZE} &>> ${SCRIPT_LOGFILE}
	chmod 0600 /var/mnode_swap.img 
	mkswap /var/mnode_swap.img &>> ${SCRIPT_LOGFILE}
	swapon /var/mnode_swap.img &>> ${SCRIPT_LOGFILE} 
	echo '/var/mnode_swap.img none swap sw 0 0' | tee -a /etc/fstab &>> ${SCRIPT_LOGFILE}
	echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf               &>> ${SCRIPT_LOGFILE}
	echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf		&>> ${SCRIPT_LOGFILE}
else
	echo "* All good, we have a swap"	
fi
}

#
# /* no parameters, creates and activates a dedicated masternode user */
#
function create_mn_user() {

    # our new mnode unpriv user acc is added 
    if id "${MNODE_USER}" >/dev/null 2>&1; then
        echo "user exists already, do nothing" &>> ${SCRIPT_LOGFILE}
    else
        echo "Adding new system user ${MNODE_USER}"
        adduser --disabled-password --gecos "" ${MNODE_USER} &>> ${SCRIPT_LOGFILE}
    fi
    
}

#
# /* no parameters, creates a masternode data directory (one per masternode)  */
#
function create_mn_dirs() {

    # individual data dirs for now to avoid problems
    echo "* Creating masternode directories"
    mkdir -p ${MNODE_CONF_BASE}
	for NUM in $(seq 1 ${count}); do
	    if [ ! -d "${MNODE_DATA_BASE}/${CODENAME}${NUM}" ]; then
	         echo "creating data directory ${MNODE_DATA_BASE}/${CODENAME}${NUM}" &>> ${SCRIPT_LOGFILE}
             mkdir -p ${MNODE_DATA_BASE}/${CODENAME}${NUM} &>> ${SCRIPT_LOGFILE}
        fi
	done    

}
function remove_sentinel_setup_for_coin() {

	cd /usr/share                                               &>> ${SCRIPT_LOGFILE}
	rm -rf sentinel_${CODENAME}
	rm -rf /usr/share/sentinelvenv_${CODENAME}

    #rm -f /root/runmultipleSentinel${CODENAME}.sh
	rm -rf /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_runSentinelToSeeOutput.sh					
	rm -rf /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_goToWhereSentinelConfsAre.sh
	rm -rf /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_goToWhereDataFilesAre.sh
	rm -rf /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_editSentinelConf.sh
	rm /root/runsentinelnolog${CODENAME}${NUM}.sh	
	for NUM in $(seq 1 ${count}); do
		sed -i "s_${CODENAME}${NUM}/sentinel.conf_d" root/runmultipleSentinel${CODENAME}.sh
	done	
}
#
# /* no parameters, creates a sentinel config for a set of masternodes (one per masternode)  */
#
function create_sentinel_setup() {

	# if code directory does not exists, we create it clone the src
	#if [ ! -d /usr/share/sentinel ]; then

cd /usr/share                                               &>> ${SCRIPT_LOGFILE}
#rm -rf sentinel
rm -rf sentinel_${CODENAME}
git clone ${SENTINEL_URL} sentinel_${CODENAME} &>> ${SCRIPT_LOGFILE}
cd sentinel_${CODENAME}                                                 &>> ${SCRIPT_LOGFILE}
rm -f rm sentinel.conf                                      &>> ${SCRIPT_LOGFILE}


	#else
	#	echo "* Updating the existing sentinel GIT repo"
	#		cd /usr/share/sentinel        &>> ${SCRIPT_LOGFILE}
	#		git pull                      &>> ${SCRIPT_LOGFILE}
	#		rm -f rm sentinel.conf        &>> ${SCRIPT_LOGFILE}
	#	fi
	
    # create a globally accessible venv and install sentinel requirements
	
	
	
	
    cd /usr/share/sentinel_${CODENAME}
    virtualenv --system-site-packages /usr/share/sentinelvenv_${CODENAME}      &>> ${SCRIPT_LOGFILE}
    /usr/share/sentinelvenv_${CODENAME}/bin/pip install -r requirements.txt    &>> ${SCRIPT_LOGFILE}
    
    rm -f /root/runmultipleSentinel${CODENAME}.sh
	
    mkdir /root/mnTroubleshoot
	mkdir /root/mnTroubleshoot/${CODENAME}/
	

    # create one sentinel config file per masternode
	for NUM in $(seq 1 ${count}); do
	    if [ ! -f "/usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf" ]; then
	         echo "* Creating sentinel configuration for ${CODENAME} masternode number ${NUM}" &>> ${SCRIPT_LOGFILE}  
	     mkdir /usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}
	     mkdir /home/masternode/database/
		 mkdir /home/masternode/database/${CODENAME}
             mkdir /home/masternode/database/${CODENAME}/${CODENAME}_${NUM}
	     echo "${CODENAME}_conf=${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf"   > /usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf
             echo "network=mainnet"                                         >> /usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf
             echo "db_name=/home/masternode/database/${CODENAME}/${CODENAME}_${NUM}/sentinel.db"         >> /usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf
             echo "db_driver=sqlite"                                        >> /usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf     
	     echo "/sbin/runuser -l masternode -c 'export SENTINEL_CONFIG=/usr/share/sentinel_${CODENAME}//${CODENAME}${NUM}/sentinel.conf; /usr/share/sentinelvenv_${CODENAME}//bin/python /usr/share/sentinel_${CODENAME}/bin/sentinel.py 2>&1 >> /var/log/sentinel_${CODENAME}/sentinel-cron.log'" >> /root/runmultipleSentinel${CODENAME}.sh
	     echo "/sbin/runuser -l masternode -c 'export SENTINEL_CONFIG=/usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf; /usr/share/sentinelvenv_${CODENAME}/bin/python /usr/share/sentinel_${CODENAME}/bin/sentinel.py'" > ~/runsentinelnolog${CODENAME}${NUM}.sh
         chmod +x ~/runsentinelnolog${CODENAME}${NUM}.sh
		 
		if grep -Fxq "/root/runmultipleSentinel${CODENAME}.sh" /root/runmultipleSentinel.sh ; then
			echo "IT DOES EXIST"
		else
			echo "NO NO IT DOES NO EXIST"
			echo "/root/runmultipleSentinel${CODENAME}.sh" >> /root/runmultipleSentinel.sh			
		fi  
	
	ln -s /usr/share/sentinel_${CODENAME}/${CODENAME}${NUM} /root/sentinel_directories/${CODENAME}${NUM}
	
	mkdir /var/log/sentinel_${CODENAME}
	echo "rm -rf /var/log/sentinel_${CODENAME}" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_remove_sentinel_files.sh		

	echo "/sbin/runuser -l masternode -c 'export SENTINEL_CONFIG=/usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf; /usr/share/sentinelvenv_${CODENAME}/bin/python /usr/share/sentinel_${CODENAME}/bin/sentinel.py'" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_runSentinelToSeeOutput.sh					

	echo "cd /usr/share/sentinel_${CODENAME}/;exec bash" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_goToWhereSentinelConfsAre.sh
	echo "cd /var/lib/masternodes/${CODENAME}${NUM};exec bash" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_goToWhereDataFilesAre.sh
	echo "nano /usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}_sentinel.conf" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_editSentinelConf.sh

        fi
		
	done 
	
	mkdir /root/sentinel_directories
	ln -s /home/masternode/database/ /root/sentinel_directories/data_directories
	ln -s /home/masternode/database/ /root/masternode_sentinel_data_directories
	
    echo "Generated a Sentinel config for you. To activate Sentinel run"
    
    echo "/sbin/runuser -l masternode -c 'export SENTINEL_CONFIG=/usr/share/sentinel_${CODENAME}/${CODENAME}${NUM}/sentinel.conf; /usr/share/sentinelvenv_${CODENAME}/bin/python /usr/share/sentinel_${CODENAME}/bin/sentinel.py 2>&1 >> /var/log/sentinel_${CODENAME}/sentinel-cron.log'"
    chmod +x /root/runmultipleSentinel${CODENAME}.sh
	chmod +x /root/runmultipleSentinel.sh
	
    chown -R masternode:masternode /home/masternode/
    chown -R masternode:masternode /usr/share/sentinel
    chown -R masternode:masternode /usr/share/sentinelvenv
	if ! crontab -l | grep "/root/runmultipleSentinel.sh"; then
		(crontab -l 2>/dev/null; echo "* * * * * /root/runmultipleSentinel.sh") | crontab -
	fi
    	
}

#
# /* no parameters, creates a minimal set of firewall rules that allows INBOUND masternode p2p & SSH ports */
#
function configure_firewall() {

    echo "* Configuring firewall rules"
	# disallow everything except ssh and masternode inbound ports
	ufw default deny                          &>> ${SCRIPT_LOGFILE}
	ufw logging on                            &>> ${SCRIPT_LOGFILE}
	ufw allow ${SSH_INBOUND_PORT}/tcp         &>> ${SCRIPT_LOGFILE}
	# KISS, its always the same port for all interfaces
	ufw allow ${MNODE_INBOUND_PORT}/tcp       &>> ${SCRIPT_LOGFILE}
	# This will only allow 6 connections every 30 seconds from the same IP address.
	ufw limit OpenSSH	                      &>> ${SCRIPT_LOGFILE}
	ufw --force enable                        &>> ${SCRIPT_LOGFILE}
	echo "* Firewall ufw is active and enabled on system startup"

}

#
# /* no parameters, checks if the choice of networking matches w/ this VPS installation */
#
function validate_netchoice() {

    echo "* Validating network rules"		

	# break here of net isn't 4 or 6 
	if [ ${net} -ne 4 ] && [ ${net} -ne 6 ]; then
		echo "invalid NETWORK setting, can only be 4 or 6!"
		exit 1;
	fi 

	# generate the required ipv6 config
	if [ "${net}" -eq 4 ]; then
	    IPV6_INT_BASE="#NEW_IPv4_ADDRESS_FOR_MASTERNODE_NUMBER"
	    NETWORK_BASE_TAG=""
        echo "IPv4 address generation needs to be done manually atm!"  &>> ${SCRIPT_LOGFILE}
	fi	# end ifneteq4		    

}

#
# /* no parameters, generates one masternode configuration file per masternode in the default
#    directory (eg. /etc/masternodes/${CODENAME} and replaces the existing placeholders if possible */
# 
function create_mn_configuration() {
    
        # always return to the script root
        cd ${SCRIPTPATH}

	mkdir /root/mnTroubleshoot
	mkdir /root/mnTroubleshoot/${CODENAME}
	
        
        # create one config file per masternode
        for NUM in $(seq 1 ${count}); do
        PASS=$(date | md5sum | cut -c1-24)

			# we dont want to overwrite an existing config file
			if [ ! -f ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf ]; then
                echo "individual masternode config doesn't exist, generate it!"                  &>> ${SCRIPT_LOGFILE}

				# if a template exists, use this instead of the default
				if [ -e config/${CODENAME}/${CODENAME}.conf ]; then
					echo "custom configuration template for ${CODENAME} found, use this instead"                      &>> ${SCRIPT_LOGFILE}
					cp ${SCRIPTPATH}/config/${CODENAME}/${CODENAME}.conf ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf  &>> ${SCRIPT_LOGFILE}
				else
					echo "No ${CODENAME} template found, using the default configuration template"			          &>> ${SCRIPT_LOGFILE}
					cp ${SCRIPTPATH}/config/default.conf ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf                  &>> ${SCRIPT_LOGFILE}
				fi
				# replace placeholders
				echo "running sed on file ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf"                                &>> ${SCRIPT_LOGFILE}
				sed -e "s/XXX_GIT_PROJECT_XXX/${CODENAME}/" -e "s/XXX_NUM_XXY/${NUM}]/" -e "s/XXX_NUM_XXX/${NUM}/" -e "s/XXX_PASS_XXX/${PASS}/" -e "s/XXX_IPV6_INT_BASE_XXX/[${IPV6_INT_BASE}/" -e "s/XXX_NETWORK_BASE_TAG_XXX/${NETWORK_BASE_TAG}/" -e "s/XXX_MNODE_INBOUND_PORT_XXX/${MNODE_INBOUND_PORT}/" -i ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf				   
 				# insert privatekey
						
				sed -i 's/masternodeprivkey/\#masternodeprivkey/g'  ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf

				echo " " >> ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf
				cat /root/pk_${CODENAME}_${NUM}.txt >> ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf
				echo -e "\r\n" >> ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf
				
				sed -i 's/rpcport/\#rpcport/g'  ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf				
				sed -i 's/bind/\#bind/g'  ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf
				
				if [ ! -f /root/lastRpcPort ]; then
					echo "5566" > /root/lastRpcPort
				fi

				typeset -i RPC_PORT=$(cat /root/lastRpcPort)
				echo $RPC_PORT
				RPC_PORT=$RPC_PORT+1
				echo $RPC_PORT > /root/lastRpcPort
				echo -e "rpcport=${RPC_PORT}\n"  >> ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf
				
                cat /root/ip4_${NUM}.txt|tr -d "\n" >> ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf
				echo ":${MNODE_INBOUND_PORT}"  >> ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf

				if [[ -z ${COIN_MASTERNODE_REPLACEMENT_STRING} ]]; then
					echo "masternode will be used as masternode"
				else
					echo "masternode will be replaced with ${COIN_MASTERNODE_REPLACEMENT_STRING}" &>> ${SCRIPT_LOGFILE}
					sed -i "s/masternode/${COIN_MASTERNODE_REPLACEMENT_STRING}/g" ${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf
				fi	


			fi        			
		
		echo "/root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_stopService.sh;/sbin/runuser -l masternode -c '/usr/local/bin/${CODENAME}d -reindex -pid=/var/lib/masternodes/${CODENAME}${NUM}/${CODENAME}.pid -conf=/etc/masternodes/${CODENAME}_n${NUM}.conf -datadir=/var/lib/masternodes/${CODENAME}${NUM}'" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_reindex.sh

		echo "/root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_stopService.sh;/sbin/runuser -l masternode -c '/usr/local/bin/${CODENAME}d -deamon -pid=/var/lib/masternodes/${CODENAME}${NUM}/${CODENAME}.pid -conf=/etc/masternodes/${CODENAME}_n${NUM}.conf -datadir=/var/lib/masternodes/${CODENAME}${NUM}'" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_restartWithoutService.sh
		
		echo "/usr/local/bin/${CODENAME}-cli -conf=/etc/masternodes/${CODENAME}_n${NUM}.conf getinfo" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_getInfo.sh
		echo "/usr/local/bin/${CODENAME}-cli -conf=/etc/masternodes/${CODENAME}_n${NUM}.conf masternode status" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_masternode_status.sh		

		echo "/usr/local/bin/${CODENAME}-cli -conf=/etc/masternodes/${CODENAME}_n${NUM}.conf mnsync status" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_masternode_sync_status.sh		
		echo "/usr/local/bin/${CODENAME}-cli -conf=/etc/masternodes/${CODENAME}_n${NUM}.conf masternode debug" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_masternode_debug.sh		

		
		echo "tail -f /var/lib/masternodes/${CODENAME}${NUM}/db.log" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_tail_the_db_log_file.sh				
		echo "tail -f /var/lib/masternodes/${CODENAME}${NUM}/db.log" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_tail_the_debug_log_file.sh				
		

		echo "tail -f /var/lib/masternodes/${CODENAME}${NUM}/db.log" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_tail_the_debug_log_file.sh				
		  
 	
		echo "service ${CODENAME}_n${NUM} status" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_statusOfService.sh			
		echo "service ${CODENAME}_n${NUM} stop" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_stopService.sh			
		echo "service ${CODENAME}_n${NUM} start" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_startService.sh			

		echo "cd ${SYSTEMD_CONF}/;exec bash" > /root/mnTroubleshoot/${CODENAME}_goToWhereServiceFilesAre.sh
		echo "ls ${SYSTEMD_CONF}/${CODENAME}*;exec bash" > /root/mnTroubleshoot/${CODENAME}_listServiceFiles.sh		

		echo "cd /usr/local/bin/;exec bash" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_goToWhereMasternodeExecutablesAre.sh
		echo "cd /var/lib/masternodes/${CODENAME}${NUM};exec bash" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_goToWhereDataFilesAre.sh
		echo "cd /etc/masternodes/;exec bash" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_goToWhereMasternodeConfFilesAre.sh
	
		echo "rm -f /usr/local/bin/${CODENAME}d" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_remove_executable.sh	
		echo "rm -rf /var/lib/masternodes/${CODENAME}${NUM}" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_remove_data_files.sh		
		echo "rm -f /etc/masternodes/${CODENAME}_n${NUM}.conf" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_remove_conf.sh		

		#get block count from explorer if in environment	
		if [[ -z ${COIN_EXPLORER_BLOCKCOUNT} ]]; then
			echo "no explorer block count available"
		else
			echo "(wget -q -O - $COIN_EXPLORER_BLOCKCOUNT)" > /root/mnTroubleshoot/${CODENAME}_getBlockCountFromExplorer.sh	
		fi	

		
	
		echo "rm -f /etc/masternodes/${CODENAME}_n${NUM}.conf" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_removeMasternodeConfFile.sh	
		echo "nano /etc/masternodes/${CODENAME}_n${NUM}.conf" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_editMasternodeConfFile.sh
		echo "nano ${SYSTEMD_CONF}/${CODENAME}_n${NUM}.service" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_editMasternodeServiceFile.sh
		
		echo "service ${CODENAME}_n${NUM} stop;cd /var/lib/masternodes/${CODENAME}${NUM};rm -rf chainstate;rm -rf blocks;rm netfulfilled.dat;rm banlist.dat;rm fee_estimates.dat;rm mncache.dat;rm peers.dat;rm governance.dat;rm mnpayments.dat;service ${CODENAME}_n${NUM} start" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_clear_out_data_restart_with_blank_data.sh

		echo "journalctl -u ${CODENAME}_n${NUM}.service -b" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_print_logs_of_service_of_current_boot.sh
		echo "journalctl -u ${CODENAME}_n${NUM}.service" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_print_logs_of_service_of_current_boot.sh		

		echo "netstat -plnt | grep "Program name"; netstat -plnt | grep ${CODENAME}" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_listening_on_what_ports.sh
		
        done

		echo "netstat -plnt | grep "Program name"; netstat -plnt | grep ${CODENAME}" > /root/mnTroubleshoot/${CODENAME}/${CODENAME}${NUM}_listening_on_what_ports.sh
		
		echo "chown -R masternode:masternode /home/masternode/" >> /root/mnTroubleshoot/fix_ownership_on_all.sh
		echo "chown -R masternode:masternode /usr/share/sentinel*" >> /root/mnTroubleshoot/fix_ownership_on_all.sh
		echo "chown -R masternode:masternode /usr/share/sentinelvenv*" >> /root/mnTroubleshoot/fix_ownership_on_all.sh
		echo "chown -R masternode:masternode /usr/local/bin/" >> /root/mnTroubleshoot/fix_ownership_on_all.sh
		echo "chown -R masternode:masternode /var/lib/masternodes/" >> /root/mnTroubleshoot/fix_ownership_on_all.sh
		echo "chown -R masternode:masternode /etc/masternodes/" >> /root/mnTroubleshoot/fix_ownership_on_all.sh
				
		chmod +x /root/mnTroubleshoot/fix_ownership_on_all.sh
		/root/mnTroubleshoot/fix_ownership_on_all.sh
		
		ln -s /usr/local/bin/ /root/masternode_executables
		ln -s /etc/masternodes/ /root/masternode_conf_files
		ln -s /var/lib/masternodes/ /root/masternode_data_directories

}

#
# /* no parameters, generates a masternode configuration file per masternode in the default */
# 
function create_control_configuration() {

    # delete any old stuff that's still around
    rm -f /tmp/${CODENAME}_masternode.conf &>> ${SCRIPT_LOGFILE}
	# create one line per masternode with the data we have
	for NUM in $(seq 1 ${count}); do
		cat >> /tmp/${CODENAME}_masternode.conf <<-EOF
			${CODENAME}MN${NUM} [${IPV6_INT_BASE}:${NETWORK_BASE_TAG}::${NUM}]:${MNODE_INBOUND_PORT} MASTERNODE_PRIVKEY_FOR_${CODENAME}MN${NUM} COLLATERAL_TX_FOR_${CODENAME}MN${NUM} OUTPUT_NO_FOR_${CODENAME}MN${NUM}	
		EOF
	done

}

#
# /* no parameters, generates a a pre-populated masternode systemd config file */
# 
function create_systemd_configuration() {

    echo "* (over)writing systemd config files for masternodes"
	# create one config file per masternode
	for NUM in $(seq 1 ${count}); do
	PASS=$(date | md5sum | cut -c1-24)
		echo "* (over)writing systemd config file ${SYSTEMD_CONF}/${CODENAME}_n${NUM}.service"  &>> ${SCRIPT_LOGFILE}
		cat > ${SYSTEMD_CONF}/${CODENAME}_n${NUM}.service <<-EOF
			[Unit]
			Description=${CODENAME} distributed currency daemon
			After=network.target
                 
			[Service]
			User=${MNODE_USER}
			Group=${MNODE_USER}
         	
			Type=forking
			PIDFile=${MNODE_DATA_BASE}/${CODENAME}${NUM}/${CODENAME}.pid
			ExecStart=${MNODE_DAEMON} -daemon -pid=${MNODE_DATA_BASE}/${CODENAME}${NUM}/${CODENAME}.pid \
			-conf=${MNODE_CONF_BASE}/${CODENAME}_n${NUM}.conf -datadir=${MNODE_DATA_BASE}/${CODENAME}${NUM}
       		 
			Restart=always
			RestartSec=70
			PrivateTmp=true
			TimeoutStopSec=60s
			TimeoutStartSec=5s
			StartLimitInterval=120s
			StartLimitBurst=15
         	
			[Install]
			WantedBy=multi-user.target			
		EOF
	done

}

#
# /* set all permissions to the masternode user */
# 
function set_permissions() {

	# maybe add a sudoers entry later
	chown -R ${MNODE_USER}:${MNODE_USER} ${MNODE_CONF_BASE} ${MNODE_DATA_BASE} /var/log/sentinel* &>> ${SCRIPT_LOGFILE}	

}

#
# /* wipe all files and folders generated by the script for a specific project */
# 
function wipe_all() {
    
    echo "Deleting all ${project} related data!" 
	rm -f /etc/masternodes/${project}_n*.conf 
	rmdir --ignore-fail-on-non-empty -p /var/lib/masternodes/${project}*
	rm -f /etc/systemd/system/${project}_n*.service
	rm -f ${MNODE_DAEMON}
	echo "DONE!"
	exit 0

}

#
# /*
# remove packages and stuff we don't need anymore and set some recommended
# kernel parameters
# */
# 
function cleanup_after() {

	apt-get -qqy -o=Dpkg::Use-Pty=0 --force-yes autoremove
	apt-get -qqy -o=Dpkg::Use-Pty=0 --force-yes autoclean

	echo "kernel.randomize_va_space=1" > /etc/sysctl.conf  &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.conf.all.accept_source_route=0" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.conf.all.log_martians=1" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.conf.default.log_martians=1" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv6.conf.all.accept_redirects=0" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.conf.all.send_redirects=0" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "kernel.sysrq=0" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.tcp_timestamps=0" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE} 
	echo "net.ipv4.icmp_ignore_bogus_error_responses=1" >> /etc/sysctl.conf &>> ${SCRIPT_LOGFILE}
	sysctl -p
	
}

#
# /* project as parameter, sources the project specific parameters and runs the main logic */
# 

# source the default and desired crypto configuration files
function source_config() {

    SETUP_CONF_FILE="${SCRIPTPATH}/config/${project}/${project}.env" 
    #SENTINEL_URL=https://github.com/vivocoin/sentinel.git

    # first things first, to break early if things are missing or weird
    check_distro
        
	if [ -f ${SETUP_CONF_FILE} ]; then
		echo "Script version ${SCRIPT_VERSION}, you picked: ${project}"
		echo "apply config file for ${project}"	&>> ${SCRIPT_LOGFILE}	
		source "${SETUP_CONF_FILE}"

		# count is from the default config but can ultimately be
		# overwritten at runtime
		if [ -z "${count}" ]
		then
			count=${SETUP_MNODES_COUNT}
			echo "No number given, installing default number of nodes: ${SETUP_MNODES_COUNT}" &>> ${SCRIPT_LOGFILE}
		fi

		# release is from the default project config but can ultimately be
		# overwritten at runtime
		if [ -z "$release" ]
		then
			release=${SCVERSION}
			echo "release empty, setting to project default: ${SCVERSION}"  &>> ${SCRIPT_LOGFILE}
		fi

		# net is from the default config but can ultimately be
		# overwritten at runtime
		if [ -z "${net}" ]; then
			net=${NETWORK_TYPE}
			echo "net EMPTY, setting to default: ${NETWORK_TYPE}" &>> ${SCRIPT_LOGFILE}
		fi			 			

		# main block of function logic starts here
	    # if update flag was given, delete the old daemon binary first & proceed
		if [ "$update" -eq 1 ]; then
			echo "update given, deleting the old daemon NOW!" &>> ${SCRIPT_LOGFILE}
			rm -f ${MNODE_DAEMON}  	 
		fi

		echo "************************* Installation Plan *****************************************"
		echo ""
		echo "I am going to install and configure "
        echo "=> ${count} ${project} masternode(s) in version ${SCVERSION} "
        echo "for you now."
        echo ""
		echo "You have to add your masternode private key to the individual config files afterwards"
		echo ""
		echo "Stay tuned!"
        echo ""
		# show a hint for MANUAL IPv4 configuration
		if [ "${net}" -eq 4 ]; then
			NETWORK_TYPE=4
			
			echo "See the following link for instructions how to add multiple ipv4 addresses on vultr:"
			echo "${IPV4_DOC_LINK}"
			if [ ! -f /root/ip4_1.txt ]; then
				ipvariable=$(wget http://ipecho.net/plain -O - -q);
				echo "bind=$ipvariable" > /root/ip4_1.txt
				echo "Will be using {$ipvariable} as your IP. If you want to change them you will have to go to etc/masternodes and change the conf file."
			fi

		fi        
		# sentinel setup 
		if [ "$sentinel" -eq 1 ]; then
			
			echo "I will also generate a Sentinel configuration for you." 	 
		fi	
		echo ""
		echo "A logfile for this run can be found at the following location:"
		echo "${SCRIPT_LOGFILE}"
		echo ""
		echo "*************************************************************************************"
		sleep 5
		
		# main routine
        prepare_mn_interfaces
        swaphack
        install_packages	
		build_mn_from_source
		create_mn_user
		create_mn_dirs
		echo "--- What to do about sentinel ..." >> /root/sentinelInstalledOrNot.txt				
		echo "The sentine url is: ${SENTINEL_URL}" >> /root/sentinelInstalledOrNot.txt				
		# sentinel setup 
		if [ "$sentinel" -eq 1 ]; then
			if [[ -z ${SENTINEL_URL} ]]; then
				echo "DID NOT FIND SENTINEL GIT URL FOR THIS COIN"
				echo "DID NOT FIND SENTINEL GIT URL FOR THIS COIN for ${CODENAME}" >> /root/sentinelInstalledOrNot.txt				
				remove_sentinel_setup_for_coin
			else
				echo "* Sentinel setup chosen" &>> ${SCRIPT_LOGFILE}
				echo "FOUND SENTINEL GIT URL FOR THIS COIN - installing for ${CODENAME}" >> /root/sentinelInstalledOrNot.txt								
				create_sentinel_setup  	 
			fi	
				
		fi		
		configure_firewall      
		create_mn_configuration
		create_control_configuration
		create_systemd_configuration 
		set_permissions
		cleanup_after
		chmod -R +x /root/mnTroubleshoot
		chown -R masternode:masternode /root/mnTroubleshoot
		#showbanner
		if [[ -z ${COIN_CLI} ]]; then
			echo "cli will be used"
		else
			echo "cli will be replaced with ${CODENAME}d" &>> ${SCRIPT_LOGFILE}
			find /root/mnTroubleshoot -type f | xargs sed -i "s_${CODENAME}-cli_${COIN_CLI}_g"
			echo "/root/mnTroubleshoot -type f | xargs sed -i \"s_${CODENAME}-cli_${COIN_CLI}_g\"" > replaceCli.sh
			
		fi	
		if [[ -z ${COIN_MASTERNODE_REPLACEMENT_STRING} ]]; then
			echo "masternode will be used as masternode"
		else
			echo "masternode will be replaced with ${COIN_MASTERNODE_REPLACEMENT_STRING}" &>> ${SCRIPT_LOGFILE}
			find /root/mnTroubleshoot/${CODENAME}/ -type f | xargs sed -i "s_ masternode _ ${COIN_MASTERNODE_REPLACEMENT_STRING} _g"
			echo "/root/mnTroubleshoot/${CODENAME}/ -type f | xargs sed -i \"s_ masternode _ ${COIN_MASTERNODE_REPLACEMENT_STRING} _g\""  > /root/mnTroubleshoot/${CODENAME}/replaceMasternodeString.sh			
		fi	
				

		cd /home/masternode
		chown -R masternode:masternode /home/masternode/
		chown -R masternode:masternode /usr/share/sentinel*
		chown -R masternode:masternode /usr/share/sentinelvenv*
		chown -R masternode:masternode /usr/local/bin/
		chown -R masternode:masternode /var/lib/masternodes/
		chown -R masternode:masternode /etc/masternodes/
		apt -y install fail2ban
		systemctl enable fail2ban
		systemctl start fail2ban
		sudo apt -y install rkhunter
		chmod 755 /
		chmod 755 /bin
		chmod 755 /lib
		cp /root/interfaces /etc/network/interfaces
		touch /root/installCompleted
		
		final_call 
		/usr/local/bin/activate_masternodes_${CODENAME}		
	else
		echo "required file ${SETUP_CONF_FILE} does not exist, abort!"
		exit 1   
	fi
	
}

#
# /* no parameters, builds the required masternode binary from sources. Exits if already exists and "update" not given  */
# 
function build_mn_from_source() {
        # daemon not found compile it
        if [ ! -f ${MNODE_DAEMON} ]; then
                mkdir -p ${SCRIPTPATH}/${CODE_DIR} &>> ${SCRIPT_LOGFILE}
                # if code directory does not exists, we create it clone the src
                if [ ! -d ${SCRIPTPATH}/${CODE_DIR}/${CODENAME} ]; then
                        mkdir -p ${CODE_DIR} && cd ${SCRIPTPATH}/${CODE_DIR} &>> ${SCRIPT_LOGFILE}
                        git clone ${GIT_URL} ${CODENAME}          &>> ${SCRIPT_LOGFILE}
                        cd ${SCRIPTPATH}/${CODE_DIR}/${CODENAME}  &>> ${SCRIPT_LOGFILE}
                        echo "* Checking out desired GIT tag: ${release}"   
                        git checkout ${release}                   &>> ${SCRIPT_LOGFILE}
                else
                        echo "* Updating the existing GIT repo"
                        cd ${SCRIPTPATH}/${CODE_DIR}/${CODENAME}  &>> ${SCRIPT_LOGFILE}
                        git pull                                  &>> ${SCRIPT_LOGFILE}
                        echo "* Checking out desired GIT tag: ${release}"                      
                        git checkout ${release}                   &>> ${SCRIPT_LOGFILE}
                fi

                # print ascii banner if a logo exists
                echo -e "* Starting the compilation process for ${CODENAME}, stay tuned"
                if [ -f "${SCRIPTPATH}/assets/$CODENAME.jpg" ]; then
                        jp2a -b --colors --width=56 ${SCRIPTPATH}/assets/${CODENAME}.jpg
                else
                        jp2a -b --colors --width=56 ${SCRIPTPATH}/assets/default.jpg          
                fi  
                # compilation starts here
                source ${SCRIPTPATH}/config/${CODENAME}/${CODENAME}.compile | pv -t -i0.1
        else
                echo "* Daemon already in place at ${MNODE_DAEMON}, not compiling"
        fi
        
		# if it's not available after compilation, theres something wrong
        if [ ! -f ${MNODE_DAEMON} ]; then
		echo ${MNODE_DAEMON}
                echo "COMPILATION FAILED! Please open an issue for coolblock on discord https://discord.gg/V74WQM . Thank you!"
                exit 1        
        fi       
}

#
# /* no parameters, print some (hopefully) helpful advice  */
# 
function final_call() {
	# note outstanding tasks that need manual work
    echo "************! ALMOST DONE !******************************"	
	echo "There is still work to do in the configuration templates."
	echo "These are located at ${MNODE_CONF_BASE}, one per masternode."
	echo "Add your masternode private keys now."
	echo "eg in /etc/masternodes/${CODENAME}_n1.conf"
	echo ""
    echo "=> All configuration files are in: ${MNODE_CONF_BASE}"
    echo "=> All Data directories are in: ${MNODE_DATA_BASE}"
	echo ""
	echo "last but not least, run /usr/local/bin/activate_masternodes_${CODENAME} as root to activate your nodes."	

    # place future helper script accordingly
    cp ${SCRIPTPATH}/scripts/activate_masternodes.sh ${MNODE_HELPER}_${CODENAME}
	echo "">> ${MNODE_HELPER}_${CODENAME}
	
	for NUM in $(seq 1 ${count}); do
		echo "systemctl enable ${CODENAME}_n${NUM}" >> ${MNODE_HELPER}_${CODENAME}
		echo "systemctl restart ${CODENAME}_n${NUM}" >> ${MNODE_HELPER}_${CODENAME}
	done
     
	chmod u+x ${MNODE_HELPER}_${CODENAME}
	tput sgr0
}

#
# /* no parameters, create the required network configuration. IPv6 is auto.  */
# 

function prepare_mn_interfaces() {

if [ "${net}" -ne 4 ]; then prepare_mn_interfaces1
fi
}

function prepare_mn_interfaces1() {


    # this allows for more flexibility since every provider uses another default interface
    # current default is:
    # * ens3 (vultr) w/ a fallback to "eth0" (Hetzner, DO & Linode w/ IPv4 only)
    #

    # check for the default interface status
    if [ ! -f /sys/class/net/${ETH_INTERFACE}/operstate ]; then
        echo "Default interface doesn't exist, switching to eth0"
        export ETH_INTERFACE="eth0"
    fi

    # get the current interface state
    ETH_STATUS=$(cat /sys/class/net/${ETH_INTERFACE}/operstate)

    # check interface status
    if [[ "${ETH_STATUS}" = "down" ]] || [[ "${ETH_STATUS}" = "" ]]; then
        echo "Default interface is down, fallback didn't work. Break here."
        exit 1
    fi
    
    # DO ipv6 fix, are we on DO? 
    # check for DO network config file
    if [ -f ${DO_NET_CONF} ]; then
        # found the DO config
		if ! grep -q "::8888" ${DO_NET_CONF}; then
			echo "ipv6 fix not found, applying!"
			sed -i '/iface eth0 inet6 static/a dns-nameservers 2001:4860:4860::8844 2001:4860:4860::8888 8.8.8.8 127.0.0.1' ${DO_NET_CONF}
			ifdown ${ETH_INTERFACE}; ifup ${ETH_INTERFACE};
		fi
    fi

    IPV6_INT_BASE="$(ip -6 addr show dev ${ETH_INTERFACE} | grep inet6 | awk -F '[ \t]+|/' '{print $3}' | grep -v ^fe80 | grep -v ^::1 | cut -f1-4 -d':' | head -1)" &>> ${SCRIPT_LOGFILE}
	
	validate_netchoice
	echo "IPV6_INT_BASE AFTER : ${IPV6_INT_BASE}" &>> ${SCRIPT_LOGFILE}

    # user opted for ipv6 (default), so we have to check for ipv6 support	
	# check for vultr ipv6 box active
	if [ -z "${IPV6_INT_BASE}" ] && [ ${net} -ne 4 ]; then
		echo "No IPv6 support on the VPS but IPv6 is the setup default. Please switch to ipv4 with flag \"-n 4\" if you want to continue."
		echo ""
		echo "See the following link for instructions how to add multiple ipv4 addresses on vultr:"
		echo "${IPV4_DOC_LINK}"
		exit 1
	fi	
		
	# generate the required ipv6 config
	if [ "${net}" -eq 6 ]; then
        # vultr specific, needed to work
	    sed -ie '/iface ${ETH_INTERFACE} inet6 auto/s/^/#/' ${NETWORK_CONFIG}
	    
		# move current config out of the way first
		cp ${NETWORK_CONFIG} ${NETWORK_CONFIG}.${DATE_STAMP}.bkp

		# create the additional ipv6 interfaces, rc.local because it's more generic 	    
		for NUM in $(seq 1 ${count}); do

			# check if the interfaces exist	    
			ip -6 addr | grep -qi "${IPV6_INT_BASE}:${NETWORK_BASE_TAG}::${NUM}"
			if [ $? -eq 0 ]
			then
			  echo "IP for masternode already exists, skipping creation" &>> ${SCRIPT_LOGFILE}
			else
			  echo "Creating new IP address for ${CODENAME} masternode nr ${NUM}" &>> ${SCRIPT_LOGFILE}
			  echo "ip -6 addr add ${IPV6_INT_BASE}:${NETWORK_BASE_TAG}::${NUM}/64 dev ${ETH_INTERFACE}" >> ${NETWORK_CONFIG}
			  sleep 2
			  ip -6 addr add ${IPV6_INT_BASE}:${NETWORK_BASE_TAG}::${NUM}/64 dev ${ETH_INTERFACE} &>> ${SCRIPT_LOGFILE}
			fi	
		done # end forloop	    
	fi # end ifneteq6
	
}

##################------------Menu()---------#####################################

# Declare vars. Flags initalizing to 0.
wipe=0;
debug=0;
update=0;
sentinel=0;

# Execute getopt
ARGS=$(getopt -o "hp:n:c:r:wsud" -l "help,project:,net:,count:,release:,wipe,sentinel,update,debug" -n "install.sh" -- "$@");
 
#Bad arguments
if [ $? -ne 0 ];
then
    help;
fi
 
eval set -- "$ARGS";
 
while true; do
    case "$1" in
        -h|--help)
            shift;
            help;
            ;;
        -p|--project)
            shift;
                    if [ -n "$1" ]; 
                    then
                        project="$1";
                        shift;
                    fi
            ;;
        -n|--net)
            shift;
                    if [ -n "$1" ]; 
                    then
                        net="$1";
                        shift;
                    fi
            ;;
        -c|--count)
            shift;
                    if [ -n "$1" ]; 
                    then
                        count="$1";
                        shift;
                    fi
            ;;
        -r|--release)
            shift;
                    if [ -n "$1" ]; 
                    then
                        release="$1";
                        shift;
                    fi
            ;;
        -w|--wipe)
            shift;
                    wipe="1";
            ;;
        -s|--sentinel)
            shift;
                    sentinel="1";
            ;;            
        -u|--update)
            shift;
                    update="1";
            ;;
        -d|--debug)
            shift;
                    debug="1";
            ;;            
 
        --)
            shift;
            break;
            ;;
    esac
done
 
# Check required arguments
if [ -z "$project" ]
then
    show_help;
fi

# Check required arguments
if [ "$wipe" -eq 1 ]; then
	get_confirmation "Would you really like to WIPE ALL DATA!? YES/NO y/n" && wipe_all
	exit 0
fi		

#################################################
# source default config before everything else
source ${SCRIPTPATH}/config/default.env
#################################################

main() {

    echo "starting" &> ${SCRIPT_LOGFILE}
    showbanner
    
	# debug
	if [ "$debug" -eq 1 ]; then
		echo "********************** VALUES AFTER CONFIG SOURCING: ************************"
		echo "START DEFAULTS => "
		echo "SCRIPT_VERSION:       $SCRIPT_VERSION"
		echo "SSH_INBOUND_PORT:     ${SSH_INBOUND_PORT}"
		echo "SYSTEMD_CONF:         ${SYSTEMD_CONF}"
		echo "NETWORK_CONFIG:       ${NETWORK_CONFIG}"
		echo "NETWORK_TYPE:         ${NETWORK_TYPE}"	
		echo "ETH_INTERFACE:        ${ETH_INTERFACE}"
		echo "MNODE_CONF_BASE:      ${MNODE_CONF_BASE}"
		echo "MNODE_DATA_BASE:      ${MNODE_DATA_BASE}"
		echo "MNODE_USER:           ${MNODE_USER}"
		echo "MNODE_HELPER:         ${MNODE_HELPER}"
		echo "MNODE_SWAPSIZE:       ${MNODE_SWAPSIZE}"
		echo "CODE_DIR:             ${CODE_DIR}"
		echo "SETUP_MNODES_COUNT:   ${SETUP_MNODES_COUNT}"	
		echo "END DEFAULTS => "
	fi
	
	# source project configuration         
    source_config ${project}
    
	# debug
	if [ "$debug" -eq 1 ]; then
		echo "START PROJECT => "
		echo "CODENAME:             $CODENAME"
		echo "SETUP_MNODES_COUNT:   ${SETUP_MNODES_COUNT}"
		echo "MNODE_DAEMON:         ${MNODE_DAEMON}"
		echo "MNODE_INBOUND_PORT:   ${MNODE_INBOUND_PORT}"
		echo "GIT_URL:              ${GIT_URL}"
		echo "SCVERSION:            ${SCVERSION}"
		echo "NETWORK_BASE_TAG:     ${NETWORK_BASE_TAG}"	
		echo "END PROJECT => "   	
		 
		echo "START OPTIONS => "
		echo "RELEASE: ${release}"
		echo "PROJECT: ${project}"
		echo "SETUP_MNODES_COUNT: ${count}"
		echo "NETWORK_TYPE: ${NETWORK_TYPE}"
		echo "NETWORK_TYPE: ${net}"         
	   
		echo "END OPTIONS => "
		echo "********************** VALUES AFTER CONFIG SOURCING: ************************"
	fi    
}

main "$@"
