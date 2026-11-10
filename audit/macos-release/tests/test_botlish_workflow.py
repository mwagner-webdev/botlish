#!/usr/bin/env python3
"""test_botlish_workflow.py -- the trust boundary of Botlish.app's release
workflow (.github/workflows/botlish-macos.yml; MACOS-BOTLISH-DISTRIBUTION-
MILESTONE-1.md, "Trusted release boundary"), read as data:

    python3 -I audit/macos-release/tests/test_botlish_workflow.py [-v]

Only the release job, for a botlish-macos-vX.Y.Z tag of main's history,
once the tagged commit's tests are green, in the protected macos-release
environment, sees a credential -- each in the env of the steps that read it
alone, never traced -- and it cannot write; it builds the bundle from the
tag itself, never takes the game's MACOS_BUNDLE_ID, accepts the bundle
before signing, after signing and from the final ZIP, and runs every stage
in order; only the publish job writes, after the release job, publishing
exactly its ZIP; nothing uploads a credential; no job changes a trust
setting; nothing runs for a branch or a pull request.
"""
import os
import re
import sys
import unittest

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
WORKFLOW = os.path.join(ROOT, ".github", "workflows", "botlish-macos.yml")
SECRET = re.compile(r"secrets\.([A-Z0-9_]+)")
VARS = re.compile(r"vars\.([A-Z0-9_]+)")
CREDENTIALS = {"MACOS_CERTIFICATE_P12_BASE64", "MACOS_CERTIFICATE_PASSWORD", "APPLE_NOTARY_KEY_BASE64"}


def text(x):
    return yaml.safe_dump(x, default_flow_style=False, width=1 << 20)


def runs(job):
    return [st.get("run", "") or "" for st in job.get("steps", [])]


def step_index(job, needle):
    for i, st in enumerate(job.get("steps", [])):
        if needle in (st.get("run") or "") or needle in (st.get("name") or ""):
            return i
    return None


class BotlishWorkflow(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with open(WORKFLOW) as f:
            cls.w = yaml.safe_load(f)
        cls.on = cls.w.get(True) or cls.w.get("on")
        cls.jobs = cls.w["jobs"]
        cls.release = cls.jobs["release"]
        cls.publish = cls.jobs["publish"]

    def test_only_tags_and_manual_runs(self):
        self.assertEqual(sorted(self.on), ["push", "workflow_dispatch"])
        self.assertEqual(self.on["push"], {"tags": ["botlish-macos-v*"]})
        self.assertEqual(self.w.get("permissions"), {"contents": "read"})

    def test_release_job_is_protected(self):
        self.assertEqual(self.release.get("environment"), "macos-release")
        cond = self.release.get("if", "")
        self.assertIn("startsWith(github.ref, 'refs/tags/botlish-macos-v')", cond)
        self.assertRegex(cond, r"github\.event_name == 'push' \|\| github\.event_name == 'workflow_dispatch'")
        self.assertIn("needs.tested.outputs.green == 'true'", cond)
        self.assertEqual(self.release.get("needs"), "tested")
        for name, job in self.jobs.items():
            if name != "release":
                self.assertIsNone(job.get("environment"), "job %s enters an environment" % name)

    def test_only_the_release_job_sees_credentials(self):
        for name, job in self.jobs.items():
            if name != "release":
                self.assertFalse(SECRET.findall(text(job)), "job %s references a secret" % name)
        self.assertEqual(set(SECRET.findall(text(self.release))), CREDENTIALS)

    def test_secrets_reach_only_their_steps(self):
        self.assertFalse(SECRET.findall(text(self.release.get("env", {}))), "a secret in the job's env reaches every step")
        holders = {}
        for st in self.release.get("steps", []):
            for field in ("run", "with", "if"):
                self.assertFalse(SECRET.findall(text(st.get(field, ""))), "step %r writes a secret into its %s" % (st.get("name"), field))
            names = set(SECRET.findall(text(st.get("env", {}))))
            if names:
                holders[st.get("name")] = names
                self.assertNotRegex(st.get("run", ""), r"set -[a-z]*x|\bprintenv\b|^\s*env\s*$|echo [^\n]*\$\{?(MACOS_|APPLE_NOTARY_KEY_B)",
                                    "step %r may print a secret" % st.get("name"))
        self.assertEqual(sorted(holders), ["Credential preflight (local)", "Temporary keychain and the Developer ID identity"])
        self.assertEqual(holders["Temporary keychain and the Developer ID identity"], {"MACOS_CERTIFICATE_PASSWORD"})

    def test_the_compilers_identifier_never_the_games(self):
        for name, job in self.jobs.items():
            self.assertNotIn("MACOS_BUNDLE_ID", text(job), "job %s reads MACOS_BUNDLE_ID (the game's identifier)" % name)
        self.assertIn("io.github.mwagner-webdev.botlish", "\n".join(runs(self.publish)))

    def test_release_cannot_write_and_only_publish_writes(self):
        for name, job in self.jobs.items():
            writes = [k for k, v in (job.get("permissions") or {}).items() if v == "write"]
            self.assertEqual(writes, ["contents"] if name == "publish" else [], "job %s may write %s" % (name, writes))

    def test_built_from_the_tagged_revision(self):
        body = "\n".join(runs(self.release))
        self.assertIn('git merge-base --is-ancestor "$GITHUB_SHA" origin/main', body)
        self.assertIn('[ "$(git rev-parse "refs/tags/$tag^{commit}")" = "$GITHUB_SHA" ]', body)
        self.assertIn('single/macos/build.sh -o "$RUNNER_TEMP/build" --version "$VERSION"', body)
        # the bundle signed is the one built here (or, resuming, this commit's run's)
        for st in self.release.get("steps", []):
            self.assertNotIn("download-artifact", st.get("uses", ""), "the release job downloads something to sign")

    def test_release_never_ad_hoc_or_test_anchors(self):
        body = "\n".join(runs(self.release))
        self.assertNotIn("--mode adhoc", body)
        self.assertNotIn("--mode dry-run", body)
        self.assertNotIn("--trust-anchors", body)
        self.assertIn('single/macos/release.py preflight --work "$WORK" --mode release', body)
        self.assertIn('--signature developer-id --team "$TEAM"', body)

    def test_stages_in_order(self):
        order = ["single/macos/build.sh", "Acceptance before signing", "release.py preflight", "release.py identity",
                 "release.py keychain", "release.py notary-auth", "release.py sign", "--signature developer-id",
                 "--label hardened-runtime", "release.py notarize", "rel staple", "rel gatekeeper", "rel tamper",
                 "release.py package", "--label final-artifact", "release.py publishable"]
        found = []
        for needle in order:
            i = step_index(self.release, needle)
            self.assertIsNotNone(i, "no step runs %s" % needle)
            found.append(i)
        self.assertEqual(found, sorted(found), "the stages are out of order: %s" % list(zip(order, found)))

    def test_acceptance_of_the_final_artifact(self):
        st = self.release["steps"][step_index(self.release, "--label final-artifact")]
        body = st["run"]
        self.assertIn('ditto -x -k "$DIST/botlish-macos-aarch64.zip"', body)
        self.assertIn("com.apple.quarantine", body)
        self.assertIn("spctl --assess --type execute", body)
        self.assertIn("xcrun stapler validate", body)
        self.assertLess(body.index("com.apple.quarantine"), body.index("acceptance.sh"))
        self.assertIn("--zip \"$DIST/botlish-macos-aarch64.zip\"", body)

    def test_cleanup_always_and_no_credential_uploaded(self):
        i = step_index(self.release, "release.py cleanup")
        self.assertIn("always()", self.release["steps"][i].get("if", ""))
        for name, job in self.jobs.items():
            for st in job.get("steps", []):
                if "upload-artifact" not in st.get("uses", ""):
                    continue
                for path in str(st.get("with", {}).get("path", "")).split("\n"):
                    p = path.strip()
                    if p:
                        self.assertNotRegex(p, r"secret|\.p12|\.p8|keychain", "job %s uploads %s" % (name, p))
                        self.assertNotRegex(p, r"/release/?$|\$WORK", "job %s uploads the whole work directory %s" % (name, p))

    def test_release_assets_after_publishable(self):
        publishable = step_index(self.release, "release.py publishable")
        uploads = [(i, st) for i, st in enumerate(self.release["steps"]) if "upload-artifact" in st.get("uses", "")
                   and st.get("with", {}).get("name") == "botlish-macos-release"]
        self.assertEqual(len(uploads), 1)
        i, st = uploads[0]
        self.assertGreater(i, publishable)
        self.assertNotIn("always()", st.get("if", "") or "")

    def test_publish_checks_the_release_jobs_zip(self):
        self.assertEqual(self.publish.get("needs"), "release")
        self.assertIn("needs.release.result == 'success'", self.publish.get("if", ""))
        body = "\n".join(runs(self.publish))
        self.assertIn("sha256sum -c SHA256SUMS", body)
        self.assertIn('[ "$got" = "$ZIP_SHA256" ]', body)
        self.assertIn("never replaced", body)

    def test_no_job_changes_a_trust_setting(self):
        for name, job in self.jobs.items():
            body = "\n".join(runs(job))
            for word in ("add-trusted-cert", "remove-trusted-cert", "authorizationdb write", "trust-settings-import",
                         "spctl --master-disable", "spctl --global-disable", "--add --label"):
                self.assertNotIn(word, body, "job %s: %s" % (name, word))

    def test_tested_first_and_never_cancelled(self):
        tested = self.jobs["tested"]
        self.assertEqual(tested.get("permissions"), {"contents": "read", "actions": "read"})
        self.assertIn('tools/ci/runs.py check "$GITHUB_SHA" --for botlish-macos', "\n".join(runs(tested)))
        self.assertIn("!startsWith(github.ref, 'refs/tags/')", self.w["concurrency"]["cancel-in-progress"])


if __name__ == "__main__":
    unittest.main()
