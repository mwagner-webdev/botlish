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
# RefBinding, TypeFact/ConstrainType, add/sub/mul/BitOp, ExactOf, point,
# unknown, JoinBindings) -- see each proc below for exactly which one it
# calls. What this file adds on top, that hir::range.tcl deliberately does
# not need for its own purpose, is: (a) treating a narrowed branch fact that
# becomes an empty interval as a *provably infeasible* branch, pruned
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
# The one way an error can leave a function that does not declare it is a
# call this walk cannot see through: a callable that reaches an untyped
# parameter through a semantic instance (hir/semantic.tcl; the only erasure
# hir/callables.tcl accepts), called there as `f(x)` with `f : any` -- or a
# closure that captured one and is called later. The generic body says
# nothing about such a call's errors, so the walk tracks where each callable
# value comes from (CallableFact):
#
#   {block B} / {native N}  exactly that callable (an argument of exact
#                           type): the call is analyzed as an exact call of
#                           it -- its effective errors, never a must-fact
#   clean                   a parameter or capture of the body being
#                           checked: whatever an erased argument carries is
#                           charged at the call that passed it (it reaches
#                           this body only through that call's analysis);
#                           a closure the walk saw created in the same
#                           activation sees its captures' facts
#   unknown                 anything else: the call may be any callable the
#                           program erases, so it is charged the program's
#                           erased-callable contract (ErasedErrors: every
#                           declared error of every callable the program
#                           passes into an untyped parameter) and the walk
#                           becomes *incomplete*
#
# An incomplete summary falls back to the callee's declared contract at the
# function-instance boundary (EffectiveFacts): exact narrowing is kept only
# while the whole walk is complete, and incompleteness propagates to every
# enclosing summary. A fallback is a may-set: it never turns a call into a
# known failure (`normal` is what the walk proved, and the fallbacks never
# lower it). A program that erases no error-bearing callable has an empty
# erased-callable contract, and nothing here changes its analysis.

namespace eval hir::completions {
    # Recursive nested-call analysis budget (item 35/108-16): once this many
    # distinct exact-callee analyses have run within one top-level
    # hir::completions::checkBlock walk, every further nested call falls
    # back conservatively to its callee's own declared errors and ordinary
    # (normal-completion-possible) outcome -- never a claim of impossibility
    # the budget did not actually verify. Generous enough for every corpus
    # shape (byte::set's own single-level from_int nesting, a handful of
    # calls per literal-list element) while bounding pathological call
    # chains.
    variable maxAnalyses 256
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
    # (ErasedErrors), and the transparent blocks (Transparent): computed on
    # first use, cleared with the cache.
    variable erased ""
    variable erasedKnown 0
    variable transparent ""
}

proc hir::completions::resetCache {} {
    variable cache
    variable erasedKnown
    variable transparent
    set cache [dict create]
    set erasedKnown 0
    set transparent ""
}

# ---------------------------------------------------------------------------
# Callable facts and the erased-callable contract (header, "Precision and the
# erased-callable contract")

# The erased-callable contract of HIR: every declared error a callable the
# program passes into an untyped parameter can raise. Such a value reaches
# the parameter only through a semantic instance (hir/semantic.tcl: the
# instance's entry type at a parameter without a declared or trusted
# contract is the argument's own type), so the instances' entry types at
# untyped parameters are every erased value; what each one carries is
# hir::callables::CarriedErrors of its type. An untyped call whose callee
# this walk cannot identify can only be one of those values, or a closure
# whose own untyped calls reach one of them: this set bounds what it raises.
proc hir::completions::ErasedErrors {hir} {
    variable erased
    variable erasedKnown
    if {!$erasedKnown} {
        set erased [erasedErrorsOf $hir]
        set erasedKnown 1
    }
    return $erased
}

# ErasedErrors of HIR, computed afresh (for a pass other than this file's:
# hir/affine.tcl's error edges).
proc hir::completions::erasedErrorsOf {hir} {
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

# The callable fact of expression E's value (header): {block B} or {native N}
# when its static type is that exact callable, else the fact this walk
# recorded for the binding a `ref` reads (a parameter seeded from its
# argument, a local from its value, a checked body's parameters and captures
# `clean`), else `clean` for a value that cannot be a callable, else
# `unknown`.
proc hir::completions::CallableFact {hir ctx e} {
    set type [hir::typeOf $hir $e]
    if {[hir::types::IsExactBlock $type]} {
        return [list block [lindex $type 1]]
    }
    if {[hir::types::IsExactNative $type]} {
        return [list native [lindex $type 1]]
    }
    if {[hir::kind $hir $e] eq "ref"} {
        set b [hir::get $hir $e binding]
        if {$b ne "" && [dict exists $ctx callables $b]} {
            return [dict get $ctx callables $b]
        }
    }
    return [expr {[MayHoldCallable $type] ? "unknown" : "clean"}]
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
    if {[hir::types::IsExactBlock $type]} {
        return [list block [lindex $type 1]]
    }
    if {[hir::types::IsExactNative $type]} {
        return [list native [lindex $type 1]]
    }
    if {[dict exists $ctx callables $b]} {
        return [dict get $ctx callables $b]
    }
    return [expr {[MayHoldCallable $type] ? "unknown" : "clean"}]
}

# 1 if binding B is one a body's own check takes as `clean` and may hold a
# callable (SeedClean): a parameter or capture of a type that is neither an
# exact callable (whose calls that check analyzes) nor uncallable.
proc hir::completions::CleanInput {hir b} {
    set type [hir::bindingType $hir $b]
    return [expr {![hir::types::IsExactBlock $type] && ![hir::types::IsExactNative $type]
        && [MayHoldCallable $type]}]
}

# The callable facts of the captures of closure TARGET, a dict binding ->
# fact, when call CALLEE (the callee expression) calls the closure this
# activation created (a `ref` to the local CTX recorded it in): its captures
# are this walk's own bindings. {} otherwise -- a closure from elsewhere
# (another activation's) has captures this walk knows nothing about.
proc hir::completions::CaptureFacts {hir ctx callee target} {
    if {[ErasedErrors $hir] eq {} || [hir::kind $hir $callee] ne "ref"} {
        return {}
    }
    set b [hir::get $hir $callee binding]
    if {$b eq "" || ![dict exists $ctx closures $b] || [dict get $ctx closures $b] ne $target} {
        return {}
    }
    set facts [dict create]
    foreach c [hir::get $hir $target captures] {
        dict set facts $c [BindingFact $hir $ctx $c]
    }
    return $facts
}

# 1 if an activation of block B may complete with a declared error B does
# not declare itself: B's own body (not the bodies of the closures it
# creates) makes a call this walk cannot see through -- through a value of
# untyped or structural function type, or a native that calls a callable
# argument (-errors-from) -- or an exact call of a transparent block.
# Everything else B's activation raises is a `fail` of B (which B must
# declare) or an exact call checkBlock holds to B's declared errors. Static
# (no facts), so it can answer for a call the walk does not enter: a
# recursion cycle, an exhausted budget, an arity mismatch (Fallback).
# One least fixpoint over the program's exact call edges, per pass.
proc hir::completions::Transparent {hir b} {
    variable transparent
    if {$transparent eq ""} {
        set transparent [transparentBlocks $hir]
    }
    return [dict exists $transparent $b]
}

# 1 if call E of HIR may complete with an error its type-level calleeErrors
# do not name (hir/types.tcl's Call): an exact call of a block in TRANSPARENT
# (transparentBlocks), a call through an untyped or structural callee, a
# native calling a callable argument -- the calls the erased-callable
# contract reaches. For hir/affine.tcl's error edges, which use the
# type-level errors and this, never the completion proofs.
proc hir::completions::mayLetErasedThrough {hir e transparent} {
    lassign [hir::get $hir $e target] targetKind target
    switch -- $targetKind {
        block {
            return [dict exists $transparent $target]
        }
        native {
            set name [dict get [hir::symbol $hir $target] name]
            return [expr {[dict get [core::native::metadata $name] errorsFrom] ne ""}]
        }
    }
    return [MayHoldCallable [hir::typeOf $hir [hir::get $hir $e callee]]]
}

# The transparent blocks of HIR (Transparent), as a dict BLOCK -> 1.
proc hir::completions::transparentBlocks {hir} {
    set callers [dict create]
    set work {}
    set result [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block"} {
            continue
        }
        set opaque 0
        foreach child [dict get $node body] {
            TransparentEdges $hir $e $child callers opaque
        }
        if {$opaque} {
            dict set result $e 1
            lappend work $e
        }
    }
    while {$work ne {}} {
        set b [lindex $work 0]
        set work [lrange $work 1 end]
        if {![dict exists $callers $b]} {
            continue
        }
        foreach caller [dict get $callers $b] {
            if {![dict exists $result $caller]} {
                dict set result $caller 1
                lappend work $caller
            }
        }
    }
    return $result
}

# Records, for block B, the exact call edges of expression E (in CALLERSVAR:
# callee -> {caller ...}) and sets OPAQUEVAR when E makes a call
# Transparent's header names; never enters a nested block's body.
proc hir::completions::TransparentEdges {hir b e callersVar opaqueVar} {
    upvar 1 $callersVar callers $opaqueVar opaque
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        block { return }
        call {
            lassign [dict get $node target] targetKind target
            if {$targetKind eq "block"} {
                dict lappend callers $target $b
            } elseif {$targetKind eq "native"} {
                set name [dict get [hir::symbol $hir $target] name]
                if {[dict get [core::native::metadata $name] errorsFrom] ne ""} {
                    set opaque 1
                }
            } elseif {[MayHoldCallable [hir::typeOf $hir [dict get $node callee]]]} {
                set opaque 1
            }
        }
    }
    foreach child [hir::children $hir $e] {
        TransparentEdges $hir $b $child callers opaque
    }
}

# ---------------------------------------------------------------------------
# Branch feasibility (item 29): a Range this file's own ComparisonNarrowing-
# derived facts computed that is empty (both bounds finite, min > max) means
# the outcome that produced it cannot actually happen -- a genuine
# contradiction between the incoming argument facts and this branch's own
# condition, not merely "no new information" (hir::range::Narrowed's own ""
# return, which means the opposite: nothing to prune).
proc hir::completions::RangeEmpty {r} {
    if {$r eq {never}} {
        return 1
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    return [expr {$mn ne {-inf} && $mx ne {+inf} && $mn > $mx}]
}

# 1 if any Range in FACTS (a bindingId -> Range dict, as hir::range::
# ComparisonNarrowing returns) is empty: this outcome is infeasible under
# the current bindings.
proc hir::completions::FactsContradictory {facts} {
    foreach {b r} $facts {
        if {[RangeEmpty $r]} {
            return 1
        }
    }
    return 0
}

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
#   exactList bindingId -> {value ...}  (a List-kind binding's own exact
#                                        element values, when it was bound
#                                        to a small literal list, either
#                                        directly or via a further exact
#                                        call boundary -- what lets
#                                        `byte::set(['-','.','_','~'])`'s own
#                                        literal-list proof see through the
#                                        call into `set`'s own `chars`
#                                        parameter, items 36-40)
#   indexBounds bindingId -> FORM       (a counted-loop variable proven to
#                                        satisfy 0 <= i < FORM in its loop's
#                                        body, FORM a hir/cardinality.tcl
#                                        linear form -- e.g. the length of
#                                        the List the loop counts over:
#                                        IndexBounds' relational case)
#   upperBounds bindingId -> {FORM ...} (an Int binding proven < each FORM
#                                        in the current branch, from an
#                                        enclosing `if` condition comparing
#                                        it with a size: BranchRelations)
#   sizes     FORM -> N                 (a List length / MutableArray
#                                        capacity form proven equal to the
#                                        Int N in the current branch, from
#                                        an enclosing `list::length(xs) == N`)
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
#                                        {native N} or clean; a binding
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
        incomplete 0]
}

# Seeds CTX for a walk of BLOCK's own body by its own check (checkBlock,
# reachedExprs): every parameter and capture is `clean` -- a callable an
# erased argument puts there is charged at the call that passed it.
proc hir::completions::SeedClean {hir ctxVar block} {
    upvar 1 $ctxVar ctx
    if {[ErasedErrors $hir] eq {}} {
        return
    }
    foreach b [concat [hir::get $hir $block params] [hir::get $hir $block captures]] {
        dict set ctx callables $b clean
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
            set r [expr {[core::value::kind $v] eq {int} ? [hir::range::point [core::value::intOf $v]] : [hir::range::unknown]}]
            dict set ctx exprs $e $r
            return $r
        }
        ref {
            set b [dict get $node binding]
            if {$b eq {}} {
                return never
            }
            set bindings [dict get $ctx bindings]
            set r [expr {[dict exists $bindings $b] ? [dict get $bindings $b] : [hir::range::unknown]}]
            set r [hir::range::ConstrainType $hir $e $r]
            dict set ctx exprs $e $r
            return $r
        }
        bind {
            set r [Eval hir ctx $diagnose $enclosing $guard [dict get $node value]]
            set b [dict get $node binding]
            if {$r ne {never} && ![dict get $node duplicate]
                    && [dict get [hir::binding $hir $b] kind] eq {local}} {
                dict set ctx bindings $b $r
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
            set r [expr {$value eq {} ? [hir::range::unknown] : [Eval hir ctx $diagnose $enclosing $guard $value]}]
            if {$r ne {never} && [dict get $node target] ne {}} {
                dict set ctx returned 1
                dict set ctx returnRange [hir::range::join [dict get $ctx returnRange] $r]
            }
            return never
        }
        break {
            set value [dict get $node value]
            if {$value ne {}} {
                Eval hir ctx $diagnose $enclosing $guard $value
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
            return never
        }
        ok - error {
            set r [Eval hir ctx $diagnose $enclosing $guard [dict get $node value]]
            return [expr {$r eq {never} ? {never} : [hir::range::unknown]}]
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
            return [hir::range::unknown]
        }
        project {
            # The projected field's Range is what its static type implies,
            # exactly as hir::range::Expr's own project case computes it (a
            # field declared with an integer domain holds values of that
            # domain: every construction proved it), so `byte::from_int(
            # x.value)` for `x: abi::U8` is as decided here as it is for a
            # local bound to x.value (ABI-NUMERIC-DOMAINS.md).
            if {[Eval hir ctx $diagnose $enclosing $guard [dict get $node receiver]] eq {never}} {
                return never
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
# the SAME machinery hir::range::If uses to narrow a `<`/`<=`/`>`/`>=`/`==`
# condition (reused directly, not reimplemented): hir::types::KnownOutcome
# first (a purely syntactic/type-level decided condition), then
# hir::range::ComparisonNarrowing against this walk's own ctx.exprs cache.
# Returns {feasible 0|1 facts BINDINGS-DICT}.
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
    set facts [dict create]
    foreach conjunct [Conjuncts $hir $condition $outcome] {
        set narrowed [hir::range::ComparisonNarrowing $hir $shim {*}$conjunct]
        if {[FactsContradictory $narrowed]} {
            return [list 0 {}]
        }
        dict for {b r} $narrowed {
            if {[dict exists $facts $b]} {
                set r [hir::range::intersect [dict get $facts $b] $r]
            }
            dict set facts $b $r
        }
    }
    return [list 1 $facts]
}

# The {condition outcome} pairs that all hold when CONDITION has OUTCOME:
# `A or B` (lowered to `if A: true else: B`) being false means A and B are
# both false, `A and B` (`if A: B else: false`) being true means both are
# true -- recursively, so a chain of `or`s (`i < 0 or i >= n`) narrows its
# false branch by every operand. Anything else is the one pair itself.
proc hir::completions::Conjuncts {hir condition outcome} {
    set node [hir::node $hir $condition]
    if {[dict get $node kind] eq {if}} {
        set then [dict get $node thenBody]
        set else [dict get $node elseBody]
        if {[llength $then] == 1 && [llength $else] == 1} {
            set test [dict get $node condition]
            if {!$outcome && [hir::types::KnownOutcome $hir [lindex $then 0]] eq {1}} {
                return [concat [Conjuncts $hir $test 0] [Conjuncts $hir [lindex $else 0] 0]]
            }
            if {$outcome && [hir::types::KnownOutcome $hir [lindex $else 0]] eq {0}} {
                return [concat [Conjuncts $hir $test 1] [Conjuncts $hir [lindex $then 0] 1]]
            }
        }
    }
    return [list [list $condition $outcome]]
}

# The relational facts the `if` condition CONDITION establishes on its
# OUTCOME branch, for IndexBounds alone, added to ctx: a comparison of an
# Int binding with a size (`i < list::length(xs)` true, `i >= list::length
# (xs)` false, ... in either operand order) records the binding's
# exclusive upper bound as a hir/cardinality.tcl form (ctx.upperBounds); an
# equality of a List length or MutableArray capacity with an exact Int
# (`list::length(bytes) == 1`) records that size (ctx.sizes). Only an Int
# comparison native (`< <= > >= ==`) is read; anything else adds nothing.
# Every form names immutable values, so a fact stays true for the whole
# branch. Each of the condition's Conjuncts contributes its own facts.
proc hir::completions::BranchRelations {hir ctxVar condition outcome} {
    upvar 1 $ctxVar ctx
    foreach conjunct [Conjuncts $hir $condition $outcome] {
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
    # A constant below a size (`list::length(xs) > 0`, `str::length(s) >= 1`
    # true, `str::length(s) < 1` false): LOW < SIZE + K, so SIZE >= LOW - K + 1.
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
    lassign [hir::cardinality::Chase $hir $low steps] kind binding
    if {$kind ne {binding}} {
        return
    }
    set form [hir::cardinality::FormAdd [hir::cardinality::IntForm $hir $high steps] \
        [hir::cardinality::FormConst $k]]
    set bounds [dict get $ctx upperBounds]
    dict lappend bounds $binding $form
    dict set ctx upperBounds $bounds
}

# The form of E when it is exactly one container size -- a List length, a
# MutableArray capacity or a String length (`list::length(xs)`, a binding
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
        RestoreRelations ctx $savedRelations
        dict set after $outcome [dict get $ctx bindings]
    }
    # When only one branch can complete normally (`if i >= list::length(xs):
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
    Seq hir ctx $diagnose $enclosing $guard [dict get $node body]
    dict set ctx bindings $saved
    RestoreRelations ctx $relations
    return [hir::range::unknown]
}

# The relational facts (ctx.upperBounds, ctx.sizes) in effect: what a scope
# whose body may run zero times, or only on some other path -- a loop body,
# a handler -- restores when it ends, so a fact established inside it (an
# early `return`/`break` guard: `if j >= list::length(ys): break`) never
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

# A countloop's start/end are evaluated once, in the enclosing scope,
# exactly like EvalListloop's own iterable -- walked here to record whatever
# errors/diagnostics/facts they themselves contribute, and for their Ranges.
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
    set start [Eval hir ctx $diagnose $enclosing $guard [dict get $node start]]
    set end [Eval hir ctx $diagnose $enclosing $guard [dict get $node end]]
    set saved [dict get $ctx bindings]
    set savedBounds [dict get $ctx indexBounds]
    set relations [Relations $ctx]
    dict set ctx bindings [dict get $node countBinding] \
        [hir::range::InductionBinding $start $end [dict get $node direction] [dict get $node endKind]]
    NoteIndexBound hir ctx [dict get $node countBinding] $start [dict get $node end] \
        [dict get $node direction] [dict get $node endKind]
    Seq hir ctx $diagnose $enclosing $guard [dict get $node body]
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
# contribute); the body is then walked once, EvalCountloop's own
# conservative treatment: each numeric domain's binding gets the same
# interval hir/range.tcl gives it, each list domain's element binding stays
# unseeded.
proc hir::completions::EvalLockloop {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set ranges [dict create]
    foreach operand [hir::loopOperands $node] {
        dict set ranges $operand [Eval hir ctx $diagnose $enclosing $guard $operand]
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
    Seq hir ctx $diagnose $enclosing $guard [dict get $node body]
    dict set ctx bindings $saved
    dict set ctx indexBounds $savedBounds
    RestoreRelations ctx $relations
    return [hir::range::unknown]
}

# listloop's small-exact-literal-list proof (items 36-40, 92): when ITERABLE
# is itself a call to the variadic `list` native whose every argument is a
# plain `const`, within hir::range's own exact-value budget, this walks the
# body once per element, left to right (item 73), each under that exact
# element's own fact (an Int point for an int element, ctx.exact for any
# other constant kind, e.g. UnicodeChar). If some element's own body proves
# unable to complete normally, the whole listloop stops there (matching
# runtime left-to-right completion semantics) and is itself never, carrying
# every error discovered up to and including that element (items 39/73).
# An empty literal list never executes the body at all (item 92): trivially
# always completes normally, no errors.
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
    set elements [LiteralListOf $hir $ctx $iterable]
    if {$elements eq {} || [ExitsLoop $hir $e [dict get $node body]]} {
        return [EvalLoop hir ctx $diagnose $enclosing $guard $e $node]
    }
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
        if {$result eq {never}} {
            break
        }
    }
    dict set ctx bindings $saved
    dict set ctx exact $savedExact
    RestoreRelations ctx $relations
    return [expr {$result eq {never} ? {never} : [hir::range::unknown]}]
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

# The literal core values of EXPR (a List-typed expression), if it is either
# (a) a direct call to the variadic `list` native with every argument a
# plain `const`, within hir::range's own exact-value budget (item 37:
# reused, not reintroduced), or (b) a `ref` to a binding this walk's own
# ctx.exactList already established -- the general form of (a), threaded
# across an exact call boundary the same way an Int/UnicodeChar exact value
# already is (ArgExactValues/ctx.exact): this is what lets
# `byte::set(['-','.','_','~'])`'s own literal argument reach `set`'s own
# `loop c in chars:` (whose iterable is a plain `ref` to the parameter
# `chars`, not the literal list expression itself) as a genuine small
# literal list, with no `set`/`byte`-specific code anywhere in this file.
# {} otherwise (not a small literal list; EvalListloop falls back to the
# general case).
proc hir::completions::LiteralListOf {hir ctx expr} {
    if {[hir::kind $hir $expr] eq {ref}} {
        set b [hir::get $hir $expr binding]
        set exactList [dict get $ctx exactList]
        return [expr {$b ne {} && [dict exists $exactList $b] ? [dict get $exactList $b] : {}}]
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
    set values {}
    foreach arg $args {
        if {[hir::kind $hir $arg] ne {const}} {
            return {}
        }
        lappend values [hir::get $hir $arg value]
    }
    return $values
}

# A native call's own result Range, for the small set of natives this
# analysis needs a fact for. `+ - * bit_and bit_or bit_xor shift_left
# shift_right` reuse hir::range's own pure interval/exact-set arithmetic
# directly (identical to hir::range::Call's own native case). Any other
# native consults its own -result-range metadata (nonneg/collection-length,
# core/native.tcl) the same generic way hir::range.tcl's SeedRange/Call
# already do, PLUS one further, local fact this pass alone needs (never
# registered on the native itself, so it can never influence native
# lowering/codegen -- item 60-61): `mod` with a divisor of bounded
# magnitude is below it, and `char::scalar_value` (the root native
# core/unicodechar.tcl registers under that qualified name) is a Unicode
# scalar value, therefore always in
# [0, 0x10FFFF] (item 22), and when its own argument is provably an exact
# UnicodeChar constant (a literal, or ctx.exact propagation through an
# immutable binding -- e.g. a small-literal-list element, EvalListloop
# above), the exact codepoint itself, not merely the interval.
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
        # Euclidean modulo (core/primitives.tcl): every result r of
        # mod(a, b) has 0 <= r < abs(b), so a divisor of bounded magnitude
        # bounds the result (`mod(b, 16)` is 0..15) -- the general fact,
        # local to this pass like char::scalar_value's below.
        set d [lindex $argRanges 1]
        if {$d ne {never} && [dict get $d min] ne "-inf" && [dict get $d max] ne "+inf"} {
            set m [expr {max(abs([dict get $d min]), abs([dict get $d max]))}]
            if {$m > 0} {
                return [dict create min 0 max [expr {$m - 1}]]
            }
        }
        return [hir::range::nonneg]
    }
    if {$name in {str::length list::length} && [llength $argExprs] == 1} {
        # The length of a String or List this walk knows exactly (a literal,
        # an exact binding, an exact argument of this call-specific walk) is
        # that exact number -- what a slice or index proof inside a callee
        # needs from `n = str::length(s)` once s is a known argument.
        set arg [lindex $argExprs 0]
        if {$name eq {str::length}} {
            set v [ExactValueOf $hir $ctx $arg]
            if {$v ne {} && [core::value::kind $v] eq {str}} {
                return [hir::range::point [string length [core::value::strOf $v]]]
            }
        } else {
            set literal [LiteralListOf $hir $ctx $arg]
            if {$literal ne {}} {
                return [hir::range::point [llength $literal]]
            }
        }
    }
    if {$name eq {char::scalar_value} && [llength $argExprs] == 1} {
        set arg [lindex $argExprs 0]
        set v [ExactValueOf $hir $ctx $arg]
        if {$v ne {} && [core::value::kind $v] eq {UnicodeChar}} {
            return [hir::range::point [core::value::charOf $v]]
        }
        return [dict create min 0 max 0x10FFFF]
    }
    set exact [hir::exact::NativeRange $hir $name $argExprs $argRanges [dict get $ctx exprs]]
    if {$exact ne {}} {
        return $exact
    }
    switch -- [dict get [core::native::metadata $name] resultRange] {
        nonneg            { return [hir::range::nonneg] }
        collection-length { return [hir::range::collectionLength] }
    }
    return [hir::range::unknown]
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
    return {}
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
    lassign [dict get $node target] targetKind target
    if {$targetKind eq {native}} {
        set name [dict get [hir::symbol $hir $target] name]
        # A native that declares errors (-errors, core/native.tcl: `argv`,
        # `list::at`) is held to the same legality rule as any other
        # fallible call, under its own call-specific facts
        # (NativeEffectiveFacts). So is one that calls a callable argument
        # while the program erases an error-bearing callable (IndirectFacts).
        if {[NativeDeclaredErrors $hir $e $name] ne {} || [CallsCallable $hir $name]} {
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
        # TYPES.md): which implementation runs is unknown, so no narrower
        # proof exists here -- every error the contract declares may escape,
        # exactly like an exact callee whose own proof ran out (the
        # conservative fallback EffectiveFacts itself uses), and the call's
        # result is what the contract promises.
        # (A coroutine handle's resume, AFFINE-VALUES.md: the same contract,
        # the errors any one segment may end with.)
        # A call through an untyped value is charged what its callable fact
        # says (IndirectFacts): nothing for a clean one, as before.
        lassign [IndirectFacts hir ctx $guard [dict get $node callee] $calleeType $argExprs $argRanges] how errors
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
# counterpart of ArgExactValues above (items 36-40).
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
# maxAnalyses (item 35). This is the function-instance boundary of the
# header: an incomplete analysis keeps every error TARGET declares.
proc hir::completions::EffectiveFacts {hirVar ctxVar target argRanges argExact argExactLists argCallables guard {captureFacts {}}} {
    upvar 1 $hirVar hir $ctxVar ctx
    variable maxAnalyses
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
            lappend facts [expr {$f eq "" ? "unknown" : $f}]
        }
    }
    foreach c [hir::get $hir $target captures] {
        if {[CleanInput $hir $c]} {
            lappend facts [expr {[dict exists $captureFacts $c] ? [dict get $captureFacts $c] : "unknown"}]
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

# The completion facts of call node NODE whose callee CALLEE (static type
# CALLEETYPE) is not an exact target -- a structural function type, a
# coroutine handle, or an untyped value -- under ARGEXPRS/ARGRANGES:
# {HOW ERRORS}, HOW `structural` (its contract's errors, ERRORS) or `opaque`
# (an untyped callee charged ERRORS), or `none` (an untyped callee charged
# nothing: no fact says it may raise). A structural callee always may
# complete normally, an opaque one is never charged a must-fact.
#
# With an erased-callable contract (header), CALLEE's callable fact adds to
# it: an exact closure's effective errors (its body analyzed under these
# arguments: the recovery a structural type or `any` hides), an exact
# native's declared errors, or -- for an unknown value -- the erased-callable
# contract itself, which makes the walk incomplete.
proc hir::completions::IndirectFacts {hirVar ctxVar guard callee calleeType argExprs argRanges {argFacts ""}} {
    upvar 1 $hirVar hir $ctxVar ctx
    set structural [expr {[hir::types::IsFn $calleeType] || [hir::types::IsCoroutine $calleeType]}]
    set errors [expr {$structural ? [dict get [hir::types::Contract $calleeType] errors] : {}}]
    set erased [ErasedErrors $hir]
    if {$erased ne {} && ![hir::types::IsCoroutine $calleeType]} {
        set fact [CallableFact $hir $ctx $callee]
        switch -- [lindex $fact 0] {
            block {
                if {$argFacts eq ""} {
                    set argFacts [ArgCallables $hir $ctx $argExprs]
                }
                set target [lindex $fact 1]
                lassign [EffectiveFacts hir ctx $target $argRanges \
                    [ArgExactValues $hir $ctx $argExprs] [ArgExactLists $hir $ctx $argExprs] \
                    $argFacts $guard [CaptureFacts $hir $ctx $callee $target]] normal sub _ incomplete
                set errors [lsort -unique [concat $errors $sub]]
                if {$incomplete} {
                    dict set ctx incomplete 1
                }
            }
            native {
                if {![catch {core::native::metadata [lindex $fact 1]} meta]} {
                    set errors [lsort -unique [concat $errors [dict get $meta errors]]]
                }
            }
            unknown {
                set extra [lmap name $erased {expr {$name in $errors ? [continue] : $name}}]
                if {$extra ne {}} {
                    set errors [lsort -unique [concat $errors $extra]]
                    dict set ctx incomplete 1
                }
            }
        }
    }
    if {$structural} {
        return [list structural $errors]
    }
    return [list [expr {$errors eq {} ? "none" : "opaque"}] $errors]
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
        set cited [expr {$errors eq {} ? $declared : $errors}]
        hir::Diagnose hir KNOWN-ERROR [format \
            {this call can never complete normally under the facts proven for its arguments here -- it always produces %s; a handler does not make a statically known failure legal} \
            [ErrorsPhrase $cited]] $e
        return
    }
    foreach name $errors {
        if {$name ni $handled && $name ni $enclosing} {
            hir::Diagnose hir UNHANDLED-ERROR [format \
                {this call may produce the declared error "%s", which is neither handled here nor admitted by the enclosing function's own "errors" declaration} \
                $name] $e
        }
    }
}

# CheckCallLegality for call E through a structural function type
# CALLEETYPE: its whole declared error set ERRORS is effective (a structural
# callee always may complete normally), so the one legality rule is
# ERRORS - HANDLED subseteq ENCLOSING.
proc hir::completions::CheckStructuralCallLegality {hirVar e calleeType errors handled enclosing} {
    upvar 1 $hirVar hir
    dict set hir exprs $e effectiveErrors [lsort -unique $errors]
    dict set hir exprs $e mayReturnNormally 1
    foreach name $errors {
        if {$name ni $handled && $name ni $enclosing} {
            if {[hir::types::IsCoroutine $calleeType]} {
                hir::Diagnose hir UNHANDLED-ERROR [format \
                    {this coroutine resume may produce the declared error "%s", which is neither handled here nor admitted by the enclosing function's own "errors" declaration} \
                    $name] $e
                continue
            }
            hir::Diagnose hir UNHANDLED-ERROR [format \
                {this call through a callable of function type %s may produce the declared error "%s", which is neither handled here nor admitted by the enclosing function's own "errors" declaration} \
                [hir::types::show $calleeType] $name] $e
        }
    }
}

# The legality of call E whose callee (static type CALLEETYPE) is not an
# exact target, charged ERRORS (IndirectFacts): a structural callee's
# contract errors are CheckStructuralCallLegality's; an error a structural
# contract does not declare, or any error of an untyped callee, is what the
# callable fact added -- an erased callable that may reach this call.
proc hir::completions::CheckIndirectCallLegality {hirVar e calleeType errors handled enclosing} {
    upvar 1 $hirVar hir
    set contract {}
    if {[hir::types::IsFn $calleeType] || [hir::types::IsCoroutine $calleeType]} {
        set contract [dict get [hir::types::Contract $calleeType] errors]
        CheckStructuralCallLegality hir $e $calleeType [lmap name $errors {
            expr {$name in $contract ? $name : [continue]}
        }] $handled $enclosing
    }
    dict set hir exprs $e effectiveErrors [lsort -unique $errors]
    dict set hir exprs $e mayReturnNormally 1
    foreach name $errors {
        if {$name ni $contract && $name ni $handled && $name ni $enclosing} {
            hir::Diagnose hir UNHANDLED-ERROR [format \
                {this call through a callable value the completion analysis cannot identify may produce the declared error "%s" (this program passes a callable that declares it through an untyped parameter, and such a callable may reach this call), which is neither handled here nor admitted by the enclosing function's own "errors" declaration} \
                $name] $e
        }
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
    if {!$normal} {
        hir::Diagnose hir KNOWN-ERROR [format \
            {this call of "%s" can never complete normally under the facts proven for its arguments here -- it always produces %s; a handler does not make a statically known failure legal} \
            $name [ErrorsPhrase $errors]] $e
        return
    }
    # A coroutine segment is named as the operation it is written as.
    set what [switch -- $name {
        coroutine#start { expr {"coroutine construction"} }
        coroutine#resume { expr {"coroutine resume"} }
        default { format {call of "%s"} $name }
    }]
    foreach error $errors {
        if {$error ni $handled && $error ni $enclosing} {
            hir::Diagnose hir UNHANDLED-ERROR [format \
                {this %s may produce the declared error "%s", which is neither handled here nor admitted by the enclosing function's own "errors" declaration} \
                $what $error] $e
        }
    }
}

# {normal 0|1 errors NAMES verdicts}: the call-specific completion facts of
# a call of the root native NAME (argument expressions ARGEXPRS, their Ranges
# ARGRANGES here). A native's declared -errors are all effective, except
# for the natives whose errors depend only on their arguments, as their
# registered -bounds (core/native.tcl) state: an indexed access (`index`:
# list::at, mutable_array::at, mutable_array::set), whose IndexNotFound
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
        return [expr {[dict exists $hir exprs $e calleeErrors] ? [dict get $hir exprs $e calleeErrors] : {}}]
    }
    return [dict get $meta errors]
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
        # A native calling a callable argument (mutable_array::generate's
        # factory): it may complete normally, or with what the callable's
        # contract permits (the call's calleeErrors, hir/types.tcl's Call)
        # -- and with an erased-callable contract, with what the callable's
        # fact adds (IndirectFacts: a closure analyzed, an unknown value
        # charged the erased-callable contract).
        set errors [NativeDeclaredErrors $hir $e $name]
        if {[ErasedErrors $hir] ne {} && $from < [llength $argExprs]} {
            set factory [lindex $argExprs $from]
            set fact [CallableFact $hir $ctx $factory]
            if {[lindex $fact 0] eq "block"} {
                set block [lindex $fact 1]
                set n [llength [hir::get $hir $block params]]
                lassign [IndirectFacts hir ctx $guard $factory [hir::typeOf $hir $factory] \
                    {} [lrepeat $n [hir::range::unknown]] [lrepeat $n clean]] how extra
            } else {
                lassign [IndirectFacts hir ctx $guard $factory any {} {}] how extra
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
    set errors [dict get $meta errors]
    set bounds [dict get $meta bounds]
    set verdicts {}
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
    }
    return [list 1 $errors $verdicts]
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
# `list::length(xs) == N`-shaped equality (ctx.sizes). Two known sizes that
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
            lappend forms [hir::cardinality::FormConst [llength $literal]]
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
# (ctx.minSizes: `if str::length(s) > 0:`).
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
#     the container's own size form (hir/cardinality.tcl: list::length of
#     the same immutable List, or the capacity of the same MutableArray --
#     `loop i from 0 to list::length(xs): list::at(xs, i)`).
#
#   * branch relations (BranchRelations): INDEX reads a binding an
#     enclosing `if` proved below the container's size form, and INDEX's
#     own Range is provably >= 0 (`if i < 0 or i >= list::length(xs): ...
#     else: list::at(xs, i)`, or the `and` form's then branch); or the
#     container's size form was proven equal to an exact N (`if
#     list::length(bytes) == 1: list::at(bytes, 0)`), which the range check
#     above then uses.
#
# The relational proofs are tried first: an index they place in range is in
# range on every path that reaches the read, so if this walk's exact ranges
# also put it out of range, the two cannot both hold and the read is
# unreachable here (vacuously in).
#
# Nothing else is attempted: no arithmetic on a bounded variable, no
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
    } elseif {$family eq "str"} {
        # A character index (str::char_at): checked against the String's
        # length in Unicode scalars, the size str::length's guards state.
        set size [hir::cardinality::StrLength $hir $container steps]
    } else {
        set size [hir::cardinality::Capacity $hir $container steps]
    }
    set sizes [list $size]
    if {$family eq "list"} {
        set literal [LiteralListOf $hir $ctx $container]
        if {$literal ne {}} {
            lappend sizes [hir::cardinality::FormConst [llength $literal]]
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
        # Two proven sizes disagree (a branch's `list::length(xs) == 2`
        # under this call's exact one-element xs): the facts cannot hold
        # together, so this code is unreachable on this path and the read
        # vacuously designates an element.
        return in
    }
    # Relational facts first: when they place the index below a size this
    # path also knows, the read designates an element -- and should the
    # range facts below say otherwise, the facts contradict each other, so
    # the path is unreachable and the read is vacuously in range.
    lassign [hir::cardinality::Chase $hir $index steps] kind binding
    if {$kind eq "binding"} {
        if {[dict exists $ctx indexBounds $binding] && [dict get $ctx indexBounds $binding] in $sizes} {
            return in
        }
        if {$indexRange ne {never} && [dict exists $ctx upperBounds $binding]
                && [dict get $indexRange min] ne "-inf" && [dict get $indexRange min] >= 0} {
            foreach form [dict get $ctx upperBounds $binding] {
                if {$form in $sizes} {
                    return in
                }
            }
        }
    }
    # A size an enclosing branch proved at least M (`if list::length(xs) >
    # 0:`) holds every index in 0..M-1.
    set min [MinSizeOf $ctx $sizes]
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
            set inside [lmap i $exact {expr {$i >= 0 && $i < $n ? $i : [continue]}}]
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
        } elseif {$targetKind eq {} && [lindex [set indirect [IndirectFacts hir ctx $guard \
                [dict get $callNode callee] $calleeType $argExprs $argRanges]] 0] ne "none"} {
            # A handled call through a structural function type (or a
            # coroutine handle's resume): its contract's whole declared error
            # set (EvalCall's own case) -- or through an untyped value that
            # its callable fact charges (IndirectFacts).
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
            # `list::at`), or of a coroutine segment (start, resume).
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
    foreach name $handled body $handlerBodies type $handlerTypes {
        if {$type ne {never} && $callType ne {never}} {
            set range [hir::range::analyzeSequence $hir $body]
            if {![hir::range::ProvesValueAcceptedBy $type $range $callType]} {
                hir::Diagnose hir TYPE [format \
                    {handler "on %s" completes with type %s, not admissible as %s (the call's own normal result type)} \
                    $name [hir::types::show $type] [hir::types::show $callType]] $e
            }
        }
        set saved [dict get $ctx bindings]
        set relations [Relations $ctx]
        set r [Seq hir ctx $diagnose $enclosing $guard $body]
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
    set normal [expr {$result ne {never} || [dict get $ctx returned]}]
    # The successful result is the fall-through value joined with every
    # returned one (`never` when there is neither).
    set result [hir::range::join $result [dict get $ctx returnRange]]
    return [dict create normal $normal \
        errors [lsort -unique [dict keys [dict get $ctx errors]]] \
        result [expr {$result eq {never} ? [hir::range::unknown] : $result}] \
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
    return [expr {[dict exists $node effectiveErrors] ? [dict get $node effectiveErrors] : {}}]
}

# The per-check bounds verdicts checkBlock stamped on native call E
# (NativeEffectiveFacts): one element per registered bounds check, each the
# declared errors that check may still produce on every path reaching E. ""
# when E was never reached by a top-level walk or is not a bounds-bearing
# native call -- "no proof", never "proven".
proc hir::completions::BoundsVerdictsOf {hir e} {
    set node [hir::node $hir $e]
    return [expr {[dict exists $node boundsVerdicts] ? [dict get $node boundsVerdicts] : {}}]
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
    return [expr {[dict exists $node mayReturnNormally] ? [dict get $node mayReturnNormally] : 1}]
}

# The Range fact this pass computed for a checked call expression E (item
# 69's own char::scalar_value pins), or hir::range::unknown if E was never
# reached by a top-level checkBlock walk.
proc hir::completions::resultRangeOf {hir e} {
    set node [hir::node $hir $e]
    return [expr {[dict exists $node resultRangeFact] ? [dict get $node resultRangeFact] : [hir::range::unknown]}]
}
