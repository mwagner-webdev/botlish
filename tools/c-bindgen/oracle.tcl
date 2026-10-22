# oracle.tcl -- the runtime C oracle of generated layouts
# (C-BINDGEN-LAYOUTS.md, "Verification"). Test tooling: tests/c-bindgen.test
# and audit/c-bindgen/tools/fuzz.tcl source it; the generator never does.
#
#   ::cbind::oracle::build NS DIR LAYOUTS ?SEED?
#
# For layouts LAYOUTS of the generated binding NS in DIR (its NS/layouts.bot
# and layouts.tsv, as generation wrote them), the text of
#
#   oracle.c       C: for each layout's C record, functions that fill a
#                  record with 0xA5 and then write every leaf field with a
#                  value of its own C type at its own C address (init: a
#                  member C declares const is written so too), check every leaf and every padding
#                  byte of a record Botlish wrote in place (check_edit), check
#                  a byte image Botlish built in byte storage (check_bytes),
#                  hand out and compare pointer values (anchor, is), and
#                  answer sizeof and _Alignof;
#   orc.bot        the Botlish declarations of those functions (an ordinary
#                  module beside the program);
#   main.bot       a Botlish program that, for every layout, compares
#                  std::binary::layout_length and std::binary::layout_alignment with
#                  C's sizeof and _Alignof, reads every leaf of the record C
#                  initialized through std::binary::native::view, writes every
#                  leaf through std::binary::native::edit (std::binary::store) and has C
#                  check them and the padding, builds the record in
#                  std::abi::bytes::MutableBytes with std::binary::write and
#                  std::binary::write_foreign and has C check that image (and, for
#                  a layout without pointers, std::binary::parse reads it back);
#
# and the value the program must produce: a list per layout of zeros (each
# check returns 0 when C and Botlish agree, a nonzero code otherwise), with
# the label of every check for a failure's message. Every C access is a C
# member access of the record's C type with a C designator from the layout
# manifest; every number on the Botlish side is the generated layout's;
# the values are deterministic bit patterns per field (boundary values on
# every fourth), each phase its own.
#
# A union (LAYOUT-UNIONS.md) is several interpretations of the same bytes,
# so no phase writes all of its leaves: each phase selects one alternative
# of every union it reaches (a different one in each phase, where there are
# several) and writes the leaves of the selection only. Botlish reads every
# leaf: a selected one against the value C stored, any other -- another
# interpretation of the same bytes -- against C's own reading of its bytes
# (memcpy from the member's address into a value of its type: the physical
# model, not C's union punning), except a pointer or a C float or double
# (C-FLOAT-FFI-MILESTONE-1.md), which arbitrary bits need not be (a NaN is
# no Float64). C checks an edited record and a built image against an image
# of its own (0xA5, or 0, then every written leaf's bytes copied in at its
# offsetof), byte by byte, and every written leaf with a typed read: a
# write that strays outside its alternative, or loses one written earlier
# that it does not overlap, is caught. A layout holding a union has no
# whole copy (std::binary::parse refuses it): its selected scalar leaves are
# read back from the bytes with std::binary::read instead.

namespace eval ::cbind::oracle {}

# The leaves of layout NAME of LAYOUTS (name -> {size align fields union})
# with MEMBERS ({layout field} -> C member): {{BOTPATH CPATH TYPE READ PARSE
# CHOICES} ...}, nested layouts flattened (a.b, a.b), fixed arrays element
# by element (FIXED-LAYOUT-ARRAYS.md): BOTPATH a static designator
# (a.items[2].x), CPATH the C designator (an anonymous member's members are
# its record's: C11), READ the Botlish expression reading the leaf through
# the view `v` (std::binary::element(v.a.items, 2).x), PARSE the one reading it
# from the LayoutStruct `s` (std::list::at(s.a.items, 2).x) and CHOICES the
# alternatives it lies in: {UNION K N} each, the K-th of the N alternatives
# of the union at UNION (its BOTPATH: one occurrence of a union). An array
# of more than four elements in a dimension is sampled there -- its first
# two, its middle and its last -- and every element left out is a byte no
# check covers: C checks it untouched.
proc ::cbind::oracle::Leaves {layouts members name {bot ""} {c ""} {read v} {parse s} {choices {}}} {
    set out {}
    set alternatives [lindex [dict get $layouts $name] 2]
    set union [lindex [dict get $layouts $name] 3]
    set k 0
    foreach f $alternatives {
        lassign $f fname type offset
        set cm [dict get $members [list $name $fname]]
        set bp [expr {$bot eq "" ? $fname : "$bot.$fname"}]
        set cp [expr {$cm eq "-" ? $c : ($c eq "" ? $cm : "$c.$cm")}]
        set within [expr {$union ? [concat $choices [list [list $bot $k [llength $alternatives]]]] : $choices}]
        lappend out {*}[Elements $layouts $members $type $bp $cp "$read.$fname" "$parse.$fname" $within]
        incr k
    }
    return $out
}

# The leaves of a field of type TYPE at BOT / C / READ / PARSE (Leaves').
proc ::cbind::oracle::Elements {layouts members type bot c read parse choices} {
    if {[regexp {^array ([0-9]+) of (.*)$} $type -> n element]} {
        set indices [expr {$n <= 4 ? [lsearch -all [lrepeat $n x] x] : [lsort -integer -unique [list 0 1 [expr {$n / 2}] [expr {$n - 1}]]]}]
        set out {}
        foreach i $indices {
            lappend out {*}[Elements $layouts $members $element "$bot\[$i\]" "$c\[$i\]" \
                "std::binary::element($read, $i)" "std::list::at($parse, $i)" $choices]
        }
        return $out
    }
    if {[dict exists $layouts $type]} {
        return [Leaves $layouts $members $type $bot $c $read $parse $choices]
    }
    return [list [list $bot $c $type $read $parse $choices]]
}

# 1 if a leaf of CHOICES (Leaves') is written in PHASE (0 C's init, 1 the
# edit, 2 the built bytes): the alternative PHASE selects of every union it
# lies in. Each union occurrence selects by its place and the seed, a
# different alternative in each phase.
proc ::cbind::oracle::Selected {choices phase seed} {
    foreach ch $choices {
        lassign $ch union k n
        set pick 0
        foreach letter [split $union ""] { set pick [expr {($pick * 31 + [scan $letter %c]) % 65521}] }
        if {($pick + $phase + $seed) % $n != $k} { return 0 }
    }
    return 1
}

# A deterministic value of an integer of BITS bits (SIGNED 0|1) for leaf I
# in PHASE (0 init, 1 edit, 2 bytes): {BITS-PATTERN VALUE}, every fourth
# leaf a boundary of its range.
proc ::cbind::oracle::Value {bits signed i phase seed} {
    set mod [expr {2 ** $bits}]
    switch -- [expr {($i + $phase) % 4}] {
        0 { set pattern [expr {$signed ? 2 ** ($bits - 1) : $mod - 1}] }
        1 { set pattern [expr {$signed ? 2 ** ($bits - 1) - 1 : 0}] }
        default {
            set pattern [expr {(($i + 1) * 0x9E3779B97F4A7C15 + ($phase + 1) * 0x632BE59BD9B4E019 + $seed * 0x2545F4914F6CDD1D) % $mod}]
        }
    }
    set value [expr {$signed && $pattern >= 2 ** ($bits - 1) ? $pattern - $mod : $pattern}]
    return [list $pattern $value]
}

# A deterministic value of the C floating type NAME (Float, Double) on
# TARGET for leaf I in PHASE: {BITS TEXT}, BITS its bit pattern (the C side
# writes and compares those bytes, exactly) and TEXT the Botlish literal of
# the Float64 it is (exactly: every value is one of the format's). Every
# fourth leaf is the largest finite value of the format, every fourth after
# it the smallest positive subnormal (C-FLOAT-FFI-MILESTONE-1.md: both cross
# the boundary unchanged); the others are exact multiples of 1/64.
proc ::cbind::oracle::FloatValue {name target i phase seed} {
    set format [dict get [core::cabi::floatingInfo $name $target] format]
    set info [core::cabi::formatInfo $format]
    switch -- [expr {($i + $phase) % 4}] {
        0 {
            set p [dict get $info precision]
            set x [expr {(2.0 - 2.0 ** (1 - $p)) * 2.0 ** [dict get $info maxExponent]}]
        }
        1 {
            set x [expr {2.0 ** (2 - [dict get $info maxExponent] - [dict get $info precision])}]
        }
        default {
            set n [expr {(($i + 1) * 0x9E3779B97F4A7C15 + ($phase + 1) * 0x632BE59BD9B4E019 + $seed * 0x2545F4914F6CDD1D) % 2097152}]
            set x [expr {($n - 1048576) / 64.0}]
        }
    }
    return [list [core::cabi::NarrowBits $format $x] [core::float::text [core::value::float Float64 $x]]]
}

# C statements copying the bit pattern BITS of a value of the C type CT
# into the lvalue DST's bytes (TO an expression of its address).
proc ::cbind::oracle::FloatStore {ct bits to} {
    return "    { $ct t; unsigned long long u = ${bits}ULL; __builtin_memcpy(&t, &u, sizeof t); __builtin_memcpy($to, &t, sizeof t); }\n"
}

proc ::cbind::oracle::Ident {s} { regsub -all {[^A-Za-z0-9_]} $s _ }

# The prelude of LAYOUTS-CHECK (layouts-check.c's text): its defines,
# includes and #undefs, before its own macros.
proc ::cbind::oracle::Prelude {check} {
    set at [string first "#define BOTLISH_M(" $check]
    return [string range $check 0 [expr {$at - 1}]]
}

proc ::cbind::oracle::build {ns dir names {seed 1} {target ""}} {
    if {$target eq ""} { set target [core::cabi::hostTarget] }
    set text [::chdr::readFile [file join $dir $ns layouts.bot]]
    set parsed [::cbind::verify::ParseLayouts $text]
    set layouts [dict create]
    foreach l $parsed { dict set layouts [lindex $l 0] [lrange $l 1 end] }
    lassign [::cbind::verify::CNames [::chdr::readFile [file join $dir layouts.tsv]]] records members
    # (A synthetic layout, an anonymous member's, is checked through the
    # layouts holding it: it has no C type of its own.)
    if {$names eq "all"} { set names [lmap n [dict keys $layouts] {expr {[dict get $records $n] eq "-" ? [continue] : $n}}] }
    set c [Prelude [::chdr::readFile [file join $dir layouts-check.c]]]
    append c "/* The runtime oracle of ${ns}::layouts (tools/c-bindgen/oracle.tcl): test tooling. */\n"
    append c "static char orc_anchor\[256\];\n"
    append c "#define ORC_ANCHOR(T, k) ((T)(__UINTPTR_TYPE__)&orc_anchor\[(k)\])\n"
    # (A binding whose layouts name no pointee identity has no ctypes module.)
    set ctypes [expr {[file exists [file join $dir $ns ctypes.bot]] ? "import ${ns}::ctypes\n" : ""}]
    set ext "# The C oracle's functions (tools/c-bindgen/oracle.tcl): test tooling.\nimport std::ffi::c\n$ctypes\nextern c library \"botlish_layout_oracle\"\n"
    set bot "direct module\n\nimport std::abi\nimport std::abi::bytes\nimport std::binary\nimport std::binary::native\nimport std::ffi::c\nimport std::list\nimport ${ns}::layouts\nimport orc\n"
    set calls {}
    set n 0
    foreach name $names {
        incr n
        set T [dict get $records $name]
        set L "${ns}::layouts::$name"
        set id [Ident $name]_$n
        set leaves [Leaves $layouts $members $name]
        set reads {}
        set parses {}
        set pointerFree 1
        set unionFree 1
        set floating 0
        foreach leaf $leaves {
            if {[regexp {^std::ffi::c::(Ptr|FnPtr)\[} [lindex $leaf 2]]} { set pointerFree 0 }
            if {[llength [lindex $leaf 5]]} { set unionFree 0 }
            if {[regexp {^std::ffi::c::(Float|Double)$} [lindex $leaf 2]]} { set floating 1 }
        }
        # C.
        append c "\n/* $name: $T */\n"
        append c "static union { $T value; unsigned char bytes\[sizeof($T)\]; } orc_rec_$id;\n"
        append c "unsigned long orc_${id}_size(void) { return sizeof($T); }\n"
        append c "unsigned long orc_${id}_align(void) { return _Alignof($T); }\n"
        set init ""
        set image0 ""
        set image1 ""
        set image2 ""
        set checkEdit ""
        set checkBytes ""
        set botRead ""
        set botStore ""
        set botWrite ""
        set botParse ""
        set written 0
        set i 0
        foreach leaf $leaves {
            lassign $leaf bp cp type read parse choices
            set ct "__typeof__(((($T *)0)->$cp))"
            set at "__builtin_offsetof($T, $cp)"
            set on0 [Selected $choices 0 $seed]
            set on1 [Selected $choices 1 $seed]
            set on2 [Selected $choices 2 $seed]
            if {[regexp {^std::ffi::c::(Ptr|FnPtr)\[} $type]} {
                set ka [expr {($n * 7 + $i) % 200}]
                set kb [expr {$ka + 17}]
                set kc [expr {$ka + 33}]
                append c "$ct orc_${id}_anchor_$i\(int k) { return ORC_ANCHOR($ct, k); }\n"
                append c "int orc_${id}_is_$i\($ct q, int k) { return q == ORC_ANCHOR($ct, k) ? 0 : 1; }\n"
                append ext "extern c fn orc_${id}_anchor_$i\(k: std::ffi::c::Int) -> $type\n"
                append ext "extern c fn orc_${id}_is_$i\(q: $type, k: std::ffi::c::Int) -> std::ffi::c::Int\n"
                if {$on0} {
                    append init "    { $ct t = ORC_ANCHOR($ct, $ka); __builtin_memcpy((void *)&r->$cp, &t, sizeof t); }\n"
                    append image0 "    { $ct t = ORC_ANCHOR($ct, $ka); __builtin_memcpy(img + $at, &t, sizeof t); }\n"
                    # (A pointer read from bits C stored as another
                    # interpretation is no pointer C made: it is not read.)
                    append botRead "    q$i = $read\n    r$i = orc::orc_${id}_is_$i\(q$i, $ka)\n"
                    lappend reads r$i
                }
                if {$on1} {
                    append image1 "    { $ct t = ORC_ANCHOR($ct, $kb); __builtin_memcpy(img + $at, &t, sizeof t); }\n"
                    append checkEdit "    if (r->$cp != ORC_ANCHOR($ct, $kb)) return [expr {$i + 1}];\n"
                    append botStore "    a$i = orc::orc_${id}_anchor_$i\($kb)\n    std::binary::store(e, $L.$bp, a$i)\n"
                }
                if {$on2} {
                    append image2 "    { $ct t = ORC_ANCHOR($ct, $kc); __builtin_memcpy(img + $at, &t, sizeof t); }\n"
                    append checkBytes "    if (r.$cp != ORC_ANCHOR($ct, $kc)) return [expr {$i + 1}];\n"
                    append botWrite "    b$i = orc::orc_${id}_anchor_$i\($kc)\n    d[expr {$written + 1}] = std::binary::write_foreign(d$written, $L.$bp, b$i)\n"
                    incr written
                }
            } elseif {[regexp {^std::ffi::c::(Float|Double)$} $type -> scalar]} {
                # A C float or double (C-FLOAT-FFI-MILESTONE-1.md): C writes
                # and checks exact bit patterns; Botlish reads, stores and
                # writes the Float64 each one is. Another interpretation of
                # bytes C wrote may be NaN, which is no value: not read.
                lassign [FloatValue $scalar $target $i 0 $seed] pa va
                lassign [FloatValue $scalar $target $i 1 $seed] pb vb
                lassign [FloatValue $scalar $target $i 2 $seed] pc vc
                if {$on0} {
                    append init [FloatStore $ct $pa "(void *)&r->$cp"]
                    append image0 [FloatStore $ct $pa "img + $at"]
                    append botRead "    r$i = if $read == $va:\n        0\n    else:\n        1\n"
                    lappend reads r$i
                }
                if {$on1} {
                    append image1 [FloatStore $ct $pb "img + $at"]
                    append checkEdit "    { $ct t; unsigned long long u = ${pb}ULL; __builtin_memcpy(&t, &u, sizeof t); if (__builtin_memcmp(&t, (const void *)&r->$cp, sizeof t)) return [expr {$i + 1}]; }\n"
                    append botStore "    std::binary::store(e, $L.$bp, $vb)\n"
                }
                if {$on2} {
                    append image2 [FloatStore $ct $pc "img + $at"]
                    append checkBytes "    { $ct t; unsigned long long u = ${pc}ULL; __builtin_memcpy(&t, &u, sizeof t); if (__builtin_memcmp(&t, (const void *)&r.$cp, sizeof t)) return [expr {$i + 1}]; }\n"
                    append botWrite "    d[expr {$written + 1}] = std::binary::write(d$written, $L.$bp, $vc)\n"
                    incr written
                    if {$pointerFree && $unionFree} {
                        append botParse "    s$i = if $parse == $vc:\n        0\n    else:\n        1\n"
                        lappend parses s$i
                    } elseif {!$unionFree} {
                        append botParse "    s$i = if std::binary::read(frozen, $L.$bp) == $vc:\n        0\n    else:\n        1\n"
                        lappend parses s$i
                    }
                }
            } else {
                regexp {^std::ffi::c::([A-Za-z]+)$} $type -> scalar
                set info [core::cabi::scalarInfo $scalar $target]
                set bits [dict get $info bits]
                set signed [dict get $info signed]
                lassign [Value $bits $signed $i 0 $seed] pa va
                lassign [Value $bits $signed $i 1 $seed] pb vb
                lassign [Value $bits $signed $i 2 $seed] pc vc
                if {$on0} {
                    append init "    { $ct t = ($ct)${pa}ULL; __builtin_memcpy((void *)&r->$cp, &t, sizeof t); }\n"
                    append image0 "    { $ct t = ($ct)${pa}ULL; __builtin_memcpy(img + $at, &t, sizeof t); }\n"
                    append botRead "    r$i = if $read == $va:\n        0\n    else:\n        1\n"
                } else {
                    # Another interpretation of bytes C wrote: C's own
                    # reading of them, by memcpy from the member's address.
                    append c "$ct orc_${id}_peek_$i\(void) { $ct t; __builtin_memcpy(&t, (const unsigned char *)&orc_rec_$id.value + $at, sizeof t); return t; }\n"
                    append ext "extern c fn orc_${id}_peek_$i\() -> $type\n"
                    append botRead "    r$i = if $read == orc::orc_${id}_peek_$i\():\n        0\n    else:\n        1\n"
                }
                lappend reads r$i
                if {$on1} {
                    append image1 "    { $ct t = ($ct)${pb}ULL; __builtin_memcpy(img + $at, &t, sizeof t); }\n"
                    append checkEdit "    if (r->$cp != ($ct)${pb}ULL) return [expr {$i + 1}];\n"
                    append botStore "    std::binary::store(e, $L.$bp, $vb)\n"
                }
                if {$on2} {
                    append image2 "    { $ct t = ($ct)${pc}ULL; __builtin_memcpy(img + $at, &t, sizeof t); }\n"
                    append checkBytes "    if (r.$cp != ($ct)${pc}ULL) return [expr {$i + 1}];\n"
                    append botWrite "    d[expr {$written + 1}] = std::binary::write(d$written, $L.$bp, $vc)\n"
                    incr written
                    if {$pointerFree && $unionFree} {
                        append botParse "    s$i = if $parse == $vc:\n        0\n    else:\n        1\n"
                        lappend parses s$i
                    } elseif {!$unionFree} {
                        append botParse "    s$i = if std::binary::read(frozen, $L.$bp) == $vc:\n        0\n    else:\n        1\n"
                        lappend parses s$i
                    }
                }
            }
            incr i
        }
        append c "void *orc_${id}_init(void) {\n    $T *r = &orc_rec_$id.value;\n    __builtin_memset(&orc_rec_$id, 0xA5, sizeof orc_rec_$id);\n$init    return r;\n}\n"
        append c "int orc_${id}_check_edit(const void *p) {\n    const $T *r = p;\n    unsigned char img\[sizeof($T)\];\n    __builtin_memset(img, 0xA5, sizeof img);\n$image0$image1$checkEdit"
        append c "    for (unsigned long i = 0; i < sizeof($T); i++)\n        if (((const unsigned char *)p)\[i\] != img\[i\]) return 1000 + (int)i;\n    return 0;\n}\n"
        append c "int orc_${id}_check_bytes(const unsigned char *b, unsigned long n) {\n    $T r;\n    unsigned char img\[sizeof($T)\];\n    if (n != sizeof($T)) return -1;\n    __builtin_memset(img, 0, sizeof img);\n$image2    __builtin_memcpy(&r, b, sizeof r);\n$checkBytes"
        append c "    for (unsigned long i = 0; i < sizeof($T); i++)\n        if (b\[i\] != img\[i\]) return 1000 + (int)i;\n    return 0;\n}\n"
        append ext "extern c fn orc_${id}_size() -> std::ffi::c::ULong\n"
        append ext "extern c fn orc_${id}_align() -> std::ffi::c::ULong\n"
        append ext "extern c fn orc_${id}_init() -> std::ffi::c::Ptr\[std::ffi::c::Void\]\n"
        append ext "extern c fn orc_${id}_check_edit(p: std::ffi::c::Ptr\[std::ffi::c::Void\]) -> std::ffi::c::Int\n"
        append ext "extern c fn orc_${id}_check_bytes(\n    b: std::ffi::c::Ptr\[std::ffi::c::UChar\] read noescape,\n    n: std::ffi::c::ULong\n) -> std::ffi::c::Int\n"
        # Botlish.
        set errors "NativeViewNull, NativeEditNull, LayoutLengthMismatch, IndexNotFound[expr {$floating ? ", NonFiniteFloat" : ""}]"
        set fn "\n# $name ($T)\nfn check_$id\() -> List\[int\] errors $errors:\n"
        append fn "    size = if orc::orc_${id}_size() == std::binary::layout_length($L):\n        0\n    else:\n        1\n"
        append fn "    align = if orc::orc_${id}_align() == std::binary::layout_alignment($L):\n        0\n    else:\n        1\n"
        append fn "    p = orc::orc_${id}_init()\n    v = std::binary::native::view($L, p)\n$botRead"
        append fn "    e = std::binary::native::edit($L, p)\n$botStore    edited = orc::orc_${id}_check_edit(p)\n"
        append fn "    d0 = std::abi::bytes::zeroed(std::abi::usize(std::binary::layout_length($L)))\n$botWrite"
        set dn d$written
        if {$pointerFree && $unionFree} {
            append fn "    s = std::binary::parse($L, std::abi::bytes::freeze($dn))\n$botParse"
        } elseif {!$unionFree && $botParse ne ""} {
            append fn "    frozen = std::abi::bytes::freeze($dn)\n$botParse"
        }
        append fn "    built = orc::orc_${id}_check_bytes($dn, [lindex [dict get $layouts $name] 0])\n"
        set all [concat size align $reads edited built $parses]
        append fn "    \[[join $all {, }]\]\n"
        append bot $fn
        lappend calls check_$id
        lappend expected [lrepeat [llength $all] 0]
        set readLabels {}
        set parseLabels {}
        set i 0
        foreach leaf $leaves {
            lassign $leaf bp cp type read parse choices
            set pointer [regexp {^std::ffi::c::(Ptr|FnPtr)\[} $type]
            set notRead [expr {$pointer || [regexp {^std::ffi::c::(Float|Double)$} $type]}]
            if {!$notRead || [Selected $choices 0 $seed]} {
                lappend readLabels [string cat $name "." $bp [expr {[Selected $choices 0 $seed] ? ": view read of C's store" : ": view read of another interpretation of C's bytes"}]]
            }
            if {!$pointer && [Selected $choices 2 $seed] && (($pointerFree && $unionFree) || !$unionFree)} {
                lappend parseLabels [string cat $name "." $bp [expr {$unionFree ? ": std::binary::parse of the bytes" : ": std::binary::read of the bytes"}]]
            }
            incr i
        }
        lappend checkLabels [concat [list "$name: layout_length == sizeof" "$name: layout_alignment == _Alignof"] \
            $readLabels \
            [list "$name: C reads every leaf Botlish stored through the edit, every other byte as C's own image of it" \
                "$name: C reads every leaf Botlish wrote in byte storage, every other byte zero"] \
            $parseLabels]
    }
    append bot "\nfn run() -> List\[any\] errors NativeViewNull, NativeEditNull, LayoutLengthMismatch, IndexNotFound, NonFiniteFloat:\n    \[[join [lmap k $calls {string cat $k "()"}] {, }]\]\n"
    append bot "\nr = run():\n    on NativeViewNull:\n        \[\"view of null\"\]\n    on NativeEditNull:\n        \[\"edit of null\"\]\n    on LayoutLengthMismatch:\n        \[\"length mismatch\"\]\n    on IndexNotFound:\n        \[\"index not found\"\]\n    on NonFiniteFloat:\n        \[\"non-finite float\"\]\nr\n"
    return [dict create c $c ext $ext bot $bot expected $expected labels $checkLabels names $names]
}

# The checks of RESULT (build's) a program VALUE fails (its shown value, a
# list of lists of Ints: [[0, 0], [0]]): their labels, with the code each
# returned.
proc ::cbind::oracle::failures {result value} {
    set out {}
    if {[regexp {^[][0-9, -]*$} $value]} { set value [lindex [string map {[ \{ ] \} , ""} $value] 0] }
    if {[llength $value] != [llength [dict get $result expected]]} {
        return [list "the program returned [string range $value 0 300]"]
    }
    foreach got $value want [dict get $result expected] labels [dict get $result labels] {
        foreach g $got w $want label $labels {
            if {$g ne $w} { lappend out "$label: code $g" }
        }
    }
    return $out
}

# Writes RESULT's files into APP (orc.bot, main.bot) and compiles its C
# oracle with CONFIG (a toolchain configuration) and the header profile
# TOOL into DIR's libbotlish_layout_oracle.a; returns DIR.
proc ::cbind::oracle::install {result app config tool dir} {
    ::chdr::writeFile [file join $app orc.bot] [dict get $result ext]
    ::chdr::writeFile [file join $app main.bot] [dict get $result bot]
    file mkdir $dir
    set src [file join $dir oracle.c]
    ::chdr::writeFile $src [dict get $result c]
    lassign [::chdr::toolchain::object $config $tool $src [file join $dir oracle.o] {-O1 -fPIC -w}] ok stderr
    if {!$ok} { error "the layout oracle does not compile:\n[string range $stderr 0 3000]" }
    lassign [::chdr::toolchain::archive $config [list [file join $dir oracle.o]] [file join $dir libbotlish_layout_oracle.a]] ok stderr
    if {!$ok} { error "the layout oracle's archive: $stderr" }
    return $dir
}
