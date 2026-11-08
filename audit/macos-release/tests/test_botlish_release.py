#!/usr/bin/env python3
"""test_botlish_release.py -- Botlish.app's release (single/macos/release.py:
tools/macos-release/release.py's stages with single/macos/bundle.py)
against the recording stand-ins of Apple's tools (tools/stub-tool.py), as
test_release.py runs the game's (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md,
"Release tests"):

    python3 -I audit/macos-release/tests/test_botlish_release.py [-v]

The bundle is a synthetic Botlish.app with single/macos/build.sh's layout
(stand-in Mach-Os, a framework version, the runtime archive); its compiler
archive is the one single/macos/sign.sh packs (single/package.tcl, run by
a zipfs-capable Tcl 9: tclsh9.0, or $BOTLISH_RELEASE_TCLSH). What is checked:
the three signing units signed inner first, each with the hardened runtime
and the release's timestamp and identity, never --deep; each verified; the
application's identifier fixed (MACOS_BUNDLE_ID, the game's variable, never
read); a nested unit without the hardened runtime, with an entitlement or
changed after signing refused; the layout refused when it is not
build.sh's; and a release whose every stage passed publishable.
"""
import json
import os
import plistlib
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
TOOLS = os.path.join(HERE, "..", "tools")
SHARED = os.path.join(ROOT, "tools", "macos-release")
sys.path.insert(0, TOOLS)
sys.path.insert(0, SHARED)
import fixtures as fx  # noqa: E402
import machofake  # noqa: E402
import credentials  # noqa: E402

RELEASE = os.path.join(ROOT, "single", "macos", "release.py")
STUB = os.path.join(TOOLS, "stub-tool.py")
AUTHORITY = fx.Authority()
APPLE_TOOLS = ("security", "codesign", "spctl", "xcrun")
BUNDLE_ID = "io.github.mwagner-webdev.botlish"
ZIP = "botlish-macos-aarch64.zip"
TCLSH = os.environ.get("BOTLISH_RELEASE_TCLSH") or shutil.which("tclsh9.0")


def make_app(directory, bundle_id=BUNDLE_ID):
    """A Botlish.app with build.sh's layout, unsigned."""
    app = os.path.join(directory, "Botlish.app")
    c = os.path.join(app, "Contents")
    version = os.path.join(c, "Frameworks", "Tcl.framework", "Versions", "9.0")
    for d in ("MacOS", "Resources", os.path.join(version, "Resources")):
        os.makedirs(os.path.join(c, d), exist_ok=True)
    with open(os.path.join(c, "Info.plist"), "wb") as f:
        plistlib.dump({"CFBundleExecutable": "botlish", "CFBundleIdentifier": bundle_id, "CFBundlePackageType": "APPL",
                       "CFBundleName": "Botlish", "CFBundleShortVersionString": "0.0", "CFBundleVersion": "0",
                       "LSMinimumSystemVersion": "11.0", "LSBackgroundOnly": True}, f)
    with open(os.path.join(version, "Resources", "Info.plist"), "wb") as f:
        plistlib.dump({"CFBundleIdentifier": "com.tcltk.tcllibrary", "CFBundleExecutable": "Tcl"}, f)
    for path, data in ((os.path.join(version, "Tcl"), b"\xcf\xfa\xed\xfe tcl library" * 64),
                       (os.path.join(c, "MacOS", "botlish"), machofake.make()),
                       (os.path.join(c, "MacOS", "botlish-native"), machofake.make() + b"driver" * 100),
                       (os.path.join(c, "Resources", "libbotlish_runtime.a"), b"!<arch>\nruntime" * 200)):
        with open(path, "wb") as f:
            f.write(data)
    for name in ("botlish", "botlish-native"):
        os.chmod(os.path.join(c, "MacOS", name), 0o755)
    # (The framework's standard links, as Tcl's framework build makes them.)
    fw = os.path.join(c, "Frameworks", "Tcl.framework")
    for link, target in (("Versions/Current", "9.0"), ("Tcl", "Versions/Current/Tcl"), ("Resources", "Versions/Current/Resources")):
        os.symlink(target, os.path.join(fw, link))
    # (build.sh's archive, which sign.sh writes again for the driver it signs.)
    import zipfile
    with zipfile.ZipFile(os.path.join(c, "Resources", "botlish.zip"), "w") as z:
        z.writestr("native-bin/ID", "unsigned\n")
    return app


@unittest.skipUnless(TCLSH, "no zipfs-capable Tcl 9 (tclsh9.0) to pack the compiler archive")
class BotlishRelease(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="botlish-release-test.")
        self.bin = os.path.join(self.tmp, "bin")
        self.state = os.path.join(self.tmp, "stub")
        os.makedirs(self.bin)
        os.makedirs(self.state)
        for tool in APPLE_TOOLS + ("ditto", "unzip", "xattr"):
            path = os.path.join(self.bin, tool)
            with open(path, "w") as f:
                f.write("#!/bin/sh\nSTUB_TOOL=%s exec '%s' '%s' \"$@\"\n" % (tool, sys.executable, STUB))
            os.chmod(path, 0o755)
        self.work = os.path.join(self.tmp, "work")
        self.app = make_app(os.path.join(self.tmp, "build"))
        self.out = os.path.join(self.tmp, "dist")
        self.anchors = os.path.join(self.tmp, "anchors")
        AUTHORITY.write(self.anchors)
        # (The game's MACOS_BUNDLE_ID is in the shared environment: never Botlish.app's.)
        self.env = dict(fx.good_env(AUTHORITY), MACOS_BUNDLE_ID="com.avanticonic.botlishtower")
        self.configure()

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def configure(self, **cfg):
        base = {"apple_chain": True, "valid": True}
        base.update(cfg)
        with open(os.path.join(self.state, "config.json"), "w") as f:
            json.dump(base, f)

    def stage(self, name, *args, env=None):
        e = {k: v for k, v in os.environ.items() if not k.startswith(("MACOS_", "APPLE_"))}
        e.update(self.env if env is None else env)
        e.update({"PATH": self.bin + os.pathsep + os.environ["PATH"], "STUB_STATE": self.state,
                  "MACOS_RELEASE_WAIT_SCALE": "0.001", "BOTLISH_RELEASE_TCLSH": TCLSH})
        r = subprocess.run([sys.executable, "-I", RELEASE, name, "--work", self.work] + list(args), env=e,
                           capture_output=True, text=True, timeout=600)
        output = r.stdout + r.stderr
        for v in credentials.secret_values(e):
            for piece in (v[i:i + 16] for i in range(0, max(1, len(v) - 15), 8)):
                if len(piece) >= 12:
                    self.assertNotIn(piece, output, "a piece of a secret was printed by %s" % name)
        return r.returncode, output

    def ok(self, name, *args, **kw):
        code, output = self.stage(name, *args, **kw)
        self.assertEqual(code, 0, "%s failed:\n%s" % (name, output))
        return output

    def refused(self, name, code_text, *args, **kw):
        code, output = self.stage(name, *args, **kw)
        self.assertEqual(code, 1, "%s should have been refused:\n%s" % (name, output))
        self.assertIn(code_text, output)
        return output

    def calls(self):
        path = os.path.join(self.state, "calls.log")
        if not os.path.exists(path):
            return []
        with open(path) as f:
            return [json.loads(line) for line in f]

    def fake_apple_preflight(self):
        """The preflight under the test anchors, its record then marked as Apple's (test_release.py's stand-in
        for Apple's issuance)."""
        self.ok("preflight", "--mode", "dry-run", "--trust-anchors", self.anchors)
        with open(os.path.join(self.work, "state.json")) as f:
            st = json.load(f)
        st["mode"] = "release"
        st["stages"][0]["anchors"] = "apple"
        st["stages"][0]["identity"]["intermediate"] = None
        with open(os.path.join(self.work, "state.json"), "w") as f:
            json.dump(st, f)

    def results(self, name, cases=("compiler-smoke", "aot-run", "no-jit")):
        path = os.path.join(self.tmp, name + ".json")
        with open(path, "w") as f:
            json.dump([{"name": c, "class": "EXECUTED"} for c in cases], f)
        return path

    def through_signing(self):
        self.fake_apple_preflight()
        self.ok("identity")
        self.ok("keychain")
        self.ok("notary-auth")
        self.ok("sign", "--app", self.app)

    def flip(self, path):
        with open(path, "r+b") as f:
            f.seek(os.path.getsize(path) // 2)
            b = f.read(1)
            f.seek(-1, 1)
            f.write(bytes([b[0] ^ 0x01]))

    # --- the whole release ----------------------------------------------------

    def test_botlish_release_is_publishable(self):
        self.through_signing()
        self.ok("verify-signature", "--app", self.app)
        self.ok("record", "--label", "hardened-runtime", "--results", self.results("hr"), "--app", self.app)
        self.ok("notarize", "--app", self.app, "--timeout", "30")
        self.ok("staple", "--app", self.app)
        self.ok("verify-signature", "--app", self.app, "--label", "stapled")
        self.ok("gatekeeper", "--app", self.app, "--expect", "notarized")
        self.ok("tamper", "--app", self.app)
        self.ok("package", "--app", self.app, "--out", self.out, "--provenance", json.dumps({"version": "0.1.0"}))
        self.ok("record", "--label", "final-artifact", "--results", self.results("final"), "--zip", os.path.join(self.out, ZIP))
        out = self.ok("publishable", "--out", self.out)
        self.assertIn("every stage of the release passed", out)
        with open(os.path.join(self.out, "provenance.json")) as f:
            p = json.load(f)
        self.assertEqual(p["bundle_id"], BUNDLE_ID, "the release's identifier is the compiler's, never MACOS_BUNDLE_ID's")
        self.assertEqual(p["team"], fx.TEAM)
        self.assertEqual(p["zip"], ZIP)
        # The signing order: the framework's version, the driver, the application; each with the release's
        # identity, the hardened runtime and a secure timestamp; never --deep.
        signs = [c for c in self.calls() if c[0] == "codesign" and "--sign" in c]
        targets = [os.path.relpath(c[-1], os.path.dirname(self.app)) for c in signs]
        self.assertEqual(targets, ["Botlish.app/Contents/Frameworks/Tcl.framework/Versions/9.0",
                                   "Botlish.app/Contents/MacOS/botlish-native", "Botlish.app"])
        for c in signs:
            self.assertNotIn("--deep", c)
            self.assertIn("--timestamp", c)
            self.assertEqual(c[c.index("--options") + 1], "runtime")
            self.assertNotEqual(c[c.index("--sign") + 1], "-")
        self.assertEqual(signs[1][signs[1].index("--identifier") + 1], BUNDLE_ID + ".native")
        self.ok("cleanup")

    def test_botlish_archive_names_the_signed_driver(self):
        """sign.sh writes the compiler archive after the driver's signature: its native-bin/ID names the driver
        as the bundle holds it (CRC-32 and size), and the archive holds the compiler."""
        import zipfile
        import zlib
        self.through_signing()
        c = os.path.join(self.app, "Contents")
        with zipfile.ZipFile(os.path.join(c, "Resources", "botlish.zip")) as z:
            names = z.namelist()
            ident = z.read("native-bin/ID").decode().strip()

        def crc(path):
            with open(path, "rb") as f:
                data = f.read()
            return "%08x-%d" % (zlib.crc32(data) & 0xFFFFFFFF, len(data))
        self.assertEqual(ident, crc(os.path.join(c, "MacOS", "botlish-native")) + "-" + crc(os.path.join(c, "Resources", "libbotlish_runtime.a")))
        for entry in ("main.tcl", "botlish/main.tcl", "botlish/stdlib/list.bot", "botlish/BUILD"):
            self.assertIn(entry, names)

    def test_botlish_ignores_macos_bundle_id(self):
        """MACOS_BUNDLE_ID (the game's variable) is neither required nor read for Botlish.app."""
        env = {k: v for k, v in self.env.items() if k != "MACOS_BUNDLE_ID"}
        self.ok("preflight", "--mode", "dry-run", "--trust-anchors", self.anchors, env=env)
        with open(os.path.join(self.work, "state.json")) as f:
            self.assertEqual(json.load(f)["stages"][0]["bundle_id"], BUNDLE_ID)

    # --- the nested signing units ----------------------------------------------

    def test_nested_unit_without_hardened_runtime_refused(self):
        self.configure(nested_no_runtime=True)
        self.through_signing()
        out = self.refused("verify-signature", "MACOS-SIGN", "--app", self.app)
        self.assertIn("Contents/MacOS/botlish-native: the hardened runtime is not enabled", out)
        self.assertIn("Contents/Frameworks/Tcl.framework/Versions/9.0: the hardened runtime is not enabled", out)

    def test_nested_unit_with_entitlement_refused(self):
        self.configure(nested_entitlements="com.apple.security.cs.allow-jit")
        self.through_signing()
        out = self.refused("verify-signature", "MACOS-SIGN", "--app", self.app)
        self.assertIn("Contents/MacOS/botlish-native: it carries entitlements (com.apple.security.cs.allow-jit): Botlish needs none", out)

    def test_driver_changed_after_signing_refused(self):
        self.through_signing()
        self.flip(os.path.join(self.app, "Contents", "MacOS", "botlish-native"))
        self.refused("verify-signature", "MACOS-SIGN", "--app", self.app)

    def test_driver_signed_ad_hoc_refused(self):
        """A release whose driver is left with an ad hoc signature (its identity never applied) is refused."""
        self.through_signing()
        driver = os.path.join(self.app, "Contents", "MacOS", "botlish-native")
        e = dict(os.environ, PATH=self.bin + os.pathsep + os.environ["PATH"], STUB_STATE=self.state)
        subprocess.run(["codesign", "--force", "--sign", "-", "--options", "runtime", "--identifier", BUNDLE_ID + ".native", driver],
                       env=e, check=True, capture_output=True)
        # ... and the application signed again with the release's identity over it.
        with open(os.path.join(self.work, "state.json")) as f:
            keychain = [st for st in json.load(f)["stages"] if st["stage"] == "keychain"][-1]
        subprocess.run(["codesign", "--force", "--sign", keychain["identity"], "--keychain", keychain["keychain"], "--options",
                        "runtime", "--timestamp", self.app], env=e, check=True, capture_output=True)
        out = self.refused("verify-signature", "MACOS-SIGN", "--app", self.app)
        self.assertIn("Contents/MacOS/botlish-native: it is an ad hoc signature", out)

    # --- the bundle -------------------------------------------------------------

    def test_wrong_identifier_refused(self):
        shutil.rmtree(self.app)
        self.app = make_app(os.path.join(self.tmp, "build"), bundle_id="com.avanticonic.botlishtower")
        self.fake_apple_preflight()
        self.refused("sign", "MACOS-BUNDLE-METADATA", "--app", self.app)

    def test_extra_executable_refused(self):
        with open(os.path.join(self.app, "Contents", "MacOS", "helper"), "wb") as f:
            f.write(machofake.make())
        self.fake_apple_preflight()
        self.refused("sign", "MACOS-BUNDLE-LAYOUT", "--app", self.app)

    def test_zip_that_changes_links_refused(self):
        # A ZIP whose framework links came back as copies of what they point to, or pointing at the build
        # machine's files (absolute targets: the bundle works only where it was built), is not the bundle
        # that was signed: the package stage compares links as links, by their targets.
        self.ok("sign", "--mode", "adhoc", "--app", self.app)
        self.ok("verify-signature", "--app", self.app)
        for fault in ("deref_links", "absolute_links"):
            self.configure(**{fault: True})
            self.refused("package", "MACOS-PUBLISH", "--app", self.app, "--out", self.out)
        self.configure()
        self.ok("package", "--app", self.app, "--out", self.out)
        with zipfile.ZipFile(os.path.join(self.out, ZIP)) as z:
            links = sorted(i.filename for i in z.infolist() if stat.S_ISLNK(i.external_attr >> 16))
        self.assertEqual(links, ["Botlish.app/Contents/Frameworks/Tcl.framework/" + n for n in ("Resources", "Tcl", "Versions/Current")])

    def test_adhoc_build_signs_and_verifies_but_is_never_published(self):
        self.ok("sign", "--mode", "adhoc", "--app", self.app)
        self.ok("verify-signature", "--app", self.app)
        signs = [c for c in self.calls() if c[0] == "codesign" and "--sign" in c]
        self.assertEqual([c[c.index("--sign") + 1] for c in signs], ["-", "-", "-"])
        self.assertTrue(all("--timestamp=none" in c and c[c.index("--options") + 1] == "runtime" for c in signs))
        self.refused("publishable", "MACOS-PUBLISH", "--out", self.out)


if __name__ == "__main__":
    unittest.main()
