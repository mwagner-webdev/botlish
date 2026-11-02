# fuzz.tcl -- generated emitters against exhaustive execution, under the
# compiler (EMISSION-CLAIMS-MILESTONE-1.md, "Differential and
# generated-program evidence"; the modular prototype's fuzzer,
# audit/emission-proofs/tools/fuzz.tcl, with the compiler's checker).
#
#   tclsh9.0 audit/emission-claims/tools/fuzz.tcl ?-seeds 1-40? ?-functions 8?
#       ?-out FILE? ?-keep DIR?
#
# Each seed writes one module of emitting functions with bounded control
# flow and data -- sequences, branches on `x` (comparisons, and, or, not),
# counted loops with separators, early returns, helpers that emit parts of
# a token, recursive helpers, helpers that fail after emitting, handlers
# that catch a failure and go on emitting, guards (a recognizer of one
# symbol) and their handlers -- each claiming (`emits`) one of four small
# recognizers (one symbol; a two-symbol pair; a word that ends before its
# follower; a bracketed list of words: a call, `then STATE` and `accept
# before`). The compiler decides every claim from the declaration (`x:
# int`); the program, its claims removed (tools/witness.tcl), then runs every
# function for every x of a window holding every constant the generator
# uses, and some huge values, on the Tcl compiler, and tests/dfa-support.tcl's
# reference interpreter judges each run: a complete one must be exactly one
# token, a failed one a viable prefix.
#
# The generator's comparisons and arithmetic use constants inside the
# window (and `mod` by 2..4), so every condition and every symbol is
# piecewise constant -- or periodic -- outside it: the window is exhaustive
# for these programs.
#
#   false proof      the compiler certified a claim, and some run violates
#                    it: the failure this harness exists to find (exit 1)
#   rejected, confirmed   the compiler rejected the claim and some run is
#                    invalid
#   precision loss   not certified (rejected or not proved), and every run
#                    is valid
#   agreed           certified and every run valid

set here [file dirname [file normalize [info script]]]
set options [dict merge {-seeds 1-40 -functions 8 -out "" -keep ""} $argv]
set argv {}
source [file join $here witness.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval gen {
    variable faultRate 12
    variable rng 1
    variable helpers {}
    variable text ""
    variable fnCount 0
    variable window {}
    for {set x -6} {$x <= 120} {incr x} { lappend window $x }
    lappend window 100000000000000000000 -100000000000000000000 9223372036854775808
}

proc gen::Rand {n} {
    variable rng
    set rng [expr {($rng * 1103515245 + 12345) % 2147483648}]
    return [expr {($rng >> 8) % $n}]
}

proc gen::Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

proc gen::Chance {percent} {
    return [expr {[Rand 100] < $percent}]
}

# The recognizers every generated module declares.
set gen::recognizers {
dfa one over ascii:
    start:
        'a'..'c' -> accept

dfa pair over ascii:
    start:
        'a' -> mid
    mid:
        'b' 'c' -> accept
        end -> accept

dfa word over ascii:
    start:
        'a' 'b' -> more
    more:
        'a' 'b' -> more
        ' ' ',' ']' -> accept before
        end -> accept

dfa items over ascii:
    open:
        '[' -> first
    first:
        'a' 'b' -> call word then sep
        ']' -> accept
    sep:
        ',' -> next
        ']' -> accept
    next:
        'a' 'b' -> call word then sep

dfa letter over ascii:
    start:
        'a'..'e' -> accept
}

proc gen::Indent {lines} {
    return [lmap l $lines {string cat "    " $l}]
}

# A fault planted with probability PERCENT (the generator's mistakes: each
# construct has a correct form and wrong ones, some wrong only for a few x).
proc gen::Fault {} {
    variable faultRate
    return [Chance $faultRate]
}

# A condition on V (comparisons with small constants, and, or, not).
proc gen::Cond {v depth} {
    if {$depth < 2 && [Chance 25]} {
        set a [Cond $v [expr {$depth + 1}]]
        set b [Cond $v [expr {$depth + 1}]]
        return "($a [Pick {and or}] $b)"
    }
    if {$depth < 2 && [Chance 10]} {
        return "not [Cond $v [expr {$depth + 1}]]"
    }
    set op [Pick {< <= > >= == !=}]
    if {[Chance 20]} {
        return "$v.mod([Pick {2 3 4}]) $op [Rand 4]"
    }
    return "$v $op [expr {[Rand 14] - 3}]"
}

# Lines that yield exactly one symbol of LO..HI computed from the Int V --
# or, where a fault is planted, possibly another or none or two. MAYFAIL
# records whether they may fail E.
proc gen::Sym1 {lo hi v depth mayFailVar} {
    upvar 1 $mayFailVar mayFail
    variable helpers
    set n [expr {$hi - $lo + 1}]
    set kind [Rand 11]
    if {$depth >= 3} { set kind [Rand 3] }
    switch -- $kind {
        0 {
            set c [expr {$lo + [Rand $n]}]
            if {[Fault]} { set c [Pick {96 100 101 44 32}] }
            return [list "yield $c"]
        }
        1 {
            set m $n
            if {[Fault]} { incr m }
            return [list "yield $lo + $v.mod($m)"]
        }
        2 {
            set l [expr {[Rand 12] - 3}]
            set top [expr {$l + $n - 1}]
            if {[Fault]} { incr top }
            set lines [list "if $v >= $l and $v <= $top:" "    yield [expr {$lo - $l}] + $v"]
            if {[Fault]} { return $lines }
            lappend lines "else:" {*}[Indent [Sym1 $lo $hi $v [expr {$depth + 1}] mayFail]]
            return $lines
        }
        3 {
            return [list "if [Cond $v 0]:" {*}[Indent [Sym1 $lo $hi $v [expr {$depth + 1}] mayFail]] \
                "else:" {*}[Indent [Sym1 $lo $hi $v [expr {$depth + 1}] mayFail]]]
        }
        4 - 5 {
            # A helper of its own Int, called with an expression of V.
            set name [Helper $lo $hi $depth fails]
            if {$fails} { set mayFail 1 }
            return [list "$name\([Pick [list $v "$v + [Rand 3]" "$v.mod(5)" [Rand 6]]])"]
        }
        6 {
            # A guard: `letter` takes 'a'..'e'; the symbol is then
            # confined to LO..HI by a branch (or, a fault, yielded as is).
            set c g[Rand 1000]
            set lines [list "$c = [expr {96 + [Rand 3]}] + $v.mod(6)" "letter($c):"]
            if {[Chance 70]} {
                lappend lines "    on std::dfa::UnrecognizedInput:" "        fail E {at: 1}" \
                    "    on std::dfa::UnexpectedEnd:" "        fail E {at: 2}"
                set mayFail 1
            } else {
                lappend lines "    on std::dfa::UnrecognizedInput:" "        0" \
                    "    on std::dfa::UnexpectedEnd:" "        0"
            }
            if {[Fault]} {
                lappend lines "yield $c"
            } else {
                lappend lines "if $c >= $lo and $c <= $hi:" "    yield $c" "else:" "    yield $lo"
            }
            return $lines
        }
        7 {
            # A helper that may fail -- before its symbol (or, a fault,
            # after it) -- and a handler that writes the symbol instead.
            set name [Failer $lo $hi $depth]
            return [list "$name\($v):" "    on E:" {*}[Indent [Indent [Sym1 $lo $hi $v 3 mayFail]]]]
        }
        8 {
            # An early return after the symbol (a fault: before it).
            set inner [Sym1 $lo $hi $v [expr {$depth + 1}] mayFail]
            if {[Fault]} {
                return [list "if [Cond $v 0]:" "    return unit" {*}$inner]
            }
            return [list "if [Cond $v 0]:" {*}[Indent $inner] "    return unit" {*}$inner]
        }
        9 {
            # A loop that runs once (a fault: zero or two times).
            set k 1
            if {[Fault]} { set k [Pick {0 2}] }
            return [list "loop i from 0 to $k:" {*}[Indent [Sym1 $lo $hi $v [expr {$depth + 1}] mayFail]] "    continue"]
        }
        10 {
            return [list "loop:" {*}[Indent [Sym1 $lo $hi $v [expr {$depth + 1}] mayFail]] "    break"]
        }
    }
}

# A helper yielding one symbol of LO..HI from its parameter n (FAILSVAR:
# whether it may fail E): its name.
proc gen::Helper {lo hi depth failsVar} {
    upvar 1 $failsVar fails
    variable helpers
    variable fnCount
    set key [list $lo $hi]
    if {[dict exists $helpers $key] && [Chance 50]} {
        lassign [Pick [dict get $helpers $key]] name fails
        return $name
    }
    set name h[incr fnCount]
    set fails 0
    set lines [Sym1 $lo $hi n [expr {$depth + 1}] fails]
    Define $name $lines $fails
    dict lappend helpers $key [list $name $fails]
    return $name
}

# A helper that may fail E, before its symbol of LO..HI or (a fault) after.
proc gen::Failer {lo hi depth} {
    variable fnCount
    set name h[incr fnCount]
    set fails 1
    set check [list "if n.mod([Pick {2 3}]) == [Rand 2]:" "    fail E {at: 0}"]
    set body [Sym1 $lo $hi n 3 fails]
    if {[Fault]} {
        set lines [concat $body $check]
    } else {
        set lines [concat $check $body]
    }
    Define $name $lines 1
    return $name
}

# A recursive helper: N symbols of LO..HI for N in 0..4.
proc gen::Repeater {lo hi} {
    variable fnCount
    set name r[incr fnCount]
    set fails 0
    set lines [list "if n > 0 and n < 5:" {*}[Indent [Sym1 $lo $hi n 2 fails]] "    $name\(n - 1)"]
    Define $name $lines $fails
    return [list $name $fails]
}

proc gen::Define {name lines fails} {
    variable text
    set errors ""
    if {$fails} { set errors " errors E" }
    append text "fn $name\(n: int) -> unit$errors:\n[join [Indent $lines] \n]\n    unit\n\n"
}

# The body of a claimed emitter of recognizer R over x: {LINES FAILS}.
proc gen::Emitter {r} {
    set fails 0
    set lines {}
    switch -- $r {
        one {
            set lines [Sym1 97 99 x 0 fails]
        }
        pair {
            set first 97
            if {[Fault]} { set first 98 }
            lappend lines "yield $first"
            if {[Chance 70]} {
                lappend lines "if [Cond x 0]:" {*}[Indent [Sym1 98 99 x 1 fails]]
            }
        }
        word {
            switch -- [Rand 3] {
                0 {
                    for {set i [expr {1 + [Rand 3]}]} {$i > 0} {incr i -1} {
                        lappend lines {*}[Sym1 97 98 x 1 fails]
                    }
                }
                1 {
                    set k [expr {1 + [Rand 3]}]
                    if {[Fault]} { set k 0 }
                    lappend lines "loop i from 0 to $k:" {*}[Indent [Sym1 97 98 x 1 fails]] "    continue"
                }
                2 {
                    lassign [Repeater 97 98] name f
                    if {$f} { set fails 1 }
                    lappend lines {*}[Sym1 97 98 x 1 fails]
                    set arg x.mod(4)
                    if {[Fault]} { set arg 0 }
                    lappend lines "$name\($arg)"
                }
            }
        }
        items {
            lappend lines "yield 91"
            set k [Rand 4]
            lappend lines "loop i from 0 to $k:"
            if {[Fault]} {
                lappend lines "    yield [Pick {44 32}]"
            } else {
                lappend lines "    if i > 0:" "        yield 44"
            }
            set f 0
            set word [Sym1 97 98 n 2 f]
            if {[Chance 50]} {
                lappend word {*}[Sym1 97 98 n 2 f]
            }
            set name w[incr ::gen::fnCount]
            Define $name $word $f
            if {$f} { set fails 1 }
            lappend lines "    $name\(x + i)" "    continue"
            set close 93
            if {[Fault]} { set close [Pick {44 97}] }
            lappend lines "yield $close"
        }
    }
    return [list $lines $fails]
}

# The module of seed SEED: {TEXT CLAIMS}, CLAIMS {NAME R FAILS}...
proc gen::Module {seed count} {
    variable rng
    variable helpers
    variable text
    variable fnCount
    set rng [expr {$seed * 7919 + 17}]
    set helpers [dict create]
    set text ""
    set fnCount 0
    set claims {}
    set emitters ""
    for {set i 0} {$i < $count} {incr i} {
        set r [Pick {one one pair word word items}]
        set name f[incr fnCount]
        lassign [Emitter $r] lines fails
        set errors ""
        if {$fails} { set errors " errors E" }
        append emitters "fn $name\(x: int) -> unit$errors emits gen${seed}::$r:\n[join [Indent $lines] \n]\n    unit\n\n"
        lappend claims [list $name $r $fails]
    }
    set module "import std::dfa\n\nerror E:\n    at: int\n\n$::gen::recognizers\n$text\n$emitters"
    return [list $module $claims]
}

# ---------------------------------------------------------------------------

proc Range {spec} {
    set out {}
    foreach part [split $spec ,] {
        if {[regexp {^(\d+)-(\d+)$} $part -> a b]} {
            for {set i $a} {$i <= $b} {incr i} { lappend out $i }
        } else {
            lappend out $part
        }
    }
    return $out
}

set totals [dict create claims 0 proven 0 rejected 0 not-proved 0 "false proof" 0 "rejected, confirmed" 0 \
    "precision loss" 0 discarded 0 runs 0]
set rows {}
set failures 0
foreach seed [Range [dict get $options -seeds]] {
    lassign [gen::Module $seed [dict get $options -functions]] module claims
    set dir [emit::workspace gen${seed}.bot $module main.bot "import gen$seed\n\n0\n"]
    if {[dict get $options -keep] ne ""} {
        file mkdir [dict get $options -keep]
        file copy -force [file join $dir gen${seed}.bot] [dict get $options -keep]
    }
    if {[catch {emit::compile [file join $dir main.bot]} hir]} {
        dict incr totals discarded
        lappend rows "| $seed | (does not compile: [string map {| /} [lindex [split $hir \n] 0]]) |"
        continue
    }
    set verdicts [dict create]
    set kindsOf [dict create]
    foreach r [hir::emission::claims $hir] {
        set name [namespace tail [dict get $r function]]
        dict set verdicts $name [dict get $r verdict]
        dict set kindsOf $name [lsort -unique [lmap d [dict get $hir diagnostics] {
            if {[dict getdef $d expr ""] ne [dict get $r block]} continue
            dict get $d kind
        }]]
    }
    set copy [emitw::Stripped $dir]
    set model [emit::reference $copy]
    set counts [dict create]
    foreach claim $claims {
        lassign $claim name rec fails
        set fn gen${seed}::$name
        set errors {}
        if {$fails} { set errors E }
        if {[catch {emitw::traces $copy $fn {int} [lmap e $errors {string cat gen${seed}:: $e}] \
                [lmap x $gen::window {list $x}]} runs]} {
            dict incr totals discarded
            continue
        }
        set invalid ""
        foreach run $runs {
            lassign $run tuple outcome symbols
            dict incr totals runs
            set j [emit::judge $model [list gen$seed $rec] $outcome $symbols]
            if {$j ne "ok" && $invalid eq ""} {
                set invalid "x = [lindex $tuple 0]: [lindex $j 1]"
            }
        }
        set v [dict getdef $verdicts $name missing]
        dict incr totals claims
        dict incr totals $v
        if {$v eq "proven" && $invalid ne ""} {
            dict incr totals "false proof"
            incr failures
            lappend rows "| $seed | FALSE PROOF: $name ($rec): $invalid |"
        } elseif {$v ne "proven" && $invalid eq ""} {
            dict incr totals "precision loss"
            lappend rows "| $seed | precision loss: $name ($rec), $v: [join [dict getdef $kindsOf $name {}] {, }] |"
        } elseif {$v ne "proven"} {
            dict incr totals "rejected, confirmed"
        }
        dict incr counts $v
    }
    lappend rows "| $seed | [join [lmap {k v} $counts {string cat $k " " $v}] {, }] |"
}

set report [list "## Generated emitters against exhaustive execution" "" \
    "seeds [dict get $options -seeds], [dict get $options -functions] claimed functions each, x in -6..120 and three huge values" "" \
    "| seed | result |" "|---|---|" {*}$rows "" "| total | |" "|---|---:|"]
dict for {k v} $totals {
    lappend report "| $k | $v |"
}
set text [join $report \n]
if {[dict get $options -out] ne ""} {
    emit::writeText [dict get $options -out] "$text\n"
}
puts $text
emit::cleanup
exit [expr {$failures > 0}]
