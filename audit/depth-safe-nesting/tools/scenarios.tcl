# scenarios.tcl -- the compile-time paths a nested program is put through
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md): probe.tcl runs
# each at Tcl's default recursion limit, census.tcl traces each.
#
# dsn::scenarios is NAME -> a script, evaluated at the global level with
# `source` (a program's text, specimens.tcl's) and `dir` (a private
# directory) set. Needs the compiler and the service loaded.

namespace eval dsn {}

set dsn::scenarios {
    compile {
        set hir [surface::compile $source -warnings default -warning-channel ""]
        hir::warnings::of $hir
    }
    hirtext {
        set hir [surface::compile $source -warnings off]
        hir::parse [hir::format $hir]
    }
    interchange {
        set hir [surface::compile $source -warnings off]
        hir::interchange::decode [hir::interchange::encode $hir]
    }
    lowerings {
        set hir [surface::compile $source -warnings off]
        core::ir::check [list block {} {*}[hir::lower $hir]]
        core::compiler::compileHir $hir
        native::lowered $hir
    }
    trait {
        surface::compile "$source\nstruct DsnP:\n    n: int\n\ntrait DsnNamed:\n    fn dsn_name(value: DsnNamed) -> int\n\nfn dsn_name(value: DsnP) -> int:\n    value.n\n\nfn dsn_describe(value: DsnNamed) -> int:\n    value.dsn_name()\n\ndsn_describe(DsnP \{n: 1\})\n" -warnings off
    }
    coroutine {
        surface::compile "import std::coroutine\n\nfn dsn_worker(seed: int) -> int:\n    yield seed\n    seed\n\ncoroutine \{step\} = dsn_worker(1)\n$source" -warnings off
    }
    static {
        lassign [dsn::Split $source] declarations statements
        surface::compile "import std::compiler\n\n${declarations}fn dsn_f() errors std::compiler::CompilerError:\n    static compile:\n[dsn::Indented [dsn::Indented $statements]]\n        unit\n\ndsn_f():\n    on std::compiler::CompilerError:\n        unit\n" -warnings off
    }
    module {
        lassign [dsn::Split $source] declarations statements
        set f [open [file join $dir deepmod.bot] w]
        puts -nonewline $f "${declarations}fn dsn_value():\n[dsn::Indented $statements]\n"
        close $f
        set f [open [file join $dir main.bot] w]
        puts -nonewline $f "import deepmod\n\ndeepmod::dsn_value()\n"
        close $f
        surface::readProgramFile [file join $dir main.bot] -warnings off
    }
    service {
        set ws [service::workspace -warnings default -cache ""]
        set path [file join $dir service.bot]
        service::setDocument $ws $path $source
        set rev [service::analyze $ws $path]
        set lines [split $source \n]
        for {set line 1} {$line <= [llength $lines]} {incr line [expr {max(1, [llength $lines] / 7)}]} {
            set text [lindex $lines $line-1]
            foreach column [list 1 [expr {[string length $text] / 2}] [string length $text]] {
                if {$column >= 1} {
                    service::at $rev $path $line $column
                }
            }
        }
        service::closeWorkspace $ws
    }
}

# SOURCE as a function body: every line indented once.
proc dsn::Indented {source} {
    return [join [lmap line [split [string trimright $source \n] \n] {string cat "    " $line}] \n]
}

# SOURCE's top-level declarations (struct, fn, error and trait, each with
# its indented lines) and its other statements: {DECLARATIONS STATEMENTS}.
proc dsn::Split {source} {
    set chunks {}
    foreach line [split [string trimright $source \n] \n] {
        if {$line ne "" && ![string match " *" $line] && ![regexp {^(elif|else)\M} $line]} {
            lappend chunks $line
        } else {
            lset chunks end "[lindex $chunks end]\n$line"
        }
    }
    set declarations ""
    set statements ""
    foreach chunk $chunks {
        if {[regexp {^(struct|fn|error|trait) } $chunk]} {
            append declarations [string trimright $chunk \n] \n\n
        } else {
            append statements [string trimright $chunk \n] \n
        }
    }
    return [list $declarations [string trimright $statements \n]]
}

