#!/usr/bin/env python3
"""xdrive.py -- look at and drive a running X11 application from outside.

A minimal X11 protocol client in Python's standard library only (no Xlib,
no xdotool, no ImageMagick: the environment has none of them). It talks
to the X server named by DISPLAY over its Unix socket and can:

  list                      every top-level window: id, title, geometry, map state
  shot TITLE FILE.png       a screenshot of the window titled TITLE (PNG),
                            and a coarse text rendering of it on stdout
  click TITLE X Y           a real left click (XTEST) at X, Y of the window
  type TEXT                 real key presses (XTEST) typing TEXT
  close TITLE               ask the window to close, as a window manager's
                            close button does (WM_DELETE_WINDOW)
  wait TITLE [SECONDS]      wait until a window titled TITLE is mapped
  zoom FILE.png X Y W H     a region of a screenshot this tool wrote, one
                            character per pixel, to read text in it

Input goes through the XTEST extension: the X server generates the same
events a real mouse and keyboard would, so the application cannot tell
them apart from a person's.
"""
import os
import socket
import struct
import sys
import time
import zlib


class X:
    def __init__(self, display=None):
        display = display or os.environ.get("DISPLAY", ":0")
        number = display.split(":")[1].split(".")[0]
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.connect("/tmp/.X11-unix/X" + number)
        self.sock.sendall(struct.pack("<BxHHHHxx", 0x6C, 11, 0, 0, 0))
        head = self.recv(8)
        if head[0] != 1:
            extra = self.recv(struct.unpack_from("<H", head, 6)[0] * 4)
            raise SystemExit("X server refused the connection: %r" % extra)
        data = self.recv(struct.unpack_from("<H", head, 6)[0] * 4)
        vendor_len, = struct.unpack_from("<H", data, 16)
        nscreens, nformats = data[20], data[21]
        self.min_keycode, self.max_keycode = data[26], data[27]
        off = 32 + ((vendor_len + 3) & ~3) + 8 * nformats
        self.root, = struct.unpack_from("<I", data, off)
        self.seq = 0
        self.atoms = {}
        self.xtest = None

    def recv(self, n):
        out = b""
        while len(out) < n:
            chunk = self.sock.recv(n - len(out))
            if not chunk:
                raise SystemExit("X server closed the connection")
            out += chunk
        return out

    def request(self, data, reply=True):
        self.sock.sendall(data)
        self.seq = (self.seq + 1) & 0xFFFF
        if not reply:
            return None
        while True:
            msg = self.recv(32)
            if msg[0] == 0:
                raise RuntimeError("X error %d (request %d, value 0x%x)" % (msg[1], msg[10], struct.unpack_from("<I", msg, 4)[0]))
            if msg[0] == 1:
                extra = struct.unpack_from("<I", msg, 4)[0] * 4
                return msg + self.recv(extra)
            # an event: not asked for; skip it

    def sync(self):
        self.request(struct.pack("<BxH", 43, 1))  # GetInputFocus: a round trip

    def atom(self, name):
        if name not in self.atoms:
            b = name.encode()
            pad = (4 - len(b) % 4) % 4
            r = self.request(struct.pack("<BBHHxx", 16, 0, 2 + (len(b) + pad) // 4, len(b)) + b + b"\0" * pad)
            self.atoms[name] = struct.unpack_from("<I", r, 8)[0]
        return self.atoms[name]

    def children(self, window):
        r = self.request(struct.pack("<BxHI", 15, 2, window))
        n, = struct.unpack_from("<H", r, 16)
        return list(struct.unpack_from("<%dI" % n, r, 32))

    def property(self, window, name):
        r = self.request(struct.pack("<BBHIIIII", 20, 0, 6, window, self.atom(name), 0, 0, 1 << 20))
        fmt = r[1]
        n, = struct.unpack_from("<I", r, 16)
        size = {8: 1, 16: 2, 32: 4}.get(fmt, 0)
        return fmt, r[32:32 + n * size]

    def title(self, window):
        fmt, value = self.property(window, "_NET_WM_NAME")
        if not value:
            fmt, value = self.property(window, "WM_NAME")
        return value.decode("utf-8", "replace")

    def geometry(self, window):
        r = self.request(struct.pack("<BxHI", 14, 2, window))
        w, h = struct.unpack_from("<HH", r, 16)
        t = self.request(struct.pack("<BxHIIhh", 40, 4, window, self.root, 0, 0))
        x, y = struct.unpack_from("<hh", t, 12)
        return x, y, w, h

    def mapped(self, window):
        r = self.request(struct.pack("<BxHI", 3, 2, window))
        return r[26] == 2  # IsViewable

    def find(self, title):
        for w in self.children(self.root):
            if self.title(w) == title:
                return w
        return None

    def image(self, x, y, w, h):
        r = self.request(struct.pack("<BBHIhhHHI", 73, 2, 5, self.root, x, y, w, h, 0xFFFFFFFF))
        data = r[32:]
        rgb = bytearray()
        for row in range(h):
            line = data[row * w * 4:(row + 1) * w * 4]
            for i in range(0, len(line), 4):
                rgb += bytes((line[i + 2], line[i + 1], line[i]))
        return rgb

    def fake(self, kind, detail, x=0, y=0):
        if self.xtest is None:
            name = b"XTEST"
            r = self.request(struct.pack("<BxHHxx", 98, 2 + 2, len(name)) + name + b"\0\0\0")
            if not r[8]:
                raise SystemExit("the X server has no XTEST extension")
            self.xtest = r[9]
        self.request(struct.pack("<BBHBBxxIIxxxxxxxxhhxxxxxxxx", self.xtest, 2, 9, kind, detail, 0, self.root, x, y), reply=False)

    def keymap(self):
        count = self.max_keycode - self.min_keycode + 1
        r = self.request(struct.pack("<BxHBBxx", 101, 2, self.min_keycode, count))
        per = r[1]
        syms = struct.unpack_from("<%dI" % (count * per), r, 32)
        table = {}
        for i in range(count):
            row = syms[i * per:(i + 1) * per]
            for level, sym in enumerate(row[:2]):
                if sym and (sym, ) not in table:
                    table.setdefault(sym, (self.min_keycode + i, level))
        return table


def png(path, w, h, rgb):
    raw = b"".join(b"\0" + bytes(rgb[y * w * 3:(y + 1) * w * 3]) for y in range(h))
    def chunk(kind, body):
        return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", zlib.crc32(kind + body) & 0xFFFFFFFF)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(raw, 9)))
        f.write(chunk(b"IEND", b""))


def text_rendering(w, h, rgb, columns=140):
    """A coarse picture: one character per cell, darker cells denser."""
    ramp = " .:-=+*#%@"
    cw = max(1, w // columns)
    ch = cw * 2
    # Light-on-dark or dark-on-light: measure against the most common
    # luminance (the background), so text and edges stand out either way.
    lum = [(0.299 * rgb[i] + 0.587 * rgb[i + 1] + 0.114 * rgb[i + 2]) for i in range(0, len(rgb), 3)]
    hist = {}
    for v in lum:
        hist[int(v) // 8] = hist.get(int(v) // 8, 0) + 1
    background = max(hist, key=hist.get) * 8 + 4
    lines = []
    for cy in range(0, h - ch + 1, ch):
        line = ""
        for cx in range(0, w - cw + 1, cw):
            total = 0.0
            for yy in range(cy, cy + ch):
                base = yy * w
                for xx in range(cx, cx + cw):
                    total += abs(lum[base + xx] - background)
            v = total / (cw * ch) / 128.0
            line += ramp[min(len(ramp) - 1, int(v * (len(ramp) - 1) * 2.5))]
        lines.append(line.rstrip())
    return "\n".join(lines)


def read_png(path):
    """The RGB pixels of a PNG this tool wrote (8-bit RGB, filter 0)."""
    with open(path, "rb") as f:
        data = f.read()
    pos, idat, w, h = 8, b"", 0, 0
    while pos < len(data):
        n, = struct.unpack_from(">I", data, pos)
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + n]
        if kind == b"IHDR":
            w, h = struct.unpack_from(">II", body, 0)
        elif kind == b"IDAT":
            idat += body
        pos += 12 + n
    raw = zlib.decompress(idat)
    rgb = bytearray()
    for y in range(h):
        rgb += raw[y * (w * 3 + 1) + 1:(y + 1) * (w * 3 + 1)]
    return w, h, rgb


def zoom(w, h, rgb, x0, y0, zw, zh):
    ramp = " .:-=+*#%@"
    lum = lambda i: 0.299 * rgb[i] + 0.587 * rgb[i + 1] + 0.114 * rgb[i + 2]
    region = [[lum(3 * (y * w + x)) for x in range(x0, min(w, x0 + zw))] for y in range(y0, min(h, y0 + zh))]
    flat = sorted(v for row in region for v in row)
    background = flat[len(flat) // 2]
    out = []
    for row in region:
        out.append("".join(ramp[min(9, int(abs(v - background) / 128.0 * 9 * 1.5))] for v in row).rstrip())
    return "\n".join(out)


def need(x, title):
    w = x.find(title)
    if w is None:
        raise SystemExit("no window titled %r" % title)
    return w


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    cmd = argv[0]
    if cmd == "zoom":
        w, h, rgb = read_png(argv[1])
        print(zoom(w, h, rgb, *[int(a) for a in argv[2:6]]))
        return 0
    x = X()
    if cmd == "list":
        for w in x.children(x.root):
            gx, gy, gw, gh = x.geometry(w)
            print("0x%08x %-8s %4d,%-4d %4dx%-4d %r" % (w, "mapped" if x.mapped(w) else "unmapped", gx, gy, gw, gh, x.title(w)))
        return 0
    if cmd == "wait":
        title = argv[1]
        limit = float(argv[2]) if len(argv) > 2 else 60.0
        end = time.time() + limit
        while time.time() < end:
            w = x.find(title)
            if w is not None and x.mapped(w):
                gx, gy, gw, gh = x.geometry(w)
                print("window 0x%08x %r mapped at %d,%d size %dx%d" % (w, title, gx, gy, gw, gh))
                return 0
            time.sleep(0.25)
        print("no mapped window titled %r after %g s" % (title, limit))
        return 1
    if cmd == "shot":
        w = need(x, argv[1])
        gx, gy, gw, gh = x.geometry(w)
        rgb = x.image(gx, gy, gw, gh)
        png(argv[2], gw, gh, rgb)
        colours = len(set(bytes(rgb[i:i + 3]) for i in range(0, len(rgb), 3)))
        print("%s: %dx%d, %d distinct colours" % (argv[2], gw, gh, colours))
        print(text_rendering(gw, gh, rgb))
        return 0
    if cmd == "click":
        w = need(x, argv[1])
        gx, gy, gw, gh = x.geometry(w)
        px, py = gx + int(argv[2]), gy + int(argv[3])
        x.fake(6, 0, px, py)      # MotionNotify, absolute
        x.sync()
        time.sleep(0.05)
        x.fake(4, 1)              # ButtonPress, button 1
        x.sync()
        time.sleep(0.05)
        x.fake(5, 1)              # ButtonRelease
        x.sync()
        return 0
    if cmd == "type":
        table = x.keymap()
        shift = table.get(0xFFE1, (None, 0))[0]
        for c in argv[1]:
            sym = {"\n": 0xFF0D}.get(c, ord(c))
            if sym not in table:
                raise SystemExit("no key types %r" % c)
            code, level = table[sym]
            if level and shift:
                x.fake(2, shift)
            x.fake(2, code)
            x.fake(3, code)
            if level and shift:
                x.fake(3, shift)
            x.sync()
            time.sleep(0.03)
        return 0
    if cmd == "close":
        w = need(x, argv[1])
        fmt, protocols = x.property(w, "WM_PROTOCOLS")
        delete = x.atom("WM_DELETE_WINDOW")
        listed = struct.unpack("<%dI" % (len(protocols) // 4), protocols)
        if delete not in listed:
            raise SystemExit("the window does not take WM_DELETE_WINDOW")
        event = struct.pack("<BBHII5I", 33, 32, 0, w, x.atom("WM_PROTOCOLS"), delete, 0, 0, 0, 0)
        x.request(struct.pack("<BBHII", 25, 0, 11, w, 0) + event, reply=False)
        x.sync()
        return 0
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
