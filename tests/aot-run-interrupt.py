#!/usr/bin/env python3
"""aot-run-interrupt.py -- interrupts a program main.tcl -aot-run runs, as a
terminal or a person would, for tests/aot-run.test (AOT-RUN-MILESTONE-1.md,
"Signals and cleanup"; Unix only).

    python3 -I tests/aot-run-interrupt.py HOW SIGNAL -- COMMAND...

COMMAND (main.tcl -aot-run of a program that prints "ready PID" and then
sleeps) is started as the leader of a process group of its own, as a shell
starts a foreground job. Once the program has said it is ready, HOW is done
with SIGNAL:

    group    to the whole process group (a terminal's Ctrl-C: SIGINT)
    parent   to COMMAND's process alone (main.tcl killed: SIGKILL)
    driver   to the native driver alone, the program's parent (SIGTERM)

Then it waits (at most 20 s) for the program, the driver and COMMAND to
end, and prints a Tcl dict: ready (1 when the program said so), alive (1
when the program still runs at the end: it outlived its command), status
(COMMAND's exit status, or the signal that ended it, negated).
"""
import os
import signal
import subprocess
import sys
import time


def state(pid):
    """None when PID no longer exists or is a zombie, else its ps state."""
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return None
    except PermissionError:
        return "?"
    r = subprocess.run(["ps", "-o", "stat=", "-p", str(pid)], capture_output=True, text=True)
    s = r.stdout.strip()
    if not s or s.startswith("Z"):
        return None
    return s


def parent_of(pid):
    r = subprocess.run(["ps", "-o", "ppid=", "-p", str(pid)], capture_output=True, text=True)
    return int(r.stdout.strip() or 0)


def gone(pid, deadline):
    while time.time() < deadline:
        if state(pid) is None:
            return True
        time.sleep(0.05)
    return state(pid) is None


def main(argv):
    how, name = argv[0], argv[1]
    assert argv[2] == "--"
    command = argv[3:]
    sig = getattr(signal, name)
    proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, preexec_fn=os.setpgrp)
    ready, pid = 0, 0
    deadline = time.time() + 120
    while time.time() < deadline:
        line = proc.stdout.readline()
        if not line:
            break
        words = line.decode("utf-8", "replace").split()
        if len(words) == 2 and words[0] == "ready":
            ready, pid = 1, int(words[1])
            break
    if not ready:
        proc.kill()
        proc.wait()
        print("ready 0 alive 0 status %d" % proc.returncode)
        return 0
    driver = parent_of(pid)
    if how == "group":
        os.killpg(proc.pid, sig)
    elif how == "parent":
        os.kill(proc.pid, sig)
    elif how == "driver":
        os.kill(driver, sig)
    else:
        raise SystemExit("unknown HOW %r" % how)
    deadline = time.time() + 20
    gone(pid, deadline)
    if driver > 1:
        gone(driver, deadline)
    try:
        status = proc.wait(timeout=max(1, deadline - time.time()))
    except subprocess.TimeoutExpired:
        proc.kill()
        status = proc.wait()
    alive = 0 if state(pid) is None else 1
    if alive:
        os.kill(pid, signal.SIGKILL)
    print("ready %d alive %d status %d" % (ready, alive, status))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
