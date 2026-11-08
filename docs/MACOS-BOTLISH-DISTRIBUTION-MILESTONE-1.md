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
  test_botlish_release.py`, 11 tests, beside Icy Tower's suites);
* [inspected] the release workflow (`.github/workflows/botlish-macos.yml`),
  read as data by `test_botlish_workflow.py` (15 tests): only the release
  job, for a trusted tag, in the protected environment, sees a credential,
  each only in the steps that read it; only the publish job writes.

To make the first release (section 28): merge, push the tag (the
environment's deployment rule admits it since 2026-11-08: section 9).

The milestone's acceptance criteria, as they stand:

| # | criterion | status |
|---|---|---|
| 13 | the packaged compiler exposes no working native JIT | [executed, macOS] the driver is built without it (verify.sh's `no JIT` group, every build) |
| 14 | `-backend cranelift` fails with an actionable diagnostic | [executed, macOS] app-test.sh, acceptance.sh's `jit-refused` |
| 15 | native Cranelift AOT remains fully functional | [executed, macOS] the app jobs, link-plan-sdl3, main-thread-startup, Icy Tower built by the application |
| 16 | the interpreter remains functional | [executed, macOS] smoke-test.sh, acceptance.sh |
| 17 | relocated, self-contained | [executed, macOS] app-test.sh's relocation, `app-clean` |
| 18 | validated structure and stable identity | [executed, macOS] verify.sh's layout; bundle.py's check and the identity stage |
| 19 | every executable component signed correctly | [executed, macOS] ad hoc with the hardened runtime, each unit verified; [credential-blocked] with the Developer ID |
| 20 | Developer ID signature with the hardened runtime and a secure timestamp | [stand-in] the stages and checks; [credential-blocked] the real signature |
| 21 | no unnecessary JIT entitlement | [executed, macOS] no entitlement at all (verify.sh) |
| 22 | compilation and AOT-run do not invalidate the signature | [executed, macOS] acceptance.sh's `signature`, app-test.sh's tree comparison |
| 23 | the Developer ID-signed compiler passes functional tests | [credential-blocked]; the same acceptance passes on the ad hoc hardened-runtime bundle [executed, macOS] |
| 24 | notarized by Apple | [credential-blocked] |
| 25 | ticket stapled and verified | [credential-blocked] |
| 26 | Gatekeeper accepts the application | [credential-blocked]; Gatekeeper's refusal of the ad hoc bundle [executed, macOS] |
| 27 | the final ZIP preserves every signature and ticket | [stand-in] the package stage's checks; [credential-blocked] the ticket |
| 28 | a quarantined extraction is assessed and launched | [credential-blocked] in release mode (synthetic quarantine, section 14) |
| 29 | the compiler works from that extracted artifact | [credential-blocked]; the ad hoc download's toolchain-free smoke test [executed, macOS: `app-clean`] |
| 30 | AOT-run works from that extracted artifact | [credential-blocked] (the final acceptance's `aot-run` case) |
| 31 | the AOT-compiled SDL3/Cocoa canary works | [executed, macOS] the AppKit and Metal canary through `-aot-run -native-startup main-thread`; SDL3 through the application (main-thread-startup's census, Icy Tower) |
| 32 | developer-tool requirements documented and tested | [executed, macOS] section 19 (`app-clean` without them, the app jobs with them) |
| 33 | the release publishes the exact verified ZIP with SHA-256 and provenance | [inspected] the publish job; [stand-in] `publishable`; [credential-blocked] a real release |
| 34 | credentials unavailable to untrusted jobs | [inspected] test_botlish_workflow.py (15 tests) and its mutants |
| 35 | malformed credentials fail before Apple tools | [stand-in] the shared preflight's 63 tests (test_credentials.py) and its mutants |
| 36 | negative controls and mutants reject broken artifacts | [stand-in, and executed on macOS by icy-tower-macos.yml] audit/macos-release's 92 mutants; [executed, macOS with `[ci-app-mutants]`] audit/macos-app's |
| 37 | Linux and Windows regressions pass | section 23 |

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

What the application loses with the JIT: a program whose functions the
AOT compiler cannot close (an untyped closure parameter, a value of no
static kind: NATIVE AOT NOT-READY) ran natively on the JIT, with run-time
guards, and now runs on the interpreter only. Of the smoke test's 23
programs, 18 run as executables and 5 are not AOT-ready; the smoke test
names them and accepts exactly that refusal (AOT-RUN-MILESTONE-1.md,
"Limitations"). Every program that is AOT-ready -- which every
`-emit-native-executable` build needed already -- runs as before.

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
admit the new tags, and only tags**: Settings, Environments, macos-release,
Deployment branches and tags, "Selected branches and tags", the tag rules
`botlish-macos-v*` and `icy-tower-macos-v*` and no branch rule (both jobs
that enter the environment run only for those tags: botlish-macos.yml's
and icy-tower-macos.yml's `release`, each `if` requiring
`refs/tags/PREFIX`). With "No restriction" a workflow run of any branch
could enter the environment and read its secrets, a branch's own edited
workflow included. [inspected, the owner's settings page, 2026-11-08] it
was "No restriction" and is now "Selected branches and tags", 0 branches
and 2 tags: `botlish-macos-v*` (applying to 0 tags) and the Icy Tower rule
(applying to its 2 release tags). Recommended beside it, as for Icy Tower
(ICY-TOWER-MACOS-APP-MILESTONE-1.md, section 11): "Required reviewers"
(the owner), so every release waits for an approval before the
credentials reach it, and a tag ruleset for `botlish-macos-v*` restricting
creation, update and deletion to administrators: a deployment rule admits
any run of a matching tag, and whoever can push such a tag chooses the
commit, and so the workflow file, that runs. Nothing else changes:

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
(names, modes, bytes) and link for link (the framework's three symbolic
links, by their targets: a ZIP that stores them as copies, or as absolute
paths into the build machine's tree, is refused --
`test_zip_that_changes_links_refused`, the mutant `zip-links-followed`),
the launcher keep mode 755, the signature verify and,
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
  ZIP unquarantined, publish an unchecked ZIP, compare the ZIP's symbolic
  links by what they point to (`zip-links-followed`: the shared core's
  package stage now records a link as a link, which the game's bundle, with
  no link, never needed). [stand-in] each is killed by
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
`tests (linux arm64)` (their canaries, on a branch push) were green on
`29bcbe2` and `a822905`, Icy Tower's Windows build on both; Windows'
canary failed three aot-run.test tests' reading of Windows output on
`29bcbe2`, fixed in `a822905` (AOT-RUN-MILESTONE-1.md, section 9.1).
[executed, Linux x86-64, this sandbox] the Linux single executable built
by single/build.sh (14,853,994 bytes) passes single/smoke-test.sh (the
new `-aot-run` refusal without a C compiler included) and
single/ffi-smoke-test.sh, and audit/single-executable/tools/mutate.tcl
kills its 11 mutants (none survived). [pending] the full suites
(tests.yml, tests-arm64.yml) and Windows' acceptance shards on the merge
of main (`4ece288` and the commit after it, section 24): the runs
dispatched on `460fcee` and on `c3cd83c` were superseded by the next
push before their expensive jobs had a runner.

## 24. CI runs and artifacts

The branch `ccr-7f920867-5n2fuj` (https://github.com/mwagner-webdev/botlish/actions?query=branch%3Accr-7f920867-5n2fuj):

| commit | workflow | run | result |
|---|---|---|---|
| `29bcbe2` | icy-tower (macos arm64) | 42461857789 | failure: build.sh's signing stopped at sign.sh's empty `keychain` array (bash 3.2 under `set -u`: macOS's bash takes an empty array for an unset one); fixed in `a822905` |
| `29bcbe2` | tests (windows x86-64) | 42461857832 | failure: three aot-run.test tests' reading of Windows output (AOT-RUN-MILESTONE-1.md, section 9.1); fixed in `a822905` |
| `29bcbe2` | tests, tests (linux arm64), icy-tower (windows x86-64), raven clean room | 42461857793, 42461857916, 42461857885, 42461857808 | success |
| `a822905` | icy-tower (macos arm64) | 42464261231 | **success** [executed, macOS]: Botlish.app built from the commit (the driver without its JIT, every unit ad hoc signed with the hardened runtime), Icy Tower built by it (static SDL3, Cocoa, `-native-startup main-thread`), the game's tests and the graphical acceptance, the release tooling's five suites and the 92-mutant harness (audit/macos-release/tools/mutate.py) on the runner, the game's ad hoc and dry-run release paths |
| `a822905` | tests (macos arm64) | 42464261169 | smoke (Tier A, its canary running the changed files, aot-run.test among them, on Apple Silicon): **success** [executed, macOS]; the app jobs: superseded by the next push before a runner took them |
| `a822905` | tests, tests (linux arm64), ci tools, icy-tower (windows x86-64), raven clean room | 42464261202, 42464261307, 42464261174, 42464261275, 42464261197 | success |
| `460fcee` | icy-tower (macos arm64) | 42466433504 | **success** [executed, macOS]: as for `a822905`, on the bundle whose release step now also asks Gatekeeper's refusal, and the release tooling's 92 mutants |
| `460fcee` | tests (macos arm64), the Botlish.app job | 42466433458 (job 128698763992) | **failure**, the first time the job ran past the signing step: (1) single/smoke-test.sh's no-JIT branch required every sample to run as an executable, and 5 of 23 are not AOT-ready (section 4: the smoke test now accepts exactly that refusal and names them); (2) app-test.sh's relocation check: with a user's `BOTLISH_NATIVE_BIN` in the environment, `-aot-run` failed with `wrong # args: should be "binary"` -- `native::aotRun`'s child-environment writer called `binary` inside the namespace `native`, whose own `native::binary` (the driver's path) shadows Tcl's; fixed (`::binary`), with `aotr-child-environment` and the mutant `child-environment-dropped`. compare.sh, single/ffi-smoke-test.sh, the ad hoc release stages (Gatekeeper's refusal included) and bench/macos-app.tcl passed in the same job [executed, macOS] |
| `460fcee` | tests (macos arm64) | 42466433458 | smoke (its canary, `AOT-run costs`) and acceptance shard 3/4 **success** [executed, macOS]; the system linker's executable and C tests success (its GC-stress step running); the Botlish.app job (the ad hoc release stages, the Gatekeeper refusal, acceptance.sh), app-clean, link-plan-sdl3, main-thread-startup and shards 1, 2, 4 [pending] (waiting for macOS runners when this was written) |
| `460fcee` | tests (windows x86-64) | 42466433448 | canary (aot-run.test with `aotr-parent-killed-windows`), smoke (the smoke tier and the Windows-relevant test files, `AOT-run costs`, GC workloads) and root plans **success** [executed, Windows]; the acceptance shards and the system linker [pending] |
| `460fcee` | single executable (dispatched) | 42466437468 | the x86-64 and AArch64 builds and their build-machine smoke and C FFI smoke tests **success**; no job failed; the stock-container smoke jobs [pending] |
| `460fcee` | tests (dispatched in full) | 42466447733 | one job failed before any test ran: `tests (compile)` could not download Neovim from github.com (`curl: (22)`, HTTP 504) -- infrastructure, to be re-run when the run ends; the other jobs no failure, several [pending] |
| `460fcee` | tests (linux arm64) (dispatched in full) | 42466450059 | no job failed; superseded by `c3cd83c` before it finished |
| `c3cd83c` | tests (macos arm64) | 42480168990 | smoke (Tier A, its canary running the changed aot-run.test with `aotr-child-environment`, `AOT-run costs`) and the linux control **success** [executed, macOS]; the Botlish.app job, the acceptance shards and the system linker were still waiting for a macOS runner when the merge of main was pushed, which superseded them |
| `c3cd83c` | tests (windows x86-64) | 42480168979 | canary (aot-run.test) and root plans **success** [executed, Windows]; smoke still queued when superseded |
| `c3cd83c` | single executable (dispatched), icy-tower (macos arm64), icy-tower (windows x86-64), raven clean room | 42480179860, 42480169020, 42480168944, 42480168980 | success |
| `c3cd83c` | tests, tests (linux arm64) (dispatched in full) | 42480175061, 42480177266 | the canary success, no job failed; every expensive job still queued when superseded |
| `4ece288` | (merge of main at `d4aebf1`) | -- | conflicts in main.tcl and backends.topic, both sides kept; the merged tree did not build without the JIT (main's thread factory, `jit_factory`, named the JIT's types outside the `jit` feature): gated, found by building the JIT-less driver locally [executed, Linux x86-64]; the next commit adds that build to tests.yml's Rust unit-test job so Linux finds such a break, not only macOS's app job. Locally on the merged tree: mutant-catalogs (3,224 mutants, 0 problems), test_runs.py, compilerpedia check, main-cli.test and aot-run.test (also with the JIT-less driver: `aotr-no-jit-driver`), the driver's aot_run tests, native-executable, native-program-output, compilerpedia, main-thread-startup, system-linker, aot-stub-linker and native-library tests on interp and compile, a thread program (tests/threads/lifecycle.bot) through `-aot-run` with the JIT's value, and audit/aot-run/tools/mutate.tcl's nine mutants of main.tcl and native/native.tcl (`-only`: 9 killed, 0 survived) [executed, Linux x86-64]; CI [pending] |
| `b5a649e` | icy-tower (macos arm64) | 42493473172 | **failure**, one step: the release tooling's tests all passed (63, 68, 25, 11 and 15) and Botlish.app, the game, its tests, the oracle, the graphical and LaunchServices acceptances and the dry run passed [executed, macOS], but the mutant harness's baseline failed for six Botlish release tests: audit/macos-release/tools/mutate.py copied a list of its own of what single/package.tcl stages, and the merge of main added `ccompile/` (the C backend) to StageCompiler. Fixed in the next commit: the harness reads StageCompiler's list (`staged()`), so it cannot drift again; locally all 92 mutants killed [executed, Linux x86-64, the stand-in Apple tools] |
| `b5a649e` | tests (macos arm64), tests (windows x86-64), tests, tests (linux arm64), single executable | 42493473208, 42493473190, 42493482322, 42493484973, 42493487776 | macOS's smoke (its canary with aot-run.test, `AOT-run costs`) and linux control, the full Linux suite's canary, ci tools, raven clean room, icy-tower (windows x86-64) and package reproducibility **success**; no job failed; the Botlish.app job, the macOS acceptance shards and system linker, Windows' smoke and the full suites' expensive jobs were still queued after two hours when the fix was pushed, which superseded them |
| `1d6bc3a` | icy-tower (macos arm64) | 42505874085 | **success** [executed, macOS]: the release tooling's mutant harness, now reading what single/package.tcl stages, passes its baseline (97 named tests) and kills 92 of 92 mutants; Botlish.app from the commit (the merged tree's driver without its JIT), the game, its tests, the oracle, the graphical and LaunchServices acceptances and the dry run as before |
| `1d6bc3a` | tests (macos arm64), icy-tower (windows x86-64) | 42505874116, 42505874167 | macOS's smoke (its canary with aot-run.test's 35 tests, `AOT-run costs`) and linux control **success** [executed, macOS]; Icy Tower on Windows success; the Botlish.app job, the acceptance shards and the system linker [pending] (queued for a macOS runner when this was written) |
| `1d6bc3a` | tests (windows x86-64), tests, tests (linux arm64), single executable (the last three dispatched) | 42505874103, 42505877367, 42505879585, 42505881610 | no job failed; [pending] (queued for runners when this was written, the Linux canaries included) |

Ordinary CI uploads the ad hoc
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
  first start). Measured on `460fcee` (job 128698763992; `c3cd83c`
  changed no sizes):

  | part | MB |
  |---|---:|
  | Tcl.framework | 4.03 |
  | launcher (MacOS/botlish) | 0.07 |
  | compiler archive (Resources/botlish.zip) | 2.42 |
  | native driver (MacOS/botlish-native, no JIT) | 5.82 |
  | runtime archive (Resources/libbotlish_runtime.a) | 13.99 |
  | Botlish.app | 26.33 |
  | download (botlish-macos-aarch64.zip) | 10.86 |

  | startup, best of 7 | ms |
  |---|---:|
  | the launcher alone (process) | 5.0 |
  | Tcl.framework loaded and initialized | 14.6 |
  | the compiler archive mounted | 17.0 |
  | `-version` | 123.6 |
  | `-help` | 205.8 |
  | `-check` | 191.1 |
  | a program on the interpreter | 147.6 |
  | the compiler service | 91.4 |
  | the driver (`capabilities`) | 5.3 |
  | `-aot-run` of a printing program | 239.4 |
  | `-emit-native-executable`, then the executable | 234.7 |

  Of `-aot-run`'s 239 ms, 92 ms are native (lowering, the driver, the
  object, the link and the run) over the interpreter's run of the same
  program. A moved copy's first `-version` took 97-106 ms, its second
  98-111 ms: no first-start penalty in a new location.
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
* Programs that are not AOT-ready run on the interpreter only in the
  application (section 4).

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
* A release: merge to main; push the tag `botlish-macos-vX.Y.Z` on a
  commit of main (the macos-release environment's deployment rule admits
  `botlish-macos-v*`: section 9); the release gate runs it once the commit
  is green.
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
