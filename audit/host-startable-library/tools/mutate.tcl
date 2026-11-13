# mutate.tcl -- mutation testing of host-startable application libraries,
# cross-target link plans and Android C-binding generation
# (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/host-startable-library/tools/mutate.tcl ?-only NAME,...?
#       ?-timeout SECONDS? ?-untested fail|ok?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once, with a `!!` line naming the tests that must kill it: al-* of
# tests/application-library.test, at-* of tests/android-target.test, cb-* of
# tests/c-bindgen.test, nl-* of tests/native-library.test, rust:FILTER the
# native driver's cargo tests matching FILTER. For each mutant a private copy
# of the repository (a temporary directory; its native/target a real copy,
# following a link) gets the replacements, its native backend is rebuilt (a
# mutant that does not build is NOT-BUILT, never counted as killed), and its
# named detectors run there, each test file with a private -tmpdir and
# -match the named tests. A mutant is KILLED when a named detector fails,
# SURVIVED when every one that ran passed, UNTESTED when none ran (each
# skipped by its constraints: the Android tests need ANDROID_NDK_ROOT and,
# for execution, qemu-aarch64 and BOTLISH_ANDROID_ROOTS; the generator's
# need SDL's pinned headers). The report lists each mutant and what killed
# it; it exits 1 on a survivor, a mutant that no longer applies or does not
# build, and (with -untested fail, the default) an untested one. The real
# checkout, its native/target included, is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 3600 -untested fail]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt, as {NAME DESCRIPTION DETECTORS {FILE OLD NEW ...}}.
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
                    if {$name ne ""} { lappend mutants $name $description $detectors $edits }
                    set name $n
                    set description $d
                    set detectors {}
                    set edits {}
                } elseif {[regexp {^!! (.*)$} $line -> names]} {
                    set detectors $names
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
    if {$name ne ""} { lappend mutants $name $description $detectors $edits }
    foreach {n d detectors e} $mutants {
        if {$detectors eq {}} { error "mutant $n names no detector (a \"!! TEST ...\" line)" }
    }
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

# Runs ARGS (output and error together) in directory DIR for at most TIMEOUT
# seconds: {STATUS OUTPUT}, STATUS 0 on success, "timeout" when it was
# killed for running too long.
proc run {timeout dir args} {
    set here [pwd]
    cd $dir
    set pipe [open |[concat $args [list 2>@1]] r]
    cd $here
    fconfigure $pipe -blocking 0 -translation lf -encoding utf-8
    set ::runOutput ""
    set ::runDone 0
    fileevent $pipe readable [list apply {{pipe} {
        append ::runOutput [read $pipe]
        if {[eof $pipe]} { set ::runDone 1 }
    }} $pipe]
    set timer [after [expr {$timeout * 1000}] {set ::runDone timeout}]
    vwait ::runDone
    after cancel $timer
    if {$::runDone eq "timeout"} {
        catch {exec kill -9 {*}[pid $pipe]}
        catch {close $pipe}
        return [list timeout $::runOutput]
    }
    fconfigure $pipe -blocking 1
    set status 0
    if {[catch {close $pipe} message options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
    }
    return [list $status $::runOutput]
}

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

# The test file of a detector NAME.
proc detectorFile {name} {
    foreach {prefix file} {al- application-library.test at- android-target.test cb- c-bindgen.test nl- native-library.test} {
        if {[string match $prefix* $name]} { return $file }
    }
    error "detector $name: no test file has its prefix (al-, at-, cb-, nl-, rust:)"
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description detectors edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $detectors $edits
}

# A private copy of the repository (not .git), its native/target a real copy
# (each mutant rebuilds it), following a linked target: a copied link would
# build every mutant into another checkout.
set tree [file tempdir botlish-host-startable-mutants]
foreach entry [glob -nocomplain -directory $root * .cargo .devcontainer .github] {
    set tail [file tail $entry]
    if {$tail in {.git native}} continue
    file copy $entry [file join $tree $tail]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } else {
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        exec cp -a $entry [file join $tree native target]
    }
}

set results {}
set manifest [file join $tree native Cargo.toml]
set timeout [dict get $options -timeout]
try {
    foreach {name description detectors edits} $selected {
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
        set restore {
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
        }
        if {!$applied} {
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            eval $restore
            continue
        }
        # Every mutant rebuilds (a no-op when no native source changed since
        # the last build: an earlier native mutant's build is undone here).
        lassign [run $timeout $tree cargo build --release --manifest-path $manifest] status output
        if {$status != 0} {
            lappend results [list $name $description NOT-BUILT ""]
            puts "NOT-BUILT $name: [lastLine $output]"
            eval $restore
            continue
        }
        set killers {}
        set ran 0
        set byFile [dict create]
        foreach detector $detectors {
            if {[string match rust:* $detector]} {
                set filter [string range $detector 5 end]
                lassign [run $timeout $tree cargo test --release --manifest-path $manifest $filter] status output
                if {$status != 0} {
                    set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
                    lappend killers "$detector ([expr {$failing eq {} ? [lastLine $output] : [join [lrange $failing 0 5] {, }]}])"
                    incr ran
                } elseif {[regexp {test result: ok\. ([1-9]\d*) passed} $output]} {
                    incr ran
                }
                continue
            }
            dict lappend byFile [detectorFile $detector] $detector
        }
        dict for {file names} $byFile {
            set tmp [file tempdir botlish-host-startable-mutant-run]
            lassign [run $timeout $tree tclsh9.0 [file join $tree tests $file] -tmpdir $tmp -match $names] status output
            file delete -force $tmp
            if {![regexp {Total\s+\d+\s+Passed\s+(\d+)\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> passed failed]} {
                lappend killers "$file (did not complete: [lastLine $output])"
                incr ran
                continue
            }
            set failing [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
            set failing [lmap n $failing {if {$n ni $names} continue; set n}]
            incr ran [expr {$passed + $failed}]
            if {$failing ne {}} {
                lappend killers "$file ([join $failing {, }])"
            }
        }
        if {$killers ne {}} {
            set verdict KILLED
        } elseif {$ran == 0} {
            set verdict UNTESTED
        } else {
            set verdict SURVIVED
        }
        lappend results [list $name $description $verdict $killers]
        puts "$verdict $name -- $description"
        foreach killer $killers {
            puts "    $killer"
        }
        flush stdout
        eval $restore
    }
} finally {
    file delete -force $tree
}

set count {}
foreach verdict {KILLED SURVIVED UNTESTED NOT-APPLIED NOT-BUILT} {
    lappend count $verdict [lmap r $results {if {[lindex $r 2] ne $verdict} continue; lindex $r 0}]
}
puts "[llength $results] mutants: [llength [dict get $count KILLED]] killed, [llength [dict get $count SURVIVED]] survived[expr {[dict get $count SURVIVED] eq {} ? "" : " ([join [dict get $count SURVIVED] {, }])"}], [llength [dict get $count UNTESTED]] untested[expr {[dict get $count UNTESTED] eq {} ? "" : " ([join [dict get $count UNTESTED] {, }])"}], [llength [concat [dict get $count NOT-APPLIED] [dict get $count NOT-BUILT]]] not applied or not built"
set bad [concat [dict get $count SURVIVED] [dict get $count NOT-APPLIED] [dict get $count NOT-BUILT]]
if {[dict get $options -untested] eq "fail"} {
    lappend bad {*}[dict get $count UNTESTED]
}
exit [expr {$bad ne {}}]
