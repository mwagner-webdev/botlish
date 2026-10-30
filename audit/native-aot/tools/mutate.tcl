# mutate.tcl -- mutation testing of native executable emission
# (MACOS-AARCH64-MILESTONE-5.md, "Mutation results").
#
#   tclsh9.0 audit/native-aot/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each mutant that applies to this host (its %% line), a private
# copy of the compiler, library, examples and native backend (a temporary
# directory) gets the replacements, its native backend is rebuilt (a mutant
# that does not build is reported NOT-BUILT, never counted as killed), and
# the detectors run against it:
#
#   * cargo test --bin botlish-native aot (the link plans' unit tests, the
#     system linker's among them) and --lib aotimage program (the stub
#     image's encoding and checks, and the program record's and
#     descriptor's, which every startup reads);
#   * tests/native-executable.test (formats, parity, paths, diagnostics,
#     stack overflows, coroutines);
#   * tests/argv.test's standalone tests (argv-standalone-*);
#   * tests/workload-2048.test's workload-2048-bench-executable (a moved
#     multi-file application);
#   * tests/system-linker.test (the system linker against the rustc and
#     stub linkers: startup reports, outputs under GC stress, C, failures;
#     SINGLE-EXECUTABLE-FFI-MILESTONE-1.md);
#   * tests/main-thread-startup.test (the startup policy: the command line,
#     the driver, the record, refusals, a panic, and on macOS the main
#     thread's executables; MAIN-THREAD-STARTUP-MILESTONE-1.md);
#   * tests/platform/aot-facts.tcl (the host's tools on the object and the
#     executable, the standalone runs);
#   * tests/platform/native-status.tcl (the executable, object and C call
#     probes, the target boundary).
#
# Each test file runs with a private -tmpdir. The unmutated tree runs the
# detectors first, and must pass all of them: otherwise no mutant is judged
# (a failure there is the tree's or the host's, and would pass for every
# mutant's kill). A mutant every detector misses SURVIVES; one whose code
# this host does not compile differently (another host's gate) is SKIPPED.
# The report lists each mutant and what killed it; it exits 1 on a failed
# baseline, a survivor or a mutant that no longer applies.
# Portable to macOS (no GNU timeout, no /proc). The real checkout, its
# native/target included, is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
# This host's target, named as core::cabi names it (linux-x86_64,
# linux-aarch64, macos-aarch64, windows-x86_64: never Tcl's "windows nt").
set host [string cat [expr {$::tcl_platform(os) eq "Darwin" ? "macos" : ($::tcl_platform(platform) eq "windows" ? "windows" : [string tolower $::tcl_platform(os)])}] - \
    [expr {$::tcl_platform(machine) in {arm64 aarch64} ? "aarch64" : ($::tcl_platform(machine) in {amd64 x86_64} ? "x86_64" : $::tcl_platform(machine))}]]

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
    fconfigure $pipe -blocking 0 -translation lf -encoding utf-8
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
        catch {exec kill -9 {*}[pid $pipe]}
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

# What a tcltest file run reported as failing (OUTPUT is its output), or
# "did not complete" when it printed no totals: "" when every test passed.
proc testFailures {label output} {
    if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> failed]} {
        return "$label (did not complete: [lastLine $output])"
    }
    set names [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
    if {$failed == 0 && $names eq {}} {
        return ""
    }
    return "$label ([llength $names] failed: [join [lrange $names 0 5] {, }][expr {[llength $names] > 6 ? ", ..." : ""}])"
}

# What the detectors report against TREE (its native backend built): a
# list of "LABEL (WHAT FAILED)", empty when every detector passed.
proc detect {tree manifest timeout} {
    set killers {}
    foreach {label target filter} {rust {--bin botlish-native} aot rust-lib --lib {-- aotimage program}} {
        lassign [run $timeout $tree cargo test --release --manifest-path $manifest -p botlish-native {*}$target {*}$filter] status output
        if {$status != 0} {
            set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
            lappend killers "$label ([expr {$failing eq {} ? [lastLine $output] : [join [lrange $failing 0 5] {, }]}])"
        }
    }
    foreach {label file match} {
        native-executable.test native-executable.test *
        argv.test argv.test argv-standalone-*
        workload-2048.test workload-2048.test workload-2048-bench-executable
        system-linker.test system-linker.test *
        main-thread-startup.test main-thread-startup.test *
    } {
        set tmp [file tempdir botlish-native-aot-mutant-run]
        lassign [run $timeout $tree tclsh9.0 [file join $tree tests $file] -tmpdir $tmp -match $match] status output
        file delete -force $tmp
        set failure [testFailures $label $output]
        if {$failure ne ""} { lappend killers $failure }
    }
    foreach script {aot-facts.tcl native-status.tcl} {
        lassign [run $timeout $tree tclsh9.0 [file join $tree tests platform $script]] status output
        if {$status != 0} {
            set failing [lmap {- n} [regexp -all -inline -line {^FAIL (\S+)} $output] {set n}]
            lappend killers "$script ([expr {$failing eq {} ? [lastLine $output] : [join [lrange $failing 0 5] {, }]}])"
        }
    }
    return $killers
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description hosts edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $hosts $edits
}

# A private copy of the front end, the tests, everything they read (the
# examples' 2048 application, the census programs under audit/, the
# service main.tcl loads) and the native backend, its native/target a real
# copy (each mutant rebuilds it), following a linked target: a copied link
# would build every mutant into another checkout.
set tree [file tempdir botlish-native-aot-mutants]
foreach dir {compiler compilerpedia core hir surface stdlib tests examples bench audit service lsp .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } else {
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        exec cp -a $entry [file join $tree native target]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

set results {}
set manifest [file join $tree native Cargo.toml]
set timeout [dict get $options -timeout]
# The unmutated tree first, when a selected mutant applies here: every
# detector must pass on it, or a mutant's "kill" may be the tree's own
# failure (a file the copy left out, a broken host), never the mutant's.
set applicable [llength [lmap {name description hosts edits} $selected {
    if {$hosts ne {} && $host ni $hosts} continue
    set name
}]]
set baseline ok
try {
    if {$applicable > 0} {
        lassign [run $timeout $tree cargo build --release --manifest-path $manifest] status output
        if {$status != 0} {
            set baseline "not built: [lastLine $output]"
        } elseif {[set failures [detect $tree $manifest $timeout]] ne {}} {
            set baseline "failed:\n    [join $failures "\n    "]"
        }
        puts "BASELINE (the unmutated tree): $baseline"
        flush stdout
    }
    foreach {name description hosts edits} [if {$baseline eq "ok"} {set selected} else {list}] {
        if {$hosts ne {} && $host ni $hosts} {
            lappend results [list $name $description SKIPPED ""]
            puts "SKIPPED $name: not compiled differently for $host"
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
            eval $restore
            continue
        }
        set killers [detect $tree $manifest $timeout]
        set verdict [expr {$killers eq {} ? "SURVIVED" : "KILLED"}]
        lappend results [list $name $description $verdict $killers]
        puts "$verdict $name -- $description"
        foreach killer $killers {
            puts "    $killer"
        }
        flush stdout
        eval $restore
    }
} finally {
    file delete -force $tree
}
if {$baseline ne "ok"} {
    puts "no mutant judged: the unmutated tree must pass every detector first"
    exit 1
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set skipped [llength [lsearch -all -index 2 $results SKIPPED]]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants on $host, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}], $skipped skipped (another host's code)[expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
