#!/usr/bin/env python3
"""macos-session.py -- plays the macOS Icy Tower executable in real Cocoa
windows (ICY-TOWER-MACOS-MILESTONE-1.md, "Graphical acceptance"): the
counterpart of xvfb-session.py on a Mac's own window system.

    python3 -I macos-session.py run --exe EXE --probe PROBE --worker WORKER
        --helper MACOS_INPUT --reference TRACE_REFERENCE --out DIR [--strict]
    python3 -I macos-session.py selftest [--out DIR]

EXE is the game as build-macos.sh builds it (main-thread startup, static
SDL3); PROBE the same game linked against the traced archive
(traced-archive.sh: every SDL call logged, and SDLTRACE_INFO's account of
the session -- driver, renderer, the thread of every call, frame times);
WORKER the same game built with the default worker startup (the positive
control); MACOS_INPUT the compiled macos-input.m, which does what a person
does: activates the window, presses keys through Quartz's event taps,
closes the window through Accessibility, takes the focus away. Nothing
here enters the game's process: no SDL_PushEvent, no hook, no option the
game does not have.

Every case runs the executable as a fresh process and reads it from
outside: the WindowServer's windows (CGWindowList), captures of its window
(screencapture -l), its exit status and summary line. A capture is checked
against the game's own geometry, which the independent oracle
(audit/icy-tower/oracle.py) predicts: the walls and their mortar lines, the
platforms where the oracle's tower puts them (each in its floor's color,
sky above it), the player, the HUD panel and its text, the banners. Colors
are render.bot's; the window's scale is found from the walls (SDL's
letterbox keeps 480 x 720 logical units' aspect).

The cases:
  env           the session: permissions, the active application, displays
  cocoa         PROBE, seed 7, real time: SDL's video driver cocoa and
                renderer metal (SDLTRACE_INFO, and forced by SDL_VIDEO_DRIVER
                and SDL_RENDER_DRIVER), every SDL call on the process's main
                thread, the window, the start banner and the tower of seed 7
                as the oracle places it, the frame intervals, then Escape
  keyboard      EXE, seed 7: Right, Left, D and A, each a timed tap from
                rest with room to move, move the player their way; Left and
                Right held together do not move it; Escape quits (status 0).
                The tower climbs while the keys move the player, and a game
                a fall ends is restarted with R (the summary's round counts
                them) and the move tried again
  restart       EXE, seed 254: Right held from 3.5 s reaches game over
                (the oracle: within 1.7 s, whatever the frame times), the
                game-over banner, R, a new game -- round 2 on the next tower
                of the same generator, its platforms where the oracle puts
                them, its player where the oracle's run of it with no key
                down draws it between R and the capture, the summary's
                floor the oracle's at its time -- then Escape
  close         EXE, seed 7: the window's close button pressed
                (Accessibility, else a click on it): SDL's quit, status 0
  focus         EXE, seed 7: Right held, the focus taken by another
                application while it is down, the key released there; back
                in the game, Left moves the player left (a stuck Right would
                cancel it, as the keyboard case shows both keys do)
  autopilot     PROBE, seed 3 --autopilot, real time for 20 s: the tower
                climbs (the frames change, the camera rises), every frame
                presented, about 60 a second (vertical sync), the frame
                timing distribution, the event pump's time, then Escape
  trace-dummy   PROBE on SDL's dummy driver, --autopilot --fixed-step
                --frames 600 --seed 7: the SDL call trace equals the Linux
                executable's (TRACE_REFERENCE, sdl-trace.py compare)
  trace-cocoa   the same in a Cocoa window with Metal: the same trace, the
                oracle's summary
  gc-stress     EXE in a Cocoa window under BOTLISH_NATIVE_GC_STRESS=1,
                --autopilot --fixed-step --frames 120 --seed 11: the window,
                the oracle's summary
  worker        WORKER with Cocoa: SDL's video refuses a worker thread
                (status 1, "SDL_Init failed", no window) -- the reason for
                the main-thread policy
  controls      the frame checks reject a capture that is not the game: no
                window, a blank window, the player painted out, a player that
                did not move, a frame that did not change, a dummy-driver run

Each case is EXECUTED (it ran and every check held), FAILED (it ran and a
check did not hold: the category says which kind), or ENVIRONMENT-BLOCKED
(the runner did not let it run: no window server, no permission to post
events, no way to give the window the keyboard focus). A blocked case is
never counted as a passed one: with --strict the exit status is 1 unless
every case is EXECUTED. Writes DIR/results.json, DIR/summary.md, every
capture (PNG) and every run's output.
"""
import argparse
import copy
import json
import os
import re
import shutil
import signal
import struct
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import oracle  # noqa: E402

APPLE = sys.platform == "darwin"

# render.bot's colors.
SKY = (18, 22, 38)
WALL = (54, 64, 96)
MORTAR = (32, 38, 60)
PLAYER = (250, 112, 72)
EYES = (28, 28, 40)
PANEL = (10, 12, 24)
INK = (236, 240, 255)
BANNER_INK = (255, 236, 160)
SHINE = (255, 255, 255)
GOLD = (236, 196, 84)
BANDS = [(128, 206, 236), (120, 220, 170), (186, 160, 240), (240, 150, 140)]
TOLERANCE = 26
VIEW_W, VIEW_H = 480, 720


def platform_color(floor):
    if floor % 25 == 0:
        return GOLD
    return BANDS[min((floor % 40) // 10, 3)]


def near(c, ref, tol=TOLERANCE):
    return abs(c[0] - ref[0]) <= tol and abs(c[1] - ref[1]) <= tol and abs(c[2] - ref[2]) <= tol


# Every color render.bot draws with. The dark ones (the sky, the panels, the
# eyes, the mortar) are a few units apart, so a pixel is read as the
# palette's nearest color (within a distance), not by a tolerance.
PALETTE = [SKY, WALL, MORTAR, PLAYER, EYES, PANEL, INK, BANNER_INK, SHINE, GOLD] + BANDS


def nearest(c, limit=40):
    best, dist = None, None
    for k in PALETTE:
        d = (c[0] - k[0]) ** 2 + (c[1] - k[1]) ** 2 + (c[2] - k[2]) ** 2
        if dist is None or d < dist:
            best, dist = k, d
    return best if dist <= limit * limit else None


def is_(c, *colors):
    return nearest(c) in colors


def blend_of(c, a, b, lo, hi, limit=24):
    """Whether C is a mixture a + t (b - a) of A and B with LO <= t <= HI (within LIMIT): what a renderer's
    filtering makes of an edge between the two."""
    d = [b[i] - a[i] for i in range(3)]
    dd = sum(v * v for v in d)
    t = sum((c[i] - a[i]) * d[i] for i in range(3)) / float(dd)
    if not lo <= t <= hi:
        return False
    return sum((c[i] - a[i] - t * d[i]) ** 2 for i in range(3)) <= limit * limit


# ---------------------------------------------------------------------------
# Images

class Image:
    """WIDTH x HEIGHT RGB pixels, rows top down."""

    def __init__(self, width, height, rows=None, fill=(0, 0, 0)):
        self.width, self.height = width, height
        self.rows = rows if rows is not None else [bytearray(bytes(fill) * width) for _ in range(height)]

    def px(self, x, y):
        if x < 0 or y < 0 or x >= self.width or y >= self.height:
            return (0, 0, 0)
        r = self.rows[y]
        o = 3 * x
        return (r[o], r[o + 1], r[o + 2])

    def fill(self, x0, y0, x1, y1, color):
        x0, y0 = max(0, int(x0)), max(0, int(y0))
        x1, y1 = min(self.width, int(x1)), min(self.height, int(y1))
        for y in range(y0, y1):
            self.rows[y][3 * x0:3 * x1] = bytes(color) * max(0, x1 - x0)

    def copy(self):
        return Image(self.width, self.height, [bytearray(r) for r in self.rows])


def read_bmp(path):
    data = open(path, "rb").read()
    if data[:2] != b"BM":
        raise ValueError("not a BMP: " + path)
    offset, = struct.unpack_from("<I", data, 10)
    width, height = struct.unpack_from("<ii", data, 18)
    bpp, = struct.unpack_from("<H", data, 28)
    step = bpp // 8
    stride = (width * step + 3) & ~3
    flipped = height > 0
    height = abs(height)
    rows = []
    for y in range(height):
        yy = height - 1 - y if flipped else y
        o = offset + yy * stride
        line = data[o:o + width * step]
        row = bytearray(3 * width)
        # BMP stores B, G, R (and A for 32 bits).
        row[0::3] = line[2::step]
        row[1::3] = line[1::step]
        row[2::3] = line[0::step]
        rows.append(row)
    return Image(width, height, rows)


def capture(window_id, png):
    """A capture of window WINDOW_ID (screencapture -l, no shadow) as an Image, or None."""
    if os.path.exists(png):
        os.unlink(png)
    r = subprocess.run(["/usr/sbin/screencapture", "-x", "-o", "-l", str(window_id), png], capture_output=True, text=True, timeout=30)
    if r.returncode != 0 or not os.path.exists(png):
        return None
    bmp = png[:-4] + ".bmp"
    subprocess.run(["sips", "-s", "format", "bmp", png, "--out", bmp], capture_output=True, timeout=30)
    try:
        return read_bmp(bmp)
    finally:
        if os.path.exists(bmp):
            os.unlink(bmp)


# ---------------------------------------------------------------------------
# Frames: a capture read as the game's view

class NotTheGame(Exception):
    pass


class Frame:
    """A capture located: the logical 480 x 720 view inside it, found from
    the walls, which span the view's whole height at both sides."""

    def __init__(self, image):
        self.image = image
        w, h = image.width, image.height
        if w < 100 or h < 100:
            raise NotTheGame("the capture is %dx%d" % (w, h))
        counts = []
        for x in range(w):
            n = 0
            for y in range(0, h, 2):
                c = image.px(x, y)
                if near(c, WALL, 12) or near(c, MORTAR, 12):
                    n += 1
            counts.append(n)
        top = max(counts)
        if top < h // 6:
            raise NotTheGame("no wall columns (the most wall-colored column has %d of %d samples)" % (top, h // 2))
        cols = [x for x in range(w) if counts[x] >= top * 0.6]
        clusters = []
        for x in cols:
            if clusters and x - clusters[-1][1] <= 2:
                clusters[-1][1] = x
            else:
                clusters.append([x, x])
        if len(clusters) < 2:
            raise NotTheGame("one wall, not two (%s)" % clusters)
        left, right = clusters[0], clusters[-1]
        self.x0, x1 = left[0], right[1]
        self.sx = (x1 - self.x0 + 1) / VIEW_W
        cx = (left[0] + left[1]) // 2
        ys = [y for y in range(h) if near(image.px(cx, y), WALL, 12) or near(image.px(cx, y), MORTAR, 12)]
        self.y0, y1 = ys[0], ys[-1]
        self.sy = (y1 - self.y0 + 1) / VIEW_H
        if abs(self.sx - self.sy) > 0.03 * self.sx:
            raise NotTheGame("the walls span %.3f x %.3f of a logical unit: not 480 x 720 letterboxed" % (self.sx, self.sy))
        for name, (a, b) in (("left", left), ("right", right)):
            width = (b - a + 1) / self.sx
            if not 15 <= width <= 25:
                raise NotTheGame("the %s wall is %.1f logical units wide, not 20" % (name, width))

    def lp(self, lx, ly):
        return self.image.px(int(self.x0 + (lx + 0.5) * self.sx), int(self.y0 + (ly + 0.5) * self.sy))

    def fraction(self, region, colors, step=4):
        x0, y0, x1, y1 = region
        n = hit = 0
        for ly in range(y0, y1, step):
            for lx in range(x0, x1, step):
                n += 1
                hit += is_(self.lp(lx, ly), *colors)
        return hit / max(n, 1)

    def facts(self):
        return {"capture": "%dx%d" % (self.image.width, self.image.height), "view_origin": [self.x0, self.y0],
                "scale": round(self.sx, 4)}

    def walls(self):
        return min(self.fraction((2, 60, 18, 700), [WALL, MORTAR]), self.fraction((462, 60, 478, 700), [WALL, MORTAR]))

    def mortar_lines(self):
        runs, inside = 0, False
        for ly in range(0, VIEW_H):
            m = is_(self.lp(10, ly), MORTAR)
            if m and not inside:
                runs += 1
            inside = m
        return runs

    def hud(self):
        """The fraction of the HUD panel's samples that are the panel, the text, or a mixture of the two (a
        glyph's edge where the renderer scales the 8-pixel debug font: a blend well inside the segment
        from PANEL to INK, never the sky's few units from the panel's end), and the fraction of text."""
        x0, y0, x1, y1 = 24, 4, 148, 52
        total = dark = ink = 0
        for ly in range(y0, y1, 2):
            for lx in range(x0, x1, 2):
                c = self.lp(lx, ly)
                total += 1
                n = nearest(c)
                if n == INK:
                    ink += 1
                if n in (PANEL, INK) or blend_of(c, PANEL, INK, 0.15, 0.85):
                    dark += 1
        return dark / float(total), ink / float(total)

    def player(self):
        xs, ys = [], []
        for ly in range(0, VIEW_H, 2):
            for lx in range(20, 460, 2):
                if near(self.lp(lx, ly), PLAYER, 20):
                    xs.append(lx)
                    ys.append(ly)
        if len(xs) < 20:
            return None
        return {"x": min(xs), "right": max(xs), "top": min(ys), "bottom": max(ys), "centre_x": (min(xs) + max(xs)) / 2.0,
                "pixels": len(xs)}

    def banner(self):
        band = self.fraction((30, 288, 450, 352), [PANEL, BANNER_INK], 4)
        if band < 0.85:
            return None
        xs = [lx for ly in range(300, 316) for lx in range(24, 456) if is_(self.lp(lx, ly), BANNER_INK)]
        if not xs:
            return {"kind": "unknown", "width": 0}
        width = max(xs) - min(xs)
        return {"kind": "game-over" if width < 250 else "start", "width": width, "from": min(xs), "to": max(xs)}

    def platform_rows(self):
        """The view rows where a platform's colors are, as intervals: what changes as the tower climbs."""
        rows = []
        for ly in range(60, VIEW_H, 2):
            if any(is_(self.lp(lx, ly), *(BANDS + [GOLD])) for lx in range(24, 456, 12)):
                rows.append(ly)
        intervals = []
        for r in rows:
            if intervals and r - intervals[-1][1] <= 4:
                intervals[-1][1] = r
            else:
                intervals.append([r, r])
        return intervals

    def platforms(self, platforms, camera, avoid):
        """How many of PLATFORMS (the oracle's (x, y, width, floor)) are drawn exactly where they should be:
        their body in their floor's color at both ends (4 units in) and the middle, the sky just above
        them, and not their color 4 units past either end -- away from the regions AVOID (logical
        rectangles the HUD, a banner or the player cover)."""
        checked = matched = 0
        misses = []
        for (x, y, w, floor) in platforms:
            top = VIEW_H - (y - camera)
            if top < 6 or top > VIEW_H - 16:
                continue
            color = platform_color(floor)
            points = [(x + 4, top + 8), (x + w / 2.0, top + 8), (x + w - 4, top + 8)]
            above = [(x + w * k / 4.0, top - 5) for k in (1, 2, 3)]
            outside = [(px, top + 8) for px in (x - 4, x + w + 4) if 23 <= px <= 457]
            if any(ax0 - 2 <= px <= ax1 + 2 and ay0 - 2 <= py <= ay1 + 2 for (px, py) in points + above + outside
                   for (ax0, ay0, ax1, ay1) in avoid):
                continue
            checked += 1
            body = sum(is_(self.lp(px, py), color) for px, py in points)
            sky = sum(is_(self.lp(px, py), SKY) for px, py in above)
            past = sum(is_(self.lp(px, py), color) for px, py in outside)
            if body == 3 and sky >= 2 and past == 0:
                matched += 1
            else:
                misses.append({"floor": floor, "top": round(top, 1), "body": body, "sky": sky, "past_ends": past})
        return checked, matched, misses


def check_static(frame, platforms, camera, banner_expected, player_x=None):
    """The checks of one frame against the oracle: [(ok, text)], facts."""
    checks = []
    facts = frame.facts()
    walls = frame.walls()
    checks.append((walls >= 0.95, "the walls: %.1f%% of their samples wall or mortar" % (100 * walls)))
    lines = frame.mortar_lines()
    checks.append((lines >= 10, "the walls' mortar lines: %d (one every 48 units)" % lines))
    dark, ink = frame.hud()
    checks.append((dark >= 0.9 and ink >= 0.02, "the HUD panel: %.0f%% panel or text, %.1f%% text" % (100 * dark, 100 * ink)))
    p = frame.player()
    facts["player"] = p
    if p is None:
        checks.append((False, "the player: not found"))
    else:
        size_ok = 20 <= p["right"] - p["x"] + 2 <= 32 and 26 <= p["bottom"] - p["top"] + 2 <= 40
        checks.append((size_ok, "the player: %s x %s units at x %s" % (p["right"] - p["x"] + 2, p["bottom"] - p["top"] + 2, p["x"])))
        if player_x is not None:
            checks.append((abs(p["x"] - player_x) <= 4, "the player at x %s, the oracle's %s" % (p["x"], player_x)))
    b = frame.banner()
    facts["banner"] = b
    if banner_expected is None:
        checks.append((b is None, "no banner (found: %s)" % b))
    else:
        checks.append((b is not None and b["kind"] == banner_expected, "the %s banner (found: %s)" % (banner_expected, b)))
    if platforms is not None:
        avoid = [(20, 0, 152, 56)]
        if b is not None or banner_expected is not None:
            avoid.append((20, 280, 460, 360))
        if p is not None:
            avoid.append((p["x"] - 4, p["top"] - 8, p["right"] + 4, p["bottom"] + 4))
        checked, matched, misses = frame.platforms(platforms, camera, avoid)
        facts["platforms"] = {"checked": checked, "matched": matched, "misses": misses[:6]}
        checks.append((checked >= 4 and matched >= checked - max(1, checked // 10),
                       "the oracle's platforms: %d of %d where it puts them" % (matched, checked)))
    return checks, facts


# ---------------------------------------------------------------------------
# A synthetic frame (selftest): render.bot's drawing of a world, rectangles
# only, at a scale and under a title bar, as a capture would show it.

def synthetic(world, scale=0.96, title=28, banner=None, player=True):
    width, height = int(VIEW_W * scale) + 2, int(VIEW_H * scale) + title + 2
    img = Image(width, height, fill=(0, 0, 0))
    img.fill(0, 0, width, title, (230, 230, 230))
    ox, oy = 1, title

    def rect(x, y, w, h, color):
        img.fill(ox + x * scale, oy + y * scale, ox + (x + w) * scale, oy + (y + h) * scale, color)

    cam = world.bottom
    rect(0, 0, VIEW_W, VIEW_H, SKY)
    rect(0, 0, 20, VIEW_H, WALL)
    rect(460, 0, 20, VIEW_H, WALL)
    first = int(cam // 48)
    for k in range(first, first + 17):
        y = VIEW_H - (k * 48 - cam)
        rect(0, y, 20, 1.2, MORTAR)
        rect(460, y, 20, 1.2, MORTAR)
    for (x, y, w, floor) in world.platforms:
        top = VIEW_H - (y - cam)
        rect(x, top, w, 14, platform_color(floor))
        rect(x, top, w, 2, SHINE)
    if player:
        top = VIEW_H - (world.y + 34 - cam)
        rect(world.x, top, 26, 34, PLAYER)
        rect(world.x + 6, top + 8, 4, 7, EYES)
        rect(world.x + 16, top + 8, 4, 7, EYES)
    rect(20, 0, 132, 56, PANEL)
    for i in range(4):
        rect(28, 8 + 12 * i, 60, 7, INK)
    if banner:
        rect(20, 284, 440, 72, PANEL)
        w = 144 if banner == "game-over" else 384
        rect(240 - w / 2, 300, w, 16, BANNER_INK)
        rect(48, 324, 384, 16, BANNER_INK)
    return img


def selftest(out):
    """The frame checks against synthetic frames of the oracle's worlds, and their positive controls."""
    results = []

    def expect(ok, text):
        results.append((ok, text))
        print(("PASS " if ok else "FAIL ") + text, flush=True)

    w = oracle.World(7, 1)
    frame = Frame(synthetic(w, banner="start"))
    checks, facts = check_static(frame, w.platforms, 0.0, "start", player_x=227)
    expect(all(ok for ok, _ in checks), "a synthetic start frame of seed 7 passes every check: %s" % [t for ok, t in checks if not ok])
    for _ in range(240):
        w.step(False, False, False, 1 / 60.0)
    frame = Frame(synthetic(w, scale=1.0, title=0))
    checks, _ = check_static(frame, w.platforms, w.bottom, None, player_x=227)
    expect(all(ok for ok, _ in checks), "a synthetic frame after the banner (scale 1, no title bar) passes")
    # Positive controls: each must be rejected.
    try:
        Frame(Image(480, 748))
        expect(False, "a blank capture is rejected")
    except NotTheGame as e:
        expect(True, "a blank capture is rejected: %s" % e)
    painted = synthetic(w, player=False)
    checks, _ = check_static(Frame(painted), w.platforms, w.bottom, None, player_x=227)
    expect(not all(ok for ok, _ in checks), "a frame without the player is rejected")
    moved = oracle.World(7, 1)
    moved.platforms = [(x + 60, y, wd, f) for (x, y, wd, f) in moved.platforms]
    checks, _ = check_static(Frame(synthetic(moved, banner="start")), oracle.World(7, 1).platforms, 0.0, "start")
    expect(not all(ok for ok, _ in checks), "a frame whose platforms are not where the oracle puts them is rejected")
    checks, _ = check_static(Frame(synthetic(oracle.World(7, 1), banner="game-over")), oracle.World(7, 1).platforms, 0.0, "start")
    expect(not all(ok for ok, _ in checks), "a game-over banner is not taken for the start banner")
    a, b = Frame(synthetic(w)), Frame(synthetic(w))
    expect(a.platform_rows() == b.platform_rows(), "two captures of one world have the same platform rows (a frame that did not change is noticed)")
    later = oracle.World(3, 1)
    for _ in range(900):
        l, r, s = later.autopilot()
        later.step(l, r, s, 1 / 60.0)
    expect(Frame(synthetic(later)).platform_rows() != a.platform_rows(), "a later world of the climbing autopilot has other platform rows")
    expect(moved_check(None, None)[0] is False, "a player not found does not count as moved")
    expect(moved_check({"centre_x": 240}, {"centre_x": 241}, 20)[0] is False, "a player that did not move is rejected")
    failed = sum(not ok for ok, _ in results)
    print("%d selftest checks, %d failed" % (len(results), failed))
    return failed


def moved_check(before, after, by=20, sign=1):
    if before is None or after is None:
        return False, "the player was not found in both captures"
    d = after["centre_x"] - before["centre_x"]
    return (d * sign > by), "the player moved %+.0f units (wanted %s%d)" % (d, "+" if sign > 0 else "-", by)


# ---------------------------------------------------------------------------
# The session on macOS

class Session:
    def __init__(self, args):
        self.args = args
        self.out = os.path.abspath(args.out)
        os.makedirs(self.out, exist_ok=True)
        self.cases = []
        self.helper = os.path.abspath(args.helper)
        self.key_mode = "hid"

    def tool(self, *words, timeout=30):
        r = subprocess.run([self.helper] + [str(w) for w in words], capture_output=True, text=True, timeout=timeout)
        line = (r.stdout.strip().splitlines() or ["{}"])[-1]
        try:
            return r.returncode, json.loads(line)
        except ValueError:
            return r.returncode, {"output": r.stdout + r.stderr}

    def record(self, name, cls, category, checks, facts):
        case = {"name": name, "class": cls, "category": category, "checks": [{"ok": ok, "text": t} for ok, t in checks],
                "facts": facts}
        self.cases.append(case)
        print("RESULT %s: %s%s" % (name, cls, " (%s)" % category if category else ""), flush=True)
        for ok, t in checks:
            print("   %s %s" % ("PASS" if ok else "FAIL", t), flush=True)
        with open(os.path.join(self.out, "results.json"), "w") as f:
            json.dump(self.cases, f, indent=1, default=str)
        return case

    def verdict(self, name, checks, facts, category, blocked=None):
        if blocked:
            return self.record(name, "ENVIRONMENT-BLOCKED", blocked, checks, facts)
        if checks and all(ok for ok, _ in checks):
            return self.record(name, "EXECUTED", "", checks, facts)
        return self.record(name, "FAILED", category, checks, facts)


class Game:
    """One run of an executable, in a Cocoa window unless ENV says otherwise."""

    def __init__(self, session, name, exe, args, env=None):
        self.s, self.name = session, name
        self.log_out = os.path.join(session.out, name + ".stdout")
        self.log_err = os.path.join(session.out, name + ".stderr")
        full = {k: v for k, v in os.environ.items() if not k.startswith(("SDL_", "BOTLISH_NATIVE_GC", "SDLTRACE"))}
        full.update(env or {})
        self.env = env or {}
        self.started = time.time()
        self.p = subprocess.Popen([exe] + args, env=full, stdout=open(self.log_out, "w"), stderr=open(self.log_err, "w"),
                                  stdin=subprocess.DEVNULL)
        self.win = None
        self.shots = 0

    def window(self, timeout=15.0):
        until = time.time() + timeout
        while time.time() < until and self.p.poll() is None:
            _, d = self.s.tool("windows", self.p.pid)
            big = [w for w in d.get("windows", []) if w.get("onscreen") and w.get("w", 0) >= 200 and w.get("h", 0) >= 200]
            if big:
                self.win = big[0]
                self.window_at = time.time()
                return self.win
            time.sleep(0.2)
        return None

    def frontmost(self):
        _, d = self.s.tool("frontmost")
        return d.get("pid") == self.p.pid

    def refresh(self):
        """The window's bounds now (the window manager may have moved or resized it since it opened)."""
        if self.win:
            _, d = self.s.tool("windows", self.p.pid)
            for w in d.get("windows", []):
                if w.get("id") == self.win["id"]:
                    self.win = w
        return self.win

    def focus(self):
        """Gives the game's window the keyboard focus the way a person would; the method that did, or None.
        After a change, a moment for SDL's event pump to take the window becoming key (SDL's Cocoa driver
        gives a key event only to the window with the keyboard focus)."""
        if self.frontmost():
            return "already active"
        self.s.tool("activate", self.p.pid)
        if self.frontmost():
            time.sleep(0.3)
            return "NSRunningApplication activate"
        if self.refresh():
            # A click on the window's content: the WindowServer activates the application and makes the window key.
            self.s.tool("click", self.win["x"] + self.win["w"] / 2, self.win["y"] + self.win["h"] * 0.75)
            time.sleep(0.3)
            if self.frontmost():
                return "a click on the window"
        self.s.tool("ax-raise", self.p.pid)
        if self.frontmost():
            time.sleep(0.3)
            return "Accessibility (frontmost, raise)"
        return None

    def press(self, key, sign, label):
        """KEY down and left down, confirmed by the player's move in direction SIGN: a press the window
        system delivered before SDL gave the window the keyboard focus is not the game's, so an
        unconfirmed one is released, the focus taken again and the key pressed again (three times at
        most). (moved, text, before, after)."""
        last = (False, "no attempt", None, None)
        for attempt in range(3):
            before, _ = self.frame(label + "-before", retries=2)
            self.key(key, "down")
            time.sleep(0.35)
            after, _ = self.frame(label, retries=2)
            pb, pa = (before.player() if before else None), (after.player() if after else None)
            ok, t = moved_check(pb, pa, 20, sign)
            last = (ok, t if attempt == 0 else "%s (press %d)" % (t, attempt + 1), pb, pa)
            if ok:
                return last
            self.key(key, "up")
            self.focus()
            time.sleep(0.5)
        return last

    def key(self, name, action, mode=None):
        mode = mode or self.s.key_mode
        if mode == "pid":
            mode = "pid:%d" % self.p.pid
        self.s.tool("key", name, action, mode)

    def hold(self, names, seconds, mode=None):
        """NAMES (comma-separated) pressed together for SECONDS, timed by the helper (one process: the
        keys' events back to back, the hold not stretched by starting a second process)."""
        mode = mode or self.s.key_mode
        if mode == "pid":
            mode = "pid:%d" % self.p.pid
        return self.s.tool("hold", names, "%.3f" % seconds, mode)

    def ready(self, label, restarts):
        """A frame of a game in play -- the player drawn, no game-over banner -- taking R when the game is
        over (counted in RESTARTS, a one-element list) and waiting for the new game's player."""
        for _ in range(4):
            f, problem = self.frame(label, retries=4)
            if f is not None and f.banner() is None:
                return f
            img, _ = self.shot(label + "-ended")
            try:
                b = Frame(img).banner() if img is not None else None
            except NotTheGame:
                b = None
            if b is not None and b["kind"] == "game-over":
                self.key("r", "tap")
                restarts[0] += 1
                time.sleep(0.8)
        return None

    def shot(self, label):
        self.shots += 1
        png = os.path.join(self.s.out, "%s-%02d-%s.png" % (self.name, self.shots, label))
        if not self.win:
            return None, png
        t0 = time.time()
        img = capture(self.win["id"], png)
        self.taken = (t0, time.time())  # the capture was made between these two moments
        return img, png

    def frame(self, label, retries=8):
        """A located frame of the window (retaken while the player is hidden, as xvfb-session.py does)."""
        last_error = "no capture"
        for _ in range(retries):
            img, png = self.shot(label)
            if img is None:
                last_error = "screencapture failed"
                time.sleep(0.1)
                continue
            try:
                f = Frame(img)
            except NotTheGame as e:
                last_error = str(e)
                time.sleep(0.1)
                continue
            f.png = png
            f.taken = self.taken
            if f.player() is not None:
                return f, None
            last_error = "no player in the capture"
            time.sleep(0.05)
        return None, last_error

    def finish(self, timeout=10.0):
        try:
            code = self.p.wait(timeout=timeout)
            how = "exited"
        except subprocess.TimeoutExpired:
            self.p.send_signal(signal.SIGTERM)
            try:
                code = self.p.wait(timeout=5)
                how = "SIGTERM"
            except subprocess.TimeoutExpired:
                self.p.kill()
                code = self.p.wait()
                how = "killed"
        self.wall = time.time() - self.started
        out = open(self.log_out).read().strip()
        err = open(self.log_err).read().strip()
        return code, how, out, err

    def escape(self):
        self.key("escape", "tap")
        return self.finish(6.0)


def summary_fields(text):
    return dict(f.split("=", 1) for f in text.strip().strip('"').split() if "=" in f)


def info_of(path):
    """SDLTRACE_INFO's lines as {stage: {key: value}}."""
    out = {}
    if not os.path.exists(path):
        return out
    for line in open(path):
        words = line.split()
        if words:
            out[words[0]] = dict(w.split("=", 1) for w in words[1:] if "=" in w)
    return out


def case_env(s):
    code, pre = s.tool("preflight")
    facts = {"preflight": pre, "macos": subprocess.run(["sw_vers", "-productVersion"], capture_output=True, text=True).stdout.strip(),
             "windowserver": subprocess.run(["pgrep", "-x", "WindowServer"], capture_output=True).returncode == 0,
             "console_user": subprocess.run(["stat", "-f", "%Su", "/dev/console"], capture_output=True, text=True).stdout.strip()}
    s.env = facts
    checks = [(facts["windowserver"], "a WindowServer runs"), (pre.get("screens", 0) >= 1, "%s display(s)" % pre.get("screens"))]
    blocked = None if facts["windowserver"] else "cocoa-unavailable"
    return s.verdict("env", checks, facts, "test-harness", blocked)


def case_cocoa(s):
    info = os.path.join(s.out, "cocoa.info")
    trace = os.path.join(s.out, "cocoa.trace")
    g = Game(s, "cocoa", s.args.probe, ["--seed", "7"],
             {"SDL_VIDEO_DRIVER": "cocoa", "SDL_RENDER_DRIVER": "metal", "SDLTRACE": trace, "SDLTRACE_INFO": info})
    win = g.window()
    checks, facts = [], {"window": win}
    if win is None:
        code, how, out, err = g.finish(5)
        facts.update({"status": code, "stderr": err[-400:]})
        # The environment's only where the session has no window server or
        # display (the env case's facts); with both, a Cocoa that SDL calls
        # unavailable is the executable's failure (a worker startup's, as the
        # worker case shows).
        env = getattr(s, "env", {})
        session = env.get("windowserver") and env.get("preflight", {}).get("screens", 0) >= 1
        blocked = "cocoa-unavailable" if not session and ("video device" in err or "not available" in err) else None
        return s.verdict("cocoa", [(False, "a Cocoa window appears (status %s: %s)" % (code, err[-200:]))], facts, "graphical-correctness", blocked)
    time.sleep(0.8)
    start, problem = g.frame("start")
    tower = oracle.World(7, 1)
    if start is None:
        checks.append((False, "a capture of the start: " + problem))
    else:
        c, f = check_static(start, tower.platforms, 0.0, "start", player_x=227)
        checks += [(ok, "start frame: " + t) for ok, t in c]
        facts["start"] = f
    # The banner shows for the first 3 s of the game, whose clock starts as the window opens.
    time.sleep(max(0.0, 3.6 - (time.time() - g.window_at)))
    after, problem = g.frame("after-banner")
    if after is None:
        checks.append((False, "a capture after the banner: " + problem))
    else:
        c, f = check_static(after, tower.platforms, 0.0, None, player_x=227)
        checks += [(ok, "after the banner: " + t) for ok, t in c]
        facts["after_banner"] = f
    time.sleep(1.0)
    focus = g.focus()
    code, how, out, err = g.escape() if focus else g.finish(0.5)
    i = info_of(info)
    facts.update({"focus": focus, "status": code, "ended": how, "summary": out, "info": i})
    checks.append((i.get("init", {}).get("driver") == "cocoa", "SDL's video driver: %s" % i.get("init", {}).get("driver")))
    checks.append((i.get("renderer", {}).get("name") == "metal", "SDL's renderer: %s" % i.get("renderer", {}).get("name")))
    checks.append((i.get("start", {}).get("main") == "1" and i.get("summary", {}).get("off_main") == "0",
                   "every SDL call on the process's main thread (pthread_main_np): %s of %s off it"
                   % (i.get("summary", {}).get("off_main"), i.get("summary", {}).get("calls"))))
    checks.append((int(i.get("summary", {}).get("presents", "0")) > 30, "frames presented: %s" % i.get("summary", {}).get("presents")))
    checks.append(("shutdown" in i, "the renderer, the window and SDL shut down (SDL_Quit reached)"))
    checks.append((code == 0 and "frames=" in out, "status 0 and the summary (%s, %s): %s" % (code, how, out)))
    return s.verdict("cocoa", checks, facts, "graphical-correctness")


def keyboard_blocked(s, g, focus):
    pre = s.env.get("preflight", {}) if hasattr(s, "env") else {}
    if not pre.get("post_event"):
        return "keyboard-injection-unavailable"
    if focus is None:
        return "keyboard-injection-unavailable"
    return None


# A tap's run, from rest, and the room it needs: 0.18 s of RUN_ACCEL reaches
# MAX_RUN, then friction slides the player on (about 90 units in all), and a
# wall within that would turn the move back (REBOUND). The player is first
# moved away from a wall it is too near.
TAP = 0.18
RIGHT_LIMIT, LEFT_LIMIT = 330, 150


def measure_key(g, key, sign, label, restarts):
    """KEY tapped (TAP seconds, from rest) moves the player by more than 20 units in direction SIGN:
    (ok, text, before, after). A game the tower ends during a move (it climbs while the keys
    move the player; a fall below the camera ends it) is restarted with R and the move tried again,
    up to three times: a move is judged only between two captures of one game in play."""
    last = "the player was not found in both captures"
    for attempt in range(3):
        before = g.ready(label + "-before", restarts)
        for _ in range(3):
            if before is None:
                break
            c = before.player()["centre_x"]
            away = "left" if sign > 0 and c > RIGHT_LIMIT else "right" if sign < 0 and c < LEFT_LIMIT else None
            if away is None:
                break
            g.hold(away, 0.22)
            time.sleep(0.35)
            before = g.ready(label + "-before", restarts)
        if before is None:
            last = "no capture of the game in play before the move"
            continue
        g.hold(key, TAP)
        time.sleep(0.3)  # friction stops a full run in 0.23 s
        after, _ = g.frame(label, retries=3)
        if after is None or after.banner() is not None:
            last = "the game ended during the move (attempt %d)" % (attempt + 1)
            continue
        ok, t = moved_check(before.player(), after.player(), 20, sign)
        return ok, t, before.player(), after.player()
    return False, last, None, None


def case_keyboard(s):
    g = Game(s, "keyboard", s.args.exe, ["--seed", "7"])
    checks, facts = [], {}
    if g.window() is None:
        code, how, out, err = g.finish(3)
        return s.verdict("keyboard", [(False, "a window (status %s: %s)" % (code, err[-200:]))], {"stderr": err}, "graphical-correctness")
    time.sleep(max(0.0, 3.5 - (time.time() - g.window_at)))  # the start banner (3 s) is drawn over the player
    focus = g.focus()
    facts["focus"] = focus
    facts["window"] = g.win
    if focus is None:
        code, how, out, err = g.finish(0.5)
        return s.verdict("keyboard", [(False, "the window could take the keyboard focus")], facts, "keyboard-correctness",
                         keyboard_blocked(s, g, focus))
    start, problem = g.frame("start")
    if start is not None:
        c, f = check_static(start, oracle.World(7, 1).platforms, 0.0, None, player_x=227)
        checks += [(ok, "the start: " + t) for ok, t in c]
    restarts = [0]
    # Which of Quartz's paths delivers the keys: the HID event tap (as a
    # keyboard's events enter), else the session's, else posting to the
    # game's process. The first that moves the player is kept for every case.
    tried = []
    for mode in ("hid", "session", "pid"):
        s.key_mode = mode
        ok, t, _, _ = measure_key(g, "right", 1, "calibrate-%s" % mode, restarts)
        tried.append({"mode": mode, "moved": ok, "how": t})
        if ok:
            break
    facts["key_paths"] = tried
    facts["key_mode"] = s.key_mode if any(t["moved"] for t in tried) else None
    if facts["key_mode"] is None:
        s.key_mode = "hid"
    positions = {}
    for key, sign, name in (("right", 1, "Right"), ("left", -1, "Left"), ("d", 1, "D"), ("a", -1, "A")):
        ok, t, before, after = measure_key(g, key, sign, key, restarts)
        positions[key] = [before, after]
        checks.append((ok, "%s: %s" % (name, t)))
    # Both held: run_velocity's neither-or-both rule, friction only (from
    # rest: both keys' events posted together, so neither runs alone).
    both_ok, both_text = False, "Left and Right held together: the player was not found in both captures"
    for attempt in range(3):
        time.sleep(0.4)
        rest = g.ready("rest", restarts)
        if rest is None:
            continue
        g.hold("left,right", 0.5)
        time.sleep(0.1)
        both, _ = g.frame("both", retries=3)
        if both is None or both.banner() is not None:
            continue
        d = both.player()["centre_x"] - rest.player()["centre_x"]
        positions["both"] = [rest.player(), both.player()]
        both_ok = abs(d) <= 12
        both_text = "Left and Right held together: the player moved %+.0f units (friction only)" % d
        break
    checks.append((both_ok, both_text))
    code, how, out, err = g.escape()
    fields = summary_fields(out)
    facts.update({"positions": positions, "restarts": restarts[0], "status": code, "ended": how, "summary": out,
                  "stderr": err[-300:]})
    checks.append((code == 0 and how == "exited", "Escape quits: status %s (%s)" % (code, how)))
    checks.append((fields.get("round") == str(1 + restarts[0]) and "frames=" in out,
                   "the summary, round %d (the games the tower ended were restarted with R %d time(s)): %s"
                   % (1 + restarts[0], restarts[0], out)))
    moved_any = any(ok for ok, t in checks if t.startswith(("Right:", "Left:")))
    blocked = None
    if not moved_any:
        blocked = keyboard_blocked(s, g, focus)
    return s.verdict("keyboard", checks, facts, "keyboard-correctness", blocked)


def round_two(seed, final_rng, final_platforms):
    """The k for which the oracle's game after a restart of SEED's game -- new_world(rng after k platforms, 2) --
    ends with FINAL_RNG and FINAL_PLATFORMS: the next tower of the same generator, or None."""
    state = seed % 4294967296
    # The first game places every platform but the ground (three draws each).
    n0 = len(oracle.World(seed, 1).platforms) - 1
    for _ in range(3 * n0):
        state = oracle.lcg(state)
    for k in range(n0, n0 + 4000):
        w = oracle.World(state, 2)
        if w.rng == final_rng and len(w.platforms) == final_platforms:
            return k, state, w
        for _ in range(3):
            state = oracle.lcg(state)
    return None


def no_input_run(world, seconds):
    """The oracle's run of WORLD with no key down, 60 steps a second, for SECONDS:
    [(time, y, floor, camera)]."""
    w = copy.deepcopy(world)
    out = [(w.time, w.y, w.floor, w.bottom)]
    while w.time < seconds:
        w.step(False, False, False, oracle.FRAME)
        out.append((w.time, w.y, w.floor, w.bottom))
    return out


def case_restart(s):
    g = Game(s, "restart", s.args.exe, ["--seed", "254"])
    checks, facts = [], {}
    if g.window() is None:
        code, how, out, err = g.finish(3)
        return s.verdict("restart", [(False, "a window (status %s)" % code)], {"stderr": err}, "graphical-correctness")
    time.sleep(3.5)
    focus = g.focus()
    facts["focus"] = focus
    if focus is None:
        g.finish(0.5)
        return s.verdict("restart", [(False, "the window could take the keyboard focus")], facts, "keyboard-correctness",
                         keyboard_blocked(s, g, focus))
    held, held_text, _, _ = g.press("right", 1, "press")
    facts["press"] = held_text
    over = None
    until = time.time() + 8.0
    while time.time() < until:
        img, png = g.shot("climb")
        if img is not None:
            try:
                f = Frame(img)
                b = f.banner()
                if b and b["kind"] == "game-over":
                    over = f
                    break
            except NotTheGame:
                pass
        time.sleep(0.15)
    g.key("right", "up")
    checks.append((over is not None, "Right held reaches game over (the oracle: within 1.7 s of the press)"))
    if over is not None:
        facts["game_over"] = {"banner": over.banner(), "png": os.path.basename(png)}
        time.sleep(0.5)
        still, _ = g.frame("over-still", retries=2)
        if still is None:
            img, _ = g.shot("over-still")
            still = Frame(img) if img else None
        b = still.banner() if still else None
        checks.append((b is not None and b["kind"] == "game-over", "a game that is over stays over until R (%s)" % b))
        r_sent = time.time()
        g.key("r", "tap")
        r_done = time.time()
        time.sleep(0.6)
        fresh, problem = g.frame("restarted")
        if fresh is None:
            checks.append((False, "a capture after R: " + problem))
        else:
            checks.append((fresh.banner() is None, "R: the banner is gone (round 2 has no start banner)"))
            facts["restarted"] = fresh.facts()
    code, how, out, err = g.escape()
    fields = summary_fields(out)
    facts.update({"status": code, "ended": how, "summary": out})
    checks.append((code == 0 and how == "exited", "Escape quits: status %s (%s)" % (code, how)))
    checks.append((fields.get("round") == "2" and fields.get("over") == "no", "the summary: round 2, not over: " + out))
    if over is not None and fields.get("rng") and fields.get("platforms"):
        found = round_two(254, int(fields["rng"]), int(fields["platforms"]))
        if found is None:
            checks.append((False, "the new game is new_world(the old game's generator state, 2) for no state the old game reached"))
        else:
            k, state, w = found
            facts["round_two"] = {"platforms_placed_before": k, "seed": state}
            checks.append((True, "the new game is the next tower of the same generator (after %d platforms: seed %d)" % (k, state)))
            # No key is down in round 2: its player stays at the centre and
            # bounces where the oracle's run of that tower with no input does
            # (the ground, then whatever platform it lands on), and the
            # summary's floor is that run's at the summary's time.
            run = no_input_run(w, 4.0)
            p = fresh.player() if fresh is not None else None
            if p is None:
                checks.append((False, "R: the new game's player: not found"))
            else:
                # Round 2's clock started as the game read R (between the
                # helper's start and its exit) and runs in real time; the
                # capture was made between two known moments. Where the
                # oracle's player is drawn in that interval (its feet's view
                # row, the camera's), the capture's must be.
                lo = fresh.taken[0] - r_done - 0.05
                hi = fresh.taken[1] - r_sent + 0.05
                rows = [VIEW_H - (y - camera) for (tt, y, _, camera) in run if lo <= tt <= hi]
                feet = p["bottom"] + 1
                checks.append((bool(rows) and abs(p["x"] - 227) <= 4 and min(rows) - 4 <= feet <= max(rows) + 4,
                               "R: the new game's player centred, its feet at view row %d, where the oracle's run of "
                               "round 2 with no key down draws them %.1f to %.1f s after R (rows %s to %s)"
                               % (feet, lo, hi, rows and round(min(rows)), rows and round(max(rows)))))
            t = float(fields.get("time", "-1"))
            floors = sorted({f for (tt, _, f, _) in run if abs(tt - t) <= 0.2})
            checks.append((fields.get("floor") is not None and int(fields["floor"]) in floors,
                           "the summary's floor %s is the oracle's at %.1f s of round 2 with no key down (%s)"
                           % (fields.get("floor"), t, floors)))
            if fresh is not None:
                checked, matched, misses = fresh.platforms(w.platforms, 0.0, [(20, 0, 152, 56)] + (
                    [(fresh.player()["x"] - 4, fresh.player()["top"] - 8, fresh.player()["right"] + 4, fresh.player()["bottom"] + 4)]
                    if fresh.player() else []))
                checks.append((checked >= 4 and matched >= checked - max(1, checked // 10),
                               "round 2's platforms where the oracle's next tower puts them: %d of %d" % (matched, checked)))
    return s.verdict("restart", checks, facts, "keyboard-correctness")


def case_close(s):
    g = Game(s, "close", s.args.exe, ["--seed", "7"])
    if g.window() is None:
        code, how, out, err = g.finish(3)
        return s.verdict("close", [(False, "a window (status %s)" % code)], {"stderr": err}, "graphical-correctness")
    time.sleep(2.0)
    before, _ = g.frame("before")
    method = None
    rc, d = s.tool("ax-close", g.p.pid)
    facts = {"ax_close": d}
    if rc == 0:
        method = "Accessibility: the close button pressed"
    else:
        # The window menu's Close (Command-W, which SDL's menu binds to performClose:), else a
        # click on the close button: the leftmost of the title bar's three, 14 points in and down.
        method = "Command-W (the window's performClose:)"
        if g.focus():
            g.key("cmd+w", "tap")
        try:
            g.p.wait(timeout=3)
        except subprocess.TimeoutExpired:
            g.refresh()
            s.tool("click", g.win["x"] + 14, g.win["y"] + 14)
            method = "a click on the close button"
    code, how, out, err = g.finish(6.0)
    facts.update({"method": method, "status": code, "ended": how, "summary": out, "stderr": err[-300:]})
    checks = [(before is not None, "the game was drawn before the close"),
              (code == 0 and how == "exited", "closing the window ends the run: status %s (%s, by %s)" % (code, how, method)),
              ("frames=" in out and "over=no" in out, "the summary: " + out)]
    blocked = None
    if how != "exited" and not s.env.get("preflight", {}).get("accessibility") and not s.env.get("preflight", {}).get("post_event"):
        blocked = "window-close-injection-unavailable"
    return s.verdict("close", checks, facts, "graphical-correctness", blocked)


def case_focus(s):
    g = Game(s, "focus", s.args.exe, ["--seed", "7"])
    if g.window() is None:
        code, how, out, err = g.finish(3)
        return s.verdict("focus", [(False, "a window (status %s)" % code)], {"stderr": err}, "graphical-correctness")
    time.sleep(max(0.0, 3.5 - (time.time() - g.window_at)))
    focus = g.focus()
    facts = {"focus": focus}
    if focus is None:
        g.finish(0.5)
        return s.verdict("focus", [(False, "the window could take the keyboard focus")], facts, "keyboard-correctness",
                         keyboard_blocked(s, g, focus))
    checks = []
    restarts = [0]
    before = g.ready("before", restarts)
    if before is not None and before.player()["centre_x"] > RIGHT_LIMIT:
        g.hold("left", 0.22)
        time.sleep(0.35)
        before = g.ready("before", restarts)
    # Right goes down and stays down: the game runs the player right.
    ok_held, t_held, pb, ph = g.press("right", 1, "held")
    # Another application takes the focus while Right is down; the key is released there.
    thief = subprocess.Popen([s.helper, "steal-focus", "3"], stdout=subprocess.PIPE, text=True)
    ready = json.loads(thief.stdout.readline() or "{}")
    time.sleep(0.4)
    if g.frontmost() and ready.get("w"):
        s.tool("click", ready["x"] + ready["w"] / 2, ready["y"] + ready["h"] / 2)
        time.sleep(0.3)
    lost = not g.frontmost()
    _, who = s.tool("frontmost")
    g.key("right", "up")
    time.sleep(0.5)
    thief.wait(timeout=10)
    back = g.focus()
    time.sleep(0.4)
    # Back in the game, no key down. Left alone must move the player left:
    # with Right stuck down, the two would cancel (the keyboard case's
    # both-held check), and the player would not move.
    ok, t, settled, left = measure_key(g, "left", -1, "left", restarts)
    code, how, out, err = g.escape()
    facts.update({"focus_lost_to": who, "refocused": back, "before": pb, "held": ph, "back": settled, "after_left": left,
                  "restarts": restarts[0], "status": code, "ended": how, "summary": out})
    checks.append((ok_held, "Right held runs the player right: " + t_held))
    checks.append((lost, "another application took the keyboard focus (frontmost: %s)" % who.get("name")))
    checks.append((back is not None, "the game's window took the focus back (%s)" % back))
    checks.append((ok, "Left alone moves the player left after the focus came back, so Right is not stuck: " + t))
    checks.append((code == 0 and how == "exited", "Escape quits: status %s (%s)" % (code, how)))
    blocked = None if lost else ("focus-change-unavailable" if not ok else None)
    return s.verdict("focus", checks, facts, "keyboard-correctness", blocked)


def case_autopilot(s):
    info = os.path.join(s.out, "autopilot.info")
    g = Game(s, "autopilot", s.args.probe, ["--seed", "3", "--autopilot"],
             {"SDLTRACE": os.path.join(s.out, "autopilot.trace"), "SDLTRACE_INFO": info})
    if g.window() is None:
        code, how, out, err = g.finish(3)
        return s.verdict("autopilot", [(False, "a window (status %s)" % code)], {"stderr": err}, "graphical-correctness")
    rows, shots = [], []
    for i in range(5):
        time.sleep(4.0)
        f, _ = g.frame("t%02d" % (4 * (i + 1)))
        if f is not None:
            rows.append(f.platform_rows())
            shots.append(f.facts())
    focus = g.focus()
    code, how, out, err = g.escape() if focus else g.finish(0.5)
    fields = summary_fields(out)
    i = info_of(info)
    changes = sum(1 for a, b in zip(rows, rows[1:]) if a != b)
    facts = {"focus": focus, "status": code, "ended": how, "summary": out, "info": i, "captures": shots, "wall_seconds": round(g.wall, 1)}
    frames = i.get("frames", {})
    mean = float(frames.get("mean_ms", "0") or 0)
    # Real time, the renderer's vertical sync: about 60 frames a second, as
    # xvfb-session.py's autopilot (40 to 72). The autopilot is the game's
    # own driver for a fixed step; in real time a frame's dt follows the
    # display, and a game it loses it restarts (the round counts them).
    checks = [(len(rows) >= 4, "%d of 5 captures located" % len(rows)),
              (changes >= len(rows) - 2 >= 1, "the tower moves between captures (%d of %d changes)" % (changes, max(len(rows) - 1, 0))),
              (fields.get("frames") == i.get("summary", {}).get("presents"),
               "every frame the game counted was presented: %s frames, %s presents"
               % (fields.get("frames"), i.get("summary", {}).get("presents"))),
              (12.0 <= mean <= 25.0, "real time with vertical sync: a frame every %.1f ms on average (40 to 83 a second; "
               "median %s ms, 99th percentile %s ms)" % (mean, frames.get("p50_ms"), frames.get("p99_ms"))),
              (i.get("summary", {}).get("off_main") == "0", "every SDL call on the main thread"),
              (code == 0, "status %s (%s): %s" % (code, how, out))]
    return s.verdict("autopilot", checks, facts, "graphical-correctness")


def case_trace(s, name, driver):
    trace = os.path.join(s.out, name + ".trace")
    info = os.path.join(s.out, name + ".info")
    env = {"SDL_VIDEO_DRIVER": driver, "SDLTRACE": trace, "SDLTRACE_INFO": info}
    if driver == "cocoa":
        env["SDL_RENDER_DRIVER"] = "metal"
    g = Game(s, name, s.args.probe, ["--autopilot", "--fixed-step", "--frames", "600", "--seed", "7"], env)
    win = g.window(6.0) if driver == "cocoa" else None
    code, how, out, err = g.finish(60)
    cmp = subprocess.run([sys.executable, "-I", os.path.join(HERE, "sdl-trace.py"), "compare", trace, s.args.reference],
                         capture_output=True, text=True)
    open(os.path.join(s.out, name + ".compare"), "w").write(cmp.stdout + cmp.stderr)
    i = info_of(info)
    want = oracle.summary(7, 600)
    checks = [(code == 0, "status %s (%s)" % (code, how)),
              (out.strip('"') == want, "the summary is the oracle's: %s" % out),
              (cmp.returncode == 0, "the SDL call trace is the Linux executable's: " + (cmp.stdout.strip().splitlines() or ["?"])[-1]),
              (i.get("init", {}).get("driver") == driver, "SDL's video driver: %s" % i.get("init", {}).get("driver")),
              (i.get("summary", {}).get("off_main") == "0", "every SDL call on the main thread: %s of %s off it"
               % (i.get("summary", {}).get("off_main"), i.get("summary", {}).get("calls")))]
    if driver == "cocoa":
        checks.append((win is not None, "a Cocoa window (%s)" % win))
        checks.append((i.get("renderer", {}).get("name") == "metal", "renderer: %s" % i.get("renderer", {}).get("name")))
    facts = {"status": code, "summary": out, "info": i, "compare": cmp.stdout[-1500:], "wall_seconds": round(g.wall, 2)}
    return s.verdict(name, checks, facts, "graphical-correctness" if driver == "cocoa" else "headless-simulation-mismatch")


def case_gc(s):
    g = Game(s, "gc-stress", s.args.exe, ["--autopilot", "--fixed-step", "--frames", "120", "--seed", "11"],
             {"SDL_VIDEO_DRIVER": "cocoa", "BOTLISH_NATIVE_GC_STRESS": "1"})
    win = g.window(20.0)
    mid = None
    if win is not None:
        mid, _ = g.frame("mid", retries=3)
    code, how, out, err = g.finish(600)
    want = oracle.summary(11, 120)
    checks = [(win is not None, "a Cocoa window under GC stress"),
              (code == 0, "status %s (%s)" % (code, how)),
              (out.strip('"') == want, "the summary is the oracle's (a collection at every allocation changes nothing): %s" % out)]
    return s.verdict("gc-stress", checks, {"status": code, "summary": out, "stderr": err[-300:], "wall_seconds": round(g.wall, 1),
                                          "captured": mid.facts() if mid else None}, "runtime-safety")


def case_worker(s):
    g = Game(s, "worker", s.args.worker, ["--seed", "7", "--frames", "60"], {"SDL_VIDEO_DRIVER": "cocoa"})
    win = g.window(4.0)
    code, how, out, err = g.finish(10)
    checks = [(code == 1, "the worker-startup executable fails: status %s" % code),
              ("SDL_Init failed" in err, "SDL's video refuses the worker thread: %s" % err[-200:]),
              (win is None, "no window")]
    return s.verdict("worker", checks, {"status": code, "stderr": err, "window": win}, "runtime-safety")


def case_controls(s):
    checks = []
    failed = selftest(s.out)
    checks.append((failed == 0, "the synthetic positive controls (selftest): %d failed" % failed))
    # A real capture with the player painted out, and a dummy-driver run, which has no window.
    g = Game(s, "controls", s.args.exe, ["--seed", "7"])
    real = None
    if g.window() is not None:
        time.sleep(4.0)
        real, _ = g.frame("real")
    g.finish(0.5)
    if real is not None:
        img = real.image.copy()
        p = real.player()
        x0 = int(real.x0 + (p["x"] - 6) * real.sx)
        x1 = int(real.x0 + (p["right"] + 8) * real.sx)
        y0 = int(real.y0 + (p["top"] - 8) * real.sx)
        y1 = int(real.y0 + (p["bottom"] + 8) * real.sx)
        img.fill(x0, y0, x1, y1, SKY)
        c, _ = check_static(Frame(img), None, 0.0, None)
        checks.append((not all(ok for ok, _ in c), "a real capture with the player painted out is rejected"))
        blank = Image(real.image.width, real.image.height)
        try:
            Frame(blank)
            checks.append((False, "a blank window is rejected"))
        except NotTheGame as e:
            checks.append((True, "a blank window is rejected: %s" % e))
    else:
        checks.append((False, "a real capture for the controls"))
    d = Game(s, "controls-dummy", s.args.exe, ["--seed", "7", "--frames", "120"], {"SDL_VIDEO_DRIVER": "dummy"})
    win = d.window(3.0)
    code, how, out, err = d.finish(20)
    checks.append((win is None and code == 0, "a dummy-driver run has no window to capture: never taken for Cocoa (status %s)" % code))
    return s.verdict("controls", checks, {}, "test-harness")


def run(args):
    s = Session(args)
    cases = [("env", case_env), ("cocoa", case_cocoa), ("keyboard", case_keyboard), ("restart", case_restart),
             ("close", case_close), ("focus", case_focus), ("autopilot", case_autopilot),
             ("trace-dummy", lambda s: case_trace(s, "trace-dummy", "dummy")),
             ("trace-cocoa", lambda s: case_trace(s, "trace-cocoa", "cocoa")),
             ("gc-stress", case_gc), ("worker", case_worker), ("controls", case_controls)]
    only = set(args.only.split(",")) if args.only else None
    for name, case in cases:
        # env always runs: the other cases read its permissions.
        if only and name not in only and name != "env":
            continue
        try:
            case(s)
        except Exception as e:  # a harness failure is a result of its own, never a pass
            s.record(name, "FAILED", "test-harness", [(False, "the harness failed: %r" % e)], {})
    lines = ["| case | class | category | checks |", "|---|---|---|---|"]
    for c in s.cases:
        lines.append("| %s | %s | %s | %d of %d |" % (c["name"], c["class"], c["category"] or "",
                                                    sum(x["ok"] for x in c["checks"]), len(c["checks"])))
    text = "\n".join(lines)
    open(os.path.join(s.out, "summary.md"), "w").write(text + "\n")
    print(text)
    bad = [c["name"] for c in s.cases if c["class"] != "EXECUTED"]
    print("not EXECUTED: %s" % (", ".join(bad) or "none"))
    return 1 if args.strict and bad else 0


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="command", required=True)
    r = sub.add_parser("run")
    for k in ("exe", "probe", "worker", "helper", "reference", "out"):
        r.add_argument("--" + k, required=True)
    r.add_argument("--strict", action="store_true")
    r.add_argument("--only", default="")
    t = sub.add_parser("selftest")
    t.add_argument("--out", default="")
    args = ap.parse_args()
    if args.command == "selftest":
        return 1 if selftest(args.out) else 0
    if not APPLE:
        print("macos-session.py run: macOS only", file=sys.stderr)
        return 2
    return run(args)


if __name__ == "__main__":
    sys.exit(main())
