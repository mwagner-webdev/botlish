#!/usr/bin/env python3
"""cgprof.py -- attribute a callgrind profile of a Botlish native run
(POST-M8A-COMMON-INEFFICIENCY-CENSUS.md). Observation only.

    python3 cgprof.py CALLGRIND.OUT JITMAP RUNS OUTDIR

CALLGRIND.OUT must come from
    valgrind --tool=callgrind --dump-instr=yes --dump-line=no \
        --compress-strings=no --compress-pos=no \
        --toggle-collect=botlish_audit_run [--cache-sim=yes --branch-sim=yes] ...
run on the audit build (tools/audit-native.patch), whose
BOTLISH_AUDIT_JITMAP=JITMAP file names every JIT function's direct and
generic-entry code ranges and bytes (JIT code has no symbols, so callgrind
alone can only name it by address). RUNS divides every count to a per-run
figure (the toggle collects the timed runs only: no JIT compilation, no
between-run Vm::reset).

Writes into OUTDIR:
  profile.txt      totals; exclusive cost per Botlish function (direct and
                   generic entry separately) and per runtime/libc function;
                   inclusive cost of every runtime helper as called from
                   Botlish code; call counts (Botlish->Botlish exact calls per
                   callee, Botlish->helper calls per helper); a coarse
                   "Botlish code vs runtime vs libc" split
  instr.txt        every executed JIT instruction: address, function,
                   execution count, per-event cost, disassembly
  mix.txt          executed JIT instruction mix by class, per function and
                   total (moves, loads, stores, push/pop, calls, branches,
                   compares/tests, tag ops, arithmetic, ...)
"""
import collections
import os
import re
import subprocess
import sys
import tempfile


def parse_callgrind(path):
    events = None
    fn = None
    obj = None
    pending_call = None
    self_cost = collections.defaultdict(lambda: None)  # addr -> [events]
    addr_fn = {}
    calls = []  # (caller_fn, callsite, cobj, cfn, target, count, cost)
    cfn = cob = None
    totals = None
    with open(path, encoding='utf-8', errors='replace') as f:
        for raw in f:
            line = raw.rstrip('\n')
            if not line:
                continue
            if line.startswith('events:'):
                events = line.split()[1:]
                continue
            if line.startswith('totals:') or line.startswith('summary:'):
                totals = [int(x) for x in line.split()[1:]]
                continue
            if line.startswith('ob='):
                obj = line[3:]
                continue
            if line.startswith('fn='):
                fn = line[3:]
                continue
            if line.startswith('cob='):
                cob = line[4:]
                continue
            if line.startswith('cfn='):
                cfn = line[4:]
                continue
            if line.startswith(('fl=', 'fi=', 'fe=', 'cfi=', 'cfl=')):
                continue
            if line.startswith('calls='):
                parts = line[6:].split()
                pending_call = (int(parts[0]), int(parts[1], 16))
                continue
            if line.startswith(('jump=', 'jcnd=')):
                continue
            if line[0] == '0' or line[0].isdigit():
                parts = line.split()
                addr = int(parts[0], 16)
                vals = [int(x) for x in parts[1:]]
                vals += [0] * (len(events) - len(vals))
                if pending_call is not None:
                    count, target = pending_call
                    calls.append((fn, addr, cob if cob else obj, cfn, target, count, vals))
                    pending_call = None
                    cob = None
                else:
                    cur = self_cost[addr]
                    if cur is None:
                        self_cost[addr] = list(vals)
                    else:
                        for i, v in enumerate(vals):
                            cur[i] += v
                    addr_fn[addr] = (obj, fn)
                continue
            # header lines (version:, creator:, cmd:, positions:, ...) ignored
    return events, dict(self_cost), addr_fn, calls, totals


def load_jitmap(path):
    funcs = []
    with open(path, encoding='utf-8') as f:
        for line in f:
            m = re.match(r'(\d+) "((?:[^"\\]|\\.)*)" (0x[0-9a-f]+) (\d+) (0x[0-9a-f]+) (\d+) ([0-9a-f]*) ([0-9a-f]*)$', line.strip())
            if not m:
                continue
            fid, name, da, ds, ea, es, dhex, ehex = m.groups()
            funcs.append(dict(id=int(fid), name=name, direct=int(da, 16), dsize=int(ds),
                              entry=int(ea, 16), esize=int(es), dhex=dhex, ehex=ehex))
    ranges = []
    for f in funcs:
        ranges.append((f['direct'], f['direct'] + f['dsize'], f, 'direct'))
        ranges.append((f['entry'], f['entry'] + f['esize'], f, 'entry'))
    ranges.sort(key=lambda r: r[0])
    return funcs, ranges


def jit_lookup(ranges, addr):
    lo, hi = 0, len(ranges)
    while lo < hi:
        mid = (lo + hi) // 2
        if ranges[mid][0] <= addr:
            lo = mid + 1
        else:
            hi = mid
    i = lo - 1
    if i >= 0 and ranges[i][0] <= addr < ranges[i][1]:
        return ranges[i]
    return None


def disassemble(hexbytes, vma):
    if not hexbytes:
        return {}
    with tempfile.NamedTemporaryFile(suffix='.bin', delete=False) as t:
        t.write(bytes.fromhex(hexbytes))
        name = t.name
    try:
        out = subprocess.run(['objdump', '-D', '-b', 'binary', '-m', 'i386:x86-64', '-M', 'intel',
                              '--no-show-raw-insn', f'--adjust-vma={vma:#x}', name],
                             capture_output=True, text=True, check=True).stdout
    finally:
        os.unlink(name)
    insns = {}
    for line in out.splitlines():
        m = re.match(r'\s+([0-9a-f]+):\s+(.*)$', line)
        if m:
            insns[int(m.group(1), 16)] = m.group(2).strip()
    return insns


# Instruction classes for the executed-mix census. Heuristic, by mnemonic,
# operand shape (Intel syntax) and immediate neighbours; the classes and
# their exact patterns are documented in the report. SEMANTIC classes
# (first match wins, per function, in address order):
#   frame: prologue       push rbp / mov rbp,rsp / sub rsp,N / callee-saved
#                         register stores into [rsp+N] at function entry
#   frame: root-slot zero mov QWORD PTR [rsp+N],0x0 at function entry
#   frame: epilogue       callee-saved reloads / add rsp / mov rsp,rbp /
#                         pop rbp / ret at a function exit
#   tag test              test R,0x1 (+ its jcc; + a preceding and R,R that
#                         combines two operands' tags)
#   overflow check        seto R8 / test R8,R8 / its jcc
#   bool materialize      mov R,0x2 + cmovCC R,[rip+K] (a compare turned
#                         into a Botlish Bool word: FALSE=2, TRUE=6)
#   bool test             cmp R,0x6 / test R,R? on a Bool + its jcc
#   untag                 sar R,1
#   retag                 shl R,1 + or R,0x1
#   completion check      test rax,rax + jcc right after a call (NO_VALUE=0
#                         is the error sentinel)
#   call botlish / call helper   (+ movabs of a helper address)
#   stack store / stack load     other [rsp+N] traffic in a body: root-slot
#                         publication, spills, out-parameter slots
#   heap/vm load / heap/vm store other memory traffic
#   mov reg-reg / mov imm / lea / arith / logic / cmp/test / jcc / jmp / other
CALLEE_SAVED = ('rbx', 'r12', 'r13', 'r14', 'r15')


def norm(text):
    return re.sub(r'\s+', ' ', text.split('#')[0]).strip()


def split_insn(t):
    mn = t.split(' ')[0] if t else ''
    return mn, t[len(mn):].strip()


def classify_function(insns, jit_starts):
    """insns: [(addr, text)] in address order for one code range. Returns
    {addr: class}."""
    out = {}
    n = len(insns)
    T = [norm(t) for _, t in insns]
    # prologue
    i = 0
    while i < n:
        t = T[i]
        mn, ops = split_insn(t)
        if t in ('push rbp', 'mov rbp,rsp') or re.match(r'sub rsp,0x[0-9a-f]+$', t) \
                or re.match(r'mov QWORD PTR \[rsp(\+0x[0-9a-f]+)?\],(rbx|r12|r13|r14|r15)$', t):
            out[insns[i][0]] = 'frame: prologue'
            i += 1
            continue
        if re.match(r'mov QWORD PTR \[rsp(\+0x[0-9a-f]+)?\],0x0$', t):
            out[insns[i][0]] = 'frame: root-slot zero'
            i += 1
            continue
        break
    # epilogues: walk back from every ret
    for j in range(n):
        if T[j] == 'ret':
            k = j
            while k >= 0 and (T[k] in ('ret', 'pop rbp', 'mov rsp,rbp') or re.match(r'add rsp,0x[0-9a-f]+$', T[k])
                              or re.match(r'mov (rbx|r12|r13|r14|r15),QWORD PTR \[rsp(\+0x[0-9a-f]+)?\]$', T[k])):
                out[insns[k][0]] = 'frame: epilogue'
                k -= 1
    for j in range(n):
        a = insns[j][0]
        if a in out:
            continue
        t = T[j]
        mn, ops = split_insn(t)
        prev = T[j - 1] if j > 0 else ''
        nxt = T[j + 1] if j + 1 < n else ''
        nxt2 = T[j + 2] if j + 2 < n else ''
        if re.match(r'test \w+,0x1$', t):
            out[a] = 'tag test'
            if nxt.startswith('j'):
                out[insns[j + 1][0]] = 'tag test'
            continue
        if mn == 'and' and re.match(r'test \w+,0x1$', nxt) and '[' not in ops and not re.search(r',0x', ops):
            out[a] = 'tag test'
            continue
        if mn == 'seto':
            out[a] = 'overflow check'
            if re.match(r'test (\w+),\1$', nxt):
                out[insns[j + 1][0]] = 'overflow check'
                if nxt2.startswith('j'):
                    out[insns[j + 2][0]] = 'overflow check'
            continue
        if mn.startswith('cmov') and '[rip' in ops:
            out[a] = 'bool materialize'
            continue
        if re.match(r'mov e?\w+,0x2$', t) and (nxt.startswith('cmp') or nxt.startswith('test') or nxt.startswith('cmov')) \
                and any(x.startswith('cmov') for x in (nxt, nxt2)):
            out[a] = 'bool materialize'
            continue
        if re.match(r'cmp \w+,0x6$', t):
            out[a] = 'bool test'
            if nxt.startswith('j'):
                out[insns[j + 1][0]] = 'bool test'
            continue
        if re.match(r'sar \w+,(1|0x1)$', t):
            out[a] = 'untag'
            continue
        if re.match(r'shl (\w+),(1|0x1)$', t) and re.match(r'(mov \w+,\w+|or \w+,0x1)$', nxt):
            out[a] = 'retag'
            continue
        if re.match(r'or \w+,0x1$', t):
            out[a] = 'retag'
            continue
        if t == 'test rax,rax' and prev.startswith('call') and nxt.startswith('j'):
            out[a] = 'completion check'
            out[insns[j + 1][0]] = 'completion check'
            continue
        if mn == 'call':
            m = re.match(r'call (0x[0-9a-f]+)$', t)
            out[a] = 'call botlish' if m and int(m.group(1), 16) in jit_starts else 'call helper'
            continue
        if mn == 'movabs':
            out[a] = 'call helper' if nxt.startswith('call') else 'mov imm'
            continue
        if mn in ('mov', 'movzx', 'movsx', 'movsxd'):
            if '[' in ops:
                dst, src = ops.split(',', 1)
                rsp = '[rsp' in ops
                if '[' in dst:
                    out[a] = 'stack store' if rsp else 'heap/vm store'
                else:
                    out[a] = 'stack load' if rsp else ('const load' if '[rip' in ops else 'heap/vm load')
                continue
            if re.search(r',(0x[0-9a-f]+|-?\d+)$', ops):
                out[a] = 'mov imm'
            else:
                out[a] = 'mov reg-reg'
            continue
        if mn == 'xor' and re.match(r'(\w+),\1$', ops):
            out[a] = 'mov imm'
            continue
        if mn == 'lea':
            out[a] = 'lea (stack addr)' if '[rsp' in ops else 'lea'
            continue
        if mn in ('push', 'pop'):
            out[a] = 'push/pop'
            continue
        if mn == 'jmp':
            out[a] = 'jmp'
            continue
        if mn.startswith('j'):
            out[a] = 'jcc (other)'
            continue
        if mn in ('cmp', 'test'):
            out[a] = 'cmp/test (other)'
            continue
        if mn.startswith('set') or mn.startswith('cmov'):
            out[a] = 'setcc/cmov (other)'
            continue
        if mn in ('add', 'sub', 'imul', 'inc', 'dec', 'neg', 'adc', 'sbb', 'shl', 'sar', 'shr'):
            out[a] = 'arith'
            continue
        if mn in ('and', 'or', 'xor', 'not'):
            out[a] = 'logic'
            continue
        if mn == 'ret':
            out[a] = 'frame: epilogue'
            continue
        out[a] = 'other:' + mn
    return out


def main():
    cg, jitmap, runs, outdir = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
    os.makedirs(outdir, exist_ok=True)
    events, self_cost, addr_fn, calls, totals = parse_callgrind(cg)
    funcs, ranges = load_jitmap(jitmap)
    E = len(events)
    ir = events.index('Ir')

    def per(v):
        return v / runs

    KEY = [e for e in ('Ir', 'Dr', 'Dw', 'Bc', 'Bcm', 'Bi', 'D1mr', 'D1mw') if e in events]
    KI = [events.index(e) for e in KEY]

    def ev(v, width=11):
        return '  '.join(f'{events[i]}={per(v[i]):>{width},.1f}' for i in KI)

    def short(name):
        return (name or '?').replace('botlish_native::runtime::ops::', '').replace('botlish_native::runtime::', 'runtime::')

    # --- exclusive cost per function -------------------------------------
    fn_cost = collections.defaultdict(lambda: [0] * E)
    fn_kind = {}
    jit_insn_cost = {}
    for addr, vals in self_cost.items():
        r = jit_lookup(ranges, addr)
        if r:
            f, part = r[2], r[3]
            key = f"[botlish] {f['id']} {f['name']}" + (' (generic entry)' if part == 'entry' else '')
            fn_kind[key] = 'botlish'
            jit_insn_cost[addr] = (r, vals)
        else:
            obj, fn = addr_fn.get(addr, ('?', '?'))
            ob = os.path.basename(obj or '?')
            if 'botlish-native' in ob:
                kind = 'runtime' if (fn or '').startswith('rt_') or '::runtime::' in (fn or '') else 'rust-other'
            elif ob.startswith('libc') or ob.startswith('ld-'):
                kind = 'libc'
            else:
                kind = 'other'
            key = f"[{kind}] {fn}"
            fn_kind[key] = kind
        c = fn_cost[key]
        for i, v in enumerate(vals):
            c[i] += v
    total = [sum(c[i] for c in fn_cost.values()) for i in range(E)]

    # --- calls ---------------------------------------------------------------
    jit_calls = collections.defaultdict(int)          # callee botlish fn -> count
    jit_call_sites = collections.defaultdict(int)     # (caller, callee) -> count
    jit_call_incl = collections.defaultdict(lambda: [0] * E)  # callee -> inclusive cost of its calls
    helper_calls = collections.defaultdict(int)       # helper name -> count (from JIT code)
    helper_incl = collections.defaultdict(lambda: [0] * E)
    helper_sites = collections.defaultdict(int)       # (caller botlish fn, helper) -> count
    other_calls = collections.defaultdict(int)        # (caller fn, callee fn) outside JIT
    for caller_fn, site, cobj, cfn, target, count, vals in calls:
        src = jit_lookup(ranges, site)
        dst = jit_lookup(ranges, target)
        src_name = f"{src[2]['id']} {src[2]['name']}" + (' (entry)' if src and src[3] == 'entry' else '') if src else caller_fn
        if dst:
            dname = f"{dst[2]['id']} {dst[2]['name']}" + (' (generic entry)' if dst[3] == 'entry' else '')
            jit_calls[dname] += count
            jit_call_sites[(src_name, dname)] += count
            if not (src and src[2] is dst[2]):
                jc = jit_call_incl[dname]
                for i, v in enumerate(vals):
                    jc[i] += v
        elif src:
            helper_calls[cfn] += count
            helper_sites[(src_name, cfn)] += count
            hc = helper_incl[cfn]
            for i, v in enumerate(vals):
                hc[i] += v
        else:
            other_calls[(caller_fn, cfn)] += count

    kind_tot = collections.defaultdict(lambda: [0] * E)
    for k, c in fn_cost.items():
        kt = kind_tot[fn_kind[k]]
        for i, v in enumerate(c):
            kt[i] += v

    lines = []
    lines.append(f'events: {" ".join(events)}')
    lines.append(f'runs collected: {runs} (per-run figures below = total / runs)')
    lines.append('totals per run: ' + '  '.join(f'{e}={per(v):,.0f}' for e, v in zip(events, total)))
    lines.append('(Ir = executed instructions; Dr/Dw = data reads/writes; Bc/Bcm = conditional branches / mispredicted;'
                 ' Bi = indirect branches; D1mr/D1mw = L1 data misses -- callgrind simulated)')
    lines.append('')
    lines.append('== exclusive cost by code kind (per run)')
    for k in sorted(kind_tot, key=lambda k: -kind_tot[k][ir]):
        v = kind_tot[k]
        lines.append(f'  {k:<12} {100 * v[ir] / total[ir]:5.1f}% of Ir  ' + ev(v, 12))
    lines.append('')
    lines.append('== exclusive cost per function (per run, sorted by Ir; >= 0.1% of Ir)')
    for k in sorted(fn_cost, key=lambda k: -fn_cost[k][ir]):
        v = fn_cost[k]
        if v[ir] < 0.001 * total[ir]:
            continue
        lines.append(f'  {100 * v[ir] / total[ir]:6.2f}%  {short(k)[:70]:<70} ' + ev(v))
    lines.append('')
    lines.append('== Botlish -> Botlish calls, per callee (per run): count; INCLUSIVE cost of the non-self calls')
    for k in sorted(jit_calls, key=lambda k: -jit_calls[k]):
        v = jit_call_incl[k]
        lines.append(f'  {per(jit_calls[k]):>12,.1f}  {k:<40} incl {100 * v[ir] / total[ir]:6.2f}% of Ir  ' + ev(v))
    lines.append('')
    lines.append('== Botlish -> Botlish calls, per caller -> callee (per run)')
    for (a, b) in sorted(jit_call_sites, key=lambda k: -jit_call_sites[k]):
        lines.append(f'  {per(jit_call_sites[(a, b)]):>12,.1f}  {a}  ->  {b}')
    lines.append('')
    lines.append('== Botlish -> runtime/libc calls, per helper: count and INCLUSIVE cost (per run)')
    for k in sorted(helper_calls, key=lambda k: -helper_incl[k][ir]):
        v = helper_incl[k]
        lines.append(f'  {short(k)[:60]:<60} calls={per(helper_calls[k]):>10,.1f}  {100 * v[ir] / total[ir]:5.2f}% of Ir  '
                     f'{v[ir] / max(helper_calls[k], 1):7.1f} Ir/call  ' + ev(v))
    lines.append('')
    lines.append('== Botlish -> helper calls, per calling Botlish function (per run)')
    for (a, b) in sorted(helper_sites, key=lambda k: -helper_sites[k]):
        lines.append(f'  {per(helper_sites[(a, b)]):>12,.1f}  {a}  ->  {short(b)}')
    lines.append('')
    lines.append('== calls made outside Botlish code, caller -> callee (per run; top 60)')
    for (a, b) in sorted(other_calls, key=lambda k: -other_calls[k])[:60]:
        lines.append(f'  {per(other_calls[(a, b)]):>12,.1f}  {short(a)}  ->  {short(b)}')
    with open(os.path.join(outdir, 'profile.txt'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')

    # --- per-instruction JIT listing and executed mix ----------------------
    dis = {}
    classes = {}
    jit_starts = set()
    for fn in funcs:
        jit_starts.add(fn['direct'])
        jit_starts.add(fn['entry'])
    for fn in funcs:
        for hexbytes, vma in ((fn['dhex'], fn['direct']), (fn['ehex'], fn['entry'])):
            d = disassemble(hexbytes, vma)
            dis.update(d)
            classes.update(classify_function(sorted(d.items()), jit_starts))
    # Execution count of an instruction = its Ir (callgrind counts one Ir per
    # executed instruction).
    mix_by_fn = collections.defaultdict(lambda: collections.defaultdict(lambda: [0] * E))
    mix_total = collections.defaultdict(lambda: [0] * E)
    listing = []
    for addr in sorted(jit_insn_cost):
        r, vals = jit_insn_cost[addr]
        f, part = r[2], r[3]
        text = dis.get(addr, '?')
        cls = classes.get(addr, '?')
        key = f"{f['id']} {f['name']}" + (' (generic entry)' if part == 'entry' else '')
        m = mix_by_fn[key][cls]
        for i, v in enumerate(vals):
            m[i] += v
            mix_total[cls][i] += v
        listing.append(f'{addr:#x}  {per(vals[ir]):>10,.1f}  ' + ' '.join(f'{e}={per(x):,.1f}' for e, x in zip(events, vals) if e != 'Ir' and x)
                       + f'  [{key} +{addr - (f["direct"] if part == "direct" else f["entry"]):#x}]  {cls:<18} {text}')
    with open(os.path.join(outdir, 'instr.txt'), 'w', encoding='utf-8') as f:
        f.write('# addr  executions/run  other events/run  [function +offset]  class  instruction\n')
        f.write('\n'.join(listing) + '\n')
    jit_total = sum(v[ir] for v in mix_total.values())
    ml = []
    ml.append(f'executed Botlish-code instructions per run: {per(jit_total):,.0f} '
              f'({100 * jit_total / total[ir]:.1f}% of all Ir)')
    ml.append('')
    ml.append('== total executed JIT instruction mix (per run)')
    for cls in sorted(mix_total, key=lambda c: -mix_total[c][ir]):
        v = mix_total[cls]
        ml.append(f'  {cls:<20} {per(v[ir]):>12,.1f}  {100 * v[ir] / max(jit_total, 1):5.1f}%'
                  + ''.join(f'  {e}={per(x):,.1f}' for e, x in zip(events, v) if e != 'Ir' and x))
    for key in sorted(mix_by_fn, key=lambda k: -sum(v[ir] for v in mix_by_fn[k].values())):
        fsum = sum(v[ir] for v in mix_by_fn[key].values())
        if fsum < 0.001 * jit_total:
            continue
        ml.append('')
        ml.append(f'== {key}: {per(fsum):,.1f} executed instructions per run ({100 * fsum / max(jit_total, 1):.1f}% of JIT)')
        for cls in sorted(mix_by_fn[key], key=lambda c: -mix_by_fn[key][c][ir]):
            v = mix_by_fn[key][cls]
            ml.append(f'  {cls:<20} {per(v[ir]):>12,.1f}  {100 * v[ir] / fsum:5.1f}%')
    with open(os.path.join(outdir, 'mix.txt'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(ml) + '\n')
    print(f'{outdir}: Ir/run={per(total[ir]):,.0f}; JIT share {100 * jit_total / total[ir]:.1f}%')


if __name__ == '__main__':
    main()
