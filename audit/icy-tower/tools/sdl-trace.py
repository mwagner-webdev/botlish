#!/usr/bin/env python3
# sdl-trace.py -- the SDL call trace of the Icy Tower executable across
# platforms (ICY-TOWER-MACOS-MILESTONE-1.md, "SDL call trace"): the lines
# audit/icy-tower/context-refactor/tools/sdltrace.c writes -- every SDL call
# the game makes that draws, polls, times or manages a resource, with its
# arguments (floats in C99 hex, pointers as "ptr" or "null") -- normalized,
# cut into frames, and compared with a reference the Linux executable made.
#
#   python3 -I sdl-trace.py normalize TRACE              the normalized lines
#   python3 -I sdl-trace.py digest TRACE ARGS... > REF   a reference: the
#       command line ARGS it was made with, the per-function counts and a
#       SHA-256 of every frame
#   python3 -I sdl-trace.py compare TRACE REF            exit 0 when TRACE
#       is REF's, else 1 and the first frame that differs, its lines and the
#       per-function counts of both
#
# Normalization removes only what the platform genuinely decides and the
# game does not: how many events the window system queued. The game takes
# every waiting event (sdl.bot's quit_requested?: SDL_PollEvent until it
# returns false), so a run of "poll ptr -> 1" lines -- a window shown, a
# display added, focus gained, keys -- becomes one "poll events" line; the
# final "poll ptr -> 0" of each frame stays. A quit is no difference to
# normalize away: it ends the run, and the frame counts then differ.
# Pointers are already "ptr" or "null" in the trace, and the trace has no
# time stamps ("ticks" is a call, not its value). Nothing else is
# normalized: a missing call, a wrong rectangle or a wrong color differs.
#
# A frame ends with its "present" line; the lines before the first frame
# (SDL_Init, the window, the renderer, the scratch memory) belong to the
# first one, and the lines after the last present (the release, SDL_Quit)
# are the teardown.
import collections
import hashlib
import sys


def normalize(lines):
    out = []
    for line in lines:
        line = line.rstrip("\n")
        if not line:
            continue
        if line == "poll ptr -> 1":
            if not out or out[-1] != "poll events":
                out.append("poll events")
            continue
        out.append(line)
    return out


def frames(lines):
    segments, current = [], []
    for line in lines:
        current.append(line)
        if line.startswith("present "):
            segments.append(current)
            current = []
    return segments, current


def sha(lines):
    return hashlib.sha256("".join(l + "\n" for l in lines).encode()).hexdigest()


def counts(lines):
    return collections.Counter(l.split(" ", 1)[0] for l in lines)


def read(path):
    with open(path, encoding="utf-8", errors="strict") as f:
        return normalize(f.readlines())


def digest(path, args):
    lines = read(path)
    segments, teardown = frames(lines)
    print("# The normalized SDL call trace of the Icy Tower executable (audit/icy-tower/tools/sdl-trace.py),")
    print("# made on Linux x86-64 by the LD_PRELOAD interposer (context-refactor/tools/sdltrace.c) on SDL's")
    print("# dummy video driver: audit/icy-tower/tools/trace-reference.sh EXECUTABLE write regenerates it.")
    print("args " + " ".join(args))
    print("lines %d %s" % (len(lines), sha(lines)))
    for name, n in sorted(counts(lines).items()):
        print("count %s %d" % (name, n))
    for i, seg in enumerate(segments, 1):
        print("frame %d %d %s" % (i, len(seg), sha(seg)))
    print("teardown %d %s" % (len(teardown), sha(teardown)))


def parse_reference(path):
    ref = {"counts": {}, "frames": [], "args": "", "lines": None, "teardown": None}
    with open(path, encoding="utf-8") as f:
        for line in f:
            words = line.split()
            if not words or words[0].startswith("#"):
                continue
            if words[0] == "args":
                ref["args"] = " ".join(words[1:])
            elif words[0] == "lines":
                ref["lines"] = (int(words[1]), words[2])
            elif words[0] == "count":
                ref["counts"][words[1]] = int(words[2])
            elif words[0] == "frame":
                ref["frames"].append((int(words[2]), words[3]))
            elif words[0] == "teardown":
                ref["teardown"] = (int(words[1]), words[2])
    return ref


def compare(path, reference):
    lines = read(path)
    ref = parse_reference(reference)
    segments, teardown = frames(lines)
    got = counts(lines)
    print("trace %s: %d normalized calls, %d frames; reference (%s): %d calls, %d frames"
          % (path, len(lines), len(segments), ref["args"], ref["lines"][0], len(ref["frames"])))
    if (len(lines), sha(lines)) == ref["lines"]:
        print("identical: every call, argument and result of every frame, and the teardown")
        return 0
    for i, seg in enumerate(segments):
        if i >= len(ref["frames"]):
            print("DIFFERENT: frame %d is beyond the reference's %d frames" % (i + 1, len(ref["frames"])))
            break
        if (len(seg), sha(seg)) != ref["frames"][i]:
            print("DIFFERENT: frame %d (%d calls; the reference's has %d); its calls:" % (i + 1, len(seg), ref["frames"][i][0]))
            for line in seg[:120]:
                print("  " + line)
            if len(seg) > 120:
                print("  ... %d more" % (len(seg) - 120))
            break
    else:
        if len(segments) < len(ref["frames"]):
            print("DIFFERENT: %d frames, the reference has %d" % (len(segments), len(ref["frames"])))
        else:
            print("DIFFERENT: the teardown (%d calls; the reference's has %d):" % (len(teardown), ref["teardown"][0]))
            for line in teardown:
                print("  " + line)
    names = sorted(set(got) | set(ref["counts"]))
    print("calls per function (trace / reference):")
    for name in names:
        mark = "" if got.get(name, 0) == ref["counts"].get(name, 0) else "   <- differs"
        print("  %-16s %7d %7d%s" % (name, got.get(name, 0), ref["counts"].get(name, 0), mark))
    return 1


def main(argv):
    if len(argv) >= 2 and argv[0] == "normalize":
        for line in read(argv[1]):
            print(line)
        return 0
    if len(argv) >= 2 and argv[0] == "digest":
        digest(argv[1], argv[2:])
        return 0
    if len(argv) == 3 and argv[0] == "compare":
        return compare(argv[1], argv[2])
    print("usage: sdl-trace.py normalize TRACE | digest TRACE ARGS... | compare TRACE REFERENCE", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
