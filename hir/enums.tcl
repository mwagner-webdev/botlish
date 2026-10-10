# enums.tcl -- enum declarations: closed nominal sums (ENUMS.md).
#
#   hir::enums::apply DECLS          => HIR `sourceTypes` entries of the enums
#   hir::enums::applyEntries ENTRIES re-registers entries read back from HIR
#                                       text (hir/read.tcl)
#   hir::enums::lookup NAME NS       => declaration identity, or ""
#   hir::enums::declared ID          => 1 if ID is a registered enum
#   hir::enums::cases ID             => EnumCases(ID): the declared cases, in
#                                       declaration order
#   hir::enums::hasCase ID CASE      => 1 if CASE is a declared case of ID
#   hir::enums::caseDescriptor ID CASE  => the case's descriptor
#   hir::enums::IsAffine ID          => the enum's affinity (0 today)
#
# Vocabulary (the language's and the compiler's)
# ----------------------------------------------
#   enum         a named, closed, nominal sum type, declared `enum Name:`
#   case         one nominal member of exactly one enum, written
#                `Name::Case`; in this milestone every case is payload-free
#   case value   the value a case expression denotes
#   payload      (future) an optional named-field product carried by a case
#
# An enum's identity is its *declaration identity*, exactly a named
# struct's: the declared name for the entry program ("VehicleType") and
# "namespace::Name" for a module's ("geo::VehicleType"). Two declarations
# with the same case list are unrelated types. A case's identity is the pair
# (enum declaration identity, case declaration): its name is unique within
# its enum (a duplicate is rejected here), so (ID, NAME) is that pair --
# never the spelling alone (another enum's same-spelled case is another
# value) and never the case's position. There is no global case namespace:
# a case is reached only through its enum's type name (hir/resolve.tcl's
# ResolveEnumCase), so `Car` may be a case of any number of enums and a
# module-level `fn Car()` at the same time.
#
# The registry keeps the complete, closed case set in declaration order:
# `cases` is EnumCases(E), the compiler-side query a future exhaustiveness
# check, payload extension, diagnostics and match lowering need. It is not
# a source-visible operation -- Botlish has no reflection, iteration,
# counting or ordinal of an enum's cases -- and declaration order is kept
# for diagnostics only: no ordering, ordinal, ABI number or serialization
# number is derived from it, and no semantic check reads a case's position
# (backends may number cases internally, as native lowering does for its
# immediate words; that number is representation, never a value).
#
# Each case has a *descriptor* {name NAME span SPAN payload PAYLOAD}.
# PAYLOAD is "" for a payload-free case -- every case in this milestone. A
# later payload-bearing case will carry its named-field product here
# ({FIELD TYPE ...} in declared order, struct-shaped, never a positional
# tuple), without changing what a case is or how the enum is identified; a
# payload-free case stays a case with no payload. Affinity is derived from
# the descriptors (IsAffine): an enum is affine iff some case's payload can
# own affine state, which no payload-free case can.
#
# Like hir/structs.tcl's registry, this is the current compilation's,
# replaced by the next compilation that brings declarations
# (hir::sourcetypes::apply is the one entry point; hir::buildSyntax resets
# it for a fresh program). An enum shares the type namespace of structs,
# traits and source-defined types: no two of them share a name.

namespace eval hir::enums {
    # ID -> {id ID name NAME namespace NS cases {CASE ...} descriptors
    # {CASE DESCRIPTOR ...} span SPAN}
    variable registry [dict create]
}

proc hir::enums::Reset {} {
    variable registry
    set registry [dict create]
}

proc hir::enums::Fail {span message {kind TYPE}} {
    core::semanticError $kind "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# The declaration identity of an enum NAME declared in module NAMESPACE (""
# for the entry program).
proc hir::enums::identity {name namespace} {
    return [expr {$namespace eq "" ? $name : "${namespace}::${name}"}]
}

# 1 if ID is a registered enum declaration identity.
proc hir::enums::declared {id} {
    variable registry
    return [dict exists $registry $id]
}

# The identity of the enum the type spelling NAME (as written: "Vehicle",
# "geo::Vehicle") denotes in code of module namespace NS ("" for the entry
# program), or "": a qualified spelling is exactly that declaration; a bare
# one is the code's own namespace's declaration, else the enum its file's
# `import type` binds to that short name -- the visibility every nominal
# type annotation has (hir::types::resolveNamed).
proc hir::enums::lookup {name {ns ""}} {
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

# EnumCases(ID): the declared case names of enum ID, in declaration order.
proc hir::enums::cases {id} {
    variable registry
    return [dict get $registry $id cases]
}

# 1 if CASE is a declared case of enum ID.
proc hir::enums::hasCase {id case} {
    variable registry
    return [expr {[dict exists $registry $id] && [dict exists $registry $id descriptors $case]}]
}

# The descriptor of case CASE of enum ID: {name NAME span SPAN payload ""}.
proc hir::enums::caseDescriptor {id case} {
    variable registry
    return [dict get $registry $id descriptors $case]
}

# Every payload field type of every case of enum ID (none today: every case
# is payload-free). For the analyses that ask what a value of the enum can
# hold (affinity, vector places, contract bearing).
proc hir::enums::payloadTypes {id} {
    variable registry
    set types {}
    if {![dict exists $registry $id]} {
        return {}
    }
    foreach {case descriptor} [dict get $registry $id descriptors] {
        foreach {field type} [dict get $descriptor payload] {
            lappend types $type
        }
    }
    return $types
}

# The namespace ("" for an entry program) that declares enum ID.
proc hir::enums::owner {id} {
    variable registry
    return [dict get $registry $id namespace]
}

# The source spelling of declaration identity ID (for diagnostics and show).
proc hir::enums::display {id} {
    return $id
}

# 1 if enum ID is affine (hir::types::Affinity, AFFINE-VALUES.md): some
# case's payload can own affine state. A payload-free case owns nothing, so
# every enum of this milestone is unrestricted; the rule is written over the
# case descriptors so that a payload-bearing case extends it rather than
# replacing it. SEEN guards a payload that mentions its own enum.
proc hir::enums::IsAffine {id {seen {}}} {
    variable registry
    if {$id in $seen || ![dict exists $registry $id]} {
        return 0
    }
    foreach {case descriptor} [dict get $registry $id descriptors] {
        foreach {field type} [dict get $descriptor payload] {
            if {[hir::types::IsAffine $type [concat $seen [list $id]]]} {
                return 1
            }
        }
    }
    return 0
}

# The case names of enum ID closest in spelling to CASE (an unknown case),
# for a diagnostic's suggestion: those within an edit distance of 2 (1 for a
# name of up to three characters), nearest first, ties in declaration order.
proc hir::enums::Suggestions {id case} {
    set scored {}
    set limit [expr {[string length $case] <= 3 ? 1 : 2}]
    set position 0
    foreach candidate [cases $id] {
        set d [EditDistance [string tolower $case] [string tolower $candidate]]
        if {$d <= $limit} {
            lappend scored [list $d $position $candidate]
        }
        incr position
    }
    return [lmap s [lsort -integer -index 0 [lsort -integer -index 1 $scored]] {lindex $s 2}]
}

# Levenshtein distance of A and B.
proc hir::enums::EditDistance {a b} {
    set n [string length $b]
    set previous {}
    for {set j 0} {$j <= $n} {incr j} {
        lappend previous $j
    }
    set i 0
    foreach ca [split $a ""] {
        incr i
        set current [list $i]
        set j 0
        foreach cb [split $b ""] {
            incr j
            set cost [expr {$ca eq $cb ? 0 : 1}]
            lappend current [expr {min([lindex $previous $j] + 1, [lindex $current end] + 1,
                [lindex $previous [expr {$j - 1}]] + $cost)}]
        }
        set previous $current
    }
    return [lindex $previous end]
}

# The UNKNOWN-ENUM-CASE message for CASE written against enum ID.
proc hir::enums::UnknownCaseMessage {id case} {
    set message [format {enum %s has no case "%s" (its cases: %s)} \
        [display $id] $case [join [cases $id] {, }]]
    set near [Suggestions $id $case]
    if {$near ne ""} {
        append message "; did you mean [join [lmap c $near {string cat [display $id] :: $c}] { or }]?"
    }
    return $message
}

# Validates and registers DECLS (surface/lower.tcl's EnumDeclOf dicts:
# {kind enum name NAME nameSpan SPAN namespace NS cases {{name C nameSpan
# SPAN} ...} span SPAN}), resetting the previous compilation's registry.
# Returns HIR's own `sourceTypes` entries for them: {kind enum name NAME id ID
# namespace NS cases {C ...}}, in declaration order. Called before any other
# type declaration is resolved: an enum names no other type, and a struct
# field, a refinement carrier or an applied type may name an enum.
proc hir::enums::apply {decls} {
    variable registry
    Reset
    set entries {}
    foreach decl $decls {
        set name [dict get $decl name]
        set ns [dict get $decl namespace]
        set id [identity $name $ns]
        if {[dict exists $decl resolved] && [dict get $decl resolved]} {
            # Read back from HIR text: NAME is already the identity.
            set id $name
            set name [lindex [split [string map {:: \x01} $id] \x01] end]
        }
        if {$name in {Int any never Fn Coroutine enum} || [core::type::isBuiltinName $name]
                || [core::type::valid $id] || [dict exists $::hir::types::constructors $name]} {
            Fail [dict get $decl nameSpan] "\"$name\" cannot be declared as an enum: the name is already a built-in or declared type"
        }
        if {[dict exists $registry $id]} {
            Fail [dict get $decl nameSpan] "type \"$name\" is already declared"
        }
        if {[hir::traits::declared $id]} {
            Fail [dict get $decl nameSpan] "type \"$name\" is already declared (as a trait)"
        }
        if {[dict get $decl cases] eq ""} {
            # The parser already rejects this (ENUM-EMPTY); HIR text can
            # still spell it.
            Fail [dict get $decl nameSpan] "enum \"$name\" declares no case: an enum needs at least one case" ENUM-EMPTY
        }
        set names {}
        set descriptors [dict create]
        foreach case [dict get $decl cases] {
            set caseName [dict get $case name]
            if {[dict exists $descriptors $caseName]} {
                Fail [dict get $case nameSpan] \
                    "duplicate case \"$caseName\" in enum \"$name\": every case of an enum is a distinct nominal case, declared once (there are no case aliases)"
            }
            lappend names $caseName
            dict set descriptors $caseName [dict create name $caseName span [dict get $case nameSpan] payload {}]
        }
        dict set registry $id [dict create id $id name $name namespace $ns cases $names \
            descriptors $descriptors span [dict get $decl nameSpan]]
        lappend entries [dict create kind enum name $name id $id namespace $ns cases $names]
    }
    return $entries
}

# Re-registers the enum entries of a HIR's own `sourceTypes` (hir/read.tcl:
# a serialized HIR carries its declarations; core IR rebuilds keep them).
proc hir::enums::applyEntries {entries} {
    variable registry
    Reset
    foreach entry $entries {
        set descriptors [dict create]
        foreach case [dict get $entry cases] {
            dict set descriptors $case [dict create name $case span "" payload {}]
        }
        dict set registry [dict get $entry id] [dict create id [dict get $entry id] \
            name [dict get $entry name] namespace [dict get $entry namespace] \
            cases [dict get $entry cases] descriptors $descriptors span ""]
    }
}

# 1 if NAME (a bare or qualified type spelling written in code of namespace
# NS) names something visible that is a type but not an enum: a struct, a
# trait, a source-defined or built-in type. For NOT-AN-ENUM.
proc hir::enums::OtherTypeKind {name ns} {
    if {[hir::structs::lookup $name $ns] ne ""} {
        return struct
    }
    if {[hir::traits::lookup $name $ns] ne ""} {
        return trait
    }
    if {$name in {Int any never Fn Coroutine} || [dict exists $::hir::types::constructors $name]
            || [core::type::isBuiltinName $name]} {
        return "built-in type"
    }
    set canonical [hir::types::CanonicalTypeName $name $ns]
    if {[core::type::isSource $canonical]} {
        return type
    }
    return ""
}
