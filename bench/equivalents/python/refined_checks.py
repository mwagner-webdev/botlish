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

# Tcl 9-compatible Unicode alpha/alnum classification (see
# NATIVE-TCL-UNICODE.md for the derivation and the empirical Tcl 9.0.1
# corpus this was checked against, and native/src/runtime/ops.rs's
# tcl_alpha_char/tcl_alnum_char / bench/equivalents/rust/tcl_unicode.rs for
# the other two implementations that must agree with this one):
#
#   tcl_alpha(c)  General_Category(c) in {Lu, Ll, Lt, Lm, Lo}   ("Letter")
#   tcl_alnum(c)  tcl_alpha(c) or General_Category(c) == Nd
#
# str.isalpha() is documented (Python's own reference) to test exactly
# General_Category in {Lm, Lt, Lu, Ll, Lo} -- an exact match, verified
# directly against the corpus, not assumed. str.isdecimal() tests exactly
# General_Category == Nd, so `isalpha() or isdecimal()` is the exact tcl_alnum
# match. str.isalnum() is NOT used here: it is documented to also accept
# Numeric_Type=Digit/Numeric characters (categories No/Nl too, e.g. circled
# digits, Roman numerals, superscripts), which Tcl's [:alnum:] does not --
# verified directly (see NATIVE-TCL-UNICODE.md's edge-case corpus).
#
# Unicode-version note: Python's unicodedata module here is 14.0.0 (see
# `unicodedata.unidata_version`), while Tcl 9.0.1 and the Rust equivalent's
# generated table (unicode-general-category 1.1.0) agree on Unicode 16.0.
# A real, disclosed skew for code points assigned only in Unicode 15.0+,
# immaterial to this benchmark's own test corpus (NATIVE-TCL-UNICODE.md) --
# never hidden, never silently assumed away.


def tcl_alpha(c):
    return c.isalpha()


def tcl_alnum(c):
    return c.isalpha() or c.isdecimal()


def is_local_char(c):
    return tcl_alnum(c) or c in "._%+-"


def is_label_char(c):
    return tcl_alnum(c) or c == "-"


# Same two-pointer scan as bench/equivalents/rust/refined_checks.rs's
# `emailish` (and lib/web.tcl's Emailish? native-body): the domain/local
# structure is ordinary control flow, not a regex -- only the leaf
# character-class tests above are Unicode-classification-dependent. A
# regex-based version was deliberately not kept: Python's stdlib `re` has
# no built-in "Tcl [:alpha:]/[:alnum:]" character class, and building one
# from a hand-written pattern would just be this same classification
# problem wearing a regex disguise.
def emailish(s):
    n = len(s)
    i = 0
    local_start = i
    while i < n and is_local_char(s[i]):
        i += 1
    if i == local_start:
        return False
    if i >= n or s[i] != "@":
        return False
    i += 1
    while True:
        label_start = i
        while i < n and is_label_char(s[i]):
            i += 1
        if i == label_start:
            return False
        if i >= n or s[i] != ".":
            return False
        i += 1
        j = i
        while j < n and tcl_alpha(s[j]):
            j += 1
        if j == n and j - i >= 2:
            return True
        # else: continue the loop, treating what was just scanned as
        # another domain label rather than the final TLD.


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
    s1 = positional[1] if len(positional) > 1 else "café@例え.テスト"
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
