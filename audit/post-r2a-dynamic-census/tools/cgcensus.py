#!/usr/bin/env python3
"""cgcensus.py -- POST-R2A-DYNAMIC-CENSUS.md's call-graph attribution of a
callgrind profile of the audit botlish-native. Observation only.

    python3 cgcensus.py CALLGRIND.OUT JITMAP RUNS OUTDIR [BINARY]

Complements audit/post-m8a-common-inefficiency/tools/cgprof.py (reused for
parsing, JIT address lookup, disassembly and the instruction classifier)
with what that tool does not report:

  * per Botlish function: SELF Ir (direct body and generic entry
    separately) and INCLUSIVE Ir (self plus every call it makes, into
    Botlish code or runtime/libc), with an EXACT in-region invocation
    count;
  * per runtime helper: inclusive Ir split by calling Botlish function;
  * the `callvalue` dispatch decomposition (rt_call_value's own
    instructions, attributed by inlined source function via addr2line,
    vs. the callee work beneath it);
  * inlined-source-line attribution of the hot runtime helpers' SELF cost
    (addr2line -i on each executed instruction: e.g. rt_substr's UTF-8
    seek vs. its copy vs. its allocation);
  * the executed JIT instruction-class mix per function (cgprof's
    classifier, unchanged) as a machine-readable table.

Call counts. callgrind gates event COSTS by --toggle-collect, but the
`calls=` count of a call arc is incremented process-wide (verified: the
arc __rust_dealloc -> __rdl_dealloc reports ~19,700 calls/run at 4,330 Ir
in total -- Vm::reset's frees, outside the collected region). So this
tool never uses `calls=` counts for invocation counts. Instead:
  * a function's in-region invocation count is the execution count of its
    FIRST instruction (each call executes it exactly once; none of the
    functions reported loops back to its own entry address), and
  * an arc's in-region count is the execution count of its call
    instruction (the call site's own self Ir), split in proportion to
    `calls=` only for a site with several targets (an indirect call). This
    holds for JIT and Rust callers alike (verified: every JIT arc count
    equals the callee's entry-instruction count where the callee has one
    caller).
"""
import bisect
import collections
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', '..', 'post-m8a-common-inefficiency', 'tools'))
import cgprof  # noqa: E402

HOT_HELPERS = [
    'rt_substr', 'rt_call_value', 'rt_str_region_eq', 'rt_str_region_is_tcl_alnum',
    'rt_is_tcl_alnum', 'one_scalar', 'region_one_scalar', 'rt_set_contains', 'equal',
    'rt_closure_new', 'rt_str_region_check', 'rt_str_len',
    '<runtime::vm::Vm>::alloc::<runtime::value::StrObj>',
    '<runtime::vm::Vm>::alloc::<runtime::value::ClosureObj>',
    '<runtime::vm::Vm>::new_str_known', '<runtime::vm::Vm>::new_str', 'runtime::vm::str_object',
]


def short(name):
    return (name or '?').replace('botlish_native::runtime::ops::', '').replace('botlish_native::runtime::', 'runtime::') \
        .replace('botlish_native::', '')


def main():
    cg, jitmap, runs, outdir = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
    binary = sys.argv[5] if len(sys.argv) > 5 else None
    events, self_cost, addr_fn, calls, totals = cgprof.parse_callgrind(cg)
    funcs, ranges = cgprof.load_jitmap(jitmap)
    E = len(events)
    IR = events.index('Ir')

    def per(v):
        return v / runs

    total = [0] * E
    for v in self_cost.values():
        for i, x in enumerate(v):
            total[i] += x
    T = total[IR]

    def pct(x):
        return 100.0 * x / T

    # ---- entities ---------------------------------------------------------
    # JIT: ('J', id, part); other: ('R', fnname)
    def jit_entity(addr):
        r = cgprof.jit_lookup(ranges, addr)
        if r:
            return ('J', r[2]['id'], r[3])
        return None

    fname = {f['id']: f['name'] for f in funcs}

    def ename(e):
        if e[0] == 'J':
            return f"{e[1]} {fname[e[1]]}" + (' (generic entry)' if e[2] == 'entry' else '')
        return short(e[1])

    selfc = collections.defaultdict(lambda: [0] * E)
    kind = {}
    first_addr = {}
    for addr, vals in self_cost.items():
        e = jit_entity(addr)
        if e is None:
            obj, fn = addr_fn.get(addr, ('?', '?'))
            e = ('R', fn)
            ob = os.path.basename(obj or '?')
            if 'botlish-native' in ob:
                kind[e] = 'runtime' if (fn or '').startswith('rt_') or '::runtime::' in (fn or '') or 'runtime' in (fn or '') else 'rust-other'
            elif ob.startswith('libc') or ob.startswith('ld-'):
                kind[e] = 'libc'
            else:
                kind[e] = 'other'
        else:
            kind[e] = 'botlish'
        c = selfc[e]
        for i, x in enumerate(vals):
            c[i] += x
        if e not in first_addr or addr < first_addr[e]:
            first_addr[e] = addr

    # exact in-region invocation counts: executions of the entry instruction
    entries = {}
    for f in funcs:
        for part, a in (('direct', f['direct']), ('entry', f['entry'])):
            v = self_cost.get(a)
            entries[('J', f['id'], part)] = (v[IR] if v else 0)
    sym_start = {}
    if binary:
        out = subprocess.run(['nm', '-C', '--defined-only', binary], capture_output=True, text=True).stdout
        for line in out.splitlines():
            m = re.match(r'([0-9a-f]+) [tTwW] (.*)$', line)
            if m:
                sym_start.setdefault(m.group(2), int(m.group(1), 16))
    rust_entries = {}
    for e in selfc:
        if e[0] != 'R':
            continue
        nm = e[1]
        cands = [s for s in sym_start if s == nm or s.endswith('::' + nm) or s.endswith(nm)]
        for s in cands:
            a = sym_start[s]
            v = self_cost.get(a)
            if v is not None:
                rust_entries[e] = v[IR]
                break

    # ---- arcs -------------------------------------------------------------
    # An arc's in-region call count is the in-region execution count of
    # its call instruction (the site's own self Ir: one Ir per executed
    # instruction, gated by --toggle-collect like every other cost), never
    # callgrind's process-wide `calls=` counter. A site with several
    # targets (an indirect call) is split in proportion to `calls=`.
    arcs = collections.defaultdict(lambda: [0] * E)
    arc_count = collections.defaultdict(float)
    site_targets = collections.defaultdict(list)
    for caller_fn, site, cobj, cfn, target, count, vals in calls:
        src = jit_entity(site) or ('R', caller_fn)
        dst = jit_entity(target) or ('R', cfn)
        site_targets[site].append((src, dst, count, vals))
    for site, lst in site_targets.items():
        executed = self_cost[site][IR] if site in self_cost else 0
        total_calls = sum(c for _, _, c, _ in lst) or 1
        for src, dst, count, vals in lst:
            if src == dst:
                continue
            a = arcs[(src, dst)]
            for i, x in enumerate(vals):
                a[i] += x
            arc_count[(src, dst)] += executed * count / total_calls

    def combined(e):
        return ('F', e[1]) if e[0] == 'J' else e

    # inclusive for combined JIT functions (direct + entry) and for Rust fns
    incl = collections.defaultdict(lambda: [0] * E)
    for e, v in selfc.items():
        c = incl[combined(e)]
        for i, x in enumerate(v):
            c[i] += x
    for (s, d), v in arcs.items():
        cs, cd = combined(s), combined(d)
        if cs == cd:
            continue
        c = incl[cs]
        for i, x in enumerate(v):
            c[i] += x

    L = []
    L.append(f'runs collected: {runs}; all figures per run')
    L.append(f'total Ir/run: {per(T):,.0f}')
    kt = collections.defaultdict(float)
    for e, v in selfc.items():
        kt[kind[e]] += v[IR]
    L.append('exclusive Ir by code kind: ' + '  '.join(f'{k} {per(v):,.0f} ({pct(v):.1f}%)' for k, v in sorted(kt.items(), key=lambda x: -x[1])))
    L.append('')

    # ---- per Botlish function --------------------------------------------
    L.append('== Botlish functions: invocations (exact), SELF Ir (direct / generic entry), INCLUSIVE Ir (direct+entry+all callees)')
    L.append(f'  {"function":<34} {"invoc":>9} {"entry-invoc":>11} {"self direct":>12} {"self entry":>10} {"inclusive":>12} {"incl %":>7} {"self %":>7}')
    rows = []
    for f in funcs:
        d, en = ('J', f['id'], 'direct'), ('J', f['id'], 'entry')
        sd = selfc[d][IR] if d in selfc else 0
        se = selfc[en][IR] if en in selfc else 0
        inc = incl[('F', f['id'])][IR]
        rows.append((inc, f, sd, se))
    for inc, f, sd, se in sorted(rows, key=lambda r: -r[0]):
        if inc == 0:
            continue
        L.append(f'  {str(f["id"]) + " " + f["name"]:<34} {per(entries[("J", f["id"], "direct")]):>9,.0f} {per(entries[("J", f["id"], "entry")]):>11,.0f} '
                 f'{per(sd):>12,.0f} {per(se):>10,.0f} {per(inc):>12,.0f} {pct(inc):>6.2f}% {pct(sd + se):>6.2f}%')
    L.append('')

    # ---- arcs from Botlish code ------------------------------------------
    L.append('== calls out of Botlish code (in-region counts): caller -> callee, count/run, inclusive Ir/run, Ir/call, % total')
    for (s, d), v in sorted(arcs.items(), key=lambda kv: -kv[1][IR]):
        if s[0] != 'J':
            continue
        n = arc_count[(s, d)]
        L.append(f'  {ename(s):<30} -> {ename(d)[:60]:<60} {per(n):>9,.0f}  {per(v[IR]):>12,.0f}  {v[IR] / max(n, 1):>7.1f}  {pct(v[IR]):>6.2f}%')
    L.append('')

    # ---- runtime helper inclusive table -----------------------------------
    L.append('== runtime/libc functions: exact in-region invocations (entry-instruction count, if resolvable), SELF, INCLUSIVE')
    rrows = []
    for e in incl:
        if e[0] != 'R':
            continue
        rrows.append((incl[e][IR], e))
    for inc, e in sorted(rrows, key=lambda r: -r[0]):
        if inc < 0.0005 * T:
            continue
        n = rust_entries.get(e)
        ns = f'{per(n):>9,.0f}' if n is not None else f'{"?":>9}'
        L.append(f'  {short(e[1])[:70]:<70} {ns}  self {per(selfc[e][IR]):>11,.0f} ({pct(selfc[e][IR]):5.2f}%)  incl {per(inc):>11,.0f} ({pct(inc):5.2f}%)'
                 + (f'  {inc / n:7.1f} Ir/call' if n else ''))
    L.append('')

    # ---- arcs out of selected runtime functions (costs only) -----------------
    L.append('== arcs out of hot runtime functions: in-region call count/run, inclusive Ir/run of the callee subtree')
    for h in HOT_HELPERS:
        e = ('R', 'botlish_native::runtime::ops::' + h) if ('R', 'botlish_native::runtime::ops::' + h) in incl else None
        if e is None:
            for cand in incl:
                if cand[0] == 'R' and (cand[1] == h or short(cand[1]) == h or (cand[1] or '').endswith('::' + h)):
                    e = cand
                    break
        if e is None:
            continue
        L.append(f'  {short(e[1])}: self {per(selfc[e][IR]):,.0f}, inclusive {per(incl[e][IR]):,.0f}')
        for (s, d), v in sorted(arcs.items(), key=lambda kv: -kv[1][IR]):
            if s == e and v[IR] > 0:
                L.append(f'      -> {ename(d)[:90]:<90} {per(arc_count[(s, d)]):>9,.0f} calls {per(v[IR]):>11,.0f}')
    L.append('')

    # ---- inlined-source attribution of hot helpers' self cost ---------------
    if binary:
        L.append('== SELF cost of hot runtime functions by inlined source (addr2line -i: innermost function @ line; outermost line)')
        addrs_by = collections.defaultdict(list)
        for addr, vals in self_cost.items():
            if jit_entity(addr):
                continue
            obj, fn = addr_fn.get(addr, ('?', '?'))
            if 'botlish-native' not in os.path.basename(obj or ''):
                continue
            e = ('R', fn)
            for h in HOT_HELPERS:
                if short(fn) == h or fn == h or (fn or '').endswith('::' + h):
                    addrs_by[e].append((addr, vals[IR]))
        all_addrs = sorted({a for lst in addrs_by.values() for a, _ in lst})
        info = {}
        if all_addrs:
            p = subprocess.run(['addr2line', '-i', '-f', '-C', '-a', '-e', binary] + [hex(a) for a in all_addrs],
                               capture_output=True, text=True).stdout.splitlines()
            cur = None
            chain = []
            i = 0
            while i < len(p):
                line = p[i]
                if re.match(r'0x[0-9a-f]+$', line):
                    if cur is not None:
                        info[cur] = chain
                    cur = int(line, 16)
                    chain = []
                    i += 1
                    continue
                func = line
                loc = p[i + 1] if i + 1 < len(p) else '?'
                chain.append((func, loc))
                i += 2
            if cur is not None:
                info[cur] = chain

        def srcshort(loc):
            m = re.search(r'([^/]+\.rs):(\d+)', loc)
            return f'{m.group(1)}:{m.group(2)}' if m else loc.split('/')[-1]

        # callvalue dispatch decomposition: rt_call_value's own (self)
        # instructions, split by what the inlined source frame chain says
        # they are doing: the inlined native callee's work (is_tcl_alpha's
        # one_scalar/classification), the native-dispatch layer
        # (invoke_native's arity/param-kind checks, apply_op's opcode
        # match), or rt_call_value's own common dispatch (heap-kind test,
        # closure arity check, generic-entry transmute/call).
        for e, lst in addrs_by.items():
            if short(e[1]) != 'rt_call_value':
                continue
            cat = collections.Counter()
            for a, x in lst:
                names = ' '.join(fnn for fnn, _ in info.get(a, []))
                if any(k in names for k in ('tcl_alpha_char', 'tcl_alnum_char', 'get_general_category', 'rt_is_tcl_alpha', 'one_scalar', 'bool_value')):
                    cat['callee work inlined (is_tcl_alpha classification)'] += x
                elif any(k in names for k in ('invoke_native', 'apply_op')):
                    cat['native dispatch (invoke_native arity/kind checks, apply_op match)'] += x
                else:
                    cat['common dispatch (rt_call_value kind test, closure arity, entry call)'] += x
            L.append('  rt_call_value SELF by role (inline chain):')
            for k, x in cat.most_common():
                L.append(f'      {k:<72} {per(x):>10,.0f}')
        for e, lst in sorted(addrs_by.items(), key=lambda kv: -sum(x for _, x in kv[1])):
            tot = sum(x for _, x in lst)
            if tot == 0:
                continue
            by_inner = collections.Counter()
            by_outer = collections.Counter()
            for a, x in lst:
                ch = info.get(a, [])
                if ch:
                    inner = f'{short(ch[0][0])[:60]} @ {srcshort(ch[0][1])}'
                    outer = srcshort(ch[-1][1])
                    # the first frame (walking outward) that is Botlish runtime source
                    rt = next((srcshort(l) for fnn, l in ch if '/src/runtime/' in l), outer)
                else:
                    inner, outer, rt = '?', '?', '?'
                by_inner[inner] += x
                by_outer[rt] += x
            L.append(f'  {short(e[1])}: self {per(tot):,.0f} Ir/run')
            L.append('    by runtime source line (innermost botlish-native runtime frame):')
            for k, x in by_outer.most_common(12):
                if x:
                    L.append(f'      {k:<40} {per(x):>10,.0f}  {100 * x / tot:5.1f}%')
            L.append('    by innermost inlined function:')
            for k, x in by_inner.most_common(8):
                if x:
                    L.append(f'      {k:<80} {per(x):>10,.0f}  {100 * x / tot:5.1f}%')
        L.append('')

    # ---- JIT instruction-class mix, per function ---------------------------
    jit_starts = set()
    for fn in funcs:
        jit_starts.add(fn['direct'])
        jit_starts.add(fn['entry'])
    classes = {}
    for fn in funcs:
        for hexbytes, vma in ((fn['dhex'], fn['direct']), (fn['ehex'], fn['entry'])):
            d = cgprof.disassemble(hexbytes, vma)
            classes.update(cgprof.classify_function(sorted(d.items()), jit_starts))
    mix = collections.defaultdict(lambda: collections.defaultdict(int))
    for addr, vals in self_cost.items():
        e = jit_entity(addr)
        if not e:
            continue
        mix[e[1]][classes.get(addr, '?')] += vals[IR]
    allcls = collections.Counter()
    for fid, m in mix.items():
        for c, x in m.items():
            allcls[c] += x
    L.append('== executed JIT instruction classes (per run), per function (direct + generic entry)')
    cols = [c for c, _ in allcls.most_common()]
    L.append('  class-totals: ' + '; '.join(f'{c}={per(x):,.0f}' for c, x in allcls.most_common()))
    for fid in sorted(mix, key=lambda f: -sum(mix[f].values())):
        tot = sum(mix[fid].values())
        if tot == 0:
            continue
        L.append(f'  {fid} {fname[fid]} ({per(tot):,.0f}): ' + '; '.join(f'{c}={per(x):,.0f}' for c, x in sorted(mix[fid].items(), key=lambda kv: -kv[1]) if x))
    L.append('')
    with open(os.path.join(outdir, 'census.txt'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(L) + '\n')
    print(f'{outdir}/census.txt: Ir/run={per(T):,.0f}')


if __name__ == '__main__':
    main()
