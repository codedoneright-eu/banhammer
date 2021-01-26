#!/bin/bash

LOG_1=/var/log/syslog
LOG_2=/var/log/auth.log

sudo cat ${LOG_1} | grep -e "auth=0/1" | awk '{print $8}' | awk -F'[' '{print$2}' | sed 's/]$//' | sort | uniq > sus_ip_list_syslog.txt
sudo cat ${LOG_2} | grep -e "authentication failure" -e "tty=dovecot" | awk '{print $14}' | awk -F'=' '{print $2}' | uniq > sus_ip_list_auth.log.txt

cat ${LOG_1} ${LOG_2} > sus_ip_combined.txt
cat sus_ip_combined.txt | sort | uniq > sus_ip_all.txt
cat sus_ip_all.txt | sort | uniq > sus_ip_all.txt


while IFS= read -r ip_to_block
do
	sudo iptables -I INPUT -s ${ip_to_block} -j DROP
done < sus_ip_all.txt
