#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized differential check of abi::bytes::MutableBytes value
# semantics and linux::read (MUTABLE-BYTES.md).
#
#   tclsh9.0 audit/mutable-bytes/tools/fuzz.tcl ?-mode pure|read|both? ?-n N?
#       ?-seed S? ?-items K? ?-backends LIST? ?-gc-stress 0|1?
#
# pure   (every semantic backend: interp, compile, cranelift-generic,
#         cranelift; no syscall is made)
#   Each program is a random SCRIPT of K value definitions over a growing set
#   of MutableBytes variables v0..vN, seeded individually (a failure replays
#   with `-seed S -n 1`). Every definition is one of
#       fresh            a new value from a random byte sequence (empty, one
#                        byte, sizes around 7/8/9, 15/16/17, 31/32/33, zeros,
#                        0xff, high half, ASCII, UTF-8, a few thousand bytes)
#       copy             vN = vK                       (binding)
#       set              vN = put(vK, I, B)            (an update at a random
#                                                       valid index, or an
#                                                       invalid one: IndexNotFound
#                                                       leaves vK as it is)
#       identity         vN = idg(vK)                  (generic function)
#       list             vN = first([vK, vJ])          (List storage)
#       struct           vN = unwrap(Holder {data: vK})(struct storage)
#       detach           vN = abi::bytes::detach(vK)
#       reuse            vN = put(put(vK, ..), ..)     (copy then two updates)
#   plus snapshots fN = abi::bytes::freeze(vK) and pN = prefix(vK, n) (n may exceed
#   the length: the sentinel OVER). The result lists the revealed contents of
#   EVERY variable and snapshot at the END, so an update that leaked into any
#   earlier copy, through any route, shows up. The independent oracle (a Tcl
#   byte-list model) computes every expected value; it never reads what the
#   program computes. Equality and hash between random pairs are checked too,
#   and the whole result must be identical on every backend.
#
# read   (native only, Linux x86-64; the only syscall made is read(2) from a
#         file or a pipe the harness feeds, and write(2) to files)
#   Each program makes several linux::read calls of random capacities (biased
#   as above) into buffers pre-filled with random NONZERO bytes, from one open
#   FILE, and checks: every result is exactly min(capacity, bytes remaining)
#   (a short read when the file ends inside a buffer, 0 at EOF); the returned
#   buffer is the bytes read followed by the untouched suffix; the caller's
#   own buffer is unchanged; and the file's remaining bytes are as expected --
#   in a normal run and under GC stress. A second program per seed reads once
#   from a real PIPE the harness writes (at most 4000 bytes: one atomic write).
#
# Ends with "mutable-bytes-fuzz programs N values V failures F"; exit status 1
# if F is not zero.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set mode both
set n 20
set seed0 1
set items 10
set backends {interp compile cranelift-generic cranelift}
set gcStress 0
while {[lindex $args 0] in {-mode -n -seed -items -backends -gc-stress}} {
    switch -- [lindex $args 0] {
        -mode { set mode [lindex $args 1] }
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -items { set items [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
        -gc-stress { set gcStress [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}
if {$gcStress} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}

set scratch [file tempdir mutable-bytes-fuzz]
set counter 0

proc hirOfText {text} {
    set text [surface::modules::ImportHeader $text]$text
    set path [file join $::scratch p[incr ::counter].bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
    try {
        return [surface::readProgramFile $path -strict 1]
    } finally {
        file delete $path
    }
}

# ---------------------------------------------------------------------------
# Generators (shared in spirit with audit/abi-bytes/tools/fuzz.tcl): a byte
# sequence is described by a SPEC the Botlish program and the Tcl oracle both
# evaluate the same way, so a program carries no per-byte source.

proc randomByte {} { return [expr {int(rand() * 256)}] }

proc polyValue {a b c i k d} {
    set v [expr {$a * $i * $i + $b * $i + $c}]
    if {$i == $k} { incr v $d }
    return $v
}

proc renderSpec {spec} {
    if {[lindex $spec 0] eq "utf8"} {
        binary scan [encoding convertto utf-8 [lindex $spec 1]] cu* bytes
        return [expr {[info exists bytes] ? $bytes : {}}]
    }
    lassign $spec - kind n t a b c k d
    set bytes {}
    for {set i 0} {$i < $n} {incr i} {
        set v [polyValue $a $b $c $i $k $d]
        switch -- $kind {
            full  { set byte [expr {$v % 256}] }
            ascii { set byte [expr {32 + $v % 95}] }
            high  { set byte [expr {128 + $v % 128}] }
            zeros { set byte [expr {$v % 3 == 0 ? 0 : $v % 256}] }
            ffs   { set byte [expr {$v % 3 == 0 ? 255 : $v % 256}] }
        }
        lappend bytes $byte
    }
    for {set i 0} {$i < $t} {incr i} { lappend bytes 0 }
    return $bytes
}

# The Botlish expression (a List[Byte]) of SPEC.
proc specSource {spec} {
    if {[lindex $spec 0] eq "utf8"} {
        return "str::encode_utf8([textLiteral [lindex $spec 1]])"
    }
    lassign $spec - kind n t a b c k d
    return "gen_${kind}([join [list $n $t $a $b $c $k $d] {, }])"
}

proc textLiteral {text} {
    # Botlish string literals have exactly the escapes \\ \" \n \r \t (the
    # lexer reports any other); every other character stands for itself.
    set out "\""
    foreach ch [split $text ""] {
        switch -- $ch {
            "\"" { append out {\"} }
            "\\" { append out {\\} }
            "\n" { append out {\n} }
            "\r" { append out {\r} }
            "\t" { append out {\t} }
            default { append out $ch }
        }
    }
    return "$out\""
}

# A random spec, biased toward the shapes that matter: empty, one byte, the
# sizes around 7/8/9, 15/16/17, 31/32/33 (where a small inline representation
# would end and a heap buffer begin), embedded zeros, 0xff and the high half,
# ASCII, arbitrary 8-bit data, repeated patterns, larger buffers, UTF-8.
proc randomSpec {} {
    set kinds {full ascii high zeros ffs}
    set kind [lindex $kinds [expr {int(rand() * 5)}]]
    set a [expr {int(rand() * 40)}]
    set b [expr {int(rand() * 300)}]
    set c [expr {int(rand() * 1000)}]
    set t 0
    switch -- [expr {int(rand() * 11)}] {
        0 { return {gen full 0 0 0 0 0 -1 0} }
        1 { set n 1 }
        2 {
            set sizes {2 3 4 7 8 9 15 16 17 23 24 25 31 32 33 63 64 65 127 128 129 255 256 257}
            set n [lindex $sizes [expr {int(rand() * [llength $sizes])}]]
        }
        3 {
            # embedded zeros: zero-padded, or all zero
            set n [expr {1 + int(rand() * 40)}]
            set t [expr {int(rand() * 5)}]
            if {rand() < 0.3} { set kind full; set a 0; set b 0; set c 0 }
        }
        4 {
            # 0xff-heavy and the high half
            set n [expr {1 + int(rand() * 40)}]
            if {rand() < 0.5} { set kind ffs } else { set kind high }
        }
        5 { set n [expr {1 + int(rand() * 60)}]; set kind ascii }
        6 {
            # repeated: a constant formula
            set n [expr {2 + int(rand() * 200)}]
            set a 0; set b 0
        }
        7 { set n [expr {500 + int(rand() * 2500)}] }
        8 {
            set k [expr {3 + int(rand() * 8)}]
            set n [expr {(1 << $k) + int(rand() * 3) - 1}]
        }
        9 {
            # UTF-8 of random scalars
            set text ""
            set count [expr {1 + int(rand() * 12)}]
            for {set i 0} {$i < $count} {incr i} {
                switch -- [expr {int(rand() * 4)}] {
                    0 { append text [format %c [expr {32 + int(rand() * 95)}]] }
                    1 { append text [format %c [expr {0xA0 + int(rand() * 0x500)}]] }
                    2 { append text [format %c [expr {0x2000 + int(rand() * 0x500)}]] }
                    3 { append text [format %c [expr {0x1F300 + int(rand() * 0x200)}]] }
                }
            }
            return [list utf8 $text]
        }
        10 { set n [expr {2 + int(rand() * 40)}] }
    }
    return [list gen $kind $n $t $a $b $c -1 0]
}

# The specs that must compare unequal to SPEC (gen specs only; a utf8 spec has
# its neighbours' inequality checked instead): one byte changed, the last byte
# dropped, a byte appended, a zero appended.
proc mutantSpecs {spec} {
    if {[lindex $spec 0] eq "utf8"} { return {} }
    lassign $spec - kind n t a b c k d
    set out {}
    if {$n > 0} {
        # Deterministic in the spec: the program and the oracle each ask for
        # the mutants and must see the same ones (a random index drawn per
        # call made them compare different bytes). Whether the changed byte
        # really differs is checked by the oracle itself: for the zeros and
        # ffs kinds a +1 can land on the byte the pattern already had.
        set idx [expr {($a * 7 + $b * 13 + $c * 31 + $n * 3) % $n}]
        lappend out [list gen $kind $n $t $a $b $c $idx 1]
        lappend out [list gen $kind [expr {$n - 1}] 0 $a $b $c -1 0]
    }
    lappend out [list gen $kind [expr {$n + 1}] 0 $a $b $c -1 0]
    lappend out [list gen $kind $n [expr {$t + 1}] $a $b $c -1 0]
    return $out
}

proc hexOf {bytes} {
    if {$bytes eq ""} { return "" }
    return [binary encode hex [binary format c* $bytes]]
}

set genFunctions {
fn bump(i: int, k: int, d: int) -> int:
    if i == k:
        d
    else:
        0

fn gen_full(n: int, t: int, a: int, b: int, c: int, k: int, d: int):
    loop i from 0 to n + t:
        if i >= n:
            byte::from_int(0)
        else:
            byte::from_int(mod(a * i * i + b * i + c + bump(i, k, d), 256))

fn gen_ascii(n: int, t: int, a: int, b: int, c: int, k: int, d: int):
    loop i from 0 to n + t:
        if i >= n:
            byte::from_int(0)
        else:
            byte::from_int(32 + mod(a * i * i + b * i + c + bump(i, k, d), 95))

fn gen_high(n: int, t: int, a: int, b: int, c: int, k: int, d: int):
    loop i from 0 to n + t:
        if i >= n:
            byte::from_int(0)
        else:
            byte::from_int(128 + mod(a * i * i + b * i + c + bump(i, k, d), 128))

fn gen_zeros(n: int, t: int, a: int, b: int, c: int, k: int, d: int):
    loop i from 0 to n + t:
        if i >= n:
            byte::from_int(0)
        elif mod(a * i * i + b * i + c + bump(i, k, d), 3) == 0:
            byte::from_int(0)
        else:
            byte::from_int(mod(a * i * i + b * i + c + bump(i, k, d), 256))

fn gen_ffs(n: int, t: int, a: int, b: int, c: int, k: int, d: int):
    loop i from 0 to n + t:
        if i >= n:
            byte::from_int(0)
        elif mod(a * i * i + b * i + c + bump(i, k, d), 3) == 0:
            byte::from_int(255)
        else:
            byte::from_int(mod(a * i * i + b * i + c + bump(i, k, d), 256))

}

# The top-level elements of a shown List "[a, b, ...]": split at ", " outside
# any braces/brackets/angle brackets.
proc splitShown {text} {
    set text [string range $text 1 end-1]
    set parts {}
    set depth 0
    set current ""
    set length [string length $text]
    for {set i 0} {$i < $length} {incr i} {
        set ch [string index $text $i]
        if {$ch in {"\{" "\[" "<"}} { incr depth }
        if {$ch in {"\}" "\]" ">"}} { incr depth -1 }
        if {$depth == 0 && $ch eq "," && [string index $text [expr {$i + 1}]] eq " "} {
            lappend parts $current
            set current ""
            incr i
            continue
        }
        append current $ch
    }
    lappend parts $current
    return $parts
}


proc boolWord {v} { return [expr {$v ? "true" : "false"}] }

proc binaryOf {bytes} {
    if {$bytes eq ""} { return "" }
    return [binary format c* $bytes]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }

# ---------------------------------------------------------------------------
# pure: a random script of value definitions, and the oracle that replays it

set pureHelpers {
fn mbf(d: abi::bytes::Bytes) -> abi::bytes::MutableBytes:
    abi::bytes::from_bytes(d)

struct Holder:
    data: abi::bytes::MutableBytes

fn put(m: abi::bytes::MutableBytes, i: int, v: Byte) -> abi::bytes::MutableBytes:
    abi::bytes::replace(m, i, v):
        on IndexNotFound:
            m

fn idg(x):
    x

fn first(xs: List[abi::bytes::MutableBytes]) -> abi::bytes::MutableBytes:
    list::at(xs, 0):
        on IndexNotFound:
            abi::bytes::zeroed(abi::usize(0))

fn unwrap(h: Holder) -> abi::bytes::MutableBytes:
    h.data

fn sentinel() -> abi::bytes::Bytes:
    abi::bytes::from_list(str::encode_utf8("OVER"))

fn pre(m: abi::bytes::MutableBytes, n: int) -> abi::bytes::Bytes:
    c = abi::usize(n):
        on abi::AbiIntegerBelowRange:
            abi::usize(0)
        on abi::AbiIntegerAboveRange:
            abi::usize(0)
    abi::bytes::freeze_prefix(m, c):
        on UpperOverrun:
            sentinel()

fn hashok(a: abi::bytes::MutableBytes, b: abi::bytes::MutableBytes) -> bool:
    if a == b:
        hash(a) == hash(b)
    else:
        true

}

# {PROGRAM-TEXT EXPECTED-LIST VALUE-COUNT} of one random script of ITEMS
# definitions.
proc pureScript {items} {
    set lines {}
    set values [dict create]   ;# vK -> bytes
    set snaps {}               ;# {NAME BYTES}
    set count 0
    proc newName {} { upvar 1 count count; return v[incr count] }
    for {set i 0} {$i < $items} {incr i} {
        set names [dict keys $values]
        set op [expr {[llength $names] == 0 ? "fresh" : [pick {fresh copy set set set set set identity list struct detach reuse snap snap prefix prefix}]}]
        switch -- $op {
            fresh {
                set spec [randomSpec]
                set name [newName]
                lappend lines "$name = mbf(abi::bytes::from_list([specSource $spec]))"
                dict set values $name [renderSpec $spec]
            }
            copy {
                set k [pick $names]
                set name [newName]
                lappend lines "$name = $k"
                dict set values $name [dict get $values $k]
            }
            set {
                set k [pick $names]
                set bytes [dict get $values $k]
                set len [llength $bytes]
                set idx [expr {rand() < 0.15 ? [pick [list -2 -1 $len [expr {$len + 1}] 1000]] : ($len > 0 ? int(rand() * $len) : 0)}]
                set b [expr {int(rand() * 256)}]
                set name [newName]
                lappend lines "$name = put($k, $idx, byte::from_int($b))"
                if {$idx >= 0 && $idx < $len} { set bytes [lreplace $bytes $idx $idx $b] }
                dict set values $name $bytes
            }
            identity {
                set k [pick $names]
                set name [newName]
                lappend lines "$name = idg($k)"
                dict set values $name [dict get $values $k]
            }
            list {
                set k [pick $names]
                set j [pick $names]
                set name [newName]
                lappend lines "$name = first(\[$k, $j\])"
                dict set values $name [dict get $values $k]
            }
            struct {
                set k [pick $names]
                set name [newName]
                lappend lines "$name = unwrap(Holder {data: $k})"
                dict set values $name [dict get $values $k]
            }
            detach {
                set k [pick $names]
                set name [newName]
                lappend lines "$name = abi::bytes::detach($k)"
                dict set values $name [dict get $values $k]
            }
            reuse {
                set k [pick $names]
                set bytes [dict get $values $k]
                set len [llength $bytes]
                set name [newName]
                set b1 [expr {int(rand() * 256)}]
                set b2 [expr {int(rand() * 256)}]
                set i1 [expr {$len > 0 ? int(rand() * $len) : 0}]
                set i2 [expr {$len > 0 ? int(rand() * $len) : 0}]
                lappend lines "$name = put(put($k, $i1, byte::from_int($b1)), $i2, byte::from_int($b2))"
                if {$len > 0} {
                    set bytes [lreplace $bytes $i1 $i1 $b1]
                    set bytes [lreplace $bytes $i2 $i2 $b2]
                }
                dict set values $name $bytes
            }
            snap {
                set k [pick $names]
                set name f[incr count]
                lappend lines "$name = abi::bytes::freeze($k)"
                lappend snaps [list $name [dict get $values $k]]
            }
            prefix {
                set k [pick $names]
                set bytes [dict get $values $k]
                set len [llength $bytes]
                set n [expr {rand() < 0.2 ? $len + 1 + int(rand() * 5) : ($len > 0 ? int(rand() * ($len + 1)) : 0)}]
                set name p[incr count]
                lappend lines "$name = pre($k, $n)"
                if {$n > $len} {
                    lappend snaps [list $name [binary scan OVER cu* sent; set sent]]
                } else {
                    lappend snaps [list $name [lrange $bytes 0 [expr {$n - 1}]]]
                }
            }
        }
    }
    # The result: every variable's and snapshot's contents at the END, then
    # equality / hash checks between random pairs.
    set results {}
    set expected {}
    dict for {name bytes} $values {
        lappend results "abi::bytes::freeze($name)"
        lappend expected "abi::bytes::Bytes {storage: <bytes [llength $bytes]: [hexOf $bytes]>}"
    }
    foreach snap $snaps {
        lassign $snap name bytes
        lappend results $name
        lappend expected "abi::bytes::Bytes {storage: <bytes [llength $bytes]: [hexOf $bytes]>}"
    }
    set names [dict keys $values]
    for {set i 0} {$i < 6} {incr i} {
        set a [pick $names]
        set b [pick $names]
        lappend results "$a == $b" "hashok($a, $b)"
        lappend expected [boolWord [expr {[dict get $values $a] eq [dict get $values $b]}]] true
    }
    set text "import abi\nimport abi::bytes\nimport byte\nimport list\nimport str\nimport type byte::Byte\n\n$::genFunctions\n$::pureHelpers\n[join $lines \n]\n\[[join $results {, }]\]\n"
    return [list $text $expected [dict size $values]]
}

# ---------------------------------------------------------------------------
# read (native)

proc readCapacity {} {
    set sizes {0 1 2 3 7 8 9 15 16 17 31 32 33 64 100 255 256 600}
    if {rand() < 0.75} { return [pick $sizes] }
    return [expr {1 + int(rand() * 700)}]
}

proc fillText {cap} {
    set alphabet {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
    set s ""
    for {set i 0} {$i < $cap} {incr i} { append s [pick $alphabet] }
    return $s
}

set readPrelude {import abi
import abi::bytes
import byte
import linux
import str

fn mbs(s: str) -> abi::bytes::MutableBytes:
    abi::bytes::from_bytes(abi::bytes::from_list(str::encode_utf8(s)))

fn out(fd: int, data: abi::bytes::Bytes) -> int errors abi::AbiIntegerBelowRange, abi::AbiIntegerAboveRange:
    linux::write(abi::i32(fd), data)

fn rd(fd: int, data: abi::bytes::MutableBytes) -> linux::ReadResult errors abi::AbiIntegerBelowRange, abi::AbiIntegerAboveRange:
    linux::read(abi::i32(fd), data)

}

# {PROGRAM FILL-TEXTS} reading once per capacity in CAPS, in order.
proc readProgram {caps} {
    set lets {}
    set results {}
    set fills {}
    set i 0
    foreach cap $caps {
        set fill [fillText $cap]
        lappend fills $fill
        append lets "b$i = mbs([textLiteral $fill])\n"
        append lets "r$i = rd(0, b$i)\n"
        append lets "w$i = out(3, abi::bytes::freeze(r$i.data))\n"
        append lets "x$i = out(4, abi::bytes::freeze(b$i))\n"
        lappend results "r$i.result"
        incr i
    }
    return [list "$::readPrelude\n${lets}\[[join $results {, }]\]\n" $fills]
}

proc runReadFile {exe input stress} {
    set f0 [file join $::scratch fd0.[incr ::counter]]
    set f3 [file join $::scratch fd3.$::counter]
    set f4 [file join $::scratch fd4.$::counter]
    set rest [file join $::scratch rest.$::counter]
    set channel [open $f0 wb]; puts -nonewline $channel $input; close $channel
    set saved [expr {[info exists ::env(BOTLISH_NATIVE_GC_STRESS)] ? $::env(BOTLISH_NATIVE_GC_STRESS) : ""}]
    if {$stress} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
    set printed [exec sh -c {{ "$0" 3>"$2" 4>"$3"; cat >"$4"; } <"$1"} $exe $f0 $f3 $f4 $rest]
    if {$stress && !$::gcStress} { unset ::env(BOTLISH_NATIVE_GC_STRESS) }
    set got {}
    foreach f [list $f3 $f4 $rest] {
        set channel [open $f rb]; lappend got [read $channel]; close $channel
        file delete $f
    }
    file delete $f0
    return [list [string trim $printed] {*}$got]
}

proc runReadPipe {exe input stress} {
    set f3 [file join $::scratch fd3.[incr ::counter]]
    set f4 [file join $::scratch fd4.$::counter]
    set command [list sh -c {exec "$0" 3>"$1" 4>"$2"} $exe $f3 $f4]
    if {$stress} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
    set pipe [open |$command r+b]
    puts -nonewline $pipe $input
    chan close $pipe write
    set printed [read $pipe]
    close $pipe
    if {$stress && !$::gcStress} { unset ::env(BOTLISH_NATIVE_GC_STRESS) }
    set got {}
    foreach f [list $f3 $f4] {
        set channel [open $f rb]; lappend got [read $channel]; close $channel
        file delete $f
    }
    return [list [string trim $printed] {*}$got]
}

# What the sequential reads of CAPS over INPUT must produce: {RESULTS
# FILE3 FILE4 REST}. FILE3 holds each returned buffer (the bytes read, then
# the untouched suffix of the fill), FILE4 each caller's own buffer.
proc readOracle {caps fills input} {
    set offset 0
    set total [string length $input]
    set results {}
    set f3 ""
    set f4 ""
    foreach cap $caps fill $fills {
        set n [expr {min($cap, $total - $offset)}]
        lappend results $n
        set chunk [string range $input $offset [expr {$offset + $n - 1}]]
        append f3 $chunk [string range $fill $n end]
        append f4 $fill
        incr offset $n
    }
    return [list "\[[join $results {, }]\]" $f3 $f4 [string range $input $offset end]]
}

set failures 0
set values 0
try {
    for {set p 0} {$p < $n} {incr p} {
        set seed [expr {$seed0 + $p}]
        expr {srand($seed)}

        if {$mode in {pure both}} {
            lassign [pureScript $items] text expected count
            incr values $count
            set hir [hirOfText $text]
            foreach backend $backends {
                set outcome [outcomeUnderHir $backend $hir]
                set ok 0
                set detail [string range $outcome 0 300]
                if {[lindex $outcome 0] eq "value"} {
                    set parts [splitShown [lindex $outcome 1]]
                    set ok [expr {[llength $parts] == [llength $expected]}]
                    if {!$ok} {
                        set detail "slot count [llength $parts], want [llength $expected]"
                    } else {
                        set slot 0
                        foreach part $parts want $expected {
                            if {$part ne $want} {
                                set ok 0
                                set detail "slot $slot differs: got [string range $part 0 160] / want [string range $want 0 160]"
                                break
                            }
                            incr slot
                        }
                    }
                }
                if {!$ok} {
                    incr failures
                    puts "FAIL seed $seed pure $backend: $detail"
                }
            }
        }

        if {$mode in {read both}} {
            # (1) several sequential reads from one open file
            set caps {}
            for {set k 0} {$k < 3} {incr k} { lappend caps [readCapacity] }
            lassign [readProgram $caps] text fills
            set input [binaryOf [renderSpec [randomSpec]]]
            set exe [file join $scratch exe.$p]
            native::executable [hirOfText $text] $exe
            lassign [readOracle $caps $fills $input] wantResults want3 want4 wantRest
            foreach stress {0 1} {
                lassign [runReadFile $exe $input $stress] printed got3 got4 gotRest
                if {$printed ne $wantResults || $got3 ne $want3 || $got4 ne $want4 || $gotRest ne $wantRest} {
                    incr failures
                    puts "FAIL seed $seed read-file stress=$stress caps=$caps: printed $printed want $wantResults; returned buffers [expr {$got3 eq $want3 ? {ok} : {WRONG}}]; callers' buffers [expr {$got4 eq $want4 ? {ok} : {WRONG}}]; remaining input [expr {$gotRest eq $wantRest ? {ok} : {WRONG}}]"
                }
            }
            incr values [llength $caps]

            # (2) one read from a real pipe
            set cap [readCapacity]
            lassign [readProgram [list $cap]] text fills
            set pipeInput [string range [binaryOf [renderSpec [randomSpec]]] 0 3999]
            set pipeExe [file join $scratch pexe.$p]
            native::executable [hirOfText $text] $pipeExe
            lassign [readOracle [list $cap] $fills $pipeInput] wantResults want3 want4 -
            foreach stress {0 1} {
                lassign [runReadPipe $pipeExe $pipeInput $stress] printed got3 got4
                if {$printed ne $wantResults || $got3 ne $want3 || $got4 ne $want4} {
                    incr failures
                    puts "FAIL seed $seed read-pipe stress=$stress cap=$cap input=[string length $pipeInput]: printed $printed want $wantResults; returned [expr {$got3 eq $want3 ? {ok} : {WRONG}}]; caller's [expr {$got4 eq $want4 ? {ok} : {WRONG}}]"
                }
            }
            incr values
            file delete $exe $pipeExe
        }
    }
} finally {
    file delete -force $scratch
}
puts "mutable-bytes-fuzz programs $n values $values failures $failures"
exit [expr {$failures ? 1 : 0}]
