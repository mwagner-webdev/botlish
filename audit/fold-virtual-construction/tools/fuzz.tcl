# fuzz.tcl -- differential fuzzing of FOLD-VIRTUAL-LIST-CONSTRUCTION-
# MILESTONE-1.md's plan folds: seeded random folds whose List intermediate
# is extended, kept, observed, captured, continued past, broken off and
# returned from, each run on every backend (and on cranelift with virtual
# construction off, the eager fold) and compared with an independent Tcl
# model of the fold's meaning; the compiler's decision (plan fold or not)
# is compared with an independent model of the eligibility rule.
#
#   tclsh9.0 audit/fold-virtual-construction/tools/fuzz.tcl ?-n N? ?-seed S? \
#       ?-gc-stress 0|1? ?-backends LIST? ?-keep 0|1?
#
# Each program is one function `f(xs, base)` holding one fold (over the List
# or over its indices) and a call of it on three inputs. The body is a
# sequence of statements -- `if C: continue`, `if C: break`, `if C: return
# acc.append(E)`, `n = acc.length()`, a nested function capturing `acc`,
# `y = acc.append(E)` -- and a trailing value: `acc`, an append of one or two
# elements, `y`, `y.append(E)`, or an `if` of two such values.
#
# The eligibility model, written from the report's rule and not from
# hir/construction.tcl: the intermediate is a plan when it is not captured,
# every path of an iteration references it at most once (a taken continue,
# break or return counts the reference it makes; the fall-through path
# counts every observation, every `y = acc.append(...)` and the trailing
# value's), and some reference continues the construction (anything but an
# observation); only a fold whose body runs is judged (an instance over an
# empty List[never] never runs it). The last line is "programs N plan P
# flat F unreached U disagreements D mispredictions M"; it exits 1 on any
# disagreement or misprediction (a "mixed" verdict -- two instances of one
# fold decided differently -- is one).
# -keep 1 keeps the failing programs' files (their paths are printed).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
# (tests/helpers.tcl loads tcltest, which reads argv: it sees none.)
set arguments $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root examples stdlib corpus.tcl]
set argv $arguments

set options [dict create -n 40 -seed 1 -gc-stress 0 -backends {interp compile cranelift-generic cranelift} -keep 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}
if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}

proc pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}
proc chance {p} {
    return [expr {rand() < $p}]
}
proc rnd {lo hi} {
    return [expr {$lo + int(rand() * ($hi - $lo + 1))}]
}

# ---------------------------------------------------------------------------
# Generation

proc genCond {} {
    if {[chance 0.5]} {
        return [list mod [rnd 2 5] [rnd 0 1]]
    }
    return [list gt [rnd 0 12]]
}

proc genElem {hasN} {
    set forms {x lin lin}
    if {$hasN} { lappend forms n n }
    switch -- [pick $forms] {
        x   { return x }
        lin { return [list lin [rnd 1 3] [rnd -2 5]] }
        n   { return [list n [rnd 0 3]] }
    }
}

proc genTail {hasN hasY depth} {
    set forms {keep append append append2}
    if {$hasY} { lappend forms y y yappend }
    if {$depth < 2} { lappend forms if if }
    switch -- [pick $forms] {
        keep    { return keep }
        append  { return [list append [genElem $hasN]] }
        append2 { return [list append [genElem $hasN] [genElem $hasN]] }
        y       { return y }
        yappend { return [list yappend [genElem $hasN]] }
        if      { return [list if [genCond] [genTail $hasN $hasY [expr {$depth + 1}]] [genTail $hasN $hasY [expr {$depth + 1}]]] }
    }
}

proc genProgram {} {
    set stmts {}
    set hasN 0
    set hasY 0
    set count [rnd 0 4]
    for {set i 0} {$i < $count} {incr i} {
        set forms {continue break}
        if {[chance 0.4]} { lappend forms return }
        if {!$hasN} { lappend forms observe capture }
        if {!$hasY} { lappend forms bindy bindy }
        switch -- [pick $forms] {
            continue { lappend stmts [list continue [genCond]] }
            break    { lappend stmts [list break [genCond]] }
            return   { lappend stmts [list return [genCond] [genElem $hasN]] }
            observe  { lappend stmts observe; set hasN 1 }
            capture  { lappend stmts capture; set hasN 1 }
            bindy    { lappend stmts [list bindy [genElem $hasN]]; set hasY 1 }
        }
    }
    set inputs {}
    foreach len [list [rnd 0 12] [rnd 0 12] 0] {
        set xs {}
        for {set i 0} {$i < $len} {incr i} { lappend xs [rnd -5 20] }
        lappend inputs [list $xs [lrange {9 8 7} 0 [rnd 0 2]]]
    }
    return [dict create domain [pick {list list count}] init [pick {empty empty const base}] \
        stmts $stmts tail [genTail $hasN $hasY 0] inputs $inputs]
}

# ---------------------------------------------------------------------------
# Rendering

proc condText {c} {
    switch -- [lindex $c 0] {
        mod { return "x.mod([lindex $c 1]) == [lindex $c 2]" }
        gt  { return "x > [lindex $c 1]" }
    }
}
proc elemText {e} {
    switch -- [lindex $e 0] {
        x   { return x }
        lin { return "x * [lindex $e 1] + [lindex $e 2]" }
        n   { return "n + [lindex $e 1]" }
    }
}
proc appendText {base elems} {
    set text $base
    foreach e $elems { append text ".append([elemText $e])" }
    return $text
}
proc tailLines {t indent} {
    set pad [string repeat "    " $indent]
    switch -- [lindex $t 0] {
        keep    { return [list "${pad}acc"] }
        append  { return [list "$pad[appendText acc [lrange $t 1 end]]"] }
        y       { return [list "${pad}y"] }
        yappend { return [list "$pad[appendText y [lrange $t 1 end]]"] }
        if {
            set lines [list "${pad}if [condText [lindex $t 1]]:"]
            lappend lines {*}[tailLines [lindex $t 2] [expr {$indent + 1}]]
            lappend lines "${pad}else:"
            lappend lines {*}[tailLines [lindex $t 3] [expr {$indent + 1}]]
            return $lines
        }
    }
}
proc listText {xs} {
    return "\[[join $xs {, }]\]"
}
proc render {p} {
    set init [dict get {empty {[]} const {[100, 101]} base base} [dict get $p init]]
    set lines {{import std::list} {} {fn f(xs: List[int], base: List[int]) -> List[int]:}}
    if {[dict get $p domain] eq "list"} {
        lappend lines "    fold x in xs with intermediate acc $init:"
    } else {
        lappend lines "    fold x from 0 to xs.length() with intermediate acc $init:"
    }
    foreach s [dict get $p stmts] {
        switch -- [lindex $s 0] {
            continue { lappend lines "        if [condText [lindex $s 1]]:" "            continue" }
            break    { lappend lines "        if [condText [lindex $s 1]]:" "            break" }
            return   { lappend lines "        if [condText [lindex $s 1]]:" "            return [appendText acc [list [lindex $s 2]]]" }
            observe  { lappend lines "        n = acc.length()" }
            capture  { lappend lines "        fn peek() -> int:" "            acc.length()" "        n = peek()" }
            bindy    { lappend lines "        y = [appendText acc [list [lindex $s 1]]]" }
        }
    }
    lappend lines {*}[tailLines [dict get $p tail] 2]
    lappend lines ""
    lappend lines "\[[join [lmap in [dict get $p inputs] {string cat "f([listText [lindex $in 0]], [listText [lindex $in 1]])"}] {, }]\]"
    return "[join $lines \n]\n"
}

# ---------------------------------------------------------------------------
# The models

proc condValue {c x} {
    switch -- [lindex $c 0] {
        mod { return [expr {$x % [lindex $c 1] == [lindex $c 2]}] }
        gt  { return [expr {$x > [lindex $c 1]}] }
    }
}
proc elemValue {e env} {
    switch -- [lindex $e 0] {
        x   { return [dict get $env x] }
        lin { return [expr {[dict get $env x] * [lindex $e 1] + [lindex $e 2]}] }
        n   { return [expr {[dict get $env n] + [lindex $e 1]}] }
    }
}
proc tailValue {t env} {
    switch -- [lindex $t 0] {
        keep    { return [dict get $env acc] }
        append  { return [concat [dict get $env acc] [lmap e [lrange $t 1 end] {elemValue $e $env}]] }
        y       { return [dict get $env y] }
        yappend { return [concat [dict get $env y] [lmap e [lrange $t 1 end] {elemValue $e $env}]] }
        if {
            if {[condValue [lindex $t 1] [dict get $env x]]} {
                return [tailValue [lindex $t 2] $env]
            }
            return [tailValue [lindex $t 3] $env]
        }
    }
}
# f(xs, base) of program P, as a Tcl list.
proc model {p xs base} {
    set acc [dict get [dict create empty {} const {100 101} base $base] [dict get $p init]]
    set domain [expr {[dict get $p domain] eq "list" ? $xs : [lmap i [lsearch -all $xs *] {set i}]}]
    foreach x $domain {
        set env [dict create acc $acc x $x]
        set next ""
        foreach s [dict get $p stmts] {
            switch -- [lindex $s 0] {
                continue {
                    if {[condValue [lindex $s 1] $x]} { set next continue; break }
                }
                break {
                    if {[condValue [lindex $s 1] $x]} { return $acc }
                }
                return {
                    if {[condValue [lindex $s 1] $x]} { return [concat $acc [list [elemValue [lindex $s 2] $env]]] }
                }
                observe - capture { dict set env n [llength $acc] }
                bindy { dict set env y [concat $acc [list [elemValue [lindex $s 1] $env]]] }
            }
        }
        if {$next eq "continue"} continue
        set acc [tailValue [dict get $p tail] $env]
    }
    return $acc
}

proc tailUses {t} {
    switch -- [lindex $t 0] {
        keep - append { return 1 }
        y - yappend   { return 0 }
        if            { return [expr {max([tailUses [lindex $t 2]], [tailUses [lindex $t 3]])}] }
    }
}
# "plan" or "flat": the eligibility model.
proc predict {p} {
    set before 0
    set worst 0
    set continues [expr {[tailUses [dict get $p tail]] > 0}]
    foreach s [dict get $p stmts] {
        switch -- [lindex $s 0] {
            capture { return flat }
            continue - break - return {
                set worst [expr {max($worst, $before + 1)}]
                if {[lindex $s 0] eq "return"} { set continues 1 }
            }
            observe { incr before }
            bindy { incr before; set continues 1 }
        }
    }
    set worst [expr {max($worst, $before + [tailUses [dict get $p tail]])}]
    return [expr {$worst <= 1 && $continues ? "plan" : "flat"}]
}

# ---------------------------------------------------------------------------
# The compiler

# "plan" or "flat": the compiler's decision for the fold of every
# specialization of f whose fold body runs ("none" when no call reaches it:
# an instance over an empty List[never] never runs its body, and its
# decision means nothing); "mixed" if two instances disagree.
proc verdict {hir} {
    set lowered [native::lower::program $hir]
    set spec [dict get $lowered specialization]
    set analysis [dict get $lowered construction]
    set verdicts {}
    foreach id [dict get $spec used] {
        set view [dict get $analysis regions $id view]
        foreach e [dict get $analysis regions $id exprs] {
            if {[hir::kind $view $e] in {loop listloop countloop lockloop} && [hir::isFold $view $e]
                    && [hir::get $view [lindex [hir::get $view $e body] 0] reachable]} {
                lappend verdicts [expr {[hir::construction::foldFamily $analysis $id $e] ne "" ? "plan" : "flat"}]
            }
        }
    }
    set verdicts [lsort -unique $verdicts]
    if {$verdicts eq ""} {
        return none
    }
    if {[llength $verdicts] > 1} {
        return mixed
    }
    return $verdicts
}

proc outcome {label hir} {
    if {$label eq "eager"} {
        if {[catch {native::evalHir $hir -virtual-construction-opt 0} value]} {
            return [list error $value]
        }
        return [list value [core::value::show $value 1]]
    }
    return [lrange [corpus::outcome $label $hir] 0 1]
}

set counts [dict create plan 0 flat 0 none 0 mixed 0]
set disagreements 0
set mispredictions 0
set keepDir ""
for {set i 0} {$i < [dict get $options -n]} {incr i} {
    set p [genProgram]
    set text [render $p]
    set expected [list value "\[[join [lmap in [dict get $p inputs] {listText [model $p {*}$in]}] {, }]\]"]
    set problems {}
    if {[catch {
        set hir [surface::compile $text fuzz.bot -strict 1 -warnings off]
        set got [verdict $hir]
        set predicted [predict $p]
        dict incr counts $got
        if {$got ne $predicted && $got ne "none"} {
            incr mispredictions
            lappend problems "decision: compiler $got, model $predicted"
        }
        foreach label [concat [dict get $options -backends] eager] {
            set o [outcome $label $hir]
            if {$o ne $expected} {
                lappend problems "$label: $o (model: $expected)"
            }
        }
    } message]} {
        lappend problems "compile: [lindex [split $message \n] 0]"
    }
    if {[llength $problems]} {
        if {![string match decision* [lindex $problems 0]] || [llength $problems] > 1} {
            incr disagreements
        }
        puts "PROGRAM $i (seed [dict get $options -seed]):\n$text"
        foreach line $problems { puts "  $line" }
        if {[dict get $options -keep]} {
            if {$keepDir eq ""} { set keepDir [file tempdir fvc-fuzz] }
            set path [file join $keepDir program$i.bot]
            set f [open $path w]
            fconfigure $f -encoding utf-8 -translation lf
            puts -nonewline $f $text
            close $f
            puts "  kept: $path"
        }
    }
}
puts "programs [dict get $options -n] plan [dict get $counts plan] flat [dict get $counts flat] unreached [dict get $counts none] disagreements $disagreements mispredictions $mispredictions"
exit [expr {$disagreements > 0 || $mispredictions > 0}]
