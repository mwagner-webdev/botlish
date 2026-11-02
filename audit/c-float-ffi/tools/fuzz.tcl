# fuzz.tcl -- a fuzzer of C float and C double across the FFI
# (C-FLOAT-FFI-MILESTONE-1.md, "Fuzzing").
#
#   tclsh9.0 audit/c-float-ffi/tools/fuzz.tcl ?-n N? ?-seed S? ?-functions K?
#                                             ?-layouts L? ?-gc-stress 0|1?
#                                             ?-backends LIST? ?-keep 0|1?
#                                             ?-verbose 0|1? ?-raw 0|1?
#
# Each of N programs has two halves, each checked against this file's own
# model -- IEEE 754 rounding written with integer arithmetic on the bits,
# never a floating-point conversion of Tcl's, the compiler's or C's:
#
#   * K random C functions, generated as real C (a static archive in a
#     private directory) and declared with `extern c fn`: up to fourteen
#     parameters, C floats, C doubles and C integers interleaved (past every
#     target's floating-point argument registers), a float, double or int
#     result whose bits the call names (an argument, so C returns NaN of any
#     payload, an infinity, negative zero, subnormals). C records the bits it
#     received and counts its calls. Each call's arguments are random
#     Float64s -- binary32 ties and subnormal midpoints, values a float
#     cannot hold, tiny negative numbers, values at and past the binary32
#     overflow threshold -- written as literals (decided at compile time) or
#     hidden behind a recursion (decided when the call runs). The model
#     says, per call: NonFiniteFloat before C runs (the first argument that
#     overflows a float, with its sign: C's count unchanged) or after it (a
#     NaN or an infinity C returned: the count advanced), else the exact bits
#     C received for every argument and the exact Float64 of the result. Run
#     on both native backends (BACKENDS' native ones).
#   * L random layouts of C floats, C doubles and integers at their C
#     offsets, as bytes: random byte storage parsed (a float or double field
#     holding a NaN or an infinity is NonFiniteFloat), random Float64s
#     written into each field (a float rounded, an overflow NonFiniteFloat)
#     and the record emitted -- run on every backend of BACKENDS (all four by
#     default), the Float64s read out as the bytes of a double, so the
#     comparison is of integers.
#
# With -raw 1 (the default) parameters, results and layout fields are
# sometimes std::ffi::c::RawFloat or std::ffi::c::RawDouble
# (RAW-C-FLOAT-FFI-MILESTONE-1.md): a raw argument is any bit pattern (NaN
# payloads, signaling NaNs, the infinities, negative zero, subnormals) made
# with std::ffi::c::raw's float_from_bits or double_from_bits, and the model
# expects exactly those bits in C, exactly C's bits in a raw result (read with
# float_to_bits or double_to_bits) and in a raw field, and never
# NonFiniteFloat for a raw position. -raw 0 draws exactly the programs of
# C-FLOAT-FFI-MILESTONE-1.md's generator.
#
# The last line is "programs N calls C layouts L disagreements X" (the exit
# status is 1 on any); every disagreement is printed with its directory,
# kept unless -keep is 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 6 -seed 1 -functions 8 -layouts 4 -gc-stress 0 \
    -backends {interp compile cranelift-generic cranelift} -keep 1 -verbose 0 -raw 1]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc between {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# A finite C floating spelling T (float, double, or their layout types) made
# raw with probability 0.3 when -raw is on; without it no random number is
# drawn, so -raw 0 keeps the milestone-1 generator's streams.
proc maybeRaw {t} {
    if {![dict get $::options -raw] || ![chance 0.3]} { return $t }
    return [dict get {float rawfloat double rawdouble std::ffi::c::Float std::ffi::c::RawFloat std::ffi::c::Double std::ffi::c::RawDouble} $t]
}

# ---------------------------------------------------------------------------
# The model

# The binary64 bits of the double X, and the double of bits B.
proc bits64 {x} {
    binary scan [binary format q $x] wu bits
    return $bits
}
proc double64 {b} {
    binary scan [binary format wu $b] q x
    return $x
}

# The bits of the binary32 nearest the finite double X, rounded to nearest,
# ties to even, by integer arithmetic on X's bits (a zero of either sign is
# +0), or {overflow SIGN} when it rounds to an infinity (SIGN 1 negative).
proc narrow32 {x} {
    set bits [bits64 $x]
    set negative [expr {$bits >> 63}]
    set e [expr {($bits >> 52) & 0x7ff}]
    set f [expr {$bits & 0xfffffffffffff}]
    if {$e == 0} {
        set m $f
        set exp -1074
    } else {
        set m [expr {$f | (1 << 52)}]
        set exp [expr {$e - 1075}]
    }
    if {$m == 0} { return 0 }
    set length 0
    for {set t $m} {$t > 0} {set t [expr {$t >> 1}]} { set length [expr {$length + 1}] }
    set q [expr {max($exp + $length - 1 - 23, -149)}]
    set shift [expr {$q - $exp}]
    if {$shift <= 0} {
        set k [expr {$m << -$shift}]
    } else {
        set k [expr {$m >> $shift}]
        set rest [expr {$m - ($k << $shift)}]
        set half [expr {1 << ($shift - 1)}]
        if {$rest > $half || ($rest == $half && ($k & 1))} { set k [expr {$k + 1}] }
    }
    if {$k == (1 << 24)} {
        set k [expr {1 << 23}]
        set q [expr {$q + 1}]
    }
    if {$k == 0} { return 0 }
    if {$q > 104} { return [list overflow $negative] }
    set out [expr {$k < (1 << 23) ? $k : ((($q + 150) << 23) | ($k - (1 << 23)))}]
    return [expr {($negative << 31) | $out}]
}

# The admission of the binary32 (WIDTH 32) or binary64 (64) bits B: {value
# BITS64} (the exact Float64's bits; negative zero is zero) or {error KIND}
# (1 NotANumber, 2 PositiveInfinity, 3 NegativeInfinity).
proc admit {width b} {
    if {$width == 32} {
        set sign [expr {$b >> 31}]
        set e [expr {($b >> 23) & 0xff}]
        set f [expr {$b & 0x7fffff}]
        if {$e == 0xff} {
            return [list error [expr {$f != 0 ? 1 : ($sign ? 3 : 2)}]]
        }
        if {$e == 0 && $f == 0} { return {value 0} }
        # Widening is exact: the same sign, the exponent rebiased, the
        # significand shifted (a subnormal normalized).
        if {$e == 0} {
            set shift 0
            while {!($f & 0x800000)} {
                set f [expr {$f << 1}]
                incr shift
            }
            set f [expr {$f & 0x7fffff}]
            set e64 [expr {1 - $shift - 127 + 1023}]
        } else {
            set e64 [expr {$e - 127 + 1023}]
        }
        return [list value [expr {($sign << 63) | ($e64 << 52) | ($f << 29)}]]
    }
    set sign [expr {$b >> 63}]
    set e [expr {($b >> 52) & 0x7ff}]
    set f [expr {$b & 0xfffffffffffff}]
    if {$e == 0x7ff} {
        return [list error [expr {$f != 0 ? 1 : ($sign ? 3 : 2)}]]
    }
    if {$e == 0 && $f == 0} { return {value 0} }
    return [list value $b]
}

# A random finite Float64 for an argument or a write: binary32 ties and
# their neighbours, subnormal binary32 midpoints, values a float cannot hold
# exactly, tiny negative numbers, values around the overflow threshold
# (2^128 - 2^103) of either sign, arbitrary ones.
proc floatingValue {} {
    switch -- [between 0 7] {
        0 { set x [pick {0.1 0.3333333333333333 16777217.0 1.0000000596046448 1.0000001788139343 1.401298464324817e-45 7.006492321624085e-46 2.1019476964872256e-45 1.0e-40 -1.0e-50 0.0 3.4028234663852886e38 3.4028235677973366e38 3.402823567797336e38 1.0e39 1.0e300}] }
        1 { set x [expr {((1 << 23) | ([between 0 4194303] << 1) | 1) * 2.0 ** ([between -150 103]) * 0.5}] }
        2 { set x [expr {([between 0 63] + 0.5) * 2.0 ** -149 + [between -1 1] * 2.0 ** -170}] }
        3 { set x [expr {340282356779733661637539395458142568448.0 + [between -4 4] * 2.0 ** 103}] }
        default { set x [expr {(rand() - 0.5) * 2.0 ** [between -150 130]}] }
    }
    if {[chance 0.4]} { set x [expr {-$x}] }
    if {$x == 0} { set x 0.0 }
    return $x
}

# A random bit pattern for a C value of WIDTH bits: with probability
# NONFINITE a NaN of any payload or an infinity, else negative zero, a
# subnormal or a normal value.
proc resultBits {width {nonfinite 0.3}} {
    set m [expr {$width == 32 ? 23 : 52}]
    set ebits [expr {$width == 32 ? 8 : 11}]
    set emax [expr {(1 << $ebits) - 1}]
    set sign [expr {[chance 0.5] << ($width - 1)}]
    if {[chance $nonfinite]} {
        if {[chance 0.5]} {
            return [expr {$sign | ($emax << $m) | [between 1 [expr {(1 << $m) - 1}]]}]
        }
        return [expr {$sign | ($emax << $m)}]
    }
    switch -- [between 0 4] {
        0 { return $sign }
        1 { return [expr {$sign | [between 1 [expr {(1 << $m) - 1}]]}] }
        default { return [expr {$sign | ([between 1 [expr {$emax - 1}]] << $m) | entier(rand() * (1 << $m))}] }
    }
}

# A Float64 a float cannot hold: at or past the binary32 overflow threshold
# (2^128 - 2^103), of either sign.
proc overflowingValue {} {
    set x [pick [list 340282356779733661637539395458142568448.0 [expr {340282356779733661637539395458142568448.0 + [between 1 1000] * 2.0 ** 90}] 1.0e39 1.0e300]]
    if {[chance 0.5]} { set x [expr {-$x}] }
    return $x
}

# A Float64 literal of X (exact: seventeen significant digits).
proc literal {x} {
    return [format %.16e $x]
}

# ---------------------------------------------------------------------------
# The C functions

# Draws program P's K functions: each {name params result rpos}, a
# parameter a C spelling (float, double, int, long long) or rawfloat or
# rawdouble (a C float or double declared raw), RPOS the position
# of the unsigned long long naming the result's bits.
proc drawFunctions {k} {
    set out {}
    for {set i 0} {$i < $k} {incr i} {
        set params {}
        for {set j 0} {$j < [pick [list 0 1 2 3 [between 4 8] [between 9 14]]]} {incr j} {
            set p [pick {float float double double int {long long}}]
            if {$p in {float double}} { set p [maybeRaw $p] }
            lappend params $p
        }
        set result [pick {float double int}]
        if {$result ne "int"} { set result [maybeRaw $result] }
        lappend out [dict create name ff_f$i params $params result $result rpos [between 0 [llength $params]]]
    }
    return $out
}

# The C source of FUNCTIONS.
proc cSource {functions} {
    set c "#include <stdint.h>\n#include <string.h>\n\nunsigned long long ff_seen\[16\];\nint ff_calls;\n"
    append c "unsigned long long ff_seen_at(int i) { return ff_seen\[i\]; }\nint ff_count(void) { return ff_calls; }\n"
    append c "unsigned long long ff_dbits(double x) { unsigned long long u; memcpy(&u, &x, 8); return u; }\n\n"
    foreach f $functions {
        set formals {}
        set body "    ff_calls++;\n"
        set j 0
        set k 0
        foreach p [dict get $f params] {
            if {$k == [dict get $f rpos]} { lappend formals "unsigned long long rbits" }
            lappend formals "[cType $p] a$j"
            switch -- $p {
                float - rawfloat { append body "    { uint32_t u; memcpy(&u, &a$j, 4); ff_seen\[$j\] = u; }\n" }
                double - rawdouble { append body "    memcpy(&ff_seen\[$j\], &a$j, 8);\n" }
                default { append body "    ff_seen\[$j\] = (unsigned long long)a$j;\n" }
            }
            incr j
            incr k
        }
        if {[dict get $f rpos] == [llength [dict get $f params]]} { lappend formals "unsigned long long rbits" }
        switch -- [dict get $f result] {
            float - rawfloat { append body "    { uint32_t u = (uint32_t)rbits; float r; memcpy(&r, &u, 4); return r; }\n" }
            double - rawdouble { append body "    { double r; memcpy(&r, &rbits, 8); return r; }\n" }
            int { append body "    return (int)(rbits % 100000);\n" }
        }
        append c "[cType [dict get $f result]] [dict get $f name]([join $formals {, }]) {\n$body}\n"
    }
    return $c
}

# The C spelling of a drawn type: a raw one is C's float or double.
proc cType {t} {
    return [dict getdef {rawfloat float rawdouble double} $t $t]
}

# The import of std::ffi::c::raw, when -raw is on.
proc rawImport {} {
    if {[dict get $::options -raw]} { return "import std::ffi::c::raw\n" }
    return ""
}

# The Botlish spelling of a C parameter type.
proc ffiType {c} {
    return [dict get {float std::ffi::c::Float double std::ffi::c::Double rawfloat std::ffi::c::RawFloat rawdouble std::ffi::c::RawDouble int std::ffi::c::Int {long long} std::ffi::c::LongLong unsigned std::ffi::c::ULongLong} $c]
}

# The program calling every function of FUNCTIONS once, and the model's
# value of it.
proc callProgram {functions} {
    set text "import std::ffi::c\n[rawImport]extern c library \"botlish_cfloat_fuzz\"\n"
    append text "extern c fn seen_at named \"ff_seen_at\"(i: std::ffi::c::Int) -> std::ffi::c::ULongLong\n"
    append text "extern c fn count named \"ff_count\"() -> std::ffi::c::Int\n"
    append text "extern c fn dbits named \"ff_dbits\"(x: std::ffi::c::Double) -> std::ffi::c::ULongLong\n"
    foreach f $functions {
        set formals {}
        set j 0
        foreach p [dict get $f params] {
            if {$j == [dict get $f rpos]} { lappend formals "rbits: std::ffi::c::ULongLong" }
            lappend formals "a$j: [ffiType $p]"
            incr j
        }
        if {[dict get $f rpos] == [llength [dict get $f params]]} { lappend formals "rbits: std::ffi::c::ULongLong" }
        append text "extern c fn [dict get $f name]([join $formals {, }]) -> [ffiType [dict get $f result]]\n"
    }
    append text "fn hide(x: Float64, n: int) -> Float64:\n    if n == 0:\n        x\n    else:\n        hide(x, n - 1)\n"
    append text "fn kind(r: NonFiniteResult) -> int:\n    if r == NonFiniteResult::NotANumber:\n        1\n    elif r == NonFiniteResult::PositiveInfinity:\n        2\n    else:\n        3\n"
    set calls {}
    set model {}
    set i 0
    foreach f $functions {
        set width [dict get {float 32 double 64 rawfloat 32 rawdouble 64 int 0} [dict get $f result]]
        set rbits [expr {$width ? [resultBits $width] : [between 0 1000000]}]
        set args {}
        set seen {}
        set before ""
        set j 0
        foreach p [dict get $f params] {
            if {$j == [dict get $f rpos]} { lappend args $rbits }
            switch -- $p {
                float - double {
                    set x [floatingValue]
                    if {$p eq "float"} {
                        set b [narrow32 $x]
                        if {[lindex $b 0] eq "overflow" && $before eq ""} {
                            set before [expr {[lindex $b 1] ? 3 : 2}]
                        }
                        lappend seen $b
                    } else {
                        lappend seen [bits64 $x]
                    }
                    # An overflow is always hidden: written as a literal the
                    # compiler decides it (KNOWN-ERROR, a rejection).
                    # (`if`, never expr's ?:, which reads the literal as a
                    # number: AGENTS.md.)
                    if {[lindex [narrow32 $x] 0] eq "overflow" || [chance 0.5]} {
                        lappend args "hide([literal $x], [between 0 3])"
                    } else {
                        lappend args [literal $x]
                    }
                }
                rawfloat - rawdouble {
                    # Any bit pattern, received by C exactly.
                    set w [expr {$p eq "rawfloat" ? 32 : 64}]
                    set b [resultBits $w 0.4]
                    lappend args "std::ffi::c::raw::[expr {$w == 32 ? "float" : "double"}]_from_bits($b)"
                    lappend seen $b
                }
                int {
                    set v [between -2147483648 2147483647]
                    lappend args $v
                    lappend seen [expr {$v % (2 ** 64)}]
                }
                default {
                    set v [between -9223372036854775807 9223372036854775807]
                    lappend args $v
                    lappend seen [expr {$v % (2 ** 64)}]
                }
            }
            incr j
        }
        if {[dict get $f rpos] == [llength [dict get $f params]]} { lappend args $rbits }
        set out [dict get {int r float dbits(r) double dbits(r) rawfloat std::ffi::c::raw::float_to_bits(r) rawdouble std::ffi::c::raw::double_to_bits(r)} [dict get $f result]]
        set reads [lmap k [lsearch -all [dict get $f params] *] {string cat "seen_at($k)"}]
        append text "fn call${i}() -> list:\n    before = count()\n"
        append text "    r = [dict get $f name]([join $args {, }]):\n        on NonFiniteFloat {result}:\n            return \[-kind(result), count() - before\]\n"
        append text "    \[$out, count() - before[expr {$reads eq {} ? "" : ", [join $reads {, }]"}]\]\n"
        lappend calls "call${i}()"
        if {$before ne ""} {
            lappend model "\[-$before, 0\]"
        } else {
            if {$width == 0} {
                set r [expr {$rbits % 100000}]
                set admitted [list value $r]
            } elseif {[dict get $f result] in {rawfloat rawdouble}} {
                # A raw result is C's bits, never admitted.
                set admitted [list value $rbits]
            } else {
                set admitted [admit $width $rbits]
            }
            if {[lindex $admitted 0] eq "error"} {
                lappend model "\[-[lindex $admitted 1], 1\]"
            } else {
                lappend model "\[[join [concat [list [lindex $admitted 1] 1] $seen] {, }]\]"
            }
        }
        incr i
    }
    append text "\[[join $calls {, }]\]\n"
    return [list $text "\[[join $model {, }]\]"]
}

# ---------------------------------------------------------------------------
# The layouts

# Draws a layout: fields {name type width offset} at their C offsets (each
# aligned to its width), a size rounded to the largest alignment.
proc drawLayout {} {
    set fields {}
    set at 0
    set align 1
    for {set i 0} {$i < [between 1 6]} {incr i} {
        set type [pick {std::ffi::c::Float std::ffi::c::Float std::ffi::c::Double std::ffi::c::Double std::ffi::c::UChar std::ffi::c::Int}]
        if {$type in {std::ffi::c::Float std::ffi::c::Double}} { set type [maybeRaw $type] }
        set width [dict get {std::ffi::c::Float 4 std::ffi::c::Double 8 std::ffi::c::RawFloat 4 std::ffi::c::RawDouble 8 std::ffi::c::UChar 1 std::ffi::c::Int 4} $type]
        set at [expr {($at + [between 0 1] * $width + $width - 1) / $width * $width}]
        lappend fields [dict create name f$i type $type width $width offset $at]
        set at [expr {$at + $width}]
        set align [expr {max($align, $width)}]
    }
    return [dict create fields $fields size [expr {($at + $align - 1) / $align * $align}] align $align]
}

# The little-endian bytes of the WIDTH-byte integer V.
proc le {v width} {
    return [lmap k [lsearch -all [lrepeat $width x] x] {expr {($v >> (8 * $k)) & 255}}]
}

# The program over layout L (named LN), and the model's value: the parse of
# random bytes (every field's double bits, or the error), each field written
# with a random Float64 (or an integer), and the emit of the record.
proc layoutProgram {l n} {
    set name L$n
    set text "layout $name:\n    size [dict get $l size]\n    align [dict get $l align]\n"
    foreach f [dict get $l fields] { append text "    field [dict get $f name]: [dict get $f type] at [dict get $f offset]\n" }
    # Random bytes, a float or double field sometimes a NaN or an infinity.
    set bytes [lrepeat [dict get $l size] 0]
    for {set k 0} {$k < [dict get $l size]} {incr k} { lset bytes $k [between 0 255] }
    set parsed {}
    set parseError ""
    foreach f [dict get $l fields] {
        set w [dict get $f width]
        switch -- [dict get $f type] {
            std::ffi::c::Float - std::ffi::c::Double {
                set b [resultBits [expr {8 * $w}] 0.1]
                set admitted [admit [expr {8 * $w}] $b]
                if {[lindex $admitted 0] eq "error" && $parseError eq ""} { set parseError [lindex $admitted 1] }
                lappend parsed [lindex $admitted 1]
            }
            std::ffi::c::RawFloat - std::ffi::c::RawDouble {
                # Any bits, read back exactly.
                set b [resultBits [expr {8 * $w}] 0.4]
                lappend parsed $b
            }
            std::ffi::c::UChar { set b [between 0 255]; lappend parsed $b }
            std::ffi::c::Int { set b [between -2147483648 2147483647]; lappend parsed $b; set b [expr {$b % (2 ** 32)}] }
        }
        set k [dict get $f offset]
        foreach byte [le $b $w] {
            lset bytes $k $byte
            incr k
        }
    }
    # Values to write and emit.
    set values {}
    set written {}
    set emitError ""
    foreach f [dict get $l fields] {
        switch -- [dict get $f type] {
            std::ffi::c::Float {
                set x [expr {[chance 0.2] ? [overflowingValue] : [floatingValue]}]
                set b [narrow32 $x]
                if {[lindex $b 0] eq "overflow"} {
                    if {$emitError eq ""} { set emitError [expr {[lindex $b 1] ? 3 : 2}] }
                    lappend written [list error [expr {[lindex $b 1] ? 3 : 2}]]
                } else {
                    lappend written [list bytes [le $b 4]]
                }
                lappend values "hide([literal $x], [between 0 2])"
            }
            std::ffi::c::Double {
                set x [floatingValue]
                lappend written [list bytes [le [bits64 $x] 8]]
                lappend values "hide([literal $x], [between 0 2])"
            }
            std::ffi::c::RawFloat - std::ffi::c::RawDouble {
                set w [dict get $f width]
                set b [resultBits [expr {8 * $w}] 0.4]
                lappend written [list bytes [le $b $w]]
                lappend values "std::ffi::c::raw::[expr {$w == 4 ? "float" : "double"}]_from_bits($b)"
            }
            std::ffi::c::UChar { set v [between 0 255]; lappend written [list bytes [le $v 1]]; lappend values $v }
            std::ffi::c::Int { set v [between -2147483648 2147483647]; lappend written [list bytes [le [expr {$v % (2 ** 32)}] 4]]; lappend values $v }
        }
    }
    set size [dict get $l size]
    append text "layout RAW$n:\n    size $size\n    align 1\n    field bs: array $size of std::binary::U8 at 0\n"
    append text "fn parse${n}() -> list errors LayoutLengthMismatch:\n    s = std::binary::parse($name, bytes_of(\[[join $bytes {, }]\])):\n        on NonFiniteFloat {result}:\n            return \[-kind(result)\]\n"
    set reads [lmap f [dict get $l fields] {
        switch -- [dict get $f type] {
            std::ffi::c::Float - std::ffi::c::Double { string cat "out(s." [dict get $f name] ")" }
            std::ffi::c::RawFloat { string cat "std::ffi::c::raw::float_to_bits(s." [dict get $f name] ")" }
            std::ffi::c::RawDouble { string cat "std::ffi::c::raw::double_to_bits(s." [dict get $f name] ")" }
            default { string cat "s." [dict get $f name] }
        }
    }]
    append text "    \[[join $reads {, }]\]\n"
    set model {}
    if {$parseError ne ""} {
        lappend model "\[-$parseError\]"
    } else {
        lappend model "\[[join [lmap f [dict get $l fields] v $parsed {expr {[dict get $f type] in {std::ffi::c::Float std::ffi::c::Double} ? "\[[join [le $v 8] {, }]\]" : $v}}] {, }]\]"
    }
    # Each field written into zeroed storage on its own.
    set writes {}
    set k 0
    foreach f [dict get $l fields] v $values w $written {
        append text "fn write${n}_${k}() -> list errors LayoutLengthMismatch:\n    m = std::binary::write(std::abi::bytes::zeroed(std::abi::usize($size)), $name.[dict get $f name], $v):\n        on NonFiniteFloat {result}:\n            return \[-kind(result)\]\n    std::binary::parse(RAW$n, std::abi::bytes::freeze(m)).bs\n"
        lappend writes "write${n}_${k}()"
        if {[lindex $w 0] eq "error"} {
            lappend model "\[-[lindex $w 1]\]"
        } else {
            set expect [lrepeat $size 0]
            set at [dict get $f offset]
            foreach byte [lindex $w 1] { lset expect $at $byte; incr at }
            lappend model "\[[join $expect {, }]\]"
        }
        incr k
    }
    # The whole record emitted.
    set inits [lmap f [dict get $l fields] v $values {string cat [dict get $f name] ": " $v}]
    append text "fn emit${n}() -> list errors LayoutLengthMismatch:\n    e = std::binary::emit(LayoutStruct\[$name\] {[join $inits {, }]}):\n        on NonFiniteFloat {result}:\n            return \[-kind(result)\]\n    std::binary::parse(RAW$n, e).bs\n"
    if {$emitError ne ""} {
        lappend model "\[-$emitError\]"
    } else {
        set expect [lrepeat $size 0]
        foreach f [dict get $l fields] w $written {
            set at [dict get $f offset]
            foreach byte [lindex $w 1] { lset expect $at $byte; incr at }
        }
        lappend model "\[[join $expect {, }]\]"
    }
    return [list $text [concat [list "parse${n}()"] $writes [list "emit${n}()"]] $model]
}

proc layoutsProgram {count} {
    set text "import std::abi\nimport std::abi::bytes\nimport std::binary\nimport std::byte\nimport std::ffi::c\n[rawImport]"
    append text "layout D8:\n    size 8\n    align 1\n    field d: std::ffi::c::Double at 0\n"
    append text "layout B8:\n    size 8\n    align 1\n    field bs: array 8 of std::binary::U8 at 0\n"
    # A Float64 as the bytes of a double: what the model compares.
    append text "fn out(x: Float64) -> list errors LayoutLengthMismatch:\n    std::binary::parse(B8, std::abi::bytes::freeze(std::binary::write(std::abi::bytes::zeroed(std::abi::usize(8)), D8.d, x))).bs\n"
    append text "fn hide(x: Float64, n: int) -> Float64:\n    if n == 0:\n        x\n    else:\n        hide(x, n - 1)\n"
    append text "fn kind(r: NonFiniteResult) -> int:\n    if r == NonFiniteResult::NotANumber:\n        1\n    elif r == NonFiniteResult::PositiveInfinity:\n        2\n    else:\n        3\n"
    append text "fn bytes_of(values: List\[int\]) -> std::abi::bytes::Bytes:\n    bs = loop v in values:\n        b = std::byte::from_int(v):\n            on std::byte::BelowRange:\n                0\n            on std::byte::AboveRange:\n                255\n        b\n    std::abi::bytes::from_list(bs)\n"
    set calls {}
    set model {}
    for {set n 0} {$n < $count} {incr n} {
        lassign [layoutProgram [drawLayout] $n] t c m
        append text $t
        lappend calls {*}$c
        lappend model {*}$m
    }
    append text "fn go() -> list errors LayoutLengthMismatch:\n    \[[join $calls {, }]\]\ngo():\n    on LayoutLengthMismatch:\n        \[\]\n"
    return [list $text "\[[join $model {, }]\]"]
}

# ---------------------------------------------------------------------------

proc writeFile {path text} {
    file mkdir [file dirname $path]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# The outcome text of HIR on BACKEND: the value, or "error KIND".
proc outcome {backend hir} {
    lassign [outcomeUnderHir $backend $hir] tag value message
    if {$tag eq "value"} { return $value }
    return "$tag $value $message"
}

expr {srand([dict get $options -seed])}
set scratch [file tempdir botlish-cfloat-fuzz-]
set programs 0
set callCount 0
set layoutCount 0
set disagreements 0
set native [lmap b [dict get $options -backends] {expr {$b in {cranelift cranelift-generic} ? $b : [continue]}}]
set canCall [expr {$native ne {} && [auto_execok cc] ne "" && ![catch {native::binary}]
    && [testConstraint nativeCCalls] && [testConstraint rustcLinker]}]
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set dir [file join $scratch p$p]
    file mkdir $dir
    set problem ""
    if {[dict get $options -gc-stress]} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
    if {$canCall && [dict get $options -functions] > 0} {
        set functions [drawFunctions [dict get $options -functions]]
        writeFile [file join $dir ff.c] [cSource $functions]
        lassign [callProgram $functions] main expected
        writeFile [file join $dir calls.bot] $main
        if {[catch {
            exec cc -c -O2 -fPIC [file join $dir ff.c] -o [file join $dir ff.o]
            exec ar rcs [file join $dir libbotlish_cfloat_fuzz.a] [file join $dir ff.o]
        } message]} {
            append problem "\nthe C library did not build: $message"
        } elseif {[catch {surface::compile $main calls.bot -warnings off} hir]} {
            append problem "\nthe call program did not compile: $hir"
        } else {
            native::withLinkDirs [list $dir] {
                foreach backend $native {
                    set got [outcome $backend $hir]
                    if {$got ne $expected} {
                        append problem "\ncalls on $backend: expected $expected\n  got $got"
                    }
                }
            }
        }
        incr callCount [llength $functions]
    }
    if {[dict get $options -layouts] > 0} {
        lassign [layoutsProgram [dict get $options -layouts]] main expected
        writeFile [file join $dir layouts.bot] $main
        if {[catch {surface::compile $main layouts.bot -warnings off} hir]} {
            append problem "\nthe layout program did not compile: $hir"
        } else {
            foreach backend [dict get $options -backends] {
                set got [outcome $backend $hir]
                if {$got ne $expected} {
                    append problem "\nlayouts on $backend: expected $expected\n  got $got"
                }
            }
        }
        incr layoutCount [dict get $options -layouts]
    }
    unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
    incr programs
    set problem [string trim $problem]
    if {$problem ne ""} {
        incr disagreements
        puts "DISAGREEMENT program $p ($dir):\n$problem"
        if {![dict get $options -keep]} { file delete -force $dir }
    } else {
        if {[dict get $options -verbose]} { puts "program $p: ok" }
        file delete -force $dir
    }
}
if {$disagreements == 0} { file delete -force $scratch }
puts "programs $programs calls $callCount layouts $layoutCount disagreements $disagreements"
exit [expr {$disagreements > 0}]
