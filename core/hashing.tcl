# hashing.tcl -- native structural hash: hash(value) -> Int.
#
# STATUS: bootstrap native -- candidate for stdlib replacement.
#
#   This implementation is acceptable for now, but it is deliberately a
#   native primitive rather than an ordinary Botlish one, purely because
#   Botlish itself cannot yet express it: FNV-1a needs 64-bit *wrapping*
#   multiplication/XOR over Int, and Botlish's only Int is arbitrary-
#   precision (core/value.tcl) -- there is no wrapping integer type to write
#   this algorithm in Botlish today. That is a gap in the language, not a
#   reason this belongs in the runtime permanently. Do not let this native
#   quietly become "just how hashing works" -- it is a stand-in.
#
#   Replace it with an ordinary Botlish implementation once BOTH of these
#   are true:
#     1. Botlish has a wrapping (fixed-width, e.g. 64-bit) integer type or
#        equivalent wrapping arithmetic operators, so FNV-1a's step function
#        can be written directly in Botlish instead of simulated here with
#        `& Mask64` (Tcl) / `wrapping_mul` (Rust) on the runtime's own
#        arbitrary-precision Int;
#     2. the exact hash semantics this runtime should guarantee going
#        forward are actually decided (algorithm, byte encoding, whether
#        FNV-1a specifically is kept or replaced, seeding/collision-hardening
#        policy) -- "whatever core/hashing.tcl currently does" is a
#        placeholder, not a specification.
#   Until then, this file and native/src/runtime/ops.rs's rt_hash are the
#   two implementations that must stay byte-for-byte identical (see below);
#   a Botlish replacement collapses that duplication to one.
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
# Supported key domain: int, str, bool, unit, enum (ENUMS.md), list (of hashable values),
# result (of a hashable payload), UnicodeChar, Float64, bytestore and mutbytes (ABI-BYTES.md,
# MUTABLE-BYTES.md: the byte count, then the bytes), immutableSet (of hashable
# members, combined order-independently to match core::value::equal's own
# order-independent set equality) -- exactly core::value::equal's domain.
# Like ==, hash is undefined for block/native/mutarray (EQUALITY error):
# see core::value::equal's header. The hash-table milestone's realistic
# benchmarked domain is narrower still (String keys, matching the upcoming
# CSV workload, and Int keys to isolate hashing/probing cost) -- see
# examples/stdlib/hashtable.bot's header.
#
# Two hashes, one walk (HASHABLE-AND-KEYED-HASH.md). `hash` is the public,
# deterministic hash above. `table_hash::of` is the private, collision-
# hardened hash the standard library's hash structures place values with:
# SipHash-1-3 under a key the runtime draws once per process (TableKey), never
# a Botlish value. Both hash the same canonical input, produced by one walk of
# the value (Encode): its kind tag, then its payload. They differ only in how
# the walk is folded --
#
#   public  a variable-length text (an Int's or a code point's decimal text,
#           a String, an enum's or a struct's names) is its bytes alone; a
#           nested value (a List element, a struct field, a Result payload)
#           is its own 64-bit FNV-1a sub-hash, 8 bytes little-endian; a set
#           member's sub-hashes are XOR-combined. Exactly the bytes this file
#           always hashed: every public hash is unchanged.
#   table   a text is its byte count (8 bytes, little-endian) then its bytes,
#           so the input is prefix-free; a nested value is its own canonical
#           input, inline; a set's members are XOR-combined keyed hashes.
#
# The table hash consumes the value, never the public hash: two values whose
# public hashes collide -- which anyone can arrange offline, as
# audit/hashable/tools/collide.rs does for whole 64-bit FNV states -- feed it
# different inputs, so no key-independent collision survives. Its numbers are
# not stable across processes or versions and are never shown to a program.
#
# Result range: masked to 61 bits (always 0 <= result < 2^61), comfortably
# inside the runtime's small-Int envelope (2^62): a hash result can never
# itself force a BigInt allocation, on either backend. This is a result
# *shape* guarantee (-result-range {interval 0 2^61-1}), not a new integer
# representation: the result is an ordinary arbitrary-precision Botlish Int
# that merely never happens to need more than 61 bits.

namespace eval core::hashing {
    variable FnvOffset 0xcbf29ce484222325
    variable FnvPrime  0x100000001b3
    variable Mask64    0xFFFFFFFFFFFFFFFF
    variable Mask61    0x1FFFFFFFFFFFFFFF
    # Kind tags mixed in before each value's payload, so e.g. int 1 and str
    # "1" never hash the same by coincidence of byte content.
    variable KindTag [dict create int 0 str 1 bool 2 unit 3 list 4 result 5 UnicodeChar 6 immutableSet 7 struct 8 bytestore 9 mutbytes 10 enum 11 Float64 12]
    # The kinds whose values have no hash: Encode refuses them (EQUALITY),
    # and the compiler's Hashable witnesses (hir::types::HashClass) read this
    # very list beside core::value's `incomparable`. Exactly == 's domain
    # today; native/src/runtime/ops.rs's walk refuses the same kinds.
    variable unhashable {block native mutarray coroutine mutvec cptr DecimalRounded}
    # The private table hash's key, {K0 K1} (two 64-bit words), drawn once per
    # process the first time it is needed (TableKey); "" until then. Runtime
    # state: no Botlish value holds it, no operation returns it.
    variable tableKey ""
    # A fixed key for test harnesses (useTableHashKey), "" in production.
    variable tableKeyOverride ""
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

# The canonical input, a list of bytes (0..255), of value V's hash in MODE
# (public or table: the header): V's kind tag, then its payload. The one
# walk of a value both hashes make; Text and Child are where the modes
# differ.
proc core::hashing::Encode {mode v} {
    variable KindTag
    variable unhashable
    set kind [core::value::kind $v]
    if {$kind in $unhashable} {
        if {$kind eq "DecimalRounded"} {
            # Hashing agrees with equality, which a DecimalRounded value has
            # only at the precision of its static type (core::value::equal;
            # DECIMAL-ROUNDED-MILESTONE-1.md).
            core::semanticError EQUALITY \
                "hash of a DecimalRounded value needs the precision of its type, which a hash does not know"
        }
        core::semanticError EQUALITY \
            "hash is not defined for callables: [core::value::show $v]"
    }
    set out [list [dict get $KindTag $kind]]
    switch -- $kind {
        int {
            # Canonical decimal text: core::value::equal treats textual
            # identity as numeric equality, so hashing that same text
            # keeps hash consistent with equal for every Int, small or big.
            Text out $mode [Utf8Bytes [core::value::intOf $v]]
        }
        str {
            # Evidence is metadata, not part of the value (see value.tcl):
            # equal ignores it, so hash must too. intOf/strOf-style access
            # already gives just the text, never evidence.
            Text out $mode [Utf8Bytes [core::value::strOf $v]]
        }
        bool {
            lappend out [expr {[core::value::isTrue $v] ? 1 : 0}]
        }
        unit {
        }
        UnicodeChar {
            # Canonical decimal codepoint text, matching how Int's own
            # canonical decimal text is hashed above: same encoding, no
            # separate binary scheme to keep in sync with native/src/
            # runtime/ops.rs's walk.
            Text out $mode [Utf8Bytes [core::value::charOf $v]]
        }
        list {
            set items [core::value::items $v]
            lappend out {*}[LeBytes [llength $items]]
            foreach item $items {
                Child out $mode $item
            }
        }
        result {
            lappend out [expr {[core::value::resultTag $v] eq "ok" ? 1 : 0}]
            Child out $mode [core::value::resultPayload $v]
        }
        struct {
            # Consistent with core::value::equal's struct equality (same
            # shape, equal fields slot by slot): the declaration identity
            # text (empty for an anonymous struct), the field count, then
            # each slot's name text and its value in slot order. The shape
            # is folded in so {x: 1} and {y: 1} do not collide by design.
            set fields [core::value::structFields $v]
            Text out $mode [Utf8Bytes [core::value::structId $v]]
            lappend out {*}[LeBytes [llength $fields]]
            foreach field $fields item [core::value::structValues $v] {
                Text out $mode [Utf8Bytes $field]
                Child out $mode $item
            }
        }
        enum {
            # Consistent with core::value::equal's nominal enum equality
            # (ENUMS.md): the enum's declaration identity text, a 0xFF
            # separator (never a byte of UTF-8 text, so the pair is encoded
            # unambiguously), then the case's declared name. Never the
            # case's position in its declaration: reordering cases changes
            # no hash, and no hash is an ordinal.
            Text out $mode [Utf8Bytes [core::value::enumId $v]]
            lappend out 255
            Text out $mode [Utf8Bytes [core::value::enumCaseName $v]]
        }
        bytestore - mutbytes {
            # The byte count (8 bytes, little-endian), then every byte in
            # order: consistent with core::value::equal's exact byte-sequence
            # equality, and with native/src/runtime/ops.rs's walk. A
            # MutableBytes hashes by its current contents under its own kind
            # tag (the tag is the only difference from a byte storage). The
            # count already delimits the bytes, in both modes.
            set hex [lindex $v 1]
            set count [expr {[string length $hex] / 2}]
            lappend out {*}[LeBytes $count]
            if {$count > 0} {
                binary scan [binary decode hex $hex] cu* codes
                lappend out {*}$codes
            }
        }
        Float64 {
            # The binary64 bit pattern, 8 bytes little-endian: a value has
            # one representation (no NaN, no negative zero, core/value.tcl),
            # so equal numbers have equal bits, consistent with
            # core::value::equal and with native/src/runtime/ops.rs's walk.
            lappend out {*}[LeBytes [core::float::bits64 $v]]
        }
        immutableSet {
            # Order-independent (XOR-combined member hashes), matching
            # core::value::equal's own order-independent set equality: two
            # equal sets must hash equal regardless of construction order.
            # No ImmutableSet-specific hashing *API* is added (MINIMAL-
            # IMMUTABLE-SET.md item 92) -- this only keeps the existing,
            # pre-existing generic `hash` native (core::value::equal's own
            # "hash consistent with equal" contract, this file's header)
            # total for the new kind instead of silently mishandling it.
            variable Mask64
            set items [core::value::immutableSetItems $v]
            lappend out {*}[LeBytes [llength $items]]
            set combined 0
            foreach item $items {
                set combined [expr {($combined ^ [Fold $mode $item]) & $Mask64}]
            }
            lappend out {*}[LeBytes $combined]
        }
    }
    return $out
}

# Appends the variable-length text BYTES to OUTVAR's canonical input in
# MODE: the bytes alone (public, as this file always hashed), or their count
# first (table: a prefix-free input, so no two different values' inputs are
# one byte string).
proc core::hashing::Text {outVar mode bytes} {
    upvar 1 $outVar out
    if {$mode eq "table"} {
        lappend out {*}[LeBytes [llength $bytes]]
    }
    lappend out {*}$bytes
}

# Appends nested value V to OUTVAR's canonical input in MODE: its own 64-bit
# FNV-1a sub-hash (public), or its own canonical input, inline (table: the
# keyed hash reads every byte of the value, never a public sub-hash, which
# anyone can make collide).
proc core::hashing::Child {outVar mode v} {
    upvar 1 $outVar out
    if {$mode eq "table"} {
        lappend out {*}[Encode table $v]
    } else {
        lappend out {*}[LeBytes [Fold public $v]]
    }
}

# The full 64-bit hash of V's canonical input in MODE: FNV-1a (public) or
# SipHash-1-3 under the process key (table).
proc core::hashing::Fold {mode v} {
    variable FnvOffset
    if {$mode eq "public"} {
        return [Bytes $FnvOffset [Encode public $v]]
    }
    return [SipHash13 {*}[TableKey] [Encode table $v]]
}

proc core::hashing::hash {v} {
    variable Mask61
    return [core::value::intFromNumber [expr {[Fold public $v] & $Mask61}]]
}

# The private table hash of V (HASHABLE-AND-KEYED-HASH.md): SipHash-1-3,
# under the process key, of V's canonical input, masked to 61 bits like
# `hash`. Equal values hash equal within one process; nothing is promised
# across processes.
proc core::hashing::tableHash {v} {
    variable Mask61
    return [core::value::intFromNumber [expr {[Fold table $v] & $Mask61}]]
}

# ---------------------------------------------------------------------------
# SipHash-1-3 (Aumasson and Bernstein's SipHash with one compression and
# three finalization rounds, the variant Rust's HashMap uses), over the list
# of bytes BYTES under the key K0, K1 (64-bit words). native/src/runtime/
# ops.rs's Sip13 computes the same function; audit/hashable/tools/oracle.py is
# an independent implementation the tests compare both with.

proc core::hashing::SipRound {v0Var v1Var v2Var v3Var} {
    upvar 1 $v0Var v0 $v1Var v1 $v2Var v2 $v3Var v3
    set m 0xFFFFFFFFFFFFFFFF
    set v0 [expr {($v0 + $v1) & $m}]
    set v1 [expr {(($v1 << 13) | ($v1 >> 51)) & $m}]
    set v1 [expr {$v1 ^ $v0}]
    set v0 [expr {(($v0 << 32) | ($v0 >> 32)) & $m}]
    set v2 [expr {($v2 + $v3) & $m}]
    set v3 [expr {(($v3 << 16) | ($v3 >> 48)) & $m}]
    set v3 [expr {$v3 ^ $v2}]
    set v0 [expr {($v0 + $v3) & $m}]
    set v3 [expr {(($v3 << 21) | ($v3 >> 43)) & $m}]
    set v3 [expr {$v3 ^ $v0}]
    set v2 [expr {($v2 + $v1) & $m}]
    set v1 [expr {(($v1 << 17) | ($v1 >> 47)) & $m}]
    set v1 [expr {$v1 ^ $v2}]
    set v2 [expr {(($v2 << 32) | ($v2 >> 32)) & $m}]
}

proc core::hashing::SipHash13 {k0 k1 bytes} {
    set v0 [expr {$k0 ^ 0x736f6d6570736575}]
    set v1 [expr {$k1 ^ 0x646f72616e646f6d}]
    set v2 [expr {$k0 ^ 0x6c7967656e657261}]
    set v3 [expr {$k1 ^ 0x7465646279746573}]
    set n [llength $bytes]
    set whole [expr {$n - $n % 8}]
    for {set i 0} {$i < $whole} {incr i 8} {
        set word 0
        foreach b [lreverse [lrange $bytes $i [expr {$i + 7}]]] {
            set word [expr {($word << 8) | $b}]
        }
        set v3 [expr {$v3 ^ $word}]
        SipRound v0 v1 v2 v3
        set v0 [expr {$v0 ^ $word}]
    }
    # The last block: the remaining bytes, little-endian, and the input's
    # length (mod 256) in the top byte.
    set word [expr {($n & 0xFF) << 56}]
    set shift 0
    foreach b [lrange $bytes $whole end] {
        set word [expr {$word | ($b << $shift)}]
        incr shift 8
    }
    set v3 [expr {$v3 ^ $word}]
    SipRound v0 v1 v2 v3
    set v0 [expr {$v0 ^ $word}]
    set v2 [expr {$v2 ^ 0xFF}]
    SipRound v0 v1 v2 v3
    SipRound v0 v1 v2 v3
    SipRound v0 v1 v2 v3
    return [expr {$v0 ^ $v1 ^ $v2 ^ $v3}]
}

# ---------------------------------------------------------------------------
# The table hash's process key

# {K0 K1}: the key of every table hash this process computes. Drawn once, on
# first use, from the operating system's entropy (/dev/urandom); where the
# host has none (Windows, which the Tcl reference backends also run on), from
# the clock, the process id and Tcl's own counters -- unpredictable to a
# program, but not a cryptographic source: the native runtime, which draws its
# key from the system's random source on every host, is the production one.
proc core::hashing::TableKey {} {
    variable tableKey
    variable tableKeyOverride
    if {$tableKeyOverride ne ""} {
        return $tableKeyOverride
    }
    if {$tableKey eq ""} {
        set tableKey [DrawKey]
    }
    return $tableKey
}

proc core::hashing::DrawKey {} {
    if {![catch {
        set f [open /dev/urandom rb]
        try {
            set raw [read $f 16]
        } finally {
            close $f
        }
    }] && [string length $raw] == 16} {
        binary scan $raw wu2 words
        return $words
    }
    set seed [list [clock clicks] [clock microseconds] [pid] [info cmdcount] [expr {rand()}]]
    binary scan [binary format a* [encoding convertto utf-8 $seed]] cu* codes
    set h [Bytes 0xcbf29ce484222325 $codes]
    return [list $h [Bytes [expr {$h ^ 0x9e3779b97f4a7c15}] $codes]]
}

# Test harnesses only (HASHABLE-AND-KEYED-HASH.md, "Correctness oracle"): KEY
# {K0 K1} fixes the table hash's key for this process, so a test can compare
# exact keyed hashes with an independent implementation; "" restores the
# drawn process key. No Botlish operation reaches this.
proc core::hashing::useTableHashKey {key} {
    variable tableKeyOverride
    if {$key ne ""} {
        if {[llength $key] != 2} {
            error "core::hashing::useTableHashKey: KEY must be two 64-bit words"
        }
        foreach word $key {
            if {![string is entier -strict $word] || $word < 0 || $word > 0xFFFFFFFFFFFFFFFF} {
                error "core::hashing::useTableHashKey: KEY must be two 64-bit words"
            }
        }
        set key [lmap word $key {expr {$word + 0}}]
    }
    set tableKeyOverride $key
}

core::native::register hash -arity 1 -impl core::hashing::hash \
    -param-types any -result-type int -result-range [list interval 0 [expr {(1 << 61) - 1}]] \
    -runtime hash -ownership {equality} -hashing {0 checked}

# The private table hash (HASHABLE-AND-KEYED-HASH.md): a member of the
# internal namespace table_hash, so only the standard library's modules may
# call it, and nothing may take it as a value. Not -context-free: it reads
# the runtime's process key, so it is never evaluated before run time.
core::native::register table_hash::of -arity 1 -impl core::hashing::tableHash \
    -param-types any -result-type int -result-range [list interval 0 [expr {(1 << 61) - 1}]] \
    -runtime table-hash -ownership {equality} -hashing {0 required} -nomethod 1
core::native::declareInternalNamespace table_hash
