# hir.tcl -- semantic HIR: what a core IR program means, before execution.
#
#   source hir/hir.tcl                 ;# also loads core
#   set h [hir::build {{bind x {const 10}} {call {ref +} {ref x} {const 1}}}]
#   puts [hir::format $h]
#   hir::lower $h                      ;# back to core IR
#   hir::parse [hir::format $h]        ;# HIR text back to HIR (read.tcl)
#
# Pipeline (DIRECT-HIR-NATIVE-PATH.md):
#
#   source / syntax --hir::buildSyntax--> HIR     (frontends, e.g. surface/)
#   core IR text --hir::build--> HIR              (an input notation: examples,
#                                                  tests; same builder)
#
#   HIR --hir::lower--> core IR --> Tcl reference interpreter (core/) and the
#                                   Tcl compiler (compiler/)
#   HIR --native::lowered--> NIR --> native: JIT, object, standalone executable
#                                    (native/), later a bytecode interpreter
#
# HIR is the authoritative semantic program representation and the one place
# analysis facts live (types, contracts, semantic instances, ranges,
# refinements, call targets, captures, module identity). Core IR is the small
# executable/reference representation of the Tcl interpreter: a consumer of
# HIR, never a producer of it for the native path -- nothing lowers HIR to
# core IR and builds HIR back from it. NIR is the production executable
# representation.
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
#   modules      NAMESPACE -> ScopeId of that namespace's own module
#                section scope (surface/modules.tcl, hir/resolve.tcl's
#                ResolveQualifiedRef); absent for a program with no modules
#   diagnostics  list of {kind KIND message TEXT expr ExprId}
#   semantic     compiler-internal side table of opportunistic semantic
#                function instances (semantic.tcl, OPPORTUNISTIC-SEMANTIC-
#                INSTANCES.md): instances, keys, calls (a call ExprId, in the
#                program or inside an instance, -> the instance it uses),
#                census counters. Analysis facts, never part of a function's
#                contract or of hir::format's text; absent until hir::check
#                has typed the program.
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
#             init (yes | deferred: yes for every resolved reference -- its
#             binding was established before it; deferred only for an ambient
#             binding, whatever the host holds when a closure runs)
#   bind      name, binding, value (ExprId), duplicate (0|1)
#   block     bodyScope, params (BindingIds), body (ExprIds),
#             captures (BindingIds), staticRefs (BindingIds: module-static
#             references, disjoint from captures -- hir::isModuleBinding,
#             MODULE-STATIC-RETAINED-VALUES.md), resultType (TypeId)
#   call      callee, args (ExprIds), target ("" | {native SymbolId} |
#             {block ExprId}), known ("" | 1 | 0: result decided statically).
#             A call written `receiver.name(args)` with a function `name`
#             visible (METHOD-SUGAR.md) is an ordinary call `name(receiver,
#             args)`, receiver first in `args`; it carries `method` {name
#             nameOrigin} for the field/function ambiguity check and
#             diagnostics only (no analysis, lowering or backend reads it).
#             Without such a function the written callee is a `project`
#             marked `methodCallee 1` (diagnostic wording only)
#   if        condition, thenScope, thenBody, elseScope, elseBody,
#             refinements (dict OUTCOME -> BindingId FACT pairs)
#   loop      bodyScope, body
#   listloop  iterable, elementBinding, bodyScope, body
#   countloop start, end, direction, endKind, countBinding, bodyScope, body
#             -- the numeric collecting loop (R2A3-COUNTED-LOOPS-FINAL-SOURCE.
#             md, COLLECTING-LOOPS.md); start/end are ExprIds evaluated once
#             in the *enclosing* scope, countBinding is the per-iteration
#             immutable induction BindingId (in scope only in body, exactly
#             like listloop's own elementBinding). `start` is where iteration
#             begins and `end` the limit; direction (up | down) and endKind
#             (exclusive | inclusive) say how it advances and whether `end`
#             itself is visited -- explicit semantic fields, never an
#             `end + 1` / `start - 1` rewrite (hir::cardinality::Numeric
#             spells the exact element count of each combination).
#   lockloop  domains, bodyScope, body -- the lockstep collecting loop (`loop
#             x in xs and i from 0 to n:`): one loop whose iteration domains
#             all advance together. domains is a list of dicts in written
#             order, {kind list binding B iterable E} or {kind count binding
#             B start E end E direction D endKind K}, each domain's ExprIds
#             evaluated once in the *enclosing* scope and each binding a
#             fresh per-iteration immutable parameter of bodyScope. Its
#             obligation -- every domain has the same element count -- is
#             discharged statically by hir/lockstep.tcl.
#   return    value, target (the block ExprId it leaves, "" if none)
#   break     value ("" if none), target (the loop ExprId, "" if none)
#   continue  target
#   struct    named (0 | 1), structId (the named struct's declaration
#             identity, "" for an anonymous struct -- or a named construction
#             whose type did not resolve, a diagnostic), names (the field
#             names in WRITTEN order), nameOrigins, fieldOrigins, fields (the
#             field value ExprIds in written order: evaluation order),
#             layout (the field names in slot order: sorted for an
#             anonymous struct, declared order for a named one), slots (for
#             each written field its index in layout, -1 if it names no
#             layout field). STRUCTS.md; hir/structs.tcl.
#   project   receiver (ExprId), name, nameOrigin -- `receiver.name`
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
        diagnostics {} counters [dict create] sourceTypes {}]
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

# Diagnose, locating the diagnostic at ORIGIN (an expression origin, e.g. a
# struct field's own initializer) instead of at EXPR's: EXPR stays the
# anchor every check that groups or deduplicates diagnostics uses.
proc hir::DiagnoseAt {hirVar kind message expr origin} {
    upvar 1 $hirVar hir
    dict lappend hir diagnostics [dict create kind $kind message $message expr $expr origin $origin]
}

# Builds the HIR of the core IR program EXPRS (through hir::syntax::fromIR,
# so origins are {ir PATH}).
#
#   -mode program   (default) EXPRS are a checked program: a program scope
#                   over the root environment; all names resolve statically
#   -mode sequence  EXPRS run in an unknown existing environment: names not
#                   bound by nested scopes resolve to ambient bindings
#   -strict 1       (default) raise the first diagnostic as the semantic
#                   error the runtime would raise ({CORE SEMANTIC KIND}).
#                   A resolution diagnostic (an unbound name, which includes
#                   every reference to a binding established later --
#                   hir/resolve.tcl) is raised before type inference runs:
#                   a program that fails to resolve is never typed, analyzed
#                   or specialized.
#   -strict 0       keep diagnostics in the HIR; the error stays a run-time
#                   error of the lowered program (used by the compiler)
#
# Malformed IR always raises {CORE MALFORMED}.
#
#   -halt-on-resolution-errors 1   (buildSyntax only) return the HIR as soon as
#                   resolution has recorded a diagnostic, before typing: the
#                   caller raises. Default 0 (typing and every check run and
#                   keep collecting diagnostics).
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
#   -modules D      a list of {namespace NS nodes SECTION-NODES origin
#                   SECTION-ORIGIN} dicts (surface/modules.tcl's own
#                   sections: one per namespace NODES needs, transitively,
#                   dependencies first) -- see hir::resolve::program
#   -type-decls D   surface/lower.tcl's TypeDeclOf dicts (one per "type
#                   Child = Parent in Domain" declaration the caller found,
#                   across every module section plus its own top level, in
#                   dependency-load order) -- validated and registered by
#                   hir::sourcetypes::apply before resolution/type inference
#                   below, so a `-> Child` result-type annotation resolves
#                   exactly like a compiler-registered refined type. Their
#                   canonical metadata is kept as HIR's own `sourceTypes`
#                   field (hir/format.tcl, hir/read.tcl's round-trip). Empty
#                   by default: every caller but the surface frontend
#                   (surface/lower.tcl, surface/modules.tcl) and hir::read.
#
#   -struct-decls D surface/lower.tcl's StructDeclOf dicts (one per "struct
#                   Name:" declaration, across every module section plus the
#                   program's own top level): validated and registered, in the
#                   same declaration pass and the same type namespace as
#                   -type-decls, by hir::sourcetypes::apply (hir/structs.tcl;
#                   STRUCTS.md), so `Name { ... }` and a `Name` annotation
#                   resolve through it. A caller that passes this option, even
#                   empty, starts a fresh struct registry (the surface
#                   frontends always do); one that omits it (core IR builds,
#                   internal rebuilds) leaves the registry as it is. Kept as
#                   `struct` entries of HIR's `sourceTypes`.
#
#   -error-decls D  surface/lower.tcl's ErrorDeclOf dicts (one per "error
#                   NAME" declaration the caller found, across every module
#                   section plus its own top level) -- validated and
#                   registered by hir::errordecls::apply before resolution,
#                   so a function's `errors` clause, a `fail` statement and
#                   an `on` handler all resolve their error names against
#                   it (EXPLICIT-ERROR-COMPLETIONS.md). Kept as HIR's own
#                   `errorDecls` field (hir/format.tcl, hir/read.tcl's
#                   round-trip). Empty by default, like -type-decls.
#
# This is how frontends construct HIR: they state what was written and where;
# resolution, hygiene (hygiene.tcl), types and refinements happen here.
proc hir::buildSyntax {nodes args} {
    set options [Options hir::buildSyntax \
        {-mode program -strict 1 -origin "" -files {} -modules {} \
            -type-decls {} -error-decls {} -struct-decls {} -halt-on-resolution-errors 0} $args]
    set mode [dict get $options -mode]
    if {$mode ni {program sequence}} {
        error "hir::build: -mode must be program or sequence"
    }
    set errorDecls [hir::errordecls::apply [dict get $options -error-decls]]
    if {[dict exists [dict create {*}$args] -struct-decls] && [dict get $options -struct-decls] eq ""} {
        # A frontend that passes -struct-decls (even empty) compiles a program
        # of its own: no struct of an earlier compilation may stay visible.
        hir::structs::Reset
    }
    set sourceTypes [hir::sourcetypes::apply [dict get $options -type-decls] [dict get $options -struct-decls]]
    set hir [hir::resolve::program $nodes $mode [dict get $options -origin] [dict get $options -modules]]
    dict set hir sourceTypes $sourceTypes
    dict set hir errorDecls $errorDecls
    hir::hygiene::apply hir
    dict for {f path} [dict get $options -files] {
        dict set hir files $f [dict create id $f path $path]
    }
    if {[dict get $hir diagnostics] ne ""} {
        # Resolution failed: nothing below runs on a HIR whose names are not
        # all resolved. A caller that raises later (the source frontend adds
        # source locations to the message) asks to stop here with
        # -halt-on-resolution-errors and raises the diagnostics itself.
        if {[dict get $options -strict]} {
            core::semanticError [dict get [lindex [dict get $hir diagnostics] 0] kind] \
                [dict get [lindex [dict get $hir diagnostics] 0] message]
        }
        if {[dict get $options -halt-on-resolution-errors]} {
            return $hir
        }
    }
    hir::check hir
    if {[dict get $options -strict]} {
        foreach diagnostic [dict get $hir diagnostics] {
            core::semanticError [dict get $diagnostic kind] [dict get $diagnostic message]
        }
    }
    return $hir
}

# Types resolved HIR (inferring every block's intrinsic contract,
# hir/signatures.tcl) and runs every static check over it, collecting
# diagnostics. hir::buildSyntax's and native::prepareHir's shared tail.
#
# A call that violates a *trusted inferred* contract (VerifyCall), or an
# erasure of a callable whose contract is (hir::callables), is diagnosed
# like any other; the whole typing is then redone with those parameters'
# trusted contracts demoted to checked-only, keeping the original
# diagnostics. With -strict 1 the first diagnostic is raised either way;
# with -strict 0 (the core-IR compile path, whose diagnostics stay in the
# HIR and become AOT blockers) this is what keeps every backend from
# compiling a body that assumes a contract its own program breaks --
# exactly what such a program meant before its parameter had one.
#
# A *declared* parameter type the program's own call cannot prove is
# diagnosed too, but the HIR keeps the declared type (the analyses pin it);
# the violation is recorded as `violatedDeclared` (parameter BindingId -> the
# offending argument) so that a consumer that must not compile a body on the
# assumption of a broken contract can recover: native::prepareHir does.
proc hir::check {hirVar} {
    upvar 1 $hirVar hir
    hir::containers::index hir
    set pre $hir
    CheckOnce hir {}
    if {![dict exists $hir violatedContracts]} {
        return
    }
    set diagnostics [dict get $hir diagnostics]
    set demote [lsort -unique [dict keys [dict get $hir violatedContracts]]]
    set hir $pre
    CheckOnce hir $demote
    dict unset hir violatedContracts
    dict set hir diagnostics $diagnostics
    dict set hir demotedContracts $demote
}

proc hir::CheckOnce {hirVar demote} {
    upvar 1 $hirVar hir
    hir::signatures::infer hir $demote
    hir::range::verifyDeclaredResults hir
    hir::range::verifyDeclaredParams hir
    hir::callables::verify hir
    hir::lockstep::verify hir
    hir::structs::verify hir
    hir::semantic::verify hir
    hir::errorsets::verify hir
    hir::modulebinding::validate hir
}

# Resolves TARGETS (flat NATIVE-NAME NAMESPACE NAME triples,
# hir::buildSyntax's -module-native-targets) into HIR's own
# moduleNativeTargets field: NATIVE-NAME -> {BLOCK-EXPRID ARITY}, consulted
# by hir::types::BindingType. NAMESPACE::NAME must already be a module
# definition somewhere in this same HIR (hir::resolve has already run, so
# its `modules` table, hir/resolve.tcl, is populated): a caller-side bug (a
# namespace/name the loader never actually merged in) is a plain Tcl
# error, not a user-facing diagnostic.
proc hir::ResolveModuleNativeTargets {hirVar targets} {
    upvar 1 $hirVar hir
    if {$targets eq ""} {
        return
    }
    set resolved [dict create]
    set bridged [dict create]
    foreach {nativeName ns name} $targets {
        if {![dict exists $hir modules $ns]} {
            error "hir::buildSyntax: -module-native-targets: module \"$ns\" was not loaded into this program"
        }
        set bodyScope [dict get $hir modules $ns]
        # hir::hygiene::qualifyModules (run between hir::resolve::program
        # and here -- hir::buildSyntax) has already renamed every binding
        # this scope declares, and its own `names` entry, from NAME to
        # "${ns}::${name}"; look it up under that spelling.
        set qualified "${ns}::${name}"
        if {![dict exists $hir scopes $bodyScope names $qualified]} {
            error "hir::buildSyntax: -module-native-targets: module \"$ns\" has no definition \"$name\""
        }
        set b [dict get $hir scopes $bodyScope names $qualified]
        set bindExpr [dict get $hir bindings $b declaredBy]
        set value [dict get $hir exprs $bindExpr value]
        if {[dict get $hir exprs $value kind] ne "block"} {
            error "hir::buildSyntax: -module-native-targets: \"${ns}::${name}\" is not bound to a function"
        }
        dict set resolved $nativeName [list $value [llength [dict get $hir exprs $value params]]]
        set root [dict get $hir scopes [dict get $hir top] parent]
        dict set bridged [dict get $hir scopes $root names $nativeName] $b
    }
    dict set hir moduleNativeTargets $resolved
    BridgeProvenance hir $bridged
}

# Records, for every reference to a bridged native's root binding (BRIDGED:
# root BindingId -> the target module function's own BindingId; an alias
# spelling shares its canonical name's root binding, so both are covered),
# what that reference now denotes on this backend: the module function's
# Block value, which lives in the module function's own binding -- not the
# native's root binding, which every region reaches for free.
#
#   * `bridge` (on the ref) is that module BindingId: the one place native
#     lowering (native/lower.tcl's ModuleBridgeBinding) reads the bridged
#     function's value from.
#   * Every block enclosing the reference reaches that module binding
#     exactly as a module-qualified reference to it
#     (hir::resolve::ResolveQualifiedRef) already makes them reach it -- so a
#     caller reaches the bridged function the same way an ordinary
#     `NAMESPACE::NAME` call from the same place would. The bridged target is
#     always itself a module function (a module section's own binding, MODULE
#     -STATIC-RETAINED-VALUES.md's `staticRefs`), so this records module-
#     static provenance the same way hir::resolve::Capture does, never an
#     ordinary lexical capture -- the bridge's target no longer forces every
#     caller's enclosing function to become closure-valued merely to reach
#     it.
#
# Only the function's own binding is recorded, never anything *it*
# references: the function's module dependencies were resolved into its own
# body's own staticRefs/captures by ordinary resolution, where it is defined
# (its module section), and stay there. hir::resolve cannot do this itself:
# the bridge's targets are only resolved here, after resolution and hygiene
# (a bridged reference may also precede the target's own module section).
proc hir::BridgeProvenance {hirVar bridged} {
    upvar 1 $hirVar hir
    if {[dict size $bridged] == 0} {
        return
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "ref" || ![dict exists $node binding]
                || ![dict exists $bridged [dict get $node binding]]} {
            continue
        }
        set b [dict get $bridged [dict get $node binding]]
        dict set hir exprs $e bridge $b
        set bindingScope [dict get $hir bindings $b scope]
        set static [isModuleScope $hir $bindingScope]
        for {set s [dict get $node scope]} {$s ne ""} {set s [dict get $hir scopes $s parent]} {
            if {[dict get $hir scopes $s kind] ne "block"} {
                continue
            }
            if {!$static && [scopeWithin $hir $bindingScope $s]} {
                break
            }
            set block [dict get $hir scopes $s owner]
            set field [expr {$static ? "staticRefs" : "captures"}]
            set list [dict get $hir exprs $block $field]
            if {$b ni $list} {
                dict set hir exprs $block $field [concat $list [list $b]]
            }
        }
    }
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

# The source-defined type declarations this HIR's own build registered
# (hir::sourcetypes::apply's return value): a list of {name .. parent ..
# domain ..}, in dependency order. Empty for a program that declared none.
proc hir::sourceTypes {hir} {
    return [expr {[dict exists $hir sourceTypes] ? [dict get $hir sourceTypes] : {}}]
}

# The source-defined error declarations this HIR's own build registered
# (hir::errordecls::apply's return value): an ordered list of names. Empty
# for a program that declared none.
proc hir::errorDecls {hir} {
    return [expr {[dict exists $hir errorDecls] ? [dict get $hir errorDecls] : {}}]
}

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

# Public ordinary-function signatures exported by loaded module sections.
# The block result is the single authoritative semantic signature used by
# calls and specialization; PARAMS is each parameter's intrinsic contract
# (hir::signatures): its declared type (STRICT-TYPED-PARAMETERS.md) -- the
# pinned API boundary, never narrowed by the body -- else the contract its
# own body proves (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md: trusted, else
# checked), else "any"; SOURCES says which, per parameter (declared |
# inferred | none). An unannotated export's contract can therefore change
# when its implementation does -- the explicit annotation is how a stable
# public contract is pinned. This is descriptive
# metadata only: module sections are combined into one HIR before any
# checking runs (surface/modules.tcl), so a cross-module call is already an
# ordinary direct call by the time hir::range::verifyDeclaredParams sees it,
# needing no separate signature-lookup path of its own.
proc hir::moduleSignatures {hir} {
    set signatures [dict create]
    if {![dict exists $hir modules]} { return $signatures }
    dict for {namespace scope} [dict get $hir modules] {
        foreach b [dict get $hir scopes $scope bindings] {
            set declaration [dict get $hir bindings $b declaredBy]
            if {$declaration eq {}} { continue }
            set value [dict get $hir exprs $declaration value]
            if {[dict get $hir exprs $value kind] ne {block}} { continue }
            set sig [hir::signatures::of $hir $value]
            set params [lmap p [dict get $sig params] {hir::signatures::paramType $p}]
            set sources [lmap p [dict get $sig params] {dict get $p source}]
            set result [hir::type $hir [dict get $hir exprs $value resultType]]
            dict set signatures [dict get $hir bindings $b name] [dict create params $params \
                sources $sources result $result block $value]
        }
    }
    return $signatures
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
        listloop {
            return [concat [list [dict get $node iterable]] [dict get $node body]]
        }
        countloop {
            return [concat [list [dict get $node start] [dict get $node end]] [dict get $node body]]
        }
        lockloop {
            return [concat [hir::loopOperands $node] [dict get $node body]]
        }
        struct  { return [dict get $node fields] }
        project { return [list [dict get $node receiver]] }
        fail  { return {} }
        handle {
            set result [list [dict get $node call]]
            foreach body [dict get $node handlerBodies] {
                lappend result {*}$body
            }
            return $result
        }
    }
}

# The operand ExprIds of lockloop NODE's domains, in written order (a list
# domain's iterable; a count domain's start then end).
proc hir::loopOperands {node} {
    set result {}
    foreach domain [dict get $node domains] {
        if {[dict get $domain kind] eq "list"} {
            lappend result [dict get $domain iterable]
        } else {
            lappend result [dict get $domain start] [dict get $domain end]
        }
    }
    return $result
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

# Module-static bindings block expression E references (transitively, at any
# nesting depth), disjoint from hir::captures E -- see
# MODULE-STATIC-RETAINED-VALUES.md. Populated by hir::resolve::Capture
# exactly where an ordinary lexical capture would otherwise have been
# recorded, for a reference whose binding lives in a module section scope.
proc hir::staticRefs {hir e} {
    return [dict get $hir exprs $e staticRefs]
}

# hir::captures E, plus hir::staticRefs E: every binding block expression E
# reaches from outside its own body, whether by ordinary lexical capture or
# by a module-static reference. A binding's value is realized as a single
# addressable Value seen through the OTHER function's own storage (an
# ordinary closure environment, or a module-static slot) either way -- so
# hir::escape.tcl/hir::construction.tcl/hir::stringregion.tcl's own
# virtualization-eligibility analyses use this, never hir::captures alone,
# wherever the question is "does creating (or holding a reference to) this
# literal make some binding's identity observable outside its own defining
# invocation" (MODULE-STATIC-RETAINED-VALUES.md's escape/construction/
# region audit). A closure/environment-construction site (hir/blockescape
# .tcl, hir/aot.tcl, native/lower.tcl's CaptureList, compiler.tcl) asks a
# different question -- "what does this Block value's own runtime
# environment hold" -- and correctly keeps using hir::captures alone, since
# a module-static reference is exactly the kind of reference that must NOT
# end up in that environment.
proc hir::externalRefs {hir e} {
    return [concat [dict get $hir exprs $e captures] [dict get $hir exprs $e staticRefs]]
}

# 1 if BindingId B is a module-static binding: declared directly in some
# namespace's own module section scope (hir::resolve::ProgramSection), with
# module/program lifetime and no lexical-activation identity of its own.
# Never true of a root binding, a hir::top-level (non-module) binding, or an
# ordinary lexical local/param/ambient binding. See
# MODULE-STATIC-RETAINED-VALUES.md's storage-class discussion.
proc hir::isModuleBinding {hir b} {
    return [dict exists $hir moduleScopeIds [dict get $hir bindings $b scope]]
}

# 1 if ScopeId S is a module section's own scope (see hir::isModuleBinding).
proc hir::isModuleScope {hir s} {
    return [dict exists $hir moduleScopeIds $s]
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
    foreach file {syntax resolve refcheck hygiene sourcetypes structs errordecls types exactvalue signatures modulebinding refine lower format read aot specialize range rangerec callables containers semantic completions errorsets induction transport escape blockescape stringregion traversal construction cardinality lockstep} {
        uplevel #0 [list source [file join $dir $file.tcl]]
    }
}} $hir::home
