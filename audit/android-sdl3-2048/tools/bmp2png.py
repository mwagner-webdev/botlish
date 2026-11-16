#!/usr/bin/env python3
"""bmp2png.py BMP PNG -- converts an uncompressed 24- or 32-bit BMP (the frames SDL's offscreen
video driver saves, SDL_VIDEO_OFFSCREEN_SAVE_FRAMES) to an 8-bit RGB PNG for screen.py; the
standard library only (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Rendering")."""
import struct, sys, zlib
d = open(sys.argv[1], "rb").read()
off = struct.unpack("<I", d[10:14])[0]
w, h = struct.unpack("<ii", d[18:26])
bpp = struct.unpack("<H", d[28:30])[0] // 8
stride = (w * bpp + 3) & ~3
rows = []
for y in range(abs(h)):
    sy = (abs(h) - 1 - y) if h > 0 else y
    line = d[off + sy * stride: off + sy * stride + w * bpp]
    out = bytearray()
    for x in range(w):
        b, g, r = line[x * bpp], line[x * bpp + 1], line[x * bpp + 2]
        out += bytes((r, g, b))
    rows.append(b"\0" + bytes(out))
def chunk(t, b): return struct.pack(">I", len(b)) + t + b + struct.pack(">I", zlib.crc32(t + b) & 0xffffffff)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, abs(h), 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(b"".join(rows))) + chunk(b"IEND", b"")
open(sys.argv[2], "wb").write(png)
