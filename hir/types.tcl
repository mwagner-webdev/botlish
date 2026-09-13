# types.tcl -- static semantic types of HIR expressions, and their inference.
#
# Static types are the semantic types of core/type.tcl, which define what it
# means for a value to have a type, extended with forms that describe values
# more precisely than a value type can:
#
#   (any core type)                 int, str, {refined str {Emailish}}, any, ...
#   {native NAME}                   exactly the native callable NAME
#   {block EXPR ARITY RESULT}       a Block created by the block expression
#                                   EXPR (an ExprId), taking ARITY arguments;
#                                   RESULT types what a call returns
#   never                           no value: evaluation never completes
#                                   normally (return, break, error, ...)
#
# These are semantic facts, not representation: nothing here says how a
# backend stores a value. The procedures handle the extra forms and delegate
# everything else to core::type, so a refinement or named type means the same
# thing here as to the interpreter.
#
# Invariant: if an expression has static type T (a core type), each value v
# it evaluates to satisfies core::type::acceptsValue T v.
#
# Types are interned per HIR program: nodes and bindings hold TypeIds.

namespace eval hir::types {}

proc hir::types::IsSpecific {type} {
    return [expr {$type eq "never"
                  || ([llength $type] > 1 && [lindex $type 0] in {native block})}]
}

# TYPE in canonical form (core types are normalized by core::type).
proc hir::types::canonical {type} {
    if {[IsSpecific $type]} {
        return $type
    }
    return [core::type::normalize $type]
}

# Least upper bound: the most precise type describing values of A or B.
proc hir::types::lub {a b} {
    if {$a eq "never"} { return [canonical $b] }
    if {$b eq "never"} { return [canonical $a] }
    if {$a eq $b} { return [canonical $a] }
    if {[lindex $a 0] eq "block" && [lindex $b 0] eq "block"
            && [llength $a] == 4 && [llength $b] == 4
            && [lrange $a 1 2] eq [lrange $b 1 2]} {
        return [list block [lindex $a 1] [lindex $a 2] [lub [lindex $a 3] [lindex $b 3]]]
    }
    if {[IsSpecific $a] || [IsSpecific $b]} {
        set kind [kindOf $a]
        return [expr {$kind ne "" && $kind eq [kindOf $b] ? $kind : "any"}]
    }
    return [core::type::lub $a $b]
}

# Narrows CURRENT by a proven FACT (a core type).
proc hir::types::narrow {current fact} {
    if {$fact eq "any" || $current eq "never"} {
        return $current
    }
    if {[IsSpecific $current]} {
        # A precise callable type already implies a bare kind fact.
        if {$fact eq [kindOf $current]} {
            return $current
        }
        return $fact
    }
    return [core::type::narrow $current $fact]
}

# The runtime value kind every value of TYPE has, or "" if not fixed.
proc hir::types::kindOf {type} {
    if {$type eq "never"} {
        return ""
    }
    if {[IsSpecific $type]} {
        return [lindex $type 0]
    }
    return [core::type::base $type]
}

# The core type (core/type.tcl) a static type implies.
proc hir::types::semantic {type} {
    if {$type eq "never"} {
        return any
    }
    if {[IsSpecific $type]} {
        return [lindex $type 0]
    }
    return $type
}

# The static type of the runtime value V.
proc hir::types::ofValue {v} {
    if {[core::value::kind $v] eq "native"} {
        return [list native [core::value::nativeName $v]]
    }
    return [core::type::ofValue $v]
}

# Signature of native NAME: {PARAM-TYPES RESULT-TYPE}; PARAM-TYPES may be "".
proc hir::types::nativeSignature {name} {
    set meta [core::native::metadata $name]
    return [list [dict get $meta paramTypes] [dict get $meta resultType]]
}

proc hir::types::show {type} {
    if {$type eq "never"} {
        return never
    }
    if {[IsSpecific $type]} {
        switch -- [lindex $type 0] {
            native { return "native [lindex $type 1]" }
            block  { return "block([lindex $type 1])/[lindex $type 2] -> [show [lindex $type 3]]" }
        }
    }
    return [core::type::show $type]
}

# The TypeId of TYPE in the program, interning it.
proc hir::types::intern {hirVar type} {
    upvar 1 $hirVar hir
    if {[dict exists $hir typeIds $type]} {
        return [dict get $hir typeIds $type]
    }
    set t [hir::NewId hir type]
    dict set hir types $t $type
    dict set hir typeIds $type $t
    return $t
}

# ---------------------------------------------------------------------------
# Inference
#
# One walk in evaluation order assigns every expression its type. A context
# describes the path being analyzed:
#
#   types       BindingId -> type of the value the binding was bound to, for
#               bindings bound earlier on this path (a block body starts
#               from a copy of the types known where the block is created)
#   facts       BindingId -> narrowed type proven on the current path
#   returnType  lub of the values returned from the current block
#   breakTypes  loop ExprId -> lub of the values broken out with
#   reachable   0 once no normal completion can reach this point
#
# Where types come from:
#   * literals and constructors (const, ok, error, block)
#   * root bindings: their values are constants ({native +}, bool, unit)
#   * native signatures in the registry (-param-types / -result-type)
#   * immutability: a binding has the type of the expression it was bound to
#   * branch refinements (refine.tcl), inside the branch they are proven in
#   * flow facts: once a call of a native requiring a type returned, its
#     argument had that type, and since bindings are immutable it keeps it
#   * block results: lub of the body's value and every return; a block bound
#     to a binding it calls itself through is analyzed under an assumed
#     result type (never, then the inferred type) until the assumption is
#     reproduced, giving up with any after 3 passes (sound by induction over
#     calls)
#
# Facts are scoped like the control flow that proves them: facts learned in
# a branch or loop body are dropped at its end; facts learned in a sequence
# hold for the rest of it; closures inherit the facts known where they are
# created. Code that cannot be reached is still typed, but contributes
# nothing to block result or break types.
#
# Only local and parameter bindings are narrowed: root bindings hold
# constants, ambient bindings are unknown.

proc hir::types::infer {hirVar} {
    upvar 1 $hirVar hir
    set ctx [NewContext]
    Sequence hir ctx [dict get $hir roots]
}

proc hir::types::NewContext {} {
    return [dict create types {} facts {} returnType never breakTypes {} reachable 1]
}

proc hir::types::SetType {hirVar e type} {
    upvar 1 $hirVar hir
    dict set hir exprs $e type [intern hir $type]
    return $type
}

# Current static type of binding B on the path.
proc hir::types::BindingType {hir ctx b} {
    if {[dict exists $ctx facts $b]} {
        return [dict get $ctx facts $b]
    }
    if {[dict exists $ctx types $b]} {
        return [dict get $ctx types $b]
    }
    if {[dict get $hir bindings $b kind] eq "root"} {
        return [ofValue [dict get $hir bindings $b value]]
    }
    return any
}

# Records that binding B's value has type FACT on the current path.
proc hir::types::Narrow {hir ctxVar b fact} {
    upvar 1 $ctxVar ctx
    if {$b ne "" && [dict get $hir bindings $b kind] in {local param}} {
        dict set ctx facts $b [narrow [BindingType $hir $ctx $b] $fact]
    }
}

# The binding whose value expression E evaluates to, or "".
proc hir::types::ValueBinding {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        ref {
            if {[dict get $node init] ne "no"} {
                return [dict get $node binding]
            }
        }
        bind {
            if {![dict get $node duplicate]} {
                return [dict get $node binding]
            }
        }
    }
    return ""
}

# Types EXPRS in order. Returns the type of the sequence: unit if empty,
# never if some expression never completes normally, else the last type.
proc hir::types::Sequence {hirVar ctxVar exprs} {
    upvar 1 $hirVar hir $ctxVar ctx
    set entry [dict get $ctx reachable]
    set result unit
    foreach e $exprs {
        set type [Expr hir ctx $e]
        if {$result ne "never"} {
            set result $type
        }
        if {$type eq "never"} {
            dict set ctx reachable 0
        }
    }
    dict set ctx reachable $entry
    return $result
}

# Types expression E. Returns its type.
proc hir::types::Expr {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    dict set hir exprs $e reachable [dict get $ctx reachable]
    switch -- [dict get $node kind] {
        const {
            return [SetType hir $e [ofValue [dict get $node value]]]
        }
        ref {
            if {[dict get $node binding] eq "" || [dict get $node init] eq "no"} {
                return [SetType hir $e never]
            }
            return [SetType hir $e [BindingType $hir $ctx [dict get $node binding]]]
        }
        bind {
            return [SetType hir $e [Bind hir ctx $e]]
        }
        block {
            return [SetType hir $e [Block hir ctx $e ""]]
        }
        call {
            return [SetType hir $e [Call hir ctx $e]]
        }
        if {
            return [SetType hir $e [If hir ctx $e]]
        }
        loop {
            set saved [dict get $ctx facts]
            dict set ctx breakTypes $e never
            Sequence hir ctx [dict get $node body]
            set type [dict get $ctx breakTypes $e]
            dict unset ctx breakTypes $e
            dict set ctx facts $saved
            return [SetType hir $e $type]
        }
        return {
            set value [Expr hir ctx [dict get $node value]]
            if {$value ne "never" && [dict get $node target] ne "" && [dict get $ctx reachable]} {
                dict set ctx returnType [lub [dict get $ctx returnType] $value]
            }
            return [SetType hir $e never]
        }
        break {
            set value unit
            if {[dict get $node value] ne ""} {
                set value [Expr hir ctx [dict get $node value]]
            }
            set loop [dict get $node target]
            if {$value ne "never" && $loop ne "" && [dict get $ctx reachable]} {
                dict set ctx breakTypes $loop [lub [dict get $ctx breakTypes $loop] $value]
            }
            return [SetType hir $e never]
        }
        continue {
            return [SetType hir $e never]
        }
        ok - error {
            set value [Expr hir ctx [dict get $node value]]
            return [SetType hir $e [expr {$value eq "never" ? "never" : "result"}]]
        }
    }
}

proc hir::types::Bind {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set b [dict get $node binding]
    set valueExpr [dict get $node value]
    set typed [expr {![dict get $node duplicate] && [dict get $hir bindings $b kind] ne "ambient"}]
    if {$typed && [dict get $hir exprs $valueExpr kind] eq "block"} {
        # The block may call itself through the binding.
        dict set hir exprs $valueExpr reachable [dict get $ctx reachable]
        set value [SetType hir $valueExpr [Block hir ctx $valueExpr $b]]
    } else {
        set value [Expr hir ctx $valueExpr]
    }
    if {$value eq "never" || [dict get $node duplicate]} {
        return never
    }
    if {$typed} {
        dict set ctx types $b $value
        dict set hir bindings $b type [intern hir $value]
    }
    return $value
}

# Types block expression E; SELF is the binding it is bound to (or "").
proc hir::types::Block {hirVar outerVar e self} {
    upvar 1 $hirVar hir $outerVar outer
    set node [dict get $hir exprs $e]
    set arity [llength [dict get $node params]]
    set assumed never
    set attempts [expr {$self eq "" ? 1 : 3}]
    for {set attempt 1} {$attempt <= $attempts} {incr attempt} {
        if {$attempt == $attempts && $attempts > 1} {
            set assumed any
        }
        set ctx [NewContext]
        dict set ctx types [dict get $outer types]
        dict set ctx facts [dict get $outer facts]
        if {$self ne ""} {
            dict set ctx types $self [list block $e $arity $assumed]
        }
        set body [Sequence hir ctx [dict get $node body]]
        set result [lub $body [dict get $ctx returnType]]
        if {$self eq "" || $result eq $assumed || $assumed eq "any"} {
            break
        }
        set assumed $result
    }
    dict set hir exprs $e resultType [intern hir $result]
    return [list block $e $arity $result]
}

proc hir::types::Call {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set entry [dict get $ctx reachable]
    set dead 0
    set types {}
    foreach child [concat [list [dict get $node callee]] [dict get $node args]] {
        set type [Expr hir ctx $child]
        lappend types $type
        if {$type eq "never"} {
            set dead 1
            dict set ctx reachable 0
        }
    }
    dict set ctx reachable $entry
    set calleeType [lindex $types 0]
    set argExprs [dict get $node args]
    set argTypes [lrange $types 1 end]

    set target ""
    set known ""
    set result any
    if {[lindex $calleeType 0] eq "native" && [llength $calleeType] == 2} {
        set name [lindex $calleeType 1]
        set target [list native [hir::resolve::nativeSymbol hir $name]]
        set meta [core::native::metadata $name]
        set arity [dict get $meta arity]
        if {$arity eq "*" || $arity == [llength $argExprs]} {
            set result [dict get $meta resultType]
            if {[dict get $meta testsType] ne ""} {
                set known [hir::refine::decideTypeTest $name [lindex $argTypes 0]]
            }
            if {!$dead} {
                # The call returned, so every argument had its parameter type.
                foreach arg $argExprs paramType [dict get $meta paramTypes] {
                    if {$paramType ne "" && $arg ne ""} {
                        Narrow $hir ctx [ValueBinding $hir $arg] $paramType
                    }
                }
            }
        }
    } elseif {[lindex $calleeType 0] eq "block" && [llength $calleeType] == 4} {
        lassign $calleeType _ block arity blockResult
        set target [list block $block]
        if {$arity == [llength $argExprs]} {
            set result $blockResult
        }
    }
    dict set hir exprs $e target $target
    dict set hir exprs $e known $known
    return [expr {$dead ? "never" : $result}]
}

# The Boolean (1/0) CONDITION is statically known to evaluate to, or "":
# a decided call, or a reference to a Boolean root binding (a constant).
proc hir::types::KnownOutcome {hir condition} {
    set node [dict get $hir exprs $condition]
    switch -- [dict get $node kind] {
        call {
            return [dict get $node known]
        }
        ref {
            set b [dict get $node binding]
            if {$b ne "" && [dict get $hir bindings $b kind] eq "root"
                    && [core::value::kind [dict get $hir bindings $b value]] eq "bool"} {
                return [core::value::isTrue [dict get $hir bindings $b value]]
            }
        }
    }
    return ""
}

proc hir::types::If {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set condition [dict get $node condition]
    set test [Expr hir ctx $condition]
    set entry [dict get $ctx reachable]

    set known ""
    set refinements [dict create 1 {} 0 {}]
    set live [expr {$entry && $test ne "never"}]
    if {$test ne "never"} {
        set known [KnownOutcome $hir $condition]
        if {$test ne "bool"} {
            # The if raises unless the condition is a Boolean.
            Narrow $hir ctx [ValueBinding $hir $condition] bool
        }
        set refinements [hir::refine::branchFacts $hir $condition]
    }
    dict set hir exprs $e refinements $refinements

    set branchTypes [dict create]
    foreach {outcome role} {1 then 0 else} {
        set saved [dict get $ctx facts]
        dict set ctx reachable [expr {$live && ($known eq "" || $known == $outcome)}]
        dict set hir scopes [dict get $node ${role}Scope] refinements [dict get $refinements $outcome]
        foreach {b fact} [dict get $refinements $outcome] {
            Narrow $hir ctx $b $fact
        }
        dict set branchTypes $outcome [Sequence hir ctx [dict get $node ${role}Body]]
        dict set ctx facts $saved
        dict set ctx reachable $entry
    }
    if {$test eq "never"} {
        return never
    }
    if {$known ne ""} {
        return [dict get $branchTypes $known]
    }
    return [lub [dict get $branchTypes 1] [dict get $branchTypes 0]]
}
