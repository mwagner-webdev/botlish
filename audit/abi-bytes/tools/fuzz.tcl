#!/usr/bin/env tclsh9.0
# fuzz.tcl -- randomized differential check of abi::Bytes and linux::write
# (ABI-BYTES.md).
#
#   tclsh9.0 audit/abi-bytes/tools/fuzz.tcl ?-mode pure|write|both? ?-n N?
#       ?-seed S? ?-items K? ?-backends LIST? ?-gc-stress 0|1?
#
# pure   (every semantic backend: interp, compile, cranelift-generic,
#         cranelift; no syscall is made)
#   Each program (seeded individually: a failure replays with `-seed S -n 1`)
#   draws K random byte sequences biased toward the shapes that matter -- the
#   empty sequence, one byte, the small sizes around 7/8/9, 15/16/17 and
#   31/32/33 (where a small inline representation would end and a heap
#   buffer begin), embedded zeros, 0xff and the high half, ASCII, arbitrary
#   8-bit data, repeated patterns, and larger buffers up to a few thousand
#   bytes -- builds each as a List[Byte], and checks against an independent Tcl
#   byte-sequence oracle:
#       length          abi::bytes_length(abi::bytes(L)).value == |L|
#       contents        the explicit internal reveal of the Bytes itself shows
#                       exactly the oracle's hex (every byte, in order)
#       construction    two Bytes built separately from equal Lists are equal
#                       and hash equal; one built from a mutated List (one
#                       byte changed, the last byte dropped, a byte appended,
#                       a zero appended) is unequal
#       aliasing        b = a: a == b and [a, b] == [b, a], holding in a List
#   The reveal string of the whole result must be identical on every backend.
#
# write  (native only, Linux x86-64; the only syscall made is write(2) to a
#         temp file and to a pipe the harness reads, never a fuzzed number)
#   Each program writes its K generated payloads (as separate abi::Bytes, plus
#   one aliased value written twice) to descriptor 3 (a file) and descriptor 4
#   (a pipe whose other end this process reads), one linux::write each, and
#   checks that the bytes the kernel received are exactly the concatenation
#   the oracle expects and that every returned count is the payload's length --
#   in a normal run and under GC stress.
#
# Ends with "abi-bytes-fuzz programs N payloads P failures F"; exit status 1
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
set items 8
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

set scratch [file tempdir abi-bytes-fuzz]
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
# Generators. A byte sequence is a Tcl list of integers 0..255, described by a
# SPEC the Botlish program and the Tcl oracle both evaluate the same way:
#
#   {gen KIND N T A B C K D}   N formula bytes then T zero bytes, where formula
#                              byte i is a function of POLY(i) = A*i*i + B*i + C
#                              (plus D at index K), by KIND:
#                                full     mod(POLY, 256)
#                                ascii    32 + mod(POLY, 95)
#                                high     128 + mod(POLY, 128)
#                                zeros    0 where mod(POLY, 3) == 0, else mod(POLY, 256)
#                                ffs      255 where mod(POLY, 3) == 0, else mod(POLY, 256)
#   {utf8 TEXT}                the UTF-8 encoding of TEXT
#
# so a program carries no per-byte source (one call per sequence), and the
# oracle never reads what the program computes.

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
        set idx [expr {int(rand() * $n)}]
        # a change that really changes the byte: +1 on a full/zeros/ffs byte
        # of a different value is checked by the oracle itself
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

# ---------------------------------------------------------------------------
# pure

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

proc pureProgram {specs} {
    set lets {}
    set results {}
    set i 0
    foreach spec $specs {
        set source [specSource $spec]
        append lets "a$i = abi::bytes($source)\n"
        append lets "c$i = abi::bytes($source)\n"
        append lets "b$i = a$i\n"
        set diffs {}
        set j 0
        foreach m [mutantSpecs $spec] {
            append lets "m${i}_$j = abi::bytes([specSource $m])\n"
            lappend diffs "a$i == m${i}_$j"
            incr j
        }
        lappend results "abi::bytes_length(a$i).value" "a$i" "a$i == c$i" "hash(a$i) == hash(c$i)" \
            "a$i == b$i" "\[a$i, b$i\] == \[b$i, a$i\]" {*}$diffs
        if {$i > 0} {
            lappend results "a$i == a[expr {$i - 1}]" "(hash(a$i) == hash(a[expr {$i - 1}]))"
        }
        incr i
    }
    return "import abi\nimport byte\nimport str\n\n$::genFunctions\n${lets}\[[join $results {, }]\]\n"
}

proc boolWord {v} { return [expr {$v ? "true" : "false"}] }

proc pureExpected {specs} {
    set results {}
    set previous ""
    set i 0
    foreach spec $specs {
        set bytes [renderSpec $spec]
        lappend results [llength $bytes] "abi::Bytes {storage: <bytes [llength $bytes]: [hexOf $bytes]>}" true true true true
        foreach m [mutantSpecs $spec] {
            # The mutant is unequal by construction unless the rendered bytes
            # happen to coincide: the oracle compares them.
            lappend results [boolWord [expr {[renderSpec $m] eq $bytes}]]
        }
        if {$i > 0} {
            lappend results [boolWord [expr {$bytes eq $previous}]]
            # hash(a) == hash(prev) is only required when equal; when unequal
            # it is almost surely false, but a collision is possible in
            # principle: the harness treats this slot as "equal implies true"
            lappend results [expr {$bytes eq $previous ? "true" : "?"}]
        }
        set previous $bytes
        incr i
    }
    return $results
}

# ---------------------------------------------------------------------------
# write (native)

proc writeProgram {specs} {
    set lets {}
    set results {}
    set i 0
    foreach spec $specs {
        append lets "d$i = abi::bytes([specSource $spec])\n"
        lappend results "out([expr {3 + $i % 2}], d$i)"
        incr i
    }
    # an aliased value written twice, to both descriptors
    append lets "alias = d0\n"
    lappend results "out(3, alias)" "out(4, alias)"
    return "import abi
import byte
import linux
import str

$::genFunctions
fn out(fd: int, data: abi::Bytes) -> int errors AbiIntegerBelowRange, AbiIntegerAboveRange:
    linux::write(abi::i32(fd), data)

${lets}\[[join $results {, }]\]\n"
}

proc runWrite {exe stress} {
    set f3 [file join $::scratch fd3.[incr ::counter]]
    set command [list sh -c {exec "$0" 3>"$1" 4>&1 1>/dev/null} $exe $f3]
    if {$stress} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
    set pipe [open |$command rb]
    set pipeData [read $pipe]
    close $pipe
    if {$stress && !$::gcStress} { unset ::env(BOTLISH_NATIVE_GC_STRESS) }
    set channel [open $f3 rb]
    set fileData [read $channel]
    close $channel
    file delete $f3
    return [list $fileData $pipeData]
}

proc binaryOf {bytes} {
    if {$bytes eq ""} { return "" }
    return [binary format c* $bytes]
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

set failures 0
set payloads 0
try {
    for {set p 0} {$p < $n} {incr p} {
        set seed [expr {$seed0 + $p}]
        expr {srand($seed)}
        set specs {}
        for {set k 0} {$k < $items} {incr k} { lappend specs [randomSpec] }
        incr payloads $items

        if {$mode in {pure both}} {
            set hir [hirOfText [pureProgram $specs]]
            set expected [pureExpected $specs]
            foreach backend $backends {
                set outcome [outcomeUnderHir $backend $hir]
                set ok 0
                if {[lindex $outcome 0] eq "value"} {
                    set got [lindex $outcome 1]
                    # split the shown list "[a, b, ...]" at top-level ", " (the
                    # reveal strings contain no commas at that level except
                    # inside braces)
                    set parts [splitShown $got]
                    set ok [expr {[llength $parts] == [llength $expected]}]
                    if {$ok} {
                        foreach part $parts want $expected {
                            if {$want eq "?"} { continue }
                            if {$part ne $want} { set ok 0; break }
                        }
                    }
                    # a "?" slot (hash of unequal values) must still be a Bool
                    if {$ok} {
                        foreach part $parts want $expected {
                            if {$want eq "?" && $part ni {true false}} { set ok 0 }
                        }
                    }
                }
                if {!$ok} {
                    incr failures
                    puts "FAIL seed $seed pure $backend: [string range $outcome 0 500]"
                }
            }
        }

        if {$mode in {write both}} {
            set hir [hirOfText [writeProgram $specs]]
            set exe [file join $scratch exe.$p]
            native::executable $hir $exe
            set want3 {}
            set want4 {}
            set i 0
            foreach spec $specs {
                set bytes [renderSpec $spec]
                if {$i % 2 == 0} { append want3 [binaryOf $bytes] } else { append want4 [binaryOf $bytes] }
                incr i
            }
            set first [renderSpec [lindex $specs 0]]
            append want3 [binaryOf $first]
            append want4 [binaryOf $first]
            foreach stress {0 1} {
                lassign [runWrite $exe $stress] got3 got4
                if {$got3 ne $want3 || $got4 ne $want4} {
                    incr failures
                    puts "FAIL seed $seed write stress=$stress: file [string length $got3]/[string length $want3] bytes, pipe [string length $got4]/[string length $want4] bytes"
                }
            }
            # The counts the program reports (its own result line): run it
            # once with 3 and 4 redirected and read the printed list.
            set f3 [file join $scratch counts.[incr counter]]
            set printed [exec sh -c {exec "$0" 3>"$1" 4>>"$1"} $exe $f3]
            file delete $f3
            set wantCounts {}
            foreach spec $specs { lappend wantCounts [llength [renderSpec $spec]] }
            lappend wantCounts [llength $first] [llength $first]
            if {$printed ne "\[[join $wantCounts {, }]\]"} {
                incr failures
                puts "FAIL seed $seed write counts: got $printed, want \[[join $wantCounts {, }]\]"
            }
            file delete $exe
        }
    }
} finally {
    file delete -force $scratch
}
puts "abi-bytes-fuzz programs $n payloads $payloads failures $failures"
exit [expr {$failures ? 1 : 0}]
