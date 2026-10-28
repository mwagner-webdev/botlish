# original-names.tcl -- the scheduler with its driver operations under their
# intended names (CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md).
#
#   tclsh9.0 audit/event-loop/tools/original-names.tcl ?-only GLOB? ?-backends LIST?
#
# The exploration named the `Driver` context trait's operations `clock` and
# `block` because the compiler took `d.now()` and `d.wait(deadline)` for
# calls of evloop's own `now` (which requires the Loop context) and `wait`
# (which yields: a task waiting on a registration) -- the bug
# repro/trait-op-yield-edge/ reduces (EVENT-LOOP-EXPLORATION.md, section 12).
# The prototype keeps the workaround; this tool checks the original names
# directly. It copies src/ into a temporary directory, renames the two
# operations back -- the trait's requirements and every operation call in
# evloop.bot, the deterministic driver's implementations in simdrv.bot,
# each replacement counted -- and requires every deterministic scenario
# (a-*.bot) to compile under -warnings error in both trees, to give one
# outcome on every backend, and to give the same outcome (its whole trace)
# under either name. The native drivers (evn, evsdl, evsdlhost) keep
# `clock` and `block`: their scenarios need C adapters, and the
# deterministic driver exercises the same operations. Exits 1 on any
# difference.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set src [file join $root audit event-loop src]
cd $root
set options [dict create -only * -backends {interp compile cranelift-generic cranelift}]
foreach {k v} $argv {
    if {![dict exists $options $k]} { puts stderr "unknown option $k"; exit 2 }
    dict set options $k $v
}
# tests/helpers.tcl configures tcltest from argv: give it none.
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

set failures 0
proc check {what ok {detail ""}} {
    if {$ok} {
        puts [format "  ok    %s" $what]
    } else {
        incr ::failures
        puts [format "  FAIL  %s %s" $what $detail]
    }
}

proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $text
    close $f
}

# TEXT with every replacement of PAIRS ({OLD NEW COUNT ...}: OLD must occur
# exactly COUNT times) made; FILE names it in a failure.
proc rename {file text pairs} {
    foreach {old new count} $pairs {
        set found 0
        for {set at [string first $old $text]} {$at >= 0} {set at [string first $old $text [expr {$at + 1}]]} {
            incr found
        }
        check "$file: $count occurrence(s) of \"[string trim $old]\" renamed to \"[string trim $new]\"" [expr {$found == $count}] "(found $found)"
        set text [string map [list $old $new] $text]
    }
    return $text
}

set tree [file tempdir evloop-names]
try {
    foreach file [glob -directory $src *.bot] {
        file copy $file $tree
    }
    puts "== the driver operations renamed back (now, wait) in $tree"
    set evloop [file join $tree evloop.bot]
    writeText $evloop [rename evloop.bot [readText $evloop] {
        "    fn clock() -> int\n" "    fn now() -> int\n" 1
        "    fn block(deadline: int) -> int\n" "    fn wait(deadline: int) -> int\n" 1
        "d.clock()" "d.now()" 4
        "d.block(" "d.wait(" 1
    }]
    set simdrv [file join $tree simdrv.bot]
    writeText $simdrv [rename simdrv.bot [readText $simdrv] {
        "\nfn clock(context s: Sim) -> int:" "\nfn now(context s: Sim) -> int:" 1
        "\nfn block(deadline: int, context s: Sim) -> int:" "\nfn wait(deadline: int, context s: Sim) -> int:" 1
    }]
    # The collision the workaround avoided: evloop's own functions of the
    # operations' names stay as they are, visible to every operation call.
    set text [readText $evloop]
    check "evloop.bot declares its own now (requiring Loop) beside the operation" \
        [regexp {\nfn now\(context ev: Loop\) -> int} $text]
    check "evloop.bot declares its own yielding wait beside the operation" \
        [regexp {\nfn wait\(reg: Reg, context ev: Loop\) -> Event} $text]

    puts "== deterministic scenarios (backends: [dict get $options -backends])"
    foreach name [lsort [glob -tails -directory $src a-*.bot]] {
        set name [file rootname $name]
        if {![string match [dict get $options -only] $name]} continue
        set outcomes {}
        foreach dir [list $src $tree] label {workaround original} {
            if {[catch {surface::readProgramFile [file join $dir $name.bot] -warnings error} hir]} {
                check "$name ($label names) compiles under -warnings error" 0 [string range $hir 0 600]
                lappend outcomes ""
                continue
            }
            set each [lsort -unique [lmap b [dict get $options -backends] {lrange [outcomeUnderHir $b $hir] 0 1}]]
            check "$name ($label names): one outcome on [llength [dict get $options -backends]] backends" \
                [expr {[llength $each] == 1 && [lindex $each 0 0] eq "value"}] [string range $each 0 600]
            lappend outcomes [lindex $each 0]
        }
        check "$name: the same outcome (trace) under either name" \
            [expr {[lindex $outcomes 0] ne "" && [lindex $outcomes 0] eq [lindex $outcomes 1]}]
    }
} finally {
    file delete -force $tree
}
puts "[expr {$failures == 0 ? "PASS" : "FAIL ($failures)"}]"
exit [expr {$failures != 0}]
