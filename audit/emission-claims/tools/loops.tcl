# loops.tcl -- the counted-loop entry differential (EMISSION-COUNTED-LOOP-
# PRECISION-MILESTONE-1.md, section 12): generated claimed emitters whose
# counted loops are, or are not, entered by the facts before them, each
# checked by the compiler and run for real on every argument tuple of a box
# around its constants.
#
#   tclsh9.0 audit/emission-claims/tools/loops.tcl ?-count N? ?-seed S?
#       ?-cross K? ?-backends LIST? ?-out FILE? ?-show 1?
#
# A case is one claimed function `f(a: int, n: int) errors Bad emits R` (R
# `ones`, '1'+, or `ab`, 'a' 'b'*: both nonempty, so a loop that may run
# zero times before the first symbol is exactly what the claim must not
# survive) built from: a guard on n and on a (none, `n < L`, `n > H`, both,
# a hole `n == K`, a point `n != K`, a branch that yields and returns, a
# handled helper that only fails), a counted loop (start and end each a
# parameter or a constant, up or down, `to` or `through`), a body (a yield
# of the token's symbols, a `break`, `continue`, `return` or `fail` at one
# iteration, a later iteration's invalid symbol, a helper that yields then
# may fail, handled by a handler that emits nothing, a valid or an invalid
# symbol, a nested loop over the other parameter), sometimes a symbol after
# the loop, and sometimes the guard and the loop in a helper the claimed
# function calls (its summary per argument context). Every constant is
# offset by one of 0, 2^63 and 10^23 (the box with it): bounds past the
# machine words, never a sentinel.
#
# For each case:
#
#   1. the compiler's verdict, and the verdict of the rule before this
#      milestone (hir::emission::Entered answering 0: the loop's zero-
#      iteration exit always kept), in the same process;
#   2. the function run (audit/emission-claims/tools/witness.tcl's traces,
#      its claims erased) for every (a, n) of the box (-5..7 around the
#      offset), on the Tcl compiler; every K-th case (-cross) also on the
#      interpreter and the native backends, which must give the same traces;
#   3. every trace judged by the reference interpreter (tests/dfa-support.tcl,
#      which reads the declarations, nothing of the checker): a completed
#      run exactly one token, a failed one a viable prefix.
#
# A proven claim with an invalid trace is a false certificate: the tool
# fails. A claim proved before and not now is a regression: the tool fails.
# A claim the compiler does not prove whose every run in the box is valid is
# a precision limit (reported, never a failure: the box is not every Int).

set here [file dirname [file normalize [info script]]]
set options [dict merge {-count 120 -seed 1 -cross 10 -backends {interp cranelift-generic cranelift} -out "" -show 0} $argv]
set argv {}
source [file join $here witness.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval loops {
    variable lines {}
    variable header "import std::dfa\n\ndfa ones over ascii:\n    start:\n        '1' -> more\n    more:\n        '1' -> more\n        end -> accept\n\ndfa ab over ascii:\n    start:\n        'a' -> rest\n    rest:\n        'b' -> rest\n        end -> accept\n\nerror Bad\n\nfn maybe_fail(b: bool) -> unit errors Bad:\n    if b:\n        fail Bad\n    unit\n\nfn sym_then_maybe_fail(s: int, b: bool) -> unit errors Bad:\n    yield s\n    if b:\n        fail Bad\n    unit\n\n"
}

proc loops::out {line} {
    variable lines
    lappend lines $line
    puts $line
    flush stdout
}

proc loops::pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc loops::chance {p} {
    return [expr {rand() < $p}]
}

# The text of one case: {TEXT GRAMMAR OFFSET DESCRIPTION}. Its claimed
# function is f$K; a helper h$K when the loop is in one.
proc loops::Case {k} {
    set offset [pick {0 0 0 9223372036854775808 100000000000000000000000}]
    set grammar [pick {ones ones ab}]
    if {$grammar eq "ones"} {
        set first 49
        set rest 49
        set bad 120
    } else {
        set first 97
        set rest 98
        set bad 120
    }
    # Constants of the case, all offset.
    proc K {v} [list expr "\$v + $offset"]
    set desc {}
    # --- the loop: start and end each a parameter or a constant
    set direction [pick {up up up down}]
    set endKind [pick {to to through}]
    set startC [K [expr {int(rand() * 5) - 2}]]
    set endC [K [expr {int(rand() * 7) - 2}]]
    if {$direction eq "up"} {
        set start [pick [list $startC $startC a]]
        set end [pick [list n n $endC]]
        set clause "i from $start $endKind $end"
    } else {
        set start [pick [list n n a]]
        set end [pick [list $startC $endC a]]
        set clause "i down from $start $endKind $end"
    }
    # --- guards: on the parameters the loop reads, their constants near the
    # loop's (so that the loop is entered, or misses it by one, often), and
    # sometimes on the other one or of another kind.
    set guard ""
    set gdesc {}
    foreach p {a n} {
        set used [expr {$p eq $start || $p eq $end}]
        if {!$used && [chance 0.7]} continue
        # The constant the guard is about: the loop's other bound, or 0.
        set near [K 0]
        if {$p eq $end && [string is entier -strict $start]} { set near $start }
        if {$p eq $start && [string is entier -strict $end]} { set near $end }
        set l [expr {$near + [pick {-1 0 0 1 1 2}]}]
        set h [expr {$near + [pick {-2 -1 0 0 1 3}]}]
        set kinds {lower lower lower upper both both none hole point returns handled}
        if {$p eq $start && $direction eq "up" || $p eq $end && $direction eq "down"} {
            # The side the loop's test reads is this parameter's largest
            # (an ascending start, a descending end): bounded above.
            set kinds {upper upper both both both lower none hole point returns handled}
        }
        set g [pick $kinds]
        switch -- $g {
            none {}
            lower { append guard "    if $p < $l:\n        fail Bad\n" }
            upper { append guard "    if $p > $h:\n        fail Bad\n" }
            both {
                if {$h < $l} { lassign [list $h $l] l h }
                append guard "    if $p < $l or $p > $h:\n        fail Bad\n"
            }
            hole { append guard "    if $p == $l:\n        fail Bad\n" }
            point { append guard "    if $p != $h:\n        fail Bad\n" }
            returns { append guard "    if $p < $l:\n        yield $first\n        yield $rest\n        return unit\n" }
            handled { append guard "    maybe_fail($p < $l):\n        on Bad:\n            unit\n" }
        }
        lappend gdesc "$p:$g"
    }
    set desc [concat $gdesc [list "loop $clause"]]
    # --- the body: one or two statements around the symbol
    set body ""
    set ci [K [expr {int(rand() * 5) - 2}]]
    set stmt [pick {plain plain plain plain plain plain break continue return fail later first-differs first-differs helper-none helper-valid helper-valid helper-invalid nested}]
    switch -- $stmt {
        plain { append body "        yield [Sym $grammar]\n" }
        break { append body "        if i == $ci:\n            break\n        yield [Sym $grammar]\n" }
        continue { append body "        if i == $ci:\n            continue\n        yield [Sym $grammar]\n" }
        return { append body "        if i == $ci:\n            return unit\n        yield [Sym $grammar]\n" }
        fail { append body "        if i == $ci:\n            fail Bad\n        yield [Sym $grammar]\n" }
        later { append body "        if i != $ci:\n            yield $bad\n        yield [Sym $grammar]\n" }
        first-differs {
            # The token's first symbol in the iteration where i is the
            # start (when the start is a constant), its rest otherwise.
            append body "        if i == $start:\n            yield $first\n        else:\n            yield $rest\n"
        }
        helper-none { append body "        sym_then_maybe_fail([Sym $grammar], i == $ci):\n            on Bad:\n                unit\n" }
        helper-valid { append body "        sym_then_maybe_fail([Sym $grammar], i == $ci):\n            on Bad:\n                yield $rest\n" }
        helper-invalid { append body "        sym_then_maybe_fail([Sym $grammar], i == $ci):\n            on Bad:\n                yield $bad\n" }
        nested { append body "        loop j from [K 0] to a:\n            yield [Sym $grammar]\n            continue\n" }
    }
    append body "        continue\n"
    lappend desc $stmt
    set after ""
    if {[chance 0.15]} {
        append after "    yield [Sym $grammar]\n"
        lappend desc after
    }
    set loop "    loop $clause:\n$body"
    set inHelper [chance 0.25]
    set text ""
    if {$inHelper} {
        lappend desc helper
        append text "fn h$k\(a: int, n: int) -> unit errors Bad:\n$guard$loop$after    unit\n\n"
        append text "fn f$k\(a: int, n: int) -> unit errors Bad emits $grammar:\n    h$k\(a, n)\n    unit\n\n"
    } else {
        append text "fn f$k\(a: int, n: int) -> unit errors Bad emits $grammar:\n$guard$loop$after    unit\n\n"
    }
    return [list $text $grammar $offset [join $desc ", "]]
}

# A symbol of GRAMMAR's token for the body: ones' '1'; ab's first symbol
# ('a') or its rest ('b'), chosen per case.
proc loops::Sym {grammar} {
    if {$grammar eq "ones"} { return 49 }
    return [pick {97 98 98}]
}

# {VERDICT KINDS} of every claim of the HIR of DIR's main.bot (its module
# loopcase.bot), by function.
proc loops::Verdicts {dir} {
    set hir [emit::compile [file join $dir main.bot]]
    set out [dict create]
    foreach r [emit::results $hir loopcase.bot] {
        dict set out [lindex $r 0] [lrange $r 1 2]
    }
    return [list $hir $out]
}

proc loops::run {options} {
    variable header
    expr {srand([dict get $options -seed])}
    set count [dict get $options -count]
    set cases {}
    set text $header
    for {set k 0} {$k < $count} {incr k} {
        lassign [Case $k] t grammar offset desc
        append text $t
        lappend cases [list $k $grammar $offset $desc $t]
    }
    set dir [emit::workspace loopcase.bot $text main.bot "import loopcase\n\n0\n"]
    set t0 [clock milliseconds]
    lassign [Verdicts $dir] hir now
    set checkMs [expr {[clock milliseconds] - $t0}]
    set stats $::hir::emission::stats
    # The rule before this milestone, in the same process: Entered 0.
    set ::hir::emission::useMemo 0
    rename ::hir::emission::Entered ::hir::emission::Entered_current
    proc ::hir::emission::Entered {induction} { return 0 }
    set t0 [clock milliseconds]
    lassign [Verdicts $dir] - before
    set beforeMs [expr {[clock milliseconds] - $t0}]
    rename ::hir::emission::Entered {}
    rename ::hir::emission::Entered_current ::hir::emission::Entered
    set ::hir::emission::useMemo 1
    set copy [emitw::Stripped $dir]
    set model [emit::reference $copy main.bot]
    set tally [dict create proven 0 rejected 0 not-proved 0 dependent 0 new 0 regressed 0 false 0 precision 0 runs 0 invalid 0 cross 0 crossDiffer 0]
    foreach c $cases {
        lassign $c k grammar offset desc t
        set f f$k
        lassign [dict getdef $now $f {missing {}}] verdict kinds
        lassign [dict getdef $before $f {missing {}}] old -
        dict incr tally $verdict
        set tuples {}
        for {set a -5} {$a <= 7} {incr a} {
            for {set n -5} {$n <= 7} {incr n} {
                lappend tuples [list [expr {$a + $offset}] [expr {$n + $offset}]]
            }
        }
        set runs [emitw::traces $copy loopcase::$f {int int} {loopcase::Bad} $tuples]
        set bad {}
        foreach r $runs {
            lassign $r tuple outcome symbols
            dict incr tally runs
            set j [emit::judge $model [list loopcase $grammar] $outcome $symbols]
            if {$j ne "ok"} {
                dict incr tally invalid
                if {[llength $bad] < 1} { lappend bad [list $tuple [lindex $j 1]] }
            }
        }
        set mark ""
        if {$verdict eq "proven" && $bad ne {}} {
            dict incr tally false
            set mark "FALSE CERTIFICATE"
        }
        if {$old eq "proven" && $verdict ne "proven"} {
            dict incr tally regressed
            set mark "REGRESSED"
        }
        if {$old ne "proven" && $verdict eq "proven"} {
            dict incr tally new
        }
        if {$verdict ne "proven" && $bad eq {}} {
            dict incr tally precision
            set mark "(precision limit: no run in the box shows an invalid trace)"
        }
        if {[dict get $options -cross] > 0 && $k % [dict get $options -cross] == 0} {
            foreach b [dict get $options -backends] {
                dict incr tally cross
                if {[catch {emitw::traces $copy loopcase::$f {int int} {loopcase::Bad} $tuples -backend $b} other]} {
                    set other [list error $other]
                }
                if {$other ne $runs} {
                    dict incr tally crossDiffer
                    append mark " BACKEND $b DIFFERS"
                }
            }
        }
        if {$mark ne "" || [dict get $options -show]} {
            out "case $k ($desc; offset $offset; $grammar): $verdict $kinds (before: $old) [lindex $bad 0] $mark"
            if {$mark ne ""} { out [string trimright $t] }
        }
    }
    out ""
    out "cases: $count (seed [dict get $options -seed]); verdicts: proven [dict get $tally proven], rejected [dict get $tally rejected], not-proved [dict get $tally not-proved], dependent [dict get $tally dependent]"
    out "newly proven (the rule before this milestone did not): [dict get $tally new]; regressed (proven before, not now): [dict get $tally regressed]"
    out "runs: [dict get $tally runs], invalid traces: [dict get $tally invalid]; false certificates: [dict get $tally false]; precision limits (not proved, every run in the box valid): [dict get $tally precision]"
    out "backends: [dict get $tally cross] cross-checks on [dict get $options -backends], [dict get $tally crossDiffer] differing from the Tcl compiler's traces"
    out "checking: [expr {$checkMs / 1000.0}] s for $count claims (summaries computed [dict getdef $stats summariesComputed ?], reused [dict getdef $stats summariesReused ?], rounds [dict getdef $stats rounds ?]); the rule before: [expr {$beforeMs / 1000.0}] s"
    emit::cleanup
    return [expr {[dict get $tally false] == 0 && [dict get $tally regressed] == 0 && [dict get $tally crossDiffer] == 0}]
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    set ok [loops::run $options]
    if {[dict get $options -out] ne ""} {
        emit::writeText [dict get $options -out] "[join $::loops::lines \n]\n"
    }
    exit [expr {!$ok}]
}
