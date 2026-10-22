# tier.tcl -- the macOS and Windows ports' test tiers, run through the
# repository's own entry points (MACOS-AARCH64-PORT-AUDIT.md, section 16;
# WINDOWS-X86-64-MILESTONE-1.md, section 7).
#
#   tclsh9.0 tests/platform/tier.tcl ?-backends LIST? ?-golden-backends LIST?
#                                    ?-example-backends LIST? ?-gc-stress 0|1?
#                                    ?-shard I/N? ?-list 0|1? ITEM ...
#
# An ITEM is a tier -- smoke, acceptance or all -- or one thing to run: a
# Tcl test file (tests/X.test or X.test), a golden suite (tests/golden/X.bot
# or X.bot), `examples` (main.tcl's sample programs), `cabi`
# (tests/platform/cabi-facts.tcl), `rust` (the native crate's Rust tests),
# `native-stack-mutants` (audit/native-stack/tools/mutate.tcl: the stack
# guard's mutants for this host, each rebuilding a private copy of native/;
# about two minutes a mutant), `native-aot-mutants`
# (audit/native-aot/tools/mutate.tcl: executable emission's mutants, the
# same way), `native-stack-bench` (bench/native-stack-guard.tcl against
# origin's main, built here), `c-ffi-fuzz` (audit/c-ffi/tools/fuzz.tcl: a
# few seeds of the C FFI fuzzer, one under GC stress), `c-ffi-mutants`
# (audit/c-ffi/tools/mutate.tcl: the C FFI's mutants for this host;
# `c-ffi-mutants=NAME,...` only those), `c-ffi-bench` (bench/c-ffi.tcl),
# `c-borrow-fuzz` (audit/c-pointer-borrowing/tools/fuzz.tcl: a few seeds of
# the byte-borrowing fuzzer, one under GC stress), `c-borrow-mutants`
# (audit/c-pointer-borrowing/tools/mutate.tcl: byte borrowing's mutants for
# this host; `c-borrow-mutants=NAME,...` only those), `c-borrow-bench`
# (bench/c-pointer-borrowing.tcl), `darwin-io-mutants`
# (audit/context-traits/tools/mutate.tcl -only 'darwin-*': Darwin I/O's
# mutants, MACOS-AARCH64-MILESTONE-8.md), `darwin-io-bench`
# (bench/darwin-io.tcl) or `c-capture-bench` (bench/c-ffi-error-capture.tcl,
# C-FFI-ERROR-CAPTURE-MILESTONE-1.md); the last twelve are never part of a
# tier.
#
#   smoke       cabi, examples and a dozen front-end test files that never
#               reach the native backend: about 15 seconds
#   acceptance  smoke, every Tcl test file except the ones `notYet` lists
#               below for this host, and every golden suite on
#               -golden-backends (all four: native coroutines run on macOS
#               since milestone 3; on Windows the golden runner excludes the
#               native backends, which run no coroutines there yet): what
#               passes on a macOS arm64 or Windows x86-64 host today
#   all         every Tcl test file and every golden suite (on
#               -golden-backends), and rust: the census, which on macOS
#               fails as notYet says until the port is done
#
# How each kind runs:
#
#   Tcl test files  tests/all.tcl -tmpdir PRIVATE -file "FILES", once per
#                   backend of -backends (CORE_BACKEND; default interp,compile)
#   golden suites   tests/golden/run.tcl -quiet -backends B, B the
#                   -golden-backends (default all four; the golden runner,
#                   lib/test.bot, is a coroutine, which the native backends
#                   run on macOS since milestone 3)
#   examples        main.tcl -backend B on the sample programs CI runs, for
#                   every B of -example-backends (default all four)
#   cabi            tests/platform/cabi-facts.tcl
#   rust            cargo test --release --manifest-path native/Cargo.toml
#   native-stack-mutants  tclsh9.0 audit/native-stack/tools/mutate.tcl
#   native-aot-mutants    tclsh9.0 audit/native-aot/tools/mutate.tcl
#   native-stack-bench    tclsh9.0 bench/native-stack-guard.tcl -baseline-rev main
#   c-ffi-fuzz            tclsh9.0 audit/c-ffi/tools/fuzz.tcl -n 10 -seed S, for
#                         seeds 1 and 2, and -seed 9 -gc-stress 1
#   c-ffi-mutants         tclsh9.0 audit/c-ffi/tools/mutate.tcl ?-only NAMES?
#   c-ffi-bench           tclsh9.0 bench/c-ffi.tcl
#   c-borrow-fuzz         tclsh9.0 audit/c-pointer-borrowing/tools/fuzz.tcl -n 10
#                         -seed S, for seeds 1 and 2, and -seed 9 -gc-stress 1
#   c-borrow-mutants      tclsh9.0 audit/c-pointer-borrowing/tools/mutate.tcl
#                         ?-only NAMES?
#   c-borrow-bench        tclsh9.0 bench/c-pointer-borrowing.tcl
#   darwin-io-mutants     tclsh9.0 audit/context-traits/tools/mutate.tcl -only darwin-*
#   darwin-io-bench       tclsh9.0 bench/darwin-io.tcl
#   c-capture-bench       tclsh9.0 bench/c-ffi-error-capture.tcl -baseline-rev 8c29f7e
#
# -gc-stress 1 runs everything with BOTLISH_NATIVE_GC_STRESS=1. -shard I/N
# (1 <= I <= N) keeps the Ith of every N test files and of every N suites,
# for parallel CI jobs; examples, cabi, rust, native-stack-mutants,
# native-aot-mutants, native-stack-bench, c-capture-bench, the darwin-io-*
# and the c-ffi-* and c-borrow-* checks run in shard 1 only. -list 1
# prints the commands and runs nothing. Each command is printed before it
# runs and streams its output; at the end a summary lists every failure with
# the command that reruns it alone. Exits 1 on any failure. It never uses
# the front-end cache.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
set tclsh [info nameofexecutable]

# Front-end, HIR and Tcl-backend test files that never reach the native
# backend, about a second each on interp.
set smokeFiles {
    blocks.test bindings.test calls.test control.test hir-lowering.test
    hir-samples.test inference.test lists.test loops.test refinements.test
    regex.test results.test surface-samples.test
}

# The Tcl test files that do not pass on a host yet, per host target, with
# the cause and the roadmap milestone it belongs to (macOS:
# MACOS-AARCH64-PORT-AUDIT.md, sections 15 and 17; Windows:
# WINDOWS-X86-64-MILESTONE-1.md, section 8). The acceptance tier is every
# other file. A port milestone that makes one pass removes it here; a new
# test file that fails on a port's host for a capability not ported yet is
# added with its cause. macOS's is empty since milestone 6
# (MACOS-AARCH64-MILESTONE-6.md), which brought c-ffi.test and
# c-bindgen.test, the last two, to macOS. A file a host passes only in part
# is never listed: its tests that need a capability the host lacks carry
# that capability's constraint (tests/helpers.tcl).
source [file join $root core core.tcl]
set notYetByHost [dict create \
    macos-aarch64 {} \
    windows-x86_64 {}]
set notYet [dict getdef $notYetByHost [core::cabi::hostTarget] {}]

proc usage {} {
    puts stderr "usage: tclsh9.0 tests/platform/tier.tcl ?-backends LIST? ?-golden-backends LIST? ?-example-backends LIST? ?-gc-stress 0|1? ?-shard I/N? ?-list 0|1? ITEM ..."
    puts stderr "  ITEM: smoke | acceptance | all | tests/X.test | X.test | tests/golden/X.bot | X.bot | examples | cabi | rust | native-stack-mutants | native-aot-mutants | native-stack-bench | c-ffi-fuzz | c-ffi-mutants?=NAME,...? | c-ffi-bench | c-borrow-fuzz | c-borrow-mutants?=NAME,...? | c-borrow-bench | darwin-io-mutants | darwin-io-bench | c-capture-bench"
    exit 2
}

set options [dict create -backends interp,compile \
    -golden-backends interp,compile,cranelift-generic,cranelift \
    -example-backends interp,compile,cranelift-generic,cranelift \
    -gc-stress 0 -shard 1/1 -list 0]
set items {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {[string match -* $arg]} {
        if {![dict exists $options $arg] || $i + 1 >= [llength $argv]} usage
        dict set options $arg [lindex $argv [incr i]]
    } else {
        lappend items $arg
    }
}
if {$items eq {}} usage
set listOf {apply {{value} {lsearch -all -inline -not -exact [split [string map {" " ,} $value] ,] ""}}}
set backends [{*}$listOf [dict get $options -backends]]
set goldenBackends [{*}$listOf [dict get $options -golden-backends]]
set exampleBackends [{*}$listOf [dict get $options -example-backends]]
set gcStress [dict get $options -gc-stress]
if {$gcStress ni {0 1}} usage
if {![regexp {^(\d+)/(\d+)$} [dict get $options -shard] -> shard shards] || $shard < 1 || $shard > $shards} usage

# ---------------------------------------------------------------------------
# What runs: test files, suites (each with its backends) and checks, in
# order, without duplicates.

set testFiles {}
set suites [dict create]
set checks {}
proc addFile {name} {
    global root testFiles
    set name [file tail $name]
    if {![file isfile [file join $root tests $name]]} {
        puts stderr "no test file tests/$name"
        exit 2
    }
    if {$name ni $testFiles} { lappend testFiles $name }
}
proc addSuite {name backends} {
    global root suites
    set name [file tail $name]
    if {![file isfile [file join $root tests golden $name]]} {
        puts stderr "no golden suite tests/golden/$name"
        exit 2
    }
    if {![dict exists $suites $name]} { dict set suites $name $backends }
}
proc addCheck {name} {
    global checks
    if {$name ni $checks} { lappend checks $name }
}
proc allFiles {} {
    global root
    return [lsort [glob -tails -directory [file join $root tests] *.test]]
}
proc allSuites {} {
    global root
    return [lsort [glob -tails -directory [file join $root tests golden] *.bot]]
}
proc addTier {name} {
    global smokeFiles notYet goldenBackends
    switch -- $name {
        smoke {
            addCheck cabi
            addCheck examples
            foreach f $smokeFiles { addFile $f }
        }
        acceptance {
            addTier smoke
            foreach f [allFiles] {
                if {![dict exists $notYet $f]} { addFile $f }
            }
            foreach s [allSuites] { addSuite $s $goldenBackends }
        }
        all {
            addCheck cabi
            addCheck examples
            addCheck rust
            foreach f [allFiles] { addFile $f }
            foreach s [allSuites] { addSuite $s $goldenBackends }
        }
    }
}
foreach item $items {
    if {$item in {smoke acceptance all}} {
        addTier $item
    } elseif {$item in {examples cabi rust native-stack-mutants native-aot-mutants native-stack-bench c-ffi-fuzz c-ffi-bench c-borrow-fuzz c-borrow-bench darwin-io-mutants darwin-io-bench c-capture-bench}
            || [regexp {^c-(ffi|borrow)-mutants(=[A-Za-z0-9,_-]+)?$} $item]} {
        addCheck $item
    } elseif {[string match *.test $item]} {
        addFile $item
    } elseif {[string match *.bot $item]} {
        addSuite $item $goldenBackends
    } else {
        puts stderr "not a tier, test file, golden suite, examples, cabi, rust, native-stack-mutants, native-aot-mutants, native-stack-bench, c-ffi-fuzz, c-ffi-mutants, c-ffi-bench, c-borrow-fuzz, c-borrow-mutants, c-borrow-bench, darwin-io-mutants, darwin-io-bench or c-capture-bench: $item"
        usage
    }
}

# This shard's share.
proc shardOf {list} {
    global shard shards
    set kept {}
    set i 0
    foreach x $list {
        if {$i % $shards == $shard - 1} { lappend kept $x }
        incr i
    }
    return $kept
}
set testFiles [shardOf $testFiles]
set kept [dict create]
foreach name [shardOf [dict keys $suites]] {
    dict set kept $name [dict get $suites $name]
}
set suites $kept
if {$shard != 1} { set checks {} }

# The sample programs main.tcl runs on BACKEND, as CI's jobs run them
# (.github/workflows/tests.yml): one list per main.tcl run. The Tcl backends
# also run the core IR examples (examples/*.ir) and the module and enum
# samples; the native ones the HIR samples, and cranelift-generic not the
# stdlib programs whose struct shapes only a semantic instance proves.
proc examplePrograms {backend} {
    global root
    set surface [lsort [concat [glob -directory [file join $root examples surface] {0[1-8]*.bot}] \
        [glob -directory [file join $root examples surface] {1[1-3]*.bot}]]]
    set stdlib [lsort [glob -directory [file join $root examples stdlib] *.bot]]
    set hirSamples [lsort [glob -directory [file join $root examples hir] {0[1-3]*.hir}]]
    switch -- $backend {
        interp - compile {
            set more [lsort [glob -directory [file join $root examples surface] {1[45]*.bot}]]
            set coreIr [lsort [glob -directory [file join $root examples] *.ir]]
            return [list $coreIr [concat $surface $more $stdlib]]
        }
        cranelift { return [list [concat $surface $stdlib $hirSamples]] }
        cranelift-generic { return [list [concat $surface $hirSamples]] }
        default { error "no sample programs for backend $backend" }
    }
}

# The commands: {LABEL ENVIRONMENT COMMAND KIND}, KIND tcl, golden or plain.
set commands {}
foreach check $checks {
    switch -- $check {
        cabi {
            lappend commands [list cabi {} [list $tclsh [file join $here cabi-facts.tcl]] plain]
        }
        examples {
            foreach backend $exampleBackends {
                set n 0
                foreach programs [examplePrograms $backend] {
                    lappend commands [list "examples on $backend[expr {[incr n] > 1 ? " ($n)" : ""}]" {} \
                        [list $tclsh [file join $root main.tcl] -backend $backend -warnings off {*}$programs] plain]
                }
            }
        }
        rust {
            lappend commands [list "native Rust tests" {} \
                [list cargo test --release --manifest-path [file join $root native Cargo.toml]] plain]
        }
        native-stack-mutants {
            lappend commands [list "native stack guard mutants" {} \
                [list $tclsh [file join $root audit native-stack tools mutate.tcl]] plain]
        }
        native-aot-mutants {
            lappend commands [list "native executable mutants" {} \
                [list $tclsh [file join $root audit native-aot tools mutate.tcl]] plain]
        }
        native-stack-bench {
            lappend commands [list "native stack guard overhead" {} \
                [list $tclsh [file join $root bench native-stack-guard.tcl] -baseline-rev main] plain]
        }
        c-ffi-fuzz {
            foreach {seed stress} {1 0 2 0 9 1} {
                lappend commands [list "C FFI fuzzer, seed $seed[expr {$stress ? " (GC stress)" : ""}]" {} \
                    [list $tclsh [file join $root audit c-ffi tools fuzz.tcl] -n 10 -seed $seed -gc-stress $stress] plain]
            }
        }
        c-ffi-bench {
            lappend commands [list "C FFI performance" {} [list $tclsh [file join $root bench c-ffi.tcl]] plain]
        }
        c-borrow-fuzz {
            foreach {seed stress} {1 0 2 0 9 1} {
                lappend commands [list "byte-borrowing fuzzer, seed $seed[expr {$stress ? " (GC stress)" : ""}]" {} \
                    [list $tclsh [file join $root audit c-pointer-borrowing tools fuzz.tcl] -n 10 -seed $seed -gc-stress $stress] plain]
            }
        }
        c-borrow-bench {
            lappend commands [list "byte-borrowing performance" {} [list $tclsh [file join $root bench c-pointer-borrowing.tcl]] plain]
        }
        darwin-io-mutants {
            lappend commands [list "Darwin I/O mutants" {} \
                [list $tclsh [file join $root audit context-traits tools mutate.tcl] -only darwin-*] plain]
        }
        darwin-io-bench {
            lappend commands [list "platform I/O performance" {} [list $tclsh [file join $root bench darwin-io.tcl]] plain]
        }
        c-capture-bench {
            # Against the commit before C-FFI-ERROR-CAPTURE-MILESTONE-1, the
            # report's baseline, built on the same runner.
            lappend commands [list "C error capture performance" {} [list $tclsh [file join $root bench c-ffi-error-capture.tcl] -baseline-rev 8c29f7edd13a515b725415190f5d9c07294615c5] plain]
        }
        default {
            if {[regexp {^c-ffi-mutants(?:=(.*))?$} $check -> only]} {
                lappend commands [list "C FFI mutants" {} \
                    [list $tclsh [file join $root audit c-ffi tools mutate.tcl] {*}[expr {$only ne "" ? [list -only $only] : {}}]] plain]
            } elseif {[regexp {^c-borrow-mutants(?:=(.*))?$} $check -> only]} {
                lappend commands [list "byte-borrowing mutants" {} \
                    [list $tclsh [file join $root audit c-pointer-borrowing tools mutate.tcl] {*}[expr {$only ne "" ? [list -only $only] : {}}]] plain]
            }
        }
    }
}
if {$testFiles ne {}} {
    foreach backend $backends {
        lappend commands [list "[llength $testFiles] Tcl test files on $backend" [list CORE_BACKEND $backend] \
            [list $tclsh [file join $root tests all.tcl] -tmpdir @TMPDIR@ -file [join $testFiles " "]] tcl]
    }
}
set byBackends [dict create]
dict for {suite list} $suites {
    dict lappend byBackends [join $list ,] $suite
}
dict for {list names} $byBackends {
    lappend commands [list "[llength $names] golden suites on $list" {} \
        [list $tclsh [file join $root tests golden run.tcl] -quiet -backends $list \
            {*}[lmap s $names {file join $root tests golden $s}]] golden]
}

set environmentAll [expr {$gcStress ? {BOTLISH_NATIVE_GC_STRESS 1} : {}}]
if {[dict get $options -list]} {
    foreach command $commands {
        lassign $command label environment argv
        puts "$label: [join [lmap {k v} [concat $environmentAll $environment] {string cat $k=$v}] " "] [join $argv " "]"
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Running.

unset -nocomplain ::env(BOTLISH_HIR_CACHE)
set failures {}
set started [clock milliseconds]
set scratch [file tempdir botlish-tier]
try {
    set n 0
    foreach command $commands {
        lassign $command label environment argv kind
        set environment [concat $environmentAll $environment]
        set tmpdir [file join $scratch [incr n]]
        file mkdir $tmpdir
        set argv [lmap a $argv {expr {$a eq "@TMPDIR@" ? $tmpdir : $a}}]
        puts "\n######## $label"
        puts "######## [join [lmap {k v} $environment {string cat $k=$v}] " "] [join $argv " "]"
        flush stdout
        set saved [dict create]
        foreach {k v} $environment {
            dict set saved $k [expr {[info exists ::env($k)] ? [list $::env($k)] : {}}]
            set ::env($k) $v
        }
        set output {}
        set start [clock milliseconds]
        set channel [open |[concat $argv [list 2>@1]] r]
        fconfigure $channel -encoding utf-8 -translation auto
        while {[gets $channel line] >= 0} {
            puts $line
            lappend output $line
        }
        set status 0
        if {[catch {close $channel} message options]} {
            set code [dict get $options -errorcode]
            set status [expr {[lindex $code 0] eq "CHILDSTATUS" ? [lindex $code end] : 1}]
        }
        dict for {k v} $saved {
            if {$v eq {}} { unset ::env($k) } else { set ::env($k) [lindex $v 0] }
        }
        set seconds [expr {([clock milliseconds] - $start) / 1000.0}]
        puts [format "######## %s: %s (%.1f s)" $label [expr {$status == 0 ? "ok" : "FAILED, exit status $status"}] $seconds]
        flush stdout
        if {$status == 0} continue
        # The parts to rerun alone: the failing files or suites, else the
        # whole command.
        set prefix [join [lmap {k v} $environment {expr {$k eq "CORE_BACKEND" ? [continue] : "$k=$v "}}] ""]
        set again {}
        if {$kind eq "tcl"} {
            set backend [dict get $environment CORE_BACKEND]
            foreach line $output {
                if {[regexp {^(?:Files with failing tests|Test files exiting with errors):\s*(.*)$} $line -> files]} {
                    foreach f $files {
                        lappend again "${prefix}CORE_BACKEND=$backend tclsh9.0 tests/$f"
                    }
                }
            }
        } elseif {$kind eq "golden"} {
            set list [lindex $argv [expr {[lsearch -exact $argv -backends] + 1}]]
            foreach line $output {
                if {[regexp {^(\S+\.bot)\s+(\S+)\s+(?:\d+ passed, ([1-9]\d*) failed|ABORTED)} $line -> suite backend]
                        || [regexp {^(\S+\.bot): BACKENDS DISAGREE} $line -> suite]
                        || [regexp {^== (\S+\.bot): COMPILE ERROR} $line -> suite]} {
                    set rerun "${prefix}tclsh9.0 tests/golden/run.tcl -backends $list tests/golden/$suite"
                    if {$rerun ni $again} { lappend again $rerun }
                }
            }
        }
        if {$again eq {}} {
            set again [list "[join [lmap {k v} $environment {string cat $k=$v}] " "] [join [lmap a $argv {string map [list $root/ {}] $a}] " "]"]
        }
        lappend failures [list $label $again]
    }
} finally {
    file delete -force $scratch
}

set wall [expr {([clock milliseconds] - $started) / 1000.0}]
puts "\n######## [llength $commands] commands, [llength $failures] failed ([format %.1f $wall] s; [llength $testFiles] Tcl test files on [join $backends ,], [dict size $suites] golden suites, [llength $checks] checks[expr {$gcStress ? ", under GC stress" : ""}])"
foreach failure $failures {
    lassign $failure label again
    puts "FAILED: $label"
    foreach line $again {
        puts "    [string trim $line]"
    }
}
exit [expr {[llength $failures] > 0}]
