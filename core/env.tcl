# env.tcl -- lexical environments.
#
# An environment is a frame with identity, held in a frame store:
#
#   frame {
#       parent       parent frame id, or "" for a root
#       bindings     NAME -> {id BINDING-ID value VALUE}
#       refinements  BINDING-ID -> list of facts proven in this scope
#   }
#
# Frames are append-only: a name may be added once and never changed or
# removed. Because frames have identity, a Block that captures a frame sees
# bindings added to that frame later (this is what permits recursion); it can
# never observe a binding change, because bindings do not change.
#
# Refinements are keyed by binding identity, not by name, so a fact about an
# outer `x` never applies to an inner `x` that shadows it.
#
# Environment ids are opaque to the rest of the evaluator.

namespace eval core::env {
    variable frames [dict create]
    # binding id -> {name NAME frame FRAME-ID}; used only for introspection.
    variable bindingIndex [dict create]
    variable nextFrame 0
    variable nextBinding 0
}

proc core::env::new {parent} {
    variable frames
    variable nextFrame
    if {$parent ne ""} {
        Require $parent
    }
    set id env[incr nextFrame]
    dict set frames $id [dict create \
        parent $parent \
        bindings [dict create] \
        refinements [dict create]]
    return $id
}

proc core::env::child {parent} {
    Require $parent
    return [new $parent]
}

proc core::env::Require {env} {
    variable frames
    if {![dict exists $frames $env]} {
        error "core::env: no such environment \"$env\""
    }
}

proc core::env::parent {env} {
    variable frames
    Require $env
    return [dict get $frames $env parent]
}

# Adds an immutable binding to ENV itself. Returns the new binding id.
proc core::env::define {env name value} {
    variable frames
    variable bindingIndex
    variable nextBinding
    Require $env
    core::value::check $value
    if {[dict exists $frames $env bindings $name]} {
        core::semanticError DUPLICATE \
            "duplicate binding \"$name\" in the same lexical scope"
    }
    set id b[incr nextBinding]
    dict set frames $env bindings $name [dict create id $id value $value]
    dict set bindingIndex $id [dict create name $name frame $env]
    return $id
}

# ---------------------------------------------------------------------------
# Lookup
#
# Name resolution walks an ordered list of *scopes*. Today every scope is a
# lexical frame, innermost first:
#
#     local bindings -> captured lexical parent -> ... -> root
#
# The intended future order is
#
#     local bindings -> execution overlay -> captured lexical env -> module/global
#
# Such scopes are added by extending lookupScopes and the scope accessors
# below with new scope kinds; resolve and the evaluator are unaffected.

proc core::env::lookupScopes {env} {
    Require $env
    set scopes {}
    for {set frame $env} {$frame ne ""} {set frame [parent $frame]} {
        lappend scopes [list frame $frame]
    }
    return $scopes
}

# Returns the binding record {id ... value ...} for NAME in SCOPE, or "".
proc core::env::ScopeBinding {scope name} {
    variable frames
    lassign $scope scopeKind frame
    switch -- $scopeKind {
        frame {
            if {[dict exists $frames $frame bindings $name]} {
                return [dict get $frames $frame bindings $name]
            }
            return ""
        }
        default {
            error "core::env: unknown scope kind \"$scopeKind\""
        }
    }
}

proc core::env::ScopeRefinements {scope} {
    variable frames
    lassign $scope scopeKind frame
    switch -- $scopeKind {
        frame   { return [dict get $frames $frame refinements] }
        default { error "core::env: unknown scope kind \"$scopeKind\"" }
    }
}

# Resolves NAME lexically. Returns the binding record {id BINDING-ID value V}.
proc core::env::resolve {env name} {
    foreach scope [lookupScopes $env] {
        set binding [ScopeBinding $scope $name]
        if {$binding ne ""} {
            return $binding
        }
    }
    core::semanticError UNBOUND "unbound name \"$name\""
}

proc core::env::lookup {env name} {
    return [dict get [resolve $env $name] value]
}

# ---------------------------------------------------------------------------
# Refinements

# Records, in ENV itself, that the binding BINDING-ID satisfies FACT.
proc core::env::refine {env bindingId fact} {
    variable frames
    Require $env
    set facts {}
    if {[dict exists $frames $env refinements $bindingId]} {
        set facts [dict get $frames $env refinements $bindingId]
    }
    if {$fact ni $facts} {
        lappend facts $fact
        dict set frames $env refinements $bindingId $facts
    }
}

# All facts about BINDING-ID visible from ENV.
proc core::env::factsFor {env bindingId} {
    set facts {}
    foreach scope [lookupScopes $env] {
        set refinements [ScopeRefinements $scope]
        if {[dict exists $refinements $bindingId]} {
            foreach fact [dict get $refinements $bindingId] {
                if {$fact ni $facts} {
                    lappend facts $fact
                }
            }
        }
    }
    return $facts
}

# Facts about the binding that NAME resolves to from ENV.
proc core::env::refinementsOf {env name} {
    return [factsFor $env [dict get [resolve $env $name] id]]
}

# NAME -> facts for every refined binding that is visible (not shadowed) from ENV.
proc core::env::visibleRefinements {env} {
    variable bindingIndex
    set result [dict create]
    foreach scope [lookupScopes $env] {
        dict for {bindingId -} [ScopeRefinements $scope] {
            set name [dict get $bindingIndex $bindingId name]
            if {[dict exists $result $name]} {
                continue
            }
            if {[dict get [resolve $env $name] id] ne $bindingId} {
                continue
            }
            dict set result $name [factsFor $env $bindingId]
        }
    }
    return $result
}

# NAME -> value for the bindings made directly in ENV.
proc core::env::localBindings {env} {
    variable frames
    Require $env
    set result [dict create]
    dict for {name binding} [dict get $frames $env bindings] {
        dict set result $name [dict get $binding value]
    }
    return $result
}
