# mutate.tcl -- can the SAME-FAILURE checks fail?
# (WARNINGS-SAME-FAILURE.md, "Mutation testing"). Each mutant is a small,
# local break of the pass, applied to a scratch copy of the tree (never to the
# working tree). For each, the fuzzer runs over SEEDS seeds, and the mutants it
# does not kill run tests/same-failure.test (the unit tests own what the fuzzer
# does not generate, and what only a trace can see).
#
#   tclsh9.0 audit/same-failure/tools/mutate.tcl ?SEEDS? ?MUTANT-PATTERN?
#
# Output: one line per mutant, `killed by fuzz`, `killed by unit tests` or
# `SURVIVED`. Exits non-zero if a mutant survives.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 40}]
set only [expr {[llength $argv] > 1 ? [lindex $argv 1] : "*"}]

# The pass's own lines the mutants replace (each must occur exactly once in
# hir/warnings.tcl).
set siteLoop "    set sites {}\n    foreach e \[BodyExprs \$hir \$block\] \{\n"
set siteTest "        if \{\[dict get \$node kind\] eq \"fail\" && \[dict get \$node reachable\]\n                && \[dict get \$node name\] in \$declared\} \{\n            lappend sites \[list \$e \[dict get \$node name\]\]\n"
set threshold "        if \{\[llength \$members\] >= 2\} \{\n            lappend warnings \[FailureWarning"

# A prologue for the site loop that collects the fails of handler bodies
# (inHandler) and, among them, the re-raises (a fail of the name its handler
# handles).
set handlerScan {    set inHandler [dict create]
    set reraise [dict create]
    foreach h [BodyExprs $hir $block] {
        if {[dict get $hir exprs $h kind] ne "handle"} continue
        foreach hname [dict get $hir exprs $h handlerNames] hbody [dict get $hir exprs $h handlerBodies] {
            foreach x $hbody {
                set acc {}
                BodyInto $hir $x acc
                foreach y $acc {
                    dict set inHandler $y 1
                    if {[dict get $hir exprs $y kind] eq "fail" && [dict get $hir exprs $y name] eq $hname} {
                        dict set reraise $y 1
                    }
                }
            }
        }
    }
}

# {NAME FILE OLD NEW}: OLD must occur exactly once in FILE. The first eleven
# are the milestone's required kill list; the rest are extra.
set mutants [list \
    [list grouping-disabled hir/warnings.tcl \
        {            lappend warnings [FailureWarning $hir $block $name $failure $members]} \
        {            foreach member $members {lappend warnings [FailureWarning $hir $block $name $failure [list $member]]}}] \
    [list single-fail-threshold-dropped hir/warnings.tcl \
        $threshold \
        [string map {">= 2" ">= 1"} $threshold]] \
    [list dead-fails-counted hir/warnings.tcl \
        $siteTest \
        [string map {" && \[dict get \$node reachable\]" ""} $siteTest]] \
    [list walk-pruning-removed hir/warnings.tcl \
        "        if \{!\[dict exists \$reached \[lindex \$site 0\]\]\} \{\n            continue\n        \}\n" \
        ""] \
    [list handler-body-fails-ignored hir/warnings.tcl \
        $siteLoop \
        "$handlerScan$siteLoop        if \{\[dict exists \$inHandler \$e\]\} continue\n"] \
    [list nested-function-fails-grouped hir/warnings.tcl \
        $siteLoop \
        "    set sites {}\n    set all {}\n    foreach b \[dict get \$hir exprs \$block body\] \{hir::WalkInto \$hir \$b all\}\n    foreach e \$all \{\n"] \
    [list different-failures-grouped hir/warnings.tcl \
        {        dict lappend groups $failure $e} \
        {        dict lappend groups [lindex $sites 0 1] $e}] \
    [list returns-grouped-with-fails hir/warnings.tcl \
        $siteTest \
        "        if \{\[dict get \$node kind\] in \{fail return\} && \[dict get \$node reachable\]\n                && (\[dict get \$node kind\] eq \"return\" || \[dict get \$node name\] in \$declared)\} \{\n            lappend sites \[list \$e \[expr \{\[dict get \$node kind\] eq \"return\" ? \[lindex \$declared 0\] : \[dict get \$node name\]\}\]\]\n"] \
    [list candidate-gate-broken hir/warnings.tcl \
        {    if {![HasRepeat [FailureGroups $sites]]} } \
        {    if {0} }] \
    [list instances-visited hir/warnings.tcl \
        {        lappend warnings {*}[SameFailureIn $hir $e [expr {[dict exists $names $e] ? [dict get $names $e] : ""}]]} \
        {        lappend warnings {*}[lrepeat [expr {1 + ([dict exists $hir semantic byBlock $e] ? [dict get $hir semantic byBlock $e] : 0)}] {*}[SameFailureIn $hir $e [expr {[dict exists $names $e] ? [dict get $names $e] : ""}]]]}] \
    [list re-raise-ignored hir/warnings.tcl \
        $siteLoop \
        "$handlerScan$siteLoop        if \{\[dict exists \$reraise \$e\]\} continue\n"] \
    [list similar-names-grouped hir/warnings.tcl \
        {        dict lappend groups $failure $e} \
        {        dict lappend groups [string range $failure 0 2] $e}] \
    [list unresolved-name-accepted hir/warnings.tcl \
        $siteTest \
        [string map {"\n                && \[dict get \$node name\] in \$declared" ""} $siteTest]] \
    [list unreachable-functions-walked hir/warnings.tcl \
        "        if \{\[dict get \$node kind\] ne \"block\" || !\[dict get \$node reachable\]\} \{\n            continue\n        \}\n        lappend warnings \{*\}\[SameFailureIn" \
        "        if \{\[dict get \$node kind\] ne \"block\"\} \{\n            continue\n        \}\n        lappend warnings \{*\}\[SameFailureIn"] \
]

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

set scratch [file tempdir same-failure-mutants]
set survivors 0
foreach mutant $mutants {
    lassign $mutant name file old new
    if {![string match $only $name]} continue
    set tree [file join $scratch $name]
    file mkdir $tree
    # A copy of the tree; the (large) native build is shared, not copied.
    exec tar -C $root --exclude=./native/target --exclude=./.git -cf - . | tar -C $tree -xf -
    file link -symbolic [file join $tree native target] [file join $root native target]
    set path [file join $tree $file]
    set text [readText $path]
    set at [string first $old $text]
    if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
        puts "$name: the mutation does not apply exactly once to $file"
        incr survivors
        file delete -force $tree
        continue
    }
    writeText $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    catch {exec [info nameofexecutable] [file join $tree audit same-failure tools fuzz.tcl] $seeds 1 2>@1} full
    # The fuzzer's summary, wherever it is in what it printed (a failing run
    # makes exec raise, with the output as the message).
    set summary "no summary: [string range [lindex [split [string trim $full] \n] end] 0 100]"
    regexp -line {^seeds [0-9]+ \(from 1\):[^;]*; failures [0-9]+; extra warnings [0-9]+} $full summary
    regexp {failures ([0-9]+); extra warnings ([0-9]+)} $summary -> failures extras
    if {![info exists failures] || $failures > 0 || $extras > 0} {
        set status "killed by fuzz ($summary)"
    } else {
        set unit [catch {exec [info nameofexecutable] [file join $tree tests same-failure.test] -tmpdir [file join $tree tcltest] 2>@1} unitOut]
        regexp {Total\t([0-9]+)\tPassed\t([0-9]+)\tSkipped\t([0-9]+)\tFailed\t([0-9]+)} $unitOut -> total passed skipped unitFailed
        set failing [regexp -all -inline -line {^==== (sf-[^ ]+) FAILED$} $unitOut]
        set failing [lsort -unique [lmap {- t} $failing {set t}]]
        if {[info exists unitFailed] && $unitFailed > 0} {
            set status "killed by unit tests ($unitFailed failing of $total: [join $failing {, }]; fuzz saw: $summary)"
        } else {
            set status "SURVIVED ($summary)"
            incr survivors
        }
        unset -nocomplain unitFailed
    }
    unset -nocomplain failures extras
    puts "[format %-31s $name] $status"
    file delete -force $tree
}
file delete -force $scratch
exit [expr {$survivors > 0}]
