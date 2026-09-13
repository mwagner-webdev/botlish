# programfile.tcl -- reading IR programs stored as data files.
#
# A program file is a Tcl list of IR expressions. Lines whose first
# non-blank character is # are comments. This is not a source-language
# parser: the file content is already core IR.
#
# A comment of the form
#
#   # requires: web
#
# names optional libraries (lib/NAME.tcl) the program needs; see
# core::programFileRequires and core::loadLibrary.

namespace eval core {}

proc core::ReadFile {path} {
    set channel [open $path r]
    try {
        return [read $channel]
    } finally {
        close $channel
    }
}

proc core::readProgramFile {path} {
    set kept {}
    foreach line [split [ReadFile $path] \n] {
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

# The libraries named by "# requires: NAME ..." comments in PATH.
proc core::programFileRequires {path} {
    set libraries {}
    foreach line [split [ReadFile $path] \n] {
        if {[regexp {^\s*#\s*requires:\s*(.*)$} $line _ names]} {
            foreach name $names {
                if {$name ni $libraries} {
                    lappend libraries $name
                }
            }
        }
    }
    return $libraries
}

# Reads PATH after loading the libraries it requires.
proc core::loadProgramFile {path} {
    foreach name [programFileRequires $path] {
        core::loadLibrary $name
    }
    return [readProgramFile $path]
}
