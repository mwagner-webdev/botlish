# mutate.tcl -- can the tests of compiler-managed scratch storage
# (STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md) fail, and for the reason
# they state?
#
#   tclsh9.0 audit/storage-scratch/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant of mutants.txt beside this script (the format is its header's)
# is a deliberate break of one rule -- of the plan, the lowering, the storage
# provider, the collector's treatment of scratch storage, the code
# generator's request and destination, the NIR validator, or one of the
# lifetime facts the plan reads. It is applied to a private copy of the
# compiler, library, tests, audit tools and native backend (a temporary
# directory; native/target a real copy, rebuilt for a mutant that edits
# native/src and again after it), and the detectors its `!!` line names
# run against the copy:
#
#   ss-NAME, sl-NAME  those tests of tests/scratch-storage.test and
#                     tests/storage-lifetime.test (with a private -tmpdir);
#   fuzz              the differential fuzzer (fuzz.tcl, seeds 1-2, 4
#                     programs each, every mode);
#   rust              cargo test --lib scratch (the provider, the VM's
#                     request and the collector, the NIR protocol).
#
# A mutant is killed only when one of its named detectors fails; a mutant
# that does not apply exactly once, or does not build, fails the run. The
# unmutated copy runs every detector first and must pass them all. The real
# checkout, its native/target included, is never modified.
#
# Output: one line per mutant -- KILLED (by which detectors), SURVIVED,
# NOT-APPLIED or NOT-BUILT. Exits 1 unless every mutant applies, builds and
# is killed.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -timeout 2400]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of PATH: {NAME DESCRIPTION DETECTORS {FILE OLD NEW ...}}.
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
                } elseif {[regexp {^!! (.*)$} $line -> d]} {
                    set detectors $d
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

# Runs ARGS in directory DIR for at most TIMEOUT seconds: {STATUS OUTPUT}.
proc run {timeout dir args} {
    set here [pwd]
    cd $dir
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
    }
    cd $here
    return [list $status $output]
}

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 160]
}

# The named detectors of DETECTORS that fail against TREE.
proc detect {tree detectors timeout} {
    set failed {}
    set ::env(LANG) C.utf8
    set ::env(LC_ALL) C.utf8
    foreach {file prefix} {scratch-storage.test ss- storage-lifetime.test sl-} {
        set names [lmap d $detectors {if {[string match $prefix* $d]} {set d} else continue}]
        if {$names eq {}} continue
        set tmp [file tempdir botlish-scratch-mutant-run]
        lassign [run $timeout $tree tclsh9.0 [file join $tree tests $file] -tmpdir $tmp -match $names] status output
        file delete -force $tmp
        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> n]} {
            lappend failed "$file (did not complete: [lastLine $output])"
            continue
        }
        foreach {- t} [regexp -all -inline -line {^==== (\S+) FAILED$} $output] {
            lappend failed $t
        }
    }
    if {"fuzz" in $detectors} {
        lassign [run $timeout $tree tclsh9.0 [file join $tree audit storage-scratch tools fuzz.tcl] -seeds 1-2 -count 4] status output
        if {$status != 0} {
            lappend failed "fuzz ([lastLine $output])"
        }
    }
    if {"rust" in $detectors} {
        lassign [run $timeout $tree cargo test --release --manifest-path [file join $tree native Cargo.toml] --lib scratch] status output
        if {$status != 0} {
            set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
            lappend failed "rust ([join [lrange $failing 0 5] {, }])"
        }
    }
    return $failed
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description detectors edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {$detectors eq {}} {
        error "mutant $name names no detector that must kill it (!!)"
    }
    lappend selected $name $description $detectors $edits
}

# The private copy: native/target a real copy (a copied link would build
# every native mutant into this checkout).
set tree [file tempdir botlish-scratch-mutants]
foreach dir {compiler compilerpedia core hir surface stdlib service lsp ccompile tests examples audit .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
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
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}
file copy [file join $root rust-toolchain.toml] $tree

set timeout [dict get $options -timeout]
set manifest [file join $tree native Cargo.toml]
proc build {} {
    global timeout tree manifest
    return [run $timeout $tree cargo build --release --manifest-path $manifest]
}

set results {}
set failures 0
try {
    lassign [build] status output
    if {$status != 0} {
        puts "BASELINE not built: [lastLine $output]"
        exit 1
    }
    set all [lsort -unique [concat {*}[lmap {n d detectors e} $selected {set detectors}]]]
    set baseline [detect $tree $all $timeout]
    if {$baseline ne {}} {
        puts "BASELINE (the unmutated copy) fails: [join $baseline {, }]"
        exit 1
    }
    puts "BASELINE: every detector passes on the unmutated copy"
    flush stdout
    set dirty 0
    foreach {name description detectors edits} $selected {
        set saved [dict create]
        set applied 1
        set native 0
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $saved $path]} {
                dict set saved $path [readFile $path]
            }
            set text [readFile $path]
            set at [string first $old $text]
            if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
                set applied 0
                break
            }
            writeFile $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
            if {[string match native/src/* $file]} {
                set native 1
            }
        }
        if {!$applied} {
            puts "NOT-APPLIED $name: a text does not occur exactly once"
            incr failures
        } elseif {($native || $dirty) && [lindex [set built [build]] 0] != 0} {
            puts "NOT-BUILT $name: [lastLine [lindex $built 1]]"
            incr failures
            set dirty 1
        } else {
            set dirty $native
            set failed [detect $tree $detectors $timeout]
            if {$failed ne {}} {
                puts "KILLED $name -- by [join $failed {, }]"
            } else {
                puts "SURVIVED $name -- $description"
                incr failures
            }
        }
        flush stdout
        dict for {path text} $saved {
            writeFile $path $text
        }
    }
} finally {
    file delete -force $tree
}
puts "[expr {[llength $selected] / 4}] mutants, $failures not killed"
exit [expr {$failures > 0}]
