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
#   {list ELEM}                     a list whose every element has static
#                                   type ELEM ({list never}: the empty list)
#   {list ELEM {P0 P1 ...}}         a list of exactly n elements, element i
#                                   of static type Pi; ELEM is their lub
#
# The list forms are *aggregate facts*. Semantic inference (infer) never
# produces them: a program's HIR types stay what they were. Only
# specialization inference (inferRegion, used by hir/specialize.tcl) tracks
# what lists contain. They are bounded (see MakeList), so analyses over them
# terminate.
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

namespace eval hir::types {
    # Bounds of aggregate facts: list forms nest at most aggregateDepth deep
    # (deeper lists are plain list), a positional shape has at most
    # shapeLength elements, and block result types are cut at the same
    # depth. Lattices of bounded types have finite height.
    variable aggregateDepth 3
    variable shapeLength 8
}

proc hir::types::IsSpecific {type} {
    return [expr {$type eq "never"
                  || ([llength $type] > 1 && [lindex $type 0] in {native block list})}]
}

# 1 if TYPE is a list form ({list ELEM} or {list ELEM SHAPE}).
proc hir::types::IsList {type} {
    return [expr {[lindex $type 0] eq "list" && [llength $type] in {2 3}}]
}

# TYPE in canonical form (core types are normalized by core::type).
proc hir::types::canonical {type} {
    if {[IsSpecific $type]} {
        return [Bound $type 0]
    }
    return [core::type::normalize $type]
}

# The canonical list form of a list whose elements have type ELEM or, if
# SHAPED, whose elements are exactly of the POSITIONS types (ELEM is then
# derived), nested DEPTH list forms deep. Nothing known about the elements
# gives the plain kind list. A shape is kept only when it says more than the
# element type (a heterogeneous list) and fits shapeLength; only the
# outermost list has one (elements and positions are unshaped).
proc hir::types::MakeList {elem {positions {}} {shaped 0} {depth 0}} {
    variable aggregateDepth
    variable shapeLength
    if {$depth >= $aggregateDepth} {
        return list
    }
    set inner [expr {$depth + 1}]
    if {$shaped} {
        set positions [lmap p $positions {Unshaped [Bound $p $inner]}]
        set elem never
        foreach p $positions {
            set elem [lub $elem $p]
        }
        if {[llength $positions] > $shapeLength || [lsearch -exact -not $positions $elem] < 0} {
            set shaped 0
        }
    }
    set elem [Unshaped [Bound $elem $inner]]
    if {$shaped} {
        return [list list $elem $positions]
    }
    if {$elem eq "any"} {
        return list
    }
    return [list list $elem]
}

# TYPE with the aggregate bounds applied, nested DEPTH list forms deep.
proc hir::types::Bound {type depth} {
    variable aggregateDepth
    if {[IsList $type]} {
        if {[llength $type] == 3} {
            return [MakeList [lindex $type 1] [lindex $type 2] 1 $depth]
        }
        return [MakeList [lindex $type 1] {} 0 $depth]
    }
    if {[lindex $type 0] eq "block" && [llength $type] == 4} {
        set result [expr {$depth >= $aggregateDepth ? "any" : [Bound [lindex $type 3] [expr {$depth + 1}]]}]
        return [lreplace $type 3 3 $result]
    }
    return $type
}

# TYPE without a positional shape.
proc hir::types::Unshaped {type} {
    if {[IsList $type] && [llength $type] == 3} {
        return [expr {[lindex $type 1] eq "any" ? "list" : [lrange $type 0 1]}]
    }
    return $type
}

# The static type of every element of a value of static type TYPE, if TYPE
# is a list form; otherwise "".
proc hir::types::elementOf {type} {
    return [expr {[IsList $type] ? [lindex $type 1] : ""}]
}

# The positional shape {P0 ...} of static type TYPE, or "" if not known.
proc hir::types::shapeOf {type} {
    return [expr {[IsList $type] && [llength $type] == 3 ? [lindex $type 2] : ""}]
}

# 1 if every value of static type A is a value of static type B.
proc hir::types::subtype {a b} {
    if {$a eq "never" || $b eq "any" || $a eq $b} {
        return 1
    }
    if {$b eq "never"} {
        return 0
    }
    if {[IsList $b]} {
        if {![IsList $a] || ![subtype [lindex $a 1] [lindex $b 1]]} {
            return 0
        }
        set sb [shapeOf $b]
        if {$sb eq ""} {
            return 1
        }
        set sa [shapeOf $a]
        if {[llength $sa] != [llength $sb]} {
            return 0
        }
        foreach pa $sa pb $sb {
            if {![subtype $pa $pb]} {
                return 0
            }
        }
        return 1
    }
    if {[IsSpecific $b]} {
        # A block or native form: only that identical form is known to be one.
        return 0
    }
    return [core::type::subtype [semantic $a] $b]
}

# Least upper bound: the most precise type describing values of A or B.
proc hir::types::lub {a b} {
    if {$a eq "never"} { return [canonical $b] }
    if {$b eq "never"} { return [canonical $a] }
    if {$a eq $b} { return [canonical $a] }
    if {[lindex $a 0] eq "block" && [lindex $b 0] eq "block"
            && [llength $a] == 4 && [llength $b] == 4
            && [lrange $a 1 2] eq [lrange $b 1 2]} {
        return [canonical [list block [lindex $a 1] [lindex $a 2] [lub [lindex $a 3] [lindex $b 3]]]]
    }
    if {[IsList $a] && [IsList $b]} {
        set elem [lub [lindex $a 1] [lindex $b 1]]
        set sa [shapeOf $a]
        set sb [shapeOf $b]
        if {$sa ne "" && [llength $sa] == [llength $sb]} {
            return [MakeList $elem [lmap pa $sa pb $sb {lub $pa $pb}] 1]
        }
        return [MakeList $elem]
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
            list {
                if {[llength $type] == 3} {
                    return "list\[[join [lmap p [lindex $type 2] {show $p}] {, }]\]"
                }
                return "list<[show [lindex $type 1]]>"
            }
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
#   * forward references: a reference from a closure to a binding bound later
#     to a block expression E has type {block E ARITY any} (ForwardType), so
#     mutually recursive functions have known call targets
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

# ---------------------------------------------------------------------------
# Region inference (specialization)
#
# inferRegion types one region (a block's body, or the program's top level)
# of HIR again, under facts its semantic inference could not assume, and
# returns what that proves. hir/specialize.tcl uses it for native function
# instances: the same walk, the same refinements, flow facts and
# reachability, with three differences:
#
#   * entry facts: TYPES (BindingId -> type) seeds the region's parameter
#     and captured bindings (a specialization's argument types, what the
#     creations of the block had captured)
#   * aggregate facts: list constants, list-building natives
#     (-result-shape, core/native.tcl) and list reads produce list forms
#   * a HANDLER (command prefix) decides what the region's calls of known
#     blocks return and learns which blocks the region creates:
#
#       {*}HANDLER call CALL BLOCK ARG-TYPES   -> the call's result type
#       {*}HANDLER create BLOCK SEEDS          (SEEDS: captured BindingId ->
#                                               type where BLOCK is created)
#
#     Nested block bodies are not walked (they are regions of their own).
#
# An operation that always raises (a native or block called with the wrong
# number of arguments, a native argument statically of another kind, a
# non-callable callee, a non-Boolean condition) has type never here: its
# error path contributes nothing to what the region returns.
#
# HIR is changed in place (typically a scratch copy): expressions of the
# region get their types, known outcomes and reachability. Returns the type
# of the region's normal completion (never if none).
proc hir::types::inferRegion {hirVar region types handler} {
    upvar 1 $hirVar hir
    set ctx [NewContext]
    dict set ctx types $types
    dict set ctx spec $handler
    if {$region eq "program"} {
        return [Sequence hir ctx [dict get $hir roots]]
    }
    set body [Sequence hir ctx [dict get $hir exprs $region body]]
    return [lub $body [dict get $ctx returnType]]
}

proc hir::types::NewContext {} {
    return [dict create types {} facts {} returnType never breakTypes {} reachable 1]
}

# The static type of constant V under aggregate facts.
proc hir::types::AggregateOfValue {v} {
    if {[core::value::kind $v] eq "list"} {
        return [MakeList never [lmap item [core::value::items $v] {AggregateOfValue $item}] 1]
    }
    return [ofValue $v]
}

# The result type of a call of a native with -result-shape SHAPE on the
# arguments ARG-EXPRS of types ARG-TYPES, given its declared result type
# RESULT.
proc hir::types::ShapeResult {hir shape argExprs argTypes result} {
    switch -- [lindex $shape 0] {
        elements {
            return [MakeList never $argTypes 1]
        }
        element {
            lassign $shape _ l i
            set list [lindex $argTypes $l]
            set elem [elementOf $list]
            if {$elem eq "" || $elem eq "never"} {
                # Nothing known, or an empty list: no element to describe.
                return $result
            }
            set positions [shapeOf $list]
            set index [dict get $hir exprs [lindex $argExprs $i]]
            if {$positions ne "" && [dict get $index kind] eq "const"
                    && [core::value::kind [dict get $index value]] eq "int"} {
                set n [core::value::intOf [dict get $index value]]
                if {$n >= 0 && $n < [llength $positions]} {
                    return [lindex $positions $n]
                }
            }
            return $elem
        }
        append {
            lassign $shape _ l v
            set list [lindex $argTypes $l]
            if {[IsList $list]} {
                return [MakeList [lub [lindex $list 1] [lindex $argTypes $v]]]
            }
            return $result
        }
    }
    return $result
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
    return [ForwardType $hir $b]
}

# The type of a local binding B read before this path has bound it: only a
# reference from inside a closure (init deferred) gets here. If B's first
# bind binds a block expression E, the reference either fails (B not bound
# yet when it runs) or yields the Block E created: bindings are immutable, and
# a later duplicate bind raises instead of rebinding. Its result is not known
# yet: {block E ARITY any}. Otherwise any.
proc hir::types::ForwardType {hir b} {
    set binding [dict get $hir bindings $b]
    set declaredBy [dict get $binding declaredBy]
    if {[dict get $binding kind] ne "local" || $declaredBy eq ""} {
        return any
    }
    set value [dict get $hir exprs $declaredBy value]
    if {[dict get $hir exprs $value kind] ne "block"} {
        return any
    }
    return [list block $value [llength [dict get $hir exprs $value params]] any]
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
            if {[dict exists $ctx spec]} {
                return [SetType hir $e [AggregateOfValue [dict get $node value]]]
            }
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
    if {[dict exists $outer spec]} {
        # Region inference: the body is a region of its own. Report what
        # this creation captures; calls of the block ask the handler.
        set seeds [dict create]
        foreach b [dict get $node captures] {
            dict set seeds $b [BindingType $hir $outer $b]
        }
        {*}[dict get $outer spec] create $e $seeds
        return [list block $e $arity any]
    }
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
    set spec [dict exists $ctx spec]
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
            if {$spec && !$dead} {
                foreach argType $argTypes paramType [dict get $meta paramTypes] {
                    set kind [kindOf $argType]
                    if {$paramType ni {"" any} && $kind ne "" && $kind ne [core::type::base $paramType]} {
                        # The argument is statically of another kind: the call
                        # always raises TYPE.
                        set dead 1
                    }
                }
                if {!$dead && [dict get $meta resultShape] ne ""} {
                    set result [ShapeResult $hir [dict get $meta resultShape] $argExprs $argTypes $result]
                }
            }
            if {!$dead} {
                # The call returned, so every argument had its parameter type.
                foreach arg $argExprs paramType [dict get $meta paramTypes] {
                    if {$paramType ne "" && $arg ne ""} {
                        Narrow $hir ctx [ValueBinding $hir $arg] $paramType
                    }
                }
            }
        } elseif {$spec} {
            set dead 1
        }
    } elseif {[lindex $calleeType 0] eq "block" && [llength $calleeType] == 4} {
        lassign $calleeType _ block arity blockResult
        set target [list block $block]
        if {$arity == [llength $argExprs]} {
            set result $blockResult
            if {$spec && !$dead && [dict get $ctx reachable]} {
                set result [{*}[dict get $ctx spec] call $e $block $argTypes]
            }
            if {!$dead && [dict exists $node nativeResultOverride]} {
                # A trusted native's declared result type survives -native-
                # body substitution (hir::ApplyNativeResultOverrides):
                # still run the spec handler above unconditionally, so
                # instance discovery/edges for the substituted body are
                # unaffected, but the call's own *type* is the registered
                # one, not whatever the body block infers.
                set result [dict get $node nativeResultOverride]
            }
        } elseif {$spec} {
            set dead 1
        }
    } elseif {$spec && [kindOf $calleeType] ni {"" block native}} {
        # Not callable: the call always raises NOT-CALLABLE.
        set dead 1
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
    if {[dict exists $ctx spec] && [kindOf $test] ni {"" bool}} {
        # Region inference: the condition is statically not a Boolean, so
        # the if always raises NOT-BOOLEAN.
        set test never
    }
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
