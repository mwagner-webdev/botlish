# results.tcl -- `==` of Result values (EQUALITY-SEMANTIC-CENSUS.md,
# section 3), which no source program can build: `ok(v)` and `error(v)` are
# core IR forms ({ok E}, {error-value E}) with no surface syntax
# (docs/README.md, section 4), so each case here is a core IR program,
# run on the reference interpreter, the Tcl compiler (core IR text, read
# into HIR by hir::build) and the native backend (native::evalHir of that
# HIR).
#
#   tclsh9.0 audit/equality-semantics/tools/results.tcl
#
# Prints each case's outcome per backend: `value V` or `error ERRORCODE`.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set ::argv {}
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]

set cases {
    "ok(1) == ok(1)"
        {{call {ref ==} {ok {const 1}} {ok {const 1}}}}
    "ok(1) == ok(\"1\")  (payloads of disjoint kinds)"
        {{call {ref ==} {ok {const 1}} {ok {const str 1}}}}
    "ok(1) == error(1)  (tags differ, payloads equal)"
        {{call {ref ==} {ok {const 1}} {error-value {const 1}}}}
    "error(\"x\") == error(\"x\")  (the shared variant of two Result shapes)"
        {{call {ref ==} {error-value {const str x}} {error-value {const str x}}}}
    "ok(f) == error(1)  (a callable payload, tags differ)"
        {{bind f {block {x} {ref x}}} {call {ref ==} {ok {ref f}} {error-value {const 1}}}}
    "ok(f) == ok(f)  (a callable payload reached)"
        {{bind f {block {x} {ref x}}} {call {ref ==} {ok {ref f}} {ok {ref f}}}}
    "ok([]) == ok([])  (empty Lists in the payload)"
        {{call {ref ==} {ok {call {ref list}}} {ok {call {ref list}}}}}
}

proc Outcome {backend exprs} {
    try {
        switch -- $backend {
            interp {
                core::useBackend interp
                set v [core::evalProgram $exprs]
            }
            compile {
                set v [lindex [core::compiler::runProgram $exprs [core::env::child [core::rootEnv]]] 1]
            }
            cranelift {
                set v [native::evalHir [hir::build $exprs -strict 0]]
            }
        }
        return "value [core::formatValue $v]"
    } on error {message options} {
        return "error [dict get $options -errorcode]: [lindex [split $message \n] 0]"
    }
}

foreach {label exprs} $cases {
    puts "== $label"
    foreach backend {interp compile cranelift} {
        puts "  [format %-10s $backend] [Outcome $backend $exprs]"
    }
}
