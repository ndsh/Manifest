#!/bin/sh
nc -ulp 6000 | while read line 
do
	match=$(echo $line | grep -c 'Manifest,On/Off')

        echo -n "$line " | nc -4u -w0 -q0  localhost 6100

        if [ $match -eq 1 ]; then
        	echo "shutdown"
            shutdown now
        fi
done
