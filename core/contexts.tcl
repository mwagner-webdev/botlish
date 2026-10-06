# contexts.tcl -- the Tcl backends' execution-environment contexts
# (CONTEXTS.md).
#
# A context is an ordinary Botlish value of a `context struct` type. Two
# operations reach the execution environment, and nothing else does:
#
#   context#install(VALUE)   `with context EXPR` (entry program, top level):
#                            VALUE becomes the installed context of its own
#                            exact nominal type, for the rest of the run
#   context#load("ID")       a function's context parameter `context io: T`:
#                            the installed context of the context-struct
#                            declaration ID (T's canonical identity), bound
#                            to the local `io` at function entry
#
# Both are internal root natives: `#` cannot be spelled by source, so no
# program can name, alias, pass or call them -- the only producers are the
# source frontend's `with context` lowering and the resolver's context
# parameter bindings (hir/resolve.tcl). They are what the HIR records
# explicitly (hir/contexts.tcl reads every one of them by native identity), and
# they never reach native code as calls: native/lower.tcl compiles an install
# into stores to the type's fixed context slot and a load into loads from it.
#
# HERE, in the interpreter and the Tcl compiler, the environment is one dict
# keyed by canonical context-struct identity (core::value::structId of the
# installed value, which static typing proved is exactly the requested type).
# That map is this backend's implementation detail of the semantics, not a
# language facility: there is no lookup by any other key, no enumeration, no
# replacement, no user-visible API. Static verification (hir/contexts.tcl)
# proves that every load is preceded by the installation of its type and that
# no type is installed twice; a program that runs anyway (-strict 0) gets the
# same semantic failure at run time (MISSING-CONTEXT, DUPLICATE-CONTEXT)
# rather than an arbitrary value.
#
# The environment is per program run: core::evalProgram runs every program
# inside core::contexts::fresh, which starts it empty and restores the
# previous one afterwards, however the run ends.

namespace eval core::contexts {
    # Canonical context-struct identity -> installed value, for the run in
    # progress.
    variable installed [dict create]
}

# The native names of the two operations (hir/contexts.tcl, native/lower.tcl).
proc core::contexts::installNative {} { return context#install }
proc core::contexts::loadNative {} { return context#load }

proc core::contexts::installImpl {value} {
    variable installed
    set id [core::value::structId $value]
    if {$id eq ""} {
        core::semanticError NOT-A-CONTEXT \
            "with context: an anonymous struct value is not a context (a context is a value of a \"context struct\" type)"
    }
    if {[dict exists $installed $id]} {
        core::semanticError DUPLICATE-CONTEXT "$id is already installed in this scope"
    }
    dict set installed $id $value
    return [core::value::unit]
}

proc core::contexts::loadImpl {key} {
    variable installed
    set id [core::value::strOf $key]
    if {![dict exists $installed $id]} {
        core::semanticError MISSING-CONTEXT \
            "$id: no context of this type is installed (install one with \"with context EXPR\" before the call that needs it)"
    }
    return [dict get $installed $id]
}

# Runs SCRIPT (in the caller's scope) with an empty context environment,
# restoring the previous one afterwards however SCRIPT ends.
proc core::contexts::fresh {script} {
    variable installed
    set saved $installed
    set installed [dict create]
    try {
        return [uplevel 1 $script]
    } finally {
        set installed $saved
    }
}

core::native::register context#install -arity 1 -impl core::contexts::installImpl \
    -param-types {struct} -result-type unit
core::native::register context#load -arity 1 -impl core::contexts::loadImpl \
    -param-types {str} -result-type struct -result-shape {context-struct 0}
