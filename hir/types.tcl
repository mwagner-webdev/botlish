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
#   {block EXPR ARITY RESULT CONTRACT}
#                                   the same, for a block that declares a
#                                   parameter type or an error set:
#                                   CONTRACT is {args {T1 ...} errors
#                                   {E1 ...}} (see blockType, below)
#   {fn {args {T1 ...} return R errors {E1 ...}}}
#                                   a *structural function type*
#                                   (STRUCTURAL-FUNCTION-TYPES.md): some
#                                   callable -- native, envless Block or
#                                   capturing Block, which one is not known
#                                   -- that accepts arguments admissible
#                                   for T1..Tn, returns R when it completes
#                                   normally, and may let at most the
#                                   declared errors E1.. escape
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
#   {struct {F1 T1 F2 T2 ...}}      an *anonymous struct* (STRUCTS.md): a
#                                   struct value whose fields are exactly
#                                   F1.. (sorted by name: the canonical
#                                   order, so source order is never part of
#                                   type identity), field Fi of static type
#                                   Ti. Structural: two anonymous structs
#                                   have one type iff they have the same
#                                   field names and the same field types.
#                                   Not spellable in a source annotation.
#   {nstruct ID}                    a *named struct*: a value of the struct
#                                   declared as ID (hir/structs.tcl). Nominal:
#                                   the identity is the declaration, never
#                                   the fields, and the schema is the
#                                   declaration's (hir::structs::fieldType).
#   struct                          the broad kind of every struct value (a
#                                   depth-truncated struct type, and the
#                                   runtime kind's own name); no field can
#                                   be projected from it.
#   {trait ID}                      a trait *constraint* (TRAITS.md): what a
#                                   parameter or result annotation naming
#                                   trait ID resolves to; never a value's type
#   {trait ID WITNESS}              a *trait view*: a value accepted through
#                                   trait ID's constraint. Source-visible as
#                                   ID only (its requirements are its whole
#                                   interface); WITNESS is the compiler's
#                                   hidden static provenance -- the concrete
#                                   witness type, {param E I} (the abstract
#                                   witness of parameter I of block E) or
#                                   {join W...} (a rejected join). A view is a
#                                   subtype of its constraint and of any, of
#                                   nothing else; no concrete type is a
#                                   subtype of a constraint (acceptance is
#                                   hir::traits::Accept, at the boundary)
#   {mutarray ELEM}                 a MutableArray[ELEM] (PARAMETERIZED-
#                                   MUTABLEARRAY.md): a mutable object whose
#                                   static contract is that every slot value
#                                   belongs to ELEM and every store preserves
#                                   that. Static only -- the runtime object
#                                   carries no element type. Invariant in
#                                   ELEM, and never silently erasable to the
#                                   bare `mutarray` kind or to `any`
#                                   (hir/callables.tcl audits every position
#                                   that would). The bare atom `mutarray` is
#                                   the raw, element-untyped substrate type.
#
# The list and immutableSet forms are *aggregate facts*. Semantic inference
# (infer) never produces a *shaped* (positional) one: a program's HIR types
# stay what they were. Only specialization inference (inferRegion, used by
# hir/specialize.tcl) tracks a List's positional shape. Both forms are
# bounded (see MakeList/MakeSet), so analyses over them terminate.
#
# Exact value facts (EXACT-VALUE-FACTS.md, hir/exactvalue.tcl) are a
# separate, ephemeral channel and never a type: `list::at` of a List the
# compiler knows exactly (a literal, an immutable alias of one, list::append
# of one, bounded by shapeLength/aggregateDepth) at an exactly known index
# gets the selected element's own type in *ordinary* inference too, and a
# comparison of two exactly known operands is decided (`known`). The List's
# own type stays {list ELEM}; a parameter never acquires an element type
# from how its body indexes it.

# These are semantic facts, not representation: nothing here says how a
# backend stores a value. The procedures handle the extra forms and delegate
# everything else to core::type, so a refinement or named type means the same
# thing here as to the interpreter.
#
# Invariant: if an expression has static type T (a core type), each value v
# it evaluates to satisfies core::type::acceptsValue T v.
#
# Types are interned per HIR program: nodes and bindings hold TypeIds.
#
# Callable types (STRUCTURAL-FUNCTION-TYPES.md)
# ---------------------------------------------
# The exact forms say *which code runs*: {native NAME} one native, {block E
# ...} the code of block expression E -- with whatever environment the
# particular Block value carries (two closures made by two activations of
# one factory share one exact type: exactness is code identity, never
# closure-object or environment identity). The structural form says only
# *what calling is allowed to do*: its call contract. Every exact callable
# type with a fixed arity has one canonical structural supertype,
# structuralOf, derived from the one authoritative signature source of its
# kind -- the native registry's -param-types/-result-type (natives never
# declare errors), or the block's own resolved declaredParamTypes (an
# untyped parameter is any), its result type (the declared one if any, else
# the inferred one) and its declaredErrors. A block that declares neither a
# parameter type nor an error has the trivial contract (every argument any,
# no errors), which the four-element exact form already says; a block that
# does carries it as the fifth element, so that structuralOf, subtype and
# lub stay pure functions of their type arguments (they are called with no
# HIR in reach) and every exact type of one block has one canonical
# spelling (blockType is its only constructor).
#
# Compatibility (subtype A B, B structural) is the call contract's: equal
# arity; arguments contravariant under declared-parameter admissibility
# (Admits: every argument B's callers may prove admissible is admissible for
# A's own parameter); return covariant; A's errors a subset of B's (a
# declared error set is an upper bound: an implementation may produce
# fewer). lub of two different callables is their narrowest representable
# common structural type (FnLub: glb of the arguments, lub of the returns,
# union of the errors), never a union of targets; when no argument meet is
# representable it falls back exactly as before (the shared kind, or any).

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
    variable constructors [dict create List 1 ImmutableSet 1 MutableArray 1]
}

# The canonical resolved type for a bare (unapplied) type name NAME -- an
# ordinary named/primitive type (core::type::normalize, unchanged), or a
# Tcl error if NAME is itself a registered type constructor used with no
# type argument at all ("fn f(x: List):" -- an arity error, not "unknown
# type": #5/#49 of MINIMAL-APPLIED-LIST-TYPES.md). Called only from
# hir::resolve::ResolveTypeExpr, which turns the error into a located HIR
# diagnostic exactly as a plain core::type::normalize failure always has.
proc hir::types::resolveNamed {name {ns ""}} {
    variable constructors
    if {[dict exists $constructors $name]} {
        error "type constructor \"$name\" requires [dict get $constructors $name]\
            type argument(s) (e.g. $name\[...\])"
    }
    # A declared struct (hir/structs.tcl): `Person` in the code's own
    # namespace NS, or a module-qualified `geo::Point`. The struct
    # declarations are a type namespace of their own, consulted before
    # core::type's registry (and never colliding with it: apply rejects a
    # struct named like any registered type).
    set id [hir::structs::lookup $name $ns]
    if {$id ne ""} {
        return [list nstruct $id]
    }
    # A trait (TRAITS.md): the same type namespace and visibility rules as a
    # struct or a source-defined type, `import type` included. A bare
    # annotation names the constraint; only a parameter or result position
    # accepts one (every other position rejects it: MentionsTrait).
    set trait [hir::traits::lookup $name $ns]
    if {$trait ne ""} {
        return [list trait $trait]
    }
    # A source-defined `type`: spelled bare it is the code's own namespace's
    # (declared there) or the one a `import type` of its file binds to that
    # short name; spelled qualified it is exactly that member. Either way the
    # type is the one canonical `NS::Name` identity -- no alias exists.
    set canonical [CanonicalTypeName $name $ns]
    if {[string first :: $canonical] >= 0 && ![core::type::isSource $canonical]} {
        error "unknown type \"$name\": no source-defined type or struct of that name is declared in that namespace"
    }
    if {$ns ne "" && $canonical eq $name && [core::type::isSource $name]} {
        # The entry program's own type: not visible from a module.
        error "core::type: unknown type \"$name\" (a module sees its own types, the types it imports with `import type`, and the built-in types; not the program's)"
    }
    return [core::type::normalize $canonical]
}

# The registry identity the bare or qualified type spelling NAME denotes in
# the file of namespace NS ("" for the entry program): a qualified spelling
# is itself; a bare one is NS's own declared type `NS::NAME` if there is one,
# else the type its file's `import type` binds to NAME, else NAME unchanged
# (a built-in type, or the entry program's own).
proc hir::types::CanonicalTypeName {name ns} {
    if {[string first :: $name] >= 0} {
        return $name
    }
    if {$ns ne "" && [core::type::isSource ${ns}::$name]} {
        return ${ns}::$name
    }
    set imported [hir::imports::typeNamed $ns $name]
    return [expr {$imported ne "" ? $imported : $name}]
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
    foreach t $argTypes {
        set contextTrait [MentionedContextTrait $t]
        if {$contextTrait ne ""} {
            return -code error -errorcode {BOTLISH CONTEXT-TRAIT-POSITION} \
                [ContextTraitPositionMessage $contextTrait "the element type of $ctor\[[show $t]\]"]
        }
        if {[MentionsTrait $t]} {
            # A container of trait values would have to carry arbitrary
            # witnesses: there is no erased/heterogeneous trait
            # representation (TRAITS.md, "Storage").
            return -code error -errorcode {BOTLISH TRAIT-STORAGE-UNSUPPORTED} \
                "$ctor\[[show $t]\] would store trait values: a container element cannot be a trait (there is no erased or heterogeneous trait representation: elements need one concrete witness type)"
        }
    }
    switch -- $ctor {
        List { return [MakeList [lindex $argTypes 0] {} 0 0] }
        ImmutableSet { return [MakeSet [lindex $argTypes 0] 0] }
        MutableArray { return [MakeMutArray [lindex $argTypes 0] 0] }
    }
}

proc hir::types::IsSpecific {type} {
    return [expr {$type eq "never"
                  || ([llength $type] > 1 && [lindex $type 0] in {native block list immutableSet mutarray fn struct nstruct trait})}]
}

# ---------------------------------------------------------------------------
# Trait types (TRAITS.md; the header's {trait ID} and {trait ID WITNESS})

# 1 if TYPE is a trait constraint or a trait view.
proc hir::types::IsTrait {type} {
    return [expr {[lindex $type 0] eq "trait" && [llength $type] in {2 3}}]
}

# 1 if TYPE is a trait constraint ({trait ID}: an annotation).
proc hir::types::IsTraitConstraint {type} {
    return [expr {[lindex $type 0] eq "trait" && [llength $type] == 2}]
}

# 1 if TYPE is a trait view ({trait ID WITNESS}: a value's type).
proc hir::types::IsView {type} {
    return [expr {[lindex $type 0] eq "trait" && [llength $type] == 3}]
}

proc hir::types::ViewTrait {type} { return [lindex $type 1] }
proc hir::types::ViewWitness {type} { return [lindex $type 2] }

# The view of trait ID whose hidden witness is WITNESS.
proc hir::types::MakeView {id witness} {
    return [list trait $id $witness]
}

# 1 if WITNESS (a view's hidden witness) is a rejected join of several.
proc hir::types::IsJoinWitness {witness} {
    return [expr {[lindex $witness 0] eq "join" && [llength $witness] > 2}]
}

# 1 if WITNESS is an abstract witness ({param E I}).
proc hir::types::IsAbstractWitness {witness} {
    return [expr {[lindex $witness 0] eq "param" && [llength $witness] == 3}]
}

# 1 if TYPE is or contains a trait type (an element, a field, a function
# type's argument or result): the positions where a trait cannot appear.
proc hir::types::MentionsTrait {type} {
    if {[IsTrait $type]} {
        return 1
    }
    if {[IsList $type] || [IsSet $type] || [IsMutArray $type]} {
        return [MentionsTrait [lindex $type 1]]
    }
    if {[IsFn $type]} {
        foreach t [FnArgs $type] {
            if {[MentionsTrait $t]} { return 1 }
        }
        return [MentionsTrait [FnReturn $type]]
    }
    if {[IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[MentionsTrait $t]} { return 1 }
        }
    }
    return 0
}

# The context trait (CONTEXT-TRAITS.md) TYPE is or contains -- an element, a
# field, a function type's argument or result -- or "". A context trait is an
# environment capability, never a value type: it is valid only as the type of
# a context parameter, and every other position rejects it
# (CONTEXT-TRAIT-POSITION, ContextTraitPositionMessage).
proc hir::types::MentionedContextTrait {type} {
    if {[IsTrait $type]} {
        return [expr {[hir::traits::isContext [lindex $type 1]] ? [lindex $type 1] : ""}]
    }
    set inner {}
    if {[IsList $type] || [IsSet $type] || [IsMutArray $type]} {
        set inner [list [lindex $type 1]]
    } elseif {[IsFn $type]} {
        set inner [concat [FnArgs $type] [list [FnReturn $type]]]
    } elseif {[IsStruct $type]} {
        set inner [lmap {name t} [lindex $type 1] {set t}]
    }
    foreach t $inner {
        set id [MentionedContextTrait $t]
        if {$id ne ""} {
            return $id
        }
    }
    return ""
}

# The CONTEXT-TRAIT-POSITION message for context trait ID used as WHAT ("the
# type of parameter \"x\"", "a List element", ...).
proc hir::types::ContextTraitPositionMessage {id what} {
    return "$id is a context trait, which cannot be $what: a context trait is an execution-environment capability, not a value type -- it has no value, representation or storage, and is valid only as the type of a context parameter (\"context NAME: [namespace tail $id]\")"
}

# The hidden witness of a join of views with witnesses A and B: the one
# witness when they are the same, else {join W...} (sorted, flattened).
proc hir::types::JoinWitness {a b} {
    if {$a eq $b} {
        return $a
    }
    set all {}
    foreach w [list $a $b] {
        if {[IsJoinWitness $w]} {
            lappend all {*}[lrange $w 1 end]
        } else {
            lappend all $w
        }
    }
    set all [lsort -unique $all]
    return [expr {[llength $all] == 1 ? [lindex $all 0] : [linsert $all 0 join]}]
}

# TYPE as an aggregate element/field: a view is erased to any (the concrete
# runtime value is what is stored; no witness or tag is kept, TRAITS.md
# "any"), so no List/ImmutableSet/MutableArray/struct type ever has a trait
# element.
proc hir::types::Unviewed {type} {
    return [expr {[IsTrait $type] ? "any" : $type}]
}

# ---------------------------------------------------------------------------
# Struct types (STRUCTS.md; the header's {struct FIELDS} and {nstruct ID})

# 1 if TYPE is an anonymous struct type.
proc hir::types::IsStruct {type} {
    return [expr {[lindex $type 0] eq "struct" && [llength $type] == 2}]
}

# 1 if TYPE is a named struct type.
proc hir::types::IsNamedStruct {type} {
    return [expr {[lindex $type 0] eq "nstruct" && [llength $type] == 2}]
}

# 1 if TYPE is any precise struct type, anonymous or named.
proc hir::types::IsStructLike {type} {
    return [expr {[IsStruct $type] || [IsNamedStruct $type]}]
}

# The canonical anonymous struct type with the fields FIELDS (a dict, field
# name -> type, in any order), nested DEPTH aggregate forms deep. The field
# names are sorted (plain code-point order): the one canonical layout, so
# the order fields are written in is never part of a struct's type. Field
# types are bounded like every aggregate's, so the lattice stays finite;
# past the bound the result is the bare `struct` kind -- sound for the same
# reason a truncated List is (hir/callables.tcl compares a value's own type
# with the position it flows into exactly, so a bearing struct flowing into a
# truncated position is an erasure and is rejected there). A `never` field
# (an expression that never completes makes the whole struct never, see
# hir::types::Struct) is recorded as `any`.
proc hir::types::MakeStruct {fields depth} {
    variable aggregateDepth
    if {$depth >= $aggregateDepth} {
        return struct
    }
    set inner [expr {$depth + 1}]
    set canonical {}
    foreach name [lsort [dict keys $fields]] {
        set t [dict get $fields $name]
        if {$t eq "never"} {
            set t any
        }
        lappend canonical $name [Unviewed [Unshaped [Bound $t $inner]]]
    }
    return [list struct $canonical]
}

# The field names of struct type TYPE in slot order: sorted for an anonymous
# struct, declared order for a named one. "" is not a struct type.
proc hir::types::StructLayout {type} {
    if {[IsStruct $type]} {
        return [dict keys [lindex $type 1]]
    }
    if {[IsNamedStruct $type]} {
        return [hir::structs::names [lindex $type 1]]
    }
    return ""
}

# The static type of field NAME of struct type TYPE, or "" if TYPE is not a
# struct type or has no such field. For a named struct it is the declared
# type, always: never narrowed by how a particular value was built.
proc hir::types::StructField {type name} {
    if {[IsStruct $type]} {
        set fields [lindex $type 1]
        return [expr {[dict exists $fields $name] ? [dict get $fields $name] : ""}]
    }
    if {[IsNamedStruct $type]} {
        return [hir::structs::fieldType [lindex $type 1] $name]
    }
    return ""
}

# The runtime *shape key* of struct type TYPE: what the runtime/codegen
# representation of its values depends on, never the semantic field types --
# {} for an anonymous struct followed by its canonical field names, or
# {ID FIELD...} for a named one (declaration identity, then slot order).
# Two anonymous struct types of one field set share a shape key even when
# their field types differ ({x: int} and {x: str}).
proc hir::types::StructShape {type} {
    if {[IsNamedStruct $type]} {
        return [linsert [StructLayout $type] 0 [lindex $type 1]]
    }
    return [linsert [StructLayout $type] 0 ""]
}

# ---------------------------------------------------------------------------
# Callable types (see the header's "Callable types" section)

# The canonical structural function type with argument types ARGTYPES, return
# type RESULT and declared error set ERRORS (any order, duplicates allowed:
# canonicalized here). DEPTH bounds the return type like a block result.
# Its fields are named and always listed in this one order -- args, return,
# errors -- so two equal contracts are equal strings; the planned `context`
# field (STRUCTURAL-FUNCTION-TYPES.md, "Future context extension point")
# is one more named entry here, read by FnSubtype/FnLub like the others,
# never a new positional form.
# Argument types are kept verbatim (canonicalized, never bounded): cutting
# an argument to a wider type would make the contract *narrower*, not an
# over-approximation, and every argument type is a declared type (or a glb
# of declared types), so their set is already finite.
proc hir::types::MakeFn {argTypes result errors {depth 0}} {
    variable aggregateDepth
    if {$depth >= $aggregateDepth} {
        return any
    }
    set argTypes [lmap a $argTypes {canonical $a}]
    set result [Bound [canonical $result] [expr {$depth + 1}]]
    return [list fn [dict create args $argTypes return $result errors [lsort -unique $errors]]]
}

# 1 if TYPE is a structural function type.
proc hir::types::IsFn {type} {
    return [expr {[lindex $type 0] eq "fn" && [llength $type] == 2}]
}

proc hir::types::FnArgs {type}   { return [dict get [lindex $type 1] args] }
proc hir::types::FnReturn {type} { return [dict get [lindex $type 1] return] }
proc hir::types::FnErrors {type} { return [dict get [lindex $type 1] errors] }

# 1 if TYPE is an exact block type ({block E ARITY RESULT ?CONTRACT?}).
proc hir::types::IsExactBlock {type} {
    return [expr {[lindex $type 0] eq "block" && [llength $type] in {4 5}}]
}

# 1 if TYPE is an exact native type ({native NAME}).
proc hir::types::IsExactNative {type} {
    return [expr {[lindex $type 0] eq "native" && [llength $type] == 2}]
}

# 1 if TYPE is statically known to be callable: an exact callable or a
# structural function type.
proc hir::types::IsCallable {type} {
    return [expr {[IsExactBlock $type] || [IsExactNative $type] || [IsFn $type]}]
}

# The non-trivial contract of block expression E in HIR -- {args {T1 ...}
# errors {E1 ...}}, an untyped parameter as any -- or "" when E declares
# neither a parameter type nor an error (the trivial contract the four-
# element exact form already implies).
proc hir::types::BlockContract {hir e} {
    set node [dict get $hir exprs $e]
    # The block's intrinsic entry contract (hir::signatures::entryTypes):
    # its declared parameter types, else the trusted contracts its own body
    # proves (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md) -- never a checked-
    # only requirement, which, like a native's own -param-types, is
    # re-validated at run time rather than assumed.
    set declared [hir::signatures::entryTypes $hir $e]
    set errors [expr {[dict exists $node declaredErrors] ? [dict get $node declaredErrors] : {}}]
    if {[lsearch -exact -not $declared {}] < 0 && $errors eq {}} {
        return ""
    }
    set args [lmap t $declared {expr {$t eq {} ? "any" : [canonical $t]}}]
    return [dict create args $args errors [lsort -unique $errors]]
}

# The exact type of a Block created by block expression E of HIR, taking
# ARITY arguments, whose calls return RESULT: the only constructor of an
# exact block type, so every exact type of one block carries the same
# contract (BlockContract).
proc hir::types::blockType {hir e arity result} {
    set contract [BlockContract $hir $e]
    if {$contract eq ""} {
        return [list block $e $arity $result]
    }
    return [list block $e $arity $result $contract]
}

# The greatest lower bound of structural function types A and B -- a
# contract whose every implementation satisfies both -- or "" if none is
# representable: equal arity, arguments joined (an implementation must
# accept what either contract's callers may pass: contravariant), returns
# met (glb), errors intersected. The dual of FnLub; used where two uses of
# one value each require a function contract (hir/signatures.tcl).
proc hir::types::FnGlb {a b} {
    if {$a eq $b} {
        return $a
    }
    set aa [FnArgs $a]
    set ba [FnArgs $b]
    if {[llength $aa] != [llength $ba]} {
        return ""
    }
    set args [lmap x $aa y $ba {lub $x $y}]
    set ra [FnReturn $a]
    set rb [FnReturn $b]
    if {$ra eq "any"} {
        set result $rb
    } elseif {$rb eq "any"} {
        set result $ra
    } elseif {[IsFn $ra] && [IsFn $rb]} {
        set result [FnGlb $ra $rb]
    } else {
        set result [glb $ra $rb]
    }
    if {$result eq ""} {
        return ""
    }
    set errors {}
    foreach e [FnErrors $a] {
        if {$e in [FnErrors $b]} {
            lappend errors $e
        }
    }
    return [MakeFn $args $result $errors]
}

# The canonical structural function type of callable type TYPE: TYPE itself
# for a structural type; for an exact block, its contract and result type;
# for an exact native, its registry signature: its fixed arity, its
# -result-type, its -errors (none for every native but `argv`,
# core/process.tcl) -- and every argument any.
# A native's -param-types are *run-time-checked requirements* (the native
# validates its own arguments on every call, raising TYPE: core/native.tcl's
# "types the implementation requires"), never static proof obligations a
# caller must discharge, so its call contract imposes none: exactly how a
# direct call of a native with an argument of type any is already accepted.
# A structural argument type is only ever a *static* obligation (a declared
# parameter type, a Fn annotation) -- which is what lets the typed-callable
# escape audit (hir/callables.tcl) decide from the type alone whether a
# structural value may still carry an obligation worth protecting
# (STRUCTURAL-FUNCTION-TYPES.md, "Native signature derivation"). "" when
# TYPE is not a callable type, or is a native of variable arity (`list`: no
# fixed-arity contract exists, and this milestone invents no variadic
# function typing).
proc hir::types::structuralOf {type} {
    if {[IsFn $type]} {
        return $type
    }
    if {[IsExactNative $type]} {
        if {[catch {core::native::metadata [lindex $type 1]} meta]} {
            return ""
        }
        set arity [dict get $meta arity]
        if {$arity eq "*"} {
            return ""
        }
        return [MakeFn [lrepeat $arity any] [dict get $meta resultType] [dict get $meta errors]]
    }
    if {[IsExactBlock $type]} {
        lassign $type _ e arity result contract
        if {$contract eq ""} {
            return [MakeFn [lrepeat $arity any] $result {}]
        }
        return [MakeFn [dict get $contract args] $result [dict get $contract errors]]
    }
    return ""
}

# 1 if a value of static type T is provably admissible where DECLARED is a
# declared parameter type: hir::range::ProvesValueAcceptedBy -- the one
# admissibility proof a call's typed argument is held to -- with the
# integer-domain facts T's own type implies as its Range. This (not
# subtype) is what a structural function type's *arguments* are compared
# with, because they are exactly declared parameter obligations: List[T]
# and ImmutableSet[T] parameters stay invariant, and an integer domain
# contained in another is admissible for it even without a nominal parent.
proc hir::types::Admits {declared t} {
    return [hir::range::ProvesValueAcceptedBy $t [hir::range::TypeFact $t] $declared]
}

# 1 if a normal result of static type T is usable where EXPECTED is
# promised: covariant (subtype, consistent with lub's own joins of values)
# or admissible (an integer domain contained in another).
proc hir::types::ReturnFits {t expected} {
    return [expr {[subtype $t $expected] || [Admits $expected $t]}]
}

# 1 if structural function type A is usable wherever structural function
# type B is expected (both {fn ...}): equal arity, each of A's parameters
# admits B's argument (contravariant), A's return fits B's (covariant),
# A's declared errors are a subset of B's.
proc hir::types::FnSubtype {a b} {
    return [expr {[FnMismatch $a $b] eq ""}]
}

# Why structural function type A is not usable where B is expected, or ""
# if it is: {arity N M}, {arg I}, {return}, or {errors NAME...} (the extra
# errors A may let escape) -- the first incompatible part of the contract,
# for diagnostics (FnSubtype is exactly "no mismatch").
proc hir::types::FnMismatch {a b} {
    set aa [FnArgs $a]
    set ba [FnArgs $b]
    if {[llength $aa] != [llength $ba]} {
        return [list arity [llength $aa] [llength $ba]]
    }
    set i 0
    foreach x $aa y $ba {
        if {![Admits $x $y]} {
            return [list arg $i]
        }
        incr i
    }
    if {![ReturnFits [FnReturn $a] [FnReturn $b]]} {
        return return
    }
    set extra {}
    foreach e [FnErrors $a] {
        if {$e ni [FnErrors $b]} {
            lappend extra $e
        }
    }
    if {$extra ne {}} {
        return [list errors {*}$extra]
    }
    return ""
}

# The greatest lower bound of argument types A and B in the representable
# fragment -- a type every value admissible for it is admissible for both
# A and B -- or "" if none is representable. One side if it is admissible
# for the other (the narrower one); two core types of one base meet in the
# union of their evidence (core::type::narrow, the repository's existing
# "a value of both" operation); anything else (different kinds, two
# unequal List/ImmutableSet/Fn types) has no representable meet here. A
# `never` meet of unrelated kinds would be sound but useless, so it is
# deliberately not produced: the caller falls back instead
# (STRUCTURAL-FUNCTION-TYPES.md, "Type meet / GLB strategy").
proc hir::types::glb {a b} {
    if {$a eq $b} {
        return $a
    }
    set aNarrower [Admits $b $a]
    set bNarrower [Admits $a $b]
    set core [expr {![IsSpecific $a] && ![IsSpecific $b] && $a ne "any" && $b ne "any"
        && [core::type::base $a] eq [core::type::base $b]}]
    if {$aNarrower && $bNarrower} {
        # Equivalent under admissibility: a deterministic, operand-order-
        # independent choice.
        return [expr {$core ? [core::type::narrow $a $b] : [lindex [lsort [list $a $b]] 0]}]
    }
    if {$aNarrower} {
        return $a
    }
    if {$bNarrower} {
        return $b
    }
    if {$core} {
        return [core::type::narrow $a $b]
    }
    return ""
}

# The narrowest representable structural function type both structural
# types A and B are subtypes of, or "" (different arity, an argument pair
# with no representable meet, or either side "").
proc hir::types::FnLub {a b} {
    if {$a eq "" || $b eq ""} {
        return ""
    }
    if {$a eq $b} {
        return $a
    }
    set aa [FnArgs $a]
    set ba [FnArgs $b]
    if {[llength $aa] != [llength $ba]} {
        return ""
    }
    set args {}
    foreach x $aa y $ba {
        set m [glb $x $y]
        if {$m eq ""} {
            return ""
        }
        lappend args $m
    }
    return [MakeFn $args [lub [FnReturn $a] [FnReturn $b]] [concat [FnErrors $a] [FnErrors $b]]]
}

# Why a value of static type ACTUAL does not satisfy structural function
# type EXPECTED, as a diagnostic clause naming the incompatible part of the
# contract (STRUCTURAL-FUNCTION-TYPES.md "Diagnostics"), or "" if it does.
proc hir::types::explainMismatch {actual expected} {
    if {[subtype $actual $expected]} {
        return ""
    }
    set s [structuralOf $actual]
    if {$s eq ""} {
        if {[IsExactNative $actual]} {
            return "native [lindex $actual 1] takes a variable number of arguments, so it has no function type"
        }
        return "a value of type [show $actual] is not known to be callable"
    }
    set why [FnMismatch $s $expected]
    switch -- [lindex $why 0] {
        arity {
            return "arity mismatch: the callable takes [lindex $why 1] argument(s), the function type [lindex $why 2]"
        }
        arg {
            set i [lindex $why 1]
            return [format {argument %d is incompatible: the callable's parameter requires %s, but callers of the function type may pass any %s} \
                [expr {$i + 1}] [show [lindex [FnArgs $s] $i]] [show [lindex [FnArgs $expected] $i]]]
        }
        return {
            return [format {return incompatible: the callable returns %s, not usable as %s} \
                [show [FnReturn $s]] [show [FnReturn $expected]]]
        }
        errors {
            return [format {error set incompatible: the callable may raise %s, but the function type allows only [%s]} \
                [join [lrange $why 1 end] {, }] [join [FnErrors $expected] {, }]]
        }
    }
    return ""
}

# TYPE as a structural contract, for diagnostics: its own text if it is
# structural, else "<exact text> (contract <Fn text>)" when it has one.
proc hir::types::showContract {type} {
    set s [structuralOf $type]
    if {$s eq "" || $s eq $type} {
        return [show $type]
    }
    return "[show $type] (contract [show $s])"
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

# 1 if TYPE is an applied MutableArray form ({mutarray ELEM}). The bare atom
# `mutarray` (the raw substrate kind) is deliberately not one.
proc hir::types::IsMutArray {type} {
    return [expr {[lindex $type 0] eq "mutarray" && [llength $type] == 2}]
}

# The canonical MutableArray[ELEM], nested DEPTH aggregate forms deep. Unlike
# List/ImmutableSet, ELEM = any is *not* folded into the bare kind: a
# MutableArray[any] is a fully initialized array whose element contract is
# the whole `any` domain, which the bare (raw) `mutarray` type does not say.
# Past the aggregate bound the result is the bare kind; that is sound only
# because hir/callables.tcl compares every value's own type with the
# position it flows into exactly, so a precise MutableArray flowing into a
# bound-truncated position is an erasure and is rejected there. A `never`
# element (List[never], the empty literal) means an array with no slot that
# can ever be read or written: it is recorded as `any`.
proc hir::types::MakeMutArray {elem depth} {
    variable aggregateDepth
    if {$depth >= $aggregateDepth} {
        return mutarray
    }
    if {$elem eq "never"} {
        set elem any
    }
    return [list mutarray [Unviewed [Unshaped [Bound $elem [expr {$depth + 1}]]]]]
}

# 1 if element contracts A and B are the same contract: identical, or each
# admissible for the other (two spellings of one value domain). MutableArray
# is invariant, so this -- not subtype -- relates two MutableArray element
# types.
proc hir::types::Equivalent {a b} {
    if {$a eq $b} {
        return 1
    }
    return [expr {[Admits $a $b] && [Admits $b $a]}]
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
        set positions [lmap p $positions {Unviewed [Unshaped [Bound $p $inner]]}]
        set elem never
        foreach p $positions {
            set elem [lub $elem $p]
        }
        if {[llength $positions] > $shapeLength || [lsearch -exact -not $positions $elem] < 0} {
            set shaped 0
        }
    }
    set elem [Unviewed [Unshaped [Bound $elem $inner]]]
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
    set elem [Unviewed [Unshaped [Bound $elem [expr {$depth + 1}]]]]
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
    if {[IsMutArray $type]} {
        return [MakeMutArray [lindex $type 1] $depth]
    }
    if {[IsStruct $type]} {
        return [MakeStruct [lindex $type 1] $depth]
    }
    if {[IsExactBlock $type]} {
        set result [expr {$depth >= $aggregateDepth ? "any" : [Bound [lindex $type 3] [expr {$depth + 1}]]}]
        return [lreplace $type 3 3 $result]
    }
    if {[IsFn $type]} {
        # Past the bound a structural function type becomes any -- a sound
        # over-approximation, unlike cutting one of its (contravariant)
        # argument types would be (MakeFn).
        return [MakeFn [FnArgs $type] [FnReturn $type] [FnErrors $type] $depth]
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
    if {[IsMutArray $b]} {
        # MutableArray[E] is invariant: only a MutableArray with an
        # equivalent element contract (or the raw kind when E is the whole
        # `any` domain, which promises nothing) may be viewed as it.
        if {[IsMutArray $a]} {
            return [Equivalent [lindex $a 1] [lindex $b 1]]
        }
        return [expr {$a eq "mutarray" && [lindex $b 1] eq "any"}]
    }
    if {$b eq "mutarray" && [IsMutArray $a]} {
        # A typed array viewed as the raw kind could be written with
        # anything: only the vacuous contract MutableArray[any] qualifies.
        return [expr {[lindex $a 1] eq "any"}]
    }
    if {[IsStruct $b]} {
        # An anonymous struct is compatible with another only when the field
        # sets are equal (no width subtyping, no optional fields) and every
        # field type is compatible -- fields are immutable, so covariant;
        # a MutableArray field stays invariant through its own rule above.
        if {![IsStruct $a]} {
            return 0
        }
        set fa [lindex $a 1]
        set fb [lindex $b 1]
        if {[dict keys $fa] ne [dict keys $fb]} {
            return 0
        }
        dict for {name t} $fa {
            if {![subtype $t [dict get $fb $name]]} {
                return 0
            }
        }
        return 1
    }
    if {[IsNamedStruct $b]} {
        # Nominal: only the same declaration. Identical spelling was
        # decided above ($a eq $b); a same-shaped anonymous struct or a
        # differently named struct with the same fields is never one.
        return 0
    }
    if {[IsTraitConstraint $b]} {
        # A trait constraint (TRAITS.md) is satisfied, as a type, only by a
        # view of the same trait with one witness. A concrete type that
        # satisfies the trait structurally is *accepted* at a trait-typed
        # boundary (hir::traits::Accept), never a subtype: lub must not join
        # unrelated types to a trait they happen to satisfy.
        return [expr {[IsView $a] && [ViewTrait $a] eq [lindex $b 1] && ![IsJoinWitness [ViewWitness $a]]}]
    }
    if {[IsFn $b]} {
        # A structural function type: any callable whose own call contract
        # is compatible with B's (an exact native/block through its
        # structuralOf supertype). A value merely of kind block/native, or
        # of type any, is not known to honor any particular contract.
        set s [structuralOf $a]
        return [expr {$s ne "" && [FnSubtype $s $b]}]
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
    if {[IsExactBlock $a] && [IsExactBlock $b] && [lrange $a 1 2] eq [lrange $b 1 2]} {
        # The same code target (its contract, if any, is the same too: it
        # is a property of the block expression -- blockType): keep the
        # exact identity, join what its calls return.
        return [canonical [lreplace $a 3 3 [lub [lindex $a 3] [lindex $b 3]]]]
    }
    if {[IsTrait $a] && [IsTrait $b] && [lindex $a 1] eq [lindex $b 1]} {
        # Two views of one trait keep the trait only with one witness: there
        # is no trait object to hold a choice between two (TRAITS.md, "Witness
        # joins"). Different witnesses join to a {join ...} witness, which
        # hir::traits::verify reports (TRAIT-WITNESS-JOIN) -- never any.
        if {[IsTraitConstraint $a] || [IsTraitConstraint $b]} {
            return [list trait [lindex $a 1]]
        }
        return [MakeView [lindex $a 1] [JoinWitness [ViewWitness $a] [ViewWitness $b]]]
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
    if {[IsMutArray $a] || [IsMutArray $b]} {
        # Two MutableArrays join only when they are one contract. Otherwise
        # there is no join that keeps the element contract (MutableArray[int]
        # and MutableArray[str] have no common typed supertype; the raw kind
        # would allow writes the original contract forbids): `any`, which
        # hir/callables.tcl rejects as an erasure wherever a typed array
        # would flow into it.
        if {[subtype $a $b] && [subtype $b $a]} {
            return [expr {$a eq "mutarray" || $b eq "mutarray" ? "mutarray" : [lindex [lsort [list $a $b]] 0]}]
        }
        return any
    }
    if {[IsStructLike $a] || [IsStructLike $b]} {
        # Two anonymous structs with the same field names join fieldwise
        # (STRUCTS.md: {x: lub(A,C), y: lub(B,D)}); every other pair has no
        # useful join -- different field sets (no width subtyping, no
        # optional or open fields), two different named structs, a named
        # struct and an anonymous one (nominal identity never arises from
        # shape coincidence) -- and falls back to the broad `any`.
        if {[IsStruct $a] && [IsStruct $b]} {
            set fa [lindex $a 1]
            set fb [lindex $b 1]
            if {[dict keys $fa] eq [dict keys $fb]} {
                set joined [dict create]
                dict for {name t} $fa {
                    dict set joined $name [lub $t [dict get $fb $name]]
                }
                return [MakeStruct $joined 0]
            }
        }
        return any
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
    if {[IsCallable $a] && [IsCallable $b]} {
        # Two different callables (exact or structural): their narrowest
        # common call contract -- forgetting only which code runs, never
        # that the value is a callable with that contract. No finite set
        # of targets is kept (STRUCTURAL-FUNCTION-TYPES.md's non-goal).
        set joined [FnLub [structuralOf $a] [structuralOf $b]]
        if {$joined ne ""} {
            return [canonical $joined]
        }
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
    if {[IsTrait $current]} {
        # A trait view is never strengthened by a fact about its value (a
        # kind test, a native's parameter type): its source-visible type is
        # its trait, whatever runs underneath (TRAITS.md, "One-way").
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
    if {[IsMutArray $fact]} {
        # A MutableArray[T] contract fact is a static property of the
        # object, never derivable from a kind test: an already typed value
        # keeps its contract; a raw/unknown one adopts the declared one
        # (legal callers already proved it).
        return [expr {[IsMutArray $current] ? $current : $fact}]
    }
    if {[IsFn $fact] || [IsStructLike $fact]} {
        # A structural contract fact (a function contract, a struct type): a
        # value already known to satisfy it (a narrower contract, the same
        # struct) says more.
        return [expr {[subtype $current $fact] ? $current : $fact}]
    }
    if {[IsFn $current] && $fact in {block native}} {
        # Both facts hold; the contract is the one static checking uses
        # (no single type represents "this contract, and a Block").
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
    if {$type eq "never" || [IsFn $type] || [IsTrait $type]} {
        # A structural function type's value is a Block or a native: no
        # one runtime kind.
        return ""
    }
    if {[IsStructLike $type]} {
        return struct
    }
    if {[IsSpecific $type]} {
        return [lindex $type 0]
    }
    return [core::type::base $type]
}

# The core type (core/type.tcl) a static type implies.
proc hir::types::semantic {type} {
    if {$type eq "never" || [IsFn $type] || [IsTrait $type]} {
        return any
    }
    if {[IsStructLike $type]} {
        return struct
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
            block  {
                # A block's contract (a fifth element) is not shown: it is
                # a property of block expression E itself, recovered from
                # its node (hir::read::CanonicalBlockTypes), and showing it
                # would only repeat that node's own declarations.
                return "block([lindex $type 1])/[lindex $type 2] -> [show [lindex $type 3]]"
            }
            fn {
                # The canonical structural function type notation, exactly
                # the source syntax an annotation spells.
                set fields [lindex $type 1]
                return [format {Fn{args: [%s], return: %s, errors: [%s]}} \
                    [join [lmap t [dict get $fields args] {show $t}] {, }] \
                    [show [dict get $fields return]] [join [dict get $fields errors] {, }]]
            }
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
            mutarray {
                return "MutableArray\[[show [lindex $type 1]]\]"
            }
            struct {
                # An anonymous struct type, fields in canonical order:
                # struct{age: int, name: str}. (The leading word keeps a
                # type text a Tcl-list-safe word sequence in HIR text, like
                # Fn{...}, and apart from an ImmutableSet's value display.)
                return "struct{[join [lmap {name t} [lindex $type 1] {format {%s: %s} $name [show $t]}] {, }]}"
            }
            nstruct {
                # A named struct, by its declared name.
                return [hir::structs::display [lindex $type 1]]
            }
            trait {
                # A trait constraint or view, by the trait's name only: the
                # source-visible type (a view's hidden witness is shown by
                # hir::traits::showView, never in a source-level message).
                return [lindex $type 1]
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
#   * a named function's reference to itself: the block's own exact type
#     under an assumed result (Block), so direct recursion has a known call
#     target. (There are no other references to bindings not yet bound:
#     resolution is sequential, hir/resolve.tcl -- an ordinary reference
#     always names a binding some earlier expression on this path bound.)
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
    if {![hir::semantic::Enabled]} {
        set ctx [NewContext]
        Sequence hir ctx [dict get $hir roots]
        return
    }
    # Opportunistic semantic instances (hir/semantic.tcl): the walk also
    # analyzes the ordinary body of an exact-called function under its
    # call's concrete argument types. A request for a closure whose creation
    # environment the walk has not recorded yet is declined; when a later
    # walk can serve it, the program is walked again (every walk is sound,
    # later ones more precise). That is not about definition order (a
    # reference always follows its binding, hir/resolve.tcl): it happens only
    # when a function's own recursive call (its declared result type makes
    # the call answerable at once) requests an instance whose body creates a
    # nested closure the enclosing generic walk has not reached yet
    # (hir/semantic.tcl, "Captures").
    set base $hir
    set envs {}
    for {set round 1} {$round <= [set ::hir::semantic::maxRounds]} {incr round} {
        set typed $base
        hir::semantic::Begin $envs
        set ctx [NewContext]
        Sequence typed ctx [dict get $typed roots]
        set snapshot [hir::semantic::End]
        dict set snapshot rounds $round
        if {$round == [set ::hir::semantic::maxRounds] || ![hir::semantic::WantsRerun $snapshot]} {
            break
        }
        set envs [dict get $snapshot envs]
    }
    set hir $typed
    dict set hir semantic $snapshot
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
    return [dict create types {} facts {} implies {} returnType never breakTypes {} reachable 1]
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
        never {
            # context#unreachable (core/contexts.tcl): never completes.
            return never
        }
        context-struct {
            # context#load("ID") (core/contexts.tcl, CONTEXTS.md): the
            # installed context of the context-struct declaration ID, a
            # struct of exactly that named declaration.
            set arg [lindex $argExprs [lindex $shape 1]]
            if {$arg ne "" && [hir::kind $hir $arg] eq "const"} {
                set id [lindex [hir::get $hir $arg literal] end]
                if {[hir::structs::declared $id]} {
                    return [list nstruct $id]
                }
                if {[hir::traits::declared $id] && [hir::traits::isContext $id]} {
                    # A context-trait binding (CONTEXT-TRAITS.md): source
                    # code sees the context trait's operations only; the
                    # installed context that provides them is selected
                    # statically and never becomes this binding's type.
                    return [list trait $id]
                }
            }
            return $result
        }
        named-struct {
            # A struct of one named declaration (core/native.tcl's
            # {named-struct ID}: linux::abi::syscall's abi::x86_64::
            # Register64), when the compiling program declares it; the
            # native's declared result (the bare `struct` kind) otherwise.
            set id [lindex $shape 1]
            if {[hir::structs::declared $id]} {
                return [list nstruct $id]
            }
            return $result
        }
        elements {
            return [MakeList never $argTypes 1]
        }
        element {
            lassign $shape _ l i
            # An exactly known immutable List read at an exactly known
            # index (EXACT-VALUE-FACTS.md): the selected element's own
            # static type, whatever the List's ordinary type says. This is
            # a value fact about this particular List (hir/exactvalue.tcl:
            # a literal, or an immutable alias of one), never a property of
            # Lists in general -- an arbitrary List's element stays the
            # element type below.
            set exact [hir::exact::ProjectType $hir [lindex $argExprs $l] [lindex $argExprs $i]]
            if {$exact ne ""} {
                return $exact
            }
            set list [lindex $argTypes $l]
            set elem [elementOf $list]
            if {$elem eq "" || $elem eq "never"} {
                # Nothing known, or an empty list: no element to describe.
                return $result
            }
            set positions [shapeOf $list]
            if {$positions ne ""} {
                # A positional shape (specialization only: an instance
                # entered with a List of known element types) read at an
                # exactly known index, a constant or an immutable alias of
                # one.
                set n [hir::exact::IntOf $hir [lindex $argExprs $i]]
                if {$n ne "" && $n >= 0 && $n < [llength $positions]} {
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
            # immutable_set::from_list's own -result-shape. Generic over T
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
        mutarray-element {
            # MutableArray[T] -> T (PARAMETERIZED-MUTABLEARRAY.md): reading
            # a slot of an array whose static contract is T yields a T.
            # Only an applied MutableArray carries a contract; the raw
            # kind (or an unproven `any`) keeps the native's declared
            # result. Slot contents are never exact-value facts.
            lassign $shape _ m
            set array [lindex $argTypes $m]
            if {[IsMutArray $array]} {
                return [lindex $array 1]
            }
            return $result
        }
        mutarray-freeze {
            # MutableArray[T] -> List[T]: a frozen copy of slots that all
            # satisfy T. The count affects the length only, never the
            # element type.
            lassign $shape _ m
            set array [lindex $argTypes $m]
            if {[IsMutArray $array]} {
                return [MakeList [lindex $array 1]]
            }
            return $result
        }
        element-type {
            # {element-type TYPE}: this native's result is a List whose every
            # element has type TYPE -- a fixed fact about the native itself
            # (argv's Strings, core/process.tcl), like `typed` below but for
            # a plain semantic type. MakeList takes the canonical type.
            return [MakeList [core::type::normalize [lindex $shape 1]]]
        }
        typed {
            # {typed NAME LO HI}: this native's result is a List whose
            # every element is an Int in LO..HI -- a fixed, argument-
            # independent semantic fact about the native itself (e.g.
            # str::encode_utf8's every UTF-8 code unit is definitionally in
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
            # 0..15` must not make str::encode_utf8's result List[Byte] just
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
            # AUDIT.md's str::encode_utf8/List[Byte] finding).
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
        return [ofValue $value]
    }
    if {[hir::isModuleBinding $hir $b]} {
        # A module-static reference (MODULE-STATIC-RETAINED-VALUES.md) is
        # never itself instance-varying -- unlike a genuine capture, whose
        # type can differ per creation and is therefore seeded per instance
        # into `ctx types` above, a module-static binding has exactly one
        # program-lifetime value, typed once by the ordinary semantic pass
        # (hir::types::infer), the same in every instance's own per-region
        # re-inference (hir/specialize.tcl's Reanalyze/inferRegion). Without
        # this, a module binding would silently widen to `any` here merely
        # because it is no longer captured -- exactly the kind of correctness
        # bug spec item 24 permits fixing, never a specialization-policy
        # change of its own.
        return [hir::bindingType $hir $b]
    }
    # No type is known on this path: an untyped parameter, or a local whose
    # initializer never completed (so nothing after its bind is reachable).
    # Never a binding that is merely bound later: resolution is sequential.
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
            return [dict get $node binding]
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
            if {[dict get $node binding] eq ""} {
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
            # breakTypes is seeded (and later unset) only so the shared
            # `break` case in this same switch (below) always has a
            # dict entry to lub into, exactly as a plain `loop`/countloop
            # needs -- but a listloop's own result type never reads it
            # back: RETURNING-ITERABLE-LOOPS.md redefines listloop to have
            # exactly one stable result type, List[R], for every successful
            # exit (normal exhaustion *and* a bare break, which now returns
            # the collected prefix -- still a List[R], not a separate
            # payload type). `break VALUE` inside a listloop is rejected
            # outright at hir/resolve.tcl (LISTLOOP-BREAK-VALUE), so no
            # valid program ever reaches here with a break payload type to
            # reconcile. Always contributed, even when bodyType is itself
            # never (a body that always diverges whenever it runs): the
            # loop can still complete normally with an empty result for an
            # empty iterable, exactly as a bare `[]` literal is List[never],
            # not never itself.
            dict set ctx breakTypes $e never
            set bodyType [Sequence hir ctx [dict get $node body]]
            dict unset ctx breakTypes $e
            dict set ctx facts $saved
            return [SetType hir $e [MakeList $bodyType]]
        }
        countloop {
            Expr hir ctx [dict get $node start]
            Expr hir ctx [dict get $node end]
            set saved [dict get $ctx facts]
            # Unlike listloop's element binding (typed from the iterable's
            # own, possibly-unknown element type), a countloop's induction
            # binding is always exactly Int: successfully entering any
            # iteration at all already requires an Int-domain induction
            # state (spec item 32), so this exposes that fact directly
            # rather than making a later analysis rediscover it from `i`'s
            # own uses (e.g. `i + 1`). Whether START/END are *themselves*
            # statically known Int is a separate, ordinary dynamic-Int-
            # operation question (core::value::expect at the interpreter/
            # compiler boundary, spec item 6) -- not something this static
            # type pass needs to decide or reject.
            dict set ctx facts [dict get $node countBinding] int
            # A countloop is a collecting loop exactly like a listloop
            # (COLLECTING-LOOPS.md): see that case above for why breakTypes
            # is only seeded for the shared `break` case and why the result
            # is always List[R] for the body's own type R.
            dict set ctx breakTypes $e never
            set bodyType [Sequence hir ctx [dict get $node body]]
            dict unset ctx breakTypes $e
            dict set ctx facts $saved
            return [SetType hir $e [MakeList $bodyType]]
        }
        lockloop {
            # Every domain's operands are typed in written order in the
            # enclosing scope; each domain binding is then typed like the
            # single-domain loop's own (an element's type, or exactly Int).
            # The result is the same collected List[R] as any collecting
            # loop's.
            set facts {}
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    Expr hir ctx [dict get $domain iterable]
                    set elemType [elementOf [hir::typeOf $hir [dict get $domain iterable]]]
                    lappend facts [dict get $domain binding] [expr {$elemType eq "" ? "any" : $elemType}]
                } else {
                    Expr hir ctx [dict get $domain start]
                    Expr hir ctx [dict get $domain end]
                    lappend facts [dict get $domain binding] int
                }
            }
            set saved [dict get $ctx facts]
            foreach {binding type} $facts {
                dict set ctx facts $binding $type
            }
            dict set ctx breakTypes $e never
            set bodyType [Sequence hir ctx [dict get $node body]]
            dict unset ctx breakTypes $e
            dict set ctx facts $saved
            return [SetType hir $e [MakeList $bodyType]]
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
        struct {
            return [SetType hir $e [Struct hir ctx $e]]
        }
        project {
            return [SetType hir $e [Project hir ctx $e]]
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

# Types struct construction E (STRUCTS.md). The field expressions are typed
# in WRITTEN order -- the order they evaluate in; the canonical layout never
# reorders anything -- and, like a call's arguments, an expression that never
# completes normally makes the whole construction never (no struct value is
# built). A named construction has its declared type, whatever its values are
# (the declaration is the contract; hir::range::VerifyStruct proves each value
# admissible); an anonymous one has the canonical structural type of its
# fields' own types.
proc hir::types::Struct {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set entry [dict get $ctx reachable]
    set dead 0
    set fieldTypes [dict create]
    foreach name [dict get $node names] child [dict get $node fields] {
        set type [Expr hir ctx $child]
        if {$type eq "never"} {
            set dead 1
            dict set ctx reachable 0
        }
        if {![dict exists $fieldTypes $name]} {
            dict set fieldTypes $name $type
        }
    }
    dict set ctx reachable $entry
    if {$dead} {
        return never
    }
    if {[dict get $node named]} {
        set id [dict get $node structId]
        return [expr {$id eq "" ? "any" : [list nstruct $id]}]
    }
    return [MakeStruct $fieldTypes 0]
}

# Types field projection E (STRUCTS.md): the static type of the named field
# of the receiver's struct type -- for a named struct the declared type,
# always -- never a runtime lookup. A receiver that is not (yet) a known
# struct type gives `any` here; hir::structs::verify decides whether that
# is acceptable (a projection is proven only under a known struct type, or in
# a semantic instance that knows it). A projection that can never complete
# (a receiver statically of another kind, or without that field) is `never`
# in specialization inference, like any operation that always raises.
proc hir::types::Project {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set receiver [Expr hir ctx [dict get $node receiver]]
    if {$receiver eq "never"} {
        return never
    }
    set name [dict get $node name]
    if {[hir::structs::projectionDenied $receiver $node]} {
        # No authority over an opaque receiver's representation
        # (OPAQUE-STRUCTS.md; hir::structs::ProjectionProblem rejects it): the
        # access is typed as if no such field were known, never with the
        # hidden field's declared type, so the representation cannot leak
        # through the types of the program's later diagnostics.
        return [expr {[dict exists $ctx spec] ? "never" : "any"}]
    }
    if {[IsStructLike $receiver]} {
        set t [StructField $receiver $name]
        if {$t ne ""} {
            return $t
        }
        return [expr {[dict exists $ctx spec] ? "never" : "any"}]
    }
    if {[dict exists $ctx spec] && [kindOf $receiver] ni {"" struct}} {
        return never
    }
    return any
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
#
# Facts. A handler runs instead of a normal completion of the handled call
# expression -- the call itself failed, or one of its arguments did (the
# handler catches any matching error the expression produces,
# core::forms::op-handle). So a validator's completion fact
# (REFINEMENT-VALUES.md, "Validators") established anywhere in that
# expression -- the handled call's own, or an argument's -- does not hold
# in a handler: Call logs the bindings such facts narrow (`completionLog`),
# and each handler starts from the facts after the call with those bindings
# as they were before it. After the construct, a fact holds when it holds at
# the end of every way the construct completes normally: the call's normal
# completion and each handler body that completes normally (a handler that
# returns, fails, breaks or continues contributes nothing) -- the join of
# an `if` (If), applied when a validator fact is involved; otherwise the
# construct keeps the facts after the call, as it always has.
proc hir::types::Handle {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set entry [dict get $ctx reachable]
    set before [dict get $ctx facts]
    set outerLog [expr {[dict exists $ctx completionLog] ? [dict get $ctx completionLog] : ""}]
    set hadLog [dict exists $ctx completionLog]
    dict set ctx completionLog {}
    set callType [Expr hir ctx [dict get $node call]]
    set validated [dict keys [dict get $ctx completionLog]]
    if {$hadLog} {
        dict set ctx completionLog [dict merge $outerLog [dict get $ctx completionLog]]
    } else {
        dict unset ctx completionLog
    }
    dict set ctx reachable $entry
    set completed [dict get $ctx facts]
    set handlerEntry $completed
    foreach b $validated {
        if {[dict exists $before $b]} {
            dict set handlerEntry $b [dict get $before $b]
        } else {
            dict unset handlerEntry $b
        }
    }

    set handlerTypes {}
    set ends [expr {$callType ne "never" ? [list $completed] : {}}]
    foreach body [dict get $node handlerBodies] {
        dict set ctx reachable $entry
        dict set ctx facts $handlerEntry
        set handlerType [Sequence hir ctx $body]
        lappend handlerTypes $handlerType
        if {$handlerType ne "never"} {
            lappend ends [dict get $ctx facts]
        }
    }
    dict set ctx facts $completed
    if {$validated ne {} && $ends ne {}} {
        set joined [lindex $ends 0]
        foreach end [lrange $ends 1 end] {
            set joined [hir::refine::Meet $joined $end 1]
        }
        dict set ctx facts $joined
    }
    dict set ctx reachable $entry
    # Recorded for hir/errorsets.tcl, which (after this whole inference
    # pass) rejects any live handler whose type is not admissible as
    # CALLTYPE -- item 11: no implicit union widening of a handled-result
    # binding, so CALLTYPE alone is T, never a lub of the handlers' types.
    dict set hir exprs $e handlerTypes $handlerTypes
    if {$callType ne "never"} {
        # hir/completions.tcl's admissibility check holds every live
        # handler to CALLTYPE in the generic analysis, which is what makes
        # CALLTYPE alone the construct's type there. A semantic instance can
        # type the call more precisely than its handlers, though: in
        # `fn explicit(xs, i, d): v = list::at(xs, i): on IndexNotFound: d`
        # (lib/list.bot's list::get), the generic call is `any` and `d` is
        # admissible, but the instance for (List[int], int, str) types the
        # call int while `d` is a str. Claiming int there is unsound (native
        # code compared two such results with an Int equality and crashed),
        # so a handler type that is not a subtype of CALLTYPE widens the
        # result to their join -- except between two Int-domain types,
        # whose difference is a value-range admissibility question the
        # range proofs answer, never a representation one. No program the
        # generic check accepts changes type in the generic analysis.
        set result $callType
        foreach t $handlerTypes {
            if {$t eq "never" || [subtype $t $callType]
                    || ([kindOf $t] eq "int" && [kindOf $callType] eq "int")} {
                continue
            }
            set result [lub $result $t]
        }
        return $result
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
        if {$value eq "bool"} {
            # What the Boolean value implies is a property of the value, so
            # it belongs to the immutable binding that holds it: `ok =
            # p(s)` then `if ok:` proves what `if p(s):` would
            # (REFINEMENT-VALUES.md, hir/refine.tcl's Implication).
            set implication [hir::refine::Implication $hir $ctx $valueExpr]
            if {$implication ne [hir::refine::Nothing]} {
                dict set ctx implies $b $implication
            }
        }
    }
    return $value
}

# Types block expression E; SELF is the binding it is bound to (or "").
proc hir::types::Block {hirVar outerVar e self} {
    upvar 1 $hirVar hir $outerVar outer
    set node [dict get $hir exprs $e]
    set arity [llength [dict get $node params]]
    # A named function reaches itself through its own binding, which is not
    # in the creating context yet (a bind establishes it before this block
    # is typed, but its type is this block's): exact, with an unknown result
    # here (the body's own analysis assumes one, below).
    set selfType [expr {$self eq "" ? "" : [blockType $hir $e $arity any]}]
    if {[dict exists $outer spec]} {
        # Region inference: the body is a region of its own. Report what
        # this creation captures; calls of the block ask the handler.
        set seeds [dict create]
        foreach b [dict get $node captures] {
            dict set seeds $b [expr {$b eq $self ? $selfType : [BindingType $hir $outer $b]}]
        }
        {*}[dict get $outer spec] create $e $seeds
        # The Block's own intrinsic result contract -- its declared result,
        # else what semantic inference proved for every invocation of it
        # (a sound upper bound for every instance: the semantic body was
        # typed under the creation's source-level facts, which every
        # instance's are narrower than) -- not "any": calls of an exact
        # block ask the handler for their instance result regardless, so
        # this only matters where the exact type is *joined* (FnLub's
        # return) or called through a structural view, which is exactly
        # where "any" used to lose a known bool
        # (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md, "Result-type
        # precision").
        set result any
        if {[dict exists $node resultType] && [dict get $node resultType] ne ""} {
            set result [hir::type $hir [dict get $node resultType]]
        }
        return [blockType $hir $e $arity $result]
    }
    hir::semantic::RecordEnv $hir $outer $e $self $selfType
    set declared [dict get $node declaredResult]
    # A declared trait result is a view whose witness the body decides
    # (hir::traits::ViewResult), so it is inferred like an undeclared one.
    set assumed [expr {$declared eq {} || [IsTraitConstraint $declared] ? {never} : $declared}]
    set attempts [expr {$self eq "" ? 1 : 3}]
    for {set attempt 1} {$attempt <= $attempts} {incr attempt} {
        if {$attempt == $attempts && $attempts > 1} {
            set assumed any
        }
        set ctx [NewContext]
        dict set ctx types [dict get $outer types]
        dict set ctx facts [dict get $outer facts]
        dict set ctx implies [dict get $outer implies]
        if {[dict exists $outer inst]} {
            dict set ctx inst [dict get $outer inst]
        }
        if {$self ne ""} {
            dict set ctx types $self [blockType $hir $e $arity $assumed]
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
        #
        # The same holds for a *trusted inferred* contract
        # (hir::signatures::entryTypes, INTRINSIC-FUNCTION-CONTRACT-
        # INFERENCE.md): every call is held to it exactly like a
        # declaration, so the body may assume it the same way.
        set index 0
        foreach b [dict get $node params] declaredType [hir::signatures::entryTypes $hir $e] {
            if {$declaredType ne {}} {
                if {[IsTraitConstraint $declaredType]} {
                    # A trait-typed parameter (TRAITS.md): the body sees a
                    # view of the trait whose witness is this parameter's
                    # own, unknown and independent of every other's.
                    set declaredType [hir::traits::AbstractView $declaredType $e $index]
                }
                dict set ctx types $b $declaredType
            }
            incr index
        }
        set body [Sequence hir ctx [dict get $node body]]
        set result [lub $body [dict get $ctx returnType]]
        if {$self eq "" || $result eq $assumed || $assumed eq "any"} {
            break
        }
        set assumed $result
    }
    dict set hir exprs $e inferredResultType [intern hir $result]
    if {$declared ne {}} { set result [hir::traits::ViewResult $declared $result] }
    dict set hir exprs $e resultType [intern hir $result]
    return [blockType $hir $e $arity $result]
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
    if {!$spec} {
        # A method-syntax call whose receiver is a trait view is an operation
        # of the trait (TRAITS.md): typed from the requirement, never from
        # whatever function of that name the code can see.
        set traitCall [hir::traits::TypeCall hir $e $node]
        if {$traitCall ne ""} {
            lassign $traitCall result calleeErrors
            dict set hir exprs $e target ""
            dict set hir exprs $e known ""
            dict set hir exprs $e calleeErrors $calleeErrors
            return [expr {$dead ? "never" : $result}]
        }
    }
    if {[lindex $calleeType 0] eq "native" && [llength $calleeType] == 2} {
        set name [lindex $calleeType 1]
        set target [list native [hir::resolve::nativeSymbol hir $name]]
        set meta [core::native::metadata $name]
        set arity [dict get $meta arity]
        if {$arity eq "*" || $arity == [llength $argExprs]} {
            set result [dict get $meta resultType]
            if {[dict get $meta testsType] ne ""} {
                set known [hir::refine::decideTypeTest $name [lindex $argTypes 0]]
            } elseif {$name in {== < <= > >=} && [llength $argExprs] == 2 && !$dead} {
                # Two exactly known operands decide the comparison:
                # Botlish == is structural value equality, never identity
                # (EXACT-VALUE-FACTS.md, hir/exactvalue.tcl).
                set known [hir::exact::DecideCompare $name $hir [lindex $argExprs 0] [lindex $argExprs 1]]
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
                # (list/list::at/list::append, core/lists.tcl,
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
    } elseif {[IsExactBlock $calleeType]} {
        lassign $calleeType _ block arity blockResult
        set target [list block $block]
        if {$known eq "" && !$dead && [hir::refine::IsPredicate $hir $block]} {
            # An exact predicate-result fact (REFINEMENT-VALUES.md): this
            # very invocation -- the same proof-producing function on the
            # same argument values -- already returned a known result on
            # every path reaching here, and the function is repeatable
            # (hir/repeatable.tcl), so the call is decided. A refinement
            # fact about the argument alone never decides it: another
            # function proving the same refinement need not return true.
            # A validator (`-> unit proves`) has no exact result to record
            # and is never decided: removing a repeated validator call
            # would also remove the failure it may raise.
            set key [hir::refine::CallKey $hir $block $argExprs]
            if {$key ne "" && [dict exists $ctx facts $key] && [hir::repeatable::Block $hir $block]} {
                set known [dict get $ctx facts $key]
            }
        }
        if {$arity == [llength $argExprs]} {
            # A view the callee returns of one of its own trait parameters is
            # the caller's argument's view (TRAITS.md, "Provenance").
            set blockResult [hir::traits::SubstituteResult $blockResult $block $argTypes]
            set result $blockResult
            if {$spec && !$dead && [dict get $ctx reachable]} {
                set result [{*}[dict get $ctx spec] call $e $block $argTypes]
            }
            if {!$dead} {
                # An intrinsic container rule of the resolved callee
                # (hir/containers.tcl): the mutarray library's from_list and create
                # relate their result to their argument types, which the
                # non-generic function type cannot say.
                set rule [hir::containers::RuleOf $hir $block]
                if {$rule ne ""} {
                    set result [hir::containers::CallResult $rule $argTypes $result]
                } elseif {!$spec && ([dict get $ctx reachable] || [hir::traits::IsPolymorphic $hir $block])} {
                    # (A call of a trait-polymorphic function always gets its
                    # instance, reachable or not: its witnesses decide which
                    # specialization the call is, TRAITS.md.)
                    # An opportunistic semantic instance of the callee
                    # (hir/semantic.tcl): its ordinary body analyzed under
                    # this call's concrete argument types. The call is
                    # typed with what that analysis proves; the callee's own
                    # contract and generic result are untouched.
                    set result [hir::semantic::Call $hir $ctx $e $block $argTypes $result]
                }
            }
        } elseif {$spec} {
            set dead 1
        }
    } elseif {[IsFn $calleeType]} {
        # A call through a structural function type (STRUCTURAL-FUNCTION-
        # TYPES.md): statically known to be callable, target unknown -- no
        # `target` (lowering stays the indirect callvalue path, and no
        # instance is chosen), but the call is typed from the contract:
        # what it returns here, and (calleeErrors below) which declared
        # errors it may let escape. Its arguments are held to the
        # contract's argument types by hir::range::verifyDeclaredParams,
        # exactly as a direct call's are held to its target's parameters.
        if {[llength [FnArgs $calleeType]] == [llength $argExprs]} {
            set result [FnReturn $calleeType]
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
    # callee (target {block ExprId}, or a root native whose registry entry
    # declares -errors: `argv`) or a structural one (its contract's declared
    # errors) can ever be charged with a nonempty set here, and any other
    # callee (an unresolved
    # dynamic dispatch through any/a bare kind) is sound to treat as
    # producing none, because hir/callables.tcl's escape audit (widened to
    # cover an error-bearing block exactly like a typed-parameter-bearing
    # one) already rejects every position that would let an error-bearing
    # callable reach such a call erased of both its exact identity and its
    # structural contract -- so a callee that reaches here with neither can
    # never actually be one.
    set calleeErrors {}
    if {[lindex $target 0] eq "block"} {
        set calleeErrors [dict get $hir exprs [lindex $target 1] declaredErrors]
    } elseif {[lindex $target 0] eq "native"} {
        # A root native declares errors only through its registry entry
        # (-errors: `argv`'s InvalidArgumentEncoding).
        set calleeErrors [dict get [core::native::metadata [dict get [hir::symbol $hir [lindex $target 1]] name]] errors]
    } elseif {[IsFn $calleeType]} {
        # A structural callee's declared error contract: every error it
        # permits may escape this call, since which implementation runs
        # (and so any narrower proof about it) is unknown here.
        set calleeErrors [FnErrors $calleeType]
    }
    dict set hir exprs $e calleeErrors $calleeErrors
    if {!$dead && [lindex $target 0] eq "block"} {
        # A validator's proof (REFINEMENT-VALUES.md, "Validators"): once
        # this call completes normally, its argument satisfies the
        # contract's refinement -- a flow fact about the rest of the path,
        # like a native's parameter types above, scoped and joined like
        # every other fact. Inside a handled call, the bindings it narrows
        # are logged for Handle: a handler may run instead of this
        # completion, and must not see its proof.
        foreach {b fact} [hir::refine::CompletionFacts $hir $e] {
            Narrow $hir ctx $b $fact
            if {[dict exists $ctx completionLog]} {
                dict set ctx completionLog $b 1
            }
        }
    }
    return [expr {$dead ? "never" : $result}]
}

# The Boolean (1/0) CONDITION is statically known to evaluate to, or "":
# a decided call, or a reference to a Boolean root binding (a constant).
proc hir::types::KnownOutcome {hir condition} {
    set node [dict get $hir exprs $condition]
    switch -- [dict get $node kind] {
        call {
            if {[dict get $node known] ne ""} {
                return [dict get $node known]
            }
            # E.g. a Boolean element read out of a known List
            # (EXACT-VALUE-FACTS.md).
            set fact [hir::exact::Of $hir $condition]
            if {[lindex $fact 0] eq "val" && [core::value::kind [lindex $fact 1]] eq "bool"} {
                return [core::value::isTrue [lindex $fact 1]]
            }
            return ""
        }
        ref {
            set b [dict get $node binding]
            if {$b ne "" && [dict get $hir bindings $b kind] eq "root"
                    && [core::value::kind [dict get $hir bindings $b value]] eq "bool"} {
                return [core::value::isTrue [dict get $hir bindings $b value]]
            }
            # An immutable alias of an exactly known Boolean (`ok = 3 < 4`,
            # `if ok:`): the same decided outcome its value has
            # (EXACT-VALUE-FACTS.md).
            set fact [hir::exact::Of $hir $condition]
            if {[lindex $fact 0] eq "val" && [core::value::kind [lindex $fact 1]] eq "bool"} {
                return [core::value::isTrue [lindex $fact 1]]
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
    set implication [hir::refine::Nothing]
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
        set implication [hir::refine::Implication $hir $ctx $condition]
        set refinements [hir::refine::branchFacts $hir $condition $ctx]
    }
    dict set hir exprs $e refinements $refinements

    set branchTypes [dict create]
    set saved [dict get $ctx facts]
    set ends {}
    foreach {outcome role} {1 then 0 else} {
        set reachable [expr {$live && ($known eq "" || $known == $outcome)}]
        dict set ctx reachable $reachable
        dict set hir scopes [dict get $node ${role}Scope] refinements [dict get $refinements $outcome]
        foreach {b fact} [dict get $refinements $outcome] {
            Narrow $hir ctx $b $fact
        }
        if {$test ne "never" && [dict get $implication $outcome] ne "never"} {
            # The exact predicate results this outcome establishes
            # (hir/refine.tcl's call keys), for Call's decided repeats.
            dict for {key value} [dict get $implication $outcome] {
                if {[hir::refine::IsCallKey $key]} {
                    dict set ctx facts $key $value
                }
            }
        }
        dict set branchTypes $outcome [Sequence hir ctx [dict get $node ${role}Body]]
        if {$reachable && [dict get $branchTypes $outcome] ne "never"} {
            lappend ends [dict get $ctx facts]
        }
        dict set ctx facts $saved
        dict set ctx reachable $entry
    }
    if {$ends ne {}} {
        # The join (REFINEMENT-VALUES.md): a fact survives the if exactly
        # when it holds at the end of every branch that completes normally
        # -- a branch that returns, fails or breaks contributes nothing,
        # like a never-completing branch contributes nothing to the if's
        # value type. Facts about one binding join by lub; an exact
        # predicate result survives when every such branch agrees.
        set joined [lindex $ends 0]
        foreach end [lrange $ends 1 end] {
            set joined [hir::refine::Meet $joined $end 1]
        }
        dict set ctx facts $joined
    }
    if {$test eq "never"} {
        return never
    }
    if {$known ne ""} {
        return [dict get $branchTypes $known]
    }
    return [lub [dict get $branchTypes 1] [dict get $branchTypes 0]]
}
