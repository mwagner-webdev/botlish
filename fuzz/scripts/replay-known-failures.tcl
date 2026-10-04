# replay-known-failures.tcl -- replay every packaged finding across the
# vertical matrix and report expected vs actual (campaign brief #46). This
# preserves the campaign's findings as executable evidence while fixes are
# deferred to the downstream milestone.
#
#   tclsh9.0 fuzz/scripts/replay-known-failures.tcl ?--selftest?
#
# A filed finding lives in fuzz/triage/FZ-NNN/ with:
#   input        the minimized reproducer (an argv-vector file)
#   target       the target name (one line)
#   expected.tsv lines "vertical<TAB>normalized-result<TAB>exit"
# The suite re-runs replay.tcl for each vertical and compares. It always
# exits 0: it is a report, not a gate (#47).
#
# --selftest packages a synthetic finding (a seed of the csv target that
# never was a bug) and verifies the replay machinery end to end -- the
# suite must stay demonstrably runnable even when the campaign files zero
# findings.
set root [file normalize [file join [file dirname [info script]] .. ..]]
set selftest [expr {[lindex $argv 0] eq "--selftest"}]

proc readText {path} {
    if {![file exists $path]} { return "" }
    set channel [open $path r]
    try { return [read $channel] } finally { close $channel }
}

# Runs one vertical via replay.tcl; returns the normalized "result|... exit|..."
proc replay {vertical target input} {
    variable root
    set cmd [list tclsh9.0 [file join $root fuzz scripts replay.tcl] \
        $vertical $target $input]
    if {[catch {exec -- {*}$cmd} output options]} {
        # replay.tcl exits 0 on success; treat any failure as the answer
        set output [dict get $options -errorcode]
        if {[string match "CHILDSTATUS*" $output]} {
            set output "(replay failed: exit [lindex $output 2])"
        }
    }
    return [string map {\n " "} [string trim $output]]
}

if {$selftest} {
    # A synthetic finding: csv's own three-args seed, expected clean on all
    # five verticals. It exercises packaging + replay + comparison.
    set dir [file join $root fuzz triage SELFTEST]
    file mkdir $dir
    file copy -force [file join $root fuzz seeds csv three-args] [file join $dir input]
    set channel [open [file join $dir target] w]; puts $channel csv; close $channel
    set channel [open [file join $dir expected.tsv] w]
    foreach vertical {aot interp compile cranelift cranelift-generic} {
        puts $channel "$vertical\tresult|value|\[\[\"name\", \"age\"\], \[\"Alice\", \"30\"\], \[\"Bob\", \"40\"\]\] exit|0"
    }
    close $channel
    puts "selftest: packaged a synthetic finding under $dir"
}

set packages {}
foreach dir [lsort [glob -nocomplain -directory [file join $root fuzz triage] FZ-*]] {
    if {[file exists [file join $dir input]]} { lappend packages $dir }
}
if {$selftest} { lappend packages [file join $root fuzz triage SELFTEST] }

if {[llength $packages] == 0} {
    puts "known-failures: no findings filed (fuzz/triage/FZ-*); nothing to replay."
    if {$selftest} { puts "known-failures: SELFTEST FAILED to appear" ; exit 1 }
    exit 0
}

set agreements 0
set drift 0
foreach packageDir $packages {
    set id [file tail $packageDir]
    set target [string trim [readText [file join $packageDir target]]]
    set input [file join $packageDir input]
    puts "== $id (target: $target)"
    foreach line [split [readText [file join $packageDir expected.tsv]] \n] {
        set line [string trimright $line]
        if {$line eq ""} { continue }
        lassign [split $line \t] vertical expected
        set actual [replay $vertical $target $input]
        set status ok
        if {$actual ne $expected} { set status DRIFT; incr drift } else { incr agreements }
        puts [format "  %-20s %-10s expected: %s" $vertical $status $expected]
        if {$status eq "DRIFT"} {
            puts [format "  %-20s %-10s actual:   %s" "" "" $actual]
        }
    }
}
puts "known-failures: $agreements verticals agree, $drift drifted (informational; exit 0)"
exit 0
