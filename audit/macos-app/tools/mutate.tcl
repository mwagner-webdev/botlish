# mutate.tcl -- mutation testing of the macOS application's packaging
# (MACOS-AARCH64-MILESTONE-9.md, "Mutation testing").
#
#   tclsh9.0 audit/macos-app/tools/mutate.tcl -tcl-framework DIR ?-only NAME,...?
#
# Each mutant of mutants.txt (beside this script) edits the launcher, the
# application's build, single/main.tcl or single/package.tcl in a private
# copy of what single/macos/build.sh packs and the acceptance scripts read.
# For each, the copy builds Botlish.app (single/macos/build.sh --no-verify,
# with -tcl-framework DIR, a single/macos/tcl-framework.sh output, and this
# checkout's built native backend: no cargo, no Tcl build). A mutant whose
# build fails is NOT-BUILT, never counted as killed. Then the detectors run,
# cheapest first, until one fails:
#
#   verify   single/macos/verify.sh --checkout COPY on the application
#   archive  the download archive extracted with unzip and verified
#   smoke    single/smoke-test.sh on the application's launcher
#   ffi      single/ffi-smoke-test.sh
#   app      single/macos/app-test.sh
#   seal     the application verified again after the runs (the compiler
#            wrote nothing into it)
#
# A mutant every detector passes SURVIVES. The killing failure is classified
# by its group (FAIL[GROUP]) and its words as packaging, code signing,
# framework loading, ZIP mounting, runtime linking or compiler behavior.
# The unmutated copy runs first: it must pass every detector, else the run
# stops (the test environment, not a mutant, failed). The report lists each
# mutant, its verdict and what killed it; it exits 1 on a survivor or a
# mutant that no longer applies (update its text when the code it mutates
# changes, keeping it a mutant of the same rule). macOS on Apple Silicon
# with the developer tools; the checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -tcl-framework ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set framework [dict get $options -tcl-framework]
if {$framework eq "" || ![file isdirectory [file join $framework Tcl.framework]]} {
    puts stderr "usage: tclsh9.0 audit/macos-app/tools/mutate.tcl -tcl-framework DIR ?-only NAME,...? (DIR: a single/macos/tcl-framework.sh output)"
    exit 2
}
set framework [file normalize $framework]
set nativeDir [file join $root native target release]
foreach name {botlish-native libbotlish_runtime.a} {
    if {![file isfile [file join $nativeDir $name]]} {
        puts stderr "missing [file join $nativeDir $name]: build the native backend first"
        exit 2
    }
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

# What killed a mutant, classified: DETECTOR's failing OUTPUT.
proc Classify {detector output} {
    set line [lsearch -inline -regexp [split $output \n] {^FAIL}]
    if {$line eq ""} { set line [lindex [split [string trim $output] \n] end] }
    set group ""
    regexp {^FAIL\[([^\]]+)\]} $line -> group
    set text [string tolower $output]
    if {$group in {signature tamper} || $detector eq "seal" || [regexp {does not verify|codesign|sealed resource|code object is not signed|invalid signature|not signed ad hoc|linker-signed} $text]} {
        set kind "code signing"
    } elseif {$group eq "dependencies" || [regexp {cannot load tcl|library not loaded|loaded tcl from|lc_rpath|install name} $text]} {
        set kind "framework loading"
    } elseif {[regexp {compiler archive|cannot mount|holds no main.tcl|//zipfs:/app/botlish/stdlib/nosuch} $text]} {
        set kind "ZIP mounting"
    } elseif {[regexp {runtime archive|native link|ran no cc|system linker} $text]} {
        set kind "runtime linking"
    } elseif {$group in {layout archive}} {
        set kind packaging
    } else {
        set kind "compiler behavior"
    }
    return [list $kind "$detector: [string range $line 0 200]"]
}

# Runs the detectors on the application built from TREE in OUT; returns ""
# when every one passes, else {KIND WHAT}.
proc Detect {tree out} {
    set app [file join $out Botlish.app]
    set launcher [file join $app Contents MacOS botlish]
    set env [list env HOME=[file join $out home] PATH=/usr/bin:/bin:/usr/sbin:/sbin LANG=en_US.UTF-8]
    file mkdir [file join $out home]
    set detectors [list \
        verify [list {*}$env bash [file join $tree single macos verify.sh] --checkout $tree $app] \
        archive [list {*}$env bash -c {rm -rf "$2/x" && mkdir "$2/x" && cd "$2/x" && unzip -q "$2/botlish-macos-aarch64.zip" && bash "$1/single/macos/verify.sh" --checkout "$1" "$2/x/Botlish.app"} - $tree $out] \
        smoke [list {*}$env bash [file join $tree single smoke-test.sh] $launcher] \
        ffi [list {*}$env bash [file join $tree single ffi-smoke-test.sh] $launcher [file join $tree tests cffi fixture.c]] \
        app [list {*}$env bash [file join $tree single macos app-test.sh] $app] \
        seal [list codesign --verify --deep --strict --verbose=2 $app]]
    foreach {name command} $detectors {
        if {[catch {exec {*}$command 2>@1} output]} {
            return [Classify $name $output]
        }
    }
    return ""
}

# Builds the application of TREE into OUT: "" or why not.
proc Build {tree out} {
    global framework nativeDir
    file delete -force $out
    if {[catch {exec env PATH=/usr/bin:/bin:/usr/sbin:/sbin HOME=$::env(HOME) \
            bash [file join $tree single macos build.sh] -o $out --no-verify --tcl-framework $framework --native-dir $nativeDir 2>@1} output]} {
        return [lindex [split [string trim $output] \n] end]
    }
    return ""
}

set only [split [dict get $options -only] ,]
set tree [file tempdir botlish-app-mutants]
set out [file join [file tempdir botlish-app-mutants-out] build]
try {
    foreach item {main.tcl LICENSE core compiler hir surface service lsp stdlib single examples} {
        file copy [file join $root $item] [file join $tree $item]
    }
    file mkdir [file join $tree native runtime-archive] [file join $tree compilerpedia] [file join $tree tests cffi] [file join $tree audit macos-app]
    foreach path [glob -directory [file join $root native] *.tcl] { file copy $path [file join $tree native] }
    file copy [file join $root native runtime-archive libraries.tcl] [file join $tree native runtime-archive]
    file copy [file join $root compilerpedia compilerpedia.tcl] [file join $tree compilerpedia]
    foreach dir {topics generated} { file copy [file join $root compilerpedia $dir] [file join $tree compilerpedia $dir] }
    file copy [file join $root tests cffi fixture.c] [file join $tree tests cffi]
    file copy [file join $root audit macos-app programs] [file join $tree audit macos-app programs]
    file delete -force [file join $tree single out]

    puts "== the unmutated application"
    set why [Build $tree $out]
    if {$why ne ""} {
        puts stderr "the unmutated tree does not build: $why"
        exit 2
    }
    set killed [Detect $tree $out]
    if {$killed ne ""} {
        puts stderr "the unmutated application fails a detector (the test environment): [join $killed {: }]"
        exit 2
    }
    puts "   builds and passes every detector"
    flush stdout

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
            set new [string map [list @CHECKOUT@ $tree] $new]
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            lappend results [list $name NOT-APPLIED]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
        } else {
            set why [Build $tree $out]
            if {$why ne ""} {
                lappend results [list $name NOT-BUILT]
                puts "NOT-BUILT $name -- $description\n    $why"
            } else {
                set killed [Detect $tree $out]
                if {$killed eq ""} {
                    lappend results [list $name SURVIVED]
                    puts "SURVIVED $name -- $description"
                } else {
                    lappend results [list $name KILLED [lindex $killed 0]]
                    puts "KILLED $name -- $description\n    [lindex $killed 0]: [lindex $killed 1]"
                }
            }
        }
        flush stdout
        dict for {file text} $touched { writeFile [file join $tree $file] $text }
    }
} finally {
    file delete -force $tree [file dirname $out]
}
set count [dict create]
foreach r $results { dict incr count [lindex $r 1] }
set survivors [lmap r $results {if {[lindex $r 1] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 1] ne "NOT-APPLIED"} continue; lindex $r 0}]
set kinds [dict create]
foreach r $results { if {[lindex $r 1] eq "KILLED"} { dict incr kinds [lindex $r 2] } }
puts "[llength $results] mutants: [join [lmap {k n} $count {string cat $n " " $k}] {, }]"
puts "killed by: [join [lmap {k n} $kinds {string cat $k " " $n}] {, }]"
if {$survivors ne {}} { puts "survived: [join $survivors {, }]" }
if {$unapplied ne {}} { puts "not applied: [join $unapplied {, }]" }
exit [expr {$survivors ne {} || $unapplied ne {}}]
