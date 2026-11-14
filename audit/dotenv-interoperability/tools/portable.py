"""The portable emission profile: which values can be written so that every
reference target reads back exactly the intended assignments.

  python3 -I tools/portable.py corpus      write results/portable/corpus.jsonl
  (python3 -I tools/run.py --corpus portable --modes clean)
  python3 -I tools/portable.py analyze     write results/portable/encodings.json and the report part
  python3 -I tools/portable.py roundtrip [--seed N --files M]
                                           generate files with the chosen rule into
                                           results/portable/roundtrip.jsonl, run them, check them
  python3 -I tools/portable.py report      write results/portable.md

The search is exhaustive over a fixed set of value categories (each with
sample values) and candidate encodings. A candidate passes for a sample only
if every reference target returns status ok and exactly {KEY: value} -- the
same key, the same value byte for byte, no extra or missing assignment.
Bash counts like every other target: a candidate whose text the static
classifier will not let Bash run is not portable (its meaning in Bash is
unverified, which is never success).
"""

import argparse
import json
import random
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import analyze  # noqa: E402
import common  # noqa: E402
import corpus  # noqa: E402

OUT = common.RESULTS / "portable"
KEY = "PORTABLE_KEY"

CATEGORIES = [
    ("alnum", "simple alphanumeric", ["value", "Value123", "ABC"]),
    ("punct-safe", "punctuation without quoting meaning", ["a-b_c.d", "a/b", "a:b", "a,b", "a+b", "a@b", "a%b", "a^b"]),
    ("url", "URLs and connection strings", ["https://example.com/path?x=1&y=2", "postgres://u:p@h:5432/db"]),
    ("shell-meta", "shell metacharacters", ["a;b", "a&b", "a|b", "a<b>c", "a(b)c", "a{b}c", "a[b]c", "a*b", "a?b", "a!b", "a~b"]),
    ("spaces", "inner spaces", ["a b", "a  b", "hello world foo"]),
    ("empty", "the empty string", [""]),
    ("edge-space", "leading and trailing whitespace", [" a", "a ", "  a  ", " ", "\ta", "a\t"]),
    ("tab", "inner tab", ["a\tb"]),
    ("hash", "#", ["a#b", "a #b", "#a", "a#"]),
    ("equals", "=", ["a=b", "=a", "a=", "=="]),
    ("squote", "single quote", ["a'b", "'", "'a'"]),
    ("dquote", "double quote", ['a"b', '"', '"a"']),
    ("backtick", "backtick", ["a`b", "`a`"]),
    ("backslash", "backslash", ["a\\b", "a\\\\b", "a\\nb", "a\\", "\\"]),
    ("dollar", "dollar sign", ["a$b", "$a", "a$", "$$", "$1"]),
    ("template", "literal ${NAME} and $NAME", ["${NAME}", "$NAME", "${NAME:-x}", "pre${NAME}post"]),
    ("command-text", "literal command-substitution text", ["$(id)", "`id`"]),
    ("newline", "newline", ["a\nb", "a\n", "\na", "a\n\nb"]),
    ("cr", "carriage return", ["a\rb", "a\r\nb"]),
    ("unicode", "non-ASCII Unicode", ["caf\u00e9", "\u65e5\u672c\u8a9e", "\U0001f600", "cafe\u0301", "\u05e9\u05dc\u05d5\u05dd"]),
    ("unicode-space", "Unicode spaces and separators", ["a\u00a0b", "\u00a0a\u00a0", "a\u2003b", "a\u2028b", "a\u2029b", "a\u0085b"]),
    ("bom-char", "U+FEFF inside a value", ["a\ufeffb"]),
    ("controls", "C0 controls and DEL", ["a\x01b", "a\x1bb", "a\x7fb"]),
    ("json", "JSON text", ['{"a":1}', "[1,2]"]),
    ("long", "a long value", ["x" * 4096]),
    ("nul", "NUL", ["a\x00b"]),
]


def esc_double(v, chars='\\"$`'):
    return "".join("\\" + c if c in chars else c for c in v)


ENCODINGS = [
    ("unquoted", "KEY=VALUE as is", lambda v: v),
    ("single", "KEY='VALUE' (no escaping; impossible with a ')", lambda v: None if "'" in v else "'" + v + "'"),
    ("double", 'KEY="VALUE" (no escaping)', lambda v: '"' + v + '"'),
    ("double-esc", 'KEY="VALUE" with \\ " $ ` backslash-escaped (POSIX shell rules)', lambda v: '"' + esc_double(v) + '"'),
    ("double-esc-quote", 'KEY="VALUE" with only " backslash-escaped', lambda v: '"' + esc_double(v, '"') + '"'),
    ("double-esc-nl", 'KEY="VALUE" with \\ " $ ` escaped and newline, CR, tab as \\n \\r \\t',
     lambda v: '"' + esc_double(v).replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") + '"'),
    ("single-concat", "KEY='VALUE' with each ' written as '\\'' (POSIX shell concatenation)",
     lambda v: "'" + v.replace("'", "'\\''") + "'"),
    ("ansi-c", "KEY=$'VALUE' (Bash ANSI-C quoting)",
     lambda v: "$'" + v.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") + "'"),
    ("backtick", "KEY=`VALUE` (impossible with a `)", lambda v: None if "`" in v else "`" + v + "`"),
    ("unquoted-esc", "KEY=VALUE with every non-alphanumeric character backslash-escaped",
     lambda v: "".join(c if c.isalnum() and c.isascii() else "\\" + c for c in v)),
]

# Whole-file conventions, each tried with the "double-esc" encoding of plain values.
LAYOUTS = [
    ("lf", "LF line ends, final newline", lambda lines: "".join(l + "\n" for l in lines)),
    ("no-final-newline", "LF, no final newline", lambda lines: "\n".join(lines)),
    ("crlf", "CRLF line ends", lambda lines: "".join(l + "\r\n" for l in lines)),
    ("comment-header", "a # comment line first", lambda lines: "# generated\n" + "".join(l + "\n" for l in lines)),
    ("blank-separated", "blank lines between assignments", lambda lines: "\n\n".join(lines) + "\n"),
    ("export-prefix", "every assignment prefixed with export", lambda lines: "".join("export " + l + "\n" for l in lines)),
]


def build():
    recs = []
    for cat, what, samples in CATEGORIES:
        for i, v in enumerate(samples):
            for enc, _, f in ENCODINGS:
                text = f(v)
                if text is None:
                    continue
                recs.append(corpus.record(dict(
                    id="pe-%s-%s-%d" % (enc, cat, i), category="portable-" + cat,
                    description="%s sample %d (%s) written %s" % (what, i, json.dumps(v)[:40], enc),
                    data="%s=%s\n" % (KEY, text), intended={KEY: v}, modes=["clean"],
                    tags=["encoding:" + enc, "category:" + cat, "sample:%d" % i])))
    lines = ['A="one"', 'B="two words"', 'C=""']
    for lay, what, f in LAYOUTS:
        recs.append(corpus.record(dict(
            id="pl-%s" % lay, category="portable-layout", description="Three assignments, %s" % what,
            data=f(lines), intended={"A": "one", "B": "two words", "C": ""}, modes=["clean"],
            tags=["layout:" + lay])))
    for i, k in enumerate(KEYS):
        recs.append(corpus.record(dict(
            id="pk-%02d" % i, category="portable-key", description="Key %r with a plain double-quoted value" % k,
            data='%s="v"\n' % k, intended={k: "v"}, modes=["clean"], tags=["key"])))
    OUT.mkdir(parents=True, exist_ok=True)
    corpus.write_jsonl(recs, OUT / "corpus.jsonl")
    print("results/portable/corpus.jsonl: %d fixtures" % len(recs))


KEYS = ["KEY", "key", "Key", "_KEY", "K1", "MY_LONG_KEY_NAME_42", "k_e_y", "A", "_K", "KEY_",
        "CL\u00c9", "my.key", "my-key", "1KEY", "K\u0663"]


def exact(r, intended):
    return r is not None and r["status"] == "ok" and r["map"] == intended


def load_run(name):
    return analyze.load_results(common.RESULTS / name)


def verdicts(results, recs, targets):
    """Per fixture: the targets that read back exactly the intended map."""
    out = {}
    for rec in recs:
        per = {}
        for t in targets:
            r = results.get(t, {}).get("results", {}).get(rec["id"], {}).get("clean")
            if r is None:
                per[t] = "absent"
            elif r["status"] in ("not-run", "adapter-failure"):
                per[t] = r["status"]
            else:
                per[t] = "exact" if exact(r, rec["intended"]) else "differs"
        out[rec["id"]] = per
    return out


def analyze_cmd():
    recs = corpus.load("portable")
    results = load_run("portable")
    targets = [t for t in common.REFERENCE if t in results]
    v = verdicts(results, recs, targets)
    byid = {r["id"]: r for r in recs}
    table = {}
    for cat, what, samples in CATEGORIES:
        row = {"what": what, "samples": samples, "encodings": {}}
        for enc, _, f in ENCODINGS:
            per_sample = []
            for i, s in enumerate(samples):
                fid = "pe-%s-%s-%d" % (enc, cat, i)
                if fid not in byid:
                    per_sample.append(None)
                    continue
                per_sample.append({t: v[fid][t] for t in targets})
            row["encodings"][enc] = per_sample
        row["classification"] = classify(row, targets)
        table[cat] = row
    layouts = {r["id"]: v[r["id"]] for r in recs if r["category"] == "portable-layout"}
    keys = {byid[fid]["description"]: v[fid] for fid in v if fid.startswith("pk-")}
    common.dump_json({"targets": targets, "categories": table, "layouts": layouts, "keys": keys},
                     OUT / "encodings.json")
    for cat, row in table.items():
        print("%-14s %s" % (cat, row["classification"]["class"]), row["classification"].get("encoding", ""),
              row["classification"].get("note", ""))


def classify(row, targets):
    """universal | restricted | subset | none | undetermined, from the
    per-encoding, per-sample verdicts."""
    n = len(row["samples"])
    best = None
    for enc, per in row["encodings"].items():
        ok = [i for i, p in enumerate(per) if p and all(x == "exact" for x in p.values())]
        if len(ok) == n:
            return {"class": "universal", "encoding": enc,
                    "all": sorted(e for e, pp in row["encodings"].items()
                                  if all(p and all(x == "exact" for x in p.values()) for p in pp))}
        if ok and (best is None or len(ok) > len(best[1])):
            best = (enc, ok)
    if best:
        return {"class": "restricted", "encoding": best[0],
                "note": "samples %s of %d" % (",".join(str(i) for i in best[1]), n),
                "portable_samples": [row["samples"][i] for i in best[1]]}
    # the largest set of targets some encoding satisfies for every sample
    sub = None
    for enc, per in row["encodings"].items():
        if any(p is None for p in per):
            continue
        good = [t for t in targets if all(p[t] == "exact" for p in per)]
        if sub is None or len(good) > len(sub[1]):
            sub = (enc, good)
    unobserved = all(p is None or any(x in ("not-run", "adapter-failure", "absent") for x in p.values())
                     for per in row["encodings"].values() for p in per)
    if sub and sub[1]:
        cls = "undetermined" if unobserved and len(sub[1]) == len(targets) else "subset"
        return {"class": cls, "encoding": sub[0], "targets": sub[1],
                "excluded": [t for t in targets if t not in sub[1]]}
    return {"class": "none"}


# -- the chosen rule, generated and checked ----------------------------------

sys.path.insert(0, str(Path(__file__).resolve().parent))
import safety  # noqa: E402


def rule_key_ok(k):
    """Keys of the recommended profile: ASCII [A-Za-z_][A-Za-z0-9_]*, none
    that Bash or a restricted shell treats specially (safety.SPECIAL) and
    none a runtime obeys at startup (safety.LOADER_CONTROL)."""
    import re
    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", k) is None:
        return False
    b = k.encode()
    return b not in safety.SPECIAL and not safety.LOADER_CONTROL.match(b)


def loader_safe(v):
    """A multiline value's continuation line must not read as an assignment of
    a variable a runtime obeys: the census never loads such a file into a
    process (safety.classify), so its meaning there is unverified."""
    return safety.classify(('K="%s"\n' % v).encode("utf-8"))["loader"]["run"]


EXCLUDED = set('"\\$`')
MULTILINE_EXCLUDED = set("#\u0085\u2028\u2029")


def rule_value_ok(v, multiline=False):
    """The admissible value domain, derived from results/portable/: Unicode
    scalar values except the four characters no double-quoted form carries
    portably (" \\ $ `), every C0 control but TAB (CR and NUL have no common
    encoding; DotNetEnv rejects the others), DEL and the C1 controls
    (DotNetEnv). LF is the multiline extension's only: allowed when the
    value does not start with it and holds no #, NEL, LS or PS
    (dotenv-java's line accumulation)."""
    if "\n" in v:
        if not multiline or v.startswith("\n") or MULTILINE_EXCLUDED & set(v) or not loader_safe(v):
            return False
    for ch in v:
        o = ord(ch)
        if ch in EXCLUDED or 0x7F <= o <= 0x9F or 0xD800 <= o <= 0xDFFF:
            return False
        if o < 0x20 and ch not in "\t\n":
            return False
    return True


def emit(assignments, multiline=False):
    seen = set()
    for k, v in assignments:
        if not rule_key_ok(k):
            raise ValueError("key outside the portable profile: %r" % k)
        if k.upper() in seen:
            raise ValueError("keys must differ case-insensitively: %r" % k)
        seen.add(k.upper())
        if not rule_value_ok(v, multiline):
            raise ValueError("value outside the portable profile for %s" % k)
    return "".join('%s="%s"\n' % (k, v) for k, v in assignments)


def random_value(rnd, multiline=False):
    """A value from the whole admissible domain, weighted towards the
    characters with a meaning somewhere: ASCII punctuation, whitespace, LF
    (multiline only, never first), Unicode separators, astral characters,
    noncharacters."""
    special = list("!#%&'()*+,-./:;<=>?@[]^_{|}~ \t") + ["\u00a0", "\u2028", "\u2029",
                                                        "\u200b", "\ufeff", "\ufffe", "\uffff", "\u0301"]
    if multiline:
        special = [c for c in special if c not in MULTILINE_EXCLUDED] + ["\n"] * 6

    def ch():
        r = rnd.random()
        if r < 0.45:
            return rnd.choice("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        if r < 0.75:
            return rnd.choice(special)
        while True:
            o = rnd.choice([rnd.randint(0xA0, 0x7FF), rnd.randint(0x800, 0xFFFF), rnd.randint(0x10000, 0x10FFFF)])
            if not 0xD800 <= o <= 0xDFFF and not (multiline and chr(o) in MULTILINE_EXCLUDED):
                return chr(o)
    n = rnd.choice([0, 1, 2, 3, 5, 10, 40, 200, 2000])
    v = "".join(ch() for _ in range(n))
    while v.startswith("\n"):
        v = v[1:]
    if not rule_value_ok(v, multiline):
        return random_value(rnd, multiline)
    return v


def roundtrip(seed, files, multiline=False):
    rnd = random.Random(seed)
    recs = []
    for i in range(files):
        n = rnd.randint(1, 12)
        keys = []
        while len(keys) < n:
            k = rnd.choice(["K", "APP", "DB", "X", "_P", "svc", "Mixed"]) + "_" + str(rnd.randint(0, 999))
            if k.upper() not in {x.upper() for x in keys} and rule_key_ok(k):
                keys.append(k)
        pairs = [(k, random_value(rnd, multiline)) for k in keys]
        recs.append(corpus.record(dict(id="rt-%d-%04d" % (seed, i), category="portable-roundtrip",
                                       description="Random portable map (seed %d, file %d%s)"
                                       % (seed, i, ", multiline" if multiline else ""),
                                       data=emit(pairs, multiline), intended=dict(pairs), modes=["clean"])))
    work = common.CACHE / "roundtrip"
    work.mkdir(parents=True, exist_ok=True)
    path = work / ("roundtrip-%d.jsonl" % seed)  # regenerated from the seed; not committed
    corpus.write_jsonl(recs, path)
    out = work / ("results-%d" % seed)
    subprocess.run([sys.executable, "-I", str(common.AUDIT / "tools" / "run.py"), "--corpus", str(path),
                    "--targets", ",".join(common.REFERENCE), "--modes", "clean", "--out", str(out),
                    "--elide", "0"] + (["--any-runtime"] if "--any-runtime" in sys.argv else []), check=True)
    results = analyze.load_results(out)
    v = verdicts(results, recs, [t for t in common.REFERENCE if t in results])
    bad = {fid: {t: x for t, x in per.items() if x != "exact"} for fid, per in v.items()
           if any(x != "exact" for x in per.values())}
    summary = {"seed": seed, "files": files, "multiline": multiline, "targets": sorted(results), "failures": bad,
               "assignments": sum(len(r["intended"]) for r in recs)}
    common.dump_json(summary, OUT / ("roundtrip-%d.json" % seed))
    import shutil
    shutil.rmtree(out, ignore_errors=True)
    print("roundtrip seed %d: %d files, %d assignments, %d files with a difference"
          % (seed, files, summary["assignments"], len(bad)))
    return not bad


def report():
    d = common.load_json(OUT / "encodings.json")
    ts = d["targets"]
    lines = ["# The portable emission profile: evidence", "",
             "Generated by `tools/portable.py report` from `results/portable/`; do not edit. A candidate encoding",
             "passes for a sample value when every reference target (%s) reads back exactly" % ", ".join(ts),
             "`PORTABLE_KEY=<value>` and nothing else. Classes: **universal** (one encoding works for every sample",
             "on every target), **restricted** (an encoding works for some samples only), **subset** (no encoding",
             "works on every target; the largest set an encoding satisfies is named), **none**.", "",
             "| category | class | portable encodings | excluded targets / note |", "|---|---|---|---|"]
    for cat, row in d["categories"].items():
        c = row["classification"]
        encs = ", ".join("`%s`" % e for e in c.get("all", [])) or ("`%s`" % c["encoding"] if c.get("encoding") else "-")
        note = ", ".join(c.get("excluded", [])) if c["class"] in ("subset", "undetermined") else c.get("note", "")
        lines.append("| %s (%s) | %s | %s | %s |" % (cat, row["what"], c["class"], encs, note))
    lines += ["", "## Per encoding, the targets that misread each sample", "",
              "A cell lists the samples (by index) and the targets that did not read them back exactly;",
              "`(not-run)` means the safety classification forbade the run (unverified is never success).", ""]
    for cat, row in d["categories"].items():
        if row["classification"]["class"] == "universal":
            continue
        lines += ["### %s" % cat, "", "Samples: " + ", ".join("%d=`%s`" % (i, json.dumps(v, ensure_ascii=True)[1:-1].replace("`", "\\`"))
                                                         for i, v in enumerate(row["samples"])), "",
                  "| encoding | misreads |", "|---|---|"]
        for enc, per in row["encodings"].items():
            bad = []
            for i, p in enumerate(per):
                if p is None:
                    bad.append("%d: cannot be written" % i)
                    continue
                miss = ["%s%s" % (t, "" if x == "differs" else "(%s)" % x) for t, x in sorted(p.items()) if x != "exact"]
                if miss:
                    bad.append("%d: %s" % (i, " ".join(miss)))
            lines.append("| %s | %s |" % (enc, "; ".join(bad) or "**all exact**"))
        lines.append("")
    lines += ["## Whole-file layouts", "", "| layout | targets that misread it |", "|---|---|"]
    for lid, per in d["layouts"].items():
        lines.append("| %s | %s |" % (lid, ", ".join(t for t, x in sorted(per.items()) if x != "exact") or "none"))
    lines += ["", "## Keys (with a plain double-quoted value)", "", "| key | targets that misread it |", "|---|---|"]
    for k, per in d["keys"].items():
        lines.append("| %s | %s |" % (k.replace("Key ", "").replace(" with a plain double-quoted value", ""),
                                       ", ".join(t for t, x in sorted(per.items()) if x != "exact") or "none"))
    lines += ["", "## Seeded round trips of the recommended profiles", "",
              "`tools/portable.py roundtrip`: random maps drawn from each profile's whole admissible domain",
              "(`rule_key_ok`, `rule_value_ok`), written by `emit`, read back by every reference target.", "",
              "| seed | profile | files | assignments | files with a difference |", "|---:|---|---:|---:|---:|"]
    for f in sorted(OUT.glob("roundtrip-*.json"), key=lambda p: int(p.stem.split("-")[1])):
        r = common.load_json(f)
        lines.append("| %d | %s | %d | %d | %d |" % (r["seed"], "multiline" if r.get("multiline") else "single-line",
                                                    r["files"], r["assignments"], len(r["failures"])))
    (common.RESULTS / "portable.md").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print("results/portable.md written")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--files", type=int, default=200)
    ap.add_argument("--multiline", action="store_true")
    ap.add_argument("--any-runtime", action="store_true")
    a = ap.parse_args()
    if a.cmd == "corpus":
        build()
    elif a.cmd == "analyze":
        analyze_cmd()
    elif a.cmd == "report":
        report()
    elif a.cmd == "roundtrip":
        sys.exit(0 if roundtrip(a.seed, a.files, a.multiline) else 1)
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
