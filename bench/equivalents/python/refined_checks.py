#!/usr/bin/env python3
# Python equivalent of bench/refined-checks.ir: repeated refined-type
# predicates. Emailish? is a structural check (regex membership test);
# UriQueryValue? is opaque evidence that only uri_escape can attach.
#
# Invoked by bench/bench.tcl; see fib.py for the --runs/value/best_us
# protocol shared by all four equivalents. The printed value's "[a, b]"
# shape matches core::value::show's rendering of a Botlish list, so
# bench.tcl can compare it against the Tcl backends' output directly.
import re
import sys
import time

_EMAIL_RE = re.compile(r"^[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\.)+[A-Za-z]{2,}$")


def emailish(s):
    return bool(_EMAIL_RE.fullmatch(s))


class UriQueryValue(str):
    """A str subclass marking evidence that uri_escape produced this value."""


def uri_query_value(s):
    return isinstance(s, UriQueryValue)


def uri_escape(s):
    escaped = "".join(
        c if re.match(r"[A-Za-z0-9._~-]", c) else "".join(f"%{b:02X}" for b in c.encode("utf-8"))
        for c in s
    )
    return UriQueryValue(escaped)


def check(n, acc, s, q):
    if n <= 0:
        return acc
    if emailish(s):
        # Statically redundant re-check, mirrored from the IR as written.
        if emailish(s):
            hit = 1 if uri_query_value(q) else 0
        else:
            hit = 0
    else:
        hit = 0
    return check(n - 1, acc + hit, s, q)


def parse_args(argv):
    runs = 5
    positional = []
    i = 0
    while i < len(argv):
        if argv[i] == "--runs":
            i += 1
            runs = int(argv[i])
        else:
            positional.append(argv[i])
        i += 1
    return runs, positional


def run_once(n0, s1, s2, raw_q):
    q = uri_escape(raw_q)
    return [check(n0, 0, s1, q), check(n0, 0, s2, q)]


if __name__ == "__main__":
    runs, positional = parse_args(sys.argv[1:])
    n0 = int(positional[0]) if len(positional) > 0 else 400
    s1 = positional[1] if len(positional) > 1 else "someone@example.com"
    s2 = positional[2] if len(positional) > 2 else "not-an-email"
    raw_q = positional[3] if len(positional) > 3 else "a b"

    run_once(n0, s1, s2, raw_q)  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = run_once(n0, s1, s2, raw_q)
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: [{value[0]}, {value[1]}]")
    print(f"best_us: {best:.3f}")
