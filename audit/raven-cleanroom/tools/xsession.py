#!/usr/bin/env python3
"""xsession.py -- drive a real X11 window from outside the program
(RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, "Real desktop execution").

Only the X server is used: the program under test is never hooked, and
nothing here knows Raven or Botlish. Python's standard library and the
system's libX11.so.6 and libXtst.so.6 (ctypes) are all it needs, so it runs
in the clean room as it is.

    python3 -I xsession.py find TITLE [SECONDS]
        wait for a top-level window named TITLE; print "ID X Y WIDTH HEIGHT"
        (root coordinates)
    python3 -I xsession.py snap ID OUT
        write the window's pixels as a binary PPM; print "WIDTH HEIGHT
        COLORS" (COLORS: how many distinct colors it holds)
    python3 -I xsession.py diff A B
        print how many pixels of the two PPMs differ
    python3 -I xsession.py click ID X Y
        a left click at X, Y of the window, through XTest (the pointer moves
        there, the button goes down and up), as a user's would
    python3 -I xsession.py close ID
        ask the window to close as a window manager does: a ClientMessage
        WM_PROTOCOLS / WM_DELETE_WINDOW

DISPLAY names the display. Exit status 1, with the reason on standard
error, when the display, the window or the libraries are missing.
"""

import ctypes
import ctypes.util
import os
import sys
import time


def die(message):
    sys.stderr.write("xsession: %s\n" % message)
    sys.exit(1)


def library(name, soname):
    try:
        return ctypes.CDLL(soname)
    except OSError:
        die("%s (%s) is not installed" % (name, soname))


x11 = library("libX11", "libX11.so.6")

Window = ctypes.c_ulong
Atom = ctypes.c_ulong


class XWindowAttributes(ctypes.Structure):
    _fields_ = [("x", ctypes.c_int), ("y", ctypes.c_int),
                ("width", ctypes.c_int), ("height", ctypes.c_int),
                ("border_width", ctypes.c_int), ("depth", ctypes.c_int),
                ("visual", ctypes.c_void_p), ("root", Window),
                ("class_", ctypes.c_int), ("bit_gravity", ctypes.c_int),
                ("win_gravity", ctypes.c_int), ("backing_store", ctypes.c_int),
                ("backing_planes", ctypes.c_ulong), ("backing_pixel", ctypes.c_ulong),
                ("save_under", ctypes.c_int), ("colormap", ctypes.c_ulong),
                ("map_installed", ctypes.c_int), ("map_state", ctypes.c_int),
                ("all_event_masks", ctypes.c_long), ("your_event_mask", ctypes.c_long),
                ("do_not_propagate_mask", ctypes.c_long), ("override_redirect", ctypes.c_int),
                ("screen", ctypes.c_void_p)]


class XClientMessageEvent(ctypes.Structure):
    _fields_ = [("type", ctypes.c_int), ("serial", ctypes.c_ulong),
                ("send_event", ctypes.c_int), ("display", ctypes.c_void_p),
                ("window", Window), ("message_type", Atom), ("format", ctypes.c_int),
                ("data", ctypes.c_long * 5)]


class XEvent(ctypes.Union):
    _fields_ = [("xclient", XClientMessageEvent), ("pad", ctypes.c_long * 24)]


x11.XOpenDisplay.restype = ctypes.c_void_p
x11.XOpenDisplay.argtypes = [ctypes.c_char_p]
x11.XDefaultRootWindow.restype = Window
x11.XDefaultRootWindow.argtypes = [ctypes.c_void_p]
x11.XQueryTree.argtypes = [ctypes.c_void_p, Window, ctypes.POINTER(Window), ctypes.POINTER(Window),
                           ctypes.POINTER(ctypes.POINTER(Window)), ctypes.POINTER(ctypes.c_uint)]
x11.XFetchName.argtypes = [ctypes.c_void_p, Window, ctypes.POINTER(ctypes.c_char_p)]
x11.XFree.argtypes = [ctypes.c_void_p]
x11.XGetWindowAttributes.argtypes = [ctypes.c_void_p, Window, ctypes.POINTER(XWindowAttributes)]
x11.XTranslateCoordinates.argtypes = [ctypes.c_void_p, Window, Window, ctypes.c_int, ctypes.c_int,
                                      ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int),
                                      ctypes.POINTER(Window)]
x11.XGetImage.restype = ctypes.c_void_p
x11.XGetImage.argtypes = [ctypes.c_void_p, Window, ctypes.c_int, ctypes.c_int, ctypes.c_uint,
                          ctypes.c_uint, ctypes.c_ulong, ctypes.c_int]
x11.XInternAtom.restype = Atom
x11.XInternAtom.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int]
x11.XSendEvent.argtypes = [ctypes.c_void_p, Window, ctypes.c_int, ctypes.c_long, ctypes.POINTER(XEvent)]
x11.XFlush.argtypes = [ctypes.c_void_p]
x11.XSync.argtypes = [ctypes.c_void_p, ctypes.c_int]


class XImage(ctypes.Structure):
    # The leading fields of XImage (Xlib.h), enough to read a ZPixmap.
    _fields_ = [("width", ctypes.c_int), ("height", ctypes.c_int), ("xoffset", ctypes.c_int),
                ("format", ctypes.c_int), ("data", ctypes.POINTER(ctypes.c_ubyte)),
                ("byte_order", ctypes.c_int), ("bitmap_unit", ctypes.c_int),
                ("bitmap_bit_order", ctypes.c_int), ("bitmap_pad", ctypes.c_int),
                ("depth", ctypes.c_int), ("bytes_per_line", ctypes.c_int),
                ("bits_per_pixel", ctypes.c_int), ("red_mask", ctypes.c_ulong),
                ("green_mask", ctypes.c_ulong), ("blue_mask", ctypes.c_ulong)]


def display():
    name = os.environ.get("DISPLAY", "")
    if not name:
        die("DISPLAY is not set")
    d = x11.XOpenDisplay(name.encode())
    if not d:
        die("cannot open the display %s" % name)
    return d


def children(d, window):
    root, parent = Window(), Window()
    kids = ctypes.POINTER(Window)()
    count = ctypes.c_uint()
    if not x11.XQueryTree(d, window, ctypes.byref(root), ctypes.byref(parent), ctypes.byref(kids), ctypes.byref(count)):
        return []
    found = [kids[i] for i in range(count.value)]
    if kids:
        x11.XFree(kids)
    return found


def name_of(d, window):
    name = ctypes.c_char_p()
    if x11.XFetchName(d, window, ctypes.byref(name)) and name.value is not None:
        text = name.value.decode("utf-8", "replace")
        return text
    return None


def geometry(d, window):
    attributes = XWindowAttributes()
    x11.XGetWindowAttributes(d, window, ctypes.byref(attributes))
    x, y, child = ctypes.c_int(), ctypes.c_int(), Window()
    x11.XTranslateCoordinates(d, window, x11.XDefaultRootWindow(d), 0, 0, ctypes.byref(x), ctypes.byref(y), ctypes.byref(child))
    return x.value, y.value, attributes.width, attributes.height, attributes.map_state


def find(title, seconds):
    d = display()
    deadline = time.time() + seconds
    while True:
        pending = [x11.XDefaultRootWindow(d)]
        while pending:
            window = pending.pop()
            if name_of(d, window) == title:
                x, y, w, h, state = geometry(d, window)
                if state == 2:  # IsViewable
                    print(window, x, y, w, h)
                    return
            pending.extend(children(d, window))
        if time.time() > deadline:
            die("no viewable window named %r after %s s" % (title, seconds))
        time.sleep(0.1)


def snap(window, out):
    d = display()
    window = int(window)
    _, _, w, h, _ = geometry(d, window)
    image = x11.XGetImage(d, window, 0, 0, w, h, 0xFFFFFFFF, 2)  # AllPlanes, ZPixmap
    if not image:
        die("cannot read the window's pixels")
    img = XImage.from_address(image)
    if img.bits_per_pixel != 32:
        die("unexpected %d bits per pixel" % img.bits_per_pixel)
    raw = ctypes.string_at(img.data, img.bytes_per_line * h)
    rgb = bytearray()
    colors = set()
    for row in range(h):
        line = raw[row * img.bytes_per_line: row * img.bytes_per_line + 4 * w]
        for col in range(w):
            b, g, r = line[4 * col], line[4 * col + 1], line[4 * col + 2]
            rgb += bytes((r, g, b))
            colors.add((r, g, b))
    with open(out, "wb") as f:
        f.write(b"P6\n%d %d\n255\n" % (w, h))
        f.write(rgb)
    print(w, h, len(colors))


def read_ppm(path):
    with open(path, "rb") as f:
        data = f.read()
    parts = data.split(b"\n", 3)
    w, h = (int(v) for v in parts[1].split())
    return w, h, parts[3]


def diff(a, b):
    wa, ha, pa = read_ppm(a)
    wb, hb, pb = read_ppm(b)
    if (wa, ha) != (wb, hb):
        print(max(wa * ha, wb * hb))
        return
    print(sum(1 for i in range(0, len(pa), 3) if pa[i:i + 3] != pb[i:i + 3]))


def click(window, x, y):
    xtst = library("libXtst", "libXtst.so.6")
    xtst.XTestFakeMotionEvent.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_ulong]
    xtst.XTestFakeButtonEvent.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_int, ctypes.c_ulong]
    d = display()
    wx, wy, _, _, _ = geometry(d, int(window))
    xtst.XTestFakeMotionEvent(d, -1, wx + int(float(x)), wy + int(float(y)), 0)
    x11.XSync(d, 0)
    time.sleep(0.15)
    xtst.XTestFakeButtonEvent(d, 1, 1, 0)
    x11.XSync(d, 0)
    time.sleep(0.05)
    xtst.XTestFakeButtonEvent(d, 1, 0, 0)
    x11.XSync(d, 0)


def close(window):
    d = display()
    window = int(window)
    event = XEvent()
    event.xclient.type = 33  # ClientMessage
    event.xclient.window = window
    event.xclient.message_type = x11.XInternAtom(d, b"WM_PROTOCOLS", 0)
    event.xclient.format = 32
    event.xclient.data[0] = x11.XInternAtom(d, b"WM_DELETE_WINDOW", 0)
    event.xclient.data[1] = 0  # CurrentTime
    x11.XSendEvent(d, window, 0, 0, ctypes.byref(event))
    x11.XSync(d, 0)


def main(argv):
    if len(argv) >= 2 and argv[0] == "find":
        find(argv[1], float(argv[2]) if len(argv) > 2 else 20.0)
    elif len(argv) == 3 and argv[0] == "snap":
        snap(argv[1], argv[2])
    elif len(argv) == 3 and argv[0] == "diff":
        diff(argv[1], argv[2])
    elif len(argv) == 4 and argv[0] == "click":
        click(argv[1], argv[2], argv[3])
    elif len(argv) == 2 and argv[0] == "close":
        close(argv[1])
    else:
        sys.stderr.write(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main(sys.argv[1:])
