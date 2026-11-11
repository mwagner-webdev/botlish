# probes.tcl -- FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md's semantic probes:
# for every program named, its value on the four backends against the
# reference interpreter and the program's `# expect:` line, the struct
# census of the struct scalar replacement (native::structCensus: how each
# struct construction is represented today, and why), the native run's
# Struct allocations, and the NIR experiment (tools/nir-sra.tcl: every
# struct register web of the program's NIR carried as field registers) --
# its value on the driver against the original NIR's, also under
# BOTLISH_NATIVE_GC_STRESS=1 (a collection attempted at every allocation
# site), and its Struct allocations.
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/probes.tcl ?-root DIR? FILE.bot ...
#
# Exits 1 if a backend or the experiment disagrees with the interpreter or
# a value differs from its `# expect:` line. Its scratch files live in a
# `file tempdir` directory, removed at the end.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        default { lappend files [file normalize $arg] }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit
set driver [file join $root native target release botlish-native]

proc mainValue {path backend} {
    global root
    set out [exec tclsh9.0 [file join $root main.tcl] -backend $backend -warnings off $path 2>@1]
    if {![regexp -line {^\s*value: (.*)$} $out -> value]} {
        return "(no value: [lindex [split $out \n] end])"
    }
    return $value
}

proc expected {path} {
    set ch [open $path r]
    fconfigure $ch -encoding utf-8
    set text [read $ch]
    close $ch
    if {[regexp -line {^# expect: (.*)$} $text -> e]} {
        return $e
    }
    return ""
}

# The driver's value line and Struct allocations of NIR file PATH.
proc driverRun {path} {
    global driver
    set lines [split [exec $driver run $path --alloc summary 2>@1] \n]
    set value [lsearch -inline $lines {value *}]
    set alloc [lsearch -inline $lines {alloc *}]
    set structs ?
    regexp {Struct \{allocations (\d+)} $alloc -> structs
    return [list [string range $value 6 end] $structs]
}

set work [file tempdir fvss]
set failures 0
try {
    foreach path $files {
        puts "== [file tail $path]"
        set reference [mainValue $path interp]
        set expect [expected $path]
        set line "   interp $reference"
        if {$expect ne "" && $expect ne $reference} {
            append line "  MISMATCH expect $expect"
            incr failures
        }
        puts $line
        foreach backend {compile cranelift-generic cranelift} {
            set v [mainValue $path $backend]
            if {$v ne $reference} {
                puts "   $backend DISAGREES: $v"
                incr failures
            }
        }
        set hir [surface::readProgramFile $path -warnings off]
        set classes [dict create]
        foreach rec [native::structCensus $hir] {
            set c [dict get $rec class]
            if {$c eq "materialized"} {
                append c "([dict get $rec reason])"
            }
            dict incr classes $c
        }
        puts "   census: [lsort -stride 2 $classes]"
        set nirPath [file join $work [file rootname [file tail $path]].nir]
        set ch [open $nirPath w]
        fconfigure $ch -encoding utf-8 -translation lf
        puts -nonewline $ch [native::nir $hir]
        close $ch
        lassign [driverRun $nirPath] original structs
        set sraPath [file rootname $nirPath].sra.nir
        set report [exec tclsh9.0 [file join $here nir-sra.tcl] $nirPath $sraPath]
        lassign [driverRun $sraPath] rewritten sraStructs
        set ::env(BOTLISH_NATIVE_GC_STRESS) 1
        try {
            lassign [driverRun $sraPath] stressed
        } finally {
            unset ::env(BOTLISH_NATIVE_GC_STRESS)
        }
        set webs 0
        foreach r [split $report \n] {
            if {[regexp {webs (\d+)} $r -> w]} {
                incr webs $w
            }
        }
        set verdict [expr {$rewritten eq $original ? "same value" : "DIFFERENT VALUE: $rewritten"}]
        append verdict [expr {$stressed eq $original ? ", same under GC stress" : ", UNDER GC STRESS: $stressed"}]
        if {$rewritten ne $original || $stressed ne $original} {
            incr failures
        }
        puts "   native Struct allocations: $structs; field registers ($webs webs): $structs -> $sraStructs, $verdict"
    }
} finally {
    file delete -force $work
}
puts "failures: $failures"
exit [expr {$failures > 0}]
