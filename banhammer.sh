#!/bin/bash

check_syslog () {
cat /var/log/syslog | grep -e "auth=0/1" | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq > banhammer_syslog.txt
}

#Read authlog and get dovecot authentication failures, save IP numbers to file
check_authlog () {
cat /var/log/auth.log | grep -e "authentication failure" -e "tty=dovecot" | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq > banhammer_auth.log.txt
}


get_ip_block_list () {
#Combine failed IP numbers to one file
cat banhammer_syslog.txt banhammer_auth.log.txt | grep . > banhammer_combined.txt
#Sort and get only unique IP numbers to be blocked, append file with all numbers
cat banhammer_combined.txt | sort | uniq >> banhammer_all.txt
#Reverse search for your local IP and put in a temp file
cat banhammer_all.txt | grep -v -e "192.168.50." > banhammer_all_temp.txt
#Put back only external IPs in the file again
cat banhammer_all_temp.txt > banhammer_all.txt
#Read file with combined IPs and prepare file with numbers to be blocked
cat banhammer_all.txt | sort | uniq > banhammer_block.txt
}

execute_block () {
while IFS= read -r ip_to_block
do
        sudo iptables -I INPUT -s ${ip_to_block} -j DROP
done < banhammer_block.txt
}


check_syslog
check_authlog
get_ip_block_list
execute_block


#Logging stuff
echo "Banhammer blocked the following IP numbers:"
echo "==========================================="

cat banhammer_block.txt

echo ""
echo "Banhammer did it's job..."
