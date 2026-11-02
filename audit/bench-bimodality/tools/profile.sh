#!/bin/bash
# profile.sh -- where a benchmark's instructions go, per timed run
# (BENCHMARK-BIMODALITY.md, "Method").
#
#   audit/bench-bimodality/tools/profile.sh FILE.bot N1 N2
#
# Builds the program's standalone executable (or, for a program that is not
# AOT-ready, its NIR for `botlish-native bench`) in a private directory, runs
# it under callgrind twice, N1 and N2 timed runs (BOTLISH_NATIVE_RESULT /
# BOTLISH_NATIVE_RUNS: the driver protocol of runtime/aot.rs), and prints the
# difference divided by N2 - N1: one run's exclusive instruction count per
# function and by category. The difference cancels startup and JIT
# compilation; it includes the untimed Vm::reset between runs (the heap's
# release), which the report's toggled profiles leave out. Needs valgrind
# and python3; removes its directory when it ends.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
program=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
n1=$2
n2=$3
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export LANG=C.utf8 LC_ALL=C.utf8
built=$(cd "$root" && tclsh9.0 "$here/executable.tcl" "$program" "$work/program")
for n in "$n1" "$n2"; do
    case "$built" in
        executable*)
            BOTLISH_NATIVE_RESULT="$work/result.$n" BOTLISH_NATIVE_RUNS=$n \
                valgrind --tool=callgrind --callgrind-out-file="$work/cg.$n" "$work/program" > /dev/null 2>&1
            ;;
        *)
            (cd "$work" && valgrind --tool=callgrind --callgrind-out-file="$work/cg.$n" \
                "$root/native/target/release/botlish-native" bench "$n" program.nir > /dev/null 2>&1)
            ;;
    esac
    callgrind_annotate --threshold=100 --inclusive=no --auto=no "$work/cg.$n" > "$work/annotate.$n" 2> /dev/null
done
echo "$built" | cut -c1-200
python3 -I - "$work/annotate.$n1" "$work/annotate.$n2" $((n2 - n1)) <<'EOF'
import collections, re, sys

def load(path):
    counts = collections.Counter()
    for line in open(path, encoding='utf-8', errors='replace'):
        m = re.match(r'^\s*([0-9,]+) \(\s*[0-9.]+%\)\s+(.*?)(?: \[[^\]]*\])?$', line.rstrip('\n'))
        if not m or 'PROGRAM TOTALS' in line:
            continue
        file, _, function = m.group(2).partition(':')
        if file == '???' and not function.startswith('__rust'):
            function = 'generated ' + function
        counts[function] += int(m.group(1).replace(',', ''))
    return counts

def category(function):
    if function.startswith('generated '):
        return 'generated code'
    if re.search(r'malloc|free|calloc|realloc|_int_|unlink_chunk|__rdl_|__rust_|alloc::<|alloc_str|finish_grow|grow_one|arena|consolidate', function):
        return 'allocator'
    if re.search(r'collect|free_object|retain|Heap', function):
        return 'collector'
    if re.search(r'memcpy|memmove|memcmp|memset', function):
        return 'mem*'
    return 'runtime helpers'

first, second, k = load(sys.argv[1]), load(sys.argv[2]), int(sys.argv[3])
per_run = {f: (second[f] - first.get(f, 0)) / k for f in second}
total = sum(v for v in per_run.values() if v > 0)
print(f"instructions per run: {total:,.0f}")
categories = collections.Counter()
for f, v in per_run.items():
    if v > 0:
        categories[category(f)] += v
for name, v in categories.most_common():
    print(f"  {name:16} {100 * v / total:5.1f}%")
for f, v in sorted(per_run.items(), key=lambda x: -x[1])[:20]:
    if v <= 0:
        break
    print(f"{v:12,.0f} {100 * v / total:5.1f}%  {f[:110]}")
EOF
