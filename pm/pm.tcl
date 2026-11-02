# pm.tcl -- the Botlish package manager (PACKAGE-MANAGER-MILESTONE-1.md):
# local package management with botlish.json (BOTLISH-JSON.md) and .botpkg
# artifacts (BOTPKG-FORMAT.md).
#
#   source pm/pm.tcl; pm::cli::main ARGV INVOCATION     the commands add,
#       install, update, remove, verify, package pack|inspect and native
#       inspect|plan|deploy; the exit status (0 success, 1 a failed
#       operation, 2 a usage error)
#
# main.tcl sources this file only when its first argument is one of those
# command words, before it loads anything of the compiler: an ordinary
# compilation never loads the package manager, reads a botlish.json or
# touches a package. The compiler, in turn, never loads this: it reads the
# .bot_modules trees the package manager builds (BOT-MODULES-MILESTONE-1.md)
# exactly as it reads hand-assembled ones, and knows nothing of versions,
# descriptors, locks or artifacts.
#
# Files:
#
#   json.tcl        strict JSON (duplicate keys rejected) and its canonical form
#   sha256.tcl      SHA-256: the host system's own tool when it has one, else Tcl
#   version.tcl     versions, requests, their matching and order
#   target.tcl      compilation targets (the compiler's table, read as data)
#   binary.tcl      native file inspection (ELF, ar, Mach-O, PE/COFF), no execution
#   targets.tcl     schema 2's targets: target files and native metadata
#   descriptor.tcl  botlish.json, schemas 1 and 2
#   archive.tcl     the .botpkg format: deterministic writer, validating reader
#   catalog.tcl     where artifacts come from: archive sources, repositories
#   state.tcl       the installation record: what the manager installed
#   native.tcl      native verification, the native closure, the plan
#   view.tcl        target views: one package tree per target
#   deploy.tcl      placing a target's bundled shared libraries
#   install.tcl     resolution, plans, staging and transactions
#   commands.tcl    the commands and the command line
#
# Nothing here executes anything a package holds: no hook, no script, no
# binary, no compilation. Installing a package is writing its files. The
# only programs it ever starts are the host system's own SHA-256 tool, at a
# fixed system path (pm/sha256.tcl), and `kill -0` (a lock holder's
# liveness).

namespace eval pm {
    variable root [file dirname [file dirname [file normalize [info script]]]]
    variable here [file join $root pm]
}

foreach pm::file {json sha256 version target binary targets descriptor archive catalog state native view deploy install commands} {
    source [file join $pm::here $pm::file.tcl]
}
unset pm::file

# Raises an operation error {PM KIND} with MESSAGE: the command reports it
# and exits 1. (A plain error, raised here: never `return -level 2`, which a
# `try` in the caller would not see.)
proc pm::Fail {kind message} {
    return -code error -errorcode [list PM $kind] $message
}

# Fault injection for the transaction tests (BOTLISH_PM_FAULT, read only from
# the environment: no command-line option or descriptor key reaches it). A
# point POINT fails as an error when the variable names it, and ends the
# process at once (exit status 99, nothing cleaned up) when it names
# crash:POINT.
proc pm::Fault {point} {
    if {![info exists ::env(BOTLISH_PM_FAULT)]} return
    set fault $::env(BOTLISH_PM_FAULT)
    if {$fault eq $point} {
        return -code error -errorcode {PM FAULT} "injected fault at $point (BOTLISH_PM_FAULT)"
    }
    if {$fault eq "crash:$point"} {
        catch {flush stdout}
        exit 99
    }
}

# The text of the file PATH (bytes).
proc pm::ReadBytes {path} {
    set channel [open $path rb]
    try {
        return [read $channel]
    } finally {
        close $channel
    }
}

# Writes BYTES to the new file PATH, which must not exist (never through a
# link or over a file someone placed there).
proc pm::WriteNew {path bytes} {
    set channel [open $path {WRONLY CREAT EXCL BINARY}]
    try {
        puts -nonewline $channel $bytes
    } finally {
        close $channel
    }
}

# Replaces the file PATH by BYTES atomically where the platform renames
# atomically: a temporary file beside it, renamed over it.
proc pm::ReplaceFile {path bytes} {
    set temporary $path.tmp-[pid]
    file delete $temporary
    WriteNew $temporary $bytes
    Rename $temporary $path 1
}

# Renames FROM to TO (with FORCE, over an existing file). On Windows a
# rename fails while another process (a virus scanner, an editor) holds a
# file under FROM open: it is retried for about two seconds before the
# error is raised, and the transaction rolls back.
proc pm::Rename {from to {force 0}} {
    set attempts [expr {$::tcl_platform(platform) eq "windows" ? 20 : 1}]
    for {set i 1} {1} {incr i} {
        if {$force} {
            set failed [catch {file rename -force -- $from $to} message options]
        } else {
            set failed [catch {file rename -- $from $to} message options]
        }
        if {!$failed} return
        if {$i >= $attempts} {
            return -options $options $message
        }
        after 100
    }
}

# Removes the tree PATH: a link is removed as a link (never followed), a
# directory with everything in it.
proc pm::RemoveTree {path} {
    if {[catch {file type $path}]} return
    file delete -force -- $path
}

# 1 when PATH exists as anything, a dangling link included.
proc pm::Exists {path} {
    return [expr {![catch {file lstat $path stat}]}]
}

# The relative path from the directory BASE to PATH (both absolute,
# normalized), with "/" separators; "" when there is none (another volume).
proc pm::RelativePath {base path} {
    set from [file split $base]
    set to [file split $path]
    if {[lindex $from 0] ne [lindex $to 0]} {
        return ""
    }
    set i 0
    while {$i < [llength $from] && $i < [llength $to] && [lindex $from $i] eq [lindex $to $i]} {
        incr i
    }
    set parts [lrepeat [expr {[llength $from] - $i}] ..]
    lappend parts {*}[lrange $to $i end]
    if {$parts eq ""} {
        return .
    }
    return [join $parts /]
}

# The absolute path of the descriptor path RELATIVE ("/"-separated) under the
# project directory PROJECT.
proc pm::ProjectPath {project relative} {
    return [file normalize [file join $project {*}[split $relative /]]]
}

# The digest's short form for messages.
proc pm::Short {digest} {
    return [string range $digest 0 11]
}
