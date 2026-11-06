#!/usr/bin/env python3
"""test_runs.py -- tests of tools/ci/runs.py and tools/ci/history.py
(CI-RUNS.md):

    python3 -I tools/ci/test_runs.py [-v]

The release check, the gate and the pruning against a fake of the GitHub
API over a small commit graph; the canary's records (history.py) from
runs and job logs of the fake; the requests themselves against a fake
urlopen; and, when PyYAML is installed, the workflows' side of the rules
(.github/workflows/: every test workflow cancels a superseded run, main's
included; a release is published only by a release run, after the check;
the gate listens to every workflow a release waits for; every test
workflow's expensive jobs wait for its canary).
"""
import io
import json
import os
import sys
import tempfile
import unittest
import urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
import runs  # noqa: E402
import history  # noqa: E402

REPO = "owner/repo"


def sha(name):
    """A stable 40-hex SHA for a commit's short name."""
    return (name.encode().hex() + "0" * 40)[:40]


class FakeApi:
    """The high-level calls of runs.Api over in-memory state. parents:
    commit -> its parents (names); heads and tags: name -> commit."""

    def __init__(self, parents, heads, tags=None, releases=(), repo=REPO):
        self.repo = repo
        self.parents = {sha(k): [sha(p) for p in v] for k, v in parents.items()}
        self.heads = {k: sha(v) for k, v in heads.items()}
        self.tags_ = {k: sha(v) for k, v in (tags or {}).items()}
        self.releases = set(releases)
        self.runs = []
        self.jobs_ = {}
        self.dispatched = []
        self.cancelled = []
        self.fail_cancel = set()
        self.logs = {}
        self.next_id = 1000

    # building state

    def run(self, workflow, commit, branch="main", event="push", status="completed",
            conclusion="success", title=None, jobs=None, repo=None, created="2026-11-01T00:00:00Z"):
        self.next_id += 1
        r = {"id": self.next_id, "path": ".github/workflows/" + workflow, "head_sha": sha(commit),
             "head_branch": branch, "event": event, "status": status,
             "conclusion": conclusion if status == "completed" else None,
             "display_title": title if title is not None else "commit " + commit,
             "name": workflow, "html_url": "https://example/runs/%d" % self.next_id,
             "head_repository": {"full_name": repo or self.repo}, "created_at": created}
        self.runs.append(r)
        if jobs is not None:
            self.jobs_[r["id"]] = []
            for job in jobs:
                n, c, labels, log = (tuple(job) + (None, None))[:4]
                self.next_id += 1
                self.jobs_[r["id"]].append({"id": self.next_id, "name": n, "status": "completed", "conclusion": c,
                                            "labels": labels or ["ubuntu-latest"]})
                self.logs[self.next_id] = log or ""
        return r

    def green(self, commit, gc="success", own=()):
        """Every CORE workflow green at commit (GC-stress jobs `gc`)."""
        self.run("tests.yml", commit, jobs=[("tests (interp)", "success"), ("tests (native GC-stress)", gc)])
        self.run("tests-arm64.yml", commit, jobs=[("arm64 tests (interp)", "success"),
                                                  ("arm64 tests (native GC-stress, interp)", gc),
                                                  ("arm64 tests (native GC-stress, compile)", gc)])
        self.run("macos-arm64.yml", commit)
        self.run("windows-x86_64.yml", commit)
        for w in own:
            self.run(w, commit)

    # the graph

    def ancestors(self, s):
        seen, todo = set(), [s]
        while todo:
            c = todo.pop()
            if c in seen:
                continue
            seen.add(c)
            todo.extend(self.parents.get(c, []))
        return seen

    def resolve(self, ref):
        return self.heads.get(ref, ref)

    # the calls

    def runs_at(self, s):
        return [r for r in self.runs if r["head_sha"] == s]

    def workflow_runs(self, workflow, pages=1, per_page=100, branch=None, event=None, status=None, created=None):
        out = [r for r in self.runs if r["path"] == ".github/workflows/" + workflow
               and (branch is None or r["head_branch"] == branch)
               and (event is None or r["event"] == event)
               and (status is None or r["status"] == status or r["conclusion"] == status)
               and (created is None or r["created_at"][:10] >= created[2:])]
        return sorted(out, key=lambda r: r["id"], reverse=True)[:per_page * pages]

    def unfinished_runs(self):
        return [r for r in self.runs if r["status"] != "completed"]

    def jobs(self, run_id):
        return self.jobs_.get(run_id, [])

    def log(self, job_id):
        return self.logs[job_id]

    def compare(self, base, head):
        b, h = self.resolve(base), self.resolve(head)
        if b not in self.parents or h not in self.parents:
            return None
        if b == h:
            return "identical"
        if h in self.ancestors(b):
            return "behind"
        if b in self.ancestors(h):
            return "ahead"
        return "diverged"

    def ref_sha(self, ref):
        kind, name = ref.split("/", 1)
        return (self.heads if kind == "heads" else self.tags_).get(name)

    def tags(self, prefix):
        return sorted((k, v) for k, v in self.tags_.items() if k.startswith(prefix))

    def release_exists(self, tag):
        return tag in self.releases

    def dispatch(self, workflow, ref, inputs):
        self.dispatched.append((workflow, ref, dict(inputs)))

    def cancel(self, run_id):
        if run_id in self.fail_cancel:
            raise runs.ApiError("HTTP 409 cannot cancel")
        self.cancelled.append(run_id)


def linear(*names, branches=None):
    """Main's history names[0] <- names[1] <- ... (the last is main's head),
    plus branches: name -> (fork point, [its commits])."""
    parents = {names[0]: []}
    for a, b in zip(names, names[1:]):
        parents[b] = [a]
    heads = {"main": names[-1]}
    for branch, (base, commits) in (branches or {}).items():
        prev = base
        for c in commits:
            parents[c] = [prev]
            prev = c
        heads[branch] = prev
    return parents, heads


def read(path):
    with open(path) as f:
        return f.read()


def quiet():
    lines = []
    return lines, lines.append


SE = runs.RELEASES["single-executable"]
WIN = runs.RELEASES["icy-tower-windows"]
MAC = runs.RELEASES["icy-tower-macos"]


class Check(unittest.TestCase):
    def api(self):
        return FakeApi(*linear("a", "b", "c"))

    def test_green_with_its_build_run(self):
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        v = runs.check(api, sha("b"), SE)
        self.assertTrue(v.green, v.lines)
        build = [r for r in api.runs if r["path"].endswith("single-executable.yml")][0]
        self.assertEqual(v.run_id, build["id"])

    def test_own_build_required(self):
        api = self.api()
        api.green("b")
        v = runs.check(api, sha("b"), SE)
        self.assertFalse(v.green)
        self.assertIn(("single-executable.yml", "missing"), [(w, s) for w, s, _ in v.lines])
        self.assertTrue(runs.check(api, sha("b"), MAC).green, "the tagged release has no build workflow")

    def test_skipped_gc_stress_is_no_success(self):
        api = self.api()
        api.green("b", gc="skipped", own=["single-executable.yml"])
        v = runs.check(api, sha("b"), SE)
        self.assertFalse(v.green)
        state = dict((w.split()[0], s) for w, s, _ in v.lines)
        self.assertEqual(state["tests.yml"], "failed")
        self.assertEqual(state["tests-arm64.yml"], "failed")
        # a push run with GC stress makes it green, whichever run is newer
        api.run("tests.yml", "b", jobs=[("tests (native GC-stress)", "success")])
        api.run("tests-arm64.yml", "b", jobs=[("arm64 tests (native GC-stress, interp)", "success")])
        self.assertTrue(runs.check(api, sha("b"), SE).green)

    def test_gc_stress_job_must_exist(self):
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        for r in api.runs:
            if r["path"].endswith("/tests.yml"):
                api.jobs_[r["id"]] = [{"name": "tests (interp)", "conclusion": "success"}]
        self.assertFalse(runs.check(api, sha("b"), SE).green)

    def test_pending_failed_missing(self):
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        api.runs = [r for r in api.runs if not r["path"].endswith("windows-x86_64.yml")]
        self.assertFalse(runs.check(api, sha("b"), SE).green)
        api.run("windows-x86_64.yml", "b", status="queued")
        v = runs.check(api, sha("b"), SE)
        self.assertIn("pending", [s for w, s, _ in v.lines if w == "windows-x86_64.yml"])
        api.runs[-1].update(status="completed", conclusion="failure")
        v = runs.check(api, sha("b"), SE)
        self.assertIn("failed", [s for w, s, _ in v.lines if w == "windows-x86_64.yml"])
        api.run("windows-x86_64.yml", "b", conclusion="cancelled")
        self.assertFalse(runs.check(api, sha("b"), SE).green)
        api.run("windows-x86_64.yml", "b")
        self.assertTrue(runs.check(api, sha("b"), SE).green, "a later successful attempt counts")

    def test_static_decisions_when_it_ran(self):
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        v = runs.check(api, sha("b"), SE)
        self.assertTrue(v.green)
        self.assertIn(("static-decisions.yml", "not run"), [(w, s) for w, s, _ in v.lines])
        api.run("static-decisions.yml", "b", conclusion="failure")
        self.assertFalse(runs.check(api, sha("b"), SE).green)
        api.run("static-decisions.yml", "b", status="in_progress")
        self.assertFalse(runs.check(api, sha("b"), SE).green)

    def test_not_in_main(self):
        api = FakeApi(*linear("a", "b", branches={"topic": ("a", ["t1"]), "next": ("b", ["n1"])}))
        for c in ("t1", "n1"):
            api.green(c, own=["single-executable.yml"])
            v = runs.check(api, sha(c), SE)
            self.assertFalse(v.green, c)
            self.assertEqual(v.lines[0][:2], ("in main's history", "failed"))

    def test_any_event_at_the_commit_counts(self):
        # a branch push at the commit main later reached tests the same tree
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        api.runs = [r for r in api.runs if not r["path"].endswith("macos-arm64.yml")]
        api.run("macos-arm64.yml", "b", branch="topic")
        self.assertTrue(runs.check(api, sha("b"), SE).green)

    def test_release_runs_are_no_build(self):
        api = self.api()
        api.green("b")
        api.run("single-executable.yml", "c", event="workflow_dispatch", title="release " + sha("b"))
        api.runs[-1]["head_sha"] = sha("b")
        self.assertFalse(runs.check(api, sha("b"), SE).green)
        # a push whose commit message reads like a release run's title is a build
        api.run("single-executable.yml", "b", title="release " + sha("b"))
        self.assertTrue(runs.check(api, sha("b"), SE).green)


class Gate(unittest.TestCase):
    def api(self, *names, **kw):
        api = FakeApi(*linear(*(names or ("a", "b", "c", "d"))), **kw)
        return api

    def gate(self, api, dry=False):
        lines, out = quiet()
        done = runs.gate(api, dry, out)
        return done, lines

    def test_dispatches_the_newest_green_commit(self):
        api = self.api(tags={"single-latest": "a", "icy-tower-windows-latest": "a"})
        for c in ("b", "c"):
            api.green(c, own=["single-executable.yml", "icy-tower-windows.yml"])
        done, _ = self.gate(api)
        self.assertEqual(sorted(api.dispatched), [
            ("icy-tower-windows.yml", "main", {"release": sha("c")}),
            ("single-executable.yml", "main", {"release": sha("c")})])
        self.assertEqual(len(done), 2)

    def test_newest_not_green_older_is(self):
        api = self.api(tags={"single-latest": "a"})
        api.green("b", own=["single-executable.yml"])
        api.green("c", own=["single-executable.yml"])
        for r in api.runs:
            if r["head_sha"] == sha("c") and r["path"].endswith("macos-arm64.yml"):
                r.update(status="in_progress", conclusion=None)
        self.gate(api)
        self.assertIn(("single-executable.yml", "main", {"release": sha("b")}), api.dispatched)

    def test_tag_already_there_or_later(self):
        api = self.api(tags={"single-latest": "c", "icy-tower-windows-latest": "d"})
        api.green("c", own=["single-executable.yml", "icy-tower-windows.yml"])
        api.green("b", own=["single-executable.yml", "icy-tower-windows.yml"])
        self.gate(api)
        self.assertEqual(api.dispatched, [])

    def test_no_tag_yet(self):
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        self.gate(api)
        self.assertEqual(api.dispatched, [("single-executable.yml", "main", {"release": sha("b")})])

    def test_never_twice(self):
        api = self.api(tags={"single-latest": "a"})
        api.green("b", own=["single-executable.yml"])
        api.run("single-executable.yml", "d", event="workflow_dispatch", status="queued",
                title="release " + sha("b"))
        _, lines = self.gate(api)
        self.assertEqual(api.dispatched, [])
        self.assertTrue(any("exists" in l for l in lines), lines)
        # a failed release run is left to a person
        api.runs[-1].update(status="completed", conclusion="failure")
        self.gate(api)
        self.assertEqual(api.dispatched, [])

    def test_dry_run_dispatches_nothing(self):
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        done, lines = self.gate(api, dry=True)
        self.assertEqual(api.dispatched, [])
        self.assertEqual(done, [("single-executable", "main", sha("b"))])
        self.assertTrue(any("would dispatch" in l for l in lines))

    def test_only_tests_yml_push_runs_on_main_are_candidates(self):
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        for r in api.runs:
            if r["path"].endswith("/tests.yml"):
                r["head_branch"] = "topic"
        self.gate(api)
        self.assertEqual(api.dispatched, [])

    # the tagged release

    def mac(self, run_conclusion="success", release_job="skipped", status="completed", tag="icy-tower-macos-v1.2.3"):
        api = self.api(tags={tag: "c", "single-latest": "d", "icy-tower-windows-latest": "d"})
        api.green("c")
        api.run("icy-tower-macos.yml", "c", branch=tag, status=status, conclusion=run_conclusion,
                jobs=[("the release's commit: its tests are green", "success"),
                      ("icy-tower (Botlish.app, static SDL3, Cocoa; macOS arm64)", "skipped"),
                      ("release (Developer ID, notarization, Gatekeeper)", release_job),
                      ("publish the GitHub Release", "skipped")])
        return api

    def test_deferred_tag_dispatched_once_green(self):
        api = self.mac()
        self.gate(api)
        self.assertEqual(api.dispatched, [("icy-tower-macos.yml", "icy-tower-macos-v1.2.3", {})])

    def test_deferred_tag_waits_while_not_green(self):
        api = self.mac()
        api.runs = [r for r in api.runs if not r["path"].endswith("windows-x86_64.yml")]
        self.gate(api)
        self.assertEqual(api.dispatched, [])

    def test_tag_left_alone(self):
        for kw, why in (({"status": "in_progress"}, "in progress"),
                        ({"run_conclusion": "failure", "release_job": "failure"}, "not deferred"),
                        ({"run_conclusion": "cancelled"}, "not deferred"),
                        ({"release_job": "success"}, "not deferred")):
            api = self.mac(**kw)
            _, lines = self.gate(api)
            self.assertEqual(api.dispatched, [], kw)
            self.assertTrue(any(why in l for l in lines), (kw, lines))
        api = self.mac()
        api.releases.add("icy-tower-macos-v1.2.3")
        self.gate(api)
        self.assertEqual(api.dispatched, [])

    def test_tag_without_runs_left_alone(self):
        api = self.api(tags={"icy-tower-macos-v0.1.0": "c"})
        api.green("c")
        self.gate(api)
        self.assertEqual(api.dispatched, [])


class Prune(unittest.TestCase):
    def api(self):
        parents, heads = linear("a", "b", "m", branches={
            "merged": ("a", ["x1"]), "ahead": ("b", ["y1"]), "same": ("m", []), "fresh": ("m", ["z1"])})
        parents["m"] = ["b", "x1"]          # main merged `merged`
        heads["same"] = "m"
        return FakeApi(parents, heads, tags={"icy-tower-macos-v1.0.0": "b"})

    def prune(self, api, dry=False):
        lines, out = quiet()
        return runs.prune(api, dry, out), lines

    def test_cancels_runs_of_branches_in_main(self):
        api = self.api()
        keep, gone = [], []
        for status in runs.UNFINISHED:
            gone.append(api.run("tests.yml", "x1", branch="merged", status=status)["id"])
        gone.append(api.run("macos-arm64.yml", "a", branch="merged", status="queued")["id"])   # an older commit
        gone.append(api.run("tests.yml", "m", branch="same", event="workflow_dispatch", status="queued")["id"])
        gone.append(api.run("tests.yml", "x1", branch="merged", event="pull_request", status="queued")["id"])
        keep.append(api.run("tests.yml", "y1", branch="ahead", status="queued")["id"])
        keep.append(api.run("tests.yml", "z1", branch="fresh", status="queued")["id"])          # strictly ahead of main
        keep.append(api.run("tests.yml", "m", branch="fresh", status="queued")["id"])           # main's commit, on a live branch
        keep.append(api.run("tests.yml", "b", branch="ahead", status="queued")["id"])          # an older commit of a live branch
        keep.append(api.run("tests.yml", "b", branch="main", status="queued")["id"])           # a stale run of main
        keep.append(api.run("icy-tower-macos.yml", "b", branch="icy-tower-macos-v1.0.0", status="queued")["id"])
        keep.append(api.run("tests.yml", "x1", branch="merged", event="pull_request", status="queued",
                            repo="someone/fork")["id"])
        api.run("tests.yml", "x1", branch="merged")                                            # finished
        done, _ = self.prune(api)
        self.assertEqual(sorted(api.cancelled), sorted(gone))
        self.assertEqual(sorted(i for i, _ in done), sorted(gone))
        self.assertFalse(set(keep) & set(api.cancelled))

    def test_deleted_branch(self):
        api = self.api()
        gone = api.run("tests.yml", "x1", branch="deleted-after-merge", status="queued")["id"]
        keep = api.run("tests.yml", "y1", branch="deleted-unmerged", status="queued")["id"]
        self.prune(api)
        self.assertEqual(api.cancelled, [gone])
        self.assertNotIn(keep, api.cancelled)

    def test_dry_run_and_errors(self):
        api = self.api()
        a = api.run("tests.yml", "x1", branch="merged", status="queued")["id"]
        b = api.run("windows-x86_64.yml", "x1", branch="merged", status="queued")["id"]
        done, lines = self.prune(api, dry=True)
        self.assertEqual(api.cancelled, [])
        self.assertEqual(len(done), 2)
        api.fail_cancel.add(a)
        done, lines = self.prune(api)
        self.assertEqual(api.cancelled, [b])
        self.assertTrue(any("could not cancel run %d" % a in l for l in lines), lines)


class CommandLine(unittest.TestCase):
    def test_check_outputs(self):
        api = FakeApi(*linear("a", "b"))
        api.green("b", own=["single-executable.yml"])
        with tempfile.TemporaryDirectory() as d:
            outp, summ = os.path.join(d, "out"), os.path.join(d, "summary")
            os.environ["GITHUB_OUTPUT"], os.environ["GITHUB_STEP_SUMMARY"] = outp, summ
            try:
                lines, out = quiet()
                self.assertEqual(runs.main(["check", sha("b"), "--for", "single-executable", "--require"], api, out), 0)
                build = [r for r in api.runs if r["path"].endswith("single-executable.yml")][0]
                self.assertEqual(read(outp), "green=true\nrun_id=%d\n" % build["id"])
                self.assertIn("| tests.yml (GC-stress jobs succeeded) | green |", read(summ))
                os.remove(outp)
                self.assertEqual(runs.main(["check", sha("a"), "--for", "single-executable"], api, out), 0)
                self.assertEqual(read(outp), "green=false\nrun_id=\n")
                self.assertEqual(runs.main(["check", sha("a"), "--for", "single-executable", "--require"], api, out), 1)
                self.assertEqual(runs.main(["check", "HEAD", "--for", "single-executable"], api, out), 2)
            finally:
                del os.environ["GITHUB_OUTPUT"], os.environ["GITHUB_STEP_SUMMARY"]


class FakeResponse(io.BytesIO):
    def __enter__(self):
        return self

    def __exit__(self, *a):
        self.close()


class Requests(unittest.TestCase):
    def setUp(self):
        self.requests = []
        self.answers = []

    def urlopen(self, req, timeout=None):
        self.requests.append(req)
        code, body = self.answers.pop(0)
        if code >= 400:
            raise urllib.error.HTTPError(req.full_url, code, "error", {}, io.BytesIO(json.dumps(body).encode()))
        return FakeResponse(json.dumps(body).encode() if body is not None else b"")

    def api(self):
        return runs.Api("t0ken", REPO, "https://api.example/", urlopen=self.urlopen)

    def test_get_and_headers(self):
        self.answers = [(200, {"status": "behind"})]
        self.assertEqual(self.api().compare("main", "a" * 40), "behind")
        req = self.requests[0]
        self.assertEqual(req.full_url, "https://api.example/repos/owner/repo/compare/main...%s?per_page=1" % ("a" * 40))
        self.assertEqual(req.get_header("Authorization"), "Bearer t0ken")
        self.assertEqual(req.get_method(), "GET")

    def test_missing_and_errors(self):
        self.answers = [(404, {"message": "Not Found"}), (404, {"message": "Not Found"}), (500, {"message": "boom"})]
        api = self.api()
        self.assertIsNone(api.ref_sha("heads/claude/some-branch"))
        self.assertTrue(self.requests[0].full_url.endswith("/git/ref/heads/claude/some-branch"))
        self.assertFalse(api.release_exists("single-latest"))
        with self.assertRaises(runs.ApiError):
            api.jobs(7)

    def test_annotated_tag_and_paging(self):
        self.answers = [(200, {"object": {"type": "tag", "sha": "t" * 40}}),
                        (200, {"object": {"type": "commit", "sha": "c" * 40}})]
        self.assertEqual(self.api().ref_sha("tags/icy-tower-macos-v1.0.0"), "c" * 40)
        self.answers = [(200, {"workflow_runs": [{"id": i} for i in range(100)]}),
                        (200, {"workflow_runs": [{"id": 100}]})]
        self.assertEqual(len(self.api().runs_at("a" * 40)), 101)
        self.assertIn("head_sha=" + "a" * 40, self.requests[-1].full_url)
        self.assertIn("page=2", self.requests[-1].full_url)

    def test_posts(self):
        self.answers = [(204, None), (202, {})]
        api = self.api()
        api.dispatch("single-executable.yml", "main", {"release": "b" * 40})
        api.cancel(42)
        d, c = self.requests
        self.assertEqual(d.get_method(), "POST")
        self.assertTrue(d.full_url.endswith("/actions/workflows/single-executable.yml/dispatches"))
        self.assertEqual(json.loads(d.data), {"ref": "main", "inputs": {"release": "b" * 40}})
        self.assertTrue(c.full_url.endswith("/actions/runs/42/cancel"))

    def test_log_follows_its_redirect_without_the_token(self):
        hops = []

        def first_hop(req, timeout=None):
            hops.append(req)
            raise urllib.error.HTTPError(req.full_url, 302, "Found", {"Location": "https://blob.example/log?sig=x"},
                                         io.BytesIO(b""))
        self.answers = []
        seen = []

        def urlopen(req, timeout=None):
            seen.append(req)
            return FakeResponse("2026-11-01T00:00:00Z a.test\n".encode())
        api = runs.Api("t0ken", REPO, "https://api.example/", urlopen=urlopen, first_hop=first_hop)
        self.assertEqual(api.log(9), "2026-11-01T00:00:00Z a.test\n")
        self.assertEqual(hops[0].full_url, "https://api.example/repos/owner/repo/actions/jobs/9/logs")
        self.assertEqual(hops[0].get_header("Authorization"), "Bearer t0ken")
        self.assertEqual(seen[0].full_url, "https://blob.example/log?sig=x")
        self.assertIsNone(seen[0].get_header("Authorization"))

        def missing(req, timeout=None):
            raise urllib.error.HTTPError(req.full_url, 410, "Gone", {}, io.BytesIO(b""))
        with self.assertRaises(runs.ApiError):
            runs.Api("t0ken", REPO, first_hop=missing).log(9)

    def test_refuses_without_token_or_repository(self):
        with self.assertRaises(runs.ApiError):
            runs.Api("", REPO)
        with self.assertRaises(runs.ApiError):
            runs.Api("t", "not a repository")


# --- the canary's records (history.py) -------------------------------------------------


def stamped(text, start="2026-11-01T10:00:00Z"):
    """GitHub's log prefix on every line, a second apart."""
    out = []
    for i, line in enumerate(text.strip("\n").split("\n")):
        out.append("2026-11-01T10:%02d:%02d.5000000Z %s" % (i // 60, i % 60, line))
    return "\n".join(out) + "\n"


TCLTEST_LOG = stamped("""
######## backend: interp
abi-bytes.test
affine.test
==== af-one the first FAILED
==== Contents of test case:
==== af-one FAILED
==== af-two FAILED
coroutines.test
all.tcl:\tTotal\t10\tPassed\t7\tSkipped\t0\tFailed\t3
Files with failing tests: affine.test coroutines.test
Test files exiting with errors:  enums.test
""")

GOLDEN_LOG = stamped("""
lists.bot          interp             3 passed, 0 failed
loops.bot          cranelift          2 passed, 1 failed
traits.bot         compile            ABORTED
enums.bot: BACKENDS DISAGREE
== mutable-vector.bot: COMPILE ERROR
DISAGREE: tests/hashable.test hb-1 -> hashable.bot hb-1: old fail, new pass
DISAGREE: tests/lists.test l-1 -> lists.bot l-1: old pass, new fail
DISAGREE: tests/abi.test a-1 -> abi.bot a-1: old skip, new no-verdict
TCL TEST FAILED: tests/maps.test m-7
SUITE NOT OK: fold-loops.bot timeout
Golden suites, wall seconds per suite (compile once, run on interp, compile, cranelift-generic, cranelift):
    lists.bot                                           12.5   ok
    loops.bot                                            3.0   failed
    total                                               15.5 (elapsed 9.0 with 2 jobs)
""")


class History(unittest.TestCase):
    def test_failures_of_the_test_runners(self):
        self.assertEqual(history.failures(TCLTEST_LOG), {
            "tests/affine.test": "af-one", "tests/coroutines.test": "a test failed",
            "tests/enums.test": "did not complete"})
        self.assertEqual(history.failures(GOLDEN_LOG), {
            "tests/golden/loops.bot": "cranelift: 1 failed", "tests/golden/traits.bot": "compile: aborted",
            "tests/golden/enums.bot": "backends disagree", "tests/golden/mutable-vector.bot": "compile error",
            "tests/hashable.test": "hb-1", "tests/golden/lists.bot": "l-1", "tests/maps.test": "m-7",
            "tests/golden/fold-loops.bot": "timeout"})
        self.assertEqual(history.failures("ok\nnothing failed here\n"), {})

    def test_hosts_from_labels(self):
        cases = {"ubuntu-latest": "linux-x86_64", "ubuntu-24.04-arm": "linux-aarch64",
                 "macos-15": "macos-aarch64", "windows-2025": "windows-x86_64", "self-hosted": None}
        for label, host in cases.items():
            self.assertEqual(history.host_of({"labels": [label]}), host, label)

    def test_durations_from_the_logs(self):
        self.assertEqual(history.file_durations(TCLTEST_LOG),
                         {"tests/abi-bytes.test": 1.0, "tests/affine.test": 5.0, "tests/coroutines.test": 1.0})
        self.assertEqual(history.suite_durations(GOLDEN_LOG),
                         {"tests/golden/lists.bot": 12.5, "tests/golden/loops.bot": 3.0})

    def api(self):
        api = FakeApi(*linear("a", "b", "c", "d"))
        fail = lambda files: stamped("Files with failing tests: %s" % files)  # noqa: E731
        api.run("tests.yml", "a", conclusion="failure", created="2026-10-01T00:00:00Z",
                jobs=[("tests (interp)", "failure", None, fail("old.test"))])
        api.run("tests.yml", "b", conclusion="failure", created="2026-10-20T00:00:00Z",
                jobs=[("tests (interp)", "failure", None, fail("affine.test")),
                      ("tests (compile)", "failure", None, fail("affine.test lists.test gone.test")),
                      ("tests (rust)", "success", None, fail("never.test"))])
        api.run("tests.yml", "b", conclusion="failure", created="2026-10-20T01:00:00Z",
                jobs=[("tests (interp)", "failure", None, fail("affine.test"))])
        api.run("tests-arm64.yml", "c", conclusion="failure", created="2026-10-25T00:00:00Z",
                jobs=[("arm64 tests (interp)", "failure", ["ubuntu-24.04-arm"], fail("affine.test lists.test"))])
        # A layer that broke as a whole says nothing about its items.
        api.run("tests-arm64.yml", "c", conclusion="failure", created="2026-10-25T02:00:00Z",
                jobs=[("arm64 golden suites (shard 1/4)", "failure", ["ubuntu-24.04-arm"],
                       fail(" ".join("x%d.test" % i for i in range(history.BROKEN + 1))))])
        # A run that succeeded failed nothing (a job allowed to fail).
        api.run("tests-arm64.yml", "c", conclusion="success", created="2026-10-26T00:00:00Z",
                jobs=[("arm64 probe", "failure", ["ubuntu-24.04-arm"], fail("loops.test"))])
        api.run("macos-arm64.yml", "c", conclusion="failure", created="2026-10-25T00:00:00Z",
                jobs=[("acceptance", "failure", ["macos-15"], fail("affine.test")),
                      ("linux control", "failure", ["ubuntu-latest"], fail("loops.test"))])
        api.run("windows-x86_64.yml", "d", conclusion="failure", created="2026-10-30T00:00:00Z",
                jobs=[("smoke", "failure", ["windows-2025"], stamped("""
affine.test
==== af-9 FAILED
Files with failing tests: affine.test"""))])
        api.run("tests.yml", "d", branch="topic", conclusion="failure", created="2026-10-30T00:00:00Z",
                jobs=[("tests (interp)", "failure", None, fail("branch.test"))])
        api.run("tests.yml", "d", conclusion="success", created="2026-10-31T00:00:00Z",
                jobs=[("tests (interp)", "success", None, TCLTEST_LOG),
                      ("golden suites (Botlish-native tests, shard 1/4)", "success", None, GOLDEN_LOG)])
        return api

    def test_history_counts_commits_per_item(self):
        import datetime
        today = datetime.datetime(2026, 11, 5, tzinfo=datetime.timezone.utc)
        rows = history.history(self.api(), 21, today)
        self.assertEqual(rows, [
            ("tests/affine.test", "*", 3, "2026-10-30", "af-9"),
            ("tests/lists.test", "linux-x86_64,linux-aarch64", 2, "2026-10-25", "a test failed"),
            ("tests/loops.test", "linux-x86_64", 1, "2026-10-25", "a test failed"),
            ("tests/gone.test", "linux-x86_64", 1, "2026-10-20", "a test failed"),
        ])

    def test_render_keeps_existing_items(self):
        import datetime
        today = datetime.datetime(2026, 11, 5, tzinfo=datetime.timezone.utc)
        api = self.api()
        text = history.render(history.history(api, 21, today), history.durations(api), 21, today)
        body = [line.split("\t") for line in text.splitlines() if line and not line.startswith("#")]
        self.assertEqual(body[0], ["history", "tests/affine.test", "*", "3", "2026-10-30", "af-9"])
        items = [b[1] for b in body]
        self.assertIn("tests/lists.test", items)
        self.assertNotIn("tests/abi-bytes.test", [b[1] for b in body if b[0] == "history"])
        for b in body:
            self.assertTrue(os.path.isfile(os.path.join(ROOT, b[1])), b)
            self.assertEqual(len(b), 6 if b[0] == "history" else 3, b)
        self.assertIn(["duration", "tests/golden/loops.bot", "3.0"], body)
        self.assertNotIn("tests/golden/lists.bot", items, "no such suite")
        self.assertNotIn("tests/gone.test", items, "no such file")
        self.assertIn("# tools/ci/history.py", text)


# --- the workflows' side ---------------------------------------------------------------

try:
    import yaml
except ImportError:  # the logic's tests run without it
    yaml = None


def workflow(name):
    with open(os.path.join(ROOT, ".github", "workflows", name)) as f:
        return yaml.safe_load(f)


def all_workflows():
    d = os.path.join(ROOT, ".github", "workflows")
    return {n: workflow(n) for n in sorted(os.listdir(d)) if n.endswith(".yml")}


def triggers(w):
    on = w.get(True, w.get("on"))
    return on if isinstance(on, dict) else {k: None for k in ([on] if isinstance(on, str) else on)}


RELEASE_RUN_NAME = "${{ inputs.release && format('release {0}', inputs.release) || '' }}"
# Workflows whose runs are never cancelled by a newer one: a writer whose
# commit back to main must not be cut off, census probes whose every run is
# evidence, the release gate (each run sees the state as it is).
NEVER_CANCELLED = {"scalar-asm-audit.yml", "react-native-probe.yml", "release-gate.yml"}
# Workflows in no concurrency group: the pruning, whose waiting run a newer
# one must never replace (under a full pool it would never get a runner).
NO_GROUP = {"prune-runs.yml"}


@unittest.skipIf(yaml is None, "PyYAML is not installed")
class Workflows(unittest.TestCase):
    def test_superseded_runs_are_cancelled_main_included(self):
        for name, w in all_workflows().items():
            on = triggers(w)
            if not ({"push", "pull_request"} & set(on)):
                continue
            c = w.get("concurrency")
            if name in NO_GROUP:
                self.assertIsNone(c, "%s: a newer run would replace one waiting for a runner" % name)
                continue
            self.assertIsInstance(c, dict, "%s has no concurrency group" % name)
            if name in NEVER_CANCELLED:
                continue
            cancel = c.get("cancel-in-progress")
            self.assertNotIn("refs/heads/main", str(cancel), "%s keeps main's superseded runs" % name)
            self.assertTrue(cancel is True or (isinstance(cancel, str) and cancel.startswith("${{")),
                            "%s: cancel-in-progress is %r" % (name, cancel))

    def test_release_workflows(self):
        for release in (SE, WIN):
            w = workflow(release.workflow)
            self.assertEqual(w.get("run-name"), RELEASE_RUN_NAME, release.workflow)
            self.assertIn("release", triggers(w)["workflow_dispatch"]["inputs"])
            c = w["concurrency"]
            self.assertIn("inputs.release", c["group"], "a release run is in a group of its own")
            self.assertEqual(c["cancel-in-progress"], "${{ !inputs.release }}", "a release run is never cancelled")
            jobs = w["jobs"]
            writers = [n for n, j in jobs.items() if (j.get("permissions") or {}).get("contents") == "write"]
            self.assertEqual(writers, ["release"], release.workflow)
            # the release check runs before anything is downloaded or published
            checked = False
            for n in self.chain(jobs, "release"):
                steps = jobs[n].get("steps", [])
                for st in steps:
                    body = st.get("run") or ""
                    if "tools/ci/runs.py check" in body:
                        self.assertIn('--for %s --require' % release.name, body)
                        self.assertIn('"$SHA"', body)
                        checked = True
                    if "download-artifact" in (st.get("uses") or "") or "gh release" in body:
                        self.assertTrue(checked, "%s: job %s downloads or publishes before the check" % (release.workflow, n))
            self.assertTrue(checked)
            self.assertIn("inputs.release", jobs["release"]["if"])
            self.assertIn("github.ref == 'refs/heads/main'", jobs["release"]["if"])
            # the build and its tests never run in a release run
            for n, j in jobs.items():
                if n not in self.chain(jobs, "release") and "needs" not in j:
                    self.assertIn("!inputs.release", str(j.get("if")), "%s: job %s runs in a release run" % (release.workflow, n))
            # no input is pasted into a script
            for n, j in jobs.items():
                for st in j.get("steps", []):
                    self.assertNotIn("inputs.release", st.get("run") or "", "%s: job %s" % (release.workflow, n))

    @staticmethod
    def chain(jobs, name):
        """name and every job it needs, transitively, in order."""
        out = []

        def visit(n):
            needs = jobs[n].get("needs") or []
            for m in [needs] if isinstance(needs, str) else needs:
                visit(m)
            if n not in out:
                out.append(n)
        visit(name)
        return out

    def test_tagged_release_waits_for_green(self):
        w = workflow(MAC.workflow)
        jobs = w["jobs"]
        tested = jobs["tested"]
        self.assertEqual(tested["permissions"], {"contents": "read", "actions": "read"})
        body = "\n".join(st.get("run") or "" for st in tested["steps"])
        self.assertIn('tools/ci/runs.py check "$GITHUB_SHA" --for icy-tower-macos', body)
        self.assertIn("tested", jobs["release"]["needs"])
        self.assertIn("needs.tested.outputs.green == 'true'", jobs["release"]["if"])
        self.assertIn("needs.tested.outputs.green == 'true'", jobs["game"]["if"])
        self.assertFalse(jobs["tested"]["name"].startswith("release"), "runs.deferred reads the release job by its name")
        self.assertTrue(jobs["release"]["name"].startswith("release"))

    def test_gate_listens_to_every_requirement(self):
        w = workflow("release-gate.yml")
        names = set(triggers(w)["workflow_run"]["workflows"])
        wanted = set()
        for release in runs.RELEASES.values():
            for req in release.requirements():
                wanted.add(workflow(req.workflow)["name"])
        self.assertEqual(names, wanted)
        self.assertEqual(triggers(w)["workflow_run"]["branches"], ["main"])
        self.assertEqual(w["concurrency"], {"group": "release-gate", "cancel-in-progress": False})

    def test_requirements_name_real_jobs(self):
        for req in runs.CORE:
            jobs = workflow(req.workflow)["jobs"]
            for needle in req.jobs:
                self.assertTrue([j for j in jobs.values() if needle in str(j.get("name"))],
                                "%s has no %s job" % (req.workflow, needle))

    # The canary (CI-RUNS.md, "The canary"): which job of each test workflow
    # runs it, and the jobs that need not wait for it.
    CANARY = {
        "tests.yml": ("canary", set()),
        "tests-arm64.yml": ("canary", set()),
        "macos-arm64.yml": ("smoke", {"linux-control", "app-mutants"}),
        "windows-x86_64.yml": ("canary", set()),
    }

    def test_canary_gates_the_test_workflows(self):
        for name, (canary, free) in self.CANARY.items():
            w = workflow(name)
            jobs = w["jobs"]
            self.assertEqual(triggers(w)["push"]["branches"], ["**"], "%s: every branch push runs the canary" % name)
            steps = jobs[canary]["steps"]
            runs_canary = [st for st in steps if "tests/canary.tcl" in (st.get("run") or "")]
            self.assertEqual(len(runs_canary), 1, "%s: job %s runs the canary once" % (name, canary))
            self.assertEqual(runs_canary[0]["run"], 'tclsh9.0 tests/canary.tcl -base "$BASE"', name)
            base = runs_canary[0]["env"]["BASE"]
            self.assertIn("github.event.before", base, "%s: a push to main is compared with main's previous head" % name)
            self.assertIn("origin/main", base, name)
            checkout = [st for st in steps if (st.get("uses") or "").startswith("actions/checkout")]
            self.assertEqual(checkout[0].get("with", {}).get("fetch-depth"), 0, "%s: the canary needs the history" % name)
            for n in jobs:
                if n == canary or n in free:
                    continue
                self.assertIn(canary, self.chain(jobs, n), "%s: job %s does not wait for the canary" % (name, n))
                if_ = str(jobs[n].get("if"))
                # A job that runs whatever its needs' results checks the canary's itself.
                if "always()" in if_ or "!cancelled()" in if_:
                    self.assertTrue("needs.%s.result" % canary in if_, "%s: job %s runs after a failed canary" % (name, n))

    def test_cheap_gates_are_steps_of_the_canary(self):
        # Steps, not jobs: a job of its own waits for a runner before the
        # expensive jobs may start (close to an hour with the pool full).
        steps = workflow("tests.yml")["jobs"]["canary"]["steps"]
        runs = [st.get("run") or "" for st in steps]
        for command in ("tclsh9.0 tools/mutant-catalogs.tcl", "tclsh9.0 audit/refactor/tools/gate.tcl"):
            at = [i for i, r in enumerate(runs) if r.startswith(command)]
            self.assertEqual(len(at), 1, command)
            canary = [i for i, r in enumerate(runs) if "tests/canary.tcl" in r][0]
            self.assertLess(at[0], canary, "%s runs before the canary" % command)
        first = min(i for i, r in enumerate(runs) if "mutant-catalogs.tcl" in r or "gate.tcl" in r)
        for st in steps[first + 1:]:
            self.assertIn("!cancelled()", str(st.get("if")), "step %s must run whatever an earlier gate found" % st.get("name"))

    def test_branch_pushes_run_only_the_canary_on_linux(self):
        for name in ("tests.yml", "tests-arm64.yml"):
            jobs = workflow(name)["jobs"]
            canary, free = self.CANARY[name]
            for n, j in jobs.items():
                if n == canary or n in free:
                    continue
                self.assertIn("github.ref == 'refs/heads/main'", str(j.get("if")), "%s: job %s runs on a branch push" % (name, n))
                if "GC-stress" in j["name"]:
                    self.assertIn("github.event_name == 'push' && github.ref == 'refs/heads/main'", j["if"], name)
                    self.assertNotIn("!= 'pull_request'", j["if"], "%s: GC stress on a branch push" % name)

    def test_only_housekeeping_cancels_or_dispatches(self):
        for name, w in all_workflows().items():
            for n, j in w.get("jobs", {}).items():
                if (j.get("permissions") or {}).get("actions") == "write":
                    self.assertIn(name, ("prune-runs.yml", "release-gate.yml"), "%s: job %s" % (name, n))


if __name__ == "__main__":
    unittest.main()
