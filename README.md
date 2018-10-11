Newest Technique to install ONE vivo masternode (there are other instructions to install multiple):
First time installation as root on ubuntu 16 or above.
This will work if there are no other masternodes installed. Otherwise unknown conflicts can occur.

All in one line BUT replace the XXXXX with your private key

Ideally you will have at least a 1 gig ram machine. A 512 will work but will take half a day to build.

# Option 1
One way is to use this entire single line:

cd;apt install -y git screen;echo 'masternodeprivkey=xxxxxxxxxxxxxxxxxxxxxxxxxxxx'>pk_vivo_1.txt;git clone https://github.com/coolblock/vpsVIVO.git;screen -dmS new_screen bash;screen -S new_screen -p 0 -X exec /root/vpsVIVO/coinMnInstall.sh vivo 1

# Option 2
Another way is to grab this file and modify and then run it. You grab it by typeing

wget https://raw.githubusercontent.com/coolblock/vpsVIVO/master/utils/vivo/1vivo.sh;

#edit the file

apt-get install -y nano

nano 1vivo.sh;

#controlx to exit nano

chmod +x 1vivo.sh; 

./1vivo.sh

# Option 3
If you have trouble or you want to use multiple commands you can:
cd

apt install -y git screen

echo 'masternodeprivkey=xxxxxxxxxxxxxxxxxxxxxxxxxxxx'>pk_vivo_1.txt

git clone https://github.com/coolblock/vpsVIVO.git

-- then type in sreen and hit enter twice and enter

/root/vpsVIVO/coinMnInstall.sh vivo 1

Any option will install a vivo masternode using an ip4. It will build the masternode from source. It will run as a service and will be restarted if the vps is restarted.
With a 1 gig machine the process will take around 20 minutes.

The vps script will run for 20 minutes and disconnect your ssh session. Putty will show a disconnect error. That means the machine is rebooting. You can restart another session if you want to check the vps.

# Set up Cold Wallet and start masternode after VPS has rebooted

Meanwhile set up your cold wallet, the masternode.conf file on your windows machine (if that is where your cold wallet is at).

After the server has rebooted, you will need to start the alias on the cold wallet.

# To update

## option 1 update

wget https://raw.githubusercontent.com/coolblock/vpsVIVO/master/coinMnUpdate.sh

chmod +x coinMnUpdate.sh

./coinMnUpdate.sh vivo 1

This will rebuild vivo

## option 2 update

cd

rm -rf vpsVIVO

git clone https://github.com/coolblock/vpsVIVO.git

/root/vpsVIVO/coinMnUpdate.sh vivo 1

This will rebuild vivo

# Looking at the VPS information

The conf file is located at:
/etc/masternodes/vivo_n1.conf

Executables like vivod are in:
/usr/local/bin

Data directory is in:
/var/lib/masternodes/vivo1

To do an individual run of sentinel:
/root/runsentinelnolog1.sh

To do a getinfo:
/usr/local/bin/vivo-cli -conf=/etc/masternodes/vivo_n1.conf getinfo

# Troubleshooting

99 percent of the time, a problem is because of invalid private key or a mistake on the the cold wallet (the controlling wallet).

To see if the deamon is running: 
service vivo_n1 status

Or you can look at top and see if vivod exists in the list

To start the deamon: 
service vivo_n1 start

If it does not start, to trouble shoot the "starting":

/sbin/runuser -l masternode -c '/usr/local/bin/vivod -daemon -pid=/var/lib/masternodes/vivo1/vivo.pid -conf=/etc/masternodes/vivo_n1.conf -datadir=/var/lib/masternodes/vivo1'

Look at the output

If you have made a mistake with your privatekey, 
nano conf=/etc/masternodes/vivo_n1.conf
Go the the bottom and fix it
control x to save
and then type in
reboot
That will restart everything.

# Troubleshooting files

Many commands are in: /root/mnTroubleshoot/vivo/

As in:

/root/mnTroubleshoot/vivo/vivo1_reindex.sh

/root/mnTroubleshoot/vivo/vivo1_stopService.sh

/root/mnTroubleshoot/vivo/vivo1_getInfo.sh


## TO REINDEX:


/root/mnTroubleshoot/vivo/vivo1_reindex.sh

Or

(one single line below)

service vivo_n1 stop;/sbin/runuser -l masternode -c '/usr/local/bin/vivod -reindex -pid=/var/lib/masternodes/vivo1/vivo.pid -conf=/etc/masternodes/vivo_n1.conf -datadir=/var/lib/masternodes/vivo1'

# Multiple Masternodes

For those who want to install multiple masternodes, each masternode has to have its own private key and its own ip to bind to.

The ip of the first masternode was in 

/root/ip4_1.txt

The ip of the second masternode should go in 

/root/ip4_2.txt

The private key of the first masternode will be in: 

/root/pk_vivo_1.txt

The private key of the second masternode should go in: 

/root/pk_vivo_2.txt

Now for a total of two masternodes you must run 

/root/vpsVIVO/coinMnInstall.sh vivo 2

The 2 at the end means install a total of 2 masternodes. It will use the /root/ip4_1.txt, /root/ip4_2.txt, and /root/pk_vivo_1.txt, /root/pk_vivo_2.txt files.

These each will have their separate sentinel installs.






