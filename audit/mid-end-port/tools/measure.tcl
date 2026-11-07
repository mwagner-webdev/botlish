# measure.tcl -- measures one compilation of a program (audit/mid-end-port/
# README.md, "The scale experiment"): the front end's phases, its whole-
# program builds, its semantic instances and their budget, its memory, and
# optionally the native path (specialization, lowering to NIR, Cranelift
# and the link) and a run of the executable.
#
#   tclsh9.0 audit/mid-end-port/tools/measure.tcl FILE ?-native 0|1? ?-run 0|1?
#       ?-specialize 0|1?
#
# -specialize 0 lowers every function once, unspecialized (cranelift-
# generic's lowering), instead of the specialized program.
#
# Prints `frontend DICT` once the front end is done, `stage NAME RSS-KB`
# after each step of the native path, then `final DICT` (the
# same dict with the native path's figures added): a run that dies in the
# native path keeps its front-end figures (scale.tcl reads the last line).
# Run it in a process of its own: its memory figures are the process's peak
# resident size (/proc/self/status VmHWM; "" where there is no /proc).

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set path [file normalize [lindex $argv 0]]
set options [dict create -native 1 -run 1 -specialize 1]
foreach {option value} [lrange $argv 1 end] {
    if {![dict exists $options $option]} { error "measure.tcl: unknown option $option" }
    dict set options $option $value
}
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]

proc peakKb {} {
    if {[catch {open /proc/self/status} channel]} { return "" }
    set kb ""
    foreach line [split [read $channel] \n] {
        if {[regexp {^VmHWM:\s+(\d+)} $line -> kb]} break
    }
    close $channel
    return $kb
}
# The process's current resident size (VmRSS), in KB.
proc rssKb {} {
    if {[catch {open /proc/self/status} channel]} { return "" }
    set kb ""
    foreach line [split [read $channel] \n] {
        if {[regexp {^VmRSS:\s+(\d+)} $line -> kb]} break
    }
    close $channel
    return $kb
}
proc seconds {script} {
    set t0 [clock microseconds]
    uplevel 1 $script
    return [format %.2f [expr {([clock microseconds] - $t0) / 1e6}]]
}

source [file join $here timing.tcl]
# Coarse phases of the front end, then the native path's own analyses
# (native::lowered runs them all): inclusive seconds, the outermost
# activation of each (timing.tcl).
set phases {::surface::modules::CollectAndLoad ::surface::modules::Parse ::hir::buildSyntax
    ::hir::check ::hir::DecideMethodCalls ::hir::traits::monomorphize ::hir::static::decide
    ::surface::lower::Finish}
set nativePhases {::native::prepareHir ::hir::specialize::analyze ::hir::specialize::view
    ::hir::range::analyze ::hir::escape::analyze ::hir::stringregion::analyze
    ::hir::blockescape::analyze ::hir::construction::analyze ::hir::traversal::analyze
    ::hir::aot::analyzeRegion ::native::shortstr::plan ::native::rawabi::plan}
timing::wrap $phases
if {[dict get $options -native]} {
    timing::wrap $nativePhases
}

# Warm: load the libraries a compilation loads lazily, and compile the
# procedures that call the wrapped ones again, outside the timing.
set scratch [file tempdir mid-end-measure]
set warm [file join $scratch warm.bot]
set channel [open $warm w]; puts $channel 1; close $channel
surface::readProgramFile $warm -warnings off -cache ""
set baselineKb [peakKb]
timing::reset

set result [dict create file [file tail $path]]
set lines 0
foreach file [glob -directory [file dirname $path] *.bot] {
    set channel [open $file]
    incr lines [llength [split [string trimright [read $channel] \n] \n]]
    close $channel
}
dict set result lines $lines
set before $::hir::buildStats
set t0 [clock microseconds]
set failed [catch {surface::readProgramFile $path -warnings default -warning-channel "" -cache ""} hir errorOptions]
dict set result frontend [format %.2f [expr {([clock microseconds] - $t0) / 1e6}]]
foreach p $phases {
    dict set result [namespace tail $p] [format %.2f [timing::seconds $p]]
}
foreach counter {builds methodTrials methodFinals checks} {
    dict set result $counter [expr {[dict get $::hir::buildStats $counter] - [dict get $before $counter]}]
}
dict set result baselinePeakKb $baselineKb
dict set result frontendPeakKb [peakKb]
if {$failed} {
    dict set result outcome [list failed [dict get $errorOptions -errorcode] [lindex [split $hir \n] 0]]
    puts [list final $result]
    file delete -force $scratch
    exit 0
}
dict set result outcome ok
dict set result exprs [dict size [dict get $hir exprs]]
dict set result warnings [llength [hir::warnings::of $hir]]

# Semantic instances (hir/semantic.tcl): the HIR keeps the run's state.
set semantic [dict getdef $hir semantic {}]
set byBlock [dict getdef $semantic byBlock {}]
set maxPerBlock 0
dict for {block n} $byBlock { if {$n > $maxPerBlock} { set maxPerBlock $n } }
dict set result semanticInstances [dict size [dict getdef $semantic instances {}]]
dict set result semanticMaxPerBlock $maxPerBlock
dict set result semanticBudget [list perBlock $::hir::semantic::maxPerBlock total $::hir::semantic::maxInstances]
dict set result semanticDeclined [dict getdef $semantic declinedCount {}]

if {![dict get $options -native]} {
    puts [list final $result]
    file delete -force $scratch
    exit 0
}
puts [list frontend $result]
flush stdout
proc nativePhaseTable {} {
    set table {}
    foreach p $::nativePhases {
        lappend table [namespace tail [namespace qualifiers $p]]::[namespace tail $p] \
            [list [format %.2f [timing::seconds $p]] [timing::calls $p]]
    }
    return $table
}
if {1} {
    # The specializer (hir/specialize.tcl): instances per function, against
    # its limit (8 specialized instances of a block, then the generic one).
    dict set result specialize [seconds {set analysis [hir::specialize::analyze $hir -specialize [dict get $options -specialize]]}]
    dict set result specRssKb [rssKb]
    puts [list stage specialize [rssKb]]
    flush stdout
    dict set result summary [seconds {set summary [hir::specialize::summary $hir $analysis]}]
    dict set result summaryRssKb [rssKb]
    puts [list stage summary [rssKb]]
    flush stdout
    set maxSpec 0
    set atLimit 0
    dict for {name counts} [dict get $summary perFunction] {
        set n [dict get $counts specializations]
        if {$n > $maxSpec} { set maxSpec $n }
        if {$n >= $::hir::specialize::limit} { incr atLimit }
    }
    dict set result specInstances [dict get $summary instances]
    dict set result specSpecialized [dict get $summary specializedInstances]
    dict set result specMaxPerFunction $maxSpec
    dict set result specFunctionsAtLimit $atLimit
    dict set result specLimit $::hir::specialize::limit
    dict set result specializeOption [dict get $options -specialize]
    set executable [file join $scratch program]
    if {[catch {
        timing::reset
        dict set result lower [seconds {set nirText [native::nir $hir -specialize [dict get $options -specialize]]}]
        dict set result nativePhases [nativePhaseTable]
        dict set result lowerRssKb [rssKb]
        dict set result nirKb [expr {[string length $nirText] / 1024}]
        dict set result cranelift [seconds {set lines [native::Driver executable $nirText $executable --startup worker]}]
        if {[lindex [lindex $lines 0] 0] ne "executable"} { error "driver: [join $lines { }]" }
        set executable [lindex [lindex $lines 0] 1]
    } message]} {
        dict set result native [list failed [lindex [split $message \n] 0]]
    } else {
        dict set result native ok
        if {[dict get $options -run]} {
            set resultFile [file join $scratch result.txt]
            set env(BOTLISH_NATIVE_RESULT) $resultFile
            dict set result run [seconds {catch {exec $executable} runOutput}]
            unset env(BOTLISH_NATIVE_RESULT)
            set value ""
            if {[file exists $resultFile]} {
                set channel [open $resultFile]
                foreach line [split [read $channel] \n] {
                    if {[lindex $line 0] eq "value"} { set value [lindex $line 1] }
                }
                close $channel
            }
            dict set result value $value
        }
    }
    dict set result peakKb [peakKb]
}
file delete -force $scratch
puts [list final $result]
