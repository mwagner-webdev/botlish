# repro.tcl -- runs the minimal reproducers of ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md
# (audit/icy-tower/context-refactor/repro/) and checks each against the
# expectations written in its own header.
#
#   tclsh9.0 audit/icy-tower/context-refactor/tools/repro.tcl ?NAME ...?
#
# A reproducer is a .bot file of repro/ (or a main*.bot of one of its
# subdirectories: a multi-module application) whose leading comments hold
# lines
#
#   # expect BACKEND: value: TEXT        the program's value on BACKEND
#   # expect BACKEND: value: *           a value, whatever it is (a program
#                                        that reads memory nothing wrote)
#   # expect BACKEND: CODE CODE ...      the diagnostic codes, in order
#   # expect check: ok                   main.tcl -check accepts it
#
# BACKEND is interp, compile, cranelift-generic or cranelift. Each is run
# with main.tcl (-backend BACKEND, or -check) from the repository root; the
# observed outcome is the "value:" line, or the code of every diagnostic --
# the last word of the parenthesized error code that ends it, e.g. MISSING-
# CONTEXT of "(CORE SEMANTIC MISSING-CONTEXT)". NAME arguments select
# reproducers by file name prefix. Prints one line per run and exits 1 on any
# difference.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]
set dir [file normalize [file join $here .. repro]]
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8

set files [lsort [glob -directory $dir *.bot]]
foreach sub [lsort [glob -nocomplain -type d -directory $dir *]] {
    lappend files {*}[lsort [glob -nocomplain -directory $sub main*.bot]]
}
if {$argc > 0} {
    set files [lmap f $files {
        set keep 0
        foreach name $argv {
            if {[string match $name* [file tail $f]] || [string match $name* [file tail [file dirname $f]]]} { set keep 1 }
        }
        if {!$keep} continue
        set f
    }]
}

proc Observed {output} {
    foreach line [split $output \n] {
        if {[regexp {^   value: (.*)$} $line -> value]} {
            return "value: $value"
        }
        if {[regexp {^   ok$} $line]} {
            return ok
        }
    }
    set codes {}
    foreach line [split $output \n] {
        if {[string match *help:* $line]} continue
        if {[regexp {\((?:[A-Z]+ )+([A-Z][A-Z0-9-]*)\)\s*$} $line -> code]} {
            lappend codes $code
        }
    }
    return [join $codes " "]
}

set failures 0
foreach file $files {
    set channel [open $file r]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    set expectations {}
    foreach line [split $text \n] {
        if {![string match #* $line]} break
        if {[regexp {^# expect (\S+): (.*)$} $line -> backend expected]} {
            lappend expectations $backend [string trim $expected]
        }
    }
    set name [string range $file [string length $dir]+1 end]
    if {$expectations eq {}} {
        puts "SKIP  $name (no expectations)"
        continue
    }
    foreach {backend expected} $expectations {
        set mode [expr {$backend eq "check" ? [list -check] : [list -backend $backend]}]
        catch {exec [info nameofexecutable] [file join $root main.tcl] {*}$mode $file 2>@1} output
        set observed [Observed $output]
        if {$observed eq $expected || ($expected eq "value: *" && [string match "value: *" $observed])} {
            puts "ok    $name  $backend: $observed"
        } else {
            incr failures
            puts "DIFF  $name  $backend: expected {$expected}, observed {$observed}"
            puts [join [lmap l [split $output \n] {string cat "        " $l}] \n]
        }
    }
}
puts "[expr {$failures ? "$failures differences" : "all as expected"}]"
exit [expr {$failures > 0}]
