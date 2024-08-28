#!/usr/bin/bash

read -p "Enter a number: " num

while [ $num -gt 0 ]; do
  echo $num
  num=$(expr $num - 1)
done

echo "Done"
