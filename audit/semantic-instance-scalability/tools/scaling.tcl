# scaling.tcl -- what semantic instances cost, as the program, the number of
# instances and the instantiated function's own size vary independently
# (SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md, "Measurements").
#
#   tclsh9.0 audit/semantic-instance-scalability/tools/scaling.tcl ROOT POINT...
#
# Each POINT is N:K:B -- a program of N struct types and N calls of one
# untyped helper `choose` (audit/mid-end-port/tools/budget.tcl's program),
# call I giving it type T((I - 1) mod K + 1), so K distinct semantic
# instances whatever N is, and choose's body B statements of Int arithmetic
# longer (a larger region per instance). Each point is compiled (the front
# end of checkout ROOT, warnings off, no cache) in a process of its own, and
# one line is printed per point:
#
#   N K B lines outcome front-end-s infer-s walks walk-s walk-ms verify-s instances peak-MB
#
# infer-s is hir::signatures::infer's inclusive time (type inference,
# instance walks included), walk-s hir::semantic::Walk's (every instance
# walk of every build), verify-s hir::semantic::verify's; peak-MB the
# process's peak resident size. outcome is `ok` or the error code: a ROOT
# before the milestone rejects K > 16 (TYPE).

set here [file dirname [file normalize [info script]]]
set root [file normalize [lindex $argv 0]]
if {[lindex $argv 1] ne "-one"} {
    puts "# N K B lines outcome front-end-s infer-s walks walk-s walk-ms verify-s instances peak-MB"
    foreach point [lrange $argv 1 end] {
        lassign [split $point :] n k b
        puts [exec [info nameofexecutable] [info script] $root -one $n $k $b 2>@ stderr]
    }
    exit 0
}
lassign [lrange $argv 2 end] n k b
source [file join $root surface surface.tcl]
source [file join $here .. .. mid-end-port tools timing.tcl]
timing::wrap {::hir::semantic::Walk ::hir::semantic::verify ::hir::signatures::infer}
proc peakMb {} {
    set channel [open /proc/self/status]
    set kb ""
    foreach line [split [read $channel] \n] {
        if {[regexp {^VmHWM:\s+(\d+)} $line -> kb]} break
    }
    close $channel
    return [expr {$kb / 1024}]
}
set text "struct Fact:\n    v: int\n\nfn choose(c, x, y):\n"
set previous 1
for {set i 1} {$i <= $b} {incr i} {
    append text "    a$i = $previous * 3 + $i\n"
    set previous a$i
}
if {$b > 0} {
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
    set t [expr {($i - 1) % $k + 1}]
    append text "pick$i = choose(true, T$t {f: Fact {v: $i}, tag$t: 0}, T$t {f: Fact {v: 0}, tag$t: 1})\n"
    if {$i == 1} {
        append text "total1 = value(pick1.f)\n"
    } else {
        append text "total$i = total[expr {$i - 1}] + value(pick$i.f)\n"
    }
}
append text "total$n\n"
set scratch [file tempdir semantic-scaling]
try {
    set warm [file join $scratch warm.bot]
    set channel [open $warm w]; puts $channel 1; close $channel
    surface::readProgramFile $warm -warnings off -cache ""
    timing::reset
    set path [file join $scratch scaling.bot]
    set channel [open $path w]; puts -nonewline $channel $text; close $channel
    set t0 [clock microseconds]
    set failed [catch {surface::readProgramFile $path -warnings off -cache ""} hir options]
    set front [expr {([clock microseconds] - $t0) / 1e6}]
    set outcome [if {$failed} {lindex [dict get $options -errorcode] end} else {string cat ok}]
    set instances [if {$failed} {string cat -} else {dict size [dict get $hir semantic instances]}]
    set walks [timing::calls ::hir::semantic::Walk]
    set walkSeconds [timing::seconds ::hir::semantic::Walk]
    puts [format "%d %d %d %d %s %.2f %.2f %d %.2f %.2f %.2f %s %d" $n $k $b \
        [llength [split $text \n]] $outcome $front [timing::seconds ::hir::signatures::infer] \
        $walks $walkSeconds [expr {$walks == 0 ? 0.0 : 1e3 * $walkSeconds / $walks}] \
        [timing::seconds ::hir::semantic::verify] $instances [peakMb]]
} finally {
    file delete -force $scratch
}
