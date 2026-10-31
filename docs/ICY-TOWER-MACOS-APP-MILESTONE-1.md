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

RESULT-PLACEHOLDER

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
application), and the `agent-application` mutant is killed by the
LaunchServices launch's check that the process is a regular application.

`bundle.py` validates before writing and after: the identifier
(reverse-DNS, at least two components, letters, digits, hyphens and
periods -- Apple's rule for CFBundleIdentifier, no underscore, no
com.apple.), both versions (one to three period-separated integers),
every required key with its exact value and type, the identifier, version
and build the release asked for, no forbidden key. A property list that
does not parse, a missing one, a wrong CFBundleExecutable or a missing,
non-executable or wrong-architecture executable are refused (section 40).

BUNDLE-EVIDENCE-PLACEHOLDER

## 5. LaunchServices recognition

LAUNCHSERVICES-PLACEHOLDER

## 6. Finder-style startup

FINDER-PLACEHOLDER

## 7. Activation and focus

ACTIVATION-PLACEHOLDER

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

ALERT-EVIDENCE-PLACEHOLDER

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

The push runs `icy-tower (macos arm64)` for the tag: the game job (the build
and every test, as on any push; no credential), then the release job in the
`macos-release` environment (waiting for its approval when one is
required), then the publish job. A manual run (Actions, icy-tower (macos
arm64), Run workflow, "Use workflow from" the tag) does the same; a manual
run on a branch runs no release job. The release job refuses a tag that is
not `icy-tower-macos-vX.Y.Z`, one that does not name the run's commit, and
a commit that is not in main's history. The release appears under Releases
as "Icy Tower X.Y.Z for macOS (Apple Silicon)", with
`icy-tower-macos-aarch64.zip`, `SHA256SUMS` and `provenance.json`; a release
of the tag that exists already is never replaced (tag a new version).

RELEASE-STEPS-PLACEHOLDER

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
("wrong key algorithm") and P-384 ("wrong curve") are refused. The decoded
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

NOTARY-AUTH-EVIDENCE-PLACEHOLDER

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
throwaway identity ordinary CI rehearses the release with (section 25).

## 22. Credential negative tests

`audit/macos-release/tests/test_credentials.py` (61 tests) runs
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

**Executed** on Linux (61 tests, OK) and on macOS (section 43).

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
| dry-run | a throwaway test identity in the temporary keychain | `--options runtime --timestamp=none` (Apple's time stamp service signs only Apple-issued identities) | ordinary CI: the release's keychain, selection, signing and cleanup, rehearsed |
| release | the Developer ID Application identity | `--options runtime --timestamp` | the release job |

A release never falls back: its sign stage refuses to run without the
keychain and Apple's credential check (mutants `adhoc-fallback`,
`remote-auth-skipped`), and verification refuses an ad hoc signature
(`adhoc-signature-accepted`).

SIGN-EVIDENCE-PLACEHOLDER

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

HARDENED-PLACEHOLDER

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

NOTARIZE-EVIDENCE-PLACEHOLDER

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

`spctl --assess --type execute --verbose=4`: for a release, `accepted`,
`source=Notarized Developer ID` and `origin=Developer ID Application: ...
(TEAM)` are all required -- not a valid signature alone, not a
non-notarized Developer ID, not a successful extraction or a direct run.
For the ad hoc bundle the same assessment must be a rejection (a control
that Gatekeeper decides on the runner). The runner's `spctl --status` is
recorded, and never changed (no `--master-disable`).

GATEKEEPER-EVIDENCE-PLACEHOLDER

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

QUARANTINE-EVIDENCE-PLACEHOLDER

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

ZIP-EVIDENCE-PLACEHOLDER

## 33. Tamper control

`release.py tamper`: two private copies (`ditto`) of the signed bundle,
one with a byte of the executable changed, one with a byte of a sealed
resource changed; `codesign --verify --deep --strict` must refuse both, the
copies are removed, and the original must still verify with its CDHash
unchanged. The released copy is never touched.

TAMPER-EVIDENCE-PLACEHOLDER

## 34. The game: graphical and keyboard regression

GAME-REGRESSION-PLACEHOLDER

## 35. Clean-environment independence

CLEAN-PLACEHOLDER

## 36. GitHub Actions trust boundaries

`.github/workflows/icy-tower-macos.yml` (read by
`audit/macos-release/tests/test_workflow.py`, 21 tests, which parse it as
GitHub does):

* triggers: push (branches, and `icy-tower-macos-v*` tags), pull_request,
  workflow_dispatch; no `pull_request_target`, no `workflow_run`;
  workflow-level permissions `contents: read`;
* the **game** job (every push and pull request from a fork; skipped for
  the repository's own pull requests, whose push already ran): no
  environment, no secret, no write permission; it builds and tests the
  game and the ad hoc bundle and rehearses the release with a throwaway
  identity;
* the **release** job: `needs: game` and the game job's success; only for
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

PUBLICATION-PLACEHOLDER

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

MUTATION-PLACEHOLDER

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

LINUX-WINDOWS-PLACEHOLDER

## 42. Timing and sizes

TIMING-PLACEHOLDER

## 43. macOS CI runs

RUNS-PLACEHOLDER

## 44. The release run and its notarization

**Credential-blocked.** No release has run: the seven values are not
configured in GitHub yet. Sections 25 (the Developer ID signature), 26
(its authority chain, team and timestamp), 27 (the Developer ID-signed
application played), 28 (notarization), 29 (stapling), 30 (Gatekeeper's
notarized verdict), 31 (the notarized download launched), 37 (publication)
and the release's half of 32 and 38 are therefore **not verified**: the
code paths are exercised up to Apple's service by the dry run (section 25)
and in full against the stand-ins (section 40), never by Apple. The first
release tag pushed after the configuration (sections 10 to 12) runs them;
its run ID and notarization submission ID belong here.

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
  TESTED-VERSIONS-PLACEHOLDER.

## 46. Remaining limitations

LIMITATIONS-PLACEHOLDER

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
  rel sign --work "$TMPDIR/dry/w" --app "$TMPDIR/dry/app/Icy Tower.app"
  rel verify-signature --work "$TMPDIR/dry/w" --app "$TMPDIR/dry/app/Icy Tower.app"
  rel notary-auth --work "$TMPDIR/dry/w"          # Apple refuses the key it never issued: MACOS-NOTARY-AUTH
  rel cleanup --work "$TMPDIR/dry/w" )
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
| `audit/macos-release/tools/mutate.py`, `audit/macos-release/mutants.txt` | the release pipeline's 64 mutants and their harness |
| `audit/macos-release/requirements.txt` | the tests' environment (PyYAML beside the release's) |
| `audit/icy-tower/tools/app-abi-check.py` | macos_app.bot's C declarations against the SDK |
| `docs/ICY-TOWER-MACOS-APP-MILESTONE-1.md` | this report |

Changed:

| File | What |
|---|---|
| `examples/games/icy-tower/main-macos.bot` | installs `macos_app::create()` instead of `std::darwin::io::create()` |
| `audit/icy-tower/tools/macos-session.py` | the `app` mode (LaunchServices launches, the alert and Gatekeeper cases, App Translocation), SIP and Gatekeeper recorded |
| `audit/icy-tower/tools/macos-input.m` | `app-info`, `apps`, `ax-texts`, `ax-press` |
| `audit/icy-tower/context-refactor/tools/sdltrace.c` | `SDLTRACE_FAIL` fault injection (window creation, the Nth present); without it nothing changes |
| `audit/icy-tower/macos-mutate.tcl`, `audit/icy-tower/macos-mutants.txt` | the `app:CASES` detector (the mutant's executable bundled, signed ad hoc, launched through LaunchServices); `darwin-io-silent` renamed `app-io-silent` for the new entry; six bundle mutants |
| `tests/workload-icy-tower.test` | `workload-icy-tower-app-module`, `-app-module-shared-sources-untouched`, `-release-tooling`, `-macos-app-bundle` |
| `.github/workflows/icy-tower-macos.yml` | the game job's bundle, LaunchServices, dry-run, tooling and ABI steps; the tag trigger; the release and publish jobs |
| `.github/workflows/icy-tower.yml` | the release tooling's pinned Python for its tests |
| `AGENTS.md`, `docs/INDEX.md`, `docs/ICY-TOWER-MACOS-MILESTONE-1.md`, `docs/ICY-TOWER-VERTICAL-SLICE-1.md`, `docs/MAIN-THREAD-STARTUP-MILESTONE-1.md`, `docs/MACOS-AARCH64-MILESTONE-9.md`, `docs/MACOS-AARCH64-PORT-AUDIT.md` | cross-references and the rules |

No file of `core/`, `hir/`, `surface/`, `compiler/`, `native/`, `stdlib/`,
`tools/` or the game's shared modules (tower, hud, options, render, sdl,
game, main, main-windows) changed: no compiler, runtime, FFI or standard
library change was needed.
