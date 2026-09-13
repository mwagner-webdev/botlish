# refine.tcl -- branch refinement.
#
# When an `if` condition has the form
#
#     (call (ref P) ARG...)
#
# and P resolves to a callable with refinement metadata, each rule
# "argument I satisfies FACT" for the observed outcome is applied to argument I
# if that argument is itself (ref NAME). The fact is attached to the *binding*
# NAME resolves to, and recorded in the branch's own environment, so it is
# visible exactly within that branch.
#
# Re-resolving the refs here is equivalent to what the condition evaluated:
# bindings are immutable and lookup has no effects. Conditions of any other
# shape simply yield no facts, which is always sound.

namespace eval core::refine {}

# Returns a flat list of BINDING-ID FACT pairs.
proc core::refine::branchFacts {conditionNode env outcome} {
    if {[core::ir::op $conditionNode] ne "call"} {
        return {}
    }
    set calleeNode [lindex $conditionNode 1]
    if {[core::ir::op $calleeNode] ne "ref"} {
        return {}
    }
    set callee [core::env::lookup $env [lindex $calleeNode 1]]
    set argNodes [lrange $conditionNode 2 end]
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
