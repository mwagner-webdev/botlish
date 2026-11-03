# census.tcl -- Stage A of LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md:
# what affine release does today, reproduced.
#
#   tclsh9.0 audit/lexical-cleanup/tools/census.tcl
#
# For every program in audit/lexical-cleanup/census/: its value on the four
# backends, the release flags of its HIR (where each owned value dies), the
# coroutines the interpreter releases (core::coroutines::releaseTrace, in
# release order, numbered by construction), and the native coroutine
# counters (native::allocationReport): stacks released, and suspended
# coroutines a collection swept without a release.

source [file join [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]

set dir [file join $::projectRoot audit lexical-cleanup census]
foreach path [lsort [glob -directory $dir *.bot]] {
    set name [file tail $path]
    puts "== $name"
    set hir [surface::readProgramFile $path -warnings off]
    foreach backend {interp compile cranelift-generic cranelift} {
        set outcome [outcomeUnderHir $backend $hir]
        puts [format "   %-18s %s" $backend [string range [lrange $outcome 0 1] 0 300]]
    }
    # The program's own release flags (a library module's are its own).
    set flags {}
    set own 1
    foreach line [split [hir::format $hir] \n] {
        if {[regexp {^e[0-9]+ bind b[0-9]+ (\S+) } $line -> name]} {
            set own [expr {![string match std::* $name]}]
        }
        if {$own && [regexp {(release=|exit-release=|error-release=)} $line]} {
            lappend flags [string trim $line]
        }
    }
    puts "   release flags in the program's own HIR ([llength $flags]):"
    foreach f $flags {
        puts "      $f"
    }
    set core::coroutines::releaseTrace {}
    try {
        outcomeUnderHir interp $hir
        set ids $core::coroutines::releaseTrace
    } finally {
        set core::coroutines::releaseTrace none
    }
    puts "   interp releases (coroutine ids, release order): $ids"
    if {![catch {dict get [native::allocationReport $hir summary] coroutines} counters]} {
        puts "   native coroutine counters: $counters"
    }
}
