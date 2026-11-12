# bindings.tcl -- memo validity when what a claimed function reads through a
# binding changes between two compilations of one process
# (EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-MILESTONE-1.md, section
# 22.4): for each case, a valid first program, then a second whose claimed
# `emitter` has the same text and a unique name but yields 'A'. The second
# is compiled after the first with the certificate memo kept, then again
# with an empty memo; a difference is history deciding a verdict, and a
# second program proven after the first but rejected fresh is a FALSE
# CERTIFICATE. Seven of the cases are tests/emission-claims.test's
# `ec-memo-bindings`; this tool keeps all twelve.
#
#   tclsh9.0 audit/emission-identity/tools/bindings.tcl ?-out FILE?
#
# Compiles in memory (surface::compile), writes no file but -out, runs no
# program. A research instrument: nothing in compilation loads it.

set here [file dirname [file normalize [info script]]]
set options [dict merge {-out ""} $argv]
set argv {}
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

namespace eval bindings {
    variable lines {}
    variable head [string cat "import std::dfa\n\nclass digit = '0'..'9'\n\ndfa digit_token over ascii:\n" \
        "    start:\n        digit -> accept\n\ntype Digit = Int in 0..9\n\n"]
}

proc bindings::out {line} {
    variable lines
    lappend lines $line
    puts $line
}

# {FUNCTION VERDICT}... of TEXT's claims, compiled with the memo as it is.
proc bindings::Verdicts {text} {
    set hir [surface::compile $text -warnings off -strict 0]
    return [lmap r [hir::emission::claims $hir] {list [dict get $r function] [dict get $r verdict]}]
}

# The cases: NAME WHAT FIRST SECOND.
proc bindings::Cases {} {
    variable head
    set h $head
    set c {}
    lappend c captured-local "a captured local, 49 then 65" \
        "${h}fn outer() -> int:\n    k = 49\n    fn emitter() -> unit emits digit_token:\n        yield k\n        unit\n    3\n\n0\n" \
        "${h}fn outer() -> int:\n    k = 65\n    fn emitter() -> unit emits digit_token:\n        yield k\n        unit\n    3\n\n0\n"
    lappend c module-binding "a module binding, 49 then 65" \
        "${h}k = 49\n\nfn emitter() -> unit emits digit_token:\n    yield k\n    unit\n\n0\n" \
        "${h}k = 65\n\nfn emitter() -> unit emits digit_token:\n    yield k\n    unit\n\n0\n"
    lappend c moved-capture "the same code moved into another function whose captured local differs" \
        "${h}fn outer1() -> int:\n    k = 49\n    fn emitter() -> unit emits digit_token:\n        yield k\n        unit\n    3\n\n0\n" \
        "${h}fn outer2() -> int:\n    k = 65\n    fn emitter() -> unit emits digit_token:\n        yield k\n        unit\n    3\n\n0\n"
    lappend c captured-parameter-type "a captured parameter's declared type, Digit then int" \
        "${h}fn outer(d: Digit) -> int:\n    fn emitter() -> unit emits digit_token:\n        yield 48 + d\n        unit\n    3\n\n0\n" \
        "${h}fn outer(d: int) -> int:\n    fn emitter() -> unit emits digit_token:\n        yield 48 + d\n        unit\n    3\n\n0\n"
    lappend c callee-result "a helper's result value, 49 then 65" \
        "${h}fn sym() -> int:\n    49\n\nfn emitter() -> unit emits digit_token:\n    yield sym()\n    unit\n\n0\n" \
        "${h}fn sym() -> int:\n    65\n\nfn emitter() -> unit emits digit_token:\n    yield sym()\n    unit\n\n0\n"
    lappend c nested-callee "a nested helper's yield, 49 then 65" \
        "${h}fn outer() -> int:\n    fn a() -> unit:\n        yield 49\n        unit\n    fn emitter() -> unit emits digit_token:\n        a()\n        unit\n    3\n\n0\n" \
        "${h}fn outer() -> int:\n    fn a() -> unit:\n        yield 65\n        unit\n    fn emitter() -> unit emits digit_token:\n        a()\n        unit\n    3\n\n0\n"
    lappend c helper-twin "a nested helper replaced by a top-level twin of its name yielding 65" \
        "${h}fn outer() -> int:\n    fn h() -> unit:\n        yield 49\n        unit\n    fn emitter() -> unit emits digit_token:\n        h()\n        unit\n    3\n\n0\n" \
        "${h}fn h() -> unit:\n    yield 65\n    unit\n\nfn outer() -> int:\n    fn emitter() -> unit emits digit_token:\n        h()\n        unit\n    3\n\n0\n"
    lappend c function-value-choice "a module binding naming another function (a, then b)" \
        "${h}fn a() -> int:\n    49\n\nfn b() -> int:\n    65\n\nf = a\n\nfn emitter() -> unit emits digit_token:\n    yield f()\n    unit\n\n0\n" \
        "${h}fn a() -> int:\n    49\n\nfn b() -> int:\n    65\n\nf = b\n\nfn emitter() -> unit emits digit_token:\n    yield f()\n    unit\n\n0\n"
    lappend c module-function-value "the code of a function a module binding holds, yielding 49 then 65" \
        "${h}fn a() -> unit:\n    yield 49\n    unit\n\nf = a\n\nfn emitter() -> unit emits digit_token:\n    f()\n    unit\n\n0\n" \
        "${h}fn a() -> unit:\n    yield 65\n    unit\n\nf = a\n\nfn emitter() -> unit emits digit_token:\n    f()\n    unit\n\n0\n"
    lappend c captured-function-value "the code of a function a captured local holds, yielding 49 then 65" \
        "${h}fn a() -> unit:\n    yield 49\n    unit\n\nfn outer() -> int:\n    g = a\n    fn emitter() -> unit emits digit_token:\n        g()\n        unit\n    3\n\n0\n" \
        "${h}fn a() -> unit:\n    yield 65\n    unit\n\nfn outer() -> int:\n    g = a\n    fn emitter() -> unit emits digit_token:\n        g()\n        unit\n    3\n\n0\n"
    lappend c same-name-branch "two emitters of one name, the nested one's `if true:` branch 49 then 65" \
        "${h}fn outer() -> int:\n    fn emitter() -> unit emits digit_token:\n        if true:\n            yield 49\n        unit\n    3\n\nfn emitter() -> unit emits digit_token:\n    yield 50\n    unit\n\n0\n" \
        "${h}fn outer() -> int:\n    fn emitter() -> unit emits digit_token:\n        if true:\n            yield 65\n        unit\n    3\n\nfn emitter() -> unit emits digit_token:\n    yield 50\n    unit\n\n0\n"
    lappend c empty-environment-helper "a parameterless helper whose unknown `if` yields 49 or 50, then 49 or 65" \
        "${h}fn flip() -> bool:\n    true\n\nfn h() -> unit:\n    if flip():\n        yield 49\n    else:\n        yield 50\n    unit\n\nfn emitter() -> unit emits digit_token:\n    h()\n    unit\n\n0\n" \
        "${h}fn flip() -> bool:\n    true\n\nfn h() -> unit:\n    if flip():\n        yield 49\n    else:\n        yield 65\n    unit\n\nfn emitter() -> unit emits digit_token:\n    h()\n    unit\n\n0\n"
    return $c
}

proc bindings::Show {verdicts} {
    return [join [lmap v $verdicts {join $v " "}] ", "]
}

proc bindings::main {options} {
    variable lines
    set rev [expr {[catch {exec git -C $::root rev-parse --short HEAD} r] ? "?" : $r}]
    out "## Memo validity through bindings"
    out ""
    out "Generated by `tclsh9.0 audit/emission-identity/tools/bindings.tcl` at $rev."
    out ""
    out "| case | what changes | first | second, after the first (memo kept) | second, fresh | |"
    out "|---|---|---|---|---|---|"
    set differ 0
    set falseCerts 0
    foreach {name what first second} [Cases] {
        set ::hir::emission::memo [dict create]
        set a [Verdicts $first]
        set after [Verdicts $second]
        set ::hir::emission::memo [dict create]
        set fresh [Verdicts $second]
        set mark same
        if {$after ne $fresh} {
            set mark DIFFERENT
            incr differ
            foreach x $after y $fresh {
                if {[lindex $x 1] eq "proven" && [lindex $y 1] ne "proven"} {
                    set mark "DIFFERENT: FALSE CERTIFICATE"
                    incr falseCerts
                }
            }
        }
        out "| `$name` | $what | [Show $a] | [Show $after] | [Show $fresh] | $mark |"
    }
    set ::hir::emission::memo [dict create]
    out ""
    out "Cases whose verdicts depend on the memo: $differ; false certificates: $falseCerts"
    if {[dict get $options -out] ne ""} {
        set f [open [dict get $options -out] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts $f [join $lines \n]
        close $f
    }
    return [expr {$differ == 0 ? 0 : 1}]
}

exit [bindings::main $options]
