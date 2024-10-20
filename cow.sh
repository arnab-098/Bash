#!/bin/bash

file="list.txt"

content=$(cat $file)

size=0
for i in $content; do
	size=$(expr $size + 1)
done

idx=1

for i in $content; do
	clear
	echo -e "$idx/$size\n"
	echo "Mode: "$i
	fortune | cowsay -f $i
	idx=$(expr $idx + 1)
	echo -ne "\nPress enter to continue..."
	read
done

