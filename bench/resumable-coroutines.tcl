# resumable-coroutines.tcl -- the performance report of
# WASM-RESUMABLE-COROUTINES-SHADOW-ROOTS-MILESTONE-1.md: the resumable
# coroutine mechanism (a `fallback-roots` driver: heap frames, the ShadowOnly
# root plan) against the stackful one (the shipped driver: a stack per
# coroutine, native-frame roots), each with coroutine fusion on and off.
#
#   tclsh9.0 bench/resumable-coroutines.tcl ?-stackful DRIVER? ?-resumable DRIVER?
#                                           ?-runs N? ?-parts LIST?
#
# DRIVER defaults: native/target/release/botlish-native (stackful) and
# native/target-fallback/release/botlish-native (resumable: `cargo build
# --release --features fallback-roots --target-dir native/target-fallback`).
# Each driver says which mechanism it has (`botlish-native capabilities`);
# the report refuses a pair that is not one of each.
#
# Workloads (-parts, default all):
#   generator  one generator resumed 1,000,000 times (tests/resumable/generator.bot)
#   many       10,000 coroutines suspended at once (tests/resumable/many.bot)
#   deep       one coroutine resumed 20,000 times, every yield D yielding
#              activations deep (D = 1, 10, 100, 1000; recursive, so never
#              fused): what a resume costs per level of the chain
#   dfa        a declared recognizer over 1,000,000 symbols (tests/resumable/dfa-tail.bot)
#   churn      100,000 constructions, each released suspended at its
#              handle's last use, under ordinary collections
#   loop       std::event_loop on its deterministic driver: 10,000 mostly
#              idle tasks sleeping five times each, and 100 tasks yielding
#              1,000 times each (bench/event-loop/benchwork.bot)
#
# Per workload and configuration: the best wall time of RUNS in-process runs
# (the driver's `bench`, compilation excluded), and of one `run --alloc
# summary`: allocations in all and of frames (ResumeFrame) and coroutine
# objects, the peak live heap, collections and their time; the process's
# peak resident set (a separate run: Python's resource module), which
# includes every coroutine stack's touched pages and the runtime, so it is
# not the size of the coroutine objects. Then the machine code of each
# workload's yielding functions (`botlish-native size`, fusion off: the
# general mechanism's code), both mechanisms. Times are a shared machine's:
# compare within a run, never against a fixed number.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000

set options [dict create \
    -stackful [file join $root native target release botlish-native] \
    -resumable [file join $root native target-fallback release botlish-native] \
    -runs 3 -parts {generator many deep dfa churn loop}]
foreach {option value} $args {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set runs [dict get $options -runs]
set drivers [dict create stackful [dict get $options -stackful] resumable [dict get $options -resumable]]
dict for {mechanism driver} $drivers {
    set said [exec $driver capabilities]
    if {![regexp -line "^coroutines $mechanism\$" $said]} {
        error "$driver is no $mechanism driver: [string map {\n {, }} $said]"
    }
}

set scratch [file tempdir botlish-resumable-bench]

proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

# Writes the NIR of program TEXT (whose imports resolve beside DIR) to
# SCRATCH/NAME.nir and returns its path.
proc emit {name text dir} {
    global scratch
    set program [file join $scratch $name.bot]
    set f [open $program w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $text
    close $f
    foreach module [glob -nocomplain -directory $dir *.bot] {
        set copy [file join $scratch [file tail $module]]
        if {![file exists $copy]} { file copy $module $copy }
    }
    set hir [surface::readProgramFile $program -warnings off]
    set path [file join $scratch $name.nir]
    set f [open $path w]
    puts -nonewline $f [native::nir $hir]
    close $f
    return $path
}

proc withFusion {on script} {
    set ::env(BOTLISH_NATIVE_COROUTINE_FUSION) $on
    try {
        return [uplevel 1 $script]
    } finally {
        unset ::env(BOTLISH_NATIVE_COROUTINE_FUSION)
    }
}

# One configuration's measurements of NIR.
proc measure {driver nir} {
    global runs
    set lines [split [exec $driver bench $runs $nir] \n]
    set timing [lsearch -inline $lines {timing *}]
    set value [lsearch -inline $lines {value *}]
    set best [lindex $timing 2]
    set report [lrange [lsearch -inline [split [exec $driver run --alloc summary $nir] \n] {alloc *}] 1 end]
    set kind {{report kind key} {
        expr {[dict exists $report byKind $kind $key] ? [dict get $report byKind $kind $key] : 0}
    }}
    set rss [string trim [exec python3 -c {
import resource, subprocess, sys
subprocess.run(sys.argv[1:], stdout=subprocess.DEVNULL, check=True)
print(resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss)
} $driver run $nir]]
    return [dict create value [lrange $value 1 end] best_us $best \
        allocations [dict get $report total allocations] \
        frames [apply $kind $report ResumeFrame allocations] frame_bytes [apply $kind $report ResumeFrame allocatedBytes] \
        coroutines [apply $kind $report Coroutine allocations] \
        peak_live [dict get $report total peakLiveBytes] \
        gc [dict get $report gc cycles] gc_us [dict get $report gc totalTimeUs] rss_kib $rss]
}

proc fmt {n} {
    if {$n eq ""} { return - }
    return [regsub -all {\d(?=(\d{3})+$)} $n {&,}]
}

# Reports workload NAME: its four configurations.
proc report {name nir} {
    global drivers
    puts "\n## $name\n"
    puts "| configuration | best | allocations | frames (bytes) | coroutines | peak live | GCs (time) | maxrss | value |"
    puts "|---|---:|---:|---:|---:|---:|---:|---:|---|"
    set values {}
    foreach mechanism {stackful resumable} {
        foreach fusion {1 0} {
            set m [withFusion $fusion {measure [dict get $drivers $mechanism] $nir}]
            lappend values [dict get $m value]
            set ms [format %.2f [expr {[dict get $m best_us] / 1000.0}]]
            puts "| $mechanism, fusion [expr {$fusion ? "on" : "off"}] | $ms ms | [fmt [dict get $m allocations]] | [fmt [dict get $m frames]] ([fmt [dict get $m frame_bytes]] B) | [fmt [dict get $m coroutines]] | [fmt [dict get $m peak_live]] B | [dict get $m gc] ([format %.1f [expr {[dict get $m gc_us] / 1000.0}]] ms) | [fmt [dict get $m rss_kib]] KiB | [string range [dict get $m value] 0 40] |"
        }
    }
    if {[llength [lsort -unique $values]] != 1} {
        puts "\n**The configurations disagree**: $values"
    }
}

# The machine code of NIR's functions, fusion off, on both mechanisms:
# {TOTAL STACKFUL RESUMABLE} for the functions RESUMABLE's lowering made
# resumable (`botlish-native resumable` names them).
proc codeSize {nir} {
    global drivers
    set lowered [withFusion 0 {exec [dict get $drivers resumable] resumable $nir}]
    set names [lmap line [split $lowered \n] {if {[lindex $line 0] ne "function"} continue; lindex $line 1}]
    set text [readText $nir]
    set ids {}
    foreach line [split $text \n] {
        if {[regexp {^func (\d+) "([^"]*)"} $line -> id fname]} {
            set label [expr {$fname eq "" ? "#$id" : $fname}]
            if {$label in $names} { lappend ids $id }
        }
    }
    set sizes {}
    foreach mechanism {stackful resumable} {
        set per [lindex [withFusion 0 {exec [dict get $drivers $mechanism] size $nir}] 2]
        set sum 0
        foreach id $ids { incr sum [lindex $per $id] }
        lappend sizes $sum
    }
    return [list [llength $ids] {*}$sizes]
}

puts "# Resumable coroutines: performance report"
puts ""
puts "Drivers: stackful [dict get $drivers stackful], resumable [dict get $drivers resumable]; best of $runs runs."

set parts [dict get $options -parts]
set sizes {}
set resumable [file join $root tests resumable]
if {"generator" in $parts} {
    set nir [emit generator [readText [file join $resumable generator.bot]] $resumable]
    report "generator: 1,000,000 resumes of one generator" $nir
    lappend sizes generator [codeSize $nir]
}
if {"many" in $parts} {
    set nir [emit many [readText [file join $resumable many.bot]] $resumable]
    report "many: 10,000 coroutines suspended at once" $nir
    lappend sizes many [codeSize $nir]
}
if {"deep" in $parts} {
    foreach depth {1 10 100 1000} {
        set text "import std::coroutine\n\nfn bottom(n: int) -> int:\n    fold i from 0 to n with intermediate acc 0:\n        yield i\n        acc + i\n\nfn level(d: int, n: int) -> int:\n    if d == 0:\n        return bottom(n)\n    v = level(d - 1, n)\n    v + 1\n\nfn drive(d: int, n: int) -> int:\n    coroutine {step: s, first: f} = level(d, n)\n    fold i from 0 to n with intermediate acc f:\n        acc + s()\n\ndrive($depth, 20000)\n"
        set nir [emit deep-$depth $text $resumable]
        report "deep-$depth: 20,000 resumes, each yield $depth yielding activations deep" $nir
        if {$depth == 10} { lappend sizes deep [codeSize $nir] }
    }
}
if {"dfa" in $parts} {
    set nir [emit dfa [readText [file join $resumable dfa-tail.bot]] $resumable]
    report "dfa: a declared recognizer over 1,000,000 symbols" $nir
    lappend sizes dfa [codeSize $nir]
}
if {"churn" in $parts} {
    set text "import std::coroutine\n\nfn holder(i: int) -> int:\n    xs = \[i, i + 1\]\n    yield i\n    std::list::length(xs)\n\nfn churn(n: int) -> int:\n    fold i from 0 to n with intermediate acc 0:\n        coroutine {first: f} = holder(i)\n        acc + f\n\nchurn(100000)\n"
    set text "import std::list\n$text"
    set nir [emit churn $text $resumable]
    report "churn: 100,000 constructions released suspended" $nir
    lappend sizes churn [codeSize $nir]
}
if {"loop" in $parts} {
    set work [file join $root bench event-loop]
    foreach {name spawn label} {
        sleepers {spawn_sleepers(10000, 5)} "10,000 mostly idle tasks sleeping 5 times each"
        yielders {spawn_yielders(100, 1000)} "100 tasks yielding 1,000 times each"
    } {
        set text "import benchwork\nimport std::event_loop\nimport std::event_loop::deterministic\n\nfn main(context ev: std::event_loop::Loop, d: std::event_loop::deterministic::Deterministic) -> int errors IndexNotFound, std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered:\n    benchwork::$spawn\n    std::event_loop::run()\n\nwith context std::event_loop::create(64)\nwith context std::event_loop::deterministic::create()\nmain():\n    on IndexNotFound:\n        -1\n    on std::event_loop::SchedulerFault:\n        -2\n    on std::event_loop::DriverFault:\n        -3\n    on std::event_loop::LoopReentered:\n        -4\n"
        set nir [emit loop-$name $text $work]
        report "loop-$name: $label (std::event_loop, deterministic driver)" $nir
        lappend sizes loop-$name [codeSize $nir]
    }
}

puts "\n## Machine code of the yielding functions (fusion off)\n"
puts "| workload | functions | stackful | resumable | ratio |"
puts "|---|---:|---:|---:|---:|"
foreach {name size} $sizes {
    lassign $size n a b
    puts "| $name | $n | [fmt $a] B | [fmt $b] B | [expr {$a > 0 ? [format %.2f [expr {double($b) / $a}]] : "-"}] |"
}
file delete -force $scratch
