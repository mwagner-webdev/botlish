# callable.tcl -- the single call dispatch point.
#
# There is exactly one semantic call operation. Internally it dispatches on
# the callable's representation.

namespace eval core::callable {}

# Invokes CALLEE with already-evaluated ARG-VALUES. Returns a completion.
proc core::callable::invoke {callee argValues} {
    switch -- [core::value::kind $callee] {
        block {
            return [core::block::invoke $callee $argValues]
        }
        native {
            return [core::native::invoke $callee $argValues]
        }
        default {
            core::semanticError NOT-CALLABLE \
                "cannot call non-callable value [core::value::show $callee]"
        }
    }
}

# Refinement rules (ARG-INDEX FACT pairs) that hold when CALLEE returned
# the Boolean OUTCOME (host 1/0). Blocks carry no refinement metadata yet.
proc core::callable::refinementRules {callee outcome} {
    switch -- [core::value::kind $callee] {
        native {
            return [core::native::refinementRules [core::value::nativeName $callee] $outcome]
        }
        default {
            return {}
        }
    }
}
