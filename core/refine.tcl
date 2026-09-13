# refine.tcl -- branch refinement.
#
# When an `if` condition has the form
#
#     (call (ref P) ARG...)
#
# and P's value is a callable with refinement metadata, each rule
# "argument I satisfies FACT" for the observed outcome is applied to argument I
# if that argument is itself (ref NAME). The fact is attached to the *binding*
# NAME resolves to, and recorded in the branch's own environment, so it is
# visible exactly within that branch.
#
# Re-resolving the refs here is equivalent to what the condition evaluated:
# bindings are immutable and lookup has no effects. Conditions of any other
# shape simply yield no facts, which is always sound.

namespace eval core::refine {}

# True if CONDITION-NODE has the shape that can yield refinements.
proc core::refine::isRefiningCondition {conditionNode} {
    return [expr {[core::ir::op $conditionNode] eq "call"
                  && [core::ir::op [lindex $conditionNode 1]] eq "ref"}]
}

# Returns a flat list of BINDING-ID FACT pairs.
proc core::refine::branchFacts {conditionNode env outcome} {
    if {![isRefiningCondition $conditionNode]} {
        return {}
    }
    set callee [core::env::lookup $env [lindex $conditionNode 1 1]]
    return [factsFromCall $callee [lrange $conditionNode 2 end] $env $outcome]
}

# Facts from calling CALLEE (a value) on ARG-NODES in ENV with OUTCOME (1/0).
proc core::refine::factsFromCall {callee argNodes env outcome} {
    set facts {}
    foreach {index fact} [core::callable::refinementRules $callee $outcome] {
        if {$index >= [llength $argNodes]} {
            continue
        }
        set argNode [lindex $argNodes $index]
        if {[core::ir::op $argNode] ne "ref"} {
            continue
        }
        set binding [core::env::resolve $env [lindex $argNode 1]]
        lappend facts [dict get $binding id] $fact
    }
    return $facts
}

proc core::refine::install {env facts} {
    foreach {bindingId fact} $facts {
        core::env::refine $env $bindingId $fact
    }
}
