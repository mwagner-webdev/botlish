#!/usr/bin/env python3
# Python equivalent of bench/uri-steady.bot: steady-state percent-escaping
# of a small fixed corpus (plain unreserved ASCII, ASCII that needs
# escaping, multi-byte UTF-8, a mixed string), summing each result's length.
#
# Invoked by bench/bench.tcl; see fib.py for the --runs/value/best_us
# protocol shared by all equivalents.
#
# uri_escape_text is stdlib/web.bot's std::web::uri_escape_text: every
# scalar above 127 becomes the %XX escapes of its UTF-8 bytes, an RFC 3986
# unreserved ASCII character (letters, digits, - . _ ~) is kept, every
# other ASCII character becomes its own %XX, uppercase hex, built up one
# piece at a time. The Botlish driver is a recursion 2,000 calls deep
# (repeat_uri); Python's default recursion limit is 1,000, so it is a loop
# here, doing the same calls in the same order.
import sys
import time

HEX_DIGITS = "0123456789ABCDEF"
UNRESERVED = frozenset("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")


def pct(b):
    return "%" + HEX_DIGITS[b >> 4] + HEX_DIGITS[b & 15]


def uri_escape_text(s):
    out = []
    for c in s:
        if ord(c) > 127:
            out.extend(pct(b) for b in c.encode("utf-8"))
        elif c in UNRESERVED:
            out.append(c)
        else:
            out.append(pct(ord(c)))
    return "".join(out)


def repeat_uri(corpus, total):
    acc = 0
    for i in range(total):
        escaped = uri_escape_text(corpus[i % len(corpus)])
        acc += len(escaped)
    return acc


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


if __name__ == "__main__":
    runs, positional = parse_args(sys.argv[1:])
    total = int(positional[0]) if positional else 2000
    corpus = ["abcXYZ012", "a b+c?", "café", "hello 世界?"]

    repeat_uri(corpus, total)  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = repeat_uri(corpus, total)
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: {value}")
    print(f"best_us: {best:.3f}")
