#!/usr/bin/env bash

function xcursor {
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
}

function hyprcursor {
    DEST_DIR=$HOME/.local/share/icons
    mkdir -p $DEST_DIR

    if [ -d "$DEST_DIR/vimix-kanagawa-hyprcursors-wave" ]; then
        rm -rf "$DEST_DIR/vimix-kanagawa-hyprcursors-wave"
    fi

    if [ -d "$DEST_DIR/vimix-kanagawa-hyprcursors-lotus" ]; then
        rm -rf "$DEST_DIR/vimix-kanagawa-hyprcursors-lotus"
    fi

    cp -r hyprcursor/vimix-kanagawa-hyprcursors-wave $DEST_DIR/vimix-kanagawa-hyprcursors-wave
    cp -r hyprcursor/vimix-kanagawa-hyprcursors-lotus $DEST_DIR/vimix-kanagawa-hyprcursors-lotus

    echo "Finished..."

    # Warn user if running as root
    if [ "$UID" -eq "0" ]; then
        echo -e "\nHyprcursors are not installed system-wide due to potential permission issues."
        echo -e "If you are running this script with sudo, try running it without."
    fi
}

if [ "$1" = "all" ]; then
    xcursor
    hyprcursor
elif [ "$1" = "xcursor" ]; then
    xcursor
elif [ "$1" = "hyprcursor" ]; then
    hyprcursor
else
    echo -e "Specify one of \"xcursor\" or \"hyprcursor\", or provide no arguments to install both"
    exit 1
fi
