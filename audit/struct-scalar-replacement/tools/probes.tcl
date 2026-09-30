#!/usr/bin/env tclsh9.0
# probes.tcl -- the width / direction / distance / nesting experiments of
# STRUCT-SCALAR-REPLACEMENT.md. Observation only (generates its own probe
# programs; no canonical source is touched).
#
#   (cd TREE && tclsh9.0 audit/struct-scalar-replacement/tools/probes.tcl OUTFILE ?RUNS? ?SECTION...?)
#
# SECTION is any of: width distance nesting (default: all).
#
# Every probe is a counted loop of ITERS iterations in which one struct value
# is built and all of its fields consumed, so the work per iteration is the
# transport of the struct and nothing else. Per probe and per mode:
#   physical   -struct-opt 0: every struct is a StructObj (the structs
#              milestone's lowering)
#   virtual    struct scalar replacement with every width cap raised to 32,
#              so the width under test is never rejected by policy
#   default    struct scalar replacement with the shipped width policy
# the report gives Struct allocations, machine-code bytes of the whole
# program and of the functions under test, the number of stack-slot accesses
# in the machine code of those functions (a mechanical spill indicator:
# `[rsp+..]`/`[rbp-..]` operands, counted from the disassembly of the
# unlinked object), and best-of-RUNS native time per iteration. Tiny-leaf
# inlining is off for all probes (the boundary under test must stay a call).
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 2000000
lassign $argv outfile runs
if {$runs eq ""} { set runs 15 }
set sections [lrange $argv 2 end]
if {$sections eq ""} { set sections {width distance nesting} }
set ITERS 200000

set wide {-struct-local-width 32 -struct-return-width 32 -struct-arg-width 32}
set common {-tiny-leaf-inline-opt 0}
set modes [list \
    physical [concat $common {-struct-opt 0}] \
    virtual  [concat $common $wide] \
    default  $common]

proc fieldNames {w} {
    set r {}
    for {set i 0} {$i < $w} {incr i} { lappend r f$i }
    return $r
}
proc literal {w base} {
    set parts {}
    for {set i 0} {$i < $w} {incr i} { lappend parts "f$i: $base + $i" }
    return "\{[join $parts {, }]\}"
}
proc sumOf {w var} { return [join [lmap f [fieldNames $w] {string cat $var . $f}] { + }] }

# Stack-slot operand count of the machine code of the named functions.
proc spills {hir opts names} {
    set obj [file join [pwd] probe-[pid].o]
    native::object $hir $obj {*}$opts
    set pipe [open |[list objdump -d --no-show-raw-insn -M intel $obj] r]
    set text [read $pipe]; close $pipe
    file delete -force $obj
    set nir [dict get [native::lowered $hir {*}$opts] text]
    set ids {}
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)"} $line -> id name] && $name in $names} { lappend ids $id }
    }
    set total 0
    set current ""
    foreach line [split $text \n] {
        if {[regexp {^[0-9a-f]+ <botlish_(?:fn|entry)_(\d+)>:} $line -> id]} {
            set current $id
            continue
        }
        if {$current in $ids && [regexp {\[r[sb]p[+-]} $line]} { incr total }
    }
    return $total
}

proc funcBytes {hir opts names} {
    lassign [native::codeSize $hir {*}$opts] total per
    set nir [dict get [native::lowered $hir {*}$opts] text]
    set sum 0
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)"} $line -> id name] && $name in $names} {
            incr sum [lindex $per $id]
        }
    }
    return [list $total $sum]
}

proc run {label source names} {
    global modes runs ITERS out
    if {[catch {set hir [surface::compile $source probe.bot -strict 0]} msg]} {
        lappend out "$label: COMPILE ERROR $msg"
        return
    }
    foreach {mode opts} $modes {
        if {[catch {
            set report [native::allocationReport $hir summary 1 {*}$opts]
            set structs [dict get $report byKind Struct allocations]
            set allocs [dict get $report total allocations]
            lassign [funcBytes $hir $opts $names] total fnBytes
            set stack [spills $hir $opts $names]
            lassign [native::measure $hir $runs {*}$opts] lower jit best collections value
            set nir [dict get [native::lowered $hir {*}$opts] text]
            set sn [regexp -all {= structnew } $nir]
            set cm [regexp -all {= callmulti } $nir]
            set params [lmap n $names {
                if {[regexp "^func \\d+ \"$n\" params=(\\d+)" $nir -> p]} {set p} else {continue}
            }]
            lappend out [format "%-34s %-8s struct-allocs %7d  structnew %2d callmulti %2d  fn-params %-10s code %6d B (fns %5d B)  stack-ops %4d  %9.1f us  %7.2f ns/iter  value %s" \
                $label $mode $structs $sn $cm [join $params /] $total $fnBytes $stack $best \
                [expr {$best * 1000.0 / $ITERS}] [core::value::show $value]]
        } msg]} {
            lappend out "$label $mode: ERROR $msg"
        }
    }
}

set out {}
# ---------------------------------------------------------------- width
if {"width" in $sections} {
    foreach w {0 1 2 3 4 6 8 16} {
        set fields [fieldNames $w]
        # return direction: mk builds the struct, the loop consumes every field
        set uses [expr {$w == 0 ? "0" : [sumOf $w r]}]
        run "width-$w return" "
fn mk(i):
    [literal $w i]
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = mk(i)
    drive(i + 1, n, acc + $uses)
drive(0, $ITERS, 0)
" {mk drive}
        # argument direction: the loop builds the struct, use consumes every field
        set uses2 [expr {$w == 0 ? "0" : [sumOf $w x]}]
        run "width-$w argument" "
fn consume_fields(x, k):
    $uses2 + k
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + consume_fields([literal $w i], i))
drive(0, $ITERS, 0)
" {consume_fields drive}
        # local only
        run "width-$w local" "
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = [literal $w i]
    drive(i + 1, n, acc + $uses)
drive(0, $ITERS, 0)
" {drive}
    }
}
# ------------------------------------------------------------- distance
if {"distance" in $sections} {
    foreach w {2 8} {
        set uses [sumOf $w r]
        foreach d {0 1 2 4 8} {
            # return chain: mk -> ret1 -> ... -> retD, the loop projects
            set chain "fn ret0(i):\n    [literal $w i]\n"
            for {set k 1} {$k <= $d} {incr k} {
                append chain "fn ret${k}(i):\n    ret[expr {$k - 1}](i)\n"
            }
            run "distance-$d width-$w return" "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = ret${d}(i)
    drive(i + 1, n, acc + $uses)
drive(0, $ITERS, 0)
" [lmap k [lrange {0 1 2 3 4 5 6 7 8} 0 $d] {string cat ret $k}]
            # argument chain: loop -> fwdD -> ... -> fwd1 -> use
            set chain "fn fwd0(r, k):\n    $uses + k\n"
            for {set k 1} {$k <= $d} {incr k} {
                append chain "fn fwd${k}(r, k):\n    fwd[expr {$k - 1}](r, k)\n"
            }
            run "distance-$d width-$w argument" "$chain
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + fwd${d}([literal $w i], i))
drive(0, $ITERS, 0)
" [lmap k [lrange {0 1 2 3 4 5 6 7 8} 0 $d] {string cat fwd $k}]
        }
    }
}
# -------------------------------------------------------------- nesting
if {"nesting" in $sections} {
    set shapes [dict create \
        flat4 [list "\{a: i, b: i + 1, c: i + 2, d: i + 3\}" {r.a + r.b + r.c + r.d}] \
        inner1 [list "\{a: i, b: i + 1, inner: \{c: i + 2, d: i + 3\}\}" {r.a + r.b + r.inner.c + r.inner.d}] \
        inner2 [list "\{left: \{a: i, b: i + 1\}, right: \{c: i + 2, d: i + 3\}\}" {r.left.a + r.left.b + r.right.c + r.right.d}]]
    dict for {name spec} $shapes {
        lassign $spec lit uses
        run "nesting-$name return" "
fn mk(i):
    $lit
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = mk(i)
    drive(i + 1, n, acc + $uses)
drive(0, $ITERS, 0)
" {mk drive}
        run "nesting-$name argument" "
fn consume_fields(r, k):
    $uses + k
fn drive(i, n, acc):
    if i >= n:
        return acc
    drive(i + 1, n, acc + consume_fields($lit, i))
drive(0, $ITERS, 0)
" {consume_fields drive}
        run "nesting-$name local" "
fn drive(i, n, acc):
    if i >= n:
        return acc
    r = $lit
    drive(i + 1, n, acc + $uses)
drive(0, $ITERS, 0)
" {drive}
    }
}
set f [open $outfile w]
fconfigure $f -encoding utf-8
puts $f [join $out \n]
close $f
puts "wrote $outfile"
