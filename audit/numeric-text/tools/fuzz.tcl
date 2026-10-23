# fuzz.tcl -- differential fuzzer of the numeric/text boundary
# (NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md) against an independent oracle.
#
#   tclsh9.0 audit/numeric-text/tools/fuzz.tcl ?-seed N? ?-count N?
#       ?-backends "interp compile cranelift-generic cranelift"? ?-verbose 0|1?
#
# Each run makes COUNT cases of each kind and one program that computes
# them all through parameters (so no call is decided before the run):
#
#   int-to-string    random Ints of 1 to 400 digits, both signs, and the
#                    machine-width boundaries: std::int::to_string
#   int-from-string  canonical texts, and the same texts corrupted (a "+",
#                    a leading zero, "-0", a space, a trailing letter, a
#                    fraction, an exponent, a "_", a non-ASCII digit, a
#                    newline, a doubled sign, nothing): std::int::from_string,
#                    its value shown again, or "invalid" for the declared
#                    InvalidIntegerText
#   float-round      random finite binary64s of every magnitude, exact
#                    halves and their two neighbors: std::float64::round
#   dr-quantize      random binary64s quantized at a random precision P
#                    (std::decimal_rounded::round[DecimalRounded{
#                    minDecimalsPreserved: P}]) and shown
#                    (std::decimal_rounded::to_string), or "none" for
#                    UnrepresentableDecimal
#
# The oracle (oracle.py beside this script, python3 -I) is written from the
# milestone's rules with Python's integers, fractions and decimals: it
# shares no code with core/ or native/. A case disagrees when a backend's
# text differs from the oracle's, or the backends differ from each other
# (a "none" quantization is checked only for agreement: whether a decimal
# has a binary64 at P places is DECIMAL-ROUNDED-MILESTONE-1.md's, audited
# by its own fuzzer). It prints one line per disagreement and a final
# "cases N disagreements D" line; the exit status is 1 when D > 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -seed 1 -count 60 -backends "interp compile cranelift-generic cranelift" -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set backends [dict get $options -backends]
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

expr {srand([dict get $options -seed])}
proc random {n} { return [expr {int(rand() * $n)}] }
proc pick {list} { return [lindex $list [random [llength $list]]] }

# The precisions the dr-quantize cases use (one function each).
set precisions {0 1 2 3 6 9 15 19 25}

# ---------------------------------------------------------------------------
# Cases

# A random Int of 1 to MAX decimal digits, either sign.
proc randomInt {max} {
    set digits [expr {1 + [random $max]}]
    set n [expr {1 + [random 9]}]
    for {set i 1} {$i < $digits} {incr i} {
        append n [random 10]
    }
    if {[random 2]} {
        set n -$n
    }
    return $n
}

# The 64-bit pattern (hex) of the double X.
proc bitsOf {x} {
    binary scan [binary format q $x] wu bits
    return [format %016llx $bits]
}

# The double of the 64-bit pattern BITS (an integer).
proc doubleOf {bits} {
    binary scan [binary format wu $bits] q x
    return $x
}

# A random finite double: random bits of any magnitude, or a small value.
proc randomDouble {} {
    while 1 {
        switch -- [random 4] {
            0 {
                set bits [expr {([random 0x10000] << 48) | ([random 0x1000000] << 24) | [random 0x1000000]}]
                set x [doubleOf $bits]
            }
            1 { set x [expr {(rand() - 0.5) * 10.0 ** [random 12]}] }
            2 { set x [expr {(rand() - 0.5) * 10.0 ** (-[random 20])}] }
            default { set x [expr {(rand() - 0.5) * 2.0 ** [random 80]}] }
        }
        if {[expr {isfinite($x)}]} {
            return $x
        }
    }
}

set ints {0 1 -1 9 -10 4611686018427387903 4611686018427387904 -4611686018427387904 -4611686018427387905
    9223372036854775807 9223372036854775808 -9223372036854775809 18446744073709551616
    340282366920938463463374607431768211455 340282366920938463463374607431768211456}
for {set i 0} {$i < [dict get $options -count]} {incr i} {
    lappend ints [randomInt [pick {5 19 40 400}]]
}

set texts {"" - -0 00 01 +1 " 1" "1 " 1x x1 --1 1.0 1e3 1_0 "١" "１" "1\n" 0 -1 7}
for {set i 0} {$i < [dict get $options -count]} {incr i} {
    set t [randomInt [pick {3 19 40}]]
    switch -- [random 14] {
        0 { set t +$t }
        1 { set t "0[string trimleft $t -]" }
        2 { set t " $t" }
        3 { set t "$t " }
        4 { set t ${t}x }
        5 { set t $t.0 }
        6 { set t ${t}e2 }
        7 { set t [string replace $t end end _] }
        8 { set t [string replace $t end end ٣] }
        9 { set t $t\n }
        10 { set t -$t }
        default {}
    }
    lappend texts $t
}

set floats {0.0 0.49 0.5 1.5 2.5 3.5 -0.5 -1.5 -2.5 1.0e20 -1.0e300 1.7976931348623157e308 5.0e-324}
for {set i 0} {$i < [dict get $options -count]} {incr i} {
    if {[random 3] == 0} {
        # An exact half and its neighbors.
        set k [expr {[random 2] ? [random 1000] : int(rand() * 2.0 ** 52)}]
        set half [expr {($k + 0.5) * ([random 2] ? 1 : -1)}]
        binary scan [binary format q $half] wu bits
        lappend floats $half [doubleOf [expr {$bits + 1}]] [doubleOf [expr {$bits - 1}]]
    } else {
        lappend floats [randomDouble]
    }
}

set quantized [dict create]
foreach p $precisions {
    dict set quantized $p {}
}
for {set i 0} {$i < [dict get $options -count]} {incr i} {
    set p [pick $precisions]
    set x [randomDouble]
    if {[random 3] == 0} {
        # A decimal tie at P places, or a hair either side.
        set x [expr {(int(rand() * 1000000) + 0.5) / 10.0 ** $p}]
    }
    dict lappend quantized $p $x
}

# ---------------------------------------------------------------------------
# The program

# Botlish source of the String literal of TEXT.
proc stringLiteral {text} {
    return "\"[string map {\\ \\\\ \" \\\" \n \\n \t \\t \r \\r} $text]\""
}

# Botlish source of the Float64 literal of the double X (its canonical
# text, which reads back as exactly X).
proc floatLiteral {x} {
    return [core::float::Text $x]
}

set program "import std::int\nimport std::float64\nimport std::decimal_rounded\n"
append program "fn a(n: int) -> str:\n    n.to_string()\n"
append program "fn b(s: str) -> str:\n    n = std::int::from_string(s):\n        on InvalidIntegerText:\n            return \"invalid\"\n    n.to_string()\n"
append program "fn c(x: Float64) -> str:\n    x.round().to_string()\n"
foreach p $precisions {
    append program "fn d$p\(x: Float64) -> str:\n    d = std::decimal_rounded::round\[DecimalRounded{minDecimalsPreserved: $p}\](x):\n        on UnrepresentableDecimal:\n            return \"none\"\n    d.to_string()\n"
}
append program "fn as(ns: List\[int\]) -> List\[str\]:\n    loop n in ns:\n        a(n)\n"
append program "fn bs(ts: List\[str\]) -> List\[str\]:\n    loop t in ts:\n        b(t)\n"
append program "fn cs(xs: List\[Float64\]) -> List\[str\]:\n    loop x in xs:\n        c(x)\n"
foreach p $precisions {
    append program "fn ds$p\(xs: List\[Float64\]) -> List\[str\]:\n    loop x in xs:\n        d$p\(x)\n"
}
set parts [list "as(\[[join $ints {, }]\])" "bs(\[[join [lmap t $texts {stringLiteral $t}] {, }]\])" \
    "cs(\[[join [lmap x $floats {floatLiteral $x}] {, }]\])"]
foreach p $precisions {
    lappend parts "ds$p\(\[[join [lmap x [dict get $quantized $p] {floatLiteral $x}] {, }]\])"
}
append program "\[[join $parts {, }]\]\n"

# The cases in the program's order, as oracle input lines.
set cases {}
foreach n $ints {
    lappend cases "int-to-string\t$n"
}
foreach t $texts {
    binary scan [encoding convertto utf-8 $t] H* hex
    lappend cases "int-from-string\t$hex"
}
foreach x $floats {
    lappend cases "float-round\t[bitsOf $x]"
}
foreach p $precisions {
    foreach x [dict get $quantized $p] {
        lappend cases "dr-quantize\t[bitsOf $x]\t$p"
    }
}

# ---------------------------------------------------------------------------
# Running and comparing

set oracleInput [file join [file tempdir botlish-numeric-text-fuzz] cases.txt]
set f [open $oracleInput w]
fconfigure $f -encoding utf-8 -translation lf
puts -nonewline $f [join $cases \n]\n
close $f
set expected [split [exec python3 -I [file join $root audit numeric-text tools oracle.py] < $oracleInput] \n]
file delete -force [file dirname $oracleInput]

set hir [surface::compile $program fuzz.bot -warnings off]
set outputs [dict create]
foreach backend $backends {
    set saved [core::useBackend]
    resetEffects
    if {[catch {
        switch -- $backend {
            interp { core::useBackend interp; core::evalProgram [hir::lower $hir] }
            compile { core::compiler::evalHir $hir }
            cranelift-generic { native::evalHir $hir -specialize 0 }
            cranelift { native::evalHir $hir }
        }
    } result]} {
        core::useBackend $saved
        puts "$backend: the program did not run: $result"
        puts "cases [llength $cases] disagreements [llength $cases]"
        exit 1
    }
    core::useBackend $saved
    set texts {}
    foreach group [core::value::items $result] {
        foreach item [core::value::items $group] {
            lappend texts [core::value::strOf $item]
        }
    }
    dict set outputs $backend $texts
}

set disagreements 0
set nones 0
foreach line $cases want $expected i [lsearch -all $cases *] {
    set got [lsort -unique [lmap b $backends {lindex [dict get $outputs $b] $i}]]
    if {[llength $got] != 1} {
        incr disagreements
        puts "DISAGREE (backends) [string map {\t " "} $line]: [lmap b $backends {list $b [lindex [dict get $outputs $b] $i]}]"
        continue
    }
    set got [lindex $got 0]
    if {$got eq "none" && [string match dr-quantize* $line]} {
        incr nones
        continue
    }
    if {$got ne $want} {
        incr disagreements
        puts "DISAGREE (oracle) [string map {\t " "} $line]: got [string range $got 0 80] want [string range $want 0 80]"
    } elseif {[dict get $options -verbose]} {
        puts "ok [string map {\t " "} $line] -> [string range $got 0 80]"
    }
}
puts "unrepresentable quantizations (agreement only) $nones"
puts "cases [llength $cases] disagreements $disagreements"
exit [expr {$disagreements > 0}]
