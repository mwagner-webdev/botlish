# RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1

## Full-width native C pointers and byte exposure on Android, without regressing desktop performance

Evidence categories, as in the earlier Android reports: **observed**
(executed in this environment: a 4-core Intel Xeon @ 2.10 GHz Linux
x86-64 container, rustc 1.97.0, Tcl 9.0.1, the Android NDK r29
29.0.14206865, qemu-user 8.2.2 and Google's pinned arm64-v8a system images
of API 21, 24 and 35), **static** (source or artifacts inspected), **CI**
(a completed workflow on another host), **projected** (a design consequence
not executed).

## 1. Executive result

Android applications run with Bionic's heap pointer tagging **on**
(**observed**, API 35, 4 KiB and 16 KiB pages, also under GC stress): byte
exposures of Botlish storage to C, C pointers returned, stored in an
installed context, handed back, read from C records, stored through native
edits, passed to and from callbacks, Bionic's `qsort` calling back with
pointers into an exposed buffer, and SDL3's surfaces over the committed
Android binding -- every pointer arriving with Bionic's `0xb4` tag in its
top byte and leaving with it, bit for bit, no application opting out.

The design is **target-specialized at compile time, one word, no
allocation anywhere**:

* A C address word is `(rotl(address, R) << 4) | 0b1110`. R is **0** on
  every desktop target -- exactly the word every earlier runtime made, so
  Linux, macOS and Windows code is **byte-identical** (CLIF compared,
  **observed** on x86-64; **static** for the other desktop targets through a
  code-generation test) and their runtime ABI fingerprints are **unchanged**
  (`14aa5041bb46ae5d` before and after on Linux x86-64). R is **8** on
  Android AArch64: the whole top byte is kept and bits 52..55 must repeat
  bit 51, which every user and kernel address of a 48-bit address space
  does, tagged or not. One extra `ror` per encode and decode, on Android
  only.
* A C call's byte exposure is no longer a Botlish value: the call takes the
  exposed storage and makes its payload address itself (an inline kind
  check, then the storage plus the payload offset) -- a machine word of the
  full width. This removed a runtime helper call per exposure: read
  exposures are **~1.5 ns faster** on x86-64 (**observed**), with no new
  runtime helper (so no fingerprint change for it either).

Ordinary Int semantics, ownership, nullability, lifetimes and checked
failures are unchanged; no pointer arithmetic, integer-to-pointer
conversion or unsafe surface was added.

## 2. The original defect

Reproduced with the unmodified compiler and runtime at the base commit
`ce54fead` (`/root/botlish-baseline`, its own driver and Android runtime
package, fingerprint `14aa5041bb46ae5d` for Android too), in Android
processes (`audit/android-tagged-pointers/tools/probe.sh`, **observed**;
outputs in `audit/android-tagged-pointers/results/baseline-*`):

| API | Program | Tagging | Result |
|---|---|---|---|
| 21, 24 | hello, heap, tagged, sdl_surface | (none: Android 10 and earlier) | `MAIN 0 0`, `MAIN 1 0` |
| 35 | hello (liblog over byte exposures) | on | `MAIN 0 2 CORE SEMANTIC RANGE std::abi::x86_64::from_bytes: the payload address 0xb40040011b51c620 is outside the small-Int range` |
| 35 | heap (a C heap pointer, no exposure) | on | `MAIN 0 2 NATIVE ADDRESS the C function tp::alloc returned the address 0xb4004001a50dcb00, which a Botlish C pointer cannot hold (its word keeps a sign-extended 60-bit address: a top-byte-tagged pointer is not one)` |
| 35 | sdl_surface (SDL3) | on | `MAIN 0 2 NATIVE ADDRESS the C function sdl3::surface::SDL_CreateSurface returned the address 0xb4004000eee5aa30, ...` |
| 35 | every program, tagging turned off first (`mallopt`) | off | `MAIN 0 0`, `MAIN 1 0` |

The two failure paths are independent: the exposure (a small Int of 62
bits) and the C address word (sign-extended 60 bits). The SDL3 row is the
earlier milestone's projected `SDL_CreateWindow` failure, now observed on a
real SDL3 function returning a heap pointer.

## 3. Pointer representation census

Every place a native address is made, held, compared or handed over
(**static**; `grep` of `CPTR_TAG`, `make_cptr`, `cptr_address`,
`cptr_fits`, `sshr_imm_s(_, 4)`, `bytesaddr` over `native/`):

| Pointer category | Representation before | Bits a target needs | Escapes to C? | Treatment |
|---|---|---|---|---|
| Ordinary Botlish Int | small Int (62 bits) or BigInt | language-defined | as numeric data | unchanged |
| C data / function pointer (`Ptr`, `FnPtr`) | C address word, sign-extended 60 bits | Android: tag byte + 48-bit VA | yes | the target's encoding (R = 0 or 8) |
| C pointer result (`foreign_result`) | inline `<< 4`, fits check | as above | from C | `cptr_rotated` then the check, NATIVE ADDRESS otherwise |
| C pointer argument, variadic pointer (`foreign_call`, `vararg_value`) | inline `sshr 4` | as above | yes | `cptr_address`: `sshr 4`, `rotr R` |
| Callback entry address (`cbaddr`) | inline `<< 4` | code addresses: untagged | yes | rotated (fits every encoding) |
| Callback parameters and results (runtime/callback.rs) | `make_cptr`/`cptr_address` | as above | from and to C | the runtime's encoding |
| Native view / edit (`NativeView[L]`, `NativeEdit[L]`), nested views (`cptroffset`) | C address word | as above | memory reads/writes | the runtime's encoding |
| Pointer field read through a view (`nativeloadptr`) | `cptr_fits` | as above | from memory | the runtime's encoding |
| Pointer stored by an edit or into bytes (`pointer_bits`) | `cptr_address` | full width | to memory | the full decoded address |
| Null | the bare tag, 14 | 0 | yes | 14 under both encodings (`rotl(0) = 0`) |
| C call byte exposure (BorrowCall) | `op bytesaddr`: small Int, `sshr 1` at the call | full width | yes | the storage itself; the call makes `storage + 16` |
| Fixture operations' exposures (test-only) | small Int | host | no (test helpers) | unchanged |
| Linux syscall bridge (`std::abi::*::from_bytes`) | small Int (a Register64 Int) | Linux heaps: untagged | to the kernel | unchanged (an Int by type; section 7) |
| GC references | heap pointers, low bits `000` | runtime-internal | no | unchanged (never C address words) |
| Native-library boundary | C scalars, owned strings/errors | n/a | yes | no pointer type crosses (`exported c fn`) |

Width assumptions found: `value.rs`'s `cptr_fits` (60), four inline sites
in `codegen/clif.rs`, `ops.rs`'s `rt_bytes_addr`/`rt_mbytes_addr` (62,
through the C call), and none elsewhere -- every runtime path goes through
`cptr_fits`/`make_cptr`/`cptr_address`.

## 4. Android's tagging contract

Android 11 and later tag every Bionic heap pointer's top byte (`0xb4` in
the TBI mode these images use; MTE tags live in bits 56..59 of the same
byte), and AArch64's Top Byte Ignore makes the tag invisible to loads and
stores. The tag must survive: `free` and Bionic's heap checks compare it.
Bits 48..55 of a user address are zero (bit 55 selects TTBR0), so a tagged
user pointer is `[tag:8][0:8][address:48]`.

Observed values (**observed**, API 35, tagging on; addresses differ from
run to run, ASLR; these are the committed result files'):

| Pointer | Value |
|---|---|
| liblog exposure address (baseline refusal) | `0xb40040011b51c620` |
| a C heap block (`tp_alloc`, baseline refusal) | `0xb4004001a50dcb00` |
| `SDL_CreateSurface` result / its `pixels` | `0xb4004001d61070b0` / `0xb4004001d6103860` (C test, `sdltry/t3.c`) |
| the top byte C reads of a Botlish exposure and of a heap block, after the fix | `180` (`0xb4`) |

Tagging is shown to be genuinely on: the probe's C side reads the top byte
of each address itself (`tp_top_byte`, `tp_exposed_top_byte`) and reports
180 on API 35 and 0 on API 21 and 24 and with tagging turned off; the tests
require exactly that, so an environment without tagging fails the tagged
expectation rather than passing silently.

## 5. Representation alternatives

| Criterion | Compact existing | Universal full-width (boxed) | Target-specialized rotation (chosen) | Compact + boxed fallback |
|---|---|---|---|---|
| Correct on tagged Android pointers | no | yes | yes (48-bit VA, any tag) | yes |
| Desktop conversion cost | baseline | an allocation per pointer result; a load per use | **identical code** | a branch per conversion |
| Android conversion cost | refuses | an allocation per pointer result | one `ror` each way | an allocation for **every** heap pointer (all are tagged) |
| Allocation | none | per pointer | none | per tagged pointer |
| Runtime memory | one word | word + 16-byte object | one word | as boxed on Android |
| GC | never a root | a new rooted kind | never a root | a new rooted kind |
| Codegen complexity | -- | every site, plus stack maps | two helpers, four sites | every site, two paths |
| ABI impact | -- | every target | Android only | every target |

Measured where it decides: the boxed representations' allocation per
pointer would add a `rt_*` allocation (tens of ns, plus collector work) to
`ptr result` and `ptr echo`, which cost **0.7-1.7 ns** today (section 18);
the rotation costs one ALU instruction. The rotation's limit: an AArch64
address of a **52-bit** user address space with bit 51 set (only reachable
on Linux by an explicit high `mmap` hint; Android's kernels use 39- or
48-bit spaces) does not fit -- it is refused NATIVE ADDRESS, never
truncated (section 25).

## 6. The design decision

**Target-specialized, chosen at compile time.** The universal options are
rejected on cost (an allocation per pointer, a new GC-rooted kind) and on
compatibility (every desktop fingerprint, stub and object would change for
no desktop benefit). The fallback option degenerates to the boxed one on
Android, where every heap pointer is tagged. The rotation keeps one
immediate word everywhere, adds nothing on desktop -- the same CLIF, the
same objects, the same fingerprints -- and one rotation each way on
Android.

The policy is a property of the target's pointer ABI ("pointers carry a
tag in their top byte"), stated once for every target in
`native/src/codegen/target.rs:138` (`address_word`) and once by each
runtime for its own build in `native/src/runtime/value.rs:178`
(`ADDRESS_WORD`, `cfg!(target_os = "android")`); a test requires the two
to agree for the host (`address_word_is_the_runtimes`). No OS name is read
anywhere else, and nothing is decided per call at run time.

## 7. Native C pointer implementation

`native/src/runtime/value.rs:110` `AddressWord` (`Canonical60`,
`TopByteTagged`) with `rotation`, `fits`, `encode`, `decode` and `holds`
(the NATIVE ADDRESS text); `cptr_fits`, `make_cptr`, `cptr_address`
(`:1030-1043`) are the runtime's only paths. Generated code:
`codegen/clif.rs:1540` `cptr_address` (decode: `sshr 4`, `rotr R`) and
`:1551` `cptr_rotated` (encode's rotation), used by the argument and
variadic decodes, the result's encode and fits check (`:1622`) and the
callback address (`:2208`). The translator reads the encoding from the
module's ISA triple (`address_word` field), never from the host.

Preserved by construction: null (14 under both), distinct tags are distinct
words (`distinct_addresses_are_distinct_words`), `-1` (`MAP_FAILED`) and
small integers cast to pointers fit both encodings. Refused, never fixed: an
address whose bits 52..55 do not repeat bit 51 on Android, whose bits 60..63
do not repeat bit 59 elsewhere.

The Linux syscall bridge `std::abi::*::from_bytes` keeps its small-Int
contract: its value is a Register64, an Int a program sees, used only by
the Linux syscall transports (`std::linux` is Linux's platform; Android
imports none of it), and Linux heaps carry no tag. Making it a BigInt or a
C address word would change an Int's meaning or invent an
integer-to-pointer path; neither is needed.

## 8. Byte exposure

`native/lower.tcl` BorrowCall now hands a C call the exposed **storage**
(`foreigncall F %s ... exposed=I [mutable=I]`, `:6178`); the call
(`codegen/clif.rs:1521` `exposure_address`) checks its kind inline
(`KIND_BYTES`, or `KIND_MUTBYTES` for `mutable=`; a wrong kind takes the
slow path to `rt_bytes_addr`/`rt_mbytes_addr`, which raise the TYPE
refusal they always did) and passes `storage + BYTES_PAYLOAD_OFFSET`. The
address exists only in a machine register during the call: no Botlish
value holds it, so no width limit applies. The write exposure's private
copy (`mbytesclone`), the keepalive after the call (`KeepStoragesAlive`,
`:6043`) and every borrow rule (contracts, noescape, access) are unchanged;
the fixture's operations and the syscall bridges keep `bytesaddr`.

On Android the address C receives carries Bionic's tag (Botlish's heap is
Rust's system allocator, Bionic's `malloc`): `exposure 180 36` -- the top
byte C reads and the sum it computes over the right bytes (**observed**).
Writes through a write exposure land in the private copy and come back
(`write true`).

## 9. Lowering and code generation

NIR gains `mutable=` on `foreigncall` (`nir.rs`: a subset of `exposed=`,
validated; `fusion.rs` and `nirtext.rs` carry it). `codegen/mod.rs:713`
records the target's runtime fingerprint in the program record
(`target::runtime_fingerprint`). A code-generation test compiles one NIR
program -- a pointer echoed through C and an exposure -- for five triples
(`codegen::clif::address_word_tests`): Android's CLIF has `rotl`/`rotr` by
8, Linux x86-64, Linux AArch64, macOS AArch64 and Windows x86-64 have none,
and every exposure is an `iadd` of the payload offset.

## 10. The C binding generator

No change: generated bindings declare `Ptr[...]` and layouts; the encoding
is below them. The committed android-aarch64 SDL3 binding is used
unchanged by the SDL3 probe (section 16); no binding was regenerated.

## 11. Native ownership

Pointers stay affine values with no runtime ownership state; the
encoding changes only the payload bits above the unchanged four-bit tag.
A heap block kept in an installed opaque context (`Heap.block`), observed
through a context place, handed back and finally freed: `heap 180 same`,
`release done` (**observed**). Resources' cleanup, thread affinity and
sendability rules are untouched (no code there changed).

## 12. GC correctness

C address words keep the low bits `1110`, never a heap pointer's `000`, so
the collector's classification is unchanged; byte exposures add no root
(the storage was and is kept by the keepalive after the call). The probe
passes under `BOTLISH_NATIVE_GC_STRESS=1` on API 35 with tagging on
(**observed**), and the desktop files touching pointers and exposures pass
(section 23).

## 13. Application-library compatibility

`NAME_main`, schema 3 and the entry dispatch are unchanged. Every probe is
an application library run by the earlier milestone's host (`MAIN 0 0`,
`MAIN 1 0`, twice per process). A library's manifest now states its
target's runtime fingerprint as `compiler.runtimeAbi`
(`native/library.tcl`), equal to its target support package's
(`at-tagged-manifest`), as the React Native tool requires.

## 14. Native-library compatibility

No export signature, ownership rule or manifest schema changed. Desktop
libraries' manifests state the same fingerprint as before (it is the
host's). `tests/native-library.test` and `tests/application-library.test`
pass (section 23).

## 15. Android execution

`audit/android-tagged-pointers/results/fixed-summary.txt` (**observed**,
with the fixed compiler and its Android package, fingerprint
`637264e0003a0b68`):

| API | Pages | Tagging | hello | heap | tagged probe | sdl_surface |
|---|---|---|---|---|---|---|
| 21 | 4 KiB | none | 0 0 | 0 0 | all checks, tags 0 | all checks, tags 0 |
| 24 | 4 KiB | none | 0 0 | 0 0 | all checks, tags 0 | all checks, tags 0 |
| 35 | 4 KiB | **on** | 0 0 | 0 0 | all checks, **tags 180** | all checks, **tags 180** |
| 35 | 4 KiB | off (`mallopt`) | 0 0 | 0 0 | all checks, tags 0 | all checks, tags 0 |
| 35 | 16 KiB | **on** | -- | -- | all checks, tags 180 | -- |
| 35 | 4 KiB, GC stress | **on** | -- | -- | all checks, tags 180 | -- |

The tagged probe's lines, twice per process
(`results/fixed-35-tagged.txt`): `log called`, `exposure 180 36`, `write
true`, `heap 180 same`, `view 77 0`, `record same same`, `callback same`,
`qsort true`, `null true same`, `release done`. Nothing turns tagging off:
no manifest attribute, no `mallopt` (only the comparison hosts built with
`-DNO_HEAP_POINTER_TAGGING` do, as before).

This is an Android process's userspace (Android's linker, Bionic, liblog,
libandroid, libSDL3) under qemu-user on a Linux kernel: no ART, Activity,
or MTE hardware.

## 16. SDL3 integration

`audit/android-tagged-pointers/android/sdl_surface.bot`, over the committed
android-aarch64 binding and Android's libSDL3.so (3.4.18, NDK r29, API 21):
`SDL_CreateSurface` (a tagged `SDL_Surface *`), `SDL_FillSurfaceRect`, the
`pixels` field -- a tagged pointer inside SDL's struct -- read through the
generated `SDL_Surface` layout's native view and read through,
`SDL_DuplicateSurface`, both `SDL_DestroySurface` (**observed**: `sdl
surface 180 180 8x8 32`, `sdl fill true 287454020 287454020`, `sdl
duplicate 287454020`, `sdl destroyed` on API 35 with tagging on; the
baseline refuses `SDL_CreateSurface`'s result).

Why surfaces, not a window: `SDL_Init` needs Android's Java side (JNI) --
in a C-only Android process it crashes before any Botlish code runs (a C
program calling `SDL_Init(SDL_INIT_EVENTS)` alone, **observed**), and the
software renderer waits on the platform; SDL's surfaces need neither.
Icy Tower's library loads and starts under `SDL_RunApp` and stops in
`SDL_Init` there. Window and renderer pointers on Android are the next
milestone's, in an Activity (section 26). libSDL3.so's dependency on
libandroid needs ICU on Android 10+: `audit/android-tagged-pointers/tools/
apex.sh` unpacks the pinned image's i18n APEX (Android 21 and 24 keep ICU
in /system).

## 17. Desktop compatibility

* The C address word, objects and generated code of Linux, macOS and
  Windows are the default encoding's: byte-identical CLIF for every
  pointer-only program before and after (section 18); fingerprints
  unchanged.
* Exposure programs' code changed (the helper call replaced by an inline
  check and add), as intended; every desktop test that runs C passes.
* `runtime-abi` gains an `address-word` line; `runtime-abi TRIPLE` is new.

## 18. Desktop performance

`bench/tagged-pointers.tcl`, baseline (`-root /root/botlish-baseline`,
`ce54fead`) and this change run alternately twice on the same idle machine;
ns per iteration, best of 9 runs of 2,000,000 iterations of a fold that
allocates nothing; "op" is the operation's cost over the fold's trivial
body (**observed**, Linux x86-64):

| Operation | baseline 1 | baseline 2 | new 1 | new 2 | CLIF |
|---|---:|---:|---:|---:|---|
| ptr result (`bcf_address()`) | 0.76 | -0.21 | 0.71 | 0.91 | identical |
| ptr argument (`bcf_is_null(p)`) | 2.43 | 1.82 | 0.62 | 1.50 | identical |
| ptr echo | 2.21 | 1.52 | 1.47 | 1.69 | identical |
| ptr same (two decodes) | 1.82 | 1.31 | 0.86 | 1.02 | identical |
| `null?` | -0.07 | 0.47 | -0.47 | -0.04 | identical |
| context-held handle | 1.95 | 1.46 | 0.35 | 0.22 | identical |
| read 64 B exposure | 3.94 | 4.05 | 2.77 | 2.47 | changed |
| read 64 KiB exposure | 4.52 | 4.16 | 2.77 | 2.14 | changed |
| write 64 B exposure | 44.88 | 45.50 | 43.42 | 42.37 | changed |
| write 64 KiB exposure | 1631.26 | 1664.31 | 1635.22 | 1626.41 | changed |
| text 64 B (C reads every byte) | 23.90 | 24.98 | 22.28 | 22.61 | changed |
| control (no C: Int arithmetic) | 0.26 | -0.15 | 0.87 | 0.93 | identical |

Where the CLIF is identical the differences are code placement and noise
(the trivial fold's own time moves between 0.95 and 3.4 ns from program to
program: alignment), not the operation; nothing changed in the code.
Exposures got faster: about 1.5 ns per read exposure (the `rt_bytes_addr`
call is gone). No desktop allocation was added anywhere.

Application level, Icy Tower's 600-frame autopilot: section 18a.
Linux AArch64, macOS AArch64 and Windows x86-64: the same CLIF claim holds
statically (`desktop_code_never_rotates` compiles for each); their timing
is CI's (section 23), not measured here.

### 18a. Icy Tower and the footprint

Icy Tower built by `examples/games/icy-tower/build.sh` with each checkout
against the same libSDL3.so (3.4.18), run `--autopilot --fixed-step
--frames 600 --seed 17` on SDL's dummy driver (**observed**): both print
the identical summary (`frames=600 ... score=360 ... rng=659525717`).
Instructions under callgrind (deterministic: the baseline run twice gives
the same count):

| Object | before | after | difference |
|---|---:|---:|---:|
| the program and runtime (icy) | 294,086,969 | 293,909,980 | -176,989 (-0.06%) |
| libSDL3.so | 638,891,193 | 638,891,193 | 0 |
| libc (malloc internals: `_int_malloc`, `malloc_consolidate`) | 81,944,938 | 82,312,545 | +367,607 |
| total | 1,051,883,847 | 1,052,096,194 | +212,347 (+0.020%) |

The program's own instructions went down (its exposures lost their helper
call); glibc's allocator did more work for the same calls (its free lists
start from another heap state: the executable's layout differs), a
difference unrelated to pointers. Wall time, alternating runs on a machine
also running mutation tests: best of 7, 301 ms before and 302 ms after.

Footprint (**observed**, Linux x86-64; stripped sizes in parentheses):

| Artifact | before | after |
|---|---:|---:|
| single-file compiler (`single/build.sh`) | 15,607,833 | 15,610,549 (+2,716) |
| driver `botlish-native` | 61,417,960 (10,053,576) | 61,476,168 (10,068,568) |
| runtime archive `libbotlish_runtime.a` | 41,325,388 (13,602,794) | 41,440,104 (13,596,330) |
| stub `botlish-aot-stub` | 12,054,264 (1,263,088) | 12,089,448 (1,257,792) |
| Android runtime archive | 44,364,258 (43,922,918) | 44,252,274 (43,820,014) |
| Icy Tower executable (stripped) | 984,104 | 981,400 |
| Icy Tower program object (`botlish-native object`) | 160,208 | 160,264 |
| `handle` benchmark executable (rustc linker, unstripped) | 11,501,880 | 11,537,440 |

Code generation time for Icy Tower's program (`botlish-native object`,
alternating, best of 7 on the loaded machine): 69 ms before, 74 ms after,
the runs' ranges (69-100, 74-107) overlapping; the change adds a handful of
Cranelift instructions per exposure site and none elsewhere.

## 19. Android performance

The rotation is one `ror` (AArch64, single-cycle) per encode and per
decode; exposures lost their helper call there as everywhere. Android
timings under qemu-user are emulation, not device numbers: not reported as
performance.

## 20. Runtime ABI and target packages

| Runtime | Fingerprint |
|---|---|
| Linux x86-64 driver, before and after | `14aa5041bb46ae5d` |
| `runtime-abi aarch64-unknown-linux-gnu`, `aarch64-apple-darwin`, `x86_64-pc-windows-msvc` | the default encoding's (equal to the host's on x86-64; each host's own) |
| Android runtime before (base commit) | `14aa5041bb46ae5d` (archive SHA-256 `653bed00377113d5...`) |
| Android runtime after (`runtime-abi aarch64-linux-android`) | `637264e0003a0b68` (archive SHA-256 `6fbd8f342ecc733e...`) |

The fingerprint digests the encoding only when it is not the default
(`runtime/aotimage.rs:104` `fingerprint_for`, `:115` the mark
`CPTRWORD` and the rotation), so desktop runtimes, stubs and records keep
theirs and the stale Android package -- whose fingerprint is the old one --
is refused by `-target-support` before anything links (`at-runtime-
identity` requires the archive to state Android's fingerprint and not the
driver's own). The driver reports a target's with `runtime-abi TRIPLE`
(`main.rs:686`); `native::runtimeAbi ?TRIPLE?`, `native/support.tcl:240`
and the manifest compare with it; `package.sh` checks the archive against
it. ELF facts, 16 KiB alignment, Bionic-only dependencies: unchanged
(`at-library-elf` and the rest of android-target.test pass).

## 21. Negative tests

Refused, never fixed (**observed** in tests): an address no word of the
runtime's encoding holds (`cf-wild-address`, `0xf000000000000010`); an
Android address whose bits 52..55 do not repeat bit 51
(`top_byte_tagged_refuses_what_it_cannot_hold`); a wrong storage kind at a
C call (TYPE, the mutants `exposure-kinds-swapped`,
`exposure-writable-unmarked` below); a target support package of the old
fingerprint; a program built for another target. Synthetic tagged values
are only encoded and decoded, never dereferenced or freed; every pointer
dereferenced or freed came from Bionic or SDL.

## 22. Mutation testing

PENDING

## 23. Regression and CI

PENDING

## 24. Cleanroom

`audit/android-tagged-pointers/cleanroom/cleanroom.sh` (**observed**;
`results/cleanroom/`): the single-file compiler built from this change
(`single/build.sh`, 15,610,549 bytes) copied into a fresh directory and run
with an emptied environment (`env -i PATH=/usr/bin:/bin`, a fresh HOME,
`ANDROID_NDK_ROOT`), nothing of the checkout reachable. Its inputs are what
a developer has: the Android target support package packed by that compiler
(`package.sh OUT single/out/botlish`: runtime ABI `637264e0003a0b68`,
archive SHA-256 `6fbd8f342ecc733e...`), the probe's sources and the
userspace runner copied into the room, Android's libSDL3.so and the
committed android-aarch64 SDL3 binding staged as sources, the NDK and the
three Android userspaces.

1. The package is installed (`botlish add ... -target android-aarch64`).
2. hello, heap, tagged and sdl_surface are compiled as application
   libraries of android-aarch64 (`-target-support
   botlish_target_android_aarch64 -emit-native-library NAME -application`),
   tagged and heap linking the probe's NDK-built static archive (`static
   at`), sdl_surface libSDL3.so; the hosts by the NDK.
3. Each manifest is schema 3 with `compiler.runtimeAbi` and
   `targetSupport.runtimeAbi` both `637264e0003a0b68`
   (`results/cleanroom/tagged.manifest.json`).
4. Run in Android processes: every program `MAIN 0 0`, `MAIN 1 0` on API 21,
   24 and 35; on API 35 with tagging on `exposure 180 36`, `heap 180 same`,
   `sdl surface 180 180 8x8 32` and every other check; also with 16 KiB
   pages and under GC stress (`results/cleanroom/cleanroom.txt`).
5. The base commit's Android package installed by the same compiler is
   refused before anything links: `NATIVE TARGET-SUPPORT ABI`, "the
   package's runtime ABI fingerprint is 14aa5041bb46ae5d, and this
   compiler's for android-aarch64 is 637264e0003a0b68"
   (`results/cleanroom/stale-package.txt`).

## 25. Remaining limitations

* **52-bit AArch64 address spaces**: under the tagged encoding a user
  address with bit 51 set (Linux's large virtual addresses past the default
  48-bit window, only by an explicit `mmap` hint) is refused NATIVE
  ADDRESS. Android's kernels use 39- and 48-bit spaces.
* **Linux AArch64 with MTE or HWASan heaps** keeps the default encoding:
  glibc's tagged heaps (its memory-tagging tunable) are refused as before.
  It joins the tagged encoding by its row in `address_word` and its
  runtime's cfg, with its own measurements (**projected**).
* **MTE**: tags in bits 56..59 are kept like any tag (the whole top byte),
  but no MTE hardware ran here: tag-check faults were not exercised.
* **No ART**: no Activity, `SDL_Init`, window or renderer ran on Android
  (section 16); qemu-user processes are Android userspaces, not devices.
* **The Linux syscall bridge** keeps its small-Int address on purpose
  (section 7).

## 26. Next milestone

**RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1** can proceed without
`android:allowNativeHeapPointerTagging="false"`: its first prerequisite in
RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md (section 24, item 1)
is met by the runtime. Its emulator jobs will be the first to run
`SDL_CreateWindow` and `SDL_CreateRenderer` on Android, where both return
tagged pointers this runtime holds.
