#!/usr/bin/env python3
"""run.py -- the managed-subprocess census's harness
(MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md).

    python3 -I audit/managed-subprocess/tools/run.py [--build] [--only NAME...] [--out DIR]

Builds (with --build) the slice's executables, then runs every scenario
under an external watchdog (a hang is a failure that names itself, never a
pass), under a PTY where a scenario needs a terminal, checks the
expectations below against each run's lines, and checks from outside the
processes a run named ("pid N", "desc N"): gone, or -- where the scenario
says so -- alive (then killed here). Writes every run's output and a
summary to DIR (default: audit/managed-subprocess/results/runs).
"""
import argparse
import errno
import fcntl
import os
import pty
import re
import resource
import select
import signal
import struct
import subprocess
import sys
import tempfile
import termios
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SLICE = os.environ.get("MSP_SLICE") or os.path.join(ROOT, "slice")
REPO = os.path.dirname(os.path.dirname(ROOT))
HELPER = os.path.join(SLICE, "bin", "msp-child")
PROGRAMS_DIR = SLICE
PROGRAMS = ["lab-io", "lab-life", "lab-perf", "slice", "threads", "durable"]

# name: (program, scenario args, expectations, options)
# An expectation is a regular expression every run must contain a line
# matching (re.search over the whole output), or "!RE": no line may match.
CLEAN = [r"^end owned 0$", r"^end live 0$", r"^end fds delta 0$"]
SCENARIOS = {
    "basic": ("lab-io", ["basic"], [r"^args 9$", r"^arg 2 -$", r"^arg 3 612062$", r"^arg 5 68c3a96c6c6f20e282ac$",
                                     r"^env MSP_X=one two$", r"^env HOME unset$", r"^env PATH unset$", r"^env ONLY=1$", r"^cwd /"] + CLEAN, {}),
    "launch": ("lab-io", ["launch"], [r"^missing launch-failed exec -2$", r"^not-executable launch-failed exec -13$",
                                       r"^directory launch-failed exec -13$", r"^relative-not-searched launch-failed exec -2$",
                                       r"^bad-cwd launch-failed working-directory -2$", r"^cwd-is-file launch-failed working-directory -20$",
                                       r"^bad-file launch-failed file -2$", r"^nul-in-arg launch-failed spec -22$",
                                       r"^exit-3 started exited 3$", r"^abort started (signal|core) 6$", r"^killed started signal 9$",
                                       r"^shell-explicit started exited 4$"] + CLEAN, {}),
    "streams": ("lab-io", ["streams"], [r"^stdout bytes 1048576$", r"^stderr bytes 1048580$", r"^status exited 0$"] + CLEAN, {}),
    "naive": ("lab-io", ["naive"], [r"^stdout read interrupted: deadlock$", r"^stdout bytes before the deadlock 0$",
                                     r"^child exited no$", r"^status signal 15$"] + CLEAN, {}),
    "stdin": ("lab-io", ["stdin"], [r"^written 4194304$", r"^echoed 4194304$", r"^child: cat-eof 4194304", r"^status exited 0$",
                                     r"^ticks ([2-9]\d|\d{3,})$"] + CLEAN, {}),
    "stdin-partial": ("lab-io", ["stdin-partial"], [r"^written 1000000$", r"^echoed 1000000$", r"^status exited 0$"] + CLEAN, {}),
    "backpressure": ("lab-io", ["backpressure"], [r"^first-chunk 65536$", r"^resumed exited 0$", r"^total 8388608$"] + CLEAN, {"sample": "outn:8388608"}),
    "binary": ("lab-io", ["binary"], [r"^bytes 262$", r"^reads [2-9]$", r"^first-nul 0$", r"^first-newline 10$",
                                       r"^second-newline 261$", r"^whole-as-utf8 <invalid utf-8>$", r"^tail-as-utf8 €$"] + CLEAN, {}),
    "eof-early": ("lab-io", ["eof-early"], [r"^stdout a$", r"^exited-at-eof 0$", r"^stderr late$", r"^status exited 4$"] + CLEAN, {}),
    "exit-unread": ("lab-io", ["exit-unread"], [r"^small bytes after exit 30000$", r"^large exited within 0.7 s unread no$",
                                                 r"^large bytes 200000$", r"^large status exited 5$"] + CLEAN, {}),
    "exit-first": ("lab-io", ["exit-first"], [r"^status exited 3$"] + CLEAN, {}),
    "persist": ("lab-io", ["persist"], [r"^status exited 0$"] + CLEAN, {"files": {"job.out": 100008, "job.err": 12}}),
    "limit": ("lab-io", ["limit"], [r"^limit exceeded: terminating$", r"^kept 4096$", r"^status signal 15$"] + CLEAN, {}),
    "inherit": ("lab-io", ["inherit"], [r"^default: sigpipe dfl mask 0$", r"^fds 0 1 2$", r"^kept: sigpipe ign mask 0$"] + CLEAN, {}),
    "tty-inherit": ("lab-io", ["inherit"], [r"^tty 0 0 0$", r"^tty 0 1 1$", r"^inherited"] + CLEAN, {"pty": True}),
    "tty-read": ("lab-io", ["tty-read"], [r"^stopped by the terminal: yes$", r"^status signal 9$"] + CLEAN, {"pty": True}),
    "tty-raw": ("lab-io", ["tty-raw"], [r"^status exited 0$"] + CLEAN, {"pty": True, "termios_changed": True}),
    "cancel": ("lab-life", ["cancel"], [r"^read interrupted after-us \d+$", r"^child still running after the interrupt yes$",
                                         r"^second read got bytes 6$", r"^status exited 0$"] + CLEAN, {}),
    "terminate": ("lab-life", ["terminate"], [r"^graceful exited 143$", r"^ignored signal 9$", r"^escalations 1$",
                                               r"^exits-during-grace exited 0$", r"^signal to an exited, unreaped child yes$",
                                               r"^already-exited exited 0$", r"^terminate-again exited 0$",
                                               r"^signal after release: stale -116$"] + CLEAN, {}),
    "descendants": ("lab-life", ["descendants"], [r"^group signal 15$", r"^escaped signal 15$", r"^orphans \(no subreaper\) 0$"] + CLEAN,
                    {"alive": "escaped"}),
    "subreaper": ("lab-life", ["subreaper"], [r"^subreaper 0$", r"^orphans found 1$", r"^orphans killed 1$", r"^orphans after 0$"] + CLEAN, {}),
    "inherited": ("lab-life", ["inherited"], [r"^leader exited 0$", r"^group signal after the leader's exit yes$"] + CLEAN, {"eof_after": 1400000}),
    "reap-order": ("lab-life", ["reap-order"], [r"^group signal after exit delivered yes$"] + CLEAN, {}),
    "eager-reap": ("lab-life", ["eager-reap"], [r"^group signal after exit delivered no$"] + CLEAN, {"alive": "all-desc"}),
    "release": ("lab-life", ["release"], [r"^owned right after release 1$", r"^leaving the owner's scope$",
                                           r"^owned after the scope 2$", r"^end escalations 1$"] + CLEAN, {}),
    "abandon": ("lab-life", ["abandon"], [r"^holder suspended at \d+$", r"^owned after the drop 1$", r"^releases 1$"] + CLEAN, {}),
    "shutdown": ("lab-life", ["shutdown"], [r"^end owned before shutdown 1$", r"^waiter: its read was revoked by the shutdown$",
                                             r"^end killed by shutdown 1$"] + CLEAN, {}),
    "detach": ("lab-life", ["detach"], [r"^owned after detach 0$", r"^still running \(sweep\) 1$", r"^the identity is stale after detach$",
                                         r"^still running after its end \(sweep\) 0$"] + CLEAN, {}),
    "detach-outlive": ("lab-life", ["detach-outlive"], [r"^owned after detach 0$", r"^end owned 0$", r"^end live 1$", r"^end fds delta 1$"], {"alive": "pid", "files": {"detached.pid": None}}),
    "two-waiters": ("lab-life", ["two-waiters"], [r"^waiter 1 saw exited 6$", r"^waiter 2 saw exited 6$"] + CLEAN, {}),
    "stdin-closed": ("lab-io", ["stdin-closed"], [r"^write after the child closed stdin: closed$", r"^status exited 0$"] + CLEAN, {}),
    "watch-release": ("lab-life", ["watch-release"], [r"^the next child's first chunk: new$", r"^status exited 0$"] + CLEAN, {}),
    "exhaust": ("lab-life", ["exhaust"], [r"failed at pipe -24$", r"^running \d+$"] + CLEAN, {"nofile": 128}),
    "stale": ("lab-life", ["stale"], [r"^old identity: stale -116$", r"^signal through the old identity: stale -116$",
                                       r"^the new child unaffected yes$"] + CLEAN, {}),
    "many": ("lab-life", ["many"], [r"^concurrent live 64$", r"^wrong sequential 0$", r"^wrong concurrent 0$", r"^live 0$",
                                     r"^fds delta 0$"] + CLEAN, {"zombies": True}),
    "threads": ("threads", [], [r"^vm 1 bytes 2000170 exit 11 owned-after 0$", r"^vm 2 bytes 3000080 exit 22 owned-after 0$",
                                r"^distinct children yes$", r"^adapter live after both 0$"], {"noargs": True}),
    "slice": ("slice", [], [r"^A ended exited 0$", r"^B ended signal 9$", r"^cancelling B$", r"^A lines fed 3$",
                            r"got: line 3$", r"^A! warning: something", r"^ticks [3-9]\d*$", r"^input lines 1$",
                            r"^end owned 0$", r"^end live 0$", r"^end escalations 1$", r"^end fds delta 0$",
                            r"^end registrations delta 0$", r"^end shutdown killed 0$"], {"pty": True, "type": (b"tick 4", b"c\n"), "noscenario": True}),
    "perf-throughput": ("lab-perf", ["throughput"], [r"^bytes 67108864$"] + CLEAN, {"perf": True}),
    "perf-latency": ("lab-perf", ["latency"], [r"^spawned 200$", r"^wrong 0$"] + CLEAN, {"perf": True}),
    "perf-idle": ("lab-perf", ["idle"], [r"^both exited yes$"] + CLEAN, {"perf": True}),
    "perf-poll": ("lab-perf", ["poll"], [r"^both exited yes$"] + CLEAN, {"perf": True}),
    "perf-flood": ("lab-perf", ["flood"], [r"^ticks \d+$"] + CLEAN, {"perf": True}),
}


def build(only):
    env = dict(os.environ, LANG="C.utf8", LC_ALL="C.utf8")
    subprocess.run(["sh", os.path.join(SLICE, "build.sh")], check=True, stdout=subprocess.DEVNULL)
    for prog in PROGRAMS:
        if only and not any(SCENARIOS[n][0] == prog for n in only):
            continue
        t = time.monotonic()
        r = subprocess.run(["tclsh9.0", os.path.join(REPO, "main.tcl"), "-warnings", "off", "-emit-native-executable", prog + ".bot"],
                           cwd=SLICE, env=env, capture_output=True, text=True, timeout=1800)
        print(f"build {prog}: {r.returncode} in {time.monotonic() - t:.1f} s", flush=True)
        if r.returncode != 0:
            print(r.stdout + r.stderr)
            sys.exit(1)


def proc_state(pid):
    try:
        with open(f"/proc/{pid}/stat") as f:
            fields = f.read().rsplit(")", 1)[1].split()
        return fields[0], int(fields[1])
    except OSError:
        return None, None


def zombies_of(pid):
    out = []
    for d in os.listdir("/proc"):
        if d.isdigit():
            st, ppid = proc_state(int(d))
            if ppid == pid and st == "Z":
                out.append(int(d))
    return out


PEAK = {}
NOFILE = []


def run_plain(argv, timeout):
    """Run ARGV, its output read to end of file under a watchdog; reaped with
    wait4 so its peak resident set size is known (PEAK['kb'])."""
    limit = None
    if NOFILE:
        limit = lambda: resource.setrlimit(resource.RLIMIT_NOFILE, (NOFILE[0], NOFILE[0]))
    p = subprocess.Popen(argv, cwd=SLICE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, preexec_fn=limit)
    out = b""
    deadline = time.monotonic() + timeout
    fd = p.stdout.fileno()
    timed_out = False
    while True:
        left = deadline - time.monotonic()
        if left <= 0:
            p.kill()
            timed_out = True
            left = 5
        r, _, _ = select.select([fd], [], [], min(left, 1.0))
        if r:
            data = os.read(fd, 65536)
            if not data:
                break
            out += data
        elif timed_out:
            break
    _, status, ru = os.wait4(p.pid, 0)
    p.returncode = os.waitstatus_to_exitcode(status)
    PEAK["kb"] = ru.ru_maxrss
    PEAK["cpu"] = ru.ru_utime + ru.ru_stime
    return ("TIMEOUT" if timed_out else p.returncode), out.decode("utf-8", "replace"), p


def run_pty(argv, timeout, typed=None):
    """Run ARGV with a PTY as its controlling terminal and its stdio; when
    TYPED = (trigger, text), write TEXT once TRIGGER appeared. The output,
    the exit status and the slave's termios before and after."""
    master, slave = pty.openpty()
    before = termios.tcgetattr(slave)

    def child_setup():
        os.setsid()
        fcntl.ioctl(0, termios.TIOCSCTTY, 0)

    p = subprocess.Popen(argv, cwd=SLICE, stdin=slave, stdout=slave, stderr=slave, preexec_fn=child_setup, close_fds=True)
    out = b""
    sent = False
    deadline = time.monotonic() + timeout
    status = None
    while True:
        if time.monotonic() > deadline:
            p.kill()
            status = "TIMEOUT"
            break
        r, _, _ = select.select([master], [], [], 0.05)
        if r:
            try:
                data = os.read(master, 65536)
            except OSError as e:
                if e.errno == errno.EIO:
                    data = b""
                else:
                    raise
            out += data
        if typed and not sent and typed[0] in out:
            os.write(master, typed[1])
            sent = True
        if p.poll() is not None and not r:
            # drain what is left
            try:
                while select.select([master], [], [], 0.05)[0]:
                    data = os.read(master, 65536)
                    if not data:
                        break
                    out += data
            except OSError:
                pass
            status = p.returncode
            break
    after = termios.tcgetattr(slave)
    os.close(slave)
    os.close(master)
    return status, out.decode("utf-8", "replace").replace("\r\n", "\n"), p, before != after


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--build", action="store_true")
    ap.add_argument("--only", nargs="*")
    ap.add_argument("--out", default=os.path.join(ROOT, "results", "runs"))
    ap.add_argument("--repeat", type=int, default=1)
    args = ap.parse_args()
    names = args.only or list(SCENARIOS)
    if args.build:
        build(args.only)
    os.makedirs(args.out, exist_ok=True)
    summary = []
    failures = 0
    for rep in range(args.repeat):
        for name in names:
            prog, sargs, expects, opts = SCENARIOS[name]
            tmp = tempfile.mkdtemp(prefix="msp-")
            for d in ("a", "b"):
                os.makedirs(os.path.join(tmp, d))
            if opts.get("noargs"):
                argv = [os.path.join(SLICE, prog), HELPER]
            elif opts.get("noscenario"):
                argv = [os.path.join(SLICE, prog), HELPER, tmp]
            else:
                argv = [os.path.join(SLICE, prog), HELPER] + sargs + [tmp]
            t = time.monotonic()
            changed = False
            sampled = ""
            if opts.get("pty"):
                status, out, p, changed = run_pty(argv, 60, opts.get("type"))
            elif opts.get("sample"):
                p = subprocess.Popen(argv, cwd=SLICE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                time.sleep(0.5)
                for d in os.listdir("/proc"):
                    if d.isdigit():
                        try:
                            cmd = open(f"/proc/{d}/cmdline", "rb").read()
                        except OSError:
                            continue
                        if opts["sample"].encode() in cmd and b"msp-child" in cmd:
                            try:
                                wchan = open(f"/proc/{d}/wchan").read()
                            except OSError:
                                wchan = "?"
                            st, _ = proc_state(int(d))
                            rss = [l for l in open(f"/proc/{p.pid}/status") if l.startswith("VmRSS")][0].split()[1]
                            sampled = f"[harness] paused child {d} state {st} wchan {wchan} supervisor VmRSS {rss} kB"
                try:
                    o, _ = p.communicate(timeout=60)
                    status, out = p.returncode, o.decode("utf-8", "replace")
                except subprocess.TimeoutExpired:
                    p.kill()
                    status, out = "TIMEOUT", p.communicate()[0].decode("utf-8", "replace")
            else:
                NOFILE[:] = [opts["nofile"]] if opts.get("nofile") else []
                status, out, p = run_plain(argv, 120 if opts.get("perf") else 60)
            elapsed = time.monotonic() - t
            problems = []
            if status != 0:
                problems.append(f"exit status {status}")
            if opts.get("termios_changed"):
                if not changed:
                    problems.append("the child's raw mode did not reach the terminal")
            elif opts.get("pty") and changed:
                problems.append("the terminal's attributes changed")
            for e in expects:
                neg = e.startswith("!")
                found = re.search(e[1:] if neg else e, out, re.M)
                if neg and found:
                    problems.append(f"unexpected {e[1:]!r}")
                if not neg and not found:
                    problems.append(f"missing {e!r}")
            if "task failed" in out:
                problems.append("a task failed")
            time.sleep(0.15)
            named = [(m.group(1), int(m.group(2))) for m in re.finditer(r"(desc|pid) (\d+)", out)]
            alive_want = opts.get("alive")
            lines = []
            for kind, pid in named:
                st, ppid = proc_state(pid)
                alive = st is not None and st != "Z"
                if alive:
                    lines.append(f"[harness] {kind} {pid} alive (state {st}, parent {ppid})")
                    os.kill(pid, signal.SIGKILL)
                else:
                    lines.append(f"[harness] {kind} {pid} gone")
                expected_alive = (alive_want == "pid" and kind == "pid") or (alive_want == "all-desc" and kind == "desc") or \
                                 (alive_want == "escaped" and kind == "desc" and pid == named[-1][1])
                if alive != expected_alive:
                    problems.append(f"{kind} {pid} {'alive' if alive else 'gone'}")
            if opts.get("zombies"):
                z = zombies_of(p.pid)
                if z:
                    problems.append(f"zombies {z}")
            for f, size in opts.get("files", {}).items():
                path = os.path.join(tmp, f)
                if not os.path.exists(path):
                    problems.append(f"no file {f}")
                elif size is not None and os.path.getsize(path) != size:
                    problems.append(f"{f} has {os.path.getsize(path)} bytes, not {size}")
                else:
                    lines.append(f"[harness] file {f}: {os.path.getsize(path)} bytes")
            if opts.get("eof_after"):
                m = re.search(r"^stdout-eof-us (\d+)$", out, re.M)
                if not m or int(m.group(1)) < opts["eof_after"]:
                    problems.append("stdout's end of file came before the descendant's exit")
            if sampled:
                lines.append(sampled)
            if not opts.get("pty") and not opts.get("sample") and "kb" in PEAK:
                lines.append(f"[harness] supervisor peak RSS {PEAK['kb']} kB, CPU {PEAK['cpu']:.3f} s")
                PEAK.clear()
            if opts.get("pty"):
                lines.append(f"[harness] terminal attributes {'changed' if changed else 'unchanged'}")
            verdict = "PASS" if not problems else "FAIL"
            failures += bool(problems)
            text = out + "\n".join(lines) + f"\n[harness] {verdict} in {elapsed:.2f} s" + ("".join(f"\n[harness] problem: {x}" for x in problems)) + "\n"
            with open(os.path.join(args.out, f"{name}.txt" if args.repeat == 1 else f"{name}.{rep}.txt"), "w") as f:
                f.write(text)
            summary.append(f"{verdict} {name} {elapsed:.2f}s" + (" -- " + "; ".join(problems) if problems else ""))
            print(summary[-1], flush=True)
    with open(os.path.join(args.out, "SUMMARY.txt"), "w") as f:
        f.write("\n".join(summary) + f"\n{len(summary) - failures} of {len(summary)} passed\n")
    print(f"{len(summary) - failures} of {len(summary)} passed")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
