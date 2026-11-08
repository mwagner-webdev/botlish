# budget.tcl -- the semantic-instance budget as a program's size grows
# (audit/mid-end-port/README.md, "The scale experiment" and "The
# semantic-instance budget"): an untyped helper called with N struct types,
# whose result reaches a typed parameter.
#
#   tclsh9.0 audit/mid-end-port/tools/budget.tcl ?-types {15 16 17 18}?
#       ?-max-per-block 16? ?-max-instances 2000? ?-body 0? ?-distinct K?
#
# For each N, writes in a `file tempdir` directory
#
#   struct Fact: v: int
#   fn choose(c, x, y): ... if c: x else: y   (untyped; -body B adds B
#                                             statements of Int arithmetic
#                                             on c before the choice, so an
#                                             instance's walk costs more)
#   fn value(f: Fact) -> int: f.v              (typed)
#   struct T1 ... TN, each holding a Fact
#   pickI = choose(true, TI {...}, TI {...})
#   totalI = total(I-1) + value(pickI.f)              for I = 1..N
#
# -distinct K keeps the program the size N gives it (N structs, N calls)
# but makes call I use type T((I-1) mod K + 1): K distinct instances of
# choose, whatever N is -- the cost of an instance at a fixed program size.
#
# and compiles it (front end only, in this process), with
# hir::semantic::maxPerBlock and maxInstances set as given. Each call of
# choose with a new TI asks for a semantic instance of choose
# (hir/semantic.tcl); past maxPerBlock a request is declined and the call
# keeps choose's generic typing, so pickN.f is `any` and value's typed
# parameter refuses it. Prints N, the outcome, the compile time, the semantic
# counters and the process's peak resident size so far.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set options [dict create -types {15 16 17 18} -max-per-block 16 -max-instances 2000 -body 0 -distinct ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "budget.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $checkout surface surface.tcl]
set ::hir::semantic::maxPerBlock [dict get $options -max-per-block]
set ::hir::semantic::maxInstances [dict get $options -max-instances]
proc peakMb {} {
    if {[catch {open /proc/self/status} channel]} { return "" }
    set kb ""
    foreach line [split [read $channel] \n] {
        if {[regexp {^VmHWM:\s+(\d+)} $line -> kb]} break
    }
    close $channel
    return [expr {$kb / 1024}]
}
puts "# budget: maxPerBlock [dict get $options -max-per-block], maxInstances [dict get $options -max-instances]; choose's body: [dict get $options -body] extra statements; distinct types: [expr {[dict get $options -distinct] eq "" ? "N" : [dict get $options -distinct]}]"
set scratch [file tempdir mid-end-budget]
try {
    # Warm: load what a compilation loads lazily.
    set warm [file join $scratch warm.bot]
    set channel [open $warm w]; puts $channel 1; close $channel
    surface::readProgramFile $warm -warnings off -cache ""
    foreach n [dict get $options -types] {
        set text "struct Fact:\n    v: int\n\nfn choose(c, x, y):\n"
        set previous 1
        for {set i 1} {$i <= [dict get $options -body]} {incr i} {
            append text "    a$i = $previous * 3 + $i\n"
            set previous a$i
        }
        if {[dict get $options -body] > 0} {
            append text "    if $previous > 0 and c:\n        x\n    else:\n        y\n"
        } else {
            append text "    if c:\n        x\n    else:\n        y\n"
        }
        append text "\nfn value(f: Fact) -> int:\n    f.v\n"
        for {set i 1} {$i <= $n} {incr i} {
            append text "\nstruct T$i:\n    f: Fact\n    tag$i: int\n"
        }
        append text "\n"
        for {set i 1} {$i <= $n} {incr i} {
            set t $i
            if {[dict get $options -distinct] ne ""} {
                set t [expr {($i - 1) % [dict get $options -distinct] + 1}]
            }
            append text "pick$i = choose(true, T$t {f: Fact {v: $i}, tag$t: 0}, T$t {f: Fact {v: 0}, tag$t: 1})\n"
            # A running total, one short binding per call: a single sum of
            # N terms nests N deep, and the front end's nesting limit
            # rejects it near 1,024 terms (HASH-TABLE-COMPILER-PRESSURE.md,
            # CO-8), whatever the budget.
            if {$i == 1} {
                append text "total1 = value(pick1.f)\n"
            } else {
                append text "total$i = total[expr {$i - 1}] + value(pick$i.f)\n"
            }
        }
        append text "total$n\n"
        set path [file join $scratch budget-$n.bot]
        set channel [open $path w]
        puts -nonewline $channel $text
        close $channel
        set t0 [clock microseconds]
        set failed [catch {surface::readProgramFile $path -warnings off -cache ""} hir errorOptions]
        set seconds [format %.2f [expr {([clock microseconds] - $t0) / 1e6}]]
        if {$failed} {
            set message [string map [list $scratch/ ""] [lindex [split $hir \n] 0]]
            puts "$n types: rejected [lindex [dict get $errorOptions -errorcode] end] in $seconds s: $message"
        } else {
            set semantic [dict get $hir semantic]
            set perBlock 0
            dict for {block count} [dict get $semantic byBlock] { if {$count > $perBlock} { set perBlock $count } }
            puts "$n types: accepted in $seconds s; [dict size [dict get $semantic instances]] semantic instances, at most $perBlock of one function; declined: [dict get $semantic declinedCount]; peak [peakMb] MB"
        }
    }
} finally {
    file delete -force $scratch
}
