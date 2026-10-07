# mutate.tcl -- can the ONE-CHAR-STRING-LITERAL checks fail?
# (WARNINGS-ONE-CHAR-STRING-LITERAL.md, "Mutation testing"). Each mutant is a
# small, local break of the pass (or its registry line), applied to a scratch
# copy of the tree (never to the working tree). For each, the fuzzer runs over
# SEEDS seeds, and the mutants it does not kill run
# tests/one-char-string-literal.test (the unit tests own what the fuzzer does
# not generate: HIR-text input, several semantic instances of one literal,
# message wording).
#
#   tclsh9.0 audit/one-char-string-literal/tools/mutate.tcl ?SEEDS? ?MUTANT-PATTERN?
#
# Output: one line per mutant, `killed by fuzz`, `killed by unit tests`,
# `SURVIVED`, or `BROKEN MUTANT` (the mutated tree did not run the fuzzer to
# its summary -- a tool failure, never counted as a kill). Exits non-zero if a
# mutant survives or is broken.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set seeds [expr {[llength $argv] > 0 ? [lindex $argv 0] : 40}]
set only [expr {[llength $argv] > 1 ? [lindex $argv 1] : "*"}]

# The pass's own lines the mutants replace (each must occur exactly once in
# hir/warnings.tcl). `computed-string-warned` evaluates a native call whose
# arguments are exactly known (the "heroic proving" the warning must never do);
# `character-literal-warned` drops the kind check and measures a character
# literal as the one-character String of its scalar (so it warns, rather than
# crashing str::length);
# `first-site-per-value` also declares its `seen` dict (below). (Texts that open
# a brace they do not close are double-quoted.)
set guard "        if \{\[dict get \$node kind\] ne \"const\" || \[dict exists \$keys \$e\]\} \{"
set kind "        if \{\[lindex \$fact 0\] ne \"val\" || \[core::value::kind \[lindex \$fact 1\]\] ne \"str\"\} \{"
set length "        if \{\[core::value::intOf \[core::strings::length \$value\]\] != 1\} \{"
set exact {        set fact [hir::exact::Of $hir $e]}
set message "            \"the String literal `\[core::value::show \$value\]` is one character long; a single character is written as a character literal\" \\"
set returned "        lappend warnings \[New ONE-CHAR-STRING-LITERAL \\"

# {NAME FILE OLD NEW}: OLD must occur exactly once in FILE. The first ten are
# the milestone's required kill list, in its order; the rest are extra.
set mutants [list \
    [list empty-string-warned hir/warnings.tcl \
        $length \
        "        if \{\[core::value::intOf \[core::strings::length \$value\]\] > 1\} \{"] \
    [list two-characters-warned hir/warnings.tcl \
        $length \
        "        if \{\[core::value::intOf \[core::strings::length \$value\]\] ni \{1 2\}\} \{"] \
    [list at-least-one-character hir/warnings.tcl \
        $length \
        "        if \{\[core::value::intOf \[core::strings::length \$value\]\] < 1\} \{"] \
    [list character-literal-warned hir/warnings.tcl \
        "$kind\n            continue\n        \}\n        set value \[lindex \$fact 1\]\n" \
        "        if \{\[lindex \$fact 0\] ne \"val\" || \[core::value::kind \[lindex \$fact 1\]\] ni \{str UnicodeChar\}\} \{\n            continue\n        \}\n        set value \[lindex \$fact 1\]\n        if \{\[core::value::kind \$value\] eq \"UnicodeChar\"\} \{\n            set value \[core::value::str \[format %c \[core::value::charOf \$value\]\]\]\n        \}\n"] \
    [list use-site-read-warned hir/warnings.tcl \
        $guard \
        "        if \{\[dict get \$node kind\] ni \{const ref\} || \[dict exists \$keys \$e\]\} \{"] \
    [list computed-string-warned hir/warnings.tcl \
        "$guard\n            continue\n        \}\n$exact" \
        "        if \{\[dict get \$node kind\] ni \{const call\} || \[dict exists \$keys \$e\]\} \{\n            continue\n        \}
        set fact \[hir::exact::Of \$hir \$e\]
        if \{\$fact eq \"\" && \[dict get \$node kind\] eq \"call\" && \[lindex \[dict get \$node target\] 0\] eq \"native\"
                && \[core::native::exists \[dict get \$hir symbols \[lindex \[dict get \$node target\] 1\] name\]\]\} \{
            set argValues \[lmap a \[dict get \$node args\] \{
                set f \[hir::exact::Of \$hir \$a\]
                expr \{\[lindex \$f 0\] eq \"int\" ? \[core::value::int \[lindex \$f 1\]\] : \[lindex \$f 0\] eq \"val\" ? \[lindex \$f 1\] : \"\"\}
            \}\]
            if \{\"\" ni \$argValues && !\[catch \{core::native::invoke \[core::value::native \[dict get \$hir symbols \[lindex \[dict get \$node target\] 1\] name\]\] \$argValues\} v\]\} \{
                if \{\[lindex \$v 0\] eq \"value\"\} \{
                    set fact \[list val \[lindex \$v 1\]\]
                \}
            \}
        \}"] \
    [list raw-spelling-counted hir/warnings.tcl \
        $length \
        "        set span \[lrange \[dict get \$node origin\] 2 end\]
        if \{\[lindex \[dict get \$node origin\] 0\] ne \"file\" || \[dict get \$span end\] - \[dict get \$span start\] - 2 != 1\} \{"] \
    [list instances-visited hir/warnings.tcl \
        "    return \$warnings\n\}\n\n# The const ExprIds" \
        "    if \{\[dict exists \$hir semantic instances\]\} \{\n        dict for \{id instance\} \[dict get \$hir semantic instances\] \{\n            foreach w \$warnings \{\n                if \{\[dict exists \$instance snapshot exprs \[dict get \$w data site\]\]\} \{\n                    lappend warnings \$w\n                \}\n            \}\n        \}\n    \}\n    return \$warnings\n\}\n\n# The const ExprIds"] \
    [list registry-line-removed hir/warnings.tcl \
        "        ONE-CHAR-STRING-LITERAL hir::warnings::OneCharStringLiteral\n" \
        ""] \
    [list reachability-added hir/warnings.tcl \
        $guard \
        "        if \{\[dict get \$node kind\] ne \"const\" || !\[dict get \$node reachable\] || \[dict exists \$keys \$e\]\} \{"] \
    [list context-key-reported hir/warnings.tcl \
        $guard \
        "        if \{\[dict get \$node kind\] ne \"const\"\} \{"] \
    [list bytes-counted hir/warnings.tcl \
        $length \
        "        if \{\[string length \[encoding convertto utf-8 \[core::value::strOf \$value\]\]\] != 1\} \{"] \
    [list code-units-counted hir/warnings.tcl \
        $length \
        "        if \{\[string length \[encoding convertto utf-16 \[core::value::strOf \$value\]\]\] != 2\} \{"] \
    [list first-site-per-value hir/warnings.tcl \
        $returned \
        "        if \{\[dict exists \$seen \$value\]\} continue\n        dict set seen \$value 1\n$returned"] \
    [list character-spelling-printed hir/warnings.tcl \
        $message \
        "            \"the String literal `\[core::value::show \$value\]` is one character long; a single character is written as a character literal: \[core::value::show \[core::value::char \[scan \[core::value::strOf \$value\] %c\]\]\]\" \\"] \
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

set scratch [file tempdir one-char-string-literal-mutants]
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
    set text [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    if {$name eq "first-site-per-value"} {
        # The mutant's own state: a dict of values already reported.
        set text [string map [list "    set keys \[ContextLoadKeys \$hir\]\n" "    set keys \[ContextLoadKeys \$hir\]\n    set seen \[dict create\]\n"] $text]
    }
    writeText $path $text
    catch {exec [info nameofexecutable] [file join $tree audit one-char-string-literal tools fuzz.tcl] $seeds 1 2>@1} full
    # The fuzzer's summary, wherever it is in what it printed (a failing run
    # makes exec raise, with the output as the message).
    set summary "no summary: [string range [lindex [split [string trim $full] \n] end] 0 100]"
    regexp -line {^seeds [0-9]+ \(from 1\):[^;]*; failures [0-9]+; extra warnings [0-9]+; spelling law [0-9]+ of [0-9]+ findings, failures [0-9]+} $full summary
    regexp {failures ([0-9]+); extra warnings ([0-9]+)} $summary -> failures extras
    if {![info exists failures]} {
        # The fuzzer did not run to its summary: a broken mutant (a syntax
        # error, say) is a tool failure, never a kill.
        set status "BROKEN MUTANT ($summary)"
        incr survivors
    } elseif {$failures > 0 || $extras > 0} {
        set status "killed by fuzz ($summary)"
    } else {
        set unit [catch {exec [info nameofexecutable] [file join $tree tests one-char-string-literal.test] -tmpdir [file join $tree tcltest] -skip oc-fuzz-smoke 2>@1} unitOut]
        regexp {Total\t([0-9]+)\tPassed\t([0-9]+)\tSkipped\t([0-9]+)\tFailed\t([0-9]+)} $unitOut -> total passed skipped unitFailed
        set failing [regexp -all -inline -line {^==== (oc-[^ ]+) FAILED$} $unitOut]
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
