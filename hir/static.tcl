# static.tcl -- static intrinsics: `static compile:` (STATIC-COMPILE.md).
#
#   hir::static::present NODES MODULES        1 if the program has a static node
#   hir::static::decide NODES OPTIONS GIVEN HALT   => HIR (hir::buildSyntax)
#   hir::static::sites HIR                    the decided sites of a built program
#   hir::static::codes                        internal kind -> DiagnosticCode case
#
# A static intrinsic is a compiler-directed syntactic operation on a captured,
# parser-valid block: `static OPERATION:` followed by an indented block
# (surface/parser.tcl's staticIntrinsic, hir/syntax.tcl's `static` node). The
# one operation is `compile`: a recoverable semantic-compilation boundary.
#
#   static compile:
#       BODY
#
# has two compilation outcomes. If the compiler accepts BODY where it stands,
# the boundary disappears: the site becomes BODY, ordinary syntax, compiled
# by the ordinary pipeline with its ordinary value and errors. If the
# compiler rejects BODY, the site becomes the reification of the compiler's
# primary diagnostic for it -- an ordinary
#
#   fail std::compiler::CompilerError {code: std::compiler::DiagnosticCode::CASE,
#       primary: std::compiler::SourceLocation {line: L, column: C},
#       related: [...], message: "..."}
#
# -- and none of BODY survives. Either way the static node is gone before
# hir::resolve sees the program: no HIR expression, analysis, core IR form,
# NIR instruction or runtime operation knows static intrinsics exist.
#
# Phase placement
# ---------------
# After parsing (the body is parsed syntax, carried as hir/syntax.tcl nodes
# with their source origins) and before resolution (Expand writes each site's
# decided form into the syntax the ordinary build consumes). A site is
# decided by building the whole program with the ordinary pipeline -- the one
# compiler: resolution, types, ranges and refinements, completions, affine
# ownership, contexts, traits, opaque authority, semantic instances,
# callable contracts -- with the site's body in place, and reading the
# diagnostics that build records as data (hir::Diagnose: nothing raises
# during a build). That build *is* the transaction: it is a pure value (HIR is
# persistent dicts), so a rejected body is rolled back by not keeping it --
# its bindings, moves, facts, instances and summaries existed only in a HIR
# that is discarded -- and the next build starts from the decided syntax
# alone. The per-compilation registries a build fills (structs, enums,
# errors, traits, imports) are rebuilt from the same declarations by every
# build, and a static block cannot declare into them (declarations are
# top-level only), so nothing a rejected body did can leak.
#
# Which diagnostic belongs to which site
# --------------------------------------
# A diagnostic belongs to the innermost site whose body contains its primary
# location (the location a strict compile reports: its `origin`, else its
# expression's), among the sites present as bodies in that build. Every
# other diagnostic is the enclosing program's own. The site's diagnostic is
# the first of its own in the build's diagnostic list: the one ordinary
# compilation of the same code would raise first (surface::lower::Finish
# raises the list, its first first: hir/recovery.tcl; resolution
# diagnostics come first in it -- these rounds stop after them -- and a
# method-call decision prepends its own).
#
# Deciding (decide)
# -----------------
# Sites are taken in post-order: a nested site before the site containing it
# (its outcome is part of the outer body), and otherwise in source order
# (modules' sections before the entry program, as they are resolved). Each
# round builds the program with every decided site in its decided form and
# every undecided site's body in place:
#
#   1. a loader diagnostic (surface/modules.tcl: a qualified reference the
#      file may not make) found in a body rejects that site before any build
#      -- the loader runs before HIR exists, so its diagnostic precedes every
#      HIR diagnostic of the same code;
#   2. a round that stopped after resolution (strict compilation does not
#      type a program with unresolved names): every site with a resolution
#      diagnostic of its own is rejected, all together -- resolution is
#      lexical, and a site's own bindings are scoped to its block, so no
#      other site's form can change what a site's names resolve to. A
#      resolution diagnostic of the enclosing program ends the decisions:
#      the program is rejected whatever they would be;
#   3. otherwise (a typed round) the first site in post-order with a
#      diagnostic of its own that does not *wait* is rejected, and every
#      undecided site before it without one is accepted -- every site before
#      it compiled in a program whose earlier sites have their final forms. A
#      rejected body's effects (a move, a refinement, an instance, a
#      function's summary) are gone only from the next build on, so a later
#      site is judged again without them: one rejection per build. A site
#      accepted earlier that now has a diagnostic of its own is rejected (a
#      later decision removed something it relied on): decisions only ever go
#      from body to rejection, so the rounds end. A round in which no site has
#      a diagnostic of its own accepts every undecided site and is the final
#      program.
#
# The waiting rule (Next, Waits). A program-wide channel -- the
# erased-callable contract, a semantic-instance budget under pressure -- is
# one fact every site reading it shares, and its contributors may be written
# anywhere: a site's diagnostic may come from a contribution that a site
# written after it, rejected later, removes. So a failing site that may read
# a channel (its *consumer*, hir/staticdeps.tcl's `consumes`) waits while
# another failing site may change it (a *contributor*, `contributors`): the
# contributors are judged first, and the consumer against the channel their
# decisions leave -- whichever is written first. (A site whose first
# diagnostic precedes the completion walk consumes no erased contract: no
# erasure can cause or precede that diagnostic.) An ok contributor does not
# make it wait: its body stays in the final program unless a later decision
# makes it fail. A failing site that waits stays undecided. When every
# failing site waits -- on another: a cycle through a channel, each one
# consuming what another contributes -- the first one in post-order is
# rejected, as before the rule. With one failing site nothing waits. Layout
# still decides a verdict in a cycle, and where an ok contributor fails only
# after a later rejection (STATIC-COMPILE.md, "The waiting rule").
#
# That is the *sequential* order, the definition of every outcome. The
# scheduler that runs it (decide's `scheduler`) only chooses how many builds
# it takes.
#
# Decision economics: committing without a build
# ----------------------------------------------
# A site's own diagnostics are a function of the program around it -- of the
# forms of the sites its analysis can see. hir/staticdeps.tcl computes, from
# a build, which sites each site's analysis depends on (Deps: a conservative
# graph of the program's semantic channels -- nesting, a function's own
# statement sequence, the summaries a body reads, the facts of the bindings
# it captures, and the backward and program-wide channels: an untyped
# parameter's inferred contract, the callable inputs of an only-called
# function, yields, the erased-callable contract, the semantic-instance
# budget; STATIC-COMPILE.md, "Decision economics", has each one and why).
#
# The *batched* scheduler (the default) runs the sequential order on one
# build for as long as that build already answers it (Simulate): it rejects
# the first failing site that does not wait (a consumer and its contributors
# are linked: they are decided in one component, in the order the waiting
# rule gives), marks every site that depends on it *unknown* --
# its diagnostics may differ once that site is rejected -- and keeps every
# other site's status, which cannot change: nothing it depends on changed.
# It then continues with the next site in post-order, exactly as the next
# sequential build would, and stops at the first site whose status is
# unknown: only that question needs a new build. So it commits exactly the
# rejections the sequential order commits, in the same order, with the same
# diagnostics -- independent failing sites in one build, however the source
# is laid out -- and builds again only where one decision changes facts
# another one reads. A build whose outcome contradicts the prediction (a
# site the analysis said cannot have changed now fails) would mean the
# dependency analysis missed a channel; decide records it (`mispredicted` in
# staticStats) and the audits fail on it.
#
# The *sequential* scheduler builds after every rejection: the reference
# the batched one is checked against (audit/static-decisions). The *legacy*
# scheduler is the procedure before the economics milestone (Rejectable,
# Independent, GlobalChannels: one rejection per round, more only for sites
# in different top-level units that do not reach each other), kept for the
# before/after measurements; it takes its first rejection by the waiting
# rule too, and only that one while a site waits. With two or more failing
# sites, both read the dependency analysis for the rule (WaitingDeps).
#
# Decisions follow source order. A site is judged with the sites after it
# present as written: a later site's body can reach an earlier one only
# backwards -- through a loop's next iteration, a recursive call or a
# program-wide contract -- and only there can a later block that is itself
# rejected afterwards have caused an earlier block's diagnostic (a later
# *accepted* block's effect on an earlier one is ordinary: the final program
# has it). For the program-wide channels the waiting rule takes the order
# out of the verdict, except in its two residual cases; the backward
# channels of one function (a loop, a recursive call, an untyped parameter's
# inferred contract) keep it.
#
# The enclosing program's own diagnostics are not consulted while deciding
# (a trial body may cause them: a move the site's rejection undoes); those
# of the final program are its diagnostics, raised by the caller as for any
# program. The final program therefore satisfies: no diagnostic lies in the
# body of an accepted site, and every rejected site carries the primary
# diagnostic its body had in the program whose earlier sites have their
# final forms. A diagnostic the compiler marks as its own failure (an
# *-INTERNAL kind, a problem found in the monomorphized program) is never a
# site's (Internal), and a Tcl error raised while building is never caught:
# a failure of the compiler fails the compilation, never becomes a
# CompilerError.
#
# What a site sees
# ----------------
# Its body is compiled where it stands: the lexical environment (bindings,
# imports, the module's namespace), and every fact the ordinary compiler has
# there (types, ranges, refinements, ownership, contexts). Its own bindings
# are scoped to the block, exactly an `if true:` block's: an accepted body
# that binds nothing in its own scope is spliced in place (the same syntax
# nodes, so the same HIR, code and machine code as writing it there), any
# other is the then-branch of an `if` on the root `true` (Accepted).
#
# Completions
# -----------
# The reified failure is an ordinary `fail` of an ordinary payload error,
# marked `static {operation compile kind KIND}` (provenance only). Two rules
# read the mark: KNOWN-ERROR does not count a reified failure as proof that a
# function never completes normally (hir/completions.tcl's `intended`), and
# SAME-FAILURE does not count it as a fail site written by the programmer
# (hir/warnings.tcl). Everything else -- the enclosing function's `errors`,
# handlers, propagation, payload transport on every backend -- is the
# ordinary error machinery; the one other use of the mark is the wording of
# the UNHANDLED-ERROR a rejected site's error raises where it is not admitted
# (hir/resolve.tcl).

namespace eval hir::static {
    # The public diagnostic identities (stdlib/compiler.bot's `enum
    # DiagnosticCode`): every error diagnostic kind a parser-valid block can
    # make the compiler report, and the one case each becomes. Explicit and
    # one-to-one (tests/static-compile.test pins it against the enum and
    # against the census of the compiler's diagnostic kinds,
    # STATIC-COMPILE.md "Diagnostic-code census"): a kind missing here is an
    # internal compiler failure when it is reified, never a default case.
    variable codes {
        AFFINE-CAPTURE-UNSUPPORTED               AffineCaptureUnsupported
        AFFINE-CONTAINER-UNSUPPORTED             AffineContainerUnsupported
        AFFINE-CONTEXT-COPY-OUT                  AffineContextCopyOut
        AFFINE-DUPLICATION-UNSUPPORTED           AffineDuplicationUnsupported
        AFFINE-ELEMENT-COPY-OUT                  AffineElementCopyOut
        AFFINE-EQUALITY-UNSUPPORTED              AffineEqualityUnsupported
        AFFINE-ERASURE-UNSUPPORTED               AffineErasureUnsupported
        AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE   AffineFieldMoveRequiresDestructure
        AFFINE-GENERIC-NESTED-UNSUPPORTED        AffineGenericNestedUnsupported
        AFFINE-INSTANCE-BUDGET                   AffineInstanceBudget
        AFFINE-LIST-OPERATION-UNSUPPORTED        AffineListOperationUnsupported
        AFFINE-NOT-DEFINITELY-LIVE               AffineNotDefinitelyLive
        AFFINE-PATH-RELEASE-UNSUPPORTED          AffinePathReleaseUnsupported
        AFFINE-TEMPORARY-UNSUPPORTED             AffineTemporaryUnsupported
        AMBIGUOUS-CONTEXT-IMPLEMENTATION         AmbiguousContextImplementation
        AMBIGUOUS-METHOD-CALL                    AmbiguousMethodCall
        AMBIGUOUS-QUALIFIER                      AmbiguousQualifier
        ARITY                                    Arity
        BINARY-OPERAND                           BinaryOperand
        BREAK-OUTSIDE-LOOP                       BreakOutsideLoop
        CONTEXT-BINDING-COLLISION                ContextBindingCollision
        CONTEXT-FUNCTION-VALUE                   ContextFunctionValue
        CONTEXT-INSTALLATION-UNSUPPORTED         ContextInstallationUnsupported
        CONTEXT-TRAIT-MISUSE                     ContextTraitMisuse
        CONTEXT-TRAIT-POSITION                   ContextTraitPosition
        CONTINUE-OUTSIDE-LOOP                    ContinueOutsideLoop
        COROUTINE-CONTRACT                       CoroutineContract
        COROUTINE-NOT-FUNCTION                   CoroutineNotFunction
        COROUTINE-RESULT-MISMATCH                CoroutineResultMismatch
        COROUTINE-RESUME-ARITY                   CoroutineResumeArity
        COROUTINE-RESUME-CONFLICT                CoroutineResumeConflict
        COROUTINE-RESUME-TYPE                    CoroutineResumeType
        COROUTINE-RESUME-UNDERCONSTRAINED        CoroutineResumeUnderconstrained
        COROUTINE-RHS-NOT-YIELDING               CoroutineRhsNotYielding
        DECIMAL-GUARANTEE-LOST                   DecimalGuaranteeLost
        DECIMAL-PRECISION                        DecimalPrecision
        DIRECT                                   Direct
        DIRECT-CALLABLE-VALUE                    DirectCallableValue
        DUPLICATE                                Duplicate
        DUPLICATE-CONTEXT-PARAMETER              DuplicateContextParameter
        DUPLICATE-FIELD                          DuplicateField
        DUPLICATE-FLAG                           DuplicateFlag
        DUPLICATE-FLAG-DECLARATION               DuplicateFlagDeclaration
        DUPLICATE-LOOP-VARIABLE                  DuplicateLoopVariable
        EXPORT-ENVIRONMENT                       ExportEnvironment
        EXPORT-NAME                              ExportName
        EXPORT-PLACEMENT                         ExportPlacement
        EXPORT-SIGNATURE                         ExportSignature
        FLAG-BINDING-COLLISION                   FlagBindingCollision
        FLAG-CALLEE-UNKNOWN                      FlagCalleeUnknown
        FLAG-FUNCTION-VALUE                      FlagFunctionValue
        FOREIGN-BORROW                           ForeignBorrow
        IMPRINT                                  Imprint
        INTERNAL-INTRINSIC-VALUE                 InternalIntrinsicValue
        INTERNAL-NAMESPACE                       InternalNamespace
        KNOWN-ERROR                              KnownError
        LAYOUT-ARRAY-EXTENT                      LayoutArrayExtent
        LAYOUT-ARRAY-INDEX                       LayoutArrayIndex
        LAYOUT-FOREIGN-WRITE                     LayoutForeignWrite
        LAYOUT-NATIVE-ONLY                       LayoutNativeOnly
        LAYOUT-NOT-A-TYPE                        LayoutNotAType
        LAYOUT-NOT-A-VALUE                       LayoutNotAValue
        LAYOUT-OPERAND                           LayoutOperand
        LAYOUT-STRUCT-PARAMETER                  LayoutStructParameter
        LAYOUT-UNION                             LayoutUnion
        LOCKSTEP-UNEQUAL                         LockstepUnequal
        LOCKSTEP-UNPROVEN                        LockstepUnproven
        MISSING-CONTEXT                          MissingContext
        MISSING-ERROR-PAYLOAD                    MissingErrorPayload
        MISSING-FIELD                            MissingField
        MISSING-IMPORT                           MissingImport
        MODULE-CONTEXT                           ModuleContext
        MODULE-IMMUTABLE                         ModuleImmutable
        MUTABLE-PLACE-CAPTURE                    MutablePlaceCapture
        MUTABLE-PLACE-RECEIVER                   MutablePlaceReceiver
        NO-APPLICABLE-METHOD                     NoApplicableMethod
        NOMETHOD-CALL                            NomethodCall
        NOT-A-CONTEXT                            NotAContext
        NOT-A-STRUCT                             NotAStruct
        NOT-AN-ENUM                              NotAnEnum
        OPAQUE-CONSTRUCTION                      OpaqueConstruction
        OPAQUE-REPRESENTATION                    OpaqueRepresentation
        PRIVATE-ACCESS                           PrivateAccess
        PROOF-CLAUSE                             ProofClause
        REFINEMENT-MINT-AUTHORITY                RefinementMintAuthority
        REFINEMENT-PARAMETER                     RefinementParameter
        REORDER-NOT-PROVEN                       ReorderNotProven
        RESOURCE-DECLARATION                     ResourceDeclaration
        RETURN-OUTSIDE-CALLABLE                  ReturnOutsideCallable
        TRAIT-IMPL-ORDER                         TraitImplOrder
        TRAIT-INSTANCE-BUDGET                    TraitInstanceBudget
        TRAIT-NESTED-POLYMORPHIC                 TraitNestedPolymorphic
        TRAIT-NOT-SATISFIED                      TraitNotSatisfied
        TRAIT-POLYMORPHIC-FUNCTION-VALUE         TraitPolymorphicFunctionValue
        TRAIT-POLYMORPHIC-RECURSION              TraitPolymorphicRecursion
        TRAIT-STORAGE-UNSUPPORTED                TraitStorageUnsupported
        TRAIT-UNKNOWN-OPERATION                  TraitUnknownOperation
        TRAIT-VIEW-MISUSE                        TraitViewMisuse
        TRAIT-WITNESS-JOIN                       TraitWitnessJoin
        TYPE                                     Type
        UNBOUND                                  Unbound
        UNDECLARED-ERROR                         UndeclaredError
        UNEXPECTED-ERROR-PAYLOAD                 UnexpectedErrorPayload
        UNHANDLED-ERROR                          UnhandledError
        UNKNOWN-ENUM-CASE                        UnknownEnumCase
        UNKNOWN-FIELD                            UnknownField
        UNKNOWN-FLAG                             UnknownFlag
        UNKNOWN-LAYOUT                           UnknownLayout
        UNKNOWN-NAMESPACE                        UnknownNamespace
        UNKNOWN-STRUCT                           UnknownStruct
        UNKNOWN-SYMBOL                           UnknownSymbol
        UNPROVEN-FIELD                           UnprovenField
        UNWRAPPED-YIELD                          UnwrappedYield
        USE-AFTER-MOVE                           UseAfterMove
        YIELD-OUTSIDE-FUNCTION                   YieldOutsideFunction
    }
    # The canonical identities the reification constructs (stdlib/compiler.bot).
    variable errorName std::compiler::CompilerError
    variable codeEnum std::compiler::DiagnosticCode
    variable locationStruct std::compiler::SourceLocation
    # The decision scheduler (header, "Decision economics"): batched (the
    # default), sequential (the reference: one rejection per typed build) or
    # legacy (the procedure before the economics milestone). Test, audit and
    # benchmark knob only: every scheduler decides the same program.
    variable scheduler batched
    # BOTLISH_STATIC_SCHEDULER chooses it for a whole process: how the audits
    # run the existing suites under the sequential and legacy schedulers.
    if {[info exists ::env(BOTLISH_STATIC_SCHEDULER)] && $::env(BOTLISH_STATIC_SCHEDULER) ne ""} {
        set scheduler $::env(BOTLISH_STATIC_SCHEDULER)
    }
    # 1 records each round in the decided HIR's staticStats (`trace`, with
    # the reasons a failing site was deferred); BOTLISH_STATIC_TRACE=1 in the
    # environment also prints it to stderr. Diagnostics of the compiler's
    # scheduling only, never read by an analysis.
    variable trace 0
    # 1 (the default) lets a round reuse the method-style call decisions of
    # the previous one that no rejection since can have changed
    # (MethodSeeds); 0 decides every call afresh in every round.
    variable methodReuse 1
    # 1 builds every seeded round a second time without its seeds and fails
    # unless the two programs are identical (audits and tests only).
    variable methodAudit 0
}

# The static operations (surface/parser.tcl's staticOperations): the compiler's
# static-intrinsic vocabulary.
proc hir::static::operations {} {
    return {compile}
}

# The internal-kind -> DiagnosticCode-case table (see `codes` above).
proc hir::static::codes {} {
    variable codes
    return $codes
}

# The std::compiler::DiagnosticCode case of diagnostic KIND. A kind with no case is
# an internal compiler failure, never a default: the table is the public
# contract (tests/static-compile.test's census keeps it complete).
proc hir::static::CodeOf {kind} {
    variable codes
    if {![dict exists $codes $kind]} {
        error "internal compiler error: diagnostic kind \"$kind\" has no std::compiler::DiagnosticCode case (hir/static.tcl's codes, stdlib/compiler.bot)"
    }
    return [dict get $codes $kind]
}

# ---------------------------------------------------------------------------
# Sites

# 1 if the syntax NODES or any module section of MODULES holds a static node.
proc hir::static::present {nodes modules} {
    if {[HasStatic $nodes]} {
        return 1
    }
    foreach section $modules {
        if {[HasStatic [dict get $section nodes]]} {
            return 1
        }
    }
    return 0
}

proc hir::static::HasStatic {nodes} {
    foreach node $nodes {
        if {[dict get $node kind] eq "static"} {
            return 1
        }
        foreach child [Children $node] {
            if {[HasStatic [list $child]]} {
                return 1
            }
        }
    }
    return 0
}

# The direct child syntax nodes of NODE, in evaluation order.
proc hir::static::Children {node} {
    switch -- [dict get $node kind] {
        bind - ok - error {
            return [list [dict get $node value]]
        }
        return - break - fail {
            set value [dict get $node value]
            if {$value eq ""} {
                return {}
            }
            return [list $value]
        }
        block - loop - static {
            return [dict get $node body]
        }
        call {
            return [concat [list [dict get $node callee]] [dict get $node args]]
        }
        if {
            return [concat [list [dict get $node condition]] [dict get $node thenBody] [dict get $node elseBody]]
        }
        listloop {
            return [concat [list [dict get $node iterable]] [dict get $node body]]
        }
        countloop {
            return [concat [list [dict get $node start] [dict get $node end]] [dict get $node body]]
        }
        lockloop {
            set children {}
            foreach domain [dict get $node domains] {
                foreach operand {iterable start end} {
                    if {[dict exists $domain $operand]} {
                        lappend children [dict get $domain $operand]
                    }
                }
            }
            return [concat $children [dict get $node body]]
        }
        handle {
            set children [list [dict get $node call]]
            foreach handler [dict get $node handlers] {
                lappend children {*}[dict get $handler body]
            }
            return $children
        }
        struct {
            return [lmap field [dict get $node fields] {dict get $field value}]
        }
        project {
            return [list [dict get $node receiver]]
        }
    }
    return {}
}

# The key of the static node NODE: FILE:START of its origin, unique per site.
proc hir::static::Key {node} {
    set origin [dict get $node origin]
    return "[dict get $origin file]:[dict get $origin start]"
}

# The static sites of the program (its module SECTIONS, then its own NODES), in
# post-order: a nested site before the site containing it, otherwise in
# source order. Each a dict {key origin bodyOrigin operation parent deferred}
# (PARENT the key of the site whose body holds it, "" for none).
proc hir::static::Sites {nodes modules} {
    set sites {}
    foreach section $modules {
        CollectSites [dict get $section nodes] "" sites
    }
    CollectSites $nodes "" sites
    return $sites
}

proc hir::static::CollectSites {nodes parent sitesVar} {
    upvar 1 $sitesVar sites
    foreach node $nodes {
        if {[dict get $node kind] eq "static"} {
            set key [Key $node]
            CollectSites [dict get $node body] $key sites
            lappend sites [dict create key $key origin [dict get $node origin] \
                bodyOrigin [dict get $node bodyOrigin] operation [dict get $node operation] \
                parent $parent deferred [dict get $node deferred]]
            continue
        }
        CollectSites [Children $node] $parent sites
    }
}

# ---------------------------------------------------------------------------
# Expansion: the syntax a round builds

# {NODES MODULES} with every static node replaced by its form under DECISIONS
# (key -> {accepted} or {rejected DIAGNOSTIC}; an undecided site is its body, as
# an accepted one is; `unknown`, a hole: surface/modules.tcl's Recovery).
proc hir::static::Expand {nodes modules decisions} {
    set sections [lmap section $modules {
        dict set section nodes [Sequence [dict get $section nodes] $decisions]
        set section
    }]
    return [list [Sequence $nodes $decisions] $sections]
}

# The statement list NODES expanded: a static statement may become several
# statements (an accepted body spliced in place).
proc hir::static::Sequence {nodes decisions} {
    set result {}
    foreach node $nodes {
        if {[dict get $node kind] eq "static"} {
            lappend result {*}[Form $node $decisions statement]
            continue
        }
        lappend result [Node $node $decisions]
    }
    return $result
}

# The value node NODE expanded (a static node in a value position becomes one
# node).
proc hir::static::Value {node decisions} {
    if {$node eq ""} {
        return ""
    }
    if {[dict get $node kind] eq "static"} {
        return [lindex [Form $node $decisions value] 0]
    }
    return [Node $node $decisions]
}

# NODE (not itself static) with every static node below it expanded.
proc hir::static::Node {node decisions} {
    switch -- [dict get $node kind] {
        bind - ok - error {
            dict set node value [Value [dict get $node value] $decisions]
        }
        return - break - fail {
            dict set node value [Value [dict get $node value] $decisions]
        }
        block - loop {
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        call {
            dict set node callee [Value [dict get $node callee] $decisions]
            dict set node args [lmap arg [dict get $node args] {Value $arg $decisions}]
        }
        if {
            dict set node condition [Value [dict get $node condition] $decisions]
            dict set node thenBody [Sequence [dict get $node thenBody] $decisions]
            dict set node elseBody [Sequence [dict get $node elseBody] $decisions]
        }
        listloop {
            dict set node iterable [Value [dict get $node iterable] $decisions]
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        countloop {
            dict set node start [Value [dict get $node start] $decisions]
            dict set node end [Value [dict get $node end] $decisions]
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        lockloop {
            dict set node domains [lmap domain [dict get $node domains] {
                foreach operand {iterable start end} {
                    if {[dict exists $domain $operand]} {
                        dict set domain $operand [Value [dict get $domain $operand] $decisions]
                    }
                }
                set domain
            }]
            dict set node body [Sequence [dict get $node body] $decisions]
        }
        handle {
            dict set node call [Value [dict get $node call] $decisions]
            dict set node handlers [lmap handler [dict get $node handlers] {
                dict set handler body [Sequence [dict get $handler body] $decisions]
                set handler
            }]
        }
        struct {
            dict set node fields [lmap field [dict get $node fields] {
                dict set field value [Value [dict get $field value] $decisions]
                set field
            }]
        }
        project {
            dict set node receiver [Value [dict get $node receiver] $decisions]
        }
    }
    return $node
}

# The nodes the static node NODE becomes under DECISIONS, in a statement
# position (POSITION statement: any number of statements) or a value
# position (value: exactly one node).
proc hir::static::Form {node decisions position} {
    set key [Key $node]
    if {[dict exists $decisions $key] && [dict get $decisions $key] eq "unknown"} {
        # A program with syntax errors (SYNTAX-RECOVERY-MILESTONE-1.md):
        # whether the block compiles is not known, nor what it is; it binds
        # nothing either way (Accepted).
        return [list [hir::syntax::holeNode [dict get $node origin] 0]]
    }
    if {[dict exists $decisions $key] && [lindex [dict get $decisions $key] 0] eq "rejected"} {
        return [list [Reified $node [lindex [dict get $decisions $key] 1]]]
    }
    return [Accepted $node [Sequence [dict get $node body] $decisions] $position]
}

# An accepted (or undecided) site NODE whose expanded body is BODY: the body
# itself where that is exactly the ordinary block -- it binds nothing in its
# own scope, so there is nothing for a block to scope, and in a value
# position it is one expression -- else the body as the then-branch of an
# `if` on the root `true`, the ordinary block (`if true:`) that scopes what it
# binds. Neither form is marked: an accepted site is ordinary syntax.
proc hir::static::Accepted {node body position} {
    if {[hir::syntax::scopeBindNames $body] eq {}} {
        if {$position eq "statement"} {
            return $body
        }
        if {[llength $body] == 1
                && [dict get [lindex $body 0] kind] in {const ref call struct project if handle loop listloop countloop lockloop ok error}} {
            return $body
        }
    }
    set origin [dict get $node origin]
    set bodyOrigin [dict get $node bodyOrigin]
    return [list [hir::syntax::ifNode $origin [hir::syntax::rootRef [Role $origin block] true] \
        $bodyOrigin $body [Role $origin else] {}]]
}

# ORIGIN with the node id role ROLE appended (surface/lower.tcl's convention
# for nodes a rule adds).
proc hir::static::Role {origin role} {
    if {[dict exists $origin node]} {
        dict set origin node "[dict get $origin node]/$role"
    }
    return $origin
}

# ---------------------------------------------------------------------------
# Reification: a rejected site's ordinary failure

# The `fail std::compiler::CompilerError {...}` node a rejected site NODE becomes,
# reifying DIAGNOSTIC ({kind message origin related}: ORIGIN the primary
# location, RELATED a list of origins). Every constructed value is an
# ordinary literal or construction of stdlib/compiler.bot's declarations, by
# their canonical identities (the file imports `compiler`: surface/
# modules.tcl requires it of every file using a static intrinsic). The node
# carries `static {operation OPERATION kind KIND}`: provenance, read by
# KNOWN-ERROR, SAME-FAILURE, the UNHANDLED-ERROR wording and HIR text only.
proc hir::static::Reified {node diagnostic} {
    variable errorName
    variable codeEnum
    set origin [Role [dict get $node origin] reified]
    set kind [dict get $diagnostic kind]
    set code [hir::syntax::constNode $origin enum [list $codeEnum [CodeOf $kind]]]
    set primary [Location $origin [dict get $diagnostic origin]]
    set related [hir::syntax::withWritten [hir::syntax::callNode $origin \
        [hir::syntax::rootRef $origin list] \
        {*}[lmap r [dict get $diagnostic related] {Location $origin $r}]] list]
    set message [hir::syntax::constNode $origin str [dict get $diagnostic message]]
    set fields {}
    foreach {name value} [list code $code primary $primary related $related message $message] {
        lappend fields [dict create name $name nameOrigin $origin origin $origin value $value]
    }
    set payload [hir::syntax::structNode $origin "" $fields]
    dict set payload payloadOf $errorName
    set fail [hir::syntax::failNode $origin $errorName $payload]
    dict set fail static [dict create operation [dict get $node operation] kind $kind]
    return $fail
}

# A std::compiler::SourceLocation construction (at ORIGIN) of the source location
# AT: its line and column in its own file.
proc hir::static::Location {origin at} {
    variable locationStruct
    set fields {}
    foreach name {line column} {
        lappend fields [dict create name $name nameOrigin $origin origin $origin \
            value [hir::syntax::constNode $origin [dict get $at $name]]]
    }
    return [hir::syntax::structNode $origin [dict create id $locationStruct] $fields]
}

# ---------------------------------------------------------------------------
# Deciding

# hir::buildSyntax for a program with static sites (NODES, the options
# OPTIONS/GIVEN as there, HALT whether the caller stops after resolution
# errors): the rounds of this file's header, then the final program -- built
# with the caller's HALT -- with its decisions in `staticSites` (key -> {key
# origin operation outcome accepted|rejected diagnostic D}, D the reified
# diagnostic), the number of builds they took in `staticRounds` and their
# economics in `staticStats` (DecisionStats).
proc hir::static::decide {nodes options given halt} {
    variable scheduler
    variable trace
    if {$scheduler ni {batched sequential legacy}} {
        error "hir::static: unknown scheduler \"$scheduler\" (batched, sequential or legacy)"
    }
    set tracing [expr {$trace || ([info exists ::env(BOTLISH_STATIC_TRACE)]
        && $::env(BOTLISH_STATIC_TRACE) ni {"" 0})}]
    set modules [dict get $options -modules]
    set sites [Sites $nodes $modules]
    set decisions [dict create]
    set log {}
    set loaderRejected {}
    foreach site $sites {
        set deferred [dict get $site deferred]
        if {$deferred ne {}} {
            # The loader's diagnostic precedes every HIR diagnostic of the
            # same code: the site is rejected before any build.
            set first [lindex $deferred 0]
            set diagnostic [dict create kind [dict get $first kind] message [dict get $first message] \
                origin [dict get $first origin] related {}]
            dict set decisions [dict get $site key] [list rejected $diagnostic]
            lappend loaderRejected [TraceDecision [dict get $site key] $diagnostic]
        }
    }
    if {$loaderRejected ne {}} {
        lappend log [dict create round 0 phase loader rejected $loaderRejected]
    }
    set start [hir::BuildStats]
    set stats [dict create scheduler $scheduler mispredicted {} depMs 0 committedWithoutBuild 0]
    # The batched scheduler's prediction for the next build (Simulate): key
    # -> ok, or the first diagnostic a still-failing site keeps.
    set predicted [dict create]
    # The method-style call decisions the next round takes as made.
    set seeds [dict create]
    set rounds 0
    while 1 {
        incr rounds
        set before [hir::BuildStats]
        set hir [Round $nodes $options $given $decisions 1 checked $seeds]
        set seeds [dict create]
        set own [Attribute $hir $sites $decisions]
        dict unset own ""
        set entry [dict create round $rounds phase [expr {$checked ? "checked" : "resolution"}] \
            bodies [llength [Present $sites $decisions]] \
            undecided [llength [lmap site $sites {
                if {[dict exists $decisions [dict get $site key]]} continue
                dict get $site key
            }]]]
        if {!$checked} {
            # Stopped after resolution: every site with a resolution
            # diagnostic of its own is rejected (resolution is lexical). A
            # site the last batched run predicted ok has none (a rejected
            # inner block's failure, which resolution charges to the block
            # around it, makes that one depend on it).
            dict for {key expectation} $predicted {
                if {$expectation eq "ok" && [dict exists $own $key]} {
                    dict lappend stats mispredicted [list $rounds $key]
                }
            }
            set rejected {}
            dict for {key diagnostics} $own {
                dict set decisions $key [list rejected [lindex $diagnostics 0]]
                lappend rejected [TraceDecision $key [lindex $diagnostics 0]]
            }
            dict set entry rejected $rejected
            lappend log [RoundEntry $entry $before]
            if {[dict size $own] == 0} {
                # Only the enclosing program's own: it is rejected whatever
                # the sites would be.
                break
            }
            set predicted [dict create]
            continue
        }
        set failing {}
        foreach site $sites {
            if {[dict exists $own [dict get $site key]]} {
                lappend failing [dict get $site key]
            }
        }
        dict for {key expectation} $predicted {
            # A prediction of the last simulation that this build contradicts
            # (a message's internal ids are this build's numbering: an
            # earlier rejection renumbers them, whatever the site depends on).
            if {[dict exists $own $key]} {
                set actual [PredictionOf [lindex [dict get $own $key] 0]]
            } else {
                set actual "ok"
            }
            if {$actual ne $expectation} {
                dict lappend stats mispredicted [list $rounds $key]
            }
        }
        set predicted [dict create]
        dict set entry failing [llength $failing]
        if {$failing eq {}} {
            AcceptBefore $sites decisions "" accepted
            dict set entry accepted $accepted
            lappend log [RoundEntry $entry $before]
            break
        }
        switch -- $scheduler {
            legacy {
                set siteRecords [lmap site $sites {
                    if {[dict get $site key] ni $failing} continue
                    set site
                }]
                # The waiting rule decides which site goes first, as in the
                # sequential order; while a site waits, one per round.
                set deps [WaitingDeps $hir $sites $decisions $failing stats]
                lassign [Next $sites $decisions $own $deps] first waiting
                AcceptBefore $sites decisions $first accepted $failing
                set rejected {}
                if {[dict size $waiting] > 0} {
                    set keys [list $first]
                } else {
                    set keys [Rejectable $hir $siteRecords]
                }
                foreach key $keys {
                    dict set decisions $key [list rejected [lindex [dict get $own $key] 0]]
                    lappend rejected [TraceDecision $key [lindex [dict get $own $key] 0]]
                }
                dict set entry accepted $accepted
                dict set entry rejected $rejected
                dict set entry deferred [lmap key $failing {
                    if {$key in $keys} continue
                    if {[dict exists $waiting $key]} {
                        list $key [WaitReason $deps [dict get $waiting $key]]
                    } else {
                        list $key "legacy: not proven independent of an earlier failing site"
                    }
                }]
            }
            sequential {
                set deps [WaitingDeps $hir $sites $decisions $failing stats]
                lassign [Next $sites $decisions $own $deps] key waiting
                AcceptBefore $sites decisions $key accepted $failing
                dict set decisions $key [list rejected [lindex [dict get $own $key] 0]]
                dict set entry accepted $accepted
                dict set entry rejected [list [TraceDecision $key [lindex [dict get $own $key] 0]]]
                dict set entry deferred [lmap other $failing {
                    if {$other eq $key} continue
                    if {[dict exists $waiting $other]} {
                        list $other [WaitReason $deps [dict get $waiting $other]]
                    } else {
                        list $other "sequential: one rejection per build"
                    }
                }]
            }
            batched {
                variable methodReuse
                set t0 [clock microseconds]
                set methods [expr {$methodReuse && [dict exists $hir methodDecided]
                    && [dict get $hir methodDecided] ne {}}]
                if {[llength $failing] > 1 || $methods} {
                    set deps [hir::staticdeps::Deps $hir $sites $decisions $methods]
                } else {
                    # One failing site: whatever depends on it, the next
                    # sequential step needs a build.
                    set deps ""
                }
                dict incr stats depMs [expr {([clock microseconds] - $t0) / 1000}]
                set result [Simulate $sites $decisions $own $deps]
                set decisions [dict get $result decisions]
                set predicted [dict get $result predicted]
                set committed [dict get $result committed]
                dict incr stats committedWithoutBuild [expr {[llength $committed] - 1}]
                if {$methods} {
                    set seeds [MethodSeeds $hir $deps $committed]
                    dict set entry methodSeeds [dict size $seeds]
                    dict set entry methodRetried [expr {[dict size [dict get $hir methodCalls]] - [dict size $seeds]}]
                }
                dict set entry accepted [dict get $result accepted]
                dict set entry rejected [lmap key $committed {
                    TraceDecision $key [lindex [dict get $own $key] 0]
                }]
                dict set entry deferred [lmap key $failing {
                    if {$key in $committed} continue
                    list $key [Deferral $hir $sites $decisions $deps $result $key $tracing]
                }]
                if {$deps ne ""} {
                    dict set entry channels [dict get $deps channels]
                }
            }
        }
        lappend log [RoundEntry $entry $before]
    }
    if {!$halt && !$checked} {
        # The caller keeps the diagnostics of a program that does not
        # resolve and analyzes it anyway: build the decided program its way.
        set hir [Round $nodes $options $given $decisions 0 checked]
        incr rounds
    }
    set end [hir::BuildStats]
    foreach counter {builds methodTrials methodFinals methodReused methodReports} {
        dict set stats $counter [expr {[dict get $end $counter] - [dict get $start $counter]}]
    }
    dict set stats rounds $rounds
    if {$tracing} {
        dict set stats trace $log
        if {[info exists ::env(BOTLISH_STATIC_TRACE)] && $::env(BOTLISH_STATIC_TRACE) ni {"" 0}} {
            puts stderr [FormatTrace $stats]
        }
    }
    set summary [dict create]
    foreach site $sites {
        set key [dict get $site key]
        set decision [dict getdef $decisions $key "undecided"]
        set entry [dict create key $key origin [dict get $site origin] \
            operation [dict get $site operation] outcome [lindex $decision 0]]
        if {[lindex $decision 0] eq "rejected"} {
            dict set entry diagnostic [lindex $decision 1]
        }
        dict set summary $key $entry
    }
    dict set hir staticSites $summary
    dict set hir staticRounds $rounds
    dict set hir staticStats $stats
    return $hir
}

# The sites of SITES present as bodies under DECISIONS (not rejected), in
# post-order.
proc hir::static::Present {sites decisions} {
    return [lmap site $sites {
        set key [dict get $site key]
        if {[dict exists $decisions $key] && [lindex [dict get $decisions $key] 0] eq "rejected"} continue
        set site
    }]
}

# Accepts, in the caller's DECISIONSVAR, every undecided site of SITES (in
# post-order) before the site with key STOP ("" for all of them), except
# the keys of FAILING (the failing sites before it wait: Next): what the
# sequential order does for the ok sites before the one it rejects. Sets the
# caller's ACCEPTEDVAR to their keys.
proc hir::static::AcceptBefore {sites decisionsVar stop acceptedVar {failing {}}} {
    upvar 1 $decisionsVar decisions $acceptedVar accepted
    set accepted {}
    foreach site $sites {
        set key [dict get $site key]
        if {$key eq $stop} break
        if {![dict exists $decisions $key] && $key ni $failing} {
            dict set decisions $key accepted
            lappend accepted $key
        }
    }
}

# The waiting rule (header, "Deciding"): whether failing site KEY waits --
# a program-wide channel its diagnostics may depend on (DEPS's consumes:
# hir/staticdeps.tcl) has a contributor other than KEY that is failing in
# STATUS (key -> ok, failing or unknown, for the sites present as bodies, in
# post-order). Returns "" when it does not, {Z CHANNEL} -- the first such
# contributor in post-order and its channel -- when it does, and ? when that
# cannot be told yet (no contributor is failing, and one's status is
# unknown). With DEPS "" (no analysis: one failing site) no site waits.
proc hir::static::Waits {key status deps} {
    if {$deps eq "" || ![dict exists $deps consumes $key]} {
        return ""
    }
    set channelOf [dict create]
    foreach channel [dict get $deps consumes $key] {
        if {![dict exists $deps contributors $channel]} continue
        foreach z [dict get $deps contributors $channel] {
            if {$z ne $key && ![dict exists $channelOf $z]} {
                dict set channelOf $z $channel
            }
        }
    }
    set unsure 0
    dict for {z s} $status {
        if {![dict exists $channelOf $z]} continue
        if {$s eq "failing"} {
            return [list $z [dict get $channelOf $z]]
        }
        if {$s eq "unknown"} {
            set unsure 1
        }
    }
    return [expr {$unsure ? "?" : ""}]
}

# The site the sequential order rejects in a checked build (header,
# "Deciding"): of SITES (post-order) present under DECISIONS, OWN the
# build's diagnostics by site and DEPS its dependency analysis ("" with one
# failing site), the first failing site that does not wait (Waits); when
# every failing site waits -- on another one: a cycle through a channel --
# the first failing site. Returns {KEY WAITING}, WAITING the failing sites
# that wait: key -> {Z CHANNEL}.
proc hir::static::Next {sites decisions own deps} {
    set status [dict create]
    foreach site [Present $sites $decisions] {
        set key [dict get $site key]
        dict set status $key [expr {[dict exists $own $key] ? "failing" : "ok"}]
    }
    set first ""
    set pick ""
    set waiting [dict create]
    dict for {key s} $status {
        if {$s ne "failing"} continue
        if {$first eq ""} {
            set first $key
        }
        set w [Waits $key $status $deps]
        if {$w ne ""} {
            dict set waiting $key $w
        } elseif {$pick eq ""} {
            set pick $key
        }
    }
    if {$pick eq ""} {
        set pick $first
    }
    dict unset waiting $pick
    return [list $pick $waiting]
}

# The dependency analysis the waiting rule reads in a checked build of HIR
# (SITES under DECISIONS) whose failing sites are FAILING: "" with one (it
# cannot wait), else hir::staticdeps::Deps, its time added to the caller's
# STATSVAR's depMs.
proc hir::static::WaitingDeps {hir sites decisions failing statsVar} {
    upvar 1 $statsVar stats
    if {[llength $failing] < 2} {
        return ""
    }
    set t0 [clock microseconds]
    set deps [hir::staticdeps::Deps $hir $sites $decisions]
    dict incr stats depMs [expr {([clock microseconds] - $t0) / 1000}]
    return $deps
}

# The trace's reason for a failing site that waits (Waits' {Z CHANNEL}).
proc hir::static::WaitReason {deps wait} {
    lassign $wait z channel
    return "waits for $z, a failing contributor to [hir::staticdeps::Name $deps $channel] it consumes"
}

# The batched scheduler's run of the sequential order on one build (header,
# "Decision economics"): SITES in post-order, DECISIONS as built, OWN the
# build's diagnostics by site (Attribute, without ""), DEPS the dependency
# analysis of the build (hir::staticdeps::Deps; "" with one failing site).
# The status of a site is failing (it has a diagnostic of its own), ok, or
# unknown (it depends on a site rejected since the build).
#
# The sites fall into *components*: sites linked, directly or through
# others, by a dependency in either direction or by the waiting rule (a
# failing site and every contributor it may wait on, Components). No decision in
# one component can change a status or a wait in another, so the
# sequential order of the whole program is an interleaving of each
# component's own sequential order, and the run takes each component's
# sequential step on its own: reject the component's first failing site in
# post-order that does not wait (and accept the undecided ok sites of the
# component before it), or, when every failing site of it waits, its first
# failing site (Next). A rejection makes every site depending on it
# unknown; a component whose first site not ok is unknown, or one of whose
# failing sites may or may not wait (a contributor's status is unknown),
# needs a build, the others go on. Returns a dict: decisions, committed (the rejected keys, in
# order), accepted (the keys accepted), predicted (key -> ok or the first
# diagnostic: what the next build must show for each site whose status the
# run still knows), held (the sites whose message names internal ids, left
# for a build), waiting (the failing sites the last step saw waiting: key
# -> {Z CHANNEL}).
proc hir::static::Simulate {sites decisions own deps} {
    set parentOf [dict create]
    foreach site $sites {
        dict set parentOf [dict get $site key] [dict get $site parent]
    }
    set status [dict create]
    foreach site [Present $sites $decisions] {
        set key [dict get $site key]
        dict set status $key [expr {[dict exists $own $key] ? "failing" : "ok"}]
    }
    set component [Components $status $deps]
    set committed {}
    set held {}
    set acceptedAll {}
    while 1 {
        # Each component's sequential step: its first failing site in
        # post-order that does not wait (Waits); a component whose first
        # site not ok is unknown, or whose failing site may or may not wait,
        # needs a build. A component whose failing sites all wait (a cycle
        # through a channel) rejects its first failing site (Next).
        set first ""
        set tie 0
        set blocked [dict create]
        set cycle [dict create]
        set waiting [dict create]
        dict for {key s} $status {
            set c [dict get $component $key]
            if {$s eq "ok" || [dict exists $blocked $c]} continue
            if {$s eq "unknown"} {
                dict set blocked $c 1
                continue
            }
            set w [Waits $key $status $deps]
            if {$w eq "?"} {
                dict set blocked $c 1
                continue
            }
            if {$w ne ""} {
                dict set waiting $key $w
                if {![dict exists $cycle $c]} {
                    dict set cycle $c $key
                }
                continue
            }
            set first $key
            break
        }
        if {$first eq ""} {
            dict for {c key} $cycle {
                if {![dict exists $blocked $c]} {
                    set first $key
                    set tie 1
                    break
                }
            }
        }
        if {$first eq ""} break
        set c [dict get $component $first]
        set ids [InternalIds [dict get [lindex [dict get $own $first] 0] message]]
        if {$ids ne {}} {
            # Its message names internal identities (hir::types::show's
            # `block(e12)`, InternalIds), numbered by the build in one walk: an expression
            # number is the sequential order's own only if no site numbered
            # before it has another form here than there -- a site rejected
            # since this build, or a site of a blocked component that is not
            # ok: before it (the sequential order may reject it first), or,
            # for a cycle's site, anywhere (the sequential order breaks a
            # cycle only once no failing site anywhere is free). A failing
            # site of a component not blocked that waits keeps its form until
            # then (nothing it waits on can change first). Any other kind of
            # id is assumed to depend on every site. Else its component waits
            # for a build. (The run's first pick has no such site: a run
            # always commits one.)
            set differing $committed
            dict for {key s} $status {
                if {$key eq $first} {
                    if {!$tie} break
                    continue
                }
                if {$s eq "ok"} continue
                if {[dict exists $waiting $key] && ![dict exists $blocked [dict get $component $key]]} continue
                lappend differing $key
            }
            set clean 1
            if {$differing ne {}} {
                set bound ""
                foreach key $differing {
                    if {$deps ne "" && [dict exists $deps firstIds $key]} {
                        set n [dict get $deps firstIds $key]
                        if {$bound eq "" || $n < $bound} {
                            set bound $n
                        }
                    } elseif {$deps eq ""} {
                        set bound 0
                    }
                }
                foreach id $ids {
                    if {![string match e* $id] || ($bound ne "" && [string range $id 1 end] >= $bound)} {
                        set clean 0
                    }
                }
            }
            if {!$clean} {
                dict set status $first unknown
                lappend held $first
                continue
            }
        }
        set accepted {}
        foreach site $sites {
            set key [dict get $site key]
            if {$key eq $first} break
            if {![dict exists $decisions $key] && [dict exists $status $key]
                    && [dict get $component $key] eq $c && [dict get $status $key] eq "ok"} {
                dict set decisions $key accepted
                lappend accepted $key
            }
        }
        lappend acceptedAll {*}$accepted
        dict set decisions $first [list rejected [lindex [dict get $own $first] 0]]
        lappend committed $first
        dict unset status $first
        # The sites nested in its body are gone with it (each was ok: it
        # comes before it, and is accepted with the others).
        foreach site $sites {
            set key [dict get $site key]
            if {[dict exists $status $key] && [Inside $parentOf $key $first]} {
                if {![dict exists $decisions $key]} {
                    dict set decisions $key accepted
                    lappend acceptedAll $key
                }
                dict unset status $key
            }
        }
        dict for {key s} $status {
            if {$deps eq "" || $first in [dict get $deps sites $key]} {
                # Without an analysis every other site is unknown.
                dict set status $key unknown
            }
        }
    }
    set predicted [dict create]
    dict for {key s} $status {
        switch -- $s {
            ok { dict set predicted $key ok }
            failing { dict set predicted $key [PredictionOf [lindex [dict get $own $key] 0]] }
        }
    }
    return [dict create decisions $decisions committed $committed accepted $acceptedAll \
        predicted $predicted held $held waiting $waiting]
}

# The components (Simulate) of the sites of STATUS under DEPS: key -> a
# component id; one component when DEPS is "" (no analysis). Sites are
# linked by a dependency in either direction and by the waiting rule (a
# failing site and every contributor to a channel it consumes).
proc hir::static::Components {status deps} {
    set leader [dict create]
    dict for {key s} $status {
        dict set leader $key $key
    }
    if {$deps eq ""} {
        set first [lindex [dict keys $status] 0]
        dict for {key s} $status {
            dict set leader $key $first
        }
        return $leader
    }
    dict for {key s} $status {
        set others [dict get $deps sites $key]
        # And, for a failing site, every site it may wait on (Waits): a
        # contributor to a channel it consumes need not be one whose form it
        # reads (the erased contract reads its witnesses' only), and the rule
        # must stay inside a component. (Only a failing site waits: within a
        # run an ok site stays ok or becomes unknown.)
        if {$s eq "failing" && [dict exists $deps consumes $key]} {
            foreach channel [dict get $deps consumes $key] {
                if {[dict exists $deps contributors $channel]} {
                    lappend others {*}[dict get $deps contributors $channel]
                }
            }
        }
        foreach other $others {
            if {![dict exists $leader $other]} continue
            set a [Find leader $key]
            set b [Find leader $other]
            if {$a ne $b} {
                dict set leader $a $b
            }
        }
    }
    set component [dict create]
    dict for {key s} $status {
        dict set component $key [Find leader $key]
    }
    return $component
}

proc hir::static::Find {leaderVar key} {
    upvar 1 $leaderVar leader
    set root $key
    while {[dict get $leader $root] ne $root} {
        set root [dict get $leader $root]
    }
    while {[dict get $leader $key] ne $root} {
        set next [dict get $leader $key]
        dict set leader $key $root
        set key $next
    }
    return $root
}

# What a prediction of the batched run (Simulate) says about DIAGNOSTIC: the
# diagnostic with the internal ids of its message blanked (InternalIds).
proc hir::static::PredictionOf {diagnostic} {
    dict set diagnostic message [regsub -all {\m(block\(|function )e[0-9]+\M} [dict get $diagnostic message] {\1#}]
    return $diagnostic
}

# The internal identities of the build it came from that diagnostic MESSAGE
# names, whose numbering depends on the sites before them in the walk: the
# expression ids of exact callables, which a message prints the way
# hir::types::show and hir::specialize::ShowKey do, `block(e12)`, or, for a
# function without a name, hir::semantic::ShowType, `function e12` -- the
# forms in which a diagnostic names an id. Nothing else counts: a word of the
# message that merely looks like an id (a binding written `s1` or `t2`) is the
# program's own text, the same in every build.
proc hir::static::InternalIds {message} {
    return [lmap {- - id} [regexp -all -inline {\m(block\(|function )(e[0-9]+)\M} $message] {set id}]
}

# 1 if site KEY is nested, at any depth, in the body of site OUTER (PARENTOF:
# site key -> the key of the site whose body holds it, "" for none).
proc hir::static::Inside {parentOf key outer} {
    set p [dict get $parentOf $key]
    while {$p ne ""} {
        if {$p eq $outer} {
            return 1
        }
        set p [dict get $parentOf $p]
    }
    return 0
}

# Why the batched run (RESULT of Simulate on DEPS) left failing site KEY
# undecided: it depends on a site the run rejected (with the dependency's
# path when TRACING: hir::staticdeps::Explain), or it comes after a site of
# its component whose status became unknown, or it waits for a failing
# contributor to a channel it consumes (Waits).
proc hir::static::Deferral {hir sites decisions deps result key tracing} {
    if {$key in [dict get $result held]} {
        return "its message names internal ids, numbered by the forms of the sites before it: decided in the sequential order's own build"
    }
    if {$deps eq ""} {
        return "depends on [lindex [dict get $result committed] 0] (no dependency analysis with one failing site)"
    }
    foreach c [dict get $result committed] {
        if {$c in [dict get $deps sites $key]} {
            if {$tracing} {
                return "depends on $c: [hir::staticdeps::Explain $deps $key $c]"
            }
            return "depends on $c"
        }
    }
    if {[dict exists $result waiting $key]} {
        return [WaitReason $deps [dict get $result waiting $key]]
    }
    return "after a site of its component whose status is unknown"
}

# The trace record of a decision: KEY and DIAGNOSTIC's kind and location.
proc hir::static::TraceDecision {key diagnostic} {
    set origin [dict get $diagnostic origin]
    set at ""
    if {[lindex $origin 0] eq "file"} {
        set at "[dict get [lrange $origin 2 end] line]:[dict get [lrange $origin 2 end] column]"
    }
    return [list $key [dict get $diagnostic kind] $at]
}

# ENTRY with the builds made since the counters were BEFORE.
proc hir::static::RoundEntry {entry before} {
    set now [hir::BuildStats]
    foreach counter {builds methodTrials methodFinals methodReused methodReports} {
        dict set entry $counter [expr {[dict get $now $counter] - [dict get $before $counter]}]
    }
    return $entry
}

# The decision trace of STATS (staticStats with `trace`) as text, one line
# per round and one per decision.
proc hir::static::FormatTrace {stats} {
    set lines [list "static decisions ([dict get $stats scheduler]): [dict get $stats rounds] rounds,\
        [dict get $stats builds] builds ([dict get $stats methodTrials] method trials,\
        [dict get $stats methodFinals] method finals, [dict get $stats methodReports] reported forms,\
        [dict get $stats methodReused] reused)"]
    foreach entry [dict get $stats trace] {
        set head "round [dict get $entry round] ([dict get $entry phase])"
        foreach field {bodies undecided failing builds methodTrials methodSeeds methodRetried} {
            if {[dict exists $entry $field]} {
                append head " $field [dict get $entry $field]"
            }
        }
        lappend lines $head
        if {[dict exists $entry rejected]} {
            foreach r [dict get $entry rejected] {
                lappend lines "    reject [lindex $r 0] [lindex $r 1] [lindex $r 2]"
            }
        }
        if {[dict exists $entry deferred]} {
            foreach d [dict get $entry deferred] {
                lappend lines "    defer [lindex $d 0]: [lindex $d 1]"
            }
        }
        if {[dict exists $entry accepted] && [dict get $entry accepted] ne {}} {
            lappend lines "    accept [llength [dict get $entry accepted]]: [dict get $entry accepted]"
        }
        if {[dict exists $entry channels]} {
            lappend lines "    channels [dict get $entry channels]"
        }
    }
    if {[dict get $stats mispredicted] ne {}} {
        lappend lines "MISPREDICTED [dict get $stats mispredicted]"
    }
    return [join $lines \n]
}

# The legacy scheduler (header, "Decision economics"; kept for the
# before/after measurements, never the default). The keys of the sites of
# FAILING (the sites with a diagnostic of their own in HIR, a typed build, in
# post-order) this round rejects: the first, whose earlier sites all have
# their final forms -- and every other one that no other site of FAILING can
# have caused its diagnostic (Independent): its diagnostic stays when the
# others are rejected, so it is decided now rather than one build later.
# Without that proof, sites are decided one per round. The batched scheduler
# replaces the top-level units by the dependency graph of
# hir/staticdeps.tcl and GlobalChannels' stop sign by its channel nodes.
proc hir::static::Rejectable {hir failing} {
    set keys [list [dict get [lindex $failing 0] key]]
    if {[llength $failing] < 2 || [GlobalChannels $hir]} {
        return $keys
    }
    set units [Units $hir]
    foreach y [lrange $failing 1 end] {
        set alone 1
        foreach z $failing {
            if {$z eq $y} continue
            if {![Independent $hir $units $y $z]} {
                set alone 0
                break
            }
        }
        if {$alone} {
            lappend keys [dict get $y key]
        }
    }
    return $keys
}

# The legacy scheduler's stop sign: 1 if a site's body in HIR might change
# what the compiler concludes about code anywhere, whatever calls what -- a
# call that violates a trusted inferred contract (the contract is demoted for
# every call, hir::check), or a callable with declared errors passed into an
# untyped parameter (the uncontracted erased-callable channel: the
# erased-callable contract charges every call that has lost both identity
# and contract precision -- no exact callee, no verified structural contract
# bounding it -- and bounds what a structural type admits where a value
# acquires it, hir/completions.tcl). In such a build the legacy scheduler
# proves no site independent and decides one per round. Neither is a global
# stop sign for the batched scheduler: a demotion changes no diagnostic
# (hir::check keeps the diagnostics of the check before it), and the
# erased-callable contract is a node of hir/staticdeps.tcl's graph with
# contributors (the erasing calls) and consumers (the calls without identity
# or contract precision); a call through a verified structural contract
# consumes nothing.
proc hir::static::GlobalChannels {hir} {
    if {[dict exists $hir demotedContracts] && [dict get $hir demotedContracts] ne {}} {
        return 1
    }
    return [expr {[hir::completions::erasedErrorsOf $hir] ne {}}]
}

# 1 if the body of site Z cannot have caused a diagnostic in the body of site
# Y in HIR, by the program's units (Units): Y and Z lie in different units,
# and neither unit reaches the other through the references of the program
# -- Y's unit uses nothing whose analysis Z's body takes part in, and Z's unit
# calls into nothing of Y's. A unit is a top-level function definition (with
# everything nested in it: its body runs in sequence, so its sites see each
# other's effects), or the top-level code of one module section or of the
# entry program (all of it: it runs in sequence too). Neither site may hold
# the other.
proc hir::static::Independent {hir units y z} {
    set uy [UnitOf $units $y]
    set uz [UnitOf $units $z]
    if {$uy eq "" || $uz eq "" || $uy eq $uz} {
        return 0
    }
    set reach [dict get $units reach]
    return [expr {$uz ni [dict get $reach $uy] && $uy ni [dict get $reach $uz]}]
}

# The units of HIR (Independent): {roots {UNIT {FILE START END} ...} reach
# {UNIT {UNIT ...} ...}}, UNIT a root ExprId (a top-level function
# definition) or code:SCOPE (the rest of the top level of that section's
# scope), REACH the units each unit's code transitively refers to.
proc hir::static::Units {hir} {
    set unitOfBinding [dict create]
    set rootsOf [dict create]
    set spans {}
    foreach r [dict get $hir roots] {
        set node [dict get $hir exprs $r]
        set unit "code:[dict get $node scope]"
        if {[dict get $node kind] eq "bind" && [dict get $hir exprs [dict get $node value] kind] eq "block"} {
            set unit $r
        }
        if {[dict get $node kind] eq "bind" && [dict get $node binding] ne ""} {
            dict set unitOfBinding [dict get $node binding] $unit
        }
        dict lappend rootsOf $unit $r
        set origin [dict get $node origin]
        if {[lindex $origin 0] eq "file"} {
            lappend spans [list $unit [dict get $origin file] [dict get $origin start] [dict get $origin end]]
        }
    }
    set uses [dict create]
    dict for {unit roots} $rootsOf {
        set used [dict create]
        set stack $roots
        while {$stack ne {}} {
            set e [lindex $stack end]
            set stack [lrange $stack 0 end-1]
            set node [dict get $hir exprs $e]
            if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""
                    && [dict exists $unitOfBinding [dict get $node binding]]} {
                dict set used [dict get $unitOfBinding [dict get $node binding]] 1
            }
            lappend stack {*}[hir::children $hir $e]
        }
        dict set uses $unit [dict keys $used]
    }
    set reach [dict create]
    dict for {unit _} $rootsOf {
        set seen [dict create]
        set stack [dict get $uses $unit]
        while {$stack ne {}} {
            set u [lindex $stack end]
            set stack [lrange $stack 0 end-1]
            if {[dict exists $seen $u]} continue
            dict set seen $u 1
            if {[dict exists $uses $u]} {
                lappend stack {*}[dict get $uses $u]
            }
        }
        dict set reach $unit [dict keys $seen]
    }
    return [dict create spans $spans reach $reach]
}

# The unit (Units) site SITE belongs to: the top-level definition or code
# whose source span holds the site, else the one its body's code lies in;
# "" if none is found (never independent).
proc hir::static::UnitOf {units site} {
    set origin [dict get $site origin]
    set file [dict get $origin file]
    set start [dict get $origin start]
    set end [dict get $origin end]
    foreach span [dict get $units spans] {
        lassign $span unit f from to
        if {$f eq $file && $start >= $from && $start <= $to} {
            return $unit
        }
    }
    foreach span [dict get $units spans] {
        lassign $span unit f from to
        if {$f eq $file && $from >= $start && $from <= $end} {
            return $unit
        }
    }
    return ""
}

# One build of the program under DECISIONS: hir::BuildFull of the expanded
# syntax, stopping after resolution errors when HALT, with the method-style
# call decisions SEEDS taken as made (MethodSeeds). Sets CHECKEDVAR to
# whether the static checks ran.
proc hir::static::Round {nodes options given decisions halt checkedVar {seeds {}}} {
    upvar 1 $checkedVar checked
    variable methodAudit
    lassign [Expand $nodes [dict get $options -modules] $decisions] nodes modules
    dict set options -modules $modules
    if {[dict exists $given -modules]} {
        dict set given -modules $modules
    }
    if {$methodAudit && $seeds ne {}} {
        # The audit: the same round deciding every call afresh must be the
        # same program (built first, so the per-compilation registries are
        # the seeded build's afterwards).
        set fresh [hir::BuildFull $nodes $options $given $halt freshChecked]
    }
    set hir [hir::BuildFull $nodes $options $given $halt checked $seeds]
    if {$methodAudit && $seeds ne {}} {
        foreach {what a b} [list checked $freshChecked $checked \
                diagnostics [dict get $fresh diagnostics] [dict get $hir diagnostics] \
                choices [dict get $fresh methodChoices] [dict get $hir methodChoices] \
                program [hir::format $fresh] [hir::format $hir]] {
            if {$a ne $b} {
                error "hir::static: method-call decision reuse changed the round's $what (seeds: $seeds)"
            }
        }
    }
    return $hir
}

# The method-style call decisions of HIR (a typed build: its methodDecided)
# that the next round, in which the sites COMMITTED are rejected, may take as
# made, by the dependency analysis DEPS of HIR (hir::staticdeps::Deps with
# methods): a call's decision is a function of what its region reaches -- its
# receiver, arguments and candidates, the calls those depend on, and the
# sites (METHOD-SUGAR.md's rule, decided by trial builds of the candidates).
# A call is decided afresh when it was not decided here (rejected, or not a
# trial's to decide) or a committed site reaches it -- and so is every call
# such a call reaches: the trial builds pair a call's candidates with those
# of the calls it depends on, so a call decided afresh must see them varied
# exactly as an unseeded round varies them. Every other decision is the one
# the next round would make again.
proc hir::static::MethodSeeds {hir deps committed} {
    set decided [dict get $hir methodDecided]
    set methods [dict get $deps methods]
    set retry [dict create]
    dict for {key cone} $methods {
        if {![dict exists $decided $key]} {
            dict set retry $key 1
            continue
        }
        foreach c $committed {
            if {$c in [dict get $cone sites]} {
                dict set retry $key 1
                break
            }
        }
    }
    set work [dict keys $retry]
    while {$work ne {}} {
        set key [lpop work]
        if {![dict exists $methods $key]} continue
        foreach other [dict get $methods $key calls] {
            if {![dict exists $retry $other]} {
                dict set retry $other 1
                lappend work $other
            }
        }
    }
    set seeds [dict create]
    dict for {key choice} $decided {
        if {![dict exists $retry $key] && [dict exists $methods $key]} {
            dict set seeds $key $choice
        }
    }
    return $seeds
}

# The diagnostics of HIR (one build) by owner: a dict key -> its diagnostics
# in list order, each {kind message origin related}, for every site whose
# body (present in this build: not rejected under DECISIONS) holds the
# diagnostic's primary location innermost; key "" holds the enclosing
# program's own.
proc hir::static::Attribute {hir sites decisions} {
    set present {}
    foreach site $sites {
        set key [dict get $site key]
        if {[dict exists $decisions $key] && [lindex [dict get $decisions $key] 0] eq "rejected"} continue
        lappend present $site
    }
    set owners [dict create "" {}]
    foreach diagnostic [dict get $hir diagnostics] {
        set origin [PrimaryOrigin $hir $diagnostic]
        set owner [Owner $present $origin]
        if {[Internal $diagnostic]} {
            # A failure of the compiler is never a block's rejection: it
            # stays the program's, and fails the compilation loudly.
            set owner ""
        }
        set related [dict getdef $diagnostic related {}]
        dict lappend owners $owner [dict create kind [dict get $diagnostic kind] \
            message [dict get $diagnostic message] origin $origin related $related]
    }
    return $owners
}

# 1 if DIAGNOSTIC reports a failure of the compiler rather than of the code:
# an internal invariant (the *-INTERNAL kinds) or a problem found in the
# monomorphized program, which is the checked program with every trait
# resolved (hir/traits.tcl marks those `internal`).
proc hir::static::Internal {diagnostic} {
    return [expr {[dict exists $diagnostic internal]
        || [string match *-INTERNAL [dict get $diagnostic kind]]}]
}

# The primary location of DIAGNOSTIC in HIR: the origin a strict compile
# reports it at (surface::lower::Finish).
proc hir::static::PrimaryOrigin {hir diagnostic} {
    if {[dict exists $diagnostic origin]} {
        return [dict get $diagnostic origin]
    }
    set e [dict get $diagnostic expr]
    if {$e eq "" || ![dict exists $hir exprs $e]} {
        return ""
    }
    return [hir::get $hir $e origin]
}

# The key of the innermost site of SITES whose body holds the source location
# ORIGIN, or "" (the enclosing program's).
proc hir::static::Owner {sites origin} {
    if {[lindex $origin 0] ne "file"} {
        return ""
    }
    set file [lindex $origin 1]
    set at [dict get [lrange $origin 2 end] start]
    set owner ""
    set best -1
    foreach site $sites {
        set body [dict get $site bodyOrigin]
        if {[lindex $body 1] ne $file} continue
        set span [lrange $body 2 end]
        set start [dict get $span start]
        if {$at >= $start && $at <= [dict get $span end] && $start > $best} {
            set owner [dict get $site key]
            set best $start
        }
    }
    return $owner
}

# ---------------------------------------------------------------------------
# Queries

# The static sites of the built HIR and their decisions (hir::static::decide's
# `staticSites`), {} for a program without any.
proc hir::static::sites {hir} {
    return [dict getdef $hir staticSites {}]
}
