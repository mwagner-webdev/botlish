#!/usr/bin/env python3
"""runs.py -- this repository's GitHub Actions housekeeping (CI-RUNS.md):
the release gate and the pruning of obsolete runs.

    python3 -I tools/ci/runs.py check SHA --for RELEASE [--require]
    python3 -I tools/ci/runs.py gate [--dry-run]
    python3 -I tools/ci/runs.py prune [--dry-run]

check   Whether the tests of commit SHA are green for RELEASE (one of
        RELEASES' names): every workflow of CORE (and the release's own
        build workflow) has a finished, successful run at SHA, and in it
        every job a requirement names (the GC-stress jobs) succeeded rather
        than being skipped; SHA is a commit of main's history. Prints the
        verdict per requirement (also to $GITHUB_STEP_SUMMARY) and writes
        green=true|false and run_id=ID (the release's build run) to
        $GITHUB_OUTPUT. --require exits 1 unless green.

gate    The release gate, run when a test workflow finishes on main: for
        each rolling release, the newest commit of main whose tests are
        green, when its release tag holds an earlier one and no release run
        for it exists yet, is dispatched (a workflow_dispatch of the
        release's workflow on main with input release=SHA); for the tagged
        release, a tag whose every run was deferred (its tests were not
        green yet) and whose commit's tests are green now is dispatched
        again on the tag. It never publishes anything itself.

prune   Cancels the unfinished runs of branches that are fully in main: the
        branch's tip is main's or an ancestor of it (or, the branch
        deleted, the run's commit is). Never a run of main (the workflows'
        concurrency groups supersede those), of a tag, or of a fork.

The token is $GH_TOKEN (or $GITHUB_TOKEN), the repository
$GITHUB_REPOSITORY, the API $GITHUB_API_URL. Nothing here runs a tool or
reads the checkout: only the REST API. tools/ci/test_runs.py tests it with
a fake of the API.
"""
import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

WORKFLOWS = ".github/workflows/"
SHA = re.compile(r"^[0-9a-f]{40}$")
# A release run is a workflow_dispatch whose run-name is this
# (single-executable.yml, icy-tower-windows.yml: `run-name: release SHA`).
RELEASE_RUN = re.compile(r"^release ([0-9a-f]{40})$")
UNFINISHED = ("queued", "in_progress", "waiting", "pending", "requested")


class Requirement:
    """A workflow that must have a successful run at the commit; `jobs`
    are substrings of job names that must each match at least one job of
    that run, and every matching job must have succeeded (a skipped
    GC-stress job, as in a manual run of tests.yml, is no success).
    `optional`: required only when the workflow ran at the commit (its
    paths filter decides whether it does)."""

    def __init__(self, workflow, jobs=(), optional=False):
        self.workflow = workflow
        self.jobs = tuple(jobs)
        self.optional = optional

    def __repr__(self):
        return "Requirement(%r)" % self.workflow


# The tests every release waits for: the four test workflows, each on its
# host, the two GC-stress runs among them, and the front end's
# static-decision comparison when the commit changed what it compares.
CORE = (
    Requirement("tests.yml", jobs=("GC-stress",)),
    Requirement("tests-arm64.yml", jobs=("GC-stress",)),
    Requirement("macos-arm64.yml"),
    Requirement("windows-x86_64.yml"),
    Requirement("static-decisions.yml", optional=True),
)


class Release:
    """A published release. `workflow` publishes it; `built_by`, when set,
    is the workflow whose push run built and tested the artifact the
    release publishes (it is a requirement too, and its run's id is the
    check's run_id). A rolling release moves `tag` to the newest green
    commit of main; a tagged one (`tag_prefix`) publishes each tag once."""

    def __init__(self, name, workflow, tag=None, tag_prefix=None, built_by=None):
        self.name = name
        self.workflow = workflow
        self.tag = tag
        self.tag_prefix = tag_prefix
        self.built_by = built_by

    def requirements(self):
        own = (Requirement(self.built_by),) if self.built_by else ()
        return CORE + own


RELEASES = {
    r.name: r for r in (
        Release("single-executable", "single-executable.yml", tag="single-latest",
                built_by="single-executable.yml"),
        Release("icy-tower-windows", "icy-tower-windows.yml", tag="icy-tower-windows-latest",
                built_by="icy-tower-windows.yml"),
        Release("icy-tower-macos", "icy-tower-macos.yml", tag_prefix="icy-tower-macos-v"),
        # Botlish.app (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md): built,
        # signed and tested by its release run itself, from the tag.
        Release("botlish-macos", "botlish-macos.yml", tag_prefix="botlish-macos-v"),
    )
}


# --- the API ---------------------------------------------------------------------


class ApiError(Exception):
    pass


class Api:
    """The few REST calls the commands make. `urlopen` is replaceable for
    tests of the requests themselves."""

    def __init__(self, token, repo, base="https://api.github.com", urlopen=urllib.request.urlopen,
                 first_hop=None):
        if not token:
            raise ApiError("no token: set GH_TOKEN (or GITHUB_TOKEN)")
        if not re.match(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", repo or ""):
            raise ApiError("no repository: set GITHUB_REPOSITORY to OWNER/NAME (not %r)" % repo)
        self.token = token
        self.repo = repo
        self.base = base.rstrip("/")
        self.urlopen = urlopen
        # A request whose redirect is not followed: a job log's answer is a
        # redirect to storage, which must not be sent the token.
        self.first_hop = first_hop or urllib.request.build_opener(NoRedirect).open

    def headers(self, data=None):
        return {
            "Authorization": "Bearer " + self.token,
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "botlish-ci-runs",
            **({"Content-Type": "application/json"} if data is not None else {}),
        }

    def request(self, method, path, params=None, body=None, missing_ok=False):
        url = "%s/repos/%s%s" % (self.base, self.repo, path)
        if params:
            url += "?" + urllib.parse.urlencode(params)
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(url, data=data, method=method, headers=self.headers(data))
        try:
            with self.urlopen(req, timeout=60) as resp:
                text = resp.read().decode() or "null"
                return json.loads(text)
        except urllib.error.HTTPError as e:
            if missing_ok and e.code == 404:
                return None
            detail = e.read().decode(errors="replace")[:300]
            raise ApiError("%s %s: HTTP %d %s" % (method, path, e.code, detail)) from None

    def get(self, path, missing_ok=False, **params):
        return self.request("GET", path, params=params or None, missing_ok=missing_ok)

    def paged(self, path, key, pages=10, per_page=100, **params):
        out = []
        for page in range(1, pages + 1):
            got = self.get(path, per_page=per_page, page=page, **params)
            items = (got.get(key, []) if isinstance(got, dict) else got) or []
            out.extend(items)
            if len(items) < per_page:
                break
        return out

    # High-level calls: the fake in test_runs.py implements exactly these.

    def runs_at(self, sha):
        """Every run of every workflow at commit sha."""
        return self.paged("/actions/runs", "workflow_runs", pages=5, head_sha=sha)

    def workflow_runs(self, workflow, pages=1, **params):
        """A workflow's runs, newest first (filters: branch, event, status)."""
        return self.paged("/actions/workflows/%s/runs" % workflow, "workflow_runs", pages=pages, **params)

    def unfinished_runs(self):
        seen = {}
        for status in UNFINISHED:
            for r in self.paged("/actions/runs", "workflow_runs", status=status):
                seen.setdefault(r["id"], r)
        return list(seen.values())

    def jobs(self, run_id):
        return self.paged("/actions/runs/%d/jobs" % run_id, "jobs", filter="latest")

    def log(self, job_id):
        """A job's log, as text: GitHub answers with a redirect to storage,
        which is followed without the token."""
        path = "/actions/jobs/%d/logs" % job_id
        req = urllib.request.Request("%s/repos/%s%s" % (self.base, self.repo, path), headers=self.headers())
        try:
            with self.first_hop(req, timeout=60) as resp:
                return resp.read().decode("utf-8", "replace")
        except urllib.error.HTTPError as e:
            location = e.headers.get("Location") if e.code in (301, 302, 303, 307, 308) else None
            if not location:
                raise ApiError("GET %s: HTTP %d" % (path, e.code)) from None
        try:
            with self.urlopen(urllib.request.Request(location, headers={"User-Agent": "botlish-ci-runs"}),
                              timeout=120) as resp:
                return resp.read().decode("utf-8", "replace")
        except urllib.error.HTTPError as e:
            raise ApiError("GET %s (its redirect): HTTP %d" % (path, e.code)) from None

    def compare(self, base, head):
        """GitHub's comparison status of head against base: ahead, behind,
        identical or diverged (None when either is unknown)."""
        got = self.get("/compare/%s...%s" % (quote(base), quote(head)), missing_ok=True, per_page=1)
        return got and got.get("status")

    def ref_sha(self, ref):
        """The commit a ref (heads/NAME, tags/NAME) names, an annotated
        tag dereferenced; None when there is no such ref."""
        got = self.get("/git/ref/%s" % quote(ref, safe="/"), missing_ok=True)
        if not got or not isinstance(got, dict):
            return None
        return self.commit_of(got["object"])

    def commit_of(self, obj):
        while obj["type"] == "tag":
            obj = self.get("/git/tags/%s" % obj["sha"])["object"]
        return obj["sha"]

    def tags(self, prefix):
        """(name, commit) of every tag whose name starts with prefix."""
        got = self.get("/git/matching-refs/tags/%s" % quote(prefix, safe="/")) or []
        return [(ref["ref"][len("refs/tags/"):], self.commit_of(ref["object"])) for ref in got]

    def release_exists(self, tag):
        return self.get("/releases/tags/%s" % quote(tag), missing_ok=True) is not None

    def dispatch(self, workflow, ref, inputs):
        self.request("POST", "/actions/workflows/%s/dispatches" % workflow, body={"ref": ref, "inputs": inputs})

    def cancel(self, run_id):
        self.request("POST", "/actions/runs/%d/cancel" % run_id)


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def quote(s, safe=""):
    return urllib.parse.quote(s, safe=safe)


# --- shared rules ------------------------------------------------------------------


def workflow_of(run):
    path = (run.get("path") or "").split("@", 1)[0]
    return path[len(WORKFLOWS):] if path.startswith(WORKFLOWS) else path


def is_release_run(run):
    return run.get("event") == "workflow_dispatch" and RELEASE_RUN.match(run.get("display_title") or "") is not None


def in_main(api, sha):
    """sha is main's head or one of its ancestors."""
    return api.compare("main", sha) in ("behind", "identical")


def link(api, run):
    return run.get("html_url") or "run %s" % run.get("id")


# --- check ------------------------------------------------------------------------


class Verdict:
    def __init__(self, sha):
        self.sha = sha
        self.lines = []      # (requirement, state, detail)
        self.green = True
        self.run_id = None   # the release's build run

    def add(self, what, state, detail):
        self.lines.append((what, state, detail))
        if state not in ("green", "not run"):
            self.green = False


def requirement_state(api, req, runs):
    """(state, run, detail) of one requirement among the runs at a commit.
    state: green, pending, failed, missing, or (optional) not run."""
    mine = [r for r in runs if workflow_of(r) == req.workflow and not is_release_run(r)]
    if not mine:
        return ("not run", None, "no run at this commit (its paths filter)") if req.optional \
            else ("missing", None, "no run at this commit")
    mine.sort(key=lambda r: r["id"], reverse=True)
    why = []
    for r in mine:
        if r.get("status") != "completed" or r.get("conclusion") != "success":
            continue
        problems = job_problems(api, req, r)
        if not problems:
            return ("green", r, link(api, r))
        why.append("%s: %s" % (link(api, r), "; ".join(problems)))
    unfinished = [r for r in mine if r.get("status") != "completed"]
    if unfinished:
        return ("pending", unfinished[0], "%s is %s" % (link(api, unfinished[0]), unfinished[0].get("status")))
    if not why:
        why = ["%s: %s" % (link(api, r), r.get("conclusion")) for r in mine[:3]]
    return ("failed", mine[0], "; ".join(why))


def job_problems(api, req, run):
    if not req.jobs:
        return []
    jobs = api.jobs(run["id"])
    problems = []
    for needle in req.jobs:
        matching = [j for j in jobs if needle in (j.get("name") or "")]
        if not matching:
            problems.append("no %s job" % needle)
        for j in matching:
            if j.get("conclusion") != "success":
                problems.append("%s %s" % (j.get("name"), j.get("conclusion") or j.get("status")))
    return problems


def check(api, sha, release):
    v = Verdict(sha)
    if in_main(api, sha):
        v.add("in main's history", "green", "")
    else:
        v.add("in main's history", "failed", "not a commit of main")
    runs = api.runs_at(sha)
    for req in release.requirements():
        state, run, detail = requirement_state(api, req, runs)
        what = req.workflow + ("" if not req.jobs else " (%s jobs succeeded)" % ", ".join(req.jobs))
        v.add(what, state, detail)
        if state == "green" and req.workflow == release.built_by:
            v.run_id = run["id"]
    return v


def report(v, release, out, summary=None):
    head = "%s: the tests of %s are %s" % (release.name, v.sha, "green" if v.green else "not green")
    out(head)
    for what, state, detail in v.lines:
        out("  %-9s %s%s" % (state, what, " -- " + detail if detail else ""))
    if summary is not None:
        summary.append("### " + head + "\n\n| requirement | state | |\n|---|---|---|")
        for what, state, detail in v.lines:
            summary.append("| %s | %s | %s |" % (what, state, detail.replace("|", "\\|")))
        summary.append("")


# --- gate -------------------------------------------------------------------------


def gate(api, dry_run, out, summary=None, candidates=20):
    """Dispatches what is due; returns the list of (release, ref, sha)
    it dispatched (or, dry, would)."""
    done = []
    for release in RELEASES.values():
        if release.tag:
            due = rolling_due(api, release, out, summary, candidates)
            if due:
                act(api, dry_run, out, release, "main", {"release": due}, due)
                done.append((release.name, "main", due))
        else:
            for tag, sha in tagged_due(api, release, out, summary):
                act(api, dry_run, out, release, tag, {}, sha)
                done.append((release.name, tag, sha))
    if not done:
        out("gate: nothing to dispatch")
    return done


def act(api, dry_run, out, release, ref, inputs, sha):
    what = "%s on %s for %s" % (release.workflow, ref, sha)
    if dry_run:
        out("gate: would dispatch " + what)
    else:
        api.dispatch(release.workflow, ref, inputs)
        out("gate: dispatched " + what)


def rolling_due(api, release, out, summary, candidates):
    """The commit to release, or None: the newest commit whose tests.yml
    push run on main succeeded and whose every requirement is green, if
    the tag holds an earlier commit and no release run for it exists."""
    held = api.ref_sha("tags/" + release.tag)
    seen = set()
    for run in api.workflow_runs(CORE[0].workflow, branch="main", event="push", status="success",
                                 per_page=candidates):
        sha = run["head_sha"]
        if sha in seen:
            continue
        seen.add(sha)
        if held and (held == sha or api.compare(sha, held) == "ahead"):
            out("gate: %s holds %s, %s or later: nothing newer is green" % (release.tag, held, sha))
            return None
        v = check(api, sha, release)
        if not v.green:
            report(v, release, out)
            continue
        report(v, release, out, summary)
        existing = [r for r in api.workflow_runs(release.workflow, event="workflow_dispatch", per_page=50)
                    if is_release_run(r) and RELEASE_RUN.match(r["display_title"]).group(1) == sha]
        if existing:
            r = existing[0]
            out("gate: %s's release run for %s exists (%s, %s %s): not dispatched again"
                % (release.name, sha, link(api, r), r.get("status"), r.get("conclusion") or ""))
            return None
        return sha
    out("gate: %s: no green commit among main's last %d tested ones" % (release.name, len(seen)))
    return None


def tagged_due(api, release, out, summary):
    """Tags whose release does not exist, whose every run finished
    deferred (successful, its release job skipped: the tests were not green
    when it ran), and whose commit's tests are green now."""
    due = []
    for tag, sha in api.tags(release.tag_prefix):
        if not sha or api.release_exists(tag):
            continue
        runs = api.workflow_runs(release.workflow, branch=tag, per_page=20)
        if not runs:
            continue
        if any(r.get("status") != "completed" for r in runs):
            out("gate: %s has a run in progress: left to it" % tag)
            continue
        if not all(r.get("conclusion") == "success" and deferred(api, r) for r in runs):
            out("gate: %s has a run that was not deferred (it failed, was cancelled or released): left to a person" % tag)
            continue
        v = check(api, sha, release)
        report(v, release, out, summary if v.green else None)
        if v.green:
            due.append((tag, sha))
    return due


def deferred(api, run):
    """The run's release job was skipped (icy-tower-macos.yml: its game
    and release jobs wait for the `tested` job's green; botlish-macos.yml:
    its release job)."""
    jobs = api.jobs(run["id"])
    release = [j for j in jobs if (j.get("name") or "").startswith("release")]
    return bool(release) and all(j.get("conclusion") == "skipped" for j in release)


# --- prune -------------------------------------------------------------------------


def prune(api, dry_run, out):
    """Cancels the unfinished runs of branches fully in main; returns the
    list of (run id, reason)."""
    cancelled = []
    verdicts = {}
    for run in sorted(api.unfinished_runs(), key=lambda r: r["id"]):
        branch = run.get("head_branch") or ""
        repo = (run.get("head_repository") or {}).get("full_name") or ""
        if not branch or branch == "main" or repo.lower() != api.repo.lower():
            continue
        if branch not in verdicts:
            if api.ref_sha("tags/" + branch):
                verdicts[branch] = (False, "a tag's run")
            else:
                tip = api.ref_sha("heads/" + branch)
                verdicts[branch] = (in_main(api, tip), "%s's tip %s is in main" % (branch, tip[:12])) if tip else None
        verdict = verdicts[branch]
        if verdict is None:
            merged = in_main(api, run["head_sha"])
            reason = "%s was deleted and the run's commit %s is in main" % (branch, run["head_sha"][:12])
        else:
            merged, reason = verdict
        if not merged:
            continue
        what = "run %d (%s, %s, %s)" % (run["id"], run.get("name"), run.get("event"), run.get("status"))
        if dry_run:
            out("prune: would cancel %s: %s" % (what, reason))
        else:
            try:
                api.cancel(run["id"])
            except ApiError as e:
                out("prune: could not cancel %s: %s" % (what, e))
                continue
            out("prune: cancelled %s: %s" % (what, reason))
        cancelled.append((run["id"], reason))
    if not cancelled:
        out("prune: nothing to cancel")
    return cancelled


# --- the command line ---------------------------------------------------------------


def github_file(var, lines):
    path = os.environ.get(var)
    if path and lines:
        with open(path, "a") as f:
            f.write("\n".join(lines) + "\n")


def main(argv, api=None, out=print):
    p = argparse.ArgumentParser(prog="runs.py", description=__doc__.split("\n\n")[0])
    sub = p.add_subparsers(dest="command", required=True)
    c = sub.add_parser("check")
    c.add_argument("sha")
    c.add_argument("--for", dest="release", required=True, choices=sorted(RELEASES))
    c.add_argument("--require", action="store_true")
    for name in ("gate", "prune"):
        sub.add_parser(name).add_argument("--dry-run", action="store_true")
    a = p.parse_args(argv)
    if api is None:
        api = Api(os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN"),
                  os.environ.get("GITHUB_REPOSITORY"),
                  os.environ.get("GITHUB_API_URL", "https://api.github.com"))
    summary = []
    if a.command == "check":
        if not SHA.match(a.sha):
            out("check: %r is not a full commit SHA" % a.sha)
            return 2
        release = RELEASES[a.release]
        v = check(api, a.sha, release)
        report(v, release, out, summary)
        github_file("GITHUB_STEP_SUMMARY", summary)
        github_file("GITHUB_OUTPUT", ["green=%s" % ("true" if v.green else "false"),
                                      "run_id=%s" % (v.run_id or "")])
        return 1 if a.require and not v.green else 0
    if a.command == "gate":
        gate(api, a.dry_run, out, summary)
        github_file("GITHUB_STEP_SUMMARY", summary)
        return 0
    prune(api, a.dry_run, out)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except ApiError as e:
        print("runs.py: %s" % e, file=sys.stderr)
        sys.exit(1)
