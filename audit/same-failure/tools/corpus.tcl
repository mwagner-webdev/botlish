# corpus.tcl -- observational audit of SAME-FAILURE over the corpus
# (WARNINGS-SAME-FAILURE.md, "Corpus findings"). Compiles every program of
# examples/stdlib, examples/surface, bench/*.bot and lib/*.bot with warnings
# on (collected, not emitted) and reports, at the commit it runs on:
#
#   * every distinct finding (a library module's finding is reported once,
#     with the first program that loaded it), with the source line of each
#     exit and its HAND classification (the table below; a finding missing
#     from the table is printed UNCLASSIFIED and makes the tool exit
#     non-zero);
#   * the fail census of every function the corpus compiles: functions with a
#     reachable fail, reachable fail sites, re-raises, and the near misses --
#     functions that fail two or more DISTINCT declared failures (the
#     BelowRange/AboveRange pattern, deliberately not a finding) -- with
#     their names;
#   * for each finding classified as a combine-conditions candidate with a
#     curated merge below, a scratch copy of the library with the guards
#     merged: it must compile, lose the finding, and give a probe program the
#     same value as the original.
#
# The corpus itself is never edited (the scratch copy lives in a temporary
# directory and is removed).
#
#   tclsh9.0 audit/same-failure/tools/corpus.tcl ?-root DIR?
#
# -root audits another checkout (e.g. a worktree of a later commit) with this
# checkout's tools.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set auditRoot $root
foreach {option value} $argv {
    switch -- $option {
        -root { set auditRoot [file normalize $value] }
        default { error "unknown option $option" }
    }
}
source [file join $auditRoot surface surface.tcl]

set programs [concat \
    [lsort [glob -directory [file join $auditRoot examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $auditRoot examples surface] *.bot]] \
    [lsort [glob -directory [file join $auditRoot bench] *.bot]] \
    [lsort [glob -directory [file join $auditRoot lib] *.bot]]]

# The surface examples that are deliberate rejections (their own headers say
# so): expected not to compile.
set deliberate {examples/surface/09-mutual-recursion.bot examples/surface/10-duplicate-binding.bot}

# HAND classification, per distinct (file, function, failure): {CATEGORY WHY}.
#   combine   an un-split repeated guard: the conditions could be merged into
#             one guard (a combine-conditions candidate)
#   uniform   the uniform failure is the API by design, and the exits are
#             deliberately separate (kept as is)
#   split     distinct failures would inform the caller (a richer-split
#             candidate)
# A finding the author would neither merge, split, nor keep as is would be a
# false positive (item 19's bar) and a warning-design issue; none may be
# listed here as such -- the theorem changes instead.
set classified {
    {lib/abi/bytes.bot abi::bytes::replace IndexNotFound} {combine
        {the two halves of one bounds check (`index < 0`, `index >= count`), written as an if/elif pair that fails the same IndexNotFound; the failure itself is uniform by design (the header: "the same error list::at and mutable_array::set use"), so a split is not a candidate: the natural responses are merging the guards into one `or` condition or keeping the two-line form}}
}

# Curated merges for "combine" findings: FILE -> {OLD NEW} exact text
# replacements (OLD must occur exactly once), and a probe program exercising
# the function on both sides of every guard and in range.
set merges {
    lib/abi/bytes.bot {
        {    if index < 0:
        fail IndexNotFound
    elif index >= mutable_byte_store::count(data.storage):
        fail IndexNotFound
    else:}
        {    if index < 0 or index >= mutable_byte_store::count(data.storage):
        fail IndexNotFound
    else:}
    }
}
set probes {
    lib/abi/bytes.bot {import abi
import abi::bytes
import byte
import str

fn mb(s: str):
    abi::bytes::from_bytes(abi::bytes::from_list(str::encode_utf8(s)))
fn tryset(m: abi::bytes::MutableBytes, i: int) -> List[any] errors IndexNotFound:
    r = abi::bytes::replace(m, i, byte::from_int(88))
    [abi::bytes::mutable_length(r).value, abi::bytes::freeze(r) == abi::bytes::freeze(m)]
fn at(m: abi::bytes::MutableBytes, i: int):
    tryset(m, i):
        on IndexNotFound:
            []
m = mb("abc")
[at(m, 0 - 1), at(m, 0), at(m, 2), at(m, 3), at(m, 1000), at(abi::bytes::zeroed(abi::usize(0)), 0), at(mb("XYZ"), 0)]}
}

proc readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8
    set text [read $channel]
    close $channel
    return $text
}

proc writeText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
}

proc rel {path} {
    return [string map [list $::auditRoot/ {}] $path]
}

proc compilePath {path} {
    return [surface::readProgramFile $path -warnings default -warning-channel ""]
}

proc failuresOf {hir} {
    return [lmap w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "SAME-FAILURE"} continue
        set w
    }]
}

proc pathOf {hir origin} {
    return [dict get [hir::sourceFile $hir [lindex $origin 1]] path]
}

proc lineOf {hir origin} {
    set lines [split [readText [pathOf $hir $origin]] \n]
    return [string trim [lindex $lines [expr {[dict get [lrange $origin 2 end] line] - 1}]]]
}

proc valueOf {hir} {
    if {[catch {core::formatValue [core::evalProgram [hir::lower $hir]]} v]} {
        return [list error $v]
    }
    return $v
}

# 1 if the fail E of HIR sits in an on-handler body handling its own name.
proc reraise? {hir block e} {
    foreach h [hir::warnings::BodyExprs $hir $block] {
        if {[dict get $hir exprs $h kind] ne "handle"} continue
        foreach name [dict get $hir exprs $h handlerNames] body [dict get $hir exprs $h handlerBodies] {
            foreach x $body {
                set acc {}
                hir::warnings::BodyInto $hir $x acc
                if {$e in $acc && $name eq [dict get $hir exprs $e name]} {
                    return 1
                }
            }
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# The audit

set commit [string trim [exec git -C $auditRoot rev-parse HEAD]]
set dirty [string trim [exec git -C $auditRoot status --porcelain -- examples bench lib]]
puts "# SAME-FAILURE corpus audit: tclsh9.0 audit/same-failure/tools/corpus.tcl"
puts "# commit $commit (corpus paths [expr {$dirty eq "" ? "clean" : "MODIFIED: $dirty"}])"
puts ""

set findings [dict create]     ;# primary location -> record
set failed {}
set compiled 0
set functions [dict create]    ;# function location -> {name file sites names reraises}
foreach path $programs {
    if {[catch {compilePath $path} hir options]} {
        lappend failed [list [rel $path] [dict get $options -errorcode]]
        continue
    }
    incr compiled
    foreach w [failuresOf $hir] {
        set where [rel [hir::originLocation $hir [dict get $w primary]]]
        if {[dict exists $findings $where]} continue
        dict set findings $where [dict create file [rel [pathOf $hir [dict get $w primary]]] \
            name [dict get $w data functionName] failure [dict get $w data failure] \
            exits [dict get $w data exits] \
            lines [lmap o [list [dict get $w primary] {*}[dict get $w secondary]] {
                list [rel [hir::originLocation $hir $o]] [lineOf $hir $o]
            }] entry [rel $path]]
    }
    # The fail census, from the pass's own pieces: per source function, its
    # reachable fail sites (structural tier, as the pass enumerates them) and
    # the failures they name.
    set names [hir::warnings::BlockNames $hir]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![dict get $node reachable]
                || [lindex [dict get $node origin] 0] ne "file"} continue
        set where [join [lrange [split [rel [hir::originLocation $hir [dict get $node origin]]] :] 0 1] :]
        if {[dict exists $functions $where]} continue
        set sites [hir::warnings::FailSites $hir $e]
        if {$sites eq ""} continue
        set reraises 0
        foreach site $sites {
            incr reraises [reraise? $hir $e [lindex $site 0]]
        }
        dict set functions $where [list [expr {[dict exists $names $e] ? [dict get $names $e] : "?"}] \
            [llength $sites] [lmap s $sites {lindex $s 1}] $reraises [rel $path]]
    }
}

puts "compiled $compiled of [llength $programs] programs"
foreach f $failed {
    lassign $f path code
    puts "  not compiled: $path ($code)[expr {$path in $deliberate ? " -- a deliberate rejection" : ""}]"
}
puts ""

set unclassified 0
set categories [dict create]
puts "## Findings: [dict size $findings] distinct"
set i 0
foreach where [lsort -dictionary [dict keys $findings]] {
    set f [dict get $findings $where]
    set key [list [dict get $f file] [dict get $f name] [dict get $f failure]]
    puts "[incr i]. $where: `[dict get $f name]`: failure `[dict get $f failure]` from [dict get $f exits] exits (first seen compiling [dict get $f entry])"
    foreach line [dict get $f lines] {
        puts "     [lindex $line 0]: [lindex $line 1]"
    }
    if {[dict exists $classified $key]} {
        lassign [dict get $classified $key] category why
        dict incr categories $category
        puts "     HAND: $category -- $why"
    } else {
        incr unclassified
        puts "     HAND: UNCLASSIFIED"
    }
}
puts ""
puts "## Categories"
foreach category {combine uniform split} {
    puts "  $category: [expr {[dict exists $categories $category] ? [dict get $categories $category] : 0}]"
}
puts "  false positives: 0 by construction of the table (an unclassified finding fails the tool: $unclassified unclassified)"
puts ""

# The census.
set totalSites 0
set totalReraises 0
set distinctOnly {}
set single 0
foreach where [lsort -dictionary [dict keys $functions]] {
    lassign [dict get $functions $where] name count failures reraises entry
    incr totalSites $count
    incr totalReraises $reraises
    set unique [lsort -unique $failures]
    if {$count == 1} {
        incr single
    } elseif {[llength $unique] == $count} {
        lappend distinctOnly [list $where $name $unique]
    }
}
puts "## Fail census (functions with at least one structurally reachable fail of a declared failure)"
puts "  functions: [dict size $functions] ($single with a single fail site); reachable fail sites: $totalSites; re-raises: $totalReraises"
puts "  near misses -- two or more fail sites, every one a DISTINCT failure (never a finding): [llength $distinctOnly]"
foreach entry $distinctOnly {
    lassign $entry where name unique
    puts "     $where: `$name`: [join $unique {, }]"
}
puts ""

# The merge check, in a scratch copy of the library.
puts "## Merge check (scratch copy of the library; the corpus is not edited)"
foreach {file pair} $merges {
    lassign $pair old new
    set scratch [file tempdir same-failure-corpus]
    set lib [file join $scratch lib]
    file copy [file join $auditRoot lib] $lib
    set path [file join $scratch $file]
    set text [readText $path]
    set at [string first $old $text]
    if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
        puts "  $file: the merge does not apply exactly once"
        incr unclassified
        file delete -force $scratch
        continue
    }
    set probe [dict get $probes $file]
    set saved $::core::libraryDir
    set before [surface::compile $probe probe.bot -warnings default -warning-channel ""]
    writeText $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    set ::core::libraryDir $lib
    try {
        set merged [catch {surface::compile $probe probe.bot -warnings default -warning-channel ""} after]
    } finally {
        set ::core::libraryDir $saved
    }
    if {$merged} {
        puts "  $file: the merged copy does not compile: $after"
        incr unclassified
    } else {
        set left [lmap w [failuresOf $after] {hir::originLocation $after [dict get $w primary]}]
        set kept [lmap w [failuresOf $before] {hir::originLocation $before [dict get $w primary]}]
        set v0 [valueOf $before]
        set v1 [valueOf $after]
        puts "  $file: original probe: [llength $kept] SAME-FAILURE finding(s), value $v0"
        puts "  $file: merged copy:    [llength $left] SAME-FAILURE finding(s), value $v1"
        set holds [expr {$left eq "" && $kept ne "" && $v0 eq $v1 && [lindex $v0 0] ne "error"}]
        puts "  $file: [expr {$holds ? "merge holds (compiles, finding gone, same value)" : "MERGE CHECK FAILED"}]"
        if {!$holds} {
            incr unclassified
        }
    }
    file delete -force $scratch
}
exit [expr {$unclassified > 0}]
