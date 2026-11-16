# mutate.tcl -- mutation testing of the standalone Android SDL3 2048
# application, its packages and its generator
# (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/android-sdl3-2048/tools/mutate.tcl ?-only NAME,...?
#       ?-timeout SECONDS? ?-untested fail|ok?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once, with a `!!` line naming the tests that must kill it: as-* of
# tests/android-sdl3-2048.test, et-* of tests/external-tools.test. For each
# mutant a private copy of the repository (a temporary directory) gets the
# replacements and its named detectors run there, each test file with a
# private -tmpdir and -match the named tests. No mutant touches native/, so
# the copy's native/target is a link to this checkout's (nothing rebuilds
# it; the applications are built with the driver it holds). A mutant is
# KILLED when a named detector fails, SURVIVED when every one that ran
# passed, UNTESTED when none ran (each skipped by its constraints: the host
# runs need Linux x86-64, cc, the package-owned libSDL3.so
# (tests/cffi/sdl3.tcl) and SDL's pinned headers; the generator's need
# BOTLISH_SDL3_2048_PACKAGES -- build.sh's OUT/repo -- and ANDROID_NDK_ROOT).
# The report lists each mutant and what killed it; it exits 1 on a
# survivor, a mutant that no longer applies and (with -untested fail, the
# default) an untested one. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 900 -untested fail]
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
    foreach {prefix file} {as- android-sdl3-2048.test et- external-tools.test} {
        if {[string match $prefix* $name]} { return $file }
    }
    error "detector $name: no test file has its prefix (as-, et-)"
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description detectors edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    foreach {file old new} $edits {
        if {[string match native/* $file]} { error "mutant $name edits $file: this harness never rebuilds native/" }
    }
    lappend selected $name $description $detectors $edits
}

# A private copy of the repository (not .git), its native/target a link to
# this checkout's (no mutant rebuilds it).
set tree [file tempdir botlish-android-sdl3-mutants]
foreach entry [glob -nocomplain -directory $root * .cargo .devcontainer .github] {
    set tail [file tail $entry]
    if {$tail in {.git native single}} continue
    if {[string match as-* $tail]} continue
    file copy $entry [file join $tree $tail]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } else {
        file link -symbolic [file join $tree native target] [file normalize $entry]
    }
}

set results {}
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
        set killers {}
        set ran 0
        set byFile [dict create]
        foreach detector $detectors {
            dict lappend byFile [detectorFile $detector] $detector
        }
        dict for {file names} $byFile {
            set tmp [file tempdir botlish-android-sdl3-mutant-run]
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
foreach verdict {KILLED SURVIVED UNTESTED NOT-APPLIED} {
    lappend count $verdict [lmap r $results {if {[lindex $r 2] ne $verdict} continue; lindex $r 0}]
}
puts "[llength $results] mutants: [llength [dict get $count KILLED]] killed, [llength [dict get $count SURVIVED]] survived[expr {[dict get $count SURVIVED] eq {} ? "" : " ([join [dict get $count SURVIVED] {, }])"}], [llength [dict get $count UNTESTED]] untested[expr {[dict get $count UNTESTED] eq {} ? "" : " ([join [dict get $count UNTESTED] {, }])"}], [llength [dict get $count NOT-APPLIED]] not applied"
set bad [concat [dict get $count SURVIVED] [dict get $count NOT-APPLIED]]
if {[dict get $options -untested] eq "fail"} {
    lappend bad {*}[dict get $count UNTESTED]
}
exit [expr {$bad ne {}}]
