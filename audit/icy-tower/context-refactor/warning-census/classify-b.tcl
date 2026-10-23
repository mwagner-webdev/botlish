# classify-b.tcl -- turns partition B's scan (scan-b.tcl's output over the
# programs extract-tests.tcl and extract-fuzz.tcl captured) into the census
# files: one row per site with its classification, one row per distinct
# program with its outcome, and the summaries partition-b.md quotes.
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/classify-b.tcl \
#       -work WORK -out DIR
#
# WORK is census-b.tcl's working directory: WORK/t/SET/ (a test file's
# captures; SET the file's stem, SET@PLATFORM a -platform run), WORK/f/SET/
# (a fuzzer's), WORK/raw-t.tsv and WORK/raw-f.tsv (scan-b.tcl's output for
# each), WORK/cov-SET.txt (coverage-b.tcl's report per test file). Writes
#
#   DIR/partition-b.tsv        source, bucket, location, from, to, rules,
#                              what, classification, reason: a site is a
#                              location and its rules, once whatever number
#                              of programs observed it (source lists them);
#   DIR/partition-b-units.tsv  every distinct program: set, sources, entry,
#                              target, the test's or the model's outcome,
#                              the scan's outcome, error code and message,
#                              sites per bucket;
#
# and prints the summaries (per test file and fuzzer: tests, stopped
# bodies, captures, distinct programs, outcomes, sites per bucket; the
# compile failures; the totals).
#
# A location names the program a site is in: TESTFILE#TEST/PATH:LINE:COLUMN
# (the first test that compiled it), FUZZER#SEED:INDEX/PATH:..., or the
# repository path of a standard-library file. The classification is the
# census author's judgment, written below as rules: a site matches the first
# rule whose location glob, WHAT glob and rules glob all match. A site no
# rule matches stops the script: every site must be judged.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]

# {LOCATION-GLOB WHAT-GLOB RULES-GLOB CLASS REASON}
set classification {
    {stdlib/windows/io.bot:* {call std::windows::*} R1,R2 LEGITIMATE
     "partition A's site (stdlib/windows/io.bot, classified there), observed here because these test programs import std::windows::io: std::windows is the thin Win32 layer, ordinary and context-free (GetStdHandle's and WriteFile's handle are non-retaining, no direct edge), so there is no airlock; std::windows::io fetches the borrowed standard handle and passes it back within one call and never stores it (a C pointer cannot live in a context)"}
    {tests/windows-io.test#wi-c-declarations/main.bot:* {call std::windows::standard_handle} R1,R2 LEGITIMATE
     "a test of the raw Win32 layer itself: the program asks std::windows (ordinary, context-free, no airlock) for the borrowed standard output HANDLE and only tests it for null; standard_handle's result is a borrowed handle by design (never closed, never cached), and the program beside it writes through std::windows::io's context as intended"}
    {tests/native-view.test#nv-direct-modules/main.bot:* {call std::nvdemo::raw::open} R1,R2,R3 LEGITIMATE
     "the test's subject (NATIVE-LAYOUT-VIEWS.md, DIRECT-MODULES.md): std::nvdemo::raw is a designated `direct module`, the raw layer that turns a C pointer into a view; the entry program is the airlock (contextualized: its App context mediates this direct edge), and passing the pointer in and taking the view out is the mediated call itself -- there is nothing behind the callee to keep it"}
    {tests/native-view.test#nv-direct-modules/main.bot:* {call std::nvdemo::reader::a_of} R3 LEGITIMATE
     "the test's subject: an ordinary module that reads a view someone else made stays ordinary (a view is the authority, already granted: NATIVE-LAYOUT-VIEWS.md). Intended, and harmless here: layout L is pointer-free (one U32), so no pointer authority travels. Note the direction: the airlock is the *caller* (the entry program, contextualized), handing the view out as an argument; the instrument buckets by the callee only (reader: no-context), so an airlock passing a view or pointer out through an argument can never be a hit"}
    {tests/native-edit.test#ne-direct-modules/main.bot:* {call std::nedemo::raw::open} R1,R2,R3 LEGITIMATE
     "the test's subject (NATIVE-LAYOUT-WRITES.md, DIRECT-MODULES.md): std::nedemo::raw is a designated `direct module` making write authority (NativeEdit) from a C pointer; the entry program's App context mediates the call -- the raw layer has nothing behind it to keep"}
    {tests/native-edit.test#ne-direct-modules/main.bot:* {call std::nedemo::writer::set_a} R3 LEGITIMATE
     "the test's subject: an ordinary module storing through an edit someone made stays ordinary (NATIVE-LAYOUT-WRITES.md: storing through an edit is not direct). Intended; L is pointer-free (one U32 field), so no pointer can be punned through it. As for nv-direct-modules, the airlock is the caller, which the callee-keyed buckets cannot express"}
}

proc ReadLines {path} {
    if {![file exists $path]} { return {} }
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set lines [split [string trimright [read $f] \n] \n]
    close $f
    return $lines
}

proc Write {path lines} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    foreach line $lines { puts $f $line }
    close $f
}

set work ""
set outDir ""
foreach {option value} $argv {
    switch -- $option {
        -work { set work [file normalize $value] }
        -out { set outDir [file normalize $value] }
        default { error "unknown option $option" }
    }
}

# The origin of each set: its test file or fuzzer, for locations.
proc Origin {set} {
    set base [lindex [split $set @] 0]
    if {[file exists [file join $::root tests $base.test]]} {
        return tests/$base.test
    }
    if {$base eq "aot-facts"} {
        return tests/platform/aot-facts.tcl
    }
    return audit/$base/tools/fuzz.tcl
}

set units [dict create]
set order {}
set siteOrder {}
set sites [dict create]
set repo {}
foreach kind {t f} {
    foreach line [ReadLines [file join $work raw-$kind.tsv]] {
        set fields [split $line \t]
        switch -- [lindex $fields 0] {
            UNIT {
                lassign $fields - uid set sources entry target expect outcome seconds code message
                set first [lindex [split $sources ";"] 0]
                regsub { \[.*\]$} [string trim $first] {} first
                dict set units $uid [dict create kind $kind set $set sources $sources entry $entry target $target \
                    expect $expect outcome $outcome code $code message $message buckets [dict create] \
                    prefix "[Origin $set]#$first/"]
                lappend order $uid
            }
            SITE {
                lassign $fields - uid bucket location from to rules what
                set unit [dict get $units $uid]
                if {[string match $uid/* $location]} {
                    set location [dict get $unit prefix][string range $location [string length $uid/] end]
                }
                set key [list $location $rules]
                if {![dict exists $sites $key]} {
                    dict set sites $key [dict create bucket $bucket from $from to $to what $what sources {}]
                    lappend siteOrder $key
                }
                foreach s [split [dict get $unit sources] ";"] {
                    set s "[Origin [dict get $unit set]]#[string trim $s]"
                    if {$s ni [dict get $sites $key sources]} {
                        dict set sites $key sources [linsert [dict get $sites $key sources] end $s]
                    }
                }
                set b [dict get $units $uid buckets]
                dict incr b $bucket
                dict set units $uid buckets $b
            }
            REPO {
                lassign $fields - id test path outcome
                lappend repo [list $id $test $path $outcome]
            }
        }
    }
}

# Classify.
set rows [list [join {source bucket location from to rules what classification reason} \t]]
set totals [dict create]
foreach key $siteOrder {
    set s [dict get $sites $key]
    lassign $key location rules
    set what [dict get $s what]
    set class ""
    foreach rule $classification {
        lassign $rule lglob wglob rglob c reason
        if {[string match $lglob $location] && [string match $wglob $what] && [string match $rglob $rules]} {
            set class $c
            break
        }
    }
    if {$class eq ""} {
        error "unclassified site: $location $rules $what"
    }
    set sources [dict get $s sources]
    set source [expr {[llength $sources] > 3
        ? "[llength $sources] programs: [join $sources {; }]" : [join $sources {; }]}]
    lappend rows [join [list $source [dict get $s bucket] $location [dict get $s from] [dict get $s to] \
        $rules $what $class [string map {\n " " \t " "} [regsub -all {\s+} $reason " "]]] \t]
    dict incr totals "[dict get $s bucket] $class"
    dict incr totals "all $class"
}
Write [file join $outDir partition-b.tsv] $rows

# Units.
set unitRows [list [join {set sources entry target expected outcome code message sites} \t]]
set perSet [dict create]
set failures {}
foreach uid $order {
    set u [dict get $units $uid]
    set set [dict get $u set]
    set base [lindex [split $set @] 0]
    set expect [dict get $u expect]
    set rejected [expr {[regexp {(^|; )(error|diagnostics|expected rejected)} $expect]
        && ![regexp {(^|; )(ok|expected ok|not compiled)} $expect]}]
    set outcome [dict get $u outcome]
    if {$outcome eq "ok"} {
        set class ok
    } elseif {$rejected} {
        set class rejected
    } else {
        set class failure
        lappend failures [list $set [dict get $u sources] [dict get $u code] [dict get $u message]]
    }
    dict incr perSet "$base units"
    dict incr perSet "$base $class"
    set bs {}
    dict for {b n} [dict get $u buckets] {
        lappend bs "$b $n"
        dict incr perSet "$base site-observations"
    }
    lappend unitRows [join [list $set [dict get $u sources] [dict get $u entry] [dict get $u target] \
        $expect $outcome [dict get $u code] [dict get $u message] [join $bs ,]] \t]
}
Write [file join $outDir partition-b-units.tsv] $unitRows

# Summaries.
puts "== per set (the first set to capture a program owns it):"
puts [join {set tests stopped captures units ok rejected failure} \t]
foreach dir [lsort [concat [glob -nocomplain -directory [file join $work t] *] [glob -nocomplain -directory [file join $work f] *]]] {
    if {![file isdirectory $dir]} continue
    set set [file tail $dir]
    set tests [llength [ReadLines [file join $dir tests.tsv]]]
    set stopped 0
    foreach line [ReadLines [file join $dir tests.tsv]] {
        if {[lindex [split $line \t] 2] ne "ok"} { incr stopped }
    }
    set captures [llength [ReadLines [file join $dir captures.tsv]]]
    set base [lindex [split $set @] 0]
    puts [join [list $set $tests $stopped $captures \
        [expr {$set eq $base ? [dict getdef $perSet "$base units" 0] : "-"}] \
        [expr {$set eq $base ? [dict getdef $perSet "$base ok" 0] : "-"}] \
        [expr {$set eq $base ? [dict getdef $perSet "$base rejected" 0] : "-"}] \
        [expr {$set eq $base ? [dict getdef $perSet "$base failure" 0] : "-"}]] \t]
}
puts "\n== repository programs a test compiled (partition A's, not scanned here):"
foreach r $repo { puts [join $r \t] }
puts "\n== compile failures (the test's or model's compilation succeeded, the scan's did not):"
foreach f $failures { puts [join $f \t] }
puts "\n== sites: [llength $siteOrder]; by bucket and classification:"
dict for {k n} [lsort -stride 2 $totals] { puts "$k\t$n" }
