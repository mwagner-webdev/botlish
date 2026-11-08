# timing.tcl -- inclusive and exclusive time of named procedures (the
# audit's tools source it). `timing::wrap PROCS` renames each procedure P to
# P__untimed and puts in its place a wrapper that calls it through
# `uplevel 1`, so an `upvar` or `uplevel` in P still reaches P's caller and
# `info level` reads the same. Inclusive time counts a recursive activation
# once (the outermost one); exclusive time is a call's time minus the time
# of the wrapped calls inside it.
#
# Not an execution trace: Tcl hands an execution trace's callback the
# command string, so every traced call formats its arguments and its result
# as text -- the whole HIR dict for most of these procedures. That inflated
# the timed procedures many times over (lowering a 533-line program: 91 s
# traced, 1.4 s untraced) and their memory. The wrapper formats nothing.
#
# Wrap before the warm-up compilation: renaming a command makes every
# procedure that calls it compile its body again on its next call.

namespace eval timing {
    variable total [dict create]
    variable exclusive [dict create]
    variable calls [dict create]
    variable depth [dict create]
    # One {NAME CHILD-MICROSECONDS} per active wrapped call.
    variable stack {}
}

proc timing::wrap {procs} {
    foreach p $procs {
        if {[info procs $p] eq ""} {
            error "timing::wrap: no procedure $p"
        }
        set original ${p}__untimed
        rename $p $original
        proc $p args [string map [list @P@ [list $p] @O@ [list $original]] {
            ::timing::Enter @P@
            set t0 [clock microseconds]
            try {
                return [uplevel 1 [list @O@ {*}$args]]
            } finally {
                ::timing::Leave @P@ $t0
            }
        }]
    }
}

proc timing::Enter {p} {
    variable depth
    variable stack
    dict incr depth $p
    lappend stack [list $p 0]
}

proc timing::Leave {p t0} {
    variable depth
    variable total
    variable exclusive
    variable calls
    variable stack
    set dt [expr {[clock microseconds] - $t0}]
    lassign [lindex $stack end] - child
    set stack [lrange $stack 0 end-1]
    if {$stack ne ""} {
        lset stack end 1 [expr {[lindex $stack end 1] + $dt}]
    }
    dict incr calls $p
    dict incr exclusive $p [expr {$dt - $child}]
    dict incr depth $p -1
    if {[dict get $depth $p] == 0} {
        dict incr total $p $dt
    }
}

proc timing::reset {} {
    variable total [dict create]
    variable exclusive [dict create]
    variable calls [dict create]
}

# Seconds spent in P (inclusive, or exclusive of the wrapped calls inside
# it), and its number of calls.
proc timing::seconds {p} {
    variable total
    return [expr {[dict getdef $total $p 0] / 1e6}]
}
proc timing::exclusiveSeconds {p} {
    variable exclusive
    return [expr {[dict getdef $exclusive $p 0] / 1e6}]
}
proc timing::calls {p} {
    variable calls
    return [dict getdef $calls $p 0]
}
