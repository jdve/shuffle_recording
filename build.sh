#!/bin/bash

set -e

nimble build

cd ./bin
rm -rf *.workflow

cp -r ~/Library/Services/Shuffle\ Recording.workflow .

FFMPEG=ffmpeg
FFMPEG_ARCHIVE=ffmpeg.zip
FFMPEG_URL=https://evermeet.cx/ffmpeg/getrelease/zip

if [ ! -e "$FFMPEG" ]; then
   curl -L $FFMPEG_URL --output $FFMPEG_ARCHIVE
   unzip $FFMPEG_ARCHIVE
   rm $FFMPEG_ARCHIVE
fi

RESOURCES=Shuffle\ Recording.workflow/Contents/Resources

rm -rf "$RESOURCES"
mkdir -p "$RESOURCES"

cp $FFMPEG "$RESOURCES"
chmod +x "$RESOURCES/$FFMPEG"

cp shuffle_recording "$RESOURCES"

