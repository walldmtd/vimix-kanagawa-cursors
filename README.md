# Vimix Kanagawa cursors

![Logo](logo.png)

This is an x-cursor theme based on [Vimix cursors](https://github.com/vinceliuice/Vimix-cursors),
recoloured using the [Kanagawa colourscheme](https://github.com/rebelot/kanagawa.nvim).

## Installation

To install the cursor theme simply copy the compiled theme to your icons
directory. For local user installation:

```sh
./install.sh
```

For system-wide installation for all users:

```sh
sudo ./install.sh
```

Then set the theme with your preferred desktop tools.

### Windows

The Windows build comes with an INF file to make installation easy.

 1. Open `.windows/` folder in Explorer, and right click on `install.inf`.
 1. Click 'Install' from the context menu, and authorise the modifications to your system.
 1. Press the `Windows Key and R` at the same time and type `main.cpl` in the run promt and press `Ok`.
 1. Go to `Pointers` and select `Vimix Kanagawa Cursors` under the Scheme category.
 1. Click 'Apply'.

## Building from source

You'll find everything you need to build and modify this cursor set in
the `src/` directory. To build the xcursor theme from the SVG source
run:

```sh
./build.sh
```

This will generate the pixmaps and appropriate aliases.
The freshly compiled cursor theme will be located in `dist/`

### Building depends requirement

- xorg-xcursorgen.
- python-cairosvg.

Fedora/RedHat distros:

```sh
dnf install xorg-xcursorgen python-cairosvg
```

Ubuntu/Mint/Debian distros:

```sh
sudo apt-get install xorg-xcursorgen python-cairosvg
```

ArchLinux/Manjaro:

```sh
pacman -S xorg-xcursorgen python-cairosvg
```

Other:
Search for the engines in your distributions repository or install the depends from source.

## Preview

![Vimix Kanagawa cursors preview](preview.png)
![Vimix Kanagawa Lotus cursors preview](preview-lotus.png)
