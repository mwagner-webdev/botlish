# traits.tcl -- eager structural traits (TRAITS.md).
#
#   hir::traits::declare DECLS          the trait names of a compilation
#   hir::traits::resolve                validates them; HIR's `traits` entries
#   hir::traits::lookup NAME NS         trait identity a spelling denotes, or ""
#   hir::traits::satisfies TYPE TRAIT   structural conformance + implementations
#   hir::traits::explain TYPE TRAIT     why TYPE does not satisfy TRAIT ("" if it does)
#
#   trait Named:
#       fn name(value: Named) -> str
#
# A trait is a nominal, statically resolved view: a *constraint* a concrete
# type satisfies structurally (every requirement has a compatible function in
# the namespace that owns the type), never a runtime value kind. It has no
# layout, no representation, no tag and no runtime membership test. Its
# identity is a namespace member's (`ui::Named` for a trait declared by
# lib/ui.bot, the bare name in the entry program), exactly like a struct or a
# refinement, and it is importable with `import type`.
#
# Types (hir/types.tcl)
# ---------------------
#   {trait ID}          the declared constraint: what a parameter or result
#                       annotation `value: Named` / `-> Named` resolves to
#   {trait ID WITNESS}  a *trait view*: the static type of a value accepted
#                       through that constraint. Source code sees only ID's
#                       requirements; WITNESS is the compiler's hidden static
#                       provenance -- a concrete type (the value's exact
#                       witness), {param E I} (the abstract witness of
#                       parameter I of block E, in its generic analysis) or
#                       {join W...} (several witnesses met at a join: always
#                       rejected, TRAIT-WITNESS-JOIN)
#
# A view is a subtype of its own constraint and of `any`, and of nothing else:
# no concrete type is ever recovered from it (no cast, test or strengthening),
# and no concrete type is a subtype of a constraint (trait weakening happens
# only at an explicit trait-typed boundary, hir::traits::Accept, never in
# lub).
#
# Conformance
# -----------
# Satisfies(T, N): T has one canonical owner namespace (WitnessOwner), and
# for every requirement R of N the owner's own function named R (a top-level
# `fn` of that module or of the entry program, or for a built-in scalar family
# the intrinsic of its namespace: `str::length`) has a signature compatible
# with R with N replaced by T, decided by the existing structural function
# compatibility (hir::types::FnMismatch: arity, contravariant parameters under
# declared-parameter admissibility, covariant result, error-set subset) from
# the implementation's *declared* signature. Nothing the call site imports or
# where it is written takes part: the answer is a property of T, N and the
# program's declarations, cached per compilation (Reset with the registry).

namespace eval hir::traits {
    # ID -> {id name namespace nameSpan span requirements {NAME REQ ...}
    # order {NAME ...}}: the registry of the current compilation's traits.
    # A requirement REQ is {name nameSpan span params {{name span type self}
    # ...} result {type self} | "" errors {E ...}}: SELF 1 marks the
    # trait's own type (the implementing witness).
    variable registry [dict create]
    # The implementation candidates of the current compilation: UNIT ("" for
    # the entry program, else a module namespace) -> NAME -> {kind block
    # binding B block E origin O} | {kind value binding B origin O}
    # (hir::traits::index, from the resolved program before any check).
    variable impls [dict create]
    # {TYPE ID} -> satisfies result, for the current registry and index.
    variable cache [dict create]
    # BindingId -> {UNIT NAME}: every unit-level binding's unit and source
    # name (before hygiene renames it), from the same index.
    variable unitNames [dict create]
}

proc hir::traits::Reset {} {
    variable registry
    variable impls
    variable cache
    set registry [dict create]
    set impls [dict create]
    set cache [dict create]
}

proc hir::traits::Fail {span kind message} {
    core::semanticError $kind "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

proc hir::traits::identity {name namespace} {
    return [expr {$namespace eq "" ? $name : "${namespace}::$name"}]
}

proc hir::traits::declared {id} {
    variable registry
    return [dict exists $registry $id]
}

# 1 if any trait is declared in the current compilation.
proc hir::traits::hasTraits {} {
    variable registry
    return [expr {[dict size $registry] > 0}]
}

proc hir::traits::owner {id} {
    variable registry
    return [dict get $registry $id namespace]
}

proc hir::traits::requirementNames {id} {
    variable registry
    return [dict get $registry $id order]
}

# The resolved requirement NAME of trait ID, or "".
proc hir::traits::requirement {id name} {
    variable registry
    if {![dict exists $registry $id requirements $name]} {
        return ""
    }
    return [dict get $registry $id requirements $name]
}

# The trait identity the type spelling NAME denotes in code of namespace NS
# ("" for the entry program), or "": a qualified spelling is exactly that
# member; a bare one is NS's own trait, else the trait the file's `import
# type` binds to that short name. A module never sees the entry program's
# traits (the same visibility as every source-defined type).
proc hir::traits::lookup {name {ns ""}} {
    variable registry
    if {[dict size $registry] == 0} {
        return ""
    }
    if {[string first :: $name] >= 0} {
        return [expr {[dict exists $registry $name] ? $name : ""}]
    }
    set own [identity $name $ns]
    if {[dict exists $registry $own]} {
        return $own
    }
    set imported [hir::imports::typeNamed $ns $name]
    if {$imported ne "" && [dict exists $registry $imported]} {
        return $imported
    }
    return ""
}

# Registers the names of DECLS (surface/lower.tcl's TraitDeclOf dicts), before
# any other type declaration is resolved, so a struct field, a refinement
# carrier or an applied type that names a trait is recognized as one (and
# rejected there: TRAIT-STORAGE-UNSUPPORTED). Requirements are resolved later
# (resolve), once every type they may mention is registered.
proc hir::traits::declare {decls} {
    variable registry
    Reset
    foreach decl $decls {
        set id [identity [dict get $decl name] [dict get $decl namespace]]
        if {[dict exists $registry $id]} {
            Fail [dict get $decl nameSpan] TRAIT-NAME-COLLISION "trait \"$id\" is already declared"
        }
        dict set registry $id [dict create id $id name [dict get $decl name] \
            namespace [dict get $decl namespace] nameSpan [dict get $decl nameSpan] \
            span [dict get $decl span] decl $decl requirements [dict create] order {} \
            context [expr {[dict exists $decl context] ? [dict get $decl context] : 0}]]
    }
}

# 1 if trait ID is a *context trait* (`context trait ID:`, CONTEXT-TRAITS.md):
# an environment abstraction whose requirements an installed context supplies
# and whose only use is through a context parameter, never a value type.
proc hir::traits::isContext {id} {
    variable registry
    return [expr {[dict exists $registry $id context] && [dict get $registry $id context]}]
}

# 1 if TYPE is the type of a context trait ({trait ID} with ID a context
# trait): the type of a context-trait binding (`context io: IO`).
proc hir::traits::IsContextTraitType {type} {
    return [expr {[hir::types::IsTrait $type] && [isContext [lindex $type 1]]}]
}

# Validates every declared trait and resolves its requirements' types
# (TRAITS.md, "Declarations"); returns HIR's `traits` entries, in declaration
# order: {id ID name NAME namespace NS requirements {REQ ...}}.
proc hir::traits::resolve {{sourceTypes {}}} {
    variable registry
    set entries {}
    # The type identities this compilation itself declared (the source-type
    # registry keeps a previous compilation's until the next one that
    # declares types: hir/sourcetypes.tcl, "Compilation isolation").
    set types [lmap t $sourceTypes {
        expr {[dict exists $t kind] && [dict get $t kind] eq "struct" ? [dict get $t id] : [dict get $t name]}
    }]
    foreach id [dict keys $registry] {
        set entry [dict get $registry $id]
        set name [dict get $entry name]
        set ns [dict get $entry namespace]
        set span [dict get $entry nameSpan]
        if {$name in {Int any never Fn} || [core::type::isBuiltinName $name]
                || [dict exists $::hir::types::constructors $name]} {
            Fail $span TRAIT-NAME-COLLISION "trait \"$name\" cannot be declared: the name is already a built-in type"
        }
        if {[hir::structs::declared $id] || $id in $types} {
            Fail $span TRAIT-NAME-COLLISION "trait \"$id\" cannot be declared: a type of that name is already declared (types, structs and traits share one namespace)"
        }
        if {![dict exists $entry decl]} {
            lappend entries [Entry $id]
            continue
        }
        set requirements [dict create]
        foreach r [dict get $entry decl requirements] {
            set rname [dict get $r name]
            if {[dict exists $requirements $rname]} {
                Fail [dict get $r nameSpan] TRAIT-DUPLICATE-REQUIREMENT \
                    "trait \"$id\" declares requirement \"$rname\" twice (at most one requirement per operation name: there is no overloading)"
            }
            if {[dict get $entry context]} {
                dict set requirements $rname [ResolveContextRequirement $id $ns $r]
            } else {
                dict set requirements $rname [ResolveRequirement $id $ns $r]
            }
        }
        dict set registry $id requirements $requirements
        dict set registry $id order [dict keys $requirements]
        dict unset registry $id decl
        lappend entries [Entry $id]
    }
    return $entries
}

# The HIR `traits` entry of trait ID.
proc hir::traits::Entry {id} {
    variable registry
    set entry [dict get $registry $id]
    return [dict create id $id name [dict get $entry name] namespace [dict get $entry namespace] \
        requirements [lmap n [dict get $entry order] {dict get $entry requirements $n}] \
        context [dict get $entry context]]
}

# Re-registers the `traits` entries of a serialized HIR (hir/read.tcl).
proc hir::traits::applyEntries {entries} {
    variable registry
    Reset
    foreach entry $entries {
        set requirements [dict create]
        foreach r [dict get $entry requirements] {
            dict set requirements [dict get $r name] $r
        }
        dict set registry [dict get $entry id] [dict create id [dict get $entry id] \
            name [dict get $entry name] namespace [dict get $entry namespace] nameSpan "" span "" \
            requirements $requirements order [dict keys $requirements] \
            context [expr {[dict exists $entry context] ? [dict get $entry context] : 0}]]
    }
}

# The resolved requirement R (a parsed requirement dict) of trait ID declared
# in namespace NS, validated (TRAITS.md, "Requirement restrictions"):
#
#   TRAIT-REQUIREMENT-RECEIVER  no ordinary parameter, or the first one is not
#                               declared as the trait itself
#   TRAIT-SELF-POSITION         the trait's own type in another parameter
#                               (a relational requirement: unsupported)
#   TRAIT-OTHER-TRAIT           another trait in a parameter or the result
#   UNDECLARED-ERROR / DUPLICATE  the `errors` clause, as for a function
#   TYPE                        an unknown or invalid type
proc hir::traits::ResolveRequirement {id ns r} {
    set rname [dict get $r name]
    set params [dict get $r params]
    set what "requirement \"$rname\" of trait \"$id\""
    if {$params eq {}} {
        Fail [dict get $r nameSpan] TRAIT-REQUIREMENT-RECEIVER \
            "$what has no parameter: its first ordinary parameter must be the trait itself (\"fn ${rname}(value: [dict get [Registry $id] name], ...)\"); static requirements are not supported"
    }
    set resolved {}
    set index 0
    foreach param $params {
        lassign $param pname pspan ptype ptypeSpan
        set where [expr {$ptypeSpan eq "" ? $pspan : $ptypeSpan}]
        if {$ptype eq ""} {
            if {$index == 0} {
                Fail $pspan TRAIT-REQUIREMENT-RECEIVER \
                    "$what: its first parameter \"$pname\" must be declared as the trait itself (\"$pname: [dict get [Registry $id] name]\")"
            }
            lappend resolved [dict create name $pname type any self 0]
            incr index
            continue
        }
        set type [ResolveType $ptype $ns $where "parameter \"$pname\" of $what"]
        set self 0
        if {[hir::types::IsTraitConstraint $type]} {
            if {[lindex $type 1] ne $id} {
                Fail $where TRAIT-OTHER-TRAIT \
                    "$what mentions another trait, [lindex $type 1], in parameter \"$pname\": requirements over other traits (trait composition) are not supported yet"
            }
            if {$index != 0} {
                Fail $where TRAIT-SELF-POSITION \
                    "$what uses the trait's own type in parameter \"$pname\": only the first parameter (and the result) may be the trait itself -- a relational requirement (two values of one witness) is not supported yet"
            }
            set self 1
        } elseif {$index == 0} {
            Fail $where TRAIT-REQUIREMENT-RECEIVER \
                "$what: its first parameter \"$pname\" must be declared as the trait itself, not [hir::types::show $type] (a requirement is an operation on a value of the trait)"
        } elseif {[hir::types::MentionsTrait $type]} {
            Fail $where TRAIT-OTHER-TRAIT "$what mentions a trait inside parameter \"$pname\"'s type: not supported"
        }
        lappend resolved [dict create name $pname type $type self $self]
        incr index
    }
    set result ""
    if {[dict get $r resultType] ne ""} {
        set where [dict get $r resultTypeSpan]
        set type [ResolveType [dict get $r resultType] $ns $where "the result of $what"]
        if {[hir::types::IsTraitConstraint $type]} {
            if {[lindex $type 1] ne $id} {
                Fail $where TRAIT-OTHER-TRAIT \
                    "$what returns another trait, [lindex $type 1]: requirements over other traits are not supported yet"
            }
            set result [dict create type $type self 1]
        } elseif {[hir::types::MentionsTrait $type]} {
            Fail $where TRAIT-OTHER-TRAIT "$what mentions a trait inside its result type: not supported"
        } else {
            set result [dict create type $type self 0]
        }
    }
    set errors {}
    foreach pair [dict get $r errors] {
        lassign $pair err errSpan
        if {$err in $errors} {
            Fail $errSpan DUPLICATE "duplicate error \"$err\" in the \"errors\" declaration of $what"
        }
        if {![hir::errordecls::isDeclared $err]} {
            Fail $errSpan UNDECLARED-ERROR "unknown error \"$err\" in $what: no \"error $err\" declaration is visible"
        }
        lappend errors $err
    }
    return [dict create name $rname nameSpan [dict get $r nameSpan] span [dict get $r span] \
        params $resolved result $result errors [lsort -unique $errors]]
}

# The resolved requirement R of *context trait* ID declared in namespace NS
# (CONTEXT-TRAITS.md, "Requirements"). A context-trait requirement is an
# ordinary signature with no receiver: the installed context is the implicit
# receiver, so every parameter is an ordinary value parameter (none is the
# trait's own type, `self` is always 0) and a requirement may take none.
#
#   TRAIT-OTHER-TRAIT           a trait (an ordinary trait or a context trait)
#                               in a parameter or the result: an operation whose
#                               applicability depended jointly on the context's
#                               witness and a value's witness is not supported
#                               yet, nor is a trait-typed (witness-carrying)
#                               result
#   UNDECLARED-ERROR / DUPLICATE  the `errors` clause, as for a function
#   TYPE                        an unknown or invalid type
proc hir::traits::ResolveContextRequirement {id ns r} {
    set rname [dict get $r name]
    set what "requirement \"$rname\" of context trait \"$id\""
    set resolved {}
    foreach param [dict get $r params] {
        lassign $param pname pspan ptype ptypeSpan
        set where [expr {$ptypeSpan eq "" ? $pspan : $ptypeSpan}]
        if {$ptype eq ""} {
            lappend resolved [dict create name $pname type any self 0]
            continue
        }
        set type [ResolveType $ptype $ns $where "parameter \"$pname\" of $what"]
        if {[hir::types::MentionsTrait $type]} {
            Fail $where TRAIT-OTHER-TRAIT \
                "$what mentions a trait ([hir::types::show $type]) in parameter \"$pname\": a context-trait requirement takes ordinary values only (an operation chosen jointly by the context's witness and a value's trait witness is not supported yet)"
        }
        lappend resolved [dict create name $pname type $type self 0]
    }
    set result ""
    if {[dict get $r resultType] ne ""} {
        set where [dict get $r resultTypeSpan]
        set type [ResolveType [dict get $r resultType] $ns $where "the result of $what"]
        if {[hir::types::MentionsTrait $type]} {
            Fail $where TRAIT-OTHER-TRAIT \
                "$what returns a trait ([hir::types::show $type]): a context-trait requirement returns an ordinary concrete value (trait-typed results of context operations are not supported yet)"
        }
        set result [dict create type $type self 0]
    }
    set errors {}
    foreach pair [dict get $r errors] {
        lassign $pair err errSpan
        if {$err in $errors} {
            Fail $errSpan DUPLICATE "duplicate error \"$err\" in the \"errors\" declaration of $what"
        }
        if {![hir::errordecls::isDeclared $err]} {
            Fail $errSpan UNDECLARED-ERROR "unknown error \"$err\" in $what: no \"error $err\" declaration is visible"
        }
        lappend errors $err
    }
    return [dict create name $rname nameSpan [dict get $r nameSpan] span [dict get $r span] \
        params $resolved result $result errors [lsort -unique $errors]]
}

proc hir::traits::Registry {id} {
    variable registry
    return [dict get $registry $id]
}

# TYPEEXPR resolved in namespace NS, or a located failure (the type error's
# own code when it has one, TYPE otherwise).
proc hir::traits::ResolveType {typeExpr ns span what} {
    if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} type options]} {
        set code [hir::resolve::TypeErrorKind $options TYPE]
        Fail $span $code "unknown or invalid type [hir::resolve::ShowTypeExpr $typeExpr] for $what: $type"
    }
    return $type
}

# ---------------------------------------------------------------------------
# Implementation candidates

# Records, from resolved HIR (before any check), every top-level definition
# of every unit -- each module section and the entry program -- by its
# source name: the only place conformance looks for an implementation
# (TRAITS.md, "Implementation lookup"). Called once per build; clears the
# conformance cache.
proc hir::traits::index {hir} {
    variable impls
    variable cache
    variable unitNames
    set impls [dict create]
    set cache [dict create]
    set unitNames [dict create]
    # Context-trait satisfaction reads the same index (CONTEXT-TRAITS.md).
    hir::contexts::ResetTraitCache
    set units [dict create "" [dict get $hir top]]
    if {[dict exists $hir modules]} {
        dict for {ns scope} [dict get $hir modules] {
            dict set units $ns $scope
        }
    }
    dict for {unit scope} $units {
        if {[dict get $hir scopes $scope kind] ne "program"} {
            continue
        }
        dict for {name b} [dict get $hir scopes $scope names] {
            set binding [dict get $hir bindings $b]
            set d [dict get $binding declaredBy]
            set info [dict create kind value binding $b origin [dict get $binding origin]]
            if {$d ne "" && [dict exists $hir exprs $d value]} {
                set value [dict get $hir exprs $d value]
                if {[dict get $hir exprs $value kind] eq "block"} {
                    set node [dict get $hir exprs $value]
                    set flags [expr {[dict exists $node flags] ? [dict get $node flags] : {}}]
                    set arity [expr {[llength [dict get $node params]] - [llength $flags]}]
                    set info [dict create kind block binding $b block $value origin [dict get $binding origin] \
                        params [lrange [dict get $node declaredParamTypes] 0 [expr {$arity - 1}]] \
                        result [dict get $node declaredResult] errors [dict get $node declaredErrors] \
                        flags $flags contexts [expr {[dict exists $node contextParams] ? [dict get $node contextParams] : {}}]]
                }
            }
            dict set impls $unit $name $info
            dict set unitNames $b [list $unit $name]
        }
    }
}

# The implementation index entry of NAME in UNIT, or "".
proc hir::traits::ImplInfo {unit name} {
    variable impls
    if {[dict exists $impls $unit $name]} {
        return [dict get $impls $unit $name]
    }
    return ""
}

# ---------------------------------------------------------------------------
# Witnesses and owners

# {OWNER KIND}: the canonical namespace that owns the concrete type TYPE and
# where its operations live (KIND module: a module or the entry program,
# OWNER "" for the entry program; KIND builtin: a scalar family whose
# operations are the intrinsics of namespace OWNER), or {"" none WHY}.
proc hir::traits::WitnessOwner {type} {
    if {[hir::types::IsNamedStruct $type]} {
        return [list [hir::structs::owner [lindex $type 1]] module]
    }
    if {$type in {any never}} {
        return [list "" none "its static type is $type, not a concrete type"]
    }
    if {[hir::types::IsTrait $type]} {
        return [list "" none "it is a trait view, not a concrete type"]
    }
    if {[hir::types::IsSpecific $type] || $type in {list immutableSet mutarray struct block native result}} {
        return [list "" none "[hir::types::show $type] is an applied, container or callable type: such types have no canonical owner namespace, so they are not supported as trait witnesses yet"]
    }
    if {[catch {core::type::evidenceOf $type} names]} {
        return [list "" none "[hir::types::show $type] is not a concrete type"]
    }
    if {$names ne {}} {
        if {[llength $names] > 1} {
            return [list "" none "a value statically known as several nominal types ([join $names {, }]) has no single witness"]
        }
        set name [lindex $names 0]
        if {[core::type::isRefinement $name]} {
            return [list [dict get [core::type::refinementOf $name] owner] module]
        }
        if {[core::type::isSource $name]} {
            set cut [string last :: $name]
            return [list [expr {$cut < 0 ? "" : [string range $name 0 [expr {$cut - 1}]]}] module]
        }
        return [list "" none "$name is a compiler-registered type with no source owner"]
    }
    switch -- [core::type::base $type] {
        str { return [list str builtin] }
        UnicodeChar { return [list char builtin] }
    }
    return [list "" none "[hir::types::show $type] has no canonical operation namespace"]
}

# "module \"m\"" / "the entry program" / "namespace \"str\"".
proc hir::traits::OwnerPhrase {owner kind} {
    if {$kind eq "builtin"} {
        return "the intrinsics of namespace \"$owner\""
    }
    return [expr {$owner eq "" ? "the entry program" : "module \"$owner\""}]
}

proc hir::traits::QualifiedName {owner name} {
    return [expr {$owner eq "" ? $name : "${owner}::$name"}]
}

# ---------------------------------------------------------------------------
# Conformance

# The required signature of requirement REQ for witness WITNESS: the
# structural function type {fn {args {...} return R errors {...}}} with the
# trait's own type replaced by WITNESS (a requirement without a result type
# returns any).
proc hir::traits::RequiredFn {req witness} {
    set args [lmap p [dict get $req params] {
        expr {[dict get $p self] ? $witness : [dict get $p type]}
    }]
    set result [dict get $req result]
    set ret [expr {$result eq "" ? "any" : ([dict get $result self] ? $witness : [dict get $result type])}]
    return [hir::types::MakeFn $args $ret [dict get $req errors]]
}

# Source text of the required signature of REQ for WITNESS: "fn name(model::
# Person) -> str errors E".
proc hir::traits::ShowRequired {req witness} {
    set fn [RequiredFn $req $witness]
    set text "fn [dict get $req name]([join [lmap t [hir::types::FnArgs $fn] {hir::types::show $t}] {, }])"
    if {[dict get $req result] ne ""} {
        append text " -> [hir::types::show [hir::types::FnReturn $fn]]"
    }
    if {[hir::types::FnErrors $fn] ne {}} {
        append text " errors [join [hir::types::FnErrors $fn] {, }]"
    }
    return $text
}

# The implementation of requirement REQ for WITNESS owned by OWNER (KIND as
# WitnessOwner gives), as {ok 1 impl IMPL} or {ok 0 reason WHY found TEXT}:
# IMPL {kind block unit U name NAME binding B block E} or {kind native name
# Q}.
proc hir::traits::Implementation {req witness owner kind} {
    set name [dict get $req name]
    set qualified [QualifiedName $owner $name]
    set required [RequiredFn $req $witness]
    set info ""
    if {$kind eq "module"} {
        set info [ImplInfo $owner $name]
    }
    if {$info eq "" && $owner ne "" && [core::native::isQualifiedNative $qualified]} {
        set info [dict create kind native name $qualified]
    }
    if {$info eq ""} {
        return [dict create ok 0 reason "no function $qualified exists: \"$name\" is not defined by [OwnerPhrase $owner $kind]" found ""]
    }
    switch -- [dict get $info kind] {
        value {
            return [dict create ok 0 reason "$qualified is not a function declaration (a value binding cannot implement a requirement)" found ""]
        }
        native {
            set meta [core::native::metadata $qualified]
            set actual [hir::types::structuralOf [list native $qualified]]
            if {$actual eq ""} {
                return [dict create ok 0 reason "$qualified takes a variable number of arguments, so it has no function type" found "native $qualified"]
            }
            set found "fn ${qualified}([join [lmap t [hir::types::FnArgs $actual] {hir::types::show $t}] {, }]) -> [hir::types::show [hir::types::FnReturn $actual]] (intrinsic)"
            set why [Mismatch $actual $required $req]
            if {$why ne ""} {
                return [dict create ok 0 reason $why found $found]
            }
            return [dict create ok 1 impl [dict create kind native name $qualified] found $found]
        }
        block {
            set params [lmap t [dict get $info params] {expr {$t eq {} ? "any" : $t}}]
            set declared [dict get $info result]
            set actual [hir::types::MakeFn $params [expr {$declared eq {} ? "any" : $declared}] [dict get $info errors]]
            set found [ShowFound $qualified $info]
            if {[dict get $info flags] ne {}} {
                return [dict create ok 0 reason "$qualified declares flags ([join [lmap f [dict get $info flags] {string cat : $f}] {, }]): implementations with flags are not supported yet" found $found]
            }
            if {[dict get $info contexts] ne {}} {
                return [dict create ok 0 reason "$qualified requires a context ([join [lmap c [dict get $info contexts] {dict get $c context}] {, }]): context-dependent implementations are not supported yet" found $found]
            }
            if {$declared eq {} && [dict get $req result] ne ""} {
                return [dict create ok 0 reason "$qualified declares no result type: conformance is decided from declarations, so an implementation of a requirement with a result must declare it (\"-> [hir::types::show [hir::types::FnReturn $required]]\")" found $found]
            }
            set why [Mismatch $actual $required $req]
            if {$why ne ""} {
                return [dict create ok 0 reason $why found $found]
            }
            return [dict create ok 1 found $found impl [dict create kind block unit $owner name $name \
                binding [dict get $info binding] block [dict get $info block]]]
        }
    }
}

# "fn model::name(model::Person) -> str errors E": an implementation
# candidate's declared signature.
proc hir::traits::ShowFound {qualified info} {
    set text "fn ${qualified}([join [lmap t [dict get $info params] {expr {$t eq {} ? "any" : [hir::types::show $t]}}] {, }])"
    if {[dict get $info result] ne {}} {
        append text " -> [hir::types::show [dict get $info result]]"
    }
    if {[dict get $info errors] ne {}} {
        append text " errors [join [dict get $info errors] {, }]"
    }
    return $text
}

# Why structural function type ACTUAL (an implementation's) is not usable as
# REQUIRED (requirement REQ's for one witness), "" if it is: the existing
# function compatibility (hir::types::FnMismatch), worded per part.
proc hir::traits::Mismatch {actual required req} {
    set why [hir::types::FnMismatch $actual $required]
    switch -- [lindex $why 0] {
        "" { return "" }
        arity {
            return "it takes [lindex $why 1] parameter(s), the requirement [lindex $why 2]"
        }
        arg {
            set i [lindex $why 1]
            return [format {parameter %d requires %s, which does not admit the required %s} \
                [expr {$i + 1}] [hir::types::show [lindex [hir::types::FnArgs $actual] $i]] \
                [hir::types::show [lindex [hir::types::FnArgs $required] $i]]]
        }
        return {
            return [format {return type %s does not satisfy required %s} \
                [hir::types::show [hir::types::FnReturn $actual]] [hir::types::show [hir::types::FnReturn $required]]]
        }
        errors {
            return [format {it may fail with %s, which the requirement's error contract [%s] does not admit} \
                [join [lrange $why 1 end] {, }] [join [hir::types::FnErrors $required] {, }]]
        }
    }
    return "incompatible signature"
}

# Whether concrete type TYPE satisfies trait ID: a dict {ok 0|1 trait ID
# witness TYPE owner NS ownerKind KIND impls {REQUIREMENT IMPL ...} reason
# WHY requirement NAME found TEXT} -- IMPLS the static implementation mapping
# (never materialized at run time), REASON/REQUIREMENT/FOUND the first
# missing or incompatible requirement when not ok. Cached per compilation on
# the canonical type and the trait identity.
proc hir::traits::satisfies {type id} {
    variable cache
    set type [hir::types::canonical $type]
    set key [list $type $id]
    if {[dict exists $cache $key]} {
        return [dict get $cache $key]
    }
    set result [dict create ok 0 trait $id witness $type owner "" ownerKind none impls {} \
        reason "" requirement "" found ""]
    if {![declared $id]} {
        dict set result reason "$id is not a declared trait"
    } elseif {[isContext $id]} {
        # A context trait (CONTEXT-TRAITS.md) is satisfied by installed
        # contexts (hir::contexts::satisfiesTrait), never by a value.
        dict set result reason "$id is a context trait: an installed context provides it, a value never satisfies it"
    } else {
        lassign [WitnessOwner $type] owner kind why
        dict set result owner $owner
        dict set result ownerKind $kind
        if {$kind eq "none"} {
            dict set result reason "[hir::types::show $type] cannot be a trait witness: $why"
        } else {
            set impls {}
            set ok 1
            foreach name [requirementNames $id] {
                set req [requirement $id $name]
                set found [Implementation $req $type $owner $kind]
                if {![dict get $found ok]} {
                    dict set result reason [dict get $found reason]
                    dict set result requirement $name
                    dict set result found [dict get $found found]
                    set ok 0
                    break
                }
                lappend impls $name [dict get $found impl]
            }
            dict set result ok $ok
            dict set result impls $impls
        }
    }
    dict set cache $key $result
    return $result
}

# "" if TYPE satisfies trait ID, else the TRAIT-NOT-SATISFIED explanation:
#
#   model::Thing does not satisfy ui::Named
#   required:
#       fn name(model::Thing) -> str   (declared at ui.bot:3:8)
#   found:
#       fn model::name(model::Thing) -> int   (at model.bot:9:4)
#   return type int does not satisfy required str
proc hir::traits::explain {type id {hir ""}} {
    set s [satisfies $type $id]
    if {[dict get $s ok]} {
        return ""
    }
    set lines [list "[hir::types::show $type] does not satisfy $id"]
    set name [dict get $s requirement]
    if {$name eq ""} {
        lappend lines [dict get $s reason]
        return [join $lines \n]
    }
    set req [requirement $id $name]
    set at [SpanText [dict get $req nameSpan]]
    lappend lines "required:" "    [ShowRequired $req [dict get $s witness]]$at"
    if {[dict get $s found] ne ""} {
        set where ""
        set info [ImplInfo [dict get $s owner] $name]
        if {$info ne "" && $hir ne ""} {
            set origin [dict get $info origin]
            if {[lindex $origin 0] eq "file" && [dict exists $hir files [lindex $origin 1]]} {
                set where "   (at [hir::originLocation $hir $origin])"
            }
        }
        lappend lines "found:" "    [dict get $s found]$where"
    }
    lappend lines [dict get $s reason]
    return [join $lines \n]
}

proc hir::traits::SpanText {span} {
    if {$span eq "" || ![dict exists $span file]} {
        return ""
    }
    return "   (declared at [dict get $span file]:[dict get $span line]:[dict get $span column])"
}

# ---------------------------------------------------------------------------
# Views in inference (hir/types.tcl, hir/semantic.tcl, hir/range.tcl)

# 1 if a value of static type TYPE is accepted where the trait constraint
# CONSTRAINT ({trait ID}) is declared: a view of that trait with one
# witness, or a concrete type that satisfies the trait. The trait-typed
# boundary is the only place a concrete type becomes a view.
proc hir::traits::Accept {type constraint} {
    set id [lindex $constraint 1]
    if {[hir::types::IsTrait $type]} {
        if {[lindex $type 1] ne $id} {
            return 0
        }
        return [expr {[hir::types::IsTraitConstraint $type]
            || ![hir::types::IsJoinWitness [hir::types::ViewWitness $type]]}]
    }
    if {$type eq "never"} {
        return 1
    }
    return [dict get [satisfies $type $id] ok]
}

# The view an argument of static type TYPE becomes at a parameter declared
# with trait constraint CONSTRAINT: the same view if it is one of that trait,
# else the view whose hidden witness is TYPE itself (when TYPE satisfies the
# trait), else the bare constraint (an inadmissible argument, rejected by
# hir::range::VerifyCall).
proc hir::traits::EntryView {type constraint} {
    set id [lindex $constraint 1]
    if {[hir::types::IsView $type] && [hir::types::ViewTrait $type] eq $id} {
        return $type
    }
    if {![hir::types::IsTrait $type] && $type ne "never" && [dict get [satisfies $type $id] ok]} {
        return [hir::types::MakeView $id [hir::types::canonical $type]]
    }
    return $constraint
}

# The abstract view parameter INDEX of block E, declared with trait
# constraint CONSTRAINT, has in E's generic analysis: its witness is the
# parameter's own, independent of every other parameter's.
proc hir::traits::AbstractView {constraint e index} {
    return [hir::types::MakeView [lindex $constraint 1] [list param $e $index]]
}

# The result type callers see of a function declaring result DECLARED whose
# body (and returns) give BODY: DECLARED itself unless it is a trait
# constraint; then the view with the body's one witness -- the input view's
# own for `fn same(v: Named) -> Named: v`, the concrete type for `fn make()
# -> Named: Person {...}` -- so later trait operations on the result keep
# resolving statically while the result stays source-visible as the trait.
proc hir::traits::ViewResult {declared body} {
    if {![hir::types::IsTraitConstraint $declared]} {
        return $declared
    }
    if {$body eq "never"} {
        return never
    }
    set id [lindex $declared 1]
    if {[hir::types::IsView $body] && [hir::types::ViewTrait $body] eq $id} {
        return $body
    }
    if {![hir::types::IsTrait $body] && [dict get [satisfies $body $id] ok]} {
        return [hir::types::MakeView $id [hir::types::canonical $body]]
    }
    return $declared
}

# The trait-call shape of call node NODE, or "": a call written with method
# syntax `receiver.name(args)` -- either resolved by the frontend to a call
# of a visible function `name` (NODE carries `method`; the receiver is its
# first argument) or left as the call of the field value `receiver.name`
# (the callee is a `project` marked methodCallee) -- as {name NAME receiver
# E args {E...} shape candidate|field}. Whether it IS a trait call is decided
# by the receiver's static type alone (TraitCallOf).
proc hir::traits::MethodShape {hir node} {
    if {[dict exists $node method]} {
        set args [dict get $node args]
        return [dict create name [dict get $node method name] receiver [lindex $args 0] \
            args [lrange $args 1 end] shape candidate]
    }
    set callee [dict get $node callee]
    set c [dict get $hir exprs $callee]
    if {[dict get $c kind] eq "project" && [dict exists $c methodCallee]} {
        return [dict create name [dict get $c name] receiver [dict get $c receiver] \
            args [dict get $node args] shape field]
    }
    return ""
}

# Types method-syntax call E (NODE) as a trait call when its receiver is
# statically a trait view (TRAITS.md, "Trait operations"): the method name is
# a requirement of the receiver's trait, whatever functions the code imports
# or declares -- the trait declaration is authoritative, so no concrete
# operation of the hidden witness is ever reachable this way, and no import
# can make the call ambiguous. Returns {RESULT ERRORS} (and records
# `traitCall` on E), or "" when E is not a trait call. The call has no target
# (no dynamic dispatch exists to give it one): its callee is typed as the
# requirement's structural contract for the receiver's trait -- the receiver
# position the trait constraint, the result the receiver's own view when the
# requirement returns the trait (the same witness) -- so argument
# admissibility, arity and the error contract are the ordinary checks of a
# call through a structural function type.
proc hir::traits::TypeCall {hirVar e node} {
    upvar 1 $hirVar hir
    set shape [MethodShape $hir $node]
    if {$shape eq ""} {
        return ""
    }
    set receiverType [hir::typeOf $hir [dict get $shape receiver]]
    if {![hir::types::IsTrait $receiverType]} {
        if {[dict exists $hir exprs $e traitCall]} {
            dict unset hir exprs $e traitCall
        }
        return ""
    }
    set id [lindex $receiverType 1]
    set name [dict get $shape name]
    set record [dict create trait $id requirement $name receiver [dict get $shape receiver] \
        args [dict get $shape args] shape [dict get $shape shape]]
    set req [requirement $id $name]
    if {$req eq ""} {
        dict set record unknown 1
        dict set hir exprs $e traitCall $record
        return [list any {}]
    }
    set result [dict get $req result]
    if {$result eq ""} {
        set type any
    } elseif {[dict get $result self]} {
        set type [expr {[hir::types::IsView $receiverType] ? $receiverType : [list trait $id]}]
    } else {
        set type [dict get $result type]
    }
    if {[isContext $id]} {
        # A context-trait operation (CONTEXT-TRAITS.md): the requirement has
        # no receiver parameter -- the context binding is the implicit
        # receiver, never an argument -- so every requirement parameter is
        # one of the written arguments.
        dict set record context 1
        set args [lmap p [dict get $req params] {dict get $p type}]
    } else {
        set args [lmap p [lrange [dict get $req params] 1 end] {dict get $p type}]
    }
    if {[dict get $shape shape] eq "candidate"} {
        set args [linsert $args 0 [list trait $id]]
    }
    set contract [hir::types::MakeFn $args $type [dict get $req errors]]
    dict set hir exprs [dict get $node callee] type [hir::types::intern hir $contract]
    if {[dict get $shape shape] eq "field"} {
        dict set hir exprs [dict get $node callee] traitCallee 1
    }
    dict set hir exprs $e traitCall $record
    return [list $type [dict get $req errors]]
}

# "ui::Named[witness model::Person]": a view with its hidden witness, for
# HIR debugging and audit output (never a source-level diagnostic).
proc hir::traits::showView {type} {
    if {![hir::types::IsView $type]} {
        return [hir::types::show $type]
    }
    return "[lindex $type 1]\[witness [ShowWitness [lindex $type 2]]\]"
}

proc hir::traits::ShowWitness {witness {hir ""}} {
    if {[hir::types::IsJoinWitness $witness]} {
        return [join [lmap w [lrange $witness 1 end] {ShowWitness $w $hir}] { | }]
    }
    if {[hir::types::IsAbstractWitness $witness]} {
        lassign $witness _ block index
        if {$hir ne "" && [dict exists $hir exprs $block params]} {
            set b [lindex [dict get $hir exprs $block params] $index]
            return "the witness of parameter \"[dict get $hir bindings $b name]\" of [hir::signatures::Name $hir $block]"
        }
        return "the witness of parameter [expr {$index + 1}] of $block"
    }
    return [hir::types::show $witness]
}

# The call's result TYPE for exact callee BLOCK given the call's ARGTYPES: a
# view whose witness is one of BLOCK's own abstract parameter witnesses ({param
# BLOCK I}: the callee returns a view it was given) is the view of argument
# I as the caller sees it -- the caller's provenance, never the callee's
# placeholder.
proc hir::traits::SubstituteResult {type block argTypes} {
    if {![hir::types::IsView $type]} {
        return $type
    }
    set w [hir::types::ViewWitness $type]
    if {![hir::types::IsAbstractWitness $w] || [lindex $w 1] ne $block} {
        return $type
    }
    set view [EntryView [lindex $argTypes [lindex $w 2]] [list trait [hir::types::ViewTrait $type]]]
    return [expr {[hir::types::IsView $view] ? $view : [list trait [hir::types::ViewTrait $type]]}]
}

# The TRAIT-NOT-SATISFIED message for an argument of static type ARGTYPE
# passed to parameter PARAM, declared with trait constraint CONSTRAINT.
proc hir::traits::NotSatisfiedMessage {hir param argType constraint} {
    set id [lindex $constraint 1]
    if {[hir::types::IsTrait $argType]} {
        if {[lindex $argType 1] ne $id} {
            return [format {argument for parameter "%s" is a view of trait %s, not of %s: a trait view satisfies only its own trait (there is no trait composition or conversion between traits)} \
                $param [lindex $argType 1] $id]
        }
        return [format {argument for parameter "%s" may have several witnesses (%s): heterogeneous trait values are not supported} \
            $param [ShowWitness [hir::types::ViewWitness $argType]]]
    }
    return "argument for parameter \"$param\" does not satisfy trait $id:\n[explain $argType $id $hir]"
}

# ---------------------------------------------------------------------------
# Static checks of trait use (hir::check, after inference)

# The diagnostics a trait view's misuse, a trait operation the trait does not
# declare, a witness join, a declared trait result and a trait-polymorphic
# function value get (TRAITS.md, "Diagnostics"). Reads the generic analysis:
# whether a value is a view, and what its trait is, never depends on an
# instance (a view only ever enters through a trait-typed declaration, and
# leaves at every untyped boundary).
proc hir::traits::verify {hirVar} {
    upvar 1 $hirVar hir
    if {![hasTraits]} {
        return
    }
    set parents [Parents $hir]
    set joined [dict create]
    dict for {e node} [dict get $hir exprs] {
        set kind [dict get $node kind]
        if {![dict get $node reachable]} {
            continue
        }
        switch -- $kind {
            call {
                VerifyCallUse hir $e $node
            }
            if {
                CheckOperand hir [dict get $node condition] "an \"if\" condition (a Boolean)"
            }
            listloop {
                CheckOperand hir [dict get $node iterable] "a loop's iterable (a List)"
            }
            countloop {
                CheckOperand hir [dict get $node start] "a counted loop's bound (an Int)"
                CheckOperand hir [dict get $node end] "a counted loop's bound (an Int)"
            }
            lockloop {
                foreach operand [hir::loopOperands $node] {
                    CheckOperand hir $operand "a loop operand"
                }
            }
            project {
                set parent [expr {[dict exists $parents $e] ? [dict get $parents $e] : ""}]
                set traitCallee [expr {$parent ne "" && [dict exists $hir exprs $parent traitCall]
                    && [dict get $hir exprs $parent callee] eq $e}]
                if {!$traitCallee} {
                    set t [hir::typeOf $hir [dict get $node receiver]]
                    # (A context-trait binding's misuse is CONTEXT-TRAIT-MISUSE,
                    # hir::contexts::CheckTraitBindings.)
                    if {[hir::types::IsTrait $t] && ![IsContextTraitType $t]} {
                        hir::DiagnoseAt hir TRAIT-VIEW-MISUSE [format {a %s trait view has no fields: ".%s" would inspect its concrete representation, which a trait never exposes (only the operations %s declares are available)} \
                            [hir::types::show $t] [dict get $node name] [lindex $t 1]] $e [dict get $node nameOrigin]
                    }
                }
            }
        }
        if {$kind in {if handle loop}} {
            set t [hir::typeOf $hir $e]
            if {[hir::types::IsView $t] && [hir::types::IsJoinWitness [hir::types::ViewWitness $t]]} {
                JoinDiagnostic hir $e $t
                dict set joined [OwnerBlock $hir $parents $e] 1
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![dict get $node reachable]} {
            continue
        }
        set declared [dict get $node declaredResult]
        if {[hir::types::IsTraitConstraint $declared]} {
            VerifyTraitResult hir $e $declared
        } elseif {![dict exists $joined $e] && [dict get $node resultType] ne ""} {
            set t [hir::type $hir [dict get $node resultType]]
            if {[hir::types::IsView $t] && [hir::types::IsJoinWitness [hir::types::ViewWitness $t]]} {
                JoinDiagnostic hir $e $t
            }
        }
    }
    VerifyFunctionValues hir $parents
    set roots [dict get $hir roots]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![IsPolymorphic $hir $e]} {
            continue
        }
        set parent [expr {[dict exists $parents $e] ? [dict get $parents $e] : ""}]
        if {$parent eq "" || [dict get $hir exprs $parent kind] ne "bind" || $parent ni $roots} {
            hir::Diagnose hir TRAIT-NESTED-POLYMORPHIC "a function with a trait-typed parameter must be declared at the top level of a module or the entry program: a nested trait-polymorphic function is not supported yet (its specializations would have to be made per activation of the enclosing function)" $e
        }
    }
    Promote hir
}

# Child ExprId -> parent ExprId, over the whole program.
proc hir::traits::Parents {hir} {
    set parents [dict create]
    dict for {e node} [dict get $hir exprs] {
        foreach child [hir::children $hir $e] {
            dict set parents $child $e
        }
        if {[dict get $node kind] eq "call"} {
            dict set parents [dict get $node callee] $e
        }
    }
    return $parents
}

# The block ExprId (or "program") whose body E is in, not entering nested
# blocks: E's nearest enclosing block. A coroutine construction's thunk
# (COROUTINES.md) is no owner: its body runs right at the construction, in
# the code around it (hir::contexts::Callee).
proc hir::traits::OwnerBlock {hir parents e} {
    while {[dict exists $parents $e]} {
        set e [dict get $parents $e]
        if {[dict get $hir exprs $e kind] eq "block"} {
            if {[dict exists $parents $e]
                    && [hir::coroutines::NativeOf $hir [dict get $parents $e]] eq [core::coroutines::createNative]} {
                continue
            }
            return $e
        }
    }
    return program
}

# Rejects operand E when it is a trait view: WHAT names the position.
proc hir::traits::CheckOperand {hirVar e what} {
    upvar 1 $hirVar hir
    set t [hir::typeOf $hir $e]
    if {[hir::types::IsTrait $t] && ![IsContextTraitType $t]} {
        hir::Diagnose hir TRAIT-VIEW-MISUSE [format {a %s trait view cannot be used as %s: only the operations %s declares are available on it} \
            [hir::types::show $t] $what [lindex $t 1]] $e
    }
}

# The checks of call E (NODE): an operation its trait does not declare, a
# view called, a view passed to a native that requires a kind of value (or
# tests one).
proc hir::traits::VerifyCallUse {hirVar e node} {
    upvar 1 $hirVar hir
    if {[dict exists $node traitCall]} {
        set record [dict get $node traitCall]
        if {[dict exists $record unknown]} {
            set id [dict get $record trait]
            set origin [expr {[dict exists $node method] ? [dict get $node method nameOrigin]
                : [dict get $hir exprs [dict get $node callee] nameOrigin]}]
            if {[isContext $id]} {
                hir::DiagnoseAt hir TRAIT-UNKNOWN-OPERATION [format {context trait %s has no operation "%s" (its operations: %s): a context-trait binding exposes exactly its trait's requirements, whatever installed context provides them} \
                    $id [dict get $record requirement] [join [requirementNames $id] {, }]] $e $origin
            } else {
                hir::DiagnoseAt hir TRAIT-UNKNOWN-OPERATION [format {trait %s has no operation "%s" (its operations: %s): a trait view exposes exactly its trait's requirements, whatever concrete type is underneath} \
                    $id [dict get $record requirement] [join [requirementNames $id] {, }]] $e $origin
            }
        }
        return
    }
    set calleeType [hir::typeOf $hir [dict get $node callee]]
    if {[IsContextTraitType $calleeType]} {
        return
    }
    if {[hir::types::IsTrait $calleeType]} {
        hir::Diagnose hir TRAIT-VIEW-MISUSE [format {a %s trait view is not callable} [hir::types::show $calleeType]] $e
        return
    }
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native"} {
        return
    }
    set name [dict get [hir::symbol $hir $target] name]
    if {[string first # $name] >= 0} {
        # An internal operation source cannot spell (context#install, ...):
        # its own verification diagnoses its operand (hir/contexts.tcl:
        # CONTEXT-TYPE-NOT-EXACT for an installed trait view).
        return
    }
    set meta [core::native::metadata $name]
    set i 0
    foreach arg [dict get $node args] {
        set t [hir::typeOf $hir $arg]
        set p [lindex [dict get $meta paramTypes] $i]
        incr i
        if {![hir::types::IsTrait $t] || [IsContextTraitType $t]} {
            continue
        }
        if {[dict get $meta testsType] ne ""} {
            hir::Diagnose hir TRAIT-VIEW-MISUSE [format {%s cannot test a %s trait view: a trait has no runtime membership test and its concrete type is never recovered (no type test, cast or downcast)} \
                $name [hir::types::show $t]] $arg
        } elseif {$p ni {"" any}} {
            hir::Diagnose hir TRAIT-VIEW-MISUSE [format {argument %d of %s requires %s, but the value is a %s trait view: only the operations %s declares are available on it (its concrete type is never recovered)} \
                $i $name [hir::types::show $p] [hir::types::show $t] [lindex $t 1]] $arg
        }
    }
}

proc hir::traits::JoinDiagnostic {hirVar e type} {
    upvar 1 $hirVar hir
    hir::Diagnose hir TRAIT-WITNESS-JOIN [format {expression has trait type %s but may contain either %s; heterogeneous trait values are not supported (there is no erased trait representation to hold a run-time choice between witnesses)} \
        [lindex $type 1] [join [lmap w [lrange [hir::types::ViewWitness $type] 1 end] {ShowWitness $w $hir}] { or }]] $e
}

# Checks the exits of block E, which declares trait result CONSTRAINT: each
# exit's value must be accepted by the trait (a view of it, or a concrete
# type satisfying it), and all must have one witness (TRAIT-WITNESS-JOIN).
proc hir::traits::VerifyTraitResult {hirVar e constraint} {
    upvar 1 $hirVar hir
    set id [lindex $constraint 1]
    set witnesses {}
    foreach exit [hir::warnings::Exits $hir $e] {
        lassign $exit site value
        set t [hir::typeOf $hir $value]
        if {$t eq "never"} {
            continue
        }
        if {![Accept $t $constraint]} {
            if {[hir::types::IsTrait $t]} {
                set message [format {the function's declared result is trait %s, but this exit returns a view of %s} $id [lindex $t 1]]
            } else {
                set message "the function's declared result is trait $id, but this exit's value does not satisfy it:\n[explain $t $id $hir]"
            }
            hir::Diagnose hir TRAIT-NOT-SATISFIED $message $site
            continue
        }
        set w [expr {[hir::types::IsView $t] ? [hir::types::ViewWitness $t] : [hir::types::canonical $t]}]
        if {$w ni $witnesses} {
            lappend witnesses $w
        }
    }
    if {[llength $witnesses] > 1} {
        hir::Diagnose hir TRAIT-WITNESS-JOIN [format {the function's result has trait type %s but may contain either %s; heterogeneous trait values are not supported (every exit of a trait-typed result needs the same witness)} \
            $id [join [lmap w $witnesses {ShowWitness $w $hir}] { or }]] $e
    }
}

# 1 if block expression E is a *trait function*: a parameter or its result
# is declared with a trait.
proc hir::traits::IsTraitFunction {hir e} {
    set node [dict get $hir exprs $e]
    foreach t [concat [dict get $node declaredParamTypes] [list [dict get $node declaredResult]]] {
        if {$t ne {} && [hir::types::IsTraitConstraint $t]} {
            return 1
        }
    }
    return 0
}

# The trait function binding B denotes (its function, or the function an
# immutable alias of it denotes), or "".
proc hir::traits::FunctionOf {hir b} {
    for {set depth 0} {$depth < 32} {incr depth} {
        if {![dict exists $hir bindings $b]} {
            return ""
        }
        set d [dict get $hir bindings $b declaredBy]
        if {$d eq "" || ![dict exists $hir exprs $d value]} {
            return ""
        }
        set value [dict get $hir exprs $d value]
        switch -- [dict get $hir exprs $value kind] {
            block {
                return [expr {[IsTraitFunction $hir $value] ? $value : ""}]
            }
            ref {
                set b [dict get $hir exprs $value binding]
                if {$b eq ""} { return "" }
            }
            default { return "" }
        }
    }
    return ""
}

# TRAIT-POLYMORPHIC-FUNCTION-VALUE: a trait function is called directly (by
# its name or an immutable alias), never used as a value -- an argument, an
# element, a field, a result -- because a general callable has no place to
# carry the compile-time witness its calls need (there is no runtime trait
# dispatch). Its declaration (or an alias) may not be the value of a body
# either.
proc hir::traits::VerifyFunctionValues {hirVar parents} {
    upvar 1 $hirVar hir
    set lasts [dict create]
    foreach body [concat [list [dict get $hir roots]] [lmap {e node} [dict get $hir exprs] {
                if {[dict get $node kind] eq "block"} { dict get $node body } else continue }]] {
        if {$body ne ""} {
            dict set lasts [lindex $body end] 1
        }
    }
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            if {
                foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
                    if {$body ne ""} { dict set lasts [lindex $body end] 1 }
                }
            }
            loop - listloop - countloop - lockloop {
                set body [dict get $node body]
                if {$body ne ""} { dict set lasts [lindex $body end] 1 }
            }
            handle {
                foreach body [dict get $node handlerBodies] {
                    if {$body ne ""} { dict set lasts [lindex $body end] 1 }
                }
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        set kind [dict get $node kind]
        if {$kind eq "bind" && [dict exists $lasts $e] && ![dict get $node duplicate]
                && [dict get $node binding] ne "" && [FunctionOf $hir [dict get $node binding]] ne ""} {
            hir::Diagnose hir TRAIT-POLYMORPHIC-FUNCTION-VALUE [format {"%s" is the value of this body, but it denotes the trait-polymorphic function %s, which is not a general callable value (its calls need compile-time witnesses; there is no runtime trait dispatch): call it directly} \
                [dict get $node name] [hir::signatures::Name $hir [FunctionOf $hir [dict get $node binding]]]] $e
            continue
        }
        if {$kind ne "ref" || [dict get $node binding] eq "" || ![dict get $node reachable]} {
            continue
        }
        set fn [FunctionOf $hir [dict get $node binding]]
        if {$fn eq ""} {
            continue
        }
        set parent [expr {[dict exists $parents $e] ? [dict get $parents $e] : ""}]
        if {$parent ne ""} {
            set pnode [dict get $hir exprs $parent]
            if {[dict get $pnode kind] eq "call" && [dict get $pnode callee] eq $e} {
                continue
            }
            if {[dict get $pnode kind] eq "bind" && ![dict get $pnode duplicate]} {
                # An immutable alias: its own uses are checked as the
                # function's.
                continue
            }
        }
        hir::Diagnose hir TRAIT-POLYMORPHIC-FUNCTION-VALUE [format {%s is a trait-polymorphic function (a parameter or its result is a trait): it can be called directly or through an immutable alias, but not used as a general function value, which has no place for the compile-time witnesses its calls need (there is no runtime trait dispatch)} \
            [hir::signatures::Name $hir $fn]] $e
    }
}

# Moves the root-cause trait diagnostics ahead of the others (after the
# opacity ones), keeping relative order: a rejected trait operation or join
# is typed so later checks can still run, and may surface as their
# consequence.
proc hir::traits::Promote {hirVar} {
    upvar 1 $hirVar hir
    set first {}
    set trait {}
    set rest {}
    foreach d [dict get $hir diagnostics] {
        set kind [dict get $d kind]
        if {$kind in {OPAQUE-CONSTRUCTION OPAQUE-REPRESENTATION TRAIT-NESTED-POLYMORPHIC CONTEXT-TRAIT-MISUSE}} {
            # (A context-trait binding used as a value is the cause of every
            # type error about that value.)
            lappend first $d
        } elseif {$kind in {TRAIT-UNKNOWN-OPERATION TRAIT-VIEW-MISUSE TRAIT-WITNESS-JOIN TRAIT-NOT-SATISFIED TRAIT-POLYMORPHIC-FUNCTION-VALUE}} {
            lappend trait $d
        } else {
            lappend rest $d
        }
    }
    dict set hir diagnostics [concat $first $trait $rest]
}

# ---------------------------------------------------------------------------
# Monomorphization (TRAITS.md, "Monomorphization")
#
# A trait program is checked once (the source program, with trait views and
# trait operations as above) and then built again from the same syntax,
# monomorphized: every trait-polymorphic function is replaced by one clone per
# combination of concrete witnesses its live calls pass (its semantic
# instances, hir/semantic.tcl, keyed by the full view types), each trait
# parameter typed by its witness; every trait operation becomes an ordinary
# direct call of the witness's implementation; every declared trait result
# becomes its witness type. The rebuilt program has no trait type, no trait
# operation and no trait-polymorphic function: every backend -- the
# interpreter, the Tcl compiler, native -- compiles ordinary direct calls of
# ordinary functions, with no wrapper, tag, dictionary or witness argument.
#
# A clone is placed (bound) at the top level of the unit whose statement
# first needs it, immediately before that statement, so every
# implementation it calls is established before it is (TRAIT-IMPL-ORDER
# otherwise). Its body is the source function's own syntax; each reference
# it makes outside the function is resolved to the binding the source
# function's resolution found, never by lexical lookup where it is placed.

namespace eval hir::traits {
    # The plan of the build in progress (hir::traits::monomorphize), {}
    # outside it.
    variable plan {}
    # KEY -> BindingId of each clone bound so far in the planned build.
    variable cloneBindings [dict create]
}

proc hir::traits::Planning {} {
    variable plan
    return [expr {$plan ne {}}]
}

proc hir::traits::Dropped {sid} {
    variable plan
    return [dict exists $plan drop $sid]
}

proc hir::traits::PlacedBefore {sid} {
    variable plan
    if {[dict exists $plan place $sid]} {
        return [dict get $plan place $sid]
    }
    return {}
}

proc hir::traits::CloneRecord {key} {
    variable plan
    return [dict get $plan clones $key]
}

proc hir::traits::NoteCloneBinding {key b} {
    variable cloneBindings
    dict set cloneBindings $key $b
}

proc hir::traits::CloneBinding {key} {
    variable cloneBindings
    return [dict get $cloneBindings $key]
}

proc hir::traits::ContextKey {ctx} {
    return [expr {[dict exists $ctx traitContext] ? [dict get $ctx traitContext] : "live"}]
}

# The identity syntax ref NODE resolves to in a clone's body (CTX inside one),
# or "" (ordinary resolution).
proc hir::traits::ExternalIdent {ctx node} {
    variable plan
    if {$plan eq {} || ![dict exists $ctx clone] || ![dict exists $node sid]} {
        return ""
    }
    set fn [dict get $ctx clone]
    set sid [dict get $node sid]
    if {[dict exists $plan externals $fn $sid]} {
        return [dict get $plan externals $fn $sid]
    }
    return ""
}

# The clone head record when block syntax NODE is the block of the clone
# CTX is resolving, else "".
proc hir::traits::CloneHead {ctx node} {
    if {![dict exists $ctx cloneHead] || ![dict exists $node sid]
            || [dict get $ctx cloneHead sid] ne [dict get $node sid]} {
        return ""
    }
    return [dict get $ctx cloneHead]
}

# The declared result block syntax NODE takes in the planned build: its
# witness type ("-": none, the body never completes), or "" (unchanged).
proc hir::traits::ResultOverride {ctx node head} {
    variable plan
    if {$head ne ""} {
        return [dict get $head result]
    }
    if {$plan eq {} || ![dict exists $node sid]} {
        return ""
    }
    set key [list [ContextKey $ctx] [dict get $node sid]]
    if {[dict exists $plan actions $key] && [lindex [dict get $plan actions $key] 0] eq "result"} {
        return [lindex [dict get $plan actions $key] 1]
    }
    return ""
}

# How the planned build resolves call syntax NODE in CTX: {redirect KEY},
# {trait RECORD}, {method IDENT}, `field` (a field-value call: no method
# candidates), or "" (ordinarily).
proc hir::traits::CallAction {ctx node} {
    variable plan
    if {$plan eq {} || ![dict exists $node sid]} {
        return ""
    }
    set sid [dict get $node sid]
    set key [list [ContextKey $ctx] $sid]
    if {[dict exists $plan actions $key] && [lindex [dict get $plan actions $key] 0] ne "result"} {
        return [dict get $plan actions $key]
    }
    if {[dict exists $ctx clone] && [dict exists $plan methods [dict get $ctx clone] $sid]} {
        return [dict get $plan methods [dict get $ctx clone] $sid]
    }
    return ""
}

# NODES and MODULES (hir::buildSyntax's syntax and -modules sections) with
# a program-unique `sid` on every syntax node, and the function declarations
# among them by sid: {NODES MODULES INDEX}. The sid is what the plan names a
# node by: an expression of the checked build maps back to the syntax node
# it came from, which the planned build resolves again (once per clone).
proc hir::traits::Stamp {nodes modules} {
    set counter 0
    set index [dict create]
    set nodes [lmap node $nodes {StampNode $node counter index}]
    set modules [lmap section $modules {
        dict set section nodes [lmap node [dict get $section nodes] {StampNode $node counter index}]
        set section
    }]
    return [list $nodes $modules $index]
}

proc hir::traits::StampNode {node counterVar indexVar} {
    upvar 1 $counterVar counter $indexVar index
    dict set node sid [incr counter]
    switch -- [dict get $node kind] {
        bind - return - ok - error {
            dict set node value [StampNode [dict get $node value] counter index]
            if {[dict get $node kind] eq "bind" && [dict get $node value kind] eq "block"} {
                dict set index [dict get $node sid] $node
            }
        }
        break {
            if {[dict get $node value] ne ""} {
                dict set node value [StampNode [dict get $node value] counter index]
            }
        }
        block - loop {
            dict set node body [lmap c [dict get $node body] {StampNode $c counter index}]
        }
        call {
            dict set node callee [StampNode [dict get $node callee] counter index]
            dict set node args [lmap c [dict get $node args] {StampNode $c counter index}]
        }
        if {
            dict set node condition [StampNode [dict get $node condition] counter index]
            dict set node thenBody [lmap c [dict get $node thenBody] {StampNode $c counter index}]
            dict set node elseBody [lmap c [dict get $node elseBody] {StampNode $c counter index}]
        }
        listloop {
            dict set node iterable [StampNode [dict get $node iterable] counter index]
            dict set node body [lmap c [dict get $node body] {StampNode $c counter index}]
        }
        countloop {
            dict set node start [StampNode [dict get $node start] counter index]
            dict set node end [StampNode [dict get $node end] counter index]
            dict set node body [lmap c [dict get $node body] {StampNode $c counter index}]
        }
        lockloop {
            dict set node domains [lmap d [dict get $node domains] {
                foreach f {iterable start end} {
                    if {[dict exists $d $f]} {
                        dict set d $f [StampNode [dict get $d $f] counter index]
                    }
                }
                set d
            }]
            dict set node body [lmap c [dict get $node body] {StampNode $c counter index}]
        }
        struct {
            dict set node fields [lmap f [dict get $node fields] {
                dict set f value [StampNode [dict get $f value] counter index]
                set f
            }]
        }
        project {
            dict set node receiver [StampNode [dict get $node receiver] counter index]
        }
        handle {
            dict set node call [StampNode [dict get $node call] counter index]
            dict set node handlers [lmap h [dict get $node handlers] {
                dict set h body [lmap c [dict get $h body] {StampNode $c counter index}]
                set h
            }]
        }
    }
    return $node
}

# 1 if block expression E declares a trait-typed parameter: a trait-
# polymorphic function.
proc hir::traits::IsPolymorphic {hir e} {
    foreach t [dict get $hir exprs $e declaredParamTypes] {
        if {$t ne {} && [hir::types::IsTraitConstraint $t]} {
            return 1
        }
    }
    return 0
}

proc hir::traits::IsConcreteWitness {w} {
    return [expr {$w ne "" && ![hir::types::IsAbstractWitness $w] && ![hir::types::IsJoinWitness $w]}]
}

# {I W ...}: the witness of each trait parameter I of block BLOCK in the
# entry types ENTRY of one of its instances, or "" if one is not concrete.
proc hir::traits::WitnessesOf {hir block entry} {
    set result {}
    set i 0
    foreach d [hir::signatures::entryTypes $hir $block] t $entry {
        if {$d ne {} && [hir::types::IsTraitConstraint $d]} {
            if {![hir::types::IsView $t] || ![IsConcreteWitness [hir::types::ViewWitness $t]]} {
                return ""
            }
            lappend result $i [hir::types::ViewWitness $t]
        }
        incr i
    }
    return $result
}

# The location-independent identity of binding B as a reference from outside
# its unit: {root NAME}, {entry NAME} or {module NS NAME} (NAME the source
# name), or "".
proc hir::traits::IdentOf {hir b} {
    variable unitNames
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "root"} {
        return [list root [dict get $binding name]]
    }
    if {[dict exists $unitNames $b]} {
        lassign [dict get $unitNames $b] unit name
        return [expr {$unit eq "" ? [list entry $name] : [list module $unit $name]}]
    }
    return ""
}

proc hir::traits::ImplIdent {impl} {
    if {[dict get $impl kind] eq "native"} {
        return [list native [dict get $impl name]]
    }
    set unit [dict get $impl unit]
    return [expr {$unit eq "" ? [list entry [dict get $impl name]] : [list module $unit [dict get $impl name]]}]
}

# A short, symbol-safe spelling of witness type W for clone names.
proc hir::traits::WitnessName {w} {
    if {[hir::types::IsNamedStruct $w]} {
        return [lindex $w 1]
    }
    if {![catch {core::type::evidenceOf $w} names] && $names ne {}} {
        return [join $names +]
    }
    return [hir::types::show $w]
}

# The monomorphization plan of checked HIR (the source build), or {diagnostics
# {D ...}} when the program cannot be monomorphized. SYNTAX is the stamped
# function declarations by sid (Stamp's INDEX).
proc hir::traits::Plan {hir syntax} {
    set diagnostics {}
    set roots [dict get $hir roots]
    set rootIndex [dict create]
    set i 0
    foreach r $roots {
        dict set rootIndex $r $i
        incr i
    }
    set parents [Parents $hir]
    # The functions the monomorphized program replaces by clones: top-level
    # declarations only (hir::traits::verify rejects any other trait-
    # polymorphic one, TRAIT-NESTED-POLYMORPHIC) that are trait-polymorphic
    # (a trait-typed parameter: one clone per witness tuple), or whose
    # context requirement includes a context trait (CONTEXT-TRAITS.md: one
    # clone under the provider the installed contexts statically select,
    # bound where every implementation it calls is established).
    set polys [dict create]
    foreach r $roots {
        set node [dict get $hir exprs $r]
        if {[dict get $node kind] ne "bind" || [dict get $hir exprs [dict get $node value] kind] ne "block"} {
            continue
        }
        set block [dict get $node value]
        set trait [IsPolymorphic $hir $block]
        set contextTraits [ContextTraitsOf $hir $block]
        if {(!$trait && $contextTraits eq {}) || ![dict exists $node sid]} {
            continue
        }
        set b [dict get $node binding]
        lassign [IdentOf $hir $b] where unitOrName name
        if {$where eq "entry"} {
            set ns ""
            set name $unitOrName
        } else {
            set ns $unitOrName
        }
        dict set polys $block [dict create bind $r binding $b sid [dict get $node sid] \
            namespace $ns name $name index [dict get $rootIndex $r] trait $trait \
            contextTraits $contextTraits selection [ContextSelection $hir $contextTraits]]
    }
    # Each expression's home: the replaced function whose body it is in (a
    # clone context), or "" (live code).
    set home [dict create]
    set byHome [dict create]
    set stack [lmap r [lreverse $roots] {list $r ""}]
    while {$stack ne {}} {
        lassign [lindex $stack end] e h
        set stack [lrange $stack 0 end-1]
        dict set home $e $h
        dict lappend byHome $h $e
        set inner [expr {[dict exists $polys $e] ? $e : $h}]
        foreach c [lreverse [hir::children $hir $e]] {
            lappend stack [list $c $inner]
        }
    }
    set sem [expr {[dict exists $hir semantic] ? [dict get $hir semantic] : {}}]
    set calls [expr {$sem ne {} ? [dict get $sem calls] : {}}]
    set instances [expr {$sem ne {} ? [dict get $sem instances] : {}}]
    set actions [dict create]
    set clones [dict create]
    set livePos [dict create]
    set edges [dict create]
    set implUses {}
    set queue [list live]
    set seen [dict create live 1]
    while {$queue ne {}} {
        set context [lindex $queue 0]
        set queue [lrange $queue 1 end]
        if {$context eq "live"} {
            set view $hir
            set h ""
            set caller generic
            set ckey live
        } else {
            if {[lindex $context 0] eq "contextfn"} {
                # A function whose requirement includes a context trait and
                # no trait parameter: one clone, analyzed generically.
                set h [lindex $context 1]
                set view $hir
                set caller generic
                set params {}
                set rt [expr {[dict get $hir exprs $h resultType] eq "" ? "any" : [hir::type $hir [dict get $hir exprs $h resultType]]}]
            } else {
                set inst [dict get $instances $context]
                set view [hir::semantic::View $hir $context]
                set h [dict get $inst block]
                set caller $context
                set params [WitnessesOf $hir $h [dict get $inst args]]
                set rt [dict get $inst result]
            }
            set fn [dict get $polys $h]
            set ckey [list $h $params [dict get $fn selection]]
            if {![dict exists $clones $ckey]} {
                set node [dict get $syntax [dict get $fn sid]]
                set result ""
                set declared [dict get $hir exprs $h declaredResult]
                if {[hir::types::IsTraitConstraint $declared]} {
                    if {$rt eq "never"} {
                        set result -
                    } elseif {[hir::types::IsView $rt] && [IsConcreteWitness [hir::types::ViewWitness $rt]]} {
                        set result [hir::types::ViewWitness $rt]
                    } else {
                        lappend diagnostics [list TRAIT-INTERNAL "the result witness of [dict get $fn name] for [WitnessText $params] is not known" $h]
                    }
                }
                set qualified [QualifiedName [dict get $fn namespace] [dict get $fn name]]
                set parts [lmap {i w} $params {WitnessName $w}]
                foreach {c w} [dict get $fn selection] {
                    lappend parts "$c=$w"
                }
                dict set clones $ckey [dict create key $ckey node $node namespace [dict get $fn namespace] \
                    function [dict get $fn sid] params $params result $result source $qualified \
                    selection [dict get $fn selection] \
                    name "$qualified<[join $parts ,]>" block $h]
            }
        }
        # The context traits this context's code has a provider for: the
        # clone's selection (live code has none: a context-trait operation or
        # a context-trait-dependent call there is never executed).
        set provided [expr {$ckey eq "live" ? {} : [lindex $ckey 2]}]
        foreach e [expr {[dict exists $byHome $h] ? [dict get $byHome $h] : {}}] {
            set node [dict get $view exprs $e]
            if {![dict exists $node sid]} {
                continue
            }
            set sid [dict get $node sid]
            switch -- [dict get $node kind] {
                call {
                    if {[dict exists $node traitCall] && [dict exists $node traitCall context]} {
                        # A context-trait operation (CONTEXT-TRAITS.md): a
                        # direct call of the selected context's
                        # implementation.
                        set record [dict get $node traitCall]
                        set id [dict get $record trait]
                        set req [dict get $record requirement]
                        if {[dict exists $record unknown] || ![dict exists $provided $id]} {
                            # No provider reaches this code: it is never
                            # executed (an operation in a nested function its
                            # enclosing function never calls).
                            SetAction actions diagnostics $ckey $sid [list unreachable] $e
                            continue
                        }
                        set w [dict get $provided $id]
                        set s [hir::contexts::satisfiesTrait $w $id]
                        if {![dict get $s ok]} {
                            lappend diagnostics [list TRAIT-INTERNAL "the selected context $w does not implement $id" $e]
                            continue
                        }
                        set impl [dict get [dict get $s impls] $req]
                        set operation [dict create trait $id requirement $req witness [list nstruct $w] \
                            impl [ImplIdent $impl] contract [RequiredFn [requirement $id $req] ""] \
                            implementation [QualifiedName [dict get $impl unit] [dict get $impl name]] context 1]
                        set implBlock [dict get $impl block]
                        if {[dict exists $polys $implBlock]} {
                            # The implementation itself requires a context
                            # trait: it is replaced by its own clone.
                            set k [list $implBlock {} [dict get $polys $implBlock selection]]
                            SetAction actions diagnostics $ckey $sid [list context $operation $k] $e
                            dict set edges $ckey $k 1
                            set j [list contextfn $implBlock]
                            if {![dict exists $seen $j]} {
                                dict set seen $j 1
                                lappend queue $j
                            }
                        } else {
                            SetAction actions diagnostics $ckey $sid [list context $operation] $e
                            lappend implUses [list $ckey $impl $e]
                        }
                    } elseif {[dict exists $node traitCall]} {
                        set record [dict get $node traitCall]
                        if {[dict exists $record unknown]} {
                            continue
                        }
                        set receiverType [hir::typeOf $view [dict get $record receiver]]
                        if {![hir::types::IsView $receiverType] || ![IsConcreteWitness [hir::types::ViewWitness $receiverType]]} {
                            lappend diagnostics [list TRAIT-INTERNAL "trait operation [dict get $record requirement] has no concrete witness here" $e]
                            continue
                        }
                        set w [hir::types::ViewWitness $receiverType]
                        set id [dict get $record trait]
                        set s [satisfies $w $id]
                        if {![dict get $s ok]} {
                            lappend diagnostics [list TRAIT-NOT-SATISFIED [explain $w $id $hir] $e]
                            continue
                        }
                        set req [dict get $record requirement]
                        set impl [dict get [dict get $s impls] $req]
                        set action [list trait [dict create trait $id requirement $req witness $w \
                            impl [ImplIdent $impl] contract [RequiredFn [requirement $id $req] $w] \
                            implementation [expr {[dict get $impl kind] eq "native" ? [dict get $impl name] : [QualifiedName [dict get $impl unit] [dict get $impl name]]}]]]
                        SetAction actions diagnostics $ckey $sid $action $e
                        lappend implUses [list $ckey $impl $e]
                    } else {
                        lassign [dict get $node target] tk tb
                        if {$tk ne "block" || ![dict exists $polys $tb]} {
                            continue
                        }
                        set fn [dict get $polys $tb]
                        if {[dict get $fn contextTraits] ne {}} {
                            # A call of a context-trait-dependent function
                            # reaches its clone only where the selection does:
                            # a reachable top-level call (verified: exactly one
                            # provider per context trait), or a reachable call
                            # in a clone that has the same providers. Anything
                            # else never runs (an unreachable call, a call in a
                            # nested function its enclosing function never
                            # calls).
                            set reaches [hir::get $hir $e reachable]
                            if {$reaches && $ckey eq "live"} {
                                set reaches [expr {[OwnerBlock $hir $parents $e] eq "program"}]
                            } elseif {$reaches} {
                                foreach c [dict get $fn contextTraits] {
                                    if {![dict exists $provided $c]} {
                                        set reaches 0
                                    }
                                }
                            }
                            if {!$reaches} {
                                SetAction actions diagnostics $ckey $sid [list unreachable] $e
                                continue
                            }
                            if {[dict get $fn selection] eq "-"} {
                                lappend diagnostics [list TRAIT-INTERNAL "a call of [dict get $fn name] has no selected context provider" $e]
                                continue
                            }
                        }
                        if {[dict get $fn trait]} {
                            if {![dict exists $calls [list $caller $e]]} {
                                lappend diagnostics [list TRAIT-INSTANCE-BUDGET [format {this call of the trait-polymorphic function %s has no static specialization (the compiler's semantic-instance budget declined it), and there is no runtime trait dispatch to fall back to} \
                                    [dict get $polys $tb name]] $e]
                                continue
                            }
                            set j [dict get $calls [list $caller $e]]
                            set witnesses [WitnessesOf $hir $tb [dict get $instances $j args]]
                            if {$witnesses eq ""} {
                                lappend diagnostics [list TRAIT-INTERNAL "a call of [dict get $polys $tb name] has no concrete witness" $e]
                                continue
                            }
                        } else {
                            set j [list contextfn $tb]
                            set witnesses {}
                        }
                        set k [list $tb $witnesses [dict get $fn selection]]
                        SetAction actions diagnostics $ckey $sid [list redirect $k] $e
                        if {$ckey eq "live"} {
                            set top [TopIndex $parents $rootIndex $e]
                            if {![dict exists $livePos $k] || $top < [dict get $livePos $k]} {
                                dict set livePos $k $top
                            }
                        } else {
                            dict set edges $ckey $k 1
                        }
                        if {![dict exists $seen $j]} {
                            dict set seen $j 1
                            lappend queue $j
                        }
                    }
                }
                block {
                    if {[dict exists $polys $e]} {
                        continue
                    }
                    set declared [dict get $node declaredResult]
                    if {![hir::types::IsTraitConstraint $declared]} {
                        continue
                    }
                    set rt [expr {[dict get $node resultType] eq "" ? "any" : [hir::type $view [dict get $node resultType]]}]
                    if {$rt eq "never"} {
                        SetAction actions diagnostics $ckey $sid [list result -] $e
                    } elseif {[hir::types::IsView $rt] && [IsConcreteWitness [hir::types::ViewWitness $rt]]} {
                        SetAction actions diagnostics $ckey $sid [list result [hir::types::ViewWitness $rt]] $e
                    } else {
                        lappend diagnostics [list TRAIT-INTERNAL "the result witness of this function is not known here" $e]
                    }
                }
            }
        }
    }
    if {$diagnostics ne {}} {
        return [dict create diagnostics $diagnostics]
    }
    # Placement: each clone before the earliest top-level statement that
    # needs it, directly or through the clones that call it.
    set pos $livePos
    set changed 1
    while {$changed} {
        set changed 0
        dict for {from targets} $edges {
            if {![dict exists $pos $from]} continue
            foreach to [dict keys $targets] {
                if {![dict exists $pos $to] || [dict get $pos $from] < [dict get $pos $to]} {
                    dict set pos $to [dict get $pos $from]
                    set changed 1
                }
            }
        }
    }
    # A clone calls the clones it needs, which are bound before it: the
    # calls between clones must form no cycle but a clone's own recursion.
    set order [TopoOrder [dict keys $clones] $edges cycle]
    if {$cycle ne {}} {
        set names [lmap k $cycle {dict get $clones $k name}]
        return [dict create diagnostics [list [list TRAIT-POLYMORPHIC-RECURSION [format {the specializations %s call each other in a cycle (polymorphic recursion across witnesses): each needs the other bound first, which this milestone's static specialization cannot do} \
            [join $names { and }]] [dict get $clones [lindex $cycle 0] block]]]]
    }
    set place [dict create]
    foreach k [lsort -command [list apply {{pos order a b} {
            set c [expr {[dict get $pos $a] - [dict get $pos $b]}]
            if {$c != 0} { return $c }
            return [expr {[lsearch -exact $order $a] - [lsearch -exact $order $b]}]
        }} $pos $order] [dict keys $clones]] {
        set root [lindex $roots [dict get $pos $k]]
        dict lappend place [dict get $hir exprs $root sid] $k
        dict set clones $k position [dict get $pos $k]
    }
    # Every implementation a statement (or a clone placed before it) calls is
    # bound before it.
    foreach use $implUses {
        lassign $use ckey impl e
        if {[dict get $impl kind] ne "block"} {
            continue
        }
        set implRoot [dict get $hir bindings [dict get $impl binding] declaredBy]
        if {![dict exists $rootIndex $implRoot]} {
            continue
        }
        set implPos [dict get $rootIndex $implRoot]
        if {$ckey eq "live"} {
            set usePos [TopIndex $parents $rootIndex $e]
            if {$implPos < $usePos || ($implPos == $usePos && [Inside $parents $e [dict get $impl block]])} {
                continue
            }
            set what "this trait operation"
        } else {
            set usePos [dict get $pos $ckey]
            if {$implPos < $usePos} {
                continue
            }
            set what "the specialization [dict get $clones $ckey name] (needed before [hir::originLocation $hir [dict get $hir exprs [lindex $roots $usePos] origin]])"
        }
        lappend diagnostics [list TRAIT-IMPL-ORDER [format {%s calls the implementation %s, which is not established yet at that point: a trait operation needs its implementation declared before the code that first uses it (as for any function: no forward references)} \
            $what [QualifiedName [dict get $impl unit] [dict get $impl name]]] $e]
    }
    if {$diagnostics ne {}} {
        return [dict create diagnostics $diagnostics]
    }
    # The declarations the clones replace, and the aliases of them.
    set drop [dict create]
    dict for {block fn} $polys {
        dict set drop [dict get $fn sid] 1
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "bind" && [dict exists $node sid] && ![dict get $node duplicate]
                && [hir::kind $hir [dict get $node value]] eq "ref"} {
            set fn [FunctionOf $hir [dict get $node binding]]
            if {$fn eq ""} {
                # An alias of a context-trait-dependent function.
                set fn [hir::contexts::Denotes $hir [dict get $node binding]]
            }
            if {$fn ne "" && [dict exists $polys $fn]} {
                dict set drop [dict get $node sid] 1
            }
        }
    }
    # What a clone's body refers to outside its function, and the function
    # each method-syntax call in it chose.
    set externals [dict create]
    set methods [dict create]
    dict for {block fn} $polys {
        set bodyScope [dict get $hir exprs $block bodyScope]
        set fsid [dict get $fn sid]
        set work [list $block]
        while {$work ne {}} {
            set e [lindex $work end]
            set work [lrange $work 0 end-1]
            set node [dict get $hir exprs $e]
            lappend work {*}[hir::children $hir $e]
            if {![dict exists $node sid]} {
                continue
            }
            switch -- [dict get $node kind] {
                ref {
                    set b [dict get $node binding]
                    if {$b eq "" || [hir::scopeWithin $hir [dict get $hir bindings $b scope] $bodyScope]} {
                        continue
                    }
                    set ident [IdentOf $hir $b]
                    if {$ident ne ""} {
                        dict set externals $fsid [dict get $node sid] $ident
                    }
                }
                call {
                    if {[dict exists $node traitCall]} {
                        continue
                    }
                    if {[dict exists $node method]} {
                        set callee [dict get $hir exprs [dict get $node callee]]
                        set b [expr {[dict exists $callee binding] ? [dict get $callee binding] : ""}]
                        if {$b eq ""} {
                            continue
                        }
                        if {[hir::scopeWithin $hir [dict get $hir bindings $b scope] $bodyScope]} {
                            set binding [dict get $hir bindings $b]
                            set ident [list local [expr {[dict exists $binding spelling] ? [dict get $binding spelling] : [dict get $binding name]}]]
                        } else {
                            set ident [IdentOf $hir $b]
                        }
                        if {$ident ne ""} {
                            dict set methods $fsid [dict get $node sid] [list method $ident]
                        }
                    } elseif {[hir::kind $hir [dict get $node callee]] eq "project"
                            && [dict exists $hir exprs [dict get $node callee] methodCallee]} {
                        dict set methods $fsid [dict get $node sid] field
                    }
                }
            }
        }
    }
    return [dict create clones $clones actions $actions place $place drop $drop \
        externals $externals methods $methods polys $polys]
}

# The context traits block E's requirement includes (CONTEXT-TRAITS.md),
# sorted: what makes E context-trait-dependent.
proc hir::traits::ContextTraitsOf {hir e} {
    set result {}
    foreach id [hir::contexts::required $hir $e] {
        if {[isContext $id]} {
            lappend result $id
        }
    }
    return $result
}

# {TRAIT WITNESS ...}: the installed context the program statically selected
# for each of context traits TRAITS (hir::contexts::verify's `selected`), or
# "-" when one of them has no selection (no top-level call reaches a function
# requiring it: its code is never executed).
proc hir::traits::ContextSelection {hir traits} {
    set result {}
    foreach id $traits {
        if {![dict exists $hir contexts selected $id]} {
            return -
        }
        lappend result $id [dict get $hir contexts selected $id]
    }
    return $result
}

proc hir::traits::WitnessText {params} {
    return [join [lmap {i w} $params {hir::types::show $w}] {, }]
}

proc hir::traits::SetAction {actionsVar diagnosticsVar ckey sid action e} {
    upvar 1 $actionsVar actions $diagnosticsVar diagnostics
    set key [list $ckey $sid]
    if {[dict exists $actions $key] && [dict get $actions $key] ne $action} {
        lappend diagnostics [list TRAIT-INTERNAL "conflicting specializations of one expression: [dict get $actions $key] and $action" $e]
        return
    }
    dict set actions $key $action
}

# The index (in ROOTINDEX) of the top-level statement expression E is in.
proc hir::traits::TopIndex {parents rootIndex e} {
    while {![dict exists $rootIndex $e]} {
        set e [dict get $parents $e]
    }
    return [dict get $rootIndex $e]
}

# 1 if expression E is inside block expression BLOCK.
proc hir::traits::Inside {parents e block} {
    while {[dict exists $parents $e]} {
        set e [dict get $parents $e]
        if {$e eq $block} {
            return 1
        }
    }
    return 0
}

# NODES in an order where every node follows the nodes EDGES ({FROM {TO 1
# ...}}) says it calls (callees first), self edges ignored; CYCLEVAR receives
# the nodes of a cycle, if any ("" when acyclic).
proc hir::traits::TopoOrder {nodes edges cycleVar} {
    upvar 1 $cycleVar cycle
    set cycle {}
    set order {}
    set state [dict create]
    foreach n $nodes {
        if {[dict exists $state $n]} continue
        set stack [list [list $n 0]]
        dict set state $n 1
        while {$stack ne {}} {
            lassign [lindex $stack end] x i
            set targets [expr {[dict exists $edges $x] ? [dict keys [dict get $edges $x]] : {}}]
            set targets [lsearch -all -inline -exact -not $targets $x]
            if {$i < [llength $targets]} {
                lset stack end [list $x [expr {$i + 1}]]
                set t [lindex $targets $i]
                if {![dict exists $state $t]} {
                    dict set state $t 1
                    lappend stack [list $t 0]
                } elseif {[dict get $state $t] == 1} {
                    set cycle [list $t $x]
                    return {}
                }
                continue
            }
            dict set state $x 2
            lappend order $x
            set stack [lrange $stack 0 end-1]
        }
    }
    return $order
}

# The monomorphized program of checked trait program HIR (the source build,
# no diagnostics), built again from the stamped syntax NODES with the
# options of hir::buildSyntax (hir::BuildOnce's OPTIONS and GIVEN); SYNTAX
# as for Plan. A plan that cannot be made -- an implementation used before
# it is established, polymorphic recursion across witnesses, a declined
# specialization -- is diagnosed on HIR, which is returned as is.
proc hir::traits::monomorphize {nodes options given hir syntax} {
    variable plan
    variable cloneBindings
    set p [Plan $hir $syntax]
    if {[dict exists $p diagnostics]} {
        foreach d [dict get $p diagnostics] {
            lassign $d kind message e
            hir::Diagnose hir $kind $message $e
        }
        return $hir
    }
    set plan $p
    set cloneBindings [dict create]
    try {
        set mono [hir::BuildOnce $nodes $options $given [dict get $hir methodChoices] 0 checked]
    } finally {
        set plan {}
        set cloneBindings [dict create]
    }
    if {[dict get $mono diagnostics] ne {}} {
        # A monomorphized program is the checked one with every trait
        # resolved: a problem here is the compiler's, said so.
        dict set mono diagnostics [lmap d [dict get $mono diagnostics] {
            dict set d message "in the monomorphized program: [dict get $d message]"
            set d
        }]
    }
    dict set mono traitFunctions [FunctionsSummary $hir $p]
    # The checked source program: what compiler warnings are about (each
    # source function once, a trait-polymorphic one included whether or not
    # it has clones). No analysis or backend reads it.
    dict set mono traitSource $hir
    return $mono
}

# HIR's `traitFunctions`: each trait-polymorphic function of the source
# program, by its qualified name, with its source signature and its clones --
# {name {params {P TYPE ...} result TYPE clones {CLONE {P WITNESS ...} ...}}}
# -- the record of what the monomorphized program replaced (hir::format
# prints it; no analysis reads it).
proc hir::traits::FunctionsSummary {hir p} {
    set summary [dict create]
    dict for {block fn} [dict get $p polys] {
        set node [dict get $hir exprs $block]
        set params {}
        foreach b [dict get $node params] t [dict get $node declaredParamTypes] {
            lappend params [dict get $hir bindings $b name] [expr {$t eq {} ? "any" : $t}]
        }
        set clones {}
        dict for {k clone} [dict get $p clones] {
            if {[dict get $clone block] ne $block} continue
            set ws {}
            foreach {i w} [dict get $clone params] {
                lappend ws [dict get $hir bindings [lindex [dict get $node params] $i] name] $w
            }
            lappend clones [dict get $clone name] $ws
        }
        set result [dict get $node declaredResult]
        dict set summary [QualifiedName [dict get $fn namespace] [dict get $fn name]] \
            [dict create params $params result [expr {$result eq {} ? "" : $result}] clones $clones]
    }
    return $summary
}

# ---------------------------------------------------------------------------
# Tooling

# A readable report of HIR's traits (main.tcl -traits): every trait with its
# requirements; every conformance the program relies on -- the concrete
# witness, the trait, and the implementation of each requirement, read from
# the clones' parameter views and the trait operations of the monomorphized
# program and re-derived by hir::traits::satisfies; and every trait-
# polymorphic function with its specializations.
proc hir::traits::report {hir} {
    if {![dict exists $hir traits]} {
        return "no traits"
    }
    set lines {}
    foreach entry [dict get $hir traits] {
        set owner [dict get $entry namespace]
        set kind [expr {[dict exists $entry context] && [dict get $entry context] ? "context trait" : "trait"}]
        lappend lines "$kind [dict get $entry id] (owner: [expr {$owner eq "" ? "entry program" : $owner}])"
        foreach r [dict get $entry requirements] {
            set text "    fn [dict get $r name]([join [lmap p [dict get $r params] {format {%s: %s} [dict get $p name] [hir::types::show [dict get $p type]]}] {, }])"
            if {[dict get $r result] ne ""} {
                append text " -> [hir::types::show [dict get $r result type]]"
            }
            if {[dict get $r errors] ne {}} {
                append text " errors [join [dict get $r errors] {, }]"
            }
            lappend lines $text
        }
    }
    set pairs {}
    dict for {b binding} [dict get $hir bindings] {
        if {[dict exists $binding view]} {
            set view [dict get $binding view]
            lappend pairs [list [lindex $view 2] [lindex $view 1]]
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict exists $node traitImpl]} {
            lappend pairs [list [dict get $node traitImpl witness] [dict get $node traitImpl trait]]
        }
    }
    if {$pairs ne {}} {
        lappend lines "conformance:"
        foreach pair [lsort -unique $pairs] {
            lassign $pair witness id
            set s [satisfies $witness $id]
            if {![dict get $s ok]} {
                lappend lines "    [hir::types::show $witness] does NOT satisfy $id: [dict get $s reason]"
                continue
            }
            lappend lines "    [hir::types::show $witness] satisfies $id"
            foreach {name impl} [dict get $s impls] {
                set target [expr {[dict get $impl kind] eq "native" ? "[dict get $impl name] (intrinsic)"
                    : [QualifiedName [dict get $impl unit] [dict get $impl name]]}]
                lappend lines "        $name -> $target"
            }
        }
    }
    # Every concrete type the program declares (a struct, refinement or
    # integer domain of any unit) against every trait: does it satisfy it,
    # through which implementations, or why not.
    set declaredTypes {}
    if {[dict exists $hir sourceTypes]} {
        foreach t [dict get $hir sourceTypes] {
            if {[dict exists $t kind] && [dict get $t kind] eq "struct"} {
                lappend declaredTypes [list nstruct [dict get $t id]]
            } elseif {![catch {core::type::normalize [dict get $t name]} type]} {
                lappend declaredTypes $type
            }
        }
    }
    if {$declaredTypes ne {}} {
        lappend lines "declared types:"
        foreach type $declaredTypes {
            foreach entry [dict get $hir traits] {
                set id [dict get $entry id]
                if {[dict exists $entry context] && [dict get $entry context]} {
                    # A context trait (CONTEXT-TRAITS.md): installed context
                    # structs implement it; values never do.
                    if {![hir::types::IsNamedStruct $type] || ![hir::structs::isContext [lindex $type 1]]} {
                        continue
                    }
                    set s [hir::contexts::satisfiesTrait [lindex $type 1] $id]
                    if {[dict get $s ok]} {
                        lappend lines "    context [hir::types::show $type] implements $id ([join [lmap {name impl} [dict get $s impls] {
                            format {%s -> %s} $name [QualifiedName [dict get $impl unit] [dict get $impl name]]
                        }] {, }])"
                    } else {
                        lappend lines "    context [hir::types::show $type] does not implement $id: [dict get $s reason]"
                    }
                    continue
                }
                set s [satisfies $type $id]
                if {[dict get $s ok]} {
                    lappend lines "    [hir::types::show $type] satisfies $id ([join [lmap {name impl} [dict get $s impls] {
                        format {%s -> %s} $name [expr {[dict get $impl kind] eq "native" ? [dict get $impl name]
                            : [QualifiedName [dict get $impl unit] [dict get $impl name]]}]
                    }] {, }])"
                } else {
                    lappend lines "    [hir::types::show $type] does not satisfy $id: [dict get $s reason]"
                }
            }
        }
    }
    if {[dict exists $hir traitFunctions]} {
        lappend lines "trait-polymorphic functions:"
        dict for {name fn} [dict get $hir traitFunctions] {
            set result [expr {[dict get $fn result] eq "" ? "" : " -> [hir::types::show [dict get $fn result]]"}]
            lappend lines "    $name ([join [lmap {p t} [dict get $fn params] {format {%s: %s} $p [hir::types::show $t]}] {, }])$result"
            foreach {clone witnesses} [dict get $fn clones] {
                lappend lines "        $clone[expr {$witnesses eq {} ? "" : "   [join [lmap {p w} $witnesses {format {%s = %s} $p [hir::types::show $w]}] {, }]"}]"
            }
        }
    }
    return [join $lines \n]
}
