# lower.tcl -- native lowering: semantic HIR to NIR, the native backend IR.
#
#   set nir [native::lower::program $hir]      ;# dict: text functions ...
#   puts [dict get $nir text]
#
# Pipeline:
#
#   HIR --native::lower--> NIR (text) --botlish-native--> Cranelift IR --> machine code
#
# This layer decides *what* native code does; the Rust backend
# (native/src/codegen) decides only how to express it in Cranelift IR. It
# does no semantic analysis of its own. Everything it knows comes from HIR
# and from the shared analyses in hir/aot.tcl and hir/specialize.tcl:
#
#   function instances, their call targets  hir::specialize::analyze
#   static types of an instance's code      its view (hir::specialize::view)
#   which operand needs which kind check    hir::aot::analyzeRegion on the
#                                           view: blockers (class
#                                           representation), known errors
#   self tail calls                         hir::aot::selfTailCalls (the same
#                                           criterion the Tcl compiler uses)
#   references needing an init check        hir::aot::unprovenReferences
#   blocks that need no environment         envless (hir::aot::context)
#   which Block values code materializes    hir::aot::materializedBlocks
#
# Instances
# ---------
# Each NIR function is one instance (hir/specialize.tcl) of a block or of the
# program: a block's generic instance, or a specialization whose parameters
# have statically known kinds. A specialization has the generic function's
# signature and ABI (tagged values in, a tagged value out) and differs only
# in what its code need not check. A direct call calls the instance the
# analysis chose; Block values (fnvalue, closure) are always generic
# instances. Only instances lowered code refers to are emitted, numbered in
# program order (the block's position, then discovery order).
#
# -specialize 0 (or BOTLISH_NATIVE_SPECIALIZE=0) lowers generic instances
# only, with the semantic types: the guarded baseline.
#
# NIR
# ---
# A NIR program is a list of functions over numbered registers (%0, %1, ...)
# holding tagged Botlish values. It has no semantic concepts (no names to
# resolve, no types, no traits): only representation-level operations.
#
#   native "NAME" arity=N|* params="KIND..." impl=OP
#       A native used as a value: what a call chosen at run time checks and
#       performs (from the native registry).
#   func F "NAME" params=N env=0|1 regs=R pnames="P ..." captures=K instance="KEY"
#       Function F. Registers %0..%N-1 hold the arguments on entry. env=1:
#       the function also receives its closure, holding K captures. KEY
#       ("generic", or its key types) documents which instance it is.
#   %d = int DIGITS | str "TEXT" | bool true|false | unit
#   %d = native NAME           a native callable value
#   %d = fnvalue F             the closure of environment-free function F
#   %d = self                  the running closure (env=1)
#   %d = capture I             capture I of the running closure (env=1)
#   %d = move %s
#   %d = cell                  a fresh binding cell, not yet bound
#   cellset %c %v              binds the cell
#   %d = cellget %c            reads a cell proven bound
#   %d = cellcheck %c "NAME"   reads a cell; UNBOUND if not bound yet
#   %d = closure F %c...       a closure of F capturing the values %c...
#   guard KIND %v "CONTEXT"    TYPE error unless %v has kind KIND
#   guardbool %v               NOT-BOOLEAN error unless %v is a Boolean
#   %d = op OP %a...           a known operation whose operands have the
#                              kinds it requires (see Ops below)
#   %d = call F %a...          direct call of environment-free F
#   %d = callenv F %k %a...    direct call of F with closure %k
#   %d = callvalue %f %a...    call of a callable chosen at run time
#   tail %a...                 self tail call: rebind %0.. and restart
#   tailenv %k %a...           the same, with closure %k
#   br %c LTHEN LELSE          %c is a Boolean
#   jump L / label L / ret %v
#   raise KIND "MESSAGE"       a semantic error HIR found statically
#   unreachable                HIR proved no normal completion reaches here
#
# Every instruction may end with @ExprId (its HIR expression).
#
# Values and bindings
# -------------------
# A local binding is a register, unless some reference to it cannot be
# proven bound when it runs (a forward reference from a closure): then it is
# a *cell* created when its scope is entered, and closures capture the cell.
# Closures capture every other binding by value, which is sound because a
# proven reference's binding is bound before the closure is created. A
# closure refers to its own function binding through `self`. A binding bound
# to an environment-free function is not captured at all: its value is the
# function's constant closure (fnvalue).
#
# Unsupported constructs raise {NATIVE UNSUPPORTED} with the source location
# and HIR node (see Unsupported).

namespace eval native::lower {
    # Native name -> how native code performs it: {op OP} (after the
    # parameter kind checks the registry declares), or a special form. The
    # identity of an implementation is necessarily by native; everything
    # else (arity, parameter kinds, runtime needs) comes from the registry.
    variable natives [dict create \
        +            {op iadd} \
        -            {op isub} \
        *            {op imul} \
        mod          {op imod} \
        bit_and      {op iand} \
        bit_or       {op ior} \
        bit_xor      {op ixor} \
        shift_left   {op ishl} \
        shift_right  {op ishr} \
        <            {op ilt} \
        <=           {op ile} \
        >            {op igt} \
        >=           {op ige} \
        ==           {equality} \
        eq           {op streq} \
        list         {op listnew} \
        length       {op strlen} \
        substring    {op substr} \
        lowercase    {op strlower} \
        concat       {op strcat} \
        encode_utf8  {op strutf8bytes} \
        is_tcl_alpha {op strtclalpha} \
        is_tcl_alnum {op strtclalnum} \
        list_length  {op listlen} \
        list_get     {op listget} \
        list_append  {op listappend} \
        immutable_set_from_list {op setfromlist} \
        immutable_set_contains  {op setcontains} \
        mutable_array_allocate {op mutarrayallocate} \
        mutable_array_capacity {op mutarraycapacity} \
        mutable_array_get      {op mutarrayget} \
        mutable_array_set      {op mutarrayset} \
        mutable_array_copy     {op mutarraycopy} \
        mutable_array_freeze   {op mutarrayfreeze} \
        integer?     {op isint} \
        string?      {op isstr} \
        list?        {op islist} \
        ok?          {op isok} \
        error?       {op iserror} \
        result-value {op resultvalue} \
        result-error {op resulterror} \
        hash         {op hash} \
        char_codepoint {op charcodepoint}]
    # State of the program being lowered. hir is the view of the instance
    # being lowered, baseHir the program's semantic HIR.
    variable hir {}
    variable baseHir {}
    variable spec {}
    variable context {}
    variable guards {}
    variable knownErrors {}
    variable selfTail {}
    variable unproven {}
    variable cells {}
    variable envless {}
    variable captureLists {}
    variable pending {}
    variable usedNatives {}
    # NAME -> small 1-indexed id (EXPLICIT-ERROR-COMPLETIONS.md), assigned
    # once per program in `program` below, in `hir::errorDecls`'s own
    # (already-sorted, program-unique) order: `fail`'s own Inst::Fail
    # embeds the id as a compile-time constant, and each `handle` arm's
    # Inst::DeclaredErrorEq compares the runtime pending id against it --
    # never a runtime name lookup.
    variable errorIds {}
    # Representation (see "Representation" below): the hir::range analysis
    # of the program, the instance currently being lowered (its key into
    # it), and whether local unboxing is enabled at all.
    variable ranges {}
    variable currentInstance {}
    variable reprOpt 1
    # The widest shift amount a raw (host machine i64) shift may use (see
    # RawEligibleShift): the host word width, not core/scalarbits.tcl's own
    # much larger MAX_SHIFT -- a proven-constant shift count under this bound
    # is always also within MAX_SHIFT, so raw eligibility never needs to
    # consult that separate, generic-path-only contract.
    variable rawShiftMax 64
    # Scalar replacement (see "Scalar replacement" below): the hir::escape
    # analysis of the program, and whether it is enabled at all.
    variable escape {}
    variable escapeOpt 1
    # Parameter virtualization (see "Parameter virtualization" below):
    # whether hir::escape::analyze's own parameter-boundary growth pass is
    # enabled, independent of escapeOpt above.
    variable paramAggregateOpt 1
    # Block virtualization (see "Block virtualization" below): the
    # hir::blockescape analysis of the program, and whether it is enabled
    # at all.
    variable blockescape {}
    variable blockEscapeOpt 1
    # String regions (see "String regions" below): the hir::stringregion
    # analysis of the program, and whether it is enabled at all.
    variable stringregion {}
    variable stringRegionOpt 1
    # String traversal (see "String traversal" below): the hir::traversal
    # analysis of the program, and whether it is enabled at all.
    variable traversal {}
    variable traversalOpt 1
    # Tiny exact-leaf inlining (see "Tiny exact-leaf inlining" below):
    # whether it is enabled at all, and a memo cache InstanceId -> 0|1 (reset
    # at the start of every native::lower::program call), since
    # LeafInlineEligible's own answer for a given callee instance never
    # changes within one lowering and the same callee may be reached from
    # several exact call sites.
    variable tinyLeafInlineOpt 1
    variable leafEligible {}
    # The small, fixed, auditable operation-count budget (TINY-EXACT-LEAF-
    # INLINING.md): comfortably above both real target bodies
    # (byte::high_nibble's 1 native call, byte::nibble's 4), with headroom
    # for a small synthetic multi-op test, not guessed large.
    variable leafInlineMaxOps 8
    # The fixed, generic set of native ops (the same op table above) a tiny
    # leaf's body may call: pure, total, allocation-free scalar Int
    # arithmetic/comparison/bitwise ops, plus shift (LeafShiftSafe proves
    # its own error-safety separately) -- deliberately not `imod` (no
    # existing error-safety proof for it), not `veq`/`streq` (not proven
    # allocation-free), and nothing else in the `natives` table above.
    variable leafInlineSafeOps {iadd isub imul ilt ile igt ige ieq iand ior ixor ishr ishl}
}

# ---------------------------------------------------------------------------
# Representation
#
# Alongside the semantic/kind checks above (guards), a function's local Int
# values may be lowered as raw (untagged) machine integers rather than
# tagged Values, when hir/range.tcl's analysis proves an operand's -- and,
# for arithmetic, the result's -- mathematical range fits the runtime's
# small-Int representation (hir::range::smallMin/smallMax). This never
# changes what a value *is* (still an arbitrary-precision Botlish Int): it
# is purely a lowering choice, exactly as sound whether taken or not (see
# hir/range.tcl's header). -repr-opt 0 (or BOTLISH_NATIVE_REPR_OPT=0)
# disables it, for differential testing and benchmark comparison.
#
# The rewrite applies to `+ - * < <= > >= ==` on two Ints already proven that
# kind by a guard or by a static type (representation is strictly downstream
# of the guard/kind machinery: see RawIntOp), and, since the bounded-shift-
# lowering milestone, to `>>`/`<<` (shift_right/shift_left) once both the
# shifted value and the shift amount are additionally proven safe
# (RawEligibleShift): nonnegative, in range, and (for the shift amount) a
# single already-known value -- AND/OR/XOR are deliberately not part of this
# tier (see below): they already have their own branch-free tagged-word fast
# path (native/src/codegen/clif.rs's int_bitop), which a raw promotion would
# only duplicate, not improve.
# Every "logical" NIR register a binding, a call argument, or a branch join
# is ever known by stays tagged, exactly as it is today; raw registers are
# purely local temporaries introduced and consumed within one function's
# lowering, never stored in `fn locals`, never a captured value, never an
# argument, never a branch's joined result. That keeps the function ABI,
# self-tail-loop parameter slots (always tagged: see native/src/codegen/
# clif.rs's `def` vs `def_raw`) and every other lowering rule unchanged.
#
# fn rawCache: tagged Reg -> raw Reg, so reading the same already-small
# local twice (e.g. two arithmetic expressions over the same binding) unboxes
# it once (RawOf), and a value this lowering already boxed from a raw result
# is unboxed again for free (a box TaggedOf itself created caches both
# directions). Scoped like fn locals: If and Loop save and restore it around
# each branch, since a register's raw counterpart from one branch does not
# dominate the other or the code after the join.
#
# Demand-driven lowering
# -----------------------
# Expr's contract is "produce the representation the caller asked for", not
# unconditionally tagged: `Expr fn e ?want?` (want defaults to `tagged`, the
# conservative form every ordinary caller keeps getting) returns a register
# already in that representation. Only two expression kinds can produce `raw`
# directly, without ever materializing a tagged value first:
#
#   ref   a local/parameter register already stored raw (a self-tail-proven
#         parameter, RawParams): returned as-is, no conversion at all.
#   call  a native `+ - * < <= > >= ==` or a proven-safe `>>`/`<<` whose
#         operands need no runtime kind guard (RawEligibleCall) and whose
#         operand/result ranges are proven small (hir/range.tcl): its own
#         operands are demanded raw too (so a chain like `(i + 1) * 2 - 3`,
#         or a shift chained onto one, stays raw throughout, recursively),
#         and the arithmetic/shift result is boxed only if the caller wanted
#         tagged -- a comparison's result is always a tagged Bool regardless,
#         since raw is purely an Int representation (see #11 of the
#         milestone this was written for; Bool representation is untouched).
#
# Every other expression kind (and a raw-ineligible call, or one whose
# operand needs a guard: guards run on tagged registers, so representation
# stays downstream of them exactly as before) always produces tagged; Expr's
# uniform tail then converts with RawOf/TaggedOf if the caller's `want`
# disagrees with what was produced -- "decline raw, lower tagged, runbox"
# (milestone #6). Because RawOf/TaggedOf are the same two caches either way,
# asking for one representation and later the other of the same *register*
# never re-runs the expression's own code (only Bind/Call's argument
# evaluation ever *runs* an expression; a subsequent Ref of the binding it
# produced just reads that one register, in whichever representation the new
# use needs) -- see the milestone's #8/#18/#30.
#
# The two places that actually *ask* for raw are: NativeCall, for the
# operands of a raw-eligible arithmetic/comparison (recursively demanding raw
# from whatever produced them), and Call, for a self-tail call's arguments at
# a parameter slot RawParams proved raw for the whole function (replacing the
# old always-produce-tagged-then-RawOf-it-back TailArgs). Both are exactly
# the places native/lower.tcl already knew, from existing analysis, that raw
# is both safe and wanted; nothing here adds a new proof.

# ---------------------------------------------------------------------------
# Scalar replacement
#
# A fixed-shape immutable List value (`[e0, ..., en-1]`) whose object
# identity hir/escape.tcl proves is never observed may stay a handful of
# scalar registers instead of ever calling `listnew`, with every
# `list_get(..., k)` reading it at a compile-time-constant position reading
# the corresponding register directly instead of calling `listget`. This
# holds for two shapes (hir/escape.tcl's Classify):
#
#   local    a plain `[e0, ..., en-1]` construction, bound to a local
#            binding every one of whose references is such a `list_get`:
#            purely intraprocedural, needs no ABI change at all -- Bind
#            below just evaluates e0..en-1 into fresh registers instead of
#            building a List from them, exactly as constant folding would.
#   remote   the same, but the aggregate is *returned* by an exact, closed
#            direct call to another (non-generic-required) instance whose
#            own result is itself fully recognized this same way. This is
#            the milestone's central case (#6-7): the allocation crosses a
#            function boundary, so avoiding it needs the callee's fields
#            back without ever materializing a List in between.
#
# The remote case is why every instance hir::escape::wants also gets a
# second, additional NIR function emitted alongside its ordinary one
# (CompanionFunction, vs. Function): a "scalar-replacement companion" whose
# signature declares `results=N` (nir.rs's Function::results) and whose
# every terminator is `retmulti` (N registers) instead of `ret` (one),
# reached only through the internal `callmulti`/`callenvmulti` NIR ops
# (nir.rs's CallMulti/CallEnvMulti) -- never through the generic entry ABI,
# never as a Block value. This is deliberately the smallest calling
# convention that fits the architecture (the milestone's #7): Cranelift
# already supports a function returning several values natively, so no
# out-pointer, no caller-allocated result slot, and no source-level
# multiple return values are needed. It applies *only* to this one instance
# for this one internal calling convention; the instance's ordinary
# Function is still unconditionally emitted exactly as before (guards,
# knownErrorGuards, its own List-returning `ret`), so a generic/indirect/
# test-harness caller that needs the real List keeps working unchanged
# (the milestone's #28) -- hir::escape::wants only ever *adds* a companion,
# it never changes what a canonical function returns.
#
# Call (below), the shared block-call lowering every direct call already
# goes through, is where both callers of a wanted instance meet: a `bind`
# whose value is a recognized remote construction (Bind) and, inside a
# companion's own body, one of its own recognized forwarding exits
# (CompanionFunction/the `return` case of Expr) both ask Call for `results`
# registers directly (its optional wantVirtual argument) instead of one
# tagged register -- the same "ask for the representation actually wanted"
# discipline as the raw/tagged demand-driven lowering above, just for an
# aggregate's fields instead of an Int's bits. A self-tail call (already a
# NIR `tail`/`tailenv` loop backedge, never a completion) is unaffected
# either way: Call decides that before ever consulting wantVirtual.
#
# Effects, evaluation order and errors (#12-13) fall out of reusing exactly
# the same argument-evaluation code Call and the native-call path already
# run for an ordinary construction/call: nothing here evaluates anything an
# unoptimized lowering would not have, in any different order, or fails to
# check. GC rooting (#24) needs no new mechanism either: every field
# register is an ordinary tagged NIR register, and codegen already stores
# every register's value to its own shadow-stack slot on definition
# (codegen/clif.rs's `def`) regardless of what produced it, so a field that
# used to be a List element is rooted exactly as it was before, for as long
# as its slot is live.
#
# hir::escape.tcl is conservative and additive only: a binding or an
# instance this analysis does not recognize (any escaping use, a dynamic
# index, an argument crossing a call boundary as a plain parameter rather
# than a call result -- the HashTable rehash-grouping case, see
# hir::escape.tcl's header -- a generic/indirect call, recursion without a
# base case) simply lowers exactly as it always did. -escape-opt 0 (or
# BOTLISH_NATIVE_ESCAPE_OPT=0) disables the analysis outright, for
# differential testing against the unoptimized baseline.
#
# ---------------------------------------------------------------------------
# Block virtualization (de-closure conversion)
#
# A Block value bound to a local name whose every use hir/blockescape.tcl
# proves is a statically known direct call -- from its own enclosing
# region, from inside another nonescaping sibling Block's own body, or its
# own exact recursive call -- need not become a canonical heap closure at
# all: a semantic Block is code identity plus a captured lexical
# environment, not a mandatory heap object, exactly as a semantic Int is
# not a mandatory tagged representation (the "Representation" section
# above) and a fixed-shape List is not a mandatory allocated List (the
# "Scalar replacement" section above). Bind (below), for such a binding,
# does nothing at all -- no closure, no captures evaluated, no local
# stored -- exactly like an envless function bound in statement position:
# hir::blockescape.tcl's own proof already guarantees every reference to
# it is intercepted before ever being evaluated as a value (below), so
# there is nothing here to compute yet.
#
# A direct call of such a binding (Call's early FlattenedVirtualCall
# dispatch, keyed by BindingId via hir::blockescape::virtual -- so it
# fires identically whether the binding was bound in the calling
# function's own region or an enclosing one) never evaluates the callee
# expression as a Block value: it emits a plain `call` (or, for the
# callee's own self-tail recursive call, a `tail` loop backedge) to the
# callee instance's *internal variant* (InternalFunction), with the
# ordinary call arguments followed by the callee's *flattened* capture
# registers (hir::blockescape::captures), resolved fresh -- via
# CaptureRegsOf -- in the calling function's own current scope. This is
# sound by construction (hir/blockescape.tcl's FlattenBinding): every
# binding a callee's flattened list names is already, transitively, a
# subset of whatever the calling function's own params/captures/locals
# already are, so Access always finds it. The capture arguments are an
# internal ABI detail, invisible to Botlish source (the milestone's #9),
# and the call target is always statically direct (never a code-pointer
# load out of a Block, since there is no Block).
#
# The internal variant is the smallest coherent NIR mechanism this needs
# (deliberately not a new opcode, heap pseudo-object, or dynamic capture
# dictionary): the same instance, the same body, as the callee's ordinary
# (canonical) function, except env=0 and its capture bindings
# (native::lower::captureLists, overridden from hir::blockescape::captures
# for a wants-flagged instance) are ordinary trailing parameters instead of
# an environment record -- so every reference to a captured binding inside
# it is just that parameter's register (Access finds it already in `fn
# locals`, exactly as an ordinary parameter is, and never emits a `capture
# I` load), and a reference to the callee's *own* binding (a recursive
# self-call) needs no "self" (running-closure identity) value at all --
# FlattenedVirtualCall recognizes it as the same instance currently being
# lowered and calls back into it directly, re-passing the same capture
# registers, in a `tail` loop backedge for a self-tail call (never
# `tailenv`: there is no environment register to carry) or an ordinary
# `call` otherwise (the milestone's #21-22: non-tail recursion needs no
# special support of its own). Cranelift already treats an internal
# variant as an entirely ordinary function (no `env=1`, no `results=`), so
# it gets ordinary GC rooting (every register, including a former capture,
# is stored to its own shadow-stack slot on definition, precisely as
# "Scalar replacement" above reasons for a virtual List field) and
# ordinary error/completion-code handling, with no new runtime or codegen
# mechanism at all. It is built at most once per callee instance, shared
# by every call site that demands it (like a scalar-replacement
# companion), and is purely additive: the callee's canonical,
# closure-taking function is still unconditionally emitted, so a
# generic/indirect/escaping caller of the very same Block-producing source
# keeps working completely unchanged (the milestone's #10 fallback
# requirement) -- `return step` or `consume_unknown(step)` still build a
# real heap closure, even for a `step` some other call site virtualizes; a
# captured-but-ineligible callee (one some use this analysis cannot vouch
# for as an exact call at all) simply stays a genuine, terminal capture --
# an ordinary Block value -- in every eligible sibling's own flattened
# list, gracefully degrading rather than losing the sibling's own
# virtualization.
#
# hir::blockescape.tcl is conservative and additive only, and declines
# outright (never partially materializes) a binding with any use it cannot
# vouch for as an exact call, or one capturing a forward-reference cell --
# see its header for the exact criteria and the bounded, single-region
# transitive fixpoint this now is. -block-escape-opt 0 (or
# BOTLISH_NATIVE_BLOCK_ESCAPE_OPT=0) disables the analysis outright, for
# differential testing against the unoptimized (canonical closure)
# baseline.
#
# Composing with String regions: capture-explicit region companions
# ---------------------------------------------------------------------
# A candidate whose result some caller asks for in StringRegion "region"
# form (the "String regions" section below -- e.g. `char_at(i) == "@"`, or
# `is_local_char(char_at(i))` through a ConsumingParams inline call) is
# *not* excluded from virtualization: the same de-closure conversion above
# applies, and Call's own dispatch (below, the FlattenedVirtualCall/
# FlattenedVirtualRegionCall split) resolves, per call site, which of the
# candidate's two internal variants that particular use needs.
#
# An earlier version of this composition (see git history) declined a
# candidate outright the moment hir::stringregion.tcl proved any caller
# wanted its result as a region: the only region companion that existed
# then (RegionCompanionFunction, below) took a real closure/environment
# register (`callenvmulti`, "capture 0" reads), which a capture-explicit
# candidate -- by definition, no closure object -- cannot supply. That
# mismatch is what this section's own internal *region* companion
# (InternalRegionCompanionFunction, InternalRegionCompanionRef) resolves:
# it is InternalFunction's own env=0/capture-explicit-parameters shape,
# generated from the exact same instance and body as the ordinary,
# closure-taking RegionCompanionFunction, ending in the same `retmulti` of
# region fields instead of `ret`ing a materialized String. Nothing here
# fabricates an environment, a fake closure, or a transient Block to bridge
# the two: the region companion's own captures are simply the same ordinary
# capture *values* (hir::blockescape::captures) the ordinary internal
# variant already receives as trailing parameters -- the smallest
# composition of the two existing "capture representation" (canonical
# environment vs. capture-explicit) and "result representation" (ordinary
# vs. StringRegion) dimensions, not a third representation of either.
#
# Demand-driven, like every other variant in this file: InternalRegionCompanionRef
# only ever enters native::lower::program's `pending` work list when Call's
# FlattenedVirtualRegionCall actually needs it (some call site asks for
# region form), so a candidate with only ordinary-result callers never gets
# one, and a candidate with both ordinary- and region-result callers gets
# both internal variants -- sharing the callee instance's one flattened
# capture list either way (never independently re-derived, never
# re-ordered: see FlattenedVirtualRegionCall's own comment). The
# candidate's canonical, closure-taking function and its canonical region
# companion (RegionCompanionFunction) remain unconditionally available too,
# for any caller that genuinely needs a real Block value or reaches the
# candidate through the closure-taking region companion some other way
# (e.g. a generic/indirect call) -- exactly the same "purely additive,
# canonical entry still correct for every other caller" discipline this
# section's own ordinary internal variant already established.
#
# ---------------------------------------------------------------------------
# Parameter virtualization
#
# The "Scalar replacement" section above already keeps a fixed-shape List
# scalar when it is *constructed* locally or *returned* by a direct call
# (hir/escape.tcl's `local`/`remote` cases). This section is the third,
# closed-call-*parameter* case that module's own header used to call out as
# a "structural blocker": a fixed-shape List value an exact caller hands
# to a callee whose own uses of that parameter are themselves all
# structural (hir::escape::paramVirtualArity) need not materialize at that
# boundary either -- exactly the same "semantic aggregate, not a mandatory
# heap representation" reasoning as Block virtualization above, just for a
# List parameter instead of a Block's captured environment.
#
# Two additional NIR functions per eligible instance (hir::escape::
# paramWants), built the same lazy, on-demand way (native/lower.tcl's
# `pending` work list) as a scalar-replacement companion or a Block
# internal variant, alongside the instance's *unconditionally* still-
# emitted canonical function (so every open/dynamic/mismatched-shape caller
# keeps calling a real List-taking function, completely unaffected):
#
#   fields            (FieldsFunction) the same instance and body as
#                      Function, except every parameter
#                      hir::escape::paramVirtualArity recognizes is
#                      received as that many ordinary trailing-in-place
#                      field registers instead of one List register
#                      (SetupFieldParams) -- stored in `fn locals` exactly
#                      like a virtualized *local* binding already is
#                      (`{virtual fields}`), so the existing `list_get(ref,
#                      constant)` interception in Call (the "Scalar
#                      replacement" section's own mechanism) needs no
#                      change at all to also serve a virtualized parameter:
#                      it already only ever consults `fn locals`, never
#                      which kind of binding put a `{virtual ...}` entry
#                      there. Still ends in an ordinary `ret` of one
#                      (possibly still-materialized) tagged List, exactly
#                      like Function.
#   fieldscompanion    (FieldsCompanionFunction) the same, but for an
#                      instance hir::escape::wants *also* holds for (its
#                      own result is itself recognized): ends in `retmulti`
#                      of its own recognized construction's fields, exactly
#                      like CompanionFunction, just with virtualized
#                      parameters too. This is what lets a builder-style
#                      `append(state, value) -> [storage2, length2]`
#                      chain stay scalar on *both* its parameter and result
#                      boundaries at once, reusing the exact same
#                      results=N/retmulti/callmulti machinery "Scalar
#                      replacement" already built -- no new multi-value ABI
#                      mechanism for this milestone (#20-21 of the
#                      milestone this was written for).
#
# A direct call site (Call's `targetKind eq "block"` branch) that reaches
# an eligible instance (ParamFieldsUsable) evaluates each virtualized
# parameter's own argument expression in *virtual field form* instead of a
# single register (TryFields, via the shared CallArgs helper both the
# self-tail and ordinary call paths use): a `ref` to a binding this same
# caller's own `fn locals` already holds virtual (a local binding, or one
# of *this* function's own virtualized parameters, forwarded unchanged --
# read for free, already evaluated), or a `call` recognized the same way
# VirtualValue already recognizes one (a literal, or a forwarding call to
# another companion instance) -- reusing Call's own existing WANTVIRTUAL
# machinery rather than duplicating it. hir::escape.tcl (its Eligible pass)
# only ever proves a parameter position virtualizable when every one of its
# exact callers' arguments already has one of exactly these two shapes, so
# TryFields finding neither at such a call site is a lowering/analysis
# inconsistency (NATIVE BUG), never a legitimate fallback path to build.
#
# This is why hir/escape.tcl calls its own growth pass a *pure value-shape*
# fact and its shrink pass *eligibility* as two separate questions (see
# that file's header): the caller-argument classification above never
# depends on whether a slot's containing function *chose* to virtualize it
# (that would be circular for a multi-hop forwarding chain), only on
# whether the value it holds provably has that shape -- exactly the
# soundness discipline the milestone's #41 requires.
#
# Self-tail calls (a loop backedge, `tail`/`tailenv`) are not a special
# case: CallArgs applies the identical field-expansion to a self-tail
# call's own arguments when the *current* function is itself a `fields`/
# `fieldscompanion` variant (checked via `fn locals`, exactly like the
# existing RawParams raw-argument case already does) -- so builder/state
# self-tail loops thread their aggregate's fields through registers across
# iterations, never reboxing into a List on the backedge (the milestone's
# #25).
#
# Field-expansion is never attempted for a call whose target instance has a
# hir/traversal.tcl TraversalPlan (ParamFieldsUsable): a plan's hidden
# extra byte-position parameter is a *different* internal-ABI extension of
# the same instance, and this milestone does not attempt to compose the
# two (no stdlib workload needs both: a TraversalPlan only ever applies to
# a String-scanning `peek`-shaped function, never a List-record accessor).
# Block virtualization (this same file's previous section) is similarly
# not composed with this one: a virtualized Block's own direct-call
# arguments (FlattenedVirtualCall) are still evaluated as ordinary single
# registers, even when one of them would itself be List-parameter-
# eligible -- an intentionally narrow scope, not a soundness gap (the
# canonical, materializing path is always still correct and always still
# available).
#
# GC rooting needs no new mechanism, for exactly the reason "Scalar
# replacement" above already gives: every field register -- whether a
# `fields` variant's own parameter, or a forwarded value read out of an
# already-rooted `fn locals` entry -- is an ordinary tagged NIR register,
# stored to its own shadow-stack slot on definition by codegen's `def`
# regardless of what produced it. Each field's *own* liveness (not the
# List wrapper's, which no longer exists) governs how long it stays rooted,
# so a field that dies before a sibling field does is not kept live merely
# because the sibling still is (the milestone's #59) -- an actual
# improvement over the canonical path, where the whole List object (and so
# every field reachable from it) stays rooted for as long as the List
# reference itself does.
#
# -param-aggregate-opt 0 (or BOTLISH_NATIVE_PARAM_AGGREGATE_OPT=0) disables
# this section's parameter/result-boundary virtualization independently of
# -escape-opt (which still separately controls local/remote scalar
# replacement and this section together): hir::escape::analyze's own
# growth pass for parameters is simply skipped, so no `fields`/
# `fieldscompanion` variant is ever built and every call goes through the
# canonical function exactly as before -- for differential testing against
# the unoptimized baseline.

# ---------------------------------------------------------------------------
# String regions
#
# A temporary substring (`substring(text, a, b)`) hir/stringregion.tcl proves
# is consumed only by `==` (resolving to `streq`: both operands statically
# str-typed) or `length` may be represented, instead of an allocated String,
# as a "StringRegion": the three registers (base text, start, end) an
# ordinary `substr` call would have validated and copied from -- kept as-is,
# never materialized. This is the String analogue of the "Representation"
# section above (RawOf/TaggedOf for Int) and the "Scalar replacement"
# section (virtual fields for List): the same *demand-driven* discipline,
# just for a third semantic value's optimizer-internal representation.
# `StringRegion` is never a Botlish source type (no `StringSlice`, `Span`, or
# borrowed-String type is introduced): it is purely an optimizer
# representation of an ordinary, already-immutable String value, valid only
# while lowering can preserve the exact observable behavior a materialized
# String would have had (see hir/stringregion.tcl's header for the full
# recognition rules).
#
# Two shapes (hir/stringregion.tcl's Classify):
#
#   local    a plain `substring(text, a, b)` call, or a String literal,
#            bound to a local binding every reference to which is a
#            supported consumer (Bind evaluates it once, as a region, via
#            `Expr fn ... region`; Ref hands its fields straight to the one
#            or two consumers that use it -- there is never a "materialize
#            it after all" path for such a binding, because
#            hir::stringregion.tcl only ever calls one virtual if *every*
#            reference already qualifies).
#   remote   the same, but the region is *returned* by an exact, direct call
#            to another instance whose own result is itself fully
#            region-producing (`peek`-shaped helpers: a String-returning
#            function whose every exit is a substring call or a literal).
#            Exactly like escape's remote List case, this needs a second NIR
#            function alongside the instance's ordinary one -- a *region
#            companion* (RegionCompanionFunction), signature `results=3`,
#            terminated by `retmulti`, reached only through
#            `callmulti`/`callenvmulti`. The instance's ordinary, canonical
#            String-returning function is still unconditionally emitted (a
#            generic/indirect caller, or a caller with a mixed-use binding
#            hir::stringregion.tcl declined to virtualize, keeps calling it,
#            unaffected).
#
# A region is also produced *inline*, with no binding at all, when a
# region-producing call is a direct operand of `==`/`length`
# (`peek(text, i) == "\""`): Call's `wantRegion` asks the operand expression
# for region form directly, exactly as NativeCall's raw-eligible operands
# ask Expr for `raw` -- there is no separate "materialize, then compare"
# step, and no need to check "every reference", since an inline operand has
# exactly one use by construction.
#
# Consumers (deliberately narrow -- only what the corpus this milestone
# targets, CSV scanning, actually exercises): `==` between two statically
# str-typed operands lowers to `regioneq` (a region's three registers plus
# the other, ordinary String register) instead of `streq` when one operand
# is region-eligible; `length` of a region-eligible operand lowers to a
# plain `isub end start` (exact by construction: Botlish substring bounds
# are already Unicode-scalar/character indices, not bytes, so a region's
# character count is always end-start, with no ASCII/byte-length caveat
# needed). Hashing a region is not implemented (not exercised by the
# corpus this milestone measured; see hir/stringregion.tcl and the
# milestone's own guidance against implementing a consumer merely because
# it is theoretically possible). Any other use (concat, storage, return, a
# generic/indirect call) is never virtualized in the first place
# (hir::stringregion::Bindings), so it simply materializes exactly as
# before -- once, at the ordinary point Bind/Call already evaluate it.
#
# A "remote" region whose call target is itself hir::blockescape.tcl-virtual
# (a nonescaping local Block, called only through statically known direct
# calls -- see the "Block virtualization" section above) is not reached
# through this section's own RegionCompanionFunction/`callenvmulti` at all:
# Call's early FlattenedVirtualCall/FlattenedVirtualRegionCall dispatch
# resolves it first, straight to the callee's *internal* region companion
# (InternalRegionCompanionFunction), with no closure ever built and no
# environment register ever read. RegionCompanionFunction and this
# section's own analysis are otherwise completely unaware of Block
# virtualization -- hir::stringregion.tcl classifies a `remote` region by
# instance alone, never by how the callee happens to be represented at
# lowering time -- so hir::blockescape.tcl's own header, not this section,
# is where that composition is documented in full.
#
# Bounds checking (#18 of this milestone): a `substring`-shaped region still
# validates its bounds -- RegionCheck (`op regioncheck`), emitted at exactly
# the point in program order the ordinary `substr` call would have run --
# exactly as `rt_substr` does, just without allocating or copying. Once
# validated, the region's registers stay valid for as long as they are live:
# Strings are immutable, so nothing can invalidate a bound already proven.
# `length`/`regioneq`, downstream of a `regioncheck` (or of a String
# literal's always-valid trivial region), never re-check.
#
# GC rooting needs no new mechanism: a region's three fields are ordinary
# tagged NIR registers (the base String, and two tagged Ints), each already
# stored to its own shadow-stack slot on definition by codegen's `def`
# (native/src/codegen/clif.rs), exactly as any other register is -- the base
# String stays rooted for as long as its register is live, which is exactly
# as long as the region itself is (see #33 of this milestone: no separate
# "keep the source alive" mechanism is needed, or possible to get wrong,
# because there is no mechanism at all beyond the ordinary one every
# register already has).
#
# Large-source retention (#15/#42 of this milestone): a virtual region never
# escapes as a semantic String -- hir::stringregion.tcl only recognizes a
# binding virtual when *every* reference is `==`/`length`, so a region is
# never itself the thing a caller stores or returns. A binding that *is*
# stored or returned is, by that same rule, never virtualized: it
# materializes (an ordinary, independent String, unrelated in size to its
# source) at the one point it is bound, exactly as it always did. There is
# therefore no new way for a large source String to be retained past a
# temporary computation's end: the only registers a region keeps live are
# the ones an equivalent unoptimized program would already keep live for the
# length of the same temporary computation (the source text itself, plus two
# Ints), never longer.
#
# -string-region-opt 0 (or BOTLISH_NATIVE_STRING_REGION_OPT=0) disables this
# analysis and lowering outright, independent of -escape-opt/-repr-opt, for
# differential (semantic and allocation) testing against the unoptimized
# baseline.

# ---------------------------------------------------------------------------
# String traversal
#
# A provably forward, +1-per-iteration character scan (hir/traversal.tcl's
# TraversalPlan) carries its physical UTF-8 byte position across the self-
# tail loop as one *hidden* extra function parameter, instead of every
# access re-locating the semantic character index from byte 0 (rt_substr's/
# rt_str_region_eq's non-ASCII paths). This is the same "representation, not
# semantics" discipline as the "Representation", "Scalar replacement" and
# "String regions" sections above: no Botlish String, index, or
# hir/specialize.tcl instance changes meaning; only how a proven-forward
# scan's execution *carries state across iterations* changes.
#
# The hidden parameter
# ---------------------
# An instance hir::traversal.tcl gives a TraversalPlan gets one extra
# register beyond its ordinary (source) parameters -- allocated right after
# them (`[dict get $plan byteParamIndex]`, always the source parameter
# count), so it becomes the function's last declared parameter. It holds an
# ordinary *tagged* Int (never raw/untagged: unlike RawParams' whole-function
# raw parameters, this never needs the "Representation" section's
# raw-across-backedge machinery at all -- a traversal's carried byte offset
# is always a small Int, so boxing/unboxing it costs nothing beyond a tag
# bit, value.rs's make_small/small_of being pure bit operations with no
# allocation). Concretely:
#
#   func F "clean_from" params=4 ...   ; the 4th slot (index 3) is the
#                                       ; hidden byte position, never a
#                                       ; Botlish `clean_from` parameter
#
# This reuses exactly the mechanism that already carries a self-tail loop's
# ordinary parameters across its `tail`/`tailenv` backedge (ordinary NIR
# registers rebound by Tail's argument list): the hidden parameter is not a
# new codegen concept, just one more register in that same list (see
# AppendTraversalArg below) -- native/src/codegen/clif.rs needs no change at
# all, since its prologue, prologue-to-body jump and Tail lowering are
# already generic in the number of declared parameters (native/src/nir.rs's
# `f.params`, read from this function's own header).
#
# Recognizing an access: TraversalAccess
# ----------------------------------------
# hir/traversal.tcl's `accesses` names the exact call expressions -- each a
# call forwarding to a recognized character-accessor instance (`peek`-shaped:
# hir/traversal.tcl's CharAccessorShape; see that module's header for why a
# *direct* `substring(text, i, i+1)` call is deliberately not recognized,
# even though it is structurally simpler) -- that read the scanned String at
# the loop's own induction index. Call (below) checks this *before* any of
# its other dispatch (a native call, a block call, wantRegion/wantVirtual): when the
# current function has an active TraversalPlan and E is one of its
# recognized accesses, TraversalAccess lowers it directly, inline, in the
# *caller's* own function body -- never emitting a `call`/`callenv` to
# `peek`'s own compiled function at all for this one call site (the
# smallest sound mechanism per the milestone's #17-18 option A: no new
# interprocedural ABI, no companion call, `peek`'s own canonical function
# still unconditionally emitted and still correct for every other caller).
#
# TraversalAccess reads the access call's own two argument expressions for
# the scanned String and the index (`Expr fn ... tagged`: ordinary
# expression lowering, so a raw-declared index parameter is transparently
# reboxed by the existing TaggedOf machinery, exactly as any other tagged
# consumer of it already is) and emits, matching `peek`'s own semantics
# exactly (#30 of the milestone: EOF and bounds behavior unchanged):
#
#   len = strlen(text)
#   if index >= len:
#       result, nextByte = "", byteReg            ; unchanged: peek's own
#                                                   ; EOF branch never reads
#                                                   ; a byte position either
#   else:
#       result = decodecharat(text, byteReg)       ; op DecodeCharAt
#       nextByte = byteReg + strbytelen(result)     ; op StrByteLen, iadd
#
# joined (the same shared-register `move`-then-`jump` idiom If already
# uses) into RESULT (the access's own ordinary tagged return value -- the
# one-character String a caller like `clean_char` receives exactly as
# before: #10/#20 of the milestone, character materialization is
# unaffected) and the function's new current byte position, saved in `fn
# traversalByteReg` for whichever `tail`/`tailenv`/(exotic) `call` reads it
# next.
#
# Only ever recognized when the result is wanted tagged (never region/
# virtual: TraversalAccess is skipped, falling back to ordinary lowering,
# if `want` is anything else -- #23's conservative fallback; the corpus
# this milestone targets never asks for one at a recognized access site,
# since hir/traversal.tcl only looks inside a self-tail call's own
# argument subtree, never a `==`/`length` operand position).
#
# Threading the hidden parameter across calls: AppendTraversalArg
# ------------------------------------------------------------------
# Two call sites ever need the hidden parameter's *value*, both inside
# Call's existing block-call dispatch:
#
#   self-tail (`tail`/`tailenv`)   the function's own current
#                                   `fn traversalByteReg` (TraversalAccess
#                                   already advanced it, earlier in this
#                                   same statement's argument evaluation,
#                                   before the backedge is emitted)
#   ordinary direct call            a literal `int 0` -- sound because
#   (`call`/`callenv`)              hir/traversal.tcl's ZeroStart already
#                                   proved *every* such caller passes
#                                   literal 0 for the scanned index itself,
#                                   so byte offset 0 is exactly where this
#                                   call's scan begins
#
# A generic/indirect call (`callvalue`, `rt_call_value`) can only ever
# reach a *generic* instance (native/lower.tcl's own header: "Block values
# are always generic instances"), and hir/traversal.tcl analyzes each used
# instance -- generic or specialized -- independently from its own actual
# callers, so this never needs special handling: a generic instance either
# independently earns its own TraversalPlan (and every one of *its* actual
# callers, direct calls only, already satisfies ZeroStart) or it does not,
# and callvalue simply never supplies the hidden parameter because no
# generic-entry caller (rt_call_value's fixed ABI) ever could -- so a
# TraversalPlan is never given to an instance reachable that way in the
# first place (ZeroStart only examines hir::specialize's own direct `calls`
# edges, never a value-call site, so an instance with no direct callers at
# all simply never proves ZeroStart and is never optimized).
#
# Interaction with scalar replacement / String regions
# -------------------------------------------------------
# hir/traversal.tcl itself excludes any instance hir::escape.tcl or
# hir::stringregion.tcl also wants a companion function for, so a
# TraversalPlan instance is only ever reached through the ordinary call/tail
# ABI: CompanionFunction and RegionCompanionFunction never need the hidden
# parameter at all (their own `fn traversal` is always ""), and only
# Function's prologue ever allocates it.
#
# -string-traversal-opt 0 (or BOTLISH_NATIVE_STRING_TRAVERSAL_OPT=0)
# disables this analysis and lowering outright, independent of every other
# -*-opt flag, for differential (semantic and instrumentation) testing
# against the unoptimized baseline.

# ---------------------------------------------------------------------------
# Entry point

# The NIR of the program-mode HIR program HIR. Options:
#   -specialize 1|0    specialize functions (default 1, unless the
#                      environment variable BOTLISH_NATIVE_SPECIALIZE is 0)
#   -escape-opt 1|0    scalar-replace fixed-shape immutable List aggregates
#                      whose identity hir/escape.tcl proves is never
#                      observed (default 1, unless the environment variable
#                      BOTLISH_NATIVE_ESCAPE_OPT is 0; see the "Scalar
#                      replacement" section above)
#   -param-aggregate-opt 1|0
#                      also virtualize a fixed-shape List parameter across
#                      an exact closed call boundary (default 1, unless the
#                      environment variable BOTLISH_NATIVE_PARAM_AGGREGATE_OPT
#                      is 0; see the "Parameter virtualization" section
#                      above; independent of -escape-opt, which still
#                      separately controls local/remote scalar replacement)
#   -string-region-opt 1|0
#                      represent a temporary substring hir/stringregion.tcl
#                      proves is consumed only by `==`/`length` as a
#                      StringRegion instead of an allocated String (default
#                      1, unless the environment variable
#                      BOTLISH_NATIVE_STRING_REGION_OPT is 0; see the
#                      "String regions" section above)
#   -call-facts-opt 1|0
#                      propagate value facts through exact closed calls
#                      (default 1; BOTLISH_NATIVE_CALL_FACTS_OPT=0 disables
#                      the new propagation for differential testing)
#   -string-traversal-opt 1|0
#                      carry a provably forward, +1-per-iteration character
#                      scan's physical UTF-8 byte position across its self-
#                      tail loop (hir/traversal.tcl) instead of relocating it
#                      from byte 0 on every access (default 1, unless the
#                      environment variable
#                      BOTLISH_NATIVE_STRING_TRAVERSAL_OPT is 0; see the
#                      "String traversal" section above)
# Returns a dict:
#   text        the NIR program
#   functions   list of dicts, in id order: {id name block instance label
#               generic envless selfTailCalls calls blockers guards
#               knownErrorGuards}: blockers counts the region's
#               representation blockers, guards the kind checks emitted for
#               them, knownErrorGuards the checks that always fail
#   statistics  {functions N generic N specialized N blockers N guards N
#               perFunction {NAME {generic 0|1 specializations N} ...}}
#   specialization  the hir::specialize analysis
proc native::lower::program {hirProgram args} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable selfTail
    variable unproven
    variable cells
    variable envless
    variable captureLists
    variable pending
    variable usedNatives
    variable ranges
    variable callFactsOpt
    variable reprOpt
    variable escape
    variable escapeOpt
    variable paramAggregateOpt
    variable blockescape
    variable blockEscapeOpt
    variable stringregion
    variable stringRegionOpt
    variable traversal
    variable traversalOpt
    variable tinyLeafInlineOpt
    variable leafEligible

    set default [expr {[info exists ::env(BOTLISH_NATIVE_SPECIALIZE)]
        && $::env(BOTLISH_NATIVE_SPECIALIZE) eq "0" ? 0 : 1}]
    set reprDefault [expr {[info exists ::env(BOTLISH_NATIVE_REPR_OPT)]
        && $::env(BOTLISH_NATIVE_REPR_OPT) eq "0" ? 0 : 1}]
    set escapeDefault [expr {[info exists ::env(BOTLISH_NATIVE_ESCAPE_OPT)]
        && $::env(BOTLISH_NATIVE_ESCAPE_OPT) eq "0" ? 0 : 1}]
    set paramAggregateDefault [expr {[info exists ::env(BOTLISH_NATIVE_PARAM_AGGREGATE_OPT)]
        && $::env(BOTLISH_NATIVE_PARAM_AGGREGATE_OPT) eq "0" ? 0 : 1}]
    set blockEscapeDefault [expr {[info exists ::env(BOTLISH_NATIVE_BLOCK_ESCAPE_OPT)]
        && $::env(BOTLISH_NATIVE_BLOCK_ESCAPE_OPT) eq "0" ? 0 : 1}]
    set stringRegionDefault [expr {[info exists ::env(BOTLISH_NATIVE_STRING_REGION_OPT)]
        && $::env(BOTLISH_NATIVE_STRING_REGION_OPT) eq "0" ? 0 : 1}]
    set callFactsDefault [expr {[info exists ::env(BOTLISH_NATIVE_CALL_FACTS_OPT)]
        && $::env(BOTLISH_NATIVE_CALL_FACTS_OPT) eq "0" ? 0 : 1}]
    set callEffectsDefault [expr {[info exists ::env(BOTLISH_NATIVE_CALL_EFFECTS_OPT)]
        && $::env(BOTLISH_NATIVE_CALL_EFFECTS_OPT) eq "0" ? 0 : 1}]
    set traversalDefault [expr {[info exists ::env(BOTLISH_NATIVE_STRING_TRAVERSAL_OPT)]
        && $::env(BOTLISH_NATIVE_STRING_TRAVERSAL_OPT) eq "0" ? 0 : 1}]
    # Default *on* (TINY-LEAF-DEFAULT-ON.md), matching every other -*-opt
    # flag above: TINY-EXACT-LEAF-INLINING.md's own milestone defaulted this
    # off because a wide swath of *pre-existing* tests located a named
    # function's own compiled body via its quoted name (FunctionBody-style
    # helpers throughout tests/native-*.test) and never expected a plain
    # top-level `fn f(x): ...` with one caller to stop being separately
    # emitted once inlining removed its last caller -- a test-methodology
    # gap, not an optimizer defect (that milestone's own extensive
    # differential/GC-stress/determinism evidence already supported
    # default-on). TINY-LEAF-DEFAULT-ON.md's own milestone adapted every
    # affected test to its real intent (explicit -tiny-leaf-inline-opt 0 for
    # a genuine standalone-lowering inspection, inspecting the surviving
    # optimized caller where that is what the test actually meant, or a
    # tcltest constraint where the assertion is genuinely configuration-
    # specific) and made this the supported normal configuration. Explicit
    # -tiny-leaf-inline-opt 0 (or BOTLISH_NATIVE_TINY_LEAF_INLINE_OPT=0)
    # still disables it completely, for standalone-lowering tests,
    # differential comparison, and debugging.
    set tinyLeafInlineDefault [expr {[info exists ::env(BOTLISH_NATIVE_TINY_LEAF_INLINE_OPT)]
        && $::env(BOTLISH_NATIVE_TINY_LEAF_INLINE_OPT) eq "0" ? 0 : 1}]
    set options [hir::Options native::lower::program \
        [list -specialize $default -repr-opt $reprDefault -escape-opt $escapeDefault \
            -param-aggregate-opt $paramAggregateDefault -block-escape-opt $blockEscapeDefault \
            -string-region-opt $stringRegionDefault -string-traversal-opt $traversalDefault \
            -call-facts-opt $callFactsDefault -call-effects-opt $callEffectsDefault \
            -tiny-leaf-inline-opt $tinyLeafInlineDefault] $args]
    if {[hir::mode $hirProgram] ne "program"} {
        throw {NATIVE UNSUPPORTED sequence-mode} \
            "native lowering: only program-mode HIR can be compiled (sequence mode runs in an unknown environment)"
    }
    variable errorIds
    set errorIds [dict create]
    set nextErrorId 1
    foreach name [hir::errorDecls $hirProgram] {
        dict set errorIds $name $nextErrorId
        incr nextErrorId
    }
    set baseHir $hirProgram
    set hir $hirProgram
    set reprOpt [dict get $options -repr-opt]
    set callFactsOpt [dict get $options -call-facts-opt]
    set callEffectsOpt [dict get $options -call-effects-opt]
    set escapeOpt [dict get $options -escape-opt]
    set paramAggregateOpt [dict get $options -param-aggregate-opt]
    set blockEscapeOpt [dict get $options -block-escape-opt]
    set stringRegionOpt [dict get $options -string-region-opt]
    set traversalOpt [dict get $options -string-traversal-opt]
    set tinyLeafInlineOpt [dict get $options -tiny-leaf-inline-opt]
    set leafEligible [dict create]
    set spec [hir::specialize::analyze $hirProgram -specialize [dict get $options -specialize] \
        -call-facts-opt [dict get $options -call-facts-opt]]
    set ranges [hir::range::analyze $hirProgram $spec [dict get $options -call-facts-opt]]
    set escape [expr {$escapeOpt ? [hir::escape::analyze $hirProgram $spec $paramAggregateOpt]
        : [dict create arity {} wants {} virtual {} paramVirtual {}]}]
    set stringregion [expr {$stringRegionOpt ? [hir::stringregion::analyze $hirProgram $spec]
        : [dict create regionOf {} wants {} virtual {}]}]
    # hir::blockescape.tcl and hir::stringregion.tcl are now independent
    # analyses (composed only here, at lowering time -- see native/lower
    # .tcl's "Block virtualization" and "String regions" sections): a
    # candidate B whose result some caller asks for in region form is no
    # longer declined outright. Call's own dispatch (FlattenedVirtualCall/
    # FlattenedVirtualRegionCall) resolves, per call site, whether the
    # ordinary capture-explicit internal variant or the capture-explicit
    # *region companion* internal variant is the one actually demanded, so
    # this ordering (stringregion before blockescape) is no longer a
    # dependency -- only kept for determinism/readability.
    set blockescape [expr {$blockEscapeOpt ? [hir::blockescape::analyze $hirProgram $spec]
        : [dict create virtual {} wants {} flatCaptures {}]}]
    set traversal [expr {$traversalOpt ? [hir::traversal::analyze $hirProgram $spec $stringregion $escape]
        : [dict create plans {}]}]
    set context [dict get $spec context]
    set selfTail [dict get $context selfTails]
    set unproven [dict get $context unproven]
    set cells [dict get $context cells]
    set envless [dict get $context envless]
    set captureLists [dict create]
    set usedNatives {}
    foreach e [dict keys [dict get $context exprs]] {
        if {$e ne "program" && $e ni $envless} {
            dict set captureLists $e [CaptureList $e]
        }
    }
    # A block instance hir::blockescape.tcl proved eligible for de-closure
    # conversion (see native/lower.tcl's "Block virtualization" section)
    # uses its *flattened* capture list -- possibly wider than its own
    # structural captures (a captured, itself-eligible candidate is
    # replaced by that candidate's own flattened captures) -- as ordinary
    # trailing parameters of its internal variant, in place of the
    # structural CaptureList above.
    foreach pair [hir::blockescape::wantedInstances $hirProgram $spec $blockescape] {
        lassign $pair wantedId label
        set wantedBlock [dict get [hir::specialize::instance $spec $wantedId] block]
        dict set captureLists $wantedBlock [hir::blockescape::captures $blockescape $wantedId]
    }

    set functions [dict create]
    set pending [list [list [dict get $spec keys program] canonical]]
    while {$pending ne ""} {
        set pending [lassign $pending item]
        lassign $item id mode
        set key [Key $id $mode]
        if {[dict exists $functions $key]} {
            continue
        }
        switch -- $mode {
            canonical       { set lowered [Function $id] }
            companion       { set lowered [CompanionFunction $id] }
            region          { set lowered [RegionCompanionFunction $id] }
            internal        { set lowered [InternalFunction $id] }
            internalregion  { set lowered [InternalRegionCompanionFunction $id] }
            fields          { set lowered [FieldsFunction $id] }
            fieldscompanion { set lowered [FieldsCompanionFunction $id] }
        }
        dict set functions $key $lowered
    }
    set hir $baseHir

    # Function ids in program order: a companion (List or String-region)
    # right after its instance's canonical function (the order between the
    # two is otherwise arbitrary; keeping it deterministic is all that
    # matters here).
    set order [lmap key [dict keys $functions] {
        lassign [Unkey $key] id mode
        set block [dict get $spec instances $id block]
        list [expr {$block eq "program" ? 0 : [dict get $context positions $block]}] \
            [string range $id 1 end] \
            [dict get {canonical 0 companion 1 region 1 internal 1 internalregion 1 fields 1 fieldscompanion 1} $mode] $key
    }]
    set order [lmap entry [lsort -integer -index 0 [lsort -integer -index 1 [lsort -integer -index 2 $order]]] {
        lindex $entry 3
    }]
    set map {}
    set index 0
    foreach key $order {
        lassign [Unkey $key] id mode
        lappend map [Placeholder $id $mode] $index
        incr index
    }
    set texts {}
    set infos {}
    foreach key $order {
        lassign [dict get $functions $key] text info
        lappend texts [string map $map $text]
        lappend infos [string map $map $info]
    }

    set header [list "nir 1 call-effects=$callEffectsOpt"]
    foreach name [lsort $usedNatives] {
        set meta [core::native::metadata $name]
        set kinds [lmap type [dict get $meta paramTypes] {
            expr {$type eq "any" ? "any" : [core::type::base $type]}
        }]
        lappend header "native [Quote $name] arity=[dict get $meta arity] params=[Quote $kinds] impl=[NativeImpl $name]"
    }
    set text "[join $header \n]\n\n[join $texts \n\n]\n"
    return [dict create text $text functions $infos statistics [Statistics $infos] \
        specialization $spec]
}

# Code-size and guard statistics of the lowered functions INFOS.
proc native::lower::Statistics {infos} {
    set perFunction [dict create]
    set generic 0
    set specialized 0
    set guardCount 0
    set blockerCount 0
    set rawUnboxes 0
    set rawBoxes 0
    set rawArith 0
    set rawCompare 0
    foreach info $infos {
        incr guardCount [dict get $info guards]
        incr blockerCount [dict get $info blockers]
        incr rawUnboxes [dict get $info rawUnboxes]
        incr rawBoxes [dict get $info rawBoxes]
        incr rawArith [dict get $info rawArith]
        incr rawCompare [dict get $info rawCompare]
        if {[dict get $info block] eq "program"} {
            continue
        }
        set name [dict get $info name]
        if {$name eq ""} {
            set name "block [dict get $info block]"
        }
        if {![dict exists $perFunction $name]} {
            dict set perFunction $name [dict create generic 0 specializations 0]
        }
        if {[dict get $info generic]} {
            incr generic
            dict set perFunction $name generic 1
        } else {
            incr specialized
            dict set perFunction $name specializations \
                [expr {[dict get $perFunction $name specializations] + 1}]
        }
    }
    return [dict create functions [llength $infos] generic $generic specialized $specialized \
        blockers $blockerCount guards $guardCount rawUnboxes $rawUnboxes rawBoxes $rawBoxes \
        rawArith $rawArith rawCompare $rawCompare perFunction $perFunction]
}

# ---------------------------------------------------------------------------
# Program facts (from HIR and hir::aot)

# guards: {OPERATION OPERAND} -> required type, for every representation
# blocker of the region analysis REGION; knownErrors: {OPERATION OPERAND} ->
# error kind.
proc native::lower::CollectChecks {region} {
    variable guards
    variable knownErrors
    set guards [dict create]
    set knownErrors [dict create]
    foreach blocker [dict get $region blockers] {
        switch -- [dict get $blocker class] {
            representation {
                if {[dict get $blocker kind] eq "UnprovenRefinement"} {
                    Unsupported [dict get $blocker expr] "refinement evidence" \
                        "the operation needs [core::type::show [dict get $blocker requires]]; named types and evidence are not supported natively"
                }
                dict set guards [list [dict get $blocker operation] [dict get $blocker expr]] \
                    [dict get $blocker requires]
            }
            semantic {
                set kind [dict get $blocker kind]
                if {$kind in {DynamicBinding UnresolvedControl}} {
                    Unsupported [dict get $blocker expr] $kind [dict get $blocker message]
                }
            }
        }
    }
    foreach fact [dict get $region facts] {
        if {[dict get $fact kind] eq "known-error" && [dict exists $fact operand]} {
            dict set knownErrors [list [dict get $fact expr] [dict get $fact operand]] \
                [dict get $fact error]
        }
    }
}

# The bindings closure E stores, in order: its captures, except bindings
# whose value is an environment-free function's constant closure and E's own
# function binding (read through self).
proc native::lower::CaptureList {e} {
    variable hir
    set result {}
    foreach b [hir::get $hir $e captures] {
        switch -- [BindingAccess $b $e] {
            fnvalue - self {}
            default { lappend result $b }
        }
    }
    return $result
}

# How code in the function of block E (or "program") reaches binding B from
# an enclosing invocation: fnvalue, cell, self or value.
proc native::lower::BindingAccess {b e} {
    variable hir
    variable cells
    variable envless
    if {[dict exists $cells $b]} {
        return cell
    }
    set bound [hir::aot::BoundBlock $hir $b]
    if {$bound ne "" && $bound in $envless} {
        return fnvalue
    }
    if {$bound ne "" && $bound eq $e} {
        return self
    }
    return value
}

# The NIR function id of instance ID: a placeholder that program replaces
# with the final id. The instance's ordinary (canonical, List-returning)
# function will be lowered.
proc native::lower::FunctionRef {id} {
    variable pending
    lappend pending [list $id canonical]
    return [Placeholder $id canonical]
}

# Like FunctionRef, for instance ID's scalar-replacement companion function
# (see the "Scalar replacement" section above): callers must already know,
# from hir::escape::wants/arity, that this instance has one.
proc native::lower::CompanionRef {id} {
    variable pending
    lappend pending [list $id companion]
    return [Placeholder $id companion]
}

# Like CompanionRef, for instance ID's *region* companion function (see the
# "String regions" section above): callers must already know, from
# hir::stringregion::wants, that this instance has one.
proc native::lower::RegionCompanionRef {id} {
    variable pending
    lappend pending [list $id region]
    return [Placeholder $id region]
}

# Like CompanionRef, for instance ID's *internal* (capture-explicit) variant
# (see the "Block virtualization" section above): callers must already
# know, from hir::blockescape::virtual, that some binding demands this
# instance's internal variant.
proc native::lower::InternalRef {id} {
    variable pending
    lappend pending [list $id internal]
    return [Placeholder $id internal]
}

# Like InternalRef, for instance ID's *internal region companion* (see the
# "Block virtualization" and "String regions" sections above): the
# composition this milestone adds -- a capture-explicit calling convention
# (no environment register) together with a StringRegion (base, start, end)
# multi-value result, instead of either alone. Callers must already know,
# from hir::blockescape::virtual (ID is some binding's flattened-capture
# target) AND hir::stringregion::wants (some caller demands ID's result in
# region form), that this variant is needed.
proc native::lower::InternalRegionCompanionRef {id} {
    variable pending
    lappend pending [list $id internalregion]
    return [Placeholder $id internalregion]
}

# Like FunctionRef, for instance ID's `fields` variant (see the "Parameter
# virtualization" section above): callers must already know, from
# ParamFieldsUsable/hir::escape::paramWants, that this instance has one.
proc native::lower::FieldsRef {id} {
    variable pending
    lappend pending [list $id fields]
    return [Placeholder $id fields]
}

# Like FieldsRef, for instance ID's `fieldscompanion` variant (see the
# "Parameter virtualization" section above): callers must already know,
# from ParamFieldsUsable *and* hir::escape::arity, that this instance has
# one.
proc native::lower::FieldsCompanionRef {id} {
    variable pending
    lappend pending [list $id fieldscompanion]
    return [Placeholder $id fieldscompanion]
}

# The key `program`'s `functions` dict uses for instance ID's function of
# MODE (canonical or companion): also Placeholder's inner text, so a
# Placeholder's text and its functions-dict key always agree.
proc native::lower::Key {id mode} {
    return "$id.$mode"
}

# {ID MODE} from a Key/Placeholder text.
proc native::lower::Unkey {key} {
    return [split $key .]
}

proc native::lower::Placeholder {id {mode canonical}} {
    return "[format %c 1][Key $id $mode][format %c 2]"
}

# FunctionRef of the generic instance of block E.
proc native::lower::GenericRef {e} {
    variable baseHir
    variable spec
    set id [hir::specialize::genericInstance $baseHir $spec $e]
    if {$id eq ""} {
        throw {NATIVE BUG} "native lowering: no generic instance of block $e"
    }
    return [FunctionRef $id]
}

# 1 if any of INSTANCE's calls (ExprId -> target InstanceId) is a self-tail
# call (hir::aot::selfTailCalls, native::lower's own `selfTail` criterion for
# a NIR `tail`/`tailenv` backedge) that stays within instance ID itself: the
# only case a parameter's own register can benefit from staying raw across
# every iteration instead of round-tripping through box/unbox each time (see
# RawParams). A non-recursive function's proven-small parameter is already
# unboxed at most once per use by RawOf's cache; there is no backedge for a
# permanently-raw register to save anything on.
proc native::lower::HasSelfTailCall {id calls} {
    variable selfTail
    foreach {callExpr target} $calls {
        if {$target eq $id && [dict exists $selfTail $callExpr]} {
            return 1
        }
    }
    return 0
}

# 1|0 per parameter of instance ID's PARAMS: whether hir::range::analyze's
# fully-analyzed Range for it (hir/induction.tcl's equality-termination proof
# and/or hir/range.tcl's branch-derived narrowing, already folded into that
# Range by the time native::lower runs it) fits the small-Int representation
# for the *entire* function, not just one local use -- exactly the fact that
# justifies making the parameter's own register raw from the prologue
# onward (see clif.rs's per-parameter prologue unboxing) rather than merely
# unboxing a local temporary. Only asked for a self-tail-recursive instance
# (HasSelfTailCall): see its comment for why a non-recursive one gets no
# benefit from this.
proc native::lower::RawParams {id instance params} {
    variable reprOpt
    variable ranges
    set n [llength $params]
    if {!$reprOpt || !$n || ![HasSelfTailCall $id [dict get $instance calls]]} {
        return [lrepeat $n 0]
    }
    set paramRanges [dict get [dict get $ranges instances $id] params]
    return [lmap r $paramRanges {hir::range::fitsSmall $r}]
}

# ---------------------------------------------------------------------------
# Functions

# Lowers the function of instance ID (hir/specialize.tcl). Returns
# {TEXT INFO}.
proc native::lower::Function {id} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable envless
    variable selfTail
    variable captureLists
    variable currentInstance
    variable ranges
    variable traversal
    set currentInstance $id
    set instance [hir::specialize::instance $spec $id]
    set region [dict get $instance block]
    set hir [hir::specialize::view $baseHir $spec $id]
    set analysis [hir::aot::analyzeRegion $hir $region $context]
    CollectChecks $analysis
    set blockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    set fn [dict create region $region instance $id targets [dict get $instance calls] \
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 0 \
        traversal "" traversalByteReg ""]
    if {$region eq "program"} {
        set name <program>
        set params {}
        set env 0
        set scope [hir::top $hir]
        set body [hir::roots $hir]
    } else {
        set name [hir::aot::BlockName $hir $region]
        set params [hir::get $hir $region params]
        set env [expr {$region ni $envless}]
        set scope [hir::get $hir $region bodyScope]
        set body [hir::get $hir $region body]
    }
    set rawParams [RawParams $id $instance $params]
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            dict set fn locals $b [list reg $r]
        }
    }
    set extraParams 0
    if {$region ne "program"} {
        set plan [hir::traversal::plan $traversal $id]
        if {$plan ne ""} {
            dict set fn traversal $plan
            dict set fn traversalByteReg [NewReg fn]
            set extraParams 1
        }
    }
    # Module scopes share this one program function. Deferred references from
    # module functions need their cells before initializers and closures run.
    if {$region eq "program" && [dict exists $hir modules]} {
        dict for {moduleName moduleScope} [dict get $hir modules] {
            EnterScope fn $moduleScope
        }
    }
    EnterScope fn $scope
    set result [Sequence fn $body]
    if {$result ne "never"} {
        Emit fn "ret $result"
    }
    set pnames [lmap b $params {dict get [hir::binding $hir $b] name}]
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    # pnames: the parameter names as block error messages show them.
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]}]
    set head "func [Placeholder $id] [Quote $name] params=[expr {[llength $params] + $extraParams}] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key]"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    if {$region ne "program"} {
        append head " @$region"
    }
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id] name $name block $region instance $id \
        label [hir::specialize::label $spec $id] generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare]]
    return [list $text $info]
}

# Lowers the scalar-replacement companion function of instance ID (see the
# "Scalar replacement" section above): the same instance as Function, but
# ending every reachable exit in `retmulti` of its recognized construction's
# fields (hir::escape::classify) instead of materializing and `ret`ing a
# List. hir::escape::wants ID must already be true (its arity is this
# function's `results`). Returns {TEXT INFO}, in the same shape as Function.
proc native::lower::CompanionFunction {id} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable envless
    variable captureLists
    variable currentInstance
    variable escape
    set currentInstance $id
    set instance [hir::specialize::instance $spec $id]
    set region [dict get $instance block]
    set arity [hir::escape::arity $escape $id]
    if {$region eq "program" || $arity eq ""} {
        throw {NATIVE BUG} "native lowering: instance $id has no scalar-replacement companion"
    }
    set hir [hir::specialize::view $baseHir $spec $id]
    set analysis [hir::aot::analyzeRegion $hir $region $context]
    CollectChecks $analysis
    set blockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    set fn [dict create region $region instance $id targets [dict get $instance calls] \
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion $arity regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            dict set fn locals $b [list reg $r]
        }
    }
    EnterScope fn $scope
    if {$body eq ""} {
        throw {NATIVE BUG} "native lowering: companion of instance $id has an empty body"
    }
    set ok 1
    foreach e [lrange $body 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            set ok 0
            break
        }
    }
    if {$ok} {
        set fields [VirtualValue fn [lindex $body end] $arity]
        if {$fields ne "never"} {
            Emit fn "retmulti [join $fields { }]"
        }
    }
    set pnames [lmap b $params {dict get [hir::binding $hir $b] name}]
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]}]
    set head "func [Placeholder $id companion] [Quote $name] params=[llength $params] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key] results=$arity"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id companion] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (scalar)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare]]
    return [list $text $info]
}

# Lowers the region companion function of instance ID (see the "String
# regions" section above): the same instance as Function, but ending every
# reachable exit in `retmulti` of its region fields (base, start, end --
# hir::stringregion::classify) instead of materializing and `ret`ing a
# String. hir::stringregion::wants ID must already be true. Returns
# {TEXT INFO}, in the same shape as Function/CompanionFunction.
proc native::lower::RegionCompanionFunction {id} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable envless
    variable captureLists
    variable currentInstance
    variable stringregion
    set currentInstance $id
    set instance [hir::specialize::instance $spec $id]
    set region [dict get $instance block]
    if {$region eq "program" || ![hir::stringregion::wants $stringregion $id]} {
        throw {NATIVE BUG} "native lowering: instance $id has no string-region companion"
    }
    set hir [hir::specialize::view $baseHir $spec $id]
    set analysis [hir::aot::analyzeRegion $hir $region $context]
    CollectChecks $analysis
    set blockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    set fn [dict create region $region instance $id targets [dict get $instance calls] \
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 1 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            dict set fn locals $b [list reg $r]
        }
    }
    EnterScope fn $scope
    if {$body eq ""} {
        throw {NATIVE BUG} "native lowering: region companion of instance $id has an empty body"
    }
    set ok 1
    foreach e [lrange $body 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            set ok 0
            break
        }
    }
    if {$ok} {
        set fields [Expr fn [lindex $body end] region]
        if {$fields ne "never"} {
            Emit fn "retmulti [join $fields { }]"
        }
    }
    set pnames [lmap b $params {dict get [hir::binding $hir $b] name}]
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]}]
    set head "func [Placeholder $id region] [Quote $name] params=[llength $params] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key] results=3"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id region] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (region)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare]]
    return [list $text $info]
}

# Lowers the internal (capture-explicit) variant of instance ID's block (see
# the "Block virtualization" section above): the same instance and body as
# Function, except env=0 -- its capture bindings (native::lower::
# captureLists) are ordinary trailing parameters instead of an environment
# record, so every reference to one inside the body is just that
# parameter's register (Access finds it already in `fn locals`, exactly as
# an ordinary parameter, and never emits a `capture I` load). Only ever
# built for a block instance hir::blockescape::wants is true for; every
# capture hir::blockescape.tcl let through is a plain already-resolved
# value (never a forward-reference cell, never "self": see its header), so
# no other part of this function's lowering needs to change at all -- same
# guards, same known-error checks, same GC rooting (every parameter is
# rooted from the prologue exactly like any other, "Scalar replacement"'s
# reasoning applies unchanged), same completion-code handling. Returns
# {TEXT INFO}, in the same shape as Function.
proc native::lower::InternalFunction {id} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable envless
    variable captureLists
    variable currentInstance
    variable ranges
    variable traversal
    set currentInstance $id
    set instance [hir::specialize::instance $spec $id]
    set region [dict get $instance block]
    if {$region eq "program" || $region in $envless} {
        throw {NATIVE BUG} "native lowering: instance $id has no internal variant"
    }
    set hir [hir::specialize::view $baseHir $spec $id]
    set analysis [hir::aot::analyzeRegion $hir $region $context]
    CollectChecks $analysis
    set blockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    set fn [dict create region $region instance $id targets [dict get $instance calls] \
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            dict set fn locals $b [list reg $r]
        }
    }
    set captureBindings [dict get $captureLists $region]
    foreach b $captureBindings {
        dict set fn locals $b [list reg [NewReg fn]]
    }
    EnterScope fn $scope
    set result [Sequence fn $body]
    if {$result ne "never"} {
        Emit fn "ret $result"
    }
    set pnames [concat [lmap b $params {dict get [hir::binding $hir $b] name}] \
        [lmap b $captureBindings {dict get [hir::binding $hir $b] name}]]
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]}]
    set head "func [Placeholder $id internal] [Quote $name] params=[expr {[llength $params] + [llength $captureBindings]}] env=0 regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=0 instance=[Quote $key]"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id internal] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (internal)" generic [dict get $instance generic] \
        envless 1 selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare]]
    return [list $text $info]
}

# Lowers the internal *region companion* of instance ID (the composition
# this milestone adds): the same instance and body as InternalFunction
# (env=0, its capture bindings ordinary trailing parameters -- see that
# proc's own comment), except every reachable exit ends in `retmulti` of its
# region fields (hir::stringregion::classify), exactly like
# RegionCompanionFunction, instead of materializing and `ret`ing a String.
# Only ever built for a block instance BOTH hir::blockescape::wants (some
# binding demands its internal variant) AND hir::stringregion::wants (some
# caller demands its result in region form) hold for -- demand-driven, like
# every other variant here: native::lower::program's `pending` work list
# only ever builds this when some actual call site (Call's
# FlattenedVirtualRegionCall) asks for it. Reuses exactly the same
# `native::lower::captureLists` override InternalFunction does (the
# identical flattened, deterministic BindingId list hir::blockescape
# ::captures computed -- never independently re-derived, and always in the
# same order), so the ordinary internal variant and this one agree on
# capture identity, order, and representation by construction. Returns
# {TEXT INFO}, in the same shape as InternalFunction/RegionCompanionFunction.
proc native::lower::InternalRegionCompanionFunction {id} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable envless
    variable captureLists
    variable currentInstance
    variable ranges
    variable stringregion
    set currentInstance $id
    set instance [hir::specialize::instance $spec $id]
    set region [dict get $instance block]
    if {$region eq "program" || $region in $envless || ![hir::stringregion::wants $stringregion $id]} {
        throw {NATIVE BUG} "native lowering: instance $id has no internal region companion"
    }
    set hir [hir::specialize::view $baseHir $spec $id]
    set analysis [hir::aot::analyzeRegion $hir $region $context]
    CollectChecks $analysis
    set blockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    set fn [dict create region $region instance $id targets [dict get $instance calls] \
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 1 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            dict set fn locals $b [list reg $r]
        }
    }
    set captureBindings [dict get $captureLists $region]
    foreach b $captureBindings {
        dict set fn locals $b [list reg [NewReg fn]]
    }
    EnterScope fn $scope
    if {$body eq ""} {
        throw {NATIVE BUG} "native lowering: internal region companion of instance $id has an empty body"
    }
    set ok 1
    foreach e [lrange $body 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            set ok 0
            break
        }
    }
    if {$ok} {
        set fields [Expr fn [lindex $body end] region]
        if {$fields ne "never"} {
            Emit fn "retmulti [join $fields { }]"
        }
    }
    set pnames [concat [lmap b $params {dict get [hir::binding $hir $b] name}] \
        [lmap b $captureBindings {dict get [hir::binding $hir $b] name}]]
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]}]
    set head "func [Placeholder $id internalregion] [Quote $name] params=[expr {[llength $params] + [llength $captureBindings]}] env=0 regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=0 instance=[Quote $key] results=3"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id internalregion] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (internal region)" generic [dict get $instance generic] \
        envless 1 selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare]]
    return [list $text $info]
}

# Like the parameter-registration loop Function/CompanionFunction/
# RegionCompanionFunction each run, but for instance ID's `fields`/
# `fieldscompanion` internal variant (see the "Parameter virtualization"
# section above): a parameter B hir::escape::paramVirtualArity recognizes
# is received as that many ordinary field registers, stored in `fn locals`
# exactly like a virtualized *local* binding already is (`{virtual
# fields}`) -- so the existing `list_get(ref, constant)` interception in
# Call needs no change at all to also serve it. Every other parameter is
# registered exactly as Function's own loop does, including RawParams
# raw-eligibility. Returns the flattened NIR parameter names (one per
# field for a virtualized parameter, its own name otherwise).
proc native::lower::SetupFieldParams {fnVar id instance params} {
    upvar 1 $fnVar fn
    variable hir
    variable escape
    set rawParams [RawParams $id $instance $params]
    set pnames {}
    foreach b $params raw $rawParams {
        set n [hir::escape::paramVirtualArity $escape $id $b]
        set name [dict get [hir::binding $hir $b] name]
        if {$n ne ""} {
            set fields [NewRegs fn $n]
            dict set fn locals $b [list virtual $fields]
            for {set k 0} {$k < $n} {incr k} {
                lappend pnames "$name.$k"
            }
            continue
        }
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            dict set fn locals $b [list reg $r]
        }
        lappend pnames $name
    }
    return $pnames
}

# Lowers the `fields` variant of instance ID (see the "Parameter
# virtualization" section above): the same instance and body as Function,
# except every parameter hir::escape::paramVirtualArity recognizes is
# received as N ordinary field registers instead of one List register
# (SetupFieldParams). Still ends in an ordinary `ret` of one tagged value,
# exactly like Function -- hir::escape::paramWants ID must already be true.
# Returns {TEXT INFO}, in the same shape as Function.
proc native::lower::FieldsFunction {id} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable envless
    variable captureLists
    variable currentInstance
    variable escape
    set currentInstance $id
    set instance [hir::specialize::instance $spec $id]
    set region [dict get $instance block]
    if {$region eq "program" || ![hir::escape::paramWants $escape $id]} {
        throw {NATIVE BUG} "native lowering: instance $id has no fields variant"
    }
    set hir [hir::specialize::view $baseHir $spec $id]
    set analysis [hir::aot::analyzeRegion $hir $region $context]
    CollectChecks $analysis
    set blockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    set fn [dict create region $region instance $id targets [dict get $instance calls] \
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set pnames [SetupFieldParams fn $id $instance $params]
    EnterScope fn $scope
    set result [Sequence fn $body]
    if {$result ne "never"} {
        Emit fn "ret $result"
    }
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]}]
    set head "func [Placeholder $id fields] [Quote $name] params=[llength $pnames] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key]"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id fields] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (fields)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare]]
    return [list $text $info]
}

# Lowers the `fieldscompanion` variant of instance ID (see the "Parameter
# virtualization" section above): the same instance and body as
# CompanionFunction (ending every reachable exit in `retmulti` of its own
# recognized construction's fields), except its parameters are received as
# fields too (SetupFieldParams) -- both hir::escape::paramWants ID and
# hir::escape::arity ID must already hold. Returns {TEXT INFO}, in the same
# shape as CompanionFunction.
proc native::lower::FieldsCompanionFunction {id} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable envless
    variable captureLists
    variable currentInstance
    variable escape
    set currentInstance $id
    set instance [hir::specialize::instance $spec $id]
    set region [dict get $instance block]
    set arity [hir::escape::arity $escape $id]
    if {$region eq "program" || $arity eq "" || ![hir::escape::paramWants $escape $id]} {
        throw {NATIVE BUG} "native lowering: instance $id has no fields+companion variant"
    }
    set hir [hir::specialize::view $baseHir $spec $id]
    set analysis [hir::aot::analyzeRegion $hir $region $context]
    CollectChecks $analysis
    set blockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    set fn [dict create region $region instance $id targets [dict get $instance calls] \
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion $arity regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set pnames [SetupFieldParams fn $id $instance $params]
    EnterScope fn $scope
    if {$body eq ""} {
        throw {NATIVE BUG} "native lowering: fields+companion of instance $id has an empty body"
    }
    set ok 1
    foreach e [lrange $body 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            set ok 0
            break
        }
    }
    if {$ok} {
        set fields [VirtualValue fn [lindex $body end] $arity]
        if {$fields ne "never"} {
            Emit fn "retmulti [join $fields { }]"
        }
    }
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::types::show $t}] {, }]}]
    set head "func [Placeholder $id fieldscompanion] [Quote $name] params=[llength $pnames] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key] results=$arity"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id fieldscompanion] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (fields, scalar)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare]]
    return [list $text $info]
}

proc native::lower::NewReg {fnVar} {
    upvar 1 $fnVar fn
    set r [dict get $fn nreg]
    dict incr fn nreg
    return %$r
}

# N fresh registers (NewReg), for a callmulti/callenvmulti's destinations or
# a `retmulti`'s fields.
proc native::lower::NewRegs {fnVar n} {
    upvar 1 $fnVar fn
    set regs {}
    for {set i 0} {$i < $n} {incr i} {
        lappend regs [NewReg fn]
    }
    return $regs
}

proc native::lower::NewLabel {fnVar} {
    upvar 1 $fnVar fn
    set l [dict get $fn nlabel]
    dict incr fn nlabel
    return L$l
}

proc native::lower::Emit {fnVar line {e ""}} {
    upvar 1 $fnVar fn
    if {$e ne ""} {
        append line " @$e"
    }
    dict lappend fn lines "    $line"
}

proc native::lower::EmitLabel {fnVar label} {
    upvar 1 $fnVar fn
    dict lappend fn lines "  label $label"
}

# Emits "%d = RHS" and returns %d.
proc native::lower::Assign {fnVar rhs {e ""}} {
    upvar 1 $fnVar fn
    set r [NewReg fn]
    Emit fn "$r = $rhs" $e
    return $r
}

# Like Assign, for an instruction whose result is a raw (untagged) machine
# integer: records R in fn rawRegs, emitted as the func header's `rawregs=`
# declaration (native/src/nir.rs's validate checks every definition and use
# of a declared register against it, rather than inferring raw-ness by scan
# order -- see the "Representation" section below).
proc native::lower::AssignRaw {fnVar rhs {e ""}} {
    upvar 1 $fnVar fn
    set r [Assign fn $rhs $e]
    dict set fn rawRegs $r 1
    return $r
}

# Declares REG raw (see AssignRaw) without emitting an instruction: for a
# register a *later* instruction defines (a tail-rebound parameter slot, an
# if-join's shared result register) whose raw-ness is decided before that
# instruction is reached.
proc native::lower::MarkRaw {fnVar reg} {
    upvar 1 $fnVar fn
    dict set fn rawRegs $reg 1
}

# Enters HIR scope S: creates the cells of its cell bindings.
proc native::lower::EnterScope {fnVar s} {
    upvar 1 $fnVar fn
    variable hir
    variable cells
    foreach b [dict get $hir scopes $s bindings] {
        if {[dict get [hir::binding $hir $b] kind] eq "local" && [dict exists $cells $b]} {
            dict set fn locals $b [list cell [Assign fn cell]]
        }
    }
}

# ---------------------------------------------------------------------------
# Expressions
#
# Each procedure emits the instructions evaluating an expression and returns
# the register holding its value, or "never" if evaluation cannot complete
# normally (the instructions then end in a terminator).

proc native::lower::Sequence {fnVar exprs} {
    upvar 1 $fnVar fn
    if {$exprs eq ""} {
        return [Assign fn unit]
    }
    foreach e $exprs {
        set result [Expr fn $e]
        if {$result eq "never"} {
            break
        }
    }
    return $result
}

proc native::lower::Expr {fnVar e {want tagged}} {
    upvar 1 $fnVar fn
    variable hir
    set node [hir::node $hir $e]
    set repr tagged
    switch -- [dict get $node kind] {
        const    { lassign [ConstOrRegion fn $e $node $want] result repr }
        ref      { lassign [Ref fn $e $node $want] result repr }
        bind     { set result [Bind fn $e $node] }
        block    { set result [Closure fn $e] }
        call     { lassign [Call fn $e $node $want "" [expr {$want eq "region"}]] result repr }
        if       { set result [If fn $e $node] }
        loop     { set result [Loop fn $e $node] }
        listloop { set result [ListLoop fn $e $node] }
        return {
            set companion [dict get $fn companion]
            if {$companion ne ""} {
                # A scalar-replacement companion function (see the "Scalar
                # replacement" section above): hir::escape::wants only ever
                # holds when every reachable exit -- this one included --
                # classifies as a recognized construction of this same
                # arity, so VirtualValue's fields (not a materialized List)
                # are what this return actually produces.
                set fields [VirtualValue fn [dict get $node value] $companion]
                if {$fields ne "never"} {
                    Emit fn "retmulti [join $fields { }]" $e
                }
            } elseif {[dict get $fn regionCompanion]} {
                # A region companion function (see the "String regions"
                # section above): hir::stringregion::wants only ever holds
                # when every reachable exit -- this one included --
                # classifies region-producing, so its fields (not a
                # materialized String) are what this return actually
                # produces.
                set fields [Expr fn [dict get $node value] region]
                if {$fields ne "never"} {
                    Emit fn "retmulti [join $fields { }]" $e
                }
            } else {
                set value [Expr fn [dict get $node value]]
                if {$value ne "never"} {
                    Emit fn "ret $value" $e
                }
            }
            set result never
        }
        break {
            set value ""
            if {[dict get $node value] ne ""} {
                set value [Expr fn [dict get $node value]]
            }
            if {$value ne "never"} {
                lassign [dict get $fn loops [dict get $node target]] head exit resultReg
                if {$value eq ""} {
                    set value [Assign fn unit]
                }
                Emit fn "$resultReg = move $value" $e
                Emit fn "jump $exit" $e
                dict set fn broken [dict get $node target] 1
            }
            set result never
        }
        continue {
            lassign [dict get $fn loops [dict get $node target]] head
            Emit fn "jump $head" $e
            dict set fn continued [dict get $node target] 1
            set result never
        }
        ok - error {
            set value [Expr fn [dict get $node value]]
            if {$value eq "never"} {
                return never
            }
            set result [Assign fn "op [expr {[dict get $node kind] eq "ok" ? "mkok" : "mkerror"}] $value" $e]
        }
        fail {
            Emit fn "faildeclared [ErrorId [dict get $node name]] [Quote [dict get $node name]]" $e
            set result never
        }
        handle {
            set result [Handle fn $e $node]
        }
        default {
            throw {NATIVE INVALID-HIR} "native lowering: unknown HIR expression kind \"[dict get $node kind]\" ($e)"
        }
    }
    if {$result ne "never" && [hir::typeOf $hir $e] eq "never"} {
        # HIR proved that no normal completion reaches past E.
        Emit fn unreachable $e
        return never
    }
    if {$result ne "never" && $want eq "raw" && $repr eq "tagged"} {
        # WANT could not be produced directly (Ref/Call are the only kinds
        # that ever try): the declined-raw fallback, lower tagged then
        # runbox (milestone #6), reusing RawOf's cache like any other caller.
        set result [RawOf fn $result]
    }
    return $result
}

proc native::lower::Const {fnVar e node} {
    upvar 1 $fnVar fn
    set value [dict get $node value]
    switch -- [core::value::kind $value] {
        int  { return [IntConst fn [core::value::intOf $value] $e] }
        str  { return [Assign fn "str [Quote [core::value::strOf $value]]" $e] }
        UnicodeChar { return [Assign fn "char [core::value::charOf $value]" $e] }
        list {
            # (const list {...}): a list of literal elements.
            set items [lmap item [core::value::items $value] {
                switch -- [core::value::kind $item] {
                    int { IntConst fn [core::value::intOf $item] $e }
                    UnicodeChar { Assign fn "char [core::value::charOf $item]" $e }
                    default { Assign fn "str [Quote [core::value::strOf $item]]" $e }
                }
            }]
            return [Assign fn "op listnew [join $items { }]" $e]
        }
    }
    throw {NATIVE INVALID-HIR} "native lowering: unexpected constant [core::value::show $value] ($e)"
}

# {RESULT REPR}: like Const, but when WANT is "region" and the constant is a
# String, produces its trivial region directly -- a String literal is always
# a region over itself (base = the literal, 0..its own character count),
# needing no runtime bounds check at all (unlike a `substring` call's
# region, whose bounds native/lower.tcl still validates: see RegionCheck in
# the "String regions" section above). Every other constant is unaffected
# (WANT=region is only ever asked by a caller that already confirmed, via
# RegionEligible, that E is a String constant or a region-producing call).
proc native::lower::ConstOrRegion {fnVar e node want} {
    upvar 1 $fnVar fn
    if {$want eq "region" && [core::value::kind [dict get $node value]] eq "str"} {
        set text [core::value::strOf [dict get $node value]]
        set base [Assign fn "str [Quote $text]" $e]
        set start [IntConst fn 0 $e]
        set end [IntConst fn [string length $text] $e]
        return [list [list $base $start $end] region]
    }
    return [list [Const fn $e $node] tagged]
}

# An Int constant N: the tagged register (as before), with its raw
# counterpart pre-computed and cached (fn rawCache) when N fits the small-Int
# range, so arithmetic on a literal never round-trips through a redundant
# runbox of a value this lowering just boxed itself (the milestone's #8).
proc native::lower::IntConst {fnVar n e} {
    upvar 1 $fnVar fn
    variable reprOpt
    set r [Assign fn "int $n" $e]
    if {$reprOpt && [hir::range::fitsSmall [hir::range::point $n]]} {
        set raw [AssignRaw fn "rawint $n"]
        dict set fn rawCache $r $raw
    }
    return $r
}

proc native::lower::Ref {fnVar e node want} {
    upvar 1 $fnVar fn
    variable hir
    variable unproven
    set b [dict get $node binding]
    set name [dict get $node name]
    if {$b eq ""} {
        Emit fn "raise UNBOUND [Quote "unbound name \"$name\""]" $e
        return {never tagged}
    }
    set binding [hir::binding $hir $b]
    switch -- [dict get $binding kind] {
        root {
            return [list [RootValue fn $e $binding] tagged]
        }
        ambient {
            Unsupported $e "ambient binding" "\"$name\" is looked up in an unknown environment"
        }
    }
    if {[dict get $node init] eq "no"} {
        Emit fn "raise UNBOUND [Quote "name \"$name\" used before its binding"]" $e
        return {never tagged}
    }
    set access [Access fn $b]
    lassign $access how where
    switch -- $how {
        reg     { return [list $where tagged] }
        region  {
            # A local hir::stringregion.tcl proved virtual: every reference
            # is already known (hir::stringregion::Bindings) to be a
            # supported consumer asking for region form directly -- a plain
            # (tagged) reference to it would mean this analysis and this
            # lowering have gone out of sync.
            if {$want ne "region"} {
                throw {NATIVE BUG} "native lowering: region binding $b referenced outside a recognized consumer ($e)"
            }
            return [list $where region]
        }
        rawreg  {
            # A parameter RawParams proved raw for the whole function: WHERE
            # already *is* its raw register (Function), so a raw consumer
            # gets it with no conversion at all, not TaggedOf-then-RawOf'd
            # back (the milestone's core case: see #9 and the "Demand-driven
            # lowering" note above).
            if {$want eq "raw"} {
                return [list $where raw]
            }
            return [list [TaggedOf fn $where] tagged]
        }
        fnvalue { return [list [Assign fn "fnvalue $where" $e] tagged] }
        self    { return [list [Assign fn self $e] tagged] }
        cell {
            if {[dict exists $unproven $e]} {
                return [list [Assign fn "cellcheck $where [Quote [dict get $binding name]]" $e] tagged]
            }
            return [list [Assign fn "cellget $where" $e] tagged]
        }
    }
    throw {NATIVE BUG} "native lowering: bad access $access for $b ($e)"
}

# {reg %r} (a register holding the binding's value), {cell %c} (a register
# holding its cell), {fnvalue F} or {self}: how the current function reaches
# binding B, emitting a capture load if needed.
proc native::lower::Access {fnVar b} {
    upvar 1 $fnVar fn
    variable hir
    variable captureLists
    if {[dict exists $fn locals $b]} {
        set local [dict get $fn locals $b]
        if {[lindex $local 0] eq "function"} {
            # Bound in statement position: the value is materialized here.
            return [list fnvalue [GenericRef [lindex $local 1]]]
        }
        return $local
    }
    set region [dict get $fn region]
    set access [BindingAccess $b [expr {$region eq "program" ? "" : $region}]]
    switch -- $access {
        fnvalue {
            return [list fnvalue [GenericRef [hir::aot::BoundBlock $hir $b]]]
        }
        self {
            return [list self]
        }
    }
    if {$region eq "program" || ![dict exists $captureLists $region]} {
        throw {NATIVE BUG} "native lowering: binding $b is not reachable from $region"
    }
    set index [lsearch -exact [dict get $captureLists $region] $b]
    if {$index < 0} {
        throw {NATIVE BUG} "native lowering: $region does not capture $b"
    }
    # Loaded at each use: a use may sit in a branch that does not dominate
    # later uses.
    set r [Assign fn "capture $index"]
    return [list [expr {$access eq "cell" ? "cell" : "reg"}] $r]
}

proc native::lower::RootValue {fnVar e binding} {
    upvar 1 $fnVar fn
    variable natives
    variable usedNatives
    set value [dict get $binding value]
    switch -- [core::value::kind $value] {
        bool   { return [Assign fn "bool [lindex $value 1]" $e] }
        unit   { return [Assign fn unit $e] }
        native {
            set name [core::value::nativeName $value]
            if {![dict exists $natives $name]} {
                Unsupported $e "native $name" "the native \"$name\" has no native implementation"
            }
            if {$name ni $usedNatives} {
                lappend usedNatives $name
            }
            return [Assign fn "native [Quote $name]" $e]
        }
    }
    throw {NATIVE INVALID-HIR} "native lowering: unexpected root value [core::value::show $value] ($e)"
}

proc native::lower::Bind {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable context
    variable escape
    variable blockescape
    variable stringregion
    variable currentInstance
    set valueExpr [dict get $node value]
    set b [dict get $node binding]
    if {[hir::kind $hir $valueExpr] eq "block" && $valueExpr in [dict get $context envless]
            && ![dict get $node duplicate] && [dict exists $context discarded $e]
            && ![dict exists $context cells $b]
            && [dict get [hir::binding $hir $b] kind] eq "local"} {
        # An environment-free function bound in statement position: nothing
        # to run. References materialize its value
        # (hir::aot::materializedBlocks).
        dict set fn locals $b [list function $valueExpr]
        return ""
    }
    if {![dict get $node duplicate]} {
        set blockTarget [hir::blockescape::virtual $blockescape $currentInstance $b]
        if {$blockTarget ne ""} {
            # A locally bound Block value every use of which
            # hir::blockescape.tcl already proved is a statically known
            # direct call -- from this region, from a sibling nonescaping
            # Block's own body, or from its own recursion (see the "Block
            # virtualization" section above): nothing to run. Every
            # reference is intercepted directly in Call's
            # FlattenedVirtualCall below, which resolves the callee
            # instance's flattened captures fresh, in whatever scope the
            # call itself appears -- always a subset of bindings already in
            # scope there, by construction (hir/blockescape.tcl's
            # FlattenBinding) -- so (like an envless function bound in
            # statement position) nothing ever reads this local's "value"
            # as a callable Block, and there is nothing to evaluate or
            # store here at all.
            return ""
        }
        set virtualArity [hir::escape::virtualArity $escape $currentInstance $b]
        if {$virtualArity ne ""} {
            # A fixed-shape construction whose identity is never observed
            # (hir/escape.tcl): its fields, not a materialized List (see
            # the "Scalar replacement" section above). Every reference to B
            # is already known (hir::escape::Bindings) to be a scalar
            # `list_get` at a constant position, intercepted directly in
            # NativeCall below -- nothing ever reads this local's "value"
            # as a single register.
            set fields [VirtualValue fn $valueExpr $virtualArity]
            if {$fields eq "never"} {
                return never
            }
            dict set fn locals $b [list virtual $fields]
            return ""
        }
        if {[hir::stringregion::virtual $stringregion $currentInstance $b]} {
            # A region-producing value (hir/stringregion.tcl) every
            # reference to which is already known to be a supported
            # consumer (`==`/`length`): its fields, not a materialized
            # String. Every reference to B is intercepted directly in Ref
            # below -- nothing ever reads this local's "value" as a single
            # tagged register.
            set fields [Expr fn $valueExpr region]
            if {$fields eq "never"} {
                return never
            }
            dict set fn locals $b [list region $fields]
            return ""
        }
    }
    set value [Expr fn $valueExpr]
    if {$value eq "never"} {
        return never
    }
    set b [dict get $node binding]
    set name [dict get $node name]
    if {[dict get [hir::binding $hir $b] kind] eq "ambient"} {
        Unsupported $e "ambient binding" "\"$name\" is bound in an unknown environment"
    }
    if {[dict get $node duplicate]} {
        Emit fn "raise DUPLICATE [Quote "duplicate binding \"$name\" in the same lexical scope"]" $e
        return never
    }
    if {[dict exists $fn locals $b] && [lindex [dict get $fn locals $b] 0] eq "cell"} {
        Emit fn "cellset [lindex [dict get $fn locals $b] 1] $value" $e
    } else {
        dict set fn locals $b [list reg $value]
    }
    return $value
}

# The current SSA values of BINDINGS (a BindingId list, most often
# native::lower::captureLists's own entry for some block expression), in
# order: the same evaluation Closure runs to build a real closure's
# environment array, reused as-is by Call's FlattenedVirtualCall below
# since a captured binding's value is exactly the same ordinary value
# either way (the "Block virtualization" section above's #8: captures
# remain ordinary values, closure or not) -- resolved fresh in the current
# function's own scope every time it is asked for, never stored once and
# threaded through a `bind` (see FlattenedVirtualCall's own comment for
# why every binding this is ever asked to resolve is already guaranteed to
# be in scope).
proc native::lower::CaptureRegsOf {fnVar bindings} {
    upvar 1 $fnVar fn
    set values {}
    foreach b $bindings {
        lassign [Access fn $b] how where
        switch -- $how {
            reg - cell { lappend values $where }
            rawreg     { lappend values [TaggedOf fn $where] }
            fnvalue    { lappend values [Assign fn "fnvalue $where"] }
            self       { lappend values [Assign fn self] }
        }
    }
    return $values
}

# The current SSA values of block expression E's captures
# (native::lower::captureLists).
proc native::lower::CaptureValues {fnVar e} {
    upvar 1 $fnVar fn
    variable captureLists
    return [CaptureRegsOf fn [dict get $captureLists $e]]
}

# Creation of the Block value of block expression E.
proc native::lower::Closure {fnVar e} {
    upvar 1 $fnVar fn
    variable envless
    variable context
    if {$e in $envless} {
        if {[dict exists $context discarded $e] && ![dict exists $context bound $e]} {
            # A value nothing uses (hir::aot::materializedBlocks).
            return ""
        }
        return [Assign fn "fnvalue [GenericRef $e]" $e]
    }
    set values [CaptureValues fn $e]
    return [Assign fn [string trimright "closure [GenericRef $e] [join $values { }]"] $e]
}

# ---------------------------------------------------------------------------
# Calls

# The ARITY fields (a list of registers) of expression E, a call
# hir::escape.tcl already classified (Bind, CompanionFunction, and Expr's
# `return` case in companion mode: every caller already knows, from
# hir::escape.tcl, that E recognizes with this arity) as a recognized
# fixed-shape construction -- never a materialized List register. "never"
# if evaluating one of its parts cannot complete normally.
proc native::lower::VirtualValue {fnVar e arity} {
    upvar 1 $fnVar fn
    variable hir
    set node [hir::node $hir $e]
    if {[dict get $node kind] ne "call"} {
        throw {NATIVE BUG} "native lowering: expected a recognized construction at $e"
    }
    lassign [Call fn $e $node tagged $arity] result repr
    if {$result eq "never"} {
        return never
    }
    if {$repr ne "virtual"} {
        throw {NATIVE BUG} "native lowering: expected virtual fields at $e"
    }
    if {[hir::typeOf $hir $e] eq "never"} {
        # HIR proved that no normal completion reaches past E (Expr's own
        # tail does this same check for every other expression kind).
        Emit fn unreachable $e
        return never
    }
    return $result
}

# 1 if TARGET (a callee InstanceId, possibly "") has a `fields`/
# `fieldscompanion` variant a direct call may actually use (see the
# "Parameter virtualization" section above): hir::escape::paramWants holds
# for it, and it has no hir/traversal.tcl TraversalPlan (that plan's own
# hidden extra parameter is a different internal-ABI extension of the same
# instance this milestone does not attempt to compose with).
proc native::lower::ParamFieldsUsable {target} {
    variable escape
    variable traversal
    if {$target eq "" || ![hir::escape::paramWants $escape $target]} {
        return 0
    }
    return [expr {[hir::traversal::plan $traversal $target] eq ""}]
}

# One entry per PARAMS (TARGET's own declared parameters): TARGET's
# hir::escape::paramVirtualArity at that position (N), or "" if that
# parameter is not virtualized -- an all-"" list (in practice never
# consulted, since ParamFieldsUsable gates every call site) if TARGET
# cannot use fields at all.
proc native::lower::FieldWidths {target params} {
    variable escape
    if {![ParamFieldsUsable $target]} {
        return {}
    }
    return [lmap p $params {hir::escape::paramVirtualArity $escape $target $p}]
}

# 1 if every virtualized position of FIELDWIDTHS (FieldWidths) can actually
# be supplied as fields *right now*, for THIS specific call site: a `call`
# argument always can (TryFields's own `call` case recurses into Call,
# which applies this same all-or-nothing discipline to its own arguments in
# turn, so it can never itself be the reason a whole chain fails); a `ref`
# argument can only if the binding it names is *currently* stored
# `{virtual fields}` of the matching width in `fn locals` -- checkable
# without evaluating anything.
#
# This exists because hir::escape.tcl's parameter-arity growth (
# RawParamArities) is, by design (the file header's #41 soundness
# requirement), a pure caller-proven *value-shape* fact -- computed from
# every caller's argument, independent of whether that caller's own slot
# ultimately turns out *eligible* (Eligible is a separate, later question).
# So a target parameter can be soundly virtualizable (some OTHER caller
# really does have fields to give it) while one particular caller does not
# actually have them on hand at lowering time (its own forwarded slot had a
# provable shape, but failed its own structural-use check for an unrelated
# reason -- e.g. it was also returned as itself, or stored elsewhere). This
# check is what makes that safe: the decision to use TARGET's `fields`/
# `fieldscompanion` variant is made per call site, never assumed from
# TARGET's own eligibility alone.
proc native::lower::CanSupplyFields {fnVar argExprs fieldWidths} {
    upvar 1 $fnVar fn
    variable hir
    set i 0
    foreach arg $argExprs {
        set width [expr {$i < [llength $fieldWidths] ? [lindex $fieldWidths $i] : ""}]
        if {$width ne ""} {
            switch -- [hir::kind $hir $arg] {
                call {}
                ref {
                    set b [hir::get $hir $arg binding]
                    if {$b eq "" || ![dict exists $fn locals $b]
                            || [lindex [dict get $fn locals $b] 0] ne "virtual"
                            || [llength [lindex [dict get $fn locals $b] 1]] != $width} {
                        return 0
                    }
                }
                default {
                    return 0
                }
            }
        }
        incr i
    }
    return 1
}

# The N-field virtual form of argument expression E (a call's argument, at
# a position hir::escape.tcl already proved this call's target instance
# receives as N ordinary fields), or "" if E does not have one of the two
# shapes hir::escape.tcl's Eligible pass ever accepts as a source: a `ref`
# to a binding this same caller's own `fn locals` already holds virtual
# (a virtualized local binding, or one of *this* function's own
# virtualized parameters, forwarded unchanged -- already evaluated, read
# here for free, exactly like the existing list_get(ref, constant)
# interception reads one field), or a `call` node itself recognized this
# same way (a `[e0..en-1]` literal, or a forwarding call to another
# companion-eligible instance) -- reusing Call's own existing WANTVIRTUAL
# machinery (VirtualValue's own mechanism) rather than duplicating it.
# "never" if evaluating a construction's own parts cannot complete
# normally. hir::escape.tcl only ever proves a call site eligible this way
# when one of these two shapes is what is actually there, so CallArgs
# treats "" here as a lowering/analysis inconsistency (NATIVE BUG), never a
# legitimate fallback to build.
proc native::lower::TryFields {fnVar e n} {
    upvar 1 $fnVar fn
    variable hir
    switch -- [hir::kind $hir $e] {
        ref {
            set b [hir::get $hir $e binding]
            if {$b eq "" || ![dict exists $fn locals $b]} {
                return ""
            }
            set local [dict get $fn locals $b]
            if {[lindex $local 0] ne "virtual"} {
                return ""
            }
            set fields [lindex $local 1]
            if {[llength $fields] != $n} {
                return ""
            }
            return $fields
        }
        call {
            set node [hir::node $hir $e]
            lassign [Call fn $e $node tagged $n] result repr
            if {$result eq "never"} {
                return never
            }
            if {$repr ne "virtual"} {
                return ""
            }
            return $result
        }
    }
    return ""
}

# The flat NIR argument-register list for a call to a target whose own
# declared parameters ARGEXPRS supplies values for: FIELDWIDTHS (FieldWidths
# -- "" at a non-virtualized position, or the whole list when the target
# cannot use fields at all) says which positions to evaluate in virtual
# field form (TryFields) instead of one ordinary register; RAWSLOTS (empty
# unless this is a self-tail call: see Call's own `self` case) says which
# of the *remaining*, non-virtualized positions want Expr's `raw` form
# instead of `tagged`. "never" if any argument cannot complete normally.
proc native::lower::CallArgs {fnVar argExprs fieldWidths rawSlots} {
    upvar 1 $fnVar fn
    set regs {}
    set i 0
    foreach arg $argExprs {
        set width [expr {$i < [llength $fieldWidths] ? [lindex $fieldWidths $i] : ""}]
        if {$width ne ""} {
            set fields [TryFields fn $arg $width]
            if {$fields eq "never"} {
                return never
            }
            if {$fields eq ""} {
                throw {NATIVE BUG} "native lowering: expected $width virtual fields at $arg"
            }
            lappend regs {*}$fields
        } else {
            set argWant [expr {$i < [llength $rawSlots] && [lindex $rawSlots $i] ? "raw" : "tagged"}]
            set r [Expr fn $arg $argWant]
            if {$r eq "never"} {
                return never
            }
            lappend regs $r
        }
        incr i
    }
    return $regs
}

# Returns {RESULT REPR}: REPR is "raw" only when Ref or Call produced it
# directly, "virtual" only when WANTVIRTUAL asked for it and got it (a list
# of WANTVIRTUAL registers, the fields of a recognized construction: see the
# "Scalar replacement" section above); every other expression kind always
# returns "tagged" (Expr's tail reconciles a mismatch with WANT via
# RawOf/TaggedOf; WANTVIRTUAL is never reconciled that way -- a caller that
# passes it already knows, from hir::escape.tcl, that E recognizes).
# Direct internal-variant call of a Block binding hir::blockescape.tcl
# proved eligible for de-closure conversion (see the "Block virtualization"
# section above): CALLEEEXPR is never evaluated (no Block value exists to
# call through). CAPTUREBINDINGS -- CALLEEINSTANCE's own flattened capture
# list (hir::blockescape::captures) -- is resolved fresh, in the CURRENT
# function's own scope (CaptureRegsOf), every time this is called: by
# construction (hir/blockescape.tcl's FlattenBinding), every one of those
# bindings is already in scope wherever this call appears, whether that is
# the enclosing region's own top-level body, another eligible candidate's
# own body (a sibling call), or CALLEEINSTANCE's own body (a recursive
# call: CALLEEINSTANCE equals the CURRENT instance being lowered) -- so
# the same registers this function already has for its own params/captures
# serve directly as the callee's capture arguments, with no intervening
# `bind` or stored value, and no "self" (running-closure identity) value
# is ever needed even for a recursive call.
#
# A recursive self-tail call (hir::aot::selfTailCalls, exactly the
# condition Call's own ordinary self-tail branch below checks for a
# materialized closure) still becomes a loop backedge -- `tail`, never
# `tailenv`: an internal variant has no environment/closure register at
# all -- with its own capture registers re-passed as ordinary trailing
# loop-carried parameters, so a self-tail recursive de-closure-converted
# function keeps the existing self-tail-to-loop optimization (the
# milestone's #92) exactly as a materialized closure would, just with no
# per-call closure allocation and no environment register at all. Any
# other (non-tail) recursive or sibling call is an ordinary `call` to the
# callee's own internal variant (the milestone's #22: non-tail recursion
# needs no special support of its own).
proc native::lower::FlattenedVirtualCall {fnVar e node target targetInstance captureBindings} {
    upvar 1 $fnVar fn
    variable hir
    variable selfTail
    variable currentInstance
    set params [hir::get $hir $target params]
    set argExprs [dict get $node args]
    # A recursive self-tail call (target is the instance currently being
    # lowered): each of ITS OWN declared parameter slots may be RawParams-
    # declared raw (native/lower.tcl's "Representation" section) -- exactly
    # the same condition Call's own ordinary self-tail branch below checks
    # -- so its argument must be evaluated in that same representation
    # (CallArgs), never eagerly tagged, or the backedge's own raw/tagged
    # parameter-slot discipline (nir.rs's validation) is violated.
    set self [expr {$targetInstance eq $currentInstance && [dict exists $selfTail $e]}]
    set rawSlots {}
    if {$self} {
        set rawSlots [lmap p $params {
            expr {[dict exists $fn locals $p] && [lindex [dict get $fn locals $p] 0] eq "rawreg"}
        }]
    }
    set argRegs [CallArgs fn $argExprs {} $rawSlots]
    if {$argRegs eq "never"} {
        return {never tagged}
    }
    if {[llength $params] != [llength $argRegs]} {
        set pnames [lmap p $params {dict get [hir::binding $hir $p] name}]
        Emit fn "raise ARITY [Quote "block ([join $pnames { }]) expects [llength $params] argument(s), got [llength $argRegs]"]" $e
        return {never tagged}
    }
    set captureRegs [CaptureRegsOf fn $captureBindings]
    if {$self} {
        dict lappend fn calls [list direct [Placeholder $targetInstance internal] 1]
        Emit fn [string trimright "tail [join [concat $argRegs $captureRegs] { }]"] $e
        return {never tagged}
    }
    set id [InternalRef $targetInstance]
    dict lappend fn calls [list direct $id 0]
    return [list [Assign fn [string trimright "call $id [join [concat $argRegs $captureRegs] { }]"] $e] tagged]
}

# Like FlattenedVirtualCall, but for a call E whose result is wanted as a
# StringRegion (Call's wantRegion): hir::stringregion.tcl already proved
# TARGETINSTANCE's own result is fully region-producing and some caller --
# this one -- demands its region companion (hir::stringregion::wants).
# CALLEEEXPR is never evaluated (there is no Block value to produce, for
# exactly the reason FlattenedVirtualCall's own comment gives): the call
# goes straight to TARGETINSTANCE's *internal region companion*
# (InternalRegionCompanionRef) instead of its ordinary internal variant --
# the composition this milestone adds, a capture-explicit calling
# convention together with a multi-value region result. CAPTUREBINDINGS is
# exactly the same flattened list (hir::blockescape::captures), in the same
# order, FlattenedVirtualCall's own ordinary-result dispatch uses for the
# very same TARGETINSTANCE -- never independently re-derived, so the two
# variants agree on capture identity/order/representation by construction
# (the milestone's #9).
proc native::lower::FlattenedVirtualRegionCall {fnVar e node target targetInstance captureBindings} {
    upvar 1 $fnVar fn
    variable hir
    variable selfTail
    variable currentInstance
    set params [hir::get $hir $target params]
    set argExprs [dict get $node args]
    # A self-tail recursive call is never itself asked for a region result:
    # hir/stringregion.tcl's Exits/SelfTailExit never treats a self-tail
    # loop backedge as a reachable exit to classify in the first place, so
    # this instance's own `wants`-demanded exits never include one. Handled
    # defensively anyway, mirroring FlattenedVirtualCall's own self branch,
    # rather than assumed unreachable.
    set self [expr {$targetInstance eq $currentInstance && [dict exists $selfTail $e]}]
    set rawSlots {}
    if {$self} {
        set rawSlots [lmap p $params {
            expr {[dict exists $fn locals $p] && [lindex [dict get $fn locals $p] 0] eq "rawreg"}
        }]
    }
    set argRegs [CallArgs fn $argExprs {} $rawSlots]
    if {$argRegs eq "never"} {
        return {never region}
    }
    if {[llength $params] != [llength $argRegs]} {
        set pnames [lmap p $params {dict get [hir::binding $hir $p] name}]
        Emit fn "raise ARITY [Quote "block ([join $pnames { }]) expects [llength $params] argument(s), got [llength $argRegs]"]" $e
        return {never region}
    }
    set captureRegs [CaptureRegsOf fn $captureBindings]
    if {$self} {
        dict lappend fn calls [list direct [Placeholder $targetInstance internalregion] 1]
        Emit fn [string trimright "tail [join [concat $argRegs $captureRegs] { }]"] $e
        return {never region}
    }
    set id [InternalRegionCompanionRef $targetInstance]
    dict lappend fn calls [list direct $id 0]
    set dsts [NewRegs fn 3]
    Emit fn [string trimright "[join $dsts { }] = callmulti $id [join [concat $argRegs $captureRegs] { }]"] $e
    return [list $dsts region]
}

# The native-to-module bridge changes a root native call's resolved target to
# a module Block. When that Block has captures, the root native value is not
# its closure; fetch the already-resolved module binding instead. This uses
# only HIR BindingIds, never a run-time namespace/name lookup.
proc native::lower::ModuleBridgeBinding {calleeExpr targetKind} {
    variable hir
    if {$targetKind ne "block" || [hir::kind $hir $calleeExpr] ne "ref"} {
        return ""
    }
    set rootBinding [hir::get $hir $calleeExpr binding]
    if {$rootBinding eq "" || [dict get [hir::binding $hir $rootBinding] kind] ne "root"} {
        return ""
    }
    set rootValue [dict get [hir::binding $hir $rootBinding] value]
    if {[core::value::kind $rootValue] ne "native"} {
        return ""
    }
    set nativeName [core::value::nativeName $rootValue]
    set moduleFn [dict get [core::native::metadata $nativeName] moduleFn]
    if {$moduleFn eq ""} {
        return ""
    }
    lassign $moduleFn namespace symbol
    if {![dict exists $hir modules $namespace]} {
        return ""
    }
    set scope [dict get $hir modules $namespace]
    set qualified [format {%s::%s} $namespace $symbol]
    if {![dict exists $hir scopes $scope names $qualified]} {
        return ""
    }
    return [dict get $hir scopes $scope names $qualified]
}

# Preserve the exact call and its completion handling, then substitute a
# successful-result constant for later value uses when the per-instance range
# analysis proves one. This is not an effect or totality optimization.
proc native::lower::ClosedResult {fnVar e result} {
    upvar 1 $fnVar fn
    variable callFactsOpt
    variable ranges
    variable currentInstance
    variable hir
    if {$callFactsOpt && [hir::types::kindOf [hir::typeOf $hir $e]] eq "int"} {
        set range [hir::range::of $ranges $currentInstance $e]
        if {$range ne "never" && [hir::range::fitsSmall $range] && [dict get $range min] eq [dict get $range max]} {
            return [list [IntConst fn [dict get $range min] $e] tagged]
        }
    }
    return [list $result tagged]
}

proc native::lower::Call {fnVar e node want {wantVirtual ""} {wantRegion 0}} {
    upvar 1 $fnVar fn
    variable hir
    variable selfTail
    variable envless
    variable unproven
    variable natives
    variable escape
    variable blockescape
    variable currentInstance
    variable stringregion
    variable traversal
    variable stringRegionOpt
    variable tinyLeafInlineOpt
    lassign [dict get $node target] targetKind target
    set calleeExpr [dict get $node callee]
    set argExprs [dict get $node args]

    if {$wantVirtual eq "" && $targetKind eq "block"
            && [hir::kind $hir $calleeExpr] eq "ref"} {
        set calleeBinding [hir::get $hir $calleeExpr binding]
        set flattenedTarget [expr {$calleeBinding ne "" ? [hir::blockescape::virtual $blockescape $currentInstance $calleeBinding] : ""}]
        if {$flattenedTarget ne ""} {
            # A direct call of a Block binding hir::blockescape.tcl already
            # proved eligible for de-closure conversion: CALLEEEXPR is
            # never evaluated at all (there is no Block value to produce).
            # This is the *only* place a virtualized Block binding's
            # captures are ever resolved -- never at `bind` time (Bind's
            # own virtualized case is a no-op) -- so it fires identically
            # whether CALLEEBINDING was bound in this same region, in an
            # enclosing region (a sibling call from inside another
            # eligible candidate's own body), or is this very instance's
            # own binding (a recursive call).
            #
            # An ordinary-result call goes straight to the callee
            # instance's internal variant with its flattened captures
            # appended (FlattenedVirtualCall). A region-result call --
            # hir::stringregion.tcl already proved this exact instance's
            # own result is fully region-producing, and this call site is
            # the demand -- goes instead to its *internal region
            # companion* (FlattenedVirtualRegionCall): the composition
            # this milestone adds, so a candidate hir::blockescape.tcl no
            # longer declines merely because some caller wants a region
            # result (see hir/blockescape.tcl's own header and the "Block
            # virtualization"/"String regions" sections above).
            set captureBindings [hir::blockescape::captures $blockescape $flattenedTarget]
            if {$wantRegion} {
                if {![hir::stringregion::wants $stringregion $flattenedTarget]} {
                    throw {NATIVE BUG} "native lowering: instance $flattenedTarget has no region companion for virtualized call $e"
                }
                return [FlattenedVirtualRegionCall fn $e $node $target $flattenedTarget $captureBindings]
            }
            return [FlattenedVirtualCall fn $e $node $target $flattenedTarget $captureBindings]
        }
    }

    if {$wantVirtual eq "" && !$wantRegion} {
        set plan [dict get $fn traversal]
        if {$plan ne "" && $e in [dict get $plan accesses]} {
            # A recognized single-character String traversal access (see
            # native/lower.tcl's "String traversal" section and hir/
            # traversal.tcl): lowered directly here, inline, in the caller's
            # own body -- never as a `call`/`callenv` to its own callee
            # function at all for this one call site. Only when an ordinary
            # tagged result is wanted (#23's conservative fallback: hir/
            # traversal.tcl never actually produces an access reachable in a
            # region/virtual-consuming position, but this guard costs
            # nothing and keeps that a soundness property of this lowering,
            # not just of the analysis).
            return [TraversalAccess fn $e $node $plan]
        }
    }

    if {$wantRegion && $targetKind eq "native"
            && [dict get [hir::symbol $hir $target] name] eq "substring" && [llength $argExprs] == 3} {
        # `substring(text, a, b)` asked for directly in region form (Bind, a
        # region companion's exit, or an inline `==`/`length` operand):
        # RegionEligible already confirmed E has exactly this shape. The
        # three operands *are* the region -- text/a/b, evaluated exactly as
        # an ordinary `substring` call would, with the same argument guards
        # (EmitArgGuards) -- but bounds are validated with RegionCheck
        # instead of the allocating, copying `substr`.
        lassign $argExprs tExpr sExpr eExpr
        set base [Expr fn $tExpr]
        if {$base eq "never"} {
            return {never tagged}
        }
        set start [Expr fn $sExpr]
        if {$start eq "never"} {
            return {never tagged}
        }
        set end [Expr fn $eExpr]
        if {$end eq "never"} {
            return {never tagged}
        }
        set meta [core::native::metadata substring]
        EmitArgGuards fn $e $argExprs [list $base $start $end] [dict get $meta paramTypes] substring
        dict lappend fn calls [list native substring]
        Assign fn "op regioncheck $base $start $end" $e
        return [list [list $base $start $end] region]
    }

    if {$wantVirtual eq "" && $targetKind eq "native" && [llength $argExprs] == 2
            && [dict get [hir::symbol $hir $target] name] eq "list_get"
            && [hir::kind $hir [lindex $argExprs 0]] eq "ref"} {
        # A `list_get(ref, constant)` read of a binding *currently* lowered
        # as virtual fields (`fn locals`'s own `{virtual fields}` tag,
        # consulted directly rather than re-derived from hir::escape.tcl:
        # the same binding is `{virtual ...}` in one lowering of its
        # instance and an ordinary `{reg ...}` in another -- a local
        # binding is virtual in every lowering of its instance alike, but a
        # *parameter* SetupFieldParams recognizes is virtual only in that
        # instance's `fields`/`fieldscompanion` variant, never in its
        # canonical function, which must keep accepting a real List: see
        # the "Parameter virtualization" section above). REF is not even
        # evaluated (a plain reference has no effect of its own); a
        # binding not currently virtual falls through to the ordinary
        # NativeCall `listget` path below unchanged.
        set b [hir::get $hir [lindex $argExprs 0] binding]
        if {$b ne "" && [dict exists $fn locals $b] && [lindex [dict get $fn locals $b] 0] eq "virtual"} {
            set fields [lindex [dict get $fn locals $b] 1]
            set idxExpr [lindex $argExprs 1]
            if {[hir::kind $hir $idxExpr] ne "const"
                    || [core::value::kind [hir::get $hir $idxExpr value]] ne "int"} {
                throw {NATIVE BUG} "native lowering: virtual binding $b read with a non-constant index at $e"
            }
            set idx [core::value::intOf [hir::get $hir $idxExpr value]]
            if {$idx < 0 || $idx >= [llength $fields]} {
                throw {NATIVE BUG} "native lowering: virtual binding $b read out of range at $e"
            }
            variable guards
            if {[dict exists $guards [list $e [lindex $argExprs 0]]]} {
                # hir::aot::analyzeRegion counted a representation blocker
                # for this operand (its own, coarser, per-instance
                # representation analysis has no notion of hir::escape.tcl's
                # finer per-binding proof that this value is always list-
                # shaped by construction): the kind guard that blocker
                # would otherwise need is genuinely unnecessary here, but
                # still counted in `analysis blockers` below, so it must be
                # subtracted back out to keep this function's own
                # blockers==guards accounting (native::report's invariant)
                # correct -- see FUNCTION-BUILDING procs' own blocker count.
                dict incr fn skippedGuards
            }
            return [list [lindex $fields $idx] tagged]
        }
    }

    if {$wantVirtual eq "" && !$wantRegion && $targetKind eq "block" && $stringRegionOpt} {
        # A direct call to an instance hir::stringregion.tcl's ConsumingParams
        # proved region-consuming at some parameter (e.g. `is_local_char
        # (char_at(i))`, lib/web.tcl's Emailish? native-body): if the
        # argument at that position is itself region-eligible, its body is
        # lowered directly here, inline, in the caller's own function --
        # never as a `call`/`callenv` to its own compiled function at all
        # for this one call site (the "String traversal" section's
        # TraversalAccess precedent: no interprocedural ABI, no companion
        # call, the instance's own canonical function still unconditionally
        # emitted and still correct for every other caller). Only the first
        # consuming parameter with a region-eligible argument is used
        # (mirrors TryStringRegionOp's own "prefer the left operand"
        # narrowing for `==`: the corpus this milestone targets never
        # exercises more than one).
        set consumerInstance [expr {[dict exists $fn targets $e] ? [dict get $fn targets $e] : ""}]
        if {$consumerInstance ne ""} {
            foreach k [hir::stringregion::consumingParamsOf $stringregion $consumerInstance] {
                set argExpr [lindex $argExprs $k]
                if {$argExpr ne "" && [RegionEligible $argExpr]} {
                    return [InlineRegionConsumerCall fn $argExpr $consumerInstance $k]
                }
            }
        }
    }

    if {$wantVirtual ne "" && $targetKind eq "native"} {
        # A `[e0, ..., en-1]` construction VirtualValue asked for directly:
        # hir::escape.tcl already confirmed this call recognizes with
        # exactly this arity, so there is nothing to skip-callee-check or
        # guard here (a `list` call can never fail) -- just the fields, in
        # source evaluation order, never materialized into a List.
        if {[dict get [hir::symbol $hir $target] name] ne "list" || [llength $argExprs] != $wantVirtual} {
            throw {NATIVE BUG} "native lowering: expected a $wantVirtual-element list construction at $e"
        }
        set fields {}
        foreach arg $argExprs {
            set r [Expr fn $arg]
            if {$r eq "never"} {
                return {never tagged}
            }
            lappend fields $r
        }
        return [list $fields virtual]
    }

    # The callee is evaluated first. A reference to a root native or to an
    # environment-free function needs no code. A module-native bridge with a
    # captured module value instead reads the module function binding itself.
    set callee ""
    set bridgeBinding [ModuleBridgeBinding $calleeExpr $targetKind]
    set bridgeEnvless [expr {$bridgeBinding ne "" && $target in $envless}]
    set skipCallee [expr {[hir::kind $hir $calleeExpr] eq "ref"
        && ![dict exists $unproven $calleeExpr]
        && ($bridgeEnvless || ($bridgeBinding eq "" &&
            (($targetKind eq "native" && [dict get [hir::binding $hir [hir::get $hir $calleeExpr binding]] kind] eq "root")
                || ($targetKind eq "block" && $target in $envless && [hir::get $hir $calleeExpr init] ne "no"))))}]
    if {$bridgeBinding ne "" && !$skipCallee} {
        lassign [Access fn $bridgeBinding] how where
        switch -- $how {
            reg { set callee $where }
            cell { set callee [Assign fn "cellget $where" $e] }
            rawreg { set callee [TaggedOf fn $where] }
            fnvalue { set callee [Assign fn "fnvalue $where" $e] }
            self { set callee [Assign fn self $e] }
            default {
                throw {NATIVE BUG} "native lowering: module bridge binding $bridgeBinding has inaccessible storage $how"
            }
        }
    } elseif {!$skipCallee} {
        set callee [Expr fn $calleeExpr]
        if {$callee eq "never"} {
            return {never tagged}
        }
    }

    if {$targetKind eq "native"} {
        # A raw-eligible native (RawEligibleCall, decided from the argument
        # *expressions* alone -- no evaluation needed yet) asks its operands
        # for raw directly, so a chain of such calls never materializes an
        # intermediate tagged value only to unbox it straight back
        # (milestone #10); anything else evaluates tagged exactly as before.
        lassign [NativeCallOp $e $node] name op
        set region [TryStringRegionOp fn $e $name $op $argExprs]
        if {$region ne ""} {
            return $region
        }
        set rawEligible [expr {[dict exists $natives $name] ? [RawEligibleCall $e $argExprs $op] : 0}]
        set argRegs {}
        foreach arg $argExprs {
            set r [Expr fn $arg [expr {$rawEligible ? "raw" : "tagged"}]]
            if {$r eq "never"} {
                return {never tagged}
            }
            lappend argRegs $r
        }
        return [NativeCall fn $e $node $name $argRegs $rawEligible $op $want]
    }

    if {$targetKind eq "block"} {
        set params [hir::get $hir $target params]
        set instance [expr {[dict exists $fn targets $e] ? [dict get $fn targets $e] : ""}]
        # The instance hir::specialize chose; a self tail call that stays in
        # this instance is a loop, and each of its raw-declared parameter
        # slots (RawParams) wants its argument raw directly, rather than
        # Expr's default tagged form immediately unboxed back (the
        # milestone's central case: see #9).
        set self [expr {$instance ne "" && [dict exists $selfTail $e] && $instance eq [dict get $fn instance]}]
        # A parameter position hir::escape.tcl proved this call's own
        # target instance receives as N ordinary fields rather than one
        # materialized List (see the "Parameter virtualization" section
        # above): evaluated in that same virtual field form (CallArgs/
        # TryFields) instead of a single register -- but only when this
        # specific call site can actually supply them right now
        # (CanSupplyFields; see its own comment for why TARGET's own
        # eligibility alone is not enough). Never attempted for a
        # region-result call (wantRegion): the two optimizations do not
        # currently combine.
        set fieldWidths [expr {$wantRegion ? {} : [FieldWidths $instance $params]}]
        if {$fieldWidths ne "" && ![CanSupplyFields fn $argExprs $fieldWidths]} {
            set fieldWidths {}
        }
        set rawSlots {}
        if {$self} {
            set rawSlots [lmap p $params {
                expr {[dict exists $fn locals $p] && [lindex [dict get $fn locals $p] 0] eq "rawreg"}
            }]
        }
        set argRegs [CallArgs fn $argExprs $fieldWidths $rawSlots]
        if {$argRegs eq "never"} {
            return {never tagged}
        }
        if {[llength $params] != [llength $argExprs]} {
            set pnames [lmap b $params {dict get [hir::binding $hir $b] name}]
            Emit fn "raise ARITY [Quote "block ([join $pnames { }]) expects [llength $params] argument(s), got [llength $argExprs]"]" $e
            return {never tagged}
        }
        if {![dict exists $fn targets $e]} {
            throw {NATIVE BUG} "native lowering: hir::specialize chose no instance for call $e"
        }
        if {$self} {
            dict lappend fn calls [list direct [Placeholder $instance] 1]
            set tailArgs $argRegs
            if {[dict get $fn traversal] ne ""} {
                # This instance's own hidden byte-position parameter
                # (native/lower.tcl's "String traversal" section): carries
                # forward whatever TraversalAccess last advanced it to while
                # lowering this same self-tail call's own argument
                # expressions, above.
                lappend tailArgs [dict get $fn traversalByteReg]
            }
            if {$target in $envless} {
                Emit fn [string trimright "tail [join $tailArgs { }]"] $e
            } else {
                Emit fn [string trimright "tailenv $callee [join $tailArgs { }]"] $e
            }
            return {never tagged}
        }
        if {$wantVirtual ne ""} {
            # A recognized forwarding construction (VirtualValue): the
            # target instance's scalar-replacement companion (or, when its
            # own parameters are also virtualized, its `fieldscompanion`
            # variant: ParamFieldsUsable), reached through callmulti/
            # callenvmulti, hands its fields straight back with no List
            # ever materialized in between. Instance is never "" here:
            # hir::escape.tcl only classifies a call this way when
            # hir::specialize itself resolved a direct target for it
            # (Classify consults the same `calls` map).
            if {[hir::escape::arity $escape $instance] ne $wantVirtual} {
                throw {NATIVE BUG} "native lowering: instance $instance has no $wantVirtual-arity scalar companion for $e"
            }
            if {$fieldWidths ne ""} {
                set companionId [FieldsCompanionRef $instance]
            } else {
                set companionId [CompanionRef $instance]
            }
            dict lappend fn calls [list direct $companionId 0]
            set dsts [NewRegs fn $wantVirtual]
            if {$target in $envless} {
                Emit fn [string trimright "[join $dsts { }] = callmulti $companionId [join $argRegs { }]"] $e
            } else {
                Emit fn [string trimright "[join $dsts { }] = callenvmulti $companionId $callee [join $argRegs { }]"] $e
            }
            return [list $dsts virtual]
        }
        if {$wantRegion} {
            # A recognized forwarding region (RegionEligible/hir::stringregion
            # ::classify already confirmed this call is a `remote` region
            # source): the target instance's region companion, reached
            # through callmulti/callenvmulti, hands its (base, start, end)
            # fields straight back with no String ever materialized.
            if {![hir::stringregion::wants $stringregion $instance]} {
                throw {NATIVE BUG} "native lowering: instance $instance has no region companion for $e"
            }
            set companionId [RegionCompanionRef $instance]
            dict lappend fn calls [list direct $companionId 0]
            set dsts [NewRegs fn 3]
            if {$target in $envless} {
                Emit fn [string trimright "[join $dsts { }] = callmulti $companionId [join $argRegs { }]"] $e
            } else {
                Emit fn [string trimright "[join $dsts { }] = callenvmulti $companionId $callee [join $argRegs { }]"] $e
            }
            return [list $dsts region]
        }
        if {$tinyLeafInlineOpt && $fieldWidths eq "" && [LeafInlineEligible $instance]} {
            # A tiny exact-leaf callee (LeafInlineEligible: straight-line,
            # environment-free, nonrecursive, small, guard/error-free body --
            # see "Tiny exact-leaf inlining" below): its body is lowered
            # directly here, inline, in the caller's own function -- never
            # as a `call`/`callenv` to its own compiled function at all for
            # this one call site (the "String regions"/"String traversal"
            # sections' own precedent). ARGREGS is already this call's own
            # ordinary, already-evaluated (exactly once, left-to-right)
            # argument registers.
            return [InlineLeafCall fn $e $node $instance $argRegs]
        }
        set id [expr {$fieldWidths ne "" ? [FieldsRef $instance] : [FunctionRef $instance]}]
        dict lappend fn calls [list direct $id $self]
        set targetPlan [hir::traversal::plan $traversal $instance]
        if {$targetPlan ne ""} {
            # The callee has a TraversalPlan: hir/traversal.tcl's ZeroStart
            # already proved every direct, non-self-tail caller of it
            # (this call site included) passes literal 0 for its own scanned
            # index, so its hidden byte-position parameter starts at byte
            # offset 0 here -- exactly where a semantic index of 0 begins.
            lappend argRegs [IntConst fn 0 $e]
        }
        if {$target in $envless} {
            set result [Assign fn [string trimright "call $id [join $argRegs { }]"] $e]
        } else {
            set result [Assign fn [string trimright "callenv $id $callee [join $argRegs { }]"] $e]
        }
        return [ClosedResult fn $e $result]
    }
    if {$wantVirtual ne ""} {
        throw {NATIVE BUG} "native lowering: cannot virtualize call $e (not a recognized construction)"
    }
    if {$wantRegion} {
        throw {NATIVE BUG} "native lowering: cannot form a region for call $e (not a recognized construction)"
    }

    set argRegs {}
    foreach arg $argExprs {
        set r [Expr fn $arg]
        if {$r eq "never"} {
            return {never tagged}
        }
        lappend argRegs $r
    }
    dict lappend fn calls [list value]
    return [list [Assign fn [string trimright "callvalue $callee [join $argRegs { }]"] $e] tagged]
}

# Lowers E, one of PLAN's recognized accesses (native/lower.tcl's "String
# traversal" section, hir/traversal.tcl's TraversalPlan), inline: reads E's
# own text/index argument expressions (ordinary `Expr fn ... tagged`
# lowering -- a raw-declared index parameter is transparently reboxed by the
# existing TaggedOf machinery, exactly as any other tagged consumer already
# is), then decodes directly at the function's current carried byte
# position instead of calling E's own callee. Matches the access's own
# (peek-shaped) semantics exactly: `if index >= length(text): ""` else the
# one-character String at that index -- never seeking to find it, since
# PLAN's own soundness proof (hir/traversal.tcl's ZeroStart plus the
# self-tail +1 step) is exactly what guarantees the carried byte position
# already corresponds to `index`. Updates `fn traversalByteReg` to the
# decoded scalar's advanced position, read back by Call's self-tail-call
# (`tail`/`tailenv`) argument list once every access in this statement has
# run. Always returns a tagged result (this instance's caller, Call, only
# ever reaches here when an ordinary tagged value is wanted).
proc native::lower::TraversalAccess {fnVar e node plan} {
    upvar 1 $fnVar fn
    set args [dict get $node args]
    set textExpr [lindex $args [dict get $plan textArgOf $e]]
    set indexExpr [lindex $args [dict get $plan indexArgOf $e]]
    set textReg [Expr fn $textExpr]
    if {$textReg eq "never"} {
        return {never tagged}
    }
    set indexReg [Expr fn $indexExpr]
    if {$indexReg eq "never"} {
        return {never tagged}
    }
    set byteReg [dict get $fn traversalByteReg]
    set lenReg [Assign fn "op strlen $textReg" $e]
    set pastEnd [Assign fn "op ige $indexReg $lenReg" $e]
    set emptyLabel [NewLabel fn]
    set decodeLabel [NewLabel fn]
    set joinLabel [NewLabel fn]
    set resultReg [NewReg fn]
    set nextByteReg [NewReg fn]
    Emit fn "br $pastEnd $emptyLabel $decodeLabel" $e
    EmitLabel fn $emptyLabel
    set emptyStr [Assign fn "str [Quote {}]" $e]
    Emit fn "$resultReg = move $emptyStr"
    Emit fn "$nextByteReg = move $byteReg"
    Emit fn "jump $joinLabel"
    EmitLabel fn $decodeLabel
    set charReg [Assign fn "op decodecharat $textReg $byteReg" $e]
    set widthReg [Assign fn "op strbytelen $charReg" $e]
    set advancedReg [Assign fn "op iadd $byteReg $widthReg" $e]
    Emit fn "$resultReg = move $charReg"
    Emit fn "$nextByteReg = move $advancedReg"
    Emit fn "jump $joinLabel"
    EmitLabel fn $joinLabel
    dict set fn traversalByteReg $nextByteReg
    return [list $resultReg tagged]
}

# 1 if expression E (an operand of a native `==`/`length` call TryStringRegionOp
# is deciding) can produce a StringRegion directly (`Expr fn E region`),
# with no runtime kind guard needed first: a direct `substring` call, a
# String literal, a `ref` to a binding hir::stringregion.tcl proved virtual,
# or a direct call to another instance hir::stringregion.tcl recognizes as
# region-producing (Classify's "remote" case). See the "String regions"
# section above.
proc native::lower::RegionEligible {e} {
    variable hir
    variable spec
    variable stringregion
    variable currentInstance
    if {[hir::kind $hir $e] eq "ref"} {
        set b [hir::get $hir $e binding]
        return [expr {$b ne "" && [hir::stringregion::virtual $stringregion $currentInstance $b]}]
    }
    return [expr {[hir::stringregion::classify $hir $spec $stringregion $currentInstance $e] ne ""}]
}

# Tries to lower call E (native NAME, resolving to OP: NativeCallOp) as a
# StringRegion-consuming operation instead of an ordinary `streq`/`strlen`:
# "" if not applicable (the caller falls back to NativeCall's ordinary
# path), else {RESULT REPR} (always "tagged": the *result* of `==`/`length`
# is an ordinary Bool/Int -- only one *operand* is ever a region).
#
#   ==      both operands already statically str-typed (OP resolved to
#           `streq`, so neither ever needs a runtime guard: see
#           NativeCallOp) and at least one is RegionEligible: `regioneq`
#           (that operand's region, the other evaluated ordinarily). Both
#           operands are still evaluated in their original left-to-right
#           order regardless of which one supplies the region (milestone
#           #17: no reordering), preferring the left one as the region
#           when both would qualify (the corpus never exercises
#           region-vs-region, so this is a deliberate, documented
#           narrowing, not a soundness requirement).
#   length  its one argument is RegionEligible and -- like any other
#           `length` call -- needs no guard already proven unnecessary: a
#           plain `isub end start`, exact by construction (Botlish
#           substring bounds are character indices already, so a region's
#           character count is always end-start).
#
# Only ever tried when -string-region-opt is enabled.
proc native::lower::TryStringRegionOp {fnVar e name op argExprs} {
    upvar 1 $fnVar fn
    variable guards
    variable knownErrors
    variable stringRegionOpt
    if {!$stringRegionOpt} {
        return ""
    }
    if {$name eq "==" && $op eq "streq" && [llength $argExprs] == 2} {
        lassign $argExprs ea eb
        set aRegion [RegionEligible $ea]
        set bRegion [expr {!$aRegion && [RegionEligible $eb]}]
        if {!$aRegion && !$bRegion} {
            return ""
        }
        set ra [Expr fn $ea [expr {$aRegion ? "region" : "tagged"}]]
        if {$ra eq "never"} {
            return {never tagged}
        }
        set rb [Expr fn $eb [expr {$bRegion ? "region" : "tagged"}]]
        if {$rb eq "never"} {
            return {never tagged}
        }
        if {$aRegion} {
            lassign $ra base start end
            set other $rb
        } else {
            lassign $rb base start end
            set other $ra
        }
        dict lappend fn calls [list native $name]
        return [list [Assign fn "op regioneq $base $start $end $other" $e] tagged]
    }
    if {$name eq "length" && [llength $argExprs] == 1} {
        set arg [lindex $argExprs 0]
        set key [list $e $arg]
        if {[dict exists $guards $key] || [dict exists $knownErrors $key] || ![RegionEligible $arg]} {
            return ""
        }
        set region [Expr fn $arg region]
        if {$region eq "never"} {
            return {never tagged}
        }
        lassign $region base start end
        dict lappend fn calls [list native $name]
        return [list [Assign fn "op isub $end $start" $e] tagged]
    }
    if {$name in {is_tcl_alpha is_tcl_alnum} && [llength $argExprs] == 1} {
        # core/tclcompat.tcl's one-scalar classification: a region-eligible
        # sole argument classifies directly from the region's own text (see
        # ops.rs's rt_str_region_is_tcl_alpha/alnum), never materializing the
        # one-character String `char_at`-shaped source code (hir/
        # stringregion.tcl's ConsumingNative) usually builds just to classify
        # it once and discard it. Same RANGE contract as the materializing
        # op (both guard/knownError-free by construction: is_tcl_alpha/
        # is_tcl_alnum accept any str, never needing a kind guard).
        set arg [lindex $argExprs 0]
        if {![RegionEligible $arg]} {
            return ""
        }
        set region [Expr fn $arg region]
        if {$region eq "never"} {
            return {never tagged}
        }
        lassign $region base start end
        set rop [expr {$name eq "is_tcl_alpha" ? "strregiontclalpha" : "strregiontclalnum"}]
        dict lappend fn calls [list native $name]
        return [list [Assign fn "op $rop $base $start $end" $e] tagged]
    }
    return ""
}

# 1 if E (in VIEW) is a `ref` naming binding B.
proc native::lower::IsRefToBinding {view e b} {
    return [expr {[hir::kind $view $e] eq "ref" && [hir::get $view $e binding] eq $b}]
}

# Lowers region-consumer instance CALLEEVIEW's own expression E, directly in
# the caller's function FN, substituting REGION (a {base start end} triple
# already lowered in the caller) for every reference to its designated
# consuming parameter B (hir::stringregion::ConsumingParams already proved
# every such reference is one of the three node kinds handled below) --
# never emitting a call to CALLEEVIEW's own compiled function for this call
# site at all (see native/lower.tcl's "String regions" section and the
# "String traversal" section's identical TraversalAccess precedent). Trusts
# ConsumingShape's own structural proof rather than re-deriving it: any
# expression shape besides `if`, a `ref` (to B or to a root true/false/
# native value), or a call to `==`/`length`/a ConsumingNative is a
# hir::stringregion.tcl bug, not a case this lowering falls back from.
proc native::lower::EmitRegionConsumerBody {fnVar calleeView e b region} {
    upvar 1 $fnVar fn
    switch -- [hir::kind $calleeView $e] {
        ref {
            set rb [hir::get $calleeView $e binding]
            return [RootValue fn $e [hir::binding $calleeView $rb]]
        }
        if {
            set node [hir::node $calleeView $e]
            set test [EmitRegionConsumerBody fn $calleeView [dict get $node condition] $b $region]
            if {$test eq "never"} {
                return never
            }
            set then [NewLabel fn]
            set else [NewLabel fn]
            set join [NewLabel fn]
            set result [NewReg fn]
            Emit fn "br $test $then $else" $e
            set joined 0
            foreach {label bodyKey} [list $then thenBody $else elseBody] {
                EmitLabel fn $label
                set body [dict get $node $bodyKey]
                set value [EmitRegionConsumerBody fn $calleeView [lindex $body 0] $b $region]
                if {$value ne "never"} {
                    Emit fn "$result = move $value"
                    Emit fn "jump $join"
                    set joined 1
                }
            }
            if {!$joined} {
                return never
            }
            EmitLabel fn $join
            return $result
        }
        call {
            set node [hir::node $calleeView $e]
            lassign [dict get $node target] targetKind target
            set name [dict get [hir::symbol $calleeView $target] name]
            set args [dict get $node args]
            lassign $region base start end
            dict lappend fn calls [list native $name]
            if {$name eq "==" && [llength $args] == 2} {
                lassign $args pa pb
                set litExpr [expr {[IsRefToBinding $calleeView $pa $b] ? $pb : $pa}]
                set litValue [hir::get $calleeView $litExpr value]
                set litReg [Assign fn "str [Quote [core::value::strOf $litValue]]" $litExpr]
                return [Assign fn "op regioneq $base $start $end $litReg" $e]
            }
            if {$name eq "length" && [llength $args] == 1} {
                return [Assign fn "op isub $end $start" $e]
            }
            # is_tcl_alpha/is_tcl_alnum: ConsumingShape's own structural
            # check allows no other native call to appear here.
            set rop [expr {$name eq "is_tcl_alpha" ? "strregiontclalpha" : "strregiontclalnum"}]
            return [Assign fn "op $rop $base $start $end" $e]
        }
    }
    throw {NATIVE BUG} "native lowering: unexpected region-consumer body shape at $e"
}

# Lowers a direct call to CALLEEID (view BASEHIR/SPEC), given a region-
# eligible argument expression ARGEXPR at its consuming parameter index
# PARAMINDEX (hir::stringregion::consumingParamsOf), by inlining CALLEEID's
# own body against that region (EmitRegionConsumerBody) instead of an actual
# call. Returns {RESULT tagged}, exactly like Call's other dispatch cases.
proc native::lower::InlineRegionConsumerCall {fnVar argExpr calleeId paramIndex} {
    upvar 1 $fnVar fn
    variable baseHir
    variable spec
    set region [Expr fn $argExpr region]
    if {$region eq "never"} {
        return {never tagged}
    }
    set calleeView [hir::specialize::view $baseHir $spec $calleeId]
    set calleeInstance [hir::specialize::instance $spec $calleeId]
    set block [dict get $calleeInstance block]
    set b [lindex [hir::get $calleeView $block params] $paramIndex]
    set body [hir::get $calleeView $block body]
    foreach stmt [lrange $body 0 end-1] {
        if {[EmitRegionConsumerBody fn $calleeView $stmt $b $region] eq "never"} {
            return {never tagged}
        }
    }
    set result [EmitRegionConsumerBody fn $calleeView [lindex $body end] $b $region]
    if {$result eq "never"} {
        return {never tagged}
    }
    return [list $result tagged]
}

# ---------------------------------------------------------------------------
# Tiny exact-leaf inlining (TINY-EXACT-LEAF-INLINING.md)
#
# The narrowest, deliberately non-general form of inlining this compiler
# does. A direct call E (target instance CALLEEID, chosen by hir::specialize
# like any other exact call) whose own callee instance LeafInlineEligible
# proves is a "tiny exact leaf" is lowered (InlineLeafCall) by re-running the
# ordinary per-expression lowering (Sequence/Expr/Bind/NativeCall -- the same
# procs an ordinary function body already goes through) directly against the
# callee's own body, in the caller's own function, instead of ever emitting
# a `call`/`callenv` instruction for this call site. Exactly like the
# "String regions"/"String traversal" sections above: this never touches
# HIR, and never requires the callee's own canonical function to disappear
# -- whatever else in the program still calls it the ordinary way keeps it
# reachable through native::lower::program's own worklist, unchanged.
#
# Eligibility (LeafInlineEligible) is purely structural/effect-based, with
# no callee name anywhere in it:
#
#   - the call's own target is an *exact* instance (hir::specialize already
#     resolved it -- Call only reaches this dispatch when `fn targets`
#     names one) and needs no environment (its block is in ENVLESS: no
#     captures, so no closure value, no capture-list bookkeeping);
#   - its body is a straight-line sequence of `bind`/plain-expression
#     statements -- no `if`, `loop`, `break`, `continue`, `return`, `ok`,
#     `error`, or nested `block` anywhere in it (LeafExprEligible's own
#     allowlist accepts only `const`, `ref`, `bind`, and a safe native
#     `call`) -- which, since `block` is the only HIR shape that could
#     recurse or capture an environment, also makes the body trivially
#     nonrecursive and closure-free with no separate check needed;
#   - every call in the body targets a *native*, never another `block`
#     (this alone rules out recursion, mutual recursion, and any other
#     internal function call: a leaf with zero calls to Botlish functions
#     cannot recurse through one);
#   - every such native call resolves (NativeCallOp) to one of a small,
#     fixed, generic set of pure, total, allocation-free scalar Int ops
#     (LEAFINLINESAFEOPS, above: the arithmetic/comparison/bitwise/shift
#     family already in the `natives` op table -- deliberately not `imod`,
#     not equality across non-Int kinds, not any string/list/hash/mutable-
#     array op, none of which this milestone attempts to prove error- or
#     allocation-free);
#   - none of the body's own calls is *proven* to always raise
#     (hir::aot's own `knownErrors` blocker fact -- computed here for the
#     callee's own instance specifically, via the same
#     hir::aot::analyzeRegion + CollectChecks every ordinary function
#     lowering already runs for itself, in Function above). An ordinary,
#     merely-*unproven* runtime kind guard (`guards`) is deliberately *not*
#     a reason to decline: EmitArgGuards emits that exact same check
#     wherever NativeCall runs a native call, inlined here or not -- the
#     real byte::high_nibble(b) case (its own `b` is not statically proven
#     int at web.bot's call site) needs exactly this to still inline (the
#     milestone's own mandatory acceptance target): the check simply moves
#     with the operation, on the same value, checked before it is used
#     either way, so this introduces no new possible failure and preserves
#     the same error on the same input;
#   - a shift call (`ishr`/`ishl`) additionally proves (LeafShiftSafe) its
#     own shift amount a single already-known value strictly within
#     RAWSHIFTMAX (the same bound RawEligibleShift already uses): the only
#     one of these ops whose generic runtime helper can otherwise raise a
#     semantic RANGE error, so this is the one place eligibility directly
#     proves an otherwise-possible error path statically excluded, rather
#     than merely reading an existing blocker fact -- deliberately narrower
#     than RawEligibleShift's own raw-*representation* proof: this only
#     needs the shift to be unable to *error*, not to be raw-lowerable, so
#     it does not require the shifted value's own sign or size at all
#     (core::scalarbits::shiftRight/shiftLeft only ever check the amount);
#     whether the shift ends up raw or tagged afterward is still entirely
#     NativeCall's own ordinary, unrelated decision, made the same way
#     whether this body was inlined or not (spec's own "do not force
#     rawness");
#   - the body's own total native-call count does not exceed
#     LEAFINLINEMAXOPS (8, above): comfortably above both real target
#     bodies (byte::high_nibble's 1 call, byte::nibble's 4), with headroom
#     for a small synthetic multi-op test, not guessed large.
#
# Argument evaluation (InlineLeafCall): CALLERARGREGS is the *same* already-
# lowered list Call's own ordinary block-call path already computed
# (CallArgs, just above this dispatch) -- every argument expression is
# evaluated exactly once, in its own original left-to-right order, with
# whatever side effects or errors it may have, *before* InlineLeafCall is
# ever reached at all: an unused callee parameter's own argument is still
# evaluated (CallArgs evaluates every argument unconditionally, whether or
# not the callee body ever references the corresponding parameter), and an
# argument that itself "never"s (errors) short-circuits Call itself before
# InlineLeafCall is ever reached. Substitution needs no bespoke environment
# of its own: `fn locals` is already keyed by BindingId, and hir.tcl's IDs
# are allocated once, monotonically, over the *whole* program (hir/hir.tcl's
# own header) -- so a callee's own parameter BindingId can never collide
# with any binding already live in the caller's `fn locals`. Binding the
# callee's parameter BindingIds directly to the caller's own already-
# evaluated argument registers (`[list reg $r]`, the same shape Function
# itself gives an ordinary parameter) is therefore both sufficient and safe:
# every `ref` to that parameter anywhere in the callee's body resolves
# through the *ordinary* Access/Ref machinery, identically to any other
# already-bound local, with no new code path in either proc.
#
# Facts and provenance: HIR/CURRENTINSTANCE/GUARDS/KNOWNERRORS are switched
# to the callee's own specialized view and instance id for exactly the
# duration of lowering its body (saved and restored around it -- the same
# discipline If/Loop already use for `fn rawCache`), so hir::range::of,
# RawEligibleCall/RawEligibleShift/PureBitwiseEligible and every other
# lowering-time decision inside the callee's own body read *its own*
# instance's already-computed facts (hir::range::analyze already analyzed
# every used instance, callees included, in one whole-program fixpoint --
# nothing here recomputes them): an intermediate value can stay raw across
# what used to be the function boundary exactly when ordinary
# representation analysis would already keep it raw within one function,
# with no inlining-specific representation rule of any kind. Every emitted
# instruction still carries its own HIR expression id (Emit's own `@E`
# suffix, unchanged), so it still names its true origin inside the callee's
# own source -- byte::nibble's `x & 15` stays traceable to byte::nibble's
# own expression, not to a synthetic node, even though it now runs inside
# its caller's own compiled function.

# 1 if instance ID is a tiny exact leaf (see above): memoized in
# LEAFELIGIBLE (reset once per native::lower::program call), since the same
# callee instance may be reached from several exact call sites.
proc native::lower::LeafInlineEligible {id} {
    variable leafEligible
    if {[dict exists $leafEligible $id]} {
        return [dict get $leafEligible $id]
    }
    set ok [LeafInlineEligibleUncached $id]
    dict set leafEligible $id $ok
    return $ok
}

proc native::lower::LeafInlineEligibleUncached {id} {
    variable baseHir
    variable spec
    variable context
    variable envless
    variable hir
    variable currentInstance
    variable guards
    variable knownErrors
    set instance [hir::specialize::instance $spec $id]
    set block [dict get $instance block]
    if {$block eq "program" || $block ni $envless} {
        return 0
    }
    set savedHir $hir
    set savedInstance $currentInstance
    set hir [hir::specialize::view $baseHir $spec $id]
    set currentInstance $id
    # Structure-only pre-filter (LeafBlockLooksSmall), before ever paying
    # for hir::aot::analyzeRegion: compile-time cost (spec's own \167 90 "a
    # tiny exact-leaf pass should be cheap") -- a branchy/loopy/large/
    # internal-calling body is rejected by a single cheap walk of its own
    # shape, with no per-instance analysis run for it at all. Only a body
    # that already structurally looks like a candidate pays for the full
    # guard/known-error analysis below.
    if {![LeafBlockLooksSmall $block]} {
        set hir $savedHir
        set currentInstance $savedInstance
        return 0
    }
    set savedGuards $guards
    set savedKnownErrors $knownErrors
    CollectChecks [hir::aot::analyzeRegion $hir $block $context]
    set body [hir::get $hir $block body]
    set ops 0
    set ok [expr {$body ne "" && [LeafBodyEligible $body ops]}]
    set hir $savedHir
    set currentInstance $savedInstance
    set guards $savedGuards
    set knownErrors $savedKnownErrors
    return $ok
}

# The cheap half of LeafInlineEligible: BLOCK's own body shape and op-count
# budget alone (LeafExprStructural, below), with no guard/known-error/shift-
# safety analysis at all -- gates whether the more expensive
# hir::aot::analyzeRegion + CollectChecks is ever run for this instance.
proc native::lower::LeafBlockLooksSmall {block} {
    variable hir
    set body [hir::get $hir $block body]
    if {$body eq ""} {
        return 0
    }
    set ops 0
    foreach s $body {
        if {![LeafExprStructural $s ops]} {
            return 0
        }
    }
    return 1
}

# Structure/op-count-only half of LeafExprEligible's own allowlist (same
# shape, minus the guard/known-error/shift-safety checks, which need
# GUARDS/KNOWNERRORS already populated for this instance -- see
# LeafBlockLooksSmall above).
proc native::lower::LeafExprStructural {e opsVar} {
    upvar 1 $opsVar ops
    variable hir
    variable leafInlineSafeOps
    variable leafInlineMaxOps
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const { return 1 }
        ref    { return 1 }
        bind   { return [LeafExprStructural [dict get $node value] ops] }
        call {
            lassign [dict get $node target] targetKind target
            if {$targetKind ne "native"} {
                return 0
            }
            lassign [NativeCallOp $e $node] name op
            if {$op eq "" || $op ni $leafInlineSafeOps} {
                return 0
            }
            foreach a [dict get $node args] {
                if {![LeafExprStructural $a ops]} {
                    return 0
                }
            }
            incr ops
            return [expr {$ops <= $leafInlineMaxOps}]
        }
    }
    return 0
}

proc native::lower::LeafBodyEligible {stmts opsVar} {
    upvar 1 $opsVar ops
    foreach s $stmts {
        if {![LeafExprEligible $s ops]} {
            return 0
        }
    }
    return 1
}

# 1 if E (in the callee's own view, HIR/CURRENTINSTANCE/GUARDS/KNOWNERRORS
# already switched to it by the caller) is one of LeafInlineEligible's
# allowed body shapes, counting every native call it contains into OPSVAR
# and declining once LEAFINLINEMAXOPS is exceeded.
proc native::lower::LeafExprEligible {e opsVar} {
    upvar 1 $opsVar ops
    variable hir
    variable guards
    variable knownErrors
    variable leafInlineSafeOps
    variable leafInlineMaxOps
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        const { return 1 }
        ref    { return 1 }
        bind   { return [LeafExprEligible [dict get $node value] ops] }
        call {
            lassign [dict get $node target] targetKind target
            if {$targetKind ne "native"} {
                return 0
            }
            lassign [NativeCallOp $e $node] name op
            if {$op eq "" || $op ni $leafInlineSafeOps} {
                return 0
            }
            set argExprs [dict get $node args]
            foreach a $argExprs {
                if {![LeafExprEligible $a ops]} {
                    return 0
                }
                set key [list $e $a]
                if {[dict exists $knownErrors $key]} {
                    # A representation blocker (an ordinary runtime kind
                    # guard, GUARDS above) is deliberately *not* checked
                    # here: EmitArgGuards emits that exact same check
                    # wherever NativeCall runs, inlined or not -- the same
                    # single contract check, on the same value, in the same
                    # position relative to its own operand's evaluation,
                    # just relocated into the caller's own function. A
                    # KNOWNERRORS entry is different in kind (the call is
                    # *proven* to always raise, not merely unproven-safe),
                    # so that alone still declines eligibility.
                    return 0
                }
            }
            if {$op in {ishr ishl} && ![LeafShiftSafe $e $argExprs]} {
                return 0
            }
            incr ops
            return [expr {$ops <= $leafInlineMaxOps}]
        }
    }
    return 0
}

# 1 if shift call E's (op ishr/ishl, ARGEXPRS = {value amount}) own amount
# operand is a single already-proven value strictly within RAWSHIFTMAX: the
# only condition (core/scalarbits.tcl's CheckShiftAmount) under which the
# generic shift_right/shift_left helper this call would otherwise lower to
# can raise {CORE SEMANTIC RANGE} -- proven the same way RawEligibleShift
# already proves it for its own, stricter, raw-representation purpose,
# reusing the same RAWSHIFTMAX bound (deliberately not the shifted value's
# own sign/size: unlike raw eligibility, error-safety here does not depend
# on it at all -- core::scalarbits::shiftRight/shiftLeft only ever check the
# amount).
proc native::lower::LeafShiftSafe {e argExprs} {
    variable ranges
    variable currentInstance
    variable rawShiftMax
    if {[llength $argExprs] != 2} {
        return 0
    }
    lassign $argExprs ex ek
    set rangeK [hir::range::of $ranges $currentInstance $ek]
    set kmn [dict get $rangeK min]
    set kmx [dict get $rangeK max]
    if {$kmn eq "-inf" || $kmn ne $kmx || $kmn < 0 || $kmn >= $rawShiftMax} {
        return 0
    }
    return 1
}

# Lowers exact direct call E (node NODE, callee instance CALLEEID,
# LeafInlineEligible already proved -- CALLERARGREGS its own already-
# evaluated argument registers, Call's own ordinary CallArgs, in the
# caller's original left-to-right evaluation order) by re-running the
# ordinary per-expression lowering (Sequence/Expr/Bind/NativeCall -- the
# same procs an ordinary function body already goes through) directly
# against the callee's own body, in the caller's own function FN, with
# HIR/CURRENTINSTANCE/GUARDS/KNOWNERRORS switched to the callee's own
# specialized view for the duration (saved and restored around it) and its
# parameter BindingIds bound, in FN's own `locals`, directly to
# CALLERARGREGS (see the section header above for why this substitution is
# sufficient and safe). Returns {RESULT tagged}, exactly like Call's other
# dispatch cases -- never emits a `call`/`callenv` instruction for E at all.
proc native::lower::InlineLeafCall {fnVar e node calleeId callerArgRegs} {
    upvar 1 $fnVar fn
    variable hir
    variable baseHir
    variable spec
    variable context
    variable currentInstance
    variable guards
    variable knownErrors
    set instance [hir::specialize::instance $spec $calleeId]
    set block [dict get $instance block]
    set calleeView [hir::specialize::view $baseHir $spec $calleeId]
    set params [hir::get $calleeView $block params]
    set body [hir::get $calleeView $block body]

    set savedHir $hir
    set savedInstance $currentInstance
    set savedGuards $guards
    set savedKnownErrors $knownErrors
    set savedLocals {}
    foreach b $params {
        lappend savedLocals [expr {[dict exists $fn locals $b] ? [dict get $fn locals $b] : ""}]
    }

    set hir $calleeView
    set currentInstance $calleeId
    CollectChecks [hir::aot::analyzeRegion $hir $block $context]
    foreach b $params r $callerArgRegs {
        dict set fn locals $b [list reg $r]
    }
    EnterScope fn [hir::get $hir $block bodyScope]
    set result [Sequence fn $body]

    set hir $savedHir
    set currentInstance $savedInstance
    set guards $savedGuards
    set knownErrors $savedKnownErrors
    foreach b $params saved $savedLocals {
        if {$saved eq ""} {
            dict unset fn locals $b
        } else {
            dict set fn locals $b $saved
        }
    }

    if {$result eq "never"} {
        return {never tagged}
    }
    return [list $result tagged]
}

# {NAME OP}: the native NODE's target's name, and the NIR op its call
# resolves to (an "equality" implementation picks veq/ieq/streq from the two
# argument expressions' static types, exactly as NativeCall always has) --
# purely static, so eligibility (RawEligibleCall) can be decided before any
# argument is lowered. OP is "" for a name native/lower.tcl does not
# implement (NativeCall's own existence check reports that properly; this
# only needs to not throw first).
proc native::lower::NativeCallOp {e node} {
    variable hir
    variable natives
    lassign [dict get $node target] targetKind target
    set name [dict get [hir::symbol $hir $target] name]
    if {![dict exists $natives $name]} {
        return [list $name ""]
    }
    set impl [dict get $natives $name]
    if {[lindex $impl 0] ne "equality"} {
        return [list $name [lindex $impl 1]]
    }
    set argExprs [dict get $node args]
    if {[llength $argExprs] != 2} {
        return [list $name veq]
    }
    lassign $argExprs a b
    set ka [hir::types::kindOf [hir::typeOf $hir $a]]
    set kb [hir::types::kindOf [hir::typeOf $hir $b]]
    set op veq
    if {$ka eq $kb && $ka eq "int"} {
        set op ieq
    } elseif {$ka eq $kb && $ka eq "str"} {
        set op streq
    }
    return [list $name $op]
}

# Emits the runtime kind guard (or known-error guard) hir::aot already
# decided each of ARGEXPRS (call E's arguments, now lowered as ARGREGS) needs
# for a call whose native's declared parameter types are PARAMTYPES -- shared
# by NativeCall's ordinary path and the "String regions" section's own
# `substring`-as-region lowering (Call's `wantRegion` case), which bypasses
# NativeCall entirely but still owes its three operands the exact same
# checks an ordinary `substring` call would have run.
proc native::lower::EmitArgGuards {fnVar e argExprs argRegs paramTypes name} {
    upvar 1 $fnVar fn
    variable hir
    variable guards
    variable knownErrors
    foreach arg $argExprs r $argRegs type $paramTypes {
        if {$type in {"" any}} {
            continue
        }
        set key [list $e $arg]
        if {[dict exists $guards $key]} {
            Emit fn "guard [core::type::base [dict get $guards $key]] $r [Quote $name]" $e
            dict incr fn guards
        } elseif {[dict exists $knownErrors $key]} {
            # Statically of another kind: the check always fails.
            Emit fn "guard [core::type::base $type] $r [Quote $name]" $e
            dict incr fn knownErrorGuards
        } elseif {![core::type::subtype [hir::types::semantic [hir::typeOf $hir $arg]] $type]
                  && [hir::typeOf $hir $arg] ne "never"} {
            throw {NATIVE BUG} "native lowering: hir::aot reports no check for argument $arg of $name ($e)"
        }
    }
}

# Checked construction for a source-defined *interval*-domain integer
# refinement (Byte(x), a source-declared Small(x), ... --
# SOURCE-DEFINED-INTEGER-DOMAINS.md): NAME's own registered -impl is
# {core::type::CheckedConstruct NAME}, the one generic Tcl implementation
# every such type's constructor shares (core/type.tcl), never a per-type
# native. This is composed entirely from *existing* NIR forms (guard, op
# ige/ile, br/raise/label) -- no new NIR instruction and no Rust codegen
# change: NAME's own LO/HI domain bounds are ordinary compile-time-known Int
# constants (hir/sourcetypes.tcl already validated and registered them when
# the type was declared), so the only genuinely dynamic thing here is the
# *value* being checked, exactly the shape an ordinary hand-written `if v >=
# LO and v <= HI` guard already lowers to. Returns {REG tagged} when NAME is
# such a constructor over an interval domain (the only domain shape this
# handles: byte::set's own Byte(...) calls, and every other interval-domain
# type, e.g. Nibble/LowNibble/a source-declared Small); "" for anything else
# (an *exact*-domain constructor such as HighNibble, or an ordinary
# unsupported native), so the caller falls through to the existing {NATIVE
# UNSUPPORTED} diagnostic completely unchanged -- no Byte-specific path, no
# special-casing by name anywhere in this proc.
proc native::lower::CheckedIntDomainConstruct {fnVar e node name meta argRegs} {
    upvar 1 $fnVar fn
    set impl [dict get $meta impl]
    if {[lindex $impl 0] ne "core::type::CheckedConstruct"} {
        return ""
    }
    set typeName [lindex $impl 1]
    set domain [dict get [core::type::metadata $typeName] integerDomain]
    if {[lindex $domain 0] ne "interval"} {
        return ""
    }
    lassign $domain _ lo hi
    dict lappend fn calls [list native $name]
    EmitArgGuards fn $e [dict get $node args] $argRegs [dict get $meta paramTypes] $name
    set v [lindex $argRegs 0]
    set loReg [IntConst fn $lo $e]
    set hiReg [IntConst fn $hi $e]
    set okLo [Assign fn "op ige $v $loReg" $e]
    set checkHi [NewLabel fn]
    set fail [NewLabel fn]
    set ok [NewLabel fn]
    Emit fn "br $okLo $checkHi $fail" $e
    EmitLabel fn $checkHi
    set okHi [Assign fn "op ile $v $hiReg" $e]
    Emit fn "br $okHi $ok $fail" $e
    EmitLabel fn $fail
    Emit fn "raise RANGE [Quote "$typeName: value is not a valid $typeName"]" $e
    EmitLabel fn $ok
    return [list $v tagged]
}

proc native::lower::NativeCall {fnVar e node name argRegs rawEligible op want} {
    upvar 1 $fnVar fn
    variable hir
    variable natives
    variable guards
    variable knownErrors
    set meta [core::native::metadata $name]
    set arity [dict get $meta arity]
    if {$arity ne "*" && $arity != [llength $argRegs]} {
        Emit fn "raise ARITY [Quote "$name expects $arity argument(s), got [llength $argRegs]"]" $e
        return {never tagged}
    }
    if {[dict get $node known] ne ""} {
        # A type test HIR already decided statically (Call, above, already
        # ran the arguments): the result exists, so nothing else does --
        # not even a native implementation of NAME, whether or not
        # native/lower.tcl otherwise supports it. An operation HIR has
        # already proven unnecessary should not need to exist natively
        # merely in order to disappear.
        return [list [Assign fn "bool [expr {[dict get $node known] ? "true" : "false"}]" $e] tagged]
    }
    if {![dict exists $natives $name]} {
        set checked [CheckedIntDomainConstruct fn $e $node $name $meta $argRegs]
        if {$checked ne ""} {
            return $checked
        }
        Unsupported $e "native $name" "the native \"$name\" has no native implementation"
    }
    dict lappend fn calls [list native $name]
    set testsType [dict get $meta testsType]
    if {$testsType ne "" && [llength $testsType] > 1 && $name ni {ok? error?}} {
        Unsupported $e "native $name" "type tests of named types need evidence, which is not supported natively"
    }
    # Unaffected by rawEligible: RawEligibleCall already required every
    # int-typed operand to need neither a guard nor a known-error guard, so
    # this loop is a no-op (falls through its subtype-proven case) whenever
    # rawEligible is true -- run unconditionally anyway, so the "hir::aot
    # proved no check" assertion below still covers every call the same way
    # it always has.
    set argExprs [dict get $node args]
    EmitArgGuards fn $e $argExprs $argRegs [dict get $meta paramTypes] $name
    if {[PureBitwiseEligible $e $argExprs $op]} {
        set folded [FoldPureBitwise fn $e $argExprs $argRegs $op $want]
        if {$folded ne ""} {
            return $folded
        }
    }
    if {$rawEligible} {
        # ARGREGS are already raw (Call requested it): lower directly, with
        # no RawOf needed on either operand.
        lassign $argRegs xa xb
        set rawOp [dict get {
            iadd riadd  isub risub  imul rimul
            ilt  rilt   ile  rile   igt  rigt   ige rige   ieq rieq
            ishr rishr  ishl rishl
        } $op]
        set arith [expr {$op in {iadd isub imul ishr ishl}}]
        if {$arith} {
            set r [AssignRaw fn "op $rawOp $xa $xb" $e]
        } else {
            # A raw comparison's result is a tagged Bool, not raw (nir.rs's
            # OpCode::raw_result is false for rilt/rile/rigt/rige/rieq).
            set r [Assign fn "op $rawOp $xa $xb" $e]
        }
        dict incr fn [expr {$arith ? "rawArith" : "rawCompare"}]
        if {!$arith} {
            return [list $r tagged]
        }
        if {$want eq "raw"} {
            return [list $r raw]
        }
        return [list [TaggedOf fn $r] tagged]
    }
    set raw [RawIntOp fn $e $argExprs $argRegs $op $want]
    if {$raw ne ""} {
        return $raw
    }
    return [list [Assign fn [string trimright "op $op [join $argRegs { }]"] $e] tagged]
}

# ---------------------------------------------------------------------------
# Pure bitwise simplification (spec #23-27): a lowering-time-only decision,
# exactly like raw representation itself -- never a HIR rewrite, never
# changes what a value *is*, only which instructions native code emits for
# it. Both procs below are gated on PureBitwiseEligible's own guard-safety
# check, which mirrors RawEligibleCall's: a call whose operand still needs a
# runtime kind guard is not proven to even evaluate to an Int, so neither a
# constant nor an algebraic-identity replacement would be sound (spec #26).
# argRegs are already fully evaluated by the time NativeCall runs (Call
# always evaluates every argument first, unconditionally), so choosing not
# to emit iand/ior/ixor here never skips an evaluation that may have had a
# side effect -- it only ever discards the (already pure, allocation-free,
# total) operation itself.

# Whether E (a call to the pure, total, two-operand bitwise native OP: iand,
# ior, or ixor) is eligible for FoldPureBitwise below.
proc native::lower::PureBitwiseEligible {e argExprs op} {
    variable reprOpt
    variable guards
    variable knownErrors
    if {!$reprOpt || $op ni {iand ior ixor} || [llength $argExprs] != 2} {
        return 0
    }
    foreach a $argExprs {
        set key [list $e $a]
        if {[dict exists $guards $key] || [dict exists $knownErrors $key]} {
            return 0
        }
    }
    return 1
}

# {REG REPR}, or "" to fall back to the ordinary `op iand/ior/ixor` emission.
# Two independent, purely generic simplifications, both decided from
# hir/range.tcl's own already-computed facts (no code here names a type or a
# specific mask):
#
#   1. E's own result is a single proven value (a point Range): the whole
#      call becomes that Int constant directly (spec #23-26's own worked
#      example, `x & 15 -> 0` for the real HighNibble-domain caller).
#
#   2. Otherwise, for `ior`/`ixor`: if one operand is provably exactly 0,
#      the result is unconditionally the other operand's own value (`0|x`,
#      `x|0`, `0^x`, `x^0` all equal `x` for ordinary Int bit semantics --
#      spec #27). For `iand`: if one operand (B) is a single proven constant
#      and the other (A) is nonnegative, and the call's own already-computed
#      result range/exact-set exactly equals A's own, then this AND changes
#      nothing: AND-with-any-mask can only ever clear bits of a nonnegative
#      A (so `a&b <= a` for every a>=0, any b), so a value set that maps
#      *onto itself* under a fixed mask must map every element to itself
#      (a self-map of a finite set bounded above by the identity, hitting
#      every element, is forced to be the identity) -- this is what removes
#      the real body's own trailing `bit_and(..., 15)` once the OR it wraps
#      has already been proven to stay within `[0, 15]` (spec #3's "final
#      masking required by its broad all-Int implementation").
proc native::lower::FoldPureBitwise {fnVar e argExprs argRegs op want} {
    upvar 1 $fnVar fn
    variable ranges
    variable currentInstance
    set resultRange [hir::range::of $ranges $currentInstance $e]
    set rmn [dict get $resultRange min]
    if {$rmn ne "-inf" && $rmn eq [dict get $resultRange max]} {
        return [WantConvert fn [IntConst fn $rmn $e] $want]
    }
    lassign $argExprs ea eb
    lassign $argRegs ra rb
    set eaRange [hir::range::of $ranges $currentInstance $ea]
    set ebRange [hir::range::of $ranges $currentInstance $eb]
    if {$op eq "iand"} {
        set eamn [dict get $eaRange min]
        set eamx [dict get $eaRange max]
        set ebmn [dict get $ebRange min]
        set ebmx [dict get $ebRange max]
        if {$eamn ne "-inf" && $eamn >= 0 && $ebmn ne "-inf" && $ebmn eq $ebmx
                && $resultRange eq $eaRange} {
            return [WantConvert fn $ra $want]
        }
        if {$ebmn ne "-inf" && $ebmn >= 0 && $eamn ne "-inf" && $eamn eq $eamx
                && $resultRange eq $ebRange} {
            return [WantConvert fn $rb $want]
        }
        return ""
    }
    foreach {zeroRange keepReg} [list $eaRange $rb $ebRange $ra] {
        if {[dict get $zeroRange min] eq 0 && [dict get $zeroRange max] eq 0} {
            return [WantConvert fn $keepReg $want]
        }
    }
    return ""
}

# {REG REPR}: REG converted to WANT's representation (both already-known
# representations: REG is always tagged here), reusing RawOf's own cache.
proc native::lower::WantConvert {fnVar reg want} {
    upvar 1 $fnVar fn
    if {$want eq "raw"} {
        return [list [RawOf fn $reg] raw]
    }
    return [list $reg tagged]
}

# ---------------------------------------------------------------------------
# Representation: local unboxing of proven-small Int arithmetic/comparisons
#
# Every operand here already has kind Int by this point (a guard just ran,
# or hir::aot proved it statically: see NativeCall above and CollectChecks).
# Representation is strictly downstream of that: this only decides whether
# the two (already Int) operands, and the arithmetic result, additionally
# fit the runtime's small-Int range (hir/range.tcl), so the operation can run
# on raw machine integers instead of through the tagged fast/slow path
# (native/src/codegen/clif.rs's int_arith/int_compare, which still handles
# every other case exactly as before, including BigInt overflow).

# Whether a native call to OP (already resolved: NativeCallOp) on ARG-EXPRS
# can lower its operands raw directly: reprOpt is on, OP is one of the
# raw-representable `+ - * < <= > >= ==`, there are exactly two arguments,
# *neither* needs a runtime kind guard or known-error guard (CollectChecks's
# guards/knownErrors: those run on a tagged register, so representation
# stays strictly downstream of them, same as always -- see RawIntOp below for
# the case where a guard *is* needed first), and both operands' (and, for
# arithmetic, the result's) ranges hir/range.tcl proved fit the small-Int
# representation. Decided purely from ARG-EXPRS/E, before either argument is
# lowered, so Call can ask each for raw directly instead of tagged-then-RawOf.
# `ishr`/`ishl` (proven-safe shifts -- RawEligibleShift) get the same
# treatment through the same entry point, so a shift chained onto another
# raw-eligible expression never needlessly boxes the intermediate value.
proc native::lower::RawEligibleCall {e argExprs op} {
    variable reprOpt
    variable ranges
    variable currentInstance
    variable guards
    variable knownErrors
    if {!$reprOpt || [llength $argExprs] != 2} {
        return 0
    }
    if {$op in {ishr ishl}} {
        return [RawEligibleShift $e $argExprs $op]
    }
    if {$op ni {iadd isub imul ilt ile igt ige ieq}} {
        return 0
    }
    lassign $argExprs ea eb
    foreach a [list $ea $eb] {
        set key [list $e $a]
        if {[dict exists $guards $key] || [dict exists $knownErrors $key]} {
            return 0
        }
    }
    set rangeA [hir::range::of $ranges $currentInstance $ea]
    set rangeB [hir::range::of $ranges $currentInstance $eb]
    if {![hir::range::fitsSmall $rangeA] || ![hir::range::fitsSmall $rangeB]} {
        return 0
    }
    if {$op in {iadd isub imul}} {
        switch -- $op {
            iadd { set r [hir::range::add $rangeA $rangeB] }
            isub { set r [hir::range::sub $rangeA $rangeB] }
            imul { set r [hir::range::mul $rangeA $rangeB] }
        }
        if {![hir::range::fitsSmall $r]} {
            return 0
        }
    }
    return 1
}

# Raw-shift eligibility (spec #33-41, #47): OP (ishr/ishl) qualifies for raw
# lowering only when every semantic obligation is statically proven, so the
# generic runtime helper (rt_int_shl/rt_int_shr: BigInt promotion, the
# 0<=k<=MAX_SHIFT validity check) can be skipped entirely rather than merely
# inlined --
#
#   * neither operand needs a runtime kind guard or known-error guard (same
#     discipline as RawEligibleCall's own arithmetic/comparison case);
#   * the shifted value X's own range fits the small-Int representation and
#     is proven nonnegative -- deliberately conservative (spec #47): a raw
#     right shift of a negative host machine integer is an arithmetic shift
#     (sign-extending), which happens to match Botlish's own arbitrary-
#     precision floor-shift semantics for negative operands too, but this
#     milestone does not attempt to prove that equivalence rigorously for
#     every case (e.g. a negative X straddling a raw/BigInt representation
#     boundary), so negative X is simply left on the generic path;
#   * the shift amount K's range is a single already-proven value (spec
#     #40's own conservative first cut -- an interval would also be sound
#     for shift_right specifically, since it is monotonically non-increasing
#     in K, but a single proven value is enough for the mandatory case and
#     keeps this proc's own soundness argument trivial for shift_left too,
#     where growth makes an interval-only proof more delicate), itself
#     nonnegative and strictly below rawShiftMax -- far inside the
#     language's own MAX_SHIFT contract (core/scalarbits.tcl), so a shift
#     amount that passes this check can never be the invalid-shift error
#     case;
#   * E's own already-computed result range (hir::range::of -- Phase A's own
#     shift_right/shift_left transfer) also fits the small-Int
#     representation, so the raw result never needs to escape into BigInt
#     (this is the load-bearing check for shift_left, spec #38-39; for
#     shift_right it is automatically true whenever X's own range fits,
#     since a nonnegative right shift never grows the value, but checking it
#     uniformly keeps both operations under one proof).
proc native::lower::RawEligibleShift {e argExprs op} {
    variable reprOpt
    variable ranges
    variable currentInstance
    variable guards
    variable knownErrors
    variable rawShiftMax
    if {!$reprOpt || [llength $argExprs] != 2} {
        return 0
    }
    lassign $argExprs ex ek
    foreach a [list $ex $ek] {
        set key [list $e $a]
        if {[dict exists $guards $key] || [dict exists $knownErrors $key]} {
            return 0
        }
    }
    set rangeX [hir::range::of $ranges $currentInstance $ex]
    if {![hir::range::fitsSmall $rangeX] || [dict get $rangeX min] eq "-inf"
            || [dict get $rangeX min] < 0} {
        return 0
    }
    set rangeK [hir::range::of $ranges $currentInstance $ek]
    set kmn [dict get $rangeK min]
    set kmx [dict get $rangeK max]
    if {$kmn eq "-inf" || $kmn ne $kmx || $kmn < 0 || $kmn >= $rawShiftMax} {
        return 0
    }
    set resultRange [hir::range::of $ranges $currentInstance $e]
    return [hir::range::fitsSmall $resultRange]
}

# The RawEligibleCall-declined path: OP already ran on tagged ARG-REGS (a
# guard may just have checked one of them), so this only asks whether the
# operands' ranges retroactively also qualify for raw lowering -- unlike
# RawEligibleCall, it consumes already-lowered registers, converting with
# RawOf rather than asking Expr to produce raw from scratch. Emits the raw
# form and returns {REG REPR} (comparisons: always tagged; arithmetic and
# shifts: raw if WANT is raw, else reboxed once). Otherwise emits nothing and
# returns "": the caller falls back to the plain tagged `op`. Formerly
# RawArithOrCompare; renamed once shifts joined arithmetic/comparison as a
# third kind of raw-eligible integer operation (spec #31).
proc native::lower::RawIntOp {fnVar e argExprs argRegs op want} {
    upvar 1 $fnVar fn
    variable reprOpt
    if {!$reprOpt || [llength $argExprs] != 2} {
        return ""
    }
    if {$op in {ishr ishl}} {
        if {![RawEligibleShift $e $argExprs $op]} {
            return ""
        }
        lassign $argRegs ra rb
        set xa [RawOf fn $ra]
        set xb [RawOf fn $rb]
        set rawOp [expr {$op eq "ishr" ? "rishr" : "rishl"}]
        set r [AssignRaw fn "op $rawOp $xa $xb" $e]
        dict incr fn rawArith
        if {$want eq "raw"} {
            return [list $r raw]
        }
        return [list [TaggedOf fn $r] tagged]
    }
    if {$op ni {iadd isub imul ilt ile igt ige ieq}} {
        return ""
    }
    variable ranges
    variable currentInstance
    lassign $argExprs ea eb
    lassign $argRegs ra rb
    set rangeA [hir::range::of $ranges $currentInstance $ea]
    set rangeB [hir::range::of $ranges $currentInstance $eb]
    if {![hir::range::fitsSmall $rangeA] || ![hir::range::fitsSmall $rangeB]} {
        return ""
    }
    set arith [expr {$op in {iadd isub imul}}]
    if {$arith} {
        switch -- $op {
            iadd { set resultRange [hir::range::add $rangeA $rangeB] }
            isub { set resultRange [hir::range::sub $rangeA $rangeB] }
            imul { set resultRange [hir::range::mul $rangeA $rangeB] }
        }
        if {![hir::range::fitsSmall $resultRange]} {
            return ""
        }
    }
    set rawOp [dict get {
        iadd riadd  isub risub  imul rimul
        ilt  rilt   ile  rile   igt  rigt   ige rige   ieq rieq
    } $op]
    set xa [RawOf fn $ra]
    set xb [RawOf fn $rb]
    if {$arith} {
        set r [AssignRaw fn "op $rawOp $xa $xb" $e]
    } else {
        # A raw comparison's result is a tagged Bool, not raw (nir.rs's
        # OpCode::raw_result is false for rilt/rile/rigt/rige/rieq).
        set r [Assign fn "op $rawOp $xa $xb" $e]
    }
    dict incr fn [expr {$arith ? "rawArith" : "rawCompare"}]
    if {!$arith} {
        return [list $r tagged]
    }
    if {$want eq "raw"} {
        return [list $r raw]
    }
    return [list [TaggedOf fn $r] tagged]
}

# The raw (untagged) machine-integer form of tagged register REG, already
# proven a small Int: unboxes it once (op runbox) and remembers the result
# for later reads/arithmetic of the same register (fn rawCache).
proc native::lower::RawOf {fnVar reg} {
    upvar 1 $fnVar fn
    set cache [dict get $fn rawCache]
    if {[dict exists $cache $reg]} {
        return [dict get $cache $reg]
    }
    set r [AssignRaw fn "op runbox $reg"]
    dict incr fn rawUnboxes
    dict set fn rawCache $reg $r
    dict set fn rawCache $r $reg
    return $r
}

# The tagged (boxed) form of a RAW register REG, already proven a small Int
# by construction (a rawreg parameter: see Function/RawParams below): the
# mirror of RawOf, boxing it once (op rbox) and remembering the result (fn
# rawCache, the same cache RawOf reads/writes -- register numbers are unique,
# so the two directions never collide) so a later RawOf of the boxed
# register it just produced is a cache hit, not a redundant runbox, and a
# later TaggedOf of the same raw register is a cache hit too.
proc native::lower::TaggedOf {fnVar reg} {
    upvar 1 $fnVar fn
    set cache [dict get $fn rawCache]
    if {[dict exists $cache $reg]} {
        return [dict get $cache $reg]
    }
    set r [Assign fn "op rbox $reg"]
    dict incr fn rawBoxes
    dict set fn rawCache $reg $r
    dict set fn rawCache $r $reg
    return $r
}

# The NIR operation implementing native NAME for generic calls.
proc native::lower::NativeImpl {name} {
    variable natives
    set impl [dict get $natives $name]
    return [expr {[lindex $impl 0] eq "equality" ? "veq" : [lindex $impl 1]}]
}

# ---------------------------------------------------------------------------
# Control flow

proc native::lower::If {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable guards
    variable knownErrors
    set condition [dict get $node condition]
    set test [Expr fn $condition]
    if {$test eq "never"} {
        return never
    }
    set key [list $e $condition]
    if {[dict exists $guards $key] || [dict exists $knownErrors $key]} {
        Emit fn "guardbool $test" $e
        dict incr fn [expr {[dict exists $guards $key] ? "guards" : "knownErrorGuards"}]
    } elseif {[hir::types::kindOf [hir::typeOf $hir $condition]] ne "bool"} {
        throw {NATIVE BUG} "native lowering: hir::aot reports no Boolean check for $condition ($e)"
    }
    set then [NewLabel fn]
    set else [NewLabel fn]
    set join [NewLabel fn]
    set result [NewReg fn]
    Emit fn "br $test $then $else" $e
    set joined 0
    foreach {label role} [list $then then $else else] {
        EmitLabel fn $label
        set saved [dict get $fn locals]
        set savedRaw [dict get $fn rawCache]
        EnterScope fn [dict get $node ${role}Scope]
        set body [dict get $node ${role}Body]
        if {$body ne "" && ![hir::get $hir [lindex $body 0] reachable]} {
            # HIR decided the condition: this branch never runs.
            Emit fn unreachable $e
            set value never
        } else {
            set value [Sequence fn $body]
        }
        dict set fn locals $saved
        dict set fn rawCache $savedRaw
        if {$value ne "never"} {
            Emit fn "$result = move $value"
            Emit fn "jump $join"
            set joined 1
        }
    }
    if {!$joined} {
        return never
    }
    EmitLabel fn $join
    return $result
}

# (listloop LIST-EXPR (block (ELEM) BODY...)): lowers directly to the shape
# item 50 of BYTE-SET.md describes -- evaluate the list once, an index/
# accumulator pair rebound at the loop's own back edge (exactly the
# multi-definition-site register pattern `If`'s own join register already
# uses, just fed back to the loop head instead of a forward join), a
# `listget` at the proven-in-bounds index each iteration (no spurious user-
# visible bounds Error: the generated index is always < the list's own
# length by construction), and `listappend` to grow the result. `break`/
# `continue`/`return`/an error inside the body compose completely unchanged
# -- `dict set fn loops $e [list $head $exit $resultReg]` is the *same*
# mechanism a bare `loop` already registers, so the existing Break/Continue
# lowering (native::lower::Expr's own `break`/`continue` cases) needs no
# change at all to make a `break` here overwrite $resultReg and jump
# straight to $exit, or a `continue` jump straight back to $head.
proc native::lower::ListLoop {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    set iterExpr [dict get $node iterable]
    set iterReg [Expr fn $iterExpr]
    if {$iterReg eq "never"} {
        return never
    }
    EmitArgGuards fn $e [list $iterExpr] [list $iterReg] {list} "loop"
    set lenReg [Assign fn "op listlen $iterReg" $e]
    set idx0 [IntConst fn 0 $e]
    set acc0 [Assign fn "op listnew" $e]
    set idxReg [NewReg fn]
    set accReg [NewReg fn]
    set resultReg [NewReg fn]
    Emit fn "$idxReg = move $idx0" $e
    Emit fn "$accReg = move $acc0" $e
    set head [NewLabel fn]
    set bodyLabel [NewLabel fn]
    # `continue`'s own target (registered below): only advances the index
    # and loops back -- it must NOT re-run the accumulation step, exactly
    # like the interpreter's own "contributes nothing" continue case. A
    # normal (non-continue) body completion reaches the same label via its
    # own explicit jump, after first accumulating its value -- so the index
    # is advanced exactly once per iteration either way, unlike jumping
    # straight back to $head, which would never advance the index at all
    # for a `continue`d iteration.
    set continueLabel [NewLabel fn]
    set normalExit [NewLabel fn]
    set exit [NewLabel fn]
    Emit fn "jump $head" $e
    EmitLabel fn $head
    set cmp [Assign fn "op ilt $idxReg $lenReg" $e]
    Emit fn "br $cmp $bodyLabel $normalExit" $e
    EmitLabel fn $bodyLabel
    set saved [dict get $fn locals]
    set savedRaw [dict get $fn rawCache]
    dict set fn loops $e [list $continueLabel $exit $resultReg]
    EnterScope fn [dict get $node bodyScope]
    set elemReg [Assign fn "op listget $iterReg $idxReg" $e]
    dict set fn locals [dict get $node elementBinding] [list reg $elemReg]
    set bodyValue [Sequence fn [dict get $node body]]
    set usedContinue [dict exists $fn continued $e]
    if {$bodyValue ne "never"} {
        set accNext [Assign fn "op listappend $accReg $bodyValue" $e]
        Emit fn "$accReg = move $accNext" $e
        Emit fn "jump $continueLabel" $e
    }
    dict unset fn continued $e
    dict set fn locals $saved
    dict set fn rawCache $savedRaw
    dict unset fn loops $e
    if {$bodyValue ne "never" || $usedContinue} {
        EmitLabel fn $continueLabel
        set idxNext [Assign fn "op iadd $idxReg [IntConst fn 1 $e]" $e]
        Emit fn "$idxReg = move $idxNext" $e
        Emit fn "jump $head" $e
    }
    EmitLabel fn $normalExit
    Emit fn "$resultReg = move $accReg" $e
    Emit fn "jump $exit" $e
    EmitLabel fn $exit
    return $resultReg
}

# `handle CALL NAME1 HANDLER1 ...` (EXPLICIT-ERROR-COMPLETIONS.md): lowers
# CALL as an ordinary expression (no lowering change of its own -- still
# whatever Call would otherwise emit, `may_error` included), bracketed in
# `pusherrorexit`/`poperrorexit` so every `may_error` check reachable while
# lowering it (its own invocation, and any fallible call its own argument
# expressions make -- exactly the one completion interp's op-handle checks
# too, since evaluating CALL's callee/args is part of evaluating the call
# node as a whole) branches to this handle's own dispatch label instead of
# propagating straight out of the function. The dispatch is an ordinary
# if-elif chain over `declarederroreq`: the first match clears the pending
# error and runs that handler's body (a fresh, possibly-cell-backed scope,
# lexically part of the enclosing function -- EnterScope, exactly like an
# `if` branch); no match re-raises the still-pending failure unchanged
# (`reraise`) to whatever the *outer* error-exit target is (PopErrorExit
# has already restored it by then).
proc native::lower::Handle {fnVar e node} {
    upvar 1 $fnVar fn
    set call [dict get $node call]
    set names [dict get $node handlerNames]
    set scopes [dict get $node handlerScopes]
    set bodies [dict get $node handlerBodies]

    set catchLabel [NewLabel fn]
    set joinLabel [NewLabel fn]
    set result [NewReg fn]
    set joined 0

    Emit fn "pusherrorexit $catchLabel" $e
    set callResult [Expr fn $call]
    Emit fn "poperrorexit" $e
    if {$callResult ne "never"} {
        Emit fn "$result = move $callResult" $e
        Emit fn "jump $joinLabel" $e
        set joined 1
    }

    EmitLabel fn $catchLabel
    foreach name $names scopeId $scopes body $bodies {
        set eqReg [Assign fn "declarederroreq [ErrorId $name]" $e]
        set matchLabel [NewLabel fn]
        set nextLabel [NewLabel fn]
        Emit fn "br $eqReg $matchLabel $nextLabel" $e
        EmitLabel fn $matchLabel
        Emit fn "cleardeclarederror" $e
        set saved [dict get $fn locals]
        set savedRaw [dict get $fn rawCache]
        EnterScope fn $scopeId
        set value [Sequence fn $body]
        dict set fn locals $saved
        dict set fn rawCache $savedRaw
        if {$value ne "never"} {
            Emit fn "$result = move $value" $e
            Emit fn "jump $joinLabel" $e
            set joined 1
        }
        EmitLabel fn $nextLabel
    }
    Emit fn "reraise" $e

    if {!$joined} {
        return never
    }
    EmitLabel fn $joinLabel
    return $result
}

proc native::lower::Loop {fnVar e node} {
    upvar 1 $fnVar fn
    set head [NewLabel fn]
    set exit [NewLabel fn]
    set result [NewReg fn]
    Emit fn "jump $head" $e
    EmitLabel fn $head
    set saved [dict get $fn locals]
    set savedRaw [dict get $fn rawCache]
    dict set fn loops $e [list $head $exit $result]
    EnterScope fn [dict get $node bodyScope]
    set value [Sequence fn [dict get $node body]]
    if {$value ne "never"} {
        Emit fn "jump $head" $e
    }
    set used [dict exists $fn broken $e]
    dict unset fn loops $e
    dict set fn locals $saved
    dict set fn rawCache $savedRaw
    if {!$used} {
        return never
    }
    EmitLabel fn $exit
    return $result
}

# ---------------------------------------------------------------------------
# Diagnostics and text

# Raises {NATIVE UNSUPPORTED} for expression E: WHAT is the unsupported
# operation, DETAIL explains.
proc native::lower::Unsupported {e what detail} {
    variable hir
    set where ""
    if {$e ne "" && [dict exists $hir exprs $e]} {
        set location [hir::aot::Location $hir [hir::get $hir $e origin]]
        if {[dict exists $location line]} {
            set where "[dict get $location file]:[dict get $location line]:[dict get $location column]: "
        } elseif {[dict exists $location ir]} {
            set where "ir {[dict get $location ir]}: "
        }
    }
    throw [list NATIVE UNSUPPORTED $what] "${where}$e: native lowering does not support $what: $detail"
}

# NAME's own small compile-time id (EXPLICIT-ERROR-COMPLETIONS.md); see
# `errorIds`'s own doc.
proc native::lower::ErrorId {name} {
    variable errorIds
    if {![dict exists $errorIds $name]} {
        throw {NATIVE BUG} "native lowering: undeclared error \"$name\" has no assigned id"
    }
    return [dict get $errorIds $name]
}

# TEXT as a NIR string literal.
proc native::lower::Quote {text} {
    set quoted [string map {\\ \\\\ \" \\\" \n \\n \r \\r \t \\t} $text]
    if {[regexp {[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]} $quoted]} {
        set escaped ""
        foreach char [split $quoted ""] {
            scan $char %c code
            if {$code < 32 || $code == 127} {
                append escaped [format {\u{%x}} $code]
            } else {
                append escaped $char
            }
        }
        set quoted $escaped
    }
    return "\"$quoted\""
}
