#!/usr/bin/env tclsh9.0
# budget.tcl N LIMIT -- EXACT-CALLABLE-CLOSED-CALLER.md "Specialization budget": N distinct exact targets into one two-call higher-order function, exactLimit LIMIT; prints instances, callvalue sites, emitted functions, machine-code bytes (native::codeSize) and lowering time. Run from the repository root.
set root [pwd]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $args n limit
set ::hir::specialize::exactLimit $limit
set src ""
for {set k 1} {$k <= $n} {incr k} {
    append src "fn p${k}(x):\n    x < [expr {$k * 3}]\n\n"
}
append src "fn apply_loop(f, i, n):\n    acc = 0\n    loop j from i to n:\n        if f(j) == false:\n            return j + acc\n        if f(j + 1) == false:\n            return j + acc + 1\n    n\n\n"
set calls {}
for {set k 1} {$k <= $n} {incr k} { lappend calls "apply_loop(p${k}, 0, 100)" }
append src "\[[join $calls {, }]\]\n"
set hir [surface::compile [surface::modules::ImportHeader $src]$src budget.bot -strict 0]
set t0 [clock microseconds]
set nir [native::nir $hir]
set ms [expr {([clock microseconds]-$t0)/1000}]
set bytes [lindex [native::codeSize $hir] 0]
puts [format "N=%-2d limit=%-2d apply_loop-instances=%-2d callvalue=%d funcs=%-3d bytes=%-6d lower_ms=%d" $n $limit [regexp -all {func \d+ "apply_loop"} $nir] [regexp -all {callvalue} $nir] [regexp -all {\nfunc } $nir] $bytes $ms]
