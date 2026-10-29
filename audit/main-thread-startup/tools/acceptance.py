#!/usr/bin/env python3
"""acceptance.py -- the graphical acceptance of MAIN-THREAD-STARTUP-MILESTONE-1.md.

The census's candidate-A cases (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md,
audit/macos-graphical-main-thread/) run on the production startup policy
instead of the disposable experimental runtime: every executable is built by
the compiler itself -- `botlish -native-startup main-thread
-emit-native-executable` -- and nothing selects the thread when it runs. The
census's fixtures (native/mtprobe.c, native/mtprobe_sdl.c, the C controls),
its Botlish programs (programs/*.bot, probe.bot.in) and its classifier
(tools/census.py: EXECUTED-COCOA only when SDL's driver is cocoa, the window
has a Cocoa window, every SDL stage ran on the process's main thread, frames
were presented, the pushed quit was polled back and everything was shut
down) are reused unchanged; the cases that needed the experiment's switches
(BOTLISH_EXPERIMENT_THREAD, _NO_GUARD, _REPORT, _MAIN_STACK) are replaced by
production executables of each policy and the runtime's own startup report
(BOTLISH_NATIVE_STARTUP_REPORT: `startup`, `thread`, `stack` lines).

    python3 -I acceptance.py --work DIR --out RESULTS --sdl-prefix PREFIX
        [--app Botlish.app] [--checkout REPO] [--tclsh tclsh9.0]
        [--repeat N] [--only GROUP,...]

  --app        the packaged compiler (macOS): the `worker` and `main`
               executables are built by Botlish.app's own `botlish` (the
               system linker, the application's `auto` for a program that
               calls C), from a work directory outside any checkout
  --checkout   this repository: its main.tcl builds the `rustc` executables
               (BOTLISH_NATIVE_LINKER=rustc, main-thread) and the
               `checkout` ones (the system linker, main-thread); and, with no
               --app, the worker and main ones too
  --sdl-prefix an SDL3 install (lib/libSDL3.a, include/, lib/pkgconfig/
               sdl3.pc): the pinned release, static
  --repeat     timed repetitions of the timing cases

Groups: env, identity, lc-main, report, runtime, semantics, graphical,
controls, timing. On Linux (a dry run of the plumbing, never evidence about
macOS) the main-thread executables are refused at build time -- predicted
FAILED-BUILD with NATIVE UNSUPPORTED startup -- and the graphical cases run
with SDL's dummy driver.

Writes RESULTS/outcomes.json, RESULTS/summary.md, RESULTS/logs/ and
RESULTS/captures/; prints a RESULT line per case and the summary. Exits 1
when a case is not as predicted (a gate, unlike the census).
"""
import argparse
import importlib.util
import json
import os
import re
import signal
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
CENSUS = HERE.parent.parent / "macos-graphical-main-thread" / "tools" / "census.py"
_spec = importlib.util.spec_from_file_location("census", CENSUS)
census = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(census)

APPLE = census.APPLE
log = census.log
run = census.run
KEPT = [[0, [1, 4, -1]], [4, 5, 6, 7, -1], [110, 34, 0, 0, 3]]
# LC_MAIN's stack size of a main-thread executable (codegen::aot's
# MAIN_STACK_BYTES): Apple ld's largest on arm64.
MAIN_STACK = 512 << 20
REFUSAL = "NATIVE UNSUPPORTED startup"
# The production executables: (label, compiler, linker, startup policy).
#   worker   Botlish.app (or the checkout), its default policy
#   main     Botlish.app (or the checkout), -native-startup main-thread
#   rustc    the checkout's rustc linker, -native-startup main-thread
#   checkout the checkout's system linker, -native-startup main-thread
COMMON = ["identity", "sdl", "depth", "kept", "co_overflow", "fault", "big", "errors", "sleep"]
LINKERS = {"rustc": ["identity", "sdl", "errors", "depth", "kept"], "checkout": ["identity", "sdl", "errors"]}


class Acceptance(census.Census):
    def __init__(self, args):
        args.exp = None
        super().__init__(args)
        self.exe = {}

    # -- building ------------------------------------------------------------------
    def build(self, name, cmd, env=None, cwd=None, timeout=900):
        """census.py's build, without the census's Rust identity control (native/identity.rs): no case here reads
        it, and the run through Botlish.app has no rustc on PATH (that is the point of it)."""
        if name == "identity-rust":
            log("   build identity-rust: not built (the acceptance needs no Rust)")
            return False
        return super().build(name, cmd, env=env, cwd=cwd, timeout=timeout)

    def build_exe(self, label, directory, program, compiler, startup, env=None):
        """DIRECTORY/PROGRAM.bot built by COMPILER ("app" or "checkout") with startup policy STARTUP (None: no
        option, the default): the executable's path, or None."""
        env = dict(env or {})
        source = directory / f"{program}.bot"
        option = ["-native-startup", startup] if startup else []
        if compiler == "app":
            cmd = [Path(self.args.app) / "Contents/MacOS/botlish", "-warnings", "off", *option,
                   "-emit-native-executable", source]
        else:
            cmd = [self.args.tclsh, Path(self.args.checkout) / "main.tcl", "-warnings", "off", *option,
                   "-emit-native-executable", source]
            env.setdefault("BOTLISH_NATIVE_LINKER", "system")
        env["BOTLISH_NATIVE_LINK_LOG"] = str(self.logs / f"link-{label}-{program}.log")
        ok = self.build(f"{label}/{program}", cmd, env=env, cwd=self.work)
        exe = directory / program
        return exe if ok and exe.exists() else None

    def botlish(self):
        log("== Botlish executables (production: the startup policy of each)")
        primary = "app" if self.args.app else "checkout"
        for label, startup in (("worker", None), ("main", "main-thread")):
            d = self.stage(label, COMMON)
            for p in COMMON:
                self.exe[(label, p)] = self.build_exe(label, d, p, primary, startup)
        if self.args.checkout:
            for label, programs in LINKERS.items():
                d = self.stage(label, programs)
                env = {"BOTLISH_NATIVE_LINKER": "rustc"} if label == "rustc" else {}
                for p in programs:
                    self.exe[(label, p)] = self.build_exe(label, d, p, "checkout", "main-thread", env)

    def case(self, name, group, cmd, kind, env=None, timeout=60, expect=None, note="", repeat=1, capture=False,
             signal_after=None, build=None):
        """census.py's case, with one requirement more: a captured Cocoa window (macOS) shows what the program
        drew -- its center pixel within 48 of each channel of EXPECT's color, and at least half the sampled
        pixels so -- or the case is not as predicted (the census recorded the pixels; the acceptance requires
        them)."""
        rec = super().case(name, group, cmd, kind, env=env, timeout=timeout, expect=expect, note=note, repeat=repeat,
                           capture=capture, signal_after=signal_after, build=build)
        color = (expect or {}).get("color")
        if capture and APPLE and color and rec.get("class") == "EXECUTED-COCOA":
            shot = rec.get("facts", {}).get("capture", {})
            center = shot.get("center_rgb")
            drawn = shot.get("fraction_drawn_color") or 0
            ok = bool(shot.get("exists")) and center is not None and all(abs(a - b) <= 48 for a, b in zip(center, color)) \
                and drawn >= 0.5
            rec["facts"]["capture_matches"] = ok
            if not ok:
                rec["expected"] = False
                log(f"RESULT {name}: the capture does not show the program's color {color}: {shot} (UNEXPECTED)")
        return rec

    # -- classifying what census.py does not -----------------------------------------
    def classify_lcmain(self, r, expect, name):
        """LC_MAIN's stacksize, as `otool -l` reads the executable."""
        sizes = re.findall(r"cmd LC_MAIN\s.*?stacksize (\d+)", r["stdout"], re.S)
        facts = {"status": r["status"], "stacksize": int(sizes[0]) if sizes else None}
        ok = r["status"] == 0 and facts["stacksize"] == expect["stacksize"]
        return ("EXECUTED-THREAD" if ok else "FAILED-CORRECTNESS"), facts, ok

    def classify_report(self, r, expect, name):
        """The startup report (BOTLISH_NATIVE_STARTUP_REPORT): the policy, the thread and the stack it names, and
        that the Vm's part is EXPECT's other executable's."""
        facts = {"status": r["status"]}
        text = Path(expect["file"]).read_text() if Path(expect["file"]).exists() else ""
        for key, pattern in (("startup", r"^startup (\S+)$"), ("thread", r"^thread (\S+)$")):
            m = re.search(pattern, text, re.M)
            facts[key] = m.group(1) if m else None
        m = re.search(r"^stack usable (\d+) guard (\d+)$", text, re.M)
        if m:
            facts["usable"], facts["guard"] = int(m.group(1)), int(m.group(2))
        vm = "\n".join(l for l in text.splitlines() if not re.match(r"^(startup|thread|stack) ", l))
        facts["vm_lines"] = len(vm.splitlines())
        problems = [k for k in ("startup", "thread") if k in expect and facts.get(k) != expect[k]]
        if "usable" in expect and facts.get("usable") != expect["usable"]:
            problems.append("usable")
        if "min_usable" in expect and (facts.get("usable") or 0) < expect["min_usable"]:
            problems.append("usable")
        if expect.get("guard") and not facts.get("guard"):
            problems.append("guard")
        if "same_vm_as" in expect:
            other = Path(expect["same_vm_as"])
            theirs = "\n".join(l for l in (other.read_text() if other.exists() else "").splitlines()
                               if not re.match(r"^(startup|thread|stack) ", l))
            facts["same_vm"] = bool(vm) and vm == theirs
            if not facts["same_vm"]:
                problems.append("vm")
        if r["status"] != 0 or problems:
            return "FAILED-CORRECTNESS", dict(facts, problem=", ".join(problems) or f"status {r['status']}"), False
        return "EXECUTED-THREAD", facts, True

    def classify_dylibs(self, r, expect, name):
        """The executable's dynamic libraries (`otool -L`): none of SDL3's."""
        libs = [l.strip().split(" ")[0] for l in r["stdout"].splitlines()[1:] if l.strip()]
        facts = {"status": r["status"], "libraries": libs, "sdl3": [l for l in libs if "SDL" in l]}
        ok = r["status"] == 0 and not facts["sdl3"] and libs
        return ("EXECUTED-THREAD" if ok else "FAILED-CORRECTNESS"), facts, bool(ok)

    # -- the cases -------------------------------------------------------------------
    def cases(self):
        w, e = self.work, self.exe
        only = set(filter(None, self.args.only.split(",")))
        want = lambda g: not only or g in only
        worker = lambda p: e.get(("worker", p))
        main = lambda p: e.get(("main", p))
        rustc = lambda p: e.get(("rustc", p))
        checkout = lambda p: e.get(("checkout", p))
        gc = {"BOTLISH_NATIVE_GC_STRESS": "1"}
        dummy = {"SDL_VIDEODRIVER": "dummy"}
        # Linux has no Cocoa: the "cocoa" cases run headless there (a dry run of the harness, never evidence), and
        # every main-thread executable is refused when it is built.
        gui_env = {} if APPLE else dummy
        refused = {} if APPLE else {"build_refused": REFUSAL}
        mains = [("main", main, "main"), ("rustc", rustc, "rustc"), ("checkout", checkout, "checkout")]
        cocoa = {"class": "EXECUTED-COCOA", "color": (255, 0, 255)} if APPLE else {"class": "EXECUTED-HEADLESS", "headless": True}
        # A host tool's command on EXE, or the census's "not built" command when it was not built.
        tool = lambda exe, *words: [*words, exe] if exe else [None]

        if want("env") and APPLE:
            self.case("env-session", "env", [w / "session"], "session")

        if want("identity"):
            # The C controls first: what a main thread and a worker look like to the fixture on this host.
            self.case("id-c-main", "identity", [w / "csdl", "identity"], "identity", expect={"main": True})
            self.case("id-c-worker", "identity", [w / "csdl", "identity-worker"], "identity", expect={"main": False})
            self.case("id-worker", "identity", [worker("identity")], "identity", expect={"main": False},
                      note="the default policy: Botlish on its worker")
            for label, exe, build in mains:
                if build != "main" and not self.args.checkout:
                    continue
                self.case(f"id-{label}", "identity", [exe("identity")], "identity", expect={"main": True, **refused},
                          build=f"{build}/identity", note=f"-native-startup main-thread ({label})")
            app = Path(self.args.app) / "Contents/MacOS/botlish" if self.args.app else None
            compiler = [app] if app else [self.args.tclsh, Path(self.args.checkout) / "main.tcl"]
            self.case("id-linked-run", "identity", [*compiler, "-warnings", "off", "-backend", "cranelift",
                                                    self.work / "worker/identity.bot"], "identity", expect={"main": False},
                      note="-backend cranelift: a program that calls C runs as a linked executable, on its worker")
            if APPLE:
                self.case("macho-main", "identity", tool(main("sdl"), "file", "-b"), "process", build="main/sdl",
                          expect={"status": 0, "stdout": r"^Mach-O 64-bit executable arm64$"})
                for label, exe, build in mains:
                    if build != "main" and not self.args.checkout:
                        continue
                    if exe("sdl"):
                        self.case(f"deps-{label}-sdl", "identity", tool(exe("sdl"), "otool", "-L"), "dylibs",
                                  note="the static SDL3: no SDL3 dylib among the executable's dynamic libraries")

        if want("lc-main") and APPLE:
            self.case("lc-main-worker", "lc-main", tool(worker("identity"), "otool", "-l"), "lcmain", expect={"stacksize": 0},
                      build="worker/identity")
            for label, exe, build in mains:
                if build != "main" and not self.args.checkout:
                    continue
                self.case(f"lc-main-{label}", "lc-main", tool(exe("identity"), "otool", "-l"), "lcmain",
                          expect={"stacksize": MAIN_STACK}, build=f"{build}/identity")

        if want("report"):
            wr = self.work / "report-worker.txt"
            self.case("report-worker", "report", [worker("errors"), "value"], "report",
                      env={"BOTLISH_NATIVE_STARTUP_REPORT": str(wr)},
                      expect={"file": str(wr), "startup": "worker", "thread": "worker", "min_usable": 1 << 30, "guard": True})
            for label, exe, build in mains:
                if build != "main" and not self.args.checkout:
                    continue
                mr = self.work / f"report-{label}.txt"
                self.case(f"report-{label}", "report", [exe("errors"), "value"], "report",
                          env={"BOTLISH_NATIVE_STARTUP_REPORT": str(mr)}, build=f"{build}/errors",
                          expect={"file": str(mr), "startup": "main-thread", "thread": "main", "usable": MAIN_STACK,
                                  "guard": True, "same_vm_as": str(wr), **refused})
            mg = self.work / "report-main-gc.txt"
            self.case("report-main-gc", "report", [main("errors"), "value"], "report", build="main/errors",
                      env={"BOTLISH_NATIVE_STARTUP_REPORT": str(mg), **gc},
                      expect={"file": str(mg), "startup": "main-thread", "thread": "main", "same_vm_as": str(wr), **refused})

        if want("runtime"):
            # The census's runtime probes (sections 11-14) on each policy: the finite recursions, every
            # exhaustion, a fault that is no overflow, GC stress, kept coroutines, large frames.
            depths = {"down": [10000, 100000, 1000000], "keep": [10000, 100000], "wide": [10000, 100000],
                      "rec": [10000, 100000]}
            expected = {"down": lambda n: n, "keep": lambda n: 2 * n, "wide": lambda n: 0, "rec": lambda n: n}
            for label, exe in (("worker", worker), ("main", main)):
                no = refused if label == "main" else {}
                b = lambda p: f"{label}/{p}"
                for shape, ns in depths.items():
                    for n in ns:
                        self.case(f"rt-{label}-depth-{shape}-{n}", "runtime", [exe("depth"), shape, str(n)], "runtime",
                                  expect={"value": expected[shape](n), **no}, build=b("depth"), timeout=120)
                    self.case(f"rt-{label}-overflow-{shape}", "runtime", [exe("depth"), shape, "0"], "runtime",
                              expect={"overflow": True, **no}, build=b("depth"), timeout=300)
                self.case(f"rt-{label}-keep-gc", "runtime", [exe("depth"), "keep", "3000"], "runtime", env=gc,
                          expect={"value": 6000, **no}, build=b("depth"), timeout=300)
                self.case(f"rt-{label}-kept", "runtime", [exe("kept")], "runtime", expect={"value": KEPT, **no},
                          build=b("kept"))
                self.case(f"rt-{label}-kept-gc", "runtime", [exe("kept")], "runtime", env=gc,
                          expect={"value": KEPT, **no}, build=b("kept"), timeout=180)
                self.case(f"rt-{label}-co-overflow", "runtime", [exe("co_overflow")], "runtime",
                          expect={"overflow": True, **no}, build=b("co_overflow"), timeout=180)
                self.case(f"rt-{label}-fault", "runtime", [exe("fault")], "runtime", expect={"fault": True, **no},
                          build=b("fault"))
                self.case(f"rt-{label}-bigframe-100", "runtime", [exe("big"), "100"], "runtime",
                          expect={"value": census.big_value(100), **no}, build=b("big"), timeout=120)
                self.case(f"rt-{label}-bigframe-gc", "runtime", [exe("big"), "8"], "runtime", env=gc,
                          expect={"value": census.big_value(8), **no}, build=b("big"), timeout=600)
                # The worker's large-frame exhaustion on an 8 MiB worker, to end in seconds; the main thread's
                # stack is LC_MAIN's, which the environment cannot resize.
                small = {"BOTLISH_NATIVE_STACK_BYTES": str(8 << 20)} if label == "worker" else {}
                self.case(f"rt-{label}-bigframe-overflow", "runtime", [exe("big"), "0"], "runtime", env=small,
                          expect={"overflow": True, **no}, build=b("big"), timeout=600)
            if self.args.checkout:
                self.case("rt-rustc-depth-down-1000000", "runtime", [rustc("depth"), "down", "1000000"], "runtime",
                          expect={"value": 1000000, **refused}, build="rustc/depth", timeout=120)
                self.case("rt-rustc-overflow-down", "runtime", [rustc("depth"), "down", "0"], "runtime",
                          expect={"overflow": True, **refused}, build="rustc/depth", timeout=300)
                self.case("rt-rustc-kept-gc", "runtime", [rustc("kept")], "runtime", env=gc,
                          expect={"value": KEPT, **refused}, build="rustc/kept", timeout=180)

        if want("semantics"):
            # How a program leaves the process (census section 21), on each policy and linker: the lines, files
            # and statuses must be the worker's. A runtime panic (BOTLISH_NATIVE_RUNTIME_FAULT=panic, the
            # runtime's test-only fault) is NATIVE BUG, status 1, on every thread.
            runs = [("worker", worker), ("main", main)]
            if self.args.checkout:
                runs += [("rustc", rustc), ("checkout", checkout)]
            for label, exe in runs:
                no = refused if label != "worker" else {}
                b = f"{label}/errors"
                self.case(f"s-{label}-declared", "semantics", [exe("errors"), "declared"], "process", build=b,
                          expect={"status": 0, "stdout": r"^1008$", **no})
                self.case(f"s-{label}-runtime", "semantics", [exe("errors"), "runtime"], "process", build=b,
                          expect={"status": 1, "stdout": r"^$",
                                  "stderr": r"\+: expected int, got \[true\] \(CORE SEMANTIC TYPE\)", **no})
                result = self.work / f"result-{label}.txt"
                self.case(f"s-{label}-protocol", "semantics", [exe("errors"), "runtime"], "process", build=b,
                          env={"BOTLISH_NATIVE_RESULT": str(result)},
                          expect={"status": 0, "stdout": r"^$", "file": str(result),
                                  "file_re": r"^error \{CORE SEMANTIC TYPE\} \{\+: expected int, got \[true\]\}$", **no})
                runs3 = self.work / f"runs-{label}.txt"
                self.case(f"s-{label}-protocol-runs", "semantics", [exe("errors"), "declared"], "process", build=b,
                          env={"BOTLISH_NATIVE_RESULT": str(runs3), "BOTLISH_NATIVE_RUNS": "3"},
                          expect={"status": 0, "file": str(runs3),
                                  "file_re": r"^times \d+ \d+ \d+\ntiming \d+ \d+ 3 \d+\nvalue \{int 1008\}$", **no})
                self.case(f"s-{label}-startup-report-io", "semantics", [exe("errors"), "value"], "process", build=b,
                          env={"BOTLISH_NATIVE_STARTUP_REPORT": "/nonexistent/startup-report"},
                          expect={"status": 2, "stderr": r"NATIVE IO", **no})
                self.case(f"s-{label}-panic", "semantics", [exe("errors"), "value"], "process", build=b,
                          env={"BOTLISH_NATIVE_RUNTIME_FAULT": "panic"},
                          expect={"status": 1, "stdout": r"^$", "stderr": r"native executable panicked \(NATIVE BUG\)\Z", **no})
                panicked = self.work / f"panic-{label}.txt"
                self.case(f"s-{label}-panic-protocol", "semantics", [exe("errors"), "value"], "process", build=b,
                          env={"BOTLISH_NATIVE_RUNTIME_FAULT": "panic", "BOTLISH_NATIVE_RESULT": str(panicked)},
                          expect={"status": 1, "stdout": r"^$", "stderr": r"native executable panicked \(NATIVE BUG\)\Z", **no})
            for label, exe in (("worker", worker), ("main", main)):
                no = refused if label != "worker" else {}
                self.case(f"s-{label}-overflow-line", "semantics", [exe("depth"), "down", "0"], "process",
                          build=f"{label}/depth", timeout=300,
                          expect={"status": 1, "stderr": r"^error \{NATIVE LIMIT STACK\} \{native stack exhausted: too many nested calls\}$", **no})
                # No SDL: the runtime leaves SIGTERM and SIGINT (Ctrl+C) at their defaults on every thread.
                for sig in (signal.SIGTERM, signal.SIGINT):
                    self.case(f"s-{label}-{sig.name.lower()}-c-call", "semantics", [exe("sleep")], "signal",
                              build=f"{label}/sleep", signal_after=(1.0, sig), timeout=30,
                              expect={"signal": int(sig), **no}, note="a program in a 5 s C call, signalled after 1 s")
            if APPLE:
                # SIGTERM while SDL runs: SDL's own handler (SDL_INIT_EVENTS) turns it into SDL_EVENT_QUIT; the
                # program then ends normally.
                self.case("s-main-sigterm-sdl", "semantics", [main("sdl")], "graphical", signal_after=(1.0, signal.SIGTERM),
                          expect={"class": "EXECUTED-COCOA"}, note="SIGTERM one second in: SDL's handler makes it a quit event")

        if want("graphical"):
            # The C control: whether this session can make a Cocoa window at all.
            gui = self.case("c-main-cocoa", "graphical", [w / "csdl", "main"], "graphical", capture=True, env=gui_env,
                            expect={"color": (255, 128, 0)} if APPLE else {"class": "EXECUTED-HEADLESS"}, timeout=60)
            self.gui = gui["class"] == "EXECUTED-COCOA"
            self.facts["gui_available"] = self.gui
            self.case("g-main-cocoa", "graphical", [main("sdl")], "graphical", env=gui_env, capture=True,
                      expect={**cocoa, **refused}, build="main/sdl",
                      note="-native-startup main-thread through Botlish.app: Cocoa, Metal, 30 frames + 3 from a kept coroutine")
            self.case("g-main-cocoa-gc", "graphical", [main("sdl")], "graphical", env={**gui_env, **gc},
                      expect={**cocoa, **refused}, build="main/sdl", timeout=180)
            self.case("g-main-headless", "graphical", [main("sdl")], "graphical", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True, **refused}, build="main/sdl")
            self.case("g-worker-cocoa", "graphical", [worker("sdl")], "graphical",
                      expect={"class": "FAILED-CORRECTNESS"} if APPLE else {"class": "UNAVAILABLE-GUI"},
                      note="the positive control: the default worker's SDL_Init fails as the census established")
            self.case("g-worker-headless", "graphical", [worker("sdl")], "graphical", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True})
            self.case("g-worker-headless-gc", "graphical", [worker("sdl")], "graphical", env={**dummy, **gc},
                      expect={"class": "EXECUTED-HEADLESS", "headless": True}, timeout=180)
            if self.args.checkout:
                self.case("g-rustc-cocoa", "graphical", [rustc("sdl")], "graphical", env=gui_env,
                          expect={**cocoa, **refused}, build="rustc/sdl", note="rustc-linked: Rust's own main, then aot::start_linked")
                self.case("g-checkout-cocoa", "graphical", [checkout("sdl")], "graphical", env=gui_env,
                          expect={**cocoa, **refused}, build="checkout/sdl", note="the checkout's system linker")

        if want("controls"):
            self.case("pc-baddriver", "controls", [w / "csdl", "main"], "graphical", env={"SDL_VIDEODRIVER": "nonexistent"},
                      expect={"class": "FAILED-CORRECTNESS", "headless": True}, note="SDL_Init must fail: never a window")
            self.case("pc-dummy-not-cocoa", "controls", [main("sdl")], "graphical", env=dummy, build="main/sdl",
                      expect={"class": "EXECUTED-HEADLESS", "headless": True, **refused},
                      note="a dummy-driver run on the main thread must never be classified EXECUTED-COCOA")
            self.case("pc-nopump", "controls", [w / "csdl", "nopump"], "graphical", env={} if APPLE else dummy,
                      expect={"class": "UNAVAILABLE-GUI" if (APPLE and self.gui is False) else "FAILED-CORRECTNESS"},
                      note="the pushed quit is never polled: must not be reported processed")
            self.case("pc-nodestroy", "controls", [w / "csdl", "nodestroy"], "graphical", env={} if APPLE else dummy,
                      expect={"class": "UNAVAILABLE-GUI" if (APPLE and self.gui is False) else "FAILED-CORRECTNESS"},
                      note="no destroy and no SDL_Quit: the cleanup check must notice")
            self.oracle_selftest()

        if want("timing"):
            n = self.args.repeat
            self.case("t-id-worker", "timing", [worker("identity")], "identity", expect={"main": False}, repeat=n)
            self.case("t-id-main", "timing", [main("identity")], "identity", expect={"main": True, **refused},
                      build="main/identity", repeat=n)
            self.case("t-main-sdl", "timing", [main("sdl")], "graphical", env=gui_env, expect={**cocoa, **refused},
                      build="main/sdl", repeat=n)
            self.case("t-main-sdl-headless", "timing", [main("sdl")], "graphical", env=dummy, build="main/sdl",
                      expect={"class": "EXECUTED-HEADLESS", "headless": True, **refused}, repeat=n)
            self.case("t-worker-sdl-headless", "timing", [worker("sdl")], "graphical", env=dummy,
                      expect={"class": "EXECUTED-HEADLESS", "headless": True}, repeat=n)
            self.case("t-main-sdl-headless-gc", "timing", [main("sdl")], "graphical", env={**dummy, **gc}, build="main/sdl",
                      expect={"class": "EXECUTED-HEADLESS", "headless": True, **refused}, repeat=n, timeout=180)
            self.case("t-worker-sdl-headless-gc", "timing", [worker("sdl")], "graphical", env={**dummy, **gc},
                      expect={"class": "EXECUTED-HEADLESS", "headless": True}, repeat=n, timeout=180)
            self.case("t-main-kept-gc", "timing", [main("kept")], "runtime", env=gc, build="main/kept",
                      expect={"value": KEPT, **refused}, repeat=n, timeout=180)
            self.case("t-worker-kept-gc", "timing", [worker("kept")], "runtime", env=gc,
                      expect={"value": KEPT}, repeat=n, timeout=180)
            self.case("t-c-main", "timing", [w / "csdl", "main"], "graphical", env=gui_env,
                      expect={"class": "EXECUTED-COCOA" if APPLE else "EXECUTED-HEADLESS"}, repeat=n)

    def report(self):
        super().report()
        summary = self.out / "summary.md"
        text = summary.read_text().replace("# MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md: outcomes",
                                           "# MAIN-THREAD-STARTUP-MILESTONE-1.md: the graphical acceptance", 1)
        builds = ["", "## Builds (ms)", "", "| build | ok | ms |", "|---|---|---|"]
        builds += [f"| {k} | {'yes' if v['ok'] else '**no**'} | {v['ms']} |" for k, v in sorted(self.builds.items())]
        summary.write_text(text + "\n".join(builds) + "\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--work", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--sdl-prefix", required=True)
    ap.add_argument("--app")
    ap.add_argument("--checkout")
    ap.add_argument("--tclsh", default="tclsh9.0")
    ap.add_argument("--repeat", type=int, default=5)
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    if not args.app and not args.checkout:
        ap.error("--app or --checkout")
    a = Acceptance(args)
    a.environment()
    a.native()
    a.botlish()
    a.cases()
    a.report()
    unexpected = [r["name"] for r in a.records if not r.get("expected")]
    if unexpected:
        log(f"NOT AS PREDICTED ({len(unexpected)}): {', '.join(unexpected)}")
        sys.exit(1)
    log("every case as predicted")


if __name__ == "__main__":
    main()
