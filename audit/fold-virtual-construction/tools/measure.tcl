# measure.tcl -- FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md's
# construction measurements: per program and size, the value, the List
# allocations and private List plans, the List elements copied, the
# construction counters (plans created, in-place extensions,
# materializations), the NIR's eager appends and plan extensions, the
# machine code size (the builder function's / the whole program's) and the best-of-RUNS native time (JIT compilation
# excluded); with -instructions 1, callgrind's instructions per run
# (audit/bench-bimodality/tools/profile.sh: the difference of a 4- and a
# 24-run profile of the standalone executable).
#
#   tclsh9.0 audit/fold-virtual-construction/tools/measure.tcl \
#       ?-root DIR? ?-sizes "128 1024 4096 16384"? ?-runs N? \
#       ?-instructions 0|1? ?-lower {OPTION VALUE ...}? FILE.bot ...
#
# -root names the checkout whose compiler measures (default: this one), so
# the tree before the milestone (a worktree whose native/target is a link
# to this one's: the backend is unchanged) measures the same files. A
# program with an `n = NUMBER` line is measured at every size of -sizes (the
# line rewritten in a private copy); any other once. -lower passes
# native::lower::program options (e.g. {-virtual-construction-opt 0}).
# Every copy lives in a `file tempdir` directory, removed at the end.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set sizes {128 1024 4096 16384}
set runs 20
set instructions 0
set lower {}
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -sizes { set sizes [lindex $argv [incr i]] }
        -runs { set runs [lindex $argv [incr i]] }
        -instructions { set instructions [lindex $argv [incr i]] }
        -lower { set lower [lindex $argv [incr i]] }
        default { lappend files [file normalize $arg] }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit

# The text of FILE with its `n = ...` line set to N.
proc sized {text n} {
    regsub -line {^n = [0-9]+$} $text "n = $n" text
    return $text
}

proc counter {report args} {
    if {[dict exists $report {*}$args]} {
        return [dict get $report {*}$args]
    }
    return 0
}

set work [file tempdir foldvc]
try {
    puts [format "%-30s %6s %10s %8s %8s %12s %7s %7s %6s %7s %7s %12s %10s %s" \
        program n time-us List ListPlan elem-copied created extend mat nir-app nir-ext code-B instr/run value]
    foreach path $files {
        set text [core::ReadFile $path]
        set sized [regexp -line {^n = [0-9]+$} $text]
        foreach n [expr {$sized ? $sizes : {-}}] {
            set copy [file join $work [file tail $path]]
            set channel [open $copy w]
            fconfigure $channel -encoding utf-8 -translation lf
            puts -nonewline $channel [expr {$sized ? [sized $text $n] : $text}]
            close $channel
            set hir [surface::readProgramFile $copy -warnings off]
            set nir [native::nir $hir {*}$lower]
            set appends [regexp -all {= op listappend } $nir]
            set extends [regexp -all {= construct list plan } $nir]
            # The machine code of the function that builds the List (the
            # first of the workloads' builders the NIR defines), and of the
            # whole program.
            lassign [native::codeSize $hir {*}$lower] total perFunction
            set code -
            foreach {_ id name} [regexp -all -inline -line {^func (\d+) "([^"]*)"} $nir] {
                if {$name in {build build_from chunks chunks_from}} {
                    set code [lindex $perFunction $id]
                    break
                }
            }
            set code $code/$total
            set report [native::allocationReport $hir summary 1 {*}$lower]
            lassign [native::measure $hir $runs {*}$lower] _ _ best _ value
            set perRun -
            if {$instructions} {
                # The difference of an N1- and an N2-run profile, divided by
                # N2 - N1: 4 and 24 runs, 1 and 3 at sizes of 16384 and more
                # (the eager fold's quadratic runs take minutes each under
                # callgrind; the counts are deterministic either way).
                set profileRuns [expr {$n ne "-" && $n >= 16384 ? {1 3} : {4 24}}]
                set profile [exec bash [file join $root audit bench-bimodality tools profile.sh] $copy {*}$profileRuns 2>@1]
                regexp {instructions per run[^0-9]*([0-9,]+)} $profile -> perRun
            }
            puts [format "%-30s %6s %10.2f %8s %8s %12s %7s %7s %6s %7s %7s %12s %10s %s" \
                [file tail $path] $n $best \
                [counter $report byKind List allocations] [counter $report byKind ListPlan allocations] \
                [counter $report copies listElements] \
                [counter $report construction plansCreated] [counter $report construction extensions] \
                [counter $report construction materializations] \
                $appends $extends $code $perRun [core::formatValue $value]]
            flush stdout
        }
    }
} finally {
    file delete -force $work
}
