#!/usr/bin/env tclsh9.0
# determinism.tcl -- M7.a determinism / order-sensitivity / monotonicity
# observations (M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md, questions 58-62).
# Observation only.
#
#   tclsh9.0 audit/m7a-instance-selection/tools/determinism.tcl
#
# 1. Re-running the same analysis on the same program gives the same
#    instance table (labels, keys, entry Ranges).
# 2. Reordering independent call statements: instance *labels* and entry
#    facts vs. InstanceIds (discovery order).
# 3. The per-block specialization limit (hir::specialize::limit, 8): which
#    argument-kind keys get their own instance depends on discovery order.
# 4. Adding a caller only ever widens a shared instance's entry fact.

source [file join [file dirname [file normalize [info script]]] lib.tcl]

proc Table {hir a names} {
    set rows {}
    foreach d [m7a::instanceData $hir $a] {
        if {[dict get $d name] ni $names} continue
        lappend rows [list [dict get $d label] [lmap p [dict get $d params] {dict get $p entry}]]
    }
    return [lsort $rows]
}

proc Ids {hir a names} {
    set rows {}
    foreach d [m7a::instanceData $hir $a] {
        if {[dict get $d name] ni $names} continue
        lappend rows "[dict get $d id]=[dict get $d label]"
    }
    return $rows
}

# 1. Identical re-run -------------------------------------------------------
set src {fn f(x):
    if x < 100:
        1
    else:
        2
fn g(y):
    f(y)
f(5)
g(500)
f("s")
}
set h1 [m7a::source $src]
set h2 [m7a::source $src]
set t1 [Table $h1 [m7a::analyze $h1] {f g}]
set t2 [Table $h2 [m7a::analyze $h2] {f g}]
puts "1. identical re-run: [expr {$t1 eq $t2 ? {same instance table} : {DIFFERENT}}]"
puts "   $t1"

# 2. Statement order ----------------------------------------------------------
# (f's body must be valid for both kinds: an always-raising instance --
# e.g. `x < 100` on a Str -- has result never, which makes every later
# statement unreachable, a different effect from the one measured here.)
set fwd {fn f(x):
    x
fn g(y):
    f(y)
f(5)
g(500)
f("s")
}
set rev {fn f(x):
    x
fn g(y):
    f(y)
f("s")
g(500)
f(5)
}
set hf [m7a::source $fwd]; set af [m7a::analyze $hf]
set hr [m7a::source $rev]; set ar [m7a::analyze $hr]
puts "2. reordered calls: labels+entries [expr {[Table $hf $af {f g}] eq [Table $hr $ar {f g}] ? {identical} : {DIFFER}}]"
puts "   forward ids: [Ids $hf $af {f g}]  [Table $hf $af {f g}]"
puts "   reverse ids: [Ids $hr $ar {f g}]  [Table $hr $ar {f g}]"

# 3. Instance limit -----------------------------------------------------------
set kinds [list 1 {"s"} true unit {'c'} {[1]} {["s"]} {[true]} {[[1]]} {[unit]}]
set body "fn f(x):\n    x\n"
set forward $body
foreach k $kinds { append forward "f($k)\n" }
set reverse $body
foreach k [lreverse $kinds] { append reverse "f($k)\n" }
set hf [m7a::source $forward]; set af [m7a::analyze $hf]
set hr [m7a::source $reverse]; set ar [m7a::analyze $hr]
puts "3. per-block limit ($hir::specialize::limit specialized instances), [llength $kinds] distinct argument kinds:"
puts "   forward order instances: [lsort [lmap r [Table $hf $af f] {lindex $r 0}]]"
puts "   reverse order instances: [lsort [lmap r [Table $hr $ar f] {lindex $r 0}]]"
set cf [dict create]
foreach {e t} [dict get [dict get $af spec] instances i0 calls] { dict set cf $e [hir::specialize::label [dict get $af spec] $t] }
puts "   forward: call -> instance: [dict values $cf]"
set cr [dict create]
foreach {e t} [dict get [dict get $ar spec] instances i0 calls] { dict set cr $e [hir::specialize::label [dict get $ar spec] $t] }
puts "   reverse: call -> instance: [dict values $cr]"

# 4. Adding a caller ----------------------------------------------------------
set base "fn f(x):\n    if x < 100:\n        1\n    else:\n        2\n"
foreach {label calls} {
    "f(5)" "f(5)\n"
    "f(5) + f(9)" "f(5)\nf(9)\n"
    "f(5) + f(9) + f(500)" "f(5)\nf(9)\nf(500)\n"
    "f(5) + f(9) + f(500) + g(length(s))" "fn g(s):\n    f(length(s))\nf(5)\nf(9)\nf(500)\ng(\"abc\")\n"
} {
    set h [m7a::source "$base$calls"]
    set a [m7a::analyze $h]
    set c [m7a::conditionData $h $a f]
    puts [format "4. %-40s entry %-28s x < 100 -> %s" $label \
        [lindex [Table $h $a f] 0 1] [expr {[dict get [lindex $c 0] outcome] eq {} ? {Unknown} : ([dict get [lindex $c 0] outcome] ? {AlwaysTrue} : {AlwaysFalse})}]]
}
