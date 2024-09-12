#!/bin/bash

declare -a arr=()

read -p "Enter the elements: " -a arr

length=${#arr[@]}

echo "Unsorted Array: "${arr[@]}

for ((i = 1; i < length; i++)); do
  j=$(expr $i - 1)
  key=${arr[$i]}
  while [ $j -ge 0 -a $key -lt ${arr[$j]} ]; do
    arr[$(expr $j + 1)]=${arr[$j]}
    j=$(expr $j - 1)
  done
  arr[$(expr $j + 1)]=$key
done

echo "Sorted Array: "${arr[@]}
