# width-facts.tcl -- FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1.md's width
# facts that tools/measure.tcl and tools/economics.tcl do not give: per
# program and configuration, the fold slot's decision (native::foldSlots),
# and for the function FUNCTION (default `f`, the width inputs' fold
# function) its NIR registers (all, raw, managed-capable), its safepoints,
# root candidates, maximum live roots and shadow slots (the driver's
# `roots`), its machine code's frame size (the prologue's `sub $N, %rsp`)
# and its stack traffic -- the instructions that address the frame
# (`(%rsp)` or `(%rbp)` operands): Cranelift's spills and reloads, the
# stack map slots and the outgoing arguments together, a proxy for register
# pressure (objdump of the driver's `object`); with -compile-runs N, the
# driver's compile time of the whole NIR (Cranelift: the `timing` line's
# COMPILE-US of `botlish-native bench 1`, best of N processes; run it on a
# quiet machine: it is wall-clock).
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/width-facts.tcl \
#       ?-function NAME? ?-configs {LABEL {OPTIONS} ...}? ?-compile-runs N? FILE.bot ...
#
# The default configurations are `slots` (the default lowering) and `off`
# (-struct-fold 0 -struct-ref-joins 0: the lowering before the milestone,
# byte for byte). x86-64 only (the frame operands are x86-64's). Scratch
# files live in a `file tempdir` directory, removed at the end.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set function f
set configs {slots {} off {-struct-fold 0 -struct-ref-joins 0}}
set compileRuns 0
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    switch -- $a {
        -function { set function [lindex $argv [incr i]] }
        -configs  { set configs [lindex $argv [incr i]] }
        -compile-runs { set compileRuns [lindex $argv [incr i]] }
        default   { lappend files $a }
    }
}
set argv {}
cd $root
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
set driver [file join $root native target release botlish-native]
set scratch [file tempdir]

# The `roots` facts of function NAME: a dict.
proc RootFacts {nir name} {
    set text [exec $::driver roots $nir]
    set facts {}
    set inside 0
    set index ""
    foreach line [split $text \n] {
        if {[regexp {^function (\d+) "([^"]*)"} $line -> n fname]} {
            set inside [expr {$fname eq $name}]
            if {$inside} { set index $n }
            continue
        }
        if {$inside && [regexp {^\s+([A-Za-z -]+): (\S+)} $line -> key value]} {
            dict set facts $key $value
        }
    }
    dict set facts index $index
    return $facts
}

# The frame size and frame-addressing instructions of botlish_fn_INDEX.
proc FrameFacts {nir index} {
    set object [file join $::scratch program.o]
    exec $::driver object $object $nir
    set text [exec objdump -d --no-show-raw-insn $object]
    set inside 0
    set frame 0
    set traffic 0
    foreach line [split $text \n] {
        if {[regexp {^[0-9a-f]+ <([^>]+)>:} $line -> symbol]} {
            set inside [expr {$symbol eq "botlish_fn_$index"}]
            continue
        }
        if {!$inside} continue
        if {$frame == 0 && [regexp {sub\s+\$0x([0-9a-f]+),%rsp} $line -> hex]} {
            scan $hex %x frame
        }
        if {[regexp {\(%rsp\)|\(%rbp\)|\(%rsp,|\(%rbp,} $line]} {
            incr traffic
        }
    }
    return [list $frame $traffic]
}

# The driver's best compile time of NIR over RUNS processes (microseconds).
proc CompileUs {nir runs} {
    set best -
    for {set r 0} {$r < $runs} {incr r} {
        set line [lsearch -inline [split [exec $::driver bench 1 $nir 2>@1] \n] {timing *}]
        set us [lindex $line 1]
        if {$best eq "-" || $us < $best} { set best $us }
    }
    return $best
}

puts [format "%-16s %-6s %-22s %6s %5s %6s %5s %6s %5s %5s %6s %7s %10s" \
    program config decision regs raw manag safe cand live shad frame traffic compile-us]
foreach path $files {
    set hir [surface::readProgramFile $path -warnings off]
    foreach {label options} $configs {
        set decisions {}
        foreach slot [native::foldSlots $hir {*}$options] {
            set word [dict get $slot status]
            if {[dict get $slot width] ne ""} { append word " [dict get $slot width]" }
            if {[dict get $slot reason] ne ""} { append word " [dict get $slot reason]" }
            lappend decisions $word
        }
        if {$decisions eq ""} { set decisions - }
        set nir [file join $scratch program.nir]
        set channel [open $nir w]
        puts -nonewline $channel [dict get [native::lowered $hir {*}$options] text]
        close $channel
        set roots [RootFacts $nir $function]
        lassign [FrameFacts $nir [dict get $roots index]] frame traffic
        set compile [expr {$compileRuns > 0 ? [CompileUs $nir $compileRuns] : "-"}]
        puts [format "%-16s %-6s %-22s %6s %5s %6s %5s %6s %5s %5s %6s %7s %10s" \
            [file tail $path] $label [string range [join $decisions ,] 0 21] \
            [dict getdef $roots {NIR regs} -] [dict getdef $roots {raw regs} -] \
            [dict getdef $roots {managed-capable regs} -] [dict getdef $roots safepoints -] \
            [dict getdef $roots {root candidates} -] [dict getdef $roots {max live roots} -] \
            [dict getdef $roots {shadow slots} -] $frame $traffic $compile]
    }
}
file delete -force $scratch
