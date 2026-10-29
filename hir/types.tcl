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
#   {nstruct ID {A1 ... An}}        an *application* of the parameterized
#                                   struct ID (TRAIT-CONSTRAINED-IMPRINTED-
#                                   TYPES.md): a value of ID whose type slots
#                                   are A1..An, in declared slot order, each
#                                   a canonical type (an imprint variable in
#                                   an imprinted signature). Its field types
#                                   are the declaration's with every slot
#                                   replaced by its argument
#                                   (hir::structs::AppliedFieldType). The
#                                   identity is the constructor's and the
#                                   arguments', never a witness: two
#                                   applications are one type iff their
#                                   arguments are (invariant in every slot);
#                                   their runtime representation is the
#                                   constructor's alone (StructShape).
#   {enum ID}                       an *enum* (ENUMS.md): a value that is one
#                                   case of the enum declared as ID
#                                   (hir/enums.tcl). Nominal: the identity is
#                                   the declaration, never the case list; a
#                                   case expression has exactly this type
#                                   (no per-case subtype). Closed: the
#                                   declaration's case set is complete
#                                   (hir::enums::cases). Never a subtype of
#                                   Int or str, nor of another enum.
#   enum                            the broad kind of every enum case value
#                                   (the runtime kind's own name). Not
#                                   source-spellable (an anonymous enum).
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
#   {mutvec ELEM}                   a MutableVector[ELEM] (MUTABLE-VECTOR.md):
#                                   a growable mutable VALUE whose every
#                                   element has static type ELEM. Logical
#                                   copies are independent (copy-on-write);
#                                   its affinity is ELEM's (Affinity). Like
#                                   List: covariant as a subtype, admissible
#                                   at a declared boundary only with the
#                                   same element type or as the proven-empty
#                                   MutableVector[never] (range.tcl's
#                                   AggregateAdmits). The bare atom `mutvec`
#                                   is the runtime kind (MutableVector[any]).
#   {coroutine {args {M} return R errors {E1 ...}}}
#                                   a coroutine handle (COROUTINES.md,
#                                   AFFINE-VALUES.md): the affine, resumable
#                                   computation one `coroutine {...} = CALL`
#                                   construction started, described by the
#                                   same *callable contract* a structural Fn
#                                   has -- `args` the messages one call
#                                   (resume) takes: none (the zero-message
#                                   protocol) or one named struct type;
#                                   `return` the static type of every value
#                                   a segment ends with (a yield's or the
#                                   final return's); `errors` the sorted
#                                   declared errors a segment may end with.
#                                   Source-spellable as Coroutine{args: [M],
#                                   return: R, errors: [E]}, and printed so.
#                                   Its callable *kind* differs from Fn's
#                                   (calling resumes one evolving execution),
#                                   so neither is a subtype of the other.
#                                   Affine (Affinity, below): ordinary
#                                   operations never duplicate one.
#   {cptr POINTEE}                  a C data pointer std::ffi::c::Ptr[T] (C-ABI-
#                                   TYPES.md, hir/cabi.tcl): a raw C address
#                                   whose static pointee identity is
#                                   POINTEE -- `void` (std::ffi::c::Void), a C
#                                   integer scalar, an opaque struct
#                                   {nstruct ID}, another pointer, or an
#                                   imprint variable. Invariant: Ptr[A] is a
#                                   Ptr[B] only when A is B (erase/retype
#                                   are the explicit bridges). Not an Int.
#                                   Affine (an AffineRoot that drops
#                                   nothing): moved, cloned explicitly.
#   {cfnptr FN}                     a C function pointer std::ffi::c::FnPtr[F]:
#                                   FN the canonical {fn {args .. return ..
#                                   errors {}}} signature, every argument
#                                   and the result C ABI types. Of the same
#                                   runtime kind as a data pointer (cptr),
#                                   never a subtype of one, nor of Fn: no
#                                   Botlish call reaches it. Affine like a
#                                   data pointer.
#   cptr                            the runtime kind of both (a pointer of
#                                   unknown pointee, e.g. the join of two
#                                   different pointer types); affine
#   {cfloat NAME}                   a C floating type, std::ffi::c::Float or
#                                   std::ffi::c::Double (hir/cabi.tcl, C-FLOAT-
#                                   FFI-MILESTONE-1.md): a C representation
#                                   named where a C type is (a C signature,
#                                   a pointee, a layout field), never the
#                                   type of a Botlish value: the values that
#                                   cross the boundary are its carrier's,
#                                   Float64 (hir::cabi::Carrier)
#   {nview L}                       a read-only native view NativeView[L]
#                                   (NATIVE-LAYOUT-VIEWS.md): live native
#                                   memory read through layout L, whose
#                                   value is the address word of the
#                                   pointer it was made from (runtime kind
#                                   cptr). Nominal (NativeView[A] is a
#                                   NativeView[B] only when A is B), never a
#                                   pointer (no pointer operation takes
#                                   one), never a LayoutStruct; its fields
#                                   are read by projection
#                                   (hir::layouts::ViewFieldType).
#                                   Unrestricted: a non-owning window that
#                                   confers nothing its copy does not; like
#                                   a callable it has no equality
#   {nedit L}                       a native edit NativeEdit[L]
#                                   (NATIVE-LAYOUT-WRITES.md): live native
#                                   memory read AND written through layout
#                                   L, the address word of the pointer it
#                                   was made from (runtime kind cptr). Its
#                                   reads are a view's (a nested layout's
#                                   a NativeEdit[INNER]); std::binary::store
#                                   writes through it. Nominal and distinct
#                                   from NativeView[L] in both directions
#                                   (write authority is never implied by
#                                   read authority, nor made from it), never
#                                   a pointer. Unrestricted like a view: a
#                                   non-owning capability whose copies prove
#                                   nothing about other aliases of the
#                                   memory; no equality
#   {srefined FAMILY FACTS}         a scalar refinement (hir/refinements.tcl,
#                                   DECIMAL-ROUNDED-MILESTONE-1.md): the
#                                   values of FAMILY's base type of which
#                                   the compiler knows the integer facts
#                                   FACTS (canonical: present parameters in
#                                   schema order), e.g. {srefined
#                                   DecimalRounded {minDecimalsPreserved 2}},
#                                   source-spelled DecimalRounded{
#                                   minDecimalsPreserved: 2}. A subtype of
#                                   another member when its facts imply the
#                                   other's (weakening), and of its family's
#                                   base (forgetting every fact); nothing
#                                   else is a subtype of it: a fact is only
#                                   ever established by a proof
#                                   (hir/decimal.tcl). Its runtime kind is
#                                   the base's; the facts are static only.
#   {srefined FAMILY FACTS BASE}    a scalar refinement of an applied type
#                                   (LIST-CARDINALITY-REFINEMENTS.md): the
#                                   values of BASE (a List form, {list
#                                   ELEM} or the bare `list`) of which the
#                                   compiler knows FACTS, e.g. {srefined
#                                   List {length 4} {list int}}, source-
#                                   spelled List[int]{length: 4}: an
#                                   ordinary List of exactly four elements.
#                                   A subtype of B' when its facts imply
#                                   B''s and BASE is a subtype of B''s base
#                                   (List[A]{length: 4} <: List[B]{length:
#                                   4} for A <: B), and of BASE itself
#                                   (forgetting the facts); a type that
#                                   states the same facts by its own form
#                                   ({list never}, only ever empty: length
#                                   0) is one too. Built only by Refine,
#                                   which keeps the form canonical.
#   {imprint T}                     an imprint variable (hir/imprint.tcl):
#                                   in a function's declared signature, the
#                                   type a call imprints as T. Rigid in the
#                                   body (only T itself, never, and any
#                                   relate to it); substituted at every
#                                   call. Unrestricted.
#   {imprint T {TRAIT ...}}         a *constrained* imprint variable
#                                   (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md):
#                                   T itself -- not a trait view, not the
#                                   trait -- plus the facts "T satisfies
#                                   TRAIT" its function's contract entails,
#                                   because T is the argument of a slot
#                                   constrained by TRAIT in an application
#                                   of its signature (hir::imprint::
#                                   Constrain). The traits are sorted and
#                                   derived, never declared on a function:
#                                   every occurrence of T in one signature
#                                   carries the same ones, so T stays rigid.
#                                   Inside a parameterized struct's own
#                                   declaration, a slot reference is this
#                                   form too, with its declared trait.
#
# The list and immutableSet forms are *aggregate facts*. Semantic inference
# (infer) never produces a *shaped* (positional) one: a program's HIR types
# stay what they were. Only specialization inference (inferRegion, used by
# hir/specialize.tcl) tracks a List's positional shape. Both forms are
# bounded (see MakeList/MakeSet), so analyses over them terminate.
#
# Exact value facts (EXACT-VALUE-FACTS.md, hir/exactvalue.tcl) are a
# separate, ephemeral channel and never a type: `std::list::at` of a List the
# compiler knows exactly (a literal, an immutable alias of one, std::list::append
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
    # The depth past which an application of a parameterized struct keeps
    # its constructor but no longer its arguments (MakeApplied,
    # TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): deeper than the aggregate bound,
    # so a declared type of practical depth is never cut, and finite, so
    # inference over applications terminates.
    variable appliedDepth 6
    # Registered *type constructors* (MINIMAL-APPLIED-LIST-TYPES.md): NAME
    # -> arity. A source type annotation "NAME[ARG]" (surface::parser::
    # TypeExpr) is resolved generically against this table (resolveNamed/
    # resolveApplication below), not by special-casing a constructor's name
    # in the parser or in hir::resolve.tcl. ImmutableSet (MINIMAL-IMMUTABLE-
    # SET.md) is this registry's second entry, added with no grammar or
    # resolution-mechanism change -- confirming the List[T] milestone's own
    # claim that a future unary container needs only another entry here
    # (plus a case in resolveApplication/MakeSet below), never new syntax.
    # LayoutStruct (BINARY-LAYOUT.md) is registered for its name and arity
    # (an unapplied `LayoutStruct` is the arity error, no declaration may be
    # named so); its one argument is a layout, not a type, so
    # hir::resolve::ResolveTypeExpr resolves it (hir::layouts::
    # ResolveLayoutStruct) before any argument is resolved as a type.
    #
    # std::ffi::c::Ptr and std::ffi::c::FnPtr (C-ABI-TYPES.md) are registered for their
    # names and arity the same way: their argument is a pointee or a C
    # signature, resolved by hir::cabi (hir::resolve::ResolveTypeExpr).
    #
    # NativeView (NATIVE-LAYOUT-VIEWS.md) likewise: its argument is a layout
    # (hir::layouts::ResolveNativeView).
    variable constructors [dict create List 1 ImmutableSet 1 MutableArray 1 MutableVector 1 LayoutStruct 1 \
        NativeView 1 NativeEdit 1 std::ffi::c::Ptr 1 std::ffi::c::FnPtr 1]
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
    if {[hir::refinements::isFamily $name]} {
        # A scalar-refinement family (DECIMAL-ROUNDED-MILESTONE-1.md): its
        # parameters are part of every type of it, so its bare name is no
        # annotation (DecimalRounded{minDecimalsPreserved: N} is).
        return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} [hir::refinements::BareMessage $name]
    }
    # A declared struct (hir/structs.tcl): `Person` in the code's own
    # namespace NS, or a module-qualified `geo::Point`. The struct
    # declarations are a type namespace of their own, consulted before
    # core::type's registry (and never colliding with it: apply rejects a
    # struct named like any registered type).
    set id [hir::structs::lookup $name $ns]
    if {$id ne ""} {
        if {[hir::structs::isParameterized $id]} {
            # A parameterized struct (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md)
            # is a type constructor: only an application of it is a type.
            error "struct \"$name\" takes [llength [hir::structs::slots $id]] type argument(s): it is a type constructor, and only an application of it, $name\[[join [hir::structs::slots $id] {, }]\] with a type for each slot, is a type"
        }
        return [list nstruct $id]
    }
    # An enum (ENUMS.md): the same type namespace and visibility rules,
    # `import type` included.
    set id [hir::enums::lookup $name $ns]
    if {$id ne ""} {
        return [list enum $id]
    }
    if {$name eq [hir::cabi::BoolName]} {
        # C _Bool (hir/cabi.tcl, C-BINDGEN.md): Botlish's bool, under its C
        # ABI name.
        return bool
    }
    if {$name eq [hir::cabi::DoubleName]} {
        # C double where a type of Botlish values is written: its values'
        # type, Float64 (FLOAT64-MILESTONE-1.md). Where a C type is named it
        # is the C representation {cfloat Double} instead (hir::cabi::
        # ResolveCType, C-FLOAT-FFI-MILESTONE-1.md).
        return Float64
    }
    if {$name eq [hir::cabi::FloatName]} {
        # C float names a C type only: no Botlish value is a binary32.
        return -code error -errorcode {BOTLISH TYPE} [hir::cabi::FloatMessage]
    }
    if {$name eq [hir::cabi::VoidName]} {
        # The C void (C-ABI-TYPES.md): a pointee identity, never the type of
        # a value.
        return -code error -errorcode {BOTLISH TYPE} [hir::cabi::VoidMessage]
    }
    if {$name eq "cptr"} {
        return -code error -errorcode {BOTLISH TYPE} \
            "\"cptr\" is not a type: a C pointer always has a pointee identity (std::ffi::c::Ptr\[std::ffi::c::Void\] is C's void *)"
    }
    if {$name eq "enum"} {
        # The broad kind of every enum value would be an anonymous enum
        # type: an enum's identity is its declaration, so only a declared
        # enum's name is an enum type.
        error "\"enum\" is not a type: there are no anonymous enum types (an enum is a named declaration, `enum Name:`; write its name)"
    }
    # A trait (TRAITS.md): the same type namespace and visibility rules as a
    # struct or a source-defined type, `import type` included. A bare
    # annotation names the constraint; only a parameter or result position
    # accepts one (every other position rejects it: MentionsTrait).
    set trait [hir::traits::lookup $name $ns]
    if {$trait ne ""} {
        return [list trait $trait]
    }
    # A layout (BINARY-LAYOUT.md) is not a type: its values are
    # LayoutStruct[L]'s.
    set layout [hir::layouts::lookup $name $ns]
    if {$layout ne ""} {
        return -code error -errorcode {BOTLISH LAYOUT-NOT-A-TYPE} \
            "\"$name\" is a layout, not a type: a layout describes bytes, and the values imprinted with it have the type LayoutStruct\[$name\]"
    }
    # A source-defined `type`: spelled bare it is the code's own namespace's
    # (declared there) or the one a `import type` of its file binds to that
    # short name; spelled qualified it is exactly that member. Either way the
    # type is the one canonical `NS::Name` identity -- no alias exists.
    set canonical [CanonicalTypeName $name $ns]
    if {[string first :: $canonical] >= 0 && ![core::type::isSource $canonical]} {
        error "unknown type \"$name\": no source-defined type or struct of that name is declared in that namespace"
    }
    if {$ns ne "" && [string first :: $canonical] < 0 && [core::type::isSource $canonical]} {
        # The entry program's own type (the only source types with a bare
        # identity): not visible from a module. A qualified spelling is a
        # module's member, authorized by its file's imports
        # (surface/modules.tcl), never the program's.
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
    if {$imported ne ""} {
        return $imported
    }
    return $name
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
        if {$ctor eq "ImmutableSet" && [IsAffine $t]} {
            # An ImmutableSet compares and hashes its members, which an
            # affine value does not support (AFFINE-EQUALITY-UNSUPPORTED):
            # it cannot own one. A List, a MutableVector and a MutableArray
            # can (their affinity is their element's: MUTABLE-ARRAY.md).
            return -code error -errorcode {BOTLISH AFFINE-CONTAINER-UNSUPPORTED} \
                "$ctor\[[show $t]\] would hold affine values: an ImmutableSet compares and hashes its members, so it cannot own them (a List, MutableVector or MutableArray of them can)"
        }
        if {$ctor eq "ImmutableSet" && [hir::decimal::Mentions $t]} {
            # A set hashes and compares its members by value, which knows
            # no precision: a DecimalRounded member's hash would read
            # digits its type does not guarantee (hir/decimal.tcl,
            # "Observations"; core::hashing refuses one at run time).
            return -code error -errorcode {BOTLISH TYPE} \
                "$ctor\[[show $t]\] would hash DecimalRounded values: a set compares and hashes its members by value, which knows no precision, so it cannot hold them (a List can; decay the members with std::float64::from_decimal_rounded to build a set of Float64)"
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
        std::ffi::c::Ptr - std::ffi::c::FnPtr {
            # Only from a pointee or a signature (hir::cabi::ResolvePtr,
            # ResolveFnPtr), never from a resolved argument type.
            error "internal compiler error: $ctor is resolved by hir::cabi"
        }
        LayoutStruct - NativeView - NativeEdit {
            # Only from a resolved argument type (never a layout): see
            # hir::layouts::ResolveLayoutStruct and ResolveNativeView.
            return -code error -errorcode {BOTLISH LAYOUT-STRUCT-PARAMETER} \
                "$ctor\[[show [lindex $argTypes 0]]\]: the argument of $ctor must name a layout declaration, not a type"
        }
        List { return [MakeList [lindex $argTypes 0] {} 0 0] }
        ImmutableSet { return [MakeSet [lindex $argTypes 0] 0] }
        MutableArray { return [MakeMutArray [lindex $argTypes 0] 0] }
        MutableVector { return [MakeMutVec [lindex $argTypes 0] 0] }
    }
}

proc hir::types::IsSpecific {type} {
    return [expr {$type eq "never"
                  || ([llength $type] > 1 && [lindex $type 0] in {native block list immutableSet mutarray mutvec fn struct nstruct enum trait coroutine cptr cfnptr cfloat imprint nview nedit srefined})}]
}

# C ABI pointer forms (C-ABI-TYPES.md; the header's {cptr ...}/{cfnptr ...}).
proc hir::types::IsCPtr {type} {
    return [expr {[llength $type] == 2 && [lindex $type 0] eq "cptr"}]
}
proc hir::types::IsCFnPtr {type} {
    return [expr {[llength $type] == 2 && [lindex $type 0] eq "cfnptr"}]
}
# 1 for any raw C address type: a data or function pointer, or the bare kind.
proc hir::types::IsCAddress {type} {
    return [expr {$type eq "cptr" || [IsCPtr $type] || [IsCFnPtr $type]}]
}
# A native view NativeView[L] (NATIVE-LAYOUT-VIEWS.md; the header's
# {nview L}).
proc hir::types::IsNativeView {type} {
    return [expr {[llength $type] == 2 && [lindex $type 0] eq "nview"}]
}
# A native edit NativeEdit[L] (NATIVE-LAYOUT-WRITES.md; the header's
# {nedit L}).
proc hir::types::IsNativeEdit {type} {
    return [expr {[llength $type] == 2 && [lindex $type 0] eq "nedit"}]
}
# Native memory read through a layout: a NativeView[L] or a NativeEdit[L],
# whose reads are the same.
proc hir::types::IsNativeMemory {type} {
    return [expr {[IsNativeView $type] || [IsNativeEdit $type]}]
}
# An imprint variable (hir/imprint.tcl).
proc hir::types::IsImprint {type} {
    return [expr {[llength $type] in {2 3} && [lindex $type 0] eq "imprint"}]
}

# The traits the (constrained) imprint variable TYPE is known to satisfy
# (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): its sorted trait identities, ""
# for an unconstrained one.
proc hir::types::ImprintConstraints {type} {
    return [lindex $type 2]
}

# The imprint variable NAME constrained by TRAITS (any order, duplicates
# allowed): {imprint NAME} when there are none.
proc hir::types::MakeImprint {name traits} {
    set traits [lsort -unique $traits]
    if {$traits eq {}} {
        return [list imprint $name]
    }
    return [list imprint $name $traits]
}

# ---------------------------------------------------------------------------
# Coroutine handles (COROUTINES.md; the header's {coroutine ...} form)

proc hir::types::IsCoroutine {type} {
    return [expr {[lindex $type 0] eq "coroutine" && [llength $type] == 2}]
}

# The canonical coroutine handle type with the callable contract ARGTYPES
# (the resume messages: {} or one named struct type), RESULT (what each
# resume returns) and ERRORS (canonicalized here), nested DEPTH aggregate
# forms deep. The parallel of MakeFn: the same three named fields in the same
# canonical order, so that one contract text means the same thing for both
# callable kinds. Unlike a Fn, a coroutine type is never cut by the aggregate
# bound (an affine value must never be erased to an unrestricted one); only
# its result is bounded, like a Fn's.
proc hir::types::MakeCoroutineType {argTypes result errors {depth 0}} {
    set argTypes [lmap a $argTypes {canonical $a}]
    set result [Bound [canonical $result] [expr {$depth + 1}]]
    return [list coroutine [dict create args $argTypes return $result errors [lsort -unique $errors]]]
}

# The handle type of a coroutine resumed with RESUME (unit: no message; a
# named struct type: one message of it; any: a protocol conflict, already
# diagnosed, whose resumes are not checked again), whose segments end with
# values of OUTWARD or one of ERRORS.
proc hir::types::MakeCoroutine {resume outward errors} {
    return [MakeCoroutineType [if {$resume eq "unit"} {string cat {}} else {list $resume}] $outward $errors]
}

# The resume protocol of coroutine type TYPE: unit, a named struct type, or
# any (MakeCoroutine).
proc hir::types::CoroutineResume {type} {
    set args [dict get [lindex $type 1] args]
    if {[llength $args] == 0} {
        return "unit"
    }
    return [lindex $args 0]
}
proc hir::types::CoroutineOutward {type} { return [dict get [lindex $type 1] return] }
proc hir::types::CoroutineErrors {type}  { return [dict get [lindex $type 1] errors] }

# ---------------------------------------------------------------------------
# Callable contracts and kinds (AFFINE-VALUES.md)
#
# A *callable contract* is what calling a value is allowed to do: {args {T1
# ...} return R errors {E1 ...}}. Every callable type has one: a structural
# Fn and a coroutine handle carry theirs as their second element (one
# representation, compared field by field by the same FnMismatch rules), an
# exact native or block has its structuralOf contract. The *callable kind*
# is what a call means -- independent of the contract:
#
#   exact      an exact native or block: a direct call of known code
#   fn         a structural function value: an ordinary indirect call
#   coroutine  a coroutine handle: a resume of its one evolving execution
#
# Call checking (arity, argument admissibility, result typing, declared-
# error charging) reads the contract only; lowering dispatches by the kind.

# The callable kind of TYPE (exact, fn, coroutine), or "" if it is not
# statically known to be callable.
proc hir::types::CallableKind {type} {
    if {[IsCoroutine $type]} {
        return coroutine
    }
    if {[IsFn $type]} {
        return fn
    }
    if {[IsExactBlock $type] || [IsExactNative $type]} {
        return exact
    }
    return ""
}

# The callable contract dict of TYPE, or "" (not callable, or a native of
# variable arity).
proc hir::types::Contract {type} {
    if {[IsCoroutine $type] || [IsFn $type]} {
        return [lindex $type 1]
    }
    set s [structuralOf $type]
    if {$s eq ""} {
        return ""
    }
    return [lindex $s 1]
}

# ---------------------------------------------------------------------------
# Affinity (AFFINE-VALUES.md)
#
# Affinity is a property of a value's type, orthogonal to callability:
#
#   unrestricted  ordinary operations may duplicate or alias the value
#   affine        ordinary operations preserve at most one usable owner:
#                 binding, passing, returning, storing in an aggregate or a
#                 container *move* it, never copy it
#
# It is compositional: a value that owns an affine value is affine. The one
# primitive affine root today is the coroutine handle; a struct (named or
# anonymous) is affine iff a field type is, a List, a MutableVector and a
# MutableArray (and, for completeness, an ImmutableSet, which rejects affine
# members elsewhere) iff its element type is, a trait view iff its concrete
# witness is.
# Functions, scalars and `any` are unrestricted -- a closure cannot capture
# an affine value (AFFINE-CAPTURE-UNSUPPORTED), and `any` never holds one
# (AFFINE-ERASURE-UNSUPPORTED). A future affine root (a file, a socket, a
# stateful closure) is one more case in AffineRoot; every ownership analysis
# consumes only this query.

# affine or unrestricted.
proc hir::types::Affinity {type} {
    return [expr {[IsAffine $type] ? "affine" : "unrestricted"}]
}

# 1 if TYPE is an intrinsically affine root type (no component makes it so).
proc hir::types::AffineRoot {type} {
    # A C address (C-ABI-TYPES.md) is affine by the same rule as a handle:
    # one usable owner, an explicit clone for a second alias. It owns
    # nothing (hir::affine::Descriptor drops nothing for it).
    return [expr {[IsCoroutine $type] || $type eq "coroutine" || [IsCAddress $type]}]
}

# 1 if any of TYPES is affine.
proc hir::types::AnyAffine {types} {
    foreach t $types {
        if {[IsAffine $t]} {
            return 1
        }
    }
    return 0
}

# 1 if TYPE is affine (Affinity).
proc hir::types::IsAffine {type {seen {}}} {
    if {[llength $type] < 2} {
        return [AffineRoot $type]
    }
    switch -- [lindex $type 0] {
        coroutine - cptr - cfnptr {
            return 1
        }
        imprint {
            # A variable is bound to an unrestricted type only
            # (hir::imprint::Bind): its function's body may copy it.
            return 0
        }
        srefined {
            # A refinement is knowledge about a value, never ownership: a
            # refined value is affine exactly when its base is.
            return [IsAffine [hir::refinements::Base $type] $seen]
        }
        list {
            if {[IsAffine [lindex $type 1] $seen]} {
                return 1
            }
            if {[llength $type] == 3} {
                foreach p [lindex $type 2] {
                    if {[IsAffine $p $seen]} {
                        return 1
                    }
                }
            }
            return 0
        }
        immutableSet - mutarray - mutvec {
            # A MutableVector or MutableArray of affine elements is itself
            # affine: it uniquely owns every element (MUTABLE-VECTOR.md,
            # MUTABLE-ARRAY.md). Mutation alone never makes a type affine.
            return [IsAffine [lindex $type 1] $seen]
        }
        struct {
            foreach {name t} [lindex $type 1] {
                if {[IsAffine $t $seen]} {
                    return 1
                }
            }
            return 0
        }
        nstruct {
            return [hir::structs::IsAffine [lindex $type 1] $seen]
        }
        enum {
            # Derived from the enum's case payloads (hir::enums::IsAffine):
            # no payload-free case owns anything, so every enum of today is
            # unrestricted -- by that rule, not by being an enum.
            return [hir::enums::IsAffine [lindex $type 1] $seen]
        }
        trait {
            set w [lindex $type 2]
            if {$w eq "" || [IsAbstractWitness $w] || [IsJoinWitness $w]} {
                return 0
            }
            return [IsAffine $w $seen]
        }
    }
    return 0
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
    if {[IsRefinedApplied $type]} {
        return [MentionsTrait [hir::refinements::Base $type]]
    }
    if {[IsList $type] || [IsSet $type] || [IsMutArray $type] || [IsMutVec $type]} {
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
    foreach t [StructArgs $type] {
        if {[MentionsTrait $t]} { return 1 }
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
        if {[hir::traits::isContext [lindex $type 1]]} {
            return [lindex $type 1]
        }
        return ""
    }
    set inner {}
    if {[IsRefinedApplied $type]} {
        set inner [list [hir::refinements::Base $type]]
    } elseif {[IsList $type] || [IsSet $type] || [IsMutArray $type] || [IsMutVec $type]} {
        set inner [list [lindex $type 1]]
    } elseif {[IsFn $type]} {
        set inner [concat [FnArgs $type] [list [FnReturn $type]]]
    } elseif {[IsStruct $type]} {
        set inner [lmap {name t} [lindex $type 1] {set t}]
    } elseif {[IsAppliedStruct $type]} {
        set inner [StructArgs $type]
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
    if {[llength $all] == 1} {
        return [lindex $all 0]
    }
    return [linsert $all 0 join]
}

# TYPE as an aggregate element/field: a view is erased to any (the concrete
# runtime value is what is stored; no witness or tag is kept, TRAITS.md
# "any"), so no List/ImmutableSet/MutableArray/struct type ever has a trait
# element.
proc hir::types::Unviewed {type} {
    if {[IsTrait $type]} {
        return "any"
    }
    return $type
}

# ---------------------------------------------------------------------------
# Refinements of applied types (LIST-CARDINALITY-REFINEMENTS.md; the
# header's {srefined FAMILY FACTS BASE})
#
# One fact theory today: the List family's exact `length`. Everything here
# is generic over the family (hir/refinements.tcl's schema decides what a
# fact means and how two of them combine); what this section adds is the
# base -- the applied type a member refines -- and the types whose own form
# already states a fact (FactsOf).

# 1 if TYPE is a refinement of an applied type.
proc hir::types::IsRefinedApplied {type} {
    return [expr {[llength $type] == 4 && [lindex $type 0] eq "srefined"}]
}

# TYPE with its outermost refinement forgotten (its base); TYPE itself when
# it is no refinement of an applied type. Forgetting is always valid: every
# member is a value of its base, with the same representation.
proc hir::types::Unrefined {type} {
    if {[IsRefinedApplied $type]} {
        return [hir::refinements::Base $type]
    }
    return $type
}

# The family over a type constructor that A or B is a refinement of (A's,
# when both are), else "": the operation combining A and B (lub, glb,
# narrow) then combines their bases and their facts of that family.
proc hir::types::AppliedFamily {a b} {
    foreach t [list $a $b] {
        if {[IsRefinedApplied $t]} {
            return [hir::refinements::Family $t]
        }
    }
    return ""
}

# The facts of FAMILY the base type TYPE states by its own form, without a
# refinement: an empty List[never] (no value has type never, so the List
# has no element) states length 0, a positional shape its length; {} for
# any other type.
proc hir::types::BaseFacts {family type} {
    if {$family ne "List" || ![IsList $type]} {
        return {}
    }
    if {[llength $type] == 3} {
        return [list length [llength [lindex $type 2]]]
    }
    if {[lindex $type 1] eq "never"} {
        return [list length 0]
    }
    return {}
}

# The facts of FAMILY known of every value of TYPE: a member's own, else
# what its form states (BaseFacts); {} for none.
proc hir::types::FactsOf {family type} {
    if {[IsRefinedApplied $type]} {
        if {[hir::refinements::Family $type] eq $family} {
            return [hir::refinements::Facts $type]
        }
        return {}
    }
    return [BaseFacts $family $type]
}

# The canonical type of the values of BASE of which the FAMILY facts FACTS
# are known (a dict; {} for none): BASE itself when FACTS is empty or BASE
# states them by its own form (BaseFacts: List[never] is length 0 already),
# never when BASE states other facts (an empty List of length 3) or is
# never, and BASE (forgetting FACTS) when it is not of FAMILY's base kind
# (a List fact joined with an Int: any) -- else {srefined FAMILY FACTS
# BASE}, the facts in canonical order and BASE unshaped (a shape's length
# is the refinement's).
proc hir::types::Refine {base family facts} {
    if {$base eq "never"} {
        return never
    }
    set facts [hir::refinements::CanonicalFacts $family $facts]
    if {$facts eq {}} {
        return $base
    }
    if {[IsRefinedApplied $base]} {
        set merged [hir::refinements::GlbFacts $family [FactsOf $family $base] $facts]
        if {$merged eq "none"} {
            return never
        }
        return [Refine [Unrefined $base] $family $merged]
    }
    if {![RefinableBase $family $base]} {
        return $base
    }
    set stated [BaseFacts $family $base]
    if {$stated ne {}} {
        set merged [hir::refinements::GlbFacts $family $stated $facts]
        if {$merged eq "none"} {
            return never
        }
        if {$merged eq $stated && [llength $base] == 2} {
            return $base
        }
        set facts $merged
    }
    return [list srefined $family $facts [Unshaped $base]]
}

# 1 if BASE is a type FAMILY may refine: a List form or the bare `list` kind
# (List[any]) for the List family -- the family's base kind, applied.
proc hir::types::RefinableBase {family base} {
    if {$base eq [hir::refinements::base $family]} {
        return 1
    }
    return [expr {$family eq "List" && [IsList $base]}]
}

# The exact length of every value of TYPE (a List the type refines, or
# states by its form), or "".
proc hir::types::LengthOf {type} {
    set facts [FactsOf List $type]
    if {[dict exists $facts length]} {
        return [dict get $facts length]
    }
    return ""
}

# The value of parameter PARAM of the FAMILY facts known of every value of
# TYPE (FactsOf), or "".
proc hir::types::FactValue {family param type} {
    return [dict getdef [FactsOf $family $type] $param ""]
}

# {ARG FAMILY PARAM} when E is a call of a native that measures a fact
# (core/native.tcl's -measures {FAMILY PARAM K}: std::list::length measures a
# List's length), ARG its argument K; else "".
proc hir::types::Measure {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "call"} {
        return ""
    }
    lassign [dict get $node target] kind symbol
    if {$kind ne "native"} {
        return ""
    }
    set measures [MeasuresOf [dict get [hir::symbol $hir $symbol] name]]
    if {$measures eq ""} {
        return ""
    }
    lassign $measures family param k
    set args [dict get $node args]
    if {$k >= [llength $args]} {
        return ""
    }
    return [list [lindex $args $k] $family $param]
}

# The -measures registration of native NAME, or "".
proc hir::types::MeasuresOf {name} {
    if {[catch {core::native::metadata $name} meta]} {
        return ""
    }
    return [dict getdef $meta measures ""]
}

# The exact Int a call of native NAME on ARGEXPRS returns because its
# argument's static type states the fact it measures (MeasuresOf: the length
# of a List whose type is List[T]{length: N} is N), or "".
proc hir::types::MeasuredValue {hir name argExprs} {
    set measures [MeasuresOf $name]
    if {$measures eq ""} {
        return ""
    }
    lassign $measures family param k
    if {$k >= [llength $argExprs]} {
        return ""
    }
    return [FactValue $family $param [hir::typeOf $hir [lindex $argExprs $k]]]
}

# TYPE with every fact of a family whose interface is `declared` forgotten,
# at every depth (elements, fields, function types): what an undeclared
# function result and a semantic instance's entry types keep
# (hir/refinements.tcl, "interface"; LIST-CARDINALITY-REFINEMENTS.md,
# "Function contracts"). Every other fact (a DecimalRounded guarantee) is
# kept.
proc hir::types::ForgetInferred {type} {
    if {[llength $type] < 2} {
        return $type
    }
    if {[hir::refinements::IsRefined $type]} {
        set family [hir::refinements::Family $type]
        if {[hir::refinements::IsApplied $family]} {
            set base [ForgetInferred [hir::refinements::Base $type]]
            if {[hir::refinements::Interface $family] eq "declared"} {
                return $base
            }
            return [Refine $base $family [hir::refinements::Facts $type]]
        }
        return $type
    }
    switch -- [lindex $type 0] {
        list {
            if {[llength $type] == 3} {
                return [list list [ForgetInferred [lindex $type 1]] [lmap p [lindex $type 2] {ForgetInferred $p}]]
            }
            return [list list [ForgetInferred [lindex $type 1]]]
        }
        immutableSet - mutarray - mutvec {
            return [list [lindex $type 0] [ForgetInferred [lindex $type 1]]]
        }
        struct {
            set fields {}
            foreach {name t} [lindex $type 1] {
                lappend fields $name [ForgetInferred $t]
            }
            return [list struct $fields]
        }
        nstruct {
            if {[llength $type] == 3} {
                return [list nstruct [lindex $type 1] [lmap t [lindex $type 2] {ForgetInferred $t}]]
            }
        }
        fn - coroutine {
            set fields [lindex $type 1]
            dict set fields args [lmap t [dict get $fields args] {ForgetInferred $t}]
            dict set fields return [ForgetInferred [dict get $fields return]]
            return [list [lindex $type 0] $fields]
        }
        block {
            return [lreplace $type 3 3 [ForgetInferred [lindex $type 3]]]
        }
    }
    return $type
}

# TYPE as a diagnostic shows a value's type when the diagnostic is not about
# a List's length: every length inference minted forgotten (ForgetInferred;
# LIST-CARDINALITY-REFINEMENTS.md, "Diagnostics"). A projection of a List or
# a List passed where C wants a scalar is wrong whatever its length, which
# would only distract; a message about a length shows the type itself
# (hir::range::ShownArgType keeps it where the expected type states one).
proc hir::types::showValue {type} {
    return [show [ForgetInferred $type]]
}

# ---------------------------------------------------------------------------
# Enum types (ENUMS.md; the header's {enum ID})

# 1 if TYPE is an enum type ({enum ID}).
proc hir::types::IsEnum {type} {
    return [expr {[lindex $type 0] eq "enum" && [llength $type] == 2}]
}

# ---------------------------------------------------------------------------
# Struct types (STRUCTS.md; the header's {struct FIELDS} and {nstruct ID})

# 1 if TYPE is an anonymous struct type.
proc hir::types::IsStruct {type} {
    return [expr {[lindex $type 0] eq "struct" && [llength $type] == 2}]
}

# 1 if TYPE is a named struct type (an application of a parameterized one
# included).
proc hir::types::IsNamedStruct {type} {
    return [expr {[lindex $type 0] eq "nstruct" && [llength $type] in {2 3}}]
}

# 1 if TYPE is an application {nstruct ID ARGS} of a parameterized struct
# (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md).
proc hir::types::IsAppliedStruct {type} {
    return [expr {[lindex $type 0] eq "nstruct" && [llength $type] == 3}]
}

# The type arguments of the application TYPE, in slot order ("" for any
# other type).
proc hir::types::StructArgs {type} {
    if {[IsAppliedStruct $type]} {
        return [lindex $type 2]
    }
    return ""
}

# The canonical application of parameterized struct ID to ARGS (types, one
# per slot), nested DEPTH aggregate forms and NESTING applications deep.
# Every argument is bounded at the application's own aggregate depth
# (Bound): an argument is the type of the fields that name its slot, so it
# is cut exactly where a value of it standing in that position is (List
# admission and applications are invariant: an argument cut a level earlier
# than its values' types would admit none of them). An application directly
# in an argument is one application deeper, and past appliedDepth
# applications the arguments are `any` -- a sound description of every
# value of the constructor, which keeps inferred types finite (a function
# whose result wraps its own result) and declared types of any practical
# depth intact.
proc hir::types::MakeApplied {id args {depth 0} {nesting 0}} {
    variable appliedDepth
    if {$nesting >= $appliedDepth} {
        return [list nstruct $id [lrepeat [llength $args] any]]
    }
    set inner [expr {$nesting + 1}]
    return [list nstruct $id [lmap a $args {
        if {[IsAppliedStruct $a]} {
            MakeApplied [lindex $a 1] [lindex $a 2] $depth $inner
        } else {
            Unviewed [Unshaped [Bound $a $depth]]
        }
    }]]
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
    if {$depth >= $aggregateDepth && ![AnyAffine [dict values $fields]]} {
        # (Never cut when a field is affine: AFFINE-VALUES.md.)
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
        return [dict getdef $fields $name ""]
    }
    if {[IsAppliedStruct $type]} {
        # (An application's fields: the declaration's, its slots replaced by
        # the arguments, TRAIT-CONSTRAINED-IMPRINTED-TYPES.md.)
        return [hir::structs::AppliedFieldType $type $name]
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
    set errors [dict getdef $node declaredErrors {}]
    if {[lsearch -exact -not $declared {}] < 0 && $errors eq {}} {
        return ""
    }
    set args [lmap t $declared {if {$t eq {}} {string cat "any"} else {canonical $t}}]
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
# What a call of a value of callable TYPE returns: an exact block's result,
# a structural Fn's or an exact native's contract result, a coroutine's
# outward type; any when TYPE is not statically callable.
proc hir::types::CallableResult {type} {
    if {[IsExactBlock $type]} {
        return [lindex $type 3]
    }
    if {[IsCoroutine $type]} {
        return [CoroutineOutward $type]
    }
    set s [structuralOf $type]
    if {$s ne ""} {
        return [FnReturn $s]
    }
    return any
}

# The declared errors a call of a value of callable TYPE may complete with:
# an exact block's declared errors, a structural Fn's or coroutine's
# contract errors, an exact native's -errors; none otherwise (an untyped
# value: hir/callables.tcl keeps an error-bearing callable from being
# erased to one).
proc hir::types::CallableErrors {hir type} {
    if {[IsExactBlock $type]} {
        set block [lindex $type 1]
        if {[dict exists $hir exprs $block]} {
            return [dict get $hir exprs $block declaredErrors]
        }
    }
    if {[IsCoroutine $type]} {
        return [CoroutineErrors $type]
    }
    set s [structuralOf $type]
    if {$s ne ""} {
        return [dict get [lindex $s 1] errors]
    }
    return {}
}

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
        if {![Admits $x $y] || ([IsAffine $y] && ![IsAffine $x])} {
            # (An argument the contract may pass affine must be received by
            # a parameter that owns it: an `any` or untyped parameter of a
            # function value has no specialization to carry ownership,
            # AFFINE-VALUES.md.)
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

# Why coroutine handle type A is not usable where coroutine handle type B is
# expected, or "": FnMismatch's answer for their callable contracts -- the
# same arity, argument (contravariant), return (covariant) and error-subset
# rules a structural Fn obeys. Coroutine lifecycle adds no variance rule: a
# resume is a call with the contract's arguments, result and errors.
proc hir::types::CoroutineMismatch {a b} {
    return [FnMismatch [list fn [lindex $a 1]] [list fn [lindex $b 1]]]
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
    set family [AppliedFamily $a $b]
    if {$family ne ""} {
        # A refinement of an applied type (a List of a known length): the
        # meet of the bases, each fact the stronger -- none when the facts
        # contradict each other (two different lengths: no value has both).
        set base [glb [Unrefined $a] [Unrefined $b]]
        set facts [hir::refinements::GlbFacts $family [FactsOf $family $a] [FactsOf $family $b]]
        if {$base eq "" || $facts eq "none"} {
            return ""
        }
        return [Refine $base $family $facts]
    }
    if {[hir::refinements::IsRefined $a] && [hir::refinements::IsRefined $b]} {
        # Two scalar refinements of one family: each fact the stronger.
        if {[hir::refinements::Family $a] ne [hir::refinements::Family $b]} {
            return ""
        }
        return [hir::refinements::Glb $a $b]
    }
    set aNarrower [Admits $b $a]
    set bNarrower [Admits $a $b]
    set core [expr {![IsSpecific $a] && ![IsSpecific $b] && $a ne "any" && $b ne "any"
        && [core::type::base $a] eq [core::type::base $b]}]
    if {$aNarrower && $bNarrower} {
        # Equivalent under admissibility: a deterministic, operand-order-
        # independent choice.
        if {$core} {
            return [core::type::narrow $a $b]
        }
        return [lindex [lsort [list $a $b]] 0]
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
    if {[IsCoroutine $actual] && [IsFn $expected]} {
        return "a coroutine handle is not a function value: Coroutine and Fn are distinct callable kinds, even with the same contract"
    }
    if {[IsCoroutine $expected]} {
        if {![IsCoroutine $actual]} {
            return "only a coroutine handle is a Coroutine: a function value is not one, even with the same contract (Fn and Coroutine are distinct callable kinds)"
        }
        # The same contract rules as a Fn's (CoroutineMismatch), worded for
        # a resume.
        set s [list fn [lindex $actual 1]]
        set expected [list fn [lindex $expected 1]]
        set why [FnMismatch $s $expected]
        switch -- [lindex $why 0] {
            arity {
                return "resume protocol mismatch: the coroutine takes [lindex $why 1] message(s), the type [lindex $why 2]"
            }
            arg {
                return [format {message type mismatch: the coroutine is resumed with %s, the type with %s} \
                    [show [lindex [FnArgs $s] 0]] [show [lindex [FnArgs $expected] 0]]]
            }
            return {
                return [format {return incompatible: each resume returns %s, not usable as %s} \
                    [show [FnReturn $s]] [show [FnReturn $expected]]]
            }
            errors {
                return [format {error set incompatible: a resume may raise %s, but the type allows only [%s]} \
                    [join [lrange $why 1 end] {, }] [join [FnErrors $expected] {, }]]
            }
        }
        return ""
    }
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
    if {$depth >= $aggregateDepth && ![IsAffine $elem]} {
        # (An affine element type is never erased: AFFINE-VALUES.md.)
        return mutarray
    }
    if {$elem eq "never"} {
        set elem any
    }
    return [list mutarray [Unviewed [Unshaped [Bound $elem [expr {$depth + 1}]]]]]
}

# 1 if TYPE is or holds a MutableVector or a MutableArray (an element, a
# field): a type some place of which may be mutated.
proc hir::types::MentionsMutable {type {seen {}}} {
    if {[IsMutVec $type] || [IsMutArray $type] || $type in {mutvec mutarray}} {
        return 1
    }
    if {[IsRefinedApplied $type]} {
        return [MentionsMutable [hir::refinements::Base $type] $seen]
    }
    if {[IsList $type] || [IsSet $type]} {
        return [MentionsMutable [lindex $type 1] $seen]
    }
    if {[IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[MentionsMutable $t $seen]} { return 1 }
        }
    }
    if {[IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$type in $seen} {
            return 0
        }
        foreach {name t} [hir::structs::AppliedFieldTypes $type] {
            if {[MentionsMutable $t [concat $seen [list $type]]]} { return 1 }
        }
    }
    return 0
}

# 1 if TYPE is an applied MutableVector form ({mutvec ELEM}). The bare atom
# `mutvec` (the runtime kind) is not one.
proc hir::types::IsMutVec {type} {
    return [expr {[lindex $type 0] eq "mutvec" && [llength $type] == 2}]
}

# The canonical MutableVector[ELEM], nested DEPTH aggregate forms deep. A
# `never` element is kept: MutableVector[never] is the proven-empty vector
# (`from_list([])`), admissible wherever a MutableVector[T] is declared
# (hir::range::AggregateAdmits), into which nothing can ever be pushed.
# Past the aggregate bound the bare kind, unless the element is affine (an
# affine element type is never erased: AFFINE-VALUES.md).
proc hir::types::MakeMutVec {elem depth} {
    variable aggregateDepth
    if {$depth >= $aggregateDepth && ![IsAffine $elem]} {
        return mutvec
    }
    return [list mutvec [Unviewed [Unshaped [Bound $elem [expr {$depth + 1}]]]]]
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
    if {$depth >= $aggregateDepth && ![IsAffine $elem] && ![AnyAffine $positions]} {
        # (An affine element is never cut: the bare kind would erase the
        # ownership it carries -- AFFINE-VALUES.md.)
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
    if {[IsRefinedApplied $type]} {
        # (The facts are a few integers: only the base is bounded.)
        return [Refine [Bound [hir::refinements::Base $type] $depth] \
            [hir::refinements::Family $type] [hir::refinements::Facts $type]]
    }
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
    if {[IsMutVec $type]} {
        return [MakeMutVec [lindex $type 1] $depth]
    }
    if {[IsStruct $type]} {
        return [MakeStruct [lindex $type 1] $depth]
    }
    if {[IsAppliedStruct $type]} {
        return [MakeApplied [lindex $type 1] [lindex $type 2] $depth]
    }
    if {[IsExactBlock $type]} {
        if {$depth >= $aggregateDepth} {
            set result "any"
        } else {
            set result [Bound [lindex $type 3] [expr {$depth + 1}]]
        }
        return [lreplace $type 3 3 $result]
    }
    if {[IsFn $type]} {
        # Past the bound a structural function type becomes any -- a sound
        # over-approximation, unlike cutting one of its (contravariant)
        # argument types would be (MakeFn).
        return [MakeFn [FnArgs $type] [FnReturn $type] [FnErrors $type] $depth]
    }
    if {[IsCoroutine $type]} {
        # Never cut (an affine value is never erased): only its result is
        # bounded (MakeCoroutineType).
        return [MakeCoroutineType [dict get [lindex $type 1] args] [CoroutineOutward $type] \
            [CoroutineErrors $type] $depth]
    }
    return $type
}

# TYPE without a positional shape.
proc hir::types::Unshaped {type} {
    if {[IsList $type] && [llength $type] == 3} {
        if {[lindex $type 1] eq "any"} {
            return "list"
        }
        return [lrange $type 0 1]
    }
    return $type
}

# The static type of every element of a value of static type TYPE, if TYPE
# is a list form; otherwise "".
proc hir::types::elementOf {type} {
    if {[IsRefinedApplied $type]} {
        return [elementOf [hir::refinements::Base $type]]
    }
    if {[IsList $type]} {
        return [lindex $type 1]
    }
    return ""
}

# The static type of the loop variable of a loop over a value of static type
# TYPE: a List's element type, or a MutableVector's (MUTABLE-VECTOR.md: a
# loop over an unrestricted vector iterates its snapshot, over an affine one
# consumes it); "" if not known.
proc hir::types::IterationElementOf {type} {
    if {[IsMutArray $type]} {
        # A MutableArray's element type (MUTABLE-ARRAY.md: snapshot or
        # consuming iteration, as a vector's).
        return [lindex $type 1]
    }
    if {[IsMutVec $type]} {
        # (MutableVector[never] promises no element type for its contents:
        # it is empty only while held at that type, and a value read back
        # from HIR text or Core IR may have lost the declared type it was
        # filled under -- never a reason to call a loop body dead.)
        if {[lindex $type 1] eq "never"} {
            return ""
        }
        return [lindex $type 1]
    }
    return [elementOf $type]
}

# The positional shape {P0 ...} of static type TYPE, or "" if not known.
proc hir::types::shapeOf {type} {
    if {[IsList $type] && [llength $type] == 3} {
        return [lindex $type 2]
    }
    return ""
}

# 1 if every value of static type A is a value of static type B.
proc hir::types::subtype {a b} {
    if {$a eq "never" || $b eq "any" || $a eq $b} {
        return 1
    }
    if {$b eq "never"} {
        return 0
    }
    if {[IsNativeMemory $a] || [IsNativeMemory $b]} {
        # Nominal (NATIVE-LAYOUT-VIEWS.md): the same layout was decided above
        # ($a eq $b). A view is never a pointer, though its run-time word is
        # one: no pointer operation (null?, clone, a C argument) takes it.
        # A NativeEdit[L] and a NativeView[L] are not each other's subtypes
        # either way (NATIVE-LAYOUT-WRITES.md): write authority is never read
        # authority's, and an edit is not silently narrowed into a view.
        return 0
    }
    if {[hir::refinements::IsRefined $b]} {
        # A scalar refinement (hir/refinements.tcl): only a member of the
        # same family whose facts imply B's -- never a value of its base,
        # which states no fact (a fact is minted by a proof, never by
        # subtyping). A refinement of an applied type relates the bases
        # too, and a type whose own form states the facts (FactsOf: an
        # empty List[never]) implies them as a member would.
        set family [hir::refinements::Family $b]
        if {![hir::refinements::IsApplied $family]} {
            return [expr {[hir::refinements::IsRefined $a] && [hir::refinements::Implies $a $b]}]
        }
        set facts [FactsOf $family $a]
        if {$facts eq {} || ![hir::refinements::ImpliesFacts $family $facts [hir::refinements::Facts $b]]} {
            return 0
        }
        return [subtype [Unrefined $a] [hir::refinements::Base $b]]
    }
    if {[hir::refinements::IsRefined $a]} {
        # Forgetting every fact: a member is a value of its base.
        return [subtype [hir::refinements::Base $a] $b]
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
        # MutableArray[E] is a value (MUTABLE-ARRAY.md), like MutableVector:
        # an array of a subtype is one of the supertype, since a copy never
        # writes through to another logical value. The raw kind is
        # MutableArray[any]. (Under the reference semantics MutableArray had
        # before, it was invariant: a wider view was an alias that could
        # store values the original's element type excluded.)
        if {[IsMutArray $a]} {
            return [subtype [lindex $a 1] [lindex $b 1]]
        }
        return [expr {$a eq "mutarray" && [lindex $b 1] eq "any"}]
    }
    if {[IsMutVec $b]} {
        # MutableVector[E] is a value (MUTABLE-VECTOR.md): like List, a
        # vector of a subtype is one of the supertype (a copy never writes
        # through to another logical value). The bare kind is
        # MutableVector[any].
        if {[IsMutVec $a]} {
            return [subtype [lindex $a 1] [lindex $b 1]]
        }
        return [expr {$a eq "mutvec" && [lindex $b 1] eq "any"}]
    }
    if {$b eq "mutarray" && [IsMutArray $a]} {
        # The raw kind, MutableArray[any]: every MutableArray[T] is one.
        return 1
    }
    if {[IsStruct $b]} {
        # An anonymous struct is compatible with another only when the field
        # sets are equal (no width subtyping, no optional fields) and every
        # field type is compatible -- fields are immutable, so covariant.
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
    if {[IsCoroutine $b]} {
        # A coroutine handle type (AFFINE-VALUES.md): only another coroutine
        # handle, whose callable contract is compatible by the very rules a
        # Fn's is (CoroutineMismatch). Never a Fn or an exact function: the
        # callable *kind* is part of the type, the contract is shared.
        return [expr {[IsCoroutine $a] && [CoroutineMismatch $a $b] eq ""}]
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
    set family [AppliedFamily $a $b]
    if {$family ne ""} {
        # A refinement of an applied type: the join of the bases, each fact
        # the weaker -- a List of length 4 and one of length 5 join to a
        # List of no known length (hir::refinements::LubFacts: an exact
        # fact holds of the join only when both sides state the same one).
        return [Refine [lub [Unrefined $a] [Unrefined $b]] $family \
            [hir::refinements::LubFacts $family [FactsOf $family $a] [FactsOf $family $b]]]
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
    if {[IsMutVec $a] && [IsMutVec $b]} {
        # Two MutableVector values: their elements join, as a List's do.
        return [MakeMutVec [lub [lindex $a 1] [lindex $b 1]] 0]
    }
    if {[IsMutArray $a] && [IsMutArray $b]} {
        # Two MutableArray values: their elements join, as a MutableVector's
        # do.
        return [MakeMutArray [lub [lindex $a 1] [lindex $b 1]] 0]
    }
    if {[IsNativeMemory $a] || [IsNativeMemory $b]} {
        # Nominal (NATIVE-LAYOUT-VIEWS.md): views of two layouts, or a view
        # and anything else, have no useful join -- never the bare pointer
        # kind their words share, which is affine. (A view and an edit of
        # one layout neither: NATIVE-LAYOUT-WRITES.md.)
        return any
    }
    if {[hir::refinements::IsRefined $a] && [hir::refinements::IsRefined $b]
            && [hir::refinements::Family $a] eq [hir::refinements::Family $b]} {
        # Two members of one scalar-refinement family: each fact the weaker
        # of the two (hir::refinements::Lub), or the base when none holds
        # for both.
        set joined [hir::refinements::Lub $a $b]
        if {$joined ne ""} {
            return $joined
        }
        return [hir::refinements::Base $a]
    }
    if {[IsEnum $a] || [IsEnum $b]} {
        # Nominal (ENUMS.md): the same enum was decided above ($a eq $b).
        # Two different enums -- or an enum and anything else -- have no
        # useful join: never a union of the two case sets (there are no
        # anonymous enums) and never the bare `enum` kind. The broad any.
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
    if {[IsCoroutine $a] && [IsCoroutine $b]} {
        # Two coroutine handle types: the narrowest common contract (the
        # Fn rules, FnLub), still a coroutine; none representable is any --
        # which no affine value may flow into (AFFINE-ERASURE-UNSUPPORTED).
        set joined [FnLub [list fn [lindex $a 1]] [list fn [lindex $b 1]]]
        if {$joined ne ""} {
            return [canonical [list coroutine [lindex $joined 1]]]
        }
        return any
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
        if {$kind ne "" && $kind eq [kindOf $b]} {
            return $kind
        }
        return "any"
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
    if {$fact eq "any" || $current eq "never" || [IsImprint $fact]} {
        # (An imprint variable as a fact -- a declared List[T] parameter of
        # an instance -- says nothing a value's own type does not: T is
        # whatever each call imprints, hir/imprint.tcl.)
        return $current
    }
    if {[IsTrait $current]} {
        # A trait view is never strengthened by a fact about its value (a
        # kind test, a native's parameter type): its source-visible type is
        # its trait, whatever runs underneath (TRAITS.md, "One-way").
        return $current
    }
    set family [AppliedFamily $current $fact]
    if {$family ne ""} {
        # A refinement of an applied type, on either side: a fact about a
        # List's length (a guard's, hir/refine.tcl) narrows what is known of
        # its elements not at all, and an element fact keeps the length.
        # Contradicting facts (two lengths) hold of no value: never.
        set facts [hir::refinements::GlbFacts $family [FactsOf $family $current] [FactsOf $family $fact]]
        if {$facts eq "none"} {
            return never
        }
        return [Refine [narrow [Unrefined $current] [Unrefined $fact]] $family $facts]
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
    if {[IsMutVec $fact]} {
        # A declared MutableVector[T] theorem: the element facts combine,
        # as a List's do (an instance key's kind-only element, a coroutine,
        # adopts the declared contract); a bare or unknown vector adopts the
        # declared one.
        if {[IsMutVec $current] && [lindex $current 1] ne "never"} {
            return [MakeMutVec [narrow [lindex $current 1] [lindex $fact 1]] 0]
        }
        # (A proven-empty MutableVector[never] stays empty only while nothing
        # is pushed into it: a place of the declared type may push, so the
        # declared element type is the fact.)
        return $fact
    }
    if {[IsMutArray $fact]} {
        # A declared MutableArray[T] theorem, like a MutableVector's: the
        # element facts combine (an instance key's kind-only element, a
        # coroutine, adopts the declared contract); a raw or unknown array
        # adopts the declared one (legal callers already proved it).
        if {[IsMutArray $current] && [lindex $current 1] ne "never"} {
            return [MakeMutArray [narrow [lindex $current 1] [lindex $fact 1]] 0]
        }
        return $fact
    }
    if {[IsFn $fact] || [IsStructLike $fact] || [IsCoroutine $fact] || [IsEnum $fact]
            || [IsCPtr $fact] || [IsCFnPtr $fact] || [IsNativeMemory $fact]
            || [hir::refinements::IsRefined $fact]} {
        # A structural contract fact (a function contract, a struct type, a
        # coroutine handle's contract): a value already known to satisfy it
        # (a narrower contract, the same struct) says more.
        if {[subtype $current $fact]} {
            return $current
        }
        return $fact
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
        if {$fact in {list immutableSet mutarray mutvec} && [kindOf $current] in {list immutableSet mutarray mutvec}} {
            # Two different collection kinds: no value is both (a native's
            # parameter kind after a call that can only fail, a kind test
            # that cannot hold), so nothing follows.
            return never
        }
        return $fact
    }
    return [core::type::narrow $current $fact]
}

# ---------------------------------------------------------------------------
# Equality and hash totality, and the intrinsic trait Hashable
# (HASHABLE-AND-KEYED-HASH.md)

# {CLASS WHY}: how every value of static TYPE answers to OPERATION -- equality
# (`==`, core::value::equal) or hash (core::hashing's canonical walk) -- the
# compile-time mirror of the operation itself:
#
#   total    every value has it: the operation never refuses one (equality of
#            two values of total types never raises EQUALITY: values of
#            different kinds simply compare unequal; hashing never raises)
#   none     TYPE names a component whose every value lacks it -- a function,
#            a coroutine handle, a MutableArray, a C pointer, ... -- so its
#            values are statically known not to be Hashable
#   unknown  neither is known: a component of no fixed kind (any, an imprint
#            variable, a view of another trait, a bare collection kind)
#
# WHY is "" for total, else the reason in source terms (what a
# TRAIT-NOT-SATISFIED explanation prints). One walk serves both operations:
# the per-kind facts are the runtime's own refusal lists (core::value's
# `incomparable` for equality, core::hashing's `unhashable` for hash), and the
# composite kinds recurse exactly as both operations do -- a List or an
# ImmutableSet into its elements, a struct into its fields (an opaque
# struct's too: `==` already compares its representation). SEEN holds the
# named structs being walked: a struct met again through its own fields (a
# `kids: List[Tree]`) adds nothing, so a recursive type is total when every
# other component is (every value is finite).
proc hir::types::Totality {operation type {seen {}}} {
    if {$type eq "never"} {
        # No value: vacuously total (List[never] is the empty List).
        return {total ""}
    }
    if {[IsTrait $type]} {
        if {$operation in [hir::traits::intrinsicGuarantees [lindex $type 1]]} {
            # A view of a trait whose witnesses guarantee the operation (the
            # intrinsic trait Hashable): total whatever the witness is.
            return {total ""}
        }
        return [list unknown "it is seen only through trait [lindex $type 1], whose values need not have total equality and hashing"]
    }
    if {[IsFn $type]} {
        return [list none [NoTotality $operation block]]
    }
    if {[IsImprint $type]} {
        foreach trait [ImprintConstraints $type] {
            if {$operation in [hir::traits::intrinsicGuarantees $trait]} {
                # A constrained variable (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md)
                # whose contract says it satisfies a trait guaranteeing the
                # operation: every type a call can imprint as it has it.
                return {total ""}
            }
        }
        return [list unknown "its type is the imprint variable [lindex $type 1], which no constraint holds to total equality and hashing"]
    }
    if {[hir::cabi::IsFloating $type]} {
        return [Totality $operation [hir::cabi::Carrier $type] $seen]
    }
    if {[hir::refinements::IsRefined $type] && [hir::refinements::IsApplied [hir::refinements::Family $type]]} {
        # A refinement is knowledge about a value of its base (a List of a
        # known length): the base's answer.
        return [Totality $operation [hir::refinements::Base $type] $seen]
    }
    if {[llength $type] >= 2} {
        switch -- [lindex $type 0] {
            list {
                if {[llength $type] == 3} {
                    # A positional shape: each element's own type.
                    return [Components $operation [lmap p [lindex $type 2] {list "element of the List" $p}] $seen]
                }
                return [Components $operation [list [list "its elements" [lindex $type 1]]] $seen]
            }
            immutableSet {
                return [Components $operation [list [list "its members" [lindex $type 1]]] $seen]
            }
            struct {
                set parts {}
                foreach {name t} [lindex $type 1] {
                    lappend parts [list "field \"$name\"" $t]
                }
                return [Components $operation $parts $seen]
            }
            nstruct {
                # (SEEN holds the struct types being walked, an application
                # with its arguments: a recursive parameterized struct's
                # applications are finitely many, hir::structs::apply.)
                set id [lindex $type 1]
                if {$type in $seen} {
                    return {total ""}
                }
                if {![hir::structs::declared $id] && [hir::layouts::OfStructId $id] eq ""} {
                    return [list unknown "$id is not a declared struct"]
                }
                set parts {}
                set shown [show $type]
                set identity [hir::structs::identityOf $id]
                if {$identity ne ""} {
                    # A struct that declares its identity
                    # (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md) is
                    # compared and hashed by it alone: its identity fields'
                    # elements are its components, named in the type's own
                    # terms (its representation is its owner's), and every
                    # other field takes no part.
                    set fields [hir::structs::AppliedFieldTypes $type]
                    foreach field [dict get $identity fields] label [hir::structs::IdentityLabels [dict get $identity form]] {
                        set t [dict get $fields $field]
                        lappend parts [list "the $label of $shown" [if {$t eq {}} {string cat any} else {elementOf $t}]]
                    }
                    return [Components $operation $parts [concat $seen [list $type]]]
                }
                foreach {name t} [hir::structs::AppliedFieldTypes $type] {
                    lappend parts [list "field \"$name\" of $shown" [if {$t eq {}} {string cat any} else {set t}]]
                }
                return [Components $operation $parts [concat $seen [list $type]]]
            }
        }
    }
    set kind [kindOf $type]
    if {$operation eq "equality"} {
        set refused $::core::value::incomparable
    } else {
        set refused $::core::hashing::unhashable
    }
    if {$kind in $refused} {
        return [list none [NoTotality $operation $kind]]
    }
    if {$kind eq "" || $kind in {list immutableSet struct result}} {
        # (`any`, an imprint variable and the other kind-less types are "":
        # kindOf; the others are bare kinds whose elements are not known.)
        return [list unknown "its static type is [show $type], whose values are not known to have total equality and hashing (one may hold a function)"]
    }
    return {total ""}
}

# Totality's answer for a value made of the PARTS {WHAT TYPE}: none if one part
# is (the first such, named), else unknown if one part is, else total.
proc hir::types::Components {operation parts seen} {
    set unknown ""
    foreach part $parts {
        lassign $part what t
        lassign [Totality $operation $t $seen] class why
        if {$class eq "none"} {
            return [list none "$what ([show $t]): $why"]
        }
        if {$class eq "unknown" && $unknown eq ""} {
            set unknown "$what ([show $t]): $why"
        }
    }
    if {$unknown ne ""} {
        return [list unknown $unknown]
    }
    return {total ""}
}

# Why a value of runtime KIND has no OPERATION, in source terms.
proc hir::types::NoTotality {operation kind} {
    set op [expr {$operation eq "hash" ? "hash" : "total equality"}]
    switch -- $kind {
        block - native {
            return "a function has no $op (== of two functions is not defined: there is no function identity)"
        }
        coroutine {
            return "a coroutine handle has no $op (comparing one would observe what it owns)"
        }
        mutarray - mutvec {
            return "a [expr {$kind eq "mutarray" ? "MutableArray" : "MutableVector"}] has no $op (a mutable header's identity is never a value's)"
        }
        cptr {
            return "a C pointer or native view has no $op (no address identity is observable)"
        }
        DecimalRounded {
            return "a DecimalRounded value has no $op: it is equal to another only at its type's precision, which [expr {$operation eq "hash" ? "a hash" : "a type-blind equality"}] does not know"
        }
    }
    return "a value of kind $kind has no $op"
}

# 1 if every value of static TYPE is guaranteed to support Botlish's ordinary
# structural equality unconditionally: comparing it with any value of an
# equality-total type can never raise EQUALITY (Totality's `total` for
# equality). It recurses into Lists, ImmutableSets and structs, as
# core::value::equal does. The bare `never` is left out, as it always was: a
# call whose operand can produce no value keeps its generic lowering
# (M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md's List[never] fixture); as a
# component (the element of List[never]) it is vacuously total.
proc hir::types::IsEqualityTotal {type} {
    return [expr {$type ne "never" && [lindex [Totality equality $type] 0] eq "total"}]
}

# {CLASS WHY}: TYPE against the intrinsic trait Equatable -- total equality
# (Totality's equality column; REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md).
proc hir::types::EqualityClass {type} {
    return [Totality equality $type]
}

# {CLASS WHY}: TYPE against the intrinsic trait Hashable -- total equality and
# total hashing (Totality of both operations: none if either is, then unknown,
# else total).
proc hir::types::HashClass {type} {
    lassign [Totality equality $type] e ewhy
    lassign [Totality hash $type] h hwhy
    if {$e eq "none"} { return [list none $ewhy] }
    if {$h eq "none"} { return [list none $hwhy] }
    if {$e eq "unknown"} { return [list unknown $ewhy] }
    if {$h eq "unknown"} { return [list unknown $hwhy] }
    return {total ""}
}

# 1 if every value of static TYPE is Hashable: the witness predicate of the
# intrinsic trait Hashable (hir::traits's intrinsics), and the one native
# lowering reads to choose a total hash.
proc hir::types::IsHashable {type} {
    return [expr {[lindex [HashClass $type] 0] eq "total"}]
}

# The runtime value kind every value of TYPE has, or "" if not fixed.
proc hir::types::kindOf {type} {
    if {[hir::cabi::IsFloating $type]} {
        # (Never an expression's type: the values a C floating type
        # describes are its carrier's, hir::cabi::Carrier.)
        return [kindOf [hir::cabi::Carrier $type]]
    }
    if {[IsCFnPtr $type] || [IsNativeMemory $type]} {
        # (A native view's or edit's value is the address word of its
        # pointer.)
        return cptr
    }
    if {$type eq "never" || [IsFn $type] || [IsTrait $type] || [IsImprint $type]} {
        # A structural function type's value is a Block or a native: no
        # one runtime kind.
        return ""
    }
    if {[IsStructLike $type]} {
        return struct
    }
    if {[hir::refinements::IsRefined $type]} {
        # (The facts are static: the runtime kind is the base's.)
        if {[hir::refinements::IsApplied [hir::refinements::Family $type]]} {
            return [kindOf [hir::refinements::Base $type]]
        }
        return [hir::refinements::base [hir::refinements::Family $type]]
    }
    if {[IsSpecific $type]} {
        return [lindex $type 0]
    }
    return [core::type::base $type]
}

# The core type (core/type.tcl) a static type implies.
proc hir::types::semantic {type} {
    if {[hir::cabi::IsFloating $type]} {
        return [semantic [hir::cabi::Carrier $type]]
    }
    if {[IsCFnPtr $type] || [IsNativeMemory $type]} {
        return cptr
    }
    if {$type eq "never" || [IsFn $type] || [IsTrait $type] || [IsImprint $type]} {
        return any
    }
    if {[IsStructLike $type]} {
        return struct
    }
    if {[hir::refinements::IsRefined $type]} {
        if {[hir::refinements::IsApplied [hir::refinements::Family $type]]} {
            return [semantic [hir::refinements::Base $type]]
        }
        return [hir::refinements::base [hir::refinements::Family $type]]
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
    if {[core::value::kind $v] eq "enum"} {
        # A case value has exactly its declaring enum's type (ENUMS.md).
        return [list enum [core::value::enumId $v]]
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
            mutvec {
                return "MutableVector\[[show [lindex $type 1]]\]"
            }
            struct {
                # An anonymous struct type, fields in canonical order:
                # struct{age: int, name: str}. (The leading word keeps a
                # type text a Tcl-list-safe word sequence in HIR text, like
                # Fn{...}, and apart from an ImmutableSet's value display.)
                return "struct{[join [lmap {name t} [lindex $type 1] {format {%s: %s} $name [show $t]}] {, }]}"
            }
            nstruct {
                # A named struct, by its declared name; an application of a
                # parameterized one with its arguments, Pair[int, str].
                if {[llength $type] == 3} {
                    return "[hir::structs::display [lindex $type 1]]\[[join [lmap t [lindex $type 2] {show $t}] {, }]\]"
                }
                return [hir::structs::display [lindex $type 1]]
            }
            enum {
                # An enum, by its declared name (ENUMS.md).
                return [hir::enums::display [lindex $type 1]]
            }
            trait {
                # A trait constraint or view, by the trait's name only: the
                # source-visible type (a view's hidden witness is shown by
                # hir::traits::showView, never in a source-level message).
                return [lindex $type 1]
            }
            coroutine {
                # The source notation of a coroutine handle type, field for
                # field the one Fn{...} uses (AFFINE-VALUES.md).
                set fields [lindex $type 1]
                return [format {Coroutine{args: [%s], return: %s, errors: [%s]}} \
                    [join [lmap t [dict get $fields args] {show $t}] {, }] \
                    [show [dict get $fields return]] [join [dict get $fields errors] {, }]]
            }
            immutableSet {
                # Same convention as List[T] above: the canonical applied-
                # type notation, matching what a declared ImmutableSet[T]
                # annotation spells (a set form is always 2-element -- it
                # never has a positional shape to special-case).
                return "ImmutableSet\[[show [lindex $type 1]]\]"
            }
            cptr {
                # A C data pointer, by its source spelling (C-ABI-TYPES.md):
                # std::ffi::c::Ptr[std::ffi::c::Void], std::ffi::c::Ptr[std::ffi::c::Int],
                # std::ffi::c::Ptr[ssl::SSL].
                return "[hir::cabi::PtrName]\[[hir::cabi::ShowPointee [lindex $type 1]]\]"
            }
            cfnptr {
                return "[hir::cabi::FnPtrName]\[[hir::cabi::ShowSignature [lindex $type 1]]\]"
            }
            cfloat {
                # A C floating type, by its source spelling
                # (C-FLOAT-FFI-MILESTONE-1.md): std::ffi::c::Float, std::ffi::c::Double.
                return [hir::cabi::ShowFloating $type]
            }
            nview {
                # A native view, by its layout's identity
                # (NATIVE-LAYOUT-VIEWS.md), as LayoutStruct[L] is shown --
                # or a live array, by its representation
                # (FIXED-LAYOUT-ARRAYS.md: NativeView[array 16 of ...]).
                return "NativeView\[[hir::layouts::ShowNative [lindex $type 1]]\]"
            }
            nedit {
                # A native edit (NATIVE-LAYOUT-WRITES.md), likewise.
                return "NativeEdit\[[hir::layouts::ShowNative [lindex $type 1]]\]"
            }
            imprint {
                # An imprint variable, by its name (hir/imprint.tcl).
                return [lindex $type 1]
            }
            srefined {
                # A scalar refinement, by its source spelling
                # (DecimalRounded{minDecimalsPreserved: 2}).
                return [hir::refinements::Show $type]
            }
        }
    }
    set cabi [core::type::cabiScalar $type]
    if {$cabi ne ""} {
        # A C integer scalar, by its own name (C-ABI-TYPES.md): std::ffi::c::ULong,
        # not int[std::ffi::c::ULong]. It reads back as that registered name.
        return [lindex $type 2 0]
    }
    return [core::type::show $type]
}

# TYPE as a person reads it (a hover's text; COMPILER-SERVICE-MILESTONE-1.md):
# `show` of TYPE with every exact callable in it -- a block, which `show`
# names by its expression id (`block(e8)/2 -> int`), or a native -- replaced by
# its structural contract (structuralOf), in the Fn{...} notation an
# annotation spells. A type with no exact callable in it is shown as `show`
# shows it. Never used where a diagnostic's message is made.
proc hir::types::presented {type} {
    return [show [Presentable $type]]
}

proc hir::types::Presentable {type} {
    if {[IsExactBlock $type] || [IsExactNative $type]} {
        set structural [structuralOf $type]
        if {$structural eq ""} {
            return $type
        }
        set type $structural
    }
    if {[llength $type] < 2} {
        return $type
    }
    if {[hir::refinements::IsRefined $type]} {
        set family [hir::refinements::Family $type]
        if {[hir::refinements::IsApplied $family]} {
            return [Refine [Presentable [hir::refinements::Base $type]] $family [hir::refinements::Facts $type]]
        }
        return $type
    }
    switch -- [lindex $type 0] {
        list {
            if {[llength $type] == 3} {
                return [list list [Presentable [lindex $type 1]] [lmap p [lindex $type 2] {Presentable $p}]]
            }
            return [list list [Presentable [lindex $type 1]]]
        }
        immutableSet - mutarray - mutvec {
            return [list [lindex $type 0] [Presentable [lindex $type 1]]]
        }
        struct {
            set fields {}
            foreach {name t} [lindex $type 1] {
                lappend fields $name [Presentable $t]
            }
            return [list struct $fields]
        }
        nstruct {
            if {[llength $type] == 3} {
                return [list nstruct [lindex $type 1] [lmap t [lindex $type 2] {Presentable $t}]]
            }
        }
        fn - coroutine {
            set fields [lindex $type 1]
            dict set fields args [lmap t [dict get $fields args] {Presentable $t}]
            dict set fields return [Presentable [dict get $fields return]]
            return [list [lindex $type 0] $fields]
        }
    }
    return $type
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
    # The operators' meanings (hir/operators.tcl): a walk's types select the
    # floating-point operation of every operator call with a floating-point
    # operand, which is rewritten; the program is typed again while a
    # rewrite changed it.
    while 1 {
        Walk hir
        if {![hir::operators::resolve hir]} {
            return
        }
    }
}

# One typing walk of the whole of HIR (infer).
proc hir::types::Walk {hirVar} {
    upvar 1 $hirVar hir
    # Poison is a fact of one walk (a later round of the signature fixpoint
    # may type a receiver differently): every walk starts without any.
    dict unset hir poisoned
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

# ---------------------------------------------------------------------------
# Poison (DIAGNOSTIC-RECOVERY.md)
#
# An expression whose meaning the analysis has already proven cannot exist --
# a projection that is definitionally invalid (NOT-A-STRUCT, UNKNOWN-FIELD,
# OPAQUE-REPRESENTATION: hir/structs.tcl reports it, in every context), which
# is also what a method-style call with no function of its name visible
# becomes -- is *poison*: typed `never`, the bottom type, so no later check
# restates the failure as a mismatch, an unproven field or an unproven range
# (a value of type never is admissible everywhere and carries nothing), and
# recorded in HIR's `poisoned` side table so that it is not a *divergence*:
# code after it, and its siblings, stay reachable and keep every check of
# their own. Poison spreads through what consumes the value -- a call with a
# poisoned callee or argument, a bind (its binding: every reference to it), a
# construction, a projection, a sequence ending in it, a block whose result
# it is (`poisoned` holds the block's ExprId: its calls are poison) -- and
# never through control flow: a poisoned `if` condition leaves both branches
# reachable and undecided. Semantic inference makes poison -- the generic
# walk, and a semantic instance's walk, whose call is then poison too
# (hir::semantic::PoisonedCall: an instance's definitional failure is
# reported at that call, hir::semantic::verify) -- region inference never (an
# invalid projection there always raises: never). It exists only in a
# program with a diagnostic, never in a valid program's HIR, and no backend
# compiles it: a lenient HIR, which runs with its diagnostics, is checked
# again without poison first (hir::recovery::runnable, `unpoisoned`).
# Recovery state, never a type: hir::types::show never prints it.

# Expression E (`syntaxDependent`: its meaning depends on source the front
# end could not read, SYNTAX-RECOVERY-MILESTONE-1.md) typed as ever -- its
# children are what they are -- and then poison: its own value is not known.
proc hir::types::Dependent {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    dict unset hir syntaxDependent $e
    try {
        Expr hir ctx $e
    } finally {
        dict set hir syntaxDependent $e 1
    }
    return [SetType hir $e [Poison hir $e]]
}

# 1 if E (an ExprId or a BindingId; for a block, its result) is poison.
proc hir::types::Poisoned {hir e} {
    return [dict exists $hir poisoned $e]
}

# Records E (an ExprId or a BindingId) as poison; returns its type, never.
proc hir::types::Poison {hirVar e} {
    upvar 1 $hirVar hir
    dict set hir poisoned $e 1
    return never
}

# 1 if E, of static type TYPE, never completes normally: a `never` that is not
# poison.
proc hir::types::Halts {hir e type} {
    return [expr {$type eq "never" && ![dict exists $hir poisoned $e]}]
}

# 1 if semantic inference is typing (CTX) a source program (HIR): the generic
# walk or a semantic instance's (hir/semantic.tcl, whose call is poison when
# its result is), never region inference (hir/specialize.tcl), where these
# failures always raise. A program read from core IR text is past the source
# boundary: it has lost its declarations (a coroutine's resume type, ...), so
# a failure its weaker types show is no definitional one -- its lenient
# builds run such code (hir::build -strict 0) -- and nothing there is poison.
# Nor in a HIR checked again for a backend (hir::recovery::runnable).
proc hir::types::MakesPoison {hir ctx} {
    return [expr {![dict exists $ctx spec] && ![dict exists $hir unpoisoned]
        && [lindex [dict get $hir scopes [dict get $hir top] origin] 0] eq "file"}]
}

# The static type of constant V under aggregate facts.
proc hir::types::AggregateOfValue {v} {
    if {[core::value::kind $v] eq "list"} {
        return [MakeList never [lmap item [core::value::items $v] {AggregateOfValue $item}] 1]
    }
    return [ofValue $v]
}

# 1 if the std::binary::parse call whose arguments are ARGEXPRS (result shape
# SHAPE, {layout-struct I}) makes no LayoutStruct: its layout is native-only
# (a pointer field: LAYOUT-NATIVE-ONLY) or holds a union (LAYOUT-UNION,
# LAYOUT-UNIONS.md), or is a union.
proc hir::types::LayoutParseRefused {hir argExprs shape} {
    set arg [lindex $argExprs [lindex $shape 1]]
    if {$arg eq "" || [hir::kind $hir $arg] ne "const"} {
        return 0
    }
    set id [hir::layouts::DescriptorLayout [lindex [hir::get $hir $arg literal] end]]
    if {$id eq "" || ![hir::layouts::declared $id]} {
        return 0
    }
    return [expr {[hir::layouts::NativeOnly $id] || [hir::layouts::HoldsUnion $id]}]
}

# 1 if the std::binary::read call whose arguments are ARGEXPRS (result shape
# SHAPE, {layout-read I}) reads nothing: its designated representation holds
# a C pointer (LAYOUT-NATIVE-ONLY) or a union (LAYOUT-UNION), or the
# designator was rejected (its constant holds none).
proc hir::types::LayoutReadRefused {hir argExprs shape} {
    set arg [lindex $argExprs [lindex $shape 1]]
    if {$arg eq "" || [hir::kind $hir $arg] ne "const"} {
        return 0
    }
    set repr [hir::layouts::PathField [lindex [hir::get $hir $arg literal] end]]
    if {$repr eq ""} {
        return 1
    }
    return [expr {[hir::layouts::ReprPointerPath $repr] ne "none" || [hir::layouts::ReprUnionPath $repr] ne "none"}]
}

# The result type of a call of a native with -result-shape SHAPE on the
# arguments ARG-EXPRS of types ARG-TYPES, given its declared result type
# RESULT.
proc hir::types::ShapeResult {hir shape argExprs argTypes result {ctx {}}} {
    switch -- [lindex $shape 0] {
        never {
            # context#unreachable (core/contexts.tcl): never completes.
            return never
        }
        coroutine-create - coroutine-outward - coroutine-yield {
            # The coroutine operations (core/coroutines.tcl): typed from the
            # program's coroutine analysis (hir/coroutines.tcl), in CTX, the
            # typing context (a semantic instance's walk types a trait-
            # polymorphic function's yields and constructions as its
            # specialization).
            return [hir::coroutines::ShapeResult $hir [lindex $shape 0] $argExprs $argTypes $ctx]
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
        layout-struct {
            # std::binary::parse(L, data) (core/binary.tcl, BINARY-LAYOUT.md): a
            # LayoutStruct[L], L the layout argument I's descriptor
            # constant describes (hir/resolve.tcl's LayoutOperand).
            set arg [lindex $argExprs [lindex $shape 1]]
            if {$arg ne "" && [hir::kind $hir $arg] eq "const"} {
                set id [hir::layouts::DescriptorLayout [lindex [hir::get $hir $arg literal] end]]
                if {$id ne "" && [hir::layouts::declared $id] && ![hir::layouts::HoldsUnion $id]} {
                    # (A union, or a layout holding one, has no LayoutStruct:
                    # LAYOUT-UNIONS.md.)
                    return [hir::layouts::structType $id]
                }
            }
            return $result
        }
        native-view {
            # std::binary::native::view(L, p) (core/binary.tcl,
            # NATIVE-LAYOUT-VIEWS.md): a NativeView[L], L the layout argument
            # I's descriptor constant describes.
            set arg [lindex $argExprs [lindex $shape 1]]
            if {$arg ne "" && [hir::kind $hir $arg] eq "const"} {
                set id [hir::layouts::DescriptorLayout [lindex [hir::get $hir $arg literal] end]]
                if {$id ne "" && [hir::layouts::declared $id]} {
                    return [hir::layouts::viewType $id]
                }
            }
            return $result
        }
        native-edit {
            # std::binary::native::edit(L, p) (NATIVE-LAYOUT-WRITES.md): a
            # NativeEdit[L], L the layout argument I's descriptor constant
            # describes.
            set arg [lindex $argExprs [lindex $shape 1]]
            if {$arg ne "" && [hir::kind $hir $arg] eq "const"} {
                set id [hir::layouts::DescriptorLayout [lindex [hir::get $hir $arg literal] end]]
                if {$id ne "" && [hir::layouts::declared $id]} {
                    return [hir::layouts::editType $id]
                }
            }
            return $result
        }
        view-field {
            # binary#view_field(v, FIELD), the elaborated field read of a
            # native view: the field's view type (hir::layouts::
            # ViewFieldType) when V's static type is a view -- what an
            # instance's re-inference recovers (hir/specialize.tcl).
            # (Through a NativeEdit[L] a nested layout is an edit too:
            # NATIVE-LAYOUT-WRITES.md.)
            lassign $shape _ v f
            set id [hir::layouts::OfNativeType [lindex $argTypes $v]]
            set arg [lindex $argExprs $f]
            if {$id ne "" && $arg ne "" && [hir::kind $hir $arg] eq "const"} {
                set t [hir::layouts::NativeFieldType [lindex $argTypes $v] [lindex [lindex [hir::get $hir $arg literal] end] 0]]
                if {$t ne ""} {
                    return $t
                }
            }
            return $result
        }
        view-struct {
            # std::binary::load(v): the LayoutStruct[L] of argument I's static
            # NativeView[L] (or NativeEdit[L]) type -- or, of a live fixed
            # array NativeView[array N of E], the List its copy is
            # (FIXED-LAYOUT-ARRAYS.md).
            set argType [lindex $argTypes [lindex $shape 1]]
            set id [hir::layouts::OfNativeType $argType]
            if {$id ne "" && ![hir::layouts::HoldsUnion $id]} {
                return [hir::layouts::structType $id]
            }
            if {$id ne ""} {
                # (LAYOUT-UNIONS.md: no copied value.)
                return $result
            }
            set term [hir::layouts::OfArrayType $argType]
            if {$term ne ""} {
                return [hir::layouts::TermConsumerType $term]
            }
            return $result
        }
        layout-read {
            # std::binary::read(data, L.path) (LAYOUT-UNIONS.md): the copied type
            # of the representation the designator constant argument I
            # names -- a scalar's domain, LayoutStruct[R], a List.
            set arg [lindex $argExprs [lindex $shape 1]]
            if {$arg ne "" && [hir::kind $hir $arg] eq "const"} {
                set repr [hir::layouts::PathField [lindex [hir::get $hir $arg literal] end]]
                if {$repr ne ""} {
                    # (A copy: a List states its array's extent,
                    # hir::layouts::CopyType.)
                    return [hir::layouts::CopyType $repr]
                }
            }
            return $result
        }
        native-element {
            # std::binary::element(a, i) (FIXED-LAYOUT-ARRAYS.md): the element of
            # argument I's static live array type, read in place (a scalar,
            # a pointer, or a nested layout's or array's live view or edit).
            set t [hir::layouts::ElementType [lindex $argTypes [lindex $shape 1]]]
            if {$t ne ""} {
                return $t
            }
            return $result
        }
        named-struct {
            # A struct of one named declaration (core/native.tcl's
            # {named-struct ID}: std::linux::abi::x86_64::syscall's std::abi::x86_64::
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
            if {$elem eq ""} {
                # Nothing known: no element to describe.
                return $result
            }
            if {$elem eq "never"} {
                # A List[never] is empty (no value has type never), so no
                # read of it completes normally. The native's declared
                # result here would be wider than the element type of any
                # List it is a subtype of: an instance entered with `[]`
                # for a `List[S]` parameter would type an element read
                # `any` where the declared contract's analysis has `S`,
                # and reject a body valid for its contract
                # (OPPORTUNISTIC-SEMANTIC-INSTANCES.md: a narrower
                # argument may only add precision).
                return never
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
            set list [Unrefined [lindex $argTypes $l]]
            if {[IsList $list]} {
                return [MakeList [lub [lindex $list 1] [lindex $argTypes $v]]]
            }
            return $result
        }
        immutable-set {
            # List[T] -> ImmutableSet[T] (MINIMAL-IMMUTABLE-SET.md item 24):
            # std::immutable_set::from_list's own -result-shape. Generic over T
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
        mutarray-create {
            # (n, x : T) -> MutableArray[T] (MUTABLE-ARRAY.md): T the static
            # type of the repeated value, also for capacity 0 -- its
            # ordinary type, never an exact-value fact
            # (hir::containers::ElementContract).
            lassign $shape _ v
            return [MakeMutArray [hir::containers::ElementContract [lindex $argTypes $v]] 0]
        }
        mutarray-from-list {
            # List[T] -> MutableArray[T]; a broad `list` (no element type),
            # List[any] and the empty literal give MutableArray[any] -- a
            # fully initialized array whose contract is the whole `any`
            # domain, never the raw substrate type.
            lassign $shape _ l
            set list [Unrefined [Unshaped [lindex $argTypes $l]]]
            set elem any
            if {[IsList $list]} {
                set elem [hir::containers::ElementContract [lindex $list 1]]
            }
            return [MakeMutArray $elem 0]
        }
        mutarray-generate {
            # (n, factory) -> MutableArray[T], T what the factory's callable
            # contract returns (each slot holds one call's result); a
            # factory of unknown contract gives MutableArray[any].
            lassign $shape _ f
            return [MakeMutArray [hir::containers::ElementContract [CallableResult [lindex $argTypes $f]]] 0]
        }
        mutvec-from-list {
            # List[T] -> MutableVector[T] (MUTABLE-VECTOR.md); the empty
            # literal's List[never] gives the proven-empty MutableVector[never].
            lassign $shape _ l
            set list [Unrefined [lindex $argTypes $l]]
            if {[IsList $list]} {
                # (The element contract a MutableVector's pushes are held to
                # forgets what inference minted about its first elements:
                # a vector of [[1, 2]] takes any List[int].)
                return [MakeMutVec [ForgetInferred [lindex $list 1]] 0]
            }
            if {$list eq "never"} {
                return never
            }
            return [MakeMutVec any 0]
        }
        mutvec-element {
            # MutableVector[T] -> T: an element read (at) or removal (pop,
            # take, swap's displaced element).
            lassign $shape _ v
            set vector [lindex $argTypes $v]
            if {[IsMutVec $vector] && [lindex $vector 1] ne "never"} {
                return [lindex $vector 1]
            }
            # (An element read of MutableVector[never]: see
            # IterationElementOf.)
            return $result
        }
        mutvec-to-list {
            # MutableVector[T] -> List[T]: a snapshot of the elements.
            lassign $shape _ v
            set vector [lindex $argTypes $v]
            if {[IsMutVec $vector] && [lindex $vector 1] ne "never"} {
                return [MakeList [lindex $vector 1]]
            }
            return $result
        }
        same {
            # The result is argument A's own value, logically copied
            # (mutable_vector#share): its type.
            lassign $shape _ a
            return [lindex $argTypes $a]
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
            # std::str::encode_utf8's every UTF-8 code unit is definitionally in
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
            # 0..15` must not make std::str::encode_utf8's result List[Byte] just
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
            # AUDIT.md's std::str::encode_utf8/List[Byte] finding).
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
# never if some expression never completes normally, else the last type. A
# poisoned expression (Poison, above) is no divergence: what follows it stays
# reachable, and the sequence is poison when it ends in one -- recorded in
# CTX's `poisonResult` (1 or 0) for the caller that needs to tell (Block, If,
# the loops).
proc hir::types::Sequence {hirVar ctxVar exprs} {
    upvar 1 $hirVar hir $ctxVar ctx
    set entry [dict get $ctx reachable]
    set result unit
    set halted 0
    set poison 0
    foreach e $exprs {
        set type [Expr hir ctx $e]
        if {!$halted} {
            set result $type
            set poison [expr {$type eq "never"}]
        }
        if {$type eq "never" && [Halts $hir $e $type]} {
            set halted 1
            set poison 0
            dict set ctx reachable 0
        }
    }
    dict set ctx reachable $entry
    dict set ctx poisonResult $poison
    return $result
}

# Types expression E. Returns its type.
proc hir::types::Expr {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    if {[dict exists $hir syntaxDependent $e] && ![dict exists $ctx spec]} {
        return [Dependent hir ctx $e]
    }
    set node [dict get $hir exprs $e]
    dict set hir exprs $e reachable [dict get $ctx reachable]
    switch -- [dict get $node kind] {
        const {
            if {[dict exists $node decimalExpected]} {
                # The root of a DecimalRounded constant expression: the type
                # its position expects, which hir::decimal::verify proves.
                return [SetType hir $e [dict get $node decimalExpected]]
            }
            if {[dict exists $ctx spec]} {
                return [SetType hir $e [AggregateOfValue [dict get $node value]]]
            }
            return [SetType hir $e [ofValue [dict get $node value]]]
        }
        ref {
            if {[dict exists $node hole] && ![dict exists $ctx spec]} {
                # Source the front end could not read
                # (SYNTAX-RECOVERY-MILESTONE-1.md): an unknown value --
                # poison, never a divergence.
                return [SetType hir $e [Poison hir $e]]
            }
            if {[dict get $node binding] eq ""} {
                return [SetType hir $e never]
            }
            set type [BindingType $hir $ctx [dict get $node binding]]
            if {$type eq "never" && [Poisoned $hir [dict get $node binding]]} {
                # A poisoned binding's value (Bind).
                Poison hir $e
            }
            return [SetType hir $e $type]
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
            set elemType [hir::iteration::ElementOf $hir [hir::typeOf $hir [dict get $node iterable]]]
            set poison [Poisoned $hir [dict get $node iterable]]
            if {$poison} {
                # A poisoned iterable: its element is poison too, and the
                # body is walked as reachable code (it may still run).
                set elemType never
                Poison hir [dict get $node elementBinding]
            } elseif {$elemType eq ""} {
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
            set entry [dict get $ctx reachable]
            if {$elemType eq "never" && !$poison} {
                # The iterable is a List[never], which only an empty List
                # ever is (M7AA-EMPTY-COLLECTION-AND-APPLIED-TYPE-
                # SEMANTICS.md): the body never runs. It is walked like a
                # decided `if`'s dead arm (If, below), unreachable, and the
                # loop is exactly the empty List, whatever the body's type:
                # that type describes an iteration whose element would be a
                # `never`, a value that cannot exist (a handled call of it is
                # typed by its handlers' join, Handle: `b = std::byte::from_int(v):
                # on ...: 0` an Int, so `[b]` a List[int], not a List[Byte]).
                dict set ctx reachable 0
            }
            set bodyType [Sequence hir ctx [dict get $node body]]
            dict set ctx reachable $entry
            dict unset ctx breakTypes $e
            dict set ctx facts $saved
            if {$poison} {
                return [SetType hir $e [Poison hir $e]]
            }
            return [SetType hir $e [LoopResult $hir $ctx $e [MakeList [if {$elemType eq "never"} {string cat "never"} else {set bodyType}]] \
                [list [list list [hir::typeOf $hir [dict get $node iterable]]]]]]
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
            return [SetType hir $e [LoopResult $hir $ctx $e [MakeList $bodyType] \
                [list [list count [lindex [hir::cardinality::domains $hir $e] 0]]]]]
        }
        lockloop {
            # Every domain's operands are typed in written order in the
            # enclosing scope; each domain binding is then typed like the
            # single-domain loop's own (an element's type, or exactly Int).
            # The result is the same collected List[R] as any collecting
            # loop's.
            set facts {}
            set empty 0
            set poison 0
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    Expr hir ctx [dict get $domain iterable]
                    set elemType [hir::iteration::ElementOf $hir [hir::typeOf $hir [dict get $domain iterable]]]
                    if {[Poisoned $hir [dict get $domain iterable]]} {
                        # (listloop's poisoned iterable.)
                        set poison 1
                        lappend facts [dict get $domain binding] never
                        Poison hir [dict get $domain binding]
                        continue
                    }
                    lappend facts [dict get $domain binding] [if {$elemType eq ""} {string cat "any"} else {set elemType}]
                    # An empty domain (listloop's case): every domain has
                    # the one proven cardinality, so the body never runs.
                    set empty [expr {$empty || $elemType eq "never"}]
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
            set entry [dict get $ctx reachable]
            if {$empty} {
                dict set ctx reachable 0
            }
            set bodyType [Sequence hir ctx [dict get $node body]]
            dict set ctx reachable $entry
            dict unset ctx breakTypes $e
            dict set ctx facts $saved
            if {$poison} {
                return [SetType hir $e [Poison hir $e]]
            }
            set clauses {}
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    lappend clauses [list list [hir::typeOf $hir [dict get $domain iterable]]]
                } else {
                    lappend clauses [list count $domain]
                }
            }
            return [SetType hir $e [LoopResult $hir $ctx $e [MakeList [if {$empty} {string cat "never"} else {set bodyType}]] $clauses]]
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
            if {$value eq "never" && [Poisoned $hir [dict get $node value]]} {
                return [SetType hir $e [Poison hir $e]]
            }
            return [SetType hir $e [expr {$value eq "never" ? "never" : "result"}]]
        }
        fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                # The payload (ERROR-PAYLOADS.md): evaluated, then raised.
                Expr hir ctx [dict get $node value]
            }
            return [SetType hir $e never]
        }
        handle {
            return [SetType hir $e [Handle hir ctx $e]]
        }
    }
}

# RESULT, the List a collecting loop E (listloop, countloop, lockloop)
# completes with, refined by its exact length (Refine) when that is known:
# no break or continue targets E (hir::cardinality::Exact: every normal
# completion collects one element per iteration), and one of its domains
# CLAUSES -- {list TYPE}, an iterable of static TYPE; {count DOMAIN}, a
# numeric domain (hir::cardinality::domains) -- has an exact cardinality:
# the length TYPE states, or a numeric domain whose cardinality form is a
# constant (hir::cardinality::of_domain: exactly known bounds). A lockstep
# loop's domains have one cardinality, proven (hir/lockstep.tcl), so any
# one decides. The existing proven cases only (COLLECTING-LOOPS.md); no new
# loop reasoning. Region inference (CTX's `spec`) keeps the List it always
# had, as a call of a native does (MintLength).
proc hir::types::LoopResult {hir ctx e result clauses} {
    if {[dict exists $ctx spec] || ![hir::cardinality::Exact $hir $e]} {
        return $result
    }
    foreach clause $clauses {
        lassign $clause kind what
        if {$kind eq "list"} {
            set n [LengthOf $what]
        } else {
            set form [hir::cardinality::of_domain $hir $what]
            set n ""
            if {[hir::cardinality::IsConst $form]} {
                set n [lindex $form 0]
            }
        }
        if {$n ne ""} {
            return [Refine $result List [list length $n]]
        }
    }
    return $result
}

# Types struct construction E (STRUCTS.md). The field expressions are typed
# in WRITTEN order -- the order they evaluate in; the canonical layout never
# reorders anything -- and, like a call's arguments, an expression that never
# completes normally makes the whole construction never (no struct value is
# built). A named construction has its declared type, whatever its values are
# (the declaration is the contract; hir::range::VerifyStruct proves each value
# admissible); an anonymous one has the canonical structural type of its
# fields' own types.
# The application of parameterized struct ID that the construction E with
# field value types FIELDTYPES (name -> type) makes when none is written
# (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): each slot established by the
# values of the fields that hold it, exactly as a call's arguments
# establish its imprint variables (hir::imprint::MatchInner, the inferred
# List lengths forgotten), a bare `value: T` field included. A slot no field
# establishes (only an empty List or a function's type says it), or two
# fields that establish differently, is the construction's IMPRINT problem
# (recorded on E as structInferProblem, diagnosed by hir::imprint::verify):
# the type is then "" (the construction is poison), and the application
# must be written.
proc hir::types::InferApplication {hirVar e id fieldTypes} {
    upvar 1 $hirVar hir
    set binding [dict create]
    set problem ""
    set index 0
    foreach name [hir::structs::names $id] {
        incr index
        set declared [hir::structs::fieldType $id $name]
        if {$declared eq "" || ![dict exists $fieldTypes $name] || ![hir::imprint::Mentions $declared]} {
            continue
        }
        set value [dict get $fieldTypes $name]
        set problem [hir::imprint::MatchInner $declared $value binding $index]
        if {$problem ne ""} {
            set problem [format {the construction %s {...} cannot establish its type slots from field "%s": %s} \
                [hir::structs::display $id] $name [regsub {argument ([0-9]+)} $problem {field \1}]]
            break
        }
    }
    set slots [hir::structs::slots $id]
    if {$problem eq ""} {
        foreach slot $slots {
            if {![dict exists $binding $slot] || [dict get $binding $slot] eq "never"} {
                set problem [format {the construction %s {...} does not establish type slot %s from its field values (no field holds a value whose type says what %s is): write the application, %s[%s] {...}} \
                    [hir::structs::display $id] $slot $slot [hir::structs::display $id] [join $slots {, }]]
                break
            }
        }
    }
    if {$problem ne ""} {
        if {[dict getdef $hir exprs $e structInferProblem ""] ne $problem} {
            dict set hir exprs $e structInferProblem $problem
        }
        return ""
    }
    if {[dict exists $hir exprs $e structInferProblem]} {
        dict unset hir exprs $e structInferProblem
    }
    # (A slot is a type a declaration could state: an exact function's
    # identity is no part of it, its structural contract is --
    # Box {value: f} is a Box[Fn{...}], as Box[Fn{...}] {value: f} is.)
    return [MakeApplied $id [lmap slot $slots {Presentable [dict get $binding $slot]}]]
}

proc hir::types::Struct {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set entry [dict get $ctx reachable]
    set dead 0
    set poison 0
    set fieldTypes [dict create]
    foreach name [dict get $node names] child [dict get $node fields] {
        set type [Expr hir ctx $child]
        if {$type eq "never" && [Halts $hir $child $type]} {
            set dead 1
            dict set ctx reachable 0
        } elseif {$type eq "never"} {
            set poison 1
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
        # (A poisoned field value leaves a named construction its declared
        # type: the declaration is the contract.)
        set id [dict get $node structId]
        if {$id eq ""} {
            return "any"
        }
        if {[hir::structs::isParameterized $id]} {
            # A parameterized struct's construction (TRAIT-CONSTRAINED-
            # IMPRINTED-TYPES.md): an explicit application, Pair[int, str]
            # {...} -- the declaration is the contract, its slots the
            # written arguments -- or the one its field values establish.
            # An application that is invalid (a constrained slot's argument
            # does not satisfy its trait) or not established is poison: no
            # context makes it valid, and its diagnostic is the
            # construction's (hir::structs::verifyApplications,
            # hir::imprint::verify).
            if {[dict exists $node structArgs]} {
                set type [MakeApplied $id [dict get $node structArgs]]
            } else {
                set type [InferApplication hir $e $id $fieldTypes]
                if {$type eq ""} {
                    return [Poison hir $e]
                }
            }
            set problem [hir::structs::ApplicationProblem $type]
            if {$problem ne ""} {
                if {[dict getdef $hir exprs $e structApplicationProblem ""] ne $problem} {
                    dict set hir exprs $e structApplicationProblem $problem
                }
                return [Poison hir $e]
            }
            if {[dict exists $hir exprs $e structApplicationProblem]} {
                dict unset hir exprs $e structApplicationProblem
            }
            return $type
        }
        return [list nstruct $id]
    }
    if {[dict exists $node payloadOf] && [hir::errordecls::hasPayload [dict get $node payloadOf]]} {
        # An error's payload (ERROR-PAYLOADS.md) has its declared type,
        # whatever its values are -- the declaration is the contract, as a
        # named construction's (hir::range::VerifyStruct proves each value
        # admissible) -- the anonymous struct type of the declared fields.
        return [hir::errordecls::payloadType [dict get $node payloadOf]]
    }
    if {$poison} {
        # An anonymous struct's type is its fields': one of them is poison.
        return [Poison hir $e]
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
        if {[Poisoned $hir [dict get $node receiver]]} {
            return [Poison hir $e]
        }
        return never
    }
    if {[dict exists $node methodRejected]} {
        # The written callee of a rejected method-style call (hir/resolve.tcl's
        # MethodChoice): no candidate was established, so the call computes
        # nothing the program knows -- poison, whatever the receiver's
        # fields (METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md).
        return [ProjectionFailed hir $ctx $e]
    }
    set name [dict get $node name]
    # A projection hir::structs::ProjectionProblem rejects in every context
    # (NOT-A-STRUCT, UNKNOWN-FIELD, OPAQUE-REPRESENTATION; a method-style
    # call with no function of its name visible is one) has no value to
    # type: in region inference it always raises (never); in the generic
    # walk and a semantic instance's it is poison (above), so no later check
    # restates it -- never the `any` that made a missing import surface as a
    # type error elsewhere. Unreachable code keeps `any`: nothing is reported
    # there, and poison exists only where its diagnostic does.
    if {[hir::structs::projectionDenied $receiver $node]
            || [hir::structs::PrivateRepresentation $hir $receiver $node] ne ""} {
        # No authority over an opaque receiver's representation, or over a
        # private declaration of another module (hir/privacy.tcl)
        # (OPAQUE-STRUCTS.md; hir::structs::ProjectionProblem rejects it): the
        # access is typed as if no such field were known, never with the
        # hidden field's declared type, so the representation cannot leak
        # through the types of the program's later diagnostics.
        return [ProjectionFailed hir $ctx $e]
    }
    if {[IsStructLike $receiver]} {
        set t [StructField $receiver $name]
        if {$t ne ""} {
            # A field of an exact copy of a layout -- what std::binary::parse or
            # std::binary::load made, or a field of one (hir::completions::
            # ExactCopy) -- holds a copy of the field's representation: its
            # arrays' Lists have exactly their extents (hir::layouts::
            # CopyType, LIST-CARDINALITY-REFINEMENTS.md). A LayoutStruct
            # constructed by the program may hold any List there.
            set copy [hir::completions::ExactCopy $hir [dict get $node receiver]]
            if {$copy ne "" && [dict get $copy kind] eq "layout"} {
                set copied [hir::layouts::CopiedFieldType [dict get $copy layout] $name]
                if {$copied ne ""} {
                    return $copied
                }
            }
            return $t
        }
        return [ProjectionFailed hir $ctx $e]
    }
    set layout [hir::layouts::OfNativeType $receiver]
    if {$layout ne ""} {
        # A field read through a native view (NATIVE-LAYOUT-VIEWS.md): the
        # field's view type, read at run time from the memory the view
        # addresses. (Through a native edit the same read; a nested layout
        # an edit of it: NATIVE-LAYOUT-WRITES.md.)
        set t [hir::layouts::NativeFieldType $receiver $name]
        if {$t ne ""} {
            return $t
        }
        return [ProjectionFailed hir $ctx $e]
    }
    if {[kindOf $receiver] ni {"" struct}} {
        return [ProjectionFailed hir $ctx $e]
    }
    return any
}

# The type of the projection E that hir::structs::ProjectionProblem rejects
# in every context (Project): never in region inference, poison in reachable
# code of semantic inference, else `any`.
proc hir::types::ProjectionFailed {hirVar ctx e} {
    upvar 1 $hirVar hir
    if {[dict exists $ctx spec]} {
        return never
    }
    if {[MakesPoison $hir $ctx] && [dict get $ctx reachable]} {
        return [Poison hir $e]
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
    set outerLog [dict getdef $ctx completionLog ""]
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
    # A poisoned handled call: its handlers are walked as ever (each may
    # still run), and the construct is poison.
    set poison [expr {$callType eq "never" && [Poisoned $hir [dict get $node call]]}]
    if {$callType ne "never" || $poison} {
        set ends [list $completed]
    } else {
        set ends {}
    }
    set payloads [dict getdef $node handlerPayloads {}]
    set index 0
    foreach body [dict get $node handlerBodies] name [dict get $node handlerNames] {
        set payload [lindex $payloads $index]
        incr index
        if {$payload ne "" && [hir::errordecls::hasPayload $name]} {
            # The handler's payload binding (ERROR-PAYLOADS.md) holds the
            # selected error's payload: its declared type, known statically
            # from the error's identity alone.
            set payloadType [hir::errordecls::payloadType $name]
            dict set ctx types $payload $payloadType
            dict set hir bindings $payload type [intern hir $payloadType]
        }
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
    if {$poison} {
        return [Poison hir $e]
    }
    if {$callType ne "never"} {
        # hir/completions.tcl's admissibility check holds every live
        # handler to CALLTYPE in the generic analysis, which is what makes
        # CALLTYPE alone the construct's type there. A semantic instance can
        # type the call more precisely than its handlers, though: in
        # `fn explicit(xs, i, d): v = std::list::at(xs, i): on IndexNotFound: d`
        # (stdlib/list.bot's std::list::get), the generic call is `any` and `d` is
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
        if {$result eq "any" && $callType ne "any" && [MakesPoison $hir $ctx] && ![dict exists $ctx inst] && $entry} {
            # A handler with no type in common with the call: inadmissible,
            # which hir/completions.tcl reports. The generic walk makes the
            # construct poison (above), never the `any` that would restate
            # the handler's error wherever the value is used
            # (DIAGNOSTIC-RECOVERY.md).
            return [Poison hir $e]
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
    if {$value eq "never" && [Poisoned $hir $valueExpr]} {
        # A poisoned value: so is its binding, whose every reference is
        # poison, and so is the bind (no divergence).
        if {$typed} {
            dict set ctx types $b never
            dict set hir bindings $b type [intern hir never]
            Poison hir $b
        }
        return [Poison hir $e]
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
    if {$self eq ""} {
        set selfType ""
    } else {
        set selfType [blockType $hir $e $arity any]
    }
    if {[dict exists $outer spec]} {
        # Region inference: the body is a region of its own. Report what
        # this creation captures; calls of the block ask the handler.
        set seeds [dict create]
        foreach b [dict get $node captures] {
            dict set seeds $b [if {$b eq $self} {set selfType} else {BindingType $hir $outer $b}]
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
    if {$declared eq {} || [IsTraitConstraint $declared]} {
        set assumed {never}
    } else {
        set assumed $declared
    }
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
        set poison [dict get $ctx poisonResult]
        set result [lub $body [dict get $ctx returnType]]
        if {$self eq "" || $result eq $assumed || $assumed eq "any"} {
            break
        }
        set assumed $result
    }
    if {($result eq "never" && $poison)
            || ($declared eq {} && [dict exists $hir holeBlocks $e] && ![dict exists $outer spec])} {
        # Its every normal completion is poison (no `return` contributes):
        # so is every call's result (Call), never a divergence. Likewise when
        # its body holds a hole and it declares no result: a malformed
        # statement may return anything (SYNTAX-RECOVERY-MILESTONE-1.md).
        set result never
        Poison hir $e
    } elseif {[dict exists $hir poisoned $e]} {
        dict unset hir poisoned $e
    }
    dict set hir exprs $e inferredResultType [intern hir $result]
    if {$declared ne {}} {
        set result [hir::traits::ViewResult $declared $result]
    } else {
        # An undeclared result is the function's contract only in what a
        # declaration could have said: a fact inference minted (a List
        # literal's length) is the implementation's, never its callers'
        # (ForgetInferred; LIST-CARDINALITY-REFINEMENTS.md, "Function
        # contracts"). The inferred result keeps it: verifyDeclaredResults
        # and the body's own analyses read that one.
        set result [ForgetInferred $result]
    }
    dict set hir exprs $e resultType [intern hir $result]
    return [blockType $hir $e $arity $result]
}

proc hir::types::Call {hirVar ctxVar e} {
    upvar 1 $hirVar hir $ctxVar ctx
    set node [dict get $hir exprs $e]
    set entry [dict get $ctx reachable]
    # DEAD: no result to type (a callee or argument never completes, or is
    # poison); HALTS: the call never completes normally. A poisoned callee
    # or argument makes the call poison and leaves its later arguments
    # reachable, each typed and checked on its own.
    set dead 0
    set halts 0
    set types {}
    foreach child [concat [list [dict get $node callee]] [dict get $node args]] {
        set type [Expr hir ctx $child]
        lappend types $type
        if {$type eq "never" && [Halts $hir $child $type]} {
            set halts 1
            dict set ctx reachable 0
        }
        if {$type eq "never"} {
            set dead 1
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
            if {[dict exists $hir exprs $e traitCall unknown] && [MakesPoison $hir $ctx] && [dict get $ctx reachable]} {
                # An operation the receiver's trait does not declare
                # (TRAIT-UNKNOWN-OPERATION, hir/traits.tcl): no value to type,
                # poison like a failed method call -- never its `any` stand-in.
                set dead 1
            }
            if {$dead} {
                return [CallResult hir $e [expr {$halts || $spec}]]
            }
            return $result
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
            if {!$dead && [dict exists $node resolvedOperator] && [MakesPoison $hir $ctx] && [dict get $ctx reachable]
                    && [hir::operators::Mismatched $argTypes [lindex [dict get $node resolvedOperator] 1]]} {
                # An operand of another kind than the floating-point type its
                # operator selected (hir/operators.tcl's verify reports it):
                # the operation has no value -- poison.
                set dead 1
            }
            if {!$dead && [MakesPoison $hir $ctx] && [dict get $ctx reachable]
                    && [hir::decimal::Unprovable $hir $e]} {
                # DecimalRounded arithmetic no proof can give a guarantee
                # (DECIMAL-GUARANTEE-LOST, hir/decimal.tcl): no value.
                set dead 1
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
                # (list/std::list::at/std::list::append, core/lists.tcl,
                # core/primitives.tcl) carry or recover a concrete List[T]
                # applied type with no List-specific inference code of its
                # own (MINIMAL-APPLIED-LIST-TYPES.md).
                set result [ShapeResult $hir [dict get $meta resultShape] $argExprs $argTypes $result $ctx]
                set shapeKind [lindex [dict get $meta resultShape] 0]
                if {[MakesPoison $hir $ctx] && [dict get $ctx reachable]
                        && (($shapeKind eq "view-struct" && [hir::layouts::OfType $result] eq ""
                                && [hir::layouts::OfArrayType [lindex $argTypes 0]] eq "")
                            || ($shapeKind eq "view-struct" && [hir::layouts::NativeUnionRefusal [lindex $argTypes 0]] ne "")
                            || ($shapeKind eq "native-element" && [hir::layouts::OfArrayType [lindex $argTypes 0]] eq "")
                            || ($shapeKind eq "layout-struct" && [hir::layouts::RoleOf [dict get $meta layout] op] eq "parse"
                                && [LayoutParseRefused $hir $argExprs [dict get $meta resultShape]])
                            || ($shapeKind eq "layout-read" && [LayoutReadRefused $hir $argExprs [dict get $meta resultShape]]))} {
                    # std::binary::load of a value not statically a NativeView[L]
                    # (BINARY-OPERAND), or std::binary::parse of a native-only
                    # layout (LAYOUT-NATIVE-ONLY: hir::layouts::verify): no
                    # LayoutStruct is ever produced (NATIVE-LAYOUT-VIEWS.md).
                    # Nor of a union, or of anything holding one by value
                    # (LAYOUT-UNION), and std::binary::read never makes a pointer
                    # or a union (LAYOUT-UNIONS.md).
                    set result [Poison hir $e]
                }
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
            if {!$dead && !$spec && [dict get $meta resultLength] ne ""} {
                # The exact length of a returned List, stated by the
                # native's registration (core/native.tcl's -result-length):
                # a List literal's argument count, std::list::append's one more
                # than its List's, a live fixed array's copy -- minted as
                # the refinement List[T]{length: N} (LIST-CARDINALITY-
                # REFINEMENTS.md), the one representation of exact List
                # cardinality. Region inference keeps its positional
                # shapes, which state their length themselves.
                set result [MintLength $hir [dict get $meta resultLength] $argExprs $argTypes $result]
            }
            set foreign [dict get $meta foreign]
            if {[dict get $meta imprint] ne ""} {
                # An intrinsic's imprint signature (hir/imprint.tcl): its
                # result imprinted for this call (std::ffi::c::null[T]()). A byte
                # owner exposed to a foreign pointer parameter establishes
                # no pointee (hir/borrow.tcl).
                set result [hir::imprint::Call hir $e $calleeType \
                    [if {$foreign eq ""} {set argTypes} else {hir::borrow::ImprintArgTypes $foreign $argTypes}] \
                    [dict get $meta imprint result] $result]
            } elseif {[dict exists $node imprint]} {
                hir::imprint::Call hir $e $calleeType $argTypes $result $result
            }
            if {$foreign ne ""} {
                # A foreign call contract (hir/borrow.tcl): the call's byte
                # exposures, recorded on the node, and its type -- the C
                # result, or the write-back struct of the bytes C wrote.
                set result [hir::borrow::Type hir $e $meta $argTypes]
            }
            if {[dict exists $node decimalExpected]} {
                # The root of a DecimalRounded constant expression: the type
                # its position expects, which hir::decimal::verify proves.
                set result [dict get $node decimalExpected]
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
                # (No call of a Botlish function is typed by a precomputed
                # rule instead of its body: MutableArray's relational
                # constructors are intrinsics, MUTABLE-ARRAY.md.)
                if {!$spec && ([dict get $ctx reachable] || [hir::traits::IsPolymorphic $hir $block])
                        && ![dict exists $hir holeBlocks $block]} {
                    # (Never an instance of a function whose body holds a
                    # hole: what its body proves is not known, only its
                    # declared contract -- SYNTAX-RECOVERY-MILESTONE-1.md.)
                    # (A call of a trait-polymorphic function always gets its
                    # instance, reachable or not: its witnesses decide which
                    # specialization the call is, TRAITS.md.)
                    # An opportunistic semantic instance of the callee
                    # (hir/semantic.tcl): its ordinary body analyzed under
                    # this call's concrete argument types. The call is
                    # typed with what that analysis proves; the callee's own
                    # contract and generic result are untouched.
                    set result [hir::semantic::Call $hir $ctx $e $block $argTypes $result]
                    if {$result eq "never" && [hir::semantic::PoisonedCall $ctx $e]} {
                        # The instance's every normal completion is poison.
                        set dead 1
                    }
                }
            }
            # A function with imprint variables (hir/imprint.tcl): the
            # result imprinted for this call (its body's own type for them is
            # rigid).
            set result [hir::imprint::Call hir $e $calleeType $argTypes $result any]
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
    } elseif {[IsCoroutine $calleeType]} {
        # A call of a coroutine handle (AFFINE-VALUES.md): the coroutine
        # callable kind -- a resume of its one execution -- typed from the
        # same callable contract a structural Fn has: what each resume
        # returns, and (calleeErrors below) which declared errors may cross
        # it. Its messages are held to the contract's arguments by the same
        # check (hir::range::VerifyStructuralCall), and it lowers to the
        # coroutine resume (hir::coroutines::ElaborateResumes), never to a
        # call of a function value.
        set protocol [CoroutineResume $calleeType]
        if {$protocol eq "any" || [llength [dict get [lindex $calleeType 1] args]] == [llength $argExprs]} {
            set result [CoroutineOutward $calleeType]
        } elseif {$spec} {
            set dead 1
        }
    } elseif {$spec && [kindOf $calleeType] ni {"" block native coroutine}} {
        # Not callable: the call always raises NOT-CALLABLE.
        set dead 1
    }
    if {$target eq "" && [dict exists $node imprint]} {
        # Explicit imprints on a callee that is not statically known.
        hir::imprint::Call hir $e $calleeType $argTypes $result $result
    }
    dict set hir exprs $e target $target
    dict set hir exprs $e known $known
    # The declared errors this call may propagate (EXPLICIT-ERROR-
    # COMPLETIONS.md), for hir/errorsets.tcl. Only an exact, directly-known
    # callee (target {block ExprId}, or a root native whose registry entry
    # declares -errors: `argv`) or a structural one is charged with a
    # nonempty set here. For a structural Fn or Coroutine callee it is the
    # callable contract's declared error set: a valid semantic upper bound,
    # because every value of that type was checked against the contract
    # where it acquired it -- its declared errors by subtyping, what it
    # raises through a callable it captured or receives by the verified
    # contract boundary (hir/completions.tcl's Subsume) -- so no other error
    # is ever added to it. Any other callee (an unresolved dynamic dispatch
    # through any/a bare kind: uncontracted) is charged none at this type
    # level. That is not a proof it raises nothing -- unknown never means
    # empty: hir/callables.tcl's escape audit rejects every erasure of an
    # error-bearing callable except into an untyped parameter of a semantic
    # instance (hir/semantic.tcl) or of a callable given a structural type,
    # so such a callee may be one after all. The completion analysis
    # (hir/completions.tcl, "Precision and the erased-callable contract") and
    # hir/affine.tcl's error edges charge what it may raise.
    set calleeErrors {}
    if {[lindex $target 0] eq "block"} {
        set calleeErrors [dict get $hir exprs [lindex $target 1] declaredErrors]
    } elseif {[lindex $target 0] eq "native"} {
        # A root native declares errors only through its registry entry
        # (-errors: `argv`'s InvalidArgumentEncoding) -- except a coroutine
        # segment (start, resume: COROUTINES.md), which ends with whatever
        # declared error its body lets escape, as the handle's type says.
        set name [dict get [hir::symbol $hir [lindex $target 1]] name]
        set meta [core::native::metadata $name]
        # (A layout operation's NonFiniteFloat only where its layout holds a
        # C floating field it reads, or a binary32 one it writes:
        # C-FLOAT-FFI-MILESTONE-1.md.)
        set calleeErrors [hir::layouts::CallErrors $hir $name $argExprs $argTypes [dict get $meta errors]]
        if {[dict get $meta completion] && [IsCoroutine [lindex $argTypes 0]]} {
            set calleeErrors [CoroutineErrors [lindex $argTypes 0]]
        }
        if {[dict get $meta errorsFrom] ne ""} {
            # A native that calls a callable argument (-errors-from:
            # std::mutable_array::generate's factory) completes with whatever
            # declared error that callable's contract permits.
            set calleeErrors [lsort -unique [concat $calleeErrors \
                [CallableErrors $hir [lindex $argTypes [dict get $meta errorsFrom]]]]]
        }
    } elseif {[IsFn $calleeType] || [IsCoroutine $calleeType]} {
        # A structural callee's declared error contract (a Fn's, or a
        # coroutine handle's: the errors a segment may end with): every
        # error it permits may escape this call, since which implementation
        # runs (and so any narrower proof about it) is unknown here -- and no
        # error it does not permit can (above).
        set calleeErrors [dict get [Contract $calleeType] errors]
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
    if {!$dead && $result eq "never" && [lindex $target 0] eq "block"
            && [Poisoned $hir [lindex $target 1]]} {
        # The callee's every normal completion is poison (Block).
        set dead 1
    }
    # (Region inference's own dead calls -- a wrong arity or argument kind --
    # always raise.)
    if {$dead} {
        return [CallResult hir $e [expr {$halts || $spec}]]
    }
    return $result
}

# RESULT, the type of a call of a native whose registration states the
# length of the List it returns (core/native.tcl's -result-length LENGTH)
# on the arguments ARGEXPRS of types ARGTYPES, refined by that length when
# it is known exactly here (hir::types::Refine; RESULT itself when it is
# not, or when RESULT is no List).
proc hir::types::MintLength {hir length argExprs argTypes result} {
    set n [ResultLength $hir $length $argExprs $argTypes]
    if {$n eq ""} {
        return $result
    }
    return [Refine $result List [list length $n]]
}

# The exact length the registration LENGTH (-result-length) states for a
# call on ARGEXPRS of types ARGTYPES, or "": `args` the argument count,
# `list K D` the length argument K's type states plus D, `extent K` the
# extent of argument K's live fixed array type, `path K` the extent of the
# array designator constant argument K names. (`int K`, a MutableArray's
# capacity, is no List length.)
proc hir::types::ResultLength {hir length argExprs argTypes} {
    if {$length eq "args"} {
        return [llength $argExprs]
    }
    lassign $length how k d
    if {$k eq "" || $k >= [llength $argExprs]} {
        return ""
    }
    switch -- $how {
        list {
            set n [LengthOf [lindex $argTypes $k]]
            if {$n eq ""} {
                return ""
            }
            return [expr {$n + ($d eq "" ? 0 : $d)}]
        }
        extent {
            set term [hir::layouts::OfArrayType [lindex $argTypes $k]]
            if {$term ne "" && [string is entier -strict [lindex $term 1]]} {
                return [lindex $term 1]
            }
        }
        path {
            set repr [hir::layouts::PathField [hir::layouts::ConstText $hir [lindex $argExprs $k]]]
            if {$repr ne "" && [dict get $repr kind] eq "array"} {
                return [dict get $repr extent]
            }
        }
    }
    return ""
}

# The type of call E when it is dead (Call): never -- poison unless HALTS.
proc hir::types::CallResult {hirVar e halts} {
    upvar 1 $hirVar hir
    if {$halts} {
        return never
    }
    return [Poison hir $e]
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
    # A poisoned condition decides nothing: both branches are reachable,
    # neither refined.
    set poisonTest [expr {$test eq "never" && [Poisoned $hir $condition]}]
    set live [expr {$entry && ($test ne "never" || $poisonTest)}]
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
    set poison 0
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
        set branchPoison [expr {$reachable && [dict get $ctx poisonResult]}]
        set poison [expr {$poison || $branchPoison}]
        if {$reachable && ([dict get $branchTypes $outcome] ne "never" || $branchPoison)} {
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
    if {$test eq "never" && !$poisonTest} {
        return never
    }
    if {$known ne ""} {
        set result [dict get $branchTypes $known]
    } else {
        set result [lub [dict get $branchTypes 1] [dict get $branchTypes 0]]
    }
    if {$result eq "never" && $poison} {
        # Every branch that may complete does so with poison.
        return [Poison hir $e]
    }
    return $result
}
