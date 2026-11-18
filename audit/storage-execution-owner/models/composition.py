"""composition.py -- a model of how storage requirements compose across
execution owners on one thread (STORAGE-EXECUTION-OWNER-CENSUS-1.md,
section 10). It is modeling, not Botlish behavior: no compiler code runs.

    python3 -I audit/storage-execution-owner/models/composition.py selftest
    python3 -I audit/storage-execution-owner/models/composition.py check [SEEDS] [OWNERS]

An owner is a cooperative execution (a coroutine instance): a sequence of
segments separated by suspension points. Each object it makes has a size, the
segment it is made in and the segment after which it is dead. An object made
and dead in one segment is *segment* storage; one live across a suspension is
*persistent* storage (hir::lifetime's segment verdict, `suspension`).

Per owner the model derives two numbers from its own objects only:

    P = the most bytes live across any one of its suspension points
    S = the most bytes live during any one of its segments (its persistent
        objects then included)

and bounds the thread's peak, under every interleaving of the owners'
segments (one segment runs at a time; the others are suspended), by

    B = max over owners j of ( S_j + sum over owners i != j of P_i )

because while j runs, every other owner is suspended at some suspension
point, holding at most its P. Composition rules this gives (the census's
algebra): sequential work of one owner -> max; owners suspended at once ->
sum of P; segment storage of all owners of one thread -> one max (they never
run at once), which is why a per-thread stack of regions can hold segment
storage and cannot hold persistent storage.

`check` enumerates random owners and interleavings and compares the real
peak (a simulation) with B; it also checks the broken rule B' = max_j S_j (a
single shared stack across suspensions), which must be exceeded by some
interleaving.
"""

import itertools
import random
import sys


def owner_numbers(objects, segments):
    """(P, S) of an owner with SEGMENTS segments and OBJECTS = [(size, made, dead)]."""
    p = 0
    for point in range(segments - 1):  # suspension point after segment `point`
        live = sum(size for size, made, dead in objects if made <= point < dead)
        p = max(p, live)
    s = 0
    for seg in range(segments):
        live = sum(size for size, made, dead in objects if made <= seg <= dead)
        s = max(s, live)
    return p, s


def bound(owners, broken=False):
    nums = [owner_numbers(objs, segs) for objs, segs in owners]
    if broken:
        return max(s for _, s in nums)
    total_p = sum(p for p, _ in nums)
    return max(s + total_p - p for p, s in nums)


def simulate(owners, order):
    """The peak of live bytes when the owners' segments run in ORDER (a
    sequence of owner indexes, each appearing once per segment). An owner
    that has not started holds nothing; one that has finished holds nothing.
    During a segment its objects alive in that segment are counted, as are
    every other owner's objects alive across its current suspension point."""
    progress = [0] * len(owners)  # segments completed per owner
    peak = 0
    for j in order:
        seg = progress[j]
        live = 0
        for i, (objs, segs) in enumerate(owners):
            if i == j:
                live += sum(size for size, made, dead in objs if made <= seg <= dead)
            elif 0 < progress[i] < segs:
                point = progress[i] - 1
                live += sum(size for size, made, dead in objs if made <= point < dead)
        peak = max(peak, live)
        progress[j] += 1
    return peak


def random_owner(rng):
    segs = rng.randint(1, 4)
    objs = []
    for _ in range(rng.randint(0, 5)):
        made = rng.randrange(segs)
        dead = rng.randint(made, segs - 1)
        objs.append((rng.choice([24, 32, 40, 64, 72]), made, dead))
    return objs, segs


def orders(owners, rng, limit=200):
    """Interleavings of the owners' segments (each owner's in order)."""
    seq = [i for i, (_, segs) in enumerate(owners) for _ in range(segs)]
    seen = set()
    for _ in range(limit):
        rng.shuffle(seq)
        key = tuple(seq)
        if key not in seen:
            seen.add(key)
            yield list(seq)


def check(seeds=200, max_owners=4, quiet=False):
    exceeded_broken = 0
    tight = 0
    for seed in range(1, seeds + 1):
        rng = random.Random(seed)
        owners = [random_owner(rng) for _ in range(rng.randint(1, max_owners))]
        b = bound(owners)
        bb = bound(owners, broken=True)
        worst = 0
        for order in orders(owners, rng):
            peak = simulate(owners, order)
            if peak > b:
                raise AssertionError(f"seed {seed}: peak {peak} exceeds the bound {b}: {owners} {order}")
            worst = max(worst, peak)
        if worst > bb:
            exceeded_broken += 1
        if worst == b:
            tight += 1
    if not quiet:
        print(f"composition: {seeds} programs, no interleaving above the bound; "
              f"the bound reached in {tight}; the broken rule (one shared stack) exceeded in {exceeded_broken}")
    return tight, exceeded_broken


def selftest():
    # Two owners, each keeping 40 bytes across its suspension and using 72
    # in a segment (E03's shape): while one runs (72), the other holds 40.
    w = ([(40, 0, 1), (32, 0, 0)], 2)
    assert owner_numbers(*w) == (40, 72)
    assert bound([w, w]) == 112
    assert bound([w, w], broken=True) == 72
    assert simulate([w, w], [0, 1, 0, 1]) == 112
    # Sequential operations of one owner reuse: one owner, many segments, a
    # per-segment object never persists: P = 0, S = the largest segment.
    seq = ([(32, k, k) for k in range(4)], 4)
    assert owner_numbers(*seq) == (0, 32)
    # K concurrent copies of one request: P sums.
    req = ([(40, 0, 1)], 2)
    assert bound([req] * 8) == 8 * 40
    tight, broken = check(seeds=60, quiet=True)
    assert tight > 0 and broken > 0
    print("composition: selftest passed")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "selftest":
        selftest()
    elif len(sys.argv) > 1 and sys.argv[1] == "check":
        seeds = int(sys.argv[2]) if len(sys.argv) > 2 else 200
        owners = int(sys.argv[3]) if len(sys.argv) > 3 else 4
        check(seeds, owners)
    else:
        print(__doc__)
