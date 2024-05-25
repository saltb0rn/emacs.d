#!/bin/bash

for i in *.mp3; do
    ffmpeg -i "$i" "${i%.mp3}.wav"
done
