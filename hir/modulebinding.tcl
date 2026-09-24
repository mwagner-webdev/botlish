# modulebinding.tcl -- safety validation for retained module-scope values.
#
# Module values are ordinary HIR binds in a module program scope. This pass
# proves two separate facts: initializer evaluation is context-free, and the
# retained value has an immutable object graph. Unknown operations are
# conservative failures.

namespace eval hir::modulebinding {}

proc hir::modulebinding::validate {hirVar} {
    upvar 1 $hirVar hir
    if {[hir::mode $hir] ne "program" || ![dict exists $hir modules]} {
        return
    }
    set moduleScopes [dict create]
    dict for {namespace scope} [dict get $hir modules] {
        dict set moduleScopes $scope $namespace
    }
    set values [dict create]
    set contextState [dict create]

    # Roots are dependency-first and source-ordered inside each module.
    # Values therefore becomes the textual initialization-order proof.
    foreach e [hir::roots $hir] {
        if {[hir::kind $hir $e] ne "bind"} {
            continue
        }
        set b [hir::get $hir $e binding]
        if {![dict exists $moduleScopes [dict get [hir::binding $hir $b] scope]]} {
            continue
        }
        set value [hir::get $hir $e value]
        if {[hir::kind $hir $value] eq "block"} {
            # Function definitions remain ordinary cheap startup bindings.
            dict set values $b [list block $value [dict create]]
            continue
        }

        set context [ContextExpr $hir $value contextState]
        if {[lindex $context 0] ne "ok"} {
            hir::Diagnose hir MODULE-CONTEXT \
                "module binding initializer must be context-free: [lindex $context 1]" $e
            continue
        }

        set active [dict create]
        set retained [ImmutableExpr $hir $value values active]
        if {[lindex $retained 0] ne "ok"} {
            set name [dict get [hir::binding $hir $b] name]
            switch -- [lindex $retained 1] {
                mutable {
                    set message "module binding \"$name\" cannot retain mutable value [lindex $retained 2]"
                }
                order {
                    set message "module binding initializer may refer only to earlier module bindings: [lindex $retained 2]"
                }
                default {
                    set message "module binding \"$name\" cannot prove its retained value is transitively immutable: [lindex $retained 2]"
                }
            }
            hir::Diagnose hir MODULE-IMMUTABLE $message $e
            continue
        }
        dict set values $b [lindex $retained 1]
    }
}

# Context freedom follows direct resolved calls. A recursive SCC is allowed:
# a bad operation reached by a member still makes that member, and its caller,
# fail when the walk completes.
proc hir::modulebinding::ContextExpr {hir e stateVar} {
    upvar 1 $stateVar state
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const - ref - block - continue {
            return {ok}
        }
        bind - return - ok - error {
            return [ContextExpr $hir [dict get $node value] state]
        }
        break {
            if {[dict get $node value] eq ""} {
                return {ok}
            }
            return [ContextExpr $hir [dict get $node value] state]
        }
        if {
            foreach child [concat [list [dict get $node condition]] \
                    [dict get $node thenBody] [dict get $node elseBody]] {
                set result [ContextExpr $hir $child state]
                if {[lindex $result 0] ne "ok"} {
                    return $result
                }
            }
            return {ok}
        }
        loop {
            return [ContextSequence $hir [dict get $node body] state]
        }
        listloop {
            set result [ContextExpr $hir [dict get $node iterable] state]
            if {[lindex $result 0] ne "ok"} {
                return $result
            }
            return [ContextSequence $hir [dict get $node body] state]
        }
        call {
            foreach child [dict get $node args] {
                set result [ContextExpr $hir $child state]
                if {[lindex $result 0] ne "ok"} {
                    return $result
                }
            }
            lassign [dict get $node target] targetKind target
            switch -- $targetKind {
                native {
                    set name [dict get [hir::symbol $hir $target] name]
                    if {![dict get [core::native::metadata $name] contextFree]} {
                        return [list bad "native operation \"$name\" is not classified context-free"]
                    }
                    return {ok}
                }
                block {
                    return [ContextBlock $hir $target state]
                }
                default {
                    return {bad "call target is not statically known"}
                }
            }
        }
        default {
            return [list bad "unsupported initializer expression [dict get $node kind]"]
        }
    }
}

proc hir::modulebinding::ContextSequence {hir exprs stateVar} {
    upvar 1 $stateVar state
    foreach e $exprs {
        set result [ContextExpr $hir $e state]
        if {[lindex $result 0] ne "ok"} {
            return $result
        }
    }
    return {ok}
}

proc hir::modulebinding::ContextBlock {hir block stateVar} {
    upvar 1 $stateVar state
    if {[dict exists $state $block]} {
        set entry [dict get $state $block]
        if {[lindex $entry 0] eq "in-progress"} {
            return {ok}
        }
        return $entry
    }
    dict set state $block {in-progress}
    set result [ContextSequence $hir [hir::get $hir $block body] state]
    dict set state $block $result
    return $result
}

# Proof values:
#   {scalar KIND}
#   {list ITEM-PROOFS}
#   {set ITEM-PROOFS}
#   {block EXPR CAPTURE-PROOFS}
#
# A plain List type alone is deliberately not enough: its items could be
# mutable. List construction must remain visible to this structural proof.
proc hir::modulebinding::ImmutableExpr {hir e factsVar activeVar} {
    upvar 1 $factsVar facts $activeVar active
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const {
            set kind [core::value::kind [dict get $node value]]
            if {$kind in {int str bool unit UnicodeChar}} {
                return [list ok [list scalar $kind]]
            }
            return [list bad unknown "literal value kind $kind"]
        }
        ref {
            return [ImmutableRef $hir $node $facts]
        }
        bind {
            set result [ImmutableExpr $hir [dict get $node value] facts active]
            if {[lindex $result 0] ne "ok"} {
                return $result
            }
            dict set facts [dict get $node binding] [lindex $result 1]
            return $result
        }
        block {
            set captures [dict create]
            foreach b [dict get $node captures] {
                set result [ImmutableBinding $hir $b $facts]
                if {[lindex $result 0] ne "ok"} {
                    if {[lindex $result 1] eq "mutable"} {
                        return [list bad mutable "Block capture -> [lindex $result 2]"]
                    }
                    return $result
                }
                dict set captures $b [lindex $result 1]
            }
            return [list ok [list block $e $captures]]
        }
        call {
            lassign [dict get $node target] targetKind target
            set nativeName ""
            if {$targetKind eq "native"} {
                set nativeName [dict get [hir::symbol $hir $target] name]
            }
            set args {}
            foreach arg [dict get $node args] {
                set result [ImmutableExpr $hir $arg facts active]
                if {[lindex $result 0] ne "ok"} {
                    if {$targetKind eq "native" && $nativeName eq "list"
                            && [lindex $result 1] eq "mutable"} {
                        return [list bad mutable "List element -> [lindex $result 2]"]
                    }
                    return $result
                }
                lappend args [lindex $result 1]
            }
            switch -- $targetKind {
                native {
                    return [ImmutableNative $hir $target $args]
                }
                block {
                    set calleeProof ""
                    set callee [hir::get $hir $e callee]
                    if {[hir::kind $hir $callee] eq "ref"} {
                        set calleeBinding [hir::get $hir $callee binding]
                        if {[dict exists $facts $calleeBinding]} {
                            set calleeProof [dict get $facts $calleeBinding]
                        }
                    }
                    return [ImmutableBlockCall $hir $target $args $calleeProof facts active]
                }
                default {
                    return {bad unknown "call target is not statically known"}
                }
            }
        }
        if {
            set thenFacts $facts
            set then [ImmutableSequence $hir [dict get $node thenBody] thenFacts active]
            if {[lindex $then 0] ne "ok"} {
                return $then
            }
            set elseFacts $facts
            set else [ImmutableSequence $hir [dict get $node elseBody] elseFacts active]
            if {[lindex $else 0] ne "ok"} {
                return $else
            }
            return [MergeBranchProofs $then $else]
        }
        return {
            set result [ImmutableExpr $hir [dict get $node value] facts active]
            if {[lindex $result 0] ne "ok"} {
                return $result
            }
            return [list return [lindex $result 1]]
        }
        loop - break - continue {
            return {bad unknown "control-flow result cannot be proven immutable"}
        }
        listloop {
            # Unlike a bare `loop` (whose result is whatever an arbitrary,
            # data-dependent `break` supplies, never proven here), a
            # listloop's own result is exactly the List of every iteration's
            # own body value -- provable the same way `list(...)`'s own
            # per-argument proof already is (ImmutableNative's `list` case,
            # below), just with the element binding's own fact seeded from
            # each of the iterable's own item proofs in turn: this is the
            # one general rule that lets an exact, context-free call like
            # `byte::set(['-', '.', '_', '~'])` prove retainable, without
            # any byte::set-specific code here (see BYTE-SET.md).
            set iterProof [ImmutableExpr $hir [dict get $node iterable] facts active]
            if {[lindex $iterProof 0] ne "ok"} {
                return $iterProof
            }
            if {[lindex $iterProof 1 0] ne "list"} {
                return {bad unknown "listloop iterable is not structurally known"}
            }
            set elementBinding [dict get $node elementBinding]
            set results {}
            foreach itemProof [lindex $iterProof 1 1] {
                set bodyFacts $facts
                dict set bodyFacts $elementBinding $itemProof
                set bodyResult [ImmutableSequence $hir [dict get $node body] bodyFacts active]
                if {[lindex $bodyResult 0] ne "ok"} {
                    return $bodyResult
                }
                lappend results [lindex $bodyResult 1]
            }
            return [list ok [list list $results]]
        }
        ok - error {
            return {bad unknown "Result values are not retained module values yet"}
        }
        default {
            return [list bad unknown "initializer expression [dict get $node kind]"]
        }
    }
}

proc hir::modulebinding::ImmutableSequence {hir exprs factsVar activeVar} {
    upvar 1 $factsVar facts $activeVar active
    set result [list ok [list scalar unit]]
    foreach e $exprs {
        set result [ImmutableExpr $hir $e facts active]
        if {[lindex $result 0] eq "return"} {
            return [list ok [lindex $result 1]]
        }
        if {[lindex $result 0] ne "ok"} {
            return $result
        }
    }
    return $result
}

proc hir::modulebinding::ImmutableRef {hir node facts} {
    set b [dict get $node binding]
    if {$b eq ""} {
        return {bad unknown "unresolved reference"}
    }
    if {[dict exists $facts $b]} {
        return [list ok [dict get $facts $b]]
    }
    set binding [hir::binding $hir $b]
    if {[dict get $binding kind] eq "root"} {
        set kind [core::value::kind [dict get $binding value]]
        if {$kind in {bool unit}} {
            return [list ok [list scalar $kind]]
        }
        return [list bad unknown "root value [dict get $binding name] is not retained immutable data"]
    }
    return [list bad order "\"[dict get $binding name]\" has not initialized"]
}

proc hir::modulebinding::ImmutableBinding {hir b facts} {
    if {[dict exists $facts $b]} {
        return [list ok [dict get $facts $b]]
    }
    set binding [hir::binding $hir $b]
    if {[dict get $binding kind] eq "root"} {
        return [ImmutableRef $hir [dict create binding $b] $facts]
    }
    return [list bad order "\"[dict get $binding name]\" has not initialized"]
}

proc hir::modulebinding::ImmutableNative {hir symbol proofs} {
    set name [dict get [hir::symbol $hir $symbol] name]
    set meta [core::native::metadata $name]
    switch -- $name {
        list {
            return [list ok [list list $proofs]]
        }
        list_append {
            set sourceProof [lindex $proofs 0]
            if {[lindex $sourceProof 0] ne "list"} {
                return {bad unknown "list_append source List is not structurally known"}
            }
            return [list ok [list list [concat [lindex $sourceProof 1] [lindex $proofs 1]]]]
        }
        immutable_set_from_list {
            # MINIMAL-IMMUTABLE-SET.md item 36: the same structural-proof
            # pattern list_append uses above -- immutable_set_from_list's
            # source List must itself be structurally known (built from
            # `list`/`list_append`, not e.g. a mutable-array freeze whose
            # proof this pass cannot see through) for the resulting
            # ImmutableSet to be a retainable module value. Construction's
            # own dedup is a runtime detail, not part of this static proof:
            # the element proofs it retains are the source List's, verbatim.
            set sourceProof [lindex $proofs 0]
            if {[lindex $sourceProof 0] ne "list"} {
                return {bad unknown "immutable_set_from_list source List is not structurally known"}
            }
            return [list ok [list set [lindex $sourceProof 1]]]
        }
    }
    set kind [core::type::base [dict get $meta resultType]]
    if {$kind in {int str bool unit}} {
        return [list ok [list scalar $kind]]
    }
    if {$kind eq "mutarray"} {
        return {bad mutable MutableArray}
    }
    return [list bad unknown "native \"$name\" returns $kind without a structural immutable-value proof"]
}

proc hir::modulebinding::ImmutableBlockCall {hir block args calleeProof factsVar activeVar} {
    upvar 1 $factsVar facts $activeVar active
    if {[dict exists $active $block]} {
        return {bad unknown "recursive function result cannot be proven immutable"}
    }
    set params [hir::get $hir $block params]
    if {[llength $params] != [llength $args]} {
        return {bad unknown "function call has the wrong arity"}
    }
    set callFacts $facts
    if {$calleeProof ne "" && [lindex $calleeProof 0] eq "block"
            && [llength $calleeProof] == 3} {
        dict for {b proof} [lindex $calleeProof 2] {
            dict set callFacts $b $proof
        }
    }
    foreach b $params proof $args {
        dict set callFacts $b $proof
    }
    dict set active $block 1
    set result [ImmutableSequence $hir [hir::get $hir $block body] callFacts active]
    dict unset active $block
    return $result
}

proc hir::modulebinding::MergeBranchProofs {then else} {
    # Both branch proofs are immutable. Keep both possibilities instead of
    # pretending a conditional has a compile-time-selected retained value.
    return [list ok [list choice [lindex $then 1] [lindex $else 1]]]
}
