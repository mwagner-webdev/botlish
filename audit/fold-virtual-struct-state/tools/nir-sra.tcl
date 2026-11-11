# nir-sra.tcl -- FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md's NIR experiment: a
# NIR-to-NIR scalar replacement of struct register webs, applied to the NIR
# the current compiler emits, to measure what carrying a fold's struct
# intermediate as field registers would save before anything is built in
# the compiler. It is an audit instrument, never a pass: nothing in the
# compiler or the driver loads it, and its output is NIR text the driver
# runs as it runs any other (`botlish-native run|bench FILE.nir`), with the
# driver's own validation (nir.rs: registers, plans, effects).
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/nir-sra.tcl \
#       ?-functions "NAME ..."? ?-plan-field SHAPE.FIELD ...? \
#       ?-return-fields NAME:SHAPE ...? IN.nir OUT.nir
#
# A *web* is a set of registers of one function connected by `move`, every
# definition of which is a `structnew` of one shape or a `move` from a
# register of the web (a fold's intermediate: its initial value, the
# body's completions through the `if` joins' result registers, the back
# edge, the fold's result register). Such a web is rewritten so that every
# member R becomes N field registers R.0 .. R.N-1:
#
#   %R = structnew S A0 .. An-1  ->  %R.i = move %Ai           (no object)
#   %R = move %Q                 ->  %R.i = move %Q.i
#   %D = structget K %R          ->  %D = move %R.K
#   any other use of %R          ->  %R = structnew S %R.0 .. %R.N-1, then
#                                    the use (the object built there: a
#                                    materialization at the use, as the
#                                    struct scalar replacement's lazy
#                                    materialization would, but once per
#                                    such use, not once per scope)
#
# A web is left alone when one of its registers has another definition (a
# call result, a structget of another struct) or two shapes meet in it.
# -functions limits the rewrite to the named functions (default: every
# function).
#
# -plan-field SHAPE.FIELD (repeatable) additionally carries that field of a
# rewritten web of shape index SHAPE as a List *construction plan*
# (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md): its field registers are
# declared in the function's `planregs=`, `op listappend %F X` of a plan
# field register becomes `construct list plan %F elem X`, a `construct list
# flat %F PIECES` whose first piece is one becomes `construct list plan %F
# PIECES`, and any other use of a plan field register reads `construct
# list flat %F` first (its one materialization). This is the representation
# FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md gives a direct List
# intermediate, applied to a field of the scalar-replaced struct. The
# driver's validate_plans then checks, as for any NIR, that no path
# consumes a plan register twice: the experiment stands or falls on it.
#
# -return-fields NAME:SHAPE (repeatable) also hands function NAME's result,
# a rewritten web of shape index SHAPE, to its callers as fields: its `ret
# %R` becomes `retmulti %R.0 .. %R.N-1` (header `results=N`), and every
# `%C = call INDEX ARGS` of it elsewhere becomes `%C0 .. = callmulti INDEX
# ARGS` followed by `%C = structnew SHAPE %C0 ..`, which the caller's own
# rewrite then turns into field moves: the struct scalar replacement's
# return transport (STRUCT-SCALAR-REPLACEMENT.md, "One-hop return"),
# applied to a function whose result is a fold's value.
#
# What the tool does not decide -- whether a source program's value
# semantics allow the rewrite -- is the census's question; the tool only
# applies it to NIR whose webs are by construction a fold's carried value,
# and the census compares every rewritten program's value with the
# original's on the driver (run.tcl).

set functions ""
set planFields {}
set returnFields {}
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -functions { set functions [lindex $argv [incr i]] }
        -plan-field { lappend planFields [lindex $argv [incr i]] }
        -return-fields { lappend returnFields [lindex $argv [incr i]] }
        default { lappend files $arg }
    }
}
if {[llength $files] != 2} {
    puts stderr "usage: nir-sra.tcl ?-functions \"NAME ...\"? ?-plan-field SHAPE.FIELD ...? IN.nir OUT.nir"
    exit 2
}
lassign $files in out

proc readText {path} {
    set ch [open $path r]
    fconfigure $ch -encoding utf-8 -translation lf
    set text [read $ch]
    close $ch
    return $text
}

set text [readText $in]
set lines [split $text \n]

# Shape index -> field count, from the `shape` header lines.
set widths [dict create]
foreach line $lines {
    if {[regexp {^shape (\d+) (?:named "[^"]*"|anon|anonymous)(?: [a-z]+=\S+)* fields="([^"]*)"} $line -> idx fields]} {
        dict set widths $idx [llength $fields]
    }
}

# Splits an instruction line into {DESTS REST LOC}: the destination
# registers (without %), the instruction text after `=` (or the whole
# instruction when it defines nothing) and its `@eN` suffix.
proc parse {line} {
    set body [string trim $line]
    set loc ""
    if {[regexp {^(.*?)( @e\d+)$} $body -> b l]} {
        set body $b
        set loc $l
    }
    if {[regexp {^((?:%\d+ )*%\d+) = (.*)$} $body -> dests rest]} {
        return [list [lmap d $dests {string range $d 1 end}] $rest $loc]
    }
    return [list {} $body $loc]
}

# The registers (without %) instruction text REST reads.
proc uses {rest} {
    return [lmap m [regexp -all -inline {%\d+} $rest] {string range $m 1 end}]
}

# Union-find over registers.
proc find {x} {
    upvar 1 parent parent
    while {[dict get $parent $x] ne $x} {
        set x [dict get $parent $x]
    }
    return $x
}

proc rewrite {fnLines {returnShape ""}} {
    global widths planFields
    set header [lindex $fnLines 0]
    set body [lrange $fnLines 1 end]
    regexp {regs=(\d+)} $header -> nextReg
    # Pass 1: definitions of every register.
    set defs [dict create]
    foreach line $body {
        lassign [parse $line] dests rest
        foreach d $dests {
            dict lappend defs $d $rest
        }
    }
    # Candidate members: every definition a structnew or a move.
    set parent [dict create]
    set shapeOf [dict create]
    dict for {r ds} $defs {
        set ok 1
        foreach d $ds {
            if {![regexp {^structnew \d+} $d] && ![regexp {^move %\d+$} $d]} {
                set ok 0
                break
            }
        }
        if {$ok} {
            dict set parent $r $r
        }
    }
    # A move from a non-member disqualifies (iterate: removing one may
    # disqualify another); a member with only moves needs a structnew in
    # its web, found after the union.
    set changed 1
    while {$changed} {
        set changed 0
        foreach r [dict keys $parent] {
            foreach d [dict get $defs $r] {
                if {[regexp {^move %(\d+)$} $d -> src] && ![dict exists $parent $src]} {
                    dict unset parent $r
                    set changed 1
                    break
                }
            }
        }
    }
    foreach r [dict keys $parent] {
        foreach d [dict get $defs $r] {
            if {[regexp {^move %(\d+)$} $d -> src]} {
                set a [find $r]
                set b [find $src]
                if {$a ne $b} {
                    dict set parent $a $b
                }
            }
        }
    }
    # Shapes per web: exactly one.
    set webShape [dict create]
    set bad [dict create]
    foreach r [dict keys $parent] {
        set w [find $r]
        foreach d [dict get $defs $r] {
            if {[regexp {^structnew (\d+)} $d -> s]} {
                if {[dict exists $webShape $w] && [dict get $webShape $w] ne $s} {
                    dict set bad $w 1
                }
                dict set webShape $w $s
            }
        }
    }
    set member [dict create]
    foreach r [dict keys $parent] {
        set w [find $r]
        if {[dict exists $bad $w] || ![dict exists $webShape $w]} {
            continue
        }
        dict set member $r [dict get $webShape $w]
    }
    if {![dict size $member]} {
        return [list $fnLines {webs 0 members 0}]
    }
    # Field registers.
    set fieldReg [dict create]
    set plans {}
    dict for {r s} $member {
        set n [dict get $widths $s]
        for {set i 0} {$i < $n} {incr i} {
            dict set fieldReg $r $i $nextReg
            if {"$s.$i" in $planFields} {
                lappend plans $nextReg
            }
            incr nextReg
        }
    }
    set planSet [dict create]
    foreach p $plans {
        dict set planSet $p 1
    }
    set out {}
    set planTemps [dict create]
    set materialized 0
    set flats 0
    foreach line $body {
        lassign [parse $line] dests rest loc
        set indent "    "
        if {[string match "label *" [string trim $line]] || [string trim $line] eq "end" || [string trim $line] eq ""} {
            lappend out $line
            continue
        }
        # Which members this instruction reads as whole objects: none for a
        # field move or a field read of the web, the argument registers of
        # a web member's construction (a struct of another web stored as a
        # field), every member it reads otherwise.
        set memberDef [expr {[llength $dests] == 1 && [dict exists $member [lindex $dests 0]]}]
        set kind other
        if {$memberDef && [regexp {^structnew (\d+) ?(.*)$} $rest -> s args]} {
            set kind construct
            set wholeUses [lmap a $args {string range $a 1 end}]
        } elseif {$memberDef && [regexp {^move %(\d+)$} $rest -> src]} {
            set kind move
            set wholeUses {}
        } elseif {[regexp {^structget (\d+) %(\d+)$} $rest -> k src] && [dict exists $member $src]} {
            set kind get
            set wholeUses {}
        } elseif {$returnShape ne "" && [regexp {^ret %(\d+)$} $rest -> u] && [dict exists $member $u]
                && [dict get $member $u] eq $returnShape} {
            # The result of a -return-fields function leaves as fields.
            set kind retfields
            set wholeUses {}
        } else {
            set wholeUses [uses $rest]
        }
        # Materialize each such member right before the instruction.
        foreach u [lsort -unique $wholeUses] {
            if {[dict exists $member $u]} {
                set s [dict get $member $u]
                set regs {}
                dict for {i f} [dict get $fieldReg $u] {
                    if {[dict exists $planSet $f]} {
                        set t $nextReg
                        incr nextReg
                        lappend out "$indent%$t = construct list flat %$f$loc"
                        incr flats
                        lappend regs %$t
                    } else {
                        lappend regs %$f
                    }
                }
                lappend out "$indent%$u = structnew $s [join $regs { }]$loc"
                incr materialized
            }
        }
        switch -- $kind {
            construct {
                set d [lindex $dests 0]
                set i 0
                foreach a $args {
                    lappend out "$indent%[dict get $fieldReg $d $i] = move $a$loc"
                    incr i
                }
            }
            move {
                set d [lindex $dests 0]
                dict for {i f} [dict get $fieldReg $d] {
                    lappend out "$indent%$f = move %[dict get $fieldReg $src $i]$loc"
                }
            }
            get {
                set f [dict get $fieldReg $src $k]
                # A plan field's read hands the plan on to a plan temporary
                # (the pass below materializes it where it is not extended).
                if {[dict exists $planSet $f]} {
                    dict set planTemps [lindex $dests 0] 1
                }
                lappend out "$indent%[lindex $dests 0] = move %$f$loc"
            }
            retfields {
                lappend out "${indent}retmulti [join [lmap {i f} [dict get $fieldReg $u] {string cat % $f}] { }]$loc"
            }
            default {
                lappend out $line
            }
        }
    }
    # Plan fields: appends extend the plan in place; a move keeps a plan
    # only into a plan register; any other read of a plan register reads
    # it flat first (its one materialization on that path).
    if {[llength $plans]} {
        set isPlan $planSet
        dict for {t -} $planTemps {
            dict set isPlan $t 1
        }
        set final {}
        foreach line $out {
            lassign [parse $line] dests rest loc
            if {[string match "label *" [string trim $line]] || [string trim $line] in {end ""}} {
                lappend final $line
                continue
            }
            set d [lindex $dests 0]
            if {[regexp {^op listappend %(\d+) (%\d+)$} $rest -> a x] && [dict exists $isPlan $a]} {
                lappend final "    %$d = construct list plan %$a elem $x$loc"
                dict set isPlan $d 1
                continue
            }
            if {[regexp {^construct list flat %(\d+)( .+)$} $rest -> a pieces] && [dict exists $isPlan $a]} {
                lappend final "    %$d = construct list plan %$a$pieces$loc"
                dict set isPlan $d 1
                continue
            }
            if {[regexp {^construct list (?:flat|plan) } $rest]} {
                lappend final $line
                continue
            }
            if {[regexp {^move %(\d+)$} $rest -> a] && [dict exists $isPlan $a] && [dict exists $isPlan $d]} {
                lappend final $line
                continue
            }
            set subst $rest
            set pre {}
            foreach u [lsort -unique [uses $rest]] {
                if {[dict exists $isPlan $u]} {
                    set t $nextReg
                    incr nextReg
                    lappend pre "    %$t = construct list flat %$u$loc"
                    incr flats
                    regsub -all "%$u\\M" $subst "%$t" subst
                }
            }
            if {[llength $pre]} {
                lappend final {*}$pre
                set dtext [expr {[llength $dests] ? "[join [lmap x $dests {string cat % $x}] { }] = " : ""}]
                lappend final "    $dtext$subst$loc"
            } else {
                lappend final $line
            }
        }
        set plans [dict keys $isPlan]
        set out $final
    }
    regsub {regs=\d+} $header "regs=$nextReg" header
    if {$returnShape ne ""} {
        regsub { instance=} $header " results=[dict get $widths $returnShape] instance=" header
    }
    if {[llength $plans]} {
        if {[regexp {planregs="([^"]*)"} $header -> existing]} {
            regsub {planregs="[^"]*"} $header "planregs=\"[join [concat $existing [lsort -integer -unique $plans]] { }]\"" header
        } else {
            regsub { @e\d+$} $header "" h
            set suffix [string range $header [string length $h] end]
            set header "$h planregs=\"[join [lsort -integer -unique $plans] { }]\"$suffix"
        }
    }
    set webs [llength [lsort -unique [lmap r [dict keys $member] {find $r}]]]
    return [list [list $header {*}$out] [list webs $webs members [dict size $member] materializations $materialized flatReads $flats]]
}

# Function name -> index, and the -return-fields callees by index.
set indexOf [dict create]
foreach line $lines {
    if {[regexp {^func (\d+) "([^"]*)"} $line -> idx name]} {
        dict set indexOf $name $idx
    }
}
set returning [dict create]
set returnShapeOf [dict create]
foreach spec $returnFields {
    lassign [split $spec :] name shape
    dict set returning [dict get $indexOf $name] $shape
    dict set returnShapeOf $name $shape
}

# A call of a -return-fields callee in function FNLINES: its fields come
# back by callmulti and are bundled again (the rewrite opens the bundle).
proc openCalls {fnLines} {
    global returning widths
    if {![dict size $returning]} {
        return $fnLines
    }
    set header [lindex $fnLines 0]
    regexp {regs=(\d+)} $header -> nextReg
    set out [list $header]
    foreach line [lrange $fnLines 1 end] {
        lassign [parse $line] dests rest loc
        if {[llength $dests] == 1 && [regexp {^call (\d+)( .*)?$} $rest -> idx args] && [dict exists $returning $idx]} {
            set shape [dict get $returning $idx]
            set fields {}
            for {set i 0} {$i < [dict get $widths $shape]} {incr i} {
                lappend fields %$nextReg
                incr nextReg
            }
            lappend out "    [join $fields { }] = callmulti $idx$args$loc"
            lappend out "    %[lindex $dests 0] = structnew $shape [join $fields { }]$loc"
            continue
        }
        lappend out $line
    }
    regsub {regs=\d+} $header "regs=$nextReg" header
    return [lreplace $out 0 0 $header]
}

set result {}
set fn {}
set report {}
foreach line $lines {
    if {[string match "func *" $line]} {
        set fn [list $line]
        continue
    }
    if {[llength $fn]} {
        lappend fn $line
        if {$line eq "end"} {
            regexp {^func \d+ "([^"]*)"} [lindex $fn 0] -> name
            if {$functions eq "" || $name in $functions} {
                set fn [openCalls $fn]
                lassign [rewrite $fn [dict getdef $returnShapeOf $name ""]] fn stats
                lappend report "$name: $stats"
            }
            lappend result {*}$fn
            set fn {}
        }
        continue
    }
    lappend result $line
}
set ch [open $out w]
fconfigure $ch -encoding utf-8 -translation lf
puts -nonewline $ch [join $result \n]
close $ch
puts [join $report \n]
