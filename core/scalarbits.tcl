# scalarbits.tcl -- the generic bitwise Int primitives Byte/Nibble/bit
# arithmetic is built from (bit_and, bit_or, bit_xor, shift_left,
# shift_right).
#
# The Byte/Nibble/LowNibble/HighNibble bounded-integer domains themselves
# are no longer registered here: they are ordinary Botlish source
# declarations in lib/byte.bot (see SOURCE-DEFINED-INTEGER-DOMAINS.md,
# which supersedes this file's own former #161-189 for exactly what moved
# and why). What is still true of them, unchanged by where they are
# declared:
#
# Semantic domains (all four are ordinary refined `int` types -- see
# type.tcl's header -- validator-backed, not opaque: membership is decided
# structurally, by re-running the validator on the actual Int value, exactly
# like Emailish/NonEmpty. No runtime wrapper object exists for any of them:
# a Byte/Nibble/LowNibble/HighNibble value is, at every backend and at every
# layer, an ordinary Botlish Int. See BYTE-NIBBLE-BIT-ARITHMETIC.md for the
# full design writeup this file used to implement.
#
#   Byte        0..255                a plain 8-bit value
#   Nibble      0..15                 a logical 4-bit value
#   LowNibble   0..15                 a nibble already positioned in the low
#                                     half of a Byte (numerically identical
#                                     to Nibble's domain, but a distinct name:
#                                     LowNibble means "already positioned",
#                                     Nibble means "logical value")
#   HighNibble  {0,16,32,...,240}     a nibble positioned in the high half of
#                                     a Byte -- 16 exact values, not every
#                                     integer in [0,240]
#
# Checked construction from Int (Byte(x), Nibble(x), LowNibble(x),
# HighNibble(x)) enforces each domain exactly, raising {CORE SEMANTIC RANGE}
# for an invalid value -- never masking or silently truncating (masking is
# what the explicit byte::high_nibble/byte::low_nibble bit operations below
# are for). These four constructors are supported on interp/compile only:
# unlike the bitwise primitives below, a checked constructor's failure path
# has no native (Cranelift) implementation yet (no core-IR "raise" primitive
# exists for a -native-body to compose), so `Byte(x)` etc. are native-
# unsupported on cranelift/cranelift-generic, reported (not silently
# swallowed) exactly like any other not-yet-native-lowerable call --
# see native/lower.tcl's Unsupported. This is now a property of every
# source-declared bounded-integer type generically (hir/sourcetypes.tcl's
# own core::type::declareIntConstructor), not something this file arranges.
#
# byte::high_nibble/byte::low_nibble/byte::nibble/byte::complement/
# byte::position_low/byte::position_high (lib/byte.bot) are ordinary,
# Botlish functions with verified result contracts, built from the bitwise primitives below --
# not separate natives. byte::high_nibble(0xAB) is HighNibble(0xA0), not
# logical Nibble(0xA): position-preserving extraction, never folded into
# normalization itself (spec's own #3-4); byte::nibble(...) is the separate
# conversion that does that. See lib/byte.bot's own header for exactly why
# these are ordinary functions here rather than natives with a declared
# HighNibble/LowNibble/Nibble result type: native lowering's -native-body/
# -module-fn bridge (native/native.tcl) is a syntactic pre-pass over only
# the entry program's own raw core IR, so a native whose sole executable
# form is one of those is unsupported on Cranelift the moment it is called
# from *inside* a cross-file module function -- exactly web.bot's own
# high_nibble's shape -- discovered directly while building this milestone
# (BYTE-NIBBLE-BIT-ARITHMETIC.md's own trace). Plain functions over
# `bit_and`/`bit_or`/`bit_xor`/`shift_left`/`shift_right` sidestep this
# entirely (those five are already in native/lower.tcl's own op table).
# Ordinary block metadata now carries the verified nominal result through
# module resolution and specialization, and the integer-domain descriptor
# below seeds hir/range.tcl at every caller.

namespace eval core::scalarbits {}

# ---------------------------------------------------------------------------
# Generic bitwise Int primitives.
#
# Distinct from + - * mod (core/primitives.tcl): Botlish Int stays
# arbitrary-precision and these still operate over the *whole* Int domain,
# but bitwise operations are naturally total/checked differently than
# arithmetic (spec #58-59):
#
#   bit_and, bit_or, bit_xor    total over every Int (positive, negative, or
#                               zero), two's-complement, exactly matching
#                               Tcl's own &|^ and Rust's num_bigint BitAnd/
#                               BitOr/BitXor -- never fails.
#   shift_left, shift_right     the value shifted may be any Int (an
#                               arithmetic/sign-extending shift, i.e. exact
#                               multiplication/floor-division by 2^k); the
#                               shift amount must be a nonnegative Int no
#                               larger than maxShift, or {CORE SEMANTIC
#                               RANGE} is raised (never silent truncation of
#                               an out-of-range amount, never UB) -- a
#                               generic shift's own domain is a deliberately
#                               *weaker* contract than the named positioning
#                               conversions below (spec #20), which is why
#                               byte::position_high uses shift_left(n, 4)
#                               internally but a caller shifting by an
#                               unproven amount still gets a checked op.
#
# No generic `~` (bitwise NOT) is defined here: a full one's-complement of
# an arbitrary-precision Int is well-defined (Tcl/Rust both give it via
# -(x+1)) but is not the operation this milestone's domains need, and
# accidentally inheriting it as "~Byte" would be exactly the mistake spec
# #15 warns against. Only byte::complement (below), defined over Byte's
# 8-bit domain via bit_xor with 0xFF, is provided.

namespace eval core::scalarbits {
    variable maxShift 1048576
}

proc core::scalarbits::bitAnd {a b} {
    lassign [core::primitives::Ints bit_and $a $b] x y
    return [core::value::int [expr {$x & $y}]]
}

proc core::scalarbits::bitOr {a b} {
    lassign [core::primitives::Ints bit_or $a $b] x y
    return [core::value::int [expr {$x | $y}]]
}

proc core::scalarbits::bitXor {a b} {
    lassign [core::primitives::Ints bit_xor $a $b] x y
    return [core::value::int [expr {$x ^ $y}]]
}

# The nonnegative shift amount of raw Tcl int K, or a RANGE error: shared by
# shiftLeft/shiftRight, matching native/src/runtime/ops.rs's shift_amount
# exactly (same bound, same error kind) so interp/compile and native agree.
proc core::scalarbits::CheckShiftAmount {k} {
    variable maxShift
    if {$k < 0 || $k > $maxShift} {
        core::semanticError RANGE "shift amount out of range (0..$maxShift)"
    }
}

proc core::scalarbits::shiftLeft {a b} {
    lassign [core::primitives::Ints shift_left $a $b] x k
    CheckShiftAmount $k
    return [core::value::int [expr {$x << $k}]]
}

proc core::scalarbits::shiftRight {a b} {
    lassign [core::primitives::Ints shift_right $a $b] x k
    CheckShiftAmount $k
    return [core::value::int [expr {$x >> $k}]]
}

foreach {name impl} {
    bit_and     core::scalarbits::bitAnd
    bit_or      core::scalarbits::bitOr
    bit_xor     core::scalarbits::bitXor
    shift_left  core::scalarbits::shiftLeft
    shift_right core::scalarbits::shiftRight
} {
    core::native::register $name -arity 2 -impl $impl \
        -param-types {int int} -result-type int -runtime bigint -context-free 1
}
unset name impl

# The four scalar domains (Byte, Nibble, LowNibble, HighNibble) are no
# longer registered here: they are ordinary Botlish source declarations in
# lib/byte.bot now (see SOURCE-DEFINED-INTEGER-DOMAINS.md). This file keeps
# only the primitive bit operations above, which those declarations' own
# functions (byte::high_nibble et al.) are built from -- and which stay
# root natives regardless of what domains are ever declared over their
# results, exactly as before this milestone.
