# loops-bench.tcl -- what counted-loop entry costs the emission checker
# (EMISSION-COUNTED-LOOP-PRECISION-MILESTONE-1.md, section 15): the checking
# time, summaries, fixpoint rounds and loop walks of the claims of a few
# workloads, under the current rule and under the rule before the milestone
# (hir::emission::Entered answering 0: every counted loop keeps its zero-
# iteration exit), each scenario in a fresh process, the certificate memo
# off.
#
#   tclsh9.0 audit/emission-claims/tools/loops-bench.tcl ?-runs 5? ?-scenarios LIST?
#       ?-out FILE?
#
# Workloads: the CSV workload's 52 claims (examples/dfa/csv/export.bot), the
# JSON workload's 22 (examples/dfa/json/emit_probes.bot), the selective
# field before this milestone (its first character peeled) and after (one
# loop), and the counted-loop claims of tests/emission-claims.test's
# ec-loop-entered-guards. A loop walk is one walk of a loop body (the first
# iteration, a fixpoint round or an unrolled iteration); loop evaluations
# count EvalLoop calls. Times are medians; counts are the same every run.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-runs 5 -out "" -scenario "" -rule current -scenarios {csv json selective-peeled selective-loop loops}} $argv]
set argv {}
set root [file dirname [file dirname [file dirname $here]]]

if {[dict get $options -scenario] eq ""} {
    source [file join $root tests helpers.tcl]
    proc median {xs} {
        set s [lsort -real $xs]
        return [lindex $s [expr {[llength $s] / 2}]]
    }
    set lines {}
    lappend lines "| workload | rule | claims proven | check ms (median) | of it: certificates ms | summaries computed / reused | rounds | loop evaluations | loop walks |"
    lappend lines "|---|---|---:|---:|---:|---:|---:|---:|---:|"
    foreach scenario [dict get $options -scenarios] {
        foreach rule {before current} {
            set times {}
            set certs {}
            set last ""
            for {set i 0} {$i < [dict get $options -runs]} {incr i} {
                set out [exec [info nameofexecutable] [info script] -scenario $scenario -rule $rule 2>@1]
                set last [lindex [split [string trim $out] \n] end]
                lappend times [dict get $last ms]
                lappend certs [dict get $last certify]
            }
            set line "| $scenario | $rule | [dict get $last proven] / [dict get $last claims] | [median $times] | [median $certs] | [dict get $last computed] / [dict get $last reused] | [dict get $last rounds] | [dict get $last loops] | [dict get $last walks] |"
            lappend lines $line
            puts $line
        }
    }
    if {[dict get $options -out] ne ""} {
        set f [open [dict get $options -out] w]
        puts $f [join $lines \n]
        close $f
    }
    exit 0
}

# --- one scenario, in this process
source [file join $root tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]
source [file join $::projectRoot tests emission-support.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit
set ::hir::emission::useMemo 0

proc copyDir {from} {
    set dir [file tempdir loops-bench]
    foreach path [glob -directory $from *.bot] {
        file copy $path $dir
    }
    return $dir
}

set scenario [dict get $options -scenario]
switch -- $scenario {
    csv {
        set dir [copyDir [file join $::projectRoot examples dfa csv]]
        set entry [file join $dir export.bot]
    }
    json {
        set dir [copyDir [file join $::projectRoot examples dfa json]]
        set entry [file join $dir emit_probes.bot]
    }
    selective-peeled - selective-loop {
        set dir [copyDir [file join $::projectRoot examples dfa csv]]
        set path [file join $dir selective_emit.bot]
        set text [emit::readText $path]
        if {$scenario eq "selective-peeled"} {
            foreach profile {csv_strict csv_utf8} {
                set loop "        loop i from 0 to n:\n            c = value.char_at(i).scalar_value()\n            ${profile}::text_char(c):\n"
                set peel "        c0 = value.char_at(0).scalar_value()\n        ${profile}::text_char(c0):\n            on std::dfa::UnrecognizedInput:\n                fail QuotingDecision {at: 0, value: c0}\n            on std::dfa::UnexpectedEnd:\n                fail QuotingDecision {at: 0, value: c0}\n        yield c0\n        loop i from 1 to n:\n            c = value.char_at(i).scalar_value()\n            ${profile}::text_char(c):\n"
                set text [string map [list $loop $peel] $text]
            }
            emit::writeText $path $text
        }
        set entry [file join $dir main.bot]
        emit::writeText $entry "import selective_emit\n\n0\n"
    }
    loops {
        # ec-loop-entered-guards' program.
        set test [emit::readText [file join $::projectRoot tests emission-claims.test]]
        regexp {set onesDfa "([^"]*)"} $test -> header
        set header [string map {\\n \n} $header]
        set at [string first "test ec-loop-entered-guards " $test]
        set from [expr {[string first "    loopClaims \{" $test $at] + [string length "    loopClaims \{"]}]
        set to [expr {[string first "\}\n\} -result" $test $from] - 1}]
        set body [string range $test $from $to]
        set dir [emit::workspace main.bot "$header$body\n\n0\n"]
        set entry [file join $dir main.bot]
    }
}
if {[dict get $options -rule] eq "before"} {
    # Load the checker, then make it the rule before the milestone.
    set warm [emit::workspace main.bot "0\n"]
    emit::compile [file join $warm main.bot]
    proc ::hir::emission::Entered {induction} { return 0 }
}
set ::loopEvaluations 0
set ::loopWalks 0
set ::loopBodies [dict create]
# Counting wrappers (instrumentation of this process only).
set warm [emit::workspace main.bot "0\n"]
emit::compile [file join $warm main.bot]
rename ::hir::emission::EvalLoop ::hir::emission::EvalLoop_counted
proc ::hir::emission::EvalLoop {e node s} {
    incr ::loopEvaluations
    dict set ::loopBodies [dict get $node body] 1
    return [::hir::emission::EvalLoop_counted $e $node $s]
}
rename ::hir::emission::EvalBody ::hir::emission::EvalBody_counted
proc ::hir::emission::EvalBody {body s} {
    if {[dict exists $::loopBodies $body]} { incr ::loopWalks }
    return [::hir::emission::EvalBody_counted $body $s]
}
set hir [emit::compile $entry]
set stats $::hir::emission::stats
set claims [hir::emission::claims $hir]
set proven [llength [lmap r $claims {if {[dict get $r verdict] ne "proven"} continue; set r}]]
file delete -force $dir
puts [dict create ms [expr {[dict get $stats checkMicroseconds] / 1000.0}] certify [expr {[dict getdef $stats certifyMicroseconds 0] / 1000.0}] claims [llength $claims] proven $proven \
    computed [dict get $stats summariesComputed] reused [dict get $stats summariesReused] rounds [dict get $stats rounds] \
    loops $::loopEvaluations walks $::loopWalks]
