# resolve.tcl -- building HIR: scopes, bindings and lexical resolution.
#
# One walk over core IR, in evaluation order, creates an expression node per
# IR node and resolves every name. The rules are those of the interpreter
# (README §2, core/env.tcl), decided statically:
#
# * A scope is the program, a block invocation, an if branch or a loop
#   iteration. On entry it declares every name bound by a `bind` reachable
#   without entering a nested scope (core::ir::scopeBindNames), so a name
#   denotes one binding throughout its scope. Block parameters are bindings
#   of the block's scope.
# * A reference denotes the binding of the innermost enclosing scope that
#   declares its name; failing that, a root binding (program mode) or an
#   ambient binding of the host environment (sequence mode). Otherwise it is
#   unresolved: {UNBOUND "unbound name ..."}.
# * Whether the binding has its value when the reference is evaluated:
#     yes       it is bound earlier in the same invocation, or is a
#               parameter or root binding
#     no        same invocation, not yet bound: evaluating the reference
#               raises {UNBOUND "used before its binding"}
#     deferred  the reference is inside a block created in another
#               invocation (a closure): decided when the block is called
#   Code within one invocation runs in the order of this walk, and each
#   branch or iteration binds only its own scope's names, so "bound earlier
#   in the walk" is exact.
# * A `bind` of a binding that is already bound at that point (a second bind
#   of the name, or a bind of a parameter name) raises {DUPLICATE ...} when
#   evaluated, after its value.
# * A block captures every non-root binding that a reference in its body (at
#   any depth) resolves to outside the block.
# * return targets the innermost enclosing block; break and continue the
#   innermost enclosing loop within that block.
#
# Static errors are recorded as diagnostics; hir::build decides whether to
# raise them. Types are filled in afterwards by types.tcl.

namespace eval hir::resolve {}

proc hir::resolve::program {exprs mode} {
    set hir [hir::Empty $mode]
    dict set hir bound [dict create]
    if {$mode eq "program"} {
        set root [NewScope hir root "" "" "" {builtin root}]
        set top [NewScope hir program $root "" "" {ir {}}]
        Declare hir $top [core::ir::scopeBindNames $exprs]
    } else {
        set top [NewScope hir ambient "" "" "" {host environment}]
    }
    dict set hir top $top
    set ctx [dict create scope $top callable "" loop "" blocks {}]
    set roots {}
    set index 0
    foreach expr $exprs {
        lappend roots [Expr hir $expr [list $index] $ctx]
        incr index
    }
    dict set hir roots $roots
    if {$mode eq "program"} {
        # Root bindings are created on first reference, so ids depend only on
        # the program; the rest exist too, for scope queries.
        foreach name [RootNames] {
            RootBinding hir $root $name
        }
    }
    dict unset hir bound
    return $hir
}

proc hir::resolve::RootNames {} {
    return [concat [core::native::names] {true false unit}]
}

proc hir::resolve::NewScope {hirVar kind parent invocation owner origin} {
    upvar 1 $hirVar hir
    set s [hir::NewId hir scope]
    dict set hir scopes $s [dict create id $s kind $kind parent $parent \
        invocation $invocation owner $owner origin $origin \
        names [dict create] bindings {} closures {} refinements {}]
    return $s
}

proc hir::resolve::NewBinding {hirVar name kind scope origin} {
    upvar 1 $hirVar hir
    set b [hir::NewId hir binding]
    dict set hir bindings $b [dict create id $b name $name kind $kind scope $scope \
        declaredBy "" origin $origin type "" symbol "" value ""]
    dict set hir scopes $scope names $name $b
    dict set hir scopes $scope bindings [concat [dict get $hir scopes $scope bindings] [list $b]]
    return $b
}

# Declares NAMES as local bindings of scope S (names already there are kept).
proc hir::resolve::Declare {hirVar s names} {
    upvar 1 $hirVar hir
    foreach name $names {
        if {![dict exists $hir scopes $s names $name]} {
            NewBinding hir $name local $s [list declared $s]
        }
    }
}

proc hir::resolve::RootBinding {hirVar root name} {
    upvar 1 $hirVar hir
    if {[dict exists $hir scopes $root names $name]} {
        return [dict get $hir scopes $root names $name]
    }
    set b [NewBinding hir $name root $root {builtin root}]
    set y [hir::NewId hir symbol]
    if {$name in {true false unit}} {
        set value [core::value::$name]
        dict set hir symbols $y [dict create id $y kind constant name $name \
            provenance [list core root $name]]
    } else {
        set value [core::value::native $name]
        dict set hir symbols $y [dict create id $y kind native name $name \
            provenance [list core native $name]]
    }
    dict set hir bindings $b symbol $y
    dict set hir bindings $b value $value
    return $b
}

# The SymbolId of native NAME, creating its root binding if needed.
proc hir::resolve::nativeSymbol {hirVar name} {
    upvar 1 $hirVar hir
    dict for {y symbol} [dict get $hir symbols] {
        if {[dict get $symbol kind] eq "native" && [dict get $symbol name] eq $name} {
            return $y
        }
    }
    set y [hir::NewId hir symbol]
    dict set hir symbols $y [dict create id $y kind native name $name \
        provenance [list core native $name]]
    return $y
}

# The binding NAME denotes from scope S, or "".
proc hir::resolve::Lookup {hirVar s name} {
    upvar 1 $hirVar hir
    for {} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        if {[dict exists $hir scopes $s names $name]} {
            return [dict get $hir scopes $s names $name]
        }
        switch -- [dict get $hir scopes $s kind] {
            ambient {
                return [NewBinding hir $name ambient $s {host environment}]
            }
            root {
                if {$name in [RootNames]} {
                    return [RootBinding hir $s $name]
                }
            }
        }
    }
    return ""
}

# Records that block expression E is created in scope S's region.
proc hir::resolve::AddClosure {hirVar s e} {
    upvar 1 $hirVar hir
    while 1 {
        dict set hir scopes $s closures [concat [dict get $hir scopes $s closures] [list $e]]
        if {[dict get $hir scopes $s kind] ni {branch loop}} {
            break
        }
        set s [dict get $hir scopes $s parent]
    }
}

proc hir::resolve::SetField {hirVar e key value} {
    upvar 1 $hirVar hir
    dict set hir exprs $e $key $value
}

# Resolves the IR NODE at PATH in context CTX:
#   scope     ScopeId the node is evaluated in
#   callable  the enclosing block ExprId ("" at unit level)
#   loop      the enclosing loop ExprId within that block ("")
#   blocks    {ExprId BodyScopeId} of every enclosing block, innermost last
# Returns the ExprId.
proc hir::resolve::Expr {hirVar node path ctx} {
    upvar 1 $hirVar hir
    core::ir::checkShape $node
    set op [core::ir::op $node]
    set scope [dict get $ctx scope]
    set e [hir::NewId hir expr]
    set kind [expr {$op eq "error-value" ? "error" : $op}]
    dict set hir exprs $e [dict create id $e kind $kind origin [list ir $path] \
        scope $scope type "" reachable 1]

    switch -- $op {
        const {
            SetField hir $e literal [lrange $node 1 end]
            SetField hir $e value [core::ir::literalValue $node]
        }
        ref {
            ResolveRef hir $e [lindex $node 1] $ctx
        }
        bind {
            set name [lindex $node 1]
            SetField hir $e name $name
            set b [Lookup hir $scope $name]
            SetField hir $e binding $b
            SetField hir $e value [Expr hir [lindex $node 2] [concat $path 2] $ctx]
            set duplicate 0
            switch -- [dict get $hir bindings $b kind] {
                ambient {}
                default {
                    if {[dict exists $hir bound $b]} {
                        set duplicate 1
                        hir::Diagnose hir DUPLICATE \
                            "duplicate binding \"$name\" in the same lexical scope" $e
                    } else {
                        dict set hir bound $b 1
                        dict set hir bindings $b declaredBy $e
                        dict set hir bindings $b origin [list ir $path]
                    }
                }
            }
            SetField hir $e duplicate $duplicate
        }
        block {
            set invocation $e
            set bodyScope [NewScope hir block $scope $e $e [list ir $path]]
            set params {}
            set index 0
            foreach param [core::ir::blockParams $node] {
                set b [NewBinding hir $param param $bodyScope [list ir [concat $path 1 $index]]]
                dict set hir bound $b 1
                lappend params $b
                incr index
            }
            set body [core::ir::blockBody $node]
            Declare hir $bodyScope [core::ir::scopeBindNames $body]
            AddClosure hir $scope $e
            SetField hir $e bodyScope $bodyScope
            SetField hir $e params $params
            SetField hir $e captures {}
            SetField hir $e resultType ""
            set inner [dict create scope $bodyScope callable $e loop "" \
                blocks [concat [dict get $ctx blocks] [list [list $e $bodyScope]]]]
            SetField hir $e body [Sequence hir $body [concat $path] 2 $inner]
        }
        call {
            SetField hir $e callee [Expr hir [lindex $node 1] [concat $path 1] $ctx]
            set args {}
            set index 2
            foreach arg [lrange $node 2 end] {
                lappend args [Expr hir $arg [concat $path $index] $ctx]
                incr index
            }
            SetField hir $e args $args
            SetField hir $e target ""
            SetField hir $e known ""
        }
        if {
            SetField hir $e condition [Expr hir [lindex $node 1] [concat $path 1] $ctx]
            foreach {role index outcome} {then 2 1 else 3 0} {
                set body [core::ir::blockBody [lindex $node $index]]
                set branch [NewScope hir branch $scope \
                    [dict get $hir scopes $scope invocation] $e [list ir [concat $path $index]]]
                dict set hir scopes $branch outcome $outcome
                Declare hir $branch [core::ir::scopeBindNames $body]
                SetField hir $e ${role}Scope $branch
                SetField hir $e ${role}Body \
                    [Sequence hir $body [concat $path $index] 2 [dict replace $ctx scope $branch]]
            }
            SetField hir $e refinements [dict create 1 {} 0 {}]
        }
        loop {
            set body [core::ir::blockBody [lindex $node 1]]
            set iteration [NewScope hir loop $scope \
                [dict get $hir scopes $scope invocation] $e [list ir [concat $path 1]]]
            Declare hir $iteration [core::ir::scopeBindNames $body]
            SetField hir $e bodyScope $iteration
            SetField hir $e body \
                [Sequence hir $body [concat $path 1] 2 [dict replace $ctx scope $iteration loop $e]]
        }
        return {
            SetField hir $e value [Expr hir [lindex $node 1] [concat $path 1] $ctx]
            SetField hir $e target [dict get $ctx callable]
            if {[dict get $ctx callable] eq ""} {
                hir::Diagnose hir RETURN-OUTSIDE-CALLABLE "return outside callable invocation" $e
            }
        }
        break {
            set value ""
            if {[llength $node] == 2} {
                set value [Expr hir [lindex $node 1] [concat $path 1] $ctx]
            }
            SetField hir $e value $value
            SetField hir $e target [dict get $ctx loop]
            if {[dict get $ctx loop] eq ""} {
                hir::Diagnose hir BREAK-OUTSIDE-LOOP "break outside lexical loop" $e
            }
        }
        continue {
            SetField hir $e target [dict get $ctx loop]
            if {[dict get $ctx loop] eq ""} {
                hir::Diagnose hir CONTINUE-OUTSIDE-LOOP "continue outside lexical loop" $e
            }
        }
        ok - error-value {
            SetField hir $e value [Expr hir [lindex $node 1] [concat $path 1] $ctx]
        }
    }
    return $e
}

# Resolves the expressions EXPRS, found at PATH from index FIRST on.
proc hir::resolve::Sequence {hirVar exprs path first ctx} {
    upvar 1 $hirVar hir
    set ids {}
    set index $first
    foreach expr $exprs {
        lappend ids [Expr hir $expr [concat $path $index] $ctx]
        incr index
    }
    return $ids
}

proc hir::resolve::ResolveRef {hirVar e name ctx} {
    upvar 1 $hirVar hir
    set scope [dict get $ctx scope]
    SetField hir $e name $name
    set b [Lookup hir $scope $name]
    SetField hir $e binding $b
    if {$b eq ""} {
        SetField hir $e init no
        hir::Diagnose hir UNBOUND "unbound name \"$name\"" $e
        return
    }
    set binding [dict get $hir bindings $b]
    set bindingScope [dict get $binding scope]
    switch -- [dict get $binding kind] {
        root {
            set init yes
        }
        ambient {
            set init deferred
        }
        default {
            if {[dict get $hir scopes $bindingScope invocation]
                    ne [dict get $hir scopes $scope invocation]} {
                set init deferred
            } elseif {[dict exists $hir bound $b]} {
                set init yes
            } else {
                set init no
                hir::Diagnose hir UNBOUND "name \"$name\" used before its binding" $e
            }
        }
    }
    SetField hir $e init $init

    # Every enclosing block that does not contain the binding captures it.
    if {[dict get $binding kind] ne "root"} {
        foreach entry [lreverse [dict get $ctx blocks]] {
            lassign $entry block bodyScope
            if {[hir::scopeWithin $hir $bindingScope $bodyScope]} {
                break
            }
            set captures [dict get $hir exprs $block captures]
            if {$b ni $captures} {
                SetField hir $block captures [concat $captures [list $b]]
            }
        }
    }
}
