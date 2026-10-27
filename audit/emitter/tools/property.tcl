# property.tcl -- property-based and differential tests of the emitters
# (EMITTER-COROUTINE-EXPLORATION.md, "Correctness"): random integers,
# Unicode texts and value trees, emitted by every emitter on every backend,
# and each output held to
#
#   * the oracle (tools/oracle.py: CPython's json made strict): valid, and
#     denoting the case's value (the canonical text support.tcl writes,
#     every non-ASCII character escaped: a policy no emitter has);
#   * the reference interpreter of tests/dfa-support.tcl (dfaref: the
#     declarations read straight from the source, nothing of
#     surface/dfa.tcl): a token emitter's output is exactly one token of its
#     recognizer, a text's one json_text;
#   * in the program, the integrated recognizers and decoder of
#     examples/dfa/json/json.bot: the text validates (structure included),
#     whole and in random chunks, and a string decodes to the text it was
#     emitted from (decode(emit(text)) == text, over scalar values and over
#     UTF-8 bytes);
#   * every backend agreeing on every output.
#
#   tclsh9.0 audit/emitter/tools/property.tcl ?-seed N? ?-ints N? ?-texts N?
#       ?-values N? ?-depth N? ?-backends LIST? ?-mutate CASE? ?-out FILE?
#
# -mutate applies a census case (census/cases.txt) first: the harness's
# power against a mistake the checker cannot see.
#
# Prints a summary and every failure; exits 1 on any.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -seed 1 -ints 60 -texts 60 -values 30 -depth 4 \
    -backends {interp compile cranelift-generic cranelift cranelift-unfused} -mutate "" -out ""]
foreach {option value} $argv {
    dict set options $option $value
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root tests dfa-support.tcl]
source [file join $root audit emitter tools workspace.tcl]
source [file join $root audit emitter tools support.tcl]
interp recursionlimit {} 100000
core::useProgramRecursionLimit

namespace eval emitprop {}

# The program of the cases, and what each of its outputs is:
# {OUTPUTS PROGRAM}, OUTPUTS a list of {KIND RECOGNIZER EXPECTED CASE}
# (KIND unicode | bytes | check; RECOGNIZER the token's, for dfaref).
proc emitprop::program {ints texts values} {
    set outputs {}
    set exprs {}
    foreach n $ints {
        foreach f {collect_integer collect_integer_text validated_integer buffered_integer} {
            lappend exprs "sinks::${f}($n)"
            lappend outputs [list unicode json_number $n "integer $n ($f)"]
        }
    }
    foreach t $texts {
        set l [emitsup::literal $t]
        set j [emitsup::jsonString $t]
        set shown [string range [emitsup::jsonString $t] 0 40]
        lappend exprs "sinks::collect_string($l)" "sinks::collect_string_ascii($l)" \
            "sinks::collect_string_bytes($l)" "sinks::collect_string_codes(\[[join [emitsup::scalars $t] {, }]\])" \
            "round_trip($l)" "round_trip_ascii($l)" "round_trip_bytes($l)"
        lappend outputs [list unicode json_string $j "string $shown (string)"] \
            [list unicode json_string_strict $j "string $shown (string_ascii)"] \
            [list bytes json_string_bytes $j "string $shown (string_bytes)"] \
            [list unicode json_string_strict $j "string $shown (string_codes)"] \
            [list check "" 1 "decode(string(t)) == t: $shown"] \
            [list check "" 1 "decode(string_ascii(t)) == t: $shown"] \
            [list check "" 1 "decode_bytes(string_bytes(t)) == utf8(t): $shown"]
    }
    set k 0
    foreach v $values {
        set b [emitsup::botlish $v]
        set j [emitsup::json $v]
        set shown [string range $j 0 40]
        set sizes [lmap i {1 2 3} {expr {1 + [emitsup::below 9]}}]
        lappend exprs "sinks::collect_text($b)" "sinks::collect_stacked($b)" "sinks::collect_flat($b)" \
            "validated(sinks::collect_text($b), \[[join $sizes {, }]\])" \
            "digests($b)"
        lappend outputs [list unicode json_text $j "value $shown (value)"] \
            [list unicode json_text $j "value $shown (value_stacked)"] \
            [list unicode json_text $j "value $shown (value_flat)"] \
            [list check "" ok "json::validate_scalars over chunks of $sizes: $shown"] \
            [list check "" digest "digest = chunked digest = the text's: $shown"]
        incr k
    }
    set text {import sinks
import json
import value_emit
import std::str
import std::char
import std::list
import std::mutable_vector
import std::mutable_array

fn no_keys() -> List[str]:
    []

fn scalars(t: str) -> List[int] errors IndexNotFound:
    loop i from 0 to std::str::length(t):
        std::char::scalar_value(t.char_at(i))

fn same(a: List[int], b: List[int]) -> List[int]:
    if a == b:
        return [1]
    [0]

fn round_trip(t: str) -> List[int] errors IndexNotFound, json::UnpairedSurrogate:
    same(json::decode_symbols(sinks::collect_string(t)), scalars(t))

fn round_trip_ascii(t: str) -> List[int] errors IndexNotFound, json::UnpairedSurrogate:
    same(json::decode_symbols(sinks::collect_string_ascii(t)), scalars(t))

fn round_trip_bytes(t: str) -> List[int] errors IndexNotFound, json::UnpairedSurrogate:
    utf8 = loop b in std::str::encode_utf8(t):
        0 + b
    same(json::decode_bytes(sinks::collect_string_bytes(t)), utf8)

# XS cut into chunks of the sizes SIZES, cyclically.
fn split(xs: List[int], sizes: List[int]) -> List[List[int]] errors IndexNotFound:
    out = std::mutable_vector::from_list([[0]])
    out.pop()
    cursor = std::mutable_array::create(2, 0)
    n = std::list::length(xs)
    loop:
        p = std::mutable_array::at(cursor, 0)
        if p >= n:
            break
        k = std::mutable_array::at(cursor, 1)
        size = std::list::at(sizes, k.mod(std::list::length(sizes)))
        e = if p + size > n:
            n
        else:
            p + size
        chunk = loop i from p to e:
            std::list::at(xs, i)
        out.push(chunk)
        cursor.set(0, e)
        cursor.set(1, k + 1)
    loop c in out:
        c

fn validated(xs: List[int], sizes: List[int]) -> List[int] errors IndexNotFound:
    s = json::validate_scalars(xs.split(sizes), 1000, 100000000):
        on json::Lexical:
            return [-1]
        on json::Truncated:
            return [-2]
        on json::Structure:
            return [-3]
        on json::TooDeep:
            return [-4]
        on json::TokenTooLong:
            return [-5]
    [s.symbols]

fn digests(v: value_emit::Value) -> List[int] errors IndexNotFound:
    d = sinks::digest_stacked(v)
    e = sinks::chunked_stacked(v)
    f = sinks::digest_text(v)
    [d.digest, e.digest, f.digest, d.symbols, e.symbols, f.symbols]

fn all() -> List[List[int]] errors IndexNotFound, json::UnpairedSurrogate, sinks::Invalid, number_emit::NotCanonical, string_emit::NotAScalar:
    [
}
    append text "        [join $exprs ",\n        "],\n    \]\n\n"
    append text {all():
    on IndexNotFound:
        [[-100]]
    on json::UnpairedSurrogate:
        [[-101]]
    on sinks::Invalid:
        [[-102]]
    on number_emit::NotCanonical:
        [[-103]]
    on string_emit::NotAScalar:
        [[-104]]
}
    set text [string map {"import sinks\n" "import sinks\nimport number_emit\nimport string_emit\n"} $text]
    return [list $outputs $text]
}

proc emitprop::run {options} {
    emitsup::seed [dict get $options -seed]
    set ints [list 0 -1 1 9 10 -10 99 100 [expr {2 ** 63}] [expr {-2 ** 63}] [expr {10 ** 40}]]
    for {set i 0} {$i < [dict get $options -ints]} {incr i} {
        lappend ints [emitsup::integer]
    }
    set texts [list "" "\"" "\\" "\u0000\u001f\u007f" "a\u2028b" "\uD7FF\uE000\uFFFF" [format %c 0x10000][format %c 0x10FFFF] "/"]
    for {set i 0} {$i < [dict get $options -texts]} {incr i} {
        lappend texts [emitsup::text]
    }
    # One long text.
    set long ""
    for {set i 0} {$i < 2000} {incr i} {
        append long [format %c [emitsup::scalar]]
    }
    lappend texts $long
    set values [list {null} {true} {array {}} {object {}} {array {{array {}} {object {}}}} \
        {object {{a {number 1}} {a {number 2}}}} {array {{number 1} {number -2} {number 0}}}]
    for {set i 0} {$i < [dict get $options -values]} {incr i} {
        lappend values [emitsup::value [dict get $options -depth]]
    }
    lassign [program $ints $texts $values] outputs text
    set dir [emitws::scratch main.bot $text]
    if {[dict getdef $options -mutate ""] ne ""} {
        emitsup::mutate $dir [dict get $options -mutate]
    }
    set hir [surface::readProgramFile [file join $dir main.bot] -warnings off]
    set results [dict create]
    set failures {}
    foreach b [dfatest::hosted [dict get $options -backends]] {
        set t0 [clock milliseconds]
        set outcome [outcomeUnderHir $b $hir]
        dict set results $b [list [lindex $outcome 0] [lindex $outcome 1]]
        puts "$b: [lindex $outcome 0] ([expr {[clock milliseconds] - $t0}] ms)"
    }
    set distinct [lsort -unique [dict values $results]]
    if {[llength $distinct] != 1} {
        lappend failures "backends disagree: [dict keys $results]"
    }
    set first [lindex [dict values $results] 0]
    if {[lindex $first 0] ne "value"} {
        lappend failures "the program fails: [lindex $first 1]"
        return [list 0 $failures]
    }
    set lists [emitsup::lists [lindex $first 1]]
    if {[llength $lists] != [llength $outputs]} {
        lappend failures "[llength $lists] outputs, [llength $outputs] expected"
        return [list 0 $failures]
    }
    # The oracle and the reference interpreter.
    set model [dfaref::load [list json_lex [file join $dir json_lex.bot] json_grammar [file join $dir json_grammar.bot]]]
    set lines {}
    set which {}
    set checked 0
    set digest ""
    foreach out $lists o $outputs {
        lassign $o kind recognizer expected what
        if {$kind eq "check"} {
            incr checked
            if {$expected eq "ok"} {
                if {[lindex $out 0] < 0} {
                    lappend failures "$what: json.bot rejects it ([lindex $out 0])"
                }
            } elseif {$expected eq "digest"} {
                lassign $out d e f n1 n2 n3
                if {$d != $e || $d != $f || $n1 != $n2 || $n1 != $n3} {
                    lappend failures "$what: $out"
                }
            } elseif {$out ne $expected} {
                lappend failures "$what: $out"
            }
            continue
        }
        set ns [expr {$recognizer eq "json_text" ? "json_grammar" : "json_lex"}]
        set ref [dfaref::text [dfaref::run $model $ns $recognizer [concat $out -1] 0]]
        if {$ref ne "accept [llength $out] 0"} {
            lappend failures "$what: the reference interpreter's $recognizer says $ref"
        }
        lappend lines [emitsup::case $kind $out $expected]
        lappend which $what
    }
    foreach v [emitsup::oracle $lines] what $which {
        if {![string match "valid * equal" $v]} {
            lappend failures "$what: the oracle says $v"
        }
    }
    puts "[llength $ints] integers, [llength $texts] texts, [llength $values] values: [llength $lines] outputs held to the oracle and the reference interpreter, $checked in-program checks, [llength $failures] failures"
    return [list [llength $lines] $failures]
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    lassign [emitprop::run $options] n failures
    foreach f [lrange $failures 0 40] {
        puts "FAIL $f"
    }
    if {[dict get $options -out] ne ""} {
        set f [open [dict get $options -out] a]
        puts $f "seed [dict get $options -seed]: $n outputs, [llength $failures] failures"
        close $f
    }
    exit [expr {[llength $failures] > 0}]
}
