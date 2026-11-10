#!/usr/bin/env python3
"""test_runs.py -- tests of tools/ci/runs.py and tools/ci/history.py
(CI-RUNS.md):

    python3 -I tools/ci/test_runs.py [-v]

The release check, the gate, the pruning and a branch push's deferral to
a run that already tests its commit against a fake of the GitHub API over
a small commit graph; the canary's records (history.py) from runs and job
logs of the fake; the requests themselves against a fake urlopen; and,
when PyYAML is installed, the workflows' side of the rules
(.github/workflows/: every test workflow cancels a superseded run, main's
included; a release is published only by a release run, after the check;
no job asks for the concurrency group its own run holds; the gate listens
to every workflow a release waits for; every test workflow's expensive
jobs wait for its canary, a branch push runs only the canary and the jobs
its message opts into, and every job a branch push runs defers with it).
"""
import io
import itertools
import json
import os
import re
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
                n, c, labels, log, steps = (tuple(job) + (None, None, None))[:5]
                self.next_id += 1
                self.jobs_[r["id"]].append({"id": self.next_id, "name": n, "status": "completed", "conclusion": c,
                                            "labels": labels or ["ubuntu-latest"],
                                            "steps": [{"name": k, "status": "completed", "conclusion": v}
                                                      for k, v in (steps or {}).items()]})
                self.logs[self.next_id] = log or ""
        return r

    def green(self, commit, gc="success", own=()):
        """Every CORE workflow green at commit (GC-stress jobs `gc`)."""
        self.run("tests.yml", commit, jobs=[("tests (interp)", "success"),
                                            ("tests (native GC-stress, interp)", gc),
                                            ("tests (native GC-stress, compile)", gc)])
        self.run("tests-arm64.yml", commit, jobs=[("arm64 tests (interp)", "success"),
                                                  ("arm64 tests (native GC-stress, interp)", gc),
                                                  ("arm64 tests (native GC-stress, compile)", gc)])
        self.run("macos-arm64.yml", commit, jobs=full_jobs("macos-arm64.yml"))
        self.run("windows-x86_64.yml", commit, jobs=full_jobs("windows-x86_64.yml"))
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


def full_jobs(workflow, acceptance="success"):
    """The jobs of a macOS or Windows run that ran its acceptance tier
    (main's push runs, dispatched runs; never a branch push's)."""
    host = {"macos-arm64.yml": "Tier B, macOS arm64", "windows-x86_64.yml": "Windows x86-64"}[workflow]
    canary = "smoke (Tier A, macOS arm64)" if workflow == "macos-arm64.yml" else "canary (Windows x86-64, MSVC)"
    return [(canary, "success", None, None, {"Canary": "success"})] + \
        [("acceptance (%s, shard %d/4)" % (host, i), acceptance) for i in (1, 2, 3, 4)]


def canary_jobs(workflow, canary="success"):
    """The jobs of a branch push's run: the canary job alone, its canary
    step `canary` (skipped: the run deferred to another)."""
    name = {"tests.yml": "canary (linux x86-64)", "tests-arm64.yml": "canary (linux arm64)",
            "macos-arm64.yml": "smoke (Tier A, macOS arm64)",
            "windows-x86_64.yml": "canary (Windows x86-64, MSVC)"}[workflow]
    return [(name, "success", None, None, {"Already tested at this commit?": "success", runs.CANARY_STEP: canary})]


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
        api.run("tests.yml", "b", jobs=[("tests (native GC-stress, interp)", "success")])
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
        self.assertIn("pending", [s for w, s, _ in v.lines if w.split()[0] == "windows-x86_64.yml"])
        api.runs[-1].update(status="completed", conclusion="failure")
        v = runs.check(api, sha("b"), SE)
        self.assertIn("failed", [s for w, s, _ in v.lines if w.split()[0] == "windows-x86_64.yml"])
        api.run("windows-x86_64.yml", "b", conclusion="cancelled")
        self.assertFalse(runs.check(api, sha("b"), SE).green)
        api.run("windows-x86_64.yml", "b", jobs=full_jobs("windows-x86_64.yml"))
        self.assertTrue(runs.check(api, sha("b"), SE).green, "a later successful attempt counts")

    def test_acceptance_required_on_macos_and_windows(self):
        # A branch push runs only the canary, and a deferred run nothing: a
        # successful run counts only with its acceptance tier, which every
        # run of main and every dispatched run has (CI-RUNS.md).
        for workflow in ("macos-arm64.yml", "windows-x86_64.yml"):
            api = self.api()
            api.green("b", own=["single-executable.yml"])
            api.runs = [r for r in api.runs if not r["path"].endswith(workflow)]
            api.run(workflow, "b", branch="topic", jobs=canary_jobs(workflow))
            api.run(workflow, "b", branch="other", jobs=canary_jobs(workflow, canary="skipped"))
            v = runs.check(api, sha("b"), SE)
            self.assertFalse(v.green, workflow)
            self.assertIn((workflow + " (acceptance jobs succeeded)", "failed"), [(w, s) for w, s, _ in v.lines])
            api.run(workflow, "b", jobs=full_jobs(workflow, acceptance="skipped"))
            self.assertFalse(runs.check(api, sha("b"), SE).green, "%s: a skipped acceptance shard" % workflow)
            api.run(workflow, "b", branch="topic", event="workflow_dispatch", jobs=full_jobs(workflow))
            self.assertTrue(runs.check(api, sha("b"), SE).green, "%s: a dispatched run counts" % workflow)

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
        # a dispatched run on a branch at the commit main later reached
        # tests the same tree
        api = self.api()
        api.green("b", own=["single-executable.yml"])
        api.runs = [r for r in api.runs if not r["path"].endswith("macos-arm64.yml")]
        api.run("macos-arm64.yml", "b", branch="topic", event="workflow_dispatch", jobs=full_jobs("macos-arm64.yml"))
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


class Twin(unittest.TestCase):
    """A branch push defers to a run that already tests its commit
    (CI-RUNS.md, "A commit already tested")."""

    def api(self):
        return FakeApi(*linear("a", "b", branches={"topic": ("b", ["t1"])}))

    def twin(self, api, commit="b", ref="refs/heads/topic", event="push", workflow="macos-arm64.yml", me=None):
        if me is None:
            me = api.run(workflow, commit, branch=ref.split("/", 2)[-1], event=event, status="in_progress")["id"]
        return runs.twin(api, workflow, me, sha(commit), ref, event)

    def test_defers_to_mains_unfinished_or_successful_run(self):
        for status, conclusion in (("queued", None), ("in_progress", None), ("completed", "success")):
            api = self.api()
            main = api.run("macos-arm64.yml", "b", status=status, conclusion=conclusion)
            found, why = self.twin(api)
            self.assertEqual(found and found["id"], main["id"], status)
            self.assertIn("main's push run", why)

    def test_mains_failed_or_cancelled_run_is_no_twin(self):
        for conclusion in ("failure", "cancelled"):
            api = self.api()
            api.run("macos-arm64.yml", "b", conclusion=conclusion)
            found, why = self.twin(api)
            self.assertIsNone(found, conclusion)
            self.assertEqual(why, "no other run tests this commit")

    def test_another_branch_counts_once_green_and_tested(self):
        api = self.api()
        unfinished = api.run("macos-arm64.yml", "b", branch="other", status="in_progress")
        self.assertIsNone(self.twin(api)[0], "its own next push may cancel it")
        unfinished.update(status="completed", conclusion="failure")
        self.assertIsNone(self.twin(api)[0], "a failed run")
        api.run("macos-arm64.yml", "b", branch="third", jobs=canary_jobs("macos-arm64.yml", canary="skipped"))
        self.assertIsNone(self.twin(api)[0], "a deferred run tested nothing")
        tested = api.run("macos-arm64.yml", "b", branch="other", jobs=canary_jobs("macos-arm64.yml"))
        found, why = self.twin(api)
        self.assertEqual(found["id"], tested["id"])
        self.assertIn("other's push run", why)

    def test_main_preferred(self):
        api = self.api()
        api.run("macos-arm64.yml", "b", branch="other", jobs=canary_jobs("macos-arm64.yml"))
        main = api.run("macos-arm64.yml", "b", status="queued")
        self.assertEqual(self.twin(api)[0]["id"], main["id"])

    def test_only_the_same_workflow_commit_and_kind(self):
        api = self.api()
        api.run("windows-x86_64.yml", "b", status="queued")                    # another workflow
        api.run("macos-arm64.yml", "a", status="queued")                        # another commit
        api.run("macos-arm64.yml", "b", event="workflow_dispatch", jobs=full_jobs("macos-arm64.yml"))
        api.run("macos-arm64.yml", "b", event="pull_request", status="queued")  # not a push
        api.run("macos-arm64.yml", "b", status="queued", repo="fork/repo")     # not ours
        self.assertIsNone(self.twin(api)[0])

    def test_another_commits_run_is_no_twin(self):
        # whatever the API's filter returns, a run at another commit
        api = self.api()
        api.run("macos-arm64.yml", "a", status="queued")
        api.runs_at = lambda s: list(api.runs)
        self.assertIsNone(self.twin(api)[0])

    def test_never_itself(self):
        api = self.api()
        me = api.run("macos-arm64.yml", "b", branch="topic", jobs=canary_jobs("macos-arm64.yml"))
        self.assertIsNone(self.twin(api, me=me["id"])[0], "a re-run attempt of a run is no twin of it")

    def test_who_never_defers(self):
        api = self.api()
        api.run("macos-arm64.yml", "b", status="queued")
        api.run("macos-arm64.yml", "b", branch="other", jobs=canary_jobs("macos-arm64.yml"))
        for ref, event, why in (("refs/heads/main", "push", "a push to main never defers"),
                                ("refs/heads/topic", "workflow_dispatch", "a workflow_dispatch run never defers"),
                                ("refs/pull/7/merge", "pull_request", "a pull_request run never defers"),
                                ("refs/tags/v1", "push", "refs/tags/v1 is no branch")):
            found, got = self.twin(api, ref=ref, event=event)
            self.assertIsNone(found, (ref, event))
            self.assertTrue(got.startswith(why), got)

    def test_workflow_file(self):
        self.assertEqual(runs.workflow_file("o/r/.github/workflows/tests-arm64.yml@refs/heads/main"), "tests-arm64.yml")
        self.assertEqual(runs.workflow_file(""), "")

    def command(self, api, env, *argv):
        """Runs the twin command with the GITHUB_* variables `env`, the API
        `api` (an exception: every call of it fails so); returns its outputs,
        its summary and its lines."""
        def make_api():
            if isinstance(api, Exception):
                raise api
            return api
        lines, out = quiet()
        with tempfile.TemporaryDirectory() as d:
            outp, summ = os.path.join(d, "out"), os.path.join(d, "summary")
            saved = {k: os.environ.get(k) for k in ("GITHUB_OUTPUT", "GITHUB_STEP_SUMMARY")}
            os.environ["GITHUB_OUTPUT"], os.environ["GITHUB_STEP_SUMMARY"] = outp, summ
            try:
                runs.twin_command(runs.parser().parse_args(["twin"] + list(argv)), make_api, out, env)
                return (read(outp) if os.path.exists(outp) else ""), (read(summ) if os.path.exists(summ) else ""), lines
            finally:
                for k, v in saved.items():
                    if v is None:
                        os.environ.pop(k, None)
                    else:
                        os.environ[k] = v

    def env(self, api, commit="b", ref="refs/heads/topic", event="push"):
        me = api.run("tests.yml", commit, branch=ref.split("/", 2)[-1], status="in_progress")
        return {"GITHUB_WORKFLOW_REF": "%s/.github/workflows/tests.yml@%s" % (REPO, ref),
                "GITHUB_RUN_ID": str(me["id"]), "GITHUB_SHA": sha(commit), "GITHUB_REF": ref,
                "GITHUB_EVENT_NAME": event}

    def test_command_outputs(self):
        api = self.api()
        main = api.run("tests.yml", "b", status="in_progress")
        outputs, summary, lines = self.command(api, self.env(api))
        self.assertEqual(outputs, "deferred=true\nrun=%s\n" % main["html_url"])
        self.assertIn("### Deferred: commit %s is tested by %s" % (sha("b"), main["html_url"]), summary)
        self.assertIn("This run tested nothing", summary)
        self.assertTrue(any("deferred to" in l for l in lines), lines)
        # not deferred: the outputs say so, the summary says nothing
        outputs, summary, _ = self.command(api, self.env(api, commit="a"))
        self.assertEqual((outputs, summary), ("deferred=false\nrun=\n", ""))

    def test_command_never_defers_on_errors(self):
        api = self.api()
        api.run("tests.yml", "b", status="in_progress")
        env = self.env(api)
        outputs, _, lines = self.command(runs.ApiError("HTTP 502"), env)
        self.assertEqual(outputs, "deferred=false\nrun=\n")
        self.assertTrue(any(l.startswith("::warning") and "HTTP 502" in l for l in lines), lines)
        broken = self.api()
        broken.runs_at = lambda s: [{"path": ".github/workflows/tests.yml", "event": "push"}]  # no id
        outputs, _, lines = self.command(broken, env)
        self.assertEqual(outputs, "deferred=false\nrun=\n")
        # main's push asks nothing of the API
        outputs, _, _ = self.command(runs.ApiError("not asked"), self.env(api, ref="refs/heads/main"))
        self.assertEqual(outputs, "deferred=false\nrun=\n")

    def test_command_dry_run(self):
        api = self.api()
        api.heads["main"] = sha("b")
        api.run("tests.yml", "b", status="queued")
        outputs, summary, lines = self.command(api, {}, "--dry-run", "--workflow", "tests.yml", "--sha", "main",
                                               "--ref", "refs/heads/a-branch", "--event", "push", "--run-id", "0")
        self.assertEqual((outputs, summary), ("", ""))
        self.assertTrue(any("would defer" in l for l in lines), lines)


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


# A shard of tests/platform/tier.tcl's acceptance tier: its Tcl phase (one
# tests/all.tcl run), then its golden phase (tests/golden/run.tcl -quiet,
# which prints a suite's lines when the suite has run), a line a second.
TIER_LOG = stamped("""
######## 2 Tcl test files on interp
######## CORE_BACKEND=interp tclsh9.0 tests/all.tcl -tmpdir T -file affine.test lists.test
affine.test
++++ af-1 PASSED
lists.test
all.tcl:\tTotal\t9\tPassed\t9\tSkipped\t0\tFailed\t0
Sourced 2 Test Files.
######## 2 Tcl test files on interp: ok (5.0 s)

######## 3 golden suites on interp,compile,cranelift-generic,cranelift
########  tclsh9.0 tests/golden/run.tcl -quiet -backends interp,compile,cranelift-generic,cranelift
== abi-numeric-native.bot: not run on this host (needs linux-x86_64) -- a live syscall
types.bot                    interp     3 passed, 0 failed (compile 1.00s, run 0.10s)
types.bot                    compile    3 passed, 0 failed (compile 1.00s, run 0.10s)
types.bot                    cranelift  3 passed, 0 failed (compile 1.00s, run 0.10s)
variadics.bot                interp     2 passed, 0 failed (compile 1.00s, run 0.10s)
######## 3 golden suites on interp,compile,cranelift-generic,cranelift: ok (6.0 s)
######## 2 commands, 0 failed (11.0 s; 2 Tcl test files on interp, 3 golden suites, 0 checks)
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

    def test_tier_durations_from_a_shard_log(self):
        # The Tcl phase as tests/all.tcl's log; the golden phase from the
        # phase's start (its command echoed under it), suite by suite.
        self.assertEqual(history.file_durations(TIER_LOG), {"tests/affine.test": 2.0, "tests/lists.test": 1.0})
        self.assertEqual(history.tier_suite_durations(TIER_LOG), {
            "tests/golden/abi-numeric-native.bot": 2.0, "tests/golden/types.bot": 1.0,
            "tests/golden/variadics.bot": 3.0})
        self.assertEqual(history.tier_suite_durations(GOLDEN_LOG), {}, "no tier golden phase")

    def test_costs_from_the_newest_run_whose_acceptance_succeeded(self):
        api = FakeApi(*linear("a", "b", "c", "d"))
        shard = lambda c, log="": ("acceptance (Tier B, macOS arm64, shard 1/6)", c, ["macos-15"], log)  # noqa: E731
        api.run("macos-arm64.yml", "a", jobs=[shard("success", stamped("affine.test\nall.tcl:\tTotal\t1"))])
        chosen = api.run("macos-arm64.yml", "b", jobs=[shard("success", TIER_LOG),
                                                        ("smoke (Tier A, macOS arm64)", "success", ["macos-15"], "")])
        # Newer runs that do not count: a shard skipped, a branch's, a failed one.
        api.run("macos-arm64.yml", "c", jobs=[shard("skipped"), shard("success", TIER_LOG)])
        api.run("macos-arm64.yml", "d", branch="topic", jobs=[shard("success", stamped("lists.test\nall.tcl:"))])
        api.run("macos-arm64.yml", "d", conclusion="failure", jobs=[shard("failure", TIER_LOG)])
        # A run without its acceptance tier gives no costs.
        api.run("windows-x86_64.yml", "d", jobs=[("canary (Windows x86-64, MSVC)", "success", ["windows-2025"], "")])
        said = []
        found = history.costs(api, said.append)
        self.assertEqual(found, {"macos-aarch64": {
            "tests/affine.test": 2.0, "tests/lists.test": 1.0, "tests/golden/abi-numeric-native.bot": 2.0,
            "tests/golden/types.bot": 1.0, "tests/golden/variadics.bot": 3.0}})
        self.assertEqual(said, ["history: macos-aarch64 costs from %s" % chosen["html_url"]])
        import datetime
        today = datetime.datetime(2026, 11, 5, tzinfo=datetime.timezone.utc)
        found["macos-aarch64"]["tests/gone.test"] = 9.0
        text = history.render([], {}, 21, today, costs=found)
        body = [line.split("\t") for line in text.splitlines() if line and not line.startswith("#")]
        self.assertEqual(body, [
            ["cost", "macos-aarch64", "tests/affine.test", "2.0"],
            ["cost", "macos-aarch64", "tests/golden/abi-numeric-native.bot", "2.0"],
            ["cost", "macos-aarch64", "tests/golden/types.bot", "1.0"],
            ["cost", "macos-aarch64", "tests/golden/variadics.bot", "3.0"],
            ["cost", "macos-aarch64", "tests/lists.test", "1.0"]])
        self.assertIn("# cost HOST ITEM SECONDS", text)

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


# A concurrency group's value in a run, its ${{ }} expressions evaluated as
# GitHub does: string literals, context paths, !, && and || with
# JavaScript's values (a && b || c is b when a and b are truthy, else c).
# An expression it cannot read, or a context it is not given, is an error:
# teach it the form rather than skip the group.
EXPRESSION = re.compile(r"\$\{\{(.*?)\}\}", re.S)
TOKEN = re.compile(r"\s*(?:('(?:[^']|'')*')|(&&|\|\||!|\(|\))|([A-Za-z_][A-Za-z0-9_.-]*))")
KEYWORDS = {"true": True, "false": False, "null": None}


def truthy(v):
    return v not in ("", None, False, 0)


def evaluate(expr, context):
    tokens, pos, expr = [], 0, expr.strip()
    while pos < len(expr):
        m = TOKEN.match(expr, pos)
        if not m:
            raise ValueError("an expression this test cannot read: %r" % expr)
        lit, op, path = m.groups()
        tokens.append(("lit", lit[1:-1].replace("''", "'")) if lit else ("op", op) if op else ("path", path))
        pos = m.end()

    def primary(i):
        kind, v = tokens[i]
        if kind == "lit":
            return v, i + 1
        if kind == "path":
            if v in KEYWORDS:
                return KEYWORDS[v], i + 1
            if v not in context:
                raise ValueError("%s in %r: no such context in this test's runs" % (v, expr))
            return context[v], i + 1
        if v == "!":
            val, i = primary(i + 1)
            return not truthy(val), i
        if v == "(":
            val, i = disjunction(i + 1)
            if tokens[i:i + 1] != [("op", ")")]:
                raise ValueError("unbalanced parentheses in %r" % expr)
            return val, i + 1
        raise ValueError("an expression this test cannot read: %r" % expr)

    def conjunction(i):
        val, i = primary(i)
        while tokens[i:i + 1] == [("op", "&&")]:
            rhs, i = primary(i + 1)
            val = rhs if truthy(val) else val
        return val, i

    def disjunction(i):
        val, i = conjunction(i)
        while tokens[i:i + 1] == [("op", "||")]:
            rhs, i = conjunction(i + 1)
            val = val if truthy(val) else rhs
        return val, i

    val, i = disjunction(0)
    if i != len(tokens):
        raise ValueError("an expression this test cannot read: %r" % expr)
    return val


def group_value(group, context):
    def text(m):
        v = evaluate(m.group(1), context)
        return "true" if v is True else "false" if v is False else "" if v is None else str(v)
    return EXPRESSION.sub(text, group)


def group_of(concurrency):
    return concurrency.get("group") if isinstance(concurrency, dict) else concurrency


def run_contexts(w):
    """A context per kind of run the workflow has: on main, on another
    branch and on a tag, each with every combination of its dispatch
    inputs given and left empty."""
    inputs = ((triggers(w).get("workflow_dispatch") or {}).get("inputs") or {})
    choices = []
    for name, spec in inputs.items():
        kind = (spec or {}).get("type")
        values = (False, True) if kind == "boolean" else \
            tuple(spec.get("options") or ()) if kind == "choice" else ("", "a-value")
        choices.append(["inputs." + name] + list(values))
    for ref in ("refs/heads/main", "refs/heads/a-branch", "refs/tags/a-tag"):
        for combination in itertools.product(*(c[1:] for c in choices)):
            context = {"github.ref": ref}
            context.update({c[0]: v for c, v in zip(choices, combination)})
            yield context


RELEASE_RUN_NAME ="${{ inputs.release && format('release {0}', inputs.release) || '' }}"
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

    def test_group_values(self):
        g = "x-${{ inputs.release && 'release' || github.ref }}"
        self.assertEqual(group_value(g, {"inputs.release": "abc", "github.ref": "refs/heads/main"}), "x-release")
        self.assertEqual(group_value(g, {"inputs.release": "", "github.ref": "refs/heads/main"}), "x-refs/heads/main")
        self.assertEqual(group_value("y-${{ !inputs.dry && 'a' || 'b' }}", {"inputs.dry": True}), "y-b")
        self.assertEqual(group_value("z-${{ (inputs.dry) }}", {"inputs.dry": False}), "z-false")
        self.assertEqual(group_value("q-${{ 'it''s' }}", {}), "q-it's")
        with self.assertRaises(ValueError):
            group_value("${{ github.workflow }}", {"github.ref": "refs/heads/main"})
        with self.assertRaises(ValueError):
            group_value("${{ format('{0}', github.ref) }}", {"github.ref": "refs/heads/main"})

    def test_no_job_waits_for_its_own_run(self):
        """A job in the concurrency group its own run holds waits for the
        run, which waits for the job: GitHub fails the job before it gets a
        runner. Every release run of single-executable.yml and
        icy-tower-windows.yml failed so -- the run in NAME-release, its
        publishing job too -- from the release gate's first dispatch (run
        42208024676) until those jobs got groups of their own."""
        for name, w in all_workflows().items():
            run = group_of(w.get("concurrency"))
            jobs = {n: group_of(j.get("concurrency")) for n, j in (w.get("jobs") or {}).items()}
            jobs = {n: g for n, g in jobs.items() if g}
            if not run or not jobs:
                continue
            for context in run_contexts(w):
                held = group_value(run, context)
                for n, g in jobs.items():
                    self.assertNotEqual(group_value(g, context), held,
                                        "%s: job %s asks for its own run's group %r (a run with %s)"
                                        % (name, n, held, context))

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

    def test_botlish_release_waits_for_green(self):
        """Botlish.app's tagged release (botlish-macos.yml) waits for its commit's tests as the game's does."""
        w = workflow(runs.RELEASES["botlish-macos"].workflow)
        jobs = w["jobs"]
        tested = jobs["tested"]
        self.assertEqual(tested["permissions"], {"contents": "read", "actions": "read"})
        body = "\n".join(st.get("run") or "" for st in tested["steps"])
        self.assertIn('tools/ci/runs.py check "$GITHUB_SHA" --for botlish-macos', body)
        self.assertIn("tested", jobs["release"]["needs"])
        self.assertIn("needs.tested.outputs.green == 'true'", jobs["release"]["if"])
        self.assertFalse(jobs["tested"]["name"].startswith("release"), "runs.deferred reads the release job by its name")
        self.assertTrue(jobs["release"]["name"].startswith("release"))
        self.assertEqual(triggers(w)["push"]["tags"], ["botlish-macos-v*"])
        self.assertNotIn("branches", triggers(w)["push"])
        writers = [n for n, j in jobs.items() if (j.get("permissions") or {}).get("contents") == "write"]
        self.assertEqual(writers, ["publish"])

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

    # What a branch push runs beside its canary job (CI-RUNS.md, "The
    # canary"): macOS's Linux control, and the opt-in jobs its head commit's
    # message asks for (the marker each one's condition reads).
    BRANCH_PUSH = {
        "tests.yml": {},
        "tests-arm64.yml": {},
        "macos-arm64.yml": {"linux-control": None, "full": "[ci-full]", "app-mutants": "[ci-app-mutants]"},
        "windows-x86_64.yml": {"full": "[ci-full]", "roots": "[ci-probes]"},
    }
    NOT_ON_A_BRANCH_PUSH = "github.event_name != 'push' || github.ref == 'refs/heads/main'"

    def test_branch_pushes_run_only_the_canary(self):
        for name, extra in self.BRANCH_PUSH.items():
            jobs = workflow(name)["jobs"]
            canary, _ = self.CANARY[name]
            for n, j in jobs.items():
                if_ = str(j.get("if"))
                if n == canary:
                    self.assertNotIn("refs/heads/main", if_, "%s: a branch push runs its canary" % name)
                    continue
                marker = extra.get(n, False)
                if marker is False:
                    self.assertTrue(self.NOT_ON_A_BRANCH_PUSH in if_
                                    or "github.event_name == 'push' && github.ref == 'refs/heads/main'" in if_,
                                    "%s: job %s runs on a branch push" % (name, n))
                elif marker:
                    self.assertIn("contains(github.event.head_commit.message, '%s')" % marker, if_,
                                  "%s: job %s runs on a branch push unasked" % (name, n))
                if "GC-stress" in j["name"]:
                    self.assertIn("github.event_name == 'push' && github.ref == 'refs/heads/main'", j["if"], name)
                    self.assertNotIn("!= 'pull_request'", j["if"], "%s: GC stress on a branch push" % name)

    TWIN_ACTION = "./.github/actions/twin"
    DEFERRED = "steps.twin.outputs.deferred != 'true'"

    def own_twin(self, name, n, job):
        """The job decides itself whether it defers: the twin step right
        after its checkout, every later step skipped once it defers, and
        the token's actions: read."""
        steps = job["steps"]
        at = [i for i, st in enumerate(steps) if st.get("uses") == self.TWIN_ACTION]
        self.assertEqual(len(at), 1, "%s: job %s has no twin step" % (name, n))
        self.assertEqual(steps[at[0]].get("id"), "twin", name)
        self.assertTrue(steps[at[0] - 1].get("uses", "").startswith("actions/checkout"),
                        "%s: job %s: the twin step comes right after the checkout" % (name, n))
        self.assertNotIn("if", steps[at[0]], name)
        for st in steps[:at[0]]:
            # nothing that tests before it: the checkout, Windows' line ends
            self.assertTrue(st.get("uses", "").startswith("actions/checkout")
                            or st.get("run", "").startswith("git config"),
                            "%s: job %s runs %s before its twin step" % (name, n, st.get("name") or st.get("uses")))
        for st in steps[at[0] + 1:]:
            self.assertIn(self.DEFERRED, str(st.get("if")),
                          "%s: job %s's step %s runs in a deferred run" % (name, n, st.get("name") or st.get("uses")))
        self.assertEqual(job.get("permissions"), {"contents": "read", "actions": "read"}, "%s: job %s" % (name, n))

    def test_a_branch_push_already_tested_defers(self):
        """Every job a branch push runs is deferred with it (CI-RUNS.md, "A
        commit already tested"): the canary job and the jobs that need not
        wait for it decide by their own twin step, the others by the canary
        job's output."""
        for name, extra in self.BRANCH_PUSH.items():
            jobs = workflow(name)["jobs"]
            canary, _ = self.CANARY[name]
            self.own_twin(name, canary, jobs[canary])
            self.assertEqual(jobs[canary]["outputs"]["deferred"], "${{ steps.twin.outputs.deferred }}", name)
            for n in extra:
                if canary in self.chain(jobs, n):
                    self.assertIn("needs.%s.outputs.deferred != 'true'" % canary, str(jobs[n].get("if")),
                                  "%s: job %s runs after a deferred canary" % (name, n))
                else:
                    self.own_twin(name, n, jobs[n])

    def test_twin_action_and_canary_step(self):
        with open(os.path.join(ROOT, ".github", "actions", "twin", "action.yml")) as f:
            action = yaml.safe_load(f)
        steps = action["runs"]["steps"]
        self.assertEqual(len(steps), 1)
        self.assertIn("tools/ci/runs.py twin", steps[0]["run"])
        self.assertEqual(steps[0]["env"], {"GH_TOKEN": "${{ github.token }}"})
        self.assertEqual(action["outputs"]["deferred"]["value"], "${{ steps.decide.outputs.deferred }}")
        # runs.ran_canary reads the canary step by its name
        for name, (canary, _) in self.CANARY.items():
            st = [st for st in workflow(name)["jobs"][canary]["steps"] if "tests/canary.tcl" in (st.get("run") or "")]
            self.assertEqual(st[0].get("name"), runs.CANARY_STEP, name)

    def test_only_housekeeping_cancels_or_dispatches(self):
        for name, w in all_workflows().items():
            for n, j in w.get("jobs", {}).items():
                if (j.get("permissions") or {}).get("actions") == "write":
                    self.assertIn(name, ("prune-runs.yml", "release-gate.yml"), "%s: job %s" % (name, n))


if __name__ == "__main__":
    unittest.main()
