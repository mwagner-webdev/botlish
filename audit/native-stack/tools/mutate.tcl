# mutate.tcl -- mutation testing of the native stack guard
# (MACOS-AARCH64-MILESTONE-4.md, "Mutation testing";
# WINDOWS-X86-64-MILESTONE-4.md, "Mutation testing").
#
#   tclsh9.0 audit/native-stack/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each mutant that applies to this host (its %% line), a private
# copy of the checkout's sources, tests and native backend (a temporary
# directory) gets the replacements, its native backend is rebuilt (a mutant
# that does not build is reported NOT-BUILT, never counted as killed), and
# the detectors run against it, cheapest first, until one fails:
#
#   * the native Rust tests (`cargo test --lib --bins`): the host's stack
#     discovery, the Windows guard's classification and guard page, the
#     root plan, the call effects, the stack probes;
#   * native/tests/native_stack.rs (`cargo test --test native_stack`): the
#     host's stack facts, the guard in every mode, coroutine overflows,
#     unrelated faults, publication and the switch sweep (on Windows: the
#     guard on every kind of thread, its modes, the faults it must not
#     claim), every faulting check in a child process;
#   * tests/native-stack-overflow.test (with a private -tmpdir);
#   * tests/platform/native-status.tcl (the driver's overflows: Botlish
#     recursion, a large frame, the runtime's own recursion);
#   * tests/platform/aot-facts.tcl (a standalone executable's overflows);
#   * the fallback plan's Rust tests (`cargo test --lib --features
#     fallback-roots`, a build of its own): what only the shadow stack's
#     depth check decides.
#
# A mutant every detector misses SURVIVES. A mutant of code this host never
# compiles (macos.rs on Linux, guard.rs on Windows) is SKIPPED. The report
# lists each mutant and the detector that killed it; it exits 1 on a
# survivor or a mutant that no longer applies or builds. Portable to macOS
# and Windows: no GNU timeout, no /proc. The real checkout, its native/target
# included, is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root core core.tcl]

set options [dict create -only "" -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
# This host's target (linux-x86_64, linux-aarch64, macos-aarch64,
# windows-x86_64).
set host [core::cabi::hostTarget]
set windows [string match windows-* $host]

# The mutants of mutants.txt, as {NAME DESCRIPTION HOSTS {FILE OLD NEW ...}}
# (HOSTS empty: every host).
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
                    if {$name ne ""} { lappend mutants $name $description $hosts $edits }
                    set name $n
                    set description $d
                    set hosts {}
                    set edits {}
                } elseif {[regexp {^%% (.*)$} $line -> h]} {
                    set hosts $h
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
    if {$name ne ""} { lappend mutants $name $description $hosts $edits }
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

# Runs ARGS (output and error together) in directory DIR for at most TIMEOUT
# seconds: {STATUS OUTPUT}, STATUS 0 on success, "timeout" when it was
# killed for running too long.
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
            if {$::windows} {
                catch {exec taskkill /F /T /PID $id}
            } else {
                catch {exec kill -9 $id}
            }
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
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

# The detectors, cheapest first: {NAME COMMAND FAILURES}, FAILURES a script
# reading $status and $output and returning what failed ("" for nothing).
set tclsh [info nameofexecutable]
set manifest native/Cargo.toml
set detectors [list \
    rust [list cargo test --release --manifest-path $manifest --lib --bins --no-fail-fast] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join [lrange $failing 0 5] {, }]}
    } \
    native_stack [list cargo test --release --manifest-path $manifest --test native_stack] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^FAIL (.+?):} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : "[join [lrange $failing 0 5] {, }][expr {[llength $failing] > 6 ? ", ..." : ""}]"}
    } \
    native-stack-overflow.test [list $tclsh tests/native-stack-overflow.test -tmpdir TMPDIR] {
        set failed [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
            return "did not complete: [lastLine $output]"
        }
        expr {$failed eq {} ? "" : "[llength $failed] failed: [join [lrange $failed 0 5] {, }]"}
    } \
    native-status [list $tclsh tests/platform/native-status.tcl] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^FAIL\s+(\S+)} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join $failing {, }]}
    } \
    aot-facts [list $tclsh tests/platform/aot-facts.tcl] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^FAIL\s+(\S+)} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join $failing {, }]}
    } \
    fallback [list cargo test --release --manifest-path $manifest --features fallback-roots --target-dir native/target-fallback --lib --no-fail-fast] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join [lrange $failing 0 5] {, }]}
    }]

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description hosts edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $hosts $edits
}

# A private copy of the checkout's sources, the tests and their programs, and
# the native backend, its native/target a real copy (each mutant rebuilds
# it), following a linked target: a copied link would build every mutant
# into another checkout. On a CI runner, under its own temporary directory:
# a shorter path than the user profile's, for Windows' build tools.
if {[info exists ::env(RUNNER_TEMP)]} {
    set tree [file tempdir [file join $::env(RUNNER_TEMP) nsm]]
} else {
    set tree [file tempdir botlish-native-stack-mutants]
}
foreach dir {compiler core hir surface stdlib tests examples bench audit service lsp compilerpedia .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        if {$windows} {
            file copy $entry [file join $tree native target]
        } else {
            exec cp -a $entry [file join $tree native target]
        }
    } elseif {![string match target-* [file tail $entry]]} {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}
unset -nocomplain ::env(BOTLISH_NATIVE_BIN) ::env(BOTLISH_NATIVE_GC_STRESS) ::env(BOTLISH_NATIVE_UNWIND_CHECK) ::env(BOTLISH_NATIVE_STACK_BYTES)

set results {}
set timeout [dict get $options -timeout]
try {
    foreach {name description hosts edits} $selected {
        if {$hosts ne {} && $host ni $hosts} {
            lappend results [list $name $description SKIPPED ""]
            puts "SKIPPED $name: not compiled for $host"
            continue
        }
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
        set restore {
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
        }
        if {!$applied} {
            # The code the mutant edits changed: update mutants.txt.
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            eval $restore
            continue
        }
        # Cargo finds the copy's .cargo/config.toml (frame pointers) from the
        # working directory.
        lassign [run $timeout $tree cargo build --release --manifest-path $manifest] status output
        if {$status != 0} {
            lappend results [list $name $description NOT-BUILT ""]
            puts "NOT-BUILT $name: [lastLine $output]"
            foreach line [lrange [split [string trim $output] \n] end-11 end] {
                puts "    $line"
            }
            eval $restore
            continue
        }
        set killer ""
        foreach {detector command failures} $detectors {
            set tmp [file tempdir botlish-native-stack-mutant-run]
            lassign [run $timeout $tree {*}[lmap word $command {expr {$word eq "TMPDIR" ? $tmp : $word}}]] status output
            file delete -force $tmp
            set failed [apply [list {status output} $failures] $status $output]
            if {$failed ne ""} {
                set killer "$detector ($failed)"
                break
            }
        }
        set verdict [expr {$killer eq "" ? "SURVIVED" : "KILLED"}]
        lappend results [list $name $description $verdict $killer]
        puts "$verdict $name -- $description"
        if {$killer ne ""} { puts "    $killer" }
        flush stdout
        eval $restore
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set skipped [llength [lsearch -all -index 2 $results SKIPPED]]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants on $host, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}], $skipped skipped (another host's code)[expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
