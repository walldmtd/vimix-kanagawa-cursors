if [ ! "$(which hyprcursor-util 2> /dev/null)" ]; then
  echo -e "\'hyprcursor\' needs to be installed to generate the cursors."
  exit 1
fi

function create {
    echo -ne "Generating folder structure...\\r"

    TEMP=$HYPRSRC/temp
    mkdir -p $TEMP
    mkdir -p $TEMP/hyprcursors


    for CUR in $HYPRSRC/*.hl; do
        BASENAME=$CUR
		BASENAME="${BASENAME##*/}"
		BASENAME="${BASENAME%.*}"

        mkdir -p $TEMP/hyprcursors/$BASENAME

        # Copy svg files to new directory
        while read LINE; do
            REGEX="define_size.*,[ ]*([^ ]+)\.svg.*"
            if [[ $LINE =~ $REGEX ]]; then
                SVGNAME="${BASH_REMATCH[1]}"
                cp $SVGSRC/$1/$SVGNAME.svg $TEMP/hyprcursors/$BASENAME
            fi
        done < $CUR

        # Copy meta file
        cp $CUR $TEMP/hyprcursors/$BASENAME/meta.hl
    done

    # Create manifest
    MANIFEST=$TEMP/manifest.hl
    touch $MANIFEST
    echo "cursors_directory = hyprcursors" > $MANIFEST
    echo "name = $THEME" >> $MANIFEST
    echo "description = Kanagawa recolour of the Vimix cursor theme by vinceliuice" >> $MANIFEST

    echo "Generating folder structure... DONE"

    # Generate cursor theme
    mkdir -p $OUT/vimix-kanagawa-hyprcursors-$1
    hyprcursor-util --create $TEMP --output $OUT/vimix-kanagawa-hyprcursors-$1

    # Remove output subdirectory
    mv "$OUT/vimix-kanagawa-hyprcursors-$1/theme_$THEME"/* $OUT/vimix-kanagawa-hyprcursors-$1
    rmdir "$OUT/vimix-kanagawa-hyprcursors-$1/theme_$THEME"
}

function cleanup {
    rm -rf $HYPRSRC/temp
}

SVGSRC=$PWD/src/svg
HYPRSRC=$PWD/src/hyprcursor
OUT=$PWD/hyprcursor

# Remove previous build (avoids prompt with hyprcursor-util)
if [ -d $OUT ]; then
    rm -rf $OUT
    mkdir -p $OUT
fi

# Build themes
THEME="Vimix Kanagawa Cursors - Wave"
create wave
THEME="Vimix Kanagawa Cursors - Lotus"
create lotus

cleanup
