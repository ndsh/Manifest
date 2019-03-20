#!/bin/sh
nc -ulp 6000 | while read line 
do
	match=$(echo $line | grep -c 'Manifest,On/Off')
        if [ $match -eq 1 ]; then
            shutdown now
        else
        	echo -n "$line " | nc -4u -w0  localhost 6100
        fi
done
