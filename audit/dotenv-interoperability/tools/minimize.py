"""Minimization of a disagreement: delta debugging (ddmin) over a fixture,
every candidate of a round evaluated in one batch through the implicated
targets.

Two properties are minimized:

  disagree   targets A and B (both observed: neither not-run nor
             adapter-failure) produce different outcomes for the bytes;
             shrinks lines, then characters (bytes when not UTF-8)
  inexact    target T does not read back exactly the intended assignments
             of a structured map [(key, value), ...] written by an emitter;
             shrinks the assignments, then each value's characters

Used as a library by generate.py and portable.py, and from the command line:

  python3 -I tools/minimize.py disagree --corpus C --id ID --targets A,B
"""

import argparse
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import analyze  # noqa: E402
import common  # noqa: E402
import corpus  # noqa: E402
import run  # noqa: E402


class Evaluator:
    """Runs candidate byte strings through targets, caching by content."""

    def __init__(self, targets, mode="clean"):
        self.targets = targets
        self.mode = mode
        self.cache = {}
        self.runs = 0
        self.serial = 0
        self.scratch = tempfile.mkdtemp(prefix="dotenv-minimize-")

    def close(self):
        shutil.rmtree(self.scratch, ignore_errors=True)

    def outcomes(self, datas, targets=None):
        """{data: {target: normalized outcome}} for a list of byte strings,
        cached per (data, target)."""
        targets = list(targets or self.targets)
        for name in targets:
            todo = [d for d in dict.fromkeys(datas) if (d, name) not in self.cache]
            if not todo:
                continue
            self.serial += 1
            recs = [corpus.record(dict(id="m%06d-%d" % (self.serial, i), category="minimize", description="",
                                       data=d, modes=[self.mode])) for i, d in enumerate(todo)]
            sub = tempfile.mkdtemp(dir=self.scratch)
            runner = run.Runner(sub, max(2, os.cpu_count() or 2))
            res = runner.target(common.targets()[name], recs, [self.mode])
            for d, rec in zip(todo, recs):
                self.cache[(d, name)] = res["results"].get(rec["id"], {}).get(self.mode)
            self.runs += len(todo)
            shutil.rmtree(sub, ignore_errors=True)
        return {d: {t: self.cache[(d, t)] for t in targets} for d in datas}


def observed(o):
    return o is not None and o["status"] not in ("not-run", "adapter-failure")


def ddmin(items, test, batch):
    """Classic ddmin; `batch(list_of_candidates)` returns which satisfy the
    property, so a whole round is evaluated at once."""
    n = 2
    while len(items) >= 2:
        size = max(1, len(items) // n)
        chunks = [items[i:i + size] for i in range(0, len(items), size)]
        complements = [sum((c for j, c in enumerate(chunks) if j != i), []) for i in range(len(chunks))]
        cands = chunks + complements
        ok = batch(cands)
        hit = next((c for c, good in zip(cands, ok) if good), None)
        if hit is not None:
            items = hit
            n = 2 if hit in chunks else max(n - 1, 2)
            continue
        if n >= len(items):
            break
        n = min(len(items), n * 2)
    return items


MISSING = object()


def witness(oa, ob):
    """What makes two outcomes differ, as something a smaller file must keep:
    ("value", KEY) -- both accept, KEY's value differs (or KEY is present on
    one side only: ("presence", KEY, in_a, in_b)); or ("status", SA, SB) with
    the accepting side still accepting a key."""
    if oa["status"] == ob["status"] == "ok":
        for k in sorted(set(oa["map"]) | set(ob["map"])):
            va, vb = oa["map"].get(k, MISSING), ob["map"].get(k, MISSING)
            if va is MISSING or vb is MISSING:
                return ("presence", k, va is not MISSING, vb is not MISSING)
            if va != vb:
                return ("value", k)
        return None
    if oa["status"] == ob["status"]:
        return None
    ok = oa if oa["status"] == "ok" else ob
    return ("status", oa["status"], ob["status"], bool(ok.get("map")))


def minimize_disagreement(data, a, b, mode="clean", ev=None):
    """The smallest file (by ddmin over lines, then characters) on which a
    and b still disagree with the same witness."""
    own = ev is None
    ev = ev or Evaluator([a, b], mode)
    try:
        o0 = ev.outcomes([data], [a, b])[data]
        if not (observed(o0[a]) and observed(o0[b])):
            return None
        w0 = witness(o0[a], o0[b])
        if w0 is None:
            return None

        def keeps(o):
            return observed(o[a]) and observed(o[b]) and witness(o[a], o[b]) == w0

        try:
            text = data.decode("utf-8")
            unit_lines = text.splitlines(keepends=True)
            enc = lambda xs: "".join(xs).encode("utf-8")
            chars = lambda d: list(d.decode("utf-8"))
        except UnicodeDecodeError:
            unit_lines = data.splitlines(keepends=True)
            enc = lambda xs: b"".join(xs)
            chars = lambda d: [bytes([x]) for x in d]

        def batch(cands):
            datas = [enc(c) for c in cands]
            outs = ev.outcomes(datas, [a, b])
            return [keeps(outs[d]) for d in datas]

        lines = ddmin(unit_lines, None, batch)
        cur = enc(lines)
        out = enc(ddmin(chars(cur), None, batch))
        return out if keeps(ev.outcomes([out], [a, b])[out]) else cur
    finally:
        if own:
            ev.close()


def minimize_inexact(pairs, target, emit, ev=None, valid=lambda ps: True):
    """Shrinks a map the emitter writes while `target` still misreads it and
    the map stays inside the emitter's domain (`valid`)."""
    own = ev is None
    ev = ev or Evaluator([target])
    try:
        def bad(ps):
            d = emit(ps).encode("utf-8")
            o = ev.outcomes([d], [target])[d][target]
            return observed(o) and not (o["status"] == "ok" and o["map"] == dict(ps))

        def batch_pairs(cands):
            inside = [c for c in cands if valid(c)]
            if len(inside) < len(cands):
                res = dict(zip(map(id, inside), batch_pairs(inside))) if inside else {}
                return [res.get(id(c), False) for c in cands]
            datas = [emit(c).encode("utf-8") for c in cands]
            outs = ev.outcomes(datas, [target])
            return [observed(outs[d][target]) and not (outs[d][target]["status"] == "ok"
                                                        and outs[d][target]["map"] == dict(c))
                    for c, d in zip(cands, datas)]

        if not bad(pairs):
            return None
        pairs = ddmin(list(pairs), None, batch_pairs) if len(pairs) > 1 else list(pairs)
        for i in range(len(pairs)):
            k, v = pairs[i]

            def batch_chars(cands, i=i, k=k):
                trial = []
                for c in cands:
                    p = list(pairs)
                    p[i] = (k, "".join(c))
                    trial.append(p)
                return batch_pairs(trial)

            pairs[i] = (k, "".join(ddmin(list(v), None, batch_chars)))
        return pairs if bad(pairs) else None
    finally:
        if own:
            ev.close()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("prop", choices=["disagree"])
    ap.add_argument("--corpus", default="hand")
    ap.add_argument("--id", required=True)
    ap.add_argument("--targets", required=True)
    ap.add_argument("--mode", default="clean")
    a = ap.parse_args()
    rec = next(r for r in corpus.load(a.corpus) if r["id"] == a.id)
    t1, t2 = a.targets.split(",")
    out = minimize_disagreement(corpus.data_of(rec), t1, t2, a.mode)
    print(json.dumps({"id": a.id, "targets": [t1, t2], "minimal": out.decode("utf-8", "replace") if out else None,
                      "hex": out.hex() if out else None}, ensure_ascii=False))


if __name__ == "__main__":
    main()
