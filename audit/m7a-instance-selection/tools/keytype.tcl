#!/usr/bin/env tclsh9.0
# keytype.tcl -- M7.a: what hir::specialize::KeyType preserves or erases,
# for every static type category the compiler represents today
# (M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md, "KeyType preservation/erasure
# table"). Calls the production KeyType unmodified on hand-built static
# types, plus the M1 seeding rule (hir::specialize::Analyze's own
# declared-type merge) re-stated as a read-only observation.
#
#   tclsh9.0 audit/m7a-instance-selection/tools/keytype.tcl

source [file join [file dirname [file normalize [info script]]] lib.tcl]

# Register the lib/byte.bot domains (and a source-defined Small) the same
# way any program that mentions them would: by compiling a program that
# declares/loads them.
core::loadLibrary web
m7a::source {type Small = Int in 10..20
byte::from_int(1)
}

set byte {refined int Byte}
set cases [list \
    int                         int \
    "Byte (int refinement)"     $byte \
    "Small (source Int in 10..20)" {refined int Small} \
    "HighNibble (exact set)"    {refined int HighNibble} \
    bool                        bool \
    str                         str \
    "Emailish-like str refinement (UriQueryValue)" {refined str UriQueryValue} \
    UnicodeChar                 UnicodeChar \
    unit                        unit \
    result                      result \
    mutarray                    mutarray \
    "List (broad kind)"         list \
    {List[int]}                 {list int} \
    {List[Byte]}                [list list $byte] \
    {List[never] (empty)}       {list never} \
    {List shaped [int, str]}    {list any {int str}} \
    {List[List[Byte]]}          [list list [list list $byte]] \
    "ImmutableSet (broad kind)" immutableSet \
    {ImmutableSet[Byte]}        [list immutableSet $byte] \
    {ImmutableSet[never]}       {immutableSet never} \
    {exact block {block e7 1 int}} {block e7 1 int} \
    {exact native {native +}}   {native +} \
    "block (kind only)"         block \
    "native (kind only)"        native \
    any                         any \
    never                       never]

puts [format "%-48s %-28s %-22s %s" "static type" "form" "KeyType" "M1 seed with declared T=same type"]
foreach {label type} $cases {
    set key [hir::specialize::KeyType $type]
    # hir::specialize::Analyze's seeding rule, stated here only to report
    # what a *declared* parameter of the same type would re-add after
    # identity selection (M1): specific keys are kept, everything else is
    # narrowed/adopted from the declaration.
    if {[hir::types::IsSpecific $key]} {
        set seeded $key
    } elseif {[hir::types::IsSpecific $type]} {
        set seeded $type
    } else {
        set seeded [hir::types::narrow $key $type]
    }
    puts [format "%-48s %-28s %-22s %s" $label [hir::types::show $type] [hir::types::show $key] [hir::types::show $seeded]]
}
