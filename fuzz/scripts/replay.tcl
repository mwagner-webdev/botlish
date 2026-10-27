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

# Stdin mode (fuzz/stdin-targets): the input file is the program's stdin,
# not an argv vector. Such programs (read-stdin.bot) print the echoed raw
# bytes and then their value, possibly glued when the echo has no trailing
# newline, so their value is the trailing integer of stdout.
set stdinTargets {}
set stdinList [file join $root fuzz stdin-targets]
if {[file exists $stdinList]} {
    set channel [open $stdinList r]
    foreach line [split [read $channel] \n] {
        if {[string trim $line] ne ""} { lappend stdinTargets [string trim $line] }
    }
    close $channel
}
set stdinMode [expr {$target in $stdinTargets}]
set writeTargets {}
set writeList [file join $root fuzz write-targets]
if {[file exists $writeList]} {
    set channel [open $writeList r]
    foreach line [split [read $channel] \n] {
        if {[string trim $line] ne ""} { lappend writeTargets [string trim $line] }
    }
    close $channel
}
set writeMode [expr {$target in $writeTargets}]
set linesTargets {}
set linesList [file join $root fuzz lines-targets]
if {[file exists $linesList]} {
    set channel [open $linesList r]
    foreach line [split [read $channel] \n] {
        if {[string trim $line] ne ""} { lappend linesTargets [string trim $line] }
    }
    close $channel
}
set linesMode [expr {$target in $linesTargets}]

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
proc run {cmd envExtra {stdinPath ""}} {
    foreach {name value} $envExtra { set ::env($name) $value }
    set outPath [tempPath out]
    set errPath [tempPath err]
    set code 0
    set signal ""
    if {$stdinPath ne ""} {
        if {[catch {exec -- {*}$cmd <$stdinPath >$outPath 2>$errPath} message options]} {
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
    } elseif {[catch {exec -- {*}$cmd >$outPath 2>$errPath} message options]} {
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
    set channel [open $path rb]
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
        # The vector is handed over via a script rather than the command
        # line: a 100 KiB argument hex-doubles past the kernel's 128 KiB
        # per-argument limit (E2BIG), and stdin has no such limit.
        # main.tcl reads the global argv, which the script sets before
        # sourcing it.
        #
        # argv[0] is pinned to the aot executable's path, so the vector is
        # byte-identical to what the harness passes the aot vertical
        # (argv-file uses the binary path as argv[0]). Without this, every
        # index shifts by one between the verticals and input-consuming
        # programs diverge for a harness reason, not a semantic one.
        #
        # Stdin targets: the script goes to a temp FILE and the input file
        # becomes the process's stdin, which the native driver inherits
        # down to the program's read.
        set words [list -backend $vertical]
        lappend words -argv-hex [binary encode hex [file join $build $target]]
        foreach argument $arguments {
            lappend words -argv-hex [binary encode hex $argument]
        }
        lappend words $source
        set script "set argv [list $words]\nsource \[file join {$root} main.tcl\]\n"
        if {$stdinMode && $vertical in {cranelift cranelift-generic}} {
            set scriptPath [tempPath script]
            set channel [open $scriptPath w]
            puts -nonewline $channel $script
            close $channel
            set cmd [list tclsh9.0 $scriptPath]
            set runStdin $input
        } else {
            set cmd [list tclsh9.0 << $script]
            set runStdin ""
        }
        set inProcess 1
    }
    aot - aot-asan {
        set directory [expr {$vertical eq "aot" ? $build : $asanBuild}]
        set binary [file join $directory $target]
        if {![file executable $binary]} {
            puts stderr "replay.tcl: no executable \"$binary\" (built by fuzz/scripts/build-aot.sh / build-asan.sh)"; exit 2
        }
        if {$stdinMode} {
            set cmd [list $binary]
            set runStdin $input
        } else {
            set cmd [list [file join $root fuzz harness argv-file] $binary $input]
            set runStdin ""
        }
        if {$valgrind} { set cmd [list valgrind -q --error-exitcode=88 -- {*}$cmd] }
        if {$vertical eq "aot-asan"} {
            dict set envExtra ASAN_OPTIONS {abort_on_error=1:detect_leaks=0:symbolize=0}
        }
        set inProcess 0
    }
    default { puts stderr $usage; exit 2 }
}

lassign [run $cmd $envExtra $runStdin] code signal stdout stderrText

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
#
# Stdin targets: the AOT executable's own echo (raw input bytes) precedes
# the value on stdout and may glue to it when the echo has no trailing
# newline. The value is recovered by trying every suffix of the trailing
# digit run that satisfies read-stdin's value domain (0..4096 bytes read,
# or a negative raw -errno) and requiring the residual to equal the
# expected echo EXACTLY: the first min(4096, input) bytes of the input
# when n > 0, empty otherwise. Exactly one candidate must fit; none is a
# genuine violation (a finding-class result), more than one is reported
# as ambiguous. The in-process verticals are extracted by the ordinary
# value line below: main.tcl captures and reprints only the driver's
# value, so their stdout never carries the raw echo (a runner property,
# not a divergence -- the echo is verified on the aot side, which has no
# framing).
set result ""
set panic ""
if {$linesMode && $signal eq "" && $vertical in {aot aot-asan interp compile cranelift cranelift-generic}} {
    # Multi-line report target: the whole stdout (minus the in-process
    # runner's framing lines) is the oracle, joined into one normalized
    # string. Error lines are KEPT: a refusal (NATIVE-ONLY) or a runtime
    # error is part of the observable report.
    set kept {}
    foreach line [split $stdout \n] {
        set line [string trimright $line \r]
        if {$line eq ""} continue
        if {$inProcess && [regexp {^(== |   value: |   help: |   type: |   block )} $line]} continue
        lappend kept $line
    }
    # The aot executable's runtime prints the program's value as the last
    # line (always "unit" here); the in-process framing carries it in the
    # stripped "   value:" line. Drop it from the aot side so both sides
    # hold exactly the report.
    if {!$inProcess} { set kept [lrange $kept 0 end-1] }
    set result "report|[join $kept { / }]"
} elseif {$stdinMode && $vertical in {aot aot-asan} && $signal eq ""} {
    set text [string trimright $stdout \n]
    set expectedEcho ""
    if {[string length $bytes] > 0} {
        set expectedEcho [string range $bytes 0 [expr {min(4095, [string length $bytes]-1)}]]
    }
    if {![regexp {(-?[0-9]+)$} $text -> digits]} {
        set result "raw|[string range $text end-100 end]"
    } else {
        set fits {}
        for {set take 1} {$take <= [string length $digits]} {incr take} {
            set n [string range $digits end-[expr {$take - 1}] end]
            if {$take < [string length $digits] && [string index $digits 0] eq "-"} continue
            if {![regexp {^-?[0-9]+$} $n]} continue
            if {$n > 4096} continue
            if {$n < -4095} continue
            set residual [string range $text 0 end-$take]
            set echo ""
            if {$n > 0} { set echo $expectedEcho }
            if {$residual eq $echo} { lappend fits $n }
        }
        if {[llength $fits] == 1} {
            set result "value|[lindex $fits 0]"
        } elseif {[llength $fits] == 0} {
            set result "stdin-violation|stdout does not decompose into echo + value"
        } else {
            set result "stdin-ambiguous|candidates: $fits"
        }
    }
} elseif {$signal ne ""} {
    set result "signal|$signal"
} else {
    foreach line [split $stdout \n] {
        set line [string trimright $line \r]
        if {$inProcess} {
            if {[regexp {^\s+value: (.*)$} $line -> value]} { set result "value|[string trimright $value]" ; continue }
            if {[regexp {^\s+error: .* \((.+)\)\s*$} $line -> errorcode]} { set result "error|$errorcode" ; continue }
        } else {
            if {$writeMode && $vertical in {aot aot-asan}} {
                # stdout-writing target: <text><count> possibly glued; the
                # value is the trailing integer (the byte count).
                set text [string trimright $stdout \n]
                if {[regexp {(-?[0-9]+)$} $text -> n]} {
                    set result "value|$n"
                } else {
                    set result "raw|[string range $text 0 120]"
                }
            } else {
                set value [string trim $line]
                if {$value ne "" && $result eq ""} { set result "value|$value" }
            }
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
