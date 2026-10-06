# mutate.tcl -- can the FIXED-ARITY-LIST-RETURN checks fail?
# (WARNINGS-FIXED-ARITY-LIST-RETURN.md, "Mutation testing"). Each mutant is a
# one-line break of the pass, applied to a scratch copy of the tree (never to
# the working tree). For each, the fuzzer runs over SEEDS seeds, and the
# mutants it does not kill run tests/fixed-arity-list-return.test (the unit
# tests own what the fuzzer does not generate).
#
#   tclsh9.0 audit/fixed-arity-list-return/tools/mutate.tcl ?SEEDS? ?MUTANT-PATTERN?
#
# Output: one line per mutant, `killed by fuzz`, `killed by unit tests` or
# `SURVIVED`. Exits non-zero if a mutant survives.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 40}]
set only [expr {[llength $argv] > 1 ? [lindex $argv 1] : "*"}]

# {NAME FILE OLD NEW}: OLD must occur exactly once in FILE. The first nine are
# the milestone's required kill list; the last three are extra.
set mutants [list \
    [list unit-exit-skipped hir/warnings.tcl \
        "                # fixed-arity result.\n                return \"\"\n" \
        "                # fixed-arity result.\n                continue\n"] \
    [list alias-exits-ignored hir/warnings.tcl \
        {            set n [InitializerArity $hir $value]} \
        {            set n ""}] \
    [list self-call-ignored hir/warnings.tcl \
        "                return self\n" \
        "                return other\n"] \
    [list all-self-call-warned hir/warnings.tcl \
        "    if \{\$arity eq \"\"\} \{\n        return \"\"\n    \}\n    set count" \
        "    if \{\$arity eq \"\" && \$selfCalls eq \"\"\} \{\n        return \"\"\n    \}\n    set count"] \
    [list arity-one-allowed hir/warnings.tcl \
        {    variable minListArity 2} \
        {    variable minListArity 1}] \
    [list non-list-forms-literal hir/warnings.tcl \
        {if {[dict exists $node written] && [dict get $node written form] eq "list"} } \
        {if {[dict exists $node written] && [dict get $node written form] in {list function method}} }] \
    [list annotation-ignored hir/warnings.tcl \
        "    if \{\[DeclaresListResult \$hir \$block\]\} \{\n" \
        "    if \{0\} \{\n"] \
    [list reachability-ignored hir/warnings.tcl \
        "        if \{!\[dict exists \$reached \$site\]\} \{\n            continue\n        \}\n" \
        ""] \
    [list instances-visited hir/warnings.tcl \
        {            lappend warnings $warning} \
        {            lappend warnings {*}[lrepeat [expr {1 + ([dict exists $hir semantic byBlock $e] ? [dict get $hir semantic byBlock $e] : 0)}] $warning]}] \
    [list fall-through-not-enumerated hir/warnings.tcl \
        {        foreach site [FallThroughs $hir [lindex $body end]] } \
        {        foreach site {} }] \
    [list self-alias-not-followed hir/warnings.tcl \
        {    return [expr {[hir::resolve::CandidateIdentity hir [dict get $callee binding]] eq "binding:$self"}]} \
        {    return [expr {[dict get $callee binding] eq $self}]}] \
    [list mixed-arity-accepted hir/warnings.tcl \
        {                if {$n < $minListArity || ($arity ne "" && $n != $arity)} } \
        {                if {$n < $minListArity} }] \
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

set scratch [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] fixed-arity-mutants-[pid]]
file delete -force $scratch
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
    set first [string first $old $text]
    if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
        puts "$name: the mutation does not apply exactly once to $file"
        incr survivors
        file delete -force $tree
        continue
    }
    writeText $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
    catch {exec [info nameofexecutable] [file join $tree audit fixed-arity-list-return tools fuzz.tcl] $seeds 1 2>@1} full
    # The fuzzer's summary line, wherever it is in what it printed (a failing
    # run makes exec raise, with the output as the message).
    set summary "no summary: [string range [lindex [split [string trim $full] \n] end] 0 100]"
    regexp -line {^seeds [0-9]+ \(from 1\):.*$} $full summary
    regexp {failures ([0-9]+); extra warnings ([0-9]+)} $summary -> failures extras
    if {![info exists failures] || $failures > 0 || $extras > 0} {
        set status "killed by fuzz ($summary)"
    } else {
        set unit [catch {exec [info nameofexecutable] [file join $tree tests fixed-arity-list-return.test] -tmpdir [file join $tree tcltest] 2>@1} unitOut]
        regexp {Total\t([0-9]+)\tPassed\t([0-9]+)\tSkipped\t([0-9]+)\tFailed\t([0-9]+)} $unitOut -> total passed skipped unitFailed
        if {[info exists unitFailed] && $unitFailed > 0} {
            set status "killed by unit tests ($unitFailed failing of $total; fuzz saw: $summary)"
        } else {
            set status "SURVIVED ($summary)"
            incr survivors
        }
        unset -nocomplain unitFailed
    }
    unset -nocomplain failures extras
    puts "[format %-28s $name] $status"
    file delete -force $tree
}
file delete -force $scratch
exit [expr {$survivors > 0}]
