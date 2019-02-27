#!/bin/bash

echo "If this does not work: Reminding you must first run the command"
echo "passwd"
echo "and then the command"
echo "su"
echo "and this file should work after that"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd
apt-get install toilet figlet -y
apt-get install psmisc -y

	
#if [ ! -f /root/ip4_1.txt ]; then
	ipvariable=$(wget http://ipecho.net/plain -O - -q);
	echo "externalip=$ipvariable" > /root/ip4_1.txt
	echo "Will be using {$ipvariable} as your IP. If you want to change them you will have to go to etc/masternodes and change the conf file."
#fi

echo "Now the install scripts should work for google cloud"