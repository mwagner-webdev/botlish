# ranges.tcl -- the mid-end-shaped kernel (audit/mid-end-port/README.md,
# "The kernel") in Tcl, the same analysis and value as ranges-structs.bot:
#
#   tclsh9.0 ranges.tcl dict|list|tables FUNCTIONS DEPTH
#
#   dict    hir/'s style: a dict of node dicts keyed by "eN" (the HIR's
#           `exprs`), the summaries in it, the ranges in a side-table dict
#           reached through upvar; each evaluation returns a {lo hi} pair
#   list    tuned Tcl: flat lists indexed by Int, lset in place; each
#           evaluation returns a {lo hi} pair (ranges-structs.bot's shape)
#   tables  flat lists, the results only in the side tables; each evaluation
#           returns the node's index (ranges-tables.bot's shape)
#
# Prints `MODE NODES ROUNDS CHECKSUM SECONDSs`.
set mode [lindex $argv 0]
set functions [lindex $argv 1]
set depth [lindex $argv 2]
set big 1000000000

proc next {seed} { expr {($seed * 1103515245 + 12345) % 2147483648} }

# ---------------------------------------------------------------- dict mode
proc genD {d seed} {
    upvar 1 exprs exprs count count
    set s1 [next $seed]
    set r [expr {$s1 % 100}]
    if {$d == 0 || $r < 25} {
        set s2 [next $s1]
        set pick [expr {$s2 % 3}]
        if {$pick == 0} {
            set node [dict create kind const a [expr {$s2 % 100}]]
        } elseif {$pick == 1} {
            set node [dict create kind param]
        } else {
            set node [dict create kind call a [expr {$s2 % $::functions}]]
        }
        set e e$count
        dict set exprs $e $node
        incr count
        return [list $e $s2]
    }
    if {$r < 65} {
        lassign [genD [expr {$d - 1}] $s1] left s
        lassign [genD [expr {$d - 1}] $s] right s
        set e e$count
        dict set exprs $e [dict create kind add a $left b $right]
        incr count
        return [list $e $s]
    }
    lassign [genD [expr {$d - 1}] $s1] cond s
    lassign [genD [expr {$d - 1}] $s] yes s
    lassign [genD [expr {$d - 1}] $s] no s
    set e e$count
    dict set exprs $e [dict create kind if a $cond b $yes c $no]
    incr count
    return [list $e $s]
}

proc evalD {hir e} {
    upvar 1 ranges ranges
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const {
            set a [dict get $node a]
            set r [list $a $a]
        }
        param { set r {0 10} }
        call { set r [dict get $hir summaries [dict get $node a]] }
        add {
            lassign [evalD $hir [dict get $node a]] xl xh
            lassign [evalD $hir [dict get $node b]] yl yh
            set r [list [expr {max(-$::big, $xl + $yl)}] [expr {min($::big, $xh + $yh)}]]
        }
        if {
            evalD $hir [dict get $node a]
            lassign [evalD $hir [dict get $node b]] xl xh
            lassign [evalD $hir [dict get $node c]] yl yh
            set r [list [expr {min($xl, $yl)}] [expr {max($xh, $yh)}]]
        }
    }
    dict set ranges $e $r
    return $r
}

proc runD {} {
    set exprs [dict create e0 [dict create kind const a 0]]
    set count 1
    set roots {}
    set seed 42
    for {set f 0} {$f < $::functions} {incr f} {
        lassign [genD $::depth $seed] root seed
        lappend roots $root
    }
    set hir [dict create exprs $exprs summaries {}]
    unset exprs
    for {set f 0} {$f < $::functions} {incr f} {
        dict set hir summaries $f {0 0}
    }
    set ranges [dict create]
    set n 0
    while 1 {
        set changed 0
        for {set f 0} {$f < $::functions} {incr f} {
            lassign [evalD $hir [lindex $roots $f]] rl rh
            lassign [dict get $hir summaries $f] ol oh
            set jl [expr {min($ol, $rl)}]
            set jh [expr {max($oh, $rh)}]
            set nl [expr {$n >= 6 && $jl < $ol ? -$::big : $jl}]
            set nh [expr {$n >= 6 && $jh > $oh ? $::big : $jh}]
            if {$nl == $ol && $nh == $oh} continue
            dict set hir summaries $f [list $nl $nh]
            set changed 1
        }
        if {!$changed || $n == 30} break
        incr n
    }
    set check 0
    for {set i 0} {$i < $count} {incr i} {
        lassign [dict getdef $ranges e$i {0 0}] l h
        set check [expr {($check * 31 + $l * 3 + $h * 7) % 1000000007}]
    }
    return [list $count [expr {$n + 1}] $check]
}

# ---------------------------------------------------------------- list mode
proc genL {d seed} {
    upvar 1 kinds kinds as as bs bs cs cs
    set s1 [next $seed]
    set r [expr {$s1 % 100}]
    if {$d == 0 || $r < 25} {
        set s2 [next $s1]
        set pick [expr {$s2 % 3}]
        if {$pick == 0} {
            lappend kinds 0; lappend as [expr {$s2 % 100}]
        } elseif {$pick == 1} {
            lappend kinds 1; lappend as 0
        } else {
            lappend kinds 4; lappend as [expr {$s2 % $::functions}]
        }
        lappend bs 0; lappend cs 0
        return [list [expr {[llength $kinds] - 1}] $s2]
    }
    if {$r < 65} {
        lassign [genL [expr {$d - 1}] $s1] left s
        lassign [genL [expr {$d - 1}] $s] right s
        lappend kinds 2; lappend as $left; lappend bs $right; lappend cs 0
        return [list [expr {[llength $kinds] - 1}] $s]
    }
    lassign [genL [expr {$d - 1}] $s1] cond s
    lassign [genL [expr {$d - 1}] $s] yes s
    lassign [genL [expr {$d - 1}] $s] no s
    lappend kinds 3; lappend as $cond; lappend bs $yes; lappend cs $no
    return [list [expr {[llength $kinds] - 1}] $s]
}

proc evalL {i} {
    upvar 1 kinds kinds as as bs bs cs cs sumlo sumlo sumhi sumhi lo lo hi hi
    switch -- [lindex $kinds $i] {
        0 { set a [lindex $as $i]; set rl $a; set rh $a }
        1 { set rl 0; set rh 10 }
        4 { set a [lindex $as $i]; set rl [lindex $sumlo $a]; set rh [lindex $sumhi $a] }
        2 {
            lassign [evalL [lindex $as $i]] xl xh
            lassign [evalL [lindex $bs $i]] yl yh
            set rl [expr {max(-$::big, $xl + $yl)}]
            set rh [expr {min($::big, $xh + $yh)}]
        }
        3 {
            evalL [lindex $as $i]
            lassign [evalL [lindex $bs $i]] xl xh
            lassign [evalL [lindex $cs $i]] yl yh
            set rl [expr {min($xl, $yl)}]
            set rh [expr {max($xh, $yh)}]
        }
    }
    lset lo $i $rl
    lset hi $i $rh
    return [list $rl $rh]
}

proc runL {} {
    set kinds {0}; set as {0}; set bs {0}; set cs {0}
    set roots {}
    set seed 42
    for {set f 0} {$f < $::functions} {incr f} {
        lassign [genL $::depth $seed] root seed
        lappend roots $root
    }
    set count [llength $kinds]
    set sumlo [lrepeat $::functions 0]
    set sumhi [lrepeat $::functions 0]
    set lo [lrepeat $count 0]
    set hi [lrepeat $count 0]
    set n 0
    while 1 {
        set changed 0
        for {set f 0} {$f < $::functions} {incr f} {
            lassign [evalL [lindex $roots $f]] rl rh
            set ol [lindex $sumlo $f]; set oh [lindex $sumhi $f]
            set jl [expr {min($ol, $rl)}]
            set jh [expr {max($oh, $rh)}]
            set nl [expr {$n >= 6 && $jl < $ol ? -$::big : $jl}]
            set nh [expr {$n >= 6 && $jh > $oh ? $::big : $jh}]
            if {$nl == $ol && $nh == $oh} continue
            lset sumlo $f $nl; lset sumhi $f $nh
            set changed 1
        }
        if {!$changed || $n == 30} break
        incr n
    }
    set check 0
    for {set i 0} {$i < $count} {incr i} {
        set check [expr {($check * 31 + [lindex $lo $i] * 3 + [lindex $hi $i] * 7) % 1000000007}]
    }
    return [list $count [expr {$n + 1}] $check]
}

proc evalT {i} {
    upvar 1 kinds kinds as as bs bs cs cs sumlo sumlo sumhi sumhi lo lo hi hi
    switch -- [lindex $kinds $i] {
        0 { set a [lindex $as $i]; lset lo $i $a; lset hi $i $a }
        1 { lset lo $i 0; lset hi $i 10 }
        4 { set a [lindex $as $i]; lset lo $i [lindex $sumlo $a]; lset hi $i [lindex $sumhi $a] }
        2 {
            set x [evalT [lindex $as $i]]
            set y [evalT [lindex $bs $i]]
            lset lo $i [expr {max(-$::big, [lindex $lo $x] + [lindex $lo $y])}]
            lset hi $i [expr {min($::big, [lindex $hi $x] + [lindex $hi $y])}]
        }
        3 {
            evalT [lindex $as $i]
            set x [evalT [lindex $bs $i]]
            set y [evalT [lindex $cs $i]]
            lset lo $i [expr {min([lindex $lo $x], [lindex $lo $y])}]
            lset hi $i [expr {max([lindex $hi $x], [lindex $hi $y])}]
        }
    }
    return $i
}

proc runT {} {
    set kinds {0}; set as {0}; set bs {0}; set cs {0}
    set roots {}
    set seed 42
    for {set f 0} {$f < $::functions} {incr f} {
        lassign [genL $::depth $seed] root seed
        lappend roots $root
    }
    set count [llength $kinds]
    set sumlo [lrepeat $::functions 0]
    set sumhi [lrepeat $::functions 0]
    set lo [lrepeat $count 0]
    set hi [lrepeat $count 0]
    set n 0
    while 1 {
        set changed 0
        for {set f 0} {$f < $::functions} {incr f} {
            set root [evalT [lindex $roots $f]]; set rl [lindex $lo $root]; set rh [lindex $hi $root]
            set ol [lindex $sumlo $f]; set oh [lindex $sumhi $f]
            set jl [expr {min($ol, $rl)}]
            set jh [expr {max($oh, $rh)}]
            set nl [expr {$n >= 6 && $jl < $ol ? -$::big : $jl}]
            set nh [expr {$n >= 6 && $jh > $oh ? $::big : $jh}]
            if {$nl == $ol && $nh == $oh} continue
            lset sumlo $f $nl; lset sumhi $f $nh
            set changed 1
        }
        if {!$changed || $n == 30} break
        incr n
    }
    set check 0
    for {set i 0} {$i < $count} {incr i} {
        set check [expr {($check * 31 + [lindex $lo $i] * 3 + [lindex $hi $i] * 7) % 1000000007}]
    }
    return [list $count [expr {$n + 1}] $check]
}

set t0 [clock microseconds]
switch -- $mode {
    dict { set result [runD] }
    list { set result [runL] }
    tables { set result [runT] }
    default { error "ranges.tcl: the mode is dict, list or tables" }
}
puts "$mode $result [format %.3f [expr {([clock microseconds] - $t0) / 1e6}]]s"
