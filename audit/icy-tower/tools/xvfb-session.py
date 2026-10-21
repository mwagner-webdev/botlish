#!/usr/bin/env python3
# xvfb-session.py -- plays the Icy Tower executable in a real X11 window
# under Xvfb (ICY-TOWER-VERTICAL-SLICE-1.md, "Graphical run"): a virtual X
# server, SDL's x11 video driver, key presses injected with the XTest
# extension, screenshots with ImageMagick's `import`, and a window close
# sent as the window manager would (WM_DELETE_WINDOW). No desktop needed.
#
#   python3 audit/icy-tower/tools/xvfb-session.py EXECUTABLE SDL_DIR OUT_DIR
#
# SDL_DIR holds a libSDL3.so built WITH the x11 driver (tests/cffi/sdl3.tcl
# builds a headless one by default; build.sh says how to build another).
# Three sessions, each a separate run of EXECUTABLE:
#
#   keyboard   --seed 7: hold Right, then Left, then Escape; the player's
#              x (found in the screenshots by its color) must move right,
#              then left, and the run must exit 0 with over=no
#   autopilot  --seed 3 --autopilot: real time and vertical sync for 25 s
#              (the frames the clock allows), screenshots on the way, then
#              Escape
#   close      --seed 7: the window is closed from outside (the window
#              manager's WM_DELETE_WINDOW); the run must exit 0
#
# Prints one line per check and exits 1 if any failed. Screenshots and
# each run's output land in OUT_DIR.
import ctypes
import os
import subprocess
import sys
import time

PLAYER = (250, 112, 72)


def screenshot(display, path):
    subprocess.run(["import", "-display", display, "-window", "root", path], check=True)


def player_x(path):
    from PIL import Image
    image = Image.open(path).convert("RGB")
    width, height = image.size
    xs = [x for y in range(0, height, 2) for x in range(width) if image.getpixel((x, y)) == PLAYER]
    return (min(xs) + max(xs)) / 2 if xs else None


class X:
    def __init__(self, display):
        self.lib = ctypes.CDLL("libX11.so.6")
        self.tst = ctypes.CDLL("libXtst.so.6")
        self.lib.XOpenDisplay.restype = ctypes.c_void_p
        self.lib.XDefaultRootWindow.argtypes = [ctypes.c_void_p]
        self.lib.XDefaultRootWindow.restype = ctypes.c_ulong
        self.lib.XStringToKeysym.restype = ctypes.c_ulong
        self.lib.XKeysymToKeycode.argtypes = [ctypes.c_void_p, ctypes.c_ulong]
        self.lib.XKeysymToKeycode.restype = ctypes.c_ubyte
        self.lib.XFlush.argtypes = [ctypes.c_void_p]
        self.lib.XInternAtom.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int]
        self.lib.XInternAtom.restype = ctypes.c_ulong
        self.lib.XQueryTree.argtypes = [ctypes.c_void_p, ctypes.c_ulong, ctypes.POINTER(ctypes.c_ulong),
                                        ctypes.POINTER(ctypes.c_ulong), ctypes.POINTER(ctypes.POINTER(ctypes.c_ulong)),
                                        ctypes.POINTER(ctypes.c_uint)]
        self.lib.XSendEvent.argtypes = [ctypes.c_void_p, ctypes.c_ulong, ctypes.c_int, ctypes.c_long, ctypes.c_void_p]
        self.tst.XTestFakeKeyEvent.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_int, ctypes.c_ulong]
        self.display = self.lib.XOpenDisplay(display.encode())
        if not self.display:
            raise RuntimeError("cannot open display " + display)

    def key(self, name, down):
        code = self.lib.XKeysymToKeycode(self.display, self.lib.XStringToKeysym(name.encode()))
        self.tst.XTestFakeKeyEvent(self.display, code, 1 if down else 0, 0)
        self.lib.XFlush(self.display)

    def hold(self, name, seconds):
        self.key(name, True)
        time.sleep(seconds)
        self.key(name, False)

    def top_windows(self):
        root = self.lib.XDefaultRootWindow(self.display)
        r, p, n = ctypes.c_ulong(), ctypes.c_ulong(), ctypes.c_uint()
        children = ctypes.POINTER(ctypes.c_ulong)()
        self.lib.XQueryTree(self.display, root, ctypes.byref(r), ctypes.byref(p), ctypes.byref(children), ctypes.byref(n))
        return [children[i] for i in range(n.value)]

    def close_windows(self):
        # An XClientMessageEvent: type, serial, send_event, display, window,
        # message_type, format, data (5 longs).
        class ClientMessage(ctypes.Structure):
            _fields_ = [("type", ctypes.c_int), ("serial", ctypes.c_ulong), ("send_event", ctypes.c_int),
                        ("display", ctypes.c_void_p), ("window", ctypes.c_ulong), ("message_type", ctypes.c_ulong),
                        ("format", ctypes.c_int), ("data", ctypes.c_long * 5), ("pad", ctypes.c_long * 24)]
        protocols = self.lib.XInternAtom(self.display, b"WM_PROTOCOLS", 0)
        delete = self.lib.XInternAtom(self.display, b"WM_DELETE_WINDOW", 0)
        windows = self.top_windows()
        for window in windows:
            event = ClientMessage()
            event.type = 33  # ClientMessage
            event.window = window
            event.message_type = protocols
            event.format = 32
            event.data[0] = delete
            event.data[1] = 0  # CurrentTime
            self.lib.XSendEvent(self.display, window, 0, 0, ctypes.byref(event))
        self.lib.XFlush(self.display)
        return len(windows)


def session(name, executable, sdl_dir, out_dir, display, args, script):
    env = dict(os.environ, DISPLAY=display, SDL_VIDEO_DRIVER="x11", LD_LIBRARY_PATH=sdl_dir)
    out = open(os.path.join(out_dir, name + ".out"), "w")
    process = subprocess.Popen([executable] + args, env=env, stdout=out, stderr=subprocess.STDOUT)
    try:
        notes = script(process)
        code = process.wait(timeout=30)
    finally:
        if process.poll() is None:
            process.kill()
        out.close()
    text = open(os.path.join(out_dir, name + ".out")).read().strip()
    return code, text, notes


def main():
    executable, sdl_dir, out_dir = [os.path.abspath(a) for a in sys.argv[1:4]]
    os.makedirs(out_dir, exist_ok=True)
    display = ":97"
    server = subprocess.Popen(["Xvfb", display, "-screen", "0", "640x900x24", "-nolisten", "tcp"],
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(1.5)
    failures = 0

    def check(ok, text):
        nonlocal failures
        print(("PASS " if ok else "FAIL ") + text)
        if not ok:
            failures += 1

    try:
        x = X(display)

        def shot(name):
            path = os.path.join(out_dir, name + ".png")
            screenshot(display, path)
            return path

        # The player's x in a screenshot NAME, retaken (a few times) while
        # the player is hidden -- under the text drawn over it, say.
        def seen(name):
            for _ in range(10):
                found = player_x(shot(name))
                if found is not None:
                    return found
                time.sleep(0.03)
            return None

        def keyboard(process):
            # After the start banner (3 s), which is drawn over the player.
            time.sleep(3.5)
            start = seen("keyboard-start")
            x.hold("Right", 0.45)
            right = seen("keyboard-right")
            x.hold("Left", 0.9)
            left = seen("keyboard-left")
            x.hold("Escape", 0.2)
            return [start, right, left]

        code, text, xs = session("keyboard", executable, sdl_dir, out_dir, display, ["--seed", "7"], keyboard)
        print("keyboard: player x at start, after Right, after Left: %s" % xs)
        check(code == 0, "keyboard: exit status 0 (got %s)" % code)
        check("over=no" in text and "frames=" in text, "keyboard: summary printed: " + text)
        check(None not in xs and xs[1] > xs[0] + 20 and xs[2] < xs[1] - 20,
              "keyboard: Right moved the player right and Left moved it back left")

        def autopilot(process):
            for i in range(5):
                time.sleep(5.0)
                shot("autopilot-%d" % (i + 1))
            x.hold("Escape", 0.2)
            return None

        code, text, _ = session("autopilot", executable, sdl_dir, out_dir, display, ["--seed", "3", "--autopilot"], autopilot)
        check(code == 0, "autopilot: exit status 0 (got %s)" % code)
        fields = dict(f.split("=", 1) for f in text.strip('"').split() if "=" in f)
        frames = int(fields.get("frames", "0"))
        print("autopilot: %s" % text)
        check(1000 <= frames <= 1800, "autopilot: about 60 frames a second for 25 s (%d frames)" % frames)

        def close(process):
            time.sleep(2.0)
            shot("close-before")
            count = x.close_windows()
            return count

        code, text, count = session("close", executable, sdl_dir, out_dir, display, ["--seed", "7"], close)
        check(code == 0 and "frames=" in text, "close: WM_DELETE_WINDOW to %s window(s) ends the run cleanly (exit %s): %s" % (count, code, text))
    finally:
        server.terminate()
        server.wait()
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
