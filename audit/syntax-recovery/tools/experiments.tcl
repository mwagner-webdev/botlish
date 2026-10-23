# experiments.tcl -- the syntax-recovery experiments
# (SYNTAX-RECOVERY-MILESTONE-1.md, section 2): what the compiler service
# knows about each malformed program of audit/syntax-recovery/experiments/
# and about two line-preserving repairs of it.
#
#   tclsh9.0 audit/syntax-recovery/tools/experiments.tcl ?-root DIR? ?-cases A,B? ?-out FILE?
#
# A case is a directory: the program (main.bot, its modules), `probes` (one
# line per position: FILE LINE COLUMN EXPECT NOTE, EXPECT `known` or
# `unavailable`: what the malformed program's analysis must say there), and
# repair-1/ and repair-2/, files that replace the malformed ones with two
# different completions of the same lines. For the program and each repair
# the tool prints the analysis's outcome and diagnostics and, at every probe,
# the binding and type the service answers, or why it has none. The repairs
# are the dependency oracle: a fact the two repairs disagree on must not be
# known in the malformed program; a fact both repairs and the malformed
# program share is what recovery keeps.
#
# -root DIR analyzes with another checkout's compiler (the tree before the
# milestone, for its "before" column).

set here [file dirname [file normalize [info script]]]
set options [dict create -root [file dirname [file dirname [file dirname $here]]] -cases "" -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        puts stderr "usage: experiments.tcl ?-root DIR? ?-cases A,B? ?-out FILE?"
        exit 2
    }
    dict set options $option $value
}
set root [file normalize [dict get $options -root]]
source [file join $root service service.tcl]
interp recursionlimit {} 100000
set experiments [file join [file dirname $here] experiments]

proc Copy {from to} {
    foreach path [glob -nocomplain -directory $from -types f *.bot] {
        file copy -force $path [file join $to [file tail $path]]
    }
}

# One line per fact at the probe.
proc Probe {rev dir file line column} {
    if {[catch {service::at $rev [file join $dir $file] $line $column} facts]} {
        return "error: $facts"
    }
    set unavailable [dict get $facts unavailable]
    set parts {}
    if {[dict exists $facts binding]} {
        lappend parts "binding [dict get $facts binding name]"
    } elseif {[dict exists $unavailable binding]} {
        lappend parts "binding -"
    }
    if {[dict exists $facts type]} {
        lappend parts "type [dict get $facts type text]"
    } elseif {[dict exists $unavailable type]} {
        lappend parts "type - ([dict get $unavailable type])"
    }
    return [join $parts "; "]
}

proc Analyze {dir} {
    set ws [service::workspace -warnings off -cache ""]
    set rev [service::analyze $ws [file join $dir main.bot]]
    set summary [service::revision $rev]
    set semantics [dict getdef $summary semantics [expr {[dict get $summary hir] ? "full" : "none"}]]
    set lines [list "outcome [dict get $summary outcome], semantics $semantics"]
    foreach d [service::diagnostics $rev] {
        set where none
        if {[dict get $d range] ne "none"} {
            set where "[file tail [dict get $d file]]:[dict get $d line]:[dict get $d column]"
        }
        lappend lines "  [dict get $d severity] $where [dict get $d code]: [dict get $d message]"
    }
    return [list $ws $rev $lines]
}

set cases [lsort [glob -directory $experiments -types d *]]
if {[dict get $options -cases] ne ""} {
    set wanted [split [dict get $options -cases] ,]
    set cases [lmap c $cases {if {[file tail $c] in $wanted} {set c} else continue}]
}
set out {}
lappend out "# syntax-recovery experiments, compiler at $root"
foreach case $cases {
    set name [file tail $case]
    lappend out "" "## $name"
    set probes {}
    set f [open [file join $case probes]]
    foreach line [split [read $f] \n] {
        if {[string trim $line] eq ""} continue
        lappend probes $line
    }
    close $f
    foreach variant {malformed repair-1 repair-2} {
        set dir [file join [file normalize [file tempdir]] $name-$variant]
        file mkdir $dir
        Copy $case $dir
        if {$variant ne "malformed"} {
            Copy [file join $case $variant] $dir
        }
        lassign [Analyze $dir] ws rev lines
        lappend out "### $variant" {*}$lines
        foreach probe $probes {
            set fields [split $probe " "]
            lassign $fields file line column expect
            set note [join [lrange $fields 4 end] " "]
            set answer [Probe $rev $dir $file $line $column]
            if {$variant eq "malformed"} {
                lappend out "  $file:$line:$column (expect $expect: $note) => $answer"
            } else {
                lappend out "  $file:$line:$column => $answer"
            }
        }
        service::closeWorkspace $ws
        file delete -force [file dirname $dir]
    }
}
set text [join $out \n]\n
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    puts -nonewline $f $text
    close $f
} else {
    puts -nonewline $text
}
