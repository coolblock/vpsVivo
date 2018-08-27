#find /root/mnTroubleshoot -name '*_getInfo.sh' > allGetInfo.sh
##cat allGetInfo.sh
#chmod +x allGetInfo.sh
#./allGetInfo.sh | grep blocks


#find /root/mnTroubleshoot -name '*runSentinelToSeeOutput.sh' > allGetSentinelInfo.sh
##cat allGetSentinelInfo.sh
#chmod +x allGetSentinelInfo.sh
#./allGetSentinelInfo.sh

echo "====================START================================="

uptime
df -h
echo "----------------------------------------------------------"
find /root/mnTroubleshoot -name '*_getInfo.sh'| while read program; do
                                echo "--- $program"
				$program | grep blocks
                            done

find /root/mnTroubleshoot -name '*_getBlockCountFromExplorer.sh'| while read program; do
                                echo "--- $program"
				$program; echo " " 
                            done

find /root/mnTroubleshoot -name '*sync_status.sh'| while read program; do
                                echo "--- $program"
				echo "If synced -- AssetID should be 999"
				$program | grep Asset
                            done


find /root/mnTroubleshoot -name '*masternode_status.sh'| while read program; do
                                echo "--- $program"
				echo "If synced should be: -- Masternode successfully started or status is 4"
				$program | grep status
                            done


find /root/mnTroubleshoot -name '*runSentinelToSeeOutput.sh'| while read program; do
                                echo "--- $program"
				echo "Any SENTINEL issues will be listed below:"
				$program
				echo "--END (if nothing then Sentinel found no error)"
                            done


echo "====================END================================="
