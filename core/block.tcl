# block.tcl -- Block creation and invocation.
#
# A Block value is {params, body, captured environment}. Creating a Block
# never runs its body. Invoking it:
#
#   1. checks that the argument count equals the parameter count
#   2. creates a fresh child environment of the *captured* environment
#   3. binds each parameter immutably in that environment
#   4. evaluates the body as a sequence
#   5. applies the callable boundary (return consumed, break/continue rejected)

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
    set frame [core::env::child [core::value::blockEnv $blockValue]]
    foreach param $params arg $argValues {
        core::env::define $frame $param $arg
    }
    set completion [core::evalSequence [core::value::blockBody $blockValue] $frame]
    return [core::completion::atCallBoundary $completion]
}
