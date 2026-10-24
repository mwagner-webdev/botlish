# workspace.tcl -- an application directory for the emitter experiment
# (EMITTER-COROUTINE-EXPLORATION.md): the JSON workload's modules
# (examples/dfa/json: json_lex.bot, the one grammar, and json.bot, its
# validators and decoder) beside the emitter modules (audit/emitter/json)
# and the files a caller adds. Copies, never links: the grammar has one
# source, examples/dfa/json/json_lex.bot.
#
#   source audit/emitter/tools/workspace.tcl
#   emitws::make DIR ?NAME TEXT ...?      => DIR
#   emitws::scratch ?NAME TEXT ...?       => a new directory under the
#                                            system's temporary directory
#   emitws::cleanup                       removes every scratch directory
#                                         this process made (also run by
#                                         `exit`)

namespace eval emitws {
    variable root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
    variable scratches {}
}

proc emitws::make {dir args} {
    variable root
    file mkdir $dir
    foreach path [list [file join $root examples dfa json json_lex.bot] [file join $root examples dfa json json.bot]] {
        file copy -force $path [file join $dir [file tail $path]]
    }
    foreach path [glob -directory [file join $root audit emitter json] *.bot] {
        file copy -force $path [file join $dir [file tail $path]]
    }
    foreach {name text} $args {
        set f [open [file join $dir $name] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $text
        close $f
    }
    return $dir
}

proc emitws::scratch {args} {
    variable scratches
    set dir [file tempdir]
    lappend scratches $dir
    return [make $dir {*}$args]
}

proc emitws::cleanup {args} {
    variable scratches
    foreach dir $scratches {
        file delete -force $dir
    }
    set scratches {}
}

if {"emitws::cleanup" ni [join [trace info execution exit]]} {
    trace add execution exit enter emitws::cleanup
}
