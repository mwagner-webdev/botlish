# range.tcl -- conservative integer range analysis and the representation
# facts it proves, for native/lower.tcl's local unboxing.
#
#   set analysis [hir::range::analyze $hir $spec]
#   hir::range::of $analysis $instanceId $exprId     -> a Range
#
# This is a *representation* analysis, strictly below the semantic layer:
# nothing here changes what a Botlish `Int` means (still arbitrary
# precision), HIR types, or hir/specialize.tcl's instances. It only adds a
# second, independent fact per expression of a used specialization instance
# (hir/specialize.tcl): a conservative bound on the mathematical integer a
# reachable Int-typed expression evaluates to, given the argument facts that
# instance's calls establish. native/lower.tcl consults it to decide which
# Int-typed NIR registers may be lowered as raw (untagged) machine integers
# instead of tagged Values (see the "Representation" section of lower.tcl).
#
# Range
# -----
# A Range is {min MIN max MAX}: MIN is -inf or an arbitrary-precision
# integer, MAX is an integer or +inf, always MIN <= MAX. unknown is
# {min -inf max +inf}: no useful bound. Host arithmetic is Tcl's own
# (arbitrary precision), so range computations themselves never overflow.
#
# Small-int bound
# ----------------
# smallMin/smallMax are the *only* definition of the runtime's tagged
# small-Int range (native/src/runtime/value.rs: (n << 1) | 1 on a 64-bit
# word, n in [-2^62, 2^62)); native/lower.tcl and this module both read them
# from here, and tests/native.test checks they match the runtime's actual
# boundary.
#
# What is analyzed
# -----------------
# analyze walks the region (hir::specialize view) of every used instance,
# computing a Range for each reachable expression: constants, `+ - *` of two
# known ranges (interval arithmetic; unknown if either operand is unknown),
# natives whose -result-range metadata promises a fact (core/native.tcl),
# references to a local/param binding (the range last bound to it on this
# path), and `if` branches (joined; the known-branch shortcut reuses
# hir::types::KnownOutcome so a statically decided condition does not lose
# precision). Every other expression's range is unknown: nothing here infers
# a bound from a call whose target's own result this pass has not computed,
# from a list/aggregate read, or from a branch condition (e.g. `i <
# length(xs)` proves nothing about i's range: that needs relational
# reasoning intervals cannot express, so it is not attempted; see #19 of the
# milestone this module was written for).
#
# Parameters: interprocedural seeding
# ------------------------------------
# A parameter's range is seeded only from *syntactically evident* arguments
# passed to it by other instances' direct calls (ExternalSeeds/SeedRange: a
# syntactic look at each call's argument expressions, not a fixpoint over the
# caller's own analysis, so instances need no dependency order): a literal
# Int, or a direct call to a native whose -result-range metadata is a
# context-free guarantee (nonneg, collection-length; e.g. a parameter passed
# only `list_length(row)`-shaped arguments gets a genuine finite range with
# no relational reasoning). A call from an instance
# back to itself (hir::specialize's `calls`, self tail calls and ordinary
# same-instance recursion alike) instead feeds back through a small internal
# fixpoint: analyze the region under the current assumption, see what range
# the self calls' arguments would have, join it into the assumption, and
# repeat (widening a bound to infinity the first time it grows, so this
# always reaches a fixed point in a few passes: see #16-18 of the milestone).
# A parameter with no literal external argument and no self-recursive
# feedback stays unknown (Option A of the milestone's #13: a parameter's
# incoming magnitude is never assumed small merely because it is a Botlish
# Int).
#
# This is deliberately not a full interprocedural analysis: a non-recursive
# instance's parameters are seeded once from literal arguments and never
# revisited. That is sound (seeding never over-approximates: unknown is
# always a safe fallback) but not maximally precise; it is enough to prove
# what the corpus needs (loop counters seeded by a literal 0) without a
# cross-instance worklist.

namespace eval hir::range {
    # The runtime's tagged small-Int range (see the file header).
    variable smallMin [expr {-(1 << 62)}]
    variable smallMax [expr {(1 << 62) - 1}]
    # Self-recursive parameter feedback passes before giving up (each pass
    # either converges or widens a bound to infinity, so few are needed).
    variable maxPasses 4
}

# ---------------------------------------------------------------------------
# The Range lattice

proc hir::range::unknown {} {
    return {min -inf max +inf}
}

proc hir::range::point {n} {
    return [dict create min $n max $n]
}

proc hir::range::nonneg {} {
    return [dict create min 0 max +inf]
}

# The range of a native result tagged -result-range collection-length
# (core/native.tcl): a String/List length. Unlike nonneg this bound is
# *finite* -- native/src/runtime/vm.rs's MAX_COLLECTION_LENGTH is an actual
# enforced construction-time limit, not an assumption (see its doc comment),
# so this alone makes a direct length(...)/list_length(...) call small
# (fitsSmall below) with no relational reasoning: it is the whole proof for
# every corpus loop whose bound is a length call appearing in the loop body
# itself (e.g. reverse's `index == length(text)`).
proc hir::range::collectionLength {} {
    variable smallMax
    return [dict create min 0 max $smallMax]
}

proc hir::range::isUnknown {r} {
    return [expr {[dict get $r min] eq "-inf" && [dict get $r max] eq "+inf"}]
}

# 1 if every value in R is representable as a runtime small Int.
proc hir::range::fitsSmall {r} {
    variable smallMin
    variable smallMax
    set mn [dict get $r min]
    set mx [dict get $r max]
    return [expr {$mn ne "-inf" && $mx ne "+inf" && $mn >= $smallMin && $mx <= $smallMax}]
}

proc hir::range::Min {a b} {
    if {$a eq "-inf" || $b eq "-inf"} {
        return -inf
    }
    return [expr {$a < $b ? $a : $b}]
}

proc hir::range::Max {a b} {
    if {$a eq "+inf" || $b eq "+inf"} {
        return +inf
    }
    return [expr {$a > $b ? $a : $b}]
}

# The least upper bound of A and B: every value either could be. "never" (no
# value: dead code) is the bottom element.
proc hir::range::join {a b} {
    if {$a eq "never"} {
        return $b
    }
    if {$b eq "never"} {
        return $a
    }
    return [dict create min [Min [dict get $a min] [dict get $b min]] \
        max [Max [dict get $a max] [dict get $b max]]]
}

# NEW after a join of OLD with a freshly computed contribution: OLD with any
# bound that grew pushed to infinity, so repeated growth (an unbounded
# induction variable) reaches a fixed point in one step instead of counting
# up forever (see the milestone's #18).
proc hir::range::widen {old new} {
    set mn [dict get $new min]
    set mx [dict get $new max]
    if {$mn ne [dict get $old min]} {
        set mn -inf
    }
    if {$mx ne [dict get $old max]} {
        set mx +inf
    }
    return [dict create min $mn max $mx]
}

proc hir::range::AddBound {a b} {
    if {$a eq "-inf" || $b eq "-inf"} {
        return -inf
    }
    if {$a eq "+inf" || $b eq "+inf"} {
        return +inf
    }
    return [expr {$a + $b}]
}

# X - Y (a bound of a subtraction result, or Narrowed's "predecessor of a
# finite bound" with y=1): every caller either passes (a.min, b.max) or
# (a.max, b.min) from `sub`, or has already checked x is finite (Narrowed),
# so x is never +inf and y is never -inf; every combination below is then
# well defined.
proc hir::range::SubBound {x y} {
    if {$x eq "-inf" || $y eq "+inf"} {
        return -inf
    }
    if {$x eq "+inf" || $y eq "-inf"} {
        return +inf
    }
    return [expr {$x - $y}]
}

proc hir::range::add {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    return [dict create min [AddBound [dict get $a min] [dict get $b min]] \
        max [AddBound [dict get $a max] [dict get $b max]]]
}

proc hir::range::sub {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    return [dict create min [SubBound [dict get $a min] [dict get $b max]] \
        max [SubBound [dict get $a max] [dict get $b min]]]
}

# The product's range from the four endpoint products, or unknown if any
# bound is infinite (a sound, simple fallback: see the milestone's #6).
proc hir::range::mul {a b} {
    if {$a eq "never" || $b eq "never"} {
        return never
    }
    set amin [dict get $a min]
    set amax [dict get $a max]
    set bmin [dict get $b min]
    set bmax [dict get $b max]
    if {$amin eq "-inf" || $amax eq "+inf" || $bmin eq "-inf" || $bmax eq "+inf"} {
        return [unknown]
    }
    set lo ""
    set hi ""
    foreach p [list [expr {$amin * $bmin}] [expr {$amin * $bmax}] [expr {$amax * $bmin}] [expr {$amax * $bmax}]] {
        if {$lo eq "" || $p < $lo} { set lo $p }
        if {$hi eq "" || $p > $hi} { set hi $p }
    }
    return [dict create min $lo max $hi]
}

proc hir::range::show {r} {
    if {$r eq "never"} {
        return never
    }
    set mn [dict get $r min]
    set mx [dict get $r max]
    return "\[[expr {$mn eq {-inf} ? "-∞" : $mn}], [expr {$mx eq {+inf} ? "+∞" : $mx}]\]"
}

# ---------------------------------------------------------------------------
# Interprocedural seeding

# The Range of expression E if it is a plain integer literal, or a direct
# call to a native whose -result-range metadata (core/native.tcl) is a
# context-free guarantee (nonneg, collection-length): unknown otherwise. Both
# cases are purely syntactic facts that need no analysis of any callee or
# binding, so external call sites can be seeded from them without an
# ordering dependency between instances. The native-call case is what lets a
# parameter seeded only by e.g. `list_length(row)`-shaped arguments (never a
# literal) still get a genuine finite range (matmul's `count`/`columns`):
# the same metadata Call (below) reads for an expression already inside the
# instance being analyzed, read here for an expression outside it.
proc hir::range::SeedRange {hir e} {
    switch -- [hir::kind $hir $e] {
        const {
            set v [hir::get $hir $e value]
            if {[core::value::kind $v] ne "int"} {
                return [unknown]
            }
            return [point [core::value::intOf $v]]
        }
        call {
            lassign [hir::get $hir $e target] targetKind target
            if {$targetKind ne "native"} {
                return [unknown]
            }
            set name [dict get [hir::symbol $hir $target] name]
            switch -- [dict get [core::native::metadata $name] resultRange] {
                nonneg            { return [nonneg] }
                collection-length { return [collectionLength] }
            }
            return [unknown]
        }
    }
    return [unknown]
}

# InstanceId -> list of Range, one per parameter: the join of the literal
# argument ranges every *other* used instance's direct calls pass it.
# Self-recursive calls are excluded (Analyze below feeds those back).
proc hir::range::ExternalSeeds {hir spec} {
    set seeds [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        foreach {callExpr target} [dict get $instance calls] {
            if {$target eq $id} {
                continue
            }
            set targetBlock [dict get [dict get $spec instances $target] block]
            if {$targetBlock eq "program"} {
                continue
            }
            set nparams [llength [hir::get $hir $targetBlock params]]
            set current [expr {[dict exists $seeds $target] ? [dict get $seeds $target] : [lrepeat $nparams never]}]
            set next {}
            foreach argExpr [hir::get $hir $callExpr args] c $current {
                lappend next [join $c [SeedRange $hir $argExpr]]
            }
            dict set seeds $target $next
        }
    }
    return $seeds
}

# ---------------------------------------------------------------------------
# One region, under one assumption of its parameters' ranges

# Types EXPRS in order (a block body, an if branch): the last one's range,
# or never if some expression never completes normally.
proc hir::range::Sequence {hirVar ctxVar exprs} {
    upvar 1 $hirVar hir $ctxVar ctx
    set result [unknown]
    foreach e $exprs {
        set result [Expr hir ctx $e]
        if {$result eq "never"} {
            break
        }
    }
    return $result
}

proc hir::range::Expr {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {![hir::get $hir $e reachable]} {
        return never
    }
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const {
            set v [dict get $node value]
            set r [expr {[core::value::kind $v] eq "int" ? [point [core::value::intOf $v]] : [unknown]}]
            dict set ctx exprs $e $r
            return $r
        }
        ref {
            if {[dict get $node binding] eq "" || [dict get $node init] eq "no"} {
                return never
            }
            set b [dict get $node binding]
            set bindings [dict get $ctx bindings]
            set r [expr {[dict exists $bindings $b] ? [dict get $bindings $b] : [unknown]}]
            dict set ctx exprs $e $r
            return $r
        }
        bind {
            set r [Expr hir ctx [dict get $node value]]
            set b [dict get $node binding]
            if {$r ne "never" && ![dict get $node duplicate]
                    && [dict get [hir::binding $hir $b] kind] eq "local"} {
                dict set ctx bindings $b $r
            }
            return $r
        }
        block {
            # A nested block's body is its own region; nothing to compute here.
            return [unknown]
        }
        call {
            return [Call hir ctx $e $node]
        }
        if {
            return [If hir ctx $e $node]
        }
        loop {
            set saved [dict get $ctx bindings]
            foreach child [dict get $node body] {
                Expr hir ctx $child
            }
            dict set ctx bindings $saved
            return [unknown]
        }
        return {
            set value [dict get $node value]
            set r [expr {$value eq "" ? [unknown] : [Expr hir ctx $value]}]
            if {$r ne "never" && [dict get $node target] ne ""} {
                dict set ctx returnRange [join [dict get $ctx returnRange] $r]
            }
            return never
        }
        break {
            if {[dict get $node value] ne ""} {
                Expr hir ctx [dict get $node value]
            }
            return never
        }
        continue {
            return never
        }
        ok - error {
            set value [Expr hir ctx [dict get $node value]]
            return [expr {$value eq "never" ? "never" : [unknown]}]
        }
        default {
            return [unknown]
        }
    }
}

proc hir::range::Call {hirVar ctxVar e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set argRanges {}
    set dead 0
    foreach a [dict get $node args] {
        set r [Expr hir ctx $a]
        lappend argRanges $r
        if {$r eq "never"} {
            set dead 1
        }
    }
    if {$dead} {
        return never
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "native"} {
        set name [dict get [hir::symbol $hir $target] name]
        set result [unknown]
        if {$name in {+ - *} && [llength $argRanges] == 2} {
            lassign $argRanges x y
            switch -- $name {
                + { set result [add $x $y] }
                - { set result [sub $x $y] }
                * { set result [mul $x $y] }
            }
        } else {
            set meta [core::native::metadata $name]
            switch -- [dict get $meta resultRange] {
                nonneg            { set result [nonneg] }
                collection-length { set result [collectionLength] }
            }
        }
        dict set ctx exprs $e $result
        return $result
    }
    if {$targetKind eq "block" && [dict exists [dict get $ctx instanceCalls] $e]} {
        # Every exact call this pass actually reaches (dead/unreachable
        # call expressions never get here: Expr's reachability check above
        # returns never before Call is even entered, so an argument from an
        # unreachable path never contributes -- spec #31). Self and
        # cross-instance targets are recorded uniformly; hir::range::analyze
        # separates them when folding (self feeds this same instance's own
        # fixpoint, cross feeds the callee's).
        dict lappend ctx calls [list [dict get [dict get $ctx instanceCalls] $e] $argRanges]
    }
    return [unknown]
}

proc hir::range::If {hirVar ctxVar e node} {
    upvar 1 $hirVar hir $ctxVar ctx
    set condition [dict get $node condition]
    Expr hir ctx $condition
    set known [hir::types::KnownOutcome $hir $condition]
    set saved [dict get $ctx bindings]
    set branches [dict create]
    set after [dict create]
    foreach {outcome role} {1 then 0 else} {
        if {$known ne "" && $known != $outcome} {
            dict set branches $outcome never
            dict set after $outcome $saved
            continue
        }
        dict set ctx bindings $saved
        foreach {b r} [ComparisonNarrowing $hir $ctx $condition $outcome] {
            dict set ctx bindings $b $r
        }
        dict set branches $outcome [Sequence hir ctx [dict get $node ${role}Body]]
        dict set after $outcome [dict get $ctx bindings]
    }
    # What code textually after this "if" sees (spec #14's whole point: an
    # early-return/break guard -- the corpus's actual shape, e.g. reverse's
    # `if index == length(text): return ...` with no else, the recursive
    # call a later sibling statement, not nested in an else branch -- must
    # let a narrowed bound reach that sibling code, not just the branch body
    # itself). If one outcome never completes normally, only the other's
    # bindings (narrowed or not) are reachable afterward; if both are alive,
    # only the join of the two is safe. Every existing (pre-this-milestone)
    # binding is unchanged by either branch unless ComparisonNarrowing
    # touched it (an existing binding's range in ctx is otherwise never
    # rewritten -- only a fresh `bind` adds a new BindingId), so for any
    # program before this addition this reduces to plain restoration, same
    # as before.
    dict set ctx bindings [JoinBindings $saved [dict get $after 1] [dict get $after 0] $branches]
    if {$known ne ""} {
        return [dict get $branches $known]
    }
    return [join [dict get $branches 1] [dict get $branches 0]]
}

# The bindings dict code after an "if" sees, given SAVED (bindings entering
# it), AFTER1/AFTER0 (bindings leaving each branch, meaningful only when that
# branch is alive) and BRANCHES (each outcome's Range-or-never, to tell which
# branches are alive).
proc hir::range::JoinBindings {saved after1 after0 branches} {
    set dead1 [expr {[dict get $branches 1] eq "never"}]
    set dead0 [expr {[dict get $branches 0] eq "never"}]
    if {$dead1 && $dead0} {
        return $saved
    }
    if {$dead1} {
        return $after0
    }
    if {$dead0} {
        return $after1
    }
    set result [dict create]
    dict for {b r} $saved {
        set r1 [expr {[dict exists $after1 $b] ? [dict get $after1 $b] : $r}]
        set r0 [expr {[dict exists $after0 $b] ? [dict get $after0 $b] : $r}]
        dict set result $b [join $r1 $r0]
    }
    return $result
}

# ---------------------------------------------------------------------------
# Branch-derived narrowing (spec #14): what a `< <= > >=` condition directly
# says about a ref'd local/param binding's range on the branch its outcome
# (1 true, 0 false) selects. Sound and general -- no step/monotonicity
# reasoning, unlike hir/induction.tcl's equality-termination proof. `==`
# establishes nothing here (spec #15: equality alone never bounds a
# magnitude without an independent monotonicity fact).

# The binding a `ref` expression E names, if it is a proven-initialized local
# or parameter (the only bindings ctx bindings tracks a range for), else "".
#
# Soundness: `local` and `param` are hir/hir.tcl's two immutable-lexical-
# binding kinds (binding kind enum: root | ambient | param | local) -- both
# are bound exactly once, to a value that never changes for the life of the
# binding (spec #2, #25: a raw representation is a downstream consequence,
# never a source-semantics change, and Botlish has no parameter mutation to
# begin with). `root` (builtins/constants) and `ambient` (an open host
# environment's names in -mode sequence: not a checked program, no static
# facts to narrow) are excluded, unchanged from before this milestone.
proc hir::range::RefBinding {hir e} {
    if {[hir::kind $hir $e] ne "ref"} {
        return ""
    }
    set b [hir::get $hir $e binding]
    if {$b eq "" || [hir::get $hir $e init] eq "no"} {
        return ""
    }
    if {[dict get [hir::binding $hir $b] kind] ni {local param}} {
        return ""
    }
    return $b
}

# {binding Range ...}: what CONDITION (a call already evaluated into CTX's
# exprs, so its argument ranges are available) establishes when it evaluates
# to OUTCOME, for each side that is a ref'd local/param binding.
proc hir::range::ComparisonNarrowing {hir ctx condition outcome} {
    set node [hir::node $hir $condition]
    if {[dict get $node kind] ne "call"} {
        return {}
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native"} {
        return {}
    }
    set name [dict get [hir::symbol $hir $target] name]
    set args [dict get $node args]
    if {[llength $args] != 2} {
        return {}
    }
    if {$name eq "=="} {
        return [EqualityNarrowing $hir $ctx $condition $args $outcome]
    }
    if {$name ni {< <= > >=}} {
        return {}
    }
    set op $name
    if {!$outcome} {
        # The false branch's fact is the comparison's negation.
        set op [dict get {< >= <= > > <= >= <} $op]
    }
    lassign $args ea eb
    set exprs [dict get $ctx exprs]
    set ra [expr {[dict exists $exprs $ea] ? [dict get $exprs $ea] : [unknown]}]
    set rb [expr {[dict exists $exprs $eb] ? [dict get $exprs $eb] : [unknown]}]
    set facts [dict create]
    set ba [RefBinding $hir $ea]
    if {$ba ne ""} {
        set n [Narrowed $op $ra $rb]
        if {$n ne ""} {
            dict set facts $ba $n
        }
    }
    set bb [RefBinding $hir $eb]
    if {$bb ne ""} {
        # "B [mirror of OP] A" is the same fact, stated about B.
        set mirror [dict get {< > <= >= > < >= <=} $op]
        set n [Narrowed $mirror $rb $ra]
        if {$n ne ""} {
            dict set facts $bb $n
        }
    }
    return $facts
}

# ComparisonNarrowing's `==` case. Equality alone proves nothing (spec #15):
# unless hir/induction.tcl already proved this exact "if P == B" sound as an
# equality-termination guard (ctx monotone, keyed by this same condition's
# expression id -- hir/induction.tcl's Guard found the identical HIR node,
# so it is the same P and the same B), in which case its false ("P != B")
# branch is exactly "P < B" / "P > B" per that proof, the same fact a
# `<`/`>` guard would give. Unlike the generic comparison case above, OP here
# is derived from the proof's step direction, not from the source order of
# CONDITION's two operands, so this resolves P and B itself (whichever side
# each is) rather than trying both sides symmetrically.
proc hir::range::EqualityNarrowing {hir ctx condition args outcome} {
    if {$outcome || ![dict exists [dict get $ctx monotone] $condition]} {
        return {}
    }
    lassign [dict get [dict get $ctx monotone] $condition] p step
    lassign $args ea eb
    set boundExpr [expr {[RefBinding $hir $ea] eq $p ? $eb : $ea}]
    set exprs [dict get $ctx exprs]
    set boundRange [expr {[dict exists $exprs $boundExpr] ? [dict get $exprs $boundExpr] : [unknown]}]
    set current [dict get [dict get $ctx bindings] $p]
    set n [Narrowed [expr {$step > 0 ? "<" : ">"}] $current $boundRange]
    return [expr {$n eq "" ? {} : [dict create $p $n]}]
}

# The Range of X narrowed by "X OP Y", given X's own range RX and Y's range
# RY, or "" if OP gives no new information (Y unbounded on the relevant
# side).
proc hir::range::Narrowed {op rx ry} {
    set mn [dict get $rx min]
    set mx [dict get $rx max]
    switch -- $op {
        < {
            if {[dict get $ry max] eq "+inf"} { return "" }
            set mx [Min $mx [SubBound [dict get $ry max] 1]]
        }
        <= {
            if {[dict get $ry max] eq "+inf"} { return "" }
            set mx [Min $mx [dict get $ry max]]
        }
        > {
            if {[dict get $ry min] eq "-inf"} { return "" }
            set mn [Max $mn [AddBound [dict get $ry min] 1]]
        }
        >= {
            if {[dict get $ry min] eq "-inf"} { return "" }
            set mn [Max $mn [dict get $ry min]]
        }
        default { return "" }
    }
    return [dict create min $mn max $mx]
}

# The region of instance ID's view HIR (already specialize::view'd): a dict
#   exprs   ExprId -> Range, for every reachable expression this pass could
#           say something about
#   result  the range of the region's normal completion (never if none)
#   calls   list of {TargetInstanceId ArgumentRangeList}, one per exact
#           block call this pass reached (hir::specialize's own "calls" --
#           self tail calls, ordinary same-instance recursion, and calls of
#           other instances alike); hir::range::analyze separates self from
#           cross-instance when it folds these into entry facts
proc hir::range::AnalyzeInstance {hir id instanceCalls block params assumed monotone} {
    set ctx [dict create bindings [dict create] returnRange never exprs [dict create] \
        calls {} id $id instanceCalls $instanceCalls monotone $monotone]
    foreach b $params r $assumed {
        dict set ctx bindings $b $r
    }
    set body [expr {$block eq "program" ? [hir::roots $hir] : [hir::get $hir $block body]}]
    set final [Sequence hir ctx $body]
    set result [join $final [dict get $ctx returnRange]]
    return [dict create exprs [dict get $ctx exprs] result $result calls [dict get $ctx calls]]
}

# The block ExprIds that materialize (hir/aot.tcl::materializedBlocks) as an
# escaping Block value somewhere in the used instances' reachable code: a
# value that can be called through unknown dynamic dispatch this analysis
# has no edges for (spec #9, #28-29). Only a block's *generic* instance can
# ever run such a call (hir::specialize's own materialization rule always
# resolves a materialized value to the block's generic instance --
# specialize.tcl's own header, "Closures over values stay generic" and "not
# a static block"): a *specialized* instance's only possible callers are
# exactly the direct calls hir::specialize resolved to it, so it is never
# open regardless of this set.
proc hir::range::OpenInstances {spec} {
    set materialized [dict create]
    foreach id [dict get $spec used] {
        foreach block [dict get [dict get $spec instances $id] values] {
            dict set materialized $block 1
        }
    }
    set open [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        if {[dict get $instance generic] && [dict get $instance block] ne "program"
                && [dict exists $materialized [dict get $instance block]]} {
            dict set open $id 1
        }
    }
    return $open
}

# Runs instance ID to its own local self-call fixpoint (self tail calls and
# ordinary same-instance recursion, exactly the mechanism this module had
# before interprocedural caller-propagation existed): ASSUMED is the entry
# Range per parameter to start from; LOCKED marks indices hir/induction.tcl
# already proved (never touched -- see analyze's own comment on this).
# Returns {outcome ASSUMED'}: the last pass's AnalyzeInstance result and the
# (possibly narrower-information, widened) settled entry Ranges.
proc hir::range::SettleInstance {hir id instanceCalls block params assumed locked monotone} {
    variable maxPasses
    set n [llength $params]
    set outcome {}
    for {set pass 1} {$pass <= $maxPasses} {incr pass} {
        set outcome [AnalyzeInstance $hir $id $instanceCalls $block $params $assumed $monotone]
        set selfArgs {}
        foreach pair [dict get $outcome calls] {
            lassign $pair target argRanges
            if {$target eq $id} {
                lappend selfArgs $argRanges
            }
        }
        if {$selfArgs eq ""} {
            break
        }
        set next {}
        for {set i 0} {$i < $n} {incr i} {
            if {[dict exists $locked $i]} {
                lappend next [lindex $assumed $i]
                continue
            }
            set r never
            foreach call $selfArgs {
                set r [join $r [lindex $call $i]]
            }
            lappend next [join [lindex $assumed $i] $r]
        }
        if {$next eq $assumed} {
            break
        }
        set widened {}
        foreach a $assumed w $next {
            lappend widened [widen $a $w]
        }
        set assumed $widened
    }
    return [list $outcome $assumed]
}

# ---------------------------------------------------------------------------
# Entry point

# Range facts for every used instance of specialization ANALYSIS (the return
# of hir::specialize::analyze) over program HIR. Returns a dict:
#   instances  InstanceId -> {params {Range ...} exprs {ExprId Range ...} result Range}
#
# Two cooperating mechanisms feed a used instance's parameter entry facts:
#
#   * SettleInstance's own self-call fixpoint (unchanged from before this
#     milestone): a self-recursive/self-tail call's argument ranges, fed
#     back into the same instance's own assumption.
#   * caller propagation (new): an *exact* call from another used instance
#     (hir::specialize's own call resolution -- never an open/dynamic
#     dispatch, which never appears in an instance's "calls" at all) seeds
#     the callee with the caller's own already-proven Range for the
#     argument expression, not just a syntactically literal one.
#
# Both read the caller/callee's Range the *same* way this module always
# has (AnalyzeInstance's ctx exprs), so an argument may be a Ref, an
# arithmetic expression, a branch-narrowed parameter reference, a known
# native result, or anything else this analysis already prices in -- never
# only a literal (spec #8).
#
# This is an ordinary monotone dataflow fixpoint over the "used" instance
# graph (self-recursion and, rarely, mutual recursion between distinct
# instances are its only cycles): each round re-settles every instance from
# its current entry facts, then folds every exact call's argument ranges
# into its callee's facts (join across every caller -- a safe hull, never
# an intersection or "whichever call site ran first": spec #11) and widens
# any bound that grew (same widen() as the self-call case) so growth jumps
# straight to infinity in one step instead of climbing forever. A bound can
# then change at most twice (unseen -> a first concrete value -> widened to
# infinity), so convergence needs only as many rounds as the longest
# caller-to-callee chain among the used instances, comfortably inside the
# round budget below; stopping once nothing changed in a full round is
# still sound if the budget is ever exhausted first, since every entry fact
# an unfinished fixpoint leaves behind is still real, if not maximally
# precise, evidence (never a guess).
#
# An instance flagged open (OpenInstances) never receives caller-propagated
# facts for any parameter: its set of known callers is not the full set of
# actual callers (spec #28-29), so joining only the known ones would be
# unsound over-narrowing; it keeps whatever hir/induction.tcl proved and is
# otherwise unknown, exactly as an instance with no known callers at all
# already was before this milestone.
proc hir::range::analyze {hir spec} {
    # hir/induction.tcl is fed only the old, purely syntactic external seeds
    # (a literal argument, or a direct call to a native with context-free
    # -result-range metadata) -- unchanged by, and entirely independent of,
    # this proc's own caller-propagated seeding below, so its proof is
    # exactly as sound and exactly as narrow as it was before this
    # milestone (spec #17, #44: no induction capability change here).
    set literalSeeds [ExternalSeeds $hir $spec]
    # hir/induction.tcl's proof, when it fires, replaces a parameter's own
    # self-call feedback with a fixed answer (see below): unlike an ordinary
    # seed it is a *conclusion*, not just a starting guess, so widen must
    # never touch it, or the very growth its equality-termination argument
    # already accounts for would immediately widen it back to infinity (see
    # hir/induction.tcl's header).
    set induction [hir::induction::analyze $hir $spec $literalSeeds]
    set open [OpenInstances $spec]

    set ids [dict get $spec used]
    set blockOf [dict create]
    set paramsOf [dict create]
    set viewOf [dict create]
    set instanceCallsOf [dict create]
    set monotoneOf [dict create]
    set lockedOf [dict create]
    set assumed [dict create]
    set outcomes [dict create]
    # Indices this instance's own self-call feedback has, at some round,
    # actually *destroyed*: widened a concrete entry fact all the way to
    # unknown (never just started unknown with nothing yet to say -- see
    # the caller-propagation fold below, which must tell the two apart).
    set poisonedOf [dict create]

    foreach id $ids {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        dict set blockOf $id $block
        set params [expr {$block eq "program" ? {} : [hir::get $hir $block params]}]
        dict set paramsOf $id $params
        dict set viewOf $id [hir::specialize::view $hir $spec $id]
        dict set instanceCallsOf $id [dict get $instance calls]
        dict set monotoneOf $id [hir::induction::monotone $induction $id]

        set locked [dict create]
        set init {}
        set i 0
        foreach p $params {
            set override [hir::induction::of $induction $id $i]
            if {$override ne ""} {
                dict set locked $i 1
                lappend init $override
            } else {
                lappend init [unknown]
            }
            incr i
        }
        dict set lockedOf $id $locked
        dict set assumed $id $init
        dict set poisonedOf $id [dict create]
    }

    # Whether ID calls itself at all (self tail calls and ordinary
    # same-instance recursion alike -- hir::specialize's own "calls", not a
    # separate notion): the fold below must tell a *genuinely* self-derived
    # "unknown" (SettleInstance ran, found real self-call evidence, and it
    # proved the entry unbounded -- see POISONEDOF) apart from an
    # instance with no self-calls at all, whose entry fact is unknown only
    # because nothing has said otherwise yet, never a conclusion. Only the
    # first kind is safe to fold caller evidence into by *union* (it must
    # never lose ground); the second is free to be replaced outright by a
    # fresher, more precise caller computation as upstream callers
    # themselves finish converging (spec #12-13, #15: this is exactly why
    # work's parameter, having no self-calls, can still tighten from
    # drive's own still-converging else-branch fact once drive settles,
    # instead of being stuck at whatever drive's first, roughest pass gave
    # it).
    set selfRecursiveOf [dict create]
    foreach id $ids {
        dict set selfRecursiveOf $id [expr {$id in [dict values [dict get $instanceCallsOf $id]]}]
    }

    # A bound on rounds that scales with the instance count (a chain of N
    # instances can need up to N rounds for its first real value to
    # propagate end to end) plus a fixed cushion for the self-call/widen
    # settling every instance also does each round -- finite, deterministic,
    # never a per-interval or per-benchmark constant (spec #12, #24, #37).
    set roundBudget [expr {[llength $ids] + 8}]
    for {set round 1} {$round <= $roundBudget} {incr round} {
        set changed 0
        set contributions [dict create]
        foreach id $ids {
            set before [dict get $assumed $id]
            lassign [SettleInstance [dict get $viewOf $id] $id [dict get $instanceCallsOf $id] \
                [dict get $blockOf $id] [dict get $paramsOf $id] $before \
                [dict get $lockedOf $id] [dict get $monotoneOf $id]] outcome settled
            dict set outcomes $id $outcome
            if {$settled ne $before} {
                set locked [dict get $lockedOf $id]
                set poisoned [dict get $poisonedOf $id]
                set i 0
                foreach b $before s $settled {
                    if {![dict exists $locked $i] && $b ne [unknown] && $s eq [unknown]} {
                        # Self-call feedback just destroyed a real entry
                        # fact (a genuine widen, not "nothing proven yet"):
                        # permanent, since a wider starting fact could only
                        # make the same self-recursion at least as
                        # unbounded, never less (the caller-propagation
                        # fold below must never treat this "unknown" as an
                        # empty slate safe to adopt a caller's Range into).
                        dict set poisoned $i 1
                    }
                    incr i
                }
                dict set poisonedOf $id $poisoned
                dict set assumed $id $settled
                set changed 1
            }
            foreach pair [dict get $outcome calls] {
                lassign $pair target argRanges
                if {$target eq $id || [dict exists $open $target]} {
                    continue
                }
                set current [expr {[dict exists $contributions $target]
                    ? [dict get $contributions $target] : [lrepeat [llength $argRanges] never]}]
                set next {}
                foreach c $current r $argRanges {
                    lappend next [join $c $r]
                }
                dict set contributions $target $next
            }
        }
        dict for {target contribution} $contributions {
            set locked [dict get $lockedOf $target]
            set poisoned [dict get $poisonedOf $target]
            set selfRecursive [dict get $selfRecursiveOf $target]
            set current [dict get $assumed $target]
            set next {}
            set i 0
            foreach o $current c $contribution {
                if {[dict exists $locked $i]} {
                    # Never touched: induction's own conclusion (see the
                    # header on this proc), not an ordinary seed to widen.
                    lappend next $o
                } elseif {!$selfRecursive} {
                    # No self-calls at all (SELFRECURSIVEOF, above): this
                    # parameter's entry fact is *entirely* a function of its
                    # exact callers, nothing here to preserve against, so
                    # each round recomputes it fresh from this round's
                    # calls instead of folding onto -- and thereby never
                    # improving past -- a rougher fact an earlier round
                    # (necessarily computed from a caller that had not yet
                    # settled itself: work's caller drive is a self-tail
                    # loop that only reaches its own [-∞,500] over several
                    # rounds) happened to produce first.
                    lappend next [expr {$c eq "never" ? [unknown] : $c}]
                } elseif {[dict exists $poisoned $i]} {
                    # This instance's own self-recursion already proved the
                    # entry unbounded (id-processing loop, above): permanent,
                    # and a caller's Range -- real or not yet -- cannot
                    # un-prove it.
                    lappend next [unknown]
                } elseif {$o eq [unknown]} {
                    # Self-recursive, but its own feedback has not (yet, or
                    # ever, if it never needs to move past its seed) said
                    # anything: the first real caller evidence is this
                    # parameter's first fact, adopted exactly, for the same
                    # reason as the non-self-recursive case above.
                    lappend next [expr {$c eq "never" ? [unknown] : $c}]
                } else {
                    # A genuine, already-established self-derived fact
                    # (drive's own [-∞,500], reached through its own
                    # self-tail widening): callers can only ever add to it,
                    # never replace it outright, and widen keeps that
                    # addition from taking many rounds to reach its own
                    # fixed point.
                    lappend next [widen $o [join $o $c]]
                }
                incr i
            }
            if {$next ne $current} {
                set changed 1
            }
            dict set assumed $target $next
        }
        if {!$changed} {
            break
        }
    }

    set instances [dict create]
    foreach id $ids {
        set outcome [dict get $outcomes $id]
        dict set instances $id [dict create params [dict get $assumed $id] \
            exprs [dict get $outcome exprs] result [dict get $outcome result]]
    }
    return [dict create instances $instances induction $induction]
}

# The Range of expression E as instance ID's analysis proved it, or unknown.
proc hir::range::of {analysis id e} {
    set exprs [dict get [dict get $analysis instances $id] exprs]
    if {[dict exists $exprs $e]} {
        return [dict get $exprs $e]
    }
    return [unknown]
}
