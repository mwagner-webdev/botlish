# refine.tcl -- static refinement facts and statically decided type tests.
#
# The runtime rule (core/refine.tcl): when an `if` condition has the form
#
#     (call (ref P) ARG...)
#
# and P's value is a callable with refinement metadata, each rule "argument I
# satisfies FACT" for the outcome is applied to argument I if that argument
# is itself (ref NAME); the fact holds for the binding NAME denotes, within
# the branch.
#
# Statically, the rule applies when the callee's static type says which
# native P is ({native NAME}, types.tcl). The facts are pairs of BindingId
# and FACT, never names, so shadowing cannot redirect them. They are stored
# on the if node (per outcome) and on each branch scope; the type inference
# narrows the bindings inside the branch only. Nothing here knows any
# predicate by name: the rules are the native's registered metadata.
#
# When the callee is unknown statically (a parameter, say) the runtime may
# still install facts the HIR does not know; the HIR facts are the statically
# provable subset, which is always sound.

namespace eval hir::refine {}

# dict OUTCOME (1/0) -> BindingId FACT pairs proven by CONDITION (an ExprId
# whose callee has already been typed).
proc hir::refine::branchFacts {hir condition} {
    set facts [dict create 1 {} 0 {}]
    set node [dict get $hir exprs $condition]
    if {[dict get $node kind] ne "call"
            || [dict get $hir exprs [dict get $node callee] kind] ne "ref"} {
        return $facts
    }
    set calleeType [hir::typeOf $hir [dict get $node callee]]
    if {[lindex $calleeType 0] ne "native" || [llength $calleeType] != 2} {
        return $facts
    }
    set args [dict get $node args]
    foreach outcome {1 0} {
        foreach {index fact} [core::native::refinementRules [lindex $calleeType 1] $outcome] {
            if {$index >= [llength $args]} {
                continue
            }
            set arg [dict get $hir exprs [lindex $args $index]]
            if {[dict get $arg kind] ne "ref" || [dict get $arg binding] eq ""} {
                continue
            }
            dict lappend facts $outcome [dict get $arg binding] $fact
        }
    }
    return $facts
}

# The result (1/0) of calling the type test native NAME on an argument of
# static type ARG-TYPE, when the type decides it; otherwise "".
#
# A type test (core/native.tcl -tests-type T, parameter kind P) returns
# exactly whether its argument is a value of T, after rejecting arguments not
# of kind P. So with argument type S: S ⊑ P and S ⊑ T decides true; S ⊑ P with
# a base other than T's decides false. If S is not known to be a P, the call
# may raise, and nothing is decided.
proc hir::refine::decideTypeTest {name argType} {
    set meta [core::native::metadata $name]
    set testsType [dict get $meta testsType]
    if {$testsType eq ""} {
        return ""
    }
    set param [lindex [dict get $meta paramTypes] 0]
    set type [hir::types::semantic $argType]
    if {$type eq "any" || ![core::type::subtype $type $param]} {
        return ""
    }
    if {[core::type::subtype $type $testsType]} {
        return 1
    }
    if {[core::type::base $type] ne [core::type::base $testsType]} {
        return 0
    }
    return ""
}
