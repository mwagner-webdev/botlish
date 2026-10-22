#!/usr/bin/env tclsh9.0
# fuzz.tcl -- Hashable, the public hash and the private table hash against an
# independent model (HASHABLE-AND-KEYED-HASH.md, "Fuzzing").
#
#   tclsh9.0 audit/hashable/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                          ?-backends LIST? ?-gc-stress 0|1?
#
# Each program declares an enum (its cases in a random order) and two to four
# structs whose fields are drawn from the Hashable types (Int, String, Bool,
# UnicodeChar, Float64, the enum, an earlier struct, List[int], List[str],
# ImmutableSet[int]), then hashes 8..16 generated values of those types --
# Ints at the small/big boundaries (2^61, 2^62, 2^63, 2^64, 2^128, negative
# and positive), Strings empty, short and long, with characters at the UTF-8
# encoding boundaries, code points at the same boundaries, dyadic Float64s,
# enum cases, named and anonymous structs, nested structs, Lists and sets --
# and 3..6 pairs of equal values constructed differently (an Int computed and
# written, a String concatenated and written, a set from a shuffled list with
# a duplicate, a struct's fields written in another order, a Float64 sum).
# For each value it observes the public hash, the table hash (through a
# standard library module, the only code that may call it), the hash through
# a Hashable parameter and ==; for each pair, ==, the public hashes' equality
# and the table hashes' equality.
#
# The model shares no code with the compiler or a runtime: a value is a JSON
# description its generator writes beside the source, and
# audit/hashable/tools/oracle.py (the independent encoder, FNV-1a and
# SipHash) computes both hashes from it under the run's fixed test key
# (core::hashing::useTableHashKey, forwarded to the native driver). Every
# backend of BACKENDS must give exactly the model's observations.
#
# Each program also carries admission probes: a struct with one field of a
# type outside Hashable -- a function (`Fn{...}`, statically not Hashable), a
# MutableArray (likewise) or `any` (not known) -- or with Hashable fields
# only, and a struct holding one of those, passed to a Hashable parameter, to
# the table hash and to the public hash. The model's verdict, from its own
# three-valued rule (a field of none makes the struct none, else a field of
# unknown makes it unknown, else total): a Hashable parameter and the table
# hash accept exactly total; the public hash rejects exactly none
# (TRAIT-NOT-SATISFIED), and hashes an unknown value dynamically. An accepted
# probe of the public hash must run on every backend.
#
# With -gc-stress 1 the main program runs again on cranelift with a
# collection at every allocation site.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 30 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

# A private library: the standard one plus the module hashfix, which reaches
# the table hash as the standard library's hash structures will.
set ::fuzzLibrary [file tempdir botlish-hashable-fuzz]
foreach entry [glob -nocomplain -directory $::core::libraryDir *] {
    file copy -force $entry $::fuzzLibrary
}
set ::core::libraryDir $::fuzzLibrary
set channel [open [file join $::fuzzLibrary hashfix.bot] w]
fconfigure $channel -encoding utf-8 -translation lf
puts -nonewline $channel {import table_hash

fn keyed(x: Hashable) -> int:
    table_hash::of(x)
}
close $channel

# ---------------------------------------------------------------------------
# Deterministic choices

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState / 65536) % $n}]
}

proc Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

proc Shuffle {list} {
    set out {}
    while {$list ne {}} {
        set i [Rand [llength $list]]
        lappend out [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $out
}

proc Json {text} {
    # A JSON string literal of TEXT (the generator's texts hold no control
    # characters).
    return "\"[string map {\\ \\\\ \" \\\"} $text]\""
}

# ---------------------------------------------------------------------------
# Values: {EXPR JSON} of a model type
#
# A model type is int | str | bool | char | float | enum | {struct NAME} |
# {list T} | {set} | anon; a program's structs are {NAME {FIELD TYPE ...}}.

set ::intEdges {0 1 -1 7 -7 9 10 99 100 -100 2305843009213693951 2305843009213693952 -2305843009213693952
    4611686018427387903 4611686018427387904 -4611686018427387904 -4611686018427387905
    9223372036854775807 9223372036854775808 -9223372036854775808 -9223372036854775809
    18446744073709551615 18446744073709551616 -18446744073709551616
    170141183460469231731687303715884105728 340282366920938463463374607431768211455
    340282366920938463463374607431768211456 -340282366920938463463374607431768211456
    100000000000000000000000000000000000007 123456789012345678901234567890123456789012345678901234567890}
# Code points at the UTF-8 length boundaries and around them (no surrogate,
# no quote or backslash, no control character).
set ::codePoints {32 48 65 97 122 126 160 233 255 256 0x7FF 0x800 0x2603 0xFFFD 0xFFFF 0x10000 0x1F642 0x10FFFF}

proc RandomInt {} {
    switch -- [Rand 3] {
        0 { return [Pick $::intEdges] }
        1 { return [expr {[Rand 2001] - 1000}] }
        default {
            set digits [expr {1 + [Rand 30]}]
            set n [expr {1 + [Rand 9]}]
            for {set i 1} {$i < $digits} {incr i} {
                append n [Rand 10]
            }
            return [expr {[Rand 2] ? $n : "-$n"}]
        }
    }
}

proc RandomText {} {
    set length [Pick {0 0 1 2 3 5 8 13 21 40 75}]
    set text ""
    for {set i 0} {$i < $length} {incr i} {
        if {[Rand 3] == 0} {
            append text [format %c [Pick $::codePoints]]
        } else {
            append text [string index "abcdefghijklmnopqrstuvwxyz ABCXYZ0123456789-_.:;!?" [Rand 50]]
        }
    }
    return $text
}

proc RandomFloat {} {
    # Dyadic, so the literal is exact and the oracle reads the same binary64.
    set whole [expr {[Rand 2000] - 1000}]
    set frac [Pick {0 5 25 125 0625 5 75}]
    return "$whole.$frac"
}

# A value of model TYPE: {EXPR JSON}.
proc Value {type structs enumCases {depth 0}} {
    switch -- [lindex $type 0] {
        int {
            set n [RandomInt]
            return [list $n "{\"int\": [Json $n]}"]
        }
        str {
            set t [RandomText]
            return [list "\"$t\"" "{\"str\": [Json $t]}"]
        }
        bool {
            set b [Pick {true false}]
            return [list $b "{\"bool\": $b}"]
        }
        char {
            set cp [Pick $::codePoints]
            return [list "'[format %c $cp]'" "{\"char\": [expr {$cp}]}"]
        }
        float {
            set f [RandomFloat]
            return [list $f "{\"float\": $f}"]
        }
        enum {
            set c [Pick $enumCases]
            return [list "Color::$c" "{\"enum\": \[\"Color\", \"$c\"\]}"]
        }
        struct {
            set name [lindex $type 1]
            set fields [dict get $structs $name]
            set exprs {}
            set jsons {}
            foreach {f t} $fields {
                lassign [Value $t $structs $enumCases [expr {$depth + 1}]] e j
                lappend exprs "$f: $e"
                lappend jsons "\[\"$f\", $j\]"
            }
            return [list "$name {[join [Shuffle $exprs] {, }]}" \
                "{\"struct\": {\"id\": \"$name\", \"fields\": \[[join $jsons {, }]\]}}"]
        }
        list {
            set n [Rand [expr {$depth > 1 ? 2 : 4}]]
            set exprs {}
            set jsons {}
            for {set i 0} {$i < $n} {incr i} {
                lassign [Value [lindex $type 1] $structs $enumCases [expr {$depth + 1}]] e j
                lappend exprs $e
                lappend jsons $j
            }
            if {$n == 0} {
                # (An empty literal's element type is never; the List of the
                # declared element type comes from a typed function.)
                return [list "empty_[ListName [lindex $type 1]]()" "{\"list\": \[\]}"]
            }
            return [list "\[[join $exprs {, }]\]" "{\"list\": \[[join $jsons {, }]\]}"]
        }
        set {
            set members [lsort -unique [lmap i {1 2 3 4} {expr {[Rand 21] - 10}}]]
            set members [lrange $members 0 [Rand [llength $members]]]
            return [list "immutable_set::from_list(\[[join [Shuffle $members] {, }]\])" \
                "{\"set\": \[[join [lmap m $members {string cat "{\"int\": \"$m\"}"}] {, }]\]}"]
        }
        anon {
            set names [lrange [Shuffle {a b c k z}] 0 [Rand 3]]
            set exprs {}
            set jsons {}
            foreach f $names {
                lassign [Value [Pick {int str bool char}] $structs $enumCases [expr {$depth + 1}]] e j
                lappend exprs "$f: $e"
                lappend jsons "\[\"$f\", $j\]"
            }
            return [list "{[join $exprs {, }]}" "{\"struct\": {\"id\": \"\", \"fields\": \[[join $jsons {, }]\]}}"]
        }
    }
    error "unknown model type $type"
}

proc ListName {t} {
    return [expr {[lindex $t 0] eq "struct" ? [lindex $t 1] : $t}]
}

proc TypeText {t} {
    switch -- [lindex $t 0] {
        int { return int }
        str { return str }
        bool { return bool }
        char { return UnicodeChar }
        float { return Float64 }
        enum { return Color }
        struct { return [lindex $t 1] }
        list { return "List\[[TypeText [lindex $t 1]]\]" }
        set { return "ImmutableSet\[int\]" }
    }
}

# Two different constructions of one value: {EXPR-A EXPR-B JSON}.
proc EqualPair {structs enumCases} {
    switch -- [Rand 6] {
        0 {
            set n [RandomInt]
            set k [expr {1 + [Rand 1000]}]
            return [list "($n - $k) + $k" $n "{\"int\": [Json $n]}"]
        }
        1 {
            set a [RandomText]
            set b [RandomText]
            return [list "str::concat(\"$a\", \"$b\")" "\"$a$b\"" "{\"str\": [Json $a$b]}"]
        }
        2 {
            set members [lsort -unique [lmap i {1 2 3 4 5} {expr {[Rand 41] - 20}}]]
            set dup [concat [Shuffle $members] [list [lindex $members 0]]]
            return [list "immutable_set::from_list(\[[join $members {, }]\])" \
                "immutable_set::from_list(\[[join $dup {, }]\])" \
                "{\"set\": \[[join [lmap m $members {string cat "{\"int\": \"$m\"}"}] {, }]\]}"]
        }
        3 {
            lassign [Value anon $structs $enumCases] e j
            # Another spelling of the same fields: reversed.
            set inner [string range $e 1 end-1]
            set parts [split [string map {", " \x01} $inner] \x01]
            return [list $e "{[join [lreverse $parts] {, }]}" $j]
        }
        4 {
            set name [Pick [dict keys $structs]]
            lassign [Value [list struct $name] $structs $enumCases] e j
            return [list $e $e $j]
        }
        default {
            set a [RandomFloat]
            set b [RandomFloat]
            set sum [expr {double($a) + double($b)}]
            return [list "$a + $b" [FloatLiteral $sum] "{\"float\": $sum}"]
        }
    }
}

proc FloatLiteral {x} {
    set text [format %.6f $x]
    regsub {0+$} $text "" text
    if {[string index $text end] eq "."} {
        append text 0
    }
    return $text
}

# ---------------------------------------------------------------------------
# Admission: the model's three-valued rule

# total | unknown | none for a probe field type.
proc FieldClass {t probes} {
    switch -- $t {
        fn - mutarray { return none }
        any { return unknown }
    }
    if {[lindex $t 0] eq "probe"} {
        return [dict get $probes [lindex $t 1] class]
    }
    return total
}

proc ProbeFieldText {t} {
    switch -- $t {
        fn { return "Fn{args: \[int\], return: int}" }
        mutarray { return "MutableArray\[int\]" }
        any { return any }
        int { return int }
        str { return str }
    }
    return [lindex $t 1]
}

proc ProbeFieldValue {t probes} {
    switch -- $t {
        fn { return twice }
        mutarray { return "mutable_array::create(1, 0)" }
        any { return [Pick {1 "\"s\"" {[1, 2]}}] }
        int { return [RandomInt] }
        str { return "\"[RandomText]\"" }
    }
    return [ProbeValue [lindex $t 1] $probes]
}

proc ProbeValue {name probes} {
    set fields [dict get $probes $name fields]
    return "$name {[join [lmap {f t} $fields {string cat "$f: [ProbeFieldValue $t $probes]"}] {, }]}"
}

# ---------------------------------------------------------------------------
# One program

proc Program {number} {
    set enumCases [Shuffle {Red Green Blue}]
    set structs [dict create]
    set decls "enum Color:\n[join [lmap c $enumCases {string cat "    $c,"}] \n]\n\n"
    set pool {int str bool char float enum {list int} {list str} set}
    for {set s 1} {$s <= 2 + [Rand 3]} {incr s} {
        set name S$s
        set fields {}
        set names [lrange [Shuffle {a b c d e f g}] 0 [Rand 4]]
        foreach f $names {
            dict set fields $f [Pick $pool]
        }
        dict set structs $name $fields
        append decls "struct $name:\n[join [lmap {f t} $fields {string cat "    $f: [TypeText $t]"}] \n]\n\n"
        lappend pool [list struct $name] [list list [list struct $name]]
    }
    foreach t $pool {
        if {[lindex $t 0] eq "list"} {
            append decls "fn empty_[ListName [lindex $t 1]]() -> [TypeText $t]:\n    \[\]\n\n"
        }
    }
    append decls "fn fingerprint(x: Hashable) -> int:\n    hash(x)\n\nfn twice(n: int) -> int:\n    n * 2\n\n"
    set observations {}
    set expected {}
    set jsons {}
    set kinds [concat $pool {anon anon}]
    for {set i 0} {$i < 8 + [Rand 9]} {incr i} {
        lassign [Value [Pick $kinds] $structs $enumCases] e j
        lappend observations "\[hash($e), hashfix::keyed($e), fingerprint($e) == hash($e), $e == $e\]"
        lappend expected [list value $j]
        lappend jsons $j
    }
    for {set i 0} {$i < 3 + [Rand 4]} {incr i} {
        lassign [EqualPair $structs $enumCases] a b j
        lappend observations "\[$a == $b, hash($a) == hash($b), hashfix::keyed($a) == hashfix::keyed($b), hashfix::keyed($a)\]"
        lappend expected [list pair $j]
        lappend jsons $j
    }
    set text "import hashfix\nimport str\nimport immutable_set\nimport mutable_array\n\n$decls\[\n    [join $observations ",\n    "]\n\]\n"
    # Admission probes.
    set probes [dict create]
    foreach k {1 2} {
        set name Probe$k
        set fields [dict create n int]
        if {$k == 2 && [Rand 2]} {
            dict set fields inner [list probe Probe1]
        } else {
            dict set fields odd [Pick {fn mutarray any int str}]
        }
        set class total
        foreach {f t} $fields {
            set c [FieldClass $t $probes]
            if {$c eq "none" || ($c eq "unknown" && $class eq "total")} {
                set class $c
            }
        }
        dict set probes $name [dict create fields $fields class $class]
    }
    set probeDecls ""
    dict for {name p} $probes {
        append probeDecls "struct $name:\n[join [lmap {f t} [dict get $p fields] {string cat "    $f: [ProbeFieldText $t]"}] \n]\n\n"
    }
    return [list $text $expected $jsons $probes $probeDecls]
}

# The program's observations as Tcl lists of words.
proc Observed {value} {
    return [lindex [string map {, "" [ "{" ] "}"} $value] 0]
}

proc Oracle {jsons key} {
    set out [exec python3 -I [file join $::root audit hashable tools oracle.py] hash {*}$key << [join $jsons \n]]
    return [split $out \n]
}

proc Probe {probes probeDecls site name} {
    set value [ProbeValue $name $probes]
    set call [dict get {param "fingerprint(%s)" table "hashfix::keyed(%s)" public "hash(%s)"} $site]
    set text "import hashfix\nimport mutable_array\n\nfn fingerprint(x: Hashable) -> int:\n    hash(x)\n\nfn twice(n: int) -> int:\n    n * 2\n\n$probeDecls[format $call $value]\n"
    set class [dict get $probes $name class]
    set accept [expr {$site eq "public" ? $class ne "none" : $class eq "total"}]
    if {[catch {surface::compile $text t.bot -warnings off} hir options]} {
        set kind [lindex [dict get [lindex [dict getdef $options -diagnostics [list [dict create errorcode [dict get $options -errorcode]]]] 0] errorcode] end]
        if {$accept} {
            return "probe $site $name ($class) rejected with $kind, the model accepts it\n$text"
        }
        if {$kind ne "TRAIT-NOT-SATISFIED"} {
            return "probe $site $name ($class) rejected with $kind, the model predicts TRAIT-NOT-SATISFIED\n$text"
        }
        return ""
    }
    if {!$accept} {
        return "probe $site $name ($class) accepted, the model rejects it\n$text"
    }
    if {$site eq "public" && $class eq "unknown"} {
        # A dynamic hash: it runs, and agrees on every backend.
        set outcomes [lmap b $::backends {lrange [outcomeUnderHir $b $hir] 0 1}]
        if {[llength [lsort -unique $outcomes]] != 1 || [lindex $outcomes 0 0] ne "value"} {
            return "probe $site $name ($class): backends give $outcomes\n$text"
        }
    }
    return ""
}

proc Run {} {
    global options seedState
    set seedState [dict get $options -seed]
    set ::backends [dict get $options -backends]
    set disagreements 0
    set values 0
    set pairs 0
    set probes 0
    for {set number 1} {$number <= [dict get $options -n]} {incr number} {
        set key [list [expr {$seedState * 2654435761 % 18446744073709551616}] [expr {($number * 40503 + $seedState) % 18446744073709551616}]]
        lassign [Program $number] text expected jsons probeSet probeDecls
        if {[dict get $options -dump]} {
            puts "--- program $number\n$text"
        }
        set problems {}
        set oracle [Oracle $jsons $key]
        set want {}
        foreach e $expected line $oracle {
            lassign $line public table
            if {[lindex $e 0] eq "value"} {
                lappend want [list $public $table true true]
                incr values
            } else {
                lappend want [list true true true $table]
                incr pairs
            }
        }
        if {[catch {surface::compile $text t.bot -warnings off} hir]} {
            lappend problems "the program does not compile: $hir"
        } else {
            core::hashing::useTableHashKey $key
            try {
                foreach b $::backends {
                    set o [lrange [outcomeUnderHir $b $hir] 0 1]
                    if {[lindex $o 0] ne "value" || [Observed [lindex $o 1]] ne $want} {
                        lappend problems "$b gives $o, the model [list $want]"
                    }
                }
                if {[dict get $options -gc-stress]} {
                    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                    try {
                        set o [lrange [outcomeUnderHir cranelift $hir] 0 1]
                    } finally {
                        unset ::env(BOTLISH_NATIVE_GC_STRESS)
                    }
                    if {[lindex $o 0] ne "value" || [Observed [lindex $o 1]] ne $want} {
                        lappend problems "cranelift under GC stress gives $o, the model [list $want]"
                    }
                }
            } finally {
                core::hashing::useTableHashKey ""
            }
        }
        foreach name [dict keys $probeSet] {
            foreach site {param table public} {
                incr probes
                set p [Probe $probeSet $probeDecls $site $name]
                if {$p ne ""} {
                    lappend problems $p
                }
            }
        }
        if {$problems ne {}} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n[join $problems \n]\n--- program\n$text"
        }
    }
    puts "values $values pairs $pairs probes $probes"
    puts "programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

try {
    set status [Run]
} finally {
    file delete -force $::fuzzLibrary
}
exit [expr {$status > 0 ? 1 : 0}]
