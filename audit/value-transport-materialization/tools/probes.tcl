#!/usr/bin/env tclsh9.0
# probes.tcl -- the width / distance / direction / frontier / nesting probes of
# VALUE-TRANSPORT-MATERIALIZATION.md. Observation only: every probe program is
# generated here (tools/shapes.tcl); no canonical source is touched.
#
#   (cd TREE && tclsh9.0 audit/value-transport-materialization/tools/probes.tcl OUTFILE ?RUNS? ?SECTION...?)
#
# SECTION is any of: grid-arg grid-ret narrow wide-return wide-arg late direction
# mixed branchy nested cyclic (default: all). Every probe is a counted loop of
# ITERS iterations in which one struct value is built, carried and consumed, so
# the work per iteration is the transport of that value and nothing else.
# Tiny-leaf inlining is off (the boundary under test must stay a call).
#
# Per probe and per mode (physical = `-struct-opt 0`, every struct a StructObj;
# virtual = the transport policy with every budget and ceiling raised so
# nothing is ever materialized for cost reasons; legacy = the previous
# milestone's width-only caps 16/8/4; default = the shipped transport policy)
# one record: Struct allocations, allocated bytes, GC cycles, machine-code bytes
# of the whole program and of the functions under test, stack-slot operands in
# those functions (a mechanical spill indicator: `[rsp+..]`/`[rbp-..]` operands
# of the disassembly), argument and result registers of the functions under
# test, and best-of-RUNS native time per iteration. Records are also written
# tab-separated to OUTFILE.tsv.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tests transport-shapes.tcl]
interp recursionlimit {} 2000000
lassign $argv outfile runs
if {$runs eq ""} { set runs 15 }
set sections [lrange $argv 2 end]
set all {grid-arg grid-ret narrow wide-return wide-arg late direction mixed branchy nested cyclic}
if {$sections eq ""} { set sections $all }
set ITERS 200000

set raised {-struct-local-width 64 -struct-return-width 64 -struct-arg-width 64 \
    -struct-arg-budget 1e12 -struct-return-budget 1e12 -struct-cycle-budget 1e12}
set common {-tiny-leaf-inline-opt 0}
set modes [list \
    physical [concat $common {-struct-opt 0}] \
    virtual  [concat $common $raised] \
    legacy   [concat $common {-struct-policy legacy}] \
    default  $common]
if {[info exists ::env(PROBE_MODES)]} {
    set keep $::env(PROBE_MODES)
    set filtered {}
    foreach {m o} $modes { if {$m in $keep} { lappend filtered $m $o } }
    set modes $filtered
}

# Stack-slot operand count of the machine code of the named functions.
proc disasm {hir opts} {
    set obj [file join [pwd] probe-[pid].o]
    native::object $hir $obj {*}$opts
    set pipe [open |[list objdump -d --no-show-raw-insn -M intel $obj] r]
    set text [read $pipe]; close $pipe
    file delete -force $obj
    return $text
}
proc fnIds {nir names} {
    set ids {}
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)"} $line -> id name] && $name in $names} { lappend ids $id }
    }
    return $ids
}
proc spills {disasm ids} {
    set total 0
    set current ""
    foreach line [split $disasm \n] {
        if {[regexp {^[0-9a-f]+ <botlish_(?:fn|entry)_(\d+)>:} $line -> id]} {
            set current $id
            continue
        }
        if {$current in $ids && [regexp {\[r[sb]p[+-]} $line]} { incr total }
    }
    return $total
}

set out {}
set tsv {}
proc run {label source names} {
    global modes runs ITERS out tsv
    if {[catch {set hir [surface::compile $source probe.bot -strict 0]} msg]} {
        lappend out "$label: COMPILE ERROR $msg"
        return
    }
    foreach {mode opts} $modes {
        if {[catch {
            set report [native::allocationReport $hir summary 1 {*}$opts]
            set structs [dict get $report byKind Struct allocations]
            set bytes [dict get $report total allocatedBytes]
            set nir [dict get [native::lowered $hir {*}$opts] text]
            set ids [fnIds $nir $names]
            lassign [native::codeSize $hir {*}$opts] total per
            set fnBytes 0
            foreach id $ids { incr fnBytes [lindex $per $id] }
            set stack [spills [disasm $hir $opts] $ids]
            lassign [native::measure $hir $runs {*}$opts] lower jit best collections value
            set gcc [dict get $report gc cycles]
            set hops [native::NirHops $nir]
            set sn [regexp -all {= structnew } $nir]
            set cm [regexp -all {= callmulti } $nir]
            set sig {}
            foreach line [split $nir \n] {
                if {[regexp {^func (\d+) "([^"]*)" params=(\d+)} $line -> id n p] && $n in $names} {
                    regexp {results=(\d+)} $line -> r
                    lappend sig "$n:$p[expr {[info exists r] ? ">$r" : ""}]"
                    unset -nocomplain r
                }
            }
            set ns [expr {$best * 1000.0 / $ITERS}]
            lappend out [format "%-34s %-8s struct-allocs %7d bytes %9d gc %2d  structnew %2d callmulti %2d  hops arg %3d ret %3d  code %6d B (fns %5d B)  stack-ops %4d  %7.2f ns/iter  sig %s  value %s" \
                $label $mode $structs $bytes $gcc $sn $cm [dict get $hops arg] [dict get $hops return] $total $fnBytes $stack $ns [join $sig ,] [core::value::show $value]]
            lappend tsv [join [list $label $mode $structs $bytes $gcc $sn $cm $total $fnBytes $stack $ns [join $sig ,] [core::value::show $value] [dict get $hops arg] [dict get $hops return]] \t]
        } msg]} {
            lappend out "$label $mode: ERROR $msg"
        }
    }
}
proc names {prefix n} { return [lmap k [lrange {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} 0 [expr {$n - 1}]] {string cat $prefix $k}] }

if {"grid-arg" in $sections} {
    foreach w {2 3 4 5 6 8} {
        foreach e {1 2 3 4 6 8 12} {
            run "arg W=$w E=$e" [chainArg $w $e $ITERS] [concat [names fwd $e] drive]
        }
    }
}
if {"grid-ret" in $sections} {
    foreach w {2 3 4 6 8 12} {
        foreach e {1 2 3 4 6 8 12} {
            run "ret W=$w E=$e" [chainRet $w $e $ITERS] [concat [names ret $e] drive]
        }
    }
}
if {"narrow" in $sections} {
    foreach e {1 4 8 12 16} {
        run "narrow-arg W=2 E=$e" [chainArg 2 $e $ITERS] [concat [names fwd $e] drive]
    }
}
if {"wide-return" in $sections} {
    foreach {w e} {6 1 6 2 8 1 8 2 8 3} {
        run "wide-return W=$w E=$e" [chainRet $w $e $ITERS] [concat [names ret $e] drive]
    }
}
if {"wide-arg" in $sections} {
    foreach {w e} {8 4 8 6 8 8} {
        run "wide-arg W=$w E=$e" [chainArg $w $e $ITERS] [concat [names fwd $e] drive]
    }
}
if {"late" in $sections} {
    foreach {w e} {8 4 8 6 8 8 6 4} {
        run "late-frontier W=$w E=$e" [lateFrontier $w $e $ITERS] [concat [names fwd $e] drive]
    }
}
if {"direction" in $sections} {
    foreach {w e} {4 6 4 8 6 3 6 4} {
        run "direction-arg W=$w E=$e" [chainArg $w $e $ITERS] [concat [names fwd $e] drive]
        run "direction-ret W=$w E=$e" [chainRet $w $e $ITERS] [concat [names ret $e] drive]
    }
}
if {"mixed" in $sections} {
    foreach {w r a} {4 3 3 4 6 6 2 4 4 6 3 2 8 4 1} {
        run "mixed W=$w R=$r A=$a" [mixed $w $r $a $ITERS] [concat [names ret $r] [names fwd $a] drive]
    }
}
if {"branchy" in $sections} {
    foreach {w e} {8 6 4 8 4 2} {
        run "branchy W=$w E=$e" [branchy $w $e $ITERS] [concat [names fwd $e] drive]
    }
}
if {"nested" in $sections} {
    foreach {name src uses} [nestedProbes] {
        foreach {dirName source names} [nestedPrograms $name $src $uses $ITERS] {
            run "nested-$name $dirName" $source $names
        }
    }
}
if {"cyclic" in $sections} {
    foreach w {2 3 4 5 6 8} {
        run "cyclic W=$w" [selfTail $w $ITERS] {spin}
    }
}
set f [open $outfile w]
fconfigure $f -encoding utf-8
puts $f [join $out \n]
close $f
set f [open $outfile.tsv w]
fconfigure $f -encoding utf-8
puts $f [join $tsv \n]
close $f
puts "wrote $outfile"
