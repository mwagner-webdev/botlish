"""The whole census in one command, and the compact matrix.

  python3 -I tools/census.py all [--host-only]
      every corpus through every target, the analyses and the reports, into
      the results root (results/, or $DOTENV_CENSUS_RESULTS: CI writes a fresh
      tree there and compares it with the committed one, tools/compare.py)
  python3 -I tools/census.py matrix
      results/matrix.md from results/hand/

Steps of `all`, in order: the hand corpus is checked current (fixtures/*.py
-> fixtures/corpus.jsonl) and the generated corpus regenerated (its seed is
fixed; CI fails on a difference); the hand corpus runs through every target
(both environment modes), the generated corpus through the reference
targets (clean mode), the minimized corpus (both modes), the portable
candidates (clean); six seeded round trips check the two portable profiles;
then analyze.py, portable.py analyze, the matrix and the portable report. A
round trip's differences are recorded (results/portable/roundtrip-N.json),
never a reason to stop: tools/compare.py decides what fails.
--host-only skips what needs the Linux-only pins (cross-version targets);
--any-runtime lets a host runtime differ from versions.json (macOS's Bash
3.2, Git for Windows' Bash), recorded with the results.
"""

import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import analyze  # noqa: E402
import common  # noqa: E402
import corpus  # noqa: E402

TOOLS = common.AUDIT / "tools"
SINGLE_SEEDS = [1, 2, 3]
MULTILINE_SEEDS = [101, 102, 103]


ANY_RUNTIME = "--any-runtime" in sys.argv


def py(*args, check=True):
    print("[census] tools/" + " ".join(str(a) for a in args), flush=True)
    extra = ["--any-runtime"] if ANY_RUNTIME and args[0] == "run.py" else []
    subprocess.run([sys.executable, "-I", str(TOOLS / args[0])] + [str(a) for a in args[1:]] + extra, check=check)


def all_(host_only):
    ref = ",".join(common.REFERENCE)
    py("corpus.py", "check")
    py("generate.py", "check")
    if common.RESULTS != common.AUDIT / "results":
        common.RESULTS.mkdir(parents=True, exist_ok=True)
    py("run.py", "--corpus", "hand", "--targets", "default" if host_only else "all")
    py("run.py", "--corpus", "generated", "--targets", ref, "--modes", "clean")
    py("run.py", "--corpus", "minimized", "--targets", ref)
    py("portable.py", "corpus")
    py("run.py", "--corpus", "portable", "--targets", ref, "--modes", "clean")
    for s in SINGLE_SEEDS:
        py("portable.py", "roundtrip", "--seed", s, "--files", 300, *(["--any-runtime"] if ANY_RUNTIME else []),
           check=False)
    for s in MULTILINE_SEEDS:
        py("portable.py", "roundtrip", "--seed", s, "--files", 300, "--multiline",
           *(["--any-runtime"] if ANY_RUNTIME else []), check=False)
    for c in ("hand", "generated", "minimized"):
        py("analyze.py", "--corpus", c)
    py("portable.py", "analyze")
    py("portable.py", "report")
    matrix()


# The compact matrix: one representative fixture per principal feature, as
# the reference targets read it. Every cell is an observation (results/hand).
ROWS = [
    ("Plain KEY=value", "assign-basic", "KEY"),
    ("Empty value KEY=", "assign-empty", "KEY"),
    ("Bare key KEY", "assign-bare", "KEY"),
    ("Spaces around =", "assign-spaces-around-eq", "KEY"),
    ("export KEY=value", "assign-export", "KEY"),
    ("export<TAB>KEY=value", "assign-export-tab", "KEY"),
    ("YAML-style KEY: value", "assign-colon", "KEY"),
    ("CRLF line ends", "assign-crlf", "A"),
    ("Lowercase key", "name-lower", "key"),
    ("Dotted key my.key", "name-dot", "my.key"),
    ("Hyphenated key MY-KEY", "name-hyphen", "MY-KEY"),
    ("Non-ASCII key", "name-latin1-range", "CL\u00c9"),
    ("Inline comment after space", "comment-inline-space", "KEY"),
    ("# right after the value", "comment-inline-nospace", "KEY"),
    ("Single quotes", "quote-single", "KEY"),
    ("Double quotes", "quote-double", "KEY"),
    ("Backtick quotes", "quote-backtick", "KEY"),
    ("Text after closing quote", "quote-text-after-double", "KEY"),
    ("Unterminated double quote", "quote-unterminated-double", "KEY"),
    ("Escaped quote in double quotes", "quote-escaped-double", "KEY"),
    ("Trailing spaces, unquoted", "ws-trailing-unquoted", "KEY"),
    ("\\n in double quotes", "esc-n-double", "KEY"),
    ("\\n in single quotes", "esc-n-single", "KEY"),
    ("\\\\ in double quotes", "esc-double-backslash-double", "KEY"),
    ("\\$ in double quotes", "esc-dollar-double", "KEY"),
    ("${NAME} unquoted", "interp-braced", "KEY"),
    ("${NAME} in single quotes", "interp-single-quoted", "KEY"),
    ("${NAME:-default}", "interp-default", "KEY"),
    ("Reference to a later key", "interp-later", "KEY"),
    ("Literal newline in double quotes", "ml-double", "KEY"),
    ("Literal newline in single quotes", "ml-single", "KEY"),
    ("UTF-8 BOM", "enc-bom", "KEY"),
    ("Invalid UTF-8 byte", "enc-invalid-ff", "KEY"),
    ("NUL byte in a value", "enc-nul-in-value", "KEY"),
    ("Duplicate key", "dup-different", "KEY"),
    ("$(command)", "cmd-dollar-paren", "KEY"),
]
ENV_ROWS = [
    ("File assigns an existing variable (conflict mode)", "env-preset-assigned", "CENSUS_PRESET"),
    ("File references an environment-only variable (conflict mode)", "env-ref-only", "KEY"),
]


def show(v):
    """A value as the matrix prints it: as written, but a backslash doubled,
    a control character as a C escape (\\n, \\r, \\t, \\xHH) and an invisible
    format or separator character as \\uXXXX."""
    import unicodedata
    out = []
    for ch in v:
        o = ord(ch)
        if ch == "\\":
            out.append("\\\\")
        elif ch in "\n\r\t":
            out.append({"\n": "\\n", "\r": "\\r", "\t": "\\t"}[ch])
        elif o < 0x20 or 0x7F <= o <= 0x9F:
            out.append("\\x%02x" % o)
        elif unicodedata.category(ch) in ("Cf", "Zl", "Zp", "Co", "Cn", "Cs"):
            out.append("\\u%04x" % o)
        elif ch == "|":
            out.append("\\|")
        else:
            out.append(ch)
    return "".join(out)


def cell(r, key):
    if r is None:
        return "-"
    if r["status"] == "not-run":
        return "not run"
    if r["status"] == "adapter-failure":
        return "adapter failure"
    if r["status"] == "error":
        return "**error**"
    if key not in r["map"]:
        keys = sorted(r["map"])
        return "_absent_" + ((" (keys: %s)" % ", ".join("`%s`" % show(k) for k in keys[:2])) if keys else "")
    v = r["map"][key]
    if v is None:
        return "_no value_"
    if isinstance(v, dict):
        return "bytes " + v.get("bytes_hex", "?")
    s = show(v)
    if "\ue000CMD" in v:
        s = "runs the command"
    s = s if len(s) <= 24 else s[:23] + "\u2026"
    if not s:
        return "(empty)"
    return "``%s``" % s if "`" in s else "`%s`" % s


def matrix():
    results = analyze.load_results(common.RESULTS / "hand")
    recs = {r["id"]: r for r in corpus.load("hand")}
    ts = [t for t in common.REFERENCE if t in results]
    lines = ["# The compact matrix", "",
             "Generated by `tools/census.py matrix` from `results/hand/`; do not edit. One fixture per principal",
             "feature (its id in the second column, its bytes in `fixtures/corpus.jsonl`), the value of one key as",
             "each reference target read it in the clean mode (the last rows: the conflict mode). `**error**`: the",
             "file was rejected; `_absent_`: the key was not assigned; `not run`: the safety classification forbids",
             "running the fixture on that target; `(empty)`: the empty string. Values are shown as read, a backslash",
             "doubled and control characters as C escapes (`\\n`, `\\r`, `\\t`). Ruby's `$(...)` cell: Ruby would run",
             "the command (recorded, never run).", "",
             "| feature | fixture | " + " | ".join(ts) + " |",
             "|---|---|" + "---|" * len(ts)]
    for label, fid, key in ROWS + ENV_ROWS:
        mode = "conflict" if (label, fid, key) in ENV_ROWS else "clean"
        row = [cell(results[t]["results"].get(fid, {}).get(mode), key) for t in ts]
        lines.append("| %s | `%s` | %s |" % (label.replace("|", "\\|"), fid, " | ".join(row)))
    missing = [fid for _, fid, _ in ROWS + ENV_ROWS if fid not in recs]
    if missing:
        raise SystemExit("matrix rows name unknown fixtures: %s" % missing)
    (common.RESULTS / "matrix.md").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print("results/matrix.md: %d rows" % len(ROWS + ENV_ROWS))


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "all"
    if cmd == "all":
        all_("--host-only" in sys.argv)
    elif cmd == "matrix":
        matrix()
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
