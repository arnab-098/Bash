#!/bin/bash

file="password.txt"
if [ -f $file ]; then
  content=$(cat $file | wc -l)
  if [ $content -ne 1 ]; then
    read -s -p "Create a password: " password
    echo ""
    echo $password >$file
  fi
else
  read -s -p "Create a password: " password
  echo ""
  echo $password >>$file
fi

password=$(cat $file)

count=0

echo -e "Hello user!\n"

while [ $count -lt 3 ]; do
  read -s -p "Enter password to get access: " x
  echo ""
  if [ "$x" == "$password" ]; then
    read -p "Enter file: " f
    exist=$(ls -la | tr -s " " | grep -Pi "^([^ ]+ ){8}\.?$f(\.[^ ]+)?$")
    if [ ! -z "$exist" ]; then
      echo "File exists"
    else
      echo "File does not exist"
    fi
    exit 0
  else
    count=$(expr $count + 1)
    echo "Incorrect password"
    if [ $count -lt 3 ]; then
      echo -e "$(expr 3 - $count) attemp(s) remaining!\n"
    else
      echo -e "Too many wrong attempts. Try again later\n"
    fi
  fi
done
