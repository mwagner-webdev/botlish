# mutate.tcl -- mutation testing of the UnicodeChar classifiers
# std::char::is_tcl_alpha and std::char::is_tcl_alnum
# (UNICODECHAR-CLASSIFIERS.md).
#
#   tclsh9.0 audit/char-classifiers/tools/mutate.tcl ?-only NAME,...?
#       ?-timeout SECONDS?
#
# Each mutant of mutants.txt (beside this script) is a deliberate bug,
# written as exact source replacements. For each, a private copy of the
# checkout (audit/golden/tools/tree.tcl) gets the replacements and the
# detectors run in it:
#
#   * tests/native-tcl-unicode.test (with a private -tmpdir): killed if a
#     test fails or the file does not complete;
#   * the golden suite tests/golden/unicode-strings.bot on every backend:
#     killed if its status is not ok;
#   * for a native mutant (one that edits native/src/), first a release
#     build of the copy's native backend (a mutant that does not build is
#     reported NOT-BUILT, never counted as killed), then also the runtime's
#     Rust tests of the classes (`cargo test --release --lib --
#     char_classifiers inline_ascii_rule`).
#
# A mutant every detector misses SURVIVES. Exit status 1 if any mutant
# survived, did not apply or did not build. The real checkout, including its
# native/target, is never modified: a native mutant builds in the copy's own
# native/target.

source [file join [file dirname [file dirname [file dirname [file normalize [info script]]]]] golden tools tree.tcl]

set here [file dirname [file normalize [info script]]]
set options [dict create -only "" -timeout 2400]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

set testFiles {tests/native-tcl-unicode.test}
set suites {tests/golden/unicode-strings.bot}

set only [split [dict get $options -only] ,]
set tcl {}
set nativeMutants {}
foreach {name description edits} [goldentools::readMutants [file join $here mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {[goldentools::isNative $edits]} {
        lappend nativeMutants $name $description $edits
    } else {
        lappend tcl $name $description $edits
    }
}

set tree [goldentools::makeTree [expr {$nativeMutants ne {}}]]
set timeout [dict get $options -timeout]
set results {}
try {
    # Tcl-only mutants first, against the copy's unmodified native build.
    foreach {name description edits} [concat $tcl $nativeMutants] {
        set native [goldentools::isNative $edits]
        lassign [goldentools::apply $tree $edits] applied touched
        if {!$applied} {
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $touched"
            lappend results [list $name NOT-APPLIED]
            continue
        }
        set killers {}
        if {$native} {
            set problem [goldentools::build $tree $timeout]
            if {$problem ne ""} {
                puts "NOT-BUILT $name: $problem"
                lappend results [list $name NOT-BUILT]
                goldentools::restore $tree $touched
                goldentools::build $tree $timeout
                continue
            }
        }
        foreach testFile $testFiles {
            lassign [goldentools::runTestFile $tree $testFile $timeout] failed passed incomplete
            if {$failed ne {}} {
                lappend killers "[file tail $testFile]: [llength $failed] failed ([join [lrange $failed 0 5] {, }][expr {[llength $failed] > 6 ? ", ..." : ""}])"
            }
            if {$incomplete ne ""} {
                lappend killers "incomplete: $incomplete"
            }
        }
        dict for {suite outcome} [goldentools::runSuites $tree $suites $timeout] {
            lassign $outcome state verdicts
            if {$state ne "ok"} {
                set failing [lmap {n v} $verdicts {if {$v ne "FAIL"} continue; set n}]
                lappend killers "[file tail $suite]: $state[expr {$failing eq {} ? "" : " ([join [lrange $failing 0 3] {, }])"}]"
            }
        }
        if {$native} {
            set cwd [pwd]
            cd [file join $tree native]
            try {
                lassign [goldentools::run $timeout cargo test --release --lib -- char_classifiers inline_ascii_rule] status output
            } finally {
                cd $cwd
            }
            if {$status != 0} {
                lappend killers "cargo test: [goldentools::lastLine $output]"
            }
        }
        set verdict [expr {$killers eq {} ? "SURVIVED" : "KILLED"}]
        puts "$verdict $name -- $description"
        foreach k $killers { puts "    $k" }
        flush stdout
        lappend results [list $name $verdict]
        goldentools::restore $tree $touched
        if {$native} {
            goldentools::build $tree $timeout
        }
    }
} finally {
    file delete -force $tree
}

set counts [dict create KILLED 0 SURVIVED 0 NOT-APPLIED 0 NOT-BUILT 0]
foreach r $results { dict incr counts [lindex $r 1] }
puts "\n[llength $results] mutants: [dict get $counts KILLED] killed, [dict get $counts SURVIVED] survived, [dict get $counts NOT-APPLIED] not applied, [dict get $counts NOT-BUILT] not built"
exit [expr {[dict get $counts KILLED] == [llength $results] ? 0 : 1}]
