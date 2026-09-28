#!/usr/bin/env tclsh9.0
# Offline proof witnesses only. No HIR fields, types or lowering are changed.
source compiler/compiler.tcl
source surface/surface.tcl
source native/native.tcl
set out audit/post-structural-fn-dynamic-census/out
proc readfile {p} {set f [open $p]; set s [read $f]; close $f; return $s}
proc Q {s} {return \"[string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t] $s]\"}
proc record {args} {
    global json
    set parts {}; foreach {k v} $args {lappend parts "[Q $k]:[Q $v]"}
    puts $json \{[join $parts ,]\}
}
proc View {id} {global views; return [dict get $views $id]}
proc Union {sets} {
    set all {}; foreach s $sets {if {$s eq "Unknown"} {return Unknown}; lappend all {*}$s}
    if {$all eq {}} {return Unknown}; return [lsort -unique $all]
}
proc Targets {id e {seen {}} {elements 0}} {
    global hir spec proof
    set token [list $id $e $elements]
    if {$token in $seen} {return Unknown}
    lappend seen $token
    set view [View $id]
    set t [hir::typeOf $view $e]
    if {!$elements && [llength $t]>1 && [lindex $t 0] in {native block}} {
        return [list [list [lindex $t 0] [lindex $t 1]]]
    }
    set n [dict get $hir exprs $e]
    switch -- [dict get $n kind] {
        ref {
            set b [dict get $n binding]
            set binding [hir::binding $hir $b]
            set declaration [dict get $binding declaredBy]
            if {$declaration ne {} && [hir::kind $hir $declaration] eq "bind"} {
                return [Targets $id [hir::get $hir $declaration value] $seen $elements]
            }
            # Immutable loop elements inherit the union of their literal's
            # code targets, without any positional assumption.
            dict for {le ln} [dict get $hir exprs] {
                if {[dict get $ln kind] eq "listloop" && [dict get $ln elementBinding] eq $b} {
                    return [Targets $id [dict get $ln iterable] $seen 1]
                }
            }
            # Parameters captured from an enclosing activation use all used
            # instances of that lexical owner. Unknown ingress stays Unknown.
            set owners {}
            foreach oid [dict get $spec used] {
                set oi [hir::specialize::instance $spec $oid]
                set block [dict get $oi block]
                if {$block eq "program"} continue
                set params [hir::get $hir $block params]
                set ix [lsearch -exact $params $b]
                if {$ix>=0} {lappend owners [list $oid $ix]}
            }
            foreach pair $owners {if {[lindex $pair 0] eq $id} {set owners [list $pair]; break}}
            set sets {}
            foreach pair $owners {
                lassign $pair owner ix
                set found 0
                foreach caller [dict get $spec used] {
                    set ci [hir::specialize::instance $spec $caller]
                    dict for {call target} [dict get $ci calls] {
                        if {$target ne $owner || $call ni [dict get $ci reachable]} continue
                        set found 1
                        set arg [lindex [hir::get $hir $call args] $ix]
                        set targets [Targets $caller $arg $seen $elements]
                        lappend sets $targets
                        puts $proof "  ingress $owner/[dict get $binding name] <- $caller@$call argument $arg : [hir::types::show [hir::typeOf [View $caller] $arg]] => $targets"
                    }
                }
                if {!$found} {lappend sets Unknown}
            }
            return [Union $sets]
        }
        if {
            return [Union [list [Targets $id [lindex [dict get $n thenBody] end] $seen $elements] [Targets $id [lindex [dict get $n elseBody] end] $seen $elements]]]
        }
        call {
            if {$elements && [lindex [dict get $n target] 0] eq "native"} {
                set sym [lindex [dict get $n target] 1]
                if {[dict get [hir::symbol $hir $sym] name] eq "list"} {
                    set sets {}; foreach a [dict get $n args] {lappend sets [Targets $id $a $seen]}
                    return [Union $sets]
                }
            }
            set inst [hir::specialize::instance $spec $id]
            if {[dict exists $inst calls $e]} {
                set target [dict get $inst calls $e]
                set block [dict get [hir::specialize::instance $spec $target] block]
                # This case deliberately accepts only a sole final if/expr
                # and no return statements; it is not a general dataflow pass.
                set body [hir::get $hir $block body]
                if {[llength $body] == 1} {return [Targets $target [lindex $body end] $seen $elements]}
            }
        }
    }
    return Unknown
}

set json [open $out/proofs.jsonl w]
set proof [open $out/proof-witnesses.txt w]
foreach p [lsort [glob $out/bench__*.hir.txt]] {
    set hir [readfile $p]
    set spec [readfile [string map {.hir.txt .spec.txt} $p]]
    set views {}; foreach id [dict get $spec used] {dict set views $id [hir::specialize::view $hir $spec $id]}
    set name [string map {bench__ bench/ .hir.txt .bot} [file tail $p]]
    set nir [readfile [string map {.hir.txt .nir} $p]]
    set functions {}
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)".*instance="([^"]*)"} $line -> fid fn key]} {
            set label [expr {$fn eq "<program>" ? $fn : "$fn<$key>"}]
            set id {}
            foreach candidate [dict get $spec used] {if {[hir::specialize::label $spec $candidate] eq $label} {set id $candidate; break}}
            dict set functions $fid $id
        }
        if {![regexp {= callvalue .*@(e\d+)} $line -> e]} continue
        if {$id eq {}} {error "No instance for $name $label"}
        set callee [hir::get $hir $e callee]
        puts $proof "\n$name $label/$id @$e"
        set targets [Targets $id $callee]
        puts $proof "  UNION $targets"
        set desc {}
        foreach target $targets {
            lassign $target kind code
            if {$kind eq "block"} {lappend desc "$target captures=[hir::captures $hir $code]"}
        }
        record program $name fid $fid expr $e instance $id label $label type [hir::types::show [hir::typeOf [View $id] $callee]] targets $targets environments $desc
    }
    # Full source types, branch/list witnesses and source locations in the
    # ordinary surface HIR, alongside the benchmark runner's relifted view.
    set surface [surface::readProgramFile $name]
    dict for {e n} [dict get $surface exprs] {
        if {[dict get $n kind] ne "call"} continue
        set c [dict get $n callee]
        if {[hir::kind $surface $c] ne "ref"} continue
        set cn [hir::get $surface $c name]
        if {$cn ni {predicate check classifier}} continue
        record kind sourceSite program $name expr $e callee $cn type [hir::types::show [hir::typeOf $surface $c]] location [hir::aot::Location $surface [dict get $n origin]]
    }
}
close $proof
close $json
