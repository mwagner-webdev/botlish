# completions.tcl -- call-specific completion proof: for an exact call under
# concrete argument facts, what can actually happen (STATIC-COMPLETION-
# PROOFS.md).
#
#   effectiveErrors(call) = declaredErrors(callee) - errors proven
#                            impossible for this call, under the facts
#                            reachable at this call site
#   mayReturnNormally(call) = is a normal completion still possible
#
# This is a genuinely separate, focused proof pass from hir/range.tcl's own
# interprocedural Range fixpoint (hir::range::analyze), deliberately: that
# fixpoint feeds native/lower.tcl's raw-representation eligibility decisions
# (an unrelated, codegen-facing concern with its own golden-file assembly
# audits -- SCALAR-ASM-AUDIT.md), and this milestone must not let a semantic
# analysis change generated code (item 60-61 of the milestone brief). Rather
# than risk that blast radius by teaching hir::range.tcl's shared `If`/
# `Expr`/`AnalyzeInstance` new branch-pruning precision, this file is its own
# small, local (never interprocedural), non-codegen-facing walker -- but it
# is NOT a second independent abstract interpreter built from scratch: every
# numeric fact it computes reuses hir::range.tcl's own pure Range lattice
# operations directly (join, intersect, ComparisonNarrowing, Narrowed,
# RefBinding, BindingRange, TypeFact/ConstrainType, add/sub/mul/BitOp,
# ExactOf, point, unknown, JoinBindings) -- see each proc below for exactly
# which one it calls. What this file adds on top, that hir::range.tcl
# deliberately does not need for its own purpose, is: (a) treating a
# narrowed branch fact that becomes an empty interval as a *provably
# infeasible* branch, pruned
# entirely rather than merely computed and joined (general branch
# feasibility, not just the existing purely-syntactic hir::types::
# KnownOutcome); and (b) tracking *which* declared error names are reachable
# through a `fail`, not just that the branch never completes normally.
#
# The one thing code generation does take from this pass is a native call's
# per-check bounds verdict (BoundsVerdictsOf/BoundsProven, PROOF-FACT-
# REPAIRS.md): a check proven never to fail needs no runtime check. It is a
# retained *result* of the legality proof, never a second proof engine in
# lowering, and legality itself still never reads closed-world facts.
#
# Two entry points:
#   hir::completions::checkBlock hirVar block enclosingErrors
#       -- the once-per-function-body legality driver (hir/errorsets.tcl's
#          own "blocks" loop calls this once per block, plus once for the
#          program root), diagnosing UNHANDLED-ERROR/KNOWN-ERROR/TYPE
#          directly into hir as it walks.
#   hir::completions::analyzeBlock hir block argRanges guard
#       -- pure fact computation, no diagnosis: what a call to BLOCK, under
#          concrete per-parameter Range facts ARGRANGES, may complete with.
#          Used both recursively (a fallible call nested inside the body
#          currently being checked, item 33) and by hir/errorsets.tcl for a
#          `handle`d call's own effective set.
#
# Scope (item 16): only an exact, directly-known callee (`target {block
# ExprId}`) is ever analyzed this way -- exactly the same restriction
# hir/range.tcl's own closed-call machinery already has, and for the same
# reason (hir/callables.tcl's Bearing check already forbids an error-bearing
# or typed-parameter-bearing function from escaping to an opaque callable
# value, so a callee reached through unknown dynamic dispatch never legally
# carries error obligations here to begin with). A call through a
# *structural function type* (STRUCTURAL-FUNCTION-TYPES.md) -- a callable
# whose target is unknown but whose contract is -- is not analyzed that way
# either (there is no one body to analyze), but is charged its contract's
# whole declared error set (CheckStructuralCallLegality): the contract is
# the upper bound every implementation reaching it was proven to fit.
#
# Precision and the erased-callable contract
# ------------------------------------------
# Failure to prove an error absent never becomes proof that it is absent.
# Two kinds of precision are kept apart (STATIC-COMPLETION-PROOFS.md,
# "Verified callable contract boundary"):
#
#   identity precision   which callable a value is (an exact block or
#                        native: its body can be analyzed under the call's
#                        facts)
#   contract precision   which callable contract it is proven to satisfy
#                        (a structural Fn or Coroutine type: a bound on what
#                        any call through it raises)
#
# Losing identity does not lose the contract. A value whose static type is
# a structural Fn has been checked against that type wherever it acquired
# it (the subsumption check below), so a call through it raises at most its
# contract's declared errors, whatever callable it holds and whatever the
# call passes it. An exact callable fact may narrow that bound
# (IndirectFacts), never widen it.
#
# The one way an error can leave a function that declares neither it nor a
# contract admitting it is a call through an *uncontracted* value (static
# type any or a bare kind) the walk cannot see through: a callable that
# reached an untyped parameter -- through a semantic instance (hir/
# semantic.tcl; the only erasure hir/callables.tcl accepts), or through a
# structural call whose callee is a function with that parameter untyped
# (contravariant erasure, ErasedErrors) -- called there as `f(x)`, or a
# closure that captured one and is called later. The walk tracks where each
# callable value comes from (CallableFact):
#
#   {block B} / {native N}  exactly that callable (an argument of exact
#                           type): the call is analyzed as an exact call of
#                           it -- its effective errors, never a must-fact
#   {contract ERRORS ARGS}  identity unknown, contract known: a value of
#                           structural Fn type (its static type, or the one
#                           it had where it was passed into an untyped
#                           parameter): a call raises at most ERRORS --
#                           through an uncontracted call, also what an
#                           argument carries where ARGS types it with a
#                           contract nothing checked (ContractChannel)
#   clean                   a parameter or capture of uncontracted type of
#                           the body being checked: whatever an erased
#                           argument carries is charged at the call that
#                           passed it (it reaches this body only through
#                           that call's analysis); a closure the walk saw
#                           created in the same activation sees its
#                           captures' facts
#   unknown                 anything else: identity and contract both lost,
#                           so the call may be any callable the program
#                           erases; it is charged the program's
#                           erased-callable contract (ErasedErrors: every
#                           declared error of every callable the program
#                           passes into an untyped parameter) and the walk
#                           becomes *incomplete*
#
# An incomplete summary falls back to the callee's declared contract at the
# function-instance boundary (EffectiveFacts): exact narrowing is kept only
# while the whole walk is complete, and incompleteness propagates to every
# enclosing summary. A call bounded by a contract never makes the walk
# incomplete: the contract is a proof boundary. A fallback is a may-set: it
# never turns a call into a known failure (`normal` is what the walk proved,
# and the fallbacks never lower it). A program that erases no error-bearing
# callable has an empty erased-callable contract, and nothing here changes
# its analysis.
#
# The verified contract boundary
# ------------------------------
# Trusting a structural contract is sound only because every value that
# acquires one was checked against it. The type checker proves an exact
# callable's *declared* errors fit (hir::types::subtype); what its type does
# not show -- what it raises through an uncontracted callable it captured
# or receives as an argument -- is checked here, at every position where a
# value of exact callable type (or of another Fn type) acquires a structural
# Fn type (Subsume: the positions hir/callables.tcl audits, plus yields): its
# body is analyzed under the facts of that position and every parameter the
# contract types, and an error outside the contract is a TYPE error. The
# check runs in each body's own check (checkBlock), where a clean input
# stands for every value it can hold (Possible), so it holds for every
# activation, however the body is later reached.

namespace eval hir::completions {
    # Recursive nested-call analysis budget (item 35/108-16): once one walk
    # has started this many distinct exact-callee analyses, every further
    # call it makes falls back conservatively to its callee's own declared
    # errors and ordinary (normal-completion-possible) outcome -- never a
    # claim of impossibility the budget did not actually verify. Each
    # nested analysis walks with a count of its own (NewCtx), so this bounds
    # how wide the analyses of one walk get; maxDepth below bounds how deep
    # they nest. Generous enough for every corpus shape (std::byte::set's own
    # single-level from_int nesting, a handful of calls per literal-list
    # element).
    variable maxAnalyses 256
    # Nesting bound (COMPILER-BOTTLENECKS.md, 4.4): an exact call analyzed
    # while this many blocks are being analyzed around it (the size of
    # EffectiveFacts's `guard`) falls back to its callee's declared contract,
    # as a recursion cycle does. The per-walk budget above bounds the
    # analyses one walk starts, not how deep they nest: a static call chain
    # f1 -> f2 -> ... nests one analysis per call, six to nine Tcl
    # evaluation levels each (more in a body that nests deeper), so without
    # this a long enough chain exceeded any Tcl recursion limit (a
    # 120-function chain at Tcl's default of 1000). With it the walk is at
    # most this deep, which the recursion floor the front end runs under
    # (hir::Deep, 100000) leaves room for at up to about 90 levels per
    # analysis. A chain deeper than this keeps every proof up to the bound
    # and loses only what the calls past it would have proven: the fallback
    # never claims an error impossible, but a caller whose call needed no
    # handler only because of such a proof then needs one. A count of
    # analyses, never of Tcl frames, so the verdicts do not depend on how
    # deep the compiler was entered or on the process's recursion limit.
    # No corpus program comes near it (the deepest nests 12).
    variable maxDepth 1024
    # Memoization for analyzeBlock's own results, {target argRanges argExact
    # argExactLists} -> {normal errors result}, valid for one whole-program
    # errorsets::verify pass (hir::completions::resetCache clears it at that
    # pass's own start -- HIR content is read-only for the pass's entire
    # duration, so nothing here can go stale mid-pass). This is a plain
    # performance fix, not a semantic one (item 101 -- generated-code/
    # runtime performance is explicitly out of scope, but a compile pass
    # that is not practically usable is a real defect this milestone still
    # has to avoid): without it, a program with many ordinary call sites
    # sharing the same (unconstrained) argument facts -- the overwhelmingly
    # common case -- re-walks the same callee body from scratch at every
    # one of them, compounding multiplicatively with program size. Sound
    # regardless of the two different `guard` chains a cache hit and its
    # original computation may have run under: `guard` only ever makes a
    # sub-computation MORE conservative (a cycle/budget fallback widens
    # toward the callee's full declared contract, never narrows), so
    # reusing a result computed under a stricter guard is always at least
    # as sound as reusing one computed under a looser one -- this can only
    # ever cost precision, never introduce a false claim of impossibility
    # (item 82's soundness rule). A target already in the CURRENT guard is
    # never even offered to the cache (EffectiveFacts checks that first),
    # so a genuine cycle is never short-circuited by a stale hit either.
    variable cache [dict create]
    # The erased-callable contract of the program this pass checks
    # (ErasedErrors), its static facts (Statics: the transparent blocks and
    # the contravariant erasures), the outward types every yield sends into
    # (YieldFinals) and the possible errors of its uncontracted bindings
    # (Possible): computed on first use, cleared with the cache.
    variable erased ""
    variable erasedKnown 0
    variable statics ""
    variable yieldFinals ""
    variable yieldFinalsKnown 0
    variable possible ""
    variable possibleKnown 0
    # The contract-boundary violations this pass has reported (Subsume), so
    # a position walked more than once (a literal List's loop body, once
    # per element) is reported once.
    variable reported [dict create]
}

proc hir::completions::resetCache {} {
    variable cache
    variable erasedKnown
    variable statics
    variable yieldFinalsKnown
    variable possibleKnown
    variable reported
    set cache [dict create]
    set erasedKnown 0
    set statics ""
    set yieldFinalsKnown 0
    set possibleKnown 0
    set reported [dict create]
    hir::cardinality::resetCache
}

# ---------------------------------------------------------------------------
# Callable facts and the erased-callable contract (header, "Precision and the
# erased-callable contract")

# The erased-callable contract of HIR (erasedErrorsOf), for this pass.
proc hir::completions::ErasedErrors {hir} {
    variable erased
    variable erasedKnown
    if {!$erasedKnown} {
        set erased [lsort -unique [concat [InstanceErasures $hir] [dict get [Statics $hir] contravariant]]]
        set erasedKnown 1
    }
    return $erased
}

# The erased-callable contract of HIR, computed afresh (for a pass other
# than this file's: hir/static.tcl): every declared error a callable the
# program passes into an untyped parameter can raise. A value reaches an
# untyped parameter in exactly two ways:
#
#   a semantic instance    an exact call of a function with that parameter
#                          untyped (hir/semantic.tcl: the instance's entry
#                          type at a parameter without a declared or trusted
#                          contract is the argument's own type) -- the one
#                          erasure hir/callables.tcl accepts at a call
#   contravariant erasure  a structural call through a Fn type that a
#                          callable with that parameter untyped was given:
#                          the Fn's argument type admits whatever it types,
#                          and the callable's parameter forgets it
#                          (Contravariant)
#
# and what each value carries is hir::callables::CarriedErrors of its type.
# An uncontracted call whose callee this walk cannot identify can only be
# one of those values, or a closure whose own uncontracted calls reach one
# of them: this set bounds what it raises.
proc hir::completions::erasedErrorsOf {hir} {
    return [lsort -unique [concat [InstanceErasures $hir] [dict get [staticsOf $hir] contravariant]]]
}

# {ERASED TRANSPARENT}: erasedErrorsOf and transparentBlocks of HIR, from one
# static walk (hir/affine.tcl's error edges).
proc hir::completions::erasureFacts {hir} {
    set statics [staticsOf $hir]
    set erased [lsort -unique [concat [InstanceErasures $hir] [dict get $statics contravariant]]]
    return [list $erased [dict get $statics transparent]]
}

# What the semantic instances of HIR erase into untyped parameters
# (erasedErrorsOf).
proc hir::completions::InstanceErasures {hir} {
    set errors {}
    if {[dict exists $hir semantic instances]} {
        dict for {id inst} [dict get $hir semantic instances] {
            set block [dict get $inst block]
            if {![dict exists $hir exprs $block]} {
                continue
            }
            foreach contract [hir::signatures::entryTypes $hir $block] type [dict get $inst args] {
                if {$contract eq ""} {
                    lappend errors {*}[hir::callables::CarriedErrors $hir $type]
                }
            }
        }
    }
    return [lsort -unique $errors]
}

# 1 if a value of static TYPE may be a callable this walk cannot identify
# from TYPE alone: `any`, a bare block or native kind, or a structural Fn
# (whose value may be a closure). An exact callable type identifies its
# value; a coroutine handle's resume is bounded by its contract (its thunk
# is checked against it); any other type is not callable at all.
proc hir::completions::MayHoldCallable {type} {
    if {$type eq "never" || [hir::types::IsCoroutine $type]} {
        return 0
    }
    return [expr {[hir::types::kindOf $type] in {"" block native}}]
}

# 1 if a value of static TYPE may be a callable that neither an identity nor
# a contract bounds: `any` or a bare kind -- not an exact callable, a
# structural Fn (its contract bounds every call, header) or a coroutine
# handle.
proc hir::completions::Uncontracted {type} {
    return [expr {[MayHoldCallable $type] && ![hir::types::IsFn $type]
        && ![hir::types::IsExactBlock $type] && ![hir::types::IsExactNative $type]}]
}

# The callable fact a value of static TYPE has when the walk recorded none
# for it (header): {block B} / {native N} for an exact callable, {contract
# ERRORS ARGS} for a structural Fn (identity unknown, contract known: its
# errors and argument types), unknown for any other value that may be a
# callable, clean for one that cannot be.
proc hir::completions::TypeFact {type} {
    if {[hir::types::IsExactBlock $type]} {
        return [list block [lindex $type 1]]
    }
    if {[hir::types::IsExactNative $type]} {
        return [list native [lindex $type 1]]
    }
    if {[hir::types::IsFn $type]} {
        return [ContractFact $type]
    }
    return [expr {[MayHoldCallable $type] ? "unknown" : "clean"}]
}

# The callable fact {contract ERRORS ARGS} of a value of structural callable
# TYPE (a Fn, or a coroutine handle's contract).
proc hir::completions::ContractFact {type} {
    set contract [hir::types::Contract $type]
    return [list contract [dict get $contract errors] [dict get $contract args]]
}

# 1 if a callable whose callable fact is {contract ERRORS ARGS} may, called
# through an uncontracted value -- where nothing checks the arguments'
# effects against ARGS -- raise what an argument carries beyond ERRORS: when
# its argument types are unknown (ARGS `*`) or one of them is itself a
# structural contract, whose implementation trusts that contract for a
# value nobody checked against it. An uncontracted argument position never
# lets one through: a value of the contract's type was checked to raise only
# ERRORS whatever such an argument holds (SubsumedRaises).
proc hir::completions::ContractChannel {args_} {
    if {$args_ eq "*"} {
        return 1
    }
    foreach t $args_ {
        if {[hir::types::IsFn $t] || [hir::types::IsCoroutine $t]} {
            return 1
        }
    }
    return 0
}

# The callable fact of expression E's value (header): {block B} or {native N}
# when its static type is that exact callable, else the fact this walk
# recorded for the binding a `ref` reads (a parameter seeded from its
# argument, a local from its value, a checked body's uncontracted parameters
# and captures `clean`), else its static type's (TypeFact).
proc hir::completions::CallableFact {hir ctx e} {
    set type [hir::typeOf $hir $e]
    if {[hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type]} {
        return [TypeFact $type]
    }
    if {[hir::kind $hir $e] eq "ref"} {
        set b [hir::get $hir $e binding]
        if {$b ne "" && [dict exists $ctx callables $b]} {
            return [dict get $ctx callables $b]
        }
    }
    return [TypeFact $type]
}

# The callable facts of ARGEXPRS, one per argument, for the parameters of the
# callee they are passed to -- or {} when the program erases no error-bearing
# callable (no fact can matter then; keeping the cache key unchanged).
proc hir::completions::ArgCallables {hir ctx argExprs} {
    if {[ErasedErrors $hir] eq {}} {
        return {}
    }
    return [lmap a $argExprs {CallableFact $hir $ctx $a}]
}

# 1 if the root native NAME calls a callable argument (-errors-from) in a
# program that erases an error-bearing callable: what it raises then depends
# on that argument's callable fact (NativeCallFacts).
proc hir::completions::CallsCallable {hir name} {
    return [expr {[ErasedErrors $hir] ne {} && [dict get [core::native::metadata $name] errorsFrom] ne ""}]
}

# The callable fact of binding B in CTX: by B's type when it is an exact
# callable, else the one recorded, else by B's type (CallableFact's rule for
# a `ref`).
proc hir::completions::BindingFact {hir ctx b} {
    set type [hir::bindingType $hir $b]
    if {[hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type]} {
        return [TypeFact $type]
    }
    if {[dict exists $ctx callables $b]} {
        return [dict get $ctx callables $b]
    }
    return [TypeFact $type]
}

# 1 if binding B is one a body's own check takes as `clean` (SeedClean): a
# parameter or capture of uncontracted recorded type (Uncontracted). One
# whose recorded type is a structural Fn is not: its contract bounds every
# call through it, wherever the body passes it (TypeFact's {contract
# ERRORS}). A declared parameter's binding records no type (its declared
# type is the block's signature), so it is clean here whatever it declares:
# a call through it is still charged its contract (the callee expression's
# type), and what it carries where the body passes it on is charged where
# the function is called, by the argument's fact there (a contract's for a
# value only its Fn type bounds: Carried, Fallback).
proc hir::completions::CleanInput {hir b} {
    return [Uncontracted [hir::bindingType $hir $b]]
}

# The callable facts of the captures of closure TARGET, a dict binding ->
# fact, when call CALLEE (the callee expression) calls the closure this
# activation created (a `ref` to the local CTX recorded it in): its captures
# are this walk's own bindings. {} otherwise -- a closure from elsewhere
# (another activation's) has captures this walk knows nothing about.
proc hir::completions::CaptureFacts {hir ctx callee target} {
    if {[ErasedErrors $hir] eq {} || ![CreatedHere $hir $ctx $callee $target]} {
        return {}
    }
    set facts [dict create]
    foreach c [hir::get $hir $target captures] {
        dict set facts $c [BindingFact $hir $ctx $c]
    }
    return $facts
}

# 1 if expression E is closure TARGET as this activation created it: the
# block expression itself, or a `ref` to the local CTX recorded it in.
proc hir::completions::CreatedHere {hir ctx e target} {
    switch -- [hir::kind $hir $e] {
        block { return [expr {$e eq $target}] }
        ref {
            set b [hir::get $hir $e binding]
            return [expr {$b ne "" && [dict exists $ctx closures $b] && [dict get $ctx closures $b] eq $target}]
        }
    }
    return 0
}

# 1 if an activation of block B may complete with a declared error B does
# not declare itself: B's own body (not the bodies of the closures it
# creates) makes a call through an uncontracted value (CallOpacity), or
# calls a native that calls a callable argument no contract bounds
# (-errors-from) -- or makes an exact call of a transparent block.
# Everything else B's activation raises is a `fail` of B (which B must
# declare), an exact call checkBlock holds to B's declared errors, or a call
# a contract bounds (checked the same way).
# Static (no facts), so it can answer for a call the walk does not enter: a
# recursion cycle, an exhausted budget, an arity mismatch (Fallback). One
# least fixpoint over the program's exact call edges, per pass (Statics).
proc hir::completions::Transparent {hir b} {
    return [dict exists [dict get [Statics $hir] transparent] $b]
}

# 1 if call E of HIR may complete with an error its type-level calleeErrors
# do not name (hir/types.tcl's Call): an exact call of a block in TRANSPARENT
# (transparentBlocks), a call through an uncontracted callee, a native
# calling a callable argument no contract bounds -- the calls the
# erased-callable contract reaches. A call through a structural Fn never
# is: its contract bounds it (the verified contract boundary, header). For
# hir/affine.tcl's error edges, which use the type-level errors and this,
# never the completion proofs.
proc hir::completions::mayLetErasedThrough {hir e transparent} {
    set node [dict get $hir exprs $e]
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "block"} {
        return [dict exists $transparent $target]
    }
    set how [CallOpacity $hir $node]
    switch -- [lindex $how 0] {
        opaque { return 1 }
        edge { return [dict exists $transparent [lindex $how 1]] }
    }
    return 0
}

# The transparent blocks of HIR (Transparent), as a dict BLOCK -> 1.
proc hir::completions::transparentBlocks {hir} {
    return [dict get [staticsOf $hir] transparent]
}

# What call NODE (not an exact call of a block) does to transparency: opaque
# (it may let an error through that no declaration names), {edge B} (it may
# call block B, whose own transparency it then shares) or none.
proc hir::completions::CallOpacity {hir node} {
    lassign [dict get $node target] targetKind target
    set args [dict get $node args]
    if {$targetKind eq "native"} {
        set from [dict get [core::native::metadata [dict get [hir::symbol $hir $target] name]] errorsFrom]
        if {$from eq "" || $from >= [llength $args]} {
            return none
        }
        # A native calling a callable argument (std::mutable_array::generate's
        # factory): bounded by its contract or identity, else opaque.
        set type [hir::typeOf $hir [lindex $args $from]]
        if {[hir::types::IsExactBlock $type]} {
            return [list edge [lindex $type 1]]
        }
        return [expr {[Uncontracted $type] ? "opaque" : "none"}]
    }
    set calleeType [hir::typeOf $hir [dict get $node callee]]
    if {[hir::types::IsExactBlock $calleeType]} {
        return [list edge [lindex $calleeType 1]]
    }
    return [expr {[Uncontracted $calleeType] ? "opaque" : "none"}]
}

# ---------------------------------------------------------------------------
# Static facts: transparency and contravariant erasure

# staticsOf HIR, for this pass.
proc hir::completions::Statics {hir} {
    variable statics
    if {$statics eq ""} {
        set statics [staticsOf $hir]
    }
    return $statics
}

# The static facts of HIR, from one walk of every body (never descending
# into a nested function's, which has its own entry): a dict
#
#   transparent    BLOCK -> 1 for every transparent block (Transparent): the
#                  blocks whose own body makes an opaque call (CallOpacity),
#                  closed over the program's exact call edges
#   contravariant  what the program's contravariant erasures carry
#                  (erasedErrorsOf): at every position where a callable
#                  acquires a structural Fn type (Align), what each argument
#                  type of the Fn carries when the callable leaves that
#                  parameter untyped (Contravariant)
proc hir::completions::staticsOf {hir} {
    # A value acquires a structural Fn type only where one is some
    # expression's type: without one, no position does (Positions is the
    # costly part of the walk).
    set sites [HasFnTypes $hir]
    if {$sites} {
        set finals [YieldFinalsOf $hir]
    } else {
        set finals {}
    }
    set callers [dict create]
    set transparent [dict create]
    set contravariant {}
    set work {}
    set bodies [list program [hir::roots $hir]]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "block"} {
            lappend bodies $e [dict get $node body]
        }
    }
    foreach {b body} $bodies {
        set opaque 0
        foreach child $body {
            StaticWalk $hir $b $child $sites $finals callers opaque contravariant
        }
        if {$b ne "program"} {
            if {$sites} {
                StaticSite $hir [lindex $body end] [ResultFinal $hir $b] contravariant
            }
            if {$opaque} {
                dict set transparent $b 1
                lappend work $b
            }
        }
    }
    while {$work ne {}} {
        set b [lindex $work 0]
        set work [lrange $work 1 end]
        if {![dict exists $callers $b]} {
            continue
        }
        foreach caller [dict get $callers $b] {
            if {![dict exists $transparent $caller]} {
                dict set transparent $caller 1
                lappend work $caller
            }
        }
    }
    return [dict create transparent $transparent contravariant [lsort -unique $contravariant]]
}

# Records, for body B, the exact call edges of expression E (in CALLERSVAR:
# callee -> {caller ...}), sets OPAQUEVAR when E makes an opaque call
# (CallOpacity), and adds to CONTRAVAR what every position of E where a
# callable acquires a structural Fn type erases (StaticSite); never enters a
# nested block's body.
proc hir::completions::StaticWalk {hir b e sites finals callersVar opaqueVar contraVar} {
    upvar 1 $callersVar callers $opaqueVar opaque $contraVar contravariant
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        block { return }
        call {
            lassign [dict get $node target] targetKind target
            if {$targetKind eq "block"} {
                if {$b ne "program"} {
                    dict lappend callers $target $b
                }
            } else {
                set how [CallOpacity $hir $node]
                if {$how eq "opaque"} {
                    set opaque 1
                } elseif {[lindex $how 0] eq "edge" && $b ne "program"} {
                    dict lappend callers [lindex $how 1] $b
                }
            }
        }
    }
    if {$sites} {
        foreach position [Positions $hir $e $finals] {
            lassign $position value final
            StaticSite $hir $value $final contravariant
        }
    }
    foreach child [hir::children $hir $e] {
        StaticWalk $hir $b $child $sites $finals callers opaque contravariant
    }
}

# 1 if some type of HIR's type table is or contains a structural Fn type.
proc hir::completions::HasFnTypes {hir} {
    if {![dict exists $hir types]} {
        return 1
    }
    dict for {id type} [dict get $hir types] {
        if {[string first "fn \{args " $type] >= 0 || [lindex $type 0] eq "fn"} {
            return 1
        }
    }
    return 0
}

# Adds to CONTRAVAR what a value of expression VALUE flowing into a position
# of static type FINAL erases into parameters a structural Fn type's
# argument types reach but its callable leaves untyped (Contravariant).
proc hir::completions::StaticSite {hir value final contraVar} {
    upvar 1 $contraVar contravariant
    if {$value eq "" || $final eq ""} {
        return
    }
    foreach triple [Align [hir::typeOf $hir $value] $final] {
        lassign $triple source target
        lappend contravariant {*}[Contravariant $hir $source $target]
    }
}

# The positions of expression E where a value acquires the type of where it
# lands, as {VALUE FINAL} pairs: the positions hir/callables.tcl's escape
# audit checks (WalkExpr) -- a call's arguments (hir::callables::ArgContexts)
# and the value a `yield` sends (FINALS: YieldFinalsOf), an `if` branch's,
# a collecting loop's and a handler's trailing value, a `return`'s or
# `break`'s value, a struct field -- for the static walk (Statics). A
# function's own trailing value is its block's (ResultFinal). The completion
# walk checks the same positions where it reaches them (Subsume).
proc hir::completions::Positions {hir e finals} {
    set node [dict get $hir exprs $e]
    set result {}
    switch -- [dict get $node kind] {
        call {
            foreach arg [dict get $node args] final [hir::callables::ArgContexts $hir $e] {
                lappend result [list $arg $final]
            }
            if {[dict exists $finals $e]} {
                foreach final [dict get $finals $e] {
                    lappend result [list [lindex [dict get $node args] 0] $final]
                }
            }
        }
        if {
            foreach role {thenBody elseBody} {
                lappend result [list [lindex [dict get $node $role] end] [hir::typeOf $hir $e]]
            }
        }
        listloop - countloop - lockloop {
            lappend result [list [lindex [dict get $node body] end] [hir::types::elementOf [hir::typeOf $hir $e]]]
        }
        return {
            if {[dict get $node target] ne ""} {
                lappend result [list [dict get $node value] [ResultFinal $hir [dict get $node target]]]
            }
        }
        break {
            if {[dict get $node target] ne ""} {
                lappend result [list [dict get $node value] [hir::typeOf $hir [dict get $node target]]]
            }
        }
        struct {
            if {![dict exists $node opaqueDenied]} {
                set structType [hir::typeOf $hir $e]
                foreach name [dict get $node names] field [dict get $node fields] {
                    lappend result [list $field [hir::types::StructField $structType $name]]
                }
            }
        }
        handle {
            foreach body [dict get $node handlerBodies] {
                lappend result [list [lindex $body end] [hir::typeOf $hir $e]]
            }
        }
    }
    return $result
}

# The static type a value block B returns lands in: its declared result
# type, else its inferred one ("" if it has none).
proc hir::completions::ResultFinal {hir b} {
    set node [dict get $hir exprs $b]
    if {[dict get $node declaredResult] ne {}} {
        return [dict get $node declaredResult]
    }
    if {![dict exists $node inferredResultType] || [dict get $node inferredResultType] eq ""} {
        return ""
    }
    return [hir::type $hir [dict get $node inferredResultType]]
}

# {SOURCE TARGET TOP} for every part of a value of static type TYPE that, as
# it flows into a position of static type FINAL, acquires a structural Fn
# type TARGET its own callable type SOURCE (an exact callable, or another
# Fn) does not name exactly: the value itself (TOP 1), or a part of it (TOP
# 0) -- a List/set/vector/array element, an anonymous struct's field, what a
# callable returns. A value of `any` never acquires a Fn type (the type
# checker rejects it).
proc hir::completions::Align {type final {depth 0}} {
    set type [hir::types::Unrefined $type]
    set final [hir::types::Unrefined $final]
    if {$depth > 8 || $type eq $final || $type in {never any ""} || $final in {"" any}} {
        return {}
    }
    set deeper [expr {$depth + 1}]
    if {[hir::types::IsFn $final]} {
        if {![hir::types::IsExactBlock $type] && ![hir::types::IsExactNative $type] && ![hir::types::IsFn $type]} {
            return {}
        }
        set result [list [list $type $final [expr {$depth == 0}]]]
        set returned [ResultOf $type]
        if {$returned ne ""} {
            lappend result {*}[Align $returned [hir::types::FnReturn $final] $deeper]
        }
        return $result
    }
    if {[hir::types::IsList $type] && [hir::types::IsList $final]} {
        set result {}
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            lappend result {*}[Align $t [lindex $final 1] $deeper]
        }
        return $result
    }
    if {([hir::types::IsSet $type] && [hir::types::IsSet $final])
            || ([hir::types::IsMutVec $type] && [hir::types::IsMutVec $final])
            || ([hir::types::IsMutArray $type] && [hir::types::IsMutArray $final])} {
        return [Align [lindex $type 1] [lindex $final 1] $deeper]
    }
    if {[hir::types::IsStruct $type] && [hir::types::IsStruct $final]
            && [dict keys [lindex $type 1]] eq [dict keys [lindex $final 1]]} {
        set result {}
        dict for {name t} [lindex $type 1] {
            lappend result {*}[Align $t [dict get [lindex $final 1] $name] $deeper]
        }
        return $result
    }
    return {}
}

# What calling a value of callable TYPE returns, or "".
proc hir::completions::ResultOf {type} {
    if {[hir::types::IsExactBlock $type]} {
        return [lindex $type 3]
    }
    if {[hir::types::IsFn $type]} {
        return [hir::types::FnReturn $type]
    }
    set s [hir::types::structuralOf $type]
    if {$s eq ""} {
        return ""
    }
    return [hir::types::FnReturn $s]
}

# What a callable of type SOURCE, given structural Fn type TARGET, has erased
# (erasedErrorsOf): every argument TARGET's contract types reaches the
# callable's own parameter, so where that parameter is untyped the value
# becomes erased there -- what each such argument type carries.
proc hir::completions::Contravariant {hir source target} {
    set errors {}
    set i 0
    foreach arg [hir::types::FnArgs $target] {
        if {[ParamUncontracted $hir $source $i]} {
            lappend errors {*}[hir::callables::CarriedErrors $hir $arg]
        }
        incr i
    }
    return $errors
}

# 1 if parameter I of a callable of type SOURCE holds what it is given with
# no contract: an exact block's untyped (or `any`) parameter, any native's
# (a native's structural arguments are all `any`, STRUCTURAL-FUNCTION-
# TYPES.md), a structural Fn's uncontracted argument.
proc hir::completions::ParamUncontracted {hir source i} {
    if {[hir::types::IsExactBlock $source]} {
        set block [lindex $source 1]
        if {![dict exists $hir exprs $block]} {
            return 0
        }
        set entry [lindex [hir::signatures::entryTypes $hir $block] $i]
        return [expr {$entry eq "" || [Uncontracted $entry]}]
    }
    if {[hir::types::IsExactNative $source]} {
        return 1
    }
    if {[hir::types::IsFn $source]} {
        set arg [lindex [hir::types::FnArgs $source] $i]
        return [expr {$arg ne "" && [Uncontracted $arg]}]
    }
    return 0
}

# The outward types the value of every `yield` of HIR lands in, as a dict
# YIELD -> {TYPE ...}: hir::coroutines::Outward of every coroutine root that
# can reach the yield's function.
proc hir::completions::YieldFinalsOf {hir} {
    set finals [dict create]
    if {![dict exists $hir coroutines thunks] || ![dict exists $hir coroutines direct]
            || ![dict exists $hir coroutines edges] || ![dict exists $hir coroutines blocks]} {
        return $finals
    }
    set table [dict get $hir coroutines]
    dict for {thunk info} [dict get $table thunks] {
        set root [dict getdef $info root ""]
        if {$root eq "" || ![dict exists $hir exprs $root]} {
            continue
        }
        set outward [hir::coroutines::Outward $hir $root]
        foreach b [hir::coroutines::Closure $root [dict get $table edges] [dict get $table blocks]] {
            if {![dict exists $table direct $b]} {
                continue
            }
            foreach y [dict get $table direct $b] {
                if {![dict exists $finals $y] || $outward ni [dict get $finals $y]} {
                    dict lappend finals $y $outward
                }
            }
        }
    }
    return $finals
}

# YieldFinalsOf HIR, for this pass.
proc hir::completions::YieldFinals {hir} {
    variable yieldFinals
    variable yieldFinalsKnown
    if {!$yieldFinalsKnown} {
        set yieldFinals [YieldFinalsOf $hir]
        set yieldFinalsKnown 1
    }
    return $yieldFinals
}

# ---------------------------------------------------------------------------
# The verified contract boundary (header)

# What calling any value uncontracted binding B of HIR can hold may raise:
# {ERRORS QUIET}, QUIET 1 when no such value calls an argument it is given
# (so what its caller passes it adds nothing). What a clean input stands for
# where the boundary is checked (Subsume). A parameter of a function that is
# only ever called (every reference to it is a callee) holds exactly what
# its calls pass; a local, what it is bound to; anything else -- a parameter
# of a function used as a value, a loop or destructured binding -- whatever
# the program erases (ErasedErrors).
proc hir::completions::Possible {hir b} {
    variable possible
    variable possibleKnown
    if {!$possibleKnown} {
        set possible [PossibleOf $hir]
        set possibleKnown 1
    }
    if {[dict exists $possible $b]} {
        return [dict get $possible $b]
    }
    return [list [ErasedErrors $hir] 0]
}

# Possible for every uncontracted binding of HIR, as a dict binding ->
# {ERRORS QUIET}: the least solution of one equation per binding (errors
# only grow, QUIET only falls), over a finite set of error names.
proc hir::completions::PossibleOf {hir} {
    set erased [ErasedErrors $hir]
    set paramOf [dict create]
    set definedBy [dict create]
    set callees [dict create]
    set calls [dict create]
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            block {
                set i 0
                foreach p [dict get $node params] {
                    dict set paramOf $p [list $e $i]
                    incr i
                }
            }
            bind {
                set v [dict get $node value]
                if {$v ne "" && [dict exists $hir exprs $v] && [dict get $hir exprs $v kind] eq "block"} {
                    dict set definedBy $v [dict get $node binding]
                }
            }
            call {
                dict set callees [dict get $node callee] 1
                lassign [dict get $node target] targetKind target
                if {$targetKind eq "block"} {
                    dict lappend calls $target [dict get $node args]
                }
            }
        }
    }
    set escaping [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && ![dict exists $callees $e]} {
            dict set escaping [dict get $node binding] 1
        }
    }
    set equations [dict create]
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding kind] eq "root" || ![CleanInput $hir $b]} {
            continue
        }
        if {[dict exists $paramOf $b]} {
            lassign [dict get $paramOf $b] block i
            if {![dict exists $definedBy $block] || [dict exists $escaping [dict get $definedBy $block]]} {
                dict set equations $b top
                continue
            }
            set values {}
            if {[dict exists $calls $block]} {
                foreach args [dict get $calls $block] {
                    if {$i < [llength $args]} {
                        lappend values [lindex $args $i]
                    }
                }
            }
            dict set equations $b $values
            continue
        }
        set by [dict get $binding declaredBy]
        if {[dict get $binding kind] eq "local" && $by ne "" && [dict exists $hir exprs $by]
                && [dict get $hir exprs $by kind] eq "bind" && [dict get $hir exprs $by value] ne ""} {
            dict set equations $b [list [dict get $hir exprs $by value]]
            continue
        }
        dict set equations $b top
    }
    set result [dict create]
    dict for {b equation} $equations {
        dict set result $b [if {$equation eq "top"} {list $erased 0} else {list {} 1}]
    }
    set changed 1
    while {$changed} {
        set changed 0
        dict for {b equation} $equations {
            if {$equation eq "top"} {
                continue
            }
            lassign [dict get $result $b] errors quiet
            foreach value $equation {
                lassign [ValueCarriesStatic $hir $value $result $erased] more calm
                lappend errors {*}$more
                set quiet [expr {$quiet && $calm}]
            }
            set new [list [lsort -unique $errors] $quiet]
            if {$new ne [dict get $result $b]} {
                dict set result $b $new
                set changed 1
            }
        }
    }
    return $result
}

# What the value of expression VALUE may raise when called (PossibleOf),
# under the current solution RESULT, as {ERRORS QUIET}: a contract's errors
# (QUIET unless an argument can reach it unchecked, ContractChannel); an
# exact native's declared errors (QUIET unless it calls an argument); an
# exact block's declared errors and what its uncontracted captures hold
# (QUIET unless it may call a parameter: one of uncontracted type, when it is
# transparent, or of a structural contract); for an uncontracted value, the
# binding a `ref` reads, else ERASED.
proc hir::completions::ValueCarriesStatic {hir value result erased} {
    set type [hir::typeOf $hir $value]
    if {$type eq "never"} {
        return {{} 1}
    }
    if {[hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
        set fact [ContractFact $type]
        return [list [lindex $fact 1] [expr {![ContractChannel [lindex $fact 2]]}]]
    }
    if {[hir::types::IsExactNative $type]} {
        if {[catch {core::native::metadata [lindex $type 1]} meta]} {
            return {{} 1}
        }
        return [list [dict get $meta errors] [expr {[dict get $meta errorsFrom] eq ""}]]
    }
    if {[hir::types::IsExactBlock $type]} {
        set block [lindex $type 1]
        if {![dict exists $hir exprs $block]} {
            return {{} 1}
        }
        set errors [dict get $hir exprs $block declaredErrors]
        foreach c [dict get $hir exprs $block captures] {
            if {[dict exists $result $c]} {
                lappend errors {*}[lindex [dict get $result $c] 0]
            } elseif {[CleanInput $hir $c]} {
                lappend errors {*}$erased
            }
        }
        set quiet 1
        foreach p [dict get $hir exprs $block params] {
            set t [hir::bindingType $hir $p]
            if {([CleanInput $hir $p] && [Transparent $hir $block])
                    || [hir::types::IsFn $t] || [hir::types::IsCoroutine $t]} {
                set quiet 0
            }
        }
        return [list $errors $quiet]
    }
    if {![Uncontracted $type]} {
        return {{} 1}
    }
    if {[hir::kind $hir $value] eq "ref"} {
        set b [hir::get $hir $value binding]
        if {[dict exists $result $b]} {
            return [dict get $result $b]
        }
    }
    return [list $erased 0]
}

# The verified contract boundary (header): VALUE (an expression this walk
# reached) flows into a position of static type FINAL. Every part of it that
# acquires a structural Fn type its own callable type does not name exactly
# (Align) must raise, when called through that type, only what the type's
# contract declares; an error outside it is a TYPE error at VALUE. Checked
# only by a body's own check (DIAGNOSE), where a clean input stands for every
# value it can hold (Possible): so the check holds for every activation of
# the body, however it is reached, and an analysis under one caller's facts
# has nothing to add.
proc hir::completions::Subsume {hirVar ctxVar diagnose guard value final} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {!$diagnose || $value eq "" || [ErasedErrors $hir] eq {}} {
        return
    }
    if {[hir::types::IsCoroutine [hir::typeOf $hir $value]]} {
        SubsumeHandle hir ctx $guard $value
        return
    }
    if {$final eq ""} {
        return
    }
    foreach triple [Align [hir::typeOf $hir $value] $final] {
        lassign $triple source target top
        if {![hir::types::subtype $source $target]} {
            # Not this check's: the type checker rejects it (what the type
            # itself declares does not fit).
            continue
        }
        # What the type shows is the type checker's; what it does not is
        # this check's.
        set shown [concat [hir::types::FnErrors $target] [hir::types::CallableErrors $hir $source]]
        foreach name [lsort -unique [SubsumedRaises hir ctx $guard [if {$top} {set value} else {string cat ""}] $source $target]] {
            if {$name ni $shown} {
                ReportOutside hir $value $source $target $top $name
            }
        }
    }
}

# Subsume for the positions of call E (NODE): its arguments, and the value a
# `yield` sends. (Not a coroutine operation's own handle operand: the handle
# stays where it is.)
proc hir::completions::SubsumeCall {hirVar ctxVar diagnose guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {!$diagnose || [ErasedErrors $hir] eq {}} {
        return
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "native" && [dict get [hir::symbol $hir $target] name] in [list \
            [core::coroutines::createNative] [core::coroutines::startNative] [core::coroutines::resumeNative] \
            [core::coroutines::doneNative] [core::coroutines::releaseNative]]} {
        return
    }
    foreach arg [dict get $node args] final [hir::callables::ArgContexts $hir $e] {
        Subsume hir ctx $diagnose $guard $arg $final
    }
    set finals [YieldFinals $hir]
    if {[dict exists $finals $e]} {
        foreach final [dict get $finals $e] {
            Subsume hir ctx $diagnose $guard [lindex [dict get $node args] 0] $final
        }
    }
}

# The verified contract boundary for a coroutine handle (Subsume): VALUE, a
# handle whose construction is in this body (hir::coroutines::thunkOfHandle),
# leaves it here -- passed, stored, returned -- and is resumed elsewhere
# through its Coroutine type alone, which is trusted to bound what a resume
# raises. Its thunk is analyzed with every capture holding what it holds
# here (a clean or unknown one standing for every value it can hold,
# Possible): an error outside the type's contract -- one the root raises
# through a callable passed to its construction -- is a TYPE error. A handle
# that never leaves its construction's body is resumed there, where each
# segment is analyzed under the same facts (NativeCallFacts); one that came
# from elsewhere was checked where it left.
proc hir::completions::SubsumeHandle {hirVar ctxVar guard value} {
    upvar 1 $hirVar hir $ctxVar ctx
    set thunk [hir::coroutines::thunkOfHandle $hir $value]
    if {$thunk eq ""} {
        return
    }
    set type [hir::typeOf $hir $value]
    set contract [hir::types::CoroutineErrors $type]
    set captures [dict create]
    foreach c [hir::get $hir $thunk captures] {
        set fact [BindingFact $hir $ctx $c]
        if {$fact in {clean unknown} && [CleanInput $hir $c]} {
            lassign [Possible $hir $c] errors quiet
            set fact [list contract $errors [expr {$quiet ? {} : "*"}]]
        }
        dict set captures $c $fact
    }
    lassign [EffectiveFacts hir ctx $thunk {} {} {} {} $guard $captures] _ errors
    foreach name [lsort -unique $errors] {
        if {$name ni $contract} {
            ReportOutside hir $value $type $type 1 $name
        }
    }
}

# What a callable of static type SOURCE may raise when called through
# structural Fn type TARGET, with any arguments TARGET admits. VALUE is the
# callable's own expression when it is the value itself (Align's TOP), else
# "".
#
#   an exact block   its body, analyzed with each parameter holding what
#                    TARGET's argument type admits (ParamFact) and each
#                    capture what it holds here -- the closure this
#                    activation created: this walk's facts -- with a clean or
#                    unknown capture standing for every value it can hold
#                    (Possible)
#   an exact native  its registered errors, and what TARGET admits for the
#                    callable argument it calls (-errors-from)
#   a structural Fn  its contract: within TARGET's (the type checker proved
#                    it), and its own check covered every argument TARGET
#                    admits (contravariance only narrows what it is given)
proc hir::completions::SubsumedRaises {hirVar ctxVar guard value source target} {
    upvar 1 $hirVar hir $ctxVar ctx
    set args [hir::types::FnArgs $target]
    if {[hir::types::IsFn $source]} {
        return [hir::types::FnErrors $source]
    }
    if {[hir::types::IsExactNative $source]} {
        if {[catch {core::native::metadata [lindex $source 1]} meta]} {
            return {}
        }
        set errors [dict get $meta errors]
        set from [dict get $meta errorsFrom]
        if {$from ne "" && $from < [llength $args]} {
            set fact [ArgumentFact $hir [lindex $args $from]]
            if {[lindex $fact 0] eq "contract"} {
                lappend errors {*}[lindex $fact 1]
            }
        }
        return $errors
    }
    if {![hir::types::IsExactBlock $source] || ![dict exists $hir exprs [lindex $source 1]]} {
        return {}
    }
    set block [lindex $source 1]
    set params [hir::get $hir $block params]
    set facts {}
    set i 0
    foreach b $params {
        lappend facts [ParamFact $hir $b [lindex $args $i]]
        incr i
    }
    set here [expr {$value ne "" && [CreatedHere $hir $ctx $value $block]}]
    set captures [dict create]
    foreach c [hir::get $hir $block captures] {
        if {$here} {
            set fact [BindingFact $hir $ctx $c]
        } else {
            set fact "unknown"
        }
        if {$fact in {clean unknown} && [CleanInput $hir $c]} {
            lassign [Possible $hir $c] errors quiet
            set fact [list contract $errors [expr {$quiet ? {} : "*"}]]
        }
        dict set captures $c $fact
    }
    set n [llength $params]
    lassign [EffectiveFacts hir ctx $block [lrepeat $n [hir::range::unknown]] [lrepeat $n {}] [lrepeat $n {}] \
        $facts $guard $captures] _ errors
    return $errors
}

# What a value passed through a structural Fn's argument of type ARG can
# raise when called, as a callable fact: a structural contract's own
# ({contract ERRORS ARGS}); for an uncontracted ARG, whatever the program
# erases ({contract ERASED {}}: anything may be passed there, and what it
# does with the arguments it is given is erased too); for any other type,
# nothing ({contract {} {}}: a call through the Fn passes a value of that
# type, which no call can make raise a declared error); "" for no ARG (an
# arity the type checker rejects).
proc hir::completions::ArgumentFact {hir arg} {
    if {$arg eq ""} {
        return ""
    }
    if {[hir::types::IsFn $arg] || [hir::types::IsCoroutine $arg]} {
        return [ContractFact $arg]
    }
    if {[Uncontracted $arg]} {
        return [list contract [ErasedErrors $hir] {}]
    }
    return {contract {} {}}
}

# The callable fact parameter binding B starts with when its callable is
# called through a structural Fn type whose argument type here is ARG
# (SubsumedRaises): ArgumentFact's for a callable ARG -- a contract's, or
# for an uncontracted one the erased-callable contract: a callable that
# calls a parameter the contract leaves untyped must admit what any value
# may raise there, since every call through the contract trusts it whatever
# it passes -- else none ("", the parameter's type's).
proc hir::completions::ParamFact {hir b arg} {
    return [ArgumentFact $hir $arg]
}

# Diagnoses VALUE: a callable of type SOURCE in it (the value itself when
# TOP) may raise error NAME, which structural Fn type TARGET, the type it
# acquires there, does not declare (Subsume). Once per position, Fn and
# error per pass.
proc hir::completions::ReportOutside {hirVar value source target top name} {
    upvar 1 $hirVar hir
    variable reported
    set key [list $value $target $name]
    if {[dict exists $reported $key]} {
        return
    }
    dict set reported $key 1
    set shown [hir::types::show $target]
    if {[hir::types::IsCoroutine $source]} {
        set message [format {this coroutine may produce the declared error "%s" when resumed (through a callable passed to its construction), but its type %s does not declare it, and it leaves its construction here: a resume through a value of that type is trusted to produce only the errors it declares} \
            $name $shown]
    } elseif {[hir::types::IsFn $source]} {
        set message [format {a value of function type %s is used here as a value of function type %s, whose calls may pass it an argument that produces the declared error "%s" when called -- an argument %s leaves untyped and so may call -- which %s does not declare: a call through a value of that type is trusted to produce only the errors it declares} \
            [hir::types::show $source] $shown $name [hir::types::show $source] $shown]
    } else {
        set what [expr {$top ? "this callable" : "a callable this value holds"}]
        set message [format {%s may produce the declared error "%s" when called (through a callable it captured or receives as an argument), but it is used here as a value of function type %s, which does not declare it: a call through a value of that type is trusted to produce only the errors it declares} \
            $what $name $shown]
    }
    hir::Diagnose hir TYPE $message $value
}

# What the arguments ARGEXPRS of an uncontracted call may make its callee
# raise beyond its own errors, when the callee may call them with arguments
# of its own (the argument channel): the arguments at the positions ARGS
# names -- every one for `*`, else those whose type in ARGS is itself a
# structural contract (ContractChannel: nothing checked the argument
# against it) -- each what its value carries (ValueCarries). {ERRORS LOST},
# LOST 1 when that is the erased-callable contract.
proc hir::completions::ArgChannel {hirVar ctxVar guard args_ argExprs} {
    upvar 1 $hirVar hir $ctxVar ctx
    set errors {}
    set lost 0
    set i 0
    foreach a $argExprs {
        if {$args_ eq "*"} {
            set t "*"
        } else {
            set t [lindex $args_ $i]
        }
        incr i
        if {$t ne "*" && ![hir::types::IsFn $t] && ![hir::types::IsCoroutine $t]} {
            continue
        }
        lassign [ValueCarries hir ctx $guard $a] carried l
        lappend errors {*}$carried
        set lost [expr {$lost || $l}]
    }
    return [list [lsort -unique $errors] $lost]
}

# What the value of argument expression A may raise when the callee it is
# passed to calls it with arguments of its own: {ERRORS LOST}. A contract's
# errors; an exact closure's effective errors under its captures' facts
# here (the closure this activation created, else none) with every
# uncontracted parameter unknown (the callee's arguments); otherwise what
# its callable fact carries (Carried).
proc hir::completions::ValueCarries {hirVar ctxVar guard a} {
    upvar 1 $hirVar hir $ctxVar ctx
    set type [hir::typeOf $hir $a]
    if {[hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
        return [list [dict get [hir::types::Contract $type] errors] 0]
    }
    if {![MayHoldCallable $type]} {
        return {{} 0}
    }
    set fact [CallableFact $hir $ctx $a]
    if {[lindex $fact 0] eq "block" && [dict exists $hir exprs [lindex $fact 1]]} {
        set block [lindex $fact 1]
        set n [llength [hir::get $hir $block params]]
        lassign [EffectiveFacts hir ctx $block [lrepeat $n [hir::range::unknown]] [lrepeat $n {}] [lrepeat $n {}] \
            [lrepeat $n ""] $guard [CaptureFacts $hir $ctx $a $block]] _ errors _ incomplete
        return [list $errors $incomplete]
    }
    return [Carried $hir $fact]
}

# ---------------------------------------------------------------------------
# Branch feasibility (item 29): a path of a condition whose narrowing is an
# empty Range (both bounds finite, min > max) cannot actually happen -- a
# genuine contradiction between the incoming argument facts and the
# condition, not merely "no new information" (hir::range::Narrowed's own ""
# return, which means the opposite: nothing to prune). hir::range::
# OutcomeFacts decides it (BranchOutcome, below).

# The Range to seed parameter binding B with, given its declared type
# (possibly ""): always hir::range::unknown -- exactly like hir::range's own
# AnalyzeInstance/verifyDeclaredParams seeding -- because ConstrainType
# (called on every `ref` read, mirroring hir::range::Expr's own ref case)
# already intersects a declared type's own integer-domain facts on demand;
# seeding it twice would be redundant, never more precise.
proc hir::completions::SeedParam {} {
    return [hir::range::unknown]
}

# ---------------------------------------------------------------------------
# The walker: Seq/Eval return a Range (a normally-completing expression) or
# the literal string "never" (this expression cannot complete normally on
# this path -- a `fail`, a `return`/`break`/`continue`, or a branch this
# pass proved infeasible). CTX is a dict:
#   bindings  bindingId -> Range        (mirrors hir::range's own ctx)
#   exact     bindingId -> core value   (an exact NON-INT constant fact,
#                                        e.g. a literal UnicodeChar element
#                                        during small-literal-list proof --
#                                        items 22/36-40; Int constants use
#                                        `bindings`'s own Range/exact-set
#                                        machinery instead, already general)
#   exactList bindingId -> {list V...}  (a List-kind binding's own literal-
#                                        List fact (LiteralListOf: its exact
#                                        element values; `{list}` is the
#                                        empty List), when it was bound
#                                        to a small literal list, either
#                                        directly or via a further exact
#                                        call boundary -- what lets
#                                        `std::byte::set(['-','.','_','~'])`'s own
#                                        literal-list proof see through the
#                                        call into `set`'s own `chars`
#                                        parameter, items 36-40)
#   indexBounds bindingId -> FORM       (a counted-loop variable proven to
#                                        satisfy 0 <= i < FORM in its loop's
#                                        body, FORM a hir/cardinality.tcl
#                                        linear form -- e.g. the length of
#                                        the List the loop counts over:
#                                        IndexBounds' relational case)
#   upperBounds KEY -> {FORM ...}       (an Int value proven < each FORM
#                                        in the current branch, from an
#                                        enclosing `if` condition comparing
#                                        it with a size: BranchRelations;
#                                        KEY a binding or {e EXPR}, a
#                                        computed local's defining
#                                        expression: RelationKey)
#   sizes     FORM -> N                 (a List length / MutableArray
#                                        capacity form proven equal to the
#                                        Int N in the current branch, from
#                                        an enclosing `std::list::length(xs) == N`)
#   exprs     exprId -> Range           (a per-walk cache so
#                                        ComparisonNarrowing can read a
#                                        condition's own already-evaluated
#                                        argument Ranges, exactly as
#                                        hir::range::If already relies on
#                                        Expr having populated ctx.exprs
#                                        first)
#   errors    name -> 1                 (every declared error name this
#                                        walk has found a reachable `fail`
#                                        for)
#   analyses  a scalar counter cell (a one-element list, mutated in place)
#             counting nested analyzeBlock calls against maxAnalyses
#   callables bindingId -> callable fact (CallableFact: {block B},
#                                        {native N}, {contract ERRORS}
#                                        or clean; a binding
#                                        with none is read by its static
#                                        type), only while the program
#                                        erases an error-bearing callable
#   closures  bindingId -> block        a local bound to a closure created
#                                        by this activation (its captures
#                                        are this walk's bindings)
#   incomplete 0|1                      this walk charged a call the
#                                        erased-callable contract, or used
#                                        an incomplete summary (header)

proc hir::completions::NewCtx {} {
    return [dict create bindings [dict create] exact [dict create] exactList [dict create] \
        indexBounds [dict create] upperBounds [dict create] sizes [dict create] minSizes [dict create] \
        exprs [dict create] errors [dict create] analyses 0 returned 0 returnRange never \
        record 0 visited [dict create] bounds [dict create] callables [dict create] closures [dict create] \
        incomplete 0 intended 0 folded [dict create]]
}

# Seeds CTX for a walk of BLOCK's own body by its own check (checkBlock,
# reachedExprs): every parameter and capture of uncontracted type
# (CleanInput) is `clean` -- a callable an erased argument puts there is
# charged at the call that passed it. One of structural Fn type keeps its
# type's fact: its contract bounds every call through it, wherever this body
# passes it.
proc hir::completions::SeedClean {hir ctxVar block} {
    upvar 1 $ctxVar ctx
    if {[ErasedErrors $hir] eq {}} {
        return
    }
    foreach b [concat [hir::get $hir $block params] [hir::get $hir $block captures]] {
        if {[CleanInput $hir $b]} {
            dict set ctx callables $b clean
        }
    }
}

# Walks EXPRS (a block body / branch body) in order; a "never" expression
# makes the rest of the sequence unreachable (item 32).
proc hir::completions::Seq {hirVar ctxVar diagnose enclosing guard e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set result [hir::range::unknown]
    foreach child $e {
        set result [Eval hir ctx $diagnose $enclosing $guard $child]
        if {$result eq {never}} {
            return never
        }
    }
    return $result
}

proc hir::completions::Eval {hirVar ctxVar diagnose enclosing guard e} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {[dict get $ctx record]} {
        dict set ctx visited $e 1
    }
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const {
            set v [dict get $node value]
            if {[core::value::kind $v] eq {int}} {
                set r [hir::range::point [core::value::intOf $v]]
            } else {
                set r [hir::range::unknown]
            }
            dict set ctx exprs $e $r
            return $r
        }
        ref {
            set b [dict get $node binding]
            if {[dict exists $node hole] || [dict exists $hir syntaxDependent $e]} {
                # Source nobody could read, or a name depending on it
                # (SYNTAX-RECOVERY-MILESTONE-1.md): it may complete with any
                # value; nothing proves it fails or what it raises.
                set r [hir::range::unknown]
                dict set ctx exprs $e $r
                return $r
            }
            if {$b eq {}} {
                return never
            }
            set r [hir::range::ConstrainType $hir $e [hir::range::BindingRange $hir [dict get $ctx bindings] $b]]
            dict set ctx exprs $e $r
            return $r
        }
        bind {
            set r [Eval hir ctx $diagnose $enclosing $guard [dict get $node value]]
            set b [dict get $node binding]
            if {$r ne {never} && ![dict get $node duplicate]
                    && [dict get [hir::binding $hir $b] kind] eq {local}} {
                dict set ctx bindings $b $r
                set v [ExactValueOf $hir $ctx [dict get $node value]]
                if {$v ne {} && [core::type::isFloat [core::value::kind $v]]} {
                    # A local bound to an exactly known floating-point value
                    # is that value (single assignment): a float has no
                    # Range to carry it, an Int's Range does.
                    dict set ctx exact $b $v
                } else {
                    dict unset ctx exact $b
                }
                if {[ErasedErrors $hir] ne {}} {
                    # A local is the value it is bound to (an alias of a
                    # clean parameter stays clean, header).
                    set value [dict get $node value]
                    set fact [CallableFact $hir $ctx $value]
                    if {$fact ne "unknown"} {
                        dict set ctx callables $b $fact
                    }
                    if {[hir::kind $hir $value] eq "block"} {
                        dict set ctx closures $b $value
                    }
                }
            }
            return $r
        }
        block {
            return [hir::range::unknown]
        }
        call {
            return [EvalCall hir ctx $diagnose $enclosing $guard $e $node]
        }
        if {
            return [EvalIf hir ctx $diagnose $enclosing $guard $e $node]
        }
        loop {
            return [EvalLoop hir ctx $diagnose $enclosing $guard $e $node]
        }
        listloop {
            return [EvalListloop hir ctx $diagnose $enclosing $guard $e $node]
        }
        countloop {
            return [EvalCountloop hir ctx $diagnose $enclosing $guard $e $node]
        }
        lockloop {
            return [EvalLockloop hir ctx $diagnose $enclosing $guard $e $node]
        }
        return {
            # Unlike `fail`, an explicit `return` is an ordinary, successful
            # completion of the enclosing function -- just via early exit
            # rather than falling off the end of the body -- so it must
            # count toward analyzeBlock's own "may return normally"
            # determination (mirroring hir::range::Expr's own `return`
            # case/ctx.returnRange, which this file did not have and, found
            # only via this milestone's own opt-tail-5 regression, wrongly
            # treated a function that always returns early -- e.g. any
            # tail-recursive style function using `return` in every branch
            # -- as unable to complete normally at all). Still `never` as
            # THIS expression's own contribution to its own sequence (later
            # sibling statements are correctly unreachable), and the
            # returned value is still walked for whatever errors/facts it
            # itself contributes. Its Range joins ctx.returnRange
            # (hir::range::Expr's own rule): analyzeBlock's result is the
            # join of every way the function returns, never the fall-through
            # alone (PROOF-FACT-CENSUS.md).
            set value [dict get $node value]
            if {$value eq {}} {
                set r [hir::range::unknown]
            } else {
                set r [Eval hir ctx $diagnose $enclosing $guard $value]
            }
            if {$r ne {never} && [dict get $node target] ne {}} {
                dict set ctx returned 1
                dict set ctx returnRange [hir::range::join [dict get $ctx returnRange] $r]
                Subsume hir ctx $diagnose $guard $value [ResultFinal $hir [dict get $node target]]
            }
            return never
        }
        break {
            set value [dict get $node value]
            if {$value ne {}} {
                if {[Eval hir ctx $diagnose $enclosing $guard $value] ne {never} && [dict get $node target] ne {}} {
                    Subsume hir ctx $diagnose $guard $value [hir::typeOf $hir [dict get $node target]]
                }
            }
            return never
        }
        continue {
            return never
        }
        fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                # The payload (ERROR-PAYLOADS.md) is evaluated first: one
                # that never completes raises nothing.
                if {[Eval hir ctx $diagnose $enclosing $guard [dict get $node value]] eq {never}} {
                    return never
                }
            }
            dict set ctx errors [dict get $node name] 1
            if {[dict exists $node static]} {
                # The reified failure of a rejected static block
                # (STATIC-COMPILE.md): an intended completion of the
                # intrinsic, which analyzeBlock never counts as proof that a
                # call cannot complete normally (KNOWN-ERROR). The error is
                # charged like any other.
                dict set ctx intended 1
            }
            return never
        }
        ok - error {
            set r [Eval hir ctx $diagnose $enclosing $guard [dict get $node value]]
            if {$r eq {never}} {
                return {never}
            }
            return [hir::range::unknown]
        }
        struct {
            # Field values are evaluated (and may fail or return) in written
            # order; a field that never completes normally means no struct
            # value is ever built.
            foreach field [dict get $node fields] {
                if {[Eval hir ctx $diagnose $enclosing $guard $field] eq {never}} {
                    return never
                }
            }
            if {![dict exists $node opaqueDenied]} {
                # Each field lands in its field's type: the verified contract
                # boundary where that is a structural Fn (Subsume).
                set structType [hir::typeOf $hir $e]
                foreach name [dict get $node names] field [dict get $node fields] {
                    Subsume hir ctx $diagnose $guard $field [hir::types::StructField $structType $name]
                }
            }
            return [hir::range::unknown]
        }
        project {
            # The projected field's Range is what its static type implies,
            # exactly as hir::range::Expr's own project case computes it (a
            # field declared with an integer domain holds values of that
            # domain: every construction proved it), so `std::byte::from_int(
            # x.value)` for `x: std::abi::U8` is as decided here as it is for a
            # local bound to x.value (ABI-NUMERIC-DOMAINS.md).
            if {[Eval hir ctx $diagnose $enclosing $guard [dict get $node receiver]] eq {never}} {
                return never
            }
            if {[hir::layouts::ProjectionReadsFloat [hir::typeOf $hir [dict get $node receiver]] [dict get $node name]]} {
                # A C floating field read through a native view or edit
                # (C-FLOAT-FFI-MILESTONE-1.md): native memory may hold a NaN
                # or an infinity, which is the read's NonFiniteFloat -- the
                # one projection that may fail (it becomes binary#view_field
                # after the checks, hir::layouts::Elaborate).
                if {$diagnose} {
                    CheckFloatReadLegality hir $e $node $enclosing
                }
                MergeErrors ctx NonFiniteFloat
            }
            set r [hir::range::ConstrainType $hir $e [hir::range::unknown]]
            dict set ctx exprs $e $r
            return $r
        }
        handle {
            return [EvalHandle hir ctx $diagnose $enclosing $guard $e $node]
        }
        default {
            return [hir::range::unknown]
        }
    }
}

# EXPR's outcome-1/outcome-0 branch feasibility and narrowing facts, using
# the SAME machinery hir::range::If uses to narrow a condition (reused
# directly, not reimplemented): hir::types::KnownOutcome first (a purely
# syntactic/type-level decided condition), then hir::range::OutcomeFacts
# against this walk's own ctx.exprs cache -- the condition's paths (`and`,
# `or`, `not`), each the ComparisonNarrowing of its pairs: the outcome is
# feasible when one of its paths is, and its facts are what every feasible
# path narrows. Returns {feasible 0|1 facts BINDINGS-DICT}.
proc hir::completions::BranchOutcome {hir ctx condition outcome} {
    set known [hir::types::KnownOutcome $hir $condition]
    if {$known ne {} && $known != $outcome} {
        return [list 0 {}]
    }
    # `monotone` is deliberately always empty here: hir::induction.tcl's own
    # equality-termination proof (what a real `monotone` dict would supply)
    # is keyed to hir::range.tcl's own interprocedural instance analysis --
    # a different, whole-program, codegen-facing pass this file never runs
    # (see this file's own header) -- so hir::range::EqualityNarrowing's
    # `==` case here always takes its general, non-monotone fallback
    # (ExactEqualityNarrowing), which is exactly right: this walk narrows
    # `==` purely from concrete exact-value facts, never a step-direction
    # proof.
    set shim [dict create exprs [dict get $ctx exprs] monotone {}]
    lassign [hir::range::OutcomeFacts $hir $shim $condition $outcome] feasible facts
    if {!$feasible} {
        return [list 0 {}]
    }
    return [list 1 $facts]
}

# The relational facts the `if` condition CONDITION establishes on its
# OUTCOME branch, for IndexBounds alone, added to ctx: a comparison of an
# Int value with a size (`i < std::list::length(xs)` true, `i >= std::list::length
# (xs)` false, ... in either operand order) records the value's exclusive
# upper bound as a hir/cardinality.tcl form (ctx.upperBounds, under the
# value's RelationKey: a binding, or a computed local's defining
# expression); an
# equality of a List length or MutableArray capacity with an exact Int
# (`std::list::length(bytes) == 1`) records that size (ctx.sizes). Only an Int
# comparison native (`< <= > >= ==`) is read; anything else adds nothing.
# Every form names immutable values, so a fact stays true for the whole
# branch. Each of the condition's Conjuncts contributes its own facts.
proc hir::completions::BranchRelations {hir ctxVar condition outcome} {
    upvar 1 $ctxVar ctx
    foreach conjunct [hir::range::Conjuncts $hir $condition $outcome] {
        BranchRelation $hir ctx {*}$conjunct
    }
}

proc hir::completions::BranchRelation {hir ctxVar condition outcome} {
    upvar 1 $ctxVar ctx
    set node [hir::node $hir $condition]
    if {[dict get $node kind] ne {call}} {
        return
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne {native}} {
        return
    }
    set op [dict get [hir::symbol $hir $target] name]
    set args [dict get $node args]
    if {$op ni {< <= > >= ==} || [llength $args] != 2} {
        return
    }
    lassign $args x y
    if {$op eq {==}} {
        foreach {a b} [list $x $y $y $x] {
            set n [hir::exact::IntOf $hir $b]
            set form [SizeForm $hir $a]
            if {$n eq {} || $form eq {}} {
                continue
            }
            if {$outcome} {
                dict set ctx sizes $form $n
            } elseif {$n == 0} {
                # A size is never negative, so one that is not 0 is >= 1.
                NoteMinSize ctx $form 1
            }
        }
        return
    }
    # Normalize to LOW < HIGH + K (exclusive): the binding side is LOW.
    switch -- $op/$outcome {
        </1  { set rel [list $x $y 0] }
        </0  { set rel [list $y $x 1] }
        <=/1 { set rel [list $x $y 1] }
        <=/0 { set rel [list $y $x 0] }
        >/1  { set rel [list $y $x 0] }
        >/0  { set rel [list $x $y 1] }
        >=/1 { set rel [list $y $x 1] }
        >=/0 { set rel [list $x $y 0] }
    }
    lassign $rel low high k
    # A constant below a size (`std::list::length(xs) > 0`, `std::str::length(s) >= 1`
    # true, `std::str::length(s) < 1` false): LOW < SIZE + K, so SIZE >= LOW - K + 1.
    # An Int binding takes the same minimum (`if n > 0:`), which a size form
    # equal to that binding then reads (an array allocated or created with
    # capacity n).
    set lowInt [hir::exact::IntOf $hir $low]
    set steps 0
    set sizeForm [SizeForm $hir $high]
    if {$sizeForm eq {}} {
        lassign [hir::cardinality::Chase $hir $high steps] highKind highBinding
        if {$highKind eq {binding}} {
            set sizeForm [hir::cardinality::FormAtom [list v $highBinding]]
        }
    }
    if {$lowInt ne {} && $sizeForm ne {}} {
        NoteMinSize ctx $sizeForm [expr {$lowInt - $k + 1}]
    }
    set key [RelationKey $hir $low]
    set form [hir::cardinality::FormAdd [hir::cardinality::IntForm $hir $high steps] \
        [hir::cardinality::FormConst $k]]
    set bounds [dict get $ctx upperBounds]
    dict lappend bounds $key $form
    dict set ctx upperBounds $bounds
}

# The key under which a relation on the Int expression E is recorded
# (ctx.upperBounds) and looked up (IndexBounds): one convention, Chase's
# (PROOF-FACT-CENSUS.md, G12). The binding an alias chain ends at with no
# defining expression (a parameter, a loop variable), else {e D}, the
# expression D the chain ends at: a computed local `j = i + 1` guarded by
# `if j < 0 or j >= std::list::length(xs): return ...` is keyed by its one
# defining expression, which every reference to j (and to any alias of j)
# chases to. The relation is then about the value that one evaluation of D
# bound -- the value every such reference reads, the binding being
# single-assignment -- and lives only in the scope that proved it, like
# every relation (Relations): a loop body or handler restores the facts it
# started with, so another evaluation of D (the next iteration) never sees
# it. An expression no alias names (a guard on `i + 1` written inline) keys
# a relation nothing reads: each written `i + 1` is its own expression.
proc hir::completions::RelationKey {hir e} {
    set steps 0
    lassign [hir::cardinality::Chase $hir $e steps] kind id
    if {$kind eq {binding}} {
        return $id
    }
    return [list e $id]
}

# The form of E when it is exactly one container size -- a List length, a
# MutableArray capacity or a String length (`std::list::length(xs)`, a binding
# of it, ...) -- else "".
proc hir::completions::SizeForm {hir e} {
    set steps 0
    set form [hir::cardinality::IntForm $hir $e steps]
    lassign $form c terms
    if {$c == 0 && [llength $terms] == 2 && [lindex $terms 1] == 1
            && [lindex [lindex $terms 0] 0] in {len cap slen}} {
        return $form
    }
    return ""
}

# Records in ctx.minSizes that the size FORM is at least MIN on the current
# branch (keeping the larger of two such facts).
proc hir::completions::NoteMinSize {ctxVar form min} {
    upvar 1 $ctxVar ctx
    if {[dict exists $ctx minSizes $form] && [dict get $ctx minSizes $form] >= $min} {
        return
    }
    dict set ctx minSizes $form $min
}

proc hir::completions::EvalIf {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set condition [dict get $node condition]
    Eval hir ctx $diagnose $enclosing $guard $condition
    set saved [dict get $ctx bindings]
    set branches [dict create]
    set after [dict create]
    set relations [dict create]
    foreach {outcome role} {1 then 0 else} {
        lassign [BranchOutcome $hir $ctx $condition $outcome] feasible facts
        if {!$feasible} {
            dict set branches $outcome never
            dict set after $outcome $saved
            continue
        }
        dict set ctx bindings $saved
        foreach {b r} $facts {
            dict set ctx bindings $b $r
        }
        set savedRelations [Relations $ctx]
        BranchRelations $hir ctx $condition $outcome
        dict set relations $outcome [Relations $ctx]
        dict set branches $outcome [Seq hir ctx $diagnose $enclosing $guard [dict get $node ${role}Body]]
        if {[dict get $branches $outcome] ne {never}} {
            Subsume hir ctx $diagnose $guard [lindex [dict get $node ${role}Body] end] [hir::typeOf $hir $e]
        }
        RestoreRelations ctx $savedRelations
        dict set after $outcome [dict get $ctx bindings]
    }
    # When only one branch can complete normally (`if i >= std::list::length(xs):
    # return acc` followed by the rest of the body), whatever follows the
    # `if` runs only on that branch's outcome: its condition relations
    # hold there too, exactly as JoinBindings keeps the live branch's range
    # facts.
    foreach {outcome other} {1 0 0 1} {
        if {[dict get $branches $other] eq {never} && [dict get $branches $outcome] ne {never}
                && [dict exists $relations $outcome]} {
            RestoreRelations ctx [dict get $relations $outcome]
        }
    }
    dict set ctx bindings [hir::range::JoinBindings $saved [dict get $after 1] [dict get $after 0] $branches]
    set t [dict get $branches 1]
    set f [dict get $branches 0]
    if {$t eq {never} && $f eq {never}} {
        return never
    }
    if {$t eq {never}} {
        return $f
    }
    if {$f eq {never}} {
        return $t
    }
    return [hir::range::join $t $f]
}

# A general (dynamic) loop/listloop body: no per-iteration concrete facts
# (item 91 -- no general loop theorem proving), but every error the body
# might reach is still a genuine possibility (an arbitrary number of
# iterations, any of which could hit it), so the body is walked once, under
# the element binding left unseeded (hir::range::unknown, the same fallback
# an ordinary untracked ref already gets), purely to collect ctx.errors and
# any diagnostics for calls it directly contains. The loop's own overall
# completion is conservatively "may complete normally" (an ordinary,
# non-error-producing List/loop result is always possible: zero iterations,
# or every iteration's own error path not taken).
proc hir::completions::EvalLoop {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set saved [dict get $ctx bindings]
    set relations [Relations $ctx]
    SubsumeCollected hir ctx $diagnose $guard $e $node [Seq hir ctx $diagnose $enclosing $guard [dict get $node body]]
    dict set ctx bindings $saved
    RestoreRelations ctx $relations
    return [hir::range::unknown]
}

# Subsume for a collecting loop E (NODE: a listloop, countloop or lockloop)
# whose body's walk ended with RESULT: its trailing value is collected into
# the loop's List result (RETURNING-ITERABLE-LOOPS.md, COLLECTING-LOOPS.md).
proc hir::completions::SubsumeCollected {hirVar ctxVar diagnose guard e node result} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {$result eq {never} || [dict get $node kind] ni {listloop countloop lockloop}} {
        return
    }
    Subsume hir ctx $diagnose $guard [lindex [dict get $node body] end] \
        [hir::types::elementOf [hir::typeOf $hir $e]]
}

# The relational facts (ctx.upperBounds, ctx.sizes) in effect: what a scope
# whose body may run zero times, or only on some other path -- a loop body,
# a handler -- restores when it ends, so a fact established inside it (an
# early `return`/`break` guard: `if j >= std::list::length(ys): break`) never
# outlives it.
proc hir::completions::Relations {ctx} {
    return [list [dict get $ctx upperBounds] [dict get $ctx sizes] [dict get $ctx minSizes]]
}

proc hir::completions::RestoreRelations {ctxVar relations} {
    upvar 1 $ctxVar ctx
    lassign $relations upper sizes minSizes
    dict set ctx upperBounds $upper
    dict set ctx sizes $sizes
    dict set ctx minSizes $minSizes
}

# Walks a collecting loop's iteration domain: OPERANDS, the ExprIds a
# listloop's iterable, a countloop's start and end or a lockloop's domain
# operands (hir::loopOperands) name, which run once, in this order, in the
# enclosing scope, before the first iteration -- an ordinary sequence, like
# the statements before the loop (Seq). Their Ranges in order, or `never`
# when one cannot complete normally: the loop never starts, so the operands
# after it and the body are never reached, charged or diagnosed, and the
# loop is itself `never` there -- exactly the statement `xs = g(n)` bound
# before `loop x in xs:` would be. What an operand raises (a call, a
# handled call's unhandled remainder) is charged and diagnosed where it is
# written, like any other expression of the enclosing body: a domain is
# never skipped, or a fallible call in it would escape unchecked.
proc hir::completions::LoopDomain {hirVar ctxVar diagnose enclosing guard operands} {
    upvar 1 $hirVar hir $ctxVar ctx
    set ranges {}
    foreach operand $operands {
        set r [Eval hir ctx $diagnose $enclosing $guard $operand]
        if {$r eq {never}} {
            return never
        }
        lappend ranges $r
    }
    return $ranges
}

# A countloop's start/end are evaluated once, in the enclosing scope, in
# that order and before the first iteration, exactly like EvalListloop's own
# iterable -- walked here to record whatever errors/diagnostics/facts they
# themselves contribute, and for their Ranges. One that cannot complete
# normally makes the whole loop `never` there (LoopDomain): the end after a
# start that never completes, and the body, never run.
# The body is then walked once, EvalLoop's own conservative treatment (item
# 91's "no general loop theorem proving": no per-iteration concrete facts),
# but under the induction binding's interval -- the very counted-loop theorem
# hir/range.tcl seeds the binding with (hir::range::InductionBinding, shared,
# not re-derived: START <= i < END, ... per direction and endKind) over the
# START/END Ranges this walk computed (PROOF-FACT-CENSUS.md G3). Like every
# binding fact it lives only in the body (restored below), so it never
# outlives the loop. A countloop's own completion is conservatively "may
# complete normally": unlike a bare loop, natural exhaustion (the collected
# List) is always a *genuinely* reachable completion here, not merely a
# conservative assumption, so this is at least as sound as EvalLoop's own
# case.
proc hir::completions::EvalCountloop {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set ranges [LoopDomain hir ctx $diagnose $enclosing $guard [list [dict get $node start] [dict get $node end]]]
    if {$ranges eq {never}} {
        return never
    }
    lassign $ranges start end
    set saved [dict get $ctx bindings]
    set savedBounds [dict get $ctx indexBounds]
    set relations [Relations $ctx]
    dict set ctx bindings [dict get $node countBinding] \
        [hir::range::InductionBinding $start $end [dict get $node direction] [dict get $node endKind]]
    NoteIndexBound hir ctx [dict get $node countBinding] $start [dict get $node end] \
        [dict get $node direction] [dict get $node endKind]
    SubsumeCollected hir ctx $diagnose $guard $e $node [Seq hir ctx $diagnose $enclosing $guard [dict get $node body]]
    dict set ctx bindings $saved
    dict set ctx indexBounds $savedBounds
    RestoreRelations ctx $relations
    return [hir::range::unknown]
}

# Records in ctx.indexBounds that the counted-loop variable BINDING
# satisfies 0 <= BINDING < FORM throughout its loop's body, when that is
# provable from the loop's own domain: an ascending loop whose START (Range
# STARTRANGE) is provably >= 0 visits START, START+1, ... up to END
# exclusive (`to`) or inclusive (`through`), so every value is below END's
# form (END + 1 for `through`). END is evaluated once, before the first
# iteration, and its form names only immutable values (hir/cardinality.tcl),
# so the bound holds for the whole body. A descending loop, or a start not
# proven nonnegative, records nothing. Read only by IndexBounds.
proc hir::completions::NoteIndexBound {hirVar ctxVar binding startRange end direction endKind} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {$direction ne "up" || $startRange eq {never}} {
        return
    }
    set min [dict get $startRange min]
    if {$min eq "-inf" || $min < 0} {
        return
    }
    set steps 0
    set form [hir::cardinality::IntForm $hir $end steps]
    if {$endKind eq "inclusive"} {
        set form [hir::cardinality::FormAdd $form [hir::cardinality::FormConst 1]]
    }
    dict set ctx indexBounds $binding $form
}

# A lockloop's domain operands are evaluated once, in written order, in the
# enclosing scope (walked here for whatever errors/diagnostics/facts they
# contribute; one that cannot complete normally makes the loop `never`
# there, LoopDomain); the body is then walked once, EvalCountloop's own
# conservative treatment: each numeric domain's binding gets the same
# interval hir/range.tcl gives it, each list domain's element binding stays
# unseeded.
proc hir::completions::EvalLockloop {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set operands [hir::loopOperands $node]
    set results [LoopDomain hir ctx $diagnose $enclosing $guard $operands]
    if {$results eq {never}} {
        return never
    }
    set ranges [dict create]
    foreach operand $operands r $results {
        dict set ranges $operand $r
    }
    set saved [dict get $ctx bindings]
    set savedBounds [dict get $ctx indexBounds]
    set relations [Relations $ctx]
    foreach domain [dict get $node domains] {
        if {[dict get $domain kind] eq "count"} {
            dict set ctx bindings [dict get $domain binding] [hir::range::InductionBinding \
                [dict get $ranges [dict get $domain start]] [dict get $ranges [dict get $domain end]] \
                [dict get $domain direction] [dict get $domain endKind]]
            NoteIndexBound hir ctx [dict get $domain binding] [dict get $ranges [dict get $domain start]] \
                [dict get $domain end] [dict get $domain direction] [dict get $domain endKind]
        }
    }
    SubsumeCollected hir ctx $diagnose $guard $e $node [Seq hir ctx $diagnose $enclosing $guard [dict get $node body]]
    dict set ctx bindings $saved
    dict set ctx indexBounds $savedBounds
    RestoreRelations ctx $relations
    return [hir::range::unknown]
}

# A listloop's ITERABLE is evaluated first, once, in the enclosing scope
# (LoopDomain): what it raises is charged and diagnosed there, and one that
# cannot complete normally makes the whole loop `never` before any of what
# follows is considered -- the body is never walked.
#
# listloop's small-exact-literal-list proof (items 36-40, 92): when ITERABLE
# is itself a call to the variadic `list` native whose every argument is a
# plain `const`, within hir::range's own exact-value budget, this walks the
# body once per element, left to right (item 73), each under that exact
# element's own fact (an Int point for an int element, ctx.exact for any
# other constant kind, e.g. UnicodeChar). If some element's own body proves
# unable to complete normally, the whole listloop stops there (matching
# runtime left-to-right completion semantics) and is itself never, carrying
# every error discovered up to and including that element (items 39/73).
# An empty literal list (the fact `{list}`, never confused with "no fact")
# never executes the body at all (item 92): the body is not walked -- like
# a branch proven infeasible, nothing in it is reached, so nothing in it is
# charged or diagnosed -- and the loop completes normally with its empty
# List, no errors, whatever the body could do (break or continue included).
#
# Any other iterable (dynamic, or a literal list too large for the budget)
# falls back to EvalLoop's own general, conservative treatment -- this is a
# strict *addition* on top of that case, not a replacement for it, mirroring
# hir::range.tcl's own "exact set is a strict addition to the interval"
# discipline for the identical reason (never less sound than the general
# case, only sometimes more precise).
#
# A body that can `break` or `continue` this loop falls back to EvalLoop too:
# such a body also walks as `never` (it does not complete normally), yet the
# loop then goes on or ends normally, so stopping there and calling the loop
# `never` would hide everything after it from the proof (PROOF-FACT-CENSUS.md).
proc hir::completions::EvalListloop {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set iterable [dict get $node iterable]
    if {[LoopDomain hir ctx $diagnose $enclosing $guard [list $iterable]] eq {never}} {
        return never
    }
    set fact [LiteralListOf $hir $ctx $iterable]
    if {$fact eq {list}} {
        return [hir::range::unknown]
    }
    if {$fact eq {} || [ExitsLoop $hir $e [dict get $node body]]} {
        return [EvalLoop hir ctx $diagnose $enclosing $guard $e $node]
    }
    set elements [LiteralElements $fact]
    set elementBinding [dict get $node elementBinding]
    set saved [dict get $ctx bindings]
    set savedExact [dict get $ctx exact]
    set relations [Relations $ctx]
    set result [hir::range::unknown]
    foreach v $elements {
        dict set ctx bindings $saved
        dict set ctx exact $savedExact
        RestoreRelations ctx $relations
        if {[core::value::kind $v] eq {int}} {
            dict set ctx bindings $elementBinding [hir::range::point [core::value::intOf $v]]
        } else {
            dict set ctx exact $elementBinding $v
        }
        set result [Seq hir ctx $diagnose $enclosing $guard [dict get $node body]]
        SubsumeCollected hir ctx $diagnose $guard $e $node $result
        if {$result eq {never}} {
            break
        }
    }
    dict set ctx bindings $saved
    dict set ctx exact $savedExact
    RestoreRelations ctx $relations
    if {$result eq {never}} {
        return {never}
    }
    return [hir::range::unknown]
}

# 1 if a `break` or `continue` targeting loop LOOP occurs in EXPRS (never
# looking inside a nested function body, which cannot target it).
proc hir::completions::ExitsLoop {hir loop exprs} {
    foreach e $exprs {
        switch -- [hir::kind $hir $e] {
            block { continue }
            break - continue {
                if {[hir::get $hir $e target] eq $loop} {
                    return 1
                }
            }
        }
        if {[ExitsLoop $hir $loop [hir::children $hir $e]]} {
            return 1
        }
    }
    return 0
}

# The literal-List fact of EXPR (a List-typed expression): {list V...}, the
# tag `list` followed by its exact element core values in order, if EXPR is
# either (a) a direct call to the variadic `list` native with every argument
# a plain `const`, within hir::range's own exact-value budget (item 37:
# reused, not reintroduced), or (b) a `ref` to a binding this walk's own
# ctx.exactList already established -- the general form of (a), threaded
# across an exact call boundary the same way an Int/UnicodeChar exact value
# already is (ArgExactValues/ctx.exact): this is what lets
# `std::byte::set(['-','.','_','~'])`'s own literal argument reach `set`'s own
# `loop c in chars:` (whose iterable is a plain `ref` to the parameter
# `chars`, not the literal list expression itself) as a genuine small
# literal list, with no `set`/`byte`-specific code anywhere in this file.
# "" otherwise: no fact (not a small literal list; EvalListloop falls back
# to the general case). The tag is what keeps the empty literal `[]`,
# `{list}` -- exactly zero elements, a loop over it never runs its body
# (item 92) -- apart from "no fact": a parameter merely typed List, or any
# other List this walk does not know, is "", never `{list}`.
proc hir::completions::LiteralListOf {hir ctx expr} {
    if {[hir::kind $hir $expr] eq {ref}} {
        set b [hir::get $hir $expr binding]
        set exactList [dict get $ctx exactList]
        if {$b ne {} && [dict exists $exactList $b]} {
            return [dict get $exactList $b]
        }
        return {}
    }
    if {[hir::kind $hir $expr] ne {call}} {
        return {}
    }
    lassign [hir::get $hir $expr target] targetKind target
    if {$targetKind ne {native} || [dict get [hir::symbol $hir $target] name] ne {list}} {
        return {}
    }
    set args [hir::get $hir $expr args]
    if {[llength $args] > $::hir::range::maxExactValues} {
        return {}
    }
    set fact {list}
    foreach arg $args {
        if {[hir::kind $hir $arg] ne {const}} {
            return {}
        }
        lappend fact [hir::get $hir $arg value]
    }
    return $fact
}

# The exact element core values of literal-List fact FACT (LiteralListOf),
# in order: {} for the empty List `{list}`.
proc hir::completions::LiteralElements {fact} {
    return [lrange $fact 1 end]
}

# A native call's own result Range. Its bound is the one hir/range.tcl
# computes (so the two analyses never disagree about a native): `+ - *`,
# `bit_and bit_or bit_xor shift_left shift_right` and `mod` reuse
# hir::range's own transfer functions (identical to hir::range::Call's own
# native case), and any other native its -result-range metadata
# (hir::range::RegisteredRange: std::char::scalar_value's [0, 0x10FFFF], a
# length's collection-length, ...). On top of that bound this pass adds the
# exact value of a native whose arguments its walk knows exactly (ctx.exact
# reaches call-specific facts hir/range.tcl never sees): the length of a
# known String or List, and the codepoint of a known UnicodeChar (a literal,
# or ctx.exact propagation through an immutable binding -- e.g. a
# small-literal-list element, EvalListloop above; item 22).
proc hir::completions::NativeResultRange {hir ctx name argExprs argRanges} {
    if {$name in {+ - *} && [llength $argRanges] == 2} {
        lassign $argRanges x y
        switch -- $name {
            + { return [hir::range::add $x $y] }
            - { return [hir::range::sub $x $y] }
            * { return [hir::range::mul $x $y] }
        }
    }
    if {$name in {bit_and bit_or bit_xor shift_right shift_left} && [llength $argRanges] == 2} {
        lassign $argRanges x y
        return [hir::range::BitOp $name $x $y]
    }
    if {$name eq {mod} && [llength $argRanges] == 2} {
        return [hir::range::Mod {*}$argRanges]
    }
    if {$name in {std::str::length std::list::length} && [llength $argExprs] == 1} {
        # The length of a String or List this walk knows exactly (a literal,
        # an exact binding, an exact argument of this call-specific walk) is
        # that exact number -- what a slice or index proof inside a callee
        # needs from `n = std::str::length(s)` once s is a known argument.
        set arg [lindex $argExprs 0]
        if {$name eq {std::str::length}} {
            set v [ExactValueOf $hir $ctx $arg]
            if {$v ne {} && [core::value::kind $v] eq {str}} {
                return [hir::range::point [string length [core::value::strOf $v]]]
            }
        } else {
            set literal [LiteralListOf $hir $ctx $arg]
            if {$literal ne {}} {
                return [hir::range::point [llength [LiteralElements $literal]]]
            }
        }
    }
    if {$name eq {std::char::scalar_value} && [llength $argExprs] == 1} {
        set v [ExactValueOf $hir $ctx [lindex $argExprs 0]]
        if {$v ne {} && [core::value::kind $v] eq {UnicodeChar}} {
            return [hir::range::point [core::value::charOf $v]]
        }
    }
    set exact [hir::exact::NativeRange $hir $name $argExprs $argRanges [dict get $ctx exprs]]
    if {$exact ne {}} {
        return $exact
    }
    # (A fact the argument's static type states: hir::range::Call.)
    set measured [hir::types::MeasuredValue $hir $name $argExprs]
    if {$measured ne {}} {
        return [hir::range::point $measured]
    }
    return [hir::range::RegisteredRange $name]
}

# The exact core value of EXPR, if it is a literal `const` or a `ref` to a
# binding this walk's ctx.exact already established (item 22's "exact
# character literal" case; general, not char-specific: any const kind).
proc hir::completions::ExactValueOf {hir ctx e} {
    if {[hir::kind $hir $e] eq {const}} {
        return [hir::get $hir $e value]
    }
    if {[hir::kind $hir $e] eq {ref}} {
        set b [hir::get $hir $e binding]
        set exact [dict get $ctx exact]
        if {$b ne {} && [dict exists $exact $b]} {
            return [dict get $exact $b]
        }
    }
    if {[hir::kind $hir $e] eq {call} && [dict exists $ctx folded $e]} {
        # A native call this walk decided (FoldCall): its value.
        return [dict get $ctx folded $e]
    }
    return {}
}

# The decision of call E of the root native NAME (argument expressions
# ARGEXPRS) this walk can make: a native with a fold (core/native.tcl's
# -fold: the floating-point operations, core/float.tcl) whose every argument
# this walk knows exactly is decided by computing it -- {value V}, or {error
# NAME} -- the very computation a run of it makes. "" when nothing is
# decided.
proc hir::completions::FoldCall {hir ctx name argExprs} {
    set fold [dict get [core::native::metadata $name] fold]
    if {$fold eq {}} {
        return {}
    }
    set values {}
    foreach a $argExprs {
        set v [ExactValueOf $hir $ctx $a]
        if {$v eq {} && [dict exists $ctx exprs $a]} {
            # An Int this walk knows exactly is its Range's one value.
            set exact [hir::range::ExactOf [dict get $ctx exprs $a]]
            if {[llength $exact] == 1} {
                set v [core::value::int $exact]
            }
        }
        if {$v eq {}} {
            return {}
        }
        lappend values $v
    }
    if {$values eq {}} {
        return {}
    }
    return [{*}$fold {*}$values]
}

proc hir::completions::EvalCall {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set argExprs [dict get $node args]
    set argRanges {}
    foreach a $argExprs {
        set r [Eval hir ctx $diagnose $enclosing $guard $a]
        if {$r eq {never}} {
            return never
        }
        lappend argRanges $r
    }
    # Where an argument acquires a structural Fn type (or a yield's value
    # its coroutine's outward one): the verified contract boundary.
    SubsumeCall hir ctx $diagnose $guard $e $node
    lassign [dict get $node target] targetKind target
    if {$targetKind eq {native}} {
        set name [dict get [hir::symbol $hir $target] name]
        set decided [FoldCall $hir $ctx $name $argExprs]
        if {[lindex $decided 0] eq "value"} {
            # A floating-point value has no Range: its exact value is the
            # fact a later fold reads (ExactValueOf).
            dict set ctx folded $e [lindex $decided 1]
        } else {
            # (Nothing an earlier walk of E decided, under other facts.)
            dict unset ctx folded $e
        }
        # A native that declares errors (-errors, core/native.tcl: `argv`,
        # `std::list::at`) is held to the same legality rule as any other
        # fallible call, under its own call-specific facts
        # (NativeEffectiveFacts). So is one that calls a callable argument
        # while the program erases an error-bearing callable (IndirectFacts).
        if {([NativeDeclaredErrors $hir $e $name] ne {} || [CallsCallable $hir $name])
                && ![hir::types::Poisoned $hir $e]} {
            # (A poisoned call -- an operand an earlier check rejected,
            # hir/types.tcl -- never runs the operation: it owes nothing.)
            lassign [NativeCallFacts hir ctx $guard $e $name $argExprs $argRanges] normal errors verdicts
            if {$diagnose} {
                CheckNativeCallLegality hir $e $name $normal $errors {} $enclosing
                NoteBounds ctx $e $verdicts
            }
            MergeErrors ctx $errors
            if {!$normal} {
                return never
            }
        }
        set result [hir::range::ConstrainType $hir $e [NativeResultRange $hir $ctx $name $argExprs $argRanges]]
        dict set ctx exprs $e $result
        if {$diagnose} {
            dict set hir exprs $e resultRangeFact $result
        }
        return $result
    }
    if {$targetKind ne {block}} {
        set calleeType [hir::typeOf $hir [dict get $node callee]]
        # A call through a structural function type (STRUCTURAL-FUNCTION-
        # TYPES.md): which implementation runs may be unknown, but every
        # value of that type was checked against its contract (the verified
        # contract boundary, header), so the contract's errors bound it --
        # plus what its arguments carry into parameters the contract leaves
        # untyped -- and an exact callable fact may narrow that, never widen
        # it; the call's result is what the contract promises. (A coroutine
        # handle's resume, AFFINE-VALUES.md: the same contract, the errors
        # any one segment may end with.) A call through an uncontracted
        # value is charged what its callable fact says (IndirectFacts):
        # nothing for a clean one, as before.
        lassign [IndirectFacts hir ctx $diagnose $guard $e [dict get $node callee] $calleeType $argExprs $argRanges] how errors
        if {$how eq "none"} {
            return [hir::range::unknown]
        }
        if {$diagnose} {
            CheckIndirectCallLegality hir $e $calleeType $errors {} $enclosing
        }
        MergeErrors ctx $errors
        set result [hir::range::ConstrainType $hir $e [hir::range::unknown]]
        dict set ctx exprs $e $result
        if {$diagnose} {
            dict set hir exprs $e resultRangeFact $result
        }
        return $result
    }
    set argExact [ArgExactValues $hir $ctx $argExprs]
    set argExactLists [ArgExactLists $hir $ctx $argExprs]
    lassign [EffectiveFacts hir ctx $target $argRanges $argExact $argExactLists \
        [ArgCallables $hir $ctx $argExprs] $guard [CaptureFacts $hir $ctx [dict get $node callee] $target]] \
        normal errors resultRange incomplete
    if {!$normal && [hir::coroutines::isBoundaryCall $hir $e]} {
        # A coroutine's root call (COROUTINES.md): its segments may complete
        # normally by yielding even when its last one always fails.
        set normal 1
    }
    if {[dict exists $node traitImpl]} {
        # A trait operation of a monomorphized clone (TRAITS.md): its
        # legality is its requirement's error contract, exactly as the
        # source function was checked against it -- never a diagnostic only
        # one witness's implementation would give (no instantiation-time
        # errors). The implementation's own facts still give the result --
        # and, when they are incomplete, what an erased callable may raise
        # through it (header).
        set errors [TraitCallErrors [dict get $node traitImpl contract] $errors $incomplete]
        if {$diagnose} {
            CheckStructuralCallLegality hir $e [dict get $node traitImpl contract] $errors {} $enclosing
        }
    } elseif {$diagnose} {
        CheckCallLegality hir $e $target $normal $errors {} $enclosing
    }
    # A bare (unhandled) call's own effective errors are not absorbed here --
    # they propagate straight through to whatever encloses this expression,
    # exactly like a direct `fail` (item 30-32): merge them into this walk's
    # own ctx.errors so an *enclosing* call site (this whole function, when
    # it is itself analyzed as an exact callee under analyzeBlock) sees them
    # as part of ITS own possible completions too.
    MergeErrors ctx $errors
    if {$incomplete} {
        dict set ctx incomplete 1
    }
    if {!$normal} {
        return never
    }
    set result [hir::range::ConstrainType $hir $e $resultRange]
    dict set ctx exprs $e $result
    if {$diagnose} {
        dict set hir exprs $e resultRangeFact $result
    }
    return $result
}

proc hir::completions::MergeErrors {ctxVar names} {
    upvar 1 $ctxVar ctx
    foreach name $names {
        dict set ctx errors $name 1
    }
}

# ARGEXPRS's own ExactValueOf facts, one per argument (item 22's exact-
# character-literal propagation is the motivating case, but this is general:
# any argument expression that is itself a literal `const`, or a `ref` to a
# binding this walk's own ctx.exact already established -- e.g. a small-
# literal-list element binding, EvalListloop -- carries its exact value
# across a further exact-block call boundary the same way argRanges already
# carries an Int Range across it).
proc hir::completions::ArgExactValues {hir ctx argExprs} {
    set values {}
    foreach a $argExprs {
        lappend values [ExactValueOf $hir $ctx $a]
    }
    return $values
}

# ARGEXPRS's own LiteralListOf facts, one per argument -- the List-typed
# counterpart of ArgExactValues above (items 36-40): "" for no fact, so an
# empty literal argument (`{list}`) reaches the callee's parameter as the
# empty List, never as an unknown one.
proc hir::completions::ArgExactLists {hir ctx argExprs} {
    set values {}
    foreach a $argExprs {
        lappend values [LiteralListOf $hir $ctx $a]
    }
    return $values
}

# The effective completion facts of a call to TARGET (an exact block) under
# ARGRANGES/ARGEXACT/ARGEXACTLISTS/ARGCALLABLES: {normal 0|1 errors NAME-LIST
# resultRange Range incomplete 0|1}. Recurses via analyzeBlock (item 33),
# guarded against cycles (item 34) and bounded by hir::completions::
# maxAnalyses (item 35) and maxDepth. This is the function-instance boundary of the
# header: an incomplete analysis keeps every error TARGET declares.
proc hir::completions::EffectiveFacts {hirVar ctxVar target argRanges argExact argExactLists argCallables guard {captureFacts {}}} {
    upvar 1 $hirVar hir $ctxVar ctx
    variable maxAnalyses
    variable maxDepth
    variable cache
    set declared [hir::get $hir $target declaredErrors]
    if {[dict exists $hir coroutines thunks $target]} {
        # A coroutine's thunk (NativeCallFacts) declares nothing itself: its
        # contract is its root's.
        set declared [hir::coroutines::thunkErrors $hir $target]
    }
    if {[dict exists $guard $target]} {
        # Self/mutual recursion: never assume an error impossible because
        # analysis recursed (item 34) -- the conservative, always-sound
        # fallback is the callee's own full declared contract.
        return [Fallback $hir $target $declared $argCallables $captureFacts]
    }
    if {[dict size $guard] >= $maxDepth} {
        # The nesting bound (maxDepth): the same fallback, so a static call
        # chain of any length is analyzed without exhausting Tcl's stack.
        return [Fallback $hir $target $declared $argCallables $captureFacts]
    }
    if {[llength $argRanges] != [llength [hir::get $hir $target params]]} {
        # An arity mismatch (only reachable through raw core IR that
        # bypasses the surface parser's own arity checking -- the ordinary
        # (non-specialization) type-inference pass, hir/types.tcl's own
        # Call, deliberately still resolves TARGET as an exact callee here
        # even when arity disagrees, matching its own pre-existing
        # behavior). Not this pass's own concern to diagnose (the
        # interp/compile backends already raise CORE SEMANTIC ARITY for it
        # identically at run time); just never zip PARAMS against a
        # shorter/longer ARGRANGES (Tcl's own foreach silently pads the
        # shorter list with "", which is not a valid Range and would
        # corrupt every downstream ConstrainType/intersect call) -- fall
        # back to the same conservative contract a cycle/budget hit uses.
        return [Fallback $hir $target $declared $argCallables $captureFacts]
    }
    set key [list $target $argRanges $argExact $argExactLists $argCallables $captureFacts]
    if {[dict exists $cache $key]} {
        set sub [dict get $cache $key]
        return [list [dict get $sub normal] [dict get $sub errors] [dict get $sub result] [dict get $sub incomplete]]
    }
    set analyses [dict get $ctx analyses]
    if {$analyses >= $maxAnalyses} {
        # Proof budget exhausted (item 35): fall back conservatively, same
        # as a recursion cycle -- never reject a correct program merely
        # because precision ran out.
        return [Fallback $hir $target $declared $argCallables $captureFacts]
    }
    dict set ctx analyses [expr {$analyses + 1}]
    set sub [analyzeBlock $hir $target $argRanges $argExact $argExactLists $argCallables \
        [dict merge $guard [dict create $target 1]] $captureFacts]
    if {[dict get $sub incomplete]} {
        # The declared-contract fallback (header): the walk lost track of
        # some call, so what it proved impossible elsewhere in the body is
        # no longer a proof about the whole body -- every declared error
        # stays possible, beside what the lost call was charged. May-facts
        # only: `normal` stays what the walk proved.
        dict set sub errors [lsort -unique [concat [dict get $sub errors] $declared]]
    }
    dict set cache $key $sub
    return [list [dict get $sub normal] [dict get $sub errors] [dict get $sub result] [dict get $sub incomplete]]
}

# The facts of a call to TARGET (declaring DECLARED) that EffectiveFacts does
# not analyze -- a recursion cycle, an arity mismatch, an exhausted budget:
# the declared contract, which bounds a call that may complete normally.
# A Transparent target may also let through what its callable inputs carry:
# TARGET's own check (checkBlock) holds every other source of its body to
# its declared errors and charges its parameters and captures where they
# were passed, so what passes through beyond DECLARED is carried by the
# values its parameters (ARGCALLABLES) and captures (CAPTUREFACTS, else
# unknown) hold here (Carried). Charging the erased-callable contract makes
# it incomplete; a contract is a bound, as DECLARED is.
proc hir::completions::Fallback {hir target declared argCallables captureFacts} {
    set erased [ErasedErrors $hir]
    if {$erased eq {} || ![Transparent $hir $target]} {
        return [list 1 $declared [hir::range::unknown] 0]
    }
    set errors $declared
    set incomplete 0
    set facts {}
    foreach b [hir::get $hir $target params] f $argCallables {
        if {$b eq ""} break
        if {[CleanInput $hir $b]} {
            lappend facts [if {$f eq ""} {string cat "unknown"} else {set f}]
        }
    }
    foreach c [hir::get $hir $target captures] {
        if {[CleanInput $hir $c]} {
            lappend facts [dict getdef $captureFacts $c "unknown"]
        }
    }
    foreach f $facts {
        lassign [Carried $hir $f] carried lost
        set errors [concat $errors $carried]
        set incomplete [expr {$incomplete || $lost}]
    }
    return [list 1 [lsort -unique $errors] [hir::range::unknown] $incomplete]
}

# What a value with callable fact FACT may raise when a callee calls it:
# {ERRORS LOST}, LOST 1 when that is the erased-callable contract.
proc hir::completions::Carried {hir fact} {
    switch -- [lindex $fact 0] {
        clean { return {{} 0} }
        contract {
            # What it may do with the arguments its caller gives it is the
            # erased-callable contract's, unless no argument can reach it
            # unchecked (ContractChannel).
            if {[ContractChannel [lindex $fact 2]]} {
                return [list [lsort -unique [concat [lindex $fact 1] [ErasedErrors $hir]]] 1]
            }
            return [list [lindex $fact 1] 0]
        }
        block {
            set b [lindex $fact 1]
            set errors [hir::get $hir $b declaredErrors]
            if {[Transparent $hir $b]} {
                return [list [concat $errors [ErasedErrors $hir]] 1]
            }
            return [list $errors 0]
        }
        native {
            if {[catch {core::native::metadata [lindex $fact 1]} meta]} {
                return {{} 0}
            }
            return [list [dict get $meta errors] 0]
        }
    }
    return [list [ErasedErrors $hir] 1]
}

# The errors of a trait operation's call (EvalCall): its requirement
# CONTRACT's, plus -- when the implementation's facts are INCOMPLETE -- the
# effective ERRORS that include what an erased callable may raise through it.
proc hir::completions::TraitCallErrors {contract errors incomplete} {
    set result [hir::types::FnErrors $contract]
    if {$incomplete} {
        set result [lsort -unique [concat $result $errors]]
    }
    return $result
}

# The completion facts of call E whose callee CALLEE (static type
# CALLEETYPE) is not an exact target -- a structural function type, a
# coroutine handle, or an uncontracted value -- under ARGEXPRS/ARGRANGES:
# {HOW ERRORS}, HOW `structural` (a contract bounds it: ERRORS) or `opaque`
# (an uncontracted callee charged ERRORS), or `none` (an uncontracted callee
# charged nothing: no fact says it may raise). A structural callee always may
# complete normally, an opaque one is never charged a must-fact.
#
# A structural Fn callee (header, "Precision and the erased-callable
# contract") is bounded by its contract whatever its callable fact: an exact
# closure's effective errors under these arguments (its body analyzed: the
# recovery a structural type hides) or a narrower contract may narrow it,
# never widen it, and the erased-callable contract never reaches it. An
# uncontracted callee is charged by its fact: an exact closure's effective
# errors, an exact native's declared errors or a contract's (plus what an
# argument it may call carries, ArgChannel), nothing for a clean value, and
# the erased-callable contract for an unknown one, which makes the walk
# incomplete. With an empty erased-callable contract no fact can matter.
proc hir::completions::IndirectFacts {hirVar ctxVar diagnose guard e callee calleeType argExprs argRanges {argFacts ""}} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {[hir::types::IsCoroutine $calleeType]} {
        return [list structural [hir::types::CoroutineErrors $calleeType]]
    }
    set erased [ErasedErrors $hir]
    if {[hir::types::IsFn $calleeType]} {
        set contract [hir::types::FnErrors $calleeType]
        if {$erased eq {}} {
            return [list structural $contract]
        }
        set errors $contract
        set fact [CallableFact $hir $ctx $callee]
        switch -- [lindex $fact 0] {
            block {
                lassign [Recover hir ctx $guard $callee [lindex $fact 1] $argExprs $argRanges $argFacts] sub incomplete
                set errors [Within $sub $contract]
                set excess [lmap name $sub {if {$name in $contract} {continue} else {set name}}]
                if {$diagnose && !$incomplete && $excess ne {}} {
                    # A complete analysis of the exact callable a contract
                    # was proven for, raising beyond it: the boundary check
                    # and this walk disagree (an internal inconsistency, or
                    # a program already rejected). Recorded, never widened.
                    dict set hir exprs $e contractExcess $excess
                }
            }
            contract {
                set errors [Within [lindex $fact 1] $contract]
            }
        }
        return [list structural $errors]
    }
    if {$erased eq {}} {
        return {none {}}
    }
    set errors {}
    set fact [CallableFact $hir $ctx $callee]
    switch -- [lindex $fact 0] {
        block {
            lassign [Recover hir ctx $guard $callee [lindex $fact 1] $argExprs $argRanges $argFacts] errors incomplete
            if {$incomplete} {
                dict set ctx incomplete 1
            }
        }
        native - contract {
            # Its own errors, and what an argument it may call with a
            # caller's arguments of its own carries (ArgChannel): every
            # argument of a native's, those a contract's own contracts
            # type (ContractChannel).
            if {[lindex $fact 0] eq "native"} {
                set errors [lindex [Carried $hir $fact] 0]
                set channel *
            } else {
                set errors [lindex $fact 1]
                set channel [lindex $fact 2]
            }
            lassign [ArgChannel hir ctx $guard $channel $argExprs] carried lost
            set errors [lsort -unique [concat $errors $carried]]
            if {$lost} {
                dict set ctx incomplete 1
            }
        }
        unknown {
            set errors $erased
            dict set ctx incomplete 1
        }
    }
    return [list [expr {$errors eq {} ? "none" : "opaque"}] $errors]
}

# The recovery of a call through CALLEE, a value this walk knows is exactly
# block TARGET: the call analyzed as an exact call of TARGET under ARGEXPRS
# (ARGFACTS their callable facts, or "" to compute them) and the captures'
# facts when CALLEE is a closure this activation created. {ERRORS
# INCOMPLETE}: its possible errors only (never a must-fact: the call serves
# every value the callee may hold).
proc hir::completions::Recover {hirVar ctxVar guard callee target argExprs argRanges argFacts} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {$argFacts eq ""} {
        set argFacts [ArgCallables $hir $ctx $argExprs]
    }
    lassign [EffectiveFacts hir ctx $target $argRanges \
        [ArgExactValues $hir $ctx $argExprs] [ArgExactLists $hir $ctx $argExprs] \
        $argFacts $guard [CaptureFacts $hir $ctx $callee $target]] normal errors _ incomplete
    return [list $errors $incomplete]
}

# The names of NAMES that are in BOUND.
proc hir::completions::Within {names bound} {
    return [lsort -unique [lmap name $names {if {$name in $bound} {set name} else {continue}}]]
}

# Diagnoses call E (target TARGET, an exact block) under its own computed
# NORMAL/ERRORS: item 18-20/50 (a call proven unable to complete normally is
# always a compile-time KNOWN-ERROR, independent of any handler -- checked
# first, before HANDLED is even consulted), else the ordinary legality rule
# (item 45): effectiveErrors(call) - handled(call) subseteq enclosing.
proc hir::completions::CheckCallLegality {hirVar e target normal errors handled enclosing} {
    upvar 1 $hirVar hir
    # Retained for later inspection (item 62/89 of STATIC-COMPLETION-
    # PROOFS.md: HIR/proof inspection tests, and useful input to the
    # later comprehensive generated-code audit) -- never read back by this
    # pass itself, and never consulted by any backend/codegen. (What code
    # generation does consume is the per-check bounds verdict of a native
    # call, NativeEffectiveFacts/BoundsProven, never these flat sets.)
    dict set hir exprs $e effectiveErrors [lsort -unique $errors]
    dict set hir exprs $e mayReturnNormally $normal
    if {!$normal} {
        set declared [hir::get $hir $target declaredErrors]
        if {$errors eq {}} {
            set cited $declared
        } else {
            set cited $errors
        }
        hir::Diagnose hir KNOWN-ERROR [format \
            {this call can never complete normally under the facts proven for its arguments here -- it always produces %s; a handler does not make a statically known failure legal} \
            [ErrorsPhrase $cited]] $e
        return
    }
    set unhandled [Unhandled $errors $handled $enclosing]
    if {$unhandled ne ""} {
        hir::Diagnose hir UNHANDLED-ERROR [format \
            {this call may produce %s, which %s neither handled here nor admitted by the enclosing function's own "errors" declaration} \
            [UnhandledPhrase $unhandled] [UnhandledVerb $unhandled]] $e
    }
}

# The errors of ERRORS neither HANDLED nor admitted by ENCLOSING, sorted: a
# call's whole unhandled set, which its one UNHANDLED-ERROR names
# (DIAGNOSTIC-RECOVERY.md) -- in the canonical order of every error set
# (effectiveErrors, a contract's `errors`).
proc hir::completions::Unhandled {errors handled enclosing} {
    return [lsort -unique [lmap name $errors {
        if {$name ni $handled && $name ni $enclosing} {set name} else {continue}
    }]]
}

# `the declared error "A"`, or `the declared errors "A", "B" and "C"`: the
# unhandled errors NAMES (Unhandled) as an UNHANDLED-ERROR message names them.
proc hir::completions::UnhandledPhrase {names} {
    set quoted [lmap name $names {string cat \" $name \"}]
    if {[llength $quoted] == 1} {
        return "the declared error [lindex $quoted 0]"
    }
    return "the declared errors [join [lrange $quoted 0 end-1] {, }] and [lindex $quoted end]"
}

# "is" or "are", for the unhandled errors NAMES.
proc hir::completions::UnhandledVerb {names} {
    return [expr {[llength $names] == 1 ? "is" : "are"}]
}

# The legality of projection E (NODE), a read of a C floating field through
# a native view or edit (C-FLOAT-FFI-MILESTONE-1.md): its NonFiniteFloat
# must be admitted by the enclosing function's own "errors" declaration
# (ENCLOSING) -- a projection has no handler of its own.
proc hir::completions::CheckFloatReadLegality {hirVar e node enclosing} {
    upvar 1 $hirVar hir
    set unhandled [Unhandled NonFiniteFloat {} $enclosing]
    if {$unhandled eq ""} {
        return
    }
    hir::Diagnose hir UNHANDLED-ERROR [format \
        {this read of the C floating field "%s" through %s may produce %s -- native memory may hold a NaN or an infinity, which no Float64 is -- which %s not admitted by the enclosing function's own "errors" declaration (a field read has no handler of its own: read it in a function that declares the error, or copy the record with std::binary::load, a call a handler may follow)} \
        [dict get $node name] [hir::types::show [hir::typeOf $hir [dict get $node receiver]]] \
        [UnhandledPhrase $unhandled] [UnhandledVerb $unhandled]] $e
}

# CheckCallLegality for call E through a structural function type
# CALLEETYPE: its whole declared error set ERRORS is effective (a structural
# callee always may complete normally), so the one legality rule is
# ERRORS - HANDLED subseteq ENCLOSING.
proc hir::completions::CheckStructuralCallLegality {hirVar e calleeType errors handled enclosing} {
    upvar 1 $hirVar hir
    dict set hir exprs $e effectiveErrors [lsort -unique $errors]
    dict set hir exprs $e mayReturnNormally 1
    set unhandled [Unhandled $errors $handled $enclosing]
    if {$unhandled eq ""} {
        return
    }
    if {[hir::types::IsCoroutine $calleeType]} {
        hir::Diagnose hir UNHANDLED-ERROR [format \
            {this coroutine resume may produce %s, which %s neither handled here nor admitted by the enclosing function's own "errors" declaration} \
            [UnhandledPhrase $unhandled] [UnhandledVerb $unhandled]] $e
        return
    }
    hir::Diagnose hir UNHANDLED-ERROR [format \
        {this call through a callable of function type %s may produce %s, which %s neither handled here nor admitted by the enclosing function's own "errors" declaration} \
        [hir::types::show $calleeType] [UnhandledPhrase $unhandled] [UnhandledVerb $unhandled]] $e
}

# The legality of call E whose callee (static type CALLEETYPE) is not an
# exact target, charged ERRORS (IndirectFacts): a structural callee is
# charged within its contract (CheckStructuralCallLegality); any error of an
# uncontracted callee is what its callable fact added -- the callable it
# holds, or an erased callable that may reach this call.
proc hir::completions::CheckIndirectCallLegality {hirVar e calleeType errors handled enclosing} {
    upvar 1 $hirVar hir
    if {[hir::types::IsFn $calleeType] || [hir::types::IsCoroutine $calleeType]} {
        CheckStructuralCallLegality hir $e $calleeType $errors $handled $enclosing
        return
    }
    dict set hir exprs $e effectiveErrors [lsort -unique $errors]
    dict set hir exprs $e mayReturnNormally 1
    set unhandled [Unhandled $errors $handled $enclosing]
    if {$unhandled ne ""} {
        hir::Diagnose hir UNHANDLED-ERROR [format \
            {this call through a callable value the completion analysis cannot identify, and that no callable contract bounds, may produce %s (this program passes a callable that declares %s through an untyped parameter, and such a callable may reach this call), which %s neither handled here nor admitted by the enclosing function's own "errors" declaration} \
            [UnhandledPhrase $unhandled] [expr {[llength $unhandled] == 1 ? "it" : "one of them"}] \
            [UnhandledVerb $unhandled]] $e
    }
}

# CheckCallLegality for a call of the root native NAME whose effective
# errors under this call's facts are ERRORS (NativeEffectiveFacts: the
# native's declared -errors, minus what the call's arguments rule out), and
# which may complete normally iff NORMAL: a call that never can is
# KNOWN-ERROR whatever handles it (CheckCallLegality's rule), else
# ERRORS - HANDLED subseteq ENCLOSING.
proc hir::completions::CheckNativeCallLegality {hirVar e name normal errors handled enclosing} {
    upvar 1 $hirVar hir
    dict set hir exprs $e effectiveErrors [lsort -unique $errors]
    dict set hir exprs $e mayReturnNormally $normal
    # A coroutine segment is named as the operation it is written as, a
    # floating-point operator as the operator of its type
    # (hir/operators.tcl), an extern c fn by its Botlish name (C-FFI.md).
    set extern [dict get [core::native::metadata $name] extern]
    set call $e
    if {[hir::kind $hir $e] eq "handle"} {
        set call [dict get $hir exprs $e call]
    }
    if {[dict exists $hir exprs $call resolvedOperator]} {
        lassign [dict get $hir exprs $call resolvedOperator] op type
        set what [format {%s "%s"} $type [if {$op eq "neg"} {string cat "-"} else {set op}]]
        set known $what
    } elseif {$extern ne ""} {
        set what [format {call of "%s"} [dict get $extern key]]
        set known $what
    } else {
        set what [switch -- $name {
            coroutine#start { expr {"coroutine construction"} }
            coroutine#resume { expr {"coroutine resume"} }
            default { format {call of "%s"} $name }
        }]
        set known [format {call of "%s"} $name]
    }
    if {!$normal} {
        hir::Diagnose hir KNOWN-ERROR [format \
            {this %s can never complete normally under the facts proven for its arguments here -- it always produces %s; a handler does not make a statically known failure legal} \
            $known [ErrorsPhrase $errors]] $e
        return
    }
    set unhandled [Unhandled $errors $handled $enclosing]
    if {$unhandled ne ""} {
        hir::Diagnose hir UNHANDLED-ERROR [format \
            {this %s may produce %s, which %s neither handled here nor admitted by the enclosing function's own "errors" declaration} \
            $what [UnhandledPhrase $unhandled] [UnhandledVerb $unhandled]] $e
    }
}

# {normal 0|1 errors NAMES verdicts}: the call-specific completion facts of
# a call of the root native NAME (argument expressions ARGEXPRS, their Ranges
# ARGRANGES here). A native's declared -errors are all effective, except
# for the natives whose errors depend only on their arguments, as their
# registered -bounds (core/native.tcl) state: an indexed access (`index`:
# std::list::at, std::mutable_array::at, std::mutable_array::set), whose IndexNotFound
# IndexBounds proves impossible (the index always designates an element: no
# obligation) or certain (it never does: the call cannot complete normally,
# KNOWN-ERROR), and a slicing native (`slices`), whose LowerUnderrun/
# UpperOverrun SliceFacts rules out one by one or proves certain -- the
# three-way rule STATIC-COMPLETION-PROOFS.md established for exact calls,
# applied to native errors that are functions of their arguments. Anything
# unproven keeps the declared error.
#
# VERDICTS has one element per registered bounds check, in registration
# order (one for `index`, one per SLICE for `slices`): the declared errors
# that check may still produce here ({} = proven never to fail). It is
# what a code generator may rely on (BoundsVerdictsOf), kept per check
# because two checks of one call can raise the same declared error name
# (a native with two slices): the call's flat `errors` cannot say which
# check an error comes from. {} for a native without bounds.
# The declared errors call E of the root native NAME may complete with: the
# native's registered -errors -- or, for a native that completes with what
# the Botlish code it runs leaves unhandled (core/native.tcl's -completion: a
# coroutine segment, COROUTINES.md), the call's own calleeErrors, which type
# inference took from the coroutine handle's type (hir/types.tcl's Call).
proc hir::completions::NativeDeclaredErrors {hir e name} {
    set meta [core::native::metadata $name]
    if {[dict get $meta completion]} {
        return [dict getdef $hir exprs $e calleeErrors {}]
    }
    return [LayoutCallErrors $hir $name [dict get $hir exprs $e args] [dict get $meta errors]]
}

# ERRORS (native NAME's registered errors) as call ARGEXPRS charges them: a
# layout operation's NonFiniteFloat only where the representation it reads
# or writes holds a C floating value that can fail (hir::layouts::
# CallErrors, C-FLOAT-FFI-MILESTONE-1.md).
proc hir::completions::LayoutCallErrors {hir name argExprs errors} {
    if {"NonFiniteFloat" ni $errors} {
        return $errors
    }
    return [hir::layouts::CallErrors $hir $name $argExprs [lmap a $argExprs {hir::typeOf $hir $a}] $errors]
}

# NativeEffectiveFacts for call E. A coroutine segment (start, resume) may
# complete with what its coroutine's whole computation may: the effective
# facts of its thunk (EffectiveFacts, as for an exact call: the root call
# under its captured arguments), whose errors are what any one segment can
# leave unhandled. A segment may always complete normally (it may yield).
# A handle whose construction is not found keeps the declared errors.
proc hir::completions::NativeCallFacts {hirVar ctxVar guard e name argExprs argRanges} {
    upvar 1 $hirVar hir $ctxVar ctx
    set from [dict get [core::native::metadata $name] errorsFrom]
    if {$from ne ""} {
        # A native calling a callable argument (std::mutable_array::generate's
        # factory): it may complete normally, or with what the callable's
        # contract permits (the call's calleeErrors, hir/types.tcl's Call)
        # -- and with an erased-callable contract, with what the callable's
        # fact adds (IndirectFacts: a closure analyzed, an unknown value
        # charged the erased-callable contract). A factory of structural Fn
        # type is bounded by its contract, already in calleeErrors: its fact
        # ({contract ERRORS}, or a closure within it) adds nothing outside.
        set errors [NativeDeclaredErrors $hir $e $name]
        if {[ErasedErrors $hir] ne {} && $from < [llength $argExprs]} {
            set factory [lindex $argExprs $from]
            set fact [CallableFact $hir $ctx $factory]
            if {[lindex $fact 0] eq "block"} {
                set block [lindex $fact 1]
                set n [llength [hir::get $hir $block params]]
                lassign [IndirectFacts hir ctx 0 $guard $e $factory [hir::typeOf $hir $factory] \
                    {} [lrepeat $n [hir::range::unknown]] [lrepeat $n clean]] how extra
            } else {
                lassign [IndirectFacts hir ctx 0 $guard $e $factory any {} {}] how extra
            }
            set errors [lsort -unique [concat $errors $extra]]
        }
        return [list 1 $errors {}]
    }
    if {[dict get [core::native::metadata $name] completion]} {
        set thunk [hir::coroutines::thunkOfHandle $hir [lindex $argExprs 0]]
        if {$thunk eq ""} {
            return [list 1 [NativeDeclaredErrors $hir $e $name] {}]
        }
        lassign [EffectiveFacts hir ctx $thunk {} {} {} {} $guard] normal errors _ incomplete
        if {$incomplete} {
            dict set ctx incomplete 1
        }
        return [list 1 $errors {}]
    }
    return [NativeEffectiveFacts $hir $ctx $name $argExprs $argRanges]
}

proc hir::completions::NativeEffectiveFacts {hir ctx name argExprs argRanges} {
    set meta [core::native::metadata $name]
    set errors [LayoutCallErrors $hir $name $argExprs [dict get $meta errors]]
    set bounds [dict get $meta bounds]
    set verdicts {}
    if {[dict get $meta fold] ne {}} {
        # A native whose errors are functions of its argument values alone,
        # decided by its fold when every argument is exactly known (FoldCall):
        # it cannot fail (no obligation), or it always fails (KNOWN-ERROR) --
        # the three-way rule, for an operation such as Float64 division
        # (FLOAT64-MILESTONE-1.md). One check: its verdict is what may still
        # fail.
        set decided [FoldCall $hir $ctx $name $argExprs]
        switch -- [lindex $decided 0] {
            value { return [list 1 {} {{}}] }
            error { return [list 0 [list [lindex $decided 1]] [list [list [lindex $decided 1]]]] }
        }
        return [list 1 $errors [list $errors]]
    }
    if {"NonFiniteFloat" in $errors && [hir::layouts::Role $name] ne ""} {
        # A Float64 written into one C floating field or element
        # (C-FLOAT-FFI-MILESTONE-1.md): a value this walk knows exactly is
        # narrowed by the boundary's own rule (core::cabi::Narrow), so the
        # write cannot fail through it (its other errors stay), or always
        # does (KNOWN-ERROR).
        set at [hir::layouts::RoleOf [hir::layouts::Role $name] value]
        set format [hir::layouts::WrittenFloatFormat $hir $name $argExprs [lmap a $argExprs {hir::typeOf $hir $a}]]
        set v [if {$at eq "" || $format eq ""} {string cat ""} else {ExactValueOf $hir $ctx [lindex $argExprs $at]}]
        if {$v ne {} && [core::type::isFloat [core::value::kind $v]]} {
            if {[lindex [core::cabi::Narrow $format [core::value::floatOf $v]] 0] ne "ok"} {
                return [list 0 {NonFiniteFloat} {}]
            }
            set errors [lsearch -all -inline -not -exact $errors NonFiniteFloat]
        }
    }
    if {[core::native::isExtern $name] && "NonFiniteFloat" in $errors} {
        # A C call with a C floating result or a C float parameter
        # (C-FLOAT-FFI-MILESTONE-1.md): a float argument this walk knows
        # exactly is narrowed by the boundary's own rule (core::cabi::
        # Narrow, what a run computes): one that rounds to an infinity makes
        # the call fail before C runs (KNOWN-ERROR); when every one narrows
        # to a finite float and C returns no floating value, the call cannot
        # fail with NonFiniteFloat at all. A floating result is C's, never
        # known: it may always be NaN or an infinity.
        switch -- [ExternNarrowing $hir $ctx $name $argExprs] {
            out { return [list 0 {NonFiniteFloat} {}] }
            in {
                set result [dict get [core::native::metadata $name] extern abi result]
                if {$result ni {f32 f64}} {
                    return [list 1 [lsearch -all -inline -not -exact $errors NonFiniteFloat] {}]
                }
            }
        }
    }
    switch -- [lindex $bounds 0] {
        index {
            lassign $bounds _ family c i
            set verdicts [list $errors]
            if {[llength $argExprs] > max($c, $i)} {
                switch -- [IndexBounds $hir $ctx $family [lindex $argExprs $c] [lindex $argExprs $i] [lindex $argRanges $i]] {
                    in  { return [list 1 [lsearch -all -inline -not -exact $errors IndexNotFound] {{}}] }
                    out { return [list 0 [list IndexNotFound] $verdicts] }
                }
            }
        }
        slices {
            set verdicts [lrepeat [llength [lrange $bounds 1 end]] $errors]
            set slices [Slices $hir $ctx [lrange $bounds 1 end] $argExprs $argRanges]
            if {$slices ne {}} {
                return [SliceFacts $hir $ctx $slices]
            }
        }
        extents {
            # A whole fixed array written from a List (FIXED-LAYOUT-
            # ARRAYS.md): LayoutExtentMismatch only when some array it
            # writes is not proven to get exactly its extent -- and
            # certainly when a List's length is proven to be another.
            set verdicts [list [list LayoutExtentMismatch]]
            switch -- [ExtentsVerdict $hir $ctx $name $argExprs [lindex $bounds 1]] {
                in  { return [list 1 [lsearch -all -inline -not -exact $errors LayoutExtentMismatch] {{}}] }
                out { return [list 0 [list LayoutExtentMismatch] $verdicts] }
            }
        }
    }
    return [list 1 $errors $verdicts]
}

# Whether every C float argument (ARGEXPRS) of a call of the extern c fn
# native NAME narrows to a finite float (core::cabi::Narrow, C-FLOAT-FFI-
# MILESTONE-1.md): `in` (every one is exactly known and does), `out` (one
# exactly known rounds to an infinity: the call fails before C is called)
# or "" (unknown).
proc hir::completions::ExternNarrowing {hir ctx name argExprs} {
    set abi [dict get [core::native::metadata $name] extern abi]
    set verdict in
    foreach i [hir::foreign::NarrowedParameters $abi] {
        set v [ExactValueOf $hir $ctx [lindex $argExprs $i]]
        if {$v eq {} || ![core::type::isFloat [core::value::kind $v]]} {
            set verdict ""
            continue
        }
        if {[lindex [core::cabi::Narrow binary32 [core::value::floatOf $v]] 0] ne "ok"} {
            return out
        }
    }
    return $verdict
}

# Whether every fixed array the value argument V of call ARGEXPRS of the
# layout operation NAME writes gets a List of exactly its extent
# (FIXED-LAYOUT-ARRAYS.md, the `extents` bounds of core/native.tcl): `in`
# (proven: no LayoutExtentMismatch), `out` (a List's length is proven to be
# another: the call always fails) or "" (unproven). The arrays are those of
# the field a write's designator names, or of the layout an emitted
# LayoutStruct's static type (or its elaborated descriptor) names -- none at
# all for an array-free layout or a scalar field, which is every program
# before fixed arrays. A malformed operand (diagnosed by hir::layouts::
# verify) is vacuously `in`: nothing runs.
proc hir::completions::ExtentsVerdict {hir ctx name argExprs v} {
    set role [hir::layouts::Role $name]
    set value [lindex $argExprs $v]
    if {$value eq ""} {
        return ""
    }
    set path [hir::layouts::RoleOf $role path]
    if {$path ne ""} {
        set field [hir::layouts::PathField [hir::layouts::ConstText $hir [lindex $argExprs $path]]]
        if {$field eq ""} {
            return in
        }
        set pointer [expr {[dict get $field kind] eq "pointer" || [hir::layouts::PointerArray $field]}]
        if {[hir::layouts::ReprUnionPath $field] ne "none"} {
            # (LAYOUT-UNION: an array of unions is never written whole.)
            return in
        }
        switch -- [hir::layouts::RoleOf $role op] {
            write {
                if {[hir::layouts::ReprPointerPath $field] ne "none"} {
                    # (LAYOUT-NATIVE-ONLY: the write never runs.)
                    return in
                }
            }
            write_foreign {
                if {!$pointer} {
                    # (LAYOUT-FOREIGN-WRITE: the write never runs.)
                    return in
                }
            }
        }
        return [ReprValueVerdict $hir $ctx $field $value]
    }
    set id ""
    set typed [hir::layouts::RoleOf $role typed]
    if {$typed ne ""} {
        set id [hir::layouts::OfType [hir::typeOf $hir [lindex $argExprs [lindex $typed 0]]]]
    } elseif {[hir::layouts::RoleOf $role operand] ne ""} {
        set id [hir::layouts::DescriptorLayout [hir::layouts::ConstText $hir [lindex $argExprs [hir::layouts::RoleOf $role operand]]]]
    }
    if {$id eq "" || ![hir::layouts::declared $id]} {
        return in
    }
    return [ReprValueVerdict $hir $ctx [dict create kind layout layout $id] $value]
}

# Whether the value expression E written as the representation REPR fills
# every fixed array in it exactly (in / out / "", ExtentsVerdict): a scalar
# or pointer trivially; an array when the List's length is proven its
# extent (hir/cardinality.tcl's size form: an exactly known List, a list
# literal, a collecting loop of an exactly known count -- or a size an
# enclosing branch proved, ctx.sizes) and, if its elements hold arrays
# themselves, E is a list literal each of whose elements is proven; a layout
# with arrays when E is (an alias of) a construction of its LayoutStruct
# each of whose array fields is proven -- and any representation when E is
# an exact copy of the same one (ExactCopy: what std::binary::load or
# std::binary::parse made, or a field of it). `out` when one of those lengths is
# proven to be another. Nothing else: the length of a List is a fact about
# the List, never about its type.
proc hir::completions::ReprValueVerdict {hir ctx repr e} {
    set copy [ExactCopy $hir $e]
    if {$copy ne "" && [hir::layouts::ReprText $copy] eq [hir::layouts::ReprText $repr]} {
        return in
    }
    switch -- [dict get $repr kind] {
        array {
            set steps 0
            set form [hir::cardinality::ListLength $hir $e steps]
            set n ""
            if {[hir::cardinality::IsConst $form]} {
                set n [lindex $form 0]
            } elseif {[dict exists $ctx sizes $form]} {
                set n [dict get $ctx sizes $form]
            } else {
                # The length the value's own static type states (a refined
                # List, a guard's refinement: LIST-CARDINALITY-
                # REFINEMENTS.md).
                set n [hir::cardinality::TypedLength $hir $e]
            }
            if {$n eq ""} {
                return ""
            }
            if {$n != [dict get $repr extent]} {
                return out
            }
            set element [dict get $repr element]
            if {![hir::layouts::ReprHasArrays $element]} {
                return in
            }
            lassign [hir::cardinality::Chase $hir $e steps] kind id
            if {$kind ne "expr" || [hir::cardinality::NativeName $hir [dict get $hir exprs $id]] ne "list"} {
                return ""
            }
            return [AllVerdicts [lmap item [dict get $hir exprs $id args] {
                ReprValueVerdict $hir $ctx $element $item
            }]]
        }
        layout {
            set id [dict get $repr layout]
            if {![hir::layouts::HasArrays $id]} {
                return in
            }
            set steps 0
            lassign [hir::cardinality::Chase $hir $e steps] kind x
            if {$kind ne "expr"} {
                return ""
            }
            set node [dict get $hir exprs $x]
            if {[dict get $node kind] ne "struct" || ![dict get $node named]
                    || [dict get $node structId] ne [hir::layouts::structId $id]} {
                return ""
            }
            set verdicts {}
            foreach field [dict get [hir::layouts::entry $id] fields] {
                if {![hir::layouts::ReprHasArrays $field]} continue
                set i [lsearch -exact [dict get $node names] [dict get $field name]]
                if {$i < 0} {
                    # (MISSING-FIELD, diagnosed by the construction's check.)
                    return in
                }
                lappend verdicts [ReprValueVerdict $hir $ctx $field [lindex [dict get $node fields] $i]]
            }
            return [AllVerdicts $verdicts]
        }
    }
    # (A scalar or a pointer; a union is never written whole: LAYOUT-UNION.)
    return in
}

# The representation the value of expression E is an exact copy of, or "":
# a List or LayoutStruct std::binary::load copied out of live memory (its
# operand's static type says what: NativeView[array N of E] or
# NativeView[L], an edit alike), a LayoutStruct std::binary::parse imprinted (its
# layout operand), or a field of one of those (the field's representation),
# followed through immutable bindings and handlers that never complete. Every fixed array in such a value has
# exactly its extent: the copy made it so, and a value never changes.
proc hir::completions::ExactCopy {hir e} {
    set steps 0
    lassign [hir::cardinality::Chase $hir $e steps] kind id
    if {$kind ne "expr"} {
        return ""
    }
    set node [dict get $hir exprs $id]
    switch -- [dict get $node kind] {
        project {
            set base [ExactCopy $hir [dict get $node receiver]]
            if {$base eq "" || [dict get $base kind] ne "layout"} {
                return ""
            }
            foreach field [dict get [hir::layouts::entry [dict get $base layout]] fields] {
                if {[dict get $field name] eq [dict get $node name]} {
                    return $field
                }
            }
        }
        handle {
            # A handled call whose handlers all leave (return, fail, ...)
            # completes only with the call's own value. A handler body is a
            # sequence: its last expression is the one that completes it.
            foreach body [dict get $node handlerBodies] {
                set last [lindex $body end]
                if {![hir::types::Halts $hir $last [hir::typeOf $hir $last]]} {
                    return ""
                }
            }
            return [ExactCopy $hir [dict get $node call]]
        }
        call {
            set role [hir::layouts::Role [hir::cardinality::NativeName $hir $node]]
            set args [dict get $node args]
            if {[hir::layouts::RoleOf $role viewed] ne ""} {
                set type [hir::typeOf $hir [lindex $args 0]]
                set term [hir::layouts::OfArrayType $type]
                if {$term ne ""} {
                    return [hir::layouts::ReprOfTerm $term]
                }
                if {[hir::types::IsNativeMemory $type] && [hir::layouts::declared [lindex $type 1]]
                        && ![hir::layouts::IsUnion [lindex $type 1]]} {
                    return [dict create kind layout layout [lindex $type 1]]
                }
            } elseif {[hir::layouts::RoleOf $role op] eq "parse"} {
                set operand [lindex $args [hir::layouts::RoleOf $role operand]]
                set layout [hir::layouts::DescriptorLayout [hir::layouts::ConstText $hir $operand]]
                if {$layout ne "" && [hir::layouts::declared $layout] && ![hir::layouts::IsUnion $layout]} {
                    return [dict create kind layout layout $layout]
                }
            } elseif {[hir::layouts::RoleOf $role op] eq "read"} {
                # One designated representation copied out of bytes
                # (std::binary::read, LAYOUT-UNIONS.md): exactly its arrays'
                # extents, as a parse makes them.
                set repr [hir::layouts::PathField [hir::layouts::ConstText $hir [lindex $args [hir::layouts::RoleOf $role path]]]]
                if {$repr ne ""} {
                    return $repr
                }
            }
        }
    }
    return ""
}

# The verdict of several checks that all must hold: `out` if one is, `in`
# if every one is, else "".
proc hir::completions::AllVerdicts {verdicts} {
    if {"out" in $verdicts} {
        return out
    }
    foreach v $verdicts {
        if {$v ne "in"} {
            return ""
        }
    }
    return in
}

# ---------------------------------------------------------------------------
# Slices (core::native::checkSlice, STDLIB-NAMESPACES.md)
#
# A slice START..END of a sequence of N elements is valid iff 0 <= START <=
# END <= N; checked START first (against 0..N), then END (against
# START..N), below its interval is LowerUnderrun, above it UpperOverrun.
# Operands are {form F range R}: a hir/cardinality.tcl linear form and this
# walk's Range for the same Int.

# The slices SPECS (a native's registered `slices` bounds, core/native.tcl)
# a call checks, in the order it checks them, as {sizes SIZES start OPERAND
# end OPERAND} (SIZES: SizesOf), or "" for a call of an unexpected shape.
proc hir::completions::Slices {hir ctx specs argExprs argRanges} {
    set slices {}
    foreach spec $specs {
        lassign $spec family c start end
        set operands {}
        foreach operand [list $start $end] {
            switch -- [lindex $operand 0] {
                const {
                    set k [lindex $operand 1]
                    lappend operands [dict create form [hir::cardinality::FormConst $k] range [hir::range::point $k]]
                }
                sum {
                    lassign $operand _ a b
                    if {[llength $argExprs] <= max($a, $b)} {
                        return ""
                    }
                    lappend operands [OperandSum \
                        [Operand $hir [lindex $argExprs $a] [lindex $argRanges $a]] \
                        [Operand $hir [lindex $argExprs $b] [lindex $argRanges $b]]]
                }
                default {
                    if {[llength $argExprs] <= $operand} {
                        return ""
                    }
                    lappend operands [Operand $hir [lindex $argExprs $operand] [lindex $argRanges $operand]]
                }
            }
        }
        if {[llength $argExprs] <= $c} {
            return ""
        }
        lappend slices [dict create sizes [SizesOf $hir $ctx $family [lindex $argExprs $c]] \
            start [lindex $operands 0] end [lindex $operands 1]]
    }
    return $slices
}

proc hir::completions::Operand {hir e range} {
    set steps 0
    return [dict create form [hir::cardinality::IntForm $hir $e steps] range $range]
}

proc hir::completions::OperandSum {a b} {
    set ra [dict get $a range]
    set rb [dict get $b range]
    if {$ra eq {never} || $rb eq {never}} {
        set range never
    } else {
        set range [dict create min [hir::range::AddBound [dict get $ra min] [dict get $rb min]] \
            max [hir::range::AddBound [dict get $ra max] [dict get $rb max]]]
    }
    return [dict create form [hir::cardinality::FormAdd [dict get $a form] [dict get $b form]] range $range]
}

# The size of the sequence CONTAINER (FAMILY list, mutarray or str) as
# {forms FORMS known N}: FORMS its size forms (the structural one
# hir/cardinality.tcl derives, plus the constant of an exactly known size),
# N the exactly known size or "" -- known from a literal or exact value, an
# exact argument of this call-specific walk, or an enclosing branch's
# `std::list::length(xs) == N`-shaped equality (ctx.sizes). Two known sizes that
# disagree mean the facts contradict each other: N is then "contradiction".
proc hir::completions::SizesOf {hir ctx family container} {
    set steps 0
    switch -- $family {
        list     { set size [hir::cardinality::ListLength $hir $container steps] }
        mutarray { set size [hir::cardinality::Capacity $hir $container steps] }
        str      { set size [hir::cardinality::StrLength $hir $container steps] }
    }
    set forms [list $size]
    if {$family eq "list"} {
        set literal [LiteralListOf $hir $ctx $container]
        if {$literal ne {}} {
            lappend forms [hir::cardinality::FormConst [llength [LiteralElements $literal]]]
        }
        # The length the read's own static type states (a guard's
        # refinement of it: hir/cardinality.tcl's TypedLength).
        set typed [hir::cardinality::TypedLength $hir $container]
        if {$typed ne {}} {
            lappend forms [hir::cardinality::FormConst $typed]
        }
    } elseif {$family eq "str"} {
        set v [ExactValueOf $hir $ctx $container]
        if {$v ne {} && [core::value::kind $v] eq "str"} {
            lappend forms [hir::cardinality::FormConst [string length [core::value::strOf $v]]]
        }
    }
    set known {}
    foreach form $forms {
        if {[hir::cardinality::IsConst $form]} {
            lappend known [lindex $form 0]
        } elseif {[dict exists $ctx sizes $form]} {
            lappend known [dict get $ctx sizes $form]
        }
    }
    set known [lsort -unique -integer $known]
    if {[llength $known] > 1} {
        return [dict create forms $forms known contradiction]
    }
    if {[llength $known] == 1} {
        lappend forms [hir::cardinality::FormConst [lindex $known 0]]
    }
    return [dict create forms [lsort -unique $forms] known [lindex $known 0]]
}

# 1 if operand A is provably >= 0: by its Range, by its form, or as a
# counted-loop variable (ctx.indexBounds: 0 <= i) plus nonnegative terms.
proc hir::completions::ProveNonNeg {ctx a} {
    set r [dict get $a range]
    if {$r ne {never} && [dict get $r min] ne "-inf" && [dict get $r min] >= 0} {
        return 1
    }
    set fa [dict get $a form]
    if {[hir::cardinality::NonNeg $fa]} {
        return 1
    }
    foreach {atom coeff} [lindex $fa 1] {
        if {[lindex $atom 0] eq "v" && $coeff == 1 && [dict exists $ctx indexBounds [lindex $atom 1]]
                && [hir::cardinality::NonNeg [hir::cardinality::FormAdd $fa [hir::cardinality::FormAtom $atom] -1]]} {
            return 1
        }
    }
    return 0
}

# 1 if operand A is provably <= the Int of form B (with Range BRANGE, or ""
# for none): by Ranges, by the forms' difference being nonnegative, or
# relationally -- A is a binding (plus a constant offset or other terms)
# that an enclosing counted loop (ctx.indexBounds) or `if` (ctx.upperBounds)
# proved below some form U, so A <= U - 1 + the rest.
proc hir::completions::ProveLe {ctx a b {brange ""}} {
    set ra [dict get $a range]
    if {$brange ne "" && $brange ne {never} && $ra ne {never}
            && [dict get $ra max] ne "+inf" && [dict get $brange min] ne "-inf"
            && [dict get $ra max] <= [dict get $brange min]} {
        return 1
    }
    set fa [dict get $a form]
    if {[hir::cardinality::NonNeg [hir::cardinality::FormAdd $b $fa -1]]} {
        return 1
    }
    lassign $fa c terms
    foreach {atom coeff} $terms {
        if {[lindex $atom 0] ne "v" || $coeff != 1} {
            continue
        }
        set binding [lindex $atom 1]
        set rest [hir::cardinality::FormAdd $fa [hir::cardinality::FormAtom $atom] -1]
        set uppers {}
        if {[dict exists $ctx indexBounds $binding]} {
            lappend uppers [dict get $ctx indexBounds $binding]
        }
        if {[dict exists $ctx upperBounds $binding]} {
            lappend uppers {*}[dict get $ctx upperBounds $binding]
        }
        foreach u $uppers {
            set bound [hir::cardinality::FormAdd [hir::cardinality::FormAdd $u $rest] [hir::cardinality::FormConst -1]]
            if {[hir::cardinality::NonNeg [hir::cardinality::FormAdd $b $bound -1]]} {
                return 1
            }
        }
    }
    return 0
}

# 1 if operand A is provably <= operand B.
proc hir::completions::ProveLeOperand {ctx a b} {
    return [ProveLe $ctx $a [dict get $b form] [dict get $b range]]
}

# 1 if operand A is provably <= the sequence size SIZES (SizesOf). A size
# form's Range is its constant, or at least an enclosing branch's minimum
# (ctx.minSizes: `if std::str::length(s) > 0:`).
proc hir::completions::ProveLeSize {ctx a sizes} {
    foreach form [dict get $sizes forms] {
        if {[hir::cardinality::IsConst $form]} {
            set range [hir::range::point [lindex $form 0]]
        } elseif {[dict exists $ctx minSizes $form]} {
            set range [dict create min [dict get $ctx minSizes $form] max +inf]
        } else {
            set range ""
        }
        if {[ProveLe $ctx $a $form $range]} {
            return 1
        }
    }
    return 0
}

# The largest minimum an enclosing branch proved for one of the size forms
# FORMS (ctx.minSizes), or "".
proc hir::completions::MinSizeOf {ctx forms} {
    set min ""
    foreach form $forms {
        if {[dict exists $ctx minSizes $form]} {
            set m [dict get $ctx minSizes $form]
            if {$min eq "" || $m > $min} {
                set min $m
            }
        }
    }
    return $min
}

# The errors one slice may fail with ({} when valid on every path), and the
# one it always fails with ("" when not provably certain): {possible
# certain}.
proc hir::completions::SliceVerdict {ctx slice} {
    set sizes [dict get $slice sizes]
    if {[dict get $sizes known] eq "contradiction"} {
        # Two proven sizes disagree: this path is unreachable.
        return [list {} {}]
    }
    set start [dict get $slice start]
    set end [dict get $slice end]
    set possible {}
    if {!([ProveNonNeg $ctx $start] && [ProveLeOperand $ctx $start $end])} {
        lappend possible LowerUnderrun
    }
    if {!([ProveLeSize $ctx $end $sizes]
            && ([ProveLeOperand $ctx $start $end] || [ProveLeSize $ctx $start $sizes]))} {
        lappend possible UpperOverrun
    }
    if {$possible eq {}} {
        return [list {} {}]
    }
    # Certain failure, from Ranges alone: the rule replayed on intervals.
    set n [dict get $sizes known]
    set rs [dict get $start range]
    set re [dict get $end range]
    if {$rs eq {never} || $re eq {never}} {
        return [list $possible {}]
    }
    lassign [list [dict get $rs min] [dict get $rs max] [dict get $re min] [dict get $re max]] smin smax emin emax
    if {$smax ne "+inf" && $smax < 0} {
        return [list $possible LowerUnderrun]
    }
    if {$n eq "" || $smin eq "-inf" || $smax eq "+inf"} {
        return [list $possible {}]
    }
    if {$smin > $n} {
        return [list $possible UpperOverrun]
    }
    if {$smin >= 0 && $smax <= $n} {
        # START always passes its check; END is then compared with START.
        if {$emax ne "+inf" && $emax < $smin} {
            return [list $possible LowerUnderrun]
        }
        if {$emin ne "-inf" && $emin >= $smax && $emin > $n} {
            return [list $possible UpperOverrun]
        }
    }
    return [list $possible {}]
}

# {normal errors verdicts} (NativeEffectiveFacts) of a call checking SLICES
# in order: the union of what each may fail with; a certain failure of the
# first slice that is not provably valid makes the call certain to fail
# with it. The verdicts are each slice's own possible errors (SliceVerdict),
# unaffected by what another slice proves.
proc hir::completions::SliceFacts {hir ctx slices} {
    set possible {}
    set certain {}
    set settled 0
    set verdicts {}
    foreach slice $slices {
        lassign [SliceVerdict $ctx $slice] p c
        lappend verdicts $p
        lappend possible {*}$p
        if {!$settled && $c ne ""} {
            set certain $c
        }
        if {$p ne {}} {
            set settled 1
        }
    }
    if {$certain ne ""} {
        return [list 0 [list $certain] $verdicts]
    }
    return [list 1 [lsort -unique $possible] $verdicts]
}

# Whether the Int index INDEX (Range INDEXRANGE) of an indexed access to
# CONTAINER (FAMILY list or mutarray) always designates an element (`in`),
# never does (`out`), or neither is proven (""). Two sources of proof, both
# from facts this program already establishes, never from a guess:
#
#   * a container of statically known size N -- a List whose elements are
#     exactly known (a literal, an exact fact through immutable bindings,
#     hir/exactvalue.tcl, or an exact list argument of this call-specific
#     walk), or a MutableArray allocated with an exactly known capacity --
#     against INDEXRANGE: in when it lies within 0..N-1, out when it lies
#     entirely outside (hir::exact::BoundsOf's own rule);
#   * relational: INDEX reads a counted-loop variable proven to satisfy
#     0 <= i < FORM (ctx.indexBounds, NoteIndexBound) and FORM is exactly
#     the container's own size form (hir/cardinality.tcl: std::list::length of
#     the same immutable List, or the capacity of the same MutableArray --
#     `loop i from 0 to std::list::length(xs): std::list::at(xs, i)`).
#
#   * branch relations (BranchRelations): INDEX reads a value an
#     enclosing `if` proved below the container's size form -- a binding,
#     or a computed local keyed by its defining expression (RelationKey) --
#     and INDEX's own Range is provably >= 0 (`if i < 0 or i >=
#     std::list::length(xs): ... else: std::list::at(xs, i)`, or the `and` form's then
#     branch; `j = i + 1` guarded the same way, then `std::list::at(xs, j)`); or the
#     container's size form was proven equal to an exact N (`if
#     std::list::length(bytes) == 1: std::list::at(bytes, 0)`), which the range check
#     above then uses.
#   * reduction (ReducedIndex): INDEX is (an alias of) `mod(X, SIZE)` or
#     `bit_and(X, SIZE - 1)` with SIZE the container's own size form
#     (`std::list::at(xs, h.mod(std::list::length(xs)))`).
#
# The relational proofs are tried first: an index they place in range is in
# range on every path that reaches the read, so if this walk's exact ranges
# also put it out of range, the two cannot both hold and the read is
# unreachable here (vacuously in).
#
# Nothing else is attempted: no other arithmetic on a bounded variable, no
# interprocedural parameter facts.
proc hir::completions::IndexBounds {hir ctx family container index indexRange} {
    set steps 0
    # The container's size as a form (structural: what hir/cardinality.tcl
    # derives from the expression itself), plus, in a call-specific walk,
    # the exact length of a List argument whose elements this walk knows
    # (ctx.exactList): either one may be what a loop bound was proven
    # against, and either one may be the constant the range check needs.
    if {$family eq "list"} {
        set size [hir::cardinality::ListLength $hir $container steps]
    } elseif {$family eq "narray"} {
        # A live fixed array (FIXED-LAYOUT-ARRAYS.md): its extent is its
        # static type's, a constant.
        set term [hir::layouts::OfArrayType [hir::typeOf $hir $container]]
        if {$term eq ""} {
            # (Not a live array: BINARY-OPERAND, hir::layouts::verify --
            # nothing runs, so the access is vacuously in range.)
            return in
        }
        set size [hir::cardinality::FormConst [lindex $term 1]]
    } elseif {$family eq "str"} {
        # A character index (std::str::char_at): checked against the String's
        # length in Unicode scalars, the size std::str::length's guards state.
        set size [hir::cardinality::StrLength $hir $container steps]
    } else {
        set size [hir::cardinality::Capacity $hir $container steps]
    }
    set sizes [list $size]
    if {$family eq "list"} {
        set literal [LiteralListOf $hir $ctx $container]
        if {$literal ne {}} {
            lappend sizes [hir::cardinality::FormConst [llength [LiteralElements $literal]]]
        }
        # The length the read's own static type states (a refined List,
        # a guard's refinement of it: LIST-CARDINALITY-REFINEMENTS.md).
        set typed [hir::cardinality::TypedLength $hir $container]
        if {$typed ne {}} {
            lappend sizes [hir::cardinality::FormConst $typed]
        }
    }
    set known {}
    foreach form $sizes {
        if {[hir::cardinality::IsConst $form]} {
            lappend known [lindex $form 0]
        } elseif {[dict exists $ctx sizes $form]} {
            lappend known [dict get $ctx sizes $form]
        }
    }
    set known [lsort -unique -integer $known]
    if {[llength $known] > 1} {
        # Two proven sizes disagree (a branch's `std::list::length(xs) == 2`
        # under this call's exact one-element xs): the facts cannot hold
        # together, so this code is unreachable on this path and the read
        # vacuously designates an element.
        return in
    }
    # A size an enclosing branch proved at least M (ctx.minSizes) that this
    # path also knows to be exactly N < M (`if std::list::length(xs) < 1: return
    # ...` under this call's exact empty xs) is the same contradiction: the
    # read is unreachable here.
    set min [MinSizeOf $ctx $sizes]
    if {$known ne "" && $min ne "" && [lindex $known 0] < $min} {
        return in
    }
    # Relational facts first: when they place the index below a size this
    # path also knows, the read designates an element -- and should the
    # range facts below say otherwise, the facts contradict each other, so
    # the path is unreachable and the read is vacuously in range.
    lassign [hir::cardinality::Chase $hir $index steps] kind binding
    if {$kind eq "binding" && [dict exists $ctx indexBounds $binding]
            && [dict get $ctx indexBounds $binding] in $sizes} {
        return in
    }
    set key [RelationKey $hir $index]
    if {$indexRange ne {never} && [dict exists $ctx upperBounds $key]
            && [dict get $indexRange min] ne "-inf" && [dict get $indexRange min] >= 0} {
        foreach form [dict get $ctx upperBounds $key] {
            if {$form in $sizes} {
                return in
            }
        }
    }
    # An index reduced into the container's own size by arithmetic
    # (ReducedIndex: mod by the size, bit_and with the size minus one). A
    # container of known size 0 is left to the range rule below: it has no
    # element, so a read of it that is reached is out -- and a read whose
    # index is reduced by that size 0 is never reached at all (mod fails
    # with ARITHMETIC first) -- so such a read stays KNOWN-ERROR, as it
    # always was, rather than becoming vacuously in.
    if {$kind eq "expr" && 0 ni $known && [ReducedIndex $hir $ctx $binding $sizes $known]} {
        return in
    }
    # A size an enclosing branch proved at least M (`if std::list::length(xs) >
    # 0:`) holds every index in 0..M-1.
    if {$min ne "" && $indexRange ne {never}} {
        set lo [dict get $indexRange min]
        set hi [dict get $indexRange max]
        if {$lo ne "-inf" && $hi ne "+inf" && $lo >= 0 && $hi < $min} {
            return in
        }
    }
    set n [lindex $known 0]
    if {$indexRange ne {never} && $n ne ""} {
        set lo [dict get $indexRange min]
        set hi [dict get $indexRange max]
        if {$lo ne "-inf" && $hi ne "+inf" && $lo >= 0 && $hi < $n} {
            return in
        }
        if {($hi ne "+inf" && $hi < 0) || ($lo ne "-inf" && $lo >= $n)} {
            return out
        }
        set exact [hir::range::ExactOf $indexRange]
        if {$exact ne ""} {
            set inside [lmap i $exact {if {$i >= 0 && $i < $n} {set i} else {continue}}]
            if {[llength $inside] == [llength $exact]} {
                return in
            }
            if {$inside eq ""} {
                return out
            }
        }
    }
    return ""
}

# 1 if the Int expression E -- the expression an index's alias chain ends at
# (hir::cardinality::Chase) -- is provably in 0..N-1, N the container size
# that each of the forms SIZES names (KNOWN: the sizes this path knows
# exactly, IndexBounds'), by one of two facts of integer arithmetic:
#
#   * mod(X, D) with D's form one of SIZES: mod is Euclidean
#     (core/primitives.tcl) and returns only when D != 0 -- D == 0 fails
#     with ARITHMETIC, which no handler catches -- with 0 <= r < |D|. D is
#     a size, so D >= 0 and r < D = N: `xs.at(h.mod(xs.length()))`.
#   * bit_and(X, M), in either operand order, with M + 1's form one of
#     SIZES and M >= 0: two's-complement AND of a nonnegative M keeps a
#     subset of M's bits, so 0 <= X & M <= M < N whatever X is (negative or
#     beyond any machine word). M >= 0 holds when the size is proven at
#     least 1 (an enclosing guard: ctx.minSizes, `if a.capacity() == 0:
#     return ...`; or a known size), when M's form is nonnegative
#     (hir::cardinality::NonNeg) or when M's Range in this walk is. No
#     power of two is assumed: a mask keeps any index in range, whatever
#     the size; a power of two only makes it reach every element. Without
#     M >= 0 nothing is proven: for N = 0 the mask is -1 and X & -1 = X.
#
# Both forms name immutable values (hir/cardinality.tcl), so D and M + 1
# are the container's size wherever the index is read. Nothing else is
# recognized: no other operation, no offset of a reduced index.
proc hir::completions::ReducedIndex {hir ctx e sizes known} {
    set node [dict get $hir exprs $e]
    set name [hir::cardinality::NativeName $hir $node]
    if {$name ni {mod bit_and} || [llength [dict get $node args]] != 2} {
        return 0
    }
    lassign [dict get $node args] x y
    if {$name eq "mod"} {
        set steps 0
        return [expr {[hir::cardinality::IntForm $hir $y steps] in $sizes}]
    }
    set min [MinSizeOf $ctx $sizes]
    set positive [expr {($min ne "" && $min >= 1) || ($known ne "" && [lindex $known 0] >= 1)}]
    foreach m [list $y $x] {
        set steps 0
        set form [hir::cardinality::IntForm $hir $m steps]
        if {[hir::cardinality::FormAdd $form [hir::cardinality::FormConst 1]] ni $sizes} {
            continue
        }
        set range [dict getdef $ctx exprs $m never]
        if {$positive || [hir::cardinality::NonNeg $form]
                || ($range ne {never} && [dict get $range min] ne "-inf" && [dict get $range min] >= 0)} {
            return 1
        }
    }
    return 0
}

proc hir::completions::ErrorsPhrase {names} {
    if {$names eq {}} {
        return {an error}
    }
    return "the declared error(s) [join $names {, }]"
}

proc hir::completions::EvalHandle {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set call [dict get $node call]
    set callNode [hir::node $hir $call]
    set argExprs [dict get $callNode args]
    set argRanges {}
    set dead 0
    foreach a $argExprs {
        set r [Eval hir ctx $diagnose $enclosing $guard $a]
        if {$r eq {never}} {
            set dead 1
        }
        lappend argRanges $r
    }
    set handled [dict get $node handlerNames]
    if {!$dead} {
        SubsumeCall hir ctx $diagnose $guard $call $callNode
        lassign [dict get $callNode target] targetKind target
        set calleeType [hir::typeOf $hir [dict get $callNode callee]]
        if {$targetKind eq {block}} {
            set argExact [ArgExactValues $hir $ctx $argExprs]
            set argExactLists [ArgExactLists $hir $ctx $argExprs]
            lassign [EffectiveFacts hir ctx $target $argRanges $argExact $argExactLists \
                [ArgCallables $hir $ctx $argExprs] $guard \
                [CaptureFacts $hir $ctx [dict get $callNode callee] $target]] normal errors callResult incomplete
            if {$incomplete} {
                dict set ctx incomplete 1
            }
            if {[dict exists $callNode traitImpl]} {
                # A trait operation of a clone: its requirement's contract
                # (EvalCall's own case).
                set errors [TraitCallErrors [dict get $callNode traitImpl contract] $errors $incomplete]
                if {$diagnose} {
                    CheckStructuralCallLegality hir $e [dict get $callNode traitImpl contract] $errors $handled $enclosing
                }
            } elseif {$diagnose} {
                CheckCallLegality hir $e $target $normal $errors $handled $enclosing
            }
        } elseif {$targetKind eq {} && [lindex [set indirect [IndirectFacts hir ctx $diagnose $guard $e \
                [dict get $callNode callee] $calleeType $argExprs $argRanges]] 0] ne "none"} {
            # A handled call through a structural function type (or a
            # coroutine handle's resume): bounded by its contract (EvalCall's
            # own case) -- or through an uncontracted value that its
            # callable fact charges (IndirectFacts).
            set normal 1
            set errors [lindex $indirect 1]
            set callResult [hir::range::ConstrainType $hir $call [hir::range::unknown]]
            if {$diagnose} {
                CheckIndirectCallLegality hir $e $calleeType $errors $handled $enclosing
            }
        } elseif {$targetKind eq {native}
                && ([NativeDeclaredErrors $hir $call [dict get [hir::symbol $hir $target] name]] ne {}
                    || [CallsCallable $hir [dict get [hir::symbol $hir $target] name]])} {
            # A handled call of a native with declared errors (`argv`,
            # `std::list::at`), or of a coroutine segment (start, resume).
            set name [dict get [hir::symbol $hir $target] name]
            lassign [NativeCallFacts hir ctx $guard $call $name $argExprs $argRanges] normal errors verdicts
            set callResult [hir::range::ConstrainType $hir $call \
                [NativeResultRange $hir $ctx $name $argExprs $argRanges]]
            if {$diagnose} {
                CheckNativeCallLegality hir $e $name $normal $errors $handled $enclosing
                # The verdicts belong to the native call itself (what a
                # code generator lowers), not to this `handle` node: a
                # handler's presence is never the proof.
                NoteBounds ctx $call $verdicts
            }
        } else {
            set normal 1
            set errors {}
            set callResult [hir::range::unknown]
        }
    } else {
        set normal 0
        set errors {}
    }
    # Only the errors this `handle` does NOT itself catch propagate onward
    # (item 30-32, mirroring EvalCall's own bare-call merge above); a
    # handled name is fully absorbed into whichever handler body's own
    # completion runs instead, never counted as a possible completion of
    # the enclosing scope.
    MergeErrors ctx [lmap name $errors {if {$name in $handled} continue; set name}]
    if {!$dead} {
        Eval hir ctx $diagnose $enclosing $guard [dict get $callNode callee]
    }
    # Each live handler body's own completion type must itself be
    # admissible as the call's own normal result type (spec items 11/37 of
    # EXPLICIT-ERROR-COMPLETIONS.md, unchanged by this milestone): the same
    # proof hir::range::verifyDeclaredResults already uses for a declared
    # result, via hir::range::analyzeSequence -- unaffected by, and
    # independent of, this file's own call-specific effective-error facts.
    # A handler body reachable via `never` (type "never" here) is exempt --
    # there is no completion type to admit.
    set callType [hir::typeOf $hir $call]
    set handlerTypes [dict get $node handlerTypes]
    set handlerBodies [dict get $node handlerBodies]
    set liveResults {}
    if {!$dead && $normal} {
        lappend liveResults [hir::range::ConstrainType $hir $call $callResult]
    }
    # The call's type with every List length forgotten (hir::types::
    # ForgetInferred): forgetting a length is always valid, so a handler's
    # List of another length (or of none) is admissible, and the handled
    # value's type is then their join (hir::types::Handle: a List of no
    # known length) -- a length inference minted never makes a handler
    # inadmissible (LIST-CARDINALITY-REFINEMENTS.md).
    set admitted [hir::types::ForgetInferred $callType]
    foreach name $handled body $handlerBodies type $handlerTypes {
        if {$type ne {never} && $callType ne {never}} {
            set range [hir::range::analyzeSequence $hir $body]
            if {![hir::range::ProvesValueAcceptedBy $type $range $admitted]} {
                hir::Diagnose hir TYPE [format \
                    {handler "on %s" completes with type %s, not admissible as %s (the call's own normal result type)} \
                    $name [hir::types::show [hir::types::ForgetInferred $type]] [hir::types::show $admitted]] $e
            }
        }
        set saved [dict get $ctx bindings]
        set relations [Relations $ctx]
        set r [Seq hir ctx $diagnose $enclosing $guard $body]
        if {$r ne {never}} {
            Subsume hir ctx $diagnose $guard [lindex $body end] [hir::typeOf $hir $e]
        }
        dict set ctx bindings $saved
        RestoreRelations ctx $relations
        if {$r ne {never}} {
            lappend liveResults $r
        }
    }
    if {$liveResults eq {}} {
        return never
    }
    set result [hir::range::unknown]
    foreach r $liveResults {
        set result [hir::range::join $result $r]
    }
    dict set ctx exprs $e $result
    return $result
}

# ---------------------------------------------------------------------------
# Entry points

# Pure fact computation for a call to BLOCK under concrete per-parameter
# Range facts ARGRANGES, scalar exact-value facts ARGEXACT, List-typed
# exact-element facts ARGEXACTLISTS and callable facts ARGCALLABLES (never
# diagnoses): {normal 0|1 errors NAME-LIST result Range incomplete 0|1}.
proc hir::completions::analyzeBlock {hir block argRanges argExact argExactLists argCallables guard {captureFacts {}}} {
    lassign [WalkBlock $hir $block $argRanges $argExact $argExactLists $argCallables $guard $captureFacts] ctx result
    # Normal completion is possible either by falling off the end of the
    # body (RESULT ne never) or through any reachable `return` (ctx.returned
    # -- see Eval's own `return` case): both are ordinary successful
    # completions of this function, never a failure.
    # A path that ends in a rejected static block's reified failure does not
    # make the call a known failure either (STATIC-COMPILE.md): reporting
    # that failure is the intrinsic's purpose, not an accident of the call,
    # so the call is treated as one that may complete normally -- the
    # narrowest exemption: an ordinary `fail` or a call proven to fail on
    # its own still makes its callers KNOWN-ERROR.
    set normal [expr {$result ne {never} || [dict get $ctx returned] || [dict get $ctx intended]}]
    # The successful result is the fall-through value joined with every
    # returned one (`never` when there is neither).
    set result [hir::range::join $result [dict get $ctx returnRange]]
    return [dict create normal $normal \
        errors [lsort -unique [dict keys [dict get $ctx errors]]] \
        result [if {$result eq {never}} {hir::range::unknown} else {set result}] \
        incomplete [dict get $ctx incomplete]]
}

# analyzeBlock's walk: {CTX FALLTHROUGH-RESULT}, the final walk context
# (never diagnosing) and the body's fall-through value. A parameter's
# callable fact is its argument's; a capture's is CAPTUREFACTS's (the
# closure the caller's own activation created: CaptureFacts), else it has
# none (the closure may have been created by any activation).
proc hir::completions::WalkBlock {hir block argRanges argExact argExactLists argCallables guard {captureFacts {}}} {
    set ctx [NewCtx]
    set params [hir::get $hir $block params]
    foreach b $params r $argRanges {
        dict set ctx bindings $b $r
    }
    foreach b $params f $argCallables {
        if {$f ne "" && $f ne "unknown"} {
            dict set ctx callables $b $f
        }
    }
    dict for {b f} $captureFacts {
        if {$f ne "unknown"} {
            dict set ctx callables $b $f
        }
    }
    foreach b $params v $argExact {
        if {$v ne {}} {
            dict set ctx exact $b $v
        }
    }
    foreach b $params v $argExactLists {
        if {$v ne {}} {
            dict set ctx exactList $b $v
        }
    }
    set result [Seq hir ctx 0 {} $guard [hir::get $hir $block body]]
    return [list $ctx $result]
}

# Inspection accessor (tests/range-completions-crosscheck.test): the Range
# this walk computed for every expression of BLOCK's own body under the
# parameter Ranges ARGRANGES (ExprId -> Range), the very per-node facts
# analyzeBlock's callers read -- for comparing the local transfer rules
# with hir::range's (AnalyzeInstance's `exprs`), which are meant to agree.
proc hir::completions::exprRangesOf {hir block argRanges} {
    resetCache
    lassign [WalkBlock $hir $block $argRanges {} {} {} [dict create $block 1]] ctx result
    return [dict get $ctx exprs]
}

# The once-per-function-body legality driver (hir/errorsets.tcl's own
# "blocks" loop): walks BLOCK's own body (or the program root's, when BLOCK
# is the literal string "program") diagnosing every call/handle found
# directly in its own lexical scope (never descending into a different
# block's own body -- that gets its own independent top-level entry from the
# same "blocks" loop, exactly matching the pre-existing WalkExpr's own
# scoping) against ENCLOSINGERRORS.
proc hir::completions::checkBlock {hirVar block enclosingErrors} {
    upvar 1 $hirVar hir
    set ctx [NewCtx]
    if {$block eq {program}} {
        set body [hir::roots $hir]
        set guard {}
    } else {
        set params [hir::get $hir $block params]
        foreach b $params {
            dict set ctx bindings $b [SeedParam]
        }
        SeedClean $hir ctx $block
        set body [hir::get $hir $block body]
        set guard [dict create $block 1]
    }
    set result [Seq hir ctx 1 $enclosingErrors $guard $body]
    if {$block ne {program} && $result ne {never}} {
        # The body's own trailing value is what it returns.
        Subsume hir ctx 1 $guard [lindex $body end] [ResultFinal $hir $block]
    }
    # Replace, never merge, whatever an earlier check of this HIR left.
    dict for {e verdicts} [dict get $ctx bounds] {
        dict set hir exprs $e boundsVerdicts $verdicts
    }
    return $result
}

# Records VERDICTS (NativeEffectiveFacts) for native call E in ctx.bounds,
# joined with every verdict an earlier walk of E in this checkBlock made: a
# literal-List loop walks its body once per element, each under that
# element's own facts, and the call runs under all of them, so a check is
# proven only if every walk proved it (a later element must never
# overwrite an earlier element's unproven check). Per check, the union of
# the errors that walk left possible.
proc hir::completions::NoteBounds {ctxVar e verdicts} {
    upvar 1 $ctxVar ctx
    if {$verdicts eq {}} {
        return
    }
    if {[dict exists $ctx bounds $e]} {
        set verdicts [lmap old [dict get $ctx bounds $e] new $verdicts {
            lsort -unique [concat $old $new]
        }]
    }
    dict set ctx bounds $e $verdicts
}

# The expressions of BLOCK's own body this pass's walk reaches (ExprId -> 1):
# exactly the walk checkBlock makes -- parameters unconstrained, a branch the
# facts prove infeasible (an empty narrowed range, a decided condition) never
# entered, nothing after an expression that cannot complete -- but pure
# fact computation (it diagnoses nothing and stashes nothing in HIR), with the
# walk recording what it visited. A consumer that needs "can this expression
# execute at all, by everything the completion proof knows" asks this; an
# expression absent from the answer is proven unreachable, one present is
# merely not proven unreachable. Used by hir/warnings.tcl (SAME-RETURN-VALUE)
# on demand, never by a compilation that has warnings off.
proc hir::completions::reachedExprs {hir block} {
    resetCache
    set ctx [NewCtx]
    dict set ctx record 1
    foreach b [hir::get $hir $block params] {
        dict set ctx bindings $b [SeedParam]
    }
    SeedClean $hir ctx $block
    Seq hir ctx 0 {} [dict create $block 1] [hir::get $hir $block body]
    return [dict get $ctx visited]
}

# ---------------------------------------------------------------------------
# Test/inspection accessors (item 89): the facts CheckCallLegality stashed
# on a checked call/handle node E, or "" if E was never reached by any
# top-level checkBlock walk (dead/unreachable code).
proc hir::completions::effectiveErrorsOf {hir e} {
    set node [hir::node $hir $e]
    return [dict getdef $node effectiveErrors {}]
}

# The per-check bounds verdicts checkBlock stamped on native call E
# (NativeEffectiveFacts): one element per registered bounds check, each the
# declared errors that check may still produce on every path reaching E. ""
# when E was never reached by a top-level walk or is not a bounds-bearing
# native call -- "no proof", never "proven".
proc hir::completions::BoundsVerdictsOf {hir e} {
    set node [hir::node $hir $e]
    return [dict getdef $node boundsVerdicts {}]
}

# 1 iff every bounds check of native call E is proven never to fail (every
# verdict {}): the only fact code generation consumes, and only ever for a
# whole call -- a call with any unproven check keeps all of them. The
# stamp is open-world (parameters unconstrained, no caller facts), so it
# holds in every specialization instance of E's block.
proc hir::completions::BoundsProven {hir e} {
    set verdicts [BoundsVerdictsOf $hir $e]
    if {$verdicts eq {}} {
        return 0
    }
    foreach v $verdicts {
        if {$v ne {}} {
            return 0
        }
    }
    return 1
}

proc hir::completions::mayReturnNormallyOf {hir e} {
    set node [hir::node $hir $e]
    return [dict getdef $node mayReturnNormally 1]
}

# The Range fact this pass computed for a checked call expression E (item
# 69's own std::char::scalar_value pins), or hir::range::unknown if E was never
# reached by a top-level checkBlock walk.
proc hir::completions::resultRangeOf {hir e} {
    set node [hir::node $hir $e]
    return [dict getdef $node resultRangeFact [hir::range::unknown]]
}
