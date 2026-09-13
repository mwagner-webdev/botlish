# main.tcl -- example runner.
#
#   tclsh main.tcl [-backend interp|compile] [-code] [-hir] [FILE.ir|FILE.hir ...]
#
# Runs the given program files (default: every examples/*.ir) and prints
# each program's value, with runtime evidence shown as "text"#{Type}. With
# -backend compile it also prints the inferred types of program-level
# bindings; -code prints the Tcl code the compiler generates; -hir prints the
# program's semantic HIR (hir::format).
#
# A .hir file (HIR text, e.g. examples/hir/*.hir) is read with hir::readFile.
# The interpreter runs its lowered IR; the compiler compiles the HIR itself.
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

proc runFile {path showCode showHir} {
    puts "== [file tail $path] ([core::useBackend])"
    set hir ""
    if {[file extension $path] eq ".hir"} {
        set hir [hir::readFile $path]
        set program [hir::lower $hir]
        set run [expr {[core::useBackend] eq "compile"
            ? {core::compiler::evalHir $hir} : {core::evalProgram $program}}]
    } else {
        set program [core::loadProgramFile $path]
        set run {core::evalProgram $program}
    }
    if {$showHir} {
        puts [hir::format [expr {$hir ne "" ? $hir : [hir::build $program -strict 0]}]]
    }
    if {$showCode} {
        puts [core::compiler::generatedCode $program]
    }
    if {[catch $run value options]} {
        puts "   error: $value ([dict get $options -errorcode])"
        return 1
    }
    puts "   value: [core::value::show $value 1]"
    if {[core::useBackend] eq "compile"} {
        dict for {name type} [core::compiler::programTypes $program] {
            puts "   type:  $name : [hir::types::show $type]"
        }
    }
    set index 0
    foreach probe [probeValues $value] {
        set shown {}
        dict for {name facts} [core::envRefinements [core::blockEnv $probe]] {
            lappend shown "$name : [join [lmap fact $facts {core::type::show $fact}] {, }]"
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
set showHir 0
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -backend { core::useBackend [lindex $argv [incr i]] }
        -code    { set showCode 1 }
        -hir     { set showHir 1 }
        default  { lappend files $arg }
    }
}
if {$files eq ""} {
    set files [lsort [glob -directory [file join $root examples] *.ir]]
}
set failures 0
foreach path $files {
    incr failures [runFile $path $showCode $showHir]
}
exit [expr {$failures > 0}]
