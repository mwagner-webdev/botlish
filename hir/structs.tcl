# structs.tcl -- struct declarations, and the static checks of struct values
# (STRUCTS.md).
#
#   hir::structs::apply DECLS       => HIR `sourceTypes` entries of the structs
#   hir::structs::lookup NAME NS    => declaration identity, or ""
#   hir::structs::names ID          => declared field names, slot order
#   hir::structs::fieldType ID NAME => the declared type of a field, or ""
#
# Vocabulary (the language's and the compiler's)
# ----------------------------------------------
#   struct          the language construct / declaration / type family
#   struct value    one concrete value
#   named struct    a nominal struct declared with `struct Name:`
#   anonymous struct  an unnamed, structurally typed struct value, `{ ... }`
#   struct field    one named member of a struct
#   field projection  `value.field`, statically resolved
#
# A named struct's identity is its *declaration identity*: the declared name
# for the entry program ("Person") and "namespace::Name" for a module's
# ("geo::Point"), so two declarations with identical fields are distinct
# types, and two modules' `Point`s never coincide (STRUCTS.md "Named nominal
# identity"). The declared schema -- field names in written order and the
# resolved type of each -- lives in this file's registry, which is how the
# pure type functions of hir/types.tcl (subtype, lub, bearing, ...) reach it
# from a type form `{nstruct ID}` without a HIR in reach. It is the same
# kind of per-compilation registry core::type's source-defined types are
# (hir/sourcetypes.tcl, "Compilation isolation"): hir::sourcetypes::apply is
# its one entry point, the struct declarations are validated and registered
# there, through the same declaration pass, in the same type namespace as
# integer-domain types (a struct never shares a name with one), and HIR keeps
# the canonical entries as its own `sourceTypes` (kind struct).
#
# A declaration is a *type* declaration, not a value binding: it introduces
# no binding, and follows the declaration-order semantics of the other type
# declarations (a struct may name a struct declared later, itself, or one in
# a cycle: a field's type is the named type, never its expansion, so
# recursion needs no special construction rule). `Name { ... }` resolves
# `Name` through this registry, never through lexical scope.
#
# Representation authority (OPAQUE-STRUCTS.md)
# ---------------------------------------------
# A struct declared `opaque struct Name:` is an ordinary named struct whose
# representation belongs to the module that declares it: only code of that
# module (its *owner*: the declaring namespace, which is already the
# registry's `namespace`, "" for an entry program) may construct it from its
# fields or inspect its fields. The registry records `opaque` per declaration;
# nothing else about an opaque struct differs (identity, type algebra,
# equality, hashing, optimization). Authority is decided at the source
# semantic boundary, from three things: the declaration's owner, the namespace
# of the code performing the operation, and, for a projection, the receiver's
# static type. A construction is decided when it is resolved
# (hir/resolve.tcl's ResolveStruct knows its code's namespace); a projection
# only once types are known, so hir/resolve.tcl stamps every `project` node and
# method-call record with the namespace of its code (`ns`). A node carrying no
# `ns` (core IR, serialized HIR: already past the source boundary) is trusted.
# No `ns` or opacity is consulted after HIR is checked: the analyses, the
# interpreter, the compiler and native lowering see ordinary construct/project
# operations.
#
#   OPAQUE-CONSTRUCTION   `NS::Name { ... }` outside the owner (resolve time;
#                         no field-level diagnostic is ever given for it)
#   OPAQUE-REPRESENTATION a projection of any field name (so also a
#                         destructuring, which lowers to projections, and the
#                         callee of a field-value call) outside the owner,
#                         whether or not the field exists
#
# Static checks (verify, below; hir/structs.tcl is HIR's one home for them)
# --------------------------------------------------------------------------
#   * every named construction provides every declared field once, none
#     undeclared (hir/resolve.tcl), and every value is *proven* admissible
#     for its declared field type: the same proof a call's argument gets for
#     a declared parameter (hir::range::ProvesValueAcceptedBy). No runtime
#     guard is ever inserted because a field type is declared.
#   * a field projection must be proven to name a field of its receiver's
#     static struct type. A receiver of type `any` is rejected -- there is no
#     dynamic lookup to fall back to -- unless the projection sits in a
#     function every call of which has a semantic instance (hir/semantic.tcl)
#     in which the receiver's struct type is known (OPPORTUNISTIC-SEMANTIC-
#     INSTANCES.md): then the definition is valid exactly for the struct
#     types its callers pass, each analyzed under its actual type.

namespace eval hir::structs {
    # ID -> {id ID name NAME namespace NS opaque 0|1 context 0|1 names {FIELD...} types
    # {FIELD TYPE ...} spans {FIELD SPAN ...} span SPAN slots {SLOT ...}
    # constraints {SLOT {TRAIT ...} ...}}: the registry of the current
    # compilation's declarations. `namespace` is the declaring module and,
    # for an opaque struct, the owner of its representation. SLOTS are a
    # parameterized struct's type slots in declared order (empty for every
    # other struct), CONSTRAINTS the trait identities each slot's `satisfies`
    # names (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md); a field type names a slot
    # as the variable {imprint SLOT TRAITS}.
    variable registry [dict create]
    # Entries of the previous compilation's registration are dropped by the
    # next compilation that brings declarations of any kind, before it
    # resolves one (hir::sourcetypes::Reset), or by one that brings none
    # (hir::BuildOnce).
    # ID -> 1|0: whether struct ID is affine (IsAffine), for this registry.
    variable affinity [dict create]
}

proc hir::structs::Reset {} {
    variable registry
    variable affinity
    set registry [dict create]
    set affinity [dict create]
}

# 1 if struct ID is affine (hir::types::Affinity, AFFINE-VALUES.md): a field
# type is. Derived, never declared: there is no `affine struct`. SEEN guards
# a struct whose fields mention itself (through a List): such a cycle adds no
# affinity -- a struct is affine only if some field path reaches an affine
# root. Cached per registration (Reset clears it).
proc hir::structs::IsAffine {id {seen {}}} {
    variable registry
    variable affinity
    if {[dict exists $affinity $id]} {
        return [dict get $affinity $id]
    }
    if {$id in $seen || ![declared $id]} {
        return 0
    }
    set result 0
    # (fieldTypes answers for a LayoutStruct[L] too, from the layout: a
    # layout with a pointer field makes an affine struct view,
    # NATIVE-LAYOUT-VIEWS.md.)
    foreach {name t} [fieldTypes $id] {
        if {[hir::types::IsAffine $t [concat $seen [list $id]]]} {
            set result 1
            break
        }
    }
    if {$seen eq {}} {
        dict set affinity $id $result
    }
    return $result
}

# The fields, as {STRUCT FIELD} pairs from struct ID on, by which struct ID
# holds a value of its own type inside a List, MutableVector or MutableArray
# element -- {Tree kids} for `kids: List[Tree]` in `struct Tree`, or a path
# through other structs -- or "" if it holds none. The steps are exactly the
# ones an affine drop descriptor walks (hir::affine::Descriptor: struct fields
# and those elements). A struct that meets itself through fields alone is not
# such a path: no finite value has that type. One that meets itself through a
# container element has finite values nested to any depth, which no finite
# descriptor reaches: if it is affine, it is AFFINE-CONTAINER-UNSUPPORTED at
# its declaration (apply).
proc hir::structs::OwnedRecursion {id} {
    set visited [dict create]
    return [OwnedRecursionFrom $id [list nstruct $id] 0 {} visited]
}

# OwnedRecursion's walk of TYPE, reached from struct TARGET by the fields
# PATH, CROSSED 1 once that path went through a container element. VISITED
# (STRUCT,CROSSED -> 1) bounds it: a struct is explored at most once per
# CROSSED. (An anonymous struct's fields have no declaring struct: "".)
proc hir::structs::OwnedRecursionFrom {target type crossed path visitedVar} {
    set type [hir::types::Unrefined $type]
    upvar 1 $visitedVar visited
    variable registry
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$path ne {} && $id eq $target} {
            if {$crossed} {
                return $path
            }
            return ""
        }
        if {[dict exists $visited $id,$crossed] || ![dict exists $registry $id]} {
            return ""
        }
        dict set visited $id,$crossed 1
        set owner $id
        set fields [dict get $registry $id types]
    } elseif {[hir::types::IsStruct $type]} {
        set owner ""
        set fields [lindex $type 1]
    } elseif {[hir::types::IsList $type] || [hir::types::IsMutVec $type] || [hir::types::IsMutArray $type]} {
        return [OwnedRecursionFrom $target [lindex $type 1] 1 $path visited]
    } else {
        return ""
    }
    foreach {name t} $fields {
        set found [OwnedRecursionFrom $target $t $crossed [linsert $path end [list $owner $name]] visited]
        if {$found ne ""} {
            return $found
        }
    }
    return ""
}

proc hir::structs::Fail {span message {kind TYPE}} {
    core::semanticError $kind "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# The declaration identity a struct NAME declared in module NAMESPACE (""
# for the entry program) has.
proc hir::structs::identity {name namespace} {
    if {$namespace eq ""} {
        return $name
    }
    return "${namespace}::${name}"
}

# 1 if ID is a registered struct declaration identity, or the identity of
# the struct view of a registered layout ("LayoutStruct[L]", BINARY-LAYOUT.md:
# its schema is the layout's, answered from hir/layouts.tcl's registry by the
# accessors below and never registered here).
proc hir::structs::declared {id} {
    variable registry
    return [expr {[dict exists $registry $id] || [hir::layouts::OfStructId $id] ne ""}]
}

# The identity the struct type spelled NAME (as written: "Person", or
# "geo::Point") denotes in code of module namespace NS ("" for the entry
# program), or "". A qualified spelling is exactly one declaration; an
# unqualified one is the code's own namespace's declaration.
proc hir::structs::lookup {name {ns ""}} {
    variable registry
    if {[string first :: $name] >= 0} {
        if {[dict exists $registry $name]} {
            return $name
        }
        return ""
    }
    set id [identity $name $ns]
    if {[dict exists $registry $id]} {
        return $id
    }
    return ""
}

proc hir::structs::names {id} {
    variable registry
    if {![dict exists $registry $id]} {
        set layout [hir::layouts::OfStructId $id]
        if {$layout ne ""} {
            return [hir::layouts::StructNames $layout]
        }
    }
    return [dict get $registry $id names]
}

# The declared type of field NAME of struct ID, or "" if ID has no such
# field.
proc hir::structs::fieldType {id name} {
    variable registry
    if {![dict exists $registry $id]} {
        set layout [hir::layouts::OfStructId $id]
        if {$layout eq ""} {
            return ""
        }
        set types [hir::layouts::StructFieldTypes $layout]
        return [dict getdef $types $name ""]
    }
    set types [dict get $registry $id types]
    return [dict getdef $types $name ""]
}

# {FIELD TYPE ...} in declared order.
proc hir::structs::fieldTypes {id} {
    variable registry
    if {![dict exists $registry $id]} {
        set layout [hir::layouts::OfStructId $id]
        if {$layout ne ""} {
            return [hir::layouts::StructFieldTypes $layout]
        }
    }
    return [dict get $registry $id types]
}

# The source spelling of declaration identity ID (for diagnostics and show).
proc hir::structs::display {id} {
    return $id
}

# ---------------------------------------------------------------------------
# Parameterized structs (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md)
#
#   struct Map[K satisfies Hashable, V]:
#       keys: MutableArray[K]
#       values: MutableArray[V]
#
# declares a *type constructor*: its types are its applications
# {nstruct Map {A B}} (hir/types.tcl), one type per slot, each valid only if
# every constrained slot's argument satisfies its trait -- by the ordinary
# trait satisfaction (hir::traits::satisfies), whatever supplies the witness.
# A slot is a static imprinted type position: a field type names it as the
# variable {imprint K {Hashable}}, and an application's field types are the
# declaration's with every slot replaced by its argument (AppliedFieldTypes).
# There is no generic function behind it and no runtime generic object: a
# value of Map[str, int] is an ordinary Map struct value (one representation
# per constructor, hir::types::StructShape), its arguments static only.

# The type slots of struct ID in declared order ("" if it has none).
proc hir::structs::slots {id} {
    variable registry
    return [dict getdef $registry $id slots {}]
}

# 1 if the current compilation declares a parameterized struct.
proc hir::structs::anyParameterized {} {
    variable registry
    dict for {id entry} $registry {
        if {[dict getdef $entry slots {}] ne {}} {
            return 1
        }
    }
    return 0
}

# 1 if struct ID declares type slots.
proc hir::structs::isParameterized {id} {
    return [expr {[slots $id] ne {}}]
}

# {SLOT {TRAIT ...} ...}: the traits each slot of struct ID is declared to
# satisfy (an unconstrained slot's list is empty).
proc hir::structs::slotConstraints {id} {
    variable registry
    return [dict getdef $registry $id constraints {}]
}

# {SLOT TYPE ...}: the imprint binding of application TYPE, each slot of its
# constructor to its argument ("" for a struct type that is no application).
proc hir::structs::SlotBinding {type} {
    if {![hir::types::IsAppliedStruct $type]} {
        return ""
    }
    set binding [dict create]
    foreach slot [slots [lindex $type 1]] arg [lindex $type 2] {
        dict set binding $slot $arg
    }
    return $binding
}

# {FIELD TYPE ...}, in declared order: the field types of the named struct
# type TYPE -- for an application, the declaration's with every slot
# replaced by its argument. Static typing reads these; the runtime
# representation reads the declaration's own (fieldTypes), one per
# constructor.
proc hir::structs::AppliedFieldTypes {type} {
    set fields [fieldTypes [lindex $type 1]]
    set binding [SlotBinding $type]
    if {$binding eq ""} {
        return $fields
    }
    set result {}
    foreach {name t} $fields {
        lappend result $name [hir::types::canonical [hir::imprint::Substitute $t $binding]]
    }
    return $result
}

# "" when every application in TYPE, at any depth, is valid -- each argument
# of a constrained slot satisfies the slot's traits, by the ordinary trait
# satisfaction (hir::traits::satisfies: an intrinsic trait's witness
# predicate, an ordinary trait's conformance through the witness's owner, a
# constrained variable's own constraints) -- else the first failure's
# message, in source terms. A `never` argument (no value) is vacuous; `any`
# satisfies nothing, though some of its values might.
proc hir::structs::ApplicationProblem {type} {
    if {[string first nstruct $type] < 0} {
        return ""
    }
    if {[hir::types::IsAppliedStruct $type]} {
        set id [lindex $type 1]
        set constraints [slotConstraints $id]
        foreach slot [slots $id] arg [lindex $type 2] {
            if {$arg eq "never"} {
                continue
            }
            foreach trait [dict getdef $constraints $slot {}] {
                set s [hir::traits::satisfies $arg $trait]
                if {[dict get $s ok]} {
                    continue
                }
                set why [dict get $s reason]
                if {[dict get $s requirement] ne ""} {
                    # An ordinary trait's explanation: the requirement and what
                    # was found (hir::traits::explain, past its first line).
                    set why [join [lrange [split [hir::traits::explain $arg $trait] \n] 1 end] \n]
                }
                return [format {type argument for "%s" in %s does not satisfy %s: %s} \
                    $slot [hir::types::presented $type] $trait $why]
            }
        }
        if {[treeField $id] ne "" && [lsearch -exact [lmap arg [lindex $type 2] {hir::types::IsAffine $arg}] 1] >= 0} {
            # A tree struct applied to an affine type (TREE-STRUCT-
            # MILESTONE-1.md): its values would be affine trees, nested to
            # any depth -- the recursive affine type a declaration may not
            # be either (apply's AFFINE-CONTAINER-UNSUPPORTED).
            return [format {%s applies tree struct "%s" to an affine type: a tree of affine values nests to any depth, and an affine value is released by a static, finite walk of its type (a tree struct holds unrestricted values)} \
                [hir::types::presented $type] [display $id]]
        }
    }
    foreach t [hir::imprint::Parts $type] {
        set problem [ApplicationProblem $t]
        if {$problem ne ""} {
            return $problem
        }
    }
    return ""
}

# The diagnostic kind of ApplicationProblem's answer for TYPE: AFFINE-
# CONTAINER-UNSUPPORTED for an affine application of a tree struct (the
# declaration rule's kind), TRAIT-NOT-SATISFIED for every other problem.
proc hir::structs::ProblemKind {problem} {
    if {[string match {* applies tree struct * to an affine type: *} $problem]} {
        return AFFINE-CONTAINER-UNSUPPORTED
    }
    return TRAIT-NOT-SATISFIED
}

# Diagnoses the invalid applications HIR's code writes or makes
# (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md), as TRAIT-NOT-SATISFIED -- the
# failure belongs to the type application, never to a later operation on a
# value of it: a block's declared parameter and result types, a
# parameterized struct's construction (explicit or inferred), a call's
# explicit imprints. (A struct field's or payload's application is the
# declaration's, VerifyDeclarations; one a call's binding makes is the
# call's, hir::imprint::verify.)
proc hir::structs::verifyApplications {hirVar} {
    upvar 1 $hirVar hir
    if {![anyParameterized]} {
        return
    }
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            block {
                if {![dict exists $node declaredParamTypes]} continue
                set names [lmap b [dict get $node params] {hir::semantic::SourceName $hir $b}]
                foreach t [dict get $node declaredParamTypes] name $names {
                    if {$t eq ""} continue
                    set problem [ApplicationProblem $t]
                    if {$problem ne ""} {
                        hir::Diagnose hir [ProblemKind $problem] "the type of parameter \"$name\" is invalid: $problem" $e
                    }
                }
                set result [dict getdef $node declaredResult {}]
                if {$result ne ""} {
                    set problem [ApplicationProblem $result]
                    if {$problem ne ""} {
                        hir::Diagnose hir [ProblemKind $problem] "the declared result type is invalid: $problem" $e
                    }
                }
            }
            struct {
                # (Recorded by its typing, hir::types::Struct: the
                # construction is poison.)
                if {![dict exists $node structApplicationProblem]} continue
                if {[dict exists $node reachable] && ![dict get $node reachable]} continue
                hir::Diagnose hir [ProblemKind [dict get $node structApplicationProblem]] \
                    "the construction is invalid: [dict get $node structApplicationProblem]" $e
            }
            call {
                if {![dict exists $node imprint]} continue
                if {[dict exists $node reachable] && ![dict get $node reachable]} continue
                foreach t [dict get $node imprint] {
                    set problem [ApplicationProblem $t]
                    if {$problem ne ""} {
                        hir::Diagnose hir TRAIT-NOT-SATISFIED "an explicit imprint is invalid: $problem" $e
                        break
                    }
                }
            }
        }
    }
}

# Raises the first invalid application of the current compilation's
# declarations (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): a struct field's type
# or an error payload field's, located at the field's type. Inside a
# parameterized struct a slot is the variable with its declared traits, so
#
#   struct Outer[T]:                 inner: Map[T, int]
#
# is rejected here -- T does not declare the Hashable its field's type
# requires -- and `struct Outer[T satisfies Hashable]` is accepted: an
# enclosing declaration states the obligations of the applications it
# holds, never hides one. Run once every declaration and implementation is
# known (an ordinary trait's conformance reads the implementation index).
proc hir::structs::VerifyDeclarations {} {
    variable registry
    dict for {id entry} $registry {
        set spans [dict getdef $entry typeSpans {}]
        foreach {name t} [dict get $entry types] {
            set problem [ApplicationProblem $t]
            if {$problem eq ""} continue
            set span [dict getdef $spans $name ""]
            set message [format {invalid type %s for field "%s" of struct "%s": %s} \
                [hir::types::show $t] $name [dict get $entry name] $problem]
            if {[dict exists $entry constraints] && [string first imprint $t] >= 0} {
                append message " (a type slot satisfies exactly the traits its declaration states: struct [dict get $entry name]\[... satisfies TRAIT\])"
            }
            if {$span eq ""} {
                core::semanticError [ProblemKind $problem] $message
            }
            Fail $span $message [ProblemKind $problem]
        }
    }
    foreach {error fields spans} [hir::errordecls::PayloadTypes] {
        foreach {name t} $fields {
            set problem [ApplicationProblem $t]
            if {$problem eq ""} continue
            set message [format {invalid type %s for payload field "%s" of error "%s": %s} \
                [hir::types::show $t] $name $error $problem]
            set span [dict getdef $spans $name ""]
            if {$span eq ""} {
                core::semanticError TRAIT-NOT-SATISFIED $message
            }
            Fail $span $message TRAIT-NOT-SATISFIED
        }
    }
}

# The type of field NAME of the named struct type TYPE (AppliedFieldTypes),
# or "" if it has no such field.
proc hir::structs::AppliedFieldType {type name} {
    set t [fieldType [lindex $type 1] $name]
    set binding [SlotBinding $type]
    if {$t eq "" || $binding eq ""} {
        return $t
    }
    return [hir::types::canonical [hir::imprint::Substitute $t $binding]]
}

# 1 if struct ID was declared `opaque struct`.
proc hir::structs::isOpaque {id} {
    variable registry
    return [expr {[dict exists $registry $id opaque] && [dict get $registry $id opaque]}]
}

# 1 if struct ID was declared `context struct` (or `opaque context struct`):
# a value of it may be installed into the execution environment and satisfy
# a function's context dependency (CONTEXTS.md). Independent of opacity.
proc hir::structs::isContext {id} {
    variable registry
    return [expr {[dict exists $registry $id context] && [dict get $registry $id context]}]
}

# The namespace ("" for an entry program) that owns the representation of
# struct ID: the module that declares it.
proc hir::structs::owner {id} {
    variable registry
    if {![dict exists $registry $id]} {
        set layout [hir::layouts::OfStructId $id]
        if {$layout ne ""} {
            return [dict get [hir::layouts::entry $layout] namespace]
        }
    }
    return [dict get $registry $id namespace]
}

# 1 if code of namespace NS ("" for the entry program) lacks authority over
# the representation of struct ID: the struct is opaque and NS is not its
# declaring module. Authority is exact -- no import, parent, child or
# containing struct ever grants it.
proc hir::structs::representationDenied {id ns} {
    return [expr {[isOpaque $id] && [owner $id] ne $ns}]
}

# "module \"token\"" / "the entry program": the owner of struct ID in prose.
proc hir::structs::OwnerPhrase {id} {
    set owner [owner $id]
    return [expr {$owner eq "" ? "the entry program" : "module \"$owner\""}]
}

# "that module" / "the entry program": the owner as a back-reference.
proc hir::structs::OwnerRef {id} {
    return [expr {[owner $id] eq "" ? "the entry program" : "that module"}]
}

# The message of OPAQUE-CONSTRUCTION for struct ID. It names the type and its
# owner, never a field.
proc hir::structs::ConstructionMessage {id} {
    return [::format {%s has an opaque representation owned by %s; construct it through the public operations provided by %s} \
        [display $id] [OwnerPhrase $id] [OwnerRef $id]]
}

# The message of OPAQUE-REPRESENTATION for struct ID. It does not depend on
# the field named, so it cannot be used to discover which fields exist.
proc hir::structs::RepresentationMessage {id} {
    return [::format {field access on %s is not available outside %s; %s has an opaque representation, so its fields can be neither projected nor destructured here (use the public operations provided by %s)} \
        [display $id] [OwnerPhrase $id] [display $id] [OwnerRef $id]]
}

# Moves the representation-authority diagnostics (OPAQUE-CONSTRUCTION,
# OPAQUE-REPRESENTATION) ahead of the others, keeping every relative order:
# they are the root cause of whatever follows from a rejected access (the
# rejected access is poison, hir/types.tcl, so no later check reports a
# consequence of it; a semantic instance's types it as an unknown field is),
# and the first diagnostic is the one a strict compile raises first. A HIR
# without one is left exactly as it is.
proc hir::structs::promoteOpacity {hirVar} {
    upvar 1 $hirVar hir
    set opaque {}
    set rest {}
    foreach d [dict get $hir diagnostics] {
        if {[dict get $d kind] in {OPAQUE-CONSTRUCTION OPAQUE-REPRESENTATION}} {
            lappend opaque $d
        } else {
            lappend rest $d
        }
    }
    if {$opaque ne "" && $rest ne ""} {
        dict set hir diagnostics [concat $opaque $rest]
    }
}

# 1 if NODE (a `project` node, or a method-call receiver's context) performs
# its field access without authority over TYPE, a receiver type: TYPE is a
# named opaque struct whose owner is not the namespace NODE's code is in. A
# node without an `ns` stamp is trusted (see the file header). Never consulted
# for a type that is not a named struct.
proc hir::structs::projectionDenied {type node} {
    if {![hir::types::IsNamedStruct $type] || ![dict exists $node ns]} {
        return 0
    }
    set id [lindex $type 1]
    return [expr {[declared $id] && [representationDenied $id [dict get $node ns]]}]
}

# The PRIVATE-ACCESS message of the field access NODE (a `project` node)
# through a value of TYPE, its receiver's type, when TYPE is a struct or a
# layout's native view or edit declared `private` by another module than
# the one NODE's code is in (hir/privacy.tcl: the declaration is not that
# code's to use, its fields included), else "". A node without an `ns`
# stamp is trusted (the file header).
proc hir::structs::PrivateRepresentation {hir type node} {
    if {![dict exists $node ns]} {
        return ""
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
    } else {
        set id [hir::layouts::OfNativeType $type]
        if {$id eq "" || [llength $id] != 1} {
            return ""
        }
    }
    set decls [hir::privacy::Decls $hir]
    lassign [hir::privacy::Member $id] ns name
    if {![hir::privacy::Denied $decls $ns types $name [dict get $node ns]]} {
        return ""
    }
    set entry [hir::privacy::Entry $decls $ns types $name]
    return "field access on $id is not available outside [hir::privacy::UnitPhrase $ns]: [hir::privacy::AccessMessage $ns $name [dict get $entry kind] [dict get $node ns]]"
}

# The struct declaration the expression-level name NAME could be confused
# with: a non-struct type of the same spelling, for a better diagnostic.
proc hir::structs::IsOtherType {name} {
    return [expr {[core::type::valid $name] || [dict exists $::hir::types::constructors $name]}]
}

# Validates and registers DECLS (surface/lower.tcl's StructDeclOf dicts:
# {name nameSpan namespace NS fields {{name nameSpan type typeSpan}...}}),
# after the integer-domain types of the same compilation are registered (a
# struct name may collide with none of them), resetting the previous
# compilation's registry. Returns HIR's own `sourceTypes` entries for them:
# {kind struct name NAME id ID namespace NS opaque 0|1 fields {FIELD TYPE ...}},
# in declaration order.
proc hir::structs::apply {decls} {
    variable registry
    variable affinity
    Reset
    set byId [dict create]
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        if {$name in {Int any never Fn Coroutine enum} || [core::type::isBuiltinName $name] || [core::type::valid $id]
                || [dict exists $::hir::types::constructors $name] || [core::native::isBuiltinEnum $name]
                || [hir::traits::isIntrinsicName $name]} {
            Fail [dict get $decl nameSpan] "\"$name\" cannot be declared as a struct: the name is already a built-in or declared type"
        }
        if {[hir::enums::declared $id]} {
            # One type namespace (ENUMS.md): an enum of that name exists.
            Fail [dict get $decl nameSpan] "type \"$name\" is already declared (as an enum)"
        }
        if {[hir::layouts::declared $id]} {
            # Layouts share the type namespace (BINARY-LAYOUT.md).
            Fail [dict get $decl nameSpan] "type \"$name\" is already declared (as a layout)"
        }
        if {[dict exists $byId $id]} {
            Fail [dict get $decl nameSpan] "type \"$name\" is already declared"
        }
        set names {}
        set spans [dict create]
        foreach field [dict get $decl fields] {
            set fieldName [dict get $field name]
            if {$fieldName in $names} {
                Fail [dict get $field nameSpan] "duplicate field \"$fieldName\" in struct \"$name\""
            }
            lappend names $fieldName
            dict set spans $fieldName [dict get $field nameSpan]
        }
        dict set byId $id $decl
        lassign [DeclaredSlots $decl] slotNames constraints
        # The skeleton first: a field type may name any struct of the batch,
        # declared earlier, later, or this one itself (its slots too: an
        # application's arity is checked as its field types resolve).
        dict set registry $id [dict create id $id name $name namespace $ns \
            opaque [expr {[dict exists $decl opaque] && [dict get $decl opaque]}] \
            context [expr {[dict exists $decl context] && [dict get $decl context]}] names $names \
            types {} spans $spans span [dict get $decl nameSpan] slots $slotNames constraints $constraints]
    }
    foreach decl $decls {
        # A slot names no visible type (every type of the batch is
        # registered now): inside the declaration the name is the slot's.
        foreach slot [dict getdef $decl slots {}] {
            set slotName [dict get $slot name]
            if {![catch {hir::types::resolveNamed $slotName [dict get $decl namespace]}]} {
                Fail [dict get $slot nameSpan] "type slot \"$slotName\" of struct \"[dict get $decl name]\" names a visible type: a slot is a name of its own, never a type of the program (choose another variable name)"
            }
        }
    }
    set entries {}
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        set types {}
        # A parameterized struct's fields may name its slots: the variables
        # {imprint SLOT TRAITS} (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md).
        set slotNames [dict get $registry $id slots]
        set imprints [if {$slotNames eq {}} {string cat 0} else {set slotNames}]
        foreach field [dict get $decl fields] {
            set fieldName [dict get $field name]
            set typeExpr [dict get $field type]
            if {[catch {hir::imprint::ConstrainVariables \
                    [hir::resolve::ResolveTypeExpr $typeExpr $ns $imprints] \
                    [dict get $registry $id constraints]} resolved options]} {
                Fail [dict get $field typeSpan] \
                    [format {unknown or invalid type %s for field "%s" of struct "%s": %s} \
                        [hir::resolve::ShowTypeExpr $typeExpr] $fieldName $name $resolved] \
                    [hir::resolve::TypeErrorKind $options TYPE]
            }
            if {[hir::types::MentionedContextTrait $resolved] ne ""} {
                Fail [dict get $field typeSpan] \
                    [hir::types::ContextTraitPositionMessage [hir::types::MentionedContextTrait $resolved] \
                        "the type of field \"$fieldName\" of struct \"$name\""] CONTEXT-TRAIT-POSITION
            }
            if {[hir::types::MentionsTrait $resolved]} {
                # A stored trait value would need its witness stored beside
                # it: an existential representation this milestone does not
                # have (TRAITS.md, "Storage").
                Fail [dict get $field typeSpan] \
                    [format {field "%s" of struct "%s" cannot have trait type %s: a struct field stores one concrete representation, and there is no erased or heterogeneous trait representation (store a concrete type)} \
                        $fieldName $name [hir::types::show $resolved]] TRAIT-STORAGE-UNSUPPORTED
            }
            lappend types $fieldName $resolved
        }
        dict set registry $id types $types
        dict set registry $id typeSpans [concat {*}[lmap field [dict get $decl fields] {
            list [dict get $field name] [dict get $field typeSpan]
        }]]
        set entry [dict create kind struct name $name id $id namespace $ns \
            opaque [dict get $registry $id opaque] fields $types]
        if {$slotNames ne {}} {
            # Present only for a parameterized struct, so an ordinary
            # declaration's entry is unchanged: {SLOT {TRAIT ...}} pairs.
            dict set entry slots [lmap slot $slotNames {
                list $slot [dict get $registry $id constraints $slot]
            }]
        }
        if {[dict get $registry $id context]} {
            # Present only for a context struct (CONTEXTS.md), so an ordinary
            # declaration's entry is unchanged.
            dict set entry context 1
        }
        if {[dict exists $decl identity]} {
            # Present only for a struct that declares its semantic identity
            # (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md): {form FORM
            # fields {FIELD ...}}.
            set identity [ValidateIdentity $decl $id $types]
            dict set registry $id identity $identity
            dict set entry identity $identity
        }
        lappend entries $entry
    }
    # Tree structs (TREE-STRUCT-MILESTONE-1.md), once every field type of
    # the batch is resolved (a field reaches other declarations' fields):
    # each one's recursive field, checked against the one shape there is.
    set index 0
    foreach decl $decls {
        if {[dict exists $decl tree] && [dict get $decl tree]} {
            set id [identity [dict get $decl name] [dict get $decl namespace]]
            set field [ValidateTree $decl $id [dict get $registry $id types]]
            dict set registry $id tree $field
            lset entries $index [dict replace [lindex $entries $index] tree $field]
        }
        incr index
    }
    # (Affinity read while field types were still being resolved is stale.)
    set affinity [dict create]
    foreach decl $decls {
        set id [identity [dict get $decl name] [dict get $decl namespace]]
        if {![IsAffine $id]} continue
        set path [OwnedRecursion $id]
        if {$path eq ""} continue
        # A recursive affine type: releasing a value of it would have to
        # recurse as deep as the value nests, and an affine drop is a static
        # descriptor -- a finite walk of the type (hir::affine::Descriptor).
        set first [lindex $path 0 1]
        foreach field [dict get $decl fields] {
            if {[dict get $field name] eq $first} {
                set span [dict get $field typeSpan]
            }
        }
        set steps [lmap step $path {
            lassign $step owner name
            format {%s.%s: %s} [display $owner] $name [hir::types::show [fieldType $owner $name]]
        }]
        Fail $span [format {struct "%s" is affine and holds values of its own type in a List, MutableVector or MutableArray (%s): a recursive affine type is not supported -- its release would have to recurse as deep as the value nests, and an affine value is released by a static, finite walk of its type (an unrestricted struct may hold itself in a container)} \
            [dict get $decl name] [join $steps ", "]] AFFINE-CONTAINER-UNSUPPORTED
    }
    return $entries
}

# Re-registers the struct entries of a HIR's own `sourceTypes` (hir/read.tcl:
# a serialized HIR carries its declarations as resolved types).
proc hir::structs::applyEntries {entries} {
    variable registry
    variable affinity
    Reset
    foreach entry $entries {
        set names {}
        foreach {fieldName type} [dict get $entry fields] { lappend names $fieldName }
        set slotNames {}
        set constraints {}
        foreach pair [dict getdef $entry slots {}] {
            lassign $pair slot traits
            lappend slotNames $slot
            dict set constraints $slot $traits
        }
        dict set registry [dict get $entry id] [dict create id [dict get $entry id] \
            name [dict get $entry name] namespace [dict get $entry namespace] \
            opaque [expr {[dict exists $entry opaque] && [dict get $entry opaque]}] \
            context [expr {[dict exists $entry context] && [dict get $entry context]}] names $names \
            types [dict get $entry fields] spans {} span {} slots $slotNames constraints $constraints]
        if {[dict exists $entry identity]} {
            dict set registry [dict get $entry id] identity [dict get $entry identity]
        }
        if {[dict exists $entry tree]} {
            dict set registry [dict get $entry id] tree [dict get $entry tree]
        }
    }
    set affinity [dict create]
}

# ---------------------------------------------------------------------------
# Tree structs (TREE-STRUCT-MILESTONE-1.md)
#
# `tree struct NAME[SLOTS]:` declares a finite recursive value: an ordinary
# immutable struct whose one recursive field -- its *child field* -- has
# exactly the type List[NAME[SLOTS]], the declaration applied to its own
# slots in order (Self). Its values are the finite rooted ordered trees the
# fields describe, built from child values that already exist: there is no
# reference, node identity, parent link or cycle, and a subtree is a value.
# The declaration records which field is the child field (the registry's and
# the sourceTypes entry's `tree`), so nothing later finds tree-ness by
# looking for a recursive field: totality skips exactly that edge
# (hir::types::Totality), both runtimes compare, hash and print a tree
# value's topology iteratively by it (core::value's tree test, NIR's shape
# `tree=`), and std::tree::walk reads it (`std::tree::children`).
#
# The shape is deliberately strict. Self occurs exactly once in the
# declaration, as that field's List element. Every other field is an
# ordinary non-recursive field: it never reaches the declaration again,
# directly (`child: Node`), through a container (`kids: MutableVector[Node]`,
# an ImmutableMap's value, an Optional-like struct), nested
# (`List[List[Node]]`), through another application of the declaration
# (`List[Node[int]]` in `Node[T]`) or through another declaration (mutual
# recursion). A general recursive type -- a field of Self, a second
# recursive edge, a map of Self -- is an ordinary `struct`'s business
# (STRUCTS.md), never a tree's: what a tree struct promises (depth-unbounded
# equality, hashing and traversal over one ordered child edge) holds for
# this shape only.

# The child field of tree struct ID, or "" when ID is no tree struct.
proc hir::structs::treeField {id} {
    variable registry
    if {$id eq "" || ![dict exists $registry $id tree]} {
        return ""
    }
    return [dict get $registry $id tree]
}

# What the runtimes read (core::value's tree test, NIR's shape `tree=`):
# the slot position of tree struct ID's child field, or "" for any other
# struct.
proc hir::structs::RuntimeTree {id} {
    variable registry
    set field [treeField $id]
    if {$field eq ""} {
        return ""
    }
    return [lsearch -exact [dict get $registry $id names] $field]
}

# The type Self of struct ID: {nstruct ID} or, for a parameterized struct,
# its application to its own slots in declared order.
proc hir::structs::SelfType {id} {
    variable registry
    set slots [dict get $registry $id slots]
    if {$slots eq {}} {
        return [list nstruct $id]
    }
    set constraints [dict get $registry $id constraints]
    return [list nstruct $id [lmap slot $slots {
        hir::types::MakeImprint $slot [dict get $constraints $slot]
    }]]
}

# The child field of tree struct declaration DECL (apply's; ID its identity,
# TYPES its resolved field types {FIELD TYPE ...}), checked: exactly one
# field of type List[Self], and no other occurrence of the declaration in
# any field type, the child field's element included (header).
proc hir::structs::ValidateTree {decl id types} {
    set name [dict get $decl name]
    set rule "a tree struct has exactly one recursive field, of type List\[[ShowSelf $id]\]"
    if {[dict exists $decl identity]} {
        Fail [dict get $decl identity span] "tree struct \"$name\" cannot declare an identity: a tree's equality and hashing are its structure -- its fields and its ordered children, recursively -- and an identity clause would give it a second meaning" TREE-STRUCT-COMBINATION
    }
    if {[dict exists $decl context] && [dict get $decl context]} {
        Fail [dict get $decl treeSpan] "context struct \"$name\" cannot be a tree struct: a context is installed and required by its type, never a recursive value" TREE-STRUCT-COMBINATION
    }
    if {[dict exists $decl opaque] && [dict get $decl opaque]} {
        # std::tree::walk takes any tree apart into its subtrees, which for
        # an opaque struct only its owner may do (OPAQUE-STRUCTS.md).
        Fail [dict get $decl treeSpan] "tree struct \"$name\" cannot be opaque: std::tree::walk takes any tree apart into its subtrees, and taking an opaque struct's value apart is its owning module's alone (wrap the tree in an opaque struct of its own to hide it)" TREE-STRUCT-COMBINATION
    }
    set self [SelfType $id]
    set child ""
    foreach field [dict get $decl fields] {
        set fieldName [dict get $field name]
        set type [dict get $types $fieldName]
        set span [dict get $field typeSpan]
        if {[hir::types::IsList $type] && [llength $type] == 2 && [lindex $type 1] eq $self} {
            if {$child ne ""} {
                Fail $span "tree struct \"$name\" has a second recursive field \"$fieldName\" (the first is \"$child\"): $rule" TREE-STRUCT-SHAPE
            }
            set child $fieldName
            continue
        }
        set how [TreeOccurrence $type $id {}]
        if {$how ne ""} {
            Fail $span "field \"$fieldName\" of tree struct \"$name\" ([hir::types::show $type]) [TreeOccurrenceText $how $name $self]: $rule, and every other field is an ordinary value that does not contain \"$name\"" TREE-STRUCT-SHAPE
        }
    }
    if {$child eq ""} {
        Fail [dict get $decl nameSpan] "tree struct \"$name\" has no recursive field: $rule (the field that holds its ordered children)" TREE-STRUCT-SHAPE
    }
    return $child
}

# How declaration ID occurs in TYPE (a field type of a tree struct other
# than its child field), the first occurrence found: "" for none, else one
# of {self} (TYPE is the declaration itself), {list INNER} (a List whose
# element holds it some other way: INNER, recursively), {application}
# (another application of the declaration than Self), {container KIND}
# (a MutableVector, MutableArray, ImmutableSet, function or coroutine type
# holds it), {through OTHER} (another declaration's fields reach it). SEEN
# bounds the walk through declarations.
proc hir::structs::TreeOccurrence {type id seen} {
    set type [hir::types::Unrefined $type]
    if {[hir::types::IsNamedStruct $type]} {
        set other [lindex $type 1]
        if {$other eq $id} {
            if {[llength $type] > 2 && $type ne [SelfType $id]} {
                return {application}
            }
            return {self}
        }
        foreach arg [lrange $type 2 end] {
            foreach t $arg {
                if {[TreeOccurrence $t $id $seen] ne ""} {
                    # An argument of another type constructor (an
                    # ImmutableMap's value, a Pair's component): a
                    # container this shape does not have.
                    return [list container [display $other]]
                }
            }
        }
        if {$other in $seen || ![declared $other]} {
            return ""
        }
        if {[catch {AppliedFieldTypes $type} fields]} {
            set fields [fieldTypes $other]
        }
        foreach {name t} $fields {
            if {$t eq {}} continue
            if {[TreeOccurrence $t $id [concat $seen [list $other]]] ne ""} {
                return [list through [display $other]]
            }
        }
        return ""
    }
    if {[hir::types::IsList $type]} {
        if {[llength $type] == 2} {
            set inner [TreeOccurrence [lindex $type 1] $id $seen]
            if {$inner eq ""} {
                return ""
            }
            return [list list $inner]
        }
        foreach t [lindex $type 2] {
            set inner [TreeOccurrence $t $id $seen]
            if {$inner ne ""} {
                return [list list $inner]
            }
        }
        return ""
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            set inner [TreeOccurrence $t $id $seen]
            if {$inner ne ""} {
                return $inner
            }
        }
        return ""
    }
    foreach {test label} {IsMutVec MutableVector IsMutArray MutableArray IsSet ImmutableSet} {
        if {[hir::types::$test $type]} {
            if {[TreeOccurrence [lindex $type 1] $id $seen] ne ""} {
                return [list container $label]
            }
            return ""
        }
    }
    if {[hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
        set contract [lindex $type 1]
        foreach t [concat [dict getdef $contract args {}] [list [dict getdef $contract return any]]] {
            if {[TreeOccurrence $t $id $seen] ne ""} {
                return [list container [expr {[hir::types::IsFn $type] ? "function type" : "coroutine type"}]]
            }
        }
        return ""
    }
    return ""
}

# The words of a ValidateTree diagnostic for occurrence HOW (TreeOccurrence)
# of the tree struct NAME, whose Self type is SELF; WHERE says that the
# occurrence is inside a List.
proc hir::structs::TreeOccurrenceText {how name self {where ""}} {
    switch -- [lindex $how 0] {
        self {
            return "holds \"$name\" itself$where, a recursive field that is not the List of its children"
        }
        application {
            return "holds another application of \"$name\" than [hir::types::show $self]$where, but the children of a tree are values of its own type"
        }
        list {
            # Through the Lists to what holds the declaration: Self itself
            # in a List of Lists is nesting; anything else is said of what
            # it is.
            while {[lindex $how 0] eq "list"} {
                set how [lindex $how 1]
            }
            if {[lindex $how 0] eq "self"} {
                return "nests \"$name\" deeper than one List"
            }
            return [TreeOccurrenceText $how $name $self " (inside a List)"]
        }
        container {
            return "holds \"$name\" inside a [lindex $how 1]$where, a recursive edge a tree struct does not have"
        }
        through {
            return "reaches \"$name\" again through \"[lindex $how 1]\"$where, which is mutual recursion between declarations, not a tree"
        }
    }
    return "holds \"$name\""
}

# How Self of struct ID is written in a diagnostic: NAME or NAME[SLOT, ...].
proc hir::structs::ShowSelf {id} {
    variable registry
    set name [dict get $registry $id name]
    set slots [dict get $registry $id slots]
    if {$slots eq {}} {
        return $name
    }
    return "$name\[[join $slots {, }]\]"
}

# ---------------------------------------------------------------------------
# Semantic identity (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md)
#
# An opaque struct may declare what its values mean -- their *identity* --
# apart from how they are stored, by one clause of its declaration:
#
#   identity members(F)            the elements of the List field F, in no
#                                  order: two values are equal when F holds
#                                  the same elements, as many times
#   identity associations(K, V)    the pairs (K[i], V[i]) of the List fields
#                                  K and V, in no order: two values are equal
#                                  when they hold the same pairs
#
# Every other field is representation: no equality, hash or table hash reads
# it. The language implementation defines the two forms -- equality is
# multiset equality of the elements or pairs under Botlish `==`, both hashes
# a commutative combination of the elements' or pairs' hashes (core/value.tcl,
# core/hashing.tcl, native/src/runtime/ops.rs) -- so totality, coherence and
# order independence hold by construction: no code of the owner runs. The
# owner chooses the projection, and keeps its own invariants (distinct
# members, distinct keys) that make multiset equality the set or map
# equality it means. Only an opaque, immutable struct may declare one, and
# only in its own declaration, so a type has exactly one identity and only
# its owner decides it.

# The identity forms: name -> the number of fields each takes.
namespace eval hir::structs {
    variable identityForms {members 1 associations 2}
}

# The identity of struct ID, {form FORM fields {FIELD ...}}, or "" when it
# declares none (its equality and hashes are its fields', structurally).
proc hir::structs::identityOf {id} {
    variable registry
    if {![dict exists $registry $id identity]} {
        return ""
    }
    return [dict get $registry $id identity]
}

# What the runtimes read (core::value's identity test): {FORM {POSITION ...}}
# -- the identity's form and its fields' slot positions -- or "" for a struct
# of no declared identity, or no struct of the current registry.
proc hir::structs::RuntimeIdentity {id} {
    variable registry
    if {$id eq "" || ![dict exists $registry $id identity]} {
        return ""
    }
    set entry [dict get $registry $id]
    set identity [dict get $entry identity]
    return [list [dict get $identity form] [lmap field [dict get $identity fields] {
        lsearch -exact [dict get $entry names] $field
    }]]
}

# The labels Totality and diagnostics give an identity's fields, in order:
# what a value's identity is made of, in the type's own terms -- never a
# field's name, which is representation (an opaque struct's fields are its
# owner's).
proc hir::structs::IdentityLabels {form} {
    switch -- $form {
        members { return {members} }
        associations { return {keys values} }
    }
    return {}
}

# The identity of struct declaration DECL (apply's; ID its identity, TYPES
# its resolved field types {FIELD TYPE ...}), checked: {form FORM fields
# {FIELD ...}}. Only an opaque struct may declare one (only its owner can
# make its values, so the owner's invariants hold), never a context struct;
# the form is one of identityForms with its number of fields, each a
# distinct field of the struct whose type is a List; and every field of the
# struct -- representation included -- is immutable (MutableComponent): an
# identity is a value's meaning, which must not change under it.
proc hir::structs::ValidateIdentity {decl id types} {
    variable identityForms
    set name [dict get $decl name]
    set clause [dict get $decl identity]
    set span [dict get $clause span]
    if {!([dict exists $decl opaque] && [dict get $decl opaque])} {
        Fail $span "struct \"$name\" declares an identity but is not opaque: only an opaque struct may define its equality by its contents (its owner alone makes its values, so the representation it projects is the owner's to keep consistent: declare it \"opaque struct $name\")"
    }
    if {[dict exists $decl context] && [dict get $decl context]} {
        Fail $span "context struct \"$name\" cannot declare an identity: a context is installed and required by its type, never compared or hashed"
    }
    set form [dict get $clause form]
    if {![dict exists $identityForms $form]} {
        Fail [dict get $clause formSpan] "unknown identity form \"$form\" in struct \"$name\": the forms are members(FIELD) -- the elements of a List field, in no order -- and associations(KEYS, VALUES) -- the pairs of two List fields, in no order"
    }
    set fields [dict get $clause fields]
    set want [dict get $identityForms $form]
    if {[llength $fields] != $want} {
        Fail $span "identity $form takes [expr {$want == 1 ? "one field" : "$want fields"}], got [llength $fields] in struct \"$name\""
    }
    set seen {}
    foreach field $fields fieldSpan [dict get $clause fieldSpans] {
        if {![dict exists $types $field]} {
            Fail $fieldSpan "identity $form of struct \"$name\" names \"$field\", which is not a field of it"
        }
        if {$field in $seen} {
            Fail $fieldSpan "identity $form of struct \"$name\" names field \"$field\" twice"
        }
        lappend seen $field
        set type [dict get $types $field]
        if {!([hir::types::IsList $type] && [llength $type] == 2)} {
            Fail $fieldSpan "identity $form of struct \"$name\" names field \"$field\" of type [hir::types::show $type]: an identity field is a List (List\[T\]), whose elements are what the identity is made of"
        }
    }
    foreach field [dict get $decl fields] {
        set type [dict get $types [dict get $field name]]
        set why [MutableComponent $type]
        if {$why ne ""} {
            Fail [dict get $field typeSpan] "struct \"$name\" declares an identity, so every value of it is an immutable value whose meaning never changes, but field \"[dict get $field name]\" ([hir::types::show $type]) holds $why"
        }
    }
    return [dict create form $form fields $fields]
}

# The first mutable or affine component of TYPE, described ("" for none): a
# MutableVector, a MutableArray, a coroutine handle, a C pointer or native
# view or edit, or a struct holding one. A type slot or `any` is no
# component of the declaration (an application decides its own values); a
# struct that declares an identity is immutable by its own check.
proc hir::structs::MutableComponent {type {seen {}}} {
    if {$type eq "never" || [hir::types::IsFn $type] || [hir::types::IsImprint $type]
            || [hir::types::IsTrait $type]} {
        return ""
    }
    if {[hir::types::IsAffine $type]} {
        return "an affine value"
    }
    switch -- [hir::types::kindOf $type] {
        mutvec { return "a MutableVector" }
        mutarray { return "a MutableArray" }
        cptr { return "a C pointer or native view" }
    }
    if {[hir::types::IsList $type] && [llength $type] == 2} {
        return [MutableComponent [lindex $type 1] $seen]
    }
    if {[hir::types::IsList $type]} {
        foreach t [lindex $type 2] {
            set why [MutableComponent $t $seen]
            if {$why ne ""} {
                return $why
            }
        }
        return ""
    }
    if {[hir::types::IsSet $type]} {
        return [MutableComponent [lindex $type 1] $seen]
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            set why [MutableComponent $t $seen]
            if {$why ne ""} {
                return $why
            }
        }
        return ""
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$type in $seen || ![declared $id] || [identityOf $id] ne ""} {
            return ""
        }
        if {[catch {AppliedFieldTypes $type} fields]} {
            return ""
        }
        foreach {name t} $fields {
            if {$t eq {}} continue
            set why [MutableComponent $t [concat $seen [list $type]]]
            if {$why ne ""} {
                if {[isOpaque $id]} {
                    # (An opaque struct's representation is its owner's.)
                    return "[hir::types::show $type], a mutable value"
                }
                return "[hir::types::show $type], whose field \"$name\" holds $why"
            }
        }
    }
    return ""
}

# {SLOTS CONSTRAINTS}: the type slots of struct declaration DECL (apply's)
# and the trait identities each one's `satisfies` names, {SLOT {TRAIT ...}
# ...} -- after checking them (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): a
# slot is named like an imprint variable (one capital letter, optionally
# digits), at most once; its trait is a trait declaration visible to the
# declaring namespace (TRAITS.md's lookup, `import type` included), never a
# context trait (installed contexts satisfy those, never a type). A context
# struct has no slots: its type is what a context parameter names exactly.
proc hir::structs::DeclaredSlots {decl} {
    set name [dict get $decl name]
    set ns [dict get $decl namespace]
    set slotNames {}
    set constraints [dict create]
    if {![dict exists $decl slots]} {
        return [list {} {}]
    }
    if {[dict exists $decl context] && [dict get $decl context]} {
        Fail [dict get $decl nameSpan] "context struct \"$name\" cannot have type slots: a context is installed and required by its exact struct type (CONTEXTS.md), and a type constructor has no type of its own (declare a context struct of the applied field types you need)"
    }
    foreach slot [dict get $decl slots] {
        set slotName [dict get $slot name]
        if {![hir::imprint::IsVariableName $slotName]} {
            Fail [dict get $slot nameSpan] "type slot \"$slotName\" of struct \"$name\": a slot is named like an imprint variable, one capital letter optionally followed by digits (T, K, V, T2)"
        }
        if {$slotName in $slotNames} {
            Fail [dict get $slot nameSpan] "duplicate type slot \"$slotName\" in struct \"$name\""
        }
        lappend slotNames $slotName
        set traits {}
        set spelled [dict get $slot trait]
        if {$spelled ne ""} {
            set trait [hir::traits::lookup $spelled $ns]
            if {$trait eq ""} {
                set why "no trait \"$spelled\" is visible here"
                if {[lookup $spelled $ns] ne "" || [hir::enums::lookup $spelled $ns] ne ""
                        || [core::type::valid [hir::types::CanonicalTypeName $spelled $ns]]} {
                    set why "\"$spelled\" is a type, not a trait: a slot is constrained only by a trait every argument must satisfy"
                }
                Fail [dict get $slot traitSpan] "unknown trait \"$spelled\" in \"$slotName satisfies $spelled\" (struct \"$name\"): $why"
            }
            if {[hir::traits::isContext $trait]} {
                Fail [dict get $slot traitSpan] "\"$slotName satisfies $spelled\" (struct \"$name\"): $trait is a context trait: installed contexts provide one, and no type satisfies it"
            }
            lappend traits $trait
        }
        dict set constraints $slotName $traits
    }
    return [list $slotNames $constraints]
}

# Adds the entries of DECLS (as apply takes them) to the registry without
# resetting it (native::prepareHir loading more modules into a program).
proc hir::structs::addDecls {decls} {
    variable registry
    variable affinity
    set saved $registry
    set entries [apply $decls]
    foreach {id entry} $saved {
        if {![dict exists $registry $id]} {
            dict set registry $id $entry
        }
    }
    set affinity [dict create]
    return $entries
}

# ---------------------------------------------------------------------------
# Static checks of field projection (STRUCTS.md "Field projection is static")
#
# A projection `receiver.name` is *proven* in an analysis context when the
# receiver's static type there is a struct type with a field `name`. Three
# things can be wrong, none ever a run-time event:
#
#   UNKNOWN-FIELD   the receiver is a struct type without that field
#   NOT-A-STRUCT    the receiver's type is statically some other kind
#   UNPROVEN-FIELD  the receiver's struct type is not known (`any`, a bare
#                   `struct`): there is no dynamic lookup to fall back to
#
# The first two are definitional: they hold in every context (an instance
# only ever refines the generic types, so a receiver that is a struct without
# the field, or an int, stays one). The third is the one semantic instances
# (hir/semantic.tcl) can cure: `fn first(x): x.value` has x : any in its
# generic analysis but is analyzed under the actual struct type of each exact
# call. So an unproven projection in function B's generic analysis is an error
# only if B's generic body can actually run -- B is *generically live*:
#
#   * the program's top level is live;
#   * B is live if a live context calls B without a semantic instance (the
#     call's arguments say nothing more than the generic entry types), or B's
#     value escapes (a reference that is not the callee of a call: it may be
#     called from anywhere, with anything);
#   * a live context is the generic analysis of a live block, or a semantic
#     instance some live context calls (its calls are analyzed under its own
#     concrete types).
#
# In an instance's own analysis every unproven projection is an error: that
# is where the proof must come from, reported (hir/semantic.tcl) at the call
# whose arguments made the instance invalid. No projection is ever lowered
# without a known slot, and no runtime guard or lookup exists for one that
# is not.

# "": the projection E is proven in HIR's current types; else {KIND MESSAGE}
# (KIND UNPROVEN-FIELD is the one an instance may cure).
proc hir::structs::ProjectionProblem {hir e} {
    if {[dict exists $hir exprs $e traitCallee]} {
        # The `receiver.op` of a trait operation (TRAITS.md) with no function
        # `op` visible: not a field access (hir::traits::TypeCall).
        return ""
    }
    set node [dict get $hir exprs $e]
    if {[dict exists $node methodRejected]} {
        # The callee of a rejected method-style call: no field access, and
        # its rejection is the call's diagnostic (hir::methods::Report).
        return ""
    }
    set receiver [dict get $node receiver]
    set type [hir::typeOf $hir $receiver]
    set name [dict get $node name]
    if {$type eq "never" || ![dict get $node reachable]} {
        return ""
    }
    set kind [hir::types::kindOf $type]
    set view [hir::layouts::OfNativeType $type]
    if {$view ne ""} {
        # A field read through a native view (NATIVE-LAYOUT-VIEWS.md) or a
        # native edit (NATIVE-LAYOUT-WRITES.md): the layout's fields,
        # nothing else.
        if {[hir::layouts::ViewFieldType $view $name] ne ""} {
            return ""
        }
        return [list UNKNOWN-FIELD [format {native %s type %s has no field "%s" (layout %s has fields: %s)} \
            [expr {[hir::types::IsNativeEdit $type] ? "edit" : "view"}] \
            [hir::types::show $type] $name $view [join [hir::layouts::StructNames $view] {, }]]]
    }
    set private [PrivateRepresentation $hir $type $node]
    if {$private ne ""} {
        return [list PRIVATE-ACCESS $private]
    }
    if {[projectionDenied $type $node]} {
        set problem OPAQUE-REPRESENTATION
    } elseif {[hir::types::IsStructLike $type]} {
        if {[hir::types::StructField $type $name] ne ""} {
            return ""
        }
        set problem UNKNOWN-FIELD
    } elseif {$kind ni {"" struct}} {
        set problem NOT-A-STRUCT
    } else {
        set problem UNPROVEN-FIELD
    }
    set hint ""
    if {[dict exists $node methodCallee] && $problem eq "UNPROVEN-FIELD"} {
        # The receiver's type is not known here: every intrinsic of that
        # name may be meant.
        set hint [MethodHint $name [IntrinsicsNamed $name]]
        if {[dict exists $node privateCandidates]} {
            append hint [::format { (%s %s private: not visible from here)} \
                [join [lmap c [dict get $node privateCandidates] {string cat ` $c `}] {, }] \
                [expr {[llength [dict get $node privateCandidates]] == 1 ? "is" : "are"}]]
        }
    } elseif {[dict exists $node privateCandidates]} {
        # A method-style call `receiver.NAME(args)` with no function NAME
        # visible, whose field call is rejected in every context, where the
        # functions of that name are private members of imported modules
        # (hir/privacy.tcl): the call is a private access.
        set ns [Owner [lindex [dict get $node privateCandidates] 0]]
        set decls [hir::privacy::Decls $hir]
        set entry [hir::privacy::Entry $decls $ns values $name]
        return [list PRIVATE-ACCESS "[hir::privacy::AccessMessage $ns $name [dict get $entry kind] [dict getdef $node ns ""]] (the method-style call \".${name}(...)\" applies only a function visible by that name)"]
    } elseif {[dict exists $node methodCallee]} {
        set candidates [UnimportedCandidates $hir $e $type]
        if {$candidates ne ""} {
            # A method-style call `receiver.NAME(args)` with no function NAME
            # visible, whose field call is rejected in every context, and a
            # function NAME the call would apply exists in a namespace this
            # code does not import: the import is what is missing, exactly as
            # for the explicit spelling NS::NAME(receiver, args)
            # (DIAGNOSTIC-RECOVERY.md).
            return [list MISSING-IMPORT [MissingImportMessage $name $candidates]]
        }
        set hint [MethodHint $name {}]
    }
    switch -- $problem {
        OPAQUE-REPRESENTATION {
            # The receiver is an opaque struct and this code is not its owner
            # (OPAQUE-STRUCTS.md): whatever the field is called, the access
            # needs the representation. The same message for a field that
            # exists and for one that does not, and no field named or listed.
            return [list OPAQUE-REPRESENTATION "[RepresentationMessage [lindex $type 1]]$hint"]
        }
        UNKNOWN-FIELD {
            return [list UNKNOWN-FIELD [format {struct type %s has no field "%s" (known fields: %s)%s} \
                [hir::types::show $type] $name [join [hir::types::StructLayout $type] {, }] $hint]]
        }
        NOT-A-STRUCT {
            return [list NOT-A-STRUCT [format {cannot project field "%s" from a value of type %s: only a struct has fields%s} \
                $name [hir::types::showValue $type] $hint]]
        }
    }
    return [list UNPROVEN-FIELD [format {cannot project field "%s": the receiver's struct type is not known here (its type is %s), and a field projection is resolved statically, never looked up at run time%s} \
        $name [hir::types::show $type] $hint]]
}

# What a projection problem adds when the projection is the callee of a
# method-style call `receiver.NAME(args)` that found no function NAME to
# apply (METHOD-SUGAR.md): the call is then a call of the field NAME, and the
# programmer may have meant the function spelling, which needs a function
# visible under that name here: one defined or bound in this file, or a member
# of a namespace this file directly imports (`import std::list` makes `std::list::at`
# a candidate for `xs.at(i)`; there is no search by receiver type).
# CANDIDATES (UnimportedCandidates) are the functions of that name the call
# would apply once their namespace is imported; a projection the receiver
# rejects in every context reports them as MISSING-IMPORT instead, so here
# they are only the ones a receiver whose type is not known may be meant for.
proc hir::structs::MethodHint {name candidates} {
    set hint [::format {; as a method-style call, no function named "%s" is visible here either: method syntax only applies a function that is already visible by that name (define it here, or import the namespace that defines it with `import NAMESPACE`)} \
        $name]
    if {$candidates ne ""} {
        append hint [::format { -- `%s` exist%s: add %s} \
            [join $candidates {`, `}] \
            [expr {[llength $candidates] == 1 ? "s" : ""}] \
            [join [lmap c $candidates {string cat "`import " [Owner $c] "`"}] { or }]]
    }
    return $hint
}

# The intrinsics named NAME in any namespace (`std::str::concat`), by namespace:
# cheap and deterministic (never a search of modules, which are only known
# once imported).
proc hir::structs::IntrinsicsNamed {name} {
    set owners {}
    foreach native [core::native::names] {
        if {![core::native::isQualifiedNative $native]} continue
        set i [string last :: $native]
        if {[string range $native [expr {$i + 2}] end] eq $name} {
            lappend owners [string range $native 0 [expr {$i - 1}]]
        }
    }
    return [lmap o [lsort $owners] {string cat $o :: $name}]
}

# The namespace of the qualified function name QUALIFIED.
proc hir::structs::Owner {qualified} {
    return [string range $qualified 0 [expr {[string last :: $qualified] - 1}]]
}

# The MISSING-IMPORT message of a method-style call `receiver.NAME(...)` whose
# applicable functions CANDIDATES (qualified names, sorted) are all in
# namespaces its code does not import -- the loader's message for the explicit
# spelling (surface/modules.tcl's CheckRef), naming the method form.
proc hir::structs::MissingImportMessage {name candidates} {
    set owners [lmap c $candidates {Owner $c}]
    if {[llength $candidates] == 1} {
        return [::format {namespace "%s" is not imported; add `import %s` to use `%s` (the method-style call ".%s(...)" applies only a function visible by that name)} \
            [lindex $owners 0] [lindex $owners 0] [lindex $candidates 0] $name]
    }
    return [::format {namespaces %s are not imported; add %s to use %s (the method-style call ".%s(...)" applies only a function visible by that name)} \
        [join [lmap o $owners {string cat \" $o \"}] { and }] \
        [join [lmap o $owners {string cat "`import " $o "`"}] { or }] \
        [join [lmap c $candidates {string cat ` $c `}] { or }] $name]
}

# The functions NAME that the method-style call whose callee is the
# projection E (`receiver.NAME`, receiver of static type TYPE) would apply if
# the code it is written in imported their namespace: by method resolution's
# own rules (hir/resolve.tcl's MethodCandidates, hir::methods::NativeMismatch),
# the member NAME of a namespace the code does not import -- an intrinsic
# (`std::str::concat`), or a function of a module this compilation loaded -- not
# declared nomethod, accepting the call's number of arguments (the receiver
# first) and, for an intrinsic, a first argument of the receiver's kind. The
# qualified names, sorted. No search of modules this compilation does not
# load (they are known only once imported), and no import is ever implied:
# the call is still rejected.
proc hir::structs::UnimportedCandidates {hir e type} {
    set node [dict get $hir exprs $e]
    set name [dict get $node name]
    set own [dict getdef $node ns ""]
    set imported [hir::imports::namespaces $own]
    set argCount [MethodArgCount $hir $e]
    set kind [hir::types::kindOf $type]
    set found {}
    foreach native [core::native::names] {
        if {![core::native::isQualifiedNative $native]} continue
        set i [string last :: $native]
        if {[string range $native [expr {$i + 2}] end] ne $name} continue
        set ns [string range $native 0 [expr {$i - 1}]]
        if {$ns in $imported || $ns eq $own} continue
        set meta [core::native::metadata $native]
        if {[dict get $meta nomethod]} continue
        set arity [dict get $meta arity]
        if {$arity ne "*" && $argCount ne "" && $arity != $argCount} continue
        set paramTypes [dict get $meta paramTypes]
        if {$paramTypes eq ""} {
            set wanted ""
        } else {
            set wanted [core::type::base [lindex $paramTypes 0]]
        }
        if {$kind ne "" && $wanted ni {"" any} && $kind ne $wanted} continue
        lappend found $native
    }
    if {[dict exists $hir modules]} {
        dict for {ns scope} [dict get $hir modules] {
            if {$ns in $imported || $ns eq $own || "${ns}::$name" in $found} continue
            # (After hygiene a module's own names are qualified,
            # hir::hygiene::qualifyModules.)
            set b ""
            foreach spelling [list ${ns}::$name $name] {
                if {[dict exists $hir scopes $scope names $spelling]} {
                    set b [dict get $hir scopes $scope names $spelling]
                    break
                }
            }
            if {$b eq ""} continue
            if {[dict exists $hir bindings $b nomethod]} continue
            if {[dict get $hir bindings $b kind] ne "local"} continue
            # (A private member is not this code's to import: hir/privacy.tcl.)
            if {[hir::privacy::Denied [hir::privacy::Decls $hir] $ns values $name $own]} continue
            lappend found "${ns}::$name"
        }
    }
    return [lsort -unique $found]
}

# The number of arguments, the receiver included, of the method-style call
# whose callee is the projection E, or "" if no call has it as its callee.
proc hir::structs::MethodArgCount {hir e} {
    dict for {c node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call" && [dict get $node callee] eq $e} {
            return [expr {[llength [dict get $node args]] + 1}]
        }
    }
    return ""
}

# Diagnoses the projection problems among the expressions EXPRS (an instance's
# region, hir/semantic.tcl): an unproven projection is always reported, since
# that is where an instance's proof has to come from. A flat scan: a struct
# program's projections are found by kind, never by walking the whole tree.
proc hir::structs::verifyExprs {hirVar exprs} {
    upvar 1 $hirVar hir
    foreach e $exprs {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] eq "call" && [dict exists $node method]} {
            # The instance knows the receiver's concrete type: a field the
            # generic analysis could not see may compete with the function.
            set problem [AmbiguousMethodCall $hir $e]
            if {$problem ne ""} {
                hir::DiagnoseAt hir AMBIGUOUS-METHOD-CALL $problem $e [dict get $node method nameOrigin]
            }
            continue
        }
        if {[dict get $node kind] eq "call"} {
            set problem [TreeChildrenProblem $hir $e]
            if {$problem ne ""} {
                lassign $problem kind message
                hir::Diagnose hir $kind $message $e
            }
            continue
        }
        if {[dict get $node kind] ne "project"} continue
        set problem [ProjectionProblem $hir $e]
        if {$problem ne ""} {
            lassign $problem kind message
            hir::DiagnoseAt hir $kind $message $e [dict get $node nameOrigin]
        }
    }
}

# "": E is no std::tree::children call (TREE-STRUCT-MILESTONE-1.md), or its
# argument is proven a tree struct's value in HIR's current types -- the
# children are its declaration's child field -- else {KIND MESSAGE}:
# UNPROVEN-FIELD when the argument's type is not known (std::tree::walk's
# generic body: the one problem a semantic instance cures, a projection's
# rule), TREE-OPERAND when it is statically some other type. A call is
# recognized by its native's registered result shape, never by its name.
proc hir::structs::TreeChildrenProblem {hir e} {
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "call" || ![dict exists $node target]} {
        return ""
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native" || [dict exists $node reachable] && ![dict get $node reachable]} {
        return ""
    }
    set name [dict get [hir::symbol $hir $target] name]
    if {![core::native::exists $name]
            || [lindex [dict get [core::native::metadata $name] resultShape] 0] ne "tree-children"} {
        return ""
    }
    set arg [lindex [dict get $node args] 0]
    if {$arg eq "" || [dict get $hir exprs $arg type] eq ""} {
        return ""
    }
    set type [hir::types::Unrefined [hir::typeOf $hir $arg]]
    if {$type eq "never"} {
        # (No value, or poison: hir/types.tcl.)
        return ""
    }
    if {[hir::types::IsNamedStruct $type] && [treeField [lindex $type 1]] ne ""} {
        return ""
    }
    if {[hir::types::kindOf $type] eq "" || $type eq "struct"} {
        return [list UNPROVEN-FIELD "cannot take the children of a tree: the value's type is not known here (its type is [hir::types::show $type]), and a tree's child field is found statically, from its tree struct type, never at run time (std::tree::walk walks a root whose tree struct type its call states)"]
    }
    return [list TREE-OPERAND "a tree's children are taken of a value of a tree struct, but this value's type is [hir::types::show $type] (a tree struct is declared \"tree struct NAME:\" with one field of type List\[NAME\])"]
}

# The generic verification of the whole program (hir::CheckOnce): every
# projection, found by a flat scan of the expression table. An unproven one is
# reported only when its function is generically live (above).
proc hir::structs::verify {hirVar} {
    upvar 1 $hirVar hir
    set live ""
    # Receiver bindings already reported (below).
    set receivers [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "call" && [dict exists $node method]} {
            set problem [AmbiguousMethodCall $hir $e]
            if {$problem ne ""} {
                hir::DiagnoseAt hir AMBIGUOUS-METHOD-CALL $problem $e [dict get $node method nameOrigin]
            }
            continue
        }
        if {[dict get $node kind] eq "call"} {
            set problem [TreeChildrenProblem $hir $e]
            if {$problem eq ""} continue
            lassign $problem kind message
            if {$kind eq "UNPROVEN-FIELD"} {
                if {$live eq ""} {
                    set live [GenericLive $hir]
                }
                set owner [OwnerBlock $hir $e]
                if {$owner ne "program" && $owner ni $live} continue
            }
            hir::Diagnose hir $kind $message $e
            continue
        }
        if {[dict get $node kind] ne "project"} continue
        set problem [ProjectionProblem $hir $e]
        if {$problem eq ""} continue
        lassign $problem kind message
        if {$kind eq "UNPROVEN-FIELD"} {
            if {$live eq ""} {
                set live [GenericLive $hir]
            }
            set owner [OwnerBlock $hir $e]
            if {$owner ne "program" && $owner ni $live} continue
        }
        if {$kind in {NOT-A-STRUCT OPAQUE-REPRESENTATION PRIVATE-ACCESS}} {
            # A failure of the receiver's type, whatever the field: one
            # written destructuring (`{a, b} = x`, an `on E {a, b}:` handler)
            # is the projections of one binding the front end synthesized,
            # and is one error, its first field's (DIAGNOSTIC-RECOVERY.md).
            set b [SynthesizedReceiver $hir $node]
            if {$b ne ""} {
                if {[dict exists $receivers $b]} continue
                dict set receivers $b 1
            }
        }
        hir::DiagnoseAt hir $kind $message $e [dict get $node nameOrigin]
    }
}

# The binding the receiver of projection NODE refers to when it is one the
# front end synthesized (a destructuring's hygienic temporary: no source
# spelling can name it, `#` is no identifier character), else "".
proc hir::structs::SynthesizedReceiver {hir node} {
    set receiver [dict get $hir exprs [dict get $node receiver]]
    if {[dict get $receiver kind] ne "ref" || [dict get $receiver binding] eq ""} {
        return ""
    }
    set b [dict get $receiver binding]
    set binding [dict get $hir bindings $b]
    set written [dict getdef $binding spelling [dict get $binding name]]
    if {[string first # $written] >= 0} {
        return $b
    }
    return ""
}

# "": the method-style call E (a call carrying `method`, i.e. written
# `receiver.NAME(args)` with a function NAME visible: METHOD-SUGAR.md) has
# exactly one meaning; else the message of its AMBIGUOUS-METHOD-CALL.
#
# The written form already meant something before the sugar existed: call the
# value of field NAME. When the receiver's static type is a struct with a
# field NAME that could hold a callable (anything not statically some other
# kind of value), both the field's value and the visible function are
# candidates for the one callee, and Botlish picks neither: the programmer
# writes `(receiver.NAME)(args)` for the field or `NAME(receiver, args)` for
# the function. A field statically of another kind (an Int, a String, ...)
# could never be called, so the function is the only candidate. A receiver
# whose struct type is not known here has no field the generic analysis can
# see; the call is the function call there, and a semantic instance
# (verifyExprs), which does know the receiver's concrete type, diagnoses the
# same ambiguity at the call that made the instance.
proc hir::structs::AmbiguousMethodCall {hir e} {
    set node [dict get $hir exprs $e]
    if {![dict get $node reachable]} {
        return ""
    }
    set receiver [lindex [dict get $node args] 0]
    set type [hir::typeOf $hir $receiver]
    if {$type eq "never" || ![hir::types::IsStructLike $type]} {
        return ""
    }
    set name [dict get $node method name]
    if {![FieldCompetes $type $name [dict get $node method]]} {
        return ""
    }
    return [format {method-style call "%s" is ambiguous: the receiver (type %s) has a field "%s" whose value may be callable, and a function "%s" is also visible here; write (receiver.%s)(...) to call the field, or %s(receiver, ...) to call the function} \
        $name [hir::types::show $type] $name $name $name $name]
}

# 1 if a receiver of the struct type TYPE (a struct-like type) has a field NAME
# that could compete with a visible function NAME for `receiver.NAME(args)`:
# the field exists, is visible to the code the call is in (CONTEXT carries its
# `ns`; an opaque struct's fields are not source-visible outside its owner,
# OPAQUE-STRUCTS.md, so they are not method candidates and cannot make the
# call ambiguous) and its value may be callable (anything not statically some
# other kind of value). The one rule of the field/function ambiguity above;
# the METHOD-ELIGIBLE warning (hir/warnings.tcl) asks it of the sugared
# spelling it would suggest.
proc hir::structs::FieldCompetes {type name context} {
    if {[projectionDenied $type $context]} {
        return 0
    }
    if {$name ni [hir::types::StructLayout $type]} {
        return 0
    }
    set fieldType [hir::types::StructField $type $name]
    return [expr {[hir::types::IsCallable $fieldType] || [hir::types::kindOf $fieldType] in {"" any block native}}]
}

# The innermost block whose body CODE of expression E is in ("program" at
# the top level).
proc hir::structs::OwnerBlock {hir e} {
    set invocation [dict get $hir scopes [dict get $hir exprs $e scope] invocation]
    if {$invocation eq ""} {
        return "program"
    }
    return $invocation
}

# The blocks whose generic analysis can actually run (see the header): a
# list of block ExprIds (`program` is always live).
proc hir::structs::GenericLive {hir} {
    # Every exact call, with its callee block and the block it is in -- a
    # coroutine construction's thunk being no block of its own: it takes no
    # argument and runs its one call exactly when the code that constructs
    # the coroutine does (hir/coroutines.tcl), so that call is the
    # constructing block's (TREE-STRUCT-MILESTONE-1.md: before, a function
    # reached only as a coroutine's root was never generically live).
    set thunks [dict getdef $hir coroutines thunks {}]
    set calls {}
    set callees [dict create]
    set escapes [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {![dict get $node reachable]} continue
        if {[dict get $node kind] eq "call"} {
            dict set callees [dict get $node callee] 1
            lassign [dict get $node target] kind target
            if {$kind eq "block"} {
                set owner [OwnerBlock $hir $e]
                while {[dict exists $thunks $owner]} {
                    set owner [OwnerBlock $hir $owner]
                }
                lappend calls [list $e $target $owner]
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {![dict get $node reachable] || [dict get $node kind] ne "ref"} continue
        if {[dict exists $callees $e]} continue
        set b [dict get $node binding]
        if {$b eq ""} continue
        set declaration [dict get $hir bindings $b declaredBy]
        if {$declaration eq "" || ![dict exists $hir exprs $declaration]} continue
        set value [dict get $hir exprs $declaration value]
        if {[dict get $hir exprs $value kind] eq "block"} {
            dict set escapes $value 1
        }
    }
    set semanticCalls [dict create]
    set instanceBlock [dict create]
    if {[dict exists $hir semantic]} {
        set semanticCalls [dict get $hir semantic calls]
        dict for {id inst} [dict get $hir semantic instances] {
            dict set instanceBlock $id [dict get $inst block]
        }
    }
    set liveBlocks [dict create program 1]
    set liveInstances [dict create]
    dict for {block _} $escapes {
        dict set liveBlocks $block 1
    }
    set changed 1
    while {$changed} {
        set changed 0
        foreach call $calls {
            lassign $call e target owner
            set contexts {}
            if {[dict exists $liveBlocks $owner]} {
                lappend contexts generic
            }
            dict for {id block} $instanceBlock {
                if {$block eq $owner && [dict exists $liveInstances $id]} {
                    lappend contexts $id
                }
            }
            foreach context $contexts {
                set key [list $context $e]
                if {[dict exists $semanticCalls $key]} {
                    set id [dict get $semanticCalls $key]
                    if {![dict exists $liveInstances $id]} {
                        dict set liveInstances $id 1
                        set changed 1
                    }
                } elseif {![dict exists $liveBlocks $target]} {
                    dict set liveBlocks $target 1
                    set changed 1
                }
            }
        }
    }
    return [dict keys $liveBlocks]
}

# The value printer (core/value.tcl) renders a value of an opaque struct by its
# nominal type only; whether an identity is opaque is this registry's
# knowledge (OPAQUE-STRUCTS.md).
core::value::setOpaqueStructTest hir::structs::isOpaque
# Likewise, equality and both hashes read a struct's declared identity from
# this registry (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md).
core::value::setIdentityTest hir::structs::RuntimeIdentity
# And which structs are tree structs, and their child slot, for the
# depth-unbounded walks of a tree value (TREE-STRUCT-MILESTONE-1.md).
core::value::setTreeTest hir::structs::RuntimeTree
