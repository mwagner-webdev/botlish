# bench.tcl -- compares backends on the programs in bench/*.ir.
#
#   tclsh bench/bench.tcl [-runs N] [-markdown] [FILE.ir ...]
#
# Each program runs once untimed per backend (so compilation is excluded
# from the measurement), then N timed runs; the best run is reported.
# Alongside the Botlish backends, a hand-translated Python and Rust program
# from bench/equivalents/{python,rust}/BASE.{py,rs} runs the same way (one
# untimed warmup, then N timed runs, self-reporting its best time) when one
# exists for a given BASE.ir, for a same-container reference comparison.
# -markdown prints a Markdown table (e.g. for a CI job summary).
# Exits with status 1 if the Botlish backends disagree on any program's
# value. The Python/Rust columns are informational and never gate: their
# values are still checked and flagged, but a mismatch there doesn't fail
# the run.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]

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

set backends [core::backends]
set columns [concat $backends {python rust}]
if {$markdown} {
    puts "Tcl [info patchlevel], best of $runs runs, compilation excluded.\n"
    puts "| program | [join $columns { | }] | speedup | 🏅 | values |"
    puts "|---|[string repeat ---:| [llength $columns]]---:|---:|---|"
} else {
    puts [format "%-20s %s %9s %4s" program [join [lmap b $columns {format "%14s" $b}] ""] speedup ""]
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

    set pyResult [runPythonEquivalent $root $base $runs]
    set rustResult [runRustEquivalent $root $base $runs]
    set pyMicros ""; set pyValue ""
    if {$pyResult ne ""} { lassign $pyResult pyMicros pyValue }
    set rustMicros ""; set rustValue ""
    if {$rustResult ne ""} { lassign $rustResult rustMicros rustValue }

    # Only the Botlish backends gate the exit code; python/rust are shown
    # but informational, so an environment quirk in either can't turn a
    # green run red.
    set agree [expr {[llength [lsort -unique $backendValues]] == 1}]
    if {!$agree} {
        incr disagreements
    }
    set allValues [concat $backendValues [list $pyValue $rustValue]]
    set allValues [lsearch -all -inline -not -exact $allValues ""]
    set allAgree [expr {[llength [lsort -unique $allValues]] == 1}]

    # 🫩 while the compiled IR backend is still slower than Python, 🎉 once
    # it beats Python, 🔥 once it beats Rust too.
    set emoji ""
    set compileIdx [lsearch $backends compile]
    if {$compileIdx >= 0 && $pyMicros ne "" && $rustMicros ne ""} {
        set compileMicros [lindex $backendTimes $compileIdx]
        if {$compileMicros < $rustMicros} {
            set emoji "🔥"
        } elseif {$compileMicros < $pyMicros} {
            set emoji "🎉"
        } else {
            set emoji "🫩"
        }
    }

    set speedup [format "%.1fx" [expr {double([lindex $backendTimes 0]) / max(1, [lindex $backendTimes end])}]]
    set allTimes [concat $backendTimes [list $pyMicros $rustMicros]]
    set cells [lmap micros $allTimes {fmtMicros $micros}]
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
