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
# A local binding is a register. Closures capture bindings by value, which is
# sound because resolution is sequential (hir/resolve.tcl): a reference's
# binding is always established before the closure that reads it is created.
# A closure refers to its own function binding through `self`. A binding bound
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
        list         {op listnew} \
        str::length       {op strlen} \
        str::substring    {op substr} \
        str::lowercase    {op strlower} \
        str::concat       {op strcat} \
        str::encode_utf8  {op strutf8bytes} \
        str::char_at      {op strcharat} \
        str::is_tcl_alpha {op strtclalpha} \
        str::is_tcl_alnum {op strtclalnum} \
        argv         {op argv} \
        list::length {op listlen} \
        list::at     {op listget} \
        list::append {op listappend} \
        immutable_set::from_list {equality-list} \
        immutable_set::contains  {equality-set} \
        mutable_array::allocate {op mutarrayallocate} \
        mutable_array::capacity {op mutarraycapacity} \
        mutable_array::at       {op mutarrayget} \
        mutable_array::set      {op mutarrayset} \
        mutable_array::copy     {op mutarraycopy} \
        mutable_array::freeze   {op mutarrayfreeze} \
        mutable_array::create   {op mutarraycreate} \
        mutable_array::from_list {op mutarrayfromlist} \
        mutable_array::generate {op mutarraygenerate} \
        mutable_array::swap     {op mutarrayswap} \
        mutable_array#to_list   {op mutarraytolist} \
        mutable_array#take_front {op mutarraytakefront} \
        mutable_array#swap_drop {op mutarrayswapdrop} \
        mutable_array#set_drop  {op mutarraysetdrop} \
        mutable_array#generate_drop {op mutarraygeneratedrop} \
        integer?     {op isint} \
        string?      {op isstr} \
        list?        {op islist} \
        mutarray?    {op ismutarray} \
        ok?          {op isok} \
        error?       {op iserror} \
        result-value {op resultvalue} \
        result-error {op resulterror} \
        hash         {op hash} \
        char::scalar_value {op charcodepoint} \
        byte_store::from_list {op bytesfromlist} \
        byte_store::byte_count    {op byteslen} \
        mutable_byte_store::zeroed   {op mbytesnew} \
        mutable_byte_store::from_storage  {op mbytesfrom} \
        mutable_byte_store::count {op mbyteslen} \
        mutable_byte_store::replace   {op mbytesset} \
        mutable_byte_store::detach  {op mbytesclone} \
        mutable_byte_store::freeze        {op mbytesfreeze} \
        mutable_byte_store::freeze_prefix {op mbytesfreezeprefix} \
        coroutine#create {op cocreate} \
        coroutine#start  {op costart} \
        coroutine#resume {coroutine-resume} \
        coroutine#yield  {op coyield} \
        coroutine::done? {op codone} \
        coroutine#release {op corelease} \
        affine#drop {op affinedrop} \
        mutable_vector::from_list {op mvfromlist} \
        mutable_vector::length    {op mvlen} \
        mutable_vector::empty?    {op mvempty} \
        mutable_vector::at        {op mvat} \
        mutable_vector::push      {op mvpush} \
        mutable_vector::pop       {op mvpop} \
        mutable_vector::take      {op mvtake} \
        mutable_vector::swap      {op mvswap} \
        mutable_vector::clear     {op mvclear} \
        mutable_vector#share      {op mvshare} \
        mutable_vector#to_list    {op mvtolist} \
        mutable_vector#take_front {op mvtakefront} \
        mutable_vector#clear_drop {op mvcleardrop} \
        mutable_vector#swap_drop  {op mvswapdrop}]
    # State of the program being lowered. hir is the view of the instance
    # being lowered, baseHir the program's semantic HIR.
    variable hir {}
    variable baseHir {}
    variable spec {}
    variable context {}
    variable guards {}
    variable knownErrors {}
    # ExprId -> its parent ExprId in baseHir, built on first use (Parent).
    variable parents {}
    variable selfTail {}
    variable envless {}
    variable affineTemps {}
    variable captureLists {}
    variable pending {}
    variable usedNatives {}
    # Struct shapes (STRUCTS.md), per program: {ID LAYOUT} -> dense shape
    # number, assigned on first use in deterministic lowering order, and the
    # ordered list of the {ID LAYOUT} keys, emitted as the NIR `shape`
    # declarations. ID is "" for an anonymous shape (LAYOUT its canonical,
    # sorted field set) or a named struct's declaration identity (LAYOUT its
    # declared slot order).
    variable shapeIds [dict create]
    variable shapeList {}
    # Enums (ENUMS.md), per program: declaration identity -> dense enum
    # number, assigned on first use in deterministic lowering order, and the
    # ordered identities, emitted as the NIR `enum` declarations. A case
    # value lowers to the immediate word of (enum number, the case's position
    # in the declaration): representation only, chosen after every semantic
    # check -- printing and hashing read the declared names from the table.
    variable enumIds [dict create]
    variable enumList {}
    # Module-static storage (MODULE-STATIC-RETAINED-VALUES.md): BindingId ->
    # its slot index in the Vm's own `statics` table (runtime::vm::Vm),
    # assigned once per program, in first-reference order (StaticSlot),
    # mirroring how ConstPool assigns constant-table indices. Every module-
    # scope top-level binding (hir::isModuleBinding) that this program's own
    # `bind`/`Ref` lowering ever actually touches gets exactly one slot,
    # never duplicated across functions or across a binding's several
    # references.
    variable staticSlots {}
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
    # The raw Int ABI plan (native/rawabi.tcl): InstanceId -> its physical
    # parameter/result representation, computed once per program from the
    # settled closedness and Range analyses and read by every instance's own
    # lowering and by every call site (the callee's plan is authoritative).
    variable abiPlan {}
    variable rawIntAbiOpt 1
    # The ShortString1 plan (native/shortstring.tcl, SHORT-STRING.md): the
    # physical representation of every String position/value the existing
    # facts prove has at most one character. Like abiPlan it is computed
    # once, strictly before lowering, and read by every callee and caller.
    variable shortPlan {}
    variable shortStringOpt 1
    # Raw-demand suppression of the plan (RAW-INT-ABI.md): 0 selects every
    # eligible position (audit-only comparison mode).
    variable rawDemandOpt 1
    # What a position with both a raw and a tagged consumer becomes: `boxed`
    # (default) or `raw` (audit-only: the earlier any-demand-retains policy).
    variable rawMixedPolicy boxed
    # The widest shift amount a raw (host machine i64) shift may use (see
    # RawEligibleShift): the host word width, not core/scalarbits.tcl's own
    # much larger MAX_SHIFT -- a proven-constant shift count under this bound
    # is always also within MAX_SHIFT, so raw eligibility never needs to
    # consult that separate, generic-path-only contract.
    variable rawShiftMax 64
    # GENERIC-PREDICATE-PROOF-LOSS.md, loss point 4: test/audit knob, not a
    # user-facing flag. 1 gives a counted loop (and each numeric domain of a
    # lockstep loop) a raw induction register when both of its bounds'
    # Ranges fit the small-Int domain (RawCountDomain); 0 keeps every
    # counted loop's compare and advance tagged, as before.
    variable rawCountLoopOpt 1
    # GENERIC-PREDICATE-PROOF-LOSS.md, loss point 5: test/audit knob, not a
    # user-facing flag. 1 gives a de-closured function's internal variant
    # (InternalFunction) the RawInt ABI plan's raw parameter and result
    # positions, and its direct calls (FlattenedVirtualCall) pass and
    # receive them raw; 0 keeps every internal variant tagged, as before.
    variable rawInternalAbiOpt 1
    # Scalar replacement (see "Scalar replacement" below): the hir::escape
    # analysis of the program, and whether it is enabled at all.
    variable escape {}
    variable escapeOpt 1
    # Parameter virtualization (see "Parameter virtualization" below):
    # whether hir::escape::analyze's own parameter-boundary growth pass is
    # enabled, independent of escapeOpt above.
    variable paramAggregateOpt 1
    # Struct scalar replacement (STRUCT-SCALAR-REPLACEMENT.md): whether it is
    # enabled at all (it also needs escapeOpt), and the width caps handed to
    # hir::escape::analyze (a dict; empty means the analysis defaults).
    variable structOpt 1
    variable structWidths {}
    # Block virtualization (see "Block virtualization" below): the
    # hir::blockescape analysis of the program, and whether it is enabled
    # at all.
    variable blockescape {}
    variable blockEscapeOpt 1
    # String regions (see "String regions" below): the hir::stringregion
    # analysis of the program, and whether it is enabled at all.
    variable stringregion {}
    variable stringRegionOpt 1
    # Proven bounds (PROOF-FACT-CENSUS.md G1): whether a bounds-bearing native
    # call whose every check hir/completions.tcl proved can never fail lowers
    # to its check-free sibling opcode (or, for a region, omits `regioncheck`)
    # instead of the checked form.
    variable provenBoundsOpt 1
    # String traversal (see "String traversal" below): the hir::traversal
    # analysis of the program, and whether it is enabled at all.
    variable traversal {}
    variable traversalOpt 1
    # Virtual construction (see "Virtual construction" below): the
    # hir::construction analysis of the program, and whether it is enabled
    # at all.
    variable construction {}
    variable constructionOpt 1
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
# `list::at(..., k)` reading it at a compile-time-constant position reading
# the corresponding register directly instead of calling `listget`. This
# holds for two shapes (hir/escape.tcl's Classify):
#
#   local    a plain `[e0, ..., en-1]` construction, bound to a local
#            binding every one of whose references is such a `list::at`:
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
# vouch for as an exact call -- see its header for the exact criteria and the bounded, single-region
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
#                      (`{virtual fields}`), so the existing `list::at(ref,
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
# Struct scalar replacement (STRUCT-SCALAR-REPLACEMENT.md)
#
# The two sections above were written for positional Lists; hir/escape.tcl
# now recognizes structs as the second fixed-shape aggregate kind, and the
# same representation carries them -- no second optimizer, no new NIR opcode
# and no new runtime object:
#
#   * a *virtual struct* is bookkeeping over its field registers: a `fn
#     locals` entry `{virtual FIELDS SHAPE ROOT MAT}` (FIELDS in slot order,
#     SHAPE the {ID LAYOUT} key of the struct it semantically is, ROOT the
#     binding whose entry holds the materialization, MAT the register of it
#     once it exists). Lists use the same entry without a shape.
#   * a projection from a virtual struct (Project) resolves to the field
#     register: no `structget`. A literal receiver, or an exact call that
#     returns fields, is read the same way (hir::escape::directProjection).
#   * a struct literal in a virtual position (VirtualValue) evaluates its
#     fields in WRITTEN order and yields them in slot order; no shape is
#     declared and no `structnew` emitted. A *discarded* literal (statement
#     position) builds nothing either.
#   * across one exact return the callee's companion ends in `retmulti` of
#     the fields and the caller reads them from `callmulti` (Scalar
#     replacement above); across one exact call the callee's `fields`
#     variant receives one register per field (Parameter virtualization
#     above); an `if` whose branches all end in one shape joins field-wise
#     (If with VIRTUALN: one result register per field).
#   * materialization (MaterializeVirtual) is *lazy and single*: the first
#     use that needs the physical object -- a store into a List/MutableArray,
#     an equality or hash, a capture, an unknown call, a non-virtual
#     parameter, the program's own value -- emits `structnew SHAPE fields...`
#     from fields that all already exist, with the exact named or canonical
#     anonymous shape, and records the register in the root's entry so later
#     uses this scope dominates reuse it. Branches, loops and protected calls
#     restore `fn locals` on the way out, so a materialization that does not
#     dominate what follows is never reused there. `structnew` therefore now
#     counts real materializations.
#
# Value transport (VALUE-TRANSPORT-MATERIALIZATION.md) adds no mechanism here,
# only decisions the analysis makes and this file already knows how to carry:
# whether a struct crosses an exact call as fields or as one object is the
# transport plan's per-parameter verdict (a denied parameter takes the object,
# so the caller materializes lazily, once, just before that call, and its
# earlier projections stay virtual); a recognized result's return chain is
# bounded the same way; and a nested literal may be opened by a *cut* the
# analysis chose -- virtual entries carry it (index 5), literals flatten by it
# (StructFields), a projection chain reads through it (ProjectChain), and a
# materialization rebuilds the inner objects first (BuildStruct). One
# transported layout per slot: an instance still has at most the canonical
# function, one `fields` form and the two companions.
#
# GC: a virtual struct is not an object and so not a root; each field is an
# ordinary tagged register, rooted by the same liveness that roots every
# register, live exactly until its last use (a projection or the
# materialization). -struct-opt 0 (or BOTLISH_NATIVE_STRUCT_OPT=0) disables
# all of it, for differential testing against the structs milestone's
# lowering; -struct-local-width/-struct-return-width/-struct-arg-width set
# the width caps (hir::escape::StructOption).

# ---------------------------------------------------------------------------
# String regions
#
# A temporary substring (`str::substring(text, a, b)`) hir/stringregion.tcl proves
# is consumed only by `==` (resolving to `streq`: both operands statically
# str-typed) or `str::length` may be represented, instead of an allocated String,
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
#   local    a plain `str::substring(text, a, b)` call, or a String literal,
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
# region-producing call is a direct operand of `==`/`str::length`
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
# is region-eligible; `str::length` of a region-eligible operand lowers to a
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
# Bounds checking (#18 of this milestone): a `str::substring`-shaped region still
# validates its bounds -- RegionCheck (`op regioncheck`), emitted at exactly
# the point in program order the ordinary `substr` call would have run --
# exactly as `rt_substr` does, just without allocating or copying. Once
# validated, the region's registers stay valid for as long as they are live:
# Strings are immutable, so nothing can invalidate a bound already proven.
# `str::length`/`regioneq`, downstream of a `regioncheck` (or of a String
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
# binding virtual when *every* reference is `==`/`str::length`, so a region is
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
# *direct* `str::substring(text, i, i+1)` call is deliberately not recognized,
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
# argument subtree, never a `==`/`str::length` operand position).
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
# Virtual construction
#
# M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md. An immutable String/List built by
# ordinary `str::concat`/`list::append` need not be materialized as a flat object
# at every construction step: until some consumer actually observes it as a
# flat value, it may stay a *construction plan* -- the ordered pieces it is
# made of, every one of them an already-evaluated value. hir/
# construction.tcl decides where (plan locals, plan parameters, plan
# results; see its header); this lowering represents a plan in two forms:
#
#   pieces   compile-time: a list of {span REG} (a flat value or a plan
#            register), {region BASE START END} (a validated StringRegion --
#            a `str::substring` operand of a concat is never copied into a String
#            of its own) and {elem REG} (one List element). A plan local's
#            `fn locals` entry is `{pieces PIECES FAMILY}`; a nested concat
#            tree, a plan local and a plan parameter all just contribute
#            their pieces to the enclosing construction (PlanPieces).
#   plan     runtime: a register declared in the func header's `planregs=`
#            that may hold a private plan object (runtime/construct.rs:
#            KIND_STRPLAN/KIND_LISTPLAN) *or* an ordinary flat value -- a
#            "maybe-plan" register. Needed only where a construction must
#            cross a point pieces cannot: a self-tail back edge or direct
#            call at a plan parameter (`{plan REG FAMILY}` in `fn locals`),
#            a plan result's `ret` (`planresult=1`), an `if` join.
#
# One NIR instruction does all construction, whatever the number of pieces
# (no strcat2/strcat3/... zoo): `%d = construct str|list plan|flat PIECE...`
# (nir.rs's Inst::Construct). `plan` builds or extends (in place: the first
# plan piece is its "anchor") a plan object; `flat` is the one
# materialization -- one allocation, each piece copied once, byte-for-byte
# the object eager concat/list::append would have built. Where nothing is
# virtual, PiecesToFlat still emits exactly the eager `op strcat`/`op
# listappend` the baseline does, and `-virtual-construction-opt 0` (or
# BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT=0) emits no `construct` at all:
# the untouched eager lowering, for differential testing and measurement.
#
# Strict evaluation, delayed materialization: every piece is evaluated
# exactly where, and in the order, the eager lowering evaluates it (operands
# left to right, the eager call's own argument guards after both operands --
# ConstructPieces); only copying moves, to the consumer that materializes.
# The one failure mode eager concat/list::append have -- the collection-
# length ceiling (MAX_COLLECTION_LENGTH, 2^62-1 characters/elements, far
# beyond any allocatable object) -- is checked by `construct` itself.
#
# Materialization barriers are simply every consumer that asks for an
# ordinary value: Ref of a plan local/parameter wanted tagged, a direct call
# whose callee's parameter is not a plan parameter, a plan result consumed
# by an ordinary use (PlanCallResult), a return from a non-plan-result
# function, List elements, native operations, dynamic calls, captures -- all
# of them go through the ordinary Expr path, which only ever sees flat
# registers. nir.rs's `validate_plans` re-checks this structurally (a plan
# register may reach only construct/move/plan-parameter/plan-result
# positions, and is consumed at most once along every path), so a lowering
# mistake is a loud INVALID-NIR, never a plan misread as a String/List.
#
# Nothing here is a loop rewrite: a self-tail recurrence carrying
# `str::concat(acc, piece)` stays virtual only because its `acc` parameter is a
# plan parameter by the same general rule as any other binding.

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
#                      proves is consumed only by `==`/`str::length` as a
#                      StringRegion instead of an allocated String (default
#                      1, unless the environment variable
#                      BOTLISH_NATIVE_STRING_REGION_OPT is 0; see the
#                      "String regions" section above)
#   -proven-bounds-opt 1|0
#                      lower a bounds-bearing native call whose every bounds
#                      check hir/completions.tcl proved cannot fail to the
#                      check-free `*proven` opcode (and drop a String
#                      region's `regioncheck`) instead of the checked form
#                      (default 1, unless the environment variable
#                      BOTLISH_NATIVE_PROVEN_BOUNDS_OPT is 0; see
#                      "Proven bounds" at BoundsProven)
#   -call-facts-opt 1|0
#                      propagate value facts through exact closed calls
#                      (default 1; BOTLISH_NATIVE_CALL_FACTS_OPT=0 disables
#                      the new propagation for differential testing)
#   -closed-caller-facts-opt 1|0
#                      derive a closed generic instance's own entry-kind
#                      theorem from its exact callers (M7C-CLOSED-CLOSURE-
#                      ENTRY-FACTS.md; default 1;
#                      BOTLISH_NATIVE_CLOSED_CALLER_FACTS_OPT=0 disables it
#                      for differential testing -- independent of
#                      -call-facts-opt, which only ever controls whether a
#                      value-capturing closure's own scalar-Int captures let
#                      Handle select a *specific* key at all: with it
#                      disabled a closure that would otherwise specialize
#                      stays generic, which is exactly the population this
#                      option's own mechanism also reaches, so isolating
#                      -call-facts-opt's own contribution alone requires
#                      disabling this one too)
#   -exact-callable-opt 1|0
#                      keep an exact callable argument's identity (an exact
#                      Botlish block, an exact native) in the codegen key, so
#                      a call through the parameter is a direct call, not an
#                      indirect callvalue (EXACT-CALLABLE-CLOSED-CALLER.md;
#                      default 1; BOTLISH_NATIVE_EXACT_CALLABLE_OPT=0
#                      restores the kind-only `block`/`native` keys for
#                      differential testing)
#   -exact-callable-limit N
#                      the exact-target budget: at most N live specialized
#                      instances of one function keyed by an exact callable
#                      (default: hir::specialize's exactLimit, 4;
#                      BOTLISH_NATIVE_EXACT_CALLABLE_LIMIT overrides it). A
#                      further target shares the kind-only key and the
#                      callable-value ABI.
#   -recursive-result-range-opt 1|0
#                      derive a finite successful-result Range for a closed,
#                      direct, self-recursive Int instance whose measure
#                      parameter has a finite entry Range and strictly
#                      decreases (hir/rangerec.tcl, SELF-RECURSIVE-RESULT-
#                      RANGES.md; default 1;
#                      BOTLISH_NATIVE_RECURSIVE_RESULT_RANGE_OPT=0 disables
#                      it for differential testing). Part of call facts:
#                      with -call-facts-opt 0 there are no result summaries.
#   -recursive-range-limit N
#                      the explicit measure-state budget of that solver
#                      (default: hir::range's maxRecursiveRangeStates;
#                      BOTLISH_NATIVE_RECURSIVE_RANGE_LIMIT overrides it).
#                      An audit/native option, never source syntax.
#   -raw-int-abi-opt 1|0
#                      transport the Int parameters and the successful Int
#                      result of an exact closed instance as raw signed
#                      machine integers when their final entry/result Ranges
#                      satisfy hir::range::fitsSmall (native/rawabi.tcl,
#                      RAW-INT-ABI.md; default 1;
#                      BOTLISH_NATIVE_RAW_INT_ABI_OPT=0 restores the
#                      tagged ABI everywhere, for differential testing).
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
#               representation blockers (plus those of each tiny leaf
#               inlined into it, once per inlined call: InlineLeafCall;
#               minus those of code it does not emit: SkipAfter), guards
#               the kind checks emitted for them, knownErrorGuards the
#               checks that always fail
#   statistics  {functions N generic N specialized N blockers N guards N
#               perFunction {NAME {generic 0|1 specializations N} ...}}
#   specialization  the hir::specialize analysis
#
# Every analysis Program composes and lowering itself share one view per
# instance (hir::specialize::memoizeViews), released here however it ends.
proc native::lower::program {hirProgram args} {
    try {
        return [Program $hirProgram {*}$args]
    } finally {
        hir::specialize::forgetViews
    }
}

proc native::lower::Program {hirProgram args} {
    variable hir
    variable baseHir
    variable spec
    variable context
    variable selfTail
    variable envless
    variable captureLists
    variable pending
    variable usedNatives
    variable ranges
    variable callFactsOpt
    variable reprOpt
    variable abiPlan
    variable rawIntAbiOpt
    variable shortPlan
    variable shortStringOpt
    variable rawDemandOpt
    variable rawMixedPolicy
    variable escape
    variable escapeOpt
    variable paramAggregateOpt
    variable structOpt
    variable structWidths
    variable blockescape
    variable blockEscapeOpt
    variable stringregion
    variable stringRegionOpt
    variable provenBoundsOpt
    variable traversal
    variable traversalOpt
    variable tinyLeafInlineOpt
    variable leafEligible
    variable construction
    variable constructionOpt
    # The module-static slot table is per program: without this declaration
    # the reset below assigned a local variable and slot numbers (and the
    # header's statics=N) leaked from one compilation to the next in the same
    # process.
    variable staticSlots
    variable shapeIds
    variable shapeList
    set shapeIds [dict create]
    set shapeList {}
    variable enumIds
    variable enumList
    set enumIds [dict create]
    set enumList {}

    set default [expr {[info exists ::env(BOTLISH_NATIVE_SPECIALIZE)]
        && $::env(BOTLISH_NATIVE_SPECIALIZE) eq "0" ? 0 : 1}]
    set reprDefault [expr {[info exists ::env(BOTLISH_NATIVE_REPR_OPT)]
        && $::env(BOTLISH_NATIVE_REPR_OPT) eq "0" ? 0 : 1}]
    set escapeDefault [expr {[info exists ::env(BOTLISH_NATIVE_ESCAPE_OPT)]
        && $::env(BOTLISH_NATIVE_ESCAPE_OPT) eq "0" ? 0 : 1}]
    set paramAggregateDefault [expr {[info exists ::env(BOTLISH_NATIVE_PARAM_AGGREGATE_OPT)]
        && $::env(BOTLISH_NATIVE_PARAM_AGGREGATE_OPT) eq "0" ? 0 : 1}]
    set structDefault [expr {[info exists ::env(BOTLISH_NATIVE_STRUCT_OPT)]
        && $::env(BOTLISH_NATIVE_STRUCT_OPT) eq "0" ? 0 : 1}]
    set blockEscapeDefault [expr {[info exists ::env(BOTLISH_NATIVE_BLOCK_ESCAPE_OPT)]
        && $::env(BOTLISH_NATIVE_BLOCK_ESCAPE_OPT) eq "0" ? 0 : 1}]
    set stringRegionDefault [expr {[info exists ::env(BOTLISH_NATIVE_STRING_REGION_OPT)]
        && $::env(BOTLISH_NATIVE_STRING_REGION_OPT) eq "0" ? 0 : 1}]
    set provenBoundsDefault [expr {[info exists ::env(BOTLISH_NATIVE_PROVEN_BOUNDS_OPT)]
        && $::env(BOTLISH_NATIVE_PROVEN_BOUNDS_OPT) eq "0" ? 0 : 1}]
    set rawIntAbiDefault [expr {[info exists ::env(BOTLISH_NATIVE_RAW_INT_ABI_OPT)]
        && $::env(BOTLISH_NATIVE_RAW_INT_ABI_OPT) eq "0" ? 0 : 1}]
    set rawDemandDefault [expr {[info exists ::env(BOTLISH_NATIVE_RAW_DEMAND_OPT)]
        && $::env(BOTLISH_NATIVE_RAW_DEMAND_OPT) eq "0" ? 0 : 1}]
    set rawMixedDefault [expr {[info exists ::env(BOTLISH_NATIVE_RAW_MIXED_POLICY)]
        && $::env(BOTLISH_NATIVE_RAW_MIXED_POLICY) eq "raw" ? "raw" : "boxed"}]
    set shortStringDefault [expr {[info exists ::env(BOTLISH_NATIVE_SHORT_STRING_OPT)]
        && $::env(BOTLISH_NATIVE_SHORT_STRING_OPT) eq "0" ? 0 : 1}]
    set shortDemandDefault [expr {[info exists ::env(BOTLISH_NATIVE_SHORT_DEMAND_OPT)]
        && $::env(BOTLISH_NATIVE_SHORT_DEMAND_OPT) eq "0" ? 0 : 1}]
    set asciiPackDefault [expr {[info exists ::env(BOTLISH_NATIVE_ASCII_PACK_OPT)]
        && $::env(BOTLISH_NATIVE_ASCII_PACK_OPT) eq "0" ? 0 : 1}]
    set callFactsDefault [expr {[info exists ::env(BOTLISH_NATIVE_CALL_FACTS_OPT)]
        && $::env(BOTLISH_NATIVE_CALL_FACTS_OPT) eq "0" ? 0 : 1}]
    set closedCallerFactsDefault [expr {[info exists ::env(BOTLISH_NATIVE_CLOSED_CALLER_FACTS_OPT)]
        && $::env(BOTLISH_NATIVE_CLOSED_CALLER_FACTS_OPT) eq "0" ? 0 : 1}]
    set exactCallableDefault [expr {[info exists ::env(BOTLISH_NATIVE_EXACT_CALLABLE_OPT)]
        && $::env(BOTLISH_NATIVE_EXACT_CALLABLE_OPT) eq "0" ? 0 : 1}]
    set exactLimitDefault [expr {[info exists ::env(BOTLISH_NATIVE_EXACT_CALLABLE_LIMIT)]
        ? $::env(BOTLISH_NATIVE_EXACT_CALLABLE_LIMIT) : ""}]
    set recursiveRangeDefault [expr {[info exists ::env(BOTLISH_NATIVE_RECURSIVE_RESULT_RANGE_OPT)]
        && $::env(BOTLISH_NATIVE_RECURSIVE_RESULT_RANGE_OPT) eq "0" ? 0 : 1}]
    set recursiveLimitDefault [expr {[info exists ::env(BOTLISH_NATIVE_RECURSIVE_RANGE_LIMIT)]
        ? $::env(BOTLISH_NATIVE_RECURSIVE_RANGE_LIMIT) : ""}]
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
    set constructionDefault [expr {[info exists ::env(BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT)]
        && $::env(BOTLISH_NATIVE_VIRTUAL_CONSTRUCTION_OPT) eq "0" ? 0 : 1}]
    set options [hir::Options native::lower::program \
        [list -specialize $default -repr-opt $reprDefault -escape-opt $escapeDefault \
            -param-aggregate-opt $paramAggregateDefault -struct-opt $structDefault \
            -struct-local-width "" -struct-return-width "" -struct-arg-width "" \
            -struct-policy "" -struct-arg-budget "" -struct-return-budget "" -struct-cycle-budget "" \
            -struct-arg-factor "" -struct-return-factor "" -struct-cycle-factor "" -struct-nesting "" \
            -block-escape-opt $blockEscapeDefault \
            -string-region-opt $stringRegionDefault -string-traversal-opt $traversalDefault \
            -proven-bounds-opt $provenBoundsDefault \
            -call-facts-opt $callFactsDefault -call-effects-opt $callEffectsDefault \
            -closed-caller-facts-opt $closedCallerFactsDefault \
            -exact-callable-opt $exactCallableDefault -exact-callable-limit $exactLimitDefault \
            -tiny-leaf-inline-opt $tinyLeafInlineDefault \
            -recursive-result-range-opt $recursiveRangeDefault -recursive-range-limit $recursiveLimitDefault \
            -raw-int-abi-opt $rawIntAbiDefault -raw-demand-opt $rawDemandDefault -raw-mixed-policy $rawMixedDefault \
            -short-string-opt $shortStringDefault -ascii-pack-opt $asciiPackDefault -short-demand-opt $shortDemandDefault \
            -virtual-construction-opt $constructionDefault] $args]
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
    variable parents
    set parents [dict create]
    variable affineTemps
    # The construction operands a release names as pending temporaries
    # (hir::affine::temporaries, AFFINE-VALUES.md): Expr records their
    # registers (fn `temps`) for ReleaseHandles.
    set affineTemps [hir::affine::temporaries $hirProgram]
    # A discarded construction is not built (Struct's and the List
    # literal's discarded paths): its release is its affine components'
    # (hir::affine::Components), whose registers Expr records too.
    if {[dict exists $hirProgram affine releases]} {
        dict for {statement items} [dict get $hirProgram affine releases] {
            if {$statement ni $items} continue
            foreach {component type} [hir::affine::Components $hirProgram $statement] {
                dict set affineTemps $component 1
            }
        }
    }
    set reprOpt [dict get $options -repr-opt]
    set callFactsOpt [dict get $options -call-facts-opt]
    set callEffectsOpt [dict get $options -call-effects-opt]
    set escapeOpt [dict get $options -escape-opt]
    set paramAggregateOpt [dict get $options -param-aggregate-opt]
    set structOpt [expr {[dict get $options -struct-opt] && [dict get $options -escape-opt]}]
    set structWidths [dict create enabled $structOpt]
    # The width ceilings and, under the transport policy
    # (VALUE-TRANSPORT-MATERIALIZATION.md), the policy itself and the
    # dimensionless weights/budgets of its pressure score (hir/transport.tcl).
    # `-struct-policy legacy` is the previous milestone's width-only policy
    # (local 16, return 8, argument 4), kept for comparison.
    foreach {option key envName} {-struct-local-width localWidth BOTLISH_NATIVE_STRUCT_LOCAL_WIDTH
            -struct-return-width returnWidth BOTLISH_NATIVE_STRUCT_RETURN_WIDTH
            -struct-arg-width argWidth BOTLISH_NATIVE_STRUCT_ARG_WIDTH
            -struct-policy policy BOTLISH_NATIVE_STRUCT_POLICY
            -struct-arg-budget argBudget BOTLISH_NATIVE_STRUCT_ARG_BUDGET
            -struct-return-budget returnBudget BOTLISH_NATIVE_STRUCT_RETURN_BUDGET
            -struct-cycle-budget cycleBudget BOTLISH_NATIVE_STRUCT_CYCLE_BUDGET
            -struct-arg-factor argFactor BOTLISH_NATIVE_STRUCT_ARG_FACTOR
            -struct-return-factor returnFactor BOTLISH_NATIVE_STRUCT_RETURN_FACTOR
            -struct-cycle-factor cycleFactor BOTLISH_NATIVE_STRUCT_CYCLE_FACTOR
            -struct-nesting nesting BOTLISH_NATIVE_STRUCT_NESTING} {
        set width [dict get $options $option]
        if {$width eq "" && [info exists ::env($envName)] && $::env($envName) ne ""} {
            set width $::env($envName)
        }
        if {$width ne ""} {
            dict set structWidths $key $width
        }
    }
    set blockEscapeOpt [dict get $options -block-escape-opt]
    set stringRegionOpt [dict get $options -string-region-opt]
    set provenBoundsOpt [dict get $options -proven-bounds-opt]
    set traversalOpt [dict get $options -string-traversal-opt]
    set tinyLeafInlineOpt [dict get $options -tiny-leaf-inline-opt]
    set constructionOpt [dict get $options -virtual-construction-opt]
    set leafEligible [dict create]
    set spec [hir::specialize::analyze $hirProgram -specialize [dict get $options -specialize] \
        -call-facts-opt [dict get $options -call-facts-opt] \
        -closed-caller-facts-opt [dict get $options -closed-caller-facts-opt] \
        -exact-callable-opt [dict get $options -exact-callable-opt] \
        -exact-callable-limit [dict get $options -exact-callable-limit]]
    hir::specialize::memoizeViews $hirProgram $spec
    set ranges [hir::range::analyze $hirProgram $spec [dict get $options -call-facts-opt] 1 1 \
        [dict get $options -recursive-result-range-opt] [dict get $options -recursive-range-limit]]
    # The raw Int ABI plan runs strictly after the closedness and Range
    # analyses it consumes (including bounded recursive result summaries)
    # and strictly before any lowering, so every call site sees the final
    # physical signature of its callee.
    set rawIntAbiOpt [expr {[dict get $options -raw-int-abi-opt] && $reprOpt}]
    set rawDemandOpt [dict get $options -raw-demand-opt]
    set rawMixedPolicy [dict get $options -raw-mixed-policy]
    set abiPlan [native::rawabi::plan $hirProgram $spec $ranges $rawIntAbiOpt $blockEscapeOpt $rawDemandOpt $rawMixedPolicy]
    set escape [expr {$escapeOpt ? [hir::escape::analyze $hirProgram $spec $paramAggregateOpt $structWidths]
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
    # Virtual construction (see "Virtual construction" below) runs last: it
    # leaves every binding/variant the analyses above claim to them, and
    # decides plan results from M7.c's closedness proof over blockescape.
    set construction [expr {$constructionOpt
        ? [hir::construction::analyze $hirProgram $spec $escape $stringregion $blockescape]
        : [dict create params {} bindings {} locals {} results {} closed {} regions {}]}]
    # The ShortString1 plan (SHORT-STRING.md) runs strictly after the
    # closedness, Range and virtual-construction analyses it composes with,
    # and before any lowering. It reads facts and decides a representation;
    # it never feeds back into them. A position the construction analysis
    # already carries as a plan (concat/list::append pieces) keeps that
    # existing representation: ShortString1 does not compete with another
    # virtualization of the same position. -short-string-opt 0 plans every
    # position tagged and makes every fact `over`, reproducing the previous
    # physical Strings.
    set shortStringOpt [expr {[dict get $options -short-string-opt] && $reprOpt}]
    # -ascii-pack-opt 0 turns off the packed-ASCII tier alone: a String of at
    # most one character is then a ShortString1 whether or not it is ASCII,
    # and nothing longer is virtual (the single-tier regime).
    set asciiPackOpt [dict get $options -ascii-pack-opt]
    # -short-demand-opt 0 turns off the demand rule (a position with a tier is
    # virtual whatever its uses are); on, a position none of whose uses is
    # free (a scalar consumer or a flow into another virtual position) stays
    # a tagged String, as a struct none of whose uses is free does.
    set shortDemandOpt [dict get $options -short-demand-opt]
    set shortPlan [native::shortstr::plan $hirProgram $spec $ranges $shortStringOpt $blockEscapeOpt $construction $asciiPackOpt $shortDemandOpt native::lower::DemandCallTagged]
    # The program's context slots (CONTEXTS.md), fixed before any function
    # is lowered.
    ContextSlots
    set context [dict get $spec context]
    set selfTail [dict get $context selfTails]
    set envless [dict get $context envless]
    set captureLists [dict create]
    set usedNatives {}
    set staticSlots [dict create]
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

    variable contextBytes
    set header [list "nir 1 call-effects=$callEffectsOpt statics=[StaticCount][expr {$contextBytes > 0 ? " contexts=$contextBytes" : ""}]"]
    lappend header {*}[ContextHeader]
    foreach name [lsort $usedNatives] {
        set meta [core::native::metadata $name]
        set kinds [lmap type [dict get $meta paramTypes] {
            expr {$type eq "any" ? "any" : [core::type::base $type]}
        }]
        lappend header "native [Quote $name] arity=[dict get $meta arity] params=[Quote $kinds] impl=[NativeImpl $name]"
    }
    foreach key $shapeList {
        lassign $key id layout
        if {$id eq ""} {
            lappend header "shape [dict get $shapeIds $key] anon fields=[Quote [join $layout { }]]"
        } else {
            # An opaque struct's shape says so (OPAQUE-STRUCTS.md): the
            # runtime printer renders it by its nominal type only. Nothing
            # else (layout, allocation, access) differs from an ordinary
            # named shape, and an ordinary one prints exactly as before.
            set opaque [expr {[hir::structs::isOpaque $id] ? " opaque=1" : ""}]
            lappend header "shape [dict get $shapeIds $key] named [Quote $id]$opaque fields=[Quote [join $layout { }]]"
        }
    }
    variable enumList
    foreach id $enumList {
        lappend header "enum [EnumIndex $id] [Quote $id] cases=[Quote [join [hir::enums::cases $id] { }]]"
    }
    set text "[join $header \n]\n\n[join $texts \n\n]\n"
    return [dict create text $text functions $infos statistics [Statistics $infos] \
        specialization $spec abiPlan $abiPlan shortPlan $shortPlan construction $construction structCensus [hir::escape::census $escape] \
        transportFacts [hir::escape::transportFacts $escape]]
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
                    Unsupported [dict get $blocker expr] "validator contract" \
                        "the operation needs [core::type::show [dict get $blocker requires]]; a native's validator named-type contract is checked only by the reference runtime, not natively"
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

# Code the lowering does not emit (native::report's accounting). A blocker
# is owed its kind guard where its operation runs; an operation the lowering
# does not emit runs nowhere and is owed none. hir::aot counts the blockers
# of everything HIR's types leave reachable, but the lowering emits less:
#   * an `if` arm the instance's Ranges decide against (If,
#     M6-RANGE-DECIDED-BRANCH-LOWERING.md): hir::aot knows no Range;
#   * whatever would only run after an expression whose lowering ends in
#     `never` (SkipAfter): the rest of its body, its later sibling operands
#     and the checks of the operation it is an operand of. HIR's types
#     leave that code reachable where they do not see the `never` (a
#     decided `if` whose live arm returns, a `loop` whose only `break` is
#     in a dead arm, an ARITY raise), and an
#     operation with an operand typed `never` (`n + stop()`) never runs.
# Their blockers are counted in the function's skippedGuards, as a virtual
# binding's list::at read already is (Call). The NIR does not change.

# The parent of expression E in the program (baseHir), or "" for a root.
proc native::lower::Parent {e} {
    variable parents
    variable baseHir
    if {![dict size $parents]} {
        foreach x [hir::walk $baseHir] {
            foreach child [hir::children $baseHir $x] {
                dict set parents $child $x
            }
        }
    }
    return [expr {[dict exists $parents $e] ? [dict get $parents $e] : ""}]
}

# How many of the current analysis's representation blockers (guards) are
# of an operation that is one of EXPRS or nested in one.
proc native::lower::SkippedBlockers {exprs} {
    variable guards
    if {$exprs eq "" || ![dict size $guards]} {
        return 0
    }
    set skipped [dict create]
    foreach e $exprs {
        dict set skipped $e 1
    }
    set n 0
    foreach key [dict keys $guards] {
        for {set e [lindex $key 0]} {$e ne ""} {set e [Parent $e]} {
            if {[dict exists $skipped $e]} {
                incr n
                break
            }
        }
    }
    return $n
}

# The lowering of E ended in `never`: what E's parent evaluates only after E
# is not emitted. That is the rest of E's body, or, for an operand, the
# later operands, the parent's bodies and the parent's own operand checks
# (which follow all of its operands). Counts their blockers in FN's
# skippedGuards. For an E whose type is `never`, HIR already left all but
# those checks unreachable, and hir::aot counted no blocker there.
proc native::lower::SkipAfter {fnVar e} {
    upvar 1 $fnVar fn
    variable hir
    variable guards
    if {![dict size $guards]} {
        return
    }
    # The parent's OPERANDS, in evaluation order, run before its BODIES; a
    # handle's call is neither (its handlers run when the call fails).
    set parent [Parent $e]
    set operands {}
    set bodies {}
    if {$parent eq ""} {
        set bodies [list [hir::roots $hir]]
    } else {
        set node [hir::node $hir $parent]
        switch -- [dict get $node kind] {
            if {
                set operands [list [dict get $node condition]]
                set bodies [list [dict get $node thenBody] [dict get $node elseBody]]
            }
            listloop {
                set operands [list [dict get $node iterable]]
                set bodies [list [dict get $node body]]
            }
            countloop {
                set operands [list [dict get $node start] [dict get $node end]]
                set bodies [list [dict get $node body]]
            }
            lockloop {
                set operands [hir::loopOperands $node]
                set bodies [list [dict get $node body]]
            }
            block - loop { set bodies [list [dict get $node body]] }
            handle       { set bodies [dict get $node handlerBodies] }
            default      { set operands [hir::children $hir $parent] }
        }
    }
    set k [lsearch -exact $operands $e]
    if {$k >= 0} {
        set rest [concat [lrange $operands [expr {$k + 1}] end] {*}$bodies]
        foreach key [dict keys $guards] {
            if {[lindex $key 0] eq $parent} {
                dict incr fn skippedGuards
            }
        }
    } else {
        set rest {}
        foreach body $bodies {
            set k [lsearch -exact $body $e]
            if {$k >= 0} {
                set rest [lrange $body [expr {$k + 1}] end]
            }
        }
    }
    dict incr fn skippedGuards [SkippedBlockers $rest]
}

# "never", for expression E whose lowering just ended in `never` (SkipAfter).
# Expr returns through it, and so does every other lowering of a whole
# expression that does not end in Expr (VirtualValue, TryFields, PlanPieces).
proc native::lower::Never {fnVar e} {
    upvar 1 $fnVar fn
    SkipAfter fn $e
    return never
}

# The module-static slot index for binding B (hir::isModuleBinding),
# assigning the next one on first reference: BindingId identity, never
# name/namespace text, decides slot identity (hir::isModuleBinding's own
# doc), so two spellings of the same binding (a qualified NAMESPACE::NAME
# reference and a same-module unqualified one alike) always share one slot.
proc native::lower::StaticSlot {b} {
    variable staticSlots
    if {![dict exists $staticSlots $b]} {
        dict set staticSlots $b [dict size $staticSlots]
    }
    return [dict get $staticSlots $b]
}

# The number of module-static slots this program uses so far: the NIR
# header's own `statics=N` (native::lower::program's final assembly).
proc native::lower::StaticCount {} {
    variable staticSlots
    return [dict size $staticSlots]
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
# an enclosing invocation: fnvalue, self or value.
proc native::lower::BindingAccess {b e} {
    variable hir
    variable envless
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
    variable abiPlan
    if {[native::rawabi::uses $abiPlan $id]} {
        # A Block value always enters the tagged generic entry: an instance
        # with a raw physical signature must be closed, so no Block value of
        # it can exist (rawabi.tcl, eligibility condition 2).
        throw {NATIVE BUG} "native lowering: instance $id has a raw Int ABI but a Block value of it is materialized"
    }
    variable shortPlan
    if {[native::shortstr::uses $shortPlan $id]} {
        # Likewise for the ShortString1 ABI (shortstring.tcl: a position is
        # only ever short for a closed instance).
        throw {NATIVE BUG} "native lowering: instance $id has a ShortString1 ABI but a Block value of it is materialized"
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

# ---------------------------------------------------------------------------
# Raw Int ABI (native/rawabi.tcl, RAW-INT-ABI.md)
#
# The plan is the single authority for the *physical* signature of an
# instance's canonical function. Its callee lowering (Function) and every
# caller (Call) read it through these accessors; nothing decides rawness at
# an individual call site, and nirs.rs re-validates agreement on the text.

# 1|0 per each of the first N parameter positions of instance ID's canonical
# function: whether the incoming argument is a raw signed machine integer.
proc native::lower::AbiParams {id n} {
    variable abiPlan
    return [native::rawabi::params $abiPlan $id $n]
}

# 1 if instance ID's canonical function returns its successful Int result as
# a raw signed machine integer.
proc native::lower::AbiResult {id} {
    variable abiPlan
    return [native::rawabi::result $abiPlan $id]
}

# The raw Int ABI positions (1|0 for each of the first N parameters) of
# instance ID's *internal* variant (InternalFunction; loss point 5 of
# GENERIC-PREDICATE-PROOF-LOSS.md): the plan's, the same as its canonical
# function's, with rawInternalAbiOpt on; all tagged with it off. Read by the
# internal variant itself and by every call of it (FlattenedVirtualCall),
# so the two agree by construction.
proc native::lower::InternalAbiParams {id n} {
    variable rawInternalAbiOpt
    if {!$rawInternalAbiOpt} {
        return [lrepeat $n 0]
    }
    return [AbiParams $id $n]
}

# 1 if instance ID's internal variant returns its successful Int result raw
# (see InternalAbiParams).
proc native::lower::InternalAbiResult {id} {
    variable rawInternalAbiOpt
    return [expr {$rawInternalAbiOpt && [AbiResult $id]}]
}

# 1 if the current function's own successful result is raw (only ever set,
# by Function, for the canonical function of a raw-result instance, and by
# InternalFunction for its internal variant).
proc native::lower::ResultRaw {fnVar} {
    upvar 1 $fnVar fn
    return [expr {[dict exists $fn resultRaw] && [dict get $fn resultRaw]}]
}

# ---------------------------------------------------------------------------
# ShortString1 (native/shortstring.tcl, SHORT-STRING.md)
#
# A ShortString1 register holds one i64: -1 for the empty String, else the
# one character's Unicode scalar value (U+0000 is 0, never Empty). It is a
# distinct physical kind from a raw Int register (`shortregs=` versus
# `rawregs=`; nir.rs rejects either standing in for the other) and from a
# tagged String. The proof that a value has at most one character is the
# planner's (shortstring.tcl); lowering only turns that decision into NIR:
#
#   * a local binding / branch join / exact call argument / result the plan
#     proves short is produced and kept in a short register;
#   * `strtoshort` (tagged -> short, total, non-allocating) and `shorttostr`
#     (short -> tagged, allocating) are the only transitions, cached in the
#     same fn rawCache the raw Int conversions use (register numbers are
#     unique), so one value converts once per region;
#   * `str::length` and `==` on proven-short operands are scalar ops; every other
#     consumer (storage, general String operations, hashing, FFI, a dynamic
#     call) materializes the real String at that frontier.

# The ShortString1 statistics of FN (SHORT-STRING.md's censuses): how many
# virtual values were produced, converted at each frontier and consumed by a
# scalar operation.
proc native::lower::ShortCounters {fnVar} {
    upvar 1 $fnVar fn
    set out [dict create]
    foreach key {shortLocals shortLits shortFromTagged shortToTagged shortConstMaterialized shortLen shortEq
            shortJoins shortSlices asciiLocals asciiLits asciiFromTagged asciiToTagged asciiConstMaterialized
            asciiLen asciiEq asciiShortEq asciiToShort asciiJoins} {
        dict set out $key [expr {[dict exists $fn $key] ? [dict get $fn $key] : 0}]
    }
    return $out
}

# Per each of the first N parameter positions of instance ID's canonical
# function: the kind of the incoming argument -- `ascii` (packed ASCII),
# `short` (ShortString1) or "" (an ordinary tagged value).
proc native::lower::ShortAbiParams {id n} {
    variable shortPlan
    return [native::shortstr::params $shortPlan $id $n]
}

# The kind (`ascii`, `short` or "") of instance ID's canonical function's
# successful String result.
proc native::lower::ShortAbiResult {id} {
    variable shortPlan
    return [native::shortstr::result $shortPlan $id]
}

# The kind (`ascii`, `short` or "") of the current function's own successful
# result.
proc native::lower::ResultShort {fnVar} {
    upvar 1 $fnVar fn
    return [expr {[dict exists $fn resultShort] ? [dict get $fn resultShort] : ""}]
}

# The tier of expression E of the instance being lowered: `ascii` when the
# planner proved it ASCII with at most eight characters, `short` when it
# proved at most one character, "" otherwise (and when it cannot complete).
# 1 if call E of instance ID will be lowered as a companion call (a String
# region) whose arguments are tagged and whose result is not the canonical
# function's scalar: the demand rule must not count such a call as a flow.
proc native::lower::DemandCallTagged {id e} {
    variable currentInstance
    variable stringRegionOpt
    if {!$stringRegionOpt} {
        return 0
    }
    variable hir
    variable stringregion
    if {[hir::kind $hir $e] eq "bind"} {
        # a local the String-region analysis keeps as a region
        set b [hir::get $hir $e binding]
        return [expr {$b ne "" && [hir::stringregion::virtual $stringregion $id $b]}]
    }
    set saved $currentInstance
    set currentInstance $id
    try {
        return [RegionEligible $e]
    } finally {
        set currentInstance $saved
    }
}

proc native::lower::ShortTier {e} {
    variable currentInstance
    variable shortStringOpt
    if {!$shortStringOpt} {
        return ""
    }
    return [native::shortstr::tier $currentInstance $e]
}

# 1 if E has a tier (see ShortTier).
proc native::lower::ShortOk {e} {
    return [expr {[ShortTier $e] ne ""}]
}

# 1 if a value of tier HAVE may be carried as WANT: the same tier, or a
# packed-ASCII value in a ShortString1 position (the plan only ever puts a
# value there when its join has at most one character).
proc native::lower::TierFits {have want} {
    return [expr {$have eq $want || ($have eq "ascii" && $want eq "short")}]
}

# The physical slot kind of the binding P in FN's locals as a call argument
# slot: 1 raw Int register, `short` ShortString1 register, `ascii` packed
# ASCII register, else 0.
proc native::lower::SlotKind {fnVar p} {
    upvar 1 $fnVar fn
    if {![dict exists $fn locals $p]} {
        return 0
    }
    switch -- [lindex [dict get $fn locals $p] 0] {
        rawreg   { return 1 }
        shortreg { return [ScalarKind fn [lindex [dict get $fn locals $p] 1]] }
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
    variable construction
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
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 inlinedBlockers 0 \
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
    # Raw Int ABI: these positions arrive as raw machine integers (no
    # prologue unboxing); the others keep the self-tail rule above.
    set abiParams [AbiParams $id [llength $params]]
    set rawParams [lmap a $abiParams r $rawParams {expr {$a || $r}}]
    if {$region ne "program" && [AbiResult $id]} {
        dict set fn resultRaw 1
    }
    # ShortString1 ABI: these positions arrive as a ShortString1 scalar
    # (native/shortstring.tcl); every caller of this canonical function
    # passes them the same way.
    set shortParams [expr {$region eq "program" ? [lrepeat [llength $params] ""] : [ShortAbiParams $id [llength $params]]}]
    if {$region ne "program" && [ShortAbiResult $id] ne ""} {
        dict set fn resultShort [ShortAbiResult $id]
    }
    set k 0
    foreach b $params raw $rawParams short $shortParams {
        set r [NewReg fn]
        if {$short ne ""} {
            MarkScalar fn $r $short
            dict set fn locals $b [list shortreg $r]
        } elseif {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            ParamLocal fn $id $k $b $r
        }
        incr k
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
    if {$region ne "program"} {
        dict set fn planResult [hir::construction::resultFamily $construction $id]
    }
    set contextProblem [expr {$region eq "program" ? [ContextDiagnostic] : ""}]
    if {$contextProblem ne ""} {
        # A -strict 0 program that failed context verification (CONTEXTS.md):
        # its first context diagnostic is the run's failure; no code whose
        # context loads were not proven runs.
        lassign $contextProblem kind message
        Emit fn "raise $kind [Quote $message]"
        set result never
    } elseif {[ResultRaw fn]} {
        set result [SequenceRaw fn $body]
    } elseif {[ResultShort fn] ne ""} {
        set result [SequenceShort fn $body [ResultShort fn]]
    } else {
        set result [SequenceTo fn $body [PlanResultFamily fn]]
    }
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
        : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set head "func [Placeholder $id] [Quote $name] params=[expr {[llength $params] + $extraParams}] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key]"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head [ShortRegsHeader fn]
    append head [PlanHeader fn]
    # The physical raw Int signature (a compact, deterministic encoding of
    # the plan: positions, then the result).
    set rawPositions {}
    set k 0
    foreach a $abiParams {
        if {$a} { lappend rawPositions $k }
        incr k
    }
    if {$rawPositions ne ""} {
        append head " rawparams=[Quote [join $rawPositions { }]]"
    }
    if {[ResultRaw fn]} {
        append head " rawresult=1"
    }
    foreach kind {short ascii} {
        set positions {}
        set k 0
        foreach a $shortParams {
            if {$a eq $kind} { lappend positions $k }
            incr k
        }
        if {$positions ne ""} {
            append head " ${kind}params=[Quote [join $positions { }]]"
        }
        if {[ResultShort fn] eq $kind} {
            append head " ${kind}result=1"
        }
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
        blockers [expr {$blockers + [dict get $fn inlinedBlockers] - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare] \
        short [ShortCounters fn]]
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
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 inlinedBlockers 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion $arity regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    set k 0
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            ParamLocal fn $id $k $b $r
        }
        incr k
    }
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
        set fields [VirtualValue fn [lindex $body end] $arity [hir::escape::resultCut $escape $id]]
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
        : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set head "func [Placeholder $id companion] [Quote $name] params=[llength $params] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key] results=$arity"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head [ShortRegsHeader fn]
    append head [PlanHeader fn]
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id companion] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (scalar)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers + [dict get $fn inlinedBlockers] - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare] \
        short [ShortCounters fn]]
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
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 inlinedBlockers 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 1 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    set k 0
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            ParamLocal fn $id $k $b $r
        }
        incr k
    }
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
        : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set head "func [Placeholder $id region] [Quote $name] params=[llength $params] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key] results=3"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head [ShortRegsHeader fn]
    append head [PlanHeader fn]
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id region] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (region)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers + [dict get $fn inlinedBlockers] - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare] \
        short [ShortCounters fn]]
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
# value (never "self": see its header), so
# no other part of this function's lowering needs to change at all -- same
# guards, same known-error checks, same GC rooting (every tagged parameter
# is rooted from the prologue exactly like any other, "Scalar
# replacement"'s reasoning applies unchanged; a raw one is a non-root
# scalar), same completion-code handling. Since loss
# point 5 of GENERIC-PREDICATE-PROOF-LOSS.md it also takes the RawInt ABI
# plan's raw parameter and result positions (InternalAbiParams/
# InternalAbiResult), exactly as Function does for the canonical function;
# its only callers are FlattenedVirtualCall's, which read the same plan. The
# trailing capture parameters stay tagged. Returns {TEXT INFO}, in the same
# shape as Function.
proc native::lower::InternalFunction {id} {
    variable hir
    variable construction
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
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 inlinedBlockers 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    # Raw Int ABI (loss point 5): the plan's raw positions of the declared
    # parameters arrive raw, and a raw-result plan returns raw, exactly as
    # in the canonical function (Function); every caller of an internal
    # variant is a FlattenedVirtualCall, which reads the same plan
    # (InternalAbiParams/InternalAbiResult). The hidden trailing capture
    # parameters stay tagged.
    set abiParams [InternalAbiParams $id [llength $params]]
    set rawParams [lmap a $abiParams r $rawParams {expr {$a || $r}}]
    if {[InternalAbiResult $id]} {
        dict set fn resultRaw 1
    }
    set k 0
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            ParamLocal fn $id $k $b $r
        }
        incr k
    }
    set captureBindings [dict get $captureLists $region]
    foreach b $captureBindings {
        dict set fn locals $b [list reg [NewReg fn]]
    }
    dict set fn planResult [hir::construction::resultFamily $construction $id]
    if {[ResultRaw fn]} {
        set result [SequenceRaw fn $body]
    } else {
        set result [SequenceTo fn $body [PlanResultFamily fn]]
    }
    if {$result ne "never"} {
        Emit fn "ret $result"
    }
    set pnames [concat [lmap b $params {dict get [hir::binding $hir $b] name}] \
        [lmap b $captureBindings {dict get [hir::binding $hir $b] name}]]
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set head "func [Placeholder $id internal] [Quote $name] params=[expr {[llength $params] + [llength $captureBindings]}] env=0 regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=0 instance=[Quote $key]"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head [ShortRegsHeader fn]
    append head [PlanHeader fn]
    set rawPositions {}
    set k 0
    foreach a $abiParams {
        if {$a} { lappend rawPositions $k }
        incr k
    }
    if {$rawPositions ne ""} {
        append head " rawparams=[Quote [join $rawPositions { }]]"
    }
    if {[ResultRaw fn]} {
        append head " rawresult=1"
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
        blockers [expr {$blockers + [dict get $fn inlinedBlockers] - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare] \
        short [ShortCounters fn]]
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
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 inlinedBlockers 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 1 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set rawParams [RawParams $id $instance $params]
    set k 0
    foreach b $params raw $rawParams {
        set r [NewReg fn]
        if {$raw} {
            MarkRaw fn $r
            dict set fn locals $b [list rawreg $r]
        } else {
            ParamLocal fn $id $k $b $r
        }
        incr k
    }
    set captureBindings [dict get $captureLists $region]
    foreach b $captureBindings {
        dict set fn locals $b [list reg [NewReg fn]]
    }
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
        : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set head "func [Placeholder $id internalregion] [Quote $name] params=[expr {[llength $params] + [llength $captureBindings]}] env=0 regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=0 instance=[Quote $key] results=3"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head [ShortRegsHeader fn]
    append head [PlanHeader fn]
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id internalregion] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (internal region)" generic [dict get $instance generic] \
        envless 1 selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers + [dict get $fn inlinedBlockers] - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare] \
        short [ShortCounters fn]]
    return [list $text $info]
}

# Like the parameter-registration loop Function/CompanionFunction/
# RegionCompanionFunction each run, but for instance ID's `fields`/
# `fieldscompanion` internal variant (see the "Parameter virtualization"
# section above): a parameter B hir::escape::paramVirtualArity recognizes
# is received as that many ordinary field registers, stored in `fn locals`
# exactly like a virtualized *local* binding already is (`{virtual
# fields}`) -- so the existing `list::at(ref, constant)` interception in
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
            dict set fn locals $b [list virtual $fields [hir::escape::paramVirtualShape $escape $id $b] $b "" \
                [hir::escape::paramVirtualCut $escape $id $b]]
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
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 inlinedBlockers 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion "" regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set pnames [SetupFieldParams fn $id $instance $params]
    set result [Sequence fn $body]
    if {$result ne "never"} {
        Emit fn "ret $result"
    }
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set head "func [Placeholder $id fields] [Quote $name] params=[llength $pnames] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key]"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head [ShortRegsHeader fn]
    append head [PlanHeader fn]
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id fields] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (fields)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers + [dict get $fn inlinedBlockers] - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare] \
        short [ShortCounters fn]]
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
        lines {} nreg 0 nlabel 0 guards 0 knownErrorGuards 0 skippedGuards 0 inlinedBlockers 0 \
        rawCache [dict create] rawRegs [dict create] rawUnboxes 0 rawBoxes 0 rawArith 0 rawCompare 0 \
        locals [dict create] loops [dict create] broken [dict create] continued [dict create] calls {} companion $arity regionCompanion 0 \
        traversal "" traversalByteReg ""]
    set name [hir::aot::BlockName $hir $region]
    set params [hir::get $hir $region params]
    set env [expr {$region ni $envless}]
    set scope [hir::get $hir $region bodyScope]
    set body [hir::get $hir $region body]
    set pnames [SetupFieldParams fn $id $instance $params]
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
        set fields [VirtualValue fn [lindex $body end] $arity [hir::escape::resultCut $escape $id]]
        if {$fields ne "never"} {
            Emit fn "retmulti [join $fields { }]"
        }
    }
    set captures {}
    if {$env} {
        set captures [lmap b [dict get $captureLists $region] {dict get [hir::binding $hir $b] name}]
    }
    set key [expr {[dict get $instance generic] ? "generic"
        : [join [lmap t [dict get $instance args] {hir::specialize::ShowKey $t}] {, }]}]
    set head "func [Placeholder $id fieldscompanion] [Quote $name] params=[llength $pnames] env=$env regs=[dict get $fn nreg] pnames=[Quote [join $pnames { }]] captures=[llength $captures] instance=[Quote $key] results=$arity"
    set rawRegs [lsort -integer [lmap r [dict keys [dict get $fn rawRegs]] {string range $r 1 end}]]
    if {$rawRegs ne ""} {
        append head " rawregs=[Quote [join $rawRegs { }]]"
    }
    append head [ShortRegsHeader fn]
    append head [PlanHeader fn]
    append head " @$region"
    set text "$head\n[join [dict get $fn lines] \n]\nend"
    set tails [llength [lmap line [dict get $fn lines] {
        if {![regexp {^\s+tail(env)? } $line]} continue
        set line
    }]]
    set info [dict create id [Placeholder $id fieldscompanion] name $name block $region instance $id \
        label "[hir::specialize::label $spec $id] (fields, scalar)" generic [dict get $instance generic] \
        envless [expr {!$env}] selfTailCalls $tails calls [dict get $fn calls] \
        blockers [expr {$blockers + [dict get $fn inlinedBlockers] - [dict get $fn skippedGuards]}] \
        guards [dict get $fn guards] knownErrorGuards [dict get $fn knownErrorGuards] \
        rawUnboxes [dict get $fn rawUnboxes] rawBoxes [dict get $fn rawBoxes] \
        rawArith [dict get $fn rawArith] rawCompare [dict get $fn rawCompare] \
        short [ShortCounters fn]]
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
    if {[dict exists $fn keepAddr]} {
        KeepAddrFlow fn $r $rhs
    }
    return $r
}

# Raw-address provenance (BytesAddrCall, SyscallCall; ABI-BYTES.md): `fn
# keepAddr` maps a register to the byte storages (registers) whose payload
# address it may hold or contain. It is created by `bytesaddr` and flows, within
# one function, through the instructions that build or take apart a value
# holding an address -- a Register64 object (`structnew`), a register struct
# bound to a local, a field read back out of it (`structget`), a List holding
# one -- so a syscall that takes such a register as an operand keeps every
# storage it may point into alive until the kernel returns. Registers are
# single-assignment and a storage register is defined before any value derived
# from it, so a recorded storage always dominates the registers that carry it.
# (Not tracked, by design: an address returned from another function or merged
# across a branch join -- the raw layer's one sharp edge, documented in
# ABI-BYTES.md: take the address and make the syscall in the same function.)
proc native::lower::KeepAddrFlow {fnVar reg rhs} {
    upvar 1 $fnVar fn
    set words [split $rhs " "]
    set operands {}
    switch -- [lindex $words 0] {
        structnew { set operands [lrange $words 2 end] }
        structget { set operands [lrange $words 2 end] }
        op {
            if {[lindex $words 1] in {listnew listget}} {
                set operands [lrange $words 2 end]
            }
        }
    }
    set storages {}
    foreach operand $operands {
        if {[dict exists $fn keepAddr $operand]} {
            foreach storage [dict get $fn keepAddr $operand] {
                if {$storage ni $storages} {
                    lappend storages $storage
                }
            }
        }
    }
    if {$storages ne ""} {
        dict set fn keepAddr $reg $storages
    }
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

# Like AssignRaw, for an instruction whose result is a scalar String of KIND
# (`short` ShortString1 or `ascii` packed ASCII): records R in fn shortRegs
# (the header's `shortregs=` / `asciiregs=`).
proc native::lower::AssignScalar {fnVar kind rhs {e ""}} {
    upvar 1 $fnVar fn
    set r [Assign fn $rhs $e]
    dict set fn shortRegs $r $kind
    return $r
}

proc native::lower::AssignShort {fnVar rhs {e ""}} {
    upvar 1 $fnVar fn
    return [AssignScalar fn short $rhs $e]
}

# Declares REG a scalar String register of KIND without emitting an
# instruction (an if-join's shared result register, a tail-rebound parameter
# slot).
proc native::lower::MarkScalar {fnVar reg kind} {
    upvar 1 $fnVar fn
    dict set fn shortRegs $reg $kind
}

# 1 if REG is declared a scalar String register of FN.
proc native::lower::IsShortReg {fnVar reg} {
    upvar 1 $fnVar fn
    return [dict exists $fn shortRegs $reg]
}

# The kind (`short` or `ascii`) of scalar String register REG, or "".
proc native::lower::ScalarKind {fnVar reg} {
    upvar 1 $fnVar fn
    if {[dict exists $fn shortRegs $reg]} {
        return [dict get $fn shortRegs $reg]
    }
    return ""
}

# The ` shortregs="..." asciiregs="..."` suffix of FN's header ("" when it
# has no scalar String register).
proc native::lower::ShortRegsHeader {fnVar} {
    upvar 1 $fnVar fn
    if {![dict exists $fn shortRegs]} {
        return ""
    }
    set out ""
    foreach kind {short ascii} {
        set regs {}
        dict for {r k} [dict get $fn shortRegs] {
            if {$k eq $kind} { lappend regs [string range $r 1 end] }
        }
        if {$regs ne ""} {
            append out " ${kind}regs=[Quote [join [lsort -integer $regs] { }]]"
        }
    }
    return $out
}

# Increments statistic NAME of FN (the censuses' `short` counters).
proc native::lower::Tally {fnVar name} {
    upvar 1 $fnVar fn
    dict incr fn $name
}

# The ShortString1 scalar of a String's text of at most one character.
proc native::lower::ShortValueOf {text} {
    if {$text eq ""} {
        return -1
    }
    scan $text %c cp
    return $cp
}

# The text of ShortString1 scalar VALUE (-1: "").
proc native::lower::ShortText {value} {
    if {$value == -1} {
        return ""
    }
    return [format %c $value]
}

# The packed-ASCII word (a signed i64, as NIR prints it) of an ASCII text of
# at most eight characters: byte i is 0x80 | c.
proc native::lower::AsciiWordOf {text} {
    set w 0
    set i 0
    foreach ch [split $text ""] {
        scan $ch %c cp
        set w [expr {$w | (($cp | 0x80) << (8 * $i))}]
        incr i
    }
    if {$w >= 0x8000000000000000} {
        set w [expr {$w - 0x10000000000000000}]
    }
    return $w
}

# The text of packed-ASCII word W (a signed i64).
proc native::lower::AsciiText {w} {
    if {$w < 0} {
        set w [expr {$w + 0x10000000000000000}]
    }
    set text ""
    for {set i 0} {$i < 8} {incr i} {
        set b [expr {($w >> (8 * $i)) & 0xFF}]
        if {$b == 0} break
        append text [format %c [expr {$b & 0x7F}]]
    }
    return $text
}

# The scalar form of KIND (`ascii` or `short`) of the tagged String register
# REG, which the planner proved fits KIND (the caller asserts that): a literal
# register this lowering itself built becomes an `asciilit`/`shortlit`
# constant, any other a `strtoascii`/`strtoshort`. Cached with the reverse
# direction (fn rawCache), so the conversion happens once per region and a
# later materialization of the value it just extracted is the original
# register again.
proc native::lower::ScalarOf {fnVar reg kind} {
    upvar 1 $fnVar fn
    set key "$kind $reg"
    if {[dict exists $fn rawCache $key]} {
        return [dict get $fn rawCache $key]
    }
    if {[dict exists $fn strConst $reg]} {
        set text [dict get $fn strConst $reg]
        if {$kind eq "ascii"} {
            set r [AssignScalar fn ascii "asciilit [AsciiWordOf $text]"]
        } else {
            set r [AssignScalar fn short "shortlit [ShortValueOf $text]"]
        }
        dict set fn scalarConst $r $text
        Tally fn ${kind}Lits
    } else {
        set r [AssignScalar fn $kind "op [expr {$kind eq "ascii" ? "strtoascii" : "strtoshort"}] $reg"]
        Tally fn ${kind}FromTagged
    }
    dict set fn rawCache $key $r
    dict set fn rawCache $r $reg
    return $r
}

# The tagged String of the scalar String register REG (either kind): one
# `asciitostr`/`shorttostr` (allocating), or a String constant when REG is a
# literal this lowering built (no allocation: the constant is static).
# Cached with the reverse direction like ScalarOf. This is the one
# materialization of a virtual short String; every frontier that needs a real
# String comes through here.
proc native::lower::TaggedOfShort {fnVar reg} {
    upvar 1 $fnVar fn
    set cache [dict get $fn rawCache]
    if {[dict exists $cache $reg]} {
        return [dict get $cache $reg]
    }
    set kind [ScalarKind fn $reg]
    if {[dict exists $fn scalarConst $reg]} {
        set text [dict get $fn scalarConst $reg]
        set r [Assign fn "str [Quote $text]"]
        dict set fn strConst $r $text
        Tally fn ${kind}ConstMaterialized
    } else {
        set r [Assign fn "op [expr {$kind eq "ascii" ? "asciitostr" : "shorttostr"}] $reg"]
        Tally fn ${kind}ToTagged
    }
    dict set fn rawCache $reg $r
    dict set fn rawCache $r $reg
    return $r
}

# The ShortString1 form of packed-ASCII register REG, which the planner proved
# has at most one character (the caller asserts that): a `shortlit` when REG
# is a literal, else one `asciitoshort`. Cached.
proc native::lower::ShortOfAscii {fnVar reg} {
    upvar 1 $fnVar fn
    set key "short-of-ascii $reg"
    if {[dict exists $fn rawCache $key]} {
        return [dict get $fn rawCache $key]
    }
    if {[dict exists $fn scalarConst $reg]} {
        set text [dict get $fn scalarConst $reg]
        set r [AssignScalar fn short "shortlit [ShortValueOf $text]"]
        dict set fn scalarConst $r $text
        Tally fn shortLits
    } else {
        set r [AssignScalar fn short "op asciitoshort $reg"]
        Tally fn asciiToShort
    }
    dict set fn rawCache $key $r
    return $r
}

# Scalar register REG as a register of KIND: itself when it already is, a
# packed-ASCII value widened to a ShortString1 (the only conversion between
# kinds, valid because the plan proved the position holds at most one
# character); the reverse is a compiler bug.
proc native::lower::ScalarAs {fnVar reg kind} {
    upvar 1 $fnVar fn
    set have [ScalarKind fn $reg]
    if {$have eq $kind} {
        return $reg
    }
    if {$have eq "ascii" && $kind eq "short"} {
        return [ShortOfAscii fn $reg]
    }
    throw {NATIVE BUG} "native lowering: a $have register is demanded as $kind"
}

# A scalar constant of KIND for the proven String literal TEXT.
proc native::lower::ScalarLit {fnVar kind text e} {
    upvar 1 $fnVar fn
    if {$kind eq "ascii"} {
        set r [AssignScalar fn ascii "asciilit [AsciiWordOf $text]" $e]
    } else {
        set r [AssignScalar fn short "shortlit [ShortValueOf $text]" $e]
    }
    dict set fn scalarConst $r $text
    Tally fn ${kind}Lits
    return $r
}

# ---------------------------------------------------------------------------
# Expressions
#
# Each procedure emits the instructions evaluating an expression and returns
# the register holding its value, or "never" if evaluation cannot complete
# normally (the instructions then end in a terminator).

proc native::lower::Sequence {fnVar exprs} {
    upvar 1 $fnVar fn
    variable hir
    if {$exprs eq ""} {
        return [Assign fn unit]
    }
    foreach e $exprs {
        set result [Expr fn $e]
        if {$result eq "never"} {
            break
        }
        # The affine values dead after this statement (AFFINE-VALUES.md;
        # COROUTINES.md, "Release at the last use"), its own discarded value
        # included; the statement's value register stays the sequence's
        # value.
        ReleaseHandles fn [hir::affine::releasesAfter $hir $e] $e $result
    }
    return $result
}

# Releases what the release items ITEMS hold (hir::affine::DropPlan), at
# expression E: a binding's value (its register, or the field registers of
# a virtualized aggregate), a pending temporary's (the register Expr
# recorded for it, fn `temps`), or the statement E's own value (register
# RESULT). A coroutine is `corelease`d, an aggregate `affinedrop`ped by its
# static descriptor: AFFINE-VALUES.md; COROUTINES.md, "Release at the last
# use" and "Release on every early exit".
proc native::lower::ReleaseHandles {fnVar items e {result ""}} {
    upvar 1 $fnVar fn
    variable hir
    foreach item $items {
        set plan [hir::affine::DropPlan $hir $item]
        if {$plan eq ""} continue
        set descriptor [expr {[lindex $plan 0] eq "coroutine" ? "c" : [lindex $plan 1]}]
        if {[string match b* $item]} {
            set access [Access fn $item]
        } elseif {$item eq $e && [hir::kind $hir $e] eq "struct"
                || ($item eq $e && [hir::affine::NativeName $hir $e] eq "list")} {
            # A discarded construction (not built): its components.
            foreach {component type} [hir::affine::Components $hir $e] {
                if {[dict exists $fn temps $component]} {
                    DropAccess fn [dict get $fn temps $component] [hir::affine::Descriptor $hir $type] $e
                }
            }
            continue
        } elseif {$item eq $e && $result ne ""} {
            set access [list reg $result]
        } elseif {[dict exists $fn temps $item]} {
            set access [dict get $fn temps $item]
        } else {
            # A pending temporary not evaluated on this path.
            continue
        }
        DropAccess fn $access $descriptor $e
    }
}

# Drops the affine value at ACCESS (a register, or a virtualized
# aggregate's field registers in slot order) by DESCRIPTOR
# (hir::affine::Descriptor), at expression E.
proc native::lower::DropAccess {fnVar access descriptor e} {
    upvar 1 $fnVar fn
    switch -- [lindex $access 0] {
        reg {
            set where [lindex $access 1]
            if {$descriptor eq "c"} {
                Assign fn "op corelease $where" $e
            } else {
                set d [Assign fn "str [Quote $descriptor]" $e]
                Assign fn "op affinedrop $where $d" $e
            }
        }
        virtual {
            # A virtualized construction (its fields in registers, never
            # materialized): the descriptor applied to its fields directly.
            set fields [lindex $access 1]
            set pos 0
            foreach {field inner} [DescriptorParts $descriptor] {
                if {$field eq "*"} {
                    foreach r $fields {
                        DropAccess fn [list reg $r] $inner $e
                    }
                } else {
                    DropAccess fn [list reg [lindex $fields $field]] $inner $e
                }
            }
        }
        default {
            throw {NATIVE BUG} "native lowering: an affine value at $access cannot be released"
        }
    }
}

# The parts of an aggregate drop DESCRIPTOR as {SLOT INNER ...} pairs ("*"
# for every element of a List).
proc native::lower::DescriptorParts {descriptor} {
    switch -- [string index $descriptor 0] {
        l {
            return [list * [string range $descriptor 1 end]]
        }
        s {
            set pos 1
            set n [DescriptorNumber $descriptor pos]
            set parts {}
            for {set i 0} {$i < $n} {incr i} {
                set slot [DescriptorNumber $descriptor pos]
                set start $pos
                DescriptorSkip $descriptor pos
                lappend parts $slot [string range $descriptor $start $pos-1]
            }
            return $parts
        }
    }
    throw {NATIVE BUG} "native lowering: bad drop descriptor $descriptor"
}

proc native::lower::DescriptorNumber {descriptor posVar} {
    upvar 1 $posVar pos
    set end [string first . $descriptor $pos]
    set n [string range $descriptor $pos $end-1]
    set pos [expr {$end + 1}]
    return $n
}

proc native::lower::DescriptorSkip {descriptor posVar} {
    upvar 1 $posVar pos
    set c [string index $descriptor $pos]
    incr pos
    switch -- $c {
        l - v - a { DescriptorSkip $descriptor pos }
        s {
            set n [DescriptorNumber $descriptor pos]
            for {set i 0} {$i < $n} {incr i} {
                DescriptorNumber $descriptor pos
                DescriptorSkip $descriptor pos
            }
        }
    }
}

# Where a failure of call (or handle) E is pending: releases the affine
# values a declared error it propagates takes out of scope or abandons
# (hir::affine::releasesOnError), by the pending error's name, each
# matching group then propagating it on unchanged (`reraise`). The code
# after it runs only for other failures.
proc native::lower::ReleaseOnError {fnVar e byName} {
    upvar 1 $fnVar fn
    set saved [dict get $fn locals]
    set savedRaw [dict get $fn rawCache]
    dict for {name bindings} $byName {
        set eqReg [Assign fn "declarederroreq [ErrorId $name]" $e]
        set matchLabel [NewLabel fn]
        set nextLabel [NewLabel fn]
        Emit fn "br $eqReg $matchLabel $nextLabel" $e
        EmitLabel fn $matchLabel
        ReleaseHandles fn $bindings $e
        Emit fn "reraise" $e
        EmitLabel fn $nextLabel
    }
    dict set fn locals $saved
    dict set fn rawCache $savedRaw
}

proc native::lower::Expr {fnVar e {want tagged}} {
    upvar 1 $fnVar fn
    variable hir
    variable escape
    set node [hir::node $hir $e]
    set repr tagged
    # `rawjoin` is `raw` that an `if` may also honor by joining its branches
    # in one raw register. It is only ever demanded in the tail position, or
    # by a `return`, of a raw-result function (SequenceRaw, Expr's `return`),
    # where the value flows into the function's successful result: that
    # Range is proven small (the plan), and an `if`'s value is within it, so
    # each branch value is a small Int and the raw join is sound. Everywhere
    # else it is just `raw`.
    set rawJoin [expr {$want eq "rawjoin" && [dict get $node kind] eq "if" && [ResultRaw fn]}]
    if {$want eq "rawjoin"} {
        set want raw
    }
    # `short` / `ascii` ask for a ShortString1 / packed-ASCII register. Only
    # ever requested for a value the planner proved fits that tier
    # (ShortTier): an `if` then joins its branches directly in one register of
    # that kind (each branch value is itself proven, being below the join in
    # the fact lattice, and converts to the join's kind).
    set shortJoin [expr {$want in {short ascii} && [dict get $node kind] eq "if" ? $want : ""}]
    switch -- [dict get $node kind] {
        const    { lassign [ConstOrRegion fn $e $node $want] result repr }
        ref      { lassign [Ref fn $e $node $want] result repr }
        bind     { set result [Bind fn $e $node] }
        block    { set result [Closure fn $e] }
        call     { lassign [Call fn $e $node $want "" [expr {$want eq "region"}]] result repr }
        if       {
            set result [If fn $e $node "" "" "" $rawJoin $shortJoin]
            if {$rawJoin && $result ne "never"} {
                set repr raw
            }
            if {$shortJoin ne "" && $result ne "never"} {
                set repr $shortJoin
            }
        }
        loop      { set result [Loop fn $e $node] }
        listloop  { set result [ListLoop fn $e $node] }
        countloop { set result [CountLoop fn $e $node] }
        lockloop  { set result [LockLoop fn $e $node] }
        struct    { set result [Struct fn $e $node] }
        project   { set result [Project fn $e $node] }
        return {
            # The coroutines this exit takes out of scope: released before
            # its value, or (those the value refers to) right before
            # leaving.
            lassign [hir::affine::releasesOnExit $hir $e] before after
            ReleaseHandles fn $before $e
            set companion [dict get $fn companion]
            if {$companion ne ""} {
                # A scalar-replacement companion function (see the "Scalar
                # replacement" section above): hir::escape::wants only ever
                # holds when every reachable exit -- this one included --
                # classifies as a recognized construction of this same
                # arity, so VirtualValue's fields (not a materialized List)
                # are what this return actually produces.
                set fields [VirtualValue fn [dict get $node value] $companion \
                    [hir::escape::resultCut $escape [dict get $fn instance]]]
                if {$fields ne "never"} {
                    ReleaseHandles fn $after $e
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
                    ReleaseHandles fn $after $e
                    Emit fn "retmulti [join $fields { }]" $e
                }
            } elseif {[PlanResultFamily fn] ne ""} {
                # A plan-result instance (hir::construction, "Virtual
                # construction" below): its exact callers accept a plan, so
                # the returned construction stays virtual.
                set value [SequenceTo fn [list [dict get $node value]] [PlanResultFamily fn]]
                if {$value ne "never"} {
                    ReleaseHandles fn $after $e
                    Emit fn "ret $value" $e
                }
            } else {
                set value [Expr fn [dict get $node value] [expr {[ResultRaw fn] ? "rawjoin" : [ResultShort fn] ne "" ? [ResultShort fn] : "tagged"}]]
                if {$value ne "never"} {
                    ReleaseHandles fn $after $e
                    Emit fn "ret $value" $e
                }
            }
            set result never
        }
        break {
            lassign [hir::affine::releasesOnExit $hir $e] before after
            ReleaseHandles fn $before $e
            lassign [dict get $fn loops [dict get $node target]] head exit resultReg accReg
            if {$accReg ne ""} {
                # A returning iterable loop (listloop, RETURNING-ITERABLE-
                # LOOPS.md): a bare break ends the loop and returns the
                # List collected so far. break VALUE is rejected earlier,
                # at HIR resolve, for a listloop target, so node's own
                # value is always "" here -- nothing to evaluate. A
                # provably-discarded listloop (ListLoop's own "retained"
                # check below) has no real accumulator to move; accReg is
                # then the sentinel "discard", and the placeholder result
                # nothing downstream reads is filled with unit instead.
                # A retained accumulator is materialized here
                # (CollectFinish): it may be a construction plan.
                set prefix [expr {$accReg eq "discard" ? [Assign fn unit] : [CollectFinish fn $e $accReg]}]
                Emit fn "$resultReg = move $prefix" $e
                Emit fn "jump $exit" $e
                dict set fn broken [dict get $node target] 1
                set result never
            } else {
                set value ""
                if {[dict get $node value] ne ""} {
                    set value [Expr fn [dict get $node value]]
                }
                if {$value ne "never"} {
                    ReleaseHandles fn $after $e
                    if {$value eq ""} {
                        set value [Assign fn unit]
                    }
                    Emit fn "$resultReg = move $value" $e
                    Emit fn "jump $exit" $e
                    dict set fn broken [dict get $node target] 1
                }
                set result never
            }
        }
        continue {
            ReleaseHandles fn [lindex [hir::affine::releasesOnExit $hir $e] 0] $e
            lassign [dict get $fn loops [dict get $node target]] head
            Emit fn "jump $head" $e
            dict set fn continued [dict get $node target] 1
            set result never
        }
        ok - error {
            set value [Expr fn [dict get $node value]]
            if {$value eq "never"} {
                set result never
            } else {
                set result [Assign fn "op [expr {[dict get $node kind] eq "ok" ? "mkok" : "mkerror"}] $value" $e]
            }
        }
        fail {
            lassign [hir::affine::releasesOnExit $hir $e] before after
            ReleaseHandles fn $before $e
            set name [dict get $node name]
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                # ERROR-PAYLOADS.md: the payload's fields, evaluated in
                # written order, travel the error edge field-wise (the Vm's
                # payload slots): no struct object is built for them.
                set fields [PayloadFields fn [dict get $node value] $name $e]
                if {$fields ne "never"} {
                    ReleaseHandles fn $after $e
                    set layout [hir::types::StructLayout [hir::errordecls::payloadType $name]]
                    Emit fn "faildeclared [ErrorId $name] [Quote $name] [ShapeIndex {} $layout] [join $fields { }]" $e
                }
            } else {
                Emit fn "faildeclared [ErrorId $name] [Quote $name]" $e
            }
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
        set result never
    }
    if {$result eq "never"} {
        return [Never fn $e]
    }
    variable affineTemps
    if {[dict exists $affineTemps $e]} {
        # A pending temporary a release may name (ReleaseHandles).
        dict set fn temps $e [list reg $result]
    }
    if {$result ne "never" && $want eq "raw" && $repr eq "tagged"} {
        # WANT could not be produced directly (Ref/Call are the only kinds
        # that ever try): the declined-raw fallback, lower tagged then
        # runbox (milestone #6), reusing RawOf's cache like any other caller.
        set result [RawOf fn $result]
    }
    if {$result ne "never" && $want in {short ascii}} {
        if {$repr eq "tagged"} {
            # The tagged-to-scalar frontier: this value is a String the
            # planner proved fits the wanted tier but was produced as a real
            # String (a parameter of a tagged-ABI variant, a call of a
            # tagged-result function, ...). One `strtoshort`/`strtoascii`,
            # cached.
            if {![TierFits [ShortTier $e] $want]} {
                throw {NATIVE BUG} "native lowering: $want asked for the unproven expression $e"
            }
            set result [ScalarOf fn $result $want]
        } elseif {$repr in {short ascii}} {
            # A scalar of the other tier (a packed-ASCII value flowing into a
            # ShortString1 position): the one widening conversion.
            set result [ScalarAs fn $result $want]
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Structs (STRUCTS.md)
#
# A struct value is one heap object of a *shape* (a `shape` declaration of the
# program: an anonymous field set in canonical order, or one named
# declaration's identity and slot order) holding its field values in slot
# order; the object carries neither names nor static types. Construction is
# `structnew SHAPE regs...`: every field expression is lowered first, in
# WRITTEN order (their evaluation order -- the canonical slot layout never
# reorders evaluation, and an abrupt completion of a field leaves no struct
# built), and only then are the field registers handed to structnew in SLOT
# order. A named construction is one structnew of the declaration's own
# shape: no anonymous intermediate object exists. Projection is
# `structget SLOT reg`, the slot a constant resolved from the receiver's
# statically known struct type; a receiver whose shape is not statically
# known is refused here -- native code never looks a field up by name.

# The dense number of enum ID (see enumIds), assigned on first use.
proc native::lower::EnumIndex {id} {
    variable enumIds
    variable enumList
    if {![dict exists $enumIds $id]} {
        if {![hir::enums::declared $id]} {
            throw {NATIVE INVALID-HIR} "native lowering: enum \"$id\" is not declared in this program"
        }
        dict set enumIds $id [dict size $enumIds]
        lappend enumList $id
    }
    return [dict get $enumIds $id]
}

# The NIR constant `enum E C` of the case value V ({enum ID CASE}): E the
# enum's number, C the case's position in its declaration (ENUMS.md).
proc native::lower::EnumConst {fnVar v e} {
    upvar 1 $fnVar fn
    set id [core::value::enumId $v]
    set case [lsearch -exact [hir::enums::cases $id] [core::value::enumCaseName $v]]
    if {$case < 0} {
        throw {NATIVE INVALID-HIR} "native lowering: enum \"$id\" has no case \"[core::value::enumCaseName $v]\" ($e)"
    }
    return [Assign fn "enum [EnumIndex $id] $case" $e]
}

# The dense shape number of {ID LAYOUT} (see shapeIds), assigned on first use.
proc native::lower::ShapeIndex {id layout} {
    variable shapeIds
    variable shapeList
    set key [list $id $layout]
    if {![dict exists $shapeIds $key]} {
        dict set shapeIds $key [dict size $shapeIds]
        lappend shapeList $key
    }
    return [dict get $shapeIds $key]
}

# The field registers of struct construction NODE (expression E) in SLOT
# order, every field expression lowered first, in WRITTEN order (the
# evaluation order), or "never" if one of them cannot complete normally. No
# object exists yet: Struct builds one from these, a virtual struct
# (hir/escape.tcl) keeps them as they are.
proc native::lower::StructFields {fnVar e node {cut ""}} {
    upvar 1 $fnVar fn
    variable hir
    set regs {}
    set names [dict get $node names]
    foreach field [dict get $node fields] name $names {
        if {$cut ne "" && [dict exists [CutDict $cut] $name]} {
            # An opened inner literal: evaluated here, at the position the
            # field is written, its own fields in written order; they join
            # the outer's physical fields.
            if {[hir::kind $hir $field] ne "struct"} {
                throw {NATIVE BUG} "native lowering: field \"$name\" opened but not an inline literal ($field)"
            }
            lassign [dict get [CutDict $cut] $name] sub subcut
            set r [StructFields fn $field [hir::node $hir $field] $subcut]
            if {$r ne "never" && [hir::typeOf $hir $field] eq "never"} {
                Emit fn unreachable $field
                return never
            }
        } else {
            set r [Expr fn $field]
        }
        if {$r eq "never"} {
            return never
        }
        lappend regs $r
    }
    set layout [dict get $node layout]
    set ordered {}
    foreach name $layout {
        set r [lindex $regs [lsearch -exact $names $name]]
        if {$cut ne "" && [dict exists [CutDict $cut] $name]} {
            lappend ordered {*}$r
        } else {
            lappend ordered $r
        }
    }
    return $ordered
}

# The cut CUT ({NAME SUBSHAPE SUBCUT ...}) as a dict NAME -> {SUBSHAPE SUBCUT}.
proc native::lower::CutDict {cut} {
    set d [dict create]
    foreach {name sub subcut} $cut {
        dict set d $name [list $sub $subcut]
    }
    return $d
}

# The index, among the physical fields of a struct of SHAPE opened as CUT, of
# the first physical field of the layout field NAME (an opened field's
# fields are contiguous there).
proc native::lower::FieldOffset {shape cut name} {
    set offset 0
    set cuts [CutDict $cut]
    foreach field [lindex $shape 1] {
        if {$field eq $name} {
            return $offset
        }
        if {[dict exists $cuts $field]} {
            lassign [dict get $cuts $field] sub subcut
            incr offset [hir::escape::CutFields $sub $subcut]
        } else {
            incr offset
        }
    }
    throw {NATIVE BUG} "native lowering: no field \"$name\" in shape $shape"
}

# The object of a struct of SHAPE opened as CUT whose physical fields are the
# registers FIELDS: inner objects of opened fields first, then the outer,
# each `structnew` of its exact shape. Source expression E.
proc native::lower::BuildStruct {fnVar shape cut fields e} {
    upvar 1 $fnVar fn
    lassign $shape id layout
    set cuts [CutDict $cut]
    set regs {}
    set pos 0
    foreach field $layout {
        if {[dict exists $cuts $field]} {
            lassign [dict get $cuts $field] sub subcut
            set w [hir::escape::CutFields $sub $subcut]
            lappend regs [BuildStruct fn $sub $subcut [lrange $fields $pos [expr {$pos + $w - 1}]] $e]
            incr pos $w
        } else {
            lappend regs [lindex $fields $pos]
            incr pos
        }
    }
    return [Assign fn "structnew [ShapeIndex $id $layout] [join $regs { }]" $e]
}

# The shape key ({ID LAYOUT}, ShapeIndex's key) of struct construction NODE.
proc native::lower::StructShapeOf {node} {
    return [list [expr {[dict get $node named] ? [dict get $node structId] : ""}] [dict get $node layout]]
}

proc native::lower::Struct {fnVar e node} {
    upvar 1 $fnVar fn
    variable context
    variable structOpt
    set ordered [StructFields fn $e $node]
    if {$ordered eq "never"} {
        return never
    }
    if {$structOpt && [dict exists $context discarded $e]} {
        # A struct value nothing reads (statement position): its fields were
        # evaluated for their effects, in order, and no object is needed.
        return [Assign fn unit]
    }
    lassign [StructShapeOf $node] id layout
    return [Assign fn "structnew [ShapeIndex $id $layout] [join $ordered { }]" $e]
}

# Materialization (STRUCT-SCALAR-REPLACEMENT.md): the physical struct of the
# virtual binding B -- `structnew` of its exact shape (named identity or
# canonical anonymous field set) from fields that all already exist,
# emitted at the first use that needs the object. The register is recorded
# in the *root* binding's entry (an alias shares its source's), so every
# later use this scope dominates reads the same object; a branch or loop
# body restores `fn locals` on the way out, dropping a materialization that
# does not dominate what follows.
proc native::lower::MaterializeVirtual {fnVar b e} {
    upvar 1 $fnVar fn
    set local [dict get $fn locals $b]
    lassign $local tag fields shape root
    if {$shape eq ""} {
        throw {NATIVE BUG} "native lowering: virtual binding $b has no struct shape to materialize ($e)"
    }
    set rootLocal [dict get $fn locals $root]
    if {[lindex $rootLocal 6] eq "partial"} {
        # A handler payload whose unread fields were never read
        # (PayloadNeeded): it has no object to build.
        throw {NATIVE BUG} "native lowering: the payload binding $root is used whole, but only some fields were read ($e)"
    }
    set mat [lindex $rootLocal 4]
    if {$mat ne ""} {
        return $mat
    }
    set mat [BuildStruct fn $shape [lindex $rootLocal 5] [lindex $rootLocal 1] $e]
    dict set fn locals $root [lreplace $rootLocal 4 4 $mat]
    return $mat
}

proc native::lower::Project {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable escape
    variable currentInstance
    set path [ContextPath fn $e]
    if {$path ne ""} {
        # A projection chain of a context parameter (CONTEXTS.md): the slot
        # word of a leaf, read directly (no receiver is evaluated).
        return [ContextAt fn $e {*}$path]
    }
    set receiver [dict get $node receiver]
    set type [hir::typeOf $hir $receiver]
    set name [dict get $node name]
    if {[hir::kind $hir $receiver] eq "project"} {
        # A chain `root.f.g...`: when the root is held as virtual fields whose
        # cut opened an inner value (or is a recognized call result read from
        # its fields), the whole chain is one field register; an inner value
        # the cut kept closed is an ordinary object read with `structget`.
        set r [ProjectChain fn $e $node]
        if {$r ne ""} {
            return $r
        }
    }
    if {[hir::kind $hir $receiver] eq "ref"} {
        # A receiver currently held as virtual fields (a virtual local, or a
        # virtual parameter of this `fields` variant): the projection is the
        # field register itself -- no `structget`, and the receiver is not
        # evaluated (a plain reference has no effect of its own).
        set b [hir::get $hir $receiver binding]
        if {$b ne "" && [dict exists $fn locals $b]} {
            set local [dict get $fn locals $b]
            if {[lindex $local 0] eq "virtual" && [lindex $local 2] ne ""} {
                set slot [lsearch -exact [lindex $local 2 1] $name]
                if {$slot < 0} {
                    throw {NATIVE BUG} "native lowering: virtual binding $b has no field \"$name\" ($e)"
                }
                return [lindex [lindex $local 1] [FieldOffset [lindex $local 2] [lindex $local 5] $name]]
            }
        }
    }
    set direct [hir::escape::directProjection $escape $currentInstance $e]
    if {$direct ne ""} {
        # The receiver is itself a recognized struct construction (a literal,
        # or an exact call returning fields): read the field from its virtual
        # fields; the other fields were evaluated for their effects only.
        lassign $direct n shape cut
        set slot [lsearch -exact [lindex $shape 1] $name]
        set fields [VirtualValue fn $receiver $n $cut]
        if {$fields eq "never"} {
            return never
        }
        return [lindex $fields [FieldOffset $shape $cut $name]]
    }
    if {$type eq "never"} {
        # HIR proved the receiver never completes normally (an element of a
        # `List[never]`, which is empty, in an instance for the argument
        # `[]`), so the projection is unreachable: Expr ends the receiver's
        # evaluation in `unreachable` and the projection needs no slot.
        return [Expr fn $receiver]
    }
    set slot [expr {[hir::types::IsStructLike $type] ? [lsearch -exact [hir::types::StructLayout $type] $name] : -1}]
    if {$slot < 0} {
        Unsupported $e struct-shape \
            "the field projection \".$name\" has a receiver of type [hir::types::show $type], so its slot is not statically known (native code compiles a projection to a known slot and never looks fields up by name)"
    }
    set r [Expr fn $receiver]
    if {$r eq "never"} {
        return never
    }
    return [Assign fn "structget $slot $r" $e]
}

# ---------------------------------------------------------------------------
# Contexts (CONTEXTS.md)
#
# The first native lowering of execution-environment contexts is deliberately
# the simplest one for the common case -- a process installs its contexts at
# startup, once each -- and is static all the way down:
#
#   * one context area per program: a single zero-initialized, 8-byte
#     aligned, writable, linker-local data object (`botlish_context_area`,
#     codegen/clif.rs), holding every context slot;
#   * one slot per context-struct type the program installs, assigned at
#     compile time in installation (program) order (ContextSlots), at a fixed
#     byte offset, and laid out flattened: one 64-bit word per scalar leaf of
#     the struct, nested structs inlined, in declared field order
#     (ContextLeaves);
#   * `with context EXPR` (the program function) evaluates EXPR in ordinary
#     execution order and stores its leaves: `contextstore OFFSET %leaf`;
#   * a context parameter `io` is a local whose value is never loaded as a
#     whole: a projection chain `io.stdout.raw.value` that ends at a leaf is
#     one `contextload OFFSET` (ContextAt), and a sub-struct handed to a
#     callee that receives it as fields (`linux::write`'s `fd`) is its leaves
#     (ContextFields); only a use that needs the physical object (passing
#     `io` itself to a function that keeps it whole, storing it, returning
#     it) materializes one, from loads, with `structnew` -- exactly where an
#     ordinary struct of the same shape would be materialized.
#
# Codegen turns OFFSET into the area's fixed address plus a constant
# displacement: a PC-relative `lea` of the data symbol in the AOT object, an
# absolute address in the JIT. No context pointer is passed, no register is
# reserved, nothing is looked up, and there is no presence flag: hir/
# contexts.tcl proved every load is preceded by its installation.
#
# Eligibility (StaticContextEligible, ContextLeaves): a leaf must be a value
# whose tagged word is never a heap pointer -- an Int whose declared domain
# fits the small-Int representation, a Bool, Unit or a UnicodeChar -- so the
# area needs no GC root, no tracing and no dynamic layout -- or a MutableVector
# or MutableArray header, which installation registers as a permanent root. Any other context
# type is CONTEXT-NATIVE-LOWERING-UNSUPPORTED (native compilation fails,
# naming the field and why); nothing is boxed, pointed to or looked up
# instead.

namespace eval native::lower {
    # The program's context slots: ID -> {slot N offset BYTES leaves
    # {{PATH TYPE} ...}}, PATH a list of field names (ContextSlots).
    variable contextSlots [dict create]
    variable contextBytes 0
}

# {ok LEAVES} or {no REASON}: the flattened native layout of context-struct
# ID. LEAVES lists {PATH TYPE} in slot order, PATH the field names from ID
# down to the leaf.
proc native::lower::ContextLeaves {id {seen {}}} {
    if {![hir::structs::declared $id]} {
        return [list no "its declaration is not part of the program"]
    }
    if {$id in $seen} {
        return [list no "it contains itself (a recursive layout has no fixed size)"]
    }
    set leaves {}
    foreach {field type} [hir::structs::fieldTypes $id] {
        if {[lindex $type 0] eq "nstruct"} {
            lassign [ContextLeaves [lindex $type 1] [concat $seen [list $id]]] status inner
            if {$status ne "ok"} {
                return [list no "field \"$field\" ([hir::types::show $type]) cannot be flattened: $inner"]
            }
            foreach leaf $inner {
                lassign $leaf path leafType
                lappend leaves [list [concat [list $field] $path] $leafType]
            }
            continue
        }
        set kind [hir::types::kindOf $type]
        switch -- $kind {
            bool - unit - UnicodeChar - enum {
                # (An enum case, ENUMS.md, is an immediate word: never a
                # heap pointer.)
                lappend leaves [list [list $field] $type]
            }
            mutvec - mutarray {
                # A MutableVector or MutableArray member (MUTABLE-VECTOR.md,
                # MUTABLE-ARRAY.md): its header,
                # which the context owns for the whole run -- mutated in
                # place, never replaced -- is registered as a permanent GC
                # root when installed (`ctxroot`), so the area itself
                # needs no scanning and a loaded header is kept alive by
                # that root.
                lappend leaves [list [list $field] $type]
            }
            int {
                if {![hir::range::fitsSmall [hir::range::TypeFact $type]]} {
                    return [list no "field \"$field\" is an Int ([hir::types::show $type]) whose declared domain does not fit the small-Int representation, so its value may be a heap-allocated big integer that fixed program data could not keep alive (no GC root)"]
                }
                lappend leaves [list [list $field] $type]
            }
            default {
                return [list no "field \"$field\" has type [hir::types::show $type], a value that may be (or contain) a GC-managed heap object, and fixed program data holds no GC root"]
            }
        }
    }
    return [list ok $leaves]
}

# Assigns the program's context slots (contextSlots, contextBytes), in the
# order the program installs them: its top-level installations that
# verification gave an identity (hir::contexts::installId, which HIR text
# carries as "installs ID", so a HIR read back from text gets the same
# slots). Raises CONTEXT-NATIVE-LOWERING-UNSUPPORTED for an installed context
# whose type is not StaticContextEligible.
proc native::lower::ContextSlots {} {
    variable baseHir
    variable hir
    variable contextSlots
    variable contextBytes
    set contextSlots [dict create]
    set contextBytes 0
    foreach c [dict get $baseHir roots] {
        if {![hir::contexts::isInstall $baseHir $c]} continue
        set id [hir::contexts::installId $baseHir $c]
        if {$id eq "" || [dict exists $contextSlots $id]} continue
        lassign [ContextLeaves $id] status leaves
        if {$status ne "ok"} {
            set where ""
            set location [hir::aot::Location $baseHir [hir::get $baseHir $c origin]]
            if {[dict exists $location line]} {
                set where "[dict get $location file]:[dict get $location line]:[dict get $location column]: "
            }
            throw {NATIVE UNSUPPORTED CONTEXT-NATIVE-LOWERING-UNSUPPORTED} \
                "${where}CONTEXT-NATIVE-LOWERING-UNSUPPORTED: context $id cannot currently be stored in a fixed native context slot because $leaves"
        }
        dict set contextSlots $id [dict create slot [dict size $contextSlots] offset $contextBytes leaves $leaves]
        incr contextBytes [expr {8 * [llength $leaves]}]
    }
}

# The NIR header lines of the context area: `contexts=BYTES` is appended to
# the `nir` line by the caller; one `context` line per slot.
proc native::lower::ContextHeader {} {
    variable contextSlots
    set lines {}
    dict for {id slot} $contextSlots {
        set paths [lmap leaf [dict get $slot leaves] {join [lindex $leaf 0] .}]
        lappend lines "context [dict get $slot slot] [Quote $id] offset=[dict get $slot offset] words=[llength $paths] fields=[Quote [join $paths { }]]"
    }
    return $lines
}

# The slot record of installed context ID, or "" when the program does not
# install it.
proc native::lower::ContextOffsetSlot {id} {
    variable contextSlots
    if {![dict exists $contextSlots $id]} {
        return ""
    }
    return [dict get $contextSlots $id]
}

# The byte offset in the context area of the word of leaf PATH (field
# names) of installed context ID, or "" when PATH is not a leaf.
proc native::lower::ContextOffset {id path} {
    variable contextSlots
    set slot [dict get $contextSlots $id]
    set i 0
    foreach leaf [dict get $slot leaves] {
        if {[lindex $leaf 0] eq $path} {
            return [expr {[dict get $slot offset] + 8 * $i}]
        }
        incr i
    }
    return ""
}

# The declared type of the value at PATH (field names) below context-struct
# ID ({nstruct ID} for an empty PATH).
proc native::lower::ContextTypeAt {id path} {
    set type [list nstruct $id]
    foreach name $path {
        set type [hir::structs::fieldType [lindex $type 1] $name]
    }
    return $type
}

# The first context diagnostic of the program (hir/contexts.tcl), as
# {KIND MESSAGE}, or "": a -strict 0 program that failed context verification
# raises it when it starts (native code never runs code whose context loads
# were not proven).
proc native::lower::ContextDiagnostic {} {
    variable baseHir
    foreach d [dict get $baseHir diagnostics] {
        if {[dict get $d kind] in {MISSING-CONTEXT DUPLICATE-CONTEXT NOT-A-CONTEXT CONTEXT-TYPE-NOT-EXACT
                CONTEXT-INSTALLATION-UNSUPPORTED CONTEXT-FUNCTION-VALUE CONTEXT-BINDING-COLLISION
                DUPLICATE-CONTEXT-PARAMETER}} {
            return [list [dict get $d kind] [dict get $d message]]
        }
    }
    return ""
}

# A load (at E) of context ID, which the program never installs: only
# possible in a program that failed verification (whose program function
# raises the diagnostic before anything runs, Function), and then unreachable
# code; anything else is a lowering bug.
proc native::lower::UninstalledContext {fnVar e id} {
    upvar 1 $fnVar fn
    if {[ContextDiagnostic] eq ""} {
        throw {NATIVE BUG} "native lowering: context load $e of context \"$id\", which the program does not install"
    }
    Emit fn "raise MISSING-CONTEXT [Quote "$id: no context of this type is installed"]" $e
    return never
}

# `with context VALUE` (call E, NODE): VALUE is evaluated in ordinary order,
# then each scalar leaf of it is stored into the type's slot. Returns
# {REG tagged} (unit) like a call.
proc native::lower::ContextInstallCall {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable contextSlots
    if {[dict get $fn region] ne "program"} {
        throw {NATIVE BUG} "native lowering: context installation outside the program function ($e)"
    }
    set id [hir::contexts::installId $hir $e]
    if {$id eq "" || ![dict exists $contextSlots $id]} {
        throw {NATIVE BUG} "native lowering: context installation $e has no assigned slot"
    }
    set arg [lindex [dict get $node args] 0]
    set slot [dict get $contextSlots $id]
    set leaves {}
    set b [expr {[hir::kind $hir $arg] eq "ref" ? [hir::get $hir $arg binding] : ""}]
    set local [expr {$b ne "" && [dict exists $fn locals $b] ? [dict get $fn locals $b] : ""}]
    if {[lindex $local 0] eq "virtual" && [lindex $local 2] ne ""} {
        # The installed value held as fields (the hygienic temporary of
        # `with context`, hir/escape.tcl's ctxUse): its leaves without the
        # object, a closed inner struct read with `structget`.
        lassign $local - fields shape - - cut
        set leaves [ContextLeafRegs fn $e $shape $cut $fields]
    } else {
        set value [Expr fn $arg]
        if {$value eq "never"} {
            return {never tagged}
        }
        set leaves [ContextObjectLeaves fn $e $id $value]
    }
    set offset [dict get $slot offset]
    if {[llength $leaves] != [llength [dict get $slot leaves]]} {
        throw {NATIVE BUG} "native lowering: context installation $e yields [llength $leaves] words for a [llength [dict get $slot leaves]]-word slot"
    }
    foreach r $leaves leaf [dict get $slot leaves] {
        Emit fn "contextstore $offset $r" $e
        if {[hir::types::kindOf [lindex $leaf 1]] in {mutvec mutarray}} {
            Assign fn "op ctxroot $r" $e
        }
        incr offset 8
    }
    dict lappend fn calls [list native [core::contexts::installNative]]
    return [list [Assign fn unit $e] tagged]
}

# The leaf registers, in slot order, of the struct object in register VALUE
# whose type is the named struct ID: `structget` down every path.
proc native::lower::ContextObjectLeaves {fnVar e id value} {
    upvar 1 $fnVar fn
    set regs {}
    foreach {name type} [hir::structs::fieldTypes $id] {
        set index [lsearch -exact [hir::structs::names $id] $name]
        set r [Assign fn "structget $index $value" $e]
        if {[lindex $type 0] eq "nstruct"} {
            lappend regs {*}[ContextObjectLeaves fn $e [lindex $type 1] $r]
        } else {
            lappend regs $r
        }
    }
    return $regs
}

# The leaf registers, in slot order, of a struct of SHAPE opened as CUT whose
# physical fields are the registers FIELDS (a virtual value): an opened field
# contributes its own fields' leaves, a closed struct field its object's
# (ContextObjectLeaves), a scalar field itself.
proc native::lower::ContextLeafRegs {fnVar e shape cut fields} {
    upvar 1 $fnVar fn
    lassign $shape id layout
    set cuts [CutDict $cut]
    set regs {}
    set pos 0
    foreach name $layout {
        if {[dict exists $cuts $name]} {
            lassign [dict get $cuts $name] sub subcut
            set w [hir::escape::CutFields $sub $subcut]
            lappend regs {*}[ContextLeafRegs fn $e $sub $subcut [lrange $fields $pos [expr {$pos + $w - 1}]]]
            incr pos $w
            continue
        }
        set r [lindex $fields $pos]
        incr pos
        set type [hir::structs::fieldType $id $name]
        if {[lindex $type 0] eq "nstruct"} {
            lappend regs {*}[ContextObjectLeaves fn $e [lindex $type 1] $r]
        } else {
            lappend regs $r
        }
    }
    return $regs
}

# {ID PATH} when expression E (of the current instance) denotes the value at
# PATH (field names) of the installed context ID: a reference to a context
# parameter local, or a projection chain rooted at one. "" otherwise.
proc native::lower::ContextPath {fnVar e} {
    upvar 1 $fnVar fn
    variable hir
    set names {}
    while {[hir::kind $hir $e] eq "project"} {
        set names [linsert $names 0 [hir::get $hir $e name]]
        set e [hir::get $hir $e receiver]
    }
    if {[hir::kind $hir $e] ne "ref"} {
        return ""
    }
    set b [hir::get $hir $e binding]
    if {$b eq "" || ![dict exists $fn locals $b] || [lindex [dict get $fn locals $b] 0] ne "context"} {
        return ""
    }
    return [list [lindex [dict get $fn locals $b] 1] $names]
}

# The tagged register of the value at PATH of installed context ID (source
# expression E): one `contextload` for a scalar leaf; for a struct, the
# physical object built from its leaves' loads (a use that needs the object).
proc native::lower::ContextAt {fnVar e id path} {
    upvar 1 $fnVar fn
    set offset [ContextOffset $id $path]
    if {$offset ne ""} {
        return [Assign fn "contextload $offset" $e]
    }
    set type [ContextTypeAt $id $path]
    if {[lindex $type 0] ne "nstruct"} {
        throw {NATIVE BUG} "native lowering: context path $id.[join $path .] is neither a leaf nor a struct ($e)"
    }
    set sid [lindex $type 1]
    set regs [lmap name [hir::structs::names $sid] {
        ContextAt fn $e $id [concat $path [list $name]]
    }]
    return [Assign fn "structnew [ShapeIndex $sid [hir::structs::names $sid]] [join $regs { }]" $e]
}

# The physical fields of the struct value at PATH of installed context ID,
# opened as CUT (hir/escape.tcl's cut of the receiving parameter): each opened
# field contributes its own fields, each closed one a register (a leaf's load,
# or a struct field's materialized object).
proc native::lower::ContextFields {fnVar e id path cut} {
    upvar 1 $fnVar fn
    set sid [lindex [ContextTypeAt $id $path] 1]
    set cuts [CutDict $cut]
    set regs {}
    foreach name [hir::structs::names $sid] {
        if {[dict exists $cuts $name]} {
            lassign [dict get $cuts $name] sub subcut
            lappend regs {*}[ContextFields fn $e $id [concat $path [list $name]] $subcut]
        } else {
            lappend regs [ContextAt fn $e $id [concat $path [list $name]]]
        }
    }
    return $regs
}

# The number of physical fields ContextFields gives for PATH of ID under CUT.
proc native::lower::ContextFieldCount {id path cut} {
    set type [ContextTypeAt $id $path]
    if {[lindex $type 0] ne "nstruct"} {
        return ""
    }
    set sid [lindex $type 1]
    return [hir::escape::CutFields [list $sid [hir::structs::names $sid]] $cut]
}

# ---------------------------------------------------------------------------
# linux::abi::syscall (core/linuxabi.tcl, LINUX-X86-64-SYSCALL.md)
#
# `linux::abi::syscall(REGS)`, REGS an anonymous struct of abi::x86_64::
# Register64 fields named after the Linux x86-64 syscall registers (hir/
# syscall.tcl proved that statically), lowers to
#
#   %w = op syscall_linux_x86_64 RAX RDI RSI RDX R10 R8 R9
#
# the seven operands being the registers' words (Ints, each a proven
# -2^63..2^63-1 Register64Word) in the syscall convention's order, the Int 0
# for an argument register REGS omits, and %w the raw rax afterwards (an
# Int). The op is a helper call the backend never removes, merges or moves.
#
# Representation (the transport is zero-allocation in its canonical form):
#   * an inline REGS literal is never built: its fields are evaluated in
#     written order, each register's word read straight from it -- from the
#     fields of a recognized Register64 construction (hir::escape::
#     registerWord: a register64(...) call returning fields, a literal, a
#     nested syscall), from a virtual Register64 local, or else from the
#     object with `structget` (a Register64 that already exists);
#   * any other REGS (a struct value from elsewhere) is read with `structget`;
#   * the result Register64 is the one-field construction {word: %w}: handed
#     back as that field when the caller wants it virtual (hir/escape.tcl's
#     Classify recognizes the call like a literal), built with `structnew`
#     only when an object is needed.
proc native::lower::SyscallCall {fnVar e node wantVirtual} {
    upvar 1 $fnVar fn
    variable hir
    variable context
    variable structOpt
    set problems [hir::syscall::Problems $hir $e $node]
    if {$problems ne ""} {
        # A -strict 0 program whose call hir/syscall.tcl rejected: replay the
        # problem unconditionally, before anything is evaluated (LockLoop's
        # precedent). Compiling the call instead would read registers from
        # values nothing proved to be Register64s, or run a syscall whose
        # registers are not the ones written.
        lassign [lindex $problems 0] kind message
        dict incr fn skippedGuards [SkippedBlockers [dict get $node args]]
        Emit fn "raise $kind [Quote "linux::abi::syscall: $message"]" $e
        return {never tagged}
    }
    set registerType [core::linuxabi::registerType]
    if {![hir::structs::declared $registerType]} {
        throw {NATIVE BUG} "native lowering: linux::abi::syscall without a declared $registerType ($e)"
    }
    set layout [hir::structs::names $registerType]
    set words [SyscallWords fn $e [lindex [dict get $node args] 0]]
    if {$words eq "never"} {
        return {never tagged}
    }
    set operands {}
    set zero ""
    foreach register [core::linuxabi::registers] {
        if {[dict exists $words $register]} {
            lappend operands [dict get $words $register]
        } else {
            # An omitted argument register is zero (one constant for all).
            if {$zero eq ""} {
                set zero [Assign fn "int 0" $e]
            }
            lappend operands $zero
        }
    }
    dict lappend fn calls [list native linux::abi::syscall]
    set rax [Assign fn "op syscall_linux_x86_64 [join $operands { }]" $e]
    # The kernel may read memory the address operands point into. Every byte
    # storage whose address (`bytesaddr`, BytesAddrCall) reached an operand
    # register stays a GC root until the syscall has returned: a `keepalive`
    # of it AFTER the transition makes the storage live from its definition
    # through every safepoint up to and including this syscall, whatever
    # else the function does with it (or does not). This is the one place
    # that guarantees it, explicit in the NIR, never an accident of
    # register allocation or lexical variable lifetime (ABI-BYTES.md).
    set kept {}
    foreach operand $operands {
        if {[dict exists $fn keepAddr $operand]} {
            foreach storage [dict get $fn keepAddr $operand] {
                if {$storage ni $kept} {
                    lappend kept $storage
                }
            }
        }
    }
    foreach storage $kept {
        Assign fn "op keepalive $storage" $e
    }
    if {$wantVirtual ne ""} {
        if {$wantVirtual != 1} {
            throw {NATIVE BUG} "native lowering: expected a 1-field Register64 construction at $e"
        }
        return [list [list $rax] virtual]
    }
    if {$structOpt && [dict exists $context discarded $e]} {
        # Nothing reads the result (statement position): the transition ran,
        # no Register64 object is needed.
        return [list [Assign fn unit] tagged]
    }
    return [list [Assign fn "structnew [ShapeIndex $registerType $layout] $rax" $e] tagged]
}

# Register name -> the register's word (an Int register), for the registers
# REGS (linux::abi::syscall's argument expression) names, every field
# evaluated once in written order; "never" if one cannot complete normally.
proc native::lower::SyscallWords {fnVar e regs} {
    upvar 1 $fnVar fn
    variable hir
    variable escape
    variable currentInstance
    set words [dict create]
    if {[hir::kind $hir $regs] eq "struct"} {
        # An inline literal: never built.
        set node [hir::node $hir $regs]
        foreach name [dict get $node names] field [dict get $node fields] {
            set w [RegisterWordOf fn $field]
            if {$w eq "never"} {
                return never
            }
            dict set words $name $w
        }
        return $words
    }
    set type [hir::typeOf $hir $regs]
    set object [Expr fn $regs]
    if {$object eq "never"} {
        return never
    }
    set layout [hir::types::StructLayout $type]
    foreach name $layout {
        set register [Assign fn "structget [lsearch -exact $layout $name] $object" $e]
        set word [Assign fn "structget 0 $register" $e]
        KeepAddrThrough fn $register $word
        dict set words $name $word
    }
    return $words
}

# The word (an Int register) of Register64 expression FIELD, evaluated here,
# or "never".
proc native::lower::RegisterWordOf {fnVar field} {
    upvar 1 $fnVar fn
    variable hir
    variable escape
    variable currentInstance
    set desc [hir::escape::registerWord $escape $currentInstance $field]
    if {$desc ne ""} {
        # A recognized construction: its one field, never an object.
        lassign $desc n shape cut
        set fields [VirtualValue fn $field $n $cut]
        if {$fields eq "never"} {
            return never
        }
        return [lindex $fields 0]
    }
    if {[hir::kind $hir $field] eq "ref"} {
        # A Register64 held as a virtual local (or a virtual parameter of
        # this `fields` variant): its word register, nothing evaluated.
        set b [hir::get $hir $field binding]
        if {$b ne "" && [dict exists $fn locals $b]} {
            set local [dict get $fn locals $b]
            if {[lindex $local 0] eq "virtual" && [lindex $local 2] ne ""} {
                return [lindex [lindex $local 1] 0]
            }
        }
    }
    set object [Expr fn $field]
    if {$object eq "never"} {
        return never
    }
    set word [Assign fn "structget 0 $object" $field]
    KeepAddrThrough fn $object $word
    return $word
}

# Carries a raw address's byte-storage provenance (`keepAddr`, BytesAddrCall)
# from register FROM to register TO when TO is read out of (or built from)
# FROM -- a Register64 object holding an address, and the word read back out
# of it -- so the syscall that consumes TO still keeps the storage alive.
proc native::lower::KeepAddrThrough {fnVar from to} {
    upvar 1 $fnVar fn
    if {[dict exists $fn keepAddr $from]} {
        dict set fn keepAddr $to [dict get $fn keepAddr $from]
    }
}

# `abi::bytes::from_list(BYTES)` (lib/abi/bytes.bot) whose argument is a compile-time constant
# byte sequence: the owned storage is a *static constant*,
#
#   %b = bytes "HEX"
#
# installed once at program start (never collected, never allocated at run
# time), and the Bytes it belongs to is the one virtual field %b -- so
# `abi::bytes::from_list(str::encode_utf8("hello\n"))` costs no heap buffer, no List and
# no run-time conversion. Source semantics are unchanged: a Bytes is a value
# (equal by its bytes, no identity), so a shared static storage cannot be told
# from a fresh copy. What is recognized, deliberately narrow (no new analysis;
# hir::exact's existing facts): `str::encode_utf8` of a statically known
# String (any length), and a List of at most hir::exact's own element bound
# whose every element is statically a byte. Anything else (a dynamic List) is
# the ordinary call and conversion. Returns "" for a call that is not such a
# construction, else the result Call returns: the Bytes as virtual fields when
# WANTVIRTUAL, else built with `structnew` (a module binding, a List element,
# an argument of an unspecialized call).
proc native::lower::StaticBytesCall {fnVar e node wantVirtual} {
    upvar 1 $fnVar fn
    variable hir
    variable context
    variable structOpt
    set calleeExpr [dict get $node callee]
    if {[hir::kind $hir $calleeExpr] ne "ref" || [llength [dict get $node args]] != 1} {
        return ""
    }
    set b [hir::get $hir $calleeExpr binding]
    if {$b eq "" || [dict get [hir::binding $hir $b] name] ne "abi::bytes::from_list"} {
        return ""
    }
    set known [ConstantBytesOf [lindex [dict get $node args] 0]]
    if {$known eq ""} {
        return ""
    }
    set hex [lindex $known 0]
    set bytesType [core::bytestore::bytesType]
    if {![hir::structs::declared $bytesType] || [llength [hir::structs::names $bytesType]] != 1} {
        return ""
    }
    set layout [hir::structs::names $bytesType]
    # The argument is a pure constant expression: nothing to evaluate.
    set storage [Assign fn "bytes [Quote $hex]" $e]
    if {$wantVirtual ne ""} {
        if {$wantVirtual != 1} {
            return ""
        }
        return [list [list $storage] virtual]
    }
    if {$structOpt && [dict exists $context discarded $e]} {
        return [list [Assign fn unit] tagged]
    }
    return [list [Assign fn "structnew [ShapeIndex $bytesType $layout] $storage" $e] tagged]
}

# {HEX} -- the lowercase hexadecimal text of the bytes (core/bytestore.tcl's
# {bytestore HEX} text, empty for no bytes) -- when the byte-List expression E
# is statically known, "" when it is not: `str::encode_utf8` of an exactly known
# String, or an exactly known List each of whose elements is a constant Int in
# 0..255 or a `byte::from_int` call of one (a pure, total conversion of a
# constant: its evaluation has no effect, so skipping it is unobservable).
proc native::lower::ConstantBytesOf {e} {
    variable hir
    if {[hir::kind $hir $e] eq "call"} {
        set node [hir::node $hir $e]
        lassign [dict get $node target] targetKind target
        if {$targetKind eq "native" && [PlainNativeCallee [dict get $node callee]]
                && [dict get [hir::symbol $hir $target] name] eq "str::encode_utf8"
                && [llength [dict get $node args]] == 1} {
            set fact [hir::exact::Of $hir [lindex [dict get $node args] 0]]
            if {[lindex $fact 0] eq "val" && [core::value::kind [lindex $fact 1]] eq "str"} {
                return [list [binary encode hex [encoding convertto utf-8 [core::value::strOf [lindex $fact 1]]]]]
            }
            return ""
        }
    }
    set fact [hir::exact::ListOf $hir $e]
    if {$fact eq ""} {
        return ""
    }
    set codes {}
    foreach src [lrange $fact 2 end] {
        set n ""
        switch -- [lindex $src 0] {
            e { set n [ConstantByteElement [lindex $src 1]] }
            v {
                set v [lindex $src 1]
                set n [expr {[core::value::kind $v] eq "int" ? [core::value::intOf $v] : ""}]
            }
        }
        if {$n eq "" || $n < 0 || $n > 255} {
            return ""
        }
        lappend codes $n
    }
    if {$codes eq ""} {
        return [list ""]
    }
    return [list [binary encode hex [binary format c* $codes]]]
}

# The byte value of List element expression E when it is a constant Int, or a
# call of the library conversion `byte::from_int` of a constant Int (both pure
# and total for a value in 0..255); "" otherwise.
proc native::lower::ConstantByteElement {e} {
    variable hir
    set n [hir::exact::IntOf $hir $e]
    if {$n ne ""} {
        return $n
    }
    if {[hir::kind $hir $e] ne "call"} {
        return ""
    }
    set node [hir::node $hir $e]
    set callee [dict get $node callee]
    if {[hir::kind $hir $callee] ne "ref" || [llength [dict get $node args]] != 1} {
        return ""
    }
    set b [hir::get $hir $callee binding]
    if {$b eq "" || [dict get [hir::binding $hir $b] name] ne "byte::from_int"} {
        return ""
    }
    set n [hir::exact::IntOf $hir [lindex [dict get $node args] 0]]
    return [expr {$n ne "" && $n >= 0 && $n <= 255 ? $n : ""}]
}

# abi::x86_64::from_bytes (core/bytestore.tcl, ABI-BYTES.md): the raw address
# bridge. `from_bytes(DATA)`, DATA an abi::bytes::Bytes (hir/syscall.tcl's
# BytesProblems proved that statically), lowers to
#
#   %b = <the byte storage of DATA>        a virtual field, or structget
#   %a = op bytesaddr %b                   the machine address of its payload
#
# and %a is the one word of the abi::x86_64::Register64 result: handed back
# as that field when the caller wants it virtual (hir/escape.tcl's Classify
# recognizes the call like a syscall's result), built with `structnew` only
# when an object is needed. The lowering records that %a points into %b
# (`fn keepAddr`): SyscallCall then emits `op keepalive %b` after every
# syscall that takes %a (or a register read from it) as an operand, so the
# storage cannot be collected before the kernel has returned. The bridge
# itself knows nothing about write(2) or any other syscall: it produces an
# address, and the syscall lowering owns the lifetime.
proc native::lower::BytesAddrCall {fnVar e node wantVirtual} {
    upvar 1 $fnVar fn
    variable hir
    variable context
    variable structOpt
    set native [dict get [hir::symbol $hir [lindex [dict get $node target] 1]] name]
    set bridgeType [core::bytestore::bridgeType $native]
    set problems [hir::syscall::BytesProblems $hir $e $node]
    if {$problems ne ""} {
        # A -strict 0 program whose call hir/syscall.tcl rejected: replay the
        # problem unconditionally, before anything is evaluated, exactly as
        # SyscallCall does -- no address is taken from a value nothing proved
        # to be an abi::bytes::Bytes.
        lassign [lindex $problems 0] kind message
        dict incr fn skippedGuards [SkippedBlockers [dict get $node args]]
        Emit fn "raise $kind [Quote "$native: $message"]" $e
        return {never tagged}
    }
    set registerType [core::linuxabi::registerType]
    if {![hir::structs::declared $registerType]} {
        throw {NATIVE BUG} "native lowering: $native without a declared $registerType ($e)"
    }
    set layout [hir::structs::names $registerType]
    set storage [StorageOf fn [lindex [dict get $node args] 0] $bridgeType]
    if {$storage eq "never"} {
        return {never tagged}
    }
    dict lappend fn calls [list native $native]
    # The readable bridge's operand is a Bytes storage, the writable one's a
    # MutableBytes storage: two ops (two run-time kind checks), never
    # interchanged. Provenance (keepAddr) is the same for both: the storage
    # must stay live until the syscall has returned; for the writable one the
    # kernel also changes its contents meanwhile, which needs nothing more
    # here because every read of a storage is itself a runtime helper call
    # that Cranelift can neither cache nor reorder across the syscall.
    set bridgeOp [expr {[core::bytestore::bridgeWritable $native] ? "mbytesaddr" : "bytesaddr"}]
    set address [Assign fn "op $bridgeOp $storage" $e]
    dict set fn keepAddr $address [list $storage]
    if {$wantVirtual ne ""} {
        if {$wantVirtual != 1} {
            throw {NATIVE BUG} "native lowering: expected a 1-field Register64 construction at $e"
        }
        return [list [list $address] virtual]
    }
    if {$structOpt && [dict exists $context discarded $e]} {
        return [list [Assign fn unit] tagged]
    }
    set object [Assign fn "structnew [ShapeIndex $registerType $layout] $address" $e]
    return [list $object tagged]
}

# The byte storage (a register) of abi::bytes::Bytes expression ARG, evaluated here,
# or "never": the one field of a Bytes held as virtual fields (a virtual local,
# or a virtual parameter of a `fields` variant), else read out of the object
# with `structget`.
proc native::lower::StorageOf {fnVar arg {structType ""}} {
    upvar 1 $fnVar fn
    variable hir
    if {$structType eq ""} {
        set structType [core::bytestore::bytesType]
    }
    set slot [lsearch -exact [hir::structs::names $structType] [core::bytestore::storageField]]
    if {$slot < 0} {
        throw {NATIVE BUG} "native lowering: $structType has no [core::bytestore::storageField] field"
    }
    if {[hir::kind $hir $arg] eq "ref"} {
        set b [hir::get $hir $arg binding]
        if {$b ne "" && [dict exists $fn locals $b]} {
            set local [dict get $fn locals $b]
            if {[lindex $local 0] eq "virtual" && [lindex $local 2] ne ""} {
                return [lindex [lindex $local 1] $slot]
            }
        }
    }
    set object [Expr fn $arg]
    if {$object eq "never"} {
        return never
    }
    return [Assign fn "structget $slot $object" $arg]
}

# The register of the projection chain ending at project node E when its root
# is held as virtual fields (or is a recognized call result: hir::escape's
# DirectRoots) and the chain crosses at least one opened inner value; "" when
# the ordinary one-level lowering applies (the root is not virtual, or no
# inner value on the way is opened). The chain's inner project nodes are
# never lowered on their own.
proc native::lower::ProjectChain {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable escape
    variable currentInstance
    set nodes [list $e]
    set root [dict get $node receiver]
    while {[hir::kind $hir $root] eq "project"} {
        set nodes [linsert $nodes 0 $root]
        set root [hir::get $hir $root receiver]
    }
    set names [lmap n $nodes {hir::get $hir $n name}]
    set fields ""
    if {[hir::kind $hir $root] eq "ref"} {
        set b [hir::get $hir $root binding]
        if {$b eq "" || ![dict exists $fn locals $b]} {
            return ""
        }
        set local [dict get $fn locals $b]
        if {[lindex $local 0] ne "virtual" || [lindex $local 2] eq "" || [lindex $local 5] eq ""} {
            return ""
        }
        lassign $local - fields shape - - cut
    } else {
        set direct [hir::escape::directRoot $escape $currentInstance $e]
        if {$direct eq ""} {
            return ""
        }
        lassign $direct callRoot desc
        lassign $desc n shape cut
        set fields [VirtualValue fn $callRoot $n $cut]
        if {$fields eq "never"} {
            return never
        }
    }
    set i 0
    foreach name $names {
        set offset [FieldOffset $shape $cut $name]
        set cuts [CutDict $cut]
        if {[dict exists $cuts $name]} {
            lassign [dict get $cuts $name] sub subcut
            if {$i == [llength $names] - 1} {
                throw {NATIVE BUG} "native lowering: opened field \"$name\" read as a whole at $e"
            }
            set fields [lrange $fields $offset [expr {$offset + [hir::escape::CutFields $sub $subcut] - 1}]]
            set shape $sub
            set cut $subcut
            incr i
            continue
        }
        # A closed field: its register holds the inner object; the rest of
        # the chain is ordinary projection from it.
        set r [lindex $fields $offset]
        incr i
        foreach next [lrange $nodes $i end] {
            set recvType [hir::typeOf $hir [hir::get $hir $next receiver]]
            if {$recvType eq "never"} {
                # As in Project: a never-typed receiver is unreachable.
                Emit fn unreachable [hir::get $hir $next receiver]
                return never
            }
            set slot [expr {[hir::types::IsStructLike $recvType] ? [lsearch -exact [hir::types::StructLayout $recvType] [hir::get $hir $next name]] : -1}]
            if {$slot < 0} {
                Unsupported $next struct-shape "the field projection \".[hir::get $hir $next name]\" has a receiver whose slot is not statically known"
            }
            set r [Assign fn "structget $slot $r" $next]
        }
        return $r
    }
    return ""
}

proc native::lower::Const {fnVar e node} {
    upvar 1 $fnVar fn
    set value [dict get $node value]
    switch -- [core::value::kind $value] {
        int  { return [IntConst fn [core::value::intOf $value] $e] }
        str  {
            set r [Assign fn "str [Quote [core::value::strOf $value]]" $e]
            dict set fn strConst $r [core::value::strOf $value]
            return $r
        }
        UnicodeChar { return [Assign fn "char [core::value::charOf $value]" $e] }
        enum { return [EnumConst fn $value $e] }
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
# needing no runtime bounds check at all (unlike a `str::substring` call's
# region, whose bounds native/lower.tcl still validates: see RegionCheck in
# the "String regions" section above). Every other constant is unaffected
# (WANT=region is only ever asked by a caller that already confirmed, via
# RegionEligible, that E is a String constant or a region-producing call).
proc native::lower::ConstOrRegion {fnVar e node want} {
    upvar 1 $fnVar fn
    if {$want in {short ascii} && [core::value::kind [dict get $node value]] eq "str"} {
        # A String literal the planner proved fits the wanted tier: the
        # scalar directly (a packed word for ASCII of at most eight
        # characters, a ShortString1 for at most one), never a String built
        # and then decoded.
        set text [core::value::strOf [dict get $node value]]
        if {![TierFits [ShortTier $e] $want] || ($want eq "short" && [string length $text] > 1)} {
            throw {NATIVE BUG} "native lowering: $want asked for the unproven literal at $e"
        }
        return [list [ScalarLit fn $want $text $e] $want]
    }
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
        shortreg {
            # A String the planner proved small, held as a ShortString1 or
            # packed-ASCII register (a scalar parameter, a virtualized local
            # or an alias of one): a scalar consumer gets it with no
            # conversion (Expr widens ascii -> short when a ShortString1 is
            # wanted), anything else its one cached materialization.
            if {$want in {short ascii}} {
                return [list $where [ScalarKind fn $where]]
            }
            return [list [TaggedOfShort fn $where] tagged]
        }
        fnvalue { return [list [Assign fn "fnvalue $where" $e] tagged] }
        self    { return [list [Assign fn self $e] tagged] }
        virtual {
            # A virtual struct (hir/escape.tcl) referenced where the physical
            # object is needed: its one materialization, at this first such
            # use (MaterializeVirtual). A List aggregate is only ever virtual
            # when *every* use is a constant-index read, so never gets here.
            return [list [MaterializeVirtual fn $b $e] tagged]
        }
        pieces  {
            # A plan local (virtual construction) referenced where a flat
            # value is needed: its one materialization (it is linear, so no
            # path reaches a second reference).
            return [list [PiecesToFlat fn $where [lindex $access 2] $e] tagged]
        }
        plan    {
            # A plan parameter read where a flat value is needed: `construct
            # ... flat` of a flat argument passes it through unchanged.
            return [list [Assign fn "construct [lindex $access 2] flat $where" $e] tagged]
        }
        static {
            # Module-static storage (MODULE-STATIC-RETAINED-VALUES.md): read
            # through the Vm's own static slot table, never through this
            # function's own closure environment -- reachable identically
            # from any function; hir::modulebinding.tcl already proved this
            # binding's initializer runs, exactly once, before any code that
            # could reference it (the same guarantee a root binding has).
            return [list [Assign fn "staticget $where" $e] tagged]
        }
        context {
            # A context parameter used as a whole value (CONTEXTS.md): the
            # physical struct, built from its slot's words.
            return [list [ContextAt fn $e $where {}] tagged]
        }
    }
    throw {NATIVE BUG} "native lowering: bad access $access for $b ($e)"
}

# {reg %r} (a register holding the binding's value), {static N} (module-static slot N), {fnvalue F} or
# {self}: how the current function reaches binding B, emitting a capture
# load if needed.
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
    if {[hir::isModuleBinding $hir $b]} {
        # Reachable from any function alike -- never a capture, whatever
        # function or nesting depth this reference sits in (MODULE-STATIC-
        # RETAINED-VALUES.md). Checked after the fnvalue/self cases above:
        # an envless module *function* binding (every top-level module
        # function, since its only possible external references are now
        # root natives and other module statics, never a real lexical
        # capture) already resolves for free through the ordinary constant-
        # pool fnvalue mechanism above, wherever it is referenced -- this
        # static-slot path is for a module *data* binding's actual retained
        # value (a List/ImmutableSet/scalar/... -- never itself a Block
        # constant), or the rare case BindingAccess does not otherwise
        # resolve.
        return [list static [StaticSlot $b]]
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
    return [list reg $r]
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
    variable construction
    variable hir
    variable context
    variable escape
    variable blockescape
    variable stringregion
    variable currentInstance
    variable rawIntAbiOpt
    variable shortStringOpt
    set valueExpr [dict get $node value]
    set b [dict get $node binding]
    if {[hir::contexts::isLoad $hir $valueExpr] && ![dict get $node duplicate]
            && [dict exists $context discarded $e] && [dict get [hir::binding $hir $b] kind] eq "local"} {
        # A context parameter (CONTEXTS.md): nothing is loaded here. Every use
        # reads exactly the slot words it needs (Project, TryFields) or, if it
        # needs the object, materializes it (Ref).
        set id [hir::contexts::loadId $hir $valueExpr]
        if {$id eq "" || [ContextOffsetSlot $id] eq ""} {
            return [UninstalledContext fn $e $id]
        }
        dict set fn locals $b [list context $id]
        return ""
    }
    if {[hir::kind $hir $valueExpr] eq "block" && $valueExpr in [dict get $context envless]
            && ![dict get $node duplicate] && [dict exists $context discarded $e]
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
            # `list::at` at a constant position, intercepted directly in
            # NativeCall below -- nothing ever reads this local's "value"
            # as a single register.
            set shape [hir::escape::virtualShape $escape $currentInstance $b]
            if {$shape ne "" && [hir::kind $hir $valueExpr] eq "ref"} {
                # A struct alias (`b = a`, STRUCT-SCALAR-REPLACEMENT.md):
                # the same fields, and the same root for materialization, so
                # the physical object -- if some use ever needs one -- is
                # built once for both names.
                set sb [hir::get $hir $valueExpr binding]
                set source [expr {[dict exists $fn locals $sb] ? [dict get $fn locals $sb] : ""}]
                if {[lindex $source 0] ne "virtual" || [lindex $source 2] eq ""} {
                    throw {NATIVE BUG} "native lowering: alias $b of non-virtual binding $sb ($e)"
                }
                dict set fn locals $b [list virtual [lindex $source 1] [lindex $source 2] [lindex $source 3] "" [lindex $source 5]]
                return ""
            }
            set cut [hir::escape::virtualCut $escape $currentInstance $b]
            set fields [VirtualValue fn $valueExpr $virtualArity $cut]
            if {$fields eq "never"} {
                return never
            }
            dict set fn locals $b [list virtual $fields $shape $b "" $cut]
            return ""
        }
        set family [hir::construction::localFamily $construction $currentInstance $b]
        if {$family ne ""} {
            # A plan local (hir::construction; "Virtual construction"
            # below): its value's pieces, every one already evaluated here,
            # in order -- nothing is copied until its single continuation
            # extends or materializes it.
            set pieces [PlanPieces fn $valueExpr $family]
            if {$pieces eq "never"} {
                return never
            }
            dict set fn locals $b [list pieces $pieces $family]
            return ""
        }
        if {[hir::stringregion::virtual $stringregion $currentInstance $b]} {
            # A region-producing value (hir/stringregion.tcl) every
            # reference to which is already known to be a supported
            # consumer (`==`/`str::length`): its fields, not a materialized
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
    # A local String the planner proved small (SHORT-STRING.md): kept as a
    # packed-ASCII register (ASCII, at most eight characters) or a
    # ShortString1 register (at most one character) for its whole scope.
    # Every reference reads it as a scalar (no conversion) or materializes it
    # once at the first consumer that needs a real String (Ref). An alias
    # `y = x` of such a local is the same register (Expr of the ref asks for
    # the tier and gets x's register back). Only in statement position (the
    # bind's own value is not read) and for a plain local; a module binding
    # is written to a tagged static slot and stays tagged.
    if {$shortStringOpt && [dict exists $context discarded $e]
            && ![dict get $node duplicate] && [dict get [hir::binding $hir $b] kind] eq "local"
            && ![hir::isModuleBinding $hir $b] && [hir::kind $hir $valueExpr] ne "block"
            && [ShortOk $valueExpr] && [native::shortstr::localVirtual $currentInstance $e]} {
        set tier [ShortTier $valueExpr]
        set value [Expr fn $valueExpr $tier]
        if {$value eq "never"} {
            return never
        }
        dict set fn locals $b [list shortreg $value]
        Tally fn ${tier}Locals
        return ""
    }
    # A local alias of a raw register (`y = x` where x is a raw parameter or
    # a raw alias itself): the new name is the same raw register, so passing
    # `y` on needs no rbox/runbox merely because of the lexical rebinding
    # (RAW-INT-ABI.md). Only in statement position (the bind's own value is
    # not read) and for a plain local.
    if {$rawIntAbiOpt && [hir::kind $hir $valueExpr] eq "ref" && [dict exists $context discarded $e]
            && ![dict get $node duplicate] && [dict get [hir::binding $hir $b] kind] eq "local"
            && ![hir::isModuleBinding $hir $b]} {
        set sb [hir::get $hir $valueExpr binding]
        if {$sb ne "" && [dict exists $fn locals $sb] && [lindex [dict get $fn locals $sb] 0] eq "rawreg"} {
            dict set fn locals $b [dict get $fn locals $sb]
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
    dict set fn locals $b [list reg $value]
    if {[hir::isModuleBinding $hir $b]} {
        # Module initialization (MODULE-STATIC-RETAINED-VALUES.md): written
        # once, here, at the exact point this binding's own initializer
        # finishes evaluating -- exactly where module initialization already
        # happens (this `bind` is always part of the program function's own
        # body, in source/dependency order, whatever this program's own
        # `hir::modules`; MODULE-BINDINGS.md's initialization-order
        # guarantee is unchanged). Every other function reads it back
        # through Access's own `static` case, never through a capture. A
        # module *function* binding taking the "bound in statement
        # position" fast path above returns before reaching here and needs
        # no slot at all: every reference to an envless function resolves
        # through the constant-pool fnvalue mechanism instead (Access's own
        # fnvalue/self cases, checked first).
        Emit fn "staticset [StaticSlot $b] $value" $e
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
            reg        { lappend values $where }
            rawreg     { lappend values [TaggedOf fn $where] }
            shortreg   { lappend values [TaggedOfShort fn $where] }
            fnvalue    { lappend values [Assign fn "fnvalue $where"] }
            self       { lappend values [Assign fn self] }
            context    { lappend values [ContextAt fn "" $where {}] }
            default {
                throw {NATIVE BUG} "native lowering: binding $b ($how) cannot be captured"
            }
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
proc native::lower::VirtualValue {fnVar e arity {cut ""}} {
    upvar 1 $fnVar fn
    variable hir
    set node [hir::node $hir $e]
    if {[dict get $node kind] eq "struct"} {
        # A struct literal: its field registers in slot order, the object
        # never built. CUT names the fields hir/escape.tcl opened (an inner
        # literal contributes its own fields in place of one field value).
        set fields [StructFields fn $e $node $cut]
        if {$fields ne "never" && [llength $fields] != $arity} {
            throw {NATIVE BUG} "native lowering: expected a $arity-field struct construction at $e"
        }
        if {$fields ne "never" && [hir::typeOf $hir $e] eq "never"} {
            Emit fn unreachable $e
            return [Never fn $e]
        }
        if {$fields eq "never"} {
            return [Never fn $e]
        }
        return $fields
    }
    if {[dict get $node kind] eq "if"} {
        # Branch merging: the branches' fields join field-wise.
        set fields [If fn $e $node "" $arity $cut]
        if {$fields eq "never"} {
            return [Never fn $e]
        }
        return $fields
    }
    if {[dict get $node kind] ne "call"} {
        throw {NATIVE BUG} "native lowering: expected a recognized construction at $e"
    }
    lassign [Call fn $e $node tagged $arity] result repr
    if {$result eq "never"} {
        return [Never fn $e]
    }
    if {$repr ne "virtual"} {
        throw {NATIVE BUG} "native lowering: expected virtual fields at $e"
    }
    if {[hir::typeOf $hir $e] eq "never"} {
        # HIR proved that no normal completion reaches past E (Expr's own
        # tail does this same check for every other expression kind).
        Emit fn unreachable $e
        return [Never fn $e]
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

# Like FieldWidths: one entry per parameter, the cut hir/escape.tcl opened in
# that parameter's transported layout ("" if none or not virtual).
proc native::lower::FieldCuts {target params} {
    variable escape
    if {![ParamFieldsUsable $target]} {
        return {}
    }
    return [lmap p $params {hir::escape::paramVirtualCut $escape $target $p}]
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
proc native::lower::CanSupplyFields {fnVar argExprs fieldWidths {fieldCuts {}}} {
    upvar 1 $fnVar fn
    variable hir
    set i 0
    foreach arg $argExprs {
        set width [expr {$i < [llength $fieldWidths] ? [lindex $fieldWidths $i] : ""}]
        set cut [expr {$i < [llength $fieldCuts] ? [lindex $fieldCuts $i] : ""}]
        if {$width ne ""} {
            switch -- [hir::kind $hir $arg] {
                call {}
                if {}
                struct {
                    set shape [StructShapeOf [hir::node $hir $arg]]
                    if {[hir::escape::CutFields $shape $cut] != $width} {
                        return 0
                    }
                }
                ref - project {
                    set path [ContextPath fn $arg]
                    if {$path ne ""} {
                        # A context value (CONTEXTS.md): its fields are its
                        # slot's words, under any cut.
                        if {[ContextFieldCount {*}$path $cut] != $width} {
                            return 0
                        }
                    } elseif {[hir::kind $hir $arg] eq "project"} {
                        return 0
                    } else {
                        set b [hir::get $hir $arg binding]
                        if {$b eq "" || ![dict exists $fn locals $b]
                                || [lindex [dict get $fn locals $b] 0] ne "virtual"
                                || [llength [lindex [dict get $fn locals $b] 1]] != $width} {
                            return 0
                        }
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
# here for free, exactly like the existing list::at(ref, constant)
# interception reads one field), or a `call` node itself recognized this
# same way (a `[e0..en-1]` literal, or a forwarding call to another
# companion-eligible instance) -- reusing Call's own existing WANTVIRTUAL
# machinery (VirtualValue's own mechanism) rather than duplicating it.
# "never" if evaluating a construction's own parts cannot complete
# normally. hir::escape.tcl only ever proves a call site eligible this way
# when one of these two shapes is what is actually there, so CallArgs
# treats "" here as a lowering/analysis inconsistency (NATIVE BUG), never a
# legitimate fallback to build.
proc native::lower::TryFields {fnVar e n {cut ""}} {
    upvar 1 $fnVar fn
    variable hir
    set path [ContextPath fn $e]
    if {$path ne ""} {
        # A context value (CONTEXTS.md): its slot's words, as the callee's
        # cut opens them; nothing is materialized but a closed inner struct.
        if {[ContextFieldCount {*}$path $cut] != $n} {
            return ""
        }
        return [ContextFields fn $e {*}$path $cut]
    }
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
        struct - if {
            return [VirtualValue fn $e $n $cut]
        }
        call {
            set node [hir::node $hir $e]
            lassign [Call fn $e $node tagged $n] result repr
            if {$result eq "never"} {
                return [Never fn $e]
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
# field form (TryFields) instead of one ordinary register; RAWSLOTS (a
# self-tail call's slot kinds, or the callee's RawInt/ShortString ABI
# positions: the canonical function's in Call, an internal variant's in
# FlattenedVirtualCall; empty otherwise) says which of the *remaining*,
# non-virtualized positions want Expr's `raw` (or scalar String) form
# instead of `tagged`. "never" if any argument cannot complete normally.
proc native::lower::CallArgs {fnVar argExprs fieldWidths rawSlots {planSlots {}} {fieldCuts {}}} {
    upvar 1 $fnVar fn
    variable hir
    set regs {}
    set i 0
    foreach arg $argExprs {
        set width [expr {$i < [llength $fieldWidths] ? [lindex $fieldWidths $i] : ""}]
        set family [expr {$i < [llength $planSlots] ? [lindex $planSlots $i] : ""}]
        if {$family ne ""} {
            # A plan parameter of the target (virtual construction): the
            # argument's construction is handed over as a plan, not
            # materialized at the call boundary.
            set pieces [PlanPieces fn $arg $family]
            if {$pieces eq "never"} {
                return never
            }
            lappend regs [PiecesToPlan fn $pieces $family $arg]
        } elseif {$width ne ""} {
            set fields [TryFields fn $arg $width [expr {$i < [llength $fieldCuts] ? [lindex $fieldCuts $i] : ""}]]
            if {$fields eq "never"} {
                return never
            }
            if {$fields eq ""} {
                throw {NATIVE BUG} "native lowering: expected $width virtual fields at $arg"
            }
            lappend regs {*}$fields
        } else {
            # A slot is 0 (tagged), 1 (raw Int), `short` (ShortString1) or
            # `ascii` (packed ASCII).
            set slot [expr {$i < [llength $rawSlots] ? [lindex $rawSlots $i] : 0}]
            set argWant [expr {$slot in {short ascii} ? $slot : $slot ? "raw" : "tagged"}]
            if {$argWant eq "raw" && [RawConstArg $arg]} {
                # A small Int literal handed to a raw parameter is a raw
                # constant: no tagged constant built only to be unboxed.
                set r [AssignRaw fn "rawint [core::value::intOf [dict get [hir::node $hir $arg] value]]" $arg]
                lappend regs $r
                incr i
                continue
            }
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

# 1 if argument expression E is an Int literal that fits the small-Int
# domain (so a raw machine constant is exactly its value).
proc native::lower::RawConstArg {e} {
    variable hir
    variable reprOpt
    variable rawIntAbiOpt
    if {!$reprOpt || !$rawIntAbiOpt || [hir::kind $hir $e] ne "const"} {
        return 0
    }
    set value [hir::get $hir $e value]
    return [expr {[core::value::kind $value] eq "int"
        && [hir::range::fitsSmall [hir::range::point [core::value::intOf $value]]]}]
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
proc native::lower::FlattenedVirtualCall {fnVar e node target targetInstance captureBindings {want tagged}} {
    upvar 1 $fnVar fn
    variable hir
    variable selfTail
    variable currentInstance
    variable construction
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
        set rawSlots [lmap p $params {SlotKind fn $p}]
    } elseif {[llength $params] == [llength $argExprs]} {
        # Raw Int ABI of the callee's internal variant (loss point 5): the
        # plan's raw positions are passed raw (InternalAbiParams, the same
        # list InternalFunction declares). A self tail call's slots above
        # already follow the same declaration (its parameters' locals).
        set rawSlots [InternalAbiParams $targetInstance [llength $argExprs]]
    }
    set argRegs [CallArgs fn $argExprs {} $rawSlots [PlanSlots $targetInstance [llength $argExprs]]]
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
    set text [string trimright "call $id [join [concat $argRegs $captureRegs] { }]"]
    if {[InternalAbiResult $targetInstance]} {
        return [RawCallResult fn $e [AssignRaw fn $text $e] $want]
    }
    set result [Assign fn $text $e]
    set resultFamily [hir::construction::resultFamily $construction $targetInstance]
    if {$resultFamily ne ""} {
        return [PlanCallResult fn $e $result $resultFamily $want]
    }
    return [list $result tagged]
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
        set rawSlots [lmap p $params {SlotKind fn $p}]
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

# Preserve the exact call and its completion handling, then substitute a
# successful-result constant for later value uses when the per-instance range
# analysis proves one. This is not an effect or totality optimization.
# {RESULT REPR} of a call whose callee returns a raw Int (RAW-INT-ABI.md):
# RESULT is the raw register. A raw consumer takes it as is; a tagged one
# gets the one non-allocating `rbox` (the callee's Range fits the small-Int
# domain), which TaggedOf caches so later raw uses of that tagged value
# unbox for free. Where the call facts prove the successful result is one
# constant, the tagged constant is returned exactly as ClosedResult does for
# a tagged call (the call itself still ran, for its effects).
proc native::lower::RawCallResult {fnVar e result want} {
    upvar 1 $fnVar fn
    set constant [ClosedResult fn $e ""]
    lassign $constant value repr
    if {$value ne ""} {
        return $constant
    }
    if {$want eq "raw"} {
        return [list $result raw]
    }
    return [list [TaggedOf fn $result] tagged]
}

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

# Every call lowering goes through here, so the raw-address provenance of
# ABI-BYTES.md is tracked across calls to ordinary Botlish functions in the
# calling function (see KeepAddrFlow): CallInner lowers the call, then
#   * a call that returns an abi::x86_64::Register64 and takes an abi::bytes::Bytes (or
#     an address-carrying register) may be returning an address into it: its
#     result registers carry the provenance of the call's operands -- the Bytes
#     (or its storage) itself, whichever register passes it;
#   * a call that takes an address-carrying operand may use it for a syscall
#     inside the callee: the storages stay live until the call has returned (a
#     keepalive after it).
# Calls with neither (every call of a program that never takes an address) pay
# one dict-exists test.
proc native::lower::Call {fnVar e node want {wantVirtual ""} {wantRegion 0}} {
    upvar 1 $fnVar fn
    variable hir
    # A declared error this call propagates out of the scope of affine
    # owners, or past pending temporaries, releases them on its way
    # (hir::affine::releasesOnError): the call's failures land on a pad that
    # does, then go on (Handle's technique, with no handler).
    set byName [hir::affine::releasesOnError $hir $e]
    if {$byName ne ""} {
        set pad [NewLabel fn]
        Emit fn "pusherrorexit $pad" $e
    }
    set result [CallInner fn $e $node $want $wantVirtual $wantRegion]
    if {[lindex [dict get $node target] 0] eq "block" && [BytesFlowCandidate fn $e $node]} {
        AddressFlowAcrossCall fn $e $node $result
    }
    if {$byName ne ""} {
        Emit fn "poperrorexit" $e
        set normal [expr {[lindex $result 0] ne "never"}]
        if {$normal} {
            set join [NewLabel fn]
            Emit fn "jump $join" $e
        }
        EmitLabel fn $pad
        ReleaseOnError fn $e $byName
        Emit fn "reraise" $e
        if {$normal} {
            EmitLabel fn $join
        }
    }
    return $result
}

# The static types of the values an address can be taken from: abi::bytes::Bytes
# (readable) and abi::bytes::MutableBytes (writable).
proc native::lower::BytesStructTypes {} {
    return [list [list nstruct [core::bytestore::bytesType]] [list nstruct [core::bytestore::mutableBytesType]]]
}

# 1 if call E (NODE) may carry an address: the program declares abi::bytes::Bytes and
# either the call takes an abi::bytes::Bytes or abi::bytes::MutableBytes or its operands
# carry a raw address.
proc native::lower::BytesFlowCandidate {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    if {![hir::structs::declared [core::bytestore::bytesType]]} {
        return 0
    }
    if {[dict exists $fn keepAddr]} {
        return 1
    }
    foreach arg [dict get $node args] {
        if {[hir::typeOf $hir $arg] in [BytesStructTypes]} {
            return 1
        }
    }
    return 0
}

proc native::lower::AddressFlowAcrossCall {fnVar e node result} {
    upvar 1 $fnVar fn
    variable hir
    if {[lindex $result 0] eq "never"} {
        return
    }
    set lines [dict get $fn lines]
    set callLine ""
    set count [llength $lines]
    for {set i [expr {$count - 1}]} {$i >= 0 && $i >= $count - 16} {incr i -1} {
        set line [lindex $lines $i]
        if {[string match "* @$e" $line] && [regexp {= (?:call|callenv|callmulti|callenvmulti) \S+ } $line]} {
            set callLine $line
            break
        }
    }
    if {$callLine eq ""} {
        return
    }
    regexp {= (call|callenv|callmulti|callenvmulti) \S+ ?(.*) @[^ ]+$} $callLine -> kind rest
    set operands [split [string trim $rest] " "]
    if {$kind in {callenv callenvmulti}} {
        set operands [lrange $operands 1 end]
    }
    set tagged {}
    set carried {}
    foreach operand $operands {
        if {$operand eq "" || [dict exists $fn rawRegs $operand]} continue
        if {[dict exists $fn keepAddr $operand]} {
            foreach storage [dict get $fn keepAddr $operand] {
                if {$storage ni $carried} {
                    lappend carried $storage
                }
            }
        }
    }
    # The values this call may return an address into: every non-raw operand
    # of a Register64-returning call (a Bytes, its storage, or an address
    # that already carries provenance), plus what the operands carry.
    set source $carried
    if {[hir::typeOf $hir $e] eq [list nstruct [core::linuxabi::registerType]]} {
        # Which operands are the Bytes: by position when every argument is one
        # operand (each Bytes argument, as its storage or its object), else (a
        # parameter passed as several field registers) every non-raw operand.
        set argExprs [dict get $node args]
        set picked {}
        if {[llength $argExprs] == [llength $operands]} {
            foreach arg $argExprs operand $operands {
                if {[hir::typeOf $hir $arg] in [BytesStructTypes]} {
                    lappend picked $operand
                }
            }
        } else {
            set picked $operands
        }
        foreach operand $picked {
            if {$operand ne "" && ![dict exists $fn rawRegs $operand] && $operand ni $source} {
                lappend source $operand
            }
        }
        set registers [expr {[lindex $result 1] eq "virtual" ? [lindex $result 0] : [list [lindex $result 0]]}]
        foreach register $registers {
            if {$register ne "" && $source ne ""} {
                dict set fn keepAddr $register $source
            }
        }
    }
    # A callee may consume a carried address (a syscall inside it): keep what
    # the operands carry alive until it has returned.
    foreach storage $carried {
        Assign fn "op keepalive $storage" $e
    }
}

proc native::lower::CallInner {fnVar e node want {wantVirtual ""} {wantRegion 0}} {
    upvar 1 $fnVar fn
    variable hir
    variable selfTail
    variable envless
    variable natives
    variable escape
    variable blockescape
    variable currentInstance
    variable stringregion
    variable traversal
    variable stringRegionOpt
    variable tinyLeafInlineOpt
    variable construction
    variable constructionOpt
    lassign [dict get $node target] targetKind target
    set calleeExpr [dict get $node callee]
    set argExprs [dict get $node args]

    if {$targetKind eq "native" && [dict get [hir::symbol $hir $target] name] eq "linux::abi::syscall"} {
        # The raw Linux x86-64 kernel transition (core/linuxabi.tcl): its own
        # form, never NativeCall's one-operand-per-argument shape.
        return [SyscallCall fn $e $node $wantVirtual]
    }
    if {$targetKind eq "native" && [dict get [hir::symbol $hir $target] name] eq [core::contexts::installNative]} {
        # `with context EXPR` (CONTEXTS.md): stores into the type's fixed slot.
        return [ContextInstallCall fn $e $node]
    }
    if {$targetKind eq "native" && [dict get [hir::symbol $hir $target] name] eq [core::contexts::unreachableNative]} {
        # Code no installed context reaches (CONTEXT-TRAITS.md): HIR
        # verification proved it never runs, so there is nothing to call.
        Emit fn unreachable $e
        return {never tagged}
    }
    if {$targetKind eq "native" && [dict get [hir::symbol $hir $target] name] eq [core::contexts::loadNative]} {
        # A context load outside a context parameter's own binding (Bind
        # keeps those lazy): the whole installed value, from its slot.
        set id [hir::contexts::loadId $hir $e]
        if {$id eq "" || [ContextOffsetSlot $id] eq ""} {
            return [list [UninstalledContext fn $e $id] tagged]
        }
        return [list [ContextAt fn $e $id {}] tagged]
    }
    if {$targetKind eq "block" && ($wantVirtual ne "" || !$wantRegion)} {
        # `abi::bytes::from_list(BYTES)` whose every byte is known now (StaticBytesCall):
        # a static byte storage instead of a call and a run-time conversion.
        set static [StaticBytesCall fn $e $node $wantVirtual]
        if {$static ne ""} {
            return $static
        }
    }
    if {$targetKind eq "native" && [core::bytestore::isBridge [dict get [hir::symbol $hir $target] name]]} {
        # The raw address bridge (core/bytestore.tcl, ABI-BYTES.md): reads the
        # storage out of an abi::bytes::Bytes and yields a Register64, so its own
        # form too.
        return [BytesAddrCall fn $e $node $wantVirtual]
    }

    if {$constructionOpt && $wantVirtual eq "" && !$wantRegion && $targetKind eq "native"
            && [dict get $node known] eq "" && [PlainNativeCallee $calleeExpr]} {
        # A `str::concat`/`list::append` (virtual construction; see that section
        # below) whose own value is wanted flat here: its operands' pieces
        # (a nested construction, a plan local/parameter/result) are
        # gathered first and copied once, by the eager op itself when
        # nothing was virtual (PiecesToFlat).
        set name [dict get [hir::symbol $hir $target] name]
        set family [ConstructNative $e $name $argExprs]
        if {$family ne ""} {
            set pieces [ConstructPieces fn $e $node $name $family]
            if {$pieces eq "never"} {
                return {never tagged}
            }
            return [list [PiecesToFlat fn $pieces $family $e] tagged]
        }
    }

    if {$wantVirtual eq "" && $targetKind eq "block"
            && [hir::kind $hir $calleeExpr] eq "ref"} {
        set calleeBinding [hir::get $hir $calleeExpr binding]
        set flattenedTarget [expr {$calleeBinding ne "" ? [hir::blockescape::virtual $blockescape $currentInstance $calleeBinding] : ""}]
        if {$flattenedTarget ne ""} {
            # A de-closure-converted binding may have several used instances
            # (one per exact callable target it is called with, for one):
            # blockescape's proof is that every reference is a call to one
            # of them, so THIS call site's own instance -- the one
            # hir::specialize chose for it -- is the callee.
            set flattenedTarget [expr {[dict exists $fn targets $e] ? [dict get $fn targets $e] : ""}]
            if {$flattenedTarget eq "" || ![hir::blockescape::wants $blockescape $flattenedTarget]} {
                throw {NATIVE BUG} "native lowering: call $e of a de-closure-converted binding has no wanted callee instance"
            }
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
            return [FlattenedVirtualCall fn $e $node $target $flattenedTarget $captureBindings $want]
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
            && [dict get [hir::symbol $hir $target] name] eq "str::substring" && [llength $argExprs] == 3} {
        # `str::substring(text, a, b)` asked for directly in region form (Bind, a
        # region companion's exit, or an inline `==`/`str::length` operand):
        # RegionEligible already confirmed E has exactly this shape. The
        # three operands *are* the region -- text/a/b, evaluated exactly as
        # an ordinary `str::substring` call would, with the same argument guards
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
        set meta [core::native::metadata str::substring]
        EmitArgGuards fn $e $argExprs [list $base $start $end] [dict get $meta paramTypes] str::substring
        dict lappend fn calls [list native str::substring]
        if {![BoundsProven $e]} {
            Assign fn "op regioncheck $base $start $end" $e
        }
        return [list [list $base $start $end] region]
    }

    if {$wantVirtual eq "" && $targetKind eq "native" && [llength $argExprs] == 2
            && [dict get [hir::symbol $hir $target] name] eq "list::at"
            && [hir::kind $hir [lindex $argExprs 0]] eq "ref"} {
        # A `list::at(ref, constant)` read of a binding *currently* lowered
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
        # (char_at(i))`, lib/web.bot's emailish?): if the
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

    if {$wantVirtual eq "" && !$wantRegion && $targetKind eq "native" && [dict get $node known] eq ""} {
        # ShortString1 (SHORT-STRING.md): the String natives a proven-short
        # operand can feed directly -- `str::length`, `==` -- and `str::substring`
        # when its result is asked for as a short value. Only through a root
        # native reference (no callee code to run), like the String-region
        # forms just above.
        set short [TryShortStringOp fn $e $node $want]
        if {$short ne ""} {
            return $short
        }
    }

    # The callee is evaluated first. A reference to a root native or to an
    # environment-free function needs no code.
    set callee ""
    set skipCallee [expr {[hir::kind $hir $calleeExpr] eq "ref"
        && (($targetKind eq "native" && [dict get [hir::binding $hir [hir::get $hir $calleeExpr binding]] kind] eq "root")
            || ($targetKind eq "block" && $target in $envless))}]
    if {!$skipCallee} {
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
        set fieldCuts [expr {$fieldWidths eq "" ? {} : [FieldCuts $instance $params]}]
        if {$fieldWidths ne "" && ![CanSupplyFields fn $argExprs $fieldWidths $fieldCuts]} {
            set fieldWidths {}
            set fieldCuts {}
        }
        set rawSlots {}
        if {$self} {
            set rawSlots [lmap p $params {SlotKind fn $p}]
        }
        # Plan parameters of the target (virtual construction): never for a
        # region-result call or a tiny leaf this call will inline (both
        # bind the callee's parameters to ordinary flat registers).
        set leafInline [expr {!$self && $wantVirtual eq "" && !$wantRegion && $tinyLeafInlineOpt
            && $fieldWidths eq "" && $instance ne "" && [LeafInlineEligible $instance]}]
        # Raw Int ABI: a call of the target's *canonical* function (no
        # companion, region or fields variant, no inlining) passes each
        # planned raw position as a raw machine integer. The callee's plan
        # is authoritative (native/rawabi.tcl); a self tail call needs no
        # such lookup, its slots follow the function's own raw parameters
        # above (which the same plan made raw).
        set abiCall [expr {!$self && $instance ne "" && $wantVirtual eq "" && !$wantRegion
            && $fieldWidths eq "" && !$leafInline && [llength $params] == [llength $argExprs]
            && [dict get $node known] eq ""}]
        if {$abiCall} {
            set rawSlots [AbiParams $instance [llength $argExprs]]
            # ShortString1 positions (shortstring.tcl): the callee's plan is
            # authoritative for them too; a position is never both.
            set rawSlots [lmap r $rawSlots s [ShortAbiParams $instance [llength $argExprs]] {
                expr {$s ne "" ? $s : $r}
            }]
        }
        set planSlots {}
        if {$instance ne "" && !$wantRegion && !$leafInline} {
            set planSlots [PlanSlots $instance [llength $argExprs]]
        }
        set argRegs [CallArgs fn $argExprs $fieldWidths $rawSlots $planSlots $fieldCuts]
        if {$argRegs eq "never"} {
            return {never tagged}
        }
        if {[llength $params] != [llength $argExprs]} {
            set pnames [lmap b $params {dict get [hir::binding $hir $b] name}]
            Emit fn "raise ARITY [Quote "block ([join $pnames { }]) expects [llength $params] argument(s), got [llength $argExprs]"]" $e
            return {never tagged}
        }
        if {[dict get $node known] ne ""} {
            # A repeated proof-predicate invocation HIR already decided (an
            # exact predicate-result fact of a repeatable function,
            # REFINEMENT-VALUES.md; hir/types.tcl's Call): the arguments
            # were just evaluated above for effect, but the call itself
            # needs no code at all, exactly like NativeCall's own identical
            # fold for a decided type test (see there).
            return [list [Assign fn "bool [expr {[dict get $node known] ? "true" : "false"}]" $e] tagged]
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
        set rawResult [expr {$abiCall && [AbiResult $instance]}]
        set shortResult [expr {$abiCall ? [ShortAbiResult $instance] : ""}]
        set text [string trimright [expr {$target in $envless ? "call $id [join $argRegs { }]" : "callenv $id $callee [join $argRegs { }]"}]]
        if {$rawResult} {
            set result [AssignRaw fn $text $e]
            return [RawCallResult fn $e $result $want]
        }
        if {$shortResult ne ""} {
            set result [AssignScalar fn $shortResult $text $e]
            # The callee returns a ShortString1 / packed ASCII value: a
            # scalar consumer takes it as is (Expr widens ascii -> short when
            # a ShortString1 is wanted), anything else materializes the
            # String once, here.
            if {$want in {short ascii}} {
                return [list $result $shortResult]
            }
            return [list [TaggedOfShort fn $result] tagged]
        }
        set result [Assign fn $text $e]
        set resultFamily [hir::construction::resultFamily $construction $instance]
        if {$resultFamily ne ""} {
            return [PlanCallResult fn $e $result $resultFamily $want]
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

# Short-String consumers and producers of the String natives (native call E,
# node NODE), or "" when this call is not one of them (the ordinary lowering
# then runs unchanged):
#
#   str::length(s)      s ascii  =>  `asciilen` ((71 - clz) >> 3), s short =>
#                  `shortlen` (Empty 0, One 1): a raw Int
#   s == t         both ascii  =>  `asciieq` (word equality; the packed form
#                  is canonical); both short  =>  `shorteq` (scalar equality;
#                  Empty == Empty, One(a) == One(a), nothing else); one ascii
#                  and one short  =>  `asciishorteq` (a literal ascii side of at
#                  most one character is first turned into a `shortlit`, so
#                  the common `c == "a"` is a `shorteq` against a constant).
#                  If either operand is not scalar-natural (it would need a
#                  fresh String produced and decoded), the ordinary path --
#                  including the String-region forms -- is untouched, and a
#                  scalar operand against an unrestricted String simply
#                  materializes (a recorded frontier, not a redesign of
#                  String equality).
#   str::substring(t, a, b)  asked short, with the planner's width proof
#                  (b - a <= 1)  =>  the same `regioncheck` an ordinary call
#                  would run (so the RANGE error is byte-identical), then an
#                  infallible `strsliceshort`: no String allocated, and the
#                  Empty encoding never doubles as a failure.
proc native::lower::TryShortStringOp {fnVar e node want} {
    upvar 1 $fnVar fn
    variable hir
    variable shortStringOpt
    if {!$shortStringOpt} {
        return ""
    }
    set calleeExpr [dict get $node callee]
    if {[hir::kind $hir $calleeExpr] ne "ref"
            || [dict get [hir::binding $hir [hir::get $hir $calleeExpr binding]] kind] ne "root"} {
        return ""
    }
    lassign [NativeCallOp $e $node] name op
    set argExprs [dict get $node args]
    if {$name eq "str::length" && $op eq "strlen" && [llength $argExprs] == 1} {
        set a [lindex $argExprs 0]
        if {![ShortNatural fn $a]} {
            return ""
        }
        set tier [ShortTier $a]
        set r [Expr fn $a $tier]
        if {$r eq "never"} {
            return {never tagged}
        }
        dict lappend fn calls [list native $name]
        set n [AssignRaw fn "op ${tier}len $r" $e]
        Tally fn ${tier}Len
        if {$want eq "raw"} {
            return [list $n raw]
        }
        return [list [TaggedOf fn $n] tagged]
    }
    if {$name eq "==" && $op eq "streq" && [llength $argExprs] == 2} {
        lassign $argExprs a b
        if {![ShortNatural fn $a] || ![ShortNatural fn $b]} {
            return ""
        }
        set ta [ShortTier $a]
        set tb [ShortTier $b]
        set ra [Expr fn $a $ta]
        if {$ra eq "never"} {
            return {never tagged}
        }
        set rb [Expr fn $b $tb]
        if {$rb eq "never"} {
            return {never tagged}
        }
        dict lappend fn calls [list native $name]
        if {$ta eq $tb} {
            Tally fn ${ta}Eq
            return [list [Assign fn "op ${ta}eq $ra $rb" $e] tagged]
        }
        # One side packed ASCII, the other a ShortString1.
        if {$ta eq "short"} {
            lassign [list $ra $rb] rs raw
        } else {
            lassign [list $rb $ra] rs raw
        }
        if {[dict exists $fn scalarConst $raw] && [string length [dict get $fn scalarConst $raw]] <= 1} {
            # A literal of at most one character: compare as ShortString1.
            set rawShort [ShortOfAscii fn $raw]
            Tally fn shortEq
            return [list [Assign fn "op shorteq $rs $rawShort" $e] tagged]
        }
        Tally fn asciiShortEq
        return [list [Assign fn "op asciishorteq $raw $rs" $e] tagged]
    }
    if {$want eq "short" && $name eq "str::substring" && [llength $argExprs] == 3 && [ShortOk $e]} {
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
        set meta [core::native::metadata str::substring]
        EmitArgGuards fn $e $argExprs [list $base $start $end] [dict get $meta paramTypes] str::substring
        dict lappend fn calls [list native str::substring]
        if {![BoundsProven $e]} {
            Assign fn "op regioncheck $base $start $end" $e
        }
        Tally fn shortSlices
        return [list [AssignShort fn "op strsliceshort $base $start $end" $e] short]
    }
    return ""
}

# 1 if String expression E can be consumed as a scalar without producing a
# real String first just to decode it: a proven-small expression that is a
# literal, a reference (a scalar register, or an already materialized String
# whose ShortString1 scalar is one cached load away -- a materialized String
# is *not* natural for packed ASCII, whose extraction is a helper call), a
# `str::substring` the producer above turns into a slice, or an exact call whose
# canonical function returns a scalar. A call of a tagged-result function is
# not natural: its String is allocated either way, and the ordinary paths
# (String regions, plain `streq`) already handle it.
proc native::lower::ShortNatural {fnVar e} {
    upvar 1 $fnVar fn
    variable hir
    variable stringRegionOpt
    set tier [ShortTier $e]
    if {$tier eq ""} {
        return 0
    }
    switch -- [hir::kind $hir $e] {
        const { return 1 }
        ref {
            set b [hir::get $hir $e binding]
            if {$b eq "" || [dict get [hir::binding $hir $b] kind] eq "root"} {
                return 0
            }
            if {[dict exists $fn locals $b]} {
                switch -- [lindex [dict get $fn locals $b] 0] {
                    shortreg { return 1 }
                    reg { return [expr {$tier eq "short"}] }
                }
                return 0
            }
            return [expr {$tier eq "short"}]
        }
        call {
            # A call the String-region analysis already keeps allocation-free
            # (a direct `str::substring`, a region-producing instance): that
            # existing virtualization wins, the scalar tiers do not compete
            # with it.
            if {$stringRegionOpt && [RegionEligible $e]} {
                return 0
            }
            set node [hir::node $hir $e]
            lassign [dict get $node target] kind target
            if {$kind eq "native"} {
                return [expr {$tier eq "short" && [dict get [hir::symbol $hir $target] name] eq "str::substring"
                    && [llength [dict get $node args]] == 3}]
            }
            if {$kind eq "block" && [dict exists $fn targets $e]} {
                set instance [dict get $fn targets $e]
                return [expr {[ShortAbiResult $instance] ne "" && [dict get $node known] eq ""
                    && [llength [dict get $node args]] == [llength [hir::get $hir $target params]]}]
            }
        }
    }
    return 0
}

# Lowers E, one of PLAN's recognized accesses (native/lower.tcl's "String
# traversal" section, hir/traversal.tcl's TraversalPlan), inline: reads E's
# own text/index argument expressions (ordinary `Expr fn ... tagged`
# lowering -- a raw-declared index parameter is transparently reboxed by the
# existing TaggedOf machinery, exactly as any other tagged consumer already
# is), then decodes directly at the function's current carried byte
# position instead of calling E's own callee. Matches the access's own
# (peek-shaped) semantics exactly: `if index >= str::length(text): ""` else the
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

# 1 if expression E (an operand of a native `==`/`str::length` call TryStringRegionOp
# is deciding) can produce a StringRegion directly (`Expr fn E region`),
# with no runtime kind guard needed first: a direct `str::substring` call, a
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
# path), else {RESULT REPR} (always "tagged": the *result* of `==`/`str::length`
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
#           `str::length` call -- needs no guard already proven unnecessary: a
#           plain `isub end start`, exact by construction (Botlish
#           substring bounds are character indices already, so a region's
#           character count is always end-start).
#
# Only ever tried when -string-region-opt is enabled.
proc native::lower::TryStringRegionOp {fnVar e name op argExprs} {
    upvar 1 $fnVar fn
    variable hir
    variable guards
    variable knownErrors
    variable stringRegionOpt
    if {!$stringRegionOpt} {
        return ""
    }
    if {$name eq "==" && $op eq "streq" && [llength $argExprs] == 2} {
        lassign $argExprs ea eb
        set aRegion [RegionEligible $ea]
        set bRegion [RegionEligible $eb]
        if {!$aRegion && !$bRegion} {
            return ""
        }
        # Exactly one operand supplies the region. A `ref` operand is a
        # virtual binding that *cannot* be evaluated any other way (Ref
        # refuses a non-region request), so it takes the region role; any
        # other region-eligible operand (a `str::substring` call, a literal, a
        # forwarding call) can equally be evaluated as an ordinary String.
        # hir::stringregion::Bindings never leaves both operands virtual
        # refs. Otherwise prefer the left one. Evaluation order is
        # unaffected either way (below).
        if {$aRegion && $bRegion} {
            if {[hir::kind $hir $eb] eq "ref" && [hir::kind $hir $ea] ne "ref"} {
                set aRegion 0
            } else {
                set bRegion 0
            }
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
    if {$name eq "str::length" && [llength $argExprs] == 1} {
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
    if {$name in {str::is_tcl_alpha str::is_tcl_alnum} && [llength $argExprs] == 1} {
        # core/tclcompat.tcl's one-scalar classification: a region-eligible
        # sole argument classifies directly from the region's own text (see
        # ops.rs's rt_str_region_is_tcl_alpha/alnum), never materializing the
        # one-character String `char_at`-shaped source code (hir/
        # stringregion.tcl's ConsumingNative) usually builds just to classify
        # it once and discard it. Same RANGE contract as the materializing
        # op (both guard/knownError-free by construction: str::is_tcl_alpha/
        # str::is_tcl_alnum accept any str, never needing a kind guard).
        set arg [lindex $argExprs 0]
        if {![RegionEligible $arg]} {
            return ""
        }
        set region [Expr fn $arg region]
        if {$region eq "never"} {
            return {never tagged}
        }
        lassign $region base start end
        set rop [expr {$name eq "str::is_tcl_alpha" ? "strregiontclalpha" : "strregiontclalnum"}]
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
# native value), or a call to `==`/`str::length`/a ConsumingNative is a
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
            if {$name eq "str::length" && [llength $args] == 1} {
                return [Assign fn "op isub $end $start" $e]
            }
            # str::is_tcl_alpha/str::is_tcl_alnum: ConsumingShape's own structural
            # check allows no other native call to appear here.
            set rop [expr {$name eq "str::is_tcl_alpha" ? "strregiontclalpha" : "strregiontclalnum"}]
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
    set analysis [hir::aot::analyzeRegion $hir $block $context]
    CollectChecks $analysis
    # The callee's kind guards are emitted here, into FN, and EmitArgGuards
    # counts them in FN's own `guards`; so its representation blockers are
    # FN's too, once per inlined copy -- just as a companion counts its
    # region's once per NIR function. Without this the guards of a leaf
    # inlined at an unproven argument (byte::high_nibble(b) in web.bot's
    # high_nibble, any leaf of a generic instance) had no blocker anywhere:
    # the callee's own function is not even emitted once every call inlines.
    dict incr fn inlinedBlockers [llength [lmap b [dict get $analysis blockers] {
        if {[dict get $b class] ne "representation"} continue
        set b
    }]]
    foreach b $params r $callerArgRegs {
        dict set fn locals $b [list reg $r]
    }
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
# resolves to (an "equality" implementation picks veq/ieq/streq/chareq from the two
# argument expressions' static types, exactly as NativeCall always has;
# an "equality-set" implementation -- immutable_set::contains -- picks
# setcontainstotal over the generic setcontains the identical way, from the
# set's own element type and the needle's own type, both already available
# as ordinary HIR types at this call node, no different from =='s own two
# argument expressions: see M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md; an
# "equality-list" implementation -- immutable_set::from_list -- picks
# setfromlisttotal over the generic setfromlist the same way, from the
# source list's own static element type: see
# M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md) --
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
    set argExprs [dict get $node args]
    switch -- [lindex $impl 0] {
        equality {
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
            } elseif {$ka eq $kb && $ka eq "UnicodeChar"} {
                # Two UnicodeChar immediates: scalar equality is word
                # equality, and it cannot fail (str::char_at(s, i) == '%').
                set op chareq
            } elseif {$ka eq $kb && $ka eq "enum"} {
                # Two enum case immediates (ENUMS.md): nominal equality is
                # word equality (one word per case of one declaration, so a
                # same-spelled case of another enum is another word), and it
                # cannot fail.
                set op enumeq
            }
            return [list $name $op]
        }
        equality-set {
            # SetContains's generic form (rt_set_contains) can raise
            # EQUALITY comparing the needle against a member whose runtime
            # kind lacks structural equality (Block/Native/MutArray) --
            # unconditionally true of the *native's own* signature
            # (-param-types {immutableSet any}). At one particular call
            # node, though, the set's own applied element type and the
            # needle's own static type may both already be proven
            # equality-total (hir::types::IsEqualityTotal), in which case
            # this invocation's own runtime operands can never reach that
            # failure -- so it lowers to setcontainstotal, a non-erroring
            # sibling NIR op of the identical runtime operation (op_may_error
            # is opcode-keyed, not native-keyed: see native/src/runtime/
            # ops.rs). Generic SetContains itself is untouched: any call
            # whose set/needle types are not both proven total -- including
            # a broad/unresolved ImmutableSet, or an "any" needle -- still
            # resolves to plain setcontains here, exactly as before this
            # milestone.
            set op setcontains
            if {[llength $argExprs] == 2} {
                lassign $argExprs setArg needleArg
                set setType [hir::typeOf $hir $setArg]
                set needleType [hir::typeOf $hir $needleArg]
                if {[hir::types::IsSet $setType]
                        && [hir::types::IsEqualityTotal [lindex $setType 1]]
                        && [hir::types::IsEqualityTotal $needleType]} {
                    set op setcontainstotal
                }
            }
            return [list $name $op]
        }
        coroutine-resume {
            # A coroutine resume (COROUTINES.md): the handle alone for the
            # zero-message protocol, the handle and the one message
            # otherwise (static typing fixed which, COROUTINE-RESUME-ARITY).
            return [list $name [expr {[llength $argExprs] == 1 ? "coresume0" : "coresume"}]]
        }
        equality-list {
            # SetFromList's generic form (rt_set_from_list) dedups its
            # source List by ordinary equality, which can raise EQUALITY
            # comparing two candidate elements whose runtime kind lacks
            # structural equality (Block/Native/MutArray) -- unconditionally
            # true of the *native's own* signature (-param-types {list}).
            # At one particular call node, though, the source list's own
            # static element type may already be proven equality-total
            # (hir::types::IsEqualityTotal), in which case every comparison
            # this invocation's own dedup pass can ever perform is
            # necessarily T x T for an equality-total T -- so it lowers to
            # setfromlisttotal, a non-erroring sibling NIR op of the
            # identical runtime operation (op_may_error is opcode-keyed, not
            # native-keyed: see native/src/runtime/ops.rs). Generic
            # SetFromList itself is untouched: any call whose source list's
            # element type is not proven total -- including a broad/
            # unresolved List, or one over a genuinely unsupported-equality
            # kind -- still resolves to plain setfromlist here, exactly as
            # before this milestone (M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md).
            set op setfromlist
            if {[llength $argExprs] == 1} {
                set listType [hir::typeOf $hir [lindex $argExprs 0]]
                if {[hir::types::IsList $listType]
                        && [hir::types::IsEqualityTotal [lindex $listType 1]]} {
                    set op setfromlisttotal
                }
            }
            return [list $name $op]
        }
        default {
            set op [lindex $impl 1]
            variable provenOps
            if {[dict exists $provenOps $op] && [BoundsProven $e]} {
                set op [dict get $provenOps $op]
            }
            return [list $name $op]
        }
    }
}

# Proven bounds (PROOF-FACT-CENSUS.md G1). hir/completions.tcl proves, per
# bounds-bearing native call (core/native.tcl's `-bounds`), which of its
# checks can never fail on any path reaching it, and stamps that verdict on
# the call node (BoundsProven). The proof is open-world (every parameter
# unconstrained), so it holds in every specialization instance and every
# lowering of the node -- this never re-derives it, and never reads source
# syntax (a handler, an `errors` clause) as proof. A call whose every check
# is proven lowers to the sibling opcode that has no check and no error
# exit; one with any unproven check keeps the whole checked operation. (Only
# whole calls are consumed: these operations are single helper calls with one
# error exit, so a partly checked variant would change neither the code nor
# the function's fallibility.)
namespace eval native::lower {
    variable provenOps [dict create \
        listget listgetproven  mutarrayget mutarraygetproven  mutarrayset mutarraysetproven \
        substr substrproven  strcharat strcharatproven  mutarraycopy mutarraycopyproven  mutarrayfreeze mutarrayfreezeproven]
}

# 1 if native call E has every bounds check proven (and the optimization is on).
proc native::lower::BoundsProven {e} {
    variable hir
    variable provenBoundsOpt
    return [expr {$provenBoundsOpt && [hir::completions::BoundsProven $hir $e]}]
}

# Emits the runtime kind guard (or known-error guard) hir::aot already
# decided each of ARGEXPRS (call E's arguments, now lowered as ARGREGS) needs
# for a call whose native's declared parameter types are PARAMTYPES -- shared
# by NativeCall's ordinary path and the "String regions" section's own
# `str::substring`-as-region lowering (Call's `wantRegion` case), which bypasses
# NativeCall entirely but still owes its three operands the exact same
# checks an ordinary `str::substring` call would have run.
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
    set big [BigConstantResult $e $argExprs $op]
    if {$big ne ""} {
        # An Int `+ - *` of integer constant expressions whose value BIG is
        # outside the small-Int range (a literal below -2^62 is `0 - N`:
        # lib/abi/x86_64.bot's -9223372036854775808): that value as a static
        # BigInt constant, never computed -- and allocated -- at run time on
        # every evaluation. The operands were already evaluated (Call
        # evaluates every argument first); only the pure, total operation
        # itself is dropped.
        return [list [IntConst fn $big $e] tagged]
    }
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

# The value of E, a call of the Int arithmetic op OP (iadd, isub, imul) on
# ARGEXPRS, when E is an integer constant expression (ConstantIntValue)
# whose value is outside the small-Int range and neither operand needs a
# runtime check; "" otherwise. Only source constants are folded (a
# parameter's proven point Range is not: its arithmetic stays the ordinary
# representation decision), and a small value is left alone: raw
# arithmetic already computes it without allocating.
proc native::lower::BigConstantResult {e argExprs op} {
    variable reprOpt
    variable guards
    variable knownErrors
    if {!$reprOpt || $op ni {iadd isub imul} || [llength $argExprs] != 2} {
        return ""
    }
    foreach a $argExprs {
        set key [list $e $a]
        if {[dict exists $guards $key] || [dict exists $knownErrors $key]} {
            return ""
        }
    }
    set value [ConstantIntValue $e]
    if {$value eq "" || [hir::range::fitsSmall [hir::range::point $value]]} {
        return ""
    }
    return $value
}

# The exact value of E when it is an integer constant expression: an Int
# literal, or `+ - *` (the root natives) of two of them -- a negative literal
# is `0 - N` -- else "". Tcl's own arbitrary-precision arithmetic computes it.
proc native::lower::ConstantIntValue {e} {
    variable hir
    switch -- [hir::kind $hir $e] {
        const {
            set v [hir::get $hir $e value]
            return [expr {[core::value::kind $v] eq "int" ? [core::value::intOf $v] : ""}]
        }
        call {
            set node [hir::node $hir $e]
            lassign [dict get $node target] targetKind target
            if {$targetKind ne "native" || ![PlainNativeCallee [dict get $node callee]]} {
                return ""
            }
            set name [dict get [hir::symbol $hir $target] name]
            set args [dict get $node args]
            if {$name ni {+ - *} || [llength $args] != 2} {
                return ""
            }
            set a [ConstantIntValue [lindex $args 0]]
            set b [ConstantIntValue [lindex $args 1]]
            if {$a eq "" || $b eq ""} {
                return ""
            }
            return [expr "\$a $name \$b"]
        }
    }
    return ""
}

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
#      K and every value the other operand (A) can take keeps all its bits
#      under K (AndIdentity), then this AND changes nothing -- this is what
#      removes the real body's own trailing `bit_and(..., 15)` once the OR
#      it wraps has already been proven to stay within `[0, 15]` (spec #3's
#      "final masking required by its broad all-Int implementation").
#      (This used to be decided by comparing the call's result Range with
#      A's: a self-map argument that holds only for exact value sets. For a
#      plain interval the result is the hull [0, K] whether or not bits are
#      cleared, so `bit_and(a, 95)` with a in [0, 95] was folded to `a` and
#      returned 32 for a = 32: GENERIC-PREDICATE-PROOF-LOSS.md, "bit_and
#      identity fold".)
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
        set ebmn [dict get $ebRange min]
        if {$ebmn ne "-inf" && $ebmn eq [dict get $ebRange max] && [AndIdentity $eaRange $ebmn]} {
            return [WantConvert fn $ra $want]
        }
        if {$eamn ne "-inf" && $eamn eq [dict get $eaRange max] && [AndIdentity $ebRange $eamn]} {
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

# 1 if `bit_and(a, K)` equals a for every value a Range R allows: R is
# nonnegative and finite, and either each of its exact values keeps all its
# bits under K, or (too many values to list) K has every bit below the
# bit length of R's maximum set, which no value in [0, max] can exceed.
proc native::lower::AndIdentity {r k} {
    set mn [dict get $r min]
    set mx [dict get $r max]
    if {$mn eq "-inf" || $mx eq "+inf" || $mn < 0} {
        return 0
    }
    set exact [hir::range::ExactOf $r]
    if {$exact ne ""} {
        foreach v $exact {
            if {($v & $k) != $v} {
                return 0
            }
        }
        return 1
    }
    # Not `incr`: see hir::range::ExactOf on compiled `incr` at i64 bounds.
    set bound 1
    while {$bound <= $mx} {
        set bound [expr {$bound * 2}]
    }
    set mask [expr {$bound - 1}]
    return [expr {($k & $mask) == $mask}]
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

# The NIR operation implementing native NAME for generic (dynamically
# dispatched) calls -- always the conservative/generic op, never a
# call-site-refined one like setcontainstotal: a Native value called
# through rt_call_value carries no per-call-site static proof, only NAME's
# own signature, so it must use the same opcode -- and therefore the same
# op_may_error classification -- every ordinary generic SetContains
# invocation does.
proc native::lower::NativeImpl {name} {
    variable natives
    set impl [dict get $natives $name]
    switch -- [lindex $impl 0] {
        equality      { return veq }
        equality-set  { return setcontains }
        equality-list { return setfromlist }
        coroutine-resume { return coresume }
        default       { return [lindex $impl 1] }
    }
}

# ---------------------------------------------------------------------------
# Control flow

# 1 if evaluating CONDITION (an `if` condition whose outcome is decided) has
# no effect, cannot fail and would produce only that Bool: a native
# comparison (< <= > >= ==) of two PureIntOperands. Such a condition's
# evaluation is dead code under a decided outcome (If, above).
proc native::lower::PureDecidedCondition {fnVar condition} {
    upvar 1 $fnVar fn
    variable hir
    if {[hir::kind $hir $condition] ne "call"} {
        return 0
    }
    set node [hir::node $hir $condition]
    lassign [dict get $node target] targetKind target
    if {$targetKind ne "native" || ![PlainNativeCallee [dict get $node callee]]
            || [dict get [hir::symbol $hir $target] name] ni {< <= > >= ==}} {
        return 0
    }
    set args [dict get $node args]
    if {[llength $args] != 2} {
        return 0
    }
    foreach a $args {
        if {![PureIntOperand fn $condition $a]} {
            return 0
        }
    }
    return 1
}

# 1 if E, an operand of call PARENT, is statically an Int whose evaluation
# has no effect and cannot fail, and needs no runtime kind check: an integer
# constant, a binding this function already holds in a register (a parameter
# or an evaluated local -- reading it is a register read), or `+ - *` of two
# such operands (a negative literal is `0 - N`).
proc native::lower::PureIntOperand {fnVar parent e} {
    upvar 1 $fnVar fn
    variable hir
    variable guards
    variable knownErrors
    set key [list $parent $e]
    if {[dict exists $guards $key] || [dict exists $knownErrors $key]
            || [hir::types::kindOf [hir::typeOf $hir $e]] ne "int"} {
        return 0
    }
    switch -- [hir::kind $hir $e] {
        const {
            return [expr {[core::value::kind [hir::get $hir $e value]] eq "int"}]
        }
        ref {
            set b [hir::get $hir $e binding]
            return [expr {$b ne "" && [dict exists $fn locals $b]
                && [lindex [dict get $fn locals $b] 0] in {reg rawreg}}]
        }
        call {
            set node [hir::node $hir $e]
            lassign [dict get $node target] targetKind target
            if {$targetKind ne "native" || ![PlainNativeCallee [dict get $node callee]]
                    || [dict get [hir::symbol $hir $target] name] ni {+ - *}} {
                return 0
            }
            set args [dict get $node args]
            if {[llength $args] != 2} {
                return 0
            }
            foreach a $args {
                if {![PureIntOperand fn $e $a]} {
                    return 0
                }
            }
            return 1
        }
    }
    return 0
}

proc native::lower::If {fnVar e node {family ""} {virtualN ""} {virtualCut ""} {rawJoin 0} {shortJoin ""}} {
    upvar 1 $fnVar fn
    variable hir
    variable guards
    variable knownErrors
    variable ranges
    variable currentInstance
    set condition [dict get $node condition]
    set key [list $e $condition]
    # M6-RANGE-DECIDED-BRANCH-LOWERING.md: the canonical branch-outcome
    # theorem (hir::types::KnownOutcome's own syntactic proof, composed
    # with hir::range's already-settled per-instance operand facts -- never
    # reproved here). A known Bool *result* is not the same fact as a
    # removable condition *expression* (M6 spec #40-41), so the condition is
    # still evaluated for its own effects -- unless it provably has none: a
    # comparison of operands that are constants or already-evaluated Int
    # registers (PureDecidedCondition, M6's "condition-expression purity"
    # theorem in its narrowest form, LINUX-X86-64-SYSCALL.md), which a
    # decided outcome makes dead code. Only the runtime branch this decided
    # outcome would make redundant is skipped otherwise.
    set outcome [hir::range::ConditionOutcome $hir $ranges $currentInstance $condition]
    if {$outcome ne "" && ![dict exists $guards $key] && ![dict exists $knownErrors $key]
            && [PureDecidedCondition fn $condition]} {
        dict incr fn skippedGuards [SkippedBlockers [list $condition]]
    } else {
        set test [Expr fn $condition]
        if {$test eq "never"} {
            return never
        }
        if {[dict exists $guards $key] || [dict exists $knownErrors $key]} {
            Emit fn "guardbool $test" $e
            dict incr fn [expr {[dict exists $guards $key] ? "guards" : "knownErrorGuards"}]
        } elseif {[hir::types::kindOf [hir::typeOf $hir $condition]] ne "bool"} {
            throw {NATIVE BUG} "native lowering: hir::aot reports no Boolean check for $condition ($e)"
        }
    }
    if {$outcome ne ""} {
        set role [expr {$outcome ? "then" : "else"}]
        # The other arm is not lowered at all, so its blockers are skipped
        # guards ("Code the lowering does not emit", above): HIR leaves it
        # reachable unless the condition is decided syntactically
        # (hir::types::KnownOutcome).
        dict incr fn skippedGuards \
            [SkippedBlockers [dict get $node [expr {$outcome ? "else" : "then"}]Body]]
        set saved [dict get $fn locals]
        set savedRaw [dict get $fn rawCache]
        if {$virtualN ne ""} {
            set value [SequenceVirtual fn [dict get $node ${role}Body] $virtualN $virtualCut]
        } elseif {$rawJoin} {
            set value [SequenceRaw fn [dict get $node ${role}Body]]
        } elseif {$shortJoin ne ""} {
            set value [SequenceShort fn [dict get $node ${role}Body] $shortJoin]
        } else {
            set value [SequenceTo fn [dict get $node ${role}Body] $family]
        }
        dict set fn locals $saved
        dict set fn rawCache $savedRaw
        return $value
    }
    set then [NewLabel fn]
    set else [NewLabel fn]
    set join [NewLabel fn]
    # A virtual struct join (branch merging): one result register per field.
    set result [expr {$virtualN ne "" ? [NewRegs fn $virtualN] : [NewReg fn]}]
    if {$rawJoin} {
        # Both branches' values are small Ints (they flow into a raw
        # result's proven-small Range), joined in one raw register.
        MarkRaw fn $result
    }
    if {$shortJoin ne ""} {
        # Both branches' values are small Strings of the join's tier (the
        # planner's join of them is): joined in one register of that kind,
        # no branch materialized only to be re-joined as a String.
        MarkScalar fn $result $shortJoin
        Tally fn ${shortJoin}Joins
    }
    if {$family ne ""} {
        # A join wanted in a plan position (virtual construction): each
        # branch's value is moved in as a plan or flat value alike.
        MarkPlan fn $result
    }
    Emit fn "br $test $then $else" $e
    set joined 0
    foreach {label role} [list $then then $else else] {
        EmitLabel fn $label
        set saved [dict get $fn locals]
        set savedRaw [dict get $fn rawCache]
        set body [dict get $node ${role}Body]
        if {$body ne "" && ![hir::get $hir [lindex $body 0] reachable]} {
            # HIR decided the condition: this branch never runs.
            Emit fn unreachable $e
            set value never
        } elseif {$virtualN ne ""} {
            set value [SequenceVirtual fn $body $virtualN $virtualCut]
        } elseif {$rawJoin} {
            set value [SequenceRaw fn $body]
        } elseif {$shortJoin ne ""} {
            set value [SequenceShort fn $body $shortJoin]
        } else {
            set value [SequenceTo fn $body $family]
        }
        dict set fn locals $saved
        dict set fn rawCache $savedRaw
        if {$value ne "never"} {
            if {$virtualN ne ""} {
                foreach r $result v $value {
                    Emit fn "$r = move $v"
                    JoinKeepAddr fn $r $v
                }
            } else {
                Emit fn "$result = move $value"
                JoinKeepAddr fn $result $value
            }
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

# The raw-address provenance (KeepAddrFlow) of a branch's value V moved into
# the join register R: R may hold an address into V's storages whichever branch
# ran, so it carries the union over the branches. A storage register defined
# in only one branch is read after the join as the zero a conditionally defined
# register has on the other path (the same convention a root register that is
# conditionally defined already relies on, codegen/roots.rs): the keepalive of
# it is then a use of nothing, and of the storage on the path that has one.
proc native::lower::JoinKeepAddr {fnVar r v} {
    upvar 1 $fnVar fn
    if {![dict exists $fn keepAddr $v]} {
        return
    }
    set storages [expr {[dict exists $fn keepAddr $r] ? [dict get $fn keepAddr $r] : {}}]
    foreach storage [dict get $fn keepAddr $v] {
        if {$storage ni $storages} {
            lappend storages $storage
        }
    }
    dict set fn keepAddr $r $storages
}

# The result accumulator of a retained collecting loop (ListLoop, CountLoop,
# LockLoop; COLLECTING-LOOPS.md). The accumulator is not a Botlish binding
# -- the loop's List is never observable until the loop ends, normally or by
# a bare `break` -- so hir/construction.tcl, which only reasons about
# bindings and `str::concat`/`list::append` calls, never sees it; the loop lowering
# owns it outright and keeps it virtual itself (M8A-VIRTUAL-IMMUTABLE-
# CONSTRUCTION.md's plan objects): a maybe-plan register that starts as the
# flat empty List, is extended in place by one `construct list plan ACC elem
# V` per contributing iteration (amortized growth: O(1) allocations and
# O(N) element copies for N iterations, where an eager `listappend` per
# iteration copies the whole List so far), and is materialized exactly once,
# by `construct list flat ACC`, where the loop yields its List: normal
# exhaustion and a bare `break` (CollectFinish). `continue` contributes
# nothing and leaves the plan untouched; `return`/an error leaving the body
# just drops it (the collector frees it). The register is a loop-carried
# plan register: consumed once per iteration by the extension and redefined
# by the back-edge move, which is exactly the linear discipline nir.rs's
# validate_plans checks across the back edge; it is an ordinary GC root
# like any other heap register (a ListPlan's items are traced, heap.rs),
# including on a suspended coroutine stack. -virtual-construction-opt 0
# keeps the eager per-iteration `listappend`, for differential testing.
proc native::lower::CollectStart {fnVar e} {
    upvar 1 $fnVar fn
    variable constructionOpt
    set acc0 [Assign fn "op listnew" $e]
    set accReg [NewReg fn]
    if {$constructionOpt} {
        MarkPlan fn $accReg
    }
    Emit fn "$accReg = move $acc0" $e
    return $accReg
}

# Appends the body value VALUE to collecting-loop accumulator ACCREG
# (CollectStart) and rebinds ACCREG to the result.
proc native::lower::CollectAppend {fnVar e accReg value} {
    upvar 1 $fnVar fn
    if {[IsPlanReg fn $accReg]} {
        set accNext [Assign fn "construct list plan $accReg elem $value" $e]
        MarkPlan fn $accNext
    } else {
        set accNext [Assign fn "op listappend $accReg $value" $e]
    }
    Emit fn "$accReg = move $accNext" $e
}

# The List collected so far in accumulator ACCREG (CollectStart), as an
# ordinary flat register: its one materialization (a loop that never
# contributed still holds the flat empty List, which `construct` passes
# through unchanged).
proc native::lower::CollectFinish {fnVar e accReg} {
    upvar 1 $fnVar fn
    if {[IsPlanReg fn $accReg]} {
        return [Assign fn "construct list flat $accReg" $e]
    }
    return $accReg
}

# (listloop LIST-EXPR (block (ELEM) BODY...)): the returning iterable loop
# (RETURNING-ITERABLE-LOOPS.md). Lowers directly to the shape item 50 of
# BYTE-SET.md describes -- evaluate the list once, an index/accumulator
# pair rebound at the loop's own back edge (exactly the multi-definition-
# site register pattern `If`'s own join register already uses, just fed
# back to the loop head instead of a forward join), a `listget` at the
# proven-in-bounds index each iteration (no spurious user-visible bounds
# Error: the generated index is always < the list's own length by
# construction), and `listappend` to grow the result. `continue`/`return`/
# an error inside the body compose completely unchanged. `break` shares
# the same `dict set fn loops $e [list $continueLabel $exit $resultReg
# accReg]` registration mechanism a bare `loop`/countloop already uses,
# extended with one more element -- this listloop's own accumulator
# register -- so the shared Break lowering (native::lower::Expr's own
# `break` case) can tell a collecting listloop apart from a plain
# loop/countloop (whose registration's 4th element is simply absent, i.e.
# "") and move the *collected prefix*, not a break payload, into
# $resultReg: a listloop has exactly one stable result type (List[R]), so
# `break VALUE` is rejected outright at hir/resolve.tcl and never reaches
# here.
#
# RETAINED is whether anything actually uses this listloop's own result
# (`![dict exists $context discarded $e]`, the same statement-position
# discard fact hir/aot.tcl already computes and native/lower.tcl already
# uses elsewhere, e.g. Bind's envless-function check) -- the discarded-
# result optimization (RETURNING-ITERABLE-LOOPS.md items 20-22, 28-29): a
# listloop whose List nothing reads (list::any?/all?/none?/find's own
# short-circuiting bodies, or any `loop x in xs: side_effect(x)` used
# purely for traversal) never emits `listnew`/`listappend` at all -- direct
# eager traversal only, zero output-List allocations -- while still
# running the body (and any of *its* side effects) exactly once per
# element, left to right, exactly as the retained case does. A discarded
# listloop's own $resultReg is a placeholder nothing downstream reads
# (filled with `unit`, matching a discarded countloop's own natural-
# exhaustion value); accReg's sentinel "discard" (not "", to stay
# distinguishable from a plain loop/countloop's own registration) tells
# the shared Break case there is no accumulator to move on break either.
proc native::lower::ListLoop {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    variable context
    set iterExpr [dict get $node iterable]
    set iterReg [Expr fn $iterExpr]
    if {$iterReg eq "never"} {
        return never
    }
    # A loop consuming an affine MutableVector (MUTABLE-VECTOR.md): each
    # iteration moves the vector's first element out (`mvtakefront`, O(1));
    # what an early exit leaves in it is released by that exit's own release
    # items (hir::affine's loop domain), the register %iter.
    set consuming [hir::mutvec::IsConsumingLoop $hir $e]
    # (An affine MutableArray is drained like a vector, MUTABLE-ARRAY.md.)
    set drain [expr {$consuming && [hir::mutvec::ConsumedKind $hir $e] eq "array" ? "mutarray" : "mv"}]
    if {!$consuming} {
        EmitArgGuards fn $e [list $iterExpr] [list $iterReg] {list} "loop"
        set lenReg [Assign fn "op listlen $iterReg" $e]
        set idx0 [IntConst fn 0 $e]
        set idxReg [NewReg fn]
        Emit fn "$idxReg = move $idx0" $e
    }
    set resultReg [NewReg fn]
    set retained [expr {![dict exists $context discarded $e]}]
    if {$retained} {
        set accReg [CollectStart fn $e]
    } else {
        set accReg ""
    }
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
    if {$consuming} {
        set empty [Assign fn "op ${drain}empty $iterReg" $e]
        Emit fn "br $empty $normalExit $bodyLabel" $e
    } else {
        set cmp [Assign fn "op ilt $idxReg $lenReg" $e]
        Emit fn "br $cmp $bodyLabel $normalExit" $e
    }
    EmitLabel fn $bodyLabel
    set saved [dict get $fn locals]
    set savedRaw [dict get $fn rawCache]
    dict set fn loops $e [list $continueLabel $exit $resultReg \
        [expr {$retained ? $accReg : "discard"}]]
    if {$consuming} {
        set elemReg [Assign fn "op ${drain}takefront $iterReg" $e]
    } else {
        set elemReg [Assign fn "op listget $iterReg $idxReg" $e]
    }
    dict set fn locals [dict get $node elementBinding] [list reg $elemReg]
    set bodyValue [Sequence fn [dict get $node body]]
    set usedContinue [dict exists $fn continued $e]
    if {$bodyValue ne "never"} {
        if {$retained} {
            CollectAppend fn $e $accReg $bodyValue
        }
        Emit fn "jump $continueLabel" $e
    }
    dict unset fn continued $e
    dict set fn locals $saved
    dict set fn rawCache $savedRaw
    dict unset fn loops $e
    if {$bodyValue ne "never" || $usedContinue} {
        EmitLabel fn $continueLabel
        if {!$consuming} {
            set idxNext [Assign fn "op iadd $idxReg [IntConst fn 1 $e]" $e]
            Emit fn "$idxReg = move $idxNext" $e
        }
        Emit fn "jump $head" $e
    }
    EmitLabel fn $normalExit
    if {$retained} {
        Emit fn "$resultReg = move [CollectFinish fn $e $accReg]" $e
    } else {
        set unitConst [Assign fn unit $e]
        Emit fn "$resultReg = move $unitConst" $e
    }
    Emit fn "jump $exit" $e
    EmitLabel fn $exit
    return $resultReg
}

# 1 if the numeric loop domain START..END of instance ID gets a raw
# induction register (GENERIC-PREDICATE-PROOF-LOSS.md, loss point 4): both
# bound expressions' Ranges (RANGES, hir::range::analyze) fit the small-Int
# domain. That is the whole proof obligation. The bounds are evaluated once,
# before the loop, so they are unboxed once. The induction value I is only
# ever observed (a reference of the binding, boxed on demand) while the body
# runs, i.e. after the continuation test passed, so START <= I <= END (or
# START >= I >= END going down): a small Int. The one value outside that
# interval is the exhaustion value (one step past the last body value: at
# most END + 1 up, END - 1 down; an empty domain never advances at all). It
# exists only in the register between the advance and the failing test,
# never boxed, bound or returned, and a raw i64 holds it exactly (|END| <=
# 2^62, so END +- 1 is far inside i64), so the raw comparison decides
# exactly what the tagged one did. The same predicate is
# native/rawabi.tcl's demand rule for a count loop bound, so the RawInt plan
# counts a raw loop's bounds as raw consumers exactly when lowering makes
# them so.
proc native::lower::RawCountDomain {ranges id startExpr endExpr} {
    variable reprOpt
    variable rawCountLoopOpt
    if {!$reprOpt || !$rawCountLoopOpt} {
        return 0
    }
    foreach x [list $startExpr $endExpr] {
        set r [hir::range::of $ranges $id $x]
        if {$r eq "never" || ![hir::range::fitsSmall $r]} {
            return 0
        }
    }
    return 1
}

# The bound registers of a numeric loop domain whose bound expressions
# EXPRS were lowered to REGS (tagged, or raw where WANTS asked for it) and
# guarded (EmitArgGuards: the guards run on the tagged registers, so a bound
# that needs one was lowered tagged): RAW 1 converts every tagged one with
# RawOf (its Range fits small: RawCountDomain), RAW 0 returns REGS.
proc native::lower::CountBounds {fnVar regs wants raw} {
    upvar 1 $fnVar fn
    if {!$raw} {
        return $regs
    }
    return [lmap r $regs w $wants {expr {$w eq "raw" ? $r : [RawOf fn $r]}}]
}

# The representation a numeric loop bound EXPR of loop E is first lowered
# in: raw when the domain is raw (RAW) and the bound needs no runtime guard
# (guards check tagged registers), else tagged.
proc native::lower::CountBoundWant {e expr raw} {
    variable guards
    variable knownErrors
    if {!$raw || [dict exists $guards [list $e $expr]] || [dict exists $knownErrors [list $e $expr]]} {
        return tagged
    }
    return raw
}

# The NIR comparison op that keeps a numeric loop of DIRECTION (up|down) and
# ENDKIND (exclusive|inclusive) going while its induction value is still
# inside the domain, and the op that advances it by one. The inclusive forms
# compare with ile/ige against END directly: no END+1/END-1 is ever formed.
proc native::lower::CountOps {direction endKind} {
    switch -- $direction/$endKind {
        up/exclusive   { return {ilt iadd} }
        up/inclusive   { return {ile iadd} }
        down/exclusive { return {igt isub} }
        down/inclusive { return {ige isub} }
    }
    error "native::lower::CountOps: bad $direction/$endKind"
}

# (countloop START-EXPR END-EXPR (block (I) BODY...) ?DIRECTION ENDKIND?):
# the numeric collecting loop (COLLECTING-LOOPS.md; R2A3-COUNTED-LOOPS-FINAL-
# SOURCE.md introduced the ascending exclusive form). Lowers to exactly the
# same real CFG backedge shape as ListLoop above -- a loop-carried register
# rebound at the loop's own back edge (the identical multi-definition-site
# register pattern), `break`/`continue`/`return`/an error inside the body
# composing completely unchanged through the same `dict set fn loops $e
# [list $continueLabel $exit $resultReg $accReg]` mechanism -- but simpler
# than ListLoop in one way: there is no list to index (START/END are
# ordinary Int expressions, so `op ilt`/`ile`/`igt`/`ige` and `op iadd`/
# `isub` -- the same general NIR ops an ordinary comparison/`+`/`-` call
# already lowers to, not a loop-specific operation -- drive the test and the
# advance directly), and I itself *is* the one loop-carried register (no
# per-iteration `listget`-style indirection). When both bounds' Ranges fit
# the small-Int domain (RawCountDomain, loss point 4 of GENERIC-PREDICATE-
# PROOF-LOSS.md) that register is raw: the bounds are unboxed once, the test
# and the advance are `rilt`/`rile`/`rigt`/`rige` and `riadd`/`risub`, and I
# is a `rawreg` local, boxed (TaggedOf, cached per iteration) only where a
# tagged consumer reads it; otherwise the test and advance are the tagged,
# BigInt-capable ops. Like ListLoop it is a collecting loop: an ordinary body value
# is appended to the accumulator (a bare `break` yields the collected
# prefix, exhaustion the whole List), unless nothing reads the result
# (`discarded`, see ListLoop), in which case no output List is ever built.
# The only guard is EmitArgGuards' int-kind check on START/END (hir/aot.tcl's
# own Require call for this node feeds it, exactly like ListLoop's iterable
# check); no Range/List/iterator allocation exists beyond the result.
proc native::lower::CountLoop {fnVar e node} {
    upvar 1 $fnVar fn
    variable context
    variable ranges
    variable currentInstance
    set startExpr [dict get $node start]
    set endExpr [dict get $node end]
    # Loss point 4 (GENERIC-PREDICATE-PROOF-LOSS.md): a domain whose bounds
    # are proven small runs on a raw induction register (RawCountDomain).
    set raw [RawCountDomain $ranges $currentInstance $startExpr $endExpr]
    set wants [list [CountBoundWant $e $startExpr $raw] [CountBoundWant $e $endExpr $raw]]
    set startReg [Expr fn $startExpr [lindex $wants 0]]
    if {$startReg eq "never"} {
        return never
    }
    set endReg [Expr fn $endExpr [lindex $wants 1]]
    if {$endReg eq "never"} {
        return never
    }
    EmitArgGuards fn $e [list $startExpr $endExpr] [list $startReg $endReg] {int int} "loop"
    lassign [CountBounds fn [list $startReg $endReg] $wants $raw] startReg endReg
    lassign [CountOps [dict get $node direction] [dict get $node endKind]] compareOp advanceOp
    set idxReg [NewReg fn]
    set resultReg [NewReg fn]
    if {$raw} {
        MarkRaw fn $idxReg
        set compareOp r$compareOp
        set advanceOp r$advanceOp
    }
    Emit fn "$idxReg = move $startReg" $e
    set retained [expr {![dict exists $context discarded $e]}]
    if {$retained} {
        set accReg [CollectStart fn $e]
    } else {
        set accReg ""
    }
    set head [NewLabel fn]
    set bodyLabel [NewLabel fn]
    # `continue`'s own target (registered below): only advances I and loops
    # back -- exactly ListLoop's own continueLabel discipline, see its
    # comment above for why this must be distinct from $head.
    set continueLabel [NewLabel fn]
    set normalExit [NewLabel fn]
    set exit [NewLabel fn]
    Emit fn "jump $head" $e
    EmitLabel fn $head
    set cmp [Assign fn "op $compareOp $idxReg $endReg" $e]
    if {$raw} {
        dict incr fn rawCompare
    }
    Emit fn "br $cmp $bodyLabel $normalExit" $e
    EmitLabel fn $bodyLabel
    set saved [dict get $fn locals]
    set savedRaw [dict get $fn rawCache]
    dict set fn loops $e [list $continueLabel $exit $resultReg \
        [expr {$retained ? $accReg : "discard"}]]
    dict set fn locals [dict get $node countBinding] [list [expr {$raw ? "rawreg" : "reg"}] $idxReg]
    set bodyValue [Sequence fn [dict get $node body]]
    set usedContinue [dict exists $fn continued $e]
    if {$bodyValue ne "never"} {
        if {$retained} {
            CollectAppend fn $e $accReg $bodyValue
        }
        Emit fn "jump $continueLabel" $e
    }
    dict unset fn continued $e
    dict set fn locals $saved
    dict set fn rawCache $savedRaw
    dict unset fn loops $e
    if {$bodyValue ne "never" || $usedContinue} {
        EmitLabel fn $continueLabel
        if {$raw} {
            set idxNext [AssignRaw fn "op $advanceOp $idxReg [AssignRaw fn "rawint 1" $e]" $e]
            dict incr fn rawArith
        } else {
            set idxNext [Assign fn "op $advanceOp $idxReg [IntConst fn 1 $e]" $e]
        }
        Emit fn "$idxReg = move $idxNext" $e
        Emit fn "jump $head" $e
    }
    EmitLabel fn $normalExit
    if {$retained} {
        Emit fn "$resultReg = move [CollectFinish fn $e $accReg]" $e
    } else {
        set unitConst [Assign fn unit $e]
        Emit fn "$resultReg = move $unitConst" $e
    }
    Emit fn "jump $exit" $e
    EmitLabel fn $exit
    return $resultReg
}

# (lockloop (DOMAIN...) (block (P...) BODY...)): the lockstep collecting loop
# (COLLECTING-LOOPS.md) -- ONE real CFG loop, never nested loops. Every
# domain's operands are lowered once, in written order, before the loop, and
# guarded together (list / int kinds, exactly as ListLoop/CountLoop guard
# theirs). Each numeric domain keeps its own loop-carried induction register
# (its binding, exactly CountLoop's), every list domain is indexed by one
# shared position register, and all of them advance at the one continue
# label, so `continue` advances every domain together and `break` leaves the
# whole loop. The *continuation test* is the first domain's own (an index
# below its list's length, or its numeric comparison; a numeric domain's
# register is raw exactly as CountLoop's is, decided per domain from its own
# bounds): hir/lockstep.tcl has
# already proven every other domain's cardinality equal to it, so a
# `listget` at the shared position is in bounds by construction and no
# runtime cardinality check exists anywhere. Result collection, `discarded`
# and break-prefix behavior are ListLoop's/CountLoop's own.
proc native::lower::LockLoop {fnVar e node} {
    upvar 1 $fnVar fn
    variable context
    variable ranges
    variable currentInstance
    if {[dict exists $node unproven]} {
        # A -strict 0 program whose lockstep obligation hir/lockstep.tcl
        # rejected: replay the diagnostic unconditionally, before anything
        # is evaluated, exactly as the -strict 0 Core IR lowering's
        # REJECTED operand makes the reference evaluator do
        # (core::forms::op-lockloop). Running the
        # loop instead would bind every domain after the first beyond its
        # own interval, which nothing proves.
        regexp {^(\S+): (.*)$} [dict get $node unproven] -> kind message
        Emit fn "raise $kind [Quote $message]" $e
        return never
    }
    set domains [dict get $node domains]
    set exprs {}
    set regs {}
    set kinds {}
    set wants {}
    # Per numeric domain: whether it runs on a raw induction register (loss
    # point 4, RawCountDomain; decided per domain, from its own bounds).
    set raws {}
    foreach domain $domains {
        if {[dict get $domain kind] eq "list"} {
            set operands [list [dict get $domain iterable]]
            set kindList {list}
            set raw 0
        } else {
            set operands [list [dict get $domain start] [dict get $domain end]]
            set kindList {int int}
            set raw [RawCountDomain $ranges $currentInstance {*}$operands]
        }
        lappend raws $raw
        foreach operand $operands kind $kindList {
            set want [expr {$kind eq "int" ? [CountBoundWant $e $operand $raw] : "tagged"}]
            set reg [Expr fn $operand $want]
            if {$reg eq "never"} {
                return never
            }
            lappend exprs $operand
            lappend regs $reg
            lappend kinds $kind
            lappend wants $want
        }
    }
    EmitArgGuards fn $e $exprs $regs $kinds "loop"
    # Per-domain loop state, parallel to DOMAINS.
    set states {}
    set needPosition 0
    set cursor 0
    set anyRaw 0
    foreach domain $domains raw $raws {
        if {[dict get $domain kind] eq "list"} {
            set needPosition 1
            lappend states [dict create kind list list [lindex $regs $cursor]]
            incr cursor
        } else {
            lassign [CountOps [dict get $domain direction] [dict get $domain endKind]] compareOp advanceOp
            lassign [CountBounds fn [lrange $regs $cursor [expr {$cursor + 1}]] \
                [lrange $wants $cursor [expr {$cursor + 1}]] $raw] startReg endReg
            set idxReg [NewReg fn]
            if {$raw} {
                MarkRaw fn $idxReg
                set compareOp r$compareOp
                set advanceOp r$advanceOp
                set anyRaw 1
            }
            Emit fn "$idxReg = move $startReg" $e
            lappend states [dict create kind count idx $idxReg end $endReg \
                compare $compareOp advance $advanceOp raw $raw]
            incr cursor 2
        }
    }
    set one [IntConst fn 1 $e]
    if {$anyRaw} {
        set rawOne [RawOf fn $one]
    }
    if {$needPosition} {
        set posReg [NewReg fn]
        Emit fn "$posReg = move [IntConst fn 0 $e]" $e
    }
    set first [lindex $states 0]
    if {[dict get $first kind] eq "list"} {
        set firstLen [Assign fn "op listlen [dict get $first list]" $e]
    }
    set resultReg [NewReg fn]
    set retained [expr {![dict exists $context discarded $e]}]
    if {$retained} {
        set accReg [CollectStart fn $e]
    } else {
        set accReg ""
    }
    set head [NewLabel fn]
    set bodyLabel [NewLabel fn]
    set continueLabel [NewLabel fn]
    set normalExit [NewLabel fn]
    set exit [NewLabel fn]
    Emit fn "jump $head" $e
    EmitLabel fn $head
    if {[dict get $first kind] eq "list"} {
        set cmp [Assign fn "op ilt $posReg $firstLen" $e]
    } else {
        set cmp [Assign fn "op [dict get $first compare] [dict get $first idx] [dict get $first end]" $e]
        if {[dict get $first raw]} {
            dict incr fn rawCompare
        }
    }
    Emit fn "br $cmp $bodyLabel $normalExit" $e
    EmitLabel fn $bodyLabel
    set saved [dict get $fn locals]
    set savedRaw [dict get $fn rawCache]
    dict set fn loops $e [list $continueLabel $exit $resultReg \
        [expr {$retained ? $accReg : "discard"}]]
    foreach domain $domains state $states {
        if {[dict get $state kind] eq "list"} {
            set elemReg [Assign fn "op listget [dict get $state list] $posReg" $e]
            dict set fn locals [dict get $domain binding] [list reg $elemReg]
        } else {
            dict set fn locals [dict get $domain binding] \
                [list [expr {[dict get $state raw] ? "rawreg" : "reg"}] [dict get $state idx]]
        }
    }
    set bodyValue [Sequence fn [dict get $node body]]
    set usedContinue [dict exists $fn continued $e]
    if {$bodyValue ne "never"} {
        if {$retained} {
            CollectAppend fn $e $accReg $bodyValue
        }
        Emit fn "jump $continueLabel" $e
    }
    dict unset fn continued $e
    dict set fn locals $saved
    dict set fn rawCache $savedRaw
    dict unset fn loops $e
    if {$bodyValue ne "never" || $usedContinue} {
        EmitLabel fn $continueLabel
        foreach state $states {
            if {[dict get $state kind] eq "count"} {
                set idxReg [dict get $state idx]
                if {[dict get $state raw]} {
                    set next [AssignRaw fn "op [dict get $state advance] $idxReg $rawOne" $e]
                    dict incr fn rawArith
                } else {
                    set next [Assign fn "op [dict get $state advance] $idxReg $one" $e]
                }
                Emit fn "$idxReg = move $next" $e
            }
        }
        if {$needPosition} {
            set posNext [Assign fn "op iadd $posReg $one" $e]
            Emit fn "$posReg = move $posNext" $e
        }
        Emit fn "jump $head" $e
    }
    EmitLabel fn $normalExit
    if {$retained} {
        Emit fn "$resultReg = move [CollectFinish fn $e $accReg]" $e
    } else {
        set unitConst [Assign fn unit $e]
        Emit fn "$resultReg = move $unitConst" $e
    }
    Emit fn "jump $exit" $e
    EmitLabel fn $exit
    return $resultReg
}

# The field registers of the payload VALUE of `fail NAME` (ERROR-PAYLOADS.md),
# in the slot order of error NAME's payload struct (its fields sorted by
# name), or "never": the fields of a payload construction (a struct literal)
# evaluated in written order, never built into an object; a virtual struct's
# own field registers; any other value's fields read out of the object.
proc native::lower::PayloadFields {fnVar value name e} {
    upvar 1 $fnVar fn
    variable hir
    set layout [hir::types::StructLayout [hir::errordecls::payloadType $name]]
    if {[hir::kind $hir $value] eq "struct"} {
        set node [hir::node $hir $value]
        if {[dict get $node layout] ne $layout} {
            throw {NATIVE BUG} "native lowering: the payload of fail $name has fields ([dict get $node layout]), not ($layout) ($e)"
        }
        return [StructFields fn $value $node]
    }
    if {[hir::kind $hir $value] eq "ref"} {
        set b [hir::get $hir $value binding]
        if {$b ne "" && [dict exists $fn locals $b]} {
            set local [dict get $fn locals $b]
            if {[lindex $local 0] eq "virtual" && [lindex $local 2] ne "" && [lindex $local 5] eq ""
                    && [lindex $local 2 1] eq $layout} {
                return [lindex $local 1]
            }
        }
    }
    set r [Expr fn $value]
    if {$r eq "never"} {
        return never
    }
    set fields {}
    set slot 0
    foreach field $layout {
        lappend fields [Assign fn "structget $slot $r" $e]
        incr slot
    }
    return $fields
}

# The payload fields handler BODY reads through its payload binding B of
# error NAME (ERROR-PAYLOADS.md): the names projected out of B, plus every
# field whose type is affine (a release of B drops those) -- or "all" when
# some reference uses B whole (a materialization), so every field is read.
proc native::lower::PayloadNeeded {b body name} {
    variable hir
    set parent [dict create]
    set refs {}
    set work $body
    while {$work ne {}} {
        set x [lindex $work end]
        set work [lrange $work 0 end-1]
        set node [hir::node $hir $x]
        if {[dict get $node kind] eq "ref" && [dict get $node binding] eq $b} {
            lappend refs $x
        }
        foreach child [hir::children $hir $x] {
            dict set parent $child $x
            lappend work $child
        }
    }
    set needed {}
    foreach r $refs {
        set p [expr {[dict exists $parent $r] ? [dict get $parent $r] : ""}]
        if {$p eq "" || [hir::kind $hir $p] ne "project" || [hir::get $hir $p receiver] ne $r} {
            return all
        }
        lappend needed [hir::get $hir $p name]
    }
    foreach {field type} [hir::errordecls::fields $name] {
        if {[hir::types::IsAffine $type]} {
            lappend needed $field
        }
    }
    return [lsort -unique $needed]
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
# error and runs that handler's body (a fresh scope,
# lexically part of the enclosing function, exactly like an `if` branch); no match re-raises the still-pending failure unchanged
# (`reraise`) to whatever the *outer* error-exit target is (PopErrorExit
# has already restored it by then).
proc native::lower::Handle {fnVar e node} {
    upvar 1 $fnVar fn
    variable hir
    set call [dict get $node call]
    set names [dict get $node handlerNames]
    set scopes [dict get $node handlerScopes]
    set bodies [dict get $node handlerBodies]

    set catchLabel [NewLabel fn]
    set joinLabel [NewLabel fn]
    set result [NewReg fn]
    set joined 0

    Emit fn "pusherrorexit $catchLabel" $e
    # Anything the protected call materializes (a virtual struct's object,
    # STRUCT-SCALAR-REPLACEMENT.md) may not exist on the handler's path: it
    # must not be reused there or after the join.
    set savedLocals [dict get $fn locals]
    set callResult [Expr fn $call]
    dict set fn locals $savedLocals
    Emit fn "poperrorexit" $e
    if {$callResult ne "never"} {
        Emit fn "$result = move $callResult" $e
        Emit fn "jump $joinLabel" $e
        set joined 1
    }

    EmitLabel fn $catchLabel
    set payloads [expr {[dict exists $node handlerPayloads] ? [dict get $node handlerPayloads] : {}}]
    set index 0
    foreach name $names scopeId $scopes body $bodies {
        set payload [lindex $payloads $index]
        incr index
        set eqReg [Assign fn "declarederroreq [ErrorId $name]" $e]
        set matchLabel [NewLabel fn]
        set nextLabel [NewLabel fn]
        Emit fn "br $eqReg $matchLabel $nextLabel" $e
        EmitLabel fn $matchLabel
        set saved [dict get $fn locals]
        set savedRaw [dict get $fn rawCache]
        if {$payload ne "" && [hir::errordecls::hasPayload $name]} {
            # The handler's payload binding (ERROR-PAYLOADS.md): the payload's
            # fields, read out of the Vm's payload slots before they are
            # cleared, held as a virtual struct of the payload's anonymous
            # shape -- a projection or destructuring reads a field register,
            # and only a use that needs the object itself builds it, once
            # (MaterializeVirtual).
            set layout [hir::types::StructLayout [hir::errordecls::payloadType $name]]
            set needed [PayloadNeeded $payload $body $name]
            set fieldRegs {}
            set k 0
            foreach field $layout {
                if {$needed eq "all" || $field in $needed} {
                    lappend fieldRegs [Assign fn "declaredpayload $k" $e]
                } else {
                    # A field the handler never reads: no read at all (the
                    # entry is marked partial, so it is never materialized).
                    lappend fieldRegs ""
                }
                incr k
            }
            dict set fn locals $payload [list virtual $fieldRegs [list "" $layout] $payload "" "" \
                [expr {$needed eq "all" ? "" : "partial"}]]
        }
        Emit fn "cleardeclarederror" $e
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
    # A declared error no handler handles, leaving the scope of affine
    # owners (hir::affine::releasesOnError): released on its way out.
    ReleaseOnError fn $e [hir::affine::releasesOnError $hir $e]
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
# Virtual construction (procedures; see the "Virtual construction" section
# at the top of this file)

# 1 if REG is a plan ("maybe-plan") register of the function being lowered.
proc native::lower::IsPlanReg {fnVar reg} {
    upvar 1 $fnVar fn
    return [dict exists $fn planRegs $reg]
}

# Declares REG a plan register (the func header's `planregs=`).
proc native::lower::MarkPlan {fnVar reg} {
    upvar 1 $fnVar fn
    dict set fn planRegs $reg 1
}

# The construction family ("" | str | list) of the current function's own
# result: only for a plan-result instance's canonical/internal function,
# never for a companion (whose exits have their own multi-value contract).
proc native::lower::PlanResultFamily {fnVar} {
    upvar 1 $fnVar fn
    if {![dict exists $fn planResult] || [dict get $fn companion] ne "" || [dict get $fn regionCompanion]} {
        return ""
    }
    return [dict get $fn planResult]
}

# The ` planregs="..."`/` planresult=1` suffix of the current function's
# header ("" when it has neither).
proc native::lower::PlanHeader {fnVar} {
    upvar 1 $fnVar fn
    set text ""
    if {[dict exists $fn planRegs]} {
        set regs [lsort -integer [lmap r [dict keys [dict get $fn planRegs]] {string range $r 1 end}]]
        if {$regs ne ""} {
            append text " planregs=[Quote [join $regs { }]]"
        }
    }
    if {[PlanResultFamily fn] ne ""} {
        append text " planresult=1"
    }
    return $text
}

# Registers ordinary (non-raw) parameter K of instance ID, binding B, as
# register R: a plan parameter (hir::construction) is a plan register every
# lowering variant of the instance declares alike, since a caller's plan
# argument does not depend on which variant it calls.
proc native::lower::ParamLocal {fnVar id k b r} {
    upvar 1 $fnVar fn
    variable construction
    set family [hir::construction::paramFamily $construction $id $k]
    if {$family ne ""} {
        MarkPlan fn $r
        dict set fn locals $b [list plan $r $family]
    } else {
        dict set fn locals $b [list reg $r]
    }
}

# The construction family of native NAME called with ARGS at E, when it is a
# construction this lowering may keep virtual: `str::concat` (String) or a
# `list::append` whose List operand is statically List-typed ("" otherwise:
# an untyped List operand keeps its eager, guarded `listappend`).
proc native::lower::ConstructNative {e name argExprs} {
    variable hir
    if {$name eq "str::concat" && [llength $argExprs] == 2} {
        return str
    }
    if {$name eq "list::append" && [llength $argExprs] == 2
            && [hir::construction::Family [hir::typeOf $hir [lindex $argExprs 0]]] eq "list"} {
        return list
    }
    return ""
}

# 1 if CALLEEEXPR is a plain reference to a root native (what Call's own
# skipCallee already treats as needing no code): the only callee shape the
# construction lowering bypasses Call's callee evaluation for.
proc native::lower::PlainNativeCallee {calleeExpr} {
    variable hir
    if {[hir::kind $hir $calleeExpr] ne "ref"} {
        return 0
    }
    set b [hir::get $hir $calleeExpr binding]
    return [expr {$b ne "" && [dict get [hir::binding $hir $b] kind] eq "root"}]
}

# The NIR operand text of construction PIECES.
proc native::lower::PiecesText {pieces} {
    set words {}
    foreach piece $pieces {
        switch -- [lindex $piece 0] {
            span   { lappend words [lindex $piece 1] }
            region { lappend words region {*}[lrange $piece 1 3] }
            elem   { lappend words elem [lindex $piece 1] }
        }
    }
    return [join $words { }]
}

# PIECES (of FAMILY) as one ordinary flat register: the one materialization
# of a virtual construction at a barrier. A lone flat piece is itself the
# value; two flat pieces lower to exactly the eager op the baseline emits
# (`strcat`/`listappend`), so nothing changes where nothing is virtual;
# anything else is one n-ary `construct ... flat`.
proc native::lower::PiecesToFlat {fnVar pieces family e} {
    upvar 1 $fnVar fn
    if {[llength $pieces] == 1} {
        lassign [lindex $pieces 0] tag r
        if {$tag eq "span" && ![IsPlanReg fn $r]} {
            return $r
        }
    }
    if {[llength $pieces] == 2} {
        lassign [lindex $pieces 0] t0 r0
        lassign [lindex $pieces 1] t1 r1
        if {$family eq "str" && $t0 eq "span" && $t1 eq "span" && ![IsPlanReg fn $r0] && ![IsPlanReg fn $r1]} {
            return [Assign fn "op strcat $r0 $r1" $e]
        }
        if {$family eq "list" && $t0 eq "span" && $t1 eq "elem" && ![IsPlanReg fn $r0]} {
            return [Assign fn "op listappend $r0 $r1" $e]
        }
    }
    return [Assign fn "construct $family flat [PiecesText $pieces]" $e]
}

# PIECES (of FAMILY) as one plan register, for a plan position that needs a
# single register (a plan parameter's argument, a plan result, a join): a
# lone span is passed on unchanged (flat or plan, a maybe-plan position
# accepts either); anything else is one `construct ... plan`.
proc native::lower::PiecesToPlan {fnVar pieces family e} {
    upvar 1 $fnVar fn
    if {[llength $pieces] == 1 && [lindex $pieces 0 0] eq "span"} {
        return [lindex $pieces 0 1]
    }
    set r [Assign fn "construct $family plan [PiecesText $pieces]" $e]
    MarkPlan fn $r
    return $r
}

# "never" if E cannot complete normally past its own evaluation (Expr's own
# tail check, for the expression kinds PlanPieces lowers itself).
proc native::lower::PlanNever {fnVar e} {
    upvar 1 $fnVar fn
    variable hir
    if {[hir::typeOf $hir $e] eq "never"} {
        Emit fn unreachable $e
        return 1
    }
    return 0
}

# Expression E, wanted in a plan position of FAMILY: its construction
# PIECES (a list of {span REG} | {region BASE START END} | {elem REG}), or
# "never". Every piece is an already-evaluated value, evaluated exactly
# where and in the order ordinary lowering evaluates it; only the copying
# into one flat object is left to whichever consumer materializes. An
# expression with nothing to keep virtual is simply one ordinary span.
proc native::lower::PlanPieces {fnVar e family} {
    upvar 1 $fnVar fn
    variable hir
    variable construction
    variable currentInstance
    set node [hir::node $hir $e]
    switch -- [dict get $node kind] {
        call {
            lassign [dict get $node target] targetKind target
            if {$targetKind eq "native" && [dict get $node known] eq ""
                    && [PlainNativeCallee [dict get $node callee]]} {
                set name [dict get [hir::symbol $hir $target] name]
                set args [dict get $node args]
                if {[ConstructNative $e $name $args] eq $family} {
                    set pieces [ConstructPieces fn $e $node $name $family]
                    if {$pieces eq "never" || [PlanNever fn $e]} {
                        return [Never fn $e]
                    }
                    return $pieces
                }
                if {$family eq "str" && $name eq "str::substring" && [llength $args] == 3} {
                    # A StringRegion piece: the substring's three operands,
                    # evaluated and bounds-checked exactly where the eager
                    # `substr` would run (Call's own wantRegion path), but
                    # never copied into a String of its own.
                    lassign [Call fn $e $node tagged "" 1] fields repr
                    if {$fields eq "never" || [PlanNever fn $e]} {
                        return [Never fn $e]
                    }
                    return [list [list region {*}$fields]]
                }
            }
            if {$targetKind eq "block"} {
                lassign [Call fn $e $node plan] r repr
                if {$r eq "never" || [PlanNever fn $e]} {
                    return [Never fn $e]
                }
                return [list [list span $r]]
            }
        }
        ref {
            set b [dict get $node binding]
            if {$b ne "" && [dict exists $fn locals $b]} {
                set local [dict get $fn locals $b]
                switch -- [lindex $local 0] {
                    pieces { return [lindex $local 1] }
                    plan   { return [list [list span [lindex $local 1]]] }
                }
            }
        }
        if {
            if {[hir::construction::Source $construction $currentInstance $e] eq $family} {
                set r [If fn $e $node $family]
                if {$r eq "never" || [PlanNever fn $e]} {
                    return [Never fn $e]
                }
                return [list [list span $r]]
            }
        }
    }
    set r [Expr fn $e]
    if {$r eq "never"} {
        return never
    }
    return [list [list span $r]]
}

# The pieces of construction call E (native NAME: `str::concat` or `list::append`,
# FAMILY): its operands' own pieces, in order -- a nested construction, a
# plan local, a plan parameter or a plan result contributes its pieces or
# plan instead of a materialized value. The operands' kind checks are
# exactly the eager call's (EmitArgGuards, after both operands, on the same
# flat registers); an operand that stayed virtual is statically String/
# List-typed by construction, so it never needs one.
proc native::lower::ConstructPieces {fnVar e node name family} {
    upvar 1 $fnVar fn
    variable guards
    variable knownErrors
    lassign [dict get $node args] a b
    set pa [PlanPieces fn $a $family]
    if {$pa eq "never"} {
        return never
    }
    if {$family eq "str"} {
        set pb [PlanPieces fn $b str]
        if {$pb eq "never"} {
            return never
        }
    } else {
        set r [Expr fn $b]
        if {$r eq "never"} {
            return never
        }
        set pb [list [list elem $r]]
    }
    set meta [core::native::metadata $name]
    set checkExprs {}
    set checkRegs {}
    set checkTypes {}
    foreach arg [list $a $b] pieces [list $pa $pb] type [dict get $meta paramTypes] {
        lassign [lindex $pieces 0] tag reg
        if {[llength $pieces] == 1 && $tag in {span elem} && ![IsPlanReg fn $reg]} {
            lappend checkExprs $arg
            lappend checkRegs $reg
            lappend checkTypes $type
        } elseif {[dict exists $guards [list $e $arg]] || [dict exists $knownErrors [list $e $arg]]} {
            throw {NATIVE BUG} "native lowering: virtual construction operand $arg of $name needs a kind check ($e)"
        }
    }
    EmitArgGuards fn $e $checkExprs $checkRegs $checkTypes $name
    dict lappend fn calls [list native $name]
    return [concat $pa $pb]
}

# One family ("" = ordinary) per argument position of a direct call to
# instance TARGET with N arguments: which positions are plan parameters.
proc native::lower::PlanSlots {target n} {
    variable construction
    set slots {}
    for {set k 0} {$k < $n} {incr k} {
        lappend slots [hir::construction::paramFamily $construction $target $k]
    }
    return $slots
}

# {REG REPR} for RESULT, a direct call's result register whose callee is a
# plan-result instance of FAMILY: RESULT is a plan register; a caller that
# wants a plan (PlanPieces) gets it as is, any other caller its one
# materialization right here, at the call.
proc native::lower::PlanCallResult {fnVar e result family want} {
    upvar 1 $fnVar fn
    MarkPlan fn $result
    if {$want eq "plan"} {
        return [list $result plan]
    }
    return [list [Assign fn "construct $family flat $result" $e] tagged]
}

# Like Sequence, but its trailing value is wanted in a plan position of
# FAMILY ("" for an ordinary Sequence): returns one register (flat or plan)
# or "never".
# Like Sequence, for a branch body whose value is a recognized struct
# construction of N fields: the statements run as usual and the last
# expression's *fields* (VirtualValue) are the value. A body that cannot
# complete normally (its last expression is typed never, or a statement
# never completes) is "never".
proc native::lower::SequenceVirtual {fnVar exprs n {cut ""}} {
    upvar 1 $fnVar fn
    variable hir
    foreach e [lrange $exprs 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            return never
        }
    }
    set last [lindex $exprs end]
    if {[hir::typeOf $hir $last] eq "never"} {
        Expr fn $last
        return never
    }
    return [VirtualValue fn $last $n $cut]
}

# Like Sequence, for a body whose value is wanted as a raw machine integer
# (the tail of a raw-result function, a raw `if` join): the statements run
# as usual, the last expression is demanded `rawjoin`. The caller has
# already established (RawJoinOk / the plan) that the value's Range fits the
# small-Int domain.
proc native::lower::SequenceRaw {fnVar exprs} {
    upvar 1 $fnVar fn
    if {$exprs eq ""} {
        throw {NATIVE BUG} "native lowering: a raw-Int body has no value"
    }
    foreach e [lrange $exprs 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            return never
        }
    }
    return [Expr fn [lindex $exprs end] rawjoin]
}

# Like SequenceRaw, for a body whose value flows into a scalar String register
# of KIND (`short` or `ascii`): every statement but the last is evaluated for
# effect, the last is produced as KIND.
proc native::lower::SequenceShort {fnVar exprs kind} {
    upvar 1 $fnVar fn
    if {$exprs eq ""} {
        throw {NATIVE BUG} "native lowering: a ShortString1 body has no value"
    }
    foreach e [lrange $exprs 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            return never
        }
    }
    return [Expr fn [lindex $exprs end] $kind]
}

proc native::lower::SequenceTo {fnVar exprs family} {
    upvar 1 $fnVar fn
    if {$family eq "" || $exprs eq ""} {
        return [Sequence fn $exprs]
    }
    foreach e [lrange $exprs 0 end-1] {
        if {[Expr fn $e] eq "never"} {
            return never
        }
    }
    set last [lindex $exprs end]
    set pieces [PlanPieces fn $last $family]
    if {$pieces eq "never"} {
        return never
    }
    return [PiecesToPlan fn $pieces $family $last]
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
    if {[core::native::isBuiltinError $name]} {
        # The runtime's own builtin errors (core::native::declareError) have
        # fixed ids far above a program's dense 1-based ones: the runtime
        # (native/src/runtime/error.rs's BUILTIN_ERROR_ID_BASE) raises them
        # itself, without any per-program table.
        return [expr {0x40000000 + [core::native::builtinErrorIndex $name]}]
    }
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
