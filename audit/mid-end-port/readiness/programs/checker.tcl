# checker.tcl -- the Tcl reference of checker.bot
# (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 8): the same
# generator, typing rules,
# worklist order, diagnostic text and checksums, written the way tuned Tcl
# is (flat lists indexed by Int, `lset` in place, a dict for the scoped
# environment), so the two can be compared for results and for cost.
#
#   tclsh9.0 checker.tcl FUNCTIONS DEPTH
#
# Prints `checker NODES RECHECKS DIAGNOSTICS SUMMARY TEXT SECONDS`.

lassign $argv functions depth
if {$functions eq ""} { set functions 300 }
if {$depth eq ""} { set depth 6 }

proc next {seed} { expr {($seed * 1103515245 + 12345) % 2147483648} }

proc leaf {s nparams} {
    set pick [expr {$s % 10}]
    if {$pick < 4} { return [list IntLit [expr {$s % 50}]] }
    if {$pick == 4} { return [list BoolLit [expr {$s % 2 == 0}]] }
    if {$pick < 9} { return [list Name p[expr {$s % ($nparams + 1)}]] }
    return [list Name v]
}

# Appends the nodes of one tree to ::nodes; returns {index seed}.
proc gen {depth seed nparams functions} {
    set s1 [next $seed]
    set r [expr {$s1 % 100}]
    if {$depth == 0 || $r < 20} {
        set s2 [next $s1]
        lappend ::nodes [leaf $s2 $nparams]
        return [list [expr {[llength $::nodes] - 1}] $s2]
    }
    set d [expr {$depth - 1}]
    if {$r < 60} {
        lassign [gen $d $s1 $nparams $functions] a sa
        lassign [gen $d $sa $nparams $functions] b sb
        lappend ::nodes [list [expr {$r < 45 ? "Add" : "Less"}] $a $b]
        return [list [expr {[llength $::nodes] - 1}] $sb]
    }
    if {$r < 75} {
        lassign [gen $d $s1 $nparams $functions] c sc
        lassign [gen $d $sc $nparams $functions] y sy
        lassign [gen $d $sy $nparams $functions] n sn
        lappend ::nodes [list Cond $c $y $n]
        return [list [expr {[llength $::nodes] - 1}] $sn]
    }
    if {$r < 90} {
        set s2 [next $s1]
        set target [expr {$s2 % ($functions + 2)}]
        set count [expr {[next $s2] % 3}]
        lassign [gen $d [next $s2] $nparams $functions] first sf
        if {$count == 0} {
            lappend ::nodes [list Call $target {}]
            return [list [expr {[llength $::nodes] - 1}] $sf]
        }
        if {$count == 1} {
            lappend ::nodes [list Call $target [list $first]]
            return [list [expr {[llength $::nodes] - 1}] $sf]
        }
        lassign [gen $d $sf $nparams $functions] second ss
        lappend ::nodes [list Call $target [list $first $second]]
        return [list [expr {[llength $::nodes] - 1}] $ss]
    }
    lassign [gen $d $s1 $nparams $functions] v sv
    lassign [gen $d $sv $nparams $functions] body sb
    lappend ::nodes [list Let v $v $body]
    return [list [expr {[llength $::nodes] - 1}] $sb]
}

proc join_ {a b} {
    if {$a eq "unknown"} { return $b }
    if {$b eq "unknown"} { return $a }
    if {$a eq $b} { return $a }
    return poison
}

proc diagnose {e code message} {
    if {$::report} {
        lappend ::out [list $::caller $e $code $message]
    }
    return poison
}

proc operands {e a b result op} {
    if {$a eq "poison" || $b eq "poison"} { return poison }
    if {$a eq "unknown" || $b eq "unknown"} { return unknown }
    if {$a eq "int" && $b eq "int"} { return $result }
    return [diagnose $e 2 "operands of $op have types $a and $b"]
}

# The checker; ENV is the caller's scoped environment (a dict, by name).
proc check {e envVar} {
    upvar 1 $envVar env
    set node [lindex $::nodes $e]
    switch -- [lindex $node 0] {
        IntLit { return int }
        BoolLit { return bool }
        Name {
            set name [lindex $node 1]
            if {[dict exists $env $name]} { return [dict get $env $name] }
            return [diagnose $e 1 "unbound name $name"]
        }
        Add - Less {
            set a [check [lindex $node 1] env]
            set b [check [lindex $node 2] env]
            if {[lindex $node 0] eq "Add"} {
                return [operands $e $a $b int +]
            }
            return [operands $e $a $b bool <]
        }
        Cond {
            set c [check [lindex $node 1] env]
            set y [check [lindex $node 2] env]
            set n [check [lindex $node 3] env]
            if {$c eq "poison" || $c eq "unknown"} { return $c }
            if {$c ne "bool"} { return [diagnose $e 3 "condition has type $c"] }
            return [join_ $y $n]
        }
        Call {
            set target [lindex $node 1]
            set arguments {}
            foreach a [lindex $node 2] { lappend arguments [check $a env] }
            if {$target >= [llength $::funcs]} {
                return [diagnose $e 4 "unknown function f$target"]
            }
            lassign [lindex $::funcs $target] cname - ctypes
            if {[llength $arguments] != [llength $ctypes]} {
                return [diagnose $e 5 "$cname takes [llength $ctypes] arguments, got [llength $arguments]"]
            }
            set i 0
            foreach a $arguments p $ctypes {
                if {$a eq "poison"} { return poison }
                if {$a ne "unknown" && $a ne $p} {
                    return [diagnose $e 2 "argument $i of $cname has type $a"]
                }
                incr i
            }
            return [lindex $::summaries $target]
        }
        Let {
            lassign $node - name value body
            set t [check $value env]
            set had [dict exists $env $name]
            if {$had} { set saved [dict get $env $name] }
            dict set env $name $t
            set result [check $body env]
            if {$had} { dict set env $name $saved } else { dict unset env $name }
            return $result
        }
    }
}

proc checkFunction {f report} {
    lassign [lindex $::funcs $f] name params types body
    set ::caller $name
    set ::report $report
    set env [dict create]
    foreach p $params t $types { dict set env $p $t }
    return [check $body env]
}

proc collectCalls {e caller functions} {
    set node [lindex $::nodes $e]
    switch -- [lindex $node 0] {
        Add - Less { collectCalls [lindex $node 1] $caller $functions; collectCalls [lindex $node 2] $caller $functions }
        Cond { foreach i {1 2 3} { collectCalls [lindex $node $i] $caller $functions } }
        Call {
            foreach a [lindex $node 2] { collectCalls $a $caller $functions }
            if {[lindex $node 1] < $functions} {
                lappend ::from [lindex $node 1]
                lappend ::to $caller
            }
        }
        Let { collectCalls [lindex $node 2] $caller $functions; collectCalls [lindex $node 3] $caller $functions }
    }
}

proc textSum {s h} {
    foreach c [split $s ""] {
        set h [expr {($h * 131 + [scan $c %c]) % 1000000007}]
    }
    return $h
}

proc before {x y} {
    lassign $x fx nx cx
    lassign $y fy ny cy
    if {$fx ne $fy} { return [expr {[string compare $fx $fy] < 0 ? -1 : 1}] }
    if {$nx != $ny} { return [expr {$nx < $ny ? -1 : 1}] }
    if {$cx != $cy} { return [expr {$cx < $cy ? -1 : 1}] }
    return 0
}

set t0 [clock microseconds]
set nodes {}
set funcs {}
set seed 7
for {set i 0} {$i < $functions} {incr i} {
    set nparams [expr {$i % 3}]
    lassign [gen $depth $seed $nparams $functions] index seed
    set params {}; set types {}
    for {set j 0} {$j < $nparams} {incr j} {
        lappend params p$j
        lappend types [expr {($i + $j) % 4 == 0 ? "bool" : "int"}]
    }
    lappend funcs [list f$i $params $types $index]
}
set from {}; set to {}
for {set f 0} {$f < $functions} {incr f} {
    collectCalls [lindex $funcs $f 3] $f $functions
}
set counts [lrepeat [expr {$functions + 1}] 0]
foreach t $from { lset counts [expr {$t + 1}] [expr {[lindex $counts [expr {$t + 1}]] + 1}] }
set start [lrepeat [expr {$functions + 1}] 0]
for {set f 0} {$f < $functions} {incr f} {
    lset start [expr {$f + 1}] [expr {[lindex $start $f] + [lindex $counts [expr {$f + 1}]]}]
}
set fill $start
set callers [lrepeat [llength $from] 0]
foreach t $from c $to {
    set slot [lindex $fill $t]
    lset callers $slot $c
    lset fill $t [expr {$slot + 1}]
}
set queue {}
for {set f 0} {$f < $functions} {incr f} { lappend queue $f }
set queued [lrepeat $functions 1]
set summaries [lrepeat $functions unknown]
set out {}
set rechecks 0
for {set head 0} {$head < [llength $queue]} {incr head} {
    set f [lindex $queue $head]
    lset queued $f 0
    set t [checkFunction $f 0]
    set old [lindex $summaries $f]
    set updated [join_ $old $t]
    if {$updated ne $old} {
        lset summaries $f $updated
        for {set k [lindex $start $f]} {$k < [lindex $start [expr {$f + 1}]]} {incr k} {
            set c [lindex $callers $k]
            if {![lindex $queued $c]} {
                lset queued $c 1
                lappend queue $c
            }
        }
    }
    incr rechecks
}
for {set f 0} {$f < $functions} {incr f} { checkFunction $f 1 }
set out [lsort -command before $out]
set numbers [dict create unknown 0 int 1 bool 2 poison 4]
set summary 0
foreach s $summaries { set summary [expr {($summary * 7 + [dict get $numbers $s]) % 1000000007}] }
set text 0
foreach d $out {
    lassign $d fname node code message
    set text [textSum "$fname:$node: \[$code\] $message" $text]
}
set seconds [expr {([clock microseconds] - $t0) / 1e6}]
puts [format "checker %d %d %d %d %d %.3fs" [llength $nodes] $rechecks [llength $out] $summary $text $seconds]
