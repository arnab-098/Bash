#!/bin/bash

if [ -z "$1" ]; then
    echo "Invalid syntax"
    echo "$(basename "$0") <url>"
    exit
fi

url="$1"

if [ ! -d "$HOME/$url" ]; then
    mkdir $HOME/$url
fi
if [ ! -d "$HOME/$url/recon" ]; then
    mkdir $HOME/$url/recon
fi
if [ ! -d "$HOME/$url/recon/gowitness" ]; then
    mkdir $HOME/$url/recon/gowitness
fi
if [ ! -d "$HOME/$url/recon/scans" ]; then
    mkdir $HOME/$url/recon/scans
fi
if [ ! -d "$HOME/$url/recon/httprobe" ]; then
    mkdir $HOME/$url/recon/httprobe
fi
if [ ! -d "$HOME/$url/recon/potential_takeovers" ]; then
    mkdir $HOME/$url/recon/potential_takeovers
fi
if [ ! -d "$HOME/$url/recon/wayback" ]; then
    mkdir $HOME/$url/recon/wayback
fi
if [ ! -d "$HOME/$url/recon/wayback/params" ]; then
    mkdir $HOME/$url/recon/wayback/params
fi
if [ ! -d "$HOME/$url/recon/wayback/extensions" ]; then
    mkdir $HOME/$url/recon/wayback/extensions
fi
if [ ! -f "$HOME/$url/recon/httprobe/alive.txt" ]; then
    touch $HOME/$url/recon/httprobe/alive.txt
fi
if [ ! -f "$HOME/$url/recon/final.txt" ]; then
    touch $HOME/$url/recon/final.txt
fi

echo "[+] Harvesting subdomains with assetfinder..."
assetfinder $url >>$HOME/$url/recon/assets.txt
cat $HOME/$url/recon/assets.txt | grep $1 >>$HOME/$url/recon/final.txt
rm $HOME/$url/recon/assets.txt

echo "[+] Double checking for subdomains with amass..."
amass enum -d $HOME/$url >> $HOME/$url/recon/f.txt
sort -u $HOME/$url/recon/f.txt >> $HOME/$url/recon/final.txt
rm $HOME/$url/recon/f.txt

echo "[+] Probing for alive domains..."
cat $HOME/$url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >>$HOME/$url/recon/httprobe/a.txt
sort -u $HOME/$url/recon/httprobe/a.txt >$HOME/$url/recon/httprobe/alive.txt
rm $HOME/$url/recon/httprobe/a.txt

echo "[+] Checking for possible subdomain takeover..."

if [ ! -f "$HOME/$url/recon/potential_takeovers/potential_takeovers.txt" ]; then
    touch $HOME/$url/recon/potential_takeovers/potential_takeovers.txt
fi

subjack -w $HOME/$url/recon/final.txt -t 100 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $HOME/$url/recon/potential_takeovers/potential_takeovers.txt

echo "[+] Scanning for open ports..."
nmap -iL $HOME/$url/recon/httprobe/alive.txt -T4 -oA $HOME/$url/recon/scans/scanned.txt

echo "[+] Scraping wayback data..."
cat $HOME/$url/recon/final.txt | waybackurls >>$HOME/$url/recon/wayback/wayback_output.txt
sort -u $HOME/$url/recon/wayback/wayback_output.txt

echo "[+] Pulling and compiling all possible params found in wayback data..."
cat $HOME/$url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >>$HOME/$url/recon/wayback/params/wayback_params.txt
for line in $(cat $HOME/$url/recon/wayback/params/wayback_params.txt); do echo $line'='; done

echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
for line in $(cat $HOME/$url/recon/wayback/wayback_output.txt); do
    ext="${line##*.}"
    if [[ "$ext" == "js" ]]; then
        echo $line >>$HOME/$url/recon/wayback/extensions/js1.txt
        sort -u $HOME/$url/recon/wayback/extensions/js1.txt >>$HOME/$url/recon/wayback/extensions/js.txt
    fi
    if [[ "$ext" == "html" ]]; then
        echo $line >>$HOME/$url/recon/wayback/extensions/jsp1.txt
        sort -u $HOME/$url/recon/wayback/extensions/jsp1.txt >>$HOME/$url/recon/wayback/extensions/jsp.txt
    fi
    if [[ "$ext" == "json" ]]; then
        echo $line >>$HOME/$url/recon/wayback/extensions/json1.txt
        sort -u $HOME/$url/recon/wayback/extensions/json1.txt >>$HOME/$url/recon/wayback/extensions/json.txt
    fi
    if [[ "$ext" == "php" ]]; then
        echo $line >>$HOME/$url/recon/wayback/extensions/php1.txt
        sort -u $HOME/$url/recon/wayback/extensions/php1.txt >>$HOME/$url/recon/wayback/extensions/php.txt
    fi
    if [[ "$ext" == "aspx" ]]; then
        echo $line >>$HOME/$url/recon/wayback/extensions/aspx1.txt
        sort -u $HOME/$url/recon/wayback/extensions/aspx1.txt >>$HOME/$url/recon/wayback/extensions/aspx.txt
    fi
done

rm $HOME/$url/recon/wayback/extensions/js1.txt
rm $HOME/$url/recon/wayback/extensions/jsp1.txt
rm $HOME/$url/recon/wayback/extensions/json1.txt
rm $HOME/$url/recon/wayback/extensions/php1.txt
rm $HOME/$url/recon/wayback/extensions/aspx1.txt

echo "[+] Running eyewitness against all compiled domains..."
for $currUrl in $HOME/$url/httprobe/alive.txt; do 
    gowitness scan single --url "$currUrl" --write-db
done
