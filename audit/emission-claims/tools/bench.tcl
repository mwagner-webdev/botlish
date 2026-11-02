# bench.tcl -- the costs of emission claims (EMISSION-CLAIMS-MILESTONE-1.md,
# "Compilation and native performance"): the checker's time on the
# modular prototype's workloads, summary reuse, recognizer products, the
# certificate memo's validation and invalidation, the front end's overhead,
# interchange size, the cost of a rejected claim's diagnostics, and the
# erasure of claims from native code.
#
#   tclsh9.0 audit/emission-claims/tools/bench.tcl ?-runs 3? ?-out FILE?
#
# Every scenario runs in a fresh process (no certificate memo, no warm
# caches but Tcl's own), -runs times; the report gives medians.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-runs 3 -out "" -scenario ""} $argv]
set argv {}

if {[dict get $options -scenario] eq ""} {
    # The driver.
    source [file join [file dirname [file dirname [file dirname $here]]] tests helpers.tcl]
    proc median {xs} {
        set s [lsort -real $xs]
        return [lindex $s [expr {[llength $s] / 2}]]
    }
    set results [dict create]
    foreach scenario {probes probes-stripped probes-separate library library-memo library-change invalid interchange native} {
        set runs {}
        for {set i 0} {$i < [dict get $options -runs]} {incr i} {
            if {[catch {exec [info nameofexecutable] [info script] -scenario $scenario 2>@1} out]} {
                puts stderr "$scenario: $out"
                set out ""
            }
            lappend runs [lindex [split [string trim $out] \n] end]
        }
        dict set results $scenario $runs
        puts "$scenario: [lindex $runs 0]"
    }
    proc field {results scenario key} {
        set m [median [lmap r [dict get $results $scenario] {dict getdef $r $key 0}]]
        # Milliseconds to the millisecond; counts stay integers.
        if {[string is integer -strict $m]} { return $m }
        return [format %.0f $m]
    }
    set p [dict get $results probes]
    set lines [list "## Costs (ms, median of [dict get $options -runs] runs, each a fresh process)" "" \
        "**examples/dfa/json/emit_probes.bot's 22 claims** (the prototype's check_all.bot):" "" \
        "| measure | integrated | prototype (MODULAR-EMISSION-PROOFS-MILESTONE-1.md) |" "|---|---:|---:|" \
        "| check, summaries shared | [field $results probes check] | 372 |" \
        "| of it: products with certificates' languages | [field $results probes compose] | 87 |" \
        "| of it: certificates | [field $results probes certify] | 32 |" \
        "| each claim checked alone, fresh state | [field $results probes-separate check] | 1169 |" \
        "| summaries computed / reused (shared) | [field $results probes summaries] / [field $results probes reused] | 140 / 60 |" \
        "| summaries computed (each alone) | [field $results probes-separate summaries] | 348 |" \
        "| fixpoint rounds | [field $results probes rounds] | 44 |" \
        "| whole compilation with the claims | [field $results probes total] | - |" \
        "| whole compilation, claims removed | [field $results probes-stripped total] | - |" \
        "" "**examples/dfa/json/emitlib.bot from a program that calls none of it** (10 claims, number_emit's among them):" "" \
        "| measure | integrated | prototype |" "|---|---:|---:|" \
        "| check, no memo | [field $results library check] | 127 |" \
        "| check, a later compilation reusing the memo's certificates | [field $results library-memo check] | 20 |" \
        "| of it: validation | [field $results library-memo validate] | 6 |" \
        "| certificates reused | [field $results library-memo reusedClaims] | 10 |" \
        "| check after a helper's change (hex_digit) | [field $results library-change check] | 59 |" \
        "| claims re-proved after it | [field $results library-change reproved] | 1 |" \
        "| check per imported, uncalled claim | [format %.0f [expr {[field $results library check] / 10.0}]] | - |" \
        "" "**A rejected claim's diagnostics** (invalid_emitter.bot): check [field $results invalid check] ms, [field $results invalid diagnostics] diagnostics." \
        "" "**Interchange** (emit_probes.bot): [field $results interchange bytes] bytes with its claims' records, [field $results interchange stripped] without claims ([format %.1f [expr {100.0 * ([field $results interchange bytes] - [field $results interchange stripped]) / [field $results interchange stripped]}]]% more); decoding re-proves: [field $results interchange decode] ms." \
        "" "**Native code** (emitlib::json_string_source driven and fused): fused NIR equal with and without the claims: [lindex [dict get $results native] 0 1]; coroutine allocations [lindex [dict get $results native] 0 3] and [lindex [dict get $results native] 0 5]; table loads, switches, dfa#transition: [lindex [dict get $results native] 0 7]."]
    set text [join $lines \n]
    puts $text
    if {[dict get $options -out] ne ""} {
        set f [open [dict get $options -out] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts $f $text
        close $f
    }
    exit 0
}

# A scenario, in this process.
source [file join $here witness.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit
set ::hir::emission::useMemo 0

proc ms {us} { return [expr {$us / 1000.0}] }
proc stat {key} { return [ms [dict getdef $::hir::emission::stats $key 0]] }

set scenario [dict get $options -scenario]
set result [dict create]
switch -- $scenario {
    probes {
        set dir [emit::workspace]
        set t0 [clock microseconds]
        emit::compile [file join $dir emit_probes.bot]
        dict set result total [ms [expr {[clock microseconds] - $t0}]]
        dict set result check [stat checkMicroseconds]
        dict set result compose [stat composeMicroseconds]
        dict set result certify [stat certifyMicroseconds]
        dict set result summaries [dict get $::hir::emission::stats summariesComputed]
        dict set result reused [dict get $::hir::emission::stats summariesReused]
        dict set result rounds [dict get $::hir::emission::stats rounds]
    }
    probes-stripped {
        set dir [emit::workspace]
        foreach f {number_emit string_emit value_emit emitlib} {
            set path [file join $dir $f.bot]
            emit::writeText $path [emit::strip [emit::readText $path]]
        }
        set t0 [clock microseconds]
        emit::compile [file join $dir emit_probes.bot]
        dict set result total [ms [expr {[clock microseconds] - $t0}]]
    }
    probes-separate {
        set dir [emit::workspace]
        set hir [emit::compile [file join $dir emit_probes.bot]]
        set total 0
        set summaries 0
        foreach r [hir::emission::claims $hir] {
            set copy $hir
            dict set copy diagnostics {}
            set t0 [clock microseconds]
            hir::emission::Reset $copy
            hir::emission::Check [list [dict get $r block]]
            incr total [expr {[clock microseconds] - $t0}]
            incr summaries $::hir::emission::computed
        }
        # (A function with two claims is checked twice: both claims each
        # time, as the prototype's one run per claim did not.)
        dict set result check [ms $total]
        dict set result summaries $summaries
    }
    library {
        set dir [emit::workspace main.bot "import emitlib\n\n0\n"]
        emit::compile [file join $dir main.bot]
        dict set result check [stat checkMicroseconds]
    }
    library-memo {
        set ::hir::emission::useMemo 1
        set dir [emit::workspace a.bot "import emitlib\n\n0\n" b.bot "import emitlib\n\nfn uses() -> int:\n    3\n\nuses()\n"]
        emit::compile [file join $dir a.bot]
        emit::compile [file join $dir b.bot]
        dict set result check [stat checkMicroseconds]
        dict set result validate [stat validateMicroseconds]
        dict set result reusedClaims [llength [dict get $::hir::emission::stats reusedClaims]]
    }
    library-change {
        set ::hir::emission::useMemo 1
        set dir [emit::workspace main.bot "import emitlib\n\n0\n"]
        emit::compile [file join $dir main.bot]
        set lib [file join $dir emitlib.bot]
        emit::writeText $lib [string map {"        yield 87 + n" "        yield 55 + n"} [emit::readText $lib]]
        set hir [emit::compile [file join $dir main.bot]]
        dict set result check [stat checkMicroseconds]
        dict set result reproved [expr {[llength [hir::emission::claims $hir]] - [llength [dict get $::hir::emission::stats reusedClaims]]}]
    }
    invalid {
        set hir [emit::compile [file join $::emit::jsonDir invalid_emitter.bot]]
        dict set result check [stat checkMicroseconds]
        dict set result diagnostics [llength [lmap d [dict get $hir diagnostics] {if {![string match EMIT-* [dict get $d kind]]} continue; set d}]]
    }
    interchange {
        set dir [emit::workspace]
        set hir [emit::compile [file join $dir emit_probes.bot]]
        set text [hir::interchange::encode $hir]
        dict set result bytes [string length [encoding convertto utf-8 $text]]
        set t0 [clock microseconds]
        hir::interchange::decode $text
        dict set result decode [ms [expr {[clock microseconds] - $t0}]]
        foreach f {number_emit string_emit value_emit emitlib} {
            set path [file join $dir $f.bot]
            emit::writeText $path [emit::strip [emit::readText $path]]
        }
        set bare [emit::compile [file join $dir emit_probes.bot]]
        dict set result stripped [string length [encoding convertto utf-8 [hir::interchange::encode $bare]]]
    }
    native {
        set main "import emitlib\nimport std::coroutine\n\nfn text(t: str) -> int errors IndexNotFound:\n    coroutine {step, first} = emitlib::json_string_source(t)\n    n = first\n    loop:\n        if std::coroutine::done?(step):\n            break\n        step()\n        continue\n    n\n\nloop i from 0 to 50:\n    text(\"a\\\"b\\\\c\"):\n        on IndexNotFound:\n            -2\n"
        set dir [emit::workspace main.bot $main]
        set hir [surface::readProgramFile [file join $dir main.bot] -warnings off]
        set nir [native::fusedNir $hir]
        set a [native::allocationReport $hir summary]
        set lib [file join $dir emitlib.bot]
        emit::writeText $lib [emit::strip [emit::readText $lib]]
        set bareHir [surface::readProgramFile [file join $dir main.bot] -warnings off]
        set bare [native::fusedNir $bareHir]
        set b [native::allocationReport $bareHir summary]
        set count {report {
            if {[dict exists $report byKind Coroutine]} { dict get $report byKind Coroutine allocations } else { string cat 0 }
        }}
        dict set result equal [expr {$nir eq $bare}]
        dict set result coroutinesClaimed [apply $count $a]
        dict set result coroutinesBare [apply $count $b]
        dict set result grammar [expr {[regexp -all {rtabload} $nir] + [regexp -all -line {^\s*switch } $nir] + [regexp -all {dfa#transition} $nir]}]
    }
}
emit::cleanup
puts $result
