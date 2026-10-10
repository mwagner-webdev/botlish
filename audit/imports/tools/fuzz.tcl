#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized check of explicit namespace and type imports
# (IMPORTS.md): list::, str::, mutable_array::, abi::, abi::x86_64:: and
# linux::abi:: references, method calls from directly imported namespaces,
# `import type`, and the programs imports must reject.
#
#   tclsh9.0 audit/imports/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1? ?-backends LIST?
#
# VALID programs (each seeded individually; a failure replays with `-seed S -n 1`)
# are random mixes of checks, each written twice -- once with qualified free
# calls and once with method calls (and, for ABI values, short type names from
# `import type`) -- over a header that imports exactly the namespaces the
# checks use (the generator tracks the namespaces it emits; nothing is imported
# that no check needs). The two spellings must agree on every backend, the
# backends must agree with each other, and the value must equal an independent
# Tcl oracle's:
#
#   list      list::length/list::append/list::get vs xs.length()/.append()/.get()
#   str       str::concat/str::length/str::substring vs the method spellings
#   array     mutable_array::allocate/set/at vs a.set()/a.at() (the receiver's
#             kind picks mutable_array::at over list::at when both are imported)
#   abi       abi::u8(n).value, abi::x86_64::from_u8(...), to_int and back,
#             and a typed parameter spelled abi::U8Value, or U8Value after
#             `import type abi::U8Value`
#   syscall   a function using linux::abi::syscall (compiled, never run)
#
# NEGATIVE programs rotate through the shapes imports must refuse, each with its
# expected diagnostic kind (anything else, or acceptance, is a "negative
# escape"):
#
#   no-import           a qualified reference without its import (MISSING-IMPORT)
#   parent-for-child    `import abi`, then abi::x86_64::... (MISSING-IMPORT)
#   child-for-parent    `import abi::x86_64`, then abi::... (MISSING-IMPORT)
#   duplicate-import    the same namespace twice (DUPLICATE-IMPORT)
#   missing-namespace   an import naming no namespace (UNKNOWN-NAMESPACE)
#   unknown-member      a member the imported namespace lacks (UNKNOWN-SYMBOL)
#   duplicate-type      the same type imported twice (DUPLICATE-IMPORT)
#   same-short-name     two type imports with one final name
#                       (TYPE-IMPORT-COLLISION)
#   local-type          an import of a type colliding with a local `type`
#                       declaration (TYPE-IMPORT-COLLISION; the other order,
#                       declaration then import, is a syntax error: the
#                       header comes first)
#   not-a-type          `import type abi::u8` (NOT-A-TYPE)
#   transitive          A imports B, B imports C: A uses C::... (MISSING-IMPORT)
#   transitive-type     A uses a short type name only B imported (TYPE)
#   ambiguous-method    two imported namespaces with an applicable f:
#                       x.f() (AMBIGUOUS-METHOD-CALL)
#
# The run ends with "imports-fuzz programs N values V negatives M
# differential-disagreements D oracle-disagreements O negative-escapes X
# backend-disagreements B"; the exit status is 1 if D, O, X or B is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 60
set seed0 1
set dump 0
set backends {interp compile cranelift-generic cranelift}
while {[lindex $args 0] in {-n -seed -dump -backends}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# A scratch library: a copy of lib/ plus the fixture namespaces below.
set scratch [file join [file tempdir imports-fuzz]]
file copy -force [file join $root lib] [file join $scratch lib]
set ::libraryDir [file join $scratch lib]
set ::core::libraryDir $::libraryDir

proc writeModule {name content} {
    set path [file join $::libraryDir {*}[split $name /]].bot
    file mkdir [file dirname $path]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $content
    close $channel
}
writeModule fz_a "type Count = Int in 0..9\n\nfn f(x):\n    x + 1\n"
writeModule fz_b "type Count = Int in 0..99\n\nfn f(x):\n    x + 100\n"
writeModule fz_leaf "type Wide = Int in 0..999\n\nfn deep(x):\n    x + 7\n"
writeModule fz_mid "import fz_leaf\nimport type fz_leaf::Wide\n\nfn via(x: Wide):\n    fz_leaf::deep(x)\n"

set programDir [file join $scratch programs]
file mkdir $programDir
set counter 0

proc compileFile {source {strict 1}} {
    set path [file join $::programDir p[incr ::counter].bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $source
    close $channel
    if {[catch {surface::readProgramFile $path -strict $strict -warnings off} hir options]} {
        set message [regsub -all {[^ ]*\.bot:[0-9]+:[0-9]+} $hir {t.bot:L:C}]
        return [list error [dict get $options -errorcode] $message]
    }
    return [list ok $hir]
}

proc outcomesOf {source} {
    set compiled [compileFile $source]
    if {[lindex $compiled 0] eq "error"} {
        return [lmap b $::backends {set compiled}]
    }
    return [lmap b $::backends {
        set outcome [outcomeUnderHir $b [lindex $compiled 1]]
        list [lindex $outcome 0] [lindex $outcome 1]
    }]
}

# ---------------------------------------------------------------------------
# Valid programs. A check is {FREE METHOD EXPECTED NAMESPACES TYPEIMPORTS}.

proc genList {} {
    set items {}
    foreach _ [lrepeat [rnd 0 4] x] { lappend items [rnd -20 99] }
    return $items
}
proc show {items} { return "\[[join $items {, }]\]" }

proc genCheck {} {
    switch -- [pick {list-length list-append list-get str-concat str-length str-substring array abi-roundtrip abi-typed abi-typed-import}] {
        list-length {
            set xs [genList]
            return [list "list::length([show $xs])" "[show $xs].length()" [llength $xs] {list} {}]
        }
        list-append {
            set xs [genList]
            set v [rnd 0 9]
            return [list "list::length(list::append([show $xs], $v))" "[show $xs].append($v).length()" [expr {[llength $xs] + 1}] {list} {}]
        }
        list-get {
            set xs [genList]
            set i [rnd -2 5]
            set want [expr {$i >= 0 && $i < [llength $xs] ? [lindex $xs $i] : 7}]
            return [list "list::get([show $xs], $i, 7)" "[show $xs].get($i, 7)" $want {list} {}]
        }
        str-concat {
            set a [pick {a bc "" xyz}]
            set b [pick {d "" ef g}]
            return [list "str::concat(\"$a\", \"$b\")" "\"$a\".concat(\"$b\")" "\"$a$b\"" {str} {}]
        }
        str-length {
            set s [pick {"" a bc héllo xyz}]
            return [list "str::length(\"$s\")" "\"$s\".length()" [string length $s] {str} {}]
        }
        str-substring {
            set s [pick {héllo abcdef xyz}]
            set len [string length $s]
            set a [rnd 0 $len]
            set b [rnd $a $len]
            return [list "str::substring(\"$s\", $a, $b)" "\"$s\".substring($a, $b)" "\"[string range $s $a [expr {$b - 1}]]\"" {str} {}]
        }
        array {
            set len [rnd 1 4]
            set i [rnd 0 [expr {$len - 1}]]
            set v [rnd 0 50]
            # a = allocate(len); set(a, i, v); at(a, i): each in a helper
            # function so the handlers are the program's own.
            return [list "array_free($len, $i, $v)" "array_method($len, $i, $v)" $v {mutable_array list} {}]
        }
        abi-roundtrip {
            set v [rnd 0 255]
            return [list "abi::x86_64::to_int(abi::x86_64::from_u8(abi::u8($v)))" \
                "abi::u8($v).from_u8().to_int()" $v {abi abi::x86_64} {}]
        }
        abi-typed {
            set v [rnd 0 255]
            return [list "twice_free($v)" "twice_free($v)" [expr {$v * 2}] {abi} {}]
        }
        abi-typed-import {
            set v [rnd 0 255]
            return [list "twice_short($v)" "twice_short($v)" [expr {$v * 2}] {abi} {abi::U8Value}]
        }
    }
}

set ::definitions {
fn array_free(len, i, v):
    a = mutable_array::allocate(len)
    mutable_array::set(a, i, v):
        on IndexNotFound:
            return -1
    mutable_array::at(a, i):
        on IndexNotFound:
            -1
fn array_method(len, i, v):
    a = mutable_array::allocate(len)
    a.set(i, v):
        on IndexNotFound:
            return -1
    a.at(i):
        on IndexNotFound:
            -1
fn twice_qualified(x: abi::U8):
    x.value * 2
fn twice_free(n):
    x = abi::u8(n):
        on abi::AbiIntegerBelowRange:
            return -1
        on abi::AbiIntegerAboveRange:
            return -1
    twice_qualified(x)
}
# `twice_short` takes an abi::U8Value through its short name.
set ::shortDefinition {
fn twice_short(n: U8Value):
    n * 2
}

proc header {namespaces typeImports} {
    set lines {}
    foreach ns [lsort -unique $namespaces] { lappend lines "import $ns" }
    foreach t [lsort -unique $typeImports] { lappend lines "import type $t" }
    return [join $lines \n]
}

# {FREE-SOURCE METHOD-SOURCE EXPECTED} of a program of random checks.
proc genProgram {} {
    set checks [lmap _ [lrepeat [rnd 2 6] x] {genCheck}]
    set namespaces {}
    set typeImports {}
    foreach c $checks {
        lappend namespaces {*}[lindex $c 3]
        lappend typeImports {*}[lindex $c 4]
    }
    set body {}
    set usesFns 0
    foreach c $checks {
        if {[regexp {array_|twice_} [lindex $c 0]]} { set usesFns 1 }
    }
    set defs [expr {$usesFns ? $::definitions : ""}]
    if {"abi::U8Value" in $typeImports} {
        append defs $::shortDefinition
    }
    # the definitions use these namespaces whether or not a check names them
    if {[regexp {array_} $defs]} { lappend namespaces mutable_array list }
    if {[regexp {twice_free} $defs]} { lappend namespaces abi }
    set head [header $namespaces $typeImports]
    set free [lmap c $checks {lindex $c 0}]
    set method [lmap c $checks {lindex $c 1}]
    set want [lmap c $checks {lindex $c 2}]
    return [list "$head\n$defs\n\[[join $free {, }]\]\n" "$head\n$defs\n\[[join $method {, }]\]\n" "\[[join $want {, }]\]"]
}

# ---------------------------------------------------------------------------
# Negative programs: {SOURCE EXPECTED-KIND}

proc negative {shape} {
    switch -- $shape {
        no-import {
            set ns [pick {list str mutable_array abi}]
            set call [dict get {list {list::length([1])} str {str::length("a")} mutable_array {mutable_array::allocate(1)} abi {abi::u8(1)}} $ns]
            return [list "$call\n" MISSING-IMPORT]
        }
        parent-for-child { return [list "import abi\nabi::x86_64::register64([rnd 0 9])\n" MISSING-IMPORT] }
        child-for-parent { return [list "import abi::x86_64\nabi::u8([rnd 0 9])\n" MISSING-IMPORT] }
        duplicate-import {
            set ns [pick {list str mutable_array abi abi::x86_64 linux::abi}]
            return [list "import $ns\nimport $ns\n1\n" DUPLICATE-IMPORT]
        }
        missing-namespace { return [list "import [pick {nothere nosuch::deep linux abi::nope}]\n1\n" UNKNOWN-NAMESPACE] }
        unknown-member {
            set case [pick {{str reverse} {list nothere} {mutable_array push} {abi i7} {abi::x86_64 from_i7}}]
            lassign $case ns member
            return [list "import $ns\n${ns}::${member}(1)\n" UNKNOWN-SYMBOL]
        }
        duplicate-type { return [list "import abi\nimport type abi::U8Value\nimport type abi::U8Value\n1\n" DUPLICATE-IMPORT] }
        same-short-name {
            return [list "import type fz_a::Count\nimport type fz_b::Count\n1\n" TYPE-IMPORT-COLLISION]
        }
        local-type {
            return [list "import type fz_a::Count\ntype Count = Int in 0..5\n1\n" TYPE-IMPORT-COLLISION]
        }
        not-a-type { return [list "import type [pick {abi::u8 abi::x86_64::register64 list::length str::concat}]\n1\n" NOT-A-TYPE] }
        transitive { return [list "import fz_mid\nfz_leaf::deep([rnd 0 9])\n" MISSING-IMPORT] }
        transitive-type { return [list "import fz_mid\nfn f(x: Wide):\n    x\n1\n" TYPE] }
        ambiguous-method { return [list "import fz_a\nimport fz_b\n[rnd 0 9].f()\n" AMBIGUOUS-METHOD-CALL] }
    }
}

set ::shapes {no-import parent-for-child child-for-parent duplicate-import missing-namespace unknown-member
    duplicate-type same-short-name local-type not-a-type transitive transitive-type ambiguous-method}

# The kind a rejection of source reported.
proc rejectionKind {source} {
    set path [file join $::programDir n[incr ::counter].bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $source
    close $channel
    if {[catch {surface::readProgramFile $path -strict 1 -warnings off} message options]} {
        set code [dict get $options -errorcode]
        return [expr {[lindex $code 1] eq "SYNTAX" ? "SYNTAX" : [lindex $code end]}]
    }
    return accepted
}

set programs 0
set values 0
set negatives 0
set differentialDisagreements 0
set oracleDisagreements 0
set negativeEscapes 0
set backendDisagreements 0

try {
    for {set k 0} {$k < $n} {incr k} {
        set seed [expr {$seed0 + $k}]
        expr {srand($seed)}
        lassign [genProgram] free method want
        if {$dump} {
            puts "---- seed $seed\n$method\n-- free --\n$free\n-- expect: $want"
        }
        incr programs
        set a [outcomesOf $method]
        set b [outcomesOf $free]
        if {[llength [lsort -unique $a]] != 1 || [llength [lsort -unique $b]] != 1} {
            incr backendDisagreements
            puts "BACKEND DISAGREEMENT seed $seed"
            foreach backend $backends x $a y $b { puts "  $backend: method $x / free $y" }
        } elseif {[lindex $a 0] ne [lindex $b 0]} {
            incr differentialDisagreements
            puts "DIFFERENTIAL DISAGREEMENT seed $seed: method [lindex $a 0] free [lindex $b 0]"
        } elseif {[lindex $a 0] ne [list value $want]} {
            incr oracleDisagreements
            puts "ORACLE DISAGREEMENT seed $seed: expected $want, got [lindex $a 0]"
        } else {
            incr values
        }

        # A compile-only program with linux::abi::syscall (never run).
        if {$k % 10 == 0} {
            set text "import abi::x86_64\nimport linux::abi\nfn raw():\n    abi::x86_64::to_int(linux::abi::syscall({rax: abi::x86_64::register64([rnd 0 9])}))\n1\n"
            set compiled [compileFile $text]
            if {[lindex $compiled 0] ne "ok"} {
                incr negativeEscapes
                puts "REJECTED VALID seed $seed (syscall): [lindex $compiled 2]"
            }
        }

        set shape [lindex $::shapes [expr {$k % [llength $::shapes]}]]
        lassign [negative $shape] negSource kind
        if {$dump} {
            puts "-- negative ($shape, expect $kind)\n$negSource"
        }
        incr negatives
        set got [rejectionKind $negSource]
        if {$got ne $kind} {
            incr negativeEscapes
            puts "NEGATIVE ESCAPE seed $seed ($shape): expected $kind, got $got\n$negSource"
        }
    }
} finally {
    file delete -force $scratch
}

puts "imports-fuzz programs $programs values $values negatives $negatives differential-disagreements $differentialDisagreements oracle-disagreements $oracleDisagreements negative-escapes $negativeEscapes backend-disagreements $backendDisagreements"
exit [expr {$differentialDisagreements || $oracleDisagreements || $negativeEscapes || $backendDisagreements}]
