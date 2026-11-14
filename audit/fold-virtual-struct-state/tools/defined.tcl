# defined.tcl -- FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1.md's definedness
# check of NIR text: every register an instruction reads is defined on every
# path from the function's entry to it. The driver's validator checks NIR's
# structure, not this (FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md, section 11);
# this check is independent of it and of the compiler: it reads only the NIR
# text.
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/defined.tcl FILE.nir|FILE.bot ...
#
# A .bot file is compiled first (native::lowered, default options; -options
# {...} before the files gives others). Prints one line per violation
# (function, instruction, register) and a summary; exits 1 on any.
#
# The analysis is a forward must-analysis over the function's blocks (a
# label starts one, a terminator ends one): a register is defined at entry
# when it is a parameter; an instruction's destination registers are
# defined after it; a block's state is the intersection of its
# predecessors'. Edges: br, switch and jump to their labels; every other
# instruction falls through unless it is a terminator; and every
# instruction inside a pusherrorexit/poperrorexit span may reach the span's
# handler label before its destinations are defined (a superset of the
# instructions that can fail, as nir.rs's validate_plans assumes). tail and
# tailenv restart the function, whose entry state is its parameters: no
# edge needed. An instruction naming a label the check does not know is an
# error of the check, never ignored.
#
# Also usable as a library: `source` it with ::definedLibrary set, then call
# defined::check TEXT, which returns the violations as a list.

namespace eval defined {}

# The tokens of one NIR line, minus quoted strings, key=value pairs and the
# trailing @eN position: {words...} with registers as %N.
proc defined::Tokens {line} {
    set tokens {}
    set n [string length $line]
    set i 0
    while {$i < $n} {
        set c [string index $line $i]
        if {[string is space $c]} { incr i; continue }
        if {$c eq "@"} { break }
        if {$c eq "\""} {
            incr i
            while {$i < $n} {
                set d [string index $line $i]
                if {$d eq "\\"} { incr i 2; continue }
                incr i
                if {$d eq "\""} break
            }
            continue
        }
        set start $i
        set pair 0
        while {$i < $n && ![string is space [string index $line $i]]} {
            if {[string index $line $i] eq "=" && $i > $start} {
                # key=value: skip the value, quoted or not.
                set pair 1
                incr i
                if {[string index $line $i] eq "\""} {
                    incr i
                    while {$i < $n} {
                        set d [string index $line $i]
                        if {$d eq "\\"} { incr i 2; continue }
                        incr i
                        if {$d eq "\""} break
                    }
                } else {
                    while {$i < $n && ![string is space [string index $line $i]]} { incr i }
                }
                break
            }
            incr i
        }
        if {!$pair} { lappend tokens [string range $line $start [expr {$i - 1}]] }
    }
    return $tokens
}

# The violations of the NIR TEXT: a list of {FUNCTION INDEX REGISTER LINE}.
proc defined::check {text} {
    set violations {}
    set function ""
    set body {}
    foreach line [split $text \n] {
        if {[regexp {^func (\d+) "([^"]*)" params=(\d+)} $line -> id name params]} {
            set function [list $id $name $params]
            set body {}
            continue
        }
        if {$line eq "end" && $function ne ""} {
            lappend violations {*}[Function {*}$function $body]
            set function ""
            continue
        }
        if {$function ne ""} { lappend body [string trim $line] }
    }
    return $violations
}

proc defined::Function {id name params body} {
    set terminators {tail tailenv br switch jump ret retmulti raise unreachable faildeclared reraise}
    set insts {}
    set labels [dict create]
    set handlers {}
    set stack {}
    set i 0
    foreach line $body {
        set tokens [Tokens $line]
        set defs {}
        set k 0
        while {$k < [llength $tokens] && [string match {%*} [lindex $tokens $k]]} {
            lappend defs [string range [lindex $tokens $k] 1 end]
            incr k
        }
        if {$defs ne ""} {
            if {[lindex $tokens $k] ne "="} { error "$name: malformed line: $line" }
            incr k
        }
        set op [lindex $tokens $k]
        set uses {}
        set targets {}
        foreach t [lrange $tokens [expr {$k + 1}] end] {
            if {[string match {%*} $t]} {
                lappend uses [string range $t 1 end]
            } elseif {[regexp {^L(\d+)$} $t -> l] || [regexp {^-?\d+:-?\d+:L(\d+)$} $t -> l]} {
                lappend targets $l
            }
        }
        switch -- $op {
            label {
                dict set labels [lindex $targets 0] $i
                set targets {}
            }
            pusherrorexit { lappend stack [lindex $targets 0]; set targets {} }
            poperrorexit { set stack [lrange $stack 0 end-1] }
            br - switch - jump {}
            default {
                if {$targets ne ""} { error "$name: unknown label-bearing instruction: $line" }
            }
        }
        lappend handlers [lindex $stack end]
        lappend insts [list $op $defs $uses $targets $line]
        incr i
    }
    set n [llength $insts]
    # Blocks.
    set starts [list 0]
    for {set i 0} {$i < $n} {incr i} {
        set op [lindex $insts $i 0]
        if {$op eq "label" && $i != 0} { lappend starts $i }
        if {$op in $terminators && $i + 1 < $n} { lappend starts [expr {$i + 1}] }
    }
    set starts [lsort -integer -unique $starts]
    set blockOf [dict create]
    set b 0
    for {set i 0} {$i < $n} {incr i} {
        if {$b + 1 < [llength $starts] && [lindex $starts [expr {$b + 1}]] == $i} { incr b }
        dict set blockOf $i $b
    }
    set nblocks [llength $starts]
    # State: a dict of defined registers (NONE for "no path yet").
    set entry [dict create]
    for {set r 0} {$r < $params} {incr r} { dict set entry $r 1 }
    set in [lrepeat $nblocks NONE]
    lset in 0 $entry
    set work [list 0]
    set seen [dict create]
    while {[llength $work]} {
        set b [lindex $work end]
        set work [lrange $work 0 end-1]
        set state [lindex $in $b]
        set start [lindex $starts $b]
        set end [expr {$b + 1 < $nblocks ? [lindex $starts [expr {$b + 1}]] : $n}]
        set fall 1
        for {set i $start} {$i < $end} {incr i} {
            lassign [lindex $insts $i] op defs uses targets line
            foreach r $uses {
                if {![dict exists $state $r] && ![dict exists $seen "$i $r"]} {
                    dict set seen "$i $r" [list $id/$name $i $r $line]
                }
            }
            set h [lindex $handlers $i]
            if {$h ne "" && $op ni {pusherrorexit poperrorexit label}} {
                set succ [list [dict get $blockOf [dict get $labels $h]]]
                foreach s $succ { Merge in work $s $state }
            }
            foreach r $defs { dict set state $r 1 }
            foreach l $targets {
                if {![dict exists $labels $l]} { error "$name: undefined label L$l" }
                Merge in work [dict get $blockOf [dict get $labels $l]] $state
            }
            if {$op in $terminators} { set fall 0 }
        }
        if {$fall && $b + 1 < $nblocks} { Merge in work [expr {$b + 1}] $state }
    }
    # A use reported on an early, partial pass may be defined once every
    # predecessor has merged in: recheck the reported ones against the final
    # states.
    set result {}
    dict for {key v} $seen {
        lassign $key i r
        set b [dict get $blockOf $i]
        set state [lindex $in $b]
        if {$state eq "NONE"} continue
        set start [lindex $starts $b]
        for {set j $start} {$j < $i} {incr j} {
            foreach d [lindex $insts $j 1] { dict set state $d 1 }
        }
        if {![dict exists $state $r]} { lappend result $v }
    }
    return $result
}

# Merges STATE into block S's entry state (intersection), queueing S when it
# changes.
proc defined::Merge {inVar workVar s state} {
    upvar 1 $inVar in $workVar work
    set old [lindex $in $s]
    if {$old eq "NONE"} {
        lset in $s $state
        lappend work $s
        return
    }
    set new [dict create]
    dict for {r v} $old {
        if {[dict exists $state $r]} { dict set new $r 1 }
    }
    if {[dict size $new] != [dict size $old]} {
        lset in $s $new
        lappend work $s
    }
}

if {[info exists ::definedLibrary]} return

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options {}
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {$a eq "-options"} { set options [lindex $argv [incr i]]; continue }
    lappend files $a
}
set argv {}
set compiled 0
set total 0
set functions 0
foreach path $files {
    if {[file extension $path] eq ".bot"} {
        if {!$compiled} {
            source [file join $root tests helpers.tcl]
            source [file join $root surface surface.tcl]
            set compiled 1
        }
        set hir [surface::readProgramFile $path -warnings off]
        set text [dict get [native::lowered $hir {*}$options] text]
    } else {
        set channel [open $path r]
        set text [read $channel]
        close $channel
    }
    incr functions [regexp -all -line {^func } $text]
    foreach v [defined::check $text] {
        lassign $v function index register line
        puts "UNDEFINED $path: function $function, instruction $index reads %$register on some path: $line"
        incr total
    }
}
puts "[llength $files] programs, $functions functions, $total undefined reads"
exit [expr {$total > 0}]
