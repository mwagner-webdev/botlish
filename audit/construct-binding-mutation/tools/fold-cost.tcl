# fold-cost.tcl -- the cost of n pushes, natively, in the three idioms of
# CONSTRUCT-BINDING-MUTATION-CENSUS-1.md, section 15: a fold whose
# MutableVector intermediate is pushed and carried (corpus a02), an outer
# local pushed from a counted loop (a03), and a value parameter's working
# copy threaded through a self call (a04).
#
#   tclsh9.0 audit/construct-binding-mutation/tools/fold-cost.tcl ?-sizes LIST? ?-runs N?
#
# Prints, per idiom and size, the best wall time of N runs of the native
# driver (process start included) and the allocation report's MutableVector
# shares, detaches and detached elements (exact, run to run).

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set sizes {1000 4000 16000 32000}
set runs 3
foreach {option value} $argv {
    switch -- $option {
        -sizes { set sizes $value }
        -runs { set runs $value }
        default { error "unknown option $option" }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $checkout examples stdlib corpus.tcl]
set corpus [file join [file dirname $here] corpus]
set idioms {
    fold-intermediate a02-fold-push-return.bot {f(1000)}
    outer-local a03-outer-local.bot {f(1000)}
    threaded-copy a04-recursion-threaded.bot {fill(ints(), 0, 1000)}
}
puts [format "%-18s %7s %10s %8s %8s %12s" idiom n "best us" shares detaches elements]
foreach {idiom file call} $idioms {
    set text [core::ReadFile [file join $corpus $file]]
    foreach n $sizes {
        set src [string map [list $call [string map [list 1000 $n] $call]] $text]
        set hir [surface::compile $src -warnings off]
        set best ""
        for {set k 0} {$k < $runs} {incr k} {
            set t0 [clock microseconds]
            set v [native::evalHir $hir]
            set t [expr {[clock microseconds] - $t0}]
            if {$best eq "" || $t < $best} {
                set best $t
            }
        }
        if {$v ne [list int $n]} {
            error "$idiom n=$n: value $v"
        }
        set r [dict get [native::allocationReport $hir summary] mutableVector]
        puts [format "%-18s %7d %10d %8d %8d %12d" $idiom $n $best [dict get $r shares] [dict get $r detaches] [dict get $r detachElements]]
    }
}
