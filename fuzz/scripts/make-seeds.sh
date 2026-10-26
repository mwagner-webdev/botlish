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
for t in csv csv-argv csv_chunked csv_geometric csv_records; do
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
seed ai_text_clean "csv-sample-1" 'name,age\nAlice,30\nBob,40\n'

# The argv-driven ai-text-clean variant gets the same text corpus.
i=0; for s in "${TEXT_SAMPLES[@]}"; do
    i=$((i+1)); seed ai-text-clean-argv "text-sample-$i" "$s"
done
seed ai-text-clean-argv "csv-sample-1" 'name,age\nAlice,30\nBob,40\n'

# The argv-driven replace variant: haystack\0needle\0replacement vectors
# from its own sample triples, plus needle/replacement swap shapes.
REPLACE_VECTORS=(
    'abc\0x\0y'
    'abc\0b\0X'
    'aaaa\0aa\0b'
    'abcabc\0abc\0'
    '\0x\0y'
    'aaa\0a\0aa'
)
i=0; for s in "${REPLACE_VECTORS[@]}"; do
    i=$((i+1)); seedhex string-replace-argv "replace-sample-$i" "$(printf '%b' "$s" | xxd -p | tr -d '\n')"
done

# String examples: their own driver strings.
seed string_reverse "reverse-sample-1" 'abcd'
seed string_reverse "reverse-sample-2" 'äöü'
seed string_reverse "reverse-sample-3" ''
seed string_replace "replace-sample-1" 'abcabc'
seed string_replace "replace-sample-2" 'aaaa'
seed string_replace "replace-sample-3" 'needle'

# The argv-driven reverse variant gets the same texts as its argument.
seed string-reverse-argv "reverse-sample-1" 'abcd'
seed string-reverse-argv "reverse-sample-2" 'äöü'
seed string-reverse-argv "reverse-sample-3" 'abcdcba'
seed string-reverse-argv "reverse-sample-4" 'a'

# Numeric-flavored examples: integer edge strings (SOURCE-DEFINED-INTEGER-DOMAINS.md
# documents arbitrary-precision Int; the boundary strings are the interesting bytes).
NUM_SAMPLES=('0' '1' '-1' '42' '9223372036854775807' '-9223372036854775808'
             '9223372036854775808' '007' '0x10' '3.14' '1e9')
for t in matmul 01-arithmetic 02-recursion 04-branch-value 05-shadowing \
         07-loop-break 08-return 11-boolean-operators 12-if-value \
         01-scopes 03-recursion 04-refinement 05-control; do
    i=0
    for s in "${NUM_SAMPLES[@]}"; do
        i=$((i+1)); seed "$t" "numeric-sample-$i" "$s"
    done
done

# 06-list / 13-hygiene / 14-modules: list/module-shaped text.
seed 06-list "list-sample-1" '[1, 2, 3]'
seed 06-list "list-sample-2" '[]'
seed 13-hygiene "hygiene-sample-1" '[1, 2]'
seed 14-modules "module-sample-1" 'std::mathish::inc(41)'

# The abi example: its own documented values (ABI-NUMERIC-DOMAINS.md).
seed numeric-domains "abi-sample-1" '255'
seed numeric-domains "abi-sample-2" '18446744073709551615'
seed numeric-domains "abi-sample-3" '9223372036854775808'
seed numeric-domains "abi-sample-4" '0xffffffffffffffff'
# The linux example: getpid takes no input data; numeric argv only.
seed getpid "syscall-sample-1" '39'
seed getpid "syscall-sample-2" '0'
seed getpid "syscall-sample-3" '-1'

# The merged-base examples (campaign continuation): write/context-hello are
# fixed-output writers (their text as a token), 15-enums an enum demo.
seed write "hello-sample-1" 'Hello from Botlish!'
seed context-hello "hello-sample-1" 'hello'
seed 15-enums "enum-sample-1" 'Red'
seed 15-enums "enum-sample-2" 'Green'

# read-stdin consumes raw stdin bytes (one chunk, <= 4096): raw payloads,
# NOT argv vectors -- its campaign mode is AFL's stdin mode.
raw() { local target="$1" name="$2"; shift 2
    mkdir -p "$SRC/$target"
    printf '%b' "$*" > "$SRC/$target/$name"
}
rawhex() { local target="$1" name="$2" hex="$3"
    mkdir -p "$SRC/$target"
    printf '%s' "$hex" | xxd -r -p > "$SRC/$target/$name"
}

# conformance.bot: one JSON document per argument (RFC 8259 shapes, valid
# and invalid, from the grammar the json/json_lex recognizers implement).
# Provenance: RFC 8259's grammar and the classic malformations; the verdict
# text is the program's own ("lexical/structure ..." with offset).
JSON_VALID=(
    '{}'
    '[]'
    'null'
    'true'
    'false'
    '0'
    '-0'
    '0.5'
    '-1.5e-3'
    '1e999'
    '1E+5'
    '"x"'
    '""'
    '"\\u0041"'
    '"\\uD834\\uDD1E"'
    '"\\\\"'
    '"\\/"'
    '"\\t"'
    '"😀"'
    '[1, 2, 3]'
    '{"a": null, "b": [true, false]}'
    '{"a": {"b": {"c": []}}}'
    ' { "spaced" : [ 1 ] } '
)
JSON_INVALID=(
    'not json'
    '{'
    '['
    '{"a":}'
    '{"a": 1,}'
    "[1, 2,]"
    "{'a': 1}"
    'NaN'
    'Infinity'
    '// comment'
    '/* comment */'
    '01'
    '+1'
    '.5'
    '1.'
    '0x1'
    '"unterminated'
    '"\\uD800"'
    '"a
b"'
    '{"a" 1}'
    '[1 2]'
    '"\\x41"'
)
i=0; for s in "${JSON_VALID[@]}"; do i=$((i+1)); seed conformance "valid-$i" "$s"; done
i=0; for s in "${JSON_INVALID[@]}"; do i=$((i+1)); seed conformance "invalid-$i" "$s"; done
# Boundary shapes the program's own limits define (TooDeep, MAX_TOKEN):
python3 - <<'EOF'
import os
d = 'fuzz/seeds-src/conformance'
open(f'{d}/valid-deep-16', 'w').write('[' * 16 + ']' * 16)
open(f'{d}/valid-deep-64', 'w').write('[' * 64 + ']' * 64)
open(f'{d}/invalid-deep-500', 'w').write('[' * 500)
open(f'{d}/valid-longtoken-5000', 'w').write('"' + 'a' * 5000 + '"')
open(f'{d}/invalid-longtoken-90000', 'w').write('"' + 'b' * 90000 + '"')
EOF
# Multiple documents as separate arguments (the driver's per-argument loop):
seedhex conformance "two-docs" "$(printf '{}\0[1]' | xxd -p | tr -d '\n')"
seedhex conformance "good-bad-mix" "$(printf '[1]\0nope\0"ok"' | xxd -p | tr -d '\n')"
raw read-stdin "hello" 'hello from stdin\n'
: > "$SRC/read-stdin/empty-only"
head -c 4096 /dev/zero | tr '\0' 'a' > "$SRC/read-stdin/exactly-4096"
{ head -c 4096 /dev/zero | tr '\0' 'b'; printf 'tail'; } > "$SRC/read-stdin/over-4096"
rawhex read-stdin "non-utf8" 'fffe80c3'
rawhex read-stdin "with-nuls" '6162006263'
raw read-stdin "crlf" 'a\r\nb\r\n'
raw read-stdin "csv-line" 'name,age\nAlice,30\n'

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
