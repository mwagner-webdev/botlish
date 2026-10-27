# invariance.tcl -- what a change to how method-call rejections are reported
# changes of a program (METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md,
# "Semantic invariance").
#
#   tclsh9.0 audit/method-resolution/tools/invariance.tcl -root DIR -out FILE
#       ?-jobs N? ?FILE.bot ...?
#   tclsh9.0 audit/method-resolution/tools/invariance.tcl -compare BEFORE AFTER
#
# The first form compiles each program (default: every golden suite, and
# the workloads' suites) with the front end of the checkout DIR -- each in a
# process of its own, -strict 0, warnings off, no cache, for its platform's
# target as the golden runner does -- and writes one record per program to
# FILE: what the front end decided and what it reports,
#
#   decided    the method-call decisions (methodDecided), sorted
#   choices    every call's candidate (methodChoices), sorted
#   static     each static site's outcome and the code it reifies
#   accepted   1 when the HIR has no diagnostic
#   hir        for an accepted program, the length and CRC-32 of its HIR
#              text (hir::format), the message of a method-call rejection a
#              rejected static compile block reifies left out, the
#              checkout's standard library written STDLIB
#   reported   what a strict compilation reports: {KIND LINE:COLUMN} each
#   counters   whole-program builds, method trial builds, single deviations,
#              final programs built again, reused builds, reported forms
#   ms         the front end's time
#
# The second form compares two such files program by program: the
# decisions, static outcomes and accepted programs' HIR must be the same
# (any difference is listed as a semantic difference); reported diagnostics
# and counters may differ, and are listed. It never calls the decision
# procedure: it reads what two front ends recorded.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# The child: record one program PATH with the front end of FRONT.
proc record {front path} {
    cd $front
    set ::argv {}
    source [file join $front core core.tcl]
    source [file join $front surface surface.tcl]
    interp recursionlimit {} 100000
    set target [surface::modules::PlatformTarget [core::ReadFile $path]]
    set before [hir::BuildStats]
    set start [clock milliseconds]
    if {[catch {surface::readProgramFile $path -strict 0 -warnings off -cache "" -target $target} hir]} {
        puts [list RECORD [dict create path $path error [string range $hir 0 300]]]
        return
    }
    set ms [expr {[clock milliseconds] - $start}]
    set after [hir::BuildStats]
    set counters {}
    foreach counter {builds methodTrials methodDeviations methodFinals methodReused methodReports} {
        lappend counters $counter [expr {[dict getdef $after $counter 0] - [dict getdef $before $counter 0]}]
    }
    set static {}
    dict for {key site} [dict getdef $hir staticSites {}] {
        set entry [dict get $site outcome]
        if {[dict exists $site diagnostic]} {
            lappend entry [dict get $site diagnostic kind]
        }
        lappend static $key $entry
    }
    set reported [lmap d [hir::recovery::reported $hir] {
        set origin [if {[dict exists $d origin]} {dict get $d origin} else {hir::get $hir [dict get $d expr] origin}]
        list [dict get $d kind] [file tail [hir::originLocation $hir $origin]]
    }]
    set accepted [expr {[dict get $hir diagnostics] eq {}}]
    set text ""
    if {$accepted} {
        # (The text of a method-call rejection a rejected static compile
        # block reifies is the presentation this compares across, not what
        # the program is: its message constant is left out.)
        regsub -all -line {const str \{method-style call .*\} : str$} [hir::format $hir] {const str {REJECTION} : str} formatted
        # (Nor where the checkout's standard library is: a message may name
        # one of its files.)
        set formatted [string map [list [file join $front stdlib] STDLIB] $formatted]
        set formatted [encoding convertto utf-8 $formatted]
        set text [list [string length $formatted] [zlib crc32 $formatted]]
    }
    puts [list RECORD [dict create path $path \
        decided [lsort -stride 2 [dict getdef $hir methodDecided {}]] \
        choices [lsort -stride 2 [dict getdef $hir methodChoices {}]] \
        static $static accepted $accepted hir $text reported $reported counters $counters ms $ms]]
}

if {[lindex $argv 0] eq "-child"} {
    lassign $argv - front path
    record $front $path
    exit 0
}

proc readRecords {file} {
    set f [open $file r]
    fconfigure $f -encoding utf-8
    set records [dict create]
    foreach line [split [read $f] \n] {
        if {$line eq ""} continue
        set r [lindex $line 1]
        dict set records [dict get $r path] $r
    }
    close $f
    return $records
}

if {[lindex $argv 0] eq "-compare"} {
    lassign $argv - beforeFile afterFile
    set before [readRecords $beforeFile]
    set after [readRecords $afterFile]
    set semantic 0
    set reports 0
    set totals [dict create]
    foreach name [lsort [dict keys $before]] {
        if {![dict exists $after $name]} {
            puts "$name: only before"
            incr semantic
            continue
        }
        set a [dict get $before $name]
        set b [dict get $after $name]
        if {[dict exists $a error] || [dict exists $b error]} {
            if {[dict getdef $a error ""] ne [dict getdef $b error ""]} {
                puts "$name: SEMANTIC error: [dict getdef $a error -] / [dict getdef $b error -]"
                incr semantic
            }
            continue
        }
        foreach field {decided choices static accepted hir} {
            if {[dict get $a $field] ne [dict get $b $field]} {
                puts "$name: SEMANTIC $field differs\n    before: [dict get $a $field]\n    after:  [dict get $b $field]"
                incr semantic
            }
        }
        if {[dict get $a reported] ne [dict get $b reported]} {
            puts "$name: reported\n    before: [dict get $a reported]\n    after:  [dict get $b reported]"
            incr reports
        }
        foreach {which r} [list before $a after $b] {
            dict for {counter n} [dict get $r counters] {
                dict incr totals $which,$counter $n
            }
            dict incr totals $which,ms [dict get $r ms]
            dict incr totals $which,reported [llength [dict get $r reported]]
        }
        if {[dict get $a counters] ne [dict get $b counters]} {
            puts "$name: counters [dict get $a counters] -> [dict get $b counters]"
        }
    }
    puts "programs [dict size $before]; semantic differences $semantic; programs reporting differently $reports"
    foreach which {before after} {
        puts "$which: [join [lmap key [lsort [dict keys $totals $which,*]] {string cat [string range $key [string length $which,] end] " " [dict get $totals $key]}] {, }]"
    }
    exit [expr {$semantic > 0}]
}

set options [dict create -root $root -out "" -jobs 1]
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {[dict exists $options $arg]} {
        dict set options $arg [lindex $argv [incr i]]
    } else {
        lappend files [file normalize $arg]
    }
}
if {$files eq {}} {
    set files [lsort [glob -directory [file join $root tests golden] *.bot]]
    foreach workload {examples/games/2048/golden.bot examples/games/icy-tower/golden.bot} {
        if {[file exists [file join $root $workload]]} {
            lappend files [file join $root $workload]
        }
    }
}
set front [file normalize [dict get $options -root]]
set out [open [dict get $options -out] w]
fconfigure $out -encoding utf-8
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
# (Each child its own process: no compilation's state reaches another's.)
set pending $files
set running [dict create]
set jobs [dict get $options -jobs]
proc finished {channel path} {
    global out running
    if {[eof $channel]} {
        fconfigure $channel -blocking 1
        catch {close $channel}
        dict unset running $channel
        return
    }
    set line [gets $channel]
    if {[string match "RECORD *" $line]} {
        puts $out $line
        flush $out
        puts stderr "recorded [file tail $path]"
    }
}
while {$pending ne {} || [dict size $running] > 0} {
    while {$pending ne {} && [dict size $running] < $jobs} {
        set path [lindex $pending 0]
        set pending [lrange $pending 1 end]
        set channel [open |[list [info nameofexecutable] [info script] -child $front $path 2>@stderr] r]
        fconfigure $channel -blocking 0 -encoding utf-8
        fileevent $channel readable [list finished $channel $path]
        dict set running $channel $path
    }
    vwait running
}
close $out
