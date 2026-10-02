#!/usr/bin/env python3
"""constructors.py -- per-constructor cost of every general native String
producer, old runtime versus new (STRING-ALLOCATION.md): allocation side
(steady state), free side (between-run reset) and churn life cycle, in
instructions per construction, plus malloc/free calls, from the same loops
and method as materialize.py (control: the loop without the constructing op).

    constructors.py OLD-AUDIT-BIN NEW-AUDIT-BIN OUTDIR
"""
import json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import materialize as m

NON_ASCII = "aé…\U0001f600z"          # 1 + 2 + 3 + 4 + 1 bytes, 5 characters
MIXED_UP = "ÀBCKx…"              # lowercase changes widths (U+212A -> 'k')

# name -> (constants {reg: literal-line}, constructing line(s))
def esc(t):
    return t.replace("\\", "\\\\").replace('"', '\\"')

CASES = [
    ("concat ASCII 5+5 bytes", {1: 'str "hello"', 2: 'str "world"'}, ["%10 = op strcat %1 %2"]),
    ("concat non-ASCII 6+10 bytes", {1: 'str "héllo"', 2: 'str " wörld…"'}, ["%10 = op strcat %1 %2"]),
    ("substring ASCII [3,8)", {1: 'str "hello world"', 3: "int 3", 4: "int 8"}, ["%10 = op substr %1 %3 %4"]),
    ("substring non-ASCII [1,4)", {1: f'str "{esc(NON_ASCII)}"', 3: "int 1", 4: "int 4"}, ["%10 = op substr %1 %3 %4"]),
    ("substring empty [2,2)", {1: 'str "hello world"', 3: "int 2", 4: "int 2"}, ["%10 = op substr %1 %3 %4"]),
    ("lowercase ASCII 12 bytes", {1: 'str "HELLO, World"'}, ["%10 = op strlower %1"]),
    ("lowercase non-ASCII", {1: f'str "{esc(MIXED_UP)}"'}, ["%10 = op strlower %1"]),
    ("decode_char_at U+2026", {1: f'str "{esc(NON_ASCII)}"', 3: "int 3"}, ["%10 = op decodecharat %1 %3"]),
    ("flat construct, 3 pieces", {1: 'str "ab"', 2: 'str "…"', 3: 'str "xyz\U0001f600"'},
     ["%10 = construct str flat %1 %2 region %3 %5 %6 %3"]),
]


def make(consts, body):
    def f(n, control):
        regs = dict(consts)
        regs[5] = "int 1"
        regs[6] = "int 4"
        regs[8] = f"int {n}"
        regs[0] = "int 0"
        lines = ["nir 1 call-effects=1", "", 'func 0 "<program>" params=0 env=0 regs=24 pnames="" captures=0']
        for r in sorted(regs):
            lines.append(f"    %{r} = {regs[r]}")
        lines += ["  label L0", "    %20 = op ilt %0 %8", "    br %20 L1 L2", "  label L1"]
        if control:
            lines.append("    %11 = op strlen %1")
        else:
            lines += ["    " + b for b in body] + ["    %11 = op strlen %10"]
        lines += ["    %21 = int 1", "    %0 = op iadd %0 %21", "    jump L0", "  label L2", "    ret %0", "end", ""]
        return "\n".join(lines)
    return f


def main():
    old, new, outdir = sys.argv[1:4]
    os.makedirs(outdir, exist_ok=True)
    result = {}
    for label, consts, body in CASES:
        slug = re.sub(r"\W+", "-", label)
        result[label] = {}
        for which, binary in (("old", old), ("new", new)):
            result[label][which] = m.measure(binary, f"{slug}-{which}", make(consts, body), outdir)
        print(label, {w: {k: round(result[label][w][k]["ir"], 1) for k in ("alloc", "free", "lifecycle")} for w in ("old", "new")}, flush=True)
    json.dump(result, open(os.path.join(outdir, "constructors.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
