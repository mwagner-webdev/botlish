# callables.tcl -- typed-callable contract preservation
# (TYPED-CALLABLE-ESCAPE-SOUNDNESS.md).
#
# A *typed callable* is a block with at least one declared parameter type
# (hir::resolve.tcl's declaredParamTypes, STRICT-TYPED-PARAMETERS.md): it
# imposes a caller-side precondition. hir::range::verifyDeclaredParams
# already enforces that precondition at every call whose target resolves
# to an exact known block (hir::types::Call's `target` field) -- but a
# callable *value* can flow through the program in other ways (an
# ordinary call argument, an "if" branch join, a loop break, a function
# return) before ever being called. Whenever one of those positions would
# discard the value's exact `{block B arity result}` type -- the only
# type shape verifyDeclaredParams's target resolution can ever use --
# B's own precondition becomes permanently unenforceable at whatever
# later, now-untyped call site the erased value reaches. That is not lost
# precision (the pre-existing, accepted tolerance for a declared *result*
# type reached dynamically, CROSS-MODULE-REFINED-SIGNATURES.md): it is a
# soundness hole, because a *parameter* contract is the caller's
# obligation, not the callee's promise (see this file's own header in
# TYPED-CALLABLE-ESCAPE-SOUNDNESS.md's "Result-contract vs
# parameter-contract asymmetry").
#
# This pass finds every position that would erase a typed callable's exact
# type and rejects it -- conservatively, and before any backend exists,
# exactly like hir::range::verifyDeclaredParams. It adds no runtime check:
# a program that does not erase a typed callable's exact identity is
# entirely unaffected, and hir::range::verifyDeclaredParams (unmodified)
# still does the one and only admissibility proof for every argument of
# every call this pass leaves alone.

namespace eval hir::callables {}

# 1 if TYPE is an exact callable value -- {block B ARITY RESULT} -- whose
# block B declares at least one typed parameter (STRICT-TYPED-PARAMETERS.
# md's own "typed callable" -- TYPED-CALLABLE-ESCAPE-SOUNDNESS.md item 10:
# an untyped-parameter function, or one with only a declared *result*
# type, is not precondition-bearing and gains no new restriction here) OR
# declares a non-empty error set (EXPLICIT-ERROR-COMPLETIONS.md item 73):
# a declared error is exactly as much a caller-side obligation as a typed
# parameter -- the caller (or an enclosing function's own `errors` clause)
# must account for it -- so erasing B's exact identity here would make that
# obligation just as permanently unenforceable at whatever later, now-
# untyped call site the erased value reaches (hir::types::Call's own
# `calleeErrors` is only ever nonempty for an exact `{block ExprId}`
# target, so this is the one and only place that fact needs proving).
proc hir::callables::Bearing {hir type} {
    if {[lindex $type 0] ne "block" || [llength $type] != 4} {
        return 0
    }
    set block [lindex $type 1]
    if {![dict exists $hir exprs $block]} {
        return 0
    }
    if {[dict get $hir exprs $block declaredErrors] ne {}} {
        return 1
    }
    foreach declared [dict get $hir exprs $block declaredParamTypes] {
        if {$declared ne {}} {
            return 1
        }
    }
    return 0
}

# A best-effort source name for block B, for diagnostics only (the block
# whose declaring "bind" this is, if any is still visible from here).
proc hir::callables::Name {hir block} {
    dict for {b binding} [dict get $hir bindings] {
        set declaredBy [dict get $binding declaredBy]
        if {$declaredBy eq "" || ![dict exists $hir exprs $declaredBy]} {
            continue
        }
        if {[dict get $hir exprs $declaredBy value] eq $block} {
            return [dict get $binding name]
        }
    }
    return ""
}

# Diagnoses expression ARG (a typed callable's use) unless its type either
# is not precondition-bearing at all, or exactly equals FINALTYPE (the
# type of whatever this use joins/returns into -- "" means "no context to
# match against, any precondition-bearing type here is erasure"): the join
# survived exactly, so no erasure happened at this particular position
# (spec #4/#16-19's "exact callable identity may remain legal").
proc hir::callables::CheckPreserved {hirVar arg finalType contextText} {
    upvar 1 $hirVar hir
    if {$arg eq "" || ![hir::get $hir $arg reachable]} {
        return
    }
    set type [hir::typeOf $hir $arg]
    if {![Bearing $hir $type] || ($finalType ne "" && $type eq $finalType)} {
        return
    }
    set name [Name $hir [lindex $type 1]]
    set label [expr {$name eq "" ? {this callable} : "\"$name\""}]
    hir::Diagnose hir TYPE [format \
        {%s has typed parameter requirements that cannot be preserved %s: its declared parameter contract would be erased and could no longer be checked at every future call} \
        $label $contextText] $arg
}

# The trailing statement of BODY (an "if" branch or a function's own body),
# checked against IFTYPE/RESULTTYPE the way an explicit return/break is.
proc hir::callables::CheckTrailing {hirVar body finalType contextText} {
    upvar 1 $hirVar hir
    if {$body eq {}} {
        return
    }
    CheckPreserved hir [lindex $body end] $finalType $contextText
}

# Walks E (and its children, generically, via hir::children) checking
# every position that could erase a typed callable's exact type: a call's
# own arguments (never its callee -- a direct/exact invocation is exactly
# what hir::range::verifyDeclaredParams already checks soundly), an "if"'s
# branch join, a loop's break join, a function's explicit return and its
# own implicit trailing value, and a Result wrapper's value. A nested
# block's own body is its own region (mirrors hir::range::Expr's own rule)
# -- it gets its own top-level call from verify's own "blocks" loop below,
# so this never descends into a closure's body from here.
proc hir::callables::WalkExpr {hirVar e} {
    upvar 1 $hirVar hir
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const - ref - continue - block {
        }
        bind {
            # The bind's own value position is safe: an immutable local
            # binding's type is exactly its value's type (hir::types::
            # Bind), so a typed callable's exact identity survives an
            # ordinary "f = take_byte" alias -- TYPED-CALLABLE-ESCAPE-
            # SOUNDNESS.md items 4/16-17 -- with no check needed here.
            WalkExpr hir [dict get $node value]
        }
        call {
            # The callee is safe (direct/exact invocation); every other
            # argument must not itself be a typed callable, since the
            # callee's own parameter -- unless it is itself a directly
            # resolved typed parameter, which hir::range::
            # verifyDeclaredParams's own admissibility proof already
            # covers for a *scalar* value -- gives a callable argument no
            # way to be checked again at whatever call the callee's body
            # makes with it.
            WalkExpr hir [dict get $node callee]
            foreach arg [dict get $node args] {
                CheckPreserved hir $arg {} {passed as an ordinary call argument}
                WalkExpr hir $arg
            }
        }
        if {
            WalkExpr hir [dict get $node condition]
            foreach child [dict get $node thenBody] { WalkExpr hir $child }
            foreach child [dict get $node elseBody] { WalkExpr hir $child }
            set joined [hir::typeOf $hir $e]
            CheckTrailing hir [dict get $node thenBody] $joined \
                {in an "if" branch whose joined type differs from the other branch}
            CheckTrailing hir [dict get $node elseBody] $joined \
                {in an "if" branch whose joined type differs from the other branch}
        }
        loop {
            foreach child [dict get $node body] {
                WalkExpr hir $child
            }
        }
        listloop {
            WalkExpr hir [dict get $node iterable]
            foreach child [dict get $node body] {
                WalkExpr hir $child
            }
        }
        return {
            set value [dict get $node value]
            if {$value ne ""} {
                set target [dict get $node target]
                set finalType [expr {$target eq "" ? "" \
                    : [hir::type $hir [dict get [dict get $hir exprs $target] inferredResultType]]}]
                CheckPreserved hir $value $finalType \
                    {in a "return" whose function-level result type differs}
                WalkExpr hir $value
            }
        }
        break {
            set value [dict get $node value]
            if {$value ne ""} {
                set target [dict get $node target]
                set finalType [expr {$target eq "" ? "" : [hir::typeOf $hir $target]}]
                CheckPreserved hir $value $finalType \
                    {in a loop "break" whose joined type differs}
                WalkExpr hir $value
            }
        }
        ok - error {
            CheckPreserved hir [dict get $node value] {} {wrapped as a Result value}
            WalkExpr hir [dict get $node value]
        }
        fail {
        }
        handle {
            WalkExpr hir [dict get $node call]
            foreach body [dict get $node handlerBodies] {
                foreach child $body {
                    WalkExpr hir $child
                }
            }
        }
    }
}

# Entry point: every block (and the program root), each an independent
# top-level walk -- mirroring hir::range::verifyDeclaredParams's own
# "blocks" driver exactly, so a nested closure's body is covered by its
# own entry, never by its enclosing function's.
proc hir::callables::verify {hirVar} {
    upvar 1 $hirVar hir
    set blocks [list program]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq {block}} {
            lappend blocks $e
        }
    }
    foreach block $blocks {
        if {$block eq {program}} {
            set body [hir::roots $hir]
        } else {
            set body [dict get [dict get $hir exprs $block] body]
        }
        foreach child $body {
            WalkExpr hir $child
        }
        if {$block ne {program}} {
            # The body's own trailing value is an implicit return
            # (hir::types::Block's own "result = lub(body, returnType)"),
            # so it needs the identical join check an explicit "return"
            # statement gets.
            set finalType [hir::type $hir [dict get [dict get $hir exprs $block] inferredResultType]]
            CheckTrailing hir $body $finalType \
                {as a function's own trailing value, whose declared/inferred result type differs}
        }
    }
}
