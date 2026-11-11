#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated payload-enum programs against an independent model
# (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md).
#
#   tclsh9.0 audit/payload-enums/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                              ?-backends LIST? ?-gc-stress 0|1?
#
# Each program declares two or three enums whose case and field names
# overlap in spelling (several enums have a case `Car`, several cases a
# field `x`), each enum's cases and each payload's fields declared in a
# random order, some cases payload-free and some carrying one to three
# fields of type int, str, bool, List[int], a struct P, or an earlier enum
# (nesting) -- and, every other program, the module enum `std::fz::Mode` (written
# into a private library), whose identity differs from a same-spelled local
# one. A driver `drive(zero)` runs 6..16 operations whose result is a List of
# observations:
#
#   make     a construction E::C {f: v, ...}, its fields written in a random
#            order (a payload-free case written E::C)
#   same     a generic identity, same(x)
#   typed    a function typed on the value's enum, id_E(x)
#   erase    a function through any, erase(x)
#   hold     a struct field: Hold_E {v: x}.v
#   capture  a closure capturing the value
#   listed   a List of the value, read back by a loop
#
# and the observations: a value itself (its rendering), `==` and `!=` of two
# values (of one enum or of two; two values statically of one enum half the
# time through its typed identity, so a backend may decide the comparison by
# the static type), `hash(a) == hash(b)`, membership in an ImmutableSet of
# two values.
#
# The model shares no code with the compiler or a runtime: a case value is
# the triple (NominalEnumIdentity, CaseIdentity, PayloadFields) -- the
# enum's declared identity (`Shape`, `fz::Mode`), the case's declared name,
# and the payload as a map from field name to a model value (none for a
# payload-free case). Equality is equality of the triple, the payload
# compared field by field by name (so neither the declaration nor the
# construction order takes part); every transport keeps the triple. Hashes
# are compared, never predicted: equal triples must hash equal, unequal ones
# unequal (a collision of the 61-bit hash would be reported). A value
# renders as `Enum::Case` or `Enum::Case {f: v, ...}`, its fields in sorted
# order.
#
# A third of the programs carry one fault with the diagnostic the model
# predicts: a missing, unknown or duplicate payload field, a field value of
# another type (TYPE), braces after a payload-free case
# (ENUM-PAYLOAD-UNEXPECTED), a payload-bearing case without its payload
# (ENUM-PAYLOAD-REQUIRED), an unknown case (UNKNOWN-ENUM-CASE), a value of
# another enum passed to a typed function (TYPE), a duplicate field in a
# declaration (DUPLICATE-FIELD), and -- the affine subset -- a construction
# holding a coroutine handle used twice (USE-AFTER-MOVE) or compared
# (AFFINE-EQUALITY-UNSUPPORTED). Every fifth program is an affine one whose
# coroutine-carrying values are made, moved through a function and dropped:
# it must compile and run on every backend.
#
# Every accepted program's value is compared on every backend of BACKENDS
# with the model's; with -gc-stress 1, the native run again with a
# collection at every allocation site.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 40 -seed 1 -dump 0 -backends {interp compile cranelift-generic cranelift} -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "fuzz.tcl: unknown option $option"
    }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]

# A private library: the standard one plus the module fz.
set ::fuzzLibrary [file tempdir botlish-payload-enum-fuzz]
foreach entry [glob -nocomplain -directory $::core::libraryDir *] {
    file copy -force $entry $::fuzzLibrary
}
set ::core::libraryDir $::fuzzLibrary
set channel [open [file join $::fuzzLibrary fz.bot] w]
# (A module of the private standard library is std::fz.)
fconfigure $channel -encoding utf-8 -translation lf
puts -nonewline $channel {enum Mode:
    Car {n: int, s: str},
    Off,
    On {n: int},
}
close $channel
# The module enum, for the model: its identity, cases and payloads.
set ::moduleEnum [dict create id std::fz::Mode cases {Car Off On} \
    fields [dict create Car {n int s str} Off {} On {n int}]]

# ---------------------------------------------------------------------------
# Deterministic choices

proc Rand {n} {
    global seedState
    set seedState [expr {($seedState * 1103515245 + 12345) % 2147483648}]
    return [expr {($seedState >> 8) % $n}]
}

proc Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

proc Shuffle {list} {
    set result {}
    while {[llength $list]} {
        set i [Rand [llength $list]]
        lappend result [lindex $list $i]
        set list [lreplace $list $i $i]
    }
    return $result
}

# ---------------------------------------------------------------------------
# The model: values and their rendering

# Model values: {int N}, {str S}, {bool B}, {list V...}, {P N} (struct P),
# {enum ID CASE FIELDS} (FIELDS a dict FIELD -> model value; "" for a
# payload-free case).

proc Render {v} {
    switch -- [lindex $v 0] {
        int { return [lindex $v 1] }
        str { return "\"[lindex $v 1]\"" }
        bool { return [lindex $v 1] }
        list { return "\[[join [lmap x [lrange $v 1 end] {Render $x}] {, }]\]" }
        P { return "P {x: [lindex $v 1]}" }
        enum {
            lassign $v - id case fields
            if {$fields eq ""} {
                return "${id}::$case"
            }
            set parts [lmap f [lsort [dict keys $fields]] {string cat $f ": " [Render [dict get $fields $f]]}]
            return "${id}::$case {[join $parts {, }]}"
        }
    }
    error "Render: $v"
}

proc Equal {a b} {
    if {[lindex $a 0] ne [lindex $b 0]} {
        return 0
    }
    switch -- [lindex $a 0] {
        list {
            if {[llength $a] != [llength $b]} {
                return 0
            }
            foreach x [lrange $a 1 end] y [lrange $b 1 end] {
                if {![Equal $x $y]} {
                    return 0
                }
            }
            return 1
        }
        enum {
            lassign $a - ida casea fa
            lassign $b - idb caseb fb
            if {$ida ne $idb || $casea ne $caseb || [dict size $fa] != [dict size $fb]} {
                return 0
            }
            foreach f [dict keys $fa] {
                if {![dict exists $fb $f] || ![Equal [dict get $fa $f] [dict get $fb $f]]} {
                    return 0
                }
            }
            return 1
        }
    }
    return [expr {$a eq $b}]
}

# ---------------------------------------------------------------------------
# Programs

set ::enumNames {Shape Token Node Signal}
set ::caseNames {A Car Red On Leaf Off Big}
set ::fieldNames {x y value left right tag n}

# {ID {cases {C ...} fields {C {F TYPE ...} ...}} ...}: two or three local
# enums, each case payload-free or carrying fields of the field types (an
# earlier enum's type among them), cases and fields in a random order.
proc Enums {} {
    set count [expr {2 + [Rand 2]}]
    set enums {}
    foreach name [lrange [Shuffle $::enumNames] 0 [expr {$count - 1}]] {
        set cases [lrange [Shuffle $::caseNames] 0 [expr {1 + [Rand 3]}]]
        set fields [dict create]
        set earlier [dict keys $enums]
        foreach case $cases {
            if {[Rand 5] < 2} {
                dict set fields $case {}
                continue
            }
            set types {}
            foreach f [lrange [Shuffle $::fieldNames] 0 [Rand 3]] {
                set choices {int int str bool list P}
                if {$earlier ne {}} {
                    lappend choices [Pick $earlier]
                }
                lappend types $f [Pick $choices]
            }
            dict set fields $case $types
        }
        dict set enums $name [dict create cases $cases fields $fields]
    }
    return $enums
}

proc TypeText {type} {
    switch -- $type {
        list { return "List\[int\]" }
        default { return $type }
    }
}

proc Declarations {enums faultDecl} {
    set text "struct P:\n    x: int\n\n"
    dict for {id e} $enums {
        append text "enum $id:\n"
        set lines {}
        foreach case [dict get $e cases] {
            set types [dict get $e fields $case]
            if {$types eq {}} {
                lappend lines "    $case,"
                continue
            }
            set parts {}
            foreach {f t} $types {
                lappend parts "$f: [TypeText $t]"
            }
            set parts [Shuffle $parts]
            if {$faultDecl eq "duplicate-field" && [llength $parts] > 0 && ![info exists ::declFaultDone]} {
                lappend parts [lindex $parts 0]
                set ::declFaultDone 1
            }
            lappend lines "    $case {[join $parts {, }]},"
        }
        append text [join [Shuffle $lines] \n] \n\n
        append text "fn id_$id\(v: $id) -> $id:\n    v\n\nstruct Hold_$id:\n    v: $id\n\n"
    }
    append text "fn same(v):\n    v\n\nfn erase(v: any) -> any:\n    v\n\n"
    return $text
}

# {TEXT MODEL}: a value of field type TYPE (DEPTH levels of nesting left).
proc FieldValue {state type depth} {
    switch -- $type {
        int {
            set n [expr {[Rand 4] - 1}]
            return [list $n [list int $n]]
        }
        str {
            set s [Pick {a b ab}]
            return [list "\"$s\"" [list str $s]]
        }
        bool {
            set b [Pick {true false}]
            return [list $b [list bool $b]]
        }
        list {
            set items {}
            set models {}
            for {set i 0} {$i < [Rand 3]} {incr i} {
                set n [Rand 3]
                lappend items $n
                lappend models [list int $n]
            }
            return [list "\[[join $items {, }]\]" [list list {*}$models]]
        }
        P {
            set n [Rand 3]
            return [list "P {x: $n}" [list P $n]]
        }
        default {
            return [Construction $state $type $depth]
        }
    }
}

# The enum descriptor {cases ... fields ...} of identity ID in STATE.
proc EnumOf {state id} {
    if {$id eq "std::fz::Mode"} {
        return $::moduleEnum
    }
    return [dict get $state enums $id]
}

# {TEXT MODEL}: a construction of a random case of enum ID, its fields in a
# random written order.
proc Construction {state id depth {case ""}} {
    set e [EnumOf $state $id]
    if {$case eq ""} {
        set case [Pick [dict get $e cases]]
    }
    set types [dict get $e fields $case]
    if {$types eq {}} {
        return [list "${id}::$case" [list enum $id $case ""]]
    }
    set fields [dict create]
    set written {}
    foreach {f t} $types {
        if {$depth <= 0 && [lsearch -exact {int str bool list P} $t] < 0} {
            # Too deep: still a value of T, the simplest one there is.
            lassign [Construction $state $t 0 [Simplest $state $t]] text model
        } else {
            lassign [FieldValue $state $t [expr {$depth - 1}]] text model
        }
        dict set fields $f $model
        lappend written "$f: $text"
    }
    return [list "${id}::$case {[join [Shuffle $written] {, }]}" [list enum $id $case $fields]]
}

# A case of enum ID whose payload names no enum (else the first case).
proc Simplest {state id} {
    set e [EnumOf $state $id]
    foreach case [dict get $e cases] {
        set ok 1
        foreach {f t} [dict get $e fields $case] {
            if {[lsearch -exact {int str bool list P} $t] < 0} {
                set ok 0
            }
        }
        if {$ok} {
            return $case
        }
    }
    return [lindex [dict get $e cases] 0]
}

proc Emit {stateVar line} {
    upvar 1 $stateVar state
    dict lappend state lines $line
}

proc Fresh {stateVar} {
    upvar 1 $stateVar state
    dict incr state n
    return "v[dict get $state n]"
}

proc Observe {stateVar expr model} {
    upvar 1 $stateVar state
    dict lappend state observed $expr
    dict lappend state expected $model
}

proc EnumIds {state} {
    set ids [dict keys [dict get $state enums]]
    if {[dict get $state module]} {
        lappend ids std::fz::Mode
    }
    return $ids
}

# One operation of the driver: a new binding, and sometimes an observation.
proc Operation {stateVar} {
    upvar 1 $stateVar state
    set vars [dict get $state vars]
    set op [Pick {make make make same typed erase hold capture listed}]
    if {$vars eq {}} {
        set op make
    }
    set name [Fresh state]
    if {$op eq "make"} {
        set id [Pick [EnumIds $state]]
        lassign [Construction $state $id 2] text model
        Emit state "$name = $text"
        dict set state vars $name [list $model $id]
    } else {
        set from [Pick [dict keys $vars]]
        lassign [dict get $vars $from] model id
        # (ID is the value's static enum type, "" once it is erased or in a
        # List: a typed function or field of an enum takes only a value
        # statically of it.)
        switch -- $op {
            same { Emit state "$name = same($from)" }
            typed {
                if {$id eq "std::fz::Mode" || $id eq ""} {
                    Emit state "$name = same($from)"
                } else {
                    Emit state "$name = id_$id\($from)"
                }
            }
            erase {
                Emit state "$name = erase($from)"
                set id ""
            }
            hold {
                if {$id eq "std::fz::Mode" || $id eq ""} {
                    Emit state "$name = same($from)"
                } else {
                    Emit state "$name = Hold_$id {v: $from}.v"
                }
            }
            capture {
                Emit state "fn get_$name\():"
                Emit state "    $from"
                Emit state "$name = get_$name\()"
            }
            listed {
                Emit state "${name}s = loop item in \[$from, $from\]:"
                Emit state "    item"
                Emit state "$name = same(${name}s)"
                set model [list list $model $model]
                set id ""
            }
        }
        dict set state vars $name [list $model $id]
    }
    # An observation, most of the time.
    set vars [dict get $state vars]
    set a [Pick [dict keys $vars]]
    set b [Pick [dict keys $vars]]
    lassign [dict get $vars $a] ma ida
    lassign [dict get $vars $b] mb idb
    set equal [Equal $ma $mb]
    # Two values statically of one enum are compared, half the time, as
    # that enum's (through its typed identity): the comparison a backend
    # may lower by the static type (natively, the word compare of a
    # payload-free enum's values only).
    set ea $a
    set eb $b
    if {$ida ne "" && $ida eq $idb && $ida ne "std::fz::Mode" && [Rand 2]} {
        set ea "id_$ida\($a)"
        set eb "id_$ida\($b)"
    }
    switch -- [Rand 5] {
        0 { Observe state $a $ma }
        1 { Observe state "$ea == $eb" [list bool [expr {$equal ? "true" : "false"}]] }
        2 { Observe state "$ea != $eb" [list bool [expr {$equal ? "false" : "true"}]] }
        3 { Observe state "hash($a) == hash($b)" [list bool [expr {$equal ? "true" : "false"}]] }
        4 {
            set c [Pick [dict keys $vars]]
            lassign [dict get $vars $c] mc
            set member [expr {[Equal $mc $ma] || [Equal $mc $mb]}]
            Observe state "std::immutable_set::contains(std::immutable_set::from_list(\[$a, $b\]), $c)" \
                [list bool [expr {$member ? "true" : "false"}]]
        }
    }
}

# {CODE LINE DECLFAULT}: a fault whose diagnostic code the model predicts.
proc Fault {stateVar} {
    upvar 1 $stateVar state
    set ids [dict keys [dict get $state enums]]
    set id [Pick $ids]
    set e [dict get $state enums $id]
    set bearing {}
    set free {}
    foreach case [dict get $e cases] {
        if {[dict get $e fields $case] eq {}} {
            lappend free $case
        } else {
            lappend bearing $case
        }
    }
    set kinds {unknown-case wrong-enum}
    if {$bearing ne {}} {
        lappend kinds missing-field unknown-field duplicate-field wrong-type required duplicate-decl
    }
    if {$free ne {}} {
        lappend kinds unexpected
    }
    set kind [Pick $kinds]
    switch -- $kind {
        unknown-case {
            return [list UNKNOWN-ENUM-CASE "f = ${id}::Nowhere {x: 1}" ""]
        }
        wrong-enum {
            set other [Pick [lsearch -all -inline -not -exact [EnumIds $state] $id]]
            if {$other eq ""} {
                return [list TYPE "f = id_$id\(1)" ""]
            }
            lassign [Construction $state $other 1] text
            return [list TYPE "f = id_$id\($text)" ""]
        }
        unexpected {
            return [list ENUM-PAYLOAD-UNEXPECTED "f = ${id}::[Pick $free] {x: 1}" ""]
        }
        required {
            return [list ENUM-PAYLOAD-REQUIRED "f = ${id}::[Pick $bearing]" ""]
        }
        duplicate-decl {
            return [list DUPLICATE-FIELD "f = 1" duplicate-field]
        }
    }
    set case [Pick $bearing]
    set types [dict get $e fields $case]
    set parts {}
    foreach {f t} $types {
        lappend parts [list $f [lindex [FieldValue $state $t 0] 0] $t]
    }
    switch -- $kind {
        missing-field {
            set parts [lrange $parts 1 end]
            set code MISSING-FIELD
        }
        unknown-field {
            lappend parts [list nowhere 1 int]
            set code UNKNOWN-FIELD
        }
        duplicate-field {
            lappend parts [lindex $parts 0]
            set code DUPLICATE-FIELD
        }
        wrong-type {
            lassign [lindex $parts 0] f v t
            set wrong [expr {$t eq "str" ? "1" : "\"wrong\""}]
            lset parts 0 [list $f $wrong $t]
            set code TYPE
        }
    }
    set text "f = ${id}::$case {[join [lmap p $parts {string cat [lindex $p 0] ": " [lindex $p 1]}] {, }]}"
    return [list $code $text ""]
}

# {TEXT EXPECT}: program NUMBER and the model's expectation.
proc Program {number} {
    unset -nocomplain ::declFaultDone
    if {$number % 5 == 4} {
        return [AffineProgram]
    }
    set state [dict create vars {} module [expr {$number % 2}] lines {} observed {} expected {} n 0]
    dict set state enums [Enums]
    set count [expr {6 + [Rand 11]}]
    for {set i 0} {$i < $count} {incr i} {
        Operation state
    }
    set code ""
    set decl ""
    if {[Rand 3] == 0} {
        lassign [Fault state] code line decl
        Emit state $line
    }
    set header "import std::immutable_set\n"
    if {[dict get $state module]} {
        append header "import std::fz\n"
    }
    set body [join [lmap line [dict get $state lines] {string cat "    " $line}] \n]
    set result "\[[join [dict get $state observed] {, }]\]"
    set text "$header\n[Declarations [dict get $state enums] $decl]fn drive(zero: int):\n$body\n    $result\n\ndrive(0)\n"
    if {$code eq ""} {
        set expect [list value [Render [list list {*}[dict get $state expected]]]]
    } else {
        set expect [list error $code]
    }
    return [list $text $expect]
}

# {TEXT EXPECT}: an affine program -- a payload holding a coroutine handle --
# valid (the values made, moved through a typed function and dropped: it
# runs to its String on every backend) or carrying an affine fault.
proc AffineProgram {} {
    set decls "import std::coroutine\n\nstruct Message:\n    value: int\n\nfn worker(seed: int, resume Message) -> int:\n    m = yield seed\n    m.value\n\nfn make(seed: int) -> Coroutine{args: \[Message\], return: int}:\n    coroutine {step} = worker(seed)\n    step\n\n"
    set cases [Shuffle [list "Idle," "Run {task: Coroutine{args: \[Message\], return: int}, n: int}," "Two {[join [Shuffle [list {a: Coroutine{args: [Message], return: int}} {b: Coroutine{args: [Message], return: int}}]] {, }]},"]]
    append decls "enum Job:\n    [join $cases "\n    "]\n\nfn keep(j: Job) -> Job:\n    j\n\n"
    set lines {}
    set n [expr {1 + [Rand 4]}]
    for {set i 0} {$i < $n} {incr i} {
        switch -- [Rand 3] {
            0 { lappend lines "j$i = keep(Job::Run {n: $i, task: make($i)})" }
            1 { lappend lines "j$i = keep(Job::Two {b: make($i), a: make([expr {$i + 10}])})" }
            2 { lappend lines "j$i = keep(Job::Idle)" }
        }
    }
    set expect [list value "\"done\""]
    switch -- [Rand 3] {
        0 {
            lappend lines "k = j0" "l = j0"
            set expect {error USE-AFTER-MOVE}
        }
        1 {
            lappend lines "c = j0 == j0"
            set expect {error AFFINE-EQUALITY-UNSUPPORTED}
        }
    }
    set body [join [lmap line $lines {string cat "    " $line}] \n]
    return [list "${decls}fn drive(zero: int) -> str:\n$body\n    \"done\"\n\ndrive(0)\n" $expect]
}

proc FailureKind {errorcode message} {
    if {[lrange $errorcode 0 1] eq {SURFACE SYNTAX}} {
        set d [lindex $errorcode 2]
        return [expr {[dict exists $d code] ? [dict get $d code] : "SYNTAX"}]
    }
    return [lindex $errorcode end]
}

proc Run {} {
    global options
    set backends [dict get $options -backends]
    set accepted 0
    set rejected 0
    set codes [dict create]
    set disagreements 0
    set observations 0
    for {set p 0} {$p < [dict get $options -n]} {incr p} {
        set number [expr {[dict get $options -seed] + $p}]
        set ::seedState [expr {$number * 7919 + 17}]
        lassign [Program $number] text expect
        if {[dict get $options -dump]} {
            puts "--- program $number\n$text--- expect $expect"
        }
        set problem ""
        if {[catch {surface::compile $text -warnings off} hir errOptions]} {
            set got [list error [FailureKind [dict get $errOptions -errorcode] $hir]]
            if {$got ne $expect} {
                set problem "rejected [lindex $got 1]: $hir\nmodel expects $expect"
            } else {
                incr rejected
                dict incr codes [lindex $got 1]
            }
        } elseif {[lindex $expect 0] eq "error"} {
            set problem "accepted; model expects [lindex $expect 1]"
        } else {
            foreach b $backends {
                set o [lrange [outcomeUnderHir $b $hir] 0 1]
                if {$o ne $expect} {
                    set problem "$b gives $o, model $expect"
                    break
                }
            }
            set nativeOk [expr {$::tcl_platform(os) eq "Linux" && $::tcl_platform(machine) in {x86_64 amd64 aarch64}}]
            if {$problem eq "" && [dict get $options -gc-stress] && $nativeOk} {
                set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                try {
                    set o [lrange [outcomeUnderHir cranelift $hir] 0 1]
                } finally {
                    unset ::env(BOTLISH_NATIVE_GC_STRESS)
                }
                if {$o ne $expect} {
                    set problem "cranelift under GC stress gives $o, model $expect"
                }
            }
            if {$problem eq ""} {
                incr accepted
                incr observations [regexp -all {, } [lindex $expect 1]]
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n$problem\n--- program\n$text"
        }
    }
    puts "accepted $accepted rejected $rejected ([join [lmap {c n} [lsort -stride 2 [dict get $codes]] {string cat "$c $n"}] {, }]) observations $observations"
    puts "programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

try {
    set status [Run]
} finally {
    file delete -force $::fuzzLibrary
}
exit [expr {$status > 0 ? 1 : 0}]
