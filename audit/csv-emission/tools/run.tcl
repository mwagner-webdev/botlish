# run.tcl -- runs the CSV sources of examples/dfa/csv on generated inputs, on
# any backend, and judges every trace with the reference interpreter
# (CSV-EMISSION-VALIDATION-MILESTONE-1.md, sections 10, 13, 14 and 17).
#
#   source audit/csv-emission/tools/run.tcl     (after tests/helpers.tcl and
#                                                surface/surface.tcl)
#
#   csvrun::kinds                     the sources a case can name
#   csvrun::values                    the adversarial field values, named
#   csvrun::run CASES BACKENDS        => {BACKEND OUTCOMES}...: each case's
#                                        outcome on each backend
#   csvrun::judge CASE OUTCOME        => ok | {invalid REASON}: the declared
#                                        recognizer's verdict on the trace
#                                        (tests/dfa-support.tcl's reference
#                                        interpreter: the declarations, read
#                                        on their own -- never surface/dfa.tcl
#                                        or the checker)
#   csvrun::write PATH CASES RESULTS  the cases and outcomes as lines for
#                                        oracle.py
#
# A CASE is {KIND INPUT}: for a document, INPUT is a list of rows (the first
# the header for *_document kinds), each a list of three fields; for a field,
# one field; a field is a list of Unicode scalar values (Ints) -- any value,
# NUL and controls included. For bytes_from_bytes INPUT is a list of byte
# values, valid UTF-8 or not.
#
# An OUTCOME is {STATUS AT VALUE FINAL SYMBOLS}: STATUS ok, unsupported
# (UnsupportedCSVCharacter {at, value}), quoting (QuotingDecision),
# invalid-utf8 (decode_utf8 refused the input) or setup; FINAL the source's
# final value when it completed; SYMBOLS every symbol the consumer received
# -- on a failure, the prefix written before it (what a sink would hold).
#
# The program a batch runs is generated: one function per kind constructs
# that kind's source and collects its symbols, catching its failure; the
# inputs reach it through a List loop, so no input is a constant the
# compiler could fold (a call that always fails for one literal would be
# KNOWN-ERROR). It runs in a private copy of examples/dfa/csv.

if {[info commands ::dfaref::run] eq ""} {
    source [file join $::projectRoot tests dfa-support.tcl]
}

namespace eval csvrun {
    variable csvDir [file join $::projectRoot examples dfa csv]
    # KIND -> {SOURCE SHAPE NS RECOGNIZER ERRORS}: SHAPE document (header and
    # rows), rows (rows only), field (one str) or bytes (one Bytes).
    variable kinds {
        strict_document {strict_document_source document csv_strict document3 U}
        utf8_document {utf8_document_source document csv_utf8 document3 U}
        bytes_document {bytes_document_source document csv_utf8 document3_bytes U}
        bytes_stream {bytes_stream_source rows csv_utf8 document3_bytes U}
        bytes_unterminated {bytes_unterminated_source rows csv_utf8 stream3_bytes U}
        selective_document {selective_document_source document csv_utf8 document3 UQ}
        selective_strict_document {selective_strict_document_source document csv_strict document3 UQ}
        strict_field {strict_field_source field csv_strict quoted_field U}
        utf8_field {utf8_field_source field csv_utf8 quoted_field U}
        bytes_field {bytes_field_source field csv_utf8 quoted_field_bytes U}
        selective_field {selective_field_source field csv_utf8 field UQ}
        bytes_from_bytes {bytes_field_from_bytes_source bytes csv_utf8 quoted_field_bytes UI}
    }
    variable model ""
    variable counter 0
    variable base ""
    variable timing {}
}

# The milestone's input classes (section 10), each a named field value: the
# adversarial corpus of differential.tcl and census.tcl.
proc csvrun::values {} {
    set v [dict create]
    dict set v empty ""
    dict set v ascii "hello world"
    dict set v comma "a,b"
    dict set v one-quote "\""
    dict set v two-quotes "\"\""
    dict set v three-quotes "\"\"\""
    dict set v four-quotes "\"\"\"\""
    dict set v many-quotes [string repeat "\"" 41]
    dict set v quote-comma "x\","
    dict set v quote-crlf "x\"\r\n"
    dict set v cr "a\rb"
    dict set v lf "a\nb"
    dict set v crlf "a\r\nb"
    dict set v quote-ends "\"edge\""
    dict set v long [string repeat "abc,\"\r\n" 300]
    dict set v supplementary "\U1F600 \U10348 \U10FFFF"
    dict set v combining "é ñ क्ष"
    dict set v line-separators "a b c"
    dict set v bom-inside "﻿start"
    dict set v tab "a\tb"
    dict set v nul "a\u0000b"
    dict set v control "bell\u0007"
    dict set v del "del\u007F"
    dict set v nel "next\u0085line"
    dict set v formula-eq "=1+2"
    dict set v formula-plus "+1+2"
    dict set v formula-at "@SUM(1,2)"
    dict set v formula-minus "-2+3"
    dict set v injection "hello\",\"admin"
    dict set v injection-record "x\"\r\n\"evil\",\"=1+2\",\"z"
    dict set v injection-formula "a\",\"=HYPERLINK(\"\"x\"\")"
    dict set v fake-record "\"1\",\"2\",\"3\"\r\n"
    dict set v fake-separator ",,\r\n,,"
    dict set v latin1 "café naïve"
    dict set v cjk "中文表"
    dict set v noncharacter "￾￿"
    return $v
}

proc csvrun::kinds {} {
    variable kinds
    return [dict keys $kinds]
}

# The UTF-8 bytes of the scalar values CODES (each a scalar value).
proc csvrun::Utf8 {codes} {
    set out {}
    foreach v $codes {
        if {$v < 0x80} {
            lappend out $v
        } elseif {$v < 0x800} {
            lappend out [expr {0xC0 | ($v >> 6)}] [expr {0x80 | ($v & 0x3F)}]
        } elseif {$v < 0x10000} {
            lappend out [expr {0xE0 | ($v >> 12)}] [expr {0x80 | (($v >> 6) & 0x3F)}] [expr {0x80 | ($v & 0x3F)}]
        } else {
            lappend out [expr {0xF0 | ($v >> 18)}] [expr {0x80 | (($v >> 12) & 0x3F)}] \
                [expr {0x80 | (($v >> 6) & 0x3F)}] [expr {0x80 | ($v & 0x3F)}]
        }
    }
    return $out
}

proc csvrun::IntList {xs} {
    return "\[[join [lmap x $xs {expr {$x + 0}}] {, }]\]"
}

# The literal of INPUT for a kind of SHAPE. Every byte list starts with a
# 0 the program drops (an empty list literal would be a List of anything); a
# document is the flat List of its fields, row after row, behind one more
# dropped list (three levels of List would be cut to List[List[list]]).
proc csvrun::Literal {shape input} {
    switch -- $shape {
        field { return [IntList [concat 0 [Utf8 $input]]] }
        bytes { return [IntList [concat 0 $input]] }
        default {
            set fields [list [IntList 0]]
            foreach row $input {
                foreach f $row {
                    lappend fields [IntList [concat 0 [Utf8 $f]]]
                }
            }
            return "\[[join $fields {, }]\]"
        }
    }
}

proc csvrun::InputType {shape} {
    switch -- $shape {
        field - bytes { return "List\[int\]" }
        default { return "List\[List\[int\]\]" }
    }
}

# The runner of KIND: its input's conversion, the source's construction and
# the collection of its symbols, every failure caught.
proc csvrun::Runner {kind} {
    variable kinds
    lassign [dict get $kinds $kind] source shape ns name errs
    set handlers "        on csv_common::UnsupportedCSVCharacter {at, value}:\n            return \[1, at, value, 0\]\n"
    set stepHandlers "            on csv_common::UnsupportedCSVCharacter {at, value}:\n                return std::list::flat(\[\[1, at, value, 0\], done_symbols(out)\])\n"
    if {[string match *Q* $errs]} {
        append handlers "        on selective_emit::QuotingDecision {at, value}:\n            return \[2, at, value, 0\]\n"
        append stepHandlers "            on selective_emit::QuotingDecision {at, value}:\n                return std::list::flat(\[\[2, at, value, 0\], done_symbols(out)\])\n"
    }
    if {[string match *I* $errs]} {
        append handlers "        on InvalidUtf8:\n            return \[3, -1, -1, 0\]\n"
        append stepHandlers "            on InvalidUtf8:\n                return std::list::flat(\[\[3, -1, -1, 0\], done_symbols(out)\])\n"
    }
    set setup "    input_ok = 1\n"
    switch -- $shape {
        field {
            set prep "    value = text(input):\n        on InvalidUtf8:\n            return \[9, -1, -1, 0\]\n        on std::byte::BelowRange:\n            return \[9, -1, -1, 0\]\n        on std::byte::AboveRange:\n            return \[9, -1, -1, 0\]\n"
            set args value
        }
        bytes {
            set prep "    data = bytes_of(input):\n        on std::byte::BelowRange:\n            return \[9, -1, -1, 0\]\n        on std::byte::AboveRange:\n            return \[9, -1, -1, 0\]\n"
            set args data
        }
        rows {
            set prep "    rows = rows_of(input):\n        on InvalidUtf8:\n            return \[9, -1, -1, 0\]\n        on IndexNotFound:\n            return \[9, -1, -1, 0\]\n        on std::byte::BelowRange:\n            return \[9, -1, -1, 0\]\n        on std::byte::AboveRange:\n            return \[9, -1, -1, 0\]\n"
            set args rows
        }
        document {
            set prep "    all = rows_of(input):\n        on InvalidUtf8:\n            return \[9, -1, -1, 0\]\n        on IndexNotFound:\n            return \[9, -1, -1, 0\]\n        on std::byte::BelowRange:\n            return \[9, -1, -1, 0\]\n        on std::byte::AboveRange:\n            return \[9, -1, -1, 0\]\n    if all.length() == 0:\n        return \[9, -1, -1, 0\]\n    header = all.at(0)\n    rows = loop i from 1 to all.length():\n        all.at(i)\n"
            set args "header, rows"
        }
    }
    return "fn run_$kind\(input: [InputType $shape]) -> List\[int\]:\n$prep    out = std::mutable_vector::from_list(no_ints())\n    coroutine {step, first} = sources::$source\($args):\n$handlers    c = std::mutable_array::create(1, first)\n    loop:\n        if std::coroutine::done?(step):\n            break\n        out.push(c.at(0))\n        next = step():\n$stepHandlers        c.set(0, next)\n    std::list::flat(\[\[0, -1, -1, c.at(0)\], done_symbols(out)\])\n\n"
}

# The program running CASES: {TEXT ORDER}, ORDER the case indices in the
# order of the program's result.
proc csvrun::Program {cases} {
    variable kinds
    set byKind [dict create]
    set i 0
    foreach case $cases {
        dict lappend byKind [lindex $case 0] $i
        incr i
    }
    set text "import std::coroutine\nimport std::mutable_vector\nimport std::mutable_array\nimport std::abi::bytes\nimport std::byte\nimport std::list\nimport csv_common\nimport selective_emit\nimport sources\n\n"
    append text "fn no_ints() -> List\[int\]:\n    v = std::mutable_vector::from_list(\[0\])\n    v.pop():\n        on IndexNotFound:\n            return \[\]\n    loop x in v:\n        x\n\n"
    append text "fn done_symbols(v: MutableVector\[int\]) -> List\[int\]:\n    loop x in v:\n        x\n\n"
    append text "fn bytes_of(b: List\[int\]) -> std::abi::bytes::Bytes errors std::byte::BelowRange, std::byte::AboveRange:\n    bs = loop i from 1 to b.length():\n        std::byte::from_int(b.at(i))\n    std::abi::bytes::from_list(bs)\n\n"
    append text "fn text(b: List\[int\]) -> str errors InvalidUtf8, std::byte::BelowRange, std::byte::AboveRange:\n    bytes_of(b).decode_utf8()\n\n"
    append text "fn rows_of(fs: List\[List\[int\]\]) -> List\[csv_common::Row\] errors InvalidUtf8, IndexNotFound, std::byte::BelowRange, std::byte::AboveRange:\n    texts = loop i from 1 to fs.length():\n        text(fs.at(i))\n    loop i from 0 to texts.length():\n        if i.mod(3) != 0:\n            continue\n        csv_common::Row {a: texts.at(i), b: texts.at(i + 1), c: texts.at(i + 2)}\n\n"
    set order {}
    set parts {}
    dict for {kind indices} $byKind {
        lassign [dict get $kinds $kind] source shape
        append text [Runner $kind]
        set literals [lmap i $indices {Literal $shape [lindex $cases $i 1]}]
        append text "inputs_$kind = \[[join $literals {, }]\]\n"
        append text "results_$kind = loop x in inputs_$kind:\n    run_$kind\(x)\n\n"
        lappend parts results_$kind
        lappend order {*}$indices
    }
    append text "std::list::flat(\[[join $parts {, }]\])\n"
    return [list $text $order]
}

# The exhaustive program: every string of length 0..LENGTH over ALPHABET,
# enumerated by the program itself (no literal input: the enumeration is
# the input), each run in the contexts of EXHAUSTIVE below. {TEXT CASES},
# CASES the same enumeration made here, in the program's order.
namespace eval csvrun {
    variable exhaustive {
        strict_field {x}
        bytes_field {x}
        selective_field {x}
        strict_document {[[0], [0, 34], x, [0, 34]]}
        selective_strict_document {[[0], [0, 97], x, [0], x, x, x]}
        bytes_unterminated {[[0], x, [0, 97], x, x, x, [0]]}
    }
}

proc csvrun::ExhaustiveProgram {length alphabet} {
    variable exhaustive
    lassign [Program {}] text
    set text [string range $text 0 [string first "std::list::flat(\[\])" $text]-1]
    foreach {kind input} $exhaustive {
        append text [Runner $kind]
    }
    append text "fn level_after(level: List\[List\[int\]\]) -> List\[List\[int\]\]:\n    parts = loop s in level:\n        inner = loop c in \[[join $alphabet {, }]\]:\n            s.append(c)\n        inner\n    std::list::flat(parts)\n\n"
    append text "fn with0(s: List\[int\]) -> List\[int\]:\n    std::list::flat(\[\[0\], s\])\n\n"
    append text "level0 = \[no_ints()\]\n"
    set levels {level0}
    for {set n 1} {$n <= $length} {incr n} {
        append text "level$n = level_after(level[expr {$n - 1}])\n"
        lappend levels level$n
    }
    append text "strings = std::list::flat(\[[join $levels {, }]\])\n"
    append text "results = loop s in strings:\n    x = with0(s)\n"
    set names {}
    set i 0
    foreach {kind input} $exhaustive {
        append text "    r$i = run_$kind\($input)\n"
        lappend names r$i
        incr i
    }
    append text "    \[[join $names {, }]\]\n"
    append text "std::list::flat(results)\n"
    return $text
}

# The cases of the exhaustive program, in its order.
proc csvrun::ExhaustiveCases {length alphabet} {
    variable exhaustive
    set all {{}}
    set level {{}}
    for {set n 1} {$n <= $length} {incr n} {
        set next {}
        foreach s $level {
            foreach c $alphabet {
                lappend next [concat $s $c]
            }
        }
        lappend all {*}$next
        set level $next
    }
    set cases {}
    foreach s $all {
        foreach {kind input} $exhaustive {
            switch -- $kind {
                strict_document { lappend cases [list $kind [list [list 34 $s 34]]] }
                selective_strict_document { lappend cases [list $kind [list [list 97 $s {}] [list $s $s $s]]] }
                bytes_unterminated { lappend cases [list $kind [list [list $s 97 $s] [list $s $s {}]]] }
                default { lappend cases [list $kind $s] }
            }
        }
    }
    return $cases
}

# The exhaustive enumeration's cases and their outcomes on every backend:
# {CASES {BACKEND OUTCOMES}...}.
proc csvrun::exhaustive {length backends {alphabet {97 44 34 13 10}}} {
    set cases [ExhaustiveCases $length $alphabet]
    set text [ExhaustiveProgram $length $alphabet]
    set order {}
    for {set i 0} {$i < [llength $cases]} {incr i} { lappend order $i }
    return [list $cases [Execute $text $order [llength $cases] $backends]]
}

proc csvrun::Workspace {} {
    variable csvDir
    variable counter
    variable base
    if {$base eq ""} {
        if {[info exists ::argv0] && [string match *.test [file tail $::argv0]]} {
            set base [::tcltest::temporaryDirectory]
        } else {
            set base [file tempdir]
        }
    }
    set dir [file join $base csvrun-[pid]-[incr counter]]
    file delete -force $dir
    file mkdir $dir
    foreach path [glob -directory $csvDir *.bot] {
        file copy -force $path [file join $dir [file tail $path]]
    }
    return $dir
}

proc csvrun::Status {code} {
    return [dict get {0 ok 1 unsupported 2 quoting 3 invalid-utf8 9 setup} $code]
}

# Each case's outcome on each backend of BACKENDS: {BACKEND OUTCOMES}...
proc csvrun::run {cases backends} {
    if {$cases eq {}} {
        return [lmap b $backends {list $b {}}]
    }
    lassign [Program $cases] text order
    return [Execute $text $order [llength $cases] $backends]
}

# Runs the program TEXT, whose result lists the outcomes of COUNT cases in
# ORDER, on every backend.
proc csvrun::Execute {text order count backends} {
    variable timing
    set dir [Workspace]
    set path [file join $dir main.bot]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
    try {
        set t0 [clock milliseconds]
        set hir [surface::readProgramFile $path -warnings off]
        set timing [list front-end [expr {[clock milliseconds] - $t0}]]
        set out {}
        foreach backend $backends {
            set t0 [clock milliseconds]
            set o [outcomeUnderHir $backend $hir]
            lappend timing $backend [expr {[clock milliseconds] - $t0}]
            if {[lindex $o 0] ne "value"} {
                error "csvrun: $backend failed: [lrange $o 0 2]"
            }
            set flat [lindex [string map {\[ \{ \] \} , ""} [lindex $o 1]] 0]
            if {[llength $flat] != $count} {
                error "csvrun: $backend returned [llength $flat] outcomes for $count cases"
            }
            set outcomes [lrepeat $count {}]
            foreach i $order r $flat {
                lassign $r status at value final
                lset outcomes $i [list [Status $status] $at $value $final [lrange $r 4 end]]
            }
            lappend out $backend $outcomes
        }
        return $out
    } finally {
        file delete -force $dir
    }
}

proc csvrun::Model {} {
    variable model
    variable csvDir
    if {$model eq ""} {
        set files {}
        foreach name {csv_strict csv_utf8} {
            lappend files $name [file join $csvDir $name.bot]
        }
        set model [dfaref::load $files]
    }
    return $model
}

# The declared recognizer's verdict on OUTCOME of CASE: a completed run must
# be exactly one token of the recognizer the source claims, with nothing
# unread; a failed one a viable prefix (tests/emission-support.tcl's judge,
# restated so this file needs nothing of the JSON workload).
proc csvrun::judge {case outcome} {
    variable kinds
    lassign [dict get $kinds [lindex $case 0]] source shape ns name
    lassign $outcome status at value final symbols
    set model [Model]
    set n [llength $symbols]
    if {$status eq "ok"} {
        set r [dfaref::run $model $ns $name [concat $symbols -1] 0]
        if {[lindex $r 0] eq "accept" && [lindex $r 1] == $n} {
            return ok
        }
        return [list invalid "completes with a trace that is not one ${ns}::$name token: [dfaref::text $r]"]
    }
    if {$n == 0} { return ok }
    set r [dfaref::run $model $ns $name $symbols 0]
    if {[lindex $r 0] eq "suspended" || ([lindex $r 0] eq "accept" && [lindex $r 1] == $n)} {
        return ok
    }
    return [list invalid "fails after a prefix that is no prefix of a ${ns}::$name token: [dfaref::text $r]"]
}

# Lines for oracle.py: KIND, the input, then STATUS AT VALUE FINAL and the
# symbols, tab-separated (rows split by "|", fields by ";", values by " ").
proc csvrun::write {path cases outcomes} {
    variable kinds
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    foreach case $cases outcome $outcomes {
        lassign $case kind input
        set shape [lindex [dict get $kinds $kind] 1]
        if {$shape in {document rows}} {
            set enc [join [lmap row $input {join [lmap fld $row {join [lmap x $fld {expr {$x + 0}}] " "}] ";"}] "|"]
        } else {
            set enc [join [lmap x $input {expr {$x + 0}}] " "]
        }
        lassign $outcome status at value final symbols
        puts $f [join [list $kind $enc "$status $at $value $final" [join $symbols " "]] \t]
    }
    close $f
}
