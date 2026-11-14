"""Real-world example files: pinned, fetched, classified statically, parsed
by the pure parsers -- never executed -- and summarized without values.

  python3 -I tools/realworld.py pin        resolve each ref to its commit, record SHA-256,
                                           size and the license file's first lines
  python3 -I tools/realworld.py fetch      download the pinned bytes into the cache (verified)
  python3 -I tools/realworld.py run        fetch, build the corpus in the cache, run the
                                           targets (Bash is never run on these: run.py's policy)
  python3 -I tools/realworld.py report     results/realworld.json and results/realworld.md

Safety: Bash never sources a downloaded file (run.py refuses origin
"realworld"); Ruby's adapter records command substitutions and never runs
them; a file naming a runtime-control variable is never loaded into a
process (safety.py). The report prints keys, statistics, the features each
file uses and, for a disagreement, which targets differ and the kind --
values appear only as an 8-hex-digit SHA-256 prefix and a shape (length,
quoting), never in clear.
"""

import hashlib
import json
import re
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import analyze  # noqa: E402
import common  # noqa: E402
import corpus  # noqa: E402

MANIFEST = common.AUDIT / "realworld.json"
CACHE = common.CACHE / "realworld"
TARGETS = [t for t in common.REFERENCE if t != "bash"]


def raw_url(repo, commit, path):
    return "https://raw.githubusercontent.com/%s/%s/%s" % (repo, commit, urllib.parse.quote(path))


def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": "dotenv-census"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def slug(f):
    return re.sub(r"[^a-z0-9]+", "-", (f["repo"] + "-" + f["path"]).lower()).strip("-")[:60]


def pin():
    m = common.load_json(MANIFEST)
    for f in m["files"]:
        out = subprocess.run(["git", "ls-remote", "https://github.com/" + f["repo"], f["ref"]],
                             capture_output=True, text=True, timeout=60).stdout.split()
        commit = out[0]
        data = get(raw_url(f["repo"], commit, f["path"]))
        f.update(commit=commit, sha256=hashlib.sha256(data).hexdigest(), size=len(data))
        for name in ("LICENSE", "LICENSE.md", "LICENSE.txt", "license", "license.md", "LICENSE.MD"):
            try:
                head = get(raw_url(f["repo"], commit, name)).decode("utf-8", "replace")
                f["license_file"] = name
                f["license_head"] = " ".join(head.split())[:160]
                break
            except Exception:
                continue
        print("%-40s %s %s %6d bytes" % (f["repo"], commit[:10], f["sha256"][:12], len(data)))
    common.dump_json(m, MANIFEST)


def fetch():
    m = common.load_json(MANIFEST)
    CACHE.mkdir(parents=True, exist_ok=True)
    recs = []
    for f in m["files"]:
        p = CACHE / (slug(f) + ".env")
        if not p.exists() or hashlib.sha256(p.read_bytes()).hexdigest() != f["sha256"]:
            data = get(raw_url(f["repo"], f["commit"], f["path"]))
            if hashlib.sha256(data).hexdigest() != f["sha256"]:
                raise SystemExit("%s %s: content changed at a pinned commit?" % (f["repo"], f["path"]))
            p.write_bytes(data)
        rec = corpus.record(dict(id="rw-" + slug(f), category="realworld",
                                 description="%s:%s@%s" % (f["repo"], f["path"], f["commit"][:12]),
                                 data=p.read_bytes(), modes=["clean"], tags=["realworld"]))
        rec["origin"] = "realworld"
        recs.append(rec)
    corpus.write_jsonl(recs, CACHE / "corpus.jsonl")
    return recs


FEATURES = [
    ("export", re.compile(r"^[ \t]*export[ \t]", re.M)),
    ("double-quoted", re.compile(r'^[ \t]*[\w.-]+[ \t]*=[ \t]*"', re.M)),
    ("single-quoted", re.compile(r"^[ \t]*[\w.-]+[ \t]*=[ \t]*'", re.M)),
    ("backtick", re.compile(r"^[ \t]*[\w.-]+[ \t]*=[ \t]*`", re.M)),
    ("empty-value", re.compile(r"^[ \t]*[\w.-]+[ \t]*=[ \t]*$", re.M)),
    ("interpolation", re.compile(r"\$\{?[A-Za-z_]")),
    ("default-expansion", re.compile(r"\$\{[A-Za-z_][A-Za-z0-9_]*:?-")),
    ("command-substitution", re.compile(r"\$\(")),
    ("inline-comment", re.compile(r"^[ \t]*[\w.-]+[ \t]*=[^#\n]*[ \t]#", re.M)),
    ("hash-in-value", re.compile(r"^[ \t]*[\w.-]+[ \t]*=[^ \t\n]*#", re.M)),
    ("spaces-around-eq", re.compile(r"^[ \t]*[\w.-]+[ \t]+=|^[ \t]*[\w.-]+=[ \t]+\S", re.M)),
    ("unquoted-space", re.compile(r"^[ \t]*[\w.-]+=[^\"'#\n]*\S[ \t]+[^#\s]", re.M)),
    ("multiline-quoted", re.compile(r"^[ \t]*[\w.-]+[ \t]*=[ \t]*\"[^\"\n]*\n", re.M)),
    ("backslash", re.compile(r"\\")),
    ("dollar-literal", re.compile(r"\$[^{A-Za-z_(]")),
    ("lowercase-key", re.compile(r"^[ \t]*(?:export[ \t]+)?[a-z][\w.-]*[ \t]*=", re.M)),
    ("dotted-or-dashed-key", re.compile(r"^[ \t]*(?:export[ \t]+)?[\w]*[.-][\w.-]*[ \t]*=", re.M)),
    ("colon-delimiter", re.compile(r"^[ \t]*[A-Za-z_][\w.-]*:[ \t]", re.M)),
    ("crlf", re.compile(r"\r\n")),
    ("non-ascii", re.compile(r"[^\x00-\x7f]")),
]


def static(data):
    text = data.decode("utf-8", "replace")
    keys = re.findall(r"^[ \t]*(?:export[ \t]+)?([A-Za-z_][\w.-]*)[ \t]*=", text, re.M)
    dup = sorted({k for k in keys if keys.count(k) > 1})
    feats = {name: len(rx.findall(text)) for name, rx in FEATURES}
    return {"lines": text.count("\n") + (0 if text.endswith("\n") else 1), "assignment_lines": len(keys),
            "comment_lines": len(re.findall(r"^[ \t]*#", text, re.M)),
            "duplicate_keys": dup, "features": {k: v for k, v in feats.items() if v}}


def shape(v):
    if v is None:
        return "missing"
    if not isinstance(v, str):
        return "bytes"
    return "len %d sha %s" % (len(v), hashlib.sha256(v.encode("utf-8", "surrogatepass")).hexdigest()[:8])


def run_cmd():
    fetch()
    out = CACHE / "results"
    subprocess.run([sys.executable, "-I", str(common.AUDIT / "tools" / "run.py"), "--corpus",
                    str(CACHE / "corpus.jsonl"), "--targets", ",".join(TARGETS), "--modes", "clean",
                    "--out", str(out)], check=True)


def report():
    m = common.load_json(MANIFEST)
    recs = corpus.read_jsonl(CACHE / "corpus.jsonl")
    results = analyze.load_results(CACHE / "results")
    files = []
    for f, rec in zip(m["files"], recs):
        data = corpus.data_of(rec)
        st = static(data)
        cls, un = analyze.classes(results, TARGETS, rec["id"], "clean")
        per = {}
        for t in TARGETS:
            r = results[t]["results"][rec["id"]]["clean"]
            per[t] = {"status": r["status"], "keys": len(r["map"]) if r["status"] == "ok" else None}
        keys = sorted({k for t in TARGETS for k in (results[t]["results"][rec["id"]]["clean"]["map"] or {})})
        diffs = []
        for k in keys:
            vals = {}
            for t in TARGETS:
                r = results[t]["results"][rec["id"]]["clean"]
                if r["status"] != "ok":
                    continue
                vals.setdefault(shape(r["map"].get(k)), []).append(t)
            if len(vals) > 1:
                diffs.append({"key": k, "groups": [{"value": v, "targets": ts} for v, ts in
                                                   sorted(vals.items(), key=lambda kv: -len(kv[1]))]})
        cmds = sum(len(results["ruby"]["results"][rec["id"]]["clean"].get("events") or []) for _ in [0]) \
            if "ruby" in results else 0
        files.append({"repo": f["repo"], "path": f["path"], "commit": f["commit"], "sha256": f["sha256"],
                      "license": f["license"], "consumer": f["consumer"], "static": st,
                      "safety": rec["safety"], "outcomes": per, "classes": len(cls),
                      "ruby_command_substitutions": cmds, "differing_keys": diffs})
    common.dump_json({"targets": TARGETS, "files": files}, common.RESULTS / "realworld.json")
    lines = ["# Real-world example files", "",
             "Generated by `tools/realworld.py report`; do not edit. Public example files pinned in",
             "`realworld.json` (commit and SHA-256), parsed by the pure targets; Bash never sources them.",
             "Values are never shown: a differing value appears as its length and a SHA-256 prefix.", "",
             "| file | lines | assignments | features | targets agreeing on every key | keys with differing values |",
             "|---|---:|---:|---|---|---|"]
    for f in files:
        agree = [t for t in TARGETS if f["outcomes"][t]["status"] == "ok" and
                 not any(t not in f["differing_keys"][i]["groups"][0]["targets"] for i in range(len(f["differing_keys"])))]
        lines.append("| `%s` `%s` | %d | %d | %s | %s | %d of %d |" % (
            f["repo"], f["path"], f["static"]["lines"], f["static"]["assignment_lines"],
            ", ".join("%s %d" % kv for kv in sorted(f["static"]["features"].items())),
            ", ".join(agree) or "-", len(f["differing_keys"]),
            max([v["keys"] or 0 for v in f["outcomes"].values()] or [0])))
    lines += ["", "## Disagreements per file", ""]
    for f in files:
        bad = {t: v["status"] for t, v in f["outcomes"].items() if v["status"] != "ok"}
        if not f["differing_keys"] and not bad:
            continue
        lines += ["### %s `%s` (%s)" % (f["repo"], f["path"], f["consumer"]), ""]
        if bad:
            lines.append("- rejected or not run: " + ", ".join("%s (%s)" % kv for kv in sorted(bad.items())))
        for d in f["differing_keys"][:25]:
            lines.append("- `%s`: " % d["key"] + "; ".join("%s: %s" % (g["value"], ", ".join(g["targets"]))
                                                         for g in d["groups"]))
        if len(f["differing_keys"]) > 25:
            lines.append("- ... %d more keys" % (len(f["differing_keys"]) - 25))
        lines.append("")
    (common.RESULTS / "realworld.md").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print("results/realworld.md: %d files" % len(files))


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "report"
    {"pin": pin, "fetch": fetch, "run": run_cmd, "report": report}[cmd]()


if __name__ == "__main__":
    main()
