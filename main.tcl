# main.tcl -- example runner.
#
#   tclsh9.0 main.tcl [-backend interp|compile|cranelift|cranelift-generic] [-code] [-hir] [-ast]
#                    [-aot] [-aot-data] [-aot-spec] [-emit-nir] [-emit-clif]
#                    [-emit-native-executable] [-argv TEXT]... [-argv-hex HEX]...
#                    [-argv-none] [-warnings default|off|error]
#                    [FILE.bot|FILE.hir|FILE.ir ...]
#
# -warnings sets the one global compiler-warning policy of a .bot compilation
# (WARNINGS-SAME-RETURN.md): default prints warnings on stderr and runs the
# program; off runs no warning pass (generated source, benchmarking); error
# rejects a program that has a warning, with the warning's own code
# (SAME-RETURN-VALUE), before any backend runs. There are no per-warning
# switches (no -Wfoo): that is intentional.
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
# -emit-native-executable compiles closed specialized workloads to standalone
# Linux x86_64/glibc executables beside the inputs, removing the extension.
# It does not evaluate the program. Running the executable prints its value.
#
# A .hir file (HIR text, e.g. examples/hir/*.hir) is read with hir::readFile;
# a .bot file (Botlish source, e.g. examples/surface/*.bot) is parsed and
# lowered to HIR with surface::readProgramFile. From that HIR, the interpreter
# runs the core IR it lowers to (the Tcl reference branch), the compiler
# compiles the HIR itself and the native backends lower it directly to NIR
# (native::evalHir): native compilation never goes through core IR
# (DIRECT-HIR-NATIVE-PATH.md). A .ir file is core IR text: it runs on
# interp and compile only, and is rejected by the native backends and by
# -emit-native-executable (use the .hir fixtures of examples/hir/ instead).
#
# -argv TEXT / -argv-hex HEX / -argv-none give the process argument vector
# `argv()` reads (core/process.tcl, ARGV.md): each -argv appends one argument
# (its UTF-8 bytes, argument zero first), each -argv-hex one argument given as
# the hex of its raw bytes (so invalid UTF-8 is expressible; the empty string
# is the empty argument), and -argv-none selects the empty vector. Without any
# of them the vector is the synthetic one-element default (`botlish-runner`),
# never this runner's own arguments. The same vector reaches every backend.
# A standalone executable ignores all three: it reads its own process
# arguments each time it runs.
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
    global backend nativeBackends warnings
    puts "== [file tail $path] ($backend)"
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
        } elseif {[catch {surface::readProgramFile $path -warnings $warnings} hir options]} {
            puts "   error: $hir ([dict get $options -errorcode])"
            return 1
        }
        # Core IR is only produced for the branches that consume it: the
        # interpreter, the Tcl compiler (its program types and -code) --
        # never the native backends.
        set program ""
        if {$backend in {interp compile} || $showCode} {
            set program [hir::lower $hir]
        }
        set run [dict get {
            compile   {core::compiler::evalHir $hir}
            cranelift {native::evalHir $hir}
            cranelift-generic {native::evalHir $hir -specialize 0}
            interp    {core::evalProgram $program}
        } $backend]
    } else {
        if {$backend in $nativeBackends || $showNative ne ""} {
            puts "   error: $path is core IR text; native compilation starts from HIR (.bot or .hir), never core IR (NATIVE AOT INPUT)"
            return 1
        }
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
    set nativeOptions [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
    if {$showNative ne "" && [catch {
        switch -- $showNative {
            nir  { puts -nonewline [native::nir $shownHir {*}$nativeOptions] }
            clif { puts [native::clif $shownHir {*}$nativeOptions] }
        }
    } message options]} {
        puts "   error: $message ([dict get $options -errorcode])"
        return 1
    }
    if {[catch {core::process::withArgv $::injectedArgv $run} value options]} {
        puts "   error: $value ([dict get $options -errorcode])"
        return 1
    }
    puts "   value: [core::value::show $value 1]"
    if {$backend eq "compile"} {
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

proc emitExecutable {path} {
    global warnings
    if {[catch {
        switch -- [file extension $path] {
            .bot { set hir [surface::readProgramFile $path -warnings $warnings] }
            .hir { set hir [hir::readFile $path] }
            default { throw {NATIVE AOT INPUT} "expected a .bot or .hir input file (native executables are built from HIR, never from core IR text): $path" }
        }
        native::executable $hir [file rootname $path]
    } message options]} {
        puts stderr "$path: $message ([dict get $options -errorcode])"
        return 1
    }
    puts "executable: [file rootname $path]"
    return 0
}

set nativeBackends {cranelift cranelift-generic}
set backend [core::useBackend]
set files {}
set warnings [hir::warnings::defaultMode]
set showCode 0
set showHir 0
set showAst 0
set showAot ""
set showNative ""
set injectedArgv [core::process::defaultArgv]
set injectedArgvGiven 0
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -backend {
            set backend [lindex $argv [incr i]]
            if {$backend in $nativeBackends} {
                # Native backends are not core::registerBackend backends:
                # they compile HIR (native::evalHir), never core IR.
            } elseif {$backend in [core::backends]} {
                core::useBackend $backend
            } else {
                puts stderr "unknown backend \"$backend\" (known: [core::backends] $nativeBackends)"
                exit 2
            }
        }
        -warnings {
            set warnings [lindex $argv [incr i]]
            if {$warnings ni {default off error}} {
                puts stderr "unknown warnings mode \"$warnings\" (known: default off error)"
                exit 2
            }
        }
        -code    { set showCode 1 }
        -hir     { set showHir 1 }
        -ast     { set showAst 1 }
        -aot     { set showAot text }
        -aot-data { set showAot data }
        -aot-spec { set showAot spec }
        -emit-nir { set showNative nir }
        -emit-clif { set showNative clif }
        -emit-native-executable { set showNative executable }
        -argv - -argv-hex {
            if {!$injectedArgvGiven} { set injectedArgv {}; set injectedArgvGiven 1 }
            set value [lindex $argv [incr i]]
            if {$arg eq "-argv"} {
                lappend injectedArgv [core::process::bytesOfText $value]
            } else {
                lappend injectedArgv [binary decode hex $value]
            }
        }
        -argv-none { set injectedArgv {}; set injectedArgvGiven 1 }
        default  {
            if {[string match -* $arg]} {
                puts stderr "unknown option \"$arg\""
                exit 2
            }
            lappend files $arg
        }
    }
}
if {$files eq ""} {
    if {$showNative eq "executable"} {
        puts stderr "usage: tclsh9.0 main.tcl -emit-native-executable FILE.bot"
        exit 1
    }
    set files [lsort [glob -directory [file join $root examples] *.ir]]
}
set failures 0
foreach path $files {
    if {$showNative eq "executable"} {
        incr failures [emitExecutable $path]
    } else {
        incr failures [runFile $path $showCode $showHir $showAst $showAot $showNative]
    }
}
exit [expr {$failures > 0}]
