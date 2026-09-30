#!/usr/bin/env tclsh9.0
# Observation only. Current surface sources; no historical corpus discovery.
set root [pwd]
source compiler/compiler.tcl
source surface/surface.tcl
source native/native.tcl
interp recursionlimit {} 20000
set out [file join $root audit post-structural-fn-dynamic-census out]
if {[llength $argv]} {set out [lindex $argv 0]}
file mkdir $out
proc W {p s} {set f [open $p w]; fconfigure $f -encoding utf-8; puts $f $s; close $f}
proc Q {s} {return \"[string map [list \\ \\\\ \" \\\" \n \\n \r \\r \t \\t] $s]\"}
proc record {channel args} {
    set parts {}
    foreach {k v} $args {lappend parts "[Q $k]:[Q $v]"}
    puts $channel \{[join $parts ,]\}
}
set f [open [file join $out static.jsonl] w]
fconfigure $f -encoding utf-8
set manifest {}
set total 0
foreach path [concat [lsort [glob bench/*.bot]] [lsort [glob examples/stdlib/*.bot]] [lsort [glob examples/surface/*.bot]]] {
    lappend manifest $path
    set stem [string map {/ __ .bot {}} $path]
    puts "static $path"
    record $f kind source program $path blob [exec git hash-object $path]
    if {[catch {
        set surface [surface::readProgramFile $path]
        set hir [native::prepareHir $surface]
        set spec [hir::specialize::analyze $hir]
        set lowered [native::lower::program $hir]
        set nir [dict get $lowered text]
    } err opts]} {
        record $f kind excluded program $path reason $err errorcode [dict get $opts -errorcode]
        continue
    }
    W [file join $out $stem.nir] $nir
    W [file join $out $stem.hir.txt] $hir
    W [file join $out $stem.spec.txt] $spec
    set counts [dict create call 0 callenv 0 callvalue 0 closure 0 capture 0 fnvalue 0 native 0 callmulti 0 callenvmulti 0]
    set fid {}; set fname {}; set key {}
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)".*instance="([^"]*)"} $line -> fid fname key]} {
            record $f kind function program $path fid $fid name $fname key $key header $line
        }
        if {[regexp {= (call|callenv|callvalue|closure|capture|fnvalue|native|callmulti|callenvmulti)(?: |$)} $line -> op]} {
            dict incr counts $op
            if {$op eq "callvalue"} {
                regexp {@(e\d+)} $line -> e
                record $f kind site program $path fid $fid name $fname key $key expr $e instruction [string trim $line]
            }
        }
    }
    if {[string match bench/* $path]} {incr total [dict get $counts callvalue]}
    record $f kind totals program $path instances [llength [dict get $spec used]] {*}$counts
    foreach id [dict get $spec used] {
        set inst [hir::specialize::instance $spec $id]
        set view [hir::specialize::view $hir $spec $id]
        set block [dict get $inst block]
        set caps {}; set params {}; set closed {}
        if {$block ne "program"} {
            set caps [hir::captures $hir $block]
            set params [hir::get $hir $block params]
            set closed [hir::specialize::closedCallerTheorem $hir $spec $id]
        }
        set aot [hir::aot::analyzeRegion $view $block]
        record $f kind instance program $path id $id label [hir::specialize::label $spec $id] block $block params $params captures $caps generic [dict get $inst generic] closedTheorem $closed aot [dict get $aot status]
        foreach e [dict get $inst reachable] {
            if {[hir::kind $view $e] ne "call"} continue
            set target [expr {[dict exists $inst calls $e] ? [dict get $inst calls $e] : ""}]
            set callee [hir::get $view $e callee]
            record $f kind call program $path instance $id expr $e targetInstance $target callee $callee calleeType [hir::types::show [hir::typeOf $view $callee]] node [dict get $view exprs $e] calleeNode [dict get $view exprs $callee]
            set index 0
            foreach arg [hir::get $view $e args] {
                set t [hir::typeOf $view $arg]
                set captures {}
                if {[lindex $t 0] eq "block" && [llength $t]>1} {set captures [hir::captures $hir [lindex $t 1]]}
                record $f kind argument program $path instance $id call $e index $index expr $arg type [hir::types::show $t] rawtype $t captures $captures node [dict get $view exprs $arg]
                incr index
            }
        }
    }
    foreach {e node} [dict get $hir exprs] {
        record $f kind expression program $path expr $e type [hir::types::show [hir::typeOf $hir $e]] node $node
    }
    foreach {b node} [dict get $hir bindings] {record $f kind binding program $path binding $b node $node}
    foreach {e node} [dict get $surface exprs] {
        if {[dict get $node kind] eq "call"} {record $f kind sourceCall program $path expr $e node $node location [hir::aot::Location $surface [dict get $node origin]]}
    }
}
close $f
W [file join $out corpus.txt] [join $manifest \n]
W [file join $out provenance.txt] "commit: [exec git rev-parse HEAD]\nTcl: [info patchlevel]\nrustc: [exec rustc --version]\ntarget: [exec uname -m]\nflags: production defaults, specialize=1, repr-opt=1\nfrontend: surface::readProgramFile -> native::prepareHir (direct HIR path)\nbenchmark callvalue sites: $total"
if {$total != 9} {error "STOP: expected 9 benchmark callvalue sites, found $total"}
puts "confirmed $total benchmark callvalue sites"
