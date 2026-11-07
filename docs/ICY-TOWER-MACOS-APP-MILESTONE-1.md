# ICY-TOWER-MACOS-APP-MILESTONE-1.md

## A Finder-launchable, Developer ID-signed, notarized and distributable Icy Tower.app

The macOS AArch64 Icy Tower (ICY-TOWER-MACOS-MILESTONE-1.md) as an
application a person downloads, extracts and opens from the Finder:
`Icy Tower.app`, assembled from the executable build-macos.sh builds,
reporting a failure to a person who has no terminal, signed with a
Developer ID Application identity with the hardened runtime and a secure
timestamp, notarized by Apple, stapled, accepted by Gatekeeper, packaged as
a ZIP whose download is itself played, and published as a versioned GitHub
Release -- with the release's credentials validated, locally and by Apple,
before anything uses them.

Claims are marked **Executed** (run and checked), **Inspected** (supported
by code, metadata or tool output read, not run), **Credential-blocked**
(the real signing or notarization could not run: the Apple credentials are
not configured in GitHub yet), **Environment-blocked** (another limitation
of the test environment) or **Not implemented**. Synthetic credentials are
never taken as evidence of a real Developer ID signature or notarization.

The macOS evidence is GitHub's macos-15 runners' (Apple Silicon), through
`.github/workflows/icy-tower-macos.yml`; section 43 lists the runs.

## Contents

1. [Result](#1-result)
2. [Starting executable and native dependencies](#2-starting-executable-and-native-dependencies)
3. [The application bundle](#3-the-application-bundle)
4. [Info.plist fields and validation](#4-infoplist-fields-and-validation)
5. [LaunchServices recognition](#5-launchservices-recognition)
6. [Finder-style startup](#6-finder-style-startup)
7. [Activation and focus](#7-activation-and-focus)
8. [Terminal-free error reporting](#8-terminal-free-error-reporting)
9. [Bundle identity and versioning](#9-bundle-identity-and-versioning)
10. [GitHub configuration](#10-github-configuration)
11. [Setting up the credentials](#11-setting-up-the-credentials)
12. [Releasing](#12-releasing)
13. [Credential preflight](#13-credential-preflight)
14. [Base64 handling](#14-base64-handling)
15. [PKCS#12 parsing and the password](#15-pkcs12-parsing-and-the-password)
16. [The Developer ID certificate and its private key](#16-the-developer-id-certificate-and-its-private-key)
17. [Team ID](#17-team-id)
18. [The notarization key (.p8)](#18-the-notarization-key-p8)
19. [Key ID, Issuer ID and bundle identifier](#19-key-id-issuer-id-and-bundle-identifier)
20. [Apple's validation of the notarization credentials](#20-apples-validation-of-the-notarization-credentials)
21. [Synthetic credential fixtures](#21-synthetic-credential-fixtures)
22. [Credential negative tests](#22-credential-negative-tests)
23. [Secret protection and the temporary keychain](#23-secret-protection-and-the-temporary-keychain)
24. [Signing identity selection](#24-signing-identity-selection)
25. [Signing: Developer ID, hardened runtime, timestamp](#25-signing-developer-id-hardened-runtime-timestamp)
26. [Signature inspection and entitlements](#26-signature-inspection-and-entitlements)
27. [Hardened-runtime graphical acceptance](#27-hardened-runtime-graphical-acceptance)
28. [Notarization](#28-notarization)
29. [Stapling](#29-stapling)
30. [Gatekeeper](#30-gatekeeper)
31. [Quarantine and the downloaded artifact](#31-quarantine-and-the-downloaded-artifact)
32. [The ZIP: packaging and extraction](#32-the-zip-packaging-and-extraction)
33. [Tamper control](#33-tamper-control)
34. [The game: graphical and keyboard regression](#34-the-game-graphical-and-keyboard-regression)
35. [Clean-environment independence](#35-clean-environment-independence)
36. [GitHub Actions trust boundaries](#36-github-actions-trust-boundaries)
37. [Release publication](#37-release-publication)
38. [SHA-256 and provenance](#38-sha-256-and-provenance)
39. [Mutation results](#39-mutation-results)
40. [Negative artifact controls](#40-negative-artifact-controls)
41. [Linux and Windows regressions](#41-linux-and-windows-regressions)
42. [Timing and sizes](#42-timing-and-sizes)
43. [macOS CI runs](#43-macos-ci-runs)
44. [The release run and its notarization](#44-the-release-run-and-its-notarization)
45. [Troubleshooting a release](#45-troubleshooting-a-release)
46. [Remaining limitations](#46-remaining-limitations)
47. [Reproduction commands](#47-reproduction-commands)
48. [Exact files changed](#48-exact-files-changed)

## 1. Result

**Ready for a credentialed release; the release itself has not run.** The
seven GitHub values (section 10) are not configured, so the Developer ID
signature, notarization, stapling, Gatekeeper's notarized verdict, the
notarized download played and the GitHub Release are **Credential-blocked**
(section 44). Everything before them, and every check after them, is
implemented, tested against recording stand-ins of Apple's tools, and as
far as a runner allows, run on macOS:

* **Executed** (run 41224177467, every step green; and runs 41201527696
  to 41224177467): `Icy Tower.app` assembled from build-macos.sh's
  executable byte for byte (3,772 KiB, a validated Info.plist, two
  licenses), signed ad hoc with the hardened runtime, verified strictly,
  refused when tampered with, refused by Gatekeeper, packaged and verified
  from a fresh extraction; LaunchServices recognizes it and starts it as
  the Finder does (launchd its parent, no arguments, the working
  directory `/`, frontmost by itself) with the build's products hidden;
  it plays under the hardened runtime (keys, relaunch, its close button,
  GC stress); every startup and runtime failure reaches a person in an
  alert while the terminal run stays silent; the quarantined download of
  a non-notarized build is refused by Gatekeeper's real first-launch
  dialog. The earlier milestone's graphical acceptance is kept whole
  (12 of 12 cases).
* **Executed, the credential path**: the preflight's 63 tests (every
  mistake of the brief's table, each with its code and remedy, no secret
  printed, nothing written), the stages' 63 tests, the workflow's 23 trust
  tests, and every mutant of the catalog killed (70 of 70 then; 74 of 74
  since the Gatekeeper correction, section 30), on Linux and on macOS; on the
  runner, a rehearsal with a throwaway identity: the preflight, the
  temporary keychain, the identity selected by its SHA-1, Apple's own
  answer to an unknown key (HTTP 401, classified MACOS-NOTARY-AUTH), never
  publishable, the cleanup verified.
* **Environment-blocked**: the rehearsal's signature. codesign signs only
  with a chain that reaches a trusted root, and a runner cannot trust a
  throwaway root without a person (section 25). No trust setting is
  changed by any job.
* **Found on the way, and handled**: notarytool 1.0.0 (38) crashes,
  printing nothing, on a .p8 re-encoded without the curve inside its
  ECPrivateKey (the runner's A/B: Apple's layout reaches Apple, the other
  traps). The preflight refuses such a key with the remedy (section 18).
  `store-credentials` gives no reason for a refusal; the release asks Apple
  why with one read request (section 20).
* **Not this milestone's, recorded**: the earlier milestone's `restart`
  case failed intermittently (section 34); the macOS integration's
  mutants: 31 of 31 killed (41245041656) once the harness defects the
  earlier runs exposed were fixed (a stale alert across cases; a launch
  check SDL3's own activation makes a race; bundles in a temporary
  directory LaunchServices did not find, whose baseline then held in an
  isolated run, 41297189955) (section 39).

Linux and Windows are unchanged (section 41): no shared module changed, and
their workflows pass.

## 2. Starting executable and native dependencies

The input is build-macos.sh's executable, unchanged in this milestone's
build: one Mach-O arm64 executable (3.8 MB as linked) with LC_MAIN's
512 MiB stack (`-native-startup main-thread`), LC_BUILD_VERSION minimum
macOS 11.0, SDL3 3.4.18 linked statically, and 22 dynamic libraries, every
one the system's (/usr/lib, /System/Library/Frameworks), none SDL3's
(ICY-TOWER-MACOS-MILESTONE-1.md, sections 14 and 15). What changed in it is
its entry's IO context (section 8): main-macos.bot installs
`macos_app::create()` instead of `std::darwin::io::create()`.

`macos/bundle.py check-executable` reads the Mach-O itself (its header and
load commands, no tool) before anything is assembled: thin (a universal
binary is refused), CPU type arm64, MH_EXECUTE, LC_MAIN's stack exactly
536870912 (a worker-startup executable has the default and is refused),
LC_BUILD_VERSION for macOS with a minimum no later than the bundle's
LSMinimumSystemVersion, every LC_LOAD_DYLIB (and weak, re-export, lazy,
upward) under /usr/lib or /System/Library and none named SDL, the execute
permission. On macOS package-macos.sh also asks Apple's tools -- `lipo
-archs` is arm64, `otool -l`'s LC_MAIN stacksize 536870912, `otool -L` only
system libraries -- and requires them to agree.

## 3. The application bundle

    Icy Tower.app/
        Contents/
            Info.plist
            MacOS/
                icy-tower                  build-macos.sh's executable
            Resources/
                LICENSE-Botlish.txt        the repository's LICENSE (MIT)
                LICENSE-SDL3.txt           SDL3's LICENSE.txt (zlib), from the pinned source
            _CodeSignature/CodeResources   (written by codesign)
            CodeResources                  (the stapled ticket, written by stapler)

`examples/games/icy-tower/package-macos.sh EXECUTABLE OUTDIR --bundle-id ID
--version X.Y.Z --build B --sdl3-license FILE` assembles it. It compiles,
links, signs and notarizes nothing: it checks the executable (section 2),
assembles the bundle in a private directory beside OUTDIR (umask 022,
directories 0755, the executable copied with `cp -X` -- no extended
attribute of the build's copy -- and made 0755, compared byte for byte with
its source, the property list and the licenses 0644, `xattr -cr`), writes
the Info.plist with `bundle.py plist` (Python's plistlib, from validated
values: never text pasted into XML), checks the whole bundle
(`bundle.py check`: the name, the layout -- nothing but the executable, the
Info.plist, the two licenses and the signature's files; no symbolic link --
the property list, the executable it names), on macOS also `plutil -lint`
and plutil's own reading of CFBundleIdentifier and CFBundleExecutable, and
only then replaces OUTDIR's `Icy Tower.app`. A refused bundle leaves an
earlier one as it was (`test_package_script_keeps_previous_bundle`: a
worker-startup executable and a com.apple. identifier are both refused, the
previous Info.plist byte for byte unchanged).

No DMG: the repository publishes ZIPs (single-latest, icy-tower-windows-
latest), and a ZIP made with `ditto` keeps the bundle's permissions and
signature, so a DMG would add a second container to sign and notarize and
no property the release needs. No icon: Resources holds what the
application needs, and the game has no icon of its own (the Finder shows
the generic application icon).

## 4. Info.plist fields and validation

| key | value | why |
|---|---|---|
| CFBundlePackageType | APPL | an application |
| CFBundleExecutable | icy-tower | Contents/MacOS/icy-tower |
| CFBundleIdentifier | MACOS_BUNDLE_ID (release); `org.botlish.examples.icy-tower.ci` (ordinary CI) | the application's stable identity (section 9) |
| CFBundleName, CFBundleDisplayName | Icy Tower | |
| CFBundleShortVersionString | X.Y.Z of the tag (CI: 0.0.0) | the release's version |
| CFBundleVersion | X.Y.Z of the tag (CI: 0.0.0) | a deterministic build identifier: the same tag always gives the same one |
| CFBundleInfoDictionaryVersion | 6.0 | |
| CFBundleDevelopmentRegion | en | |
| LSMinimumSystemVersion | 11.0 | the executable's LC_BUILD_VERSION minimum and the static SDL3's deployment target (its UniformTypeIdentifiers and CoreHaptics links are strong: ICY-TOWER-MACOS-MILESTONE-1.md, section 12) |
| LSApplicationCategoryType | public.app-category.arcade-games | |
| LSEnvironment | {ICY_TOWER_ERROR_ALERTS: "1"} | LaunchServices adds it to the launched process's environment: the alert of a failure (section 8) |
| NSHighResolutionCapable | true | the window's drawable at the display's backing scale (the game draws in logical units, letterboxed) |
| NSPrincipalClass | NSApplication | see below |
| NSHumanReadableCopyright | the licenses | |

`NSPrincipalClass` was evaluated against SDL3's Cocoa startup (SDL 3.4.18,
src/video/cocoa/SDL_cocoaevents.m: `Cocoa_RegisterApp` creates the
process's application object itself, an NSApplication subclass, the first
time video starts, and SDL never calls NSApplicationMain, the one reader of
NSPrincipalClass). So the key names the kind of application the bundle is,
as every AppKit application's does, and starts no second lifecycle: SDL's
object is the only NSApplication. No LSUIElement, LSBackgroundOnly or
NSUIElement: `bundle.py check` refuses each (an agent, a background-only
application), and the `agent-application` mutant is killed by
`app-bundle`'s check of the Info.plist as macOS reads it (NSBundle: no
LSUIElement, LSBackgroundOnly, NSUIElement or NSBGOnly). Not by the launch:
SDL3's `Cocoa_RegisterApp` sets NSApplicationActivationPolicyRegular
itself, so an LSUIElement bundle read after SDL started already says
regular, and LaunchServices activated the agent in one run and not in
another (policy 1 in run 41228596109; not activated in 41235898277;
activated, policy 0, in 41240614881, where the mutant survived the launch
checks).

`bundle.py` validates before writing and after: the identifier
(reverse-DNS, at least two components, letters, digits, hyphens and
periods -- Apple's rule for CFBundleIdentifier, no underscore, no
com.apple.), both versions (one to three period-separated integers),
every required key with its exact value and type, the identifier, version
and build the release asked for, no forbidden key. A property list that
does not parse, a missing one, a wrong CFBundleExecutable or a missing,
non-executable or wrong-architecture executable are refused (section 40).

**Executed** (run 41197431104 and the acceptance run 41212691891, macos-15): from
build-macos.sh's executable (3,846,184 bytes), package-macos.sh printed
`executable: Mach-O arm64, LC_MAIN stack 536870912, macOS 11.0.0 (SDK
15.5.0), 22 system libraries, none SDL3's`, `lipo: arm64; otool: LC_MAIN
536870912, 22 system libraries`, `plutil: the Info.plist is valid;
CFBundleIdentifier org.botlish.examples.icy-tower.ci, CFBundleExecutable
icy-tower`, and the bundle, 3,772 KiB, in 1 s. `workload-icy-tower-macos-
app-bundle` (the macOS test file's twelfth) assembles the built executable
again and checks it byte for byte, the identifier, LSEnvironment's
ICY_TOWER_ERROR_ALERTS, LSMinimumSystemVersion 11.0 (plutil), the ad hoc
signature with the hardened runtime, and strict verification. **Executed**
on Linux: every negative control of section 40 (BundleControls, 17 tests).

## 5. LaunchServices recognition

`macos-session.py app`'s `app-bundle` case asks the system, through the
helper's `app-info` (macos-input.m): NSBundle reads the bundle (its
identifier, executable, versions, package type), its content type
(NSURLTypeIdentifierKey) conforms to `com.apple.application-bundle`, the
Finder treats it as one item (`isFilePackageAtPath:`), `LSRegisterURL`
registers it (status 0), and LaunchServices then knows it for its
identifier (`URLsForApplicationsWithBundleIdentifier:`). **Executed** (run
41197431104): `{"type":"com.apple.application-bundle","identifier":
"org.botlish.examples.icy-tower.ci","register_status":0,"package":true,
"registered":[".../out/app/Icy Tower.app"], ...}`; every check held but one
that read the helper's `bundle` field, an Objective-C comparison boxed as
the number 1, as anything but `true` (a harness bug, fixed; the acceptance
run 41212691891: 8 of 8). Since run 41245041656 the case has a ninth
check: the Info.plist as macOS reads it (NSBundle) has no LSUIElement,
LSBackgroundOnly, NSUIElement or NSBGOnly -- the observable an agent
bundle cannot hide (section 4).

## 6. Finder-style startup

The `app-launch` case launches the bundle as the Finder does -- `open -n`
(LaunchServices; `--stdout` and `--stderr` catch what the game writes, no
argument) -- and reads the process LaunchServices started from outside.
**Executed** (run 41197431104):

    PASS LaunchServices started it: pid 19127
    PASS its parent is launchd (pid 1), not a terminal or this harness
    PASS its arguments: the executable alone ('.../out/app/Icy Tower.app/Contents/MacOS/icy-tower'): LaunchServices passed none (no -psn_)
    PASS its working directory is LaunchServices' (/), not the harness's
    PASS its window appears
    PASS LaunchServices made it the active application (frontmost: {'pid': 19127, 'name': 'Icy Tower', 'bundle': 'org.botlish.examples.icy-tower.ci'})
    PASS the game: the walls: 100.0% of their samples wall or mortar
    PASS the game: the walls' mortar lines: 13 (one every 48 units)
    PASS the game: the HUD panel: 96% panel or text, 5.4% text
    PASS the game: the player: 26 x 34 units at x 228
    PASS the game: no banner (found: None)
    PASS Escape ends it (exited, focus by already active)
    PASS its summary reached open's --stdout: "frames=250 round=1 floor=0 score=0 best=1.7 time=4.2 over=no x=227 y=92 camera=0 platforms=11 rng=397172474"
    PASS nothing on standard error

(the check of NSRunningApplication's activation policy, 0 --
NSApplicationActivationPolicyRegular -- read the helper's boxed 1 as
false, the same harness bug: fixed, and the acceptance run 41212691891 holds
it.) **Launch arguments**: macOS 15 passes a LaunchServices launch no
argument at all -- no `-psn_` -- so options.bot needs no accommodation and
none was added; the game's own `--fly` through `open --args` is still a
usage error (section 8). The working directory is `/`, and the game, which
reads no file, does not care (section 35). A second launch after the first
ended (`app-relaunch`) is a new process, its window closed by its close
button (Accessibility's AXCloseButton): status gone, the summary printed,
nothing on standard error (run 41197431104: pid 19403, `frames=128 ...
over=no`).

## 7. Activation and focus

A LaunchServices launch activates the application: the game was the
frontmost application when its window appeared, with no help from the
harness ("focus by already active" -- where a terminal-launched executable
needed the harness's activation, ICY-TOWER-MACOS-MILESTONE-1.md, section
27), and its key presses reached it (`app-keyboard`, run 41197431104: Right
+111 units, Left -89 units, Escape quits, round 1's summary). It is a
regular application -- a Dock icon, the menu bar, no agent or background
key -- SDL's Cocoa_RegisterApp sets NSApplicationActivationPolicyRegular,
and bundle.py refuses LSUIElement and LSBackgroundOnly.

## 8. Terminal-free error reporting

**The problem.** The game reports a failure (SDL's video cannot start, a
window or a renderer cannot be made, a frame cannot be drawn) by writing
`Icy Tower: WHAT failed: SDL's error` to standard error and ending with C's
`exit(1)`, and a usage error by writing its line and the usage (game.bot).
Launched from the Finder, a process's standard error goes nowhere a person
sees.

**The design.** A failure must reach a person without changing the game for
any other platform -- `game.bot`, `sdl.bot` and every shared module stay as
they are, so the Linux and Windows executables are built from the same
sources -- and without a second event loop or a background worker. The
seam is the one the game already has: every report is a write through the
installed `std::io::IO` context. So the macOS entry installs an application
IO context of its own, `macos_app.bot`'s `App`:

* `write_text` and `write_error_text` write all of the text to descriptor 1
  or 2 by `std::darwin::write` (libSystem's write(2)) with exactly
  std::darwin::io's completion policy (a short write completed, a failed one
  or one without progress `std::io::WriteFailed`, no retry);
* the first `write_error_text` of a run that LaunchServices launched --
  `ICY_TOWER_ERROR_ALERTS` is `1` in the environment, which only the
  bundle's LSEnvironment puts there -- also shows that text in an alert,
  after writing it to standard error and before returning; the game then
  exits as it always does. One alert per run: the usage after a usage
  error's first line goes to standard error only.

The alert is CoreFoundation's `CFUserNotificationDisplayAlert`: a C function
that needs no NSApplication, no SDL, no video driver and no window of the
process's own (the alert is the system's user-notification agent's), so it
works whatever SDL reached -- before `SDL_Init`, after `SDL_Quit`, with
`SDL_VIDEO_DRIVER` naming a driver that does not exist (SDL's own message
box would follow that hint and fail). It returns when the person dismisses
it: no hidden dialog keeps the process alive, and the process ends right
after. A Mach-O run from a terminal has no such variable: its usage,
`--help`, headless output and diagnostics are what they were, no dialog
(`app-terminal-failure`).

`macos_app.bot` follows sdl.bot's authority rules: its C calls (getenv,
CFStringCreateWithCString, CFRelease, CFUserNotificationDisplayAlert,
std::darwin::write) and its native view (the variable's first two bytes)
are made only by functions that require App, the context it declares, so
it is mediated, never direct (`workload-icy-tower-app-module`: `macos_app:
contextualized`, every game module and the entry ordinary); its C
declarations and every helper that holds a pointer are private; it calls
no SDL. Its hand-written C declarations are checked against the macOS SDK's
headers by `audit/icy-tower/tools/app-abi-check.py` on the Mac (each
parameter's and result's C type by template deduction from the prototype,
the constants kCFStringEncodingUTF8 and kCFUserNotificationStopAlertLevel).
**Inspected** on Linux: main-macos.bot with macos_app.bot compiles for
macos-aarch64 under `-warnings error` (the linux-aarch64 binding standing
in), and no shared module names macos_app, CoreFoundation or the variable
(`workload-icy-tower-app-module-shared-sources-untouched`).

**Executed** (run 41197431104; the probe's bundle for the two injected
failures, `SDLTRACE_FAIL`, sdltrace.c's fault injection): every case
launched through LaunchServices, the alert read through Accessibility from
UserNotificationCenter's window, the game still waiting while it was up,
its OK pressed, the game gone after it by itself, no alert left, the report
on standard error too (`open --stderr`):

| case | the failure | the alert's text |
|---|---|---|
| app-alert-video | `SDL_VIDEO_DRIVER=nosuch` (SDL's video cannot start) | Icy Tower stopped / Icy Tower: SDL_Init failed: nosuch not available |
| app-alert-window | the probe, `SDLTRACE_FAIL=SDL_CreateWindow` | Icy Tower stopped / Icy Tower: SDL_CreateWindow failed: SDLTRACE_FAIL: SDL_CreateWindow injected |
| app-alert-renderer | `SDL_RENDER_DRIVER=nosuch` | Icy Tower stopped / Icy Tower: SDL_CreateRenderer failed: nosuch not available |
| app-alert-usage | `--fly` (the application's configuration: an unknown option) | Icy Tower stopped / icy-tower: unknown option: --fly |
| app-alert-runtime | the probe, `SDLTRACE_FAIL=SDL_RenderPresent@90`: a frame that cannot be drawn, after the Cocoa window and Metal started | Icy Tower stopped / Icy Tower: drawing a frame failed: SDLTRACE_FAIL: SDL_RenderPresent injected |

The video failure is the one SDL's own message box could not have shown
(its driver selection follows the very hint that failed); the CoreFoundation
alert showed it. And the terminal run (`app-terminal-failure`, the bundle's
Mach-O run directly with `SDL_VIDEO_DRIVER=nosuch`): status 1, the line on
standard error, no alert, the process gone at once (0.0 s). Every case is
bounded: 25 s for the alert to appear, 10 s for the game to end after it;
an alert that never comes fails the case and the process is killed.

## 9. Bundle identity and versioning

The bundle identifier is the application's identity for macOS (its
preferences, its privacy permissions, LaunchServices' registration), and a
release never changes it: the release job reads MACOS_BUNDLE_ID (validated
by the preflight and by bundle.py), and `release.py identity` compares it
with the `bundle_id` of the provenance of every earlier
`icy-tower-macos-v*` release; a different one is refused
(MACOS-BUNDLE-METADATA, "a release never changes the application's
identity"; `test_identity_never_changes`, mutant `identity-may-change`).
The version is the tag's (`icy-tower-macos-v1.2.3` is 1.2.3, three integers
or the release job refuses the tag); CFBundleVersion is the same string: a
deterministic build identifier, the same for every rebuild of a tag and
different for every release. Ordinary CI builds use `0.0.0` and their own
identifier (`org.botlish.examples.icy-tower.ci`), never a release's.

## 10. GitHub configuration

The configuration contract (exact names):

| Name | GitHub type | Contents |
|---|---|---|
| `MACOS_CERTIFICATE_P12_BASE64` | Secret | Base64 of a binary `.p12` holding a Developer ID Application certificate and its private key |
| `MACOS_CERTIFICATE_PASSWORD` | Secret | the password protecting that `.p12` |
| `APPLE_NOTARY_KEY_BASE64` | Secret | Base64 of the App Store Connect team API key file `AuthKey_<KEY_ID>.p8` |
| `APPLE_NOTARY_KEY_ID` | Variable | the API key's Key ID (10 characters) |
| `APPLE_NOTARY_ISSUER_ID` | Variable | the team API keys' Issuer ID (a UUID) |
| `APPLE_TEAM_ID` | Variable | the Apple Developer Team ID (10 characters) |
| `MACOS_BUNDLE_ID` | Variable | the game's stable reverse-DNS bundle identifier, e.g. `com.example.icytower` |

All seven belong to the GitHub Actions **environment `macos-release`**
(repository Settings, Environments): environment secrets and variables are
given only to a job that names the environment -- the release job -- and
only once the environment's protection rules admit the run. The authentication
is App Store Connect's **team API key** (an Issuer ID and a Key ID); this
release has no Apple ID and password path and no individual key path. A
Developer ID certificate alone is not a notarization credential: both are
needed.

## 11. Setting up the credentials

Everything here happens on the developer's own Mac and in GitHub's web
settings. Never paste a credential into an issue, a commit, a log or a chat.

1. **The Developer ID Application identity as a .p12.** In Keychain
   Access, login keychain, My Certificates, find "Developer ID Application:
   *Your Name* (*TEAMID*)" with its private key beneath it (if it is not
   there: developer.apple.com, Certificates, Identifiers & Profiles,
   Certificates, "+", Developer ID Application, with a certificate signing
   request from Keychain Access, Certificate Assistant; or Xcode, Settings,
   Accounts, Manage Certificates, "+", Developer ID Application; only the
   team's Account Holder can create one). Select the certificate entry
   (not the key alone, not "Developer ID Installer"), File, Export Items,
   format Personal Information Exchange (.p12), and give it a password.
2. **The App Store Connect team API key.** App Store Connect, Users and
   Access, Integrations, App Store Connect API, Team Keys: "+" (Generate
   API Key), a name, access **Developer** (enough for notarization), then
   Download API Key -- `AuthKey_<KEY_ID>.p8`. Apple lets you download it
   once: keep the file. The **Key ID** is the key's column in the table
   (and the file name's part after `AuthKey_`); the **Issuer ID** is the
   UUID shown above the table.
3. **The Team ID.** developer.apple.com, Account, Membership details, Team
   ID; it is also the parenthesized end of the certificate's name.
4. **Base64.** In Terminal, in the directory holding the files:

       base64 < DeveloperIDApplication.p12 | tr -d '\n'
       base64 < AuthKey_KEYID.p8 | tr -d '\n'

   Each prints one line: copy all of it, including any trailing `=`, and
   nothing else (not the command, the file name or the prompt). Encode
   once, and encode the file, not its name.
5. **GitHub.** Repository, Settings, Environments, New environment,
   `macos-release`:
   * Deployment branches and tags: "Selected branches and tags", add the
     tag rule `icy-tower-macos-v*` (no branch): only a release tag's run
     can enter the environment.
   * Required reviewers (recommended): yourself, so every release waits for
     an approval before the credentials are given to it.
   * Environment secrets: the three secrets of section 10, each its value
     alone. Environment variables: the four variables.
6. **The tags.** Repository, Settings, Rules, Rulesets, New tag ruleset,
   target `icy-tower-macos-v*`, restrict creations, updates and deletions
   to the repository's administrators (a release tag then names one
   commit, once).

Nothing else: no keychain set up by hand, no local notarization, no edit of
a workflow or a script.

## 12. Releasing

Tag a commit of `main` and push the tag:

    git tag icy-tower-macos-v1.0.0 <commit of main>
    git push origin icy-tower-macos-v1.0.0

The push runs `icy-tower (macos arm64)` for the tag. First its `tested` job
checks that every test of the tagged commit is green (CI-RUNS.md, "The
release gate": tests.yml and tests-arm64.yml with their GC-stress jobs,
macOS, Windows, static-decisions when it ran); until they are, the run is
deferred -- every other job skips -- and the release gate runs the workflow
on the tag again once they are, so a tag can be pushed right after its
merge. Then the game job (the build and every test, as on any push; no
credential), then the release job in the `macos-release` environment
(waiting for its approval when one is required), then the publish job. A manual run (Actions, icy-tower (macos
arm64), Run workflow, "Use workflow from" the tag) does the same; a manual
run on a branch runs no release job. The release job refuses a tag that is
not `icy-tower-macos-vX.Y.Z`, one that does not name the run's commit, and
a commit that is not in main's history. The release appears under Releases
as "Icy Tower X.Y.Z for macOS (Apple Silicon)", with
`icy-tower-macos-aarch64.zip`, `SHA256SUMS` and `provenance.json`; a release
of the tag that exists already is never replaced (tag a new version).

What the release job does, in order (each step a `release.py` stage
unless named otherwise; the first failure stops the job, and the cleanup runs
whatever happened):

1. **The revision**: the tag is `icy-tower-macos-vX.Y.Z`, names the run's
   commit, and that commit is in main's history.
2. **The tested executable**: the game job's `icy-tower-macos-release-input`
   artifact, whose SHA-256 must be the game job's `exe_sha256` output (the
   release job compiles nothing).
3. **The bundle**: package-macos.sh with MACOS_BUNDLE_ID and the tag's
   version (section 3).
4. `preflight` (section 13): the seven values, locally, before any Apple
   tool.
5. `identity` (section 9): the bundle identifier of every earlier
   `icy-tower-macos-v*` release's provenance.
6. `keychain` (sections 23, 24): the temporary keychain, the identity
   imported, exactly that identity valid for code signing.
7. `notary-auth` (section 20): Apple authenticates the team API key.
8. `sign` (section 25), or for a resumed notarization `adopt` of the
   earlier run's signed bundle (section 28).
9. `verify-signature` (section 26); the signed bundle is uploaded
   (`icy-tower-macos-signed`, for a resume).
10. **Hardened-runtime acceptance** (section 27): the Developer ID-signed
    application launched through LaunchServices and played; `record
    hardened-runtime`.
11. `notarize` (section 28).
12. `staple`, `verify-signature --label stapled`, `gatekeeper --expect
    notarized`, `tamper` (sections 29, 30, 33).
13. `package` (section 32): the release ZIP, `provenance.json`,
    `SHA256SUMS`.
14. **The downloaded release launched** (section 31): the ZIP extracted,
    quarantined, opened through Gatekeeper's first-launch dialog and
    played; `record final-artifact`.
15. `publishable`: every stage of the sequence passed, in order, on one
    CDHash and one ZIP digest; only then are the three release assets
    uploaded (`icy-tower-macos-release`).
16. `cleanup` (`if: always()`): the keychain deleted, the search list
    restored, the decoded files removed, each verified.

The **publish** job (Ubuntu, no secret, the only `contents: write`)
downloads the three assets, checks `SHA256SUMS` and the ZIP against the
release job's `zip_sha256` output and the provenance's version and mode,
refuses a tag whose release exists, and creates the release
(`gh release create --verify-tag`).

## 13. Credential preflight

`examples/games/icy-tower/macos/credentials.py check --out DIR` reads the
seven values from its environment and validates every one before any Apple
tool sees one; release.py's `preflight` stage runs it. It reports **every**
problem it finds, each one line under a stable code, naming the variable,
with the remedy on the next, and exits 1; nothing is signed, nothing is
sent to Apple, and nothing is written to DIR. On success DIR (owner-only)
receives `identity.p12` and `notary-key.p8` (owner-only) and
`identity.json`, the public facts later stages read (the certificate's
SHA-1, subject, team, issuer, validity; the notary key's ID and issuer; the
bundle identifier).

The codes:

| Code | Meaning |
|---|---|
| MACOS-CONFIG-MISSING | a value is not set, or empty (GitHub gives an undefined secret or variable as empty) |
| MACOS-CREDENTIAL-BASE64 | an encoded value is not valid Base64 (or is a path, a command, raw PEM) |
| MACOS-CREDENTIAL-FORMAT | the decoded bytes are not the container they must be |
| MACOS-CERTIFICATE-DECRYPT | the .p12 cannot be decrypted with its password |
| MACOS-CERTIFICATE-IDENTITY | no private key, a key of another certificate, the wrong kind of certificate, not Apple's, expired, no code signing usage |
| MACOS-TEAM-MISMATCH | the certificate's team is not APPLE_TEAM_ID |
| MACOS-NOTARY-KEY-FORMAT | the .p8 is not a PEM PKCS#8 EC P-256 private key |
| MACOS-NOTARY-CONFIG | the Key ID, Issuer ID or Team ID is malformed |
| MACOS-BUNDLE-METADATA | the bundle identifier (or the bundle's metadata) is invalid |

The later stages add MACOS-NOTARY-AUTH, MACOS-NOTARY-PERMISSION,
MACOS-NOTARY-ACCOUNT, MACOS-NOTARY-SERVICE, MACOS-NOTARY-TOOL (section 20),
MACOS-SIGN, MACOS-NOTARIZE, MACOS-STAPLE, MACOS-GATEKEEPER, MACOS-LAUNCH and
MACOS-PUBLISH. An example of a configuration with four mistakes, as the
preflight prints it (synthetic credentials, run on Linux):

    The macOS release's configuration has 4 problem(s); nothing was signed or sent to Apple:
    MACOS-NOTARY-CONFIG: APPLE_NOTARY_KEY_ID is the key's file name, not its Key ID: the Key ID is the part after AuthKey_ (ABCDE12345)
        Copy the Key ID from App Store Connect, Users and Access, Integrations, Team Keys (10 letters and digits, e.g. 2X9R4HXF34)
    MACOS-CERTIFICATE-IDENTITY: MACOS_CERTIFICATE_P12_BASE64 holds a certificate that is not issued by Apple's Developer ID Certification Authority (...)
        Use the Developer ID Application certificate Apple issued to your team
    MACOS-TEAM-MISMATCH: APPLE_TEAM_ID is OTHER98765, but the signing certificate 'Developer ID Application: Icy Tower Test (TEST123456)' is team TEST123456's
        Set APPLE_TEAM_ID to the team of the Developer ID certificate (its common name ends with it in parentheses), or export the identity of team OTHER98765
    MACOS-NOTARY-KEY-FORMAT: APPLE_NOTARY_KEY_BASE64 is an EC private key but is not the expected PKCS#8 PEM .p8 format (it is SEC1: BEGIN EC PRIVATE KEY).
        Supply the original AuthKey_<KEY_ID>.p8 downloaded from App Store Connect (Users and Access, Integrations, Team Keys), Base64-encoded once: base64 < AuthKey_KEYID.p8 | tr -d '\n'

Its cryptography is the `cryptography` package (50.0.2) with `cffi` and
`pycparser`, pinned by version and by the SHA-256 of every wheel PyPI
publishes for them (`macos/requirements.txt`), installed into a private
virtual environment with `pip --require-hashes --only-binary :all:`; the
structural checks (Base64, DER, the PKCS#12 MAC) are its own code.

## 14. Base64 handling

Strict, and explained when not: the standard alphabet only; line breaks
(LF, CRLF) accepted between lines -- the wrapped output of GNU base64 or
openssl -- and surrounding white space trimmed, nothing else; `=` only as
the last one or two characters; a length that is a multiple of 4;
canonical (decoding and encoding again gives the same text: no nonzero
padding bits); at least one byte. Python's decoder runs in strict mode, and
only after these checks: no permissive decoder ever discards a character.
Before decoding, a value that is PEM text itself, a shell command (`base64
< FILE | tr -d '\n'` pasted instead of its output) or a file path is named
as such. An invalid character is named by its kind and position, never
quoted: a '-' or '_' (URL-safe Base64's alphabet), white space inside a
line, a control or non-ASCII character. After decoding: PEM text in the
.p12's place (a certificate, a private key -- "perhaps the notarization
key"), text that is itself Base64 of the expected content (encoded twice),
a file name or path, any other text; in the .p8's place, binary data, a
DER PKCS#12 container, a DER certificate, Base64 again.

## 15. PKCS#12 parsing and the password

Before decryption, the decoded bytes are read as DER (BER: indefinite
lengths accepted): one SEQUENCE covering the whole input (trailing data is
refused), version 3, a ContentInfo of type data, the MacData. A truncated
or damaged container is MACOS-CREDENTIAL-FORMAT ("not a PKCS#12 container:
truncated"), never a password failure. Decryption is the cryptography
package's `load_pkcs12` (modern AES/PBKDF2 exports and Keychain Access's
legacy 3DES/SHA-1 ones both pass: `test_legacy_keychain_export_passes`).
When it fails, the container's own integrity check tells more: the
PKCS#12 MAC (RFC 7292, appendix B: the password's key derivation and the
HMAC over the authenticated safe, for SHA-1, SHA-224, SHA-256, SHA-384 and
SHA-512) is computed with the password:

* the MAC verifies -- the password is right, the contents are damaged (or
  encrypted in a way the package does not support): "passes its integrity
  check with MACOS_CERTIFICATE_PASSWORD (so the password is right), but its
  contents cannot be decrypted" (`test_damaged_contents_right_password`: a
  byte of the encrypted key changed and the MAC computed again);
* the MAC does not verify -- a wrong password and a damaged container are
  indistinguishable, and the diagnosis says so: "could not be decrypted
  with MACOS_CERTIFICATE_PASSWORD. The password may be wrong, or the
  exported file may be damaged." A password that ends with white space or a
  line break gets the hint that the copy may have taken one.

## 16. The Developer ID certificate and its private key

After decryption: a private key (a certificate alone is refused: "holds the
certificate ... but no private key: a certificate alone cannot sign"), a
certificate, the key's own (their public keys compared; a key with only
other certificates is refused, "does not match its certificate"); then,
every problem reported:

* **the kind**: the common name `Developer ID Application: ...` *and*
  Apple's marker extension 1.2.840.113635.100.6.1.13; a Developer ID
  Installer certificate (6.1.14: it signs packages), Apple Development
  (6.1.12), Apple Distribution, Mac App Store, iPhone ones are each named;
  a name without the extension is refused;
* **the usage**: the extended key usage includes code signing
  (1.3.6.1.5.5.7.3.3), the key usage digital signatures;
* **validity now**: not before its start, not after its end ("expired on
  DATE");
* **Apple's issuance**: issued by one of Apple's two Developer ID
  Certification Authorities -- G1 (until 2027-02-01) and G2 (until
  2031-09-17), both issued by Apple Root CA -- verified by signature, not by
  name: a certificate merely naming the authority as its issuer is "not a
  certificate Apple issued", a self-signed one "self-signed". The three
  certificates are Apple's public ones, committed in
  `examples/games/icy-tower/macos/apple-ca/` and pinned by SHA-256 in
  credentials.py (`AppleIncRootCertificate.cer` b0b1730e...f024,
  `DeveloperIDCA.cer` 7afc9d01...587f, `DeveloperIDG2CA.cer`
  f16cd3c5...df3a, downloaded from apple.com/certificateauthority); the
  release job also compares the root with the runner's own
  SystemRootCertificates keychain before trusting either (`release.py
  keychain`);
* **the team**: section 17.

A synthetic certificate passes every structural check only under test
trust anchors (`--trust-anchors DIR`, which the release refuses: section
21); under Apple's anchors the very same identity is refused
(`test_synthetic_identity_refused_under_apple_anchors`). After the
temporary keychain's import, macOS's own view must agree (section 24).

## 17. Team ID

The certificate's team is its subject's OU, its UID and the parenthesized
end of its common name, which must agree with each other ("gives more than
one team" otherwise) and with APPLE_TEAM_ID: MACOS-TEAM-MISMATCH names
both ("APPLE_TEAM_ID is OTHER98765, but the signing certificate
'Developer ID Application: ... (TEST123456)' is team TEST123456's"). After
signing, codesign's TeamIdentifier must be APPLE_TEAM_ID again (section 26)
and Gatekeeper's origin must name the team (section 30).

## 18. The notarization key (.p8)

After strict Base64: text (UTF-8, CRLF normalized to LF -- the one
normalization), exactly one PEM block and nothing around it, labelled
`PRIVATE KEY` (PKCS#8). Each mistake has its own message: literal `\n`
sequences instead of line breaks (an escaped copy, from JSON), a BEGIN
without its END (truncated), several blocks, text before or after it,
`EC PRIVATE KEY` ("an EC private key but ... not the expected PKCS#8 PEM
.p8 format"), `RSA PRIVATE KEY`, `PUBLIC KEY` ("a public key, not the
private key"), `ENCRYPTED PRIVATE KEY`, `CERTIFICATE`; a body that is not
valid Base64. The DER must be one PrivateKeyInfo covering the body exactly
(version, algorithm, key), read by the cryptography package as an EC
private key on P-256 (secp256r1: App Store Connect's ES256); RSA, Ed25519
("wrong key algorithm") and P-384 ("wrong curve") are refused. And its
layout must be App Store Connect's: a .p8 downloaded from App Store Connect
carries the curve inside its ECPrivateKey as well (the `[0]` parameters;
150 bytes, Base64 `MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg`), and a
key re-encoded without it (`openssl pkcs8 -topk8`, a crypto library's
PKCS#8: 138 bytes, `MIGHAgEA...`) -- the same key -- is refused: "is a P-256
key re-encoded without the curve inside its ECPrivateKey ... notarytool
fails without a message on a key that does not". That rule comes from the
runner (section 20): notarytool 1.0.0 (38) traps on such a key while it
makes its token, printing nothing. The decoded
file is written owner-only and normalized (its own lines, LF); no key
material is ever printed or written elsewhere.

## 19. Key ID, Issuer ID and bundle identifier

* APPLE_NOTARY_KEY_ID: 10 upper-case letters and digits (Apple's key
  identifiers); the file name `AuthKey_XXXXXXXXXX.p8` ("the Key ID is the
  part after AuthKey_"), quotes, white space, a URL and a UUID ("the Issuer
  ID's form") are named.
* APPLE_NOTARY_ISSUER_ID: a UUID, 8-4-4-4-12 hexadecimal digits, either
  case; braces, `urn:uuid:`, quotes, a line break and a Key ID-shaped
  value are named.
* APPLE_TEAM_ID: 10 upper-case letters and digits.
* MACOS_BUNDLE_ID: section 4's rule (no path separator, space, wildcard,
  shell substitution, quote, control character, underscore, single
  component or com.apple. identifier).

A .p8 carries no identifier: no local check can tell whether the Key ID and
the Issuer ID name the key. That association is Apple's to decide (section
20), and the preflight says so on success ("well-formed; Apple's service
decides they name this key").

## 20. Apple's validation of the notarization credentials

`release.py notary-auth` runs `xcrun notarytool store-credentials PROFILE
--key notary-key.p8 --key-id ID --issuer UUID --keychain TEMPORARY` --
without `--no-validate`: notarytool authenticates with Apple before it
stores the profile, into the temporary keychain, never the login one. It
runs after the local preflight and before the signature (the sign stage
refuses to run until it passed: mutant `remote-auth-skipped`). Its output is
kept (redacted) in the diagnostics and a failure is classified:

| Code | When | Remedy |
|---|---|---|
| MACOS-NOTARY-AUTH | HTTP 401, "Unable to authenticate", "Invalid credentials" | the three values must be one team key's; the key not revoked |
| MACOS-NOTARY-PERMISSION | HTTP 403 without an agreement | a key with Developer access |
| MACOS-NOTARY-ACCOUNT | a missing or expired agreement, an inactive membership | the Account Holder signs the agreements |
| MACOS-NOTARY-SERVICE | offline, DNS, a timeout, HTTP 5xx | retry; Apple's system status |
| MACOS-NOTARY-TOOL | anything else | notarytool's own words, kept |

A rejection after the key passed every local check is never reported as a
key-format problem (`test_notary_service_unreachable` checks the reverse
too: an outage is not MACOS-NOTARY-AUTH or MACOS-NOTARY-KEY-FORMAT).

`store-credentials` names no reason when Apple refuses: on the runner it
printed only "Validating your credentials... Credential validation failed.
Please verify your inputs." So when that is all it says, notary-auth asks
Apple once more with a read request, `notarytool history` with the same
key, and classifies that answer (a 401 is MACOS-NOTARY-AUTH, an outage
MACOS-NOTARY-SERVICE: `test_notary_unspecific_validation_failure_asks_apple_why`,
`..._offline`, mutant `unspecific-auth-unexplained`). A notarytool that
prints nothing is reported with its exit status.

**Executed against Apple's service, with a key Apple never issued** (the
dry run in ordinary CI). The runs established, in this order:

1. With the throwaway key in the cryptography package's PKCS#8 layout,
   notarytool 1.0.0 (38) trapped before sending anything: `store-credentials`
   exited -5 (SIGTRAP), printing nothing, and `notarytool history --verbose`
   ended at `Debug [JWT] Generating new JWT for key ID: DRYRUN0000.` with
   "Trace/BPT trap: 5" (status 133), whether standard input was /dev/null
   or the step's (runs 41217612371, 41219310772). No notarytool crash
   report was found in either DiagnosticReports directory 10 s later.
2. With the same kind of key laid out as App Store Connect's .p8 files are
   (the curve inside the ECPrivateKey; the only difference), notarytool
   made its token, sent the request, and Apple answered (run 41220843007):

       Debug [JWT] Generating new JWT for key ID: DRYRUN0000.
       Info [JWT] Caching newly generated JWT. key ID: DRYRUN0000, JWT: private<String>
       Debug [API] Received response status code: 401, message: unauthorized, URL: https://appstoreconnect.apple.com/notary/v2/submissions?, Correlation Key: 7EFCWTLGIQIYHNZYFV5RMORIKM
       Error: HTTP status code: 401. Unauthenticated. Ensure that all authentication arguments are correct.

   So Apple's service is reachable from the runner and refuses an unknown
   key as authentication, which the preflight cannot know (section 19).
   The fixtures now make App Store Connect's layout, and the preflight
   refuses the other (section 18): a real .p8 re-encoded by a tool would
   otherwise reach notarytool and fail with no message at all.
3. With both changes, in one run (41224177467): `store-credentials` printed
"Credential validation failed. Please verify your inputs.", notary-auth's
read request got Apple's answer and classified it --

       $ xcrun notarytool history --key .../notary-key.p8 --key-id DRYRUN0000 --issuer 7a12c2b0-... --output-format json
       MACOS-NOTARY-AUTH: The key is structurally valid, but Apple's notarization service rejected the configured Key ID / Issuer ID / private-key combination
       Error: HTTP status code: 401. Unauthenticated. Ensure that all authentication arguments are correct.

   -- and the control, the same key without the curve in its
   ECPrivateKey, asked the same way, trapped (`notarytool exited 133:
   ... Trace/BPT trap: 5`). The dry run requires MACOS-NOTARY-AUTH or
   MACOS-NOTARY-SERVICE here, and fails on anything else.

**Credential-blocked**: Apple's acceptance of the release's real key
(`notary-auth: Apple validated the Key ID, the Issuer ID and the key
together`).

## 21. Synthetic credential fixtures

`audit/macos-release/tools/fixtures.py` makes every credential the tests
need on the spot with the cryptography package -- nothing is committed: a
test root and a test intermediate named "Developer ID Certification
Authority, G2, Apple Inc." (so a leaf issued by it is Apple-shaped to every
check but who issued the intermediate), leaves of every kind (Developer ID
Application, Installer, Apple Development, Apple Distribution, without
Apple's marker, without code signing usage, expired, another team's,
self-signed), PKCS#12 containers of them (AES/PBKDF2 and Keychain Access's
legacy 3DES/SHA-1), a container with a key and an unrelated certificate, a
container damaged inside with its MAC recomputed, and App Store Connect-
shaped keys (EC P-256 PKCS#8) with their wrong relatives (SEC1, RSA, P-384,
Ed25519, public, encrypted). `fixtures.py dry-run DIR` writes the
throwaway identity ordinary CI rehearses the release with (section 25),
under an authority named as its own ("Icy Tower Dry Run Certification
Authority", with subject and authority key identifiers), a precaution so
that macOS's chain building cannot take Apple's real Developer ID
intermediate, which the system holds under the Apple-shaped name, for the
leaf's issuer. The chain is sound (`security verify-cert` with its root
anchored explicitly), but codesign signs only with an identity whose chain
reaches a root the system trusts, and a runner cannot trust a throwaway
root without a person: the dry run's signature is Environment-blocked
(section 25).

## 22. Credential negative tests

`audit/macos-release/tests/test_credentials.py` (63 tests) runs
credentials.py as the release runs it -- a process, the values in its
environment -- once per mistake. Each negative case asserts the exit status
1, the expected code, the offending variable's name after it, a remedy, no
16-character piece of any secret (nor any line of the key, nor the
password) in the output, and nothing written (no decoded file a later step
could go on with).

| Input defect | Rejection |
|---|---|
| missing .p12 secret | MACOS-CONFIG-MISSING "is not set" |
| empty .p12 secret | MACOS-CONFIG-MISSING "empty credential" |
| every value missing | seven MACOS-CONFIG-MISSING, one per name |
| invalid Base64 character | MACOS-CREDENTIAL-BASE64 "not valid Base64: a '#' at character 41" |
| invalid Base64 padding | MACOS-CREDENTIAL-BASE64 "invalid padding" |
| URL-safe alphabet | MACOS-CREDENTIAL-BASE64 "URL-safe" |
| a path instead of Base64 | MACOS-CREDENTIAL-BASE64 "looks like a file name or path" |
| the encoding command instead of its output | MACOS-CREDENTIAL-BASE64 "shell command" |
| raw PEM instead of its Base64 | MACOS-CREDENTIAL-BASE64 "PEM text itself" |
| Base64 of an ordinary text file | MACOS-CREDENTIAL-FORMAT "decoded to text" |
| Base64 of a path string | MACOS-CREDENTIAL-FORMAT "file name or path" |
| Base64 of a PEM certificate | MACOS-CREDENTIAL-FORMAT "decoded to a PEM certificate, not a binary PKCS#12 container" |
| double-encoded .p12 | MACOS-CREDENTIAL-FORMAT "encoded twice" |
| truncated .p12 | MACOS-CREDENTIAL-FORMAT "not a PKCS#12 container (.p12): truncated" |
| data after the .p12 | MACOS-CREDENTIAL-FORMAT "unexpected data" |
| incorrect .p12 password | MACOS-CERTIFICATE-DECRYPT "The password may be wrong, or the exported file may be damaged." |
| password with a trailing newline | MACOS-CERTIFICATE-DECRYPT, the hint about the line break |
| damaged contents, right password | MACOS-CERTIFICATE-DECRYPT "the password is right" |
| .p12 with only a certificate | MACOS-CERTIFICATE-IDENTITY "no private key" |
| .p12 with an unrelated key and certificate | MACOS-CERTIFICATE-IDENTITY "does not match its certificate" |
| expired certificate | MACOS-CERTIFICATE-IDENTITY "expired on" |
| Developer ID Installer | MACOS-CERTIFICATE-IDENTITY "Developer ID Installer certificate" |
| Apple Development | MACOS-CERTIFICATE-IDENTITY "Apple Development certificate" |
| Apple Distribution | MACOS-CERTIFICATE-IDENTITY "Apple Distribution certificate" |
| the name without Apple's marker | MACOS-CERTIFICATE-IDENTITY "without Apple's Developer ID Application extension" |
| no code signing usage | MACOS-CERTIFICATE-IDENTITY "does not include code signing" |
| self-signed | MACOS-CERTIFICATE-IDENTITY "not issued by Apple's Developer ID" |
| synthetic identity under Apple's anchors | MACOS-CERTIFICATE-IDENTITY "not issued by Apple's Developer ID Certification Authority" |
| Team ID mismatch | MACOS-TEAM-MISMATCH (APPLE_TEAM_ID) |
| another team's certificate | MACOS-TEAM-MISMATCH |
| missing .p8 | MACOS-CONFIG-MISSING |
| double-encoded .p8 | MACOS-NOTARY-KEY-FORMAT "encoded twice" |
| truncated PEM | MACOS-NOTARY-KEY-FORMAT "truncated PEM" |
| damaged PEM body | MACOS-NOTARY-KEY-FORMAT |
| literal `\n`, no real newlines | MACOS-NOTARY-KEY-FORMAT "literal \n sequences instead of line breaks" |
| public key instead of private key | MACOS-NOTARY-KEY-FORMAT "a public key, not the private key" |
| RSA key | MACOS-NOTARY-KEY-FORMAT "wrong key algorithm" |
| Ed25519 key | MACOS-NOTARY-KEY-FORMAT "wrong key algorithm" |
| P-384 key | MACOS-NOTARY-KEY-FORMAT "wrong curve" |
| SEC1 container | MACOS-NOTARY-KEY-FORMAT "not the expected PKCS#8 PEM .p8 format" |
| the same key re-encoded as PKCS#8 without the curve in its ECPrivateKey | MACOS-NOTARY-KEY-FORMAT "re-encoded without the curve inside its ECPrivateKey" |
| encrypted key | MACOS-NOTARY-KEY-FORMAT "encrypted private key" |
| extra PEM block | MACOS-NOTARY-KEY-FORMAT "2 PEM blocks" |
| extra text | MACOS-NOTARY-KEY-FORMAT "unexpected text" |
| a certificate in the .p8's place | MACOS-NOTARY-KEY-FORMAT "a certificate, not the notarization" |
| a .p12 in the .p8's place | MACOS-NOTARY-KEY-FORMAT "PKCS#12 container" |
| malformed Key ID; its file name; quoted | MACOS-NOTARY-CONFIG |
| malformed issuer UUID; in braces; with a line break | MACOS-NOTARY-CONFIG |
| malformed Team ID | MACOS-NOTARY-CONFIG |
| invalid bundle identifier (a space, a path, one component) | MACOS-BUNDLE-METADATA |
| three independent mistakes | all three reported |

Positive controls: the valid synthetic configuration passes every local
check under the test anchors (identity.json says `"anchors": "test"`, the
directory 0700, the files 0600, no password in it); Keychain Access's legacy
export, wrapped Base64 and a CRLF .p8 pass too; the committed Apple
certificates load, chain and match their pins. That the preflight runs
before any Apple tool is shown with recording stand-ins of Apple's tools:
after a failed preflight, every later stage refuses and the stand-ins
record no call of security, codesign, spctl or xcrun
(`test_failed_preflight_stops_everything`).

**Executed** on Linux (63 tests, OK) and on macOS (section 43).

## 23. Secret protection and the temporary keychain

* The secrets reach the release job's two steps that read them, through
  their `env`: the preflight (all seven values) and the keychain (the .p12
  password); never a script's text, a `with`, a job's `env`, another job,
  another workflow (`test_workflow.py`, section 36). No step that holds
  one traces commands.
* Decoded files go to `$RUNNER_TEMP/release/secret/` (0700; the files 0600);
  `release.py cleanup` -- an `if: always()` step -- deletes the temporary
  keychain, restores the user's keychain search list exactly as it was
  (recorded before), removes the decoded files, and verifies all three; the
  diagnostics upload lists public files by name only (state.json, the
  submission record, Apple's log, the authentication log, the sessions),
  never the work directory.
* The temporary keychain has a generated 32-byte password (Python's
  `secrets`), a 6-hour lock timeout, the identity imported with access for
  codesign and security only (`-T`), the partition list set for codesign
  (no prompt), and is added to the search list beside the user's keychains
  without becoming the default one.
* Output: every tool's output passes through release.py's redaction of
  every secret value (the three secrets, the generated keychain password)
  and any PEM private key block before it is printed or raised; a command
  line holding a secret is printed with it masked. GitHub's masking is a
  second layer, never the only one. Two limits, stated: `security
  create-keychain -p` and `security import -P` take their passwords as
  arguments, so they are visible to processes of the runner's user while
  those commands run (an ephemeral GitHub-hosted runner: nobody else's);
  and the keychain password lives in the owner-only secret directory for
  the job's duration.

## 24. Signing identity selection

The identity is chosen by the SHA-1 the preflight computed of the
certificate it checked, never "the first one": `release.py keychain` lists
the temporary keychain's code-signing identities and refuses unless there
is exactly one and it is that one ("refusing to choose one",
`test_keychain_refuses_ambiguous_identities`); in a release macOS's own
`security find-identity -v -p codesigning` must also call it valid (its
chain to the system's Apple Root CA, with Apple's intermediate imported
beside it), else MACOS-CERTIFICATE-IDENTITY with macOS's reason
(`test_keychain_refuses_an_untrusted_identity`). codesign is then given
that SHA-1 and the keychain explicitly.

## 25. Signing: Developer ID, hardened runtime, timestamp

    codesign --force --sign SHA1 --keychain TEMPORARY --options runtime --timestamp "Icy Tower.app"

-- the bundle, whose one executable codesign signs as its main executable;
no `--deep`, no entitlements file, extended attributes cleared first. The
same construction in every mode, so ordinary CI tests what a release signs:

| mode | identity | flags | where |
|---|---|---|---|
| adhoc | `-` | `--options runtime --timestamp=none` | ordinary CI: the bundle every LaunchServices case plays |
| dry-run | a throwaway test identity in the temporary keychain | `--options runtime --timestamp=none` (no throwaway signature is sent to Apple's timestamp service) | ordinary CI: the release's preflight, keychain, identity selection, Apple's credential check and cleanup, rehearsed; the signature itself is Environment-blocked (below) |
| release | the Developer ID Application identity | `--options runtime --timestamp` | the release job |

A release never falls back: its sign stage refuses to run without the
keychain and Apple's credential check (mutants `adhoc-fallback`,
`remote-auth-skipped`), and verification refuses an ad hoc signature
(`adhoc-signature-accepted`).

**Executed, ad hoc** (run 41212691891 and every acceptance run): `codesign
--force --sign - --options runtime --timestamp=none`, then `verify-signature:
valid (codesign --verify --deep --strict); ad hoc; team not set; identifier
org.botlish.examples.icy-tower.ci; flags adhoc,runtime; no timestamp`, CDHash
`1f23171577e9eff6a828260316426784dfd7e825`, `codesign -dvvv`: `Format=app
bundle with Mach-O thin (arm64)`, `Signature=adhoc`, `TeamIdentifier=not
set`. This is the bundle every LaunchServices case plays.

**Executed, the dry run's identity up to codesign** (runs 41201527696,
41212691891, 41217612371): the preflight under the throwaway anchors
(`preflight: Developer ID Application: Icy Tower Dry Run (DRYRUN0000), SHA-1
..., issued by Icy Tower Dry Run Certification Authority, team DRYRUN0000`),
the temporary keychain (created with a generated password, the identity
imported with `-T /usr/bin/codesign -T /usr/bin/security`, the authority's
two certificates beside it, the partition list set, the search list
extended), exactly that identity found by its SHA-1, its chain verified with
the root anchored explicitly (`security verify-cert ... -r root.cer -p
codeSign -L`: `...certificate verification successful.`) and, through the
keychains alone, `Cert Verify Result: CSSMERR_TP_NOT_TRUSTED`; then the
cleanup (the keychain deleted, the search list restored as it was, the
decoded files removed, each checked).

**Environment-blocked, the dry run's signature.** codesign refused the
throwaway identity (run 41201527696):

    MACOS-SIGN: codesign could not sign the bundle: .../Icy Tower.app: replacing existing signature
    Warning: unable to build chain to self-signed root for signer "Developer ID Application: Icy Tower Dry Run (DRYRUN0000)"
    .../Icy Tower.app: errSecInternalComponent

codesign signs only with an identity whose chain reaches a root the system
trusts, and on a GitHub-hosted runner no root can be made trusted without a
person: `security add-trusted-cert -d` waits for SecurityAgent's
authorization dialog (the step hung until cancelled, run 41205557290), and
the admin trust settings' authorization rule ("entitled" or
"authenticate-admin") cannot be lifted by root (`security authorizationdb
write`: `NO (-60005)`, run 41210576736, the rule unchanged). No job now
attempts either (test_workflow's `test_no_job_changes_a_trust_setting`).
The dry run classifies exactly that codesign refusal as ENVIRONMENT-BLOCKED
and any other failure as a failure. A release meets neither limit:
Apple's root is the system's.

**Credential-blocked, the Developer ID signature**: `--timestamp`, the
authority chain, the team, the secure timestamp (section 44).

## 26. Signature inspection and entitlements

`release.py verify-signature` (after signing, and again after stapling):
`codesign --verify --deep --strict --verbose=2` of the bundle and of its
executable; `codesign -dvvv`: the identifier the bundle's, the format
`app bundle with Mach-O thin (arm64)`, the CodeDirectory flags with
`runtime`; for a release the authority chain exactly "Developer ID
Application: ... (TEAM)", "Developer ID Certification Authority", "Apple
Root CA", TeamIdentifier APPLE_TEAM_ID, a `Timestamp=` (the secure
timestamp; a `Signed Time=` is not one), not ad hoc; for the dry run its own
identity; for ad hoc `Signature=adhoc`. `codesign -d --entitlements -
--xml`: none (the game needs no JIT, no library-validation exception, no
debugging entitlement, and none is added). The CDHash is recorded and must
be the same in every later stage; every stage that acts on the signed
bundle first verifies the seal again (the CDHash codesign prints is the
signature's, whatever happened to the files since: `seal-unchecked`).

## 27. Hardened-runtime graphical acceptance

Every LaunchServices case plays the bundle signed with `--options
runtime` (`flags adhoc,runtime`, verified before the session): the game,
its window, Metal, the keyboard, GC stress, every alert and the Gatekeeper
refusal ran under the hardened runtime (**Executed**, run 41212691891; section 34).
In a release the same cases run once more on the Developer ID-signed
bundle before it is submitted (`app-bundle`, `app-launch`,
`app-keyboard`, `app-relaunch`, `app-gc-stress`, `app-alert-renderer`,
`app-terminal-failure`), and `record
hardened-runtime` ties their result to the CDHash notarization checks
(`test_failed_acceptance_blocks_notarization`; mutant
`acceptance-not-required`). That run is **Credential-blocked**. SIP is
disabled on the runner (section 46): the runtime's enforcement there is not
proven equal to a user's Mac.

## 28. Notarization

`release.py notarize`: requires the verified signature and the
hardened-runtime acceptance of the same CDHash; verifies the seal; `ditto -c
-k --keepParent "Icy Tower.app" submission.zip`, `unzip -tq`; `xcrun
notarytool submit submission.zip --keychain-profile icy-tower-notary
--keychain TEMPORARY --output-format json` (no `--wait`: the submission ID
is recorded in `notary-submission.json` and printed at once); then
`notarytool wait ID --timeout` and `notarytool info ID --output-format
json` until a final status (Accepted, Invalid, Rejected) or the deadline
(90 minutes); then `notarytool log ID notary-log.json`. Structured output
only (JSON), never a human message. It requires: status Accepted, a log
that reads, the log's own status Accepted, no issue of severity error
(warnings are printed and counted), and the log's ticket contents holding
the bundle's CDHash (else "another artifact was notarized"). `altool` is not
used, nor `--force`.

A timeout is not a rejection: MACOS-NOTARIZE "has no final status after
... A timeout is not a rejection: the submission may still be accepted",
with the remedy to resume the submission rather than upload again:
`notarize --resume ID` waits for that submission. In the workflow, a manual
run on the tag with `resume_run` (the timed-out run) and
`resume_submission` (its ID): the release job checks that run built this
commit, downloads the bundle it signed (`icy-tower-macos-signed`),
`release.py adopt`s it after verifying its signature as this release's
(Developer ID, the team, the identifier), plays it again, and continues the
submission; the ticket's CDHash ties the two
(`test_notarization_timeout_then_resume`, `test_resume_adopts_the_signed_bundle`).

**Executed** against the stand-ins only (test_release.py: accepted,
Invalid, Rejected, another artifact's ticket, the log's issues, a timeout
then a resume, an adopted bundle); **Credential-blocked** against Apple's
service: no submission ID exists yet (section 44).

## 29. Stapling

`xcrun stapler staple` then `xcrun stapler validate`, both required. While
Apple publishes the ticket of an Accepted submission, stapler says "Record
not found" or "Could not find base64 encoded ticket": those (and network
failures) are retried, at most six times with a doubling wait (15 s to
120 s); anything else -- an invalid signature, an unsigned bundle -- fails
at once (`test_staple_fatal_is_not_retried`; stapler ends every failure
with "Error 65", which therefore decides nothing). The final ZIP is made
after stapling, of the stapled bundle (section 32).

## 30. Gatekeeper

`spctl --assess --type execute --verbose=4`: for a release, `accepted` and
`source=Notarized Developer ID` are required -- not a valid signature
alone, not a non-notarized Developer ID, not a successful extraction or a
direct run -- of the bundle whose stapled signature `verify-signature
--label stapled` checked against APPLE_TEAM_ID (the same CDHash: that is
what makes the accepted application the team's). An `origin=` line, which
spctl prints on some macOS versions and not on macOS 15, must name the
team's Developer ID Application certificate when it is there; its absence
is no refusal. The first release run required it and was refused
falsely (below; `test_gatekeeper_without_origin_line`, the mutant
`gatekeeper-origin-required`).
For the ad hoc bundle the same assessment must be a rejection (a control
that Gatekeeper decides on the runner). The runner's `spctl --status` is
recorded, and never changed (no `--master-disable`).

**Executed** (run 41212691891): the runner's `spctl --status` is `assessments enabled` (and
`csrutil status` `System Integrity Protection status: disabled.`,
recorded, not changed), and the ad hoc bundle's assessment is a rejection:

    $ spctl --assess --type execute --verbose=4 '.../out/app/Icy Tower.app'
    .../out/app/Icy Tower.app: rejected

So Gatekeeper decides on the runner, and a bundle that is merely signed is
refused.

**Executed** (run 42290405708, attempt 2, the first release run, macOS
15): the notarized, stapled bundle is accepted --

    $ spctl --assess --type execute --verbose=4 '.../release-app/Icy Tower.app'
    .../release-app/Icy Tower.app: accepted
    source=Notarized Developer ID

-- with no `origin=` line, which the stage then required: it reported
MACOS-GATEKEEPER on that acceptance, and the release stopped before its
tamper control, its ZIP and publication (section 44). The rule above is
the correction.

## 31. Quarantine and the downloaded artifact

`macos-session.py app --zip ZIP` (the `app-gatekeeper` case) treats the
release ZIP as a download: extracted with `ditto -x -k` into a fresh
directory, the quarantine attribute a browser's download carries written on
every file of the bundle (and the ZIP) with `xattr -w -r
com.apple.quarantine "0083;TIME;Safari;UUID"` -- a simulated quarantine, not
a browser's download path, and recorded as such -- the bundle assessed by
`spctl`, and opened through LaunchServices, whose first launch of a
quarantined application is Gatekeeper's decision, shown in
CoreServicesUIAgent's dialog: for the notarized release the dialog must
offer **Open** (Apple's "downloaded from the Internet" question), which the
harness presses through Accessibility; then the window, Right and Left move
the player, Escape quits. For the ad hoc bundle of ordinary CI the dialog
must refuse it and offer no Open, the harness presses Done, and the game
must never start. Quarantine is never removed to make a case pass.

**Executed** for the ad hoc download (run 41212691891, `app-gatekeeper`, 6 of 6):

    PASS the extracted bundle carries a quarantine attribute (0083;6ae60e63;Safari;25BD0CC8-161F-4C3E-A554-AD5E93C0155D)
    PASS Gatekeeper's assessments are enabled (assessments enabled)
    PASS spctl refuses it (not notarized): .../out/app-session/downloaded/Icy Tower.app: rejected
    PASS Gatekeeper's dialog refuses it: “Icy Tower” Not Opened / Apple could not verify “Icy Tower” is free of malware that may harm your Mac or compromise your privacy.
    PASS and offers no Open: ['Done', 'Move to Trash']
    PASS the game never started

That is the negative control: the quarantined first launch is
Gatekeeper's real decision on this runner, and it refuses an application
that is not notarized. The positive case -- the notarized release's dialog
offering Open, the game played after it (the same case with `--gatekeeper
notarized`, in the release job, App Translocation followed) -- is
**Credential-blocked**.

## 32. The ZIP: packaging and extraction

`release.py package`: after stapling, Gatekeeper and the tamper control,
of the notarized CDHash (verified again), `ditto -c -k --keepParent "Icy
Tower.app" icy-tower-macos-aarch64.zip` (ditto keeps permissions, the
signature's files and the stapled ticket), `unzip -tq`, then extracted
with `ditto -x -k` into a fresh directory where the bundle must equal the
original file for file (path, mode, SHA-256), the executable keep mode
0755, the signature verify strictly and the stapled ticket validate.
`SHA256SUMS` lists the ZIP and `provenance.json`. The submission ZIP is
never a release asset (`test_unstapled_submission_zip_never_published`;
the workflow's upload lists exactly the three packaged files).

**Executed** for the ad hoc bundle (run 41212691891): `ditto -c -k --keepParent`, `unzip
-tq`, `ditto -x -k` into a fresh directory, the tree compared file for file
(path, mode, SHA-256), the executable 0755, the signature verified strictly
there -- `package: .../icy-tower-macos-aarch64.zip (1483514 bytes)`. The
ad hoc ZIP is a test input only (the `app-gatekeeper` case's download):
`publishable` refused it at once, `MACOS-PUBLISH: an ad hoc build is never
published: only a release (Developer ID, notarized, stapled)`. The bundle's
CDHash is the same in every run built from the same executable
(`1f23171577e9eff6a828260316426784dfd7e825` in runs 41201527696 and 41212691891),
while the ZIP's SHA-256 differs run to run (ditto records the files' times):
the release claims a traceable artifact, never a byte-identical one. The
release's ZIP of the stapled, notarized bundle and its `stapler validate`
after extraction are **Credential-blocked**.

## 33. Tamper control

`release.py tamper`: two private copies (`ditto`) of the signed bundle,
one with a byte of the executable changed, one with a byte of a sealed
resource changed; `codesign --verify --deep --strict` must refuse both, the
copies are removed, and the original must still verify with its CDHash
unchanged. The released copy is never touched.

**Executed** on the ad hoc bundle (run 41212691891, as in every acceptance run):

    tamper: one byte of the copy's executable changed: codesign refuses it (In architecture: arm64)
    tamper: one byte of the copy's resource changed: codesign refuses it (.../resource/Icy Tower.app: a sealed resource is missing or invalid)

and the original still verified with its CDHash, `1f23171577e9eff6a828260316426784dfd7e825`.
For the Developer ID-signed bundle the same stage runs in the release job
(**Credential-blocked**).

## 34. The game: graphical and keyboard regression

The milestone keeps the earlier acceptance whole and adds the bundle's.
**Executed** (run 41212691891, macos-15):

* the original graphical acceptance (`macos-session.py --strict`, the
  executable run directly): env 2/2, cocoa 20/20, keyboard 14/14, restart
  9/9, close 3/3, focus 5/5, autopilot 6/6, trace-dummy 5/5, trace-cocoa
  7/7, gc-stress 3/3, worker 3/3, controls 4/4 -- "not EXECUTED: none";
* the bundle through LaunchServices (`macos-session.py app --strict`): env
  2/2, app-bundle 8/8, app-launch 15/15, app-keyboard 4/4 (Right +106 units,
  Left -98 units, Escape quits), app-relaunch 5/5 (closed by its close
  button), app-gc-stress 3/3 (the oracle's summary under GC stress), the
  five alerts 8/8 or 9/9, app-terminal-failure 4/4, app-gatekeeper 6/6 --
  "not EXECUTED: none";
* `tests/workload-icy-tower.test`'s macOS section (12 tests, the bundle's
  among them), the independent oracle (`oracle.py compare`), the SDL3
  binding's ABI (123 checks) and macos_app.bot's (26 checks, 0 failed), the
  staged application moved and rebuilt by Botlish.app alone.

The original session's `restart` case (the earlier milestone's, unchanged
here) failed intermittently, never a case of the bundle:

| run | where | its failure |
|---|---|---|
| an early run of this milestone | the session | the new game's player not centred in round 2 |
| 41205557290 | the session | unknown: the log was lost when the run, hung in another step, was cancelled |
| 41220843007 | the session | `R: the new game's player centred, its feet at view row 645 ...`; the summary `x=434` |
| 41228596109 | the mutant harness's baseline | the same check |
| 41235898277 | the session | the same check, feet at row 561; the summary `x=434` |
| 41240614881 | the mutant harness's baseline | the same check, feet at row 611 |

The check is of the player's x as well as its feet, and every failure
whose summary was read ends round 2 at `x=434`: round 2's player ran to the
right wall, as if Right were still held. The case holds Right until the
game is over, sends its key-up, waits at least 0.5 s and taps R; so the
game saw Right's release after R, or never. Whether a key-up is lost on
its way (the posted event, the window's key status) or the game's input
misses one, the runs do not show; this milestone changes neither the game
nor that case, and does not paper over it in the harness. It passed in
runs 41197431104, 41201527696, 41207619549, 41210576736, 41212691891,
41217612371, 41219310772, 41224177467, 41228596109 and 41240614881 (the
session), and in 41235898277's baseline: it is recorded as a pre-existing
intermittent failure, about one run in three of this milestone's, cause
not established. The Developer ID-signed application played under the
hardened runtime (section 27) is **Credential-blocked**.

## 35. Clean-environment independence

The application needs nothing the build left on the runner. **Executed**
(run 41212691891, and as part of every later acceptance run): while every
LaunchServices case of section 34 ran, the static SDL3 prefix, Botlish's
caches, Botlish.app (both copies) and its archive were moved away --

    hidden while the application runs: /Users/runner/Library/Caches/botlish-sdl3-static /Users/runner/.cache/botlish
    /Users/runner/work/_temp/Möved Äpp/Ícy Tower /Users/runner/work/_temp/Prögram Fïles/Botlish.app /Users/runner/work/botlish/botlish/dist

-- and LaunchServices started the process from launchd (parent pid 1,
working directory `/`, launchd's environment, not the job's shell), so no
DYLD variable, PATH entry, Tcl, Rust or Botlish of the job's reached it.
The bundle's executable is byte for byte the executable the earlier
milestone's "without its build" step runs under `env -i` with the same
directories hidden, which loads no SDL image (`DYLD_PRINT_LIBRARIES`), and
`otool -L` lists 22 system libraries (section 2). What this does not show:
a different Mac -- another user, no Xcode, macOS 11 to 14 (section 46).

## 36. GitHub Actions trust boundaries

`.github/workflows/icy-tower-macos.yml` (read by
`audit/macos-release/tests/test_workflow.py`, 24 tests, which parse it as
GitHub does):

* triggers: push (branches, and `icy-tower-macos-v*` tags), pull_request,
  workflow_dispatch; no `pull_request_target`, no `workflow_run`;
  workflow-level permissions `contents: read`;
* the **tested** job, on a release tag only: it reads runs (`contents:
  read`, `actions: read`), no environment, no secret; the game job, and so
  the release, waits for its finding every test of the tagged commit green
  (CI-RUNS.md), and the release job checks that finding too;
* the **game** job (every push and pull request from a fork; skipped for
  the repository's own pull requests, whose push already ran, and on a
  deferred release tag): no
  environment, no secret, no write permission; it builds and tests the
  game and the ad hoc bundle and rehearses the release with a throwaway
  identity;
* the **release** job: `needs: [game, tested]`, the game job's success and
  the tested job's green; only for
  `refs/tags/icy-tower-macos-v*` on push or workflow_dispatch -- never a
  pull request; `environment: macos-release` (whose deployment rule should
  admit those tags alone, and may require approval); permissions `contents:
  read` (and `actions: read`, to fetch a resumed run's signed bundle); the
  tag must be `vX.Y.Z`, name the run's commit, and be in main's history; it
  builds nothing from an earlier job but the executable the game job built
  and tested in this run, whose SHA-256 is the game job's output; secrets
  only in the two steps' env; its stages in order (preflight, identity,
  keychain, notary-auth, sign, verify, hardened-runtime acceptance,
  notarize, staple, Gatekeeper, package, final acceptance, publishable),
  the release assets uploaded only after `publishable`, cleanup always;
  never `--mode adhoc`, `--mode dry-run` or `--trust-anchors`;
* the **publish** job: `needs: [game, release]` and the release job's
  success, the only job with `contents: write`, no secret; it checks
  `SHA256SUMS`, the ZIP against the release job's output, the provenance's
  version and mode, refuses an existing release, and publishes;
* tag runs are never cancelled by a newer push.

Third-party actions: none; the workflow uses GitHub's own checkout, cache
and artifact actions at their major versions, as the repository's other
workflows do, and Apple's own tools (codesign, security, notarytool,
stapler, spctl) -- no notarization action.

## 37. Release publication

The publish job (section 36) is **Inspected** (test_workflow.py's
publish tests, the mutants `publish-before-release`,
`release-assets-unchecked`, `release-writes`) and has never run: no
release tag exists. **Credential-blocked**: no release, release URL or
published SHA-256 exists yet; the first release tag's run publishes
"Icy Tower X.Y.Z for macOS (Apple Silicon)" with the three assets.

## 38. SHA-256 and provenance

`provenance.json` (a release asset, listed in SHA256SUMS): the source
commit, the tag, the version, the bundle identifier, the Team ID, the SDL3
revision (the binding's manifest), the target (macos-aarch64, arm64), the
minimum macOS, the compiler's revision (`botlish -version`), Apple clang
and the SDK, the runner's macOS, the notarization submission ID, the
CDHash, the ZIP's SHA-256, the workflow run. No certificate, key or
password. A rebuild of a tag gives different signed bytes (the secure
timestamp, the signature, the ticket): the release claims reproducible
inputs and traceable provenance, never byte-identical signed artifacts.
The game's compilation is the same operation with or without credentials:
the release job compiles nothing; the executable is the game job's.

## 39. Mutation results

Two mutant sets, both in the repository's mutant format, each killed only
by the check that states the rule it breaks.

**The release pipeline** (`audit/macos-release/mutants.txt`, 74 mutants,
`audit/macos-release/tools/mutate.py`: each applied to a private copy of
macos/, package-macos.sh, the workflow and the tests, the tests its `!!`
line names run there):

| group | mutants |
|---|---|
| the credential preflight (14) | base64-permissive, base64-padding-unchecked, p8-double-encoding-accepted, p12-accepts-pem, no-private-key-accepted, certificate-type-unchecked, team-unchecked, apple-chain-unchecked, validity-unchecked, p8-algorithm-unchecked, p8-curve-unchecked, pkcs8-unchecked, p8-layout-unchecked, issuer-uuid-unchecked |
| the release's stages (36) | preflight-prints-a-secret, continue-after-failed-preflight, test-anchors-in-release, remote-auth-skipped, continue-after-auth-failure, unspecific-auth-unexplained, auth-misclassified, secrets-printed, secret-files-kept, adhoc-fallback, adhoc-signature-accepted, no-hardened-runtime, runtime-unchecked, no-timestamp, timestamp-unchecked, entitlements-unchecked, seal-unchecked, notarization-ignored, rejected-as-accepted, ticket-unchecked, timeout-as-failure, staple-retries-everything, stapling-omitted, gatekeeper-ignored, gatekeeper-origin-required, gatekeeper-origin-unchecked, gatekeeper-team-unanchored, tamper-not-tampered, zip-modes-unchecked, sums-unchecked, publish-before-final-launch, acceptance-not-required, identity-may-change, ambiguous-identity-chosen, adhoc-publishable, sign-remedy-misleads |
| the bundle's checks (6) | worker-startup-accepted, architecture-unchecked, dynamic-sdl-accepted, permissions-unchecked, executable-name-unchecked, package-replaces-on-failure |
| the workflow's trust boundary (18) | release-on-pull-requests, release-before-green, release-on-any-ref, pull-request-target, secret-in-game-job, secret-in-script, trace-with-secrets, secret-files-uploaded, release-adhoc, workflow-no-staple, workflow-no-notary-auth, publish-before-release, release-assets-unchecked, upload-submission-zip, release-writes, release-trusts-a-root, dry-run-trusts-its-root, dry-run-blocked-as-passed |

**Executed**: 74 of 74 killed on Linux (this checkout, 167 s, after the
Gatekeeper correction of section 30; 70 of 70 when the milestone landed); on macOS in
every acceptance run, as the game job's step (run 41207619549: 66 of 66,
the set before its last three; run 41212691891: 68 of 68, 180 s). Every
named test passes on the unmutated tree first (the harness's baseline), so
no mutant is killed by a test that fails anyway.

**The macOS integration** (`audit/icy-tower/macos-mutants.txt`, 31
mutants: the earlier milestone's 25, `darwin-io-silent` renamed
`app-io-silent` for the new entry, and six of the bundle's -- alert-never-
shown, alert-always, alert-before-write, alert-wrong-text,
launch-environment-dropped, agent-application -- each killed only by a
LaunchServices case failing with its own text, the `app:CASES` detector:
the mutant's executable built, bundled by the tree's package-macos.sh,
signed ad hoc by its release.py and launched through LaunchServices):

**Executed** (run 41228596109, a manual run with `mutants: true`): every
baseline detector but one held for the unmutated game (the bundle's five
app detectors among them), and 30 of 31 mutants were killed, each by its
own detector with its own text. The bundle's:

| mutant | killed by | its text |
|---|---|---|
| alert-never-shown | app:app-alert-renderer | an alert appears: None |
| alert-always | app:app-terminal-failure | no alert: a terminal run reports on standard error only |
| alert-before-write | app:app-alert-usage | the report is on standard error as well |
| alert-wrong-text | app:app-alert-video | the alert says what failed ('Icy Tower: SDL_Init failed: nosuch not available') |
| agent-application | app:app-launch | a regular (foreground) application, not an agent: policy 1 |
| app-io-silent | output | the usage was not printed |
| launch-environment-dropped | -- | FAILED FOR ANOTHER REASON: app-alert-renderer's "the alert says what failed" |

`launch-environment-dropped` was not killed by its rule's check: an alert
*was* on screen, of another run's text. The harness left it there:
`alert-always`'s detector, the terminal case, saw its mutant's alert and
failed as it should, but never dismissed it, and an alert is
UserNotificationCenter's, outliving the game. A harness defect, fixed:
every alert case and the terminal case dismiss any alert of the game before
they start and after they end (`dismiss_alerts`, recorded as
`stale_alerts`). And the one baseline that failed was `session:restart`,
the earlier milestone's intermittent case (section 34), so that run's kill
of `restart-ignored` is not conclusive (run 41164897163 of the earlier
milestone killed it with a passing baseline). The rerun with the fix:
**Executed** (run 41235898277, with the fix): every baseline detector held,
`session:restart` included; `launch-environment-dropped` killed by its own
check (`app:app-alert-renderer: an alert appears: None`), and 30 of 31 --
`agent-application` failed `app-launch` by "LaunchServices made it the
active application (frontmost: Finder)", while the policy check that had
killed it before passed: SDL3 sets the regular policy itself (section 4).
Both checks state the mutant's rule, and its `??` line now names both.
**Executed** (run 41240614881): 30 of 31 again, and `agent-application`
SURVIVED the launch checks: LaunchServices activated the agent and its
policy read regular. The launch is no deterministic observable of an
LSUIElement bundle; the Info.plist as macOS reads it is, and the mutant is
now killed there (section 4). The baseline of `session:restart` failed
(section 34).
**Executed** (run 41245041656): **31 of 31 mutants killed**, each by its
own detector with its own text -- `agent-application` by `app-bundle`: "a
regular application as macOS reads its Info.plist: no LSUIElement,
LSBackgroundOnly, NSUIElement or NSBGOnly (['LSUIElement'])",
`launch-environment-dropped` by `app-alert-renderer`: "an alert appears:
None" -- and the harness still exited 1, for a baseline: the unmutated
bundle's `app-bundle` case failed one check, "LaunchServices knows it for
org.botlish.examples.icy-tower.mutant (0 registered)". The harness builds
its bundles in the runner's temporary directory (`/var/folders/...`), and
LaunchServices' lookup by identifier found none there, while the same case
on the session's bundle in the workspace finds it every run (section 5).
It is no property the agent mutant's check reads (the Info.plist). Fixed:
the harness now builds its bundles under the home directory (a
`[pid]`-named directory removed with its work directory), and `mutate.tcl
-macos 1 NAME ...` checks only the named mutants' detectors' baselines
(the workflow's manual run passes them: `mutants_only`). **Executed** (run
41297189955, `mutants_only: agent-application`, every step of the job
green):

    baseline app:app-bundle      pass
    agent-application            killed by app:app-bundle (48 s): a regular application as macOS reads its Info.plist: no LSUIElement, LSBackgroundOnly, NSUIElement or NSBGOnly (['LSUIElement'])
    1 of 1 mutants killed

The same check that found no registration under `/var/folders` passed with
the bundle under the home directory, which agrees with LaunchServices not
indexing the temporary directory; one run each way shows the fix works,
not why. So every one of the 31 mutants was killed by its own detector
(41245041656), every baseline those detectors need held there except
`app-bundle`'s, and that one held with the fix (41297189955). No single
run since the fix has run all 31 with all their baselines. The
`session:restart` baseline held in 41245041656; the session's own
`restart` failed (section 34).

## 40. Negative artifact controls

Each a broken artifact the pipeline must refuse, with Apple's tools'
stand-ins or the bundle checks (`test_release.py`'s `BundleControls` and
`Stages`), and on macOS with the real tools where they apply:

| control | refused by | test |
|---|---|---|
| missing Info.plist | bundle.py | test_missing_info_plist |
| malformed Info.plist | bundle.py | test_malformed_info_plist |
| wrong CFBundleExecutable | bundle.py | test_wrong_executable_name |
| invalid bundle identifier | bundle.py | test_invalid_bundle_identifier |
| an agent application (LSUIElement) | bundle.py | test_agent_application_refused |
| missing executable | bundle.py | test_missing_executable |
| executable without execute permission | bundle.py | test_executable_without_execute_permission |
| wrong architecture (x86-64); a universal binary | bundle.py | test_wrong_architecture, test_universal_binary |
| worker-startup executable (no 512 MiB LC_MAIN) | bundle.py, package-macos.sh | test_worker_startup_executable, test_package_script_keeps_previous_bundle |
| dynamic SDL3 dependency; a non-system library | bundle.py | test_dynamic_sdl3, test_non_system_library |
| a later minimum macOS than the bundle's | bundle.py | test_later_minimum_than_bundle |
| a stray file; a symbolic link | bundle.py | test_stray_file, test_symbolic_link |
| missing hardened runtime | verify-signature | test_missing_hardened_runtime |
| missing secure timestamp | verify-signature | test_missing_secure_timestamp |
| an entitlement | verify-signature | test_entitlement_refused |
| not Apple's chain | verify-signature | test_not_apple_chain |
| ad hoc signature in release mode | sign, verify-signature, adopt | test_release_never_signs_ad_hoc, test_release_refuses_an_ad_hoc_signature, test_adopt_refuses_another_signature |
| signed bundle modified after signing | verify-signature, notarize | test_modified_after_signing |
| notarization not accepted (Invalid, Rejected); another artifact's ticket | notarize | test_notarization_invalid, test_notarization_rejected, test_notarization_ticket_of_another_artifact |
| stapling omitted | gatekeeper, package, publishable | test_stapling_required |
| final ZIP made before stapling | package | test_zip_before_stapling_refused |
| the unstapled submission ZIP published | publishable | test_unstapled_submission_zip_never_published |
| ZIP loses executable permissions | package | test_zip_losing_permissions_refused |
| damaged ZIP | publishable | test_damaged_zip_refused |
| SHA256SUMS mismatch | publishable | test_sha256sums_mismatch |
| final artifact not launched | publishable | test_final_artifact_must_be_launched |
| failed hardened-runtime acceptance | notarize | test_failed_acceptance_blocks_notarization |
| Gatekeeper's rejection | gatekeeper, package, publishable | test_gatekeeper_failure_blocks_publication |
| an ad hoc or dry-run build | publishable | test_adhoc_build_never_publishable, test_dry_run_never_publishable |

And on macOS with the real tools: the tamper control (section 33), the ad
hoc bundle's Gatekeeper rejection (section 30) and the quarantined ad hoc
download refused (section 31).

## 41. Linux and Windows regressions

No shared source changed: against main, the game's changed files are
main-macos.bot, macos_app.bot (new), macos/ (new) and package-macos.sh
(new); tower, hud, options, render, sdl, game, main and main-windows, the
committed Linux executable (`audit/icy-tower/artifacts/icy-tower`) and the
SDL call trace reference are as they were
(`workload-icy-tower-app-module-shared-sources-untouched` checks that no
shared module names macos_app, CoreFoundation or the alert variable).
**Executed**:

* Linux, `icy-tower` (run 41205692581, commit c0f3165, ubuntu-latest):
  `tests/workload-icy-tower.test` Total 43, Passed 26, Skipped 17 (the 11
  macOS and 6 Windows executable tests), Failed 0 -- the release tooling's
  tests among them (`workload-icy-tower-release-tooling`); build.sh; the
  oracle (every seed and length PASS); the rules' mutants, 26 of 26
  killed; the Xvfb session (keys, the autopilot at about 60 frames a
  second, the close request).
* Windows, `icy-tower (windows x86-64)` (runs 41205557419 at c0f3165 and
  41207619531 at e0231c4, windows-2025, MSVC): the MSVC binding generated,
  the game compiled and linked, the Windows executable's tests, headless
  and dummy-driver play, the signing dry run and its signed copies.

The repository's general `tests (macos arm64)` and `tests (windows
x86-64)` workflows started for each push and were cancelled by the next
push of this branch (each push supersedes the last); section 43 lists what
ran to completion.

## 42. Timing and sizes

**Executed** (run 41212691891, macos-15, the game job's steps by their
start and end times, and the job's own measurements):

| what | time |
|---|---:|
| the whole game job (queued 37 min before it started) | 15 min 18 s |
| build-macos.sh (SDL3 cached; the binding generated 2.6 s; compile and link 56.5 s; the link itself 0.78 s) | 60 s |
| the macOS test section (12 tests) | 130 s |
| the original graphical acceptance (12 cases) | 84 s |
| the release tooling's Python environment (pinned wheels, hash-checked) | 5 s |
| the release tooling's tests (61 + 60 + 23) and 68 mutants | 4 min 37 s (mutants 180 s) |
| Icy Tower.app: assembled, signed ad hoc, verified, tampered, assessed, packaged, the probe's bundle too | 3 s (assembly 1 s) |
| LaunchServices acceptance (13 cases, the build hidden) | 35 s |
| the dry run's preflight and keychain | under 1 s each |

| size | |
|---|---:|
| the executable as linked (in the bundle) | 3,846,184 bytes |
| stripped (for comparison; the bundle keeps the linked one) | 3,309,952 bytes |
| Icy Tower.app | 3,772 KiB |
| icy-tower-macos-aarch64.zip (ditto) | 1,483,514 bytes |

The release-only stages (the Developer ID signature with its timestamp,
notarization, stapling, the notarized download played) have no timing:
**Credential-blocked**. Each records its time in the release job's
`timings.txt` (a diagnostics artifact) when it runs.

## 43. macOS CI runs

`icy-tower (macos arm64)` on this milestone's branch, macos-15 (macOS
15.8.2, Xcode 16.4, Apple clang 17.0.0, SDK 15.5), in order. A cancelled
run was superseded by the next push unless said otherwise.

| run | commit | conclusion | what it established |
|---|---|---|---|
| 41195624753 | c2c55c2 | failure | the build and the original graphical acceptance passed; the macOS test section failed (the bundle test compared `shasum` lines, paths included: it compares digests since) and the release tooling's environment did not install (no pinned wheel for the image's Python: a pinned Python 3.13 since), so no bundle step ran |
| 41197431104 | 593e4f5 | failure | every LaunchServices case ran (sections 5, 6, 8: the evidence quoted there); two checks read the helper's Objective-C booleans wrongly (fixed); the Gatekeeper case's `open` waited for the dialog (run beside it since) |
| 41201527696 | 08ef6f4 | failure | every graphical and LaunchServices case EXECUTED; the dry run's signature refused by codesign ("unable to build chain to self-signed root", section 25) |
| 41205557290 | c0f3165 | cancelled | the dry run's `sudo security add-trusted-cert -d` waited for SecurityAgent's dialog (cancelled by hand); the original session failed (log lost) |
| 41207619549 | e0231c4 | failure | every case EXECUTED; the dry run's trust change, its output discarded, failed |
| 41210576736 | a6e32b0 | failure | every case EXECUTED, the LaunchServices cases with the build hidden; the admin trust settings' rule cannot be lifted (`NO (-60005)`), the rule unchanged |
| 41212691891 | 246076d | failure | every case EXECUTED (the acceptance evidence quoted in sections 4 to 42); 68 of 68 release mutants; notary-auth unclassified (notarytool printed nothing) |
| 41217612371 | e9d7c57 | failure | notarytool trapped (exit -5) on the throwaway key, in cryptography's layout |
| 41219310772 | fbc6b54 | failure | `--verbose`: the trap at "Generating new JWT", before any request; no crash report |
| 41220843007 | 7c78a33 | failure | the key in App Store Connect's layout: Apple's HTTP 401 (section 20); the original session's `restart` failed (section 34) |
| **41224177467** | **ba18cda** | **success** | every step: the build, the 12 tests, the oracle, the original graphical acceptance (12 of 12 EXECUTED), the release tooling's tests and 70 of 70 mutants, the ad hoc bundle, the LaunchServices acceptance (13 of 13 EXECUTED, the build hidden), the dry run (MACOS-NOTARY-AUTH from Apple; the control trapped; the signature ENVIRONMENT-BLOCKED; never publishable; cleanup verified) |
| 41228596109 | 6d244e2 | failure | `mutants: true` (manual): every step but the mutants green again; the integration's mutants 30 of 31 (a stale alert across cases); the `restart` baseline failed |
| 41235898277 | 223a0e2 | failure | the alert fix: `launch-environment-dropped` killed; `agent-application` failed the launch for another check (SDL3 sets the regular policy itself); the session's `restart` failed |
| 41240614881 | 0e90386 | failure | `agent-application` survived the launch checks (LaunchServices activated the agent); the `restart` baseline failed |
| 41245041656 | bf73c0d | failure | the Info.plist check: 31 of 31 mutants killed; the harness's `app-bundle` baseline failed its LaunchServices lookup in a temporary directory; the session's `restart` failed (section 39) |
| **41297189955** | **2bc2c92** | **success** | `mutants: true`, `mutants_only: agent-application` (manual): the harness's bundles under the home directory; `baseline app:app-bundle pass`, the agent mutant killed; every step of the job green, the original session's 12 cases and the 13 LaunchServices cases among them |
| 42290405708 | 1f076e1 (the tag icy-tower-macos-v1.0.0) | failure | the first release run (section 44): attempt 1 MACOS-CERTIFICATE-DECRYPT (the stored password did not open the stored .p12); attempt 2 signed with the Developer ID, played under the hardened runtime, notarized (Accepted), stapled, Gatekeeper `accepted` -- and refused by the stage for a missing `origin=` line (section 30) |

The general workflows started by the same pushes: `icy-tower (windows
x86-64)` passed at c0f3165 (41205557419), e0231c4 (41207619531), ba18cda
(41224177532) and bf73c0d, the last commit with code (41245041660); `icy-tower` (Linux) passed at c0f3165 (41205692581, a
manual run); `tests (macos arm64)` and `tests (windows x86-64)` were
cancelled by each next push; for bf73c0d, the last commit with code, they
were still queued when this report was written (runs 41245041652 and
41245041828): **pending**, never counted as passed. So is a manual run of
`icy-tower` (Linux) on the final commit (41250651088, queued). Since its
last passing run (c0f3165) the commits changed the release tooling, the
macOS harness and the documentation only -- nothing the Linux executable
is built from -- and the Linux-runnable tests of the final code passed in
this checkout: `workload-icy-tower-app-module`,
`-app-module-shared-sources-untouched` and `-release-tooling` (the release
tooling's 63 + 63 + 23 tests), and 70 of 70 release mutants.

## 44. The release run and its notarization

The first release tag, `icy-tower-macos-v1.0.0` on 1f076e1 (the newest
commit of main the release gate found green: docs/CI-RUNS.md, "The tagged
release"), ran as run 42290405708, in two attempts. Its `tested` job found
the commit green and its game job passed both times.

* **Attempt 1, Executed**: the preflight refused the configuration,
  MACOS-CERTIFICATE-DECRYPT -- the stored MACOS_CERTIFICATE_PASSWORD did
  not open the stored .p12 (its Base64 decoded to a well-formed PKCS#12
  container, its MAC did not verify) -- and the other five values passed.
  Nothing was signed or sent to Apple; the cleanup ran. The password was
  set again from the file it opens.
* **Attempt 2, Executed**, every stage through stapling:
  - the preflight (all seven values, under Apple's anchors), the identity
    (the first release), the temporary keychain, and Apple's validation of
    the notarization credentials;
  - the Developer ID signature: `Developer ID Application: ...
    (2QN7D8A7NA) < Developer ID Certification Authority < Apple Root CA`,
    team 2QN7D8A7NA, identifier com.avanticonic.botlishtower, flags
    `runtime`, a secure timestamp;
  - the Developer ID-signed application played under the hardened runtime
    (section 27: 8 of 8 cases EXECUTED);
  - notarization: submission `ca9336f5-c461-4f04-8c4b-9b7c37cefc60`,
    **Accepted** with 0 issues in its log, 24 s from upload to the result,
    its ticket holding the bundle's CDHash
    9cf56a4fcb3df07ee3e06102dd787966c4ba86c8;
  - stapling (`stapler validate` passes) and the stapled signature
    verified again;
  - Gatekeeper's verdict, `accepted`, `source=Notarized Developer ID`
    (section 30), which the stage then refused for its missing `origin=`
    line: the release stopped there, with no tamper control, ZIP, final
    launch or publication. The cleanup ran and was verified.

Sections 25 to 30 are therefore Executed by Apple's service and the
runner. Section 31 (the notarized download launched), the tamper control
of a notarized bundle (33), the release ZIP (32), its provenance (38) and
publication (37) are **not verified yet**: they need a release tag on a
green commit that holds the corrected Gatekeeper stage (a new version: a
tag names one commit, once).

## 45. Troubleshooting a release

* **A format error or an authentication error?** Everything the preflight
  reports (sections 13 to 19: MACOS-CONFIG-MISSING,
  MACOS-CREDENTIAL-BASE64, MACOS-CREDENTIAL-FORMAT,
  MACOS-CERTIFICATE-DECRYPT, MACOS-CERTIFICATE-IDENTITY, MACOS-TEAM-MISMATCH,
  MACOS-NOTARY-KEY-FORMAT, MACOS-NOTARY-CONFIG) is a value as stored in
  GitHub: fix that value. Only after every local check passed does Apple
  see the notarization key; MACOS-NOTARY-AUTH means Apple refused the
  combination of three structurally valid values (re-copy the Key ID and
  Issuer ID of the key whose .p8 you stored, or create a new key), and
  MACOS-NOTARY-SERVICE that Apple could not be reached (retry).
* **MACOS-CERTIFICATE-DECRYPT with a .p12 made by OpenSSL.** That route
  (a private key and a certificate signing request made with `openssl
  req`, the certificate downloaded from Apple, `openssl pkcs12 -export`)
  has two passwords: the private key's pass phrase and the .p12's export
  password. MACOS_CERTIFICATE_PASSWORD is the export password. Test it
  first: `openssl pkcs12 -in FILE.p12 -info -noout` asks for it and
  answers `Mac verify error` for any other.
* **Certificate identity errors.** "no private key": the export took the
  certificate without its key (select the identity under My Certificates).
  "does not match its certificate": a key of another request (export from
  the Mac that made the certificate's signing request). "Developer ID
  Installer" / "Apple Development" / "Apple Distribution": the wrong
  certificate was exported (a Developer ID *Application* one is needed).
  "not issued by Apple's Developer ID Certification Authority": a
  self-made certificate. "expired": a new certificate. "not a valid
  code-signing identity for macOS" after the import: macOS's own reason is
  quoted (an untrusted chain, a revoked certificate).
* **A notarization rejection** (MACOS-NOTARIZE, Invalid or Rejected): the
  error names each component Apple rejected with its message; the full log
  is `notary-log.json` in the run's `icy-tower-macos-release-diagnostics`
  artifact (each issue has Apple's documentation URL), and `xcrun notarytool
  log ID` shows it with your own credentials.
* **An interrupted notarization** (a timeout, or a cancelled job after the
  submission): the submission ID is in the job's log and in
  `notary-submission.json`; `xcrun notarytool info ID` tells its state.
  Resume it -- Actions, icy-tower (macos arm64), Run workflow, the same tag,
  `resume_run` the run's ID and `resume_submission` the ID -- rather than
  pushing the tag again (which signs and uploads a new copy).
* **Downloading and checking the released application.** Download
  `icy-tower-macos-aarch64.zip` and `SHA256SUMS` from the release; then

      shasum -a 256 -c SHA256SUMS
      unzip -q icy-tower-macos-aarch64.zip          # or double-click it in the Finder
      codesign --verify --deep --strict --verbose=2 "Icy Tower.app"
      codesign -dvv "Icy Tower.app"                 # Authority=Developer ID Application: ..., TeamIdentifier, Timestamp
      xcrun stapler validate "Icy Tower.app"         # The validate action worked!
      spctl --assess --type execute --verbose=4 "Icy Tower.app"   # accepted, source=Notarized Developer ID

  and open it from the Finder (move it to Applications first, if you
  like): macOS asks once whether to open an application downloaded from
  the Internet, noting Apple checked it for malicious software.
* **Supported systems.** macOS 11 (Big Sur) and later on Apple Silicon:
  LSMinimumSystemVersion and the executable's minimum are 11.0. Tested:
  macOS 15 (GitHub's macos-15 runners, Apple Silicon); macOS 11 to 14 were not run (section 46).

## 46. Remaining limitations

* **No real Developer ID release has run (Credential-blocked).** The
  Developer ID signature, its authority chain, team and secure timestamp,
  the Developer ID-signed application played, notarization, stapling,
  Gatekeeper's notarized verdict, the notarized download launched and the
  publication are implemented, tested against stand-ins of Apple's tools
  and rehearsed on the runner with a throwaway identity up to Apple's
  service (section 20), and not yet run by Apple (section 44).
* **The rehearsal cannot sign (Environment-blocked).** codesign refuses an
  identity whose root the system does not trust, and a GitHub-hosted
  runner cannot trust a throwaway root without a person (SecurityAgent's
  dialog; the admin trust settings' rule refuses root, `NO (-60005)`). So
  codesign with a keychain identity -- the release's own sign stage, its
  `--keychain` and SHA-1 selection on a real keychain -- has run against
  the stand-ins and as far as codesign's chain check on the runner, never
  to a signature; the first release is its first run.
* **notarytool's dependence on the key's layout** was observed with
  notarytool 1.0.0 (38) (Xcode 16.4). The preflight refuses the layout
  that version traps on; a later notarytool may accept it, and the rule
  can then be relaxed with the evidence of that version.
* **An intermittent failure of the earlier milestone's `restart` case**
  (section 34): its cause is not established.
* **The runner's SIP.** GitHub's macOS runners report System Integrity
  Protection disabled (MACOS-AARCH64-MILESTONE-9.md, section 41; the
  session records `csrutil status`), where the hardened runtime may be
  enforced less than on a user's Mac. The game needs no exception the
  hardened runtime refuses (no JIT, no unsigned executable memory, no
  third-party library, no DYLD variable), and every LaunchServices case ran
  with `flags=adhoc,runtime`, but a Mac with SIP enabled is where that is
  finally shown; no entitlement is added on speculation.
* **The quarantine is simulated**: `xattr -w -r com.apple.quarantine
  "0083;...;Safari;..."` on the extracted bundle, not a browser's download
  and Archive Utility's extraction (recorded as such in the case's facts).
  Gatekeeper's assessments are on on the runner (`spctl --status`:
  assessments enabled) and its first-launch decision is the real one.
* **Tested systems.** macOS 15 on GitHub's macos-15 Apple Silicon runners
  only. LSMinimumSystemVersion is 11.0 (the executable's minimum and the
  static SDL3's deployment target), and macOS 11 to 14 were not run; in
  particular whether a LaunchServices launch passes `-psn_` there was not
  observed (macOS 15 passes nothing, and the game does not accommodate one:
  a launch with one would show the usage alert). Apple Silicon only (no
  x86-64 or universal build); one display at scale 1 (no Retina display,
  several displays); English (the alert's OK).
* **The alert is the system's**: CFUserNotificationDisplayAlert's panel
  (the stop icon, "Icy Tower stopped", the report's line, OK), owned by
  UserNotificationCenter, not an NSAlert of the game's own with its icon --
  the price of an alert that needs no AppKit, SDL or window of the game's.
  The first diagnostic of a run is shown (a usage error's first line, not
  the usage).
* **A LaunchServices-launched process's exit status** is launchd's, not
  observable by the harness: a run's end is the process gone, its summary
  what `open --stdout` caught.
* **Passwords on command lines**: `security create-keychain -p` and
  `security import -P` take them as arguments (visible to the runner
  user's processes while those commands run; never printed).
* **The tag's protection is configuration**: the deployment rule of the
  macos-release environment and a tag ruleset (section 11) are the
  developer's to set; the workflow itself requires the tag's form, that it
  names the run's commit and that the commit is in main's history.
* **No icon, no DMG** (section 3).
* **Weak frameworks linked strongly** (UniformTypeIdentifiers,
  CoreHaptics: ICY-TOWER-MACOS-MILESTONE-1.md, section 12), which is why
  the minimum stays 11.0.

## 47. Reproduction commands

On an Apple Silicon Mac with Apple's developer tools, CMake, git, Tcl
9.0.1 (`tests/platform/setup-macos.sh`) and this checkout, after building
the game as ICY-TOWER-MACOS-MILESTONE-1.md, section 42, shows
(`out/icy-tower-macos-aarch64/icy-tower`, the probe `out/probe/icy-tower`):

```sh
python3 -m venv "$TMPDIR/venv" && "$TMPDIR/venv/bin/pip" install --require-hashes --only-binary :all: \
    -r audit/macos-release/requirements.txt
PY="$TMPDIR/venv/bin/python"
SDLSRC=$(tclsh9.0 tools/c-bindgen.tcl fetch sdl3 | tail -n 1)
# the bundle, signed ad hoc with the hardened runtime, checked, tampered with, refused by Gatekeeper, packaged
examples/games/icy-tower/package-macos.sh out/icy-tower-macos-aarch64/icy-tower out/app \
    --bundle-id org.botlish.examples.icy-tower.ci --version 0.0.0 --build 0.0.0 --sdl3-license "$SDLSRC/LICENSE.txt"
examples/games/icy-tower/package-macos.sh out/probe/icy-tower out/probe-app \
    --bundle-id org.botlish.examples.icy-tower.ci.probe --version 0.0.0 --build 0.0.0 --sdl3-license "$SDLSRC/LICENSE.txt"
rel() { "$PY" -I examples/games/icy-tower/macos/release.py "$@"; }
rel sign --work out/w --mode adhoc --app "out/app/Icy Tower.app"
rel verify-signature --work out/w --app "out/app/Icy Tower.app"
rel tamper --work out/w --app "out/app/Icy Tower.app"
rel gatekeeper --work out/w --app "out/app/Icy Tower.app" --expect refused
rel package --work out/w --app "out/app/Icy Tower.app" --out out/app-dist
rel sign --work out/wp --mode adhoc --app "out/probe-app/Icy Tower.app"
python3 -I audit/icy-tower/tools/app-abi-check.py "$TMPDIR/app-abi"
# LaunchServices: the launch, keys, relaunch, close, GC stress, every alert, the quarantined download
clang -fobjc-arc -framework AppKit -framework ApplicationServices -framework CoreServices \
    -o "$TMPDIR/macos-input" audit/icy-tower/tools/macos-input.m
python3 -I audit/icy-tower/tools/macos-session.py app --app "$PWD/out/app/Icy Tower.app" \
    --probe-app "$PWD/out/probe-app/Icy Tower.app" --zip "$PWD/out/app-dist/icy-tower-macos-aarch64.zip" \
    --gatekeeper refused --helper "$TMPDIR/macos-input" --out out/app-session --strict
# the release path rehearsed with a throwaway identity
"$PY" -I audit/macos-release/tools/fixtures.py dry-run "$TMPDIR/dry"
( set -a; . "$TMPDIR/dry/env"; set +a; ditto "out/app/Icy Tower.app" "$TMPDIR/dry/app/Icy Tower.app"
  rel preflight --work "$TMPDIR/dry/w" --mode dry-run --trust-anchors "$TMPDIR/dry/anchors"
  rel keychain --work "$TMPDIR/dry/w"
  security verify-cert -c "$TMPDIR/dry/leaf.cer" -c "$TMPDIR/dry/anchors/devid.cer" -r "$TMPDIR/dry/anchors/root.cer" -p codeSign -L
  rel notary-auth --work "$TMPDIR/dry/w"          # Apple refuses a key it never issued
  rel sign --work "$TMPDIR/dry/w" --app "$TMPDIR/dry/app/Icy Tower.app"   # MACOS-SIGN: no trusted root
  rel cleanup --work "$TMPDIR/dry/w" )
```

The macOS integration's mutants, all or some (`mutate.tcl -macos 1 ... NAME
...` checks only the named mutants' detectors' baselines; in CI a manual run
of icy-tower (macos arm64) with `mutants` and `mutants_only`, or a push
whose message holds `[ci-icy-tower-mutants]` for all of them):

```sh
tclsh9.0 audit/icy-tower/mutate.tcl -macos 1 -app "$APP" -binding out/sdl3-binding -prefix "$PREFIX" \
    -helper "$TMPDIR/macos-input" agent-application
```

On any host (Linux included), the release tooling's tests and mutants, and
the front-end check of the macOS entry:

```sh
python3 -m venv /tmp/venv && /tmp/venv/bin/pip install --require-hashes --only-binary :all: -r audit/macos-release/requirements.txt
/tmp/venv/bin/python -I audit/macos-release/tests/test_credentials.py
/tmp/venv/bin/python -I audit/macos-release/tests/test_release.py
/tmp/venv/bin/python -I audit/macos-release/tests/test_workflow.py
/tmp/venv/bin/python -I audit/macos-release/tools/mutate.py
BOTLISH_RELEASE_PYTHON=/tmp/venv/bin/python tclsh9.0 tests/workload-icy-tower.test -tmpdir "$(mktemp -d)" \
    -match 'workload-icy-tower-app-module* workload-icy-tower-release-tooling'
```

A release: sections 10 to 12 (the configuration once, then a tag).

## 48. Exact files changed

Added:

| File | What |
|---|---|
| `examples/games/icy-tower/macos_app.bot` | the macOS application's IO context: std::io::IO over std::darwin::write, the alert of a LaunchServices launch's first diagnostic |
| `examples/games/icy-tower/package-macos.sh` | Icy Tower.app from build-macos.sh's executable |
| `examples/games/icy-tower/macos/bundle.py` | the Info.plist (plistlib), the Mach-O and bundle checks |
| `examples/games/icy-tower/macos/credentials.py` | the credential preflight |
| `examples/games/icy-tower/macos/release.py` | the trust path's stages (keychain, notary-auth, sign, verify, record, notarize and resume, staple, gatekeeper, tamper, package, publishable, identity, adopt, cleanup) |
| `examples/games/icy-tower/macos/requirements.txt` | cryptography, cffi, pycparser, pinned by wheel hashes |
| `examples/games/icy-tower/macos/apple-ca/` | Apple Root CA and the Developer ID Certification Authorities G1 and G2 (public, pinned) |
| `audit/macos-release/tests/test_credentials.py`, `test_release.py`, `test_workflow.py` | the preflight's negative tests, the stages against stand-ins and the bundle's controls, the workflow's trust boundary |
| `audit/macos-release/tools/fixtures.py`, `machofake.py`, `stub-tool.py` | synthetic credentials, synthetic Mach-O files, recording stand-ins of Apple's tools |
| `audit/macos-release/tools/mutate.py`, `audit/macos-release/mutants.txt` | the release pipeline's 74 mutants and their harness |
| `audit/macos-release/requirements.txt` | the tests' environment (PyYAML beside the release's) |
| `audit/icy-tower/tools/app-abi-check.py` | macos_app.bot's C declarations against the SDK |
| `docs/ICY-TOWER-MACOS-APP-MILESTONE-1.md` | this report |

Changed:

| File | What |
|---|---|
| `examples/games/icy-tower/main-macos.bot` | installs `macos_app::create()` instead of `std::darwin::io::create()` |
| `audit/icy-tower/tools/macos-session.py` | the `app` mode (LaunchServices launches, the alert and Gatekeeper cases, App Translocation), SIP and Gatekeeper recorded |
| `audit/icy-tower/tools/macos-input.m` | `app-info` (with the agent and background-only keys NSBundle reads), `apps`, `ax-texts`, `ax-press` |
| `audit/icy-tower/context-refactor/tools/sdltrace.c` | `SDLTRACE_FAIL` fault injection (window creation, the Nth present); without it nothing changes |
| `audit/icy-tower/macos-mutate.tcl`, `audit/icy-tower/macos-mutants.txt` | the `app:CASES` detector (the mutant's executable bundled under the home directory, signed ad hoc, launched through LaunchServices); named mutants with only their detectors' baselines; `darwin-io-silent` renamed `app-io-silent` for the new entry; six bundle mutants |
| `tests/workload-icy-tower.test` | `workload-icy-tower-app-module`, `-app-module-shared-sources-untouched`, `-release-tooling`, `-macos-app-bundle` |
| `.github/workflows/icy-tower-macos.yml` | the game job's bundle, LaunchServices, dry-run, tooling and ABI steps; the tag trigger; the release and publish jobs |
| `.github/workflows/icy-tower.yml` | the release tooling's pinned Python for its tests |
| `AGENTS.md`, `docs/INDEX.md`, `docs/ICY-TOWER-MACOS-MILESTONE-1.md`, `docs/ICY-TOWER-VERTICAL-SLICE-1.md`, `docs/MAIN-THREAD-STARTUP-MILESTONE-1.md`, `docs/MACOS-AARCH64-MILESTONE-9.md`, `docs/MACOS-AARCH64-PORT-AUDIT.md` | cross-references and the rules |

No file of `core/`, `hir/`, `surface/`, `compiler/`, `native/`, `stdlib/`,
`tools/` or the game's shared modules (tower, hud, options, render, sdl,
game, main, main-windows) changed: no compiler, runtime, FFI or standard
library change was needed.
