# expect.tcl -- the expected-output pin of the warning-driven refactor
# (REFACTOR-WARNINGS-CLEAN.md, "The law: observable behavior is identical"):
# every corpus program that states its value in an `# expect: VALUE` comment
# runs, on every backend, to exactly that value.
#
#   tclsh9.0 audit/refactor/tools/expect.tcl ?-backends LIST? ?-root DIR?
#
# -root DIR checks another tree's examples/, bench/ and lib/ (a scratch copy
# with a phase's conversions) with this checkout's compiler.
#
# tests/stdlib.test (examples/stdlib), tests/surface-samples.test
# (examples/surface) and tests/bench-corpus.test (four bench programs) pin
# most of these already; this tool pins all of them at once, including the
# bench programs no test runs (lex-strategy, source-checks, test-selection),
# so a phase of the refactor is checked against every stated value before and
# after. Exit status 1 on any mismatch.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set checkout $root
set backends {interp compile cranelift-generic cranelift}
foreach {option value} $argv {
    switch -- $option {
        -backends { set backends $value }
        -root { set root [file normalize $value] }
        default { error "unknown option $option" }
    }
}
source [file join $checkout examples stdlib corpus.tcl]
set ::core::libraryDir [file join $root lib]
set ::refactorSweepLibrary 1
source [file join $here sweep.tcl]
interp recursionlimit {} 1000000

proc outcome {backend hir} {
    if {[catch {corpus::run $backend $hir} value options]} {
        if {$backend eq "cranelift-generic" && [dict get $options -errorcode] eq "NATIVE UNSUPPORTED struct-shape"} {
            return [outcome cranelift $hir]
        }
        return [list error [dict get $options -errorcode]]
    }
    return [list value [core::value::show $value 1]]
}

set checked 0
set failures 0
foreach program [refactor::sweep::programs $root] {
    set text [refactor::sweep::readText [file join $root $program]]
    if {![regexp -line {^#\s*expect:\s*(.*)$} $text -> shown]} continue
    incr checked
    if {[catch {surface::readProgramFile [file join $root $program] -warnings off} hir options]} {
        incr failures
        puts "FAIL  $program: does not compile ([dict get $options -errorcode])"
        continue
    }
    set bad {}
    foreach backend $backends {
        set o [outcome $backend $hir]
        if {$o ne [list value $shown]} {
            lappend bad "$backend: $o"
        }
    }
    if {$bad eq ""} {
        puts "ok    $program: $shown"
    } else {
        incr failures
        puts "FAIL  $program (expect $shown): [join $bad {; }]"
    }
}
puts "programs with an expect line: $checked; mismatches: $failures"
exit [expr {$failures > 0}]
