# economics.tcl -- FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md's compile cost, per
# program: the front end's time (surface::readProgramFile, best of RUNS);
# the time of the two representation analyses a loop-carried struct design
# extends -- hir::escape::analyze (struct scalar replacement) and
# hir::construction::analyze (virtual construction) -- and how many times
# the escape analysis judges a slot's uses (hir::escape::UseVerdict) and
# classifies an expression (hir::escape::Classify); the whole native
# lowering's time (best of RUNS); the NIR's size (instructions) and the
# machine code's (the driver's `size`); the fold function's roots (the
# driver's `roots`: max live roots, shadow slots, safepoints); and the same
# three for the NIR experiment's field-register program (tools/nir-sra.tcl
# over every function), the code the design would let Cranelift compile.
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/economics.tcl ?-root DIR? ?-runs N? FILE.bot ...
#
# The analyses are measured through wrappers defined in this process around
# the renamed originals (as audit/fold-virtual-construction/tools/
# economics.tcl does: never execution traces, which would stringify a HIR);
# an untimed warm-up lowering per program absorbs the recompilation the
# renames cause. Scratch files live in a `file tempdir` directory.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set runs 3
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -runs { set runs [lindex $argv [incr i]] }
        default { lappend files [file normalize $arg] }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit
set driver [file join $root native target release botlish-native]

foreach {proc var} {hir::escape::analyze escapeUs hir::construction::analyze constructionUs} {
    set ::$var 0
    rename $proc ${proc}Measured
    proc $proc {args} [string map [list VAR $var PROC ${proc}Measured] {
        set started [clock microseconds]
        set result [PROC {*}$args]
        set ::VAR [expr {[clock microseconds] - $started}]
        return $result
    }]
}
set ::counting 0
foreach {proc var} {hir::escape::UseVerdict verdicts hir::escape::Classify classifies} {
    set ::$var 0
    rename $proc ${proc}Measured
    proc $proc {args} [string map [list VAR $var PROC ${proc}Measured] {
        if {$::counting} {
            incr ::VAR
        }
        return [PROC {*}$args]
    }]
}

proc writeText {path text} {
    set ch [open $path w]
    fconfigure $ch -encoding utf-8 -translation lf
    puts -nonewline $ch $text
    close $ch
}

# {CODE-BYTES MAX-LIVE SHADOW SAFEPOINTS} of NIR file PATH: the whole
# program's machine code, and the roots of its function named "f".
proc nirFacts {path} {
    global driver
    set size [lsearch -inline [split [exec $driver size $path 2>@1] \n] {size *}]
    set roots [exec $driver roots $path 2>@1]
    set live -
    set shadow -
    set safe -
    set in 0
    foreach line [split $roots \n] {
        if {[regexp {^function \d+ "([^"]*)"} $line -> name]} {
            set in [expr {$name eq "f"}]
        }
        if {$in} {
            regexp {max live roots: (\d+)} $line -> live
            regexp {shadow slots: (\d+)} $line -> shadow
            regexp {safepoints: (\d+)} $line -> safe
        }
    }
    return [list [lindex $size 1] $live $shadow $safe]
}

set work [file tempdir fvsse]
try {
    puts [format "%-16s %9s %9s %9s %8s %8s %9s %6s %5s %8s %13s | %6s %8s %13s" \
        program front-us escape-us constr-us verdicts classify lower-us nir mat code-B live/shad/safe nir* code-B* live/shad/safe*]
    foreach path $files {
        set bestFront ""
        for {set r 0} {$r < $runs} {incr r} {
            set us [lindex [time {set hir [surface::readProgramFile $path -warnings off]}] 0]
            if {$bestFront eq "" || $us < $bestFront} {
                set bestFront $us
            }
        }
        native::lower::program $hir
        set bestLower ""
        set bestEscape ""
        set bestConstruction ""
        for {set r 0} {$r < $runs} {incr r} {
            set us [lindex [time {set text [native::nir $hir]}] 0]
            if {$bestLower eq "" || $us < $bestLower} {
                set bestLower $us
                set bestEscape $::escapeUs
                set bestConstruction $::constructionUs
            }
        }
        set ::verdicts 0
        set ::classifies 0
        set ::counting 1
        native::nir $hir
        set ::counting 0
        set materialized 0
        foreach rec [native::structCensus $hir] {
            if {[dict get $rec class] eq "materialized"} {
                incr materialized
            }
        }
        set nirPath [file join $work program.nir]
        writeText $nirPath $text
        set sraPath [file join $work program.sra.nir]
        exec tclsh9.0 [file join $here nir-sra.tcl] $nirPath $sraPath
        set ch [open $sraPath r]
        set sraText [read $ch]
        close $ch
        set count {text {llength [regexp -all -inline -line {^    \S} $text]}}
        lassign [nirFacts $nirPath] code live shadow safe
        lassign [nirFacts $sraPath] sraCode sraLive sraShadow sraSafe
        puts [format "%-16s %9d %9d %9d %8d %8d %9d %6d %5d %8s %13s | %6d %8s %13s" \
            [file tail $path] $bestFront $bestEscape $bestConstruction $::verdicts $::classifies $bestLower \
            [apply $count $text] $materialized $code $live/$shadow/$safe \
            [apply $count $sraText] $sraCode $sraLive/$sraShadow/$sraSafe]
        flush stdout
    }
} finally {
    file delete -force $work
}
