#!/usr/bin/env python3
"""materialize.py -- cost of one runtime String materialization, old runtime
versus new, from deterministic callgrind instruction counts (STRING-ALLOCATION.md).

    materialize.py OLD-AUDIT-BIN NEW-AUDIT-BIN OUTDIR

For every variant a loop materializes the virtual value (`shorttostr` /
`asciitostr`) and takes its `strlen`; the control is the same loop over a
constant `str` (no materialization). Three figures per variant and runtime:

  alloc      steady-state allocation side: the timed program window
             (audit frame botlish_audit_run) of a 5,000-iteration run that
             stays below the collection threshold, after a first run grew the
             arena (so malloc reuses chunks freed by the between-run reset, as
             the corpus's steady-state runs do); per iteration, control
             subtracted
  free       the between-run Vm::reset (audit frame botlish_audit_reset): the
             sweep that frees what the previous run allocated; per iteration
  lifecycle  a churn heap: (Ir(N=40000) - Ir(N=20000)) / 20000 over the whole
             `run`, control subtracted, with collections running inside the
             loop (allocation, sweep and free interleaved)

The function-level (exclusive Ir) cost of the materializing loop is classified
into allocator / free / Rust allocator shims / memcpy / runtime construction /
GC bookkeeping / other. Observation only.
"""
import json, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cgsum import parse

SMALL, LARGE = 20000, 40000


def ascii_word(text):
    w = 0
    for i, ch in enumerate(text.encode()):
        w |= (0x80 | ch) << (8 * i)
    # the NIR literal is a signed 64-bit integer (an 8-character word has bit 63 set)
    return w - (1 << 64) if w >= (1 << 63) else w


# name, kind, operand literal, control constant
VARIANTS = []
for label, cp in [("scalar U+0061", 0x61), ("scalar U+2026", 0x2026), ("scalar U+1F600", 0x1F600), ("scalar Empty", -1)]:
    text = "" if cp == -1 else chr(cp)
    VARIANTS.append((label, "short", cp, text))
for n in (0, 1, 2, 4, 8):
    text = "abcdefgh"[:n]
    VARIANTS.append((f"packed ASCII length {n}", "ascii", ascii_word(text), text))


def nir(kind, lit, text, n, control):
    attrs = {"short": ' shortregs="1"', "ascii": ' asciiregs="1"'}[kind] if not control else ""
    lines = ["nir 1 call-effects=1", "", f'func 0 "<program>" params=0 env=0 regs=9 pnames="" captures=0{attrs}', "    %0 = int 0"]
    if control:
        esc = text.replace("\\", "\\\\").replace('"', '\\"')
        lines.append(f'    %1 = str "{esc}"')
    else:
        lines.append(f"    %1 = {'shortlit' if kind == 'short' else 'asciilit'} {lit}")
    lines += [f"    %8 = int {n}", "  label L0", "    %2 = op ilt %0 %8", "    br %2 L1 L2", "  label L1"]
    if control:
        lines.append("    %4 = op strlen %1")
    else:
        lines.append(f"    %3 = op {'shorttostr' if kind == 'short' else 'asciitostr'} %1")
        lines.append("    %4 = op strlen %3")
    lines += ["    %6 = int 1", "    %0 = op iadd %0 %6", "    jump L0", "  label L2", "    ret %0", "end", ""]
    return "\n".join(lines)


CATS = [
    ("free (glibc)", r"^(free|cfree|__libc_free|_int_free[\w.]*|unlink_chunk[\w.]*|malloc_consolidate|free_perturb|_int_free_merge_chunk|_int_free_create_chunk|_int_free_maybe_consolidate)$"),
    ("allocator (glibc)", r"^(alloc_perturb|malloc|__libc_malloc|_int_malloc|calloc|__libc_calloc|realloc|_int_realloc|__libc_realloc|tcache_\w+|sysmalloc|malloc_hook_ini|checked_request2size|_int_memalign|__libc_memalign|aligned_alloc|posix_memalign|__posix_memalign)$"),
    ("Rust allocator shims", r"(__rust_alloc|__rdl_alloc|__rust_dealloc|__rdl_dealloc|__rust_realloc|__rdl_realloc|__rust_no_alloc_shim|__rust_alloc_zeroed|__rdl_alloc_zeroed)"),
    ("memcpy/memmove", r"(memcpy|memmove|memset)"),
    ("GC bookkeeping + free_object", r"(Heap|heap)::|free_object|free_str|collect|object_size"),
    ("runtime constructors", r"(rt_short_to_str|rt_ascii_to_str|short_to_string|ascii_to_string|new_str|alloc_str|StrInit|empty_string|Vm::alloc|alloc::<|record_alloc|Metrics)"),
]


def classify(name):
    for cat, rx in CATS:
        if re.search(rx, name):
            return cat
    if re.match(r"^0x[0-9a-f]+$", name):
        return "generated code (loop + strlen)"
    return "other"


def callgrind(binary, nirpath, tag, outdir, mode):
    out = os.path.join(outdir, tag + ".cg")
    env = dict(os.environ, LANG="C.utf8", LC_ALL="C.utf8", BOTLISH_NATIVE_STACK_BYTES=str(64 << 20))
    cmd = ["valgrind", "--tool=callgrind", "--compress-strings=no", "--compress-pos=no", f"--callgrind-out-file={out}"]
    if mode == "run":
        env["BOTLISH_AUDIT_SKIP_FIRST"] = "1"
        cmd += ["--toggle-collect=botlish_audit_run", binary, "bench", str(RUNS + 1), nirpath]
    elif mode == "reset":
        cmd += ["--toggle-collect=botlish_audit_reset", binary, "bench", str(RUNS + 1), nirpath]
    else:
        cmd += [binary, "run", nirpath]
    subprocess.run(cmd, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    total, selfc, calls = parse(out)
    os.remove(out)
    return total, selfc, calls


RUNS = 3
STEADY_N = 5000


def categorize(b_self, c_self, scale_b, scale_c=None):
    cats = {}
    for fn in set(b_self) | set(c_self):
        delta = b_self.get(fn, 0) / scale_b - c_self.get(fn, 0) / (scale_c or scale_b)
        if abs(delta) > 1e-9:
            cats[classify(fn)] = cats.get(classify(fn), 0) + delta
    return cats


def measure(binary, slug, make, outdir):
    """MAKE(n, control) -> NIR text of the n-iteration loop (control: no materialization)."""
    res = {}
    # steady state: run window and reset window, N = STEADY_N
    paths = {}
    for control in (False, True):
        p = os.path.join(outdir, f"{slug}-{'c' if control else 'b'}{STEADY_N}.nir")
        open(p, "w").write(make(STEADY_N, control))
        paths[control] = p
    runw = {c: callgrind(binary, paths[c], "tmp", outdir, "run") for c in (False, True)}
    resw = {c: callgrind(binary, paths[c], "tmp", outdir, "reset") for c in (False, True)}
    d = STEADY_N * RUNS
    alloc = (runw[False][0] - runw[True][0]) / d
    free = (resw[False][0] - resw[True][0]) / d
    out = {
        "alloc": {"ir": alloc, "categories": categorize(runw[False][1], runw[True][1], d),
                  "malloc_calls": sum(runw[False][2].get(k, 0) for k in ("malloc", "calloc", "realloc")) / d,
                  "free_calls": runw[False][2].get("free", 0) / d},
        "free": {"ir": free, "categories": categorize(resw[False][1], resw[True][1], d),
                 "free_calls": resw[False][2].get("free", 0) / d},
    }
    # churn lifecycle: whole-program difference between two sizes
    runs = {}
    for control in (False, True):
        for n in (SMALL, LARGE):
            p = os.path.join(outdir, f"{slug}-{'c' if control else 'b'}{n}.nir")
            open(p, "w").write(make(n, control))
            runs[(control, n)] = callgrind(binary, p, "tmp", outdir, "whole")
    per = lambda a, b: (a - b) / SMALL
    life = per(runs[(False, LARGE)][0], runs[(False, SMALL)][0]) - per(runs[(True, LARGE)][0], runs[(True, SMALL)][0])
    cats = {}
    for control, sign in ((False, 1), (True, -1)):
        for fn in set(runs[(control, LARGE)][1]) | set(runs[(control, SMALL)][1]):
            delta = per(runs[(control, LARGE)][1].get(fn, 0), runs[(control, SMALL)][1].get(fn, 0))
            if abs(delta) > 1e-9:
                cats[classify(fn)] = cats.get(classify(fn), 0) + sign * delta
    out["lifecycle"] = {"ir": life, "categories": cats,
                        "malloc_calls": per(sum(runs[(False, LARGE)][2].get(k, 0) for k in ("malloc", "calloc", "realloc")),
                                            sum(runs[(False, SMALL)][2].get(k, 0) for k in ("malloc", "calloc", "realloc"))),
                        "free_calls": per(runs[(False, LARGE)][2].get("free", 0), runs[(False, SMALL)][2].get("free", 0))}
    return out


def main():
    old, new, outdir = sys.argv[1:4]
    os.makedirs(outdir, exist_ok=True)
    result = {}
    for label, kind, lit, text in VARIANTS:
        slug = re.sub(r"\W+", "-", label)
        result[label] = {}
        for which, binary in (("old", old), ("new", new)):
            result[label][which] = measure(binary, f"{slug}-{which}", lambda n, control, kind=kind, lit=lit, text=text: nir(kind, lit, text, n, control), outdir)
        print(label, {w: {m: round(result[label][w][m]["ir"], 1) for m in ("alloc", "free", "lifecycle")} for w in ("old", "new")}, flush=True)
    json.dump(result, open(os.path.join(outdir, "materialize.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
