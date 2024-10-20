#!/bin/bash

echo -e "Welcome to Linux Command Line Interface..."
echo -e '\n'
dateTime=$(date +%F_%H-%M-%S)
echo -e "$dateTime\n"
echo -e "$(fortune | cowsay -f turtle)"
echo -e '\n'
