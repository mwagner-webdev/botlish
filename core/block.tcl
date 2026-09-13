# block.tcl -- Block creation and invocation.
#
# A Block value is {params, body, captured environment, code}. Creating a
# Block never runs its body. Invoking it:
#
#   1. checks that the argument count equals the parameter count
#   2. creates a fresh child environment of the *captured* environment
#   3. binds each parameter immutably and declares the body's bindings
#   4. evaluates the body as a sequence
#   5. applies the callable boundary (return consumed, break/continue rejected)
#
# A Block produced by the compiler carries CODE, a generated Tcl command that
# performs steps 2-4 itself. Its abrupt completions arrive as Tcl return codes
# and are mapped back to completions here, so both kinds of Block share one
# boundary and may call each other freely.

namespace eval core::block {}

proc core::block::make {params body env} {
    return [core::value::block $params $body $env]
}

proc core::block::invoke {blockValue argValues} {
    set params [core::value::blockParams $blockValue]
    if {[llength $params] != [llength $argValues]} {
        core::semanticError ARITY \
            "block ([join $params { }]) expects [llength $params] argument(s), got [llength $argValues]"
    }
    set code [core::value::blockCode $blockValue]
    if {$code ne ""} {
        set completion [RunCompiled $code [core::value::blockEnv $blockValue] $argValues]
    } else {
        set body [core::value::blockBody $blockValue]
        set frame [core::env::child [core::value::blockEnv $blockValue]]
        foreach param $params arg $argValues {
            core::env::define $frame $param $arg
        }
        core::env::declare $frame [core::ir::scopeBindNames $body]
        set completion [core::interp::evalSequence $body $frame]
    }
    return [core::completion::atCallBoundary $completion]
}

# Runs compiled code and translates its Tcl completion code:
#   ok -> value, return -> return, break -> break, continue -> continue.
proc core::block::RunCompiled {code env argValues} {
    set status [catch {{*}$code $env $argValues} result options]
    return [core::completion::fromTclCode $status $result $options]
}
