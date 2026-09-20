# main.tcl -- example runner.
#
#   tclsh9.0 main.tcl [-backend interp|compile|cranelift|cranelift-generic] [-code] [-hir] [-ast]
#                    [-aot] [-aot-data] [-aot-spec] [-emit-nir] [-emit-clif] [FILE.ir|FILE.hir|FILE.bot ...]
#
# Runs the given program files (default: every examples/*.ir) and prints
# each program's value, with runtime evidence shown as "text"#{Type}. With
# -backend compile it also prints the inferred types of program-level
# bindings; -code prints the Tcl code the compiler generates; -hir prints the
# program's semantic HIR (hir::format); -ast prints the surface AST of a .bot
# file (surface::formatAst). -aot prints the closed-AOT readiness of every
# function (hir::aot::explain), and -aot-data the analysis itself as a Tcl
# dict (hir::aot::analyze), before running the program; -aot-spec prints the
# same report for every function instance call-site specialization uses,
# next to each function's semantic report (hir::specialize::explain).
# -emit-nir prints the native backend IR the program lowers to
# (native/lower.tcl), and -emit-clif the Cranelift IR of every function (both
# need no -backend cranelift; with -backend cranelift-generic, or
# BOTLISH_NATIVE_SPECIALIZE=0, they show the unspecialized code).
#
# A .hir file (HIR text, e.g. examples/hir/*.hir) is read with hir::readFile;
# a .bot file (Botlish source, e.g. examples/surface/*.bot) is parsed and
# lowered to HIR with surface::readProgramFile. For both, the interpreter runs
# the lowered IR and the compiler compiles the HIR itself.
#
# For every Block in the result (directly or as a list element) the runner
# also prints the refinements visible in the Block's captured environment, so
# blocks can serve as scope probes.

set root [file dirname [file normalize [info script]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

proc probeValues {value} {
    switch -- [core::value::kind $value] {
        block   { return [list $value] }
        list    { return [lsearch -all -inline -index 0 [core::value::items $value] block] }
        default { return {} }
    }
}

proc runFile {path showCode showHir showAst showAot showNative} {
    puts "== [file tail $path] ([core::useBackend])"
    set hir ""
    set extension [file extension $path]
    if {$extension eq ".bot"} {
        # Parse with recovery first, so every syntax error is reported.
        set ast [surface::parse [core::ReadFile $path] $path -recover 1]
        if {$showAst} {
            puts [surface::formatAst $ast]
        }
        if {[dict get $ast diagnostics] ne ""} {
            foreach diagnostic [dict get $ast diagnostics] {
                puts "   error: [dict get $diagnostic file]:[dict get $diagnostic line]:[dict get $diagnostic column]: [dict get $diagnostic message] (SURFACE SYNTAX)"
            }
            return 1
        }
    }
    if {$extension in {.hir .bot}} {
        if {$extension eq ".hir"} {
            set hir [hir::readFile $path]
        } elseif {[catch {surface::readProgramFile $path} hir options]} {
            puts "   error: $hir ([dict get $options -errorcode])"
            return 1
        }
        set program [hir::lower $hir]
        set run [dict get {
            compile   {core::compiler::evalHir $hir}
            cranelift {native::evalHir $hir}
            cranelift-generic {native::evalHir $hir -specialize 0}
            interp    {core::evalProgram $program}
        } [core::useBackend]]
    } else {
        set program [core::loadProgramFile $path]
        set run {core::evalProgram $program}
    }
    if {$showHir || $showAot ne "" || $showNative ne ""} {
        set shownHir [expr {$hir ne "" ? $hir : [hir::build $program -strict 0]}]
    }
    if {$showHir} {
        puts [hir::format $shownHir]
    }
    switch -- $showAot {
        text { puts [hir::aot::explain $shownHir] }
        data { puts [hir::aot::analyze $shownHir] }
        spec { puts [hir::specialize::explain $shownHir] }
    }
    if {$showCode} {
        puts [core::compiler::generatedCode $program]
    }
    set nativeOptions [expr {[core::useBackend] eq "cranelift-generic" ? {-specialize 0} : {}}]
    if {$showNative ne "" && [catch {
        switch -- $showNative {
            nir  { puts -nonewline [native::nir $shownHir {*}$nativeOptions] }
            clif { puts [native::clif $shownHir {*}$nativeOptions] }
        }
    } message options]} {
        puts "   error: $message ([dict get $options -errorcode])"
        return 1
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
set showAst 0
set showAot ""
set showNative ""
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -backend { core::useBackend [lindex $argv [incr i]] }
        -code    { set showCode 1 }
        -hir     { set showHir 1 }
        -ast     { set showAst 1 }
        -aot     { set showAot text }
        -aot-data { set showAot data }
        -aot-spec { set showAot spec }
        -emit-nir { set showNative nir }
        -emit-clif { set showNative clif }
        default  { lappend files $arg }
    }
}
if {$files eq ""} {
    set files [lsort [glob -directory [file join $root examples] *.ir]]
}
set failures 0
foreach path $files {
    incr failures [runFile $path $showCode $showHir $showAst $showAot $showNative]
}
exit [expr {$failures > 0}]
