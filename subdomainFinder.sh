#!/bin/bash

if [ -z "$1" ]; then
    echo "Invalid syntax"
    echo "$(basename "$0") <url>"
    exit
fi

url=$1

if [ ! -d "$url" ]; then
    mkdir $HOME/$url
fi

if [ ! -d "$url/recon" ]; then
    mkdir $HOME/$url/recon
fi

echo "[+] Harvesting subdomains with assetfinder..."
assetfinder $url >>$HOME/$url/recon/assets.txt
cat $url/recon/assets.txt | grep "$1" >>$HOME/$url/recon/final.txt
rm $HOME/$url/recon/assets.txt

echo "[+] Harvesting subdomains with amass..."
amass $url >>$HOME/$url/recon/f.txt
sort -u $HOME/$url/recon/f.txt >>$HOME/$url/final.txt
rm $HOME/$url/recon/f.txt
