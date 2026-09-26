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
#   {immutableSet ELEM}             an ImmutableSet (MINIMAL-IMMUTABLE-SET.
#                                   md) whose every member has static type
#                                   ELEM; structurally parallel to {list
#                                   ELEM}, but never has a positional shape
#                                   (a set is semantically unordered)
#
# The list and immutableSet forms are *aggregate facts*. Semantic inference
# (infer) never produces a *shaped* (positional) one: a program's HIR types
# stay what they were. Only specialization inference (inferRegion, used by
# hir/specialize.tcl) tracks a List's positional shape. Both forms are
# bounded (see MakeList/MakeSet), so analyses over them terminate.
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
    # Registered *type constructors* (MINIMAL-APPLIED-LIST-TYPES.md): NAME
    # -> arity. A source type annotation "NAME[ARG]" (surface::parser::
    # TypeExpr) is resolved generically against this table (resolveNamed/
    # resolveApplication below), not by special-casing a constructor's name
    # in the parser or in hir::resolve.tcl. ImmutableSet (MINIMAL-IMMUTABLE-
    # SET.md) is this registry's second entry, added with no grammar or
    # resolution-mechanism change -- confirming the List[T] milestone's own
    # claim that a future unary container needs only another entry here
    # (plus a case in resolveApplication/MakeSet below), never new syntax.
    variable constructors [dict create List 1 ImmutableSet 1]
}

# The canonical resolved type for a bare (unapplied) type name NAME -- an
# ordinary named/primitive type (core::type::normalize, unchanged), or a
# Tcl error if NAME is itself a registered type constructor used with no
# type argument at all ("fn f(x: List):" -- an arity error, not "unknown
# type": #5/#49 of MINIMAL-APPLIED-LIST-TYPES.md). Called only from
# hir::resolve::ResolveTypeExpr, which turns the error into a located HIR
# diagnostic exactly as a plain core::type::normalize failure always has.
proc hir::types::resolveNamed {name} {
    variable constructors
    if {[dict exists $constructors $name]} {
        error "type constructor \"$name\" requires [dict get $constructors $name]\
            type argument(s) (e.g. $name\[...\])"
    }
    return [core::type::normalize $name]
}

# The canonical resolved type for type constructor CTOR applied to ARGS (a
# list of already-resolved types, one per this grammar's single bracketed
# type argument). Raises a Tcl error -- again turned into a located HIR
# diagnostic by the caller -- for an unregistered constructor name, an
# ordinary type used as if it were one ("Small[Int]"), or the wrong number
# of arguments. List is the only registered constructor; its resolved type
# is the *same* structural {list ELEM} form hir::types::MakeList already
# produces for an ordinary List value's inferred element type (Call, below)
# -- one canonical representation for "a List of ELEM", not a parallel
# constructor-specific encoding (spec item 83).
proc hir::types::resolveApplication {ctor argTypes} {
    variable constructors
    if {![dict exists $constructors $ctor]} {
        if {[core::type::valid $ctor]} {
            error "\"$ctor\" is not a type constructor"
        }
        error "unknown type constructor \"$ctor\""
    }
    set arity [dict get $constructors $ctor]
    if {[llength $argTypes] != $arity} {
        error "\"$ctor\" takes $arity type argument(s), got [llength $argTypes]"
    }
    switch -- $ctor {
        List { return [MakeList [lindex $argTypes 0] {} 0 0] }
        ImmutableSet { return [MakeSet [lindex $argTypes 0] 0] }
    }
}

proc hir::types::IsSpecific {type} {
    return [expr {$type eq "never"
                  || ([llength $type] > 1 && [lindex $type 0] in {native block list immutableSet})}]
}

# 1 if TYPE is a list form ({list ELEM} or {list ELEM SHAPE}).
proc hir::types::IsList {type} {
    return [expr {[lindex $type 0] eq "list" && [llength $type] in {2 3}}]
}

# 1 if TYPE is a set form ({immutableSet ELEM}). Never a 3-element shaped
# form: a set has no positional shape (MINIMAL-IMMUTABLE-SET.md item 39).
proc hir::types::IsSet {type} {
    return [expr {[lindex $type 0] eq "immutableSet" && [llength $type] == 2}]
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

# The canonical set form of an ImmutableSet whose members have type ELEM,
# nested DEPTH list/set forms deep. No positional shape exists for a set
# (item 39): this is MakeList's own element-typing half, without the
# shaped/positions machinery that exists only for List's own heterogeneous-
# element tracking.
proc hir::types::MakeSet {elem depth} {
    variable aggregateDepth
    if {$depth >= $aggregateDepth} {
        return immutableSet
    }
    set elem [Unshaped [Bound $elem [expr {$depth + 1}]]]
    if {$elem eq "any"} {
        return immutableSet
    }
    return [list immutableSet $elem]
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
    if {[IsSet $type]} {
        return [MakeSet [lindex $type 1] $depth]
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
    if {[IsSet $a] && [IsSet $b]} {
        # Unlike List's own (specialization-motivated) covariant element-lub
        # above, two differently-elemented ImmutableSets widen straight to
        # the broad kind, never to ImmutableSet[lub(A,B)] (item 38): the
        # $a eq $b case above already returns the identical set type when
        # both branches agree, and this milestone deliberately does not
        # invent element-lub for sets merely because List has one.
        return immutableSet
    }
    if {[IsSpecific $a] || [IsSpecific $b]} {
        set kind [kindOf $a]
        return [expr {$kind ne "" && $kind eq [kindOf $b] ? $kind : "any"}]
    }
    return [core::type::lub $a $b]
}

# Narrows CURRENT by a proven FACT (a core type, or -- M7B-CONJUNCTIVE-
# ENTRY-FACTS.md -- a declared List[T]/ImmutableSet[T] aggregate theorem
# whose own constructor matches CURRENT's). CURRENT's own bottom case
# ("never" narrows to itself, unconditionally) is what makes this sound for
# an aggregate's *element* position too, not just its own top level: a
# List/ImmutableSet whose element is the scalar atom `never` (M7.a.a: a
# statically proven *empty* aggregate, never "element type unknown")
# recurses into that element with the very same rule and keeps it `never`,
# so combining a provably-empty aggregate's own observed fact with a
# declared element theorem never fabricates an element the value cannot
# have (spec item 63: emptiness must never manufacture existence) --
# while a *non-empty* (or shape-only) aggregate's element position is
# narrowed exactly as a bare scalar parameter already was (M1), letting the
# declared element contract survive specialization for it too (spec item
# 22 of M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md's own "S05d" gap). Two
# List/ImmutableSet forms narrow only when they share a constructor (both
# List, or both ImmutableSet); anything else (a callable key, a positional
# shape against a non-list declared type, or a mismatched constructor) has
# nothing sound to combine and falls through to the callable/kind rule
# below, unchanged from before this milestone.
proc hir::types::narrow {current fact} {
    if {$fact eq "any" || $current eq "never"} {
        return $current
    }
    if {[IsList $current] && [IsList $fact]} {
        set elem [narrow [lindex $current 1] [lindex $fact 1]]
        set positions [shapeOf $current]
        if {$positions ne ""} {
            return [MakeList $elem [lmap p $positions {narrow $p [lindex $fact 1]}] 1]
        }
        return [MakeList $elem]
    }
    if {[IsSet $current] && [IsSet $fact]} {
        return [MakeSet [narrow [lindex $current 1] [lindex $fact 1]] 0]
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

# 1 if every value of static TYPE is guaranteed to support Botlish's
# ordinary structural equality unconditionally: the compile-time mirror of
# the *actual* equality-totality condition both equality implementations
# enforce (core/value.tcl's core::value::equal and native/src/runtime/
# ops.rs's equal, byte-for-byte the same rule): a comparison can only ever
# fail (raise EQUALITY) when one of its two operands has runtime kind
# Block, Native, or MutableArray. Every other kind (Int -- and so every
# source-defined bounded-integer domain over it, e.g. Byte/Nibble/Small,
# since kindOf collapses a refinement to its base kind -- Str, Bool, Unit,
# UnicodeChar) is unconditionally safe, regardless of which *other*
# equality-total kind it is compared against (mismatched kinds simply
# compare unequal, never fail: see equal's own "ka != kb -> false" branch,
# checked only *after* its Block/Native/MutArray guard). "any"/an
# unresolved or broad aggregate kind (a bare "list"/"immutableSet" with no
# known element type, or "" for a type with no fixed kind at all) is
# conservatively not proven: a value of that static type could still be
# one of the three unsafe kinds at runtime.
#
# Deliberately narrow (this is SetContains's own effect refinement's
# "minimum useful proof" -- M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md): does
# not recurse into a List[T]/ImmutableSet[T] element type, so a precise
# List[Byte] is not (yet) proven total even though core::value::equal's own
# recursive list case would make it so -- sound but incomplete, never
# unsound, and not needed by this milestone's own motivating call site.
proc hir::types::IsEqualityTotal {type} {
    return [expr {[kindOf $type] in {int str bool unit UnicodeChar}}]
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
                    # A positional (heterogeneous) shape: internal
                    # specialization/aggregate-fact detail, never a source-
                    # spellable declared type (ResolveTypeExpr never
                    # produces one -- see Call's Unshaped stripping below),
                    # so it keeps its own pre-existing notation rather than
                    # applied-type bracket syntax.
                    return "list\[[join [lmap p [lindex $type 2] {show $p}] {, }]\]"
                }
                # The canonical applied-type notation (MINIMAL-APPLIED-
                # LIST-TYPES.md): the same "List[T]" a source annotation
                # spells, so a diagnostic quoting this text is directly
                # source-legible.
                return "List\[[show [lindex $type 1]]\]"
            }
            immutableSet {
                # Same convention as List[T] above: the canonical applied-
                # type notation, matching what a declared ImmutableSet[T]
                # annotation spells (a set form is always 2-element -- it
                # never has a positional shape to special-case).
                return "ImmutableSet\[[show [lindex $type 1]]\]"
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
        immutable-set {
            # List[T] -> ImmutableSet[T] (MINIMAL-IMMUTABLE-SET.md item 24):
            # immutable_set_from_list's own -result-shape. Generic over T
            # exactly the way `element`/`append` above are generic over a
            # List's own element type -- no ImmutableSet-specific inference
            # code beyond this one shape case, reusing the same elementOf
            # this proc's List cases already use.
            lassign $shape _ l
            set elem [elementOf [lindex $argTypes $l]]
            if {$elem eq ""} {
                # The argument's own type carries no element information
                # (a broad/heterogeneous List, or a non-List static type):
                # the broad ImmutableSet kind, never a false precise one
                # (item 27).
                return $result
            }
            return [MakeSet $elem 0]
        }
        typed {
            # {typed NAME LO HI}: this native's result is a List whose
            # every element is an Int in LO..HI -- a fixed, argument-
            # independent semantic fact about the native itself (e.g.
            # encode_utf8's every UTF-8 code unit is definitionally in
            # 0..255, STATIC-COMPLETION-PROOFS.md), not something derived
            # from this call's own arguments the way `element`/`append`/
            # `immutable-set` above are. NAME is resolved here, lazily,
            # against whatever the compiling program's own source-defined-
            # type registry currently holds (core/native.tcl's ValidShape
            # comment): if the compiling program never declared NAME (e.g.
            # it never loaded the library module that does), this falls
            # back to the native's own plain declared -result-type, never a
            # false claim.
            #
            # Resolving the name is not, by itself, proof that the
            # native's elements inhabit it: the same spelling can validly
            # denote an unrelated or narrower domain in a different
            # compiling program (SYMBOLIC-TYPE-IDENTITY.md's own
            # motivating example: a program-local `type Byte = Int in
            # 0..15` must not make encode_utf8's result List[Byte] just
            # because "Byte" happens to resolve). So NAME's resolved type
            # is validated against the native's own LO..HI guarantee with
            # hir::range::ProvesType -- the same admissibility check a
            # declared function result type is already held to
            # (hir/range.tcl's verifyDeclaredResults) -- and the result
            # narrows to NAME only when that proof succeeds; otherwise this
            # falls back to the native's own plain declared -result-type,
            # exactly as when NAME is not registered at all. The target
            # type's own domain always comes from the registry (via
            # ProvesType/core::type::integerFacts); no domain is ever
            # hardcoded here for any particular NAME.
            lassign $shape _ name lo hi
            if {![core::type::isNamed $name]} {
                return $result
            }
            set resolved [core::type::normalize $name]
            if {![hir::range::ProvesType [dict create min $lo max $hi] $resolved]} {
                return $result
            }
            # MakeList must fold in the *resolved* semantic type, not the
            # bare symbolic NAME: MakeList/Bound/Unshaped treat their ELEM
            # argument as already-canonical (exactly what every other
            # ShapeResult case, and hir::types::resolveApplication's own
            # List case, always pass them), so storing the raw name here
            # left this case as the one place in the whole applied-type
            # vertical that produced a non-canonical {list NAME} -- distinct
            # from the canonical {list {refined int {NAME}}} a declared
            # List[NAME] annotation resolves to, even though both render
            # identically via hir::types::show (which normalizes on
            # display). Invariant List admissibility compares the stored
            # values directly (never display text), so the mismatch
            # silently rejected every call passing this native's result to a
            # declared List[NAME] parameter (M7A-INSTANCE-SELECTION-THEOREM-
            # AUDIT.md's encode_utf8/List[Byte] finding).
            return [MakeList $resolved]
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
        set value [dict get $hir bindings $b value]
        if {[core::value::kind $value] eq "native" && [dict exists $hir moduleNativeTargets]} {
            set name [core::value::nativeName $value]
            if {[dict exists $hir moduleNativeTargets $name]} {
                # This backend's own hir::buildSyntax -module-native-targets
                # (hir.tcl) redirected native NAME to an ordinary top-level
                # function elsewhere in this same HIR: a reference to the
                # native is typed as a call of that function, not of the
                # native, on every inference of it (including
                # hir/specialize.tcl's own per-instance re-inference, which
                # calls BindingType again -- so this stays correct there
                # too, unlike a one-shot post-hoc edit of a single call's
                # `target` field would). Every other backend leaves
                # moduleNativeTargets unset, so this is a no-op for them.
                lassign [dict get $hir moduleNativeTargets $name] block arity
                return [list block $block $arity any]
            }
        }
        return [ofValue $value]
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
        listloop {
            Expr hir ctx [dict get $node iterable]
            set elemType [elementOf [hir::typeOf $hir [dict get $node iterable]]]
            if {$elemType eq ""} {
                set elemType any
            }
            set saved [dict get $ctx facts]
            dict set ctx facts [dict get $node elementBinding] $elemType
            dict set ctx breakTypes $e never
            # Unlike a plain `loop`, a listloop's own natural (non-break)
            # completion contributes too: every iteration's ordinary body
            # value is collected into the result List, so the body's own
            # Sequence type (when reachable) seeds the result as List[R],
            # unified (lub) with whatever break payload types are also
            # reachable -- exactly the pre-existing breakTypes lub, just
            # seeded with one extra contribution. Always contributed, even
            # when bodyType is itself never (a body that always diverges
            # whenever it runs): the loop can still complete normally with
            # an empty result for an empty iterable, exactly as a bare `[]`
            # literal is List[never], not never itself.
            set bodyType [Sequence hir ctx [dict get $node body]]
            set type [lub [dict get $ctx breakTypes $e] [MakeList $bodyType]]
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
        fail {
            return [SetType hir $e never]
        }
        handle {
            return [SetType hir $e [Handle hir ctx $e]]
        }
    }
}

# Types a `handle CALL NAME1 HANDLER1 ...` expression E
# (EXPLICIT-ERROR-COMPLETIONS.md). The call's own normal-completion type T
# is the whole construct's type when live (item 11: no implicit union
# widening of a handled-result binding), so every handler that completes
# normally must itself prove a value admissible as T -- exactly the
# STRICT-TYPED-PARAMETERS.md-style admissibility hir/range.tcl's own
# verifyDeclaredResults already applies to a declared function result, not
# a fresh algorithm (checked by hir/errorsets.tcl, after inference, once T
# and every handler's inferred type are known; not here, since that check
# also needs the call's resolved target/declared error set, computed by
# Call below in this very pass). Reachability of each handler body is
# conservative (entry-reachable, like an `if` whose outcome isn't known):
# nothing here claims to know which error, if any, a call actually
# produces at run time (spec items 27/82 defer that proof).
proc hir::types::Handle {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set entry [dict get $ctx reachable]
    set callType [Expr hir ctx [dict get $node call]]
    dict set ctx reachable $entry

    set handlerTypes {}
    foreach body [dict get $node handlerBodies] {
        dict set ctx reachable $entry
        set saved [dict get $ctx facts]
        lappend handlerTypes [Sequence hir ctx $body]
        dict set ctx facts $saved
    }
    dict set ctx reachable $entry
    # Recorded for hir/errorsets.tcl, which (after this whole inference
    # pass) rejects any live handler whose type is not admissible as
    # CALLTYPE -- item 11: no implicit union widening of a handled-result
    # binding, so CALLTYPE alone is T, never a lub of the handlers' types.
    dict set hir exprs $e handlerTypes $handlerTypes
    if {$callType ne "never"} {
        return $callType
    }
    set result never
    foreach t $handlerTypes {
        set result [lub $result $t]
    }
    return $result
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
    set declared [dict get $node declaredResult]
    set assumed [expr {$declared eq {} ? {never} : $declared}]
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
        # A parameter annotation seeds its binding's semantic type directly
        # (never a runtime check, STRICT-TYPED-PARAMETERS.md): from here on
        # the body sees x as T, exactly as if a caller-independent fact had
        # already been proven -- because, by the time any call reaches this
        # body, one has (hir::range::verifyDeclaredParams rejects every
        # call whose argument is not statically admissible for T before
        # this attempt ever ran). This also lets hir::range's own
        # TypeFact/ConstrainType (already applied to every ref's own
        # semantic type) seed x's declared range/exact-set facts for free,
        # with no separate parameter-fact mechanism.
        foreach b [dict get $node params] declaredType [dict get $node declaredParamTypes] {
            if {$declaredType ne {}} {
                dict set ctx types $b $declaredType
            }
        }
        set body [Sequence hir ctx [dict get $node body]]
        set result [lub $body [dict get $ctx returnType]]
        if {$self eq "" || $result eq $assumed || $assumed eq "any"} {
            break
        }
        set assumed $result
    }
    dict set hir exprs $e inferredResultType [intern hir $result]
    if {$declared ne {}} { set result $declared }
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
            }
            if {!$dead && [dict get $meta resultShape] ne ""} {
                # -result-shape (core/native.tcl) lets a static analysis
                # that tracks list contents do better than the native's own
                # declared -result-type without knowing it by name. This
                # used to run only during specialization's own region
                # inference; it now also runs here, in ordinary whole-
                # program semantic inference, which is exactly what lets an
                # ordinary List construction/element-read
                # (list/list_get/list_append, core/lists.tcl,
                # core/primitives.tcl) carry or recover a concrete List[T]
                # applied type with no List-specific inference code of its
                # own (MINIMAL-APPLIED-LIST-TYPES.md).
                set result [ShapeResult $hir [dict get $meta resultShape] $argExprs $argTypes $result]
                if {!$spec} {
                    # Ordinary inference tracks only a List's element type
                    # (the applied List[T] a source annotation can spell),
                    # never a positional shape: only hir/specialize.tcl's
                    # own per-instance region inference needs positional
                    # precision, and stripping it here keeps every ordinary
                    # List value's canonical type exactly the same 2-form
                    # {list ELEM} a declared List[T] annotation resolves to
                    # (hir::types::resolveApplication), so admissibility can
                    # compare the two structurally.
                    set result [Unshaped $result]
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
    # The declared errors this call may propagate (EXPLICIT-ERROR-
    # COMPLETIONS.md), for hir/errorsets.tcl. Only an exact, directly-known
    # callee (target {block ExprId}) can ever be charged with a nonempty
    # set here: a native never declares one, and any other callee (an
    # unresolved dynamic dispatch) is sound to treat as producing none,
    # because hir/callables.tcl's escape audit (widened to cover an error-
    # bearing block exactly like a typed-parameter-bearing one) already
    # rejects every position that would let an error-bearing block reach
    # such a call erased of its exact identity -- so a callee that reaches
    # here *without* an exact block target can never actually be one.
    set calleeErrors {}
    if {[lindex $target 0] eq "block"} {
        set calleeErrors [dict get $hir exprs [lindex $target 1] declaredErrors]
    }
    dict set hir exprs $e calleeErrors $calleeErrors
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
