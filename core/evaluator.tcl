# evaluator.tcl -- semantic evaluation of core IR, and the public API.
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

namespace eval core {
    variable forms [dict create \
        const       core::forms::op-const \
        bind        core::forms::op-bind \
        ref         core::forms::op-ref \
        block       core::forms::op-block \
        call        core::forms::op-call \
        if          core::forms::op-if \
        loop        core::forms::op-loop \
        return      core::forms::op-return \
        break       core::forms::op-break \
        continue    core::forms::op-continue \
        ok          core::forms::op-ok \
        error-value core::forms::op-error-value]
}

namespace eval core::forms {}

# ---------------------------------------------------------------------------
# Evaluation core

# Evaluates one node in ENV. Returns a completion.
proc core::evalIn {node env} {
    variable forms
    core::ir::checkShape $node
    set op [core::ir::op $node]
    if {![dict exists $forms $op]} {
        error "core::evalIn: no handler for operation \"$op\""
    }
    return [[dict get $forms $op] $node $env]
}

# Evaluates EXPRS in order in ENV. The first abrupt completion ends the
# sequence; otherwise the completion of the last expression is returned.
# An empty sequence completes normally with unit.
proc core::evalSequence {exprs env} {
    set completion [core::completion::normal [core::value::unit]]
    foreach expr $exprs {
        set completion [core::evalIn $expr $env]
        if {![core::completion::isNormal $completion]} {
            return $completion
        }
    }
    return $completion
}

# Unwraps a normal completion to its value. For any abrupt completion, makes
# the *calling handler* return that completion immediately, which is exactly
# the propagation rule for sub-expressions. (Implemented with Tcl's
# `return -level 2`; the propagated thing is still an explicit completion.)
proc core::valueOf {completion} {
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
    set value [core::valueOf [core::evalIn [lindex $node 2] $env]]
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
    set callee [core::valueOf [core::evalIn [lindex $node 1] $env]]
    set argValues {}
    foreach argNode [lrange $node 2 end] {
        lappend argValues [core::valueOf [core::evalIn $argNode $env]]
    }
    return [core::callable::invoke $callee $argValues]
}

proc core::forms::op-if {node env} {
    set condition [lindex $node 1]
    set test [core::valueOf [core::evalIn $condition $env]]
    if {[core::value::kind $test] ne "bool"} {
        core::semanticError NOT-BOOLEAN \
            "if condition must be a Boolean, got [core::value::show $test]"
    }
    set outcome [core::value::isTrue $test]
    set branch [lindex $node [expr {$outcome ? 2 : 3}]]

    # The branch body runs inline (no callable boundary) in a fresh child
    # scope that carries the facts proven by the condition.
    set branchEnv [core::env::child $env]
    core::refine::install $branchEnv [core::refine::branchFacts $condition $env $outcome]
    return [core::evalSequence [core::ir::blockBody $branch] $branchEnv]
}

proc core::forms::op-loop {node env} {
    set body [core::ir::blockBody [lindex $node 1]]
    while 1 {
        # Each iteration gets a fresh lexical scope.
        set completion [core::evalSequence $body [core::env::child $env]]
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

proc core::forms::op-return {node env} {
    set value [core::valueOf [core::evalIn [lindex $node 1] $env]]
    return [core::completion::returning $value]
}

proc core::forms::op-break {node env} {
    if {[llength $node] == 1} {
        return [core::completion::breaking [core::value::unit]]
    }
    set value [core::valueOf [core::evalIn [lindex $node 1] $env]]
    return [core::completion::breaking $value]
}

proc core::forms::op-continue {node env} {
    return [core::completion::continuing]
}

proc core::forms::op-ok {node env} {
    set value [core::valueOf [core::evalIn [lindex $node 1] $env]]
    return [core::completion::normal [core::value::ok $value]]
}

proc core::forms::op-error-value {node env} {
    set value [core::valueOf [core::evalIn [lindex $node 1] $env]]
    return [core::completion::normal [core::value::err $value]]
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
    set env [core::env::child [core::rootEnv]]
    return [core::completion::atProgramBoundary [core::evalSequence $exprs $env]]
}

# Evaluates a single top-level expression. Returns its value.
proc core::eval {node} {
    return [core::evalProgram [list $node]]
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
