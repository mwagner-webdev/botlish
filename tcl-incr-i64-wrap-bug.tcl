#!/usr/bin/env tclsh9.0
# Minimal reproduction: bytecode-compiled `incr` wraps to i64::MIN instead of
# promoting to a bignum when incrementing past i64::MAX (9223372036854775807),
# but only when `incr` runs inside a compiled proc. `incr` typed directly at
# tclsh's interactive top level (uncompiled) is unaffected and produces the
# arithmetically correct result.
#
# Confirmed present, via direct source diff of generic/tclExecute.c, in Tcl
# core-9-0-1, core-9-0-2, core-9-0-3, core-9-0-4 (latest stable as of this
# writing) and core-9-1-a1 (latest alpha) -- byte-for-byte identical buggy
# code in every one of them; none of the corresponding release notes mention
# it. There is therefore no newer Tcl 9 version that avoids this bug.
#
# Root cause: INST_INCR_SCALAR1_IMM / INST_INCR_SCALAR_IMM in
# generic/tclExecute.c correctly *detects* the overflow with the
# `Overflowing` macro, but on that overflow branch it re-derives the result
# via plain Tcl_WideInt addition (TclNewIntObj/TclSetIntObj with
# `w + increment`) -- the exact computation that just overflowed, repeated,
# then stored as if it hadn't -- instead of promoting to an mp_int bignum the
# way uncompiled `expr`/`incr` at the top level already does correctly.
#
# Expected output (both lines read 9223372036854775808):
#     top-level incr:    9223372036854775808
#     proc-compiled incr: 9223372036854775808
#
# Actual output on all affected versions (second line silently wraps to
# i64::MIN instead of promoting):
#     top-level incr:    9223372036854775808
#     proc-compiled incr: -9223372036854775808

set v 9223372036854775807
incr v
puts "top-level incr:    $v"

proc p {} {
    set v 9223372036854775807
    incr v
    return $v
}
puts "proc-compiled incr: [p]"
