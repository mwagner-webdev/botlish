# golden-port.tcl -- writes the golden port of
# tests/fold-virtual-construction.test (FOLD-VIRTUAL-LIST-CONSTRUCTION-
# MILESTONE-1.md): the suite tests/golden/fold-virtual-construction.bot,
# its manifest fragment audit/golden/migration/fragments/
# fold-virtual-construction.tsv and the census audit/golden/migration/
# census/fold-virtual-construction.tsv.
#
#   tclsh9.0 audit/fold-virtual-construction/tools/golden-port.tcl
#
# The ported tests' programs and expected values are read from the Tcl test
# file itself, never copied: each ported test's body is evaluated in a child
# interpreter whose fvc records the program it is given, and the value is
# the test's -result (its first element where the test also pins a
# decision). A program's imports go to the suite's header; its top-level
# error, type and struct declarations are lifted to the suite's top level
# (each named once, Fvc-prefixed already); the rest becomes the body of a
# `static compile:` block whose last expression is the value.
#
# Every port is `weaker` than its Tcl test: the Tcl test also compares the
# eager fold (-virtual-construction-opt 0) and, where it does, the plan/flat
# decision, which no Botlish program observes; the Tcl tests stay active.
# Then regenerate the manifest (merge.tcl -names ...; tests/golden/
# README.md). Deterministic: rerunning it rewrites the same three files.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set old tests/fold-virtual-construction.test
set suite fold-virtual-construction.bot
set all4 "interp, compile, cranelift-generic, cranelift"
set oldBackends "$all4, and cranelift with -virtual-construction-opt 0 (fvc: outcomeUnderHir and the eager fold, must agree)"

# Kept in Tcl: NAME STATUS SUBSYSTEM OBSERVES TCL_RETAINED TAGS NOTES.
set kept {
    fvc-nir-carried KEEP-INTERNAL native {the NIR of an append fold: one construct list plan per iteration into a declared plan register, one construct list flat at exhaustion, no listappend} - INTERNAL,NATIVE-ONLY {compiler representation, which no Botlish program observes}
    fvc-nir-break KEEP-INTERNAL native {the NIR of a fold with a break: the plan register materialized at the break and at exhaustion} - INTERNAL,NATIVE-ONLY {compiler representation}
    fvc-nir-off KEEP-INTERNAL native {-virtual-construction-opt 0: one listappend per iteration, no construct} - INTERNAL,NATIVE-ONLY {a lowering option}
    fvc-nir-flat-separate KEEP-INTERNAL native {std::list::flat of a plan fold: one materialization, then one listflat, no fusion} - INTERNAL,NATIVE-ONLY {compiler representation}
    fvc-types-unchanged KEEP-INTERNAL hir-core-nir {expression types, instance labels and function counts identical with virtual construction on and off} - INTERNAL {types and specialization, which no Botlish program observes}
    fvc-explain KEEP-INTERNAL hir-core-nir {hir::construction::explain names the plan fold} - INTERNAL {the analysis' own report}
    fvc-copies-linear KEEP-INTERNAL native {native::allocationReport: linear List element copies and a constant number of Lists at N and 4N; the eager fold quadratic} - INTERNAL,NATIVE-ONLY {allocation and copy counts, which no Botlish program observes: the structural evidence}
    fvc-matches-recursion KEEP-INTERNAL native {native::allocationReport: the fold's Lists, plans, extensions, materializations and copied elements equal the self tail call's} - INTERNAL,NATIVE-ONLY {allocation and copy counts}
    fvc-string-copies KEEP-INTERNAL native {native::allocationReport: a String fold's bytes copied linearly, the eager fold's quadratically} - INTERNAL,NATIVE-ONLY {copy counts}
    fvc-gc-stress KEEP-INTERNAL native {plan folds of fresh Strings, nested and broken off, on every backend under BOTLISH_NATIVE_GC_STRESS=1, and the decisions} {the GC-stress environment} INTERNAL,NATIVE-ONLY,MULTI-BACKEND {an environment variable of the native runtime}
    fvc-release-in-body KEEP-INTERNAL native {native::allocationReport's coroutine release counter: a coroutine dying mid-body of a plan fold is released} - INTERNAL,NATIVE-ONLY {release counters, which no Botlish program observes}
    fvc-release-plan-join KEEP-INTERNAL native {native::allocationReport's coroutine release counter: a plan-family if branch of a recurrence releases its coroutine, with virtual construction on and off} - INTERNAL,NATIVE-ONLY {release counters}
    fvc-executable KEEP-MULTI-PROGRAM native {standalone AOT executable stdout, plain and with BOTLISH_NATIVE_GC_STRESS=1, agreeing with the in-process backends} {the executable and its GC-stress run} MULTI-BACKEND,MULTI-PROGRAM,STDOUT,MAIN-TCL {its in-process values are the golden suite's}
}

proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}
proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The `test` commands of the Tcl file, in order: NAME -> {DESCRIPTION OPTIONS}.
set tests [dict create]
set order {}
set command ""
foreach line [split [readText [file join $root $old]] \n] {
    if {$command eq "" && ![string match "test fvc-*" $line]} continue
    append command $line \n
    if {[info complete $command]} {
        set words [lrange $command 0 end]
        set name [lindex $words 1]
        lappend order $name
        dict set tests $name [list [lindex $words 2] [lrange $words 3 end]]
        set command ""
    }
}

# The program a ported test's body hands fvc, and its expected value.
proc ported {name} {
    global tests
    lassign [dict get $tests $name] description options
    set body [dict get $options -body]
    set result [dict get $options -result]
    set child [interp create]
    try {
        $child eval {
            set ::programs {}
            proc fvc {text args} { lappend ::programs $text; return VALUE }
            proc fvcVerdicts {args} { return "" }
            proc fvcDecisions {args} { return "" }
            proc fvcNir {args} { return "" }
            proc fvcFunc {args} { return "" }
            proc fvcCount {args} { return 0 }
        }
        set value [$child eval $body]
        set programs [$child eval {set ::programs}]
    } finally {
        interp delete $child
    }
    if {[llength $programs] != 1} {
        error "golden-port: $name hands fvc [llength $programs] programs"
    }
    set expected [expr {$value eq "VALUE" ? $result : [lindex $result 0]}]
    return [list $description [lindex $programs 0] $expected]
}

# Splits PROGRAM into {IMPORTS DECLARATIONS BODY}: its import lines, its
# top-level error/type/struct declarations (a struct with its field lines)
# and everything else.
proc split3 {program} {
    set imports {}
    set decls {}
    set body {}
    set inDecl 0
    foreach line [split [string trimright $program \n] \n] {
        if {[regexp {^import (\S+)$} $line -> m]} {
            lappend imports $m
            continue
        }
        if {[regexp {^(error|type|struct) } $line]} {
            lappend decls $line
            set inDecl [string match "struct *" $line]
            continue
        }
        if {$inDecl && [string match "    *" $line]} {
            lset decls end "[lindex $decls end]\n$line"
            continue
        }
        set inDecl 0
        lappend body $line
    }
    # Drop the blank lines a lifted declaration leaves at the body's start.
    while {[llength $body] && [string trim [lindex $body 0]] eq ""} {
        set body [lrange $body 1 end]
    }
    return [list $imports $decls $body]
}

proc ident {name} {
    return "t_[string map {- _} [string range $name 4 end]]"
}

set keptNames [dict create]
foreach {name status subsystem observes retained tags notes} $kept {
    dict set keptNames $name [list $status $subsystem $observes $retained $tags $notes]
}
set imports {std::compiler std::test}
set decls {}
set declNames {}
set functions {}
set fragment {}
set census {}
set retainedText "the comparison with the eager fold (cranelift, -virtual-construction-opt 0) and, where the test pins it, the plan/flat decision"
foreach name $order {
    if {[dict exists $keptNames $name]} {
        lassign [dict get $keptNames $name] status subsystem observes retained tags notes
        lappend census [list $old $name $subsystem $status high $observes - none $retained $tags $notes]
        continue
    }
    lassign [ported $name] description program expected
    lassign [split3 $program] programImports programDecls body
    foreach m $programImports {
        if {$m ni $imports} { lappend imports $m }
    }
    foreach d $programDecls {
        regexp {^(?:error|type|struct) (\w+)} $d -> declName
        if {$declName ni $declNames} {
            lappend declNames $declName
            lappend decls $d
        }
    }
    set fn [ident $name]
    set lines [list "    fn ${fn}() errors std::compiler::CompilerError:" "        static compile:"]
    foreach line $body {
        # (`if`, never expr's ?: -- a line such as "0" would come back a
        # number without its indentation: AGENTS.md.)
        if {$line eq ""} {
            lappend lines ""
        } else {
            lappend lines "            $line"
        }
    }
    lappend lines "    std::test::value(\"$name\", $expected, $fn)" ""
    lappend functions {*}$lines
    set n [expr {[llength $body] + 3}]
    lappend fragment [list $old $name $suite $name folds value $oldBackends $all4 DIRECT - convention no simple similar weaker $n $n - \
        $description surface MIGRATED $retainedText - - MULTI-BACKEND]
    lappend census [list $old $name surface MIGRATE high "fvc: identical value on $all4 and the eager fold: [string range $name 4 end]" - value $retainedText MULTI-BACKEND -]
}
foreach name [concat [dict keys $keptNames]] {
    if {$name ni $order} { error "golden-port: $name is no test of $old" }
}

set header "# fold-virtual-construction.bot -- folds whose String/List intermediate the
# native backends carry as a construction plan (FOLD-VIRTUAL-LIST-
# CONSTRUCTION-MILESTONE-1.md), as a source-level specification: a plan
# fold means exactly what the eager fold means.
#
# * Appending to the intermediate, keeping it, continuing past it and
#   breaking off with it give the fold's value as written: a break yields
#   the intermediate its iteration started with, a continue keeps it, an
#   empty domain yields the initial value, every iteration form carries it.
# * The initial value is never modified (it may be shared), appended
#   elements stay ordinary values, nested folds keep their own
#   intermediates, an error or a return leaves the fold with nothing of it
#   committed, a yield suspends it.
# * Folds whose earlier intermediate is observable -- an append before a
#   break or continue, two versions on one path, an observation, a capture,
#   a reference in an inner loop -- run on the eager lowering, with the
#   same values.
#
# Ported from tests/fold-virtual-construction.test, which stays
# authoritative and unchanged; a golden test keeps its Tcl test's name. What
# only the Tcl tests observe (the eager fold's comparison, the decisions,
# NIR, copy and allocation counts, release counters, GC stress,
# executables) stays there. This file is generated by
# audit/fold-virtual-construction/tools/golden-port.tcl from the Tcl tests'
# own programs and results.
"
set text $header
foreach m [lsort $imports] {
    append text "import $m\n"
}
append text "\n# Declarations the tests need (top-level only), named Fvc... to stay apart\n# from the other suites'.\n"
foreach d $decls {
    append text "$d\n\n"
}
append text "fn register_fold_virtual_construction_tests():\n"
append text [string trimright [join $functions \n] \n] \n
append text "\nwith context std::test::suite()\nregister_fold_virtual_construction_tests()\nstd::test::report()\n"
writeText [file join $root tests golden $suite] $text

set fheader {old_file old_test suite new_test category outcome old_backends new_backends class also static handler api verbosity strength old_lines new_lines mutants notes subsystem status tcl_retained tcl_layer freeze tags}
writeText [file join $root audit golden migration fragments fold-virtual-construction.tsv] \
    "[join $fheader \t]\n[join [lmap row $fragment {join [lmap c $row {string map {\t { } \n { }} $c}] \t}] \n]\n"
set cheader {old_file old_test subsystem status confidence observes source_theorem outcome tcl_retained tags notes}
writeText [file join $root audit golden migration census fold-virtual-construction.tsv] \
    "[join $cheader \t]\n[join [lmap row $census {join [lmap c $row {string map {\t { } \n { }} $c}] \t}] \n]\n"
puts "wrote tests/golden/$suite ([llength $fragment] tests), the fragment and the census ([llength $census] rows)"
