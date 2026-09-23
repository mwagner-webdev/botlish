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
# apply's own answer: a call given a non-empty DECLS first Resets --
# unregisters -- every type/native the *previous* such call registered
# (`generation`, below), then registers DECLS fresh; a call given an empty
# DECLS does nothing at all, neither resetting nor registering (see apply's
# own comment for exactly why that half matters just as much). hir::
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
#     already been cleared.
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

proc hir::sourcetypes::Fail {span message} {
    core::semanticError TYPE "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# Validates and registers DECLS (surface/lower.tcl's TypeDeclOf dicts, from
# every module section a program loads plus the program's own top level --
# see surface/modules.tcl), returning the ordered list hir::buildSyntax
# stores as HIR's own `sourceTypes` field: {name NAME parent PARENT-SPELLING
# domain CANONICAL-DOMAIN}, PARENT-SPELLING "Int" or another declared name,
# CANONICAL-DOMAIN core::type::metadata's own {interval LO HI} / {exact
# {V...}} form (hir/format.tcl prints this; hir/read.tcl re-applies it).
proc hir::sourcetypes::apply {decls} {
    if {$decls eq ""} {
        # Nothing new to register: leave the registry exactly as is,
        # neither resetting nor adding anything, and report no source types
        # of THIS call's own (a caller building an HIR from these decls
        # gets an accurate, empty `sourceTypes` field for it -- see
        # hir::buildSyntax). This matters because hir::build (core IR, no
        # surface syntax) and every internal re-hir::build of an
        # already-lowered program (the Tcl compiler backend's own
        # GenerateUnit, the native backend's ExpandNativeBodies/
        # ModuleNativeBridge path, hir/specialize.tcl) all call through
        # here too, with no type decls of their own (core IR has no type-
        # declaration syntax) -- Resetting unconditionally on every call
        # would unregister a program's own already-verified source types
        # out from under its *own* later compilation/native-lowering pass,
        # not just a genuinely different program's. Only a call that itself
        # brings new declarations reclaims the (single, global) registry --
        # see this file's own header, "Compilation isolation".
        return {}
    }
    Reset
    set byName [dict create]
    foreach decl $decls {
        set name [dict get $decl name]
        if {[dict exists $byName $name]} {
            Fail [dict get $decl nameSpan] "type \"$name\" is already declared"
        }
        dict set byName $name $decl
    }
    set registered [dict create]
    set visiting [dict create]
    set order {}
    foreach decl $decls {
        Resolve [dict get $decl name] $byName registered visiting order
    }
    return $order
}

# Registers NAME (a key of BYNAME), first resolving its parent if the
# parent is itself one of BYNAME's own not-yet-registered declarations
# (same-module/same-batch forward visibility, item 25-26) -- a DFS with
# cycle detection (item 27). A NAME outside BYNAME is left alone here: it
# must already be a builtin or an earlier-resolved-in-this-batch type,
# checked (with a proper diagnostic) when RegisterOne actually looks it up
# as a parent.
proc hir::sourcetypes::Resolve {name byName registeredVar visitingVar orderVar} {
    upvar 1 $registeredVar registered $visitingVar visiting $orderVar order
    if {[dict exists $registered $name] || ![dict exists $byName $name]} {
        return
    }
    if {[dict exists $visiting $name]} {
        Fail [dict get [dict get $byName $name] nameSpan] \
            "type declaration cycle: \"$name\" depends on its own declaration through its chain of parents"
    }
    dict set visiting $name 1
    set decl [dict get $byName $name]
    set parentName [dict get $decl parent]
    if {$parentName ne "Int"} {
        Resolve $parentName $byName registered visiting order
    }
    dict set registered $name [RegisterOne $decl]
    lappend order [dict get $registered $name]
    dict unset visiting $name
}

# Validates DECL's parent and domain, registers it (core::type::register,
# plus its checked constructor and predicate, core::type::declareIntConstructor),
# and returns its own {name .. parent .. domain ..} summary.
proc hir::sourcetypes::RegisterOne {decl} {
    variable generation
    set name [dict get $decl name]
    if {$name eq "Int"} {
        Fail [dict get $decl nameSpan] \
            "\"Int\" is the compiler's own built-in integer type and cannot be redeclared"
    }
    set parentName [dict get $decl parent]
    set domain [CanonicalDomain [dict get $decl domain]]
    set parents {}
    set parentDomain {}
    if {$parentName ne "Int"} {
        if {![core::type::isNamed $parentName]} {
            Fail [dict get $decl parentSpan] "unknown parent type \"$parentName\""
        }
        set parentMeta [core::type::metadata $parentName]
        if {[dict get $parentMeta base] ne "int" || [dict get $parentMeta integerDomain] eq ""} {
            Fail [dict get $decl parentSpan] \
                "\"$parentName\" is not an integer-domain type: \"type $name = $parentName in ...\" can only refine Int or another integer-domain type"
        }
        set parents [list $parentName]
        set parentDomain [dict get $parentMeta integerDomain]
    }
    if {$parentDomain ne {} && ![core::type::integerDomainSubset $domain $parentDomain]} {
        Fail [dict get $decl domainSpan] \
            "the domain of \"$name\" is not a subset of its parent \"$parentName\"'s domain [core::type::showIntegerDomain $parentDomain]"
    }
    core::type::register $name -base int -parents $parents -integer-domain $domain -source 1
    lappend generation [list type $name]
    core::type::declareIntConstructor $name
    lappend generation [list native $name] [list native $name?]
    return [dict create name $name parent $parentName domain [dict get [core::type::metadata $name] integerDomain]]
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
