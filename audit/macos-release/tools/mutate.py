#!/usr/bin/env python3
"""mutate.py -- can the macOS release's tests fail, and for the reason they
state? (ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Credential-validation mutation
testing")

    python3 -I audit/macos-release/tools/mutate.py [--only NAME,...]

Each mutant of audit/macos-release/mutants.txt -- the repository's mutant
format (audit/golden/tools/mutants.txt): `@@ NAME DESCRIPTION`, `!! TEST
...`, then `## FILE` and `<<<< old ==== new >>>>` edits -- is applied to a
private copy of what the release consists of (examples/games/icy-tower/
macos/, package-macos.sh, LICENSE, the workflow, audit/macos-release/), in
a temporary directory, and the tests its `!!` line names run there. A
mutant is killed only when one of those tests fails: a mutant whose text
does not apply exactly once, or that no named test notices, is reported and
makes the exit status 1. Before any mutant, every named test runs on the
unmutated copy and must pass (a test that fails there kills nothing).

TEST is FILE.CLASS.METHOD of audit/macos-release/tests/ (test_credentials,
test_release, test_workflow). The real checkout is never modified.
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
COPIED = ["examples/games/icy-tower/macos", "examples/games/icy-tower/package-macos.sh", "LICENSE",
          ".github/workflows/icy-tower-macos.yml", "audit/macos-release"]


def read_mutants(path):
    mutants, cur, state, old, new, current = [], None, "outside", [], [], None
    with open(path, encoding="utf-8") as f:
        lines = f.read().split("\n")
    for line in lines:
        if state == "outside":
            if line.startswith("@@ "):
                name, _, desc = line[3:].partition(" ")
                cur = {"name": name, "description": desc, "tests": [], "edits": []}
                mutants.append(cur)
            elif line.startswith("!! "):
                cur["tests"] = line[3:].split()
            elif line.startswith("## "):
                current = line[3:].strip()
            elif line == "<<<<":
                state, old = "old", []
        elif state == "old":
            if line == "====":
                state, new = "new", []
            else:
                old.append(line)
        elif state == "new":
            if line == ">>>>":
                cur["edits"].append((current, "\n".join(old), "\n".join(new)))
                state = "outside"
            else:
                new.append(line)
    return mutants


def tree(base):
    for rel in COPIED:
        src, dst = os.path.join(ROOT, rel), os.path.join(base, rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.isdir(src):
            shutil.copytree(src, dst, ignore=shutil.ignore_patterns("__pycache__"))
        else:
            shutil.copy2(src, dst)
    return base


def apply(base, edits):
    for path, old, new in edits:
        full = os.path.join(base, path)
        with open(full, encoding="utf-8") as f:
            text = f.read()
        n = text.count(old)
        if n != 1:
            return "its text occurs %d times in %s" % (n, path)
        with open(full, "w", encoding="utf-8") as f:
            f.write(text.replace(old, new, 1))
    return None


def run_tests(base, tests, timeout=900):
    """{test: passed?} for TESTS (FILE.CLASS.METHOD) in the tree BASE."""
    by_file = {}
    for t in tests:
        f, _, rest = t.partition(".")
        by_file.setdefault(f, []).append(rest)
    results = {}
    for f, names in by_file.items():
        script = os.path.join(base, "audit", "macos-release", "tests", f + ".py")
        env = {k: v for k, v in os.environ.items() if not k.startswith(("MACOS_", "APPLE_"))}
        for name in names:
            try:
                r = subprocess.run([sys.executable, "-I", script, name], capture_output=True, text=True, timeout=timeout, env=env)
                results[f + "." + name] = (r.returncode == 0, (r.stdout + r.stderr)[-800:])
            except subprocess.TimeoutExpired:
                results[f + "." + name] = (False, "timed out")
    return results


def main(argv):
    p = argparse.ArgumentParser()
    p.add_argument("--only", default="")
    p.add_argument("--mutants", default=os.path.join(ROOT, "audit", "macos-release", "mutants.txt"))
    a = p.parse_args(argv)
    mutants = read_mutants(a.mutants)
    if a.only:
        wanted = set(a.only.split(","))
        mutants = [m for m in mutants if m["name"] in wanted]
    work = tempfile.mkdtemp(prefix="macos-release-mutate.")
    failures = 0
    try:
        started = time.time()
        base = tree(os.path.join(work, "baseline"))
        tests = sorted({t for m in mutants for t in m["tests"]})
        baseline = run_tests(base, tests)
        bad = [t for t, (ok, _) in baseline.items() if not ok]
        if bad:
            for t in bad:
                print("BASELINE FAILS %s:\n%s" % (t, baseline[t][1]))
            print("the unmutated tree fails %d of %d named tests: no mutant can be judged" % (len(bad), len(tests)))
            return 1
        print("baseline: %d named tests pass on the unmutated tree (%.0f s)" % (len(tests), time.time() - started))
        killed = 0
        for m in mutants:
            t0 = time.time()
            base = tree(os.path.join(work, m["name"]))
            problem = apply(base, m["edits"])
            if problem:
                print("NOT APPLIED %s: %s" % (m["name"], problem))
                failures += 1
                continue
            res = run_tests(base, m["tests"])
            by = [t for t, (ok, _) in res.items() if not ok]
            if by:
                killed += 1
                print("killed   %-34s by %s (%.0f s)" % (m["name"], ", ".join(by), time.time() - t0))
            else:
                failures += 1
                print("SURVIVED %-34s %s" % (m["name"], m["description"]))
            shutil.rmtree(base, ignore_errors=True)
        print("%d of %d mutants killed by the tests they name (%.0f s)" % (killed, len(mutants), time.time() - started))
    finally:
        shutil.rmtree(work, ignore_errors=True)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
