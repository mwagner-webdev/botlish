# aot.tcl -- closed-AOT readiness: what stands between HIR and native code.
#
#   set analysis [hir::aot::analyze $hir]
#   puts [hir::aot::explain $hir $analysis]
#
# An analysis only reads HIR. It emits no code, changes no facts, and uses
# nothing a backend decides: it states, for each function (block expression)
# and for the program's top level, whether native code could run it without
# dynamic semantic dispatch, and what native code would still need.
#
# Everything comes from facts HIR already has: resolved bindings, static
# types (types.tcl), known call targets, captures, control targets,
# diagnostics, and the native registry's signatures and runtime
# requirements (core/native.tcl -runtime). Nothing here knows a native by
# name.
#
# Regions
# -------
# A region is the code of one block invocation (its body, branches and loop
# bodies, not nested blocks), or the program's top level. Creating a nested
# block is part of the enclosing region; running its body is not.
#
# Status of a region
# ------------------
#   open     some operation cannot be chosen statically: a call of a value of
#            unknown kind, a name resolved at run time, a static error
#   guarded  every operation is chosen, but some operand's kind is not
#            established statically, so native code must check it at run
#            time (and hold the value in a tagged representation)
#   closed   every operation is chosen and every operand has the kind its
#            operation requires
#
# Runtime helpers never affect the status: `+` on two known Ints is closed
# even though native code needs arbitrary-precision arithmetic for it. They
# are reported as requirements. The distinction is
#
#   cannot choose the operation              -> blocker, class semantic
#   operation known, operand kind unproven   -> blocker, class representation
#   operation known, needs runtime support   -> fact + requirement
#
# transitive is the worst status of the region and every function it calls
# directly (through known block targets), so a closed wrapper around a
# guarded worker is transitively guarded.
#
# Data model
# ----------
# analyze returns a dict:
#
#   regions   RegionId -> region; RegionId is "program" or a block ExprId,
#             in source order (program first)
#
# A region:
#
#   id          RegionId
#   name        the name a function is bound to ("" for an anonymous block,
#               <program> for the top level)
#   origin      origin of the block expression (program: the program scope)
#   location    location dict (see below)
#   status      closed | guarded | open
#   dispatch    closed | open: open iff a semantic blocker exists
#   transitive  worst status over the region and its direct callees
#   params      list of {binding BindingId name NAME type TYPE}
#   result      the block's static result type ("" for the program)
#   captures    list of {binding BindingId name NAME class block|value}:
#               block if the binding is statically bound to a block that
#               needs no environment itself (see StaticBlocks), else value
#   callees     block ExprIds called directly, in order of first call
#   blockers    list of blocker dicts, in HIR pre-order (an operation
#               before its operands)
#   facts       list of fact dicts, in HIR pre-order
#   requirements  sorted runtime requirement tags (below)
#   unreachable number of unreachable expressions (not analyzed)
#
# A blocker:
#
#   kind      semantic:
#               DynamicCall             callee has no static callable kind
#               DynamicBinding          name resolved in an unknown
#                                       environment at run time (ambient)
#               UnresolvedBinding       name resolves to nothing
#               UnresolvedControl       return/break/continue with no target
#               StaticError             a HIR diagnostic
#             representation (the kind check native code needs):
#               UnknownParameterKind    the operand is a parameter: nothing
#                                       states what callers pass
#               UnknownAggregateElementType
#                                       the operand was read out of a list or
#                                       Result, which carry no element type
#               UnknownCallResultKind   the operand is the result of a call
#                                       whose result type is unknown
#               UnknownValueKind        any other operand without a kind
#                                       (e.g. a merge of different kinds)
#               UnprovenRefinement      the kind is right but a named type
#                                       (evidence) is not proven
#   class     semantic | representation
#   expr      ExprId of the operand or operation the blocker is about
#   origin    its HIR origin; location: its location dict
#   operation ExprId of the call or if that needs the kind ("" if none)
#   requires  the type the operation requires ("" for semantic blockers)
#   cause     dict {cause CAUSE expr ExprId binding BindingId native NAME
#             block ExprId}: where the unknown kind comes from (CAUSE is
#             parameter, aggregate-element, native-result, block-result,
#             dynamic-result, merge, ambient, unresolved or unknown; absent
#             fields are "")
#   message   one-line explanation (derived; not the canonical form)
#
# A fact:
#
#   kind  native-call   expr native NAME runtime TAGS argKinds KINDS
#         direct-call   expr block ExprId name NAME tail 0|1 self 0|1
#         indirect-call expr calleeKind block|native (target unknown)
#         closure       expr block ExprId captures BindingIds (creation of a
#                       block value that needs an environment)
#         known-error   expr error KIND (the operation always raises)
#         bigint-literal expr (an Int literal outside 64-bit range)
#         result-alloc  expr
#         init-check    expr binding BindingId (a reference HIR cannot
#                       prove bound: deferred, inside a closure)
#   plus origin and location, like blockers.
#
# Requirement tags: the -runtime tags of native calls (core/native.tcl), and
#
#   closure-env    creates or calls blocks that capture values
#   indirect-call  calls a callable whose target is unknown
#   dynamic-call   calls a value of unknown kind
#   init-check     reads a binding HIR cannot prove bound
#   tagged-values  holds values of statically unknown kind
#   result-alloc   allocates Results
#
# A location dict is {file PATH line L column C node ID} for source origins
# and {ir PATH} for core IR origins.

namespace eval hir::aot {
    variable statusRank {closed 0 guarded 1 open 2}
}

proc hir::aot::analyze {hir} {
    set regions [dict create]
    set top [hir::top $hir]
    dict set regions program [NewRegion $hir program <program> \
        [dict get $hir scopes $top origin] {} "" {}]
    set statics [StaticBlocks $hir]
    set walk [hir::walk $hir]
    foreach e $walk {
        if {[hir::kind $hir $e] eq "block"} {
            dict set regions $e [NewRegion $hir $e [BlockName $hir $e] \
                [hir::get $hir $e origin] \
                [lmap b [hir::get $hir $e params] {
                    dict create binding $b name [BindingName $hir $b] \
                        type [hir::bindingType $hir $b]
                }] \
                [hir::type $hir [hir::get $hir $e resultType]] \
                [lmap b [hir::get $hir $e captures] {
                    dict create binding $b name [BindingName $hir $b] \
                        class [expr {[BoundBlock $hir $b] in $statics ? "block" : "value"}]
                }]]
        }
    }
    set tails [TailCalls $hir]
    set positions [dict create]
    set index 0
    foreach e $walk {
        dict set positions $e [incr index]
    }
    set state [dict create regions $regions reported {} initChecked {} positions $positions]
    foreach e $walk {
        set region [RegionOf $hir $e]
        if {![hir::get $hir $e reachable]} {
            dict update state regions regions {
                dict set regions $region unreachable \
                    [expr {[dict get $regions $region unreachable] + 1}]
            }
            continue
        }
        Visit $hir state $region $e $tails $statics
    }
    foreach diagnostic [hir::diagnostics $hir] {
        set e [dict get $diagnostic expr]
        set region [expr {$e ne "" && [dict exists $hir exprs $e] ? [RegionOf $hir $e] : "program"}]
        Block state $region [Blocker $hir StaticError $e "" "" {} \
            "[dict get $diagnostic kind]: [dict get $diagnostic message]"]
    }
    set regions [dict get $state regions]
    dict for {id region} $regions {
        dict set regions $id [Summarize $region]
    }
    return [dict create regions [Transitive $regions]]
}

# ---------------------------------------------------------------------------
# Regions

proc hir::aot::NewRegion {hir id name origin params result captures} {
    return [dict create id $id name $name origin $origin \
        location [Location $hir $origin] status closed dispatch closed transitive closed \
        params $params result $result captures $captures callees {} \
        blockers {} facts {} requirements {} unreachable 0]
}

proc hir::aot::RegionOf {hir e} {
    set invocation [dict get $hir scopes [hir::get $hir $e scope] invocation]
    return [expr {$invocation eq "" ? "program" : $invocation}]
}

proc hir::aot::BindingName {hir b} {
    set binding [hir::binding $hir $b]
    if {[dict exists $binding spelling]} {
        return [dict get $binding spelling]
    }
    return [dict get $binding name]
}

# The name block expression E is bound to, or "".
proc hir::aot::BlockName {hir e} {
    dict for {b binding} [dict get $hir bindings] {
        set declaredBy [dict get $binding declaredBy]
        if {$declaredBy ne "" && [hir::get $hir $declaredBy value] eq $e} {
            return [BindingName $hir $b]
        }
    }
    return ""
}

# The block ExprId binding B is statically bound to (a non-duplicate bind of
# a block expression), or "".
proc hir::aot::BoundBlock {hir b} {
    set binding [hir::binding $hir $b]
    if {[dict get $binding kind] ne "local" || [dict get $binding declaredBy] eq ""} {
        return ""
    }
    set value [hir::get $hir [dict get $binding declaredBy] value]
    return [expr {[hir::kind $hir $value] eq "block" ? $value : ""}]
}

# Blocks that need no environment: every binding they capture is bound to
# a block that itself needs none. Native code can call such a block as a
# plain function (after an init check on deferred references). Greatest
# fixpoint: assume every block qualifies, then remove failures.
proc hir::aot::StaticBlocks {hir} {
    set blocks [lmap e [hir::walk $hir] {
        if {[hir::kind $hir $e] ne "block"} continue
        set e
    }]
    set statics $blocks
    set changed 1
    while {$changed} {
        set changed 0
        foreach e $statics {
            foreach b [hir::get $hir $e captures] {
                if {[BoundBlock $hir $b] ni $statics} {
                    set statics [lsearch -all -inline -not -exact $statics $e]
                    set changed 1
                    break
                }
            }
        }
    }
    return $statics
}

# 1 if binding B is certainly bound whenever the deferred reference E (inside
# a closure) runs. HIR marks every reference from inside a closure deferred;
# a closure body can only run after its block value exists, so B is bound if
# the block C created in B's invocation, which contains E, is created after
# B is bound:
#   * B is a parameter (bound on entry to its invocation)
#   * C is the value B is bound to (a function referring to itself)
#   * B's bind comes before C in B's scope (in walk order, which is evaluation
#     order within one invocation; resolution has already rejected
#     references to B before its bind as `init no`)
# Otherwise (e.g. mutual recursion with a later function) native code needs
# a check, or a whole-program proof HIR does not make.
proc hir::aot::InitProven {hir e b positions} {
    set binding [hir::binding $hir $b]
    set home [dict get $hir scopes [dict get $binding scope] invocation]
    set c [dict get $hir scopes [hir::get $hir $e scope] invocation]
    while {$c ne ""} {
        set outer [dict get $hir scopes [hir::get $hir $c scope] invocation]
        if {$outer eq $home} {
            break
        }
        set c $outer
    }
    if {$c eq ""} {
        return 0
    }
    if {[dict get $binding kind] eq "param"} {
        return 1
    }
    set declaredBy [dict get $binding declaredBy]
    if {$declaredBy eq ""} {
        return 0
    }
    if {[hir::get $hir $declaredBy value] eq $c} {
        return 1
    }
    return [expr {[dict get $positions $declaredBy] < [dict get $positions $c]
                  && [hir::scopeWithin $hir [hir::get $hir $c scope] [dict get $binding scope]]}]
}

# ---------------------------------------------------------------------------
# Shared call facts for backends
#
# These are the semantic criteria every backend uses, so that the Tcl
# compiler and native lowering cannot disagree about them.

# Self tail calls: calls whose HIR target is the block they occur in, with
# matching arity, in tail position of that block (its body's value or a
# return's value, through if branches), and not inside a loop of that block.
# Such a call is the last thing its invocation does, so a backend may rebind
# the parameters and restart the body instead of nesting a call. Returns a
# dict call ExprId -> block ExprId.
proc hir::aot::selfTailCalls {hir} {
    set result [dict create]
    foreach e [TailCalls $hir] {
        lassign [hir::get $hir $e target] kind target
        if {$kind eq "block" && [RegionOf $hir $e] eq $target
                && [llength [hir::get $hir $target params]] == [llength [hir::get $hir $e args]]
                && ![InLoopOf $hir $e $target]} {
            dict set result $e $target
        }
    }
    return $result
}

# 1 if expression E is inside a loop body within block BLOCK's invocation.
proc hir::aot::InLoopOf {hir e block} {
    for {set s [hir::get $hir $e scope]} {$s ne "" && [dict get $hir scopes $s owner] ne $block} \
            {set s [dict get $hir scopes $s parent]} {
        if {[dict get $hir scopes $s kind] eq "loop"} {
            return 1
        }
    }
    return 0
}

# References (init deferred, to a local or parameter binding) that HIR cannot
# prove bound when they run (see InitProven): evaluating one must check that
# its binding has a value. Returns a dict ref ExprId -> BindingId.
proc hir::aot::unprovenReferences {hir} {
    set walk [hir::walk $hir]
    set positions [dict create]
    set index 0
    foreach e $walk {
        dict set positions $e [incr index]
    }
    set result [dict create]
    foreach e $walk {
        if {[hir::kind $hir $e] ne "ref" || [hir::get $hir $e init] ne "deferred"} {
            continue
        }
        set b [hir::get $hir $e binding]
        if {[dict get [hir::binding $hir $b] kind] in {local param}
                && ![InitProven $hir $e $b $positions]} {
            dict set result $e $b
        }
    }
    return $result
}

# The binding whose first bind binds block expression E (the function E
# defines), or "".
proc hir::aot::functionBinding {hir e} {
    dict for {b binding} [dict get $hir bindings] {
        set declaredBy [dict get $binding declaredBy]
        if {$declaredBy ne "" && [hir::get $hir $declaredBy value] eq $e} {
            return $b
        }
    }
    return ""
}

# ExprIds of the calls in tail position of their block: the value of the
# body, or of a return leaving the block, through if branches.
proc hir::aot::TailCalls {hir} {
    set tails {}
    foreach e [hir::walk $hir] {
        switch -- [hir::kind $hir $e] {
            block {
                set body [hir::get $hir $e body]
                if {$body ne ""} {
                    TailInto $hir [lindex $body end] tails
                }
            }
            return {
                if {[hir::get $hir $e target] ne ""} {
                    TailInto $hir [hir::get $hir $e value] tails
                }
            }
        }
    }
    return $tails
}

proc hir::aot::TailInto {hir e tailsVar} {
    upvar 1 $tailsVar tails
    switch -- [hir::kind $hir $e] {
        call { lappend tails $e }
        if {
            foreach role {thenBody elseBody} {
                set body [hir::get $hir $e $role]
                if {$body ne ""} {
                    TailInto $hir [lindex $body end] tails
                }
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Expressions

proc hir::aot::Visit {hir stateVar region e tails statics} {
    upvar 1 $stateVar state
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const {
            set value [dict get $node value]
            if {[core::value::kind $value] eq "int"} {
                set n [core::value::intOf $value]
                if {$n < -9223372036854775808 || $n > 9223372036854775807} {
                    Fact state $region [FactOf $hir bigint-literal $e] bigint
                }
            }
        }
        ref {
            set b [dict get $node binding]
            if {$b eq ""} {
                Block state $region [Blocker $hir UnresolvedBinding $e "" "" \
                    [dict create cause unresolved expr $e] "\"[dict get $node name]\" is not bound"]
                return
            }
            switch -- [dict get [hir::binding $hir $b] kind] {
                ambient {
                    Block state $region [Blocker $hir DynamicBinding $e "" "" \
                        [dict create cause ambient expr $e binding $b] \
                        "\"[dict get $node name]\" is looked up in an unknown environment at run time"]
                }
                local - param {
                    if {[dict get $node init] eq "deferred"
                            && ![dict exists $state initChecked $region $b]
                            && ![InitProven $hir $e $b [dict get $state positions]]} {
                        dict set state initChecked $region $b 1
                        Fact state $region [dict merge [FactOf $hir init-check $e] \
                            [dict create binding $b name [BindingName $hir $b]]] init-check
                    }
                }
            }
        }
        block {
            set values [lmap b [dict get $node captures] {
                if {[BoundBlock $hir $b] in $statics} continue
                set b
            }]
            if {$values ne ""} {
                Fact state $region [dict merge [FactOf $hir closure $e] \
                    [dict create block $e captures $values]] closure-env
            }
        }
        call {
            VisitCall $hir state $region $e $node $tails $statics
        }
        if {
            set condition [dict get $node condition]
            Require $hir state $region $e $condition bool NOT-BOOLEAN
        }
        return - break - continue {
            if {[dict get $node target] eq ""} {
                Block state $region [Blocker $hir UnresolvedControl $e "" "" {} \
                    "[dict get $node kind] has no enclosing target"]
            }
        }
        ok - error {
            Fact state $region [FactOf $hir result-alloc $e] result-alloc
        }
    }
}

proc hir::aot::VisitCall {hir stateVar region e node tails statics} {
    upvar 1 $stateVar state
    set callee [dict get $node callee]
    set args [dict get $node args]
    set calleeType [hir::typeOf $hir $callee]
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "native"} {
        set name [dict get [hir::symbol $hir $target] name]
        set meta [core::native::metadata $name]
        set arity [dict get $meta arity]
        if {$arity ne "*" && $arity != [llength $args]} {
            Fact state $region [dict merge [FactOf $hir known-error $e] [dict create error ARITY]]
            return
        }
        set runtime [dict get $meta runtime]
        set argKinds [lmap arg $args {hir::types::kindOf [hir::typeOf $hir $arg]}]
        if {"structural-equality" in $runtime && [llength $argKinds] == 2
                && [lindex $argKinds 0] eq [lindex $argKinds 1]
                && [lindex $argKinds 0] in {int str bool unit}} {
            # Both kinds known and scalar: no structural walk is needed.
            set runtime [lsearch -all -inline -not -exact $runtime structural-equality]
            if {[lindex $argKinds 0] eq "int"} {
                lappend runtime bigint
            }
        }
        if {[dict get $node known] ne ""} {
            # A type test decided statically: nothing runs.
            set runtime {}
        }
        Fact state $region [dict merge [FactOf $hir native-call $e] \
            [dict create native $name runtime [lsort -unique $runtime] argKinds $argKinds]] {*}$runtime
        if {[dict get $node known] eq ""} {
            foreach arg $args param [dict get $meta paramTypes] {
                if {$arg ne "" && $param ne ""} {
                    Require $hir state $region $e $arg $param TYPE $name
                }
            }
        }
        return
    }
    if {$targetKind eq "block"} {
        set name [BlockName $hir $target]
        if {[llength [hir::get $hir $target params]] != [llength $args]} {
            Fact state $region [dict merge [FactOf $hir known-error $e] [dict create error ARITY]]
            return
        }
        Fact state $region [dict merge [FactOf $hir direct-call $e] \
            [dict create block $target name $name tail [expr {$e in $tails}] \
                self [expr {$target eq $region}]]]
        dict update state regions regions {
            if {$target ni [dict get $regions $region callees]} {
                dict set regions $region callees [concat [dict get $regions $region callees] [list $target]]
            }
        }
        if {$target ni $statics} {
            dict update state regions regions {
                dict set regions $region requirements \
                    [lsort -unique [concat [dict get $regions $region requirements] closure-env]]
            }
        }
        return
    }
    set kind [hir::types::kindOf $calleeType]
    if {$kind in {block native}} {
        Fact state $region [dict merge [FactOf $hir indirect-call $e] \
            [dict create calleeKind $kind]] indirect-call
    } elseif {$kind eq ""} {
        if {$calleeType ne "never"} {
            Block state $region [Blocker $hir DynamicCall $callee $e "" [Cause $hir $callee] \
                "the callee has no static kind: native, block or not callable is decided at run time"]
            dict update state regions regions {
                dict set regions $region requirements \
                    [lsort -unique [concat [dict get $regions $region requirements] dynamic-call tagged-values]]
            }
        }
    } else {
        Fact state $region [dict merge [FactOf $hir known-error $e] [dict create error NOT-CALLABLE]]
    }
}

# Operation OP requires operand ARG to be of type TYPE (a core type); a
# mismatch raises ERROR. Reports a known error, or a blocker for the check
# native code needs, once per operand.
proc hir::aot::Require {hir stateVar region op arg type error {what ""}} {
    upvar 1 $stateVar state
    if {$type eq "any"} {
        return
    }
    set argType [hir::typeOf $hir $arg]
    if {$argType eq "never" || [core::type::subtype [hir::types::semantic $argType] $type]} {
        return
    }
    if {[dict exists $state reported $arg]} {
        return
    }
    dict set state reported $arg 1
    set kind [hir::types::kindOf $argType]
    set base [core::type::base $type]
    set what [expr {$what eq "" ? "the condition" : "$what"}]
    if {$kind eq ""} {
        set cause [Cause $hir $arg]
        set blockerKind [dict get {
            parameter UnknownParameterKind aggregate-element UnknownAggregateElementType
            native-result UnknownCallResultKind block-result UnknownCallResultKind
            dynamic-result UnknownCallResultKind merge UnknownValueKind ambient UnknownValueKind
            unresolved UnknownValueKind unknown UnknownValueKind
        } [dict get $cause cause]]
        Block state $region [Blocker $hir $blockerKind $arg $op $type $cause \
            "$what needs [core::type::show $type]; [CauseText $hir $cause] has no static kind"]
        dict update state regions regions {
            dict set regions $region requirements \
                [lsort -unique [concat [dict get $regions $region requirements] tagged-values]]
        }
    } elseif {$kind ne $base} {
        Fact state $region [dict merge [FactOf $hir known-error $op] \
            [dict create error $error operand $arg]]
    } else {
        Block state $region [Blocker $hir UnprovenRefinement $arg $op $type [dict create cause unknown expr $arg] \
            "$what needs [core::type::show $type]; the operand is only known to be [hir::types::show $argType]"]
    }
}

# Where the unknown kind of expression E comes from.
proc hir::aot::Cause {hir e {depth 0}} {
    set cause [dict create cause unknown expr $e binding "" native "" block ""]
    if {$depth > 50} {
        return $cause
    }
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        ref {
            set b [dict get $node binding]
            if {$b eq ""} {
                return [dict merge $cause [dict create cause unresolved]]
            }
            dict set cause binding $b
            switch -- [dict get [hir::binding $hir $b] kind] {
                param   { return [dict merge $cause [dict create cause parameter]] }
                ambient { return [dict merge $cause [dict create cause ambient]] }
                local {
                    set declaredBy [dict get [hir::binding $hir $b] declaredBy]
                    if {$declaredBy ne ""} {
                        return [Cause $hir [hir::get $hir $declaredBy value] [expr {$depth + 1}]]
                    }
                }
            }
        }
        bind {
            return [Cause $hir [dict get $node value] [expr {$depth + 1}]]
        }
        call {
            lassign [dict get $node target] targetKind target
            switch -- $targetKind {
                native {
                    set name [dict get [hir::symbol $hir $target] name]
                    dict set cause native $name
                    # A native that takes an aggregate and returns an unknown
                    # kind hands out one of its elements.
                    foreach param [dict get [core::native::metadata $name] paramTypes] {
                        if {[core::type::base $param] in {list result}} {
                            return [dict merge $cause [dict create cause aggregate-element]]
                        }
                    }
                    return [dict merge $cause [dict create cause native-result]]
                }
                block {
                    return [dict merge $cause [dict create cause block-result block $target]]
                }
                default {
                    return [dict merge $cause [dict create cause dynamic-result]]
                }
            }
        }
        if - loop {
            return [dict merge $cause [dict create cause merge]]
        }
    }
    return $cause
}

proc hir::aot::CauseText {hir cause} {
    set e [dict get $cause expr]
    set at [LocationText [Location $hir [hir::get $hir $e origin]]]
    switch -- [dict get $cause cause] {
        parameter {
            return "parameter [BindingName $hir [dict get $cause binding]] (no annotation, no call-site inference)"
        }
        aggregate-element {
            return "the element read by [dict get $cause native] at $at"
        }
        native-result {
            return "the result of [dict get $cause native] at $at"
        }
        block-result {
            set name [BlockName $hir [dict get $cause block]]
            return "the result of [expr {$name eq "" ? "block [dict get $cause block]" : $name}] at $at"
        }
        dynamic-result {
            return "the result of the dynamic call at $at"
        }
        merge {
            return "the value merged from different paths at $at"
        }
        ambient {
            return "the ambient binding [BindingName $hir [dict get $cause binding]]"
        }
        default {
            return "the operand at $at"
        }
    }
}

# ---------------------------------------------------------------------------
# Recording

proc hir::aot::Blocker {hir kind e op requires cause message} {
    set class [expr {$kind in {DynamicCall DynamicBinding UnresolvedBinding UnresolvedControl StaticError}
        ? "semantic" : "representation"}]
    set origin [expr {$e ne "" && [dict exists $hir exprs $e] ? [hir::get $hir $e origin] : ""}]
    return [dict create kind $kind class $class expr $e origin $origin \
        location [Location $hir $origin] operation $op requires $requires \
        cause [dict merge [dict create cause "" expr "" binding "" native "" block ""] $cause] \
        message $message]
}

proc hir::aot::FactOf {hir kind e} {
    set origin [hir::get $hir $e origin]
    return [dict create kind $kind expr $e origin $origin location [Location $hir $origin]]
}

proc hir::aot::Block {stateVar region blocker} {
    upvar 1 $stateVar state
    dict update state regions regions {
        dict set regions $region blockers [concat [dict get $regions $region blockers] [list $blocker]]
    }
}

proc hir::aot::Fact {stateVar region fact args} {
    upvar 1 $stateVar state
    dict update state regions regions {
        dict set regions $region facts [concat [dict get $regions $region facts] [list $fact]]
        if {$args ne ""} {
            dict set regions $region requirements \
                [lsort -unique [concat [dict get $regions $region requirements] $args]]
        }
    }
}

proc hir::aot::Summarize {region} {
    set classes [lmap b [dict get $region blockers] {dict get $b class}]
    set status closed
    if {"representation" in $classes} {
        set status guarded
    }
    if {"semantic" in $classes} {
        set status open
    }
    dict set region status $status
    dict set region dispatch [expr {"semantic" in $classes ? "open" : "closed"}]
    return $region
}

proc hir::aot::Worse {a b} {
    variable statusRank
    return [expr {[dict get $statusRank $a] >= [dict get $statusRank $b] ? $a : $b}]
}

proc hir::aot::Transitive {regions} {
    dict for {id region} $regions {
        dict set regions $id transitive [dict get $region status]
    }
    set changed 1
    while {$changed} {
        set changed 0
        dict for {id region} $regions {
            set status [dict get $region transitive]
            foreach callee [dict get $region callees] {
                if {[dict exists $regions $callee]} {
                    set status [Worse $status [dict get $regions $callee transitive]]
                }
            }
            if {$status ne [dict get $region transitive]} {
                dict set regions $id transitive $status
                set changed 1
            }
        }
    }
    return $regions
}

# ---------------------------------------------------------------------------
# Locations

proc hir::aot::Location {hir origin} {
    if {[catch {dict size $origin}]} {
        return {}
    }
    if {[dict exists $origin file] && [dict exists $origin line]} {
        set file [dict get $origin file]
        set path [expr {[dict exists $hir files $file] ? [dict get $hir files $file path] : $file}]
        return [dict create file $path line [dict get $origin line] \
            column [dict get $origin column] node [dict get $origin node]]
    }
    if {[dict exists $origin ir]} {
        return [dict create ir [dict get $origin ir]]
    }
    return {}
}

proc hir::aot::LocationText {location} {
    if {[dict exists $location line]} {
        return "line [dict get $location line]:[dict get $location column]"
    }
    if {[dict exists $location ir]} {
        return "ir {[dict get $location ir]}"
    }
    return "?"
}

# ---------------------------------------------------------------------------
# Human-readable explanation (derived from the analysis)

proc hir::aot::explain {hir {analysis ""}} {
    if {$analysis eq ""} {
        set analysis [analyze $hir]
    }
    set lines {}
    dict for {id region} [dict get $analysis regions] {
        set name [dict get $region name]
        if {$name eq ""} {
            set name "block $id"
        }
        set status [dict get $region status]
        set transitive [dict get $region transitive]
        set header "$name: $status"
        if {$transitive ne $status} {
            append header " (transitively $transitive)"
        }
        append header "   \[[join [lmap part [list $id [LocationText [dict get $region location]]] {set part}] {, }]\]"
        lappend lines $header
        if {$id ne "program"} {
            set params [lmap p [dict get $region params] {
                string cat [dict get $p name] " : " [hir::types::show [dict get $p type]]
            }]
            lappend lines "  params:   [expr {$params eq "" ? "(none)" : [join $params {, }]}]   result: [hir::types::show [dict get $region result]]"
            if {[dict get $region captures] ne ""} {
                lappend lines "  captures: [join [lmap c [dict get $region captures] {
                    string cat [dict get $c name] " (" [dict get $c class] ")"
                }] {, }]"
            }
        }
        lappend lines "  dispatch: [dict get $region dispatch] -- [CallSummary $region]"
        set blockers [dict get $region blockers]
        if {$blockers eq ""} {
            lappend lines "  blockers: none"
        } else {
            lappend lines "  blockers:"
            foreach blocker $blockers {
                lappend lines "    [LocationText [dict get $blocker location]]  [dict get $blocker expr]  [dict get $blocker kind]: [dict get $blocker message]"
            }
        }
        set notes {}
        foreach fact [dict get $region facts] {
            switch -- [dict get $fact kind] {
                known-error {
                    lappend notes "[LocationText [dict get $fact location]]  [dict get $fact expr]  always raises [dict get $fact error]"
                }
                indirect-call {
                    lappend notes "[LocationText [dict get $fact location]]  [dict get $fact expr]  indirect call of a [dict get $fact calleeKind] (target unknown)"
                }
                closure {
                    lappend notes "[LocationText [dict get $fact location]]  [dict get $fact expr]  creates a closure capturing values"
                }
            }
        }
        foreach note $notes {
            lappend lines "  note:     $note"
        }
        set requirements [dict get $region requirements]
        lappend lines "  runtime:  [expr {$requirements eq "" ? "none" : [join $requirements {, }]}]"
        if {[dict get $region unreachable]} {
            lappend lines "  unreachable expressions skipped: [dict get $region unreachable]"
        }
        lappend lines ""
    }
    return [join [lrange $lines 0 end-1] \n]
}

proc hir::aot::CallSummary {region} {
    set natives [dict create]
    set blocks {}
    set other 0
    foreach fact [dict get $region facts] {
        switch -- [dict get $fact kind] {
            native-call {
                dict incr natives [dict get $fact native]
            }
            direct-call {
                set label [expr {[dict get $fact name] eq "" ? "block [dict get $fact block]" : [dict get $fact name]}]
                set flags {}
                if {[dict get $fact self]} { lappend flags self }
                lappend flags [expr {[dict get $fact tail] ? "tail" : "non-tail"}]
                lappend blocks "$label ([join $flags {, }])"
            }
            indirect-call {
                incr other
            }
        }
    }
    set parts {}
    if {[dict size $natives]} {
        lappend parts "natives: [join [lmap {name count} $natives {
            expr {$count > 1 ? "$name x$count" : $name}
        }] {, }]"
    }
    if {$blocks ne ""} {
        lappend parts "functions: [join [lsort -unique $blocks] {, }]"
    }
    if {$other} {
        lappend parts "indirect calls: $other"
    }
    set dynamic [llength [lsearch -all -exact [lmap b [dict get $region blockers] {dict get $b kind}] DynamicCall]]
    if {$dynamic} {
        lappend parts "dynamic calls: $dynamic"
    }
    if {$parts eq ""} {
        return "no calls"
    }
    return [join $parts {; }]
}
