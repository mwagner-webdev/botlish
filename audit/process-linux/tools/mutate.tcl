# mutate.tcl -- mutation testing of the process_linux package: its native
# adapter and its module (PROCESS-LINUX-PACKAGE-MILESTONE-1.md, "Mutation
# testing").
#
#   tclsh9.0 audit/process-linux/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the repository's sources (a temporary
# directory; native/target a symbolic link to this checkout's, never
# rebuilt: no mutant edits the native backend) gets the replacements, and
# the tests its `%%` lines name run against it, each test file in its own
# process with a private -tmpdir (PATTERNs: a tcltest -match). The test file
# builds the package's archive and the scenario programs from the tree, so
# every mutant is compiled into what the tests run.
#
# A mutant is KILLED when a named test fails (a hang is a failure: every
# scenario runs under its own watchdog). It is NOT-BUILT when the test file
# could not even set up -- nothing passed and nothing failed, or the
# adapter (a C compiler's error) or a scenario program (a compilation
# error's errorCode) did not compile: no detection. A mutant nothing kills SURVIVES. The real checkout
# is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 3600]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt, as {NAME DESCRIPTION {FILE OLD NEW ...} TESTS ...}.
proc readMutants {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set lines [split [read $f] \n]
    close $f
    set mutants {}
    set name ""
    set state outside
    foreach line $lines {
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+) (.*)$} $line -> n d]} {
                    if {$name ne ""} { lappend mutants $name $description $edits $tests }
                    set name $n
                    set description $d
                    set edits {}
                    set tests {}
                } elseif {[regexp {^%% (.+)$} $line -> files]} {
                    lappend tests {*}$files
                } elseif {[regexp {^## (\S+)$} $line -> file]} {
                    set current $file
                } elseif {$line eq "<<<<"} {
                    set state old
                    set old {}
                }
            }
            old {
                if {$line eq "===="} {
                    set state new
                    set new {}
                } else {
                    lappend old $line
                }
            }
            new {
                if {$line eq ">>>>"} {
                    lappend edits $current [join $old \n] [join $new \n]
                    set state outside
                } else {
                    lappend new $line
                }
            }
        }
    }
    if {$name ne ""} { lappend mutants $name $description $edits $tests }
    return $mutants
}
set mutants [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]]

proc readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# A private copy of the sources the tests read.
set tree [file tempdir botlish-process-mutants]
foreach dir {ccompile compiler core hir surface stdlib tests service lsp pm tools single compilerpedia packages} {
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        file link -symbolic [file join $tree native target] $entry
    } else {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

proc run {timeout dir args} {
    set status 0
    if {[catch {exec sh -c {cd "$1" && shift && exec "$@"} sh $dir timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

set only [split [dict get $options -only] ,]
set results {}
try {
    foreach {name description edits tests} $mutants {
        if {$only ne {} && $name ni $only} continue
        set touched [dict create]
        set applied 1
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $touched $file]} {
                dict set touched $file [readFile $path]
            }
            set text [readFile $path]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                set applied 0
                break
            }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set verdicts {}
        set started [clock seconds]
        foreach spec $tests {
            set colon [string first : $spec]
            set testFile [expr {$colon < 0 ? $spec : [string range $spec 0 [expr {$colon - 1}]]}]
            set match [expr {$colon < 0 ? "" : [split [string range $spec [expr {$colon + 1}] end] ,]}]
            set tmp [file tempdir botlish-process-mutant-run]
            set extra {}
            if {$match ne ""} { set extra [list -match $match] }
            lassign [run [dict get $options -timeout] $tree tclsh9.0 [file join $tree tests $testFile] -tmpdir $tmp {*}$extra] status output
            file delete -force $tmp
            set failed [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
            if {[regexp -line {^---- errorCode: (?:SURFACE|CORE|HIR) } $output] || [regexp {\.c:\d+:\d+: error:} $output]} {
                lappend verdicts "not-built ($testFile: a scenario program did not compile)"
            } elseif {![regexp {Total\s+\d+\s+Passed} $output]} {
                lappend verdicts "not-built ($testFile did not complete)"
            } elseif {[regexp {Total\s+\d+\s+Passed\s+(\d+)\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> passed n] && $n > 0} {
                lappend verdicts "killed ($testFile: $n failed: [join [lrange $failed 0 5] {, }])"
            } elseif {$passed == 0} {
                lappend verdicts "not-built ($testFile: nothing passed, nothing failed: its constraints?)"
            }
        }
        set killedBy [lsearch -all -inline $verdicts killed*]
        set notBuilt [lsearch -all -inline $verdicts not-built*]
        set verdict [expr {$killedBy ne {} ? "KILLED" : $notBuilt ne {} ? "NOT-BUILT" : "SURVIVED"}]
        set shown [expr {$verdicts eq {} ? "survived" : [join $verdicts {; }]}]
        lappend results [list $name $description $verdict $shown]
        puts "$verdict $name ([expr {[clock seconds] - $started}] s)\n    $shown"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
