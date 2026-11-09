# fuzz.tcl -- random nested programs against an independent model
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md).
#
#   tclsh9.0 audit/depth-safe-nesting/tools/fuzz.tcl ?-seed N? ?-programs N?
#       ?-depth N? ?-backends LIST? ?-segments LIST?
#
# Each program is one expression whose spine nests up to -depth levels
# (random, 1500 by default) through every production in turn --
# parentheses, unary minus, `not`, `+`/`-` either way round, `and`/`or`,
# `==`, calls, method calls, List literals, constructions projected again,
# and a List's length -- with small random siblings along the way. The
# generator works out the value as it builds the text (its own model of
# each production; it never asks the compiler), and every program is
# compiled at Tcl's default recursion limit of 1000 nested evaluations:
#
#   * valid: it must compile and show that value on every backend of
#     -backends (interp and cranelift by default), and compile to the same
#     HIR text with segments of a random size from -segments as with the
#     default (core/deep.tcl: segments change where frames live, nothing
#     else);
#   * malformed (one closing bracket of the spine removed, or an operator
#     put before one): it must be the parser's syntax diagnostic.
#
# Never TCL LIMIT STACK, never another Tcl error. Prints each failure with
# its seed and program number (and the program); exit status 1 on any.

set options [dict create -seed 1 -programs 12 -depth 1500 -backends {interp cranelift} -segments {2 3 7 25 60}]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "unknown option $option"
    }
    dict set options $option $value
}
set ::dsnOptions $options
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
set options $::dsnOptions
expr {srand([dict get $options -seed])}

proc Pick {list} {
    return [lindex $list [expr {int(rand() * [llength $list])}]]
}

proc Chance {p} {
    return [expr {rand() < $p}]
}

# A small leaf of TYPE (int, bool or list): {TEXT VALUE}. A List's value is
# its elements' values, each {TYPE VALUE}.
proc Leaf {type} {
    switch -- $type {
        int { set k [expr {int(rand() * 19) - 9}]; return [list $k $k] }
        bool { set b [Pick {true false}]; return [list $b $b] }
        list { set k [expr {int(rand() * 9)}]; return [list "\[$k\]" [list [list int $k]]] }
    }
}

# One level around the expression {TEXT VALUE} of TYPE: {TEXT VALUE TYPE}.
# Every production of the grammar the spine runs through, each with its
# meaning in the model.
proc Wrap {text value type} {
    switch -- $type {
        int {
            switch -- [Pick {paren neg add sub rsub call method box list length eq}] {
                paren  { return [list "($text)" $value int] }
                neg    { return [list "-($text)" [expr {-$value}] int] }
                add    { lassign [Leaf int] t v; return [list "$t + ($text)" [expr {$v + $value}] int] }
                sub    { lassign [Leaf int] t v; return [list "($text) - $t" [expr {$value - $v}] int] }
                rsub   { lassign [Leaf int] t v; return [list "$t - ($text)" [expr {$v - $value}] int] }
                call   { return [list "same($text)" $value int] }
                method { return [list "($text).inc()" [expr {$value + 1}] int] }
                box    { return [list "Box \{value: $text\}.value" $value int] }
                list   { return [list "\[$text\]" [list [list int $value]] list] }
                length { return [list "std::list::length(\[$text, 0\])" 2 int] }
                eq     { lassign [Leaf int] t v; return [list "($text) == $t" [expr {$value == $v ? "true" : "false"}] bool] }
            }
        }
        bool {
            switch -- [Pick {paren not and or call box}] {
                paren { return [list "($text)" $value bool] }
                not   { return [list "not ($text)" [expr {$value eq "true" ? "false" : "true"}] bool] }
                and   { lassign [Leaf bool] t v; return [list "($text) and $t" [expr {$value eq "true" && $v eq "true" ? "true" : "false"}] bool] }
                or    { lassign [Leaf bool] t v; return [list "$t or ($text)" [expr {$value eq "true" || $v eq "true" ? "true" : "false"}] bool] }
                call  { return [list "same($text)" $value bool] }
                box   { return [list "Box \{value: $text\}.value" $value bool] }
            }
        }
        list {
            switch -- [Pick {paren call box nest pair length}] {
                paren  { return [list "($text)" $value list] }
                call   { return [list "same($text)" $value list] }
                box    { return [list "Box \{value: $text\}.value" $value list] }
                nest   { return [list "\[$text\]" [list [list list $value]] list] }
                pair   { lassign [Leaf list] t v; return [list "\[$text, $t\]" [list [list list $value] [list list $v]] list] }
                length { return [list "std::list::length($text)" [llength $value] int] }
            }
        }
    }
}

# The model's value as core::value::show prints it.
proc Shown {type value} {
    if {$type ne "list"} {
        return $value
    }
    return "\[[join [lmap item $value {Shown {*}$item}] {, }]\]"
}

# A program whose expression nests DEPTH levels: {SOURCE SHOWN}.
proc Program {depth} {
    set type [Pick {int bool list}]
    lassign [Leaf $type] text value
    for {set i 0} {$i < $depth} {incr i} {
        lassign [Wrap $text $value $type] text value type
    }
    set header "import std::list\n\nstruct Box:\n    value: any\n\nfn same(a):\n    return a\n\nfn inc(a):\n    return a + 1\n\n"
    return [list "${header}x = $text\nx\n" [Shown $type $value]]
}

# SOURCE with one closing bracket of the expression line removed, or an
# operator put before one: a program with one syntax error.
proc Malformed {source} {
    set lines [split $source \n]
    set at [lsearch -glob $lines "x = *"]
    set line [lindex $lines $at]
    set closers [regexp -all -indices -inline {[)\]\}]} $line]
    lassign [Pick $closers] position
    if {[Chance 0.5]} {
        set line [string replace $line $position $position]
    } else {
        set line [string replace $line $position $position " +[string index $line $position]"]
    }
    return [join [lreplace $lines $at $at $line] \n]
}

proc Outcome {hir backend} {
    switch -- $backend {
        interp { set value [core::evalProgram [hir::lower $hir]] }
        compile { set value [core::compiler::evalHir $hir] }
        cranelift { set value [native::evalHir $hir] }
        cranelift-generic { set value [native::evalHir $hir -specialize 0] }
    }
    return [core::value::show $value 1]
}

# Compiles SOURCE at the default limit with segments SIZE frames deep:
# {ok HIR} or {error CODE MESSAGE}.
proc Compile {source {size 60}} {
    set saved [list $core::deep::segment $core::deep::outside $core::deep::bound]
    lassign [list $size [expr {max($size, 200)}] [expr {max($size, 200)}]] core::deep::segment core::deep::outside core::deep::bound
    interp recursionlimit {} 1000
    try {
        if {[catch {surface::compile $source -warnings off} hir options]} {
            return [list error [dict get $options -errorcode] $hir]
        }
        return [list ok $hir]
    } finally {
        interp recursionlimit {} 1000
        lassign $saved core::deep::segment core::deep::outside core::deep::bound
    }
}

set failures 0
proc Fail {n message source} {
    incr ::failures
    puts "FAIL seed [dict get $::dsnOptions -seed] program $n: $message"
    puts "  [string range [string map {\n { | }} $source] 0 600]"
}

for {set n 1} {$n <= [dict get $options -programs]} {incr n} {
    set depth [expr {1 + int(rand() * [dict get $options -depth])}]
    lassign [Program $depth] source shown
    lassign [Compile $source] status hir message
    if {$status ne "ok"} {
        Fail $n "depth $depth: did not compile: $hir $message" $source
        continue
    }
    core::useProgramRecursionLimit
    foreach backend [dict get $options -backends] {
        if {[catch {Outcome $hir $backend} got]} {
            Fail $n "depth $depth $backend: $got" $source
        } elseif {$got ne $shown} {
            Fail $n "depth $depth $backend: $got, the model says $shown" $source
        }
    }
    set size [Pick [dict get $options -segments]]
    lassign [Compile $source $size] status other
    if {$status ne "ok" || [hir::format $other] ne [hir::format $hir]} {
        Fail $n "depth $depth: segments of $size frames build another HIR" $source
    }
    set bad [Malformed $source]
    lassign [Compile $bad] status code message
    if {$status ne "error" || [lrange $code 0 1] ne {SURFACE SYNTAX}} {
        Fail $n "depth $depth malformed: $status [lrange $code 0 2] [string range $message 0 200]" $bad
    }
    puts "program $n: depth $depth, [lindex $shown 0 0][expr {[string length $shown] > 40 ? "..." : ""}] ok"
    flush stdout
}
puts "seed [dict get $options -seed]: [dict get $options -programs] programs, $failures failures"
exit [expr {$failures > 0}]
