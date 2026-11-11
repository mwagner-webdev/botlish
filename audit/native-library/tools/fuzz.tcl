# fuzz.tcl -- the native-library boundary against an independent model
# (NATIVE-LIBRARY-MILESTONE-1.md, section 6; WINDOWS-X86-64-MILESTONE-8.md,
# "Fuzzing").
#
#   tclsh9.0 audit/native-library/tools/fuzz.tcl ?-seed S? ?-exports N?
#       ?-calls N? ?-lifecycle N? ?-gc-stress 0|1?
#
# Generates a library of N exports with random signatures -- one to eight
# parameters of int, bool, Float64 and str (positions past the fourth
# included, the classes mixed), a result of each type or unit, some
# failing with a declared error -- whose bodies are simple, total functions
# of their arguments; calls each export -calls times from a generated C host
# with values drawn from the boundary's edges (INT64_MIN and INT64_MAX, -0.0,
# NaN and the infinities, the smallest subnormal, the empty String, NULL
# with length 0 and with a length, embedded NULs, multi-byte and invalid
# UTF-8, a surrogate's encoding, 9,000-byte text); and compares every line
# the host prints -- status, result or error identity and fields -- with
# what the model below computes from the same values: the C ABI's rules
# (NATIVE-LIBRARY-MILESTONE-1.md, section 6) and the bodies' arithmetic on
# exact integers and IEEE doubles, never the compiler or a backend. With
# -lifecycle N the host also runs N random lifecycle operations on up to
# three instances -- create, destroy (a live, a destroyed and a never-made
# handle), calls on each, releases of errors and buffers twice and of a
# foreign buffer -- against the model's registry of live handles: every
# unsafe operation is one the ABI defines as refused, so the host never
# depends on undefined behavior.
#
# Linux (cc) and Windows x86-64 (MSVC's cl, the DLL's import library, in
# vcvars64's environment). The host runs plainly and, with -gc-stress 1,
# under BOTLISH_NATIVE_GC_STRESS=1 as well. Prints the disagreements and a
# summary; exits 1 on any. Scratch files are in a temporary directory,
# removed at the end.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root core core.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests ctoolchain.tcl]
core::useBackend interp

set options [dict create -seed 1 -exports 8 -calls 24 -lifecycle 60 -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}
set windows [expr {$::tcl_platform(platform) eq "windows"}]
if {![native::hostSupports libraries] || ![ctool::available]} {
    puts "fuzz: this host builds no native libraries, or has no C toolchain"
    exit 1
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }

# ---------------------------------------------------------------- values

set INT64_MIN -9223372036854775808
set INT64_MAX 9223372036854775807
set ints [list 0 1 -1 7 -42 1000003 $INT64_MAX $INT64_MIN 4611686018427387904 -4611686018427387905]
# Doubles as their IEEE bits (hex): finite ones, -0.0, the extremes, the
# smallest subnormal, NaN, infinities.
set floats {
    0000000000000000 8000000000000000 3ff8000000000000 c00921fb54442d18 7fefffffffffffff
    ffefffffffffffff 0000000000000001 3e7ad7f29abcaf48 7ff8000000000000 7ff0000000000000
    fff0000000000000 7ff4000000000001
}
# Strings as {kind BYTES-AS-HEX} or {null LENGTH}.
set long [binary encode hex [string repeat [encoding convertto utf-8 "long ä text "] 692]]
set strs [list \
    [list bytes ""] [list null 0] [list null 3] [list bytes [binary encode hex "abc"]] \
    [list bytes [binary encode hex "a\x00b"]] [list bytes [binary encode hex [encoding convertto utf-8 "h\u00e9llo \U1F600"]]] \
    [list bytes ff] [list bytes eda080] [list bytes c3] [list bytes [binary encode hex [encoding convertto utf-8 "\u4e16\u754c"]]] \
    [list bytes $long]]
set bools {0 1}

# The double whose IEEE bits are BITS (hex, most significant first).
proc doubleOf {bits} {
    binary scan [binary decode hex $bits] Q x
    return $x
}
proc finite {bits} {
    binary scan [binary decode hex $bits] Wu value
    return [expr {(($value >> 52) & 0x7ff) != 0x7ff}]
}
# The C literal of double BITS (a bit pattern, so every value is exact).
proc cDouble {bits} { return "nl_d(0x${bits}ull)" }
# A C string literal of BYTES (hex): octal escapes, never greedy.
proc cBytes {hex} {
    set bytes [binary decode hex $hex]
    set out ""
    set n 0
    foreach c [split $bytes ""] {
        append out [format "\\%03o" [scan $c %c]]
        if {[incr n] % 256 == 0} { append out "\"\n        \"" }
    }
    return "\"$out\""
}
# The UTF-8 text of BYTES (hex), or "" with ok 0 when it is not UTF-8 (the
# runtime's std::str::from_utf8: strict, surrogates refused).
proc utf8 {hex} {
    set bytes [binary decode hex $hex]
    if {[catch {encoding convertfrom -profile strict utf-8 $bytes} text]} {
        return [list 0 ""]
    }
    # Tcl's strict profile refuses the surrogate encodings too.
    return [list 1 $text]
}
# FNV-1a, 32 bits, of BYTES (raw), as the host prints it.
proc fnv {bytes} {
    set h 2166136261
    foreach c [split $bytes ""] {
        set h [expr {(($h ^ [scan $c %c]) * 16777619) & 0xffffffff}]
    }
    return [format %08x $h]
}

# ---------------------------------------------------------------- program

set types {int bool float64 str}
set exports {}
for {set f 0} {$f < [dict get $options -exports]} {incr f} {
    set params {}
    set count [expr {1 + int(rand() * 8)}]
    for {set k 0} {$k < $count} {incr k} {
        lappend params [pick $types]
    }
    set result [pick {int int bool float64 str unit}]
    set fails [expr {[lindex $params 0] eq "int" && [chance 0.5]}]
    set coefficients [lmap p $params {expr {1 + int(rand() * 9)}}]
    set constant [expr {int(rand() * 100) - 50}]
    lappend exports [dict create name f$f params $params result $result fails $fails coefficients $coefficients constant $constant]
}

set botlish "import std::str\n\nerror Bad:\n    value: int\n\nfn weight(flag: bool, n: int) -> int:\n    if flag:\n        return n\n    0\n\nfn positive(x: Float64, n: int) -> int:\n    if x > 0.0:\n        return n\n    0\n"
foreach e $exports {
    set ps {}
    set terms [list [dict get $e constant]]
    set strsUsed {}
    set firstFloat ""
    foreach type [dict get $e params] c [dict get $e coefficients] k [lsearch -all [dict get $e params] *] {
        set botlishType [dict get {int int bool bool float64 Float64 str str} $type]
        lappend ps "p$k: $botlishType"
        switch -- $type {
            int { lappend terms "p$k * $c" }
            bool { lappend terms "weight(p$k, $c)" }
            float64 { lappend terms "positive(p$k, $c)"; if {$firstFloat eq ""} { set firstFloat p$k } }
            str { lappend terms "std::str::length(p$k) * $c"; lappend strsUsed p$k }
        }
    }
    set intExpr [join $terms " + "]
    set resultType [dict get {int int bool bool float64 Float64 str str unit unit} [dict get $e result]]
    set errors {}
    if {[dict get $e fails]} { lappend errors Bad }
    if {[dict get $e result] eq "float64"} { lappend errors NonFiniteFloat }
    append botlish "\nexported c fn [dict get $e name]([join $ps {, }]) -> $resultType"
    if {[llength $errors]} { append botlish " errors [join $errors {, }]" }
    append botlish ":\n"
    if {[dict get $e fails]} {
        append botlish "    if p0 < 0:\n        fail Bad {value: p0}\n"
    }
    switch -- [dict get $e result] {
        int { append botlish "    $intExpr\n" }
        bool { append botlish "    $intExpr > 0\n" }
        float64 {
            # (`if`, never expr's ?:, which would read "    1.5" as a number.)
            if {$firstFloat eq ""} {
                append botlish "    1.5\n"
            } else {
                append botlish "    $firstFloat * 0.5 + 1.0\n"
            }
        }
        str {
            if {![llength $strsUsed]} {
                append botlish "    \"none\"\n"
            } else {
                set expr [lindex $strsUsed end]
                foreach s [lreverse [lrange $strsUsed 0 end-1]] {
                    set expr "std::str::concat($s, std::str::concat(\"|\", $expr))"
                }
                append botlish "    $expr\n"
            }
        }
        unit {
            # The arguments still cross; their sum is computed and dropped.
            append botlish "    total = $intExpr\n    unit\n"
        }
    }
}

# ---------------------------------------------------------------- model

# The line the host prints for a call of export E with ARGS (values as the
# host passes them), as the C ABI and the body define it.
proc expected {e args} {
    # Arguments are converted in order; the first that C cannot carry fails
    # the call.
    set index 0
    set values {}
    foreach type [dict get $e params] arg $args {
        switch -- $type {
            float64 {
                if {![finite $arg]} { return "status 3 ARGUMENT-NOT-FINITE argument=$index" }
                set x [doubleOf $arg]
                # -0.0 enters as 0.0.
                if {$x == 0.0} { set x 0.0 }
                lappend values $x
            }
            str {
                lassign $arg kind payload
                if {$kind eq "null"} {
                    if {$payload != 0} { return "status 3 ARGUMENT-NULL argument=$index" }
                    lappend values [list ""]
                } else {
                    lassign [utf8 $payload] ok text
                    if {!$ok} { return "status 3 ARGUMENT-NOT-UTF8 argument=$index" }
                    lappend values [list $text]
                }
            }
            default { lappend values $arg }
        }
        incr index
    }
    if {[dict get $e fails] && [lindex $values 0] < 0} {
        return "status 1 Bad value=[lindex $values 0]"
    }
    set total [dict get $e constant]
    set firstFloat ""
    set texts {}
    foreach type [dict get $e params] c [dict get $e coefficients] v $values {
        switch -- $type {
            int { set total [expr {$total + $v * $c}] }
            bool { if {$v} { set total [expr {$total + $c}] } }
            float64 { if {$v > 0.0} { set total [expr {$total + $c}] }; if {$firstFloat eq ""} { set firstFloat $v } }
            str { set total [expr {$total + [string length [lindex $v 0]] * $c}]; lappend texts [lindex $v 0] }
        }
    }
    switch -- [dict get $e result] {
        int {
            if {$total < $::INT64_MIN || $total > $::INT64_MAX} { return "status 3 RESULT-OUT-OF-RANGE" }
            return "ok $total"
        }
        bool { return "ok [expr {$total > 0}]" }
        float64 {
            if {$firstFloat eq ""} {
                set x 1.5
            } else {
                set x [expr {$firstFloat * 0.5 + 1.0}]
            }
            return "ok [format %.17g $x]"
        }
        str {
            if {[llength $texts]} {
                set text [join $texts |]
            } else {
                set text none
            }
            set bytes [encoding convertto utf-8 $text]
            return "ok [string length $bytes] [fnv $bytes]"
        }
        unit { return "ok" }
    }
}

# ---------------------------------------------------------------- host

set c {#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "fz.h"
static double nl_d(uint64_t bits) { double x; memcpy(&x, &bits, sizeof x); return x; }
static uint32_t fnv(const uint8_t *p, size_t n) { uint32_t h = 2166136261u; for (size_t i = 0; i < n; i++) { h ^= p[i]; h *= 16777619u; } return h; }
static void line(int call, int32_t s, fz_error **ep) {
    printf("%d: status %d", call, (int) s);
    if (*ep) {
        const uint8_t *p; size_t l; int64_t n;
        fz_error_identity(*ep, &p, &l);
        printf(" %.*s", (int) l, (const char *) p);
        for (size_t i = 0; i < fz_error_field_count(*ep); i++) {
            fz_error_field_name(*ep, i, &p, &l);
            if (fz_error_field_int(*ep, i, &n) == 0) printf(" %.*s=%lld", (int) l, (const char *) p, (long long) n);
        }
        fz_error_release(ep);
    }
    printf("\n");
}
}
# (main's body is appended below, so its opening brace is not in a braced
# Tcl word.)
append c "int main(void) \{\n    fz_instance *in; fz_error *e = NULL;\n    int64_t ri; bool rb; double rd; fz_bytes rs;\n"
append c "    (void) ri; (void) rb; (void) rd; (void) rs;\n    if (fz_create(&in, &e) != 0) \{ printf(\"create failed\\n\"); return 1; \}\n"
set lines {}
set expectations {}
set call 0
foreach e $exports {
    for {set n 0} {$n < [dict get $options -calls]} {incr n} {
        set args {}
        set cargs {}
        foreach type [dict get $e params] {
            switch -- $type {
                int { set v [pick $ints]; lappend args $v; lappend cargs [expr {$v == $INT64_MIN ? "INT64_MIN" : "INT64_C($v)"}] }
                bool { set v [pick $bools]; lappend args $v; lappend cargs [expr {$v ? "true" : "false"}] }
                float64 { set v [pick $floats]; lappend args $v; lappend cargs [cDouble $v] }
                str {
                    set v [pick $strs]; lappend args $v
                    lassign $v kind payload
                    if {$kind eq "null"} {
                        lappend cargs NULL $payload
                    } else {
                        lappend cargs "(const uint8_t *) [cBytes $payload]" [string length [binary decode hex $payload]]
                    }
                }
            }
        }
        set result [dict get $e result]
        set out [dict get {int &ri bool &rb float64 &rd str &rs unit {}} $result]
        set callArgs [concat in $cargs [expr {$out eq "" ? {} : [list $out]}] &e]
        append c "    \{ int32_t s = fz_[dict get $e name]([join $callArgs {, }]);\n"
        append c "      if (s == 0) \{ printf(\"$call: ok\"); "
        switch -- $result {
            int { append c "printf(\" %lld\", (long long) ri); " }
            bool { append c "printf(\" %d\", (int) rb); " }
            float64 { append c "printf(\" %.17g\", rd); " }
            str { append c "printf(\" %zu %08x\", rs.len, (unsigned) fnv(rs.ptr, rs.len)); if (rs.ptr\[rs.len\] != 0) printf(\" unterminated\"); fz_bytes_release(&rs); " }
        }
        append c "printf(\"\\n\"); \} else line($call, s, &e); \}\n"
        dict set expectations $call [expected $e {*}$args]
        incr call
    }
}

# Lifecycle: up to three instance slots; the model knows which handles are
# live. Every operation's outcome is one the ABI defines.
set live [dict create 0 0 1 0 2 0]
set made [dict create 0 0 1 0 2 0]
set lifecycleBase $call
append c "    fz_instance *slot\[3\] = {NULL, NULL, NULL};\n    fz_instance *never = (fz_instance *) &slot;\n    fz_bytes kept = {NULL, 0};\n"
set probe [lindex $exports 0]
for {set n 0} {$n < [dict get $options -lifecycle]} {incr n} {
    set k [expr {int(rand() * 3)}]
    switch -- [pick {create create destroy call call never release foreign}] {
        create {
            if {[dict get $live $k]} continue
            append c "    printf(\"$call: create %d\\n\", (int) fz_create(&slot\[$k\], NULL));\n"
            dict set live $k 1
            dict set made $k 1
            dict set expectations $call "create 0"
        }
        destroy {
            if {![dict get $made $k]} continue
            append c "    printf(\"$call: destroy %d\\n\", (int) fz_destroy(slot\[$k\]));\n"
            dict set expectations $call "destroy [expr {[dict get $live $k] ? 0 : 4}]"
            dict set live $k 0
        }
        call {
            if {![dict get $made $k]} continue
            # The first export with its first edge arguments: what matters
            # is the handle's verdict.
            append c "    \{ fz_error *x = NULL; int32_t s = fz_invoke0(slot\[$k\], &x); printf(\"$call: call %d\", (int) s); if (x) \{ const uint8_t *p; size_t l; fz_error_identity(x, &p, &l); printf(\" %.*s\", (int) l, (const char *) p); fz_error_release(&x); printf(\" again %d\", (int) fz_error_release(&x)); \} printf(\"\\n\"); \}\n"
            dict set expectations $call [expr {[dict get $live $k] ? "call 0" : "call 4 INVALID-INSTANCE again 0"}]
        }
        never {
            append c "    \{ fz_error *x = NULL; int32_t s = fz_invoke0(never, &x); printf(\"$call: never %d\", (int) s); if (x) \{ const uint8_t *p; size_t l; fz_error_identity(x, &p, &l); printf(\" %.*s\", (int) l, (const char *) p); fz_error_release(&x); \} printf(\"\\n\"); \}\n"
            dict set expectations $call "never 4 INVALID-INSTANCE"
        }
        release {
            append c "    printf(\"$call: release %d %d\\n\", (int) fz_bytes_release(&kept), (int) fz_bytes_release(&kept));\n"
            dict set expectations $call "release 0 0"
        }
        foreign {
            append c "    \{ fz_bytes b = {(uint8_t *) \"not the library's\", 17}; printf(\"$call: foreign %d %s\\n\", (int) fz_bytes_release(&b), b.ptr ? \"kept\" : \"cleared\"); \}\n"
            dict set expectations $call "foreign 4 kept"
        }
    }
    incr call
}
append c "    for (int i = 0; i < 3; i++) if (slot\[i\]) fz_destroy(slot\[i\]);\n    fz_destroy(in);\n    return 0;\n\}\n"

# fz_invoke0: a call of the first export on HANDLE with in-range arguments.
set invokeArgs {}
foreach type [dict get $probe params] {
    switch -- $type {
        int { lappend invokeArgs 1 }
        bool { lappend invokeArgs true }
        float64 { lappend invokeArgs 1.0 }
        str { lappend invokeArgs {(const uint8_t *) "x"} 1 }
    }
}
set probeOut [dict get {int ri bool rb float64 rd str rs unit {}} [dict get $probe result]]
set probeDecl [dict get {int {int64_t ri;} bool {bool rb;} float64 {double rd;} str {fz_bytes rs = {NULL, 0};} unit {}} [dict get $probe result]]
set invoke "static int32_t fz_invoke0(fz_instance *h, fz_error **e) {\n    $probeDecl\n    int32_t s = fz_[dict get $probe name]([join [concat h $invokeArgs [expr {$probeOut eq "" ? {} : [list &$probeOut]}] e] {, }]);\n"
if {[dict get $probe result] eq "str"} { append invoke "    if (s == 0) fz_bytes_release(&rs);\n" }
append invoke "    return s;\n}\n"
set c [string map [list "int main(void) \{" "$invoke\nint main(void) \{"] $c]

# ---------------------------------------------------------------- run

proc write {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}
set dir [file tempdir botlish-native-library-fuzz]
set lib [file join $dir lib]
file mkdir $lib
write [file join $dir fz.bot] $botlish
set failures 0
try {
    set hir [surface::readProgramFile [file join $dir fz.bot] -warnings off -warning-channel ""]
    if {$windows} {
        set built [ctool::withMsvc [list native::library $hir -name fz -out $lib]]
    } else {
        set built [native::library $hir -name fz -out $lib]
    }
    write [file join $dir host.c] $c
    if {$windows} {
        set exe [file join $lib host.exe]
        ctool::msvc cl /nologo /O1 /W3 /std:c11 /MT /D_CRT_SECURE_NO_WARNINGS /I[file nativename $lib] \
            /Fo[file nativename [file join $dir host.obj]] /Fe[file nativename $exe] [file nativename [file join $dir host.c]] \
            [file nativename [dict get $built import]]
    } else {
        set exe [file join $dir host]
        exec cc -O1 -I$lib [file join $dir host.c] [dict get $built static] {*}$native::library::systemLibraries -o $exe
    }
    set runs [list plain 0]
    if {[dict get $options -gc-stress]} { lappend runs "GC stress" 1 }
    foreach {label stress} $runs {
        if {$stress} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 } else { unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS) }
        set output [string map {"\r" ""} [exec $exe]]
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
        set got [dict create]
        foreach l [split $output \n] {
            if {[regexp {^(\d+): (.*)$} $l -> n rest]} { dict set got $n $rest }
        }
        dict for {n want} $expectations {
            set have [dict getdef $got $n "(no line)"]
            if {$have ne $want} {
                incr failures
                if {$failures <= 20} {
                    set where [expr {$n < $lifecycleBase ? "call" : "lifecycle step"}]
                    puts "DISAGREE ($label) $where $n: host \"$have\", model \"$want\""
                }
            }
        }
    }
} finally {
    file delete -force $dir
}
set calls [expr {$lifecycleBase}]
puts "native-library fuzz, seed [dict get $options -seed]: [llength $exports] exports, $calls calls, [expr {[dict size $expectations] - $calls}] lifecycle steps, [expr {[dict get $options -gc-stress] ? "plainly and under GC stress" : "plainly"}]: $failures disagreements"
exit [expr {$failures > 0}]
