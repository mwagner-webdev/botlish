# golden-port.tcl -- writes the golden port of
# tests/fold-virtual-struct-state.test (FOLD-VIRTUAL-STRUCT-STATE-
# MILESTONE-1.md): the suite tests/golden/fold-virtual-struct-state.bot, its
# manifest fragment audit/golden/migration/fragments/
# fold-virtual-struct-state.tsv and the census audit/golden/migration/
# census/fold-virtual-struct-state.tsv.
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/golden-port.tcl
#
# The ported tests' programs and expected values are read from the Tcl test
# file itself, never copied: each ported test's body is evaluated in a child
# interpreter whose fvsValue records the program it is given (a program
# read from a workload file is read there too), and the value is the one
# the test's -result pins for it ({value V}, its first element where the
# test also pins representation facts). A program's leading comment lines
# are dropped, its imports go to the suite's header, its top-level error,
# type and struct declarations are lifted to the suite's top level (each
# named once: two programs declaring one name differently is an error, so
# no renaming is needed), and the rest becomes the body of a `static
# compile:` block whose last expression is the value.
#
# Every port is `weaker` than its Tcl test: the Tcl test also compares the
# backends with fold slots, reference joins and struct scalar replacement
# off and with coroutine fusion off, and pins the representation (fold-slot
# decisions, allocation and copy counts, the census), which no Botlish
# program observes; the Tcl tests stay active. Then regenerate the manifest
# (merge.tcl -names ...; tests/golden/README.md). Deterministic: rerunning
# it rewrites the same three files.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set old tests/fold-virtual-struct-state.test
set suite fold-virtual-struct-state.bot
set all4 "interp, compile, cranelift-generic, cranelift"
set oldBackends "$all4, and cranelift with fold slots off, with reference joins off and with struct scalar replacement off, and cranelift-unfused (fvsValue: all eight must agree)"

# Kept in Tcl: NAME STATUS SUBSYSTEM OBSERVES TCL_RETAINED TAGS NOTES.
set kept {
    fvs-scanner-result-transport KEEP-INTERNAL native {the NIR: number_at's companion returns its fold's two fields (results=2), scan reads them with callmulti, no structnew anywhere} - INTERNAL,NATIVE-ONLY {compiler representation, which no Botlish program observes}
    fvs-swap-parallel-nir KEEP-INTERNAL native {the NIR of a permuting completion: both carried registers copied out before either is written (the parallel back edge)} - INTERNAL,NATIVE-ONLY {compiler representation}
    fvs-copying-share-off KEEP-INTERNAL native {-struct-ref-joins 0: the copying fold's slot is declined (its only use the whole-struct share) and builds what -struct-fold 0 builds} - INTERNAL,NATIVE-ONLY {a lowering option}
    fvs-legacy-policy KEEP-INTERNAL native {-struct-policy legacy: no fold slot, one struct per iteration} - INTERNAL,NATIVE-ONLY {a lowering option}
    fvs-struct-opt-off KEEP-INTERNAL native {-struct-opt 0: no fold slot, one struct per iteration} - INTERNAL,NATIVE-ONLY {a lowering option}
    fvs-explain KEEP-INTERNAL hir-core-nir {hir::escape::explain names the virtual fold intermediate} - INTERNAL {the analysis' own report}
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

# The `test` commands of the Tcl file, in order: NAME -> {DESCRIPTION
# OPTIONS}; and its `set ::fvs... {...}` program prefixes, in order.
set tests [dict create]
set order {}
set prefixes {}
set command ""
foreach line [split [readText [file join $root $old]] \n] {
    if {$command eq "" && ![string match "test fvs-*" $line] && ![regexp {^set ::fvs(P|Acc) } $line]} continue
    append command $line \n
    if {[info complete $command]} {
        set words [lrange $command 0 end]
        if {[lindex $words 0] eq "set"} {
            lappend prefixes $command
        } else {
            set name [lindex $words 1]
            lappend order $name
            dict set tests $name [list [lindex $words 2] [lrange $words 3 end]]
        }
        set command ""
    }
}

# The program a ported test's body hands fvsValue, and its expected value.
proc ported {name} {
    global tests prefixes root
    lassign [dict get $tests $name] description options
    set body [dict get $options -body]
    set result [dict get $options -result]
    set child [interp create]
    try {
        $child eval [list set ::projectRoot $root]
        foreach p $prefixes {
            $child eval $p
        }
        $child eval {
            set ::programs {}
            namespace eval core {}
            proc core::ReadFile {path} {
                set f [open $path r]
                fconfigure $f -encoding utf-8 -translation lf
                set text [read $f]
                close $f
                return $text
            }
            proc fvsValue {text} { lappend ::programs $text; return VALUE }
            foreach p {fvsStructs fvsCopies fvsListCopies fvsSlots fvsCensus fvsNir fvsHir outcomeUnderHir} {
                proc $p {args} { return "" }
            }
            proc fvsWithEnv {pairs script} { uplevel 1 $script }
            proc withoutCoroutineFusion {script} { uplevel 1 $script }
        }
        set value [$child eval $body]
        set programs [$child eval {set ::programs}]
    } finally {
        interp delete $child
    }
    if {[llength $programs] != 1} {
        error "golden-port: $name hands fvsValue [llength $programs] programs"
    }
    set outcome [expr {$value eq "VALUE" ? $result : [lindex $result 0]}]
    if {[lindex $outcome 0] ne "value" || [llength $outcome] != 2} {
        error "golden-port: $name pins no value ($outcome)"
    }
    return [list $description [lindex $programs 0] [lindex $outcome 1]]
}

# Splits PROGRAM into {IMPORTS DECLARATIONS BODY}: its import lines, its
# top-level error/type/struct declarations (a struct or an error with its
# field lines) and everything else, its leading comment lines dropped.
proc split3 {program} {
    set imports {}
    set decls {}
    set body {}
    set inDecl 0
    set leading 1
    foreach line [split [string trimright $program \n] \n] {
        if {$leading && ([string match "#*" $line] || [string trim $line] eq "")} {
            continue
        }
        set leading 0
        if {[regexp {^import (\S+)$} $line -> m]} {
            lappend imports $m
            continue
        }
        if {[regexp {^(error|type|struct) } $line]} {
            lappend decls $line
            set inDecl [regexp {^(struct|error) } $line]
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
set decls [dict create]
set functions {}
set fragment {}
set census {}
set retainedText "the comparison with fold slots, reference joins and struct scalar replacement off and with coroutine fusion off, and the representation the test pins (fold-slot decisions, allocation and copy counts, the census)"
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
    # A declaration another program declares differently is renamed in
    # this one (NAME2, NAME3, ...: the first free name whose declaration is
    # this one's or no one's), every whole-word use of it with it.
    set renames {}
    foreach d $programDecls {
        regexp {^(?:error|type|struct) (\w+)} $d -> declName
        if {[dict exists $decls $declName] && [dict get $decls $declName] ne $d} {
            set k 2
            while 1 {
                set renamed $declName$k
                set mine [regsub -all "\\m$declName\\M" $d $renamed]
                if {![dict exists $decls $renamed] || [dict get $decls $renamed] eq $mine} {
                    break
                }
                incr k
            }
            lappend renames $declName $renamed
        }
    }
    if {$renames ne ""} {
        foreach {from to} $renames {
            set programDecls [lmap d $programDecls {regsub -all "\\m$from\\M" $d $to}]
            set body [lmap line $body {regsub -all "\\m$from\\M" $line $to}]
        }
        append description " (declarations renamed in the port: [join [lmap {from to} $renames {string cat "$from -> $to"}] {, }])"
    }
    foreach d $programDecls {
        regexp {^(?:error|type|struct) (\w+)} $d -> declName
        if {[dict exists $decls $declName] && [dict get $decls $declName] ne $d} {
            error "golden-port: $declName is still declared differently by two programs (in $name)"
        }
        dict set decls $declName $d
    }
    set fn [ident $name]
    set lines [list "    fn ${fn}() errors std::compiler::CompilerError:" "        static compile:"]
    foreach line $body {
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
    lappend census [list $old $name surface MIGRATE high "fvsValue: identical value on $all4 and with fold slots, reference joins and struct scalar replacement off: [string range $name 4 end]" - value $retainedText MULTI-BACKEND -]
}
foreach name [dict keys $keptNames] {
    if {$name ni $order} { error "golden-port: $name is no test of $old" }
}

set header "# fold-virtual-struct-state.bot -- folds whose struct intermediate the
# native backends carry as independent field registers (FOLD-VIRTUAL-STRUCT-
# STATE-MILESTONE-1.md), as a source-level specification: a fold slot means
# exactly what the fold carrying one struct object means.
#
# * A normal completion replaces the whole intermediate at once (a
#   completion that permutes, repeats or keeps fields included), a
#   continue keeps the iteration's starting value, a bare break and
#   exhaustion yield it, an empty domain yields the initial value.
# * Nested folds keep their own intermediates; an error or a return leaves
#   the fold with nothing of a candidate committed; a yield suspends it.
# * Earlier versions stored or compared stay as they were; an intermediate
#   handed whole to an open call, compared, captured or shared keeps its
#   meaning whichever representation the compiler chooses; mutable fields
#   keep their copy convention (consumed, or copied at entry).
#
# Ported from tests/fold-virtual-struct-state.test, which stays
# authoritative and unchanged; a golden test keeps its Tcl test's name. What
# only the Tcl tests observe (the comparison with fold slots, reference
# joins and struct scalar replacement off, the fold-slot decisions, the
# census, NIR, allocation and copy counts, GC stress) stays there. This file
# is generated by audit/fold-virtual-struct-state/tools/golden-port.tcl from
# the Tcl tests' own programs and results.
"
set text $header
foreach m [lsort $imports] {
    append text "import $m\n"
}
append text "\n# Declarations the tests need (top-level only): one each, the same in every\n# program that declares it.\n"
foreach declName [lsort [dict keys $decls]] {
    append text "[dict get $decls $declName]\n\n"
}
append text "fn register_fold_virtual_struct_state_tests():\n"
append text [string trimright [join $functions \n] \n] \n
append text "\nwith context std::test::suite()\nregister_fold_virtual_struct_state_tests()\nstd::test::report()\n"
writeText [file join $root tests golden $suite] $text

set fheader {old_file old_test suite new_test category outcome old_backends new_backends class also static handler api verbosity strength old_lines new_lines mutants notes subsystem status tcl_retained tcl_layer freeze tags}
writeText [file join $root audit golden migration fragments fold-virtual-struct-state.tsv] \
    "[join $fheader \t]\n[join [lmap row $fragment {join [lmap c $row {string map {\t { } \n { }} $c}] \t}] \n]\n"
set cheader {old_file old_test subsystem status confidence observes source_theorem outcome tcl_retained tags notes}
writeText [file join $root audit golden migration census fold-virtual-struct-state.tsv] \
    "[join $cheader \t]\n[join [lmap row $census {join [lmap c $row {string map {\t { } \n { }} $c}] \t}] \n]\n"
puts "wrote tests/golden/$suite ([llength $fragment] tests), the fragment and the census ([llength $census] rows)"
