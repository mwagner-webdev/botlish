# resolve.tcl -- building HIR: scopes, bindings and lexical resolution.
#
# One walk over syntax nodes (syntax.tcl: core IR converted by
# hir::syntax::fromIR, or built by a frontend), in evaluation order, creates
# an expression node per syntax node and resolves every name. The walk is
# STRICTLY SEQUENTIAL (STRICT-REFERENCE-DETERMINISM.md):
#
#     a lexical binding becomes visible when it is established
#
# * A scope is the program, a module section, a block invocation, an if
#   branch, a handler branch or a loop iteration. It starts EMPTY: only
#   parameters (and a loop's element/induction binding) exist on entry. A
#   `bind` adds its binding to the scope's `names` at the point the walk
#   reaches it, after its value has been resolved (so `x = x` reads an outer
#   x, or nothing), and nothing before that point can see it. A later
#   declaration is semantically indistinguishable from one absent from the
#   file: there is no whole-scope symbol table, no predeclaration, no hoisting.
# * The one exception is a named function: a `bind` whose value is a `block`
#   (surface `fn f(...):`) establishes its binding BEFORE its block is
#   resolved, so the body reaches the function through its own binding
#   (direct self-recursion). It never makes a *sibling* visible: mutual
#   recursion needs one edge to point forward, so it is rejected.
# * A reference denotes the binding of the innermost enclosing scope whose
#   `names` (as established so far) has its name; failing that, a root
#   binding (program mode) or an ambient binding of the host environment
#   (sequence mode). Otherwise it is unresolved: {UNBOUND "unbound name ..."},
#   and the reference gets no binding at all -- an illegal forward reference
#   never becomes a reference with a placeholder identity or type. A root
#   reference (a syntax ref with root 1) denotes the root binding of its name
#   regardless.
# * Later shadowing cannot reach back: a nested scope that establishes `x`
#   after an earlier reference to an outer `x` leaves that reference on the
#   outer binding. (Lowered core IR is name-based; hir/hygiene.tcl renames a
#   later binding that a name-based lookup would otherwise let capture an
#   earlier closure's reference.)
# * A module-qualified reference (surface/modules.tcl's "NAMESPACE::NAME", a
#   syntax ref node carrying a `qualified {NAMESPACE NAME}` field) is not an
#   ordinary name: it is resolved directly against NAMESPACE's own module
#   section scope (ResolveQualifiedRef). That scope is complete: a module's
#   section is resolved, in full and in its own source order, before any
#   section or code that depends on it (surface/modules.tcl), so a qualified
#   reference names a binding some *other* unit has already established --
#   the external module boundary, not a forward reference. Its binding is
#   never itself *within* any enclosing block's body scope (a module section
#   scope is always a sibling of the program's own top scope), so it captures
#   exactly like a distant lexical reference (Capture, shared with
#   ResolveRef) -- module-static, see MODULE-STATIC-RETAINED-VALUES.md.
# * Every reference is therefore to a binding established before it: `init`
#   is `yes`, except for an ambient binding (`deferred`: whatever the host
#   environment holds when a closure runs). A block never reads a binding
#   that does not have its value yet, so there is no use-before-binding state
#   to check or repair later. The dependency graph among bindings of a scope
#   is a DAG whose edges point backward in source order, plus explicit
#   self-edges of named functions.
# * A `bind` of a name that is already bound in the SAME scope (a second bind
#   of the name, or a bind of a parameter name) is a {DUPLICATE ...} error,
#   diagnosed after its value.
# * A block captures every non-root binding that a reference in its body (at
#   any depth) resolves to outside the block.
# * return targets the innermost enclosing block; break and continue the
#   innermost enclosing loop within that block.
#
# Diagnostic index. When a name is unbound, the error may add that the same
# spelling is bound LATER in an enclosing scope's own body ("declared
# later; forward references are not allowed"). That answer comes from
# LaterNames, a per-scope index of the syntax nodes' bind names, computed
# lazily and only for the error message: it is never consulted to resolve a
# name, cannot supply a binding identity and is dropped before resolution
# returns.
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
proc hir::resolve::program {nodes mode origin {modules {}} {choices {}} {externs 0}} {
    set hir [hir::Empty $mode]
    dict set hir laterIndex [dict create]
    dict set hir methodChoices $choices
    dict set hir methodCalls [dict create]
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
                [dict get $section nodes] [dict get $section origin] $externs]
        }
        NoteBody hir $top $nodes
        if {$externs} {
            # The entry program's extern c fn names (hir/foreign.tcl).
            hir::foreign::DeclareBindings hir $top ""
        }
    } else {
        set top [NewScope hir ambient "" "" "" {host environment}]
        dict set hir top $top
    }
    set ctx [dict create scope $top callable "" loop "" blocks {} errors {}]
    lappend roots {*}[Sequence hir $nodes $ctx]
    dict set hir roots $roots
    if {$mode eq "program"} {
        # Root bindings are created on first reference, so ids depend only on
        # the program; the rest exist too, for scope queries.
        foreach name [RootNames] {
            RootBinding hir $root $name
        }
    }
    hir::flags::CheckValues hir
    dict unset hir laterIndex
    return $hir
}

# Resolves one module section (see hir::resolve::program's MODULES): a
# "program"-kind scope of its own, a sibling of the referencing code's own
# top scope, both children of the same ROOT. Records its scope as
# namespace NAMESPACE's own in HIR's `modules` table (consulted by
# ResolveQualifiedRef and by hir::hygiene::qualifyModules). Returns the
# section's own resolved ExprIds, in order (to append to `roots`).
proc hir::resolve::ProgramSection {hirVar root namespaceName nodes origin {externs 0}} {
    upvar 1 $hirVar hir
    set scope [NewScope hir program $root "" "" $origin]
    NoteBody hir $scope $nodes
    if {$externs} {
        # The module's extern c fn names (hir/foreign.tcl): declarations,
        # visible from the section's start like its types.
        hir::foreign::DeclareBindings hir $scope $namespaceName
    }
    dict set hir modules $namespaceName $scope
    # Reverse index of `modules`, checked by IsModuleScope/hir::isModuleScope:
    # every binding this scope declares has module/program lifetime and
    # stable storage identity (MODULE-STATIC-RETAINED-VALUES.md), never a
    # lexical activation of its own -- unlike hir::top's own identically-
    # "program"-kind scope, which is the entry program's ordinary top level,
    # out of this milestone's scope (see that file's eligibility discussion).
    dict set hir moduleScopeIds $scope 1
    set ctx [dict create scope $scope callable "" loop "" blocks {} errors {} namespace $namespaceName]
    return [Sequence hir $nodes $ctx]
}

# 1 if SCOPE is a module section's own scope (hir::resolve::ProgramSection):
# every binding it declares has module/program lifetime, one initialized
# value and no lexical-activation identity of its own -- see
# MODULE-STATIC-RETAINED-VALUES.md. Never hir::top's own scope, even though
# both share scope kind "program": that is the entry program's ordinary top
# level, not a namespace's module section, and is out of this milestone's
# scope (MODULE-BINDINGS.md's existing eligibility contract governs only
# namespace module sections, hir/modulebinding.tcl's own moduleScopes).
proc hir::resolve::IsModuleScope {hirVar s} {
    upvar 1 $hirVar hir
    return [dict exists $hir moduleScopeIds $s]
}

proc hir::resolve::RootNames {} {
    # An extern c fn's native (extern#KEY, hir/foreign.tcl) is no root name:
    # its one name is a binding of the unit that declares it.
    return [concat [lsearch -all -inline -not -glob [core::native::names] extern#*] {true false unit}]
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

# Records, for the diagnostic index only (LaterNames), the syntax NODES that
# make up the body of scope S. Resolution never reads it.
proc hir::resolve::NoteBody {hirVar s nodes} {
    upvar 1 $hirVar hir
    dict set hir laterIndex $s [dict create nodes $nodes]
}

# The names scope S's own body binds anywhere (not descending into nested
# scopes), computed on first use: the answer to "is this spelling bound
# later in that scope?", asked only to word an UNBOUND diagnostic. It is
# not a symbol table for resolution and holds no binding identity.
proc hir::resolve::LaterNames {hirVar s} {
    upvar 1 $hirVar hir
    if {![dict exists $hir laterIndex $s]} {
        return {}
    }
    if {![dict exists $hir laterIndex $s names]} {
        dict set hir laterIndex $s names \
            [hir::syntax::scopeBindNames [dict get $hir laterIndex $s nodes]]
    }
    return [dict get $hir laterIndex $s names]
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

# The native (or root constant) name root binding BINDING denotes: its
# symbol's, which is its own name for a root-scope binding and, for an
# extern c fn's binding, its internal native name even before hygiene
# renames the binding to it (hir/foreign.tcl).
proc hir::resolve::RootNative {hir binding} {
    set y [dict get $binding symbol]
    if {$y ne "" && [dict exists $hir symbols $y]} {
        return [dict get $hir symbols $y name]
    }
    return [dict get $binding name]
}

# The binding identity binding B denotes for the purpose of telling method
# candidates apart: an alias (`at = std::list::at`) is the function it aliases, a
# root native is the native, anything else is itself. Two candidates with one
# identity are one function, however many names reach it.
proc hir::resolve::CandidateIdentity {hirVar b} {
    upvar 1 $hirVar hir
    for {set depth 0} {$depth < 32} {incr depth} {
        set binding [dict get $hir bindings $b]
        if {[dict get $binding kind] eq "root"} {
            return native:[RootNative $hir $binding]
        }
        set d [dict get $binding declaredBy]
        if {$d eq "" || ![dict exists $hir exprs $d] || [dict get $hir exprs $d kind] ne "bind"
                || ![dict exists $hir exprs $d value]} {
            break
        }
        set value [dict get $hir exprs $d value]
        if {$value eq "" || ![dict exists $hir exprs $value]
                || [dict get $hir exprs $value kind] ne "ref"
                || ![dict exists $hir exprs $value binding] || [dict get $hir exprs $value binding] eq ""} {
            break
        }
        set b [dict get $hir exprs $value binding]
    }
    return binding:$b
}

# The accepted count of arguments of the function candidate identity IDENTITY
# stands for, `*` for any, `>=N` for a variadic function of N fixed
# parameters (VARIADICS-VERTICAL-SLICE-1.md), or "" if it is not statically
# a function of known arity (a parameter, a value).
proc hir::resolve::CandidateArity {hirVar b} {
    upvar 1 $hirVar hir
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "root"} {
        if {[dict get $binding symbol] ne "" && [dict get $hir symbols [dict get $binding symbol] kind] eq "native"} {
            return [dict get [core::native::metadata [RootNative $hir $binding]] arity]
        }
        return ""
    }
    if {[dict exists $binding flagIface]} {
        if {[dict getdef $binding flagIface variadic 0]} {
            return ">=[expr {[dict get $binding flagIface ordinary] - 1}]"
        }
        return [dict get $binding flagIface ordinary]
    }
    return ""
}

# The binding the unqualified NAME denotes from scope S under ordinary
# lexical resolution (what a reference would see), or "" -- the walk Lookup
# makes, without creating anything (a root binding that does not exist yet is
# reported as the pair {root NAME}).
proc hir::resolve::LexicalTarget {hirVar s name} {
    upvar 1 $hirVar hir
    for {} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        if {[dict exists $hir scopes $s names $name]} {
            return [dict get $hir scopes $s names $name]
        }
        switch -- [dict get $hir scopes $s kind] {
            ambient {
                return ambient
            }
            root {
                if {$name in [RootNames]} {
                    return [list root $name]
                }
                return ""
            }
        }
    }
    return ""
}

# 1 if the function candidate identity IDENTITY (CandidateIdentity's spelling)
# stands for is declared `nomethod`: a native registered with -nomethod 1, or
# a function binding whose declaration carries the modifier. Aliases are
# already followed by the identity, so a name bound to a nomethod function is
# that function.
proc hir::resolve::NoMethodIdentity {hirVar identity} {
    upvar 1 $hirVar hir
    switch -glob -- $identity {
        native:* {
            set native [string range $identity 7 end]
            return [expr {[core::native::exists $native] && [dict get [core::native::metadata $native] nomethod]}]
        }
        binding:* {
            return [dict exists $hir bindings [string range $identity 8 end] nomethod]
        }
    }
    return 0
}

# The functions the method-style call `receiver.NAME(args)` (ARGCOUNT: the
# receiver plus the written arguments) may denote from scope S of CTX: the
# distinct functions among
#
#   * the function ordinary lexical resolution finds for NAME (a function or
#     binding of the file, a parameter, a root native), and
#   * for every namespace the file directly imports (hir/imports.tcl), the
#     member NAME of that exact namespace: a module function or an
#     intrinsic (`std::list::at`). Imports are not transitive and not
#     hierarchical: only the namespaces the file itself names.
#
# A list of {display D kind lexical|module|native ns NS identity I} dicts
# sorted by display (the unqualified name for the lexical one, `NS::NAME`
# otherwise): there is no order of precedence, ever. Candidates with one
# identity are one (an alias of an imported function adds nothing). A
# candidate that is statically a function of a different arity is dropped,
# unless that would leave none (the ordinary call then keeps its arity
# error). Empty: no function of that name is visible.
#
# A function declared `nomethod` (WARNINGS-METHOD-ELIGIBLE.md: its author
# declares that it is never the callee of method syntax) is not a candidate at
# all, before the arity rule: sugar neither resolves to it nor competes with
# it. HIDDENVAR, if given, names a caller variable that receives the displays
# of the nomethod functions that were left out, so the caller can tell "no
# function of that name is visible" from "only nomethod functions are".
proc hir::resolve::MethodCandidates {hirVar s name ctx argCount {hiddenVar ""}} {
    upvar 1 $hirVar hir
    if {$hiddenVar ne ""} {
        upvar 1 $hiddenVar hidden
    }
    set hidden {}
    set found [dict create]
    set arities [dict create]
    foreach ns [hir::imports::namespaces [CtxNamespace $ctx]] {
        set qualified "${ns}::$name"
        if {[core::native::isQualifiedNative $qualified]} {
            set identity native:$qualified
            if {![dict exists $found $identity]} {
                dict set found $identity [dict create display $qualified kind native ns $ns identity $identity]
                dict set arities $identity [dict get [core::native::metadata $qualified] arity]
            }
        } elseif {[dict exists $hir modules $ns]} {
            set scope [dict get $hir modules $ns]
            if {[dict exists $hir scopes $scope names $name]} {
                set b [dict get $hir scopes $scope names $name]
                set identity [CandidateIdentity hir $b]
                if {![dict exists $found $identity]} {
                    dict set found $identity [dict create display $qualified kind module ns $ns identity $identity]
                    dict set arities $identity [CandidateArity hir $b]
                }
            }
        }
    }
    set target [LexicalTarget hir $s $name]
    if {$target ne ""} {
        if {$target eq "ambient"} {
            set identity ambient:$name
            set arity ""
        } elseif {[llength $target] == 2} {
            set identity native:$name
            if {[core::native::exists $name]} {
                set arity [dict get [core::native::metadata $name] arity]
            } else {
                set arity ""
            }
        } else {
            set identity [CandidateIdentity hir $target]
            set arity [CandidateArity hir [if {[string match binding:* $identity]} {string range $identity 8 end} else {set target}]]
        }
        if {![dict exists $found $identity]} {
            dict set found $identity [dict create display $name kind lexical ns "" identity $identity]
            dict set arities $identity $arity
        }
    }
    set all {}
    foreach c [lsort -command {apply {{a b} {string compare [dict get $a display] [dict get $b display]}}} [dict values $found]] {
        if {[NoMethodIdentity hir [dict get $c identity]]} {
            lappend hidden [dict get $c display]
        } else {
            lappend all $c
        }
    }
    set fitting [lmap c $all {
        set arity [dict get $arities [dict get $c identity]]
        if {[string match >=* $arity]} {
            if {$argCount < [string range $arity 2 end]} continue
        } elseif {$arity ne "" && $arity ne "*" && $arity != $argCount} continue
        set c
    }]
    if {$fitting ne ""} {
        return $fitting
    }
    return $all
}

# The key naming the method-style call NODE (a call syntax node) across
# rebuilds of the same program: its source file and its structural node id.
# "" for a node with no source identity (one that did not come from source).
proc hir::resolve::MethodKey {node} {
    set origin [dict get $node origin]
    if {![dict exists $origin node] || ![dict exists $origin file]} {
        return ""
    }
    return "[dict get $origin file]:[dict get $origin node]"
}

# The candidate (one of CANDIDATES, at least one) method-style call E
# resolves to. With one candidate it is that one. With several the build was
# told which is valid (HIR's `methodChoices`, key -> candidate display; set
# by hir::buildSyntax's disambiguation), else the first by display name
# stands in provisionally. Every call with several candidates is recorded in
# `methodCalls` (key -> {expr E name NAME candidates DISPLAYS chosen D}) for
# that disambiguation, whatever the build chose.
proc hir::resolve::MethodChoice {hirVar e node candidates} {
    upvar 1 $hirVar hir
    if {[llength $candidates] == 1} {
        return [lindex $candidates 0]
    }
    set key [MethodKey $node]
    set chosen [lindex $candidates 0]
    if {$key ne "" && [dict exists $hir methodChoices $key]} {
        foreach candidate $candidates {
            if {[dict get $candidate display] eq [dict get $hir methodChoices $key]} {
                set chosen $candidate
            }
        }
    }
    dict set hir methodCalls [if {$key ne ""} {set key} else {set e}] [dict create expr $e \
        name [dict get [dict get $node callee] name] \
        candidates [lmap c $candidates {dict get $c display}] chosen [dict get $chosen display]]
    return $chosen
}

# The syntax node of the callee CHOSEN (a MethodCandidates dict) denotes.
proc hir::resolve::MethodCalleeSyntax {chosen name nameOrigin} {
    switch -- [dict get $chosen kind] {
        native {
            return [hir::syntax::rootRef $nameOrigin [dict get $chosen display]]
        }
        module {
            set ref [hir::syntax::refNode $nameOrigin [dict get $chosen display]]
            dict set ref qualified [list [dict get $chosen ns] $name]
            return $ref
        }
        default {
            return [hir::syntax::refNode $nameOrigin $name]
        }
    }
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

# The canonical resolved type named by TYPEEXPR (a surface::parser::
# TypeExpr: a bare name string, or a {NAME ARG} pair for one applied type
# argument -- e.g. "List[Small]"), or a Tcl error (unknown name, an
# ordinary type used as a constructor, an unregistered constructor, or the
# wrong arity), caught by both callers below exactly as a plain
# core::type::normalize failure always was (MINIMAL-APPLIED-LIST-TYPES.md).
# A bare name is resolved by hir::types::resolveNamed, an applied one by
# hir::types::resolveApplication -- the one place that knows which names
# are registered type constructors, so this proc stays fully generic over
# constructor identity.
#
# IMPRINTS 1 resolves a function's declared signature (hir/imprint.tcl): a
# name that is an imprint variable's (hir::imprint::IsVariableName) and
# names no visible type is the variable {imprint NAME}. IMPRINTS a list of
# names resolves a type inside the body of functions whose signatures have
# those variables (a call's explicit imprint forwarding one: `null[T]()`):
# only those are variables. Everywhere else such a name is the unknown type
# it always was.
proc hir::resolve::ResolveTypeExpr {typeExpr {ns ""} {imprints 0}} {
    if {[llength $typeExpr] == 1} {
        if {($imprints eq "1" || ($imprints ni {0 ""} && $typeExpr in $imprints))
                && [hir::imprint::IsVariableName $typeExpr]
                && [catch {hir::types::resolveNamed $typeExpr $ns} type]} {
            return [list imprint $typeExpr]
        }
        return [hir::types::resolveNamed $typeExpr $ns]
    }
    if {[hir::layouts::IsArrayTypeExpr $typeExpr]} {
        # `array N of T` (FIXED-LAYOUT-ARRAYS.md) describes bytes, like a
        # layout: a layout field's type or NativeView/NativeEdit's argument
        # (both resolved by hir/layouts.tcl), never a type of values.
        return -code error -errorcode {BOTLISH LAYOUT-NOT-A-TYPE} [hir::layouts::ArrayNotATypeMessage $typeExpr]
    }
    if {[hir::refinements::IsRefinementExpr $typeExpr]} {
        # NAME{param: N ...} (surface::parser::ScalarRefinement): a scalar
        # refinement, validated against its family's schema
        # (hir/refinements.tcl, DECIMAL-ROUNDED-MILESTONE-1.md). Of an
        # applied type, NAME[ARG]{...} (LIST-CARDINALITY-REFINEMENTS.md):
        # the base resolves like any type, and the facts refine it.
        if {[llength $typeExpr] == 4} {
            set family [lindex $typeExpr 1]
            set facts [hir::refinements::ResolveFacts $family [lindex $typeExpr 2] 1]
            set base [ResolveTypeExpr [lindex $typeExpr 3] $ns $imprints]
            set type [hir::types::Refine $base $family $facts]
            if {$type eq "never"} {
                return -code error -errorcode {BOTLISH REFINEMENT-PARAMETER} \
                    "[ShowTypeExpr $typeExpr] describes no value: [hir::types::show $base] has no element, so its only length is 0"
            }
            return $type
        }
        return [hir::refinements::Resolve [lindex $typeExpr 1] [lindex $typeExpr 2]]
    }
    if {[IsApplyTypeExpr $typeExpr]} {
        # NAME[A, B, ...] (surface::parser::TypeExpr): an application of
        # several arguments, a parameterized struct's.
        return [ResolveApplied [lindex $typeExpr 1] [lindex $typeExpr 2] $ns $imprints]
    }
    lassign $typeExpr name arg
    if {$name ne "fn" && ![dict exists $::hir::types::constructors $name] && [hir::structs::lookup $name $ns] ne ""} {
        # NAME[A]: a one-slot parameterized struct's application (a struct
        # with no slot is resolveApplication's "not a type constructor").
        return [ResolveApplied $name [list $arg] $ns $imprints]
    }
    if {$name eq "fn"} {
        # A structural function type (surface::parser::FnType's
        # {fn FIELDS}; "fn" is a keyword, so never a constructor name):
        # every argument and the return type resolve like any other type
        # annotation, and every error name must be a declared error
        # identity, exactly as in a function's own "errors" clause.
        set argTypes [lmap t [dict get $arg args] {ResolveTypeExpr $t $ns $imprints}]
        set result [ResolveTypeExpr [dict get $arg return] $ns $imprints]
        foreach t [concat $argTypes [list $result]] {
            set contextTrait [hir::types::MentionedContextTrait $t]
            if {$contextTrait ne ""} {
                return -code error -errorcode {BOTLISH CONTEXT-TRAIT-POSITION} \
                    [hir::types::ContextTraitPositionMessage $contextTrait "part of a function type"]
            }
            if {[hir::types::MentionsTrait $t]} {
                # A function (or coroutine) type over a trait would be a callable value whose
                # calls need a witness only the caller knows: there is no
                # runtime trait dispatch to give it one (TRAITS.md,
                # "Function values").
                return -code error -errorcode {BOTLISH TRAIT-POLYMORPHIC-FUNCTION-VALUE} \
                    "a function type cannot mention a trait ([hir::types::show $t]): a trait-polymorphic function is not a general callable value (there is no runtime trait dispatch)"
            }
        }
        set coroutine [expr {[dict exists $arg kind] && [dict get $arg kind] eq "coroutine"}]
        set what [expr {$coroutine ? "coroutine type" : "function type"}]
        # Each error spelling is the canonical identity it denotes here
        # (hir::errordecls::resolve: ns's own errors bare, other modules'
        # qualified); the contract holds identities only.
        set errorIds {}
        foreach errName [dict get $arg errors] {
            set id [hir::errordecls::resolve $errName $ns]
            if {$id eq ""} {
                error "unknown error \"$errName\" in the $what's \"errors\" list: [hir::errordecls::unknownReason $errName $ns]"
            }
            if {$id in $errorIds} {
                error "duplicate error \"$id\" in the $what's \"errors\" list"
            }
            lappend errorIds $id
        }
        dict set arg errors $errorIds
        if {$coroutine} {
            # A coroutine handle type (AFFINE-VALUES.md): the resume
            # protocol is its args -- no message, or exactly one of a named
            # struct type (COROUTINES.md's structured-message restriction).
            # Construction arguments are never part of it.
            if {[llength $argTypes] > 1} {
                return -code error -errorcode {BOTLISH COROUTINE-CONTRACT} \
                    "a coroutine is resumed with at most one message, but this coroutine type's \"args\" lists [llength $argTypes] types (put several values in the fields of one struct)"
            }
            foreach t $argTypes {
                if {![hir::coroutines::IsStructProtocol $t]} {
                    return -code error -errorcode {BOTLISH COROUTINE-CONTRACT} \
                        "the message type in a coroutine type's \"args\" must be a declared struct type, not [hir::types::show $t] (a coroutine is resumed with one structured message)"
                }
            }
            # (A coroutine's results are cached and its messages may go
            # unreceived: neither may be affine, hir::coroutines::
            # AffineProtocol. Checked where a construction has a type, as
            # struct field types may not be complete while this resolves.)
            return [hir::types::MakeCoroutineType $argTypes $result [dict get $arg errors]]
        }
        return [hir::types::MakeFn $argTypes $result [dict get $arg errors]]
    }
    if {$name eq "LayoutStruct"} {
        # LayoutStruct[L] (BINARY-LAYOUT.md): L names a layout, never a type.
        return [hir::layouts::ResolveLayoutStruct $arg $ns]
    }
    if {$name eq "NativeView"} {
        # NativeView[L] (NATIVE-LAYOUT-VIEWS.md): likewise.
        return [hir::layouts::ResolveNativeView $arg $ns]
    }
    if {$name eq "NativeEdit"} {
        # NativeEdit[L] (NATIVE-LAYOUT-WRITES.md): likewise.
        return [hir::layouts::ResolveNativeEdit $arg $ns]
    }
    if {$name eq [hir::cabi::PtrName]} {
        # std::ffi::c::Ptr[T] (C-ABI-TYPES.md): T is a pointee identity
        # (std::ffi::c::Void among them), never a value type.
        return [hir::cabi::ResolvePtr $arg $ns $imprints]
    }
    if {$name eq [hir::cabi::FnPtrName]} {
        return [hir::cabi::ResolveFnPtr $arg $ns $imprints]
    }
    return [hir::types::resolveApplication $name [list [ResolveTypeExpr $arg $ns $imprints]]]
}

# The application of the parameterized struct spelled NAME (in the code of
# namespace NS) to the type expressions ARGS (TRAIT-CONSTRAINED-IMPRINTED-
# TYPES.md): one per slot, each resolved as ResolveTypeExpr resolves any
# type (IMPRINTS likewise), each a type a struct field may hold -- never a
# trait, a context trait or an affine type. Its slots' trait constraints are
# not checked here: a concrete argument's satisfaction is decided once the
# program's declarations and implementations are all known
# (hir::structs::verifyApplications), a symbolic one (an imprint variable)
# gives its function the obligation (hir::imprint::Constrain).
proc hir::resolve::ResolveApplied {name args ns imprints} {
    set id [hir::structs::lookup $name $ns]
    if {$id eq ""} {
        if {[dict exists $::hir::types::constructors $name]} {
            return -code error -errorcode {BOTLISH TYPE} \
                "\"$name\" takes [dict get $::hir::types::constructors $name] type argument(s), got [llength $args]"
        }
        if {[core::type::valid [hir::types::CanonicalTypeName $name $ns]] || [hir::enums::lookup $name $ns] ne ""} {
            error "\"$name\" is not a type constructor"
        }
        error "unknown type constructor \"$name\""
    }
    set slots [hir::structs::slots $id]
    if {$slots eq {}} {
        error "\"$name\" is not a type constructor: struct $name declares no type slots, so it takes no type arguments (write $name)"
    }
    if {[llength $args] != [llength $slots]} {
        error "struct \"$name\" takes [llength $slots] type argument(s), [join $slots {, }], but $name\[[join [lmap t $args {ShowTypeExpr $t}] {, }]\] gives [llength $args]"
    }
    set types {}
    foreach slot $slots t $args {
        set type [ResolveTypeExpr $t $ns $imprints]
        set what "the argument for slot $slot of $name"
        set contextTrait [hir::types::MentionedContextTrait $type]
        if {$contextTrait ne ""} {
            return -code error -errorcode {BOTLISH CONTEXT-TRAIT-POSITION} \
                [hir::types::ContextTraitPositionMessage $contextTrait $what]
        }
        if {[hir::types::MentionsTrait $type]} {
            # A struct stores one concrete representation per field (TRAITS.md,
            # "Storage"): a slot is a field's type.
            return -code error -errorcode {BOTLISH TRAIT-STORAGE-UNSUPPORTED} \
                "$what cannot be the trait [hir::types::show $type]: a slot is the type of the values its fields hold, and there is no erased or heterogeneous trait representation (a constrained slot, $slot satisfies TRAIT, takes a concrete type that satisfies the trait)"
        }
        if {[hir::types::IsAffine $type]} {
            return -code error -errorcode {BOTLISH TYPE} \
                "$what is the affine type [hir::types::show $type]: a type slot takes an unrestricted type (its values may be copied wherever the slot's type is used)"
        }
        lappend types $type
    }
    return [hir::types::MakeApplied $id $types]
}

# The diagnostic kind of a failed ResolveTypeExpr whose catch OPTIONS are
# given: the code the type function raised it with ({BOTLISH KIND}), else
# DEFAULT.
proc hir::resolve::TypeErrorKind {options default} {
    set code [dict get $options -errorcode]
    if {[lindex $code 0] eq "BOTLISH" && [llength $code] == 2} {
        return [lindex $code 1]
    }
    return $default
}

# The resolved proof contract of block E (REFINEMENT-VALUES.md): its syntax
# NODE's proof clauses (hir::syntax::withProofs), each validated and turned
# into the generic rule {outcome OUTCOME param INDEX binding B fact TYPE}.
# The declared result decides the outcome that carries the proof:
#
#   -> bool   OUTCOME 1       a predicate: "when a call of E returns true,
#                             its argument INDEX satisfies the refinement
#                             TYPE"
#   -> unit   OUTCOME normal  a validator: "when a call of E completes
#                             normally (returns rather than failing), its
#                             argument INDEX satisfies TYPE"
#
# PARAMS are E's parameter bindings (ordinary ones first, then flags),
# DECLAREDTYPES their resolved declared types, DECLARED the resolved
# declared result. A clause that fails validation is diagnosed at its own
# origin and contributes no rule:
#
#   PROOF-CLAUSE               the clause names no ordinary parameter, its
#                              type is not a refinement type, the parameter's
#                              declared type does not forget to the
#                              refinement's carrier, or the function declares
#                              neither `-> bool` nor `-> unit`
#   REFINEMENT-MINT-AUTHORITY  the function is not in the refinement's
#                              owning module (its exact declaring namespace;
#                              no import, parent or child grants it)
#
# The parameter must be *declared* of the carrier (or of a type that forgets
# to it): the clause adds a fact to a value its callers have already proven
# to be a carrier value, so a refinement of a refinement can only be minted
# from an already-proven carrier refinement, never from the bare base kind.
proc hir::resolve::ResolveProofs {hirVar e node params declaredTypes declared ctx} {
    upvar 1 $hirVar hir
    if {![dict exists $node proofs]} {
        return {}
    }
    set ns [CtxNamespace $ctx]
    set ordinary [lmap param [dict get $node params] {lindex $param 0}]
    set rules {}
    foreach clause [dict get $node proofs] {
        set name [dict get $clause param]
        set paramOrigin [dict get $clause paramOrigin]
        set typeOrigin [dict get $clause typeOrigin]
        set typeText [ShowTypeExpr [dict get $clause type]]
        set index [lsearch -exact $ordinary $name]
        if {$index < 0} {
            if {[dict exists $node flags]} {
                set flags [lmap f [dict get $node flags] {lindex $f 0}]
            } else {
                set flags {}
            }
            if {[dict exists $node contextParams]} {
                set contexts [lmap c [dict get $node contextParams] {lindex $c 0}]
            } else {
                set contexts {}
            }
            if {$name in $flags} {
                set why "\"$name\" is a flag, not an ordinary parameter"
            } elseif {$name in $contexts} {
                set why "\"$name\" is a context parameter, not an ordinary parameter"
            } else {
                set why "the function has no parameter \"$name\" (its parameters: [if {$ordinary eq {}} {string cat "none"} else {join $ordinary {, }}])"
            }
            hir::DiagnoseAt hir PROOF-CLAUSE "proof clause \"proves $name: $typeText\" must name one of the function's ordinary parameters: $why" $e $paramOrigin
            continue
        }
        if {[catch {ResolveTypeExpr [dict get $clause type] $ns} fact]} {
            hir::DiagnoseAt hir PROOF-CLAUSE "unknown proven type $typeText in \"proves $name: $typeText\": $fact" $e $typeOrigin
            continue
        }
        set refinement [core::type::refinementName $fact]
        if {$refinement eq ""} {
            hir::DiagnoseAt hir PROOF-CLAUSE [format {the proven type of "proves %s: %s" is %s, which is not a refinement type: a proof clause establishes a refinement declared with "refined type NAME = CARRIER"} \
                $name $typeText [hir::types::show $fact]] $e $typeOrigin
            continue
        }
        set meta [core::type::refinementOf $refinement]
        set owner [dict get $meta owner]
        if {$owner ne $ns} {
            hir::DiagnoseAt hir REFINEMENT-MINT-AUTHORITY [format {%s cannot declare a proof of refinement %s: only its owning %s may mint it (no import, parent or child namespace grants that authority)} \
                [expr {$ns eq "" ? "the entry program" : "module \"$ns\""}] $refinement \
                [expr {$owner eq "" ? "entry program" : "module \"$owner\""}]] $e $typeOrigin
            continue
        }
        set carrier [dict get $meta carrier]
        set paramType [lindex $declaredTypes $index]
        if {$paramType eq {}} {
            hir::DiagnoseAt hir PROOF-CLAUSE [format {the proven parameter "%s" must declare its type: "proves %s: %s" refines a %s value, so write "%s: %s" (or a refinement that forgets to it)} \
                $name $name $typeText [hir::types::show $carrier] $name [hir::types::show $carrier]] $e $paramOrigin
            continue
        }
        if {![hir::types::subtype $paramType $carrier]} {
            hir::DiagnoseAt hir PROOF-CLAUSE [format {proof carrier mismatch: parameter "%s" is declared %s, but %s refines %s, and a %s value does not forget to a %s (a proof can only strengthen what the parameter already is)} \
                $name [hir::types::show $paramType] $refinement [hir::types::show $carrier] \
                [hir::types::show $paramType] [hir::types::show $carrier]] $e $paramOrigin
            continue
        }
        switch -- $declared {
            bool { set outcome 1 }
            unit { set outcome normal }
            default {
                hir::DiagnoseAt hir PROOF-CLAUSE [format {a proof-producing function must declare "-> bool" (a predicate: its true result is the proof) or "-> unit" (a validator: its normal completion is the proof), but "proves %s: %s" is on a function %s} \
                    $name $typeText [expr {$declared eq {} ? "with no declared result type" : "declared -> [hir::types::show $declared]"}]] $e $typeOrigin
                continue
            }
        }
        lappend rules [dict create outcome $outcome param $index binding [lindex $params $index] fact $fact]
    }
    return $rules
}

# TYPEEXPR as canonical source text ("List[Small]"), for a diagnostic about
# a type expression that failed to resolve (so there is no resolved type
# to format with hir::types::show yet). Mirrors surface::ast::showType's
# identical notation over the identical data shape; kept as its own tiny
# proc rather than a cross-layer call, since hir/*.tcl has no dependency on
# surface/*.tcl anywhere else.
# 1 if TYPEEXPR (a surface::parser::TypeExpr result) is an application of
# several type arguments, {apply NAME {ARG ...}} (TRAIT-CONSTRAINED-
# IMPRINTED-TYPES.md).
proc hir::resolve::IsApplyTypeExpr {typeExpr} {
    return [expr {[llength $typeExpr] == 3 && [lindex $typeExpr 0] eq "apply"}]
}

proc hir::resolve::ShowTypeExpr {typeExpr} {
    if {[llength $typeExpr] == 1} {
        return $typeExpr
    }
    if {[hir::layouts::IsArrayTypeExpr $typeExpr]} {
        return "array [lindex $typeExpr 1] of [ShowTypeExpr [lindex $typeExpr 2]]"
    }
    if {[hir::refinements::IsRefinementExpr $typeExpr]} {
        set head [lindex $typeExpr 1]
        if {[llength $typeExpr] == 4} {
            set head [ShowTypeExpr [lindex $typeExpr 3]]
        }
        return "$head{[join [lmap field [lindex $typeExpr 2] {join $field {: }}] {, }]}"
    }
    if {[hir::resolve::IsApplyTypeExpr $typeExpr]} {
        return "[lindex $typeExpr 1]\[[join [lmap t [lindex $typeExpr 2] {ShowTypeExpr $t}] {, }]\]"
    }
    lassign $typeExpr name arg
    if {$name eq "fn"} {
        return [format {%s{args: [%s], return: %s, errors: [%s]}} \
            [expr {[dict exists $arg kind] ? "Coroutine" : "Fn"}] \
            [join [lmap t [dict get $arg args] {ShowTypeExpr $t}] {, }] \
            [ShowTypeExpr [dict get $arg return]] [join [dict get $arg errors] {, }]]
    }
    return "$name\[[ShowTypeExpr $arg]\]"
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
    if {[dict exists $node sid]} {
        # The syntax node's identity (hir::traits::Stamp): what a trait
        # program's monomorphization plan names expressions by across builds.
        SetField hir $e sid [dict get $node sid]
    }

    switch -- $kind {
        const {
            set literal [dict get $node literal]
            SetField hir $e literal $literal
            SetField hir $e value [core::ir::literalValue [list const {*}$literal]]
            if {[dict exists $node decimal]} {
                # A decimal literal's exact decimal (hir/decimal.tcl).
                SetField hir $e decimal [dict get $node decimal]
            }
        }
        ref {
            set ident [hir::traits::ExternalIdent $ctx $node]
            if {$ident ne ""} {
                # A reference of a trait clone's body to a binding outside
                # its function, resolved to the binding the source function's
                # own resolution found (TRAITS.md, "Monomorphization").
                ResolveIdent hir $e $ident $ctx
            } elseif {[dict exists $node qualified]
                    && [set enumId [hir::enums::lookup [lindex [dict get $node qualified] 0] [CtxNamespace $ctx]]] ne ""} {
                # `Enum::Case` (ENUMS.md): the qualifier names an enum type,
                # so this is a case of it, never a namespace member.
                ResolveEnumCase hir $e $enumId [lindex [dict get $node qualified] 1] $ctx
            } elseif {[dict exists $node qualified] && [LayoutAsValue hir $e $node $ctx]} {
                # A layout written where a value is (BINARY-LAYOUT.md):
                # diagnosed by LayoutAsValue.
            } elseif {[dict exists $node qualified]} {
                ResolveQualifiedRef hir $e [dict get $node qualified] $ctx
            } else {
                ResolveRef hir $e [dict get $node name] [dict get $node root] $ctx
            }
        }
        bind {
            set name [dict get $node name]
            SetField hir $e name $name
            # An initializer sees the scope as it is BEFORE this bind, so an
            # ordinary `x = e` establishes x after resolving e. A named
            # function (the value is a block literal: `fn f(...):`) is
            # established first, so its own body can call it.
            if {[dict get [dict get $node value] kind] eq "block"} {
                Establish hir $e $scope $name $origin
                if {![dict get $hir exprs $e duplicate]} {
                    # The function's flag interface (FLAGS.md) is known
                    # before its body is resolved, so the body can call it.
                    hir::flags::DeclareFunction hir [dict get $hir exprs $e binding] [dict get $node value]
                    if {[dict exists $node value nomethod]} {
                        # The declaration's modifier, known before its body
                        # (which may call itself) is resolved.
                        dict set hir bindings [dict get $hir exprs $e binding] nomethod 1
                    }
                }
                SetField hir $e value [Expr hir [dict get $node value] $ctx]
            } else {
                SetField hir $e value [Expr hir [dict get $node value] $ctx]
                Establish hir $e $scope $name $origin
                if {![dict get $hir exprs $e duplicate] && [dict get $hir exprs [dict get $hir exprs $e value] kind] eq "ref"} {
                    hir::flags::DeclareAlias hir [dict get $hir exprs $e binding] [dict get $hir exprs $e value]
                }
            }
        }
        block {
            set bodyScope [NewScope hir block $scope $e $e $origin]
            if {[dict exists $node nomethod]} {
                SetField hir $e nomethod 1
            }
            set params {}
            set paramTypes [if {[dict exists $node paramTypes]} {dict get $node paramTypes} else {lrepeat [llength [dict get $node params]] {}}]
            set declaredParamTypes {}
            # The variadic parameter (VARIADICS-VERTICAL-SLICE-1.md, hir/
            # variadic.tcl): the last ordinary one, a List.
            set variadic [expr {[dict exists $node variadic] ? [llength [dict get $node params]] - 1 : -1}]
            set index -1
            foreach param [dict get $node params] paramType $paramTypes {
                incr index
                lassign $param name paramOrigin
                set first [dict getdef $hir scopes $bodyScope names $name ""]
                set b [NewBinding hir $name param $bodyScope $paramOrigin]
                if {$first ne ""} {
                    # Only reachable from syntax built without core IR's shape
                    # check; the name keeps denoting the first parameter.
                    dict set hir scopes $bodyScope names $name $first
                    hir::Diagnose hir DUPLICATE \
                        "duplicate binding \"$name\" in the same lexical scope (block parameters)" $e
                }
                lappend params $b
                # A parameter annotation is a compile-time proof obligation
                # (STRICT-TYPED-PARAMETERS.md), resolved with the same
                # visibility rules as a declared result type: forward
                # references to a same-batch source-defined type already
                # work because hir::sourcetypes::apply registers every type
                # declaration before this pass runs at all.
                if {$paramType eq {}} {
                    lappend declaredParamTypes {}
                    continue
                }
                if {$index == $variadic && $paramType eq "List"} {
                    # A bare List in the variadic section: List[T] of a fresh
                    # imprint variable, the element type each call imprints.
                    lappend declaredParamTypes [hir::types::MakeList [list imprint \
                        [hir::variadic::ElementVariable $node [CtxNamespace $ctx] \
                            [hir::imprint::EnclosingVariables $hir $ctx]]] {} 0 0]
                    continue
                }
                # (With imprint variables: hir/imprint.tcl.)
                if {[catch {ResolveTypeExpr $paramType [CtxNamespace $ctx] 1} normalized options]} {
                    hir::Diagnose hir [TypeErrorKind $options TYPE] \
                        [format {unknown or invalid type %s for parameter "%s": %s} [ShowTypeExpr $paramType] $name $normalized] $e
                    lappend declaredParamTypes {}
                } elseif {[hir::types::MentionedContextTrait $normalized] ne ""} {
                    # A context trait (CONTEXT-TRAITS.md) is not a value type:
                    # only a context parameter may have one.
                    hir::DiagnoseAt hir CONTEXT-TRAIT-POSITION \
                        [hir::types::ContextTraitPositionMessage [hir::types::MentionedContextTrait $normalized] \
                            "the type of the ordinary parameter \"$name\" (write \"context $name: [ShowTypeExpr $paramType]\" in the function's context section)"] \
                        $e $paramOrigin
                    lappend declaredParamTypes {}
                } elseif {$index == $variadic} {
                    lappend declaredParamTypes [hir::variadic::CheckDeclared hir $e $name $paramType $normalized]
                } else {
                    lappend declaredParamTypes $normalized
                }
            }
            if {$variadic >= 0} {
                SetField hir $e variadic $variadic
            }
            if {[dict exists $node places]} {
                # Place parameters (PLACE-PARAMETERS.md): the indices of the
                # parameters a call passes the caller's place itself for
                # (hir/mutvec.tcl checks and elaborates them).
                SetField hir $e places [lsort -integer [dict keys [dict get $node places]]]
            }
            # Imprint variables (hir/imprint.tcl): each one a parameter uses
            # must be established by an earlier one.
            set declaredParamTypes [hir::imprint::CheckSignature hir $e $declaredParamTypes \
                [lmap param [dict get $node params] {lindex $param 0}]]
            set head [hir::traits::CloneHead $ctx $node]
            if {$head ne ""} {
                # The block of a trait clone (TRAITS.md, "Monomorphization"):
                # each trait parameter takes its witness type -- the
                # representation it has -- and records the view it is.
                dict for {i witness} [dict get $head params] {
                    if {[lindex $declaredParamTypes $i] eq {}} {
                        # An untyped parameter given an affine argument
                        # (AFFINE-VALUES.md, "Generic callables"): the clone
                        # declares it with the argument's type.
                        lset declaredParamTypes $i $witness
                        continue
                    }
                    set view [hir::types::MakeView [lindex [lindex $declaredParamTypes $i] 1] $witness]
                    dict set hir bindings [lindex $params $i] view $view
                    lset declaredParamTypes $i $witness
                }
                SetField hir $e traitClone [dict get $head key]
                if {[dict get $head imprints] ne {}} {
                    # A specialization for one binding of the function's
                    # constrained imprint variables (TRAIT-CONSTRAINED-
                    # IMPRINTED-TYPES.md): its signature is imprinted with
                    # it, so its body is checked for those types.
                    set declaredParamTypes [lmap t $declaredParamTypes {
                        if {$t eq {}} { set t } else { hir::types::canonical [hir::imprint::Substitute $t [dict get $head imprints]] }
                    }]
                }
                if {[dict get $head selection] ne {}} {
                    # The installed contexts this clone's context-trait
                    # operations call (CONTEXT-TRAITS.md): {TRAIT WITNESS ...}.
                    SetField hir $e contextClone [dict get $head selection]
                }
            }
            # The flag section (FLAGS.md): the last parameters, one bool
            # binding per declared flag, after the ordinary ones.
            lassign [hir::flags::Declare hir $e $node $bodyScope [CtxNamespace $ctx]] flagBindings flagTypes
            lappend params {*}$flagBindings
            lappend declaredParamTypes {*}$flagTypes
            SetField hir $e flags [lmap flag [dict getdef $node flags {}] {lindex $flag 0}]
            # The context section (CONTEXTS.md): not parameters. Each entry
            # is an ordinary local of the body, bound first, to the installed
            # context of its type (hir::contexts::DeclareParams).
            set body [concat [hir::contexts::DeclareParams hir $e $node $bodyScope [CtxNamespace $ctx]] \
                [dict get $node body]]
            NoteBody hir $bodyScope $body
            AddClosure hir $scope $e
            SetField hir $e bodyScope $bodyScope
            SetField hir $e params $params
            SetField hir $e declaredParamTypes $declaredParamTypes
            SetField hir $e captures {}
            SetField hir $e staticRefs {}
            set declared [dict getdef $node declaredResult {}]
            if {$declared ne {}} {
                if {[catch {ResolveTypeExpr $declared [CtxNamespace $ctx] 1} normalized options]} {
                    hir::Diagnose hir [TypeErrorKind $options TYPE] [format {unknown or invalid result type %s: %s} [ShowTypeExpr $declared] $normalized] $e
                    set declared {}
                } elseif {[hir::types::MentionedContextTrait $normalized] ne ""} {
                    hir::Diagnose hir CONTEXT-TRAIT-POSITION \
                        [hir::types::ContextTraitPositionMessage [hir::types::MentionedContextTrait $normalized] "a function's result type"] $e
                    set declared {}
                } else {
                    set declared $normalized
                }
            }
            if {$head ne "" && [dict get $head imprints] ne {} && $declared ne {}} {
                set declared [hir::types::canonical [hir::imprint::Substitute $declared [dict get $head imprints]]]
            }
            # Constrained variables (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md):
            # the obligations the signature's applications of parameterized
            # structs give its imprint variables, written on every
            # occurrence -- derived from the contract, never declared.
            lassign [hir::imprint::Constrain $declaredParamTypes $declared] constrainedParams declared
            if {$constrainedParams ne $declaredParamTypes} {
                set declaredParamTypes $constrainedParams
                SetField hir $e declaredParamTypes $declaredParamTypes
            }
            set resultWitness [hir::traits::ResultOverride $ctx $node $head]
            if {$resultWitness ne ""} {
                # A declared trait result: the witness the plan proved it has.
                SetField hir $e traitResult $declared
                if {$resultWitness eq "-"} {
                    set declared {}
                } else {
                    set declared $resultWitness
                }
            }
            SetField hir $e declaredResult $declared
            SetField hir $e resultType ""
            # A declared coroutine resume protocol (`resume T`,
            # COROUTINES.md): a struct type, the one message every yield of
            # the function's coroutine evaluates to (hir/coroutines.tcl).
            SetField hir $e declaredResume [ResolveResume hir $e $node $ctx]
            # A proof contract (REFINEMENT-VALUES.md), validated against the
            # resolved parameters and result: the generic metadata every
            # consumer reads (hir/refine.tcl), never a predicate's name.
            SetField hir $e proofs [ResolveProofs hir $e $node $params $declaredParamTypes $declared $ctx]
            set declaredErrorPairs [dict getdef $node declaredErrors {}]
            set errorNames {}
            set seenErrors [dict create]
            foreach pair $declaredErrorPairs {
                lassign $pair spelling errSpan
                # The canonical identity the spelling denotes in this code's
                # namespace (hir::errordecls::resolve): identities, never
                # short names, are what a contract holds and compares.
                set errName [hir::errordecls::resolve $spelling [CtxNamespace $ctx]]
                if {$errName eq ""} {
                    hir::Diagnose hir UNDECLARED-ERROR \
                        [hir::errordecls::unknownMessage $spelling [CtxNamespace $ctx]] $e
                    continue
                }
                if {[dict exists $seenErrors $errName]} {
                    hir::Diagnose hir DUPLICATE \
                        "duplicate error \"$errName\" in the same function's \"errors\" declaration" $e
                    continue
                }
                dict set seenErrors $errName 1
                lappend errorNames $errName
            }
            set errorNames [lsort -unique $errorNames]
            SetField hir $e declaredErrors $errorNames
            set inner [dict create scope $bodyScope callable $e loop "" errors $errorNames \
                blocks [concat [dict get $ctx blocks] [list [list $e $bodyScope]]] \
                namespace [CtxNamespace $ctx]]
            foreach field {traitContext clone cloneImprints} {
                if {[dict exists $ctx $field]} {
                    dict set inner $field [dict get $ctx $field]
                }
            }
            SetField hir $e body [Sequence hir $body $inner]
        }
        call {
            set written [dict get $node callee]
            set candidates {}
            set hidden {}
            set planned [hir::traits::CallAction $ctx $node]
            if {$planned ne "" && $planned ne "field"} {
                # A call the trait plan rewrites (TRAITS.md): a trait
                # operation to its implementation, a call of a trait-
                # polymorphic function to its clone for the call's witnesses.
                ResolvePlannedCall hir $e $node $planned $ctx
                if {[lindex $planned 0] ni {unreachable dead}} {
                    # (The placeholder of never-executed code takes no flags:
                    # it is no call of the function that declares them.)
                    hir::flags::ResolveCall hir $e $node $ctx
                }
                SetField hir $e target ""
                SetField hir $e known ""
                return $e
            }
            set layoutNative [LayoutNative $written]
            if {$layoutNative eq "" || [dict exists $node method]} {
                set layoutRole ""
            } else {
                set layoutRole [hir::layouts::Role $layoutNative]
            }
            if {[hir::layouts::RoleOf $layoutRole query] ne ""} {
                # A compile-time fact of a layout (BINARY-LAYOUT.md):
                # std::binary::layout_length(L) is L's size, a constant.
                ResolveLayoutQuery hir $e $node $layoutNative $layoutRole $ctx
                return $e
            }
            if {[dict exists $node method] && $planned ne "field"} {
                set candidates [MethodCandidates hir $scope [dict get $written name] $ctx \
                    [expr {[llength [dict get $node args]] + 1}] hidden]
            }
            if {[dict exists $node written]} {
                # How the call was spelled, and the namespace of the code it
                # is written in (whose imports the method spelling would
                # consult): diagnostics' provenance, recorded in every
                # compilation mode and read by no analysis.
                SetField hir $e written [dict create form [dict get $node written] ns [CtxNamespace $ctx]]
            }
            if {[dict exists $node operator]} {
                # An operator its operands' static types resolve
                # (hir/operators.tcl), read during typing; operatorCalls
                # lists every such call, in resolution order.
                SetField hir $e operator [dict get $node operator]
                dict lappend hir operatorCalls $e
            }
            if {$candidates ne ""} {
                # Method-call sugar (METHOD-SUGAR.md): `receiver.name(args)`
                # is the ordinary call of the function `name` denotes when
                # one is visible from here -- under ordinary lexical
                # resolution (the same walk a reference to `name` makes, so a
                # shadowing local is what the sugar sees) or as a member of a
                # directly imported namespace (`import std::list` makes
                # `std::list::at` a candidate for `xs.at(i)`, IMPORTS.md). The ref
                # is a real use (capture, call target, call graph). The
                # receiver is the first argument and is resolved (and later
                # evaluated) once, in that position. Nothing below this
                # point knows the spelling: the node is an ordinary `call`,
                # and `method` records only that the callee was written after
                # a ".", for the field/function ambiguity check (hir::
                # structs::verify). When several distinct functions are
                # candidates, MethodChoice picks the one the (re)build was
                # told is valid; hir::buildSyntax decides which that is.
                set name [dict get $written name]
                set nameOrigin [dict get $written nameOrigin]
                set chosen [MethodChoice hir $e $node $candidates]
                SetField hir $e callee [Expr hir [MethodCalleeSyntax $chosen $name $nameOrigin] $ctx]
                SetField hir $e args [Sequence hir [hir::variadic::Arguments hir $e \
                    [concat [list [dict get $written receiver]] [dict get $node args]]] $ctx]
                SetField hir $e method [dict create name $name nameOrigin $nameOrigin \
                    ns [CtxNamespace $ctx]]
            } else {
                SetField hir $e callee [Expr hir $written $ctx]
                set operand [hir::layouts::RoleOf $layoutRole operand]
                set path [hir::layouts::RoleOf $layoutRole path]
                if {$operand ne "" || $path ne ""} {
                    # The static layout operand of a binary operation
                    # (BINARY-LAYOUT.md): a layout name, resolved to the
                    # layout's descriptor constant -- never an expression.
                    # A write's field designator (NATIVE-LAYOUT-WRITES.md)
                    # likewise: LAYOUT.FIELD..., resolved to the field's
                    # designator constant.
                    set args {}
                    set index 0
                    foreach arg [dict get $node args] {
                        if {$index eq $operand} {
                            lappend args [LayoutOperand hir $arg $layoutNative $ctx]
                        } elseif {$index eq $path} {
                            lappend args [FieldPathOperand hir $arg $layoutNative $ctx]
                        } else {
                            lappend args [Expr hir $arg $ctx]
                        }
                        incr index
                    }
                    SetField hir $e args $args
                } else {
                    SetField hir $e args [Sequence hir [hir::variadic::Arguments hir $e [dict get $node args]] $ctx]
                }
                if {![dict exists $node method]} {
                    # `step(m)` on a coroutine handle (COROUTINES.md) is the
                    # explicit resume operation, not a call of a function
                    # value: the handle becomes its first argument.
                    CoroutineResume hir $e $ctx
                }
                if {[dict exists $node method] && $hidden ne ""} {
                    # The only function(s) of that name visible are declared
                    # nomethod (WARNINGS-METHOD-ELIGIBLE.md): method syntax
                    # never denotes one. A resolution diagnostic, like an
                    # unbound name; the call stays the call of a field value
                    # (never a call of the function), so a -strict 0 program
                    # that keeps the diagnostic fails at run time as well.
                    set shown [join [lmap h $hidden {string cat ` $h `}] {, }]
                    hir::DiagnoseAt hir NOMETHOD-CALL [::format {%s %s declared nomethod and cannot be called with method syntax; call %s as %s(receiver, ...)} \
                        $shown [expr {[llength $hidden] == 1 ? "is" : "are"}] \
                        [expr {[llength $hidden] == 1 ? "it" : "one of them"}] [lindex $hidden 0]] \
                        $e [dict get $written nameOrigin]
                } elseif {[dict exists $node method]} {
                    # No function `name` is visible: this is the call of a
                    # field value it has always been. Only diagnostics need
                    # to know it was written as a method call.
                    SetField hir [dict get $hir exprs $e callee] methodCallee 1
                }
            }
            if {[dict exists $node imprint]} {
                # Explicit imprints `f[T, ...](...)` (hir/imprint.tcl): each
                # a type, or a pointee identity (std::ffi::c::Void), bound to the
                # callee's variables by its typing (hir::types::Call).
                set imprint {}
                set valid 1
                set variables [hir::imprint::EnclosingVariables $hir $ctx]
                lappend variables {*}[dict keys [dict getdef $ctx cloneImprints {}]]
                set constraints [hir::imprint::EnclosingConstraints $hir $ctx]
                foreach t [dict get $node imprint] origin [dict get $node imprintOrigins] {
                    if {[catch {hir::cabi::ResolveImprint $t [CtxNamespace $ctx] $variables} type options]} {
                        hir::DiagnoseAt hir [TypeErrorKind $options TYPE] \
                            [format {unknown or invalid imprint %s: %s} [ShowTypeExpr $t] $type] $e $origin
                        set valid 0
                    }
                    # (A forwarded variable is its function's: constrained
                    # as its signature constrains it -- or, in a
                    # specialization for a binding, the imprinted type.)
                    lappend imprint [hir::imprint::BodyType $ctx [hir::imprint::ConstrainVariables $type $constraints]]
                }
                if {$valid} {
                    SetField hir $e imprint $imprint
                }
            }
            hir::flags::ResolveCall hir $e $node $ctx
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
                NoteBody hir $branch $body
                SetField hir $e ${role}Scope $branch
                SetField hir $e ${role}Body [Sequence hir $body [dict replace $ctx scope $branch]]
            }
            SetField hir $e refinements [dict create 1 {} 0 {}]
        }
        loop {
            set body [dict get $node body]
            set iteration [NewScope hir loop $scope \
                [dict get $hir scopes $scope invocation] $e [dict get $node bodyOrigin]]
            NoteBody hir $iteration $body
            SetField hir $e bodyScope $iteration
            SetField hir $e body [Sequence hir $body [dict replace $ctx scope $iteration loop $e]]
        }
        listloop {
            SetField hir $e iterable [Expr hir [dict get $node iterable] $ctx]
            set body [dict get $node body]
            set iteration [NewScope hir loop $scope \
                [dict get $hir scopes $scope invocation] $e [dict get $node bodyOrigin]]
            set elementBinding [NewBinding hir [dict get $node elementName] param \
                $iteration [dict get $node elementOrigin]]
            NoteBody hir $iteration $body
            SetField hir $e bodyScope $iteration
            SetField hir $e elementBinding $elementBinding
            SetField hir $e body [Sequence hir $body [dict replace $ctx scope $iteration loop $e]]
        }
        countloop {
            # START/END are resolved in the *enclosing* scope, exactly like
            # listloop's own iterable -- the induction binding is not in
            # scope in either of them (spec item 30): it enters scope only
            # in the body, exactly like listloop's own element binding.
            SetField hir $e start [Expr hir [dict get $node start] $ctx]
            SetField hir $e end [Expr hir [dict get $node end] $ctx]
            set body [dict get $node body]
            set iteration [NewScope hir loop $scope \
                [dict get $hir scopes $scope invocation] $e [dict get $node bodyOrigin]]
            set countBinding [NewBinding hir [dict get $node countName] param \
                $iteration [dict get $node countOrigin]]
            NoteBody hir $iteration $body
            SetField hir $e bodyScope $iteration
            SetField hir $e countBinding $countBinding
            SetField hir $e direction [dict get $node direction]
            SetField hir $e endKind [dict get $node endKind]
            SetField hir $e body [Sequence hir $body [dict replace $ctx scope $iteration loop $e]]
        }
        lockloop {
            # Every domain's operands are resolved in the *enclosing* scope,
            # in written order, exactly like listloop's iterable / countloop's
            # bounds: none of the loop's own bindings is in scope in any of
            # them. The iteration scope then binds one fresh immutable
            # parameter per domain, in written order.
            set domains {}
            foreach domain [dict get $node domains] {
                if {[dict get $domain kind] eq "list"} {
                    dict set domain iterable [Expr hir [dict get $domain iterable] $ctx]
                } else {
                    dict set domain start [Expr hir [dict get $domain start] $ctx]
                    dict set domain end [Expr hir [dict get $domain end] $ctx]
                }
                lappend domains $domain
            }
            set body [dict get $node body]
            set iteration [NewScope hir loop $scope \
                [dict get $hir scopes $scope invocation] $e [dict get $node bodyOrigin]]
            set resolved {}
            set seen {}
            foreach domain $domains {
                if {[dict get $domain name] in $seen} {
                    hir::Diagnose hir DUPLICATE-LOOP-VARIABLE \
                        "lockstep loop variable \"[dict get $domain name]\" is bound by more than one iteration clause" $e
                }
                lappend seen [dict get $domain name]
                dict set domain binding [NewBinding hir [dict get $domain name] param \
                    $iteration [dict get $domain origin]]
                dict unset domain name
                dict unset domain origin
                lappend resolved $domain
            }
            NoteBody hir $iteration $body
            SetField hir $e bodyScope $iteration
            SetField hir $e domains $resolved
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
            set loop [dict get $ctx loop]
            SetField hir $e target $loop
            if {$loop eq ""} {
                hir::Diagnose hir BREAK-OUTSIDE-LOOP "break outside lexical loop" $e
            } elseif {$value ne "" && [dict get $hir exprs $loop kind] in {listloop countloop lockloop}} {
                # RETURNING-ITERABLE-LOOPS.md: a returning iterable loop
                # (`loop x in xs:`) has exactly one stable result type, the
                # collected List -- a bare `break` ends it with the prefix
                # collected so far (this same case's own `value` stays "",
                # never a payload). `break VALUE` would let one reachable
                # exit override that List with an arbitrary, unrelated
                # type, exactly the soundness hazard LISTLOOP-BREAK-TYPE-
                # SOUNDNESS.md once had to reason about for the old
                # override semantics; disallowing it outright here removes
                # the hazard at the source instead of re-deriving it in
                # hir/types.tcl on every listloop. This check stays
                # listloop-specific (not a universal "no HIR break may ever
                # carry a value" rule) -- PAYLOAD-FREE-BREAK.md's own "two-
                # tier" design, below, explains why a plain `loop:`/countloop
                # target does not need the same defense here.
                hir::Diagnose hir LISTLOOP-BREAK-VALUE \
                    "break with a value is not valid inside a collecting loop (loop x in ..., loop i from ...): use a bare break to end the loop with the collected prefix" $e
            }
            # PAYLOAD-FREE-BREAK.md: at the *surface language* level, break
            # never carries a value in any loop kind -- but that rule is
            # enforced entirely in the parser (surface/parser.tcl's own
            # `break` case in Simple), not here. No valid parse can ever
            # reach this proc with a nonempty break value, so this proc adds
            # no defensive check of its own for a plain `loop:`/countloop
            # target, deliberately (a change from that milestone's own
            # default "add a resolver-defense check for any internal
            # construction path below the parser" guidance -- see that
            # report's own "Two-tier design" section for why: this HIR/core-
            # IR level is also reachable from *below* the surface parser,
            # via `hir::syntax::breakNode`'s own optional value and, more
            # importantly, `hir::build`'s `fromIR` (raw core-IR text lifted
            # straight to HIR, e.g. for the native backend's own
            # `bench/loop-count.ir`) -- and a plain `loop:`/countloop target
            # there deliberately keeps its full pre-milestone override-and-
            # discard `break VALUE` semantics, unchanged end to end
            # (resolve/types/interpreter/Tcl-compile/native-lowering alike),
            # both to keep that already-canonical, historically-compared
            # benchmark's exact behavior and generated code stable, and as
            # the substrate the future `leave VALUE` construct (this
            # milestone's own ADR, deliberately not implemented here) is
            # expected to lower to. It is "payload-free" in the sense that
            # matters for the *language*: no Botlish program, compiled
            # through the surface frontend, can ever produce it.
        }
        continue {
            SetField hir $e target [dict get $ctx loop]
            if {[dict get $ctx loop] eq ""} {
                hir::Diagnose hir CONTINUE-OUTSIDE-LOOP "continue outside lexical loop" $e
            }
        }
        struct {
            ResolveStruct hir $e $node $ctx
        }
        project {
            SetField hir $e receiver [Expr hir [dict get $node receiver] $ctx]
            SetField hir $e name [dict get $node name]
            SetField hir $e nameOrigin [dict get $node nameOrigin]
            # The namespace of the code the projection is written in: what
            # representation authority over an opaque receiver is checked
            # against after inference (hir/structs.tcl, OPAQUE-STRUCTS.md).
            SetField hir $e ns [CtxNamespace $ctx]
            if {[dict exists $node indices]} {
                # `x.name[3]` outside a layout field designator
                # (FIXED-LAYOUT-ARRAYS.md): there is no index expression.
                set index [lindex [dict get $node indices] 0]
                hir::DiagnoseAt hir LAYOUT-OPERAND [::format {an element index (%s[%s]) is written only in a layout field designator, std::binary::store(e, L.items[3], v) or std::binary::write(d, L.items[3], v): Botlish has no index expression (an element of a live array is std::binary::element(a, i), of a List std::list::at(xs, i))} \
                    [dict get $node name] [lindex $index 0]] $e [lindex $index 1]
            }
        }
        ok - error {
            SetField hir $e value [Expr hir [dict get $node value] $ctx]
        }
        fail {
            # The error's canonical identity in this code's namespace
            # (hir::errordecls::resolve); an unknown spelling stays as
            # written, diagnosed below.
            set spelling [dict get $node name]
            set name [hir::errordecls::resolve $spelling [CtxNamespace $ctx]]
            set known [expr {$name ne ""}]
            if {!$known} {
                set name $spelling
            }
            SetField hir $e name $name
            if {[dict exists $node static]} {
                # The reified failure of a rejected static site
                # (hir/static.tcl): provenance, never semantics.
                SetField hir $e static [dict get $node static]
            }
            # The payload (ERROR-PAYLOADS.md) is evaluated before the error is
            # raised: resolved first, in the enclosing scope.
            set value ""
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                set value [Expr hir [dict get $node value] $ctx]
            }
            SetField hir $e value $value
            if {!$known} {
                hir::Diagnose hir UNDECLARED-ERROR \
                    [hir::errordecls::unknownMessage $spelling [CtxNamespace $ctx]] $e
            } elseif {$name ni [dict get $ctx errors] && [dict exists $node static]} {
                # Nobody wrote this `fail`: the site's body was rejected, and
                # its completion is the error, where the enclosing code must
                # handle or admit it like any other (STATIC-COMPILE.md).
                set static [dict get $node static]
                set remedy [expr {[dict get $ctx callable] eq ""
                    ? "a program's top level admits no error: write the block in a function that declares \"errors $name\" and handle the error where it is called"
                    : "handle it, or declare \"errors $name\" on the enclosing function"}]
                hir::Diagnose hir UNHANDLED-ERROR \
                    "this \"static [dict get $static operation]:\" block's body was rejected ([dict get $static kind]), so the block completes with the error \"$name\", which is not admitted here: $remedy" $e
            } elseif {$name ni [dict get $ctx errors]} {
                hir::Diagnose hir UNHANDLED-ERROR \
                    "\"fail $spelling\" is not admitted here: the enclosing function does not declare \"errors $spelling\"" $e
            }
            if {$known} {
                if {[hir::errordecls::hasPayload $name] && $value eq ""} {
                    hir::Diagnose hir MISSING-ERROR-PAYLOAD \
                        "error \"$name\" carries a payload, which \"fail $spelling\" must construct: write \"fail $spelling \{[join [lmap f [hir::errordecls::fieldNames $name] {string cat $f {: ...}}] {, }]\}\" (the error's name alone is not its payload)" $e
                } elseif {![hir::errordecls::hasPayload $name] && $value ne ""} {
                    hir::Diagnose hir UNEXPECTED-ERROR-PAYLOAD \
                        "error \"$name\" declares no payload: write \"fail $spelling\" (to give it one, declare its fields: \"error [hir::errordecls::shortName $name]:\" followed by \"field: Type\" lines)" $e
                }
            }
        }
        handle {
            set callExpr [Expr hir [dict get $node call] $ctx]
            if {[dict get $hir exprs $callExpr kind] ne "call"} {
                core::malformed "the handled expression of \"handle\" must be a call" $node
            }
            SetField hir $e call $callExpr
            set names {}
            set scopes {}
            set bodies {}
            set payloads {}
            set seen [dict create]
            set index 0
            foreach handler [dict get $node handlers] {
                incr index
                # Selection is by canonical identity (hir::errordecls::
                # resolve): `on NotFound` inside module http and `on
                # http::NotFound` outside it are one handler of one error,
                # `on cache::NotFound` another.
                set spelling [dict get $handler name]
                set name [hir::errordecls::resolve $spelling [CtxNamespace $ctx]]
                set known [expr {$name ne ""}]
                if {!$known} {
                    set name $spelling
                }
                set body [dict get $handler body]
                if {[dict exists $seen $name]} {
                    hir::Diagnose hir DUPLICATE \
                        "duplicate \"on $spelling\" handler in the same handled call (error \"$name\" is already handled)" $e
                    continue
                }
                dict set seen $name 1
                if {!$known} {
                    hir::Diagnose hir UNDECLARED-ERROR \
                        [hir::errordecls::unknownMessage $spelling [CtxNamespace $ctx]] $e
                }
                set branch [NewScope hir branch $scope \
                    [dict get $hir scopes $scope invocation] $e [dict get $handler origin]]
                NoteBody hir $branch $body
                # What the handler receives of the selected error's payload
                # (ERROR-PAYLOADS.md): a binding of the handler's own scope,
                # established before its body -- the name written, or a
                # destructuring's hygienic temporary (whose projection binds
                # open the body). Selection is the error name alone. An
                # ignored payload that owns affine values gets a hidden
                # binding, so it is released by the ordinary rules
                # (hir/affine.tcl) -- never left to a collector.
                set payload [dict getdef $handler payload ""]
                set binding ""
                if {$payload ne ""} {
                    set binding [NewBinding hir [dict get $payload name] param $branch [dict get $payload origin]]
                    if {$known && ![hir::errordecls::hasPayload $name]} {
                        hir::DiagnoseAt hir UNEXPECTED-ERROR-PAYLOAD \
                            "error \"$name\" declares no payload: there is nothing to bind (write \"on $spelling:\")" \
                            $e [dict get $payload origin]
                    }
                } elseif {[hir::errordecls::hasPayload $name]
                        && [hir::types::IsAffine [hir::errordecls::payloadType $name]]} {
                    set binding [NewBinding hir "payload#$e#$index" param $branch [dict get $handler origin]]
                }
                lappend names $name
                lappend scopes $branch
                lappend payloads $binding
                lappend bodies [Sequence hir $body [dict replace $ctx scope $branch]]
            }
            SetField hir $e handlerNames $names
            SetField hir $e handlerScopes $scopes
            SetField hir $e handlerBodies $bodies
            SetField hir $e handlerPayloads $payloads
        }
        default {
            core::malformed "unknown syntax node kind \"$kind\"" $node
        }
    }
    return $e
}

# The resolved `resume TYPE` clause of block syntax NODE (resolved as ExprId
# E), or "" (COROUTINES.md). The resume message of a first-milestone
# coroutine is one struct value of a declared struct type: no scalar, List or
# function protocol (COROUTINE-RESUME-TYPE), so a later tagged union of
# struct cases extends it rather than replacing it.
proc hir::resolve::ResolveResume {hirVar e node ctx} {
    upvar 1 $hirVar hir
    if {![dict exists $node resume]} {
        return ""
    }
    lassign [dict get $node resume] typeExpr origin
    if {[catch {ResolveTypeExpr $typeExpr [CtxNamespace $ctx]} type options]} {
        hir::DiagnoseAt hir [TypeErrorKind $options TYPE] \
            [format {unknown or invalid resume type %s: %s} [ShowTypeExpr $typeExpr] $type] $e $origin
        return ""
    }
    if {[lindex $type 0] ne "nstruct"} {
        hir::DiagnoseAt hir COROUTINE-RESUME-TYPE \
            [format {the resume message type must be a declared struct type, not %s: a coroutine is resumed with one structured message (put several values in the fields of a struct, e.g. "struct Input:" with one field per value)} \
                [ShowTypeExpr $typeExpr]] $e $origin
        return ""
    }
    return $type
}

# 1 if binding B holds a coroutine handle by construction: it is bound to the
# result of coroutine#create (surface/lower.tcl's CoroutineBind), or to a
# reference of another such binding (a move, `next = step`).
proc hir::resolve::IsCoroutineBinding {hirVar b {seen {}}} {
    upvar 1 $hirVar hir
    if {$b eq "" || $b in $seen || ![dict exists $hir bindings $b]} {
        return 0
    }
    set by [dict get $hir bindings $b declaredBy]
    if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"} {
        return 0
    }
    if {![dict exists $hir exprs $by value] || [dict get $hir exprs $by value] eq ""} {
        return 0
    }
    set value [dict get $hir exprs [dict get $hir exprs $by value]]
    switch -- [dict get $value kind] {
        ref {
            return [IsCoroutineBinding hir [dict get $value binding] [concat $seen [list $b]]]
        }
        call {
            set callee [dict get $hir exprs [dict get $value callee]]
            if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} {
                return 0
            }
            set binding [dict get $hir bindings [dict get $callee binding]]
            return [expr {[dict get $binding kind] eq "root"
                && [dict get $binding name] eq [core::coroutines::createNative]}]
        }
    }
    return 0
}

# Call E, already resolved as the call of its written callee: when that is a
# reference to a coroutine handle (IsCoroutineBinding), the call is the
# resume operation `coroutine#resume(handle, ARGS...)` (COROUTINES.md) and is
# rewritten to say so -- the handle becomes the first argument of the internal
# root native, the written arguments follow.
proc hir::resolve::CoroutineResume {hirVar e ctx} {
    upvar 1 $hirVar hir
    set callee [dict get $hir exprs $e callee]
    set node [dict get $hir exprs $callee]
    if {[dict get $node kind] ne "ref" || ![IsCoroutineBinding hir [dict get $node binding]]} {
        return
    }
    set origin [dict get $node origin]
    set native [Expr hir [hir::syntax::rootRef $origin [core::coroutines::resumeNative]] $ctx]
    SetField hir $e callee $native
    SetField hir $e args [concat [list $callee] [dict get $hir exprs $e args]]
}

# The module namespace ("" for the entry program) the code of CTX is in:
# what an unqualified struct name resolves against.
proc hir::resolve::CtxNamespace {ctx} {
    return [dict getdef $ctx namespace ""]
}

# Resolves struct construction E (STRUCTS.md): the field initializers in
# WRITTEN order (their evaluation order), the named struct's declaration if
# any, and the canonical slot layout. Every static construction error is a
# diagnostic located at the field it concerns:
#   UNKNOWN-STRUCT     `Name { ... }` names no visible struct declaration
#   DUPLICATE-FIELD    a field given twice
#   UNKNOWN-FIELD      a named construction gives a field the struct lacks
#   MISSING-FIELD      a named construction omits a declared field (there are
#                      no defaults: every field is given exactly once)
# Whether each value fits its declared field type is hir/range.tcl's
# VerifyStruct, after inference.
proc hir::resolve::ResolveStruct {hirVar e node ctx} {
    upvar 1 $hirVar hir
    set typeRef [dict get $node type]
    set ns [CtxNamespace $ctx]
    set named [expr {$typeRef ne ""}]
    set id ""
    set spelling ""
    # Whether a source construction of an opaque struct is made without
    # authority over its representation (OPAQUE-STRUCTS.md): only a spelling
    # the source wrote can be (a type reference carrying an `id` is core IR's,
    # past the source boundary).
    set denied 0
    # A parameterized struct's explicit arguments, "" when none are written.
    set structArgs ""
    if {$named} {
        if {[dict exists $typeRef id]} {
            set id [dict get $typeRef id]
            set spelling $id
            if {![hir::structs::declared $id]} {
                hir::Diagnose hir UNKNOWN-STRUCT \
                    "unknown struct type \"$id\": no such struct declaration is visible" $e
                set id ""
            }
        } elseif {([dict exists $typeRef typeArg] || [dict exists $typeRef typeArgs])
                && ([dict get $typeRef name] ne "LayoutStruct" || [dict getdef $typeRef namespace ""] ne ""
                    || [dict exists $typeRef typeArgs])} {
            # NAME[A, ...] { ... }: the construction of a parameterized
            # struct's application, applied explicitly (TRAIT-CONSTRAINED-
            # IMPRINTED-TYPES.md): its fields are the declaration's with the
            # slots replaced by the arguments (hir::range::VerifyStruct).
            lassign [ResolveAppliedConstruction hir $e $typeRef $ctx] id spelling structArgs denied
        } elseif {[dict exists $typeRef typeArg]} {
            # NAME[TYPE] { ... } (BINARY-LAYOUT.md): the construction of an
            # applied type, the explicit type the imprinting design writes on
            # an expression: LayoutStruct[L]'s, whose fields are L's.
            set ctor [dict get $typeRef name]
            set argText [ShowTypeExpr [dict get $typeRef typeArg]]
            set spelling "$ctor\[$argText\]"
            if {[catch {hir::layouts::ResolveLayoutStruct [dict get $typeRef typeArg] $ns} type options]} {
                set id ""
                hir::DiagnoseAt hir [TypeErrorKind $options LAYOUT-STRUCT-PARAMETER] $type $e \
                    [dict get $typeRef typeArgOrigin]
            } else {
                set id [lindex $type 1]
            }
        } else {
            set tns [dict get $typeRef namespace]
            set tname [dict get $typeRef name]
            if {$tns eq ""} {
                set spelling $tname
            } else {
                set spelling "${tns}::$tname"
            }
            set id [hir::structs::lookup $spelling $ns]
            if {$id eq ""} {
                set why [expr {[hir::structs::IsOtherType $tname] && $tns eq ""
                    ? "\"$tname\" is not a struct type"
                    : "unknown struct type \"$spelling\": no \"struct $tname\" declaration is visible"}]
                if {[hir::layouts::lookup $spelling $ns] ne ""} {
                    # BINARY-LAYOUT.md: a layout is no struct; its values
                    # are LayoutStruct[L]'s.
                    set why "\"$spelling\" is a layout, not a struct: its structural value is constructed as LayoutStruct\[$spelling\] \{...\}"
                }
                hir::DiagnoseAt hir UNKNOWN-STRUCT $why $e [dict get $typeRef origin]
            } elseif {[hir::structs::representationDenied $id $ns]} {
                set denied 1
                hir::DiagnoseAt hir OPAQUE-CONSTRUCTION [hir::structs::ConstructionMessage $id] $e \
                    [dict get $typeRef origin]
            }
        }
    }
    set names {}
    set nameOrigins {}
    set fieldOrigins {}
    set values {}
    foreach field [dict get $node fields] {
        lappend names [dict get $field name]
        lappend nameOrigins [dict get $field nameOrigin]
        lappend fieldOrigins [dict get $field origin]
        lappend values [Expr hir [dict get $field value] $ctx]
    }
    set what [expr {$named ? "the $spelling construction" : "this struct initializer"}]
    if {!$named} {
        set layout [lsort -unique $names]
    } elseif {$id ne ""} {
        set layout [hir::structs::names $id]
    } else {
        set layout [lsort -unique $names]
    }
    set seen {}
    foreach name $names origin $fieldOrigins {
        if {$denied} {
            # The caller has no authority over the representation: it learns
            # nothing about its fields (not which exist, not which are
            # missing), only the one OPAQUE-CONSTRUCTION above.
            break
        }
        if {$name in $seen} {
            hir::DiagnoseAt hir DUPLICATE-FIELD \
                "duplicate field \"$name\" in $what: each field may be given only once" $e $origin
            continue
        }
        lappend seen $name
        if {$named && $id ne "" && $name ni $layout} {
            hir::DiagnoseAt hir UNKNOWN-FIELD \
                "struct $spelling has no field \"$name\" (declared fields: [join $layout {, }])" $e $origin
        }
    }
    if {$named && $id ne "" && !$denied} {
        foreach declared $layout {
            if {$declared ni $names} {
                hir::Diagnose hir MISSING-FIELD \
                    "$what is missing field \"$declared\" (every declared field must be given exactly once; there are no defaults)" $e
            }
        }
    }
    if {[dict exists $node payloadOf]} {
        # The payload of `fail NAME {...}` (ERROR-PAYLOADS.md): an anonymous
        # struct value checked exactly as a named construction is, against
        # the error's declared payload fields -- every field once, none
        # undeclared (hir::range::VerifyStruct proves each value admissible
        # for its declared type). A payload-free or unknown error has no
        # fields to check against (the fail itself is diagnosed).
        # The canonical identity the `fail` spelling denotes here (the fail
        # node resolves it the same way); an unknown one has no fields.
        set errorName [hir::errordecls::resolve [dict get $node payloadOf] $ns]
        if {$errorName eq ""} {
            set errorName [dict get $node payloadOf]
        }
        SetField hir $e payloadOf $errorName
        if {[hir::errordecls::hasPayload $errorName]} {
            set declaredNames [hir::errordecls::fieldNames $errorName]
            set reported {}
            foreach name $names origin $fieldOrigins {
                if {$name ni $declaredNames && $name ni $reported} {
                    lappend reported $name
                    hir::DiagnoseAt hir UNKNOWN-FIELD \
                        "the payload of error $errorName has no field \"$name\" (declared fields: [join $declaredNames {, }])" $e $origin
                }
            }
            foreach declared $declaredNames {
                if {$declared ni $names} {
                    hir::Diagnose hir MISSING-FIELD \
                        "the payload of error $errorName is missing field \"$declared\" (every declared field must be given exactly once; there are no defaults)" $e
                }
            }
        }
    }
    SetField hir $e named $named
    if {$denied} {
        # Read by hir::range::VerifyStruct, which must not prove (or word a
        # diagnostic about) the fields of a construction that is rejected.
        SetField hir $e opaqueDenied 1
    }
    SetField hir $e structId $id
    if {$structArgs ne ""} {
        SetField hir $e structArgs $structArgs
    }
    SetField hir $e names $names
    SetField hir $e nameOrigins $nameOrigins
    SetField hir $e fieldOrigins $fieldOrigins
    SetField hir $e fields $values
    SetField hir $e layout $layout
    SetField hir $e slots [lmap name $names {lsearch -exact $layout $name}]
}

# {ID SPELLING ARGS DENIED}: the construction E of the explicit application
# TYPEREF -- `Pair[int, str] {...}`, `geo::Pair[int, str] {...}` -- in
# context CTX (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): the parameterized
# struct ID its constructor denotes, the construction's spelling, the
# resolved arguments (an imprint variable of an enclosing function stands for
# whatever that function's calls imprint, constrained as its signature
# constrains it) and whether the code lacks authority over an opaque
# struct's representation. ID "" after a diagnostic.
proc hir::resolve::ResolveAppliedConstruction {hirVar e typeRef ctx} {
    upvar 1 $hirVar hir
    set ns [CtxNamespace $ctx]
    set ctor [dict get $typeRef name]
    if {[dict getdef $typeRef namespace ""] ne ""} {
        set ctor "[dict get $typeRef namespace]::$ctor"
    }
    if {[dict exists $typeRef typeArgs]} {
        set args [dict get $typeRef typeArgs]
    } else {
        set args [list [dict get $typeRef typeArg]]
    }
    set spelling "$ctor\[[join [lmap t $args {ShowTypeExpr $t}] {, }]\]"
    set id [hir::structs::lookup $ctor $ns]
    if {$id eq "" || ![hir::structs::isParameterized $id]} {
        hir::DiagnoseAt hir UNKNOWN-STRUCT \
            "$spelling is not a struct type: of the applied types, only LayoutStruct\[L\] and the applications of parameterized structs (struct NAME\[SLOT, ...\]:) are constructed from field values" \
            $e [dict get $typeRef origin]
        return [list "" $spelling "" 0]
    }
    set variables [hir::imprint::EnclosingVariables $hir $ctx]
    lappend variables {*}[dict keys [dict getdef $ctx cloneImprints {}]]
    if {[catch {ResolveApplied $ctor $args $ns [if {$variables eq {}} {string cat 0} else {set variables}]} type options]} {
        hir::DiagnoseAt hir [TypeErrorKind $options TYPE] \
            [format {invalid applied type %s: %s} $spelling $type] $e [dict get $typeRef origin]
        return [list "" $spelling "" 0]
    }
    set type [hir::imprint::BodyType $ctx [hir::imprint::ConstrainVariables $type [hir::imprint::EnclosingConstraints $hir $ctx]]]
    set denied 0
    if {[hir::structs::representationDenied $id $ns]} {
        set denied 1
        hir::DiagnoseAt hir OPAQUE-CONSTRUCTION [hir::structs::ConstructionMessage $id] $e \
            [dict get $typeRef origin]
    }
    return [list $id $spelling [hir::types::StructArgs $type] $denied]
}

# Resolves the syntax nodes NODES in order.
proc hir::resolve::Sequence {hirVar nodes ctx} {
    upvar 1 $hirVar hir
    set ids {}
    set planned [hir::traits::Planning]
    foreach node $nodes {
        if {$planned && [dict exists $node sid]} {
            # A trait program's monomorphization plan (TRAITS.md): a trait-
            # polymorphic declaration (and an alias of one) is replaced by its
            # clones, each placed before the first top-level statement that
            # needs it.
            if {[hir::traits::Dropped [dict get $node sid]]} {
                continue
            }
            foreach key [hir::traits::PlacedBefore [dict get $node sid]] {
                lappend ids [ResolveClone hir $key $ctx]
            }
        }
        lappend ids [Expr hir $node $ctx]
    }
    return $ids
}

# Resolves trait clone KEY (hir::traits::Plan) as a function bound in the
# scope of CTX: the source function's own block syntax, resolved with its
# own namespace, its trait parameters typed by the clone's witnesses, every
# reference outside the function resolved to the binding the source
# function's resolution found, and every call the plan rewrites rewritten for
# this clone. Returns the bind's ExprId.
proc hir::resolve::ResolveClone {hirVar key ctx} {
    upvar 1 $hirVar hir
    set clone [hir::traits::CloneRecord $key]
    set node [dict get $clone node]
    set scope [dict get $ctx scope]
    set origin [dict get $node origin]
    set e [hir::NewId hir expr]
    dict set hir exprs $e [dict create id $e kind bind origin $origin scope $scope type "" reachable 1]
    SetField hir $e name [dict get $clone name]
    Establish hir $e $scope [dict get $clone name] $origin
    set b [dict get $hir exprs $e binding]
    dict set hir bindings $b traitClone $key
    hir::traits::NoteCloneBinding $key $b
    hir::flags::DeclareFunction hir $b [dict get $node value]
    if {[dict exists $node value nomethod]} {
        dict set hir bindings $b nomethod 1
    }
    set inner [dict replace $ctx namespace [dict get $clone namespace] traitContext $key \
        clone [dict get $clone function] cloneHead [dict create key $key sid [dict get $node value sid] \
            params [dict get $clone params] result [dict get $clone result] \
            selection [dict get $clone selection] imprints [dict getdef $clone imprints {}]] \
        cloneImprints [dict getdef $clone imprints {}]]
    SetField hir $e value [Expr hir [dict get $node value] $inner]
    return $e
}

# Resolves the already-created reference expression E to the binding IDENT
# names (hir::traits's location-independent identities: {root NAME},
# {native QUALIFIED}, {module NS NAME}, {entry NAME}, {clone KEY},
# {local NAME}).
proc hir::resolve::ResolveIdent {hirVar e ident ctx} {
    upvar 1 $hirVar hir
    switch -- [lindex $ident 0] {
        root - native {
            ResolveRef hir $e [lindex $ident 1] 1 $ctx
        }
        local {
            ResolveRef hir $e [lindex $ident 1] 0 $ctx
        }
        module {
            ResolveQualifiedRef hir $e [lrange $ident 1 2] $ctx
        }
        entry - clone {
            if {[lindex $ident 0] eq "entry"} {
                set top [dict get $hir top]
                set name [lindex $ident 1]
                if {![dict exists $hir scopes $top names $name]} {
                    core::malformed "trait plan: entry-program binding \"$name\" is not established here" [list ref $name]
                }
                set b [dict get $hir scopes $top names $name]
            } else {
                set b [hir::traits::CloneBinding [lindex $ident 1]]
            }
            SetField hir $e name [dict get $hir bindings $b name]
            SetField hir $e binding $b
            SetField hir $e init yes
            hir::flags::NoteRef hir $e
            Capture hir $ctx [dict get $hir bindings $b scope] $b
        }
        default {
            error "hir::resolve::ResolveIdent: unknown identity $ident"
        }
    }
}

# Resolves call E (syntax NODE) as the trait plan's ACTION says: {redirect
# KEY} calls clone KEY, {trait IDENT ...} the implementation IDENT names, the
# receiver of a method-syntax call becoming the first argument; {context
# OPERATION ?KEY?} the selected context's implementation of a context-trait
# operation (or, with KEY, that implementation's own clone), with the written
# arguments only -- the context-trait binding that was the receiver is no
# value and is not evaluated (CONTEXT-TRAITS.md); {unreachable} code no
# installed context reaches, never executed: the internal native
# context#unreachable, with no arguments; {dead} a dead call of a trait-
# polymorphic function (an argument of type `never`, no instance): the same
# placeholder given the call's arguments -- the receiver of a method-syntax
# call first --, which still run in order up to the one that never completes.
proc hir::resolve::ResolvePlannedCall {hirVar e node action ctx} {
    upvar 1 $hirVar hir
    set written [dict get $node callee]
    if {[lindex $action 0] in {context unreachable dead}} {
        if {[dict exists $node method]} {
            set origin [dict get $written nameOrigin]
        } else {
            set origin [dict get $written origin]
        }
        set c [hir::NewId hir expr]
        dict set hir exprs $c [dict create id $c kind ref origin $origin scope [dict get $ctx scope] type "" reachable 1]
        if {[lindex $action 0] eq "unreachable"} {
            ResolveRef hir $c [hir::contexts::UnreachableNative] 1 $ctx
            SetField hir $e callee $c
            SetField hir $e args {}
            return
        }
        if {[lindex $action 0] eq "dead"} {
            set argNodes [dict get $node args]
            if {[dict exists $node method]} {
                set argNodes [concat [list [dict get $written receiver]] $argNodes]
            }
            ResolveRef hir $c [hir::contexts::UnreachableNative] 1 $ctx
            SetField hir $e callee $c
            SetField hir $e args [Sequence hir $argNodes $ctx]
            return
        }
        set operation [lindex $action 1]
        if {[llength $action] > 2} {
            ResolveIdent hir $c [list clone [lindex $action 2]] $ctx
        } else {
            ResolveIdent hir $c [dict get $operation impl] $ctx
        }
        SetField hir $e traitImpl $operation
        SetField hir $e callee $c
        SetField hir $e args [Sequence hir [dict get $node args] $ctx]
        return
    }
    if {[dict exists $node written]} {
        SetField hir $e written [dict create form [dict get $node written] ns [CtxNamespace $ctx]]
    }
    if {[dict exists $node method]} {
        set calleeOrigin [dict get $written nameOrigin]
        set argNodes [concat [list [dict get $written receiver]] [dict get $node args]]
    } else {
        set calleeOrigin [dict get $written origin]
        set argNodes [dict get $node args]
    }
    set c [hir::NewId hir expr]
    dict set hir exprs $c [dict create id $c kind ref origin $calleeOrigin scope [dict get $ctx scope] type "" reachable 1]
    switch -- [lindex $action 0] {
        redirect {
            ResolveIdent hir $c [list clone [lindex $action 1]] $ctx
        }
        trait {
            ResolveIdent hir $c [dict get [lindex $action 1] impl] $ctx
            SetField hir $e traitImpl [lindex $action 1]
        }
        method {
            # A method-syntax call in a clone: the function the source
            # function's own resolution chose, whatever is visible where the
            # clone is placed.
            ResolveIdent hir $c [lindex $action 1] $ctx
        }
    }
    if {[dict exists $node method]} {
        SetField hir $e method [dict create name [dict get $written name] \
            nameOrigin [dict get $written nameOrigin] ns [CtxNamespace $ctx]]
    }
    SetField hir $e callee $c
    SetField hir $e args [Sequence hir [hir::variadic::Arguments hir $e $argNodes] $ctx]
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
# unlike the raw pre-resolution -native-body substitution the native backend
# once did on core IR text (NATIVE-URI-ESCAPE.md; removed by
# DIRECT-HIR-NATIVE-PATH.md, and the module-native bridge that replaced
# it by REFINEMENT-VALUES.md), this runs as part of
# hir::resolve's own ordinary walk, after full lexical resolution of
# everything reachable so far.
#
# Every reference reaching here was already validated, by
# surface::modules::CollectAndLoad, to name a namespace that was loaded and
# a definition it actually has, before this HIR was ever built -- so
# failure here is an internal invariant violation (a caller that built
# syntax nodes without going through surface/modules.tcl), not a
# user-facing diagnostic.
proc hir::resolve::ResolveQualifiedRef {hirVar e pair ctx} {
    upvar 1 $hirVar hir
    lassign $pair ns name
    set qualified "${ns}::${name}"
    SetField hir $e name $qualified
    if {![dict exists $hir modules $ns] || ![dict exists $hir scopes [dict get $hir modules $ns] names $name]} {
        if {$ns eq [CtxNamespace $ctx] && [dict exists $hir modules $ns]} {
            # A member of the module's own namespace that is not established
            # yet: the ordinary forward-reference rule (nothing is hoisted).
            SetField hir $e binding ""
            SetField hir $e init yes
            hir::Diagnose hir UNBOUND \
                "unbound name \"$qualified\": \"$name\" is not established before this point in its own namespace; forward references are not allowed (a binding is visible only after it is established)" $e
            return
        }
    }
    if {![dict exists $hir modules $ns]} {
        core::malformed "unresolved module reference ${ns}::${name}: module \"$ns\" was not loaded into this program" [list ref "${ns}::${name}"]
    }
    set bodyScope [dict get $hir modules $ns]
    if {![dict exists $hir scopes $bodyScope names $name]} {
        core::malformed "unresolved module reference ${ns}::${name}: namespace \"$ns\" has no definition \"$name\"" [list ref "${ns}::${name}"]
    }
    set b [dict get $hir scopes $bodyScope names $name]
    SetField hir $e binding $b
    SetField hir $e init yes
    hir::flags::NoteRef hir $e
    # The module section scope is never within any enclosing block's own
    # body scope (it is always a sibling of the program's top scope), so
    # this always captures through every enclosing block, exactly like an
    # ordinary reference to a binding declared outside all of them
    # (Capture; see this proc's own header and the file header's module-
    # qualified-reference bullet). Interp does not need this -- a module
    # binding is reachable by binding id alone, in the shared top-level
    # frame -- but native lowering does: a function's only way to reach
    # anything beyond its own params is a capture, and a module binding
    # that is itself a closure (retains state) is such a reach.
    Capture hir $ctx [dict get $hir bindings $b scope] $b
}

# ---------------------------------------------------------------------------
# Layouts in expressions (BINARY-LAYOUT.md)
#
# A layout is never a value. It is written in an expression only as the
# layout operand of a binary operation -- a root native whose registration
# carries a -layout role (hir/layouts.tcl) -- where it is the static evidence
# imprinting reads: the operand is resolved here, by name, to the layout's
# descriptor constant (no runtime layout object exists), and a query
# (std::binary::layout_length(L)) is replaced by the fact it asks for.
#
#   UNKNOWN-LAYOUT       the operand names no visible layout
#   LAYOUT-OPERAND       the operand is not a layout name (an expression, a
#                        value)
#   LAYOUT-NOT-A-VALUE   a layout named anywhere else in an expression

# The root native the callee syntax WRITTEN denotes when it is a root
# reference (a bare root name, or a qualified intrinsic, which surface/
# lower.tcl lowers to one) of a native with a -layout role, else "". A root
# reference denotes its native whatever local bindings are called.
proc hir::resolve::LayoutNative {written} {
    if {[dict get $written kind] ne "ref" || ![dict exists $written root] || ![dict get $written root]} {
        return ""
    }
    set name [dict get $written name]
    if {[hir::layouts::Role $name] ne ""} {
        return $name
    }
    return ""
}

proc hir::resolve::LayoutNotAValueMessage {name} {
    return "\"$name\" is a layout, not a value: a layout is named in a type (LayoutStruct\[$name\]) or as the layout operand of a binary operation (std::binary::parse($name, data), std::binary::layout_length($name)), and no runtime layout object exists"
}

# If the qualified reference syntax NODE (resolved as E) names a layout and
# no definition of its module, diagnoses LAYOUT-NOT-A-VALUE and returns 1;
# else 0.
proc hir::resolve::LayoutAsValue {hirVar e node ctx} {
    upvar 1 $hirVar hir
    lassign [dict get $node qualified] ns name
    set qualified "${ns}::$name"
    if {[hir::layouts::lookup $qualified] eq ""} {
        return 0
    }
    if {[dict exists $hir modules $ns] && [dict exists $hir scopes [dict get $hir modules $ns] names $name]} {
        return 0
    }
    SetField hir $e name $qualified
    SetField hir $e binding ""
    SetField hir $e init yes
    hir::Diagnose hir LAYOUT-NOT-A-VALUE [LayoutNotAValueMessage $qualified] $e
    return 1
}

# The layout identity the operand syntax ARG of binary operation NATIVE
# names in code of namespace NS, or "" after diagnosing (as E, with HIR) why
# it names none.
proc hir::resolve::LayoutOperandId {hirVar e arg native ctx {operand "the layout operand"}} {
    upvar 1 $hirVar hir
    set ns [CtxNamespace $ctx]
    set kind [dict get $arg kind]
    set origin [dict get $arg origin]
    set name ""
    if {$kind eq "ref" && [dict exists $arg qualified]} {
        lassign [dict get $arg qualified] qns qname
        set name "${qns}::$qname"
    } elseif {$kind eq "ref" && !([dict exists $arg root] && [dict get $arg root])} {
        set name [dict get $arg name]
    }
    if {$name eq ""} {
        hir::DiagnoseAt hir LAYOUT-OPERAND \
            "$operand of $native must be the name of a layout (std::binary::parse(Pair, data)): the layout is static evidence, never a computed value" $e $origin
        return ""
    }
    set id [hir::layouts::lookup $name $ns]
    if {$id ne ""} {
        return $id
    }
    if {![dict exists $arg qualified] && [Lookup hir [dict get $ctx scope] $name] ne ""} {
        hir::DiagnoseAt hir LAYOUT-OPERAND \
            "$operand of $native must be the name of a layout, but \"$name\" is a value here: the layout is static evidence, never a computed value" $e $origin
        return ""
    }
    hir::DiagnoseAt hir UNKNOWN-LAYOUT \
        "unknown layout \"$name\" ($operand of $native): no \"layout [lindex [split [string map {:: \x01} $name] \x01] end]:\" declaration is visible" $e $origin
    return ""
}

# Resolves the layout operand syntax ARG of a call of binary operation
# NATIVE: the ExprId of the constant holding the layout's descriptor
# (hir::layouts::descriptor). Core IR spells the operand as that constant
# already (it is past the source boundary): it is resolved as written.
proc hir::resolve::LayoutOperand {hirVar arg native ctx} {
    upvar 1 $hirVar hir
    if {[dict get $arg kind] eq "const" && [lindex [dict get $arg origin] 0] eq "ir"} {
        return [Expr hir $arg $ctx]
    }
    set placeholder [Expr hir [hir::syntax::constNode [dict get $arg origin] str ""] $ctx]
    set id [LayoutOperandId hir $placeholder $arg $native $ctx]
    if {$id ne ""} {
        set descriptor [hir::layouts::descriptor $id]
        SetField hir $placeholder literal [list str $descriptor]
        SetField hir $placeholder value [core::value::str $descriptor]
    }
    return $placeholder
}

# Resolves the field designator syntax ARG of a call of the layout write
# NATIVE (NATIVE-LAYOUT-WRITES.md): the ExprId of the constant holding the
# field's designator (hir::layouts::FieldPath). The designator is written
# LAYOUT.FIELD or LAYOUT.FIELD.FIELD... -- a projection chain whose root is a
# layout name -- and is static evidence like a layout operand: the layout is
# never a value, the projections never run. Core IR spells it as the
# constant already. Diagnoses (the constant then holds nothing):
#
#   LAYOUT-OPERAND   not a LAYOUT.FIELD chain; or the path ends at a nested
#                    layout (a write names a scalar or pointer field; a
#                    read, std::binary::read, may name one) or at a union (a
#                    designator names one of its alternatives:
#                    LAYOUT-UNIONS.md)
#   UNKNOWN-LAYOUT   its root names no visible layout (LayoutOperandId)
#   UNKNOWN-FIELD    a name that is no field of its layout, or a name after
#                    a scalar or pointer field
proc hir::resolve::FieldPathOperand {hirVar arg native ctx} {
    upvar 1 $hirVar hir
    if {[dict get $arg kind] eq "const" && [lindex [dict get $arg origin] 0] eq "ir"} {
        return [Expr hir $arg $ctx]
    }
    set placeholder [Expr hir [hir::syntax::constNode [dict get $arg origin] str ""] $ctx]
    set names {}
    set origins {}
    set indices {}
    set root $arg
    while {[dict get $root kind] eq "project"} {
        set names [linsert $names 0 [dict get $root name]]
        set origins [linsert $origins 0 [dict get $root nameOrigin]]
        # A step's static element indices (FIXED-LAYOUT-ARRAYS.md:
        # L.pts[2].x), {VALUE ORIGIN} each.
        set indices [linsert $indices 0 [dict getdef $root indices {}]]
        set root [dict get $root receiver]
    }
    if {$names eq ""} {
        hir::DiagnoseAt hir LAYOUT-OPERAND \
            "the field operand of $native must name one field of a layout, written LAYOUT.FIELD (std::binary::write(data, Header.count, 7)): the field is static evidence, never a computed value" \
            $placeholder [dict get $arg origin]
        return $placeholder
    }
    set id [LayoutOperandId hir $placeholder $root $native $ctx \
        "the layout of the field operand (LAYOUT.FIELD)"]
    if {$id eq ""} {
        return $placeholder
    }
    # A read (std::binary::read, LAYOUT-UNIONS.md) may also name a nested
    # layout: it copies the whole record.
    set records [expr {[hir::layouts::RoleOf [hir::layouts::Role $native] op] eq "read"}]
    set result [hir::layouts::FieldPath $id $names [lmap step $indices {lmap index $step {lindex $index 0}}] $records]
    if {[lindex $result 0] eq "problem"} {
        lassign $result - kind message index element
        set origin [lindex $origins $index]
        if {$element ne ""} {
            # (Located at the element index the problem is about.)
            set origin [lindex [lindex $indices $index] $element 1]
        }
        hir::DiagnoseAt hir $kind $message $placeholder $origin
        return $placeholder
    }
    set constant [lindex $result 1]
    SetField hir $placeholder literal [list str $constant]
    SetField hir $placeholder value [core::value::str $constant]
    return $placeholder
}

# Resolves call E (syntax NODE) of the layout query NATIVE (ROLE its -layout
# role) to the constant it asks for: E becomes a `const` node.
proc hir::resolve::ResolveLayoutQuery {hirVar e node native role ctx} {
    upvar 1 $hirVar hir
    set value 0
    set args [dict get $node args]
    if {[llength $args] != 1} {
        hir::Diagnose hir ARITY \
            "$native takes exactly one argument, a layout name ([llength $args] given)" $e
    } else {
        set id [LayoutOperandId hir $e [lindex $args 0] $native $ctx]
        if {$id ne ""} {
            switch -- [hir::layouts::RoleOf $role query] {
                length    { set value [hir::layouts::size $id] }
                alignment { set value [hir::layouts::align $id] }
            }
        }
    }
    dict set hir exprs $e kind const
    SetField hir $e literal [list int $value]
    SetField hir $e value [core::ir::literalValue [list const int $value]]
}

# Resolves E, written `QUALIFIER::CASE` where QUALIFIER denotes the enum ID
# (hir::enums::lookup, from the code's own namespace: the visibility of any
# nominal type), to the case CASE of ID (ENUMS.md). Type-qualified case
# resolution is not a namespace lookup: QUALIFIER was resolved as a type,
# and CASE is looked up among ID's declared cases only -- never in a module,
# a lexical scope or another enum. A case value is a constant: E becomes the
# `const` node of the value {enum ID CASE}, whose type is exactly {enum ID}
# and which keeps both identities through every check and into each
# backend. An unknown case is UNKNOWN-ENUM-CASE, with the closest declared
# spellings suggested.
proc hir::resolve::ResolveEnumCase {hirVar e id case ctx} {
    upvar 1 $hirVar hir
    if {![hir::enums::hasCase $id $case]} {
        # Typed as never (an unbound name is too): nothing downstream
        # reasons about a value that does not exist.
        SetField hir $e name "${id}::$case"
        SetField hir $e binding ""
        SetField hir $e init yes
        hir::Diagnose hir UNKNOWN-ENUM-CASE [hir::enums::UnknownCaseMessage $id $case] $e
        return
    }
    dict set hir exprs $e kind const
    set literal [list enum [list $id $case]]
    SetField hir $e literal $literal
    SetField hir $e value [core::ir::literalValue [list const {*}$literal]]
}

# The hint an UNBOUND diagnostic for the bare NAME adds when NAME is the
# spelling of an enum type or of an enum's case (ENUMS.md): a case is never
# injected into its surroundings, so it is written through its enum's type
# name; and a type name is not a value.
proc hir::resolve::EnumHint {name ns} {
    set id [hir::enums::lookup $name $ns]
    if {$id ne ""} {
        return [format {: "%s" is an enum type, not a value; a case of it is written %s::CASE (its cases: %s)} \
            $name $name [join [hir::enums::cases $id] {, }]]
    }
    set owners {}
    foreach id [lsort [dict keys $::hir::enums::registry]] {
        if {[hir::enums::hasCase $id $name]} {
            lappend owners "${id}::$name"
        }
    }
    if {$owners ne ""} {
        return [format {: an enum case is never visible by its bare name; write it qualified by its enum's type, e.g. %s} \
            [join $owners { or }]]
    }
    return ""
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
        SetField hir $e init yes
        set message "unbound name \"$name\""
        if {!$root && [DeclaredLater hir $scope $name]} {
            append message ": \"$name\" is declared later; forward references are not allowed (a binding is visible only after it is established)"
        } elseif {!$root} {
            append message [EnumHint $name [CtxNamespace $ctx]]
        }
        if {!$root && [hir::layouts::lookup $name [CtxNamespace $ctx]] ne ""} {
            hir::Diagnose hir LAYOUT-NOT-A-VALUE [LayoutNotAValueMessage $name] $e
            return
        }
        hir::Diagnose hir UNBOUND $message $e
        return
    }
    set binding [dict get $hir bindings $b]
    # Every binding a reference can resolve to is already established
    # (sequential resolution), except an ambient one: whatever the host
    # environment holds when a closure eventually runs.
    SetField hir $e init [expr {[dict get $binding kind] eq "ambient" ? "deferred" : "yes"}]
    hir::flags::NoteRef hir $e

    if {[dict get $binding kind] ne "root"} {
        Capture hir $ctx [dict get $binding scope] $b
    }
}

# Establishes the binding of bind expression E (name NAME, in scope SCOPE):
# the point at which NAME becomes visible to every later reference of SCOPE
# (and of the scopes nested in it). Sets E's `binding` and `duplicate`.
#
#   * SCOPE already has NAME (a parameter, an element/induction binding, or
#     an earlier bind): DUPLICATE; E keeps denoting the existing binding.
#   * otherwise a new local binding, declaredBy E.
#   * an ambient scope (sequence mode) denotes the host environment's own
#     binding of NAME; no duplicate check is made there.
proc hir::resolve::Establish {hirVar e scope name origin} {
    upvar 1 $hirVar hir
    if {[dict get $hir scopes $scope kind] eq "ambient"} {
        SetField hir $e binding [Lookup hir $scope $name]
        SetField hir $e duplicate 0
    } elseif {[dict exists $hir scopes $scope names $name]} {
        SetField hir $e binding [dict get $hir scopes $scope names $name]
        SetField hir $e duplicate 1
        hir::Diagnose hir DUPLICATE \
            "duplicate binding \"$name\" in the same lexical scope" $e
    } else {
        set b [NewBinding hir $name local $scope $origin]
        dict set hir bindings $b declaredBy $e
        SetField hir $e binding $b
        SetField hir $e duplicate 0
    }
}

# 1 if NAME is bound somewhere in the own body of SCOPE or of an enclosing
# scope, i.e. by a declaration that has not been reached yet (the name is
# unresolved, so nothing established binds it). Diagnostic wording only: it
# never supplies a binding.
proc hir::resolve::DeclaredLater {hirVar scope name} {
    upvar 1 $hirVar hir
    for {set s $scope} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        if {$name in [LaterNames hir $s]} {
            return 1
        }
    }
    return 0
}

# Every enclosing block of CTX (innermost first) that does not itself
# contain BINDINGSCOPE captures binding B -- shared by ResolveRef's own
# lexical walk and ResolveQualifiedRef's direct resolution against a module
# section scope.
#
# A module-static binding (BINDINGSCOPE is a namespace's own module section
# scope, hir::isModuleScope) is the one exception: MODULE-STATIC-RETAINED-
# VALUES.md's primary invariant is exactly that such a binding never enters
# a function's lexical capture set, however deep the reference is nested --
# it has module/program lifetime and stable storage identity, not one
# particular enclosing activation's. Every enclosing block instead records it
# in its own `staticRefs` (hir::staticRefs), a disjoint list downstream
# passes (native lowering, the Tcl compiler, blockescape/specialize) consult
# to recognize a static storage reference, never inferred later by
# string/module-name lookup.
proc hir::resolve::Capture {hirVar ctx bindingScope b} {
    upvar 1 $hirVar hir
    if {[IsModuleScope hir $bindingScope]} {
        foreach entry [dict get $ctx blocks] {
            lassign $entry block bodyScope
            set staticRefs [dict get $hir exprs $block staticRefs]
            if {$b ni $staticRefs} {
                SetField hir $block staticRefs [concat $staticRefs [list $b]]
            }
        }
        return
    }
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
