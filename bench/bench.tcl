# bench.tcl -- compares backends on the programs in bench/*.ir.
#
#   tclsh bench/bench.tcl [-runs N] [-markdown] [FILE.ir ...]
#
# Each program runs once untimed per backend (so compilation is excluded
# from the measurement), then N timed runs; the best run is reported.
# Alongside the Botlish backends (interp, compile, and native -- see
# below), a hand-translated Python and Rust program from
# bench/equivalents/{python,rust}/BASE.{py,rs} runs the same way (one
# untimed warmup, then N timed runs, self-reporting its best time) when one
# exists for a given BASE.ir, for a same-container reference comparison.
# -markdown prints a Markdown table (e.g. for a CI job summary).
# Exits with status 1 if the Botlish backends disagree on any program's
# value (native included, whenever it produces one at all -- see below).
# The Python/Rust columns are informational and never gate: their values
# are still checked and flagged, but a mismatch there doesn't fail the run.
#
# Native (Cranelift) column
# --------------------------
# The interp/compile backends run in this same Tcl process, so timing them
# is just "call core::evalProgram N times". Native code does not: each
# call would otherwise be a separate botlish-native subprocess, and timing
# that in a loop would mostly measure process-spawn and re-JIT-compile
# overhead, not the compiled function itself (see NATIVE-AUDIT.md). Instead
# this uses native::measure (native/native.tcl), which spawns exactly one
# subprocess that JIT-compiles once and then loops RUNS times *in that
# process*, so the reported time -- like the interp/compile columns' -- is
# genuine best-of-N execution with compilation excluded.
#
# A program that native code cannot run at all declines the comparison for
# that one row rather than failing the whole benchmark run: a missing
# native capability is a known, separate finding (NATIVE-AUDIT.md), not a
# benchmark regression to gate on. The row still says which of two very
# different reasons that was, rather than a single ambiguous n/a: "unsupported"
# (the native backend is built, but this program itself uses a construct
# native lowering has no implementation for -- a real, reportable blocker)
# versus n/a (the native backend has not been compiled at all this run, so
# nothing about this program's own support was tested).
#
# See bench/backends.tcl for every column's display name and what a timed
# number in it scopes to -- in particular, no column here is ever labeled
# bare "compile": that ambiguity (Tcl's own codegen backend, not Cranelift)
# is exactly what NATIVE-AUDIT.md's Appendix E found had been misread as
# native execution.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
source [file join $root bench backends.tcl]

set runs 5
set markdown 0
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -runs     { set runs [lindex $argv [incr i]] }
        -markdown { set markdown 1 }
        default   { lappend files [lindex $argv $i] }
    }
}
if {$files eq ""} {
    set files [lsort [glob -directory [file join $root bench] *.ir]]
}

# Recursion depth in the benchmarks exceeds Tcl's default nesting limit.
interp recursionlimit {} 20000

# The Tcl-hosted backends: both run core::evalProgram in this process, so
# timing them by calling it in a loop is valid. native/native.tcl's
# sourcing above registers "cranelift"/"cranelift-generic" too (each call
# there is its own subprocess), but those are measured separately by
# bestNative, not through this list or `best`.
set backends {interp compile}

proc best {program runs} {
    core::evalProgram $program
    set best ""
    for {set i 0} {$i < $runs} {incr i} {
        set micros [lindex [time {set value [core::evalProgram $program]}] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return [list $best [core::formatValue $value]]
}

# Best-of-RUNS native (Cranelift) execution of PROGRAM, entirely in one
# subprocess (native::measure), with JIT compile time excluded exactly like
# `best` excludes Tcl compilation for the Tcl backends -- native::measure's
# own COMPILE_US/BEST_US split (see NATIVE-AUDIT.md's Appendix A) keeps
# that separate rather than folding it into the timed region. Returns
# {microseconds value status}: status is "ok", "unsupported" (the native
# backend is built, but PROGRAM itself uses a construct native lowering has
# no implementation for), or "not-built" (native::binary has not been
# compiled this run at all, so PROGRAM's own support was never tested).
# Either failure declines the comparison for this row instead of failing
# the whole run (see this file's header).
proc bestNative {program runs} {
    if {[catch {native::binary}]} {
        return {"" "" not-built}
    }
    if {[catch {native::buildProgramHir $program} hir]} {
        return {"" "" unsupported}
    }
    if {[catch {native::measure $hir $runs} result]} {
        return {"" "" unsupported}
    }
    lassign $result lowerUs compileUs bestUs collections value
    return [list $bestUs [core::formatValue $value] ok]
}

# "n/a" or "unsupported" (see bestNative) for the native column; MICROS'
# ordinary formatting (fmtMicros) otherwise.
proc fmtNative {micros status} {
    if {$status eq "unsupported"} {
        return unsupported
    }
    return [fmtMicros $micros]
}

if {[catch {native::binary}]} {
    puts stderr "Cranelift benchmark unavailable: native driver not built --\
        every Cranelift column will show n/a. Run\
        \"cargo build --release --manifest-path native/Cargo.toml\" first."
}

# Parses the "value: V" / "best_us: N" lines a bench/equivalents/* program
# prints, and returns {microseconds value}.
proc parseEquivalentOutput {output} {
    set value ""
    set micros ""
    foreach line [split $output "\n"] {
        if {[regexp {^value: (.*)$} $line -> v]} { set value $v }
        if {[regexp {^best_us: ([0-9.]+)$} $line -> u]} { set micros $u }
    }
    if {$value eq "" || $micros eq ""} {
        error "equivalent program produced no parseable output:\n$output"
    }
    return [list $micros $value]
}

# Runs bench/equivalents/python/BASE.py the same way `best` runs a Botlish
# backend, and returns {microseconds value}, or "" if there's no such file.
proc runPythonEquivalent {root base runs} {
    set path [file join $root bench equivalents python "$base.py"]
    if {![file exists $path]} { return "" }
    return [parseEquivalentOutput [exec python3 $path --runs $runs]]
}

# Same as runPythonEquivalent, but for bench/equivalents/rust/BASE.rs: the
# source is compiled to a binary cached alongside it, rebuilt whenever the
# source is newer. Compiler warnings are merged into stdout (rather than
# left on stderr) since Tcl's exec otherwise treats any stderr output as
# an error regardless of exit status.
proc runRustEquivalent {root base runs} {
    set src [file join $root bench equivalents rust "$base.rs"]
    if {![file exists $src]} { return "" }
    set bin [file join $root bench equivalents rust $base]
    if {![file exists $bin] || [file mtime $src] > [file mtime $bin]} {
        exec rustc -O $src -o $bin 2>@1
    }
    return [parseEquivalentOutput [exec $bin --runs $runs]]
}

# microseconds -> "N.N ms" above 1ms, "N.NN us" below (backend times run to
# the hundreds of thousands of microseconds; Rust's frequently sub-1us).
proc fmtMicros {micros} {
    if {$micros eq ""} { return "n/a" }
    if {$micros >= 1000} {
        return [format "%.1f ms" [expr {$micros / 1000.0}]]
    }
    return [format "%.2f us" $micros]
}

set columns [concat $backends {native python rust}]
set columnLabels [lmap id $columns {bench::backends::displayName $id}]
if {$markdown} {
    puts "```\n[bench::backends::manifest $columns]\n```\n"
    puts "Tcl [info patchlevel], best of $runs runs, compilation excluded (Cranelift's JIT compile\
        time specifically -- see the manifest above -- not just Tcl's).\n"
    puts "| program | [join $columnLabels { | }] | speedup | 🏅 | values |"
    puts "|---|[string repeat ---:| [llength $columnLabels]]---:|---:|---|"
} else {
    puts "[bench::backends::manifest $columns]\n"
    puts [format "%-20s %s %9s %4s" program [join [lmap b $columnLabels {format "%14s" $b}] ""] speedup ""]
}

set disagreements 0
foreach path $files {
    set program [core::loadProgramFile $path]
    set base [string map {- _} [file rootname [file tail $path]]]

    set backendTimes {}
    set backendValues {}
    foreach backend $backends {
        core::useBackend $backend
        lassign [best $program $runs] micros value
        lappend backendTimes $micros
        lappend backendValues $value
    }

    lassign [bestNative $program $runs] nativeMicros nativeValue nativeStatus

    set pyResult [runPythonEquivalent $root $base $runs]
    set rustResult [runRustEquivalent $root $base $runs]
    set pyMicros ""; set pyValue ""
    if {$pyResult ne ""} { lassign $pyResult pyMicros pyValue }
    set rustMicros ""; set rustValue ""
    if {$rustResult ne ""} { lassign $rustResult rustMicros rustValue }

    # Only the Botlish backends gate the exit code; python/rust are shown
    # but informational, so an environment quirk in either can't turn a
    # green run red. Native joins the gate whenever it produced a value at
    # all (nativeValue ne ""): a program it declines to run natively
    # (bestNative returned "") is absent, not disagreeing, so it never
    # trips this on its own.
    set botlishValues $backendValues
    if {$nativeValue ne ""} { lappend botlishValues $nativeValue }
    set agree [expr {[llength [lsort -unique $botlishValues]] == 1}]
    if {!$agree} {
        incr disagreements
    }
    set allValues [concat $botlishValues [list $pyValue $rustValue]]
    set allValues [lsearch -all -inline -not -exact $allValues ""]
    set allAgree [expr {[llength [lsort -unique $allValues]] == 1}]

    # Native (Cranelift) is the baseline compared against Python/Rust: 🫩
    # while it is still slower than Python, 🎉 once it beats Python, 🔥
    # once it beats Rust too. No verdict (declined, not "🫩") when native
    # couldn't run this program at all, or when there is no Python/Rust
    # reference to compare against.
    set emoji ""
    if {$nativeMicros ne "" && $pyMicros ne "" && $rustMicros ne ""} {
        if {$nativeMicros < $rustMicros} {
            set emoji "🔥"
        } elseif {$nativeMicros < $pyMicros} {
            set emoji "🎉"
        } else {
            set emoji "🫩"
        }
    }

    set speedup [format "%.1fx" [expr {double([lindex $backendTimes 0]) / max(1, [lindex $backendTimes end])}]]
    set cells [concat [lmap micros $backendTimes {fmtMicros $micros}] \
        [list [fmtNative $nativeMicros $nativeStatus]] \
        [lmap micros [list $pyMicros $rustMicros] {fmtMicros $micros}]]
    set shown [string range [join [lsort -unique $allValues] " / "] 0 40]
    if {$markdown} {
        puts "| [file tail $path] | [join $cells { | }] | $speedup | $emoji | [expr {$allAgree ? "✅" : "❌ DIFFER"}] `$shown` |"
    } else {
        puts [format "%-20s %s %9s %4s%s" [file tail $path] \
            [join [lmap c $cells {format "%14s" $c}] ""] $speedup $emoji \
            [expr {$allAgree ? "" : "  VALUES DIFFER: $allValues"}]]
    }
}
exit [expr {$disagreements > 0}]
