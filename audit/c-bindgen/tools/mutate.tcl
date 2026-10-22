# mutate.tcl -- mutation testing of the C binding generator (C-BINDGEN.md,
# "Mutation testing").
#
#   tclsh9.0 audit/c-bindgen/tools/mutate.tcl ?-only NAME,...? ?-tests FILES?
#                                             ?-match PATTERNS?
#                                             ?-fuzz-count N? ?-fuzz-seed N?
#                                             ?-layout-fuzz-count N?
#                                             ?-layout-fuzz-seed N?
#                                             ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the repository's compiler, generator,
# committed bindings, examples and tests (a temporary directory) gets the
# replacements, and the detectors run against it:
#
#   * the test files FILES (default tests/c-bindgen.test; each with a private
#     -tmpdir; with -match, only the tests PATTERNS matches -- tcltest's
#     -match, e.g. "cb-layout-* cb-fixture-*" for a mutant of the layout
#     pass, which the real libraries' tests need not repeat): killed if any
#     test fails or a file does not complete. The
#     tests that compile, link and run a binding run what the mutated
#     generator produces, not the committed files; the *-current tests
#     compare that with the committed files byte for byte. A mutant only
#     those pinned comparisons kill is reported as such ("pinned only"):
#     every mutant here should also be killed by a test of behavior or by
#     the fuzzer;
#   * audit/c-bindgen/tools/fuzz.tcl -n N -seed S (random C libraries bound
#     and called on both native backends, against its own ABI model):
#     killed if it reports a disagreement or does not complete;
#   * audit/c-bindgen/tools/layout-fuzz.tcl -n N -seed S (random C records,
#     against its own model, GCC and the runtime oracle; C-BINDGEN-LAYOUTS.md):
#     killed likewise.
#
# The generator is Tcl only: the copy's native/target is a link to this
# checkout's. The real checkout is never modified. The Tcl, BoringSSL and
# SDL3 tests run when their sources and libraries are in Botlish's cache, as
# in the checkout (tests/c-bindgen.test's constraints).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -tests tests/c-bindgen.test -match "" -fuzz-count 3 -fuzz-seed 11 \
    -layout-fuzz-count 2 -layout-fuzz-seed 11 -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The tests whose only check is the committed bindings' equality with the
# generation.
set pinned {cb-fixture-current cb-tcl-current cb-tcl-current-cross cb-boringssl-current
    cb-boringssl-current-cross cb-sdl3-current cb-sdl3-current-cross cb-win32-current}

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
proc readMutants {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set lines [split [read $f] \n]
    close $f
    set mutants {}
    set name ""
    set state outside
    foreach line $lines {
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+) (.*)$} $line -> n d]} {
                    if {$name ne ""} { lappend mutants $name $description $edits }
                    set name $n
                    set description $d
                    set edits {}
                } elseif {[regexp {^## (\S+)$} $line -> file]} {
                    set current $file
                } elseif {$line eq "<<<<"} {
                    set state old
                    set old {}
                }
            }
            old {
                if {$line eq "===="} {
                    set state new
                    set new {}
                } else {
                    lappend old $line
                }
            }
            new {
                if {$line eq ">>>>"} {
                    lappend edits $current [join $old \n] [join $new \n]
                    set state outside
                } else {
                    lappend new $line
                }
            }
        }
    }
    if {$name ne ""} { lappend mutants $name $description $edits }
    return $mutants
}

proc readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    foreach {file old new} $edits {
        if {[string match native/* $file]} {
            error "mutant $name edits $file: the generator's mutants are Tcl only (its tree links native/target)"
        }
    }
    lappend selected $name $description $edits
}

# A private copy of everything the tests and the fuzzer read: the compiler,
# the library, the generator and its C header library, the committed
# bindings, the examples, the tests, the archaeology's profiles (the
# BoringSSL build reads its pin there) and the native backend's sources,
# its target a link to this checkout's.
set tree [file tempdir botlish-cbindgen-mutants]
foreach dir {compiler core hir surface stdlib tests tools generated examples audit/c-bindgen
        audit/c-header/profiles audit/c-header/tools .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } else {
        file link -symbolic [file join $tree native target] $entry
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

proc run {timeout args} {
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

set results {}
try {
    foreach {name description edits} $selected {
        set touched [dict create]
        set applied 1
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $touched $file]} {
                dict set touched $file [readFile $path]
            }
            set text [readFile $path]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                set applied 0
                break
            }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            # The code the mutant edits changed: update mutants.txt.
            lappend results [list $name $description NOT-APPLIED "" "" ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set failedTests {}
        set incomplete ""
        foreach testFile [dict get $options -tests] {
            set tmp [file tempdir botlish-cbindgen-mutant-run]
            set match [expr {[dict get $options -match] eq "" ? {} : [list -match [dict get $options -match]]}]
            lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp {*}$match] status output
            file delete -force $tmp
            lappend failedTests {*}[lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
            if {$incomplete eq "" && ![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
                set incomplete "[file tail $testFile]: [lastLine $output]"
            }
        }
        set failedTests [lsort -unique $failedTests]
        set behavioral [lmap t $failedTests {expr {$t in $pinned ? [continue] : $t}}]
        if {$incomplete ne ""} {
            set tests "killed (did not complete: $incomplete)"
        } elseif {$failedTests ne {}} {
            set tests "killed ([llength $failedTests] failed: [join [lrange $failedTests 0 7] {, }][expr {[llength $failedTests] > 8 ? ", ..." : ""}])"
            if {$behavioral eq {}} { append tests " -- pinned only" }
        } else {
            set tests survived
        }
        set scratch [file tempdir botlish-cbindgen-mutant-fuzz]
        set here [pwd]
        cd $scratch
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit c-bindgen tools fuzz.tcl] \
            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed] -keep 0] status output
        cd $here
        file delete -force $scratch
        if {[regexp {programs \d+ declarations \d+ (?:variadic \d+ trailing \d+ )?disagreements (\d+)} [lindex [split [string trim $output] \n] end] -> n]} {
            set fuzz [expr {$n > 0 ? "killed ($n disagreements in [dict get $options -fuzz-count] programs)" : "survived"}]
        } else {
            set fuzz "killed (did not complete: [lastLine $output])"
        }
        set scratch [file tempdir botlish-cbindgen-mutant-layout-fuzz]
        cd $scratch
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit c-bindgen tools layout-fuzz.tcl] \
            -n [dict get $options -layout-fuzz-count] -seed [dict get $options -layout-fuzz-seed] -keep 0] status output
        cd $here
        file delete -force $scratch
        if {[regexp {programs \d+ records \d+ layouts \d+ disagreements (\d+)} [lindex [split [string trim $output] \n] end] -> n]} {
            set layoutFuzz [expr {$n > 0 ? "killed ($n disagreements in [dict get $options -layout-fuzz-count] programs)" : "survived"}]
        } else {
            set layoutFuzz "killed (did not complete: [lastLine $output])"
        }
        set fuzzKilled [expr {[string match killed* $fuzz] || [string match killed* $layoutFuzz]}]
        append fuzz "; layout fuzz $layoutFuzz"
        set killed [expr {[string match killed* $tests] || $fuzzKilled}]
        set byBehavior [expr {$incomplete ne "" || $behavioral ne {} || $fuzzKilled}]
        set verdict [expr {$killed ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests $fuzz $byBehavior]
        puts "$verdict $name -- $description\n    tests:  $tests"
        puts "    fuzz:   $fuzz"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ne "NOT-APPLIED"} continue; lindex $r 0}]
set pinnedOnly [lmap r $results {if {[lindex $r 2] ne "KILLED" || [lindex $r 5]} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed ([expr {$killed - [llength $pinnedOnly]}] by a test of behavior or the fuzzer[expr {$pinnedOnly eq {} ? "" : "; pinned output only: [join $pinnedOnly {, }]"}]), [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
