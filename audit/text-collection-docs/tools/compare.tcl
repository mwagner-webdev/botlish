# compare.tcl -- what naming the inferred type in a declared result's TYPE
# diagnostic changes of a program
# (TEXT-AND-COLLECTION-DOCUMENTATION-AND-DIAGNOSTICS-MILESTONE-1.md,
# section I): nothing but that message's text.
#
#   tclsh9.0 audit/text-collection-docs/tools/compare.tcl -root DIR -out FILE
#       ?-programs DIR? ?-jobs N? ?FILE.bot ...?
#   tclsh9.0 audit/text-collection-docs/tools/compare.tcl -compare BEFORE AFTER
#
# The first form compiles each program (default: every golden suite, the
# workloads' suites, the census's probes, examples/surface, examples/stdlib
# and this audit's programs, read from the checkout -programs names, by
# default -root's: give both runs the same one, so that they compile the same
# text) with the front end of the checkout DIR -- each
# in a process of its own, -strict 0, warnings off, no cache, for its
# platform's target as the golden runner does -- and writes one record per
# program to FILE:
#
#   accepted   1 when the HIR has no diagnostic
#   reported   what the compilation reports: {KIND FILE:LINE:COLUMN} each
#   messages   their messages, as printed
#   results    every declared-result mismatch: {LOCATION DECLARED INFERRED},
#              the declared type and the block's inferred result type
#              (hir::types::show)
#   decided    the method-call decisions (methodDecided), sorted
#   choices    every call's candidate (methodChoices), sorted
#   static     each static site's outcome and the code it reifies
#   emissions  every emission claim's {FUNCTION RECOGNIZER VERDICT}
#   hir        the length and CRC-32 of its HIR text (hir::format: every
#              expression's type, completion outcome, target and flags, and
#              the constants a rejected static block reifies), the
#              checkout's directory written ROOT
#   values     an accepted program outside tests/golden: its value on
#              interp and compile ({BACKEND VALUE-OR-ERROR} each)
#   ms         the front end's time
#
# The second form compares two such files program by program. Every field
# but `messages`, `hir` and `ms` is semantic and must be equal. `messages`
# and `hir` are compared twice: as they are, which lists the programs whose
# text changed, and with the one clause this milestone adds removed from
# both sides (" (result type: T)", or "result type: T, " before the facts)
# -- that comparison is semantic too, so a change anywhere else in a message
# or in the HIR text is a difference.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# TEXT with the clause this milestone adds to a declared result's diagnostic
# removed: the text the compiler before it printed.
proc Unclaused {text} {
    regsub -all {\(result type: [^()]*?, facts: } $text {(facts: } text
    regsub -all { \(result type: [^()]*\)} $text {} text
    return $text
}

# The child: record one program PATH with the front end of FRONT.
proc record {front path} {
    cd $front
    set ::argv {}
    source [file join $front compiler compiler.tcl]
    source [file join $front surface surface.tcl]
    interp recursionlimit {} 100000
    core::useProgramRecursionLimit
    set target [surface::modules::PlatformTarget [core::ReadFile $path]]
    set start [clock milliseconds]
    if {[catch {surface::readProgramFile $path -strict 0 -warnings off -cache "" -target $target} hir]} {
        set message [string range [string map [list \n " | " [file dirname $path] DIR $front ROOT] $hir] 0 300]
        puts [list RECORD [dict create path $path error $message]]
        return
    }
    set ms [expr {[clock milliseconds] - $start}]
    set static {}
    dict for {key site} [dict getdef $hir staticSites {}] {
        set entry [dict get $site outcome]
        if {[dict exists $site diagnostic]} {
            lappend entry [dict get $site diagnostic kind]
        }
        lappend static $key $entry
    }
    set reported {}
    set messages {}
    set results {}
    foreach d [hir::recovery::reported $hir] {
        set origin [if {[dict exists $d origin]} {dict get $d origin} else {hir::get $hir [dict get $d expr] origin}]
        set location [file tail [hir::originLocation $hir $origin]]
        lappend reported [list [dict get $d kind] $location]
        lappend messages [string map [list [file dirname $path] DIR $front ROOT] [dict get $d message]]
        if {[string match {function result does not prove declared type *} [dict get $d message]]
                && [dict exists $d expr] && [dict exists $hir exprs [dict get $d expr] inferredResultType]} {
            set node [dict get $hir exprs [dict get $d expr]]
            lappend results [list $location [hir::types::show [dict get $node declaredResult]] \
                [hir::types::show [hir::type $hir [dict get $node inferredResultType]]]]
        }
    }
    set accepted [expr {[dict get $hir diagnostics] eq {}}]
    set formatted [string map [list [file dirname $path] DIR $front ROOT] [hir::format $hir]]
    set raw [encoding convertto utf-8 $formatted]
    set plain [encoding convertto utf-8 [Unclaused $formatted]]
    set emissions [lsort [lmap c [hir::emission::claims $hir] {
        list [dict get $c function] [dict get $c recognizer] [dict get $c verdict]
    }]]
    set values {}
    if {$accepted && [string first /tests/golden/ $path] < 0 && ![string match */golden.bot $path]} {
        foreach backend {interp compile} {
            core::useBackend $backend
            if {[catch {
                if {$backend eq "interp"} {
                    set value [core::evalProgram [hir::lower $hir]]
                } else {
                    set value [core::compiler::evalHir $hir]
                }
                core::value::show $value 1
            } shown]} {
                set shown "error: [string range $shown 0 200]"
            }
            lappend values $backend $shown
        }
    }
    puts [list RECORD [dict create path $path accepted $accepted reported $reported messages $messages \
        results $results \
        decided [lsort -stride 2 [dict getdef $hir methodDecided {}]] \
        choices [lsort -stride 2 [dict getdef $hir methodChoices {}]] \
        static $static emissions $emissions \
        hir [list [string length $raw] [zlib crc32 $raw]] \
        hirPlain [list [string length $plain] [zlib crc32 $plain]] \
        values $values ms $ms]]
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
    set textChanged {}
    set hirChanged {}
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
        dict incr totals programs
        if {[dict exists $a error] || [dict exists $b error]} {
            dict incr totals errors
            if {[dict getdef $a error ""] ne [dict getdef $b error ""]} {
                puts "$short: SEMANTIC error: [dict getdef $a error -] / [dict getdef $b error -]"
                incr semantic
            }
            continue
        }
        dict incr totals accepted [dict get $b accepted]
        dict incr totals reported [llength [dict get $b reported]]
        dict incr totals results [llength [dict get $b results]]
        dict incr totals runs [expr {[llength [dict get $b values]] / 2}]
        dict incr totals before.ms [dict get $a ms]
        dict incr totals after.ms [dict get $b ms]
        foreach field {accepted reported results decided choices static emissions values hirPlain} {
            if {[dict get $a $field] ne [dict get $b $field]} {
                puts "$short: SEMANTIC $field differs\n    before: [dict get $a $field]\n    after:  [dict get $b $field]"
                incr semantic
            }
        }
        set plainA [lmap m [dict get $a messages] {Unclaused $m}]
        set plainB [lmap m [dict get $b messages] {Unclaused $m}]
        if {$plainA ne $plainB} {
            puts "$short: SEMANTIC messages differ beyond the result type\n    before: $plainA\n    after:  $plainB"
            incr semantic
        }
        set changed 0
        foreach m [dict get $a messages] n [dict get $b messages] {
            if {$m ne $n} { incr changed }
        }
        if {$changed} {
            lappend textChanged "$short ($changed)"
            dict incr totals messagesChanged $changed
        }
        if {[dict get $a hir] ne [dict get $b hir]} {
            lappend hirChanged $short
        }
    }
    puts "programs [dict size $before]; semantic differences $semantic"
    puts "totals: [join [lmap key [lsort [dict keys $totals]] {string cat $key " " [dict get $totals $key]}] {, }]"
    puts "messages changed (the result type added): [join $textChanged {, }]"
    puts "HIR text changed (a reified static diagnostic's message): [join $hirChanged {, }]"
    exit [expr {$semantic > 0}]
}

set options [dict create -root $root -out "" -jobs 1 -programs ""]
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
set programs [expr {[dict get $options -programs] eq "" ? $front : [file normalize [dict get $options -programs]]}]
if {$files eq {}} {
    set files [lsort [glob -directory [file join $programs tests golden] *.bot]]
    foreach workload {examples/games/2048/golden.bot examples/games/icy-tower/golden.bot} {
        if {[file exists [file join $programs $workload]]} {
            lappend files [file join $programs $workload]
        }
    }
    foreach dir {audit/text-collection-precision/probes examples/surface examples/stdlib} {
        lappend files {*}[lsort [glob -nocomplain -directory [file join $programs $dir] *.bot]]
    }
    # This audit's programs are read from this checkout, whichever front end
    # compiles them (the tree before the milestone has none of its own).
    lappend files {*}[lsort [glob -nocomplain -directory [file join $root audit text-collection-docs programs] *.bot]]
}
set out [open [dict get $options -out] w]
fconfigure $out -encoding utf-8
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
# (Each child its own process: no compilation's state reaches another's. A
# record is keyed by the program's path relative to its checkout, so the two
# checkouts' records of one program meet.)
set pending $files
set running [dict create]
set jobs [dict get $options -jobs]
proc finished {channel path} {
    global out running front root programs
    if {[eof $channel]} {
        fconfigure $channel -blocking 1
        catch {close $channel}
        dict unset running $channel
        return
    }
    set line [gets $channel]
    if {[string match "RECORD *" $line]} {
        set r [lindex $line 1]
        set rel [string map [list $programs/ "" $front/ "" $root/ ""] [dict get $r path]]
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
