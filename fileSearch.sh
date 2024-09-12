#!/bin/bash

file="password.txt"
exist=$(ls -la | tr -s " " | cut -d " " -f 9 | grep -c $file)
if [ $exist -gt 0 ]; then
  content=$(cat $file | wc -l)
  if [ $content -eq 0 ]; then
    read -s -p "Create a password: " password
    echo ""
    echo $password >>$file
  fi
else
  read -s -p "Create a password: " password
  echo ""
  echo $password >>$file
fi

password=$(cat $file)

echo -e "Hello user!"
read -s -p "Enter password to get access: " x
echo ""

if [ "$x" = $password ]; then
  read -p "Enter file: " f
  exist=$(ls -la | tr -s " " | grep -Pi "^(.* ){8}\.?$f(\..*)?$")
  if [ "$exist" != "" ]; then
    echo "FILE EXISTS"
  else
    echo "FILE DOES NOT EXIST"
  fi
else
  echo -e "Fuck off loser!"
fi
