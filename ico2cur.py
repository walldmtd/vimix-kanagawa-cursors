import sys
from pathlib import Path
from collections import defaultdict

def read_hotspots(config_file: str) -> defaultdict[int, list[tuple[int, int]]]:
    hotspots = defaultdict(list)
    with open(config_file, "r") as f:
        for line in f:
            args = line.split(" ")
            hotspots[int(args[0])].append((int(args[1]), int(args[2])))
    return hotspots

def read_frametimes(config_file: str, num_frames: int) -> list[int]:
    # Assumes entries in config file are grouped by size and sorted by frame order
    with open(config_file, "r") as f:
        frames = [next(f) for _ in range(num_frames)]

    # Collect frame times from config
    frame_times = []
    for frame in frames:
        args = frame.split(" ")
        frame_times.append(int(args[4]))
    return frame_times

def edit_data(data: bytearray, hotspots: defaultdict[int, list], index: int = 0):
    # Using .ico file spec from https://en.wikipedia.org/wiki/ICO_(file_format)

    # Change image type (offset 2, size 2) to .cur (2)
    data[2:4] = int.to_bytes(2, length=2, byteorder="little")

    # Set hotspots
    # Number of images (offset 4, size 2)
    num_images = int.from_bytes(data[4:6], byteorder="little")
    for i in range(num_images):
        entry_start = 6 + i * 16 # ICONDIR size + i * ICONDIRENTRY size

        # Image width (offset 0, size 1)
        size = int.from_bytes(data[entry_start:entry_start+1], byteorder="little")
        if size == 0:
            size = 256

        # Set hotspot x (offset 4, size 2) and hotspot y (offset 6, size 2)
        data[entry_start+4:entry_start+6] = int.to_bytes(hotspots[size][index][0],
                                                         length=2,
                                                         byteorder="little")
        data[entry_start+6:entry_start+8] = int.to_bytes(hotspots[size][index][1],
                                                         length=2,
                                                         byteorder="little")

def convert_cur(in_file: str, hotspots: defaultdict[int, list]) -> bytearray:
    with open(in_file, "rb") as f:
        data = bytearray(f.read())

    edit_data(data, hotspots)

    return data

def convert_ani(in_files:   list[str],
                hotspots:   defaultdict[int, list[tuple[int, int]]],
                frametimes: list[int]) -> bytearray:
    frame_data = []
    for in_file in in_files:
        with open(in_file, "rb") as f:
            frame_data.append(bytearray(f.read()))
    
    for i, frame in enumerate(frame_data):
        edit_data(frame, hotspots, i)


    ## Build .ani file

    # .ani file spec
    # Based on the file spec from https://www.gdgsoft.com/anituner/help/aniformat.htm
    #   and data in aero_busy.ani from the default Windows cursors

	# "RIFF" {Length of File}
	# "ACON"
	# "anih" {Length of ANI header (36 bytes)} {Data}
	# "rate" {Length of rate block} {Data}: each rate is a long
	# "LIST" {Length of List}
	# "fram"
	# "icon" {Length of Icon} {Data}
	# ...
	# "icon" {Length of Icon} {Data}

    # {Length of...} are 4 bytes
    # Lengths are the number of bytes AFTER length specifier
	# List length includes "fram"
    # Flags for ANI header: 0x0001

    data = bytearray()

    # RIFF identifier
    data.extend("RIFF".encode("ASCII"))
    data.extend(int.to_bytes(0, length=4, byteorder="little")) # File length placeholder

    # ACON
    data.extend("ACON".encode("ASCII"))

    # ANI header
    data.extend("anih".encode("ASCII"))
    data.extend(int.to_bytes(36, length=4, byteorder="little")) # ANI header chunk size (RIFF)
    data.extend(int.to_bytes(36, length=4, byteorder="little")) # ANI header size (inside header)
    data.extend(int.to_bytes(len(frame_data), length=4, byteorder="little")) # Number of icons
    data.extend(int.to_bytes(len(frame_data), length=4, byteorder="little")) # Number of frames
    data.extend(int.to_bytes(0, length=4, byteorder="little")) # Reserved
    data.extend(int.to_bytes(0, length=4, byteorder="little")) # Reserved
    data.extend(int.to_bytes(0, length=4, byteorder="little")) # Reserved
    data.extend(int.to_bytes(0, length=4, byteorder="little")) # Reserved
    data.extend(int.to_bytes(3, length=4, byteorder="little")) # Default frame length (Jiffies)
    data.extend(int.to_bytes(1, length=4, byteorder="little")) # Flags (Windows icon/cursor animation)

    # Frame rates
    data.extend("rate".encode("ASCII"))
    data.extend(int.to_bytes(4 * len(frametimes), length=4, byteorder="little")) # rate chunk size (RIFF)
    for frametime in frametimes:
        data.extend(int.to_bytes(frametime, length=4, byteorder="little"))

    # Icon list
    list_len = (4 # "fram"
                + 8 * len(frame_data) # Icon identifiers
                + sum(map(len, frame_data))) # Icon data
    data.extend("LIST".encode("ASCII"))
    data.extend(int.to_bytes(list_len, length=4, byteorder="little")) # Icon list chunk size (RIFF)
    data.extend("fram".encode("ASCII"))
    for frame in frame_data:
        data.extend("icon".encode("ASCII"))
        data.extend(int.to_bytes(len(frame), length=4, byteorder="little")) # Frame data size
        data.extend(frame)
    
    # Set total file length (not including RIFF identifier)
    data[4:8] = int.to_bytes(len(data) - 8, length=4, byteorder="little")

    return data

def main():
    # Process input parameters
    in_files = sys.argv[1:-2]
    num_frames = len(in_files)
    config_file = sys.argv[-2]
    out_file = sys.argv[-1]

    if config_file[-7:] == ".cursor":
        data = convert_cur(in_files[0], read_hotspots(config_file))
    elif config_file[-10:] == ".animation":
        data = convert_ani(in_files,
                           read_hotspots(config_file),
                           read_frametimes(config_file, num_frames))
    else: return

    with open(out_file, "wb+") as f:
        f.write(data)

if __name__ == "__main__":
    main()
