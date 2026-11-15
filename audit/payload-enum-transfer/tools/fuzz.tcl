#!/usr/bin/env tclsh9.0
# fuzz.tcl -- differential fuzzing of payload-bearing enum transfer
# (PORTABILITY-PAYLOAD-ENUM-TRANSFER-MILESTONE-1.md, "Independent oracle and
# fuzzing") against the independent model oracle.py (beside this script).
#
#   tclsh9.0 audit/payload-enum-transfer/tools/fuzz.tcl ?-seeds 1-5?
#       ?-cases N? ?-mutations M? ?-backends "interp compile ..."?
#       ?-gc-stress 0|1? ?-keep DIR?
#
# Per seed it generates declarations -- enums sharing case names, cases
# payload-free and payload-bearing, payload fields of scalars, Lists, other
# enums and the enum itself (recursion through a List or directly), structs
# holding enums, and now and then a field no value of which is sendable (a
# function, `any`) -- then typed values, and checks:
#
#   1. Sendable: hir::types::SendClass of every declared type, against the
#      oracle's prediction (total, none, unknown).
#   2. Bytes: a sender program encodes every value on every backend; each
#      backend's bytes must equal the oracle's (canonical schema text,
#      fingerprint and value encoding, written independently).
#   3. Decoding: a receiver program compiled from the same declarations
#      with every enum's cases and every payload's fields in another order,
#      unrelated declarations before them (other native enum and shape
#      numbers), decodes the oracle's bytes on every backend: each value
#      must decode, equal the receiver's own construction of it, and
#      re-encode to the same bytes.
#   4. Refusals: M mutations of each encoding (a byte replaced, the bytes
#      cut short, a byte appended, the case index forged, a header byte
#      changed) are decoded on every backend: each outcome -- a value or the
#      declared refusal -- must be the oracle's.
#
# A disagreement prints the seed, the check and both sides, and the
# counterexample's programs are kept under -keep (default: a directory per
# seed under the scratch directory it prints). Exit status 1 on any
# disagreement.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -seeds 1-5 -cases 8 -mutations 12 -backends "" -gc-stress 0 -keep ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set argv {}
set argc 0
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
set oracle [file join [file dirname [file normalize [info script]]] oracle.py]

if {[dict get $options -backends] eq ""} {
    if {[catch {native::binary}]} {
        dict set options -backends {interp compile}
    } else {
        dict set options -backends {interp compile cranelift-generic cranelift}
    }
}
if {[dict get $options -gc-stress]} {
    set env(BOTLISH_NATIVE_GC_STRESS) 1
}
set keep [dict get $options -keep]
if {$keep eq ""} {
    set keep [file tempdir botlish-pet-fuzz]
}
file mkdir $keep

# ---------------------------------------------------------------------------
# A deterministic generator (xorshift64*)

proc rng {seed} {
    set ::state [expr {($seed * 2654435761 + 88172645463325252) & 0xffffffffffffffff}]
    if {$::state == 0} { set ::state 1 }
}
proc next {} {
    set x $::state
    set x [expr {$x ^ (($x << 13) & 0xffffffffffffffff)}]
    set x [expr {$x ^ ($x >> 7)}]
    set x [expr {$x ^ (($x << 17) & 0xffffffffffffffff)}]
    set ::state $x
    return [expr {($x * 2685821657736338717) & 0xffffffffffffffff}]
}
proc below {n} { return [expr {[next] % $n}] }
proc pick {xs} { return [lindex $xs [below [llength $xs]]] }
proc chance {percent} { return [expr {[below 100] < $percent}] }
proc shuffled {xs} {
    set xs [list {*}$xs]
    for {set i [expr {[llength $xs] - 1}]} {$i > 0} {incr i -1} {
        set j [below [expr {$i + 1}]]
        set t [lindex $xs $i]
        lset xs $i [lindex $xs $j]
        lset xs $j $t
    }
    return $xs
}

# ---------------------------------------------------------------------------
# Declarations: ENUMS {NAME {CASE FIELDS ...}} (FIELDS "" payload-free, else
# {FIELD TYPE ...}), in declaration order; STRUCTS {NAME {FIELD TYPE ...}}.

set casePool {Alpha Beta Gamma Delta Ping Stop Leaf Node}
set fieldPool {a b x value items next label n}

proc genDecls {} {
    global casePool fieldPool
    set count [expr {2 + [below 3]}]
    set enums {}
    set names [lmap i [lseq $count] {string cat E$i}]
    for {set i 0} {$i < $count} {incr i} {
        set name [lindex $names $i]
        set cases [lrange [shuffled $casePool] 0 [expr {1 + [below 4]}]]
        set body {}
        set k 0
        foreach c $cases {
            if {$k > 0 && [chance 30]} {
                lappend body $c ""
            } else {
                set fields {}
                foreach f [lrange [shuffled $fieldPool] 0 [below 3]] {
                    lappend fields $f [genFieldType $i $names [expr {$k == 0}]]
                }
                lappend body $c $fields
            }
            incr k
        }
        lappend enums $name $body
    }
    set structs [dict create S0 [list tag str e [lindex $names 0] es "List\[[lindex $names end]\]"]]
    return [list $enums $structs]
}

# A payload field type of enum number I among NAMES; BASE: a field of the
# enum's first case, which must have finite values (no recursion into an
# enum not yet finished).
proc genFieldType {i names base} {
    set roll [below 100]
    if {$roll < 25} { return int }
    if {$roll < 40} { return str }
    if {$roll < 48} { return bool }
    if {$roll < 58} { return List\[int\] }
    if {$roll < 64} { return List\[str\] }
    if {$base} {
        # Only enums declared before: their values are finite.
        if {$i > 0 && $roll < 82} {
            return [lindex $names [below $i]]
        }
        return int
    }
    if {$roll < 74} {
        return "List\[[pick $names]\]"
    }
    if {$roll < 86} {
        return [lindex $names [below [expr {$i + 1}]]]
    }
    return "List\[[lindex $names $i]\]"
}

proc fieldsOf {enums name case} {
    return [dict get [dict get $enums $name] $case]
}

# ---------------------------------------------------------------------------
# Values: a value is {int N} | {str TEXT} | {bool 0|1} | {list ITEMS} |
# {enum NAME CASE FIELDS} (FIELDS a dict, "" payload-free) |
# {struct NAME FIELDS}.

set textPool {"" a xy "hé" "😀" "a b" "multi word" "ünïcödé" "0"}

proc genValue {decls type depth} {
    lassign $decls enums structs
    if {[string match List\\\[*\\\] $type]} {
        set elem [string range $type 5 end-1]
        set n [expr {$depth > 2 ? 0 : [below 4]}]
        return [list list [lmap i [lseq $n] {genValue $decls $elem [expr {$depth + 1}]}]]
    }
    switch -- $type {
        int {
            set r [below 10]
            if {$r < 3} { return [list int [expr {[below 300] - 150}]] }
            if {$r < 5} { return [list int [expr {[below 70000] - 35000}]] }
            if {$r < 7} { return [list int [expr {[next] - 9223372036854775808}]] }
            if {$r < 8} { return [list int [expr {-([next] * [next] * 7 + 1)}]] }
            return [list int [pick {0 1 -1 127 128 -128 -129 255 256 4611686018427387904 -4611686018427387905 9223372036854775807 -9223372036854775808}]]
        }
        str { return [list str [pick $::textPool]] }
        bool { return [list bool [below 2]] }
    }
    if {[dict exists $structs $type]} {
        set fields [dict create]
        foreach {f t} [dict get $structs $type] {
            dict set fields $f [genValue $decls $t [expr {$depth + 1}]]
        }
        return [list struct $type $fields]
    }
    set cases [dict keys [dict get $enums $type]]
    # Deep: the first case (finite by construction); else any.
    set c [expr {$depth > 2 ? [lindex $cases 0] : [pick $cases]}]
    set fieldTypes [dict get [dict get $enums $type] $c]
    if {$fieldTypes eq ""} {
        return [list enum $type $c ""]
    }
    set fields [dict create]
    foreach {f t} $fieldTypes {
        dict set fields $f [genValue $decls $t [expr {$depth + 1}]]
    }
    return [list enum $type $c $fields]
}

# The value's Botlish source (fields in a shuffled order).
proc source {v} {
    switch -- [lindex $v 0] {
        int { return [lindex $v 1] }
        str { return "\"[lindex $v 1]\"" }
        bool { return [expr {[lindex $v 1] ? "true" : "false"}] }
        list { return "\[[join [lmap x [lindex $v 1] {source $x}] {, }]\]" }
        enum {
            lassign $v kind name c fields
            if {$fields eq ""} {
                return "${name}::$c"
            }
            set parts {}
            foreach f [shuffled [dict keys $fields]] {
                lappend parts "$f: [source [dict get $fields $f]]"
            }
            return "${name}::$c {[join $parts {, }]}"
        }
        struct {
            lassign $v kind name fields
            set parts {}
            foreach f [shuffled [dict keys $fields]] {
                lappend parts "$f: [source [dict get $fields $f]]"
            }
            return "$name {[join $parts {, }]}"
        }
    }
}

# ---------------------------------------------------------------------------
# JSON for the oracle

proc jstr {s} {
    set out "\""
    foreach ch [split $s ""] {
        switch -- $ch {
            "\"" { append out "\\\"" }
            "\\" { append out "\\\\" }
            "\n" { append out "\\n" }
            default { append out $ch }
        }
    }
    return "$out\""
}

proc jvalue {v} {
    switch -- [lindex $v 0] {
        int { return "{\"k\": \"int\", \"v\": \"[lindex $v 1]\"}" }
        str { return "{\"k\": \"str\", \"v\": [jstr [lindex $v 1]]}" }
        bool { return "{\"k\": \"bool\", \"v\": [expr {[lindex $v 1] ? "true" : "false"}]}" }
        list { return "{\"k\": \"list\", \"v\": \[[join [lmap x [lindex $v 1] {jvalue $x}] {, }]\]}" }
        enum {
            lassign $v kind name c fields
            if {$fields eq ""} {
                return "{\"k\": \"enum\", \"e\": [jstr $name], \"c\": [jstr $c], \"f\": null}"
            }
            return "{\"k\": \"enum\", \"e\": [jstr $name], \"c\": [jstr $c], \"f\": {[join [lmap {f x} $fields {string cat [jstr $f] ": " [jvalue $x]}] {, }]}}"
        }
        struct {
            lassign $v kind name fields
            return "{\"k\": \"struct\", \"s\": [jstr $name], \"f\": {[join [lmap {f x} $fields {string cat [jstr $f] ": " [jvalue $x]}] {, }]}}"
        }
    }
}

proc jdecls {decls} {
    lassign $decls enums structs
    set es {}
    dict for {name body} $enums {
        set cs {}
        foreach {c fields} $body {
            if {$fields eq ""} {
                lappend cs "\[[jstr $c], null\]"
            } else {
                lappend cs "\[[jstr $c], \[[join [lmap {f t} $fields {string cat "\[" [jstr $f] ", " [jstr $t] "\]"}] {, }]\]\]"
            }
        }
        lappend es "[jstr $name]: \[[join $cs {, }]\]"
    }
    set ss {}
    dict for {name fields} $structs {
        lappend ss "[jstr $name]: \[[join [lmap {f t} $fields {string cat "\[" [jstr $f] ", " [jstr $t] "\]"}] {, }]\]"
    }
    return "\"enums\": {[join $es {, }]}, \"structs\": {[join $ss {, }]}"
}

# ---------------------------------------------------------------------------
# Programs

# The declarations' source: as generated (PERMUTE 0), or with every enum's
# cases and every payload's and struct's fields in another order and
# unrelated declarations first (PERMUTE 1).
proc declSource {decls extra permute} {
    lassign $decls enums structs
    set out "import std::transfer\nimport std::abi::bytes\nimport std::byte\n"
    if {$permute} {
        append out "\nenum Unrelated:\n    Zeta {q: str},\n    Eta,\n\nstruct Filler:\n    w: int\n"
    }
    set names [dict keys $enums]
    if {$permute} {
        set names [shuffled $names]
    }
    foreach name $names {
        set body [dict get $enums $name]
        append out "\nenum $name:\n"
        set cases [dict keys $body]
        if {$permute} {
            set cases [shuffled $cases]
        }
        foreach c $cases {
            set fields [dict get $body $c]
            if {$fields eq ""} {
                append out "    $c,\n"
            } else {
                set fs [dict keys $fields]
                if {$permute} {
                    set fs [shuffled $fs]
                }
                append out "    $c {[join [lmap f $fs {string cat $f ": " [dict get $fields $f]}] {, }]},\n"
            }
        }
    }
    dict for {name fields} $structs {
        append out "\nstruct $name:\n"
        set fs [dict keys $fields]
        if {$permute} {
            set fs [shuffled $fs]
        }
        foreach f $fs {
            append out "    $f: [dict get $fields $f]\n"
        }
    }
    return "$out$extra"
}

proc literal {codes} {
    return "std::abi::bytes::from_list(\[[join [lmap b $codes {string cat "std::byte::from_int($b)"}] {, }]\])"
}

proc bytesOf {value} {
    binary scan [binary decode hex [lindex $value 2 0 1]] cu* codes
    return $codes
}

proc runOn {backend hir} {
    switch -- $backend {
        interp { return [core::evalProgram [hir::lower $hir]] }
        compile { return [core::compiler::evalHir $hir] }
        cranelift { return [native::evalHir $hir] }
        cranelift-generic { return [native::evalHir $hir -specialize 0] }
    }
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $text
    close $f
}

proc readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set t [read $f]
    close $f
    return $t
}

# ---------------------------------------------------------------------------
# The run

set codes {ok 0 malformed 1 version 2 mismatch 3 invalid 4 limit 5}
set disagreements 0
set checked [dict create sendable 0 bytes 0 decodes 0 refusals 0]

proc disagree {seed what detail} {
    global disagreements keep
    incr disagreements
    puts "DISAGREE seed $seed: $what\n    $detail"
    puts "    (programs kept in [file join $keep seed-$seed])"
}

lassign [split [dict get $options -seeds] -] from to
if {$to eq ""} { set to $from }
for {set seed $from} {$seed <= $to} {incr seed} {
    rng $seed
    set decls [genDecls]
    lassign $decls enums structs
    set dir [file join $keep seed-$seed]
    file mkdir $dir

    # Non-sendable declarations, now and then: a function field, an `any`.
    set extra ""
    set typesForClass [concat [dict keys $enums] [dict keys $structs] [lmap n [dict keys $enums] {string cat "List\[$n\]"}]]
    if {[chance 60]} {
        set bad [dict create Bad [list Fine "" Run [list f "Fn{args: \[\], return: int}" n int]]]
        if {[chance 50]} {
            dict set bad Loose [list Fine "" Any [list x any]]
        }
        dict set bad Holder [list Empty "" Holds [list inner Bad]]
        set badDecls [list $bad {}]
        set enumsAll [dict merge $enums $bad]
        lappend typesForClass {*}[dict keys $bad] "List\[Holder\]"
    } else {
        set enumsAll $enums
    }

    # The cases.
    set cases {}
    for {set k 0} {$k < [dict get $options -cases]} {incr k} {
        set r [below 10]
        if {$r < 5} {
            set type [pick [dict keys $enums]]
        } elseif {$r < 8} {
            set type "List\[[pick [dict keys $enums]]\]"
        } else {
            set type S0
        }
        lappend cases [list $type [genValue $decls $type 0]]
    }

    # The oracle's predictions, before any mutation (its bytes first).
    set spec [file join $dir spec.json]
    set jcases [lmap c $cases {string cat "{\"type\": " [jstr [lindex $c 0]] ", \"value\": " [jvalue [lindex $c 1]] "}"}]
    writeFile $spec "{[jdecls [list $enumsAll $structs]], \"cases\": \[[join $jcases {, }]\], \"types\": \[[join [lmap t $typesForClass {jstr $t}] {, }]\]}"
    set facts [dict create]
    foreach line [split [exec python3 -I $oracle run $spec --lines] \n] {
        if {$line eq ""} continue
        set rest [lassign $line kind k]
        dict set facts $kind $k $rest
    }

    # Mutations of the oracle's bytes, and the oracle's outcomes for them.
    set mutations {}
    for {set k 0} {$k < [llength $cases]} {incr k} {
        set good [dict get $facts bytes $k]
        set n [llength $good]
        set ms {}
        for {set m 0} {$m < [dict get $options -mutations]} {incr m} {
            set roll [below 100]
            set b $good
            if {$roll < 45} {
                lset b [expr {13 + [below [expr {$n - 13}]]}] [below 256]
            } elseif {$roll < 60} {
                set b [lrange $b 0 [expr {[below $n] - 1}]]
            } elseif {$roll < 70} {
                lappend b [below 256]
            } elseif {$roll < 85} {
                lset b 13 [below 12]
            } elseif {$roll < 92} {
                set at [expr {13 + [below [expr {$n - 13}]]}]
                set b [concat [lrange $b 0 [expr {$at - 1}]] [list [expr {128 + [below 128]}] [below 128]] [lrange $b [expr {$at + 1}] end]]
            } else {
                lset b [below 13] [below 256]
            }
            lappend ms $b
        }
        lappend mutations $ms
    }
    set jcases {}
    foreach c $cases ms $mutations {
        lappend jcases "{\"type\": [jstr [lindex $c 0]], \"value\": [jvalue [lindex $c 1]], \"mutations\": \[[join [lmap b $ms {string cat "\[" [join $b {, }] "\]"}] {, }]\]}"
    }
    writeFile $spec "{[jdecls [list $enumsAll $structs]], \"cases\": \[[join $jcases {, }]\], \"types\": \[[join [lmap t $typesForClass {jstr $t}] {, }]\]}"
    set facts [dict create]
    foreach line [split [exec python3 -I $oracle run $spec --lines] \n] {
        if {$line eq ""} continue
        set rest [lassign $line kind k]
        dict set facts $kind $k $rest
    }

    # 1. Sendable.
    set badSource ""
    if {$enumsAll ne $enums} {
        set badSource "\nenum Bad:\n    Fine,\n    Run {f: Fn{args: \[\], return: int}, n: int},\n"
        if {[dict exists $enumsAll Loose]} {
            append badSource "\nenum Loose:\n    Fine,\n    Any {x: any},\n"
        }
        append badSource "\nenum Holder:\n    Empty,\n    Holds {inner: Bad},\n"
    }
    set classSource [declSource $decls "$badSource\n[join [lmap t $typesForClass {string cat "fn f_[incr ::fcount](x: $t) -> int:\n    1\n"}] \n]\n1\n" 0]
    writeFile [file join $dir classes.bot] $classSource
    if {[catch {
        set hir [surface::compile $classSource classes.bot -warnings off]
        hir::activate $hir
        set got {}
        foreach r [dict get $hir roots] {
            set node [dict get $hir exprs $r]
            if {[dict get $node kind] ne "bind"} continue
            set binding [hir::binding $hir [dict get $node binding]]
            if {$binding eq "" || ![string match f_* [dict get $binding name]]} continue
            set value [dict get $hir exprs [dict get $node value]]
            set ts [dict getdef $value declaredParamTypes {}]
            lappend got [lindex [hir::types::SendClass [lindex $ts 0]] 0]
        }
    } message]} {
        disagree $seed "sendable program" $message
        continue
    }
    set want [lmap k [lseq [llength $typesForClass]] {dict get $facts sendable $k}]
    dict incr checked sendable [llength $want]
    if {$got ne $want} {
        disagree $seed "Sendable" "types $typesForClass\n    compiler $got\n    oracle   $want"
    }

    # 2. Bytes on every backend.
    set typed {}
    set encodes {}
    set k 0
    foreach c $cases {
        lassign $c type v
        append typed "fn typed_$k\(x: $type) -> $type:\n    x\n\n"
        lappend encodes "std::transfer::encode(typed_$k\([source $v]))"
        incr k
    }
    set senderSource [declSource $decls "\n$typed\[[join $encodes {, }]\]\n" 0]
    writeFile [file join $dir sender.bot] $senderSource
    if {[catch {surface::compile $senderSource sender.bot -warnings off} senderHir]} {
        disagree $seed "sender program" $senderHir
        continue
    }
    foreach backend [dict get $options -backends] {
        if {[catch {runOn $backend $senderHir} value]} {
            disagree $seed "sender on $backend" $value
            continue
        }
        set k 0
        foreach item [lindex $value 1] {
            dict incr checked bytes
            set want [dict get $facts bytes $k]
            set gotBytes [bytesOf $item]
            if {$gotBytes ne $want} {
                disagree $seed "bytes of case $k on $backend" "type [lindex $cases $k 0], value [source [lindex $cases $k 1]]\n    backend $gotBytes\n    oracle  $want"
            }
            incr k
        }
    }

    # 3 and 4. The receiver: permuted declarations, the oracle's bytes, the
    # mutations.
    set body ""
    set k 0
    foreach c $cases ms $mutations {
        lassign $c type v
        append body "fn want_$k\() -> $type:\n    [source $v]\n\n"
        append body "fn check_$k\(d: std::abi::bytes::Bytes) -> List\[bool\]:\n    x = std::transfer::decode\[$type\](d):\n        on TransferMalformed:\n            return \[false\]\n        on TransferVersion:\n            return \[false\]\n        on TransferTypeMismatch:\n            return \[false\]\n        on TransferInvalidValue:\n            return \[false\]\n        on TransferLimit:\n            return \[false\]\n    \[x == want_$k\(), std::transfer::encode(x) == d\]\n\n"
        append body "fn attempt_$k\(d: std::abi::bytes::Bytes) -> int:\n    x = std::transfer::decode\[$type\](d):\n        on TransferMalformed:\n            return 1\n        on TransferVersion:\n            return 2\n        on TransferTypeMismatch:\n            return 3\n        on TransferInvalidValue:\n            return 4\n        on TransferLimit:\n            return 5\n    0\n\n"
        incr k
    }
    set results {}
    set k 0
    foreach c $cases ms $mutations {
        lappend results "check_$k\([literal [dict get $facts bytes $k]])"
        lappend results "\[[join [lmap b $ms {string cat "attempt_$k\(" [literal $b] ")"}] {, }]\]"
        incr k
    }
    set receiverSource [declSource $decls "\n$body\[[join $results {, }]\]\n" 1]
    writeFile [file join $dir receiver.bot] $receiverSource
    if {[catch {surface::compile $receiverSource receiver.bot -warnings off} receiverHir]} {
        disagree $seed "receiver program" $receiverHir
        continue
    }
    foreach backend [dict get $options -backends] {
        if {[catch {core::value::show [runOn $backend $receiverHir] 1} shown]} {
            disagree $seed "receiver on $backend" $shown
            continue
        }
        # [[EQ, REENCODED], [OUTCOMES...], ...]
        set parsed [regexp -all -inline {\[([^\[\]]*)\]} $shown]
        set k 0
        foreach {- check} [lrange $parsed 0 end] {
            set row [lmap x [split $check ,] {string trim $x}]
            if {$k % 2 == 0} {
                set case [expr {$k / 2}]
                dict incr checked decodes
                if {$row ne {true true}} {
                    disagree $seed "decode of case $case on $backend" "type [lindex $cases $case 0], value [source [lindex $cases $case 1]]: \[equal, re-encoded\] = $row"
                }
            } else {
                set case [expr {$k / 2}]
                set want [lmap o [dict get $facts outcomes $case] {dict get $codes $o}]
                dict incr checked refusals [llength $want]
                if {$row ne $want} {
                    disagree $seed "mutations of case $case on $backend" "type [lindex $cases $case 0]\n    backend $row\n    oracle  $want\n    mutations [lindex $mutations $case]"
                }
            }
            incr k
        }
    }
    puts "seed $seed: [llength $cases] cases, [llength $typesForClass] types judged, [dict get $options -mutations] mutations each, [llength [dict get $options -backends]] backends"
    flush stdout
}

puts "checked: [dict get $checked sendable] judgements, [dict get $checked bytes] encodings, [dict get $checked decodes] decodes, [dict get $checked refusals] mutated decodes; $disagreements disagreement(s)"
if {$disagreements == 0 && [dict get $options -keep] eq ""} {
    file delete -force $keep
}
exit [expr {$disagreements != 0}]
