# process-linux.tcl -- the process_linux package's measurements
# (PROCESS-LINUX-PACKAGE-MILESTONE-1.md, "Measurements"): bench/process-
# linux/perf.bot compiled against the package's RELEASED adapter (no test
# probe), each scenario run as its own process with its peak resident set
# size and CPU time read by wait4 (python3), and -- with -census DIR, the
# census's lab-perf executable built by audit/managed-subprocess/tools/
# run.py --build -- the census's experimental module run beside it.
#
#   tclsh9.0 bench/process-linux.tcl ?-runs 3? ?-census audit/managed-subprocess/slice?
#
# Prints a Markdown table of means over the runs (sums divided here).
set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
set options [dict create -runs 3 -census ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tools process-linux.tcl]
interp recursionlimit {} 100000

set dir [file tempdir botlish-process-bench]
processLinux::app $dir 0
file copy [file join $root tests process kit.bot] $dir
file copy [file join $root bench process-linux perf.bot] $dir
set helper [processLinux::helper [file join $dir child]]
set hir [surface::readProgramFile [file join $dir perf.bot] -warnings off -cache ""]
set exe [native::executable $hir [file join $dir perf]]

# Run COMMAND: {OUTPUT MAXRSS_KB CPU_S}.
proc measured {args} {
    set script {
import os, subprocess, sys
p = subprocess.Popen(sys.argv[1:], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
out = p.stdout.read()
_, status, ru = os.wait4(p.pid, 0)
sys.stdout.write(out.decode("utf-8", "replace"))
print(f"bench-maxrss-kb {ru.ru_maxrss}")
print(f"bench-cpu-us {int((ru.ru_utime + ru.ru_stime) * 1e6)}")
print(f"bench-status {os.waitstatus_to_exitcode(status)}")
}
    exec timeout -k 5 300 python3 -I -c $script {*}$args
}

proc field {out name} {
    if {[regexp -line "^$name (-?\\d+)\$" $out -> v]} { return $v }
    return ""
}

set runs [dict get $options -runs]
set census [dict get $options -census]
set censusExe [expr {$census ne "" ? [file join $census lab-perf] : ""}]
set censusHelper [expr {$census ne "" ? [file join $census bin msp-child] : ""}]

array set sum {}
proc add {key value} {
    if {$value eq ""} return
    global sum
    if {![info exists sum($key)]} { set sum($key) 0 }
    set sum($key) [expr {$sum($key) + $value}]
}
proc addMax {key value} {
    if {$value eq ""} return
    global sum
    if {![info exists sum($key)] || $value > $sum($key)} { set sum($key) $value }
}

for {set r 0} {$r < $runs} {incr r} {
    set out [measured $exe $helper latency 4]
    add spawn-us [expr {[field $out spawn-us-sum] / 200.0}]
    addMax spawn-us-max [field $out spawn-us-max]
    add exit-us [expr {[field $out exit-observed-us-sum] / 200.0}]
    addMax exit-us-max [field $out exit-observed-us-max]
    add cycle-us [expr {[field $out cycle-us-sum] / 200.0}]
    set out [measured $exe $helper throughput 4]
    add tp-ms [expr {[field $out elapsed-us] / 1000.0}]
    add tp-cpu-ms [expr {[field $out supervisor-cpu-us] / 1000.0}]
    add tp-chunks [field $out chunks]
    add tp-late-ms [expr {[field $out max-tick-late-us] / 1000.0}]
    add tp-rss [expr {[field $out bench-maxrss-kb] / 1024.0}]
    set out [measured $exe $helper memory 4]
    add mem-ms [expr {[field $out elapsed-us] / 1000.0}]
    add mem-rss [expr {[field $out bench-maxrss-kb] / 1024.0}]
    set out [measured $exe $helper nothing 4]
    add idle-rss [expr {[field $out bench-maxrss-kb] / 1024.0}]
    set out [measured $exe $helper idle 4]
    add idle-cpu-us [field $out supervisor-cpu-us]
    add idle-turns [field $out turns]
    set out [measured $exe $helper poll 4]
    add poll-cpu-us [field $out supervisor-cpu-us]
    add poll-turns [field $out turns]
    set out [measured $exe $helper flood 4]
    add flood-ticks [field $out ticks]
    addMax flood-late-ms [expr {[field $out max-tick-late-us] / 1000.0}]
    add flood-mib [expr {[field $out bytes] / 1048576.0}]
    set out [measured $exe $helper flood 1000000000]
    add noyield-ticks [field $out ticks]
    addMax noyield-late-ms [expr {[field $out max-tick-late-us] / 1000.0}]
    set out [measured $exe $helper terminate 4]
    add graceful-ms [expr {[field $out graceful-us-sum] / 20000.0}]
    add forced-ms [expr {[field $out forced-us-sum] / 20000.0}]
    set out [measured $exe $helper many 4]
    add seq-ms [expr {[field $out sequential-400-us] / 1000.0}]
    add conc-ms [expr {[field $out concurrent-64-us] / 1000.0}]
    foreach k {owned watches children descriptors {registrations delta}} {
        addMax "end $k" [field $out "end $k"]
    }
    if {$censusExe ne "" && [file executable $censusExe]} {
        set tmp [file tempdir botlish-process-bench-census]
        set out [measured $censusExe $censusHelper latency $tmp]
        add c-spawn-us [expr {[field $out spawn-us-sum] / 200.0}]
        add c-exit-us [expr {[field $out exit-observed-us-sum] / 200.0}]
        add c-cycle-us [expr {[field $out round-trip-us-sum] / 200.0}]
        set out [measured $censusExe $censusHelper throughput $tmp]
        add c-tp-ms [expr {[field $out elapsed-us] / 1000.0}]
        add c-tp-cpu-ms [expr {[field $out supervisor-cpu-us] / 1000.0}]
        add c-tp-late-ms [expr {[field $out max-tick-late-us] / 1000.0}]
        add c-tp-rss [expr {[field $out bench-maxrss-kb] / 1024.0}]
        set out [measured $censusExe $censusHelper idle $tmp]
        add c-idle-cpu-us [field $out supervisor-cpu-us]
        set out [measured $censusExe $censusHelper poll $tmp]
        add c-poll-cpu-us [field $out supervisor-cpu-us]
        set out [measured $censusExe $censusHelper flood $tmp]
        add c-flood-ticks [field $out ticks]
        addMax c-flood-late-ms [expr {[field $out max-tick-late-us] / 1000.0}]
        file delete -force $tmp
    }
}

proc mean {key} {
    global sum runs
    if {![info exists sum($key)]} { return "--" }
    if {[string match *-max $key] || [string match *late-ms $key] && [string match {*flood*} $key] || [string match "end *" $key]} {
        return [format %.6g $sum($key)]
    }
    return [format %.4g [expr {$sum($key) / double($runs)}]]
}

puts "| Measure | process_linux 0.1.0 | census experiment |"
puts "|---|---:|---:|"
foreach {label key ckey} {
    "spawn call, mean (us)" spawn-us c-spawn-us
    "spawn call, max (us)" spawn-us-max ""
    "exit notification, mean (us)" exit-us c-exit-us
    "exit notification, max (us)" exit-us-max ""
    "spawn, read to end, wait, release (us)" cycle-us c-cycle-us
    "64 MiB of stdout (ms)" tp-ms c-tp-ms
    "64 MiB: supervisor CPU (ms)" tp-cpu-ms c-tp-cpu-ms
    "64 MiB: 64 KiB chunks read" tp-chunks ""
    "64 MiB: 5 ms ticker, worst lateness (ms)" tp-late-ms c-tp-late-ms
    "64 MiB: peak RSS (MiB)" tp-rss c-tp-rss
    "1 GiB of stdout (ms)" mem-ms ""
    "1 GiB: peak RSS (MiB)" mem-rss ""
    "no child at all: peak RSS (MiB)" idle-rss ""
    "two idle children, 2 s: CPU (us)" idle-cpu-us c-idle-cpu-us
    "two idle children, 2 s: loop turns" idle-turns ""
    "polling control (exited? every 1 ms): CPU (us)" poll-cpu-us c-poll-cpu-us
    "polling control: loop turns" poll-turns ""
    "flood 1 s, 10 ms ticker: ticks" flood-ticks c-flood-ticks
    "flood: worst tick lateness (ms)" flood-late-ms c-flood-late-ms
    "flood: MiB read in the second" flood-mib ""
    "flood, yielding off (control): ticks" noyield-ticks ""
    "flood, yielding off: worst tick lateness (ms)" noyield-late-ms ""
    "terminate, graceful (child takes 150 ms) (ms)" graceful-ms ""
    "terminate, forced (300 ms grace) (ms)" forced-ms ""
    "400 sequential spawn-wait-release (ms)" seq-ms ""
    "64 concurrent children (ms)" conc-ms ""
    "after completion: owned, watches, children, descriptors" "end owned" ""
} {
    set v [mean $key]
    if {$key eq "end owned"} {
        set v "[mean {end owned}], [mean {end watches}], [mean {end children}], [mean {end descriptors}] (registrations delta [mean {end registrations delta}])"
    }
    puts "| $label | $v | [expr {$ckey eq "" ? "" : [mean $ckey]}] |"
}
file delete -force $dir
