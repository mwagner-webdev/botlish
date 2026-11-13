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
#   hir::enums::hasPayload ID CASE   => 1 if case CASE carries a payload
#   hir::enums::hasPayloads ID       => 1 if some case of ID carries one
#   hir::enums::fields ID CASE       => the payload fields {F T ...}
#   hir::enums::payloadType ID CASE  => the payload's anonymous struct type
#   hir::enums::resolvePayloads      resolves every payload field type
#   hir::enums::IsAffine ID          => the enum's affinity, derived from
#                                       its payloads
#
# Vocabulary (the language's and the compiler's)
# ----------------------------------------------
#   enum         a named, closed, nominal sum type, declared `enum Name:`
#   case         one nominal member of exactly one enum, written
#                `Name::Case` (payload-free) or constructed
#                `Name::Case {field: value, ...}` (payload-bearing)
#   case value   the value a case expression or construction denotes
#   payload      the optional named-field product a case declares and each
#                of its values carries (PORTABILITY-PAYLOAD-ENUMS-
#                MILESTONE-1.md): statically typed fields, struct-shaped,
#                never positional; a case's payload is part of its values,
#                never of its identity
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
# PAYLOAD is "" for a payload-free case. A payload-bearing case
# (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md) carries its named-field product
# here, {FIELD TYPE ...} in declared order -- struct-shaped, never a
# positional tuple -- and `hasPayload 1`, `raw {FIELD TYPEEXPR ...}`,
# `fieldSpans` and `typeSpans` while its types are not resolved yet: apply
# runs before any other type is registered (a struct field may name an
# enum), resolvePayloads once every type is (a payload field may name a
# struct, an enum -- its own enum included -- a domain or a layout's
# struct). A payload changes neither what a case is nor how the enum is
# identified: the case's identity is (enum, name), and a payload-free case
# stays a value with no payload. The payload's static type is the
# anonymous struct type of its fields (payloadType), the form an error
# payload has (ERROR-PAYLOADS.md): a statically known named product with no
# source name and no identity of its own. Affinity is derived from the
# descriptors (IsAffine): an enum is affine iff some case's payload can own
# affine state.
#
# Like hir/structs.tcl's registry, this is the current compilation's,
# replaced by the next compilation that brings declarations
# (hir::sourcetypes::apply is the one entry point; hir::buildSyntax resets
# it for a fresh program). An enum shares the type namespace of structs,
# traits and source-defined types: no two of them share a name.

namespace eval hir::enums {
    # ID -> {id ID name NAME namespace NS cases {CASE ...} descriptors
    # {CASE DESCRIPTOR ...} span SPAN}; a builtin enum's entry also has
    # `builtin 1` (Reset).
    variable registry [dict create]
}

# Drops the previous compilation's enums. The runtime's builtin enums
# (core::native::declareEnum: NonFiniteResult, the type of NonFiniteFloat's
# payload field) are registered again: every compilation has them, under
# their bare names, like the builtin errors, and none is ever in a program's
# own `sourceTypes`.
proc hir::enums::Reset {} {
    variable registry
    set registry [dict create]
    dict for {id cases} [core::native::builtinEnums] {
        set descriptors [dict create]
        foreach case $cases {
            dict set descriptors $case [dict create name $case span "" payload {}]
        }
        dict set registry $id [dict create id $id name $id namespace "" cases $cases \
            descriptors $descriptors span "" builtin 1]
    }
}

hir::enums::Reset

proc hir::enums::Fail {span message {kind TYPE}} {
    core::semanticError $kind "[dict get $span file]:[dict get $span line]:[dict get $span column]: $message"
}

# The declaration identity of an enum NAME declared in module NAMESPACE (""
# for the entry program).
proc hir::enums::identity {name namespace} {
    if {$namespace eq ""} {
        return $name
    }
    return "${namespace}::${name}"
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
        if {[dict exists $registry $name]} {
            return $name
        }
        return ""
    }
    set own [identity $name $ns]
    if {[dict exists $registry $own]} {
        return $own
    }
    set imported [hir::imports::typeNamed $ns $name]
    if {$imported ne "" && [dict exists $registry $imported]} {
        return $imported
    }
    if {[core::native::isBuiltinEnum $name]} {
        # A builtin enum, visible in every module (no module declares or
        # imports its name: apply, surface/modules.tcl).
        return $name
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

# The descriptor of case CASE of enum ID: {name NAME span SPAN payload
# PAYLOAD}.
proc hir::enums::caseDescriptor {id case} {
    variable registry
    return [dict get $registry $id descriptors $case]
}

# 1 if case CASE of enum ID declares a payload
# (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md).
proc hir::enums::hasPayload {id case} {
    variable registry
    return [expr {[hasCase $id $case] && [dict getdef [dict get $registry $id descriptors $case] hasPayload 0]}]
}

# 1 if some case of enum ID declares a payload: its values are not all
# payload-free immediates (a backend's representation question only; no
# semantic rule reads it but the ones about payloads).
proc hir::enums::hasPayloads {id} {
    variable registry
    if {![dict exists $registry $id]} {
        return 0
    }
    foreach {case descriptor} [dict get $registry $id descriptors] {
        if {[dict getdef $descriptor hasPayload 0]} {
            return 1
        }
    }
    return 0
}

# 1 if every value of static type TYPE is a payload-free case: an enum type
# of a declaration with no payload-bearing case, or the broad `enum` kind in
# a registry where no enum has one (a backend's representation question:
# native lowering's immediate words, a scalar equality with no structural
# walk; PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md).
proc hir::enums::IsPayloadFree {type} {
    variable registry
    if {$type eq "enum"} {
        dict for {id entry} $registry {
            if {[hasPayloads $id]} {
                return 0
            }
        }
        return 1
    }
    return [expr {[hir::types::IsEnum $type] && ![hasPayloads [lindex $type 1]]}]
}

# The payload fields of case CASE of enum ID, {FIELD TYPE ...} in declared
# order ({} for a payload-free case).
proc hir::enums::fields {id case} {
    variable registry
    if {![hasCase $id $case]} {
        return {}
    }
    return [dict get $registry $id descriptors $case payload]
}

# The payload field names of case CASE of enum ID, in declared order.
proc hir::enums::fieldNames {id case} {
    return [dict keys [fields $id $case]]
}

# The declared type of payload field FIELD of case CASE of enum ID, or "".
proc hir::enums::fieldType {id case field} {
    return [dict getdef [fields $id $case] $field ""]
}

# The static type of the payload of case CASE of enum ID: the anonymous
# struct type of its declared fields ({struct {FIELD TYPE ...}}, fields
# sorted -- the canonical anonymous struct form, hir::types::MakeStruct's),
# or "" for a payload-free case. Never a named type: the payload has no
# source name and no identity (the case is the identity).
proc hir::enums::payloadType {id case} {
    set types [fields $id $case]
    if {$types eq {}} {
        return ""
    }
    set canonical {}
    foreach field [lsort [dict keys $types]] {
        lappend canonical $field [dict get $types $field]
    }
    return [list struct $canonical]
}

# {WHAT TYPE ...}: the payload fields of every case of enum ID, in
# declaration order (cases, then fields), each named for a diagnostic
# ("field "value" of case Expression::Constant") -- the parts a component
# analysis reads of a value of the enum.
proc hir::enums::payloadParts {id} {
    variable registry
    set parts {}
    if {![dict exists $registry $id]} {
        return {}
    }
    foreach {case descriptor} [dict get $registry $id descriptors] {
        foreach {field type} [dict get $descriptor payload] {
            lappend parts [list "field \"$field\" of case [display $id]::$case" $type]
        }
    }
    return $parts
}

# Every payload field type of every case of enum ID. For the analyses that
# ask what a value of the enum can hold (affinity, vector places, contract
# bearing).
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
# an enum without payloads is unrestricted; the rule is written over the
# case descriptors, by that rule, never by being an enum. SEEN guards a
# payload that mentions its own enum (directly, or through other enums): on
# such a cycle a payload contributes what its other components own (the
# least answer), and a cycle through a struct is the struct affinity
# summary's fixpoint (hir::structs::AffinitySummary), which reads this walk
# afresh in every round.
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

# Exact case facts (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md)
# ------------------------------------------------------------
# The case a value is known to be, whatever its payload is: the fact a later
# exhaustive matching milestone reads to decide a case selection statically
# or report an unreachable arm, which no runtime reflection gives. It is a
# compiler-internal query, never a type: every case's value has its enum's
# type, and a join of two cases is that enum.

# {ID CASE} when expression E of HIR is known to be a value of case CASE of
# enum ID -- a case constant, a payload-bearing case's construction
# (enum#case), or a read of an immutable local binding bound to one
# (followed through aliases, at most DEPTH of them) -- else "". The payload
# need not be constant: Expression::Constant {value: n} is case Constant
# whatever n is.
proc hir::enums::caseFact {hir e {depth 16}} {
    while {$depth > 0} {
        incr depth -1
        set node [dict get $hir exprs $e]
        switch -- [dict get $node kind] {
            const {
                set v [dict getdef $node value ""]
                if {$v ne "" && ![catch {core::value::kind $v} kind] && $kind eq "enum"} {
                    return [list [core::value::enumId $v] [core::value::enumCaseName $v]]
                }
                return ""
            }
            call {
                lassign [dict getdef $node target {}] targetKind target
                if {$targetKind ne "native" || [dict get [hir::symbol $hir $target] name] ne "enum#case"} {
                    return ""
                }
                lassign [dict get $node args] payload ide casee
                set id [lindex [dict getdef [dict get $hir exprs $ide] literal {}] end]
                set case [lindex [dict getdef [dict get $hir exprs $casee] literal {}] end]
                if {[hasPayload $id $case]} {
                    return [list $id $case]
                }
                return ""
            }
            ref {
                set b [dict getdef $node binding ""]
                if {$b eq "" || ![dict exists $hir bindings $b]} {
                    return ""
                }
                set binding [dict get $hir bindings $b]
                if {[dict get $binding kind] ne "local" || [dict getdef $binding declaredBy ""] eq ""
                        || [dict getdef $binding mutable 0]} {
                    return ""
                }
                set bind [dict get $binding declaredBy]
                if {![dict exists $hir exprs $bind] || [dict get $hir exprs $bind kind] ne "bind"} {
                    return ""
                }
                set e [dict get $hir exprs $bind value]
            }
            default {
                return ""
            }
        }
    }
    return ""
}

# Recursive affine enums (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md)
# ------------------------------------------------------------------
# An affine value is released by a static drop descriptor
# (hir::affine::Descriptor), a finite walk of its type; a type whose values
# nest affine values to any depth has none: a *recursive affine type*,
# AFFINE-CONTAINER-UNSUPPORTED (AFFINE-VALUES.md, hir/ownership.tcl). An
# enum's payload is such a way to any depth wherever another case ends the
# nesting -- `enum L: Nil, Cons {head: C, tail: L}` holds lists of affine
# values of every length, as a List element does -- so an affine enum whose
# values can own a value of itself is one: its payloads reach it again.
#
# The question is decided on the finite graph of enum declarations: an edge
# from E to F wherever a payload field type of E owns a value of F
# (OwnedEnums: struct fields, applied; anonymous struct fields; List,
# MutableVector, MutableArray and ImmutableSet elements; a refinement's
# base -- the drop descriptor's edges, never a C pointer's pointee or a
# function or coroutine type's signature). An affine enum on a cycle of that
# graph is a recursive affine type. A cycle through structs alone is
# hir/ownership.tcl's question, which takes an enum for a leaf; one through
# an enum is this one (`struct S: c: C, e: E` with `enum E: Nil, Has {s:
# S}` is E -> E through S). No depth, budget or count decides it.
#
# An unrestricted recursive enum (Tree's `Branch {children: List[Tree]}`)
# is an ordinary type: it owns nothing affine, so it needs no descriptor.

# Rejects every affine enum of the registry whose values can own a value of
# itself (above), at its declaration, naming the way back.
proc hir::enums::VerifyRecursion {} {
    variable registry
    dict for {id entry} $registry {
        if {![hasPayloads $id] || ![hir::types::IsAffine [list enum $id]]} continue
        set path [RecursionPath $id]
        if {$path eq ""} continue
        set message [format {enum %s is a recursive affine type: its values can own a value of %s again (%s), so they nest affine values to any depth, and an affine value needs a finite drop descriptor (store the affine values in a MutableVector of a struct, or make the recursive part unrestricted)} \
            [display $id] [display $id] [join $path " -> "]]
        set span [dict get $entry span]
        if {$span eq ""} {
            core::semanticError AFFINE-CONTAINER-UNSUPPORTED $message
        }
        Fail $span $message AFFINE-CONTAINER-UNSUPPORTED
    }
}

# The way {ENUM.CASE.FIELD ...} from enum ID back to ID along OwnedEnums
# edges, or "" when its values never own one of ID.
proc hir::enums::RecursionPath {id} {
    set queue [list [list $id {}]]
    set visited [dict create]
    while {[llength $queue]} {
        set queue [lassign $queue item]
        lassign $item current path
        variable registry
        foreach {case descriptor} [dict get $registry $current descriptors] {
            foreach {field type} [dict get $descriptor payload] {
                set step "[display $current]::$case.$field"
                foreach target [OwnedEnums $type] {
                    if {$target eq $id} {
                        return [concat $path [list $step]]
                    }
                    if {![dict exists $visited $target] && [declared $target]} {
                        dict set visited $target 1
                        lappend queue [list $target [concat $path [list $step]]]
                    }
                }
            }
        }
    }
    return ""
}

# The enums a value of TYPE can own (directly, never through another enum's
# payload): the drop descriptor's edges (above). A named struct is walked
# by its applied fields once per declaration; met again inside itself, its
# arguments are walked instead (an over-approximation: a slot no field holds
# a value of is counted too), so the walk is finite whatever applications
# substitution would make.
proc hir::enums::OwnedEnums {type {visiting {}}} {
    set type [hir::types::Unrefined $type]
    if {[hir::types::IsEnum $type]} {
        return [list [lindex $type 1]]
    }
    if {[hir::types::IsList $type]} {
        set result [OwnedEnums [lindex $type 1] $visiting]
        foreach t [hir::types::shapeOf $type] {
            lappend result {*}[OwnedEnums $t $visiting]
        }
        return [lsort -unique $result]
    }
    if {[hir::types::IsMutVec $type] || [hir::types::IsMutArray $type] || [hir::types::IsSet $type]} {
        return [OwnedEnums [lindex $type 1] $visiting]
    }
    if {[hir::types::IsStruct $type]} {
        set result {}
        foreach {name t} [lindex $type 1] {
            lappend result {*}[OwnedEnums $t $visiting]
        }
        return [lsort -unique $result]
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        set result {}
        if {$id in $visiting} {
            foreach a [lindex $type 2] {
                lappend result {*}[OwnedEnums $a $visiting]
            }
            return [lsort -unique $result]
        }
        if {![hir::structs::declared $id]} {
            return {}
        }
        foreach {name t} [hir::structs::AppliedFieldTypes $type] {
            lappend result {*}[OwnedEnums $t [concat $visiting [list $id]]]
        }
        return [lsort -unique $result]
    }
    return {}
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

# The payload field list of case CASE of enum ID as declared, for a
# message: "{value: int}", "{left: int, right: int}".
proc hir::enums::PayloadText {id case} {
    return "\{[join [lmap {field type} [fields $id $case] {string cat $field ": " [hir::types::show $type]}] {, }]\}"
}

# The ENUM-PAYLOAD-REQUIRED message: the payload-bearing case CASE of enum
# ID written as a value, without its payload.
proc hir::enums::PayloadRequiredMessage {id case} {
    set fields [lmap f [fieldNames $id $case] {string cat $f ": ..."}]
    return [format {case %s::%s carries a payload %s: a value of it is constructed with every payload field, %s::%s {%s} (there is no payload-free value of a payload-bearing case, and no default)} \
        [display $id] $case [PayloadText $id $case] [display $id] $case [join $fields {, }]]
}

# The ENUM-PAYLOAD-UNEXPECTED message: the payload-free case CASE of enum ID
# written with braces.
proc hir::enums::PayloadUnexpectedMessage {id case} {
    return [format {case %s::%s carries no payload: its value is written %s::%s, without braces (only a case declared with payload fields is constructed with them)} \
        [display $id] $case [display $id] $case]
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
                || [core::type::valid $id] || [dict exists $::hir::types::constructors $name]
                || [core::native::isBuiltinEnum $name] || [hir::traits::isIntrinsicName $name]} {
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
            set descriptor [dict create name $caseName span [dict get $case nameSpan] payload {}]
            if {[dict exists $case payload]} {
                # A payload-bearing case (PORTABILITY-PAYLOAD-ENUMS-
                # MILESTONE-1.md): its fields' types are resolved once every
                # type is registered (resolvePayloads); HIR text gives them
                # resolved (`types`, hir/read.tcl).
                set raw {}
                set fieldSpans [dict create]
                set typeSpans [dict create]
                foreach field [dict get $case payload] {
                    set fieldName [dict get $field name]
                    if {[dict exists $fieldSpans $fieldName]} {
                        Fail [dict get $field nameSpan] \
                            "duplicate field \"$fieldName\" in the payload of case $caseName of enum \"$name\": each payload field is declared once" DUPLICATE-FIELD
                    }
                    lappend raw $fieldName [dict get $field type]
                    dict set fieldSpans $fieldName [dict get $field nameSpan]
                    dict set typeSpans $fieldName [dict get $field typeSpan]
                }
                dict set descriptor hasPayload 1
                dict set descriptor fieldSpans $fieldSpans
                dict set descriptor typeSpans $typeSpans
                if {[dict exists $case types]} {
                    dict set descriptor payload [dict get $case types]
                } else {
                    dict set descriptor raw $raw
                }
            }
            dict set descriptors $caseName $descriptor
        }
        dict set registry $id [dict create id $id name $name namespace $ns cases $names \
            descriptors $descriptors span [dict get $decl nameSpan]]
        lappend entries [dict create kind enum name $name id $id namespace $ns cases $names]
    }
    return $entries
}

# Resolves the declared type of every payload field of every enum of the
# current registration (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md), in the
# namespace of the module that declares the enum -- once the program's own
# types (structs, enums, integer domains, layouts) are registered
# (hir::BuildOnce), exactly as an error payload's field types are
# (hir::errordecls::resolvePayloads). A field type is what a struct field's
# may be: any declarable type -- the case's own enum included (a recursive
# enum: Tree's `Branch {children: List[Tree]}`) -- never a trait (a payload
# stores one concrete representation) or a context trait.
proc hir::enums::resolvePayloads {} {
    variable registry
    dict for {id entry} $registry {
        set ns [dict get $entry namespace]
        dict for {case descriptor} [dict get $entry descriptors] {
            if {![dict exists $descriptor raw]} continue
            set types {}
            foreach {fieldName typeExpr} [dict get $descriptor raw] {
                set typeSpan [dict get $descriptor typeSpans $fieldName]
                set where [format {payload field "%s" of case %s::%s} $fieldName [display $id] $case]
                if {[catch {hir::resolve::ResolveTypeExpr $typeExpr $ns} resolved options]} {
                    Fail $typeSpan [format {unknown or invalid type %s for %s: %s} \
                        [hir::resolve::ShowTypeExpr $typeExpr] $where $resolved] \
                        [hir::resolve::TypeErrorKind $options TYPE]
                }
                if {[hir::types::MentionedContextTrait $resolved] ne ""} {
                    Fail $typeSpan [hir::types::ContextTraitPositionMessage \
                        [hir::types::MentionedContextTrait $resolved] "the type of $where"] CONTEXT-TRAIT-POSITION
                }
                if {[hir::types::MentionsTrait $resolved]} {
                    Fail $typeSpan [format \
                        {%s cannot have trait type %s: a payload stores one concrete representation, and there is no erased or heterogeneous trait representation (store a concrete type)} \
                        $where [hir::types::show $resolved]] TRAIT-STORAGE-UNSUPPORTED
                }
                lappend types $fieldName $resolved
            }
            dict unset descriptor raw
            dict set descriptor payload $types
            dict set registry $id descriptors $case $descriptor
        }
    }
    # (Affinity and every fact derived from it read the payloads.)
    hir::structs::ForgetAffinity
}

# 1 if some enum of the current registration has a payload whose types are
# not resolved yet (resolvePayloads).
proc hir::enums::unresolved {} {
    variable registry
    dict for {id entry} $registry {
        dict for {case descriptor} [dict get $entry descriptors] {
            if {[dict exists $descriptor raw]} {
                return 1
            }
        }
    }
    return 0
}

# Sets the resolved payload fields TYPES ({FIELD TYPE ...}) of case CASE of
# the registered enum ID (hir/read.tcl: HIR text prints them after the
# declarations their types may name).
proc hir::enums::setPayload {id case types} {
    variable registry
    if {![hasCase $id $case]} {
        error "hir::enums::setPayload: enum \"$id\" has no case \"$case\""
    }
    set descriptor [dict get $registry $id descriptors $case]
    dict unset descriptor raw
    dict set descriptor hasPayload 1
    dict set descriptor payload $types
    if {![dict exists $descriptor typeSpans]} {
        dict set descriptor fieldSpans [dict create]
        dict set descriptor typeSpans [dict create]
    }
    dict set registry $id descriptors $case $descriptor
    hir::structs::ForgetAffinity
}

# SOURCETYPES (HIR's `sourceTypes`) with every enum entry that has
# payload-bearing cases given `payloads {CASE {FIELD TYPE ...} ...}`, the
# resolved fields in declaration order (an entry of an enum without
# payloads is unchanged, so a payload-free program's HIR is too).
proc hir::enums::withPayloads {sourceTypes} {
    return [lmap entry $sourceTypes {
        if {[dict getdef $entry kind ""] eq "enum" && [hasPayloads [dict get $entry id]]} {
            set payloads {}
            foreach case [dict get $entry cases] {
                if {[hasPayload [dict get $entry id] $case]} {
                    lappend payloads $case [fields [dict get $entry id] $case]
                }
            }
            dict set entry payloads $payloads
        }
        set entry
    }]
}

# {ENUM CASE FIELD TYPE SPAN ...}: every payload field of every enum of the
# current registration, with its resolved type and the span of its type
# ("" when read back from HIR text), for the declaration checks that read
# field types (applications, privacy).
proc hir::enums::payloadFieldList {} {
    variable registry
    set result {}
    dict for {id entry} $registry {
        dict for {case descriptor} [dict get $entry descriptors] {
            foreach {field type} [dict get $descriptor payload] {
                lappend result $id $case $field $type [dict getdef $descriptor typeSpans $field ""]
            }
        }
    }
    return $result
}

# Re-registers the enum entries of a HIR's own `sourceTypes` (hir/read.tcl:
# a serialized HIR carries its declarations; core IR text builds keep them).
proc hir::enums::applyEntries {entries} {
    variable registry
    Reset
    foreach entry $entries {
        set descriptors [dict create]
        foreach case [dict get $entry cases] {
            dict set descriptors $case [dict create name $case span "" payload {}]
            if {[dict exists $entry payloads $case]} {
                dict set descriptors $case [dict create name $case span "" hasPayload 1 \
                    payload [dict get $entry payloads $case] fieldSpans {} typeSpans {}]
            }
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
