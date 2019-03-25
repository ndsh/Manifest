#!/bin/bash
sleep 10
count=0
tmpfile="/tmp/counter"
echo $count > "$tmpfile"
(trap 'kill 0' SIGINT; 
nc -ulp 4000 | while read line 
do
	#match=$(echo $line | grep -c 'ping')
	echo "$line"
    #if [ $match -eq 1 ]; then
		count=$(<"$tmpfile")
    	count=$(($count+1))
		echo "0" > "$tmpfile"
    #fi
done & while true
do
	sleep 1
	count=$(<"$tmpfile")
    count=$(($count-1))
	echo $count > "$tmpfile"
	echo "counter: $count"
	if [ "$count" -lt "-6" ]; then
		count=0
		echo $count > "$tmpfile"
		killall "/home/thegreeneyl/Documents/Manifest/visualController/application.linux64/java/bin/java"
		sleep 1 
		cmd="/home/thegreeneyl/Documents/Manifest/visualController/application.linux64/visualController"
		$cmd &
	fi
done)