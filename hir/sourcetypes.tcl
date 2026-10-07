# sourcetypes.tcl -- source-defined bounded integer refinement types.
#
#   hir::sourcetypes::apply DECLS   => ordered list of {name .. parent ..
#                                       domain ..}, for HIR's own
#                                       `sourceTypes` field
#
# Botlish source can declare a named integer refinement directly:
#
#   type Byte = Int in 0..255
#   type Nibble = Byte in 0..15
#
# (surface/parser.tcl's TypeDecl grammar; surface/lower.tcl's SplitTypeDecls
# turns each into a plain DECL dict -- {name .. nameSpan .. parent ..
# parentSpan .. domain .. domainSpan ..}, never an hir/syntax.tcl node: a
# type declaration has no runtime meaning -- see items 21-22). This file is
# where DECLS become the exact same canonical metadata a compiler-side
# registration (core::type::register, core/type.tcl) would have produced:
# it is the only thing that changes. Everything downstream of core::type's
# registry (hir::resolve's `core::type::normalize $declared` on a function's
# result-type annotation, hir/range.tcl's core::type::integerFacts, native
# constructor lowering, ...) neither knows nor cares whether a name's
# metadata came from Tcl source or Botlish source.
#
# Compilation isolation
# ----------------------
# core::type::registry (core/type.tcl) and core::native::registry
# (core/native.tcl) are single, process-global Tcl dicts: this is
# pre-existing architecture (every compiler-registered type -- Emailish,
# NonEmpty, the old Byte/Nibble/... -- already lived there, for the whole
# process's lifetime, registered once when core/scalarbits.tcl and friends
# were first `source`d). A *source*-defined type is different: the exact
# same spelling ("Small") can validly denote a different domain in two
# different programs compiled by the same long-lived Tcl process (spec
# items 14-17), so registering it the same permanent way core-registered
# types are would let one program's declaration leak into, or collide
# with, another's.
#
# apply's own answer: a call that declares any source type -- a non-empty
# DECLS, or a non-empty STRUCTDECLS (struct declarations, hir/structs.tcl,
# which share this type namespace) -- first Resets -- unregisters -- every
# type/native the *previous* such call registered (`generation`, below),
# then registers its declarations fresh; a call given neither does nothing
# at all, neither resetting nor registering (see apply's own comment for
# exactly why that half matters just as much). hir::
# buildSyntax (hir/hir.tcl) calls apply exactly once, right before hir::
# resolve::program, on every top-level build (an ordinary source compile,
# or hir::read reconstructing a serialized HIR -- see hir/read.tcl). This
# guarantees:
#   * repeated compilation of the same program succeeds (each call clears
#     its own prior registration before re-registering, never "already
#     registered") -- spec item 109;
#   * two sequential, non-overlapping compiles never see each other's
#     domain for the same spelling -- item 110: by the time the second
#     program's hir::buildSyntax call starts, the first's registration has
#     already been cleared;
#   * that holds when the second program declares only structs as well: a
#     module rewritten from `refined type Item = int` to `struct Item:`
#     compiles in the same process (hir/read.tcl's struct-only text resets
#     the same way).
# What this does NOT give: two *live* HIR objects, from two different
# hir::buildSyntax calls, whose compiled Tcl procs or native code both
# still need a same-spelled-but-different-domain source type to resolve
# correctly *at the same time*, after a third build has reset the registry
# in between. That would need every core::type/core::native lookup site
# (hir/resolve.tcl, compiler.tcl, native/lower.tcl, ...) to thread a
# compilation-scoped environment through instead of consulting one global
# registry by bare name -- a real redesign of machinery items 93/136 ask
# this milestone to leave alone. This compiler is not built for concurrent
# or nested compilation today (nothing in hir/, compiler/ or native/ passes
# a compilation identity anywhere), so that gap is accepted and documented,
# not silently papered over -- see SOURCE-DEFINED-INTEGER-DOMAINS.md's
# "Compilation isolation" section for the full argument and its tests.

namespace eval hir::sourcetypes {
    # {type NAME} / {native NAME} entries the previous apply call
    # registered, to unregister before registering the next batch.
    variable generation {}
}

proc hir::sourcetypes::Reset {} {
    variable generation
    foreach entry $generation {
        lassign $entry kind name
        switch -- $kind {
            native { core::native::unregister $name }
            type   { core::type::unregister $name }
        }
    }
    set generation {}
}

proc hir::sourcetypes::Fail {span message {kind TYPE}} {
    core::semanticError $kind "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# "" when the earlier declaration (span FIRST) of a name redeclared at SPAN
# is in the same file; otherwise where it is, and why it counts: error names
# are one flat, program-wide namespace, so a module the program loads --
# possibly only through another module (abi, through abi::x86_64) -- takes
# its error names for the whole program. (Types are namespace members,
# IMPORTS.md.) Used by hir/errordecls.tcl.
proc hir::sourcetypes::ElsewhereClause {first span} {
    if {$first eq "" || $span eq "" || [dict get $first file] eq [dict get $span file]} {
        return ""
    }
    return [format { at %s:%s:%s (error names are global: every module the program loads, including one it reaches only through another module, declares its error names for the whole program)} \
        [dict get $first file] [dict get $first line] [dict get $first column]]
}

# Validates and registers DECLS (surface/lower.tcl's TypeDeclOf dicts, from
# every module section a program loads plus the program's own top level --
# see surface/modules.tcl), returning the ordered list hir::buildSyntax
# stores as HIR's own `sourceTypes` field: {name NAME parent PARENT-SPELLING
# domain CANONICAL-DOMAIN}, PARENT-SPELLING "Int" or another declared name,
# CANONICAL-DOMAIN core::type::metadata's own {interval LO HI} / {exact
# {V...}} form (hir/format.tcl prints this; hir/read.tcl re-applies it).
proc hir::sourcetypes::apply {decls {structDecls {}}} {
    if {$decls eq "" && $structDecls eq ""} {
        # Nothing new to register: leave the registry exactly as is,
        # neither resetting nor adding anything, and report no source types
        # of THIS call's own (a caller building an HIR from these decls
        # gets an accurate, empty `sourceTypes` field for it -- see hir::
        # buildSyntax). This matters because hir::build (core IR, no
        # surface syntax) and every internal re-hir::build of an
        # already-lowered program (the Tcl compiler backend's own
        # GenerateUnit, hir/specialize.tcl) all call through
        # here too, with no type decls of their own (core IR has no type-
        # declaration syntax) -- Resetting unconditionally on every call
        # would unregister a program's own already-verified source types
        # out from under its *own* later compilation/native-lowering pass,
        # not just a genuinely different program's. Only a call that itself
        # brings new declarations reclaims the (single, global) registry --
        # see this file's own header, "Compilation isolation".
        return {}
    }
    # Any source type declaration -- an integer domain, a refinement or a
    # struct -- makes this a program of its own, so it reclaims the registry
    # even when it declares only structs: a previous compilation's
    # `refined type Item` must not stay registered to collide with this
    # one's `struct Item` (hir::structs::apply rejects a struct name that is
    # already a declared type) or to stay resolvable under a name this
    # program does not declare.
    Reset
    set order {}
    if {$decls ne ""} {
        set byName [dict create]
        foreach decl $decls {
            set id [Identity $decl]
            if {[dict exists $byName $id]} {
                Fail [dict get $decl nameSpan] "type \"$id\" is already declared[ElsewhereClause [dict get $byName $id nameSpan] [dict get $decl nameSpan]]"
            }
            dict set byName $id $decl
        }
        set registered [dict create]
        set visiting [dict create]
        foreach decl $decls {
            Resolve [Identity $decl] $byName registered visiting order $structDecls
        }
    }
    if {$structDecls ne ""} {
        # Struct declarations (STRUCTS.md, hir/structs.tcl) are type
        # declarations of this same pass: registered after the integer-domain
        # types (whose names they may not reuse, and which their fields may
        # name), their entries joining the same ordered `sourceTypes` list.
        lappend order {*}[hir::structs::apply $structDecls]
    }
    return $order
}

# The identity of the type DECL (surface/lower.tcl's TypeDeclOf dict) declares:
# `NAMESPACE::Name` for a type of a module, the bare name for the entry
# program's own (a type is a member of its namespace, IMPORTS.md).
proc hir::sourcetypes::Identity {decl} {
    if {[dict exists $decl resolved] && [dict get $decl resolved]} {
        # Read back from HIR text (hir::read::TypeDeclLine): NAME is
        # already the canonical identity.
        return [dict get $decl name]
    }
    set ns [dict get $decl namespace]
    set name [dict get $decl name]
    return [expr {$ns eq "" ? $name : "${ns}::$name"}]
}

# The identity the parent type spelled PARENT in DECL's declaration denotes,
# or "" if no type of that spelling is visible there. `Int` is the root of
# every domain. Otherwise the same visibility a type annotation has
# (hir::types::CanonicalTypeName): a type the file's own namespace declares
# (a key of BYNAME), a type it imports with `import type`, or a built-in
# type; a module never sees the entry program's types.
proc hir::sourcetypes::ParentIdentity {decl byName} {
    set parent [dict get $decl parent]
    set ns [dict get $decl namespace]
    if {$parent eq "Int"} {
        return Int
    }
    set own [expr {$ns eq "" ? $parent : "${ns}::$parent"}]
    if {[dict exists $byName $own]} {
        return $own
    }
    set imported [hir::imports::typeNamed $ns $parent]
    if {$imported ne ""} {
        return $imported
    }
    if {[core::type::isBuiltinName $parent]} {
        return $parent
    }
    return ""
}

# Registers the type of identity ID (a key of BYNAME), first resolving its
# parent if the parent is itself one of BYNAME's own not-yet-registered
# declarations (same-module/same-batch forward visibility, item 25-26) -- a
# DFS with cycle detection (item 27). A parent outside BYNAME is left alone
# here: it must already be a builtin or an earlier-resolved-in-this-batch
# type, checked (with a proper diagnostic) when RegisterOne actually looks it
# up as a parent.
proc hir::sourcetypes::Resolve {id byName registeredVar visitingVar orderVar {structDecls {}}} {
    upvar 1 $registeredVar registered $visitingVar visiting $orderVar order
    if {[dict exists $registered $id] || ![dict exists $byName $id]} {
        return
    }
    set decl [dict get $byName $id]
    if {[dict exists $visiting $id]} {
        # The chain of declarations from ID's first visit back to ID.
        set chain [lrange [dict keys $visiting] [lsearch -exact [dict keys $visiting] $id] end]
        if {[IsRefined $decl] || [lsearch -exact [lmap c $chain {IsRefined [dict get $byName $c]}] 1] >= 0} {
            Fail [dict get $decl nameSpan] \
                "cyclic refinement: \"$id\" is its own carrier through [join [concat $chain [list $id]] { -> }] (a refinement's carrier chain must end in a type that is not a refinement of it)" \
                CYCLIC-REFINEMENT
        }
        Fail [dict get $decl nameSpan] \
            "type declaration cycle: \"$id\" depends on its own declaration through its chain of parents"
    }
    dict set visiting $id 1
    if {[IsRefined $decl]} {
        CheckDeclaredName $decl
        # The batch's declarations the carrier names are registered first
        # (same-module forward visibility, as for a domain's parent).
        foreach dependency [CarrierDependencies $decl $byName] {
            Resolve $dependency $byName registered visiting order $structDecls
        }
        dict set registered $id [RegisterRefinement $decl $structDecls]
    } else {
        set parentId [ParentIdentity $decl $byName]
        if {$parentId ne "Int" && $parentId ne ""} {
            Resolve $parentId $byName registered visiting order $structDecls
        }
        dict set registered $id [RegisterOne $decl $parentId]
    }
    lappend order [dict get $registered $id]
    dict unset visiting $id
}

# 1 if DECL (a TypeDeclOf dict) declares a refinement type
# (`refined type NAME = CARRIER`, REFINEMENT-VALUES.md).
proc hir::sourcetypes::IsRefined {decl} {
    return [expr {[dict exists $decl kind] && [dict get $decl kind] eq "refined"}]
}

# The identities of the declarations of BYNAME that the carrier type
# expression of refinement DECL names (bare, qualified, or inside an applied
# type's argument), with the visibility a type annotation has.
proc hir::sourcetypes::CarrierDependencies {decl byName} {
    if {[dict exists $decl resolved] && [dict get $decl resolved]} {
        # HIR text prints types in dependency order already.
        return {}
    }
    set ns [dict get $decl namespace]
    set result {}
    foreach spelled [TypeExprNames [dict get $decl carrier]] {
        set id [hir::types::CanonicalTypeName $spelled $ns]
        if {[string first :: $spelled] < 0 && $ns ne "" && [dict exists $byName ${ns}::$spelled]} {
            set id ${ns}::$spelled
        }
        if {[dict exists $byName $id] && $id ni $result} {
            lappend result $id
        }
    }
    return $result
}

# The type names a surface type expression (surface::parser::TypeExpr) spells.
proc hir::sourcetypes::TypeExprNames {typeExpr} {
    if {[llength $typeExpr] == 1} {
        return [list $typeExpr]
    }
    lassign $typeExpr head arg
    if {$head eq "fn"} {
        set names {}
        foreach t [dict get $arg args] { lappend names {*}[TypeExprNames $t] }
        lappend names {*}[TypeExprNames [dict get $arg return]]
        return $names
    }
    return [concat [list $head] [TypeExprNames $arg]]
}

# Validates and registers the refinement type DECL (REFINEMENT-VALUES.md):
#
#   refined type NAME = CARRIER
#
# a new nominal type -- never an alias -- whose values are exactly values of
# CARRIER known, by a proof, to satisfy NAME's proposition. Its registry
# entry (core::type::register -refinement) records the canonical identity
# (`NAMESPACE::Name`), the canonical carrier type, the owner -- the exact
# declaring module, the one module that may mint it -- and the declaration's
# span. Its base and parents are the carrier's own, so forgetting to the
# carrier (and transitively to the carrier's carrier) is ordinary subtyping
# of the existing type lattice; nothing about the carrier's runtime
# representation changes. STRUCTDECLS are the batch's struct declarations,
# only to word the diagnostic of a struct carrier.
# Rejects a refinement DECL whose name is a built-in type's (a TYPE error):
# checked before its carrier is looked at, so `refined type str = str` is a
# name collision, not a cycle through itself.
proc hir::sourcetypes::CheckDeclaredName {decl} {
    set name [dict get $decl name]
    if {[dict exists $decl resolved] && [dict get $decl resolved]} {
        return
    }
    if {$name in {Int any never Fn} || [core::type::isBuiltinName $name]
            || [dict exists $::hir::types::constructors $name]} {
        Fail [dict get $decl nameSpan] \
            "type \"$name\" cannot be declared: the name is already a built-in type"
    }
}

proc hir::sourcetypes::RegisterRefinement {decl structDecls} {
    variable generation
    set name [dict get $decl name]
    set id [Identity $decl]
    set ns [dict get $decl namespace]
    if {[dict exists $decl resolved] && [dict get $decl resolved]} {
        # Read back from HIR text: the carrier is a printed resolved type,
        # already validated when the HIR was first built.
        set carrier [hir::read::ParseType [dict get $decl carrier] [dict get $decl line]]
        core::type::register $id -base [core::type::base $carrier] -parents [core::type::evidenceOf $carrier] \
            -refinement [dict create carrier $carrier owner $ns span [dict get $decl nameSpan]] -source 1
        lappend generation [list type $id]
        return [dict create kind refined name $id carrier $carrier owner $ns]
    }
    set carrierText [hir::resolve::ShowTypeExpr [dict get $decl carrier]]
    foreach spelled [TypeExprNames [dict get $decl carrier]] {
        foreach struct $structDecls {
            set structId [expr {[dict get $struct namespace] eq "" ? [dict get $struct name]
                : "[dict get $struct namespace]::[dict get $struct name]"}]
            if {$spelled eq $structId || ($spelled eq [dict get $struct name] && [dict get $struct namespace] eq $ns)} {
                Fail [dict get $decl carrierSpan] \
                    "invalid refinement carrier $carrierText for \"$id\": $structId is a struct type, and refinements of struct values are not supported yet (this milestone's carriers are scalar value types: str, int, bool, UnicodeChar, and integer-domain or refinement types over them)" \
                    REFINEMENT-CARRIER
            }
        }
    }
    if {[catch {hir::resolve::ResolveTypeExpr [dict get $decl carrier] $ns} carrier options]} {
        Fail [dict get $decl carrierSpan] "unknown carrier type $carrierText for refinement \"$id\": $carrier" \
            [hir::resolve::TypeErrorKind $options TYPE]
    }
    if {[hir::types::MentionsTrait $carrier]} {
        Fail [dict get $decl carrierSpan] \
            "invalid refinement carrier $carrierText for \"$id\": a trait is a static constraint, not a value type with a representation of its own (TRAITS.md)" \
            REFINEMENT-CARRIER
    }
    set why [RefinementCarrierEligible $carrier]
    if {$why ne ""} {
        Fail [dict get $decl carrierSpan] \
            "invalid refinement carrier $carrierText for \"$id\": $why" REFINEMENT-CARRIER
    }
    core::type::register $id -base [core::type::base $carrier] -parents [core::type::evidenceOf $carrier] \
        -refinement [dict create carrier $carrier owner $ns span [dict get $decl nameSpan]] -source 1
    lappend generation [list type $id]
    return [dict create kind refined name $id carrier $carrier owner $ns]
}

# "" if a value of static type TYPE may carry a refinement (REFINEMENT-
# VALUES.md, RefinementCarrierEligible(T)), else the reason it may not.
#
# A refinement states a fact about a value that must stay true for as long
# as the value exists: no later operation may change what the proof was
# about. That is a property of the type's *semantics*, decided here from
# its form -- never from its spelling:
#
#   * value stability (ValueStability): a scalar value (str, int, bool,
#     UnicodeChar, unit), an integer domain or a refinement over one, and
#     an aggregate (List, ImmutableSet, struct) of stable values are
#     stable; a MutableArray -- reference semantics, its slots change in
#     place -- is not, nor is anything reaching one; `any` (e.g. a struct
#     field declared `any`) and callables are not proven stable;
#   * representation: this milestone's refinements live on the core type
#     lattice, whose types are a primitive kind refined by named facts, so a
#     carrier must also be a core type. A stable aggregate is reported as
#     such, but not supported yet.
proc hir::sourcetypes::RefinementCarrierEligible {type} {
    if {$type in {any never}} {
        return "a refinement carrier must be a concrete value type, not $type"
    }
    set stable [ValueStability $type]
    if {$stable ne ""} {
        return "[hir::types::show $type] $stable, so a proof about one value would not stay true; a refinement needs a carrier whose values never change"
    }
    if {[hir::types::IsSpecific $type] || $type eq "struct"} {
        return "[hir::types::show $type] is a stable value type, but refinements of aggregate, struct or callable values are not supported yet (this milestone's carriers are scalar value types: str, int, bool, UnicodeChar, and integer-domain or refinement types over them)"
    }
    if {[core::type::base $type] ni {str int bool UnicodeChar unit}} {
        return "values of kind [core::type::base $type] are not supported as refinement carriers (this milestone's carriers are scalar value types: str, int, bool, UnicodeChar, and integer-domain or refinement types over them)"
    }
    return ""
}

# "" if every value of static type TYPE is transitively immutable (no
# operation can change it after it exists), else why not, as a clause.
proc hir::sourcetypes::ValueStability {type {visiting {}}} {
    if {$type eq "any"} {
        return "may be any value, including a mutable one"
    }
    if {[hir::types::IsMutArray $type] || $type eq "mutarray"} {
        return "has reference semantics (a MutableArray's slots change in place)"
    }
    if {[hir::types::IsFn $type] || [hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type]
            || $type in {block native}} {
        return "is a callable, which has no stable value to refine"
    }
    if {[hir::types::IsList $type] || [hir::types::IsSet $type]} {
        set why [ValueStability [lindex $type 1] $visiting]
        return [expr {$why eq "" ? "" : "has an element type, [hir::types::show [lindex $type 1]], that $why"}]
    }
    if {$type in {list immutableSet result struct}} {
        return "may hold values of any kind, including mutable ones"
    }
    if {[hir::types::IsStruct $type]} {
        foreach {field t} [lindex $type 1] {
            set why [ValueStability $t $visiting]
            if {$why ne ""} { return "has a field \"$field\" that $why" }
        }
        return ""
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$id in $visiting} { return "" }
        foreach {field t} [hir::structs::fieldTypes $id] {
            set why [ValueStability $t [concat $visiting [list $id]]]
            if {$why ne ""} { return "has a field \"$field\" that $why" }
        }
        return ""
    }
    return ""
}

# Validates DECL's parent (PARENTID, its resolved identity, "" if none is
# visible) and domain, registers it (core::type::register, plus its
# membership predicate, core::type::declareIntConstructor), and returns its
# own {name .. parent .. domain ..} summary: `name` and `parent` are
# identities.
proc hir::sourcetypes::RegisterOne {decl parentId} {
    variable generation
    set name [dict get $decl name]
    set id [Identity $decl]
    if {$name eq "Int"} {
        Fail [dict get $decl nameSpan] \
            "\"Int\" is the compiler's own built-in integer type and cannot be redeclared"
    }
    if {[dict get $decl namespace] ne "" && ([core::type::isBuiltinName $name]
            || [dict exists $::hir::types::constructors $name] || $name in {any never Fn})} {
        Fail [dict get $decl nameSpan] \
            "type \"$name\" cannot be declared in namespace \"[dict get $decl namespace]\": the name is already a built-in type"
    }
    set parentName [dict get $decl parent]
    set domain [CanonicalDomain [dict get $decl domain]]
    set parents {}
    set parentDomain {}
    if {$parentName ne "Int"} {
        if {$parentId eq "" || ![core::type::isNamed $parentId]} {
            Fail [dict get $decl parentSpan] "unknown parent type \"$parentName\""
        }
        set parentMeta [core::type::metadata $parentId]
        if {[dict get $parentMeta base] ne "int" || [dict get $parentMeta integerDomain] eq ""} {
            Fail [dict get $decl parentSpan] \
                "\"$parentName\" is not an integer-domain type: \"type $name = $parentName in ...\" can only refine Int or another integer-domain type"
        }
        set parents [list $parentId]
        set parentDomain [dict get $parentMeta integerDomain]
    }
    if {$parentDomain ne {} && ![core::type::integerDomainSubset $domain $parentDomain]} {
        Fail [dict get $decl domainSpan] \
            "the domain of \"$id\" is not a subset of its parent \"$parentId\"'s domain [core::type::showIntegerDomain $parentDomain]"
    }
    core::type::register $id -base int -parents $parents -integer-domain $domain -source 1
    lappend generation [list type $id]
    core::type::declareIntConstructor $id
    core::native::markSource $id?
    lappend generation [list native $id] [list native $id?]
    return [dict create name $id parent [expr {$parentName eq "Int" ? "Int" : $parentId}] \
        domain [dict get [core::type::metadata $id] integerDomain]]
}

# A multi-line, human-auditable rendering of HIR's own source-defined types
# (hir::sourceTypes), one stanza per declaration in dependency order --
# e.g.
#
#   type Byte
#       parent: Int
#       domain: interval [0, 255]
#
#   type HighNibble
#       parent: Byte
#       domain: exact {0, 16, ..., 240}
#       hull: [0, 240]
#
# for auditing exactly what a compilation registered and from where (items
# 116-119): a diagnostic view, not a new representation -- every field
# comes straight from core::type::metadata/showIntegerDomain, the same
# canonical descriptor every other consumer reads.
proc hir::sourcetypes::explain {hir} {
    set stanzas {}
    foreach entry [hir::sourceTypes $hir] {
        set domain [dict get $entry domain]
        set lines [list "type [dict get $entry name]" "    parent: [dict get $entry parent]"]
        if {[lindex $domain 0] eq {interval}} {
            lappend lines "    domain: interval [core::type::showIntegerDomain $domain]"
        } else {
            set values [lindex $domain 1]
            lappend lines "    domain: exact [core::type::showIntegerDomain $domain]"
            lappend lines "    hull: \[[lindex $values 0], [lindex $values end]\]"
        }
        lappend stanzas [join $lines \n]
    }
    return [join $stanzas \n\n]
}

# DOMAIN (surface/parser.tcl's Domain node: {kind interval lo .. hi ..} or
# {kind exact values {..} spans {..}}) validated and reshaped into
# core::type::register's own -integer-domain form ({interval LO HI} /
# {exact {V...}}); core::type::register's NormalizeIntegerDomain does the
# final canonicalization (sorting, item 40) -- reused, not duplicated, here.
proc hir::sourcetypes::CanonicalDomain {domain} {
    if {[dict get $domain kind] eq "interval"} {
        set lo [dict get $domain lo]
        set hi [dict get $domain hi]
        if {$lo > $hi} {
            Fail [dict get $domain span] \
                "empty integer range: $lo..$hi (a type declaration's interval needs lo <= hi; an empty/bottom refinement is out of scope)"
        }
        return [list interval $lo $hi]
    }
    set seen [dict create]
    foreach value [dict get $domain values] span [dict get $domain spans] {
        if {[dict exists $seen $value]} {
            Fail $span "duplicate value $value in this type's finite domain"
        }
        dict set seen $value 1
    }
    return [list exact [dict get $domain values]]
}
