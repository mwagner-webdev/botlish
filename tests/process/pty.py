#!/usr/bin/env python3
"""pty.py -- run a command with a new pseudo-terminal as its controlling
terminal and its standard streams (tests/process-linux.test: the tty
scenarios), under a watchdog.

    python3 -I tests/process/pty.py TIMEOUT COMMAND ARG...

Prints the command's output, then "pty exit STATUS" (or "pty exit TIMEOUT")
and "pty termios changed yes|no" (the slave's attributes before and after).
The terminal is left as the command left it until this script closes it.
"""
import os
import pty
import select
import subprocess
import sys
import termios
import time
import fcntl


def main():
    timeout = float(sys.argv[1])
    argv = sys.argv[2:]
    master, slave = pty.openpty()
    before = termios.tcgetattr(slave)

    def setup():
        os.setsid()
        fcntl.ioctl(0, termios.TIOCSCTTY, 0)

    p = subprocess.Popen(argv, stdin=slave, stdout=slave, stderr=slave, preexec_fn=setup, close_fds=True)
    out = b""
    deadline = time.monotonic() + timeout
    status = None
    while True:
        if time.monotonic() > deadline:
            p.kill()
            status = "TIMEOUT"
        r, _, _ = select.select([master], [], [], 0.05)
        if r:
            try:
                data = os.read(master, 65536)
            except OSError:
                data = b""
            out += data
        if p.poll() is not None:
            # Drain what the terminal still holds.
            while True:
                r, _, _ = select.select([master], [], [], 0.1)
                if not r:
                    break
                try:
                    data = os.read(master, 65536)
                except OSError:
                    break
                if not data:
                    break
                out += data
            break
    if status is None:
        status = p.returncode
    after = termios.tcgetattr(slave)
    sys.stdout.write(out.decode("utf-8", "replace").replace("\r\n", "\n"))
    print(f"pty exit {status}")
    print(f"pty termios changed {'yes' if before != after else 'no'}")
    os.close(slave)
    os.close(master)


main()
