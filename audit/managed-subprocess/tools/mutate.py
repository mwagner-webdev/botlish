#!/usr/bin/env python3
"""mutate.py -- the managed-subprocess census's mutation tests
(MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md, section 16).

    python3 -I audit/managed-subprocess/tools/mutate.py [NAME...]

For every mutant of tools/mutants.txt: a private copy of the slice (its
sources, the installed driver package, the helper), the mutant applied
(its text must occur exactly once), the adapter and the detector
scenarios' programs rebuilt there, and the detectors run by run.py with
MSP_SLICE pointing at the copy. A mutant is killed when a detector fails
(a timeout counts: run.py's watchdog names it). Every mutant must be killed.
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(ROOT))
sys.path.insert(0, HERE)
import run  # noqa: E402


def mutants():
    """The catalog's mutants: name, the file (relative to the repository
    root), the text replaced and its replacement, the detectors."""
    out, cur, block, mode = [], None, None, None
    for line in open(os.path.join(HERE, "mutants.txt")).read().split("\n"):
        if mode in ("old", "new"):
            if line == "====" and mode == "old":
                mode = "new"
                continue
            if line == ">>>>":
                mode = None
                continue
            cur[mode].append(line)
            continue
        if line.startswith("@@ "):
            cur = {"name": line[3:].split()[0], "file": None, "old": [], "new": [], "detect": []}
            out.append(cur)
        elif line.startswith("!! ") and cur:
            cur["detect"] = line[3:].split()
        elif line.startswith("## ") and cur:
            cur["file"] = line[3:].strip()
        elif line == "<<<<" and cur:
            mode = "old"
    return out


def main():
    only = sys.argv[1:]
    env = dict(os.environ, LANG="C.utf8", LC_ALL="C.utf8")
    results = []
    for m in mutants():
        if only and m["name"] not in only:
            continue
        tmp = tempfile.mkdtemp(prefix="msp-mutant-")
        shutil.copytree(os.path.join(ROOT, "native"), os.path.join(tmp, "native"))
        top = os.path.join(ROOT, "slice")
        skip = {"lab-io", "lab-life", "lab-perf", "slice", "threads", "durable", "native"}
        shutil.copytree(top, os.path.join(tmp, "slice"), symlinks=False,
                        ignore=lambda d, names: [n for n in names if os.path.samefile(d, top) and n in skip])
        target = os.path.join(tmp, os.path.relpath(os.path.join(REPO, m["file"]), ROOT))
        text = open(target).read()
        old, new = "\n".join(m["old"]), "\n".join(m["new"])
        if text.count(old) != 1:
            results.append(f"STALE {m['name']}: its text occurs {text.count(old)} times")
            print(results[-1], flush=True)
            continue
        open(target, "w").write(text.replace(old, new))
        os.makedirs(os.path.join(tmp, "slice", "native"), exist_ok=True)
        subprocess.run(["cc", "-O2", "-Wall", "-fPIC", "-pthread", "-c", os.path.join(tmp, "native", "msp.c"), "-o", os.path.join(tmp, "slice", "native", "msp.o")], check=True)
        subprocess.run(["ar", "rcs", os.path.join(tmp, "slice", "native", "libmsp.a"), os.path.join(tmp, "slice", "native", "msp.o")], check=True)
        progs = sorted({run.SCENARIOS[d][0] for d in m["detect"]})
        t = time.monotonic()
        for prog in progs:
            r = subprocess.run(["tclsh9.0", os.path.join(REPO, "main.tcl"), "-warnings", "off", "-emit-native-executable", prog + ".bot"],
                               cwd=os.path.join(tmp, "slice"), env=env, capture_output=True, text=True, timeout=1800)
            if r.returncode != 0:
                results.append(f"KILLED {m['name']} (does not compile)")
                break
        else:
            r = subprocess.run([sys.executable, "-I", os.path.join(HERE, "run.py"), "--out", os.path.join(tmp, "runs"), "--only"] + m["detect"],
                               env=dict(env, MSP_SLICE=os.path.join(tmp, "slice")), capture_output=True, text=True, timeout=1800)
            failed = [l for l in r.stdout.splitlines() if l.startswith("FAIL")]
            results.append((f"KILLED {m['name']} by " + failed[0]) if failed else f"SURVIVED {m['name']}")
        print(f"{results[-1]}  ({time.monotonic() - t:.0f} s)", flush=True)
        shutil.rmtree(tmp, ignore_errors=True)
    killed = sum(r.startswith("KILLED") for r in results)
    print(f"{killed} of {len(results)} mutants killed")
    sys.exit(0 if killed == len(results) else 1)


if __name__ == "__main__":
    main()
