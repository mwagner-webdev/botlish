#!/usr/bin/env python3
"""census.py -- the harness of MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md.

Builds the probes (native/, programs/), runs every case in its own process
under a timeout, reads the fixture's "MTP" lines and classifies each
outcome. Evidence, not a test tier: a case's class says what happened, and
"expected" whether that is what the census predicted -- a failure the
census sets out to demonstrate (the worker's SDL video init, the deadlock)
is an expected FAILED-CORRECTNESS.

    python3 -I census.py --work DIR --out RESULTS --sdl-prefix PREFIX
        [--app Botlish.app] [--checkout REPO] [--exp EXPERIMENTAL_CHECKOUT]
        [--tclsh tclsh9.0] [--repeat N] [--only GROUP,...]

  --app        the packaged compiler (macOS): production executables are
               built by Botlish.app's own `botlish` (the system linker:
               the application's `auto` for a program that calls C)
  --checkout   this repository: its main.tcl builds the production
               executables when there is no --app, and a rustc-linked one
  --exp        a checkout with patches/main-thread-experiment.patch
               applied and native/ built: candidate A (main thread) and
               candidate B (dispatcher), selected per run by the
               environment
  --sdl-prefix an SDL3 install (lib/libSDL3.a, include/, lib/pkgconfig/
               sdl3.pc): the pinned release, static
  --repeat     timed repetitions of the timing cases (section 18)

Classes (section 19 of the census): EXECUTED-COCOA, EXECUTED-HEADLESS,
EXECUTED-THREAD, UNAVAILABLE-GUI, FAILED-CORRECTNESS, FAILED-BUILD,
NOT-TESTED. A graphical outcome is EXECUTED-COCOA only when SDL's current
video driver is "cocoa", the window has a Cocoa window, every SDL stage
ran on the process's main thread (pthread_main_np, never SDL's own
answer), frames were presented, the pushed quit was polled back and the
window, renderer and SDL were shut down.

Writes RESULTS/outcomes.json, RESULTS/summary.md and RESULTS/logs/; prints
"RESULT" lines (one per case) and the summary.
"""
import argparse
import ast
import json
import os
import platform
import re
import shutil
import signal
import statistics
import struct
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
APPLE = sys.platform == "darwin"
CLASSES = ["EXECUTED-COCOA", "EXECUTED-HEADLESS", "EXECUTED-THREAD", "UNAVAILABLE-GUI",
           "FAILED-CORRECTNESS", "FAILED-BUILD", "NOT-TESTED"]
# LC_MAIN stack sizes tried for the process's main thread (Apple ld's
# -stack_size): 64 MiB .. 2 GiB.
MAIN_STACK_SIZES = ["0x4000000", "0x10000000", "0x20000000", "0x40000000", "0x80000000"]
ENV_STRIP = ("BOTLISH_EXPERIMENT_", "BOTLISH_NATIVE_GC_STRESS", "BOTLISH_NATIVE_RESULT", "BOTLISH_NATIVE_RUNS",
             "SDL_VIDEODRIVER", "MTP_CAPTURE")


def log(*words):
    print(*words, flush=True)


def run(cmd, env=None, cwd=None, timeout=120, stdin=subprocess.DEVNULL):
    """Runs CMD in a session of its own: (status, signal, timed_out, wall_ms, stdout, stderr)."""
    base = {k: v for k, v in os.environ.items() if not k.startswith(ENV_STRIP)}
    base.update(env or {})
    started = time.monotonic()
    proc = subprocess.Popen([str(c) for c in cmd], env=base, cwd=cwd, stdin=stdin, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    timed_out = False
    try:
        out, err = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        os.killpg(proc.pid, signal.SIGKILL)
        out, err = proc.communicate()
    wall = (time.monotonic() - started) * 1000
    status = proc.returncode
    sig = -status if status is not None and status < 0 else 0
    return status, sig, timed_out, wall, out.decode("utf-8", "replace"), err.decode("utf-8", "replace")


def mtp(text):
    lines = []
    for line in text.splitlines():
        if line.startswith("MTP "):
            try:
                lines.append(json.loads(line[4:]))
            except json.JSONDecodeError:
                lines.append({"kind": "unparsed", "text": line})
    return lines


def value(stdout):
    """The Botlish program's printed value, as Python data (true/false -> True/False)."""
    text = stdout.strip().splitlines()[-1] if stdout.strip() else ""
    try:
        return ast.literal_eval(re.sub(r"\btrue\b", "True", re.sub(r"\bfalse\b", "False", text)))
    except (ValueError, SyntaxError):
        return text


def sh(cmd):
    try:
        return subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=60).stdout.strip()
    except subprocess.TimeoutExpired:
        return "(timed out)"


BIG_VALUES = 600
BIG_TEXT = "census-large-frame-string-"


def big_program(n=BIG_VALUES):
    """big.bot: N Ints and a String live across a recursive call -- a Botlish frame of several KiB, larger than a
    page, so Cranelift probes every page of it (codegen::stack_probes); the String is a root in every frame, made
    by an allocation at every level -- at the depth `big N` names (0: unbounded)."""
    lines = ["# big.bot -- generated by tools/census.py (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md, sections 8 and 12):",
             f"# {n} Ints and a String live across the recursive call: a frame larger than a page,",
             "# which Cranelift's stack probes walk page by page into the guard.",
             "import std::int", "import std::list", "import std::str", "",
             "fn big(n: int, s: str) -> int:", "    if n == 0:", "        return 0",
             "    held = std::str::concat(s, \"x\")"]
    lines += [f"    v{i} = n * {i + 1} + {i}" for i in range(n)]
    lines += ["    k = big(n - 1, s)", "    t0 = k + v0"]
    lines += [f"    t{i} = t{i - 1} + v{i}" for i in range(1, n)]
    lines += [f"    t{n - 1} + std::str::length(held)", "",
              "fn depth() -> int:",
              "    args = argv():",
              "        on InvalidArgumentEncoding:",
              '            ["", "0"]',
              "    text = std::list::at(args, 1):",
              "        on IndexNotFound:",
              '            "0"',
              "    std::int::from_string(text):",
              "        on InvalidIntegerText:",
              "            0", "",
              "d = depth()",
              "limit = if d == 0:", "    -1", "else:", "    d",
              f'big(limit, "{BIG_TEXT}")', ""]
    return "\n".join(lines)


def big_value(depth, n=BIG_VALUES):
    """big(depth, BIG_TEXT) = the sum over the levels m = 1 .. depth of every m * (i + 1) + i, and the held String's length."""
    return sum(m * (i + 1) + i for m in range(1, depth + 1) for i in range(n)) + depth * (len(BIG_TEXT) + 1)


class Census:
    def __init__(self, args):
        for name in ("app", "checkout", "exp"):
            if getattr(args, name):
                setattr(args, name, str(Path(getattr(args, name)).resolve()))
        self.args = args
        self.work = Path(args.work).resolve()
        self.out = Path(args.out).resolve()
        self.logs = self.out / "logs"
        self.captures = self.out / "captures"
        for d in (self.work, self.logs, self.captures):
            d.mkdir(parents=True, exist_ok=True)
        self.prefix = Path(args.sdl_prefix).resolve()
        self.records = []
        self.builds = {}
        self.facts = {}
        self.gui = None  # whether the C control made a Cocoa window on the main thread
        self.cc = "clang" if APPLE else "cc"
        self.cflags = ["-O2", "-g", "-I", str(self.prefix / "include")]
        if APPLE:
            self.cflags += ["-arch", "arm64", "-mmacosx-version-min=11.0"]
        self.frameworks, self.libraries = self.sdl_link_interface()

    # -- the environment ---------------------------------------------------------
    def environment(self):
        f = self.facts
        f["platform"] = platform.platform()
        f["uname"] = sh("uname -a")
        f["page_size"] = sh("getconf PAGESIZE")
        f["ulimit_s"] = sh("ulimit -s")
        f["ulimit_Hs"] = sh("ulimit -Hs")
        f["cc"] = sh(f"{self.cc} --version | head -n 1")
        f["rustc"] = sh("rustc --version")
        f["sdl3"] = {"commit": sh(f"cat '{self.prefix}/COMMIT' 2>/dev/null"),
                     "version": sh(f"sed -n 's/^Version: *//p' '{self.prefix}/lib/pkgconfig/sdl3.pc'"),
                     "archive_bytes": (self.prefix / "lib/libSDL3.a").stat().st_size,
                     "frameworks": self.frameworks, "libraries": self.libraries}
        if APPLE:
            f["sw_vers"] = sh("sw_vers")
            f["sdk"] = sh("xcrun --show-sdk-version")
            f["xcode"] = sh("xcode-select -p")
            f["launchctl_managername"] = sh("launchctl managername")
            f["window_server"] = sh("pgrep -lx WindowServer || echo none")
            f["loginwindow"] = sh("pgrep -lx loginwindow || echo none")
            f["console_user"] = sh("stat -f %Su /dev/console")
            f["user"] = sh("id -un")
            f["virtual_machine"] = sh("sysctl -n kern.hv_vmm_present")
            f["displays"] = sh("system_profiler SPDisplaysDataType 2>/dev/null | sed -n '1,40p'")
            f["sdl_video_hint"] = os.environ.get("SDL_VIDEODRIVER", "")
        log("== environment")
        for k, v in f.items():
            log(f"   {k}: {v}")

    def sdl_link_interface(self):
        """The frameworks and libraries SDL3's own metadata names (sdl3.pc), as link-plan-sdl3.sh reads them."""
        pc = (self.prefix / "lib/pkgconfig/sdl3.pc").read_text()
        words = []
        for key in ("Libs.private:", "Libs:"):
            for line in pc.splitlines():
                if line.startswith(key):
                    words += line[len(key):].split()
        frameworks, libraries, nxt = [], [], False
        for w in words:
            if nxt:
                frameworks.append(w)
                nxt = False
            elif w.startswith(("-Wl,-framework,", "-Wl,-weak_framework,")):
                frameworks.append(w.split(",")[-1])
            elif w in ("-framework", "-weak_framework"):
                nxt = True
            elif w.startswith("-l") and w != "-lSDL3":
                libraries.append(w[2:])
        if APPLE:
            # The fixture asks Foundation through the Objective-C runtime's C
            # interface (objc_getClass, objc_msgSend): libobjc, by name.
            frameworks += ["Foundation", "AppKit"]
            libraries += ["objc"]
        return list(dict.fromkeys(frameworks)), list(dict.fromkeys(libraries))

    def link_words(self):
        words = []
        for fw in self.frameworks:
            words += ["-framework", fw]
        words += ["-l" + l for l in self.libraries]
        if not APPLE:
            words += ["-lpthread"]
        return words

    # -- building ----------------------------------------------------------------
    def build(self, name, cmd, env=None, cwd=None, timeout=900):
        status, sig, timed_out, wall, out, err = run(cmd, env=env, cwd=cwd, timeout=timeout)
        ok = status == 0 and not timed_out
        self.builds[name] = {"ok": ok, "status": status, "ms": round(wall), "cmd": " ".join(map(str, cmd)),
                             "env": env or {}, "output": (out + err)[-4000:]}
        (self.logs / f"build-{name.replace('/', '-')}.log").write_text(" ".join(map(str, cmd)) + "\n" + out + err)
        log(f"   build {name}: {'ok' if ok else 'FAILED'} ({round(wall)} ms)")
        if not ok:
            log((out + err)[-3000:])
        return ok

    def native(self):
        log("== native fixtures and C controls")
        n = HERE / "native"
        objs = self.work / "obj"
        objs.mkdir(exist_ok=True)
        for src in ("mtprobe", "mtprobe_sdl", "mtdispatch"):
            self.build(f"cc-{src}", [self.cc, "-c", *self.cflags, "-Wall", n / f"{src}.c", "-o", objs / f"{src}.o"])
        ar = ["ar", "rcs"]
        self.build("libmtprobe.a", [*ar, self.work / "libmtprobe.a", objs / "mtprobe.o", objs / "mtprobe_sdl.o"])
        self.build("libmtdispatch.a", [*ar, self.work / "libmtdispatch.a", objs / "mtdispatch.o"])
        sdl = self.prefix / "lib/libSDL3.a"
        extra = []
        if APPLE:
            self.build("cc-appkit", [self.cc, "-c", *self.cflags, "-fno-objc-arc", n / "appkit.m", "-o", objs / "appkit.o"])
            extra = [objs / "appkit.o"]
        self.build("csdl", [self.cc, *self.cflags, "-o", self.work / "csdl", n / "csdl.c", *extra,
                            self.work / "libmtprobe.a", sdl, *self.link_words()])
        self.build("csdl_callbacks", [self.cc, *self.cflags, "-o", self.work / "csdl_callbacks", n / "csdl_callbacks.c",
                                      self.work / "libmtprobe.a", sdl, *self.link_words()])
        self.build("mainstack-default", [self.cc, *self.cflags, "-o", self.work / "mainstack-default", n / "mainstack.c"])
        if APPLE:
            for size in MAIN_STACK_SIZES:
                self.build(f"mainstack-{size}", [self.cc, *self.cflags, "-o", self.work / f"mainstack-{size}",
                                                 n / "mainstack.c", f"-Wl,-stack_size,{size}"])
            self.build("session", [self.cc, *self.cflags, "-o", self.work / "session", n / "session.c",
                                   "-framework", "ApplicationServices"])
        rust_link = ["-l", "framework=Foundation", "-l", "objc"] if APPLE else []
        self.build("identity-rust", ["rustc", "-O", "--edition=2024", n / "identity.rs", "-L", f"native={self.work}",
                                     "-l", "static=mtprobe", *rust_link, "-o", self.work / "identity-rust"])

    def stage(self, name, programs, dispatch=False):
        """An application directory: the programs, probe.bot (and mtd.bot) with this target's link lines."""
        d = self.work / name
        if d.exists():
            shutil.rmtree(d)
        (d / "native").mkdir(parents=True)
        shutil.copy(self.work / "libmtprobe.a", d / "native")
        shutil.copy(self.prefix / "lib/libSDL3.a", d / "native")
        link = ['extern c library "mtprobe" static at "native/libmtprobe.a"',
                'extern c library "SDL3" static at "native/libSDL3.a"']
        link += [f'extern c framework "{fw}"' for fw in self.frameworks]
        link += [f'extern c library "{l}"' for l in self.libraries]
        text = (HERE / "programs/probe.bot.in").read_text().replace("# @LINK@", "\n".join(link))
        (d / "probe.bot").write_text(text)
        if dispatch:
            shutil.copy(self.work / "libmtdispatch.a", d / "native")
            text = (HERE / "programs/mtd.bot.in").read_text().replace(
                "# @LINK@", 'extern c library "mtdispatch" static at "native/libmtdispatch.a"')
            (d / "mtd.bot").write_text(text)
        for p in programs:
            if p == "big":
                (d / "big.bot").write_text(big_program())
            else:
                shutil.copy(HERE / "programs" / f"{p}.bot", d)
        return d

    def compile(self, label, directory, program, compiler, env=None):
        """Builds DIRECTORY/PROGRAM.bot with COMPILER ("app", "checkout", "exp"): the executable's path."""
        env = dict(env or {})
        source = directory / f"{program}.bot"
        if compiler == "app":
            cmd = [Path(self.args.app) / "Contents/MacOS/botlish", "-warnings", "off", "-emit-native-executable", source]
        else:
            root = self.args.checkout if compiler == "checkout" else self.args.exp
            cmd = [self.args.tclsh, Path(root) / "main.tcl", "-warnings", "off", "-emit-native-executable", source]
            env.setdefault("BOTLISH_NATIVE_LINKER", "system")
        env["BOTLISH_NATIVE_LINK_LOG"] = str(self.logs / f"link-{label}-{program}.log")
        ok = self.build(f"{label}/{program}", cmd, env=env, cwd=self.work)
        exe = directory / program
        return exe if ok and exe.exists() else None

    def botlish(self):
        log("== Botlish executables")
        common = ["identity", "sdl", "depth", "kept", "co_overflow", "fault", "big"]
        self.exe = {}
        prod = self.stage("prod", common)
        compiler = "app" if self.args.app else "checkout"
        for p in common:
            self.exe[("prod", p)] = self.compile("prod", prod, p, compiler)
        if self.args.checkout:
            rustc = self.stage("prod-rustc", ["identity"])
            self.exe[("prod-rustc", "identity")] = self.compile("prod-rustc", rustc, "identity", "checkout",
                                                                {"BOTLISH_NATIVE_LINKER": "rustc"})
        if self.args.exp:
            exp = self.stage("exp", common + ["dispatch", "runonmain"], dispatch=True)
            for p in common + ["dispatch", "runonmain"]:
                self.exe[("exp", p)] = self.compile("exp", exp, p, "exp")
            if APPLE:
                self.big = self.main_stack_choice()
                if self.big:
                    big = self.stage("exp-big", ["identity", "sdl", "depth", "kept", "co_overflow", "big"])
                    for p in ["identity", "sdl", "depth", "kept", "co_overflow", "big"]:
                        self.exe[("exp-big", p)] = self.compile("exp-big", big, p, "exp",
                                                                {"BOTLISH_EXPERIMENT_MAIN_STACK": self.big})

    def main_stack_choice(self):
        """The LC_MAIN stack size the experiment links with (section 11): the worker's own 1 GiB when the kernel
        gives it with a confirmed guard, else the largest smaller size that does."""
        best = None
        for size in ["0x40000000", "0x20000000", "0x10000000", "0x4000000"]:
            exe = self.work / f"mainstack-{size}"
            if not exe.exists():
                continue
            status, sig, timed_out, wall, out, err = run([exe, "report"], timeout=30)
            lines = [l for l in mtp(err) if l.get("kind") == "mainstack"]
            if status == 0 and lines and lines[0]["guard_bytes"] > 0 and lines[0]["usable_bytes"] >= int(size, 16) // 2:
                best = size
                break
        log(f"   the main-thread stack size the experiment links with: {best}")
        return best

    # -- running and classifying ---------------------------------------------------
    def case(self, name, group, cmd, kind, env=None, timeout=60, expect=None, note="", repeat=1, capture=False):
        if cmd is None or cmd[0] is None:
            rec = {"name": name, "group": group, "kind": kind, "class": "FAILED-BUILD", "expected": False,
                   "facts": {}, "note": note or "the executable did not build"}
            self.records.append(rec)
            log(f"RESULT {name}: FAILED-BUILD")
            return rec
        env = dict(env or {})
        if capture and APPLE:
            env["MTP_CAPTURE"] = str(self.captures / f"{name}.png")
        runs = []
        for i in range(repeat):
            status, sig, timed_out, wall, out, err = run(cmd, env=env, timeout=timeout)
            runs.append({"status": status, "signal": sig, "timed_out": timed_out, "wall_ms": wall, "stdout": out,
                         "stderr": err, "mtp": mtp(err)})
            if i == 0:
                (self.logs / f"{name}.log").write_text(
                    f"$ {' '.join(f'{k}={v}' for k, v in env.items())} {' '.join(map(str, cmd))}\n"
                    f"status {status} signal {sig} timed_out {timed_out} wall {wall:.1f} ms\n"
                    f"--- stdout\n{out}\n--- stderr\n{err}\n")
        first = runs[0]
        rec = {"name": name, "group": group, "kind": kind, "cmd": " ".join(map(str, cmd)), "env": env,
               "status": first["status"], "signal": first["signal"], "timed_out": first["timed_out"],
               "wall_ms": round(first["wall_ms"], 1), "stdout_tail": first["stdout"][-400:],
               "stderr_tail": "\n".join(l for l in first["stderr"].splitlines() if not l.startswith("MTP "))[-800:],
               "note": note}
        cls, facts, expected = getattr(self, f"classify_{kind}")(first, expect or {}, name)
        rec.update({"class": cls, "facts": facts, "expected": expected})
        if capture and APPLE:
            rec["facts"]["capture"] = self.inspect_capture(self.captures / f"{name}.png", (expect or {}).get("color"))
        if repeat > 1:
            rec["timing"] = self.timing(runs)
        self.records.append(rec)
        log(f"RESULT {name}: {cls}{'' if expected else ' (UNEXPECTED)'} {json.dumps(facts, sort_keys=True)[:600]}")
        return rec

    def marks(self, r):
        return {l["stage"]: l for l in r["mtp"] if l.get("kind") == "mark"}

    def ended(self, r):
        if r["timed_out"]:
            return "timed out"
        if r["signal"]:
            return f"killed by signal {r['signal']} ({signal.Signals(r['signal']).name})"
        return None

    def classify_identity(self, r, expect, name):
        m = self.marks(r)
        entry = m.get("entry") or m.get("worker") or {}
        rt = [l for l in r["mtp"] if l.get("kind") == "runtime"]
        facts = {"status": r["status"], "pthread_main": entry.get("pthread_main"), "ns_main": entry.get("ns_main"),
                 "same_tid_as_main": entry.get("same_tid"), "threads": entry.get("threads"),
                 "stack_bytes": entry.get("stack_bytes"), "since_exec_us": entry.get("since_exec_us"),
                 "value": value(r["stdout"])}
        if rt:
            facts["runtime"] = rt[0]
        bad = self.ended(r)
        if bad or not entry:
            return "FAILED-CORRECTNESS", dict(facts, problem=bad or "no identity report"), bool(expect.get("fails"))
        ok = expect.get("main") is None or entry.get("pthread_main") == (1 if expect["main"] else 0)
        if APPLE and entry.get("ns_main", -1) != -1:
            # Foundation and libpthread must agree; a disagreement is a finding of its own.
            facts["foundation_agrees"] = entry["ns_main"] == entry["pthread_main"]
        return "EXECUTED-THREAD", facts, ok and not expect.get("fails")

    def graphical_facts(self, r):
        m = self.marks(r)
        sdl = [l for l in r["mtp"] if l.get("kind") == "sdl"]
        by = {l["stage"]: l for l in sdl}
        win = next((l for l in r["mtp"] if l.get("kind") == "window"), {})
        ren = next((l for l in r["mtp"] if l.get("kind") == "renderer"), {})
        res = next((l for l in r["mtp"] if l.get("kind") == "result"), {})
        drivers = [l["driver"] for l in sdl if l.get("driver")]
        threads = sorted({l.get("pthread_main") for l in r["mtp"] if l.get("kind") in ("mark", "sdl", "window", "renderer", "dispatch")
                          and l.get("pthread_main") is not None})
        facts = {"status": r["status"], "driver": drivers[-1] if drivers else None,
                 "init": by.get("after-init", {}).get("ok"), "error": by.get("after-init", {}).get("error"),
                 "sdl_is_main_before_init": by.get("before-init", {}).get("sdl_is_main"),
                 "sdl_is_main_after_init": by.get("after-init", {}).get("sdl_is_main"),
                 "pthread_main_seen": threads, "window": bool(win.get("id")), "cocoa_window": win.get("cocoa_window"),
                 "renderer": ren.get("name"), "destroyed": "after-destroy" in m, "quit": "after-quit" in m,
                 "threads_max": max([l.get("threads", 0) for l in r["mtp"] if isinstance(l.get("threads"), int)] or [0])}
        if res:
            facts.update({"presented": res["presented"], "quit_seen": res["quit_seen"], "events": res["events"]})
        v = value(r["stdout"])
        facts["value"] = v
        if isinstance(v, list) and len(v) == 4 and isinstance(v[3], list):
            # sdl.bot: [before, init, after, [window, [renderer, presented, in_coroutine, pushed, [events, quit]]]]
            outcome = v[3]
            if len(outcome) == 2 and isinstance(outcome[1], list) and len(outcome[1]) == 5:
                made, presented, in_co, pushed, ev = outcome[1]
                facts.update({"presented": presented, "presented_in_coroutine": in_co, "quit_seen": ev[1] == 1,
                              "events": ev[0], "value_window": outcome[0], "value_renderer": made})
            if "after-init" in by and v[1] != by["after-init"]["ok"]:
                facts["inconsistent"] = "the program's value and the fixture disagree about SDL_Init"
            if facts.get("value_window") is not None and facts["value_window"] != facts["window"]:
                facts["inconsistent"] = "the program's value and the fixture disagree about the window"
        cor = m.get("coroutine-body")
        if cor:
            sp = int(cor["sp"], 16)
            facts["coroutine_on_own_stack"] = not (int(cor["stack_low"], 16) <= sp < int(cor["stack_high"], 16))
            facts["coroutine_pthread_main"] = cor["pthread_main"]
        return facts

    def classify_graphical(self, r, expect, name):
        f = self.graphical_facts(r)
        bad = self.ended(r)
        if bad:
            return "FAILED-CORRECTNESS", dict(f, problem=bad), expect.get("class") == "FAILED-CORRECTNESS"
        if f["init"] is None:
            f["problem"] = f"the program ended before SDL_Init (status {r['status']})"
            return "FAILED-CORRECTNESS", f, expect.get("class") == "FAILED-CORRECTNESS"
        if f.get("inconsistent"):
            return "FAILED-CORRECTNESS", dict(f, problem=f["inconsistent"]), expect.get("class") == "FAILED-CORRECTNESS"
        complete = (f["init"] and f["window"] and f["renderer"] and (f.get("presented") or 0) > 0
                    and f.get("quit_seen") and f["destroyed"] and f["quit"])
        if complete:
            if f["driver"] == "cocoa" and f["cocoa_window"] and f["pthread_main_seen"] == [1]:
                cls = "EXECUTED-COCOA"
            elif f["driver"] in ("dummy", "offscreen"):
                cls = "EXECUTED-HEADLESS"
            else:
                cls = "FAILED-CORRECTNESS"
                f["problem"] = f"completed with driver {f['driver']} on threads {f['pthread_main_seen']}"
        else:
            f["missing"] = [k for k in ("init", "window", "renderer", "presented", "quit_seen", "destroyed", "quit") if not f.get(k)]
            if not f["init"] and self.gui is False and not expect.get("headless"):
                cls = "UNAVAILABLE-GUI"
            else:
                cls = "FAILED-CORRECTNESS"
        want = expect.get("class")
        return cls, f, (cls == want) if want else cls.startswith("EXECUTED")

    def classify_runtime(self, r, expect, name):
        err = "\n".join(l for l in r["stderr"].splitlines() if not l.startswith("MTP "))
        facts = {"status": r["status"], "signal": r["signal"], "value": value(r["stdout"]),
                 "native_limit_stack": "NATIVE LIMIT STACK" in err, "stderr": err[-300:]}
        rt = [l for l in r["mtp"] if l.get("kind") == "runtime"]
        if rt:
            facts["runtime"] = rt[0]
        bad = self.ended(r)
        if "value" in expect:
            ok = not bad and r["status"] == 0 and facts["value"] == expect["value"]
        elif expect.get("overflow"):
            ok = not bad and r["status"] == 1 and facts["native_limit_stack"]
        elif expect.get("fault"):
            ok = r["signal"] in (signal.SIGSEGV, signal.SIGBUS) and not facts["native_limit_stack"]
        else:
            ok = not bad and r["status"] == 0
        if expect.get("fails"):
            # A positive control: the defect must show.
            return ("FAILED-CORRECTNESS", dict(facts, problem=bad or "as the control intends"), not ok)
        if ok:
            return "EXECUTED-THREAD", facts, True
        return "FAILED-CORRECTNESS", dict(facts, problem=bad or "unexpected outcome"), False

    def classify_deadlock(self, r, expect, name):
        dead = next((l for l in r["mtp"] if l.get("kind") == "deadlock"), None)
        facts = {"status": r["status"], "deadlock_line": bool(dead), "timed_out": r["timed_out"],
                 "dispatch": [l for l in r["mtp"] if l.get("kind") == "dispatch"]}
        if dead and r["status"] == 124:
            return "FAILED-CORRECTNESS", dict(facts, problem="deadlock (the watchdog ended it)"), True
        return ("EXECUTED-THREAD" if r["status"] == 0 else "FAILED-CORRECTNESS"), facts, False

    def classify_runonmain(self, r, expect, name):
        line = next((l for l in r["mtp"] if l.get("kind") == "runonmain"), {})
        facts = {"status": r["status"], **line}
        f = self.graphical_facts(r)
        facts["driver"] = f["driver"]
        bad = self.ended(r)
        if bad or not line.get("ok"):
            return "FAILED-CORRECTNESS", dict(facts, problem=bad or "a request failed"), False
        if line["on_main"] != line["calls"]:
            return "FAILED-CORRECTNESS", dict(facts, problem="a callback ran off the main thread"), False
        return ("EXECUTED-COCOA" if f["driver"] == "cocoa" else "EXECUTED-HEADLESS"), facts, True

    def classify_dispatch(self, r, expect, name):
        f = self.graphical_facts(r)
        d = [l for l in r["mtp"] if l.get("kind") == "dispatch"]
        v = f["value"]
        facts = {"status": r["status"], "value": v, "requests": len(d),
                 "requests_on_main": sum(1 for l in d if l.get("pthread_main") == 1),
                 "callers_on_main": sum(1 for l in d if l.get("caller_pthread_main") == 1),
                 "driver": next((l.get("driver") for l in reversed(d) if l.get("driver")), None)}
        rt = next((l for l in d if l["what"] == "roundtrips"), None)
        if rt:
            facts["roundtrip_ns"] = rt["ns"] / 1000 if rt.get("rc") == 0 else None
        bad = self.ended(r)
        if bad:
            return "FAILED-CORRECTNESS", dict(facts, problem=bad), False
        if expect.get("refused"):
            ok = isinstance(v, list) and v[0] == 0 and v[1] is False
            return "EXECUTED-THREAD", facts, ok
        complete = isinstance(v, list) and v[0] == 1 and v[1] is True and isinstance(v[2], list) and len(v[2]) == 6 \
            and v[2][2] > 0 and v[2][4][1] == 1 and v[2][5] is True
        served = [l for l in d if l["what"] not in ("roundtrips",)]
        on_main = bool(served) and all(l.get("pthread_main") == 1 for l in served)
        if complete and on_main:
            if facts["driver"] == "cocoa":
                return "EXECUTED-COCOA", facts, not expect.get("headless")
            if facts["driver"] in ("dummy", "offscreen"):
                return "EXECUTED-HEADLESS", facts, bool(expect.get("headless"))
        if self.gui is False and APPLE and not expect.get("headless"):
            return "UNAVAILABLE-GUI", facts, False
        return "FAILED-CORRECTNESS", dict(facts, problem="incomplete"), False

    def classify_callbacks(self, r, expect, name):
        line = next((l for l in r["mtp"] if l.get("kind") == "callbacks"), {})
        lib = next((l for l in r["mtp"] if l.get("kind") == "botlish-library"), None)
        f = self.graphical_facts(r)
        facts = {"status": r["status"], **line, "driver": f["driver"], "renderer": f["renderer"]}
        if lib:
            facts["botlish_library"] = lib
        bad = self.ended(r)
        ok = not bad and r["status"] == 0 and line.get("result") == 1 and line.get("presented", 0) > 0 \
            and line.get("on_main") == line.get("calls")
        if not ok:
            if self.gui is False and APPLE and not expect.get("headless"):
                return "UNAVAILABLE-GUI", facts, False
            return "FAILED-CORRECTNESS", dict(facts, problem=bad or "incomplete"), False
        cls = "EXECUTED-COCOA" if f["driver"] == "cocoa" else "EXECUTED-HEADLESS"
        return cls, facts, cls == expect.get("class", cls)

    def classify_appkit(self, r, expect, name):
        line = next((l for l in r["mtp"] if l.get("kind") == "appkit"), {})
        facts = {"status": r["status"], "signal": r["signal"], **line}
        bad = self.ended(r)
        if bad:
            return "FAILED-CORRECTNESS", dict(facts, problem=bad), bool(expect.get("refused"))
        if line.get("made") == 1:
            return "EXECUTED-THREAD", facts, not expect.get("refused")
        return "FAILED-CORRECTNESS", dict(facts, problem="AppKit refused"), bool(expect.get("refused"))

    def classify_session(self, r, expect, name):
        line = next((l for l in r["mtp"] if l.get("kind") == "session"), {})
        return ("EXECUTED-THREAD" if line else "FAILED-CORRECTNESS"), {"status": r["status"], **line}, True

    def classify_mainstack(self, r, expect, name):
        facts = {"status": r["status"], "signal": r["signal"]}
        for l in r["mtp"]:
            facts.update({f"{l['kind']}.{k}": v for k, v in l.items() if k != "kind"})
        bad = self.ended(r)
        if expect.get("mode") == "overflow":
            ok = facts.get("mainstack-fault.in_guard") == (1 if expect.get("in_guard", True) else 0)
        elif expect.get("mode") == "touch":
            ok = "mainstack-touch.frames" in facts
        else:
            ok = r["status"] == 0 and "mainstack.usable_bytes" in facts
        if bad and expect.get("mode") != "overflow":
            return "FAILED-CORRECTNESS", dict(facts, problem=bad), False
        return ("EXECUTED-THREAD" if ok else "FAILED-CORRECTNESS"), facts, ok

    def classify_refusal(self, r, expect, name):
        text = r["stdout"] + r["stderr"]
        refused = r["status"] != 0 and all(w in text for w in expect.get("words", []))
        return ("EXECUTED-THREAD" if refused else "FAILED-CORRECTNESS"), {"status": r["status"], "output": text[-600:]}, refused

    # -- captures ------------------------------------------------------------------------
    def inspect_capture(self, png, color):
        """What the capture shows: its size, its center pixel and how much of it is the color the probe drew."""
        if not png.exists():
            return {"exists": False}
        bmp = png.with_suffix(".bmp")
        run(["sips", "-s", "format", "bmp", png, "--out", bmp], timeout=60)
        facts = {"exists": True, "png_bytes": png.stat().st_size}
        try:
            data = bmp.read_bytes()
            offset, = struct.unpack_from("<I", data, 10)
            width, height = struct.unpack_from("<ii", data, 18)
            bpp, = struct.unpack_from("<H", data, 28)
            step = bpp // 8
            row = (width * step + 3) & ~3
            flipped = height > 0
            height = abs(height)

            def px(x, y):
                yy = height - 1 - y if flipped else y
                o = offset + yy * row + x * step
                b, g, r_ = data[o], data[o + 1], data[o + 2]
                return r_, g, b

            facts.update({"width": width, "height": height, "center_rgb": px(width // 2, height // 2)})
            if color:
                near = total = 0
                for y in range(0, height, 4):
                    for x in range(0, width, 4):
                        total += 1
                        near += all(abs(a - b) <= 48 for a, b in zip(px(x, y), color))
                facts["fraction_drawn_color"] = round(near / max(total, 1), 3)
        except Exception as e:  # a capture is evidence, not a requirement
            facts["bmp_error"] = str(e)
        return facts

    # -- timing ----------------------------------------------------------------------------
    def timing(self, runs):
        def series(values):
            values = [v for v in values if v is not None]
            if not values:
                return None
            return {"n": len(values), "median": round(statistics.median(values), 3), "min": round(min(values), 3),
                    "max": round(max(values), 3), "stdev": round(statistics.pstdev(values), 3)}

        walls, entry, init, frame, shutdown, threads = [], [], [], [], [], []
        for r in runs:
            walls.append(r["wall_ms"])
            m = {l["stage"]: l for l in r["mtp"] if l.get("kind") == "mark"}
            s = {l["stage"]: l for l in r["mtp"] if l.get("kind") == "sdl"}
            e = m.get("entry") or m.get("callback-init")
            if e and e.get("since_exec_us", -1) >= 0:
                entry.append(e["since_exec_us"] / 1000)
            if "before-init" in s and "after-init" in s:
                init.append((s["after-init"]["t_ns"] - s["before-init"]["t_ns"]) / 1e6)
            if "after-renderer" in s and "after-present" in m:
                frame.append((m["after-present"]["t_ns"] - s["after-renderer"]["t_ns"]) / 1e6 / 30)
            if "after-events" in m and "after-quit" in m:
                shutdown.append((m["after-quit"]["t_ns"] - m["after-events"]["t_ns"]) / 1e6)
            threads.append(max([l.get("threads", 0) for l in r["mtp"] if isinstance(l.get("threads"), int)] or [0]))
        return {"wall_ms": series(walls), "entry_since_exec_ms": series(entry), "sdl_init_ms": series(init),
                "frame_ms": series(frame), "shutdown_ms": series(shutdown), "threads_max": series(threads)}

    # -- the cases ---------------------------------------------------------------------------
    def cases(self):
        w, e = self.work, self.exe
        only = set(filter(None, self.args.only.split(",")))
        want = lambda g: not only or g in only
        exp = lambda p: e.get(("exp", p))
        prod = lambda p: e.get(("prod", p))
        big = lambda p: e.get(("exp-big", p))
        main = {"BOTLISH_EXPERIMENT_THREAD": "main", "BOTLISH_EXPERIMENT_REPORT": "1"}
        worker = {"BOTLISH_EXPERIMENT_REPORT": "1"}
        dispatch = {"BOTLISH_EXPERIMENT_THREAD": "dispatch", "BOTLISH_EXPERIMENT_REPORT": "1"}
        gc = {"BOTLISH_NATIVE_GC_STRESS": "1"}
        dummy = {"SDL_VIDEODRIVER": "dummy"}
        # Linux has no Cocoa: the "cocoa" cases run headless there (a dry run of the harness, never evidence).
        gui_env = {} if APPLE else dummy

        if want("env") and APPLE:
            self.case("env-session", "env", [w / "session"], "session")

        if want("identity"):
            self.case("id-c-main", "identity", [w / "csdl", "identity"], "identity", expect={"main": True})
            self.case("id-c-worker", "identity", [w / "csdl", "identity-worker"], "identity", expect={"main": False})
            self.case("id-rust-main", "identity", [w / "identity-rust"], "identity", expect={"main": True},
                      note="the first report is Rust's main thread, the second a std thread's")
            self.case("id-botlish-aot-prod", "identity", [prod("identity")], "identity", expect={"main": False},
                      note="the production executable (system linker)")
            self.case("id-botlish-aot-rustc", "identity", [e.get(("prod-rustc", "identity"))], "identity", expect={"main": False},
                      note="the production runtime, rustc-linked")
            if self.args.app:
                self.case("id-botlish-linked-run", "identity",
                          [Path(self.args.app) / "Contents/MacOS/botlish", "-warnings", "off", "-backend", "cranelift",
                           self.work / "prod/identity.bot"], "identity", expect={"main": False},
                          note="main.tcl -backend cranelift: a program that calls C runs as a linked executable (driver protocol)")
            elif self.args.checkout:
                self.case("id-botlish-linked-run", "identity",
                          [self.args.tclsh, Path(self.args.checkout) / "main.tcl", "-warnings", "off", "-backend",
                           "cranelift", self.work / "prod/identity.bot"], "identity", expect={"main": False},
                          note="main.tcl -backend cranelift: a program that calls C runs as a linked executable (driver protocol)")
            if self.args.exp:
                self.case("id-botlish-exp-worker", "identity", [exp("identity")], "identity", env=worker, expect={"main": False})
                self.case("id-botlish-exp-main", "identity", [exp("identity")], "identity", env=main,
                          expect={"main": True, "fails": not APPLE},
                          note="Linux: the guard refuses the main thread's stack (no confirmed guard)" if not APPLE else "")
                self.case("id-botlish-exp-dispatch", "identity", [exp("identity")], "identity", env=dispatch, expect={"main": False})

        if want("stack"):
            self.case("stack-main-default", "stack", [w / "mainstack-default", "report"], "mainstack")
            self.case("stack-main-default-overflow", "stack", [w / "mainstack-default", "overflow"], "mainstack",
                      expect={"mode": "overflow", "in_guard": APPLE},
                      note="" if APPLE else "glibc reports no guard for the main thread: the fault is below the stack, not in a confirmed guard")
            if APPLE:
                for size in MAIN_STACK_SIZES:
                    exe = w / f"mainstack-{size}"
                    self.case(f"stack-main-{size}", "stack", [exe if exe.exists() else None, "report"], "mainstack")
                    self.case(f"stack-main-{size}-touch", "stack", [exe if exe.exists() else None, "touch"], "mainstack",
                              expect={"mode": "touch"}, timeout=120)
                    self.case(f"stack-main-{size}-overflow", "stack", [exe if exe.exists() else None, "overflow"], "mainstack",
                              expect={"mode": "overflow"}, timeout=120)

        if want("c-graphical"):
            gui = self.case("c-main-cocoa", "c-graphical", [w / "csdl", "main"], "graphical", capture=True, env=gui_env,
                            expect={"color": (255, 128, 0)} if APPLE else {"class": "EXECUTED-HEADLESS"}, timeout=60)
            self.gui = gui["class"] == "EXECUTED-COCOA"
            self.facts["gui_available"] = self.gui
            self.case("c-main-headless", "c-graphical", [w / "csdl", "main"], "graphical", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True})
            self.case("c-worker-cocoa", "c-graphical", [w / "csdl", "worker"], "graphical",
                      expect={"class": "FAILED-CORRECTNESS" if APPLE else "UNAVAILABLE-GUI"},
                      note="today's Botlish model in C: SDL video on a worker the main thread joins")
            self.case("c-worker-headless", "c-graphical", [w / "csdl", "worker"], "graphical", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True})
            if APPLE:
                self.case("c-appkit-main", "c-graphical", [w / "csdl", "appkit-main"], "appkit")
                self.case("c-appkit-worker", "c-graphical", [w / "csdl", "appkit-worker"], "appkit", expect={"refused": True})

        if want("botlish-baseline"):
            self.case("bl-worker-cocoa", "botlish-baseline", [prod("sdl")], "graphical",
                      expect={"class": "FAILED-CORRECTNESS"} if APPLE else {"class": "UNAVAILABLE-GUI"},
                      note="the production runtime: Botlish on its worker")
            self.case("bl-worker-cocoa-hint", "botlish-baseline", [prod("sdl")], "graphical", env={"SDL_VIDEODRIVER": "cocoa"},
                      expect={"class": "FAILED-CORRECTNESS"} if APPLE else {"class": "UNAVAILABLE-GUI"},
                      note="SDL_VIDEODRIVER=cocoa: the Cocoa driver asked for by name")
            self.case("bl-worker-headless", "botlish-baseline", [prod("sdl")], "graphical", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True})
            self.case("bl-worker-headless-gc", "botlish-baseline", [prod("sdl")], "graphical", env={**dummy, **gc},
                      expect={"class": "EXECUTED-HEADLESS", "headless": True})

        if want("candidate-a") and self.args.exp:
            cocoa = {"class": "EXECUTED-COCOA", "color": (255, 0, 255)} if APPLE else {"class": "FAILED-CORRECTNESS"}
            self.case("a-main-cocoa", "candidate-a", [exp("sdl")], "graphical", env=main, capture=True, expect=cocoa)
            self.case("a-main-cocoa-gc", "candidate-a", [exp("sdl")], "graphical", env={**main, **gc}, expect=cocoa, timeout=180)
            self.case("a-main-headless", "candidate-a", [exp("sdl")], "graphical", env={**main, **dummy},
                      expect={"class": "EXECUTED-HEADLESS" if APPLE else "FAILED-CORRECTNESS", "headless": True})
            self.case("a-worker-cocoa", "candidate-a", [exp("sdl")], "graphical", env=worker,
                      expect={"class": "FAILED-CORRECTNESS"} if APPLE else {"class": "UNAVAILABLE-GUI"},
                      note="the experimental build in the production model")
            if big("sdl"):
                self.case("a-main-big-cocoa", "candidate-a", [big("sdl")], "graphical", env=main, expect=cocoa,
                          note=f"linked with -stack_size {self.big}")
            # Runtime safety on each thread (sections 8, 9, 11-14).
            depths = {"down": [10000, 100000, 1000000], "keep": [10000, 100000], "wide": [10000, 100000],
                      "rec": [10000, 100000]}
            expected = {"down": lambda n: n, "keep": lambda n: 2 * n, "wide": lambda n: 0, "rec": lambda n: n}
            for label, env, exe in (("worker", worker, exp), ("main", main, exp), ("main-big", main, big)):
                if label == "main-big" and not big("depth"):
                    continue
                # Linux: the guard refuses the main thread (glibc reports no guard): every main-thread run ends at startup.
                refused = {"fails": True} if not APPLE and label.startswith("main") else {}
                for shape, ns in depths.items():
                    for n in ns:
                        self.case(f"a-{label}-depth-{shape}-{n}", "candidate-a", [exe("depth"), shape, str(n)], "runtime",
                                  env=env, expect={"value": expected[shape](n), **refused}, timeout=120)
                    self.case(f"a-{label}-overflow-{shape}", "candidate-a", [exe("depth"), shape, "0"], "runtime",
                              env=env, expect={"overflow": True, **refused}, timeout=180)
                self.case(f"a-{label}-keep-gc", "candidate-a", [exe("depth"), "keep", "3000"], "runtime",
                          env={**env, **gc}, expect={"value": 6000, **refused}, timeout=300)
                self.case(f"a-{label}-kept", "candidate-a", [exe("kept")], "runtime", env=env,
                          expect={"value": [[0, [1, 4, -1]], [4, 5, 6, 7, -1], [110, 34, 0, 0, 3]], **refused})
                self.case(f"a-{label}-kept-gc", "candidate-a", [exe("kept")], "runtime", env={**env, **gc},
                          expect={"value": [[0, [1, 4, -1]], [4, 5, 6, 7, -1], [110, 34, 0, 0, 3]], **refused}, timeout=180)
                self.case(f"a-{label}-co-overflow", "candidate-a", [exe("co_overflow")], "runtime", env=env,
                          expect={"overflow": True, **refused}, timeout=180)
                if label != "main-big":
                    self.case(f"a-{label}-fault", "candidate-a", [exe("fault")], "runtime", env=env, expect={"fault": True, **refused})
                # Large frames: finite, under GC stress, and exhausted. The worker's overflow runs on an 8 MiB worker
                # (BOTLISH_NATIVE_STACK_BYTES) so that it is the main thread's size and ends in seconds.
                self.case(f"a-{label}-bigframe-100", "candidate-a", [exe("big"), "100"], "runtime", env=env,
                          expect={"value": big_value(100), **refused}, timeout=120)
                self.case(f"a-{label}-bigframe-gc", "candidate-a", [exe("big"), "8"], "runtime", env={**env, **gc},
                          expect={"value": big_value(8), **refused}, timeout=600)
                small = {"BOTLISH_NATIVE_STACK_BYTES": str(8 << 20)} if label == "worker" else {}
                self.case(f"a-{label}-bigframe-overflow", "candidate-a", [exe("big"), "0"], "runtime",
                          env={**env, **small}, expect={"overflow": True, **refused}, timeout=300)

        if want("candidate-b") and self.args.exp:
            self.case("b-dispatch-cocoa", "candidate-b", [exp("dispatch")], "dispatch", env={**dispatch, **gui_env}, capture=False,
                      expect={"headless": not APPLE}, timeout=120)
            self.case("b-dispatch-headless", "candidate-b", [exp("dispatch")], "dispatch", env={**dispatch, **dummy},
                      expect={"headless": True}, timeout=120)
            self.case("b-dispatch-refused", "candidate-b", [exp("dispatch")], "dispatch", env=worker,
                      expect={"refused": True}, note="no main thread serves requests: the production model")
            self.case("b-runonmain-deadlock", "candidate-b", [exp("runonmain")], "deadlock", env={**dispatch, **gui_env}, timeout=30,
                      note="SDL_RunOnMainThread(wait) while the main thread serves the dispatcher, not SDL's queue")
            self.case("b-c-join-runonmain", "candidate-b", [w / "csdl", "join-runonmain"], "deadlock", env=gui_env, timeout=30,
                      note="aot::run's shape in C: the main thread in join(), the worker in SDL_RunOnMainThread(wait)")
            self.case("b-c-pump-runonmain", "candidate-b", [w / "csdl", "pump-runonmain"], "runonmain", timeout=60,
                      env={} if APPLE else dummy)

        if want("candidate-c"):
            self.case("c-callbacks-cocoa", "candidate-c", [w / "csdl_callbacks"], "callbacks",
                      env={} if APPLE else dummy, expect={"class": "EXECUTED-COCOA" if APPLE else "EXECUTED-HEADLESS"})
            self.case("c-callbacks-headless", "candidate-c", [w / "csdl_callbacks"], "callbacks", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True})
            root = self.args.exp or self.args.checkout
            if root:
                lib = self.work / "lib"
                lib.mkdir(exist_ok=True)
                (lib / "mtplib.bot").write_text("exported c fn step(n: int) -> int:\n    n + 1\n")
                self.case("c-library-macos" if APPLE else "c-library-linux", "candidate-c",
                          [self.args.tclsh, Path(root) / "main.tcl", "-warnings", "off", "-emit-native-library", "mtplib",
                           "-out", lib / "out", lib / "mtplib.bot"], "refusal" if APPLE else "runtime",
                          expect={"words": ["NATIVE UNSUPPORTED library", "Linux glibc"]} if APPLE else {}, timeout=300,
                          note="native libraries are Linux glibc's (codegen::library::SUPPORTED)")

        if want("controls"):
            self.case("pc-nopump", "controls", [w / "csdl", "nopump"], "graphical", env={} if APPLE else dummy,
                      expect={"class": "UNAVAILABLE-GUI" if (APPLE and self.gui is False) else "FAILED-CORRECTNESS"},
                      note="the pushed quit is never polled: must not be reported processed")
            self.case("pc-nodestroy", "controls", [w / "csdl", "nodestroy"], "graphical", env={} if APPLE else dummy,
                      expect={"class": "UNAVAILABLE-GUI" if (APPLE and self.gui is False) else "FAILED-CORRECTNESS"},
                      note="no destroy and no SDL_Quit: the cleanup check must notice")
            self.case("pc-baddriver", "controls", [w / "csdl", "main"], "graphical", env={"SDL_VIDEODRIVER": "nonexistent"},
                      expect={"class": "FAILED-CORRECTNESS", "headless": True}, note="SDL_Init must fail: never a window")
            self.case("pc-dummy-not-cocoa", "controls", [w / "csdl", "main"], "graphical", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True},
                      note="a dummy-driver run must never be classified EXECUTED-COCOA")
            if self.args.exp:
                self.case("pc-main-noguard-overflow", "controls", [exp("depth"), "down", "0"], "runtime",
                          env={**main, "BOTLISH_EXPERIMENT_NO_GUARD": "1"}, expect={"overflow": True, "fails": True},
                          timeout=120, note="no guard on the main thread: the overflow is the raw fault, not the line")
                self.case("pc-main-noguard-co-overflow", "controls", [exp("co_overflow")], "runtime",
                          env={**main, "BOTLISH_EXPERIMENT_NO_GUARD": "1"}, expect={"overflow": True, "fails": True},
                          timeout=120)
            self.oracle_selftest()

        if want("timing"):
            n = self.args.repeat
            self.case("t-id-prod-worker", "timing", [prod("identity")], "identity", expect={"main": False}, repeat=n)
            if self.args.exp:
                self.case("t-id-exp-main", "timing", [exp("identity")], "identity", env=main,
                          expect={"main": True, "fails": not APPLE}, repeat=n)
                self.case("t-id-exp-dispatch", "timing", [exp("identity")], "identity", env=dispatch,
                          expect={"main": False}, repeat=n)
                self.case("t-a-main-sdl", "timing", [exp("sdl")], "graphical", env=main if APPLE else {**main, **dummy},
                          expect={"class": ("EXECUTED-COCOA" if APPLE else "FAILED-CORRECTNESS")}, repeat=n)
                self.case("t-a-main-sdl-headless", "timing", [exp("sdl")], "graphical", env={**main, **dummy},
                          expect={"class": "EXECUTED-HEADLESS" if APPLE else "FAILED-CORRECTNESS", "headless": True}, repeat=n)
                self.case("t-a-worker-sdl-headless", "timing", [exp("sdl")], "graphical", env={**worker, **dummy},
                          expect={"class": "EXECUTED-HEADLESS", "headless": True}, repeat=n)
                self.case("t-b-dispatch", "timing", [exp("dispatch")], "dispatch", env=dispatch if APPLE else {**dispatch, **dummy},
                          expect={"headless": not APPLE}, repeat=n, timeout=120)
                self.case("t-a-main-kept-gc", "timing", [exp("kept")], "runtime", env={**main, **gc},
                          expect={"value": [[0, [1, 4, -1]], [4, 5, 6, 7, -1], [110, 34, 0, 0, 3]], "fails": not APPLE},
                          repeat=n, timeout=180)
                self.case("t-a-worker-kept-gc", "timing", [exp("kept")], "runtime", env={**worker, **gc},
                          expect={"value": [[0, [1, 4, -1]], [4, 5, 6, 7, -1], [110, 34, 0, 0, 3]]}, repeat=n, timeout=180)
            self.case("t-c-main", "timing", [w / "csdl", "main"], "graphical", env={} if APPLE else dummy,
                      expect={"class": "EXECUTED-COCOA" if APPLE else "EXECUTED-HEADLESS"}, repeat=n)
            self.case("t-c-callbacks", "timing", [w / "csdl_callbacks"], "callbacks", env={} if APPLE else dummy,
                      expect={"class": "EXECUTED-COCOA" if APPLE else "EXECUTED-HEADLESS"}, repeat=n)

    def oracle_selftest(self):
        """Synthetic records the classifier must not accept (section 25): a dummy-driver run claiming Cocoa,
        a value that contradicts the fixture, a lifecycle on the worker."""
        def synthetic(lines, stdout="", status=0):
            return {"status": status, "signal": 0, "timed_out": False, "wall_ms": 1, "stdout": stdout,
                    "stderr": "\n".join("MTP " + json.dumps(l) for l in lines), "mtp": lines}
        base = [{"kind": "sdl", "stage": "before-init", "ok": True, "sdl_is_main": True, "pthread_main": 1, "driver": None},
                {"kind": "sdl", "stage": "after-init", "ok": True, "sdl_is_main": True, "pthread_main": 1, "driver": "cocoa"},
                {"kind": "window", "id": 1, "flags": 0, "cocoa_window": True, "pthread_main": 1},
                {"kind": "renderer", "name": "metal", "pthread_main": 1},
                {"kind": "mark", "stage": "after-destroy", "pthread_main": 1},
                {"kind": "mark", "stage": "after-quit", "pthread_main": 1},
                {"kind": "result", "presented": 30, "quit_seen": True, "events": 3}]
        checks = []
        good = synthetic(base)
        checks.append(("complete Cocoa record", self.classify_graphical(good, {}, "selftest")[0], "EXECUTED-COCOA"))
        dummy = [dict(l, driver="dummy") if l.get("driver") else l for l in base]
        dummy = [dict(l, cocoa_window=False) if l["kind"] == "window" else l for l in dummy]
        checks.append(("dummy driver claimed as Cocoa", self.classify_graphical(synthetic(dummy), {}, "selftest")[0], "EXECUTED-HEADLESS"))
        worker = [dict(l, pthread_main=0) for l in base]
        checks.append(("Cocoa driver off the main thread", self.classify_graphical(synthetic(worker), {}, "selftest")[0], "FAILED-CORRECTNESS"))
        nowindow = [dict(l, id=0) if l["kind"] == "window" else l for l in base if l["kind"] != "result"]
        lying = "[true, true, true, [true, [true, 30, 3, true, [5, 1]]]]"
        checks.append(("a value claiming a window the fixture did not see",
                       self.classify_graphical(synthetic(nowindow, lying), {}, "selftest")[0], "FAILED-CORRECTNESS"))
        noquit = [dict(l, quit_seen=False) if l["kind"] == "result" else l for l in base]
        checks.append(("the quit never polled", self.classify_graphical(synthetic(noquit), {}, "selftest")[0], "FAILED-CORRECTNESS"))
        for label, got, want in checks:
            ok = got == want
            self.records.append({"name": f"oracle: {label}", "group": "controls", "kind": "oracle", "class": got,
                                 "expected": ok, "facts": {"want": want}, "note": "classifier self-test"})
            log(f"RESULT oracle: {label}: {got}{'' if ok else ' (UNEXPECTED, wanted ' + want + ')'}")

    # -- reporting ---------------------------------------------------------------------------
    def report(self):
        (self.out / "outcomes.json").write_text(json.dumps(
            {"facts": self.facts, "builds": self.builds, "records": self.records}, indent=1, default=str))
        lines = ["# MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md: outcomes", "",
                 f"Host: {self.facts.get('platform')}; GUI available to the C control: {self.facts.get('gui_available')}", "",
                 "| case | group | class | as predicted | facts |", "|---|---|---|---|---|"]
        for r in self.records:
            facts = {k: v for k, v in r.get("facts", {}).items() if k not in ("stderr", "value", "output", "dispatch")}
            lines.append(f"| {r['name']} | {r['group']} | {r['class']} | {'yes' if r.get('expected') else '**no**'} | "
                         f"`{json.dumps(facts, sort_keys=True, default=str)[:300]}` |")
        timed = [r for r in self.records if r.get("timing")]
        if timed:
            lines += ["", "## Timing (median [min, max] of the repetitions)", "",
                      "| case | wall ms | entry since exec ms | SDL init ms | frame ms | shutdown ms | threads |",
                      "|---|---|---|---|---|---|---|"]
            for r in timed:
                t = r["timing"]
                cell = lambda s: "-" if not s else f"{s['median']} [{s['min']}, {s['max']}]"
                lines.append(f"| {r['name']} | {cell(t['wall_ms'])} | {cell(t['entry_since_exec_ms'])} | {cell(t['sdl_init_ms'])} | "
                             f"{cell(t['frame_ms'])} | {cell(t['shutdown_ms'])} | {cell(t['threads_max'])} |")
        sizes = {k: v for k, v in ((f"{a}/{p}", x.stat().st_size) for (a, p), x in getattr(self, "exe", {}).items() if x)}
        lines += ["", "## Executable sizes (bytes)", "", "| executable | bytes |", "|---|---|"]
        lines += [f"| {k} | {v} |" for k, v in sorted(sizes.items())]
        cases = [r for r in self.records if r["kind"] != "oracle"]
        counts = {c: sum(1 for r in cases if r["class"] == c) for c in CLASSES}
        unexpected = [r["name"] for r in self.records if not r.get("expected")]
        lines += ["", "## Counts (cases; the oracle self-tests are rows above)", "", " ".join(f"{c}: {n}" for c, n in counts.items()), "",
                  f"Not as predicted ({len(unexpected)}): {', '.join(unexpected) or 'none'}"]
        (self.out / "summary.md").write_text("\n".join(lines) + "\n")
        log("\n".join(lines))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--work", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--sdl-prefix", required=True)
    ap.add_argument("--app")
    ap.add_argument("--checkout")
    ap.add_argument("--exp")
    ap.add_argument("--tclsh", default="tclsh9.0")
    ap.add_argument("--repeat", type=int, default=10)
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    c = Census(args)
    c.environment()
    c.native()
    c.botlish()
    c.cases()
    c.report()


if __name__ == "__main__":
    main()
