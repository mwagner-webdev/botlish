"""The generated corpus: bounded combinations of syntax features, run through
the reference targets, every distinct disagreement minimized.

  python3 -I tools/generate.py corpus [--seed 20261114 --files 600]
      writes generated/corpus.jsonl (each fixture keeps its source
      representation: the components every line was built from)
  python3 -I tools/run.py --corpus generated --modes clean
  python3 -I tools/generate.py minimize [--limit 40]
      groups the generated fixtures by the partition of the reference targets
      their outcomes make (which targets agree with which), minimizes one
      representative of each partition between two disagreeing targets, and
      writes the distinct minimal cases to generated/minimized.jsonl (part of
      the permanent corpus: CI runs it)

The generator is deterministic: the same seed and version give the same
bytes. Combinations are targeted (the dimensions below), not random bytes.
"""

import argparse
import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import analyze  # noqa: E402
import common  # noqa: E402
import corpus  # noqa: E402
import minimize  # noqa: E402

VERSION = 1
GEN = common.AUDIT / "generated"

DIMENSIONS = {
    "indent": ["", "", " ", "\t"],
    "export": ["", "", "", "export ", "export\t"],
    "key": ["KEY", "KEY", "key", "K_1", "_K", "my.key", "my-key", "1K", "K\u00c9"],
    "delim": ["=", "=", "=", " = ", " =", "= ", ": "],
    "quote": ["", "'", '"', '"', "`"],
    "atoms": ["v", "a b", " lead", "trail ", "#", " #c", "\\n", "\\\\", '\\"', "\\'", "$X", "${X}",
              "${X:-d}", "\\$X", "\n", "'", '"', "`", "\t", "\u00e9", "=", "  "],
    "trailing": ["", "", "  ", " # comment", "#c", "\t#c"],
    "eol": ["\n", "\n", "\n", "\r\n"],
}


def gen_line(rnd):
    c = {k: rnd.choice(v) for k, v in DIMENSIONS.items() if k != "atoms"}
    c["atoms"] = [rnd.choice(DIMENSIONS["atoms"]) for _ in range(rnd.choice([1, 1, 2, 3]))]
    body = "".join(c["atoms"])
    q = c["quote"]
    text = c["indent"] + c["export"] + c["key"] + c["delim"] + q + body + q + c["trailing"] + c["eol"]
    return c, text


def build(seed, files):
    rnd = random.Random(seed)
    recs = []
    for i in range(files):
        lines, text = [], ""
        if rnd.random() < 0.3:
            lines.append({"preamble": "X=defined"})
            text += "X=defined\n"
        for _ in range(rnd.choice([1, 1, 2, 3])):
            c, t = gen_line(rnd)
            lines.append(c)
            text += t
        recs.append(corpus.record(dict(id="gen-%d-%04d" % (seed, i), category="generated",
                                       description="Generated combination %d (seed %d, generator v%d)" % (i, seed, VERSION),
                                       data=text, modes=["clean"], tags=["generated"],
                                       source={"seed": seed, "version": VERSION, "lines": lines})))
    GEN.mkdir(parents=True, exist_ok=True)
    corpus.write_jsonl(recs, GEN / "corpus.jsonl")
    common.dump_json({"seed": seed, "files": files, "version": VERSION, "dimensions": DIMENSIONS},
                     GEN / "config.json")
    print("generated/corpus.jsonl: %d fixtures (seed %d)" % (len(recs), seed))


def partition(cls):
    return tuple(sorted(tuple(sorted(c["targets"])) for c in cls))


def minimize_all(limit):
    recs = corpus.load("generated")
    results = analyze.load_results(common.RESULTS / "generated")
    targets = [t for t in common.REFERENCE if t in results]
    groups = {}
    for rec in recs:
        cls, un = analyze.classes(results, targets, rec["id"], "clean")
        if len(cls) < 2:
            continue
        groups.setdefault(partition(cls), []).append((rec, cls))
    ranked = sorted(groups.items(), key=lambda kv: (-len(kv[1]), kv[0]))
    print("%d generated fixtures disagree, in %d distinct partitions" % (sum(len(v) for v in groups.values()), len(groups)))
    out, seen = [], set()
    ev = minimize.Evaluator(targets)
    try:
        for part, members in ranked[:limit]:
            rec, cls = sorted(members, key=lambda m: m[0]["size"])[0]
            a, b = cls[0]["targets"][0], cls[1]["targets"][0]
            small = minimize.minimize_disagreement(corpus.data_of(rec), a, b, "clean", ev)
            if small is None or small in seen:
                continue
            seen.add(small)
            o = ev.outcomes([small], [a, b])[small]
            out.append(corpus.record(dict(
                id="min-%03d" % len(out), category="minimized",
                description="Minimal disagreement between %s and %s, from %s (partition of %d generated fixtures)"
                            % (a, b, rec["id"], len(members)),
                data=small, modes=["clean", "conflict"], tags=["minimized"],
                origin="generated", source={"from": rec["id"], "targets": [a, b], "partition": [list(p) for p in part],
                                            "members": len(members),
                                            "witness": list(minimize.witness(o[a], o[b]) or []),
                                            "outcomes": {t: analyze.outcome_key(o[t])[0] for t in (a, b)}})))
            print("  min-%03d  %-12s vs %-12s %r" % (len(out) - 1, a, b, small.decode("utf-8", "replace")[:70]))
    finally:
        print("evaluations:", ev.runs)
        ev.close()
    corpus.write_jsonl(out, GEN / "minimized.jsonl")
    common.dump_json({"generated": len(recs), "disagreeing": sum(len(v) for v in groups.values()),
                      "partitions": len(groups), "minimized": len(out),
                      "partition_sizes": [len(v) for _, v in ranked]}, GEN / "minimize-summary.json")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["corpus", "check", "minimize"])
    ap.add_argument("--seed", type=int, default=20261114)
    ap.add_argument("--files", type=int, default=600)
    ap.add_argument("--limit", type=int, default=40)
    a = ap.parse_args()
    if a.cmd == "corpus":
        build(a.seed, a.files)
    elif a.cmd == "check":
        cfg = common.load_json(GEN / "config.json")
        before = (GEN / "corpus.jsonl").read_bytes()
        build(cfg["seed"], cfg["files"])
        if (GEN / "corpus.jsonl").read_bytes() != before:
            raise SystemExit("generated/corpus.jsonl differs from what generator v%d produces" % VERSION)
        print("generated/corpus.jsonl is current")
    else:
        minimize_all(a.limit)


if __name__ == "__main__":
    main()
