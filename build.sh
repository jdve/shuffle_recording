#!/bin/bash

set -e

nimble build

cd ./bin
rm -rf *.workflow

cp -r ~/Library/Services/Shuffle\ Recording.workflow .

FFMPEG=ffmpeg
FFMPEG_FILE=ffmpeg-95111-g87ddf9f1ef.zip
FFMPEG_URL=https://evermeet.cx/ffmpeg/$FFMPEG_FILE

if [ ! -e "$FFMPEG" ]; then
   curl $FFMPEG_URL --output $FFMPEG_FILE
   unzip $FFMPEG_FILE
fi

rm -rf Shuffle\ Recording.worflow/Contents/Resources
mkdir -p Shuffle\ Recording.workflow/Contents/Resources

cp $FFMPEG Shuffle\ Recording.workflow/Contents/Resources
cp shuffle_recording Shuffle\ Recording.workflow/Contents/Resources

