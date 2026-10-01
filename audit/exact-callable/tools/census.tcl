#!/usr/bin/env tclsh9.0
# census.tcl -- EXACT-CALLABLE-CLOSED-CALLER.md: the instance / callvalue
# census of a tree, one line per program plus per-source-function instance
# counts and every callvalue site. Observation only; it uses only entry
# points both the frozen tree (c251e7c lineage) and this milestone's tree
# have, so one script measures "before" and "after".
#
#   (cd TREE && tclsh9.0 .../census.tcl PROGRAM.bot ...)  > OUT.txt
#
# Columns of the summary line (program | ...):
#   sem        valid semantic instances (hir::semantic::census), after
#              native::prepareHir (what the front end proves)
#   used       codegen instances hir::specialize uses
#   emitted    NIR functions lowering emits (canonical + companions + internal)
#   generic    used instances whose key is all `any`
#   exact      used instances with an exact callable (block(E)/native(N)) key
#   kindcall   used instances with a kind-only callable key (`block`/`native`)
#   callvalue  `callvalue` sites in the emitted NIR
#   closures   `closure` allocations sites in the emitted NIR
#   bytes      machine-code bytes of every emitted function (native::codeSize)
set root [pwd]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
fconfigure stdout -encoding utf-8 -translation lf
set programs {}
set options {}
foreach a $args {
    if {[string match -* $a] || [llength $options] % 2 == 1} { lappend options $a } else { lappend programs $a }
}
puts "program | sem | used | emitted | generic | exact | kindcall | callvalue | closures | bytes | lower-ms"
foreach path $programs {
    set hir [surface::readProgramFile $path]
    set prepared [native::prepareHir $hir]
    set sem 0
    foreach r [hir::semantic::census $prepared] {
        if {[dict get $r status] eq "valid"} { incr sem }
    }
    set spec [hir::specialize::analyze $prepared {*}[lmap {k v} $options {expr {$k in {-exact-callable-opt -closed-caller-facts-opt -call-facts-opt} ? [list $k $v] : [continue]}}]]
    set generic 0; set exact 0; set kindcall 0
    set perName [dict create]
    foreach id [dict get $spec used] {
        set inst [dict get $spec instances $id]
        if {[dict get $inst block] eq "program"} continue
        set args [dict get $inst args]
        if {[dict get $inst generic]} { incr generic }
        set hasExact 0; set hasKind 0
        foreach k $args {
            if {[lindex $k 0] in {block native} && [llength $k] > 1} { set hasExact 1 }
            if {$k in {block native}} { set hasKind 1 }
        }
        incr exact $hasExact
        incr kindcall $hasKind
        dict incr perName [expr {[dict get $inst name] eq "" ? "block [dict get $inst block]" : [dict get $inst name]}]
    }
    set t0 [clock microseconds]
    set nir [native::nir $hir {*}$options]
    set ms [expr {([clock microseconds] - $t0) / 1000}]
    set emitted [regexp -all -line {^func } $nir]
    set cv [regexp -all {callvalue} $nir]
    set cl [regexp -all {= closure } $nir]
    # Machine-code bytes of the JIT-compiled program (native::codeSize: the
    # same NIR, every emitted function).
    set sizes {}
    if {[catch {native::codeSize $hir {*}$options} sized]} {
        set bytes n/a
    } else {
        set bytes [lindex $sized 0]
        set sizes [lindex $sized 1]
    }
    puts "$path | $sem | [llength [dict get $spec used]] | $emitted | $generic | $exact | $kindcall | $cv | $cl | $bytes | $ms"
    # per-source-function codegen instance counts (functions with > 1)
    dict for {name n} $perName {
        if {$n > 1} { puts "    instances $name: $n" }
    }
    # every callvalue site: NIR function name + instance; and every emitted
    # function's machine-code bytes (NIR function order = native::codeSize's)
    set cur ""
    set k -1
    foreach line [split $nir \n] {
        if {[regexp {^func \d+ "([^"]*)".*instance="([^"]*)"} $line -> n i]} {
            set cur "$n<$i>"
            incr k
            puts "    fn $cur bytes=[expr {$k < [llength $sizes] ? [lindex $sizes $k] : "?"}]"
        }
        if {[string match "*callvalue*" $line]} { puts "    callvalue in $cur" }
    }
}
