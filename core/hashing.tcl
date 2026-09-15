# hashing.tcl -- native structural hash: hash(value) -> Int.
#
# The smallest general-purpose primitive the hash-table milestone needs
# beyond MutableArray and mod: a semantic hash consistent with
# core::value::equal (core/value.tcl), so equal values always hash equal.
# Nothing here knows about hash tables -- this is exactly as general as ==,
# and is undefined for the same values == is undefined for.
#
# Algorithm: FNV-1a (64-bit constants), byte-by-byte over each value's kind
# tag and payload, recursing into List elements and Result payloads in
# order. This is a plain, ordinary hash -- no cryptographic strength, no
# random seed -- chosen only because it is simple to implement identically
# in this reference interpreter and in the native runtime (native/src/
# runtime/ops.rs's rt_hash), which is what makes hash results reproducible
# across backends (parity in the test sense, not merely "some Int").
#
# Determinism and stability, precisely:
#   - deterministic within one Botlish value's structure: equal values
#     (core::value::equal) always hash equal, on every call, every process,
#     every platform this runtime targets
#   - stable across processes and across runs: no random seed is mixed in
#     anywhere (the milestone explicitly defers collision hardening)
#   - NOT guaranteed stable across a future change to this algorithm's
#     constants or byte encoding: hash is a runtime-internal derived value,
#     never a value to persist or compare across program versions
#
# Supported key domain: int, str, bool, unit, list (of hashable values),
# result (of a hashable payload) -- exactly core::value::equal's domain.
# Like ==, hash is undefined for block/native/mutarray (EQUALITY error):
# see core::value::equal's header. The hash-table milestone's realistic
# benchmarked domain is narrower still (String keys, matching the upcoming
# CSV workload, and Int keys to isolate hashing/probing cost) -- see
# examples/stdlib/hashtable.bot's header.
#
# Result range: masked to 61 bits (always 0 <= result < 2^61), comfortably
# inside the runtime's small-Int envelope (2^62): a hash result can never
# itself force a BigInt allocation, on either backend. This is a result
# *shape* guarantee (-result-range nonneg, like mod's), not a new integer
# representation: the result is an ordinary arbitrary-precision Botlish Int
# that merely never happens to need more than 61 bits.

namespace eval core::hashing {
    variable FnvOffset 0xcbf29ce484222325
    variable FnvPrime  0x100000001b3
    variable Mask64    0xFFFFFFFFFFFFFFFF
    variable Mask61    0x1FFFFFFFFFFFFFFF
    # Kind tags mixed in before each value's payload, so e.g. int 1 and str
    # "1" never hash the same by coincidence of byte content.
    variable KindTag [dict create int 0 str 1 bool 2 unit 3 list 4 result 5]
}

# H folded over one more byte (0..255), wrapped to 64 bits.
proc core::hashing::Step {h byte} {
    variable FnvPrime
    variable Mask64
    set h [expr {($h ^ $byte) & $Mask64}]
    return [expr {($h * $FnvPrime) & $Mask64}]
}

proc core::hashing::Bytes {h bytes} {
    foreach byte $bytes {
        set h [Step $h $byte]
    }
    return $h
}

# The UTF-8 bytes of TEXT (unsigned 0..255 each), matching how the native
# runtime hashes a StrObj's own UTF-8 storage byte-for-byte.
proc core::hashing::Utf8Bytes {text} {
    set encoded [encoding convertto utf-8 $text]
    binary scan $encoded c* signed
    return [lmap b $signed {expr {$b & 0xFF}}]
}

# An 8-byte little-endian encoding of the 64-bit (already masked) value N,
# used to fold a sub-hash (of a list element or Result payload) into an
# outer hash as opaque bytes, exactly as the native runtime does.
proc core::hashing::LeBytes {n} {
    set bytes {}
    for {set i 0} {$i < 8} {incr i} {
        lappend bytes [expr {($n >> (8 * $i)) & 0xFF}]
    }
    return $bytes
}

proc core::hashing::Mix {h v} {
    variable KindTag
    variable Mask64
    set kind [core::value::kind $v]
    if {$kind in {block native mutarray}} {
        core::semanticError EQUALITY \
            "hash is not defined for callables: [core::value::show $v]"
    }
    set h [Step $h [dict get $KindTag $kind]]
    switch -- $kind {
        int {
            # Canonical decimal text: core::value::equal treats textual
            # identity as numeric equality, so hashing that same text
            # keeps hash consistent with equal for every Int, small or big.
            return [Bytes $h [Utf8Bytes [core::value::intOf $v]]]
        }
        str {
            # Evidence is metadata, not part of the value (see value.tcl):
            # equal ignores it, so hash must too. intOf/strOf-style access
            # already gives just the text, never evidence.
            return [Bytes $h [Utf8Bytes [core::value::strOf $v]]]
        }
        bool {
            return [Step $h [expr {[core::value::isTrue $v] ? 1 : 0}]]
        }
        unit {
            return $h
        }
        list {
            set items [core::value::items $v]
            set h [Bytes $h [LeBytes [llength $items]]]
            foreach item $items {
                variable FnvOffset
                set sub [Mix $FnvOffset $item]
                set h [Bytes $h [LeBytes $sub]]
            }
            return $h
        }
        result {
            set h [Step $h [expr {[core::value::resultTag $v] eq "ok" ? 1 : 0}]]
            variable FnvOffset
            set sub [Mix $FnvOffset [core::value::resultPayload $v]]
            return [Bytes $h [LeBytes $sub]]
        }
    }
}

proc core::hashing::hash {v} {
    variable FnvOffset
    variable Mask61
    set h [Mix $FnvOffset $v]
    return [core::value::int [expr {$h & $Mask61}]]
}

core::native::register hash -arity 1 -impl core::hashing::hash \
    -param-types any -result-type int -result-range nonneg -runtime hash
