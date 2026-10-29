# lexical-cleanup.tcl -- the performance report of
# LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md.
#
#   tclsh9.0 bench/lexical-cleanup.tcl ?-runs N? ?-n N? ?-native-n N?
#                                      ?-backends LIST? ?-parts LIST?
#                                      ?-baseline DIR?
#
# Parts (default all):
#   release    a resource released where its binding's scope ends, against
#              the same cleanup called explicitly and against an ordinary
#              struct handed to an ordinary function doing the same work (a
#              counter in a context incremented): what the compiler's
#              release adds over the call a programmer would write;
#   coroutine  a coroutine holding a resource, completed or abandoned at its
#              handle's scope end, against a coroutine holding none in a
#              program without resources (a suspended one's plain release);
#   eventloop  an owned registration made and released by its Owner's scope,
#              against a registration made and revoked explicitly
#              (std::event_loop, the deterministic driver);
#   frontend   with -baseline DIR (a checkout of the tree before this
#              milestone, with its own native build): the front end's time
#              on programs that declare no resource -- surface::readProgramFile,
#              best of N, in each tree's own process -- and the native run
#              time of the same programs.
#
# Per-operation times are (program - baseline program) / n, the whole
# program per operation in parentheses, best of RUNS executions, compilation
# excluded (bench/affine.tcl's method). Times are a shared container's:
# treat them as orders of magnitude.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set n 4000
set nativeN 200000
set backends {interp compile native}
set parts {release coroutine eventloop frontend}
set baseline ""
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        -parts { set parts $value }
        -baseline { set baseline $value }
        default { error "unknown option $option" }
    }
}

set dir [file tempdir botlish-lexical-cleanup-bench]

proc writeFile {path text} {
    set f [open $path w]
    puts -nonewline $f $text
    close $f
}

writeFile [file join $dir res.bot] {import std::mutable_array

opaque resource struct Handle:
    id: int

struct Plain:
    id: int

opaque context struct Counter:
    n: MutableArray[int]

fn create() -> Counter:
    Counter {n: std::mutable_array::create(1, 0)}

fn bump(id: int, context c: Counter):
    v = c.n.at(0):
        on IndexNotFound:
            0
    c.n.set(0, v + id - id + 1):
        on IndexNotFound:
            unit

cleanup fn close(h: Handle, context c: Counter):
    {id} = h
    bump(id)

fn open(n: int) -> Handle:
    Handle {id: n}

fn plain(n: int) -> Plain:
    Plain {id: n}

fn finish(p: Plain, context c: Counter):
    {id} = p
    bump(id)

fn count(context c: Counter) -> int:
    c.n.at(0):
        on IndexNotFound:
            -1
}

# Program KIND with N repetitions, as an application program beside res.bot.
proc program {kind n} {
    set head "import res\nimport std::coroutine\n\nstruct Go:\n    n: int\n\n"
    switch -- $kind {
        scope {
            set body "fn run(context c: res::Counter) -> int:\n    loop i from 0 to $n:\n        h = res::open(i)\n        unit\n    res::count()\n"
        }
        explicit {
            set body "fn run(context c: res::Counter) -> int:\n    loop i from 0 to $n:\n        h = res::open(i)\n        res::close(h)\n    res::count()\n"
        }
        plain-call {
            set body "fn run(context c: res::Counter) -> int:\n    loop i from 0 to $n:\n        p = res::plain(i)\n        res::finish(p)\n    res::count()\n"
        }
        plain-base {
            set body "fn run(context c: res::Counter) -> int:\n    loop i from 0 to $n:\n        p = res::plain(i)\n        unit\n    res::count()\n"
        }
        co-complete {
            set body "fn g(k: int, context c: res::Counter, resume Go) -> int:\n    h = res::open(k)\n    yield 1\n    2\n\n"
            append body "fn run(context c: res::Counter) -> int:\n    loop i from 0 to $n:\n        coroutine \{step\} = g(i)\n        step(Go \{n: 1\})\n    res::count()\n"
        }
        co-abandon {
            set body "fn g(k: int, context c: res::Counter, resume Go) -> int:\n    h = res::open(k)\n    yield 1\n    2\n\n"
            append body "fn run(context c: res::Counter) -> int:\n    loop i from 0 to $n:\n        coroutine \{step\} = g(i)\n        unit\n    res::count()\n"
        }
        co-plain-abandon {
            set body "fn g(k: int, context c: res::Counter, resume Go) -> int:\n    p = res::plain(k)\n    yield 1\n    2\n\n"
            append body "fn run(context c: res::Counter) -> int:\n    loop i from 0 to $n:\n        coroutine \{step\} = g(i)\n        unit\n    res::count()\n"
        }
        el-owned {
            set head "import std::event_loop\nimport std::event_loop::deterministic\nimport type std::event_loop::Delivery\n\n"
            set body "fn run(context ev: std::event_loop::Loop) -> int errors std::event_loop::SchedulerFault:\n    loop i from 0 to $n:\n        \{owner, reg\} = std::event_loop::owned_channel(Delivery::Reliable, 4)\n        unit\n    std::event_loop::stats().registrations\n\n"
            append body "with context std::event_loop::create(8)\nwith context std::event_loop::deterministic::create()\nrun():\n    on std::event_loop::SchedulerFault:\n        -1\n"
            return [Write $kind $head$body]
        }
        el-revoke {
            set head "import std::event_loop\nimport std::event_loop::deterministic\nimport type std::event_loop::Delivery\n\n"
            set body "fn run(context ev: std::event_loop::Loop) -> int errors std::event_loop::SchedulerFault:\n    loop i from 0 to $n:\n        r = std::event_loop::channel(Delivery::Reliable, 4)\n        std::event_loop::revoke(r)\n    std::event_loop::stats().registrations\n\n"
            append body "with context std::event_loop::create(8)\nwith context std::event_loop::deterministic::create()\nrun():\n    on std::event_loop::SchedulerFault:\n        -1\n"
            return [Write $kind $head$body]
        }
    }
    append body "\nwith context res::create()\nrun()\n"
    return [Write $kind $head$body]
}

proc Write {kind text} {
    set path [file join $::dir $kind.bot]
    writeFile $path $text
    return [surface::readProgramFile $path -warnings off]
}

# Best-of-RUNS microseconds of HIR on BACKEND (interp, compile, native).
proc timeOn {backend hir} {
    if {$backend eq "native"} {
        lassign [native::measure $hir $::runs] lower compile best collections value
        return $best
    }
    if {$backend eq "compile"} {
        set unit [core::compiler::compileHir $hir]
        set run {core::compiler::evalUnit $unit}
    } else {
        set program [hir::lower $hir]
        core::useBackend $backend
        set run {core::evalProgram $program}
    }
    eval $run
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time $run] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

proc perOp {kind base backend {scale 1}} {
    set n [expr {($backend eq "native" ? $::nativeN : $::n) / $scale}]
    set t [timeOn $backend [program $kind $n]]
    set b [timeOn $backend [program $base $n]]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.0f ns" $x]
}

proc table {title rows {scale 1}} {
    puts "### $title\n"
    puts "| operation | baseline | [join [lmap b $::backends {bench::backends::displayName $b}] { | }] |"
    puts "|---|---|[string repeat ---:| [llength $::backends]]"
    foreach {label kind base} $rows {
        set cells {}
        foreach backend $::backends {
            lassign [perOp $kind $base $backend $scale] delta whole
            lappend cells "[ns $delta] ([ns $whole])"
        }
        puts "| $label | $base | [join $cells { | }] |"
    }
    puts ""
}

puts "Lexical resource cleanup: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""

try {
    if {"release" in $parts} {
        table "Releasing a resource" {
            "released at its scope's end (the compiler's release)" scope plain-base
            "the cleanup called explicitly" explicit plain-base
            "an ordinary struct to an ordinary function (same work)" plain-call plain-base
        }
    }
    if {"coroutine" in $parts} {
        table "Coroutines holding a resource" {
            "completed (its frame releases the resource)" co-complete co-plain-abandon
            "abandoned at the handle's scope end (unwound)" co-abandon co-plain-abandon
        } 4
    }
    if {"coroutine" in $parts} {
        # What unwinding adds to the code: the NIR of the same coroutine
        # program holding a resource (unwinding: an abandonment edge and a
        # release pad at the suspension) and holding a plain struct.
        puts "### Code size: native program text (NIR lines)\n"
        puts "| program | NIR lines |"
        puts "|---|---:|"
        foreach {label kind} {
            "coroutine holding a resource (the program unwinds)" co-abandon
            "coroutine holding a plain struct (no resources)" co-plain-abandon
            "loop releasing a resource at its scope's end" scope
            "loop handing a plain struct to a function" plain-call
        } {
            puts "| $label | [llength [split [native::nir [program $kind 10]] \n]] |"
        }
        puts ""
    }
    if {"eventloop" in $parts} {
        table "Owned registrations (std::event_loop, deterministic driver)" {
            "owned_channel, released by the Owner's scope" el-owned el-revoke
        } 8
    }
    if {"frontend" in $parts && $baseline ne ""} {
        # Each tree's own process: its front end and its native build.
        set probe [file join $dir frontend.tcl]
        writeFile $probe {
set root [lindex $argv 0]
set runs [lindex $argv 1]
set programs [lrange $argv 2 end]
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000
foreach path $programs {
    surface::readProgramFile $path -warnings off
    set best ""
    for {set i 0} {$i < $runs} {incr i} {
        set us [lindex [time {set hir [surface::readProgramFile $path -warnings off]}] 0]
        if {$best eq "" || $us < $best} { set best $us }
    }
    lassign [native::measure $hir $runs] lower compile run
    # The native program text, hashed: equal in both trees when nothing a
    # program compiles changed.
    set nir [native::nir $hir]
    puts [list $path $best $run "[string length $nir]:[zlib crc32 $nir]"]
}
}
        set programs {}
        foreach p {examples/games/2048/bench.bot bench/fib.bot bench/loop-count.bot tests/event-loop/smoke.bot tests/event-loop/fairness.bot} {
            lappend programs [file join $root $p]
        }
        set rows {}
        foreach tree [list $baseline $root] {
            set out [exec [info nameofexecutable] $probe $tree $runs {*}[lmap p $programs {string map [list $root $tree] $p}]]
            foreach line [split $out \n] {
                lassign $line path front run nir
                dict set rows [file tail [file dirname $path]]/[file tail $path] $tree [list $front $run $nir]
            }
        }
        puts "### Programs without resources: front end and native run, before and after\n"
        puts "| program | front end before | front end after | native run before | native run after | NIR |"
        puts "|---|---:|---:|---:|---:|---|"
        dict for {name byTree} $rows {
            lassign [dict get $byTree $baseline] fb rb nb
            lassign [dict get $byTree $root] fa ra na
            set same [expr {$nb eq $na ? "identical" : "differs"}]
            puts [format "| %s | %.1f ms | %.1f ms | %.3f ms | %.3f ms | %s |" $name [expr {$fb / 1000.0}] [expr {$fa / 1000.0}] [expr {$rb / 1000.0}] [expr {$ra / 1000.0}] $same]
        }
        puts ""
    }
} finally {
    file delete -force $dir
}
