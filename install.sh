#!/usr/bin/env bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
  mkdir -p $DEST_DIR
fi

if [ -d "$DEST_DIR/vimix-kanagawa-cursors" ]; then
  rm -rf "$DEST_DIR/vimix-kanagawa-cursors"
fi

if [ -d "$DEST_DIR/vimix-kanagawa-lotus-cursors" ]; then
  rm -rf "$DEST_DIR/vimix-kanagawa-lotus-cursors"
fi

cp -r dist/ $DEST_DIR/vimix-kanagawa-cursors
cp -r dist-lotus/ $DEST_DIR/vimix-kanagawa-lotus-cursors

echo "Finished..."

