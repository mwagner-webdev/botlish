"""Analysis of a run: agreement classes, the disagreement taxonomy, the
configuration and cross-version differences, and the human-readable reports.

  python3 -I tools/analyze.py [--corpus hand] [--results DIR] [--write]

Reads DIR/*.json (default results/<corpus>/) and the corpus; writes
results/<corpus>-summary.json (machine-readable: per fixture and mode, the
classes of identical outcomes among the reference targets and the
disagreement's kind) and results/<corpus>-differential.md (per category, per
fixture, the classes with their values), plus, for the hand corpus,
results/configurations.md and results/cross-version.md.

Two outcomes are identical when their status is the same and, for "ok", the
effective key -> value maps are equal byte for byte (no normalization:
"compatibility is equality of meaning"). "error" outcomes are identical
whatever the exception's class. not-run and adapter-failure outcomes are
observations that did not happen; they are listed, never counted as
agreement.
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common  # noqa: E402
import corpus  # noqa: E402

KIND_BY_CATEGORY = {
    "quotes": "quote handling", "escapes": "escape handling", "interpolation": "interpolation",
    "environment": "existing-environment precedence", "duplicates": "duplicate precedence",
    "encoding": "encoding", "multiline": "multiline handling", "whitespace": "value decoding",
    "comments": "value decoding", "names": "key recognition", "assignment": "syntax acceptance",
    "malformed": "error behavior", "commands": "interpolation",
}
KINDS = ["syntax acceptance", "key recognition", "value decoding", "quote handling", "escape handling",
         "interpolation", "existing-environment precedence", "duplicate precedence", "encoding",
         "multiline handling", "error behavior", "unavailable or unsupported observation"]


def load_results(d):
    out = {}
    for p in sorted(Path(d).glob("*.json")):
        r = common.load_json(p)
        if isinstance(r, dict) and "target" in r and "results" in r:
            out[r["target"]] = r
    return out


def outcome_key(r):
    if r is None:
        return ("absent",)
    s = r["status"]
    if s == "ok" and r.get("map_elided"):
        e = r["map_elided"]
        return ("ok", json.dumps({"<elided>": "%d keys, sha256 %s" % (e["keys"], e["sha256"])}))
    if s == "ok":
        return ("ok", json.dumps(r["map"], sort_keys=True, ensure_ascii=True))
    return (s,)


def classes(results, targets, fid, mode):
    groups = {}
    unobserved = {}
    for t in targets:
        r = results[t]["results"].get(fid, {}).get(mode) if t in results else None
        if r is None:
            continue
        if r["status"] in ("not-run", "adapter-failure"):
            unobserved[t] = r["status"]
            continue
        groups.setdefault(outcome_key(r), []).append(t)
    cls = [{"targets": ts, "status": k[0], "map": json.loads(k[1]) if k[0] == "ok" else None}
           for k, ts in groups.items()]
    cls.sort(key=lambda c: (-len(c["targets"]), c["targets"]))
    return cls, unobserved


def kind(rec, cls, unobserved):
    """The disagreement's kinds (a list; empty when the observed targets
    agree): "error behavior" when some reject the file and others do not,
    and, among the targets that accepted it, the kind the fixture's category
    names when their maps differ (or "syntax acceptance" / "key recognition"
    when even their key sets differ)."""
    kinds = []
    if not cls:
        return ["unavailable or unsupported observation"] if unobserved else []
    if len({c["status"] for c in cls}) > 1:
        kinds.append("error behavior")
    oks = [c for c in cls if c["status"] == "ok"]
    if len(oks) > 1:
        cat = rec["category"]
        if len({json.dumps(sorted(c["map"])) for c in oks}) > 1 and cat not in (
                "duplicates", "environment", "interpolation", "multiline", "encoding", "commands"):
            kinds.append("key recognition" if cat == "names" else "syntax acceptance")
        else:
            kinds.append(KIND_BY_CATEGORY.get(cat, "value decoding"))
    return kinds


def short(v, n=70):
    s = json.dumps(v, ensure_ascii=False)
    s = s.replace("|", "\\|")
    return s if len(s) <= n else s[:n - 1] + "\u2026"


def render_map(m):
    if not m:
        return "{}"
    return ", ".join("%s=%s" % (short(k, 40), short(v, 60)) for k, v in sorted(m.items()))


def summarize(results, recs, targets):
    summary = {}
    for rec in recs:
        fid = rec["id"]
        per = {}
        for mode in rec["modes"]:
            cls, un = classes(results, targets, fid, mode)
            per[mode] = {"classes": cls, "unobserved": un, "kinds": kind(rec, cls, un),
                         "agree": len(cls) == 1 and not un}
        summary[fid] = per
    return summary


def differential_md(results, recs, summary, targets, title):
    lines = ["# %s" % title, "",
             "Generated by `tools/analyze.py` from `results/`; do not edit. Each fixture's outcomes",
             "among the reference targets (%s), grouped into classes of identical results" % ", ".join(targets),
             "(status and exact key/value map). `error` is a rejected file; `not-run` means the safety",
             "classification forbids running the fixture on that target (Bash: not a plain-assignment",
             "file); conflict-mode rows are shown only where they differ from the clean mode.", ""]
    bycat = {}
    for rec in recs:
        bycat.setdefault(rec["category"], []).append(rec)
    for cat in sorted(bycat):
        rs = bycat[cat]
        agree = sum(1 for r in rs if summary[r["id"]]["clean"]["agree"]) if all("clean" in summary[r["id"]] for r in rs) else 0
        lines += ["## %s (%d fixtures, %d with one class)" % (cat, len(rs), agree), ""]
        lines += ["| fixture | mode | classes |", "|---|---|---|"]
        for rec in rs:
            fid = rec["id"]
            prev = None
            for mode in rec["modes"]:
                s = summary[fid][mode]
                sig = json.dumps([s["classes"], s["unobserved"]], sort_keys=True)
                if mode != "clean" and sig == prev:
                    continue
                prev = sig
                parts = []
                for i, c in enumerate(s["classes"]):
                    label = chr(ord("A") + i)
                    body = render_map(c["map"]) if c["status"] == "ok" else c["status"]
                    parts.append("**%s** %s: %s" % (label, ", ".join(c["targets"]), body))
                if s["unobserved"]:
                    parts.append("_unobserved_: " + ", ".join("%s (%s)" % kv for kv in sorted(s["unobserved"].items())))
                lines.append("| `%s` | %s | %s |" % (fid, mode, "<br>".join(parts) or "-"))
        lines.append("")
    return "\n".join(lines) + "\n"


def pairwise_md(results, recs, pairs, title, intro):
    lines = ["# %s" % title, "", intro, ""]
    for base, other in pairs:
        if base not in results or other not in results:
            lines += ["## %s vs %s" % (other, base), "", "_not run_", ""]
            continue
        diffs = []
        for rec in recs:
            fid = rec["id"]
            for mode in rec["modes"]:
                a = results[base]["results"].get(fid, {}).get(mode)
                b = results[other]["results"].get(fid, {}).get(mode)
                if a is None or b is None or "not-run" in (a["status"], b["status"]):
                    continue
                if outcome_key(a) != outcome_key(b):
                    diffs.append((fid, mode, a, b))
        lines += ["## %s vs %s: %d differing observations" % (other, base, len(diffs)), ""]
        if diffs:
            lines += ["| fixture | mode | %s | %s |" % (base, other), "|---|---|---|---|"]
            for fid, mode, a, b in diffs:
                fa = render_map(a["map"]) if a["status"] == "ok" else a["status"]
                fb = render_map(b["map"]) if b["status"] == "ok" else b["status"]
                lines.append("| `%s` | %s | %s | %s |" % (fid, mode, fa, fb))
        lines.append("")
    return "\n".join(lines) + "\n"


CONFIG_PAIRS = [("node-dotenv", "node-dotenv-fast"), ("python", "python-nointerp"),
                ("dotenvnet", "dotenvnet-strict"), ("dotenvnet", "dotenvnet-extended"),
                ("java", "java-lenient"), ("ruby", "ruby-trusted"), ("node-builtin", "node-envfile")]
VERSION_PAIRS = [("node-builtin", "node-builtin@24"), ("node-builtin", "node-builtin@22"),
                 ("node-envfile", "node-envfile@24"), ("node-envfile", "node-envfile@22"),
                 ("node-dotenv", "node-dotenv@17"), ("node-dotenv", "node-dotenv@16"),
                 ("bun", "bun@1.3"), ("python", "python@1.0"), ("ruby", "ruby@2"),
                 ("dotenvnet", "dotenvnet@3"), ("java", "java@2")]


def stats(summary, recs):
    out = {"fixtures": len(recs), "by_kind": {}, "by_category": {}}
    for rec in recs:
        s = summary[rec["id"]].get("clean") or next(iter(summary[rec["id"]].values()))
        c = out["by_category"].setdefault(rec["category"], {"fixtures": 0, "agree": 0, "classes": 0})
        c["fixtures"] += 1
        c["agree"] += 1 if s["agree"] else 0
        c["classes"] += len(s["classes"])
        for k in s["kinds"]:
            out["by_kind"][k] = out["by_kind"].get(k, 0) + 1
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--corpus", default="hand")
    ap.add_argument("--results", default=None)
    ap.add_argument("--targets", default=",".join(common.REFERENCE))
    a = ap.parse_args()
    d = Path(a.results) if a.results else common.RESULTS / a.corpus
    results = load_results(d)
    recs = corpus.load(a.corpus)
    targets = [t for t in a.targets.split(",") if t in results]
    summary = summarize(results, recs, targets)
    st = stats(summary, recs)
    common.dump_json({"targets": targets, "stats": st, "fixtures": summary}, common.RESULTS / ("%s-summary.json" % a.corpus))
    (common.RESULTS / ("%s-differential.md" % a.corpus)).write_text(
        differential_md(results, recs, summary, targets, "Differential results: %s corpus" % a.corpus),
        encoding="utf-8", newline="\n")
    if a.corpus == "hand":
        (common.RESULTS / "configurations.md").write_text(pairwise_md(
            results, recs, CONFIG_PAIRS, "Configuration-dependent behavior",
            "Generated by `tools/analyze.py`: every hand-corpus observation where a non-default configuration "
            "(or, last, Node's --env-file loader against its own util.parseEnv) differs from the reference "
            "configuration."), encoding="utf-8", newline="\n")
        (common.RESULTS / "cross-version.md").write_text(pairwise_md(
            results, recs, VERSION_PAIRS, "Cross-version behavior",
            "Generated by `tools/analyze.py`: every hand-corpus observation where an older, widely deployed "
            "release (or runtime) differs from the pinned baseline. Versions: versions.json and each "
            "results file's meta."), encoding="utf-8", newline="\n")
    print(json.dumps(st, indent=1))


if __name__ == "__main__":
    main()
