#!/usr/bin/env python3
"""Render this frozen milestone's tables from measured artifacts."""
import collections, csv, json, pathlib, re, statistics
root=pathlib.Path.cwd(); base=root/'audit/post-structural-fn-dynamic-census'; out=base/'out'
records=[json.loads(x) for x in (out/'static.jsonl').read_text().splitlines()]
proofs=[json.loads(x) for x in (out/'proofs.jsonl').read_text().splitlines()]
proofs=[x for x in proofs if x.get('kind')!='sourceSite']
work=json.loads((out/'work.json').read_text())
totals={r['program']:r for r in records if r['kind']=='totals'}
instances={(r['program'],r['id']):r for r in records if r['kind']=='instance'}
functions={(r['program'],r['fid']):r for r in records if r['kind']=='function'}
def stem(p):return p.replace('/','__').removesuffix('.bot')
counts={p:list(csv.DictReader((out/(stem(p)+'.counts-0.tsv')).open(),delimiter='\t')) for p in totals}
def pct(n,d):return f'{100*n/d:.4f}%' if d else '0%'
def num(n):return f'{n:,}'
def targets(s):return re.findall(r'\{(native|block) ([^}]+)\}',s)
def block(p,fid):
    f=functions[p,str(fid)]
    label=f['name']+'<'+f['key']+'>'
    return next(i['block'] for (program,_),i in instances.items() if program==p and i['label']==label)
def targetlabel(p,t):
    if t.startswith('Native '):return t
    fid=t.split()[1];return 'Block '+block(p,fid)+' ('+functions[p,fid]['name']+')'
source={
 'list::any?':'lib/list.bot:61 predicate(x)',
 'list::all?':'lib/list.bot:67 predicate(x)',
 'list::none?':'lib/list.bot:73 predicate(x)',
 'list::find':'lib/list.bot:79 predicate(x)',
 'scan_while':'lib/web.bot:128 predicate(char_at(i))',
 'classify_leading':'bench/source-checks.bot:56 check(c)',
 'classify':'bench/lex-strategy.bot:57 classifier(c)',
}
sites=[]
for i,s in enumerate([r for r in records if r['kind']=='site'],1):
    s=dict(s);p=s['program']
    proof=next(x for x in proofs if x['program']==p and x['fid']==s['fid'])
    s.update(proof);s['sid']=f'S{i}';s['source']=source[s['name']]
    s['category']='List element' if s['name']=='classify_leading' else 'if/control-flow join' if s['name']=='classify' else 'HOF parameter'
    s['observed']=[r for r in counts[p] if r['kind']=='3' and r['fid']==s['fid'] and r['expr']==s['expr']]
    s['calls']=sum(int(r['calls']) for r in s['observed'])
    s['static_targets']=targets(s['targets']);s['k']=len(s['static_targets'])
    # This is measured existing-machine-path attribution, not a savings model.
    # rt_call_value self: 28 instructions on each successful Block path,
    # 46 on each successful Native path; invoke_native self: 71/Native;
    # generic Block entry: 7/Block. Cross-checked against profile totals below.
    s['machinery']=sum(int(r['calls'])*(117 if r['target'].startswith('Native') else 35) for r in s['observed'])
    sites.append(s)
N=sum(s['calls'] for s in sites)
assert len(sites)==9 and N==8317
for p in totals:
    if stem(p)+'-0' not in work:continue
    w=work[stem(p)+'-0'];rs=w['self']
    got=sum(v for k,v in rs.items() if k.split("'")[0].endswith('rt_call_value') or k.endswith('::invoke_native'))
    # Count only generic entries of actual dynamically observed Block targets.
    fids={int(r['target'].split()[1]) for r in counts[p] if r['kind']=='3' and r['target'].startswith('Block')}
    got+=sum(v for k,v in rs.items() if k.startswith('JIT ') and int(k.split()[1]) in fids and k.endswith(' entry'))
    assert got==sum(s['machinery'] for s in sites if s['program']==p),(p,got)
allcounts=collections.Counter()
for rows in counts.values():
    for r in rows:allcounts[r['kind']]+=int(r['calls'])
(out/'sites.json').write_text(json.dumps(sites,indent=2)+'\n')
L=[]
def add(s=''):L.append(s)
def heading(s):add('\n## '+s+'\n')
def table(headers,rows):
    add('| '+' | '.join(headers)+' |');add('| '+' | '.join('---' for _ in headers)+' |')
    for row in rows:add('| '+' | '.join(str(x).replace('|','\\|').replace('\n',' ') for x in row)+' |')
def cf_ir(name):return [int(re.search(r'total Ir/run: ([\d,]+)',(out/'counterfactual'/f'{name}-{r}'/'census.txt').read_text())[1].replace(',','')) for r in range(2)]
baseline=[work['bench__refined-checks-'+str(r)]['total'] for r in range(2)]
exact=cf_ir('exact');off=cf_ir('production-noregion');exactoff=cf_ir('exact-noregion')
saving=statistics.mean(baseline)-statistics.mean(exact)
offsave=statistics.mean(off)-statistics.mean(exactoff)
timing=json.loads((out/'timing.json').read_text())
def tm(p,mode='production'):return next(r['median_ns'] for r in timing if r['program']==p and r['mode']==mode)
add('# POST-STRUCTURAL-FN DYNAMIC CALLABLE CENSUS\n')
heading('Outcome')
add(f'''**9 compiled sites, 7 unique source expressions, {num(N)} indirect calls per natural corpus run.**
`refined-checks.bot`'s scanner contributes 8,000 calls ({pct(8000,N)}).
The three higher-order benchmarks contribute 317 calls; `uri-steady.bot`'s
compiled scanner never executes. No example adds an indirect call.

The audit can statically prove singleton code-target sets at 5 sites covering
101 executions ({pct(101,N)}). Sets of at most two cover 8 sites and
8,233 executions ({pct(8233,N)}); four cover all 9 and all {num(N)}.
These proofs come from frozen HIR and closed source provenance, independently
of runtime observations. No target facts are fed back into the compiler.

The old exact-target oracle control remains economically significant:
**{saving:,.0f} fewer foreground Ir/run ({pct(saving,statistics.mean(baseline))})**
on current surface `refined-checks.bot`, with 1,200 fewer String allocations.
This is not a predicted finite-set lowering speedup. Measured existing callable
machinery across the corpus is 401,467 Ir; caller setup, `apply_op` dispatch,
and callee bodies are excluded from that deliberately partial attribution.''')
heading('Measurement boundary and compiler/source freeze')
add('''One natural run executes each executable source program once with its own
unchanged inputs. This is a corpus sum, not a frequency estimate for all Botlish
programs. The corpus has 31 source files and 30 executable programs. The declared
duplicate-binding error example is listed but has no executable sites.

Only this report and `audit/post-structural-fn-dynamic-census/` are added.
No production compiler, library, canonical source, scalar baseline, or historical
audit is edited. HIR, specialization keys/instances, lowering, NIR, representation,
allocation policy and register allocation retain their production behavior.
Counter hooks exist only in a scratch native crate, behind `BOTLISH_CENSUS`.
Cost profiles have these hooks **disabled**. A separate historical oracle control
patches only a scratch copy of `lib/web.bot`, explicitly outside headline counts.

All 30 production/audit-off object disassemblies **including instruction bytes
and relocations** agree. Instrumented/uninstrumented values, allocations, GC
counts and live-object counters agree. GC timing fields alone are normalized.
The committed scalar audit was regenerated into the new tree and all 39
assembly/VCode/summary files match byte for byte. Pre-existing untracked
`bench/refined-checks` and `examples/stdlib/ai_text_clean` are untouched.''')
heading('Canonical corpus and historical corpus exclusions')
table(['Population','Files','Executable','Static callvalue','Dynamic callvalue'],[
['Pre-dogfooding benchmarks (fib, loop-count, sum-refined, refined-checks, uri-steady)',5,5,2,8000],
['New higher-order benchmarks',3,3,7,317],['Stdlib examples',9,9,0,0],['Surface examples',14,13,0,0],['Total',31,30,9,N]])
add('''\nEnumeration is exactly sorted `bench/*.bot`, `examples/stdlib/*.bot`, and
`examples/surface/*.bot`. No `.ir`, audit snapshot, raw HIR/NIR test fixture or
synthetic workload enters these totals. The NIR files below are *outputs* of
today's ordinary frontend, never corpus inputs. `10-duplicate-binding.bot`
produces its declared `CORE SEMANTIC DUPLICATE` error before compilation.
Full filenames and Git blob IDs: [corpus.txt](audit/post-structural-fn-dynamic-census/out/corpus.txt)
and [static.jsonl](audit/post-structural-fn-dynamic-census/out/static.jsonl).''')
heading('Tooling and provenance')
add('''Frozen compiler commit: `a8a306f986809c0a8b54f4763013070f209c248c`.
Tcl 9.0.1; rustc 1.98.1 (48a229cea, 2026-09-01); Cranelift 0.135.2;
x86-64 Linux/System V under Ubuntu 24.04 WSL; release build with debug=1;
Valgrind 3.22.0; `LANG=C.utf8 LC_ALL=C.utf8`.
Compiler options are production defaults (`specialize=1`, `repr-opt=1`,
StringRegion enabled). Native measurement stack is 64 MiB.

Pipeline: `surface::readProgramFile` → `hir::lower` →
`native::buildProgramHir` → `native::lower::program`, matching `bench/bench.tcl`.
Source HIR types are also recorded to distinguish them from instance views.

Static census/NIR are reproduced twice byte-identically. Two independent natural
native executions produce identical counters, target sets and object counts.
Each independent Callgrind profile collects one natural run after one excluded
warmup, using the established `botlish_audit_run` anchor and JIT address map.
There are two profiles per program/control. JIT compilation and between-run
reset reclamation are excluded; GC *during* a run is included. No outer source
loops are added. Ir is executed machine instructions, not NIR operations.

Wall-clock corroboration: five sessions, one warmup plus twenty whole-program
runs each; median of session medians, compilation excluded. It is not used to
rank sites. Full host/toolchain, source SHA-256s, blob/tree IDs, executable hashes,
NIR hashes and mode details are in
[provenance.json](audit/post-structural-fn-dynamic-census/out/provenance.json).
[README](audit/post-structural-fn-dynamic-census/README.md) gives reproduction commands.''')
heading('Static callable census and per-program dynamic totals')
table(['Program','Used instances','call','callenv','callvalue','closure','capture','fnvalue','native','Dynamic callvalue','Dominant site'],[
[p,int(t['instances']),*[int(t[k]) for k in ['call','callenv','callvalue','closure','capture','fnvalue','native']],sum(s['calls'] for s in sites if s['program']==p),next((s['sid'] for s in sorted(sites,key=lambda s:-s['calls']) if s['program']==p and s['calls']), 'none')]
for p,t in totals.items()])
add('''\nThe negative example has no used instances or generated sites. Counts are NIR
instructions, not source call expressions. `native` counts callable-value
materializations, not every inlined native operation. `callmulti` and
`callenvmulti` are separately preserved in `static.jsonl` (the displayed `call`
column does not silently include them). The benchmark total is exactly 9.''')
heading('Unique source sites versus compiled sites')
table(['Source expression','Programs','Compiled sites','Dynamic executions'],[
[src,', '.join(s['program'] for s in sites if s['source']==src),sum(s['source']==src for s in sites),sum(s['calls'] for s in sites if s['source']==src)] for src in dict.fromkeys(s['source'] for s in sites)])
add('''\nStable IDs below combine canonical program, source helper/location, instance
label and expression ID. `S1`–`S9` are table aliases; machine addresses are only
profile lookup keys. `e216` in two programs is two compiled sites. Code target
IDs are also scoped to their program.

Source-metadata observation: assembled surface HIR sometimes reports the entry
program's filename beside imported library line/node data (e.g. `list::any?`
at line 61). The source labels above were checked against `lib/list.bot` and
`lib/web.bot` definitions and module provenance, rather than trusting that
filename alone. This pre-existing attribution issue is reported, not fixed.''')
heading('Per-site results: static facts and dynamic populations')
table(['ID / program','Source site / instance / expr','Provenance','Full inferred callee type in used instance','Audit-only static code-target set','Calls','Observed target count','Observed targets: counts; objects','Capturing?'],[
[s['sid']+' '+s['program'],s['source']+'; '+s['label']+'/'+s['instance']+' @'+s['expr'],s['category'],s['type'],s['targets'],num(s['calls']),len(s['observed']),'; '.join(targetlabel(s['program'],r['target'])+': '+r['calls']+'; objects='+r['objects'] for r in s['observed']) or '0 targets (unexecuted)', '; '.join(r['target']+': '+('yes, '+r['captures']+' runtime capture(s)' if int(r['captures']) else 'envless / Native') for r in s['observed']) or 'statically mixed Native/capturing Block'] for s in sites])
add('''\nNo site has a production exact target. The eight executed sites have observed
sets equal to their independently recovered static sets. S9's two-element
static set strictly contains the empty observed set. There are no unknown static
sets after this audit's explicit source-provenance tracing. An observed
singleton alone is never treated as proof. Full caller witnesses and intermediate
unions: [proof-witnesses.txt](audit/post-structural-fn-dynamic-census/out/proof-witnesses.txt).
The trace follows immutable aliases, exact factory result types, compatible
branches/List elements, and known callers, including captured outer parameters.
It is a deliberately limited offline witness extractor, not a production pass
or a general soundness theorem for arbitrary programs.''')
heading('Structural Fn precision and error contracts')
table(['Current callee knowledge','Compiled sites','Executions','Share'],[
['Structural Fn',2,216,pct(216,N)],['Bare block/native',5,101,pct(101,N)],['any',2,8000,pct(8000,N)]])
add('''\nThe structural milestone does **not** make all nine instance parameters Fn.
The seven HOF sites still expose bare callable kinds or `any`; specialization
keys erase the exact callable arguments. Local List and strategy joins retain
`Fn{args: [any], return: bool, errors: []}` in whole-program/source HIR, and
`Fn{args: [any], return: any, errors: []}` in their used instance views.
This precision difference is also present in the prior structural-type audit;
it is not caused by instrumentation.

Both structural sites have `errors: []`; there are no nonempty structural Fn
error sets here. The other seven have no structural Fn error contract to count;
do not describe them as seven fully typed error-free Fn sites. Their recovered
actual predicates have no declared checked errors. `list::find` itself can
raise `NotFound`, independently of its predicate, and the canonical handlers
remain intact. No error-bearing control was invented.''')
heading('HOF ingress: every used instance and actual caller')
ingress=[]
for s in sites:
    if s['category']!='HOF parameter':continue
    for c in records:
        if c['kind']!='call' or c['program']!=s['program'] or c['targetInstance']!=s['instance']:continue
        a=next(a for a in records if a['kind']=='argument' and a['program']==s['program'] and a['instance']==c['instance'] and a['call']==c['expr'] and a['index']=='1')
        ingress.append([s['sid']+' '+s['label']+'/'+s['instance'],'predicate',instances[s['program'],c['instance']]['label']+'/'+c['instance']+' @'+c['expr'],a['expr']+' : '+a['type'],a['rawtype'] if len(a['rawtype'].split())>1 else 'not exact here; trace outer callers',a['captures'] or 'none / unknown for bare kind',s['targets']])
table(['Site / contributing instance','Parameter','Actual caller','Full callable argument type','Immediate exact fact','Lexical captures','Offline union'],ingress)
add('''\n`list::any?` has one used predicate instance with **two actual compiled caller
instances**, both at source expression e75: `affected?<list, block>` and
`affected?<any, block>`. Their immediate arguments are bare `block`, not exact.
Tracing `changed?` through `select_affected`, and through `is_affected?`'s
capture from `first_affected`, reaches the exact `Block e55` factory result.
`select_affected` has two root callers (e236/e241, changed_a?/changed_b?);
`first_affected` has root caller e263. Each full root argument type is
`block(e55)/1 -> any`. The witness file records all intervening caller sites.
Thus a **single pass using only already-exact immediate ingress** covers 6 HOF
sites / 8,049 calls; propagating those ingress facts through the closed caller
chain covers all 7 HOF sites / 8,101 calls. Neither result needs List/if joins.''')
heading('scan_while and web::emailish? continuity')
add('''Two compiled predicate sites represent **one** library source expression,
`lib/web.bot:128`. Both used instances are `scan_while<generic>` (i20, e216).
Each has two known callers: local-part scanning passes exact `Block e183`
(`local_char?`), and TLD scanning passes exact `Native is_tcl_alpha`.
The static union is two targets in each program. In `refined-checks`, e183 is
envless; in `uri-steady` it captures a lexical value under this pipeline.

`refined-checks` executes 1,200 helper activations and 8,000 predicate dispatches:
6,800 to e183 and 1,200 to is_tcl_alpha. `uri-steady` executes zero helper
activations and zero predicate calls: its URI workload never calls emailish?.
The source aggregation is therefore 8,000 calls, **96.1885%** of all callvalue
executions. The scanner remains dominant. Potential scan-range lengths were
not separately profiled; inspected elements equal the 8,000 measured predicates.''')
heading('list::any?, list::all?, list::none? and list::find; early exit')
table(['Helper / program','Used predicate instances','Static sites','Helper activations','Potential elements','Inspected / predicate calls','Static and observed set'],[
['any? / test-selection',1,1,31,54,52,'Block e55, capturing'],
['all? / lex-strategy',1,1,8,66,38,'Native is_tcl_alnum'],
['none? / test-selection',1,1,1,2,2,'Block e55, capturing'],
['find / test-selection',1,1,1,14,3,'Block e98, capturing'],
['find / source-checks',1,1,1,16,6,'Block e114, capturing']])
add('''\nHelper activations are measured direct NIR calls; potential lengths are
checked from the unchanged input literals and those activations, not estimated
from total runtime. `any?` traverses two complete groups-of-tests selections
(24 dependency slots each), plus the first three groups inspected by `find`
(6 slots): 54 possible, 52 inspected. `all?` receives 66 total characters but
inspects only 38 due to early false results. `find` inspects only 3/14 and 6/16.

The clean one-caller/one-target control is S1: `fully_alnum?` passes exact
`native is_tcl_alnum` at e164/e172. Its 38 calls contribute 4,446 measured Ir
in common/native callable machinery, with another 2,846 Ir in the remaining
dispatch-plus-callee subtree. Exact net savings are not measured for this
individual site. Singleton refinement would reach it without a multi-target test.''')
heading('Callable List site')
add('''`checks` is `List[Fn{args: [any], return: bool, errors: []}]` in whole-program
HIR. The used generic `classify_leading` view widens the element return to any;
the callee remains structural Fn. Its immutable literal contains exactly
`Native is_tcl_alpha`, `Native is_tcl_alnum`, envless `Block e49`
(`is_underscore?`) and envless `Block e55` (`is_hyphen?`). The literal union
proves four code targets without positional analysis.

22 `classify_leading` activations include one empty-name short circuit; 21
nonempty names invoke four checks each. S5 executes **84** calls, **21 per
target**, 1.0100% of all indirect calls. It accounts for 6,384 measured callable
machinery Ir (about 8.4% of this small program), versus 8,101 HOF dispatches
across the corpus. This is a real mixed-target acceptance case, but not the
main corpus-wide performance opportunity.''')
heading('If-selected strategy site')
add('''The strict branch is exact `native is_tcl_alnum`; the relaxed branch is
exact `block(e49)/1 -> bool` (`lenient_ident_char?`) in source HIR, and
`block(e49)/1 -> any` in the instance view. Their join is
`Fn{args: [any], return: bool, errors: []}` in source HIR and the same args/errors
with return any in the instance. The recoverable union is exactly those two
code targets, Native plus envless Block.

S2 makes **132** calls: 66 per target across 16 `classify` activations.
The chosen classifier is invariant within each activation, selected before
the character loop. Its measured callable machinery is 10,032 Ir (about 3.1%
of lex-strategy), and its whole callvalue subtree is 21,356 Ir, including
callee bodies. Singleton-only refinement does not reach it; K=2 does.''')
heading('Code target versus closure environment identity; capturing closure sites')
add('''S6 (`any?`) observes **two closure objects, one code target e55**, over
changed_a and changed_b. These objects come from two factory activations over
different immutable sets. S7 (`none?`) observes only changed_a: one object/e55.
S8 (`find`) observes one object/e98, capturing changed_a through is_affected?.
S4 (`find` in source-checks) observes one object/e114, capturing valid_start?.
All four require a dynamic environment even with singleton code identity;
their hypothetical exact path is `callenv`. There are **63** such indirect calls.

Runtime capture counts can be smaller than lexical capture lists: envless
function references can be eliminated from the environment by existing code.
Object counts come from per-natural-run identity sets; they are not added
across sites (the same changed_a object occurs in S6 and S7). None of these
small closure-control programs collects during its natural run, so address
reuse cannot hide additional objects. Native/envless callable objects are
program constants, not per-call allocations.''')
heading('Target-cardinality distribution and K=1/2/4/8 coverage')
table(['Observed population','Sites','Dynamic executions','Share'],[
['Singleton observed (also independently proved here)',5,101,pct(101,N)],['2 observed targets',2,8132,pct(8132,N)],['3–4 observed targets',1,84,pct(84,N)],['>4',0,0,'0%'],['Unexecuted / no observed population',1,0,'0%'],['Unresolved executed target',0,0,'0%']])
add('\nPrimary coverage uses **statically provable** sets, including the dormant two-target site:\n')
table(['K','Static sites covered','Static-site %','Dynamic calls covered','Dynamic-call %'],[
[k,sum(s['k']<=k for s in sites),pct(sum(s['k']<=k for s in sites),9),sum(s['calls'] for s in sites if s['k']<=k),pct(sum(s['calls'] for s in sites if s['k']<=k),N)] for k in [1,2,4,8]])
add('''\nK=1 has high *site* coverage and low *execution* coverage. K=2 reaches the
hot scanner and strategy; K=4 additionally reaches the List site. K=8 adds
nothing in this corpus. These are coverage observations, not a selected compiler
cap or an assumption that finite dispatch is free.''')
heading('Provenance-category aggregation')
table(['Category','Compiled sites','Unique source sites','Dynamic calls','Share','Provably finite-covered calls'],[
[category,len(ss),len({s['source'] for s in ss}),sum(s['calls'] for s in ss),pct(sum(s['calls'] for s in ss),N),sum(s['calls'] for s in ss if s['k'])]
for category in ['HOF parameter','List element','if/control-flow join','other'] for ss in [[s for s in sites if s['category']==category]]])
heading('Top dynamic sites / Pareto distribution')
ranked=sorted(sites,key=lambda s:-s['calls']);running=0;rows=[]
for rank,s in enumerate(ranked,1):
    running+=s['calls'];rows.append([rank,s['sid']+' '+s['program']+' '+s['name'],s['calls'],pct(s['calls'],N),pct(running,N),s['machinery']])
table(['Rank','Site','Indirect calls','Share','Cumulative share','Attributed machinery Ir'],rows)
add('''\nBy attributable machinery work the order is **S3, S2, S5, S1, S6, S4,
S8, S7, S9**: native-only S1 has fewer invocations than S6 but more measured
dispatch machinery. These are instruction counts, not a weighted score, and
say nothing against HOFs, Lists or closures as language features.''')
heading('Whole-corpus callable invocation totals')
table(['Executed NIR form','Natural corpus total'],[[n,allcounts[k]] for k,n in [('1','call'),('2','callenv'),('3','callvalue'),('4','callmulti'),('5','callenvmulti'),('6','tail/tailenv backedges (separate)')]])
den=sum(allcounts[k] for k in ['1','2','3','4','5'])
add(f'''\nTotal non-tail emitted Block/callable invocations: **{num(den)}**;
callvalue share **{pct(N,den)}**. Restricting the denominator to the requested
literal `call + callenv + callvalue` gives {num(sum(allcounts[k] for k in ['1','2','3']))}
and {pct(N,sum(allcounts[k] for k in ['1','2','3']))}. Tail backedges are shown
separately because they have no call instruction. Inlined native primitives
are not counted as calls; this is not a source-level count of every operation.''')
heading('AOT status')
table(['Site','Used instance region status','Callable fact'],[[s['sid'],instances[s['program'],s['instance']]['aot'],s['type']] for s in sites])
add('''\nThese are existing `hir::aot::analyzeRegion` results on each used instance
view. Region status includes the rest of the function and its checked-error /
representation issues: it is not solely a label on callvalue. A closed AOT
region (classify) can still use structurally known indirect dispatch. Scanner
parameters remain `any`/open; structural local joins no longer require an
unknown callable-kind semantic blocker. AOT policy is unchanged.''')
heading('Allocation observations')
table(['Program','Natural heap Block creations','Indirect calls','Closure-creation relationship'],[
['refined-checks',0,8000,'local_char? is an envless constant'],['lex-strategy',0,170,'envless Block and Native constants'],['source-checks',3,90,'classify_leading / valid_start? / invalid_name? closure chain'],['test-selection',3,57,'two changed? environments and one is_affected? environment'],['uri-steady',2,0,'closure values created despite zero indirect executions']])
add('''\nSuccessful `rt_call_value` dispatch itself makes **zero Botlish allocations**
on these paths. Block dispatch checks kind/arity then calls the generic entry;
Native dispatch checks the contract and invokes its operation. Callee work,
argument construction and closure creation are separate. In particular, the
8,000 scanner character Strings are created by `char_at` before dispatch, not
by rt_call_value. Exactness can expose existing StringRegion optimization,
but that is an additional consequence, not dispatch's own allocation cost.
Production `*.production.txt` files contain allocation summaries for every
executable program; instrumentation preserves them.''')
heading('Dispatch-cost attribution and instrumentation overhead')
add('''The exact shared helper paths are 28 self Ir per successful Block dispatch
and 46 per Native dispatch; `invoke_native` contributes 71 self Ir per Native,
and each used Block generic-entry trampoline contributes 7. These are counts
of the current compiled machine paths, cross-checked against every profile's
exclusive helper/entry totals in `report.py`, not arbitrary importance weights.
Per-site attribution multiplies the **measured** per-target invocation counts
by these verified fixed path lengths. This yields 35 Ir/Block and 117 Ir/Native
for the explicitly named machinery subset. It excludes caller argument-array
setup, guards in callee bodies, `apply_op`'s mixed dispatch/body instructions,
and the target body itself. It is not an exact recoverable-savings prediction.

Total: rt_call_value self 257,104 Ir + native contract/dispatch self 95,566 Ir
+ generic Block entries 48,797 Ir = **401,467 Ir**. Pure indirect-dispatch
**net optimization savings** cannot be isolated from all caller/callee changes
without a more specific counterfactual; that field is not measured here.

Callgrind's whole-program totals vary between independent processes. We stopped
interpretation and compared exclusive per-function work: all differences are
in libc malloc/free/realloc bookkeeping, unlink/consolidation, or memcpy paths.
Every generated-code and callable-runtime instruction count repeats exactly.
Thus whole totals are intervals, not claimed deterministic integers. Details:
[repeatability.txt](audit/post-structural-fn-dynamic-census/out/repeatability.txt).
The current reducer also sums recursive Callgrind contexts (`rt_call_value'2`)
and counts each machine call instruction once; the historical text reducer's
unmerged source-checks arcs must not be mistaken for separate static sites.''')
costrows=[]
for p in ['bench/refined-checks.bot','bench/test-selection.bot','bench/source-checks.bot','bench/lex-strategy.bot','bench/uri-steady.bot']:
    ws=[work[stem(p)+'-'+str(i)] for i in range(2)];irs=[w['total'] for w in ws];m=sum(s['machinery'] for s in sites if s['program']==p)
    costrows.append([p,f'{min(irs):,}–{max(irs):,}',m,pct(m,statistics.mean(irs)),f'{tm(stem(p))/1000:.3f}',f'{tm(stem(p),"target-tracking")/tm(stem(p)):.2f}×'])
table(['Program','Uncounted profile Ir/run range','Attributed machinery Ir','Share of program Ir','Production median µs','Tracking / production time'],costrows)
add('''\nCounter hooks record all emitted Block calls and allocate Rust-side BTreeMap /
identity-set entries; they allocate nothing in the Botlish heap, trigger no
Botlish GC and retain no Botlish roots. Their substantial overhead is why
counted execution times are never used as dispatch cost. Counter-only mode
was not measured separately. The audit-off timing controls and full samples
are in `timing.json`; short-run noise precludes conclusions from small
audit-off/production differences. Callgrind has its own execution overhead;
its wall time is not used.

Per-site inclusive subtrees (dispatch **plus callee**) are also measured.
Nested subtrees overlap: S4 includes some S5 work and S8 includes some S6.
They must not be summed as program overhead. These are supplied as body-work
context only; the exclusive machinery table avoids that double counting.''')
inclusive=[]
for s in sites:
    vals=[]
    for rep in range(2):
        vals.append(sum(x['inclusive_ir'] for x in work[stem(s['program'])+'-'+str(rep)]['sites'] if x['fid']==int(s['fid'])))
    inclusive.append([s['sid'],f'{min(vals):,}–{max(vals):,}',s['machinery']])
table(['Site','Inclusive subtree Ir range','Exclusive attributed machinery Ir'],inclusive)
heading('Counterfactual ceilings and the remaining exact-target oracle')
table(['Control on current refined-checks.bot','Foreground Ir/run (two profiles)','Mean saving vs corresponding production'],[
['Production',f'{min(baseline):,}–{max(baseline):,}','—'],['Oracle exact scanner clones',f'{min(exact):,}–{max(exact):,}',f'{saving:,.0f} ({pct(saving,statistics.mean(baseline))})'],
['Production, StringRegion disabled',f'{min(off):,}–{max(off):,}','—'],['Oracle exact, StringRegion disabled',f'{min(exactoff):,}–{max(exactoff):,}',f'{offsave:,.1f}']])
add(f'''\nThe unchanged historical `exact-target.diff` is applied to a fresh scratch
copy only. It splits scan_while into scan_local and scan_alpha and substitutes
the statically known predicate at each existing caller. The canonical
`bench/refined-checks.bot` is byte-identical. This is the existing supported
oracle control, **not an implementation of bounded target sets or dispatch**.
All control values equal `[400, 0]`.

The no-StringRegion differential is {offsave:,.1f} Ir; the remaining
{saving-offsave:,.1f} Ir of the foreground differential is exposure of existing
StringRegion effects (an interaction decomposition, not two independent passes).
Strings fall from 8,004 to 6,804; Block allocations stay zero. Callee body work
and closure creation are not mislabeled as dispatch. Deferred reset/reclamation
and total lifecycle savings are **not measured** in this fresh census.

Wall-clock corroboration is {tm('bench__refined-checks')/1000:.3f} →
{tm('counterfactual/exact')/1000:.3f} µs, median of five session medians,
{pct(tm('bench__refined-checks')-tm('counterfactual/exact'),tm('bench__refined-checks'))} lower.
The instruction differential is the stronger economic evidence. Different
malloc layouts account for the small Ir intervals; no callable or generated
instruction count varies. No finite multi-target branch cost is assumed zero.''')
def codebytes(path):
    total=0
    for line in path.read_text().splitlines():
        m=re.match(r'\d+ "[^"]*" 0x[0-9a-f]+ (\d+) 0x[0-9a-f]+ (\d+) ',line)
        if m:total+=int(m[1])+int(m[2])
    return total
bb=codebytes(out/'profiles/bench__refined-checks-0/jitmap.txt')
cb=codebytes(out/'counterfactual/exact-0/jitmap.txt')
add(f'\nGenerated JIT machine bytes (direct bodies plus generic entries): '
    f'{bb:,} production → {cb:,} exact control, signed change {cb-bb:+,} bytes. '
    'These are measured code sizes, not a proposed lowering budget.')
heading('Singleton-only, HOF-ingress-only, local-LUB-only and combined ceilings')
table(['Hypothetical scope','Sites','Executions','Execution coverage','Current attributable machinery Ir (not net savings)'],[
['Provable singleton only',5,101,pct(101,N),sum(s['machinery'] for s in sites if s['k']==1)],
['HOF immediate already-exact caller facts only',6,8049,pct(8049,N),sum(s['machinery'] for s in sites if s['category']=='HOF parameter' and s['name']!='list::any?')],
['HOF ingress through known caller chain',7,8101,pct(8101,N),sum(s['machinery'] for s in sites if s['category']=='HOF parameter')],
['Local Fn joins only (List + if/return-result)',2,216,pct(216,N),sum(s['machinery'] for s in sites if s['category']!='HOF parameter')],
['Union of HOF ingress and local joins',9,N,'100%',401467],['Intersection / double-counted sites',0,0,'0%',0]])
add('''\nSingleton-only net Ir/runtime ceiling: **not measured**; 6,651 Ir is merely
the named current machinery at those 101 calls. K=2 and K=4 execution ceilings
are 8,233 and 8,317 respectively; their net savings are **not measured** because
no trusted finite-branch dispatch model was added. The scanner oracle gives
the broader recoverable opportunity conditional on achieving equivalent exact
facts and region exposure. It cannot be added to the machinery total.

Local-only tracing includes following choose_classifier's existing returned
Fn result and immutable aliases; it needs no HOF parameter ingress. No additional
returning-loop callable-collection provenance contributes a site here.
The same-code factory uses an existing exact Block result, not a new local
multi-target join. None of these offline facts modifies a compiler type.''')
heading('Historical comparison and stable-subset comparison')
add('''[POST-R2A-DYNAMIC-CENSUS](POST-R2A-DYNAMIC-CENSUS.md) measured the older
raw-IR era. [POST-MODULE-STATIC-EXACT-TARGET-CENSUS](POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md)
reported 8,191,901 → 6,786,030 foreground Ir on `bench/refined-checks.ir`:
1,405,871 saved (17.16%), including 1,200 fewer Strings. The new source-only
control measures approximately 17.46%, so the opportunity remains of the same
order. This is **not** a pure compiler improvement/regression delta: the old
raw input, frontend route, corpus composition, runtime build/layout and host
measurement boundary differ. Today's baseline is 8.248M rather than 8.192M.

**Stable-subset comparison:** the motivating email workload's actual predicate
population still executes 6,800 local_char? + 1,200 is_tcl_alpha calls, and
the exact oracle still removes 1,200 Strings. Those natural counts are directly
comparable for that preserved workload. Absolute instruction totals across
the raw-IR/surface migration are not attributed to structural Fn. The original
five benchmark *names* form a current subset with two compiled sites but only
one executed site / 8,000 calls; old tooling's extra .ir rows are excluded.
The historical module audit omitted emailish? from uri-steady's compiled
program; today's surface pipeline contains a dormant scanner site. This is a
static corpus/pipeline difference, not an extra dynamic cost.

[HIGHER-ORDER-DOGFOODING](HIGHER-ORDER-DOGFOODING.md) added seven compiled
sites in three programs. They contribute 317 natural calls here, broadening
target provenance and environment cases while leaving scan_while dominant.
[STRUCTURAL-FUNCTION-TYPES](STRUCTURAL-FUNCTION-TYPES.md) kept all nine sites
and byte-identical generated code, while preserving local structural contracts.
This census reproduces its full type boundary outputs and the committed scalar
baseline. There is no evidence here of a structural-Fn code-generation change.''')
heading('Residual unknown sites and hypothetical lowering classes')
table(['Future class (evidence only)','Sites','Dynamic calls'],[
['Singleton Native','S1',38],['Singleton envless Block','none',0],['Singleton capturing Block','S4, S6, S7, S8',63],
['Finite Native-only','none',0],['Finite Block-only','none',0],['Finite mixed Native/Block','S2, S3, S5, S9',8216],['Unknown','none',0]])
add('''\nThere are no observed mixed envless/capturing Block-only populations. The
executed finite mixed cases use envless Blocks; S9 statically includes a
capturing Block but has no observed executions. Four static finite mixed sites,
three executed. A K=1 cap leaves S2/S3/S5/S9 (8,216 calls); K=2 leaves S5
(84 calls); K=4 leaves none. HOF-only leaves S2/S5; local-only leaves the seven
HOF sites. No site remains unknown due to genuinely absent/open target
provenance in this closed corpus. That does not establish a closed-world
property for future callers, external input or arbitrary Botlish programs.''')
heading('Evidence for bounded codeTargets and branch-once lowering')
add('''The observed cases support investigating the proposed theorem: seed exact
Native/Block references with singleton code identities; union compatible local
Fn joins; recover callable-parameter facts from all known instance callers;
forget only target identity when a bound is exceeded or provenance is open.
This would cover the two-target scanner/strategy, four-target immutable List,
one-target native all?, and capturing any?/none?/find controls. The proof must
keep code identity separate from environment identity. It must also address
the actual bare/any HOF parameter boundary: assuming every current site already
has structural Fn would miss 8,101 calls.

All **7 HOF sites / 8,101 executions** call a parameter invariant for the
whole helper activation. Their static cardinalities are five singletons and
two two-target scanner sites (one dormant); the only executed multi-target
HOF site supplies 8,000 calls across 1,200 activations. Branch-once evaluation
is therefore relevant evidence, not yet a selected lowering. The local strategy
adds one invariant site / 132 calls across 16 activations. The List loop changes
its callable each element. No branch-once code, multiversioning or target-set
algorithm is implemented.''')
heading('Full regression and benchmark parity')
add('''`cargo build --release --manifest-path native/Cargo.toml` succeeded.
`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl` passed:

| Backend run | Total | Passed | Skipped | Failed |
|---|---:|---:|---:|---:|
| interp | 2,718 | 2,718 | 0 | 0 |
| compile | 2,718 | 2,718 | 0 | 0 |
| Combined executions | 5,436 | 5,436 | 0 | 0 |

Each run sourced 93 test files, including native checks with the native backend
built. `tclsh9.0 bench/bench.tcl -runs 1` passed all 8 canonical programs with
interp/compile/Cranelift agreement and no unsupported rows. Separate native
instrumentation preservation checks pass for all 30 executable corpus sources.
Logs: [tests.txt](audit/post-structural-fn-dynamic-census/out/tests.txt),
[parity.txt](audit/post-structural-fn-dynamic-census/out/parity.txt),
[preservation.json](audit/post-structural-fn-dynamic-census/out/preservation.json).
No production native stack/root/allocation implementation was edited.''')
heading('Recommended next implementation scope')
add('''The evidence supports a small correctness step around singleton caller
ingress, accepting both the one-native all? control and same-code/different-env
capturing controls. Its economic reach is only 1.2144% of current indirect calls.
A performance milestone must also address the scanner's two-target ingress:
K=2 reaches 98.9900% of executions, with the existing exact oracle showing the
potential value of exposing callee facts to existing optimizations. K=4 adds
the real callable-List control. This scopes evidence for later work; it does
not choose a target-set algorithm, cap policy, guard structure or lowering.''')
heading('Compact factual summary')
add(f'''```text
Static callvalue sites: 9
Unique source callvalue expressions: 7
Dynamic callvalue executions per canonical run: 8,317

Statically provable singleton coverage: 5/9 sites; 101/8,317 calls ({pct(101,N)})
Statically provable <=2-target coverage: 8/9 sites; 8,233/8,317 calls ({pct(8233,N)})
Statically provable <=4-target coverage: 9/9 sites; 8,317/8,317 calls (100%)
Statically provable <=8-target coverage: 9/9 sites; 8,317/8,317 calls (100%)

Dynamic calls from HOF ingress: 8,101
Dynamic calls from callable List: 84
Dynamic calls from if/control-flow joins: 132
Dynamic calls from other causes: 0

Largest site: refined-checks.bot / scan_while / e216; 8,000 calls
Largest provenance category: HOF parameter; 8,101 calls

Capturing-Block indirect calls: 63
Envless-Block indirect calls: 6,908
Native indirect calls: 1,346
Mixed finite-target sites: 4 static; 3 executed

Sites remaining Unknown after obvious audit-only target propagation: 0

Measured optimization ceiling:
  Existing exact-scanner oracle: 1,439,963 mean foreground Ir/run saved
  on refined-checks.bot (17.4572%); 1,200 fewer Strings/run.
  Bounded finite-dispatch net savings: not measured.
  Named existing callable machinery: 401,467 Ir across the corpus;
  this is attributable current work, not a promised optimization saving.
```
''')
# Keep the summary's exact derived numbers honest if allocator profiles change.
text='\n'.join(L)
text=text.replace('1,439,963 mean',f'{saving:,.0f} mean').replace('(17.4572%)',f'({pct(saving,statistics.mean(baseline))})')
(root/'POST-STRUCTURAL-FN-DYNAMIC-CENSUS.md').write_text(text)
print('Rendered report:',len(text),'bytes')
