#!/usr/bin/env python3
"""screen.py -- checks a screenshot of the Botlish SDL3 2048 application
against the game it should show (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-
MILESTONE-1.md, "Rendering"): the application's own layout line ("2048:
layout WxH board X Y SIDE gap G restart ...") locates the sixteen cells, and
each cell's color, sampled away from its number, must be the color of the
tile the snapshot holds there -- an independent statement of the palette,
not the application's code.

    python3 -I screen.py SCREENSHOT.png "LAYOUT LINE" "SNAPSHOT" [OFFSET-Y]

Prints one line per cell that differs and a summary; exit status 1 when any
cell differs (a frame that does not show the game fails, whatever the log
says). PNG decoding is the standard library's zlib: 8-bit RGB or RGBA,
non-interlaced, as Android's screencap writes it."""
import re
import struct
import sys
import zlib

PALETTE = {0: 0xcdc1b4, 2: 0xeee4da, 4: 0xede0c8, 8: 0xf2b179, 16: 0xf59563, 32: 0xf67c5f,
           64: 0xf65e3b, 128: 0xedcf72, 256: 0xedcc61, 512: 0xedc850, 1024: 0xedc53f, 2048: 0xedc22e}
BEYOND = 0x3c3a32
TOLERANCE = 18


def png(path):
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit("screen: %s is no PNG" % path)
    pos, idat, width = 8, b"", 0
    while pos < len(data):
        n, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + n]
        if kind == b"IHDR":
            width, height, depth, ctype, _, _, interlace = struct.unpack(">IIBBBBB", body)
            if depth != 8 or ctype not in (2, 6) or interlace:
                raise SystemExit("screen: unsupported PNG (depth %d, color type %d, interlace %d)" % (depth, ctype, interlace))
            bpp = 3 if ctype == 2 else 4
        elif kind == b"IDAT":
            idat += body
        pos += 12 + n
    raw = zlib.decompress(idat)
    stride = width * bpp
    rows, prev, i = [], bytearray(stride), 0
    for _ in range(height):
        f = raw[i]
        line = bytearray(raw[i + 1:i + 1 + stride])
        i += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(line)
        prev = line
    return width, height, bpp, rows


def pixel(img, x, y):
    width, height, bpp, rows = img
    if not (0 <= x < width and 0 <= y < height):
        return None
    line = rows[y]
    return (line[x * bpp], line[x * bpp + 1], line[x * bpp + 2])


def near(rgb, color):
    want = ((color >> 16) & 255, (color >> 8) & 255, color & 255)
    return rgb is not None and all(abs(a - b) <= TOLERANCE for a, b in zip(rgb, want))


def main():
    if len(sys.argv) < 4:
        raise SystemExit("usage: screen.py SCREENSHOT.png LAYOUT-LINE SNAPSHOT [OFFSET-Y]")
    img = png(sys.argv[1])
    m = re.search(r"layout (\d+)x(\d+) board (-?\d+) (-?\d+) (\d+) gap (\d+)", sys.argv[2])
    if not m:
        raise SystemExit("screen: no layout in %r" % sys.argv[2])
    _, _, bx, by, side, gap = (int(v) for v in m.groups())
    offset = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    fields = sys.argv[3].split()
    if len(fields) != 23 or fields[0] != "2048/1":
        raise SystemExit("screen: no snapshot in %r" % sys.argv[3])
    cells = [int(v) for v in fields[7:]]
    cell = (side - gap * 5) / 4
    bad = 0
    for i, value in enumerate(cells):
        row, column = divmod(i, 4)
        x0 = bx + gap + column * (cell + gap)
        y0 = by + gap + row * (cell + gap) + offset
        # A point an eighth into the cell from its top left corner: inside
        # the tile, away from its centered number.
        x, y = int(x0 + cell / 8 + 1), int(y0 + cell / 8 + 1)
        color = PALETTE.get(value, BEYOND)
        rgb = pixel(img, x, y)
        if not near(rgb, color):
            bad += 1
            print("cell %d (row %d, column %d) at %d,%d: %s, not tile %d's #%06x" % (i, row, column, x, y, rgb, value, color))
    print("screen: %d of 16 cells show the snapshot's tiles%s" % (16 - bad, "" if bad == 0 else " (FAIL)"))
    sys.exit(1 if bad else 0)


main()
