#!/bin/bash

LOG_1=/var/log/syslog
LOG_2=/var/log/auth.log

sudo cat ${LOG_1} | grep -e "postfix" -e "auth=0/1" | awk '{print $8}' | awk -F'[' '{print$2}' | sed 's/]$//' | sort | uniq > banhammer_syslog.txt
sudo cat ${LOG_2} | grep -e "authentication failure" -e "tty=dovecot" | awk '{print $14}' | awk -F'=' '{print $2}' | uniq > banhammer_auth.log.txt

cat banhammer_syslog.txt banhammer_auth.log.txt | grep . > banhammer_combined.txt
cat banhammer_combined.txt | sort | uniq >> banhammer_all.txt
cat banhammer_all.txt | sort | uniq > banhammer_block.txt


while IFS= read -r ip_to_block
do
	sudo iptables -I INPUT -s ${ip_to_block} -j DROP
done < banhammer_block.txt
