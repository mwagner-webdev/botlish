#!/bin/bash
# instructions.sh -- what the machine instructions of a benchmark's generated
# functions are, executed (BENCHMARK-SLOWDOWN-CAUSES.md, "Generated code").
#
#   audit/bench-bimodality/tools/instructions.sh FILE.bot RUNS FUNCTION,...
#
# Builds the program's standalone executable in a private directory, runs it
# under callgrind with per-instruction counts (--dump-instr=yes) for RUNS
# timed runs (the driver protocol of runtime/aot.rs), and joins the counts of
# the named functions (botlish_fn_N: `profile.sh` names the hot ones) with
# objdump's disassembly of them. Prints the executed instructions by class
# (stack loads and stores, other moves, compares and tests, jumps,
# arithmetic, cmov/setcc, calls) and the hottest straight-line runs of
# instructions with their counts per run. The program must be AOT-ready.
# Needs valgrind, objdump and python3; removes its directory when it ends.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
program=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
runs=$2
functions=$3
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export LANG=C.utf8 LC_ALL=C.utf8
built=$(cd "$root" && tclsh9.0 "$here/executable.tcl" "$program" "$work/program")
case "$built" in
    executable*) ;;
    *) echo "not AOT-ready: $built" >&2; exit 1 ;;
esac
(cd "$work" && BOTLISH_NATIVE_RESULT="$work/result" BOTLISH_NATIVE_RUNS=$runs \
    valgrind --tool=callgrind --dump-instr=yes --callgrind-out-file="$work/cg.out" ./program > /dev/null 2>&1)
objdump -d --no-show-raw-insn -M intel "$work/program" > "$work/program.asm"
python3 -I - "$work/cg.out" "$work/program.asm" "$functions" "$runs" <<'EOF'
import collections, re, sys

cg, asm, wanted, runs = sys.argv[1], sys.argv[2], set(sys.argv[3].split(',')), int(sys.argv[4])

# Self cost per instruction address of the wanted functions. Callgrind
# compresses positions (+N, -N, *), names a function once with its number,
# and follows a calls= line with the call's inclusive cost, which is not the
# caller's own.
names, counts = {}, collections.defaultdict(collections.Counter)
current, last, after_calls = None, 0, False
for line in open(cg):
    line = line.rstrip('\n')
    m = re.match(r'^fn=\((\d+)\)(?: (.*))?$', line)
    if m:
        if m.group(2):
            names[m.group(1)] = m.group(2)
        current = names.get(m.group(1))
        continue
    if line.startswith('calls='):
        after_calls = True
        continue
    m = re.match(r'^cfn=\((\d+)\)(?: (.*))?$', line)
    if m and m.group(2):
        names[m.group(1)] = m.group(2)
    if re.match(r'^(ob|fl|fi|fe|cob|cfi|cfl|cfn)=', line):
        continue
    m = re.match(r'^(0x[0-9a-f]+|\+\d+|-\d+|\*)\s+(\S+)\s+(\d+)$', line)
    if not m:
        continue
    p = m.group(1)
    if p.startswith('0x'):
        address = int(p, 16)
    elif p[0] == '+':
        address = last + int(p[1:])
    elif p[0] == '-':
        address = last - int(p[1:])
    else:
        address = last
    last = address
    if after_calls:
        after_calls = False
        continue
    if current in wanted:
        counts[current][address] += int(m.group(3))

text, inside = {}, None
for line in open(asm):
    m = re.match(r'^[0-9a-f]+ <([^>]+)>:', line)
    if m:
        inside = m.group(1) if m.group(1) in wanted else None
        continue
    if inside:
        m = re.match(r'^\s*([0-9a-f]+):\s+(.*)$', line)
        if m:
            text[int(m.group(1), 16)] = m.group(2).strip()

def kind(instruction):
    op = instruction.split()[0] if instruction else '?'
    if op == 'call':
        return 'call'
    if op.startswith('mov') and re.search(r'\[(rsp|rbp)', instruction):
        return 'stack load/store'
    if op.startswith('mov'):
        return 'other mov'
    if op.startswith('j'):
        return 'jump'
    if op in ('cmp', 'test'):
        return 'compare/test'
    if op.startswith('cmov') or op.startswith('set'):
        return 'cmov/setcc'
    if op in ('add', 'sub', 'shl', 'sar', 'shr', 'or', 'and', 'xor', 'lea', 'imul', 'neg'):
        return 'arith/logic'
    return 'other'

classes, total = collections.Counter(), 0
for function in wanted:
    for address, count in counts[function].items():
        classes[kind(text.get(address, ''))] += count
        total += count
print(f"{', '.join(sorted(wanted))}: {total // runs:,} instructions per run")
for name, count in classes.most_common():
    print(f"  {name:18} {100 * count / total:5.1f}%")

# The hottest runs of consecutive instructions executed equally often.
blocks = []
for function in wanted:
    previous = None
    for address in sorted(counts[function]):
        count = counts[function][address]
        if blocks and previous is not None and count == blocks[-1][1] and address - previous < 16:
            blocks[-1][2].append(address)
        else:
            blocks.append([address, count, [address]])
        previous = address
blocks.sort(key=lambda b: -b[1] * len(b[2]))
for start, count, addresses in blocks[:6]:
    print(f"--- {count // runs:,} times per run, {len(addresses)} instructions, "
          f"{100 * count * len(addresses) / total:.1f}%")
    for address in addresses[:40]:
        print(f"    {text.get(address, '?')}")
EOF
