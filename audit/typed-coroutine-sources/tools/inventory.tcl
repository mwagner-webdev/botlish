# inventory.tcl -- every coroutine construction in the repository's own
# Botlish (EMISSION-TYPED-COROUTINE-SOURCE-CENSUS-MILESTONE-1.md, section 12).
#
#   tclsh9.0 audit/typed-coroutine-sources/tools/inventory.tcl ?-out FILE?
#
# A textual survey, not an analysis: for each `coroutine {...} = ROOT(...)`
# line of stdlib/, packages/, examples/, bench/, integrations/ and
# tests/golden/ (comments excluded), the function that holds it (the nearest
# column-0 `fn` line above; "-" at the top level) and what that function's
# text does after the construction:
#
#   done      it calls std::coroutine::done? (tells the phases apart)
#   sentinel  it compares something with -1 (`== -1`, `!= -1`): a terminal
#             or end value read as a value
#   narrow    it compares with 255 or 127 next to `< 0` (a byte or ASCII
#             narrowing of a received value)
#   adopt     it hands the handle to std::event_loop::adopt or a library
#             that consumes it (actor's spawned, a loop task)
#   handled   the construction line ends in ':' (handlers on it)
#
# Writes FILE (default results/sites.tsv) and prints per-directory counts.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set out [file join [file dirname $here] results sites.tsv]
if {[llength $argv] == 2 && [lindex $argv 0] eq "-out"} {
    set out [lindex $argv 1]
}

proc files {dir} {
    set result {}
    foreach f [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $f]} {
            if {[file tail $f] in {target .bot_modules}} continue
            lappend result {*}[files $f]
        } elseif {[file extension $f] eq ".bot"} {
            lappend result $f
        }
    }
    return $result
}

set rows {}
set counts [dict create]
foreach dir {stdlib packages examples bench integrations tests/golden} {
    foreach f [lsort [files [file join $root $dir]]] {
        set fh [open $f r]
        fconfigure $fh -encoding utf-8
        set lines [split [read $fh] \n]
        close $fh
        set n [llength $lines]
        for {set i 0} {$i < $n} {incr i} {
            set line [lindex $lines $i]
            if {[regexp {^\s*#} $line]} continue
            if {![regexp {coroutine \{([^\}]*)\} = ([A-Za-z_][A-Za-z0-9_:]*)} $line -> fields rootName]} continue
            # The enclosing function: the nearest column-0 fn line above.
            set fn -
            set start 0
            for {set j $i} {$j >= 0} {incr j -1} {
                set l [lindex $lines $j]
                if {[regexp {^(?:private |nomethod |exported c |callback c |thread )*fn ([A-Za-z_][A-Za-z0-9_?]*)} $l -> name]} {
                    set fn $name
                    set start $j
                    break
                }
            }
            # Its body after the construction: until the next column-0 code line.
            set body {}
            for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
                set l [lindex $lines $j]
                if {$fn ne "-" && [regexp {^[^\s#]} $l]} break
                lappend body $l
                if {$fn eq "-" && [llength $body] > 60} break
            }
            set text [join $body \n]
            set done [expr {[string first "done?(" $text] >= 0}]
            set sentinel [expr {[regexp {[!=]= -1\M} $text]}]
            set narrow [expr {[regexp {< 0 or [A-Za-z_.()0-9]+ > (255|127)} $text]}]
            set adopt [expr {[regexp {adopt\(|spawned\(} $text]}]
            set handled [expr {[string index [string trimright $line] end] eq ":"}]
            set rel [string range $f [string length $root]+1 end]
            lappend rows [list $rel [expr {$i + 1}] $fn $rootName $done $sentinel $narrow $adopt $handled]
            dict incr counts $dir
        }
    }
}
set fh [open $out w]
fconfigure $fh -encoding utf-8
puts $fh [join {file line function root done sentinel narrow adopt handled} \t]
foreach r $rows { puts $fh [join $r \t] }
close $fh
foreach {dir c} $counts { puts "$dir: $c sites" }
foreach key {done sentinel narrow adopt handled} idx {4 5 6 7 8} {
    set k 0
    foreach r $rows { incr k [lindex $r $idx] }
    puts "$key: $k of [llength $rows]"
}
