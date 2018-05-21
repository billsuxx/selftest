#!/bin/bash

SDA_ERROR="$(smartctl -a /dev/sda | grep -e Raw_Read_Error_Rate | grep -oE '[^ ]+$')"
SDA_POWER="$(smartctl -a /dev/sda | grep -e Power_On | grep -oE '[^ ]+$')"
SDA_TEMP="$(smartctl  -a /dev/sda | grep -e Temperature |grep -oE '[^ ]+$' )"
SDA_REA="$(smartctl  -a /dev/sda | grep -e Reallocated_Sector |grep -oE '[^ ]+$' )"
SDA_POWER_DAYS=$(( SDA_POWER  / 24 ))

SDB_ERROR="$(smartctl -a /dev/sdb | grep -e Raw_Read_Error_Rate | grep -oE '[^ ]+$')"
SDB_POWER="$(smartctl -a /dev/sdb | grep -e Power_On | grep -oE '[^ ]+$')"
SDB_TEMP="$(smartctl  -a /dev/sdb | grep -e Temperature |grep -oE '[^ ]+$' )"
SDB_REA="$(smartctl  -a /dev/sdb | grep -e Reallocated_Sector |grep -oE '[^ ]+$' )"
SDB_POWER_DAYS=$(( SDB_POWER  / 24 ))


DF_SIZE=$(df -h | grep /media| awk  '{print $2}')
DF_USED=$(df -h | grep /media| awk  '{print $3}')
DF_FREE=$(df -h | grep /media| awk  '{print $4}')
DF_PERCENT=$(df -h | grep /media| awk  '{print $5}')


NET_RC=$(vnstat -m | tail -4 | sed -n 1p  | awk '{print $3}')
NET_RCU=$(vnstat -m | tail -4 | sed -n 1p  | awk '{print $4}')

NET_TF=$(vnstat -m | tail -4 | sed -n 1p  | awk '{print $6}')
NET_TFU=$(vnstat -m | tail -4 | sed -n 1p  | awk '{print $7}')

RAID_STATUS=$(cat /proc/mdstat |grep -e md0)
UPTIME=$(uptime)

echo "" > /root/test.txt

EMAIL='/root/test.txt'


echo "<html><body><pre>OMV status report" >> $EMAIL
echo "" >> $EMAIL

echo 'Stats for /dev/sda:' >> $EMAIL
echo '===================' >> $EMAIL
echo "Raw Read Error Rate: $SDA_ERROR" >> $EMAIL
echo "Reallocated Sector: $SDA_REA" >> $EMAIL
echo "Power On Hours: $SDA_POWER ($SDA_POWER_DAYS days)" >> $EMAIL
echo "Temperature: $SDA_TEMP (c)" >> $EMAIL
echo "" >> $EMAIL

echo 'Stats for /dev/sdb:' >> $EMAIL
echo '===================' >> $EMAIL
echo "Raw Read Error Rate: $SDB_ERROR" >> $EMAIL
echo "Reallocated Sector: $SDB_REA" >> $EMAIL
echo "Power On Hours: $SDB_POWER ($SDB_POWER_DAYS days)" >> $EMAIL
echo "Temperature: $SDB_TEMP (c)" >> $EMAIL
echo "" >> $EMAIL

echo 'Free space on /dev/md0:' >> $EMAIL
echo '===========' >> $EMAIL
echo "Size: $DF_SIZE" >> $EMAIL
echo "Used: $DF_USED ($DF_PERCENT)" >> $EMAIL
echo "Free: $DF_FREE" >> $EMAIL

echo "" >> $EMAIL

echo 'RAID status:' >> $EMAIL
echo '===========' >> $EMAIL
echo "$RAID_STATUS" >> $EMAIL
echo "" >> $EMAIL


echo 'Network:' >> $EMAIL
echo '===========' >> $EMAIL
echo "Total recived: $NET_RC $NET_RCU" >> $EMAIL
echo "Total transfered: $NET_TF $NET_TFU" >> $EMAIL
echo "" >> $EMAIL


echo 'Uptime:' >> $EMAIL
echo '===========' >> $EMAIL
echo "$UPTIME" >> $EMAIL
echo "" >> $EMAIL


echo '</pre></body></html>' >> $EMAIL


cat $EMAIL  | mail -a "Content-type: text/html;" -s "OMV status report" your@email.com

