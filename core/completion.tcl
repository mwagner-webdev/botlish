# completion.tcl -- semantic completions.
#
# Every evaluation step produces a completion, never a raw Tcl return code:
#
#   {value V}             normal completion with value V
#   {return V}            return from the current callable invocation
#   {break V}             exit the nearest lexical loop with value V
#   {continue}            start the next iteration of the nearest lexical loop
#   {propagate-error E}   reserved for structured error propagation
#
# Language-level domain errors are Result *values*, not completions.
# New completion kinds are added here and at the boundaries below.

namespace eval core::completion {}

proc core::completion::normal {v}          { return [list value [core::value::check $v]] }
proc core::completion::returning {v}       { return [list return [core::value::check $v]] }
proc core::completion::breaking {v}        { return [list break [core::value::check $v]] }
proc core::completion::continuing {}       { return {continue} }
proc core::completion::propagatingError {e} { return [list propagate-error [core::value::check $e]] }

proc core::completion::kind {c} {
    set k [lindex $c 0]
    if {$k ni {value return break continue propagate-error}} {
        error "core::completion: not a completion: \"$c\""
    }
    return $k
}

proc core::completion::isNormal {c} {
    return [expr {[kind $c] eq "value"}]
}

proc core::completion::payload {c} {
    if {[kind $c] eq "continue"} {
        error "core::completion: continue carries no payload"
    }
    return [lindex $c 1]
}

# Boundary of a callable (Block) invocation.
# Return is consumed; break and continue may not cross; errors propagate.
proc core::completion::atCallBoundary {c} {
    switch -- [kind $c] {
        value - propagate-error {
            return $c
        }
        return {
            return [normal [payload $c]]
        }
        break {
            core::semanticError BREAK-OUTSIDE-LOOP \
                "break outside lexical loop: break cannot cross a callable boundary"
        }
        continue {
            core::semanticError CONTINUE-OUTSIDE-LOOP \
                "continue outside lexical loop: continue cannot cross a callable boundary"
        }
    }
}

# Boundary of a whole program. Returns the program's value.
proc core::completion::atProgramBoundary {c} {
    switch -- [kind $c] {
        value {
            return [payload $c]
        }
        return {
            core::semanticError RETURN-OUTSIDE-CALLABLE \
                "return outside callable invocation"
        }
        break {
            core::semanticError BREAK-OUTSIDE-LOOP "break outside lexical loop"
        }
        continue {
            core::semanticError CONTINUE-OUTSIDE-LOOP "continue outside lexical loop"
        }
        propagate-error {
            core::semanticError UNCAUGHT-ERROR \
                "uncaught propagated error: [core::value::show [payload $c]]"
        }
    }
}

proc core::completion::show {c} {
    if {[kind $c] eq "continue"} {
        return continue
    }
    return "[kind $c]([core::value::show [payload $c]])"
}
