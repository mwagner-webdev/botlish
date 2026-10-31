# fuzz.tcl -- generated emitters against exhaustive execution
# (MODULAR-EMISSION-PROOFS-MILESTONE-1.md, section 14).
#
#   tclsh9.0 audit/emission-proofs/tools/fuzz.tcl ?-seeds 1-20? ?-functions 8?
#       ?-original 0|1? ?-out FILE? ?-keep DIR?
#
# Each seed writes one module of emitting functions with bounded control
# flow and data -- sequences, branches on `x` (comparisons, and, or, not),
# counted loops with separators, early returns, helpers that emit parts of
# a token, recursive helpers, helpers that fail after emitting, handlers
# that catch a failure and go on emitting, guards (a recognizer of one
# symbol) and their handlers -- each claiming one of four small recognizers
# (one symbol; a two-symbol pair; a word that ends before its follower; a
# bracketed list of words: a call, `then STATE` and `accept before`). The
# modular checker decides every claim from the declaration (`x: int`); the
# program then runs every function for every x of a window holding every
# constant the generator uses, and some huge values, on the Tcl compiler,
# and tests/dfa-support.tcl's reference interpreter judges each run: a
# complete one must be exactly one token, a failed one a viable prefix.
#
# The generator's comparisons and arithmetic use constants inside the
# window (and `mod` by 2..4), so every condition and every symbol is
# piecewise constant -- or periodic -- outside it: the window is exhaustive
# for these programs.
#
#   false proof      the checker proved a claim, and some run violates it:
#                    the failure this harness exists to find (exit 1)
#   disproven        the checker's own counterexample (consistency: every
#                    run must agree that the claim is false)
#   precision loss   not proved, and every run is valid
#   agreed           proved and every run valid, or rejected and some run
#                    invalid
#
# With -original 1 the exploratory checker judges the same claims (its
# facts: the driver's calls, whose arguments it cannot see through), so
# its false proofs are counted too.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-seeds 1-20 -functions 8 -original 0 -out "" -keep ""} $argv]
set argv {}
source [file join $here concrete.tcl]
source [file join $here modcheck.tcl]
if {[dict get $options -original]} {
    source [file join [file dirname [file dirname $here]] emitter tools emitcheck.tcl]
}
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
        append emitters "#: emits gen${seed}::$r\nfn $name\(x: int) -> unit$errors:\n[join [Indent $lines] \n]\n    unit\n\n"
        lappend claims [list $name $r $fails]
    }
    set module "import std::dfa\n\nerror E:\n    at: int\n\n$::gen::recognizers\n$text\n$emitters"
    return [list $module $claims]
}

# ---------------------------------------------------------------------------

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

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

set totals [dict create claims 0 proven 0 disproven 0 not-proved 0 "false proof" 0 "precision loss" 0 \
    "disproven, no invalid run" 0 discarded 0 runs 0 "exploratory false proof" 0 "exploratory proved" 0]
set rows {}
set failures 0
foreach seed [Range [dict get $options -seeds]] {
    lassign [gen::Module $seed [dict get $options -functions]] module claims
    set dir [file tempdir]
    writeText [file join $dir gen${seed}.bot] $module
    writeText [file join $dir main.bot] "import gen$seed\n\n0\n"
    if {[dict get $options -keep] ne ""} {
        file mkdir [dict get $options -keep]
        file copy -force [file join $dir gen${seed}.bot] [dict get $options -keep]
    }
    if {[catch {modcheck::check [file join $dir main.bot] -witness 1} r]} {
        dict incr totals discarded
        lappend rows "| $seed | (does not compile: [string map {| /} [lindex [split $r \n] 0]]) |"
        file delete -force $dir
        continue
    }
    set verdicts [dict create]
    foreach c [dict get $r claims] {
        dict set verdicts [namespace tail [dict get $c name]] [dict get $c verdict]
    }
    set model [dfaref::load [list "" [file join $dir main.bot] gen$seed [file join $dir gen${seed}.bot]]]
    set seedFalse 0
    set counts [dict create]
    foreach claim $claims {
        lassign $claim name rec fails
        set fn gen${seed}::$name
        set errors {}
        if {$fails} { set errors E }
        if {[catch {concrete::traces [file join $dir main.bot] $fn {int} [lmap e $errors {string cat gen${seed}:: $e}] \
                [lmap x $gen::window {list $x}]} runs]} {
            dict incr totals discarded
            continue
        }
        set invalid ""
        foreach run $runs {
            lassign $run tuple outcome symbols
            dict incr totals runs
            set j [concrete::judge $model [list gen$seed $rec] $outcome $symbols]
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
            incr seedFalse
            lappend rows "| $seed | FALSE PROOF: $name ($rec): $invalid |"
        } elseif {$v ne "proven" && $invalid eq ""} {
            if {$v eq "disproven"} {
                dict incr totals "disproven, no invalid run"
                incr failures
                lappend rows "| $seed | disproven but no run in the window is invalid: $name |"
            } else {
                dict incr totals "precision loss"
                set kinds {}
                foreach c [dict get $r claims] {
                    if {[namespace tail [dict get $c name]] eq $name} {
                        set kinds [lsort -unique [lmap d [dict get $c diagnostics] {dict get $d kind}]]
                    }
                }
                lappend rows "| $seed | precision loss: $name ($rec): [join $kinds {, }] |"
            }
        }
        dict incr counts $v
    }
    if {[dict get $options -original]} {
        # The exploratory checker, on a program that calls every function
        # through a list it cannot see into.
        set calls ""
        foreach claim $claims {
            lassign $claim name rec fails
            set h ""
            if {$fails} { set h ":\n        on gen${seed}::E:\n            -3" }
            append calls "fn s_$name\(x: int) -> int:\n    gen${seed}::$name\(x)$h\n    -1\n\n"
            append calls "fn r_$name\(x: int) -> int:\n    coroutine {step, first} = s_$name\(x)\n    first\n\n"
        }
        append calls "loop x in \[[join $gen::window {, }]\]:\n    \[[join [lmap c $claims {string cat r_[lindex $c 0] (x)}] {, }]\]\n"
        writeText [file join $dir main.bot] "import gen$seed\nimport std::coroutine\n\n$calls"
        if {![catch {emitcheck::check [file join $dir main.bot]} o]} {
            set rejected [dict create]
            foreach d [dict get $o diagnostics] {
                foreach rel [dict get $d related] {
                    if {[regexp {^checking (\S+)'s claim} [lindex $rel 0] -> fn]} {
                        dict set rejected [namespace tail $fn] 1
                    }
                }
                if {[dict get $d kind] eq "EMIT-INCOMPLETE"} {
                    foreach e [dict get $o emitters] {
                        if {[dict get $e location] eq [dict get $d location]} {
                            dict set rejected [namespace tail [dict get $e name]] 1
                        }
                    }
                }
            }
            foreach e [dict get $o emitters] {
                set name [namespace tail [dict get $e name]]
                if {[dict exists $rejected $name]} continue
                dict incr totals "exploratory proved"
                if {[dict get $verdicts $name] eq "disproven"} {
                    dict incr totals "exploratory false proof"
                    lappend rows "| $seed | exploratory false proof: $name |"
                }
            }
        }
    }
    lappend rows "| $seed | [join [lmap {k v} $counts {string cat $k " " $v}] {, }] |"
    file delete -force $dir
}

set report [list "## Generated emitters against exhaustive execution" "" \
    "seeds [dict get $options -seeds], [dict get $options -functions] claimed functions each, x in -6..120 and three huge values" "" \
    "| seed | result |" "|---|---|" {*}$rows "" "| total | |" "|---|---:|"]
dict for {k v} $totals {
    lappend report "| $k | $v |"
}
set text [join $report \n]
if {[dict get $options -out] ne ""} {
    writeText [dict get $options -out] "$text\n"
}
puts $text
exit [expr {$failures > 0}]
