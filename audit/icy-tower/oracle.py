#!/usr/bin/env python3
# oracle.py -- an independent implementation of the Icy Tower vertical
# slice's rules (ICY-TOWER-VERTICAL-SLICE-1.md, "Oracle"), written from the
# report's rules, not translated from tower.bot: Python floats are IEEE 754
# binary64 like Botlish's Float64, every operation is written in the order
# the rules state it, and the displayed one-place decimals are computed
# with exact decimal arithmetic (Python's decimal module) rather than by
# DecimalRounded's representation, which is the point of the check.
#
#   python3 audit/icy-tower/oracle.py summary SEED FRAMES   the summary line
#   python3 audit/icy-tower/oracle.py tower SEED TOP         the platforms
#                                                           up to TOP
#   python3 audit/icy-tower/oracle.py compare EXECUTABLE     the executable's
#       --headless summaries against this oracle's, for a grid of seeds and
#       frame counts; exit status 1 on any difference
#
# The executable needs libSDL3.so.0 on its library path even headless (it
# is linked against it).
import math
import subprocess
import sys
from decimal import Decimal, ROUND_HALF_EVEN

VIEW_W, VIEW_H = 480.0, 720.0
WALL = 20.0
INNER = VIEW_W - 2.0 * WALL
PW, PH = 26.0, 34.0
GROUND = 40.0
GRAVITY, RUN_ACCEL, FRICTION, MAX_RUN, REBOUND = 2100.0, 2400.0, 1800.0, 420.0, 0.6
JUMP, BONUS = 860.0, 440.0
MAX_DT = 0.05
FOLLOW = 0.55
LOSE = 60.0
KEEP_BELOW, BUILD_ABOVE = 120.0, 200.0
FRAME = 1.0 / 60.0
TENTH = Decimal("0.1")


def lcg(s):
    return (s * 1664525 + 1013904223) % 4294967296


def frac(s):
    return float(s >> 16) / 65536.0


def place(below, rng):
    # below: (x, y, w, floor)
    floor = below[3] + 1
    level = float(min(floor, 200))
    r1 = lcg(rng)
    r2 = lcg(r1)
    r3 = lcg(r2)
    gap = 72.0 + level * 0.14 + frac(r1) * (44.0 + level * 0.03)
    if floor % 25 == 0:
        return (WALL, below[1] + gap, INNER, floor), r3
    widest = max(200.0 - level * 0.6, 80.0)
    w = widest * (0.6 + 0.4 * frac(r2))
    x = WALL + frac(r3) * (INNER - w)
    return (x, below[1] + gap, w, floor), r3


def grow(platforms, rng, limit):
    platforms = list(platforms)
    while platforms[-1][1] <= limit:
        p, rng = place(platforms[-1], rng)
        platforms.append(p)
    return platforms, rng


def prune(platforms, bottom):
    limit = bottom - KEEP_BELOW
    if platforms[0][1] >= limit:
        return platforms
    return [p for i, p in enumerate(platforms) if p[1] >= limit or i == len(platforms) - 1]


def shown(value):
    # The one-place decimal a player is shown: the exact binary64 value
    # rounded half to even.
    return Decimal(value).quantize(TENTH, rounding=ROUND_HALF_EVEN)


class World:
    def __init__(self, seed, rnd):
        self.platforms, self.rng = grow([(WALL, GROUND, INNER, 0)], seed % 4294967296, VIEW_H + BUILD_ABOVE)
        self.x, self.y, self.vx, self.vy = (VIEW_W - PW) / 2.0, GROUND, 0.0, 0.0
        self.bottom, self.rising = 0.0, False
        self.floor, self.best, self.time, self.over, self.round = 0, Decimal("0.0"), 0.0, False, rnd

    def step(self, left, right, restart, dt):
        if self.over:
            if restart:
                self.__init__(self.rng, self.round + 1)
            return
        h = min(max(dt, 0.0), MAX_DT)
        # horizontal velocity
        if left and not right:
            vx = max(self.vx - RUN_ACCEL * h, -MAX_RUN)
        elif right and not left:
            vx = min(self.vx + RUN_ACCEL * h, MAX_RUN)
        elif self.vx > 0.0:
            vx = max(self.vx - FRICTION * h, 0.0)
        else:
            vx = min(self.vx + FRICTION * h, 0.0)
        vy = self.vy - GRAVITY * h
        x = self.x + vx * h
        y = self.y + vy * h
        if x < WALL:
            x, vx = WALL, -vx * REBOUND
        elif x > VIEW_W - WALL - PW:
            x, vx = VIEW_W - WALL - PW, -vx * REBOUND
        # landing: the highest platform whose top the feet crossed, falling
        landed = None
        for p in reversed(self.platforms):
            if vy < 0.0 and self.y >= p[1] and y <= p[1] and x + PW > p[0] and x < p[0] + p[2]:
                landed = p
                break
        if landed is not None:
            y, vy = landed[1], JUMP + BONUS * abs(vx) / MAX_RUN
            if landed[3] > self.floor:
                self.floor = landed[3]
        self.x, self.y, self.vx, self.vy = x, y, vx, vy
        now = shown((y - GROUND) / 100.0)
        if now > self.best:
            self.best = now
        self.rising = self.rising or self.best >= Decimal("6.0")
        risen = self.bottom + min(30.0 + float(self.floor) * 0.9, 170.0) * h if self.rising else self.bottom
        self.bottom = max(risen, y - VIEW_H * FOLLOW)
        self.platforms, self.rng = grow(prune(self.platforms, self.bottom), self.rng, self.bottom + VIEW_H + BUILD_ABOVE)
        self.time = self.time + h
        self.over = y + PH < self.bottom - LOSE

    def autopilot(self):
        if self.over:
            return False, False, True
        if self.vy < 0.0:
            target = next((p for p in reversed(self.platforms) if p[1] <= self.y), (0.0, -1000000.0, 0.0, -1))
        else:
            target = next((p for p in self.platforms if p[1] > self.y), (0.0, -1000000.0, 0.0, -1))
        centre = self.x + PW / 2.0
        aim = target[0] + target[2] / 2.0
        return centre > aim + 6.0, centre < aim - 6.0, False


def nearest(v):
    return math.trunc(v - 0.5) if v < 0.0 else math.trunc(v + 0.5)


def summary(seed, frames):
    w = World(seed, 1)
    for _ in range(frames):
        left, right, restart = w.autopilot()
        w.step(left, right, restart, FRAME)
    fields = [
        ("frames", frames), ("round", w.round), ("floor", w.floor), ("score", w.floor * 10),
        ("best", w.best), ("time", shown(w.time)), ("over", "yes" if w.over else "no"),
        ("x", nearest(w.x)), ("y", nearest(w.y)), ("camera", nearest(w.bottom)),
        ("platforms", len(w.platforms)), ("rng", w.rng),
    ]
    return " ".join("%s=%s" % f for f in fields)


def main(argv):
    if argv[0] == "summary":
        print(summary(int(argv[1]), int(argv[2])))
    elif argv[0] == "tower":
        platforms, _ = grow([(WALL, GROUND, INNER, 0)], int(argv[1]) % 4294967296, float(argv[2]))
        for p in platforms:
            print("%r %r %r %d" % p)
    elif argv[0] == "compare":
        executable = argv[1]
        failures = 0
        for seed in [0, 1, 2, 3, 7, 42, 4294967295, 123456789]:
            for frames in [1, 60, 600, 3600]:
                expected = summary(seed, frames)
                actual = subprocess.run([executable, "--headless", "--seed", str(seed), "--frames", str(frames)],
                                        capture_output=True, text=True, check=True).stdout.strip().strip('"')
                ok = actual == expected
                failures += not ok
                print("%s seed=%d frames=%d%s" % ("PASS" if ok else "FAIL", seed, frames,
                                                   "" if ok else "\n  oracle:     " + expected + "\n  executable: " + actual))
        print("%d differences" % failures)
        return 1 if failures else 0
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
