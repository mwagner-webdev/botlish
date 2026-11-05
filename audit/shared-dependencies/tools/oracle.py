#!/usr/bin/env python3
"""oracle.py -- an independent reference resolver of the application's one
dependency graph (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md), for the fuzzer
(audit/shared-dependencies/tools/fuzz.tcl).

Written from the report's rules, not from pm/graph.tcl:

  * a demand is (name, exact version, who demands it); the application
    demands each of its direct dependencies at its lock; every release that
    is demanded and exists demands each of its dependencies at its lock;
    every demanded release is explored, conflicting or not;
  * a package with demands naming two versions is a conflict (all such
    packages are reported);
  * without conflicts, a demanded release no repository holds is
    unavailable;
  * without either, a package that reaches itself through the dependencies
    of the selected releases is a cycle;
  * otherwise the graph is the selected release of each demanded package,
    and each package's scope is the set of packages its release locks.

    python3 -I oracle.py resolve < UNIVERSE.json     prints the verdict
    python3 -I oracle.py selftest                    checks the oracle

UNIVERSE: {"releases": {"NAME VERSION": {"DEP": "LOCK", ...}, ...},
           "application": {"NAME": "LOCK", ...}}
VERDICT:  {"result": "ok", "selected": {...}, "uses": {...}, "graph": TEXT}
        | {"result": "conflict", "names": [...]}
        | {"result": "unavailable", "release": "NAME VERSION"}
        | {"result": "cycle"}
"""

import json
import sys


def resolve(universe):
    releases = universe["releases"]
    application = universe["application"]
    demands = {}  # name -> set of versions
    explored = set()
    missing = set()
    pending = [(name, version) for name, version in application.items()]
    for name, version in application.items():
        demands.setdefault(name, set()).add(version)
    while pending:
        name, version = pending.pop()
        key = (name, version)
        if key in explored or key in missing:
            continue
        spec = releases.get(f"{name} {version}")
        if spec is None:
            missing.add(key)
            continue
        explored.add(key)
        for dep, lock in spec.items():
            demands.setdefault(dep, set()).add(lock)
            pending.append((dep, lock))
    conflicts = sorted(name for name, versions in demands.items() if len(versions) > 1)
    if conflicts:
        return {"result": "conflict", "names": conflicts}
    selected = {name: next(iter(versions)) for name, versions in demands.items()}
    absent = sorted(f"{name} {version}" for name, version in missing)
    if absent:
        return {"result": "unavailable", "release": absent[0]}
    uses = {name: sorted(releases[f"{name} {version}"].keys()) for name, version in selected.items()}
    # A cycle: a package reachable from itself.
    for start in uses:
        seen = set()
        stack = list(uses[start])
        while stack:
            current = stack.pop()
            if current == start:
                return {"result": "cycle"}
            if current in seen:
                continue
            seen.add(current)
            stack.extend(uses[current])
    lines = ["botlish package graph 1", " ".join(["application"] + sorted(application))]
    for name in sorted(uses):
        lines.append(" ".join(["package", name] + uses[name]))
    return {"result": "ok", "selected": selected, "uses": uses, "graph": "\n".join(lines) + "\n"}


def selftest():
    def check(universe, expected):
        verdict = resolve(universe)
        for key, value in expected.items():
            assert verdict.get(key) == value, (universe, verdict, expected)
    check({"releases": {"x 1.0.0": {}, "a 1.0.0": {"x": "1.0.0"}, "b 1.0.0": {"x": "1.0.0"}},
           "application": {"a": "1.0.0", "b": "1.0.0"}},
          {"result": "ok", "selected": {"a": "1.0.0", "b": "1.0.0", "x": "1.0.0"}})
    check({"releases": {"x 1.0.0": {}, "x 2.0.0": {}, "a 1.0.0": {"x": "1.0.0"}, "b 1.0.0": {"x": "2.0.0"}},
           "application": {"a": "1.0.0", "b": "1.0.0"}},
          {"result": "conflict", "names": ["x"]})
    check({"releases": {"x 1.0.0": {}, "a 1.0.0": {"x": "1.0.0"}},
           "application": {"a": "1.0.0", "x": "2.0.0"}},
          {"result": "conflict", "names": ["x"]})
    check({"releases": {"a 1.0.0": {"x": "1.0.0"}}, "application": {"a": "1.0.0"}},
          {"result": "unavailable", "release": "x 1.0.0"})
    check({"releases": {"a 1.0.0": {"b": "1.0.0"}, "b 1.0.0": {"a": "1.0.0"}}, "application": {"a": "1.0.0"}},
          {"result": "cycle"})
    # A conflicting branch is explored: its own conflicts count too.
    check({"releases": {"a 1.0.0": {"x": "1.0.0"}, "b 1.0.0": {"x": "2.0.0"}, "x 1.0.0": {"y": "1.0.0"},
                        "x 2.0.0": {"y": "2.0.0"}, "y 1.0.0": {}, "y 2.0.0": {}},
           "application": {"a": "1.0.0", "b": "1.0.0"}},
          {"result": "conflict", "names": ["x", "y"]})
    # A conflict outranks an unavailable release.
    check({"releases": {"a 1.0.0": {"x": "1.0.0", "z": "1.0.0"}, "b 1.0.0": {"x": "2.0.0"}},
           "application": {"a": "1.0.0", "b": "1.0.0"}},
          {"result": "conflict", "names": ["x"]})
    print("oracle selftest: ok")


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "selftest":
        selftest()
    elif len(sys.argv) == 2 and sys.argv[1] == "resolve":
        print(json.dumps(resolve(json.load(sys.stdin)), sort_keys=True))
    else:
        sys.exit("usage: oracle.py resolve|selftest")
