#!/usr/bin/env tclsh9.0
# census.tcl -- corpus census of Fixpoint's result narrowing
# (GENERIC-PREDICATE-PROOF-LOSS.md, fix 3): compares the dumps collect.tcl
# wrote for hir::range::resultNarrowOpt 0 (DUMP0) and 1 (DUMP1), program by
# program, and writes a human-readable report to OUT (stdout if "-").
#
#   tclsh9.0 census.tcl DUMP0 DUMP1 OUT PROGRAM.bot...
#
# Pure comparison: needs no compiler. Per program:
#   (a) every Range fact of every used instance -- entry Ranges (analyze
#       instances params), the summary a call reads (the final Fixpoint
#       state's calleeResults), the instance result (analyze instances
#       result), every expression Range (analyze instances exprs, what
#       hir::range::of reads) and, additionally, the final capture facts
#       (narrowedCaptures) -- classified by the value sets they admit:
#         same          identical text
#         equal         different text, same value set
#         narrower      knob 1 admits a strict subset of knob 0's values
#         wider         knob 1 admits a strict superset (must never happen)
#         incomparable  neither contains the other (must never happen)
#       A Range's value set is its interval, intersected with its `exact`
#       list when it has one; "never" is the empty set. An ExprId present
#       on one side only is reported separately (dropped/added).
#   (b) resultNarrow {attempted converged rounds} of every Fixpoint call.
#   (c) the NIR: functions matched by (name, instance, anchor, occurrence),
#       and per changed function the op-mix change (tagged Int ops, raw ri*
#       ops, runbox/rbox, constants, branches, labels), its header changes,
#       and the raw-int-ABI plan's text diff.

lassign $argv dump0 dump1 outPath
set programs [lrange $argv 3 end]

proc Read {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set s [read $f]
    close $f
    return $s
}

# ---------------------------------------------------------------------------
# Range value sets

proc LowGe {a b} {
    # lower bound A >= lower bound B (as sets: [A,..] starts inside [B,..])
    if {$b eq "-inf"} { return 1 }
    if {$a eq "-inf"} { return 0 }
    return [expr {$a >= $b}]
}
proc HighLe {a b} {
    if {$b eq "+inf"} { return 1 }
    if {$a eq "+inf"} { return 0 }
    return [expr {$a <= $b}]
}
proc InRange {v r} {
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn ne "-inf" && $v < $mn} { return 0 }
    if {$mx ne "+inf" && $v > $mx} { return 0 }
    if {[dict exists $r exact]} {
        foreach x [dict get $r exact] {
            if {$x == $v} { return 1 }
        }
        return 0
    }
    return 1
}
# 1 iff every value A admits, B admits.
proc Subset {a b} {
    if {$a eq "never"} { return 1 }
    if {$b eq "never"} { return 0 }
    set amn [dict get $a min]
    set amx [dict get $a max]
    if {[dict exists $a exact]} {
        foreach v [dict get $a exact] {
            if {($amn ne "-inf" && $v < $amn) || ($amx ne "+inf" && $v > $amx)} continue
            if {![InRange $v $b]} { return 0 }
        }
        return 1
    }
    if {![LowGe $amn [dict get $b min]] || ![HighLe $amx [dict get $b max]]} {
        return 0
    }
    if {[dict exists $b exact]} {
        if {$amn eq "-inf" || $amx eq "+inf"} { return 0 }
        set bex [dict get $b exact]
        if {$amx - $amn + 1 > [llength $bex]} { return 0 }
        # Not `incr` (AGENTS.md: compiled incr wraps at the i64 boundary).
        for {set v $amn} {$v <= $amx} {set v [expr {$v + 1}]} {
            if {![InRange $v $b]} { return 0 }
        }
    }
    return 1
}
# Knob-0 fact R0 against knob-1 fact R1.
proc Classify {r0 r1} {
    if {$r0 eq $r1} { return same }
    set s10 [Subset $r1 $r0]
    set s01 [Subset $r0 $r1]
    if {$s10 && $s01} { return equal }
    if {$s10} { return narrower }
    if {$s01} { return wider }
    return incomparable
}
proc Show {r} {
    if {$r eq "never"} { return never }
    set mn [string map {-inf -∞} [dict get $r min]]
    set mx [string map {+inf +∞} [dict get $r max]]
    set s "\[$mn, $mx\]"
    if {[dict exists $r exact]} {
        append s " {[join [dict get $r exact] ,]}"
    }
    return $s
}

# `census.tcl -selftest`: the classifier against hand-checked cases
# (intervals, exact sets, dense sets written both ways, never, bignums).
if {[lindex $argv 0] eq "-selftest"} {
    set U {min -inf max +inf}
    set cases [list \
        [list {min 0 max 10} {min 0 max 10} same] \
        [list $U {min 0 max +inf} narrower] \
        [list {min 0 max +inf} $U wider] \
        [list {min -inf max 5} {min 0 max +inf} incomparable] \
        [list {min 0 max 10} {min 0 max 10 exact {0 5 10}} narrower] \
        [list {min 0 max 10 exact {0 5 10}} {min 0 max 10} wider] \
        [list {min 0 max 10 exact {0 5 10}} {min 0 max 10 exact {0 5}} narrower] \
        [list {min 0 max 10 exact {0 5}} {min 0 max 10 exact {0 6}} incomparable] \
        [list {min 0 max 2} {min 0 max 2 exact {0 1 2}} equal] \
        [list {min 0 max 2 exact {0 1 2}} {min 0 max 2} equal] \
        [list never {min 0 max 1} wider] \
        [list {min 0 max 1} never narrower] \
        [list never never same] \
        [list {min 0 max 100} {min 5 max 5} narrower] \
        [list {min 0 max 4611686018427387903} {min 0 max 4611686018427387904} wider] \
        [list {min -9223372036854775809 max 0} {min -9223372036854775808 max 0} narrower] \
        [list {min 0 max 240 exact {0 16 240}} {min 0 max 255} wider]]
    set bad 0
    foreach c $cases {
        lassign $c a b want
        set got [Classify $a $b]
        if {$got ne $want} {
            puts "FAIL [list $a] -> [list $b]: got $got, want $want"
            incr bad
        }
    }
    puts "classifier self-test: [llength $cases] cases, $bad failures"
    exit [expr {$bad != 0}]
}

# ---------------------------------------------------------------------------
# NIR

# FUNCS: ordered list of {key header body} for every `func ... end` block.
proc ParseNir {text} {
    set funcs {}
    set seen [dict create]
    set cur ""
    foreach line [split $text \n] {
        if {[string match "func *" $line]} {
            regexp {^func \d+ "([^"]*)"} $line -> name
            set instance ""
            regexp {instance="([^"]*)"} $line -> instance
            set anchor ""
            regexp {(@e\d+)\s*$} $line -> anchor
            set base [list $name $instance $anchor]
            dict incr seen $base
            set key [list {*}$base [dict get $seen $base]]
            set cur [list $key $line {}]
            continue
        }
        if {$cur eq ""} continue
        if {$line eq "end"} {
            lappend funcs $cur
            set cur ""
            continue
        }
        lset cur 2 [concat [lindex $cur 2] [list $line]]
    }
    return $funcs
}
# Instruction kind of one NIR body line.
proc Kind {line} {
    set t [string trim $line]
    if {[regexp {^%\d+ = (\S+)(?: (\S+))?} $t -> k next]} {
        if {$k eq "op"} { return $next }
        return $k
    }
    return [lindex [split $t " "] 0]
}
proc Mix {body} {
    set mix [dict create]
    foreach line $body {
        if {[string trim $line] eq ""} continue
        dict incr mix [Kind $line]
    }
    return $mix
}
# Header attributes (k="v" or k=v) other than the leading func N "name".
proc Attrs {header} {
    set attrs [dict create]
    foreach {- k v} [regexp -all -inline {(\w+)=("[^"]*"|\S+)} $header] {
        dict set attrs $k [string trim $v \"]
    }
    return $attrs
}

set taggedInt {iadd isub imul ieq ilt ile igt ige imod iand ior ixor ishl ishr}
set rawInt {riadd risub rimul rieq rilt rile rigt rige rishr rishl}

# ---------------------------------------------------------------------------
# One program

proc LoadDump {dir} {
    set d [dict create]
    if {[file exists [file join $dir skip.txt]]} {
        dict set d skip [string trim [Read [file join $dir skip.txt]]]
        return $d
    }
    dict set d nir [Read [file join $dir nir.txt]]
    dict set d instancesText [Read [file join $dir instances.txt]]
    set analysis [Read [file join $dir analysis.txt]]
    foreach line [split [string trimright $analysis \n] \n] {
        dict set d [lindex $line 0] [lindex $line 1]
    }
    set fps {}
    foreach line [split [string trimright [Read [file join $dir fixpoints.txt]] \n] \n] {
        lappend fps $line
    }
    dict set d fixpoints $fps
    set labels [dict create]
    foreach line [split [string trimright [Read [file join $dir labels.txt]] \n] \n] {
        dict set labels [lindex $line 0] [lindex $line 1]
    }
    dict set d labels $labels
    dict set d rawabi [Read [file join $dir rawabi.txt]]
    dict set d calls [string trim [Read [file join $dir calls.txt]]]
    set exprText [dict create]
    foreach line [split [Read [file join $dir hir.txt]] \n] {
        set t [string trim $line]
        if {[regexp {^(e\d+) (.*)$} $t -> e rest]} {
            dict set exprText $e $rest
        }
    }
    dict set d exprText $exprText
    set variants [dict create]
    foreach line [split [string trimright [Read [file join $dir variants.txt]] \n] \n] {
        lassign $line id mode
        dict lappend variants $id $mode
    }
    dict set d variants $variants
    return $d
}

# Global totals.
set totals [dict create]
foreach k {programs skipped instances facts same equal narrower wider incomparable dropped added
        progNarrowed progRangeChanged progNirChanged progAbiChanged funcsChanged attempted converged
        callSitesNarrowed summariesNarrowed} {
    dict set totals $k 0
}
set byKind [dict create]
set rows {}
set details {}
set skippedList {}
set badList {}
set fixpointLines {}
set nirAgg [dict create]

proc Note {catVar kind cls} {
    upvar 1 $catVar cat
    dict incr cat $cls
    upvar #0 byKind byKind
    dict incr byKind "$kind $cls"
}

foreach path $programs {
    # One dump directory per program path (bench/fib.bot and bench/fib.ir
    # must not collide): the relative path with "/" spelled "__".
    set stem [string map {/ __} [string trimleft [file rootname $path] ./]]
    set d0 [LoadDump [file join $dump0 $stem]]
    set d1 [LoadDump [file join $dump1 $stem]]
    if {[dict exists $d0 skip] || [dict exists $d1 skip]} {
        dict incr totals skipped
        set why [expr {[dict exists $d0 skip] ? [dict get $d0 skip] : [dict get $d1 skip]}]
        set both [expr {[dict exists $d0 skip] && [dict exists $d1 skip] ? "both" : "ONE SIDE ONLY"}]
        lappend skippedList "$path ($both): [lindex [split $why \n] 0] -- [lindex [split $why \n] 1]"
        continue
    }
    dict incr totals programs
    set labels [dict get $d1 labels]
    if {[dict keys [dict get $d0 labels]] ne [dict keys $labels]} {
        lappend badList "$path: used-instance lists differ between knob 0 and 1"
    }
    set exprText [dict get $d1 exprText]
    set fp0 [lindex [dict get $d0 fixpoints] end]
    set fp1 [lindex [dict get $d1 fixpoints] end]
    set cat [dict create same 0 equal 0 narrower 0 wider 0 incomparable 0 dropped 0 added 0]
    set progDetails {}
    set nInst 0
    set nFacts 0
    dict for {id info} $labels {
        incr nInst
        set label [dict get $info label]
        set pnames [dict get $info pnames]
        set i0 [dict get $d0 instances $id]
        set i1 [dict get $d1 instances $id]
        set facts {}
        # entry Ranges
        set p0 [dict get $i0 params]
        set p1 [dict get $i1 params]
        if {[llength $p0] != [llength $p1]} {
            lappend badList "$path $label: parameter counts differ"
        }
        set i 0
        foreach r0 $p0 r1 $p1 {
            set nm [lindex $pnames $i]
            lappend facts entry "param $i ($nm)" $r0 $r1
            incr i
        }
        # summary
        set has0 [dict exists $fp0 calleeResults $id]
        set has1 [dict exists $fp1 calleeResults $id]
        if {$has0 && $has1} {
            lappend facts summary "summary" [dict get $fp0 calleeResults $id] [dict get $fp1 calleeResults $id]
        } elseif {$has0 != $has1} {
            lappend badList "$path $label: summary present on one side only"
        }
        # result
        lappend facts result "result" [dict get $i0 result] [dict get $i1 result]
        # expressions
        set e0 [dict get $i0 exprs]
        set e1 [dict get $i1 exprs]
        set keys [lsort -dictionary -unique [concat [dict keys $e0] [dict keys $e1]]]
        foreach e $keys {
            set in0 [dict exists $e0 $e]
            set in1 [dict exists $e1 $e]
            if {$in0 && $in1} {
                lappend facts expr $e [dict get $e0 $e] [dict get $e1 $e]
            } else {
                set cls [expr {$in0 ? "dropped" : "added"}]
                Note cat expr $cls
                incr nFacts
                set txt [expr {[dict exists $exprText $e] ? [dict get $exprText $e] : ""}]
                set r [expr {$in0 ? [dict get $e0 $e] : [dict get $e1 $e]}]
                lappend progDetails "    $cls  $label  expr $e [Show $r]   ($txt)"
            }
        }
        foreach {kind what r0 r1} $facts {
            incr nFacts
            set cls [Classify $r0 $r1]
            Note cat $kind $cls
            if {$cls ne "same"} {
                set txt ""
                if {$kind eq "expr" && [dict exists $exprText $what]} {
                    set txt "   ([dict get $exprText $what])"
                    # An exact call to a Botlish function: the Range a call
                    # site reads (the summary, joined over the call's own
                    # transfer) -- the fact this change targets.
                    if {$cls eq "narrower" && [string match "call block(*" [dict get $exprText $what]]} {
                        dict incr totals callSitesNarrowed
                        set txt "   ([dict get $exprText $what]) <- exact call site"
                    }
                }
                if {$kind eq "summary" && $cls eq "narrower"} {
                    dict incr totals summariesNarrowed
                }
                set mark [expr {$cls in {wider incomparable} ? "!!" : "  "}]
                lappend progDetails "  $mark$cls  $label  $kind $what: [Show $r0] -> [Show $r1]$txt"
                if {$cls in {wider incomparable}} {
                    lappend badList "$path $label $kind $what: $cls [Show $r0] -> [Show $r1]"
                }
            }
        }
    }
    # captures (final state), keyed by child block
    set c0 [dict get $fp0 narrowedCaptures]
    set c1 [dict get $fp1 narrowedCaptures]
    foreach blk [lsort -dictionary -unique [concat [dict keys $c0] [dict keys $c1]]] {
        set b0 [expr {[dict exists $c0 $blk] ? [dict get $c0 $blk] : {}}]
        set b1 [expr {[dict exists $c1 $blk] ? [dict get $c1 $blk] : {}}]
        foreach b [lsort -dictionary -unique [concat [dict keys $b0] [dict keys $b1]]] {
            incr nFacts
            if {![dict exists $b0 $b] || ![dict exists $b1 $b]} {
                set cls [expr {[dict exists $b0 $b] ? "dropped" : "added"}]
                Note cat capture $cls
                lappend progDetails "    $cls  capture $blk/$b"
                continue
            }
            set r0 [dict get $b0 $b]
            set r1 [dict get $b1 $b]
            set cls [Classify $r0 $r1]
            Note cat capture $cls
            if {$cls ne "same"} {
                set mark [expr {$cls in {wider incomparable} ? "!!" : "  "}]
                lappend progDetails "  $mark$cls  capture $blk/$b: [Show $r0] -> [Show $r1]"
                if {$cls in {wider incomparable}} {
                    lappend badList "$path capture $blk/$b: $cls [Show $r0] -> [Show $r1]"
                }
            }
        }
    }
    # induction / recursive records (reported if they differ at all)
    foreach key {induction recursive} {
        if {[dict get $d0 $key] ne [dict get $d1 $key]} {
            lappend progDetails "    note: analyze `$key` differs between knob 0 and 1"
        }
    }
    dict incr totals instances $nInst
    dict incr totals facts $nFacts
    foreach k {same equal narrower wider incomparable dropped added} {
        dict incr totals $k [dict get $cat $k]
    }
    if {[dict get $cat narrower] > 0} {
        dict incr totals progNarrowed
    }
    if {[dict get $cat same] != $nFacts} {
        dict incr totals progRangeChanged
    }

    # (b) resultNarrow per Fixpoint call
    set rnText {}
    set fpi 0
    foreach fp [dict get $d1 fixpoints] {
        incr fpi
        if {[dict exists $fp resultNarrow]} {
            set rn [dict get $fp resultNarrow]
            lappend rnText "[dict get $rn attempted]/[dict get $rn converged]/[dict get $rn rounds]"
            if {$fpi == [llength [dict get $d1 fixpoints]]} {
                dict incr totals attempted [dict get $rn attempted]
                dict incr totals converged [dict get $rn converged]
            }
            lappend fixpointLines [list $stem $fpi [dict get $fp pinned] $rn]
        } else {
            lappend rnText "n/a"
        }
    }
    set rn0Text {}
    foreach fp [dict get $d0 fixpoints] {
        if {[dict exists $fp resultNarrow]} {
            set rn [dict get $fp resultNarrow]
            lappend rn0Text "[dict get $rn attempted]/[dict get $rn converged]/[dict get $rn rounds]"
        } else {
            lappend rn0Text "n/a"
        }
    }

    # (c) NIR
    set nir0 [dict get $d0 nir]
    set nir1 [dict get $d1 nir]
    set nirDetails {}
    set changedFuncs 0
    if {$nir0 ne $nir1} {
        dict incr totals progNirChanged
        set f0 [ParseNir $nir0]
        set f1 [ParseNir $nir1]
        set m0 [dict create]
        set m1 [dict create]
        foreach f $f0 { dict set m0 [lindex $f 0] $f }
        foreach f $f1 { dict set m1 [lindex $f 0] $f }
        # module-level lines outside funcs
        set top0 [lmap l [split $nir0 \n] {expr {[string match "native *" $l] || [string match "nir *" $l] ? $l : [continue]}}]
        set top1 [lmap l [split $nir1 \n] {expr {[string match "native *" $l] || [string match "nir *" $l] ? $l : [continue]}}]
        if {$top0 ne $top1} {
            lappend nirDetails "    module header/native lines differ"
        }
        foreach key [dict keys $m0] {
            if {![dict exists $m1 $key]} {
                lappend nirDetails "    function only at knob 0: $key"
                incr changedFuncs
            }
        }
        foreach key [dict keys $m1] {
            if {![dict exists $m0 $key]} {
                lappend nirDetails "    function only at knob 1: $key"
                incr changedFuncs
                continue
            }
            lassign [dict get $m0 $key] - h0 b0
            lassign [dict get $m1 $key] - h1 b1
            # function index numbers may shift; compare headers without it
            regsub {^func \d+ } $h0 {func N } h0n
            regsub {^func \d+ } $h1 {func N } h1n
            if {$h0n eq $h1n && $b0 eq $b1} continue
            incr changedFuncs
            lassign $key name instance anchor occ
            set occText [expr {$occ > 1 ? " #$occ" : ""}]
            lappend nirDetails "    func \"$name\" instance=\"$instance\" $anchor$occText"
            set a0 [Attrs $h0n]
            set a1 [Attrs $h1n]
            foreach k [lsort -unique [concat [dict keys $a0] [dict keys $a1]]] {
                set v0 [expr {[dict exists $a0 $k] ? [dict get $a0 $k] : "-"}]
                set v1 [expr {[dict exists $a1 $k] ? [dict get $a1 $k] : "-"}]
                if {$v0 ne $v1} {
                    lappend nirDetails "      header $k: \"$v0\" -> \"$v1\""
                }
            }
            set x0 [Mix $b0]
            set x1 [Mix $b1]
            set deltas {}
            foreach k [lsort -unique [concat [dict keys $x0] [dict keys $x1]]] {
                set n0 [expr {[dict exists $x0 $k] ? [dict get $x0 $k] : 0}]
                set n1 [expr {[dict exists $x1 $k] ? [dict get $x1 $k] : 0}]
                if {$n0 != $n1} {
                    lappend deltas "$k $n0->$n1"
                    dict incr nirAgg $k [expr {$n1 - $n0}]
                }
            }
            set g0 [dict create tagged 0 raw 0]
            set g1 [dict create tagged 0 raw 0]
            foreach {g list} [list tagged $::taggedInt raw $::rawInt] {
                foreach k $list {
                    if {[dict exists $x0 $k]} { dict incr g0 $g [dict get $x0 $k] }
                    if {[dict exists $x1 $k]} { dict incr g1 $g [dict get $x1 $k] }
                }
            }
            set n0 [llength [lsearch -all -inline -not -exact $b0 ""]]
            set n1 [llength [lsearch -all -inline -not -exact $b1 ""]]
            set sum "tagged-int ops [dict get $g0 tagged]->[dict get $g1 tagged], raw ri* ops [dict get $g0 raw]->[dict get $g1 raw]"
            foreach k {runbox rbox br label} {
                set c0 [expr {[dict exists $x0 $k] ? [dict get $x0 $k] : 0}]
                set c1 [expr {[dict exists $x1 $k] ? [dict get $x1 $k] : 0}]
                append sum ", $k $c0->$c1"
            }
            append sum ", lines $n0->$n1"
            lappend nirDetails "      $sum"
            if {$deltas ne ""} {
                lappend nirDetails "      op deltas: [join $deltas {, }]"
            } else {
                lappend nirDetails "      op mix unchanged (operands/order differ)"
            }
        }
        dict incr totals funcsChanged $changedFuncs
    }
    # raw-int-ABI plan
    set abi0 [dict get $d0 rawabi]
    set abi1 [dict get $d1 rawabi]
    set abiDetails {}
    if {$abi0 ne $abi1} {
        dict incr totals progAbiChanged
        # Line diff by instance block: report per instance the changed lines.
        set blocks0 [dict create]
        set blocks1 [dict create]
        foreach {var text} [list blocks0 $abi0 blocks1 $abi1] {
            set cur ""
            foreach line [split $text \n] {
                if {[string match "instance *" $line]} {
                    set cur $line
                    dict set $var $cur {}
                    continue
                }
                if {$cur ne ""} {
                    dict lappend $var $cur $line
                }
            }
        }
        foreach inst [lsort -unique [concat [dict keys $blocks0] [dict keys $blocks1]]] {
            set l0 [expr {[dict exists $blocks0 $inst] ? [dict get $blocks0 $inst] : {}}]
            set l1 [expr {[dict exists $blocks1 $inst] ? [dict get $blocks1 $inst] : {}}]
            if {$l0 eq $l1} continue
            lappend abiDetails "    $inst"
            # Only an instance's canonical function carries a physical raw
            # signature (rawabi.tcl); say which variants lowering emitted.
            set instLabel [string range $inst [string length "instance "] end]
            set instId ""
            dict for {lid linfo} $labels {
                if {[dict get $linfo label] eq $instLabel} { set instId $lid }
            }
            if {$instId ne ""} {
                set v0 [expr {[dict exists $d0 variants $instId] ? [dict get $d0 variants $instId] : {}}]
                set v1 [expr {[dict exists $d1 variants $instId] ? [dict get $d1 variants $instId] : {}}]
                set note "      NIR variants emitted for $instId: knob0 {$v0}, knob1 {$v1}"
                if {"canonical" ni $v1} {
                    append note " -- canonical function not emitted: the plan's raw signature is not realized in NIR"
                }
                lappend abiDetails $note
            }
            # simple positional diff (same section structure on both sides)
            set n [expr {max([llength $l0], [llength $l1])}]
            for {set i 0} {$i < $n} {incr i} {
                set a [lindex $l0 $i]
                set b [lindex $l1 $i]
                if {$a ne $b} {
                    lappend abiDetails "      - [string trim $a]"
                    lappend abiDetails "      + [string trim $b]"
                }
            }
        }
    }

    set abiFlag [expr {$abi0 ne $abi1 ? "changed" : "same"}]
    lappend rows [list [file rootname $path] $nInst $nFacts [dict get $cat narrower] \
        [expr {[dict get $cat wider] + [dict get $cat incomparable]}] [dict get $cat equal] \
        "[dict get $cat dropped]/[dict get $cat added]" [join $rnText ,] $changedFuncs $abiFlag]
    if {$progDetails ne "" || $nirDetails ne "" || $abiDetails ne ""} {
        lappend details "== [file rootname $path] ($path)"
        lappend details "  calls knob0: [dict get $d0 calls]; knob1: [dict get $d1 calls]"
        lappend details "  resultNarrow per Fixpoint call (attempted/converged/rounds): knob1 [join $rnText ,]; knob0 [join $rn0Text ,]"
        if {$progDetails ne ""} {
            lappend details "  Range facts that changed (knob 0 -> knob 1):"
            lappend details {*}$progDetails
        }
        if {$nirDetails ne ""} {
            lappend details "  NIR functions that changed:"
            lappend details {*}$nirDetails
        }
        if {$abiDetails ne ""} {
            lappend details "  raw-int-ABI plan changes (- knob 0, + knob 1):"
            lappend details {*}$abiDetails
        }
        lappend details ""
    }
}

# ---------------------------------------------------------------------------
# Report

set out {}
lappend out "Result-narrowing corpus census (GENERIC-PREDICATE-PROOF-LOSS.md, fix 3)"
lappend out "hir::range::resultNarrowOpt 0 (pass skipped) vs 1 (default), same tree, same specialization,"
lappend out "default native lowering options; facts are the ones native::nir's own lowering consumed."
lappend out ""
lappend out "Corpus: [llength $programs] programs; compiled natively: [dict get $totals programs]; skipped: [dict get $totals skipped]"
lappend out ""
set hdr [format "%-34s %5s %6s %6s %6s %5s %7s %-16s %5s %-7s" program inst facts narrow WIDER equal drp/add resultNarrow nirFn abi]
lappend out $hdr
lappend out [string repeat - [string length $hdr]]
foreach r $rows {
    lappend out [format "%-34s %5s %6s %6s %6s %5s %7s %-16s %5s %-7s" {*}$r]
}
lappend out [string repeat - [string length $hdr]]
lappend out [format "%-34s %5s %6s %6s %6s %5s %7s %-16s %5s" TOTAL [dict get $totals instances] [dict get $totals facts] \
    [dict get $totals narrower] [expr {[dict get $totals wider] + [dict get $totals incomparable]}] [dict get $totals equal] \
    "[dict get $totals dropped]/[dict get $totals added]" "" [dict get $totals funcsChanged]]
lappend out ""
lappend out "Columns: inst = used instances; facts = Range facts compared (entry params, summaries, results,"
lappend out "expression Ranges, capture facts); narrow = facts strictly narrower at knob 1; WIDER = facts wider or"
lappend out "incomparable at knob 1 (must be 0); equal = same value set, different text; drp/add = ExprIds"
lappend out "present at knob 0 only / knob 1 only; resultNarrow = attempted/converged/rounds of each Fixpoint call"
lappend out "(analyze re-runs Fixpoint after pinning self-recursive summaries); nirFn = NIR functions changed;"
lappend out "abi = raw-int-ABI plan text (native::rawabi::explainAll)."
lappend out ""
lappend out "Totals"
lappend out "  facts compared:            [dict get $totals facts]"
lappend out "  same:                      [dict get $totals same]"
lappend out "  equal set, different text: [dict get $totals equal]"
lappend out "  narrower:                  [dict get $totals narrower]"
lappend out "  wider:                     [dict get $totals wider]"
lappend out "  incomparable:              [dict get $totals incomparable]"
lappend out "  ExprIds dropped / added:   [dict get $totals dropped] / [dict get $totals added]"
lappend out "  exact call sites (call expressions) narrowed: [dict get $totals callSitesNarrowed]"
lappend out "  callee summaries (calleeResults) narrowed:   [dict get $totals summariesNarrowed]"
lappend out "  programs with any Range fact change: [dict get $totals progRangeChanged]"
lappend out "  programs with narrower facts: [dict get $totals progNarrowed]"
lappend out "  programs with NIR changes:    [dict get $totals progNirChanged] ([dict get $totals funcsChanged] functions)"
lappend out "  programs with raw-int-ABI plan changes: [dict get $totals progAbiChanged]"
lappend out "  final Fixpoint: result narrowing attempted [dict get $totals attempted], converged [dict get $totals converged]"
set maxRounds 0
set nonConv {}
foreach fl $fixpointLines {
    lassign $fl stem fpi pinned rn
    if {[dict get $rn rounds] > $maxRounds} { set maxRounds [dict get $rn rounds] }
    if {[dict get $rn attempted] && ![dict get $rn converged]} {
        lappend nonConv "$stem (Fixpoint call $fpi)"
    }
}
lappend out "  max result-narrowing rounds (any Fixpoint call): $maxRounds"
lappend out "  non-converged result narrowings (any Fixpoint call): [llength $nonConv][expr {$nonConv ne "" ? " -- [join $nonConv {, }]" : ""}]"
lappend out ""
lappend out "By fact kind (kind class count):"
foreach k [lsort [dict keys $byKind]] {
    lappend out "  [format %-24s $k] [dict get $byKind $k]"
}
lappend out ""
if {$nirAgg ne ""} {
    lappend out "Aggregate NIR op-count deltas over all changed functions (knob 1 minus knob 0):"
    set agg {}
    dict for {k v} $nirAgg {
        if {$v != 0} { lappend agg "$k [expr {$v > 0 ? "+$v" : $v}]" }
    }
    lappend out "  [join $agg {, }]"
    lappend out ""
}
lappend out "Wider/incomparable facts and structural mismatches: [llength $badList]"
foreach b $badList {
    lappend out "  $b"
}
lappend out ""
lappend out "Skipped programs (did not compile natively):"
if {$skippedList eq ""} {
    lappend out "  none"
}
foreach s $skippedList {
    lappend out "  $s"
}
lappend out ""
lappend out "Details per program (only programs where something changed)"
lappend out "============================================================"
lappend out {*}$details

set text "[join $out \n]\n"
if {$outPath eq "-"} {
    fconfigure stdout -encoding utf-8 -translation lf
    puts -nonewline $text
} else {
    set f [open $outPath w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}
puts stderr "SUMMARY programs=[dict get $totals programs] skipped=[dict get $totals skipped] facts=[dict get $totals facts] narrower=[dict get $totals narrower] wider=[dict get $totals wider] incomparable=[dict get $totals incomparable] equal=[dict get $totals equal] dropped=[dict get $totals dropped] added=[dict get $totals added] callSitesNarrowed=[dict get $totals callSitesNarrowed] summariesNarrowed=[dict get $totals summariesNarrowed] progRangeChanged=[dict get $totals progRangeChanged] progNirChanged=[dict get $totals progNirChanged] funcsChanged=[dict get $totals funcsChanged] progAbiChanged=[dict get $totals progAbiChanged] attempted=[dict get $totals attempted] converged=[dict get $totals converged] maxRounds=$maxRounds nonConverged=[llength $nonConv]"
puts stderr "programs [dict get $totals programs] skipped [dict get $totals skipped] facts [dict get $totals facts] narrower [dict get $totals narrower] wider [dict get $totals wider] incomparable [dict get $totals incomparable] nirProgs [dict get $totals progNirChanged] funcs [dict get $totals funcsChanged]"
