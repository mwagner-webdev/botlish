#!/usr/bin/env python3
"""bundle.py -- Botlish.app's release description: what the shared release
tooling (tools/macos-release/release.py) needs to know of the compiler's
application (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, "Signing order").

    python3 -I single/macos/bundle.py check APP

Botlish.app is single/macos/build.sh's bundle: the launcher, the native
driver (built without its JIT), Tcl.framework, the compiler archive and the
runtime archive (MACOS-AARCH64-MILESTONE-9.md, "Exact bundle layout"). Its
bundle identifier is fixed here, never a GitHub variable: the application
is the compiler's, io.github.mwagner-webdev.botlish, distinct from Icy
Tower's. It has three signing units, signed inner first by
single/macos/sign.sh -- the release's and the ad hoc build's one statement
of the order -- each with the hardened runtime and no entitlement:

    Contents/Frameworks/Tcl.framework/Versions/9.0   com.tcltk.tcllibrary
    Contents/MacOS/botlish-native                    io.github.mwagner-webdev.botlish.native
    the application (its main executable, the seal)  io.github.mwagner-webdev.botlish

`check` validates the layout as single/macos/verify.sh's layout group does
(pure Python: the release's tests run it on any host); a refusal is one
line, `MACOS-BUNDLE-LAYOUT: ...` or `MACOS-BUNDLE-METADATA: ...`.
"""
import os
import plistlib
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "macos-release"))
from bundleid import IDENTIFIER, Refused, check_identifier, refuse  # noqa: E402,F401

NAME = "Botlish"
EXECUTABLE = "botlish"
DRIVER = "botlish-native"
BUNDLE_ID = "io.github.mwagner-webdev.botlish"
TCL_VERSION = "9.0"
# The sealed resources; the tamper control changes the first.
RESOURCES = ("botlish.zip", "libbotlish_runtime.a")
# The nested signing units, inner first, each with its identifier.
COMPONENTS = (
    ("Contents/Frameworks/Tcl.framework/Versions/%s" % TCL_VERSION, "com.tcltk.tcllibrary"),
    ("Contents/MacOS/%s" % DRIVER, BUNDLE_ID + ".native"),
)
# The release's names: its ZIP (the CI artifact's too), notarytool profile,
# temporary keychain and temporary directories.
ZIP = "botlish-macos-aarch64.zip"
PROFILE = "botlish-notary"
KEYCHAIN = "botlish-signing.keychain-db"
SLUG = "botlish"
SIGN = os.path.join(HERE, "sign.sh")


def listing(path):
    return sorted(os.listdir(path))


def check_bundle(app, bundle_id=None, version=None, build=None):
    """Botlish.app's layout and Info.plist, as single/macos/build.sh makes them: the property list's dictionary."""
    c = os.path.join(app, "Contents")
    if not os.path.isdir(c):
        refuse("MACOS-BUNDLE-LAYOUT", "%s is no application bundle (no Contents)" % app)
    expected = {
        c: ["Frameworks", "Info.plist", "MacOS", "Resources", "_CodeSignature"],
        os.path.join(c, "MacOS"): [EXECUTABLE, DRIVER],
        os.path.join(c, "Resources"): list(RESOURCES),
        os.path.join(c, "Frameworks"): ["Tcl.framework"],
    }
    for directory, names in expected.items():
        if not os.path.isdir(directory):
            refuse("MACOS-BUNDLE-LAYOUT", "%s is missing" % os.path.relpath(directory, app))
        # (An unsigned bundle has no _CodeSignature yet; a stapled one holds
        # its ticket, Contents/CodeResources.)
        got = [n for n in listing(directory) if not (directory == c and n == "CodeResources")]
        want = sorted(names)
        if got != want and got != [n for n in want if n != "_CodeSignature"]:
            refuse("MACOS-BUNDLE-LAYOUT", "%s holds %s, not %s" % (os.path.relpath(directory, app), ", ".join(got), ", ".join(want)))
    fw = os.path.join(c, "Frameworks", "Tcl.framework")
    for path in ("Versions/%s/Tcl" % TCL_VERSION, "Versions/%s/Resources/Info.plist" % TCL_VERSION):
        if not os.path.isfile(os.path.join(fw, path)) or os.path.islink(os.path.join(fw, path)):
            refuse("MACOS-BUNDLE-LAYOUT", "Tcl.framework has no file %s" % path)
    for name in (EXECUTABLE, DRIVER):
        p = os.path.join(c, "MacOS", name)
        if not os.path.isfile(p) or not os.access(p, os.X_OK):
            refuse("MACOS-BUNDLE-LAYOUT", "Contents/MacOS/%s is not an executable file" % name)
    try:
        with open(os.path.join(c, "Info.plist"), "rb") as f:
            d = plistlib.load(f)
    except Exception as e:
        refuse("MACOS-BUNDLE-METADATA", "Contents/Info.plist does not parse: %s" % e)
    if d.get("CFBundleExecutable") != EXECUTABLE:
        refuse("MACOS-BUNDLE-METADATA", "Info.plist's CFBundleExecutable is %r, not %s" % (d.get("CFBundleExecutable"), EXECUTABLE))
    if d.get("CFBundleIdentifier") != (bundle_id or BUNDLE_ID):
        refuse("MACOS-BUNDLE-METADATA", "Info.plist's CFBundleIdentifier is %r, not the compiler's %s"
               % (d.get("CFBundleIdentifier"), bundle_id or BUNDLE_ID))
    if d.get("CFBundlePackageType") != "APPL":
        refuse("MACOS-BUNDLE-METADATA", "Info.plist's CFBundlePackageType is %r, not APPL" % d.get("CFBundlePackageType"))
    if version is not None and d.get("CFBundleShortVersionString") != version:
        refuse("MACOS-BUNDLE-METADATA", "Info.plist's CFBundleShortVersionString is %r, not the release's %s"
               % (d.get("CFBundleShortVersionString"), version))
    return d


def sign(app, identity, keychain_args, timestamp, run):
    """Signs APP's units in order with IDENTITY (single/macos/sign.sh): the release's sign stage."""
    tclsh = os.environ.get("BOTLISH_RELEASE_TCLSH") or "tclsh9.0"
    command = ["bash", SIGN, "--identity", identity] + keychain_args + (["--timestamp"] if timestamp == "--timestamp" else []) \
        + ["--tclsh", tclsh, app]
    run(command, timeout=1800)


def main(argv):
    if len(argv) == 2 and argv[0] == "check":
        try:
            d = check_bundle(os.path.abspath(argv[1]))
        except Refused as r:
            print(str(r), file=sys.stderr)
            return 1
        print("%s: %s %s" % (argv[1], d["CFBundleIdentifier"], d.get("CFBundleShortVersionString")))
        return 0
    print("usage: python3 -I single/macos/bundle.py check APP", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
