# evaluator.tcl -- the interpreter backend, and the public API.
#
# Each IR operation has one handler, `core::forms::op-NAME {node env}`,
# returning a completion. Handlers delegate to the centralized modules:
#
#   env.tcl         lookup and binding
#   completion.tcl  completion construction and boundaries
#   callable.tcl    call dispatch
#   block.tcl       block creation and invocation
#   native.tcl      native registry
#   refine.tcl      branch refinement
#   runtime.tcl     rules shared with the compiler
#
# Scopes: every scope declares the names it binds when it is entered
# (core::ir::scopeBindNames), so a name denotes the same binding throughout
# its scope.

namespace eval core {
    # Backend name -> {sequence CMD program CMD}. Both commands take
    # {EXPRS ENV} and return a completion. `sequence` runs EXPRS in an
    # arbitrary existing environment. `program` runs statically checked
    # EXPRS in a fresh program scope (declared, child of a fresh root), which
    # a backend may exploit, e.g. by knowing the root's contents.
    variable backends [dict create interp [dict create \
        sequence core::interp::evalSequence program core::interp::evalSequence]]
    variable backend interp
}

namespace eval core::interp {
    variable forms [dict create \
        const       core::forms::op-const \
        bind        core::forms::op-bind \
        ref         core::forms::op-ref \
        block       core::forms::op-block \
        call        core::forms::op-call \
        if          core::forms::op-if \
        loop        core::forms::op-loop \
        listloop    core::forms::op-listloop \
        countloop   core::forms::op-countloop \
        lockloop    core::forms::op-lockloop \
        return      core::forms::op-return \
        break       core::forms::op-break \
        continue    core::forms::op-continue \
        struct      core::forms::op-struct \
        project     core::forms::op-project \
        ok          core::forms::op-ok \
        error-value core::forms::op-error-value \
        fail        core::forms::op-fail \
        handle      core::forms::op-handle]
}

namespace eval core::forms {}

# ---------------------------------------------------------------------------
# Interpreter core

# Evaluates one node in ENV. Returns a completion.
proc core::interp::evalIn {node env} {
    variable forms
    core::ir::checkShape $node
    set op [core::ir::op $node]
    if {![dict exists $forms $op]} {
        error "core::interp::evalIn: no handler for operation \"$op\""
    }
    return [[dict get $forms $op] $node $env]
}

# Evaluates EXPRS in order in ENV. The first abrupt completion ends the
# sequence; otherwise the completion of the last expression is returned.
# An empty sequence completes normally with unit.
proc core::interp::evalSequence {exprs env} {
    set completion [core::completion::normal [core::value::unit]]
    foreach expr $exprs {
        set completion [evalIn $expr $env]
        if {![core::completion::isNormal $completion]} {
            return $completion
        }
    }
    return $completion
}

# Enters a new scope for EXPRS under PARENT-ENV. Returns the scope's env.
proc core::interp::enterScope {parentEnv exprs} {
    set env [core::env::child $parentEnv]
    core::env::declare $env [core::ir::scopeBindNames $exprs]
    return $env
}

# Unwraps a normal completion to its value. For any abrupt completion, makes
# the *calling handler* return that completion immediately, which is exactly
# the propagation rule for sub-expressions. (Implemented with Tcl's
# `return -level 2`; the propagated thing is still an explicit completion.)
proc core::interp::valueOf {completion} {
    if {[core::completion::isNormal $completion]} {
        return [core::completion::payload $completion]
    }
    return -level 2 $completion
}

# ---------------------------------------------------------------------------
# Forms

proc core::forms::op-const {node env} {
    return [core::completion::normal [core::ir::literalValue $node]]
}

proc core::forms::op-bind {node env} {
    set name [lindex $node 1]
    set value [core::interp::valueOf [core::interp::evalIn [lindex $node 2] $env]]
    core::env::define $env $name $value
    return [core::completion::normal $value]
}

proc core::forms::op-ref {node env} {
    return [core::completion::normal [core::env::lookup $env [lindex $node 1]]]
}

proc core::forms::op-block {node env} {
    set blockValue [core::block::make \
        [core::ir::blockParams $node] [core::ir::blockBody $node] $env]
    return [core::completion::normal $blockValue]
}

proc core::forms::op-call {node env} {
    # Callee first, then arguments strictly left to right.
    set callee [core::interp::valueOf [core::interp::evalIn [lindex $node 1] $env]]
    set argValues {}
    foreach argNode [lrange $node 2 end] {
        lappend argValues [core::interp::valueOf [core::interp::evalIn $argNode $env]]
    }
    return [core::callable::invoke $callee $argValues]
}

proc core::forms::op-if {node env} {
    set condition [lindex $node 1]
    set test [core::interp::valueOf [core::interp::evalIn $condition $env]]
    set outcome [core::runtime::conditionOutcome $test]
    set body [core::ir::blockBody [lindex $node [expr {$outcome ? 2 : 3}]]]

    # The branch body runs inline (no callable boundary) in a fresh scope
    # that carries the facts proven by the condition.
    set branchEnv [core::interp::enterScope $env $body]
    try {
        core::refine::install $branchEnv [core::refine::branchFacts $condition $env $outcome]
        return [core::interp::evalSequence $body $branchEnv]
    } finally {
        core::env::release $branchEnv
    }
}

proc core::forms::op-loop {node env} {
    set body [core::ir::blockBody [lindex $node 1]]
    while 1 {
        # Each iteration is a fresh scope.
        set iterationEnv [core::interp::enterScope $env $body]
        try {
            set completion [core::interp::evalSequence $body $iterationEnv]
        } finally {
            core::env::release $iterationEnv
        }
        switch -- [core::completion::kind $completion] {
            value - continue {
                # next iteration
            }
            break {
                return [core::completion::normal [core::completion::payload $completion]]
            }
            return - propagate-error {
                return $completion
            }
        }
    }
}

# (listloop LIST-EXPR (block (ELEM) BODY...)): the returning iterable loop
# (RETURNING-ITERABLE-LOOPS.md). Evaluates LIST-EXPR once, then iterates its
# items left to right, each iteration in a fresh scope (exactly like
# op-loop's own body) that binds ELEM to the current item. `return`/an
# error propagate directly out of the loop, exactly as they already do in
# op-loop; an ordinary (`value`) completion contributes its value to the
# result being built, `continue` contributes nothing, and `break` ends the
# loop immediately, its result becoming the List collected so far (the
# accumulated prefix) -- never the break's own payload: a listloop has
# exactly one stable result type, List[R], and a `break VALUE` reaching
# here is not something any HIR-checked program can produce (hir/resolve.
# tcl's LISTLOOP-BREAK-VALUE diagnostic rejects it at compile time), so its
# payload, if present at the raw core-IR level, is simply not consulted --
# a bare `break` and a `break VALUE` behave identically here, both ending
# the loop with the prefix. Exhausting the list without a `break` completes
# normally with the List of every contributed value, in order.
proc core::forms::op-listloop {node env} {
    set listExpr [lindex $node 1]
    set elementBlock [lindex $node 2]
    set param [lindex [core::ir::blockParams $elementBlock] 0]
    set body [core::ir::blockBody $elementBlock]
    set listValue [core::interp::valueOf [core::interp::evalIn $listExpr $env]]
    set items [core::value::items [core::value::expect list $listValue "loop iterable"]]
    set results {}
    foreach item $items {
        set iterationEnv [core::env::child $env]
        core::env::define $iterationEnv $param $item
        core::env::declare $iterationEnv [core::ir::scopeBindNames $body]
        try {
            set completion [core::interp::evalSequence $body $iterationEnv]
        } finally {
            core::env::release $iterationEnv
        }
        switch -- [core::completion::kind $completion] {
            value {
                lappend results [core::completion::payload $completion]
            }
            continue {
                # contributes nothing; next iteration
            }
            break {
                return [core::completion::normal [core::value::listOf $results]]
            }
            return - propagate-error {
                return $completion
            }
        }
    }
    return [core::completion::normal [core::value::listOf $results]]
}

# (countloop START-EXPR END-EXPR (block (I) BODY...) ?DIRECTION ENDKIND?):
# the numeric collecting loop (COLLECTING-LOOPS.md). Evaluates START-EXPR
# then END-EXPR once each, left to right, in the enclosing scope -- exactly
# like op-listloop's own LIST-EXPR. Iterates the Int induction value I from
# START by +1 (`up`) or -1 (`down`), each iteration in a fresh scope that
# binds I, for as long as I is still on the near side of END:
#
#     up   to       I <  END       up   through  I <= END
#     down to       I >  END       down through  I >= END
#
# The inclusive forms test END with <=/>= directly: no END+1 / END-1 is ever
# formed, so the loop is exactly as correct for a Botlish Int of any
# magnitude as the exclusive forms. The result is collected exactly like
# op-listloop's (a `value` completion contributes its value, `continue`
# nothing, a bare `break` ends the loop with the List collected so far,
# `return`/an error propagate directly); START/END must be Int, checked
# dynamically (core::value::expect), exactly like every other Int
# operation's own runtime discipline (core/primitives.tcl) -- not a new
# loop-only error kind. Advances I with plain `expr`, never Tcl's `incr`:
# AGENTS.md documents a confirmed Tcl-core bug where `incr` inside a
# compiled proc silently wraps at the i64 boundary instead of promoting to a
# bignum, so this loop -- which must remain correct for a Botlish Int of any
# magnitude -- follows core/primitives.tcl's own arbitrary-precision
# `expr`-only idiom throughout.
proc core::forms::op-countloop {node env} {
    set startExpr [lindex $node 1]
    set endExpr [lindex $node 2]
    set elementBlock [lindex $node 3]
    set param [lindex [core::ir::blockParams $elementBlock] 0]
    set body [core::ir::blockBody $elementBlock]
    set startValue [core::interp::valueOf [core::interp::evalIn $startExpr $env]]
    set endValue [core::interp::valueOf [core::interp::evalIn $endExpr $env]]
    set i [core::value::intOf [core::value::expect int $startValue "loop start"]]
    set end [core::value::intOf [core::value::expect int $endValue "loop end"]]
    lassign [core::ir::countOptions $node] direction endKind
    set holds [core::forms::CountTest $direction $endKind]
    set step [expr {$direction eq "up" ? 1 : -1}]
    set results {}
    while {[$holds $i $end]} {
        set iterationEnv [core::env::child $env]
        core::env::define $iterationEnv $param [core::value::intFromNumber $i]
        core::env::declare $iterationEnv [core::ir::scopeBindNames $body]
        try {
            set completion [core::interp::evalSequence $body $iterationEnv]
        } finally {
            core::env::release $iterationEnv
        }
        switch -- [core::completion::kind $completion] {
            value {
                lappend results [core::completion::payload $completion]
            }
            continue {
                # contributes nothing; advance to the next iteration
            }
            break {
                return [core::completion::normal [core::value::listOf $results]]
            }
            return - propagate-error {
                return $completion
            }
        }
        set i [expr {$i + $step}]
    }
    return [core::completion::normal [core::value::listOf $results]]
}

# The command that tests "is I still inside the domain" for a numeric loop of
# DIRECTION (up|down) and ENDKIND (exclusive|inclusive), called as
# `$cmd I END` on arbitrary-precision Tcl integers.
proc core::forms::CountTest {direction endKind} {
    switch -- $direction/$endKind {
        up/exclusive   { return ::tcl::mathop::< }
        up/inclusive   { return ::tcl::mathop::<= }
        down/exclusive { return ::tcl::mathop::> }
        down/inclusive { return ::tcl::mathop::>= }
    }
    error "core::forms::CountTest: bad $direction/$endKind"
}

# The exact number of values a numeric domain from START toward END visits:
# max(END - START, 0) (+1 when inclusive) for `up`, max(START - END, 0) (+1
# when inclusive) for `down` -- the mathematical cardinality of
# hir/cardinality.tcl, on arbitrary-precision integers.
proc core::forms::CountSize {direction endKind start end} {
    set span [expr {$direction eq "up" ? $end - $start : $start - $end}]
    if {$endKind eq "inclusive"} {
        set span [expr {$span + 1}]
    }
    return [expr {$span > 0 ? $span : 0}]
}

# (lockloop (DOMAIN...) (block (P...) BODY...) ?REJECTED?): the lockstep
# collecting loop (COLLECTING-LOOPS.md). Every DOMAIN operand is evaluated
# once, left to right, in the enclosing scope; then body iteration k binds
# every parameter to the k-th element of its own domain, the loop's result
# being collected exactly like op-countloop's/op-listloop's.
#
# All domains must have the same element count -- a *static* obligation that
# HIR discharges (hir/lockstep.tcl): a loop that could not be proven never
# reaches the evaluator (strict builds raise the diagnostic; a -strict 0
# lowering appends REJECTED, whose message is replayed here, unconditionally,
# before anything is evaluated). There is no runtime length check as
# language semantics and no shortest-wins rule. This reference interpreter
# does cross-check the proof it was handed -- a mismatch is a bug in the
# compiler's proof, reported as an internal error, which is what makes the
# differential fuzzers catch an unsound cardinality rule.
proc core::forms::op-lockloop {node env} {
    if {[llength $node] == 4} {
        regexp {^(\S+): (.*)$} [lindex $node 3] -> kind message
        core::semanticError $kind $message
    }
    set params [core::ir::blockParams [lindex $node 2]]
    set body [core::ir::blockBody [lindex $node 2]]
    set domains {}
    foreach domain [lindex $node 1] {
        if {[lindex $domain 0] eq "list"} {
            set listValue [core::interp::valueOf [core::interp::evalIn [lindex $domain 1] $env]]
            set items [core::value::items [core::value::expect list $listValue "loop iterable"]]
            lappend domains [list list $items [llength $items]]
        } else {
            set startValue [core::interp::valueOf [core::interp::evalIn [lindex $domain 1] $env]]
            set endValue [core::interp::valueOf [core::interp::evalIn [lindex $domain 2] $env]]
            set start [core::value::intOf [core::value::expect int $startValue "loop start"]]
            set end [core::value::intOf [core::value::expect int $endValue "loop end"]]
            lassign [core::ir::countOptions [list countloop {} {} {} [lindex $domain 3] [lindex $domain 4]]] \
                direction endKind
            lappend domains [list count $start [expr {$direction eq "up" ? 1 : -1}] \
                [core::forms::CountSize $direction $endKind $start $end]]
        }
    }
    set total [lindex $domains 0 end]
    foreach domain $domains {
        if {[lindex $domain end] != $total} {
            error "lockloop: iteration counts differ at run time ([lmap d $domains {lindex $d end}]):\
                the compiler's equal-cardinality proof was wrong"
        }
    }
    set results {}
    for {set k 0} {$k < $total} {incr k} {
        set iterationEnv [core::env::child $env]
        foreach param $params domain $domains {
            if {[lindex $domain 0] eq "list"} {
                core::env::define $iterationEnv $param [lindex [lindex $domain 1] $k]
            } else {
                core::env::define $iterationEnv $param \
                    [core::value::intFromNumber [expr {[lindex $domain 1] + $k * [lindex $domain 2]}]]
            }
        }
        core::env::declare $iterationEnv [core::ir::scopeBindNames $body]
        try {
            set completion [core::interp::evalSequence $body $iterationEnv]
        } finally {
            core::env::release $iterationEnv
        }
        switch -- [core::completion::kind $completion] {
            value {
                lappend results [core::completion::payload $completion]
            }
            continue {
                # contributes nothing; every domain advances together
            }
            break {
                return [core::completion::normal [core::value::listOf $results]]
            }
            return - propagate-error {
                return $completion
            }
        }
    }
    return [core::completion::normal [core::value::listOf $results]]
}

# (struct HEAD NAME EXPR ...): evaluates every EXPR strictly in written
# order (the first abrupt completion propagates, and no struct value has
# been built by then: nothing partially initialized is ever observable),
# then builds the struct value. The shape is the anonymous canonical (sorted)
# field set, or, for a named struct, HEAD's declaration identity and
# declared slot order -- the written names must be exactly that field set.
# Field values are placed into their slots only after all are evaluated:
# canonical layout never reorders evaluation.
proc core::forms::op-struct {node env} {
    set names {}
    set values {}
    foreach {name expr} [lrange $node 2 end] {
        lappend values [core::interp::valueOf [core::interp::evalIn $expr $env]]
        lappend names $name
    }
    return [core::completion::normal [core::runtime::structNew [lindex $node 1] $names $values]]
}

# (project EXPR NAME): field NAME of the struct value of EXPR.
proc core::forms::op-project {node env} {
    set receiver [core::interp::valueOf [core::interp::evalIn [lindex $node 1] $env]]
    return [core::completion::normal [core::runtime::project $receiver [lindex $node 2]]]
}

proc core::forms::op-return {node env} {
    set value [core::interp::valueOf [core::interp::evalIn [lindex $node 1] $env]]
    return [core::completion::returning $value]
}

proc core::forms::op-break {node env} {
    if {[llength $node] == 1} {
        return [core::completion::breaking [core::value::unit]]
    }
    set value [core::interp::valueOf [core::interp::evalIn [lindex $node 1] $env]]
    return [core::completion::breaking $value]
}

proc core::forms::op-continue {node env} {
    return [core::completion::continuing]
}

proc core::forms::op-ok {node env} {
    set value [core::interp::valueOf [core::interp::evalIn [lindex $node 1] $env]]
    return [core::completion::normal [core::value::ok $value]]
}

proc core::forms::op-error-value {node env} {
    set value [core::interp::valueOf [core::interp::evalIn [lindex $node 1] $env]]
    return [core::completion::normal [core::value::err $value]]
}

# (fail NAME): the named-error production primitive
# (EXPLICIT-ERROR-COMPLETIONS.md). Always produces propagate-error; whether
# NAME is admissible here (declared/handled) is a HIR-level static
# obligation (hir/errorsets.tcl), not something the evaluator enforces.
proc core::forms::op-fail {node env} {
    return [core::completion::propagatingError [core::value::errorId [lindex $node 1]]]
}

# (handle CALL-EXPR NAME1 HANDLER-BLOCK1 ...): evaluates CALL-EXPR (always a
# (call ...) node). A normal completion, or any abrupt completion other than
# a propagate-error matching one of NAME1, NAME2, ..., passes through
# unchanged. A matching propagate-error instead runs that handler's body
# inline (a fresh child scope, exactly like an `if` branch -- no callable
# boundary, so `return`/`break`/`continue` inside it affect the enclosing
# callable/loop), and `handle` completes however that body does.
proc core::forms::op-handle {node env} {
    set callCompletion [core::interp::evalIn [lindex $node 1] $env]
    if {[core::completion::kind $callCompletion] ne "propagate-error"} {
        return $callCompletion
    }
    set errorName [core::value::errorIdName [core::completion::payload $callCompletion]]
    foreach {name handlerBlock} [lrange $node 2 end] {
        if {$name eq $errorName} {
            set body [core::ir::blockBody $handlerBlock]
            set branchEnv [core::interp::enterScope $env $body]
            try {
                return [core::interp::evalSequence $body $branchEnv]
            } finally {
                core::env::release $branchEnv
            }
        }
    }
    return $callCompletion
}

# ---------------------------------------------------------------------------
# Backends

proc core::registerBackend {name sequenceCommand {programCommand ""}} {
    variable backends
    if {$programCommand eq ""} {
        set programCommand $sequenceCommand
    }
    dict set backends $name [dict create sequence $sequenceCommand program $programCommand]
}

proc core::backends {} {
    variable backends
    return [dict keys $backends]
}

# Selects the backend used by eval, evalProgram and evalIn.
# With no argument, returns the current backend.
proc core::useBackend {{name ""}} {
    variable backends
    variable backend
    if {$name ne ""} {
        if {![dict exists $backends $name]} {
            error "core::useBackend: unknown backend \"$name\" (known: [dict keys $backends])"
        }
        set backend $name
    }
    return $backend
}

proc core::RunWithBackend {mode exprs env} {
    variable backends
    variable backend
    return [{*}[dict get $backends $backend $mode] $exprs $env]
}

# ---------------------------------------------------------------------------
# Public API

# A fresh root environment: every registered native, plus true, false, unit.
# These are ordinary immutable bindings.
proc core::rootEnv {} {
    set env [core::env::new ""]
    foreach name [core::native::names] {
        core::env::define $env $name [core::value::native $name]
    }
    core::env::define $env true  [core::value::true]
    core::env::define $env false [core::value::false]
    core::env::define $env unit  [core::value::unit]
    return $env
}

# Statically checks a top-level expression (shapes and control placement).
proc core::check {node} {
    core::ir::check $node
}

# Evaluates a program: a list of expressions run in order in one program
# scope (a child of a fresh root environment). Returns the value of the last
# expression. Escaping control flow is an invalid program.
proc core::evalProgram {exprs} {
    foreach expr $exprs {
        core::ir::check $expr
    }
    set mark [core::env::mark]
    set env [core::env::child [core::rootEnv]]
    core::env::declare $env [core::ir::scopeBindNames $exprs]
    set value ""
    try {
        # Every run starts with an empty execution-environment context set
        # (core/contexts.tcl, CONTEXTS.md).
        # So does the coroutine store (core/coroutines.tcl): coroutines a run
        # leaves suspended end with it.
        set value [core::contexts::fresh {
            core::coroutines::fresh {
                core::completion::atProgramBoundary [core::RunWithBackend program $exprs $env]
            }
        }]
    } finally {
        core::releaseProgram $mark $value
    }
    return $value
}

# Ends a program run: the frames created since MARK are dropped unless the
# program's value VALUE ("" if it failed) contains a Block, which may still
# refer to them (for example as a refinement probe).
proc core::releaseProgram {mark value} {
    if {$value eq "" || ![core::value::containsBlock $value]} {
        core::env::releaseSince $mark
    }
}

# Evaluates a single top-level expression. Returns its value.
proc core::eval {node} {
    return [core::evalProgram [list $node]]
}

# Evaluates NODE directly in the existing environment ENV (no new scope, no
# static checks). Returns a completion.
proc core::evalIn {node env} {
    return [core::RunWithBackend sequence [list $node] $env]
}

proc core::childEnv {env}                { return [core::env::child $env] }
proc core::envDefine {env name value}    { core::env::define $env $name $value; return }
proc core::envBindings {env}             { return [core::env::localBindings $env] }
proc core::envRefinements {env}          { return [core::env::visibleRefinements $env] }
proc core::refinementsOf {env name}      { return [core::env::refinementsOf $env $name] }
proc core::blockEnv {blockValue}         { return [core::value::blockEnv $blockValue] }
proc core::formatValue {value}           { return [core::value::show $value] }
proc core::formatCompletion {completion} { return [core::completion::show $completion] }
proc core::registerNative {name args}    { return [core::native::register $name {*}$args] }
