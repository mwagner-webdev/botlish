# mutate.tcl -- mutation testing of syntax-error-tolerant analysis
# (SYNTAX-RECOVERY-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/syntax-recovery/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug in one rule of the milestone -- what a
# malformed statement's prefix establishes, the damage the lexer leaves, the
# holes (no value, no divergence, no unit), what a hole may bind or declare,
# a function's declared contract against what its incomplete body would
# infer, the diagnostics that depend on a hole (reported) and the ones that
# do not (suppressed), static blocks, the strict compilation, the backends'
# refusal, the cache, the service's outcome, facts and revision transfer,
# and the language server's choice between a fresh partial revision and a
# stale complete one -- written in mutants.txt (beside this script) as
# exact source replacements, each replaced text occurring exactly once. For
# each, a private copy of the compiler, the service, the language server and
# the tests (a temporary directory; native/target is a symlink to this
# checkout's, so no mutant rebuilds it) gets the replacements, and the test
# file that states the rule (tests/syntax-recovery.test unless the mutant
# names another, with its -match patterns) runs against it, with a private
# -tmpdir. The mutant is killed if a test fails or the file does not
# complete; a mutant it misses SURVIVES. The report lists each mutant, the
# tests that killed it, and the survivors. The real checkout is never
# modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 900]
# A mutant that breaks the protocol makes the client wait for answers that
# never come: its waits are shortened (tests/lsp-client.tcl), so it fails
# fast, not after a minute per test.
set ::env(BOTLISH_LSPC_TIMEOUT) 15000
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION TEST EDITS ...}, TEST {FILE PATTERNS} and EDITS
# {FILE OLD NEW ...}.
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
                    if {$name ne ""} { lappend mutants $name $description $testSpec $edits }
                    set name $n
                    set description $d
                    set testSpec [list tests/syntax-recovery.test ""]
                    set edits {}
                } elseif {[regexp {^%% (\S+) ?(.*)$} $line -> file patterns]} {
                    set testSpec [list $file $patterns]
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
    if {$name ne ""} { lappend mutants $name $description $testSpec $edits }
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

# A private copy of the compiler sources, the service, the language server,
# Compilerpedia, the tests and what they read (the examples, the
# diagnostic-recovery corpus and the syntax-recovery experiments).
set tree [file tempdir botlish-syntax-mutants]
foreach dir {compiler core hir surface service lsp stdlib compilerpedia tests examples audit/diagnostic-recovery audit/syntax-recovery} {
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
    foreach {name description testSpec edits} $mutants {
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
            # The code the mutant edits changed: update mutants.txt.
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        lassign $testSpec testFile patterns
        set tmp [file tempdir botlish-syntax-mutant-run]
        set match {}
        if {$patterns ne ""} {
            set match [list -match $patterns]
        }
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp {*}$match] status output
        file delete -force $tmp
        set failed [regexp -all -inline -line {^==== ((?:sr|lsp|cs|cli)-\S+) } $output]
        set failed [lsort -unique [lmap {- n} $failed {set n}]]
        if {[regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> n]} {
            set tests [expr {$n > 0 ? "killed ($n failed: [join [lrange $failed 0 5] {, }][expr {[llength $failed] > 6 ? ", ..." : ""}])" : "survived"}]
        } else {
            set tests "killed (did not complete: [string range [lindex [split [string trim $output] \n] end] 0 120])"
        }
        set verdict [expr {[string match killed* $tests] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests]
        puts "$verdict $name ([file tail $testFile])\n    tests: $tests"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ne "NOT-APPLIED"} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
