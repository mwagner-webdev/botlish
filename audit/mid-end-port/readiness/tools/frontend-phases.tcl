# frontend-phases.tcl -- where one front-end compilation's time goes, at the
# granularity PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md asks for
# (section 5.1): parsing and loading, hir::buildSyntax, its checks, the
# method-call decision's and the monomorphization's builds, type inference,
# semantic-instance walks and their verification, static decisions,
# warnings; plus hir::types::Block's per-call cost (section 5.3; the
# binding-type dictionary each body context inherits is
# audit/semantic-instance-scalability/tools/remaining-copies.tcl contexts).
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/frontend-phases.tcl FILE
#
# Run it in a process of its own (its peak is the process's VmHWM). Prints
# one line, `phases DICT`. Times are timing.tcl's wrappers (inclusive: the
# outermost activation of each; exclusive where named); the nested phases
# overlap (each of the decision's and the monomorphization's builds runs
# hir::check, which runs type inference).

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname [file dirname $here]]]]
set path [file normalize [lindex $argv 0]]
source [file join $checkout surface surface.tcl]
source [file join $checkout audit mid-end-port tools timing.tcl]

proc peakKb {} {
    if {[catch {open /proc/self/status} channel]} { return "" }
    set kb ""
    foreach line [split [read $channel] \n] {
        if {[regexp {^VmHWM:\s+(\d+)} $line -> kb]} break
    }
    close $channel
    return $kb
}

set phases {
    ::surface::modules::CollectAndLoad ::surface::modules::Parse ::hir::buildSyntax
    ::hir::check ::hir::DecideMethodCalls ::hir::traits::monomorphize ::hir::static::decide
    ::hir::signatures::infer ::hir::types::infer ::hir::semantic::Analyze ::hir::semantic::Walk
    ::hir::semantic::Verify ::hir::warnings::run ::surface::lower::Finish
    ::hir::resolve::program ::hir::errorsets::verify ::hir::affine::verify
    ::hir::completions::analyze ::hir::range::verify ::hir::types::Block
}
set phases [lmap p $phases { expr {[info procs $p] ne "" ? $p : [continue]} }]
timing::wrap $phases

set scratch [file tempdir frontend-phases]
set warm [file join $scratch warm.bot]
set channel [open $warm w]; puts $channel "x = 1\nx"; close $channel
surface::readProgramFile $warm -warnings off -cache ""
timing::reset
set baseline [peakKb]

set lines 0
foreach file [glob -directory [file dirname $path] *.bot] {
    set channel [open $file]
    incr lines [llength [split [string trimright [read $channel] \n] \n]]
    close $channel
}
set before $::hir::buildStats
set t0 [clock microseconds]
set failed [catch {surface::readProgramFile $path -warnings default -warning-channel "" -cache ""} hir options]
set result [dict create file [file tail $path] lines $lines]
dict set result frontend [format %.2f [expr {([clock microseconds] - $t0) / 1e6}]]
foreach p $phases {
    set name [string map {:: .} [string trimleft $p :]]
    dict set result $name [list [format %.2f [timing::seconds $p]] [format %.2f [timing::exclusiveSeconds $p]] [timing::calls $p]]
}
foreach counter {builds methodTrials methodFinals checks} {
    if {[dict exists $::hir::buildStats $counter]} {
        dict set result $counter [expr {[dict get $::hir::buildStats $counter] - [dict get $before $counter]}]
    }
}
dict set result baselineKb $baseline
dict set result peakKb [peakKb]
if {$failed} {
    dict set result outcome [list failed [dict get $options -errorcode] [lindex [split $hir \n] 0]]
} else {
    dict set result outcome ok
    dict set result exprs [dict size [dict get $hir exprs]]
    dict set result warnings [llength [hir::warnings::of $hir]]
    set semantic [dict getdef $hir semantic {}]
    dict set result semanticInstances [dict size [dict getdef $semantic instances {}]]
    set max 0
    dict for {block n} [dict getdef $semantic byBlock {}] { if {$n > $max} { set max $n } }
    dict set result semanticMaxPerBlock $max
}
file delete -force $scratch
puts [list phases $result]
