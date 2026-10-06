#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation test of the context implementation (CONTEXTS.md).
#
#   tclsh9.0 audit/contexts/tools/mutate.tcl ?-n N? ?-only NAME? ?-list 1?
#
# Each mutation breaks exactly one piece of the implementation in a scratch
# copy of the tree (the Tcl sources and lib/, never the repository), then runs
# the context fuzzer (audit/contexts/tools/fuzz.tcl, N programs, every
# backend) and tests/contexts.test against it. A mutant is KILLED if either
# fails. A SURVIVOR is a property nothing checks: the run exits 1 if there is
# one. The native binary is shared (no mutation touches Rust).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set n 40
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

# {NAME FILE OLD NEW}: NEW replaces the single occurrence of OLD in FILE.
set mutations {
    {missing-context-check-off hir/contexts.tcl
        {Missing hir $c $target $id $reasons}
        {# (mutated: no MISSING-CONTEXT)}}
    {context-available-before-its-line hir/contexts.tcl
        {foreach r [dict get $hir roots]}
        {foreach r [lreverse [dict get $hir roots]]}}
    {constructor-sees-its-own-context hir/contexts.tcl
        {set pending $c}
        {set id [InstalledType hir $c $installed]; if {$id ne ""} {lappend installed $id}}}
    {duplicate-installation-accepted hir/contexts.tcl
        {if {$id in $installed}}
        {if {0}}}
    {not-a-context-installed hir/contexts.tcl
        {if {![hir::structs::isContext $id]}}
        {if {0}}}
    {not-a-context-parameter hir/contexts.tcl
        { || ![hir::structs::isContext [lindex $type 1]]}
        {}}
    {keyed-by-local-name hir/contexts.tcl
        {[hir::syntax::constNode $origin str $id]}
        {[hir::syntax::constNode $origin str $name]}}
    {duplicate-parameter-type-accepted hir/contexts.tcl
        {[dict exists $seenTypes $id]}
        {0}}
    {binding-collision-unchecked hir/contexts.tcl
        {[dict exists $hir scopes $bodyScope names $name] || [dict exists $seenNames $name]}
        {0}}
    {propagation-one-edge-only hir/contexts.tcl
        {dict set reasons $b $id [list call $c $target]
                        set changed 1}
        {dict set reasons $b $id [list call $c $target]}}
    {recursive-propagation-omitted hir/contexts.tcl
        {dict lappend edges $o [list $c $target]}
        {if {![hir::scopeWithin $hir [hir::get $hir $o bodyScope] [hir::get $hir $target bodyScope]]} {dict lappend edges $o [list $c $target]}}}
    {alias-calls-not-followed hir/contexts.tcl
        {ref   { return [Denotes $hir [hir::get $hir $value binding] [concat $seen [list $b]]] }}
        {ref   { return "" }}}
    {function-value-check-off hir/contexts.tcl
        {CheckValues hir $parent $required}
        {# (mutated: function values unchecked)}}
    {placement-check-off hir/contexts.tcl
        {$c ne $r || [hir::get $hir $c scope] ne $top || [hir::mode $hir] ne "program"}
        {0}}
    {method-candidate-dropped hir/hir.tcl
        {AMBIGUOUS-METHOD-CALL MISSING-CONTEXT}
        {AMBIGUOUS-METHOD-CALL}}
    {runtime-missing-not-raised core/contexts.tcl
        {if {![dict exists $installed $id]}}
        {if {0}}}
    {runtime-duplicate-last-wins core/contexts.tcl
        {if {[dict exists $installed $id]}}
        {if {0}}}
    {environment-leaks-after-run core/contexts.tcl
        {set installed $saved}
        {# (mutated: the run's contexts are kept)}}
    {wrong-static-slot native/lower.tcl
        {return [expr {[dict get $slot offset] + 8 * $i}]}
        {return [expr {8 * $i}]}}
    {stdout-stderr-swapped lib/linux/io.bot
        {linux::write(io.stdout.raw, data)}
        {linux::write(io.stderr.raw, data)}}
    {context-arrives-as-argument native/lower.tcl
        {dict set fn locals $b [list context $id]}
        {dict set fn locals $b [list reg %0]}}
    {opaque-dropped-from-context-struct surface/parser.tcl
        {set opaque [dict exists $modifiers opaque]
    set context [dict exists $modifiers context]}
        {set opaque [expr {[dict exists $modifiers opaque] && ![dict exists $modifiers context]}]
    set context [dict exists $modifiers context]}}
    {unsupported-context-heap-boxed native/lower.tcl
        {return [list no "field \"$field\" has type [hir::types::show $type], a value that may be (or contain) a GC-managed heap object, and fixed program data holds no GC root"]}
        {lappend leaves [list [list $field] $type]}}
    {unbounded-int-accepted native/lower.tcl
        {if {![hir::range::fitsSmall [hir::range::TypeFact $type]]}}
        {if {0}}}
    {install-leaves-misordered native/lower.tcl
        {foreach r $leaves}
        {foreach r [lreverse $leaves]}}
    {installed-identity-not-in-hir-text hir/format.tcl
        {append text " installs $installs"}
        {# (mutated: the installed identity is not printed)}}
}

if {$listOnly} {
    foreach m $mutations {
        puts [lindex $m 0]
    }
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

# A scratch copy of exactly what the fuzzer and the context tests load.
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
    foreach f {helpers.tcl contexts.test} {
        file copy -force [file join $root tests $f] [file join $scratch tests]
    }
    file mkdir [file join $scratch examples linux]
    file copy -force [file join $root examples linux context-hello.bot] [file join $scratch examples linux]
    file mkdir [file join $scratch audit contexts tools]
    file copy -force [file join $root audit contexts tools fuzz.tcl] [file join $scratch audit contexts tools]
    file link -symbolic [file join $scratch native target] [file join $root native target]
}

# {FUZZ-FAILED TEST-REASON} of the tree at DIR.
proc check {dir} {
    global n
    set fuzz [catch {exec env LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 [file join $dir audit contexts tools fuzz.tcl] \
        -n $n -seed 1 2>@1} fuzzOut]
    # (A tcltest file run directly exits 0 whatever failed: read its totals.)
    catch {exec env LANG=C.utf8 LC_ALL=C.utf8 CORE_BACKEND=interp tclsh9.0 [file join $dir tests contexts.test] -tmpdir [file join $dir tcltest] 2>@1} testOut
    set reason ""
    if {![regexp {Total\t(\d+)\tPassed\t(\d+)\tSkipped\t(\d+)\tFailed\t(\d+)} $testOut -> total passed skipped failed]} {
        set reason "tests (did not finish)"
    } elseif {$failed > 0} {
        set reason "tests ($failed failing)"
    }
    return [list $fuzz $reason]
}

set tmp [file join [file tempdir contexts-mutants]]
set killed 0
set survivors {}
set ran 0
try {
    # The unmutated copy must pass: otherwise "killed" would mean nothing.
    makeMutantTree [file join $tmp baseline]
    lassign [check [file join $tmp baseline]] fuzz reason
    puts "baseline: fuzzer [expr {$fuzz ? "FAILED" : "clean"}], tests [expr {$reason eq "" ? "clean" : $reason}]"
    if {$fuzz || $reason ne ""} {
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
            lappend survivors "$name (bad mutation)"
            file delete -force $scratch
            continue
        }
        set at [string first $old $text]
        writeFile $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
        lassign [check $scratch] fuzz reason
        set reasons {}
        if {$fuzz} { lappend reasons fuzzer }
        if {$reason ne ""} { lappend reasons $reason }
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
puts "contexts-mutation mutants $ran killed $killed survivors [llength $survivors]"
if {$survivors ne ""} {
    puts "survivors: [join $survivors {, }]"
    exit 1
}
