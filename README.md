# Most often used commands to Install or update with Binaries

Auto update is available, read below.

## Installation For 1 (one (the first one)) masternode

Install binaries FOR total of 1 masternode

wget -qO- https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/1vivobin.sh | sudo bash

Update binaries  FOR total of 1 masternode

wget -qO- https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/1vivobinUpdate.sh | sudo bash

## Installation For Multiple Masternodes (two or more) (On the Same IP)

Install binaries by using the following line and respond to the prompts. You will need private keys and a choice of ports.

bash <(curl -s https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/1vivobinMulti.sh)

If you have installed using any of the scripts already, to add more masternodes (you will tell how many by saying how many in TOTAL you will have on the machine)

bash <(curl -s https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/AddMnBinMulti.sh)

### To update multi masternodes binaries and sentinel

bash <(curl -s https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/UpdateMnBinMulti.sh)

### Recommended sequence of actions to create multiple Masternodes

(it is recomended to add one at a time. When you have 1 masternode already, say total of 2. Then when you have started the second one, run the script again but say total of 3. and on and on.)

The command to use on the VPS is (all one line):

bash <(curl -s https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/1vivobinMulti.sh)

Let us assume you are setting up 4 Masternodes on one Vultr 1 gig machine. 

1.	Have your private keys and your four ports ready. (You can chose whatever port you want as long as it is approximately above 1500 and less that 65000 - each masternode will have to have a different one) 
2.	Then run the script. 
3.	Let the VPS masternodes sync, they will take half a day to sync.
4.	Then send 1000 to an address
5.	Wait for at least 20 confirmations and insert the proper line in the masternode.conf file or the controlling wallet. 
6.	Once set up in the controlling wallet, start alias. 
7.	You can now safely go to step 4 for the next masternode.

If you don't do it in this sequence, when you send the 1000 coins you may send from or to an address that is not locked.

It is a time consuming process as waiting for the sync takes time and waiting for confirmations takes time.

## Auto Update implementation

The system allows you to set it up so that it will autoupdate. After you have installed you can run the auto update script which is one line:

bash <(curl -s https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/vAutoUpdate.sh?$(date +%s))

This will set up your machine to update automatically. It will check once a day and if a new version is ready, it will update.

# Quick Install of Binaries on (Ubuntu 16 and 18)

(keep in mind if you have other coins installed with other scripts there may be conflicts that can't be fixed)

Have a private key ready by going to your (controlling) wallet, to the debug console and typing in 

masternode genkey

To Install 1 vivo masternode in one shot cut and paste the following line and press enter (as root)

wget -qO- https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/1vivobin.sh | sudo bash

(if you are asked what kind of mail configuration you want, just say none, or no configuration)

once it has finished, in order to confirm that vivo is running, type in 

top

vivod should be in the list on the top right.

To check the status, you can run the following multiple times and the numbers will change and blocks increase

/root/vpsVivo/overAllMnStat.sh

-------------------------

# Binary Update (Ubuntu 16 and 18)

To update without building from source you use this line (as root):

wget -qO- https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/1vivobinUpdate.sh | sudo bash

This will erase the old binary and install the new one. It will not update your conf files.

==============================

# Building from Source (Ubuntu 16 or above)

(All of this has to be done as root)

In case you must build from source: (for instance if it does not work with the latest ubuntu)

Newest Technique to install ONE vivo masternode (there are other instructions to install multiple):
First time installation as root on ubuntu 16 or above.
This will work if there are no other masternodes installed. Otherwise unknown conflicts can occur.

Ideally you will have at least a 1 gig ram machine. A 512 might (and might NOT) work but will take half a day to build.

## Option 1 Installation with Source

Run the following (All of this has to be done as root) entire line in ssh: (have your private key ready)

wget -qO- https://raw.githubusercontent.com/coolblock/vpsVivo/master/utils/vivo/1vivo.sh | sudo bash

## Option 2 Installation with Source
If you have trouble or you want to use multiple commands you can:

(All of this has to be done as root)


cd

apt install -y git screen

git clone https://github.com/coolblock/vpsVivo.git

-- then type in sreen and hit enter twice and enter

/root/vpsVivo/coinMnInstall.sh vivo 1

Any option will install by building a vivo masternode using an ip4. It will build the masternode from source. It will run as a service and will be restarted if the vps is restarted.
With a 1 gig machine the process will take around 20 minutes.

The vps script will run for 20 minutes and disconnect your ssh session. Putty will show a disconnect error. That means the machine is rebooting. You can restart another session if you want to check the vps.

# Set up Cold Wallet and start masternode after VPS has rebooted

Meanwhile set up your cold wallet, the masternode.conf file on your windows machine (if that is where your cold wallet is at).

After the server has rebooted, you will need to start the alias on the cold wallet.

# To Update (build from source)

This is updating a system that used this system to install. It will not update any other technique of installation.

## option 1 update with Source (Ubuntu 16 or above)

The following is one single line.

wget https://raw.githubusercontent.com/coolblock/vpsVivo/master/coinMnUpdate.sh;chmod +x coinMnUpdate.sh;./coinMnUpdate.sh vivo 1

This will rebuild vivo

## option 2 update with Source (Ubuntu 16 or above)

cd

rm -rf vpsVivo

git clone https://github.com/coolblock/vpsVivo.git

/root/vpsVivo/coinMnUpdate.sh vivo 1

This will also rebuild vivo

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

# To grab the bootstrap

/root/mnTroubleshoot/vivo/vivo1_clear_and_load_bootstrap.sh

Otherwise you can download it from

http://bootstrap1.vivocoin.net/vivobootstrap.zip

# Troubleshooting

99 percent of the time, if it does not start, the problem is because of invalid private key or a mistake on the the cold wallet (the controlling wallet).

If you have made a mistake with your privatekey,
 
nano /etc/masternodes/vivo_n1.conf

Go the the bottom and fix it
control x to save
and then type in

reboot

That will restart everything.


Remember you can type in 

reboot

to restart the system.


The first troubleshooting script to run is

/root/vpsVivo/overAllMnStat.sh

It will tell you what it ran and what the result was.

To see if the deamon is running: 
service vivo_n1 status

Or you can look at top and see if vivod exists in the list

To start the deamon: 
service vivo_n1 start

If it does not start, to trouble shoot the "starting":

/sbin/runuser -l masternode -c '/usr/local/bin/vivod -daemon -pid=/var/lib/masternodes/vivo1/vivo.pid -conf=/etc/masternodes/vivo_n1.conf -datadir=/var/lib/masternodes/vivo1'

Look at the output


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

## To resync with cleared/empty data

/root/mnTroubleshoot/vivo/vivo1_clear_out_data_restart_with_blank_data.sh

# Multiple Masternodes Using Multiple IP4

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

/root/vpsVivo/coinMnInstall.sh vivo 2

The 2 at the end means install a total of 2 masternodes. It will use the /root/ip4_1.txt, /root/ip4_2.txt, and /root/pk_vivo_1.txt, /root/pk_vivo_2.txt files.

If you have more files you can run

/root/vpsVivo/coinMnInstall.sh vivo 3

or

/root/vpsVivo/coinMnInstall.sh vivo 4

as many as your system can handle. Remember each has its own database and will take space. Also you will need enough cpu power to run multiple masternodes.

These each will have their separate sentinel installs.






