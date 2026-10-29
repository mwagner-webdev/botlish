# Botlish documentation

Start with the [project overview](../README.md). The
[language and implementation reference](README.md) (formerly the
repository's README) describes the values, the IR, HIR, the surface
language, the backends and the public API in one long document.

Everything else in this directory is a design document: most are the report
of one milestone (what was built, why, and the evidence), some are audits,
censuses or research notes. A document's name is its identity: code
comments, tests and other documents cite them by bare name
(`COROUTINES.md`), and they all live here.

Where a later document changed a decision, the earlier one usually says so
at its top ("Superseded by ...", "Partially superseded by ...").

## Language

### Design principles

- [LANGUAGE-DESIGN-PRINCIPLES.md](LANGUAGE-DESIGN-PRINCIPLES.md) -- the normative principles every language feature keeps: SFIAE (Substitution Failure Is An Error) -- failing a selected operation's obligations is an error, never an invitation to select another operation

### Values, syntax and functions

- [STRUCTS.md](STRUCTS.md) -- structs and struct values
- [STRUCT-DESTRUCTURING.md](STRUCT-DESTRUCTURING.md) -- struct destructuring
- [ENUMS.md](ENUMS.md) -- enums: named, closed, nominal sums of payload-free cases
- [OPAQUE-STRUCTS.md](OPAQUE-STRUCTS.md) -- `opaque struct`: module-owned representation and construction authority
- [MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md](MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md) -- `private` module-local declarations (PRIVATE-ACCESS, PRIVATE-TYPE-ESCAPE; orthogonal to `opaque`) and the `CONTEXT-RESOURCE-ESCAPE` warning on an airlock handing raw pointers, views or open records to other modules; Icy Tower's SDL helpers made private, the census re-run with the warning (completion report)
- [UNICODE-CHAR-LITERALS.md](UNICODE-CHAR-LITERALS.md) -- `UnicodeChar`: a scalar type distinct from Int and String
- [FLOAT64-MILESTONE-1.md](FLOAT64-MILESTONE-1.md) -- `Float64`: finite binary64 numbers, decimal literals, `/`, `NonFiniteFloat`, C `double` (completion report)
- [DECIMAL-ROUNDED-MILESTONE-1.md](DECIMAL-ROUNDED-MILESTONE-1.md) -- `DecimalRounded{minDecimalsPreserved: N}`: the first scalar refinement, a decimal-rounding guarantee proven for constants, observed at its precision, independent of its binary64 representation (completion report)
- [NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md](NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md) -- numbers to and from text: `std::int::to_string`/`from_string` (canonical decimal text, `InvalidIntegerText`), `std::float64::round` (nearest, ties to even), `std::decimal_rounded::to_string` (the guaranteed decimal at its static precision); the Icy Tower and test-framework conversions replaced (completion report)
- [LIST-CARDINALITY-REFINEMENTS.md](LIST-CARDINALITY-REFINEMENTS.md) -- `List[T]{length: N}`: the second scalar refinement, an exact List length as an ordinary List's type fact (the `exactly` order, applied bases, declared-only contracts); minted by literals, loops, guards, layout copies and `std::list::with_length`, consumed by the bounds, extent and range proofs; the migration of every exact-cardinality source, fuzzer, mutants, benchmark (completion report)
- [ELIF.md](ELIF.md) -- `elif`
- [METHOD-SUGAR.md](METHOD-SUGAR.md) -- method-call sugar
- [FLAGS.md](FLAGS.md) -- flag parameters
- [VARIADICS-VERTICAL-SLICE-1.md](VARIADICS-VERTICAL-SLICE-1.md) -- variadic parameters (`variadic xs: List[T]`) and variadic C calls (`extern c fn f(fixed, variadic)`), with the binding generator's `...` (completion report)
- [MULTI-VALUE-RESULTS.md](MULTI-VALUE-RESULTS.md) -- multi-value results: name the parts
- [MUTUAL-RECURSION.md](MUTUAL-RECURSION.md) -- mutual recursion: `mutual:` groups
- [STRUCTURAL-FUNCTION-TYPES.md](STRUCTURAL-FUNCTION-TYPES.md) -- structural function types (`Fn{...}`)
- [STRICT-TYPED-PARAMETERS.md](STRICT-TYPED-PARAMETERS.md) -- strict typed parameters
- [MINIMAL-APPLIED-LIST-TYPES.md](MINIMAL-APPLIED-LIST-TYPES.md) -- minimal applied `List[T]` types
- [M7AA-EMPTY-COLLECTION-AND-APPLIED-TYPE-SEMANTICS.md](M7AA-EMPTY-COLLECTION-AND-APPLIED-TYPE-SEMANTICS.md) -- empty-collection admissibility and applied-type canonicalization

### Loops

- [COLLECTING-LOOPS.md](COLLECTING-LOOPS.md) -- the numeric loop forms (`to`, `through`, `down from`) and lockstep iteration with a proven common cardinality
- [RETURNING-ITERABLE-LOOPS.md](RETURNING-ITERABLE-LOOPS.md) -- `loop x in xs:` as an expression that returns a List
- [PAYLOAD-FREE-BREAK.md](PAYLOAD-FREE-BREAK.md) -- `break` never carries a value
- [LISTLOOP-BREAK-TYPE-SOUNDNESS.md](LISTLOOP-BREAK-TYPE-SOUNDNESS.md) -- the earlier `break VALUE` design (superseded)

### Errors

- [EXPLICIT-ERROR-COMPLETIONS.md](EXPLICIT-ERROR-COMPLETIONS.md) -- `error`, `errors`, `fail` and handlers
- [STATIC-COMPLETION-PROOFS.md](STATIC-COMPLETION-PROOFS.md) -- provable success needs no handler, provable failure is a compile-time error
- [ERROR-PAYLOADS.md](ERROR-PAYLOADS.md) -- errors with a statically known named-field payload; module-qualified error identity
- [ERROR-IDENTITY-AND-COMPLETION-SOUNDNESS.md](ERROR-IDENTITY-AND-COMPLETION-SOUNDNESS.md) -- two correctness repairs to error identity and completions
- [VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md](VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md) -- calls through a structural `Fn` type are bounded by its checked contract
- [TYPED-CALLABLE-ESCAPE-SOUNDNESS.md](TYPED-CALLABLE-ESCAPE-SOUNDNESS.md) -- typed-callable escape soundness

### Proofs, refinements and integer domains

- [REFINEMENT-VALUES.md](REFINEMENT-VALUES.md) -- `refined type` and `proves`
- [SOURCE-DEFINED-INTEGER-DOMAINS.md](SOURCE-DEFINED-INTEGER-DOMAINS.md) -- `type Byte = Int in 0..255`
- [BYTE-NIBBLE-BIT-ARITHMETIC.md](BYTE-NIBBLE-BIT-ARITHMETIC.md) -- scalar domains and typed bit arithmetic: `Byte`, `Nibble`, `LowNibble`, `HighNibble`
- [ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md](ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md) -- no type is callable
- [CROSS-MODULE-REFINED-SIGNATURES.md](CROSS-MODULE-REFINED-SIGNATURES.md) -- cross-module refined signatures
- [EXACT-VALUE-FACTS.md](EXACT-VALUE-FACTS.md) -- exact constants and value-fact propagation
- [INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md](INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md) -- intrinsic function contract inference

### Abstraction: traits, contexts and modules

- [TRAITS.md](TRAITS.md) -- traits: eager structural views, monomorphized away
- [HASHABLE-AND-KEYED-HASH.md](HASHABLE-AND-KEYED-HASH.md) -- the intrinsic trait `Hashable` (witnesses the language supplies), total hashing and equality, and the private keyed table hash
- [TRAIT-CONSTRAINED-IMPRINTED-TYPES.md](TRAIT-CONSTRAINED-IMPRINTED-TYPES.md) -- parameterized structs (`struct Pair[A, B]:`) and trait-constrained type slots (`struct Map[K satisfies Hashable, V]:`): applications validated by ordinary trait satisfaction, imprinting that establishes a slot's obligation without replacing the variable, total hashing and equality of a constrained key, the typed-storage probe answering CO-3 (completion report)
- [CONTEXTS.md](CONTEXTS.md) -- contexts: static execution-environment dependencies
- [CONTEXT-TRAITS.md](CONTEXT-TRAITS.md) -- context traits: portable I/O and textual paths
- [CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md](CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md) -- an installed context owns its affine members (C pointers, coroutines, vectors of them): installation moves the value in, a context parameter is a place of that state (observed where it is stored, never copied out: `AFFINE-CONTEXT-COPY-OUT`), element places (`std::mutable_vector::element`), pointer and view words as native slot leaves; Icy Tower's SDL airlock keeps its pointers in the context, the 56-byte handle record gone (completion report)
- [IMPORTS.md](IMPORTS.md) -- imports: explicit namespace dependencies
- [DIRECT-MODULES.md](DIRECT-MODULES.md) -- direct modules: raw authority acknowledged at the module boundary (`direct module`), mediated by module-owned contexts
- [STD-NAMESPACE.md](STD-NAMESPACE.md) -- the standard library under one compiler-owned root `std`, rooted `::` paths, local modules beside it
- [BOT-MODULES-MILESTONE-1.md](BOT-MODULES-MILESTONE-1.md) -- package-scoped modules: packages installed under `.bot_modules`, downward-only resolution (no consumer, sibling or ancestor search), a package claiming its root namespace in its owner's scope, package-instance identity (`physics/geometry::Point`) through every backend, the cache and the compiler service; the SDL3 binding as a package and a reusable SDL3 airlock package (completion report)
- [STDLIB-NAMESPACES.md](STDLIB-NAMESPACES.md) -- standard namespaces, intrinsics, `at` and `get`
- [MODULE-BINDINGS.md](MODULE-BINDINGS.md) -- immutable module bindings
- [MODULE-STATIC-RETAINED-VALUES.md](MODULE-STATIC-RETAINED-VALUES.md) -- module-static retained values
- [NATIVE-MODULES.md](NATIVE-MODULES.md) -- the first cross-file module system

### Ownership, coroutines and mutable collections

- [AFFINE-VALUES.md](AFFINE-VALUES.md) -- affinity as a compositional property of a value's type
- [COROUTINES.md](COROUTINES.md) -- eagerly started, affine, resumable computations with deep `yield`
- [COROUTINE-PREREQUISITES.md](COROUTINE-PREREQUISITES.md) -- the research coroutines were built on
- [COROUTINE-FUSION-MILESTONE-1.md](COROUTINE-FUSION-MILESTONE-1.md) -- coroutine fusion: a coroutine closed inside one function compiled natively into that function's control flow (one stack, no coroutine object or switch), deep yields, several coroutines per frame, scalar transport, the general runtime as fallback and oracle (completion report)
- [DFA-COROUTINE-EXPLORATION.md](DFA-COROUTINE-EXPLORATION.md) -- declarative finite-state recognizers as ordinary coroutines: an isolated prototype (`audit/dfa/`) that checks determinism, rejection, acceptance, progress and boundaries and lowers to fused coroutine code; RFC 8259's lexical grammar, a YAML subset, a mistake census, differential tests, native evidence and a recommendation (exploratory report)
- [DFA-COROUTINE-MILESTONE-2.md](DFA-COROUTINE-MILESTONE-2.md) -- declared recognizers in the language: `class` and `dfa` declarations checked by the compiler and lowered to ordinary coroutine functions, bounded lookahead (`accept before N`), a compact transition table lowered natively to byte tables or the general NIR `switch`, compiler-service facts, the JSON and YAML workloads, before/after measurements (completion report)
- [EMITTER-COROUTINE-EXPLORATION.md](EMITTER-COROUTINE-EXPLORATION.md) -- grammar-constrained emission: an isolated prototype (`audit/emitter/`) that proves an ordinary coroutine emitter's claim to yield exactly one token of a declared recognizer, by abstract interpretation of its HIR over the recognizer's effective table; JSON integer, string and document emitters, a mistake census, property and differential tests, native evidence (no grammar left in proved emitters' code) and a recommendation (exploratory report)
- [EVENT-LOOP-EXPLORATION.md](EVENT-LOOP-EXPLORATION.md) -- a thread-local, coroutine-native event loop: an isolated prototype (`audit/event-loop/`) of one scheduler over ordinary coroutines, its scheduling turn, fairness, observers, timers and revocation, run under deterministic, Linux epoll, SDL3 (five coordination modes, its own application host) and Win32 (Wine) drivers; multi-library composition, synchronous native callback containment, registration ownership, a foreign-lifetime analysis prototype, a mobile census, measurements and a recommendation (exploratory report)
- [CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md](CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md) -- a trait operation never takes a same-named visible function as its callee: the event-loop exploration's `d.wait(5)` bug (a yield edge to an unrelated yielding `wait`), its root cause (method syntax stands a call in with a candidate before typing decides it is a trait operation), the fix in resolution, `hir::contexts::Callee` and the coroutine analysis, the related call-shape and context-requirement defects, regression tests and mutants (completion report)
- [TRAIT-IMPLEMENTATION-CONTEXT-TRAIT-DEFECT.md](TRAIT-IMPLEMENTATION-CONTEXT-TRAIT-DEFECT.md) -- an open defect, recorded for its own milestone: a trait operation whose selected implementation needs a context trait cannot be compiled (the plan drops the implementation, makes no clone of it and leaves the operation naming the dropped declaration; build 1 never sees the requirement, so nothing is selected and a missing installation is an internal error, not MISSING-CONTEXT); the reproducers and their runner, the root cause traced through hir::contexts and hir::traits, a compiler crash when a build's only diagnostics are internal, the fixes that do not work, what the fix must establish and its acceptance (defect record)
- [TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md](TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md) -- a trait operation's yields are its selected implementation's, in the checked program: the coroutine call graph binds each operation as the monomorphization's plan does (the selected context's implementation; per witness, a node per specialization of a trait-polymorphic function), learned through `hir::check`'s feedback; coroutines suspending only through an implementation run, protocols are the implementation's, nothing is acquired from another witness or a same-named function; staticdeps agreement, economics, the remaining boundary (completion report)
- [EVENT-LOOP-MILESTONE-1.md](EVENT-LOOP-MILESTONE-1.md) -- the event loop as a standard-library facility: `std::event_loop`, the exploration's scheduler promoted into ordinary Botlish (the turn contract frozen, a deadline heap, Delivery policies with Reliable backpressure, generation-checked revocation, explicit ownership, fault channels), the deterministic driver `std::event_loop::deterministic` on every backend, the production Linux driver package (`packages/event_loop_linux`: epoll, eventfd, round-robin source fairness, the native integration ABI), SDL3, the host-stepped driver, examples, the feedback-union investigation, mutants and measurements against the prototype (completion report)
- [MUTABLE-VECTOR.md](MUTABLE-VECTOR.md) -- `MutableVector[T]`: a growable mutable value
- [MUTABLE-ARRAY.md](MUTABLE-ARRAY.md) -- `MutableArray[T]` as a copy-on-write value
- [PARAMETERIZED-MUTABLEARRAY.md](PARAMETERIZED-MUTABLEARRAY.md) -- parameterized `MutableArray[T]`
- [MUTABLEARRAY-CONSTRUCTION-REFINEMENT.md](MUTABLEARRAY-CONSTRUCTION-REFINEMENT.md) -- `MutableArray` construction and refinement
- [TYPED-MUTARRAY-BUILDER-REFACTOR.md](TYPED-MUTARRAY-BUILDER-REFACTOR.md) -- typed `MutableArray` builder source refactor
- [MINIMAL-IMMUTABLE-SET.md](MINIMAL-IMMUTABLE-SET.md) -- `ImmutableSet[T]`
- [ORDERED-MUTABLE-MAP-SET.md](ORDERED-MUTABLE-MAP-SET.md) -- `MutableMap[K satisfies Hashable, V]` and `MutableSet[T satisfies Hashable]`: insertion-ordered tables written in Botlish over MutableVectors, placed by the keyed table hash; the loop protocol, MutableVector index proofs, the oracle, fuzzer, mutants and benchmarks (completion report)
- [PLACE-PARAMETERS.md](PLACE-PARAMETERS.md) -- `place m: T`: a parameter that is the caller's place, so a Botlish function can mutate its caller's collection in place
- [PROVEN-COLLECTION-REORDERING.md](PROVEN-COLLECTION-REORDERING.md) -- `m.reorder(order)`, `m.order()`, `m.validate_order(candidate)` for MutableMap and MutableSet: iteration order under the program's control, admitted only where the compiler knows the relational fact SameMembers(order, m) (hir/relations.tcl, REORDER-NOT-PROVEN); the engine's O(n) permutation by stored hashes, the oracle, both fuzzers, mutants and benchmarks (completion report)

### Strings, bytes and text

- [STRING-ALLOCATION.md](STRING-ALLOCATION.md) -- one allocation per dynamic String
- [STRING-VIEW-ALLOCATIONS.md](STRING-VIEW-ALLOCATIONS.md) -- closing the `char_at` allocation gap
- [CAPTURE-EXPLICIT-STRINGREGION.md](CAPTURE-EXPLICIT-STRINGREGION.md) -- capture-explicit StringRegion companions
- [SHORT-STRING.md](SHORT-STRING.md) -- ShortString1: one-i64 Strings of at most one character
- [SHORT-STRING-TIERS.md](SHORT-STRING-TIERS.md) -- tiered short Strings: packed ASCII, ShortString1, tagged
- [SHORT-STRING-WORK.md](SHORT-STRING-WORK.md) -- the short-String work, in full
- [STRING-BYTES-CONSTRUCTION-AUDIT.md](STRING-BYTES-CONSTRUCTION-AUDIT.md) -- String/Bytes construction audit
- [ENCODE-UTF8-ALLOCATION-RESEARCH.md](ENCODE-UTF8-ALLOCATION-RESEARCH.md) -- eliminating `std::str::encode_utf8`'s read-only Lists
- [UNICODECHAR-MODULE-RETENTION.md](UNICODECHAR-MODULE-RETENTION.md) -- `UnicodeChar` module retention
- [BYTE-SET.md](BYTE-SET.md) -- `std::byte::set`: UnicodeChar to checked Byte to `ImmutableSet[Byte]`
- [ASCII-AND-URI-UNRESERVED.md](ASCII-AND-URI-UNRESERVED.md) -- ASCII classification and `std::web::is_unreserved`
- [ASCII-SUBSTRINGS-RECOMMENDATION.md](ASCII-SUBSTRINGS-RECOMMENDATION.md) -- should `substring` results be proven ASCII?
- [NATIVE-TCL-UNICODE.md](NATIVE-TCL-UNICODE.md) -- Tcl-compatible Unicode character classification

### Systems boundary: ABI, Linux and process I/O

- [ABI-BYTES.md](ABI-BYTES.md) -- `std::abi::bytes::Bytes` and `std::linux::write`
- [MUTABLE-BYTES.md](MUTABLE-BYTES.md) -- `std::abi::bytes::MutableBytes` and `std::linux::read`
- [BINARY-LAYOUT.md](BINARY-LAYOUT.md) -- fixed binary layouts: `layout`, `LayoutStruct[L]`, `std::binary::parse` and `std::binary::emit`
- [C-HEADER-ARCHAEOLOGY.md](C-HEADER-ARCHAEOLOGY.md) -- empirical C header archaeology: BoringSSL's and Tcl's preprocessed headers, an exploratory FFI IR and what a first C FFI needs (corpus: `audit/c-header/`; its parser and toolchain adapter now in `tools/cheader/`)
- [NATIVE-LAYOUT-WRITES.md](NATIVE-LAYOUT-WRITES.md) -- the write half of native layouts: `NativeEdit[L]` (`std::binary::native::edit`, `std::binary::store`), write authority over live native memory distinct from read authority; layout-directed writes into byte storage (`std::binary::write`) and the explicit foreign encoding of an existing pointer (`std::binary::write_foreign`); field designators `L.f`; a C oracle, a caller-constructed native record, fuzzer, mutants, benchmark
- [FIXED-LAYOUT-ARRAYS.md](FIXED-LAYOUT-ARRAYS.md) -- fixed arrays in binary layouts: `field name: array N of E at OFFSET`, the copied value a List of exactly N elements (LayoutExtentMismatch, extent proofs), live arrays `NativeView[array N of E]` (`std::binary::element`, `std::binary::store_element`, whole loads and stores), static element designators `L.items[3]`; the C binding generator's arrays (+3 / +11 / +19 / +249 records, the forecast exactly), a C oracle, fuzzers, mutants, benchmark
- [LAYOUT-UNIONS.md](LAYOUT-UNIONS.md) -- unions in binary layouts: `union layout U:`, several declared interpretations of the same bytes (no tag, no active member, overlap only where declared), held by value in records, arrays and other unions; live unions `NativeView[U]`/`NativeEdit[U]` (an alternative is an address, never a copy), no copied value (`std::binary::read` through a designator instead), pointer authority through alternatives; the C binding generator's unions and anonymous members (synthetic layouts placed by clang's record layouts: Tcl 34, SDL3 85, BoringSSL 118, Win32 996 layouts), a C oracle, fuzzers, mutants, benchmark
- [NATIVE-LAYOUT-VIEWS.md](NATIVE-LAYOUT-VIEWS.md) -- read-only native layout views: an ordinary `layout` read from authorized live native memory (`std::binary::native::view(L, p)`, `NativeView[L]`, `std::binary::load`), pointer fields that native memory may hold and bytes never become; the C oracle, fuzzing, mutants and the pressure on native writes
- [C-ABI-TYPES.md](C-ABI-TYPES.md) -- the C ABI type universe: target-resolved C integer scalars, `std::ffi::c::Void`, `std::ffi::c::Ptr[T]`, `std::ffi::c::FnPtr[F]`, the pointer operations, and callable imprinting (`std::ffi::c::null[T]()`)
- [C-POINTER-BORROWING.md](C-POINTER-BORROWING.md) -- temporary foreign byte exposure: existing `Bytes` / `MutableBytes` given to a C pointer parameter for one call when its contract says noescape, sharing the syscall path's exposure mechanism; the `extern c fn` and `direct` hooks
- [C-FFI.md](C-FFI.md) -- `extern c library` and `extern c fn`: real link-time C calls with the platform ABI, linked by the system linker; contracts, byte borrowing and write-back through real C, truthful pointer results, retaining calls as direct authority; the Tcl and BoringSSL SHA-256 acceptance
- [C-BINDGEN.md](C-BINDGEN.md) -- automatic C binding generation (`tools/c-bindgen.tcl`): ordinary Botlish bindings generated from real C headers by interrogating the C compiler (ABI, symbol and evidence probes), thunks for macros and static inline functions, explicit contracts, a deterministic report and manifest, `std::ffi::c::Bool`; the Tcl, BoringSSL and SDL3 acceptance
- [C-BINDGEN-LAYOUTS.md](C-BINDGEN-LAYOUTS.md) -- generated native record layouts: an ordinary `layout` per complete C record whose fields a layout represents, with the target C compiler's sizes, alignments and offsets (verified statically, by a second compiler and by a runtime C oracle), the blocked records and their reasons, layout and API pressure; the windows-x86_64-gnu target and the Win32 binding generated with MinGW-w64
- [C-BINDGEN-UBUNTU-26.04-HANDOFF.md](C-BINDGEN-UBUNTU-26.04-HANDOFF.md) -- the c-bindgen workflow and Codespace on Ubuntu 26.04: the pinned Clang 21.1.8 and MinGW-w64 13.0.0 toolchain, the evidence probe's attribute order under LLVM 21, every committed binding regenerated and reviewed, and how to regenerate them from an Ubuntu 24.04 container (completion record)
- [C-FFI-ERROR-CAPTURE-MILESTONE-1.md](C-FFI-ERROR-CAPTURE-MILESTONE-1.md) -- the C FFI's error-capture window: a write-exposing C call's write-back value represented as fields (the C result, each private copy's storage) and its MutableBytes built at their use, `keepalive` without a machine call, so nothing the compiler emits allocates, collects or calls between a C function's return and the program's errno read; NIR, object-file and single-step detectors with positive controls, an errno-changing allocator, Linux and macOS evidence (completion report)
- [C-FFI-ERROR-CAPTURE-MILESTONE-2.md](C-FFI-ERROR-CAPTURE-MILESTONE-2.md) -- foreign-result error-capture invariance: the C error state survives every lowering (struct scalar replacement off, the generic lowering), a write-back value that escapes after the capture (captured, stored, passed, used in a loop) and a 64-bit result outside the small-Int range (`(size_t)-1` compared as the C word it is, `i64`/`u64` NIR registers, boxed only at its first tagged use); the transport a correctness rule, the eager representation a test-only fault injection; detectors in every mode, Linux and macOS evidence (completion report)
- [C-FLOAT-FFI-MILESTONE-1.md](C-FLOAT-FFI-MILESTONE-1.md) -- C `float` and `double` across the C FFI: `std::ffi::c::Float` (binary32, carrier Float64; no Botlish Float32) and `std::ffi::c::Double` as C representations in extern signatures, function pointers, pointees, layout fields, arrays and unions; finite-only admission, exact widening, checked round-to-nearest-even narrowing (`NonFiniteFloat`, never clamped), the same rule at compile time; native f32/f64 lowering (SysV, AAPCS64, Apple, Win64); the binding generator's float and double, `long double` diagnosed (completion report)
- [NATIVE-LIBRARY-MILESTONE-1.md](NATIVE-LIBRARY-MILESTONE-1.md) -- native libraries: `exported c fn` and the explicit export list, export roots compiled under their declared contracts (the census's `checked(-5)` and long-input defects fixed with no workaround), one startup data product for executables and libraries (the program descriptor and `LinkedProgram` record), `native::library` / `main.tcl -emit-native-library` writing a static archive, a shared library, a C header and a JSON manifest; a C ABI of int64_t, bool, double and UTF-8 text with owned results, statuses and structured errors, thread-affine instances with an explicit lifecycle, two libraries per process isolated in symbols and runtime state; the JSON/Tcl and React Native host probes migrated (completion report)
- [NATIVE-LINK-PLAN-MILESTONE-1.md](NATIVE-LINK-PLAN-MILESTONE-1.md) -- explicit native dependencies in source: `extern c library "NAME" static` (a static archive, never a shared library), `static at "PATH"` (the archive's file, from the application root), `extern c framework "NAME"` (Apple frameworks, `-F`); declarations merged to the strictest requirement or `LINK-CONFLICT`, kept through imports, HIR interchange and the front-end cache; the driver's resolution and checks (format, architecture, import libraries: `NATIVE LINK ARCHIVE`) for the rustc and the system linker on Linux, macOS and Windows; static SDL3 through Botlish.app (completion report)
- [ABI-NUMERIC-DOMAINS.md](ABI-NUMERIC-DOMAINS.md) -- `std::abi::I8` ... `std::abi::Usize`
- [LINUX-X86-64-SYSCALL.md](LINUX-X86-64-SYSCALL.md) -- direct Linux x86-64 syscalls
- [LINUX-SYSCALL-TRANSPORTS.md](LINUX-SYSCALL-TRANSPORTS.md) -- the AArch64 transport beside the x86-64 one (`std::linux::abi::ARCH::syscall`, one table), `std::linux::sys` as an architecture-specific module the compilation target selects, and what the single-file compiler needs on AArch64
- [ARGV.md](ARGV.md) -- `argv()`: the process argument vector

### Compile-time evaluation and testing

- [STATIC-COMPILE.md](STATIC-COMPILE.md) -- `static compile:`: compiler diagnostics as recoverable values
- [STATIC-DECISION-ECONOMICS.md](STATIC-DECISION-ECONOMICS.md) -- how many builds deciding static blocks takes
- [METHOD-DECISION-FILTER.md](METHOD-DECISION-FILTER.md) -- kind proofs in the method-call decision: candidates the receiver's kind or a named struct's declaration rules out need no build of their own
- [METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md](METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md) -- method-style calls decided by each call's own checks, certified relative to the decided program: the semantic rule, its procedure, an independent oracle and the economics
- [SFIAE-MILESTONE-1.md](SFIAE-MILESTONE-1.md) -- obligations do not select operations: an ambiguous context-trait implementation, like a missing context, is an obligation of the selected call and never decides a method-style call; SFIAE stated as a language principle (completion report)
- [METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md](METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md) -- method-call failures reported without changing method decisions: the reported program resolves a rejected call to no candidate (poison), so no placeholder's checks, obligations or result type cascade; dependent rejections, source order, candidate explanations and notes (completion report)
- [GOLDEN-TEST-FRAMEWORK.md](GOLDEN-TEST-FRAMEWORK.md) -- `stdlib/test.bot`: a test framework written in Botlish
- [LARGE-SCALE-GOLDEN-MIGRATION.md](LARGE-SCALE-GOLDEN-MIGRATION.md) -- porting the Tcl tests to golden suites
- [GOLDEN-VS-TCL-BENCHMARK.md](GOLDEN-VS-TCL-BENCHMARK.md) -- golden suites against their Tcl originals
- [TEST-SUITE-COST.md](TEST-SUITE-COST.md) -- where local test runs spend their time

### Compiler warnings

- [WARNINGS-SAME-RETURN.md](WARNINGS-SAME-RETURN.md) -- the warnings framework and `SAME-RETURN-VALUE`
- [WARNINGS-METHOD-ELIGIBLE.md](WARNINGS-METHOD-ELIGIBLE.md) -- `METHOD-ELIGIBLE` and `nomethod fn`
- [WARNINGS-FIXED-ARITY-LIST-RETURN.md](WARNINGS-FIXED-ARITY-LIST-RETURN.md) -- `FIXED-ARITY-LIST-RETURN`
- [WARNINGS-SAME-FAILURE.md](WARNINGS-SAME-FAILURE.md) -- `SAME-FAILURE`
- [WARNINGS-PROVES-NAMING.md](WARNINGS-PROVES-NAMING.md) -- `PROVES-NAMING`
- [WARNINGS-ONE-CHAR-STRING-LITERAL.md](WARNINGS-ONE-CHAR-STRING-LITERAL.md) -- `ONE-CHAR-STRING-LITERAL`
- [WARNINGS-MANY-BOOLEAN-ARGUMENTS.md](WARNINGS-MANY-BOOLEAN-ARGUMENTS.md) -- `MANY-BOOLEAN-ARGUMENTS`
- [MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md](MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md) -- `CONTEXT-RESOURCE-ESCAPE` (section 3)
- [REFACTOR-WARNINGS-CLEAN.md](REFACTOR-WARNINGS-CLEAN.md) -- the corpus under its own warnings
- [LANGUAGE-LIBRARY-DEFICIENCIES.md](LANGUAGE-LIBRARY-DEFICIENCIES.md) -- language and library gaps that refactor found

### The built-in reference

- [COMPILERPEDIA.md](COMPILERPEDIA.md) -- Compilerpedia, `-help`: the topic model, indices, search, help lines, generation, validation and maintenance
- [COMPILERPEDIA-REPORT.md](COMPILERPEDIA-REPORT.md) -- the Compilerpedia milestone: the CLI changes, coverage, the lint audit and the 15-puzzle assessment
- [IDIOMATIC-BOTLISH.md](IDIOMATIC-BOTLISH.md) -- the newcomer page of Compilerpedia (`principle.idiomatic-botlish`): its principles, search, the black-box audit and the questions that still need a probe

## Implementation

### Architecture and toolchain

- [DIRECT-HIR-NATIVE-PATH.md](DIRECT-HIR-NATIVE-PATH.md) -- HIR to NIR, never through core IR
- [COMPILATION-ISOLATION.md](COMPILATION-ISOLATION.md) -- a HIR's backends see its own declarations
- [HIR-INTERCHANGE.md](HIR-INTERCHANGE.md) -- the analyzed HIR as a file, and the front-end cache
- [COMPILER-SERVICE-MILESTONE-1.md](COMPILER-SERVICE-MILESTONE-1.md) -- the compiler service: front-end diagnostics located as data, the source-provider seam (unsaved buffers, one normalization, per-compilation snapshots), immutable analysis revisions and their position queries (bindings, presented types, name-precise definitions, references by identity, Compilerpedia topics), `main.tcl -check`; the std:: trial merge and the S2 recommendation (completion report; the census is `../audit/compiler-service/COMPILER-SERVICE-CENSUS.md`)
- [LSP-MILESTONE-1.md](LSP-MILESTONE-1.md) -- Botlish's first language server, `botlish -lsp`: Content-Length framing, typed JSON and JSON-RPC in Tcl, document synchronization over the service's overlays, program ownership, UTF-16/UTF-32 positions and file URIs at the boundary, pushed diagnostics, hover, definition and references with a conservative stale-revision policy; the synchronous and persistent-worker schedulers measured against each other (the worker chosen), revisions moved between processes as HIR interchange (`service::export`/`import`); the protocol harness over real pipes, Neovim end to end, mutation testing (completion report)
- [SYNTAX-RECOVERY-MILESTONE-1.md](SYNTAX-RECOVERY-MILESTONE-1.md) -- syntax-error-tolerant semantic analysis: malformed statements become holes that keep only what their valid prefix establishes (no value, type or proof), uncertainty propagated by the semantic dependency model, modules recovered across imports, independent diagnostics kept and dependent ones suppressed; `-check`, the compiler service's partial revisions and the language server's fresh answers while a document is incomplete, strict compilation and every backend unchanged; experiments, fuzzing, mutation testing, Neovim (completion report)
- [SINGLE-EXECUTABLE.md](SINGLE-EXECUTABLE.md) -- the single-file compiler, the stub linker and the system linker
- [SINGLE-EXECUTABLE-FFI-MILESTONE-1.md](SINGLE-EXECUTABLE-FFI-MILESTONE-1.md) -- the system linker: programs that call C linked from the single-file compiler with the host's C compiler driver, a data-only startup object and a precompiled runtime archive, no Rust; the startup census and design, the three linkers' startups compared byte for byte, static libraries, failure diagnostics, packaging, Linux, macOS and Windows results, mutation testing, sizes and costs (completion report)
- [MACOS-AARCH64-PORT-AUDIT.md](MACOS-AARCH64-PORT-AUDIT.md) -- the macOS Apple Silicon port: every Linux assumption by subsystem, what runs on a real macOS arm64 host today, the macOS CI and its test tiers, and the milestone roadmap
- [MACOS-AARCH64-MILESTONE-1.md](MACOS-AARCH64-MILESTONE-1.md) -- macOS port milestone 1: the platform audit and the Apple Silicon GitHub Actions infrastructure, with the CI evidence
- [MACOS-AARCH64-MILESTONE-2.md](MACOS-AARCH64-MILESTONE-2.md) -- macOS port milestone 2: the compilation target as an operating system and an architecture -- target identity, macOS C ABI facts, the Apple AArch64 C convention, platform module resolution, HIR interchange and cache target isolation, and native host/target validation
- [MACOS-AARCH64-MILESTONE-3.md](MACOS-AARCH64-MILESTONE-3.md) -- macOS port milestone 3: native coroutines on Apple Silicon -- the Mach-O stack switch, Apple AArch64 ABI checks, suspended-stack GC roots, and the native golden runner on macOS, with the CI evidence
- [MACOS-AARCH64-MILESTONE-4.md](MACOS-AARCH64-MILESTONE-4.md) -- macOS port milestone 4: native stack bounds, overflow detection and its recovery on Apple Silicon -- pthread stack discovery and confirmed guards, the shared stack-overflow guard, coroutine-switch publication, the shadow-stack depth token retired, with the CI evidence
- [MACOS-AARCH64-MILESTONE-5.md](MACOS-AARCH64-MILESTONE-5.md) -- macOS port milestone 5: Mach-O AOT executables on Apple Silicon -- the program object, the rustc and Apple system link, standalone runtime acceptance (GC, coroutines, NATIVE LIMIT STACK, a moved multi-file application), C calls still refused, with the CI evidence
- [MACOS-AARCH64-MILESTONE-6.md](MACOS-AARCH64-MILESTONE-6.md) -- macOS port milestone 6: C calls on Apple Silicon -- Apple's link plan and linker diagnostics, the Apple arm64 C ABI checked against Apple clang (caller extension of narrow arguments, packed stack arguments, plain char signed, pointers), a Cranelift 0.135.2 defect in extended stack arguments and its workaround, c-ffi.test and c-bindgen.test on macOS, with the CI evidence
- [MACOS-AARCH64-MILESTONE-7.md](MACOS-AARCH64-MILESTONE-7.md) -- macOS port milestone 7: C byte borrowing on Apple Silicon -- the borrowing census, read and write exposures through the host compiler's fixture and libSystem (sizes to 1 MiB, payload addresses above 4 GiB, the detach, refusals, GC stress, coroutines, Guard Malloc), the borrowing tools on macOS, with the CI evidence
- [MACOS-AARCH64-MILESTONE-8.md](MACOS-AARCH64-MILESTONE-8.md) -- macOS port milestone 8: Darwin IO through libSystem -- the `darwin` platform namespace, write/read/open/close and errno through `__error()` and a native view, the variadic open, DarwinPath, the opaque DarwinIO context implementing std::io::IO, short writes through a dyld interposer, the 2048 demo on both platforms, with the CI evidence
- [MACOS-AARCH64-MILESTONE-9.md](MACOS-AARCH64-MILESTONE-9.md) -- macOS port milestone 9: the canonical macOS compiler distribution -- Botlish.app with Tcl 9 built and bundled as its own Tcl.framework, the compiler stack in a ZIP resource mounted by zipfs, the native backend and runtime archive in place, a minimal C launcher, ad-hoc signing inner to outer, relocation, a Mac without developer tools, the distribution archive and the clean-environment CI, with the evidence
- [MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md](MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md) -- census: hosting a graphical (SDL3/Cocoa) application on macOS without compromising the native runtime -- today's 1 GiB worker cannot host Cocoa, the program on the process's main thread (candidate A, LC_MAIN's 512 MiB stack) keeps every runtime guarantee, a main-thread dispatcher and SDL3's main callbacks compared, executed on GitHub's macos-15 runners; recommends an explicit main-thread startup policy for macOS executables
- [WINDOWS-TOOLCHAIN-CENSUS.md](WINDOWS-TOOLCHAIN-CENSUS.md) -- the Windows x86-64 port's toolchain census: where the Windows ABI and toolchain boundary is (the Rust host target of the driver; Cranelift's COFF object is the same for MinGW-w64 and MSVC), every Windows assumption by subsystem, the probes on Wine and on real Windows runners, the toolchain-neutral blockers (GC roots, stack probes, unwind info, the guard, coroutines, argv, platform IO), and the decision: MSVC for the native path
- [WINDOWS-X86-64-MILESTONE-1.md](WINDOWS-X86-64-MILESTONE-1.md) -- Windows port milestone 1: the native driver and runtime built for x86_64-pc-windows-msvc, executables linked by rustc and link.exe (the MSVC link plan, the static C runtime, .exe names, LNK diagnostics), one Windows target, GC correctness through the fallback root plan with no frame walk (one capability for stack maps, the shadow stack and the walk), stack probes, the Windows argument contract, the test harness and the real-Windows CI, with the evidence
- [WINDOWS-X86-64-MILESTONE-2.md](WINDOWS-X86-64-MILESTONE-2.md) -- Windows port milestone 2: C calls on Windows x86-64 (the Win64 C ABI checked against MSVC-built callees, link.exe linking of static libraries and DLL import libraries, the static C runtime for every executable and the /MT-/MD matrix, LNK diagnostics), linked runs started with their argument snapshot by CreateProcessW, the `windows` platform namespace and Windows I/O through kernel32 behind std::io::IO (files, pipes, short writes and failures, borrowed handles), GC across C calls, with the real-Windows evidence
- [WINDOWS-X86-64-MILESTONE-3.md](WINDOWS-X86-64-MILESTONE-3.md) -- Windows port milestone 3: Windows x64 unwind information for every Botlish function (Cranelift's prologue description encoded correctly; .pdata/.xdata in the COFF object; the JIT's code in one reserved range registered with RtlAddFunctionTable for its lifetime), GC roots in native frames on Windows (the collector crossing Rust frames with RtlVirtualUnwind, Botlish frames by their frame records; BOTLISH_NATIVE_UNWIND_CHECK), a stack-pointer limit in place of the shadow stack's depth check, the fallback plan kept as the bootstrap, frame anchors probed against Windows' unwinder, the hostile tests, mutants and the same-runner performance comparison, with the real-Windows evidence
- [WINDOWS-X86-64-MILESTONE-4.md](WINDOWS-X86-64-MILESTONE-4.md) -- Windows port milestone 4: the native stack guard on Windows -- a vectored exception handler claiming STATUS_STACK_OVERFLOW on the thread that runs Botlish code, within a measured stack guarantee, reporting NATIVE LIMIT STACK through every reporting mode with WriteFile and TerminateProcess; the experiments on real Windows that chose it; the interim stack-limit checks and the call effects they forced removed; the hostile tests, mutants and the before/after comparison, with the real-Windows evidence
- [WINDOWS-X86-64-MILESTONE-5.md](WINDOWS-X86-64-MILESTONE-5.md) -- Windows port milestone 5: native coroutines on Windows x86-64 -- a Windows fiber per coroutine stack (SwitchToFiber, chosen over a stack switch of our own by experiments on real Windows: the TEB's stack fields, guarantees, growth, unwinding and panics), each fiber with its own stack guarantee and its stack published to the stack guard on every switch, suspended and resumer stacks walked by the collector from where their switch left with Windows' unwinder, pooled fibers restarted at their top, the fallback plan refusing coroutines, the golden suites on Windows' native backends, the hostile tests, mutants and costs, with the real-Windows evidence
- [WINDOWS-X86-64-MILESTONE-6.md](WINDOWS-X86-64-MILESTONE-6.md) -- Windows port milestone 6: Win64 variadic C calls -- every argument at its position through the per-call signature, and each float or double of the first four positions also in its position's integer register, which no Cranelift signature can state, copied by a stub before the jump to C (the counterpart of System V's %al stub); the Cranelift investigation and its controlled experiment, MSVC machine-state captures and va_arg callees, the C runtime's snprintf and _open and user32's wsprintfA, GC, borrowing and coroutines, the mutants and the code it makes, with the real-Windows evidence
- [WINDOWS-X86-64-MILESTONE-7.md](WINDOWS-X86-64-MILESTONE-7.md) -- Windows port milestone 7: paths and synchronous filesystem I/O -- three path representations compared through real Linux and NTFS directories (a lossy textual name opened another file), the two-layer design chosen (textual paths programs write, lossless native paths the system returns), the portable std::io::fs (FileError, open modes, the eager trait FilePath whose witness type selects the filesystem at compile time) and the platform modules std::linux::fs (raw syscalls), std::windows::fs and std::windows::path (Win32 syntax, kernel32's wide functions) and std::darwin::fs (libSystem), affine Files and the ten ownership experiments with what a resource feature would need, a method-call decision fix, the tests, fuzzer, mutants and costs, with the real-Windows evidence
- [STRICT-REFERENCE-DETERMINISM.md](STRICT-REFERENCE-DETERMINISM.md) -- strict reference determinism
- [CANONICAL-SURFACE-BENCHMARKS.md](CANONICAL-SURFACE-BENCHMARKS.md) -- every benchmark as ordinary `.bot` source
- [COMPILER-BOTTLENECKS.md](COMPILER-BOTTLENECKS.md) -- compiler performance bugs: what to tackle next
- [RANGE-FIXPOINT-SCALING.md](RANGE-FIXPOINT-SCALING.md) -- range fixpoint scaling
- [CRANELIFT-WASM.md](CRANELIFT-WASM.md) -- WebAssembly for the Cranelift backend
- [REACT-NATIVE-TARGET-CENSUS.md](REACT-NATIVE-TARGET-CENSUS.md) -- a React Native target census: Botlish functions as a Pure C++ TurboModule through a generated C++ adapter over a C ABI, the React Native 0.88 contract (Codegen, Android pure C++ autolinking, iOS module providers), what library mode, embedding and the mobile targets need in core, the plugin seams, a Tcl package generator, and the host (Hermes) and Android/iOS CI probes (material: `audit/react-native/`)
- [VM-OPCODE-VIABILITY.md](VM-OPCODE-VIABILITY.md) -- a register bytecode compiled from NIR
- [NATIVE-BOTLISH-LOWERING-IMPL.md](NATIVE-BOTLISH-LOWERING-IMPL.md) -- native lowering written in Botlish: what it would take

### Native code generation and runtime

- [NATIVE-STACK-MAPS.md](NATIVE-STACK-MAPS.md) -- stack maps and frame walking for the GC
- [NATIVE-STACK-OVERFLOW.md](NATIVE-STACK-OVERFLOW.md) -- native stack overflow protection
- [RAW-INT-ABI.md](RAW-INT-ABI.md) -- the raw 64-bit Int ABI
- [RAW-RESULT-REGISTER-COST.md](RAW-RESULT-REGISTER-COST.md) -- the cost of a raw result of a fallible function
- [BRANCH-FORM-BOOLEAN-LOWERING.md](BRANCH-FORM-BOOLEAN-LOWERING.md) -- `if` conditions lowered as branches
- [BOUNDED-BIT-SHIFT-LOWERING.md](BOUNDED-BIT-SHIFT-LOWERING.md) -- bounded bit-shift lowering
- [NATIVE-RESULT-BOUNDS.md](NATIVE-RESULT-BOUNDS.md) -- native result bounds shared by both range analyses; raw bitwise ops of small operands
- [M6-RANGE-DECIDED-BRANCH-LOWERING.md](M6-RANGE-DECIDED-BRANCH-LOWERING.md) -- range-decided branch lowering
- [NATIVE-BLOCK-ESCAPE.md](NATIVE-BLOCK-ESCAPE.md) -- block escape analysis and virtualization
- [NESTED-CLOSURE-ALLOCATIONS.md](NESTED-CLOSURE-ALLOCATIONS.md) -- de-closure conversion
- [STRUCT-SCALAR-REPLACEMENT.md](STRUCT-SCALAR-REPLACEMENT.md) -- struct-aware scalar replacement
- [NATIVE-PARAM-AGGREGATE.md](NATIVE-PARAM-AGGREGATE.md) -- parameter and result virtualization across closed calls
- [M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md](M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md) -- virtual immutable construction plans
- [VALUE-TRANSPORT-MATERIALIZATION.md](VALUE-TRANSPORT-MATERIALIZATION.md) -- value transport and materialization frontiers
- [TINY-EXACT-LEAF-INLINING.md](TINY-EXACT-LEAF-INLINING.md) -- tiny exact-leaf inlining
- [TINY-LEAF-DEFAULT-ON.md](TINY-LEAF-DEFAULT-ON.md) -- tiny exact-leaf inlining on by default
- [OPPORTUNISTIC-SEMANTIC-INSTANCES.md](OPPORTUNISTIC-SEMANTIC-INSTANCES.md) -- opportunistic semantic function instances
- [SYMBOLIC-TYPE-IDENTITY.md](SYMBOLIC-TYPE-IDENTITY.md) -- symbolic native result-type identity
- [NATIVE-OPAQUE-REFINEMENT.md](NATIVE-OPAQUE-REFINEMENT.md) -- trusted opaque refinement across specialization

### Analysis: facts, effects and specialization

- [CLOSED-CALL-FACTS.md](CLOSED-CALL-FACTS.md) -- closed-call value facts
- [CLOSED-CALL-PARAMETER-FACTS.md](CLOSED-CALL-PARAMETER-FACTS.md) -- closed-call parameter fact propagation
- [CLOSED-CALL-EFFECTS.md](CLOSED-CALL-EFFECTS.md) -- closed-call effect summaries
- [EXACT-CALLABLE-CLOSED-CALLER.md](EXACT-CALLABLE-CLOSED-CALLER.md) -- the closed-caller theorem and exact callable identity
- [FINITE-CALLABLE-TARGET-PROVENANCE-RESEARCH.md](FINITE-CALLABLE-TARGET-PROVENANCE-RESEARCH.md) -- finite callable-target provenance: research notes
- [SELF-RECURSIVE-RESULT-RANGES.md](SELF-RECURSIVE-RESULT-RANGES.md) -- self-recursive result Ranges
- [GENERIC-PREDICATE-PROOF-LOSS.md](GENERIC-PREDICATE-PROOF-LOSS.md) -- generic predicate proof loss
- [PROOF-FACT-REPAIRS.md](PROOF-FACT-REPAIRS.md) -- proof/fact repairs and drift tests
- [HIGHER-ORDER-DOGFOODING.md](HIGHER-ORDER-DOGFOODING.md) -- real-world higher-order dogfooding

The M-series milestones, in order:

- [M0-MODULE-CLOSURE-AND-URI-BASELINE.md](M0-MODULE-CLOSURE-AND-URI-BASELINE.md) -- module-closure correctness and the URI/Byte benchmark
- [M1-DECLARED-PARAMETER-FACT-TRANSPORT.md](M1-DECLARED-PARAMETER-FACT-TRANSPORT.md) -- declared-parameter facts in every instance
- [M2-EXACT-CALLABLE-TARGET-PROVENANCE.md](M2-EXACT-CALLABLE-TARGET-PROVENANCE.md) -- exact callable-target provenance and devirtualization
- [M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md](M3-EQUALITY-TOTAL-SETCONTAINS-EFFECT.md) -- equality-total SetContains effect
- [M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md](M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md) -- equality-total SetFromList effect
- [M5-CHECKED-DOMAIN-FACT-PROVENANCE.md](M5-CHECKED-DOMAIN-FACT-PROVENANCE.md) -- checked-domain construction fact provenance
- [M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md](M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md) -- instance selection and theorem semantics
- [M7B-CONJUNCTIVE-ENTRY-FACTS.md](M7B-CONJUNCTIVE-ENTRY-FACTS.md) -- conjunctive entry facts
- [M7C-CLOSED-CLOSURE-ENTRY-FACTS.md](M7C-CLOSED-CLOSURE-ENTRY-FACTS.md) -- closed-closure instances and caller-derived entry kinds
- [M7C1-CLOSECALLERS-CONVERGENCE-FENCE.md](M7C1-CLOSECALLERS-CONVERGENCE-FENCE.md) -- CloseCallers convergence fence
- [M9-INSTANCE-ENTRY-INT-FACTS.md](M9-INSTANCE-ENTRY-INT-FACTS.md) -- instance-entry Int facts

(M6, M7.a.a and M8.a are listed above, under the topics they belong to.)

### The `emailish?` and URI series

How two hand-written native predicates became ordinary Botlish library code:

- [NATIVE-URI-ESCAPE.md](NATIVE-URI-ESCAPE.md) -- de-nativizing `uriEscape`
- [NATIVE-EMAILISH.md](NATIVE-EMAILISH.md) -- de-nativizing `Emailish?`
- [OPAQUE-TYPE-PREDICATE-FINDINGS.md](OPAQUE-TYPE-PREDICATE-FINDINGS.md) -- `UriQueryValue?` and opaque types
- [R2-ORDINARY-EMAILISH-PREDICATE.md](R2-ORDINARY-EMAILISH-PREDICATE.md) -- an ordinary Botlish `emailish?`
- [R2A-IDIOMATIC-EMAILISH-SOURCE.md](R2A-IDIOMATIC-EMAILISH-SOURCE.md) -- idiomatic `emailish?` source
- [R2A1-MODULE-FN-BRIDGE-REACHABILITY.md](R2A1-MODULE-FN-BRIDGE-REACHABILITY.md) -- module-function bridge reachability
- [R2A2-TRAILING-QUESTION-IDENTIFIERS.md](R2A2-TRAILING-QUESTION-IDENTIFIERS.md) -- ordinary trailing-`?` identifiers
- [R2A3-COUNTED-LOOPS-FINAL-SOURCE.md](R2A3-COUNTED-LOOPS-FINAL-SOURCE.md) -- counted loops and the final `emailish?` source

## Workloads

The post-golden stress-test series: real programs written in ordinary
Botlish to find what the language, library, compiler and tools need.

- [2048-ENGINE-WORKLOAD.md](2048-ENGINE-WORKLOAD.md) -- a deterministic 2048 engine (`examples/games/2048/`), full-discovery baseline: findings, the GC root-slot fix it found, and what to fix before the restricted paired run
- [POST-2048-PRODUCT-FIXES.md](POST-2048-PRODUCT-FIXES.md) -- the three product failures fixed before the paired run (application modules, native program output under main.tcl, the interpreter's recursion limit), and the findings deliberately left open
- [DIAGNOSTIC-RECOVERY.md](DIAGNOSTIC-RECOVERY.md) -- after the first 15-puzzle run: failed method sugar is poison and the explicit spelling's MISSING-IMPORT (never `any`), one compilation reports every independent error (past resolution failures, a call's whole unhandled set, every rejected reference), and one malformed construct is one error; the diagnostic-efficiency corpus
- [HASH-TABLE-EXPERIMENT.md](HASH-TABLE-EXPERIMENT.md) -- hash tables, set membership and the compiler/runtime division of labor: sixteen Botlish table variants against a Rust reference of the same algorithms, five general compiler prototypes (value-semantics precision, inline arrays, raw `mod`, an allocation-free hash, bounds theorems), a probe primitive measured and rejected, constant membership as a compiler representation choice, the adversarial review that found and fixed twelve soundness bugs, and the answers to the milestone's twelve questions (`audit/hash-table/`)
- [HASH-TABLE-COMPILER-PRESSURE.md](HASH-TABLE-COMPILER-PRESSURE.md) -- its catalogue: every compiler and runtime deficiency the experiment found (VS, CP, CG, RO, CO, RT, AR entries), each with its minimal source, evidence, consequence, generality, candidate fix and, where prototyped, the result
- [ICY-TOWER-VERTICAL-SLICE-1.md](ICY-TOWER-VERTICAL-SLICE-1.md) -- a playable Icy Tower-style game on Linux (`examples/games/icy-tower/`): real-time loop, physics, collisions, camera, score and restart over the generated SDL3 binding (C floats, native layouts, a variadic call), a Linux executable (`audit/icy-tower/artifacts/`), headless and Xvfb validation, an independent oracle, 26 mutants, the allocation and FFI profile, and what the application exposed in the language, runtime, stdlib and FFI
- [ICY-TOWER-WINDOWS.md](ICY-TOWER-WINDOWS.md) -- Icy Tower on Windows x86-64 with MSVC's toolchain: the binding generator's MSVC target (clang's x86_64-pc-windows-msvc, MSVC's headers required, `__int64` and `__forceinline` parsed) generating the SDL3 binding on Windows at build time, no variadic C call (SDL's error read out with SDL_strlcpy), one game with a Linux and a Windows entry, SDL3.dll without a C runtime dependency, the Windows workflow's tests, artifact and rolling `icy-tower-windows-latest` release
- [ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md](ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md) -- Icy Tower's SDL put behind a context as an architectural census: the session (window, renderer, scratch memory) owned by the installed `sdl::Sdl`, nothing of SDL above it (pointer clones 56 to 0 outside the airlock, the SDL call trace identical); a context cannot own affine values (the pointers live in a native record behind a view), observing affine access is not needed; minimal reproducers, Design A (opaque values), SDL-ID and Canvas-trait variants, a repository census of a candidate warning, the SDL3 package sketch, a compiler fix (`hir::affine::NativeName`)

## Audits, censuses and investigations

- [NATIVE-AUDIT.md](NATIVE-AUDIT.md) -- native code-quality audit: fib, loop-count, refined-checks, sum-refined
- [SCALAR-ASM-AUDIT.md](SCALAR-ASM-AUDIT.md) -- scalar machine-code quality audit (corpus: `audit/native-scalar-asm/`)
- [COMPREHENSIVE-GENERATED-CODE-AUDIT.md](COMPREHENSIVE-GENERATED-CODE-AUDIT.md) -- comprehensive generated-code audit
- [MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md](MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md) -- bottom-up machine-code regression investigation
- [PROOF-FACT-CENSUS.md](PROOF-FACT-CENSUS.md) -- proof/fact census
- [POST-CALL-EFFECTS-AUDIT.md](POST-CALL-EFFECTS-AUDIT.md) -- post-call-effects diagnostic closure audit
- [POST-NATIVE-STACK-AUDIT.md](POST-NATIVE-STACK-AUDIT.md) -- post native stack audit
- [POST-R2A-DYNAMIC-CENSUS.md](POST-R2A-DYNAMIC-CENSUS.md) -- post-R2.a frozen-baseline dynamic census
- [POST-M8A-COMMON-INEFFICIENCY-CENSUS.md](POST-M8A-COMMON-INEFFICIENCY-CENSUS.md) -- post-M8.a cross-workload inefficiency census
- [POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md](POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md) -- post-module-statics exact-target census
- [POST-STRUCTURAL-FN-DYNAMIC-CENSUS.md](POST-STRUCTURAL-FN-DYNAMIC-CENSUS.md) -- dynamic callable census after structural function types
- [EXACT-METHOD-DECISION-MISATTRIBUTION.md](EXACT-METHOD-DECISION-MISATTRIBUTION.md) -- a defect of the former exact method-call decision, fixed by METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md: an outer call's rejected receiver charged to the inner call, so a valid `xs.at(i).length()` chain was rejected
- [FUZZING-EXAMPLES-AOT.md](FUZZING-EXAMPLES-AOT.md) -- fuzzing the example applications as executables
- [FUZZING-ARGV-PROGRAMS.md](FUZZING-ARGV-PROGRAMS.md) -- fuzzing argv-driven programs
