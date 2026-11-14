"""Compares a fresh census (a results tree written with DOTENV_CENSUS_RESULTS)
with the committed baseline, and decides what CI fails on.

  python3 -I tools/compare.py --fresh DIR [--policy baseline|portable] [--report FILE]

Policies:

  baseline  (the Linux job, the pinned host) every observation must equal the
            committed one: status, the exact key -> value map, the error's
            class; every target's runtime and library versions too. Any
            difference is behavioral drift and fails, with the fixtures named.
  portable  (macOS, Windows) the host is not the baseline's: differences are
            reported as host observations, never failures -- except that every
            category the baseline classifies as universally portable must stay
            so, and every portable round trip must read back exactly.

Both policies fail when a reference target produced adapter failures or is
missing: a missing oracle is never a passing one.
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import analyze  # noqa: E402
import common  # noqa: E402

BASE = common.AUDIT / "results"


def observation(r):
    if r is None:
        return None
    k = analyze.outcome_key(r)
    cls = (r.get("error") or {}).get("class") if r["status"] == "error" else None
    return (k, cls)


def compare_corpus(name, fresh, lines, strict):
    b = analyze.load_results(BASE / name)
    f = analyze.load_results(Path(fresh) / name)
    bad = 0
    for t in sorted(set(b) | set(f)):
        if t not in f:
            if t in b and (t in common.REFERENCE or strict):
                lines.append("- `%s` %s: missing from the fresh run" % (name, t))
                bad += 1
            continue
        if t not in b:
            lines.append("- `%s` %s: not in the baseline (new target?)" % (name, t))
            continue
        diffs = []
        for fid in sorted(set(b[t]["results"]) | set(f[t]["results"])):
            for mode in sorted(set(b[t]["results"].get(fid, {})) | set(f[t]["results"].get(fid, {}))):
                ob = observation(b[t]["results"].get(fid, {}).get(mode))
                of = observation(f[t]["results"].get(fid, {}).get(mode))
                if ob != of:
                    diffs.append((fid, mode, ob, of))
        failures = [fid for fid, m in f[t]["results"].items() for x in m.values() if x["status"] == "adapter-failure"]
        if failures:
            lines.append("- `%s` %s: adapter failures on %s" % (name, t, ", ".join(sorted(set(failures))[:10])))
            bad += 1
        vb = {m: (x["meta"] or {}).get("library_version") for m, x in b[t]["modes"].items()}
        vf = {m: (x["meta"] or {}).get("library_version") for m, x in f[t]["modes"].items()}
        if vb != vf:
            lines.append("- `%s` %s: library version %s, baseline %s" % (name, t, vf, vb))
            bad += 1 if strict else 0
        if diffs:
            lines.append("- `%s` %s: %d observations differ from the baseline%s" % (
                name, t, len(diffs), "" if strict else " (host observation)"))
            for fid, mode, ob, of in diffs[:12]:
                lines.append("  - `%s` (%s): baseline %s, now %s" % (fid, mode, short(ob), short(of)))
            if len(diffs) > 12:
                lines.append("  - ... %d more" % (len(diffs) - 12))
            bad += len(diffs) if strict else 0
    return bad


def short(o):
    if o is None:
        return "absent"
    (k, cls) = o
    if k[0] == "ok":
        s = k[1]
        return "ok %s" % (s if len(s) < 120 else s[:117] + "...")
    return k[0] + (" (%s)" % cls if cls else "")


def compare_portable(fresh, lines):
    bad = 0
    be = common.load_json(BASE / "portable" / "encodings.json")
    fe = common.load_json(Path(fresh) / "portable" / "encodings.json")
    for cat, row in be["categories"].items():
        was = row["classification"]["class"]
        now = fe["categories"].get(cat, {}).get("classification", {}).get("class")
        if was == "universal" and now != "universal":
            lines.append("- portable category `%s` was universal, is now %s" % (cat, now))
            bad += 1
        elif was != now:
            lines.append("- portable category `%s`: %s, baseline %s" % (cat, now, was))
    for p in sorted((Path(fresh) / "portable").glob("roundtrip-*.json")):
        r = common.load_json(p)
        if r["failures"]:
            lines.append("- round trip seed %d (%s): %d files read back differently: %s" % (
                r["seed"], "multiline" if r.get("multiline") else "single-line", len(r["failures"]),
                json.dumps(dict(list(r["failures"].items())[:3]))))
            bad += 1
    return bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fresh", required=True)
    ap.add_argument("--policy", default="baseline", choices=["baseline", "portable"])
    ap.add_argument("--report", default=None)
    a = ap.parse_args()
    strict = a.policy == "baseline"
    lines = ["# Census comparison (%s policy, host %s)" % (a.policy, common.HOST), ""]
    bad = 0
    for name in ("hand", "generated", "minimized", "portable"):
        if (Path(a.fresh) / name).exists():
            bad += compare_corpus(name, a.fresh, lines, strict)
        else:
            lines.append("- corpus `%s` was not run" % name)
            bad += 1
    bad += compare_portable(a.fresh, lines)
    lines += ["", "**%s**" % ("no difference that fails the policy" if not bad else "%d failing differences" % bad)]
    text = "\n".join(lines) + "\n"
    print(text)
    if a.report:
        Path(a.report).write_text(text, encoding="utf-8")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
