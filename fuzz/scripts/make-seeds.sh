#!/usr/bin/env bash
# make-seeds.sh -- build each target's seed corpus under
# fuzz/seeds-src/<target>/ (the pre-minimization corpus; afl-cmin then
# produces the committed fuzz/seeds/<target>/ set).
#
# Provenance (campaign brief #16): each target's own sample data -- the
# driver expressions, `expect:` comments and header text of the example it
# was compiled from -- plus the diversity checklist (#17): empty input,
# minimal record, typical multi-record, maximal-ish size, unicode, odd
# delimiters/quoting. Nothing here invents new formats; every thematic
# seed is a string the example's own source already contains or documents.
#
# Encoding: a seed file IS an argv vector (fuzz/harness/argv-file.c):
# NUL-separated bytes become argv[1..]. A lone trailing NUL adds nothing;
# "a\0b" is two arguments. printf '%b' is avoided deliberately; printf
# with explicit \0 in the format handles NUL bytes portably.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/fuzz/seeds-src"
rm -rf "$SRC"; mkdir -p "$SRC"

# seed TARGET NAME BYTES...  -- one file per call; backslash escapes in the
# string are interpreted (real newlines), because printf's %b cannot emit
# NUL bytes.
seed() { local target="$1" name="$2"; shift 2
    mkdir -p "$SRC/$target"
    printf '%b' "$*" > "$SRC/$target/$name"
}
# seedhex TARGET NAME HEX -- byte-exact alternative for NUL-containing seeds
# (a seed file is an argv vector: NUL-separated; see fuzz/harness/argv-file.c).
seedhex() { local target="$1" name="$2" hex="$3"
    mkdir -p "$SRC/$target"
    printf '%s' "$hex" | xxd -r -p > "$SRC/$target/$name"
}

# --- thematic seeds per example (sample data from the example's source) ---
CSV_SAMPLES=(
    'name,age\nAlice,30\nBob,40\n'      # csv.bot's own driver string
    'name,age\nAlice,30\nBob,40'        # same, without the final newline
    'a'                                  # single unquoted field, no end
    'a,b,c\n'                            # one record, three fields
    '\n'                                 # the empty line = one empty field
    '"quoted,field","x""y"\n'            # quoted comma + "" escape
    '"multi\nline"\n'                    # newline inside a quoted field
    'name,age\r\nAlice,30\r\n'           # unsupported \r\n (must stay in field)
    'é,例え.テスト\nü,ö\n'                 # unicode fields
    'x,\n,y\n'                           # empty fields between delimiters
)
for t in csv csv_chunked csv_geometric csv_records; do
    i=0
    for s in "${CSV_SAMPLES[@]}"; do
        i=$((i+1)); seedhex "$t" "csv-sample-$i" "$(printf '%b' "$s" | xxd -p | tr -d '\n')"
    done
done

TEXT_SAMPLES=(
    'hello 🙂 world'          # ai_text_clean.bot's own sample
    'AI—generated'
    '“hello”'
    '‘hello’'
    'wait… what?'
    '😀😂🙂😍🔥🚀✅❌🎉🤖👍💡'   # the whole explicit emoji set
    'plain ascii stays'
    'mixed —“”… ascii'
)
i=0; for s in "${TEXT_SAMPLES[@]}"; do
    i=$((i+1)); seed ai_text_clean "text-sample-$i" "$s"
done
# csv.bot's sample also matters to a text scanner:
seed ai_text_clean "csv-sample-1" 'name,age\nAlice,30\nBob,40\n'

# String examples: their own driver strings.
seed string_reverse "reverse-sample-1" 'abcd'
seed string_reverse "reverse-sample-2" 'äöü'
seed string_reverse "reverse-sample-3" ''
seed string_replace "replace-sample-1" 'abcabc'
seed string_replace "replace-sample-2" 'aaaa'
seed string_replace "replace-sample-3" 'needle'

# Numeric-flavored examples: integer edge strings (SOURCE-DEFINED-INTEGER-DOMAINS.md
# documents arbitrary-precision Int; the boundary strings are the interesting bytes).
NUM_SAMPLES=('0' '1' '-1' '42' '9223372036854775807' '-9223372036854775808'
             '9223372036854775808' '007' '0x10' '3.14' '1e9')
for t in matmul 01-arithmetic 02-recursion 04-branch-value 05-shadowing \
         07-loop-break 08-return 11-boolean-operators 12-if-value \
         01-scopes 03-recursion 04-refinement 05-control 06-refined-strings; do
    i=0
    for s in "${NUM_SAMPLES[@]}"; do
        i=$((i+1)); seed "$t" "numeric-sample-$i" "$s"
    done
done

# 06-list / 13-hygiene / 14-modules: list/module-shaped text.
seed 06-list "list-sample-1" '[1, 2, 3]'
seed 06-list "list-sample-2" '[]'
seed 13-hygiene "hygiene-sample-1" '[1, 2]'
seed 14-modules "module-sample-1" 'mathish::inc(41)'

# The abi example: its own documented values (ABI-NUMERIC-DOMAINS.md).
seed numeric-domains "abi-sample-1" '255'
seed numeric-domains "abi-sample-2" '18446744073709551615'
seed numeric-domains "abi-sample-3" '9223372036854775808'
seed numeric-domains "abi-sample-4" '0xffffffffffffffff'
# The linux example: getpid takes no input data; numeric argv only.
seed getpid "syscall-sample-1" '39'
seed getpid "syscall-sample-2" '0'
seed getpid "syscall-sample-3" '-1'

# --- structural seeds: every target gets the argv-shape checklist ------
ALL_TARGETS=$(ls "$SRC")
for t in $ALL_TARGETS; do
    : > "$SRC/$t/empty"                                  # no arguments at all
    seedhex "$t" "one-empty-arg"      '0000'             # [""] (a lone NUL is just a terminator)
    seedhex "$t" "three-args"         "$(printf 'a\0b\0c' | xxd -p | tr -d '\n')"   # a b c
    seedhex "$t" "invalid-utf8"       'fffe80'           # raw invalid UTF-8 bytes, one argument
    seedhex "$t" "nul-inside-arg"     "$(printf 'a\0\0b' | xxd -p | tr -d '\n')"    # a "" b
    # A maximal-ish single argument just under both the kernel's 128 KiB
    # per-argument limit and the campaign's -G 100000 input cap.
    { head -c 99990 /dev/zero | tr '\0' 'x'; printf 'end'; } > "$SRC/$t/max-arg"
    # Many small arguments (the vector shape, not one big blob).
    for i in $(seq 1 500); do printf 'arg%d\0' "$i"; done > "$SRC/$t/many-args"
done

echo "seed sources under $SRC:"
for t in $ALL_TARGETS; do printf '  %-22s %2d files\n' "$t" "$(ls "$SRC/$t" | wc -l)"; done
