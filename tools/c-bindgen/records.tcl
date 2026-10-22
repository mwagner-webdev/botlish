# records.tcl -- C records and the layouts the generator emits for them
# (C-BINDGEN-LAYOUTS.md).
#
#   ::cbind::records::requests MODEL           the typedef and enum ABI probes
#                                              the records' field types need
#   ::cbind::records::probeEntries MODEL       the layout probe: sizeof,
#                                              _Alignof, offsetof and each
#                                              field's sizeof, as the compiler
#                                              computes them
#   ::cbind::records::resolve MODEL FACTS      every record classified, named,
#                                              ordered; the emitted layouts
#
# A record is a C struct or union tag. The candidates are the complete
# records the profile's public headers define and every record they contain
# by value (of any header): one entry each, keyed by the tag ("struct T",
# "union T"; an anonymous one by the parser's anon@FILE:LINE tag). Each is
#
#   layout-direct    complete, and every field one Botlish's layout language
#                    represents as it is: a C integer scalar (an integer
#                    typedef or an enum resolved to the scalar the compiler
#                    confirms), a data or function pointer of the existing
#                    pointer mapping (its pointee identity kept), a fixed
#                    array of those, or a record emitted as a layout, nested
#                    by value. Its layout states the compiler's sizeof,
#                    _Alignof and offsetof, nothing computed: padding is the
#                    gaps, packing and alignment attributes are whatever
#                    they made of the numbers. A union is a `union layout`
#                    (LAYOUT-UNIONS.md): its members are its alternatives,
#                    each at the offset the compiler gives (0, or the union
#                    is blocked: union-member-offset).
#   layout-blocked   complete, with every blocker found: a direct one (a
#                    flexible array, a bitfield, a long double (C float
#                    and double are layout fields: C-FLOAT-FFI-
#                    MILESTONE-1.md), a C _Bool, volatile, _Atomic, a field type
#                    outside the ABI universe, ...) or a transitive one (a
#                    record it contains by value is blocked:
#                    nested-layout-blocked, with the chain to the first
#                    direct blocker).
#   opaque-only      incomplete: a nominal pointee identity, never a layout.
#
# An anonymous member (a struct or union member with no name, C11) has no
# C type name: its members are named as members of the record that has it.
# An anonymous struct in a struct is promoted -- its members are the
# struct's own fields, each at its own offset (no overlap: nothing is lost)
# -- and every other anonymous member (an anonymous union, an anonymous
# struct in a union) is a *synthetic* record: a layout of its own, named by
# its place (the container's name and its member's: OVERLAPPED_member3),
# held by value by a generated field of its container (member3), never
# flattened into overlapping fields. Its members' offsets are the
# compiler's offsetof through the record that names them (the owner, the
# first enclosing record with a C name), less the anonymous member's own
# offset there; its sizeof, alignment and members' offsets within it are
# clang's record layout (probe.tcl's anonymous: no C expression asks them),
# and the two answers must agree.
#
# Nothing here computes a C layout or reads a fact from a name: field types
# are the declaration parser's, mapped by the binding model's own type
# mapping (model.tcl: Value, Pointer, EnumScalar, TypedefAbiProblem), every
# number is the compiler's. A record's nominal identity (the opaque struct of
# the ctypes module, model.tcl's Identity) and its layout are two facts: the
# identity names the C type a pointer points to, complete or not; the layout
# describes where a complete record's bytes are, on this target.

namespace eval ::cbind::records {
    # The state of one resolution.
    variable records {}
    variable order {}
    variable facts {}
    # Synthetic records' clang layouts (Block) and offsets in their owners
    # (Base), as resolved.
    variable blockOf {}
    variable bases {}
}

# ---------------------------------------------------------------------------
# Discovery.

# The C struct and union records of MODEL's translation unit: a dict KEY ->
# record (see the file header), in translation-unit order of their
# definitions, the candidates only (public complete records and their
# by-value closure) plus every public incomplete tag (opaque-only). Fields
# are mapped later (Classify).
proc ::cbind::records::Discover {model} {
    set ix $::cbind::model::ix
    set defs [dict create]
    set defOrder {}
    foreach r [dict get $model records] {
        lassign $r kind name body
        if {$kind ne "struct" || ![dict get $body complete]} continue
        set key "[dict get $body kind] $name"
        if {[dict exists $defs $key]} continue
        dict set defs $key $body
        lappend defOrder $key
    }
    # The typedefs naming each tag: directly (typedef struct T NAME) first,
    # then through other typedefs, in translation-unit order.
    set spellings [dict create]
    set typedefAt [dict create]
    foreach r [dict get $model records] {
        lassign $r kind name body
        if {$kind ne "typedef"} continue
        lassign [::cir::resolve $ix [dict get $body type]] chain final
        set final [::cir::unq $final]
        # Where a tag no record declares is named: the first typedef naming
        # it, through pointers too (typedef struct T *H).
        set pointee $final
        while {[lindex $pointee 0] eq "ptr"} { set pointee [::cir::unq [lindex $pointee 1]] }
        if {[lindex $pointee 0] in {struct union}} {
            set k "[lindex $pointee 0] [lindex $pointee 1]"
            if {![dict exists $typedefAt $k]} { dict set typedefAt $k [list [dict get $body loc] [dict get $body origin]] }
        }
        if {[lindex $final 0] in {struct union}} {
            dict lappend spellings "[lindex $final 0] [lindex $final 1]" $name
        }
    }
    # The anonymous records' users: the first named field whose type is
    # one (through arrays), for a C name to probe it by.
    set users [dict create]
    foreach key $defOrder {
        set i 0
        foreach f [dict get $defs $key fields] {
            lassign $f fname ftype
            set t [::cir::unq $ftype]
            set depth 0
            while {[lindex $t 0] eq "array"} { set t [::cir::unq [lindex $t 1]]; incr depth }
            if {[lindex $t 0] in {struct union} && [string match anon@* [lindex $t 1]]} {
                set k "[lindex $t 0] [lindex $t 1]"
                if {![dict exists $users $k]} {
                    dict set users $k [dict create container $key field $fname index $i depth $depth]
                }
            }
            incr i
        }
    }
    # Candidates: public complete records, then their by-value closure.
    set wanted [dict create]
    set queue {}
    foreach key $defOrder {
        if {[dict get $defs $key origin] eq "public"} {
            dict set wanted $key 1
            lappend queue $key
        }
    }
    while {[llength $queue]} {
        set queue [lassign $queue key]
        foreach f [dict get $defs $key fields] {
            set t [::cir::unq [::cir::final $ix [lindex $f 1]]]
            while {[lindex $t 0] eq "array"} { set t [::cir::unq [::cir::final $ix [lindex $t 1]]] }
            if {[lindex $t 0] in {struct union}} {
                set k "[lindex $t 0] [lindex $t 1]"
                if {[dict exists $defs $k] && ![dict exists $wanted $k]} {
                    dict set wanted $k 1
                    lappend queue $k
                }
            }
        }
    }
    set out [dict create]
    foreach key $defOrder {
        if {![dict exists $wanted $key]} continue
        set body [dict get $defs $key]
        set tag [lindex $key 1]
        set rec [dict create key $key kind [lindex $key 0] tag $tag complete 1 \
            anonymous [string match anon@* $tag] origin [dict get $body origin] \
            header [lindex [dict get $body loc] 0] line [lindex [dict get $body loc] 1] \
            fieldsC [dict get $body fields] attrs [dict get $body attrs] \
            typedefs [expr {[dict exists $spellings $key] ? [dict get $spellings $key] : {}}]]
        if {[dict exists $users $key]} {
            set u [dict get $users $key]
            dict set rec user $u
            # An anonymous member: its members are named as members of the
            # record that has it (C11). An anonymous struct's in a struct
            # are promoted into it, where they are probed and emitted (it is
            # no record of its own); any other anonymous member is a
            # synthetic record (an anonymous union, an anonymous struct in a
            # union: its members overlap the union's other alternatives).
            if {[dict get $u field] eq ""} {
                dict set rec memberOf [dict get $u container]
                if {[lindex $key 0] eq "struct" && [lindex [dict get $u container] 0] eq "struct"} {
                    dict set rec promotedInto [dict get $u container]
                }
            }
        }
        dict set out $key $rec
    }
    # Public tags never completed: opaque-only (the report's public tags:
    # declared in a public header, or named by a public typedef).
    foreach key [::cbind::report::PublicTags $model $ix] {
        if {[dict exists $out $key]} continue
        if {[dict exists $ix tag $key] && [dict get $ix tag $key complete]} continue
        if {[dict exists $ix tag $key]} {
            set loc [dict get $ix tag $key loc]
            set origin [dict get $ix tag $key origin]
        } else {
            lassign [dict get $typedefAt $key] loc origin
        }
        dict set out $key [dict create key $key kind [lindex $key 0] tag [lindex $key 1] complete 0 \
            anonymous 0 origin $origin header [lindex $loc 0] line [lindex $loc 1] \
            fieldsC {} attrs {} typedefs [expr {[dict exists $spellings $key] ? [dict get $spellings $key] : {}}]]
    }
    return $out
}

# The C type expression the probes name record REC by, or "" when it has
# none: its tag, the first typedef naming an anonymous one directly, or the
# type of the member of a named container that has it (__typeof__).
proc ::cbind::records::CName {recs key} {
    set rec [dict get $recs $key]
    if {![dict get $rec anonymous]} { return $key }
    set direct [DirectTypedef $key]
    if {$direct ne ""} { return $direct }
    if {[dict exists $rec user]} {
        set u [dict get $rec user]
        if {[dict get $u field] eq ""} { return "" }
        set container [CName $recs [Owner $recs [dict get $u container]]]
        if {$container eq ""} { return "" }
        set access "(($container *)0)->[dict get $u field][string repeat {[0]} [dict get $u depth]]"
        return "__typeof__($access)"
    }
    return ""
}

# The record whose member a member of record KEY is, as C names it: KEY
# itself, or for an anonymous member (struct or union) the record it is a
# member of (through any number of them).
proc ::cbind::records::Owner {recs key} {
    while {[dict exists $recs $key memberOf]} { set key [dict get $recs $key memberOf] }
    return $key
}

# 1 if record KEY is a synthetic record: an anonymous member that is not
# promoted (an anonymous union, an anonymous struct in a union).
proc ::cbind::records::Synthetic {recs key} {
    set rec [dict get $recs $key]
    return [expr {[dict exists $rec memberOf] && ![dict exists $rec promotedInto]}]
}

# The generated field that holds synthetic record KEY, as a path from its
# owner's layout (OVERLAPPED.member3, OVERLAPPED.member3.member1): its
# container's path and its slot there (Members': through the anonymous
# structs promoted into the container).
proc ::cbind::records::Path {recs key} {
    set rec [dict get $recs $key]
    set slot member[expr {[dict get $rec user index] + 1}]
    set container [dict get $rec user container]
    while {[dict exists $recs $container promotedInto]} {
        set slot member[expr {[dict get $recs $container user index] + 1}]_$slot
        set container [dict get $recs $container user container]
    }
    if {[Synthetic $recs $container]} { return "[Path $recs $container].$slot" }
    return "[dict get $recs $container layoutName].$slot"
}

# The C type expression the probes name record KEY's members through: its
# own C name, or a synthetic record's owner's ("" when there is none).
proc ::cbind::records::ProbeName {recs key} {
    if {[Synthetic $recs $key]} { return [CName $recs [Owner $recs $key]] }
    return [CName $recs $key]
}

# The first typedef (translation-unit order) naming tag KEY directly, or "".
proc ::cbind::records::DirectTypedef {key} {
    if {[dict exists $::cbind::model::tagNames $key]} { return [dict get $::cbind::model::tagNames $key] }
    return ""
}

# ---------------------------------------------------------------------------
# Fields.

# The fields of REC as the layout sees them: a list of dicts
#
#   cname   the C member name ("" for an unnamed bitfield or an anonymous
#           member)
#   path    the member's C designator for offsetof ("" when it has none)
#   ctype   its declared C type
#   bits    its bitfield width ({lit N}, {expr TEXT}) or ""
#   via     the anonymous struct members it was promoted through ({} if
#           none)
#   slot    the member's place for a generated name: memberN (N its
#           position among its record's C members, from 1), prefixed by the
#           slots of the members it was promoted through (member2_member1)
#
# An anonymous struct member's members are a struct's own (C11: they are
# named as members of the enclosing record): they are promoted, each at its
# own offset. Any other anonymous member is kept as one field, a synthetic
# record held by value (the file header).
proc ::cbind::records::Members {recs rec {via {}} {prefix ""}} {
    set out {}
    set i 0
    foreach f [dict get $rec fieldsC] {
        lassign $f cname ctype bits attrs
        incr i
        set t [::cir::unq $ctype]
        if {$cname eq "" && $bits eq "" && [lindex $t 0] eq "struct" && [string match anon@* [lindex $t 1]]
                && [dict exists $recs "struct [lindex $t 1]" promotedInto]} {
            set inner [dict get $recs "struct [lindex $t 1]"]
            lappend out {*}[Members $recs $inner [concat $via [list "struct [lindex $t 1]"]] ${prefix}member${i}_]
            continue
        }
        lappend out [dict create cname $cname path $cname ctype $ctype bits $bits attrs $attrs via $via slot ${prefix}member$i]
    }
    return $out
}

# The array dimensions and element type of TYPE: {BOUNDS ELEMENT}, BOUNDS
# the bounds outermost first.
proc ::cbind::records::ArrayOf {type} {
    set ix $::cbind::model::ix
    set bounds {}
    set elem $type
    set t [::cir::unq [::cir::final $ix $type]]
    while {[lindex $t 0] eq "array"} {
        lappend bounds [lindex $t 2]
        set elem [lindex $t 1]
        set t [::cir::unq [::cir::final $ix $elem]]
    }
    return [list $bounds $elem]
}

# What a field of C type TYPE is to a layout: {ok scalar TEXT}, {ok pointer
# TEXT}, {ok nested KEY}, {ok array {DEPTH ELEMENT}} (a fixed array of
# DEPTH dimensions -- their extents are the layout probe's, never the
# declaration's expressions -- whose innermost ELEMENT is one of the other
# three, {KIND TEXT}: FIXED-LAYOUT-ARRAYS.md), or {no BLOCKERS DEPS},
# BLOCKERS the direct blockers {REASON DETAIL} (every one), DEPS the records
# it contains by value ({KEY RELATION}). The scalar and pointer mapping is
# the binding model's (model.tcl), the one function signatures use.
proc ::cbind::records::FieldType {type} {
    set ix $::cbind::model::ix
    lassign [::cir::resolve $ix $type] chain final
    set quals [::cir::quals $final]
    set t [::cir::unq $final]
    set blockers {}
    if {"volatile" in $quals} { lappend blockers [list volatile "a volatile field: [::cir::spell $type]"] }
    if {"_Atomic" in $quals} { lappend blockers [list atomic "an _Atomic field: [::cir::spell $type]"] }
    set first [::cir::unq $type]
    set via [expr {[lindex $first 0] eq "typedef" ? [lindex $first 1] : ""}]
    switch -- [lindex $t 0] {
        int {
            set s [::cbind::model::ScalarOf [lindex $t 1]]
            if {$s eq ""} {
                lappend blockers [list unsupported-field-type "[lindex $t 1] (no C ABI scalar of that type)"]
            } elseif {$via ne ""} {
                set problem [::cbind::model::TypedefAbiProblem $via [lindex $t 1]]
                if {$problem ne ""} { lappend blockers [list typedef-abi-mismatch $problem] }
            }
            if {$blockers ne ""} { return [list no $blockers {}] }
            return [list ok scalar $s]
        }
        enum {
            set e [::cbind::model::EnumScalar [lindex $t 1] [EnumVia $chain]]
            if {$e eq ""} {
                lappend blockers [list enum-unknown-abi "enum [lindex $t 1]: the compiler did not give its integer type"]
            }
            if {$blockers ne ""} { return [list no $blockers {}] }
            return [list ok scalar [lindex $e 0]]
        }
        bool { return [list no [concat $blockers [list [list c-bool "C _Bool ([::cir::spell $type])"]]] {}] }
        float {
            # A C float or double field (C-FLOAT-FFI-MILESTONE-1.md): the
            # binding model's mapping, its typedef chain confirmed by the
            # compiler as an integer's is; long double and the extended
            # floating types stay blocked by their own reasons.
            set m [::cbind::model::Floating [lindex $t 1]]
            if {[lindex $m 0] ne "ok"} {
                return [list no [concat $blockers [lindex $m 1]] {}]
            }
            if {$via ne ""} {
                set problem [::cbind::model::TypedefAbiProblem $via [lindex $t 1]]
                if {$problem ne ""} { lappend blockers [list typedef-abi-mismatch $problem] }
            }
            if {$blockers ne ""} { return [list no $blockers {}] }
            return [list ok scalar [lindex $m 1]]
        }
        complex { return [list no [concat $blockers [list [list complex "_Complex [lindex $t 1]"]]] {}] }
        ptr {
            set m [::cbind::model::Pointer [lindex $t 1]]
            if {[lindex $m 0] ne "ok"} {
                set inner [join [lmap b [lindex $m 1] {string cat [lindex $b 1] " (" [lindex $b 0] ")"}] "; "]
                return [list no [concat $blockers [list [list unsupported-pointer $inner]]] {}]
            }
            if {$blockers ne ""} { return [list no $blockers {}] }
            return [list ok pointer [lindex $m 1]]
        }
        struct - union {
            set key "[lindex $t 0] [lindex $t 1]"
            if {$blockers ne ""} { return [list no $blockers [list [list $key field]]] }
            return [list ok nested $key]
        }
        array {
            lassign [ArrayOf $t] bounds elem
            set flexible [expr {"" in $bounds || {lit 0} in $bounds}]
            set inner [FieldType $elem]
            set deps {}
            if {[lindex $inner 0] eq "ok" && [lindex $inner 1] eq "nested"} {
                lappend deps [list [lindex $inner 2] array-element]
            } elseif {[lindex $inner 0] eq "no"} {
                lappend deps {*}[lmap d [lindex $inner 2] {list [lindex $d 0] array-element}]
            }
            set out $blockers
            if {$flexible} {
                # A flexible array member, or a zero-length array: no fixed
                # extent, so no layout (FIXED-LAYOUT-ARRAYS.md).
                lappend out [list flexible-array "[ElementCategory $elem $inner] elements, [::cir::spell $type]"]
            }
            # The element's own blockers stay visible (an array of floats is
            # blocked by its element).
            if {[lindex $inner 0] eq "no"} {
                foreach b [lindex $inner 1] {
                    if {[lindex $b 0] ne "flexible-array"} { lappend out [list [lindex $b 0] "array element: [lindex $b 1]"] }
                }
            }
            if {[llength $out]} { return [list no $out $deps] }
            return [list ok array [list [llength $bounds] [lrange $inner 1 2]]]
        }
        fn { return [list no [concat $blockers [list [list unsupported-field-type "a function type ([::cir::spell $type])"]]] {}] }
        typedef {
            return [list no [concat $blockers [list [list unresolved-typedef "[lindex $t 1] (no declaration of it)"]]] {}]
        }
        builtin {
            set reason [expr {[string match *va_list [lindex $t 1]] ? "va-list" : "unsupported-field-type"}]
            return [list no [concat $blockers [list [list $reason [lindex $t 1]]]] {}]
        }
        atomic { return [list no [concat $blockers [list [list atomic "_Atomic([::cir::spell [lindex $t 1]])"]]] {}] }
        default {
            return [list no [concat $blockers [list [list unsupported-field-type [::cir::spell $t]]]] {}]
        }
    }
}

# The width in bytes of the std::ffi::c scalar NAME (an integer scalar, or a C
# floating type: C-FLOAT-FFI-MILESTONE-1.md) on the target being generated,
# from core/cabi.tcl's table: the representation's, never a carrier's.
proc ::cbind::records::ScalarWidth {name} {
    if {[core::cabi::isFloating $name]} {
        return [dict get [core::cabi::floatingInfo $name $::cbind::model::target] bytes]
    }
    return [expr {[dict get [core::cabi::scalarInfo $name $::cbind::model::target] bits] / 8}]
}

# The typedef of CHAIN that names an enum directly (its ABI probe), or "".
proc ::cbind::records::EnumVia {chain} {
    if {[llength $chain]} { return [lindex $chain end] }
    return ""
}

# The category of an array's element for the pressure report: char (a C
# character type), wide-char (a chain through wchar_t, char16_t, char32_t:
# the standard's typedefs), scalar, pointer, record, array, other.
proc ::cbind::records::ElementCategory {elem mapped} {
    set ix $::cbind::model::ix
    lassign [::cir::resolve $ix $elem] chain final
    set t [::cir::unq $final]
    foreach name $chain {
        if {$name in {wchar_t char16_t char32_t}} { return wide-char }
    }
    if {[lindex $t 0] eq "int" && [lindex $t 1] in {char {signed char} {unsigned char}}} { return char }
    if {[lindex $mapped 0] eq "ok"} {
        return [dict get {scalar scalar pointer pointer nested record} [lindex $mapped 1]]
    }
    switch -- [lindex $t 0] {
        struct - union { return record }
        array { return array }
        ptr { return pointer }
        int - enum { return scalar }
    }
    return other
}

# ---------------------------------------------------------------------------
# Probe requests.

# The typedef and enum ABI questions the candidate records' field types
# raise (every typedef on every field type's chain, as for signatures):
# value entries for the binding model's ABI probe, minus those MODEL already
# asks.
proc ::cbind::records::requests {model} {
    set recs [Discover $model]
    set ix $::cbind::model::ix
    set have [dict create]
    foreach e [dict get $model requests values] { dict set have [lindex $e 0] 1 }
    set seen [dict create]
    set out {}
    dict for {key rec} $recs {
        foreach f [dict get $rec fieldsC] {
            set queue [::cbind::model::TypeNames [lindex $f 1]]
            while {[llength $queue]} {
                set queue [lassign $queue r]
                if {[dict exists $seen $r]} continue
                dict set seen $r 1
                lassign $r what name
                if {$what eq "typedef" && [dict exists $ix typedef $name]} {
                    lappend queue {*}[::cbind::model::TypeNames [dict get $ix typedef $name type]]
                    set e [::cbind::model::TypedefConventionEntry $name]
                    if {$e ne "" && ![dict exists $have cctd:$name]} {
                        dict set have cctd:$name 1
                        lappend out $e
                    }
                    lassign [::cbind::model::Resolve [list typedef $name]] chain final
                    if {[lindex $final 0] in {int bool enum float} && ![dict exists $have td:$name]} {
                        dict set have td:$name 1
                        lappend out [list td:$name [list "sizeof($name)" [::cbind::probe::typeCodeOf $name]]]
                    }
                } elseif {$what eq "enum" && ![string match anon@* $name] && ![dict exists $have enum:$name]} {
                    dict set have enum:$name 1
                    lappend out [list enum:$name [list "sizeof(enum $name)" [::cbind::probe::typeCodeOf "enum $name"]]]
                }
            }
        }
    }
    return $out
}

# The layout probe of MODEL's candidate records: {ENTRIES UNDEFS}. ENTRIES
# are value entries -- rec:KEY {sizeof _Alignof} (none for a synthetic
# record: no C expression names it), fld:KEY:I {offsetof sizeof} (offsetof
# alone for a flexible array member, nothing for a bitfield or an anonymous
# member; a synthetic record's members through its owner, whose member C
# names them), dim:KEY:I {the element count of an array member}, dims:KEY:I
# {each dimension's element count, outermost first, then the innermost
# element's sizeof} -- UNDEFS the macros to #undef before them: a record's,
# a typedef's and a member's names are the preprocessed declarations'
# tokens, which a macro defined after the declaration would rewrite in the
# probe.
proc ::cbind::records::probeEntries {model} {
    set recs [Discover $model]
    set entries {}
    set names [dict create]
    dict for {key rec} $recs {
        if {![dict get $rec complete] || [dict exists $rec promotedInto]} continue
        set c [ProbeName $recs $key]
        if {$c eq ""} continue
        foreach w [regexp -all -inline {[A-Za-z_][A-Za-z0-9_]*} $c] { dict set names $w 1 }
        if {![Synthetic $recs $key]} {
            lappend entries [list rec:$key [list "sizeof($c)" "_Alignof($c)"]]
        }
        set i 0
        foreach m [Members $recs $rec] {
            if {[dict get $m path] ne "" && [dict get $m bits] eq ""} {
                set p [dict get $m path]
                dict set names $p 1
                lassign [ArrayOf [dict get $m ctype]] bounds
                if {[llength $bounds] && ([lindex $bounds 0] eq "" || [lindex $bounds 0] eq {lit 0})} {
                    lappend entries [list fld:$key:$i [list "__builtin_offsetof($c, $p)"]]
                } else {
                    set e [::cbind::model::ConventionEntry ccfld:$key:$i "(($c *)0)->$p" [dict get $m ctype] \
                        [::cbind::model::Conventions [dict get $m attrs]]]
                    if {$e ne ""} { lappend entries $e }
                    lappend entries [list fld:$key:$i [list "__builtin_offsetof($c, $p)" "sizeof((($c *)0)->$p)"]]
                    if {[llength $bounds]} {
                        lappend entries [list dim:$key:$i [list "sizeof((($c *)0)->$p) / sizeof((($c *)0)->$p\[0\])"]]
                        # Every dimension's extent, outermost first, then the
                        # innermost element's size: the compiler's answers
                        # (FIXED-LAYOUT-ARRAYS.md), never the bound
                        # expressions'.
                        set questions {}
                        set at "(($c *)0)->$p"
                        foreach b $bounds {
                            lappend questions "sizeof($at) / sizeof($at\[0\])"
                            append at "\[0\]"
                        }
                        lappend questions "sizeof($at)"
                        lappend entries [list dims:$key:$i $questions]
                    }
                }
            }
            incr i
        }
    }
    set undefs {}
    foreach m [dict get $model macroOrder] {
        if {[dict exists $names $m]} { lappend undefs $m }
    }
    # Macros of system headers too (a system macro can rename a member).
    foreach name [dict keys $names] {
        if {$name ni $undefs && [dict exists $::cbind::records::allMacros $name]} { lappend undefs $name }
    }
    return [list $entries [lsort $undefs]]
}

# Every macro defined at the end of the translation unit (any origin): set
# by generate.tcl from the pipeline's macro records.
namespace eval ::cbind::records { variable allMacros [dict create] }

# The C names of the records whose layouts hold MODEL's synthetic records
# (their owners), for clang's record layouts (probe.tcl's anonymous): the
# owners the layout probe FACTS could size, in a fixed order.
proc ::cbind::records::anonymousOwners {model facts} {
    set recs [Discover $model]
    set out [dict create]
    dict for {key rec} $recs {
        if {![dict get $rec complete] || ![Synthetic $recs $key]} continue
        set owner [Owner $recs $key]
        set c [CName $recs $owner]
        if {$c eq "" || ![dict exists $facts rec:$owner] || [lindex [dict get $facts rec:$owner] 0] ne "ok"} continue
        dict set out $c 1
    }
    return [dict keys $out]
}

# ---------------------------------------------------------------------------
# Classification, naming, order.

# MODEL with its records resolved: `layouts` (the record entries, see the
# file header, translation-unit order) and `layoutOrder` (the emitted
# layouts' keys in emission order: every nested layout before its first
# user). FACTS is the layout probe's (probe.tcl values of probeEntries),
# with clang's record layouts of the anonymous members under anon:layouts
# ({ok BLOCKS} or {error MESSAGE}: probe.tcl's anonymous).
proc ::cbind::records::resolve {model theFacts} {
    variable facts $theFacts
    variable blockOf [dict create]
    variable bases [dict create]
    variable blockIndex
    unset -nocomplain blockIndex
    set recs [Discover $model]
    # Map every record's members.
    dict for {key rec} $recs {
        dict set recs $key [Classify $recs $rec]
    }
    # Emittability: a record is emitted when it has no direct blocker and
    # every record it contains by value is emitted (the dependency graph,
    # by-value edges only: a pointer is no dependency), decided in
    # dependency order, once each.
    set order [Order recs [dict keys $recs]]
    foreach key $order {
        Settle $key recs
    }
    # Names, then the emission order: every emitted record after the ones it
    # holds by value, translation-unit order otherwise.
    set recs [Name $recs]
    # A synthetic record is a layout only as part of its owner's: one whose
    # owner is blocked is no layout any program reaches, nor one C can
    # check (no C expression names it), and is not emitted (`unheld`).
    dict for {key rec} $recs {
        set unheld [expr {[dict get $rec synthetic] && [dict get $rec status] eq "layout-direct"
            && [dict get $recs [dict get $rec owner] status] ne "layout-direct"}]
        dict set recs $key unheld $unheld
    }
    set emitted [Order recs [lmap {k r} $recs {expr {[dict get $r status] eq "layout-direct" && ![dict get $r unheld] ? $k : [continue]}}]]
    dict set model layouts $recs
    dict set model recordOrder $order
    dict set model layoutOrder $emitted
    dict set model identities $::cbind::model::identities
    return $model
}

# REC with its members mapped and its probe facts read: fields (each with
# kind scalar|pointer|nested|array|blocked, type -- an array's extents, its
# element in `element` -- offset, size), direct blockers, deps, size, align.
# A synthetic record's offsets are relative to itself (Base), its sizeof
# and alignment clang's record layout's (Block).
proc ::cbind::records::Classify {recs rec} {
    variable facts
    set key [dict get $rec key]
    dict set rec direct {}
    dict set rec deps {}
    dict set rec fields {}
    dict set rec size ""
    dict set rec align ""
    dict set rec cname ""
    dict set rec synthetic 0
    if {![dict get $rec complete]} {
        dict set rec status opaque-only
        return $rec
    }
    if {[dict exists $rec promotedInto]} {
        dict set rec status promoted
        return $rec
    }
    set c [CName $recs $key]
    dict set rec cname $c
    set direct {}
    set deps {}
    set synthetic [Synthetic $recs $key]
    dict set rec synthetic $synthetic
    set base 0
    set block ""
    set unanchored 0
    if {$synthetic} {
        # An anonymous member: probed through its owner, laid out by clang.
        set owner [Owner $recs $key]
        dict set rec owner $owner
        lassign [Block $recs $key] block why
        set base [Base $recs $key]
        if {[CName $recs $owner] eq ""} {
            lappend direct [list anonymous-record "an anonymous member of $owner, which no type name, typedef or named member reaches: no C expression names its members"]
        } elseif {$block eq ""} {
            lappend direct [list anonymous-record "an anonymous member of $owner whose layout clang's record layouts do not give: $why"]
        } else {
            dict set rec size [dict get $block size]
            dict set rec align [dict get $block align]
            dict set rec at "[dict get $block file]:[dict get $block line]:[dict get $block col]"
            if {[dict get $block size] == 0} { lappend direct [list empty-record "sizeof is 0 (an empty record, a GNU extension)"] }
            set unanchored [expr {$base eq ""}]
        }
    } elseif {$c eq ""} {
        lappend direct [list anonymous-record "an anonymous record no type name, typedef or named member reaches: nothing to probe it by"]
    } elseif {[dict exists $facts rec:$key]} {
        lassign [dict get $facts rec:$key] st data
        if {$st eq "ok"} {
            lassign $data size align
            dict set rec size $size
            dict set rec align $align
            if {$size == 0} { lappend direct [list empty-record "sizeof is 0 (an empty record, a GNU extension)"] }
        } else {
            lappend direct [list probe-rejected "the compiler rejects sizeof($c): $data"]
        }
    }
    set fields {}
    set i 0
    set promoted 0
    foreach m [Members $recs $rec] {
        set f [dict merge $m [dict create index $i kind blocked type "" offset "" size "" blockers {}]]
        if {[llength [dict get $m via]]} { set promoted 1 }
        if {[dict exists $facts fld:$key:$i]} {
            lassign [dict get $facts fld:$key:$i] st data
            if {$st eq "ok" && $base ne ""} {
                dict set f offset [expr {[lindex $data 0] - $base}]
                if {[llength $data] > 1} { dict set f size [lindex $data 1] }
            }
        }
        if {[dict exists $facts dim:$key:$i] && [lindex [dict get $facts dim:$key:$i] 0] eq "ok"} {
            dict set f extent [lindex [dict get $facts dim:$key:$i] 1 0]
        }
        set fb {}
        set t [::cir::unq [dict get $m ctype]]
        set anon [AnonymousMember $recs $m]
        if {[dict get $m bits] ne ""} {
            set width [::cir::BoundText [dict get $m bits]]
            lappend fb [list bitfield "[expr {[dict get $m cname] eq "" ? "an unnamed bitfield" : "bitfield [dict get $m cname]"}]: [::cir::spell [dict get $m ctype]] : $width"]
        } elseif {$anon ne ""} {
            # A synthetic record, held by value at its own offset in this
            # record (both relative to the owner).
            lappend deps [list $anon anonymous-member]
            dict set f kind nested
            dict set f type $anon
            set inner [Base $recs $anon]
            if {$inner ne "" && $base ne ""} {
                dict set f offset [expr {$inner - $base}]
                lassign [Block $recs $anon] ib
                if {$block ne "" && $ib ne ""} {
                    set at "[dict get $ib file]:[dict get $ib line]:[dict get $ib col]"
                    if {![dict exists $block nested $at] || [dict get $block nested $at] != [dict get $f offset]} {
                        lappend fb [list probe-rejected "the compiler's offsets place the anonymous member $anon at [dict get $f offset], clang's record layout does not"]
                    }
                }
            }
        } elseif {[dict get $m cname] eq "" && [lindex $t 0] in {struct union}} {
            set k "[lindex $t 0] [lindex $t 1]"
            lappend fb [list unsupported-field-type "an unnamed member of the named type $k (a Microsoft extension)"]
            if {[dict exists $recs $k]} { lappend deps [list $k anonymous-member] }
        } else {
            set mapped [FieldType [dict get $m ctype]]
            set ccs [::cbind::model::Conventions [dict get $m attrs]]
            if {[llength $ccs] && ![FieldConvention $key $i]} {
                set mapped [list no [list [list unsupported-calling-convention "an explicit calling convention: [join $ccs {, }]"]] {}]
            }
            if {[lindex $mapped 0] eq "ok" && [lindex $mapped 1] eq "array"} {
                set mapped [ArrayField $recs $key $i $f [lindex $mapped 2] fb deps]
            }
            if {[lindex $mapped 0] eq "ok"} {
                dict set f kind [lindex $mapped 1]
                dict set f type [lindex $mapped 2]
                if {[lindex $mapped 1] eq "array"} {
                    dict set f element [lindex $mapped 3]
                } elseif {[lindex $mapped 1] eq "nested"} {
                    if {[dict exists $recs [lindex $mapped 2]]} {
                        lappend deps [list [lindex $mapped 2] [expr {[dict get $rec kind] eq "union" ? "union-member" : "field"}]]
                    } else {
                        lappend fb [list unsupported-field-type "[lindex $mapped 2] by value, a record of no candidate definition"]
                        dict set f kind blocked
                    }
                }
            } else {
                lassign $mapped _ bl ds
                lappend fb {*}$bl
                foreach d $ds {
                    if {[dict exists $recs [lindex $d 0]]} { lappend deps $d }
                }
            }
            # Clang's record layout of a synthetic record says where its
            # named members are too: the two answers agree, or neither is
            # taken.
            if {$block ne "" && [dict get $f offset] ne "" && [dict exists $block leaves [dict get $m cname]]
                    && [dict get $block leaves [dict get $m cname]] != [dict get $f offset]} {
                lappend fb [list probe-rejected "offsetof places member [dict get $m path] at [dict get $f offset] in this anonymous member, clang's record layout at [dict get $block leaves [dict get $m cname]]"]
            }
            if {[dict get $f kind] ne "blocked" && [dict get $f offset] eq "" && $base ne ""} {
                lappend fb [list probe-rejected "the compiler gave no offset of member [dict get $m path]"]
                dict set f kind blocked
            }
        }
        # A union's members are its alternatives: each begins where the
        # union does, by the compiler's own offsets -- never assumed.
        if {[dict get $rec kind] eq "union" && [dict get $f offset] ne "" && [dict get $f offset] != 0} {
            lappend fb [list union-member-offset "the compiler places this member of a union at offset [dict get $f offset]: a union layout's alternatives all begin at its start"]
        }
        if {$fb ne ""} { dict set f kind blocked }
        lassign [ArrayOf [dict get $m ctype]] bounds elem
        if {[llength $bounds] && [dict get $m bits] eq ""} {
            dict set f array [dict create category [ElementCategory $elem [FieldType $elem]] \
                element [::cir::spell $elem] bounds [lmap b $bounds {::cir::BoundText $b}]]
        }
        dict set f blockers $fb
        foreach b $fb {
            set where [expr {[dict get $m cname] eq "" ? [dict get $m slot] : "field [dict get $m cname]"}]
            lappend direct [list [lindex $b 0] "$where: [lindex $b 1]"]
        }
        lappend fields $f
        incr i
    }
    if {![llength $fields]} { lappend direct [list empty-record "no members"] }
    # Nothing places an anonymous member none of whose members has an
    # offset: a blocker of its own only when nothing else blocks it (a
    # bitfield, which has no offsetof, is the root reason then).
    if {$unanchored && ![llength $direct]} {
        lappend direct [list anonymous-record "an anonymous member of [dict get $rec owner] none of whose members has an offset the compiler gave: nothing places it there"]
    }
    dict set rec fields $fields
    dict set rec direct $direct
    dict set rec deps $deps
    dict set rec hasPromoted $promoted
    return $rec
}

# The synthetic record member M (Members') is, or "": an anonymous struct or
# union member that is no promoted struct.
proc ::cbind::records::AnonymousMember {recs m} {
    if {[dict get $m cname] ne "" || [dict get $m bits] ne ""} { return "" }
    set t [::cir::unq [dict get $m ctype]]
    if {[lindex $t 0] ni {struct union} || ![string match anon@* [lindex $t 1]]} { return "" }
    set k "[lindex $t 0] [lindex $t 1]"
    if {![dict exists $recs $k] || ![Synthetic $recs $k]} { return "" }
    return $k
}

# Clang's record layout of synthetic record KEY (probe.tcl's anonymous): {BLOCK
# ""} or {"" WHY}. It is the anonymous record of KEY's kind clang locates in
# the parser's file at the parser's line -- or up to eight lines above it:
# the parser tags the brace, clang the struct or union keyword -- whose own
# members are KEY's, by name, in order (an unnamed one by its place);
# several are taken only when they are the same layout.
proc ::cbind::records::Block {recs key} {
    variable facts
    variable blockOf
    variable blockIndex
    if {[dict exists $blockOf $key]} { return [dict get $blockOf $key] }
    set rec [dict get $recs $key]
    if {![dict exists $facts anon:layouts]} {
        set result [list "" "no record layout was asked of the compiler"]
    } elseif {[lindex [dict get $facts anon:layouts] 0] ne "ok"} {
        set result [list "" [lindex [dict get $facts anon:layouts] 1]]
    } elseif {![regexp {^anon@(.*):([0-9]+)(?:#[0-9]+)?$} [dict get $rec tag] -> file line]} {
        set result [list "" "it has no location ([dict get $rec tag])"]
    } else {
        if {![info exists blockIndex]} {
            set blockIndex [dict create]
            foreach b [lindex [dict get $facts anon:layouts] 1] {
                dict lappend blockIndex [list [dict get $b kind] [dict get $b file] [dict get $b line]] $b
            }
        }
        set names [lmap f [dict get $rec fieldsC] {lindex $f 0}]
        set found {}
        for {set at [expr {$line - 8}]} {$at <= $line} {incr at} {
            set k [list [dict get $rec kind] $file $at]
            if {![dict exists $blockIndex $k]} continue
            foreach b [dict get $blockIndex $k] {
                if {[lmap m [dict get $b members] {lindex $m 0}] ne $names} continue
                lappend found $b
            }
        }
        set shapes [lsort -unique [lmap b $found {list [dict get $b size] [dict get $b align] [dict get $b leaves] \
            [lmap m [dict get $b members] {lindex $m 1}]}]]
        if {![llength $found]} {
            set result [list "" "none is an anonymous [dict get $rec kind] of these members at $file:$line"]
        } elseif {[llength $shapes] > 1} {
            set result [list "" "several different anonymous [dict get $rec kind]s of these members are at $file:$line"]
        } else {
            set result [list [lindex $found 0] ""]
        }
    }
    dict set blockOf $key $result
    return $result
}

# The offset of synthetic record KEY in its owner (Owner), "" when nothing
# places it: the compiler's offsetof of a member it names, through the
# owner, less that member's offset in KEY by clang's record layout; for a
# record whose members are all anonymous, an anonymous member's offset less
# its offset in KEY. 0 for a record that is no synthetic one.
proc ::cbind::records::Base {recs key} {
    variable facts
    variable bases
    if {![Synthetic $recs $key]} { return 0 }
    if {[dict exists $bases $key]} { return [dict get $bases $key] }
    dict set bases $key ""
    lassign [Block $recs $key] block
    set base ""
    if {$block ne ""} {
        set members [Members $recs [dict get $recs $key]]
        set i 0
        foreach m $members {
            set name [dict get $m cname]
            if {$name ne "" && [dict get $m bits] eq "" && [dict exists $block leaves $name]
                    && [dict exists $facts fld:$key:$i] && [lindex [dict get $facts fld:$key:$i] 0] eq "ok"} {
                set base [expr {[lindex [dict get $facts fld:$key:$i] 1 0] - [dict get $block leaves $name]}]
                break
            }
            incr i
        }
        if {$base eq ""} {
            foreach m $members {
                set anon [AnonymousMember $recs $m]
                if {$anon eq ""} continue
                set inner [Base $recs $anon]
                lassign [Block $recs $anon] ib
                if {$inner eq "" || $ib eq ""} continue
                set at "[dict get $ib file]:[dict get $ib line]:[dict get $ib col]"
                if {[dict exists $block nested $at]} {
                    set base [expr {$inner - [dict get $block nested $at]}]
                    break
                }
            }
        }
    }
    dict set bases $key $base
    return $base
}

# The mapping of member I of record KEY (the field F so far), a fixed array
# of DEPTH dimensions of ELEMENT ({KIND TEXT}, FieldType's): {ok array
# EXTENTS ELEMENT}, EXTENTS each dimension's element count as the layout
# probe gives it (dims:KEY:I), or {no} with the blocker appended to FBVAR.
# The probe's innermost element size must be the element's width (a scalar's
# on the target, a pointer's, the nested record's sizeof) and the extents'
# product times it the member's sizeof: arrays add no layout rule, and a
# disagreement is a blocker, never a guess. A nested element is a by-value
# dependency (DEPSVAR). (A synthetic record's array members are probed
# through its owner, like its other members.)
proc ::cbind::records::ArrayField {recs key i f mapped fbVar depsVar} {
    variable facts
    upvar 1 $fbVar fb $depsVar deps
    lassign $mapped depth element
    lassign $element kind text
    if {![dict exists $facts dims:$key:$i] || [lindex [dict get $facts dims:$key:$i] 0] ne "ok"
            || [llength [lindex [dict get $facts dims:$key:$i] 1]] != $depth + 1} {
        lappend fb [list probe-rejected "the compiler gave no extents of array member [dict get $f path]"]
        return no
    }
    set answers [lindex [dict get $facts dims:$key:$i] 1]
    set extents [lrange $answers 0 end-1]
    set elementSize [lindex $answers end]
    set width ""
    switch -- $kind {
        scalar {
            if {[regexp {^std::ffi::c::([A-Za-z]+)$} $text -> scalar]} {
                set width [::cbind::records::ScalarWidth $scalar]
            }
        }
        pointer {
            set width [expr {[dict get [core::cabi::target $::cbind::model::target] pointer] / 8}]
        }
        nested {
            if {![dict exists $recs $text]} {
                lappend fb [list unsupported-field-type "an array of $text by value, a record of no candidate definition"]
                return no
            }
            lappend deps [list $text array-element]
            if {[dict exists $facts rec:$text] && [lindex [dict get $facts rec:$text] 0] eq "ok"} {
                set width [lindex [dict get $facts rec:$text] 1 0]
            }
        }
    }
    set product 1
    foreach n $extents {
        if {![string is entier -strict $n] || $n < 1} {
            lappend fb [list flexible-array "array member [dict get $f path] has a dimension of $n elements"]
            return no
        }
        set product [expr {$product * $n}]
    }
    if {$width ne "" && ($elementSize != $width || ([dict get $f size] ne "" && $product * $width != [dict get $f size]))} {
        lappend fb [list probe-rejected "the compiler's extents of array member [dict get $f path] ([join $extents x] of $elementSize bytes, [dict get $f size] in all) disagree with its element's width $width"]
        return no
    }
    return [list ok array $extents $element]
}

# The Botlish type text of the representable field F of a record of RECS
# (named): a scalar's or a pointer's type (identity keys still marked, as
# the binding model writes them), a nested record's layout name, a fixed
# array's `array N of ...` down to its element's.
proc ::cbind::records::FieldText {recs f} {
    switch -- [dict get $f kind] {
        nested { return [dict get $recs [dict get $f type] layoutName] }
        array {
            lassign [dict get $f element] kind text
            set element [expr {$kind eq "nested" ? [dict get $recs $text layoutName] : $text}]
            return "[join [lmap n [dict get $f type] {string cat "array $n of "}] {}]$element"
        }
    }
    return [dict get $f type]
}

# 1 if the layout probe says member I of record KEY has the plain type of
# its declaration, its explicit conventions dropped (ccfld:KEY:I).
proc ::cbind::records::FieldConvention {key i} {
    variable facts
    if {![dict exists $facts ccfld:$key:$i]} { return 0 }
    lassign [dict get $facts ccfld:$key:$i] st data
    return [expr {$st eq "ok" && [lindex $data 0] == 1}]
}

# The records STARTS and every record they hold by value, in dependency
# order: each after every record it holds by value, STARTS' order otherwise
# (a depth-first walk with its own stack: no depth limits it). A by-value
# cycle -- no C has one, but the parser's records might say so -- is noted on
# the record whose dependency closes it (`cycle`), and the walk goes on.
proc ::cbind::records::Order {recsVar starts} {
    upvar 1 $recsVar recs
    set state [dict create]
    set order {}
    foreach key $starts {
        if {[dict exists $state $key]} continue
        dict set state $key visiting
        set stack [list [list $key 0]]
        while {[llength $stack]} {
            lassign [lindex $stack end] k i
            set deps [dict get $recs $k deps]
            if {$i < [llength $deps]} {
                lset stack end 1 [expr {$i + 1}]
                set d [lindex $deps $i 0]
                if {![dict exists $state $d]} {
                    dict set state $d visiting
                    lappend stack [list $d 0]
                } elseif {[dict get $state $d] eq "visiting"} {
                    set path [lmap e $stack {lindex $e 0}]
                    dict set recs $k cycle [concat [lrange $path [lsearch -exact $path $d] end] [list $d]]
                }
                continue
            }
            set stack [lrange $stack 0 end-1]
            dict set state $k done
            lappend order $k
        }
    }
    return $order
}

# Decides record KEY's status after its dependencies' (Order): `status`,
# `transitive` (a nested-layout-blocked blocker per blocked record it holds,
# with the chain to that record's first direct blocker), `chain` (its own:
# the records down to its first direct blocker, then that reason) and
# `roots` (every direct reason it waits for, itself and through what it
# holds: the pressure analysis's).
proc ::cbind::records::Settle {key recsVar} {
    upvar 1 $recsVar recs
    set rec [dict get $recs $key]
    if {[dict exists $rec status] && [dict get $rec status] in {opaque-only promoted}} {
        dict set recs $key transitive {}
        dict set recs $key chain {}
        dict set recs $key roots {}
        return
    }
    if {[dict exists $rec cycle]} {
        dict lappend rec direct [list layout-cycle "a by-value cycle: [join [dict get $rec cycle] { -> }]"]
        dict set recs $key direct [dict get $rec direct]
    }
    set transitive {}
    set roots [lmap b [dict get $rec direct] {lindex $b 0}]
    foreach d [dict get $rec deps] {
        lassign $d dep relation
        # A dependency not decided yet closes a cycle (reported above).
        if {![dict exists $recs $dep roots]} continue
        if {[dict get $recs $dep status] ne "layout-direct"} {
            set where [FieldOfDep $rec $dep]
            lappend transitive [list nested-layout-blocked "$where ($dep, $relation) -> [ChainText [dict get $recs $dep chain]]" $dep]
            lappend roots {*}[dict get $recs $dep roots]
        }
    }
    set direct [dict get $recs $key direct]
    if {[llength $direct]} {
        set chain [list [lindex $direct 0 0]]
    } elseif {[llength $transitive]} {
        set first [lindex $transitive 0 2]
        set chain [concat [list $first] [dict get $recs $first chain]]
    } else {
        set chain {}
    }
    dict set recs $key status [expr {[llength $direct] || [llength $transitive] ? "layout-blocked" : "layout-direct"}]
    dict set recs $key transitive $transitive
    dict set recs $key chain $chain
    dict set recs $key roots [lsort -unique $roots]
}

# A chain (Settle's) as text: "fixed-array", "struct B -> fixed-array"; one
# longer than sixteen records shows its first and last ones.
proc ::cbind::records::ChainText {chain} {
    if {[llength $chain] > 17} {
        set chain [concat [lrange $chain 0 7] [list "... [expr {[llength $chain] - 12} ] more ..."] [lrange $chain end-3 end]]
    }
    return [join $chain " -> "]
}

# The member of REC whose type contains record DEP.
proc ::cbind::records::FieldOfDep {rec dep} {
    foreach f [dict get $rec fields] {
        set t [::cir::unq [::cir::final $::cbind::model::ix [dict get $f ctype]]]
        while {[lindex $t 0] eq "array"} { set t [::cir::unq [::cir::final $::cbind::model::ix [lindex $t 1]]] }
        if {"[lindex $t 0] [lindex $t 1]" eq $dep} {
            return [expr {[dict get $f cname] eq "" ? [dict get $f slot] : "field [dict get $f cname]"}]
        }
    }
    return "a member"
}

# Every direct blocker reason the blocked record KEY waits for, itself and
# through what it contains by value (the pressure analysis's roots: Settle
# computed them).
proc ::cbind::records::RootReasons {recs key} {
    return [dict get $recs $key roots]
}

# RECS with every record's names: `layoutName` (the Botlish name of its
# layout, unique in the layouts module), and `fields`' Botlish `name`s.
#
# A layout is named by the first typedef naming its tag directly, else by
# its tag, else (an anonymous record of a named member) by its container's
# name and the member's, else (an anonymous member, a synthetic record) by
# its container's name and its place there (OVERLAPPED_member3: the
# generated field holding it is member3); a C name Botlish reserves (a
# keyword, a built-in type) gets a trailing _. A field is named by its C
# member, an unnamed one by its place (Members' slot). Two records one name
# would give get it in a fixed preference -- named by a typedef of that
# name, then a tag of that name, then synthesized; then by key -- and the
# others a _struct or _union suffix (then _2, _3, ...): the names depend on
# the records, never on the order anything was discovered or probed in.
proc ::cbind::records::Name {recs} {
    set base [dict create]
    dict for {key rec} $recs {
        dict set base $key [BaseName $recs $key]
    }
    set groups [dict create]
    dict for {key b} $base {
        lassign $b name rank
        dict lappend groups [TypeIdent $name] [list $rank $key]
    }
    set taken [dict create]
    set final [dict create]
    foreach name [lsort [dict keys $groups]] {
        set members [lsort -integer -index 0 [lsort -index 1 [dict get $groups $name]]]
        set first 1
        foreach m $members {
            set key [lindex $m 1]
            if {$first && ![dict exists $taken $name]} {
                set n $name
            } else {
                set n ${name}_[lindex $key 0]
                set k 2
                while {[dict exists $taken $n] || [dict exists $groups $n]} { set n ${name}_[lindex $key 0]_$k; incr k }
            }
            set first 0
            dict set taken $n 1
            dict set final $key $n
        }
    }
    dict for {key rec} $recs {
        dict set recs $key layoutName [dict get $final $key]
        set names {}
        set fields {}
        foreach f [dict get $rec fields] {
            # (Never expr's ?:, which would read a member named inf or nan
            # as a number.)
            set n [if {[dict get $f cname] eq ""} {dict get $f slot} else {::cbind::model::Ident [dict get $f cname]}]
            while {$n in $names} { append n _ }
            lappend names $n
            dict set f name $n
            lappend fields $f
        }
        dict set recs $key fields $fields
    }
    return $recs
}

# {NAME RANK} of record KEY before collisions: RANK 0 a typedef naming it
# directly, 1 its tag, 2 synthesized from its container.
proc ::cbind::records::BaseName {recs key} {
    set rec [dict get $recs $key]
    set direct [DirectTypedef $key]
    if {$direct ne ""} { return [list $direct 0] }
    if {![dict get $rec anonymous]} { return [list [dict get $rec tag] 1] }
    if {[dict exists $rec user] && [dict get $rec user field] ne ""} {
        set u [dict get $rec user]
        set container [lindex [BaseName $recs [Owner $recs [dict get $u container]]] 0]
        return [list ${container}_[dict get $u field] 2]
    }
    if {[dict exists $rec user]} {
        set u [dict get $rec user]
        set container [lindex [BaseName $recs [dict get $u container]] 0]
        return [list ${container}_member[expr {[dict get $u index] + 1}] 2]
    }
    return [list anon_[regsub -all {[^A-Za-z0-9]} [string range [dict get $rec tag] 5 end] _] 2]
}

# NAME as a Botlish type name: itself unless a keyword or a type name the
# compiler reserves (Int, List, str, ...), then NAME_.
proc ::cbind::records::TypeIdent {name} {
    set id [::cbind::model::Ident $name]
    while {[ReservedType $id]} { append id _ }
    return $id
}

# 1 if the compiler reserves NAME as a type name (a built-in type or type
# constructor), so that no declaration may take it: the compiler's own
# answer (hir/layouts.tcl's rule for a layout's name), never a list here.
proc ::cbind::records::ReservedType {name} {
    return [expr {[::hir::layouts::OtherDeclaration $name $name] eq "a built-in type"}]
}
