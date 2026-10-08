# mutate.tcl -- can the MANY-BOOLEAN-ARGUMENTS checks fail?
# (WARNINGS-MANY-BOOLEAN-ARGUMENTS.md, "Mutation testing"). Each mutant is a
# small, local break of the pass (or its registry line), applied to a scratch
# copy of the tree (never to the working tree). For each, the fuzzer runs over
# SEEDS seeds, and the mutants it does not kill run
# tests/many-boolean-arguments.test (the unit tests own what the fuzzer does
# not generate: a call whose argument count is not its declaration's, message
# wording).
#
#   tclsh9.0 audit/many-boolean-arguments/tools/mutate.tcl ?SEEDS? ?MUTANT-PATTERN?
#
# Output: one line per mutant, `killed by fuzz`, `killed by unit tests`,
# `SURVIVED`, or `BROKEN MUTANT` (the mutated tree did not run the fuzzer to
# its summary -- a tool failure, never counted as a kill). Exits non-zero if a
# mutant survives, is broken, or does not apply.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 40}]
set only [expr {[llength $argv] > 1 ? [lindex $argv 1] : "*"}]

# The pass's own lines the mutants replace. Each OLD must occur exactly once in
# hir/warnings.tcl. (Texts that open a brace they do not close are
# double-quoted.)
set guard "        if \{\[dict get \$node kind\] ne \"call\" || !\[dict exists \$node written\]
                || \[dict get \$node written form\] ni \{function method\} || !\[dict get \$node reachable\]\} \{"
set cheap "        if \{\[llength \[BoolLiteralPositions \$hir \[dict get \$node args\]\]\] < 2\} \{"
set gateLine "        if \{\$callee eq \"\" || \[dict get \$callee bools\] < 2 || \[dict get \$callee subjects\] < 1\} \{"
set threshold "        if \{\$count < 2\} \{"
set refCheck "        if \{\[dict get \$node kind\] ne \"ref\" || \[dict get \$node binding\] eq \"\"\} \{
            continue
        \}"
set rootCheck "        set binding \[dict get \$hir bindings \[dict get \$node binding\]\]
        if \{\[dict get \$binding kind\] eq \"root\" && \[dict get \$binding name\] in \{true false\}\} \{"
set ordinaryLine {    set ordinary [expr {[llength [dict get $fn params]] - [llength $flags]}]}
set typesLine {    set types [lrange [hir::signatures::entryTypes $hir $block] 0 [expr {$ordinary - 1}]]}
set calleeHead "    set callee \[dict get \$hir exprs \[dict get \$node callee\]\]
    if \{\[dict get \$callee kind\] ne \"ref\" || \[dict get \$callee binding\] eq \"\"\} \{
        return \"\"
    \}
    set argc"
set positionsLine "        set positions \[BoolLiteralPositions \$hir \\
            \[lrange \[dict get \$node args\] 0 \[expr \{\[dict get \$callee ordinary\] - 1\}\]\]\]
"
set message "            \"the call to `\$shown` passes \$count boolean literals; flags name options\" \\"
set head "proc hir::warnings::ManyBooleanArguments \{hir\} \{
    set warnings \{\}
"

# {NAME FILE {OLD NEW ...}}: each OLD must occur exactly once in FILE. The
# first fifteen are the milestone's required kill list, in its order (the
# reachability notion removed and added are two); the rest are extra.
set mutants [list \
    [list flags-counted hir/warnings.tcl [list \
        $ordinaryLine \
        {    set ordinary [llength [dict get $fn params]]}]] \
    [list subject-gate-dropped hir/warnings.tcl [list \
        $gateLine \
        "        if \{\$callee eq \"\" || \[dict get \$callee bools\] < 2\} \{"]] \
    [list non-bool-literals-counted hir/warnings.tcl [list \
        $refCheck \
        "        if \{\[dict get \$node kind\] eq \"const\"\} \{\n            lappend positions \$i\n            continue\n        \}\n$refCheck"]] \
    [list one-literal-fires hir/warnings.tcl [list \
        $cheap "        if \{\[llength \[BoolLiteralPositions \$hir \[dict get \$node args\]\]\] < 1\} \{" \
        $threshold "        if \{\$count < 1\} \{"]] \
    [list false-excluded hir/warnings.tcl [list \
        $rootCheck \
        "        set binding \[dict get \$hir bindings \[dict get \$node binding\]\]
        if \{\[dict get \$binding kind\] eq \"root\" && \[dict get \$binding name\] in \{true\}\} \{"]] \
    [list binding-reads-counted hir/warnings.tcl [list \
        $rootCheck \
        "        set binding \[dict get \$hir bindings \[dict get \$node binding\]\]
        set fact \[hir::exact::Of \$hir \$a\]
        if \{(\[dict get \$binding kind\] eq \"root\" && \[dict get \$binding name\] in \{true false\})
                || (\[lindex \$fact 0\] eq \"val\" && \[core::value::kind \[lindex \$fact 1\]\] eq \"bool\")\} \{"]] \
    [list computed-args-counted hir/warnings.tcl [list \
        $refCheck \
        "        if \{\[dict get \$node kind\] eq \"call\" && \[dict exists \$node written\] && \[dict get \$node written form\] eq \"operator\"\} \{\n            lappend positions \$i\n            continue\n        \}\n$refCheck"]] \
    [list synthesized-calls-counted hir/warnings.tcl [list \
        $guard \
        "        if \{\[dict get \$node kind\] ne \"call\" || !\[dict get \$node reachable\]\} \{"]] \
    [list function-value-callees-counted hir/warnings.tcl [list \
        $calleeHead \
        "    set callee \[dict get \$hir exprs \[dict get \$node callee\]\]
    if \{\[dict get \$callee kind\] ne \"ref\" || \[dict get \$callee binding\] eq \"\"\} \{
        set target \[expr \{\[dict exists \$node target\] ? \[dict get \$node target\] : \{\}\}\]
        if \{\[lindex \$target 0\] ne \"block\"\} \{
            return \"\"
        \}
        set fn \[dict get \$hir exprs \[lindex \$target 1\]\]
        set flags \[expr \{\[dict exists \$fn flags\] ? \[dict get \$fn flags\] : \{\}\}\]
        set n \[expr \{\[llength \[dict get \$fn params\]\] - \[llength \$flags\]\}\]
        return \[OptionShape \$target value \[lrange \[hir::signatures::entryTypes \$hir \[lindex \$target 1\]\] 0 \[expr \{\$n - 1\}\]\]\]
    \}
    set argc"]] \
    [list unprovable-params-counted hir/warnings.tcl [list \
        $typesLine \
        {    set types [lrange [lmap t [hir::signatures::entryTypes $hir $block] c [hir::signatures::checkedTypes $hir $block] {expr {$t ne {} ? $t : $c}}] 0 [expr {$ordinary - 1}]]}]] \
    [list instances-visited hir/warnings.tcl [list \
        "    return \$warnings\n\}\n\n# The argument positions" \
        "    if \{\[dict exists \$hir semantic instances\]\} \{\n        dict for \{id instance\} \[dict get \$hir semantic instances\] \{\n            foreach w \$warnings \{\n                if \{\[dict exists \$instance snapshot exprs \[dict get \$w data call\]\]\} \{\n                    lappend warnings \$w\n                \}\n            \}\n        \}\n    \}\n    return \$warnings\n\}\n\n# The argument positions"]] \
    [list reachability-removed hir/warnings.tcl [list \
        $guard \
        "        if \{\[dict get \$node kind\] ne \"call\" || !\[dict exists \$node written\]
                || \[dict get \$node written form\] ni \{function method\}\} \{"]] \
    [list reachability-added hir/warnings.tcl [list \
        "        set callee \[OptionCallee \$hir \$node\]\n" \
        "        set s \[dict get \$node scope\]
        while \{\$s ne \"\" && \[dict get \$hir scopes \$s kind\] ne \"block\"\} \{
            set s \[dict get \$hir scopes \$s parent\]
        \}
        if \{\$s ne \"\" && !\[dict exists \[hir::completions::reachedExprs \$hir \[dict get \$hir scopes \$s owner\]\] \$e\]\} \{
            continue
        \}
        set callee \[OptionCallee \$hir \$node\]\n"]] \
    [list registry-line-removed hir/warnings.tcl [list \
        "        MANY-BOOLEAN-ARGUMENTS  hir::warnings::ManyBooleanArguments\n" \
        ""]] \
    [list first-site-per-callee hir/warnings.tcl [list \
        $head "$head    set seen \[dict create\]\n" \
        "        set shown \[dict get \$callee shown\]\n        lappend warnings \[New MANY-BOOLEAN-ARGUMENTS" \
        "        if \{\[dict exists \$seen \[dict get \$callee target\]\]\} continue\n        dict set seen \[dict get \$callee target\] 1\n        set shown \[dict get \$callee shown\]\n        lappend warnings \[New MANY-BOOLEAN-ARGUMENTS"]] \
    [list aliases-not-followed hir/warnings.tcl [list \
        {    set identity [hir::resolve::CandidateIdentity hir [dict get $callee binding]]} \
        {    set identity [expr {[dict get $hir bindings [dict get $callee binding] kind] eq "root" ? "native:[dict get $hir bindings [dict get $callee binding] name]" : "binding:[dict get $callee binding]"}]}]] \
    [list receiver-excluded hir/warnings.tcl [list \
        $positionsLine \
        "$positionsLine        if \{\[dict get \$node written form\] eq \"method\"\} \{\n            set positions \[lmap p \$positions \{if \{\$p == 1\} continue; set p\}\]\n        \}\n"]] \
    [list natives-excluded hir/warnings.tcl [list \
        "        if \{!\[core::native::exists \$b\]\} \{" \
        "        if \{1\} \{"]] \
    [list arity-check-dropped hir/warnings.tcl [list \
        "    if \{\[dict get \$fn kind\] ne \"block\" || \$argc != \[llength \[dict get \$fn params\]\]\} \{" \
        "    if \{\[dict get \$fn kind\] ne \"block\"\} \{"]] \
    [list flag-spelling-printed hir/warnings.tcl [list \
        $message \
        "            \"the call to `\$shown` passes \$count boolean literals; flags name options: \[join \[lmap p \$positions \{string cat :arg \$p\}\] \{, \}\]\" \\"]] \
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

set scratch [file tempdir many-boolean-arguments-mutants]
set survivors 0
foreach mutant $mutants {
    lassign $mutant name file edits
    if {![string match $only $name]} continue
    set tree [file join $scratch $name]
    file mkdir $tree
    # A copy of the tree (without agent worktrees under .claude); the (large)
    # native build is shared, not copied.
    exec tar -C $root --exclude=./native/target --exclude=./.git --exclude=./.claude -cf - . | tar -C $tree -xf -
    file link -symbolic [file join $tree native target] [file join $root native target]
    set path [file join $tree $file]
    set text [readText $path]
    set applies 1
    foreach {old new} $edits {
        set at [string first $old $text]
        if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
            set applies 0
            break
        }
        set text [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    }
    if {!$applies} {
        puts "$name: the mutation does not apply exactly once to $file"
        incr survivors
        file delete -force $tree
        continue
    }
    writeText $path $text
    catch {exec [info nameofexecutable] [file join $tree audit many-boolean-arguments tools fuzz.tcl] $seeds 1 2>@1} full
    # The fuzzer's summary, wherever it is in what it printed (a failing run
    # makes exec raise, with the output as the message).
    set summary "no summary: [string range [lindex [split [string trim $full] \n] end] 0 100]"
    regexp -line {^seeds [0-9]+ \(from 1\):[^;]*; failures [0-9]+; extra warnings [0-9]+; conversion law [0-9]+ of [0-9]+ convert-now callees, failures [0-9]+} $full summary
    regexp {failures ([0-9]+); extra warnings ([0-9]+)} $summary -> failures extras
    if {![info exists failures]} {
        # The fuzzer did not run to its summary: a broken mutant (a syntax
        # error, say) is a tool failure, never a kill.
        set status "BROKEN MUTANT ($summary)"
        incr survivors
    } elseif {$failures > 0 || $extras > 0} {
        set status "killed by fuzz ($summary)"
    } else {
        set unit [catch {exec [info nameofexecutable] [file join $tree tests many-boolean-arguments.test] -tmpdir [file join $tree tcltest] -skip mb-fuzz-smoke 2>@1} unitOut]
        regexp {Total\t([0-9]+)\tPassed\t([0-9]+)\tSkipped\t([0-9]+)\tFailed\t([0-9]+)} $unitOut -> total passed skipped unitFailed
        set failing [regexp -all -inline -line {^==== (mb-[^ ]+) FAILED$} $unitOut]
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
