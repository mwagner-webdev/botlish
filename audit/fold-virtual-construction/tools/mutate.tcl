# mutate.tcl -- mutation testing of FOLD-VIRTUAL-LIST-CONSTRUCTION-
# MILESTONE-1.md: a fold whose String/List intermediate is only extended
# carries it as a construction plan -- linear per iteration (a continue or a
# bare break is a reference), uncaptured, the construction continuing
# through it -- initialized from its initial value in a plan position,
# extended in place by the body's trailing value, materialized once at
# exhaustion and at a break.
#
#   tclsh9.0 audit/fold-virtual-construction/tools/mutate.tcl ?-only NAME,...? \
#       ?-timeout SECONDS? ?-fuzz-count N? ?-fuzz-seed S?
#
# Each mutant is a deliberate bug written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the compiler (a `file tempdir`
# directory) gets the replacements, and it runs:
#
#   * tests/fold-virtual-construction.test (a private -tmpdir): values on
#     every backend with the optimization on and off, eligibility decisions,
#     NIR structure, copy counts, releases, GC stress, an executable;
#   * this directory's fuzz.tcl (-fuzz-count programs of -fuzz-seed):
#     random folds against the independent value and eligibility models.
#
# The mutant is killed if a test fails, the file does not complete, or the
# fuzzer reports a disagreement or a misprediction. A native mutant (one
# that edits the native backend's Rust sources) first rebuilds the copy's
# release backend; its
# native/target is then a real copy (cp -a, following a link), never this
# checkout's. Tcl-only mutants run first, against a link to this checkout's
# native/target. The real checkout is never modified. Exits 1 if a mutant
# survives or no longer applies (update its text: keep it a mutant of the
# same rule).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 1800 -fuzz-count 40 -fuzz-seed 1]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
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
                    if {$name ne ""} { lappend mutants $name $description $edits }
                    set name $n
                    set description $d
                    set edits {}
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
    if {$name ne ""} { lappend mutants $name $description $edits }
    return $mutants
}

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

# 1 if a mutant edits the native backend's Rust sources (not native/*.tcl,
# which no build compiles).
proc isNative {edits} {
    foreach {file old new} $edits {
        if {[string match native/* $file] && ![string match *.tcl $file]} {
            return 1
        }
    }
    return 0
}

# Selected mutants, Tcl-only ones first.
set only [split [dict get $options -only] ,]
set selected {}
set nativeSelected {}
foreach {name description edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {[isNative $edits]} {
        lappend nativeSelected $name $description $edits
    } else {
        lappend selected $name $description $edits
    }
}
set selected [concat $selected $nativeSelected]

# A private copy of the compiler sources, tests, library, examples, this
# audit's tools and the native backend.
set tree [file tempdir botlish-fold-vc-mutants]
foreach dir {compiler core hir surface stdlib tests examples service lsp compilerpedia audit/fold-virtual-construction .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } elseif {$nativeSelected ne {}} {
        # Copy the directory, following links: when native/target links to
        # another checkout's (AGENTS.md, "Running tests concurrently"), a
        # copied link would build every native mutant into that checkout.
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        exec cp -a $entry [file join $tree native target]
    } else {
        file link -symbolic [file join $tree native target] $entry
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

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

set results {}
set manifest [file join $tree native Cargo.toml]
try {
    foreach {name description edits} $selected {
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
            lappend results [list $name $description NOT-APPLIED "" ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set native [isNative $edits]
        if {$native} {
            # Cargo finds the copy's .cargo/config.toml (frame pointers: the
            # collector's stack walk needs them) from the working directory.
            set here [pwd]
            cd $tree
            lassign [run [dict get $options -timeout] cargo build --release --manifest-path $manifest] status output
            cd $here
            if {$status != 0} {
                lappend results [list $name $description NOT-BUILT "" ""]
                puts "NOT-BUILT $name: [lastLine $output]"
                dict for {file text} $touched {
                    writeFile [file join $tree $file] $text
                }
                continue
            }
        }
        set tmp [file tempdir botlish-fold-vc-mutant-run]
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree tests fold-virtual-construction.test] -tmpdir $tmp] status output
        file delete -force $tmp
        set failedTests [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
            set tests "killed (did not complete: [lastLine $output])"
        } elseif {$failedTests ne {}} {
            set tests "killed ([llength $failedTests] failed: [join [lrange $failedTests 0 5] {, }][expr {[llength $failedTests] > 6 ? ", ..." : ""}])"
        } else {
            set tests survived
        }
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit fold-virtual-construction tools fuzz.tcl] \
            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed]] status output
        set summary [lindex [split [string trim $output] \n] end]
        if {[regexp {programs \d+ plan \d+ flat \d+ unreached \d+ disagreements (\d+) mispredictions (\d+)} $summary -> d m]} {
            set fuzz [expr {$d + $m > 0 ? "killed ($d disagreements, $m mispredictions)" : "survived"}]
        } else {
            set fuzz "killed (did not complete: [lastLine $output])"
        }
        set verdict [expr {[string match killed* $tests] || [string match killed* $fuzz] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests $fuzz]
        puts "$verdict $name -- $description\n    tests: $tests\n    fuzz:  $fuzz"
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
