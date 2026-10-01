#!/usr/bin/env python3
"""fuzz.py SEED COUNT OUTDIR -- writes COUNT random, well-typed Botlish programs
(OUTDIR/prog-SEED-K.bot) for the differential check fuzz.tcl of VALUE-
TRANSPORT-MATERIALIZATION.md: struct values of random width (and one level of
nesting) built, aliased, projected, merged, forwarded down exact call chains of
random depth (argument chains, return chains, mixed, branching, partially
projected on the way), carried through self-recursive loops, and used in
materializing ways (stored, compared, hashed, an inner value taken out whole).

Every program ends in a List of the integers and strings it computed and the
side-effect counter, so any change in a value, in evaluation order or in the
number of side effects shows. Programs are bounded: at most 12 functions per
shape family, chains of depth <= 10, loops of <= 7 iterations."""
import random, sys, os

def gen(rng):
    L = []
    L.append('counter = mutarray::create(1, 0)')
    L.append('fn tick(m):\n    n = mutable_array_get(m, 0)\n    mutable_array_set(m, 0, n + 1)\n    n')
    # ---------------------------------------------------------------- shapes
    shapes = []   # dicts: name, fields [(name, kind)], inner {field: [(name, kind)]}
    nshapes = rng.randint(2, 4)
    for s in range(nshapes):
        width = rng.choice([1, 2, 2, 3, 4, 5, 6, 8, 9])
        fields = []
        for i in range(width):
            kind = 'int'
            if rng.random() < 0.12:
                kind = rng.choice(['str', 'list'])
            fields.append(('f%d' % i, kind))
        inner = {}
        if rng.random() < 0.5:
            iw = rng.choice([1, 2, 2, 3, 4])
            inner_fields = [('g%d' % i, 'int' if rng.random() > 0.15 else 'str') for i in range(iw)]
            nm = 'inner'
            fields.append((nm, 'inner'))
            inner[nm] = inner_fields
            if rng.random() < 0.25:     # a second inner value
                nm2 = 'other'
                fields.append((nm2, 'inner'))
                inner[nm2] = [('h%d' % i, 'int') for i in range(rng.randint(1, 3))]
        shapes.append(dict(name='S%d' % s, fields=fields, inner=inner))

    def int_expr(ints, depth=0):
        r = rng.random()
        if depth > 1 or r < 0.3 or not ints:
            return str(rng.randint(0, 9)) if (not ints or rng.random() < 0.5) else rng.choice(ints)
        if r < 0.42:
            return 'tick(counter)'
        return '(%s %s %s)' % (int_expr(ints, depth + 1), rng.choice(['+', '-', '*']), int_expr(ints, depth + 1))
    def leaf(kind, ints):
        if kind == 'int': return int_expr(ints)
        if kind == 'str': return rng.choice(['concat("s", "t")', '"lit"', 'concat(concat("a", "b"), "c")'])
        return rng.choice(['[1, 2]', '[%s]' % int_expr(ints), '[]'])
    def literal(sh, ints):
        order = list(range(len(sh['fields'])))
        if rng.random() < 0.5: rng.shuffle(order)
        parts = []
        for i in order:
            name, kind = sh['fields'][i]
            if kind == 'inner':
                inner = sh['inner'][name]
                io = list(range(len(inner)))
                if rng.random() < 0.5: rng.shuffle(io)
                parts.append('%s: {%s}' % (name, ', '.join('%s: %s' % (inner[j][0], leaf(inner[j][1], ints)) for j in io)))
            else:
                parts.append('%s: %s' % (name, leaf(kind, ints)))
        return '{%s}' % ', '.join(parts)
    def int_leaves(sh, var):
        out = []
        for name, kind in sh['fields']:
            if kind == 'int': out.append('%s.%s' % (var, name))
            elif kind == 'inner':
                for g, gk in sh['inner'][name]:
                    if gk == 'int': out.append('%s.%s.%s' % (var, name, g))
        return out or ['0']
    def sample_terms(sh, var):
        t = int_leaves(sh, var)
        return rng.sample(t, rng.randint(1, len(t)))
    def other_leaves(sh, var):
        out = []
        for name, kind in sh['fields']:
            if kind in ('str', 'list'): out.append('%s.%s' % (var, name))
        return out

    # ----------------------------------------------------------- function library
    lib = {}
    for sh in shapes:
        n = sh['name']
        lib[n] = dict(ret=[], fwd=[], use=[], spin=None)
        # constructors
        lit = lambda: literal(sh, ['n'])
        style = rng.choice(['plain', 'two-exit', 'ifelse', 'effect'])
        body = {'plain': '    %s' % lit(),
                'two-exit': '    if n > 3:\n        return %s\n    %s' % (lit(), lit()),
                'ifelse': '    if n > 3:\n        %s\n    else:\n        %s' % (lit(), lit()),
                'effect': '    t = tick(counter)\n    %s' % lit()}[style]
        L.append('fn mk_%s(n: int):\n%s' % (n, body))
        lib[n]['ret'].append('mk_%s' % n)
        # return chains
        depth = rng.randint(0, 9)
        prev = 'mk_%s' % n
        for j in range(depth):
            name = 'ret_%s_%d' % (n, j)
            kind = rng.choice(['forward', 'forward', 'forward', 'bound', 'reshape', 'branch'])
            if kind == 'forward':
                body = '    %s(n)' % prev
            elif kind == 'bound':
                body = '    r = %s(n)\n    r' % prev
            elif kind == 'branch':
                body = '    if n > 2:\n        %s(n)\n    else:\n        %s(n + 1)' % (prev, prev)
            else:
                body = '    r = %s(n)\n    %s' % (prev, literal(sh, ['n'] + [t for t in sample_terms(sh, 'r')][:1] and ['n']))
                # reshape: rebuild from the projection of r where ints are available
                lits = literal(sh, ['n'])
                body = '    r = %s(n)\n    %s' % (prev, lits)
            L.append('fn %s(n: int):\n%s' % (name, body))
            lib[n]['ret'].append(name)
            prev = name
        # consumers
        for k in range(rng.randint(1, 2)):
            name = 'use_%s_%d' % (n, k)
            terms = sample_terms(sh, 'x')
            extra = other_leaves(sh, 'x')
            style = rng.choice(['plain', 'store', 'eq', 'hash', 'plain'])
            lines = []
            if style == 'store':
                lines.append('    xs = list_append([], x)')
                lines.append('    list_length(xs) + %s' % ' + '.join(terms))
            elif style == 'eq':
                lines.append('    same = x == %s' % literal(sh, ['k']).replace('tick(counter)', '1'))
                lines.append('    if same:\n        %s\n    else:\n        0 - (%s)' % (' + '.join(terms), ' + '.join(terms)))
            elif style == 'hash':
                lines.append('    h = hash(x)')
                lines.append('    (h - h) + %s' % ' + '.join(terms))
            else:
                lines.append('    %s' % ' + '.join(terms))
            L.append('fn %s(x, k):\n%s' % (name, '\n'.join(lines)))
            lib[n]['use'].append(name)
        # argument chains
        depth = rng.randint(0, 10)
        prev = lib[n]['use'][-1]
        for j in range(depth):
            name = 'fwd_%s_%d' % (n, j)
            kind = rng.choice(['forward', 'forward', 'forward', 'project', 'branch', 'local'])
            terms = sample_terms(sh, 'x')
            if kind == 'forward':
                body = '    %s(x, k)' % prev
            elif kind == 'project':
                body = '    %s + %s(x, k)' % (terms[0], prev)
            elif kind == 'branch':
                body = '    if k > 2:\n        %s(x, k)\n    else:\n        %s' % (prev, terms[0])
            else:
                body = '    y = x\n    %s(y, k) + %s' % (prev, terms[0])
            L.append('fn %s(x, k):\n%s' % (name, body))
            lib[n]['fwd'].append(name)
            prev = name
        if not lib[n]['fwd']:
            lib[n]['fwd'].append(lib[n]['use'][-1])
        # loop-carried struct
        if rng.random() < 0.5:
            ints = [f for f, kind in sh['fields'] if kind == 'int']
            if ints:
                parts = []
                for name, kind in sh['fields']:
                    if kind == 'inner':
                        parts.append('%s: {%s}' % (name, ', '.join('%s: s.%s.%s' % (g, name, g) if gk == 'int' else '%s: "z"' % g for g, gk in sh['inner'][name])))
                    elif kind == 'int':
                        parts.append('%s: s.%s + 1' % (name, name))
                    elif kind == 'str':
                        parts.append('%s: s.%s' % (name, name))
                    else:
                        parts.append('%s: s.%s' % (name, name))
                nm = 'spin_%s' % n
                L.append('fn %s(s, i, m):\n    if i >= m:\n        return %s\n    %s({%s}, i + 1, m)' % (nm, ' + '.join(int_leaves(sh, 's')), nm, ', '.join(parts)))
                lib[n]['spin'] = nm

    # ----------------------------------------------------------------- run body
    body = ['    xs0 = []']
    ints = ['n']
    structs = []
    results = []
    cnt = [0]
    curxs = ['xs0']
    def fresh(p):
        cnt[0] += 1
        return '%s%d' % (p, cnt[0])
    def stmts(depth, pad):
        res = []
        for _ in range(rng.randint(4, 9)):
            c = rng.random()
            sh = rng.choice(shapes)
            n = sh['name']
            if c < 0.14:
                v = fresh('v'); res.append('%s%s = %s' % (pad, v, literal(sh, ints))); structs.append((v, sh))
            elif c < 0.28:
                v = fresh('v'); res.append('%s%s = %s(%s)' % (pad, v, rng.choice(lib[n]['ret']), 'n')); structs.append((v, sh))
            elif c < 0.34 and depth < 2:
                v = fresh('v')
                res.append('%s%s = if %s > %d:\n%s    %s\n%selse:\n%s    %s' % (pad, v, int_expr(ints), rng.randint(0, 5), pad, literal(sh, ints), pad, pad, literal(sh, ints)))
                structs.append((v, sh))
            elif c < 0.40 and structs:
                src, ssh = rng.choice(structs); v = fresh('v'); res.append('%s%s = %s' % (pad, v, src)); structs.append((v, ssh))
            elif c < 0.52 and structs:
                src, ssh = rng.choice(structs)
                t = sample_terms(ssh, src)[0]; v = fresh('i'); res.append('%s%s = %s' % (pad, v, t)); ints.append(v); results.append(v)
            elif c < 0.64 and structs:
                src, ssh = rng.choice(structs); v = fresh('r')
                res.append('%s%s = %s(%s, %s)' % (pad, v, rng.choice(lib[ssh['name']]['fwd']), src, int_expr(ints))); ints.append(v); results.append(v)
            elif c < 0.69 and structs:
                src, ssh = rng.choice(structs); v = fresh('r')
                res.append('%s%s = %s(%s, %s)' % (pad, v, rng.choice(lib[ssh['name']]['use']), src, int_expr(ints))); ints.append(v); results.append(v)
            elif c < 0.74 and structs:
                src, ssh = rng.choice(structs); prev = curxs[0]; curxs[0] = fresh('xs')
                res.append('%s%s = list_append(%s, %s)' % (pad, curxs[0], prev, src))
            elif c < 0.78 and structs:
                src, ssh = rng.choice(structs)
                outs = other_leaves(ssh, src)
                if outs:
                    v = fresh('s'); res.append('%s%s = %s' % (pad, v, rng.choice(outs))); results.append(v)
            elif c < 0.82 and structs:
                # an inner value taken out whole
                cand = [(v, s2) for v, s2 in structs if s2['inner']]
                if cand:
                    src, ssh = rng.choice(cand); nm = rng.choice(list(ssh['inner']))
                    w = fresh('w'); res.append('%s%s = %s.%s' % (pad, w, src, nm))
                    g = [g for g, gk in ssh['inner'][nm] if gk == 'int']
                    if g:
                        v = fresh('i'); res.append('%s%s = %s.%s' % (pad, v, w, g[0])); ints.append(v); results.append(v)
            elif c < 0.86 and lib[n]['spin']:
                v = fresh('r'); res.append('%s%s = %s(%s, 0, %d)' % (pad, v, lib[n]['spin'], literal(sh, ints).replace('tick(counter)', '1'), rng.randint(0, 6))); ints.append(v); results.append(v)
            elif c < 0.9 and structs:
                # a chain projection straight off a call result
                cand = [s2 for s2 in shapes if s2['inner']]
                if cand:
                    ssh = rng.choice(cand); nm = rng.choice(list(ssh['inner']))
                    g = [g for g, gk in ssh['inner'][nm] if gk == 'int']
                    if g:
                        v = fresh('i'); res.append('%s%s = %s(n).%s.%s' % (pad, v, rng.choice(lib[ssh['name']]['ret']), nm, g[0])); ints.append(v); results.append(v)
            elif c < 0.95 and len(structs) > 1:
                a, sa = rng.choice(structs); b, sb = rng.choice(structs)
                if sa is sb:
                    v = fresh('e'); res.append('%s%s = %s == %s' % (pad, v, a, b)); results.append(v)
            else:
                v = fresh('i'); res.append('%s%s = %s' % (pad, v, int_expr(ints))); ints.append(v); results.append(v)
        return res
    body.extend(stmts(0, '    '))
    body.append('    [%s]' % ', '.join(['mutable_array_get(counter, 0)', 'list_length(%s)' % curxs[0]] + results[:30]))
    L.append('fn run(n: int):\n' + '\n'.join(body))
    L.append('[run(0), run(2), run(5)]')
    return '\n'.join(L) + '\n'

seed, count, outdir = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
os.makedirs(outdir, exist_ok=True)
for k in range(count):
    rng = random.Random(seed * 100003 + k)
    open(os.path.join(outdir, 'prog-%d-%d.bot' % (seed, k)), 'w').write(gen(rng))
print('wrote', count)
