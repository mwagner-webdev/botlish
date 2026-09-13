# programfile.tcl -- reading IR programs stored as data files.
#
# A program file is a Tcl list of IR expressions. Lines whose first
# non-blank character is # are comments. This is not a source-language
# parser: the file content is already core IR.

namespace eval core {}

proc core::readProgramFile {path} {
    set channel [open $path r]
    try {
        set text [read $channel]
    } finally {
        close $channel
    }
    set kept {}
    foreach line [split $text \n] {
        if {![string match {#*} [string trimleft $line]]} {
            lappend kept $line
        }
    }
    set program [join $kept \n]
    if {[catch {llength $program}]} {
        error "core::readProgramFile: $path is not a list of IR expressions"
    }
    return $program
}
