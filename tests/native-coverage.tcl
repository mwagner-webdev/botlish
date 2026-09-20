# native-coverage.tcl -- runs the whole test suite on the Cranelift backend
# and classifies every test.
#
#   tclsh9.0 tests/native-coverage.tcl [-verbose]
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

set log [file join [pwd] native-coverage.log]
file delete $log
set env(CORE_BACKEND) cranelift
set env(NATIVE_COVERAGE) $log
catch {exec [info nameofexecutable] [file join $testDir all.tcl] 2>@1} output
unset env(NATIVE_COVERAGE)

set channel [open $log r]
fconfigure $channel -encoding utf-8
set records [split [string trimright [read $channel] \n] \n]
close $channel
file delete $log

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

puts "Cranelift backend coverage of the test suite ([llength $records] tests)"
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
    puts [string range $output 0 20000]
}
if {$verbose} {
    puts ""
    puts [join $lines \n]
}
exit [expr {[dict get $counts failed] > 0}]
