# mutate.tcl -- mutation evidence for the production event loop
# (EVENT-LOOP-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/event-loop/tools/mutate.tcl ?-only PATTERNS? ?-jobs N?
#       ?-timeout S? ?-quick-timeout S? ?-backend B? ?-native 0|1?
#       ?-baseline 0|1?
#
# For every mutant of mutants.txt beside this script (or those whose name
# matches one of PATTERNS, glob patterns): a private copy of the checkout's
# sources, library, tests, packages and tools (native/target linked: no
# mutant edits the native backend), the mutant applied to it, and the
# detectors, in two stages, until one kills it:
#
#   1. the tests its %% line names (tcltest -match patterns): the el-linux-*
#      ones of tests/event-loop-linux.test, the others of
#      tests/event-loop.test, each file within -quick-timeout seconds
#      (default 600);
#   2. when those do not kill it, the two files whole, within -timeout
#      seconds each (default 1500): tests/event-loop.test on CORE_BACKEND B
#      (default cranelift: its one backend) -- skipped for a mutant of the
#      Linux package or its C adapter, which no deterministic scenario
#      loads -- then tests/event-loop-linux.test (unless -native 0), which
#      builds the mutant's C adapter.
#
# A mutant is killed when a test fails or a file does not complete. Every
# mutant must still apply (its text occurs exactly once) and be killed; the
# unmutated tree must pass both files whole first, so a kill means the
# mutation. -jobs (default 3) mutants run at a time: the native file
# measures latencies, so keep it low on a loaded machine (a timing bound
# missed under load is a kill that proves nothing -- rerun a mutant killed
# only by el-linux-wake, -idle, -flood or -quiet-source alone).
#
# Prints one line per mutant as soon as it is decided: killed (the detector
# and its failing tests), SURVIVED or NOT APPLIED. A run stopped part way
# keeps the lines it printed; -only the rest with -baseline 0 resumes it. Exit status 1 if any survived, did not apply, or
# the baseline failed. Scratch state lives in `file tempdir` directories
# (AGENTS.md); the real checkout is never modified.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root audit golden tools tree.tcl]

set options [dict create -only {} -jobs 3 -timeout 1500 -quick-timeout 600 -backend cranelift -native 1 -baseline 1 -worker {}]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} {
        puts stderr "unknown option $arg"
        exit 2
    }
    dict set options $arg [lindex $argv [incr i]]
}

set mutantsFile [file join $here mutants.txt]

# A private tree: what the two test files read. native/target is linked to
# the checkout's (following a link, AGENTS.md "Running tests concurrently"):
# no mutant rebuilds the native backend.
proc makeTree {} {
    set tree [file tempdir botlish-event-loop-mutant]
    foreach dir {compiler core hir surface service lsp compilerpedia stdlib tests packages tools} {
        if {[file exists [file join $::root $dir]]} {
            file copy [file join $::root $dir] [file join $tree $dir]
        }
    }
    file mkdir [file join $tree native]
    foreach entry [glob -directory [file join $::root native] *] {
        if {[file tail $entry] ne "target"} {
            file copy $entry [file join $tree native]
        } else {
            while {[file type $entry] eq "link"} {
                set entry [file join [file dirname $entry] [file readlink $entry]]
            }
            file link -symbolic [file join $tree native target] $entry
        }
    }
    foreach entry [glob -directory $::root -types f *.tcl] {
        file copy $entry $tree
    }
    return $tree
}

# Whether EDITS touch only the Linux package (no deterministic scenario
# loads it).
proc packageOnly {edits} {
    foreach {file old new} $edits {
        if {![string match packages/event_loop_linux/* $file]} {
            return 0
        }
    }
    return 1
}

# The test patterns of mutant NAME's %% line.
proc targets {name} {
    set lines [split [goldentools::readFile $::mutantsFile] \n]
    set at [lsearch -regexp $lines "^@@ [string map {- \\-} $name] "]
    set line [lindex $lines [expr {$at + 1}]]
    if {$at < 0 || ![string match "%% *" $line]} {
        error "mutant $name has no %% line"
    }
    return [string range $line 3 end]
}

# Runs DETECTORS (a list of {FILE MATCH TIMEOUT}, MATCH "" for the whole
# file) in TREE in order: "" when all pass, else why the first failed.
proc detect {tree detectors} {
    foreach detector $detectors {
        lassign $detector file match timeout
        lassign [goldentools::runTestFile $tree $file $timeout $match] failed passed incomplete
        if {$incomplete ne ""} {
            return "[file tail $file]: did not complete: $incomplete"
        }
        if {[llength $failed] > 0} {
            return "[file tail $file]: [join $failed {, }]"
        }
    }
    return ""
}

# The worker: one mutant (or the baseline) in its own tree. Prints
# "RESULT killed|survived|not-applied|baseline-ok|baseline-failed DETAIL".
proc worker {name} {
    set edits {}
    if {$name ne "baseline"} {
        lassign [goldentools::mutant $::mutantsFile $name] description edits
    }
    set tree [makeTree]
    try {
        lassign [goldentools::apply $tree $edits] applied file
        if {!$applied} {
            puts "RESULT not-applied $file"
            return
        }
        set ::env(CORE_BACKEND) [dict get $::options -backend]
        set native [dict get $::options -native]
        if {$name ne "baseline"} {
            # Stage 1: the mutant's own tests.
            set deterministic {}
            set linux {}
            foreach pattern [targets $name] {
                if {[string match el-linux-* $pattern]} {
                    lappend linux $pattern
                } else {
                    lappend deterministic $pattern
                }
            }
            set quick {}
            if {$deterministic ne {}} {
                lappend quick [list tests/event-loop.test $deterministic [dict get $::options -quick-timeout]]
            }
            if {$linux ne {} && $native} {
                lappend quick [list tests/event-loop-linux.test $linux [dict get $::options -quick-timeout]]
            }
            set why [detect $tree $quick]
            if {$why ne ""} {
                puts "RESULT killed $why"
                return
            }
        }
        # Stage 2 (and the baseline): both files whole.
        set whole {}
        if {$name eq "baseline" || ![packageOnly $edits]} {
            lappend whole [list tests/event-loop.test "" [dict get $::options -timeout]]
        }
        if {$native} {
            lappend whole [list tests/event-loop-linux.test "" [dict get $::options -timeout]]
        }
        set why [detect $tree $whole]
        if {$name eq "baseline"} {
            puts [expr {$why eq "" ? "RESULT baseline-ok" : "RESULT baseline-failed $why"}]
        } elseif {$why ne ""} {
            puts "RESULT killed (whole files) $why"
        } else {
            puts "RESULT survived"
        }
    } finally {
        file delete -force $tree
    }
}

if {[dict get $options -worker] ne ""} {
    worker [dict get $options -worker]
    exit 0
}

set names {}
foreach {name description edits} [goldentools::readMutants $mutantsFile] {
    set only [dict get $options -only]
    if {$only ne {} && ![llength [lmap p $only {expr {[string match $p $name] ? 1 : [continue]}}]]} continue
    lappend names $name
}
set common [list -backend [dict get $options -backend] -native [dict get $options -native] -timeout [dict get $options -timeout] \
    -quick-timeout [dict get $options -quick-timeout]]
# The worker's own timeouts cover its detectors in turn.
set workerTimeout [expr {2 * [dict get $options -quick-timeout] + 2 * [dict get $options -timeout] + 600}]

set exit 0
set killed 0

# Prints NAME's verdict from its worker's OUTPUT (as soon as it ends, so a
# stopped run keeps what it found: rerun the rest with -only).
proc verdict {name status output seconds} {
    global exit killed
    set line [lindex [regexp -all -inline -line {^RESULT .*$} $output] end]
    set verdict [lindex $line 1]
    set detail [string range $line [string length "RESULT $verdict "] end]
    switch -- $verdict {
        baseline-ok {
            puts [format "%-32s passes every detector (%d s)" baseline $seconds]
        }
        baseline-failed {
            puts "baseline: FAILED $detail -- the unmutated tree must pass"
            set exit 1
        }
        killed {
            incr killed
            puts [format "%-32s killed by %s (%d s)" $name $detail $seconds]
        }
        survived {
            puts [format "%-32s SURVIVED" $name]
            set exit 1
        }
        not-applied {
            puts [format "%-32s NOT APPLIED (its text does not occur exactly once in %s)" $name $detail]
            set exit 1
        }
        default {
            puts [format "%-32s NO RESULT (status %s): %s" $name $status [goldentools::lastLine $output]]
            set exit 1
        }
    }
    flush stdout
}

# At most -jobs workers at a time, each reported when it ends.
set pending $names
if {[dict get $options -baseline]} {
    set pending [linsert $pending 0 baseline]
}
set running 0
proc launch {} {
    global pending running common workerTimeout options
    while {$running < [dict get $options -jobs] && [llength $pending] > 0} {
        set name [lindex $pending 0]
        set pending [lrange $pending 1 end]
        set channel [open |[list timeout $workerTimeout [info nameofexecutable] [info script] {*}$common -worker $name 2>@1] r]
        fconfigure $channel -blocking 0 -encoding utf-8
        set ::output($channel) ""
        set ::started($channel) [clock seconds]
        fileevent $channel readable [list collect $channel $name]
        incr running
    }
    if {$running == 0} {
        set ::done 1
    }
}

proc collect {channel name} {
    global running
    append ::output($channel) [read $channel]
    if {![eof $channel]} return
    fconfigure $channel -blocking 1
    set status 0
    if {[catch {close $channel} message options]} {
        set status [lindex [dict get $options -errorcode] end]
    }
    verdict $name $status $::output($channel) [expr {[clock seconds] - $::started($channel)}]
    unset ::output($channel) ::started($channel)
    incr running -1
    launch
}

launch
vwait ::done
puts "$killed of [llength $names] mutants killed"
exit $exit
