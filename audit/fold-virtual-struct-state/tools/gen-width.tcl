# gen-width.tcl -- writes FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1.md's width
# inputs into audit/fold-virtual-struct-state/width/ (tools/measure.tcl
# measures them; the census's spill-W.bot beside them in economics/ is the
# shape whose fields are live across a call):
#
#   few-W.bot     a W-field Int struct carried for n iterations, one field
#                 updated, the others carried unchanged (no call)
#   most-W.bot    every field updated every iteration (no call)
#   branch-W.bot  a third of the iterations complete with the intermediate
#                 itself, the rest rebuild every field
#   ret-W.bot     the fold is a function's value: its result crosses an
#                 exact return (retmulti while W fits the return ceiling)
#   nested-W.bot  W-1 Int fields and a nested {a, b} struct field rebuilt
#                 every iteration (one carried field: no cut)
#
#   spill-W.bot   every field updated every iteration after a call of a
#                 recursive function (every field live across a call: the
#                 census's spill-W shape, extended past its 64)
#
# W = 2 4 6 8 16 32 64 for the first five, and 128 256 for most and spill.
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/gen-width.tcl

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set dir [file join $root audit fold-virtual-struct-state width]
file mkdir $dir

proc write {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

proc decl {w {nested 0}} {
    set text "struct S:\n"
    for {set i 0} {$i < $w - $nested} {incr i} {
        append text "    f$i: int\n"
    }
    if {$nested} {
        append text "    inner: P\n"
    }
    return $text
}

proc fields {w body {nested 0}} {
    set parts {}
    for {set i 0} {$i < $w - $nested} {incr i} {
        lappend parts "f$i: [string map [list @ $i] $body]"
    }
    return [join $parts {, }]
}

foreach w {2 4 6 8 16 32 64} {
    set last [expr {$w - 1}]
    set head "import std::list\n\n"
    set init "S {[fields $w 0]}"
    # few
    set parts [list "f0: (s.f0 + i).mod(1000)"]
    for {set i 1} {$i < $w} {incr i} {
        lappend parts "f$i: s.f$i"
    }
    write [file join $dir few-$w.bot] "# few-$w.bot -- a $w-field fold, one field updated per iteration (tools/gen-width.tcl).
$head[decl $w]
fn f(n: int) -> int:
    t = fold i from 0 to n with intermediate s $init:
        S {[join $parts {, }]}
    t.f0 + t.f$last

n = 1000
f(n)
"
    # most
    write [file join $dir most-$w.bot] "# most-$w.bot -- a $w-field fold, every field updated per iteration (tools/gen-width.tcl).
$head[decl $w]
fn f(n: int) -> int:
    t = fold i from 0 to n with intermediate s $init:
        S {[fields $w {(s.f@ + i * @ + 1).mod(1000)}]}
    t.f0 + t.f$last

n = 1000
f(n)
"
    # branch
    write [file join $dir branch-$w.bot] "# branch-$w.bot -- a $w-field fold, a third of its iterations an identity completion (tools/gen-width.tcl).
$head[decl $w]
fn f(n: int) -> int:
    t = fold i from 0 to n with intermediate s $init:
        if i.mod(3) == 0:
            s
        else:
            S {[fields $w {(s.f@ + i + @).mod(1000)}]}
    t.f0 + t.f$last

n = 1000
f(n)
"
    # ret
    write [file join $dir ret-$w.bot] "# ret-$w.bot -- a $w-field fold as a function's value, read by its caller (tools/gen-width.tcl).
$head[decl $w]
fn g(n: int) -> S:
    fold i from 0 to n with intermediate s $init:
        S {[fields $w {(s.f@ + i + @).mod(1000)}]}

fn f(n: int, k: int) -> int:
    t = g(n + k * 0)
    t.f0 + t.f$last

n = 1000
f(n, 1)
"
    # nested
    set nlast [expr {$w - 2}]
    write [file join $dir nested-$w.bot] "# nested-$w.bot -- $w fields, one of them a nested struct rebuilt per iteration (tools/gen-width.tcl).
${head}struct P:
    a: int
    b: int

[decl $w 1]
fn f(n: int) -> int:
    t = fold i from 0 to n with intermediate s S {[fields $w 0 1], inner: P {a: 0, b: 0}}:
        S {[fields $w {(s.f@ + i).mod(1000)} 1], inner: P {a: (s.inner.a + i).mod(1000), b: s.inner.b + 1}}
    t.f0 + t.inner.a + t.inner.b

n = 1000
f(n)
"
}
foreach w {128 256} {
    set last [expr {$w - 1}]
    set head "import std::list\n\n"
    set init "S {[fields $w 0]}"
    write [file join $dir most-$w.bot] "# most-$w.bot -- a $w-field fold, every field updated per iteration (tools/gen-width.tcl).
$head[decl $w]
fn f(n: int) -> int:
    t = fold i from 0 to n with intermediate s $init:
        S {[fields $w {(s.f@ + i * @ + 1).mod(1000)}]}
    t.f0 + t.f$last

n = 1000
f(n)
"
}
foreach w {2 16 64 128 256} {
    set last [expr {$w - 1}]
    set head "import std::list\n\n"
    set init "S {[fields $w 0]}"
    write [file join $dir spill-$w.bot] "# spill-$w.bot -- a $w-field fold whose fields are live across a call every iteration (tools/gen-width.tcl).
$head[decl $w]
# Recursive, so native lowering keeps it a call.
fn step(x: int) -> int:
    if x < 7:
        return x + 1
    step(x - 7)

fn f(n: int) -> int:
    t = fold i from 0 to n with intermediate s $init:
        k = step(i.mod(14))
        S {[fields $w {(s.f@ + k * @).mod(1000)}]}
    t.f0 + t.f$last

n = 1000
f(n)
"
}
puts "wrote [llength [glob -directory $dir *.bot]] programs into $dir"
