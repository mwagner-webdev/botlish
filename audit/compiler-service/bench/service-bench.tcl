# service-bench.tcl -- what a compiler service would cost on the existing
# front end (COMPILER-SERVICE-CENSUS.md, "Performance results").
#
#   tclsh9.0 audit/compiler-service/bench/service-bench.tcl \
#       ?-repeat N? ?-workloads NAMES? ?-cli 0|1? ?-native 0|1? ?-out FILE?
#       ?-sections {analysis cache activation query pedia memory}?
#
# Every figure is a distribution over N runs (default 5): min, median, p90
# (the nearest-rank 90th percentile) and max, in milliseconds unless the
# column says otherwise. It measures, separately:
#
#   process   (with -cli 1, the default) fresh processes, as a CLI user or an
#             editor spawning the compiler would pay: tclsh9.0 itself,
#             loading the compiler (what main.tcl sources), `main.tcl -help`
#             (Compilerpedia, no compiler), and per workload `main.tcl
#             -warnings off -emit-hir-interchange FILE` (the front end and
#             nothing else main.tcl can be asked for: there is no check-only
#             mode) without and with a warm front-end cache
#   analysis  in one warm process, per workload, through the census's probe
#             library (lenient analysis, as a service would run it): the
#             first analysis with the loader's parse cache empty and its
#             phases (entry parse, module loading and parsing, the HIR build,
#             the finishing warnings pass), then the same program unchanged,
#             and after an implementation-only edit, an interface edit, a
#             semantic error and a syntax error in one of its files
#   cache     the front-end cache in process: a miss (build and store) and
#             a hit (read, dependency check, decode)
#   activate  switching the registries between two workloads' HIRs, and
#             activating the HIR already active
#   query     the probe library's position query (innermost expression,
#             type, definition, references, diagnostics, Compilerpedia
#             topic) at 200 positions of the entry file, in microseconds
#   pedia     Compilerpedia: the first help-line lookup (the catalogue
#             loaded), later lookups, a search
#   native    (with -native 1) NIR lowering of each workload and its run on
#             cranelift (JIT compile included)
#   memory    the process's resident set as it goes, and each workload's
#             HIR size
#
# Workloads are copied to a private directory first (the front-end
# measurements write nothing beside the repository's files).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root audit compiler-service probes lib.tcl]

set options [dict create -repeat 5 -workloads {arith csv 2048 icy 2048-golden} -cli 1 -native 0 -out "" \
    -sections {analysis cache activation query pedia memory}]
foreach {k v} $argv {
    if {![dict exists $options $k]} { error "service-bench.tcl: unknown option $k" }
    dict set options $k $v
}
set N [dict get $options -repeat]

# Workloads: NAME -> {dir DIR entry FILE edits {KIND {FILE NEEDLE REPLACEMENT} ...}}.
# Each edit replaces the first NEEDLE in FILE (relative to DIR).
set workloads [dict create \
    arith [dict create dir examples/surface entry 01-arithmetic.bot files {01-arithmetic.bot} edits {
        implementation {01-arithmetic.bot {x = 10} {x = 11}}
        semantic-error {01-arithmetic.bot {x = 10} {x = nosuch}}
        syntax-error {01-arithmetic.bot {x = 10} {x = 10 +}}
    }] \
    csv [dict create dir examples/stdlib entry csv.bot files {csv.bot} edits {
        implementation {csv.bot {return ""} {return "" + ""}}
        interface {csv.bot {# The character at index as text} "fn extra_api(n: int) -> int:\n    n\n\n# The character at index as text"}
        semantic-error {csv.bot {return ""} {return nosuch}}
        syntax-error {csv.bot {return ""} {return "" +}}
    }] \
    2048 [dict create dir examples/games/2048 entry demo.bot files {demo.bot demo_play.bot game2048.bot} edits {
        implementation {game2048.bot {scores.get(i, 0) + from(i + 1)} {scores.get(i, 0) + from(i + 1) + 0}}
        interface {game2048.bot {# The sum of SCORES.} "fn extra_api(n: int) -> int:\n    n\n\n# The sum of SCORES."}
        semantic-error {game2048.bot {            return 0} {            return nosuch}}
        syntax-error {game2048.bot {            return 0} {            return 0 +}}
    }] \
    icy [dict create dir examples/games/icy-tower entry headless.bot files {headless.bot hud.bot tower.bot options.bot} edits {
        implementation {tower.bot {floor.mod(25) == 0} {floor.mod(25) == 0 and true}}
        interface {tower.bot {# Every 25th floor spans} "fn extra_api(n: int) -> int:\n    n\n\n# Every 25th floor spans"}
        semantic-error {tower.bot {floor.mod(25) == 0} {floor.mod(25) == nosuch}}
        syntax-error {tower.bot {floor.mod(25) == 0} {floor.mod(25) ==}}
    }] \
    2048-golden [dict create dir examples/games/2048 entry golden.bot files {golden.bot demo_play.bot game2048.bot} edits {
        implementation {game2048.bot {scores.get(i, 0) + from(i + 1)} {scores.get(i, 0) + from(i + 1) + 0}}
        interface {game2048.bot {# The sum of SCORES.} "fn extra_api(n: int) -> int:\n    n\n\n# The sum of SCORES."}
        semantic-error {game2048.bot {            return 0} {            return nosuch}}
        syntax-error {game2048.bot {            return 0} {            return 0 +}}
    }] \
]

# --- statistics -------------------------------------------------------------

proc stats {samples} {
    set s [lsort -real $samples]
    set n [llength $s]
    set p90 [lindex $s [expr {max(0, int(ceil(0.9 * $n)) - 1)}]]
    set median [expr {$n % 2 ? [lindex $s [expr {$n / 2}]] : ([lindex $s [expr {$n / 2 - 1}]] + [lindex $s [expr {$n / 2}]]) / 2.0}]
    return [dict create n $n min [lindex $s 0] median $median p90 $p90 max [lindex $s end]]
}
proc fmt {x} {
    if {$x >= 100} { return [format %.0f $x] }
    if {$x >= 10} { return [format %.1f $x] }
    return [format %.2f $x]
}
proc row {label st} {
    return "| $label | [dict get $st n] | [fmt [dict get $st min]] | [fmt [dict get $st median]] | [fmt [dict get $st p90]] | [fmt [dict get $st max]] |"
}
set header "| measurement | n | min | median | p90 | max |\n|---|---:|---:|---:|---:|---:|"
proc ms {script} {
    set t [clock microseconds]
    uplevel 1 $script
    return [expr {([clock microseconds] - $t) / 1000.0}]
}
proc rss {} {
    set ch [open /proc/self/status]
    set text [read $ch]
    close $ch
    regexp {VmRSS:\s+(\d+)} $text -> kb
    return [expr {$kb / 1024}]
}

set report {}
proc out {line} {
    global report
    puts $line
    flush stdout
    append report $line \n
}

# --- environment ------------------------------------------------------------

proc environment {} {
    global root
    set cpu unknown
    catch {
        set ch [open /proc/cpuinfo]
        regexp {model name\s*:\s*([^\n]+)} [read $ch] -> cpu
        close $ch
    }
    set mem unknown
    catch {
        set ch [open /proc/meminfo]
        regexp {MemTotal:\s+(\d+)} [read $ch] -> kb
        close $ch
        set mem "[expr {$kb / 1048576}] GiB"
    }
    set rev [string trim [exec git -C $root rev-parse --short HEAD]]
    set dirty [expr {[string trim [exec git -C $root status --porcelain --untracked-files=no]] eq "" ? "" : " (modified)"}]
    out "## Environment\n"
    out "- date: [clock format [clock seconds] -format {%Y-%m-%d %H:%M} -gmt 1] UTC"
    out "- source revision: $rev$dirty"
    out "- CPU: $cpu, [exec nproc] processors; memory $mem"
    out "- OS: $::tcl_platform(os) $::tcl_platform(osVersion) $::tcl_platform(machine)"
    out "- Tcl: [info patchlevel] ([info nameofexecutable])"
    catch { out "- rustc: [exec rustc --version]" }
    out "- front end: [hir::interchange::fingerprint]"
    out "- repeat: [dict get $::options -repeat]; workloads: [dict get $::options -workloads]"
    out "- environment: BOTLISH_HIR_CACHE unset unless stated, -warnings off unless stated, static scheduler default (batched)"
    out ""
}

# --- workload copies --------------------------------------------------------

set scratch [file normalize [file tempdir]]
proc copyWorkload {name} {
    global workloads root scratch
    set w [dict get $workloads $name]
    set dst [file join $scratch work $name]
    file mkdir $dst
    foreach f [glob -directory [file join $root [dict get $w dir]] -types f *.bot] {
        file copy -force $f $dst
    }
    return [file join $dst [dict get $w entry]]
}

proc applyEdit {entry edit} {
    lassign $edit rel needle replacement
    set path [file join [file dirname $entry] $rel]
    set text [core::ReadFile $path]
    set i [string first $needle $text]
    if {$i < 0} { error "edit: no \"$needle\" in $rel" }
    return [list $path [string replace $text $i [expr {$i + [string length $needle] - 1}] $replacement]]
}

# --- process-level ----------------------------------------------------------

proc processLevel {} {
    global N root scratch header workloads options
    set tcl [info nameofexecutable]
    set empty [file join $scratch empty.tcl]
    set ch [open $empty w]; puts $ch exit; close $ch
    set init [file join $scratch init.tcl]
    set ch [open $init w]
    puts $ch "source [list [file join $root compiler compiler.tcl]]\nsource [list [file join $root surface surface.tcl]]\nsource [list [file join $root native native.tcl]]\nexit"
    close $ch
    out "## Fresh processes\n"
    out "Wall time of a whole process (fork, exec, Tcl start, the work, exit), ms.\n"
    out $header
    set t {}
    for {set i 0} {$i < $N} {incr i} { lappend t [ms {exec $tcl $empty}] }
    out [row "tclsh9.0, empty script" [stats $t]]
    set t {}
    for {set i 0} {$i < $N} {incr i} { lappend t [ms {exec $tcl $init}] }
    out [row "load the compiler (compiler, surface, native: what main.tcl sources)" [stats $t]]
    set t {}
    for {set i 0} {$i < $N} {incr i} { lappend t [ms {exec $tcl [file join $root main.tcl] -help cli.options >/dev/null}] }
    out [row "main.tcl -help cli.options (Compilerpedia only)" [stats $t]]
    set t {}
    for {set i 0} {$i < $N} {incr i} { lappend t [ms {exec $tcl [file join $root main.tcl] -help {bounds proof} >/dev/null}] }
    out [row "main.tcl -help \"bounds proof\" (a search)" [stats $t]]
    foreach name [dict get $options -workloads] {
        set entry [copyWorkload $name]
        set t {}
        for {set i 0} {$i < $N} {incr i} {
            lappend t [ms {exec $tcl [file join $root main.tcl] -warnings off -emit-hir-interchange $entry >/dev/null}]
        }
        out [row "$name: main.tcl -emit-hir-interchange, no cache" [stats $t]]
        set cache [file join $scratch cli-cache-$name]
        set env(BOTLISH_HIR_CACHE) $cache
        set ::env(BOTLISH_HIR_CACHE) $cache
        exec $tcl [file join $root main.tcl] -warnings off -emit-hir-interchange $entry >/dev/null
        set t {}
        for {set i 0} {$i < $N} {incr i} {
            lappend t [ms {exec $tcl [file join $root main.tcl] -warnings off -emit-hir-interchange $entry >/dev/null}]
        }
        unset ::env(BOTLISH_HIR_CACHE)
        out [row "$name: main.tcl -emit-hir-interchange, warm cache (hit)" [stats $t]]
    }
    out ""
    out "### What a persistent process would save
"
    out "Per workload, N fresh processes (bench/twice.tcl) each load the compiler, then analyze the program three times: the first analysis pays Tcl's bytecode compilation of every compiler procedure it calls and an empty parse cache; the second has both warm; the third empties the parse cache again (bytecode still warm). ms.\n"
    out "| workload | load compiler | 1st analysis | 2nd (warm) | 3rd (parse cache emptied) |\n|---|---:|---:|---:|---:|"
    foreach name [dict get $options -workloads] {
        set entry [copyWorkload $name]
        set rows {}
        for {set i 0} {$i < $N} {incr i} {
            lappend rows [exec $tcl [file join $::here twice.tcl] $entry]
        }
        set cols {}
        foreach k {0 1 2 3} {
            lappend cols [fmt [dict get [stats [lmap r $rows {lindex $r $k}]] median]]
        }
        out "| $name (median of $N) | [join $cols { | }] |"
    }
    out ""
}

# --- in-process -------------------------------------------------------------

# Phase timer: inclusive ms of the wrapped procedures during one script.
set phaseProcs {
    parse-all-files surface::parse
    module-load surface::modules::CollectAndLoad
    module-parse surface::modules::ParseModule
    hir-build hir::buildSyntax
    finish surface::lower::Finish
}
set phaseDepth [dict create]
proc wrapPhases {} {
    global phaseProcs phaseTime
    foreach {phase name} $phaseProcs {
        rename ::$name ::${name}__bench
        # Only the outermost call of a phase is timed: the loader's
        # CollectAndLoad recurses through each module's imports.
        proc ::$name args [string map [list @P@ $phase @N@ $name] {
            if {[dict getdef $::phaseDepth @P@ 0] > 0} {
                return [uplevel 1 [list ::@N@__bench {*}$args]]
            }
            dict set ::phaseDepth @P@ 1
            set __t [clock microseconds]
            try {
                return [uplevel 1 [list ::@N@__bench {*}$args]]
            } finally {
                dict set ::phaseDepth @P@ 0
                dict incr ::phaseTime @P@ [expr {[clock microseconds] - $__t}]
            }
        }]
    }
}

proc analysis {} {
    global workloads options N header results
    out "## Analysis in one warm process\n"
    out "The probe library's lenient analysis (cs::analyze: parse with recovery, load the modules, build the HIR, finish), the process already warm. \"first\" is the workload's first analysis with the loader's parse cache emptied; its phases are inclusive (parse-all-files is every surface::parse call, the entry's and the modules'; module loading includes parsing the modules; the HIR build includes every whole-program build the decisions make). Edits are made in a buffer (an overlay); before each repetition the edited file's cached ASTs are dropped, so its text is new to the loader as each keystroke's is, while the other files' ASTs stay cached.\n"
    out $header
    foreach name [dict get $options -workloads] {
        set entry [copyWorkload $name]
        set ::surface::modules::parsed [dict create]
        set ::phaseTime [dict create]
        set builds [dict get [hir::BuildStats] builds]
        set first [ms {set r [cs::analyze $entry -warnings default]}]
        set builds [expr {[dict get [hir::BuildStats] builds] - $builds}]
        dict set results $name hir [dict get $r hir]
        dict set results $name analysis $r
        dict set results $name entry $entry
        set phases [lmap {phase _} $::phaseProcs {
            string cat $phase " " [fmt [expr {[dict getdef $::phaseTime $phase 0] / 1000.0}]]
        }]
        out [row "$name: first analysis (status [dict get $r status], $builds whole-program builds)" [stats [list $first]]]
        out "| &nbsp;&nbsp;phases: [join $phases {, }] | | | | | |"
        set t {}
        for {set i 0} {$i < $N} {incr i} { lappend t [ms {cs::analyze $entry -warnings default}] }
        out [row "$name: unchanged, again" [stats $t]]
        foreach {kind edit} [dict get $workloads $name edits] {
            set overlay [applyEdit $entry $edit]
            set t {}
            set status ""
            set edited [file normalize [lindex $overlay 0]]
            for {set i 0} {$i < $N} {incr i} {
                # Each repetition is new text to the loader's parse cache, as
                # each keystroke is: drop the edited file's cached ASTs.
                dict for {key _} $::surface::modules::parsed {
                    if {[file normalize [lindex $key 0]] eq $edited} {
                        dict unset ::surface::modules::parsed $key
                    }
                }
                lappend t [ms {set e [cs::analyze $entry -overlay $overlay -warnings default]}]
                set status [dict get $e status]
            }
            out [row "$name: after $kind edit ([file tail [lindex $edit 0]], status $status)" [stats $t]]
        }
    }
    out ""
}

proc cacheBench {} {
    global options N header scratch
    out "## Front-end cache, in process\n"
    out "surface::modules::compileProgramFile with -cache DIR (strict, warnings off): a miss builds and stores the entry; a hit reads it, re-reads and compares every dependency, and decodes the HIR.\n"
    out $header
    foreach name [dict get $options -workloads] {
        set entry [copyWorkload $name]
        set t {}
        set h {}
        for {set i 0} {$i < $N} {incr i} {
            set dir [file join $scratch inproc-cache-$name-$i]
            if {[catch {lappend t [ms {surface::modules::compileProgramFile $entry -cache $dir -warnings off -warning-channel ""}]}]} {
                break
            }
            lappend h [ms {surface::modules::compileProgramFile $entry -cache $dir -warnings off -warning-channel ""}]
        }
        if {$t eq ""} {
            out "| $name: does not compile strictly (not cached) | | | | | |"
            continue
        }
        set size [file size [lindex [glob [file join $dir *.hirc]] 0]]
        out [row "$name: miss (build + store)" [stats $t]]
        out [row "$name: hit (read + check + decode), entry [expr {$size / 1024}] KiB" [stats $h]]
    }
    out ""
}

proc activationBench {} {
    global results options
    out "## Activation (hir::activate)\n"
    set names [dict get $options -workloads]
    out "| pair | switch, µs (median of 200) | already active, µs (median of 200) |\n|---|---:|---:|"
    for {set i 0} {$i + 1 < [llength $names]} {incr i} {
        set a [dict get $results [lindex $names $i] hir]
        set b [dict get $results [lindex $names $i+1] hir]
        if {$a eq "" || $b eq ""} continue
        set switch {}
        set same {}
        for {set k 0} {$k < 100} {incr k} {
            lappend switch [lindex [time {hir::activate $a}] 0]
            lappend same [lindex [time {hir::activate $a}] 0]
            lappend switch [lindex [time {hir::activate $b}] 0]
            lappend same [lindex [time {hir::activate $b}] 0]
        }
        out "| [lindex $names $i] / [lindex $names $i+1] | [fmt [dict get [stats $switch] median]] | [fmt [dict get [stats $same] median]] |"
    }
    out ""
}

proc queryBench {} {
    global results options
    out "## Position queries after analysis\n"
    out "cs::query at 200 evenly spaced positions of the entry file (activation first, as a service must), µs. Each query scans the HIR's expressions linearly (no position index exists).\n"
    out "| workload | expressions | median | p90 | max | positions with an expression |\n|---|---:|---:|---:|---:|---:|"
    foreach name [dict get $options -workloads] {
        set r [dict get $results $name analysis]
        if {[dict get $r hir] eq ""} continue
        set entry [dict get $results $name entry]
        set text [dict get $r texts $entry]
        set lines [split $text \n]
        set positions {}
        for {set k 0} {$k < 200} {incr k} {
            set l [expr {1 + ($k * 7919) % [llength $lines]}]
            set len [string length [lindex $lines $l-1]]
            set c [expr {1 + ($len ? ($k * 31) % $len : 0)}]
            lappend positions $l $c
        }
        hir::activate [dict get $r hir]
        set t {}
        set hits 0
        foreach {l c} $positions {
            lappend t [lindex [time {set q [cs::query $r $entry $l $c]}] 0]
            if {[dict exists $q expr]} { incr hits }
        }
        set st [stats $t]
        out "| $name | [dict size [dict get $r hir exprs]] | [fmt [dict get $st median]] | [fmt [dict get $st p90]] | [fmt [dict get $st max]] | $hits |"
    }
    out ""
}

proc pediaBench {} {
    global root
    out "## Compilerpedia, in process\n"
    out "| measurement | ms |\n|---|---:|"
    compilerpedia::reset
    set first [ms {compilerpedia::topicForDiagnostic {CORE SEMANTIC TYPE} {argument for parameter "a" cannot be proven to satisfy int}}]
    out "| first help-line lookup (topicForDiagnostic: header scan of the catalogue) | [fmt $first] |"
    set t [lindex [time {compilerpedia::topicForDiagnostic {CORE SEMANTIC UNBOUND} {unbound name "x"}} 1000] 0]
    out "| later help-line lookup (mean of 1000) | [fmt [expr {$t / 1000.0}]] |"
    set first [ms {compilerpedia::lookup {bounds proof}}]
    out "| first search (\"bounds proof\": loads and parses every topic) | [fmt $first] |"
    set t [lindex [time {compilerpedia::lookup {unbound name}} 20] 0]
    out "| later search (mean of 20) | [fmt [expr {$t / 1000.0}]] |"
    out ""
}

proc nativeBench {} {
    global results options N
    uplevel #0 [list source [file join $::root native native.tcl]]
    out "## Native code generation\n"
    out "| measurement | n | min | median | p90 | max |\n|---|---:|---:|---:|---:|---:|"
    foreach name [dict get $options -workloads] {
        set hir [dict get $results $name hir]
        if {$hir eq "" || [dict get $results $name analysis status] ne "ok"} continue
        set t {}
        for {set i 0} {$i < $N} {incr i} { lappend t [ms {native::nir $hir}] }
        out [row "$name: NIR lowering (native::nir, Tcl)" [stats $t]]
        set t {}
        for {set i 0} {$i < $N} {incr i} {
            lappend t [ms {catch {native::evalHir $hir}}]
        }
        out [row "$name: native::evalHir (lower, JIT in botlish-native, run)" [stats $t]]
    }
    out ""
}

proc memory {} {
    global results options
    out "## Memory\n"
    out "| workload | HIR dict, KiB of text | interchange encoding, KiB |\n|---|---:|---:|"
    foreach name [dict get $options -workloads] {
        set hir [dict get $results $name hir]
        if {$hir eq ""} continue
        out "| $name | [expr {[string length $hir] / 1024}] | [expr {[string length [hir::interchange::encode $hir]] / 1024}] |"
    }
    out "\nResident set of this process after everything above: [rss] MiB.\n"
}

# --- main -------------------------------------------------------------------

cs::load $root
interp recursionlimit {} 200000
set results [dict create]
out "# Compiler service benchmark\n"
environment
if {[dict get $options -cli]} {
    processLevel
}
out "Resident set after loading the compiler in process: [rss] MiB.\n"
wrapPhases
set sections [dict get $options -sections]
# The later sections read the analyses' results.
analysis
if {"cache" in $sections} { cacheBench }
if {"activation" in $sections} { activationBench }
if {"query" in $sections} { queryBench }
if {"pedia" in $sections} { pediaBench }
if {[dict get $options -native]} {
    nativeBench
}
if {"memory" in $sections} { memory }
if {[dict get $options -out] ne ""} {
    set ch [open [dict get $options -out] w]
    puts -nonewline $ch $report
    close $ch
}
file delete -force $scratch
