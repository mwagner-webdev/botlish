# mutate.tcl -- mutation testing of semantic value identity and
# std::immutable_map (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md, "Mutation
# testing").
#
#   tclsh9.0 audit/value-identity/tools/mutate.tcl ?-only NAME,...? ?-jobs N?
#       ?-tests FILES? ?-fuzz-count N? ?-fuzz-seed S? ?-all-detectors 0|1?
#       ?-timeout SECONDS? ?-mutants FILE?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as source replacements. For each, a private copy of the compiler,
# library and native backend (a temporary directory) gets the replacements,
# and the detectors run against it, in order, until one kills it (every one
# with -all-detectors 1):
#
#   * the mutant's own test files (its `%% tests` line), then FILES
#     (default: tests/value-identity.test, tests/immutable-map.test), each
#     with a private -tmpdir: killed if any test fails or a file does not
#     complete;
#   * audit/value-identity/tools/fuzz.tcl -n N -seed S on the compiled
#     backends (every key and value kind against the independent model, no
#     interpreter runs): killed if it reports a disagreement or does not
#     complete;
#   * for a native mutant (one that edits native/src/ or the crate's
#     manifest), first a release build of the copy's native backend (a mutant
#     that does not build is reported NOT-BUILT, never counted as killed).
#
# Each detector run is limited to -timeout seconds (900): a mutant that makes
# a probe or a rebuild loop forever is killed as "did not complete".
#
# -jobs N runs the mutants in N processes, each with its own copy; native
# mutants all go to the first (the only copy whose native/target is a real
# copy, rebuilt per mutant; the others link this checkout's). A mutant every
# detector misses SURVIVES; the report lists each mutant, what killed it
# first (every detector that kills it, with -all-detectors 1) and the
# survivors. The real checkout, including its native/target, is never
# modified.

set script [file normalize [info script]]
set root [file dirname [file dirname [file dirname [file dirname $script]]]]

set options [dict create -only "" -jobs 1 -shard "" \
    -tests {tests/value-identity.test tests/immutable-map.test} \
    -fuzz-count 6 -fuzz-seed 5 -all-detectors 0 -timeout 900 -mutants ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION TESTS {FILE MODE OLD NEW ...} ...}.
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
                    if {$name ne ""} { lappend mutants $name $description $tests $edits }
                    set name $n
                    set description $d
                    set tests {}
                    set edits {}
                } elseif {[regexp {^%% tests (.*)$} $line -> files]} {
                    set tests $files
                } elseif {[regexp {^## (\S+)$} $line -> file]} {
                    set current $file
                } elseif {$line eq "<<<<" || $line eq "<<<< all"} {
                    set mode [expr {$line eq "<<<<" ? "once" : "all"}]
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
                    lappend edits $current $mode [join $old \n] [join $new \n]
                    set state outside
                } else {
                    lappend new $line
                }
            }
        }
    }
    if {$name ne ""} { lappend mutants $name $description $tests $edits }
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

proc isNative {edits} {
    foreach {file mode old new} $edits {
        if {[string match native/src/* $file] || [string match native/Cargo.* $file]} {
            return 1
        }
    }
    return 0
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
    return [string range [lindex [split [string trim $output] \n] end] 0 160]
}

set mutantsFile [dict get $options -mutants]
if {$mutantsFile eq ""} {
    set mutantsFile [file join [file dirname $script] mutants.txt]
}
set all [readMutants [file normalize $mutantsFile]]
set only [split [dict get $options -only] ,]
set selected {}
foreach {name description tests edits} $all {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $tests $edits
}

# ---------------------------------------------------------------------------
# -jobs N: the shards, run as child processes, their reports merged.

if {[dict get $options -jobs] > 1 && [dict get $options -shard] eq ""} {
    set jobs [dict get $options -jobs]
    set pass {}
    dict for {option value} $options {
        if {$option ni {-jobs -shard}} {
            lappend pass $option $value
        }
    }
    set channels {}
    for {set i 0} {$i < $jobs} {incr i} {
        set channel [open |[list tclsh9.0 $script {*}$pass -shard $i/$jobs 2>@1] r]
        fconfigure $channel -encoding utf-8
        lappend channels $channel
    }
    set lines {}
    foreach channel $channels {
        while {[gets $channel line] >= 0} {
            if {[string match "RESULT *" $line]} {
                lappend lines [string range $line 7 end]
            } else {
                puts $line
                flush stdout
            }
        }
        catch {close $channel}
    }
    set results [lmap line $lines {lindex $line 0}]
} else {
    # One process: every selected mutant, or the shard's (native mutants
    # all in shard 0).
    if {[dict get $options -shard] ne ""} {
        lassign [split [dict get $options -shard] /] index count
        set mine {}
        set i 0
        foreach {name description tests edits} $selected {
            if {[isNative $edits]} {
                set owner 0
            } else {
                set owner [expr {$i % $count}]
                incr i
            }
            if {$owner == $index} {
                lappend mine $name $description $tests $edits
            }
        }
        set selected $mine
    }
    # Tcl-only mutants first.
    set ordered {}
    set natives {}
    foreach {name description tests edits} $selected {
        if {[isNative $edits]} {
            lappend natives $name $description $tests $edits
        } else {
            lappend ordered $name $description $tests $edits
        }
    }
    set selected [concat $ordered $natives]

    set tree [file tempdir botlish-vi-mutants]
    foreach dir {compiler core hir surface stdlib tests examples audit/value-identity audit/hashable .cargo} {
        if {![file exists [file join $root $dir]]} continue
        file mkdir [file dirname [file join $tree $dir]]
        file copy [file join $root $dir] [file join $tree $dir]
    }
    file mkdir [file join $tree native]
    foreach entry [glob -directory [file join $root native] *] {
        if {[file tail $entry] ne "target"} {
            file copy $entry [file join $tree native]
        } elseif {$natives ne {}} {
            # Copy the directory, following links: a copied link would build
            # every native mutant into the checkout it points to (AGENTS.md,
            # "Running tests concurrently").
            while {[file type $entry] eq "link"} {
                set entry [file join [file dirname $entry] [file readlink $entry]]
            }
            exec cp -a $entry [file join $tree native target]
        } else {
            file link -symbolic [file join $tree native target] $entry
        }
    }
    foreach entry [glob -directory $root -types f *.tcl] {
        file copy $entry $tree
    }

    set results {}
    set manifest [file join $tree native Cargo.toml]
    set timeout [dict get $options -timeout]
    try {
        foreach {name description ownTests edits} $selected {
            set touched [dict create]
            set applied 1
            foreach {file mode old new} $edits {
                set path [file join $tree $file]
                if {![dict exists $touched $file]} {
                    dict set touched $file [readFile $path]
                }
                set text [readFile $path]
                set first [string first $old $text]
                if {$first < 0 || ($mode eq "once" && [string first $old $text [expr {$first + 1}]] >= 0)} {
                    set applied 0
                    break
                }
                if {$mode eq "once"} {
                    set text [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
                } else {
                    set text [string map [list $old $new] $text]
                }
                writeFile $path $text
            }
            if {!$applied} {
                # The code the mutant edits changed: update mutants.txt.
                set result [list $name NOT-APPLIED "the text to replace does not occur [expr {$mode eq "once" ? "exactly once" : "at all"}] in $file"]
            } else {
                set result ""
                set native [isNative $edits]
                if {$native} {
                    # Cargo finds the copy's .cargo/config.toml (frame
                    # pointers) from the working directory.
                    set here [pwd]
                    cd $tree
                    lassign [run $timeout cargo build --release --manifest-path $manifest] status output
                    cd $here
                    if {$status != 0} {
                        set result [list $name NOT-BUILT [lastLine $output]]
                    }
                }
                if {$result eq ""} {
                    set killers {}
                    foreach testFile [concat $ownTests [lmap t [dict get $options -tests] {if {$t in $ownTests} continue; set t}]] {
                        if {$killers ne {} && ![dict get $options -all-detectors]} break
                        set tmp [file tempdir botlish-vi-mutant-run]
                        lassign [run $timeout tclsh9.0 [file join $tree $testFile] -tmpdir $tmp] status output
                        file delete -force $tmp
                        set failed [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
                        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
                            lappend killers "[file tail $testFile] did not complete: [lastLine $output]"
                        } elseif {$failed ne {}} {
                            lappend killers "[file tail $testFile]: [join [lrange [lsort -unique $failed] 0 4] {, }][expr {[llength [lsort -unique $failed]] > 5 ? ", ..." : ""}]"
                        }
                    }
                    if {$killers eq {} || [dict get $options -all-detectors]} {
                        set scratch [file tempdir botlish-vi-mutant-fuzz]
                        set here [pwd]
                        cd $scratch
                        lassign [run $timeout tclsh9.0 [file join $tree audit value-identity tools fuzz.tcl] \
                            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed] \
                            -interp-every 0 -backends {compile cranelift-generic cranelift}] status output
                        cd $here
                        file delete -force $scratch
                        set summary [lsearch -inline -regexp [split $output \n] {programs, .* disagreements}]
                        if {[regexp {(\d+) programs, .* (\d+) disagreements} $summary -> programs n]} {
                            if {$n > 0} {
                                lappend killers "fuzz: $n disagreements in $programs programs"
                            }
                        } else {
                            lappend killers "fuzz did not complete: [lastLine $output]"
                        }
                    }
                    set verdict [expr {$killers eq {} ? "SURVIVED" : "KILLED"}]
                    set result [list $name $verdict [join $killers {; }]]
                }
            }
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            lappend results $result
            lassign $result - verdict detail
            puts "$verdict $name -- $description\n    $detail"
            puts "RESULT [list $result]"
            flush stdout
        }
    } finally {
        file delete -force $tree
    }
    if {[dict get $options -shard] ne ""} {
        exit 0
    }
}

set survivors [lmap r $results {if {[lindex $r 1] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 1] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 1 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
