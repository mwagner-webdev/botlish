"""peak.py -- runs one command and prints its wall time and peak resident
size, for the readiness census's measurements (audit/mid-end-port/readiness/
README.md): /usr/bin/time is not installed on every host, and Tcl cannot
read a child's resource usage.

    python3 -I peak.py COMMAND [ARG...]

Prints `seconds S peakKb K status N` on standard error after the command's
own output, which passes through unchanged. Linux and macOS: ru_maxrss is
KB on Linux, bytes on macOS (converted)."""
import os, resource, subprocess, sys, time

t0 = time.monotonic()
status = subprocess.call(sys.argv[1:])
seconds = time.monotonic() - t0
peak = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
if sys.platform == "darwin":
    peak //= 1024
sys.stderr.write("seconds %.3f peakKb %d status %d\n" % (seconds, peak, status))
sys.exit(0)
