#!/usr/bin/env python3
"""test_workflow.py -- the trust boundary of the macOS release workflow
(.github/workflows/icy-tower-macos.yml; ICY-TOWER-MACOS-APP-MILESTONE-1.md,
"GitHub Actions trust boundaries"):

    python3 -I audit/macos-release/tests/test_workflow.py [-v] [--workflow FILE]

GitHub runs the workflow; these tests read it as GitHub reads it (YAML,
the jobs, their conditions, environments, permissions, steps and the
expressions in them) and hold it to the release's rules: only the release
job, in the macos-release environment, for an icy-tower-macos-v* tag
pushed or run by hand, sees a credential; a pull request (from a fork or
not) never does, nor does pull_request_target exist; each secret reaches
only the steps that read it, through env, never inside a script or a
`with`; no step that holds one traces its commands; the stages run in the
release's order (the local preflight before any Apple tool, Apple's
credential check before signing, the signed application played before it
is notarized, nothing packaged before stapling, nothing published before
the downloaded artifact was launched and the publishable check passed);
nothing uploads the work directory's decoded credentials; only the publish
job may write, and only after the release job succeeded, publishing the
release job's own ZIP.
"""
import os
import re
import sys
import unittest

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
WORKFLOW = os.path.join(ROOT, ".github", "workflows", "icy-tower-macos.yml")
SECRET = re.compile(r"secrets\.([A-Z0-9_]+)")
CREDENTIALS = {"MACOS_CERTIFICATE_P12_BASE64", "MACOS_CERTIFICATE_PASSWORD", "APPLE_NOTARY_KEY_BASE64"}
VARIABLES = {"APPLE_NOTARY_KEY_ID", "APPLE_NOTARY_ISSUER_ID", "APPLE_TEAM_ID", "MACOS_BUNDLE_ID"}


def load(path):
    with open(path) as f:
        return yaml.safe_load(f)


def text(x):
    return yaml.safe_dump(x, default_flow_style=False, width=1 << 20)


def runs(job):
    return [st.get("run", "") or "" for st in job.get("steps", [])]


def step_index(job, needle):
    for i, st in enumerate(job.get("steps", [])):
        if needle in (st.get("run") or "") or needle in (st.get("name") or "") or needle in text(st.get("with", {})):
            return i
    return None


class Workflow(unittest.TestCase):
    path = WORKFLOW

    @classmethod
    def setUpClass(cls):
        cls.w = load(cls.path)
        cls.on = cls.w.get(True) or cls.w.get("on")
        cls.jobs = cls.w["jobs"]
        cls.release = cls.jobs.get("release", {})
        cls.publish = cls.jobs.get("publish", {})

    # --- who may run with credentials ---------------------------------------------

    def test_no_pull_request_target(self):
        self.assertNotIn("pull_request_target", self.on, "pull_request_target runs contributors' code with secrets")
        self.assertNotIn("workflow_run", self.on)

    def test_workflow_permissions_read_only(self):
        self.assertEqual(self.w.get("permissions"), {"contents": "read"})

    def test_only_the_release_job_sees_credentials(self):
        for name, job in self.jobs.items():
            found = set(SECRET.findall(text(job)))
            if name == "release":
                continue
            self.assertFalse(found & (CREDENTIALS | VARIABLES), "job %s references %s" % (name, found))
        self.assertTrue(set(SECRET.findall(text(self.release))) >= CREDENTIALS)

    def test_release_job_is_protected(self):
        self.assertEqual(self.release.get("environment"), "macos-release")
        cond = self.release.get("if", "")
        self.assertIn("startsWith(github.ref, 'refs/tags/icy-tower-macos-v')", cond)
        self.assertRegex(cond, r"github\.event_name == 'push' \|\| github\.event_name == 'workflow_dispatch'")
        self.assertNotIn("pull_request", cond.replace("'push'", ""))
        self.assertIn("game", self.release.get("needs", []) if isinstance(self.release.get("needs"), list) else [self.release.get("needs")])
        self.assertIn("needs.game.result == 'success'", cond)

    def test_release_job_cannot_write(self):
        perms = self.release.get("permissions", {})
        self.assertEqual(perms.get("contents"), "read")
        self.assertFalse([k for k, v in perms.items() if v == "write"], "the release job may write: %s" % perms)

    def test_other_jobs_have_no_environment(self):
        for name, job in self.jobs.items():
            if name != "release":
                self.assertIsNone(job.get("environment"), "job %s enters an environment" % name)

    def test_game_job_skips_same_repository_pull_requests_and_never_writes(self):
        game = self.jobs["game"]
        self.assertFalse([k for k, v in (game.get("permissions") or {}).items() if v == "write"])

    # --- how a credential is handed over --------------------------------------------

    def test_secrets_only_in_step_env(self):
        self.assertFalse(SECRET.findall(text(self.release.get("env", {}))), "a secret in the job's env reaches every step")
        for st in self.release.get("steps", []):
            for field in ("run", "with", "if"):
                self.assertFalse(set(SECRET.findall(text(st.get(field, "")))) & CREDENTIALS,
                                 "step %r writes a secret into its %s" % (st.get("name"), field))

    def test_secrets_reach_only_their_steps(self):
        holders = {}
        for st in self.release.get("steps", []):
            names = set(SECRET.findall(text(st.get("env", {})))) & CREDENTIALS
            if names:
                holders[st.get("name")] = names
        self.assertEqual(sorted(holders), ["Credential preflight (local)", "Temporary keychain and the Developer ID identity"])
        self.assertEqual(holders["Temporary keychain and the Developer ID identity"], {"MACOS_CERTIFICATE_PASSWORD"})

    def test_no_tracing_or_printing_where_a_secret_is(self):
        for st in self.release.get("steps", []):
            if not set(SECRET.findall(text(st.get("env", {})))) & CREDENTIALS:
                continue
            body = st.get("run", "")
            self.assertNotRegex(body, r"set -[a-z]*x|\bprintenv\b|^\s*env\s*$|echo [^\n]*\$\{?(MACOS_|APPLE_NOTARY_KEY_B)",
                                "step %r may print a secret" % st.get("name"))

    def test_release_never_ad_hoc_or_test_anchors(self):
        body = "\n".join(runs(self.release))
        self.assertNotIn("--mode adhoc", body)
        self.assertNotIn("--mode dry-run", body)
        self.assertNotIn("--trust-anchors", body)
        self.assertIn("preflight --work \"$WORK\" --mode release", body)

    # --- the order of the release -----------------------------------------------------

    def test_stages_in_order(self):
        order = ["release.py preflight", "release.py identity", "release.py keychain", "release.py notary-auth",
                 "release.py sign", "release.py verify-signature --work \"$WORK\" --app \"$RAPP\"\n",
                 "--label hardened-runtime", "release.py notarize", "rel staple", "rel gatekeeper",
                 "release.py package", "--label final-artifact", "release.py publishable"]
        found = []
        for needle in order:
            i = step_index(self.release, needle.strip())
            self.assertIsNotNone(i, "no step runs %s" % needle)
            found.append(i)
        self.assertEqual(found, sorted(found), "the stages are out of order: %s" % list(zip(order, found)))

    def test_release_assets_uploaded_after_publishable(self):
        steps = self.release.get("steps", [])
        publishable = step_index(self.release, "release.py publishable")
        for i, st in enumerate(steps):
            if "upload-artifact" in st.get("uses", "") and st.get("with", {}).get("name") == "icy-tower-macos-release":
                self.assertGreater(i, publishable)
                self.assertNotIn("always()", st.get("if", "") or "", "the release's assets uploaded whatever happened")

    def test_release_assets_are_the_packaged_files(self):
        uploads = [st for st in self.release.get("steps", []) if "upload-artifact" in st.get("uses", "")
                   and st.get("with", {}).get("name") == "icy-tower-macos-release"]
        self.assertEqual(len(uploads), 1)
        paths = sorted(p.strip() for p in uploads[0]["with"]["path"].split("\n") if p.strip())
        self.assertEqual(paths, sorted("${{ runner.temp }}/dist/" + n for n in
                                       ("icy-tower-macos-aarch64.zip", "SHA256SUMS", "provenance.json")))

    def test_cleanup_always(self):
        i = step_index(self.release, "release.py cleanup")
        self.assertIsNotNone(i)
        self.assertIn("always()", self.release["steps"][i].get("if", ""))

    def test_no_upload_of_the_credentials(self):
        for name, job in self.jobs.items():
            for st in job.get("steps", []):
                if "upload-artifact" not in st.get("uses", ""):
                    continue
                for path in str(st.get("with", {}).get("path", "")).split("\n"):
                    p = path.strip()
                    if not p:
                        continue
                    self.assertNotRegex(p, r"secret|\.p12|\.p8|keychain", "job %s uploads %s" % (name, p))
                    self.assertNotRegex(p, r"/release/?$|\$WORK|\$\{\{ env\.WORK", "job %s uploads the whole work directory %s" % (name, p))

    # --- publication ----------------------------------------------------------------------

    def test_publish_only_after_release(self):
        self.assertEqual(sorted(self.publish.get("needs", [])), ["game", "release"])
        self.assertIn("needs.release.result == 'success'", self.publish.get("if", ""))
        self.assertIn("startsWith(github.ref, 'refs/tags/icy-tower-macos-v')", self.publish.get("if", ""))
        self.assertEqual(self.publish.get("permissions"), {"contents": "write"})
        self.assertFalse(SECRET.findall(text(self.publish)))

    def test_publish_checks_the_release_jobs_zip(self):
        body = "\n".join(runs(self.publish))
        self.assertIn("sha256sum -c SHA256SUMS", body)
        self.assertIn("needs.release.outputs.zip_sha256", text(self.publish.get("env", {})))
        self.assertIn('[ "$got" = "$ZIP_SHA256" ]', body)
        self.assertRegex(body, r"gh release view .*\n.*never replaced")

    def test_only_publish_writes(self):
        for name, job in self.jobs.items():
            writes = [k for k, v in (job.get("permissions") or {}).items() if v == "write"]
            if name == "publish":
                self.assertEqual(writes, ["contents"])
            else:
                self.assertEqual(writes, [], "job %s may write %s" % (name, writes))

    def test_release_runs_are_never_cancelled(self):
        self.assertIn("!startsWith(github.ref, 'refs/tags/')", self.w["concurrency"]["cancel-in-progress"])
        self.assertEqual(self.on["push"].get("tags"), ["icy-tower-macos-v*"])

    def test_tested_executable_checked(self):
        body = "\n".join(runs(self.release))
        self.assertIn("needs.game.outputs.exe_sha256", text(self.release))
        self.assertIn('[ "$got" = "$EXE_SHA256" ]', body)


if __name__ == "__main__":
    if "--workflow" in sys.argv:
        i = sys.argv.index("--workflow")
        Workflow.path = sys.argv[i + 1]
        del sys.argv[i:i + 2]
    unittest.main()
