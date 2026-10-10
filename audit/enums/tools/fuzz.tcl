#!/usr/bin/env tclsh9.0
# fuzz.tcl -- generated enum programs against an independent model (ENUMS.md).
#
#   tclsh9.0 audit/enums/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#                                       ?-backends LIST? ?-gc-stress 0|1?
#
# Each program declares two to four enums whose case lists overlap in
# spelling (several enums have a `Car`, a `Red`, ...), each declaration's
# cases in a random order, plus -- every other program -- an enum of a module
# (`fz::Mode`, written into a private library), and runs a driver function
# `drive(zero)`: a straight line of 6..20 operations whose result is a List of
# observations. The operations:
#
#   case        a binding of a case value, E::C
#   copy        a binding of another binding (both stay usable)
#   same        a generic identity function, `same(x)`
#   erase       a function through `any`, `erase(x)` (the result is any)
#   typed       a function typed on one enum, `id_E(x)` (only for a value
#               statically of E)
#   pick        a function returning a case from branches, `pick_E(k + zero)`,
#               whose case per branch the program states (never an ordinal)
#   struct      a struct with an enum field, constructed, projected and
#               destructured
#   list        a List of cases (of one enum or mixed), iterated by a loop
#   array       a MutableArray of cases: create (one repeated case), set, get
#   vector      a MutableVector of cases: push, pop, at
#   set         an ImmutableSet of cases: membership
#   closure     a nested function comparing its argument with a captured case
#   module      the module enum's cases and a module function on them
#
# and the observations: a case value itself, `==` and `!=` of two values (of
# one enum or of two), `hash(a) == hash(b)`, set membership, a struct, a List.
#
# The model shares no code with the compiler or a runtime: a case value is
# the pair (EnumIdentity, CaseIdentity) -- the enum's declared identity
# (`Color`, `fz::Mode`) and the case's declared name -- never a number.
# Equality is "same enum and same case"; a copy, a call, a field, an element
# keeps the pair; nothing has ownership state. Hashes are compared, never
# predicted: equal pairs must hash equal, unequal pairs unequal (a collision
# of the 61-bit hash between two of a program's few cases would be reported
# as a disagreement, and has never occurred). A value renders as
# `EnumIdentity::Case`.
#
# A third of the programs carry one fault with the diagnostic the model
# predicts: an unknown case (UNKNOWN-ENUM-CASE), a value of another enum
# passed to a typed function, returned as a declared result or stored in a
# typed struct field (TYPE), a duplicate case (TYPE), an empty enum
# (ENUM-EMPTY), an unknown qualifier (UNKNOWN-NAMESPACE), a struct used as a
# qualifier (NOT-AN-ENUM), a bare case (UNBOUND), an anonymous enum
# (ANONYMOUS-ENUM), a cross-enum value where a List of one enum is declared
# (TYPE), and, at run time on every backend, arithmetic or ordering of cases
# (the natives' TYPE error). Cross-enum `==` is not a fault: it is false.
#
# Every accepted program's value is compared on every backend of BACKENDS
# against the model's; with -gc-stress 1, the native run again with a
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
set ::fuzzLibrary [file tempdir botlish-enum-fuzz]
foreach entry [glob -nocomplain -directory $::core::libraryDir *] {
    file copy -force $entry $::fuzzLibrary
}
set ::core::libraryDir $::fuzzLibrary
set channel [open [file join $::fuzzLibrary fz.bot] w]
fconfigure $channel -encoding utf-8 -translation lf
puts -nonewline $channel {enum Mode:
    On,
    Car,
    Off,

fn flip(m: Mode) -> Mode:
    if m == Mode::On:
        Mode::Off
    else:
        Mode::On
}
close $channel
# The module enum's identity and cases, for the model.
set ::moduleEnum fz::Mode
set ::moduleCases {On Car Off}

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

proc Fresh {stateVar prefix} {
    upvar 1 $stateVar state
    dict incr state n
    return "$prefix[dict get $state n]"
}

proc Emit {stateVar args} {
    upvar 1 $stateVar state
    foreach line $args {
        dict lappend state lines $line
    }
}

# ---------------------------------------------------------------------------
# The model

# A model value: {case ENUM CASE} | {bool B} | {int N} | {list VALUES} |
# {struct ENUM CASEVALUE W}; rendered as the backends show it.
proc Render {v} {
    switch -- [lindex $v 0] {
        case   { return "[lindex $v 1]::[lindex $v 2]" }
        bool   { return [expr {[lindex $v 1] ? "true" : "false"}] }
        int    { return [lindex $v 1] }
        list   { return "\[[join [lmap x [lindex $v 1] {Render $x}] {, }]\]" }
        struct { return "Holder_[lindex $v 1] {v: [Render [lindex $v 2]], w: [lindex $v 3]}" }
    }
}

# 1 if model values A and B are equal: the same enum identity and the same
# case identity (never a position).
proc Equal {a b} {
    return [expr {$a eq $b}]
}

# ---------------------------------------------------------------------------
# Declarations

set ::enumPool {Color Signal Kind Mode Shape}
set ::casePool {Red Green Blue Car Boat On Off Idle Truck}

# The program's enums: ENUM -> its cases in declaration order.
proc Enums {} {
    set count [expr {2 + [Rand 3]}]
    set names [lrange [Shuffle $::enumPool] 0 [expr {$count - 1}]]
    set enums [dict create]
    foreach name $names {
        set cases [lrange [Shuffle $::casePool] 0 [expr {1 + [Rand 4]}]]
        dict set enums $name $cases
    }
    return $enums
}

# The pick mappings of ENUMS: ENUM -> {CASE0 CASE1 CASE2}, what pick_E
# returns for 0, 1 and 2 or more -- the program's own explicit choice, never
# a case's position.
proc Picks {enums} {
    set picks [dict create]
    dict for {name cases} $enums {
        dict set picks $name [list [Pick $cases] [Pick $cases] [Pick $cases]]
    }
    return $picks
}

# The declarations and helper functions of ENUMS (pick_E by PICKS), with
# FAULTDECL (a fault's own declaration, or "") after the enums.
proc Declarations {enums picks faultDecl} {
    set text ""
    dict for {name cases} $enums {
        append text "enum $name:\n"
        foreach c $cases {
            append text "    $c,\n"
        }
        append text "\n"
    }
    append text $faultDecl
    dict for {name cases} $enums {
        append text "struct Holder_$name:\n    v: $name\n    w: int\n\n"
        append text "fn id_$name\(x: $name) -> $name:\n    x\n\n"
        set mapping [dict get $picks $name]
        append text "fn pick_$name\(i: int) -> $name:\n    if i == 0:\n        $name\::[lindex $mapping 0]\n    elif i == 1:\n        $name\::[lindex $mapping 1]\n    else:\n        $name\::[lindex $mapping 2]\n\n"
        append text "fn lift_$name\(x: $name) -> List\[$name\]:\n    \[x, x\]\n\n"
    }
    append text "fn same(x):\n    x\n\nfn erase(x: any) -> any:\n    x\n\n"
    return $text
}

# ---------------------------------------------------------------------------
# Operations
#
# STATE: vars (NAME -> {MODEL STATIC}: STATIC an enum identity, or any),
# enums, picks, module (1 if fz is imported), lines, observed, expected, n.

proc Vars {state {static ""}} {
    set out {}
    dict for {name info} [dict get $state vars] {
        if {$static eq "" || [lindex $info 1] eq $static} {
            lappend out $name
        }
    }
    return $out
}

proc TypedVars {state} {
    set out {}
    dict for {name info} [dict get $state vars] {
        if {[lindex $info 1] ne "any"} {
            lappend out $name
        }
    }
    return $out
}

proc Bind {stateVar name model static} {
    upvar 1 $stateVar state
    dict set state vars $name [list $model $static]
}

proc ModelOf {state name} {
    return [lindex [dict get $state vars $name] 0]
}

proc StaticOf {state name} {
    return [lindex [dict get $state vars $name] 1]
}

proc Observe {stateVar expr model} {
    upvar 1 $stateVar state
    set o [Fresh state o]
    Emit state "$o = $expr"
    dict lappend state observed $o
    dict lappend state expected $model
}

# A case of an enum of the program (or of the module enum).
proc AnyCase {state} {
    set enums [dict get $state enums]
    if {[dict get $state module] && [Rand 4] == 0} {
        return [list $::moduleEnum [Pick $::moduleCases]]
    }
    set e [Pick [dict keys $enums]]
    return [list $e [Pick [dict get $enums $e]]]
}

proc Operation {stateVar} {
    upvar 1 $stateVar state
    set vars [Vars $state]
    set typed [TypedVars $state]
    if {$vars eq {}} {
        set kind case
    } else {
        set kind [Pick {case case case copy same erase typed pick pick struct list array vector set closure module module eq eq eq hash show show}]
    }
    switch -- $kind {
        case {
            lassign [AnyCase $state] e c
            set v [Fresh state v]
            Emit state "$v = ${e}::$c"
            Bind state $v [list case $e $c] $e
        }
        copy {
            set from [Pick $vars]
            set v [Fresh state v]
            Emit state "$v = $from"
            Bind state $v [ModelOf $state $from] [StaticOf $state $from]
        }
        same {
            set from [Pick $vars]
            set v [Fresh state v]
            Emit state "$v = same($from)"
            Bind state $v [ModelOf $state $from] [StaticOf $state $from]
        }
        erase {
            set from [Pick $vars]
            set v [Fresh state v]
            Emit state "$v = erase($from)"
            Bind state $v [ModelOf $state $from] any
        }
        typed {
            set candidates [lmap t $typed {if {[StaticOf $state $t] eq $::moduleEnum} continue; set t}]
            if {$candidates eq {}} return
            set from [Pick $candidates]
            set v [Fresh state v]
            Emit state "$v = id_[StaticOf $state $from]($from)"
            Bind state $v [ModelOf $state $from] [StaticOf $state $from]
        }
        pick {
            set e [Pick [dict keys [dict get $state enums]]]
            set k [Rand 4]
            set v [Fresh state v]
            Emit state "$v = pick_$e\($k + zero)"
            Bind state $v [list case $e [lindex [dict get $state picks $e] [expr {min($k, 2)}]]] $e
        }
        struct {
            set candidates [lmap t $typed {if {[StaticOf $state $t] eq $::moduleEnum} continue; set t}]
            if {$candidates eq {}} return
            set from [Pick $candidates]
            set e [StaticOf $state $from]
            set w [Rand 9]
            set h [Fresh state h]
            Emit state "$h = Holder_$e \{w: $w, v: $from\}"
            if {[Rand 2]} {
                set v [Fresh state v]
                Emit state "$v = $h.v"
            } else {
                set v [Fresh state v]
                Emit state "\{v: $v\} = $h"
            }
            Bind state $v [ModelOf $state $from] $e
            if {[Rand 3] == 0} {
                Observe state $h [list struct $e [ModelOf $state $from] $w]
            }
        }
        list {
            set items {}
            set models {}
            for {set i [expr {1 + [Rand 3]}]} {$i > 0} {incr i -1} {
                set x [Pick $vars]
                lappend items $x
                lappend models [ModelOf $state $x]
            }
            set l [Fresh state l]
            Emit state "$l = \[[join $items {, }]\]"
            # A loop over the List: keeps the elements equal to a chosen
            # one (or all), proving iteration keeps each pair.
            set target [Pick $vars]
            set tm [ModelOf $state $target]
            set c [Fresh state l]
            Emit state "$c = loop x in $l:" "    if x == $target:" "        x" "    else:" "        continue"
            Observe state $c [list list [lmap m $models {expr {[Equal $m $tm] ? $m : [continue]}}]]
            if {[Rand 2]} {
                Observe state $l [list list $models]
            }
        }
        array {
            set candidates [lmap t $typed {if {[StaticOf $state $t] eq $::moduleEnum} continue; set t}]
            if {$candidates eq {}} return
            set from [Pick $candidates]
            set e [StaticOf $state $from]
            set n [expr {2 + [Rand 3]}]
            set a [Fresh state a]
            Emit state "$a = mutable_array::create($n, $from)"
            set slots [lrepeat $n [ModelOf $state $from]]
            # A set of a case of the same enum at an in-range index.
            set others [Vars $state $e]
            set to [Pick $others]
            set i [Rand $n]
            Emit state "$a.set($i + zero, $to):" "    on IndexNotFound:" "        unit"
            lset slots $i [ModelOf $state $to]
            set j [Rand $n]
            set v [Fresh state v]
            Emit state "$v = mutable_array::get($a, $j + zero, $from)"
            Bind state $v [lindex $slots $j] $e
            if {[Rand 2]} {
                set s [Fresh state l]
                Emit state "$s = loop x in $a:" "    x"
                Observe state $s [list list $slots]
            }
        }
        vector {
            set candidates [lmap t $typed {if {[StaticOf $state $t] eq $::moduleEnum} continue; set t}]
            if {$candidates eq {}} return
            set from [Pick $candidates]
            set e [StaticOf $state $from]
            set others [Vars $state $e]
            set w [Fresh state w]
            Emit state "$w = mutable_vector::from_list(lift_$e\($from))"
            set items [list [ModelOf $state $from] [ModelOf $state $from]]
            foreach k [lrange [Shuffle $others] 0 [Rand 3]] {
                Emit state "$w.push($k)"
                lappend items [ModelOf $state $k]
            }
            set v [Fresh state v]
            Emit state "$v = $w.pop():" "    on IndexNotFound:" "        $from"
            Bind state $v [lindex $items end] $e
            set items [lrange $items 0 end-1]
            Observe state "$w.length()" [list int [llength $items]]
            set u [Fresh state v]
            Emit state "$u = $w.at(0 + zero):" "    on IndexNotFound:" "        $from"
            Bind state $u [lindex $items 0] $e
        }
        set {
            set items [lrange [Shuffle $vars] 0 [Rand 3]]
            set needle [Pick $vars]
            set s [Fresh state s]
            Emit state "$s = immutable_set::from_list(\[[join $items {, }]\])"
            set found 0
            foreach x $items {
                if {[Equal [ModelOf $state $x] [ModelOf $state $needle]]} {
                    set found 1
                }
            }
            Observe state "immutable_set::contains($s, $needle)" [list bool $found]
        }
        closure {
            set captured [Pick $vars]
            set probe [Pick $vars]
            set f [Fresh state f]
            Emit state "fn $f\(x) -> bool:" "    x == $captured"
            Observe state "$f\($probe)" [list bool [Equal [ModelOf $state $probe] [ModelOf $state $captured]]]
        }
        module {
            if {![dict get $state module]} return
            set c [Pick $::moduleCases]
            set v [Fresh state v]
            Emit state "$v = fz::flip(fz::Mode::$c)"
            Bind state $v [list case $::moduleEnum [expr {$c eq "On" ? "Off" : "On"}]] $::moduleEnum
        }
        eq {
            set a [Pick $vars]
            set b [Pick $vars]
            set same [Equal [ModelOf $state $a] [ModelOf $state $b]]
            if {[Rand 2]} {
                Observe state "$a == $b" [list bool $same]
            } else {
                Observe state "$a != $b" [list bool [expr {!$same}]]
            }
        }
        hash {
            set a [Pick $vars]
            set b [Pick $vars]
            Observe state "hash($a) == hash($b)" [list bool [Equal [ModelOf $state $a] [ModelOf $state $b]]]
        }
        show {
            set a [Pick $vars]
            Observe state $a [ModelOf $state $a]
        }
    }
}

# One fault (a line of the driver, or a declaration), with the diagnostic
# the model predicts: {KIND LINES DECL} (DECL is extra declaration text).
proc Fault {stateVar} {
    upvar 1 $stateVar state
    set enums [dict get $state enums]
    set names [dict keys $enums]
    set e [Pick $names]
    set kind [Pick {unknowncase wrongarg wrongresult wrongfield duplicate empty qualifier notenum bare anonymous wronglist arith order}]
    switch -- $kind {
        unknowncase {
            return [list UNKNOWN-ENUM-CASE [list "bad = ${e}::Nope"] ""]
        }
        wrongarg - wrongresult - wrongfield - wronglist {
            # A value statically of another enum F (bound from a case of F).
            set others [lmap n $names {if {$n eq $e} continue; set n}]
            set f [Pick $others]
            set c [Pick [dict get $enums $f]]
            set lines [list "other = ${f}::$c"]
            switch -- $kind {
                wrongarg    { lappend lines "bad = id_$e\(other)" }
                wrongfield  { lappend lines "bad = Holder_$e \{v: other, w: 1\}" }
                wronglist   { lappend lines "bad = lift_$e\(other)" }
                wrongresult {
                    return [list TYPE $lines "fn wrong_result() -> $e:\n    ${f}::$c\n\n"]
                }
            }
            return [list TYPE $lines ""]
        }
        duplicate {
            set c [Pick [dict get $enums $e]]
            return [list TYPE {} "enum Dup:\n    $c,\n    Other,\n    $c,\n\n"]
        }
        empty {
            return [list ENUM-EMPTY {} "enum Empty:\n\n"]
        }
        qualifier {
            return [list UNKNOWN-NAMESPACE [list "bad = Nowhere::Car"] ""]
        }
        notenum {
            return [list NOT-AN-ENUM [list "bad = Holder_$e\::Car"] ""]
        }
        bare {
            # A case spelling no binding of the program has (the drivers
            # bind v1, h2, ...; a case is capitalized).
            return [list UNBOUND [list "bad = [Pick [dict get $enums $e]]"] ""]
        }
        anonymous {
            return [list ANONYMOUS-ENUM {} "enum {A, B}\n\n"]
        }
        arith {
            set c [Pick [dict get $enums $e]]
            return [list runtime:TYPE [list "bad = ${e}::$c + 1"] ""]
        }
        order {
            set c [Pick [dict get $enums $e]]
            set d [Pick [dict get $enums $e]]
            return [list runtime:TYPE [list "bad = ${e}::$c < ${e}::$d"] ""]
        }
    }
}

# The program text of generation NUMBER and the model's expectation: the
# declarations (and their pick mappings) are drawn before the operations, so
# that a pick operation knows what each branch returns.
proc Program {number} {
    set state [dict create vars {} picks {} module [expr {$number % 2}] lines {} observed {} expected {} n 0]
    dict set state enums [Enums]
    dict set state picks [Picks [dict get $state enums]]
    set count [expr {6 + [Rand 15]}]
    for {set i 0} {$i < $count} {incr i} {
        Operation state
    }
    set code ""
    set decl ""
    if {[Rand 3] == 0} {
        lassign [Fault state] code lines decl
        Emit state {*}$lines
    }
    set declarations [Declarations [dict get $state enums] [dict get $state picks] $decl]
    set header "import list\nimport mutable_array\nimport mutable_vector\nimport immutable_set\n"
    if {[dict get $state module]} {
        append header "import fz\n"
    }
    set body [join [lmap line [dict get $state lines] {string cat "    " $line}] \n]
    set result "\[[join [dict get $state observed] {, }]\]"
    set text "$header\n${declarations}fn drive(zero: int):\n$body\n    $result\n\ndrive(0)\n"
    if {$code eq ""} {
        set expect [list value [Render [list list [dict get $state expected]]]]
    } elseif {[string match runtime:* $code]} {
        set expect [list runtime [string range $code 8 end]]
    } else {
        set expect [list error $code]
    }
    return [list $text $expect]
}

# The diagnostic kind of a compile failure (a syntax error's own code, else
# the semantic kind).
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
    set runtimeRejected 0
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
                set problem "rejected [lindex $got 1]: $hir\noracle expects $expect"
            } else {
                incr rejected
                dict incr codes [lindex $got 1]
            }
        } elseif {[lindex $expect 0] eq "error"} {
            set problem "accepted; oracle expects [lindex $expect 1]"
        } else {
            foreach b $backends {
                set o [lrange [outcomeUnderHir $b $hir] 0 1]
                if {[lindex $expect 0] eq "runtime"} {
                    if {[lindex $o 0] ne "error" || [lindex $o 1] ne [list CORE SEMANTIC [lindex $expect 1]]} {
                        set problem "$b gives $o, oracle a run-time [lindex $expect 1] error"
                        break
                    }
                } elseif {$o ne $expect} {
                    set problem "$b gives $o, oracle $expect"
                    break
                }
            }
            set nativeOk [expr {$::tcl_platform(os) eq "Linux" && $::tcl_platform(machine) in {x86_64 amd64}}]
            if {$problem eq "" && [dict get $options -gc-stress] && $nativeOk && [lindex $expect 0] eq "value"} {
                set ::env(BOTLISH_NATIVE_GC_STRESS) 1
                try {
                    set o [lrange [outcomeUnderHir cranelift $hir] 0 1]
                } finally {
                    unset ::env(BOTLISH_NATIVE_GC_STRESS)
                }
                if {$o ne $expect} {
                    set problem "cranelift under GC stress gives $o, oracle $expect"
                }
            }
            if {$problem eq ""} {
                if {[lindex $expect 0] eq "runtime"} {
                    incr runtimeRejected
                    dict incr codes "run-time [lindex $expect 1]"
                } else {
                    incr accepted
                    incr observations [regexp -all {, } [lindex $expect 1]]
                }
            }
        }
        if {$problem ne ""} {
            incr disagreements
            puts "DISAGREEMENT program $number:\n$problem\n--- program\n$text"
        }
    }
    puts "accepted $accepted rejected $rejected run-time-rejected $runtimeRejected ([join [lmap {c n} [lsort -stride 2 [dict get $codes]] {string cat "$c $n"}] {, }])"
    puts "programs [dict get $options -n] disagreements $disagreements"
    return $disagreements
}

try {
    set status [Run]
} finally {
    file delete -force $::fuzzLibrary
}
exit [expr {$status > 0 ? 1 : 0}]
