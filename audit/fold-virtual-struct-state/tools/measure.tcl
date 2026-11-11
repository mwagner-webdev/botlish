# measure.tcl -- FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md's measurements. Each
# ROW is a Tcl list {LABEL FILE ?OPTION VALUE ...?}:
#
#   -n N            rewrite the program's `n = NUMBER` line to N first
#   -sra OPTIONS    measure the NIR experiment instead of the compiler's
#                   NIR: tools/nir-sra.tcl with OPTIONS (a Tcl list, e.g.
#                   {-functions "scan number_at" -return-fields number_at:1})
#   -consumed 0|1   hir::mutvec::consumedFolds for the front end (default 1:
#                   CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md's default)
#
# and for each prints: the value; the native run's Struct, List and ListPlan
# allocations, List elements copied, construction plans created, in-place
# extensions and materializations, MutableVector and MutableArray shares,
# detaches and detached elements together (one run, native::allocationReport's
# counters, deterministic); the NIR's `structnew`, `structget`, `op
# listappend` and `construct list plan` instructions; the machine code of
# the whole program (the driver's `size`); the native lowering's time (best
# of 3, the compiler's rows only); and with -instructions 1, callgrind's
# instructions per run and their categories (tools/callgrind-diff.py: the
# difference of an N1- and an N2-run profile of `botlish-native bench`, 4
# and 24 runs, 1 and 3 at n >= 16384).
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/measure.tcl \
#       ?-root DIR? ?-instructions 0|1? ROW ...
#
# Every NIR, copy and profile lives in a `file tempdir` directory, removed
# at the end.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set instructions 0
set rows {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -instructions { set instructions [lindex $argv [incr i]] }
        default { lappend rows $arg }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit
set driver [file join $root native target release botlish-native]

proc readText {path} {
    set ch [open $path r]
    fconfigure $ch -encoding utf-8 -translation lf
    set text [read $ch]
    close $ch
    return $text
}

proc writeText {path text} {
    set ch [open $path w]
    fconfigure $ch -encoding utf-8 -translation lf
    puts -nonewline $ch $text
    close $ch
}

proc get {d args} {
    if {[dict exists $d {*}$args]} {
        return [dict get $d {*}$args]
    }
    return 0
}

proc profile {nir n} {
    global driver here work
    lassign [expr {$n ne "" && $n >= 16384 ? {1 3} : {4 24}}] n1 n2
    foreach runs [list $n1 $n2] {
        exec valgrind --tool=callgrind --callgrind-out-file=$work/cg.$runs $driver bench $runs $nir > /dev/null 2>@1
        exec callgrind_annotate --threshold=100 --inclusive=no --auto=no $work/cg.$runs > $work/annotate.$runs 2> /dev/null
    }
    return [exec python3 -I [file join $here callgrind-diff.py] $work/annotate.$n1 $work/annotate.$n2 [expr {$n2 - $n1}]]
}

set work [file tempdir fvssm]
try {
    puts [format "%-34s %6s %7s %6s %5s %9s %5s %6s %5s %10s %5s %4s %4s %4s %7s %8s %s" \
        row n Struct List Plan copied plans extend mat shr/det/el new get app plan code-B lower-ms instr/run]
    foreach row $rows {
        set label [lindex $row 0]
        set path [file normalize [lindex $row 1]]
        set options [dict merge {-n "" -sra "" -consumed 1} [lrange $row 2 end]]
        set text [readText $path]
        set n [dict get $options -n]
        if {$n ne ""} {
            regsub -line {^n = [0-9]+$} $text "n = $n" text
        }
        set copy [file join $work [file tail $path]]
        writeText $copy $text
        set saved $::hir::mutvec::consumedFolds
        set ::hir::mutvec::consumedFolds [dict get $options -consumed]
        try {
            set hir [surface::readProgramFile $copy -warnings off]
        } finally {
            set ::hir::mutvec::consumedFolds $saved
        }
        set best ""
        foreach _ {1 2 3} {
            set us [lindex [time {set nirText [native::nir $hir]}] 0]
            if {$best eq "" || $us < $best} {
                set best $us
            }
        }
        set nirPath [file join $work program.nir]
        writeText $nirPath $nirText
        set lower [format %.1f [expr {$best / 1000.0}]]
        if {[dict get $options -sra] ne ""} {
            set sraPath [file join $work program.sra.nir]
            exec tclsh9.0 [file join $here nir-sra.tcl] {*}[dict get $options -sra] $nirPath $sraPath
            set nirPath $sraPath
            set nirText [readText $nirPath]
            set lower -
        }
        set lines [split [exec $driver run $nirPath --alloc summary 2>@1] \n]
        set value [string range [lsearch -inline $lines {value *}] 6 end]
        set report [lrange [lsearch -inline $lines {alloc *}] 1 end]
        set size [lsearch -inline [split [exec $driver size $nirPath 2>@1] \n] {size *}]
        set code [lindex $size 1]
        # MutableVector and MutableArray shares, detaches and elements
        # copied together (bench/consumed-folds.tcl's columns).
        set ma {}
        foreach field {shares detaches detachElements} {
            lappend ma [expr {[get $report mutableVector $field] + [get $report mutableArray $field]}]
        }
        set perRun -
        if {$instructions} {
            set perRun [profile $nirPath $n]
        }
        puts [format "%-34s %6s %7s %6s %5s %9s %5s %6s %5s %10s %5s %4s %4s %4s %7s %8s %s" \
            $label [expr {$n eq "" ? "-" : $n}] \
            [get $report byKind Struct allocations] [get $report byKind List allocations] \
            [get $report byKind ListPlan allocations] [get $report copies listElements] \
            [get $report construction plansCreated] [get $report construction extensions] \
            [get $report construction materializations] [join $ma /] \
            [regexp -all {= structnew } $nirText] [regexp -all {= structget } $nirText] \
            [regexp -all {= op listappend } $nirText] [regexp -all {= construct list plan } $nirText] \
            $code $lower $perRun]
        puts "    value $value"
        flush stdout
    }
} finally {
    file delete -force $work
}
