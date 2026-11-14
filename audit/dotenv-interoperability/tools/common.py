"""Shared definitions of audit/dotenv-interoperability's tools: paths, the
host, the targets (how each reference implementation is run) and the
controlled environments the oracles start in.

Every tool runs with `python3 -I` from any directory; nothing here reads the
caller's environment except DOTENV_CENSUS_HOME (the cache) and the variables
a host needs to start a process at all (SYSTEMROOT and friends on Windows).
"""

import glob
import json
import os
import platform
import sys
from pathlib import Path

AUDIT = Path(__file__).resolve().parent.parent
REPO = AUDIT.parent.parent
ORACLES = AUDIT / "oracles"
RESULTS = Path(os.environ.get("DOTENV_CENSUS_RESULTS") or (AUDIT / "results"))


def default_cache():
    if os.name == "nt":
        base = os.environ.get("LOCALAPPDATA") or str(Path.home() / "AppData" / "Local")
        return Path(base) / "botlish" / "dotenv-census"
    base = os.environ.get("XDG_CACHE_HOME") or str(Path.home() / ".cache")
    return Path(base) / "botlish" / "dotenv-census"


CACHE = Path(os.environ.get("DOTENV_CENSUS_HOME") or default_cache())


def host():
    s = platform.system()
    m = platform.machine().lower()
    if s == "Linux":
        return "linux-arm64" if m in ("aarch64", "arm64") else "linux-x64"
    if s == "Darwin":
        return "darwin-arm64" if m in ("arm64", "aarch64") else "darwin-x64"
    if s == "Windows":
        return "win-x64"
    return s.lower() + "-" + m


HOST = host()
EXE = ".exe" if os.name == "nt" else ""


def versions():
    with open(AUDIT / "versions.json", encoding="utf-8") as f:
        return json.load(f)


# -- the reference implementations ------------------------------------------

def node_bin(version):
    root = CACHE / ("node-" + version)
    return str(root / "node.exe") if os.name == "nt" else str(root / "bin" / "node")


def bun_bin(lockdir):
    plat = {"linux-x64": "linux-x64", "linux-arm64": "linux-aarch64", "darwin-arm64": "darwin-aarch64",
            "darwin-x64": "darwin-x64", "win-x64": "windows-x64"}[HOST]
    return str(CACHE / "npm" / lockdir / "node_modules" / "@oven" / ("bun-" + plat) / "bin" / ("bun" + EXE))


def ruby_lib(version):
    hits = glob.glob(str(CACHE / "ruby" / ("dotenv-" + version) / "ruby" / "*" / "gems" / ("dotenv-" + version) / "lib"))
    return hits[0] if hits else str(CACHE / "ruby" / ("dotenv-" + version) / "missing")


def dotnet_bin():
    sdk = versions()["dotnet_sdk"]["version"]
    local = CACHE / ("dotnet-" + sdk) / ("dotnet" + EXE)
    if local.exists():
        return str(local)
    import shutil
    return os.environ.get("DOTENV_CENSUS_DOTNET") or shutil.which("dotnet") or "dotnet"


def tool(name):
    """A host runtime the CI host provides (bash, ruby, java): an explicit
    override, else the PATH the census was started with."""
    override = os.environ.get("DOTENV_CENSUS_" + name.upper())
    if override:
        return override
    import shutil
    found = shutil.which(name)
    return found or name


def python_bin():
    return os.environ.get("DOTENV_CENSUS_PYTHON") or sys.executable


# A target: one observed behavior of one implementation in one
# configuration. "family" groups the configurations of one implementation;
# "role" is reference (the census's selected set, default configuration),
# configuration (a documented non-default option of a reference), supplement
# (an additional implementation chosen on evidence), or cross-version.
# "run" is how the harness drives it: batch (one adapter process for many
# fixtures), process (one adapter process per fixture), dump (a runtime that
# loads the file into its own environment, which dump.mjs prints) or bash.

def _batch(cmd, **kw):
    return dict(run="batch", cmd=cmd, **kw)


def targets():
    v = versions()
    N26, N24, N22 = node_bin("26.13.1"), node_bin("24.22.3"), node_bin("22.23.5")
    nb = str(ORACLES / "node-builtin" / "adapter.mjs")
    dump = str(ORACLES / "node-builtin" / "dump.mjs")
    nd = str(ORACLES / "node-dotenv" / "adapter.cjs")
    npm = lambda d: str(CACHE / "npm" / d / "node_modules")
    py = str(ORACLES / "python" / "adapter.py")
    rb = str(ORACLES / "ruby" / "adapter.rb")
    java_cp = lambda ver: os.pathsep.join([str(CACHE / "java" / ("dotenv-java-%s.jar" % ver)),
                                          str(CACHE / "java" / "build" / ver)])
    dn = lambda proj: str(CACHE / "build" / "dotnet" / proj / (proj + ".Adapter.dll"))
    T = {}

    def add(name, family, role, version, **kw):
        kw.setdefault("env_sensitive", False)
        T[name] = dict(name=name, family=family, role=role, version=version, **kw)

    add("bash", "bash", "reference", "GNU Bash (host)", run="bash",
        api="set -a; source FILE (restricted shell, statically audited fixtures only)", env_sensitive=True)
    add("node-builtin", "node-builtin", "reference", "Node.js 26.13.1",
        **_batch([N26, nb]), api="util.parseEnv(text)")
    add("node-envfile", "node-envfile", "reference", "Node.js 26.13.1", run="dump",
        cmd=lambda f: [N26, "--env-file=" + f, dump], api="node --env-file=FILE", env_sensitive=True)
    add("node-dotenv", "node-dotenv", "reference", "dotenv 18.0.10",
        **_batch([N26, nd, "--lib", npm("node-dotenv")]), api="dotenv.parse(text)")
    add("node-dotenv-fast", "node-dotenv", "configuration", "dotenv 18.0.10",
        **_batch([N26, nd, "--lib", npm("node-dotenv"), "--config", "fast"]), api="dotenv.parse(text, {fast: true})")
    add("bun", "bun", "reference", "Bun 1.4.4", run="dump",
        cmd=lambda f: [bun_bin("bun"), "--no-env-file", "--env-file=" + f, dump],
        api="bun --no-env-file --env-file=FILE", env_sensitive=True)
    add("python", "python", "reference", "python-dotenv 1.2.4",
        **_batch([python_bin(), "-I", py, "--lib", str(CACHE / "python" / "dotenv-1.2.4")]),
        api="dotenv_values(path) (interpolate=True)", env_sensitive=True)
    add("python-nointerp", "python", "configuration", "python-dotenv 1.2.4",
        **_batch([python_bin(), "-I", py, "--lib", str(CACHE / "python" / "dotenv-1.2.4"), "--config", "nointerp"]),
        api="dotenv_values(path, interpolate=False)")
    add("ruby", "ruby", "reference", "dotenv 3.2.0 (Ruby)",
        **_batch([tool("ruby"), "-I", ruby_lib("3.2.0"), rb]),
        api="Dotenv.parse(path) (commands recorded, never run)", env_sensitive=True)
    add("ruby-trusted", "ruby", "configuration", "dotenv 3.2.0 (Ruby)",
        **_batch([tool("ruby"), "-I", ruby_lib("3.2.0"), rb, "--config", "trusted"]),
        api="Dotenv.parse(path) (the fixture's audited commands run)", env_sensitive=True, trusted_only=True)
    add("dotenvnet", "dotenvnet", "reference", "dotenv.net 4.2.0",
        **_batch([dotnet_bin(), dn("DotenvNet")]), api="DotEnv.Read(new DotEnvOptions(envFilePaths: [path]))")
    add("dotenvnet-strict", "dotenvnet", "configuration", "dotenv.net 4.2.0",
        **_batch([dotnet_bin(), dn("DotenvNet"), "--config", "strict"]), api="DotEnv.Read(... .WithExceptions())")
    add("dotenvnet-extended", "dotenvnet", "configuration", "dotenv.net 4.2.0",
        **_batch([dotnet_bin(), dn("DotenvNet"), "--config", "extended"]),
        api="DotEnv.Read(... .WithExceptions().WithSupportExportSyntax().WithVariableExpansion())", env_sensitive=True)
    add("dotnetenv", "dotnetenv", "supplement", "DotNetEnv 3.2.0", run="process",
        cmd=[dotnet_bin(), dn("DotNetEnv")], api="Env.Load(path) (sets the process environment)", env_sensitive=True)
    add("java", "java", "reference", "dotenv-java 3.2.0",
        **_batch([tool("java"), "-cp", java_cp("3.2.0"), "Adapter"]),
        api="Dotenv.configure()...load().entries(DECLARED_IN_ENV_FILE)", env_sensitive=False)
    add("java-lenient", "java", "configuration", "dotenv-java 3.2.0",
        **_batch([tool("java"), "-cp", java_cp("3.2.0"), "Adapter", "--config", "lenient"]),
        api="Dotenv.configure().ignoreIfMalformed()...")
    # cross-version: one older, widely deployed release (or runtime) each
    add("node-builtin@24", "node-builtin", "cross-version", "Node.js 24.22.3", **_batch([N24, nb]), api="util.parseEnv(text)")
    add("node-builtin@22", "node-builtin", "cross-version", "Node.js 22.23.5", **_batch([N22, nb]), api="util.parseEnv(text)")
    add("node-envfile@24", "node-envfile", "cross-version", "Node.js 24.22.3", run="dump",
        cmd=lambda f: [N24, "--env-file=" + f, dump], api="node --env-file=FILE", env_sensitive=True)
    add("node-envfile@22", "node-envfile", "cross-version", "Node.js 22.23.5", run="dump",
        cmd=lambda f: [N22, "--env-file=" + f, dump], api="node --env-file=FILE", env_sensitive=True)
    add("node-dotenv@17", "node-dotenv", "cross-version", "dotenv 17.4.2",
        **_batch([N26, nd, "--lib", npm("node-dotenv/v17")]), api="dotenv.parse(text)")
    add("node-dotenv@16", "node-dotenv", "cross-version", "dotenv 16.6.1",
        **_batch([N26, nd, "--lib", npm("node-dotenv/v16")]), api="dotenv.parse(text)")
    add("bun@1.3", "bun", "cross-version", "Bun 1.3.14", run="dump",
        cmd=lambda f: [bun_bin("bun/v1.3"), "--no-env-file", "--env-file=" + f, dump],
        api="bun --no-env-file --env-file=FILE", env_sensitive=True)
    add("python@1.0", "python", "cross-version", "python-dotenv 1.0.1",
        **_batch([python_bin(), "-I", py, "--lib", str(CACHE / "python" / "dotenv-1.0.1")]),
        api="dotenv_values(path)", env_sensitive=True)
    add("ruby@2", "ruby", "cross-version", "dotenv 2.8.1 (Ruby)",
        **_batch([tool("ruby"), "-I", ruby_lib("2.8.1"), rb]), api="Dotenv.parse(path)", env_sensitive=True)
    add("dotenvnet@3", "dotenvnet", "cross-version", "dotenv.net 3.2.1",
        **_batch([dotnet_bin(), dn("DotenvNet3")]), api="DotEnv.Read(new DotEnvOptions(envFilePaths: [path]))")
    add("java@2", "java", "cross-version", "dotenv-java 2.3.2",
        **_batch([tool("java"), "-cp", java_cp("2.3.2"), "Adapter"]), api="entries(DECLARED_IN_ENV_FILE)")
    for name, t in T.items():
        if t["run"] in ("batch", "process"):
            t["cmd"] = list(t["cmd"]) + ["--target", name]
    return T


REFERENCE = ["bash", "node-builtin", "node-envfile", "node-dotenv", "bun", "python", "ruby", "dotenvnet",
             "dotnetenv", "java"]


def names(role=None):
    return [n for n, t in targets().items() if role is None or t["role"] == role]


# -- controlled environments ------------------------------------------------

# Variables the census deliberately supplies in the "conflict" mode: names no
# ordinary fixture assigns, which the environment fixtures assign or
# reference (fixtures/environment.py).
CONFLICT = {
    "CENSUS_PRESET": "from-environment",
    "CENSUS_REF": "env-ref-value",
    "CENSUS_EMPTY_ENV": "",
    "CENSUS_SPACES": "  env  spaced  ",
}


def base_environment(scratch):
    """The sanitized baseline: the few variables a runtime needs to start
    at all on this host, with fixed values where possible. Everything a
    target sees is recorded with its results."""
    home = os.path.join(scratch, "home")
    os.makedirs(home, exist_ok=True)
    tmp = os.path.join(scratch, "tmp")
    os.makedirs(tmp, exist_ok=True)
    if os.name == "nt":
        env = {"PATH": os.environ.get("SystemRoot", r"C:\Windows") + r"\System32",
               "USERPROFILE": home, "HOME": home, "TEMP": tmp, "TMP": tmp,
               "LANG": "C.UTF-8"}
        for k in ("SystemRoot", "SystemDrive", "windir", "ComSpec", "PATHEXT", "NUMBER_OF_PROCESSORS",
                  "PROCESSOR_ARCHITECTURE"):
            if k in os.environ:
                env[k] = os.environ[k]
        return env
    # HOME is a constant that names no directory: a runtime that needs a home
    # to start would fail visibly, and a value read from it (Ruby returns the
    # environment's value for a key the file assigns) is the same on every run.
    return {"PATH": "/usr/bin:/bin", "HOME": "/nonexistent/dotenv-census-home", "TMPDIR": tmp,
            "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8"}


def environment(mode, scratch):
    env = base_environment(scratch)
    if mode == "conflict":
        env.update(CONFLICT)
    return env


MODES = ("clean", "conflict")


def dump_json(obj, path):
    tmp = str(path) + ".tmp"
    with open(tmp, "w", encoding="utf-8", newline="\n") as f:
        json.dump(obj, f, ensure_ascii=True, indent=1, sort_keys=True)
        f.write("\n")
    os.replace(tmp, path)


def dump_results(obj, path):
    """A target's results: the header indented, then one compact line per
    fixture (small files, one diff line per changed observation)."""
    head = {k: v for k, v in obj.items() if k != "results"}
    lines = ["{"]
    for k in sorted(head):
        lines.append(" %s: %s," % (json.dumps(k), json.dumps(head[k], ensure_ascii=True, sort_keys=True)))
    lines.append(' "results": {')
    items = sorted(obj["results"].items())
    for i, (fid, r) in enumerate(items):
        lines.append("  %s: %s%s" % (json.dumps(fid), json.dumps(r, ensure_ascii=True, sort_keys=True,
                                                                  separators=(",", ":")),
                                     "," if i < len(items) - 1 else ""))
    lines.append(" }")
    lines.append("}")
    tmp = str(path) + ".tmp"
    with open(tmp, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    os.replace(tmp, path)


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)
