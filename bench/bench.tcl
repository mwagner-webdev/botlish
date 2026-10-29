# bench.tcl -- compares backends on the canonical programs in bench/*.bot
# (CANONICAL-SURFACE-BENCHMARKS.md) and the experimental ones in
# bench/experimental/*.bot: every benchmark is ordinary Botlish source,
# compiled through the normal surface frontend (surface::readProgramFile)
# exactly like any other .bot program, never checked-in raw core
# IR/HIR/NIR. The historical bench/*.ir fixtures these programs were
# migrated from remain in bench/ only as frozen inputs for a handful of
# historical audit-reproduction scripts (see that report); they are not
# discovered or run here.
#
#   tclsh9.0 bench/bench.tcl ?-runs N? ?-markdown? ?-budget SECONDS?
#       ?-timeout SECONDS? ?-experimental 0|1|only? ?-columns LIST?
#       ?FILE.bot ...?
#
# The same command runs locally and in CI (.github/workflows/bench.yml),
# on Linux and on Windows; nothing it needs is CI's. A toolchain it does not
# find is a column marked n/a, never a failure.
#
# Columns
# -------
# interp, compile and native (Cranelift) are the Botlish backends; python,
# rust and go are hand-translated reference programs,
# bench/equivalents/{python,rust,go}/BASE.{py,rs,go} (BASE: the program's
# name with "-" as "_"), bench/experimental/equivalents/... for an
# experimental program. -columns LIST runs only those columns (say
# "compile native rust go" to leave out the slow reference interpreter).
#
# Each Botlish program runs once untimed per backend (so compilation is
# excluded from the measurement), then up to N timed runs (-runs, default
# 5); the best run is reported. A backend's runs stop early once the cell
# has used its time budget (-budget, default 60 seconds, warmup included; 0:
# no budget), after at least one timed run: such a cell shows how many of
# the N runs it made, "(2/5)". The interp column is the reference
# interpreter, and some programs take it tens of seconds per run.
#
# The interp and compile backends run in a Tcl process, so timing them is
# "run the program N times" (core::evalProgram of the lowered core IR,
# core::compiler::evalUnit of the HIR's one compilation). Native code does
# not: each call would otherwise be a separate botlish-native subprocess,
# and timing that in a loop would mostly measure process-spawn and
# re-JIT-compile overhead, not the compiled function itself (see
# NATIVE-AUDIT.md). Instead this uses native::measure (native/native.tcl),
# which spawns exactly one subprocess that JIT-compiles once and then loops
# RUNS times *in that process*, so the reported time -- like the Tcl
# columns' -- is genuine best-of-N execution with compilation excluded.
#
# A reference program runs the same way (one untimed warmup, then N timed
# runs in its own process, self-reporting its best time and value as
# "value: V" / "best_us: F" lines). Rust and Go sources are compiled once
# per bench.tcl run into a private temporary directory (rustc -O --edition
# 2021; go build), deleted when it ends.
#
# Isolation: each program's Botlish backends run in a child tclsh (this
# script with -child), one program per child, with a timeout (-timeout,
# default 1800 seconds; the reference programs get the same). A backend
# that crashes or hangs its process is that one cell's error: the child is
# started again for the backends after it, so one failure never hides the
# others or ends the run.
#
# Experimental programs (bench/experimental/) are workloads from recent
# milestones and audits that live beside their own modules elsewhere in the
# repository: a "# bench-modules: PATH ..." line in the program's header
# names them (repository-relative), and the child copies the program and
# those modules into a private temporary directory and compiles it there
# (application modules resolve from the entry file's directory, IMPORTS.md),
# so the modules stay the originals. -experimental 0 leaves them out, only
# runs nothing else.
#
# Cells and the exit status
# -------------------------
# A cell is a time, or says why it is not:
#
#   unsupported  this host cannot run the program on this backend: the
#                native backend is built but the program uses a construct
#                or capability native code has no implementation for here
#                ({NATIVE UNSUPPORTED ...}), or the host has no JIT at all
#   n/a          the column could not be tried: the native driver is not
#                built, or the column's toolchain (python3, rustc, go) is
#                not installed
#   error        it was tried and failed: an error, a crash, a timeout, a
#                build failure, unparseable output
#   --           there is no reference program for this benchmark
#
# Every unsupported, n/a and error cell has a numbered note under the table
# with its reason. The values column compares every value a cell produced
# with the program's "# expect:" header (or, without one, with the first
# Botlish backend's): ✅ when all agree, ❌ with the differing columns
# otherwise.
#
# Exits with status 1 only for a canonical program whose Botlish backends
# produced a wrong value (one that disagrees with the expectation or with
# each other) or whose interp or compile backend -- pure Tcl, supported
# wherever bench.tcl runs -- failed. Unsupported and n/a cells, the native
# column's errors, the reference columns and every experimental program are
# reported and never fail the run, so a host where something cannot run
# still gets the rest of its numbers.
#
# See bench/backends.tcl for every column's display name and what a timed
# number in it scopes to -- in particular, no column here is ever labeled
# bare "compile": that ambiguity (Tcl's own codegen backend, not Cranelift)
# is exactly what NATIVE-AUDIT.md's Appendix E found had been misread as
# native execution.

set benchScript [file normalize [info script]]
set root [file dirname [file dirname $benchScript]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root bench backends.tcl]

set runs 5
set markdown 0
set budget 60
set timeout 1800
set experimental 1
set botlishColumns {interp compile native}
set foreignColumns {python rust go}
set columns [concat $botlishColumns $foreignColumns]
set child ""
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -runs - -budget - -timeout - -experimental - -columns - -child {
            if {$i + 1 >= [llength $argv]} {
                puts stderr "bench.tcl: $arg needs a value"
                exit 2
            }
            set value [lindex $argv [incr i]]
            switch -- $arg {
                -runs { set runs $value }
                -budget { set budget $value }
                -timeout { set timeout $value }
                -experimental { set experimental $value }
                -columns { set columns $value }
                -child { set child $value }
            }
        }
        -markdown { set markdown 1 }
        default {
            if {[string match -* $arg]} {
                puts stderr "bench.tcl: unknown option $arg"
                exit 2
            }
            lappend files $arg
        }
    }
}
foreach column $columns {
    if {$column ni [concat $botlishColumns $foreignColumns]} {
        puts stderr "bench.tcl: unknown column $column (one of [concat $botlishColumns $foreignColumns])"
        exit 2
    }
}
if {$experimental ni {0 1 only}} {
    puts stderr "bench.tcl: -experimental is 0, 1 or only"
    exit 2
}

# Recursion depth in the benchmarks exceeds Tcl's default nesting limit.
core::useProgramRecursionLimit

# ---------------------------------------------------------------------------
# A program's header

# The leading comment lines of the program at PATH, without their "# ".
proc headerLines {path} {
    set lines {}
    foreach line [split [core::ReadFile $path] \n] {
        if {![string match "#*" $line]} {
            break
        }
        lappend lines [string trim [string range $line 1 end]]
    }
    return $lines
}

# The value the program at PATH documents ("# expect: V"), or "".
proc expectedValue {path} {
    foreach line [headerLines $path] {
        if {[regexp {^expect:\s*(.*)$} $line -> value]} {
            return [string trim $value]
        }
    }
    return ""
}

# The repository-relative modules the program at PATH is compiled beside
# ("# bench-modules: PATH ...").
proc benchModules {path} {
    set modules {}
    foreach line [headerLines $path] {
        if {[regexp {^bench-modules:\s*(.*)$} $line -> paths]} {
            lappend modules {*}$paths
        }
    }
    return $modules
}

# VALUE shortened for a table cell.
proc shortValue {value} {
    if {[string length $value] <= 80} {
        return $value
    }
    return "[string range $value 0 76]..."
}

proc firstLine {text} {
    return [string trim [lindex [split [string trim $text] \n] 0]]
}

# ---------------------------------------------------------------------------
# Child mode: one program's Botlish backends, one result line each

# Best-of-RUNS microseconds of the command prefix RUN (after one untimed
# run), stopping once BUDGET seconds have gone by since the untimed run
# started (after at least one timed run). Returns {micros count value}.
proc best {run runs budget} {
    set started [clock microseconds]
    set value [{*}$run]
    set best ""
    set count 0
    while {$count < $runs} {
        if {$count > 0 && $budget > 0 && [clock microseconds] - $started >= $budget * 1000000} {
            break
        }
        set micros [lindex [time {set value [{*}$run]}] 0]
        incr count
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return [list $best $count [core::formatValue $value]]
}

# {status micros count value note} of BACKEND on HIR.
proc measureBackend {backend hir runs budget} {
    switch -- $backend {
        interp {
            core::useBackend interp
            set program [hir::lower $hir]
            return [list ok {*}[best [list core::evalProgram $program] $runs $budget] ""]
        }
        compile {
            set unit [core::compiler::compileHir $hir]
            return [list ok {*}[best [list core::compiler::evalUnit $unit] $runs $budget] ""]
        }
        native {
            # Native::measure runs all RUNS in one subprocess, JIT compile
            # time excluded (its COMPILE_US/BEST_US split, NATIVE-AUDIT.md's
            # Appendix A); the budget does not apply.
            if {![native::hostSupports jit]} {
                return [list unsupported "" 0 "" "no native JIT on [core::cabi::hostTarget]"]
            }
            if {[catch {native::binary} message]} {
                return [list n/a "" 0 "" [firstLine $message]]
            }
            if {[catch {native::measure $hir $runs} result options]} {
                set code [dict get $options -errorcode]
                if {[lrange $code 0 1] eq {NATIVE UNSUPPORTED}} {
                    return [list unsupported "" 0 "" "[lrange $code 0 2]: [firstLine $result]"]
                }
                if {[lrange $code 0 1] eq {NATIVE NOT-BUILT}} {
                    return [list n/a "" 0 "" [firstLine $result]]
                }
                return [list error "" 0 "" "$code: [firstLine $result]"]
            }
            lassign $result lowerUs compileUs bestUs collections value
            return [list ok $bestUs $runs [core::formatValue $value] ""]
        }
    }
    error "unknown backend $backend"
}

proc emit {backend result} {
    puts [list BENCH-RESULT $backend {*}$result]
    flush stdout
}

proc childMain {path backends runs budget} {
    global root
    fconfigure stdout -encoding utf-8 -translation lf
    set entry $path
    set dir ""
    set modules [benchModules $path]
    try {
        if {[llength $modules]} {
            set dir [file tempdir botlish-bench]
            file copy $path [file join $dir [file tail $path]]
            foreach module $modules {
                file copy [file join $root $module] [file join $dir [file tail $module]]
            }
            set entry [file join $dir [file tail $path]]
        }
        if {[catch {surface::readProgramFile $entry -warnings off} hir]} {
            foreach backend $backends {
                emit $backend [list error "" 0 "" "front end: [firstLine $hir]"]
            }
            return
        }
        foreach backend $backends {
            if {[catch {measureBackend $backend $hir $runs $budget} result options]} {
                set result [list error "" 0 "" "[dict get $options -errorcode]: [firstLine $result]"]
            }
            emit $backend $result
        }
    } finally {
        if {$dir ne ""} {
            file delete -force $dir
        }
    }
}

if {$child ne ""} {
    set backends [expr {[llength $files] ? $files : $botlishColumns}]
    childMain $child $backends $runs $budget
    exit 0
}

# ---------------------------------------------------------------------------
# Subprocesses with a timeout

proc PipeReadable {chan} {
    if {[gets $chan line] >= 0} {
        lappend ::pipeOutput($chan) $line
    } elseif {[eof $chan]} {
        set ::pipeDone($chan) eof
    }
}

proc killProcesses {pids} {
    foreach pid $pids {
        if {$::tcl_platform(platform) eq "windows"} {
            catch {exec taskkill /F /T /PID $pid}
        } else {
            catch {exec pkill -KILL -P $pid}
            catch {exec kill -KILL $pid}
        }
    }
}

# Runs the command CMD (a list), its standard error merged into its output,
# for at most SECONDS; returns {OUTCOME OUTPUT}: OUTCOME is "ok", "exit N",
# "killed (DETAILS)" or "timeout".
proc runPipe {cmd seconds} {
    set chan [open |[concat $cmd [list 2>@1]] r]
    fconfigure $chan -blocking 0 -encoding utf-8 -translation auto
    set ::pipeOutput($chan) {}
    set ::pipeDone($chan) ""
    fileevent $chan readable [list PipeReadable $chan]
    set timer [after [expr {int($seconds * 1000)}] [list set ::pipeDone($chan) timeout]]
    vwait ::pipeDone($chan)
    after cancel $timer
    set output [join $::pipeOutput($chan) \n]
    set done $::pipeDone($chan)
    unset ::pipeOutput($chan) ::pipeDone($chan)
    if {$done eq "timeout"} {
        killProcesses [pid $chan]
        catch {close $chan}
        return [list timeout $output]
    }
    fconfigure $chan -blocking 1
    if {[catch {close $chan} message options]} {
        set code [dict get $options -errorcode]
        switch -- [lindex $code 0] {
            CHILDSTATUS { return [list "exit [lindex $code 2]" $output] }
            CHILDKILLED { return [list "killed ([lrange $code 2 end])" $output] }
        }
        return [list "error ([firstLine $message])" $output]
    }
    return [list ok $output]
}

# The last nonempty line of OUTPUT, for a note.
proc lastLine {output} {
    foreach line [lreverse [split $output \n]] {
        if {[string trim $line] ne ""} {
            return [string trim $line]
        }
    }
    return ""
}

# BACKENDS' results for the program at PATH: backend -> {status micros
# count value note}. A child that stops before reporting a backend leaves
# that backend an error, and the child is started again for the rest.
proc runBotlish {path backends} {
    global runs budget timeout benchScript
    set results [dict create]
    set remaining $backends
    while {[llength $remaining]} {
        set cmd [list [info nameofexecutable] $benchScript -child $path -runs $runs -budget $budget {*}$remaining]
        lassign [runPipe $cmd $timeout] outcome output
        foreach line [split $output \n] {
            if {[string match "BENCH-RESULT *" $line] && [string is list $line] && [llength $line] == 7} {
                lassign $line -> backend status micros count value note
                dict set results $backend [list $status $micros $count $value $note]
            }
        }
        set missing {}
        foreach backend $remaining {
            if {![dict exists $results $backend]} {
                lappend missing $backend
            }
        }
        if {![llength $missing]} {
            break
        }
        set culprit [lindex $missing 0]
        set why [expr {$outcome eq "timeout" ? "timed out after $timeout s" : "its process ended: $outcome"}]
        set tail [lastLine $output]
        dict set results $culprit [list error "" 0 "" [expr {$tail eq "" ? $why : "$why; $tail"}]]
        set remaining [lrange $missing 1 end]
    }
    return $results
}

# ---------------------------------------------------------------------------
# Reference programs

# The command prefix of a Python 3 interpreter, or "".
proc findPython {} {
    foreach name {python3 python} {
        set exe [auto_execok $name]
        if {$exe eq ""} {
            continue
        }
        if {![catch {exec {*}$exe --version 2>@1} version] && [string match "Python 3.*" [string trim $version]]} {
            return $exe
        }
    }
    return ""
}

# The command prefix of NAME if it runs with VERSIONARGS, or "".
proc findTool {name versionArgs} {
    set exe [auto_execok $name]
    if {$exe eq "" || [catch {exec {*}$exe {*}$versionArgs 2>@1}]} {
        return ""
    }
    return $exe
}

proc toolVersion {exe versionArgs} {
    if {$exe eq "" || [catch {exec {*}$exe {*}$versionArgs 2>@1} version]} {
        return "not found"
    }
    return [firstLine $version]
}

set python [findPython]
set rustc [findTool rustc --version]
set go [findTool go version]
set toolNames [dict create python "python3 (or python)" rust rustc go go]
set exeSuffix [expr {$::tcl_platform(platform) eq "windows" ? ".exe" : ""}]
set buildDir ""
# The reference programs print UTF-8 whatever the console's code page is.
set env(PYTHONIOENCODING) utf-8
set env(PYTHONUTF8) 1

# Parses the "value: V" / "best_us: N" lines a reference program prints:
# {micros value}, or "" when it printed neither.
proc parseEquivalentOutput {output} {
    set value ""
    set micros ""
    foreach line [split $output \n] {
        if {[regexp {^value: (.*)$} $line -> v]} { set value $v }
        if {[regexp {^best_us: ([0-9.]+)$} $line -> u]} { set micros $u }
    }
    if {$value eq "" || $micros eq ""} {
        return ""
    }
    return [list $micros $value]
}

# {status micros count value note} of the reference program of LANGUAGE in
# DIR (bench/equivalents or bench/experimental/equivalents) for BASE, or ""
# when there is none. TAG keeps the binaries of the two directories apart.
proc runEquivalent {language dir tag base} {
    global python rustc go toolNames exeSuffix buildDir runs timeout
    set extension [dict get {python py rust rs go go} $language]
    set source [file join $dir $language $base.$extension]
    if {![file exists $source]} {
        return ""
    }
    set tool [dict get [list python $python rust $rustc go $go] $language]
    if {$tool eq ""} {
        return [list n/a "" 0 "" "[dict get $toolNames $language] not found"]
    }
    if {$language eq "python"} {
        set cmd [list {*}$python $source --runs $runs]
    } else {
        if {$buildDir eq ""} {
            set buildDir [file tempdir botlish-bench-build]
        }
        set binary [file join $buildDir $tag-$language-$base$exeSuffix]
        set build [expr {$language eq "rust"
            ? [list {*}$rustc -O --edition 2021 $source -o $binary]
            : [list {*}$go build -o $binary $source]}]
        lassign [runPipe $build $timeout] outcome output
        if {$outcome ne "ok" || ![file exists $binary]} {
            return [list error "" 0 "" "build failed ($outcome): [lastLine $output]"]
        }
        set cmd [list $binary --runs $runs]
    }
    lassign [runPipe $cmd $timeout] outcome output
    set parsed [parseEquivalentOutput $output]
    if {$outcome ne "ok" || $parsed eq ""} {
        set why [expr {$outcome eq "timeout" ? "timed out after $timeout s" : $outcome eq "ok" ? "no value/best_us output" : $outcome}]
        set tail [lastLine $output]
        return [list error "" 0 "" [expr {$tail eq "" ? $why : "$why; $tail"}]]
    }
    lassign $parsed micros value
    return [list ok $micros $runs $value ""]
}

# ---------------------------------------------------------------------------
# The report

# microseconds -> "N.N ms" above 1ms, "N.NN us" below (backend times run to
# the hundreds of thousands of microseconds; Rust's frequently sub-1us).
proc fmtMicros {micros} {
    if {$micros eq ""} { return "n/a" }
    if {$micros >= 1000} {
        return [format "%.1f ms" [expr {$micros / 1000.0}]]
    }
    return [format "%.2f us" $micros]
}

set notes {}

# The text of cell RESULT ({status micros count value note}) of PROGRAM's
# COLUMN, numbering its note.
proc cellText {program column result} {
    global notes runs
    if {$result eq ""} {
        return "--"
    }
    lassign $result status micros count value note
    if {$status eq "ok"} {
        set text [fmtMicros $micros]
        if {$count < $runs} {
            append text " ($count/$runs)"
        }
        return $text
    }
    lappend notes [list $program [bench::backends::displayName $column] $status $note]
    return "$status \[[llength $notes]\]"
}

proc discover {} {
    global root files experimental
    if {[llength $files]} {
        return [lmap path $files {file normalize $path}]
    }
    set found {}
    if {$experimental ne "only"} {
        lappend found {*}[lsort [glob -nocomplain -directory [file join $root bench] *.bot]]
    }
    if {$experimental ne "0"} {
        lappend found {*}[lsort [glob -nocomplain -directory [file join $root bench experimental] *.bot]]
    }
    return $found
}

proc experimental? {path} {
    global root
    return [expr {[file dirname [file normalize $path]] eq [file normalize [file join $root bench experimental]]}]
}

set columnLabels [lmap id $columns {bench::backends::displayName $id}]
set nativeShown [expr {"native" in $columns}]
set goShown [expr {"go" in $columns}]

proc tableHeader {title} {
    global markdown columnLabels
    if {$markdown} {
        puts "\n### $title\n"
        puts "| program | [join $columnLabels { | }] | 🏅 | values |"
        puts "|---|[string repeat ---:| [llength $columnLabels]]---:|---|"
    } else {
        puts "\n$title"
        puts [format "%-20s %s %4s  %s" "program" [join [lmap b $columnLabels {format "%16s" $b}] ""] "" values]
    }
}

set hostLine "Host: [core::cabi::hostTarget] ($::tcl_platform(os) $::tcl_platform(osVersion)), Tcl [info patchlevel];\
    reference toolchains: [toolVersion $python --version], [toolVersion $rustc --version], [toolVersion $go version]"
set budgetText [expr {$budget > 0 ? "each Botlish backend's runs stop once its cell has taken $budget s, warmup included (a cell that stopped early shows its runs, \"(1/$runs)\")" : "no time budget"}]
if {$markdown} {
    puts "```\n[bench::backends::manifest $columns]\n```\n"
    puts "$hostLine.\n"
    puts "Best of $runs runs, compilation excluded (Cranelift's JIT compile time specifically -- see the manifest above --\
        not just Tcl's); $budgetText. A cell that is not a time says why: unsupported (this host cannot run it on that\
        backend), n/a (the native driver or the column's toolchain is missing), error (it failed), -- (no reference\
        program); its note is under the tables. 🏅 compares Cranelift with Go: 🎉 faster, 🫩 slower."
} else {
    puts "[bench::backends::manifest $columns]\n"
    puts "$hostLine."
    puts "Best of $runs runs, compilation excluded; $budgetText."
}

if {"native" in $columns && [catch {native::binary}]} {
    puts stderr "Cranelift benchmark unavailable: native driver not built --\
        every Cranelift column will show n/a. Run\
        \"cargo build --release --manifest-path native/Cargo.toml\" first."
}

set failures {}
set counts [dict create ok 0 unsupported 0 n/a 0 error 0]
set currentTable ""
foreach path [discover] {
    set isExperimental [experimental? $path]
    set table [expr {$isExperimental ? "Experimental benchmarks (informational: never fail the run)" : "Benchmarks"}]
    if {$table ne $currentTable} {
        tableHeader $table
        set currentTable $table
    }
    set name [file tail $path]
    set base [string map {- _} [file rootname $name]]
    set equivalents [expr {$isExperimental
        ? [file join $root bench experimental equivalents]
        : [file join $root bench equivalents]}]
    puts stderr "bench: $name"

    set results [dict create]
    set botlish {}
    foreach column $botlishColumns {
        if {$column in $columns} {
            lappend botlish $column
        }
    }
    if {[llength $botlish]} {
        set results [runBotlish $path $botlish]
    }
    foreach column $foreignColumns {
        if {$column in $columns} {
            dict set results $column [runEquivalent $column $equivalents [expr {$isExperimental ? "experimental" : "canonical"}] $base]
        }
    }

    # Values: every cell that produced one against the expectation (or the
    # first Botlish value).
    set expected [expectedValue $path]
    set reference $expected
    set differing {}
    set wrongBotlish 0
    set produced 0
    foreach column $columns {
        set result [dict get $results $column]
        if {$result eq "" || [lindex $result 0] ne "ok"} {
            continue
        }
        set value [lindex $result 3]
        incr produced
        if {$reference eq ""} {
            set reference $value
        }
        if {$value ne $reference} {
            lappend differing "[bench::backends::displayName $column] `[shortValue $value]`"
            if {$column in $botlishColumns} {
                set wrongBotlish 1
            }
        }
    }
    foreach column $columns {
        set result [dict get $results $column]
        if {$result ne ""} {
            dict incr counts [lindex $result 0]
        }
    }
    if {!$isExperimental} {
        if {$wrongBotlish} {
            lappend failures "$name: a Botlish backend's value differs from [expr {$expected ne "" ? "its # expect:" : "the others"}]"
        }
        foreach column {interp compile} {
            if {$column in $columns && [lindex [dict get $results $column] 0] eq "error"} {
                lappend failures "$name: [bench::backends::displayName $column] failed"
            }
        }
    }

    # Cranelift against Go: 🫩 while it is still slower than Go, 🎉 once it
    # beats it. Rust remains informational here; the goal is to beat Go,
    # not Python. No verdict when either did not run.
    set emoji ""
    if {$nativeShown && $goShown} {
        set nativeResult [dict get $results native]
        set goResult [dict get $results go]
        if {[lindex $nativeResult 0] eq "ok" && $goResult ne "" && [lindex $goResult 0] eq "ok"} {
            set emoji [expr {[lindex $nativeResult 1] < [lindex $goResult 1] ? "🎉" : "🫩"}]
        }
    }

    set cells [lmap column $columns {cellText $name $column [dict get $results $column]}]
    set shown [shortValue $reference]
    if {$markdown} {
        set verdict [expr {[llength $differing] ? "❌ expected `$shown`, got [join $differing {, }]"
            : $produced ? "✅ `$shown`" : "-- no value (expected `$shown`)"}]
        puts "| $name | [join $cells { | }] | $emoji | $verdict |"
    } else {
        set verdict [expr {[llength $differing] ? "DIFFER: expected $shown, got [join $differing {, }]"
            : $produced ? "ok $shown" : "no value (expected $shown)"}]
        puts [format "%-20s %s %4s  %s" $name [join [lmap c $cells {format "%16s" $c}] ""] $emoji $verdict]
    }
    flush stdout
}

if {[llength $notes]} {
    puts [expr {$markdown ? "\n### Notes\n" : "\nNotes:"}]
    set i 0
    foreach entry $notes {
        lassign $entry program column status note
        incr i
        puts [expr {$markdown ? "$i. **$program**, $column ($status): $note" : "\[$i\] $program, $column ($status): $note"}]
    }
}

set summary "[dict get $counts ok] timed, [dict get $counts unsupported] unsupported, [dict get $counts n/a] n/a, [dict get $counts error] error cells"
if {[llength $failures]} {
    puts [expr {$markdown ? "\n**FAILED** ($summary):\n" : "\nFAILED ($summary):"}]
    foreach failure $failures {
        puts [expr {$markdown ? "* $failure" : "  $failure"}]
    }
} else {
    puts "\n$summary."
}

if {$buildDir ne ""} {
    file delete -force $buildDir
}
exit [expr {[llength $failures] > 0}]
