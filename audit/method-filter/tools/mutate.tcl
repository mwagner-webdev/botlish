# mutate.tcl -- can the checks of the method-call decision's kind proofs
# fail? (METHOD-DECISION-FILTER.md, "Mutation testing"). Each mutant is a
# small, local break of the kind proofs in hir/methods.tcl or of the reference
# audit in hir/hir.tcl, applied to a scratch copy of the tree (never to the
# working tree). For each, the unit tests (tests/method-filter.test) run; the
# mutants they do not kill run the fuzzer over SEEDS seeds. (The decision's
# own mutants are audit/method-resolution/tools/mutate.tcl's.)
#
#   tclsh9.0 audit/method-filter/tools/mutate.tcl ?SEEDS? ?MUTANT-PATTERN?
#
# Output: one line per mutant, `killed by unit tests`, `killed by fuzz` or
# `SURVIVED`. Exits non-zero if a mutant survives or does not apply exactly
# once.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 8}]
set only [expr {[llength $argv] > 1 ? [lindex $argv 1] : "*"}]

# {NAME FILE OLD NEW}: OLD must occur exactly once in FILE.
set mutants [list \
    [list native-equal-kinds-excluded hir/methods.tcl \
        "    if \{\$wanted eq \"\" || \$kind eq \$wanted\} \{\n        return \{\}\n    \}" \
        "    if \{\$wanted eq \"\"\} \{\n        return \{\}\n    \}"] \
    [list bare-name-excluded hir/methods.tcl \
        "    if \{!\[regexp \{^(.+)::\[^:\]+\$\} \$cand -> ns\]\} \{\n        return 0\n    \}" \
        "    if \{!\[regexp \{^(.+)::\[^:\]+\$\} \$cand -> ns\]\} \{\n        return 1\n    \}"] \
    [list domain-kinds-compared hir/methods.tcl \
        "        if \{\$kind in \$comparableKinds && \$receiverKind in \$comparableKinds && \$kind ne \$receiverKind\} \{" \
        "        if \{\$kind ne \$receiverKind\} \{"] \
    [list checked-contract-ignored hir/methods.tcl \
        "foreach field \{declaredParamTypes inferredParamTypes checkedParamTypes\} \{" \
        "foreach field \{declaredParamTypes inferredParamTypes\} \{"] \
    [list inferred-contract-ignored hir/methods.tcl \
        "foreach field \{declaredParamTypes inferredParamTypes checkedParamTypes\} \{" \
        "foreach field \{declaredParamTypes checkedParamTypes\} \{"] \
    [list declared-contract-ignored hir/methods.tcl \
        "foreach field \{declaredParamTypes inferredParamTypes checkedParamTypes\} \{" \
        "foreach field \{inferredParamTypes checkedParamTypes\} \{"] \
    [list nominal-rule-dropped hir/methods.tcl \
        "    return \[NominalMismatch \[DeclaredParam \$hir \$ns \$cand\] \$R\]" \
        "    return 0"] \
    [list nominal-arguments-compared hir/methods.tcl \
        "        && \[lindex \$declared 1\] ne \[lindex \$R 1\]\}" \
        "        && \$declared ne \$R\}"] \
    [list nominal-same-declaration-excluded hir/methods.tcl \
        "        && \[lindex \$declared 1\] ne \[lindex \$R 1\]\}" \
        "        && 1\}"] \
    [list nominal-receiver-unchecked hir/methods.tcl \
        "    expr \{\[hir::types::IsNamedStruct \$declared\] && \[hir::types::IsNamedStruct \$R\]" \
        "    expr \{\[hir::types::IsNamedStruct \$declared\] && 1"] \
    [list nominal-inferred-compared hir/methods.tcl \
        "        set t \[lindex \[dict get \$hir exprs \$v declaredParamTypes\] 0\]\n" \
        "        set t \[lindex \[dict get \$hir exprs \$v declaredParamTypes\] 0\]\n        if \{\$t eq \"\" && \[dict exists \$hir exprs \$v inferredParamTypes\]\} \{ set t \[lindex \[dict get \$hir exprs \$v inferredParamTypes\] 0\] \}\n"] \
    [list kind-proofs-ignore-switch hir/methods.tcl \
        "    if \{!\$methodKindProofs && !\$guess\} \{\n        return \$candidates\n    \}" \
        "    if \{0\} \{\n        return \$candidates\n    \}"] \
    [list waves-move-nothing hir/methods.tcl \
        "            if \{\[llength \$guessed\] == 1 && \[dict get \$choices \$key\] ne \[lindex \$guessed 0\]\} \{" \
        "            if \{0 && \[llength \$guessed\] == 1 && \[dict get \$choices \$key\] ne \[lindex \$guessed 0\]\} \{"] \
    [list guess-ignored hir/methods.tcl \
        "    if \{\$guess\} \{\n        set node \[dict get \$hir exprs \$receiver\]" \
        "    if \{0\} \{\n        set node \[dict get \$hir exprs \$receiver\]"] \
    [list trait-calls-not-fixed hir/methods.tcl \
        "    dict for \{key chosen\} \[dict get \$record traits\] \{" \
        "    dict for \{key chosen\} \{\} \{"] \
    [list seeds-ignored hir/methods.tcl \
        "        if \{\[dict exists \$calls \$key\] && \$choice in \[dict get \$calls \$key candidates\]\} \{\n            dict set fixed" \
        "        if \{0\} \{\n            dict set fixed"] \
    [list wave-limit-ignored hir/methods.tcl \
        "for \{set wave 0\} \{\$wave < \$maxWaves\} \{incr wave\}" \
        "for \{set wave 0\} \{\$wave < 1000\} \{incr wave\}"] \
    [list deviations-not-counted hir/methods.tcl \
        "    if \{\$what eq \"deviation\"\} \{\n        dict incr ::hir::buildStats methodDeviations\n    \}" \
        "    if \{0\} \{\n        dict incr ::hir::buildStats methodDeviations\n    \}"] \
    [list audit-decisions-not-compared hir/hir.tcl \
        "        if \{\$a ne \$b\} \{\n            error \"hir::methodReferenceAudit: the decision's" \
        "        if \{0\} \{\n            error \"hir::methodReferenceAudit: the decision's"] \
    [list audit-programs-not-compared hir/hir.tcl \
        "    if \{\$decided ne \$reference\} \{\n        set where" \
        "    if \{0\} \{\n        set where"] \
    [list audit-reference-keeps-kind-proofs hir/hir.tcl \
        "    set methodKindProofs 0\n    hir::activate \$hir" \
        "    hir::activate \$hir"] \
    [list native-type-problem-lost hir/methods.tcl \
        "                set mismatch \[NativeMismatch \$native \[hir::typeOf \$hir \$receiver\]\]" \
        "                set mismatch \[expr \{\[hir::typeOf \$hir \$receiver\] eq \"never\" ? \"\" : \"\"\}\]"] \
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

set scratch [file tempdir method-filter-mutants]
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
        puts "[format %-31s $name] the mutation does not apply exactly once to $file"
        incr survivors
        file delete -force $tree
        continue
    }
    writeText $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    set unit [catch {exec [info nameofexecutable] [file join $tree tests method-filter.test] -tmpdir [file join $tree tcltest] 2>@1} unitOut]
    set unitFailed 0
    regexp {Total\t([0-9]+)\tPassed\t([0-9]+)\tSkipped\t([0-9]+)\tFailed\t([0-9]+)} $unitOut -> total passed skipped unitFailed
    if {$unit && $unitFailed == 0} {
        # (The file did not even run.)
        set unitFailed 1
        set failing "the test file raised an error"
    } else {
        set failing [lsort -unique [lmap {- t} [regexp -all -inline -line {^==== (mf-[^ ]+) FAILED$} $unitOut] {set t}]]
    }
    if {$unitFailed > 0} {
        set status "killed by unit tests ([join $failing {, }])"
    } else {
        catch {exec [info nameofexecutable] [file join $tree audit method-filter tools fuzz.tcl] $seeds 1 2>@1} full
        set summary "no summary: [string range [lindex [split [string trim $full] \n] end] 0 100]"
        regexp -line {^method-filter-fuzz .*disagreements [0-9]+} $full summary
        if {![regexp {disagreements ([0-9]+)} $summary -> disagreements] || $disagreements > 0
                || [regexp {raised|error:|DISAGREE} $full]} {
            set status "killed by fuzz ($summary)"
        } else {
            set status "SURVIVED ($summary)"
            incr survivors
        }
    }
    puts "[format %-31s $name] $status"
    file delete -force $tree
}
file delete -force $scratch
exit [expr {$survivors > 0}]
