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

# Structural function types (STRUCTURAL-FUNCTION-TYPES.md) change what
# "erasure" means, not the rule itself. A structural function type is a
# contract every call through it is statically held to (hir::range::
# VerifyStructuralCall for its argument types, hir::completions'
# CheckStructuralCallLegality for its declared errors), so a typed
# callable flowing into a position whose type is a structural supertype of
# it (an if/break/return join of compatible callables, a declared Fn
# parameter or result, a List[Fn] element) keeps its obligations checkable:
# only its identity is forgotten (Preserves). A structural type that still
# carries an obligation -- a non-any argument type or a non-empty error
# set, both of which can only have come from a typed Botlish block or a
# source annotation, since a native's structural arguments are all any
# (hir::types::structuralOf) -- is itself precondition-bearing, as is any
# callable *returning* a bearing value and any List/ImmutableSet of them
# (Bearing): erasing one of those to a type that forgets the obligation is
# rejected exactly like erasing a typed block's exact identity always was.

# MutableArray[T] (PARAMETERIZED-MUTABLEARRAY.md) is a second bearing form
# under the same rule, not a second checker. A MutableArray[T] carries a
# contract -- every slot value is a T and every store preserves that -- that
# lives only in its static type (the runtime object knows nothing of T). If
# such a value were to flow into a position of another type, that contract
# would become unenforceable exactly as a typed callable's is: through `any`
# or the raw `mutarray` kind a later kind test recovers a writable
# handle to the *same object* and stores a value the original alias never
# expects. So MutableArray[T] (T other than the vacuous `any`) is bearing,
# transitively through every containing type (List[MutableArray[T]],
# MutableArray[MutableArray[T]], Fn results), and is preserved only into a
# position that keeps the equivalent element contract. The natives that
# merely *use* an array through its typed API (mutable_array::at/set/
# freeze/capacity/copy, type tests, scalar-returning natives) keep it
# (hir/containers.tcl's NativeContexts); anything else that would retain it
# in an untyped position is rejected.

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
#
# Recursively (STRUCTURAL-FUNCTION-TYPES.md): a structural function type
# with a non-any argument type or a declared error; a callable (exact or
# structural) whose own result is bearing -- calling it yields a value
# whose obligation its caller must still be able to see, so forgetting the
# result type forgets that obligation too (before this milestone, `fn
# chooser(): take_byte` passed to an untyped parameter let take_byte be
# called unchecked through `f()(9999)`); and a List/ImmutableSet whose
# elements are.
proc hir::callables::Bearing {hir type {mutable 1}} {
    if {[hir::types::IsMutArray $type]} {
        # A MutableArray is a value (MUTABLE-ARRAY.md): a position that
        # forgets its element contract holds a logical copy, which no write
        # through it can make the original break, so the array bears only
        # what its elements bear -- as a List or a MutableVector does. (Under
        # the reference semantics MutableArray had before, an erased alias
        # could write a value the original's contract excluded, and every
        # typed array was bearing: PARAMETERIZED-MUTABLEARRAY.md.)
        return [Bearing $hir [lindex $type 1] $mutable]
    }
    if {[hir::types::IsExactBlock $type]} {
        set block [lindex $type 1]
        if {[dict exists $hir exprs $block]} {
            if {[dict get $hir exprs $block declaredErrors] ne {}} {
                return 1
            }
            # Declared, or trusted-inferred from the block's own body
            # (hir::signatures::entryTypes): the body assumes either one.
            foreach declared [hir::signatures::entryTypes $hir $block] {
                if {$declared ne {}} {
                    return 1
                }
            }
        }
        return [Bearing $hir [lindex $type 3] $mutable]
    }
    if {[hir::types::IsExactNative $type]} {
        # A root native with declared errors (`argv`) is exactly as much a
        # caller-side obligation as an error-bearing block.
        return [expr {![catch {core::native::metadata [lindex $type 1]} meta]
            && [dict get $meta errors] ne {}}]
    }
    if {[hir::types::IsFn $type]} {
        if {[hir::types::FnErrors $type] ne {}} {
            return 1
        }
        foreach arg [hir::types::FnArgs $type] {
            if {$arg ne "any"} {
                return 1
            }
        }
        return [Bearing $hir [hir::types::FnReturn $type] $mutable]
    }
    if {[hir::types::IsList $type]} {
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            if {[Bearing $hir $t $mutable]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsSet $type] || [hir::types::IsMutVec $type]} {
        # (A MutableVector is a value: it bears what its elements bear.)
        return [Bearing $hir [lindex $type 1] $mutable]
    }
    if {[hir::types::IsStruct $type]} {
        # A struct carries whatever any of its fields carries (STRUCTS.md):
        # a MutableArray[str] stored in a field is still that array, reachable
        # through the struct, so its contract may not be forgotten just because
        # it is now a struct's field.
        foreach {name t} [lindex $type 1] {
            if {[Bearing $hir $t $mutable]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsNamedStruct $type]} {
        return [BearingNamed $hir [lindex $type 1] $mutable]
    }
    return 0
}

# The declared errors a value of TYPE carries: what calling it -- or any
# callable reachable through it, by the structure Bearing walks (a
# callable's result, a List/set/vector/array element, a struct field) -- may
# raise according to its type: an exact block's declared errors, an exact
# native's registered ones, a structural function type's or a coroutine
# handle's contract errors. The error part of Bearing: what an erased value
# of TYPE may raise once its type is forgotten (hir::completions::
# ErasedErrors, the erased-callable contract).
proc hir::callables::CarriedErrors {hir type} {
    set errors {}
    CarriedInto $hir $type errors
    return [lsort -unique $errors]
}

proc hir::callables::CarriedInto {hir type errorsVar} {
    upvar 1 $errorsVar errors
    variable carriedVisiting
    if {[hir::types::IsMutArray $type] || [hir::types::IsSet $type] || [hir::types::IsMutVec $type]} {
        CarriedInto $hir [lindex $type 1] errors
        return
    }
    if {[hir::types::IsExactBlock $type]} {
        set block [lindex $type 1]
        if {[dict exists $hir exprs $block]} {
            lappend errors {*}[dict get $hir exprs $block declaredErrors]
        }
        CarriedInto $hir [lindex $type 3] errors
        return
    }
    if {[hir::types::IsExactNative $type]} {
        if {![catch {core::native::metadata [lindex $type 1]} meta]} {
            lappend errors {*}[dict get $meta errors]
        }
        return
    }
    if {[hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
        set contract [hir::types::Contract $type]
        lappend errors {*}[dict get $contract errors]
        CarriedInto $hir [dict get $contract return] errors
        return
    }
    if {[hir::types::IsList $type]} {
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            CarriedInto $hir $t errors
        }
        return
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            CarriedInto $hir $t errors
        }
        return
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {[info exists carriedVisiting] && $id in $carriedVisiting} {
            return
        }
        lappend carriedVisiting $id
        try {
            foreach {name t} [hir::structs::fieldTypes $id] {
                CarriedInto $hir $t errors
            }
        } finally {
            set carriedVisiting [lrange $carriedVisiting 0 end-1]
        }
    }
}

# Bearing of named struct ID: any declared field type bears. A struct may
# name itself (directly or through others), so a declaration being examined
# contributes nothing further (a cycle adds no obligation its first visit did
# not already count).
proc hir::callables::BearingNamed {hir id mutable} {
    variable visiting
    if {[info exists visiting] && $id in $visiting} {
        return 0
    }
    lappend visiting $id
    try {
        foreach {name t} [hir::structs::fieldTypes $id] {
            if {[Bearing $hir $t $mutable]} {
                return 1
            }
        }
        return 0
    } finally {
        set visiting [lrange $visiting 0 end-1]
    }
}

# 1 if a value of static TYPE flowing into a position of static type FINAL
# keeps every obligation it carries checkable: TYPE carries none, or FINAL
# is TYPE itself, or FINAL is a structural function type TYPE is a subtype
# of (so every call through FINAL is checked against a contract implying
# TYPE's own) whose return type in turn preserves TYPE's, or FINAL is the
# same exact block / an aggregate of the same constructor whose parts
# preserve TYPE's. FINAL "" (no typed context at all) preserves nothing.
proc hir::callables::Preserves {hir type final} {
    if {$type eq $final || $type eq "never" || ![Bearing $hir $type]} {
        return 1
    }
    if {$final eq ""} {
        return 0
    }
    if {[hir::types::IsExactBlock $type] && [hir::types::IsExactBlock $final]
            && [lrange $type 1 2] eq [lrange $final 1 2]} {
        return [Preserves $hir [lindex $type 3] [lindex $final 3]]
    }
    if {[hir::types::IsFn $final]} {
        set s [hir::types::structuralOf $type]
        return [expr {$s ne "" && [hir::types::subtype $type $final]
            && [Preserves $hir [hir::types::FnReturn $s] [hir::types::FnReturn $final]]}]
    }
    if {[hir::types::IsList $type] && [hir::types::IsList $final]} {
        set finalElem [lindex $final 1]
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            if {![Preserves $hir $t $finalElem]} {
                return 0
            }
        }
        return 1
    }
    if {[hir::types::IsSet $type] && [hir::types::IsSet $final]} {
        return [Preserves $hir [lindex $type 1] [lindex $final 1]]
    }
    if {([hir::types::IsMutVec $type] && [hir::types::IsMutVec $final])
            || ([hir::types::IsMutArray $type] && [hir::types::IsMutArray $final])} {
        return [Preserves $hir [lindex $type 1] [lindex $final 1]]
    }
    if {[hir::types::IsStruct $type] && [hir::types::IsStruct $final]} {
        # The same field set (an anonymous struct never widens or narrows its
        # fields), each field's obligations kept by the position it lands in.
        set final_ [lindex $final 1]
        if {[dict keys [lindex $type 1]] ne [dict keys $final_]} {
            return 0
        }
        dict for {name t} [lindex $type 1] {
            if {![Preserves $hir $t [dict get $final_ $name]]} {
                return 0
            }
        }
        return 1
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
    if {[Preserves $hir $type $finalType]} {
        return
    }
    if {[hir::types::IsExactBlock $type] && [dict exists $hir exprs [lindex $type 1]]} {
        # An erased trusted *inferred* contract (hir::signatures) is a
        # violation of it like a call's: hir::check demotes it on recovery.
        set block [lindex $type 1]
        set i 0
        foreach b [dict get $hir exprs $block params] {
            if {[hir::signatures::inferredTrusted $hir $block $i]} {
                dict set hir violatedContracts $b $arg
            }
            incr i
        }
    }
    set name [expr {[hir::types::IsExactBlock $type] ? [Name $hir [lindex $type 1]] : ""}]
    set label [expr {$name ne "" ? "\"$name\""
        : [hir::types::IsExactBlock $type] ? {this callable}
        : "this value of type [hir::types::show $type]"}]
    hir::Diagnose hir TYPE [format \
        {%s has typed parameter requirements that cannot be preserved %s: its declared parameter contract would be erased and could no longer be checked at every future call} \
        $label $contextText] $arg
}

# 1 if a MutableArray contract occurs anywhere inside TYPE (other than the
# vacuous MutableArray[any]): the array itself, an element of a List/set, a
# function's parameter or result, an exact block's result.
proc hir::callables::HasMutArray {type} {
    if {[hir::types::IsMutArray $type]} {
        return [expr {[lindex $type 1] ne "any" || [HasMutArray [lindex $type 1]]}]
    }
    if {[hir::types::IsList $type]} {
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            if {[HasMutArray $t]} { return 1 }
        }
        return 0
    }
    if {[hir::types::IsSet $type] || [hir::types::IsMutVec $type]} {
        return [HasMutArray [lindex $type 1]]
    }
    if {[hir::types::IsFn $type]} {
        foreach t [concat [hir::types::FnArgs $type] [list [hir::types::FnReturn $type]]] {
            if {[HasMutArray $t]} { return 1 }
        }
        return 0
    }
    if {[hir::types::IsExactBlock $type]} {
        return [HasMutArray [lindex $type 3]]
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[HasMutArray $t]} { return 1 }
        }
        return 0
    }
    if {[hir::types::IsNamedStruct $type]} {
        variable hasVisiting
        set id [lindex $type 1]
        if {[info exists hasVisiting] && $id in $hasVisiting} {
            return 0
        }
        lappend hasVisiting $id
        try {
            foreach {name t} [hir::structs::fieldTypes $id] {
                if {[HasMutArray $t]} { return 1 }
            }
            return 0
        } finally {
            set hasVisiting [lrange $hasVisiting 0 end-1]
        }
    }
    return 0
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
            foreach arg [dict get $node args] context [ArgContexts $hir $e] {
                CheckPreserved hir $arg $context {passed as an ordinary call argument}
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
            # A returning loop collects each iteration's trailing value
            # into its List result (RETURNING-ITERABLE-LOOPS.md): the
            # element position of that List is a join like an if branch.
            # Only reachable with a precondition-bearing value since
            # STRUCTURAL-FUNCTION-TYPES.md let Lists hold typed callables
            # (as List[Fn{...}] elements).
            CheckTrailing hir [dict get $node body] [hir::types::elementOf [hir::typeOf $hir $e]] \
                {as a returning loop's collected element, whose List element type differs}
        }
        countloop {
            WalkExpr hir [dict get $node start]
            WalkExpr hir [dict get $node end]
            foreach child [dict get $node body] {
                WalkExpr hir $child
            }
            # A collecting loop (COLLECTING-LOOPS.md): see listloop above.
            CheckTrailing hir [dict get $node body] [hir::types::elementOf [hir::typeOf $hir $e]] \
                {as a collecting loop's collected element, whose List element type differs}
        }
        lockloop {
            foreach operand [hir::loopOperands $node] {
                WalkExpr hir $operand
            }
            foreach child [dict get $node body] {
                WalkExpr hir $child
            }
            CheckTrailing hir [dict get $node body] [hir::types::elementOf [hir::typeOf $hir $e]] \
                {as a collecting loop's collected element, whose List element type differs}
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
        struct {
            # Each field value lands in its field's type: an anonymous
            # struct's own (inferred) field type, a named struct's declared
            # one. A contract-bearing value (a MutableArray[T], a typed
            # callable) stored where its contract would be forgotten -- a
            # field declared `any`, a depth-truncated position -- is an
            # erasure, exactly as it would be as a List element
            # (STRUCTS.md "Bearing").
            set structType [hir::typeOf $hir $e]
            foreach name [dict get $node names] field [dict get $node fields] {
                if {![dict exists $node opaqueDenied]} {
                    # (Not for a construction of an opaque struct that is
                    # already rejected as OPAQUE-CONSTRUCTION: the diagnostic
                    # would name a field of the hidden representation.)
                    set context [hir::types::StructField $structType $name]
                    CheckPreserved hir $field $context [format {stored in field "%s" of a struct} $name]
                }
                WalkExpr hir $field
            }
        }
        project {
            WalkExpr hir [dict get $node receiver]
        }
        fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                WalkExpr hir [dict get $node value]
            }
        }
        handle {
            WalkExpr hir [dict get $node call]
            set joined [hir::typeOf $hir $e]
            foreach body [dict get $node handlerBodies] {
                foreach child $body {
                    WalkExpr hir $child
                }
                # A handler's value becomes the handle expression's own
                # value -- typed as the handled call's result (no widening,
                # EXPLICIT-ERROR-COMPLETIONS.md item 11), or the handlers'
                # own join when the call never completes normally
                # (hir::types::Handle): a join like an if branch.
                CheckTrailing hir $body $joined \
                    {as a handler's value, whose handled call's result type differs}
            }
        }
    }
}

# The static type each argument of call E flows into, one per argument
# ("" where the callee gives it no typed position -- an untyped parameter,
# an unresolved dynamic call, or a native that may pass the value on
# untyped): a direct call's declared parameter type (hir::range::
# VerifyCall proves the argument admissible for it), a structural callee's
# contract argument type (VerifyStructuralCall), or -- for a List-building
# native (-result-shape elements/append, core/native.tcl), a List read
# (element) or immutable_set::from_list (immutable-set) -- the position the
# value provably lands in inside the call's own result type.
proc hir::callables::ArgContexts {hir e} {
    set node [dict get $hir exprs $e]
    set args [dict get $node args]
    set none [lrepeat [llength $args] ""]
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "block"} {
        set declared [hir::signatures::entryTypes $hir $target]
        if {[llength $declared] != [llength $args]} {
            return $none
        }
        # A parameter with no declared or trusted contract is `any` to the
        # generic body, so a bearing argument cannot cross it -- unless the
        # call has a semantic instance (hir/semantic.tcl), whose body is
        # analyzed (and audited, with this same walk) with the parameter at
        # the argument's own type: that type is the context.
        set instance [hir::semantic::InstanceOf $hir $e]
        if {$instance ne ""} {
            set entry [hir::semantic::EntryTypes $hir $instance]
            return [lmap t $declared u $entry {expr {$t eq {} ? $u : $t}}]
        }
        return [lmap t $declared {expr {$t eq {} ? "" : $t}}]
    }
    if {$targetKind eq ""} {
        set calleeType [hir::typeOf $hir [dict get $node callee]]
        if {[hir::types::IsFn $calleeType]
                && [llength [hir::types::FnArgs $calleeType]] == [llength $args]} {
            return [lmap t [hir::types::FnArgs $calleeType] {expr {$t eq "any" ? "" : $t}}]
        }
        return $none
    }
    set name [dict get [hir::symbol $hir $target] name]
    set container [hir::containers::NativeContexts $hir $e $name]
    if {$container ne ""} {
        return $container
    }
    set shape [dict get [core::native::metadata $name] resultShape]
    set result [hir::typeOf $hir $e]
    set elem [hir::types::elementOf $result]
    switch -- [lindex $shape 0] {
        elements {
            if {$elem ne ""} {
                return [lrepeat [llength $args] $elem]
            }
        }
        append {
            lassign $shape _ l v
            if {$elem ne ""} {
                set contexts $none
                lset contexts $l $result
                lset contexts $v $elem
                return $contexts
            }
        }
        element {
            # list::at(L, I): L's elements leave the call only as its result,
            # typed as L's own element type (ShapeResult) -- so L is
            # preserved exactly when that element is by the result's type.
            lassign $shape _ l
            set listType [hir::typeOf $hir [lindex $args $l]]
            set listElem [hir::types::elementOf $listType]
            if {$listElem ne "" && [Preserves $hir $listElem $result]} {
                set contexts $none
                lset contexts $l $listType
                return $contexts
            }
        }
        immutable-set {
            lassign $shape _ l
            if {[hir::types::IsSet $result]} {
                set contexts $none
                lset contexts $l [hir::types::MakeList [lindex $result 1]]
                return $contexts
            }
        }
        mutarray-element - mutarray-freeze {
            # Reading or freezing a MutableArray[T] hands out only T-typed
            # values (or a List[T]): the array itself is used through its
            # typed API, so its contract is kept.
            lassign $shape _ m
            set arrayType [hir::typeOf $hir [lindex $args $m]]
            if {[hir::types::IsMutArray $arrayType]} {
                set contexts $none
                lset contexts $m $arrayType
                return $contexts
            }
        }
    }
    if {[hir::containers::NonRetaining $name]} {
        # A native that returns a plain scalar and mutates nothing (list_
        # length, a type test, ...) only *uses* its arguments. That is the
        # policy for MutableArray contracts; a typed callable argument keeps
        # the original stricter treatment (its obligations are about who may
        # later call it, which this milestone does not revisit).
        return [lmap arg $args {
            set t [hir::typeOf $hir $arg]
            expr {[Bearing $hir $t 0] ? "" : $t}
        }]
    }
    return $none
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
    verifyBlocks hir $blocks
}

# verify over the given BLOCKS (also how hir/semantic.tcl audits one semantic
# instance's body on a view of the HIR).
proc hir::callables::verifyBlocks {hirVar blocks} {
    upvar 1 $hirVar hir
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
            # A declared result type is what every caller sees instead of
            # the inferred one (hir::types::Block): it must keep whatever
            # obligation the inferred result carries (hir::range::
            # verifyDeclaredResults already proved it admissible).
            set declared [dict get [dict get $hir exprs $block] declaredResult]
            if {$declared ne {} && ![Preserves $hir $finalType $declared]} {
                hir::Diagnose hir TYPE [format \
                    {the declared result type %s would erase the typed parameter requirements or declared errors of the callable this function returns (%s): its contract could no longer be checked at every future call} \
                    [hir::types::show $declared] [hir::types::showContract $finalType]] $block
            }
        }
    }
}
