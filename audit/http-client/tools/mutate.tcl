# mutate.tcl -- mutation testing of the http package, its native unit and
# its provider's recipe (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "Mutation
# testing").
#
#   tclsh9.0 audit/http-client/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the repository's sources (a temporary
# directory; native/target a symlink to this checkout's, never rebuilt: no
# mutant edits the native backend) gets the replacements, and the detectors
# its `%%` and `!!` lines name run against it: test files (each in its own
# process with a private -tmpdir; PATTERNs, a tcltest -match) and tools (run
# in the tree, from its root). The mutant is killed when a test fails, a
# file does not complete or a tool fails; a mutant nothing kills SURVIVES.
#
# The native unit is built in the tree's own cache (BOTLISH_CACHE_DIR, its
# http-package/ holding the checkout cache's BoringSSL source, build and
# provider by symbolic link -- no mutant edits how BoringSSL is built -- and
# its own provider archive, units and cargo target, the last seeded with a
# copy of the checkout's). The real checkout and its cache are never
# modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt, as {NAME DESCRIPTION {FILE OLD NEW ...} TESTS TOOLS ...}.
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
                    if {$name ne ""} { lappend mutants $name $description $edits $tests $tools }
                    set name $n
                    set description $d
                    set edits {}
                    set tests {}
                    set tools {}
                } elseif {[regexp {^%% (.+)$} $line -> files]} {
                    lappend tests {*}$files
                } elseif {[regexp {^!! (.+)$} $line -> command]} {
                    lappend tools $command
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
    if {$name ne ""} { lappend mutants $name $description $edits $tests $tools }
    return $mutants
}
set mutants [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]]

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

proc cacheDir {} {
    foreach {var sub} {BOTLISH_CACHE_DIR {} XDG_CACHE_HOME botlish} {
        if {[info exists ::env($var)] && $::env($var) ne ""} {
            return [file normalize [file join $::env($var) {*}$sub]]
        }
    }
    return [file normalize [file join [file home] .cache botlish]]
}

# A private copy of the sources the tests read, and its cache.
set tree [file tempdir botlish-http-mutants]
foreach dir {compiler core hir surface stdlib tests service lsp pm tools single compilerpedia packages audit/http-client} {
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        file link -symbolic [file join $tree native target] $entry
    } else {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}
set cache [file join $tree .cache]
set shared [file join [cacheDir] http-package]
file mkdir [file join $cache http-package cargo]
foreach sub {src build provider} {
    if {[file exists [file join $shared $sub]]} {
        file link -symbolic [file join $cache http-package $sub] [file join $shared $sub]
    }
}
foreach kind [glob -nocomplain -directory [file join $shared cargo] -tails *] {
    exec cp -a [file join $shared cargo $kind] [file join $cache http-package cargo $kind]
}
set ::env(BOTLISH_CACHE_DIR) $cache

proc run {timeout dir args} {
    set status 0
    if {[catch {exec sh -c {cd "$1" && shift && exec "$@"} sh $dir timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

set only [split [dict get $options -only] ,]
set results {}
try {
    foreach {name description edits tests tools} $mutants {
        if {$only ne {} && $name ni $only} continue
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
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        # The native files of this tree (tests/cffi/http.tcl: the provider
        # archive, the released and the test unit), rebuilt from its sources:
        # what an earlier mutant's build left in the tree's cache is removed
        # first (the recipe reuses a stamped archive, which would hide a
        # mutant of the recipe itself). cargo's own incremental state stays.
        foreach sub {provider-archives units stub-bssl} {
            file delete -force [file join $cache http-package $sub]
        }
        lassign [run [dict get $options -timeout] $tree tclsh9.0 [file join $tree tests cffi http.tcl]] status output
        if {$status != 0} {
            lappend results [list $name $description NOT-BUILT ""]
            puts "NOT-BUILT $name: [lindex [split [string trim $output] \n] end]"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set verdicts {}
        foreach spec $tests {
            set colon [string first : $spec]
            set testFile [expr {$colon < 0 ? $spec : [string range $spec 0 [expr {$colon - 1}]]}]
            set match [expr {$colon < 0 ? "" : [split [string range $spec [expr {$colon + 1}] end] ,]}]
            set tmp [file tempdir botlish-http-mutant-run]
            set extra {}
            if {$match ne ""} { set extra [list -match $match] }
            lassign [run [dict get $options -timeout] $tree tclsh9.0 [file join $tree tests $testFile] -tmpdir $tmp {*}$extra] status output
            file delete -force $tmp
            set failed [lsort -unique [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]]
            if {![regexp {Total\s+\d+\s+Passed} $output]} {
                lappend verdicts "killed ($testFile did not complete)"
            } elseif {[regexp {Total\s+\d+\s+Passed\s+(\d+)\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> passed n] && $n > 0} {
                lappend verdicts "killed ($testFile: $n failed: [join [lrange $failed 0 5] {, }])"
            } elseif {$passed == 0} {
                lappend verdicts "inconclusive ($testFile: nothing passed, nothing failed: its constraints?)"
            }
        }
        foreach command $tools {
            lassign [run [dict get $options -timeout] $tree {*}$command] status output
            if {$status != 0} {
                lappend verdicts "killed ([lindex $command 1]: [lindex [split [string trim $output] \n] end])"
            }
        }
        set killedBy [lsearch -all -inline $verdicts killed*]
        set verdict [expr {$killedBy ne {} ? "KILLED" : "SURVIVED"}]
        set shown [expr {$verdicts eq {} ? "survived" : [join $verdicts {; }]}]
        lappend results [list $name $description $verdict $shown]
        puts "$verdict $name\n    $shown"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
