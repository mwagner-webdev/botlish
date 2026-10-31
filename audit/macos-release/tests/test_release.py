#!/usr/bin/env python3
"""test_release.py -- release.py's stages against recording stand-ins of
Apple's tools (ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Release pipeline
tests", "Bundle and release negative controls"):

    python3 -I audit/macos-release/tests/test_release.py [-v]

The stand-ins (tools/stub-tool.py) model what the release relies on --
a keychain's identities, a signature that seals the bundle's files,
Gatekeeper's verdict, notarytool's answers, a stapled ticket, ZIP archives
-- and log every call, so each test shows what the pipeline did and, as
much, what it did not: no Apple tool after a failed preflight, no ad hoc
fallback in a release, no publication after any failed or skipped stage,
no secret in any output.

A release's preflight checks Apple's certificate authorities, which no
synthetic certificate passes (test_credentials.py shows it). Here the
preflight's record is made by credentials.py under the test anchors and
then marked as Apple's -- the tests' stand-in for Apple's issuance, so the
stages after it can run; that the real preflight refuses the synthetic
identity, and that a release refuses test anchors, are tests of their own.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
TOOLS = os.path.join(HERE, "..", "tools")
MACOS = os.path.join(ROOT, "examples", "games", "icy-tower", "macos")
sys.path.insert(0, TOOLS)
sys.path.insert(0, MACOS)
import fixtures as fx  # noqa: E402
import machofake  # noqa: E402
import bundle  # noqa: E402
import credentials  # noqa: E402

RELEASE = os.path.join(MACOS, "release.py")
STUB = os.path.join(TOOLS, "stub-tool.py")
AUTHORITY = fx.Authority()
APPLE_TOOLS = ("security", "codesign", "spctl", "xcrun")


def make_app(directory, exe_bytes=None, bundle_id=fx.BUNDLE_ID):
    app = os.path.join(directory, bundle.NAME + ".app")
    os.makedirs(os.path.join(app, "Contents", "MacOS"))
    os.makedirs(os.path.join(app, "Contents", "Resources"))
    bundle.write_plist(os.path.join(app, "Contents", "Info.plist"), bundle_id, "1.2.3", "1.2.3")
    exe = os.path.join(app, "Contents", "MacOS", bundle.EXECUTABLE)
    with open(exe, "wb") as f:
        f.write(exe_bytes or machofake.make())
    os.chmod(exe, 0o755)
    for r in bundle.RESOURCES:
        with open(os.path.join(app, "Contents", "Resources", r), "w") as f:
            f.write("license text\n")
    return app


class Stages(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="release-test.")
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
        self.env = fx.good_env(AUTHORITY)
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
                  "ICY_TOWER_RELEASE_WAIT_SCALE": "0.001"})
        r = subprocess.run([sys.executable, "-I", RELEASE, name, "--work", self.work] + list(args), env=e,
                           capture_output=True, text=True, timeout=300)
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

    def apple_calls(self):
        return [c for c in self.calls() if c[0] in APPLE_TOOLS]

    def fake_apple_preflight(self):
        """credentials.py's preflight under the test anchors, its record then marked as Apple's (see above)."""
        self.ok("preflight", "--mode", "dry-run", "--trust-anchors", self.anchors)
        with open(os.path.join(self.work, "state.json")) as f:
            st = json.load(f)
        st["mode"] = "release"
        st["stages"][0]["anchors"] = "apple"
        st["stages"][0]["identity"]["intermediate"] = None
        with open(os.path.join(self.work, "state.json"), "w") as f:
            json.dump(st, f)

    def results(self, name, cases=("app-launch", "app-keyboard")):
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
        self.ok("verify-signature", "--app", self.app)
        self.ok("record", "--label", "hardened-runtime", "--results", self.results("hr"), "--app", self.app)

    def through_stapling(self):
        self.through_signing()
        self.ok("notarize", "--app", self.app, "--timeout", "30")
        self.ok("staple", "--app", self.app)
        self.ok("verify-signature", "--app", self.app, "--label", "stapled")

    def full_release(self):
        self.through_stapling()
        self.ok("gatekeeper", "--app", self.app, "--expect", "notarized")
        self.ok("tamper", "--app", self.app)
        self.ok("package", "--app", self.app, "--out", self.out, "--provenance", json.dumps({"version": "1.2.3"}))
        self.ok("record", "--label", "final-artifact", "--results", self.results("final"), "--zip",
                os.path.join(self.out, "icy-tower-macos-aarch64.zip"))

    # --- the whole release --------------------------------------------------

    def test_full_release_is_publishable(self):
        self.full_release()
        out = self.ok("publishable", "--out", self.out)
        self.assertIn("every stage of the release passed", out)
        with open(os.path.join(self.out, "provenance.json")) as f:
            p = json.load(f)
        self.assertEqual(p["team"], fx.TEAM)
        self.assertEqual(p["bundle_id"], fx.BUNDLE_ID)
        self.assertTrue(p["notarization_submission"])
        signs = [c for c in self.calls() if c[0] == "codesign" and "--sign" in c]
        self.assertEqual(len(signs), 1)
        self.assertNotIn("--deep", signs[0])
        self.assertIn("--timestamp", signs[0])
        self.assertEqual(signs[0][signs[0].index("--options") + 1], "runtime")
        self.assertNotIn("-", [signs[0][signs[0].index("--sign") + 1]])
        self.ok("cleanup")
        with open(os.path.join(self.state, "searchlist.json")) as f:
            self.assertEqual(json.load(f), ["/Users/runner/Library/Keychains/login.keychain-db"])
        self.assertFalse(os.path.exists(os.path.join(self.work, "secret")))

    # --- the preflight runs first ---------------------------------------------

    def test_failed_preflight_stops_everything(self):
        bad = dict(self.env, APPLE_NOTARY_KEY_ID="AuthKey_X.p8")
        self.refused("preflight", "MACOS-NOTARY-CONFIG", "--mode", "release", env=bad)
        for name, args in (("keychain", ()), ("notary-auth", ()), ("sign", ("--app", self.app)),
                           ("notarize", ("--app", self.app)), ("staple", ("--app", self.app))):
            self.refused(name, "has not passed", *args, env=bad)
        self.assertEqual(self.apple_calls(), [], "an Apple tool ran after a failed preflight")
        self.refused("publishable", "MACOS-PUBLISH", "--out", self.out)

    def test_release_refuses_test_anchors(self):
        self.refused("preflight", "refused in release mode", "--mode", "release", "--trust-anchors", self.anchors)
        self.assertEqual(self.apple_calls(), [])

    def test_release_preflight_refuses_synthetic_identity(self):
        self.refused("preflight", "not issued by Apple's Developer ID", "--mode", "release")
        self.refused("keychain", "has not passed")
        self.assertEqual(self.apple_calls(), [])

    # --- keychain --------------------------------------------------------------

    def test_keychain_refuses_an_untrusted_identity(self):
        self.fake_apple_preflight()
        self.configure(valid=False)
        self.refused("keychain", "not a valid code-signing identity")

    def test_keychain_refuses_ambiguous_identities(self):
        self.fake_apple_preflight()
        self.configure(extra_identities=["0" * 40])
        self.refused("keychain", "refusing to choose one")

    def test_keychain_refuses_another_root(self):
        self.fake_apple_preflight()
        self.configure(root_sha256="00" * 32)
        self.refused("keychain", "Apple Root CA is not the committed")

    def test_secrets_redacted_from_tool_output(self):
        # security fails and its output, which echoes its arguments (the .p12's and the keychain's
        # passwords among them), is part of the diagnosis release.py prints.
        self.fake_apple_preflight()
        self.configure(echo_args=True, import_fails=True)
        out = self.refused("keychain", "MACOS-CERTIFICATE-DECRYPT")
        self.assertIn("[REDACTED]", out)
        self.assertNotIn(fx.PASSWORD, out)
        self.assertIn("security called with: import", out, "the tool's own words are kept, redacted, for the diagnosis")

    # --- notary authentication ---------------------------------------------------

    def notary_auth_fails(self, mode, code):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.configure(notary_auth=mode)
        out = self.refused("notary-auth", code)
        self.refused("sign", "has not passed", "--app", self.app)
        self.assertFalse([c for c in self.calls() if c[0] == "codesign"], "signed after a failed notary authentication")
        return out

    def test_notary_auth_rejected(self):
        out = self.notary_auth_fails("401", "MACOS-NOTARY-AUTH")
        self.assertIn("Key ID / Issuer ID / private-key combination", out)

    def test_notary_account_agreement(self):
        self.notary_auth_fails("agreement", "MACOS-NOTARY-ACCOUNT")

    def test_notary_permission(self):
        self.notary_auth_fails("403", "MACOS-NOTARY-PERMISSION")

    def test_notary_service_unreachable(self):
        out = self.notary_auth_fails("offline", "MACOS-NOTARY-SERVICE")
        self.assertNotIn("MACOS-NOTARY-KEY-FORMAT", out)
        self.assertNotIn("MACOS-NOTARY-AUTH", out)

    def test_notary_unknown_failure(self):
        self.notary_auth_fails("weird", "MACOS-NOTARY-TOOL")

    # --- signing -------------------------------------------------------------------

    def test_release_never_signs_ad_hoc(self):
        self.fake_apple_preflight()
        self.refused("sign", "has not passed", "--app", self.app)
        self.assertFalse([c for c in self.calls() if c[0] == "codesign"])

    def test_release_refuses_an_ad_hoc_signature(self):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.ok("notary-auth")
        self.ok("sign", "--app", self.app)
        subprocess.run(["codesign", "--force", "--sign", "-", "--options", "runtime", self.app],
                       env=dict(os.environ, PATH=self.bin + os.pathsep + os.environ["PATH"], STUB_STATE=self.state), check=True)
        self.refused("verify-signature", "ad hoc signature", "--app", self.app)

    def test_missing_hardened_runtime(self):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.ok("notary-auth")
        self.configure(sign_runtime=False)
        self.ok("sign", "--app", self.app)
        self.refused("verify-signature", "hardened runtime is not enabled", "--app", self.app)

    def test_missing_secure_timestamp(self):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.ok("notary-auth")
        self.configure(timestamp=False)
        self.ok("sign", "--app", self.app)
        self.refused("verify-signature", "no secure timestamp", "--app", self.app)

    def test_entitlement_refused(self):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.ok("notary-auth")
        self.ok("sign", "--app", self.app)
        self.configure(entitlements="com.apple.security.cs.allow-jit")
        self.refused("verify-signature", "carries entitlements", "--app", self.app)

    def test_not_apple_chain(self):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.ok("notary-auth")
        self.configure(apple_chain=False)
        self.ok("sign", "--app", self.app)
        self.refused("verify-signature", "authority chain", "--app", self.app)

    def test_modified_after_signing(self):
        self.through_signing()
        with open(os.path.join(self.app, "Contents", "Resources", bundle.RESOURCES[0]), "a") as f:
            f.write("changed\n")
        self.refused("verify-signature", "does not verify", "--app", self.app)
        self.refused("notarize", "changed after signing", "--app", self.app)
        self.assertFalse([c for c in self.calls() if c[:3] == ["xcrun", "notarytool", "submit"]])

    def test_identity_never_changes(self):
        self.fake_apple_preflight()
        old = os.path.join(self.tmp, "previous.json")
        with open(old, "w") as f:
            json.dump({"bundle_id": "com.example.other", "version": "1.0.0"}, f)
        self.refused("identity", "never changes the application's identity", "--previous", old)
        with open(old, "w") as f:
            json.dump({"bundle_id": fx.BUNDLE_ID, "version": "1.0.0"}, f)
        self.ok("identity", "--previous", old)

    def test_resume_adopts_the_signed_bundle(self):
        self.through_signing()
        self.configure(notary_status="In Progress")
        self.refused("notarize", "A timeout is not a rejection", "--app", self.app, "--timeout", "1")
        with open(os.path.join(self.work, "notary-submission.json")) as f:
            sid = json.load(f)["id"]
        shutil.rmtree(os.path.join(self.work, "secret"))
        os.unlink(os.path.join(self.work, "state.json"))
        # A new run: its own credentials, keychain and notary profile; the earlier run's signed bundle.
        self.fake_apple_preflight()
        self.ok("identity")
        self.ok("keychain")
        self.ok("notary-auth")
        self.refused("adopt", "--resume SUBMISSION_ID is required", "--app", self.app)
        self.ok("adopt", "--app", self.app, "--resume", sid)
        self.ok("verify-signature", "--app", self.app)
        self.ok("record", "--label", "hardened-runtime", "--results", self.results("hr2"), "--app", self.app)
        self.configure(notary_status="Accepted")
        self.ok("notarize", "--app", self.app, "--resume", sid, "--timeout", "30")
        self.assertEqual(len([c for c in self.calls() if c[:3] == ["xcrun", "notarytool", "submit"]]), 1)
        self.ok("staple", "--app", self.app)

    def test_adopt_refuses_another_signature(self):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.ok("notary-auth")
        subprocess.run(["codesign", "--force", "--sign", "-", "--options", "runtime", self.app],
                       env=dict(os.environ, PATH=self.bin + os.pathsep + os.environ["PATH"], STUB_STATE=self.state), check=True)
        self.refused("adopt", "ad hoc signature", "--app", self.app, "--resume", "00000000-0000-0000-0000-000000001234")

    def test_tamper_control(self):
        self.through_stapling()
        out = self.ok("tamper", "--app", self.app)
        self.assertIn("one byte of the copy's executable changed: codesign refuses it", out)
        self.assertIn("one byte of the copy's resource changed", out)

    # --- notarization ------------------------------------------------------------------

    def test_notarization_invalid(self):
        self.through_signing()
        self.configure(notary_status="Invalid", ticket_always=True, issues=[{"severity": "error", "path": "submission.zip/Icy Tower.app/Contents/MacOS/icy-tower",
                                                         "message": "The signature does not include a secure timestamp."}])
        out = self.refused("notarize", "MACOS-NOTARIZE", "--app", self.app, "--timeout", "30")
        self.assertIn("Invalid, not Accepted", out)
        self.assertIn("Contents/MacOS/icy-tower: The signature does not include a secure timestamp.", out)
        self.refused("staple", "has not passed", "--app", self.app)

    def test_notarization_rejected(self):
        self.through_signing()
        self.configure(notary_status="Rejected", ticket_always=True)
        self.refused("notarize", "Rejected, not Accepted", "--app", self.app, "--timeout", "30")

    def test_notarization_ticket_of_another_artifact(self):
        self.through_signing()
        self.configure(ticket_cdhash="ab" * 20)
        self.refused("notarize", "another artifact was notarized", "--app", self.app, "--timeout", "30")

    def test_notarization_timeout_then_resume(self):
        self.through_signing()
        self.configure(notary_status="In Progress")
        out = self.refused("notarize", "A timeout is not a rejection", "--app", self.app, "--timeout", "1")
        with open(os.path.join(self.work, "notary-submission.json")) as f:
            sid = json.load(f)["id"]
        self.assertIn("--resume %s" % sid, out)
        submits = len([c for c in self.calls() if c[:3] == ["xcrun", "notarytool", "submit"]])
        self.configure(notary_status="Accepted")
        self.ok("notarize", "--app", self.app, "--resume", sid, "--timeout", "30")
        self.assertEqual(len([c for c in self.calls() if c[:3] == ["xcrun", "notarytool", "submit"]]), submits,
                         "the resume uploaded again")

    def test_submission_failure(self):
        self.through_signing()
        self.configure(submit="fail")
        self.refused("notarize", "MACOS-NOTARY-SERVICE", "--app", self.app, "--timeout", "30")

    # --- stapling ----------------------------------------------------------------------

    def test_staple_retries_while_ticket_is_published(self):
        self.through_signing()
        self.ok("notarize", "--app", self.app, "--timeout", "30")
        self.configure(staple_transient=2)
        out = self.ok("staple", "--app", self.app)
        self.assertIn("not available yet (attempt 2", out)

    def test_staple_fatal_is_not_retried(self):
        self.through_signing()
        self.ok("notarize", "--app", self.app, "--timeout", "30")
        self.configure(staple_fatal=True)
        self.refused("staple", "could not staple", "--app", self.app)
        self.assertEqual(len([c for c in self.calls() if c[:3] == ["xcrun", "stapler", "staple"]]), 1)

    # --- Gatekeeper, package, publication ------------------------------------------------------

    def test_gatekeeper_failure_blocks_publication(self):
        self.through_stapling()
        self.configure(spctl="rejected")
        self.refused("gatekeeper", "MACOS-GATEKEEPER", "--app", self.app, "--expect", "notarized")
        self.refused("package", "has not passed", "--app", self.app, "--out", self.out)
        self.refused("publishable", "MACOS-PUBLISH", "--out", self.out)

    def test_stapling_required(self):
        self.through_signing()
        self.ok("notarize", "--app", self.app, "--timeout", "30")
        self.refused("gatekeeper", "stage staple has not passed", "--app", self.app, "--expect", "notarized")
        self.refused("package", "has not passed", "--app", self.app, "--out", self.out)
        self.refused("publishable", "MACOS-PUBLISH", "--out", self.out)

    def test_zip_before_stapling_refused(self):
        self.through_signing()
        self.ok("notarize", "--app", self.app, "--timeout", "30")
        self.refused("package", "has not passed", "--app", self.app, "--out", self.out)

    def test_unstapled_submission_zip_never_published(self):
        self.full_release()
        shutil.copy(os.path.join(self.work, "submission.zip"), os.path.join(self.out, "icy-tower-macos-aarch64.zip"))
        self.refused("publishable", "SHA-256 is not the one SHA256SUMS lists", "--out", self.out)

    def test_zip_losing_permissions_refused(self):
        self.through_stapling()
        self.ok("gatekeeper", "--app", self.app, "--expect", "notarized")
        self.ok("tamper", "--app", self.app)
        self.configure(drop_modes=True)
        self.refused("package", "MACOS-", "--app", self.app, "--out", self.out)

    def test_damaged_zip_refused(self):
        self.full_release()
        z = os.path.join(self.out, "icy-tower-macos-aarch64.zip")
        with open(z, "r+b") as f:
            f.seek(200)
            f.write(b"\xff" * 16)
        self.refused("publishable", "MACOS-PUBLISH", "--out", self.out)

    def test_sha256sums_mismatch(self):
        self.full_release()
        with open(os.path.join(self.out, "SHA256SUMS")) as f:
            text = f.read()
        with open(os.path.join(self.out, "SHA256SUMS"), "w") as f:
            f.write(text.replace(text[:8], "00000000", 1))
        self.refused("publishable", "MACOS-PUBLISH", "--out", self.out)

    def test_final_artifact_must_be_launched(self):
        self.through_stapling()
        self.ok("gatekeeper", "--app", self.app, "--expect", "notarized")
        self.ok("tamper", "--app", self.app)
        self.ok("package", "--app", self.app, "--out", self.out)
        self.refused("publishable", "record:final-artifact did not pass", "--out", self.out)

    def test_failed_acceptance_blocks_notarization(self):
        self.fake_apple_preflight()
        self.ok("keychain")
        self.ok("notary-auth")
        self.ok("sign", "--app", self.app)
        self.ok("verify-signature", "--app", self.app)
        path = os.path.join(self.tmp, "bad.json")
        with open(path, "w") as f:
            json.dump([{"name": "app-launch", "class": "EXECUTED"}, {"name": "app-keyboard", "class": "FAILED"}], f)
        self.refused("record", "MACOS-LAUNCH", "--label", "hardened-runtime", "--results", path, "--app", self.app)
        self.refused("notarize", "has not passed", "--app", self.app)

    def test_adhoc_build_never_publishable(self):
        self.ok("sign", "--mode", "adhoc", "--app", self.app)
        self.ok("verify-signature", "--app", self.app)
        self.ok("package", "--app", self.app, "--out", self.out)
        self.refused("publishable", "never published", "--out", self.out)

    def test_dry_run_never_publishable(self):
        self.configure(apple_chain=False)
        self.ok("preflight", "--mode", "dry-run", "--trust-anchors", self.anchors)
        self.ok("keychain")
        self.ok("sign", "--app", self.app)
        self.ok("verify-signature", "--app", self.app)
        self.refused("publishable", "never published", "--out", self.out)
        self.ok("cleanup")


class BundleControls(unittest.TestCase):
    """The bundle's negative controls: each a broken artifact bundle.py (and package-macos.sh) must refuse."""

    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="bundle-test.")

    def tearDown(self):
        shutil.rmtree(self.tmp, ignore_errors=True)

    def refused(self, app, text):
        with self.assertRaises(bundle.Refused) as cm:
            bundle.check_bundle(app)
        self.assertIn(text, str(cm.exception))

    def test_good_bundle(self):
        bundle.check_bundle(make_app(self.tmp))

    def test_missing_info_plist(self):
        app = make_app(self.tmp)
        os.unlink(os.path.join(app, "Contents", "Info.plist"))
        self.refused(app, "has no Contents/Info.plist")

    def test_malformed_info_plist(self):
        app = make_app(self.tmp)
        with open(os.path.join(app, "Contents", "Info.plist"), "w") as f:
            f.write("<plist><dict><key>CFBundleExecutable</key>")
        self.refused(app, "does not parse")

    def edit_plist(self, app, **changes):
        import plistlib
        p = os.path.join(app, "Contents", "Info.plist")
        with open(p, "rb") as f:
            d = plistlib.load(f)
        d.update(changes)
        with open(p, "wb") as f:
            plistlib.dump(d, f)

    def test_wrong_executable_name(self):
        app = make_app(self.tmp)
        self.edit_plist(app, CFBundleExecutable="IcyTower")
        self.refused(app, "CFBundleExecutable is 'IcyTower'")

    def test_invalid_bundle_identifier(self):
        app = make_app(self.tmp)
        self.edit_plist(app, CFBundleIdentifier="icy tower")
        self.refused(app, "holds a space")

    def test_agent_application_refused(self):
        app = make_app(self.tmp)
        self.edit_plist(app, LSUIElement=True)
        self.refused(app, "an agent")

    def test_missing_executable(self):
        app = make_app(self.tmp)
        os.unlink(os.path.join(app, "Contents", "MacOS", "icy-tower"))
        self.refused(app, "is missing")

    def test_executable_without_execute_permission(self):
        app = make_app(self.tmp)
        os.chmod(os.path.join(app, "Contents", "MacOS", "icy-tower"), 0o644)
        self.refused(app, "is not executable")

    def test_wrong_architecture(self):
        self.refused(make_app(self.tmp, machofake.make(cpu="x86_64")), "not arm64")

    def test_universal_binary(self):
        self.refused(make_app(self.tmp, machofake.make(fat=True)), "universal (fat)")

    def test_worker_startup_executable(self):
        self.refused(make_app(self.tmp, machofake.make(stack=None)), "not built with -native-startup main-thread")

    def test_dynamic_sdl3(self):
        self.refused(make_app(self.tmp, machofake.make(dylibs=["/usr/lib/libSystem.B.dylib", "@rpath/libSDL3.0.dylib"])),
                     "SDL3 must be linked into the executable")

    def test_non_system_library(self):
        self.refused(make_app(self.tmp, machofake.make(dylibs=["/usr/lib/libSystem.B.dylib", "/opt/homebrew/lib/libfoo.dylib"])),
                     "no system library")

    def test_later_minimum_than_bundle(self):
        self.refused(make_app(self.tmp, machofake.make(minos="14.0")), "later than the bundle's LSMinimumSystemVersion")

    def test_stray_file(self):
        app = make_app(self.tmp)
        with open(os.path.join(app, "Contents", "MacOS", "helper"), "w") as f:
            f.write("x")
        self.refused(app, "none of its files")

    def test_symbolic_link(self):
        app = make_app(self.tmp)
        os.symlink("/etc/passwd", os.path.join(app, "Contents", "Resources", "link"))
        self.refused(app, "symbolic link")

    def test_package_script_keeps_previous_bundle(self):
        exe = os.path.join(self.tmp, "exe")
        with open(exe, "wb") as f:
            f.write(machofake.make())
        os.chmod(exe, 0o755)
        lic = os.path.join(self.tmp, "sdl.txt")
        with open(lic, "w") as f:
            f.write("zlib\n")
        out = os.path.join(self.tmp, "out")
        script = os.path.join(ROOT, "examples", "games", "icy-tower", "package-macos.sh")
        base = ["bash", script, exe, out, "--bundle-id", fx.BUNDLE_ID, "--version", "1.0.0", "--build", "1.0.0", "--sdl3-license", lic]
        r = subprocess.run(base, capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        plist_path = os.path.join(out, "Icy Tower.app", "Contents", "Info.plist")
        with open(plist_path, "rb") as f:
            plist = f.read()
        with open(exe, "wb") as f:
            f.write(machofake.make(stack=None))
        r = subprocess.run(base, capture_output=True, text=True)
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("main-thread", r.stdout + r.stderr)
        with open(plist_path, "rb") as f:
            self.assertEqual(f.read(), plist, "a refused build replaced the previous bundle")
        with open(exe, "wb") as f:
            f.write(machofake.make())
        r = subprocess.run(base[:4] + ["--bundle-id", "com.apple.icy-tower"] + base[6:], capture_output=True, text=True)
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("MACOS-BUNDLE-METADATA", r.stdout + r.stderr)
        with open(plist_path, "rb") as f:
            self.assertEqual(f.read(), plist, "refused metadata replaced the previous bundle")


if __name__ == "__main__":
    unittest.main()
