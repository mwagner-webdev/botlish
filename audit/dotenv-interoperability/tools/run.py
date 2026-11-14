"""The differential runner: every fixture of a corpus through every selected
target, in every environment mode, normalized.

  python3 -I tools/run.py [--corpus hand|generated|minimized|realworld|portable|PATH]
                          [--targets NAME,...|reference|all|cross-version]
                          [--modes clean,conflict] [--only ID,...]
                          [--out DIR] [--jobs N] [--any-runtime]

Results go to DIR/<target>.json (default results/<corpus>/): the target's
meta (runtime and library versions, configuration, the exact environment
supplied in each mode, the command) and, per fixture and mode, one
normalized observation:

  status    ok | error (the implementation rejected the input: an exception
            or a failed load) | not-run (the safety classification forbids
            running it on this target; reasons recorded) | adapter-failure
            (the adapter itself crashed or printed nothing: never counted as
            the implementation's behavior)
  map       the effective key -> value result (value null: present without a
            value, Python's "KEY" line), sorted by key
  error     {class, message} with the fixture's path replaced by <FIXTURE>
  warnings, events, views   as the adapter reported them (events: Ruby's
            command substitutions; views: secondary APIs of one load)

A loading target (Node's --env-file, Bun) reports what a program then sees:
the variables whose value differs from the environment it was given, plus
the keys the file declares that it left at the environment's value (also
listed in views.kept).
"""

import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common  # noqa: E402
import corpus  # noqa: E402

# Sourced with every assignment exported (the usual `set -a; . ./.env` idiom),
# then every shell variable printed NUL-delimited: name, its declare flags,
# value. Portable to Bash 3.2 (macOS's /bin/bash): no ${!x@a}.
BASH_SCRIPT = (
    'shopt -u sourcepath; set -a; source fixture.env; __census_rc=$?; set +a; '
    'for __census_n in $(compgen -v); do case $__census_n in __census_*) continue;; esac; '
    '__census_d=$(declare -p "$__census_n"); __census_d=${__census_d#declare }; '
    'printf "%s\\0%s\\0%s\\0" "$__census_n" "${__census_d%% *}" "${!__census_n}"; done; '
    'printf "%s\\0%s\\0%s\\0" __census_rc - "$__census_rc"'
)
# Bash variables whose value changes from run to run or reflects the dump
# itself, never a fixture's doing (the fixtures cannot assign them: safety.SPECIAL).
BASH_DYNAMIC = {"BASHPID", "BASH_COMMAND", "BASH_EXECUTION_STRING", "EPOCHREALTIME", "EPOCHSECONDS",
                "LINENO", "RANDOM", "SRANDOM", "SECONDS", "PIPESTATUS", "BASH_LINENO", "_", "PPID",
                "HISTCMD", "BASH_SUBSHELL", "COLUMNS", "LINES", "PWD", "OLDPWD"}
ELIDE = 8192
DECLARED = re.compile(rb"^[ \t]*(?:export[ \t]+)?([A-Za-z_][A-Za-z0-9_.\-]*)[ \t]*[=:]", re.M)


def text_value(b):
    try:
        return b.decode("utf-8")
    except UnicodeDecodeError:
        return {"bytes_hex": b.hex()}


def declared_keys(data):
    return sorted({m.group(1).decode("latin-1") for m in DECLARED.finditer(data)})


def clip(s, n=600):
    """A long message kept as its start and its digest."""
    if isinstance(s, str) and len(s) > n:
        return "%s... [%d characters, sha256 %s]" % (s[:n], len(s), hashlib.sha256(s.encode("utf-8", "surrogatepass")).hexdigest()[:16])
    return s


def scrub(s, paths):
    """A message with the run's own paths replaced: the fixture's (and the
    scratch tree's) by <FIXTURE>, the audit's and the cache's by <AUDIT> and
    <CACHE>, so results do not depend on where the census ran."""
    if not isinstance(s, str):
        return s
    for p in paths:
        s = s.replace(p, "<FIXTURE>")
        s = s.replace(p.replace("\\", "/"), "<FIXTURE>")
    for p, label in ((str(common.AUDIT), "<AUDIT>"), (str(common.CACHE), "<CACHE>")):
        s = s.replace(p, label).replace(p.replace("\\", "/"), label)
    return s


def normalize(raw, paths):
    out = {"status": raw.get("status", "adapter-failure")}
    if out["status"] == "ok":
        m = {}
        for k, v in raw.get("assignments") or []:
            m[k if isinstance(k, str) else json.dumps(k)] = v
        out["map"] = dict(sorted(m.items()))
        text = json.dumps(out["map"], sort_keys=True, ensure_ascii=True)
        if ELIDE and len(text) > ELIDE:
            # a stress fixture's map: kept as its exact digest (equality stays
            # byte for byte), its size and its first keys
            first = [k[:64] for k in list(out["map"])[:3]]
            out["map"] = {}
            out["map_elided"] = {"sha256": hashlib.sha256(text.encode()).hexdigest(), "keys": len(m),
                                 "bytes": len(text), "first_keys": first}
    else:
        out["map"] = {}
    err = raw.get("error")
    out["error"] = None if not err else {"class": err.get("class"), "message": clip(scrub(err.get("message"), paths))}
    for k in ("warnings", "events"):
        if raw.get(k):
            out[k] = [clip(scrub(w, paths)) if isinstance(w, str) else w for w in raw[k]]
    views = raw.get("views") or {}
    if views:
        out["views"] = {}
        for k, v in views.items():
            v = dict(sorted({a: b for a, b in v}.items())) if isinstance(v, list) else v
            text = json.dumps(v, sort_keys=True, ensure_ascii=True)
            if ELIDE and len(text) > ELIDE:
                v = {"<elided>": "%d entries, sha256 %s" % (len(v), hashlib.sha256(text.encode()).hexdigest())}
            out["views"][k] = v
    for k in ("reasons", "returncode"):
        if k in raw:
            out[k] = raw[k]
    if "stderr" in raw:
        out["stderr"] = scrub(raw["stderr"], paths)
    return out


class Runner:
    def __init__(self, scratch, jobs, any_runtime=False):
        self.scratch = scratch
        self.jobs = jobs
        self.any_runtime = any_runtime
        self.fxdir = os.path.join(scratch, "fx")
        os.makedirs(self.fxdir, exist_ok=True)
        self.files = {}
        self.lock = threading.Lock()

    def file(self, rec):
        with self.lock:
            return self._file(rec)

    def _file(self, rec):
        if rec["id"] not in self.files:
            p = os.path.join(self.fxdir, "f%04d.env" % len(self.files))
            with open(p, "wb") as f:
                f.write(corpus.data_of(rec))
            self.files[rec["id"]] = p
        return self.files[rec["id"]]

    # -- the run kinds --------------------------------------------------------

    def batch(self, t, recs, env, extra=()):
        """One adapter process for the fixtures; a crash is resumed after the
        fixture that caused it, which is recorded as an adapter failure."""
        results, meta = {}, None
        pending = list(recs)
        tag = re.sub(r"[^a-z0-9]", "_", t["name"])
        while pending:
            manifest = os.path.join(self.scratch, "manifest-%s-%d.json" % (tag, os.getpid()))
            if t["run"] == "process":
                manifest = os.path.join(self.scratch, "manifest-%s-%s.json" % (tag, pending[0]["id"]))
            with open(manifest, "w", encoding="utf-8") as f:
                json.dump({"fixtures": [{"id": r["id"], "path": self.file(r)} for r in pending]}, f)
            cmd = list(t["cmd"]) + ["--manifest", manifest] + list(extra)
            try:
                p = subprocess.run(cmd, env=env, cwd=self.scratch, capture_output=True,
                                   timeout=120 + 5 * len(pending))
                out, err, rc = p.stdout, p.stderr, p.returncode
            except subprocess.TimeoutExpired as e:
                out, err, rc = e.stdout or b"", (e.stderr or b"") + b"\n[timeout]", -1
            got = 0
            for line in out.decode("utf-8", "replace").split("\n"):
                line = line.strip()
                if not line.startswith("{"):
                    continue
                o = json.loads(line)
                if o.get("type") == "meta":
                    meta = meta or o
                elif o.get("type") == "result" and o["id"] not in results:
                    results[o["id"]] = o
                    got += 1
            rest = [r for r in pending if r["id"] not in results]
            if rest and not got:
                results[rest[0]["id"]] = {"status": "adapter-failure", "returncode": rc,
                                          "stderr": err.decode("utf-8", "replace")[-2000:]}
                rest = rest[1:]
            pending = rest
        return meta, results

    def process(self, t, recs, env):
        results, metas = {}, []

        def one(r):
            return self.batch(dict(t), [r], env)

        with concurrent.futures.ThreadPoolExecutor(self.jobs) as ex:
            for meta, res in ex.map(one, recs):
                metas.append(meta)
                results.update(res)
        return next((m for m in metas if m), None), results

    def dump(self, t, recs, env):
        results, runtimes = {}, set()
        cwd = os.path.join(self.scratch, "empty-cwd")
        os.makedirs(cwd, exist_ok=True)
        # A control run on an empty file: what the runtime's process holds
        # without any fixture -- the supplied environment plus whatever the
        # host adds to every process (macOS adds __CF_USER_TEXT_ENCODING).
        # A fixture's assignments are the differences from it.
        empty = os.path.join(self.scratch, "empty.env")
        with open(empty, "wb"):
            pass
        p = subprocess.run(t["cmd"](empty), env=env, cwd=cwd, capture_output=True, timeout=60)
        lines = [l for l in p.stdout.decode("utf-8", "replace").split("\n") if l.strip()]
        control = json.loads(lines[-1])["env"] if p.returncode == 0 and lines else dict(env)
        host_added = sorted(k for k in control if env.get(k) != control[k])

        def one(r):
            path = self.file(r)
            try:
                p = subprocess.run(t["cmd"](path), env=env, cwd=cwd, capture_output=True, timeout=60)
                out, err, rc = p.stdout, p.stderr, p.returncode
            except subprocess.TimeoutExpired as e:
                out, err, rc = e.stdout or b"", b"[timeout]", -1
            line = [l for l in out.decode("utf-8", "replace").split("\n") if l.strip()]
            if rc != 0 or not line:
                # the runtime refused to start with this file: the loader's error
                return r["id"], None, {"status": "error", "assignments": [],
                                       "error": {"class": "exit %d" % rc,
                                                 "message": err.decode("utf-8", "replace").strip()[-600:]}}
            o = json.loads(line[-1])
            got = o["env"]
            delta = [[k, v] for k, v in sorted(got.items()) if control.get(k) != v]
            kept = [[k, env[k]] for k in declared_keys(corpus.data_of(r)) if k in env and got.get(k) == env[k]]
            removed = [[k, env[k]] for k in sorted(env) if k not in got]
            views = {}
            if kept:
                views["kept"] = kept
            if removed:
                views["removed"] = removed
            # what a program sees for every key: the changed variables, and the
            # declared keys the loader left at the environment's value
            return r["id"], o.get("runtime"), {"status": "ok", "assignments": delta + kept, "error": None,
                                               "views": views}

        with concurrent.futures.ThreadPoolExecutor(self.jobs) as ex:
            for fid, rt, res in ex.map(one, recs):
                results[fid] = res
                if rt:
                    runtimes.add(rt)
        meta = {"runtime": ", ".join(sorted(runtimes)), "library": t["name"], "library_version": t["version"],
                "options": {"api": t["api"]}}
        if host_added:
            meta["host_added_variables"] = host_added
        return meta, results

    def bash(self, t, recs, env):
        bash = common.tool("bash")
        results = {}
        empty = os.path.join(self.scratch, "bash-empty-path")
        os.makedirs(empty, exist_ok=True)
        benv = dict(env)
        benv["PATH"] = empty

        def run_one(data, tag):
            d = tempfile.mkdtemp(prefix="bash-" + tag + "-", dir=self.scratch)
            with open(os.path.join(d, "fixture.env"), "wb") as f:
                f.write(data)
            try:
                p = subprocess.run([bash, "--noprofile", "--norc", "-r", "-c", BASH_SCRIPT], env=benv, cwd=d,
                                   capture_output=True, timeout=20)
                out, err, rc = p.stdout, p.stderr, p.returncode
            except subprocess.TimeoutExpired:
                out, err, rc = b"", b"[timeout]", -1
            shutil.rmtree(d, ignore_errors=True)
            parts = out.split(b"\0")
            vars_ = {}
            for i in range(0, len(parts) - 2, 3):
                vars_[parts[i].decode("latin-1")] = (parts[i + 1].decode("latin-1"), parts[i + 2])
            return vars_, err, rc

        control, _, _ = run_one(b"", "control")
        version = control.get("BASH_VERSION", ("", b"?"))[1].decode()

        def one(r):
            vars_, err, rc = run_one(corpus.data_of(r), "fx")
            if "__census_rc" not in vars_:
                return r["id"], {"status": "adapter-failure", "returncode": rc,
                                 "stderr": err.decode("utf-8", "replace")[-2000:]}
            src_rc = int(vars_.pop("__census_rc")[1] or b"0")
            delta = []
            for k, (attrs, val) in sorted(vars_.items()):
                if k in BASH_DYNAMIC or "a" in attrs or "A" in attrs:
                    continue
                if control.get(k) != (attrs, val):
                    delta.append([k, text_value(val)])
            messages = [l for l in err.decode("utf-8", "replace").splitlines() if l.strip()]
            res = {"status": "ok", "assignments": delta, "error": None, "warnings": messages}
            if src_rc != 0 or messages:
                res["views"] = {"source_status": [["status", str(src_rc)]]}
            return r["id"], res

        with concurrent.futures.ThreadPoolExecutor(self.jobs) as ex:
            for fid, res in ex.map(one, recs):
                results[fid] = res
        meta = {"runtime": "GNU Bash " + version, "library": "bash", "library_version": version,
                "options": {"api": t["api"], "invocation": "bash --noprofile --norc -r -c SCRIPT",
                            "script": BASH_SCRIPT, "PATH": "an empty directory"}}
        return meta, results

    # -- one target -------------------------------------------------------------

    def target(self, t, recs, modes, trusted=None):
        out = {"target": t["name"], "family": t["family"], "role": t["role"], "version": t["version"],
               "api": t["api"], "host": common.HOST, "modes": {}, "results": {}}
        loading = t["run"] in ("dump", "process", "bash")
        for r in recs:
            self.file(r)
        for mode in modes:
            env = common.environment(mode, self.scratch)
            run, skipped = [], {}
            for r in recs:
                if mode not in r["modes"]:
                    continue
                if t["run"] == "bash" and not r["safety"]["bash"]["run"]:
                    skipped[r["id"]] = {"status": "not-run", "reasons": r["safety"]["bash"]["reasons"]}
                elif loading and not r["safety"]["loader"]["run"]:
                    skipped[r["id"]] = {"status": "not-run", "reasons": r["safety"]["loader"]["reasons"]}
                elif t.get("trusted_only") and not r.get("trusted"):
                    skipped[r["id"]] = {"status": "not-run", "reasons": ["not an audited command fixture"]}
                elif r.get("origin") == "realworld" and t["run"] == "bash":
                    skipped[r["id"]] = {"status": "not-run", "reasons": ["policy: downloaded files are never sourced"]}
                else:
                    run.append(r)
            started = time.time()
            if not run:
                meta, res = None, {}
            elif t["run"] == "batch":
                extra = ()
                if t.get("trusted_only"):
                    tf = os.path.join(self.scratch, "trusted.json")
                    with open(tf, "w", encoding="utf-8") as f:
                        json.dump({r["id"]: r["trusted"] for r in run}, f)
                    extra = ("--trusted", tf)
                meta, res = self.batch(t, run, env, extra)
            elif t["run"] == "process":
                meta, res = self.process(t, run, env)
            elif t["run"] == "dump":
                meta, res = self.dump(t, run, env)
            else:
                meta, res = self.bash(t, run, env)
            res.update(skipped)
            for r in run:
                res.setdefault(r["id"], {"status": "adapter-failure", "stderr": "no result"})
            paths = list(self.files.values()) + [self.scratch]
            out["modes"][mode] = {"environment": {k: ("<scratch>" + v[len(self.scratch):] if v.startswith(self.scratch) else v)
                                                  for k, v in env.items()},
                                  "meta": meta, "ran": len(run), "not_run": len(skipped)}
            for fid, raw in res.items():
                out["results"].setdefault(fid, {})[mode] = normalize(raw, paths)
        out["results"] = dict(sorted(out["results"].items()))
        return out


def select(spec):
    allt = common.targets()
    if spec in (None, "", "reference"):
        return [allt[n] for n in common.REFERENCE]
    if spec == "all":
        return list(allt.values())
    if spec in ("configuration", "cross-version", "supplement"):
        return [t for t in allt.values() if t["role"] == spec]
    if spec == "default":
        return [t for t in allt.values() if t["role"] != "cross-version"]
    return [allt[n] for n in spec.split(",")]


def check_runtimes(ts, any_runtime):
    v = common.versions()["host_runtimes"]
    problems = []
    fams = {t["family"] for t in ts}
    probes = {
        "bash": ([common.tool("bash"), "--version"], v["bash"]["expect"]),
        "ruby": ([common.tool("ruby"), "-e", "print RUBY_VERSION"], v["ruby"]["expect"]),
        "python": ([common.python_bin(), "-c", "import sys;print('%d.%d'%sys.version_info[:2])"], v["python"]["expect"]),
        "java": ([common.tool("java"), "-XshowSettings:properties", "-version"], None),
    }
    found = {}
    for fam, (cmd, want) in probes.items():
        if fam not in fams:
            continue
        try:
            p = subprocess.run(cmd, capture_output=True, timeout=60, env={k: os.environ[k] for k in os.environ if k in ("PATH", "SystemRoot", "HOME")})
            text = (p.stdout + p.stderr).decode("utf-8", "replace")
        except OSError as e:
            text = "missing: %s" % e
        if fam == "java":
            m = re.search(r"java\.specification\.version = (\S+)", text)
            found[fam] = m.group(1) if m else text.strip()[:60]
            want = v["java"]["expect"]
        else:
            found[fam] = text.strip().splitlines()[0] if text.strip() else "?"
        if want and want not in found[fam]:
            problems.append("%s: expected %s, found %r" % (fam, want, found[fam]))
    if problems and not any_runtime:
        raise SystemExit("host runtimes differ from versions.json (pass --any-runtime to run anyway):\n  "
                         + "\n  ".join(problems))
    return found, problems


def main():
    global ELIDE
    ap = argparse.ArgumentParser()
    ap.add_argument("--corpus", default="hand")
    ap.add_argument("--targets", default="default")
    ap.add_argument("--modes", default="clean,conflict")
    ap.add_argument("--only", default="")
    ap.add_argument("--out", default=None)
    ap.add_argument("--jobs", type=int, default=max(2, os.cpu_count() or 2))
    ap.add_argument("--any-runtime", action="store_true")
    ap.add_argument("--keep-scratch", action="store_true")
    ap.add_argument("--elide", type=int, default=ELIDE,
                    help="store a map larger than this many bytes as its digest (0: never)")
    a = ap.parse_args()
    ELIDE = a.elide
    recs = corpus.load(a.corpus)
    if a.only:
        want = set(a.only.split(","))
        recs = [r for r in recs if r["id"] in want]
    ts = select(a.targets)
    found, problems = check_runtimes(ts, a.any_runtime)
    name = a.corpus if a.corpus in ("hand", "generated", "minimized", "realworld", "portable") else Path(a.corpus).stem
    out = Path(a.out) if a.out else common.RESULTS / name
    out.mkdir(parents=True, exist_ok=True)
    modes = [m for m in a.modes.split(",") if m]
    scratch = tempfile.mkdtemp(prefix="dotenv-census-")
    try:
        runner = Runner(scratch, a.jobs, a.any_runtime)
        for r in recs:
            runner.file(r)

        def go(t):
            started = time.time()
            res = runner.target(t, recs, modes)
            res["host_runtimes"] = {k: found[k] for k in found if k == t["family"] or
                                    (k == "python" and t["family"] == "python")}
            if problems:
                res["runtime_mismatch"] = problems
            path = out / (t["name"].replace("@", "-at-") + ".json")
            common.dump_results(res, path)
            failures = sum(1 for v in res["results"].values() for m in v.values() if m["status"] == "adapter-failure")
            return "%-20s %5.1fs  %d fixtures%s" % (t["name"], time.time() - started, len(res["results"]),
                                                   ("  ADAPTER FAILURES: %d" % failures) if failures else "")

        batch = [t for t in ts if t["run"] == "batch"]
        other = [t for t in ts if t["run"] != "batch"]
        with concurrent.futures.ThreadPoolExecutor(max(1, a.jobs // 2)) as ex:
            for line in ex.map(go, batch):
                print(line, flush=True)
        for t in other:
            print(go(t), flush=True)
    finally:
        if not a.keep_scratch:
            shutil.rmtree(scratch, ignore_errors=True)
        else:
            print("scratch kept:", scratch)


if __name__ == "__main__":
    main()
