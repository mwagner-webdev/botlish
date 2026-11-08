# compare.tcl -- what recording loop clause binding types changes of a
# program (LOOP-CLAUSE-BINDING-TYPE-CORRECTNESS-MILESTONE-1.md, sections G,
# H and M).
#
#   tclsh9.0 audit/loop-binding-types/tools/compare.tcl -root DIR -out FILE
#       ?-jobs N? ?FILE.bot ...?
#   tclsh9.0 audit/loop-binding-types/tools/compare.tcl -compare BEFORE AFTER
#
# The first form compiles each program (default: every golden suite, the
# workloads' suites and the census's probes) with the front end of the
# checkout DIR -- each in a process of its own, -strict 0, warnings off, no
# cache, for its platform's target as the golden runner does -- and writes
# one record per program to FILE:
#
#   decided    the method-call decisions (methodDecided), sorted
#   choices    every call's candidate (methodChoices), sorted
#   static     each static site's outcome and the code it reifies
#   accepted   1 when the HIR has no diagnostic
#   hir        the length and CRC-32 of its HIR text (hir::format, which
#              prints every expression's type, outcome, target and flags but
#              no binding's recorded type), the checkout's directory written
#              ROOT (a message or a module may name a file)
#   reported   what the compilation reports: {KIND FILE:LINE:COLUMN} each
#   emissions  every emission claim's {FUNCTION RECOGNIZER VERDICT}
#   deps       the static-decision dependency analyses the compilation ran
#              (hir::staticdeps::Deps, counted by an execution trace): calls,
#              graph nodes, labelled edges, site dependencies
#   loops      the program's loop clause bindings: how many (total), how
#              many the binding table records as `any`, how many a
#              reachable reference sees more precisely than the record
#              (finer: a reference typed T, not never, T a proper subtype
#              of the record R -- a missing record, or a guard's narrowing)
#              or contrary to it (contradicts: T no subtype of R), and how
#              many semantic instances' snapshots record one
#   counters   whole-program builds, method trial builds, single deviations,
#              final programs built again, reused builds, reported forms
#   ms         the front end's time
#
# The second form compares two such files program by program: decisions,
# choices, static outcomes, acceptance, HIR text, reported diagnostics and
# emission verdicts are semantic (any difference is listed as one); the
# dependency graph, the loop counts and the counters are listed with their
# totals.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# The child: record one program PATH with the front end of FRONT.
proc record {front path} {
    cd $front
    set ::argv {}
    source [file join $front core core.tcl]
    source [file join $front surface surface.tcl]
    interp recursionlimit {} 100000
    set ::deps [dict create calls 0 nodes 0 edges 0 pairs 0]
    trace add execution hir::staticdeps::Deps leave {apply {{cmd code result op} {
        if {$code != 0} return
        dict incr ::deps calls
        dict incr ::deps nodes [dict get $result nodes]
        set edges 0
        dict for {node labelled} [dict get $result labels] {
            incr edges [expr {[llength $labelled] / 2}]
        }
        dict incr ::deps edges $edges
        set pairs 0
        dict for {key sites} [dict get $result sites] {
            incr pairs [llength $sites]
        }
        dict incr ::deps pairs $pairs
    }}}
    set target [surface::modules::PlatformTarget [core::ReadFile $path]]
    set before [hir::BuildStats]
    set start [clock milliseconds]
    if {[catch {surface::readProgramFile $path -strict 0 -warnings off -cache "" -target $target} hir]} {
        set message [string range [string map [list \n " | " $front ROOT] $hir] 0 300]
        puts [list RECORD [dict create path $path error $message]]
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
    set formatted [string map [list $front ROOT] [hir::format $hir]]
    set formatted [encoding convertto utf-8 $formatted]
    set text [list [string length $formatted] [zlib crc32 $formatted]]
    set emissions [lsort [lmap c [hir::emission::claims $hir] {
        list [dict get $c function] [dict get $c recognizer] [dict get $c verdict]
    }]]
    puts [list RECORD [dict create path $path \
        decided [lsort -stride 2 [dict getdef $hir methodDecided {}]] \
        choices [lsort -stride 2 [dict getdef $hir methodChoices {}]] \
        static $static accepted $accepted hir $text reported $reported \
        emissions $emissions deps $::deps loops [Loops $hir] counters $counters ms $ms]]
}

# The loop clause bindings of HIR: {total N any A finer F snapshots S}.
proc Loops {hir} {
    set clauses {}
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            listloop { lappend clauses [dict get $node elementBinding] }
            countloop { lappend clauses [dict get $node countBinding] }
            lockloop {
                foreach d [dict get $node domains] {
                    lappend clauses [dict get $d binding]
                }
            }
        }
    }
    set refTypes [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && [dict get $node reachable]} {
            dict lappend refTypes [dict get $node binding] [hir::typeOf $hir $e]
        }
    }
    set any 0
    set finer 0
    set contradicts 0
    foreach b $clauses {
        set recorded [hir::bindingType $hir $b]
        if {$recorded eq "any"} {
            incr any
        }
        set f 0
        set c 0
        foreach t [dict getdef $refTypes $b {}] {
            if {$t eq "never" || $t eq $recorded} continue
            if {[hir::types::subtype $t $recorded]} {
                set f 1
            } else {
                set c 1
            }
        }
        incr finer $f
        incr contradicts $c
    }
    set snapshots 0
    if {[dict exists $hir semantic instances]} {
        dict for {id inst} [dict get $hir semantic instances] {
            if {![dict exists $inst snapshot bindings]} continue
            foreach b $clauses {
                if {[dict exists $inst snapshot bindings $b]} {
                    incr snapshots
                }
            }
        }
    }
    return [dict create total [llength $clauses] any $any finer $finer contradicts $contradicts snapshots $snapshots]
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
    set totals [dict create]
    foreach name [lsort [dict keys $before]] {
        set short [file tail $name]
        if {![dict exists $after $name]} {
            puts "$short: only before"
            incr semantic
            continue
        }
        set a [dict get $before $name]
        set b [dict get $after $name]
        if {[dict exists $a error] || [dict exists $b error]} {
            if {[dict getdef $a error ""] ne [dict getdef $b error ""]} {
                puts "$short: SEMANTIC error: [dict getdef $a error -] / [dict getdef $b error -]"
                incr semantic
            }
            continue
        }
        foreach field {decided choices static accepted hir reported emissions} {
            if {[dict get $a $field] ne [dict get $b $field]} {
                puts "$short: SEMANTIC $field differs\n    before: [dict get $a $field]\n    after:  [dict get $b $field]"
                incr semantic
            }
        }
        foreach {which r} [list before $a after $b] {
            foreach group {counters deps loops} {
                dict for {counter n} [dict get $r $group] {
                    dict incr totals $which,$group.$counter $n
                }
            }
            dict incr totals $which,ms [dict get $r ms]
            dict incr totals $which,reported [llength [dict get $r reported]]
            dict incr totals $which,programs
        }
        foreach group {counters deps} {
            if {[dict get $a $group] ne [dict get $b $group]} {
                puts "$short: $group [dict get $a $group] -> [dict get $b $group]"
            }
        }
    }
    puts "programs [dict size $before]; semantic differences $semantic"
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
set front [file normalize [dict get $options -root]]
if {$files eq {}} {
    set files [lsort [glob -directory [file join $front tests golden] *.bot]]
    foreach workload {examples/games/2048/golden.bot examples/games/icy-tower/golden.bot} {
        if {[file exists [file join $front $workload]]} {
            lappend files [file join $front $workload]
        }
    }
    lappend files {*}[lsort [glob -nocomplain -directory [file join $front audit text-collection-precision probes] *.bot]]
}
set out [open [dict get $options -out] w]
fconfigure $out -encoding utf-8
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
# (Each child its own process: no compilation's state reaches another's.
# A record is keyed by the program's path relative to its checkout, so the
# two checkouts' records of one program meet.)
set pending $files
set running [dict create]
set jobs [dict get $options -jobs]
proc finished {channel path} {
    global out running front
    if {[eof $channel]} {
        fconfigure $channel -blocking 1
        catch {close $channel}
        dict unset running $channel
        return
    }
    set line [gets $channel]
    if {[string match "RECORD *" $line]} {
        set r [lindex $line 1]
        set rel [string map [list $front/ ""] [dict get $r path]]
        dict set r path $rel
        puts $out [list RECORD $r]
        flush $out
        puts stderr "recorded $rel"
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
