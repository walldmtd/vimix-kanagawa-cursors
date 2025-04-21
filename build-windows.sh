#!/usr/bin/env bash

# check command avalibility
has_command() {
  "$1" -v $1 > /dev/null 2>&1
}

if [ ! "$(which cairosvg 2> /dev/null)" ]; then
  echo cairosvg needs to be installed to generate png files.
  if has_command zypper; then
    sudo zypper in python-cairosvg
  elif has_command apt; then
    sudo apt install python-cairosvg
  elif has_command dnf; then
    sudo dnf install -y python-cairosvg
  elif has_command dnf; then
    sudo dnf install python-cairosvg
  elif has_command pacman; then
    sudo pacman -S --noconfirm python-cairosvg
  fi
fi

if [ ! "$(which cairosvg 2> /dev/null)" ]; then
  echo imagemagick needs to be installed to generate .ico files.
  if has_command zypper; then
    sudo zypper in imagemagick
  elif has_command apt; then
    sudo apt install imagemagick
  elif has_command dnf; then
    sudo dnf install -y imagemagick
  elif has_command dnf; then
    sudo dnf install imagemagick
  elif has_command pacman; then
    sudo pacman -S --noconfirm imagemagick
  fi
fi

function create {
	sizes=(32 48 64 96 128)

	# Create pngs from .cursor
	cd "$SRC"/windows
	mkdir -p ${sizes[@]}
	cd config
	for file in *.cursor; do
		while read line; do
			IFS=" " read -a args <<< "$line"
			echo -e "Generating ${args[3]} ${args[0]}"
			cairosvg -f png -o "../${args[0]}/${args[3]}" --output-width ${args[0]} --output-height ${args[0]} "../../svg/$1/${args[3]%.png}.svg"
		done < $file
	done

	# Create pngs from .animation
	# Assumes entries in config files are grouped by size and sorted by frame order
	for file in *.animation; do
		filename=$file
		filename="${filename##*/}"
		filename="${filename%.*}"

		frame_num=0
		size=""
		while read line; do
			IFS=" " read -a args <<< "$line"

			if [[ "$size" != "${args[0]}" ]]; then
				frame_num=0
				size="${args[0]}"
			fi

			echo -e "Generating $filename/$frame_num.png ${args[0]}"
			mkdir -p "../${args[0]}/$filename"
			cairosvg -f png -o "../${args[0]}/$filename/$frame_num.png" --output-width ${args[0]} --output-height ${args[0]} "../../svg/$1/${args[3]%.png}.svg"

			((frame_num++))
		done < $file
	done

	# Create .cur files from .cursor
	echo -ne "Generating cursors...\\r"
	cd $SRC/..
	mkdir -p src/windows/ico
	for file in src/windows/config/*.cursor; do
		filename=$file
		filename="${filename##*/}"
		filename="${filename%.*}"

		pngs=()
		while read line; do
			IFS=" " read -a args <<< "$line"
			pngs+=("src/windows/${args[0]}/${args[3]}")
		done < $file

		magick ${pngs[@]} src/windows/ico/$filename.ico

		mkdir -p windows/vimix-kanagawa-windows-cursors-$1
		python ico2cur.py src/windows/ico/$filename.ico $file windows/vimix-kanagawa-windows-cursors-$1/$filename.cur
	done
	echo -e "Generating cursors... DONE"

	# Create .ani files from .animation
	echo -ne "Generating animated cursors...\\r"
	for file in src/windows/config/*.animation; do
		filename=$file
		filename="${filename##*/}"
		filename="${filename%.*}"

		num_frames=$(ls "src/windows/${sizes[0]}/$filename" | wc -l)

		mkdir -p src/windows/ico/$filename
		frames=()
		for frame in $(seq 0 $(($num_frames - 1))); do
			pngs=("${sizes[@]/#/src/windows/}")
			pngs=("${pngs[@]/%//$filename/$frame.png}")
			magick ${pngs[@]} src/windows/ico/$filename/$frame.ico

			frames+=("src/windows/ico/$filename/$frame.ico")
		done

		mkdir -p windows/vimix-kanagawa-windows-cursors-$1
		python ico2cur.py ${frames[@]} $file windows/vimix-kanagawa-windows-cursors-$1/$filename.ani
	done
	echo -e "Generating animated cursors... DONE"

	# Copy installer
	echo -ne "Copying installer...\\r"
	cp src/windows/install-$1.inf windows/vimix-kanagawa-windows-cursors-$1/install.inf
	echo -e "Copying installer... DONE"
}

function cleanup {
	cd "$SRC"/windows
	rm -rf 32 48 64 96 128 ico
}

# generate pixmaps from svg source
SRC=$PWD/src
THEME="Vimix Kanagawa Cursors - Wave"

create wave

THEME="Vimix Kanagawa Cursors - Lotus"

create lotus

cleanup
