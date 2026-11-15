"""The census's own checks that need no reference implementation: the Bash
safety classifier, the fixture definitions (unique ids, every byte
materialized, corpus.jsonl current), the generated corpus (current for its
seed), the portable profile's rules against the evidence, the minimizer.

  python3 -I tools/selftest.py
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common  # noqa: E402
import corpus  # noqa: E402
import minimize  # noqa: E402
import portable  # noqa: E402
import safety  # noqa: E402


def check(name, ok, detail=""):
    print("%-48s %s %s" % (name, "ok" if ok else "FAIL", detail))
    return ok


def main():
    ok = True
    ok &= check("safety: classifier selftest", not safety.selftest(), str(safety.selftest()))
    recs = corpus.build_records()
    ok &= check("corpus: ids unique", len({r["id"] for r in recs}) == len(recs))
    want = "".join(json.dumps(r, ensure_ascii=True, sort_keys=True) + "\n" for r in recs)
    ok &= check("corpus: fixtures/corpus.jsonl current",
                (corpus.FIXTURES / "corpus.jsonl").read_text(encoding="utf-8") == want)
    # the one command fixture Bash may run is the single-quoted one: no expansion
    unsafe_run = [r["id"] for r in recs if r["category"] == "commands" and r["safety"]["bash"]["run"]]
    ok &= check("safety: Bash runs no executable command fixture", unsafe_run == ["cmd-dollar-paren-single"],
                str(unsafe_run))
    # the portable rules: the rule may refuse more than the evidence allows
    # (it is a simplification), never admit a sample the evidence refuses
    enc = common.load_json(common.AUDIT / "results" / "portable" / "encodings.json")
    admitted_bad, conservative = [], []
    for cat, row in enc["categories"].items():
        c = row["classification"]
        portable_samples = row["samples"] if c["class"] == "universal" else c.get("portable_samples", [])
        for v in row["samples"]:
            admitted = portable.rule_value_ok(v, multiline=True)
            if admitted and v not in portable_samples:
                admitted_bad.append((cat, v))
            if not admitted and v in portable_samples:
                conservative.append((cat, v))
    ok &= check("portable: the rules admit no unportable sample", not admitted_bad, str(admitted_bad[:4]))
    check("portable: portable samples the rules refuse", True, "(conservative) " + repr(conservative))
    ok &= check("portable: emit refuses a reserved key", not portable.rule_key_ok("PATH")
                and not portable.rule_key_ok("NODE_OPTIONS") and portable.rule_key_ok("APP_NAME"))
    ok &= check("minimize: ddmin finds the one bad item",
                minimize.ddmin(list("abcdefgh"), None, lambda cs: ["e" in c for c in cs]) == ["e"])
    w = minimize.witness({"status": "ok", "map": {"A": "1"}}, {"status": "ok", "map": {"A": "2"}})
    ok &= check("minimize: value witness", w == ("value", "A"), str(w))
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
