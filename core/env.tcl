# env.tcl -- lexical environments.
#
# An environment is a frame with identity, held in a frame store:
#
#   frame {
#       parent       parent frame id, or "" for a root
#       bindings     NAME -> {id BINDING-ID ?value VALUE?}
#       refinements  BINDING-ID -> list of facts proven in this scope
#   }
#
# A binding without a value is *declared*: its scope has been entered but its
# bind has not completed. Frames are append-only: a binding receives its value
# once and never changes. Because frames have identity, a Block that captures
# a frame sees bindings made in that frame later (this is what permits
# recursion); it can never observe a binding change.
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
        refinements [dict create] \
        pinned 0]
    return $id
}

# ---------------------------------------------------------------------------
# Lifetime
#
# Frames are reclaimed explicitly, which is enough because the only runtime
# values that refer to a frame are Blocks (their captured environment).
#
#   pin      a Block captures ENV: ENV and every ancestor stay alive (the
#            Block can reach them through the parent chain)
#   release  the scope ENV was created for has ended: the frame is dropped
#            unless it is pinned. Nested scopes end before their parents,
#            and a pinned frame's ancestors are pinned, so a released frame
#            is unreachable.
#   mark / releaseSince
#            every frame created after a mark, dropped at once, pinned or
#            not; for a program whose result holds no Block, since then
#            nothing can refer to its frames any more
#
# Environments an embedder creates (core::rootEnv, core::childEnv) are only
# released by an embedder.

proc core::env::pin {env} {
    variable frames
    while {$env ne "" && [dict exists $frames $env] && ![dict get $frames $env pinned]} {
        dict set frames $env pinned 1
        set env [dict get $frames $env parent]
    }
}

proc core::env::release {env} {
    variable frames
    if {[dict exists $frames $env] && ![dict get $frames $env pinned]} {
        Drop $env
    }
}

proc core::env::mark {} {
    variable nextFrame
    return $nextFrame
}

proc core::env::releaseSince {mark} {
    variable frames
    foreach env [dict keys $frames] {
        if {[string range $env 3 end] > $mark} {
            Drop $env
        }
    }
}

proc core::env::Drop {env} {
    variable frames
    variable bindingIndex
    dict for {name binding} [dict get $frames $env bindings] {
        dict unset bindingIndex [dict get $binding id]
    }
    dict unset frames $env
}

# The number of live frames (for tests).
proc core::env::liveCount {} {
    variable frames
    return [dict size $frames]
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

# Declares NAMES in ENV without values. A scope declares every name it binds
# when it is entered, so that each name denotes one binding throughout the
# scope: using it before its bind completes is an error, rather than silently
# reaching an outer binding of the same name. Already-present names are
# skipped (a later bind of them will report the duplicate).
proc core::env::declare {env names} {
    variable frames
    Require $env
    foreach name $names {
        if {![dict exists $frames $env bindings $name]} {
            dict set frames $env bindings $name [dict create id [NewBindingId $env $name]]
        }
    }
}

proc core::env::NewBindingId {env name} {
    variable bindingIndex
    variable nextBinding
    set id b[incr nextBinding]
    dict set bindingIndex $id [dict create name $name frame $env]
    return $id
}

# Gives NAME its immutable value in ENV itself. Returns the binding id.
proc core::env::define {env name value} {
    variable frames
    Require $env
    core::value::check $value
    if {[dict exists $frames $env bindings $name]} {
        set binding [dict get $frames $env bindings $name]
        if {[dict exists $binding value]} {
            duplicateBinding $name
        }
        set id [dict get $binding id]
    } else {
        set id [NewBindingId $env $name]
    }
    dict set frames $env bindings $name [dict create id $id value $value]
    return $id
}

proc core::env::duplicateBinding {name} {
    core::semanticError DUPLICATE "duplicate binding \"$name\" in the same lexical scope"
}

proc core::env::usedBeforeBinding {name} {
    core::semanticError UNBOUND "name \"$name\" used before its binding"
}

# Returns the value of NAME bound directly in ENV. The name must have been
# declared or defined there (compiled code only asks for such names).
proc core::env::lookupLocal {env name} {
    variable frames
    if {![dict exists $frames $env bindings $name]} {
        error "core::env: \"$name\" is not declared in $env"
    }
    set binding [dict get $frames $env bindings $name]
    if {![dict exists $binding value]} {
        usedBeforeBinding $name
    }
    return [dict get $binding value]
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

# Resolves NAME lexically. Returns the binding record {id BINDING-ID ?value V?};
# the value is absent while the binding is declared but not yet made.
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
    set binding [resolve $env $name]
    if {![dict exists $binding value]} {
        usedBeforeBinding $name
    }
    return [dict get $binding value]
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
        if {[dict exists $binding value]} {
            dict set result $name [dict get $binding value]
        }
    }
    return $result
}
