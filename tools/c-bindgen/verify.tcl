# verify.tcl -- the C compiler's check of the generated layouts
# (C-BINDGEN-LAYOUTS.md, "Verification").
#
#   ::cbind::verify::source FILES PROFILE TARGET UNDEFS
#
# The text of layouts-check.c: one C translation unit, including the
# profile's entry headers with its defines, of compile-time assertions about
# every layout the generated layouts module declares. The numbers it asserts
# are read back from the generated Botlish text (NS/layouts.bot), never from
# the generator's model, so a layout the emitter or the manifest corrupted
# is caught by the compiler; only the C names (which C type a layout
# describes, which C member a field is) come from the layout manifest
# (layouts.tsv). For every layout:
#
#   sizeof(T) and _Alignof(T) are the layout's size and align;
#   for every field: __builtin_offsetof(T, member) is its offset;
#     a scalar field of ffi::c::X: the member is of integer class
#       (__builtin_classify_type 1), of X's width and signedness on the
#       target (core/cabi.tcl's table), and no _Bool ((T)2 == 2);
#     a C floating field, ffi::c::Float or ffi::c::Double (C-FLOAT-FFI-
#       MILESTONE-1.md): of real floating class (8), of the C type's width
#       on the target, and exactly that C type
#       (__builtin_types_compatible_p with float or double: never long
#       double or an extended type of the same width);
#     a pointer field: of pointer class (5) and the target's pointer width;
#     a nested layout: of record class (12 a struct, 13 a union: the
#       nested layout's own kind) and that layout's size;
#     a fixed array (array N of E, FIXED-LAYOUT-ARRAYS.md): an array type at
#       every dimension (never a pointer: __builtin_types_compatible_p of the
#       member and its first element's address is 0) of exactly its extent
#       (sizeof m / sizeof m[0]), its first element m[0]...[0] checked as a
#       field of type E at the array's offset, and its last element at the
#       offset plus the array's width less one element's (the stride).
#
# A union layout (LAYOUT-UNIONS.md) is checked the same way, every one of
# its alternatives a field at offset 0: sizeof and _Alignof of the C union,
# and for each alternative, the last and the smallest as much as the first,
# offsetof 0 and its width, class and signedness. A synthetic layout (an
# anonymous member, records.tcl: a layout with no C name in the manifest)
# has no C type to name: it is checked through the record that holds it,
# whose C members its own members are (C11's promoted names). Every member
# of it is checked as a field of that record, at the offset the generated
# text gives it there -- the holding field's offset plus its own, through
# any number of anonymous members -- and the anonymous member is held to
# lie inside that record (its offset plus its size at most sizeof).
#
# A layout the compiler disagrees with does not compile: the message names
# the layout and the field.

namespace eval ::cbind::verify {}

# The layouts of the Botlish text TEXT: a list of {NAME SIZE ALIGN FIELDS
# UNION}, FIELDS {{NAME TYPE OFFSET} ...} in declaration order (a union
# layout's alternatives, each at offset 0), UNION 1 for a union layout.
proc ::cbind::verify::ParseLayouts {text} {
    set out {}
    set current ""
    foreach line [split $text \n] {
        if {[regexp {^(union )?layout ([A-Za-z_][A-Za-z0-9_]*):\s*$} $line -> union name]} {
            if {$current ne ""} { lappend out $current }
            set current [list $name "" "" {} [expr {$union ne ""}]]
        } elseif {$current ne "" && [regexp {^    size ([0-9]+)\s*$} $line -> n]} {
            lset current 1 $n
        } elseif {$current ne "" && [regexp {^    align ([0-9]+)\s*$} $line -> n]} {
            lset current 2 $n
        } elseif {$current ne "" && ![lindex $current 4]
                && [regexp {^    field ([A-Za-z_][A-Za-z0-9_]*): (.*) at ([0-9]+)\s*(?:#.*)?$} $line -> f type offset]} {
            set fields [lindex $current 3]
            lappend fields [list $f [string trim $type] $offset]
            lset current 3 $fields
        } elseif {$current ne "" && [lindex $current 4]
                && [regexp {^    alternative ([A-Za-z_][A-Za-z0-9_]*): ([^#]*[^#\s])\s*(?:#.*)?$} $line -> f type]} {
            set fields [lindex $current 3]
            lappend fields [list $f [string trim $type] 0]
            lset current 3 $fields
        } elseif {[regexp {^\S} $line] && $current ne ""} {
            lappend out $current
            set current ""
        }
    }
    if {$current ne ""} { lappend out $current }
    return $out
}

# The C names of the layout manifest TSV: {RECORDS MEMBERS}, RECORDS
# layout name -> C type ("-" for a synthetic layout: an anonymous member),
# MEMBERS {layout name, field name} -> C member ("-" for an unnamed one).
proc ::cbind::verify::CNames {tsv} {
    set records [dict create]
    set byKey [dict create]
    set members [dict create]
    foreach line [split $tsv \n] {
        set row [split $line \t]
        if {[lindex $row 0] eq "record" && [lindex $row 3] ne "-"} {
            dict set records [lindex $row 3] [lindex $row 8]
            dict set byKey [lindex $row 1] [lindex $row 3]
        }
    }
    foreach line [split $tsv \n] {
        set row [split $line \t]
        if {[lindex $row 0] ne "field" || ![dict exists $byKey [lindex $row 1]]} continue
        if {[regexp {(?:^|; )c=([^;]*)} [lindex $row 10] -> c]} {
            dict set members [list [dict get $byKey [lindex $row 1]] [lindex $row 3]] $c
        }
    }
    return [list $records $members]
}

# The text of layouts-check.c for the generated FILES of PROFILE on TARGET
# ("" when they declare no layout). UNDEFS: the macros to #undef after the
# headers (records.tcl's probeEntries: the record and member names are the
# preprocessed declarations' tokens).
proc ::cbind::verify::source {files profile target undefs} {
    set ns [dict get $profile name]
    if {![dict exists $files $ns/layouts.bot]} { return "" }
    set layouts [ParseLayouts [dict get $files $ns/layouts.bot]]
    lassign [CNames [dict get $files layouts.tsv]] records members
    set t [core::cabi::target $target]
    set pointerBytes [expr {[dict get $t pointer] / 8}]
    set sizes [dict create]
    set byName [dict create]
    foreach l $layouts {
        dict set sizes [lindex $l 0] [lindex $l 1]
        dict set byName [lindex $l 0] $l
    }
    set h [::cbind::profile::headersFor $profile $target]
    set text "/* GENERATED by tools/c-bindgen.tcl (profile $ns, target $target): do not edit.\n"
    append text " * The C compiler's check of ${ns}::layouts (C-BINDGEN-LAYOUTS.md, \"Verification\"):\n"
    append text " * every number below is read back from the generated layouts.bot, and a\n"
    append text " * layout whose size, alignment, an offset or a field's width, class or\n"
    append text " * signedness differs from this target's C compiler does not compile. */\n"
    foreach d [dict get $h defines] {
        if {[regexp {^([^=]+)=(.*)$} $d -> n v]} {
            append text "#ifndef $n\n#define $n $v\n#endif\n"
        } else {
            append text "#ifndef $d\n#define $d 1\n#endif\n"
        }
    }
    foreach e [dict get $h entry] { append text "#include <$e>\n" }
    foreach u $undefs { append text "#undef $u\n" }
    append text [join {
        "#define BOTLISH_M(T, m) (((T *)0)->m)"
        "#define BOTLISH_RECORD(T, size, align, L) \\"
        "    _Static_assert(sizeof(T) == (size), L \": sizeof\"); \\"
        "    _Static_assert(_Alignof(T) == (align), L \": _Alignof\")"
        "#define BOTLISH_OFFSET(T, m, offset, L) \\"
        "    _Static_assert(__builtin_offsetof(T, m) == (offset), L \": offset\")"
        "#define BOTLISH_SCALAR(T, m, offset, width, sign, L) \\"
        "    BOTLISH_OFFSET(T, m, offset, L); \\"
        "    _Static_assert(__builtin_classify_type(BOTLISH_M(T, m)) == 1, L \": an integer\"); \\"
        "    _Static_assert(sizeof(BOTLISH_M(T, m)) == (width), L \": width\"); \\"
        "    _Static_assert((((__typeof__(BOTLISH_M(T, m)))-1) < 0) == (sign), L \": signedness\"); \\"
        "    _Static_assert((__typeof__(BOTLISH_M(T, m)))2 == 2, L \": no _Bool\")"
        "#define BOTLISH_FLOATING(T, m, offset, width, ctype, L) \\"
        "    BOTLISH_OFFSET(T, m, offset, L); \\"
        "    _Static_assert(__builtin_classify_type(BOTLISH_M(T, m)) == 8, L \": a floating type\"); \\"
        "    _Static_assert(sizeof(BOTLISH_M(T, m)) == (width), L \": width\"); \\"
        "    _Static_assert(__builtin_types_compatible_p(__typeof__(BOTLISH_M(T, m)), ctype), L \": the C type\")"
        "#define BOTLISH_POINTER(T, m, offset, width, L) \\"
        "    BOTLISH_OFFSET(T, m, offset, L); \\"
        "    _Static_assert(__builtin_classify_type(BOTLISH_M(T, m)) == 5, L \": a pointer\"); \\"
        "    _Static_assert(sizeof(BOTLISH_M(T, m)) == (width), L \": pointer width\")"
        "#define BOTLISH_NESTED(T, m, offset, size, L) \\"
        "    BOTLISH_OFFSET(T, m, offset, L); \\"
        "    _Static_assert(__builtin_classify_type(BOTLISH_M(T, m)) == 12, L \": a struct\"); \\"
        "    _Static_assert(sizeof(BOTLISH_M(T, m)) == (size), L \": the nested layout's size\")"
        "#define BOTLISH_NESTED_UNION(T, m, offset, size, L) \\"
        "    BOTLISH_OFFSET(T, m, offset, L); \\"
        "    _Static_assert(__builtin_classify_type(BOTLISH_M(T, m)) == 13, L \": a union\"); \\"
        "    _Static_assert(sizeof(BOTLISH_M(T, m)) == (size), L \": the nested layout's size\")"
        "#define BOTLISH_INSIDE(T, offset, size, L) \\"
        "    _Static_assert((offset) + (size) <= sizeof(T), L \": inside its record\")"
        "#define BOTLISH_ARRAY(T, m, n, L) \\"
        "    _Static_assert(!__builtin_types_compatible_p(__typeof__(BOTLISH_M(T, m)), __typeof__(&BOTLISH_M(T, m)\[0\])), L \": an array\"); \\"
        "    _Static_assert(sizeof(BOTLISH_M(T, m)) / sizeof(BOTLISH_M(T, m)\[0\]) == (n), L \": extent\")"
    } \n]\n
    foreach l $layouts {
        lassign $l name size align fields
        if {![dict exists $records $name]} {
            error "c-bindgen verify: layout $name is not in the layout manifest"
        }
        set c [dict get $records $name]
        # A synthetic layout is checked through the layouts holding it.
        if {$c eq "-"} continue
        append text "\nBOTLISH_RECORD($c, $size, $align, \"$name\");\n"
        append text [Fields $c $name 0 $byName $records $members $sizes $target $pointerBytes]
    }
    return $text
}

# The checks of the fields of layout NAME as members of the C record C (its
# own C type, or for a synthetic layout the record holding it), NAME at
# offset BASE in C.
proc ::cbind::verify::Fields {c name base byName records members sizes target pointerBytes} {
    set text ""
    foreach f [lindex [dict get $byName $name] 3] {
        lassign $f fname type offset
        set offset [expr {$base + $offset}]
        if {![dict exists $members [list $name $fname]]} {
            error "c-bindgen verify: field $name.$fname is not in the layout manifest"
        }
        set m [dict get $members [list $name $fname]]
        set label "\"$name.$fname\""
        if {$m eq "-"} {
            # An anonymous member: a synthetic layout whose members are C's
            # members of C, at this field's offset.
            if {![dict exists $records $type] || [dict get $records $type] ne "-"} {
                error "c-bindgen verify: field $name.$fname has no C member and no synthetic layout"
            }
            append text "BOTLISH_INSIDE($c, $offset, [dict get $sizes $type], $label);\n"
            append text [Fields $c $type $offset $byName $records $members $sizes $target $pointerBytes]
            continue
        }
        # A fixed array: every dimension, then its first and last
        # elements; the element itself is checked below as a field.
        set extents {}
        while {[regexp {^array ([0-9]+) of (.*)$} $type -> n inner]} {
            lappend extents $n
            set type $inner
        }
        if {[llength $extents]} {
            set path $m
            set last $m
            set count 1
            foreach n $extents {
                append text "BOTLISH_ARRAY($c, $path, $n, $label);\n"
                append path "\[0\]"
                append last "\[[expr {$n - 1}]\]"
                set count [expr {$count * $n}]
            }
            if {[regexp {^ffi::c::(Ptr|FnPtr)\[} $type]} {
                set width $pointerBytes
            } elseif {[regexp {^ffi::c::([A-Za-z]+)$} $type -> scalar] && [core::cabi::isFloating $scalar]} {
                set width [dict get [core::cabi::floatingInfo $scalar $target] bytes]
            } elseif {[regexp {^ffi::c::([A-Za-z]+)$} $type -> scalar]} {
                set width [expr {[dict get [core::cabi::scalarInfo $scalar $target] bits] / 8}]
            } elseif {[dict exists $sizes $type]} {
                set width [dict get $sizes $type]
            } else {
                error "c-bindgen verify: field $name.$fname has an element type no check knows: $type"
            }
            append text "BOTLISH_OFFSET($c, $last, [expr {$offset + ($count - 1) * $width}], \"$name.$fname, its last element\");\n"
            set m $path
            set label "\"$name.$fname, its first element\""
        }
        if {[regexp {^ffi::c::(Ptr|FnPtr)\[} $type]} {
            append text "BOTLISH_POINTER($c, $m, $offset, $pointerBytes, $label);\n"
        } elseif {[regexp {^ffi::c::([A-Za-z]+)$} $type -> scalar] && [core::cabi::isFloating $scalar]} {
            set info [core::cabi::floatingInfo $scalar $target]
            append text "BOTLISH_FLOATING($c, $m, $offset, [dict get $info bytes], [dict get $info c], $label);\n"
        } elseif {[regexp {^ffi::c::([A-Za-z]+)$} $type -> scalar]} {
            set info [core::cabi::scalarInfo $scalar $target]
            append text "BOTLISH_SCALAR($c, $m, $offset, [expr {[dict get $info bits] / 8}], [dict get $info signed], $label);\n"
        } elseif {[dict exists $sizes $type]} {
            set check [expr {[lindex [dict get $byName $type] 4] ? "BOTLISH_NESTED_UNION" : "BOTLISH_NESTED"}]
            append text "$check\($c, $m, $offset, [dict get $sizes $type], $label);\n"
        } else {
            error "c-bindgen verify: field $name.$fname has a type no check knows: $type"
        }
    }
    return $text
}

# The disagreements of the synthetic layouts of the generated FILES (an
# anonymous member's: no C type names it, so layouts-check.c holds it only
# to lie inside its record) with clang's record layouts of the anonymous
# members, which compiling layouts-check.c computes: for each, the size and
# the alignment the generated text states against those of the anonymous
# record clang locates where the manifest says it is (at=). CONFIG and TOOL
# are the target's toolchain and header profile; a toolchain that dumps no
# record layout checks nothing here (and generated none).
proc ::cbind::verify::anonymous {files ns config tool} {
    if {![dict exists $files layouts-check.c] || ![dict exists $files $ns/layouts.bot]} { return {} }
    set at [dict create]
    foreach line [split [dict get $files layouts.tsv] \n] {
        set row [split $line \t]
        if {[lindex $row 0] eq "record" && [lindex $row 3] ne "-" && [lindex $row 8] eq "-"
                && [regexp {(?:^|; )at=([^;]*)} [lindex $row 10] -> where]} {
            dict set at [lindex $row 3] $where
        }
    }
    if {![dict size $at]} { return {} }
    lassign [::chdr::toolchain::recordLayouts $config $tool [dict get $files layouts-check.c]] ok text stderr
    if {!$ok} { return [list "clang's record layouts of layouts-check.c: [string range $stderr 0 2000]"] }
    set blocks [dict create]
    foreach b [::cbind::probe::ParseLayouts $text] {
        dict set blocks "[dict get $b file]:[dict get $b line]:[dict get $b col]" $b
    }
    set problems {}
    foreach l [ParseLayouts [dict get $files $ns/layouts.bot]] {
        lassign $l name size align
        if {![dict exists $at $name]} continue
        set where [dict get $at $name]
        if {![dict exists $blocks $where]} {
            lappend problems "$name: clang lays out no anonymous member at $where"
            continue
        }
        set b [dict get $blocks $where]
        if {$size != [dict get $b size] || $align != [dict get $b align]} {
            lappend problems "$name: size $size, align $align; clang's record layout of the anonymous member at $where: sizeof [dict get $b size], align [dict get $b align]"
        }
    }
    return $problems
}
