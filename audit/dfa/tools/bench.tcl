# bench.tcl -- the performance report of DFA-COROUTINE-EXPLORATION.md
# ("Performance"), measured as bench/coroutine-fusion.tcl measures.
#
#   tclsh9.0 audit/dfa/tools/bench.tcl ?-runs N? ?-rounds R? ?-scale F?
#       ?-workloads LIST? ?-out FILE? ?-instructions 1? ?-parts LIST?
#
# Natively on cranelift. Tokenizing a JSON-like text (the fusion milestone's
# tokens input, which all three tokenizers can read), per input character:
#
#   imperative   audit/compiler-service/probes/json/json_tokens.bot's
#                tokenize: recursive functions over the text, a List of
#                Token structs (it builds what the others only count)
#   coroutine    audit/coroutine-fusion/programs/tokens.bot's lex: a
#                character-source coroutine and hand-written recognizer
#                coroutines (a subset of JSON's grammar: no exponent, no
#                literal, no escape validation), counting
#   dfa-lex      json::lex_text: the declared recognizers of json_lex.dfa
#                (RFC 8259's whole lexical grammar), counting
#   dfa-validate json::validate_text: the same with the structural layer
#                (the text made one valid document)
#
# and validating UTF-8, per byte, the fusion milestone's pattern input:
#
#   utf8-coroutine   audit/coroutine-fusion/programs/utf8.bot
#   utf8-procedural  its hand-written baseline
#   utf8-dfa         json_lex's declared utf8_text, driven the same way
#
# Every coroutine program runs fused (the default) and on the general
# runtime (fusion off). A time is the best of RUNS in-process runs; each
# variant runs in ROUNDS driver processes, interleaved; the report gives the
# minimum and the median over them. Then, per workload at its middle size:
# allocations, coroutine objects, machine code bytes (botlish-native size),
# the front end's compile time, native lowering's and the driver's. With
# -instructions 1 (valgrind installed), the instructions per item: the
# driver's whole run under callgrind at the middle size minus at the
# smallest, over the items between (compilation and startup cancel out).
# Unlike the times, which a shared machine scatters, the counts repeat.
# -parts selects among times, resources (and instructions).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit dfa tests support.tcl]
interp recursionlimit {} 200000

set runs 5
set rounds 5
set scale 1.0
set workloads {imperative coroutine dfa-lex dfa-validate utf8-coroutine utf8-procedural utf8-dfa}
set out ""
set instructions 0
set parts {times resources}
foreach {option value} $args {
    switch -- $option {
        -instructions { set instructions $value }
        -parts { set parts $value }
        -runs { set runs $value }
        -rounds { set rounds $value }
        -scale { set scale $value }
        -workloads { set workloads $value }
        -out { set out $value }
        default { error "unknown option $option" }
    }
}

proc sizes {name} {
    return [lmap n {2000 20000 200000} {expr {max(1, int($n * $::scale))}}]
}

proc readFile {path} {
    return [string trimright [core::ReadFile $path] \n]
}

# The JSON-like text of the fusion milestone's benchmark, about N characters,
# as a Botlish string literal's contents; DOCUMENT: one valid document.
proc jsonText {n {document 0}} {
    set piece {{"a": [1, -2.5, 30], "b\"c": {"d": 400}, "e": [6.0, 7]}, }
    set text [string repeat $piece [expr {max(1, $n / [string length $piece])}]]
    if {$document} {
        set text "\[$text\{\}\]"
    }
    return [string map {\\ \\\\ \" \\\"} $text]
}

set utf8Pattern {
# The I-th byte of a repeating valid input of 1-, 2-, 3- and 4-byte
# characters (utf8.bot's pattern).
fn pattern(i: int) -> int:
    k = i.mod(10)
    if k == 0:
        return 97
    elif k == 1:
        return 195
    elif k == 2:
        return 169
    elif k == 3:
        return 226
    elif k == 4:
        return 130
    elif k == 5:
        return 172
    elif k == 6:
        return 240
    elif k == 7:
        return 159
    elif k == 8:
        return 152
    128
}

# {FILE TEXT ...}: the files of workload NAME at size N (main.bot the
# program; the others beside it, in a copy of the JSON directory).
proc files {name n} {
    global root
    switch -- $name {
        imperative {
            return [list json_tokens.bot [readFile [file join $root audit compiler-service probes json json_tokens.bot]] main.bot [string cat {import json_tokens
import std::list

fn run(text: str) -> int errors IndexNotFound, LowerUnderrun, UpperOverrun, json_tokens::Malformed, json_tokens::TooManyTokens:
    std::list::length(json_tokens::tokenize(text, 100000000))

run("} [jsonText $n] {"):
    on IndexNotFound:
        -1
    on LowerUnderrun:
        -1
    on UpperOverrun:
        -1
    on json_tokens::Malformed:
        -2
    on json_tokens::TooManyTokens:
        -3
}]]
        }
        coroutine {
            set lines [split [readFile [file join $root audit coroutine-fusion programs tokens.bot]] \n]
            set at [lsearch -glob $lines {lex(*}]
            return [list main.bot [join [lreplace $lines $at $at "lex(\"[jsonText $n]\"):"] \n]\n]
        }
        dfa-lex - dfa-validate {
            set call [expr {$name eq "dfa-lex" ? "json::lex_text(\[\"[jsonText $n]\"\], 100000000)" : "json::validate_text(\[\"[jsonText $n 1]\"\], 64, 100000000)"}]
            set errors [expr {$name eq "dfa-lex" ? "" : "\n    on json::Structure:\n        -4\n    on json::TooDeep:\n        -5"}]
            return [list main.bot "import json\n\nfn run() -> int errors IndexNotFound, json::Lexical, json::Truncated, json::TokenTooLong[expr {$name eq "dfa-lex" ? "" : ", json::Structure, json::TooDeep"}]:\n    $call.tokens\n\nrun():\n    on IndexNotFound:\n        -1\n    on json::Lexical:\n        -2\n    on json::Truncated:\n        -3\n    on json::TokenTooLong:\n        -6$errors\n"]
        }
        utf8-coroutine - utf8-procedural {
            set file [expr {$name eq "utf8-coroutine" ? "utf8.bot" : "utf8-procedural.bot"}]
            set lines [split [readFile [file join $root audit coroutine-fusion programs $file]] \n]
            set at [lsearch -glob $lines {\[validate(*}]
            return [list main.bot "[join [lrange $lines 0 [expr {$at - 1}]] \n]\nvalidate_pattern($n)\n"]
        }
        utf8-dfa {
            return [list main.bot [string cat "import dfa\nimport json_lex\nimport std::coroutine\n" $::utf8Pattern {
# 1 if the N bytes of the pattern are valid UTF-8 (they are).
fn validate_pattern(n: int) -> int errors dfa::UnrecognizedInput, dfa::UnexpectedEnd:
    coroutine {step} = json_lex::utf8_text(pattern(0))
    loop i from 1 to n:
        step(dfa::Symbol {code: pattern(i)})
    step(dfa::Symbol {code: -1})
    if std::coroutine::done?(step):
        return 1
    0

validate_pattern(} $n {):
    on dfa::UnrecognizedInput:
        -1
    on dfa::UnexpectedEnd:
        -2
}]]
        }
    }
}

proc coroutines? {name} {
    return [expr {$name ni {imperative utf8-procedural}}]
}

# {HIR FRONT-END-MS} of workload NAME at size N.
proc compileWorkload {name n} {
    set dir [dfatest::workspace {*}[files $name $n]]
    try {
        set t0 [clock microseconds]
        set hir [surface::readProgramFile [file join $dir main.bot] -warnings off]
        return [list $hir [expr {([clock microseconds] - $t0) / 1000.0}]]
    } finally {
        file delete -force $dir
    }
}

proc measure {hir fused} {
    if {$fused} {
        return [native::measure $hir $::runs]
    }
    return [withoutCoroutineFusion {native::measure $hir $::runs}]
}

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

proc codeSize {hir fused} {
    set line [lindex [if {$fused} {native::Driver size [native::nir $hir]} else {
        withoutCoroutineFusion {native::Driver size [native::nir $hir]}
    }] 0]
    return [lindex $line 1]
}

proc allocations {hir fused} {
    if {$fused} {
        set report [native::allocationReport $hir summary]
    } else {
        set report [withoutCoroutineFusion {native::allocationReport $hir summary}]
    }
    set all 0
    dict for {kind info} [dict get $report byKind] {
        incr all [dict get $info allocations]
    }
    set coroutines [expr {[dict exists $report byKind Coroutine] ? [dict get $report byKind Coroutine allocations] : 0}]
    return [list $all $coroutines]
}

# callgrind's instruction count of the driver running HIR, fusion on or off.
proc instructionCount {hir fused} {
    lassign [file tempfile path botlish-dfa-bench.nir] channel
    puts -nonewline $channel [native::nir $hir]
    close $channel
    try {
        set command [list exec valgrind --tool=callgrind --callgrind-out-file=/dev/null [native::binary] run $path 2>@1]
        if {$fused} {
            catch $command output
        } else {
            withoutCoroutineFusion {catch $command output}
        }
    } finally {
        file delete $path
    }
    if {![regexp {Collected : ([0-9]+)} $output -> count]} {
        error "callgrind counted nothing: $output"
    }
    return $count
}

set report "# DFA prototype: performance\n\n"
append report "Generated by audit/dfa/tools/bench.tcl -runs $runs -rounds $rounds -scale $scale on [exec uname -m] ([lindex [split [exec grep -m1 {model name} /proc/cpuinfo] :] 1]).\n"
append report "Best of $runs in-process runs; minimum and median over $rounds interleaved driver processes; ns per item (a character, or a byte for utf8-*).\n\n"
append report "| workload | items | general min | general med | fused min | fused med | general / fused (med) |\n|---|---:|---:|---:|---:|---:|---:|\n"
puts -nonewline $report
foreach name [expr {"times" in $parts ? $workloads : {}}] {
    foreach n [sizes $name] {
        lassign [compileWorkload $name $n] hir
        set variants [expr {[coroutines? $name] ? {general 0 fused 1} : {fused 1}}]
        set times [dict create general {} fused {}]
        set values {}
        for {set r 0} {$r < $rounds} {incr r} {
            foreach {variant fused} $variants {
                lassign [measure $hir $fused] lower compile best collections value
                dict lappend times $variant [expr {$best * 1000.0 / $n}]
                lappend values $value
            }
        }
        if {[llength [lsort -unique $values]] != 1} {
            error "$name at $n: the variants disagree: [lsort -unique $values]"
        }
        set row "| $name | $n |"
        foreach variant {general fused} {
            set ts [dict get $times $variant]
            if {![llength $ts]} {
                append row " -- | -- |"
            } else {
                append row " [format %.2f [tcl::mathfunc::min {*}$ts]] | [format %.2f [median $ts]] |"
            }
        }
        if {[llength [dict get $times general]]} {
            append row " [format %.1f [expr {[median [dict get $times general]] / [median [dict get $times fused]]}]] |"
        } else {
            append row " -- |"
        }
        append report $row\n
        puts $row
    }
}

set section "\n## Resources (middle size)\n\n| workload | variant | allocations | coroutine objects | code bytes | front end ms | lower ms | driver compile ms |\n|---|---|---:|---:|---:|---:|---:|---:|\n"
append report $section
puts -nonewline $section
foreach name [expr {"resources" in $parts ? $workloads : {}}] {
    set n [lindex [sizes $name] 1]
    lassign [compileWorkload $name $n] hir frontMs
    set fronts [list $frontMs]
    for {set r 0} {$r < 2} {incr r} {
        lappend fronts [lindex [compileWorkload $name $n] 1]
    }
    set variants [expr {[coroutines? $name] ? {general 0 fused 1} : {fused 1}}]
    foreach {variant fused} $variants {
        lassign [allocations $hir $fused] all coroutines
        set compiles {}
        set lowers {}
        for {set r 0} {$r < 3} {incr r} {
            lassign [measure $hir $fused] lower compile
            lappend lowers [expr {$lower / 1000.0}]
            lappend compiles [expr {$compile / 1000.0}]
        }
        set row "| $name | [expr {[coroutines? $name] ? $variant : "--"}] | $all | $coroutines | [codeSize $hir $fused] | [format %.0f [median $fronts]] | [format %.1f [median $lowers]] | [format %.1f [median $compiles]] |"
        append report $row\n
        puts $row
    }
}
if {$instructions} {
    set section "\n## Instructions per item (callgrind)\n\n| workload | variant | instructions per item |\n|---|---|---:|\n"
    append report $section
    puts -nonewline $section
    foreach name $workloads {
        lassign [sizes $name] small middle
        lassign [compileWorkload $name $small] hirSmall
        lassign [compileWorkload $name $middle] hirMiddle
        set variants [expr {[coroutines? $name] ? {general 0 fused 1} : {fused 1}}]
        foreach {variant fused} $variants {
            set per [expr {double([instructionCount $hirMiddle $fused] - [instructionCount $hirSmall $fused]) / ($middle - $small)}]
            set row "| $name | [expr {[coroutines? $name] ? $variant : "--"}] | [format %.1f $per] |"
            append report $row\n
            puts $row
        }
    }
}
if {$out ne ""} {
    dfa::WriteText $out $report
}
