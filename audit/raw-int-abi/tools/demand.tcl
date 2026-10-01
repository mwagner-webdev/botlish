#!/usr/bin/env tclsh9.0
# demand.tcl -- RAW-INT-ABI.md "Raw-demand suppression": the three-way audit.
#
# For each canonical program, three configurations:
#
#   A  -raw-int-abi-opt 0                    the tagged baseline (pre-RawInt)
#   B  -raw-int-abi-opt 1 -raw-demand-opt 0  RawInt eligibility only
#                                            (eligible => raw: the preliminary)
#   C  -raw-int-abi-opt 1 -raw-demand-opt 1  RawInt + demand suppression
#
# and, per program: the suppression census (eligible / selected / suppressed
# positions, parameters and results separately), NIR conversion counts
# (rbox/runbox) and the classification of every remaining rbox, machine-code
# bytes, and with -detail the demand trace of every eligible position.
#
#   tclsh9.0 audit/raw-int-abi/tools/demand.tcl ?-detail? PROGRAM.bot...
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join [file dirname [file normalize [info script]]] nirlib.tcl]
interp recursionlimit {} 20000
fconfigure stdout -encoding utf-8 -translation lf

set detail 0
set paths {}
foreach a $argv {
    if {$a eq "-detail"} { set detail 1 } else { lappend paths $a }
}

set configs {
    A {-raw-int-abi-opt 0}
    B {-raw-int-abi-opt 1 -raw-demand-opt 0}
    C {-raw-int-abi-opt 1 -raw-demand-opt 1}
}

set totals [dict create]
proc total {key n} {
    global totals
    dict incr totals $key $n
}

foreach path $paths {
    if {[catch {
        set hir [surface::readProgramFile $path]
        set prepared [native::prepareHir $hir]
        set res [dict create]
        foreach {name opts} $configs {
            set lowered [native::lowered $hir {*}$opts]
            set funcs [nirFunctions [dict get $lowered text]]
            set conv {0 0 0 0}
            foreach f $funcs {
                set c [conversions [lindex $f 2] [lindex $f 3]]
                set conv [lmap a $conv b $c {expr {$a + $b}}]
            }
            set cls [dict create]
            foreach r [classifyRboxes $funcs] {
                dict incr cls [lindex $r 1]
            }
            dict set res $name [dict create lowered $lowered conv $conv cls $cls \
                bytes [lindex [native::codeSize $hir {*}$opts] 0]]
        }
    } err]} {
        puts "$path: SKIP ($err)"
        continue
    }
    # Census from C's plan (carries eligibility) and B's plan (all eligible raw).
    set lowC [dict get $res C lowered]
    set spec [dict get $lowC specialization]
    set planC [dict get $lowC abiPlan]
    set planB [dict get [dict get $res B lowered] abiPlan]
    set eligP 0; set selP 0; set eligR 0; set selR 0; set anyB 0; set anyC 0; set bothC 0
    set suppressed {}
    set selected {}
    foreach id [dict get $spec used] {
        set p [dict get $planC $id]
        set label [hir::specialize::label $spec $id]
        set names {}
        set block [dict get [dict get $spec instances $id] block]
        if {$block ne "program"} {
            set names [lmap b [hir::get $prepared $block params] {
                dict get [hir::binding $prepared $b] name
            }]
        }
        set nEl 0; set nSel 0
        foreach eligible [dict get $p paramEligible] kind [dict get $p params] name $names trace [dict get $p paramTrace] {
            if {!$eligible} continue
            incr eligP; incr nEl
            if {$kind eq "rawint"} {
                incr selP; incr nSel
                lappend selected [list $label $name raw $trace]
            } else {
                lappend suppressed [list $label $name raw $trace]
            }
        }
        if {[dict get $p resultEligible]} {
            incr eligR; incr nEl
            if {[dict get $p result] eq "rawint"} {
                incr selR; incr nSel
                lappend selected [list $label result raw [dict get $p resultTrace]]
            } else {
                lappend suppressed [list $label result raw [dict get $p resultTrace]]
            }
        }
        set hasB [expr {[llength [lsearch -all -exact [dict get $planB $id params] rawint]] > 0 || [dict get $planB $id result] eq "rawint"}]
        set hasC [expr {$nSel > 0}]
        if {$hasB} { incr anyB }
        if {$hasC} { incr anyC }
        set resSel [expr {[dict get $p result] eq "rawint"}]
        set parSel [expr {[llength [lsearch -all -exact [dict get $p params] rawint]] > 0}]
        if {$resSel && $parSel} { incr bothC }
    }
    set examined [expr {[llength [dict get $spec used]] - 1}]
    puts "$path:"
    puts "  instances examined $examined; instances with any raw position B $anyB, C $anyC (both param+result in C: $bothC)"
    puts "  positions eligible/selected/suppressed: parameters $eligP/$selP/[expr {$eligP - $selP}]; results $eligR/$selR/[expr {$eligR - $selR}]"
    foreach name {A B C} {
        set r [dict get $res $name]
        lassign [dict get $r conv] rb rub brb brub
        puts "  $name: rbox $rb runbox $rub; machine bytes [dict get $r bytes]; rbox classes [lsort -stride 2 [dict get $r cls]]"
    }
    if {$detail} {
        foreach s $selected {
            lassign $s label name - trace
            puts "    selected   $label.$name: [lindex $trace 0] demand [join [lindex $trace 1] { -> }]"
        }
        foreach s $suppressed {
            lassign $s label name - trace
            set items [lindex $trace 1]
            puts "    suppressed $label.$name: no raw consumer; tagged: [expr {$items eq "" ? "(none)" : [join $items {, }]}]"
        }
    }
    foreach {k v} [list examined $examined eligP $eligP selP $selP eligR $eligR selR $selR anyB $anyB anyC $anyC bothC $bothC] {
        total $k $v
    }
    foreach name {A B C} {
        set r [dict get $res $name]
        lassign [dict get $r conv] rb rub brb brub
        total rbox$name $rb
        total runbox$name $rub
        total bytes$name [dict get $r bytes]
        dict for {k v} [dict get $r cls] { total cls$name:$k $v }
    }
}
puts "TOTALS: [lsort -stride 2 $totals]"
