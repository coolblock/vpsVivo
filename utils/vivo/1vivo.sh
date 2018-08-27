rm -rf vpsVIVO/
cd;apt install -y git screen;echo 'masternodeprivkey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'>pk_vivo_1.txt;git clone https://github.com/coolblock/vpsVIVO.git;screen -dmS new_screen bash;screen -S new_screen -p 0 -X exec /root/vpsVIVO/coinMnInstall.sh vivo 1
