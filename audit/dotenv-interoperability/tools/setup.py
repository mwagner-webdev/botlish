"""Installs every pinned reference implementation into the census cache
(common.CACHE: $DOTENV_CENSUS_HOME, else ~/.cache/botlish/dotenv-census;
%LOCALAPPDATA%\\botlish\\dotenv-census on Windows). Nothing is installed into
the repository.

  python3 -I tools/setup.py install [COMPONENT...]   node npm python ruby java dotnet
  python3 -I tools/setup.py check-latest             the pins against the registries
  python3 -I tools/setup.py paths                    where everything is

Every artifact is verified before use: the Node runtimes and the dotenv-java
jars against versions.json's SHA-256, npm packages by `npm ci` against
package-lock.json's integrity hashes, python-dotenv by pip's
--require-hashes, the Ruby gems by Bundler's frozen install against
Gemfile.lock's CHECKSUMS, NuGet packages by restore in locked mode against
packages.lock.json's content hashes. Package install scripts never run
(npm ci --ignore-scripts; Bun's binary is its platform package's file).
"""

import hashlib
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common  # noqa: E402

C = common.CACHE
O = common.ORACLES
NPM_DIRS = ["node-dotenv", "node-dotenv/v16", "node-dotenv/v17", "bun", "bun/v1.3"]
PY = [("1.2.4", "requirements.txt"), ("1.0.1", "requirements-1.0.1.txt")]
RUBY = [("3.2.0", "."), ("2.8.1", "v2")]
JARS = ["3.2.0", "2.3.2"]
DOTNET = ["DotenvNet", "DotNetEnv", "DotenvNet3"]


def say(*a):
    print("[setup]", *a, flush=True)


def fetch(url, dest, digest, algo="sha256"):
    if os.path.exists(dest) and hashlib.new(algo, Path(dest).read_bytes()).hexdigest() == digest:
        return dest
    say("download", url)
    tmp = dest + ".part"
    req = urllib.request.Request(url, headers={"User-Agent": "dotenv-census-setup"})
    with urllib.request.urlopen(req, timeout=300) as r, open(tmp, "wb") as f:
        shutil.copyfileobj(r, f)
    got = hashlib.new(algo, Path(tmp).read_bytes()).hexdigest()
    if got != digest:
        os.remove(tmp)
        raise SystemExit("%s: %s %s, pinned %s" % (url, algo, got, digest))
    os.replace(tmp, dest)
    return dest


def run(cmd, **kw):
    say("$", " ".join(str(c) for c in cmd))
    subprocess.run([str(c) for c in cmd], check=True, **kw)


def extract(archive, dest):
    """Extract with the archive's single top-level directory stripped."""
    tmp = tempfile.mkdtemp(dir=str(C))
    if archive.endswith(".zip"):
        with zipfile.ZipFile(archive) as z:
            z.extractall(tmp)
    else:
        with tarfile.open(archive) as t:
            t.extractall(tmp, filter="tar")
    tops = os.listdir(tmp)
    src = os.path.join(tmp, tops[0]) if len(tops) == 1 else tmp
    if os.path.exists(dest):
        shutil.rmtree(dest)
    shutil.move(src, dest)
    shutil.rmtree(tmp, ignore_errors=True)


def install_node():
    host = common.HOST
    for ver, files in common.versions()["node"].items():
        dest = C / ("node-" + ver)
        if Path(common.node_bin(ver)).exists():
            continue
        f = files[host]
        dl = C / "dl"
        dl.mkdir(parents=True, exist_ok=True)
        arch = fetch("https://nodejs.org/dist/v%s/%s" % (ver, f["file"]), str(dl / f["file"]), f["sha256"])
        extract(arch, str(dest))
        say("node", ver, "->", dest)


def npm_bin():
    root = Path(common.node_bin("26.13.1")).parent
    return root / ("npm.cmd" if os.name == "nt" else "npm")


def install_npm():
    env = dict(os.environ)
    env["PATH"] = str(Path(common.node_bin("26.13.1")).parent) + os.pathsep + env.get("PATH", "")
    for d in NPM_DIRS:
        dest = C / "npm" / d
        dest.mkdir(parents=True, exist_ok=True)
        lock = (O / d / "package-lock.json").read_bytes()
        stamp = dest / ".lock-installed"
        if stamp.exists() and stamp.read_bytes() == lock:
            continue
        for name in ("package.json", "package-lock.json"):
            shutil.copy(O / d / name, dest / name)
        run([npm_bin(), "ci", "--ignore-scripts", "--no-audit", "--no-fund"], cwd=str(dest), env=env,
            shell=(os.name == "nt"))
        stamp.write_bytes(lock)
    for d in ("bun", "bun/v1.3"):
        b = common.bun_bin(d)
        if not Path(b).exists():
            raise SystemExit("Bun binary missing after npm ci: " + b)
        if os.name != "nt":
            os.chmod(b, 0o755)


def install_python():
    for ver, req in PY:
        dest = C / "python" / ("dotenv-" + ver)
        if (dest / "dotenv").exists():
            continue
        run([common.python_bin(), "-m", "pip", "install", "--quiet", "--disable-pip-version-check",
             "--require-hashes", "--no-deps", "--target", dest, "-r", O / "python" / req])


def install_ruby():
    bundle = common.tool("bundle")
    for ver, d in RUBY:
        dest = C / "ruby" / ("dotenv-" + ver)
        if Path(common.ruby_lib(ver)).exists():
            continue
        env = dict(os.environ, BUNDLE_GEMFILE=str(O / "ruby" / d / "Gemfile"), BUNDLE_PATH=str(dest),
                   BUNDLE_FROZEN="true", BUNDLE_DISABLE_SHARED_GEMS="true")
        run([bundle, "install", "--quiet"], env=env, shell=(os.name == "nt"))


def install_java():
    pins = common.versions()["maven"]
    javac = common.tool("javac")
    for ver in JARS:
        p = pins["io.github.cdimascio:dotenv-java:" + ver]
        jar = C / "java" / ("dotenv-java-%s.jar" % ver)
        jar.parent.mkdir(parents=True, exist_ok=True)
        fetch(p["url"], str(jar), p["sha256"])
        out = C / "java" / "build" / ver
        if out.exists():
            shutil.rmtree(out)
        run([javac, "-encoding", "UTF-8", "-d", out, "-cp", jar, O / "java" / "Adapter.java"])


def install_dotnet():
    v = common.versions()["dotnet_sdk"]
    want = v["version"]
    dotnet = common.dotnet_bin()
    try:
        have = subprocess.run([dotnet, "--version"], capture_output=True, text=True, cwd=str(O / "dotnet")).stdout.strip()
    except OSError:
        have = ""
    if have != want:
        if common.HOST != "linux-x64":
            raise SystemExit(".NET SDK %s required (found %r): install it (CI: actions/setup-dotnet)" % (want, have))
        dl = C / "dl"
        dl.mkdir(parents=True, exist_ok=True)
        f = v["linux-x64"]
        arch = fetch(f["url"], str(dl / os.path.basename(f["url"])), f["sha512"], "sha512")
        dest = C / ("dotnet-" + want)
        dest.mkdir(parents=True, exist_ok=True)
        with tarfile.open(arch) as t:
            t.extractall(dest, filter="tar")
        dotnet = common.dotnet_bin()
    env = dict(os.environ, DOTNET_CLI_TELEMETRY_OPTOUT="1", DOTNET_NOLOGO="1",
               DOTNET_SKIP_FIRST_TIME_EXPERIENCE="1", NUGET_PACKAGES=str(C / "nuget"))
    for proj in DOTNET:
        out = C / "build" / "dotnet" / proj
        run([dotnet, "build", "-c", "Release", "-p:RestoreLockedMode=true", O / "dotnet" / proj / (proj + ".Adapter.csproj"),
             "-o", out, "--artifacts-path", C / "build" / "dotnet" / ("artifacts-" + proj), "-nologo", "-v", "quiet"],
            env=env, cwd=str(O / "dotnet"))


STEPS = {"node": install_node, "npm": install_npm, "python": install_python, "ruby": install_ruby,
         "java": install_java, "dotnet": install_dotnet}


def check_latest():
    def get(u):
        req = urllib.request.Request(u, headers={"User-Agent": "dotenv-census-setup"})
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.read()
    rows = []
    pins = common.versions()["latest_at_census"]

    def row(name, latest):
        pinned = pins.get(name, "?").split()[0]
        rows.append((name, pinned, latest, "" if latest == pinned else "NEWER RELEASE"))
    try:
        row("npm:dotenv", json.loads(get("https://registry.npmjs.org/dotenv"))["dist-tags"]["latest"])
        row("npm:bun", json.loads(get("https://registry.npmjs.org/bun"))["dist-tags"]["latest"])
        row("pypi:python-dotenv", json.loads(get("https://pypi.org/pypi/python-dotenv/json"))["info"]["version"])
        row("rubygems:dotenv", json.loads(get("https://rubygems.org/api/v1/versions/dotenv/latest.json"))["version"])
        for pkg in ("dotenv.net", "DotNetEnv"):
            vs = json.loads(get("https://api.nuget.org/v3-flatcontainer/%s/index.json" % pkg.lower()))["versions"]
            row("nuget:" + pkg, [x for x in vs if "-" not in x][-1])
        import re
        meta = get("https://repo1.maven.org/maven2/io/github/cdimascio/dotenv-java/maven-metadata.xml").decode()
        row("maven:io.github.cdimascio:dotenv-java", re.search(r"<release>(.*?)</release>", meta).group(1))
        idx = json.loads(get("https://nodejs.org/dist/index.json"))
        row("node", next(x["version"][1:] for x in idx if x["lts"]))
    except Exception as e:  # report, never fail the census on a registry outage
        rows.append(("registry", "-", "-", "unreachable: %s" % e))
    for r in rows:
        print("%-42s pinned %-10s latest %-10s %s" % r)


def main():
    a = sys.argv[1:] or ["install"]
    cmd, rest = a[0], a[1:]
    C.mkdir(parents=True, exist_ok=True)
    if cmd == "install":
        for name in rest or list(STEPS):
            STEPS[name]()
        say("ready:", C)
    elif cmd == "check-latest":
        check_latest()
    elif cmd == "paths":
        for n, t in common.targets().items():
            print(n, t.get("cmd") if not callable(t.get("cmd")) else "(per fixture)")
    else:
        raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
