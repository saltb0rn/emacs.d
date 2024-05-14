#!/bin/bash

# merge-metadata.sh VIDEO CHAPTER

# metadata=$(mktemp /tmp/FFMETADATAFILE.$$.XXXXXXXXXX)
metadata=FFMETADATAFILE
chapter="${2}-chapters.txt"
output="${1%%.*}-OUTPUT.${1##*.}"

display_help_info () {
    echo -e "\nUSAGE: merge-metadata.sh VIDEO CHAPTER"
}

release_temp_metadata () {
    if [ -e "$metadata" ]; then
        rm "$metadata"
    fi
}

if (( "$#" != 2 )); then
    display_help_info
    exit 1
fi

if ! ffmpeg -i "$1" -f ffmetadata $metadata; then
    release_temp_metadata
    exit 1
fi

if ! $(dirname -- "$0")/video_chapters_helper.el -f "$2" > /dev/null; then
    release_temp_metadata
    exit 1
fi

cat "$chapter" >> "$metadata"

ffmpeg -i "$1" -i "$metadata" -map_metadata 1 -codec copy "$output"

release_temp_metadata
