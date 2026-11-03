# prototypes.tcl -- runs the Stage B prototypes of
# LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md:
#
#   tclsh9.0 audit/lexical-cleanup/tools/prototypes.tcl ?-backends LIST?
#
# (Prototype A is the selected implementation itself: tests/resources.test,
# tests/event-loop.test's el-owned-*.)
#
# Prototype B (prototypes/b-task-scope): the scheduler as it was before this
# milestone (prototypes/b-task-scope/event_loop.base.bot, a frozen copy:
# the production scheduler has since gained owned registrations) patched by
# patch.tcl in a private copy of the standard library (never the
# repository's), its scenario program compiled against it and run on every
# backend; prints the trace's claim lines ("N ..."), which every backend
# must agree on.

source [file join [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]

set backends {interp compile cranelift-generic cranelift}
foreach {option value} $argv {
    switch -- $option {
        -backends { set backends $value }
        default { error "unknown option $option" }
    }
}

set proto [file join $::projectRoot audit lexical-cleanup prototypes b-task-scope]
source [file join $proto patch.tcl]

set saved $::core::libraryDir
set lib [file tempdir]
foreach entry [glob -directory $saved *] {
    file copy -force $entry $lib
}
try {
    set path [file join $lib event_loop.bot]
    set f [open [file join $proto event_loop.base.bot]]
    set text [read $f]
    close $f
    set f [open $path w]
    puts -nonewline $f [bscope::patch $text]
    close $f
    set ::core::libraryDir $lib
    set hir [surface::readProgramFile [file join $proto scenarios.bot] -warnings off]
    set outcomes {}
    foreach backend $backends {
        set outcome [lrange [outcomeUnderHir $backend $hir] 0 1]
        dict set outcomes $backend $outcome
    }
    set distinct [lsort -unique [dict values $outcomes]]
    puts "prototype B: [llength $backends] backends, [expr {[llength $distinct] == 1 ? "one outcome" : "DISAGREE"}]"
    foreach {- s} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} [lindex $distinct 0 1]] {
        if {[regexp {^t=\d+: (\d .*)$} $s -> claim]} {
            puts "   $claim"
        }
    }
    if {[llength $distinct] != 1 || [lindex $distinct 0 0] ne "value"} {
        puts [string range $outcomes 0 3000]
    }
} finally {
    set ::core::libraryDir $saved
    file delete -force $lib
}

# Prototype B for a native resource (prototypes/b-file-scope): native only
# (the Tcl backends refuse syscalls). The scenario writes into a private
# directory; the runner then reads what the stale identity wrote where.
set fproto [file join $::projectRoot audit lexical-cleanup prototypes b-file-scope]
set work [file tempdir]
try {
    file copy [file join $fproto fdscope.bot] $work
    set f [open [file join $fproto scenarios.bot]]
    set text [string map [list DIR $work] [read $f]]
    close $f
    set f [open [file join $work scenarios.bot] w]
    puts -nonewline $f $text
    close $f
    set hir [surface::readProgramFile [file join $work scenarios.bot] -warnings off]
    foreach backend {cranelift-generic cranelift} {
        if {$backend ni $backends} continue
        foreach name {a b c d} {
            file delete [file join $work $name]
        }
        set outcome [lrange [outcomeUnderHir $backend $hir] 0 1]
        puts "prototype B (descriptors), $backend: $outcome"
        puts "   \[registry after a reached end_scope, after a failing scope, c's descriptor, d's descriptor, the stale write's result\]"
        set f [open [file join $work d]]
        puts "   d holds: [string trim [read $f]]"
        close $f
    }
} finally {
    file delete -force $work
}

# Prototype C (prototypes/c-scoped-construct): a scoped construct, first as
# a library bracket (bracket.bot: must be rejected, a context-requiring body
# is no value), then as its hand-written expansion (scoped_construct.bot,
# every backend: its claim lines).
set cproto [file join $::projectRoot audit lexical-cleanup prototypes c-scoped-construct]
if {[catch {surface::readProgramFile [file join $cproto bracket.bot] -warnings off} message options]} {
    puts "prototype C, bracket: rejected [lindex [dict get $options -errorcode] end]"
} else {
    puts "prototype C, bracket: COMPILES (expected a rejection)"
}
set hir [surface::readProgramFile [file join $cproto scoped_construct.bot] -warnings off]
set outcomes {}
foreach backend $backends {
    dict set outcomes $backend [lrange [outcomeUnderHir $backend $hir] 0 1]
}
set distinct [lsort -unique [dict values $outcomes]]
puts "prototype C, expansion: [llength $backends] backends, [expr {[llength $distinct] == 1 ? "one outcome" : "DISAGREE"}]"
foreach {- s} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} [lindex $distinct 0 1]] {
    if {[regexp {^t=\d+: (\d .*)$} $s -> claim]} {
        puts "   $claim"
    }
}
