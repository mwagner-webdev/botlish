# fuzz.tcl -- a fuzzer of Botlish variadic parameters against an independent
# model (VARIADICS-VERTICAL-SLICE-1.md, "Fuzzing").
#
#   tclsh9.0 audit/variadics/tools/fuzz.tcl ?-n N? ?-seed S? ?-functions K?
#                                           ?-calls C? ?-gc-stress 0|1?
#                                           ?-verbose 0|1?
#
# Each of N programs declares K variadic functions and makes C calls of
# them. A function draws 0 to 3 fixed Int parameters, sometimes a flag, and
# its variadic section: List[int], List[Small] (a domain, each trailing
# argument proven in it by its own proof), List[str] or a bare List (the
# element type each call imprints). Its body folds the fixed parameters,
# the List's length and (for Int and String elements) a position-weighted
# sum of its elements into one Int, so a lost, duplicated, reordered or
# misplaced argument changes the result. A call is spelled as a free call,
# in method syntax (its first fixed argument the receiver), through an alias
# (`g = f`) or -- for a function with no fixed parameter and no flag --
# through a function value, which passes the List itself (neither for a
# bare List's function: an imprinted callable is no value); its trailing
# arguments are 0 to 12 literals of the element type, and an Int one may be
# a nested variadic call. This file's own model computes every call's value.
#
# Each program must produce the model's list on every backend (interp,
# compile, cranelift-generic, cranelift; the native ones under
# BOTLISH_NATIVE_GC_STRESS=1 with -gc-stress 1) and when written as HIR
# interchange and decoded (the same value, the same variadic call facts);
# its HIR text (hir::format) must mark every variadic call with the facts
# the HIR holds. (HIR text of a program using a library module does not
# read back -- the module's bindings are not in it -- so hir::parse is
# tests/variadics.test's, on programs without one.) The last line is "programs N functions F calls C trailing T
# disagreements D" (the exit status is 1 on any disagreement); every
# disagreement is printed with the program's source.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -n 20 -seed 1 -functions 6 -calls 14 -gc-stress 0 -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc between {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

set prelude {import std::list
import std::str

type Small = Int in 0..9

fn weigh(xs: List[int], i: int, acc: int) -> int:
    if i == xs.length():
        acc
    else:
        x = xs.at(i):
            on IndexNotFound:
                0
        weigh(xs, i + 1, acc + (i + 1) * x)

fn weigh_small(xs: List[Small], i: int, acc: int) -> int:
    if i == xs.length():
        acc
    else:
        x = xs.at(i):
            on IndexNotFound:
                0
        weigh_small(xs, i + 1, acc + (i + 1) * x)

fn letters(xs: List[str], i: int, acc: int) -> int:
    if i == xs.length():
        acc
    else:
        x = xs.at(i):
            on IndexNotFound:
                ""
        letters(xs, i + 1, acc + (i + 1) * std::str::length(x))

fn apply(f, xs):
    f(xs)

}

# Function I: {name fI fixed {C...} element int|small|str|bare flag 0|1
# weight W length L base B loud D}.
proc drawFunction {i} {
    set fixed [lmap _ [lrepeat [pick {0 1 1 2 3}] x] {between -9 9}]
    return [dict create name f$i fixed $fixed element [pick {int int small str bare}] \
        flag [chance 0.2] weight [between 1 9] length [between 0 20] base [between -100 100] loud [between 100 999]]
}

proc functionText {f} {
    set params {}
    set terms {}
    set k 0
    foreach c [dict get $f fixed] {
        lappend params "a$k: int"
        lappend terms "a$k * $c"
        incr k
    }
    if {[dict get $f flag]} { lappend params "flags :loud" }
    set type [dict get {int List[int] small List[Small] str List[str] bare List} [dict get $f element]]
    lappend params "variadic xs: $type"
    switch -- [dict get $f element] {
        int { lappend terms "weigh(xs, 0, 0) * [dict get $f weight]" }
        small { lappend terms "weigh_small(xs, 0, 0) * [dict get $f weight]" }
        str { lappend terms "letters(xs, 0, 0) * [dict get $f weight]" }
    }
    lappend terms "std::list::length(xs) * [dict get $f length]" "[dict get $f base]"
    set text "fn [dict get $f name]([join $params {, }]) -> int:\n"
    if {[dict get $f flag]} {
        append text "    total = [join $terms { + }]\n    if loud:\n        total + [dict get $f loud]\n    else:\n        total\n\n"
    } else {
        append text "    [join $terms { + }]\n\n"
    }
    return $text
}

# The model's value of a call of F with FIXED, TRAILING (each {text VALUE
# model M}) and LOUD.
proc model {f fixed trailing loud} {
    set total [dict get $f base]
    foreach c [dict get $f fixed] a $fixed { incr total [expr {$c * $a}] }
    set i 0
    set weighted 0
    foreach t $trailing {
        incr i
        switch -- [dict get $f element] {
            int - small { incr weighted [expr {$i * [dict get $t model]}] }
            str { incr weighted [expr {$i * [string length [dict get $t model]]}] }
        }
    }
    incr total [expr {$weighted * [dict get $f weight] + [llength $trailing] * [dict get $f length]}]
    if {$loud} { incr total [dict get $f loud] }
    return $total
}

# A trailing argument for F: {text TEXT model VALUE}; an Int one may be a
# nested call (depth DEPTH) of a function of FUNCTIONS.
proc drawTrailing {f functions depth bareKind} {
    switch -- [dict get $f element] {
        int {
            if {$depth < 2 && [chance 0.15]} {
                return [drawCall [pick $functions] $functions [expr {$depth + 1}] 1]
            }
            set v [between -50 50]
            return [dict create text $v model $v]
        }
        small {
            set v [between 0 9]
            return [dict create text $v model $v]
        }
        str {
            set s [string range [pick {"" a bc def ghij klmno}] 0 end]
            return [dict create text "\"$s\"" model $s]
        }
        bare {
            switch -- $bareKind {
                int { set v [between -5 5]; return [dict create text $v model $v] }
                str { return [dict create text "\"[pick {x yy zzz}]\"" model s] }
                bool { set v [pick {true false}]; return [dict create text $v model $v] }
            }
        }
    }
}

# A call of F: {text TEXT model VALUE trailing T}. A nested call (NESTED)
# is always a free call (an alias or the value form needs a binding).
proc drawCall {f functions depth nested} {
    set fixed [lmap _ [dict get $f fixed] {between -20 20}]
    set bareKind [pick {int str bool}]
    set trailing {}
    set count [pick [list 0 1 2 [between 3 6] [between 7 12]]]
    for {set j 0} {$j < $count} {incr j} {
        lappend trailing [drawTrailing $f $functions $depth $bareKind]
    }
    set loud [expr {[dict get $f flag] && [chance 0.5]}]
    set args [concat $fixed [lmap t $trailing {dict get $t text}] [expr {$loud ? ":loud" : ""}]]
    set name [dict get $f name]
    set spelling free
    if {!$nested} {
        set spelling [pick {free free method alias value}]
    }
    if {$spelling eq "method" && [llength $fixed] == 0} { set spelling free }
    # An imprinted callable (a bare List's) is no value: no alias, no value.
    if {$spelling in {alias value} && [dict get $f element] eq "bare"} { set spelling free }
    # Through a value the List is a literal, whose static type keeps no
    # element's range: a List[Small] parameter takes none.
    if {$spelling eq "value" && ([llength $fixed] > 0 || [dict get $f flag] || [dict get $f element] eq "small")} { set spelling free }
    switch -- $spelling {
        free { set text "$name\([join $args {, }])" }
        method { set text "([lindex $args 0]).$name\([join [lrange $args 1 end] {, }])" }
        alias { set text "g_$name\([join $args {, }])" }
        value { set text "apply($name, \[[join $args {, }]\])" }
    }
    set total [llength $trailing]
    foreach t $trailing { incr total [dict getdef $t trailing 0] }
    return [dict create text $text model [model $f $fixed $trailing $loud] trailing $total]
}

proc program {functions calls} {
    set text $::prelude
    foreach f $functions { append text [functionText $f] }
    foreach f $functions {
        if {[dict get $f element] ne "bare"} { append text "g_[dict get $f name] = [dict get $f name]\n" }
    }
    set elements {}
    set i 0
    foreach c $calls {
        append text "r$i = [dict get $c text]\n"
        lappend elements r$i
        incr i
    }
    append text "\[[join $elements {, }]\]\n"
    return $text
}

# The variadic call facts of HIR, in node order.
proc variadicFacts {hir} {
    set facts {}
    foreach e [lsort -dictionary [dict keys [dict get $hir exprs]]] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] eq "call" && [dict exists $node variadic]} {
            lappend facts [dict get $node variadic]
        }
    }
    return $facts
}

expr {srand([dict get $options -seed])}
set backends {interp compile cranelift-generic cranelift}
set programs 0
set functionCount 0
set callCount 0
set trailingCount 0
set disagreements 0
for {set p 0} {$p < [dict get $options -n]} {incr p} {
    set functions {}
    for {set i 0} {$i < [dict get $options -functions]} {incr i} {
        lappend functions [drawFunction $i]
    }
    set calls {}
    for {set i 0} {$i < [dict get $options -calls]} {incr i} {
        lappend calls [drawCall [pick $functions] $functions 0 0]
    }
    set source [program $functions $calls]
    set expected "\[[join [lmap c $calls {dict get $c model}] {, }]\]"
    set problem ""
    set path [file join [file tempdir botlish-variadics-fuzz-] p$p.bot]
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $source
    close $channel
    if {[catch {surface::readProgramFile $path -cache "" -warnings off} hir]} {
        set problem "did not compile: $hir"
    } else {
        if {[dict get $options -gc-stress]} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 }
        foreach backend $backends {
            lassign [outcomeUnderHir $backend $hir] tag value message
            if {$tag ne "value" || $value ne $expected} {
                append problem "$backend: expected $expected\n  got $tag $value $message\n"
            }
        }
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
        set marks [lmap {- fixed count} [regexp -all -inline -line { variadic ([0-9]+) ([0-9]+)(?: |$)} [hir::format $hir]] {
            dict create fixed $fixed count $count
        }]
        if {[lsort $marks] ne [lsort [variadicFacts $hir]]} {
            append problem "HIR text marks [llength $marks] variadic calls, the HIR [llength [variadicFacts $hir]]\n"
        }
        set back [hir::interchange::decode [hir::interchange::encode $hir]]
        if {[variadicFacts $back] ne [variadicFacts $hir]} {
            append problem "interchange: the variadic call facts differ\n"
        }
        set backend [lindex $backends [expr {$p % [llength $backends]}]]
        lassign [outcomeUnderHir $backend $back] tag value
        if {$tag ne "value" || $value ne $expected} {
            append problem "interchange, $backend: expected $expected\n  got $tag $value\n"
        }
    }
    file delete -force [file dirname $path]
    incr programs
    incr functionCount [llength $functions]
    incr callCount [llength $calls]
    foreach c $calls { incr trailingCount [dict get $c trailing] }
    if {$problem ne ""} {
        incr disagreements
        puts "DISAGREEMENT program $p:\n$problem--- source:\n$source"
    } elseif {[dict get $options -verbose]} {
        puts "program $p: $expected"
    }
}
puts "programs $programs functions $functionCount calls $callCount trailing $trailingCount disagreements $disagreements"
exit [expr {$disagreements > 0}]
