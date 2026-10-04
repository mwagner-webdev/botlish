#!/usr/bin/env bash
# triage.sh -- collect, verify, minimize, deduplicate and matrix-replay the
# campaign's raw findings (crashes and hangs), packaging each deduplicated
# finding under fuzz/triage/candidates/FZ-NNN/ for manual confirmation
# (campaign brief #32-#45). Nothing here files a bug by itself: promotion
# from candidates/ to a filed finding is a manual step (fuzz/triage/index.tsv).
#
#   bash fuzz/scripts/triage.sh
#
# Pipeline per raw artifact:
#   1. plain (non-QEMU) rerun: exit code, signal, stderr first line
#   2. nondeterminism probe: 5 repeats; flaky results are flagged (#30)
#   3. minimization: afl-tmin -Q, falling back to the raw input (#34)
#   4. deduplication signature: target|kind|signal-or-panic|exit (#33)
#      -- two artifacts with the same signature are one candidate
#   5. the vertical replay matrix (#35): aot, interp, compile,
#      cranelift, cranelift-generic + gc-stress and valgrind where cheap
#   6. a mechanical classification guess (#38) for the human to confirm
set -u
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AFL="$ROOT/fuzz/tools/afl/bin"
export AFL_PATH="$ROOT/fuzz/tools/afl/lib/afl" \
       AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 AFL_SKIP_CPUFREQ=1
OUT="$ROOT/fuzz/out"
TRIAGE="$ROOT/fuzz/triage"
mkdir -p "$TRIAGE/candidates"

signal_of() {  # exit code -> signal name, or empty for normal exits
    case "$1" in
        134) echo SIGABRT;; 137) echo SIGKILL;; 139) echo SIGSEGV;;
        132) echo SIGILL;; 133) echo SIGTRAP;; 135) echo SIGBUS;;
        136) echo SIGFPE;;  *) return 1;;
    esac
}

plain_run() {  # plain_run TARGET INPUT -> "exit|N" or "signal|NAME"; echoes
    local out err
    out="$(timeout 10 "$ROOT/fuzz/harness/argv-file" "$ROOT/fuzz/build/aot/$1" "$2" 2>/tmp/triage-err.$$)"
    local code=$?
    err="$(head -3 /tmp/triage-err.$$ 2>/dev/null)"; rm -f /tmp/triage-err.$$
    local sig
    if sig="$(signal_of "$code")"; then
        printf 'signal|%s' "$sig"
    else
        printf 'exit|%s' "$code"
    fi
    [[ -n "$err" ]] && printf '\nerr|%s' "$(printf '%s' "$err" | head -1)"
}

declare -A signatures=()
next_id=1
[[ -f "$TRIAGE/candidates/next-id" ]] && next_id="$(cat "$TRIAGE/candidates/next-id")"

process_finding() {  # process_finding TARGET KIND RAWFILE   (kind: crash|hang)
    local target="$1" kind="$2" raw="$3"
    local verdict; verdict="$(plain_run "$target" "$raw" | paste -sd' ' -)"
    local first second
    first="${verdict%% *}"
    # Nondeterminism probe (#30): 5 more runs.
    local repeats=("" "" "" "" "") i flaky=0
    for i in 1 2 3 4 5; do
        repeats[$i]="$(plain_run "$target" "$raw" | head -1 | paste -sd' ')"
    done
    for i in 1 2 3 4 5; do
        [[ "${repeats[$i]}" != "$first" ]] && flaky=1
    done
    # Hang classification (#25).
    if [[ "$kind" == "hang" ]]; then
        if [[ "$first" == "exit|"* ]]; then
            kind="hang-slow-terminating"
        else
            kind="hang-nonterminating"
        fi
    fi
    local signature="$target|$kind|$verdict"
    if [[ -n "${signatures[$signature]:-}" ]]; then
        echo "triage: $raw duplicates ${signatures[$signature]} ($signature)"
        cp "$raw" "${signatures[$signature]}/raw-$(basename "$raw")" 2>/dev/null || true
        return
    fi
    local id; id="$(printf 'FZ-%03d' "$next_id")"; next_id=$((next_id + 1))
    local dir="$TRIAGE/candidates/$id"
    mkdir -p "$dir"
    signatures[$signature]="$dir"
    cp "$raw" "$dir/raw-input"

    # Minimize (#34). tmin under QEMU; keep raw on any failure.
    local min="$dir/input"
    local t=2000
    [[ -f "$ROOT/fuzz/baselines/$target.tsv" ]] && t="$(awk -F'\t' 'NR>1 && $3+0>m {m=$3+0} END {v=m*10; if(v<200) v=200; if(v>2000) v=2000; print v}' "$ROOT/fuzz/baselines/$target.tsv")"
    if [[ "$kind" == crash* ]] || [[ "$kind" == hang* ]]; then
        "$AFL/afl-tmin" -Q -m none -t "$((t * 3))" -i "$raw" -o "$min" -- \
            "$ROOT/fuzz/harness/argv-file" "$ROOT/fuzz/build/aot/$target" "@@" \
            >"$dir/tmin.log" 2>&1 || cp "$raw" "$min"
    else
        cp "$raw" "$min"
    fi

    # The vertical replay matrix (#35-#37): cheapest first, all of them.
    local verticals="aot interp compile cranelift cranelift-generic"
    local matrix=""
    for v in $verticals; do
        local line
        line="$(tclsh9.0 "$ROOT/fuzz/scripts/replay.tcl" "$v" "$target" "$min" 2>/dev/null | paste -sd' ' -)"
        [[ -z "$line" ]] && line="(vertical unavailable)"
        matrix+="$(printf '%-20s %s\n' "$v" "$line")"
    done
    # Optional verticals (#36): gc-stress on the native verticals, valgrind.
    local gc=""; gc="$(tclsh9.0 "$ROOT/fuzz/scripts/replay.tcl" aot "$target" "$min" --gc-stress 2>/dev/null | paste -sd' ' -)"
    [[ -n "$gc" ]] && matrix+="$(printf '%-20s %s\n' 'aot+gc-stress' "$gc")"
    local vg=""; vg="$(tclsh9.0 "$ROOT/fuzz/scripts/replay.tcl" aot "$target" "$min" --valgrind 2>/dev/null | paste -sd' ' -)"
    [[ -n "$vg" ]] && matrix+="$(printf '%-20s %s\n' 'aot+valgrind' "$vg")"
    if [[ -x "$ROOT/fuzz/build/aot-asan/$target" ]]; then
        local as; as="$(tclsh9.0 "$ROOT/fuzz/scripts/replay.tcl" aot-asan "$target" "$min" 2>/dev/null | paste -sd' ' -)"
        [[ -n "$as" ]] && matrix+="$(printf '%-20s %s\n' 'aot-asan' "$as")"
    fi

    # Mechanical classification guess (#38). The human confirms or corrects.
    is_crash() { [[ "$1" == result\|signal* || "$1" == result\|panic* ]]; }
    local aotV interpV compileV clifV cligV class="unclassified"
    aotV="$(printf '%s\n' "$matrix" | awk '$1=="aot"{print $2}')"
    interpV="$(printf '%s\n' "$matrix" | awk '$1=="interp"{print $2}')"
    compileV="$(printf '%s\n' "$matrix" | awk '$1=="compile"{print $2}')"
    clifV="$(printf '%s\n' "$matrix" | awk '$1=="cranelift"{print $2}')"
    cligV="$(printf '%s\n' "$matrix" | awk '$1=="cranelift-generic"{print $2}')"
    if is_crash "$aotV" && is_crash "$interpV"; then class="shared-layer"
    elif is_crash "$aotV" && ! is_crash "$interpV" && is_crash "$clifV" && is_crash "$cligV"; then class="native-layer"
    elif is_crash "$clifV" && ! is_crash "$cligV" && ! is_crash "$interpV"; then class="cranelift-specialization"
    elif is_crash "$cligV" && ! is_crash "$clifV" && ! is_crash "$interpV"; then class="cranelift-generic-specialization"
    elif is_crash "$interpV" && ! is_crash "$aotV"; then class="interpreter"
    elif ! is_crash "$aotV" && ! is_crash "$interpV"; then class="divergence-or-no-crash"
    fi

    {
        printf 'id: %s\nkind: %s\ntarget: %s\nsignature: %s\n' "$id" "$kind" "$target" "$verdict"
        printf 'nondeterminism-probe: %s\n' "$( [[ $flaky -eq 1 ]] && echo FLAKY || echo stable)"
        printf 'raw-input: %s\n' "$raw"
        printf 'classification-guess: %s (machine-generated; confirm by hand)\n\n' "$class"
        printf 'vertical replay matrix (replay.tcl, cheapest first):\n%s\n' "$matrix"
    } > "$dir/README.txt"
    echo "$next_id" > "$TRIAGE/candidates/next-id"
    echo "triage: $id $kind $target $verdict -> $dir (class guess: $class)"
}

for tree in out out-asan; do
    OUTTREE="$ROOT/fuzz/$tree"
    [[ -d "$OUTTREE" ]] || continue
    for target in $(ls "$OUTTREE" 2>/dev/null); do
        [[ -d "$OUTTREE/$target" ]] || continue
        for kindDir in crashes hangs; do
            for fuzzer in "$OUTTREE/$target"/*/; do
                [[ -d "$fuzzer$kindDir" ]] || continue
                for raw in "$fuzzer$kindDir"/id:*; do
                    [[ -f "$raw" ]] || continue
                    process_finding "$target" "${kindDir%s}" "$raw"
                done
            done
        done
    done
done

if [[ $next_id -eq 1 ]]; then
    echo "triage: no raw crashes or hangs found under $OUT"
fi
