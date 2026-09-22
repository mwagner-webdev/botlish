# resolve.tcl -- building HIR: scopes, bindings and lexical resolution.
#
# One walk over syntax nodes (syntax.tcl: core IR converted by
# hir::syntax::fromIR, or built by a frontend), in evaluation order, creates
# an expression node per syntax node and resolves every name. The rules are
# those of the interpreter (README §2, core/env.tcl), decided statically:
#
# * A scope is the program, a block invocation, an if branch or a loop
#   iteration. On entry it declares every name bound by a `bind` reachable
#   without entering a nested scope (hir::syntax::scopeBindNames), so a name
#   denotes one binding throughout its scope. Block parameters are bindings
#   of the block's scope.
# * A reference denotes the binding of the innermost enclosing scope that
#   declares its name; failing that, a root binding (program mode) or an
#   ambient binding of the host environment (sequence mode). Otherwise it is
#   unresolved: {UNBOUND "unbound name ..."}. A root reference (a syntax ref
#   with root 1) denotes the root binding of its name regardless.
# * A module-qualified reference (surface/modules.tcl's "NAMESPACE::NAME", a
#   syntax ref node carrying a `qualified {NAMESPACE NAME}` field) is not an
#   ordinary name: it is resolved directly against NAMESPACE's own module
#   section scope (ResolveQualifiedRef), always "yes" (a module's
#   definitions are all bound, unconditionally, before any code that can
#   reference them runs -- surface/modules.tcl), and captured by nothing
#   (like a root reference).
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

# The HIR of the syntax nodes NODES (syntax.tcl) in MODE; ORIGIN is the
# origin of the program scope. MODULES (program mode only): a list of
# {namespace NS nodes SECTION-NODES origin SECTION-ORIGIN} dicts --
# surface/modules.tcl's own sections, one per namespace NODES needs,
# dependencies first -- each resolved into its OWN "program"-kind scope
# (ProgramSection), a sibling of NODES' own top scope, before NODES itself
# is resolved. A "program"-kind scope, unlike a block's, has invocation ""
# (the same tag as every other top-level scope: see ResolveRef's "same
# invocation" test), so hir::lower's core IR keeps every module's own
# bindings as ordinary flat top-level statements, in the SAME interpreter
# frame as everything else -- necessary because a block/call boundary
# would make its bindings unreachable from any sibling top-level code once
# the call returns (blocks only ever expose values through capture or
# their own return value, never bindings by name). Each such scope is
# still a genuinely separate ScopeId, so two different namespaces can
# freely declare the very same plain name (e.g. both a "parse") with no
# collision: hir::hygiene::qualifyModules (hir/hygiene.tcl) renames every
# binding a namespace's own section scope declares to its qualified
# spelling afterward, so no two modules' definitions ever share a lowered
# core IR name either.
proc hir::resolve::program {nodes mode origin {modules {}}} {
    set hir [hir::Empty $mode]
    dict set hir bound [dict create]
    set roots {}
    if {$mode eq "program"} {
        set root [NewScope hir root "" "" "" {builtin root}]
        set top [NewScope hir program $root "" "" $origin]
        # Set before resolving any module section: a root reference
        # (hir::resolve::ResolveRef) checks hir::top's own scope KIND, not
        # its identity, to confirm program mode -- true of every section's
        # own "program"-kind scope too, so this only needs to exist, not
        # to be the scope currently being walked.
        dict set hir top $top
        foreach section $modules {
            lappend roots {*}[ProgramSection hir $root [dict get $section namespace] \
                [dict get $section nodes] [dict get $section origin]]
        }
        Declare hir $top [hir::syntax::scopeBindNames $nodes]
    } else {
        set top [NewScope hir ambient "" "" "" {host environment}]
        dict set hir top $top
    }
    set ctx [dict create scope $top callable "" loop "" blocks {}]
    lappend roots {*}[Sequence hir $nodes $ctx]
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

# Resolves one module section (see hir::resolve::program's MODULES): a
# "program"-kind scope of its own, a sibling of the referencing code's own
# top scope, both children of the same ROOT. Records its scope as
# namespace NAMESPACE's own in HIR's `modules` table (consulted by
# ResolveQualifiedRef and by hir::hygiene::qualifyModules). Returns the
# section's own resolved ExprIds, in order (to append to `roots`).
proc hir::resolve::ProgramSection {hirVar root namespaceName nodes origin} {
    upvar 1 $hirVar hir
    set scope [NewScope hir program $root "" "" $origin]
    Declare hir $scope [hir::syntax::scopeBindNames $nodes]
    dict set hir modules $namespaceName $scope
    set ctx [dict create scope $scope callable "" loop "" blocks {}]
    return [Sequence hir $nodes $ctx]
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

# Resolves the syntax NODE in context CTX:
#   scope     ScopeId the node is evaluated in
#   callable  the enclosing block ExprId ("" at unit level)
#   loop      the enclosing loop ExprId within that block ("")
#   blocks    {ExprId BodyScopeId} of every enclosing block, innermost last
# Returns the ExprId.
proc hir::resolve::Expr {hirVar node ctx} {
    upvar 1 $hirVar hir
    set kind [dict get $node kind]
    set origin [dict get $node origin]
    set scope [dict get $ctx scope]
    set e [hir::NewId hir expr]
    dict set hir exprs $e [dict create id $e kind $kind origin $origin \
        scope $scope type "" reachable 1]

    switch -- $kind {
        const {
            set literal [dict get $node literal]
            SetField hir $e literal $literal
            SetField hir $e value [core::ir::literalValue [list const {*}$literal]]
        }
        ref {
            if {[dict exists $node qualified]} {
                ResolveQualifiedRef hir $e [dict get $node qualified]
            } else {
                ResolveRef hir $e [dict get $node name] [dict get $node root] $ctx
            }
        }
        bind {
            set name [dict get $node name]
            SetField hir $e name $name
            set b [Lookup hir $scope $name]
            SetField hir $e binding $b
            SetField hir $e value [Expr hir [dict get $node value] $ctx]
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
                        dict set hir bindings $b origin $origin
                    }
                }
            }
            SetField hir $e duplicate $duplicate
        }
        block {
            set bodyScope [NewScope hir block $scope $e $e $origin]
            set params {}
            foreach param [dict get $node params] {
                lassign $param name paramOrigin
                set first [expr {[dict exists $hir scopes $bodyScope names $name]
                    ? [dict get $hir scopes $bodyScope names $name] : ""}]
                set b [NewBinding hir $name param $bodyScope $paramOrigin]
                if {$first ne ""} {
                    # Only reachable from syntax built without core IR's shape
                    # check; the name keeps denoting the first parameter.
                    dict set hir scopes $bodyScope names $name $first
                    hir::Diagnose hir DUPLICATE \
                        "duplicate binding \"$name\" in the same lexical scope (block parameters)" $e
                }
                dict set hir bound $b 1
                lappend params $b
            }
            set body [dict get $node body]
            Declare hir $bodyScope [hir::syntax::scopeBindNames $body]
            AddClosure hir $scope $e
            SetField hir $e bodyScope $bodyScope
            SetField hir $e params $params
            SetField hir $e captures {}
            set declared [expr {[dict exists $node declaredResult] ? [dict get $node declaredResult] : {}}]
            if {$declared ne {}} {
                if {[catch {core::type::normalize $declared} normalized]} {
                    hir::Diagnose hir TYPE [format {unknown or invalid result type %s} $declared] $e
                    set declared {}
                } else {
                    set declared $normalized
                }
            }
            SetField hir $e declaredResult $declared
            SetField hir $e resultType ""
            set inner [dict create scope $bodyScope callable $e loop "" \
                blocks [concat [dict get $ctx blocks] [list [list $e $bodyScope]]]]
            SetField hir $e body [Sequence hir $body $inner]
        }
        call {
            SetField hir $e callee [Expr hir [dict get $node callee] $ctx]
            SetField hir $e args [Sequence hir [dict get $node args] $ctx]
            SetField hir $e target ""
            SetField hir $e known ""
        }
        if {
            SetField hir $e condition [Expr hir [dict get $node condition] $ctx]
            foreach {role outcome} {then 1 else 0} {
                set body [dict get $node ${role}Body]
                set branch [NewScope hir branch $scope \
                    [dict get $hir scopes $scope invocation] $e [dict get $node ${role}Origin]]
                dict set hir scopes $branch outcome $outcome
                Declare hir $branch [hir::syntax::scopeBindNames $body]
                SetField hir $e ${role}Scope $branch
                SetField hir $e ${role}Body [Sequence hir $body [dict replace $ctx scope $branch]]
            }
            SetField hir $e refinements [dict create 1 {} 0 {}]
        }
        loop {
            set body [dict get $node body]
            set iteration [NewScope hir loop $scope \
                [dict get $hir scopes $scope invocation] $e [dict get $node bodyOrigin]]
            Declare hir $iteration [hir::syntax::scopeBindNames $body]
            SetField hir $e bodyScope $iteration
            SetField hir $e body [Sequence hir $body [dict replace $ctx scope $iteration loop $e]]
        }
        return {
            SetField hir $e value [Expr hir [dict get $node value] $ctx]
            SetField hir $e target [dict get $ctx callable]
            if {[dict get $ctx callable] eq ""} {
                hir::Diagnose hir RETURN-OUTSIDE-CALLABLE "return outside callable invocation" $e
            }
        }
        break {
            set value ""
            if {[dict get $node value] ne ""} {
                set value [Expr hir [dict get $node value] $ctx]
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
        ok - error {
            SetField hir $e value [Expr hir [dict get $node value] $ctx]
        }
        default {
            core::malformed "unknown syntax node kind \"$kind\"" $node
        }
    }
    return $e
}

# Resolves the syntax nodes NODES in order.
proc hir::resolve::Sequence {hirVar nodes ctx} {
    upvar 1 $hirVar hir
    set ids {}
    foreach node $nodes {
        lappend ids [Expr hir $node $ctx]
    }
    return $ids
}

# Resolves module-qualified reference E (a {NAMESPACE NAME} pair) directly
# against NAMESPACE's own module section scope (hir::resolve::program's
# MODULES parameter records it in hir's `modules` table as each section is
# resolved, before the referencing code; surface/modules.tcl always orders
# a namespace's own section ahead of any code that references it, so the
# table already has NAMESPACE's entry by the time this runs). Deliberately
# not hir::resolve::Lookup's ordinary lexical
# walk: a qualified reference denotes exactly the one binding NAMESPACE's
# own module file declares NAME to be, immune to any local binding named
# NAMESPACE or NAME (no local scope is ever consulted at all) -- and,
# unlike native/native.tcl's superseded -native-body/ExpandNativeBodies
# (NATIVE-URI-ESCAPE.md), this runs as part of hir::resolve's own ordinary
# walk, after full lexical resolution of everything reachable so far, never
# as raw pre-resolution text substitution.
#
# Every reference reaching here was already validated, by
# surface::modules::CollectAndLoad, to name a namespace that was loaded and
# a definition it actually has, before this HIR was ever built -- so
# failure here is an internal invariant violation (a caller that built
# syntax nodes without going through surface/modules.tcl), not a
# user-facing diagnostic.
proc hir::resolve::ResolveQualifiedRef {hirVar e pair} {
    upvar 1 $hirVar hir
    lassign $pair ns name
    SetField hir $e name "${ns}::${name}"
    if {![dict exists $hir modules $ns]} {
        core::malformed "unresolved module reference ${ns}::${name}: module \"$ns\" was not loaded into this program" [list ref "${ns}::${name}"]
    }
    set bodyScope [dict get $hir modules $ns]
    if {![dict exists $hir scopes $bodyScope names $name]} {
        core::malformed "unresolved module reference ${ns}::${name}: namespace \"$ns\" has no definition \"$name\"" [list ref "${ns}::${name}"]
    }
    SetField hir $e binding [dict get $hir scopes $bodyScope names $name]
    SetField hir $e init yes
}

# Resolves reference E to NAME; ROOT 1: to the root binding NAME, whatever
# local bindings are called (hygiene.tcl keeps lowering faithful).
proc hir::resolve::ResolveRef {hirVar e name root ctx} {
    upvar 1 $hirVar hir
    set scope [dict get $ctx scope]
    SetField hir $e name $name
    if {$root} {
        set s [dict get $hir top]
        if {[dict get $hir scopes $s kind] ne "program"} {
            core::malformed "a root reference needs program mode" [list ref $name]
        }
        set b [RootBinding hir [dict get $hir scopes $s parent] $name]
        dict lappend hir rootRefs $e
    } else {
        set b [Lookup hir $scope $name]
    }
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
