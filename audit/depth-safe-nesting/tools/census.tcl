# census.tcl -- which procedures recurse as deep as a program nests
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md).
#
#   tclsh9.0 audit/depth-safe-nesting/tools/census.tcl ?-depth N?
#       ?-kinds KIND,...? ?-scenarios NAME,...? ?-fraction F? ?-out FILE?
#
# Traces every procedure of the compiler (surface, hir, core's IR check and
# Tcl compiler, native lowering, the service) while each specimen kind N deep
# (specimens.tcl; 24 by default) goes through each scenario (scenarios.tcl),
# counting each procedure's simultaneous activations. A procedure active at
# least N/F times at once (F 2 by default; a specimen that cycles through K
# forms, such as `loops`, shows a procedure of one form N/K times: use F
# at least K) recurses with the program's nesting: the census
# (audit/depth-safe-nesting/census.tsv) must list it, and it must start with
# the guard (core/deep.tcl). Prints, per procedure found, its deepest count,
# the kind and scenario that showed it and whether the census lists it; exit
# status 1 if one is missing. The reference interpreter's evaluation and the
# runtime's calls are left out: they are a program's run, not its
# compilation (the milestone's report, "The run").

set options [dict create -depth 24 -kinds "" -scenarios "" -fraction 2 -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "unknown option $option"
    }
    dict set options $option $value
}
set ::dsnOptions $options
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
source [file join $root service service.tcl]
source [file join $here specimens.tcl]
source [file join $here scenarios.tcl]
set options $::dsnOptions
interp recursionlimit {} 1000000
# Plain recursion, no segments: each activation is counted where it runs.
lassign {1000000 1000000 1000000} core::deep::segment core::deep::outside core::deep::bound

proc AllProcs {ns} {
    set out [info procs ${ns}::*]
    foreach child [namespace children $ns] {
        lappend out {*}[AllProcs $child]
    }
    return $out
}

set listed {}
set f [open [file join $root audit depth-safe-nesting census.tsv] r]
foreach line [split [read $f] \n] {
    if {$line ne "" && [string index $line 0] ne "#"} {
        lappend listed [lindex [split $line \t] 0]
    }
}
close $f

array set active {}
array set deepest {}
array set where {}
set ::current ""
proc Enter {name args} {
    set n [incr ::active($name)]
    if {![info exists ::deepest($name)] || $n > $::deepest($name)} {
        set ::deepest($name) $n
        set ::where($name) $::current
    }
}
proc Leave {name args} {
    incr ::active($name) -1
}
set traced {}
foreach ns {::surface ::hir ::native ::core::compiler ::core::ir ::service} {
    foreach p [AllProcs $ns] {
        if {[string match ::core::deep::* $p]} {
            continue
        }
        trace add execution $p enter [list Enter $p]
        trace add execution $p leave [list Leave $p]
        lappend traced $p
    }
}

set kinds [expr {[dict get $options -kinds] eq "" ? [dsn::kinds] : [split [dict get $options -kinds] ,]}]
set names [expr {[dict get $options -scenarios] eq "" ? [dict keys $dsn::scenarios] : [split [dict get $options -scenarios] ,]}]
set depth [dict get $options -depth]
set dir [file tempdir dsn-census]
foreach kind $kinds {
    set source [dict get [dsn::specimen $kind $depth] source]
    foreach name $names {
        set ::current "$kind/$name"
        if {[catch [dict get $dsn::scenarios $name] result info]} {
            puts stderr "$kind $name: [lrange [dict get $info -errorcode] 0 2] [string range $result 0 120]"
        }
        array unset active
    }
}
file delete -force $dir

set missing 0
set rows {}
foreach name [array names deepest] {
    if {$deepest($name) * [dict get $options -fraction] >= $depth} {
        set inCensus [expr {$name in $listed}]
        if {!$inCensus} {
            incr missing
        }
        lappend rows [list $name $deepest($name) $where($name) [expr {$inCensus ? "listed" : "MISSING"}]]
    }
}
set out [expr {[dict get $options -out] eq "" ? "stdout" : [open [dict get $options -out] w]}]
foreach row [lsort -index 0 $rows] {
    puts $out [join $row \t]
}
puts $out "# [llength $rows] procedures recurse with the nesting, $missing missing from the census"
if {$out ne "stdout"} {
    close $out
}
exit [expr {$missing > 0}]
