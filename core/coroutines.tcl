# coroutines.tcl -- the Tcl backends' coroutine runtime (COROUTINES.md).
#
# A Botlish coroutine is an eagerly started, affine resumable computation:
# `coroutine {step, first} = worker(x)` runs worker(x) at once, up to its
# first outward boundary -- a `yield`, its normal return, or an unhandled
# `fail` -- and every later step(...) call resumes it to the next one. The
# compiler proves everything static about it (hir/coroutines.tcl): which
# functions may yield, the one resume protocol of each coroutine, that every
# yielding call graph is entered through a coroutine construction, and that
# every handle has exactly one live owner (an affine binding). What is left
# for run time is the lifecycle of one handle, and that is all this file
# implements.
#
# Operations (internal root natives; source cannot spell `#`, so only the
# frontend's lowering produces them, surface/lower.tcl):
#
#   coroutine#create(THUNK)   a fresh handle around THUNK, a zero-argument
#                             Block whose body is the construction's call
#                             (its arguments were evaluated before it, into
#                             hygienic temporaries the thunk captures). No
#                             Botlish code runs.
#   coroutine#start(H)        runs H from the beginning to its first outward
#                             boundary: the construction's eager start. The
#                             frontend always emits it right after create,
#                             so a fresh handle is never observable.
#   coroutine#resume(H)       resumes a suspended H to its next boundary,
#   coroutine#resume(H, M)    delivering M (or unit, for a zero-message
#                             coroutine) as the value of the suspended yield
#   coroutine#yield(V)        suspends the running coroutine with outward
#                             value V; evaluates to the resume message
#   coroutine::done?(H)       true once H is terminal (completed or failed);
#                             observes H without moving it
#   coroutine#release(H)      H's handle is dead (the affine analysis placed
#                             this call right after its last use,
#                             hir/coroutines.tcl's Releases): frees what H
#                             still holds -- a suspended coroutine's Tcl
#                             coroutine and its frames, a terminal one's
#                             cached result or error. Unobservable: no code
#                             can reach H again, and a suspended body never
#                             runs again either way.
#
# start and resume return a *completion* (core::native's -completion): the
# outward value as a normal completion, or the body's unhandled declared
# error as its own propagate-error, which is then the start/resume call's
# completion -- the ordinary error channel, nothing coroutine-specific.
#
# Lifecycle of a handle (the store entry's `state`):
#
#   fresh       created, not started (never observable: start follows create)
#   running     executing a segment (defensive: an affine handle cannot be
#               resumed from inside its own segment)
#   suspended   stopped at a yield; `continuation` is a Tcl coroutine command
#   completed   the body returned; `value` is the final result, returned again
#               by every later resume without running anything
#   failed      the body's segment ended with an error; `failure` reproduces
#               it on every later resume without running anything
#   released    the handle is dead and everything it held is freed; nothing
#               can reach it (a resume or done? of it is a compiler bug,
#               COROUTINE-STATE)
#
# Implementation: one Tcl coroutine per started Botlish coroutine, created in
# this file's private namespace (never under a user-visible name). Tcl 9's
# non-recursive engine lets a `yield` happen at any depth of interpreted or
# compiled Botlish code (COROUTINE-PREREQUISITES.md, A.1), so the whole
# suspended call stack -- frames, handler state, return continuations -- is
# the Tcl coroutine's own. The store is per program run (fresh): a run that
# ends with suspended coroutines deletes their Tcl coroutines.

namespace eval core::coroutines {
    # ID -> {state STATE thunk BLOCK ?continuation CMD? ?value V? ?failure F?}
    variable store [dict create]
    variable nextId 0
    # The IDs whose segments are executing, innermost last: a resume nested in
    # another coroutine's segment pushes, its boundary pops.
    variable running {}
    # Test probes (AFFINE-VALUES.md, "Drop glue"): when not "none", every
    # release of a coroutine not released yet appends its ID (releaseTrace),
    # and every release call appends it, a repeated one included
    # (releaseCalls).
    variable releaseTrace none
    variable releaseCalls none
}

proc core::coroutines::createNative {} { return coroutine#create }
proc core::coroutines::startNative {} { return coroutine#start }
proc core::coroutines::resumeNative {} { return coroutine#resume }
proc core::coroutines::yieldNative {} { return coroutine#yield }
proc core::coroutines::doneNative {} { return coroutine::done? }
proc core::coroutines::releaseNative {} { return coroutine#release }

# The coroutine natives, for the analyses that recognize them by identity.
proc core::coroutines::natives {} {
    return [list coroutine#create coroutine#start coroutine#resume coroutine#yield coroutine::done? \
        coroutine#release]
}

proc core::coroutines::Entry {handle} {
    variable store
    set id [core::value::coroutineId $handle]
    if {![dict exists $store $id]} {
        core::semanticError COROUTINE-STATE \
            "coroutine handle $id does not belong to this program run"
    }
    return $id
}

proc core::coroutines::createImpl {thunk} {
    variable store
    variable nextId
    if {[core::value::kind $thunk] ni {block native}} {
        error "coroutine#create: expected a Block, got [core::value::show $thunk]"
    }
    set id [incr nextId]
    dict set store $id [dict create state fresh thunk $thunk]
    return [list coroutine $id]
}

# The body of the Tcl coroutine of coroutine ID: the thunk's invocation, to
# its completion at the thunk's own call boundary.
proc core::coroutines::Body {id} {
    variable store
    set thunk [dict get $store $id thunk]
    return [list done [core::callable::invoke $thunk {}]]
}

proc core::coroutines::startImpl {handle} {
    variable store
    set id [Entry $handle]
    if {[dict get $store $id state] ne "fresh"} {
        core::semanticError COROUTINE-STATE "coroutine $id was already started"
    }
    set command ::core::coroutines::co$id
    return [Segment $id [list coroutine $command ::core::coroutines::Body $id]]
}

proc core::coroutines::resumeImpl {handle args} {
    variable store
    set id [Entry $handle]
    if {[llength $args] > 1} {
        core::semanticError ARITY "a coroutine is resumed with at most one message, got [llength $args]"
    }
    set message [expr {$args eq "" ? [core::value::unit] : [lindex $args 0]}]
    switch -- [dict get $store $id state] {
        suspended {
            return [Segment $id [list [dict get $store $id continuation] $message]]
        }
        completed {
            # Stable terminal success: the same final result, no body code.
            return [core::completion::normal [dict get $store $id value]]
        }
        failed {
            # Stable terminal failure: the same error, no body code.
            lassign [dict get $store $id failure] how payload options
            if {$how eq "completion"} {
                return $payload
            }
            return -options $options $payload
        }
        running {
            core::semanticError COROUTINE-RUNNING \
                "coroutine $id is already running: a coroutine cannot resume itself"
        }
        released {
            core::semanticError COROUTINE-STATE \
                "coroutine $id was released after its handle's last use: nothing can resume it (a compiler bug)"
        }
        default {
            core::semanticError COROUTINE-STATE "coroutine $id was never started"
        }
    }
}

# Runs one segment of coroutine ID by evaluating the command SCRIPT (a
# coroutine creation or a resume of its continuation), and records where it
# ended. Returns the segment's completion.
proc core::coroutines::Segment {id script} {
    variable store
    variable running
    dict set store $id state running
    lappend running $id
    try {
        set out [{*}$script]
    } on error {message options} {
        # An invalid-program error (CORE SEMANTIC ..., a limit) left the body:
        # the coroutine is terminally failed with it.
        dict set store $id state failed
        dict set store $id failure [list error $message $options]
        dict unset store $id continuation
        return -options $options $message
    } finally {
        set running [lrange $running 0 end-1]
    }
    switch -- [lindex $out 0] {
        yielded {
            dict set store $id state suspended
            dict set store $id continuation ::core::coroutines::co$id
            return [core::completion::normal [lindex $out 1]]
        }
        done {
            set completion [lindex $out 1]
            dict unset store $id continuation
            dict set store $id thunk {}
            if {[core::completion::kind $completion] eq "value"} {
                dict set store $id state completed
                dict set store $id value [core::completion::payload $completion]
            } else {
                dict set store $id state failed
                dict set store $id failure [list completion $completion]
            }
            return $completion
        }
    }
    error "core::coroutines: unexpected segment outcome \"$out\""
}

proc core::coroutines::yieldImpl {value} {
    variable running
    set id [lindex $running end]
    if {$id eq "" || [info coroutine] ne "::core::coroutines::co$id"} {
        core::semanticError YIELD-OUTSIDE-COROUTINE \
            "yield outside a coroutine: no coroutine is running here"
    }
    set message [yield [list yielded $value]]
    if {$message eq [ReleaseMarker]} {
        # Released while suspended here (releaseImpl): unwind the whole
        # suspended stack. A Tcl error passes every Botlish handler (they
        # handle declared errors, a propagate-error completion, only), and
        # the frames' own `finally` clauses release their environments.
        return -code error -errorcode {CORE COROUTINE RELEASED} "coroutine released"
    }
    return $message
}

# What a release resumes a suspended Tcl coroutine with: never a Botlish
# value (every value is a kind-tagged list, and no kind is spelled so).
proc core::coroutines::ReleaseMarker {} {
    return {coroutine#released}
}

proc core::coroutines::doneImpl {handle} {
    variable store
    set id [Entry $handle]
    switch -- [dict get $store $id state] {
        completed - failed { return [core::value::bool 1] }
        released {
            core::semanticError COROUTINE-STATE \
                "coroutine $id was released after its handle's last use: nothing can observe it (a compiler bug)"
        }
    }
    return [core::value::bool 0]
}

# Releases coroutine HANDLE, whose handle is dead (hir/coroutines.tcl's
# Releases put this call after its last use): a suspended coroutine is
# unwound -- its pending yield raises, so its Botlish frames end through their
# `finally` clauses and its Tcl coroutine ends -- and every entry drops what
# it holds. Nothing observable: no Botlish code runs on the way out (a
# handler only handles declared errors), and nothing can reach the handle
# again.
proc core::coroutines::releaseImpl {handle} {
    variable store
    variable running
    variable releaseTrace
    variable releaseCalls
    set id [Entry $handle]
    if {$releaseTrace ne "none" && [dict get $store $id state] ne "released"} {
        lappend releaseTrace $id
    }
    if {$releaseCalls ne "none"} {
        lappend releaseCalls $id
    }
    switch -- [dict get $store $id state] {
        suspended {
            set continuation [dict get $store $id continuation]
            dict set store $id state running
            lappend running $id
            try {
                catch {$continuation [ReleaseMarker]}
            } finally {
                set running [lrange $running 0 end-1]
            }
            if {[info commands $continuation] ne ""} {
                rename $continuation {}
            }
        }
        running - released {
            # Released already (by another owner, in a branch: the compiler's
            # releases are idempotent), or -- defensive -- running: a dead
            # handle is never one of the running chain.
            return [core::value::unit]
        }
    }
    dict set store $id [dict create state released thunk {}]
    return [core::value::unit]
}

# Runs SCRIPT (in the caller's scope) with an empty coroutine store, then
# deletes the Tcl coroutines of every coroutine the run left suspended and
# restores the previous store, however SCRIPT ends.
proc core::coroutines::fresh {script} {
    variable store
    variable running
    set saved $store
    set savedRunning $running
    set store [dict create]
    set running {}
    try {
        return [uplevel 1 $script]
    } finally {
        dict for {id entry} $store {
            if {[dict exists $entry continuation]} {
                catch {rename [dict get $entry continuation] {}}
            }
        }
        set store $saved
        set running $savedRunning
    }
}

core::native::register coroutine#create -arity 1 -impl core::coroutines::createImpl \
    -result-type coroutine -result-shape {coroutine-create}
core::native::register coroutine#start -arity 1 -impl core::coroutines::startImpl \
    -param-types {coroutine} -completion 1 -result-shape {coroutine-outward}
core::native::register coroutine#resume -arity * -impl core::coroutines::resumeImpl \
    -completion 1 -result-shape {coroutine-outward}
core::native::register coroutine#yield -arity 1 -impl core::coroutines::yieldImpl \
    -result-shape {coroutine-yield}
core::native::register coroutine::done? -arity 1 -impl core::coroutines::doneImpl \
    -param-types {coroutine} -result-type bool
core::native::register coroutine#release -arity 1 -impl core::coroutines::releaseImpl \
    -param-types {coroutine} -result-type unit
