# dfa.tcl -- the performance and compile-cost report of declared
# recognizers (DFA-COROUTINE-MILESTONE-2.md, "Performance" and "Compile
# cost"), measured as audit/dfa/tools/bench.tcl measured the exploration's
# prototype (its numbers are the report's "before").
#
#   tclsh9.0 bench/dfa.tcl ?-runs N? ?-rounds R? ?-scale F? ?-workloads LIST?
#       ?-parts LIST? ?-out FILE?
#
# Natively on cranelift. Tokenizing a JSON-like text (the fusion milestone's
# tokens input), per input character:
#
#   imperative    audit/compiler-service/probes/json/json_tokens.bot's
#                 tokenize: recursive functions over the text, a List of
#                 Token structs (it builds what the others only count)
#   coroutine     audit/coroutine-fusion/programs/tokens.bot's lex: hand-
#                 written recognizer coroutines (a subset of JSON's grammar:
#                 no exponent, no literal, no escape validation), counting
#   dfa-lex       examples/dfa/json's json::lex_text: the declared
#                 recognizers of json_lex.bot (RFC 8259's whole lexical
#                 grammar), the driver's one-symbol buffer, counting
#   dfa-lex-factory  composition::lex_with: the same, its recognizer a
#                 parameter (a factory returning the started handle: the
#                 general runtime even "fused", the interprocedural limit)
#   dfa-validate  json::validate_text: the same with the structural layer
#
# a YAML flow text, per character:
#
#   yaml-tokens   examples/dfa/yaml's yaml::count_tokens: plain scalars
#                 with colons (two symbols of lookahead), quoted scalars,
#                 flow indicators; its driver's ring buffer of two symbols,
#                 counting
#
# validating UTF-8, per byte (the fusion milestone's pattern input):
#
#   utf8-coroutine   audit/coroutine-fusion/programs/utf8.bot
#   utf8-procedural  its hand-written baseline
#   utf8-dfa         json_lex's declared utf8_text, driven the same way
#
# and one recognizer in a tight loop, per symbol:
#
#   dfa-micro     json_number constructed once and fed digits
#   hand-micro    the same recognizer written by hand as an ordinary
#                 coroutine (examples/dfa/json/by_hand.bot), fed the same
#
# dfa-lex also runs with each native dispatch of a transition call
# (dfa-lex/tree, /switch, /table: BOTLISH_NATIVE_DFA_DISPATCH; the default
# is table for these ascii, bytes and unicode recognizers' byte rows, a
# switch otherwise) and with the front end's decision-tree lowering
# (dfa-lex/front-tree: surface::dfa::lowering tree, the exploration's shape).
# Every coroutine program runs fused (the default) and on the general
# runtime. A time is the best of RUNS in-process runs; each variant runs in
# ROUNDS driver processes, interleaved; the report gives the minimum and
# the median.
#
# Parts (-parts): times; resources (per workload at the middle size:
# allocations, coroutine objects, machine code bytes, the front end's time,
# native lowering's and the driver's compile); compile (the json_lex module
# itself: the front end of a program that uses one recognizer of it, cold --
# a fresh process -- and warm; its NIR's size; lowering, compile and code
# bytes per dispatch).

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000
core::useProgramRecursionLimit

set runs 5
set rounds 5
set scale 1.0
set workloads {imperative coroutine dfa-lex dfa-lex/tree dfa-lex/switch dfa-lex/table dfa-lex/front-tree dfa-lex-factory dfa-validate yaml-tokens utf8-coroutine utf8-procedural utf8-dfa dfa-micro hand-micro}
set out ""
set parts {times resources compile}
foreach {option value} $args {
    switch -- $option {
        -parts { set parts $value }
        -runs { set runs $value }
        -rounds { set rounds $value }
        -scale { set scale $value }
        -workloads { set workloads $value }
        -out { set out $value }
        default { error "unknown option $option" }
    }
}

set jsonDir [file join $root examples dfa json]
set yamlDir [file join $root examples dfa yaml]

# 1 if workload NAME makes coroutines (it runs fused and on the general
# runtime).
proc coroutines? {name} {
    return [expr {[base $name] ni {imperative utf8-procedural}}]
}

proc sizes {} {
    return [lmap n {2000 20000 200000} {expr {max(1, int($n * $::scale))}}]
}

proc readFile {path} {
    return [string trimright [core::ReadFile $path] \n]
}

proc writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
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

# A flow-style YAML text of about N characters, as a Botlish string
# literal's contents.
proc yamlText {n} {
    set piece {{a:b, c: d, 'it''s': [x::y, "q\tz", :k]}, }
    set text [string repeat $piece [expr {max(1, $n / [string length $piece])}]]
    return [string map {\\ \\\\ \" \\\"} "\[$text\]"]
}

# The workload NAME without its variant (dfa-lex/tree: dfa-lex).
proc base {name} {
    return [lindex [split $name /] 0]
}

# {FILE TEXT ...}: the files of workload NAME at size N (main.bot the
# program; the JSON modules beside it).
proc files {name n} {
    global root jsonDir
    set json [list json_lex.bot [readFile [file join $jsonDir json_lex.bot]] json.bot [readFile [file join $jsonDir json.bot]]]
    switch -- [base $name] {
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
        dfa-lex-factory {
            return [list {*}$json composition.bot [readFile [file join $jsonDir composition.bot]] main.bot "import json\nimport composition\n\nfn run() -> int errors IndexNotFound, json::Lexical, json::Truncated, json::TokenTooLong:\n    composition::lex_with(composition::token, \[\"[jsonText $n]\"\], 100000000).tokens\n\nrun():\n    on IndexNotFound:\n        -1\n    on json::Lexical:\n        -2\n    on json::Truncated:\n        -3\n    on json::TokenTooLong:\n        -6\n"]
        }
        yaml-tokens {
            return [list yaml_lex.bot [readFile [file join $::yamlDir yaml_lex.bot]] yaml.bot [readFile [file join $::yamlDir yaml.bot]] main.bot "import yaml\n\nfn run() -> int errors IndexNotFound, yaml::Lexical, yaml::Truncated, yaml::TokenTooLong:\n    yaml::count_tokens(\[\"[yamlText $n]\"\], 100000000)\n\nrun():\n    on IndexNotFound:\n        -1\n    on yaml::Lexical:\n        -2\n    on yaml::Truncated:\n        -3\n    on yaml::TokenTooLong:\n        -6\n"]
        }
        utf8-coroutine - utf8-procedural {
            set file [if {[base $name] eq "utf8-coroutine"} {string cat utf8.bot} else {string cat utf8-procedural.bot}]
            set lines [split [readFile [file join $root audit coroutine-fusion programs $file]] \n]
            set at [lsearch -glob $lines {\[validate(*}]
            return [list main.bot "[join [lrange $lines 0 [expr {$at - 1}]] \n]\nvalidate_pattern($n)\n"]
        }
        dfa-micro {
            return [list {*}$json main.bot [string cat "import std::dfa\nimport json_lex\nimport std::coroutine\n" {
# N digits fed to one json_number: 1 if it is still waiting (it is).
fn digits(n: int) -> int errors std::dfa::UnrecognizedInput, std::dfa::UnexpectedEnd:
    coroutine {step} = json_lex::json_number(49)
    loop i from 1 to n:
        step(std::dfa::Symbol {code: 53})
    if std::coroutine::done?(step):
        return 0
    1

digits(} $n {):
    on std::dfa::UnrecognizedInput:
        -1
    on std::dfa::UnexpectedEnd:
        -2
}]]
        }
        hand-micro {
            return [list by_hand.bot [readFile [file join $jsonDir by_hand.bot]] main.bot [string cat "import std::dfa\nimport by_hand\nimport std::coroutine\n" {
# N digits fed to one hand-written number recognizer: 1 if it is still
# waiting (it is).
fn digits(n: int) -> int errors std::dfa::UnrecognizedInput, std::dfa::UnexpectedEnd:
    coroutine {step} = by_hand::number_by_hand(49)
    loop i from 1 to n:
        step(std::dfa::Symbol {code: 53})
    if std::coroutine::done?(step):
        return 0
    1

digits(} $n {):
    on std::dfa::UnrecognizedInput:
        -1
    on std::dfa::UnexpectedEnd:
        -2
}]]
        }
        coroutine {
            set lines [split [readFile [file join $root audit coroutine-fusion programs tokens.bot]] \n]
            set at [lsearch -glob $lines {lex(*}]
            return [list main.bot [join [lreplace $lines $at $at "lex(\"[jsonText $n]\"):"] \n]\n]
        }
        dfa-lex {
            return [list {*}$json main.bot "import json\n\nfn run() -> int errors IndexNotFound, json::Lexical, json::Truncated, json::TokenTooLong:\n    json::lex_text(\[\"[jsonText $n]\"\], 100000000).tokens\n\nrun():\n    on IndexNotFound:\n        -1\n    on json::Lexical:\n        -2\n    on json::Truncated:\n        -3\n    on json::TokenTooLong:\n        -6\n"]
        }
        dfa-validate {
            return [list {*}$json main.bot "import json\n\nfn run() -> int errors IndexNotFound, json::Lexical, json::Truncated, json::TokenTooLong, json::Structure, json::TooDeep:\n    json::validate_text(\[\"[jsonText $n 1]\"\], 64, 100000000).tokens\n\nrun():\n    on IndexNotFound:\n        -1\n    on json::Lexical:\n        -2\n    on json::Truncated:\n        -3\n    on json::TokenTooLong:\n        -6\n    on json::Structure:\n        -4\n    on json::TooDeep:\n        -5\n"]
        }
        utf8-dfa {
            return [list {*}$json main.bot [string cat "import std::dfa\nimport json_lex\nimport std::coroutine\n" $::utf8Pattern {
# 1 if the N bytes of the pattern are valid UTF-8 (they are).
fn validate_pattern(n: int) -> int errors std::dfa::UnrecognizedInput, std::dfa::UnexpectedEnd:
    coroutine {step} = json_lex::utf8_text(pattern(0))
    loop i from 1 to n:
        step(std::dfa::Symbol {code: pattern(i)})
    step(std::dfa::Symbol {code: -1})
    if std::coroutine::done?(step):
        return 1
    0

validate_pattern(} $n {):
    on std::dfa::UnrecognizedInput:
        -1
    on std::dfa::UnexpectedEnd:
        -2
}]]
        }
    }
}

# Runs SCRIPT with workload NAME's variant in force: a native dispatch
# (BOTLISH_NATIVE_DFA_DISPATCH) or the front end's tree lowering.
proc withVariant {name script} {
    set variant [lindex [split $name /] 1]
    set saved [array get ::env BOTLISH_NATIVE_DFA_DISPATCH]
    try {
        switch -- $variant {
            tree - switch - table { set ::env(BOTLISH_NATIVE_DFA_DISPATCH) $variant }
            front-tree { set ::surface::dfa::lowering tree }
        }
        return [uplevel 1 $script]
    } finally {
        unset -nocomplain ::env(BOTLISH_NATIVE_DFA_DISPATCH)
        array set ::env $saved
        set ::surface::dfa::lowering compact
    }
}

# {HIR FRONT-END-MS} of workload NAME at size N, compiled in a private
# directory.
proc compileWorkload {name n} {
    set dir [file tempdir botlish-dfa-bench]
    try {
        foreach {file text} [files $name $n] {
            writeFile [file join $dir $file] $text
        }
        return [withVariant $name {
            set t0 [clock microseconds]
            set hir [surface::readProgramFile [file join $dir main.bot] -warnings off]
            list $hir [expr {([clock microseconds] - $t0) / 1000.0}]
        }]
    } finally {
        file delete -force $dir
    }
}

proc measure {name hir fused} {
    return [withVariant $name {
        if {$fused} {
            native::measure $hir $::runs
        } else {
            withoutCoroutineFusion {native::measure $hir $::runs}
        }
    }]
}

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

proc codeSize {name hir fused} {
    return [withVariant $name {
        set line [lindex [if {$fused} {native::Driver size [native::nir $hir]} else {
            withoutCoroutineFusion {native::Driver size [native::nir $hir]}
        }] 0]
        lindex $line 1
    }]
}

proc allocations {name hir fused} {
    set report [withVariant $name {
        if {$fused} {
            native::allocationReport $hir summary
        } else {
            withoutCoroutineFusion {native::allocationReport $hir summary}
        }
    }]
    set all 0
    dict for {kind info} [dict get $report byKind] {
        incr all [dict get $info allocations]
    }
    set coroutines [expr {[dict exists $report byKind Coroutine] ? [dict get $report byKind Coroutine allocations] : 0}]
    return [list $all $coroutines]
}

set report "# Declared recognizers: performance and compile cost\n\n"
append report "Generated by bench/dfa.tcl -runs $runs -rounds $rounds -scale $scale on [exec uname -m] ([string trim [lindex [split [exec grep -m1 {model name} /proc/cpuinfo] :] 1]]).\n"
append report "Best of $runs in-process runs; minimum and median over $rounds interleaved driver processes; ns per item (a character, or a byte for utf8-*).\n\n"
if {"times" in $parts} {
    append report "| workload | items | general min | general med | fused min | fused med | general / fused (med) |\n|---|---:|---:|---:|---:|---:|---:|\n"
}
puts -nonewline $report
foreach name [expr {"times" in $parts ? $workloads : {}}] {
    foreach n [sizes] {
        lassign [compileWorkload $name $n] hir
        set times [dict create general {} fused {}]
        set values {}
        set variants [if {[coroutines? $name]} {list general 0 fused 1} else {list fused 1}]
        for {set r 0} {$r < $rounds} {incr r} {
            foreach {variant fused} $variants {
                lassign [measure $name $hir $fused] lower compile best collections value
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

if {"resources" in $parts} {
    set section "\n## Resources (middle size)\n\n| workload | variant | allocations | coroutine objects | code bytes | front end ms | lower ms | driver compile ms |\n|---|---|---:|---:|---:|---:|---:|---:|\n"
    append report $section
    puts -nonewline $section
}
foreach name [expr {"resources" in $parts ? $workloads : {}}] {
    set n [lindex [sizes] 1]
    lassign [compileWorkload $name $n] hir frontMs
    set fronts [list $frontMs]
    for {set r 0} {$r < 2} {incr r} {
        lappend fronts [lindex [compileWorkload $name $n] 1]
    }
    set variants [if {[coroutines? $name]} {list general 0 fused 1} else {list fused 1}]
    foreach {variant fused} $variants {
        lassign [allocations $name $hir $fused] all coroutines
        set compiles {}
        set lowers {}
        for {set r 0} {$r < 3} {incr r} {
            lassign [measure $name $hir $fused] lower compile
            lappend lowers [expr {$lower / 1000.0}]
            lappend compiles [expr {$compile / 1000.0}]
        }
        set shown [if {[coroutines? $name]} {set variant} else {string cat --}]
        set row "| $name | $shown | $all | $coroutines | [codeSize $name $hir $fused] | [format %.0f [median $fronts]] | [format %.1f [median $lowers]] | [format %.1f [median $compiles]] |"
        append report $row\n
        puts $row
    }
}

# The front end's time for the program whose files are FILES (main.bot the
# entry), in a fresh process (cold: the compiler's procedures not yet
# compiled to Tcl bytecode) and then again in it (warm): {COLD WARM} ms.
proc frontEndColdWarm {files} {
    global root
    set dir [file tempdir botlish-dfa-bench]
    try {
        foreach {file text} $files {
            writeFile [file join $dir $file] $text
        }
        writeFile [file join $dir time.tcl] [string map [list @ROOT@ $root @MAIN@ [file join $dir main.bot]] {
            source [file join {@ROOT@} core core.tcl]
            source [file join {@ROOT@} surface surface.tcl]
            set t0 [clock microseconds]
            surface::readProgramFile {@MAIN@} -warnings off
            set cold [expr {([clock microseconds] - $t0) / 1000.0}]
            set t0 [clock microseconds]
            surface::readProgramFile {@MAIN@} -warnings off
            puts "$cold [expr {([clock microseconds] - $t0) / 1000.0}]"
        }]
        set env BOTLISH_HIR_CACHE
        set saved [array get ::env $env]
        unset -nocomplain ::env($env)
        try {
            return [exec tclsh9.0 [file join $dir time.tcl]]
        } finally {
            array set ::env $saved
        }
    } finally {
        file delete -force $dir
    }
}

if {"compile" in $parts} {
    set section "\n## The cost of the JSON lexer module\n\nA program that runs one recognizer of json_lex.bot once (`json_lex::json_number(49)`): the front end's time cold (a fresh process) and warm (the median of three, in the same process); then, per lowering, its NIR's size and native lowering's, the driver's compile and the machine code bytes of the program.\n\n"
    set program "import std::dfa\nimport json_lex\n\nfn one() -> int errors std::dfa::UnrecognizedInput, std::dfa::UnexpectedEnd:\n    coroutine {first} = json_lex::json_number(49)\n    first\n\none():\n    on std::dfa::UnrecognizedInput:\n        -1\n    on std::dfa::UnexpectedEnd:\n        -2\n"
    set files [list json_lex.bot [readFile [file join $jsonDir json_lex.bot]] main.bot $program]
    set colds {}
    set warms {}
    for {set r 0} {$r < 3} {incr r} {
        lassign [frontEndColdWarm $files] cold warm
        lappend colds $cold
        lappend warms $warm
    }
    append section "| front end | cold ms (median of 3 processes) | warm ms |\n|---|---:|---:|\n| one recognizer of json_lex | [format %.0f [median $colds]] | [format %.0f [median $warms]] |\n\n"
    append section "| lowering | NIR bytes | NIR lines | lower ms | driver compile ms | code bytes |\n|---|---:|---:|---:|---:|---:|\n"
    set dir [file tempdir botlish-dfa-bench]
    try {
        foreach {file text} $files {
            writeFile [file join $dir $file] $text
        }
        foreach variant {compact/table compact/switch compact/tree front-tree} {
            set name x/[lindex [split $variant /] end]
            set hir [withVariant $name {surface::readProgramFile [file join $dir main.bot] -warnings off}]
            set nir [withVariant $name {native::nir $hir}]
            set lowers {}
            set compiles {}
            for {set r 0} {$r < 3} {incr r} {
                lassign [measure $name $hir 1] lower compile
                lappend lowers [expr {$lower / 1000.0}]
                lappend compiles [expr {$compile / 1000.0}]
            }
            append section "| $variant | [string length $nir] | [llength [split $nir \n]] | [format %.1f [median $lowers]] | [format %.1f [median $compiles]] | [codeSize $name $hir 1] |\n"
        }
    } finally {
        file delete -force $dir
    }
    append report $section
    puts -nonewline $section
}
if {$out ne ""} {
    writeFile $out $report
}
