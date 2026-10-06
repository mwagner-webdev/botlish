# mutate.tcl -- can the PROVES-NAMING checks fail?
# (WARNINGS-PROVES-NAMING.md, "Mutation testing"). Each mutant is a small,
# local break of the pass (or its registry line), applied to a scratch copy of
# the tree (never to the working tree). For each, the fuzzer runs over SEEDS
# seeds, and the mutants it does not kill run tests/proves-naming.test (the
# unit tests own what the fuzzer does not generate: HIR-text input, dead
# branches, traces).
#
#   tclsh9.0 audit/proves-naming/tools/mutate.tcl ?SEEDS? ?MUTANT-PATTERN?
#
# Output: one line per mutant, `killed by fuzz`, `killed by unit tests` or
# `SURVIVED`. Exits non-zero if a mutant survives.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 40}]
set only [expr {[llength $argv] > 1 ? [lindex $argv 1] : "*"}]

# The pass's own lines the mutants replace (each must occur exactly once in
# hir/warnings.tcl).
set guard {        if {[dict get $fn kind] ne "block" || ![dict exists $fn proofs] || [dict get $fn proofs] eq ""} {}
set count {    if {[llength [dict get $fn params]] - [llength $flags] != 1}
set shapes "        bool \{ return predicate \}\n        unit \{ return validator \}\n    \}\n    return \"\""
set question {        return [expr {[string index $name end] eq "?"}]}
set validator {    return [expr {$name eq "validate" || [string first validate_ $name] == 0}]}
set written "    if \{\[dict exists \$binding spelling\]\} \{\n        set name \[dict get \$binding spelling\]\n    \} else \{\n        regsub \{#\[0-9\]+\$\} \[dict get \$binding name\] \{\} name\n    \}\n    return \[MemberName \$name\]"
set append "        lappend warnings \[New PROVES-NAMING \\"

# {NAME FILE OLD NEW}: OLD must occur exactly once in FILE. The first eleven
# are the milestone's required kill list, in its order; the rest are extra.
set mutants [list \
    [list scope-guard-dropped hir/warnings.tcl \
        $guard \
        {        if {[dict get $fn kind] ne "block"} {}] \
    [list parameter-count-ignored hir/warnings.tcl \
        $count \
        {    if {0}}] \
    [list result-type-ignored hir/warnings.tcl \
        $shapes \
        "        unit \{ return validator \}\n    \}\n    return predicate"] \
    [list predicate-rule-on-unit hir/warnings.tcl \
        $shapes \
        "        bool \{ return predicate \}\n        unit \{ return predicate \}\n    \}\n    return \"\""] \
    [list validator-rule-on-bool hir/warnings.tcl \
        $shapes \
        "        bool \{ return validator \}\n        unit \{ return validator \}\n    \}\n    return \"\""] \
    [list bare-validate-rejected hir/warnings.tcl \
        $validator \
        {    return [expr {[string first validate_ $name] == 0}]}] \
    [list prefix-case-insensitive hir/warnings.tcl \
        $validator \
        {    return [expr {$name eq "validate" || [string match -nocase validate_* $name]}]}] \
    [list prefix-anywhere hir/warnings.tcl \
        $validator \
        {    return [expr {$name eq "validate" || [string first validate_ $name] >= 0}]}] \
    [list question-check-inverted hir/warnings.tcl \
        $question \
        {        return [expr {[string index $name end] ne "?"}]}] \
    [list hygiene-spelling-checked hir/warnings.tcl \
        $written \
        {    return [dict get $binding name]}] \
    [list instances-visited hir/warnings.tcl \
        $append \
        "        lappend warnings \{*\}\[lrepeat \[expr \{1 + (\[dict exists \$hir semantic byBlock \$block\] ? \[dict get \$hir semantic byBlock \$block\] : 0)\}\] {*}\[New PROVES-NAMING \\"] \
    [list registry-line-removed hir/warnings.tcl \
        "        PROVES-NAMING     hir::warnings::ProvesNaming\n" \
        ""] \
    [list prefix-without-underscore hir/warnings.tcl \
        $validator \
        {    return [expr {$name eq "validate" || [string first validate $name] == 0}]}] \
    [list empty-suffix-rejected hir/warnings.tcl \
        $validator \
        {    return [expr {$name eq "validate" || ([string first validate_ $name] == 0 && $name ne "validate_")}]}] \
    [list flags-counted hir/warnings.tcl \
        $count \
        {    if {[llength [dict get $fn params]] != 1}] \
    [list reachability-added hir/warnings.tcl \
        $guard \
        {        if {[dict get $fn kind] ne "block" || ![dict get $fn reachable] || ![dict exists $fn proofs] || [dict get $fn proofs] eq ""} {}] \
    [list qualified-name-checked hir/warnings.tcl \
        "    return \[MemberName \$name\]" \
        "    return \$name"] \
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

set scratch [file tempdir proves-naming-mutants]
set survivors 0
foreach mutant $mutants {
    lassign $mutant name file old new
    if {![string match $only $name]} continue
    set tree [file join $scratch $name]
    file mkdir $tree
    # A copy of the tree (without agent worktrees under .claude); the (large)
    # native build is shared, not copied.
    exec tar -C $root --exclude=./native/target --exclude=./.git --exclude=./.claude -cf - . | tar -C $tree -xf -
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
    catch {exec [info nameofexecutable] [file join $tree audit proves-naming tools fuzz.tcl] $seeds 1 2>@1} full
    # The fuzzer's summary, wherever it is in what it printed (a failing run
    # makes exec raise, with the output as the message).
    set summary "no summary: [string range [lindex [split [string trim $full] \n] end] 0 100]"
    regexp -line {^seeds [0-9]+ \(from 1\):[^;]*; failures [0-9]+; extra warnings [0-9]+; renames [0-9]+ of [0-9]+; law failures [0-9]+} $full summary
    regexp {failures ([0-9]+); extra warnings ([0-9]+)} $summary -> failures extras
    if {![info exists failures] || $failures > 0 || $extras > 0} {
        set status "killed by fuzz ($summary)"
    } else {
        set unit [catch {exec [info nameofexecutable] [file join $tree tests proves-naming.test] -tmpdir [file join $tree tcltest] -skip pn-fuzz-smoke 2>@1} unitOut]
        regexp {Total\t([0-9]+)\tPassed\t([0-9]+)\tSkipped\t([0-9]+)\tFailed\t([0-9]+)} $unitOut -> total passed skipped unitFailed
        set failing [regexp -all -inline -line {^==== (pn-[^ ]+) FAILED$} $unitOut]
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
    puts "[format %-27s $name] $status"
    file delete -force $tree
}
file delete -force $scratch
exit [expr {$survivors > 0}]
