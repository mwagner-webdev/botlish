"""The census's fixtures: definition, materialization and loading.

Hand-written fixtures are defined in fixtures/*.py, each a module calling
F(...) (pure data: Python string literals express every byte sequence the
corpus needs, CR, NUL, a BOM or invalid UTF-8 included). `corpus.py build`
materializes them into fixtures/corpus.jsonl -- one JSON object per fixture
with its exact bytes (hex), its SHA-256 and its static safety
classification -- which is what every other tool reads. `corpus.py check`
fails when corpus.jsonl is not what the definitions produce.

A fixture:

  id           stable identifier, [a-z0-9-]+, unique across corpora
  category     the feature-matrix row it belongs to (README.md, "Feature matrix")
  description  what it probes, in one sentence
  data         the exact bytes (str is encoded as UTF-8)
  intended     the assignments its author means, where a meaning is intended
               (the portable-emission checks compare targets with it); None
               means "no single intended meaning" (most syntax probes)
  modes        the environment modes it runs in (default both)
  trusted      commands Ruby may run for it in the trusted configuration
  tags         free-form labels (for reports)
"""

import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common  # noqa: E402
import safety  # noqa: E402

FIXTURES = common.AUDIT / "fixtures"
GENERATED = common.AUDIT / "generated"
ID = re.compile(r"[a-z0-9][a-z0-9.-]*")

_collected = []


def F(id, category, description, data, intended=None, modes=("clean", "conflict"), trusted=(), tags=()):
    _collected.append(dict(id=id, category=category, description=description, data=data,
                           intended=intended, modes=list(modes), trusted=list(trusted), tags=list(tags)))


def record(fx):
    data = fx["data"].encode("utf-8") if isinstance(fx["data"], str) else bytes(fx["data"])
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        text = None
    r = {
        "id": fx["id"], "category": fx["category"], "description": fx["description"],
        "hex": data.hex(), "text": text, "sha256": hashlib.sha256(data).hexdigest(), "size": len(data),
        "intended": fx.get("intended"), "modes": fx.get("modes") or ["clean", "conflict"],
        "trusted": fx.get("trusted") or [], "tags": fx.get("tags") or [],
        "safety": safety.classify(data),
    }
    for k in ("source", "origin"):
        if k in fx:
            r[k] = fx[k]
    return r


def definitions():
    _collected.clear()
    for path in sorted(FIXTURES.glob("*.py")):
        spec = importlib.util.spec_from_file_location("fixtures_" + path.stem, path)
        mod = importlib.util.module_from_spec(spec)
        mod.F = F
        spec.loader.exec_module(mod)
    out = list(_collected)
    _collected.clear()
    return out


def build_records():
    recs = [record(fx) for fx in definitions()]
    seen = set()
    for r in recs:
        if not ID.fullmatch(r["id"]):
            raise SystemExit("bad fixture id %r" % r["id"])
        if r["id"] in seen:
            raise SystemExit("duplicate fixture id %r" % r["id"])
        seen.add(r["id"])
    return recs


def write_jsonl(recs, path):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        for r in recs:
            f.write(json.dumps(r, ensure_ascii=True, sort_keys=True) + "\n")


def read_jsonl(path):
    with open(path, encoding="utf-8") as f:
        return [json.loads(line) for line in f if line.strip()]


def load(name):
    """A corpus by name: hand (fixtures/corpus.jsonl), generated, minimized,
    realworld, portable -- or a path."""
    paths = {
        "hand": FIXTURES / "corpus.jsonl",
        "generated": GENERATED / "corpus.jsonl",
        "minimized": GENERATED / "minimized.jsonl",
        "portable": common.RESULTS / "portable" / "corpus.jsonl",
    }
    p = paths.get(name) or Path(name)
    return read_jsonl(p)


def data_of(r):
    return bytes.fromhex(r["hex"])


def main(argv):
    cmd = argv[0] if argv else "build"
    recs = build_records()
    target = FIXTURES / "corpus.jsonl"
    if cmd == "build":
        write_jsonl(recs, target)
        cats = {}
        for r in recs:
            cats[r["category"]] = cats.get(r["category"], 0) + 1
        print("fixtures/corpus.jsonl: %d fixtures in %d categories" % (len(recs), len(cats)))
        for c, n in sorted(cats.items()):
            print("  %-14s %d" % (c, n))
    elif cmd == "check":
        want = "".join(json.dumps(r, ensure_ascii=True, sort_keys=True) + "\n" for r in recs)
        have = target.read_text(encoding="utf-8") if target.exists() else ""
        if want != have:
            raise SystemExit("fixtures/corpus.jsonl is stale: run tools/corpus.py build")
        print("fixtures/corpus.jsonl is current (%d fixtures)" % len(recs))
    elif cmd == "show":
        for r in recs:
            if r["id"] in argv[1:]:
                print(json.dumps(r, indent=1, ensure_ascii=False))
    else:
        raise SystemExit("usage: corpus.py build|check|show ID...")


if __name__ == "__main__":
    main(sys.argv[1:])
