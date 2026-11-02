#!/usr/bin/env python3
# Python equivalent of bench/lex-strategy.bot: a strict-vs-relaxed
# identifier-character classifier, chosen as a function value at an if/else
# join and then applied to every character of each token, plus a universal
# "is every character of this token alphanumeric?" query.
#
# Invoked by bench/bench.tcl; see fib.py for the --runs/value/best_us
# protocol shared by all equivalents. The printed value's shape matches
# core::value::show's rendering of a Botlish List (strings double-quoted).
#
# Mapping: choose_classifier returns one of two functions, as the Botlish
# program's two branches return std::str::is_tcl_alnum or
# lenient_ident_char?; classify builds the List of per-character flags
# (the Botlish collecting loop) and count_true counts them. The Botlish
# chars_of is a recursive accumulator only because the language has no
# String-to-characters conversion; list(s) is Python's own spelling of it.
# tcl_alnum is Tcl 9's [:alnum:] (see refined_checks.py for why it is
# isalpha() or isdecimal(), never isalnum()).
import sys
import time


def tcl_alnum(c):
    return c.isalpha() or c.isdecimal()


def lenient_ident_char(c):
    return tcl_alnum(c) or c == "_" or c == "-"


def choose_classifier(strict_mode):
    if strict_mode:
        return tcl_alnum
    return lenient_ident_char


def chars_of(s):
    return list(s)


def classify(token, strict_mode):
    classifier = choose_classifier(strict_mode)
    return [classifier(c) for c in chars_of(token)]


def count_true(flags):
    return sum(1 for flag in flags if flag)


def valid_chars(token, strict_mode):
    return count_true(classify(token, strict_mode))


def fully_alnum(token):
    return all(tcl_alnum(c) for c in chars_of(token))


def total_valid(tokens, strict_mode):
    return sum(valid_chars(token, strict_mode) for token in tokens)


def run_once(tokens):
    strict_total = total_valid(tokens, True)
    relaxed_total = total_valid(tokens, False)
    alnum_only_tokens = [token for token in tokens if fully_alnum(token)]
    first_alnum = alnum_only_tokens[0] if alnum_only_tokens else ""
    return [strict_total, relaxed_total, len(alnum_only_tokens), first_alnum]


def show(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        escaped = value.replace("\\", "\\\\").replace('"', '\\"')
        return f'"{escaped}"'
    if isinstance(value, list):
        return "[" + ", ".join(show(v) for v in value) + "]"
    return str(value)


def parse_args(argv):
    runs = 5
    i = 0
    while i < len(argv):
        if argv[i] == "--runs":
            i += 1
            runs = int(argv[i])
        i += 1
    return runs


if __name__ == "__main__":
    runs = parse_args(sys.argv[1:])
    tokens = ["emailish?", "scan_while", "local-part", "tld-check", "x_1", "9bad-name", "café", "is_tcl_alpha"]

    run_once(tokens)  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = run_once(tokens)
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: {show(value)}")
    print(f"best_us: {best:.3f}")
