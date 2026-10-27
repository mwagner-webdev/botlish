# mutate.tcl -- mutation testing of Windows unwind information and the
# native-frame GC roots built on it (WINDOWS-X86-64-MILESTONE-3.md, section 7).
#
#   tclsh9.0 audit/windows-unwind/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once: the UNWIND_INFO encoder (codegen/unwind.rs), the object's .pdata and
# .xdata (codegen/mod.rs), the JIT's function table and its lifetime
# (codegen/jitunwind.rs), the collector's walk across Rust and Botlish
# frames (runtime/framewalk.rs), and its walk of suspended coroutine stacks
# from the frame their switch recorded (runtime/coroutine/windows.rs:
# WINDOWS-X86-64-MILESTONE-5.md). (The stack-limit check's mutants went with
# it: WINDOWS-X86-64-MILESTONE-4.md; the stack guard's are
# audit/native-stack's.) For each mutant that
# applies to this host (its %% line), a private copy of the checkout gets the
# replacements, its native backend is rebuilt (a mutant that does not build
# is NOT-BUILT, never counted as killed), and the detectors run against it,
# cheapest first, until one fails:
#
#   * the native Rust tests (`cargo test --lib --bins`): the encoder, the
#     object's sections, a caller's root across its callee's collections,
#     and on Windows the JIT's function table, a virtual unwind of JIT frames
#     to their callers, the collector's walk checked against Windows';
#   * on Windows, tests/platform/native-status.tcl (the frame walk under GC
#     stress, the stack overflows);
#   * tests/platform/gc-workloads.tcl on the URI and 2048 workloads and the
#     coroutine workloads (suspended stacks holding roots while others
#     collect: WINDOWS-X86-64-MILESTONE-5.md), once plainly and once under GC
#     stress, with BOTLISH_NATIVE_UNWIND_CHECK on Windows (-unwind-check 1);
#   * on Windows, tests/platform/aot-facts.tcl (the object's .pdata, the
#     executable's unwind check, the standalone stack overflows).
#
# A mutant every detector misses SURVIVES. A mutant of code this host never
# compiles or never runs (the JIT's function table off Windows) is SKIPPED.
# The report lists each mutant and the detector that killed it; it exits 1 on
# a survivor or a mutant that no longer applies. The real checkout, its
# native/target included, is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root core core.tcl]

set options [dict create -only "" -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
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

# The detectors, cheapest first: {NAME HOSTS-WINDOWS-ONLY COMMAND FAILURES},
# FAILURES a script reading $status and $output and returning what failed
# ("" for nothing).
set tclsh [info nameofexecutable]
set detectors [list \
    rust 0 {cargo test --release --manifest-path native/Cargo.toml --lib --bins --no-fail-fast} {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join [lrange $failing 0 5] {, }]}
    } \
    native-status 1 [list $tclsh tests/platform/native-status.tcl] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^FAIL\s+(\S+)} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join $failing {, }]}
    } \
    gc-workloads 0 [list $tclsh tests/platform/gc-workloads.tcl -repeat 1 -workloads uri,2048,coroutine-roots,coroutine-nested,coroutine-many -unwind-check $windows] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^FAILED: (.{0,80})} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join [lrange $failing 0 3] {; }]}
    } \
    aot-facts 1 [list $tclsh tests/platform/aot-facts.tcl] {
        if {$status == 0} { return "" }
        set failing [lmap {- n} [regexp -all -inline -line {^FAIL\s+(\S+)} $output] {set n}]
        expr {$failing eq {} ? [lastLine $output] : [join $failing {, }]}
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
# into another checkout.
# On a CI runner, under its own temporary directory: a shorter path than
# the user profile's, for Windows' build tools.
if {[info exists ::env(RUNNER_TEMP)]} {
    set tree [file tempdir [file join $::env(RUNNER_TEMP) wum]]
} else {
    set tree [file tempdir botlish-windows-unwind-mutants]
}
foreach dir {compiler core hir surface stdlib tests examples bench audit .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        file copy $entry [file join $tree native target]
    } elseif {![string match target-* [file tail $entry]]} {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}
unset -nocomplain ::env(BOTLISH_NATIVE_BIN) ::env(BOTLISH_NATIVE_GC_STRESS) ::env(BOTLISH_NATIVE_UNWIND_CHECK)

set results {}
set timeout [dict get $options -timeout]
try {
    foreach {name description hosts edits} $selected {
        if {$hosts ne {} && $host ni $hosts} {
            lappend results [list $name $description SKIPPED ""]
            puts "SKIPPED $name: not run on $host"
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
        lassign [run $timeout $tree cargo build --release --manifest-path native/Cargo.toml] status output
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
        foreach {detector windowsOnly command failures} $detectors {
            if {$windowsOnly && !$windows} continue
            lassign [run $timeout $tree {*}$command] status output
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
puts "[llength $results] mutants on $host, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}], $skipped skipped (not run on this host)[expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
