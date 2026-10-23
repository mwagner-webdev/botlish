# extract-fuzz.tcl -- the programs a fuzzer generates, written as files and
# never run, for partition B of the warning candidate's repository census
# (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, section 11; partition-b.md here).
#
#   tclsh9.0 audit/icy-tower/context-refactor/warning-census/extract-fuzz.tcl \
#       -out DIR ?-n N? ?-seed S? FUZZER
#
# FUZZER is one of the fuzzers whose programs meet contexts, C pointers,
# native views and edits, extern C functions or direct modules:
#
#   audit/direct-modules/tools/fuzz.tcl   audit/c-ffi/tools/fuzz.tcl
#   audit/c-abi-types/tools/fuzz.tcl      audit/context-traits/tools/fuzz.tcl
#   audit/native-view/tools/fuzz.tcl      audit/native-edit/tools/fuzz.tcl
#
# Every one of them keeps its generator ahead of its main loop, which starts
# at the line `set disagreements 0`. This script evaluates the fuzzer's own
# text up to that line (its options parsed from `-n N -seed S`, its random
# state seeded exactly as a run with them would be), then calls the
# fuzzer's generator the way its main loop does, program after program, in
# the same order -- so that program I is the I-th program of
# `FUZZER -n N -seed S` -- and writes each program's files into
# DIR/programs/ID/. Nothing compiles or runs here: the C library the c-ffi
# fuzzer builds is written (fz.c) but not compiled, and no backend runs (the
# main loops' calls after generation -- C compilation, outcomeUnderHir,
# native runs -- never draw from the random state, so skipping them changes
# no later program). The fuzzer's scratch directory, created by its prelude,
# is removed.
#
# DIR is an existing, private, empty directory; run one fuzzer per process.
# Output, DIR/captures.tsv (extract-tests.tcl's columns):
#
#   ID  FUZZER:SEED:INDEX  ""  fuzz  ENTRY  OPTIONS  0  EXPECT  ""
#
# OPTIONS holds the program's -target when the fuzzer compiles it for one;
# EXPECT is the fuzzer's own model's verdict: `expected ok`, or `expected
# rejected: WHY` (such a program is no evidence: it is compiled, and its
# outcome reported, by the scanner).

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. .. .. ..]]

set extractOptions [dict create -out "" -n 30 -seed 1]
set fuzzer ""
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {[dict exists $extractOptions $a]} {
        dict set extractOptions $a [lindex $argv [incr i]]
    } else {
        set fuzzer [file normalize $a]
    }
}
set extractOut [file normalize [dict get $extractOptions -out]]
if {$extractOut eq "" || ![file isdirectory $extractOut]} {
    error "-out DIR: an existing directory"
}
set extractN [dict get $extractOptions -n]
set extractSeed [dict get $extractOptions -seed]
set extractName [file tail [file dirname [file dirname $fuzzer]]]

namespace eval extract {}

proc extract::Write {path text} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

proc extract::Program {id index files options expect} {
    set dir [file join $::extractOut programs $id]
    set entry ""
    foreach {name text} $files {
        Write [file join $dir $name] $text
        if {$name in {main.bot fuzz.bot}} {
            set entry $name
        }
    }
    set f [open [file join $::extractOut captures.tsv] a]
    fconfigure $f -encoding utf-8 -translation lf
    puts $f [join [list $id $::extractName:$::extractSeed:$index "" fuzz programs/$id/$entry $options 0 $expect ""] \t]
    close $f
}

# The fuzzer's prelude: everything before its main loop.
set f [open $fuzzer r]
fconfigure $f -encoding utf-8
set extractText [read $f]
close $f
set extractCut [string first "\nset disagreements 0\n" $extractText]
if {$extractCut < 0} {
    error "$fuzzer: no main loop marker (set disagreements 0)"
}
set argv [list -n $extractN -seed $extractSeed]
set argc 2
info script $fuzzer
uplevel #0 [string range $extractText 0 $extractCut]

switch -- $extractName {
    direct-modules {
        for {set i 0} {$i < $extractN} {incr i} {
            set seed [expr {$seed0 * 100003 + $i}]
            lassign [generate $seed] files model
            set verdicts [dict get $model verdicts]
            extract::Program [expr {$i + 1}] $i $files {} \
                [expr {$verdicts eq {} ? "expected ok" : "expected rejected: $verdicts"}]
        }
    }
    c-ffi {
        for {set p 0} {$p < $extractN} {incr p} {
            set functions {}
            for {set i 0} {$i < [dict get $options -functions]} {incr i} {
                lappend functions [drawArguments [drawFunction $p $i]]
            }
            set c [cSource $functions]
            set binding [binding $functions]
            lassign [program $functions] main expected
            extract::Program [expr {$p + 1}] $p [list main.bot $main fz.bot $binding fz.c $c] {} "expected ok"
        }
    }
    c-abi-types {
        for {set k 0} {$k < $extractN} {incr k} {
            set kind [pick {pointer pointer pointer scalar imprint}]
            set case [${kind}Case]
            set caseArgs [lassign $case source expect]
            extract::Program [expr {$k + 1}] $k [list main.bot $source] $caseArgs \
                [expr {$expect eq "reject" ? "expected rejected: $kind case, the model's rejection" : "expected ok"}]
        }
    }
    context-traits {
        for {set i 0} {$i < $extractN} {incr i} {
            set seed [expr {$seed0 + $i}]
            set p [generate $seed]
            set files [list main.bot [dict get $p text]]
            dict for {name text} [dict get $p modules] {
                lappend files fz/$name.bot $text
            }
            set expect [dict get $p expect]
            extract::Program [expr {$i + 1}] $i $files {} \
                [expr {[lindex $expect 0] eq "error" ? "expected rejected: [lindex $expect 1]" : "expected ok"}]
        }
    }
    native-view - native-edit {
        for {set i 0} {$i < $extractN} {incr i} {
            lassign [program $i] text expected
            extract::Program [expr {$i + 1}] $i [list fuzz.bot $text] {} "expected ok"
        }
    }
    default {
        error "unknown fuzzer $extractName"
    }
}
if {[info exists scratch] && [file isdirectory $scratch] && [string match */tmp/* $scratch]} {
    file delete -force $scratch
}
exit 0
