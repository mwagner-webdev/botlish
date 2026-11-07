# budget.tcl -- the semantic-instance budget as a program's size grows
# (audit/mid-end-port/README.md, "The scale experiment"): an untyped helper
# called with N struct types, whose result reaches a typed parameter.
#
#   tclsh9.0 audit/mid-end-port/tools/budget.tcl ?-types {15 16 17 18}?
#
# For each N, writes in a `file tempdir` directory
#
#   struct Fact: v: int
#   fn choose(c, x, y): if c: x else: y        (untyped)
#   fn value(f: Fact) -> int: f.v              (typed)
#   struct T1 ... TN, each holding a Fact
#   pickI = choose(true, TI {...}, TI {...}); value(pickI.f)   for I = 1..N
#
# and compiles it (front end only). Each call of choose with a new TI asks
# for a semantic instance of choose (hir/semantic.tcl); past maxPerBlock (16)
# a request is declined and the call keeps choose's generic typing, so
# pickN.f is `any` and value's typed parameter refuses it. Prints N, the
# outcome, and the semantic counters of the accepted programs.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set options [dict create -types {15 16 17 18}]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "budget.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $checkout surface surface.tcl]
set scratch [file tempdir mid-end-budget]
try {
    foreach n [dict get $options -types] {
        set text "struct Fact:\n    v: int\n\nfn choose(c, x, y):\n    if c:\n        x\n    else:\n        y\n\nfn value(f: Fact) -> int:\n    f.v\n"
        for {set i 1} {$i <= $n} {incr i} {
            append text "\nstruct T$i:\n    f: Fact\n    tag$i: int\n"
        }
        append text "\n"
        set sum {}
        for {set i 1} {$i <= $n} {incr i} {
            append text "pick$i = choose(true, T$i {f: Fact {v: $i}, tag$i: 0}, T$i {f: Fact {v: 0}, tag$i: 1})\n"
            append text "value$i = value(pick$i.f)\n"
            lappend sum value$i
        }
        append text "[join $sum { + }]\n"
        set path [file join $scratch budget-$n.bot]
        set channel [open $path w]
        puts -nonewline $channel $text
        close $channel
        if {[catch {surface::readProgramFile $path -warnings off -cache ""} hir options]} {
            set message [string map [list $scratch/ ""] [lindex [split $hir \n] 0]]
            puts "$n types: rejected [lindex [dict get $options -errorcode] end]: $message"
        } else {
            set semantic [dict get $hir semantic]
            set perBlock 0
            dict for {block count} [dict get $semantic byBlock] { if {$count > $perBlock} { set perBlock $count } }
            puts "$n types: accepted; [dict size [dict get $semantic instances]] semantic instances, at most $perBlock of one function; declined: [dict get $semantic declinedCount]"
        }
    }
} finally {
    file delete -force $scratch
}
