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

if [ -d "$DEST_DIR/vimix-kanagawa-cursors-wave" ]; then
  rm -rf "$DEST_DIR/vimix-kanagawa-cursors-wave"
fi

if [ -d "$DEST_DIR/vimix-kanagawa-cursors-lotus" ]; then
  rm -rf "$DEST_DIR/vimix-kanagawa-cursors-lotus"
fi

cp -r xcursor/vimix-kanagawa-cursors-wave $DEST_DIR/vimix-kanagawa-cursors-wave
cp -r xcursor/vimix-kanagawa-cursors-lotus $DEST_DIR/vimix-kanagawa-cursors-lotus

echo "Finished..."

