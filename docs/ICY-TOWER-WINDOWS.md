# ICY-TOWER-WINDOWS.md -- Icy Tower on Windows x86-64

The Icy Tower vertical slice (ICY-TOWER-VERTICAL-SLICE-1.md), ported to
Windows x86-64 with MSVC's toolchain, the one native Windows target
(WINDOWS-X86-64-MILESTONE-1.md). The game is the same source: everything
but its entry program is shared with Linux. What you download is a zip of
`icy-tower.exe` and the `SDL3.dll` it loads, built from main by
`.github/workflows/icy-tower-windows.yml` on a Windows Server 2025 runner
and published as the `icy-tower-windows-latest` release:

    https://github.com/mwagner-webdev/botlish/releases/download/icy-tower-windows-latest/icy-tower-windows-x86_64.zip

Every run of the workflow, on any branch, also keeps the game as its
`icy-tower-windows-x86_64` artifact.

**Outcome.** On a Windows Server 2025 runner (run 40124226885) the binding
generates from the pinned SDL 3.4.18 headers with clang 20.1.8's MSVC
target, the game compiles under `-warnings error` and links against
SDL3.lib, and the executable passes its six Windows tests: its
`--headless --frames 600 --seed 7` run and its 600 frames of the real SDL
loop on SDL's dummy video driver both print seed 7's summary, the
independent oracle's (`frames=600 round=1 floor=26 score=260 ...
rng=3699965314`), as the Linux executable does. The shipped folder is
`icy-tower.exe` (892 KB), `SDL3.dll` (4.3 MB), a README and the two
licenses.

## 1. What the port needed

Five things stood between the Linux game and a Windows executable. The
native backend itself needed nothing: C calls, C floats, native views and
edits, layout arrays, executables and the static C runtime were all there
(WINDOWS-X86-64-MILESTONE-2.md to -4.md).

| gap | what was done | section |
|---|---|---|
| no SDL3 binding for windows-x86_64: the binding generator had no MSVC configuration | the generator's MSVC target: clang `--target=x86_64-pc-windows-msvc`, MSVC's headers required, `__int64` and `__forceinline` parsed; the binding generated on Windows by the build | 2 |
| `SDL_Log` is a variadic C call, which Windows' native backend does not lower (`cVariadics`) | SDL's error text read out of SDL and reported by the game through `std::io` | 3 |
| an SDL enumeration constant is `unsigned int` on Linux, `int` on Windows (MSVC's enums are `int`) | scancodes taken as Ints | 4 |
| `main.bot` installed Linux's `std::io::IO` | the program moved to `game.bot`; `main.bot` and `main-windows.bot` only install the contexts | 5 |
| no SDL3 for MSVC | SDL3.dll built by CMake and Visual Studio without a C runtime dependency | 6 |

## 2. The MSVC SDL3 binding

C-BINDGEN-LAYOUTS.md section 11 recorded that "windows-x86_64 has no
toolchain configuration (no MSVC tool exists to generate for it)", and
WINDOWS-X86-64-MILESTONE-2.md section 9 listed MSVC bindings as a next
slice: "the Windows SDK's headers with clang's MSVC target". This port
takes that slice as far as the game needs it.

**The toolchain.** `tools/cheader/toolchain.tcl` maps windows-x86_64 to
clang's `x86_64-pc-windows-msvc` (windows-x86_64-gnu stays MinGW-w64's
`x86_64-w64-mingw32`: two targets, two triples). On a Windows host with
Visual Studio's C++ tools, clang finds MSVC's and the Windows SDK's headers
by itself; no Developer Command Prompt is needed. Nowhere else do those
headers exist, and no other C library's headers may stand in for them, so
`::cbind::generate::CheckCrossHeaders` refuses windows-x86_64 unless the
Windows SDK's Universal CRT (`Windows Kits\10\Include\VERSION\ucrt`) is
among the directories clang searches (`cb-msvc-headers-windows-only`).

**The parser.** MSVC's own headers spell `size_t`, `ptrdiff_t` and
`intptr_t` with its sized integer keywords (vcruntime.h: `typedef unsigned
__int64 size_t;`), which no Linux or MinGW-w64 header leaves in the
preprocessed text (MinGW-w64 defines `__int64` as a macro). The declaration
parser (`tools/cheader/cdecl.tcl`) knew none of them, so every SDL function
taking a `size_t` was unsupported (`unresolved-typedef`), `SDL_malloc`
among them. `__int8`, `__int16`, `__int32` and `__int64` are now type
keywords, spelled as the `char`, `short`, `int` and `long long` they are,
and `__forceinline` is a function specifier like `__inline`
(`cd-msvc-sized-integers`, `cd-msvc-forceinline`). The spelling is not
taken on trust: the generator's `_Generic` probe of every typedef checks
it against the compiler (`typedef-abi-mismatch` otherwise). Every
committed binding is unchanged by it (`check -target committed`, all six
profiles).

**Generated at build time, not committed.** The SDL3 profile lists
windows-x86_64 among its targets; `examples/games/icy-tower/build-windows.sh`
generates the binding from the pinned SDL 3.4.18 headers on the Windows
runner and stages it beside the game, as `build.sh` stages the committed
Linux binding. It is not committed because nothing could keep a committed
one honest: the c-bindgen workflow runs on Linux, which has no MSVC headers
to regenerate it from, and the manifest records the toolchain's version and
the preprocessed translation unit's size, which move with the runner
image's Visual Studio and LLVM. Generating it where it is used keeps it
exactly what generation produces for the toolchain that builds SDL3.dll and
links the game. The workflow keeps each run's binding as its
`sdl3-binding-windows-x86_64` artifact (modules, report, manifest, layouts
and their C check), for review.

**What differs from linux-x86_64's binding.** On the Windows runner the
binding has 1,216 direct functions, 5 aliases, 15 thunks and 159
unsupported names (Linux: 1,215, 3, 15 and 172), and its preprocessed
translation unit is 363,645 tokens (Linux: 42,475; clang's intrinsic
headers and the Universal CRT are most of it, which is the image-dependent
part a committed manifest would record). Compared name by name on Linux,
with Wine's MSVCRT headers standing in for MSVC's (a development aid while
writing this, never used by the build: `tools/c-bindgen.tcl diff`), the two
differ in the target's own facts, as they should:

* LLP64: `size_t`, `int64_t` and `uint64_t` are `long long` types
  (`std::ffi::c::ULongLong`, `LongLong`), which are `long` on Linux;
* MSVC's enumerations are `int`: every enumeration constant and parameter
  is `std::ffi::c::Int` (`UInt` on Linux), which section 4 is about;
* `wchar_t` is 16 bits (`std::ffi::c::UShort`, `Int` on Linux);
* each platform's own declarations: `SDL_SetWindowsMessageHook`,
  `SDL_GetDirect3D9AdapterIndex` and `SDL_GetDXGIOutputInfo` only on
  Windows, `SDL_SetLinuxThreadPriority` only on Linux;
  `SDL_TriggerBreakpoint` is MSVC's `__debugbreak`, a builtin with no link
  symbol (unsupported).

Before the parser knew `__forceinline` (SDL's `SDL_FORCE_INLINE` with
MSVC), SDL's 15 inline functions were missing from it; before it knew
`__int64`, every function with a `size_t`. The game's own SDL calls bind
the same on both targets but for those types, which it never names.

## 3. No variadic C call

The Linux game logged a failure with `SDL_Log("Icy Tower: CALL failed:
%s", SDL_GetError())`, a variadic C call. Windows' native backend refuses
every variadic call (`cVariadics`: Win64's variadic convention, a double in
both registers, is not lowered yet; WINDOWS-X86-64-MILESTONE-2.md section
9, item 1), so the game makes none now, on any platform:

* `sdl::error_text` copies `SDL_GetError()`'s string into the session's
  128-byte native text buffer with `SDL_strlcpy` (the string is SDL's,
  bounded only by its NUL, so it is never read in place) and reads the
  buffer back through the `TextBuffer` layout as a `str`: printable ASCII as
  itself, any other byte as `?`, as `write_text` writes text.
* `sdl::SdlFailed` carries that text (`reason`), read before anything is
  released, and `sdl::close(failure)` returns it.
* `game.bot` writes `Icy Tower: WHAT failed: REASON` on standard error
  through `std::io::write_error_line`, then exits with status 1, as before.

On Linux the bytes are what SDL_Log wrote (SDL's default output is the
message and a newline on standard error): `workload-icy-tower-executable-
sdl-failure` and `-renderer-failure` pass unchanged, and both failure
outputs are byte-identical to the previous executable's. The SDL call trace
of a 2400-frame run (`trace-compare.sh`: 204,299 calls with their
arguments) is identical too: the new calls happen only on failure.

ICY-TOWER-VERTICAL-SLICE-1.md listed "a String from a C string" as missing
("SDL's error text reaches the user only through SDL_Log"). It still is: the
game reads one byte at a time through a layout, with a table of printable
characters, because the standard library has no UTF-8 decoder and no
character from an Int.

## 4. Enumeration constants

The generated SDL3 binding types an enumeration constant by the C type the
compiler gives the enumeration: `unsigned int` on Linux, `int` with MSVC.
The game held its scancodes as `List[std::ffi::c::UInt]`, which on Windows
would not hold `SDL_SCANCODE_LEFT`. A scancode is an index of SDL's keyboard
state, so `game::scancodes` is a `List[int]` (each constant passed through
`key(scancode: int)`: a List of a C scalar is no `List[int]`, a C scalar is
an `int` argument) and `sdl::poll` takes one. The event type stays
`std::ffi::c::UInt`: SDL_Event's `type` field is a `Uint32` on every
target, and comparing it with `SDL_EVENT_QUIT` compares Ints.

## 5. One game, two entry programs

As the 2048 demo did (2048-ENGINE-WORKLOAD.md; MACOS-AARCH64-MILESTONE-8.md
section 22), the program is an application module and each platform has a
small entry:

| file | what it is |
|---|---|
| `game.bot` | the program: options, the frame loop, play and headless runs, failure reports, `main` and `arguments` (was main.bot) |
| `main.bot` | Linux: installs `std::linux::io` and `sdl::Sdl`, runs `game::main` |
| `main-windows.bot` | Windows: installs `std::windows::io` (kernel32's WriteFile) and `sdl::Sdl`, runs `game::main` |
| `sdl.bot`, `render.bot`, `tower.bot`, `hud.bot`, `options.bot` | unchanged in role; nothing in them names a platform |

C's `exit` is declared in game.bot: glibc and MSVC's static C runtime both
have it. The airlock holds as before: game.bot is an ordinary module, no
function outside sdl.bot touches a pointer, view or edit, and
CONTEXT-RESOURCE-ESCAPE reports nothing (`workload-icy-tower-sdl-*`).

## 6. SDL3.dll

`tests/cffi/sdl3.tcl` builds the package-owned SDL on Windows too: the same
pinned release, configured by CMake's Visual Studio generator for x64 and
built in Release, `SDL3.dll` and its import library `SDL3.lib` copied into
Botlish's cache (`sdl3/COMMIT/`). Its options:

* every video driver SDL has on Windows: the `windows` driver for play,
  `dummy` and `offscreen` for headless runs;
* `SDL_LIBC=OFF`: SDL's own implementations of the C functions it uses, so
  the DLL imports no C runtime DLL. The executable links MSVC's static C
  runtime (WINDOWS-X86-64-MILESTONE-2.md, "The C runtime"), so the zip needs
  nothing else: no Visual C++ Redistributable.

The game links SDL3.lib through the binding's `extern c library "SDL3"` and
`-L` (link.exe's `/LIBPATH:` and `SDL3.lib`), and loads SDL3.dll from its
own directory at run time.

## 7. The build and the workflow

`examples/games/icy-tower/build-windows.sh [OUTDIR]`, in Git for Windows'
bash on Windows: builds SDL3.dll (step 1), generates the binding (step 2;
`ICY_TOWER_BINDING=DIR` keeps it), stages the game with it (step 3) and
compiles `main-windows.bot` under `-warnings error` with
`-emit-native-executable -L SDL3DIR` (step 4); OUTDIR (default
`icy-tower-windows/`) receives `icy-tower.exe` and `SDL3.dll`.

`.github/workflows/icy-tower-windows.yml` runs on every push to any branch
(documentation-only pushes skip), as the Windows test workflow does:

1. Tcl 9.0.1 and stable Rust for x86_64-pc-windows-msvc
   (`.github/actions/setup-windows`), the native backend;
2. SDL3.dll (cached by the profile's and sdl3.tcl's text);
3. `build-windows.sh dist/icy-tower-windows-x86_64`;
4. the Windows executable's tests (section 8), all six required to pass;
5. the game played headless and on SDL's dummy driver, and `--help`;
6. the signing dry run (section 9): signed copies played against the
   originals;
7. a README and the two licenses (Botlish's MIT, SDL's zlib) beside the
   executable, then the folder uploaded as the `icy-tower-windows-x86_64`
   artifact and the binding as `sdl3-binding-windows-x86_64`;
8. on main only, once `WINDOWS_SIGNING` is set, `sign` (section 9);
9. on main only, `release`: the folder (the signed one when `sign` ran)
   zipped as `icy-tower-windows-x86_64.zip` (and its `.sha256`) and
   published to the rolling `icy-tower-windows-latest` prerelease, never
   replacing the build of a later commit (single-executable.yml's rule),
   and never unsigned while signing is configured. The README's Windows
   download button links to that asset: a release asset needs no GitHub
   login and does not expire, as a run's artifact does.

## 8. Tests

`tests/workload-icy-tower.test`'s Windows section, constraint
`icyTowerWindowsExecutable` (Windows, the native backend, executables,
SDL3.dll built, clang and bash):

| test | what it checks |
|---|---|
| `workload-icy-tower-windows-builds` | build-windows.sh succeeds; icy-tower.exe is an x86-64 console PE that imports SDL3.dll; neither it nor SDL3.dll imports a C runtime DLL (tests/binary-header.tcl's `peFacts`) |
| `-windows-headless` | `--headless --frames 600 --seed 7` prints seed 7's summary, the independent oracle's |
| `-windows-dummy-driver` | the real SDL loop on the dummy driver (SDL_Init, window, renderer, events, keyboard state, every frame drawn through C floats and native memory, everything released) plays the same 600 frames |
| `-windows-gc-stress` | 120 dummy-driver frames under `BOTLISH_NATIVE_GC_STRESS=1` end in the same state |
| `-windows-sdl-failure` | an unknown video driver: status 1 and `Icy Tower: SDL_Init failed: nosuch not available` on standard error |
| `-windows-usage` | a usage error is status 2; `--help` prints the usage |

The test runs build-windows.sh with `sh`, which on Windows only Git for
Windows provides: the first CI run asked for `bash`, and the first `bash`
on the runner's PATH was System32's, WSL's launcher with no distribution
installed. On the Windows runner (run 40124226885) all six pass.

The Linux tests are unchanged in what they check, with the module lists
and the private helpers updated for game.bot and the new sdl.bot helpers.
On Linux: `workload-icy-tower.test` 20 passed (the six Windows tests
skipped), `oracle.py compare` 0 differences, the SDL call trace identical,
`c-bindgen.test` and the header archaeology's `parser.test` (three new
tests) and `corpus.test` passing, every committed binding current, every
icy-tower mutant still applying and killed.

## 9. Signing

Windows marks a downloaded file as coming from the internet, and SmartScreen
stops an unsigned executable with that mark: "Windows protected your PC",
publisher "Unknown publisher", until the user picks "More info" and "Run
anyway". An Authenticode signature names the publisher. It does not buy
SmartScreen's trust at once: that is reputation, which a signed file and its
publisher build up as people download and run them, and no certificate
grants it immediately (EV certificates stopped doing so in 2024). So a
signed build replaces "Unknown publisher" with a name at once; the warning
itself fades as the reputation grows.

The build is ready for signing and does not sign until it is configured:

* **Every build** signs copies of `icy-tower.exe` and `SDL3.dll` with a
  throwaway self-signed certificate (`sign-windows.ps1`, signtool) and plays
  them; they must print exactly what the originals print. A signature is a
  certificate table appended to the PE file, which would break an
  executable that reads data appended to itself (as the Linux stub
  linker's executables do): this one does not. The uploaded game stays
  unsigned.
* **The `sign` job** runs only once the repository variable
  `WINDOWS_SIGNING` is set, only for main (or a manual run), in the GitHub
  environment `windows-signing`, which alone holds the credentials. It
  signs both files in place with Azure Artifact Signing (a SHA-256 digest
  and an RFC 3161 timestamp from Microsoft's timestamp service, so the
  signature outlives the short-lived certificate), requires both
  signatures to be valid and timestamped (`sign-windows.ps1 -Verify`),
  plays the signed game and uploads it as
  `icy-tower-windows-x86_64-signed`.
* **The release** publishes the signed files when the job ran, naming the
  publisher in the release notes, and the unsigned ones only while
  `WINDOWS_SIGNING` is unset: a failed signature publishes nothing, and the
  previous release stays.

### Why Azure Artifact Signing

Since June 2023 the private key of a publicly trusted code-signing
certificate must live in hardware (a token, an HSM), never in a file, so no
certificate authority issues the PFX file a CI job could sign with. Azure
Artifact Signing (Trusted Signing until 2026) keeps the key in Microsoft's
HSMs, issues short-lived certificates in the validated publisher's name,
and signs through OpenID Connect: GitHub holds no key and no password, and
Azure accepts the token of this repository's `windows-signing` environment
only. It costs a monthly fee per account (Azure's pricing page has the
current one). At the time of writing Microsoft validates organizations
(in a list of countries that includes the USA, Canada, the EU and the UK)
and individual developers in the USA and Canada only: check eligibility
first.

### Setting it up: Azure

1. In an Azure subscription, register the resource provider
   `Microsoft.CodeSigning` (Subscription, Resource providers) and create an
   **Artifact Signing account** (Basic tier) in a resource group. Its
   overview shows the account URI, the region's endpoint, e.g.
   `https://eus.codesigning.azure.net/` for East US.
2. On the account, give your own user the identity verifier role (Access
   control (IAM)) and submit an **identity validation** of type Public: the
   organization's legal name (or yours), with the documents Microsoft asks
   for. Validation takes from hours to days; the validated name is the
   publisher Windows will show.
3. Create a **certificate profile** of type Public Trust on that validation.
4. In Microsoft Entra ID, register an **application** (no client secret).
   Under Certificates & secrets, Federated credentials, add one for GitHub
   Actions: organization `mwagner-webdev`, repository `botlish`, entity type
   Environment, environment `windows-signing` (subject
   `repo:mwagner-webdev/botlish:environment:windows-signing`). Note its
   Application (client) ID and the Directory (tenant) ID.
5. On the signing account, Access control (IAM), assign the role
   **Artifact Signing Certificate Profile Signer** to that application.

### Setting it up: GitHub

In the repository's Settings:

1. **Environments**, New environment `windows-signing`. Under Deployment
   branches and tags choose "Selected branches and tags" and add the rule
   `main`. (Required reviewers would make every push to main wait for an
   approval before signing; the rolling release does not need them.)
2. In that environment, **Environment secrets**: `AZURE_CLIENT_ID` (the
   application's client ID), `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
   **Environment variables**: `ARTIFACT_SIGNING_ENDPOINT` (the account URI),
   `ARTIFACT_SIGNING_ACCOUNT` (the account's name),
   `ARTIFACT_SIGNING_PROFILE` (the certificate profile's name).
3. Last, because it switches signing on: **Secrets and variables, Actions,
   Variables**, the repository variable `WINDOWS_SIGNING` with the value
   `artifact-signing`. It must be a repository variable: the sign job's
   condition reads it before the job enters its environment. Any other
   value fails the sign job, and so the release.
4. Push to main, or run the workflow on main (Actions, icy-tower (windows
   x86-64), Run workflow). The run has three jobs; the sign job's log
   names the signer and the timestamp authority of each file, and the
   release notes name the publisher.

The same with the GitHub CLI:

    repo=mwagner-webdev/botlish
    gh api --method PUT repos/$repo/environments/windows-signing \
      -F 'deployment_branch_policy[protected_branches]=false' \
      -F 'deployment_branch_policy[custom_branch_policies]=true'
    gh api --method POST repos/$repo/environments/windows-signing/deployment-branch-policies \
      -f name=main -f type=branch
    gh secret set AZURE_CLIENT_ID --repo $repo --env windows-signing
    gh secret set AZURE_TENANT_ID --repo $repo --env windows-signing
    gh secret set AZURE_SUBSCRIPTION_ID --repo $repo --env windows-signing
    gh variable set ARTIFACT_SIGNING_ENDPOINT --repo $repo --env windows-signing --body https://eus.codesigning.azure.net/
    gh variable set ARTIFACT_SIGNING_ACCOUNT --repo $repo --env windows-signing --body ACCOUNT
    gh variable set ARTIFACT_SIGNING_PROFILE --repo $repo --env windows-signing --body PROFILE
    gh variable set WINDOWS_SIGNING --repo $repo --body artifact-signing

To stop signing, delete `WINDOWS_SIGNING`: the next build of main is
published unsigned again. To try a change to the sign job on a branch, add
the branch to the environment's deployment rule and run the workflow on it
by hand (the release stays main's).

### Checking a signature

In Explorer: `icy-tower.exe`'s Properties, Digital Signatures, which names
the signer and the timestamp. In PowerShell, from the unpacked zip:

    pwsh examples/games/icy-tower/sign-windows.ps1 -Verify icy-tower.exe SDL3.dll

(`Get-AuthenticodeSignature icy-tower.exe` without the checkout.)

### Another signing service

A publisher Artifact Signing does not validate needs a certificate from a
certificate authority, whose key then lives in that authority's cloud HSM
or on a hardware token. A cloud HSM comes with its own signing tool: give
the sign job a step of that tool, under a new value of `WINDOWS_SIGNING`,
in place of the two Azure steps, and keep the verification after it. A
hardware token needs the machine it is plugged into: a self-hosted Windows
runner for the sign job.

## 10. Not done

* **No signature yet.** Signing waits for an Azure Artifact Signing account
  and the GitHub configuration of section 9; until then the release is
  unsigned and SmartScreen warns. The sign job has not run: its first run
  is the first push to main after `WINDOWS_SIGNING` is set.

* **No committed MSVC binding**, and so no c-bindgen workflow check of
  one, and no MSVC binding of the generator's fixture: the fixture's tests
  still skip on Windows (`fixtureHostBinding`). The generator's MSVC target
  is exercised by the Windows build only.
* **No Win64 variadic C calls**: the game avoids them; the backend still
  refuses them.
* **A console window.** Botlish executables are console programs; started
  from Explorer, the game opens a console beside its window (it shows the
  run's summary at the end). No GUI-subsystem option was added.
* **No real display in CI.** The runner plays the dummy driver; the
  windows driver, a real window and keyboard input are not exercised.
* **x86-64 only**: no Windows on Arm.

## 11. What to run when changing this

* The game: `tests/workload-icy-tower.test` (on Linux; on Windows with
  SDL3.dll built it runs the Windows section too), the mutants and the
  oracle (ICY-TOWER-VERTICAL-SLICE-1.md), and for sdl.bot, render.bot or
  game.bot the SDL call trace comparison (AGENTS.md); then the Windows
  workflow on the branch.
* The generator's MSVC target or the parser: `tests/c-bindgen.test`,
  `tools/c-bindgen.tcl check PROFILE -target committed` for every profile,
  the archaeology's `parser.test`, `corpus.test` and `tools/all.tcl`, and
  the Windows workflow (the only place windows-x86_64 is generated).
* `tests/cffi/sdl3.tcl`'s Windows build: the Windows workflow.
* Signing (`sign-windows.ps1`, the dry run, the sign or release job): the
  Windows workflow on the branch runs the dry run; the sign job runs on
  main, or by hand on a branch the `windows-signing` environment admits
  (section 9).
