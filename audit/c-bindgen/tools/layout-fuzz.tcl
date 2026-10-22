# layout-fuzz.tcl -- a fuzzer of the binding generator's record layouts
# (C-BINDGEN-LAYOUTS.md, "Fuzzing").
#
#   tclsh9.0 audit/c-bindgen/tools/layout-fuzz.tcl ?-n N? ?-seed S? ?-records K?
#                                                  ?-target T? ?-gc-stress 0|1?
#                                                  ?-keep 0|1? ?-verbose 0|1?
#
# Each of N programs is a fresh freestanding C header lf.h of K random
# records: fields of every C integer type and of C float and double
# (C-FLOAT-FFI-MILESTONE-1.md), stdint typedefs, typedef chains,
# enums of either sign, data pointers (void, char, an earlier record, the
# record itself, an incomplete record, a pointer to a pointer), function
# pointers (inline and through a typedef), earlier records nested by value,
# anonymous struct members and typedef-named anonymous records, with
# #pragma pack(N), packed and aligned attributes around and inside them,
# fixed arrays (FIXED-LAYOUT-ARRAYS.md: of C integers, stdint types, data
# pointers, earlier records and struct lf_inner, two-dimensional ones),
# unions (LAYOUT-UNIONS.md: union records of any of those alternatives --
# integers, a record and a scalar, an array and a scalar --, unions held by
# value and as array elements, anonymous unions, anonymous structs inside
# them) -- and, in some records, a field the layout language lacks: a
# flexible array member, a bitfield, a long double, a _Bool, an array
# of one of those, or a record that holds one of those by value (directly,
# as an array's elements, or as an alternative of a union, named or
# anonymous). The fuzzer generates its binding
# for TARGET (the host's by default; any target of the fixture's: the
# header is freestanding) with an in-memory profile, and checks, each
# against something other than the generator:
#
#   * its own model: which records are layouts and which are blocked, with
#     which direct blocker and which root reasons (a record holding a
#     blocked one, or an array of it, is nested-layout-blocked, rooted in
#     the inner reason; a union is blocked only by its alternatives' reasons,
#     an anonymous member's included; a pointer to a blocked record blocks
#     nothing); each emitted layout's field names, in order, and their
#     Botlish types -- the C scalar its own table of the target's data model
#     gives each C type and stdint name, the pointee identity its own naming
#     rule gives each pointer, an anonymous member's synthetic layout the
#     name its own rule gives it (the container's name and member place,
#     CONTAINER_memberN) with its own members;
#   * a second C compiler (GCC: cc on the host, the target's cross gcc
#     elsewhere, when installed): every size, alignment and offset the
#     emitted layouts state, and every array's sizeof and its last element's
#     offset, through the fuzzer's own C designators (an anonymous member's
#     members by their promoted C names, at the offset the layouts give
#     them through the synthetic layouts) -- run
#     as a program on the host, compiled as static assertions for another
#     target;
#   * the runtime oracle (tools/c-bindgen/oracle.tcl), on the host: C writes
#     every field of every emitted layout's record, Botlish reads them
#     through a native view, writes them through a native edit and into
#     byte storage, and C checks every field and every padding byte -- on
#     both native backends.
#
# The last line is "programs N records R layouts L disagreements X" (the
# exit status is 1 on any), the one before it how many of the layouts were
# unions and synthetic layouts (anonymous members), and how many unions were
# blocked; every disagreement is printed with its directory, kept unless
# -keep is 0.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 8 -seed 1 -records 10 -target "" -gc-stress 0 -keep 1 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tools c-bindgen lib.tcl]
source [file join $root tools c-bindgen oracle.tcl]

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc between {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

set host [core::cabi::hostTarget]
set target [expr {[dict get $options -target] eq "" ? $host : [dict get $options -target]}]

# The model: the target's data model, in this file's own words. C scalar
# spelling (the integers, float and double) -> the std::ffi::c scalar; the stdint
# names -> their C type on the target (LP64 Linux and macOS, LLP64 Windows:
# MinGW-w64's int64_t is long long).
set scalars [dict create char Char {signed char} SChar {unsigned char} UChar short Short \
    {unsigned short} UShort int Int {unsigned int} UInt long Long {unsigned long} ULong \
    {long long} LongLong {unsigned long long} ULongLong float Float double Double]
if {[string match windows-* $target]} {
    set stdints [dict create int8_t {signed char} uint8_t {unsigned char} int16_t short \
        uint16_t {unsigned short} int32_t int uint32_t {unsigned int} int64_t {long long} \
        uint64_t {unsigned long long} size_t {unsigned long long} intptr_t {long long}]
} elseif {[string match macos-* $target]} {
    set stdints [dict create int8_t {signed char} uint8_t {unsigned char} int16_t short \
        uint16_t {unsigned short} int32_t int uint32_t {unsigned int} int64_t {long long} \
        uint64_t {unsigned long long} size_t {unsigned long} intptr_t long]
} else {
    set stdints [dict create int8_t {signed char} uint8_t {unsigned char} int16_t short \
        uint16_t {unsigned short} int32_t int uint32_t {unsigned int} int64_t long \
        uint64_t {unsigned long} size_t {unsigned long} intptr_t long]
}

# Draws program P: a dict of typedefs, enums, records (each {name tag typedef
# anonymous kind pack attrs fields}, a field {c TEXT expect TYPE|blocked
# reason REASON dep KEY}), in declaration order.
proc drawProgram {p k} {
    set typedefs {}
    set count [between 1 3]
    for {set i 0} {$i < $count} {incr i} {
        set base [expr {[chance 0.5] ? [pick [dict keys $::stdints]] : [pick [dict keys $::scalars]]}]
        lappend typedefs [dict create name lf_t$i base $base]
    }
    set enums {}
    set count [between 0 2]
    for {set i 0} {$i < $count} {incr i} {
        set negative [chance 0.4]
        lappend enums [dict create name lf_e$i values [expr {$negative ? {-3 1 7} : {0 2 300}}]]
    }
    set records {}
    for {set r 0} {$r < $k} {incr r} {
        lappend records [verdict [drawRecord $r $records $typedefs $enums]]
    }
    return [dict create typedefs $typedefs enums $enums records $records]
}

# REC with the model's verdict: expectStatus (layout or blocked) and
# expectRoots (the direct reasons it waits for, through what it holds).
proc verdict {rec} {
    set roots {}
    foreach f [dict get $rec fields] {
        if {[dict get $f expect] ne "blocked"} continue
        switch -- [dict get $f reason] {
            nested { lappend roots {*}[dict get $f roots] }
            default { lappend roots [dict get $f reason] }
        }
    }
    dict set rec expectRoots [lsort -unique $roots]
    dict set rec expectStatus [expr {[llength $roots] ? "blocked" : "layout"}]
    return $rec
}

# The C scalar a typedef of the program names, through its chain.
proc typedefScalar {typedefs name} {
    foreach t $typedefs {
        if {[dict get $t name] eq $name} {
            set b [dict get $t base]
            if {[dict exists $::stdints $b]} { set b [dict get $::stdints $b] }
            return $b
        }
    }
    error "no typedef $name"
}

proc drawRecord {r earlier typedefs enums} {
    set kind [expr {[chance 0.18] ? "union" : "struct"}]
    set anonymous [expr {$kind eq "struct" && [chance 0.12]}]
    set tag [expr {$anonymous ? "" : "lf_r$r"}]
    set typedef [expr {$anonymous || [chance 0.5] ? "lf_r${r}_t" : ""}]
    set pack ""
    set attrs ""
    set x [expr {rand()}]
    if {$x < 0.2} {
        set pack [pick {1 2 4}]
    } elseif {$x < 0.3} {
        set attrs "__attribute__((packed))"
    } elseif {$x < 0.4} {
        set attrs "__attribute__((aligned([pick {8 16 32}])))"
    }
    set fields {}
    set n [between 1 7]
    set blocked [chance 0.2]
    set blockAt [expr {$blocked ? [between 0 [expr {$n - 1}]] : -1}]
    set recName [expr {$typedef ne "" ? $typedef : $tag}]
    for {set i 0} {$i < $n} {incr i} {
        set name f${r}_$i
        if {$i == $blockAt} {
            # A flexible array member only last, after a named member, and
            # in a struct (C).
            lappend fields [drawBlocked $r $i $name $earlier [expr {$kind eq "struct" && $i == $n - 1 && $i > 0}]]
            continue
        }
        set f [drawField $r $i $name $earlier $typedefs $enums [expr {$anonymous ? "" : "$kind $tag"}] \
            $recName $kind]
        if {[dict get $f expect] ne "promoted" && ![string match "union \{*" [dict get $f c]] && ![string match "struct \{*" [dict get $f c]]
                && [chance 0.05] && $kind eq "struct"} {
            dict set f c "[dict get $f c] __attribute__((aligned([pick {4 8 16}])))"
        }
        lappend fields $f
    }
    set key [expr {$anonymous ? "" : "$kind $tag"}]
    return [dict create name [expr {$typedef ne "" ? $typedef : $tag}] tag $tag typedef $typedef \
        anonymous $anonymous kind $kind pack $pack attrs $attrs fields $fields key $key index $r]
}

# A field of the supported universe: {c DECL expect TYPE members {{BOTNAME CPATH}} dep KEY}.
# A field of a union (KIND) is an alternative; SELFNAME names the record (an
# anonymous member's synthetic layout is named after it and its place, I).
proc drawField {r i name earlier typedefs enums self selfName {kind struct}} {
    set x [expr {rand()}]
    set emitted [lmap e $earlier {expr {![dict get $e anonymous] && [dict get $e expectStatus] eq "layout" ? $e : [continue]}}]
    set y [expr {rand()}]
    if {$y < 0.06} {
        # A union by value: lf_u, or an array of it.
        if {[chance 0.5]} {
            return [dict create c "union lf_u $name" expect nested nested {union lf_u} nestedName lf_u members [list [list $name $name]]]
        }
        set n [between 1 3]
        return [dict create c "union lf_u $name\[$n\]" expect "array $n of lf_u" members [list [list $name $name]]]
    } elseif {$y < 0.13} {
        return [drawAnonymous $i $name $selfName $earlier $kind]
    }
    if {$x < 0.32} {
        set c [pick [dict keys $::scalars]]
        return [dict create c "$c $name" expect std::ffi::c::[dict get $::scalars $c] members [list [list $name $name]]]
    } elseif {$x < 0.44} {
        set s [pick [dict keys $::stdints]]
        return [dict create c "$s $name" expect std::ffi::c::[dict get $::scalars [dict get $::stdints $s]] members [list [list $name $name]]]
    } elseif {$x < 0.52} {
        set t [pick $typedefs]
        return [dict create c "[dict get $t name] $name" expect std::ffi::c::[dict get $::scalars [typedefScalar $typedefs [dict get $t name]]] members [list [list $name $name]]]
    } elseif {$x < 0.58 && [llength $enums]} {
        set e [pick $enums]
        set neg [expr {[lindex [dict get $e values] 0] < 0}]
        return [dict create c "enum [dict get $e name] $name" expect [expr {$neg ? "std::ffi::c::Int" : "std::ffi::c::UInt"}] members [list [list $name $name]]]
    } elseif {$x < 0.74} {
        set shape [pick {void char self opaque earlier pointer}]
        switch -- $shape {
            void { return [dict create c "void *$name" expect "std::ffi::c::Ptr\[std::ffi::c::Void\]" members [list [list $name $name]]] }
            char { return [dict create c "const char *$name" expect "std::ffi::c::Ptr\[std::ffi::c::Char\]" members [list [list $name $name]]] }
            opaque { return [dict create c "struct lf_opaque *$name" expect "std::ffi::c::Ptr\[lf::ctypes::lf_opaque\]" members [list [list $name $name]]] }
            pointer { return [dict create c "void **$name" expect "std::ffi::c::Ptr\[std::ffi::c::Ptr\[std::ffi::c::Void\]\]" members [list [list $name $name]]] }
            self {
                if {$self eq ""} { return [dict create c "struct lf_opaque *$name" expect "std::ffi::c::Ptr\[lf::ctypes::lf_opaque\]" members [list [list $name $name]]] }
                return [dict create c "$self *$name" expect "std::ffi::c::Ptr\[lf::ctypes::$selfName\]" members [list [list $name $name]]]
            }
            earlier {
                set named [lmap e $earlier {expr {[dict get $e anonymous] ? [continue] : $e}}]
                if {![llength $named]} { return [dict create c "void *$name" expect "std::ffi::c::Ptr\[std::ffi::c::Void\]" members [list [list $name $name]]] }
                set e [pick $named]
                return [dict create c "[dict get $e kind] [dict get $e tag] *$name" expect "std::ffi::c::Ptr\[lf::ctypes::[dict get $e name]\]" members [list [list $name $name]]]
            }
        }
    } elseif {$x < 0.80} {
        return [drawArray $name $emitted]
    } elseif {$x < 0.86} {
        if {[chance 0.5]} {
            return [dict create c "int (*$name)(int, void *)" expect "std::ffi::c::FnPtr\[Fn{args: \[std::ffi::c::Int, std::ffi::c::Ptr\[std::ffi::c::Void\]\], return: std::ffi::c::Int}\]" members [list [list $name $name]]]
        }
        return [dict create c "lf_callback $name" expect "std::ffi::c::FnPtr\[Fn{args: \[std::ffi::c::Long\], return: unit}\]" members [list [list $name $name]]]
    } elseif {$x < 0.93 && [llength $emitted]} {
        set e [pick $emitted]
        return [dict create c "[dict get $e kind] [dict get $e tag] $name" expect nested nested [dict get $e key] members [list [list $name $name]]]
    } elseif {$x < 1.0} {
        # An anonymous struct member: in a struct, its members are the
        # record's own (promoted); in a union, a synthetic struct layout is
        # the alternative.
        set a [pick [dict keys $::scalars]]
        set b [pick [dict keys $::scalars]]
        if {$kind eq "union"} {
            return [dict create c "struct { $a ${name}_a; $b ${name}_b; }" expect anonymous \
                synthetic ${selfName}_member[expr {$i + 1}] slot member[expr {$i + 1}] synthKind struct \
                inner [list [dict create c "$a ${name}_a" expect std::ffi::c::[dict get $::scalars $a] members [list [list ${name}_a ${name}_a]]] \
                    [dict create c "$b ${name}_b" expect std::ffi::c::[dict get $::scalars $b] members [list [list ${name}_b ${name}_b]]]]]
        }
        return [dict create c "struct { $a ${name}_a; $b ${name}_b; }" expect promoted \
            types [list std::ffi::c::[dict get $::scalars $a] std::ffi::c::[dict get $::scalars $b]] \
            members [list [list ${name}_a ${name}_a] [list ${name}_b ${name}_b]]]
    }
    return [dict create c "int $name" expect std::ffi::c::Int members [list [list $name $name]]]
}

# An anonymous union member I of the record SELFNAME (LAYOUT-UNIONS.md): a
# synthetic union layout SELFNAME_memberI+1, held by the field memberI+1,
# its alternatives scalars, arrays, an earlier record -- and sometimes an
# anonymous struct of its own (a synthetic struct layout, the alternative
# memberJ+1) or a field the layout language lacks, which blocks it and the
# record (its root reason, never the union).
proc drawAnonymous {i name selfName earlier kind} {
    set synth ${selfName}_member[expr {$i + 1}]
    set inner {}
    set m [between 1 3]
    for {set j 0} {$j < $m} {incr j} {
        set iname ${name}_[format %c [expr {97 + $j}]]
        switch -- [pick {scalar scalar array struct record blocked}] {
            scalar {
                set c [pick [dict keys $::scalars]]
                lappend inner [dict create c "$c $iname" expect std::ffi::c::[dict get $::scalars $c] members [list [list $iname $iname]]]
            }
            array { lappend inner [drawArray $iname [lmap e $earlier {expr {![dict get $e anonymous] && [dict get $e expectStatus] eq "layout" ? $e : [continue]}}]] }
            struct {
                set a [pick [dict keys $::scalars]]
                set b [pick [dict keys $::scalars]]
                lappend inner [dict create c "struct { $a ${iname}_x; $b ${iname}_y; }" expect anonymous \
                    synthetic ${synth}_member[expr {$j + 1}] slot member[expr {$j + 1}] synthKind struct \
                    inner [list [dict create c "$a ${iname}_x" expect std::ffi::c::[dict get $::scalars $a] members [list [list ${iname}_x ${iname}_x]]] \
                        [dict create c "$b ${iname}_y" expect std::ffi::c::[dict get $::scalars $b] members [list [list ${iname}_y ${iname}_y]]]]]
            }
            record {
                set emitted [lmap e $earlier {expr {![dict get $e anonymous] && [dict get $e expectStatus] eq "layout" ? $e : [continue]}}]
                if {[llength $emitted]} {
                    set e [pick $emitted]
                    lappend inner [dict create c "[dict get $e kind] [dict get $e tag] $iname" expect nested nested [dict get $e key] members [list [list $iname $iname]]]
                } else {
                    lappend inner [dict create c "int $iname" expect std::ffi::c::Int members [list [list $iname $iname]]]
                }
            }
            blocked {
                set reason [pick {long-double c-bool bitfield}]
                set decl [dict get {long-double "long double NAME" c-bool "_Bool NAME" bitfield "unsigned int NAME : 3"} $reason]
                lappend inner [dict create c [string map [list NAME $iname] $decl] expect blocked reason $reason]
            }
        }
    }
    set f [dict create c "union { [join [lmap g $inner {string cat [dict get $g c] ";"}] { }] }" expect anonymous \
        synthetic $synth slot member[expr {$i + 1}] synthKind union inner $inner]
    set roots [AnonymousRoots $f]
    if {[llength $roots]} {
        return [dict create c [dict get $f c] expect blocked reason nested roots $roots]
    }
    return $f
}

# The root reasons an anonymous member field F waits for (its blocked
# alternatives', at any depth).
proc AnonymousRoots {f} {
    set roots {}
    foreach g [dict get $f inner] {
        if {[dict get $g expect] eq "blocked"} { lappend roots [dict get $g reason] }
        if {[dict get $g expect] eq "anonymous"} { lappend roots {*}[AnonymousRoots $g] }
    }
    return [lsort -unique $roots]
}

# A fixed array of a supported element (FIXED-LAYOUT-ARRAYS.md): {c DECL
# expect TYPE members ...}, TYPE `array N of ...` by the model's own tables.
proc drawArray {name emitted} {
    set n [between 1 6]
    switch -- [pick {scalar scalar stdint pointer rows record inner}] {
        scalar {
            set c [pick [dict keys $::scalars]]
            return [dict create c "$c $name\[$n\]" expect "array $n of std::ffi::c::[dict get $::scalars $c]" members [list [list $name $name]]]
        }
        stdint {
            set t [pick [dict keys $::stdints]]
            return [dict create c "$t $name\[$n\]" expect "array $n of std::ffi::c::[dict get $::scalars [dict get $::stdints $t]]" members [list [list $name $name]]]
        }
        pointer {
            return [dict create c "void *$name\[$n\]" expect "array $n of std::ffi::c::Ptr\[std::ffi::c::Void\]" members [list [list $name $name]]]
        }
        rows {
            set m [between 1 4]
            set c [pick [dict keys $::scalars]]
            return [dict create c "$c $name\[$n\]\[$m\]" expect "array $n of array $m of std::ffi::c::[dict get $::scalars $c]" members [list [list $name $name]]]
        }
        record {
            if {[llength $emitted]} {
                set e [pick $emitted]
                return [dict create c "[dict get $e kind] [dict get $e tag] $name\[$n\]" expect "array $n of [dict get $e name]" members [list [list $name $name]]]
            }
        }
    }
    return [dict create c "struct lf_inner $name\[$n\]" expect "array $n of lf_inner" members [list [list $name $name]]]
}

# A field the layout language lacks: {c DECL expect blocked reason R dep KEY?}.
proc drawBlocked {r i name earlier last} {
    set blockedEarlier [lmap e $earlier {expr {[dict get $e kind] eq "struct" && ![dict get $e anonymous] && [dict get $e expectStatus] eq "blocked" ? $e : [continue]}}]
    set shapes {bitfield longdouble bool longdoubles bools ldUnion ldUnions}
    if {$last} { lappend shapes flexible }
    if {[llength $blockedEarlier]} { lappend shapes nestedBlocked nestedBlocked nestedBlockedArray }
    set shape [pick $shapes]
    switch -- $shape {
        longdoubles { return [dict create c "long double $name\[[between 1 4]\]" expect blocked reason long-double] }
        bools { return [dict create c "_Bool $name\[[between 1 4]\]" expect blocked reason c-bool] }
        ldUnions { return [dict create c "union lf_lu $name\[2\]" expect blocked reason nested roots long-double] }
        flexible { return [dict create c "int $name\[\]" expect blocked reason flexible-array] }
        ldUnion { return [dict create c "union lf_lu $name" expect blocked reason nested roots long-double] }
        bitfield { return [dict create c "unsigned int $name : [between 1 9]" expect blocked reason bitfield] }
        longdouble { return [dict create c "long double $name" expect blocked reason long-double] }
        bool { return [dict create c "_Bool $name" expect blocked reason c-bool] }
        nestedBlocked {
            set e [pick $blockedEarlier]
            return [dict create c "struct [dict get $e tag] $name" expect blocked reason nested roots [dict get $e expectRoots] dep [dict get $e key]]
        }
        nestedBlockedArray {
            # (An array of a blocked record is blocked by its element:
            # FIXED-LAYOUT-ARRAYS.md.)
            set e [pick $blockedEarlier]
            return [dict create c "struct [dict get $e tag] $name\[[between 1 4]\]" expect blocked reason nested roots [dict get $e expectRoots] dep [dict get $e key]]
        }
    }
}

# The header text of PROG.
proc header {prog} {
    set h "/* lf.h -- a layout fuzz program (audit/c-bindgen/tools/layout-fuzz.tcl). */\n#ifndef LF_H\n#define LF_H\n#include <stdint.h>\n#include <stddef.h>\n#include <stdbool.h>\n\n"
    append h "struct lf_opaque;\nstruct lf_inner { int a; long b; };\nunion lf_u { int i; void *p; };\nunion lf_lu { int i; long double f; };\ntypedef void (*lf_callback)(long);\n"
    foreach t [dict get $prog typedefs] { append h "typedef [dict get $t base] [dict get $t name];\n" }
    foreach e [dict get $prog enums] {
        set items {}
        set k 0
        foreach v [dict get $e values] { lappend items "[string toupper [dict get $e name]]_$k = $v"; incr k }
        append h "enum [dict get $e name] { [join $items {, }] };\n"
    }
    foreach rec [dict get $prog records] {
        set r [dict get $rec index]
        append h "\n"
        if {[dict get $rec pack] ne ""} { append h "#pragma pack(push, [dict get $rec pack])\n" }
        set head [dict get $rec kind]
        if {[dict get $rec attrs] ne ""} { append head " [dict get $rec attrs]" }
        if {![dict get $rec anonymous]} { append head " [dict get $rec tag]" }
        set body [join [lmap f [dict get $rec fields] {string cat "    " [dict get $f c] ";"}] \n]
        if {[dict get $rec typedef] ne ""} {
            append h "typedef $head {\n$body\n} [dict get $rec typedef];\n"
        } else {
            append h "$head {\n$body\n};\n"
        }
        if {[dict get $rec pack] ne ""} { append h "#pragma pack(pop)\n" }
    }
    append h "\n#endif\n"
    return $h
}

# The C name of record REC.
proc cname {rec} {
    return [expr {[dict get $rec anonymous] ? [dict get $rec typedef] : "[dict get $rec kind] [dict get $rec tag]"}]
}

# The disagreements of RESULT (a generation) with the model PROG.
proc checkModel {prog result} {
    set problems {}
    set model [dict get $result model]
    set recs [dict get $model layouts]
    set layoutText [expr {[dict exists $result files lf/layouts.bot] ? [dict get $result files lf/layouts.bot] : ""}]
    set parsed [::cbind::verify::ParseLayouts $layoutText]
    set layouts [dict create]
    foreach l $parsed { dict set layouts [lindex $l 0] [lrange $l 1 end] }
    foreach rec [dict get $prog records] {
        set key [dict get $rec key]
        if {$key eq ""} {
            # A typedef-named anonymous record: found by its typedef.
            set key ""
            dict for {k v} $recs {
                if {[dict get $v anonymous] && [dict get $rec typedef] in [dict get $v typedefs]} { set key $k }
            }
            if {$key eq ""} { lappend problems "[dict get $rec name]: not discovered"; continue }
        }
        if {![dict exists $recs $key]} { lappend problems "$key: not discovered"; continue }
        set got [dict get $recs $key]
        set want [dict get $rec expectStatus]
        set status [dict get $got status]
        if {($want eq "layout") != ($status eq "layout-direct")} {
            lappend problems "$key: the model says $want, the generator $status ([dict get $got direct])"
            continue
        }
        if {$want eq "blocked"} {
            set roots [::cbind::records::RootReasons $recs $key]
            if {$roots ne [dict get $rec expectRoots]} {
                lappend problems "$key: roots [dict get $rec expectRoots] by the model, $roots by the generator"
            }
            continue
        }
        set name [dict get $got layoutName]
        if {$name ne [dict get $rec name]} { lappend problems "$key: layout name $name, the model's [dict get $rec name]" }
        if {![dict exists $layouts $name]} { lappend problems "$key: no layout $name in layouts.bot"; continue }
        lappend problems {*}[checkFields $prog $layouts $name [dict get $rec fields] [dict get $rec kind]]
    }
    return $problems
}

# The disagreements of layout NAME of LAYOUTS (the generated text's) with
# the model's FIELDS of a KIND record, and of every synthetic layout an
# anonymous member of them is, recursively.
proc checkFields {prog layouts name fields kind} {
    set problems {}
    if {![dict exists $layouts $name]} { return [list "no layout $name in layouts.bot"] }
    lassign [dict get $layouts $name] size align have union
    if {$union != ($kind eq "union")} { lappend problems "$name: union $union, the model's [expr {$kind eq "union"}]" }
    set expected {}
    foreach f $fields {
        switch -- [dict get $f expect] {
            promoted {
                foreach m [dict get $f members] t [dict get $f types] { lappend expected [list [lindex $m 0] $t] }
            }
            nested {
                if {[dict exists $f nestedName]} {
                    set inner [dict get $f nestedName]
                } else {
                    set inner ""
                    foreach e [dict get $prog records] { if {[dict get $e key] eq [dict get $f nested]} { set inner [dict get $e name] } }
                }
                lappend expected [list [lindex [dict get $f members] 0 0] $inner]
            }
            anonymous {
                lappend expected [list [dict get $f slot] [dict get $f synthetic]]
                lappend problems {*}[checkFields $prog $layouts [dict get $f synthetic] [dict get $f inner] [dict get $f synthKind]]
            }
            default { lappend expected [list [lindex [dict get $f members] 0 0] [dict get $f expect]] }
        }
    }
    set actual [lmap f $have {list [lindex $f 0] [lindex $f 1]}]
    if {$actual ne $expected} { lappend problems "$name: fields $actual, the model's $expected" }
    if {$union} {
        foreach f $have { if {[lindex $f 2] != 0} { lappend problems "$name.[lindex $f 0]: an alternative at [lindex $f 2]" } }
    }
    return $problems
}

# Every synthetic layout name the model's FIELDS hold, recursively.
proc syntheticNames {fields} {
    set out {}
    foreach f $fields {
        if {[dict get $f expect] eq "anonymous"} {
            lappend out [dict get $f synthetic] {*}[syntheticNames [dict get $f inner]]
        }
    }
    return $out
}

# The fields of layout NAME of LAYOUTS flattened through synthetic layouts
# (SYNTHETIC: their names): {{BOTPATH CPATH TYPE OFFSET} ...}, OFFSET from
# the record's start (BASE plus the fields'), CPATH the C member (an
# anonymous member's members are the record's: C11's promoted names).
proc flatten {layouts name synthetic base bot} {
    set out {}
    foreach f [lindex [dict get $layouts $name] 2] {
        lassign $f fname type offset
        set at [expr {$base + $offset}]
        if {$type in $synthetic} {
            lappend out {*}[flatten $layouts $type $synthetic $at "$bot$fname."]
        } else {
            lappend out [list "$bot$fname" $fname $type $at]
        }
    }
    return $out
}

# The members of every emitted layout as the fuzzer's own C designators:
# {LAYOUT CNAME {{BOTPATH CPATH} ...}} with nested layouts flattened.
proc designators {prog layouts} {
    set out {}
    set synthetic {}
    foreach rec [dict get $prog records] { lappend synthetic {*}[syntheticNames [dict get $rec fields]] }
    foreach rec [dict get $prog records] {
        if {[dict get $rec expectStatus] ne "layout" || ![dict exists $layouts [dict get $rec name]]} continue
        lappend out [list [dict get $rec name] [cname $rec] [flatten $layouts [dict get $rec name] $synthetic 0 ""]]
    }
    return $out
}

# The second compiler's disagreements with the emitted layouts: a C
# program (host) or static assertions (another target) of every size,
# alignment and offset through the fuzzer's designators, compiled by GCC.
proc secondCompiler {dir prog result} {
    set cross {linux-aarch64 aarch64-linux-gnu-gcc linux-x86_64 x86_64-linux-gnu-gcc windows-x86_64-gnu x86_64-w64-mingw32-gcc}
    if {$::target ne $::host && ![dict exists $cross $::target]} { return [list skipped] }
    set gcc [expr {$::target eq $::host ? "cc" : [dict get $cross $::target]}]
    if {[auto_execok $gcc] eq ""} { return [list skipped] }
    set parsed [::cbind::verify::ParseLayouts [dict get $result files lf/layouts.bot]]
    set layouts [dict create]
    foreach l $parsed { dict set layouts [lindex $l 0] [lrange $l 1 end] }
    set src "#include <lf/lf.h>\n"
    set asserts ""
    set prints ""
    foreach d [designators $prog $layouts] {
        lassign $d name c fields
        lassign [dict get $layouts $name] size align
        append asserts "_Static_assert(sizeof($c) == $size, \"$name size\");\n_Static_assert(_Alignof($c) == $align, \"$name align\");\n"
        append prints "    printf(\"$name %zu %zu\\n\", sizeof($c), _Alignof($c));\n"
        foreach f $fields {
            lassign $f bot fname type offset
            append asserts "_Static_assert(__builtin_offsetof($c, $fname) == $offset, \"$name.$bot\");\n"
            append prints "    printf(\"$name.$fname %zu $offset\\n\", __builtin_offsetof($c, $fname));\n"
            # A fixed array: its sizeof, and its last element's offset (the
            # stride), by the model's widths.
            lassign [arrayShape $type $layouts] extents width
            if {[llength $extents]} {
                set count 1
                set last $fname
                foreach e $extents {
                    set count [expr {$count * $e}]
                    append last "\[[expr {$e - 1}]\]"
                }
                append asserts "_Static_assert(sizeof((($c *)0)->$fname) == [expr {$count * $width}], \"$name.$fname sizeof\");\n"
                append asserts "_Static_assert(__builtin_offsetof($c, $last) == [expr {$offset + ($count - 1) * $width}], \"$name.$fname last\");\n"
                append prints "    printf(\"$name.$fname:size %zu [expr {$count * $width}]\\n\", sizeof((($c *)0)->$fname));\n"
                append prints "    printf(\"$name.$fname:last %zu [expr {$offset + ($count - 1) * $width}]\\n\", __builtin_offsetof($c, $last));\n"
            }
        }
    }
    set inc [file join $dir src include]
    if {$::target ne $::host} {
        set path [file join $dir second.c]
        writeFile $path "$src$asserts"
        if {[catch {exec $gcc -ffreestanding -w -I$inc -c $path -o [file join $dir second.o] 2>@1} out]} {
            return [list "$gcc rejects the emitted layouts: [string range $out 0 1500]"]
        }
        return {}
    }
    set path [file join $dir second.c]
    writeFile $path "#include <stdio.h>\n${src}int main(void) {\n$prints    return 0;\n}\n"
    if {[catch {exec $gcc -w -I$inc $path -o [file join $dir second] 2>@1} out]} {
        return [list "$gcc does not compile the probe: [string range $out 0 1500]"]
    }
    set problems {}
    foreach line [split [string trim [exec [file join $dir second]]] \n] {
        lassign $line what a b
        if {[string match *:* $what]} {
            if {$a != $b} { lappend problems "$what: GCC's $a, the layout's $b" }
        } elseif {[string match *.* $what]} {
            if {$a != $b} { lappend problems "$what: GCC's offset $a, the layout's $b" }
        } else {
            lassign [dict get $layouts $what] size align
            if {$size != $a || $align != $b} { lappend problems "$what: GCC's sizeof $a and _Alignof $b, the layout's $size and $align" }
        }
    }
    return $problems
}

# {EXTENTS WIDTH} of a layout field type TYPE: a fixed array's extents,
# outermost first, and its element's width by the model's tables (a scalar's
# on the target, a pointer's, a nested layout's size in LAYOUTS); {} {} for
# any other type.
proc arrayShape {type layouts} {
    set extents {}
    while {[regexp {^array ([0-9]+) of (.*)$} $type -> n inner]} {
        lappend extents $n
        set type $inner
    }
    if {![llength $extents]} { return {{} {}} }
    if {[regexp {^std::ffi::c::(Ptr|FnPtr)\[} $type]} {
        set width [expr {[dict get [core::cabi::target $::target] pointer] / 8}]
    } elseif {$type in {std::ffi::c::Float std::ffi::c::Double}} {
        # IEEE 754 binary32 and binary64 on every target.
        set width [dict get {std::ffi::c::Float 4 std::ffi::c::Double 8} $type]
    } elseif {[regexp {^std::ffi::c::([A-Za-z]+)$} $type -> scalar]} {
        set width [expr {[dict get [core::cabi::scalarInfo $scalar $::target] bits] / 8}]
    } else {
        set width [lindex [dict get $layouts $type] 0]
    }
    return [list $extents $width]
}

proc writeFile {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

expr {srand([dict get $options -seed])}
set scratch [file tempdir]
set programs 0
set nrecords 0
set nlayouts 0
set nunions 0
set nsynthetic 0
set nblockedUnions 0
set disagreements 0
set skippedSecond 0
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set prog [drawProgram $p [dict get $options -records]]
    set dir [file join $scratch p$p]
    writeFile [file join $dir src include lf lf.h] [header $prog]
    set profile [::cbind::profile::Validate [dict create name lf path [file join $dir profile] \
        headers [dict create library lf source [list local [file join $dir src]] includeDirs include \
            flags {-ffreestanding -nostdlibinc} public {include/lf/*} entry {lf/lf.h}] \
        targets [list $target] evidence none]]
    writeFile [dict get $profile path] "# a layout fuzz program's binding profile\n[list dict create {*}$profile]\n"
    set problem ""
    if {[catch {::cbind::generate::run $profile $target} result]} {
        set problem "generation failed: $result"
    } else {
        ::cbind::generate::write [dict get $result files] [file join $dir out] lf
        set problems [checkModel $prog $result]
        set second [secondCompiler $dir $prog $result]
        if {$second eq "skipped"} { incr skippedSecond } else { lappend problems {*}$second }
        set emitted [llength [dict get $result model layoutOrder]]
        incr nlayouts $emitted
        foreach k [dict get $result model layoutOrder] {
            set lr [dict get $result model layouts $k]
            if {[dict get $lr kind] eq "union"} { incr nunions }
            if {[dict get $lr synthetic]} { incr nsynthetic }
        }
        dict for {k lr} [dict get $result model layouts] {
            if {[dict get $lr kind] eq "union" && [dict get $lr status] eq "layout-blocked"} { incr nblockedUnions }
        }
        if {$target eq $host && $emitted} {
            set r [::cbind::oracle::build lf [file join $dir out] all [expr {[dict get $options -seed] * 100 + $p}]]
            set app [file join $dir app]
            file mkdir $app
            file copy [file join $dir out lf] [file join $app lf]
            set tool [dict create includeDirs [list [file join $dir src include]] defines {} undefines {} flags {-ffreestanding -nostdlibinc}]
            if {[catch {::cbind::oracle::install $r $app [::chdr::toolchain::configFor $target] $tool [file join $dir oracle]} lib]} {
                lappend problems "the oracle: $lib"
            } elseif {[catch {surface::readProgramFile [file join $app main.bot] -warnings off -cache ""} hir]} {
                lappend problems "the oracle program does not compile: [string range $hir 0 1500]"
            } else {
                if {[dict get $options -gc-stress]} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
                native::withLinkDirs [list $lib] {
                    foreach backend {cranelift cranelift-generic} {
                        lassign [outcomeUnderHir $backend $hir] tag value message
                        if {$tag ne "value"} {
                            lappend problems "$backend: $tag $value $message"
                            continue
                        }
                        foreach f [::cbind::oracle::failures $r $value] { lappend problems "$backend: $f" }
                    }
                }
                unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
            }
        }
        set problem [join $problems \n]
    }
    incr programs
    incr nrecords [llength [dict get $prog records]]
    if {$problem ne ""} {
        incr disagreements
        puts "DISAGREEMENT program $p ($dir):\n$problem"
        if {![dict get $options -keep]} { file delete -force $dir }
    } else {
        if {[dict get $options -verbose]} { puts "program $p: ok ([llength [dict get $prog records]] records, $emitted layouts, header CRC [::chdr::crc32 [header $prog]])" }
        file delete -force $dir
    }
}
if {$disagreements == 0} { file delete -force $scratch }
if {$skippedSecond} { puts "(no second compiler for $target: $skippedSecond programs checked by the model and the generator's own verification only)" }
puts "(union layouts $nunions, synthetic layouts $nsynthetic, blocked unions $nblockedUnions)"
puts "programs $programs records $nrecords layouts $nlayouts disagreements $disagreements"
exit [expr {$disagreements > 0}]
