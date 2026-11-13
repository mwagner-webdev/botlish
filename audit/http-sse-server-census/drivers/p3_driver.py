#!/usr/bin/env python3
"""Census probe P3's driver: start the signal probe, wait for "ready",
send SIGTERM to the process, report how it ended (HTTP-SSE-SERVER-CENSUS-
MILESTONE-1.md)."""
import os, signal, subprocess, sys, time
p = subprocess.Popen([sys.argv[1]], stdout=subprocess.PIPE, text=True)
lines = []
for line in p.stdout:
    lines.append(line.rstrip())
    if line.startswith("ready"):
        break
threads = sorted(os.listdir(f"/proc/{p.pid}/task"))
os.kill(p.pid, signal.SIGTERM)
rest, _ = p.communicate(timeout=5)
lines += rest.splitlines()
print("threads of the process:", threads)
print("\n".join(lines))
print("exit status:", p.returncode, "(negative: killed by that signal)")
