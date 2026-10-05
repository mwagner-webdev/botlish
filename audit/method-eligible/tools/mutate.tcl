# mutate.tcl -- can the METHOD-ELIGIBLE checks fail? (WARNINGS-METHOD-ELIGIBLE.md,
# "Fuzzing"). Each mutant is a one-line break of the warning pass or of the
# `nomethod` resolution, applied to a scratch copy of the tree (never to the
# working tree). For each, the fuzzer runs over SEEDS seeds, and the mutants it
# does not kill run tests/method-eligible.test (the unit tests own the cases
# the fuzzer deliberately does not generate: shadowing, field-named functions).
#
#   tclsh9.0 audit/method-eligible/tools/mutate.tcl ?SEEDS?
#
# Output: one line per mutant, `killed by fuzz`, `killed by unit tests` or
# `SURVIVED`. Exits non-zero if a mutant survives.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 40}]

# {NAME FILE OLD NEW}: OLD must occur exactly once in FILE.
set mutants [list \
    [list operator-receivers hir/warnings.tcl \
        "                list     \{ return list \}\n" \
        "                list     \{ return list \}\n                operator \{ return operator \}\n"] \
    [list one-parameter-rule hir/warnings.tcl \
        {[dict get $callee params] < 2} {[dict get $callee params] < 1}] \
    [list ignore-reachability hir/warnings.tcl \
        " || !\[dict get \$node reachable\]\n" "\n"] \
    [list warn-on-sugar hir/warnings.tcl \
        {[dict get $node written form] ne "function"} {[dict get $node written form] eq "never"}] \
    [list ignore-nomethod hir/resolve.tcl \
        {return [dict exists $hir bindings [string range $identity 8 end] nomethod]} {return 0}] \
    [list receiver-forms-everything hir/warnings.tcl \
        "    switch -- \[dict get \$node kind\] \{\n        ref     \{" \
        "    return literal\n    switch -- \[dict get \$node kind\] \{\n        ref     \{"] \
    [list candidate-check-skipped hir/warnings.tcl \
        {        if {![SugarResolvesTo $view $node $callee]} {
            continue
        }
} {}] \
    [list field-check-skipped hir/warnings.tcl \
        {        if {![SugarFieldSafe $hir $receiver [dict get $callee method] [dict get $node written ns] $fields]} {
            continue
        }
} {}] \
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

set scratch [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] method-eligible-mutants-[pid]]
file delete -force $scratch
set survivors 0
foreach mutant $mutants {
    lassign $mutant name file old new
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
        continue
    }
    writeText $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
    set status killed-by-nothing
    catch {exec [info nameofexecutable] [file join $tree audit method-eligible tools fuzz.tcl] $seeds 1 2>@1} full
    # The fuzzer's summary line, wherever it is in what it printed (a failing
    # run makes exec raise, with the output as the message).
    set summary "no summary: [string range [lindex [split [string trim $full] \n] end] 0 100]"
    regexp -line {^seeds [0-9]+ \(from 1\):.*$} $full summary
    regexp {failures ([0-9]+); extra warnings ([0-9]+)} $summary -> failures extras
    if {![info exists failures] || $failures > 0 || $extras > 0} {
        set status "killed by fuzz ($summary)"
    } else {
        # The fuzzer does not generate shadowing or field-named functions:
        # the unit tests must kill what it cannot.
        set unit [catch {exec [info nameofexecutable] [file join $tree tests method-eligible.test] 2>@1} unitOut]
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
    puts "[format %-26s $name] $status"
    file delete -force $tree
}
file delete -force $scratch
exit [expr {$survivors > 0}]
