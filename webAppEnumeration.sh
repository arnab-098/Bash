#!/bin/bash

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
RESET="\033[0m"

if [ -z "$1" ]; then
    echo -e "${RED}Usage: $(basename "$0") <domain>${RESET}"
    exit 1
fi

domain="$1"
base_dir="$HOME/recon/$domain"

# Define directories
info_path="$base_dir/info"
subdomain_path="$base_dir/subdomains"
screenshot_path="$base_dir/screenshots"
httprobe_path="$base_dir/httprobe"
wayback_path="$base_dir/wayback"
takeover_path="$base_dir/potential_takeovers"
scan_path="$base_dir/scans"
gowitness_path="$base_dir/gowitness"

# Create directories
for path in "$info_path" "$subdomain_path" "$screenshot_path" "$httprobe_path" "$wayback_path/params" "$wayback_path/extensions" "$takeover_path" "$scan_path" "$gowitness_path"; do
    if [ ! -d "$path" ]; then
        mkdir -p "$path"
        echo "Created directory: $path"
    fi
done

echo -e "${GREEN}[+] Recon started for $domain${RESET}"

# WHOIS
echo -e "${RED}[+] Checking whois info...${RESET}"
whois "$domain" >"$info_path/whois.txt"

# Subfinder
echo -e "${RED}[+] Running subfinder...${RESET}"
subfinder -d "$domain" >"$subdomain_path/found.txt"

# Assetfinder
echo -e "${RED}[+] Running assetfinder...${RESET}"
assetfinder "$domain" | grep "$domain" >>"$subdomain_path/found.txt"

# Amass
echo -e "${RED}[+] Running amass...${RESET}"
amass enum -d "$domain" >>"$subdomain_path/found.txt"

# Deduplicate
sort -u "$subdomain_path/found.txt" -o "$subdomain_path/found.txt"

# Alive check
echo -e "${RED}[+] Probing for alive domains...${RESET}"
cat "$subdomain_path/found.txt" | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >>"$httprobe_path/alive.txt"

# Screenshots
echo -e "${RED}[+] Taking screenshots with gowitness...${RESET}"
gowitness scan file -f "$httprobe_path/alive.txt" -s screenshots/ \
    --write-jsonl --write-jsonl-file gowitness.jsonl --quiet

# Possible takeover
echo -e "${RED}[+] Checking for possible subdomain takeovers...${RESET}"
subjack -w "$subdomain_path/found.txt" -t 100 -timeout 30 -ssl -c ~/go/pkg/mod/github.com/haccer/subjack@v0.0.0-20201112041112-49c51e57deab/fingerprints.json \
    -o "$takeover_path/potential_takeovers.txt"

# Nmap
echo -e "${RED}[+] Scanning for open ports with Rustscan + Nmap...${RESET}"
rustscan -a "$httprobe_path/alive.txt" --ulimit 5000 --range 1-65535 \
    --no-config -t 2000 -b 500 \
    -- -T4 -oA "$scan_path/scanned" >/dev/null 2>&1

# Wayback data
echo -e "${RED}[+] Scraping Wayback Machine data...${RESET}"
cat "$subdomain_path/found.txt" | waybackurls \
    >"$wayback_path/wayback_output.txt" 2>/dev/null

# Wayback params
echo -e "${RED}[+] Extracting parameters from wayback data...${RESET}"
cat "$wayback_path/wayback_output.txt" | grep '?*=' | cut -d '=' -f 1 | sort -u >"$wayback_path/params/wayback_params.txt"

# Wayback extensions
echo -e "${RED}[+] Extracting js/php/aspx/jsp/json/html files from wayback data...${RESET}"
for line in $(cat "$wayback_path/wayback_output.txt"); do
    ext="${line##*.}"
    case "$ext" in
    js) echo "$line" >>"$wayback_path/extensions/js.txt" ;;
    json) echo "$line" >>"$wayback_path/extensions/json.txt" ;;
    php) echo "$line" >>"$wayback_path/extensions/php.txt" ;;
    aspx) echo "$line" >>"$wayback_path/extensions/aspx.txt" ;;
    jsp | html) echo "$line" >>"$wayback_path/extensions/jsp.txt" ;;
    esac
done

sort -u -o "$wayback_path/extensions/js.txt" "$wayback_path/extensions/js.txt"
sort -u -o "$wayback_path/extensions/json.txt" "$wayback_path/extensions/json.txt"
sort -u -o "$wayback_path/extensions/php.txt" "$wayback_path/extensions/php.txt"
sort -u -o "$wayback_path/extensions/aspx.txt" "$wayback_path/extensions/aspx.txt"
sort -u -o "$wayback_path/extensions/jsp.txt" "$wayback_path/extensions/jsp.txt"

echo -e "${GREEN}[+] Recon completed for $domain. Output saved in $base_dir${RESET}"
