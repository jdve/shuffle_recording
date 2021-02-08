#!/bin/bash

set -e

nimble build

cd ./bin
rm -rf *.workflow

cp -r ~/Library/Services/Shuffle\ Recording.workflow .

RESOURCES=Shuffle\ Recording.workflow/Contents/Resources

rm -rf "$RESOURCES"
mkdir -p "$RESOURCES"

cp shuffle_recording "$RESOURCES"

