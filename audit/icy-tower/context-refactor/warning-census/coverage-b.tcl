# coverage-b.tcl -- how much of a test file's program building
# extract-tests.tcl's capture reached: for every test whose body stopped
# early (a stubbed backend's dummy value where a real one was needed, a
# refused exec), whether the body's text builds more programs than were
# captured from it.
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/coverage-b.tcl \
#       TESTFILE CAPTURE-DIR...
#
# CAPTURE-DIRs are extract-tests.tcl's output directories for TESTFILE (one
# per -platform run). The file's text is split into its top-level commands
# (never evaluated). A *builder* is surface::compile, surface::readProgramFile
# or a proc of the file (or of tests/helpers.tcl) whose body names a builder,
# transitively. For each test whose body did not finish in every capture
# directory, the body's builder calls (static occurrences: a call in a loop
# counts once) are compared with the most captures any run made from it:
#
#   TEST  STATUS  STATIC  CAPTURED  covered|LOST?
#
# LOST? when the body names more builder calls than were captured -- a
# program the census may have missed, to be read by hand; DYNAMIC for a
# stopped test the file defines inside a loop or a proc (no static body),
# also read by hand. Last line: the totals.

proc ReadText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

# The top-level commands of SCRIPT, as lists (braced words unparsed).
proc Commands {script} {
    set result {}
    set current ""
    foreach line [split $script \n] {
        append current $line \n
        if {[info complete $current]} {
            set trimmed [string trim $current]
            if {$trimmed ne "" && ![string match #* $trimmed]} {
                lappend result $trimmed
            }
            set current ""
        }
    }
    return $result
}

set testFile [lindex $argv 0]
set dirs [lrange $argv 1 end]
set root [file normalize [file join [file dirname [info script]] .. .. .. ..]]

set procs [dict create]
set tests {}
foreach path [list [file join $root tests helpers.tcl] $testFile] {
    foreach command [Commands [ReadText $path]] {
        if {[regexp {^proc\s} $command] && ![catch {llength $command} words] && $words == 4} {
            dict set procs [string trimleft [lindex $command 1] :] [lindex $command 3]
        } elseif {[regexp {^test\s+(\S+)} $command -> name] && $path eq $testFile} {
            # The -setup and -body words, braced: read by brace matching (a
            # test's -result need not be a well-formed list).
            set body ""
            foreach option {-setup -body} {
                set at [string first "$option \x7b" $command]
                if {$at < 0} continue
                set start [expr {$at + [string length $option] + 1}]
                set end [expr {$start + 1}]
                while {$end < [string length $command]
                        && !([string index $command $end] eq "\x7d" && [info complete [string range $command $start $end]])} {
                    incr end
                }
                append body [string range $command $start $end] \n
            }
            lappend tests $name $body
        }
    }
}
set builders {surface::compile surface::readProgramFile}
set changed 1
while {$changed} {
    set changed 0
    dict for {name body} $procs {
        if {$name in $builders} continue
        foreach b $builders {
            if {[regexp "(^|\[^A-Za-z0-9_:\])[string map {:: ::} $b](\$|\[^A-Za-z0-9_:\])" $body]} {
                lappend builders $name
                set changed 1
                break
            }
        }
    }
}

# Status and captures per test, across the capture directories.
set status [dict create]
set captured [dict create]
foreach dir $dirs {
    set f [open [file join $dir tests.tsv] r]
    fconfigure $f -encoding utf-8
    foreach line [split [string trimright [read $f] \n] \n] {
        lassign [split $line \t] name constraints st n ms
        if {$st ne "ok" || ![dict exists $status $name]} {
            if {![dict exists $status $name] || [dict get $status $name] eq "ok"} {
                dict set status $name $st
            }
        }
        if {![dict exists $captured $name] || $n > [dict get $captured $name]} {
            dict set captured $name $n
        }
    }
    close $f
}

set totals [dict create stopped 0 covered 0 lost 0 dynamic 0]
foreach {name body} $tests {
    if {![dict exists $status $name] || [dict get $status $name] eq "ok"} continue
    set static 0
    foreach b $builders {
        incr static [regexp -all "(^|\[^A-Za-z0-9_:\$\])${b}(\$|\[^A-Za-z0-9_:\])" $body]
    }
    set n [dict getdef $captured $name 0]
    set verdict [expr {$static > $n ? "LOST?" : "covered"}]
    dict incr totals stopped
    dict incr totals [expr {$verdict eq "covered" ? "covered" : "lost"}]
    puts [join [list $name [string range [dict get $status $name] 0 79] $static $n $verdict] \t]
}
# Stopped tests the file defines dynamically (a `test` inside a loop or a
# proc): no static body to compare; read by hand.
set static [dict create]
foreach {name body} $tests { dict set static $name 1 }
dict for {name st} $status {
    if {$st eq "ok" || [dict exists $static $name]} continue
    dict incr totals stopped
    dict incr totals dynamic
    puts [join [list $name [string range $st 0 79] ? [dict getdef $captured $name 0] DYNAMIC] \t]
}
puts "builders: [lsort $builders]"
puts "totals: $totals"
