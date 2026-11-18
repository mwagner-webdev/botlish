# mutate.tcl -- mutation testing of resumable coroutines and the ShadowOnly
# root plan (WASM-RESUMABLE-COROUTINES-SHADOW-ROOTS-MILESTONE-1.md:
# native/src/codegen/resumable.rs, runtime/resumable.rs, the frame's
# tracing in runtime/heap.rs, runtime/coroutine.rs, the frame operations in
# codegen/clif.rs, codegen/roots.rs).
#
#   tclsh9.0 audit/resumable-coroutines/tools/mutate.tcl ?-only NAME,...?
#                                                         ?-seed-target DIR?
#                                                         ?-timeout SECONDS?
#                                                         ?-tcl 0|1|survivors?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. A private copy of the compiler, library, tests and native backend (a
# temporary directory) gets each mutant's replacements in turn, and the
# detectors run against it:
#
#   * a release build of the copy's native backend with the
#     `fallback-roots` feature -- the ShadowOnly, resumable runtime (a mutant
#     that does not build is reported NOT-BUILT, never counted as killed),
#     then its Rust tests of the frame, the segment protocol, the root plan
#     and the capabilities (`cargo test --release --features fallback-roots
#     --lib --bins -- resumable fallback_tests roots capabilities`);
#   * the corpus (tests/resumable, tests/resources/coro.bot): each program's
#     NIR -- emitted once, before any mutant, since no mutant edits the
#     front end -- run by the mutant driver with fusion off (every coroutine
#     on the general mechanism), plainly and under GC stress (the precision
#     probe plainly only: quadratic), its value compared with its `# expect:`
#     line; the leaf re-entry regression five times under GC stress; and the
#     allocation evidence of tests/resumable-coroutines.test -- frames per
#     resume, the recognizer's tail recursion, reclamation, precision;
#   * tests/resumable-coroutines.test against the mutant driver
#     (BOTLISH_NATIVE_BIN): with `-tcl survivors` (the default) only for a
#     mutant the first two missed, with 1 for every mutant, 0 never.
#
# A mutant every detector misses SURVIVES; the report lists each mutant,
# what killed it and the survivors. The real checkout, including its
# native/target, is never modified. -seed-target names a `fallback-roots`
# target directory to copy as the private build's starting point (default:
# the checkout's native/target-fallback when it exists, as CI's lane builds
# it; else the first build starts from scratch).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set here [file dirname [file normalize [info script]]]

set options [dict create -only "" -seed-target "" -timeout 1800 -tcl survivors]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
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

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
proc readMutants {path} {
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

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description edits} [readMutants [file join $here mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $edits
}

# The private tree: compiler sources, library, tests, the audit directory,
# the native backend's sources and a target directory of its own.
set tree [file tempdir botlish-resumable-mutants]
foreach dir {compiler core hir surface stdlib tests examples compilerpedia audit/resumable-coroutines .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[string match target* [file tail $entry]]} continue
    file copy $entry [file join $tree native]
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}
set target [file join $tree native target]
set seed [dict get $options -seed-target]
if {$seed eq "" && [file isdirectory [file join $root native target-fallback]]} {
    set seed [file join $root native target-fallback]
}
if {$seed ne ""} {
    # Copy the directory, following links (AGENTS.md, "Running tests
    # concurrently"): a copied link would build every mutant into another
    # checkout's target.
    while {[file type $seed] eq "link"} {
        set seed [file join [file dirname $seed] [file readlink $seed]]
    }
    exec cp -a $seed $target
}
set manifest [file join $tree native Cargo.toml]
set driver [file join $target release botlish-native]
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8

# The corpus, emitted to NIR once (the front end is never mutated), with
# each program's expected value.
set scratch [file tempdir botlish-resumable-mutants-nir]
set corpus {}
foreach path [lsort [glob -directory [file join $tree tests resumable] *.bot]] {
    set name [file rootname [file tail $path]]
    if {$name eq "res"} continue
    if {![regexp -line {^# expect: (.*)$} [readFile $path] -> expect]} continue
    dict set corpus $name [list $path $expect]
}
dict set corpus coro [list [file join $tree tests resources coro.bot] {[101, 102, 100, 111, 119, 110, 300, 401, 400, 500, 599, 600, 601]}]
# The emitting run also runs each program on the seed driver: its value
# must be the program's `# expect:` line, so a program that failed to emit
# (an empty or truncated NIR file) stops the run here instead of becoming a
# reference every mutant trivially agrees with.
dict for {name entry} $corpus {
    lassign $entry path expect
    lassign [run 900 tclsh9.0 [file join $tree main.tcl] -warnings off -backend cranelift -emit-nir $path] status output
    set lines {}
    set inside 0
    set value ""
    foreach line [split $output \n] {
        if {[string match "nir *" $line]} { set inside 1 }
        if {[regexp {^   value: (.*)$} $line -> value]} { set inside 0 }
        if {$inside && ![string match "==*" $line]} { lappend lines $line }
    }
    if {$value ne $expect} {
        error "emitting $name: value \"$value\", expected \"$expect\" (status $status: [lastLine $output])"
    }
    writeFile [file join $scratch $name.nir] [join $lines \n]\n
}

# The value line of DRIVER's run of NIR under ENV (a list of NAME VALUE).
proc runNir {timeout driver nir env args} {
    set saved {}
    foreach {k v} $env {
        dict set saved $k [expr {[info exists ::env($k)] ? [list $::env($k)] : {}}]
        set ::env($k) $v
    }
    try {
        lassign [run $timeout $driver run {*}$args $nir] status output
    } finally {
        dict for {k v} $saved {
            if {$v eq {}} { unset ::env($k) } else { set ::env($k) [lindex $v 0] }
        }
    }
    return [list $status $output]
}

# The configurations the corpus detector runs: {NAME STRESS} for every
# program, under GC stress too except where a collection at every
# allocation is quadratic or needlessly slow.
proc corpusRuns {corpus} {
    set runs {}
    dict for {name entry} $corpus {
        foreach stress {0 1} {
            if {$stress && $name in {precision dfa-tail generator loop-calls}} continue
            lappend runs $name $stress
        }
    }
    return $runs
}

# The value line of DRIVER's run of NAME (fusion off) with GC stress STRESS.
proc corpusValue {driver scratch name stress timeout} {
    lassign [runNir $timeout $driver [file join $scratch $name.nir] [list BOTLISH_NATIVE_COROUTINE_FUSION 0 BOTLISH_NATIVE_GC_STRESS $stress]] status output
    set line [lsearch -inline [split $output \n] {value *}]
    return [expr {$status == 0 && $line ne "" ? $line : "status $status: [string range [string trim $output] 0 160]"}]
}

# The corpus detector: a list of failures (empty: survived). REFERENCE holds
# the unmutated build's value line for every run, which equals each
# program's `# expect:` value (tests/resumable-coroutines.test checks that).
proc corpusDetector {driver scratch corpus reference timeout} {
    set failures {}
    foreach {name stress} [corpusRuns $corpus] {
        set got [corpusValue $driver $scratch $name $stress $timeout]
        if {$got ne [dict get $reference "$name $stress"]} {
            lappend failures "$name stress=$stress: [string range $got 0 160]"
        }
    }
    # Leaf re-entry: five runs under GC stress.
    foreach i {1 2 3 4 5} {
        lassign [runNir $timeout $driver [file join $scratch leaf-reentry.nir] {BOTLISH_NATIVE_GC_STRESS 1}] status output
        if {$status != 0 || ![string match "value {int 340}*" [string trim $output]]} {
            lappend failures "leaf-reentry run $i: [string range [string trim $output] 0 120]"
            break
        }
    }
    # The allocation evidence (tests/resumable-coroutines.test's).
    set evidence {
        generator {ResumeFrame allocations} {== 2}
        dfa-tail {ResumeFrame allocations} {< 16}
        loop-calls {ResumeFrame allocations} {< 16}
        tail-calls {ResumeFrame allocations} {< 16}
        many {ResumeFrame allocations} {== 20000}
        reclaim {ResumeFrame currentLiveObjects} {== 0}
        precision {String currentLiveObjects} {< 50000}
    }
    foreach {name keys check} $evidence {
        lassign [runNir $timeout $driver [file join $scratch $name.nir] {BOTLISH_NATIVE_COROUTINE_FUSION 0} --alloc summary] status output
        set line [lsearch -inline [split $output \n] {alloc *}]
        set report [lrange $line 1 end]
        lassign $keys kind key
        if {$status != 0 || ![dict exists $report byKind $kind $key]} {
            lappend failures "$name evidence: [lastLine $output]"
            continue
        }
        set n [dict get $report byKind $kind $key]
        if {![expr "$n $check"]} {
            lappend failures "$name evidence: $kind $key $n, expected $check"
        }
    }
    return $failures
}

set results {}
try {
    # The unmutated build, and its value for every corpus run.
    set cwd [pwd]
    cd $tree
    lassign [run [dict get $options -timeout] cargo build --release --features fallback-roots --manifest-path $manifest --target-dir $target] status output
    cd $cwd
    if {$status != 0} {
        error "the unmutated copy does not build: [lastLine $output]"
    }
    set reference [dict create]
    foreach {name stress} [corpusRuns $corpus] {
        set got [corpusValue $driver $scratch $name $stress [dict get $options -timeout]]
        if {![string match "value *" $got]} {
            error "the unmutated build's run of $name (stress $stress) has no value: $got"
        }
        dict set reference "$name $stress" $got
    }
    set baseline [corpusDetector $driver $scratch $corpus $reference [dict get $options -timeout]]
    if {$baseline ne {}} {
        error "the unmutated build fails the corpus detector: [lindex $baseline 0]"
    }
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
            lappend results [list $name $description NOT-APPLIED "" "" ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched { writeFile [file join $tree $file] $text }
            continue
        }
        set cwd [pwd]
        cd $tree
        lassign [run [dict get $options -timeout] cargo build --release --features fallback-roots --manifest-path $manifest --target-dir $target] status output
        if {$status != 0} {
            cd $cwd
            lappend results [list $name $description NOT-BUILT "" "" ""]
            puts "NOT-BUILT $name: [lastLine $output]"
            dict for {file text} $touched { writeFile [file join $tree $file] $text }
            continue
        }
        lassign [run [dict get $options -timeout] cargo test --release --features fallback-roots --manifest-path $manifest --target-dir $target --lib --bins -- resumable fallback_tests roots capabilities] status output
        cd $cwd
        if {$status != 0} {
            set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
            set rust "killed ([expr {$failing eq {} ? [lastLine $output] : [join $failing {, }]}])"
        } else {
            set rust survived
        }
        set failures [corpusDetector $driver $scratch $corpus $reference [dict get $options -timeout]]
        set corpusVerdict [expr {$failures eq {} ? "survived" : "killed ([llength $failures]: [lindex $failures 0])"}]
        set tcl "not run"
        set tclMode [dict get $options -tcl]
        if {$tclMode eq "1" || ($tclMode eq "survivors" && $rust eq "survived" && $corpusVerdict eq "survived")} {
            set tmp [file tempdir botlish-resumable-mutant-run]
            set ::env(BOTLISH_NATIVE_BIN) $driver
            lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree tests resumable-coroutines.test] -tmpdir $tmp] status output
            unset ::env(BOTLISH_NATIVE_BIN)
            file delete -force $tmp
            set failedTests [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
            if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
                set tcl "killed (did not complete: [lastLine $output])"
            } elseif {$failedTests ne {}} {
                set tcl "killed ([join $failedTests {, }])"
            } else {
                set tcl survived
            }
        }
        set verdict [expr {[string match killed* $rust] || [string match killed* $corpusVerdict] || [string match killed* $tcl] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $rust $corpusVerdict $tcl]
        puts "$verdict $name -- $description\n    rust:   $rust\n    corpus: $corpusVerdict\n    tcl:    $tcl"
        flush stdout
        dict for {file text} $touched { writeFile [file join $tree $file] $text }
    }
} finally {
    file delete -force $tree $scratch
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
