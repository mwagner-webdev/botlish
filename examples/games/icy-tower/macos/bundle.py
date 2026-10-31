#!/usr/bin/env python3
"""bundle.py -- Icy Tower.app's metadata and structure
(ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Application metadata" and "Bundle
construction").

    python3 -I bundle.py plist --bundle-id ID --version V --build B OUT
    python3 -I bundle.py check-executable EXE
    python3 -I bundle.py check APP [--bundle-id ID] [--version V] [--build B]
    python3 -I bundle.py identity APP

`plist` writes the Info.plist (plistlib: a structured writer, never text
pasted into XML) after validating every value it is given; `check-executable`
reads the game's Mach-O itself (its header and load commands: thin arm64,
an executable, LC_MAIN's 512 MiB stack -- the main-thread startup -- a
LC_BUILD_VERSION for macOS whose minimum is the bundle's, every dynamic
library a system one and none SDL3's); `check` validates an assembled
bundle as a whole (the layout, the property list, the executable it names,
its permissions, the resources, nothing else) and `identity` prints the
bundle's identifier, versions and executable as JSON.

Every refusal is one line, `CODE: what is wrong` with the remedy, CODE one
of the release's stable diagnostic codes (MACOS-BUNDLE-METADATA,
MACOS-BUNDLE-EXECUTABLE, MACOS-BUNDLE-LAYOUT), and exit status 1. Pure
Python: the checks run on any host, so the bundle's negative controls run
on Linux too; on macOS, package-macos.sh also asks Apple's own tools
(plutil, lipo, otool) and requires them to agree.
"""
import json
import os
import plistlib
import re
import stat
import struct
import sys

EXECUTABLE = "icy-tower"
NAME = "Icy Tower"
MINIMUM_SYSTEM = "11.0"
CATEGORY = "public.app-category.arcade-games"
# LaunchServices adds these to the environment of the process it launches
# (macos_app.bot reads ICY_TOWER_ERROR_ALERTS: the first diagnostic of a run
# shown in an alert). A terminal run of the Mach-O has none of them.
LAUNCH_ENVIRONMENT = {"ICY_TOWER_ERROR_ALERTS": "1"}
# The main thread's stack, which -native-startup main-thread reserves
# (MAIN-THREAD-STARTUP-MILESTONE-1.md): LC_MAIN's stacksize.
MAIN_STACK = 536870912
RESOURCES = ("LICENSE-Botlish.txt", "LICENSE-SDL3.txt")


class Refused(Exception):
    def __init__(self, code, text):
        super().__init__("%s: %s" % (code, text))
        self.code = code


def refuse(code, text):
    raise Refused(code, text)


# ---------------------------------------------------------------------------
# Values

# CFBundleIdentifier: "only alphanumeric characters (A-Z, a-z, 0-9), hyphens
# (-) and periods (.)", reverse-DNS: at least two non-empty components.
IDENTIFIER = re.compile(r"[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+")
# CFBundleShortVersionString and CFBundleVersion: one to three
# period-separated non-negative integers (Apple: "can only contain numeric
# characters (0-9) and periods").
VERSION = re.compile(r"(0|[1-9][0-9]{0,8})(\.(0|[1-9][0-9]{0,8})){0,2}")


def check_identifier(value, name="MACOS_BUNDLE_ID"):
    """The bundle identifier VALUE, or a refusal naming where it came from (NAME)."""
    if value is None or value == "":
        refuse("MACOS-BUNDLE-METADATA", "%s is empty: set it to the game's stable reverse-DNS bundle identifier "
               "(for example com.example.icy-tower)" % name)
    if value != value.strip():
        refuse("MACOS-BUNDLE-METADATA", "%s has leading or trailing white space: enter the identifier alone" % name)
    if any(ord(c) < 32 or ord(c) == 127 for c in value):
        refuse("MACOS-BUNDLE-METADATA", "%s holds a control character (a line break?): enter the identifier alone" % name)
    if len(value) > 255:
        refuse("MACOS-BUNDLE-METADATA", "%s is %d characters long; a bundle identifier has at most 255" % (name, len(value)))
    for bad, why in (("/", "a path separator"), (" ", "a space"), ("*", "a wildcard"), ("$", "a shell substitution"),
                     ("`", "a shell substitution"), ("_", "an underscore"), ('"', "a quotation mark"), ("'", "a quotation mark")):
        if bad in value:
            refuse("MACOS-BUNDLE-METADATA", "%s holds %s; a bundle identifier is letters, digits, hyphens and periods, "
                   "reverse-DNS (com.example.icy-tower)" % (name, why))
    if not IDENTIFIER.fullmatch(value):
        refuse("MACOS-BUNDLE-METADATA", "%s is not a reverse-DNS bundle identifier: letters (A-Z, a-z), digits, hyphens "
               "and periods, at least two components, none empty (com.example.icy-tower)" % name)
    if value.lower().startswith("com.apple."):
        refuse("MACOS-BUNDLE-METADATA", "%s is in Apple's reserved com.apple. domain: use a domain of your own" % name)
    return value


def check_version(value, name):
    if value is None or not VERSION.fullmatch(value):
        refuse("MACOS-BUNDLE-METADATA", "%s %r is not one to three period-separated integers (1.2.3), as Apple requires "
               "of CFBundleShortVersionString and CFBundleVersion" % (name, value))
    return value


def version_tuple(text):
    parts = [int(p) for p in text.split(".")]
    return tuple(parts + [0] * (3 - len(parts)))


def info(bundle_id, version, build):
    """The Info.plist's dictionary, every value checked."""
    check_identifier(bundle_id)
    check_version(version, "the version")
    check_version(build, "the build")
    return {
        "CFBundleDevelopmentRegion": "en",
        "CFBundleDisplayName": NAME,
        "CFBundleExecutable": EXECUTABLE,
        "CFBundleIdentifier": bundle_id,
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": NAME,
        "CFBundlePackageType": "APPL",
        "CFBundleShortVersionString": version,
        "CFBundleVersion": build,
        "LSApplicationCategoryType": CATEGORY,
        "LSEnvironment": dict(LAUNCH_ENVIRONMENT),
        "LSMinimumSystemVersion": MINIMUM_SYSTEM,
        "NSHighResolutionCapable": True,
        # SDL3's Cocoa driver makes the process's NSApplication itself (an
        # NSApplication subclass, in Cocoa_RegisterApp) and never calls
        # NSApplicationMain, so this names the class of application the
        # bundle is, for the system, and starts no second lifecycle.
        "NSPrincipalClass": "NSApplication",
        "NSHumanReadableCopyright": "Icy Tower, an example game of Botlish (MIT License); SDL3 (zlib License).",
    }


def write_plist(path, bundle_id, version, build):
    data = plistlib.dumps(info(bundle_id, version, build), fmt=plistlib.FMT_XML, sort_keys=True)
    with open(path, "wb") as f:
        f.write(data)


# Keys whose presence would make the game no ordinary foreground application.
FORBIDDEN = {
    "LSUIElement": "an agent (no Dock icon, no menu bar)",
    "LSBackgroundOnly": "a background-only application",
    "NSUIElement": "an agent",
    "LSMultipleInstancesProhibited": None,
}


def check_info(d, bundle_id=None, version=None, build=None):
    """The parsed Info.plist D against the bundle's contract (and the given values, when given)."""
    required = {
        "CFBundlePackageType": "APPL",
        "CFBundleExecutable": EXECUTABLE,
        "CFBundleName": NAME,
        "CFBundleDisplayName": NAME,
        "CFBundleInfoDictionaryVersion": "6.0",
        "LSMinimumSystemVersion": MINIMUM_SYSTEM,
        "NSHighResolutionCapable": True,
        "NSPrincipalClass": "NSApplication",
        "LSEnvironment": LAUNCH_ENVIRONMENT,
    }
    for key, want in required.items():
        if key not in d:
            refuse("MACOS-BUNDLE-METADATA", "Info.plist has no %s (wanted %r)" % (key, want))
        if d[key] != want or type(d[key]) is not type(want):
            refuse("MACOS-BUNDLE-METADATA", "Info.plist's %s is %r, not %r" % (key, d[key], want))
    for key in ("CFBundleIdentifier", "CFBundleShortVersionString", "CFBundleVersion"):
        if not isinstance(d.get(key), str):
            refuse("MACOS-BUNDLE-METADATA", "Info.plist has no %s string" % key)
    check_identifier(d["CFBundleIdentifier"], "Info.plist's CFBundleIdentifier")
    check_version(d["CFBundleShortVersionString"], "Info.plist's CFBundleShortVersionString")
    check_version(d["CFBundleVersion"], "Info.plist's CFBundleVersion")
    for key, what in FORBIDDEN.items():
        if d.get(key):
            refuse("MACOS-BUNDLE-METADATA", "Info.plist sets %s: Icy Tower would be %s, not a normal application"
                   % (key, what or "restricted to one instance"))
    if bundle_id is not None and d["CFBundleIdentifier"] != bundle_id:
        refuse("MACOS-BUNDLE-METADATA", "the bundle's identifier is %s, not the configured %s" % (d["CFBundleIdentifier"], bundle_id))
    if version is not None and d["CFBundleShortVersionString"] != version:
        refuse("MACOS-BUNDLE-METADATA", "the bundle's version is %s, not the release's %s" % (d["CFBundleShortVersionString"], version))
    if build is not None and d["CFBundleVersion"] != build:
        refuse("MACOS-BUNDLE-METADATA", "the bundle's build is %s, not %s" % (d["CFBundleVersion"], build))


# ---------------------------------------------------------------------------
# The Mach-O

MH_MAGIC_64 = 0xFEEDFACF
FAT_MAGICS = (0xCAFEBABE, 0xBEBAFECA, 0xCAFEBABF, 0xBFBAFECA)
CPU_TYPE_ARM64 = 0x0100000C
MH_EXECUTE = 2
LC_MAIN = 0x80000028
LC_BUILD_VERSION = 0x32
LC_CODE_SIGNATURE = 0x1D
DYLIB_COMMANDS = {0xC: "LC_LOAD_DYLIB", 0x80000018: "LC_LOAD_WEAK_DYLIB", 0x8000001F: "LC_REEXPORT_DYLIB",
                  0x20: "LC_LAZY_LOAD_DYLIB", 0x80000023: "LC_LOAD_UPWARD_DYLIB"}
PLATFORM_MACOS = 1


def nibbles(v):
    return "%d.%d.%d" % (v >> 16, (v >> 8) & 0xFF, v & 0xFF)


def macho(path):
    """The facts of the Mach-O at PATH: {cpu, filetype, stack, minos, sdk, platform, dylibs, signed}."""
    try:
        with open(path, "rb") as f:
            data = f.read()
    except OSError as e:
        refuse("MACOS-BUNDLE-EXECUTABLE", "cannot read %s: %s" % (path, e.strerror))
    if len(data) < 32:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s is %d bytes: no Mach-O" % (path, len(data)))
    (magic_be,) = struct.unpack_from(">I", data, 0)
    if magic_be in FAT_MAGICS:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s is a universal (fat) binary: Icy Tower is a thin arm64 executable" % path)
    magic, cpu, _sub, filetype, ncmds, sizeofcmds, _flags, _res = struct.unpack_from("<IiiIIIII", data, 0)
    if magic != MH_MAGIC_64:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s is no 64-bit Mach-O (magic %08x)" % (path, magic))
    facts = {"cpu": cpu, "filetype": filetype, "stack": None, "minos": None, "sdk": None, "platform": None,
             "dylibs": [], "signed": False}
    off = 32
    end = 32 + sizeofcmds
    if end > len(data):
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s's load commands run past its end" % path)
    for _ in range(ncmds):
        if off + 8 > end:
            refuse("MACOS-BUNDLE-EXECUTABLE", "%s's load commands are truncated" % path)
        cmd, size = struct.unpack_from("<II", data, off)
        if size < 8 or off + size > end:
            refuse("MACOS-BUNDLE-EXECUTABLE", "%s has a malformed load command at %d" % (path, off))
        if cmd == LC_MAIN:
            _entry, stack = struct.unpack_from("<QQ", data, off + 8)
            facts["stack"] = stack
        elif cmd == LC_BUILD_VERSION:
            platform, minos, sdk = struct.unpack_from("<III", data, off + 8)
            facts["platform"], facts["minos"], facts["sdk"] = platform, nibbles(minos), nibbles(sdk)
        elif cmd == LC_CODE_SIGNATURE:
            facts["signed"] = True
        elif cmd in DYLIB_COMMANDS:
            (name_off,) = struct.unpack_from("<I", data, off + 8)
            raw = data[off + name_off:off + size]
            facts["dylibs"].append(raw.split(b"\0", 1)[0].decode("utf-8", "replace"))
        off += size
    return facts


def check_executable(path):
    """The game's executable at PATH, as the bundle needs it; its facts."""
    if not os.path.isfile(path) or os.path.islink(path):
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s is no regular file" % path)
    f = macho(path)
    if f["cpu"] != CPU_TYPE_ARM64:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s is for CPU type %#x, not arm64: Icy Tower's macOS executable is "
               "build-macos.sh's, on Apple Silicon" % (path, f["cpu"] & 0xFFFFFFFF))
    if f["filetype"] != MH_EXECUTE:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s is a Mach-O of file type %d, not an executable" % (path, f["filetype"]))
    if f["stack"] != MAIN_STACK:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s's LC_MAIN reserves %s, not 512 MiB: not built with -native-startup "
               "main-thread (Cocoa needs SDL's video on the process's main thread)" % (path, f["stack"]))
    if f["platform"] != PLATFORM_MACOS:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s has no LC_BUILD_VERSION for macOS (platform %s)" % (path, f["platform"]))
    if version_tuple(f["minos"]) > version_tuple(MINIMUM_SYSTEM):
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s needs macOS %s, later than the bundle's LSMinimumSystemVersion %s"
               % (path, f["minos"], MINIMUM_SYSTEM))
    for lib in f["dylibs"]:
        if re.search(r"sdl", os.path.basename(lib), re.I) or re.search(r"/sdl[0-9]*\.framework/", lib, re.I):
            refuse("MACOS-BUNDLE-EXECUTABLE", "%s loads %s: SDL3 must be linked into the executable (static), never "
                   "loaded from a library" % (path, lib))
        if not (lib.startswith("/usr/lib/") or lib.startswith("/System/Library/")):
            refuse("MACOS-BUNDLE-EXECUTABLE", "%s loads %s, which is no system library: the application carries "
                   "no library of its own" % (path, lib))
    if not f["dylibs"]:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s loads no library at all (not even libSystem): not the game" % path)
    mode = os.stat(path).st_mode
    if not mode & stat.S_IXUSR:
        refuse("MACOS-BUNDLE-EXECUTABLE", "%s is not executable (mode %o)" % (path, mode & 0o777))
    return f


# ---------------------------------------------------------------------------
# The bundle

def walk(app):
    out = []
    for dirpath, dirnames, filenames in os.walk(app):
        dirnames.sort()
        for n in sorted(dirnames + filenames):
            p = os.path.join(dirpath, n)
            out.append(os.path.relpath(p, app))
    return sorted(set(out))


# What a bundle may hold besides its Info.plist, executable and resources:
# the signature (codesign writes Contents/_CodeSignature/CodeResources) and
# the stapled notarization ticket (Contents/CodeResources).
SIGNATURE = ("Contents/_CodeSignature", "Contents/_CodeSignature/CodeResources", "Contents/CodeResources")


def check_bundle(app, bundle_id=None, version=None, build=None):
    """The assembled bundle APP: its layout, Info.plist, executable and resources. Its Info.plist."""
    if not app.endswith(".app") or os.path.basename(app.rstrip("/")) != NAME + ".app":
        refuse("MACOS-BUNDLE-LAYOUT", "%s is not named %s.app" % (app, NAME))
    if not os.path.isdir(app) or os.path.islink(app):
        refuse("MACOS-BUNDLE-LAYOUT", "%s is no directory" % app)
    plist = os.path.join(app, "Contents", "Info.plist")
    if not os.path.isfile(plist):
        refuse("MACOS-BUNDLE-METADATA", "%s has no Contents/Info.plist" % app)
    try:
        with open(plist, "rb") as f:
            d = plistlib.load(f)
    except Exception as e:  # plistlib raises several kinds for a malformed list
        refuse("MACOS-BUNDLE-METADATA", "Contents/Info.plist does not parse as a property list (%s)" % type(e).__name__)
    if not isinstance(d, dict):
        refuse("MACOS-BUNDLE-METADATA", "Contents/Info.plist is no dictionary")
    check_info(d, bundle_id, version, build)
    exe = os.path.join(app, "Contents", "MacOS", d["CFBundleExecutable"])
    if not os.path.exists(exe):
        refuse("MACOS-BUNDLE-EXECUTABLE", "the executable Info.plist names, Contents/MacOS/%s, is missing" % d["CFBundleExecutable"])
    check_executable(exe)
    allowed = {"Contents", "Contents/Info.plist", "Contents/MacOS", "Contents/MacOS/" + EXECUTABLE, "Contents/Resources"}
    allowed |= {"Contents/Resources/" + r for r in RESOURCES}
    allowed |= set(SIGNATURE)
    for rel in walk(app):
        full = os.path.join(app, rel)
        if os.path.islink(full):
            refuse("MACOS-BUNDLE-LAYOUT", "%s is a symbolic link: the bundle holds none" % rel)
        if rel not in allowed:
            refuse("MACOS-BUNDLE-LAYOUT", "the bundle holds %s, which is none of its files (the executable, the Info.plist, "
                   "the resources, the signature)" % rel)
    for r in RESOURCES:
        if not os.path.isfile(os.path.join(app, "Contents", "Resources", r)):
            refuse("MACOS-BUNDLE-LAYOUT", "Contents/Resources/%s is missing" % r)
    return d


def main(argv):
    import argparse
    p = argparse.ArgumentParser(prog="bundle.py")
    sub = p.add_subparsers(dest="command", required=True)
    w = sub.add_parser("plist")
    w.add_argument("--bundle-id", required=True)
    w.add_argument("--version", required=True)
    w.add_argument("--build", required=True)
    w.add_argument("out")
    e = sub.add_parser("check-executable")
    e.add_argument("exe")
    c = sub.add_parser("check")
    c.add_argument("app")
    c.add_argument("--bundle-id")
    c.add_argument("--version")
    c.add_argument("--build")
    i = sub.add_parser("identity")
    i.add_argument("app")
    a = p.parse_args(argv)
    try:
        if a.command == "plist":
            write_plist(a.out, a.bundle_id, a.version, a.build)
        elif a.command == "check-executable":
            f = check_executable(a.exe)
            print("executable: Mach-O arm64, LC_MAIN stack %d, macOS %s (SDK %s), %d system libraries, none SDL3's"
                  % (f["stack"], f["minos"], f["sdk"], len(f["dylibs"])))
        elif a.command == "check":
            d = check_bundle(os.path.abspath(a.app), a.bundle_id, a.version, a.build)
            print("bundle: %s %s (%s), %s" % (d["CFBundleIdentifier"], d["CFBundleShortVersionString"], d["CFBundleVersion"],
                                              os.path.abspath(a.app)))
        elif a.command == "identity":
            with open(os.path.join(a.app, "Contents", "Info.plist"), "rb") as f:
                d = plistlib.load(f)
            print(json.dumps({k: d.get(k) for k in ("CFBundleIdentifier", "CFBundleShortVersionString", "CFBundleVersion",
                                                     "CFBundleExecutable", "LSMinimumSystemVersion")}, sort_keys=True))
    except Refused as r:
        print(str(r), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
