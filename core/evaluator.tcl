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
        return      core::forms::op-return \
        break       core::forms::op-break \
        continue    core::forms::op-continue \
        ok          core::forms::op-ok \
        error-value core::forms::op-error-value]
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

# (listloop LIST-EXPR (block (ELEM) BODY...)): evaluates LIST-EXPR once,
# then iterates its items left to right, each iteration in a fresh scope
# (exactly like op-loop's own body) that binds ELEM to the current item.
# `return`/an error propagate directly out of the loop, exactly as they
# already do in op-loop; `break` ends the loop with its own payload (or
# unit) as the *whole* listloop's result; an ordinary (`value`) completion
# contributes its value to the result being built, while `continue`
# contributes nothing -- both simply move on to the next item. Exhausting
# the list without a `break` completes normally with the List of every
# contributed value, in order.
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
                return [core::completion::normal [core::completion::payload $completion]]
            }
            return - propagate-error {
                return $completion
            }
        }
    }
    return [core::completion::normal [core::value::listOf $results]]
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
        set value [core::completion::atProgramBoundary [core::RunWithBackend program $exprs $env]]
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
