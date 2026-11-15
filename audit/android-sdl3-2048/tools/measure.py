#!/usr/bin/env python3
"""measure.py -- times the 2048 application under the Linux touch host
(RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Performance and
footprint"), from outside the program:

    python3 -I measure.py HOST [ROUNDS]

HOST is the touch host linked against the application library (the
directory tests/android-sdl3-2048.test's asApp makes: DIR/lib/host). Each
round starts the host with SDL's dummy video driver, a fresh private storage
and --seed 42 --fresh, and reads its merged output line by line with a
monotonic clock: start-up (process start to the "2048: ready ... drawn"
line, which the program prints after its first frame), each swipe (the
host's "swipe pushed" mark, made after the swipe's last event, to the
program's "2048: move" line: the gesture recognized, the game moved, the
snapshot formed and printed; the frame follows), and SDLThread's CPU over
two idle seconds (the host's own measurement). Prints the median and the
range of each over the rounds."""
import os
import statistics
import subprocess
import sys
import tempfile
import time

SWIPES = ["swipe 1 0.8 0.55 0.2 0.55", "swipe 1 0.5 0.35 0.5 0.75", "swipe 1 0.2 0.55 0.8 0.55", "swipe 1 0.5 0.75 0.5 0.35"] * 4


def round_(host):
    with tempfile.TemporaryDirectory() as data:
        script = os.path.join(data, "script.txt")
        with open(script, "w") as f:
            f.write("ready\n")
            for s in SWIPES:
                f.write(s + "\nwait 60\n")
            f.write("wait 200\nmark\nwait 2000\ncpu\nback\n")
        env = dict(os.environ, SDL_VIDEO_DRIVER="dummy", SCRIPT=script, XDG_DATA_HOME=data, HOME=data, HOST_MARKS="1")
        start = time.monotonic()
        p = subprocess.Popen([host, "app", "--seed", "42", "--fresh"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
        ready, pushed, latencies, cpu = None, None, [], None
        for raw in p.stdout:
            now = time.monotonic()
            line = raw.decode("utf-8", "replace").strip()
            if line.startswith("2048: ready") and ready is None:
                ready = now - start
            elif line == "host: swipe pushed":
                pushed = now
            elif line.startswith("2048: move") and pushed is not None:
                latencies.append(now - pushed)
                pushed = None
            elif line.startswith("host: SDLThread cpu"):
                w = line.split()
                cpu = (int(w[3]), int(w[6]))
        p.wait()
        return ready, latencies, cpu


def main():
    host = sys.argv[1]
    rounds = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    readies, lat, cpus = [], [], []
    for _ in range(rounds):
        r, l, c = round_(host)
        readies.append(r * 1000)
        lat.extend(x * 1000 for x in l)
        cpus.append(c)
    def show(name, xs, unit):
        print("%-36s median %7.1f %s  (min %.1f, max %.1f, n %d)" % (name, statistics.median(xs), unit, min(xs), max(xs), len(xs)))
    show("start-up to the first frame", readies, "ms")
    show("swipe to the program's move line", lat, "ms")
    print("%-36s %s" % ("SDLThread CPU in 2 s idle", ", ".join("%d ms in %d ms" % c for c in cpus)))


main()
