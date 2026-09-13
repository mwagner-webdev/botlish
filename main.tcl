# main.tcl -- example runner.
#
#   tclsh main.tcl [-backend interp|compile] [-code] [FILE.ir ...]
#
# Runs the given program files (default: every examples/*.ir) and prints
# each program's value. -code also prints the Tcl code the compiler generates.
#
# For every Block in the result (directly or as a list element) the runner
# also prints the refinements visible in the Block's captured environment, so
# blocks can serve as scope probes.

set root [file dirname [file normalize [info script]]]
source [file join $root compiler compiler.tcl]

proc probeValues {value} {
    switch -- [core::value::kind $value] {
        block   { return [list $value] }
        list    { return [lsearch -all -inline -index 0 [core::value::items $value] block] }
        default { return {} }
    }
}

proc runFile {path showCode} {
    puts "== [file tail $path] ([core::useBackend])"
    set program [core::readProgramFile $path]
    if {$showCode} {
        puts [core::compiler::generatedCode $program]
    }
    if {[catch {core::evalProgram $program} value options]} {
        puts "   error: $value ([dict get $options -errorcode])"
        return 1
    }
    puts "   value: [core::formatValue $value]"
    set index 0
    foreach probe [probeValues $value] {
        set shown {}
        dict for {name facts} [core::envRefinements [core::blockEnv $probe]] {
            lappend shown "$name : [join $facts {, }]"
        }
        if {$shown eq ""} {
            set shown [list (none)]
        }
        puts "   block #$index refinements: [join $shown {; }]"
        incr index
    }
    return 0
}

set files {}
set showCode 0
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -backend { core::useBackend [lindex $argv [incr i]] }
        -code    { set showCode 1 }
        default  { lappend files $arg }
    }
}
if {$files eq ""} {
    set files [lsort [glob -directory [file join $root examples] *.ir]]
}
set failures 0
foreach path $files {
    incr failures [runFile $path $showCode]
}
exit [expr {$failures > 0}]
