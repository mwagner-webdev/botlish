# Warning candidate census, partition A: programs and libraries outside tests/*.test

Part of ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, section 11 (the warning
proposal). Partition B (`partition-b.*`) covers the programs embedded in
`tests/*.test` and the fuzzers. This partition applies the warning
candidate's measuring instrument,
`audit/icy-tower/context-refactor/tools/escape-candidates.tcl` (rules R1
carry, R2 raw, R3 view, R4 shape; buckets hit, context-but-ordinary,
no-context, designated-direct), to every Botlish program and library module
of the repository outside `tests/*.test`, and classifies every site it
reports.

Files:

| file | what |
|---|---|
| `partition-a.tsv` | one row per site (a source location and its rules, once whatever number of units observed it): bucket, location, from, to, rules, what, classification, reason |
| `partition-a-units.tsv` | one row per compilation unit (765): its set, what it covers, target, expectation, outcome (error code and first message line on a failure), front-end seconds, modules compiled, sites per bucket |
| `units-a.tcl` | builds the unit list: loaders, staged applications, targets |
| `scan.tcl` | applies the instrument to the units and records each unit's module facts and the two supplementary measurements (section 7) |
| `classify-a.tcl` | the classification (written as rules, every site judged) and the summaries quoted here |

Measured at commit eec63c67 (2026-10-23). The census ran while the
repository moved (b68babeb, then ad98975a, 00814dc7 and eec63c67 landed
during the scan); between b68babeb and eec63c67 the only Botlish files that
changed are the canvas variant's (`variants/canvas/`: `canvas-test.bot`
rewritten, `recorder.bot`, `golden.bot` and `golden-check-draws.bot` added),
whose units were rescanned at eec63c67. Every other unit's files are the
same at both revisions, so every number below is eec63c67's.

## 1. Result

* **765 compilation units, 704 compiled, 61 rejected**: 29 deliberately
  (rejection tests, the diagnostic-recovery corpus, reproducers of rejected
  shapes, probes whose rejection their report documents) and 32 stale audit
  programs written for an earlier compiler, none of which touches a C
  pointer, a native view or a context (section 4). The 704 compiled 459
  distinct module files.
* **59 sites: 49 hit, 10 no-context, 0 context-but-ordinary, 0
  designated-direct. 41 SUSPICIOUS, 18 LEGITIMATE, 0 UNDECIDABLE.**
* **Every SUSPICIOUS site is in code written to show the problem**: 40 in
  the baseline Icy Tower (6df89a8e, the vertical slice the refactor
  replaced) and 1 in reproducer g1 (the view leak, written on purpose).
* **Nothing the repository ships has a hit.** The standard library, the
  examples (the refactored Icy Tower included: 0 sites in any bucket), the
  benchmarks, the 102 golden suites and the 383 generated binding modules
  produce 6 sites, all no-context and LEGITIMATE: std::windows::io's use of
  std::windows (4) and the hand-written Tcl binding's demo (2).
* **The rules separate the classes in the hit bucket only through R2/R3.**
  Every hit carrying R2 or R3 (38) is SUSPICIOUS; every hit that is R1
  alone (6) is LEGITIMATE (Design A's opaque `sdl::Video`, an intended
  ownership transfer); R4 splits on opacity: the 3 SUSPICIOUS R4 sites take
  apart a non-opaque struct of pointers, the 2 LEGITIMATE ones a carrier
  whose pointer-holding field is opaque. R4 follows C addresses through
  opaque structs (its carry search); with R2's opaque stop it would have
  reported only the 3 SUSPICIOUS ones.
* **Contextualized modules: 8 module files and 2 entry programs** (section
  5). The two standard ones, std::linux::io and std::darwin::io, expose no
  C pointer and no native view. Every Icy Tower `sdl.bot` (baseline,
  working tree, ID variant, Design A) exposes pointer-typed functions
  publicly -- a module has no private members -- but only the baseline's
  and Design A's are called across the boundary.
* **What the instrument cannot see did not hide anything here** (section
  7): no function of a contextualized module is taken as a value outside
  it (a positive control shows the check works), and the 133 C calls made
  across a module boundary on a pointer all go into ordinary, context-free
  bindings.

## 2. Method

**The instrument.** `scan.tcl` sources `escape-candidates.tcl` (with no
file arguments: it defines `escape::*` and prints an empty `totals:`) and
calls its `escape::Program FILE TARGET` per unit: the front end only
(`surface::readProgramFile -warnings off -cache ""`, the unit's `-target`),
the sites and the module statuses it returns. An execution trace on
`surface::readProgramFile` keeps the HIR that call built, from which
`scan.tcl` reads the module facts (each module's status from `direct
units`, the same data `main.tcl -direct` prints through
`hir::direct::summary`; its declared contexts; its functions' parameter and
result types; its structs; its `extern c fn`s). Nothing in the instrument
is copied or redefined. Cross-check: the instrument run as a command on the
units that have sites (`-target linux-x86_64` on the staged baseline and
Design A `main.bot`, the staged working tree, g1 and the Tcl demo; `-target
windows-x86_64` on `examples/io/hello-windows.bot`) prints `{hit R1} 43
{hit R2} 37 {hit R3} 1 {hit R4} 5 {hit sites} 49 {no-context R1} 4
{no-context R2} 3 {no-context R4} 2 {no-context sites} 6` and `{no-context
R1} 4 {no-context R2} 4 {no-context sites} 4` -- the census's numbers. The
two statuses quoted for g1 and hello-darwin were also checked with
`main.tcl -direct` (airlock and std::darwin::io contextualized, std::darwin
direct).

**The units** (`units-a.tcl`; every directory and staged copy private to
one `mktemp -d` directory, removed afterwards):

* **stdlib** (27): a one-line loader `import NS` / `0` per module, as
  `audit/refactor/tools/sweep.tcl` builds them; an architecture file
  `stdlib/P.ARCH.bot` loaded as `P` under `linux-ARCH`
  (`std::linux::sys` twice: linux-x86_64 and linux-aarch64). Targets:
  `std::darwin*` macos-aarch64, `std::windows*` windows-x86_64, the rest
  linux-x86_64 (the host). The gate's `surface::modules::PlatformTarget`
  would choose macos-x86_64 on this x86-64 host; the census uses
  macos-aarch64, the macOS target the native backend runs, for the darwin
  modules and the two darwin programs.
* **examples** (52): every entry program (a file no sibling imports), in
  place, for its platform's target (hello-darwin and 2048's demo-darwin on
  macos-aarch64, hello-windows and demo-windows on windows-x86_64); the
  three `examples/ffi/bindgen/` demos staged with their profile's generated
  binding for linux-x86_64 (the copy `tools/c-bindgen.tcl stage` makes);
  Icy Tower's `main.bot`, `golden.bot` and `headless.bot` twice -- the
  working tree and the baseline -- each staged with the linux-x86_64 SDL3
  binding (the same copy, as `build.sh` stages it). The task brief calls the
  refactor uncommitted; it is committed (4be79514, "SDL behind the
  sdl::Sdl context"), unchanged since, so the "working tree" is HEAD's
  `examples/games/icy-tower/` and the baseline is 4be79514's parent,
  6df89a8e (the revision `counts.txt` measures).
* **bench** (8): `bench/*.bot`.
* **golden** (102): `tests/golden/*.bot`. No golden suite imports an
  application module (every import is `std::`), so none needs a companion
  file.
* **generated** (383): a loader per module of every committed binding
  (`generated/c/PROFILE/TARGET/PROFILE/**/*.bot`), the binding copied into a
  private application root, compiled for TARGET: boringssl linux-x86_64 and
  linux-aarch64 (83 each), sdl3 (60 each), tcl (11 each), tclstubs
  linux-x86_64 (12), win32 windows-x86_64-gnu (63). All 383 compile; every
  module is ordinary. A loader observes only sites between the binding's own
  modules, and a binding has none to give: its functions are `extern c fn`s
  (natives, which the instrument does not follow), and its only Botlish
  functions (46, in the eight `ctypes` modules) take and return no pointer.
* **audit** (193): every `.bot` program under `audit/` (a file no sibling
  imports), in place, except four corpora that are applications assembled by
  a tool, assembled here the same way: the hash-table experiment (driver as
  `main.bot`, implementation as `table.bot`, key module as `keys.bot`:
  `audit/hash-table/tools/lib.tcl`'s `ht::app`, typed drivers for the typed
  implementations as its `ht::typedDriver` does; every implementation with
  `bench.bot`, every driver with `lp` and its own key module -- bfs.bot's
  points, freq.bot's strings, as `tools/mixed.tcl` pairs them --, and the
  point and str key modules with `bench.bot`), the traits principal program
  (`program/lib/` as its application root), the compiler-service export
  probe (beside `json/json_tokens.bot`) and the three Icy Tower context
  variants (every `.bot` of the variant over the working tree, staged with
  SDL3: the variant's `main.bot`, and for canvas also `canvas-test.bot`,
  its `golden.bot` and `golden-check-draws.bot`). The
  diagnostic-recovery corpus and the reproducers whose header expects a
  front-end rejection are deliberately invalid: compiled, their outcome
  recorded, no evidence. `audit/machine-code-proof-loss/out/profiles/*.bot`
  are directories, not files.

**Scan cost.** 1,776 s of front-end time in all (golden 1,340 s:
destructuring.bot 95 s, mutable-array.bot 76 s; generated 183 s; audit
157 s; examples 88 s), run as two sequential shards.

## 3. Programs covered

| set | units | compiled | rejected | modules compiled (sum over units) | sites |
|---|---:|---:|---:|---:|---:|
| stdlib (loaders) | 27 | 27 | 0 | 94 | 4 (std::windows::io's loader) |
| examples | 52 | 50 | 2 (deliberate) | 246 | 4 windows, 2 tcl, 42 baseline Icy Tower |
| bench | 8 | 8 | 0 | 11 | 0 |
| golden | 102 | 102 | 0 | 509 | 0 |
| generated (loaders) | 383 | 383 | 0 | 1,107 | 0 |
| audit | 193 | 134 | 59 (27 deliberate, 32 stale) | 332 | 1 g1, 10 Design A |
| **total** | **765** | **704** | **61** | 2,299 (459 distinct files) | 59 distinct |

Targets: linux-x86_64 538, linux-aarch64 155, windows-x86_64-gnu 63,
macos-aarch64 5, windows-x86_64 4.

Units with sites (all others: none in any bucket):

| unit | hit | no-context |
|---|---:|---:|
| `6df89a8e:examples/games/icy-tower/main.bot` (baseline, staged) | 40 | 2 |
| `audit/icy-tower/context-refactor/variants/opaque-values: main.bot` (Design A) | 8 | 2 |
| `audit/icy-tower/context-refactor/repro/g1-view-leak/main.bot` | 1 | 0 |
| `stdlib/windows/io.bot` (loader), `examples/io/hello-windows.bot`, `examples/games/2048/demo-windows.bot` | 0 | 4 each, the same 4 sites |
| `examples/ffi/tcl/demo.bot` | 0 | 2 |

The exact list (every unit, by directory; REJECTED marks a compile failure,
section 4 says which are deliberate; `partition-a-units.tsv` has one row
per unit with its outcome and counts):

* `stdlib/` (stdlib, 15): abi.bot (import std::abi), ascii.bot (import std::ascii), binary.bot (import std::binary), byte.bot (import std::byte), compiler.bot (import std::compiler), darwin.bot (import std::darwin), float64.bot (import std::float64), io.bot (import std::io), linux.bot (import std::linux), list.bot (import std::list), mathish.bot (import std::mathish), mutable_array.bot (import std::mutable_array), test.bot (import std::test), web.bot (import std::web), windows.bot (import std::windows)
* `stdlib/abi/` (stdlib, 3): aarch64.bot (import std::abi::aarch64), bytes.bot (import std::abi::bytes), x86_64.bot (import std::abi::x86_64)
* `stdlib/darwin/` (stdlib, 2): io.bot (import std::darwin::io), path.bot (import std::darwin::path)
* `stdlib/ffi/` (stdlib, 1): c.bot (import std::ffi::c)
* `stdlib/io/` (stdlib, 1): path.bot (import std::io::path)
* `stdlib/linux/` (stdlib, 4): io.bot (import std::linux::io), path.bot (import std::linux::path), sys.aarch64.bot (import std::linux::sys), sys.x86_64.bot (import std::linux::sys)
* `stdlib/windows/` (stdlib, 1): io.bot (import std::windows::io)
* `examples/abi/` (examples, 1): numeric-domains.bot
* `examples/binary/` (examples, 1): c-structs.bot
* `examples/ffi/sha256/` (examples, 1): demo.bot
* `examples/ffi/tcl/` (examples, 1): demo.bot
* `examples/games/2048/` (examples, 5): bench.bot, demo-darwin.bot, demo-windows.bot, demo.bot, golden.bot
* `examples/io/` (examples, 5): child-path.bot, hello-darwin.bot, hello-windows.bot, hello.bot, show-path.bot
* `examples/linux/` (examples, 4): context-hello.bot, getpid.bot, read-stdin.bot, write.bot
* `examples/refinement/` (examples, 1): refined-strings.bot
* `examples/stdlib/` (examples, 9): ai_text_clean.bot, csv.bot, csv_chunked.bot, csv_geometric.bot, csv_records.bot, hashtable.bot, matmul.bot, string_replace.bot, string_reverse.bot
* `examples/surface/` (examples, 15): 01-arithmetic.bot, 02-recursion.bot, 03-closure.bot, 04-branch-value.bot, 05-shadowing.bot, 06-list.bot, 07-loop-break.bot, 08-return.bot, 09-mutual-recursion.bot (REJECTED), 10-duplicate-binding.bot (REJECTED), 11-boolean-operators.bot, 12-if-value.bot, 13-hygiene.bot, 14-modules.bot, 15-enums.bot
* `examples/ffi/bindgen/sdl3/` (examples, 1): demo.bot (staged with generated/c/sdl3/linux-x86_64)
* `examples/ffi/bindgen/sha256/` (examples, 1): demo.bot (staged with generated/c/boringssl/linux-x86_64)
* `examples/ffi/bindgen/tcl/` (examples, 1): demo.bot (staged with generated/c/tcl/linux-x86_64)
* `examples/games/icy-tower/` (examples, 3): main.bot (working tree, staged with sdl3), golden.bot (working tree, staged with sdl3), headless.bot (working tree, staged with sdl3)
* `6df89a8e:examples/games/icy-tower/` (examples, 3): main.bot (baseline, staged with sdl3), golden.bot (baseline, staged with sdl3), headless.bot (baseline, staged with sdl3)
* `bench/` (bench, 8): fib.bot, lex-strategy.bot, loop-count.bot, refined-checks.bot, source-checks.bot, sum-refined.bot, test-selection.bot, uri-steady.bot
* `tests/golden/` (golden, 102): abi-bytes-native.bot, abi-bytes.bot, abi-numeric-native.bot, abi-numeric.bot, affinity.bot, binary-layout.bot, bits-bytes-hashing.bot, branch-form-boolean.bot, c-float-ffi.bot, callable-contracts-contravariant-rejected.bot, callable-contracts-contravariant.bot, callable-contracts-fallback.bot, callable-contracts-handle.bot, callable-contracts-returned.bot, callable-contracts-unerased.bot, callable-contracts.bot, callables.bot, closure-escape-instances.bot, closure-escape.bot, collections.bot, compiled-values-struct-transport.bot, compiled-values.bot, completion-regressions.bot, contexts.bot, core-semantics.bot, coroutines.bot, decimal-rounded.bot, declared-errors-imports.bot, declared-errors.bot, destructuring-instances.bot, destructuring.bot, diagnostic-recovery-imported.bot, diagnostic-recovery.bot, diagnostics.bot, errors.bot, flags.bot, float64.bot, framework-semantics.bot, gc-sensitive-values.bot, harness.bot, hashable-admission.bot, hashable.bot, hir-values.bot, imports-abi-child.bot, imports-abi-family.bot, imports-library-modules.bot, imports-unimported.bot, imports.bot, layout-arrays.bot, layout-unions.bot, linux-io-native.bot, linux-io.bot, linux-transports.bot, lists-and-sets.bot, loop-collecting-refined-checks.bot, loop-collecting.bot, loops.bot, method-equivalence-imported.bot, method-equivalence.bot, methods-byte-without-list.bot, methods-list-without-str.bot, methods-struct-instances.bot, methods-type-import-only.bot, methods.bot, modules.bot, mutable-array.bot, mutable-vector-str.bot, mutable-vector.bot, names-and-scoping.bot, native-aggregates.bot, native-values.bot, numeric-looking-names.bot, opaque-instances.bot, opaque.bot, ownership.bot, range-and-contract-values.bot, raw-int-abi.bot, recursive-types.bot, refinements.bot, representation.bot, static-compile-erased-consumer.bot, static-compile.bot, stdlib-namespaces-entry-members.bot, stdlib-namespaces-str-only.bot, stdlib-namespaces-unimported.bot, stdlib-namespaces.bot, string-natives.bot, string-representations.bot, strings.bot, struct-representation-instances.bot, struct-representation.bot, structs-and-enums-instances.bot, structs-and-enums.bot, traits-path.bot, traits.bot, type-predicates.bot, types.bot, unicode-strings.bot, validators-and-proofs.bot, values.bot, variadics.bot, warning-programs.bot
* `generated/c/boringssl/linux-aarch64/` (generated, 83): boringssl/aead, boringssl/aes, boringssl/asn1, boringssl/asn1t, boringssl/base, boringssl/base64, boringssl/bio, boringssl/blake2, boringssl/blowfish, boringssl/bn, boringssl/buf, boringssl/bytestring, boringssl/cast, boringssl/chacha, boringssl/cipher, boringssl/cmac, boringssl/cms, boringssl/conf, boringssl/crypto, boringssl/ctrdrbg, boringssl/ctypes, boringssl/curve25519, boringssl/des, boringssl/dh, boringssl/digest, boringssl/dsa, boringssl/ec, boringssl/ec_key, boringssl/ecdh, boringssl/ecdsa, boringssl/engine, boringssl/err, boringssl/evp, boringssl/evp_errors, boringssl/ex_data, boringssl/hkdf, boringssl/hmac, boringssl/hpke, boringssl/hrss, boringssl/kdf, boringssl/layouts, boringssl/md4, boringssl/md5, boringssl/mem, boringssl/mldsa, boringssl/mlkem, boringssl/nid, boringssl/obj, boringssl/pem, boringssl/pkcs7, boringssl/pkcs8, boringssl/pool, boringssl/posix_time, boringssl/rand, boringssl/rc4, boringssl/ripemd, boringssl/rsa, boringssl/sha, boringssl/sha2, boringssl/siphash, boringssl/slhdsa, boringssl/ssl, boringssl/ssl3, boringssl/stack, boringssl/thread, boringssl/thunks/asn1, boringssl/thunks/asn1t, boringssl/thunks/bio, boringssl/thunks/bytestring, boringssl/thunks/conf, boringssl/thunks/err, boringssl/thunks/pool, boringssl/thunks/ssl, boringssl/thunks/stack, boringssl/thunks/trust_token, boringssl/thunks/x509, boringssl/tls1, boringssl/tls_prf, boringssl/trust_token, boringssl/x509, boringssl/x509v3, boringssl/x509v3_errors, boringssl/xwing
* `generated/c/boringssl/linux-x86_64/` (generated, 83): boringssl/aead, boringssl/aes, boringssl/asn1, boringssl/asn1t, boringssl/base, boringssl/base64, boringssl/bio, boringssl/blake2, boringssl/blowfish, boringssl/bn, boringssl/buf, boringssl/bytestring, boringssl/cast, boringssl/chacha, boringssl/cipher, boringssl/cmac, boringssl/cms, boringssl/conf, boringssl/crypto, boringssl/ctrdrbg, boringssl/ctypes, boringssl/curve25519, boringssl/des, boringssl/dh, boringssl/digest, boringssl/dsa, boringssl/ec, boringssl/ec_key, boringssl/ecdh, boringssl/ecdsa, boringssl/engine, boringssl/err, boringssl/evp, boringssl/evp_errors, boringssl/ex_data, boringssl/hkdf, boringssl/hmac, boringssl/hpke, boringssl/hrss, boringssl/kdf, boringssl/layouts, boringssl/md4, boringssl/md5, boringssl/mem, boringssl/mldsa, boringssl/mlkem, boringssl/nid, boringssl/obj, boringssl/pem, boringssl/pkcs7, boringssl/pkcs8, boringssl/pool, boringssl/posix_time, boringssl/rand, boringssl/rc4, boringssl/ripemd, boringssl/rsa, boringssl/sha, boringssl/sha2, boringssl/siphash, boringssl/slhdsa, boringssl/ssl, boringssl/ssl3, boringssl/stack, boringssl/thread, boringssl/thunks/asn1, boringssl/thunks/asn1t, boringssl/thunks/bio, boringssl/thunks/bytestring, boringssl/thunks/conf, boringssl/thunks/err, boringssl/thunks/pool, boringssl/thunks/ssl, boringssl/thunks/stack, boringssl/thunks/trust_token, boringssl/thunks/x509, boringssl/tls1, boringssl/tls_prf, boringssl/trust_token, boringssl/x509, boringssl/x509v3, boringssl/x509v3_errors, boringssl/xwing
* `generated/c/sdl3/linux-aarch64/` (generated, 60): sdl3/assert, sdl3/asyncio, sdl3/atomic, sdl3/audio, sdl3/blendmode, sdl3/camera, sdl3/clipboard, sdl3/cpuinfo, sdl3/ctypes, sdl3/dialog, sdl3/dlopennote, sdl3/endian, sdl3/error_h, sdl3/events, sdl3/filesystem, sdl3/gamepad, sdl3/gpu, sdl3/haptic, sdl3/hidapi, sdl3/hints, sdl3/init, sdl3/iostream, sdl3/joystick, sdl3/keyboard, sdl3/keycode, sdl3/layouts, sdl3/loadso, sdl3/locale, sdl3/log, sdl3/messagebox, sdl3/metal, sdl3/misc, sdl3/mouse, sdl3/mutex, sdl3/pen, sdl3/pixels, sdl3/platform, sdl3/platform_defines, sdl3/power, sdl3/process, sdl3/properties, sdl3/rect, sdl3/render, sdl3/scancode, sdl3/sensor, sdl3/stdinc, sdl3/storage, sdl3/surface, sdl3/system, sdl3/thread, sdl3/thunks/bits, sdl3/thunks/endian, sdl3/thunks/rect, sdl3/thunks/stdinc, sdl3/time, sdl3/timer, sdl3/touch, sdl3/tray, sdl3/version, sdl3/video
* `generated/c/sdl3/linux-x86_64/` (generated, 60): sdl3/assert, sdl3/asyncio, sdl3/atomic, sdl3/audio, sdl3/blendmode, sdl3/camera, sdl3/clipboard, sdl3/cpuinfo, sdl3/ctypes, sdl3/dialog, sdl3/dlopennote, sdl3/endian, sdl3/error_h, sdl3/events, sdl3/filesystem, sdl3/gamepad, sdl3/gpu, sdl3/haptic, sdl3/hidapi, sdl3/hints, sdl3/init, sdl3/iostream, sdl3/joystick, sdl3/keyboard, sdl3/keycode, sdl3/layouts, sdl3/loadso, sdl3/locale, sdl3/log, sdl3/messagebox, sdl3/metal, sdl3/misc, sdl3/mouse, sdl3/mutex, sdl3/pen, sdl3/pixels, sdl3/platform, sdl3/platform_defines, sdl3/power, sdl3/process, sdl3/properties, sdl3/rect, sdl3/render, sdl3/scancode, sdl3/sensor, sdl3/stdinc, sdl3/storage, sdl3/surface, sdl3/system, sdl3/thread, sdl3/thunks/bits, sdl3/thunks/endian, sdl3/thunks/rect, sdl3/thunks/stdinc, sdl3/time, sdl3/timer, sdl3/touch, sdl3/tray, sdl3/version, sdl3/video
* `generated/c/tcl/linux-aarch64/` (generated, 11): tcl/ctypes, tcl/decls, tcl/layouts, tcl/oo, tcl/oodecls, tcl/platdecls, tcl/tcl, tcl/thunks/decls, tcl/thunks/oo, tcl/thunks/tcl, tcl/tommathdecls
* `generated/c/tcl/linux-x86_64/` (generated, 11): tcl/ctypes, tcl/decls, tcl/layouts, tcl/oo, tcl/oodecls, tcl/platdecls, tcl/tcl, tcl/thunks/decls, tcl/thunks/oo, tcl/thunks/tcl, tcl/tommathdecls
* `generated/c/tclstubs/linux-x86_64/` (generated, 12): tclstubs/ctypes, tclstubs/decls, tclstubs/layouts, tclstubs/oo, tclstubs/platdecls, tclstubs/tcl, tclstubs/thunks/decls, tclstubs/thunks/oodecls, tclstubs/thunks/platdecls, tclstubs/thunks/tcl, tclstubs/thunks/tommathdecls, tclstubs/tommathdecls
* `generated/c/win32/windows-x86_64-gnu/` (generated, 63): win32/apiset, win32/basetsd, win32/ctypes, win32/datetimeapi, win32/debugapi, win32/errhandlingapi, win32/fibersapi, win32/fileapi, win32/fltwinerror, win32/handleapi, win32/heapapi, win32/imm, win32/interlockedapi, win32/ioapiset, win32/jobapi, win32/ktmtypes, win32/layouts, win32/libloaderapi, win32/mcx, win32/memoryapi, win32/minwinbase, win32/minwindef, win32/namedpipeapi, win32/namespaceapi, win32/processenv, win32/processthreadsapi, win32/processtopologyapi, win32/profileapi, win32/realtimeapiset, win32/reason, win32/sdkddkver, win32/securityappcontainer, win32/securitybaseapi, win32/stralign, win32/stringapiset, win32/synchapi, win32/sysinfoapi, win32/systemtopologyapi, win32/threadpoolapiset, win32/threadpoollegacyapiset, win32/thunks/basetsd, win32/thunks/processthreadsapi, win32/thunks/winbase, win32/thunks/winnt, win32/timezoneapi, win32/tvout, win32/utilapiset, win32/virtdisk, win32/winapifamily, win32/winbase, win32/wincon, win32/windef, win32/winerror, win32/wingdi, win32/winnetwk, win32/winnls, win32/winnt, win32/winreg, win32/winsvc, win32/winuser, win32/winver, win32/wnnc, win32/wow64apiset
* `audit/c-header/results/boringssl-prefix/` (audit, 1): layouts.bot
* `audit/c-header/results/boringssl-shared/` (audit, 1): layouts.bot
* `audit/c-header/results/boringssl-static/` (audit, 1): layouts.bot
* `audit/c-header/results/tcl-embed/` (audit, 1): layouts.bot
* `audit/c-header/results/tcl-notommath/` (audit, 1): layouts.bot
* `audit/c-header/results/tcl-stubs/` (audit, 1): layouts.bot
* `audit/compiler-service/probes/json/` (audit, 1): json_probe.bot
* `audit/comprehensive-generated-code/bugs/` (audit, 4): handle-range-bigint.bot, handle-range-entry.bot, handle-return-result.bot, module-closure-from-user-fn.bot
* `audit/comprehensive-generated-code/probes/` (audit, 13): ascii-256.bot, byte-set-canonical.bot, byte-set-dynamic.bot, from-int-byte.bot, from-int-dynamic.bot, from-int-invalid.bot (REJECTED), from-int-literal.bot, from-int-nonneg.bot, steady-ascii-capture.bot, steady-ascii-param.bot, steady-ascii.bot, web-unreserved-256.bot, web-unreserved-literals.bot
* `audit/diagnostic-recovery/corpus/app-modules/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/call-arguments/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/functions-independent/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/if-missing-colon/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/loader-references/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/mixed-phases/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/poisoned-binding/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/resolution-taint/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/s13-argument/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/s13-generic/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/s13-return/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/s17-if-operand/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/s4-unhandled-set/` (audit, 1): program.bot (REJECTED)
* `audit/diagnostic-recovery/corpus/synthetic-closer/` (audit, 1): program.bot (REJECTED)
* `audit/direct-hir-native-path/probes/` (audit, 13): arg-cycle.bot, closures.bot, errors.bot, exact-callables.bot, loops.bot, module-call.bot, module-container.bot, module-web.bot (REJECTED), mutarray-typed.bot, self-recursion.bot, semantic-instances.bot, shadow-early-late.bot, shadow-param.bot
* `audit/encode-utf8-allocation/programs/` (audit, 2): escape-parity.bot, query-value-steady.bot
* `audit/exact-callable/probes/` (audit, 14): adv1.bot, adv2.bot, adv3.bot, adv4.bot, adv5.bot, alias.bot, capture-exact.bot, dynamic.bot, escapes.bot, listheld.bot, mixed.bot, native-single.bot, recursive.bot, returned.bot
* `audit/icy-tower/context-refactor/repro/` (audit, 11): a1-affine-pointer-in-context.bot (REJECTED), a1b-destructured.bot (REJECTED), a2-affine-aggregates-in-context.bot (REJECTED), b1-mutable-context-state.bot, b2-native-handle-table.bot, b2b-bare-native-view-slot.bot, c1-fallible-installation.bot (REJECTED), c1b-installation-handler.bot (REJECTED), c2-conditional-installation.bot (REJECTED), c3-affine-is-not-linear.bot, f1-extern-rename-crash.bot
* `audit/icy-tower/context-refactor/repro/e1-wrapper-context/` (audit, 2): main-both.bot, main.bot (REJECTED)
* `audit/icy-tower/context-refactor/repro/g1-view-leak/` (audit, 1): main.bot
* `audit/machine-code-proof-loss/probes/` (audit, 4): emailish-local-copy.bot, hof-capturing.bot, hof-single-exact.bot, hof-two-exact.bot
* `audit/parameterized-mutablearray/tools/` (audit, 1): guard-elision.bot (REJECTED)
* `audit/post-native-stack/module-cases/` (audit, 1): main.bot
* `audit/proof-census/probes/` (audit, 30): a-counted-loop-at.bot (REJECTED), b-mutarray-capacity.bot (REJECTED), c-slice.bot (REJECTED), d-early-return.bot (REJECTED), e-struct-domain-projection.bot (REJECTED), f-closed-abi-u64.bot (REJECTED), f2-closed-int-vs-struct.bot, g-induction-declared-param.bot (REJECTED), h-recursive-slice.bot (REJECTED), i-get-in-counted-loop.bot (REJECTED), k-method-spelling.bot (REJECTED), k2-bound-name-spelling.bot (REJECTED), l-loop-forms.bot (REJECTED), m-listloop-checked.bot, n-call-specific-transport.bot (REJECTED), o-lowercase-length.bot (REJECTED), p-param-inference-narrowing.bot (REJECTED), q-countloop-interval.bot (REJECTED), r-return-facts.bot (REJECTED), s-struct-facts.bot (REJECTED), sound-a-open-induction-specialized.bot (REJECTED), sound-a-open-induction.bot, sound-b-control.bot (REJECTED), sound-b-return-range.bot (REJECTED), sound-c-listloop-break.bot (REJECTED), sound-c-listloop-continue.bot, t-relational-prover-pairs.bot (REJECTED), u-handler-exit.bot (REJECTED), v-allocate-size.bot (REJECTED), z-soundness-neighbours.bot (REJECTED)
* `audit/react-native/probe/` (audit, 1): rnprobe.bot
* `audit/refactor/h1-attempt/` (audit, 1): ai_text_clean.bot
* `audit/refactor/h1-attempt/variants/` (audit, 3): list-local.bot, list-program.bot, string-local.bot
* `audit/refactor/kickoff-corpus/` (audit, 11): ai_text_clean.bot, csv.bot, csv_chunked.bot, csv_geometric.bot, csv_records.bot, hashtable.bot, lex-strategy.bot, matmul.bot, refined-strings.bot, string_replace.bot, string_reverse.bot
* `audit/refactor/ripple/` (audit, 5): as-merged.bot, list-loop.bot, ripple.bot, set-per-call.bot, set-program.bot
* `audit/strict-reference-determinism/experiment/` (audit, 3): csv_records-A-callee-first.bot (REJECTED), csv_records-B-caller-first.bot (REJECTED), csv_records-C-independent-order.bot (REJECTED)
* `audit/string-allocation/programs/` (audit, 1): large-string.bot (REJECTED)
* `audit/typed-mutarray-builder-refactor/out/experiments/` (audit, 3): join-gap-v0-early-return.bot (REJECTED), join-gap-v1-fresh-only.bot (REJECTED), join-gap-v2-raw-fresh.bot (REJECTED)
* `audit/value-transport-materialization/programs/` (audit, 11): direction-arg.bot, direction-ret.bot, late-frontier.bot, mixed-branch.bot, narrow-long-arg.bot, nested-local.bot, nested-long-arg.bot, nested-short-return.bot, wide-long-arg.bot, wide-long-return.bot, wide-short-return.bot
* `audit/vm-opcode-viability/botlish/` (audit, 2): fib30.bot, loop.bot
* `audit/windows-toolchain/programs/` (audit, 3): ffi-probe.bot, fib.bot, win32.bot
* `audit/hash-table/drivers/` (audit, 24): bench.bot + impl/cd.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/chain.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/chain0.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/ht0.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/listmap.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lp.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lpa.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lpc.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lpfact.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lpint.bot as table + drivers/keys_int.bot as keys (driver typed for int keys, as ht::typedDriver), bench.bot + impl/lpmask.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lpmono.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lpp.bot as table + drivers/keys_int.bot as keys (REJECTED), bench.bot + impl/lpstr.bot as table + drivers/keys_str.bot as keys (driver typed for str keys, as ht::typedDriver), bench.bot + impl/rh.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/sorted.bot as table + drivers/keys_int.bot as keys, bfs.bot + impl/lp.bot as table + drivers/keys_point.bot as keys, freq.bot + impl/lp.bot as table + drivers/keys_str.bot as keys, memo.bot + impl/lp.bot as table + drivers/keys_int.bot as keys, memo2.bot + impl/lp.bot as table + drivers/keys_int.bot as keys, trace.bot + impl/lp.bot as table + drivers/keys_int.bot as keys, hashes.bot + impl/listmap.bot as table + drivers/keys_int.bot as keys, bench.bot + impl/lp.bot as table + drivers/keys_point.bot as keys, bench.bot + impl/lp.bot as table + drivers/keys_str.bot as keys
* `audit/traits/principal/program/` (audit, 1): principal.bot (lib/ as its application root)
* `audit/compiler-service/probes/export/` (audit, 1): exports.bot (beside json/json_tokens.bot)
* `audit/icy-tower/context-refactor/variants/` (audit, 6): ids: main.bot (over the working tree, staged with sdl3), opaque-values: main.bot (over the working tree, staged with sdl3), canvas: main.bot (over the working tree, staged with sdl3), canvas: canvas-test.bot (over the working tree, staged with sdl3), canvas: golden-check-draws.bot (over the working tree, staged with sdl3) (REJECTED), canvas: golden.bot (over the working tree, staged with sdl3)

## 4. Compile failures (no evidence)

A program that does not compile is not evidence: the instrument reports
nothing for it. 61 units were rejected by the front end; each one's error
code and first message line is in `partition-a-units.tsv`.

**Deliberately rejected (29).** Each one's first diagnostic is the one its
header, report or harness expects:

* `examples/surface/09-mutual-recursion.bot` (CORE SEMANTIC UNBOUND) and
  `10-duplicate-binding.bot` (CORE SEMANTIC DUPLICATE): the deliberate
  rejections `audit/refactor/tools/sweep.tcl` lists.
* The diagnostic-recovery corpus, 14 programs (TYPE 5, MISSING-IMPORT 4,
  SYNTAX 3, UNBOUND 1, UNHANDLED-ERROR 1).
* Seven context reproducers of `audit/icy-tower/context-refactor/repro/`:
  a1 (AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE), a1b and a2
  (AFFINE-ERASURE-UNSUPPORTED), c1 (UNHANDLED-ERROR), c1b (SURFACE SYNTAX:
  `"with context" takes one expression and no block: write "with context
  EXPR" on its own line; the context is installed for the rest of the
  scope`), c2 (CONTEXT-INSTALLATION-UNSUPPORTED), `e1-wrapper-context/
  main.bot` (MISSING-CONTEXT: `lowlevel::Native is required by this call but
  is not installed here`). They are the census's evidence for section 6 of
  ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, not for this rule: each fails before
  a site could exist.
* `variants/canvas/golden-check-draws.bot` (CORE SEMANTIC
  CONTEXT-FUNCTION-VALUE: `function first_frame requires context
  recorder::Recorder, render::Canvas, so it can only be called ...`), the
  test its NOTES.md shows cannot be written.
* The hash-table experiment's `impl/lpp.bot` (SURFACE MODULE
  UNKNOWN-SYMBOL: `namespace "std::mutable_array" has no definition
  "probe_linear"`): it needs the experiment's compiler patch
  (`audit/hash-table/patches/probe-primitive.patch`, "not for main").
* Four probes whose rejection their header or report documents:
  `comprehensive-generated-code/probes/from-int-invalid.bot` (CORE SEMANTIC
  KNOWN-ERROR), `proof-census/probes/g-induction-declared-param.bot` (CORE
  SEMANTIC TYPE: `argument for parameter "i" cannot be proven to satisfy
  int[Small] (argument type: int, facts: [1, 1001])`, PROOF-FACT-CENSUS.md
  H), `proof-census/probes/p-param-inference-narrowing.bot` (CORE SEMANTIC
  TYPE) and `strict-reference-determinism/experiment/
  csv_records-B-caller-first.bot` (CORE SEMANTIC UNBOUND, the rejection
  STRICT-REFERENCE-DETERMINISM.md's table records).

**Stale (32): audit programs written for an earlier compiler.** None of the
32 files mentions `std::ffi::c`, `extern c`, `std::binary::native`, a native
view or edit, `Ptr[`, a context declaration, a context parameter or `with
context` (a grep of each file; none imports an application module), so no
evidence about the rule is lost:

* 24 of the 30 proof-census probes: SURFACE MODULE MISSING-IMPORT, e.g.
  `audit/proof-census/probes/a-counted-loop-at.bot:4:22: namespace
  "std::list" is not imported; add `import std::list` to use
  `std::list::length``. Their qualified names were rewritten to `std::`
  spellings without the import the std namespace requires.
* `strict-reference-determinism/experiment/csv_records-A-callee-first.bot`
  and `-C-independent-order.bot`: CORE SEMANTIC MUTABLE-PLACE-RECEIVER, `the
  receiver of std::mutable_array::set is not a place: it is a temporary
  value, so the updated array would be lost (a MutableArray is a value; bind
  it to a name, mutate the name, and use the name afterwards)`. Written when
  MutableArray had reference semantics (MUTABLE-ARRAY.md).
* `direct-hir-native-path/probes/module-web.bot`: error code NONE,
  `core::loadLibrary: no library "web" in stdlib` (its `# requires: web`
  header line).
* Five CORE SEMANTIC UNHANDLED-ERROR: `parameterized-mutablearray/tools/
  guard-elision.bot` (`IndexNotFound`), `string-allocation/programs/
  large-string.bot` (`LowerUnderrun` and `UpperOverrun`; its header records
  the value it once ran to), and the three `typed-mutarray-builder-refactor/
  out/experiments/join-gap-v*.bot` (`UpperOverrun`; once run with
  `main.tcl -aot-spec`).

## 5. Contextualized modules, and what they expose

A module is contextualized when it has direct edges and its own contexts
mediate every one (DIRECT-MODULES.md, section 11): the airlock the rule is
about. Across all 765 units, 8 module files and 2 entry programs are
contextualized (`main.tcl -direct` prints the same statuses: section 2).
"Exposes" means a top-level function (every one is public: a module has no
private members, IMPORTS.md) whose parameter or result types hold a C
address (`Ptr`, `FnPtr`) or a native view or edit, or a struct type holding
one.

| module (file) | context | functions | C-address-typed functions | view/edit-typed functions | structs holding them | sites across its boundary |
|---|---|---:|---|---|---|---|
| std::linux::io (`stdlib/linux/io.bot`, 15 units) | LinuxIO, opaque | 7 | none | none | none | 0 |
| std::darwin::io (`stdlib/darwin/io.bot`, 3 units) | DarwinIO, opaque | 7 | none | none | none | 0 |
| sdl, working tree (`examples/games/icy-tower/sdl.bot`; the canvas variant's main.bot compiles it too) | Sdl, opaque | 25 | 7, parameters only: write_text, log_failure, free_text, release, remember, quit_requested?, down? | 2, parameters: write_text_unchecked (NativeEdit[TextBuffer]), remember (NativeEdit[Handles]) | Session (a NativeView[Handles] field), Sdl (opaque; its MutableVector[Session]) | **0** |
| sdl, baseline (`6df89a8e:.../sdl.bot`) | Sdl | 21 | 15: open (result: Video), poll (Video in, Polled out), close, color, clear, present, fill, line, text, scale, write_text, log_failure, free_text, quit_requested?, down? | 1: write_text_unchecked | Video and Polled, not opaque | 40 hit |
| sdl, ID variant (`variants/ids/sdl.bot`) | Sdl, opaque | 26 | 6, parameters: write_text, free_text, free_rect, free_event, release, quit_requested? | 2: write_text_unchecked, store_rect | none | 0 |
| sdl, Design A (`variants/opaque-values/sdl.bot`) | Sdl, opaque (authority only) | 27 | 10: open (r), poll (r, p), show (r, p), close (p) through the opaque Video; write_text, log_failure, free_text, quit_requested?, down?, performed? with raw pointer parameters | 1: write_text_unchecked | Video (opaque), Polled, Shown | 8 hit |
| airlock (`repro/g1-view-leak/airlock.bot`) | Airlock, opaque (MutableVector[NativeView[Record]]) | 4 | none | 2: hello (NativeEdit[Text] parameter), record (NativeView[Record] result) | Airlock | 1 hit (R3) |
| wrapper (`repro/e1-wrapper-context/wrapper.bot`) | Platform, opaque | 2 | none | none | none | 0 |
| entry program `repro/b2-native-handle-table.bot` | Store | 5 | none (its 3 `extern c fn`s, 2 with pointers, are its own) | 1: write_hello (parameter) | Session, Store (opaque) | an entry program has no importer |
| entry program `repro/b2b-bare-native-view-slot.bot` | Memory, Store | 3 | none | none | Store (opaque) | an entry program has no importer |

So: the standard library's two airlocks expose nothing raw; every SDL
airlock exposes raw-typed functions, because its private helpers cannot be
private; only the baseline and Design A have callers across the boundary.
A declaration-site rule ("a contextualized module declares a public
function with a pointer or view in its signature") would flag the working
tree's 9 functions and the ID variant's 8 although nothing outside uses
them; the call-site instrument does not.

The other statuses, for completeness. **Designated direct:**
std::linux::sys (both architecture files), std::linux, std::darwin, and
e1's `raw` module; and eleven direct entry programs (`examples/linux/
getpid.bot`, `read-stdin.bot`, `write.bot`, `examples/ffi/bindgen/sdl3/
demo.bot`, and the golden suites abi-bytes, abi-bytes-native,
abi-numeric-native, imports-abi-child, linux-io, linux-io-native,
linux-transports). The designated-direct bucket stays empty: no call from
another unit into a direct module carries a pointer or a view
(std::darwin::io calls std::darwin with `std::ffi::c::Int` descriptors and
byte storage). **Ordinary modules that declare a context struct**
(context-but-ordinary candidates; no site involves one): std::windows::io
(WindowsIO: ordinary because std::windows is not direct), std::test
(Suite), e1's `lowlevel` (Native), and context-declaring entry programs
(b1, canvas-test.bot, 15 golden suites). **Ordinary modules exposing C
pointers**: std::windows (`standard_handle` returns, `write_file` takes, a
`Ptr[Void]` handle), examples/ffi/tcl/tcl.bot (`eval` takes the
interpreter), the baseline's and Design A's render.bot (they forward
sdl's Video), and every generated binding module through its `extern c
fn`s (325 of the 383 declare 16,175 externs; 305 modules declare 14,226
with a pointer parameter or result; none is a Botlish function: the 46 Botlish functions of the eight `ctypes`
modules take and return no pointer).

## 6. The sites

Totals (distinct sites; a site counts each rule it carries):

| | sites | R1 | R2 | R3 | R4 | SUSPICIOUS | LEGITIMATE | UNDECIDABLE |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| hit | 49 | 43 | 37 | 1 | 5 | 41 | 8 | 0 |
| context-but-ordinary | 0 | | | | | | | |
| no-context | 10 | 8 | 7 | 0 | 2 | 0 | 10 | 0 |
| designated-direct | 0 | | | | | | | |
| **all** | **59** | 51 | 44 | 1 | 7 | 41 | 18 | 0 |

By rule and classification: R1 37 SUSPICIOUS / 14 LEGITIMATE; R2 37 / 7
(all 7 no-context); R3 1 / 0; R4 3 / 4.

**A. The baseline Icy Tower (6df89a8e), 42 sites.** In render.bot, 34 hit
R1+R2 calls into sdl (color, fill, line, text, scale, clear, present: each
takes the renderer, a raw `Ptr[SDL_Renderer]`) and 2 hit R4 sites
(`sdl::Video` destructured at 146:5 and rebuilt at 158:19); in main.bot, 3
hit R1+R2 calls (`sdl::poll` at 92:52, `sdl::open` at 123:13, `sdl::close`
at 134:5) and 1 hit R4 (the `sdl::Polled` poll returns, destructured at
92:5). **All 40 hits SUSPICIOUS**: sdl is
contextualized -- its Sdl context mediates every raw SDL call -- and still
hands the session's pointers to the game, which threads them through every
frame and exit; the working tree is the proof that they could stay behind
the context (0 sites, same behavior). The 2 no-context sites (main.bot's
call of `render::draw` and its `render::Drawn` destructured) are
**LEGITIMATE as sites of this rule**: render is ordinary, declares no
context and makes no direct call, so it has no authority to keep anything
behind; it forwards sdl's Video, and the leak is reported where it
originates (both disappear with it in the working tree).

**B. Reproducer g1, 1 site, SUSPICIOUS.** `main.bot:39:12`, entry ->
airlock, R3, `call airlock::record`: the contextualized airlock returns the
unrestricted view of its native record and the ordinary entry program reads
a C string pointer out of it and passes it to strlen, with no diagnostic
and no directness. Written to show the hazard (census section 5); the
airlock could read the record inline behind its context.

**C. Design A (variants/opaque-values), 10 sites, LEGITIMATE.** 6 hit R1
calls (`sdl::open`, `sdl::poll`, `sdl::show`, three `sdl::close`), 2 hit R4
(`sdl::Polled` destructured in main.bot, `sdl::Shown` in render.bot), and
the no-context `render::draw` call and `render::Drawn` destructuring. The
crossing type is the opaque affine `sdl::Video`: ownership crosses the
airlock, the representation does not (R2 and R3 never fire;
OPAQUE-REPRESENTATION outside sdl.bot). It is the design's intent
(variants/opaque-values/NOTES.md), and it buys what the context-retained
design gives up: use after close and double close are static errors
(USE-AFTER-MOVE; census section 7). The R4 sites take apart carriers whose
pointer-holding field is that opaque Video: no pointer representation is
exposed. By the literal criterion -- ownership handed across although it
could stay behind the context -- these are the targeted shape; they are
classified LEGITIMATE because the escape is intended and sealed, and the
compiler can tell them apart from A and B by a fact it has (opacity), not
by intent.

**D. std::windows::io -> std::windows, 4 sites, no-context, LEGITIMATE.**
`stdlib/windows/io.bot:78:5`, `82:5` and `100:14` (`write_file`) and
`97:14` (`standard_handle`), seen by the module's loader, hello-windows and
2048's demo-windows. std::windows is the thin Win32 layer: ordinary and
context-free, no airlock ("every C call here retains nothing", its header).
The pointer is a borrowed standard handle that std::windows::io fetches and
hands back within one call and never stores (a C pointer cannot live in a
context: AGENTS.md, "Windows I/O").

**E. examples/ffi/tcl/demo.bot -> tcl, 2 sites, no-context, LEGITIMATE.**
`29:11` and `30:10`, `tcl::eval(interp, script)`: tcl.bot is a hand-written
thin binding with no context and no direct edge; the program owns the
interpreter by design (creates and deletes it) and lends a clone.

**UNDECIDABLE: none.** Every site's verdict follows from facts the HIR
has: the airlock's status (contextualized or not), the crossing type and
whether an opaque struct seals it. The information a harder case would
lack -- whether a pointer a caller passes into an airlock is the airlock's
own resource handed back (baseline) or the caller's own (an ordinary
argument the airlock only borrows), i.e. pointer provenance across calls --
did not arise: every R1/R2 site here passes back a pointer the airlock
itself produced (sdl::open's Video, std::windows's standard handle) or one
the program created through a context-free binding (tcl).

## 7. What the instrument does not see

The instrument's call rules follow calls of Botlish functions with an exact
callee (`escape::CalleeBlock`). Two supplementary measurements of
`scan.tcl` cover what that leaves out:

* **C calls across a module boundary on a pointer** (`XCALL`: a call from
  unit V of an `extern c fn` another unit U declares, with a pointer or view
  among its argument and result types), on the 344 units whose modules
  declare an extern: 133 distinct locations, every one into an ordinary,
  context-free binding -- 118 from an SDL airlock into the generated sdl3
  modules (28 working tree, 24 baseline, 42 ID variant, 24 Design A), 15
  from a program into its binding (examples/ffi/tcl 2, bindgen sdl3 demo 9,
  bindgen tcl demo 4). None calls an extern of a contextualized module or of
  a module that declares a context: the airlocks that declare externs
  (airlock's malloc, b2's) call them only themselves. A rule over Botlish
  calls alone misses nothing here.
* **Functions taken as values** (`VREF`: a reference from unit V to a
  function of a contextualized module U that is not a call's callee), on
  the 22 units that compile a contextualized module: **0**. Positive
  control: a scratch program beside a copy of g1's `airlock.bot` binding
  `f = airlock::hello` reports `VREF ... entry airlock view airlock::hello`
  and no instrument site. A function that requires its module's context
  cannot become a value at all (CONTEXT-FUNCTION-VALUE), so this gap is
  limited to an airlock's context-free functions, such as its pointer- and
  view-typed helpers.
* **Context traits** are not counted as context declarations by the
  instrument's buckets (it reads context structs from `hir::sourceTypes`):
  std::io's `IO` and the canvas variant's `render::Canvas` are context
  traits. No site involves a module declaring only a context trait.
* **R4's search** follows C addresses through opaque structs (the carry
  mode), so it fires on Design A's carriers of an opaque value (section 6,
  C), unlike R2.

## 8. What this partition says about the warning

* **On everything shipped, the warning would be silent**: 0 hits in
  stdlib, examples (the refactored game included), bench, golden suites and
  generated bindings. Its only targets in the repository are the code
  written to exhibit the problem (the baseline game, g1).
* **R2 and R3 are the precise rules.** In the hit bucket they flag 38
  sites, all SUSPICIOUS, and miss none of the SUSPICIOUS calls (the other 3
  SUSPICIOUS sites are R4 on non-opaque pointer records, which R4 restricted
  to R2's opaque stop keeps).
* **R1 alone is a design choice, not a defect**: its 6 lone hits are all
  Design A's sealed affine resource value, a legitimate (and in one respect
  safer) architecture. A warning on R1 alone would push Design A to Design
  B, which this census recommends for Icy Tower (section 7) but which is not
  a compiler-provable defect -- and warnings must be backed by a compiler
  proof with no opt-out (AGENTS.md, "Compiler warnings").
* **Buckets other than hit stay empty or legitimate**: no context-but-
  ordinary or designated-direct site exists; the 10 no-context sites are
  thin bindings and pass-through modules.
* **The airlocks' raw helpers are public but unused outside**: 9 (working
  tree) and 8 (ID variant) pointer- or view-typed functions with no
  cross-module use. A call-site rule leaves them alone; only module privacy
  (IMPORTS.md, not done) would hide them.

## 9. Reproducing

```sh
export LANG=C.utf8 LC_ALL=C.utf8
W=$(mktemp -d)
tclsh9.0 audit/icy-tower/context-refactor/warning-census/units-a.tcl "$W" > "$W.units.tsv"
tclsh9.0 audit/icy-tower/context-refactor/warning-census/scan.tcl "$W.units.tsv" -shard 1/2 > "$W.raw1" &
tclsh9.0 audit/icy-tower/context-refactor/warning-census/scan.tcl "$W.units.tsv" -shard 2/2 > "$W.raw2" &
wait
tclsh9.0 audit/icy-tower/context-refactor/warning-census/classify-a.tcl "$W.units.tsv" "$W.raw1" "$W.raw2" \
    -out audit/icy-tower/context-refactor/warning-census
rm -rf "$W" "$W".*
```

About 30 minutes on two shards of a shared 4-core container (1,776 s of
front-end time; the golden suites are three quarters of it). The SDL3
binding comes from `generated/c/sdl3/`; no native backend, C compiler or
SDL library is needed (front end only).
