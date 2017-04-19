#!/bin/bash 

array=("10.10.10.12" "10.10.10.13")

for ip_addr in ${array[@]}
do
	echo "Stop worker script on: " $ip_addr
	#echo $(ssh ${ip_addr} "bash -s" < stop_worker.sh)
done

ip_addr="10.10.10.11"
echo "Stop master script on: " $ip_addr
#echo $(ssh ${ip_addr} "bash -s" < stop_master.sh)

