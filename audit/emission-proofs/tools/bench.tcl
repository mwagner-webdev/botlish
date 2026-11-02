# bench.tcl -- what modular certification costs, and what it saves
# (MODULAR-EMISSION-PROOFS-MILESTONE-1.md, section 16).
#
#   tclsh9.0 audit/emission-proofs/tools/bench.tcl ?-parts {check runtime}?
#       ?-runs N? ?-out FILE?
#
#   check    check_all.bot's 22 claims (the exploratory milestone's
#            program): the exploratory checker (its front end, the
#            specialization and range analysis it reads, its walk) against
#            the modular one (its front end, its walk), with summaries
#            shared across claims and with every claim from scratch, and
#            composing by certificates and by bodies; the library from a
#            program that calls none of it; a store's validation; the
#            counterexample search
#   runtime  lib/emitbench.bot natively (cranelift, fused): a digit proved
#            from its declared domain, guarded, unchecked, validated at run
#            time; a string proved, and validated at run time -- ns per
#            emitted symbol, the best of N in-process runs

set here [file dirname [file normalize [info script]]]
set options [dict merge {-parts {check runtime} -runs 5 -out "" -rounds 3} $argv]
set argv {}
source [file join $here concrete.tcl]
source [file join $here workspace.tcl]
source [file join $here modcheck.tcl]
source [file join [file dirname [file dirname $here]] emitter tools emitcheck.tcl]
interp recursionlimit {} 200000
core::useProgramRecursionLimit

set report {}
proc out {line} { lappend ::report $line }

proc ms {script} {
    set t0 [clock microseconds]
    uplevel 1 $script
    return [expr {([clock microseconds] - $t0) / 1000}]
}

proc median {values} {
    set s [lsort -integer $values]
    return [lindex $s [expr {[llength $s] / 2}]]
}

if {"check" in [dict get $options -parts]} {
    set dir [epws::scratch]
    set path [file join $dir check_all.bot]
    set rounds [dict get $options -rounds]
    # The exploratory checker: its whole run, and its inputs alone.
    set orig {}
    set inputs {}
    for {set i 0} {$i < $rounds} {incr i} {
        lappend orig [ms {emitcheck::check $path}]
        lappend inputs [ms {
            emitcheck::Models $path
            set h [surface::readProgramFile $path -warnings off]
            hir::activate $h
            set spec [hir::specialize::analyze $h -call-facts-opt 1]
            hir::range::analyze $h $spec 1 1 1 1 ""
        }]
    }
    set o [median $orig]
    set oi [median $inputs]
    # The modular checker: shared summaries (the default), every claim
    # from scratch, and by bodies.
    set rows {}
    foreach {label opts} {
        "certificates, summaries shared" {-compose certificate}
        "bodies, summaries shared" {-compose body}
    } {
        set fe {}
        set ck {}
        foreach i [lrepeat $rounds x] {
            set r [modcheck::check $path -witness 0 {*}$opts]
            lappend fe [dict get $r stats frontEndMs]
            lappend ck [dict get $r stats checkMs]
        }
        lappend rows [list $label [median $fe] [median $ck] [dict get $r stats summariesComputed] [dict get $r stats summariesReused] \
            [dict get $r stats rounds] [dict get $r stats phaseMs]]
    }
    # Every claim from scratch: one run per claim (-only), its check time.
    set r [modcheck::check $path -witness 0]
    set names [lsort -unique [lmap c [dict get $r claims] {dict get $c name}]]
    set scratch 0
    set computed 0
    foreach n $names {
        set r1 [modcheck::check $path -witness 0 -only [list $n]]
        incr scratch [dict get $r1 stats checkMs]
        incr computed [dict get $r1 stats summariesComputed]
    }
    lappend rows [list "every claim from scratch (one run per function)" - $scratch $computed 0 - {}]
    out "## Checking check_all.bot's 22 claims (ms, median of $rounds)"
    out ""
    out "| checker | front end | check | summaries computed | summaries reused | solve rounds | of the check: composing, certifying (ms) |"
    out "|---|---:|---:|---:|---:|---:|---|"
    out "| exploratory: whole run | [expr {$oi}] (front end, specialization and range analysis) | [expr {$o - $oi}] | - | - | - | - |"
    foreach row $rows {
        lassign $row label fe ck c u rounds phases
        set p [join [lmap k {compose certify} {dict getdef $phases $k 0}] ", "]
        if {$phases eq {}} { set p - }
        out "| modular, $label | $fe | $ck | $c | $u | $rounds | $p |"
    }
    # Per claim, the default run.
    set r [modcheck::check $path -witness 0]
    out ""
    out "Per claim (the default run, in order; a claim's summaries include those an earlier claim made final):"
    out ""
    out "| claim | ms | summaries reachable | computed | reused |"
    out "|---|---:|---:|---:|---:|"
    foreach c [dict get $r claims] {
        out "| `[dict get $c name]` [namespace tail [dict get $c recognizer]] | [format %.1f [dict get $c ms]] | [dict get $c summaries] | [dict get $c computed] | [dict get $c reusedSummaries] |"
    }
    # The library, its store, its counterexample search.
    file copy -force [file join [file dirname $here] callers unused.bot] [file join $dir unused.bot]
    set u [file join $dir unused.bot]
    set store [file join $dir certs.store]
    set lib0 [modcheck::check $u -witness 0]
    set lib1 [modcheck::check $u -witness 0 -store $store]
    set lib2 [modcheck::check $u -witness 0 -store $store]
    set wit [modcheck::check $u -witness 1]
    set disproven [llength [lmap c [dict get $wit claims] {if {[dict get $c verdict] ne "disproven"} continue; set c}]]
    out ""
    out "## The library from a program that calls none of it (ms)"
    out ""
    out "| run | front end | check |"
    out "|---|---:|---:|"
    out "| no store | [dict get $lib0 stats frontEndMs] | [dict get $lib0 stats checkMs] |"
    out "| store, first compilation (proves, writes) | [dict get $lib1 stats frontEndMs] | [dict get $lib1 stats checkMs] |"
    out "| store, next compilation (validates, reuses) | [dict get $lib2 stats frontEndMs] | [dict get $lib2 stats checkMs] (validation [dict getdef [dict get $lib2 stats phaseMs] validate 0]) |"
    out "| with the counterexample search ($disproven claims disproven) | [dict get $wit stats frontEndMs] | [dict get $wit stats checkMs] |"
}

if {"runtime" in [dict get $options -parts]} {
    set main "import emitbench\nimport emitlib\n\nfn run(which: int, n: int) -> List\[int\] errors emitlib::NotADigit, emitbench::Invalid, IndexNotFound:\n    if which == 0:\n        return emitbench::digits_domain(n)\n    if which == 1:\n        return emitbench::digits_guarded(n)\n    if which == 2:\n        return emitbench::digits_unchecked(n)\n    if which == 3:\n        return emitbench::digits_validated(n)\n    if which == 4:\n        return emitbench::strings_static(n)\n    emitbench::strings_validated(n)\n\nrun(@W@, @N@):\n    on emitlib::NotADigit:\n        \[-1\]\n    on emitbench::Invalid:\n        \[-2\]\n    on IndexNotFound:\n        \[-3\]\n"
    out ""
    out "## Run time (cranelift, fused; ns per emitted symbol, best of [dict get $options -runs])"
    out ""
    out "| workload | what | symbols | ns/symbol |"
    out "|---|---|---:|---:|"
    foreach {w name n what} {
        0 digits_domain 20000 "digit_of: proved from the declared domain, no check"
        1 digits_guarded 20000 "digit_checked: a guard per symbol"
        2 digits_unchecked 20000 "digit_unchecked: no check, no certificate"
        3 digits_validated 20000 "digit_unchecked fed to the recognizer as emitted"
        4 strings_static 4000 "json_string: proved, no check"
        5 strings_validated 4000 "json_string fed to json_string_strict as emitted"
    } {
        set dir [epws::scratch main.bot [string map [list @W@ $w @N@ $n] $main]]
        set hir [surface::readProgramFile [file join $dir main.bot] -warnings off]
        lassign [native::measure $hir [dict get $options -runs]] lower compile us collections value
        if {![regexp {(-?\d+)} $value -> symbols] || $symbols <= 0} {
            out "| `$name` | $what | (failed: [string range $value 0 80]) | |"
            continue
        }
        out "| `$name` | $what | $symbols | [format %.1f [expr {$us * 1000.0 / $symbols}]] |"
    }
}

set text [join $report \n]
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    puts -nonewline $f "$text\n"
    close $f
}
puts $text
