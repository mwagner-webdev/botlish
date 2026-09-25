# uri-steady.tcl -- baseline harness for bench/uri-steady.bot, the
# steady-state URI/Byte/ASCII benchmark (M0-MODULE-CLOSURE-AND-URI-
# BASELINE.md). Complements refined-checks.ir (structural integration,
# Emailish?-heavy steady state, URI composition at startup only): this
# deliberately isolates web::uri_escape_text/Byte/ASCII steady-state cost.
#
#   tclsh9.0 bench/uri-steady.tcl [-runs N] [-sessions N]
#
# Prints:
#   1. correctness: the four Botlish backends' value, pinned against the
#      fixed corpus (must agree -- see bench/uri-steady.bot's own header)
#   2. timing: best-of-RUNS native (Cranelift) execution, JIT compile
#      excluded, repeated SESSIONS independent times (same technique and
#      the same native::measure this repository's bench.tcl and
#      audit/comprehensive-generated-code/tools/measure.tcl both use) --
#      each session's best, plus the overall median/min/max
#   3. structural baseline: NIR function count, machine code bytes,
#      allocations/bytes (native::allocationReport), generic vs int
#      instance count and guard count read from the NIR text itself

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

interp recursionlimit {} 2000000

set programPath [file join $root bench uri-steady.bot]

proc hirOf {} {
    global programPath
    return [surface::readProgramFile $programPath]
}

# ---------------------------------------------------------------------------
# 1. Correctness: every backend's value, run in a fresh subinterpreter per
# Tcl-hosted backend (this process is otherwise long-lived, and
# core::useBackend is global process state) -- same isolation idiom
# tests/helpers.tcl's outcomeUnder uses (save/restore), simplified here
# since this script has no other backend-sensitive state to preserve.
proc valueUnder {backend} {
    global programPath
    set hir [hirOf]
    set exprs [hir::lower $hir]
    if {$backend in {cranelift cranelift-generic}} {
        set args [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
        return [core::value::show [native::evalHir [native::buildProgramHir $exprs] {*}$args] 1]
    }
    set saved [core::useBackend]
    core::useBackend $backend
    try {
        return [core::value::show [core::evalProgram $exprs] 1]
    } finally {
        core::useBackend $saved
    }
}

puts "Correctness (fixed corpus, spec item 18): abcXYZ012 / a b+c? / café / hello 世界?, 2000 calls"
set values {}
foreach backend {interp compile cranelift-generic cranelift} {
    set v [valueUnder $backend]
    lappend values $v
    puts [format "  %-18s %s" $backend $v]
}
if {[llength [lsort -unique $values]] == 1} {
    puts "  -> all four backends agree: [lindex $values 0]"
} else {
    puts "  -> MISMATCH"
}
puts ""

# ---------------------------------------------------------------------------
# 2. Timing: native::measure (see file header), SESSIONS independent
# subprocess sessions of RUNS timed runs each (one untimed warmup run
# inside native::measure itself, JIT compilation excluded from every timed
# run -- see bench.tcl's own header). Startup/module initialization is
# part of every run equally (not isolated out); it is a fixed, one-time
# per-run cost this steady-state benchmark's own repeat count (2000 calls)
# is chosen to make negligible by comparison (spec item 30 asks it be kept
# *separate*, not included in the timed number: the structural section
# below reports it via the allocation report's own construction-vs-
# steady-state split instead of by excluding it from the clock).
set runs 7
set sessions 5
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -runs     { set runs [lindex $argv [incr i]] }
        -sessions { set sessions [lindex $argv [incr i]] }
    }
}

puts "Timing (native/Cranelift, best of $runs runs, $sessions independent sessions, JIT compile excluded)"
set hir [hirOf]
set bests {}
for {set s 0} {$s < $sessions} {incr s} {
    lassign [native::measure $hir $runs] lowerUs compileUs bestUs collections value
    lappend bests $bestUs
    puts [format "  session %d: best=%.2f us (lower=%.2f us compile=%.2f us collections=%s)" \
        $s $bestUs $lowerUs $compileUs $collections]
}
set sorted [lsort -real $bests]
set median [lindex $sorted [expr {[llength $sorted] / 2}]]
puts [format "  -> median=%.2f us min=%.2f us max=%.2f us spread=%.1f%%" \
    $median [lindex $sorted 0] [lindex $sorted end] \
    [expr {[lindex $sorted end] > 0 ? (([lindex $sorted end] - [lindex $sorted 0]) * 100.0 / [lindex $sorted end]) : 0}]]
puts ""

# ---------------------------------------------------------------------------
# 3. Structural baseline (spec item 27): function count, machine code
# bytes, allocations/bytes, generic vs int instance count and guard count
# (mechanically counted from the NIR text, same technique
# bench/tiny-leaf-pressure.tcl and audit/comprehensive-generated-code/
# tools/census.tcl both use).
set nir [native::nir $hir]
lassign [native::codeSize $hir] totalBytes perFuncBytes
set report [native::allocationReport $hir summary]

set funcCount [regexp -all -line {^func } $nir]
set genericInstances [regexp -all {instance="generic"} $nir]
set intInstances [regexp -all {instance="int"[^"]*"} $nir]
set otherInstances [expr {$funcCount - $genericInstances - $intInstances}]
set guardCount [regexp -all {guard int } $nir]
set callCount [regexp -all {= call(env)? } $nir]
set taggedOps [regexp -all {\mop i(add|sub|mul)\M} $nir]
set setContains [regexp -all {rt_set_contains} $nir]

puts "Structural baseline (spec items 27-28; whole-program, includes module init/startup)"
puts "  NIR functions:        $funcCount"
puts "  machine code bytes:   $totalBytes"
puts "  generic instances:    $genericInstances"
puts "  int/raw instances:    $intInstances"
puts "  other instances:      $otherInstances"
puts "  guard int ops:        $guardCount"
puts "  call/callenv ops:     $callCount"
puts "  tagged i-arith ops:   $taggedOps"
puts "  rt_set_contains refs (NIR text; 0 expected -- ImmutableSet membership lowers to a direct native call, not this literal token): $setContains"
puts "  total allocations:    [dict get $report total allocations]"
puts "  total allocated bytes: [dict get $report total allocatedBytes]"
puts ""
puts "For per-instance (which is_unreserved/ascii instance executes, may_error"
puts "cascade, capture loads per byte) and the module-init-vs-steady-state"
puts "allocation split, see M0-MODULE-CLOSURE-AND-URI-BASELINE.md, gathered with"
puts "audit/comprehensive-generated-code/tools/probe.tcl and census.tcl on this"
puts "same program (non-production inspection tooling this milestone reuses"
puts "rather than duplicating)."
