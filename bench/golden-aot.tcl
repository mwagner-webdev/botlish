# golden-aot.tcl -- what an ahead-of-time executable of a golden suite costs
# against the JIT path (LARGE-SCALE-GOLDEN-MIGRATION.md, "Ahead-of-time
# executables"): each suite in a fresh tclsh, compiled once, then
#
#   AOT    native::executable (readiness check, specialization, NIR lowering,
#          object emission and linking against the runtime library), then one
#          run of the executable
#   JIT    native::evalHir of the same HIR (NIR lowering, Cranelift code
#          generation and one run in the driver)
#
#   tclsh9.0 bench/golden-aot.tcl ?FILE.bot ...?    (default: every suite)
#
# A suite that is not AOT-ready (a region that needs a runtime-guarded
# instance, from which AOT never falls back) reports its first blockers; a
# ready one whose executable fails to build reports the failure. A
# suite's report is its program's value: the executable reports it through
# the driver protocol (BOTLISH_NATIVE_RESULT: an executable prints no value,
# PROGRAM-OUTPUT-MILESTONE-1.md), and its summary ("N passed, M failed")
# must equal the JIT run's. Needs the release
# native backend (cargo build --release --manifest-path native/Cargo.toml).

set root [file dirname [file dirname [file normalize [info script]]]]
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8

proc seconds {us} { return [expr {$us / 1e6}] }

if {[lindex $argv 0] eq "-one"} {
    source [file join $root compiler compiler.tcl]
    source [file join $root surface surface.tcl]
    source [file join $root native native.tcl]
    interp recursionlimit {} 100000
    set path [lindex $argv 1]
    set dir [file tempdir botlish-golden-aot]
    try {
        set t0 [clock microseconds]
        set hir [surface::readProgramFile $path -warnings off]
        set t1 [clock microseconds]
        set result [dict create suite [file tail $path] frontend [seconds [expr {$t1 - $t0}]]]
        set exe [file join $dir [file rootname [file tail $path]]]
        if {[catch {native::executable $hir $exe} message options]} {
            set t2 [clock microseconds]
            set lines [split $message \n]
            if {[dict get $options -errorcode] eq "NATIVE AOT NOT-READY"} {
                dict set result aot [dict create status not-ready seconds [seconds [expr {$t2 - $t1}]] \
                    why [lrange $lines 1 3]]
            } else {
                dict set result aot [dict create status failed seconds [seconds [expr {$t2 - $t1}]] \
                    why [list "[dict get $options -errorcode]: [lindex $lines 0]" {*}[lrange $lines 1 3]]]
            }
        } else {
            set t2 [clock microseconds]
            set resultFile [file join $dir result]
            set ::env(BOTLISH_NATIVE_RESULT) $resultFile
            try {
                exec $exe
            } finally {
                unset ::env(BOTLISH_NATIVE_RESULT)
            }
            set t3 [clock microseconds]
            set report [native::Outcome [split [string trim [core::ReadFile $resultFile]] \n]]
            set output [join [lmap line [core::value::items $report] {core::value::strOf $line}] \n]
            regexp {(\d+) passed, (\d+) failed} $output summary
            dict set result aot [dict create status ok seconds [seconds [expr {$t2 - $t1}]] \
                run [seconds [expr {$t3 - $t2}]] summary [expr {[info exists summary] ? $summary : "no summary"}]]
        }
        set t4 [clock microseconds]
        set jit [native::evalHir $hir]
        set t5 [clock microseconds]
        set jitSummary [core::value::strOf [lindex [core::value::items $jit] end]]
        dict set result jit [dict create seconds [seconds [expr {$t5 - $t4}]] summary $jitSummary]
        if {[dict get $result aot status] eq "ok"} {
            dict set result same [expr {[dict get $result aot summary] eq $jitSummary}]
        }
        puts $result
    } finally {
        file delete -force $dir
    }
    exit 0
}

set suites [expr {$argv eq {} ? [lmap p [lsort [glob -directory [file join $root tests golden] *.bot]] {file tail $p}] : $argv}]
set ready 0
set notReady 0
set failed 0
foreach suite $suites {
    set path [file join $root tests golden $suite]
    if {[catch {exec tclsh9.0 [info script] -one $path 2>@1} output]} {
        puts [format "%-40s ERROR %s" $suite [string range $output 0 300]]
        continue
    }
    set r [lindex [split [string trimright $output \n] \n] end]
    set aot [dict get $r aot]
    set jit [dict get $r jit seconds]
    if {[dict get $aot status] eq "ok"} {
        incr ready
        puts [format "%-40s front end %7.2f s | AOT build %6.2f s, run %6.3f s | JIT lower+codegen+run %6.2f s | build/JIT %4.1f | %s%s" \
            $suite [dict get $r frontend] [dict get $aot seconds] [dict get $aot run] $jit \
            [expr {$jit > 0 ? [dict get $aot seconds] / $jit : 0}] [dict get $aot summary] \
            [expr {[dict get $r same] ? "" : " -- JIT: [dict get $r jit summary]"}]]
    } elseif {[dict get $aot status] eq "not-ready"} {
        incr notReady
        puts [format "%-40s front end %7.2f s | NOT AOT-READY (found in %.2f s) | JIT lower+codegen+run %6.2f s" \
            $suite [dict get $r frontend] [dict get $aot seconds] $jit]
        foreach line [dict get $aot why] { puts "    $line" }
    } else {
        incr failed
        puts [format "%-40s front end %7.2f s | AOT BUILD FAILED (after %.2f s) | JIT lower+codegen+run %6.2f s" \
            $suite [dict get $r frontend] [dict get $aot seconds] $jit]
        foreach line [dict get $aot why] { puts "    $line" }
    }
    flush stdout
}
puts "\n[llength $suites] suites: $ready AOT-ready, $notReady not AOT-ready, $failed failed to build"
