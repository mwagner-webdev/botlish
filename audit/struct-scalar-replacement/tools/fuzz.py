#!/usr/bin/env python3
"""fuzz.py SEED COUNT OUTDIR -- writes COUNT random, well-typed Botlish programs
(OUTDIR/prog-SEED-K.bot) that build, alias, project, merge, pass, return and
store small structs in many combinations, for the differential check
fuzz.tcl (interpreter vs native with struct scalar replacement vs native with
-struct-opt 0, plain and under GC stress). Observation only.

Every program ends in a List of the integers, strings and booleans it
computed and of the side-effect counter, so any change in a value, in
evaluation order or in the number of side effects shows in the output."""
import random, sys, os

SHAPES = {
    'two':   ['a', 'b'],
    'three': ['x', 'y', 'z'],
    'one':   ['p'],
    'four':  ['f', 'g', 'h', 'i'],
    'mixed': ['n', 's'],          # n: int, s: str
}
NAMED = {'Pair': ['left', 'right']}   # named struct, int fields

def gen(rng):
    lines = []
    out = []
    # ---- preamble
    lines.append('counter = mutarray::create(1, 0)')
    lines.append('fn tick(m):\n    n = mutable_array_get(m, 0)\n    mutable_array_set(m, 0, n + 1)\n    n')
    lines.append('struct Pair:\n    left: int\n    right: int')
    def int_expr(ints, depth=0):
        r = rng.random()
        if depth > 1 or r < 0.3 or not ints:
            return str(rng.randint(0, 9)) if (not ints or rng.random() < 0.5) else rng.choice(ints)
        if r < 0.45:
            return 'tick(counter)'
        op = rng.choice(['+', '-', '*'])
        return '(%s %s %s)' % (int_expr(ints, depth + 1), op, int_expr(ints, depth + 1))
    def str_expr(ints):
        return rng.choice(['concat("s", "t")', '"lit"', 'concat(concat("a", "b"), "c")'])
    def field_expr(shape, name, ints):
        if shape == 'mixed' and name == 's':
            return str_expr(ints)
        return int_expr(ints)
    def literal(shape, ints, named=False):
        if named:
            order = ['left', 'right']
            if rng.random() < 0.5: order.reverse()
            return 'Pair {%s}' % ', '.join('%s: %s' % (f, int_expr(ints).replace('tick(counter)', '1')) for f in order)
        names = list(SHAPES[shape])
        if rng.random() < 0.5: rng.shuffle(names)   # written order != slot order
        return '{%s}' % ', '.join('%s: %s' % (f, field_expr(shape, f, ints)) for f in names)
    # ---- functions returning / consuming each shape
    fnret = {}   # shape -> list of function names
    fncons = {}
    for shape in list(SHAPES) + ['Pair']:
        names = SHAPES.get(shape) or NAMED[shape]
        named = shape == 'Pair'
        fnret[shape] = []
        fncons[shape] = []
        for k in range(rng.randint(1, 2)):
            fname = 'make_%s_%d' % (shape, k)
            lit = lambda: literal(shape, ['n'], named)
            body = rng.choice(['    %s' % lit(),
                               '    if n > 3:\n        return %s\n    %s' % (lit(), lit()),
                               '    if n > 3:\n        %s\n    else:\n        %s' % (lit(), lit()),
                               '    t = tick(counter)\n    %s' % lit()])
            lines.append('fn %s(n: int):\n%s' % (fname, body))
            fnret[shape].append(fname)
        for k in range(rng.randint(1, 2)):
            cname = 'use_%s_%d' % (shape, k)
            chosen = rng.sample(names, rng.randint(1, len(names)))
            terms = ['x.%s' % f for f in chosen if not (shape == 'mixed' and f == 's')]
            if not terms: terms = ['0']
            style = rng.choice(['plain', 'store', 'fwd'])
            if style == 'store':
                body = '    xs = list_append([], x)\n    list_length(xs) + %s' % ' + '.join(terms)
            elif style == 'fwd' and k > 0:
                body = '    use_%s_%d(x) + %s' % (shape, k - 1, ' + '.join(terms))
            else:
                body = '    %s' % ' + '.join(terms)
            lines.append('fn %s(x):\n%s' % (cname, body))
            fncons[shape].append(cname)
    # ---- main body in a function so locals are not module statics
    body = []
    ints = ['n']
    structs = []   # (var, shape)
    stored = []    # (list var, shape)
    results = []
    def fresh(prefix, counter=[0]):
        counter[0] += 1
        return '%s%d' % (prefix, counter[0])
    def stmts(depth, indent):
        pad = '    ' * indent
        res = []
        for _ in range(rng.randint(3, 7)):
            choice = rng.random()
            shape = rng.choice(list(SHAPES) + ['Pair'])
            named = shape == 'Pair'
            if choice < 0.2:
                v = fresh('v'); res.append('%s%s = %s' % (pad, v, literal(shape, ints, named))); structs.append((v, shape))
            elif choice < 0.35:
                v = fresh('v'); res.append('%s%s = %s(%s)' % (pad, v, rng.choice(fnret[shape]), int_expr(ints))); structs.append((v, shape))
            elif choice < 0.45 and depth < 2:
                v = fresh('v')
                saved = (list(ints), list(structs))
                res.append('%s%s = if %s > %d:\n%s    %s\n%selse:\n%s    %s' % (pad, v, int_expr(ints), rng.randint(0, 5), pad, literal(shape, ints, named), pad, pad, literal(shape, ints, named)))
                structs.append((v, shape))
            elif choice < 0.55 and structs:
                src, sh = rng.choice(structs); v = fresh('v'); res.append('%s%s = %s' % (pad, v, src)); structs.append((v, sh))
            elif choice < 0.7 and structs:
                src, sh = rng.choice(structs); names = SHAPES.get(sh) or NAMED[sh]
                f = rng.choice([x for x in names if not (sh == 'mixed' and x == 's')] or [names[0]])
                if sh == 'mixed' and f == 's':
                    v = fresh('s'); res.append('%s%s = %s.%s' % (pad, v, src, f)); results.append(v)
                else:
                    v = fresh('i'); res.append('%s%s = %s.%s' % (pad, v, src, f)); ints.append(v); results.append(v)
            elif choice < 0.78 and structs:
                src, sh = rng.choice(structs); v = fresh('r'); res.append('%s%s = %s(%s)' % (pad, v, rng.choice(fncons[sh]), src)); ints.append(v); results.append(v)
            elif choice < 0.84 and structs:
                src, sh = rng.choice(structs); prev = curxs[0]; curxs[0] = fresh('xs')
                res.append('%s%s = list_append(%s, %s)' % (pad, curxs[0], prev, src)); stored.append(sh)
            elif choice < 0.9 and len(structs) > 1:
                a, sa = rng.choice(structs); b, sb = rng.choice(structs)
                if sa == sb and sa != 'mixed':
                    v = fresh('e'); res.append('%s%s = %s == %s' % (pad, v, a, b)); results.append(v)
            elif choice < 0.95:
                v = fresh('i'); res.append('%s%s = %s' % (pad, v, int_expr(ints))); ints.append(v); results.append(v)
        return res
    curxs = ['xs0']
    body.append('    xs0 = []')
    body.extend(stmts(0, 1))
    body.append('    [%s]' % ', '.join(['mutable_array_get(counter, 0)', 'list_length(%s)' % curxs[0]] + results[:24]))
    lines.append('fn run(n: int):\n' + '\n'.join(body))
    lines.append('[run(0), run(2), run(5)]')
    return '\n'.join(lines) + '\n'

seed, count, outdir = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
os.makedirs(outdir, exist_ok=True)
for k in range(count):
    rng = random.Random(seed * 100003 + k)
    open(os.path.join(outdir, 'prog-%d-%d.bot' % (seed, k)), 'w').write(gen(rng))
print('wrote', count)
