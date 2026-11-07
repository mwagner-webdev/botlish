# mutate.tcl -- mutation testing of Botlish-owned threads and the
# cross-thread transport (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-
# MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/threads/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug -- a thread started without its guard, a
# start that ignores its authority's limit, an endpoint that ignores a
# capability's key, generation or schema, backpressure that lets a sender
# overtake or deadlock, a call left waiting when its service goes, a stop
# request nobody sees, a version 1 ABI call routed to one of several loops,
# a worker's loop left open, a thread entry the compiler fails to check, a
# Tcl backend that runs a threaded program, the transfer protocol's rebuild
# made public -- written in mutants.txt (beside this script) as exact source
# replacements, each replaced text occurring exactly once, with a `!!` line
# naming the detectors meant to kill it (the format is mutants.txt's header).
#
# A private copy of the checkout's sources, tests, packages and native
# backend (a temporary directory; native/target a real copy of the release
# build, never a link) first runs every detector any selected mutant names,
# unmutated: a detector that fails there would kill anything, so the run
# stops. Then, for each mutant that applies to this host (its %% line), the
# copy gets the replacements, its native backend is rebuilt (a mutant that
# does not build is NOT-BUILT, never killed; a mutant of Tcl or Botlish
# source rebuilds nothing), and only the mutant's own detectors run:
#
#   rust-lib:TEST, rust-bin:TEST   `cargo test --lib|--bin botlish-native
#                                  TEST`: only the tests TEST names run
#   FILE:TEST                      tclsh tests/FILE -match TEST, with a
#                                  private -tmpdir
#
# A mutant is KILLED when one of them fails or does not complete (a crash, a
# timeout: a mutant that deadlocks a run is killed by its timeout);
# SURVIVED otherwise. Exits 1 on a survivor, or a mutant that no longer
# applies or builds. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root core core.tcl]

set options [dict create -only "" -timeout 300]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set host [core::cabi::hostTarget]
set windows [string match windows-* $host]

# The mutants, as {NAME DESCRIPTION HOSTS DETECTORS {FILE OLD NEW ...}}.
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
                    if {$name ne ""} { lappend mutants $name $description $hosts $detectors $edits }
                    set name $n
                    set description $d
                    set hosts {}
                    set detectors {}
                    set edits {}
                } elseif {[regexp {^%% (.*)$} $line -> h]} {
                    set hosts $h
                } elseif {[regexp {^!! (.*)$} $line -> d]} {
                    lappend detectors {*}$d
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
    if {$name ne ""} { lappend mutants $name $description $hosts $detectors $edits }
    foreach {n - - d -} $mutants {
        if {$d eq {}} { error "mutant $n names no detector (a \"!! KIND:NAME ...\" line)" }
    }
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

# Runs ARGS (output and error together) in DIR for at most TIMEOUT seconds:
# {STATUS OUTPUT}, STATUS 0 on success, "timeout" when it was killed.
proc run {timeout dir args} {
    set here [pwd]
    cd $dir
    set pipe [open |[concat $args [list 2>@1]] r]
    cd $here
    fconfigure $pipe -blocking 0 -translation auto -encoding utf-8
    set ::runOutput ""
    set ::runDone 0
    fileevent $pipe readable [list apply {{pipe} {
        append ::runOutput [read $pipe]
        if {[eof $pipe]} { set ::runDone 1 }
    }} $pipe]
    set timer [after [expr {$timeout * 1000}] {set ::runDone timeout}]
    vwait ::runDone
    after cancel $timer
    if {$::runDone eq "timeout"} {
        foreach id [pid $pipe] {
            if {$::windows} { catch {exec taskkill /F /T /PID $id} } else { catch {exec kill -9 $id} }
        }
        catch {close $pipe}
        return [list timeout $::runOutput]
    }
    fconfigure $pipe -blocking 1
    set status 0
    if {[catch {close $pipe} message options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
    }
    return [list $status $::runOutput]
}

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 160]
}

set tclsh [info nameofexecutable]
set manifest native/Cargo.toml

# What detector DETECTOR (KIND:NAME) found failing in TREE: "" when it
# passed, else what failed.
proc detect {tree detector} {
    global tclsh manifest options
    set timeout [dict get $options -timeout]
    if {![regexp {^([^:]+):(.+)$} $detector -> kind name]} { error "detector $detector is not KIND:NAME" }
    switch -- $kind {
        rust-lib - rust-bin {
            set which [expr {$kind eq "rust-lib" ? "--lib" : "--bin"}]
            set command [list cargo test --release --manifest-path $manifest $which]
            if {$kind eq "rust-bin"} { lappend command botlish-native }
            lassign [run $timeout $tree {*}$command -- $name] status output
            if {$status == 0 && [regexp {test result: ok\. (\d+) passed} $output -> passed] && $passed > 0} { return "" }
            if {$status == 0} { return "no test matches $name" }
            set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
            return [expr {$failing eq {} ? "did not complete: [lastLine $output]" : [join $failing {, }]}]
        }
        native_stack {
            lassign [run $timeout $tree cargo test --release --manifest-path $manifest --test native_stack] status output
            set failing [lmap {- n} [regexp -all -inline -line {^FAIL (.+?):} $output] {set n}]
            set mine [lsearch -all -inline -glob $failing "$name*"]
            if {$mine ne {}} { return [join $mine {, }] }
            if {$status != 0 && $failing eq {}} { return "did not complete: [lastLine $output]" }
            return ""
        }
        default {
            set tmp [file tempdir botlish-threads-mutant-run]
            try {
                lassign [run $timeout $tree $tclsh [file join tests $kind] -tmpdir $tmp -match $name] status output
            } finally {
                file delete -force $tmp
            }
            if {![regexp {Total\s+(\d+)\s+Passed\s+(\d+)\s+Skipped\s+(\d+)\s+Failed\s+(\d+)} $output -> total passed skipped failed]} {
                return "did not complete: [lastLine $output]"
            }
            set names [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
            if {$names ne {}} { return [join $names {, }] }
            if {$passed == 0} { return "no test matches $name" }
            return ""
        }
    }
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description hosts detectors edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $hosts $detectors $edits
}

# The private copy (a real copy of the release build: every mutant rebuilds
# it, never into this checkout's).
if {[info exists ::env(RUNNER_TEMP)]} {
    set tree [file tempdir [file join $::env(RUNNER_TEMP) thr]]
} else {
    set tree [file tempdir botlish-threads-mutants]
}
foreach dir {compiler core hir surface stdlib tests tools examples bench audit service lsp compilerpedia generated packages .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        file mkdir [file join $tree native target]
        if {$windows} {
            file copy [file join $entry release] [file join $tree native target release]
        } else {
            exec cp -a [file join $entry release] [file join $tree native target release]
        }
    } elseif {![string match target-* [file tail $entry]]} {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}
unset -nocomplain ::env(BOTLISH_NATIVE_BIN) ::env(BOTLISH_NATIVE_GC_STRESS) ::env(BOTLISH_NATIVE_GC_MIN) ::env(BOTLISH_NATIVE_STACK_BYTES)

set results {}
try {
    # The baseline: every detector the selected mutants name passes on the
    # unmutated copy.
    set all [lsort -unique [concat {*}[lmap {- - - d -} $selected {set d}]]]
    puts "baseline: [llength $all] detectors"
    flush stdout
    foreach detector $all {
        set failed [detect $tree $detector]
        if {$failed ne ""} {
            puts "BASELINE FAILS $detector: $failed"
            exit 1
        }
    }
    puts "baseline: every detector passes unmutated"
    flush stdout
    foreach {name description hosts detectors edits} $selected {
        if {$hosts ne {} && $host ni $hosts} {
            lappend results [list $name SKIPPED ""]
            puts "SKIPPED $name: not compiled for $host"
            continue
        }
        set touched [dict create]
        set applied 1
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $touched $file]} { dict set touched $file [readFile $path] }
            set text [readFile $path]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                set applied 0
                break
            }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        set restore {
            dict for {file text} $touched { writeFile [file join $tree $file] $text }
        }
        if {!$applied} {
            lappend results [list $name NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            eval $restore
            continue
        }
        lassign [run [dict get $options -timeout] $tree cargo build --release --manifest-path $manifest] status output
        if {$status != 0} {
            lappend results [list $name NOT-BUILT ""]
            puts "NOT-BUILT $name: [lastLine $output]"
            foreach line [lrange [split [string trim $output] \n] end-11 end] { puts "    $line" }
            eval $restore
            continue
        }
        set killer ""
        foreach detector $detectors {
            set failed [detect $tree $detector]
            if {$failed ne ""} {
                set killer "$detector ($failed)"
                break
            }
        }
        set verdict [expr {$killer eq "" ? "SURVIVED" : "KILLED"}]
        lappend results [list $name $verdict $killer]
        puts "$verdict $name -- $description"
        if {$killer ne ""} { puts "    $killer" }
        flush stdout
        eval $restore
    }
    # Leave the copy's build as the unmutated one (nothing reads it after).
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 1] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 1] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set skipped [llength [lsearch -all -index 1 $results SKIPPED]]
set killed [llength [lsearch -all -index 1 $results KILLED]]
puts "[llength $results] mutants on $host, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}], $skipped skipped (another host's code)[expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
