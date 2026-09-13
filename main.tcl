# main.tcl -- example runner.
#
#   tclsh main.tcl                 run every examples/*.ir
#   tclsh main.tcl FILE.ir ...     run the given program files
#
# Prints each program's value. For every Block in the result (directly or as
# a list element) it also prints the refinements visible in the Block's
# captured environment, so blocks can serve as scope probes.

source [file join [file dirname [file normalize [info script]]] core core.tcl]

proc probeValues {value} {
    switch -- [core::value::kind $value] {
        block   { return [list $value] }
        list    { return [lsearch -all -inline -index 0 [core::value::items $value] block] }
        default { return {} }
    }
}

proc runFile {path} {
    puts "== [file tail $path]"
    if {[catch {core::evalProgram [core::readProgramFile $path]} value options]} {
        puts "   error: $value ([dict get $options -errorcode])"
        return 1
    }
    puts "   value: [core::formatValue $value]"
    set index 0
    foreach probe [probeValues $value] {
        set refinements [core::envRefinements [core::blockEnv $probe]]
        set shown {}
        dict for {name facts} $refinements {
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

set files $argv
if {$files eq ""} {
    set files [lsort [glob -directory [file join [file dirname [file normalize [info script]]] examples] *.ir]]
}
set failures 0
foreach path $files {
    incr failures [runFile $path]
}
exit [expr {$failures > 0}]
