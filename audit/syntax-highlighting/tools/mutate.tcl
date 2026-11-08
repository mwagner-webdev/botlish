# mutate.tcl -- mutation testing of syntax highlighting
# (SYNTAX-HIGHLIGHTING-MILESTONE-1.md).
#
#   tclsh9.0 audit/syntax-highlighting/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant of mutants.txt (beside this script; its header has the format)
# is a deliberate bug in one rule: the parser's word recording, the lexer's
# comments and recovery metadata, the token IR, the command line's
# presentation, the service's tokens, the server's semantic tokens, the
# grammar generator. For each, a private copy of the checkout (a temporary
# directory; native/target and editors/vscode/node_modules are symbolic links
# to this checkout's, which no mutant rebuilds) gets the replacements, and
# the tests its `!!` line names run against it (tests/syntax-highlighting.test
# for sh-*, tests/lsp.test for lsp-*, each with a private -tmpdir). The
# mutant is killed when one of them fails or its file does not complete; a
# mutant none of them catches SURVIVES. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 1200]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants, as {NAME DESCRIPTION TESTS {FILE OLD NEW ...}} each.
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
                    if {$name ne ""} { lappend mutants [list $name $description $tests $edits] }
                    set name $n
                    set description $d
                    set tests {}
                    set edits {}
                } elseif {[regexp {^!! (.*)$} $line -> t]} {
                    lappend tests {*}$t
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
    if {$name ne ""} { lappend mutants [list $name $description $tests $edits] }
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

# A private copy of what the tests read: the compiler, the service, the
# language server, the tools, the editors (their node_modules linked) and
# the tests.
set tree [file tempdir botlish-highlighting-mutants]
foreach dir {compiler core hir surface service lsp stdlib compilerpedia tests tools} {
    file copy [file join $root $dir] [file join $tree $dir]
}
foreach dir {editors/neovim editors/vscode} {
    file mkdir [file join $tree $dir]
    foreach entry [glob -nocomplain -directory [file join $root $dir] *] {
        if {[file tail $entry] eq "node_modules"} {
            file link -symbolic [file join $tree $dir node_modules] $entry
        } else {
            file copy $entry [file join $tree $dir]
        }
    }
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

proc run {timeout args} {
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

set only [split [dict get $options -only] ,]
set results {}
try {
    foreach mutant $mutants {
        lassign $mutant name description tests edits
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
            lappend results [list $name NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set failed {}
        set incomplete {}
        foreach {prefix testFile} {sh syntax-highlighting.test lsp lsp.test} {
            set names [lsearch -all -inline -glob $tests $prefix-*]
            if {$names eq {}} continue
            set tmp [file tempdir botlish-highlighting-mutant-run]
            lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree tests $testFile] \
                -tmpdir $tmp -match $names] status output
            file delete -force $tmp
            foreach {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {
                if {$n in $names} {
                    lappend failed $n
                }
            }
            if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+\d+} $output]} {
                lappend incomplete "$testFile: [string range [lindex [split [string trim $output] \n] end] 0 120]"
            }
        }
        set failed [lsort -unique $failed]
        if {$failed ne {}} {
            set verdict KILLED
            set detail "by [join $failed {, }]"
        } elseif {$incomplete ne {}} {
            set verdict KILLED
            set detail "did not complete: [join $incomplete {; }]"
        } else {
            set verdict SURVIVED
            set detail "none of [join $tests {, }] failed"
        }
        lappend results [list $name $verdict $detail]
        puts "$verdict $name: $detail"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 1] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 1] ne "NOT-APPLIED"} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 1 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
