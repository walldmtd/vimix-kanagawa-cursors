#!/usr/bin/env bash

# Remove old packages
if [ -d "package" ]; then
    rm -rf package
fi

mkdir package

# Package xcursors
if [ -d "xcursor" ]; then
    cd xcursor
    for theme in *; do
        tar -czf ../package/"$theme".tar.gz "$theme"
    done
    cd ..
fi

# Package hyprcursors
if [ -d "hyprcursor" ]; then
    cd hyprcursor
    for theme in *; do
        tar -czf ../package/"$theme".tar.gz "$theme"
    done
    cd ..
fi