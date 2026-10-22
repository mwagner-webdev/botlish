# compiler-service.tcl -- the performance report of the compiler service
# (COMPILER-SERVICE-MILESTONE-1.md, "Performance"), measured through the
# service's own interface (service/service.tcl) and set beside the census's
# figures for the same workloads (COMPILER-SERVICE-CENSUS.md, section 7,
# measured on the front end before the service existed).
#
#   tclsh9.0 bench/compiler-service.tcl ?-repeat N? ?-workloads NAMES?
#       ?-queries N? ?-rounds N? ?-sections LIST? ?-out FILE?
#
# Sections (-sections, all by default):
#
#   analysis  per workload, in one warm process: the first analysis (the
#             loader's parse cache empty), the unchanged program again, and
#             the census's four edits -- an implementation edit, an interface
#             edit, a semantic error, a syntax error -- each applied as an
#             unsaved buffer (service::setDocument: nothing is copied or
#             written), the edited file's cached AST dropped first so its
#             text is new to the loader, as the census did. Median of N.
#   query     per workload: building a revision's query indexes
#             (service::prepare), then service::at at the census's 200
#             positions of the entry file (its formula) and at -queries more
#             random positions of the entry and its modules: median, p90,
#             p99 and max, in microseconds. Compilerpedia's catalogue is
#             loaded before (its one-time cost is its own row).
#   memory    the 2048 demo analyzed -rounds times in one process, each
#             round a different unsaved edit of game2048.bot, queried, the
#             previous revision released: the resident set and what the
#             service holds every 10 rounds; then 10 revisions retained at
#             once and released.
#   cli       fresh processes: `main.tcl -check -warnings off FILE`, with no
#             front-end cache and with a warm one, beside the census's
#             nearest command (-emit-hir-interchange: there was no -check).
#
# Every in-process figure is wall-clock time on an otherwise idle machine;
# run nothing else meanwhile. -out FILE also writes the report there.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root service service.tcl]

set options [dict create -repeat 5 -workloads {arith csv 2048 icy 2048-golden} -queries 1000 \
    -rounds 60 -sections {analysis query memory cli} -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "compiler-service.tcl: unknown option $option (known: [join [dict keys $options] {, }])"
    }
    dict set options $option $value
}
set N [dict get $options -repeat]
unset -nocomplain ::env(BOTLISH_HIR_CACHE)
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8

# Workloads: NAME -> {dir DIR entry FILE edits {KIND {FILE NEEDLE REPLACEMENT} ...}}
# -- the census's (audit/compiler-service/bench/service-bench.tcl).
set workloads [dict create \
    arith [dict create dir examples/surface entry 01-arithmetic.bot edits {
        implementation {01-arithmetic.bot {x = 10} {x = 11}}
        semantic-error {01-arithmetic.bot {x = 10} {x = nosuch}}
        syntax-error {01-arithmetic.bot {x = 10} {x = 10 +}}
    }] \
    csv [dict create dir examples/stdlib entry csv.bot edits {
        implementation {csv.bot {return ""} {return "" + ""}}
        interface {csv.bot {# The character at index as text} "fn extra_api(n: int) -> int:\n    n\n\n# The character at index as text"}
        semantic-error {csv.bot {return ""} {return nosuch}}
        syntax-error {csv.bot {return ""} {return "" +}}
    }] \
    2048 [dict create dir examples/games/2048 entry demo.bot edits {
        implementation {game2048.bot {scores.get(i, 0) + from(i + 1)} {scores.get(i, 0) + from(i + 1) + 0}}
        interface {game2048.bot {# The sum of SCORES.} "fn extra_api(n: int) -> int:\n    n\n\n# The sum of SCORES."}
        semantic-error {game2048.bot {            return 0} {            return nosuch}}
        syntax-error {game2048.bot {            return 0} {            return 0 +}}
    }] \
    icy [dict create dir examples/games/icy-tower entry headless.bot edits {
        implementation {tower.bot {floor.mod(25) == 0} {floor.mod(25) == 0 and true}}
        interface {tower.bot {# Every 25th floor spans} "fn extra_api(n: int) -> int:\n    n\n\n# Every 25th floor spans"}
        semantic-error {tower.bot {floor.mod(25) == 0} {floor.mod(25) == nosuch}}
        syntax-error {tower.bot {floor.mod(25) == 0} {floor.mod(25) ==}}
    }] \
    2048-golden [dict create dir examples/games/2048 entry golden.bot edits {
        implementation {game2048.bot {scores.get(i, 0) + from(i + 1)} {scores.get(i, 0) + from(i + 1) + 0}}
        interface {game2048.bot {# The sum of SCORES.} "fn extra_api(n: int) -> int:\n    n\n\n# The sum of SCORES."}
        semantic-error {game2048.bot {            return 0} {            return nosuch}}
        syntax-error {game2048.bot {            return 0} {            return 0 +}}
    }] \
]

# The census's medians (COMPILER-SERVICE-CENSUS.md, sections 7.1, 7.2, 7.5),
# for the comparison columns.
set census [dict create \
    analysis [dict create \
        arith       {first 42 unchanged 4.5 implementation 5.2 interface - semantic-error 4.4 syntax-error 1.3} \
        csv         {first 208 unchanged 208 implementation 165 interface 169 semantic-error 171 syntax-error 31} \
        2048        {first 1276 unchanged 1250 implementation 1233 interface 1287 semantic-error 847 syntax-error 99} \
        icy         {first 1006 unchanged 785 implementation 1006 interface 1014 semantic-error 904 syntax-error 172} \
        2048-golden {first 6223 unchanged 6994 implementation 7441 interface 7870 semantic-error 4793 syntax-error 644}] \
    query [dict create \
        arith {27 58 926} csv {664 988 3798} 2048 {1209 1851 15967} icy {1214 2197 13523} 2048-golden {7188 11062 54474}] \
    cli [dict create \
        arith {127 99} csv {337 92} 2048 {1486 142} icy {1069 266} 2048-golden {5998 198}]]

# --- statistics (the census harness's) --------------------------------------

proc stats {samples} {
    set s [lsort -real $samples]
    set n [llength $s]
    set p90 [lindex $s [expr {max(0, int(ceil(0.9 * $n)) - 1)}]]
    set p99 [lindex $s [expr {max(0, int(ceil(0.99 * $n)) - 1)}]]
    set median [expr {$n % 2 ? [lindex $s [expr {$n / 2}]] : ([lindex $s [expr {$n / 2 - 1}]] + [lindex $s [expr {$n / 2}]]) / 2.0}]
    return [dict create n $n min [lindex $s 0] median $median p90 $p90 p99 $p99 max [lindex $s end]]
}
proc fmt {x} {
    if {![string is double -strict $x]} { return $x }
    if {$x >= 100} { return [format %.0f $x] }
    if {$x >= 10} { return [format %.1f $x] }
    return [format %.2f $x]
}
proc ms {script} {
    set t [clock microseconds]
    uplevel 1 $script
    return [expr {([clock microseconds] - $t) / 1000.0}]
}
proc rss {} {
    if {[catch {open /proc/self/status} channel]} {
        return ?
    }
    set text [read $channel]
    close $channel
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

proc environment {} {
    global root
    out "# Compiler service: performance\n"
    out "Generated by `tclsh9.0 bench/compiler-service.tcl` (COMPILER-SERVICE-MILESTONE-1.md, \"Performance\"); census figures from COMPILER-SERVICE-CENSUS.md, section 7.\n"
    set revision unknown
    catch {set revision [exec git -C $root rev-parse --short HEAD]}
    set cpu ?
    catch {
        set channel [open /proc/cpuinfo]
        regexp {model name\s*:\s*([^\n]+)} [read $channel] -> cpu
        close $channel
    }
    set cores ?
    catch {set cores [exec nproc]}
    # A revision records the front end's fingerprint, which a process
    # computes once (hashing core/, hir/, surface/): computed here, before any
    # measurement, as the census's probe never computed it.
    set fingerprint [ms {hir::interchange::fingerprint}]
    out "- revision `$revision`; Tcl [info patchlevel]; $::tcl_platform(os) $::tcl_platform(machine); $cores x $cpu"
    out "- the front-end fingerprint (once per process, before the measurements): [fmt $fingerprint] ms"
    out "- repeat [dict get $::options -repeat]; workloads [dict get $::options -workloads]; median of the repeats unless a column says otherwise; milliseconds unless it says µs\n"
}

# The text of WORKLOAD's FILE with EDIT applied (its first NEEDLE replaced).
proc edited {workload edit} {
    global root
    lassign $edit file needle replacement
    set path [file join $root [dict get $workload dir] $file]
    set text [surface::source::text $path]
    set at [string first $needle $text]
    if {$at < 0} {
        error "edit of $file: no \"$needle\""
    }
    return [list $path [string replace $text $at [expr {$at + [string length $needle] - 1}] $replacement]]
}

# Drops the loader's cached ASTs of PATH (any text of it).
proc forget {path} {
    foreach key [dict keys $::surface::modules::parsed] {
        if {[lindex $key 0] eq $path} {
            dict unset ::surface::modules::parsed $key
        }
    }
}

# --- analysis ---------------------------------------------------------------

proc analysis {} {
    global workloads options N root census
    out "## Analysis in a warm process\n"
    out "service::analyze, no front-end cache, warnings off. Each edit is an unsaved buffer of the file it edits. In parentheses: the census's median for the same workload and edit (its probe library's lenient analysis, before the service).\n"
    out "| workload | first | unchanged | implementation edit | interface edit | semantic error | syntax error |\n|---|---:|---:|---:|---:|---:|---:|"
    foreach name [dict get $options -workloads] {
        set w [dict get $workloads $name]
        set entry [file join $root [dict get $w dir] [dict get $w entry]]
        set ws [service::workspace -warnings off -cache ""]
        set ::surface::modules::parsed [dict create]
        set first [ms {set rev [service::analyze $ws $entry]}]
        service::release $rev
        set row [list "[fmt $first] ([dict get $census analysis $name first])"]
        set samples {}
        for {set i 0} {$i < $N} {incr i} {
            lappend samples [ms {set rev [service::analyze $ws $entry]}]
            service::release $rev
        }
        lappend row "[fmt [dict get [stats $samples] median]] ([dict get $census analysis $name unchanged])"
        foreach kind {implementation interface semantic-error syntax-error} {
            if {![dict exists $w edits $kind]} {
                lappend row "-"
                continue
            }
            lassign [edited $w [dict get $w edits $kind]] path text
            service::setDocument $ws $path $text
            set samples {}
            for {set i 0} {$i < $N} {incr i} {
                forget $path
                lappend samples [ms {set rev [service::analyze $ws $entry]}]
                service::release $rev
            }
            service::clearDocument $ws $path
            lappend row "[fmt [dict get [stats $samples] median]] ([dict get $census analysis $name $kind])"
        }
        service::closeWorkspace $ws
        out "| $name | [join $row { | }] |"
    }
    out ""
}

# --- queries ----------------------------------------------------------------

proc queryBench {} {
    global workloads options root census
    out "## Position queries\n"
    Compilerpedia
    out "service::at against a retained revision, µs: at the census's 200 positions of the entry file (its formula), and at [dict get $options -queries] random positions of the entry and its modules (seeded). `prepare` builds every index of the revision first (a query does on first use what it needs; these are the one-time costs). In parentheses: the census's unindexed query (median, p90, max).\n"
    out "| workload | expressions | prepare, ms | census positions: median | p90 | p99 | max | random positions: median | p90 | p99 | max |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
    foreach name [dict get $options -workloads] {
        set w [dict get $workloads $name]
        set entry [file join $root [dict get $w dir] [dict get $w entry]]
        set ws [service::workspace -warnings off -cache ""]
        set rev [service::analyze $ws $entry]
        set prepare [ms {service::prepare $rev}]
        # The census's positions.
        set text [service::sourceText $rev $entry]
        set lines [split $text \n]
        set census200 {}
        for {set k 0} {$k < 200} {incr k} {
            set l [expr {1 + ($k * 7919) % [llength $lines]}]
            set len [string length [lindex $lines $l-1]]
            set c [expr {1 + ($len ? ($k * 31) % $len : 0)}]
            lappend census200 [list $entry $l $c]
        }
        # Random positions of every source text the revision read.
        expr {srand(17)}
        set files [lmap {path o} [dict get [service::revision $rev] sources] {
            if {![dict get $o read]} continue
            set path
        }]
        set random {}
        for {set k 0} {$k < [dict get $options -queries]} {incr k} {
            set path [lindex $files [expr {int(rand() * [llength $files])}]]
            set ls [split [service::sourceText $rev $path] \n]
            set l [expr {1 + int(rand() * [llength $ls])}]
            set c [expr {1 + int(rand() * ([string length [lindex $ls $l-1]] + 1))}]
            lappend random [list $path $l $c]
        }
        set row [list [dict size [dict get [service::hir $rev] exprs]] [fmt $prepare]]
        foreach positions [list $census200 $random] which {census random} {
            set samples [lmap p $positions {
                lindex [time {service::at $rev {*}$p}] 0
            }]
            set st [stats $samples]
            foreach key {median p90 p99 max} {
                set cell [fmt [dict get $st $key]]
                if {$which eq "census" && $key ne "p99"} {
                    append cell " ([lindex [dict get $census query $name] [lsearch {median p90 max} $key]])"
                }
                lappend row $cell
            }
        }
        service::closeWorkspace $ws
        out "| $name | [join $row { | }] |"
    }
    out ""
}

proc Compilerpedia {} {
    set t [ms {
        service::Compilerpedia
        compilerpedia::symbolTopics ""
    }]
    out "Compilerpedia's catalogue, loaded once per process before the queries: [fmt $t] ms.\n"
}

# --- memory -----------------------------------------------------------------

proc memory {} {
    global root options
    out "## Memory in a long-running process\n"
    set rounds [dict get $options -rounds]
    out "The 2048 demo analyzed $rounds times, each round a different unsaved edit of game2048.bot (a comment naming the round), 20 queries, then the previous revision released (one live revision, as a service keeping one per document does). Resident set in MiB; `revisions` and `derived` are what the service holds; `ASTs` the loader's parse cache (bounded at 64 entries, process-wide). Census (§3.3, analysis only): 68 MiB after 1 round, 184 after 40, 220 after 60, 220 after 120.\n"
    out "| round | RSS, MiB | revisions | derived structures | ASTs (parse cache) |\n|---:|---:|---:|---:|---:|"
    set entry [file join $root examples games 2048 demo.bot]
    set module [file join $root examples games 2048 game2048.bot]
    set original [surface::source::text $module]
    set ws [service::workspace -warnings off -cache ""]
    set previous ""
    for {set round 1} {$round <= $rounds} {incr round} {
        service::setDocument $ws $module "$original\n# round $round\n"
        set rev [service::analyze $ws $entry]
        for {set k 1} {$k <= 20} {incr k} {
            catch {service::at $rev $module [expr {1 + ($k * 37) % 300}] 5}
        }
        if {$previous ne ""} {
            service::release $previous
        }
        set previous $rev
        if {$round == 1 || $round % 10 == 0} {
            set state [service::state]
            set derived 0
            dict for {kind count} [dict get $state derived] {
                incr derived $count
            }
            out "| $round | [rss] | [dict get $state revisions] | $derived | [dict size $::surface::modules::parsed] |"
        }
    }
    service::release $previous
    set before [rss]
    set kept {}
    for {set round 1} {$round <= 10} {incr round} {
        service::setDocument $ws $module "$original\n# kept $round\n"
        lappend kept [service::analyze $ws $entry]
    }
    set retained [rss]
    foreach rev $kept {
        service::release $rev
    }
    set state [service::state]
    out "\nTen revisions retained at once: [expr {$retained - $before}] MiB more ($before -> $retained MiB); after releasing them the service holds [dict get $state revisions] revisions (Tcl keeps the freed memory for reuse: the next rounds above reuse it rather than grow).\n"
    service::closeWorkspace $ws
}

# --- fresh processes ----------------------------------------------------------

proc cli {} {
    global workloads options N root census
    out "## Fresh processes: main.tcl -check\n"
    out "`tclsh9.0 main.tcl -check -warnings off FILE`: the whole command, process start to exit. In parentheses: the census's `-emit-hir-interchange` (the nearest command before -check: the front end, then encoding and writing the HIR).\n"
    out "| workload | no front-end cache | warm front-end cache |\n|---|---:|---:|"
    set cache [file join [file tempdir] cache]
    foreach name [dict get $options -workloads] {
        set w [dict get $workloads $name]
        set entry [file join $root [dict get $w dir] [dict get $w entry]]
        set cold [lmap i [lrepeat $N 0] {
            ms {exec [info nameofexecutable] [file join $root main.tcl] -check -warnings off $entry}
        }]
        set ::env(BOTLISH_HIR_CACHE) $cache
        exec [info nameofexecutable] [file join $root main.tcl] -check -warnings off $entry
        set warm [lmap i [lrepeat $N 0] {
            ms {exec [info nameofexecutable] [file join $root main.tcl] -check -warnings off $entry}
        }]
        unset ::env(BOTLISH_HIR_CACHE)
        lassign [dict get $census cli $name] censusCold censusWarm
        out "| $name | [fmt [dict get [stats $cold] median]] ($censusCold) | [fmt [dict get [stats $warm] median]] ($censusWarm) |"
    }
    file delete -force [file dirname $cache]
    out ""
}

environment
foreach section [dict get $options -sections] {
    switch -- $section {
        analysis { analysis }
        query    { queryBench }
        memory   { memory }
        cli      { cli }
        default  { error "unknown section $section" }
    }
}
if {[dict get $options -out] ne ""} {
    set channel [open [dict get $options -out] w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $report
    close $channel
}
