# native-coverage.tcl -- runs the whole test suite on a Cranelift backend
# and classifies every test.
#
#   tclsh9.0 tests/native-coverage.tcl [-verbose] [-backend cranelift|cranelift-generic]
#                                      [-log FILE]
#
# -backend is the suite's CORE_BACKEND (default cranelift, specialized;
# cranelift-generic compiles every function once, -specialize 0). -log FILE
# classifies the coverage log of a run made elsewhere (NATIVE_COVERAGE=FILE,
# tests/helpers.tcl: for instance a parallel run of every test file with
# CORE_BACKEND set) instead of running the suite.
#
# Every test is exactly one of:
#
#   native          passed, and ran native code
#   independent     passed without running any program on the backend
#                   (frontend, HIR and analysis tests)
#   passed-partial  passed, although some program in it needs an unsupported
#                   construct (the test compares an error or other backends)
#   unsupported     failed, and needed a construct the native backend does
#                   not support (reported as {NATIVE UNSUPPORTED ...})
#   failed          failed for any other reason: a native backend bug
#
# Unsupported tests are grouped by what they needed. -verbose lists every
# test's class. Exits with status 1 if any test is in class failed.

set testDir [file dirname [file normalize [info script]]]
set verbose [expr {"-verbose" in $argv}]
set backend cranelift
set given ""
foreach {option value} [lsearch -all -inline -not -exact $argv -verbose] {
    switch -- $option {
        -backend {
            if {$value ni {cranelift cranelift-generic}} {
                error "native-coverage.tcl: -backend is cranelift or cranelift-generic"
            }
            set backend $value
        }
        -log { set given $value }
        default { error "native-coverage.tcl: unknown option $option" }
    }
}

set output ""
if {$given ne ""} {
    set log $given
} else {
    # The coverage log and the suite's tcltest temporary files live in a
    # fresh system temporary directory, removed when the run ends (never in
    # the working directory, which concurrent runs share).
    set scratch [file tempdir native-coverage]
    set log [file join $scratch native-coverage.log]
    set env(CORE_BACKEND) $backend
    set env(NATIVE_COVERAGE) $log
    catch {exec [info nameofexecutable] [file join $testDir all.tcl] -tmpdir [file join $scratch tmp] 2>@1} output
    unset env(NATIVE_COVERAGE)
}

set channel [open $log r]
fconfigure $channel -encoding utf-8
set records [split [string trimright [read $channel] \n] \n]
close $channel
if {$given eq ""} {
    file delete -force $scratch
}

set counts [dict create native 0 independent 0 passed-partial 0 unsupported 0 failed 0]
set needs [dict create]
set lines {}
foreach record $records {
    lassign $record name passed runs unsupported
    set whats [lsort -unique [lmap entry $unsupported {lrange [lindex $entry 0] 2 end}]]
    if {$passed} {
        set class [expr {$unsupported ne "" ? "passed-partial" : ($runs > 0 ? "native" : "independent")}]
    } else {
        set class [expr {$unsupported ne "" ? "unsupported" : "failed"}]
    }
    dict incr counts $class
    if {$class eq "unsupported"} {
        foreach what $whats {
            dict lappend needs $what $name
        }
    }
    lappend lines [format "  %-16s %-40s %s" $class $name [join $whats {, }]]
}

puts "$backend backend coverage of the test suite ([llength $records] tests)"
puts ""
dict for {class count} $counts {
    puts [format "  %-16s %4d" $class $count]
}
puts ""
puts "Unsupported tests by needed construct (a test may need several):"
dict for {what names} $needs {
    puts [format "  %-40s %3d  %s" $what [llength $names] [join $names { }]]
}
if {[dict get $counts failed]} {
    puts ""
    puts "FAILED (native backend bugs):"
    foreach line $lines {
        if {[string match "  failed *" $line]} {
            puts $line
        }
    }
    puts ""
    # Each failed test's own report from the suite's output (tcltest's
    # "==== NAME ..." to "==== NAME FAILED"), never the output's first
    # characters: the unsupported tests' reports come first in it, and a cut
    # at 20,000 characters hid the one failure that mattered (vt-large on
    # main at 023dfaa3; MAIN-CI-FAILURES-2026-11-13.md). A failed test with
    # no report (its file's process died) is named, with the output's end.
    set unreported {}
    foreach line $lines {
        if {![string match "  failed *" $line]} continue
        set name [lindex $line 1]
        set start [string first "==== $name " $output]
        set end [string first "==== $name FAILED" $output $start]
        if {$start < 0 || $end < 0} {
            lappend unreported $name
            continue
        }
        set report [string range $output $start [expr {$end + [string length "==== $name FAILED"] - 1}]]
        if {[string length $report] > 12000} {
            set report "[string range $report 0 5999]\n... ([string length $report] characters; the middle left out) ...\n[string range $report end-5999 end]"
        }
        puts $report
        puts ""
    }
    if {$unreported ne ""} {
        puts "No report in the suite's output for: [join $unreported {, }]; its last 6,000 characters:"
        puts [string range $output end-5999 end]
    }
}
if {$verbose} {
    puts ""
    puts [join $lines \n]
}
exit [expr {[dict get $counts failed] > 0}]
