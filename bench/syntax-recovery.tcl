# syntax-recovery.tcl -- the performance report of syntax-error-tolerant
# analysis (SYNTAX-RECOVERY-MILESTONE-1.md, "Performance"), measured through
# the compiler service's own interface, in one warm process, with no
# front-end cache and warnings off (the compiler-service census's setting).
#
#   tclsh9.0 bench/syntax-recovery.tcl ?-root DIR? ?-repeat N?
#       ?-workloads NAMES? ?-sections LIST? ?-out FILE?
#
# -root DIR measures another checkout (the baseline: the revision before the
# milestone, whose service stops at a syntax error) with the same programs
# and edits; a section that measures what only recovery does prints "-"
# there. Sections (-sections, all by default):
#
#   parse     per corpus file, the strict parse (surface::parse) of its text
#             and, with one and with three syntax errors written into it,
#             the recovering parse (surface::parse -recover 1) and the
#             recovery of its syntax tree (surface::recover::apply):
#             microseconds, median of N.
#   analysis  per workload, service::analyze of the program as written, and
#             with a malformed expression in the entry, in a module the
#             entry imports, in a module it imports only through another
#             (transitive), and with several independent syntax errors in
#             two files; each edit an unsaved buffer, the edited files'
#             cached ASTs dropped first. Milliseconds (median of N), the
#             whole-program builds one analysis made (hir::buildStats), and
#             the revision's outcome and semantics.
#   typing    a statement typed into a function of the 2048 engine one
#             character at a time, each version analyzed (as a language
#             server does once typing pauses): per version, and the
#             analyses of the versions that parse against the ones that do
#             not.
#   transfer  service::export and service::import (the language server's
#             worker transfer) of a complete and of a recovered revision of
#             each workload: milliseconds and bytes.
#   memory    ten revisions of the 2048 golden suite retained at once, each
#             with a different unsaved syntax error in its engine, against
#             ten complete ones: the resident set they add, per revision.
#
# The language server's request latency during recovery is bench/lsp.tcl's
# editing session with -malformed 1 (every other edit of the imported module
# a syntax error). Every figure is wall-clock time; run nothing else
# meanwhile. -out FILE also writes the report there.

set options [dict create -root "" -repeat 5 -workloads {csv 2048 icy 2048-golden chain} \
    -sections {parse analysis typing transfer memory} -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "syntax-recovery.tcl: unknown option $option (known: [join [dict keys $options] {, }])"
    }
    dict set options $option $value
}
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file normalize [info script]]]]
}
set root [file normalize $root]
source [file join $root service service.tcl]
set N [dict get $options -repeat]
unset -nocomplain ::env(BOTLISH_HIR_CACHE)
set ::env(LANG) C.utf8
set ::env(LC_ALL) C.utf8
# Whether the measured front end recovers (the baseline does not).
set recovers [llength [info commands ::surface::recover::apply]]

# A three-module chain written for this report (main -> mid -> low, every
# function of a module calling one of the module below), in a private
# directory: an error in low is a transitive dependency of main.
set chainDir [file tempdir syntax-recovery-bench]
proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}
apply {{dir} {
    set low ""
    set mid "import low\n\n"
    for {set i 0} {$i < 40} {incr i} {
        append low "fn l$i\(n: int) -> int:\n    k = n * $i\n    k + [expr {$i + 1}]\n\n"
        append mid "fn m$i\(n: int) -> int:\n    v = low::l$i\(n)\n    v + low::l[expr {($i + 1) % 40}](v)\n\n"
    }
    set main "import mid\n\nfn total(n: int) -> int:\n    t0 = 0\n"
    for {set i 0} {$i < 40} {incr i} {
        append main "    t[expr {$i + 1}] = t$i + mid::m$i\(n)\n"
    }
    append main "    t40\n\nresult = total(3)\nresult\n"
    writeFile [file join $dir low.bot] $low
    writeFile [file join $dir mid.bot] $mid
    writeFile [file join $dir main.bot] $main
}} $chainDir

# Workloads: NAME -> {dir DIR entry FILE edits {SCENARIO {{FILE NEEDLE REPLACEMENT} ...} ...}}.
# The compiler-service census's programs (COMPILER-SERVICE-CENSUS.md,
# section 7) and the chain; each edit leaves an expression unfinished.
set workloads [dict create \
    csv [dict create dir [file join $root examples stdlib] entry csv.bot edits {
        entry {{csv.bot {return ""} {return "" +}}}
        several {{csv.bot {return ""} {return "" +}} {csv.bot {    text.scan_unquoted(index, index)} {    text.scan_unquoted(index, index}}
            {csv.bot {    text.scan_records(scanned.stop, records.append(scanned.fields))} {    text.scan_records(scanned.stop, records.append(}}}
    }] \
    2048 [dict create dir [file join $root examples games 2048] entry demo.bot edits {
        module {{demo_play.bot {    gap = 6 - std::str::length(text)} {    gap = 6 - std::str::length(text) -}}}
        transitive {{game2048.bot {            return 0} {            return 0 +}}}
        several {{game2048.bot {            return 0} {            return 0 +}} {game2048.bot {        line.reversed()} {        line.reversed(}}
            {demo_play.bot {    gap = 6 - std::str::length(text)} {    gap = 6 - std::str::length(text) -}}}
    }] \
    icy [dict create dir [file join $root examples games icy-tower] entry headless.bot edits {
        entry {{headless.bot {    hud::summary(world, 600)} {    hud::summary(world, 600) +}}}
        module {{hud.bot {    shown.to_string()} {    shown.to_string(}}}
        transitive {{tower.bot {floor.mod(25) == 0} {floor.mod(25) ==}}}
        several {{tower.bot {floor.mod(25) == 0} {floor.mod(25) ==}} {hud.bot {    shown.to_string()} {    shown.to_string(}}
            {hud.bot {            "".append_char(' ').concat(part).concat(from(i + 1))} {            "".append_char(' ').concat(part).concat(}}}
    }] \
    2048-golden [dict create dir [file join $root examples games 2048] entry golden.bot edits {
        module {{game2048.bot {            return 0} {            return 0 +}}}
        several {{game2048.bot {            return 0} {            return 0 +}} {game2048.bot {        line.reversed()} {        line.reversed(}}
            {game2048.bot {            row.get(column, empty)} {            row.get(column,}}}
    }] \
    chain [dict create dir $chainDir entry main.bot edits {
        entry {{main.bot {    t8 = t7 + mid::m7(n)} {    t8 = t7 + mid::m7(n) +}}}
        module {{mid.bot {    v = low::l7(n)} {    v = low::l7(n) +}}}
        transitive {{low.bot {    k = n * 7} {    k = n * 7 +}}}
        several {{low.bot {    k = n * 7} {    k = n * 7 +}} {low.bot {    k = n * 20} {    k = n * 20 -}}
            {mid.bot {    v = low::l30(n)} {    v = low::l30(n) *}}}
    }] \
]

# --- statistics (bench/compiler-service.tcl's) ------------------------------

proc stats {samples} {
    set s [lsort -real $samples]
    set n [llength $s]
    set p90 [lindex $s [expr {max(0, int(ceil(0.9 * $n)) - 1)}]]
    set median [expr {$n % 2 ? [lindex $s [expr {$n / 2}]] : ([lindex $s [expr {$n / 2 - 1}]] + [lindex $s [expr {$n / 2}]]) / 2.0}]
    return [dict create n $n min [lindex $s 0] median $median p90 $p90 max [lindex $s end]]
}
proc median {samples} {
    return [dict get [stats $samples] median]
}
proc fmt {x} {
    if {![string is double -strict $x]} { return $x }
    if {$x >= 100} { return [format %.0f $x] }
    if {$x >= 10} { return [format %.1f $x] }
    return [format %.2f $x]
}
proc us {script} {
    set t [clock microseconds]
    uplevel 1 $script
    return [expr {[clock microseconds] - $t}]
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
    return [expr {$kb / 1024.0}]
}

set report {}
proc out {line} {
    global report
    puts $line
    flush stdout
    append report $line \n
}

proc environment {} {
    global root recovers options
    out "# Syntax recovery: performance\n"
    out "Generated by `tclsh9.0 bench/syntax-recovery.tcl[expr {[dict get $options -root] eq "" ? "" : " -root DIR"}]` (SYNTAX-RECOVERY-MILESTONE-1.md, \"Performance\").\n"
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
    hir::interchange::fingerprint
    out "- revision `$revision` ([expr {$recovers ? "syntax recovery" : "no syntax recovery: the baseline"}]); Tcl [info patchlevel]; $::tcl_platform(os) $::tcl_platform(machine); $cores x $cpu"
    out "- repeat [dict get $options -repeat]; workloads [dict get $options -workloads]; median of the repeats; milliseconds unless a column says µs\n"
}

# The text of FILE (in DIR) with every edit of EDITS that names it applied.
proc edited {dir file edits} {
    set text [surface::source::text [file join $dir $file]]
    foreach edit $edits {
        lassign $edit f needle replacement
        if {$f ne $file} continue
        set at [string first $needle $text]
        if {$at < 0} {
            error "edit of $file: no \"$needle\""
        }
        set text [string replace $text $at [expr {$at + [string length $needle] - 1}] $replacement]
    }
    return $text
}

proc forget {path} {
    foreach key [dict keys $::surface::modules::parsed] {
        if {[lindex $key 0] eq $path} {
            dict unset ::surface::modules::parsed $key
        }
    }
}

# Applies EDITS to workspace WS as unsaved buffers; returns the paths.
proc buffers {ws dir edits} {
    set paths {}
    foreach file [lsort -unique [lmap e $edits {lindex $e 0}]] {
        set path [file join $dir $file]
        service::setDocument $ws $path [edited $dir $file $edits]
        lappend paths $path
    }
    return $paths
}

proc builds {} {
    if {[info exists ::hir::buildStats]} {
        return [dict get $::hir::buildStats builds]
    }
    return 0
}

# --- parse ------------------------------------------------------------------

proc parse {} {
    global root N recovers
    out "## Parsing\n"
    out "One file's text: the strict parse (surface::parse); with syntax errors written into it, the recovering parse (surface::parse -recover 1, which also computes the damage) and the recovery of the tree (surface::recover::apply). Microseconds.\n"
    out "| file | lines | strict parse | 1 error: parse | 1 error: recovery | 3 errors: parse | 3 errors: recovery |\n|---|---:|---:|---:|---:|---:|---:|"
    foreach rel {examples/stdlib/csv.bot examples/games/2048/game2048.bot examples/games/icy-tower/tower.bot
            examples/games/2048/golden.bot tests/golden/mutable-array.bot} {
        set path [file join $root $rel]
        set text [surface::source::text $path]
        set lines [split $text \n]
        set row [list [file tail $rel] [llength $lines]]
        lappend row [fmt [median [lmap i [lrepeat $N 0] {us {surface::parse $text $path}}]]]
        # Syntax errors: an unfinished expression at the end of the first
        # indented binding past the middle of the file (then past 1/4 and
        # 3/4 of it).
        set damaged $lines
        set errors 0
        foreach fraction {0.5 0.25 0.75} {
            for {set l [expr {int([llength $damaged] * $fraction)}]} {$l < [llength $damaged]} {incr l} {
                set line [lindex $damaged $l]
                if {[regexp {^\s+[a-z_]+ = [^:#"]*[a-z0-9)\]]$} $line]} {
                    lset damaged $l "$line +"
                    break
                }
            }
            incr errors
            if {$errors == 1} {
                set one [join $damaged \n]
            }
        }
        set three [join $damaged \n]
        foreach source [list $one $three] {
            if {!$recovers} {
                lappend row - -
                continue
            }
            lappend row [fmt [median [lmap i [lrepeat $N 0] {us {set ast [surface::parse $source $path -recover 1]}}]]]
            lappend row [fmt [median [lmap i [lrepeat $N 0] {us {surface::recover::apply $ast $source}}]]]
        }
        out "| [join $row { | }] |"
    }
    out ""
}

# --- analysis ---------------------------------------------------------------

proc analysis {} {
    global workloads options N
    out "## Analysis\n"
    out "service::analyze in a warm process, the edited files' cached ASTs dropped before each repeat. Each cell: milliseconds, then the whole-program builds of one analysis, the outcome and the semantics (`ok`/`syntax`, `full`/`partial`/`none`).\n"
    set scenarios {valid entry module transitive several}
    out "| workload | [join $scenarios { | }] |\n|---|[string repeat ---:| [llength $scenarios]]"
    foreach name [dict get $options -workloads] {
        set w [dict get $workloads $name]
        set dir [dict get $w dir]
        set entry [file join $dir [dict get $w entry]]
        set ws [service::workspace -warnings off -cache ""]
        set ::surface::modules::parsed [dict create]
        # Warm: the standard library's modules parsed once.
        service::release [service::analyze $ws $entry]
        set row {}
        foreach scenario $scenarios {
            if {$scenario ne "valid" && ![dict exists $w edits $scenario]} {
                lappend row -
                continue
            }
            set edits [if {$scenario eq "valid"} {list} else {dict get $w edits $scenario}]
            set paths [buffers $ws $dir $edits]
            set samples {}
            for {set i 0} {$i < $N} {incr i} {
                foreach path [concat $paths [list $entry]] {
                    forget $path
                }
                set b0 [builds]
                lappend samples [ms {set rev [service::analyze $ws $entry]}]
                set built [expr {[builds] - $b0}]
                set info [service::revision $rev]
                service::release $rev
            }
            foreach path $paths {
                service::clearDocument $ws $path
            }
            lappend row "[fmt [median $samples]] ($built, [dict get $info outcome][expr {[dict exists $info semantics] ? "/[dict get $info semantics]" : ""}])"
        }
        service::closeWorkspace $ws
        out "| $name | [join $row { | }] |"
    }
    out ""
}

# --- typing -----------------------------------------------------------------

proc typing {} {
    global root
    out "## Typing a statement\n"
    set statement {        partial = scores.get(i, 0) * 2 + std::list::length(scores)}
    out "`$statement` typed into `total` of game2048.bot (before its `scores.get(i, 0) + from(i + 1)`), one character at a time; every version analyzed once (the 2048 demo, a transitive dependency of its entry, and the golden suite, which imports it). Milliseconds.\n"
    set module [file join $root examples games 2048 game2048.bot]
    set original [surface::source::text $module]
    set needle {        scores.get(i, 0) + from(i + 1)}
    set at [string first $needle $original]
    out "| program | versions | parse: median | parse: max | do not parse: median | do not parse: max | do not parse: outcome |\n|---|---:|---:|---:|---:|---:|---|"
    foreach entryFile {demo.bot golden.bot} {
        set entry [file join $root examples games 2048 $entryFile]
        set ws [service::workspace -warnings off -cache ""]
        service::release [service::analyze $ws $entry]
        set good {}
        set bad {}
        set outcomes {}
        for {set n 1} {$n <= [string length $statement]} {incr n} {
            set typed "[string range $statement 0 $n-1]\n"
            service::setDocument $ws $module "[string range $original 0 $at-1]$typed[string range $original $at end]"
            forget $module
            set t [ms {set rev [service::analyze $ws $entry]}]
            set info [service::revision $rev]
            if {[dict get $info outcome] eq "syntax"} {
                lappend bad $t
                dict incr outcomes "syntax/[dict getdef $info semantics -]"
            } else {
                lappend good $t
            }
            service::release $rev
        }
        service::closeWorkspace $ws
        set g [stats $good]
        set b [stats $bad]
        out "| $entryFile | [expr {[llength $good] + [llength $bad]}] | [fmt [dict get $g median]] | [fmt [dict get $g max]] | [fmt [dict get $b median]] | [fmt [dict get $b max]] | [join [lmap {k v} $outcomes {list $k $v}] {, }] |"
    }
    out ""
}

# --- transfer ---------------------------------------------------------------

proc transfer {} {
    global workloads options N
    out "## Worker transfer\n"
    out "service::export of a revision and service::import of its text into another workspace, as the language server's worker and server do: the complete program, and the program with its first edit (the transitive one where there is one). Milliseconds, and the text's size in KiB.\n"
    out "| workload | complete: export | import | KiB | recovered: export | import | KiB |\n|---|---:|---:|---:|---:|---:|---:|"
    foreach name [dict get $options -workloads] {
        set w [dict get $workloads $name]
        set dir [dict get $w dir]
        set entry [file join $dir [dict get $w entry]]
        set ws [service::workspace -warnings off -cache ""]
        set target [service::workspace -warnings off -cache ""]
        set row {}
        foreach scenario {valid recovered} {
            set paths {}
            if {$scenario eq "recovered"} {
                set pick [lindex [lmap s {transitive module entry} {if {[dict exists $w edits $s]} {set s} else continue}] 0]
                set paths [buffers $ws $dir [dict get $w edits $pick]]
            }
            set rev [service::analyze $ws $entry]
            set exports {}
            set imports {}
            for {set i 0} {$i < $N} {incr i} {
                lappend exports [ms {set text [service::export $rev]}]
                lappend imports [ms {set copy [service::import $target $text]}]
                service::release $copy
            }
            lappend row [fmt [median $exports]] [fmt [median $imports]] [fmt [expr {[string length [encoding convertto utf-8 $text]] / 1024.0}]]
            service::release $rev
            foreach path $paths {
                service::clearDocument $ws $path
            }
        }
        service::closeWorkspace $ws
        service::closeWorkspace $target
        out "| $name | [join $row { | }] |"
    }
    out ""
}

# --- memory -----------------------------------------------------------------

proc memory {} {
    global root
    out "## Memory\n"
    out "Ten revisions of the 2048 golden suite retained at once, each a different unsaved edit of game2048.bot -- a comment (complete), or the same comment and an unfinished expression (recovered) -- then released; the resident set they add, in MiB, after one revision of the kind analyzed and released (Tcl reuses freed memory, so each kind is measured in a fresh process).\n"
    out "| revisions | MiB added | per revision |\n|---|---:|---:|"
    foreach kind {complete recovered} {
        set script [string map [list @ROOT@ $root @KIND@ $kind] {
            source [file join @ROOT@ service service.tcl]
            proc rss {} {
                set f [open /proc/self/status]
                regexp {VmRSS:\s+(\d+)} [read $f] -> kb
                close $f
                return [expr {$kb / 1024.0}]
            }
            set entry [file join @ROOT@ examples games 2048 golden.bot]
            set module [file join @ROOT@ examples games 2048 game2048.bot]
            set original [surface::source::text $module]
            set ws [service::workspace -warnings off -cache ""]
            proc text {k} {
                global original
                set t "$original\n# kept $k\n"
                if {"@KIND@" eq "recovered"} {
                    set t [string map [list "            return 0" "            return 0 +"] $t]
                }
                return $t
            }
            service::setDocument $ws $module [text 0]
            service::release [service::analyze $ws $entry]
            set before [rss]
            set kept {}
            for {set k 1} {$k <= 10} {incr k} {
                service::setDocument $ws $module [text $k]
                lappend kept [service::analyze $ws $entry]
            }
            puts [expr {[rss] - $before}]
        }]
        set f [file tempfile path]
        puts $f $script
        close $f
        set added [string trim [exec [info nameofexecutable] $path]]
        file delete $path
        out "| $kind | [fmt $added] | [fmt [expr {$added / 10.0}]] |"
    }
    out ""
}

environment
foreach section [dict get $options -sections] {
    switch -- $section {
        parse { parse }
        analysis { analysis }
        typing { typing }
        transfer { transfer }
        memory { memory }
        default { error "unknown section $section" }
    }
}
file delete -force $chainDir
if {[dict get $options -out] ne ""} {
    writeFile [dict get $options -out] $report
}
