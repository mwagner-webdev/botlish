# refine.tcl -- static refinement facts, proof implications, and statically
# decided type tests.
#
# The runtime rule (core/refine.tcl): when an `if` condition has the form
#
#     (call (ref P) ARG...)
#
# and P's value is a callable with refinement metadata, each rule "argument I
# satisfies FACT" for the outcome is applied to argument I if that argument
# is itself (ref NAME); the fact holds for the binding NAME denotes, within
# the branch. The runtime facts are informational: no runtime check depends
# on them.
#
# Statically, facts are what a Boolean value *implies* (REFINEMENT-VALUES.md):
#
#   Implication HIR CTX E   => {1 SET 0 SET}
#
# what is proven when expression E (already typed) evaluates to true, and to
# false. A SET is a fact set -- a dict KEY -> VALUE, the same shape as an
# inference context's own `facts` (hir/types.tcl) -- or the word `never`: the
# outcome is impossible. A KEY is either
#
#   a BindingId     VALUE a type the binding's value is proven to have
#                   (narrowed into what is known of the binding)
#   a call key      "call BLOCK IDENTITY..." (CallKey): VALUE 1 or 0, the
#                   result of that exact invocation -- the same proof-
#                   producing function on the same argument values
#
# Facts are keyed by value identity -- a BindingId, an exact value -- never by
# a name, so shadowing or rebinding cannot redirect them. The sources:
#
#   * a call of a native with refinement metadata (core::native's
#     -refines-true/-refines-false, -tests-type): its rules, applied to the
#     arguments that are plain references;
#   * a call of a function with a proof contract (`proves x: R`, the block's
#     `proofs`, hir/resolve.tcl's ResolveProofs): when true, the argument of
#     the proven parameter satisfies R; either way, the call key records the
#     exact outcome of that invocation (a *predicate-result* fact, distinct
#     from the refinement fact: another function proving R need not return
#     true for the same value);
#   * a reference to an immutable Boolean binding: what its value implied
#     where it was bound (hir/types.tcl records it, CTX `implies`), so
#     `ok = p(s)` then `if ok:` proves what `if p(s):` would;
#   * a Boolean constant: true implies nothing and makes false impossible;
#   * an `if` producing a Boolean (the lowering of not, and, or, or written
#     out): for each outcome, the facts true on *every* path that yields it
#     (Meet), each path the condition's facts for its branch together with
#     the branch value's own (Conjoin);
#   * a handled call (`ok = p(s): on E: return ...`): the call's implication,
#     met with each handler that can complete with a value.
#
# Anything else implies nothing, which is always sound. Nothing here knows any
# predicate by name: the rules are the native's registered metadata or the
# function's declared proof contract.
#
# Whether a known exact call result may *replace* a later identical call is a
# separate question, answered by hir/repeatable.tcl (hir/types.tcl's Call
# asks it): a proof contract alone never makes a call removable.

namespace eval hir::refine {
    # Bound on how deep Implication follows Boolean if-expressions (their
    # nesting is bounded by the source, this only guards pathological depth).
    variable maxDepth 64
}

# The implication of a value that says nothing: both outcomes possible,
# nothing proven.
proc hir::refine::Nothing {} {
    return [dict create 1 {} 0 {}]
}

# dict OUTCOME (1/0) -> BindingId FACT pairs proven by CONDITION (an ExprId
# already typed) in inference context CTX: Implication's binding facts, for
# an if node's `refinements` field (hir::format, hir/signatures.tcl). An
# impossible outcome proves nothing worth recording.
proc hir::refine::branchFacts {hir condition {ctx {}}} {
    set implication [Implication $hir $ctx $condition]
    set facts [dict create 1 {} 0 {}]
    foreach outcome {1 0} {
        set set [dict get $implication $outcome]
        if {$set eq "never"} {
            continue
        }
        dict for {key value} $set {
            if {![IsCallKey $key]} {
                dict lappend facts $outcome $key $value
            }
        }
    }
    return $facts
}

# 1 if fact-set KEY is a call key (an exact predicate-result fact).
proc hir::refine::IsCallKey {key} {
    return [string match {call *} $key]
}

# What expression E (typed) implies when it evaluates to true and to false:
# {1 SET 0 SET}, as this file's header describes. CTX is the inference
# context E was typed in (its `implies`: BindingId -> implication of the
# Boolean value an immutable binding holds); "" for none.
proc hir::refine::Implication {hir ctx e {depth 0}} {
    variable maxDepth
    if {$depth > $maxDepth} {
        return [Nothing]
    }
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const {
            return [Constant [dict get $node value]]
        }
        ref {
            set b [dict get $node binding]
            if {$b eq ""} {
                return [Nothing]
            }
            set binding [dict get $hir bindings $b]
            if {[dict get $binding kind] eq "root"} {
                return [Constant [dict get $binding value]]
            }
            if {$ctx ne "" && [dict exists $ctx implies $b]} {
                return [dict get $ctx implies $b]
            }
            return [Nothing]
        }
        call {
            return [CallImplication $hir $e $node]
        }
        if {
            return [IfImplication $hir $ctx $e $node $depth]
        }
        handle {
            return [HandleImplication $hir $ctx $node $depth]
        }
    }
    return [Nothing]
}

# The implication of the handled call NODE (`v = p(s): on E: ...`) used as a
# Boolean value: its value is the call's when the call completes, or a
# handler body's -- so, for each outcome, the facts true on every way the
# value can be produced (Meet): the call's own implication, and each
# handler's value implication (a handler that never completes normally,
# e.g. `return`, produces no value and contributes nothing).
proc hir::refine::HandleImplication {hir ctx node depth} {
    set paths [list [Implication $hir $ctx [dict get $node call] [expr {$depth + 1}]]]
    foreach body [dict get $node handlerBodies] {
        lappend paths [BodyImplication $hir $ctx $body [expr {$depth + 1}]]
    }
    set result [dict create]
    foreach outcome {1 0} {
        set joined ""
        set any 0
        foreach path $paths {
            set facts [dict get $path $outcome]
            if {$facts eq "never"} {
                continue
            }
            set joined [expr {$any ? [Meet $joined $facts] : $facts}]
            set any 1
        }
        dict set result $outcome [expr {$any ? $joined : "never"}]
    }
    return $result
}

# The implication of the constant value V: a Boolean constant makes the
# other outcome impossible.
proc hir::refine::Constant {v} {
    if {[core::value::kind $v] ne "bool"} {
        return [Nothing]
    }
    return [expr {[core::value::isTrue $v] ? {1 {} 0 never} : {1 never 0 {}}}]
}

# The implication of the call E (node NODE), from its callee's refinement
# metadata: a native's registered rules, or a function's proof contract.
proc hir::refine::CallImplication {hir e node} {
    set result [Nothing]
    set known [dict get $node known]
    lassign [dict get $node target] kind target
    set args [dict get $node args]
    switch -- $kind {
        native {
            set name [dict get [hir::symbol $hir $target] name]
            foreach outcome {1 0} {
                foreach {index fact} [core::native::refinementRules $name $outcome] {
                    AddArgumentFact $hir result $outcome $args $index $fact
                }
            }
        }
        block {
            set proofs [ProofsOf $hir $target]
            if {$proofs ne {}} {
                foreach outcome {1 0} {
                    foreach {index fact} [ProofRules $hir $target $outcome] {
                        AddArgumentFact $hir result $outcome $args $index $fact
                    }
                }
                set key [CallKey $hir $target $args]
                if {$key ne ""} {
                    dict set result 1 $key 1
                    dict set result 0 $key 0
                }
            }
        }
    }
    # A decided call (a type test its argument's type answers, or a
    # predicate whose exact result is already known) has one outcome.
    if {$known eq "1"} {
        dict set result 0 never
    } elseif {$known eq "0"} {
        dict set result 1 never
    }
    return $result
}

# Records, in implication RESULT (upvar) for OUTCOME, that the value of
# argument INDEX of ARGS satisfies FACT -- when that argument is a plain
# reference to a binding (the binding it denotes, and, when it is an
# immutable alias of another binding, that binding too: one value). An
# argument of any other shape has no identity to attach a fact to.
proc hir::refine::AddArgumentFact {hir resultVar outcome args index fact} {
    upvar 1 $resultVar result
    if {$index >= [llength $args]} {
        return
    }
    set arg [lindex $args $index]
    set node [dict get $hir exprs $arg]
    if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} {
        return
    }
    set targets [list [dict get $node binding]]
    set root [hir::exact::AliasRoot $hir $arg]
    if {$root ne "" && $root ni $targets} {
        lappend targets $root
    }
    foreach b $targets {
        if {[dict get $hir bindings $b kind] ni {local param}} {
            continue
        }
        set set [dict get $result $outcome]
        if {[dict exists $set $b]} {
            dict set set $b [hir::types::narrow [dict get $set $b] $fact]
        } else {
            dict set set $b $fact
        }
        dict set result $outcome $set
    }
}

# The implication of the if expression E (node NODE) used as a Boolean value.
proc hir::refine::IfImplication {hir ctx e node depth} {
    set condition [Implication $hir $ctx [dict get $node condition] [expr {$depth + 1}]]
    set branches [dict create \
        1 [BodyImplication $hir $ctx [dict get $node thenBody] [expr {$depth + 1}]] \
        0 [BodyImplication $hir $ctx [dict get $node elseBody] [expr {$depth + 1}]]]
    set result [dict create]
    foreach outcome {1 0} {
        set joined ""
        set any 0
        foreach branch {1 0} {
            set entry [dict get $condition $branch]
            set value [dict get $branches $branch $outcome]
            if {$entry eq "never" || $value eq "never"} {
                continue
            }
            set path [Conjoin $entry $value]
            set joined [expr {$any ? [Meet $joined $path] : $path}]
            set any 1
        }
        dict set result $outcome [expr {$any ? $joined : "never"}]
    }
    return $result
}

# The implication of the value of the sequence BODY (a branch): its last
# expression's; a branch that never completes normally yields no value.
proc hir::refine::BodyImplication {hir ctx body depth} {
    if {$body eq {}} {
        return [Nothing]
    }
    set last [lindex $body end]
    foreach e $body {
        if {[hir::typeOf $hir $e] eq "never" || ![dict get $hir exprs $e reachable]} {
            return {1 never 0 never}
        }
    }
    return [Implication $hir $ctx $last $depth]
}

# Facts true on both of two paths (fact sets A and B, neither `never`): a
# binding fact survives as the least upper bound of its two facts; a call
# result only when both paths agree on it. A binding fact whose lub says
# nothing (`any`) is dropped from an implication; with KEEPANY 1 (joining an
# inference context's own facts, which are complete types) it is kept, so a
# join never makes a binding's type less precise than either path had it.
proc hir::refine::Meet {a b {keepAny 0}} {
    set result [dict create]
    dict for {key value} $a {
        if {![dict exists $b $key]} {
            continue
        }
        set other [dict get $b $key]
        if {[IsCallKey $key]} {
            if {$value eq $other} {
                dict set result $key $value
            }
            continue
        }
        set joined [hir::types::lub $value $other]
        if {$keepAny || $joined ne "any"} {
            dict set result $key $joined
        }
    }
    return $result
}

# Facts of both fact sets A and B (neither `never`): every fact of either,
# a binding proven by both narrowed by both.
proc hir::refine::Conjoin {a b} {
    set result $a
    dict for {key value} $b {
        if {[dict exists $result $key] && ![IsCallKey $key]} {
            dict set result $key [hir::types::narrow [dict get $result $key] $value]
        } else {
            dict set result $key $value
        }
    }
    return $result
}

# The resolved proof contract of block BLOCK (hir/resolve.tcl ResolveProofs):
# {outcome 1 param INDEX binding B fact TYPE} dicts, empty if none.
proc hir::refine::ProofsOf {hir block} {
    if {![dict exists $hir exprs $block proofs]} {
        return {}
    }
    return [dict get $hir exprs $block proofs]
}

# The INDEX FACT pairs block BLOCK's proof contract proves of a call's
# arguments when the call returns OUTCOME (1/0): the same flat shape as a
# native's refinement rules (core::native::refinementRules).
proc hir::refine::ProofRules {hir block outcome} {
    set rules {}
    foreach proof [ProofsOf $hir $block] {
        if {[dict get $proof outcome] == $outcome} {
            lappend rules [dict get $proof param] [dict get $proof fact]
        }
    }
    return $rules
}

# The exact-invocation key of a call of block BLOCK on the argument
# expressions ARGEXPRS: "call BLOCK IDENTITY...", one value identity per
# argument (hir::exact::Identity: an exactly known value, or an immutable
# binding after following aliases), or "" when some argument has no proven
# identity -- two calls with one key call the same function on the same
# argument values.
proc hir::refine::CallKey {hir block argExprs} {
    set key [list call $block]
    foreach arg $argExprs {
        set identity [hir::exact::Identity $hir $arg]
        if {$identity eq ""} {
            return ""
        }
        lappend key $identity
    }
    return $key
}

# The result (1/0) of calling the type test native NAME on an argument of
# static type ARG-TYPE, when the type decides it; otherwise "".
#
# A type test (core/native.tcl -tests-type T, parameter kind P) returns
# exactly whether its argument is a value of T, after rejecting arguments not
# of kind P. So with argument type S: S ⊑ P and S ⊑ T decides true; S ⊑ P with
# a base other than T's decides false. If S is not known to be a P, the call
# may raise, and nothing is decided.
proc hir::refine::decideTypeTest {name argType} {
    set meta [core::native::metadata $name]
    set testsType [dict get $meta testsType]
    if {$testsType eq ""} {
        return ""
    }
    set param [lindex [dict get $meta paramTypes] 0]
    set type [hir::types::semantic $argType]
    if {$type eq "any" || ![core::type::subtype $type $param]} {
        return ""
    }
    if {[core::type::subtype $type $testsType]} {
        return 1
    }
    if {[core::type::base $type] ne [core::type::base $testsType]} {
        return 0
    }
    return ""
}
