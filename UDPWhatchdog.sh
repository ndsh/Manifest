#!/bin/sh
count=2
tmpfile="/tmp/counter"
echo $count > "$tmpfile"
(trap 'kill 0' SIGINT; 
nc -ulp 4000 | while read line 
do
	#match=$(echo $line | grep -c 'ping')

    #if [ $match -eq 1 ]; then
		count=$(<"$tmpfile")
    	count=$(($count+1))
		echo $count > "$tmpfile"
    #fi
done & while true
do
	sleep 3
	count=$(<"$tmpfile")
    count=$(($count-1))
	echo $count > "$tmpfile"
	echo "counter: $count"
	if [ "$count" -lt "0" ]; then
		killall "TextEdit"
		sleep 1 
		count=2
		echo $count > "$tmpfile"
		cmd="open /Applications/TextEdit.app"
		$cmd &
	fi
done)