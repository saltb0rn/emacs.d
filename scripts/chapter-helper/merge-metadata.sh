#!/bin/bash

# merge-metadata.sh VIDEO CHAPTER

display_help_info () {
    echo -e "\nUSAGE: merge-metadata.sh VIDEO CHAPTER"
}

if (( "$#" != 2 )); then
    display_help_info
    exit 1
fi

# metadata=$(mktemp /tmp/FFMETADATAFILE.$$.XXXXXXXXXX)
metadata=FFMETADATAFILE
chapter="${2}-chapters.txt"
output="${1%%.*}-OUTPUT.${1##*.}"

if ! ffmpeg -i "$1" -f ffmetadata $metadata; then
    if [ -e "$metadata" ]; then
        rm "$metadata"
    fi
    exit 1
fi

if ! $(dirname -- "$0")/video_chapters_helper.el -f "$2" > /dev/null; then
    if [ -e "$metadata" ]; then
        rm "$metadata"
    fi
    exit 1
fi

cat "$chapter" >> "$metadata"

ffmpeg -i "$1" -i "$metadata" -map_metadata 1 -codec copy "$output"

if [ -e "$metadata" ]; then
    rm "$metadata"
fi
