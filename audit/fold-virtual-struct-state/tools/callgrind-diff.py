# callgrind-diff.py -- instructions per run from two callgrind profiles of
# `botlish-native bench N FILE.nir` with N1 and N2 runs (FOLD-VIRTUAL-STRUCT-
# STATE-CENSUS-1.md; the method of audit/bench-bimodality/tools/profile.sh,
# whose categories this repeats): the difference divided by N2 - N1 cancels
# the driver's start-up and the JIT's compilation. Prints one line:
#   TOTAL generated=PCT allocator=PCT helpers=PCT collector=PCT mem=PCT
#
#   python3 -I callgrind-diff.py ANNOTATE1 ANNOTATE2 K
import collections
import re
import sys


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
        return 'generated'
    if re.search(r'malloc|free|calloc|realloc|_int_|unlink_chunk|__rdl_|__rust_|alloc::<|alloc_str|finish_grow|grow_one|arena|consolidate', function):
        return 'allocator'
    if re.search(r'collect|free_object|retain|Heap', function):
        return 'collector'
    if re.search(r'memcpy|memmove|memcmp|memset', function):
        return 'mem'
    return 'helpers'


first, second, k = load(sys.argv[1]), load(sys.argv[2]), int(sys.argv[3])
per_run = {f: (second[f] - first.get(f, 0)) / k for f in second}
total = sum(v for v in per_run.values() if v > 0)
categories = collections.Counter()
for f, v in per_run.items():
    if v > 0:
        categories[category(f)] += v
parts = ' '.join(f"{name}={100 * categories[name] / total:.1f}%" for name in
                 ('generated', 'allocator', 'helpers', 'collector', 'mem'))
print(f"{total:.0f} {parts}")
