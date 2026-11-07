# deep.tcl -- depth-safe recursion: the front end's nesting is never bounded
# by Tcl's (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md).
#
# The compiler's walks over source nesting -- the parser's productions, the
# AST, the loader's walks, resolution, inference, the range and completion
# analyses, the lowerings and both code generators -- are recursive Tcl
# procedures, one or more Tcl evaluations per level of the program's
# nesting. Tcl bounds the nesting of evaluations (`interp recursionlimit`,
# 1000 by default, "too many nested evaluations": TCL LIMIT STACK), so a
# valid program nested a hundred deep did not compile. Raising the limit
# only moves that bound (and a C-recursive command on the path would then
# exhaust the C stack); this file removes it.
#
# A recursive walk runs in *segments*: Tcl coroutines, each at most `bound`
# procedure frames deep. A procedure whose recursion follows source nesting
# starts with the guard
#
#     if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}
#
# Past the bound it does not call deeper: `descend` makes a new segment
# that runs the same call as if in the same caller frame (the caller's
# variables are taken into it and given back after, those the call creates
# included: Take, Give), and the segment it leaves is suspended -- held,
# with its frames, by the driver's explicit stack (Drive) until the new one
# has finished. Tcl counts a coroutine's evaluations from where it is resumed,
# and the driver resumes every segment from its own frame, so the
# interpreter's nesting is at most the driver's depth plus one segment's,
# whatever the program's: the deep part of a walk lives in suspended
# segments, on the heap, in an explicit stack (Tcl 9's coroutines and procedure
# calls never grow the C stack: NRE).
#
# The walks' code is unchanged: a guarded call computes exactly what the
# recursive call computes, in the same order, with the same results,
# errors and return codes. Only where its frames live changes. So
# precedence, associativity, evaluation order, error order, source spans
# and recovery are the code's own, not a second implementation's.
#
# `run SCRIPT` evaluates SCRIPT in its caller's frame under a driver (the
# front end's entry points: compiling a program, lowering, generating code);
# inside a running segment it is SCRIPT itself. A guard reached with no
# driver (a walk called directly, or inside a coroutine of someone else's)
# makes one at that point, so every guarded walk is depth-safe whoever calls
# it; an entry point's driver only saves making one per call.
#
# Keep it so: a walk whose recursion follows the program's nesting carries
# the guard (tests/depth-safe-nesting.test's census lists them); a guarded
# procedure reaches its caller only through `upvar 1`/`uplevel 1` (deeper
# levels are another segment's) and never yields; nothing reads `info level`
# to decide what a program means.

namespace eval core::deep {
    # The frames a segment may grow before a guarded call starts another.
    # Inside a driver every walk runs in a segment, whose levels Tcl counts
    # from its own base.
    variable segment 60
    # The guard's bound now: `segment` while a driver runs; outside one, a
    # walk's frames count from the interpreter's top, and only a walk that
    # deep makes a driver of its own.
    variable outside 200
    variable bound 200
    # The segment the innermost driver is running ("" outside a driver).
    variable current ""
    variable counter 0
    # The body of every segment (MakeSegment), and its lambda per namespace.
    variable segmentBody {
        set _DEEP_names {}
        set _DEEP_linked {}
        foreach {_DEEP_name _DEEP_kind _DEEP_value} $_DEEP_taken {
            lappend _DEEP_names $_DEEP_name
            switch -- $_DEEP_kind {
                namespace {
                    upvar #0 $_DEEP_value $_DEEP_name
                    lappend _DEEP_linked $_DEEP_name
                }
                local - link {
                    set $_DEEP_name $_DEEP_value
                }
                local-array - link-array {
                    array set $_DEEP_name $_DEEP_value
                }
            }
        }
        # The values are the frame's alone now.
        unset -nocomplain _DEEP_taken _DEEP_value
        yield
        # Expanded, never evaluated as a script: a command's words are
        # values (a whole HIR among them), never given a string.
        set _DEEP_code [catch {{*}$_DEEP_work} _DEEP_result _DEEP_options]
        set _DEEP_state {}
        foreach _DEEP_name [lsort -unique [concat $_DEEP_names [info vars]]] {
            if {[string match _DEEP_* $_DEEP_name] || $_DEEP_name in $_DEEP_linked} {
                continue
            }
            if {[array exists $_DEEP_name]} {
                lappend _DEEP_state $_DEEP_name array [array get $_DEEP_name]
            } elseif {[info exists $_DEEP_name]} {
                lappend _DEEP_state $_DEEP_name scalar [set $_DEEP_name]
                unset $_DEEP_name
            } else {
                lappend _DEEP_state $_DEEP_name absent {}
            }
        }
        return [list done [list $_DEEP_code $_DEEP_result $_DEEP_options $_DEEP_state]]
    }
    variable lambdas [dict create]
    # Audit counters (never read by the compiler): segments made, drivers
    # started, the deepest driver stack, guarded calls that descended.
    variable stats [dict create segments 0 drivers 0 deepest 0]
}

# Evaluates SCRIPT in the caller's frame under a driver, returning what it
# returns (its result and return code, as `uplevel 1 SCRIPT` would).
proc core::deep::run {script} {
    variable current
    if {$current ne "" && [info coroutine] eq $current} {
        set code [catch {uplevel 1 $script} result options]
        dict incr options -level
        return -options $options $result
    }
    set seg [MakeSegment [list eval $script] [uplevel 1 {namespace current}] \
        [Take [uplevel 1 {info vars}]]]
    lassign [Drive $seg] code result options state
    Give $state
    dict incr options -level
    return -options $options $result
}

# The guard's continuation: CMD (a guarded procedure's `info level 0`), as
# its caller called it, in a new segment. Reached by `tailcall`, so this
# procedure stands where the guarded call stood: its caller is the guarded
# call's caller.
proc core::deep::descend {cmd} {
    variable current
    variable stats
    dict incr stats descents
    lset cmd 0 [uplevel 1 [list namespace which -command [lindex $cmd 0]]]
    set seg [MakeSegment $cmd [uplevel 1 {namespace current}] \
        [Take [uplevel 1 {info vars}]]]
    if {$current ne "" && [info coroutine] eq $current} {
        # The running segment of the innermost driver: suspended until the
        # driver has run the new one to its end.
        set outcome [yield [list descend $seg]]
    } else {
        set outcome [Drive $seg]
    }
    lassign $outcome code result options state
    Give $state
    dict incr options -level
    return -options $options $result
}

# The variables NAMES of the caller's caller's frame F, taken for a segment:
# {NAME KIND VALUE} each. F is suspended while the segment runs (its frames
# are below the segment's), and a coroutine sees no frame but its own, so
# nothing but the segment reaches a variable of F meanwhile: its locals are
# moved (KIND local: emptied in F, so the segment's copy is not shared) and
# given back after; a link to another frame's variable is copied (link) and
# written back. A link to a namespace variable, which code in the segment
# may reach directly, is linked to it again in the segment (namespace,
# VALUE its qualified name): found by its name in F's namespace and
# confirmed the same variable (Aliases).
proc core::deep::Take {names} {
    set locals [uplevel 2 {info locals}]
    # The global frame's variables are namespace variables, every one.
    set global [expr {[uplevel 2 {info level}] == 0}]
    set taken {}
    foreach name $names {
        upvar 2 $name var
        if {$name ni $locals} {
            set qualified [uplevel 2 [list namespace which -variable $name]]
            if {$qualified ne "" && ($global || [Aliases var $qualified])} {
                lappend taken $name namespace $qualified
                continue
            }
            set kind link
        } else {
            set kind local
        }
        if {[array exists var]} {
            lappend taken $name ${kind}-array [array get var]
        } elseif {[info exists var]} {
            lappend taken $name $kind $var
            if {$kind eq "local"} {
                set var {}
            }
        } else {
            lappend taken $name absent {}
        }
    }
    return $taken
}

# Whether the variable VAR names in the caller is the namespace variable
# QUALIFIED: unset that one and see whether VAR went with it (then put it
# back as it was).
proc core::deep::Aliases {varName qualified} {
    upvar 1 $varName var
    upvar #0 $qualified other
    if {[array exists other]} {
        set saved [array get other]
        set isArray 1
    } elseif {[info exists other]} {
        set saved $other
        set isArray 0
    } else {
        # An undefined namespace variable: VAR is it only if VAR is
        # undefined too, and then taking it as a copy changes nothing.
        return 0
    }
    if {![info exists var] && ![array exists var]} {
        return 0
    }
    unset other
    set same [expr {![info exists var] && ![array exists var]}]
    if {$isArray} {
        array set other $saved
    } else {
        set other $saved
    }
    return $same
}

# Gives back, in the caller's caller's frame, what a segment's frame held
# when it ended (MakeSegment's STATE).
proc core::deep::Give {state} {
    foreach {name kind value} $state {
        upvar 2 $name var
        switch -- $kind {
            scalar {
                if {[array exists var]} {
                    unset var
                }
                set var $value
            }
            array {
                if {[array exists var] || [info exists var]} {
                    unset var
                }
                array set var $value
            }
            absent {
                if {[array exists var] || [info exists var]} {
                    unset var
                }
            }
        }
    }
}

# A new suspended segment that will evaluate WORK (`eval SCRIPT` or a
# command) in a frame of namespace NS holding the variables TAKEN (Take's).
# Resumed, it runs WORK and ends with {done {CODE RESULT OPTIONS STATE}}:
# STATE every variable of its frame but the namespace links ({NAME
# scalar|array|absent VALUE}), the ones WORK created there included. The
# segment's own variables are _DEEP_*: no walk names a variable so.
proc core::deep::MakeSegment {work ns taken} {
    variable counter
    variable stats
    variable lambdas
    variable segmentBody
    dict incr stats segments
    set seg ::core::deep::seg[incr counter]
    if {![dict exists $lambdas $ns]} {
        # One lambda per namespace, kept: apply compiles a lambda once per
        # object, and a new one per segment cost a compilation each.
        dict set lambdas $ns [list {_DEEP_work _DEEP_taken} $segmentBody $ns]
    }
    coroutine $seg apply [dict get $lambdas $ns] $work $taken
    return $seg
}

# Runs SEG and every segment it starts, innermost first, from this frame:
# the explicit stack of suspended segments. Returns SEG's outcome.
proc core::deep::Drive {seg} {
    variable current
    variable bound
    variable segment
    variable stats
    dict incr stats drivers
    set saved [list $current $bound]
    set bound $segment
    set stack [list $seg]
    set resume {}
    try {
        while 1 {
            set current [lindex $stack end]
            set step [$current {*}$resume]
            if {[lindex $step 0] eq "descend"} {
                lappend stack [lindex $step 1]
                set resume {}
                if {[llength $stack] > [dict get $stats deepest]} {
                    dict set stats deepest [llength $stack]
                }
                continue
            }
            set stack [lrange $stack 0 end-1]
            if {![llength $stack]} {
                return [lindex $step 1]
            }
            set resume [list [lindex $step 1]]
        }
    } finally {
        lassign $saved current bound
        foreach left $stack {
            if {[info commands $left] ne ""} {
                rename $left {}
            }
        }
    }
}

# The audit counters (tests and benchmarks), and a way to reset them.
proc core::deep::stats {} {
    variable stats
    return $stats
}

proc core::deep::resetStats {} {
    variable stats
    set stats [dict create segments 0 drivers 0 deepest 0]
}
