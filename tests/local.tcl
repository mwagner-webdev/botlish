# local.tcl -- the local test run (AGENTS.md, "Running the tests locally"):
# the Tcl tests minus those a golden test duplicates, and the golden suites
# in their place, in parallel.
#
#   tclsh9.0 tests/local.tcl ?-jobs N? ?-backends LIST? ?-golden-backends LIST?
#                            ?-hir-cache DIR? ?-all 0|1? ?-parts LIST?
#                            ?-priority 0|1? ?-fail-fast 0|1? ?-verbose 0|1?
#                            ?FILE ...?
#
# Tcl tests: every tests/*.test file once per backend of -backends (default
# CORE_BACKEND if set, else interp,compile -- what tests/all.tcl runs), each
# in its own tclsh with a private -tmpdir, with BOTLISH_SKIP_GOLDEN_DUPLICATES=1:
# the tests the manifest classifies FROZEN-DUPLICATE-ORACLE, whose whole
# theorem a golden test carries, are skipped (tests/helpers.tcl). -all 1 runs
# every Tcl test, as CI does.
#
# Golden suites: every tests/golden/*.bot, one tests/golden/run.tcl process
# per suite on the backends of -golden-backends (default all four; a suite's
# recorded exclusions are skipped by the runner), through the front-end cache
# (HIR-INTERCHANGE.md): a suite whose text, modules and front end are unchanged
# since it was last compiled is read from its entry, not compiled again -- an
# edit to compiler/ or native/ only, which the cache key leaves out, reruns
# the whole golden corpus for the backends' cost alone. The cache is
# -hir-cache DIR ("" for none), else BOTLISH_HIR_CACHE when set, else this
# checkout's own directory under the user's cache directory
# ($XDG_CACHE_HOME, %LOCALAPPDATA% or ~/.cache, then botlish/hir/), from which
# the run then removes the entries another front end wrote (Prune), so it
# holds about one front end's entries. The Tcl tests never use the cache
# (tests/helpers.tcl unsets it).
#
# FILE arguments narrow the run: a test file (tests/X.test or X.test) runs
# that file, and a suite (X.bot) that suite. Given test files and no suite,
# the suites run are those holding the golden tests that replace the files'
# skipped tests, so the run covers what the files covered. -parts tcl or
# -parts golden runs one layer only.
#
# -jobs N processes at a time (default: the number of processors). The
# likeliest to fail start first (-priority 1, the default; CI-RUNS.md, "The
# canary"): the test files and golden suites this checkout changes against
# origin/main, its working tree included, then those that failed recently in
# CI on this host (tests/canary.tsv), as tests/canary.tcl selects them; then
# the golden suites and the largest files. -fail-fast 1 starts nothing more
# after the first failure (the running ones finish) and reports the rest as
# not run. Prints a line per finished process (-verbose 1 also prints each
# one's output), then every failure; exits 1 if any Tcl test or golden test
# failed, a file or suite did not complete or was not run, or a test file
# wrote to stderr (as tests/all.tcl counts it).

set testDir [file dirname [file normalize [info script]]]
set root [file dirname $testDir]

proc usage {} {
    puts stderr "usage: tclsh9.0 tests/local.tcl ?-jobs N? ?-backends LIST? ?-golden-backends LIST? ?-hir-cache DIR? ?-all 0|1? ?-parts LIST? ?-priority 0|1? ?-fail-fast 0|1? ?-verbose 0|1? ?FILE ...?"
    exit 2
}

proc processors {} {
    if {![catch {exec nproc} n] && [string is integer -strict $n]} { return $n }
    return 4
}

set options [dict create -jobs [processors] \
    -backends [expr {[info exists ::env(CORE_BACKEND)] && $::env(CORE_BACKEND) ne "" ? $::env(CORE_BACKEND) : "interp,compile"}] \
    -golden-backends interp,compile,cranelift-generic,cranelift -hir-cache default \
    -all 0 -parts tcl,golden -priority 1 -fail-fast 0 -verbose 0]
set arguments {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {[string match -* $arg]} {
        if {![dict exists $options $arg] || $i + 1 >= [llength $argv]} usage
        dict set options $arg [lindex $argv [incr i]]
    } else {
        lappend arguments $arg
    }
}
set listOf {apply {{value} {lsearch -all -inline -not -exact [split [string map {" " ,} $value] ,] ""}}}
set backends [{*}$listOf [dict get $options -backends]]
set goldenBackends [{*}$listOf [dict get $options -golden-backends]]
set parts [{*}$listOf [dict get $options -parts]]
set jobs [dict get $options -jobs]
set skipDuplicates [expr {![dict get $options -all]}]
set verbose [dict get $options -verbose]
set failFast [dict get $options -fail-fast]

# This checkout's own front-end cache directory, under the user's cache
# directory: "" when there is none to put it in.
proc defaultCacheDir {root} {
    foreach {variable under} {XDG_CACHE_HOME {} LOCALAPPDATA {} HOME .cache} {
        if {[info exists ::env($variable)] && $::env($variable) ne ""} {
            set base [file join $::env($variable) {*}$under]
            set bytes [encoding convertto utf-8 $root]
            return [file join $base botlish hir [format %s-%08x [file tail $root] [zlib crc32 $bytes]]]
        }
    }
    return ""
}
set hirCache [dict get $options -hir-cache]
set prune 0
if {$hirCache eq "default"} {
    if {[info exists ::env(BOTLISH_HIR_CACHE)] && $::env(BOTLISH_HIR_CACHE) ne ""} {
        set hirCache $::env(BOTLISH_HIR_CACHE)
    } else {
        set hirCache [defaultCacheDir $root]
        set prune [expr {$hirCache ne ""}]
    }
}
if {$hirCache ne ""} {
    set hirCache [file normalize $hirCache]
}

# Removes from the cache directory DIR the entries another front end wrote
# than the one in ROOT now (they hit again only if the front end returns to
# that exact text) and the private files of writes interrupted a day ago or
# more (surface/cache.tcl writes an entry under a private name, then renames
# it): the number removed.
proc Prune {dir root} {
    source [file join $root hir interchange.tcl]
    set current [hir::interchange::Fingerprint $root]
    set removed 0
    foreach path [glob -nocomplain -directory $dir -types f *] {
        if {[string match *.hirc $path]} {
            set f [open $path rb]
            set head [read $f 512]
            close $f
            if {[regexp {front-end (\S+)} $head -> fingerprint] && $fingerprint eq $current} continue
        } elseif {[file mtime $path] > [clock seconds] - 86400} {
            continue
        }
        if {![catch {file delete $path}]} {
            incr removed
        }
    }
    return $removed
}
foreach name {LANG LC_ALL} {
    if {![info exists ::env($name)] || $::env($name) eq ""} { set ::env($name) C.utf8 }
}

# ---------------------------------------------------------------------------
# What runs.

set testFiles {}
set suites {}
foreach arg $arguments {
    set tail [file tail $arg]
    if {[string match *.bot $tail]} {
        set path [file join $testDir golden $tail]
        if {![file exists $path]} { puts stderr "no golden suite $tail"; exit 2 }
        lappend suites $path
    } elseif {[string match *.test $tail]} {
        set path [file join $testDir $tail]
        if {![file exists $path]} { puts stderr "no test file $tail"; exit 2 }
        lappend testFiles $path
    } else {
        puts stderr "not a test file or golden suite: $arg"
        exit 2
    }
}
if {$arguments eq {}} {
    set testFiles [lsort [glob -directory $testDir *.test]]
    set suites [lsort [glob -directory [file join $testDir golden] *.bot]]
} elseif {$suites eq {} && $skipDuplicates} {
    # The suites holding the golden tests that replace the given files'
    # skipped tests (tests/helpers.tcl's GoldenDuplicates: the same rows).
    set channel [open [file join $testDir golden manifest.tsv] r]
    fconfigure $channel -encoding utf-8
    set header [split [gets $channel] \t]
    set rows [split [read $channel] \n]
    close $channel
    set columns {}
    foreach column {old_file old_test suite freeze} {
        lappend columns [lsearch -exact $header $column]
    }
    set wanted [lmap path $testFiles {file tail $path}]
    set suitesOf [dict create]
    set active [dict create]
    foreach line $rows {
        if {$line eq ""} continue
        set row [split $line \t]
        lassign [lmap c $columns {lindex $row $c}] file name suite freeze
        set file [file tail $file]
        if {$file ni $wanted} continue
        if {$freeze eq "FROZEN-DUPLICATE-ORACLE"} {
            dict lappend suitesOf [list $file $name] $suite
        } else {
            dict set active [list $file $name] 1
        }
    }
    set names {}
    dict for {key list} $suitesOf {
        if {![dict exists $active $key]} { lappend names {*}$list }
    }
    set suites [lmap suite [lsort -unique $names] {file join $testDir golden $suite}]
}
if {"tcl" ni $parts} { set testFiles {} }
if {"golden" ni $parts} { set suites {} }

# Item key -> {kind command environment label}, the golden suites and the
# largest files first.
set items [dict create]
foreach path [lsort -command {apply {{a b} {expr {[file size $b] - [file size $a]}}}} $suites] {
    dict set items golden:[file tail $path] [list golden \
        [list [info nameofexecutable] [file join $testDir golden run.tcl] -backends [join $goldenBackends ,] -quiet $path] \
        [list BOTLISH_HIR_CACHE $hirCache] "golden [file tail $path]"]
}
foreach path [lsort -command {apply {{a b} {expr {[file size $b] - [file size $a]}}}} $testFiles] {
    foreach backend $backends {
        set environment [list CORE_BACKEND $backend]
        if {$skipDuplicates} { lappend environment BOTLISH_SKIP_GOLDEN_DUPLICATES 1 }
        dict set items tcl:$backend:[file tail $path] [list tcl \
            [list [info nameofexecutable] $path] $environment "tcl $backend [file tail $path]"]
    }
}

# The likeliest to fail first (tests/canary.tcl), in its order; then the
# rest in the order above.
set first {}
if {[dict get $options -priority]} {
    source [file join $testDir canary.tcl]
    if {[catch {canary::priority} likely]} {
        puts "priority: none ($likely)"
        set likely {}
    }
    foreach item $likely {
        set tail [file tail $item]
        if {[string match *.bot $tail]} {
            set keys [list golden:$tail]
        } else {
            set keys [lmap b $backends {string cat tcl: $b : $tail}]
        }
        foreach key $keys {
            if {[dict exists $items $key] && $key ni $first} { lappend first $key }
        }
    }
}

# ---------------------------------------------------------------------------
# The pool: JOBS processes at a time, stdout through a pipe, stderr to a
# file (any stderr output counts as a test file error, as for tests/all.tcl).

set scratch [file tempdir botlish-local]
set results [dict create]
set pending [concat $first [lmap key [dict keys $items] {expr {$key in $first ? [continue] : $key}}]]
set running 0
set stopped 0
set started [clock milliseconds]

proc launch {key} {
    global items scratch running
    lassign [dict get $items $key] kind command environment
    set id [incr ::launched]
    set err [file join $scratch $id.stderr]
    if {$kind eq "tcl"} {
        set tmp [file join $scratch $id.tmp]
        file mkdir $tmp
        lappend command -tmpdir $tmp
    }
    set saved [dict create]
    foreach {name value} $environment {
        dict set saved $name [expr {[info exists ::env($name)] ? [list $::env($name)] : {}}]
        set ::env($name) $value
    }
    set channel [open |[concat $command [list 2> $err]] r]
    dict for {name value} $saved {
        if {$value eq {}} { unset ::env($name) } else { set ::env($name) [lindex $value 0] }
    }
    fconfigure $channel -blocking 0 -encoding utf-8
    set ::pipeOutput($channel) ""
    set ::pipeStart($channel) [clock milliseconds]
    fileevent $channel readable [list collect $channel $key $err]
    incr running
}

proc collect {channel key err} {
    global results running
    append ::pipeOutput($channel) [read $channel]
    if {![eof $channel]} return
    fconfigure $channel -blocking 1
    set status 0
    if {[catch {close $channel} message options]} {
        set code [dict get $options -errorcode]
        set status [expr {[lindex $code 0] eq "CHILDSTATUS" ? [lindex $code end] : 1}]
    }
    set stderr ""
    if {[file exists $err]} {
        set f [open $err r]
        fconfigure $f -encoding utf-8
        set stderr [read $f]
        close $f
    }
    set seconds [expr {([clock milliseconds] - $::pipeStart($channel)) / 1000.0}]
    dict set results $key [list $status $::pipeOutput($channel) $stderr $seconds]
    unset ::pipeOutput($channel) ::pipeStart($channel)
    incr running -1
    report $key
    if {$::failFast && ![lindex [verdict $key] 0]} { set ::stopped 1 }
    set ::event $key
}

# The verdict of a finished item: {OK SUMMARY}.
proc verdict {key} {
    global items results
    lassign [dict get $items $key] kind
    lassign [dict get $results $key] status output stderr
    if {$kind eq "tcl"} {
        if {![regexp {Total\s+(\d+)\s+Passed\s+(\d+)\s+Skipped\s+(\d+)\s+Failed\s+(\d+)} $output -> total passed skipped failed]} {
            return [list 0 "did not complete (status $status)"]
        }
        set duplicates 0
        regexp -line {^\s+(\d+)\s+goldenDuplicate$} $output -> duplicates
        set summary "$passed passed, $failed failed, $skipped skipped"
        if {$duplicates} { append summary " ($duplicates golden duplicates)" }
        if {[string trim $stderr] ne ""} {
            return [list 0 "$summary; wrote to stderr"]
        }
        return [list [expr {$failed == 0}] $summary]
    }
    set compile ""
    set parts {}
    foreach line [split $output \n] {
        if {[regexp {^\S+\s+(\S+)\s+(\d+) passed, (\d+) failed \(compile ([\d.]+)s} $line -> backend passed failed compile]} {
            lappend parts "$backend $passed/[expr {$passed + $failed}]"
        } elseif {[regexp {^\S+\s+(\S+)\s+ABORTED .*\(compile ([\d.]+)s} $line -> backend compile]} {
            lappend parts "$backend ABORTED"
        } elseif {[regexp {^\S+\s+(\S+)\s+excluded} $line -> backend]} {
            lappend parts "$backend excluded"
        } elseif {[regexp {DISAGREE|COMPILE ERROR} $line]} {
            lappend parts [string trim $line]
        }
    }
    set summary [join $parts ", "]
    if {$compile ne ""} { set summary "front end ${compile} s; $summary" }
    return [list [expr {$status == 0}] $summary]
}

proc report {key} {
    global items results verbose
    lassign [dict get $items $key] kind command environment label
    lassign [dict get $results $key] status output stderr seconds
    lassign [verdict $key] ok summary
    puts [format "%-6s %-44s %7.1f s  %s" [expr {$ok ? "ok" : "FAIL"}] $label $seconds $summary]
    if {$verbose} {
        puts $output
        if {$stderr ne ""} { puts "-- stderr:\n$stderr" }
    }
    flush stdout
}

puts "local run: [llength $testFiles] Tcl test files on [join $backends {, }][expr {$skipDuplicates ? " (golden duplicates skipped)" : " (every test)"}], [llength $suites] golden suites on [join $goldenBackends {, }] ([expr {$hirCache eq "" ? "no front-end cache" : "front-end cache $hirCache"}]), $jobs at a time"
if {$first ne {}} {
    puts "first, the likeliest to fail: [join [lmap key $first {lindex [dict get $items $key] 3}] {, }]"
}
flush stdout
try {
    while {([llength $pending] > 0 && !$stopped) || $running > 0} {
        while {$running < $jobs && [llength $pending] > 0 && !$stopped} {
            set pending [lassign $pending key]
            launch $key
        }
        vwait ::event
    }
} finally {
    file delete -force $scratch
}
set notRun [expr {$stopped ? $pending : {}}]
set wall [expr {([clock milliseconds] - $started) / 1000.0}]

# ---------------------------------------------------------------------------
# The summary.

set failures {}
set totals [dict create]
set goldenTotals [dict create suites 0 failedSuites 0]
dict for {key item} $items {
    if {![dict exists $results $key]} continue
    lassign $item kind command environment label
    lassign [dict get $results $key] status output stderr
    lassign [verdict $key] ok summary
    if {$kind eq "tcl"} {
        set backend [lindex [split $key :] 1]
        if {[regexp {Total\s+(\d+)\s+Passed\s+(\d+)\s+Skipped\s+(\d+)\s+Failed\s+(\d+)} $output -> total passed skipped failed]} {
            set duplicates 0
            regexp -line {^\s+(\d+)\s+goldenDuplicate$} $output -> duplicates
            foreach {name value} [list passed $passed failed $failed skipped [expr {$skipped - $duplicates}] duplicates $duplicates] {
                dict incr totals $backend,$name $value
            }
        }
    } else {
        dict incr goldenTotals suites
        if {!$ok} { dict incr goldenTotals failedSuites }
        foreach {- backend passed failed} [regexp -all -inline -line {^\S+\s+(\S+)\s+(\d+) passed, (\d+) failed} $output] {
            dict incr goldenTotals $backend,passed $passed
            dict incr goldenTotals $backend,failed $failed
        }
    }
    if {!$ok} {
        lappend failures $key
    }
}

puts ""
foreach backend $backends {
    if {![dict exists $totals $backend,passed]} continue
    puts [format "Tcl tests on %-8s %5d passed, %d failed, %d skipped, %d golden duplicates skipped" $backend \
        [dict get $totals $backend,passed] [dict get $totals $backend,failed] \
        [dict get $totals $backend,skipped] [dict get $totals $backend,duplicates]]
}
if {[dict get $goldenTotals suites]} {
    set perBackend [lmap backend $goldenBackends {
        expr {[dict exists $goldenTotals $backend,passed]
            ? "$backend [dict get $goldenTotals $backend,passed]/[expr {[dict get $goldenTotals $backend,passed] + [dict get $goldenTotals $backend,failed]}]"
            : [continue]}
    }]
    puts "Golden suites: [dict get $goldenTotals suites] run, [dict get $goldenTotals failedSuites] failed; tests passed: [join $perBackend {, }]"
}
if {$suites ne {} && $hirCache ne ""} {
    set removed [expr {$prune ? [Prune $hirCache $root] : 0}]
    set entries [glob -nocomplain -directory $hirCache *.hirc]
    set bytes [tcl::mathop::+ 0 {*}[lmap path $entries {file size $path}]]
    puts [format "Front-end cache %s: %d entries, %.0f MB%s" $hirCache [llength $entries] [expr {$bytes / 1e6}] \
        [expr {$removed ? ", $removed of other front ends removed" : ""}]]
}
puts [format "Wall time %.1f s with %d jobs." $wall $jobs]
if {$notRun ne {}} {
    puts "Not run (-fail-fast 1, after the first failure): [llength $notRun] of [dict size $items]"
}

if {$failures ne {}} {
    puts "\nFAILURES ([llength $failures]):"
    foreach key $failures {
        lassign [dict get $items $key] kind command environment label
        lassign [dict get $results $key] status output stderr
        puts "\n==== $label: [lindex [verdict $key] 1]"
        if {$kind eq "tcl"} {
            # Each failed test's block, "==== NAME DESCRIPTION FAILED" to
            # "==== NAME FAILED"; or the output's end, for a file that did
            # not complete.
            set lines [split $output \n]
            set shown {}
            set inside ""
            foreach line $lines {
                if {$inside eq "" && [regexp {^==== (\S+) .*FAILED$} $line -> name]} {
                    set inside $name
                }
                if {$inside ne ""} {
                    lappend shown $line
                    if {$line eq "==== $inside FAILED"} { set inside "" }
                }
            }
            if {$shown eq {}} { set shown [lrange $lines end-15 end] }
            puts [join [lrange $shown 0 200] \n]
            if {[string trim $stderr] ne ""} { puts "-- stderr:\n[string range $stderr 0 4000]" }
            puts "rerun: [expr {[llength $environment] ? "env [join [lmap {n v} $environment {string cat $n = $v}] { }] " : ""}]tclsh9.0 [file join tests [file tail [lindex $command 1]]]"
        } else {
            puts [string trim $output]
            if {[string trim $stderr] ne ""} { puts "-- stderr:\n[string range $stderr 0 4000]" }
            puts "rerun: tclsh9.0 tests/golden/run.tcl -backends [join $goldenBackends ,] tests/golden/[file tail [lindex $command end]]"
        }
    }
    exit 1
}
exit [expr {$notRun ne {}}]
