# stdlib.tcl -- programs/stdlib.bot's operations one at a time, natively, at
# growing sizes (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section
# 6): each operation's time (one JIT run, compilation excluded) and the
# allocation report's copy counters, which show whether its cost grows with
# the size or with its square.
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/stdlib.tcl ?-sizes "1000 4000 16000"?
#
# Prints `op NAME N {microseconds T allocs A bytes B stringCopyBytes S
# listCopyElements L vectorDetachElements V arrayDetachElements R
# materializedStringBytes M}` (T the best of 3 runs, the driver's timing).

set here [file dirname [file normalize [info script]]]
set readiness [file dirname $here]
set checkout [file dirname [file dirname [file dirname $readiness]]]
set options [dict create -sizes "1000 4000 16000"]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "stdlib.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]
set channel [open [file join $readiness programs stdlib.bot]]; set text [read $channel]; close $channel
set head [string range $text 0 [string first "\nfn main(" $text]]
set scratch [file tempdir mid-end-stdlib]
set ops {sort {sorted_check(N)} text {diagnostic(N).length()} update {updated(N)} grow {grown(N)}
    nested {nested(N)} nested_swap {nested_swap(N)} split {split_count(N)}}
try {
    foreach {name call} $ops {
        foreach n [dict get $options -sizes] {
            set program "$head\nfn probe() -> int errors IndexNotFound, LowerUnderrun, UpperOverrun:\n    [string map [list N $n] $call]\n\nprobe():\n    on IndexNotFound:\n        -1\n    on LowerUnderrun:\n        -2\n    on UpperOverrun:\n        -3\n"
            set file [file join $scratch $name-$n.bot]
            set channel [open $file w]; puts -nonewline $channel $program; close $channel
            set hir [surface::readProgramFile $file -warnings off -cache ""]
            set report [native::allocationReport $hir summary]
            # The best of 3 runs of the compiled program, without the
            # driver's start or Cranelift (the driver's `timing` line).
            set lines [native::Driver bench [native::nir $hir] 3]
            set us [lindex [lsearch -inline $lines {timing *}] 2]
            puts [list op $name $n [dict create microseconds $us allocs [dict get $report total allocations] \
                bytes [dict get $report total allocatedBytes] \
                stringCopyBytes [dict getdef $report copies stringBytes 0] \
                listCopyElements [dict getdef $report copies listElements 0] \
                vectorDetachElements [dict getdef $report mutableVector detachElements 0] \
                arrayDetachElements [dict getdef $report mutableArray detachElements 0] \
                materializedStringBytes [dict getdef $report construction materializedStringBytes 0]]]
            flush stdout
        }
    }
} finally {
    file delete -force $scratch
}
