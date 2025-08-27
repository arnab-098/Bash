#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <MUSIC_URL>"
    exit 1
fi

URL="$1"
OUTPUT_DIR="$HOME/Music"

yt-dlp -f bestaudio \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-thumbnail \
    --add-metadata \
    -o "$OUTPUT_DIR/%(title)s - %(artist)s.%(ext)s" \
    "$URL"
