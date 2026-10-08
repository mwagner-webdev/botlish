#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation test of the opacity checks (OPAQUE-STRUCTS.md).
#
#   tclsh9.0 audit/opaque-struct/tools/mutate.tcl ?-n N? ?-only NAME? ?-list 1?
#
# Each mutation disables or breaks exactly one piece of the implementation in
# a scratch copy of the tree (the Tcl sources, never the repository), then runs
# the opaque-struct fuzzer (audit/opaque-struct/tools/fuzz.tcl, interpreter and
# compiler backends, N programs) and tests/opaque-struct.test against it. A
# mutant is KILLED if either fails. A SURVIVOR is a check nothing tests: the
# run exits 1 if there is one.
#
# The mutations (name: what is broken):
#   see the table below; each states the single textual change it makes.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set n 51
set only ""
set listOnly 0
while {[lindex $args 0] in {-n -only -list}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -only { set only [lindex $args 1] }
        -list { set listOnly [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

# {NAME FILE OLD NEW}: NEW replaces the single occurrence of OLD in FILE. Each
# OLD is a fragment of the implementation chosen to contain no unbalanced brace.
set mutations {
    {construction-check-off hir/resolve.tcl
        {[hir::structs::representationDenied $id $ns]}
        {0}}
    {construction-field-diagnostics hir/resolve.tcl
        {# missing), only the one OPAQUE-CONSTRUCTION above.
            break}
        {# missing), only the one OPAQUE-CONSTRUCTION above.}}
    {construction-missing-field hir/resolve.tcl
        {$id ne "" && !$denied}
        {$id ne ""}}
    {construction-bearing-check hir/callables.tcl
        {![dict exists $node opaqueDenied]}
        {1}}
    {construction-field-proof hir/range.tcl
        {[dict exists $node opaqueDenied]}
        {0}}
    {projection-check-off hir/structs.tcl
        {[projectionDenied $type $node]}
        {0}}
    {projection-typing hir/types.tcl
        {[hir::structs::projectionDenied $receiver $node]}
        {0}}
    {projection-ns-stamp hir/resolve.tcl
        {SetField hir $e ns [CtxNamespace $ctx]}
        {# (mutated: no namespace stamp)}}
    {method-candidates hir/structs.tcl
        {[projectionDenied $type [dict get $node method]]}
        {0}}
    {method-record-ns hir/resolve.tcl
        {                    ns [CtxNamespace $ctx]]}
        {                    ns __mutated__]}}
    {owner-inverted hir/structs.tcl
        {[owner $id] ne $ns}
        {[owner $id] eq $ns}}
    {namespace-inheritance hir/structs.tcl
        {[owner $id] ne $ns}
        {[string first [owner $id] $ns] != 0}}
    {authority-from-entry-only hir/structs.tcl
        {[owner $id] ne $ns}
        {$ns eq ""}}
    {promote-opacity hir/hir.tcl
        {    hir::structs::promoteOpacity hir
}
        {}}
    {instance-kind hir/semantic.tcl
        {$kind in {OPAQUE-REPRESENTATION USE-AFTER-MOVE UNHANDLED-ERROR}}
        {$kind in {USE-AFTER-MOVE UNHANDLED-ERROR}}}
    {print-nominal core/value.tcl
        {!$reveal && [isOpaqueStruct [lindex $v 1 0]]}
        {0}}
    {parser-flag surface/parser.tcl
        {opaque $opaque opaqueSpan}
        {opaque 0 opaqueSpan}}
    {lower-flag surface/lower.tcl
        {opaque [expr {[dict exists $node opaque] ? [dict get $node opaque] : 0}]}
        {opaque 0}}
    {registry-flag hir/structs.tcl
        {opaque [expr {[dict exists $decl opaque] && [dict get $decl opaque]}] names $names}
        {opaque 0 names $names}}
    {projection-message-names-field hir/structs.tcl
        {[RepresentationMessage [lindex $type 1]]$hint"]}
        {[RepresentationMessage [lindex $type 1]] (field \"$name\")$hint"]}}
}

if {$listOnly} {
    foreach m $mutations { puts [lindex $m 0] }
    exit 0
}

proc fileContents {path} {
    set channel [open $path r]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}
proc writeFile {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
}

# A scratch copy of exactly what the fuzzer and the opaque tests load.
proc makeMutantTree {scratch} {
    global root
    file mkdir $scratch
    foreach dir {core compiler hir surface lib} {
        file copy -force [file join $root $dir] [file join $scratch $dir]
    }
    file mkdir [file join $scratch native]
    foreach f [glob -directory [file join $root native] *.tcl] {
        file copy -force $f [file join $scratch native]
    }
    file mkdir [file join $scratch tests]
    foreach f {helpers.tcl opaque-struct.test} {
        file copy -force [file join $root tests $f] [file join $scratch tests]
    }
    file mkdir [file join $scratch audit opaque-struct tools]
    file copy -force [file join $root audit opaque-struct tools fuzz.tcl] [file join $scratch audit opaque-struct tools]
    # The tests also run programs on the native backends: share the built
    # binary (the mutations only touch Tcl sources).
    file link -symbolic [file join $scratch native target] [file join $root native target]
}

set tmp [file join [file tempdir opaque-struct-mutants]]
set baselineFailing 0
set killed 0
set survivors {}
set ran 0
try {
    # The unmutated copy must pass: otherwise "killed" would mean nothing.
    makeMutantTree [file join $tmp baseline]
    set fuzz [catch {exec env LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 [file join $tmp baseline audit opaque-struct tools fuzz.tcl] \
        -n $n -seed 1 -backends {interp compile} 2>@1} fuzzOut]
    catch {exec env LANG=C.utf8 LC_ALL=C.utf8 CORE_BACKEND=interp tclsh9.0 [file join $tmp baseline tests opaque-struct.test] 2>@1} testOut
    regexp {Failed\t(\d+)} $testOut -> baselineFailing
    puts "baseline: fuzzer [expr {$fuzz ? "FAILED" : "clean"}], tests failing $baselineFailing"
    if {$fuzz || $baselineFailing != 0} {
        puts "the unmutated tree does not pass: fix that first"
        exit 2
    }
    file delete -force [file join $tmp baseline]
    foreach m $mutations {
        lassign $m name file old new
        if {$only ne "" && $name ne $only} continue
        incr ran
        set scratch [file join $tmp $name]
        makeMutantTree $scratch
        set path [file join $scratch $file]
        set text [fileContents $path]
        set count 0
        for {set at [string first $old $text]} {$at >= 0} {set at [string first $old $text [expr {$at + 1}]]} {
            incr count
        }
        if {$count != 1} {
            puts "MUTATION ERROR $name: the text to replace occurs $count times in $file (expected exactly 1)"
            set survivors [concat $survivors [list "$name (bad mutation)"]]
            continue
        }
        set at [string first $old $text]
        set text [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
        writeFile $path $text
        set reasons {}
        set fuzz [catch {exec env LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 [file join $scratch audit opaque-struct tools fuzz.tcl] \
            -n $n -seed 1 -backends {interp compile} 2>@1} fuzzOut]
        if {$fuzz} { lappend reasons fuzzer }
        # (A tcltest file run directly exits 0 whatever failed: read its totals.)
        catch {exec env LANG=C.utf8 LC_ALL=C.utf8 CORE_BACKEND=interp tclsh9.0 [file join $scratch tests opaque-struct.test] 2>@1} testOut
        if {![regexp {Total\t(\d+)\tPassed\t(\d+)\tSkipped\t(\d+)\tFailed\t(\d+)} $testOut -> total passed skipped failed]} {
            lappend reasons "tests (did not finish)"
        } elseif {$failed > 0} {
            lappend reasons "tests ($failed failing)"
        }
        if {$reasons eq ""} {
            puts "SURVIVED  $name"
            lappend survivors $name
        } else {
            puts "killed    $name  by [join $reasons { and }]"
            incr killed
        }
        file delete -force $scratch
    }
} finally {
    file delete -force $tmp
}
puts "opaque-struct-mutation mutants $ran killed $killed survivors [llength $survivors]"
if {$survivors ne ""} {
    puts "SURVIVORS: [join $survivors {, }]"
}
exit [expr {$survivors ne ""}]
