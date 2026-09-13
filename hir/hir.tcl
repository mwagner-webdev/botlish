# hir.tcl -- semantic HIR: what a core IR program means, before execution.
#
#   source hir/hir.tcl                 ;# also loads core
#   set h [hir::build {{bind x {const 10}} {call {ref +} {ref x} {const 1}}}]
#   puts [hir::format $h]
#   hir::lower $h                      ;# back to core IR
#   hir::parse [hir::format $h]        ;# HIR text back to HIR (read.tcl)
#
# Pipeline:
#
#   syntax --hir::buildSyntax--> HIR     (frontends, e.g. surface/)
#   core IR --hir::build--> HIR --hir::lower--> core IR --> interp / compiler
#                             \------------------------------> compiler facts
#
# Core IR is the executable specification: small, and all an evaluator needs.
# HIR is the semantic representation: every name resolved to a binding
# identity, every expression typed, scopes, captures, refinements and known
# call targets explicit. Source-level concepts (namespaces, traits, foreign
# symbols, ...) belong here and lower to core IR; they never extend core IR
# unless they have runtime semantics core IR cannot express.
#
# The HIR has no runtime representation facts (Tcl variables, frames,
# boxing); those belong to backends.
#
# Data model
# ----------
# A HIR program is a dict of flat tables, so every entity is addressable by
# a stable id (for queries, tooling and later passes):
#
#   mode         program | sequence
#   roots        ExprIds of the top-level expressions, in order
#   top          ScopeId the top-level expressions run in
#   exprs        ExprId    -> expression node
#   scopes       ScopeId   -> scope
#   bindings     BindingId -> binding
#   symbols      SymbolId  -> symbol
#   types        TypeId    -> type form (interned; see types.tcl)
#   files        FileId    -> {id path}: source files origins refer to
#   diagnostics  list of {kind KIND message TEXT expr ExprId}
#
# IDs are strings with a kind prefix, allocated monotonically per program in
# a deterministic walk, so building the same IR twice gives the same ids:
#
#   e12 ExprId   s3 ScopeId   b7 BindingId   y2 SymbolId   t4 TypeId
#   f1  FileId   n1 NodeId    (reserved for source files / syntax nodes)
#
# Spelling is never identity: two bindings named x are different BindingIds,
# and a reference carries the spelling only for diagnostics.
#
# Every expression node has
#
#   id kind origin scope type reachable
#
# where ORIGIN says where the node came from ({ir PATH}: PATH indexes into
# the input IR, e.g. {ir {2 1 3}}; or what a frontend gave hir::buildSyntax,
# e.g. a source span {file f1 start 120 end 144 line 3 column 5 endLine 3 endColumn 29}
# with offsets into file f1 and 1-based line and column), SCOPE
# is the ScopeId the expression is evaluated in, TYPE is a TypeId and
# REACHABLE is 0 when no normal completion can reach the node. By kind:
#
#   const     literal (the words after `const`), value (runtime value)
#   ref       name, binding (BindingId, "" if unresolved),
#             init (yes | no | deferred: bound when evaluated? see resolve.tcl)
#   bind      name, binding, value (ExprId), duplicate (0|1)
#   block     bodyScope, params (BindingIds), body (ExprIds),
#             captures (BindingIds), resultType (TypeId)
#   call      callee, args (ExprIds), target ("" | {native SymbolId} |
#             {block ExprId}), known ("" | 1 | 0: result decided statically)
#   if        condition, thenScope, thenBody, elseScope, elseBody,
#             refinements (dict OUTCOME -> BindingId FACT pairs)
#   loop      bodyScope, body
#   return    value, target (the block ExprId it leaves, "" if none)
#   break     value ("" if none), target (the loop ExprId, "" if none)
#   continue  target
#   ok        value
#   error     value                 (core IR error-value)
#
# A scope:
#
#   id kind parent invocation owner origin names bindings closures refinements
#
#   kind         root      the root environment (natives, true, false, unit)
#                ambient   an open host environment (sequence mode)
#                program   the program scope
#                block     one invocation of a block (parameters and body)
#                branch    an if branch (outcome 1 or 0)
#                loop      one loop iteration
#   invocation   the block ExprId whose invocation the scope belongs to
#                ("" outside any block): code in the same invocation runs in
#                a statically known order
#   owner        the ExprId that creates the scope ("" for root/program)
#   names        NAME -> BindingId declared directly in the scope
#   bindings     BindingIds in declaration order
#   closures     block ExprIds created in the scope's region (including
#                nested branch and loop scopes, excluding nested blocks)
#   refinements  BindingId FACT pairs proven on entry (branch scopes)
#
# A binding:
#
#   id name kind scope declaredBy origin type symbol value
#
#   kind         root | ambient | param | local
#   declaredBy   ExprId of the first bind of a local ("" otherwise)
#   type         TypeId of the value it is bound to ("" if not inferred)
#   symbol       SymbolId of what a root binding denotes
#   value        runtime value of a root binding
#   spelling     only on bindings hygiene renamed (hygiene.tcl): the name
#                as written; NAME is then the name core IR uses
#
# A symbol is something a name can denote that did not come from a Botlish
# binding: {id kind provenance name}. Today only builtins exist
# ({kind native provenance {core native +}}, {kind constant provenance
# {core root true}}); namespaces, foreign modules and schemas add kinds.

if {[info commands ::core::evalProgram] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] core core.tcl]
}

namespace eval hir {
    variable home [file dirname [file normalize [info script]]]
    variable prefixes [dict create expr e scope s binding b symbol y type t file f node n]
}

# ---------------------------------------------------------------------------
# Construction

proc hir::Empty {mode} {
    return [dict create mode $mode roots {} top "" \
        exprs [dict create] scopes [dict create] bindings [dict create] \
        symbols [dict create] types [dict create] typeIds [dict create] files [dict create] \
        diagnostics {} counters [dict create]]
}

proc hir::NewId {hirVar kind} {
    upvar 1 $hirVar hir
    variable prefixes
    set n 1
    if {[dict exists $hir counters $kind]} {
        set n [expr {[dict get $hir counters $kind] + 1}]
    }
    dict set hir counters $kind $n
    return [dict get $prefixes $kind]$n
}

proc hir::Diagnose {hirVar kind message expr} {
    upvar 1 $hirVar hir
    dict lappend hir diagnostics [dict create kind $kind message $message expr $expr]
}

# Builds the HIR of the core IR program EXPRS (through hir::syntax::fromIR,
# so origins are {ir PATH}).
#
#   -mode program   (default) EXPRS are a checked program: a program scope
#                   over the root environment; all names resolve statically
#   -mode sequence  EXPRS run in an unknown existing environment: names not
#                   bound by nested scopes resolve to ambient bindings
#   -strict 1       (default) raise the first diagnostic as the semantic
#                   error the runtime would raise ({CORE SEMANTIC KIND})
#   -strict 0       keep diagnostics in the HIR; the error stays a run-time
#                   error of the lowered program (used by the compiler)
#
# Malformed IR always raises {CORE MALFORMED}.
proc hir::build {exprs args} {
    set options [Options hir::build {-mode program -strict 1} $args]
    set nodes {}
    set index 0
    foreach expr $exprs {
        lappend nodes [hir::syntax::fromIR $expr [list $index]]
        incr index
    }
    return [hir::buildSyntax $nodes {*}$options -origin {ir {}}]
}

# Builds the HIR of the syntax nodes NODES (syntax.tcl), with the options of
# hir::build and
#
#   -origin O       origin of the program scope
#   -files D        FileId -> path of the files origins refer to
#
# This is how frontends construct HIR: they state what was written and where;
# resolution, hygiene (hygiene.tcl), types and refinements happen here.
proc hir::buildSyntax {nodes args} {
    set options [Options hir::buildSyntax {-mode program -strict 1 -origin "" -files {}} $args]
    set mode [dict get $options -mode]
    if {$mode ni {program sequence}} {
        error "hir::build: -mode must be program or sequence"
    }
    set hir [hir::resolve::program $nodes $mode [dict get $options -origin]]
    hir::hygiene::apply hir
    dict for {f path} [dict get $options -files] {
        dict set hir files $f [dict create id $f path $path]
    }
    if {[dict get $options -strict]} {
        foreach diagnostic [dict get $hir diagnostics] {
            core::semanticError [dict get $diagnostic kind] [dict get $diagnostic message]
        }
    }
    hir::types::infer hir
    return $hir
}

proc hir::Options {command defaults given} {
    set options [dict create {*}$defaults]
    foreach {option value} $given {
        if {![dict exists $options $option]} {
            error "$command: unknown option \"$option\""
        }
        dict set options $option $value
    }
    return $options
}

# ---------------------------------------------------------------------------
# Queries

proc hir::mode {hir}        { return [dict get $hir mode] }
proc hir::roots {hir}       { return [dict get $hir roots] }
proc hir::top {hir}         { return [dict get $hir top] }
proc hir::diagnostics {hir} { return [dict get $hir diagnostics] }

proc hir::node {hir e} {
    return [dict get $hir exprs $e]
}

# Field KEY of expression E.
proc hir::get {hir e key} {
    return [dict get $hir exprs $e $key]
}

proc hir::kind {hir e} {
    return [dict get $hir exprs $e kind]
}

proc hir::scope {hir s}   { return [dict get $hir scopes $s] }
proc hir::binding {hir b} { return [dict get $hir bindings $b] }
proc hir::symbol {hir y}  { return [dict get $hir symbols $y] }
proc hir::sourceFile {hir f} { return [dict get $hir files $f] }

# The type form of TypeId T.
proc hir::type {hir t} {
    return [dict get $hir types $t]
}

# The semantic type of expression E (a type form).
proc hir::typeOf {hir e} {
    set t [dict get $hir exprs $e type]
    if {$t eq ""} {
        return any
    }
    return [dict get $hir types $t]
}

# The inferred type of binding B (a type form; any if not inferred).
proc hir::bindingType {hir b} {
    set t [dict get $hir bindings $b type]
    if {$t eq ""} {
        return any
    }
    return [dict get $hir types $t]
}

# Sub-expressions of E in evaluation order (branch and loop bodies included).
proc hir::children {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const - ref - continue { return {} }
        bind - return - ok - error { return [list [dict get $node value]] }
        break {
            return [expr {[dict get $node value] eq "" ? {} : [list [dict get $node value]]}]
        }
        block { return [dict get $node body] }
        call  { return [concat [list [dict get $node callee]] [dict get $node args]] }
        if {
            return [concat [list [dict get $node condition]] \
                [dict get $node thenBody] [dict get $node elseBody]]
        }
        loop  { return [dict get $node body] }
    }
}

# All expression ids in pre-order.
proc hir::walk {hir} {
    set result {}
    foreach e [dict get $hir roots] {
        WalkInto $hir $e result
    }
    return $result
}

proc hir::WalkInto {hir e resultVar} {
    upvar 1 $resultVar result
    lappend result $e
    foreach child [children $hir $e] {
        WalkInto $hir $child result
    }
}

# 1 if scope S is ANCESTOR or nested in it.
proc hir::scopeWithin {hir s ancestor} {
    for {} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        if {$s eq $ancestor} {
            return 1
        }
    }
    return 0
}

# The BindingId NAME denotes in scope S ("" if it resolves to nothing known:
# unbound, or an ambient/root name no expression has referred to yet).
proc hir::lookup {hir s name} {
    for {} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        if {[dict exists $hir scopes $s names $name]} {
            return [dict get $hir scopes $s names $name]
        }
    }
    return ""
}

# NAME -> BindingId for every binding visible (not shadowed) in scope S.
proc hir::visibleBindings {hir s} {
    set result [dict create]
    for {} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        dict for {name b} [dict get $hir scopes $s names] {
            if {![dict exists $result $name]} {
                dict set result $name $b
            }
        }
    }
    return $result
}

# BindingId -> facts proven for it in scope S (from branch refinements of S
# and its enclosing scopes), innermost facts first.
proc hir::refinementsAt {hir s} {
    set result [dict create]
    for {} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
        foreach {b fact} [dict get $hir scopes $s refinements] {
            if {![dict exists $result $b] || $fact ni [dict get $result $b]} {
                dict lappend result $b $fact
            }
        }
    }
    return $result
}

# Bindings captured by block expression E.
proc hir::captures {hir e} {
    return [dict get $hir exprs $e captures]
}

# The expression ids whose origin is ORIGIN.
proc hir::exprsAt {hir origin} {
    set result {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node origin] eq $origin} {
            lappend result $e
        }
    }
    return $result
}

apply {{dir} {
    foreach file {syntax resolve hygiene types refine lower format read aot} {
        uplevel #0 [list source [file join $dir $file.tcl]]
    }
}} $hir::home
