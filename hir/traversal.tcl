# traversal.tcl -- recognition of a provably forward, +1-per-iteration
# String scan whose repeated single-character access can carry its physical
# UTF-8 byte position across the loop instead of re-locating it from byte 0
# on every iteration.
#
#   set analysis [hir::traversal::analyze $hir $spec $stringregion]
#   hir::traversal::plan $analysis $instanceId   -> "" | a TraversalPlan dict
#
# The problem (the milestone this module was written for): Botlish String
# indices are semantic Unicode-scalar positions, so locating character index
# i in a String whose text is not all ASCII means decoding forward from byte
# 0 (rt_substr's/rt_str_region_eq's non-ASCII paths, native/src/runtime/
# ops.rs). A self-tail loop that reads text at a monotonically increasing
# index -- examples/stdlib/csv.bot's and examples/stdlib/ai_text_clean.bot's
# shared `peek(text, i)` idiom, repeated every iteration -- therefore
# re-decodes the same already-traversed prefix on every iteration, an O(n)
# cost paid O(n) times.
#
# What this module proves, and what it does not
# -----------------------------------------------
# This is a *representation* analysis, in exactly the sense hir/range.tcl,
# hir/escape.tcl and hir/stringregion.tcl are: nothing here changes what a
# Botlish String or a semantic character index *means*, or hir/specialize.
# tcl's instances. It only adds a third fact, alongside a Range
# (hir/range.tcl) and a StringRegion (hir/stringregion.tcl), that native/
# lower.tcl's "String traversal" section may use to choose a cheaper
# *execution* representation for a value that stays exactly the semantic
# String/Int it always was.
#
# The one shape recognized (deliberately narrow -- see the milestone's #5,
# #7, #24-27): a used, non-program instance I with
#
#   * a self-tail call (hir::aot::selfTailCalls, exactly native/lower.tcl's
#     own `self` test) whose argument at some parameter P0 is P0's own
#     current value plus exactly 1 (hir::induction::ClassifyArg's `{step 1}`
#     -- the same per-argument classifier hir/induction.tcl's own
#     equality-termination proof uses, reused here as-is: #15 of the
#     milestone). No other step, and no decreasing (`- 1`) loop, is
#     recognized (#24-25): "unsupported relational form" for anything else.
#   * every direct (non-self-tail) caller of I, anywhere in the program,
#     passing exactly the literal constant 0 for that same parameter
#     (ZeroStart) -- so P0's value the first time the loop runs is always
#     the physical byte offset 0, with no seek needed to establish the
#     starting correspondence (#7: a caller that cannot be proven to start
#     at 0, or that is never called directly at all, is simply not
#     recognized -- the "zero-start loops first" limitation the milestone's
#     #7 allows explicitly).
#   * a second parameter P1, classified `identity` on every one of I's
#     self-tail calls (unchanged from iteration to iteration: the scanned
#     String itself) -- exactly the stability hir/induction.tcl's own
#     BoundRange already requires of a stable bound (#20-21 of *that*
#     module's own milestone).
#   * at least one *access*: a call, reached by scanning I's own body's
#     top-level statements in order (FindAccessesInBody) and, from each one,
#     a call's own argument expressions or a `bind`'s own value expression,
#     recursively (FindAccesses) -- but never descending into an `if`, a
#     `loop`, or a nested `block`, so an access that is itself conditional
#     (reached on only some paths) is simply never found (#23's "conservative
#     fallback is correct"). This is deliberately *not* limited to the
#     self-tail call's own argument expressions: csv.bot's own
#     `character = peek(text, index)` -- bound once, used later by an `if`
#     and by the self-tail call -- is unconditionally evaluated exactly once
#     per iteration wherever it sits in a straight-line body, exactly as
#     safe to recognize as an access inlined directly into the tail call's
#     own arguments (ai_text_clean.bot's own
#     `clean_from(text, index + 1, concat(done, clean_char(peek(text, index))))`).
#     An access is structurally a direct call to another instance
#     CharAccessorShape recognizes as a "character accessor" -- see that
#     proc's own header -- which is what lets a `peek`-shaped helper
#     recognize *through* a closed call, with no name ever consulted (#8,
#     #18's option A: lower the access directly in the caller, never adding
#     an interprocedural ABI or a companion call for this).
#
# Deliberately *not* recognized: a direct `substring(text, i, i+1)` call
# (not behind an accessor). Not because it is any harder to locate -- it
# would need the exact same width-1 shape check CharAccessorShape already
# has -- but because its out-of-bounds *failure* contract differs from
# peek's own: `substring` raises RANGE when i is past the end, where
# peek's own out-of-bounds branch returns "". Reproducing a byte-exact
# RANGE message needs the real `rt_substr`, which needs the seek this
# module exists to avoid; a fixed-width-1 accessor sidesteps the whole
# question because *its own body* already decided what past-the-end means
# (peek's own `if index >= length(text): return ""`), and this module
# reproduces exactly that decision, not `substring`'s. A future milestone
# that wants the bare-`substring` shape too would need to keep the
# allocating, checking `substr` call on that one cold path instead of ever
# synthesizing its error itself.
#
# What this module explicitly does NOT attempt (see the milestone's own
# #17, #19, #24-27): a captured (non-parameter) scanned String, a step other
# than exactly +1, a decreasing loop, more than one String scanned by the
# same index, more than one access per iteration reusing a single decode, or
# a loop whose starting index cannot be proven exactly 0. Every one of these
# simply is not recognized -- ordinary lowering (an allocating `substr`/
# `peek` call, exactly as before) is exactly as sound and unchanged for it as
# it always was. Nothing here ever changes program *behavior*: only which
# instances get a TraversalPlan.
#
# TraversalPlan
# -------------
#   textArgOf    ExprId (an access call) -> its own argument index holding
#                the scanned String
#   indexArgOf   ExprId (an access call) -> its own argument index holding
#                the character index (always textArgOf's expression's own
#                sibling; recorded explicitly, by argument position, rather
#                than assumed, since a future accessor shape need not put
#                them at positions 0/1)
#   accesses     the set of recognized access ExprIds (dict keys of the above)
#   byteParamIndex
#                the *hidden* extra parameter index native/lower.tcl adds
#                for I's compiled function -- always I's own source
#                parameter count (the next free slot): never a source-level
#                Botlish parameter, never observable from Botlish, purely a
#                compiler-internal execution representation (see native/
#                lower.tcl's "String traversal" section for how it is
#                threaded through Function/Call/Tail).
#
# Interaction with scalar replacement / String regions (deliberately none):
# an instance this module would otherwise recognize is skipped outright
# (analyze's own exclusion, below) if hir::escape.tcl or hir::stringregion.tcl
# also wants a companion function for it, so a TraversalPlan instance is
# only ever
# reached through the ordinary call/tail ABI (never callmulti/
# callenvmulti). This is the smallest sound scope for this milestone, not a
# permanent restriction: extending the hidden byte parameter through a
# companion's own signature is future work if a program's shape ever needs
# both at once (the corpus this milestone targets never does).
#
# -string-traversal-opt 0 (or BOTLISH_NATIVE_STRING_TRAVERSAL_OPT=0)
# disables this analysis and lowering outright, independent of
# -string-region-opt/-escape-opt/-repr-opt, for differential testing against
# the unoptimized baseline.

namespace eval hir::traversal {
}

# ---------------------------------------------------------------------------
# Character accessors: a used instance whose own body is *exactly* peek's
# shape (structurally, never by name: #8/#50 of the milestone) --
#
#   if index >= length(text):    ; or "length(text) <= index"
#       return ""
#   substring(text, index, index + 1)
#
# with no other statement, no else, and index/text exactly its own two
# parameters. This is deliberately a precise structural match of the whole
# body, not merely "some exit is a literal and some exit is a width-1
# substring" (which hir::stringregion.tcl's own region recognition alone
# would accept for *any* function with those two exits, however its guard
# actually decides between them -- e.g. an unrelated `if i == 5: return ""`
# would pass that looser test while meaning something else entirely).
# Reproducing peek's own *decision* between its two exits, not merely its
# two possible results, is exactly what TraversalAccess's own emitted
# `index >= length(text)` check must be proven equivalent to, so this
# module checks the guard condition itself rather than assuming it.

proc hir::traversal::IsLengthOf {hir e b} {
    if {[hir::kind $hir $e] ne "call"} {
        return 0
    }
    set node [hir::node $hir $e]
    lassign [dict get $node target] targetKind target
    set args [dict get $node args]
    return [expr {$targetKind eq "native" && [dict get [hir::symbol $hir $target] name] eq "length"
        && [llength $args] == 1 && [IsRefToBinding $hir [lindex $args 0] $b]}]
}

# {textParamIndex indexParamIndex} if instance ID (2 parameters) is a
# character accessor, else "".
proc hir::traversal::CharAccessorShape {hir spec id} {
    set instance [dict get $spec instances $id]
    set block [dict get $instance block]
    if {$block eq "program"} {
        return ""
    }
    set params [hir::get $hir $block params]
    if {[llength $params] != 2} {
        return ""
    }
    set view [hir::specialize::view $hir $spec $id]
    set body [hir::get $view $block body]
    if {[llength $body] != 2} {
        return ""
    }
    lassign $body guardStmt tailExpr
    if {[hir::kind $view $guardStmt] ne "if"} {
        return ""
    }
    set ifNode [hir::node $view $guardStmt]
    if {[dict get $ifNode elseBody] ne ""} {
        return ""
    }
    set thenBody [dict get $ifNode thenBody]
    if {[llength $thenBody] != 1 || [hir::kind $view [lindex $thenBody 0]] ne "return"} {
        return ""
    }
    set retValue [dict get [hir::node $view [lindex $thenBody 0]] value]
    if {$retValue eq "" || [hir::kind $view $retValue] ne "const"} {
        return ""
    }
    set retConst [hir::get $view $retValue value]
    if {[core::value::kind $retConst] ne "str" || [core::value::strOf $retConst] ne ""} {
        return ""
    }

    if {[hir::kind $view $tailExpr] ne "call"} {
        return ""
    }
    set callNode [hir::node $view $tailExpr]
    lassign [dict get $callNode target] callKind callTarget
    if {$callKind ne "native" || [dict get [hir::symbol $view $callTarget] name] ne "substring"} {
        return ""
    }
    set sargs [dict get $callNode args]
    if {[llength $sargs] != 3} {
        return ""
    }
    lassign $sargs textExpr indexExpr widthExpr
    if {[hir::kind $view $textExpr] ne "ref" || [hir::kind $view $indexExpr] ne "ref"} {
        return ""
    }
    set textParam [hir::get $view $textExpr binding]
    set indexParam [hir::get $view $indexExpr binding]
    if {$textParam ni $params || $indexParam ni $params || $textParam eq $indexParam} {
        return ""
    }
    if {[hir::induction::ClassifyArg $view $widthExpr $indexParam] ne {step 1}} {
        return ""
    }

    set condition [dict get $ifNode condition]
    if {[hir::kind $view $condition] ne "call"} {
        return ""
    }
    set condNode [hir::node $view $condition]
    lassign [dict get $condNode target] condKind condTarget
    if {$condKind ne "native"} {
        return ""
    }
    set condName [dict get [hir::symbol $view $condTarget] name]
    set condArgs [dict get $condNode args]
    if {[llength $condArgs] != 2} {
        return ""
    }
    lassign $condArgs ca cb
    set guardOk [expr {
        ($condName eq ">=" && [IsRefToBinding $view $ca $indexParam] && [IsLengthOf $view $cb $textParam])
        || ($condName eq "<=" && [IsLengthOf $view $ca $textParam] && [IsRefToBinding $view $cb $indexParam])
    }]
    if {!$guardOk} {
        return ""
    }
    return [list [lsearch -exact $params $textParam] [lsearch -exact $params $indexParam]]
}

# ---------------------------------------------------------------------------
# Zero-start: every direct, non-self-tail caller of instance ID anywhere in
# the program passes exactly the literal 0 at parameter index INDEXIDX.
# "" (no external callers at all) is exactly as unproven as a caller that
# passes something else: #7 of the milestone needs an actual literal-0
# caller to anchor byte offset 0 to semantic index 0, not merely the absence
# of a counterexample.

proc hir::traversal::ZeroStart {hir spec id indexIdx} {
    set selfTails [dict get [dict get $spec context] selfTails]
    set found 0
    foreach caller [dict get $spec used] {
        set callerInstance [dict get $spec instances $caller]
        foreach {callExpr target} [dict get $callerInstance calls] {
            if {$target ne $id} {
                continue
            }
            if {$caller eq $id && [dict exists $selfTails $callExpr]} {
                continue
            }
            set argExpr [lindex [hir::get $hir $callExpr args] $indexIdx]
            if {[hir::induction::ConstInt $hir $argExpr] ne 0} {
                return 0
            }
            set found 1
        }
    }
    return $found
}

# ---------------------------------------------------------------------------
# Accesses: a call reachable, with no intervening branch/closure/loop, from
# one of instance ID's self-tail calls' own argument expressions, structured
# as a forwarding call to a recognized character accessor (ACCESSORROLE:
# InstanceId -> {textArgIndex indexArgIndex}, from CharAccessorShape) over
# exactly TEXTPARAM/INDEXPARAM (binding ids) -- see the file header for why
# a *direct* `substring(text, index, index+1)` call is deliberately not
# recognized here. CALLS is instance ID's own `calls` map (ExprId -> target
# InstanceId: hir::specialize.tcl), needed to resolve which instance a
# forwarding call site targets. Returns a dict ExprId -> {textArgIndex
# indexArgIndex}.

proc hir::traversal::IsRefToBinding {hir e b} {
    return [expr {[hir::kind $hir $e] eq "ref" && [hir::get $hir $e binding] eq $b}]
}

proc hir::traversal::FindAccesses {hir accessorRole calls textParam indexParam e} {
    switch -- [hir::kind $hir $e] {
        bind {
            # A `character = peek(text, index)` local binding (csv.bot's own
            # idiom): unconditionally evaluated exactly once, wherever it sits
            # in a straight-line body -- exactly as safe a root to keep
            # looking from as a call's own argument expression is.
            return [FindAccesses $hir $accessorRole $calls $textParam $indexParam [dict get [hir::node $hir $e] value]]
        }
        call {}
        default {
            # Anything else -- ref, const, if, loop, block, return, ... --
            # is not itself a recognized access and is never descended into
            # (#23's conservative fallback): a branch, closure or loop might
            # not run on every path that reaches the self-tail call, and a
            # plain ref/const has no sub-expressions to look in anyway.
            return {}
        }
    }
    set node [hir::node $hir $e]
    set args [dict get $node args]
    lassign [dict get $node target] targetKind target
    if {$targetKind eq "block" && [dict exists $calls $e] && [dict exists $accessorRole [dict get $calls $e]]} {
        lassign [dict get $accessorRole [dict get $calls $e]] textArgIndex indexArgIndex
        if {[llength $args] > $textArgIndex && [llength $args] > $indexArgIndex
                && [IsRefToBinding $hir [lindex $args $textArgIndex] $textParam]
                && [IsRefToBinding $hir [lindex $args $indexArgIndex] $indexParam]} {
            return [dict create $e [list $textArgIndex $indexArgIndex]]
        }
    }
    # Not itself a recognized access: keep looking in its own argument
    # expressions (a plain applicative subtree -- no branch, closure or loop
    # node is ever descended into: #23's conservative fallback).
    set found [dict create]
    foreach a $args {
        foreach {k v} [FindAccesses $hir $accessorRole $calls $textParam $indexParam $a] {
            dict set found $k $v
        }
    }
    return $found
}

# Accesses found by scanning every one of BODY's own top-level statements
# (hir::get ... body, a block's straight-line statement list): each one is
# unconditionally evaluated whenever the function is entered at all, in
# program order, regardless of whether some *later* statement (a guard `if`
# with no else, the self-tail call itself) is only reached on some paths --
# see FindAccesses' own `bind` case. This is what lets a helper's result be
# bound to a local (`character = peek(text, index)`) and used later, rather
# than only recognizing an access inlined directly into the self-tail call's
# own argument expressions.
proc hir::traversal::FindAccessesInBody {hir accessorRole calls textParam indexParam body} {
    set found [dict create]
    foreach stmt $body {
        foreach {k v} [FindAccesses $hir $accessorRole $calls $textParam $indexParam $stmt] {
            dict set found $k $v
        }
    }
    return $found
}

# ---------------------------------------------------------------------------
# Entry point

# The traversal analysis of program HIR under specialization SPEC
# (hir::specialize::analyze), given hir::stringregion.tcl's own analysis
# STRINGREGION and hir::escape.tcl's own analysis ESCAPE (both consulted
# only to exclude an instance that already wants a region/scalar-replacement
# companion: see the file header's "Interaction with scalar replacement /
# String regions"). Returns a dict:
#   plans   InstanceId -> TraversalPlan (see the file header)
proc hir::traversal::analyze {hir spec stringregion escape} {
    set accessorRole [dict create]
    foreach id [dict get $spec used] {
        set role [CharAccessorShape $hir $spec $id]
        if {$role ne ""} {
            dict set accessorRole $id $role
        }
    }

    set context [dict get $spec context]
    set selfTails [dict get $context selfTails]
    set regionCompanions [dict get $stringregion wants]
    set scalarCompanions [dict get $escape wants]
    set plans [dict create]
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        set block [dict get $instance block]
        if {$block eq "program" || [dict exists $regionCompanions $id] || [dict exists $scalarCompanions $id]} {
            continue
        }
        # A generic instance is the only kind ever reachable as a first-
        # class Block value (native/lower.tcl's own invariant: "Block values
        # (fnvalue, closure) are always generic instances"), through the
        # fixed generic-entry ABI (rt_call_value's arity check, ClosureObj's
        # own `arity`) that a hidden extra parameter would silently break.
        # Restricting this analysis to non-generic (specialized) instances
        # sidesteps that ABI entirely: such an instance is never callable
        # except through a direct call/tail this same analysis already
        # accounts for (ZeroStart, the self-tail backedge).
        if {[dict get $instance generic]} {
            continue
        }
        set selfCallExprs {}
        foreach {callExpr target} [dict get $instance calls] {
            if {$target eq $id && [dict exists $selfTails $callExpr]} {
                lappend selfCallExprs $callExpr
            }
        }
        if {$selfCallExprs eq ""} {
            continue
        }
        set params [hir::get $hir $block params]
        set n [llength $params]
        set calls [lmap c $selfCallExprs {hir::get $hir $c args}]
        set classifications [lmap p $params {hir::induction::ClassifyParam $hir $calls [lsearch -exact $params $p] $p}]
        set view [hir::specialize::view $hir $spec $id]
        set body [hir::get $view $block body]

        for {set indexIdx 0} {$indexIdx < $n} {incr indexIdx} {
            set class [lindex $classifications $indexIdx]
            if {$class ne {step 1}} {
                continue
            }
            if {![ZeroStart $hir $spec $id $indexIdx]} {
                continue
            }
            set indexParam [lindex $params $indexIdx]
            set found 0
            for {set textIdx 0} {$textIdx < $n && !$found} {incr textIdx} {
                if {$textIdx eq $indexIdx || [lindex $classifications $textIdx] ne "identity"} {
                    continue
                }
                set textParam [lindex $params $textIdx]
                set accesses [FindAccessesInBody $view $accessorRole [dict get $instance calls] $textParam $indexParam $body]
                if {[dict size $accesses]} {
                    set textArgOf [dict create]
                    set indexArgOf [dict create]
                    dict for {e pair} $accesses {
                        dict set textArgOf $e [lindex $pair 0]
                        dict set indexArgOf $e [lindex $pair 1]
                    }
                    dict set plans $id [dict create textArgOf $textArgOf indexArgOf $indexArgOf \
                        accesses [dict keys $accesses] byteParamIndex $n]
                    set found 1
                }
            }
            if {$found} {
                break
            }
        }
    }
    return [dict create plans $plans]
}

# Instance ID's TraversalPlan, or "" if none.
proc hir::traversal::plan {analysis id} {
    if {[dict exists [dict get $analysis plans] $id]} {
        return [dict get [dict get $analysis plans] $id]
    }
    return ""
}
