# phase-mutants.py -- the phase mutants of mutants.txt, generated from
# census.tsv (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md): one
# mutant per phase, removing the guard of each of its procedures, so host
# recursion comes back to that phase alone. Prints them; mutants.txt holds
# this output followed by the hand-written mutants. Regenerate after a guard
# moves or the census changes:
#
#   python3 -I audit/depth-safe-nesting/tools/phase-mutants.py
import os, re, glob
ROOT=os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))+'/'
GUARD = "    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}"
files = [f for d in ('surface','hir','core','compiler','native','service') for f in glob.glob(ROOT+d+'/*.tcl')]
src = {f: open(f).read() for f in files}
census=[l.split('\t')[0] for l in open(ROOT+'audit/depth-safe-nesting/census.tsv') if l.strip() and not l.startswith('#')]
def edit(name):
    q=name.lstrip(':')
    pat=re.compile(r'^(proc (::)?'+re.escape(q)+r' (\{[^\n]*\}|\S+) \{)\n'+re.escape(GUARD)+r'\n', re.M)
    hits=[(f,m) for f in files for m in pat.finditer(src[f])]
    assert len(hits)==1, (name, len(hits))
    f,m=hits[0]
    return (f[len(ROOT):], m.group(1)+'\n'+GUARD, m.group(1))
groups=[
 ('parser-recursion', 'the parser\'s productions recurse through host calls again (every parser guard removed)', ['::surface::parser::'], 'dsn-1000-paren dsn-1000-list dsn-1000-ifnest dsn-census-guarded'),
 ('paren-recursion', 'parentheses recurse through host calls again: the expression chain unguarded, the List, field and argument productions still guarded', ['::surface::parser::Expression','::surface::parser::Conjunction','::surface::parser::Logical','::surface::parser::Inversion','::surface::parser::Comparison','::surface::parser::Additive','::surface::parser::Multiplicative','::surface::parser::Unary','::surface::parser::Postfix','::surface::parser::Primary','::surface::parser::ValueOrHandled','::surface::parser::Simple'], 'dsn-1000-paren'),
 ('ast-recursion', 'the parser iterative, the AST\'s walks (ids, its text) recursive', ['::surface::ast::'], 'dsn-1000-flat dsn-text'),
 ('loader-recursion', 'the loader\'s walks of a file recursive', ['::surface::modules::'], 'dsn-1000-list'),
 ('surface-lowering-recursion', 'AST to HIR syntax recursive', ['::surface::lower::'], 'dsn-1000-list dsn-1000-handler'),
 ('static-sites-recursion', 'the static-site walks recursive', ['::hir::static::','::hir::syntax::CollectBindNames'], 'dsn-1000-list dsn-static-compile'),
 ('resolve-recursion', 'the parser and lowering depth-safe, resolution recursive', ['::hir::resolve::'], 'dsn-1000-list dsn-1000-struct'),
 ('types-recursion', 'resolution depth-safe, type inference recursive', ['::hir::types::'], 'dsn-1000-list dsn-1000-struct'),
 ('contracts-recursion', 'contract inference recursive', ['::hir::signatures::'], 'dsn-1000-call'),
 ('range-recursion', 'the range analysis recursive', ['::hir::range::','::hir::refine::'], 'dsn-1000-rbin dsn-1000-elif'),
 ('completions-recursion', 'the completion analysis recursive', ['::hir::completions::'], 'dsn-1000-call dsn-1000-handler'),
 ('callables-recursion', 'the callable audit recursive', ['::hir::callables::'], 'dsn-1000-call'),
 ('specialize-recursion', 'call-site specialization recursive', ['::hir::specialize::'], 'dsn-1000-fnnest'),
 ('warnings-recursion', 'the warning passes\' walks recursive', ['::hir::warnings::'], 'dsn-warnings'),
 ('affine-recursion', 'the affine flow recursive', ['::hir::affine::'], 'dsn-affine-chain'),
 ('stamp-recursion', 'a trait or coroutine program\'s syntax stamped recursively', ['::hir::traits::'], 'dsn-trait-program dsn-affine-chain'),
 ('coreir-recursion', 'the analyses depth-safe, core IR lowering recursive', ['::hir::lower::'], 'dsn-1000-flat dsn-1000-list'),
 ('coreir-check-recursion', 'core IR\'s check recursive', ['::core::ir::'], 'dsn-1000-list'),
 ('tcl-compiler-recursion', 'core IR depth-safe, the Tcl compiler recursive', ['::core::compiler::','::hir::WalkInto','::hir::aot::'], 'dsn-1000-list dsn-1000-rbin'),
 ('native-recursion', 'the Tcl compiler depth-safe, native lowering recursive', ['::native::','::hir::escape::','::hir::construction::'], 'dsn-1000-list dsn-1000-struct'),
 ('hirtext-recursion', 'HIR text printed and read recursively', ['::hir::format::','::hir::read::'], 'dsn-text dsn-cache'),
 ('service-recursion', 'the service\'s index of a file recursive', ['::service::'], 'dsn-service'),
 ('repeatable-recursion', 'the repeatability analysis recursive', ['::hir::repeatable::'], 'dsn-1000-call dsn-1000-list'),
]
out=[]
out.append('''# mutants.txt -- mutants of the depth-safe front end
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md); mutate.tcl runs them.
#
# @@ NAME DESCRIPTION, then !! DETECTORS (tests/depth-safe-nesting.test's
# tests, tcltest -match patterns; `fuzz` for fuzz.tcl), then for each edit
# ## FILE and <<<< OLD ==== NEW >>>>, OLD occurring exactly once.
#
# The phase mutants (one per phase, generated from census.tsv by removing
# its procedures' guards) bring host recursion back to one phase while the
# others stay depth-safe: the milestone is not parser-local.
''')
for name,desc,prefixes,det in groups:
    procs=[c for c in census if any(c.startswith(p) if p.endswith('::') else c==p for p in prefixes)]
    if not procs:
        raise SystemExit('no census procedure for '+name)
    out.append(f'@@ {name} {desc}\n!! {det}\n')
    for p in procs:
        f,old,new=edit(p)
        out.append(f'## {f}\n<<<<\n{old}\n====\n{new}\n>>>>\n')
    out.append('\n')
import sys
sys.stdout.write(''.join(out))
