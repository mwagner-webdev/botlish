# tree.tcl -- the private-tree machinery the golden audit tools share
# (mutate.tcl, check.tcl): read mutants, copy the checkout, apply a mutant's
# edits to the copy, run detectors in it. The real checkout is never
# modified (AGENTS.md: scratch state lives in a `file tempdir` directory).

namespace eval goldentools {}

set ::goldentools::root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

proc goldentools::readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

proc goldentools::writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The mutants of the mutants file PATH (audit/*/tools/mutants.txt format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
proc goldentools::readMutants {path} {
    set lines [split [readFile $path] \n]
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

# The mutant NAME of the mutants file PATH: {DESCRIPTION EDITS}.
proc goldentools::mutant {path name} {
    foreach {n description edits} [readMutants $path] {
        if {$n eq $name} {
            return [list $description $edits]
        }
    }
    error "no mutant \"$name\" in $path"
}

proc goldentools::isNative {edits} {
    foreach {file old new} $edits {
        if {[string match native/src/* $file] || [string match native/Cargo.* $file]} {
            return 1
        }
    }
    return 0
}

# A private copy of the checkout's sources, library, tests, examples, tools
# and audit tools in a fresh temporary directory. Its native/target is a real
# copy when NATIVE (a native mutant will rebuild it), else a link to the
# checkout's. tools/ is copied because tests run its checks (the native
# lowercase table's generator, Compilerpedia, the editor grammars): without
# it those tests fail in every copy, and a harness would count every mutant
# killed by them.
proc goldentools::makeTree {native} {
    set root $::goldentools::root
    set tree [file tempdir botlish-golden-tree]
    foreach dir {compiler core hir surface stdlib tests examples bench audit tools .cargo} {
        if {![file exists [file join $root $dir]]} continue
        file mkdir [file dirname [file join $tree $dir]]
        file copy [file join $root $dir] [file join $tree $dir]
    }
    file mkdir [file join $tree native]
    foreach entry [glob -directory [file join $root native] *] {
        if {[file tail $entry] ne "target"} {
            file copy $entry [file join $tree native]
        } elseif {$native} {
            # Copy the directory, following links: when native/target links
            # to another checkout's (AGENTS.md, "Running tests concurrently"),
            # a copied link would build every native mutant into that checkout.
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
    return $tree
}

# Applies EDITS to TREE. Returns {1 TOUCHED} (TOUCHED: file -> original
# text, for restore), or {0 FILE} when an edit's text does not occur exactly
# once in FILE (the edits already made are undone).
proc goldentools::apply {tree edits} {
    set touched [dict create]
    foreach {file old new} $edits {
        set path [file join $tree $file]
        if {![dict exists $touched $file]} {
            dict set touched $file [readFile $path]
        }
        set text [readFile $path]
        set first [string first $old $text]
        if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
            restore $tree $touched
            return [list 0 $file]
        }
        writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
    }
    return [list 1 $touched]
}

proc goldentools::restore {tree touched} {
    dict for {file text} $touched {
        writeFile [file join $tree $file] $text
    }
}

# Runs ARGS with a TIMEOUT (seconds): {STATUS OUTPUT}.
proc goldentools::run {timeout args} {
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

proc goldentools::lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 160]
}

# Rebuilds TREE's native backend: "" when it built, else the last line of
# the build's output.
proc goldentools::build {tree timeout} {
    set here [pwd]
    cd $tree
    try {
        lassign [run $timeout cargo build --release --manifest-path [file join $tree native Cargo.toml]] status output
    } finally {
        cd $here
    }
    return [expr {$status == 0 ? "" : [lastLine $output]}]
}

# Runs the tcltest file TESTFILE (relative to TREE) in TREE with a private
# -tmpdir, only the tests matching MATCH when it is not "" (a list of
# patterns). Returns {FAILED PASSED INCOMPLETE}: the failed test names, the
# passed count, and "" or why the file did not complete.
proc goldentools::runTestFile {tree testFile timeout {match ""}} {
    set tmp [file tempdir botlish-golden-run]
    set args [list -tmpdir $tmp]
    if {$match ne ""} {
        # -verbose p: each test that passes prints "++++ NAME PASSED", so a
        # caller can tell a passing test from one that never ran.
        lappend args -match $match -verbose p
    }
    try {
        lassign [run $timeout tclsh9.0 [file join $tree $testFile] {*}$args] status output
    } finally {
        file delete -force $tmp
    }
    set failed [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
    set incomplete ""
    set passed 0
    if {[regexp {Total\s+\d+\s+Passed\s+(\d+)\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> passed failedCount]} {
    } else {
        set incomplete "[file tail $testFile]: [lastLine $output]"
    }
    set passedNames [lmap {- n} [regexp -all -inline -line {^\+\+\+\+ (\S+) PASSED$} $output] {set n}]
    return [list [lsort -unique $failed] $passed $incomplete [lsort -unique $passedNames]]
}

# Runs the golden suites SUITES (paths relative to TREE; every
# tests/golden/*.bot when empty) in TREE: a dict suite -> {STATUS VERDICTS},
# STATUS ok|failed|aborted|disagree|compile-error, VERDICTS a dict test name
# -> PASS|FAIL (FAIL if the test failed on any backend that reported).
proc goldentools::runSuites {tree suites timeout {backends {interp compile cranelift-generic cranelift}}} {
    if {$suites eq ""} {
        set suites [lmap p [lsort [glob -directory [file join $tree tests golden] *.bot]] {
            string range $p [expr {[string length $tree] + 1}] end
        }]
    }
    set results [dict create]
    foreach suite $suites {
        lassign [run $timeout tclsh9.0 [file join $tree tests golden run.tcl] -backends [join $backends ,] -names [file join $tree $suite]] status output
        set verdicts [dict create]
        set state incomplete
        foreach line [split $output \n] {
            if {[regexp {^\S+ STATUS (\S+)$} $line -> s]} {
                set state $s
            } elseif {[regexp {^\S+ (PASS|FAIL) (.*)$} $line -> verdict name]} {
                dict set verdicts $name $verdict
            }
        }
        dict set results $suite [list $state $verdicts]
    }
    return $results
}

# Runs COMMANDS -- a dict KEY -> argument list -- at most JOBS at a time, each
# with a TIMEOUT (seconds): a dict KEY -> {STATUS OUTPUT SECONDS}, as run.
proc goldentools::runParallel {jobs timeout commands} {
    variable pool
    set pool(results) [dict create]
    set pool(pending) [dict keys $commands]
    set pool(running) 0
    set pool(commands) $commands
    set pool(timeout) $timeout
    while {[llength $pool(pending)] > 0 || $pool(running) > 0} {
        while {$pool(running) < $jobs && [llength $pool(pending)] > 0} {
            set key [lindex $pool(pending) 0]
            set pool(pending) [lrange $pool(pending) 1 end]
            set channel [open |[list timeout $timeout {*}[dict get $commands $key] 2>@1] r]
            fconfigure $channel -blocking 0 -encoding utf-8
            set pool(output,$channel) ""
            set pool(start,$channel) [clock milliseconds]
            fileevent $channel readable [list goldentools::PoolRead $channel $key]
            incr pool(running)
        }
        vwait ::goldentools::pool(event)
    }
    return $pool(results)
}

proc goldentools::PoolRead {channel key} {
    variable pool
    append pool(output,$channel) [read $channel]
    if {![eof $channel]} return
    fconfigure $channel -blocking 1
    set status 0
    if {[catch {close $channel} message options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
    }
    set seconds [expr {([clock milliseconds] - $pool(start,$channel)) / 1000.0}]
    dict set pool(results) $key [list $status $pool(output,$channel) $seconds]
    unset pool(output,$channel) pool(start,$channel)
    incr pool(running) -1
    set pool(event) $key
}

# The verdicts of a tcltest file's verbose (-verbose ps) OUTPUT: {FAILED
# PASSED SKIPPED INCOMPLETE}, the failed, passed and skipped test names, and
# "" or why the file did not complete (its last line).
proc goldentools::testVerdicts {output} {
    set failed [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
    set passed [lsort -unique [lmap {- n} [regexp -all -inline -line {^\+\+\+\+ (\S+) PASSED$} $output] {set n}]]
    set skipped [lsort -unique [lmap {- n} [regexp -all -inline -line {^\+\+\+\+ (\S+) SKIPPED:} $output] {set n}]]
    set incomplete ""
    if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+\d+} $output]} {
        set incomplete [lastLine $output]
    }
    return [list $failed $passed $skipped $incomplete]
}

# The verdicts of tests/golden/run.tcl -names OUTPUT for one suite: {STATE
# VERDICTS}, as runSuites.
proc goldentools::suiteVerdicts {output} {
    set verdicts [dict create]
    set state incomplete
    foreach line [split $output \n] {
        if {[regexp {^\S+ STATUS (\S+)$} $line -> s]} {
            set state $s
        } elseif {[regexp {^\S+ (STATIC|STANDIN) } $line]} {
            continue
        } elseif {[regexp {^\S+ (PASS|FAIL) (.*)$} $line -> verdict name]} {
            dict set verdicts $name $verdict
        }
    }
    return [list $state $verdicts]
}

# The static economics line of tests/golden/run.tcl -names OUTPUT: a dict
# rounds, builds, trials, mispredicted, compile -- or "" (no static site).
proc goldentools::suiteStatic {output} {
    foreach line [split $output \n] {
        if {[regexp {^\S+ STATIC (.*)$} $line -> fields]} {
            return $fields
        }
    }
    return ""
}
