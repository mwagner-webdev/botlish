# native.tcl -- registry of native (Tcl-backed) callables.
#
# A native callable value is {native NAME}; everything else about it lives
# in the registry:
#
#   name            source-level name
#   impl            Tcl command prefix; called with the argument values,
#                   must return a runtime value
#   arity           exact argument count, or * for any
#   refinesTrue     facts proven when the callable returns true
#   refinesFalse    facts proven when the callable returns false
#   paramTypes      types (type.tcl) the implementation *requires* of each
#                   argument (any = no requirement); a call that returns
#                   proves its arguments had these types. "" = unknown.
#   resultType      type of every result, or any
#   testsType       "" or a type T: the native is a *type test*, a pure
#                   one-argument predicate returning exactly whether its
#                   argument is a value of T (core::type::acceptsValue).
#                   Its parameter type must be any or a primitive kind P,
#                   with T a subtype of P; the runtime itself rejects
#                   arguments not of kind P (with core::value::expect's
#                   TYPE error) before calling the implementation. A type
#                   test refines its argument to T when it returns true.
#                   Knowing this, a compiler may decide the call from static
#                   types or replace it with an inline membership test.
#   nomethod        0 | 1 (default 0): the native's author declares that its
#                   receiver spelling reads badly, so `x.name(...)` never
#                   denotes it (WARNINGS-METHOD-ELIGIBLE.md): method sugar skips it as a
#                   candidate, and a method-style call whose only visible
#                   function of that name is a nomethod one is the
#                   NOMETHOD-CALL resolution error. Ordinary calls are
#                   unaffected, and so are its type, completion and code.
#                   Interface metadata of the callable, like arity: no
#                   shipped native sets it.
#   errors          the declared errors (core::native::declareError) a call
#                   of this native may complete with -- {} for every native
#                   but `argv` (core/process.tcl). The impl signals one with
#                   core::native::failDeclared, and core::native::invoke turns
#                   that into an ordinary propagate-error completion, exactly
#                   like a Botlish `fail NAME` (EXPLICIT-ERROR-COMPLETIONS.md).
#   completion      0 | 1 (default 0): the impl returns a *completion*, not a
#                   value -- normal, or the propagate-error of a program's own
#                   declared error that Botlish code it ran to a boundary of
#                   its own completed with (core/coroutines.tcl: a coroutine
#                   segment). Which errors are possible is not the native's
#                   (they are the program's): static typing charges them to
#                   the call (hir/coroutines.tcl), and compiled code always
#                   calls such a native through the generic call boundary.
#   errorsFrom      "" or the index K of a callable argument whose contract's
#                   declared errors a call of the native may complete with:
#                   the native calls it (std::mutable_array::generate's factory),
#                   and the first failing call's propagate-error is the
#                   native's own completion. Static typing charges the
#                   callable's contract errors to the call (hir/types.tcl's
#                   calleeErrors); such a native is a -completion native.
#   ownership       what the operation does, statically, with each argument
#                   it is given (OWNERSHIP ROLES below), one role per
#                   parameter (for a native of arity *, the roles of its
#                   leading arguments, the last one repeating for every
#                   further argument), or "" (every argument is `erase`). The
#                   ownership discipline (hir/affine.tcl) reads these roles,
#                   never a native's name, to decide whether an affine
#                   argument moves, stays owned, or is rejected; they are
#                   compile-time semantics only (no runtime check exists).
#   resultLength    "" or the length of the collection the native returns,
#                   for static analyses that track lengths and capacities
#                   (hir/cardinality.tcl) and for the exact List length a
#                   returned List's type states (hir/types.tcl's Call mints
#                   List[T]{length: N} from it, LIST-CARDINALITY-
#                   REFINEMENTS.md), read by registration, never by name:
#                     args            the number of arguments (the List
#                                     literal's constructor, `list`)
#                     int K           the Int argument K (allocate's capacity)
#                     list K          the length of List argument K
#                     list K D        the length of List argument K plus D
#                                     (std::list::append: one more)
#                     extent K        the extent N of argument K's static
#                                     type when it is a live fixed array,
#                                     NativeView[array N of E] or
#                                     NativeEdit[array N of E] (std::binary::load
#                                     copies exactly N elements:
#                                     FIXED-LAYOUT-ARRAYS.md); nothing for
#                                     any other argument
#                     path K          the extent N of the fixed array the
#                                     field designator constant argument K
#                                     names (std::binary::read of an array:
#                                     LAYOUT-UNIONS.md); nothing for any
#                                     other designator
#   hashing         "" or {K MODE}: argument K is hashed -- compared by the
#                   hash's equality and walked by its canonical encoding
#                   (core/hashing.tcl; HASHABLE-AND-KEYED-HASH.md) -- so its
#                   static type answers to the intrinsic trait Hashable
#                   (hir::types::HashClass), read by registration, never by
#                   name. MODE says how a call is admitted:
#                     required        the argument must be Hashable, like a
#                                     parameter declared `x: Hashable`
#                                     (the private table hash): TRAIT-NOT-
#                                     SATISFIED otherwise, and the call never
#                                     fails (native lowering's total op)
#                     checked         an argument statically known not to be
#                                     Hashable (a function, a struct with a
#                                     function field) is TRAIT-NOT-SATISFIED;
#                                     a Hashable one makes the call total; a
#                                     statically unknown one (any) is hashed
#                                     dynamically and may still fail with
#                                     EQUALITY (the public `hash`)
#   measures        "" or {FAMILY PARAM K}: the Int the native returns is
#                   exactly the value of parameter PARAM of the scalar-
#                   refinement family FAMILY (hir/refinements.tcl) of its
#                   argument K -- std::list::length measures {List length 0}
#                   (LIST-CARDINALITY-REFINEMENTS.md). Read by registration,
#                   never by name: the Range of a call whose argument's
#                   static type states the fact is that one value
#                   (hir/range.tcl, hir/completions.tcl), and an equality
#                   of the call with an exactly known Int refines the
#                   argument on the branch where it holds (hir/refine.tcl).
#   keepsLength     0 | 1 (default 0): the operation mutates its receiver
#                   (ownership role `place`) without changing its length --
#                   it replaces elements in place (a swap, a set, a copy into
#                   an array) and never adds or removes one, whether it
#                   succeeds or fails. Static analyses that track a mutable
#                   collection's length (hir/cardinality.tcl) read it by
#                   registration, never by name; a mutating operation that
#                   does not say so may change the length.
#   dropForm        "" or {NAME AT}: the operation's element-dropping variant
#                   NAME, which takes the element drop descriptor as an extra
#                   last argument, so that the elements the operation removes,
#                   displaces or fails to place are released by the static
#                   drop glue (hir/mutvec.tcl writes it for an operation whose
#                   element type is affine). AT is the argument whose static
#                   type holds the element type (a collection), or `result`
#                   (the call's own type, a constructor's).
#   elementPlace    0 | 1 (default 0): the call is the *place* of its
#                   receiver's element at the index (argument 1) -- never a
#                   value of its own (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md,
#                   "Element places"). Its receiver (observed) must be a place
#                   of the installed context's storage, and the call is only
#                   ever a step of such a place: projected further, observed,
#                   or read out when what it holds is unrestricted; an affine
#                   element it holds is never copied out of it. Static analyses
#                   (hir/affine.tcl, hir/mutvec.tcl) read it by registration,
#                   never by name; at run time it is the element read.
#   fold            "" or a command prefix deciding a call whose every
#                   argument is exactly known: `{*}FOLD ARG...` returns
#                   {value V} (the call returns V), {error NAME} (it completes
#                   with the declared error NAME, one of its -errors), or ""
#                   (nothing is decided: the arguments are not the
#                   operation's). It must be the very computation the
#                   implementation performs (core/float.tcl's apply), so a
#                   decided call and a run of it never differ. Static
#                   analyses (hir/completions.tcl, hir/exactvalue.tcl) read
#                   it by registration, never by name.
#   bounds          "" or the bounds checks behind a native's argument-
#                   dependent errors (STDLIB-NAMESPACES.md), stated once here
#                   so static analyses (hir/completions.tcl) read them by
#                   registration, never by name:
#                     index FAMILY C I  IndexNotFound unless the Int
#                                     argument I designates an element of
#                                     sequence argument C (0 <= I < N)
#                     extents V       LayoutExtentMismatch unless every
#                                     fixed array of a layout the value
#                                     argument V is written into gets a List
#                                     of exactly its extent (FIXED-LAYOUT-
#                                     ARRAYS.md); the arrays are the layout
#                                     role's (the emitted LayoutStruct's
#                                     layout, a write's designated field)
#                     slices SLICE...  each SLICE {FAMILY C START END},
#                                     checked in order by checkSlice:
#                                     LowerUnderrun/UpperOverrun unless 0 <=
#                                     START <= END <= N
#                   FAMILY is the kind of sequence argument C (list,
#                   mutarray or str; N its length or capacity; narray a live
#                   fixed array, N the extent its static type states,
#                   FIXED-LAYOUT-ARRAYS.md); START and
#                   END are each an argument index, {const K} or {sum A B}
#                   (the sum of arguments A and B). A native with bounds
#                   declares exactly the errors they produce.
#   runtime         what a native implementation of the operation needs from
#                   a runtime, beyond bare machine operations on values of
#                   known kinds (a sorted list of tags from runtimeTags
#                   below). Pure metadata for static analysis (hir/aot.tcl):
#                   the operation is fully known, but lowering it to native
#                   code needs these helpers. It never changes semantics.
#   resultShape     "" or how the result is built from the arguments, for
#                   static analyses that track what aggregates contain
#                   (hir/types.tcl, aggregate facts). Pure metadata, like
#                   runtime; the result type still states the contract:
#                     elements        a list of the arguments, in order
#                     element L I     the element of list argument L at the
#                                     index given by Int argument I
#                     append L V      a list of list argument L's elements
#                                     followed by argument V
#                     immutable-set L an ImmutableSet of list argument L's
#                                     element type (MINIMAL-IMMUTABLE-SET.md)
#                     mutarray-element A  argument A is a MutableArray[T]:
#                                     the result is a T (PARAMETERIZED-
#                                     MUTABLEARRAY.md); a raw `mutarray`
#                                     argument keeps the declared result
#                     mutvec-from-list L  argument L is a List[T]: the
#                                     result is a MutableVector[T]
#                                     (MUTABLE-VECTOR.md)
#                     mutvec-element V    argument V is a MutableVector[T]:
#                                     the result is a T
#                     mutvec-to-list V    argument V is a MutableVector[T]:
#                                     the result is a List[T]
#                     same A          the result has argument A's own
#                                     static type (mutable_vector#share)
#                     mutarray-create V   argument V is a T: the result
#                                     is a MutableArray[T] (MUTABLE-ARRAY.md)
#                     mutarray-from-list L  argument L is a List[T]: the
#                                     result is a MutableArray[T]
#                     mutarray-generate F argument F is a callable whose
#                                     contract returns T: the result is a
#                                     MutableArray[T]
#                     mutarray-freeze A   argument A is a MutableArray[T]:
#                                     the result is a List[T]; a raw
#                                     `mutarray` argument keeps the declared
#                                     result
#                     named-struct ID   the result is a struct of the
#                                     named declaration ID ("std::abi::x86_64::
#                                     Register64"), resolved lazily in the
#                                     compiling program's struct registry
#                                     (hir/structs.tcl); the declared
#                                     result type when ID is not declared
#                     context-struct I  the result is a struct of the named
#                                     declaration whose identity is argument
#                                     I's String literal (context#load,
#                                     core/contexts.tcl; CONTEXTS.md)
#                     typed NAME LO HI  every element is an Int in LO..HI (a
#                                     fixed fact about the native itself, not
#                                     derived from this call's own arguments);
#                                     additionally NAME-typed iff NAME
#                                     currently resolves, in the compiling
#                                     program's own source-defined-type
#                                     registry, to a type whose domain
#                                     provably admits every value in LO..HI
#                                     (hir::range::ProvesType) -- never merely
#                                     because NAME resolves at all
#                                     (SYMBOLIC-TYPE-IDENTITY.md)
#   imprint         "" or the native's imprint signature (hir/imprint.tcl,
#                   C-ABI-TYPES.md "Imprinting"): {vars {T...} params {P...}
#                   result R}, P and R static HIR types (hir/types.tcl) in
#                   which {imprint T} stands for a variable. The one
#                   description of the signature for typing: what an
#                   argument establishes, what a call-site imprint
#                   `name[TYPE](...)` supplies, the precise parameter types
#                   an argument is held to and the result type. A Botlish
#                   function's imprint signature is its declared types;
#                   both are bound and checked by the same code.
#                   -param-types/-result-type stay the run-time kind
#                   contract.
#   foreign         "" or the native's foreign call contract (core/cabi.tcl,
#                   C-POINTER-BORROWING.md): {vars {T...} params {P...}
#                   result R}, one P per parameter -- {name N type T} for a
#                   C value, plus {access read|write|unknown escape
#                   proven-noescape|declared-noescape|captures|unknown} for
#                   a C pointer -- and R the C result (or unit). The static
#                   signature of the call (its types, like an -imprint's,
#                   which -foreign derives when it has variables) and, per
#                   pointer parameter, whether a std::abi::bytes::Bytes or
#                   std::abi::bytes::MutableBytes may be exposed to it for the
#                   call (hir/borrow.tcl). The implementation is entered
#                   through core::cabi::ForeignBoundary, which models the
#                   exposures on the Tcl backends.
#   extern          "" or, for an `extern c fn` declaration (C-FFI.md), the
#                   declaration's identity: {key KEY namespace NS name NAME
#                   symbol SYMBOL abi {params {KIND...} result KIND}} -- KEY
#                   its Botlish qualified name (the entry program's bare),
#                   SYMBOL the native link symbol, every KIND the C ABI
#                   transport class of a parameter or the result (i8 u8 i16
#                   u16 i32 u32 i64 u64 ptr, void for the result). Such a
#                   native is registered per compilation by hir/foreign.tcl
#                   under the internal name extern#KEY (`#` no source spells),
#                   with a -foreign contract and an implementation that
#                   refuses to run (NATIVE-ONLY): only the native backend
#                   makes the C call.
#   resultRange     "" (nothing known) or a fact about every Int result, for
#                   hir/range.tcl's representation analysis and
#                   hir/completions.tcl's completion proofs, which both read
#                   it through hir::range::RegisteredRange. Pure metadata,
#                   like runtime and resultShape: a guarantee the
#                   implementation actually upholds, never a guess from the
#                   native's name.
#                     nonneg          the result is always >= 0
#                     interval LO HI  the result is always in LO..HI (two
#                                     integers, LO <= HI; stored in decimal):
#                                     a bound of the operation itself, e.g.
#                                     std::char::scalar_value's Unicode scalar
#                                     values or hash's 61-bit mask
#                     collection-length   the result is always a String or
#                                     List length: >= 0 and, by the runtime's
#                                     own enforced construction limit
#                                     (native/src/runtime/ops.rs), also <=
#                                     hir::range's small-Int maximum -- never
#                                     merely assumed (see MAX_COLLECTION_LENGTH
#                                     there)
#   mutationStable  0 | 1 (default 0): the result is fixed by the argument
#                   values and by nothing an in-place mutation changes -- a
#                   call through the same binding gives the same result
#                   before and after any mutation of the value it holds
#                   (a MutableArray's capacity, fixed when the array is
#                   made) -- and the call reads no execution environment.
#                   Pure metadata, a guarantee the implementation upholds,
#                   independent of -context-free (which also governs what
#                   may be evaluated before run time or folded into static
#                   storage, and which no reader of a mutable value is):
#                   hir/induction.tcl reads it to know a call has one value
#                   for a whole recursion.
#
# OWNERSHIP ROLES (-ownership; AFFINE-VALUES.md, MUTABLE-ARRAY.md). Each role
# says what the operation does with the argument's value, so the one question
# the ownership discipline asks of an affine argument -- does it move, stay
# owned, or would it be duplicated or lost? -- is answered from metadata:
#
#   observe    read only; nothing of it is retained. An affine argument stays
#              owned by its source, which must be an owner (a binding or a
#              place path): a temporary is AFFINE-TEMPORARY-UNSUPPORTED.
#   place      the receiver place, mutated in place (push, set, swap, a
#              copy's destination, a drain step); its owner keeps owning it.
#   move       moved once into the operation: stored in its result or in its
#              receiver (push's element, swap's replacement, from_list's
#              List, a consuming loop's domain).
#   element    a List literal's element (`list`): moved into the List when
#              the List's type is affine, else an erasure.
#   repeat     logically duplicated: the operation places one value in many
#              slots (create's value). An affine argument is rejected
#              (AFFINE-DUPLICATION-UNSUPPORTED): there would be several
#              owners. An unrestricted one is copied logically, never deeply.
#   factory    a callable invoked once per element the operation makes
#              (generate's factory): each call's result moves into its own
#              slot. The callable itself is only called, never stored; an
#              affine callable (which could be called only once) is rejected.
#   copy-out   a container whose elements the operation reads out while it
#              keeps owning them (at, freeze, a copy's source, a snapshot):
#              an affine container is rejected (AFFINE-ELEMENT-COPY-OUT, or
#              AFFINE-LIST-OPERATION-UNSUPPORTED for a List).
#   equality   compared or hashed: an affine argument is rejected
#              (AFFINE-EQUALITY-UNSUPPORTED).
#   resume     a coroutine handle resumed behind its owner (consume and
#              replace: the owner keeps owning it).
#   message    a resume message: moved into the coroutine.
#   release    a release the compiler wrote (coroutine#release, affine#drop):
#              never a use to check.
#   erase      (the default) the argument becomes an untyped value the
#              operation may keep or copy: an affine argument is rejected
#              (AFFINE-ERASURE-UNSUPPORTED).
#
# Refinement rules are flat lists of ARG-INDEX TYPE pairs, e.g. {0 int}
# ("argument 0 is an int") or {0 {refined int {Byte}}}. The evaluator never
# special-cases a native by name; it only consults this metadata (see
# refine.tcl). (A Botlish function's own refinement rules are its proof
# contract, `proves`, REFINEMENT-VALUES.md -- the same shape, from source.)
#
# Declared types are a *contract*. After every call the reference runtime
# asserts that each argument satisfied its parameter type and that the
# result satisfies the result type, so a native cannot claim to return, say,
# a Byte while returning 300. Types are accepted in any form type.tcl
# understands and stored in canonical form.

namespace eval core::native {
    variable registry [dict create]
    # Runtime requirement tags (-runtime):
    #   bigint               arbitrary-precision integer arithmetic or
    #                        comparison (a small-integer fast path still needs
    #                        an overflow check and a big-integer fallback)
    #   string-alloc         allocates a new string
    #   list-alloc           allocates a new list
    #   result-alloc         allocates a new Result
    #   char-index           counts or indexes a string by character, not byte
    #   range-check          may raise RANGE for an index outside a value
    #   structural-equality  compares values of any kinds structurally
    #   mutarray-alloc       allocates a new MutableArray, or a List by
    #                        finalizing one (std::mutable_array::freeze)
    #   mutarray-mutate      mutates a MutableArray's slots in place
    #                        (std::mutable_array::set, std::mutable_array::copy)
    #   hash                 computes a semantic hash of a value, recursing
    #                        into any List/Result payload the way
    #                        structural-equality does (core/hashing.tcl) --
    #                        bootstrap native, candidate for stdlib
    #                        replacement: see core/hashing.tcl's header
    #   set-alloc            allocates a new ImmutableSet (core/immutableset.tcl)
    #   process-argv         reads the process argument snapshot of the run
    #                        (core/process.tcl; ARGV.md)
    #   bytestore-alloc      allocates a new owned byte storage (core/bytestore.tcl;
    #                        ABI-BYTES.md)
    #   raw-address          produces the machine address of an owned byte
    #                        storage's payload (std::abi::x86_64::from_bytes,
    #                        std::abi::aarch64::from_bytes; native only,
    #                        ABI-BYTES.md)
    #   mutvec-alloc         allocates a new MutableVector header
    #                        (core/mutvec.tcl; MUTABLE-VECTOR.md)
    #   mutvec-mutate        mutates a MutableVector header in place (push,
    #                        pop, take, swap, clear)
    #   float-alloc          makes a floating-point value, which the native
    #                        runtime keeps in a heap object of its own
    #                        (core/float.tcl; FLOAT64-MILESTONE-1.md)
    #   table-hash           computes the private collision-hardened hash of
    #                        a value under the runtime's hidden process key
    #                        (core/hashing.tcl's tableHash, ops.rs's
    #                        rt_table_hash; HASHABLE-AND-KEYED-HASH.md)
    #   raw-syscall          executes a raw Linux kernel transition (x86-64's
    #                        `syscall`, AArch64's `svc #0`) with unknown
    #                        effects (core/linuxabi.tcl;
    #                        LINUX-X86-64-SYSCALL.md)
    variable runtimeTags {bigint string-alloc list-alloc result-alloc char-index
        range-check structural-equality mutarray-alloc mutarray-mutate hash set-alloc
        process-argv raw-syscall bytestore-alloc raw-address mutvec-alloc mutvec-mutate float-alloc
        table-hash}
    # The -ownership roles (OWNERSHIP ROLES above).
    variable ownershipRoles {observe place move element repeat factory copy-out equality resume message release erase}
    # NAME -> 1: the errors the runtime itself declares, visible in every
    # program like a root native and never part of a program's own `error`
    # declarations (hir/errordecls.tcl). Only a native's -errors may name one;
    # native/lower.tcl's ErrorId gives each a fixed NIR id from its index.
    variable builtinErrors [dict create]
    # NAME -> {FIELD TYPE ...}: the payload a builtin error carries
    # (ERROR-PAYLOADS.md; declareErrorPayload), its fields in declaration
    # order, each TYPE a HIR type. A builtin error without an entry is
    # payload-free, as every builtin error but NonFiniteFloat is.
    variable builtinPayloads [dict create]
    # NAME -> {CASE ...}: the enums the runtime itself declares (ENUMS.md;
    # declareEnum), visible in every program under their bare names like the
    # builtin errors, and never declarable by a program. The types of
    # builtin error payloads' fields (NonFiniteFloat's NonFiniteResult).
    variable builtinEnums [dict create]
    # NS -> 1: the intrinsic namespaces the compiler provides as direct
    # modules (DIRECT-MODULES.md): their members expose raw, ambient
    # authority, so a call into one is a direct edge of the calling module.
    # The trusted provider's equivalent of a source file's `direct module`;
    # declared by declareDirectNamespace beside the namespace's natives,
    # never derived from a name.
    variable directNamespaces [dict create]
    # NS -> 1: the intrinsic namespaces internal to the language
    # implementation (HASHABLE-AND-KEYED-HASH.md, "Visibility boundary"):
    # only a standard library module may import one (surface/modules.tcl's
    # CheckImports, INTERNAL-NAMESPACE), and no code may take a member as a
    # value (hir::resolve's INTERNAL-INTRINSIC-VALUE). Declared by
    # declareInternalNamespace beside the namespace's natives, never derived
    # from a name.
    variable internalNamespaces [dict create]
    # The members of standard-library Botlish modules internal to the
    # standard library (declareInternalMember): NS::NAME -> 1.
    variable internalMembers [dict create]
}

# Declares the intrinsic namespace NS (one with qualified root natives,
# qualifiedMembers) a direct module: a module whose callables expose raw,
# ambient authority (DIRECT-MODULES.md). Module granular, like a source
# file's `direct module`: every member of NS is direct, none is exempt.
proc core::native::declareDirectNamespace {ns} {
    variable directNamespaces
    if {[qualifiedMembers $ns] eq {}} {
        error "core::native::declareDirectNamespace: \"$ns\" has no intrinsic members (register its natives first)"
    }
    dict set directNamespaces $ns 1
}

# Removes NS's direct declaration again: tests that declare a probe
# namespace direct (tests/direct-modules.test) undo it, as they unregister
# their probe natives. Nothing in the compiler undeclares one.
proc core::native::undeclareDirectNamespace {ns} {
    variable directNamespaces
    dict unset directNamespaces $ns
}

# 1 if the intrinsic namespace NS is declared direct (declareDirectNamespace).
proc core::native::isDirectNamespace {ns} {
    variable directNamespaces
    return [dict exists $directNamespaces $ns]
}

# The intrinsic namespaces declared direct, sorted.
proc core::native::directNamespaces {} {
    variable directNamespaces
    return [lsort [dict keys $directNamespaces]]
}

# Declares the intrinsic namespace NS internal to the language implementation:
# its members are callable by the standard library's modules only, and only
# called, never taken as a value. Namespace granular, like
# declareDirectNamespace.
proc core::native::declareInternalNamespace {ns} {
    variable internalNamespaces
    if {[qualifiedMembers $ns] eq {}} {
        error "core::native::declareInternalNamespace: \"$ns\" has no intrinsic members (register its natives first)"
    }
    dict set internalNamespaces $ns 1
}

# Declares the standard library module of namespace NS (a stdlib/ Botlish
# module, no intrinsic namespace) internal to the standard library, as
# declareInternalNamespace an intrinsic one: only a standard library module
# may import it or name its members (surface/modules.tcl's CheckInternal,
# INTERNAL-NAMESPACE). Its functions are ordinary Botlish, which the
# standard library's own modules share: std::ordered_table, the engine of
# std::mutable_map and std::mutable_set (ORDERED-MUTABLE-MAP-SET.md).
proc core::native::declareInternalModule {ns} {
    variable internalNamespaces
    if {[qualifiedMembers $ns] ne {}} {
        error "core::native::declareInternalModule: \"$ns\" is an intrinsic namespace (declareInternalNamespace)"
    }
    dict set internalNamespaces $ns 1
}

# Declares the function NAME (NS::MEMBER) of the standard library module of
# namespace NS internal to the standard library, as declareInternalModule a
# whole module: only a standard library module may name it
# (surface/modules.tcl's CheckInternal, INTERNAL-NAMESPACE), and its
# declaration is `nomethod`, so no method call reaches it either. The
# representation access one collection's module gives another's
# (std::mutable_set's table_of and of_table, which std::mutable_map's order
# operations read and build a MutableSet's table with:
# PROVEN-COLLECTION-REORDERING.md); nothing the generated reference or the
# standard-library census lists as API.
proc core::native::declareInternalMember {name} {
    variable internalMembers
    dict set internalMembers $name 1
}

# 1 if NAME (NS::MEMBER) is an internal member (declareInternalMember).
proc core::native::isInternalMember {name} {
    variable internalMembers
    return [dict exists $internalMembers $name]
}

# 1 if the intrinsic namespace NS is internal (declareInternalNamespace).
proc core::native::isInternalNamespace {ns} {
    variable internalNamespaces
    return [dict exists $internalNamespaces $ns]
}

# 1 if native NAME is a member of an internal namespace.
proc core::native::isInternal {name} {
    set ns [namespaceOf $name]
    return [expr {$ns ne "" && [isInternalNamespace $ns]}]
}

# The intrinsic namespaces declared internal, sorted.
proc core::native::internalNamespaces {} {
    variable internalNamespaces
    return [lsort [dict keys $internalNamespaces]]
}

# The intrinsic namespace of the qualified root native NAME (the part of its
# registered name before the last "::": std::linux::abi::x86_64::syscall is a
# member of std::linux::abi::x86_64, qualifiedMembers' membership), "" for a native in no namespace.
proc core::native::namespaceOf {name} {
    if {[string match extern#* $name]} {
        # An extern c fn's native (C-FFI.md) is a member of the module that
        # declares it.
        set name [string range $name 7 end]
    }
    set cut [string last :: $name]
    if {$cut <= 0} {
        return ""
    }
    return [string range $name 0 [expr {$cut - 1}]]
}

proc core::native::register {name args} {
    variable registry
    if {$name eq ""} {
        error "core::native::register: empty name"
    }
    if {[dict exists $registry $name]} {
        error "core::native::register: native \"$name\" is already registered"
    }
    if {[llength $args] % 2} {
        error "core::native::register: options must be -option value pairs"
    }
    set options [dict create -impl "" -arity "" -refines-true {} -refines-false {} \
        -param-types "" -result-type any -tests-type "" -runtime {} -result-shape {} -result-range {} \
        -context-free 0 -errors {} -bounds {} -nomethod 0 -completion 0 -ownership {} -errors-from {} \
        -result-length {} -keeps-length 0 -drop-form {} -layout {} -imprint {} -foreign {} -extern {} \
        -mutation-stable 0 -fold {} -measures {} -hashing {} -element-place 0]
    foreach {option value} $args {
        if {![dict exists $options $option]} {
            error "core::native::register: unknown option \"$option\""
        }
        dict set options $option $value
    }
    set impl [dict get $options -impl]
    if {$impl eq ""} {
        error "core::native::register: -impl is required for \"$name\""
    }
    set arity [dict get $options -arity]
    if {$arity ne "*" && !([string is digit -strict $arity])} {
        error "core::native::register: -arity must be a non-negative integer or *"
    }
    if {[dict get $options -context-free] ni {0 1}} {
        error "core::native::register: -context-free of \"$name\" must be 0 or 1"
    }
    if {[dict get $options -nomethod] ni {0 1}} {
        error "core::native::register: -nomethod of \"$name\" must be 0 or 1"
    }
    if {[dict get $options -completion] ni {0 1}} {
        error "core::native::register: -completion of \"$name\" must be 0 or 1"
    }
    if {[dict get $options -keeps-length] ni {0 1}} {
        error "core::native::register: -keeps-length of \"$name\" must be 0 or 1"
    }
    if {[dict get $options -mutation-stable] ni {0 1}} {
        error "core::native::register: -mutation-stable of \"$name\" must be 0 or 1"
    }
    set testsType [dict get $options -tests-type]
    if {$testsType ne ""} {
        set testsType [CanonicalType $name -tests-type $testsType]
        if {$arity ne "1"} {
            error "core::native::register: a -tests-type native must have -arity 1"
        }
        foreach typeName [core::type::evidenceOf $testsType] {
            if {[core::type::isRefinement $typeName]} {
                error "core::native::register: -tests-type of \"$name\" names the refinement type $typeName: its membership is proven by its owner's proof-producing functions, never tested at run time"
            }
        }
        if {[dict get $options -param-types] eq ""} {
            dict set options -param-types any
        }
        set param [CanonicalType $name -param-types [lindex [dict get $options -param-types] 0]]
        if {$param ne "any" && [llength $param] != 1} {
            error "core::native::register: the parameter type of -tests-type native \"$name\" must be any or a primitive kind"
        }
        if {![core::type::subtype $testsType $param]} {
            error "core::native::register: -tests-type [core::type::show $testsType] of \"$name\" is not a subtype of its parameter type $param"
        }
        if {[dict get $options -result-type] ni {any bool}} {
            error "core::native::register: a -tests-type native returns bool"
        }
        dict set options -result-type bool
        # A type test refines its argument to the type when it returns true.
        set rules [dict get $options -refines-true]
        if {![dict exists $rules 0]} {
            dict set options -refines-true [concat $rules [list 0 $testsType]]
        }
    }
    foreach option {-refines-true -refines-false} {
        set rules [dict get $options $option]
        if {[llength $rules] % 2} {
            error "core::native::register: $option must be ARG-INDEX TYPE pairs"
        }
        set canonical {}
        foreach {index type} $rules {
            if {![string is digit -strict $index]} {
                error "core::native::register: bad $option argument index \"$index\""
            }
            lappend canonical $index [CanonicalType $name $option $type]
        }
        dict set options $option $canonical
    }
    set paramTypes {}
    foreach type [dict get $options -param-types] {
        lappend paramTypes [CanonicalType $name -param-types $type]
    }
    if {$arity ne "*" && $paramTypes ne "" && [llength $paramTypes] != $arity} {
        error "core::native::register: -param-types of \"$name\" must list $arity type(s)"
    }
    variable runtimeTags
    foreach tag [dict get $options -runtime] {
        if {$tag ni $runtimeTags} {
            error "core::native::register: unknown -runtime tag \"$tag\" for \"$name\" (known: $runtimeTags)"
        }
    }
    set shape [dict get $options -result-shape]
    if {$arity eq "*"} {
        set count ""
    } else {
        set count $arity
    }
    if {![ValidShape $shape $count]} {
        error "core::native::register: bad -result-shape \"$shape\" for \"$name\""
    }
    set range [ValidResultRange [dict get $options -result-range]]
    if {$range eq "bad"} {
        error "core::native::register: bad -result-range \"[dict get $options -result-range]\" for \"$name\""
    }
    variable builtinErrors
    set errors [lsort -unique [dict get $options -errors]]
    foreach error $errors {
        if {![dict exists $builtinErrors $error]} {
            error "core::native::register: -errors of \"$name\" names \"$error\", which is not a declared builtin error"
        }
    }
    variable ownershipRoles
    set ownership [dict get $options -ownership]
    foreach role $ownership {
        if {$role ni $ownershipRoles} {
            error "core::native::register: unknown -ownership role \"$role\" for \"$name\" (known: $ownershipRoles)"
        }
    }
    if {$ownership ne "" && ($arity eq "*" ? [llength $ownership] == 0 : [llength $ownership] != $arity)} {
        error "core::native::register: -ownership of \"$name\" must list [if {$arity eq "*"} {string cat "its leading"} else {set arity}] role(s)"
    }
    if {[dict get $options -keeps-length] && [lindex $ownership 0] ne "place"} {
        error "core::native::register: -keeps-length of \"$name\" needs a receiver it mutates (-ownership role place for argument 0)"
    }
    set errorsFrom [dict get $options -errors-from]
    if {$errorsFrom ne "" && (![string is digit -strict $errorsFrom] || $arity eq "*" || $errorsFrom >= $arity
            || ![dict get $options -completion])} {
        error "core::native::register: -errors-from of \"$name\" must be the index of an argument of a -completion native"
    }
    set measures [dict get $options -measures]
    if {$measures ne "" && ([llength $measures] != 3 || ![string is digit -strict [lindex $measures 2]]
            || $arity eq "*" || [lindex $measures 2] >= $arity || [dict get $options -result-type] ne "int")} {
        error "core::native::register: bad -measures \"$measures\" for \"$name\" (FAMILY PARAM K, an Int result)"
    }
    set length [dict get $options -result-length]
    if {$length ne "" && $length ne "args" && ([llength $length] ni {2 3} || [lindex $length 0] ni {int list extent path}
            || ![string is digit -strict [lindex $length 1]] || $arity eq "*" || [lindex $length 1] >= $arity
            || ([llength $length] == 3 && ([lindex $length 0] ne "list" || ![string is digit -strict [lindex $length 2]])))} {
        error "core::native::register: bad -result-length \"$length\" for \"$name\""
    }
    set dropForm [dict get $options -drop-form]
    if {$dropForm ne "" && ([llength $dropForm] != 2 || !([lindex $dropForm 1] eq "result"
            || ([string is digit -strict [lindex $dropForm 1]] && $arity ne "*" && [lindex $dropForm 1] < $arity)))} {
        error "core::native::register: bad -drop-form \"$dropForm\" for \"$name\""
    }
    set layout [dict get $options -layout]
    if {$layout ne "" && ![ValidLayoutRole $layout $arity]} {
        error "core::native::register: bad -layout \"$layout\" for \"$name\""
    }
    set foreign [dict get $options -foreign]
    if {$foreign ne ""} {
        # A foreign call contract (core/cabi.tcl) is the native's static
        # signature: its imprint signature, when it has variables, is derived
        # from it (one description, never two), and the implementation is
        # entered through the exposure boundary.
        set foreign [core::cabi::NormalizeForeign $name $foreign $arity]
        if {[dict get $options -imprint] ne ""} {
            error "core::native::register: \"$name\" has a -foreign contract, which is its signature: no separate -imprint"
        }
        if {[dict get $foreign vars] ne ""} {
            dict set options -imprint [dict create vars [dict get $foreign vars] \
                params [lmap p [dict get $foreign params] {dict get $p type}] result [dict get $foreign result]]
        }
        set impl [list core::cabi::ForeignBoundary $name $impl]
    }
    set imprint [dict get $options -imprint]
    if {$imprint ne "" && ([catch {dict size $imprint}] || [lsort [dict keys $imprint]] ne {params result vars}
            || [llength [dict get $imprint vars]] == 0 || $arity eq "*"
            || [llength [dict get $imprint params]] != $arity)} {
        error "core::native::register: bad -imprint \"$imprint\" for \"$name\""
    }
    set hashing [dict get $options -hashing]
    if {$hashing ne "" && ([llength $hashing] != 2 || ![string is digit -strict [lindex $hashing 0]]
            || $arity eq "*" || [lindex $hashing 0] >= $arity || [lindex $hashing 1] ni {required checked})} {
        error "core::native::register: bad -hashing \"$hashing\" for \"$name\" (K required|checked)"
    }
    set elementPlace [dict get $options -element-place]
    if {$elementPlace ni {0 1} || ($elementPlace && ($arity ne "2" || [lindex $ownership 0] ne "observe"
            || [core::type::base [lindex $paramTypes 0]] ni {mutvec mutarray}))} {
        error "core::native::register: bad -element-place \"$elementPlace\" for \"$name\" (1 needs a MutableVector or MutableArray receiver it observes and an index)"
    }
    set bounds [dict get $options -bounds]
    if {$bounds ne "" && ![ValidBounds $bounds $arity $errors]} {
        error "core::native::register: bad -bounds \"$bounds\" for \"$name\" (with -errors {$errors})"
    }
    dict set registry $name [dict create \
        name $name \
        impl $impl \
        arity $arity \
        refinesTrue [dict get $options -refines-true] \
        refinesFalse [dict get $options -refines-false] \
        paramTypes $paramTypes \
        resultType [CanonicalType $name -result-type [dict get $options -result-type]] \
        testsType $testsType \
        runtime [lsort -unique [dict get $options -runtime]] \
        resultShape $shape resultRange $range \
        contextFree [dict get $options -context-free] errors $errors bounds $bounds \
        nomethod [dict get $options -nomethod] completion [dict get $options -completion] \
        ownership $ownership errorsFrom $errorsFrom resultLength $length \
        keepsLength [dict get $options -keeps-length] dropForm $dropForm \
        layout $layout imprint $imprint foreign $foreign extern [dict get $options -extern] \
        mutationStable [dict get $options -mutation-stable] fold [dict get $options -fold] \
        measures $measures hashing $hashing elementPlace $elementPlace]
    return [core::value::native $name]
}

# 1 if ROLE is a valid -layout role (hir/layouts.tcl's "The binary
# operations"; BINARY-LAYOUT.md) for a native of ARITY: KEY VALUE pairs of
#
#   operand K        argument K is the static layout operand
#   query WHAT       the call is the layout's WHAT (length | alignment), a
#                    constant (with operand 0, arity 1)
#   typed {AT FORM}  argument AT's static type is LayoutStruct[L]; the call is
#                    elaborated to a call of root native FORM with L's
#                    descriptor appended
#   input K          argument K is the bytes being imprinted (a std::abi::bytes::
#                    Bytes)
#   op OP            the operation a backend performs with the descriptor
#                    constant of the operand: parse (imprint) or emit; view
#                    (a native view of the pointer argument), load (every
#                    field read through a native view) or field (one field
#                    read, the operand that field's descriptor entry)
#                    (NATIVE-LAYOUT-VIEWS.md)
#   pointer K        argument K is the data pointer a native view reads
#                    through (a std::ffi::c::Ptr[T])
#   viewed {AT FORM} argument AT's static type is NativeView[L]; the call is
#                    elaborated to a call of FORM with L's descriptor
#                    appended (std::binary::load)
#   field K          argument K is one field's descriptor entry (the
#                    internal binary#view_field a view's projection becomes)
#   edited K         argument K is the native edit a store writes through
#                    (a NativeEdit[L]; NATIVE-LAYOUT-WRITES.md)
#   output K         argument K is the std::abi::bytes::MutableBytes a layout
#                    write writes into
#   path K           argument K is the static field designator
#                    (LAYOUT.FIELD..., resolved to its designator constant)
#   value K          argument K is the value written into that field
#   arrayed {AT FORM} argument AT's static type is a live fixed array
#                    (NativeView[array N of E] or NativeEdit[array N of
#                    E]); the call is elaborated to a call of FORM with the
#                    array's descriptor words appended (FIXED-LAYOUT-
#                    ARRAYS.md)
#   array K          argument K is a live array's descriptor words {array N
#                    STRIDE ELEMENT} (the elaborated forms)
#   index K          argument K is the Int index of the element accessed
#
# OP edit (a native edit of the pointer argument), store (one field
# written through an edit), write (one ordinary field written into byte
# storage) and write_foreign (an existing C pointer encoded into a pointer
# field of byte storage) are NATIVE-LAYOUT-WRITES.md's; element (one
# element of a live array read), store_element (one written) and
# load_array (a live array copied into its List) FIXED-LAYOUT-ARRAYS.md's;
# read (the one representation a designator names, imprinted from the
# bytes of `input K`) LAYOUT-UNIONS.md's.
proc core::native::ValidLayoutRole {role arity} {
    if {[catch {llength $role} n] || $n % 2 || ![string is digit -strict $arity]} {
        return 0
    }
    foreach {key value} $role {
        switch -- $key {
            operand - input - pointer - field - edited - output - path - value - array - index {
                if {![string is digit -strict $value] || $value >= $arity} {
                    return 0
                }
            }
            query {
                if {$value ni {length alignment} || $arity != 1} {
                    return 0
                }
            }
            typed - viewed - arrayed {
                if {[llength $value] != 2 || ![string is digit -strict [lindex $value 0]]
                        || [lindex $value 0] >= $arity} {
                    return 0
                }
            }
            op {
                if {$value ni {parse emit view load field edit store write write_foreign element store_element load_array read}} {
                    return 0
                }
            }
            default {
                return 0
            }
        }
    }
    return 1
}

# RANGE as the registry stores it (an interval's bounds in decimal), or
# "bad" if it is not a -result-range value.
proc core::native::ValidResultRange {range} {
    if {$range in {{} nonneg collection-length}} {
        return $range
    }
    if {[catch {llength $range} n] || $n != 3 || [lindex $range 0] ne "interval"} {
        return bad
    }
    lassign $range -> lo hi
    if {![string is entier -strict $lo] || ![string is entier -strict $hi] || $lo > $hi} {
        return bad
    }
    return [list interval [expr {$lo + 0}] [expr {$hi + 0}]]
}

# The declared errors of a native (METADATA its registry entry) that no
# registered bounds check of it produces: a proof that every check holds
# (hir::completions::BoundsProven) rules out only the others.
proc core::native::unboundedErrors {metadata} {
    set produced [switch -- [lindex [dict get $metadata bounds] 0] {
        index   { list IndexNotFound }
        slices  { list LowerUnderrun UpperOverrun }
        extents { list LayoutExtentMismatch }
        default { list }
    }]
    return [lmap error [dict get $metadata errors] {
        if {$error in $produced} continue
        set error
    }]
}

# 1 if BOUNDS is a valid -bounds for a native of ARITY declaring exactly
# ERRORS (sorted).
proc core::native::ValidBounds {bounds arity errors} {
    if {[catch {llength $bounds}] || ![string is digit -strict $arity]} {
        return 0
    }
    set arg [list {a} [list expr "\[string is digit -strict \$a\] && \$a < $arity"]]
    switch -- [lindex $bounds 0] {
        index {
            # (A live fixed array's element access may also fail through a
            # C floating element, NonFiniteFloat: the index check produces
            # only its own IndexNotFound. C-FLOAT-FFI-MILESTONE-1.md.)
            if {[llength $bounds] != 4 || $errors ni {IndexNotFound {IndexNotFound NonFiniteFloat}}} {
                return 0
            }
            lassign $bounds _ family c i
            return [expr {$family in {list mutarray str narray mutvec} && [apply $arg $c] && [apply $arg $i]}]
        }
        extents {
            # {extents V}: LayoutExtentMismatch unless every fixed array the
            # value argument V writes has its layout's extent (FIXED-LAYOUT-
            # ARRAYS.md; hir::layouts::ExtentVerdict reads which arrays from
            # the layout role). The native may declare others too (a byte
            # write's LayoutLengthMismatch): this check produces only its own.
            return [expr {[llength $bounds] == 2 && [apply $arg [lindex $bounds 1]]
                && "LayoutExtentMismatch" in $errors}]
        }
        slices {
            if {[llength $bounds] < 2 || $errors ne {LowerUnderrun UpperOverrun}} {
                return 0
            }
            foreach slice [lrange $bounds 1 end] {
                if {[catch {llength $slice} n] || $n != 4} {
                    return 0
                }
                lassign $slice family c start end
                if {$family ni {list mutarray str} || ![apply $arg $c]} {
                    return 0
                }
                foreach operand [list $start $end] {
                    if {[catch {llength $operand} n]} {
                        return 0
                    }
                    switch -- [lindex $operand 0]/$n {
                        const/2 { set ok [string is entier -strict [lindex $operand 1]] }
                        sum/3   { set ok [expr {[apply $arg [lindex $operand 1]] && [apply $arg [lindex $operand 2]]}] }
                        default { set ok [expr {$n == 1 && [apply $arg $operand]}] }
                    }
                    if {!$ok} {
                        return 0
                    }
                }
            }
            return 1
        }
    }
    return 0
}

# 1 if SHAPE is a valid -result-shape for a native taking COUNT arguments
# ("" for any number).
proc core::native::ValidShape {shape count} {
    if {[catch {llength $shape} length]} {
        return 0
    }
    if {[lindex $shape 0] eq {named-struct}} {
        # {named-struct ID}: the result is a struct of the named declaration
        # ID (std::linux::abi::x86_64::syscall's std::abi::x86_64::Register64), a fixed fact
        # about the native itself. ID is a symbolic declaration identity,
        # resolved lazily by hir::types::ShapeResult against the compiling
        # program's own struct registry (a library struct is declared by a
        # .bot module long after core bootstrap registers the native).
        return [expr {$length == 2 && [regexp {^[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*$} [lindex $shape 1]]}]
    }
    if {$shape in {coroutine-create coroutine-outward coroutine-yield}} {
        # The coroutine operations (core/coroutines.tcl, COROUTINES.md): the
        # result is typed by hir::types::ShapeResult from the program's
        # coroutine analysis (hir/coroutines.tcl) -- a handle's protocol, the
        # outward value of its segment, the resume message of a yield.
        return 1
    }
    if {$shape eq {never}} {
        # {never}: the native never completes normally
        # (context#unreachable, core/contexts.tcl).
        return 1
    }
    if {[lindex $shape 0] eq {layout-struct}} {
        # {layout-struct I}: the result is a LayoutStruct[L] whose layout L
        # is described by argument I's descriptor constant (std::binary::parse,
        # core/binary.tcl; BINARY-LAYOUT.md), resolved by hir::types::
        # ShapeResult.
        return [expr {$length == 2 && [string is digit -strict [lindex $shape 1]]
            && ($count eq "" || [lindex $shape 1] < $count)}]
    }
    if {[lindex $shape 0] eq {view-field}} {
        # {view-field V F}: the static type of the field whose descriptor
        # entry is argument F's constant, read through argument V's static
        # NativeView[L] (binary#view_field, NATIVE-LAYOUT-VIEWS.md), resolved
        # by hir::types::ShapeResult.
        return [expr {$length == 3 && [string is digit -strict [lindex $shape 1]]
            && [string is digit -strict [lindex $shape 2]]
            && ($count eq "" || ([lindex $shape 1] < $count && [lindex $shape 2] < $count))}]
    }
    if {[lindex $shape 0] eq {layout-read}} {
        # {layout-read I}: the copied type of the representation the field
        # designator constant argument I names (std::binary::read,
        # LAYOUT-UNIONS.md), resolved by hir::types::ShapeResult.
        return [expr {$length == 2 && [string is digit -strict [lindex $shape 1]]
            && ($count eq "" || [lindex $shape 1] < $count)}]
    }
    if {[lindex $shape 0] in {native-view native-edit view-struct native-element}} {
        # {native-view I}: the result is a NativeView[L] whose layout L is
        # described by argument I's descriptor constant
        # (std::binary::native::view); {view-struct I}: a LayoutStruct[L], L the
        # layout of argument I's static NativeView[L] type (std::binary::load),
        # or of a live fixed array's the List its copy is;
        # {native-edit I}: a NativeEdit[L] likewise (std::binary::native::edit,
        # NATIVE-LAYOUT-WRITES.md); {native-element I}: the element of
        # argument I's static live fixed array type (std::binary::element,
        # FIXED-LAYOUT-ARRAYS.md). All resolved by hir::types::ShapeResult
        # (NATIVE-LAYOUT-VIEWS.md).
        return [expr {$length == 2 && [string is digit -strict [lindex $shape 1]]
            && ($count eq "" || [lindex $shape 1] < $count)}]
    }
    if {[lindex $shape 0] eq {context-struct}} {
        # {context-struct I}: the result is the installed context of the
        # context-struct declaration whose canonical identity is the String
        # literal of argument I (context#load, core/contexts.tcl): a struct of
        # that named declaration, resolved by hir::types::ShapeResult.
        return [expr {$length == 2 && [string is digit -strict [lindex $shape 1]]
            && ($count eq "" || [lindex $shape 1] < $count)}]
    }
    if {[lindex $shape 0] eq {typed}} {
        # {typed NAME LO HI}: every element of the result List is an Int
        # in LO..HI -- a semantic fact this native's own implementation
        # actually guarantees, independent of any source-defined type --
        # *and*, if the symbolic name NAME currently resolves (in whatever
        # source-defined-type registry a compiling program has loaded) to a
        # type whose own domain admits every value in LO..HI, the result is
        # additionally NAME-typed. NAME is resolved lazily by hir::types::
        # ShapeResult at type-inference time (never here at registration
        # time, since a native like std::str::encode_utf8 is registered once at core
        # bootstrap, long before a compiling program's own `type NAME = ...`
        # declaration -- e.g. stdlib/byte.bot's Byte -- has been parsed; NAME
        # is just a symbolic reference until then). Resolving the name is
        # not, by itself, proof of membership: the same spelling can denote
        # an unrelated or narrower domain in a different compiling program
        # (SYMBOLIC-TYPE-IDENTITY.md) -- ShapeResult verifies LO..HI is
        # actually admissible in whatever NAME resolves to before ever
        # narrowing the result to it, falling back to this native's own
        # plain declared -result-type otherwise. LO and HI are a fixed
        # fact about the native itself, not argument indices, so this whole
        # shape is exempt from the digit-index check below.
        if {$length != 4} { return 0 }
        lassign $shape _ name lo hi
        return [expr {[string is entier -strict $lo] && [string is entier -strict $hi] && $lo <= $hi}]
    }
    if {[lindex $shape 0] eq {element-type}} {
        # {element-type TYPE}: every element of the result List has type
        # TYPE, a fixed fact about the native itself (argv's Strings), not
        # argument indices.
        return [expr {$length == 2 && ![catch {core::type::normalize [lindex $shape 1]}]}]
    }
    set indices [lrange $shape 1 end]
    foreach index $indices {
        if {![string is digit -strict $index] || ($count ne "" && $index >= $count)} {
            return 0
        }
    }
    switch -- [lindex $shape 0] {
        ""       { return [expr {$length == 0}] }
        elements { return [expr {$length == 1}] }
        element - append { return [expr {$length == 3 && $count ne ""}] }
        immutable-set { return [expr {$length == 2}] }
        mutarray-element - mutarray-freeze - mutarray-create - mutarray-from-list - mutarray-generate {
            return [expr {$length == 2 && $count ne ""}]
        }
        mutvec-from-list - mutvec-element - mutvec-to-list - same {
            # MUTABLE-VECTOR.md (hir::types::ShapeResult): from_list's
            # List[T] -> MutableVector[T]; an element read or removal's
            # MutableVector[T] -> T; to_list's MutableVector[T] -> List[T];
            # `same A`: the result has argument A's own type (a share).
            return [expr {$length == 2 && $count ne ""}]
        }
    }
    return 0
}

proc core::native::CanonicalType {name option type} {
    if {[catch {core::type::normalize $type} canonical]} {
        error "core::native::register: $option of \"$name\": $canonical"
    }
    return $canonical
}

# Declares NAME a builtin error (see builtinErrors); declaring one twice is an
# error. Declaration order is the error's index (builtinErrorIndex).
proc core::native::declareError {name} {
    variable builtinErrors
    if {![regexp {^[A-Z][A-Za-z0-9]*$} $name]} {
        error "core::native::declareError: bad error name \"$name\""
    }
    if {[dict exists $builtinErrors $name]} {
        error "core::native::declareError: builtin error \"$name\" is already declared"
    }
    dict set builtinErrors $name [dict size $builtinErrors]
}

proc core::native::isBuiltinError {name} {
    variable builtinErrors
    return [dict exists $builtinErrors $name]
}

# The builtin error names, in declaration order.
proc core::native::builtinErrorNames {} {
    variable builtinErrors
    return [dict keys $builtinErrors]
}

# NAME's index among the builtin errors (declaration order, from 0): the one
# number native/lower.tcl and native/src/runtime/ops.rs agree on.
proc core::native::builtinErrorIndex {name} {
    variable builtinErrors
    return [dict get $builtinErrors $name]
}

# Gives the builtin error NAME the payload FIELDS, {FIELD TYPE ...} in
# declaration order (ERROR-PAYLOADS.md): every failure with it must carry a
# value of that anonymous struct type (failDeclared's PAYLOAD), which a
# handler binds like a source-declared error's (hir/errordecls.tcl answers
# for builtin errors from here).
proc core::native::declareErrorPayload {name fields} {
    variable builtinPayloads
    if {![isBuiltinError $name]} {
        error "core::native::declareErrorPayload: \"$name\" is not a builtin error"
    }
    dict set builtinPayloads $name $fields
}

# The payload fields of the builtin error NAME ({FIELD TYPE ...}), or {} for
# a payload-free one.
proc core::native::builtinPayload {name} {
    variable builtinPayloads
    return [dict getdef $builtinPayloads $name {}]
}

# Declares the builtin enum NAME with the payload-free cases CASES, in
# declaration order (ENUMS.md: a closed nominal sum; its identity is NAME,
# like an entry program's enum). hir/enums.tcl registers it in every
# compilation.
proc core::native::declareEnum {name cases} {
    variable builtinEnums
    if {![regexp {^[A-Z][A-Za-z0-9]*$} $name] || [dict exists $builtinEnums $name]} {
        error "core::native::declareEnum: bad or repeated enum name \"$name\""
    }
    dict set builtinEnums $name $cases
}

# 1 if NAME is a builtin enum (declareEnum).
proc core::native::isBuiltinEnum {name} {
    variable builtinEnums
    return [dict exists $builtinEnums $name]
}

# The builtin enums: NAME -> {CASE ...}, in declaration order.
proc core::native::builtinEnums {} {
    variable builtinEnums
    return $builtinEnums
}

# Called by a native's impl to complete with the declared builtin error NAME
# (one of its own -errors) -- with PAYLOAD, the value of its payload's
# anonymous struct type, when NAME declares one (declareErrorPayload).
# Never returns.
proc core::native::failDeclared {name message {payload ""}} {
    throw [list CORE DECLARED-ERROR $name {*}[if {$payload eq ""} {string cat {}} else {list $payload}]] $message
}

# The one slice rule (STDLIB-NAMESPACES.md), shared by every slicing native
# (std::str::substring, std::mutable_array::copy, std::mutable_array::freeze) and
# mirrored exactly by native/src/runtime/ops.rs's check_slice: the slice
# START..END (END exclusive) of a sequence of N elements is valid iff
# 0 <= START <= END <= N. Its bounds are checked in order -- START against
# 0..N, then END against START..N -- and the first bound outside its
# interval fails with the declared builtin error LowerUnderrun (below it)
# or UpperOverrun (above it). So a negative start, and an end before the
# start (an inverted slice, or a negative count), are LowerUnderrun; a
# start or an end past N is UpperOverrun. NATIVE names the operation in the
# message. START and END are Tcl integers of any size.
proc core::native::checkSlice {native start end n} {
    if {$start < 0} {
        failDeclared LowerUnderrun "$native: slice start $start is below 0"
    }
    if {$start > $n} {
        failDeclared UpperOverrun "$native: slice start $start is above the length $n"
    }
    if {$end < $start} {
        failDeclared LowerUnderrun "$native: slice end $end is below its start $start"
    }
    if {$end > $n} {
        failDeclared UpperOverrun "$native: slice end $end is above the length $n"
    }
}

# 1 if NAME is a registered native.
proc core::native::exists {name} {
    variable registry
    return [dict exists $registry $name]
}

# 1 if NAME is the internal native of an `extern c fn` declaration
# (C-FFI.md): extern#KEY, registered per compilation by hir/foreign.tcl. The
# prefix is reserved for them.
proc core::native::isExtern {name} {
    return [string match extern#* $name]
}

# The name diagnostics print for native NAME: an extern c fn's Botlish
# qualified name (its KEY), else NAME.
proc core::native::displayName {name} {
    if {[string match extern#* $name]} {
        return [string range $name 7 end]
    }
    return $name
}

proc core::native::names {} {
    variable registry
    return [dict keys $registry]
}

# 1 if NAME is a registered native whose name is itself namespace-qualified
# ("std::linux::abi::x86_64::syscall", core/linuxabi.tcl): source spells it exactly like
# a module function, but it is a root native, and no module file defines it
# (surface/modules.tcl, surface/lower.tcl).
proc core::native::isQualifiedNative {name} {
    variable registry
    return [expr {[string first :: $name] > 0 && [dict exists $registry $name]}]
}

# The member names of the qualified root natives that live directly in
# namespace NS (`list` -> at append length; `std::linux::abi::x86_64` -> syscall), sorted:
# the intrinsic members of NS, which no module source may define
# (surface/modules.tcl's DUPLICATE-NATIVE) and which a reference
# NS::MEMBER always denotes. Empty for a namespace with none.
proc core::native::qualifiedMembers {ns} {
    variable registry
    set members {}
    foreach name [dict keys $registry] {
        if {[string first ${ns}:: $name] == 0} {
            set member [string range $name [string length ${ns}::] end]
            if {$member ne "" && [string first :: $member] < 0} {
                lappend members $member
            }
        }
    }
    return [lsort $members]
}

# Removes a previously registered native NAME: tests that register a probe
# native (tests/many-boolean-arguments.test, tests/method-eligible.test)
# remove it again. Nothing in the compiler unregisters a native: a source
# declaration registers none (ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md).
proc core::native::unregister {name} {
    variable registry
    dict unset registry $name
}

proc core::native::metadata {name} {
    variable registry
    if {![dict exists $registry $name]} {
        error "core::native: no native named \"$name\""
    }
    return [dict get $registry $name]
}

# The ownership role (OWNERSHIP ROLES) native NAME's argument INDEX has:
# its -ownership entry (for a native of arity *, the last entry repeats),
# else erase.
proc core::native::ownershipRole {name index} {
    set meta [metadata $name]
    set roles [dict get $meta ownership]
    if {$roles eq ""} {
        return erase
    }
    if {[dict get $meta arity] eq "*" && $index >= [llength $roles]} {
        return [lindex $roles end]
    }
    set role [lindex $roles $index]
    if {$role eq ""} {
        return "erase"
    }
    return $role
}

# OUTCOME is host 1 (predicate returned true) or 0 (returned false).
proc core::native::refinementRules {name outcome} {
    set meta [metadata $name]
    return [dict get $meta [expr {$outcome ? "refinesTrue" : "refinesFalse"}]]
}

proc core::native::invoke {nativeValue argValues} {
    set name [core::value::nativeName $nativeValue]
    set meta [metadata $name]
    set arity [dict get $meta arity]
    if {$arity ne "*" && [llength $argValues] != $arity} {
        core::semanticError ARITY \
            "$name expects $arity argument(s), got [llength $argValues]"
    }
    set testsType [dict get $meta testsType]
    if {$testsType ne ""} {
        set param [lindex [dict get $meta paramTypes] 0]
        if {$param ne "any"} {
            core::value::expect $param [lindex $argValues 0] $name
        }
    }
    if {[dict get $meta completion]} {
        # A native whose implementation runs Botlish code to a boundary of
        # its own and returns that code's completion (core/coroutines.tcl:
        # a coroutine segment ends normally or with the body's own
        # propagate-error, which this call then completes with). Only a
        # normal or propagate-error completion may cross it.
        set completion [{*}[dict get $meta impl] {*}$argValues]
        if {[core::completion::kind $completion] ni {value propagate-error}} {
            throw [list CORE CONTRACT TYPE] \
                "$name: contract violation: it completed with [core::completion::show $completion]"
        }
        return $completion
    }
    set errors [dict get $meta errors]
    if {$errors ne ""} {
        # A native with declared errors completes with propagate-error when
        # its impl signals one of them (failDeclared); any other signal is
        # a contract violation of the native itself.
        try {
            set result [{*}[dict get $meta impl] {*}$argValues]
        } trap {CORE DECLARED-ERROR} {message options} {
            set code [dict get $options -errorcode]
            set error [lindex $code 2]
            if {$error ni $errors} {
                throw [list CORE CONTRACT TYPE] \
                    "$name: contract violation: it signalled the undeclared error \"$error\" (declared: $errors)"
            }
            if {([llength $code] == 4) != ([builtinPayload $error] ne {})} {
                throw [list CORE CONTRACT TYPE] \
                    "$name: contract violation: it signalled \"$error\" [expr {[llength $code] == 4 ? "with a payload the error does not declare" : "without the payload the error declares"}]"
            }
            return [core::completion::propagatingError [core::value::errorId $error {*}[lrange $code 3 end]]]
        }
    } else {
        try {
            set result [{*}[dict get $meta impl] {*}$argValues]
        } on 5 failure {
            # Compiled code's propagate-error (core/completion.tcl's code 5)
            # from an implementation that delivers one: an abandoned
            # coroutine's pending yield (core/coroutines.tcl), which compiled
            # code calls directly and which fails there with this code.
            return [core::completion::propagatingError $failure]
        }
    }
    core::value::check $result
    if {$testsType ne ""} {
        set expected [core::value::bool [core::type::acceptsCanonical $testsType [lindex $argValues 0]]]
        if {$result ne $expected} {
            throw [list CORE CONTRACT TYPE] \
                "$name: contract violation: as a test of [core::type::show $testsType] it must return [core::value::show $expected] for [core::value::show [lindex $argValues 0] 1], returned [core::value::show $result]"
        }
    }
    # The call returned: check the contract it declared.
    set index 0
    foreach type [dict get $meta paramTypes] {
        if {$type ne "any"} {
            core::type::AssertCanonical $type [lindex $argValues $index] "$name argument $index"
        }
        incr index
    }
    if {[dict get $meta resultType] ne "any"} {
        core::type::AssertCanonical [dict get $meta resultType] $result "$name result"
    }
    return [core::completion::normal $result]
}

# The runtime's builtin errors, in their fixed index order
# (builtinErrorIndex): native/lower.tcl's ErrorId and native/src/runtime/
# error.rs's ERR_* constants are both keyed to these indices, so the order
# is declared once, here, never by whichever file happens to load first.
#   InvalidArgumentEncoding  argv() (core/process.tcl; ARGV.md)
#   IndexNotFound            std::list::at, std::mutable_array::at, std::mutable_array::set:
#                            the index does not designate an element
#                            (core/lists.tcl, core/mutarray.tcl;
#                            STDLIB-NAMESPACES.md)
#   LowerUnderrun            a slice bound below its interval (checkSlice)
#   UpperOverrun             a slice bound above its interval (checkSlice)
#   NonFiniteFloat           a floating-point operation whose result is not a
#                            finite number: an overflow, a division by zero
#                            (core/float.tcl; FLOAT64-MILESTONE-1.md), or a
#                            non-finite C double entering Botlish (C-FFI.md)
# The binary errors follow (core/binary.tcl), then UnrepresentableDecimal
# (core/decimal.tcl, which core/core.tcl loads after binary.tcl so that the
# ids existing programs and documents show stay what they were), then
# LengthMismatch (core/listlength.tcl, loaded after decimal.tcl: builtin
# error 10, LIST-CARDINALITY-REFINEMENTS.md), then InvalidIntegerText
# (core/inttext.tcl, loaded after listlength.tcl: builtin error 11,
# NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md).
core::native::declareError InvalidArgumentEncoding
core::native::declareError IndexNotFound
core::native::declareError LowerUnderrun
core::native::declareError UpperOverrun
core::native::declareError NonFiniteFloat

# The standard library's internal Botlish modules (declareInternalModule).
core::native::declareInternalModule std::ordered_table
core::native::declareInternalModule std::io::bytepath
# ... and the internal members of its public ones (declareInternalMember).
core::native::declareInternalMember std::mutable_set::table_of
core::native::declareInternalMember std::mutable_set::of_table
# ... and the native path of a text a platform's path module already proved
# a valid path (WINDOWS-X86-64-MILESTONE-7.md): std::linux::path::native and
# its siblings build it with no second validation.
core::native::declareInternalMember std::linux::fs::of_valid_text
core::native::declareInternalMember std::windows::fs::of_valid_text
core::native::declareInternalMember std::darwin::fs::of_valid_text
# ... and the affine token a platform's File holds (std::io::fs::Owner).
core::native::declareInternalMember std::io::fs::owner
