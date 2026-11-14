"""The census's emits probe: the portable profiles as declared recognizers
(emits/dotenv_portable.bot) and emitters claiming them (emits/dotenv_emit.bot),
checked by the Botlish compiler; every mutant of emits/mutants.txt must break
the claims it names.

  python3 -I tools/emits.py        (needs tclsh9.0 and the repository's compiler)

Writes results/emits.json and prints one line per claim and per mutant.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common  # noqa: E402

PROBE = common.AUDIT / "emits"
CLAIMS = common.REPO / "audit" / "csv-emission" / "tools" / "claims.tcl"


def claims(directory, entry="probe.bot"):
    p = subprocess.run(["tclsh9.0", str(CLAIMS), str(Path(directory) / entry)], capture_output=True,
                       text=True, cwd=str(common.REPO), timeout=1200,
                       env=dict(os.environ, LANG="C.utf8", LC_ALL="C.utf8"))
    out = {}
    for line in p.stdout.splitlines():
        parts = line.split()
        if len(parts) >= 4:
            out["%s:%s" % (parts[1], parts[2])] = {"verdict": parts[3], "kinds": parts[4:]}
    if not out:
        out["<compile>"] = {"verdict": "failed", "kinds": [p.stderr.strip().splitlines()[0] if p.stderr.strip() else "?"]}
    return out


def mutants():
    for line in (PROBE / "mutants.txt").read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        name, old, new, must = [x.strip() for x in line.split(" | ")]
        dec = lambda s: "" if s == "<nothing>" else s.replace("\\n", "\n")
        yield name, dec(old), dec(new), [m for m in must.split(",") if m]


def main():
    base = claims(PROBE)
    fold = {k: v for k, v in claims(PROBE, "probe_fold.bot").items() if k.startswith("assignment_ml:")}
    for k, v in sorted(base.items()):
        print("%-55s %s %s" % (k, v["verdict"], " ".join(v["kinds"])))
    for k, v in sorted(fold.items()):
        print("%-55s %s %s  (expected: rejected, a recorded precision limit)" % (k, v["verdict"], " ".join(v["kinds"])))
    results = {"claims": base, "precision_limit": fold, "mutants": {}}
    ok = all(v["verdict"] == "proven" for v in base.values()) and \
        all(v["verdict"] == "rejected" for v in fold.values())
    for name, old, new, must in mutants():
        d = tempfile.mkdtemp(prefix="dotenv-emits-")
        try:
            for f in PROBE.glob("*.bot"):
                shutil.copy(f, d)
            src = (Path(d) / "dotenv_emit.bot").read_text(encoding="utf-8")
            if old not in src:
                results["mutants"][name] = {"status": "DOES NOT APPLY"}
                ok = False
                print("%-20s DOES NOT APPLY" % name)
                continue
            (Path(d) / "dotenv_emit.bot").write_text(src.replace(old, new, 1), encoding="utf-8")
            got = claims(d)
            broken = {m: got.get(m, {"verdict": "absent"})["verdict"] for m in must}
            # a mutant that no longer compiles proves nothing: it must break
            # the claims by the checker's verdict, not by a syntax error
            killed = "<compile>" not in got and all(v == "rejected" for v in broken.values())
            results["mutants"][name] = {"status": "killed" if killed else "SURVIVED", "claims": got}
            ok = ok and killed
            print("%-20s %s %s" % (name, "killed" if killed else "SURVIVED",
                                   " ".join("%s=%s" % kv for kv in sorted(broken.items()))))
        finally:
            shutil.rmtree(d, ignore_errors=True)
    common.dump_json(results, common.RESULTS / "emits.json")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
