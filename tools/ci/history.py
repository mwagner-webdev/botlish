#!/usr/bin/env python3
"""history.py -- the canary's records (CI-RUNS.md, "The canary"): which test
files and golden suites failed in recent CI runs of main, on which hosts,
and how long each takes.

    python3 -I tools/ci/history.py [--days N] [--write]

Reads, through the REST API (runs.py's token and repository), the pushes to
main of the four test workflows (tests.yml, tests-arm64.yml,
macos-arm64.yml, windows-x86_64.yml) created in the last N days (default
21), and for every failed one the logs of its failed jobs: the test files
and golden suites the test runners report failing there (tests/all.tcl's
and tests/platform/tier.tcl's summaries, the golden runner's, the golden
check's). An item is counted once per commit it failed at, on the host its
job ran on (the runner's label). A job that reports more than BROKEN items
is left out: a whole layer broke there, for one cause any item of it shows
(on 2026-10-16 every arm64 golden shard reported 23 to 30 suites failing, at
five commits; a job otherwise reports one or two). Then the durations: each test file's
seconds in the newest successful push run of tests.yml on main (the
`tests (interp)` job, between the lines that start the files) and each
golden suite's (the golden shards' per-suite seconds, all four backends).
Last the costs: each item's seconds in the acceptance tier of each host
that runs one (tests/platform/tier.tcl on macOS and Windows), from the
acceptance jobs of the newest successful push run on main of the host's
workflow -- a test file's between the lines that start the files, a golden
suite's between the lines its predecessor and it print. tier.tcl balances
its shards by them (CI-RUNS.md, "The canary").

It prints tests/canary.tsv (--write writes it): the history lines, the most
failing first, of the items that still exist in this checkout, then the
duration lines, then the cost lines. Deterministic for a given API state. tests/canary.tcl reads
the file; tools/ci/test_runs.py tests this with a fake of the API.
"""
import argparse
import datetime
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
import runs  # noqa: E402

WORKFLOWS = ("tests.yml", "tests-arm64.yml", "macos-arm64.yml", "windows-x86_64.yml")
HOSTS = ("linux-x86_64", "linux-aarch64", "macos-aarch64", "windows-x86_64")
# The hosts whose workflow runs tests/platform/tier.tcl's acceptance tier in
# shards (jobs named "acceptance ..."): the workflow and the host target.
ACCEPTANCE = (("macos-arm64.yml", "macos-aarch64"), ("windows-x86_64.yml", "windows-x86_64"))
BROKEN = 5
STAMP = re.compile(r"^(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d+)?Z) ?")


def host_of(job):
    """The host target a job ran on, from its runner's labels."""
    labels = " ".join(job.get("labels") or [])
    if "macos" in labels:
        return "macos-aarch64"
    if "windows" in labels:
        return "windows-x86_64"
    if "ubuntu" in labels:
        return "linux-aarch64" if "-arm" in labels else "linux-x86_64"
    return None


def lines_of(text):
    """(timestamp or None, line) of a job log, GitHub's prefix taken off."""
    for raw in text.splitlines():
        m = STAMP.match(raw)
        yield (m.group(1) if m else None), (raw[m.end():] if m else raw).rstrip("\r")


def failures(text):
    """{item: reason} of what a job's log reports failing: tests/X.test and
    tests/golden/X.bot paths, each with its first failing test (or what
    failed)."""
    found = {}
    first = {}
    current = None

    def add(item, reason):
        found.setdefault(item, reason)

    for _, line in lines_of(text):
        m = re.match(r"^([\w.+-]+\.test)$", line)
        if m:
            current = m.group(1)
            continue
        m = re.match(r"^==== (\S+) .*FAILED$", line) or re.match(r"^==== (\S+) FAILED$", line)
        if m and current and not m.group(1).startswith("Contents"):
            first.setdefault(current, m.group(1))
            continue
        m = re.match(r"^(Files with failing tests|Test files exiting with errors):\s*(.*)$", line)
        if m:
            for f in m.group(2).split():
                if f.endswith(".test"):
                    reason = first.get(f, "did not complete" if m.group(1).startswith("Test files") else "a test failed")
                    add("tests/" + os.path.basename(f), reason)
            continue
        m = re.match(r"^TCL TEST FAILED: (tests/[\w.+-]+\.test) (\S+)", line)
        if m:
            add(m.group(1), m.group(2))
            continue
        m = re.match(r"^DISAGREE: (tests/[\w.+-]+\.test) (\S+) -> ([\w.+-]+\.bot) (\S+): old (\S+), new (\S+)$", line)
        if m:
            if m.group(5) == "fail":
                add(m.group(1), m.group(2))
            if m.group(6) == "fail":
                add("tests/golden/" + m.group(3), m.group(4))
            continue
        m = (re.match(r"^([\w.+-]+\.bot)\s+(\S+)\s+(?:\d+ passed, ([1-9]\d*) failed|(ABORTED))", line)
             or re.match(r"^(?:== )?([\w.+-]+\.bot): (BACKENDS DISAGREE|COMPILE ERROR)", line)
             or re.match(r"^SUITE NOT OK: ([\w.+-]+\.bot) (\S+)", line))
        if m:
            g = m.groups()
            if len(g) == 4:
                reason = "%s: %s" % (g[1], "aborted" if g[3] else "%s failed" % g[2])
            else:
                reason = g[1].lower()
            add("tests/golden/" + g[0], reason)
    return found


def seconds_between(a, b):
    def t(s):
        return datetime.datetime.strptime(s[:19], "%Y-%m-%dT%H:%M:%S").replace(tzinfo=datetime.timezone.utc).timestamp() \
            + float("0" + s[19:-1] if "." in s else 0)
    return t(b) - t(a)


def file_durations(text):
    """{tests/X.test: seconds} from a tests/all.tcl log: the time from the
    line that starts a file to the next timestamped line that starts one
    (or ends the run)."""
    out = {}
    current = None
    last = None
    for stamp, line in lines_of(text):
        starts = re.match(r"^([\w.+-]+\.test)$", line)
        ends = line.startswith("all.tcl:") or line.startswith("Sourced ")
        if (starts or ends) and current and stamp:
            out["tests/" + current[0]] = round(max(seconds_between(current[1], stamp), 0.0), 1)
            current = None
        if starts and stamp:
            current = (starts.group(1), stamp)
        if stamp:
            last = stamp
    if current and last:
        out["tests/" + current[0]] = round(max(seconds_between(current[1], last), 0.0), 1)
    return out


def suite_durations(text):
    """{tests/golden/X.bot: seconds} from the golden check's per-suite
    table (audit/golden/tools/check.tcl)."""
    out = {}
    within = False
    for _, line in lines_of(text):
        if line.startswith("Golden suites, wall seconds per suite"):
            within = True
            continue
        m = re.match(r"^\s+([\w.+-]+\.bot)\s+([\d.]+)\b", line)
        if within and m:
            out["tests/golden/" + m.group(1)] = float(m.group(2))
        elif within and not line.startswith(" "):
            within = False
    return out


def tier_suite_durations(text):
    """{tests/golden/X.bot: seconds} from tests/platform/tier.tcl's golden
    phase (tests/golden/run.tcl -quiet): a suite prints its lines when it
    has run, so its seconds run from the previous suite's lines (or the
    phase's start) to its own first line."""
    out = {}
    start = None
    current = None
    for stamp, line in lines_of(text):
        if re.match(r"^######## \d+ golden suites on \S+$", line):
            start, current = stamp, None
            continue
        if start is None or not stamp:
            continue
        if re.match(r"^######## \d+ ", line):
            # The phase's verdict, or the next phase (the line under the
            # phase's start echoes its command).
            start = None
            continue
        m = re.match(r"^(?:== )?([\w.+-]+\.bot)(?::|\s)", line)
        if m and m.group(1) != current:
            out["tests/golden/" + m.group(1)] = round(max(seconds_between(start, stamp), 0.0), 1)
            start, current = stamp, m.group(1)
    return out


def history(api, days, today, out=lambda line: None):
    """[(item, hosts, commits, last, reason)], the most failing first."""
    since = (today - datetime.timedelta(days=days)).strftime("%Y-%m-%d")
    seen = {}
    for workflow in WORKFLOWS:
        runs_ = api.workflow_runs(workflow, pages=5, branch="main", event="push", status="completed",
                                  created=">=" + since)
        for r in sorted(runs_, key=lambda r: r["id"]):
            if r.get("conclusion") != "failure":
                continue
            date = (r.get("created_at") or "")[:10]
            for job in api.jobs(r["id"]):
                if job.get("conclusion") != "failure":
                    continue
                host = host_of(job)
                if not host:
                    continue
                try:
                    text = api.log(job["id"])
                except runs.ApiError as e:
                    out("history: %s: %s" % (job.get("name"), e))
                    continue
                found = failures(text)
                if len(found) > BROKEN:
                    out("history: %s at %s: %d items failed, a whole layer: left out"
                        % (job.get("name"), r["head_sha"][:12], len(found)))
                    continue
                for item, reason in found.items():
                    e = seen.setdefault(item, {"hosts": set(), "commits": set(), "last": "", "reason": ""})
                    e["hosts"].add(host)
                    e["commits"].add(r["head_sha"])
                    if date >= e["last"]:
                        e["last"], e["reason"] = date, reason
    rows = []
    for item, e in seen.items():
        hosts = "*" if e["hosts"] == set(HOSTS) else ",".join(h for h in HOSTS if h in e["hosts"])
        rows.append((item, hosts, len(e["commits"]), e["last"], e["reason"]))
    rows.sort(key=lambda r: (-r[2], -int(r[3].replace("-", "") or 0), r[0]))
    return rows


def durations(api, out=lambda line: None):
    """{item: seconds} of the newest successful push run of tests.yml on
    main."""
    for r in api.workflow_runs("tests.yml", branch="main", event="push", status="success", per_page=5):
        found = {}
        for job in api.jobs(r["id"]):
            name = job.get("name") or ""
            if job.get("conclusion") != "success":
                continue
            if name == "tests (interp)":
                found.update(file_durations(api.log(job["id"])))
            elif name.startswith("golden suites"):
                found.update(suite_durations(api.log(job["id"])))
        if found:
            out("history: durations from %s" % runs.link(api, r))
            return found
    return {}


def costs(api, out=lambda line: None):
    """{host: {item: seconds}}: for each host of ACCEPTANCE, its items'
    seconds in the acceptance jobs of the newest successful push run on main
    of its workflow whose acceptance jobs all succeeded."""
    found = {}
    for workflow, host in ACCEPTANCE:
        for r in api.workflow_runs(workflow, branch="main", event="push", status="success", per_page=10):
            jobs = [j for j in api.jobs(r["id"]) if (j.get("name") or "").startswith("acceptance")]
            if not jobs or any(j.get("conclusion") != "success" for j in jobs):
                continue
            items = {}
            for job in jobs:
                text = api.log(job["id"])
                items.update(file_durations(text))
                items.update(tier_suite_durations(text))
            if items:
                out("history: %s costs from %s" % (host, runs.link(api, r)))
                found[host] = items
                break
    return found


def clean(text):
    """A reason as one field of a tab-separated line."""
    return re.sub(r"\s+", " ", text).strip() or "-"


def render(rows, seconds, days, today, root=ROOT, costs=None):
    exists = lambda item: os.path.isfile(os.path.join(root, item))  # noqa: E731
    lines = [
        "# canary.tsv -- the canary's records (CI-RUNS.md, \"The canary\"), written by",
        "# tools/ci/history.py from the pushes to main of the four test workflows in",
        "# the %d days before %s. tests/canary.tcl reads it." % (days, today.strftime("%Y-%m-%d")),
        "#",
        "# history ITEM HOSTS COMMITS LAST REASON: ITEM (a test file or golden suite)",
        "# failed in CI at COMMITS commits of main, on HOSTS (comma-separated host",
        "# targets, * for all four), last on LAST, with REASON (its first failing",
        "# test then). The canary runs these after what a push changes, the most",
        "# failing first.",
        "#",
        "# duration ITEM SECONDS: ITEM's wall seconds on linux-x86_64 (a Tcl test",
        "# file on interp, a golden suite on all four backends), the canary's",
        "# estimate of its cost; an item without one is estimated from its size.",
        "#",
        "# cost HOST ITEM SECONDS: ITEM's wall seconds in HOST's acceptance tier",
        "# (tests/platform/tier.tcl: a Tcl test file on interp, a golden suite on",
        "# all four backends), by which tier.tcl balances its shards on HOST; an",
        "# item without one costs its duration's estimate.",
        "",
    ]
    for item, hosts, commits, last, reason in rows:
        if exists(item):
            lines.append("\t".join(["history", item, hosts, str(commits), last, clean(reason)]))
    lines.append("")
    for item in sorted(seconds):
        if exists(item):
            lines.append("\t".join(["duration", item, "%.1f" % seconds[item]]))
    for host in sorted(costs or {}):
        lines.append("")
        for item in sorted(costs[host]):
            if exists(item):
                lines.append("\t".join(["cost", host, item, "%.1f" % costs[host][item]]))
    return "\n".join(lines) + "\n"


def main(argv, api=None, out=print, today=None):
    p = argparse.ArgumentParser(prog="history.py", description="the canary's records (tests/canary.tsv)")
    p.add_argument("--days", type=int, default=21)
    p.add_argument("--write", action="store_true", help="write tests/canary.tsv instead of printing it")
    a = p.parse_args(argv)
    today = today or datetime.datetime.now(datetime.timezone.utc)
    if api is None:
        try:
            api = runs.Api(os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN"),
                           os.environ.get("GITHUB_REPOSITORY"),
                           os.environ.get("GITHUB_API_URL") or "https://api.github.com")
        except runs.ApiError as e:
            print("history.py: %s" % e, file=sys.stderr)
            return 2
    text = render(history(api, a.days, today, out), durations(api, out), a.days, today, costs=costs(api, out))
    if a.write:
        with open(os.path.join(ROOT, "tests", "canary.tsv"), "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:], out=lambda line: print(line, file=sys.stderr)))
