# closings.py: the closing-mechanism table of the warning-driven refactor:
# every finding of the kickoff sweep (audit/refactor/kickoff/sweep.txt, at
# 6e3f9f7) with exactly one closing mechanism, the phase that applied it and
# its verification, resolved through the kickoff audits' own records.
import re, sys, collections
root = sys.argv[1]
sweep = open(root + '/audit/refactor/kickoff/sweep.txt', encoding='utf-8').read()
oc = open(root + '/audit/refactor/kickoff/one-char-string-literal.txt', encoding='utf-8').read()

findings = []
for line in sweep.split('\n'):
    m = re.match(r'^(\S+):(\d+):(\d+) ([A-Z-]+): (.*?)   \(', line)
    if m:
        findings.append((m.group(1), int(m.group(2)), int(m.group(3)), m.group(4), m.group(5)))

# One-char records: location -> (value, function, consumer).
ocrec = {}
for line in oc.split('\n'):
    m = re.match(r'^(\S+:\d+:\d+) ("(?:[^"\\]|\\.)*") (\S+) \| (.*?) \|', line)
    if m:
        ocrec[m.group(1)] = (m.group(2), m.group(3), m.group(4))

MARKED = {'bit_and', 'bit_or', 'bit_xor', 'mutable_array::copy', 'mutable_array::create'}
rows = []
def add(loc, code, mech, phase, why):
    rows.append((loc, code, mech, phase, why))

for f, l, c, code, msg in findings:
    loc = '%s:%d:%d' % (f, l, c)
    if code == 'METHOD-ELIGIBLE':
        callee = re.search(r'call to `([^`]*)`', msg).group(1)
        if callee in MARKED:
            add(loc, code, 'marked', 'P1', '`%s` is nomethod: the receiver form is NOMETHOD-CALL (pinned test me-nomethod-shipped-*)' % callee)
        else:
            add(loc, code, 'converted', 'P2', 'respelled `.%s(...)`, verified by the round-trip law (method-sweep-log.txt)' % callee.split('::')[-1])
    elif code == 'FIXED-ARITY-LIST-RETURN':
        if f == 'examples/surface/13-hygiene.bot':
            add(loc, code, 'manifested', 'P4', 'core-ir-roundtrip: `-> list` is a source fact core IR cannot carry, and the sample is a fixture of surface-samples.test\'s HIR/core-IR round trip; a struct would replace its subject (the list literal)')
        else:
            add(loc, code, 'annotated', 'P4', '`-> list` (the result is the sample\'s list of checks/values, never destructured); expect line and probes identical')
    elif code == 'SAME-FAILURE':
        add(loc, code, 'merged', 'P4', 'one guard `index < 0 or index >= count` (milestone 4\'s verified merge); probe abi-bytes')
    elif code == 'SAME-RETURN-VALUE':
        why = {
            'examples/stdlib/csv_records.bot': 'ht_find_insert: the two `return index` are one condition (empty slot or the key\'s slot); probes hashtable.tcl',
            'examples/stdlib/hashtable.bot:170': 'ht_find_insert: as in csv_records.bot; probes hashtable.tcl',
            'examples/stdlib/hashtable.bot:301': 'ht_delete: the early `return table` is the guard inverted around the deletion; probes hashtable.tcl',
            'lib/web.bot:190': 'domain?: an on-sight rejection leaves the scan (`break`), so every rejection is the one `false` after it; probes web.tcl',
            'lib/web.bot:202': 'emailish?: the nested `false` tree is one conjunction; probes web.tcl',
            'lib/web.bot:251': 'uri_query_value?\'s valid_from?: a valid escape or character continues by a returned tail call, everything else falls through to one `false`; probes web.tcl (a 40,000-character value included)',
        }
        key = f if f == 'examples/stdlib/csv_records.bot' else '%s:%d' % (f, l)
        add(loc, code, 'merged', 'P4', why[key])
    elif code == 'ONE-CHAR-STRING-LITERAL':
        value, fn, consumer = ocrec[loc]
        if f == 'examples/stdlib/ai_text_clean.bot':
            if consumer.startswith('return'):
                add(loc, code, 'manifested', 'P3', 'H1 -- char->text: clean_char returns %s as text; the table form (audit/refactor/h1-attempt) only hides it' % value)
            else:
                add(loc, code, 'converted', 'P3', '%s compares the character it reads (str::char_at of its one-character text) with the character literal; probes ai_text_clean.tcl' % fn)
        elif f.startswith('examples/stdlib/csv'):
            if consumer.startswith('call str::concat'):
                add(loc, code, 'converted', 'P3', 'scan_quoted: a doubled quote appends the first quote\'s own text (the slice it holds) instead of the literal; probes csv.tcl')
            else:
                add(loc, code, 'converted', 'P3', '%s reads the character with str::char_at under a str::length bound (quote_at? for the quote tests); probes csv.tcl' % fn)
        elif f == 'examples/stdlib/string_replace.bot':
            if loc in ('examples/stdlib/string_replace.bot:49:26', 'examples/stdlib/string_replace.bot:49:133'):
                add(loc, code, 'converted', 'P5', 'H2 falsified: the replacement of an absent needle is never inserted, only its non-emptiness matters; respelled "yz" (expect line identical)')
            else:
                add(loc, code, 'manifested', 'P5', 'H2 -- test-datum: the length-1 %s is the case\'s subject' % value)
        elif f == 'examples/stdlib/string_reverse.bot':
            add(loc, code, 'manifested', 'P5', 'H2 -- test-datum: "a" is the length-1 boundary of reversal')
        elif f == 'lib/web.bot':
            if fn == 'top' and consumer.startswith('list-element immutable_set'):
                add(loc, code, 'manifested', 'P3', 'classifier: local_extra_chars is queried with the one-character String local_char? also hands str::is_tcl_alnum')
            elif fn == 'label_char?':
                add(loc, code, 'manifested', 'P3', 'classifier: label_char? is str::is_tcl_alnum(c) or c == "-"')
            elif fn in ('domain?', 'emailish?'):
                add(loc, code, 'converted', 'P3', '%s tests the character at a position through the guarded char_is? (str::char_at); probes web.tcl' % fn)
            elif fn == 'top':
                add(loc, code, 'manifested', 'P3', 'char->text: hex_digits is the table of hexadecimal digits as text')
            else:
                add(loc, code, 'manifested', 'P3', 'char->text: pct\'s "%" begins every escape as text')
        elif f == 'lib/linux/path.bot':
            if consumer.startswith('=='):
                add(loc, code, 'manifested', 'P3', 'index-proof: path.char_at(n - 1) is not proven in range; concat\'s errors are fixed by io::path::Path')
            else:
                add(loc, code, 'manifested', 'P3', 'char->text: the joining "/" is appended as text')
        elif f in ('lib/io.bot', 'examples/io/child-path.bot'):
            add(loc, code, 'manifested', 'P3', 'char->text: %s appended as text' % value)
        elif f in ('bench/lex-strategy.bot', 'bench/source-checks.bot'):
            add(loc, code, 'manifested', 'P3', 'classifier: the character is a one-character String for str::is_tcl_alnum/alpha in a uniform predicate contract')
        else:
            raise SystemExit('unclassified ' + loc)
    else:
        raise SystemExit('unclassified code ' + code)

assert len(rows) == len(findings), (len(rows), len(findings))
counts = collections.Counter((r[1], r[2]) for r in rows)
mechs = collections.Counter(r[2] for r in rows)
print('# The closing-mechanism table (REFACTOR-WARNINGS-CLEAN.md): every finding of')
print('# the kickoff sweep (audit/refactor/kickoff/sweep.txt, commit 6e3f9f7) with')
print('# exactly one closing mechanism -- converted, annotated, merged, marked or')
print('# manifested -- the phase that applied it and its verification. Locations')
print('# are the kickoff tree\'s; a manifested finding\'s current location is in')
print('# audit/refactor/manifest.txt.')
print('#')
print('# findings: %d; %s' % (len(rows), ', '.join('%s %d' % (k, mechs[k]) for k in ('converted', 'annotated', 'merged', 'marked', 'manifested'))))
for code in ('METHOD-ELIGIBLE', 'ONE-CHAR-STRING-LITERAL', 'SAME-RETURN-VALUE', 'FIXED-ARITY-LIST-RETURN', 'SAME-FAILURE', 'PROVES-NAMING', 'MANY-BOOLEAN-ARGUMENTS'):
    parts = ['%s %d' % (m, counts[(code, m)]) for m in ('converted', 'annotated', 'merged', 'marked', 'manifested') if counts[(code, m)]]
    print('#   %-26s %s' % (code, ', '.join(parts) if parts else '(no findings)'))
print()
for loc, code, mech, phase, why in rows:
    print('%s %s %s %s -- %s' % (loc, code, mech, phase, why))
