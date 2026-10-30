# run.tcl -- the outcome of every probe of audit/equality-semantics/census/
# (EQUALITY-SEMANTIC-CENSUS.md), told apart by when and how it ends.
#
#   tclsh9.0 audit/equality-semantics/tools/run.tcl ?-backends B,...?
#       ?-out FILE? ?PROBE.bot ...?
#
# For each probe (default: every census/*.bot, sorted) it runs, each as a
# child process of main.tcl with warnings off and a 300 s limit:
#
#   check      main.tcl -check: the static verdict (the compiler service's
#              strict analysis; nothing runs)
#   BACKEND    main.tcl -backend BACKEND, for each backend (default interp,
#              compile, cranelift, cranelift-generic)
#
# and classifies each run's first result line:
#
#   ok                    -check found nothing
#   static KIND: TEXT     a diagnostic of the compilation (-check, or a
#                         backend's run rejected before it ran)
#   value V               the program completed with value V
#   runtime EQUALITY: T   the program raised EQUALITY when it ran
#   runtime KIND: T       another run-time error
#
# A static diagnostic carries its location (FILE:LINE:COLUMN:); a run-time
# error has none, which is how the two are told apart. A probe whose -check
# is `ok` but whose backend says `static` would be a disagreement between
# the service and a backend (none is expected). Writes the report to FILE
# (default stdout). The checkout is only read.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set backends {interp compile cranelift cranelift-generic}
set out ""
set probes {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -backends { set backends [split [lindex $argv [incr i]] ,] }
        -out { set out [lindex $argv [incr i]] }
        default { lappend probes [file normalize $arg] }
    }
}
if {$probes eq {}} {
    set probes [lsort [glob -directory [file join $root audit equality-semantics census] *.bot]]
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

proc Classify {output} {
    foreach line [split $output \n] {
        set line [string trim $line]
        if {[regexp {^value: (.*)$} $line -> value]} {
            return "value $value"
        }
        if {[regexp {^error: } $line]} {
            # The error code in parentheses at the end ("CORE SEMANTIC
            # TYPE", "SURFACE MODULE MISSING-IMPORT"): its last word.
            set kind ?
            if {[regexp {\(([A-Z][A-Z0-9 -]*)\)\s*$} $line -> code]} {
                set kind [lindex $code end]
            }
            regsub {\s*\([A-Z][A-Z0-9 -]*\)\s*$} $line {} text
            regsub {^error: } $text {} text
            if {[regexp {^[^ ]+\.bot:(\d+):(\d+): (.*)$} $text -> l c message]} {
                return "static $kind: $l:$c: $message"
            }
            return "runtime $kind: $text"
        }
    }
    return "? [lindex [split [string trim $output] \n] end]"
}

set report {}
foreach probe $probes {
    set f [open $probe r]
    fconfigure $f -encoding utf-8
    set first [string trim [gets $f]]
    close $f
    lappend report "== [file tail $probe]  $first"
    catch {exec timeout 300 tclsh9.0 [file join $root main.tcl] -warnings off -check $probe 2>@1} output
    set verdict [Classify $output]
    if {[string match "value *" $verdict] || [string match "\\? *" $verdict]} {
        set verdict ok
    }
    lappend report "  [format %-18s check] $verdict"
    foreach backend $backends {
        catch {exec timeout 300 tclsh9.0 [file join $root main.tcl] -warnings off -backend $backend $probe 2>@1} output
        lappend report "  [format %-18s $backend] [Classify $output]"
    }
    puts stderr [file tail $probe]
}
if {$out eq ""} {
    puts [join $report \n]
} else {
    set f [open $out w]
    fconfigure $f -encoding utf-8
    puts $f [join $report \n]
    close $f
}
