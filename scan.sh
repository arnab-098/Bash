#!/bin/bash

if [ "$1" == "" ]; then
	echo "Invalid input"
	echo "Syntax: ./scan.sh ip"
else
	for ip in $(seq 1 255); do
		ping $1.$ip -c 1 | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
	done
fi

