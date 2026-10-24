# mutate.tcl -- mutation testing of the single-file compiler's packaging of
# the system linker (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/single-executable/tools/mutate.tcl ?-only NAME,...? ?-basekit PATH?
#
# Each mutant of mutants.txt (beside this script) edits single/main.tcl or
# single/package.tcl in a private copy of what single/package.tcl packs.
# For each, the copy is packed into a single executable -- with the base kit
# (-basekit, else $BOTLISH_BASEKIT, else the one single/build.sh cached) and
# this checkout's built native backend, stripped once -- and the two smoke
# tests run against it: single/smoke-test.sh (no toolchain) and
# single/ffi-smoke-test.sh (the host's cc). A mutant both pass SURVIVES; the
# report lists what killed each and exits 1 on a survivor or a mutant that no
# longer applies (update its text when the code it mutates changes, keeping
# it a mutant of the same rule). Linux x86-64 only, as the single executable.
# Needs the native backend built (cargo build --release --manifest-path
# native/Cargo.toml) and a C toolchain; the checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -basekit ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set basekit [dict get $options -basekit]
if {$basekit eq "" && [info exists ::env(BOTLISH_BASEKIT)]} { set basekit $::env(BOTLISH_BASEKIT) }
if {$basekit eq ""} {
    set cache [file join $::env(HOME) .cache]
    if {[info exists ::env(XDG_CACHE_HOME)]} { set cache $::env(XDG_CACHE_HOME) }
    set basekit [file join $cache botlish-single tclsh9.0.1-static]
}
if {![file executable $basekit]} {
    puts stderr "no base kit at $basekit: run single/build.sh once (it builds and caches one), or pass -basekit"
    exit 2
}

proc readFile {path} {
    set f [open $path r]; fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]; close $f
    return $text
}
proc writeFile {path text} {
    set f [open $path w]; fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text; close $f
}

# The mutants, as {NAME DESCRIPTION {FILE OLD NEW ...}}.
proc readMutants {path} {
    set mutants {}
    set name ""
    set state outside
    foreach line [split [readFile $path] \n] {
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+) (.*)$} $line -> n d]} {
                    if {$name ne ""} { lappend mutants $name $description $edits }
                    lassign [list $n $d {}] name description edits
                } elseif {[regexp {^## (\S+)$} $line -> file]} {
                    set current $file
                } elseif {$line eq "<<<<"} {
                    set state old
                    set old {}
                }
            }
            old {
                if {$line eq "===="} { set state new; set new {} } else { lappend old $line }
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

set only [split [dict get $options -only] ,]
set tree [file tempdir botlish-single-mutants]
try {
    # What single/package.tcl packs, and what the smoke tests read.
    foreach item {main.tcl LICENSE core compiler hir surface service lsp stdlib single examples} {
        file copy [file join $root $item] [file join $tree $item]
    }
    file mkdir [file join $tree native] [file join $tree compilerpedia] [file join $tree tests cffi]
    foreach path [glob -directory [file join $root native] *.tcl] { file copy $path [file join $tree native] }
    file copy [file join $root compilerpedia compilerpedia.tcl] [file join $tree compilerpedia]
    foreach dir {topics generated} { file copy [file join $root compilerpedia $dir] [file join $tree compilerpedia $dir] }
    file copy [file join $root tests cffi fixture.c] [file join $tree tests cffi]
    set nativeDir [file join $tree native-built]
    file mkdir $nativeDir
    foreach name {botlish-native botlish-aot-stub libbotlish_runtime.a} {
        set built [file join $root native target release $name]
        if {![file isfile $built]} { error "missing $built: build the native backend first" }
        file copy $built $nativeDir
        catch {exec strip --strip-debug [file join $nativeDir $name]}
    }
    set results {}
    foreach {name description edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
        if {$only ne {} && $name ni $only} continue
        set touched [dict create]
        set applied 1
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $touched $file]} { dict set touched $file [readFile $path] }
            set text [readFile $path]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} { set applied 0; break }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            lappend results [list $name NOT-APPLIED]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
        } else {
            set exe [file join $tree out botlish]
            file mkdir [file dirname $exe]
            set killers {}
            if {[catch {exec $basekit [file join $tree single package.tcl] $exe $nativeDir 2>@1} message]} {
                lappend killers "package.tcl ([lindex [split [string trim $message] \n] end])"
            } else {
                foreach script {smoke-test.sh ffi-smoke-test.sh} {
                    set home [file tempdir botlish-single-mutant-home]
                    set status [catch {exec env HOME=$home PATH=/usr/bin:/bin bash [file join $tree single $script] $exe 2>@1} output]
                    file delete -force $home
                    if {$status} {
                        set fail [lsearch -inline -glob [split $output \n] FAIL:*]
                        if {$fail eq ""} { set fail [lindex [split [string trim $output] \n] end] }
                        lappend killers "$script ($fail)"
                    }
                }
            }
            set verdict [expr {$killers eq {} ? "SURVIVED" : "KILLED"}]
            lappend results [list $name $verdict]
            puts "$verdict $name -- $description"
            foreach killer $killers { puts "    $killer" }
            flush stdout
        }
        dict for {file text} $touched { writeFile [file join $tree $file] $text }
    }
} finally {
    file delete -force $tree
}
set survivors [lmap r $results {if {[lindex $r 1] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 1] ne "NOT-APPLIED"} continue; lindex $r 0}]
puts "[llength $results] mutants, [llength [lsearch -all -index 1 $results KILLED]] killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
