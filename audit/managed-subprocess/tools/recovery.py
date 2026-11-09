#!/usr/bin/env python3
"""recovery.py -- the managed-subprocess census's crash-recovery experiment
(MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md, section 10).

    python3 -I audit/managed-subprocess/tools/recovery.py [--no-subreaper]

Plays the persistent coordinator around slice/durable (the Botlish
supervisor): starts it, lets it record its three jobs, SIGKILLs it (no
cleanup runs), then observes for 4 s what survives -- each job, P2's
descendant, P3's output file -- and, as the coordinator becomes the
subreaper (prctl PR_SET_CHILD_SUBREAPER, the default here), the exit status
of every orphan reparented to it. Then it reattaches to P2 from its record:
pidfd_open(PID), verify the record's start time against /proc (so a
reused PID is refused), signal P2's group through the pidfd. With
--no-subreaper the orphans go to PID 1 and their statuses are unobservable.
"""
import ctypes
import os
import signal
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
SLICE = os.path.join(os.path.dirname(HERE), "slice")
HELPER = os.path.join(SLICE, "bin", "msp-child")
PIDFD_SIGNAL_PROCESS_GROUP = 1 << 2
CRASH = []


def stat(pid):
    try:
        with open(f"/proc/{pid}/stat") as f:
            rest = f.read().rsplit(")", 1)[1].split()
        return {"state": rest[0], "ppid": int(rest[1]), "pgid": int(rest[2]), "start": int(rest[19])}
    except OSError:
        return None


def describe(status):
    if os.WIFEXITED(status):
        return f"exited {os.WEXITSTATUS(status)}"
    if os.WIFSIGNALED(status):
        return f"signal {os.WTERMSIG(status)} ({signal.Signals(os.WTERMSIG(status)).name})"
    return f"status {status}"


def reap_all(statuses, names):
    while True:
        try:
            pid, st = os.waitpid(-1, os.WNOHANG)
        except ChildProcessError:
            return
        if pid == 0:
            return
        statuses[pid] = describe(st)
        since = f" {time.monotonic() - CRASH[0]:.2f} s after the crash" if CRASH else ""
        print(f"  reaped orphan {names.get(pid, pid)}: {statuses[pid]}{since}", flush=True)


def main():
    subreaper = "--no-subreaper" not in sys.argv
    if subreaper:
        libc = ctypes.CDLL(None, use_errno=True)
        assert libc.prctl(36, 1, 0, 0, 0) == 0  # PR_SET_CHILD_SUBREAPER
    tmp = tempfile.mkdtemp(prefix="msp-durable-")
    for d in ("a", "b"):
        os.makedirs(os.path.join(tmp, d))
    sup = subprocess.Popen([os.path.join(SLICE, "durable"), HELPER, tmp], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    line = sup.stdout.readline().decode().strip()
    print(f"supervisor {sup.pid}: {line}")
    jobs = {}
    for l in open(os.path.join(tmp, "jobs.txt")):
        name, pid, start, pgid, cwd = l.split()
        jobs[name] = {"pid": int(pid), "start": int(start), "pgid": int(pgid), "cwd": cwd}
        print(f"record {name}: pid {pid} start {start} pgid {pgid} cwd {cwd}")
    desc = [int(d) for d in os.listdir("/proc") if d.isdigit() and stat(int(d)) and stat(int(d))["pgid"] == jobs["P2"]["pgid"] and int(d) != jobs["P2"]["pid"]]
    names = {v["pid"]: k for k, v in jobs.items()}
    for d in desc:
        names[d] = "P2's descendant"
    time.sleep(0.7)
    size_at_crash = os.path.getsize(os.path.join(tmp, "p3.out"))
    os.kill(sup.pid, signal.SIGKILL)
    CRASH.append(time.monotonic())
    sup.wait()
    print(f"supervisor killed (SIGKILL); P3's output had {size_at_crash} bytes")
    statuses = {}
    reap_all(statuses, names)
    time.sleep(0.3)
    for pid, n in sorted(names.items(), key=lambda x: x[1]):
        s = stat(pid)
        state = "gone" if not s else ("exited, not yet reaped" if s["state"] == "Z" else "alive") + f" (parent {s['ppid']}, group {s['pgid']})"
        print(f"  0.3 s after the crash: {n} {state}")
    deadline = time.monotonic() + 4.0
    while time.monotonic() < deadline:
        reap_all(statuses, names)
        time.sleep(0.05)
    for pid, n in sorted(names.items(), key=lambda x: x[1]):
        s = stat(pid)
        state = "gone" if not s or s["state"] == "Z" else f"alive (parent {s['ppid']})"
        print(f"after 4 s: {n} {state}; status {statuses.get(pid, 'not observed by the coordinator')}")
    size_after = os.path.getsize(os.path.join(tmp, "p3.out"))
    # chunk 0..9 are 8 bytes each, chunk 10..29 9 bytes: 260 in all.
    print(f"P3's output file: {size_at_crash} bytes at the crash, {size_after} after (complete: {'yes' if size_after == 260 else 'no'})")
    # Reattach to P2 from its record, as a restarted coordinator would.
    rec = jobs["P2"]
    try:
        fd = os.pidfd_open(rec["pid"])
        s = stat(rec["pid"])
        if s and s["start"] == rec["start"]:
            print("reattach P2: pidfd opened, start time verified")
            signal.pidfd_send_signal(fd, signal.SIGTERM, None, PIDFD_SIGNAL_PROCESS_GROUP)
            print("reattach P2: SIGTERM sent to its group through the pidfd")
        else:
            print("reattach P2: start time differs: refused (a reused PID)")
        os.close(fd)
    except ProcessLookupError:
        print("reattach P2: no such process")
    time.sleep(0.3)
    reap_all(statuses, names)
    for pid in [rec["pid"]] + desc:
        s = stat(pid)
        print(f"after reattach: {names[pid]} {'gone' if not s or s['state'] == 'Z' else 'alive'}; status {statuses.get(pid, 'not observed')}")
    # A forged record: the right PID, another start time.
    forged = {"pid": os.getpid(), "start": stat(os.getpid())["start"] + 1}
    s = stat(forged["pid"])
    print(f"forged record (pid {forged['pid']}, start {forged['start']}): {'refused' if s['start'] != forged['start'] else 'accepted'}")
    # Clean up whatever survived.
    for pid in names:
        try:
            os.kill(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    time.sleep(0.1)
    reap_all(statuses, names)


if __name__ == "__main__":
    main()
