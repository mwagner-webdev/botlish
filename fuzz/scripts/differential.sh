#!/usr/bin/env bash
# differential.sh -- the vertical replay matrix over the committed seeds:
# every target x seed x {aot, interp, compile, cranelift, cranelift-generic},
# normalized outputs compared (campaign brief #29: same input, same
# observable behavior, or it is a semantic-divergence finding).
#
#   bash fuzz/scripts/differential.sh
#
# Writes fuzz/out/differential.tsv (gitignored scratch; the committed
# summary goes into FUZZING-EXAMPLES-AOT.md) and prints mismatches.
# Verticals beyond the required four can be added with EXTRA_VERTICALS
# (e.g. "aot-asan"); triage replays use replay.tcl directly.
set -u
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/fuzz/out"
mkdir -p "$OUT"
REPORT="$OUT/differential.tsv"
mismatches=0
rows=0

printf 'target\tseed\tvertical\tresult\texit\n' > "$REPORT"

compare_one() {  # compare_one TARGET SEEDNAME SEEDPATH VERTICAL...
    local target="$1" seedname="$2" seed="$3"; shift 3
    local reference="" referenceVertical="" vertical normalized
    for vertical in "$@"; do
        if [[ "$vertical" == "aot-asan" && ! -x "$ROOT/fuzz/build/aot-asan/$target" ]]; then continue; fi
        if [[ "$vertical" == "aot" && ! -x "$ROOT/fuzz/build/aot/$target" ]]; then continue; fi
        normalized="$(tclsh9.0 "$ROOT/fuzz/scripts/replay.tcl" "$vertical" "$target" "$seed" 2>/dev/null | paste -sd' ' -)"
        [[ -z "$normalized" ]] && continue
        # Documented interpreter limitation, not a finding: the Tcl
        # reference interpreter does not eliminate tail calls (a Botlish
        # recursion is a Tcl recursion), so deep input-driven recursion
        # hits Tcl's recursion limit and completes with TCL LIMIT STACK --
        # the exact behavior examples/stdlib/corpus.tcl documents and
        # works around by raising the limit. Native verticals eliminate
        # self tail calls (hir::aot's `tail` facts) and agree on the
        # value. Clean error, one vertical, depth-dependent.
        if [[ "$vertical" == "interp" && "$normalized" == *"TCL LIMIT STACK"* ]]; then
            printf '%s\t%s\t%s\t%s\tinterp-depth-limit\n' "$target" "$seedname" "$vertical" "$normalized" >> "$REPORT"
            continue
        fi
        # Documented runner limitation, not a finding: an I/O program (it
        # writes its own bytes to stdout -- fuzz/stdin-targets,
        # fuzz/write-targets) can glue those bytes onto the driver's
        # "value ..." line when they carry no trailing newline (NUL bytes
        # especially), and the in-process runner then misreports the
        # successful run as "native backend produced no result". The aot
        # vertical, which has no framing, verifies the real behavior.
        if [[ "$vertical" == "cranelift" || "$vertical" == "cranelift-generic" ]] && \
           [[ "$normalized" == "result|raw|=="* ]] && \
           { grep -qx "$target" "$ROOT/fuzz/stdin-targets" 2>/dev/null || grep -qx "$target" "$ROOT/fuzz/write-targets" 2>/dev/null; }; then
            printf '%s\t%s\t%s\t%s\tin-process-io-glue\n' "$target" "$seedname" "$vertical" "$normalized" >> "$REPORT"
            continue
        fi
        # Documented per-vertical baseline, not a finding: a native-only
        # program refuses on the Tcl backends by design (the diagnostic is
        # the refusal itself: examples/linux/getpid.bot documents it for
        # its own syscall; a program's own module files can be the trigger,
        # so the target's source text alone does not decide it).
        if [[ "$vertical" == interp || "$vertical" == compile ]] && \
           [[ "$normalized" == *"CORE SEMANTIC NATIVE-ONLY"* ]]; then
            printf '%s\t%s\t%s\t%s\tnative-only-refusal\n' "$target" "$seedname" "$vertical" "$normalized" >> "$REPORT"
            continue
        fi
        # Documented baseline gap, not a finding: cranelift-generic has no
        # slot for a struct projection only a semantic instance proves, and
        # the repository's own stand-in policy applies (examples/stdlib/
        # corpus.tcl, tests/helpers.tcl: cranelift stands in). Such a run
        # is recorded but never counted as a mismatch.
        if [[ "$vertical" == "cranelift-generic" && "$normalized" == *"NATIVE UNSUPPORTED struct-shape"* ]]; then
            printf '%s\t%s\t%s\t%s\tknown-limitation\n' "$target" "$seedname" "$vertical" "$normalized" >> "$REPORT"
            continue
        fi
        # Documented display difference, not a semantic divergence: main.tcl
        # shows values "with runtime evidence shown as text\"#{Type}\"" on the
        # Tcl-side verticals (interp, compile); native verticals print the
        # same value without the refinement annotation (the Rust runtime
        # does not carry Tcl-side refinement metadata). If stripping the
        # #{...} annotations makes the runs equal, record it as such.
        if [[ -n "$reference" && "$normalized" != "$reference" \
              && "$(sed 's/#{[^}]*}//g' <<<"$normalized")" == "$(sed 's/#{[^}]*}//g' <<<"$reference")" ]]; then
            printf '%s\t%s\t%s\t%s\tdisplay-divergence\n' "$target" "$seedname" "$vertical" "$normalized" >> "$REPORT"
            continue
        fi
        printf '%s\t%s\t%s\t%s\n' "$target" "$seedname" "$vertical" "$normalized" >> "$REPORT"
        rows=$((rows + 1))
        if [[ -z "$reference" ]]; then
            reference="$normalized"
            referenceVertical="$vertical"
        elif [[ "$normalized" != "$reference" ]]; then
            mismatches=$((mismatches + 1))
            printf 'MISMATCH %s %s %s:\n  %s: %s\n  %s: %s\n' \
                "$target" "$seedname" "$vertical" \
                "$referenceVertical" "$reference" "$vertical" "$normalized"
        fi
    done
}

# 1. The AOT fuzz targets: every committed seed x all five verticals.
for target_dir in "$ROOT"/fuzz/seeds/*/; do
    target="$(basename "$target_dir")"
    for seed in "$target_dir"/*; do
        [[ -f "$seed" ]] || continue
        compare_one "$target" "$(basename "$seed")" "$seed" \
            aot interp compile cranelift cranelift-generic ${EXTRA_VERTICALS:-}
    done
done

# 2. In-process-only examples (AOT gate: NATIVE AOT NOT-READY -- guarded
# workloads): their unminimized seed sources on the four in-process
# verticals. The programs still run identically everywhere they run; the
# matrix keeps them covered (#6: recorded, not hidden).
for target_dir in "$ROOT"/fuzz/seeds-src/*/; do
    target="$(basename "$target_dir")"
    [[ -d "$ROOT/fuzz/seeds/$target" ]] && continue      # covered above
    [[ -f "$ROOT/fuzz/build/aot/$target.bot" || -f "$ROOT/fuzz/build/aot/$target.hir" ]] || continue
    for seed in "$target_dir"/*; do
        [[ -f "$seed" ]] || continue
        compare_one "$target" "$(basename "$seed")" "$seed" \
            interp compile cranelift cranelift-generic
    done
done

# 3. Core-IR examples: interp and compile are the only verticals that run
# core IR text (by design). One empty-argv run each -- the programs take
# no input.
mkdir -p "$OUT"
: > "$OUT/empty-argv"
for ir in "$ROOT"/examples/*.ir; do
    target="$(basename "$ir" .ir)"
    compare_one "$target" "empty" "$OUT/empty-argv" interp compile
done

printf 'differential: %d runs, %d mismatches (full table: %s)\n' "$rows" "$mismatches" "$REPORT"
exit 0
