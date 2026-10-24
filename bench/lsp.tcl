# lsp.tcl -- the language server's performance report and scheduling
# comparison (LSP-MILESTONE-1.md, "Scheduling decision" and "Performance").
#
#   tclsh9.0 bench/lsp.tcl ?-workloads NAMES? ?-schedulers LIST? ?-edits N?
#                          ?-idle N? ?-seed S? ?-recovery 0|1? ?-sessions 0|1?
#                          ?-memory ROUNDS? ?-malformed 0|1? ?-out FILE?
#
# Replays one scripted editing session per workload through each scheduler
# (worker, sync), the real server (`main.tcl -lsp`) in a child process over
# real pipes (tests/lsp-client.tcl), and measures from both sides:
#
#   the client   hover latency while editing (an edit of an imported module
#                every 150-300 ms, a hover of the entry -- answerable from
#                an available revision, the entry being unchanged -- inside
#                each interval, and of the edited module, in text the edit
#                does not touch, every third), the time from the last edit to
#                that version's diagnostics, latency once idle, publications
#                of versions already superseded, the resident memory of the
#                server and its worker (Linux: /proc)
#   the server   its own measurements (BOTLISH_LSP_STATS: lsp/stats.tcl): the
#                longest event-loop callbacks, analyses run, killed and
#                their time, worker starts, revision import time and size
#
# and checks that the two schedulers end with the same diagnostics and
# answer the idle hovers identically. With -recovery 1 (the default) it also
# measures, for the worker, the recovery from a worker that dies mid-answer
# (BOTLISH_LSP_FAULT crash-marker): the time from the next edit to its
# diagnostics, a new worker started. -memory ROUNDS adds a long session per
# workload and scheduler (ROUNDS edits, each analyzed and queried before the
# next) sampling the resident memory of the server and its worker after
# each round (steady state against the peaks of the editing sessions);
# -sessions 0 runs only that. With -malformed 1 every other edit leaves the
# edited expression unfinished (a syntax error in the imported module), the
# others restore it: the editing session through syntax errors of
# SYNTAX-RECOVERY-MILESTONE-1.md, "Performance".
#
# The workloads are the compiler-service census's (COMPILER-SERVICE-CENSUS.md,
# section 7): csv (a single file: the entry is the edited module), the 2048
# demo, the icy-tower headless program, and the 2048 golden suite, the
# largest. Analyses run with -warnings off, as the census's did.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root tests lsp-client.tcl]

set options [dict create -workloads {csv 2048 icy 2048-golden} -schedulers {worker sync} -edits 20 \
    -idle 20 -seed 7 -recovery 1 -sessions 1 -memory 0 -malformed 0 -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
expr {srand([dict get $options -seed])}

set workloads [dict create \
    csv [dict create dir examples/stdlib entry csv.bot module csv.bot old {return ""} new {return "" + ""} at {98 10}] \
    2048 [dict create dir examples/games/2048 entry demo.bot module game2048.bot \
        old {scores.get(i, 0) + from(i + 1)} new {scores.get(i, 0) + from(i + 1) + 0}] \
    icy [dict create dir examples/games/icy-tower entry headless.bot module tower.bot \
        old {floor.mod(25) == 0} new {floor.mod(25) == 0 and true}] \
    2048-golden [dict create dir examples/games/2048 entry golden.bot module game2048.bot \
        old {scores.get(i, 0) + from(i + 1)} new {scores.get(i, 0) + from(i + 1) + 0}]]

proc readFile {path} {
    set f [open $path]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

# The protocol position of the first qualified name after the imports of
# TEXT (a call of an imported module's function), or of the first function
# declaration's name when FN.
proc position {text {fn 0}} {
    set lines [split $text \n]
    for {set l 0} {$l < [llength $lines]} {incr l} {
        set line [lindex $lines $l]
        if {[regexp {^\s*(#|import )} $line]} continue
        if {$fn} {
            if {[regexp -indices {^fn ([a-z_0-9]+)} $line -> name]} {
                return [list $l [expr {[lindex $name 0] + 1}]]
            }
        } elseif {[regexp -indices {\m([a-z_0-9]+)::[a-z_0-9]+} $line match] && ![string match *std::* [string range $line {*}$match]]} {
            return [list $l [expr {[lindex $match 0] + 1}]]
        }
    }
    error "no position"
}

proc percentile {values p} {
    set sorted [lsort -real $values]
    if {$sorted eq {}} {
        return -
    }
    set i [expr {min([llength $sorted] - 1, int(ceil($p / 100.0 * [llength $sorted])) - 1)}]
    return [lindex $sorted [expr {max($i, 0)}]]
}

proc median {values} {
    return [percentile $values 50]
}

# Resident memory of process PID in MiB, or "" (Linux: /proc).
proc rss {pid} {
    if {[catch {readFile /proc/$pid/status} status] || ![regexp {VmRSS:\s+(\d+) kB} $status -> kb]} {
        return ""
    }
    return [expr {$kb / 1024.0}]
}

# The diagnostics of a publication, briefly.
proc brief {params} {
    if {$params eq ""} {
        return ""
    }
    return [lmap d [lsp::json::elements [lsp::json::get $params diagnostics]] {
        list [lsp::json::write [lsp::json::get $d range]] [lsp::json::text [lsp::json::get $d code]] [lsp::json::text [lsp::json::get $d message]]
    }]
}

# The version of the last publication for URI, or 0.
proc published {c uri} {
    set params [lspc::published $c $uri]
    if {$params eq "" || ![lsp::json::has $params version]} {
        return 0
    }
    return [lsp::json::integer [lsp::json::get $params version]]
}

proc sample {c samplesVar} {
    upvar 1 $samplesVar samples
    lappend samples(server) [rss [lindex [lspc::Get $c pid] 0]]
    set workers [regexp -all -inline {analysis worker started \(pid (\d+)} [lspc::stderr $c]]
    if {$workers ne {}} {
        lappend samples(worker) [rss [lindex $workers end]]
    }
}

# Runs the event loop for MS milliseconds, sampling memory.
proc pump {c ms samplesVar} {
    upvar 1 $samplesVar samples
    catch {lspc::until $c 0 -timeout $ms}
    sample $c samples
}

proc session {name scheduler} {
    global root workloads options
    set w [dict get $workloads $name]
    set dir [file join $root [dict get $w dir]]
    set entryPath [file join $dir [dict get $w entry]]
    set modulePath [file join $dir [dict get $w module]]
    set entry [lspc::uri $entryPath]
    set module [lspc::uri $modulePath]
    set entryText [readFile $entryPath]
    set moduleText [readFile $modulePath]
    if {[string first [dict get $w old] $moduleText] < 0} {
        error "$name: the edit's text is not in [dict get $w module]"
    }
    if {[dict exists $w at]} {
        set entryAt [dict get $w at]
    } else {
        set entryAt [position $entryText]
    }
    set moduleAt [position $moduleText 1]
    set stats [file join [file tempdir lspbench] stats.txt]
    array set samples {server {} worker {}}
    set start [clock milliseconds]
    set c [lspc::start -scheduler $scheduler -args {-warnings off} -env [list BOTLISH_LSP_STATS $stats]]
    set startup [expr {[clock milliseconds] - $start}]
    set opened [clock milliseconds]
    lspc::didOpen $c $entry $entryText
    if {$module ne $entry} {
        lspc::didOpen $c $module $moduleText
    }
    lspc::until $c {[published $c $entry] >= 1} -timeout 600000
    set first [expr {[clock milliseconds] - $opened}]
    sample $c samples

    # Editing: an edit every 150-300 ms, hovers inside the intervals.
    set hovers {}
    set sent {}
    set version 1
    for {set k 1} {$k <= [dict get $options -edits]} {incr k} {
        set replacement [if {$k % 2} {dict get $w new} else {dict get $w old}]
        if {$k % 2 && [dict get $options -malformed]} {
            append replacement " +"
        }
        set text [string map [list [dict get $w old] "$replacement # lsp-bench $k"] $moduleText]
        lspc::didChange $c $module [incr version] $text
        set lastEdit [clock milliseconds]
        set interval [expr {150 + int(rand() * 151)}]
        set before [expr {40 + int(rand() * ($interval - 60))}]
        pump $c $before samples
        lappend hovers [list entry [lspc::send $c textDocument/hover [lspc::at $entry {*}$entryAt]] [clock milliseconds]]
        if {$k % 3 == 0 && $module ne $entry} {
            lappend hovers [list module [lspc::send $c textDocument/hover [lspc::at $module {*}$moduleAt]] [clock milliseconds]]
        }
        pump $c [expr {$interval - $before}] samples
    }
    set lastVersion $version
    lspc::until $c {[published $c $module] >= $lastVersion} -timeout 600000
    set diagnosticsLatency ""
    foreach n [lspc::Get $c notifications] t [lspc::Get $c arrivals] {
        set params [lsp::json::get $n params]
        if {[lsp::json::get $params uri {null {}}] eq [list str $module]
                && [lsp::json::get $params version {num 0}] eq [list num $lastVersion]} {
            set diagnosticsLatency [expr {$t - $lastEdit}]
            break
        }
    }
    foreach h $hovers {
        lspc::response $c [lindex $h 1] -timeout 600000
    }
    set editing [lmap h $hovers {expr {[dict get [lspc::Get $c answered] [lindex $h 1]] - [lindex $h 2]}}]
    # Publications of a version the client had already replaced.
    set published {}
    foreach n [lspc::Get $c notifications] t [lspc::Get $c arrivals] {
        set params [lsp::json::get $n params]
        if {[lsp::json::get $n method] eq {str textDocument/publishDiagnostics} && [lsp::json::get $params uri] eq [list str $module]
                && [lsp::json::has $params version]} {
            lappend published [lsp::json::integer [lsp::json::get $params version]]
        }
    }
    # Idle: the same hover, answered fresh.
    set idle {}
    set answers {}
    for {set i 0} {$i < [dict get $options -idle]} {incr i} {
        set t [clock milliseconds]
        set response [lspc::hover $c $entry {*}$entryAt]
        lappend idle [expr {[clock milliseconds] - $t}]
        lappend answers [lsp::json::write $response]
    }
    sample $c samples
    set final [list [brief [lspc::published $c $entry]] [brief [lspc::published $c $module]]]
    set end [lspc::stop $c]
    set report [readFile $stats]
    if {[info exists ::env(BOTLISH_LSP_BENCH_DEBUG)]} {
        puts stderr "$name $scheduler: [dict get $report longest]"
    }
    file delete -force [file dirname $stats]
    set counters [dict get $report counters]
    set totals [dict get $report totals]
    set serverRss [lmap v $samples(server) {if {$v eq ""} continue; set v}]
    set workerRss [lmap v $samples(worker) {if {$v eq ""} continue; set v}]
    return [dict create workload $name scheduler $scheduler startup $startup first $first \
        editing $editing idle $idle diagnostics $diagnosticsLatency longest [dict get $report longest] \
        analyses [dict getdef $counters analyses 0] submitted [dict getdef $counters submitted 0] \
        killed [dict getdef $counters supersededKilled 0] killedMs [dict getdef $totals supersededMs 0] \
        analysisMs [dict getdef $totals analysisMs 0] workerAnalysisMs [dict getdef $totals workerAnalysisMs 0] \
        workerExportMs [dict getdef $totals workerExportMs 0] \
        workerStarts [dict getdef $counters workerStarts 0] workerStartMs [dict getdef $totals workerStartMs 0] \
        importMs [dict getdef $totals importMs 0] importBytes [dict getdef $counters importBytes 0] \
        staleResults [dict getdef $counters staleResults 0] freshResults [dict getdef $counters freshResults 0] \
        publishedVersions $published lastVersion $lastVersion \
        serverRss $serverRss workerRss $workerRss status [dict get $end status] final $final answers [lsort -unique $answers]]
}

# The worker's recovery from a crash: the time from the edit after it to
# that edit's diagnostics.
proc recovery {name} {
    global root workloads
    set w [dict get $workloads $name]
    set dir [file join $root [dict get $w dir]]
    set entry [lspc::uri [file join $dir [dict get $w entry]]]
    set module [lspc::uri [file join $dir [dict get $w module]]]
    set moduleText [readFile [file join $dir [dict get $w module]]]
    set c [lspc::start -scheduler worker -args {-warnings off} -env {BOTLISH_LSP_FAULT crash-marker=LSP-BENCH-CRASH}]
    lspc::didOpen $c $entry [readFile [file join $dir [dict get $w entry]]]
    if {$module ne $entry} {
        lspc::didOpen $c $module $moduleText
    }
    lspc::until $c {[published $c $entry] >= 1} -timeout 600000
    lspc::didChange $c $module 2 "$moduleText\n# LSP-BENCH-CRASH\n"
    set crashed [clock milliseconds]
    lspc::until $c {[lspc::notifications $c window/logMessage] ne {}} -timeout 600000
    set detected [expr {[clock milliseconds] - $crashed}]
    lspc::didChange $c $module 3 "$moduleText\n# recovered\n"
    set edited [clock milliseconds]
    lspc::until $c {[published $c $module] >= 3} -timeout 600000
    set recovered [expr {[clock milliseconds] - $edited}]
    set end [lspc::stop $c]
    return [dict create detected $detected recovered $recovered workers [regexp -all {analysis worker started} [dict get $end stderr]] status [dict get $end status]]
}

# Memory over a long session of scheduler SCHEDULER on workload NAME: ROUNDS
# edits of its module, each waited for (its diagnostics published), the
# resident set of the server and of its worker sampled after each.
proc memory {name scheduler rounds} {
    global root workloads
    set w [dict get $workloads $name]
    set dir [file join $root [dict get $w dir]]
    set entry [lspc::uri [file join $dir [dict get $w entry]]]
    set module [lspc::uri [file join $dir [dict get $w module]]]
    set moduleText [readFile [file join $dir [dict get $w module]]]
    set c [lspc::start -scheduler $scheduler -args {-warnings off}]
    lspc::didOpen $c $entry [readFile [file join $dir [dict get $w entry]]]
    if {$module ne $entry} {
        lspc::didOpen $c $module $moduleText
    }
    lspc::until $c {[published $c $entry] >= 1} -timeout 600000
    array set samples {server {} worker {}}
    set rows {}
    for {set k 1} {$k <= $rounds} {incr k} {
        lspc::didChange $c $module [expr {$k + 1}] [string map [list [dict get $w old] "[dict get $w new] # round $k"] $moduleText]
        lspc::until $c {[published $c $module] >= $k + 1} -timeout 600000
        if {[dict exists $w at]} {
            lspc::hover $c $entry {*}[dict get $w at]
        } else {
            lspc::hover $c $entry {*}[position [readFile [file join $dir [dict get $w entry]]]]
        }
        set samples(server) {}
        set samples(worker) {}
        sample $c samples
        lappend rows [list $k [lindex $samples(server) end] [lindex $samples(worker) end]]
    }
    lspc::stop $c
    return $rows
}

proc fmt {value {digits 0}} {
    if {$value eq "" || $value eq "-"} {
        return -
    }
    return [format %.${digits}f $value]
}

set results {}
if {[dict get $options -sessions]} {
    foreach name [dict get $options -workloads] {
        foreach scheduler [dict get $options -schedulers] {
            puts stderr "== $name ($scheduler)"
            lappend results [session $name $scheduler]
        }
    }
}
set memories {}
if {[dict get $options -memory] > 0} {
    foreach name [dict get $options -workloads] {
        foreach scheduler [dict get $options -schedulers] {
            puts stderr "== $name ($scheduler, memory)"
            dict set memories "$name $scheduler" [memory $name $scheduler [dict get $options -memory]]
        }
    }
}
set recoveries {}
if {[dict get $options -recovery] && "worker" in [dict get $options -schedulers]} {
    foreach name [dict get $options -workloads] {
        puts stderr "== $name (worker crash recovery)"
        dict set recoveries $name [recovery $name]
    }
}

set lines {}
lappend lines "# Language server benchmark" "" \
    "[clock format [clock seconds] -format {%Y-%m-%d}], Tcl [info patchlevel], [exec nproc] processors; [dict get $options -edits] edits per session every 150-300 ms[expr {[dict get $options -malformed] ? ", every other one a syntax error (-malformed 1)" : ""}], [dict get $options -idle] idle hovers; seed [dict get $options -seed]." "" \
    "## Hover latency (ms) while editing, and once idle" "" \
    "| workload | scheduler | editing: median | p95 | p99 | max | idle: median | p95 | max |" \
    "|---|---|---:|---:|---:|---:|---:|---:|---:|"
foreach r $results {
    set e [dict get $r editing]
    set i [dict get $r idle]
    lappend lines "| [dict get $r workload] | [dict get $r scheduler] | [fmt [median $e]] | [fmt [percentile $e 95]] | [fmt [percentile $e 99]] | [fmt [percentile $e 100]] | [fmt [median $i]] | [fmt [percentile $i 95]] | [fmt [percentile $i 100]] |"
}
lappend lines "" "## Diagnostics, event loop and analysis work" "" \
    "| workload | scheduler | first diagnostics (ms) | last edit to its diagnostics (ms) | longest callback (ms) | analyses run | killed (ms of their work) | intermediate versions published |" \
    "|---|---|---:|---:|---:|---:|---:|---:|"
foreach r $results {
    set longest [lindex [dict get $r longest] 0]
    set superseded 0
    foreach v [dict get $r publishedVersions] {
        if {$v < [dict get $r lastVersion]} { incr superseded }
    }
    lappend lines "| [dict get $r workload] | [dict get $r scheduler] | [dict get $r first] | [dict get $r diagnostics] | [fmt [lindex $longest 0]] ([lindex $longest 1]) | [dict get $r analyses] of [dict get $r submitted] submitted | [dict get $r killed] ([fmt [dict get $r killedMs]]) | $superseded |"
}
lappend lines "" "## Worker, transfer and memory" "" \
    "| workload | scheduler | server start (ms) | worker starts | worker start to hello (ms, mean) | analysis in the worker (ms, mean) | indexes and export in the worker (ms, mean) | import (ms, mean) | transferred (KiB, mean) | server RSS max (MiB) | worker RSS max (MiB) | processes |" \
    "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
foreach r $results {
    # (A killed analysis never returns: every analysis counted was imported.)
    set imports [expr {[dict get $r scheduler] eq "worker" ? max(1, [dict get $r analyses]) : 0}]
    set starts [dict get $r workerStarts]
    lappend lines "| [dict get $r workload] | [dict get $r scheduler] | [dict get $r startup] | $starts | [expr {$starts ? [fmt [expr {[dict get $r workerStartMs] / $starts}]] : "-"}] | [expr {$imports ? [fmt [expr {[dict get $r workerAnalysisMs] / double($imports)}]] : "-"}] | [expr {$imports ? [fmt [expr {[dict get $r workerExportMs] / double($imports)}]] : "-"}] | [expr {$imports ? [fmt [expr {[dict get $r importMs] / $imports}] 1] : "-"}] | [expr {$imports ? [fmt [expr {[dict get $r importBytes] / 1024.0 / $imports}]] : "-"}] | [fmt [tcl::mathfunc::max 0 {*}[dict get $r serverRss]]] | [expr {[dict get $r workerRss] eq {} ? "-" : [fmt [tcl::mathfunc::max {*}[dict get $r workerRss]]]}] | [expr {[dict get $r scheduler] eq "worker" ? 2 : 1}] |"
}
if {$recoveries ne {}} {
    lappend lines "" "## Worker crash recovery" "" "| workload | crash reported after (ms) | next edit to its diagnostics (ms) | workers started | exit |" "|---|---:|---:|---:|---:|"
    dict for {name r} $recoveries {
        lappend lines "| $name | [dict get $r detected] | [dict get $r recovered] | [dict get $r workers] | [dict get $r status] |"
    }
}
if {$memories ne {}} {
    set rounds [dict get $options -memory]
    set shown [lsort -integer -unique [list 1 [expr {max(1, $rounds / 4)}] [expr {max(1, $rounds / 2)}] [expr {max(1, 3 * $rounds / 4)}] $rounds]]
    lappend lines "" "## Memory over a long session (MiB resident after each round: server / worker)" "" \
        "| workload | scheduler | [join [lmap k $shown {string cat "round $k"}] { | }] | max |" \
        "|---|---|[string repeat ---:| [expr {[llength $shown] + 1}]]"
    dict for {key rows} $memories {
        set cells [lmap k $shown {
            lassign [lindex $rows [expr {$k - 1}]] - server worker
            string cat [fmt $server] / [fmt $worker]
        }]
        set maxServer [tcl::mathfunc::max {*}[lmap r $rows {expr {[lindex $r 1] eq "" ? 0 : [lindex $r 1]}}]]
        set workers [lmap r $rows {if {[lindex $r 2] eq ""} continue; lindex $r 2}]
        set maxWorker [if {$workers eq {}} {list -} else {tcl::mathfunc::max {*}$workers}]
        lappend lines "| [lindex $key 0] | [lindex $key 1] | [join $cells { | }] | [fmt $maxServer] / [fmt $maxWorker] |"
    }
}
if {$results eq {}} {
    set text [join $lines \n]
    puts $text
    if {[dict get $options -out] ne ""} {
        set f [open [dict get $options -out] w]
        puts $f $text
        close $f
    }
    exit 0
}
lappend lines "" "## Equivalence" ""
foreach name [dict get $options -workloads] {
    set finals [lsort -unique [lmap r $results {if {[dict get $r workload] ne $name} continue; dict get $r final}]]
    set answers [lsort -unique [lmap r $results {if {[dict get $r workload] ne $name} continue; dict get $r answers}]]
    set statuses [lsort -unique [lmap r $results {if {[dict get $r workload] ne $name} continue; dict get $r status}]]
    lappend lines "* $name: final diagnostics [expr {[llength $finals] == 1 ? "identical" : "DIFFER"}], idle hover answers [expr {[llength $answers] == 1 ? "identical" : "DIFFER"}], exit statuses $statuses"
}
set text [join $lines \n]
puts $text
if {[dict get $options -out] ne ""} {
    set f [open [dict get $options -out] w]
    fconfigure $f -encoding utf-8
    puts $f $text
    close $f
}
