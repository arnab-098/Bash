#!/bin/bash

file="$1"

if [ -z "$file" ]; then
	echo "Invalid syntax"
	echo "Syntax: ./$(basename "$0") <file>"
	exit 1
fi

if [[ "$file" = ~* ]]; then
	file="/home/$(whoami)/$(echo $file | cut -c 2-)"
fi

dir=$(dirname "$file")
file=$(basename "$file")

if [ ! -d "$dir" ]; then
	echo "Invalid file path"
	exit 1
fi

data=$(ls -la $dir | tr -s " " | grep -Pix "^([^ ]+ ){8}\.?$file(\.[^ ]+)?$" | cut -d " " -f 1,9 | tr " " ":")

if [ -z "$data" ]; then
	echo "File not found"
	exit 1
fi

declare -a result
idx=0
for i in $data; do
	a=$(echo $i | cut -d ":" -f 1)
	b=$(echo $i | cut -d ":" -f 2)
	result[$idx]="$b:\t$a"
	idx=$(expr $idx + 1)
done

echo -e "File permissions:"
for i in "${result[@]}"; do
	echo -e $i
done

