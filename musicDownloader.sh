#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <MUSIC_URL>"
    exit 1
fi

url="$1"

output_dir="$HOME/Music/"

yt-dlp -f bestaudio \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-thumbnail \
    --add-metadata \
    -o "$OUTPUT_DIR/%(title)s - %(artist)s.%(ext)s" \
    "$URL"
