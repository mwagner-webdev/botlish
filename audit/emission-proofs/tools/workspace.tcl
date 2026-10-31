# workspace.tcl -- an application directory for the modular emission
# experiment: the exploratory milestone's workspace (examples/dfa/json's
# json_lex.bot and json.bot, audit/emitter/json's modules) plus this
# milestone's library (audit/emission-proofs/lib) and the files a caller
# adds. Copies, never links.
#
#   source audit/emission-proofs/tools/workspace.tcl
#   epws::scratch ?NAME TEXT ...?    => a new directory (removed at exit)

if {[info exists ::env(EMISSION_PROOFS_ROOT)]} {
    set epwsRoot [file join $::env(EMISSION_PROOFS_ROOT) audit]
} else {
    set epwsRoot [file dirname [file dirname [file dirname [file normalize [info script]]]]]
}
source [file join $epwsRoot emitter tools workspace.tcl]

namespace eval epws {
    variable lib [file join $::epwsRoot emission-proofs lib]
}

proc epws::scratch {args} {
    variable lib
    set dir [emitws::scratch]
    foreach path [glob -nocomplain -directory $lib *.bot] {
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
