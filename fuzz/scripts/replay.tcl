# replay.tcl -- run one input through one execution vertical, normalized.
#
#   tclsh9.0 fuzz/scripts/replay.tcl VERTICAL TARGET INPUT-FILE ?option?
#
# VERTICAL:
#   aot                the standalone executable (fuzz/build/aot/TARGET),
#                      input bytes -> argv via fuzz/harness/argv-file
#   aot-asan           the ASan-built executable (fuzz/build/aot-asan/), if built
#   interp             tclsh9.0 main.tcl -backend interp
#   compile            tclsh9.0 main.tcl -backend compile
#   cranelift          tclsh9.0 main.tcl -backend cranelift
#   cranelift-generic  tclsh9.0 main.tcl -backend cranelift-generic
#
# Options:
#   --gc-stress   export BOTLISH_NATIVE_GC_STRESS=1 (aot/cranelift* verticals;
#                 the runtime heap reads it, native/src/runtime/heap.rs)
#   --valgrind    wrap an aot run in valgrind (triage vertical; slow)
#   --raw         print everything the vertical printed, with markers
#
# The input file IS an argv vector (NUL-separated; fuzz/harness/argv-file.c
# semantics). The same bytes reach every vertical: as real process argv
# (aot verticals) or via main.tcl -argv-hex, one per argument (in-process
# verticals). argv[0] differs by design -- the real invocation name vs the
# synthetic botlish-runner default -- and is irrelevant: no example reads
# argv (that is the campaign's own finding; FUZZING-EXAMPLES-AOT.md).
#
# Normalized output, one line each, stable for diffing across verticals:
#   result|value|<shown value>          program produced a value
#   result|error|<ERRORCODE>            program failed at the language level
#   result|panic|<first stderr line>    runtime panic or bug marker
#   result|signal|<SIGNAME>             killed by a signal
#   result|valgrind|clean|errors        valgrind vertical verdicts
#   result|raw|<first output line>      none of the above (a suspect)
#   exit|<code>|signal                  process exit status
set root [file normalize [file join [file dirname [info script]] .. ..]]
set usage "usage: tclsh9.0 fuzz/scripts/replay.tcl aot|aot-asan|interp|compile|cranelift|cranelift-generic TARGET INPUT ?--gc-stress|--valgrind|--raw?"

if {$argc < 3} { puts stderr $usage; exit 2 }
lassign $argv vertical target input
set gcStress 0
set valgrind 0
set raw 0
foreach option [lrange $argv 3 end] {
    switch -- $option {
        --gc-stress { set gcStress 1 }
        --valgrind  { set valgrind 1 }
        --raw       { set raw 1 }
        default { puts stderr "replay.tcl: unknown option \"$option\""; exit 2 }
    }
}

set build [file join $root fuzz build aot]
set asanBuild [file join $root fuzz build aot-asan]
proc findSource {directory name} {
    # .ir sources only run on interp/compile (native backends reject core
    # IR by design); the caller chooses the verticals it asks for.
    foreach extension {.bot .hir .ir} {
        set path [file join $directory "$name$extension"]
        if {[file exists $path]} { return $path }
    }
    return ""
}
set source [findSource $build $target]
if {$source eq ""} { puts stderr "replay.tcl: no source for target \"$target\" under $build"; exit 2 }
if {![file exists $input]} { puts stderr "replay.tcl: no input file \"$input\""; exit 2 }

set channel [open $input rb]
set bytes [read $channel]
close $channel

# argv-file.c semantics: NUL-separated segments, one trailing empty segment
# dropped (a lone trailing NUL is a terminator, not an empty argument), an
# empty file is no argument at all.
set arguments {}
if {[string length $bytes] > 0} {
    set segments [split $bytes \0]
    if {[lindex $segments end] eq ""} { set segments [lrange $segments 0 end-1] }
    set arguments $segments
}

# Runs CMD with extra env vars. Returns {code signal stdout stderr} where
# signal is a name like SIGSEGV (empty if none).
# Temp paths are built by hand -- deliberately NOT [file tempfile], which
# on this Tcl returns a per-process channel name like "file5" (a relative
# path!), so two concurrent replays in one working directory would write
# each other's output.
proc tempPath {role} {
    set dir /tmp/opencode
    if {![file writable $dir]} { set dir $::env(TMPDIR) }
    return [file join $dir "replay-[pid]-[clock microseconds]-$role"]
}
proc run {cmd envExtra} {
    foreach {name value} $envExtra { set ::env($name) $value }
    set outPath [tempPath out]
    set errPath [tempPath err]
    set code 0
    set signal ""
    if {[catch {exec -- {*}$cmd >$outPath 2>$errPath} message options]} {
        set errorcode [dict get $options -errorcode]
        lassign $errorcode kind first second
        if {$kind eq "CHILDSTATUS"} {
            set code $second
        } elseif {$kind eq "CHILDKILLED"} {
            set signal $second
            set code 128
        } else {
            set code -1
        }
    }
    set stdout [ReadFile $outPath]
    set stderrText [ReadFile $errPath]
    file delete $outPath $errPath
    return [list $code $signal $stdout $stderrText]
}
proc ReadFile {path} {
    if {![file exists $path]} { return "" }
    set channel [open $path r]
    try { return [read $channel] } finally { close $channel }
}

set envExtra [dict create]
if {$gcStress} { dict set envExtra BOTLISH_NATIVE_GC_STRESS 1 }

switch -- $vertical {
    interp - compile - cranelift - cranelift-generic {
        if {[file extension $source] eq ".ir" && $vertical ni {interp compile}} {
            puts stderr "replay.tcl: $source is core IR text; only interp and compile run it (NATIVE AOT INPUT by design)"
            exit 2
        }
        # The vector is handed over via a stdin script rather than the
        # command line: a 100 KiB argument hex-doubles past the kernel's
        # 128 KiB per-argument limit (E2BIG), and stdin has no such limit.
        # main.tcl reads the global argv, which the script sets before
        # sourcing it.
        set words [list -backend $vertical]
        foreach argument $arguments {
            lappend words -argv-hex [binary encode hex $argument]
        }
        lappend words $source
        set script "set argv [list $words]\nsource \[file join {$root} main.tcl\]\n"
        set cmd [list tclsh9.0 << $script]
        set inProcess 1
    }
    aot - aot-asan {
        set directory [expr {$vertical eq "aot" ? $build : $asanBuild}]
        set binary [file join $directory $target]
        if {![file executable $binary]} {
            puts stderr "replay.tcl: no executable \"$binary\" (built by fuzz/scripts/build-aot.sh / build-asan.sh)"; exit 2
        }
        set cmd [list [file join $root fuzz harness argv-file] $binary $input]
        if {$valgrind} { set cmd [list valgrind -q --error-exitcode=88 -- {*}$cmd] }
        if {$vertical eq "aot-asan"} {
            dict set envExtra ASAN_OPTIONS {abort_on_error=1:detect_leaks=0:symbolize=0}
        }
        set inProcess 0
    }
    default { puts stderr $usage; exit 2 }
}

lassign [run $cmd $envExtra] code signal stdout stderrText

if {$raw} {
    puts "--- exit $code signal $signal"
    puts "--- stdout:"
    puts [string trimright $stdout]
    puts "--- stderr:"
    puts [string trimright $stderrText]
    exit 0
}

# Verdict extraction. Framings:
#   in-process stdout: "   value: V" or "   error: M (CODE)"
#   aot stdout: V (the bare shown value)   aot stderr: "M (CODE)"
# Compile-time warnings (stderr, WARNINGS-SAME-RETURN.md) are ignored by
# design (#54 of the campaign brief): they do not affect behavior.
set result ""
set panic ""
if {$signal ne ""} {
    set result "signal|$signal"
} else {
    foreach line [split $stdout \n] {
        set line [string trimright $line \r]
        if {$inProcess} {
            if {[regexp {^\s+value: (.*)$} $line -> value]} { set result "value|[string trimright $value]" ; continue }
            if {[regexp {^\s+error: .* \((.+)\)\s*$} $line -> errorcode]} { set result "error|$errorcode" ; continue }
        } else {
            set value [string trim $line]
            if {$value ne "" && $result eq ""} { set result "value|$value" }
        }
    }
    foreach line [split $stderrText \n] {
        set line [string trimright $line \r]
        if {[string match "*panicked at*" $line] || [string match "*(NATIVE BUG)*" $line]} {
            set panic $line
            break
        }
        if {$inProcess == 0 && [regexp {^(.*) \(([A-Z][A-Z ]*)\)\s*$} $line -> message errorcode]} {
            set result "error|$errorcode"
            break
        }
    }
}

if {$valgrind} {
    set verdict [expr {$code == 88 ? "errors" : "clean"}]
    # A signal or panic verdict matters more than valgrind's own view.
    if {![string match "signal|*" $result] && ![string match "panic|*" $result]} {
        set result "valgrind|$verdict"
    }
} elseif {$panic ne ""} {
    set result "panic|[string range $panic 0 140]"
} elseif {$result eq ""} {
    set first [lindex [split "$stdout$stderrText" \n] 0]
    set result "raw|[string range $first 0 120]"
}

puts "result|$result"
puts "exit|[expr {$signal ne "" ? "$code ($signal)" : $code}]"
