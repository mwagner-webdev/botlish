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
#   HIR --hir::lower--> core IR --> Tcl reference interpreter (core/)
#   HIR --core::compiler::compileHir--> Tcl procs (compiler/)
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
#   moduleDecls  NAMESPACE ("" for the entry program) -> {direct 0|1 origin
#                ORIGIN private PRIVATE declarations DECLARATIONS}: each
#                source unit's module declaration (`direct module`,
#                DIRECT-MODULES.md) and its private declarations and where
#                its type-level declarations are named (hir/privacy.tcl,
#                MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md); absent
#                past the source boundary (core IR text, HIR text)
#   direct       the module directness summary hir::direct::verify computed
#                from moduleDecls (hir/direct.tcl): declared, inferred and
#                final status per unit, and every direct edge with the context
#                that mediates it, if one does. Compile-time architecture: no
#                lowering or backend reads it
#   diagnostics  list of {kind KIND message TEXT expr ExprId}, optionally
#                with `origin` (the primary location, when not EXPR's) and
#                `related` (further locations the diagnostic names, as
#                origins in message order: a used value's move),
#                `subject` (the call ExprId whose own check -- against
#                the callee the call resolves to -- produced it: written by
#                hir::CheckingCall's checks, read only by the method-call
#                decision, hir/methods.tcl), `notes` (further locations a
#                reader may want, each {origin ORIGIN message TEXT}: where a
#                rejected method-style call's candidates are declared;
#                presentation only, never part of its identity or of a
#                static site's reified diagnostic) and `internal 1` on a
#                failure of the compiler itself
#   staticSites  the static intrinsics of a source program and their
#                decisions (hir/static.tcl, STATIC-COMPILE.md): site key ->
#                {key origin operation outcome accepted|rejected ?diagnostic
#                D?}; absent for a program without any. `staticRounds` is the
#                number of builds the decisions took. No analysis, lowering
#                or backend reads either: an accepted block is ordinary
#                syntax, a rejected one an ordinary `fail` (whose expression
#                carries `static {operation OP kind KIND}`, provenance read
#                by KNOWN-ERROR, SAME-FAILURE and diagnostics only)
#   warnings     compiler-internal side table of compiler warnings
#                (hir/warnings.tcl, WARNINGS-SAME-RETURN.md): a list of
#                {code message primary secondary data} records, attached by the
#                source frontend after every analysis ran and before any backend
#                does, only when warnings are on. Diagnostics over facts: no
#                analysis, lowering or backend reads it, hir::format does not
#                print it, and a program compiles to the same HIR without it.
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
#             MODULE-STATIC-RETAINED-VALUES.md), resultType (TypeId),
#             nomethod (1, only on a `nomethod fn`: its author's declaration
#             that it is never the callee of method syntax; printed by
#             hir::format as `nomethod` and read back by hir::parse; the
#             binding of the function carries `nomethod 1` too, which method
#             resolution reads -- WARNINGS-METHOD-ELIGIBLE.md),
#             exported (c, only on an `exported c fn`: a C export of a native
#             library, NATIVE-LIBRARY-MILESTONE-1.md; printed by hir::format
#             as `exported c`, read back by hir::parse; hir/exports.tcl
#             checks and lists the exports)
#   call      callee, args (ExprIds), target ("" | {native SymbolId} |
#             {block ExprId}), known ("" | 1 | 0: result decided statically).
#             A call written `receiver.name(args)` with a function `name`
#             visible (METHOD-SUGAR.md) is an ordinary call `name(receiver,
#             args)`, receiver first in `args`; it carries `method` {name
#             nameOrigin ns} (ns: the namespace of the code the call is
#             written in, "" for the entry program) for the field/function
#             ambiguity check and diagnostics only (no analysis, lowering or
#             backend reads it).
#             Without such a function the written callee is a `project`
#             marked `methodCallee 1` (diagnostic wording only). With
#             several, a call the method-call decision rejects (no single
#             valid candidate) has, in the program it returns, no candidate:
#             its written callee is a `project` marked `methodRejected 1`,
#             poison (hir/methods.tcl's Final; METHOD-RESOLUTION-DIAGNOSTICS-
#             MILESTONE-2.md), with no `method` field. A call the
#             source frontend built also carries `written` {form F ns NS}: how
#             it was spelled (F: function `f(x)`, method `x.f()`, list `[x]`,
#             operator `x + y`, which no later stage can recover) and the
#             namespace of the code it is in (NS: "" for the entry program),
#             recorded in every compilation mode for the METHOD-ELIGIBLE
#             warning (hir/warnings.tcl, WARNINGS-METHOD-ELIGIBLE.md) and read
#             by nothing else: no analysis, lowering, backend or hir::format
#             sees it. Calls from core IR carry no `written`.
#             A method-style call whose only visible functions of that name are
#             declared `nomethod` stays a call of the written field value and
#             is the resolution diagnostic NOMETHOD-CALL
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
#             layout field). STRUCTS.md; hir/structs.tcl. A source
#             construction of an `opaque struct` outside its owner is rejected
#             (OPAQUE-CONSTRUCTION) and its node carries `opaqueDenied 1`, read
#             only by the checks that must not describe its fields.
#   project   receiver (ExprId), name, nameOrigin, ns -- `receiver.name`; ns
#             is the namespace of the code the projection is written in ("" for
#             the entry program), stamped by hir/resolve.tcl for the one check
#             of representation authority over an opaque receiver (OPAQUE-
#             REPRESENTATION, hir/structs.tcl, OPAQUE-STRUCTS.md); a node
#             without it (core IR, HIR text) is past the source boundary and
#             trusted. No analysis, lowering or backend reads it.
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
    # Whole-program build counters (STATIC-COMPILE.md, "Decision economics"):
    # `builds` counts every hir::BuildOnce, `methodTrials` and `methodFinals`
    # the method-call decisions' trial and final builds among them (the
    # trials: the kind waves' builds and the builds of single deviations,
    # `methodDeviations` counting the latter), and `methodReused` the builds
    # a decision did not repeat because the one it needed had already been
    # made (hir/methods.tcl); `methodReports` the builds of a decided
    # program's reported form, its rejected calls resolved to no candidate
    # (hir::methods::Final; METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md).
    # `checks` counts hir::check's checks of resolved HIR (a build checks
    # once, again for each change of the coroutine analysis's feedback), and
    # `effectPlans` the plans of a check's trait-operation edges
    # (hir::coroutines::Implementations; TRAIT-IMPLEMENTATION-YIELD-
    # INFERENCE-MILESTONE-1.md). Measurement only: read as differences by
    # hir/static.tcl and the benchmarks, never by an analysis.
    variable buildStats [dict create builds 0 methodTrials 0 methodFinals 0 methodReused 0 \
        methodDeviations 0 methodReports 0 checks 0 effectPlans 0]
    # 0 makes the method-call decision build every build again even when a
    # build of the same configuration was already made (measurement and
    # audits only).
    variable methodBuildReuse 1
    # 1 makes the method-call decision build again every build it reuses and
    # fail unless it reads the same of both (the audit of the reuse: tests
    # and audit tools only). BOTLISH_METHOD_BUILD_AUDIT=1 sets it for a whole
    # process, so the existing suites and fuzzers run under it.
    variable methodBuildAudit 0
    if {[info exists ::env(BOTLISH_METHOD_BUILD_AUDIT)] && $::env(BOTLISH_METHOD_BUILD_AUDIT) ni {"" 0}} {
        set methodBuildAudit 1
    }
    # 0 makes the method-call decision judge every candidate by its own build
    # (the reference rule, hir/methods.tcl), never ruling one out by the
    # receiver's kind without building it: measurement, the reference of the
    # audit below and the tests. The kind proofs only save builds -- what
    # they rule out its build would rule out too, which the audit checks --
    # so neither this switch nor the audit is a front-end input: they are in
    # no cache key. BOTLISH_METHOD_KIND_PROOFS=0 sets it for a whole process.
    variable methodKindProofs 1
    if {[info exists ::env(BOTLISH_METHOD_KIND_PROOFS)] && $::env(BOTLISH_METHOD_KIND_PROOFS) in {0 off no}} {
        set methodKindProofs 0
    }
    # 1 makes the method-call decision decide every program a second time by
    # the reference rule (no kind proofs) and fail unless both decide alike
    # and give the same HIR (tests and audit tools only; the
    # decision's own result is the one returned). BOTLISH_METHOD_REFERENCE_AUDIT=1
    # sets it for a whole process, so the existing suites and fuzzers run
    # under it.
    variable methodReferenceAudit 0
    # The decisions the audit compared with the reference's.
    variable methodReferenceAudits 0
    if {[info exists ::env(BOTLISH_METHOD_REFERENCE_AUDIT)] && $::env(BOTLISH_METHOD_REFERENCE_AUDIT) ni {"" 0}} {
        set methodReferenceAudit 1
    }
    # The call whose own check runs now (hir::CheckingCall), "" outside one:
    # what every diagnostic reported meanwhile records as its `subject`.
    variable checkingCall ""
    # 0 makes hir::check redo the check after a demotion from the start,
    # sharing nothing with the check before it (measurement and audits only).
    variable recheckReuse 1
    # 1 makes hir::check redo that check from the start as well and fail
    # unless both give the same HIR; recheckAudits counts the checks it
    # compared (audit/demotion-recheck). Kept when this file is sourced again,
    # so an audit can set it and then run a tool that loads the compiler.
    if {![info exists ::hir::recheckAudit]} {
        variable recheckAudit 0
        variable recheckAudits 0
    }
    # The Tcl recursion limit the front end runs under at least (hir::Deep):
    # what most test files and audit tools already set for themselves.
    variable recursionFloor 100000
}

# The build counters (hir::buildStats) as they are now.
proc hir::BuildStats {} {
    variable buildStats
    return $buildStats
}

# Evaluates SCRIPT in the caller's scope with the interpreter's recursion
# limit at least recursionFloor, restoring the caller's limit afterwards
# (COMPILER-BOTTLENECKS.md, 4.4). The front end's walks recurse as deep as
# the program nests -- syntax (a left-deep `and` chain), and the completion
# analysis also a static call chain, one nested callee analysis per call up
# to hir::completions::maxDepth -- which Tcl's default limit of 1000 nested
# evaluations cut short at a 120-function chain. Tcl 9's non-recursive
# engine does not grow the C stack for a proc call, so the deeper limit costs
# nothing until it is used. Scoped, not process-wide: the program a backend
# then runs keeps the caller's limit (a compiled self tail call needs no Tcl
# depth, tests/compiler-opt.test's opt-tail-2). An embedder's higher limit is
# kept as it is.
proc hir::Deep {script} {
    variable recursionFloor
    set limit [interp recursionlimit {}]
    set raise [expr {$limit < $recursionFloor}]
    if {$raise} {
        interp recursionlimit {} $recursionFloor
    }
    set code [catch {uplevel 1 $script} result options]
    if {$raise} {
        interp recursionlimit {} $limit
    }
    dict incr options -level
    return -options $options $result
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

proc hir::Diagnose {hirVar kind message expr {related {}}} {
    upvar 1 $hirVar hir
    variable checkingCall
    set diagnostic [dict create kind $kind message $message expr $expr]
    if {$related ne {}} {
        # The diagnostic's related locations (origins, in the order its
        # message names them): the further places it is about, beside its
        # primary location -- e.g. where a used value was moved. Data, so a
        # consumer never parses them out of the message (STATIC-COMPILE.md).
        dict set diagnostic related $related
    }
    if {$checkingCall ne ""} {
        dict set diagnostic subject $checkingCall
    }
    dict lappend hir diagnostics $diagnostic
}

# Diagnose, locating the diagnostic at ORIGIN (an expression origin, e.g. a
# struct field's own initializer) instead of at EXPR's: EXPR stays the
# anchor every check that groups or deduplicates diagnostics uses.
proc hir::DiagnoseAt {hirVar kind message expr origin} {
    upvar 1 $hirVar hir
    variable checkingCall
    set diagnostic [dict create kind $kind message $message expr $expr origin $origin]
    if {$checkingCall ne ""} {
        dict set diagnostic subject $checkingCall
    }
    dict lappend hir diagnostics $diagnostic
}

# Evaluates SCRIPT in the caller's scope as the check of call E against the
# callee E resolves to: its arguments' admission by the callee's parameters
# (types, ranges, traits, contract boundaries, places, ownership roles), its
# flags and imprints, the validity of the callee's semantic instance for it.
# Every diagnostic SCRIPT reports records `subject E`: E's own problem with
# that callee, wherever the diagnostic is located (a rejected argument is
# reported at the argument, METHOD-SUGAR.md). The method-call decision reads
# exactly those as a candidate's problems (hir::methods::Problems): a
# diagnostic another construct's check reports at E's node -- the check of
# an outer call that rejects E's result as its argument -- is never E's.
# Semantic data with one invariant: only a check of E itself names E.
proc hir::CheckingCall {e script} {
    variable checkingCall
    set saved $checkingCall
    set checkingCall $e
    set code [catch {uplevel 1 $script} result options]
    set checkingCall $saved
    dict incr options -level
    return -options $options $result
}

# Builds the HIR of the core IR program EXPRS (through hir::syntax::fromIR,
# so origins are {ir PATH}).
#
#   -mode program   (default) EXPRS are a checked program: a program scope
#                   over the root environment; all names resolve statically
#   -mode sequence  EXPRS run in an unknown existing environment: names not
#                   bound by nested scopes resolve to ambient bindings
#   -strict 1       (default) raise the diagnostics as the semantic error
#                   the runtime would raise ({CORE SEMANTIC KIND} of the
#                   first, every one reported: hir/recovery.tcl).
#                   A resolution diagnostic (an unbound name, which includes
#                   every reference to a binding established later --
#                   hir/resolve.tcl) is raised before type inference runs:
#                   a program that fails to resolve is never typed, analyzed
#                   or specialized. (The source frontend builds with
#                   -strict 0 and goes on to check such a program,
#                   surface/modules.tcl's BuildProgram.)
#   -strict 0       keep diagnostics in the HIR; the error stays a run-time
#                   error of the program (the compiler's core IR text entry
#                   points, the test harness)
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
#   -imports T      the import environments of the compilation (hir/imports.tcl,
#                   IMPORTS.md): NAMESPACE -> {namespaces {NS ...} types {SHORT
#                   CANONICAL ...}}, one per file, keyed by the namespace the
#                   file is the module of ("" for the entry program). Given
#                   (even empty), it replaces the compilation's table; omitted,
#                   the table is left as it is (core IR text builds, trial
#                   builds). Consulted by resolution only: no import is ever
#                   an expression.
#
#   -struct-decls D surface/lower.tcl's StructDeclOf dicts (one per "struct
#                   Name:" declaration, across every module section plus the
#                   program's own top level): validated and registered, in the
#                   same declaration pass and the same type namespace as
#                   -type-decls, by hir::sourcetypes::apply (hir/structs.tcl;
#                   STRUCTS.md), so `Name { ... }` and a `Name` annotation
#                   resolve through it. A caller that passes this option, even
#                   empty, starts a fresh struct registry (the surface
#                   frontends always do); one that omits it (core IR text
#                   builds, trial builds) leaves the registry as it is. Kept as
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
#   -foreign-decls D, -link-decls L   a source program's extern c fn and
#                   extern c library declarations (surface/lower.tcl's
#                   ExternDeclOf and LinkDeclOf dicts; hir/foreign.tcl,
#                   C-FFI.md): registered as compilation-local natives and
#                   the HIR's link plan (`foreign`, `links`)
#   -module-decls D the module declarations of a source program
#                   (DIRECT-MODULES.md): NAMESPACE ("" for the entry program)
#                   -> {direct 0|1 origin ORIGIN private P declarations D},
#                   one per unit of the compilation, ORIGIN the `direct
#                   module` marker's, P and D its private declarations and
#                   type-level names (hir/privacy.tcl). Given (even empty),
#                   the program is a source program whose modules
#                   hir::direct::verify and hir::privacy::verify judge, and
#                   it is kept as HIR's `moduleDecls` (from resolution on:
#                   method candidates read its privacy); omitted (core IR
#                   text, HIR text), the program is past the source
#                   boundary: no module is judged.
#
# This is how frontends construct HIR: they state what was written and where;
# resolution, hygiene (hygiene.tcl), types and refinements happen here.
proc hir::buildSyntax {nodes args} {
    # Every pass of the front end runs under its recursion floor (Deep).
    return [Deep {BuildSyntax $nodes {*}$args}]
}

proc hir::BuildSyntax {nodes args} {
    set options [Options hir::buildSyntax \
        {-mode program -strict 1 -origin "" -files {} -modules {} \
            -type-decls {} -error-decls {} -struct-decls {} -trait-decls {} -imports {} -module-decls {} \
            -foreign-decls {} -link-decls {} -halt-on-resolution-errors 0 -syntax-recovery {}} $args]
    set mode [dict get $options -mode]
    if {$mode ni {program sequence}} {
        error "hir::build: -mode must be program or sequence"
    }
    set given [dict create {*}$args]
    # The analysis build raises nothing itself (a diagnostic is a diagnostic
    # of the HIR, whatever the caller's -strict): a strict caller's first
    # diagnostic is raised below, once the method-style calls with several
    # candidate functions have been decided (DecideMethodCalls) -- which needs
    # the typed HIR of trial builds, so no build may raise before it.
    set halt [expr {[dict get $options -strict] || [dict get $options -halt-on-resolution-errors]}]
    if {[hir::static::present $nodes [dict get $options -modules]]} {
        # Static intrinsics (STATIC-COMPILE.md): each site is decided by
        # ordinary builds of the program before the program itself is
        # built; the result is the build of the decided syntax.
        set hir [hir::static::decide $nodes $options $given $halt]
    } else {
        set hir [BuildFull $nodes $options $given $halt checked]
    }
    if {[dict get $options -strict] && [dict get $hir diagnostics] ne ""} {
        # Resolution failed, or a static check did: every diagnostic the
        # compilation reports (hir/recovery.tcl), the first one's kind.
        hir::recovery::raise $hir [hir::recovery::reported $hir] 0
    }
    return $hir
}

# The whole build of the syntax NODES (hir::buildSyntax's OPTIONS and GIVEN,
# with no static node left: hir/static.tcl expands them first), stopping
# after resolution when HALT and a name is unresolved. Sets CHECKEDVAR to
# whether the static checks ran. Raises nothing for a diagnostic.
#
# SEEDS (key -> candidate display) are method-style calls already decided:
# hir/static.tcl passes the decisions of its previous round that no change
# since can have touched (STATIC-COMPILE.md, "Method-call decisions across
# rounds"). They are the first build's choices and DecideMethodCalls takes
# them as decided; without seeds the build is the one it always was.
proc hir::BuildFull {nodes options given halt checkedVar {seeds {}}} {
    upvar 1 $checkedVar checked
    if {[dict exists $given -trait-decls]} {
        # The intrinsic traits the program may use (HASHABLE-AND-KEYED-HASH.md):
        # declared beside its own, so it is a trait program like any other.
        set intrinsic [hir::traits::IntrinsicDecls $nodes $options]
        if {$intrinsic ne {}} {
            dict set options -trait-decls [concat [dict get $options -trait-decls] $intrinsic]
            dict set given -trait-decls [dict get $options -trait-decls]
        }
    }
    set traits [expr {[dict get $options -trait-decls] ne {}}]
    # A source program that may construct coroutines may give a generic
    # function an affine argument, which the monomorphization below
    # specializes (AFFINE-VALUES.md).
    set affine [expr {[dict exists $given -trait-decls]
        && [hir::traits::UsesCoroutines $nodes [dict get $options -modules]]}]
    if {$traits || $affine} {
        # A trait program (TRAITS.md): every syntax node gets an identity
        # the monomorphization below can name it by.
        lassign [hir::traits::Stamp $nodes [dict get $options -modules]] nodes modules syntax
        dict set options -modules $modules
        dict set given -modules $modules
    }
    set hir [BuildOnce $nodes $options $given $seeds $halt checked]
    if {$checked && [dict exists $hir methodCalls]} {
        set hir [DecideMethodCalls $nodes $options $given $hir $seeds]
    }
    if {($traits || ($affine && [hir::traits::NeedsAffinePlan $hir])) && $checked && [dict get $hir diagnostics] eq ""} {
        # Checked as written, with trait views; now the program every
        # backend compiles: the same syntax built again, monomorphized.
        set hir [hir::traits::monomorphize $nodes $options $given $hir $syntax]
        if {[dict exists $hir traitSource direct]} {
            # Module directness is the program's as written (hir/direct.tcl):
            # the checked build's verdict, not re-derived from the clones.
            dict set hir direct [dict get $hir traitSource direct]
        }
    }
    if {$checked} {
        # Calls of coroutine handles typed as resumes, written out as the
        # resume operation (AFFINE-VALUES.md): what every backend compiles.
        hir::coroutines::ElaborateResumes hir
        # MutableVector places (MUTABLE-VECTOR.md): the logical copies a
        # vector-bearing value makes leaving or entering a place, the
        # snapshot an unrestricted vector's loop iterates, and the drop
        # descriptors affine clear/swap carry. Never for HIR built from core
        # IR (hir::build): core IR is what an elaboration lowers to -- it
        # already says all of this, and it has lost the static types (an
        # affine element type, a declared vector type) the elaboration reads.
        if {[lindex [dict get $options -origin] 0] ne "ir"} {
            # Loops over the standard library's collection structs
            # (hir/iteration.tcl), written out as counted loops over their
            # loop protocol -- before the copies, which then give the loop
            # its snapshot.
            hir::iteration::Elaborate hir
            hir::mutvec::Elaborate hir
        }
        # The layout a std::binary::emit reads from its value's static type
        # (BINARY-LAYOUT.md), written out as the descriptor constant every
        # backend reads instead (hir::layouts::Elaborate).
        hir::layouts::Elaborate hir
        # The precision every observation of a DecimalRounded value reads,
        # from its operands' static types, written into its call
        # (DECIMAL-ROUNDED-MILESTONE-1.md, hir::decimal::Elaborate).
        hir::decimal::Elaborate hir
        # The length every std::list::with_length[T] call checks, from its
        # imprint, written into the call (LIST-CARDINALITY-REFINEMENTS.md,
        # hir::listlength::Elaborate).
        hir::listlength::Elaborate hir
    }
    return $hir
}

# One build of the syntax NODES to HIR: the options of hir::buildSyntax
# (OPTIONS, with GIVEN the options as the caller wrote them), the method-call
# choices CHOICES (key -> candidate display, see hir::resolve::MethodChoice),
# stopping after resolution when HALT and a name is unresolved ("nothing
# below runs on a HIR whose names are not all resolved"). Sets CHECKEDVAR to
# whether the static checks ran. Raises nothing for a diagnostic.
proc hir::BuildOnce {nodes options given choices halt checkedVar} {
    upvar 1 $checkedVar checked
    variable buildStats
    dict incr buildStats builds
    set checked 0
    # The build rewrites the registries below; the state they hold is this
    # build's once it stamps its HIR (hir/declarations.tcl).
    hir::declarations::invalidate
    if {[dict exists $given -imports]} {
        hir::imports::apply [dict get $options -imports]
    }
    if {[dict exists $given -error-decls]} {
        # A frontend that passes -error-decls (even empty) compiles a program
        # of its own: no error an earlier compilation declared stays
        # resolvable (COMPILER-BOTTLENECKS.md, 4.1). Core IR text (hir::build)
        # passes none and keeps them: its `fail`/`handle` nodes may name the
        # errors of the program it was lowered from.
        hir::errordecls::Reset
    }
    set errorDecls [hir::errordecls::apply [dict get $options -error-decls]]
    if {[dict exists $given -struct-decls] && [dict get $options -struct-decls] eq ""} {
        # A frontend that passes -struct-decls (even empty) compiles a program
        # of its own: no struct of an earlier compilation may stay visible.
        hir::structs::Reset
    }
    if {[dict exists $given -type-decls]} {
        # Likewise for enums (ENUMS.md), which ride in -type-decls, and for
        # every other source type: a program declaring none must not see an
        # earlier compilation's, though hir::sourcetypes::apply, given no
        # declarations, leaves the registry as it is for core IR text
        # (hir::build passes no -type-decls). It registers this program's
        # own, if any.
        hir::enums::Reset
        hir::sourcetypes::Reset
    }
    set traitDecls ""
    if {[dict exists $given -trait-decls]} {
        # Likewise for traits (TRAITS.md): their names first, so every other
        # type declaration that mentions one recognizes (and rejects) it;
        # their requirements once every type they may name is registered.
        hir::traits::declare [dict get $options -trait-decls]
    }
    set sourceTypes [hir::sourcetypes::apply [dict get $options -type-decls] [dict get $options -struct-decls]]
    if {[dict exists $given -trait-decls]} {
        set traitDecls [hir::traits::resolve $sourceTypes]
    }
    if {[dict get $options -error-decls] ne {}} {
        # The payload field types (ERROR-PAYLOADS.md) name the program's
        # own types: resolved once those are registered.
        hir::errordecls::resolvePayloads
    }
    # A source program's extern c fn declarations and link plan (C-FFI.md):
    # their C types name the program's own (opaque structs, std::ffi::c's
    # scalars), so they are registered once those are. A frontend that
    # passes -error-decls (even empty) compiles a program of its own: no
    # extern of an earlier compilation stays declared. Core IR text keeps
    # them, as it keeps the errors.
    set externs [dict exists $given -error-decls]
    if {$externs} {
        hir::foreign::apply [dict get $options -foreign-decls] [dict get $options -link-decls]
    }
    set hir [hir::resolve::program $nodes [dict get $options -mode] [dict get $options -origin] \
        [dict get $options -modules] $choices $externs [dict get $options -module-decls]]
    if {$externs} {
        lassign [hir::foreign::tables] foreign links
        if {[dict size $foreign] || $links ne {}} {
            dict set hir foreign $foreign
            dict set hir links $links
        }
    }
    if {[dict exists $given -module-decls]} {
        dict set hir moduleDecls [dict get $options -module-decls]
    }
    dict set hir sourceTypes $sourceTypes
    dict set hir errorDecls $errorDecls
    set payloads [hir::errordecls::entries]
    if {[dict size $payloads]} {
        # The payload descriptors of the payload-bearing errors
        # (ERROR-PAYLOADS.md); absent when the program declares none.
        dict set hir errorPayloads $payloads
    }
    if {$traitDecls ne ""} {
        dict set hir traits $traitDecls
    }
    if {$traitDecls ne "" || [dict exists $given -trait-decls]} {
        # The implementation candidates conformance reads: every unit's own
        # top-level definitions, by source name, before hygiene renames them
        # -- also the location-independent identities a specialization of a
        # generic function for an affine argument resolves its references by
        # (hir::traits::IdentOf, AFFINE-VALUES.md).
        hir::traits::index $hir
        # A declaration's applications of parameterized structs
        # (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md) are valid once every trait
        # a slot names can be decided: a struct's or a payload's field.
        hir::structs::VerifyDeclarations
    }
    hir::hygiene::apply hir
    dict for {f path} [dict get $options -files] {
        dict set hir files $f [dict create id $f path $path]
    }
    if {[dict get $hir diagnostics] ne "" && $halt} {
        # Resolution failed: nothing below runs on a HIR whose names are not
        # all resolved. A caller that raises later (the source frontend adds
        # source locations to the message) asks to stop here with
        # -halt-on-resolution-errors and raises the diagnostics itself.
        hir::declarations::stamp hir
        return $hir
    }
    if {[dict get $options -syntax-recovery] ne {}} {
        # A program with syntax errors, its malformed source holes
        # (SYNTAX-RECOVERY-MILESTONE-1.md): what resolution found that may
        # depend on them is not known (hir::recovery::Recovered).
        dict set hir syntaxRecovery [dict get $options -syntax-recovery]
        hir::recovery::Recovered hir
    }
    if {[dict get $hir diagnostics] ne ""} {
        # The program is checked although it did not resolve: what the
        # checks find in code that depends on a resolution failure is not
        # reported (hir/recovery.tcl). Recovery bookkeeping of a rejected
        # program only, never read by an analysis.
        dict set hir resolutionDiagnostics [dict get $hir diagnostics]
    }
    hir::declarations::stamp hir
    hir::check hir
    set checked 1
    return $hir
}

# The decision of the method-style calls of HIR (hir/methods.tcl,
# METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md): the candidate whose ordinary
# call is the only valid one, relative to the decision itself, every
# rejection a diagnostic of the returned program. Under
# hir::methodReferenceAudit the program is decided a second time by the
# reference rule (every candidate judged by its own build, no kind proof),
# and the two must agree. (The reuse of builds has its own audit,
# hir::methodBuildAudit.)
proc hir::DecideMethodCalls {nodes options given hir {seeds {}}} {
    variable methodReferenceAudit
    variable methodKindProofs
    set decided [hir::methods::Decide $nodes $options $given $hir $seeds]
    if {!$methodReferenceAudit || !$methodKindProofs} {
        return $decided
    }
    set methodKindProofs 0
    hir::activate $hir
    try {
        set reference [hir::methods::Decide $nodes $options $given $hir $seeds]
    } finally {
        set methodKindProofs 1
    }
    ReferenceAudit $decided $reference $seeds
    return $reference
}

# Fails unless DECIDED, the program the decision gave, is REFERENCE, the one
# the reference rule gave: the same decisions and the same HIR.
proc hir::ReferenceAudit {decided reference seeds} {
    variable methodReferenceAudits
    foreach key {methodChoices methodDecided} {
        set a [lsort -stride 2 [dict get $decided $key]]
        set b [lsort -stride 2 [dict get $reference $key]]
        if {$a ne $b} {
            error "hir::methodReferenceAudit: the decision's $key differs from the reference rule's\ndecision:  $a\nreference: $b\nseeds: $seeds"
        }
    }
    if {$decided ne $reference} {
        set where {}
        foreach key [lsort -unique [concat [dict keys $decided] [dict keys $reference]]] {
            if {![dict exists $decided $key] || ![dict exists $reference $key]} {
                lappend where "$key (present in one only)"
            } elseif {[dict get $decided $key] ne [dict get $reference $key]} {
                lappend where $key
            }
        }
        error "hir::methodReferenceAudit: the decision's program differs from the reference rule's in: [join $where {, }]"
    }
    incr methodReferenceAudits
}

# Types resolved HIR (inferring every block's intrinsic contract,
# hir/signatures.tcl) and runs every static check over it, collecting
# diagnostics. hir::buildSyntax's and native::prepareHir's shared tail.
#
# A call that violates a *trusted inferred* contract (VerifyCall), or an
# erasure of a callable whose contract is (hir::callables), is diagnosed
# like any other; the whole typing is then redone with those parameters'
# trusted contracts demoted to checked-only, keeping the original
# diagnostics. With -strict 1 the diagnostics are raised either way;
# with -strict 0 (a lenient front-end or core IR text build, whose
# diagnostics stay in the HIR and become AOT blockers) this is what keeps
# every backend from
# compiling a body that assumes a contract its own program breaks --
# exactly what such a program meant before its parameter had one.
#
# A *declared* parameter type the program's own call cannot prove is
# diagnosed too, but the HIR keeps the declared type (the analyses pin it);
# the violation is recorded as `violatedDeclared` (parameter BindingId -> the
# offending argument) so that a consumer that must not compile a body on the
# assumption of a broken contract can recover: native::prepareHir does.
#
# The check after the demotion computes again only what the demotion can
# change (COMPILER-BOTTLENECKS.md, 3.9). The coroutine protocols are a
# function of the HIR alone, so both checks start from one inference of
# them. The signature fixpoint's rounds are a function of the HIR and their
# seeds alone, and the demotion only filters the seeds a round hands the
# next (hir::signatures::infer), so the second check reuses every round of
# the first whose seeds it reaches again -- always the first round, which
# has none. Everything from the first seeded typing on reads the demoted
# contracts and runs again. recheckReuse 0 redoes the second check from the
# start instead; recheckAudit 1 does that as well and fails unless both give
# the same HIR.
#
# The coroutine protocols (hir/coroutines.tcl) type every yield, so they are
# inferred before the types are -- and so before the typing decides which
# method-style calls are trait operations, and which implementation each
# trait operation calls. An operation's written callee is a visible function
# of the operation's name and never the operation's implementation
# (CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md); its implementation
# is the program's selected context's or its witness's, whose yields are the
# call's (TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md). So the check
# is made again from the same input, the analysis told what the typing
# found (hir::coroutines::Feedback): the operations whose written callee it
# read, to set aside, and the implementation (and, for a trait-polymorphic
# function, the specialization) each operation and call binds to, where
# that may yield. It is made until the feedback is what the check was made
# with. The feedback only grows -- it is the union of every check's -- and
# it is a set over the program's finitely many calls, implementations and
# specializations, so the checks end; a program none of whose trait
# operations' written callees the analysis reads, and none of whose
# operations' implementations may yield, is checked once. Typically the
# second check is the last: a third is needed only when a type the second
# one inferred anew (a coroutine's outward type, say) gives a trait
# operation a witness it had none for.
proc hir::check {hirVar} {
    upvar 1 $hirVar hir
    # (Under the front end's recursion floor even when not entered through
    # hir::buildSyntax: native::prepareHir re-checks a HIR itself.)
    Deep {
        set input $hir
        set feedback {}
        for {set pass 1} {1} {incr pass} {
            set hir $input
            dict incr ::hir::buildStats checks
            CheckWith hir $feedback
            set found [hir::coroutines::Feedback $hir $feedback]
            if {$found eq $feedback} {
                break
            }
            if {$pass >= 64} {
                # (The feedback grows at every repeated check and is
                # finite: a compiler bug, never a program's.)
                error "hir::check: the coroutine analysis's feedback does not settle: {$feedback} then {$found}"
            }
            set feedback $found
        }
    }
    return
}

# hir::check's one check of resolved HIR, the coroutine analysis told
# FEEDBACK (the trait operations to set aside and the trait-operation edges:
# the header).
proc hir::CheckWith {hirVar feedback} {
    upvar 1 $hirVar hir
    variable recheckReuse
    variable recheckAudit
    set input $hir
    hir::coroutines::analyze hir $feedback
    set pre $hir
    set rounds [dict create]
    CheckOnce hir {} rounds
    if {[dict exists $hir violatedContracts]} {
        set diagnostics [dict get $hir diagnostics]
        set before [dict get $hir beforeCompletions]
        set demote [lsort -unique [dict keys [dict get $hir violatedContracts]]]
        if {$recheckAudit || !$recheckReuse} {
            # The second check from the start, sharing nothing.
            set full $input
            hir::coroutines::analyze full $feedback
            CheckOnce full $demote
        }
        if {$recheckReuse} {
            set hir $pre
            CheckOnce hir $demote rounds
            if {$recheckAudit} {
                AuditRecheck $full $hir
            }
        } else {
            set hir $full
        }
        dict unset hir violatedContracts
        dict set hir diagnostics $diagnostics
        dict set hir beforeCompletions $before
        dict set hir demotedContracts $demote
    }
}

# Fails unless SHARED, the second check hir::check made reusing the first's
# work, is FULL, the same check made from the start (recheckAudit).
proc hir::AuditRecheck {full shared} {
    variable recheckAudits
    if {$full eq $shared} {
        incr recheckAudits
        return
    }
    set where {}
    foreach key [lsort -unique [concat [dict keys $full] [dict keys $shared]]] {
        if {![dict exists $full $key] || ![dict exists $shared $key]} {
            lappend where "$key (present in one only)"
        } elseif {[dict get $full $key] ne [dict get $shared $key]} {
            set detail ""
            if {$key in {exprs bindings types scopes}} {
                set a [dict get $full $key]
                set b [dict get $shared $key]
                set ids [lmap id [lsort -unique [concat [dict keys $a] [dict keys $b]]] {
                    if {[dict exists $a $id] && [dict exists $b $id]
                            && [dict get $a $id] eq [dict get $b $id]} continue
                    set id
                }]
                set detail " [lrange $ids 0 9]"
            }
            lappend where $key$detail
        }
    }
    error "hir::check: the demotion re-check that reuses the first check differs from the one made from the start in: [join $where {; }]"
}

# The checks of hir::check, one pass: HIR is the program with its coroutine
# protocols inferred; DEMOTE as for hir::signatures::infer; ROUNDSVAR, if
# given, names hir::check's memo of the signature fixpoint's rounds over
# this same HIR (hir::signatures::infer).
proc hir::CheckOnce {hirVar demote {roundsVar ""}} {
    upvar 1 $hirVar hir
    if {$roundsVar ne ""} {
        upvar 1 $roundsVar rounds
        hir::signatures::infer hir $demote rounds
    } else {
        hir::signatures::infer hir $demote
    }
    hir::range::verifyDeclaredResults hir
    hir::structs::verifyApplications hir
    hir::imprint::verify hir
    hir::cabi::verify hir
    hir::range::verifyDeclaredParams hir
    hir::operators::verify hir
    hir::decimal::verify hir
    hir::listlength::verify hir
    hir::callables::verify hir
    hir::lockstep::verify hir
    hir::structs::verify hir
    hir::resources::verify hir
    hir::contexts::verify hir
    hir::direct::verify hir
    hir::privacy::verify hir
    hir::coroutines::verify hir
    hir::resources::verifyLate hir
    hir::affine::verify hir
    hir::mutvec::verify hir
    hir::iteration::verify hir
    hir::relations::verify hir
    hir::syscall::verify hir
    hir::internal::verify hir
    hir::borrow::verify hir
    hir::layouts::verify hir
    hir::semantic::verify hir
    hir::exports::verify hir
    # {FROM TO}: the diagnostics at indices FROM to TO - 1 were reported
    # before the completion walk -- by resolution and the checks above --
    # and so are no contract-boundary report (hir::completions::Subsume),
    # which only that walk makes. Bookkeeping for hir/staticdeps.tcl (a
    # site's first diagnostic among them does not read the contract
    # boundary), never read by an analysis.
    dict set hir beforeCompletions [list 0 [llength [dict get $hir diagnostics]]]
    hir::errorsets::verify hir
    hir::modulebinding::validate hir
    hir::structs::promoteOpacity hir
    hir::traits::verify hir
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
    return [dict getdef $hir sourceTypes {}]
}

# The source-defined error declarations this HIR's own build registered
# (hir::errordecls::apply's return value): an ordered list of names. Empty
# for a program that declared none.
proc hir::errorDecls {hir} {
    return [dict getdef $hir errorDecls {}]
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

# "FILE:LINE:COLUMN" of a source ORIGIN in HIR, or the origin itself (an
# origin that is not a source span, e.g. {ir PATH}).
proc hir::originLocation {hir origin} {
    if {[lindex $origin 0] ne "file"} {
        return $origin
    }
    set path [dict get [sourceFile $hir [lindex $origin 1]] path]
    set fields [lrange $origin 2 end]
    return "$path:[dict get $fields line]:[dict get $fields column]"
}

# The source span of ORIGIN in HIR -- {file PATH start S end E line L column
# C endLine L2 endColumn C2}, PATH its file's path, the span a surface
# AST records -- or "" for an origin that is not a source span ({ir PATH}).
# Where originLocation gives a diagnostic's text its location, this gives it
# as data (core::raiseDiagnostics' `location`).
proc hir::originSpan {hir origin} {
    if {[lindex $origin 0] ne "file"} {
        return ""
    }
    set fields [lrange $origin 2 end]
    set span [dict create file [dict get [sourceFile $hir [lindex $origin 1]] path]]
    foreach key {start end line column endLine endColumn} {
        dict set span $key [dict get $fields $key]
    }
    return $span
}

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
            if {[dict get $node value] eq ""} {
                return {}
            }
            return [list [dict get $node value]]
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
        fail  {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                return [list [dict get $node value]]
            }
            return {}
        }
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
    # (An extern c fn's name is a root-kind binding of its module's scope,
    # hir/foreign.tcl: it denotes a native and owns no storage.)
    return [expr {[dict exists $hir moduleScopeIds [dict get $hir bindings $b scope]]
        && [dict get $hir bindings $b kind] ne "root"}]
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
    foreach file {syntax static staticdeps imports resolve flags variadic contexts direct privacy coroutines affine resources mutvec iteration relations refcheck hygiene sourcetypes structs enums layouts cabi imprint traits syscall internal borrow foreign errordecls refinements types operators decimal listlength exactvalue signatures modulebinding refine repeatable lower condition format read aot specialize range rangerec callables containers semantic exports completions errorsets induction transport escape blockescape stringregion traversal construction cardinality lockstep resourceescape warnings recovery methods declarations interchange} {
        uplevel #0 [list source [file join $dir $file.tcl]]
    }
}} $hir::home
