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
# carries error obligations here to begin with).

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
}

proc hir::completions::resetCache {} {
    variable cache
    set cache [dict create]
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

proc hir::completions::NewCtx {} {
    return [dict create bindings [dict create] exact [dict create] exactList [dict create] \
        exprs [dict create] errors [dict create] analyses 0 returned 0]
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
            if {$b eq {} || [dict get $node init] eq {no}} {
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
            # itself contributes.
            set value [dict get $node value]
            set r [expr {$value eq {} ? [hir::range::unknown] : [Eval hir ctx $diagnose $enclosing $guard $value]}]
            if {$r ne {never} && [dict get $node target] ne {}} {
                dict set ctx returned 1
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
            dict set ctx errors [dict get $node name] 1
            return never
        }
        ok - error {
            set r [Eval hir ctx $diagnose $enclosing $guard [dict get $node value]]
            return [expr {$r eq {never} ? {never} : [hir::range::unknown]}]
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
    set facts [hir::range::ComparisonNarrowing $hir $shim $condition $outcome]
    if {[FactsContradictory $facts]} {
        return [list 0 {}]
    }
    return [list 1 $facts]
}

proc hir::completions::EvalIf {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set condition [dict get $node condition]
    Eval hir ctx $diagnose $enclosing $guard $condition
    set saved [dict get $ctx bindings]
    set branches [dict create]
    set after [dict create]
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
        dict set branches $outcome [Seq hir ctx $diagnose $enclosing $guard [dict get $node ${role}Body]]
        dict set after $outcome [dict get $ctx bindings]
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
    Seq hir ctx $diagnose $enclosing $guard [dict get $node body]
    dict set ctx bindings $saved
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
proc hir::completions::EvalListloop {hirVar ctxVar diagnose enclosing guard e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set iterable [dict get $node iterable]
    set elements [LiteralListOf $hir $ctx $iterable]
    if {$elements eq {}} {
        return [EvalLoop hir ctx $diagnose $enclosing $guard $e $node]
    }
    set elementBinding [dict get $node elementBinding]
    set saved [dict get $ctx bindings]
    set savedExact [dict get $ctx exact]
    set result [hir::range::unknown]
    foreach v $elements {
        dict set ctx bindings $saved
        dict set ctx exact $savedExact
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
    return [expr {$result eq {never} ? {never} : [hir::range::unknown]}]
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
# lowering/codegen -- item 60-61): `char_codepoint` (lib/char.bot's
# char::codepoint) is a Unicode scalar value, therefore always in
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
    if {$name eq {char_codepoint} && [llength $argExprs] == 1} {
        set arg [lindex $argExprs 0]
        set v [ExactValueOf $hir $ctx $arg]
        if {$v ne {} && [core::value::kind $v] eq {UnicodeChar}} {
            return [hir::range::point [core::value::charOf $v]]
        }
        return [dict create min 0 max 0x10FFFF]
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
        set result [hir::range::ConstrainType $hir $e [NativeResultRange $hir $ctx $name $argExprs $argRanges]]
        dict set ctx exprs $e $result
        if {$diagnose} {
            dict set hir exprs $e resultRangeFact $result
        }
        return $result
    }
    if {$targetKind ne {block}} {
        return [hir::range::unknown]
    }
    set argExact [ArgExactValues $hir $ctx $argExprs]
    set argExactLists [ArgExactLists $hir $ctx $argExprs]
    lassign [EffectiveFacts hir ctx $target $argRanges $argExact $argExactLists $guard] normal errors resultRange
    if {$diagnose} {
        CheckCallLegality hir $e $target $normal $errors {} $enclosing
    }
    # A bare (unhandled) call's own effective errors are not absorbed here --
    # they propagate straight through to whatever encloses this expression,
    # exactly like a direct `fail` (item 30-32): merge them into this walk's
    # own ctx.errors so an *enclosing* call site (this whole function, when
    # it is itself analyzed as an exact callee under analyzeBlock) sees them
    # as part of ITS own possible completions too.
    MergeErrors ctx $errors
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
# ARGRANGES/ARGEXACT/ARGEXACTLISTS: {normal 0|1 errors NAME-LIST resultRange
# Range}. Recurses via analyzeBlock (item 33), guarded against cycles (item
# 34) and bounded by hir::completions::maxAnalyses (item 35).
proc hir::completions::EffectiveFacts {hirVar ctxVar target argRanges argExact argExactLists guard} {
    upvar 1 $hirVar hir $ctxVar ctx
    variable maxAnalyses
    variable cache
    set declared [hir::get $hir $target declaredErrors]
    if {[dict exists $guard $target]} {
        # Self/mutual recursion: never assume an error impossible because
        # analysis recursed (item 34) -- the conservative, always-sound
        # fallback is the callee's own full declared contract.
        return [list 1 $declared [hir::range::unknown]]
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
        return [list 1 $declared [hir::range::unknown]]
    }
    set key [list $target $argRanges $argExact $argExactLists]
    if {[dict exists $cache $key]} {
        set sub [dict get $cache $key]
        return [list [dict get $sub normal] [dict get $sub errors] [dict get $sub result]]
    }
    set analyses [dict get $ctx analyses]
    if {$analyses >= $maxAnalyses} {
        # Proof budget exhausted (item 35): fall back conservatively, same
        # as a recursion cycle -- never reject a correct program merely
        # because precision ran out.
        return [list 1 $declared [hir::range::unknown]]
    }
    dict set ctx analyses [expr {$analyses + 1}]
    set sub [analyzeBlock $hir $target $argRanges $argExact $argExactLists [dict merge $guard [dict create $target 1]]]
    dict set cache $key $sub
    return [list [dict get $sub normal] [dict get $sub errors] [dict get $sub result]]
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
    # pass itself, and never consulted by any backend/codegen.
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
        if {$targetKind eq {block}} {
            set argExact [ArgExactValues $hir $ctx $argExprs]
            set argExactLists [ArgExactLists $hir $ctx $argExprs]
            lassign [EffectiveFacts hir ctx $target $argRanges $argExact $argExactLists $guard] normal errors callResult
            if {$diagnose} {
                CheckCallLegality hir $e $target $normal $errors $handled $enclosing
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
        set r [Seq hir ctx $diagnose $enclosing $guard $body]
        dict set ctx bindings $saved
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
# Range facts ARGRANGES, scalar exact-value facts ARGEXACT, and List-typed
# exact-element facts ARGEXACTLISTS (never diagnoses): {normal 0|1 errors
# NAME-LIST result Range}.
proc hir::completions::analyzeBlock {hir block argRanges argExact argExactLists guard} {
    set ctx [NewCtx]
    set params [hir::get $hir $block params]
    foreach b $params r $argRanges {
        dict set ctx bindings $b $r
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
    # Normal completion is possible either by falling off the end of the
    # body (RESULT ne never) or through any reachable `return` (ctx.returned
    # -- see Eval's own `return` case): both are ordinary successful
    # completions of this function, never a failure.
    set normal [expr {$result ne {never} || [dict get $ctx returned]}]
    return [dict create normal $normal \
        errors [lsort -unique [dict keys [dict get $ctx errors]]] \
        result [expr {$result eq {never} ? [hir::range::unknown] : $result}]]
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
        set body [hir::get $hir $block body]
        set guard [dict create $block 1]
    }
    Seq hir ctx 1 $enclosingErrors $guard $body
}

# ---------------------------------------------------------------------------
# Test/inspection accessors (item 89): the facts CheckCallLegality stashed
# on a checked call/handle node E, or "" if E was never reached by any
# top-level checkBlock walk (dead/unreachable code).
proc hir::completions::effectiveErrorsOf {hir e} {
    set node [hir::node $hir $e]
    return [expr {[dict exists $node effectiveErrors] ? [dict get $node effectiveErrors] : {}}]
}

proc hir::completions::mayReturnNormallyOf {hir e} {
    set node [hir::node $hir $e]
    return [expr {[dict exists $node mayReturnNormally] ? [dict get $node mayReturnNormally] : 1}]
}

# The Range fact this pass computed for a checked call expression E (item
# 69's own char::codepoint pins), or hir::range::unknown if E was never
# reached by a top-level checkBlock walk.
proc hir::completions::resultRangeOf {hir e} {
    set node [hir::node $hir $e]
    return [expr {[dict exists $node resultRangeFact] ? [dict get $node resultRangeFact] : [hir::range::unknown]}]
}
