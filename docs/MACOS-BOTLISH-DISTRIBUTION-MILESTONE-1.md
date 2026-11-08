# MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md

The packaged macOS compiler, Botlish.app, as a Developer ID-signed,
notarized, stapled, Gatekeeper-accepted download: its native backend built
without the JIT (programs run natively as executables through `-aot-run`,
AOT-RUN-MILESTONE-1.md), every unit signed inside out with the hardened
runtime and no entitlement, and a protected release job that reuses Icy
Tower's credential validation and release stages through a shared,
application-neutral core.

> The compiler that is distributed is the compiler that was tested: the
> bundle signed is the one built from the release tag in the same job,
> accepted before signing, after signing and from the final ZIP extracted
> and quarantined, and only the ZIP those acceptances name is published.

Every claim below is marked:

* **[executed]** run on the platform it is about: macOS AArch64 on GitHub's
  `macos-15` runners (Apple M-series virtual machines, macOS 15), Linux
  x86-64 in this repository's sandbox or on GitHub's `ubuntu-latest`;
* **[inspected]** read from code, a tool's output or a log, without running
  the claim's program on that platform;
* **[stand-in]** run on Linux against `audit/macos-release/tools/stub-tool.py`,
  the stand-ins for Apple's tools that the release tests use: evidence about
  the release tooling's logic, never about Apple's tools;
* **[pending]** a CI run that had not finished when this was written;
* **[credential-blocked]** needs the `macos-release` environment's real
  Developer ID identity and notarization key, which only a protected
  release run holds: not run;
* **[environment-blocked]** needs something no available machine has
  (below: SIP enabled);
* **[not implemented]** absent, by design or for now.

## Contents

1. [Result and release link](#1-result-and-release-link)
2. [Starting Botlish.app layout](#2-starting-botlishapp-layout)
3. [JIT capability boundary](#3-jit-capability-boundary)
4. [AOT functionality preserved](#4-aot-functionality-preserved)
5. [Mach-O and nested-code signing census](#5-mach-o-and-nested-code-signing-census)
6. [Hardened-runtime analysis](#6-hardened-runtime-analysis)
7. [Signing order](#7-signing-order)
8. [Credential reuse and validation](#8-credential-reuse-and-validation)
9. [GitHub environment configuration](#9-github-environment-configuration)
10. [Developer ID identity and timestamp](#10-developer-id-identity-and-timestamp)
11. [Notarization](#11-notarization)
12. [Stapling](#12-stapling)
13. [Gatekeeper](#13-gatekeeper)
14. [Quarantine and extraction](#14-quarantine-and-extraction)
15. [Compiler functional acceptance](#15-compiler-functional-acceptance)
16. [AOT-run acceptance](#16-aot-run-acceptance)
17. [JIT refusal tests](#17-jit-refusal-tests)
18. [SDL3/Cocoa main-thread acceptance](#18-sdl3cocoa-main-thread-acceptance)
19. [Toolchain and SDK requirements](#19-toolchain-and-sdk-requirements)
20. [Relocation tests](#20-relocation-tests)
21. [Signature integrity after compilation](#21-signature-integrity-after-compilation)
22. [Mutants and negative controls](#22-mutants-and-negative-controls)
23. [Linux and Windows regressions](#23-linux-and-windows-regressions)
24. [CI runs and artifacts](#24-ci-runs-and-artifacts)
25. [Release provenance and SHA-256](#25-release-provenance-and-sha-256)
26. [Performance and sizes](#26-performance-and-sizes)
27. [Remaining limitations](#27-remaining-limitations)
28. [Reproduction](#28-reproduction)
29. [Exact files changed](#29-exact-files-changed)

## 1. Result and release link

**No release is published.** [credential-blocked] The release job runs only
for a tag `botlish-macos-vX.Y.Z` of main's history, in the protected
`macos-release` environment, once every test of the tagged commit is
green. This work is on a branch, no such tag exists, and nothing here can
reach the environment's secrets (by design: section 9). So Developer ID
signing with the real identity, notarization, stapling, Gatekeeper's
acceptance of a notarized bundle and publication are not run; the first
real evidence of them will be the first release run's.

What exists and runs:

* [executed, macOS AArch64] the release's bundle -- the driver without its
  JIT, every unit signed inside out with the hardened runtime and no
  entitlement -- built, verified and accepted by ordinary CI on every push
  (macos-arm64.yml's `app` and `app-clean` jobs, signed ad hoc), and the
  release's own stages run on it in their ad hoc mode
  (`single/macos/release.py ... --mode adhoc`: section 24);
* [stand-in] every stage of the release path, in release mode, on Linux:
  the credential preflight on synthetic credentials, the keychain,
  notarytool's validation, the Developer ID signature, notarization and its
  resumption, stapling, Gatekeeper, the tamper control, the ZIP, the
  acceptances and the publishable check (`audit/macos-release/tests/
  test_botlish_release.py`, 10 tests, beside Icy Tower's suites);
* [inspected] the release workflow (`.github/workflows/botlish-macos.yml`),
  read as data by `test_botlish_workflow.py` (15 tests): only the release
  job, for a trusted tag, in the protected environment, sees a credential,
  each only in the steps that read it; only the publish job writes.

To make the first release (section 28): merge, set the environment's
deployment rule (section 9), push the tag.

## 2. Starting Botlish.app layout

[inspected] MACOS-AARCH64-MILESTONE-9.md's bundle, unchanged in its files:

```
Botlish.app/Contents/
  Info.plist                    CFBundleIdentifier io.github.mwagner-webdev.botlish
  MacOS/botlish                 the launcher (single/macos/launcher.c): starts Tcl and the archive
  MacOS/botlish-native          the native driver (Cranelift: AOT, and until now the JIT)
  Frameworks/Tcl.framework/     Tcl 9.0.1's framework build: Versions/9.0/{Tcl, Resources/}, Versions/Current, Tcl, Resources
  Resources/botlish.zip         the compiler stack (single/package.tcl -archive), mounted by zipfs
  Resources/libbotlish_runtime.a  the runtime archive the system linker links executables with
  _CodeSignature/CodeResources
```

Before this milestone it was signed ad hoc, without the hardened runtime
(milestone 9 left the hardened runtime to "the Developer ID milestone's
decision", because the driver had a JIT), and the driver could run
programs in its own process through Cranelift's JIT.

The layout is kept exactly: `single/macos/verify.sh`'s layout group checks
every directory's listing, and `single/macos/bundle.py check` (the release
tooling's check of the same layout, pure Python, so the release's tests run
it on any host) refuses any other file, a missing one, or an executable no
build makes (`test_extra_executable_refused`). The one change in Info.plist
is a version: `single/macos/build.sh --version X.Y.Z` sets
CFBundleShortVersionString and CFBundleVersion (the release passes its
tag's version; ordinary builds keep milestone 9's).

## 3. JIT capability boundary

The application's driver is built without the JIT: `cargo build --release
--no-default-features` (the `jit` feature of native/Cargo.toml,
AOT-RUN-MILESTONE-1.md, section 3) into `native/target/macos-app`, so the
checkout's own build, which the test suite uses, keeps its JIT. build.sh
refuses a driver whose `capabilities` say `jit 1` (also one given with
`--native-dir`). That makes the boundary a property of the binary, not of a
refusal in front of it:

| entry point | in the application |
|---|---|
| `-backend cranelift`, `-backend cranelift-generic`, `run -backend cranelift` | refused by main.tcl before anything compiles, status 1: "native JIT execution (-backend B) is unavailable in this distribution: its native backend has no JIT. Run the program natively as a standalone executable with -aot-run FILE [-- ARG...], or on the interpreter (-backend interp, the default) (NATIVE UNSUPPORTED jit)", with its Compilerpedia help line |
| `run FILE` (native default, no `-backend`) | runs as `-aot-run` does: the user did not choose the JIT |
| the driver's `run`, `bench`, `batch`, `vms` (the routes to in-process code: the C-calling linked run is `run`'s) | `error {NATIVE UNSUPPORTED jit} ...`: the code is not in the binary |
| `-emit-clif`, `-emit-vcode` | from the object module (`codegen::inspect`), unchanged output |
| `-version` | `native JIT: unavailable (programs run natively as executables: -aot-run)` |
| `botlish-native capabilities` | `jit 0` (read by `native::jitAvailable`) |
| the language server, `-check`, the interpreter, `compile` | unchanged: none uses the driver's JIT |

The difference from a binary that "merely rejects JIT execution" is
measurable: the no-JIT driver holds no symbol of `cranelift_jit` and no
Mach-O of the bundle imports `pthread_jit_write_protect_np` or
`sys_icache_invalidate` (verify.sh's `no JIT` group, every build), so there
is no JIT left for a missed route to reach. [executed, Linux x86-64] The
same build on Linux: 71 `cranelift_jit` symbols with the JIT, none without;
stripped, 8,900,808 bytes against 8,580,040 (−3.6%: the JIT is a small part
of the driver; most of it is Cranelift's code generator, which AOT needs).

## 4. AOT functionality preserved

Native compilation is the same Cranelift pipeline with the JIT's module
removed, so everything that never used the JIT is untouched:
`-emit-native-executable`, `-emit-native-library` where supported, the
program object, the system linker and the runtime archive, C calls, static
libraries and frameworks (NATIVE-LINK-PLAN-MILESTONE-1.md), main-thread
startup. What used the JIT -- the application's tests' native runs -- now
runs through `-aot-run`: single/macos/app-test.sh, compare.sh,
single/smoke-test.sh, single/ffi-smoke-test.sh, bench/macos-app.tcl and the
census (audit/macos-app/tools/census.sh) read a native run's value through
the executable's driver protocol (`BOTLISH_NATIVE_RESULT`, which `-aot-run`
passes on to the program), and compare.sh compares the application's
`-aot-run` with the checkout's, value included, on every sample program,
plainly and under GC stress. The Linux single executable keeps its JIT; the
shared smoke tests branch on `-version`'s JIT line.

## 5. Mach-O and nested-code signing census

[inspected, from build.sh's output and verify.sh's checks] The bundle holds
exactly three pieces of loadable code, each its own signing unit:

| file | kind | signing unit | identifier |
|---|---|---|---|
| `Frameworks/Tcl.framework/Versions/9.0/Tcl` | Mach-O dylib (arm64), install name `@rpath/Tcl.framework/Versions/9.0/Tcl` | the framework's version directory (`Versions/9.0`, its `_CodeSignature` and `Resources` sealed) | `com.tcltk.tcllibrary` |
| `MacOS/botlish-native` | Mach-O executable (arm64): the driver | the file itself (a nested executable in `Contents/MacOS`) | `io.github.mwagner-webdev.botlish.native` |
| `MacOS/botlish` | Mach-O executable (arm64): the launcher, CFBundleExecutable | the application (its signature seals everything else) | `io.github.mwagner-webdev.botlish` |

And nothing else is code to Gatekeeper or the loader:

* `Resources/libbotlish_runtime.a` is a static archive (objects the system
  linker reads), never loaded or executed: a sealed resource of the
  application's signature, not a signing unit (codesign does not sign
  archives);
* `Resources/botlish.zip` is data mounted by zipfs: it holds the compiler's
  Tcl and Botlish sources and `native-bin/ID` (the driver's and the runtime
  archive's CRC-32 and size, which tie the archive to the files beside it),
  no native executable and no Tcl library (verify.sh's archive group);
* the framework's `Resources/` (init.tcl, the encodings, Info.plist) are
  data sealed by the framework's signature;
* no plug-in, helper, XPC service, Tcl extension library or second framework
  exists.

Executables the compiler makes are not in the bundle: `-aot-run` links into
its private temporary directory, `-emit-native-executable` beside the
source; Apple's ld signs them ad hoc (linker-signed), and since they were
made locally and never downloaded they carry no quarantine. They need no
Developer ID and get none.

## 6. Hardened-runtime analysis

[inspected] What the hardened runtime forbids, against what the bundle
does:

* **Writable and executable memory** (`allow-jit`,
  `allow-unsigned-executable-memory`): only the JIT made code at run time.
  It is not in the driver (section 3). Nothing else maps executable memory:
  Tcl 9 compiles to bytecode, which it interprets.
* **Library validation** (`disable-library-validation`): the launcher loads
  Tcl.framework from its own bundle, which the release signs with the same
  team's identity; the driver loads only the system's libraries. Tcl's
  `load` of extension libraries is never used (zipfs is built into Tcl).
  No exception is needed.
* **DYLD environment variables** are ignored under the hardened runtime: the
  launcher finds Tcl through its own `@rpath` (`@executable_path/
  ../Frameworks`), never through `DYLD_*` (milestone 9's launcher contract).
* **Debugging** (`get-task-allow`): not needed and not granted.
* **Child processes**: the compiler starts the system's `cc`/`ld` and, for
  `-aot-run`, the executable it linked. The hardened runtime constrains the
  signed process itself, not what it may start; a child runs under its own
  signature (Apple's tools', or the executable's linker signature).
* **Writing files**: executables are written to the temporary directory or
  the user's, never into the bundle (section 21).

So the application is signed with the hardened runtime and **no
entitlement at all**: verify.sh fails a unit that has any.

[executed, macOS AArch64, ordinary CI] The ad hoc hardened-runtime bundle
passes the application's whole acceptance (section 15) on GitHub's runners.
[environment-blocked] Those runners boot with System Integrity Protection
disabled, under which AMFI does not enforce everything the hardened runtime
asks on a user's Mac; ordinary CI therefore shows that the bundle is signed
so, and runs, not that every hardened-runtime restriction was enforced while
it ran. A release run is on the same runners. The mitigation is section 3's
binary-level evidence (there is no JIT to be refused) and Apple's
notarization, which checks the signature's flags itself.

## 7. Signing order

`single/macos/sign.sh` is the one statement of the order, for the ad hoc
build (build.sh: `--identity -`) and the release (release.py's sign stage:
the Developer ID identity, its temporary keychain, `--timestamp`):

1. `Tcl.framework/Versions/9.0`, with the hardened runtime;
2. `MacOS/botlish-native`, `--identifier io.github.mwagner-webdev.botlish.native`;
3. the compiler archive written again only if its `native-bin/ID` no longer
   names the driver as now signed (a signature changes the driver's bytes,
   so its CRC): single/package.tcl `-archive` from a copy of the signed
   driver and runtime archive, then mode 644;
4. the application (its main executable and the seal of everything above).

Each `codesign --force --sign ID [--keychain K] --options runtime
--timestamp|--timestamp=none`. Never `--deep` (a mutant signs so:
`botlish-deep-signing`), never an entitlements file. Inner code is signed
before what seals it, and nothing is changed after it is signed: the archive
is rewritten before the application's seal, never after.

## 8. Credential reuse and validation

Icy Tower's release tooling (ICY-TOWER-MACOS-APP-MILESTONE-1.md) was
written for one application. It is now `tools/macos-release/`, an
application-neutral core, and each application supplies only its
description:

| file | what |
|---|---|
| `tools/macos-release/credentials.py` | the credential preflight (moved, unchanged in its checks): strict Base64, the PKCS#12 and its password, the Developer ID Application certificate's chain to the pinned Apple CAs and its team, the App Store Connect .p8 key's layout and P-256 curve, the Key ID, Issuer ID and Team ID formats; a stable code per problem, never a byte of a secret |
| `tools/macos-release/release.py` | the stages (preflight, identity, keychain, notary-auth, sign, verify-signature, record, notarize and resume, adopt, staple, gatekeeper, tamper, package, publishable, cleanup) in three modes (`adhoc`, `dry-run`, `release`), each refusing to run unless the stages it depends on passed on the same signature |
| `tools/macos-release/bundleid.py` | the bundle identifier's check, shared |
| `tools/macos-release/apple-ca/`, `requirements.txt` | Apple's public CAs (pinned by SHA-256) and the pinned, hash-checked Python packages |
| `examples/games/icy-tower/macos/bundle.py`, `release.py` | Icy Tower's description and its entry point (its identifier from `MACOS_BUNDLE_ID`, as before) |
| `single/macos/bundle.py`, `release.py` | Botlish's: the name, the executable, the three units (section 5), the fixed identifier `io.github.mwagner-webdev.botlish`, the ZIP `botlish-macos-aarch64.zip`, the notarytool profile and keychain names, and `sign` through sign.sh |

There is one validator: Botlish's preflight is the same `credentials.py`,
given the compiler's fixed identifier instead of the game's variable.
Botlish never reads `MACOS_BUNDLE_ID` (the game's identifier: a mutant that
does, `botlish-identifier-from-variable`, is killed, and
test_botlish_workflow.py checks that no job of the compiler's workflow
names it), and the identity stage checks the identifier against every
earlier Botlish release's provenance, so one application can never be
released under the other's identity, and an Icy Tower release can never be
overwritten by the compiler's: different tags, different release names,
different assets, and publish refuses an existing release.

The move kept Icy Tower's behavior: its 77 mutants and three test suites
run unchanged against the new paths (`audit/macos-release/tools/mutate.py`:
section 22), and icy-tower-macos.yml's release job calls the same entry
point it called.

## 9. GitHub environment configuration

The compiler's release uses the environment Icy Tower's uses,
`macos-release`, so the credentials exist once. Its **deployment rule must
admit the new tags**: Settings, Environments, macos-release, Deployment
branches and tags, add the tag pattern `botlish-macos-v*` beside
`icy-tower-macos-v*` (and keep "required reviewers" if set). Until then a
release run's job is refused by GitHub before it starts, which is safe.
Nothing else changes:

| name | kind | read by |
|---|---|---|
| `MACOS_CERTIFICATE_P12_BASE64` | secret | the preflight step only |
| `MACOS_CERTIFICATE_PASSWORD` | secret | the preflight step and the keychain step |
| `APPLE_NOTARY_KEY_BASE64` | secret | the preflight step only (the key goes into notarytool's profile in the work directory's private part, removed by cleanup) |
| `APPLE_NOTARY_KEY_ID`, `APPLE_NOTARY_ISSUER_ID`, `APPLE_TEAM_ID` | variables | the preflight; `APPLE_TEAM_ID` also verify.sh's `--team` |
| `MACOS_BUNDLE_ID` | variable | the game's only: never the compiler's workflow |

The workflow's own boundary (test_botlish_workflow.py checks each line):

* triggers: a pushed tag `botlish-macos-v*` and `workflow_dispatch`, nothing
  for a branch or a pull request; workflow permissions `contents: read`;
* `tested` (no credential, `actions: read`): `tools/ci/runs.py check SHA
  --for botlish-macos` -- the release gate's rule (CI-RUNS.md): every CORE
  workflow green at the commit. A tag pushed before that is deferred, and
  release-gate.yml runs the workflow on the tag again (runs.py's `RELEASES`
  has `botlish-macos`, `tag_prefix="botlish-macos-v"`);
* `release` (macos-15, environment `macos-release`, `contents: read`): only
  for a `botlish-macos-v` tag whose commit is of main's history and is the
  run's, once `tested` says green; each secret only in the `env` of the step
  that reads it, no step that holds one traces commands; the bundle built
  from the tag in this job (no artifact of another run is signed, except
  the resumption of this release's own notarization, checked to be the same
  commit's run);
* `publish` (ubuntu, `contents: write`, no environment, no secret): after the
  release job succeeded, checks SHA256SUMS and that the ZIP is the release
  job's by its SHA-256 output, the provenance's version, mode and bundle
  identifier, refuses an existing release, and creates the tag's release;
* no job changes a trust setting, nothing uploads a credential, and the
  temporary keychain and decoded credentials are removed in an `always()`
  step.

## 10. Developer ID identity and timestamp

[stand-in; credential-blocked for real] The keychain stage imports the
PKCS#12 into a temporary keychain made for the run (`botlish-signing.
keychain-db`), the identity stage requires the certificate to be a
Developer ID Application certificate of `APPLE_TEAM_ID` (and the bundle
identifier to be the application's own and earlier releases'), and the
sign stage signs every unit with it and `--timestamp` (Apple's timestamp
service). verify-signature then requires, of every unit: not ad hoc, the
team's Developer ID Application authority, Developer ID Certification
Authority, Apple Root CA, the hardened runtime flag, a secure timestamp, its
own identifier, no entitlement -- and single/macos/verify.sh `--signature
developer-id --team TEAM` checks the same with Apple's tools on the bundle
as a whole. A unit left ad hoc (`test_driver_signed_ad_hoc_refused`), a unit
without the runtime flag or with an entitlement
(`test_nested_unit_without_hardened_runtime_refused`,
`test_nested_unit_with_entitlement_refused`), a driver changed after it
was signed and a wrong identifier are each refused before notarization.

## 11. Notarization

[stand-in; credential-blocked for real] `notarize` zips the signed bundle,
submits it with `xcrun notarytool submit --wait` through the profile the
notary-auth stage validated with Apple, requires `Accepted`, fetches the
log (`notarytool log`) and requires it to be readable and to say Accepted
with no issue of error severity (warnings are counted and printed), and
records the CDHash the ticket is for; a timeout is resumable (`--resume ID`, the workflow's `resume_run` and
`resume_submission`: the bundle that earlier run signed, downloaded and
adopted, never another upload). Times are recorded in `timings.txt`.

## 12. Stapling

[stand-in; credential-blocked for real] `staple` runs `xcrun stapler staple`
on the bundle and `stapler validate`; the stapled ticket is
`Contents/CodeResources` (bundle.py's layout check allows that one file
there); verify-signature runs again on the stapled bundle (`--label
stapled`): stapling must not change any unit's CDHash.

## 13. Gatekeeper

[stand-in; credential-blocked for real] `gatekeeper --expect notarized`
requires `spctl --assess --type execute` to accept the bundle with
`source=Notarized Developer ID`; the tamper control changes a sealed
resource of a copy and requires codesign to reject it and the original
to verify after. Ordinary CI runs `gatekeeper --expect refused` on the ad
hoc bundle: Gatekeeper must *reject* code that is not notarized -- so CI
checks on the runners themselves that the assessment really runs, as Icy
Tower's ordinary CI does.

## 14. Quarantine and extraction

`package` makes the ZIP with `ditto -c -k --keepParent` (permissions,
symbolic links -- the framework's three --, extended attributes kept),
writes SHA256SUMS and provenance.json, and checks the ZIP (in release
mode only after the staple, Gatekeeper and tamper stages passed on the
notarized CDHash): `unzip -t`, then extracted with `ditto -x -k` into a
fresh directory, the extracted tree must equal the bundle's file for file
(names, modes, bytes), the launcher keep mode 755, the signature verify and,
in release mode, the stapled ticket validate. The release job then extracts the ZIP into
`$HOME/Prögram Files` (a space and a non-ASCII letter), sets
`com.apple.quarantine` on every file -- **synthetic**: the attribute a
browser's download carries (`0081;TIME;Safari;UUID`), set by `xattr`, not
by a browser; no browser ran and no LaunchServices download was recorded --
and requires Gatekeeper's assessment (`spctl --assess --type execute`),
`codesign --verify --deep --strict` and `stapler validate` to pass on it
before the final acceptance runs the compiler from it. [credential-blocked]
in release mode; the same steps in ad hoc mode run in the release tests
[stand-in].

## 15. Compiler functional acceptance

`single/macos/acceptance.sh APP OUT [--only CASE,...]` is the release's
acceptance, run on the bundle before signing (the ad hoc build: version,
interpreter, check, jit-refused, aot-run, executable, cocoa-canary,
signature), on the Developer ID-signed bundle before notarization (every
case: `record --label hardened-runtime`) and on the final ZIP's bundle,
extracted and quarantined (every case but the Finder's launch: `record
--label final-artifact`). Its cases:

| case | what |
|---|---|
| version | `-version` names the packaged backend and no JIT |
| interpreter | a program's value on the interpreter |
| check | `-check` of a program and of a rejected one |
| jit-refused | `-backend cranelift`, `run -backend cranelift`: NATIVE UNSUPPORTED jit, naming -aot-run |
| aot-run | Darwin IO's output, arguments after `--`, a C exit's status, a runtime error's status, a rejected program never run |
| executable | `-emit-native-executable`: a Mach-O that runs alone |
| ffi | single/ffi-smoke-test.sh: static C libraries, borrowing, error capture, variadics, Darwin IO |
| cocoa-canary | AppKit and Metal through `-aot-run -native-startup main-thread`, on the main thread |
| smoke | single/smoke-test.sh: every checkout-free check of the packaged compiler (front end, diagnostics, imports, packages, the standard library, the language server, Compilerpedia) |
| app | single/macos/app-test.sh: relocation, read-only bundle, paths, processes, concurrency, cache, tamper, damage, executables, Darwin IO, the JIT's absence |
| finder-launch | the bundle opened by LaunchServices (`open -W -n`): it exits without a crash report |
| signature | `codesign --verify --deep --strict` after every run: nothing wrote into it |

The `record` stage requires every named case to have run and be EXECUTED,
and records the results with the bundle's CDHash (its signature verified
first) or the ZIP's SHA-256: `publishable` requires both records, on the signature and ZIP it
publishes (`botlish-final-not-quarantined` and the acceptance's own
mutants: section 22).

[executed, macOS AArch64] Ordinary CI runs the same acceptance on the ad
hoc hardened-runtime bundle (`app` job: "The release's signing stages and
acceptance, ad hoc"), plus app-test.sh, compare.sh, the two smoke tests and
the toolchain-free smoke test, outside the checkout. [pending] at the time
of writing (section 24).

Finder: [inspected] Botlish is a command-line compiler; opened from Finder,
its launcher starts the compiler with no arguments, which prints the usage
(nowhere a user sees: LaunchServices gives it no terminal) and exits 0.
That is no crash and no obscure failure: `finder-launch` requires that a LaunchServices open
returns and leaves no crash report. No GUI was added. The supported
invocation is `Botlish.app/Contents/MacOS/botlish` (the release notes say
so); a user may add a symbolic link to it on their PATH. The release never
installs anything, edits no shell startup file and makes no global
command.

## 16. AOT-run acceptance

From the distributed compiler: acceptance.sh's `aot-run` case (output,
arguments, a nonzero exit, a runtime failure, a rejected program never
run), `ffi` (C calls), `cocoa-canary` (the main thread), app-test.sh's
no-jit group (`run`'s default and `-aot-run` of Darwin IO), compare.sh (the
application's `-aot-run` against the checkout's on every sample, values
included, plainly and under GC stress), and the smoke tests' `-aot-run`
checks (an application module, a non-ASCII directory and argument, a local
module beside the standard one, and without a C compiler the refused link:
NATIVE LINK TOOLCHAIN). Temporary-directory cleanup is checked by
tests/aot-run.test on every host (AOT-RUN-MILESTONE-1.md, section 6), which
the macOS acceptance tier runs from the checkout.

Native output equivalence: tests/aot-run.test's `aotr-equals-emitted` (the
same program by `-aot-run` and by `-emit-native-executable` then the
executable: the same output, error and status, also under GC stress) and
compare.sh (the JIT-less application against the checkout's JIT-capable
build, both by `-aot-run`).

## 17. JIT refusal tests

* app-test.sh's no-jit group: `-backend cranelift`, `-backend
  cranelift-generic` and `run -backend cranelift` through the public
  launcher (status 1, NATIVE UNSUPPORTED jit, naming -aot-run, nothing run);
  the driver's `run`, `bench`, `batch` and `vms` (`error {NATIVE UNSUPPORTED
  jit}`); `capabilities` (`jit 0`); `-version`; `-emit-clif`; `run`'s
  default as an executable;
* acceptance.sh's `jit-refused`;
* verify.sh's `no JIT` group (the binary has no JIT);
* tests/aot-run.test's `aotr-no-jit-refused`, `aotr-no-jit-run-default` (a
  driver that says `jit 0`, on every host) and `aotr-no-jit-driver` (the
  real no-JIT build where it exists).

Each refusal is a diagnostic of its own, with a help line, never a loader
error, a missing symbol or a crash.

## 18. SDL3/Cocoa main-thread acceptance

* **Every release and every push**: the Cocoa and Metal canary
  (acceptance.sh's `cocoa-canary`, app-test.sh): a program that links AppKit
  and Metal as frameworks, checks `pthread_main_np()`, calls
  `NSApplicationLoad()` and `MTLCreateSystemDefaultDevice()`, run through
  `-aot-run -native-startup main-thread` -- status 0 -- and through
  `-aot-run` on the worker -- status 3, not the main thread. That is the
  smaller canary the milestone allows in ordinary acceptance.
* **The full SDL3 workload, through the application, on every push**:
  macos-arm64.yml's `main-thread-startup` job builds SDL3 programs with
  `-native-startup main-thread` from the application outside the checkout
  and runs the graphical census (`census.py --strict`: SDL3's Cocoa driver,
  a window and Metal on the main thread), and `link-plan-sdl3` links static
  SDL3 through it; icy-tower-macos.yml builds Icy Tower with the
  application (now JIT-less) and plays it under the graphical harness. These
  build executables with `-emit-native-executable`; `-aot-run` runs the same
  executable (AOT-RUN-MILESTONE-1.md, section 3), which the canary shows on
  the main thread.
* [not implemented] Icy Tower itself is not run through `-aot-run`: the
  game's harness plays an executable it can find and inspect, and adding
  `-aot-run` there would test the harness, not the compiler.

## 19. Toolchain and SDK requirements

The compiler is self-contained; native executables need Apple's linker and
SDK, which it never bundles (Cranelift writes the object; Apple's ld links
it against the SDK's libSystem and frameworks).

* [executed, macOS AArch64: `app-clean`] **Without developer tools** (Xcode
  and the Command Line Tools moved away, `/usr/bin/cc` failing; no Rust,
  Tcl or checkout; Homebrew's Tcl absent): the launcher starts, `-version`
  and `-help` work, `-check` and the interpreter work, the bundled front
  end, standard library, Compilerpedia and language server load, and the
  signature verifies; a native link is refused with NATIVE LINK TOOLCHAIN
  (`-emit-native-executable` and `-aot-run` of a C program alike: on macOS
  every program calls C, Darwin IO being libSystem's) and leaves nothing.
* [executed, macOS AArch64: `app`, `main-thread-startup`, `link-plan-sdl3`]
  **With the Command Line Tools**: AOT compilation, the link, `-aot-run`,
  static C libraries, frameworks and main-thread Cocoa executables.
* What needs no developer tools natively: `-emit-nir`, `-emit-clif`,
  `-emit-vcode` and the driver's object (Cranelift only).

## 20. Relocation tests

app-test.sh (every push, and the acceptance's `app` case): the application
copied and moved, run from a path with spaces and non-ASCII letters,
through a symbolic link, read-only, and the compiler's own files never
written. The release's final acceptance runs from `$HOME/Prögram Files`.

## 21. Signature integrity after compilation

acceptance.sh ends every run with `signature` (`codesign --verify --deep
--strict` of the bundle after every case ran); app-test.sh compares the
bundle's file tree before and after its runs; the `app` job's "The
application, untouched by the runs" checks the bundle after every test of
the job. Executables go to temporary directories or the user's, and the
language server's standard library copy to `~/Library/Caches/botlish`.

## 22. Mutants and negative controls

* **audit/macos-release/mutants.txt** (Icy Tower's 77, moved with the
  tooling, plus the compiler's): the compiler's take the game's
  identifier, sign ad hoc in release mode, drop the timestamp, sign with
  `--deep`, skip the layout or the identifier check, write the archive
  before the driver's signature, run the release for branch pushes, give
  the preflight `MACOS_BUNDLE_ID`, put a secret in the job's env, let the
  release job write, release before the commit is green, accept the final
  ZIP unquarantined, publish an unchecked ZIP. [stand-in] each is killed by
  the test its `!!` line names (`audit/macos-release/tools/mutate.py`: the
  baseline first; a mutant that does not apply is no kill).
* **audit/macos-app/tools/mutants.txt**: seven moved into sign.sh with the
  signing, and seven new: the hardened runtime dropped, a JIT entitlement
  added, the driver's identifier lost, the archive naming an unsigned
  driver, main.tcl's refusal removed, `run`'s default not AOT, the
  capability misreported. They run on macOS (a push with
  `[ci-app-mutants]`: the `Botlish.app mutants` job).
* **The release tests' negative controls** (test_botlish_release.py): a
  nested unit without the hardened runtime, one with an entitlement, the
  driver changed after signing, the driver ad hoc in release mode, a wrong
  identifier, an extra executable, an ad hoc build that signs and verifies
  but is never publishable; and Icy Tower's (malformed credentials refused
  before any Apple tool, a non-notarized ZIP, stapling omitted, a timeout
  resumed, an existing release).
* **AOT-run's 22** (AOT-RUN-MILESTONE-1.md, section 10).

The milestone's list, mapped: public `-backend cranelift` enabled
(`jit-refusal-removed`, both catalogs); a driver route invoking the JIT
(`jit-route`; and the binary has none); AOT disabled with the JIT (app-test
and the acceptance's aot-run and executable cases fail); incorrect
capability reporting (`jit-capability-misreported`); the bundle modified by
compilation (the `signature` case, the tree comparison); a nested Mach-O ad
hoc in release mode (`test_driver_signed_ad_hoc_refused`); missing hardened
runtime (`hardened-runtime-dropped`, the nested-unit control); missing
timestamp (`botlish-no-timestamp`); an unnecessary JIT entitlement
(`jit-entitlement-added`); invalid Tcl.framework signing (verify.sh's
framework unit, the release's verify-signature of every unit); the runtime
archive missing (the layout checks); a bundle that works only in the
checkout (`app-clean`); works before signing, fails after (the
hardened-runtime acceptance and its record); works before packaging, fails
after extraction (the final acceptance and its record); a non-notarized
ZIP publishable, stapling omitted (Icy Tower's mutants, the same
`publishable`); a wrong bundle identifier
(`botlish-identifier-unchecked`, `botlish-identifier-from-variable`); an
Icy Tower release overwritten (different tags and names; publish refuses
an existing release); credentials exposed to an untrusted job
(`botlish-secret-in-job-env`, `botlish-release-on-branches`,
test_botlish_workflow.py); malformed credentials passed to Apple's tools
(the preflight, the same `credentials.py`).

## 23. Linux and Windows regressions

The Linux single executable keeps its JIT and its default behavior; the
Windows build keeps its JIT; the JIT is a default feature everywhere but
the macOS application's build. [executed] `tests` (Linux x86-64) and
`tests (linux arm64)` were green on the branch's push of `29bcbe2`; Windows'
canary failed three aot-run.test tests' reading of Windows output, fixed
in `a822905` (AOT-RUN-MILESTONE-1.md, section 9.1). [pending] the
`single-executable` workflow (main pushes only: dispatched on the branch,
section 24).

## 24. CI runs and artifacts

[pending] The branch's runs at the time of writing: the commits and the
workflows to read are listed in section 28; ordinary CI uploads the ad hoc
bundle as the `botlish-macos-aarch64` artifact (macos-arm64.yml's `app`
job), and a release run uploads `botlish-macos-release` (the ZIP,
SHA256SUMS, provenance.json) and `botlish-macos-release-diagnostics` (the
release state, notarytool's submission and log, the acceptances' results,
the stage timings: never the work directory's secret part).

## 25. Release provenance and SHA-256

[credential-blocked] Each release publishes `botlish-macos-aarch64.zip`,
`SHA256SUMS` and `provenance.json`: the tag, the version, the source
commit, the target (macos-aarch64, macOS 11.0 and later), `native_jit:
none`, the Rust toolchain, the workflow run, the mode (`release`), the
bundle identifier, the team, the notarization submission, every unit's
CDHash, the two acceptance records and the ZIP's SHA-256; the publish job
compares the ZIP with the release job's output before it creates the
release.

## 26. Performance and sizes

* [executed, macOS AArch64] bench/macos-app.tcl in the `app` job: the
  bundle's and the download's sizes, each part's (Tcl.framework, the
  launcher, the archive, the driver, the runtime archive), and startup
  times (the launcher, Tcl, the archive's mount, `-version`, `-help`,
  `-check`, the interpreter, the language server, the driver, and with no
  JIT `-aot-run` in its place, `-emit-native-executable`, a moved copy's
  first start). [pending] the run's figures.
* [executed, Linux x86-64] the JIT's share of the driver: −320,768 bytes
  stripped (3.6%) (section 3). The difference between a JIT-less binary and
  one that merely refuses is that difference plus the absence of the JIT's
  code paths, not a large saving: most of the driver is the code
  generator, which AOT needs.
* Signing, notarization and verification times: [credential-blocked] the
  release job records them (`timings.txt`).
* AOT compile, link, `-aot-run` end to end and time to first output:
  AOT-RUN-MILESTONE-1.md, section 11.

## 27. Remaining limitations

* No release yet (section 1) and no evidence yet of Apple's notarization of
  this bundle.
* The hardened runtime's enforcement on a SIP-enabled Mac is not observed by
  CI (section 6).
* The quarantine is synthetic (section 14); a browser's download and
  LaunchServices' first-launch dialog for a double-click are not exercised
  (the compiler is used from a shell).
* Apple Silicon only (arm64); macOS 11 or later. No Intel or universal
  build, no DMG, no installer package, no Homebrew formula.
* Native executables need Apple's Command Line Tools (section 19).

## 28. Reproduction

* The bundle: `single/macos/build.sh -o OUT [--version X.Y.Z]` on an Apple
  Silicon Mac with Xcode or the Command Line Tools, stable Rust and
  Tcl 9.0.1 (tests/platform/setup-macos.sh); `single/macos/verify.sh
  --checkout . OUT/Botlish.app`; `single/macos/acceptance.sh
  OUT/Botlish.app RESULTS`.
* The release's stages without credentials: `python3 -I
  single/macos/release.py preflight --work W --mode adhoc` and the rest as
  the app job's step runs them; on Linux, the release tests with the
  pinned environment (`audit/macos-release/requirements.txt`):
  `python3 -I audit/macos-release/tests/test_botlish_release.py`,
  `test_botlish_workflow.py`, and `audit/macos-release/tools/mutate.py`.
* A release: merge to main; add `botlish-macos-v*` to the macos-release
  environment's deployment rule; push the tag `botlish-macos-vX.Y.Z` on a
  commit of main; the release gate runs it once the commit is green.
* CI on a branch: macos-arm64.yml (every push: `smoke`, `app`, `app-clean`,
  `link-plan-sdl3`, `main-thread-startup`; `[ci-app-mutants]` for the app's
  mutants), icy-tower-macos.yml (the game built with the application, the
  release tooling's tests), windows-x86_64.yml, tests.yml and
  tests-arm64.yml (dispatched for the full suites), single-executable.yml
  (dispatched).

## 29. Exact files changed

AOT-RUN-MILESTONE-1.md, section 13, lists the AOT-run command's. This
milestone's:

| file | change |
|---|---|
| `single/macos/build.sh` | the driver built without its JIT (its own target directory), checked `jit 0`; signing through sign.sh; `--version` |
| `single/macos/sign.sh` | new: the signing order, ad hoc or Developer ID, hardened runtime, never `--deep` |
| `single/macos/verify.sh` | the hardened runtime and no entitlement on every unit; `--signature developer-id --team`; the `no JIT` group |
| `single/macos/acceptance.sh` | new: the release's functional acceptance |
| `single/macos/bundle.py`, `single/macos/release.py` | new: Botlish's release description and entry point |
| `single/macos/app-test.sh`, `compare.sh` | native runs through `-aot-run`; the no-jit group |
| `single/smoke-test.sh`, `single/ffi-smoke-test.sh` | JIT-aware (`-version`'s line); `-aot-run` checks; the refused link without a C compiler |
| `tools/macos-release/` | the shared core: credentials.py, release.py, bundleid.py, apple-ca/, requirements.txt (moved from examples/games/icy-tower/macos/) |
| `examples/games/icy-tower/macos/bundle.py`, `release.py` | Icy Tower's description over the shared core |
| `.github/workflows/botlish-macos.yml` | new: the release workflow |
| `.github/workflows/macos-arm64.yml` | the app job's ad hoc release stages and acceptance; the smoke job's AOT-run costs |
| `.github/workflows/icy-tower-macos.yml` | the moved requirements; the compiler's release tests beside the game's |
| `tools/ci/runs.py`, `tools/ci/test_runs.py` | the `botlish-macos` release and its test |
| `audit/macos-release/` | test_botlish_release.py, test_botlish_workflow.py (new); the stand-in codesign's nested units; the mutants; mutate.py's copied files |
| `audit/macos-app/tools/` | the mutants (moved and new), the harness's JIT-less driver, the census's `-aot-run` |
| `bench/macos-app.tcl` | `-aot-run` where there is no JIT |
| `tests/workload-icy-tower.test` | the release tooling's tests at the new paths, the compiler's included |
