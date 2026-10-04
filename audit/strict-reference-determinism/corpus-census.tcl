# corpus-census.tcl -- forward-reference census over the source corpus.
#
#   tclsh9.0 audit/strict-reference-determinism/corpus-census.tcl [-root DIR]
#
# Builds the HIR of every program under bench/, examples/ and lib/ (a
# non-strict build, so a program the compiler already rejects is still
# audited) and lists every reference that violates the strict-reference
# invariant (refcheck.tcl), grouped by source area and shape. Run against the
# pre-change compiler it counts the forward references the corpus depends on;
# run against the strict compiler every program must report 0 (and a program
# with a forward reference fails to build at all, reported as REJECTED).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
foreach {option value} $argv {
    switch -- $option {
        -root { set root [file normalize $value] }
        default { error "unknown option $option" }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
# hir/refcheck.tcl is independent of the resolver, so the same checker audits
# either tree (the pre-change tree has no copy of its own: sourced from here).
if {[info commands hir::refcheck::forwardRefs] eq ""} {
    source [file join [file dirname [file dirname $here]] hir refcheck.tcl]
}

proc build {path} {
    switch -- [file extension $path] {
        .bot {
            return [surface::readProgramFile $path -strict 0]
        }
        .hir {
            return [hir::readFile $path]
        }
        .ir {
            return [hir::build [core::loadProgramFile $path] -strict 0]
        }
    }
}

proc buildModule {name} {
    set loaded [surface::modules::LoadNamespaces [list $name]]
    return [hir::buildSyntax {} -strict 0 -files [dict get $loaded files] \
        -modules [dict get $loaded sections] -imports [dict get $loaded imports] \
        -type-decls [dict get $loaded typeDecls] -error-decls [dict get $loaded errorDecls]]
}

set areas {
    {production  examples/surface/*.bot}
    {stdlib      lib/*.bot}
    {corpus      examples/stdlib/*.bot}
    {benchmark   bench/*.bot bench/*.ir}
    {hir-fixture examples/hir/*.hir examples/*.ir}
}
set totals [dict create]
set programs 0
foreach area $areas {
    set name [lindex $area 0]
    foreach pattern [lrange $area 1 end] {
        foreach path [lsort [glob -nocomplain -directory $root $pattern]] {
            set rel [string range $path [string length $root/] end]
            incr programs
            if {$name eq "stdlib"} {
                set label "$rel (as module)"
                set run [list buildModule [file rootname [file tail $path]]]
            } else {
                set label $rel
                set run [list build $path]
            }
            if {[catch $run hir]} {
                puts [format {%-13s %-52s REJECTED: %s} $name $label [string range [lindex [split $hir \n] 0] 0 100]]
                dict incr totals "$name rejected"
                continue
            }
            set found [hir::refcheck::forwardRefs $hir]
            # The strict resolver leaves a reference whose binding is not yet
            # established unresolved (UNBOUND diagnostic), so a forward
            # reference never reaches the HIR: count those as rejected.
            set unbound [lsearch -all -inline -exact [lmap d [hir::diagnostics $hir] {dict get $d kind}] UNBOUND]
            puts [format {%-13s %-52s %d forward reference(s), %d unbound name(s)} $name $label [llength $found] [llength $unbound]]
            if {[llength $unbound]} {
                dict incr totals "$name unbound-name-diagnostics" [llength $unbound]
            }
            foreach f $found {
                puts "    [dict get $f shape]: \"[dict get $f name]\" ([dict get $f kind]) at [dict get [dict get $hir exprs [dict get $f ref]] origin]"
                dict incr totals "$name [dict get $f shape]"
            }
        }
    }
}
puts "\nprograms audited: $programs"
puts "totals by area and shape:"
foreach key [lsort [dict keys $totals]] {
    puts [format {  %-46s %d} $key [dict get $totals $key]]
}
if {[dict size $totals] == 0} {
    puts "  (no forward references, no rejected programs)"
}
