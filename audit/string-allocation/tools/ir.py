#!/usr/bin/env python3
"""ir.py -- deterministic dynamic-instruction matrix, old runtime versus new,
over the canonical corpus (STRING-ALLOCATION.md).

    ir.py OLD-AUDIT-BIN NEW-AUDIT-BIN NIR-DIR OUTDIR [-j N] [-runs R] [-configs a,b] [PROGRAM...]

NIR-DIR holds emit-nir.tcl's NIR (byte-identical in the parent and this tree,
so both runtimes execute exactly the same program). For every program x
configuration x runtime:

  run    callgrind Ir, per steady-state run, of the timed program execution
         (audit frame botlish_audit_run; run 0 outside the window), plus the
         malloc/calloc/realloc and free calls made inside it
  reset  callgrind Ir, per run, of the between-run Vm::reset, which frees what
         the previous run allocated (audit frame botlish_audit_reset): the
         free side the timed window excludes, plus its free calls

The audit binaries are built by
audit/post-r2a-dynamic-census/tools/build-audit-native.sh in each tree.
"""
import json, os, subprocess, sys, hashlib
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cgsum import parse

CONFIGS = ["default", "off", "ascii0", "demand0"]
HEAVY = {"uri-steady", "refined-checks", "csv_records", "csv_chunked", "csv_geometric", "string_replace", "csv", "hashtable"}


def run_cg(binary, nir, kind, runs, tmp):
    env = dict(os.environ, LANG="C.utf8", LC_ALL="C.utf8", BOTLISH_NATIVE_STACK_BYTES=str(64 << 20))
    frame = "botlish_audit_run" if kind == "run" else "botlish_audit_reset"
    if kind == "run":
        env["BOTLISH_AUDIT_SKIP_FIRST"] = "1"
    out = os.path.join(tmp, f"{os.getpid()}-{abs(hash((binary, nir, kind)))}.cg")
    subprocess.run(["valgrind", "--tool=callgrind", "--compress-strings=no", "--compress-pos=no", f"--toggle-collect={frame}",
                    f"--callgrind-out-file={out}", binary, "bench", str(runs + 1), nir],
                   env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    total, selfc, calls = parse(out)
    os.remove(out)
    n = runs if kind == "run" else runs  # run: SKIP_FIRST leaves `runs` collected; reset: one reset before each of `runs` runs
    return {
        "ir": total / n,
        "malloc": sum(calls.get(k, 0) for k in ("malloc", "calloc", "realloc")) / n,
        "free": calls.get("free", 0) / n,
    }


def main():
    args = sys.argv[1:]
    old, new, nirdir, outdir = args[:4]
    rest = args[4:]
    jobs, runs, programs = 3, None, []
    while rest:
        a = rest.pop(0)
        if a == "-j":
            jobs = int(rest.pop(0))
        elif a == "-runs":
            runs = int(rest.pop(0))
        elif a == "-configs":
            CONFIGS[:] = rest.pop(0).split(",")
        else:
            programs.append(a)
    os.makedirs(outdir, exist_ok=True)
    tmp = os.path.join(outdir, "tmp")
    os.makedirs(tmp, exist_ok=True)
    if not programs:
        programs = sorted({f.split(".")[0] for f in os.listdir(nirdir) if f.endswith(".nir")})
    work = []
    seen = {}
    for prog in programs:
        for cfg in CONFIGS:
            path = os.path.join(nirdir, f"{prog}.{cfg}.nir")
            digest = hashlib.sha256(open(path, "rb").read()).hexdigest()
            key = (prog, digest)
            if key in seen:
                continue  # identical NIR under another config: measured once
            seen[key] = cfg
            for rt, binary in (("old", old), ("new", new)):
                for kind in ("run", "reset"):
                    work.append((prog, cfg, rt, kind, binary, path))
    results = {}

    def do(item):
        prog, cfg, rt, kind, binary, path = item
        r = runs or (3 if prog in HEAVY else 5)
        return item, run_cg(binary, path, kind, r, tmp)

    with ThreadPoolExecutor(jobs) as pool:
        for item, res in pool.map(do, work):
            prog, cfg, rt, kind, _, _ = item
            results.setdefault(prog, {}).setdefault(cfg, {}).setdefault(rt, {})[kind] = res
            print(prog, cfg, rt, kind, round(res["ir"]), flush=True)
    # configs sharing a NIR with an earlier config copy its results
    for prog in programs:
        for cfg in CONFIGS:
            path = os.path.join(nirdir, f"{prog}.{cfg}.nir")
            digest = hashlib.sha256(open(path, "rb").read()).hexdigest()
            src = seen[(prog, digest)]
            if src != cfg:
                results[prog][cfg] = dict(results[prog][src], same_nir_as=src)
    json.dump(results, open(os.path.join(outdir, "ir.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
