# repeatable.tcl -- whether a call may be replaced by its already-known result.
#
#   hir::repeatable::explain HIR BLOCK   => "" if BLOCK is repeatable, else why
#   hir::repeatable::Block HIR BLOCK     => 1 | 0
#
# A function is *repeatable* (REFINEMENT-VALUES.md) when a second call with
# the same argument values is guaranteed to complete exactly as the first
# did -- the same Boolean result, the same normal completion -- and neither
# call has an effect anything else can observe. Only then may a call whose
# exact result is already known on the current path (hir/refine.tcl's call
# keys) be replaced by that result (hir/types.tcl's Call sets `known`, and
# every backend that honors `known` elides the call). This is separate from
# proof production: a `proves` clause says what a true result establishes,
# never that the call may be skipped.
#
# The rule is conservative and structural: every operation the function can
# reach -- its own body and, transitively, every function it calls -- must
# be deterministic in its arguments and the immutable values it captures,
# and touch no state that evolves:
#
#   * a native call is repeatable when its registration classifies it
#     context-free (core::native -context-free 1: it neither reads nor
#     changes the execution environment -- no I/O, process state, context)
#     and it is not a mutation (no `mutarray-mutate` runtime tag), or when
#     it is a type test (-tests-type: by definition a pure one-argument
#     predicate). Reading a MutableArray, hashing, syscalls, contexts and
#     every unclassified native are not;
#   * a direct call of a known function (target {block E}) is repeatable
#     when E's body is, analyzed with what this call passes for E's
#     callable parameters;
#   * a call through a parameter (`predicate(c)`, no static target) is
#     repeatable only when every call that reaches here passed an exact
#     callable for it (the walk carries ENV: parameter BindingId -> {block
#     E} or {native NAME}, from the call sites it walked through), and that
#     callable is repeatable; anything else -- a callable from a List, a
#     struct field, an untyped value -- is not;
#   * everything else Botlish has is a value computation: constants,
#     references to immutable bindings (captured values included: a
#     binding never changes, and a mutable object behind one can only be
#     read through a native the first rule rejects), closure creation,
#     control flow, struct construction and projection, declared errors
#     (deterministic in the arguments, like everything else).
#
# Allocation is allowed: a fresh value is not observable through a Boolean
# result. Divergence needs no rule: a call whose result is known completed,
# and so does an identical deterministic one. Recursion is analyzed
# optimistically (a function being analyzed is assumed repeatable where it
# calls itself): repeatability is a safety property -- no reachable
# operation is effectful -- so the greatest fixpoint is the sound one.

namespace eval hir::repeatable {}

proc hir::repeatable::Block {hir block} {
    return [expr {[explain $hir $block] eq ""}]
}

# "" if BLOCK is repeatable, else the first reason found that it is not.
proc hir::repeatable::explain {hir block} {
    set memo [dict create]
    return [Walk $hir $block {} memo]
}

# 1 if the native NAME is repeatable (this file's header).
proc hir::repeatable::Native {name} {
    if {[catch {core::native::metadata $name} meta]} {
        return 0
    }
    if {[dict get $meta testsType] ne ""} {
        return 1
    }
    return [expr {[dict get $meta contextFree] && "mutarray-mutate" ni [dict get $meta runtime]}]
}

# Why BLOCK's body, entered with callable parameters ENV, is not repeatable
# ("" if it is). MEMO (upvar): {BLOCK ENV} -> result, "" while in progress.
proc hir::repeatable::Walk {hir block env memoVar} {
    upvar 1 $memoVar memo
    set key [list $block [lsort -stride 2 -index 0 $env]]
    if {[dict exists $memo $key]} {
        return [dict get $memo $key]
    }
    dict set memo $key ""
    set why ""
    foreach e [dict get $hir exprs $block body] {
        set why [Expr $hir $e $env memo]
        if {$why ne ""} {
            break
        }
    }
    dict set memo $key $why
    return $why
}

proc hir::repeatable::Expr {hir e env memoVar} {
    upvar 1 $memoVar memo
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        block {
            # Creating a closure runs nothing; its body is analyzed where
            # it is called.
            return ""
        }
        call {
            foreach child [hir::children $hir $e] {
                set why [Expr $hir $child $env memo]
                if {$why ne ""} {
                    return $why
                }
            }
            return [Call $hir $e $node $env memo]
        }
    }
    foreach child [hir::children $hir $e] {
        set why [Expr $hir $child $env memo]
        if {$why ne ""} {
            return $why
        }
    }
    return ""
}

# Why the call E (node NODE) is not repeatable under ENV ("" if it is).
proc hir::repeatable::Call {hir e node env memoVar} {
    upvar 1 $memoVar memo
    lassign [dict get $node target] kind target
    switch -- $kind {
        native {
            set callee [list native [dict get [hir::symbol $hir $target] name]]
        }
        block {
            set callee [list block $target]
        }
        default {
            set callee ""
            set calleeExpr [dict get $hir exprs [dict get $node callee]]
            if {[dict get $calleeExpr kind] eq "ref" && [dict exists $env [dict get $calleeExpr binding]]} {
                set callee [dict get $env [dict get $calleeExpr binding]]
            }
            if {$callee eq ""} {
                return "[Where $hir $e]: a call whose target is not statically known"
            }
        }
    }
    lassign $callee calleeKind calleeId
    if {$calleeKind eq "native"} {
        if {![Native $calleeId]} {
            return "[Where $hir $e]: native \"$calleeId\" is not classified as a repeatable value operation"
        }
        return ""
    }
    # A function: its callable parameters bound to what this call passes.
    set inner $env
    foreach param [dict get $hir exprs $calleeId params] arg [dict get $node args] {
        if {$param eq "" || $arg eq ""} {
            continue
        }
        set callable [CallableOf $hir $arg $env]
        if {$callable ne ""} {
            dict set inner $param $callable
        } elseif {[dict exists $inner $param]} {
            dict unset inner $param
        }
    }
    return [Walk $hir $calleeId $inner memo]
}

# The exact callable ({block E} or {native NAME}) argument expression ARG
# denotes under ENV, or "".
proc hir::repeatable::CallableOf {hir arg env} {
    set type [hir::typeOf $hir $arg]
    if {[hir::types::IsExactBlock $type]} {
        return [list block [lindex $type 1]]
    }
    if {[hir::types::IsExactNative $type]} {
        return $type
    }
    set node [dict get $hir exprs $arg]
    if {[dict get $node kind] eq "ref" && [dict exists $env [dict get $node binding]]} {
        return [dict get $env [dict get $node binding]]
    }
    return ""
}

# Where expression E is, for an explanation.
proc hir::repeatable::Where {hir e} {
    if {[catch {hir::aot::LocationText [hir::aot::Location $hir [hir::get $hir $e origin]]} text]} {
        return $e
    }
    return $text
}
