#!/usr/bin/env tclsh9.0
# demand.tcl -- RAW-INT-ABI.md "Raw-demand suppression": the three-way audit.
#
# For each canonical program, three configurations:
#
#   A  -raw-int-abi-opt 0                    the tagged baseline (pre-RawInt)
#   B  -raw-int-abi-opt 1 -raw-demand-opt 0  RawInt eligibility only
#                                            (eligible => raw: the preliminary)
#   C  ... -raw-mixed-policy raw             RawInt + demand suppression, a
#                                            position with any raw consumer
#                                            stays raw (the earlier policy)
#   D  -raw-int-abi-opt 1 (defaults)         RawInt + demand suppression, mixed
#                                            raw/tagged uses boxed (production)
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
    C {-raw-int-abi-opt 1 -raw-demand-opt 1 -raw-mixed-policy raw}
    D {-raw-int-abi-opt 1 -raw-demand-opt 1 -raw-mixed-policy boxed}
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
    # Census from D's plan (carries eligibility), B's (all eligible raw) and
    # C's (mixed uses kept raw).
    set lowC [dict get $res D lowered]
    set spec [dict get $lowC specialization]
    set planC [dict get $lowC abiPlan]
    set planB [dict get [dict get $res B lowered] abiPlan]
    set planM [dict get [dict get $res C lowered] abiPlan]
    set eligP 0; set selP 0; set eligR 0; set selR 0; set anyB 0; set anyD 0; set anyC 0; set bothD 0
    set mixP 0; set mixR 0; set noP 0; set noR 0; set selMP 0; set selMR 0
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
        set nSel 0
        foreach eligible [dict get $p paramEligible] kind [dict get $p params] reason [dict get $p paramReasons] \
                name $names trace [dict get $p paramTrace] {
            if {!$eligible} continue
            incr eligP
            if {$kind eq "rawint"} {
                incr selP; incr nSel
                lappend selected [list $label $name $trace]
            } else {
                if {$reason eq "suppressed-mixed-tagged-use"} { incr mixP } else { incr noP }
                lappend suppressed [list $label $name $reason $trace]
            }
        }
        if {[dict get $p resultEligible]} {
            incr eligR
            if {[dict get $p result] eq "rawint"} {
                incr selR; incr nSel
                lappend selected [list $label result [dict get $p resultTrace]]
            } else {
                set reason [dict get $p resultReason]
                if {$reason eq "suppressed-mixed-tagged-use"} { incr mixR } else { incr noR }
                lappend suppressed [list $label result $reason [dict get $p resultTrace]]
            }
        }
        proc anyRaw {q} { return [expr {"rawint" in [dict get $q params] || [dict get $q result] eq "rawint"}] }
        if {[anyRaw [dict get $planB $id]]} { incr anyB }
        if {[anyRaw [dict get $planM $id]]} { incr anyC }
        if {$nSel > 0} { incr anyD }
        if {[dict get $p result] eq "rawint" && "rawint" in [dict get $p params]} { incr bothD }
        set q [dict get $planM $id]
        incr selMP [llength [lsearch -all -exact [dict get $q params] rawint]]
        incr selMR [expr {[dict get $q result] eq "rawint"}]
    }
    set examined [expr {[llength [dict get $spec used]] - 1}]
    puts "$path:"
    puts "  instances examined $examined; instances with any raw position: B $anyB, C $anyC, D $anyD (both param+result in D: $bothD)"
    puts "  positions eligible/selected: parameters $eligP/$selP (C: $selMP); results $eligR/$selR (C: $selMR)"
    puts "  suppressed (D): parameters no-raw-demand $noP, mixed-tagged-use $mixP; results no-raw-demand $noR, mixed-tagged-use $mixR"
    foreach name {A B C D} {
        set r [dict get $res $name]
        lassign [dict get $r conv] rb rub brb brub
        puts "  $name: rbox $rb runbox $rub; machine bytes [dict get $r bytes]; rbox classes [lsort -stride 2 [dict get $r cls]]"
    }
    if {$detail} {
        foreach s $selected {
            lassign $s label name trace
            puts "    selected   $label.$name: raw demand [join [lindex $trace 1] { -> }]"
        }
        foreach s $suppressed {
            lassign $s label name reason trace
            if {$reason eq "suppressed-mixed-tagged-use"} {
                puts "    mixed      $label.$name: raw demand [join [lindex $trace 1] { -> }]; but tagged: [join [lindex $trace 2] {, }]"
            } else {
                set items [lindex $trace 1]
                puts "    suppressed $label.$name: no raw consumer; tagged: [expr {$items eq "" ? "(none)" : [join $items {, }]}]"
            }
        }
    }
    foreach {k v} [list examined $examined eligP $eligP selP $selP selMP $selMP eligR $eligR selR $selR selMR $selMR \
            anyB $anyB anyC $anyC anyD $anyD bothD $bothD noP $noP mixP $mixP noR $noR mixR $mixR] {
        total $k $v
    }
    foreach name {A B C D} {
        set r [dict get $res $name]
        lassign [dict get $r conv] rb rub brb brub
        total rbox$name $rb
        total runbox$name $rub
        total bytes$name [dict get $r bytes]
        dict for {k v} [dict get $r cls] { total cls$name:$k $v }
    }
}
puts "TOTALS: [lsort -stride 2 $totals]"
