#!/bin/bash

file="names.txt"

uniqueNames=$(cat $file | sort | uniq -u)
allNames=$(cat $file | sort -u)

# allNames can also be done using $(cat $file | sort | uniq)

echo $uniqueNames
echo $allNames
