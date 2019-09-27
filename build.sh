#!/bin/bash

set -e

nimble build

FFMPEG=bin/ffmpeg
FFMPEG_FILE=ffmpeg-95111-g87ddf9f1ef.zip
FFMPEG_URL=https://evermeet.cx/ffmpeg/$FFMPEG_FILE

if [ ! -e "$FFMPEG" ]; then
   mkdir -p bin
   curl $FFMPEG_URL --output bin/$FFMPEG_FILE
   unzip bin/$FFMPEG_FILE -d bin
fi

rm -rf Shuffle\ Recording.worflow/Contents/Resources
mkdir -p Shuffle\ Recording.workflow/Contents/Resources

cp $FFMPEG Shuffle\ Recording.workflow/Contents/Resources
cp bin/shuffle_recording Shuffle\ Recording.workflow/Contents/Resources

