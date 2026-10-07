# signatures.tcl -- intrinsic function contracts: what an untyped
# parameter's own function body requires of it
# (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md).
#
# Before this pass an untyped parameter was simply `any` everywhere: its
# body saw `any`, its exact Block's structural contract said `any`, and no
# call of the function was ever checked against anything. Botlish already
# infers what an expression *produces*; this infers the other direction --
# what a function *requires* -- from the function's own declaration and
# body alone, never from who happens to call it (no caller-ingress facts,
# no code targets: a later compatible caller never invalidates it).
#
# Requirements
# ------------
# Every reachable use of a parameter (or of a local that is an immutable
# alias of one, `y = x`: bindings are single-assignment, so a use of y is a
# use of x's value) that flows into a position with a statically known
# admissibility domain imposes that domain on the parameter. The domains
# come only from the metadata ordinary checking already uses for the same
# position -- never a second, hand-maintained table:
#
#   argument i of a native      core::native::metadata's paramTypes (the
#                               same -param-types hir::types::Call narrows
#                               an argument with after the call returns,
#                               and hir::specialize reads to decide a call
#                               always raises TYPE)                 CHECKED
#   argument i of a Block       its declared parameter type          TRUSTED
#                               (hir::range::VerifyCall's proof), or
#                               its own inferred contract (an edge,
#                               solved to a fixed point below)       both
#   argument i through an Fn    the contract's argument type
#                               (VerifyStructuralCall's proof)       TRUSTED
#   a declared result position  the declared result type
#                               (verifyDeclaredResults's proof)       TRUSTED
#   an `if` condition           bool (NOT-BOOLEAN; `not`/`and`/`or`
#                               lower to `if`)                       CHECKED
#   a loop iterable             list; counted-loop bounds: int
#                               (core::value::expect in the evaluator) CHECKED
#
# Several requirements combine by meet (hir::types::glb, and FnGlb for two
# function types): the value must satisfy every use, so the contract is the
# greatest lower bound, never the lub. No representable meet (str and int)
# is a compile-time TYPE error naming both uses -- never a silent fallback
# to `any`.
#
# A use is not a requirement on the whole parameter when the use site
# already proves it (a flow fact from an earlier use, a branch refinement:
# the use-site type, excluding the parameter's own seed, admits it), when
# it is statically unreachable (hir::types' own reachability), or when it
# lies in a branch of an `if` whose condition refines the parameter
# (control-flow-dependent: `if integer?(x): x + 1 else: str::length(x)` accepts
# both kinds; no union type exists to say so, so neither branch constrains
# the parameter).
#
# Trusted and checked requirements
# --------------------------------
# A requirement is TRUSTED when the function body cannot be typed or
# verified without assuming it: forwarding an untyped parameter to a
# declared-typed parameter (previously a static error in the forwarding
# body) or through a structural function type, a declared result position,
# and the structural contract of a parameter the body *calls*. A trusted
# contract is exactly as strong as a declaration: the body is seeded with
# it (hir::types::Block, hir::specialize's entry seeding), every call must
# prove it (hir::range::VerifyCall, unproven -> compile-time error), it is
# part of the exact Block's structural contract (hir::types::BlockContract
# -> structuralOf), and it makes the Block precondition-bearing for the
# typed-callable escape audit (hir::callables::Bearing).
#
# A requirement is CHECKED when the operation imposing it validates it at
# run time anyway -- a native's -param-types are "types the implementation
# *requires*" (core/native.tcl), re-checked on every call, and an `if`
# raises NOT-BOOLEAN. The wrapper inherits exactly the native's status:
# its contract records the requirement, a call whose argument is of a
# statically *known* type that is not admissible is rejected at compile
# time (the deliberate strengthening: `wrapper(123)` no longer reaches the
# native's run-time TYPE error), but the body is never compiled assuming
# it, so it is never part of a structural `Fn` argument type (exactly why a
# native's own structural arguments are `any`, STRUCTURAL-FUNCTION-TYPES.
# md) and an argument whose static type is `any` still reaches the
# native's own check. That last point is the non-generic boundary: `any`
# today conflates "any possible value" with "a relational type the
# language cannot yet express" (list::find's result, the element of a List
# built by a helper whose element type depends on its caller), and
# rejecting it would reject canonical programs whose only fault is the
# missing type variable -- see the report's "Known limitations".
#
# Callable parameters
# -------------------
# A parameter the body calls (`predicate(char_at(i))`) is inferred an
# ordinary structural function type when, and only when, every part of it
# is concretely representable:
#
#   args     the static types of the actual arguments, joined over every
#            call site (the body promises only these; contravariance then
#            admits any callable whose parameters accept them) -- each must
#            be *concrete*: a scalar/refined type or a List/ImmutableSet of
#            one. `any` (or an aggregate/callable containing unknowns) is an
#            unresolved relational constraint -- `loop x in xs:
#            predicate(x)` needs "the element type of xs", a type variable
#            Botlish does not have -- and then NO Fn is inferred at all
#            (never Fn{args: [any], ...}, which would reject a perfectly
#            valid str -> bool predicate for a List[str]).
#   return   the meet of every consumption requirement of a call's result
#            (an `if` condition: bool; an argument position: its domain);
#            unconstrained -> any.
#   errors   the intersection, over call sites, of what each call site's
#            context admits: the `on` handlers of a `handle` directly
#            around it, plus the enclosing function's own declared errors
#            -- the widest set whose every member is statically accounted
#            for (an upper bound: a callable raising fewer is compatible).
#
# The parameter must also not escape: a use other than as a callee, an
# alias, or an argument to a position whose contract is itself a function
# type (flowing into a list, an untyped parameter, a native, a return...)
# means an unknown party may call it with unknown arguments, so no contract
# is inferred for it. The inferred type is TRUSTED (the body's calls are
# typed from it: result, declared errors). It is a contract, never a code
# target: nothing here tracks which callables reach the parameter.
#
# Fixed point
# -----------
# Requirements propagate through ordinary calls (h(z) -> g(y) -> f(x)) and
# through recursion: every inferable parameter starts unconstrained (top),
# each constraint is monotone in the contracts it reads, and each round
# recomputes every contract as the meet of its requirements, in a fixed
# order, until nothing changes -- the greatest solution, independent of
# definition order. Requirement types come from a finite set (declared and
# native parameter types, bool/list/int, Fn types over those -- callable
# arguments are never themselves callable, which bounds Fn nesting), and
# glb only descends, so this terminates. Because trusted contracts are
# seeded into the body's typing, an outer loop re-infers types
# (hir::types::infer) whenever a trusted contract changed, and meets the
# new contracts with the previous round's (monotone) until they are stable.
#
# Future dimensions (a `context` requirement) are one more constraint kind
# in Collect and one more field in Contract, alongside args/return/errors.

namespace eval hir::signatures {
    # Outer (re-typing) rounds and inner solver sweeps: both converge far
    # sooner on every program; exceeding either is a compiler bug.
    variable maxRounds 32
    variable maxSweeps 1000
}

# ---------------------------------------------------------------------------
# Queries: the one authoritative intrinsic signature of a block.

# The type the body of block expression E is entered with for each
# parameter, and that every call must prove -- its declared type, else its
# TRUSTED inferred contract, else "" (unconstrained): one list, parallel to
# params. hir::types (seeding, BlockContract), hir::range::VerifyCall,
# hir::callables and hir::specialize all read this, never the declaration
# alone.
proc hir::signatures::entryTypes {hir e} {
    set node [dict get $hir exprs $e]
    set declared [expr {[dict exists $node declaredParamTypes]
        ? [dict get $node declaredParamTypes] : [lrepeat [llength [dict get $node params]] {}]}]
    if {![dict exists $node inferredParamTypes]} {
        return $declared
    }
    return [lmap d $declared i [dict get $node inferredParamTypes] {
        expr {$d ne {} ? $d : $i}
    }]
}

# The CHECKED contract of each parameter of block E ("" where there is
# none beyond its entry type): the full inferred requirement, of which the
# trusted part is entryTypes.
proc hir::signatures::checkedTypes {hir e} {
    set node [dict get $hir exprs $e]
    if {![dict exists $node checkedParamTypes]} {
        return [lrepeat [llength [dict get $node params]] {}]
    }
    return [dict get $node checkedParamTypes]
}

# 1 if parameter I of block E has an inferred (not declared) trusted
# contract.
proc hir::signatures::inferredTrusted {hir e i} {
    set node [dict get $hir exprs $e]
    return [expr {[dict exists $node inferredParamTypes]
        && [lindex [dict get $node inferredParamTypes] $i] ne {}
        && [lindex [dict get $node declaredParamTypes] $i] eq {}}]
}

# The intrinsic signature of block E, for tooling and the milestone audit:
#
#   params  one dict per parameter: name, declared (type or ""), trusted
#           (the entry type: declared or inferred-trusted, "" if none),
#           checked (the full inferred requirement, "" if none), source
#           (declared | inferred | none), why (the requirement provenance:
#           {kind trusted|checked type T expr E what TEXT} records)
#   result  the declared result type, else the inferred one
#   errors  the declared error set
proc hir::signatures::of {hir e} {
    set node [dict get $hir exprs $e]
    set entry [entryTypes $hir $e]
    set checked [checkedTypes $hir $e]
    set why [expr {[dict exists $node paramRequirements] ? [dict get $node paramRequirements]
        : [lrepeat [llength [dict get $node params]] {}]}]
    set params {}
    foreach b [dict get $node params] d [dict get $node declaredParamTypes] \
            t $entry c $checked w $why {
        set source [expr {$d ne {} ? "declared" : ($t ne {} || $c ne {}) ? "inferred" : "none"}]
        lappend params [dict create name [dict get $hir bindings $b name] binding $b \
            declared $d trusted $t checked $c source $source why $w]
    }
    set result any
    if {[dict exists $node resultType] && [dict get $node resultType] ne ""} {
        set result [hir::type $hir [dict get $node resultType]]
    }
    return [dict create params $params result $result \
        errors [expr {[dict exists $node declaredErrors] ? [dict get $node declaredErrors] : {}}]]
}

# One parameter's contract as the user would read it: its trusted type if
# it has one (callers must prove it), else its checked one, else any.
proc hir::signatures::paramType {param} {
    foreach key {trusted checked} {
        if {[dict get $param $key] ne {}} {
            return [dict get $param $key]
        }
    }
    return any
}

# ---------------------------------------------------------------------------
# Entry point: hir::buildSyntax's (and native::prepareHir's) typing step.
#
# Types HIR (hir::types::infer) with every block's intrinsic contracts
# inferred and its trusted ones seeded, and records on every block node:
#
#   inferredParamTypes   trusted inferred contract per parameter ("")
#   checkedParamTypes    full inferred requirement per parameter ("")
#   paramRequirements    provenance per parameter (see `of`)
#   paramNotes           per parameter: why a callable contract was not
#                        inferred ({relational ...}/{escapes ...}/...), or ""
#
# DEMOTE (a list of parameter BindingIds) keeps those parameters' trusted
# contracts checked-only: hir::buildSyntax's -strict 0 recovery for a
# program one of whose calls violates a trusted inferred contract, so no
# backend compiles a body assuming a contract its program breaks.
proc hir::signatures::infer {hirVar {demote {}}} {
    upvar 1 $hirVar hir
    variable maxRounds
    set base $hir
    set seeds [dict create]
    for {set round 1} {$round <= $maxRounds} {incr round} {
        set typed $base
        Install typed $seeds {} {}
        hir::types::infer typed
        set A [Collect $typed]
        set solution [Solve $typed $A]
        set next [dict create]
        dict for {p contract} $solution {
            set t [dict get $contract trusted]
            if {$t ne "any" && $p ni $demote} {
                dict set next $p $t
            }
        }
        # Monotone across rounds: a trusted contract only ever narrows.
        dict for {p t} $seeds {
            if {![dict exists $next $p]} {
                dict set next $p $t
            } else {
                set m [Meet $t [dict get $next $p]]
                dict set next $p [expr {$m eq "" ? $t : $m}]
            }
        }
        if {$next eq $seeds || [lsort -stride 2 $next] eq [lsort -stride 2 $seeds]} {
            Install typed $seeds $solution $A
            Diagnose typed $A $solution
            set hir $typed
            return
        }
        set seeds $next
    }
    error "hir::signatures::infer: trusted contracts did not converge after $maxRounds rounds"
}

# Writes the per-block fields: SEEDS (param -> trusted type) and, once
# solved, SOLUTION's checked contracts, provenance and notes.
proc hir::signatures::Install {hirVar seeds solution A} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block"} {
            continue
        }
        set trusted {}
        set checked {}
        set why {}
        set notes {}
        foreach b [dict get $node params] d [dict get $node declaredParamTypes] {
            set t [expr {$d eq {} && [dict exists $seeds $b] ? [dict get $seeds $b] : {}}]
            lappend trusted $t
            if {$d eq {} && [dict exists $solution $b]} {
                set c [dict get $solution $b checked]
                lappend checked [expr {$c eq "any" || $c eq $t ? {} : $c}]
                lappend why [dict get $solution $b why]
                lappend notes [dict get $solution $b note]
            } else {
                lappend checked {}
                lappend why {}
                lappend notes {}
            }
        }
        dict set hir exprs $e inferredParamTypes $trusted
        dict set hir exprs $e checkedParamTypes $checked
        dict set hir exprs $e paramRequirements $why
        dict set hir exprs $e paramNotes $notes
    }
}

# ---------------------------------------------------------------------------
# Requirement collection (over one typed HIR)
#
# Returns a dict:
#
#   params   param BindingId -> {block E index I}  (every untyped parameter)
#   slots    "E I" -> param BindingId
#   seeds    param -> its entry type in this typing ("any" if none)
#   alias    local BindingId -> BindingId it immutably aliases
#   resultOf local BindingId -> BindingId whose call result it is bound to
#   reqs     param -> {kind K type T expr E what W} constant requirements
#   edges    param -> {block B index I expr E what W use U}: requires
#            B's parameter I's contract, unless the use-site type U ("" =
#            unproven) already admits it
#   calls    param -> {expr E args {T...} admitted {ERR...}}
#   rets     param -> {type T expr E what W} | {block B index I expr E what W}
#   escapes  param -> {expr E what W}
#   fnEdges  param -> {block B index I expr E}: an escape unless B's
#            parameter I ends up with a function-type contract

proc hir::signatures::Collect {hir} {
    set A [dict create params {} slots {} seeds {} alias {} resultOf {} \
        reqs {} edges {} calls {} rets {} escapes {} fnEdges {}]
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            block {
                set entry [entryTypes $hir $e]
                set i 0
                foreach b [dict get $node params] d [dict get $node declaredParamTypes] {
                    if {$d eq {}} {
                        dict set A params $b [dict create block $e index $i]
                        dict set A slots [list $e $i] $b
                        set t [lindex $entry $i]
                        dict set A seeds $b [expr {$t eq {} ? "any" : $t}]
                    }
                    incr i
                }
            }
            bind {
                if {[dict get $node duplicate]} {
                    continue
                }
                set y [dict get $node binding]
                if {$y eq "" || [dict get $hir bindings $y kind] ne "local"} {
                    continue
                }
                set v [dict get $node value]
                set vnode [dict get $hir exprs $v]
                switch -- [dict get $vnode kind] {
                    ref {
                        if {[dict get $vnode binding] ne ""} {
                            dict set A alias $y [dict get $vnode binding]
                        }
                    }
                    call {
                        set callee [dict get $vnode callee]
                        if {[dict get $vnode target] eq "" && [hir::kind $hir $callee] eq "ref"
                                && [hir::get $hir $callee binding] ne ""} {
                            dict set A resultOf $y [hir::get $hir $callee binding]
                        }
                    }
                }
            }
        }
    }
    set ctx [dict create block program handled {} tested {}]
    Seq $hir A [hir::roots $hir] drop $ctx
    return $A
}

# Appends VALUE to the list A FIELD P.
proc hir::signatures::Push {AVar field p value} {
    upvar 1 $AVar A
    set list [expr {[dict exists $A $field $p] ? [dict get $A $field $p] : {}}]
    lappend list $value
    dict set A $field $p $list
}

# What binding B's value is, as far as requirements go: {param P} (B is,
# or immutably aliases, untyped parameter P), {ret P} (B is bound to the
# result of calling untyped parameter P), or "".
proc hir::signatures::Root {AVar b} {
    upvar 1 $AVar A
    set seen {}
    while {$b ni $seen} {
        lappend seen $b
        if {[dict exists $A params $b]} {
            return [list param $b]
        }
        if {[dict exists $A alias $b]} {
            set b [dict get $A alias $b]
            continue
        }
        if {[dict exists $A resultOf $b]} {
            set r [Root A [dict get $A resultOf $b]]
            return [expr {[lindex $r 0] eq "param" ? [list ret [lindex $r 1]] : ""}]
        }
        return ""
    }
    return ""
}

proc hir::signatures::Seq {hir AVar exprs sink ctx} {
    upvar 1 $AVar A
    set n [llength $exprs]
    set i 0
    foreach e $exprs {
        incr i
        Value $hir A $e [expr {$i == $n ? $sink : "drop"}] $ctx
    }
}

# The sink a block's trailing value / `return` flows into.
proc hir::signatures::ResultSink {hir block} {
    if {$block eq "" || $block eq "program"} {
        return flow
    }
    set declared [dict get $hir exprs $block declaredResult]
    if {$declared ne {}} {
        return [list type $declared trusted "the declared result type of [Name $hir $block]"]
    }
    return flow
}

# The name block E is bound to, for messages ("a function" if anonymous).
proc hir::signatures::Name {hir e} {
    if {$e eq "program"} {
        return "the program"
    }
    set scope [dict get $hir exprs $e scope]
    foreach b [dict get $hir scopes $scope bindings] {
        set declaredBy [dict get $hir bindings $b declaredBy]
        if {$declaredBy ne "" && [dict exists $hir exprs $declaredBy]
                && [dict get $hir exprs $declaredBy value] eq $e} {
            return [dict get $hir bindings $b name]
        }
    }
    return "a function"
}

# Walks expression E, whose value flows into SINK:
#
#   drop          discarded (a statement's value)
#   alias         bound to a local (its own uses are this value's uses)
#   flow          somewhere this pass does not model (a List element, a
#                 return value, an untyped native argument, ...)
#   {type T K W}  a position requiring T (K trusted|checked); W says which
#   {param B I W} parameter I of block B (untyped: its contract, an edge)
#   {pcallarg P I}  argument I of a call of untyped parameter P
#
# CTX: block (the enclosing function, for error admission), handled (the
# handler names of a `handle` directly around this call), tested (params
# refined by an enclosing `if`: their uses are path-dependent).
proc hir::signatures::Value {hir AVar e sink ctx} {
    upvar 1 $AVar A
    set node [dict get $hir exprs $e]
    set handled [dict get $ctx handled]
    dict set ctx handled {}
    switch -- [dict get $node kind] {
        const - continue - fail {
        }
        ref {
            Use $hir A $e $sink $ctx
        }
        bind {
            Value $hir A [dict get $node value] alias $ctx
        }
        block {
            # A nested function is walked where it is created, so it
            # inherits the path-dependence of its creation point (its body
            # starts from the facts known there, hir::types::Block).
            dict set ctx block $e
            Seq $hir A [dict get $node body] [ResultSink $hir $e] $ctx
        }
        call {
            dict set ctx handled $handled
            Call $hir A $e $sink $ctx
        }
        if {
            Value $hir A [dict get $node condition] \
                {type bool checked "the condition of an if (or not/and/or)"} $ctx
            if {[dict exists $node refinements]} {
                foreach outcome {1 0} {
                    if {![dict exists $node refinements $outcome]} {
                        continue
                    }
                    foreach {b fact} [dict get $node refinements $outcome] {
                        set r [Root A $b]
                        if {[lindex $r 0] eq "param"} {
                            dict set ctx tested [lindex $r 1] 1
                        }
                    }
                }
            }
            Seq $hir A [dict get $node thenBody] $sink $ctx
            Seq $hir A [dict get $node elseBody] $sink $ctx
        }
        loop {
            Seq $hir A [dict get $node body] drop $ctx
        }
        listloop {
            Value $hir A [dict get $node iterable] {type list checked "the iterable of a loop"} $ctx
            Seq $hir A [dict get $node body] flow $ctx
        }
        countloop {
            Value $hir A [dict get $node start] {type int checked "the start of a counted loop"} $ctx
            Value $hir A [dict get $node end] {type int checked "the end of a counted loop"} $ctx
            Seq $hir A [dict get $node body] flow $ctx
        }
        lockloop {
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    Value $hir A [dict get $domain iterable] {type list checked "the iterable of a loop"} $ctx
                } else {
                    Value $hir A [dict get $domain start] {type int checked "the start of a counted loop"} $ctx
                    Value $hir A [dict get $domain end] {type int checked "the end of a counted loop"} $ctx
                }
            }
            Seq $hir A [dict get $node body] flow $ctx
        }
        return {
            if {[dict get $node value] ne ""} {
                Value $hir A [dict get $node value] [ResultSink $hir [dict get $node target]] $ctx
            }
        }
        break - ok - error {
            if {[dict get $node value] ne ""} {
                Value $hir A [dict get $node value] flow $ctx
            }
        }
        struct {
            # Every field value flows into a position this analysis does not
            # follow (STRUCTS.md): a struct field never infers a parameter
            # contract, not even a declared field type -- an unproven value
            # is that construction's own TYPE error (hir::range::VerifyStruct).
            foreach field [dict get $node fields] {
                Value $hir A $field flow $ctx
            }
        }
        project {
            Value $hir A [dict get $node receiver] flow $ctx
        }
        handle {
            set inner $ctx
            dict set inner handled [expr {[dict exists $node handlerNames] ? [dict get $node handlerNames] : {}}]
            Value $hir A [dict get $node call] $sink $inner
            foreach body [dict get $node handlerBodies] {
                Seq $hir A $body $sink $ctx
            }
        }
    }
}

# A use (ref expression E) of whatever binding it reads, flowing into SINK.
proc hir::signatures::Use {hir AVar e sink ctx} {
    upvar 1 $AVar A
    set node [dict get $hir exprs $e]
    if {![dict get $node reachable] || [dict get $node binding] eq ""} {
        return
    }
    set root [Root A [dict get $node binding]]
    if {$root eq ""} {
        return
    }
    lassign $root rootKind p
    if {$rootKind eq "param" && [dict exists $ctx tested $p]} {
        return
    }
    switch -- [lindex $sink 0] {
        drop - alias {
        }
        flow {
            if {$rootKind eq "param"} {
                Push A escapes $p [dict create expr $e what "a position this analysis does not follow"]
            }
        }
        pcallarg {
            if {$rootKind eq "param"} {
                Push A escapes $p [dict create expr $e what "an argument of a call through another untyped callable"]
            }
        }
        type {
            lassign $sink _ type kind what
            if {$rootKind eq "ret"} {
                Push A rets $p [dict create type $type expr $e what $what]
                return
            }
            if {![hir::types::IsFn $type]} {
                Push A escapes $p [dict create expr $e what $what]
            }
            if {$type eq "any"} {
                return
            }
            set use [UseFact $hir A $e $p]
            if {$use ne "" && [hir::types::Admits $type $use]} {
                return
            }
            Push A reqs $p [dict create kind $kind type $type expr $e what $what]
        }
        param {
            lassign $sink _ block index what
            if {$rootKind eq "ret"} {
                Push A rets $p [dict create block $block index $index expr $e what $what]
                return
            }
            Push A edges $p [dict create block $block index $index expr $e what $what \
                use [UseFact $hir A $e $p]]
            Push A fnEdges $p [dict create block $block index $index expr $e]
        }
    }
}

# The use-site type of ref E to (an alias of) parameter P when it proves
# something beyond P's own seed -- a flow fact, a refinement -- else "".
proc hir::signatures::UseFact {hir AVar e p} {
    upvar 1 $AVar A
    set t [hir::typeOf $hir $e]
    if {$t eq "any" || $t eq [dict get $A seeds $p]} {
        return ""
    }
    return $t
}

proc hir::signatures::Call {hir AVar e sink ctx} {
    upvar 1 $AVar A
    set node [dict get $hir exprs $e]
    set callee [dict get $node callee]
    set args [dict get $node args]
    set p ""
    if {[dict get $node target] eq "" && [hir::kind $hir $callee] eq "ref"
            && [hir::get $hir $callee reachable] && [hir::get $hir $callee binding] ne ""} {
        set r [Root A [hir::get $hir $callee binding]]
        if {[lindex $r 0] eq "param" && ![dict exists $ctx tested [lindex $r 1]]} {
            set p [lindex $r 1]
        }
    }
    if {$p ne ""} {
        if {[dict get $node reachable]} {
            set admitted [concat [dict get $ctx handled] [BlockErrors $hir [dict get $ctx block]]]
            Push A calls $p [dict create expr $e \
                args [lmap a $args {hir::typeOf $hir $a}] admitted [lsort -unique $admitted]]
            # Where the call's result goes constrains P's return.
            switch -- [lindex $sink 0] {
                type {
                    lassign $sink _ type kind what
                    if {$type ne "any"} {
                        Push A rets $p [dict create type $type expr $e what $what]
                    }
                }
                param {
                    lassign $sink _ block index what
                    Push A rets $p [dict create block $block index $index expr $e what $what]
                }
            }
        }
        set i 0
        foreach arg $args {
            Value $hir A $arg [list pcallarg $p $i] $ctx
            incr i
        }
        return
    }
    Value $hir A $callee drop $ctx
    foreach arg $args sink [ArgSinks $hir $e $node] {
        Value $hir A $arg $sink $ctx
    }
}

# The declared error set of block E ("" for the program).
proc hir::signatures::BlockErrors {hir e} {
    if {$e eq "program"} {
        return {}
    }
    return [dict get $hir exprs $e declaredErrors]
}

# The sink of each argument of call E: its callee's own admissibility
# metadata for that position (see the header's table).
proc hir::signatures::ArgSinks {hir e node} {
    set args [dict get $node args]
    set n [llength $args]
    set flows [lrepeat $n flow]
    lassign [dict get $node target] kind target
    switch -- $kind {
        native {
            set name [dict get [hir::symbol $hir $target] name]
            set meta [core::native::metadata $name]
            if {[dict get $meta arity] ne "*" && [dict get $meta arity] != $n} {
                return $flows
            }
            set sinks {}
            set i 0
            foreach arg $args {
                set t [lindex [dict get $meta paramTypes] $i]
                incr i
                if {$t in {"" any}} {
                    lappend sinks flow
                } else {
                    lappend sinks [list type $t checked "argument $i of native $name"]
                }
            }
            return $sinks
        }
        block {
            set tnode [dict get $hir exprs $target]
            if {[llength [dict get $tnode params]] != $n} {
                return $flows
            }
            set name [Name $hir $target]
            set sinks {}
            set i 0
            foreach d [dict get $tnode declaredParamTypes] {
                set label "argument [expr {$i + 1}] of $name"
                if {$d ne {} && [hir::types::IsTraitConstraint $d]} {
                    # A trait-typed parameter is an explicit boundary
                    # (TRAITS.md): it never makes an untyped parameter
                    # implicitly trait-polymorphic.
                    lappend sinks flow
                } elseif {$d ne {}} {
                    lappend sinks [list type $d trusted "$label (declared [hir::types::show $d])"]
                } else {
                    lappend sinks [list param $target $i $label]
                }
                incr i
            }
            return $sinks
        }
    }
    set calleeType [hir::typeOf $hir [dict get $node callee]]
    if {[hir::types::IsFn $calleeType] && [llength [hir::types::FnArgs $calleeType]] == $n} {
        set sinks {}
        set i 0
        foreach t [hir::types::FnArgs $calleeType] {
            incr i
            if {$t eq "any"} {
                lappend sinks flow
            } else {
                lappend sinks [list type $t trusted "argument $i of a call through [hir::types::show $calleeType]"]
            }
        }
        return $sinks
    }
    return $flows
}

# ---------------------------------------------------------------------------
# Solving

# The meet of two requirement types, or "" if none is representable.
proc hir::signatures::Meet {a b} {
    if {$a eq "any" || $a eq $b} {
        return $b
    }
    if {$b eq "any"} {
        return $a
    }
    if {[hir::types::IsFn $a] && [hir::types::IsFn $b]} {
        return [hir::types::FnGlb $a $b]
    }
    if {[hir::types::IsMutArray $a] && $b eq "mutarray"} {
        # A native's `mutarray` parameter requirement is a kind test, which
        # any MutableArray[T] satisfies; every use that could write is
        # verified against the value's real type at its own call
        # (hir::range::VerifyCall, hir::containers), so the applied contract
        # is the meet.
        return $a
    }
    if {[hir::types::IsMutArray $b] && $a eq "mutarray"} {
        return $b
    }
    return [hir::types::glb $a $b]
}

# 1 if TYPE is concrete enough to be a callable parameter's argument type
# (see the header's "Callable parameters"): known, and not a relational
# placeholder -- no `any`, no bare aggregate kind (an element type `any`),
# no callable (which also keeps inferred Fn types first-order: finite).
proc hir::signatures::Concrete {type} {
    if {$type in {any never list immutableSet mutarray block native}} {
        return 0
    }
    if {[hir::types::IsList $type] || [hir::types::IsSet $type]} {
        if {[llength $type] != 2} {
            return 0
        }
        return [Concrete [lindex $type 1]]
    }
    if {[hir::types::IsSpecific $type]} {
        return 0
    }
    return 1
}

# The current contract of parameter slot BLOCK/INDEX: {trusted T checked C}.
proc hir::signatures::SlotContract {AVar contracts block index} {
    upvar 1 $AVar A
    if {![dict exists $A slots [list $block $index]]} {
        return {trusted any checked any}
    }
    set p [dict get $A slots [list $block $index]]
    return [dict get $contracts $p]
}

# Solves the requirements A collected: param -> contract dict
#
#   trusted   the meet of its trusted requirements (any: none)
#   checked   the meet of all its requirements (any: none)
#   why       the requirement records that contributed, in order
#   conflict  "" or {first REC second REC}: two requirements with no meet
#   note      "" or why no callable contract was inferred
#
# A callable parameter passed on to another untyped parameter (an fnEdge)
# does not escape if that parameter ends up with a function contract
# itself. That is decided optimistically -- every parameter starts as a
# callable candidate, so mutually recursive higher-order functions can
# infer each other's contracts -- and then retracted: a candidate passing
# its value to a parameter that did not end up with a function contract
# really escapes, and the solve is repeated without it. Candidates only
# shrink, so this terminates.
proc hir::signatures::Solve {hir A} {
    set params [lsort -dictionary [dict keys [dict get $A params]]]
    dict set A candidates [dict create]
    foreach p $params {
        dict set A candidates $p 1
    }
    while 1 {
        set contracts [SolveWith $hir A $params]
        set bad {}
        dict for {p edges} [dict get $A fnEdges] {
            if {![dict exists $A candidates $p]} {
                continue
            }
            foreach edge $edges {
                set target [SlotContract A $contracts [dict get $edge block] [dict get $edge index]]
                if {![hir::types::IsFn [dict get $target trusted]]} {
                    lappend bad $p
                    break
                }
            }
        }
        if {$bad eq {}} {
            return $contracts
        }
        foreach p $bad {
            dict unset A candidates $p
        }
    }
}

proc hir::signatures::SolveWith {hir AVar params} {
    upvar 1 $AVar A
    variable maxSweeps
    set contracts [dict create]
    foreach p $params {
        dict set contracts $p [dict create trusted any checked any why {} conflict {} note {}]
    }
    for {set sweep 1} {$sweep <= $maxSweeps} {incr sweep} {
        set changed 0
        foreach p $params {
            set new [Contract $hir A $contracts $p]
            if {$new ne [dict get $contracts $p]} {
                dict set contracts $p $new
                set changed 1
            }
        }
        if {!$changed} {
            return $contracts
        }
    }
    error "hir::signatures::Solve: requirements did not converge"
}

# Parameter P's contract given the current CONTRACTS of every other one.
proc hir::signatures::Contract {hir AVar contracts p} {
    upvar 1 $AVar A
    set state [dict create trusted any checked any why {} conflict {} note {} seen {}]
    if {[dict exists $A reqs $p]} {
        foreach req [dict get $A reqs $p] {
            Add state [dict get $req kind] [dict get $req type] $req
        }
    }
    if {[dict exists $A edges $p]} {
        foreach edge [dict get $A edges $p] {
            set target [SlotContract A $contracts [dict get $edge block] [dict get $edge index]]
            set use [dict get $edge use]
            set full [dict get $target checked]
            if {$full eq "any" || ($use ne "" && [hir::types::Admits $full $use])} {
                continue
            }
            set trusted [dict get $target trusted]
            if {$trusted ne "any"} {
                Add state trusted $trusted [dict replace $edge kind trusted type $trusted \
                    what "[dict get $edge what] (inferred)"]
            }
            if {$full ne $trusted} {
                Add state checked $full [dict replace $edge kind checked type $full \
                    what "[dict get $edge what] (inferred)"]
            }
        }
    }
    set fn [CallableContract $hir A $contracts $p]
    lassign $fn fnKind fnValue fnDetail
    switch -- $fnKind {
        fn {
            Add state trusted $fnValue [dict create kind trusted type $fnValue \
                expr [dict get [lindex [dict get $A calls $p] 0] expr] \
                what "calling it as a function ($fnDetail)"]
        }
        conflict {
            if {[dict get $state conflict] eq ""} {
                dict set state conflict $fnValue
            }
        }
        note {
            dict set state note $fnValue
        }
    }
    dict unset state seen
    if {[dict get $state conflict] ne ""} {
        # Reported once (Diagnose); for propagation the parameter is
        # unconstrained, so no second, derived error cascades from it.
        dict set state trusted any
        dict set state checked any
    }
    return $state
}

# Meets requirement REC (of KIND, type TYPE) into STATE.
proc hir::signatures::Add {stateVar kind type rec} {
    upvar 1 $stateVar state
    if {[dict get $state conflict] ne ""} {
        return
    }
    set rec [dict replace $rec kind $kind type $type]
    set keys {checked}
    if {$kind eq "trusted"} {
        set keys {trusted checked}
    }
    foreach key $keys {
        set m [Meet [dict get $state $key] $type]
        if {$m eq ""} {
            # Name the earlier requirement it conflicts with.
            set other ""
            foreach prior [dict get $state seen] {
                if {[Meet [dict get $prior type] $type] eq ""} {
                    set other $prior
                    break
                }
            }
            if {$other eq ""} {
                set other [lindex [dict get $state seen] end]
            }
            dict set state conflict [dict create first $other second $rec]
            return
        }
        dict set state $key $m
    }
    dict lappend state seen $rec
    dict lappend state why [dict create kind $kind type $type \
        expr [dict get $rec expr] what [dict get $rec what]]
}

# P's callable contract: {fn TYPE}, {conflict {first .. second ..}},
# {note TEXT} (a call exists but no contract is representable), or {}.
proc hir::signatures::CallableContract {hir AVar contracts p} {
    upvar 1 $AVar A
    if {![dict exists $A calls $p]} {
        return {}
    }
    set calls [dict get $A calls $p]
    if {[dict exists $A escapes $p]} {
        set esc [lindex [dict get $A escapes $p] 0]
        return [list note [list escapes [dict get $esc expr] [dict get $esc what]]]
    }
    set arity [llength [dict get [lindex $calls 0] args]]
    set args [lrepeat $arity never]
    set admitted [dict get [lindex $calls 0] admitted]
    foreach call $calls {
        if {[llength [dict get $call args]] != $arity} {
            return [list note [list arity [dict get $call expr] \
                "called with $arity and with [llength [dict get $call args]] argument(s)"]]
        }
        set args [lmap a $args t [dict get $call args] {hir::types::lub $a $t}]
        set kept {}
        foreach x $admitted {
            if {$x in [dict get $call admitted]} {
                lappend kept $x
            }
        }
        set admitted $kept
    }
    foreach a $args call [lrepeat $arity [lindex $calls 0]] {
        if {![Concrete $a]} {
            return [list note [list relational [dict get $call expr] \
                "an argument of type [hir::types::show $a] (its concrete type depends on callers: a type variable)"]]
        }
    }
    if {[dict exists $A fnEdges $p] && ![dict exists $A candidates $p]} {
        set edge [lindex [dict get $A fnEdges $p] 0]
        return [list note [list escapes [dict get $edge expr] \
            "an argument of [Name $hir [dict get $edge block]] whose parameter has no function-type contract"]]
    }
    set result any
    set seenRet {}
    if {[dict exists $A rets $p]} {
        foreach ret [dict get $A rets $p] {
            if {[dict exists $ret block]} {
                set type [dict get [SlotContract A $contracts [dict get $ret block] [dict get $ret index]] checked]
                set ret [dict replace $ret type $type what "[dict get $ret what] (inferred)"]
            } else {
                set type [dict get $ret type]
            }
            if {$type eq "any"} {
                continue
            }
            set m [Meet $result $type]
            if {$m eq ""} {
                set other [lindex $seenRet end]
                foreach prior $seenRet {
                    if {[Meet [dict get $prior type] $type] eq ""} {
                        set other $prior
                        break
                    }
                }
                return [list conflict [dict create first [dict replace $other what "the result of a call of it: [dict get $other what]"] \
                    second [dict replace $ret kind trusted what "the result of a call of it: [dict get $ret what]"]]]
            }
            set result $m
            lappend seenRet [dict replace $ret kind trusted type $type]
        }
    }
    # Which body expressions produced each part (spec item 46's audit).
    set parts {}
    foreach call $calls {
        set where [Where $hir [dict get $call expr]]
        set node [dict get $hir exprs [dict get $call expr]]
        set i 0
        set shown {}
        foreach arg [dict get $node args] t [dict get $call args] {
            incr i
            lappend shown "arg $i [hir::types::show $t] ([Where $hir $arg])"
        }
        lappend parts "call at $where passes [expr {$shown eq {} ? "nothing" : [join $shown {, }]}]"
    }
    lappend parts [expr {$seenRet eq {} ? "its result is unconstrained (return any)"
        : "its result is required by [join [lmap r $seenRet {Describe $hir $r}] {; }]"}]
    lappend parts "its call sites admit errors \[[join $admitted {, }]\]"
    return [list fn [hir::types::MakeFn $args $result $admitted] [join $parts {; }]]
}

# ---------------------------------------------------------------------------
# Diagnostics

# "LINE:COLUMN" of expression E's source origin, else its ExprId.
proc hir::signatures::Where {hir e} {
    if {[llength $e] != 1 || ![dict exists $hir exprs $e]} {
        return ""
    }
    set origin [dict get $hir exprs $e origin]
    if {[lindex $origin 0] eq "file"} {
        set fields [lrange $origin 2 end]
        if {[dict exists $fields line]} {
            return "[dict get $fields line]:[dict get $fields column]"
        }
    }
    return $e
}

# One requirement record as text: "argument 1 of native length requires
# str (at 4:5)".
proc hir::signatures::Describe {hir rec} {
    set where [Where $hir [dict get $rec expr]]
    return "[dict get $rec what] requires [hir::types::show [dict get $rec type]][expr {$where eq "" ? "" : " (at $where)"}]"
}

# The provenance of parameter PARAM (an `of` params entry) as text lines.
proc hir::signatures::explain {hir param} {
    return [lmap rec [dict get $param why] {
        format {%s: %s} [dict get $rec kind] [Describe $hir $rec]
    }]
}

proc hir::signatures::Diagnose {hirVar A solution} {
    upvar 1 $hirVar hir
    dict for {p contract} $solution {
        set conflict [dict get $contract conflict]
        if {$conflict eq ""} {
            continue
        }
        set first [dict get $conflict first]
        set second [dict get $conflict second]
        set block [dict get $A params $p block]
        set at [dict get $second expr]
        if {[llength $at] != 1} {
            set at $block
        }
        hir::Diagnose hir TYPE [format \
            {cannot infer a sound type for parameter "%s" of %s: %s, but %s, and no type satisfies both} \
            [dict get $hir bindings $p name] [Name $hir $block] \
            [Describe $hir $first] [Describe $hir $second]] $at
    }
}

# Text for hir::range::VerifyCall's diagnostics: why parameter I of block E
# has its inferred contract.
proc hir::signatures::because {hir e i} {
    set node [dict get $hir exprs $e]
    if {![dict exists $node paramRequirements]} {
        return ""
    }
    set why [lindex [dict get $node paramRequirements] $i]
    if {$why eq {}} {
        return ""
    }
    return "; inferred from the function body: [join [lmap rec $why {Describe $hir $rec}] {; }]"
}
