#!/usr/bin/bash

file="./data.txt"

n=$(expr $(cat $file | wc -l) - 1)
names1=$(cat $file | tail -n $n | cut -d "|" -f 2 | sort | uniq -d)
names2=$(cat $file | tail -n $n | cut -d "|" -f 2 | sort | uniq -u)

names="$names1 $names2"

for name in $names; do
  echo $name
done
