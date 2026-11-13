#!/bin/bash
# consumer.sh -- the independent consumer of HTTP-MACOS-RUST-ARCHIVE-LINK-
# FEASIBILITY-MILESTONE-1.md, section 6, on a machine that has the packaged
# compiler, the package artifact and the consumer's sources, and nothing of
# the fixture's: no checkout, no Rust toolchain, no cargo, no fixture source
# or build directory. A fresh project installs the artifact through the
# package manager (add, verify, native plan), compiles both consumer programs
# to native executables (AOT, -warnings error, no -L, the compiler's own
# linker choice) and runs them; each program's value must be its expected
# value (audit/rust-archive-link/consumer/*.expected; the unit's rustc
# version line aside), each run must exit 0, and each executable is
# inspected: its format and architecture, its dynamic libraries, and the
# symbols two copies of Rust's standard library share -- exactly one global
# personality routine and allocator shim (the Botlish runtime's), the unit's
# own local, and no global symbol carrying the unit's standard library's
# crate hash.
#
#   consumer.sh BOTLISH PACKAGE.botpkg SOURCES OUTDIR
#
# BOTLISH: the single-file compiler (Linux) or Botlish.app's
# Contents/MacOS/botlish (macOS). SOURCES: the consumer's .bot files and
# their .expected values. OUTDIR: the project, its logs, its executables.
# Exit status 0 only when every step held; every failure is printed.
set -u
BOT=${1:?usage: consumer.sh BOTLISH PACKAGE.botpkg SOURCES OUTDIR}
PKG=${2:?}
SRC=${3:?}
OUT=${4:?}
fail=0
note() { printf '%s\n' "$*"; }
bad() { printf 'FAIL %s\n' "$*"; fail=1; }

case "$PKG" in /*) ;; *) PKG=$PWD/$PKG ;; esac
case "$SRC" in /*) ;; *) SRC=$PWD/$SRC ;; esac
rm -rf "$OUT" && mkdir -p "$OUT" && cd "$OUT" || exit 1

note "== host: $(uname -srm)"
if [ "$(uname -s)" = Darwin ]; then
    note "== macOS $(sw_vers -productVersion); translated: $(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)"
fi
note "== compiler: $("$BOT" -version 2>&1 | head -1)"
note "== PATH: $PATH"
for tool in cargo rustc rustup; do
    if command -v "$tool" >/dev/null 2>&1; then
        bad "$tool is on PATH ($(command -v "$tool")): this is no clean room"
    else
        note "== $tool: not on PATH"
    fi
done
for dir in "$HOME/.cargo" "$HOME/.rustup"; do
    [ -e "$dir" ] && bad "$dir exists: this is no clean room"
done

cp "$SRC"/*.bot . || exit 1
printf '{\n  "schema": 1,\n  "name": "rustlink_consumer",\n  "version": "0.1.0"\n}\n' > botlish.json
"$BOT" add "$PKG" > add.log 2>&1 || { cat add.log; bad "add"; exit 1; }
sed 's/^/== add: /' add.log
"$BOT" verify > verify.log 2>&1 || { cat verify.log; bad "verify"; }
sed 's/^/== verify: /' verify.log | head -3
"$BOT" native plan > plan.log 2>&1 || { cat plan.log; bad "native plan"; }
sed 's/^/== native plan: /' plan.log

if [ "$(uname -s)" = Darwin ]; then
    view=.bot_modules/.targets/macos-aarch64
else
    view=.bot_modules/.targets/linux-$(uname -m)
fi
unit=$view/rustlink/native/librustlink.a
[ -f "$unit" ] || bad "the installed view has no $unit"

# The unit's own standard library's crate hash: from the name its localized
# allocator shim keeps as a local symbol (_RNvCs<HASH>_7___rustc12___rust_alloc).
unit_hash=$(nm "$unit" 2>/dev/null | grep -E ' [a-z] _?_RNvCs[0-9A-Za-z_]+_7___rustc12___rust_alloc$' | head -1 | sed -E 's/.*_RNvCs([0-9A-Za-z_]+)_7___rustc.*/\1/')
note "== the unit's __rustc crate hash: ${unit_hash:-(not found)}"

for p in without_provider with_provider; do
    if "$BOT" -warnings error -emit-native-executable "$p.bot" > "$p.build.log" 2>&1; then
        note "built $p"
    else
        cat "$p.build.log"; bad "build $p"; continue
    fi
    for round in 1 2 3; do
        rm -f "$p.result"
        BOTLISH_NATIVE_RESULT=$PWD/$p.result ./"$p" > "$p.run$round.log" 2>&1
        status=$?
        [ $status -eq 0 ] || { cat "$p.run$round.log"; bad "$p run $round: exit $status"; }
        got=$(sed -E 's/\{str \{toolchain [^}]*\}\}/{str {toolchain RUSTC}}/' "$p.result" 2>/dev/null)
        want=$(cat "$SRC/$p.expected")
        if [ "$got" = "$want" ]; then
            [ $round -eq 1 ] && note "PASS $p: $(grep -o 'toolchain [^}]*' "$p.result")"
        else
            bad "$p run $round: value"; note "  got:  $got"; note "  want: $want"
        fi
    done
    note "== $p: $(file "$p" | sed 's/^[^:]*: //')"
    if [ "$(uname -s)" = Darwin ]; then
        note "== $p architectures: $(lipo -archs "$p")"
        otool -L "$p" | sed 's/^/== otool -L: /'
        [ "$(lipo -archs "$p")" = arm64 ] || bad "$p is not arm64-only"
        prefix=_
    else
        ldd "$p" 2>&1 | sed 's/^/== ldd: /'
        prefix=
    fi
    # Symbols both copies of Rust's standard library define.
    for sym in rust_eh_personality; do
        g=$(nm "$p" | awk -v s="$prefix$sym" '$NF==s && $(NF-1) ~ /^[A-Z]$/ && $(NF-1) != "U"' | wc -l | tr -d ' ')
        l=$(nm "$p" | awk -v s="$prefix$sym" '$NF==s && $(NF-1) ~ /^[a-z]$/ && $(NF-1) != "u"' | wc -l | tr -d ' ')
        note "== $p $sym: $g global, $l local"
        [ "$g" = 1 ] || bad "$p: $g global definitions of $sym (one, the runtime's, expected)"
        [ "$l" -ge 1 ] || bad "$p: no local definition of $sym (the unit's own)"
    done
    ga=$(nm "$p" | grep -cE ' [A-Z] _?_RNvCs[0-9A-Za-z_]+_7___rustc12___rust_alloc$')
    la=$(nm "$p" | grep -cE ' [a-z] _?_RNvCs[0-9A-Za-z_]+_7___rustc12___rust_alloc$')
    note "== $p __rust_alloc: $ga global, $la local"
    [ "$ga" = 1 ] || bad "$p: $ga global allocator shims (one, the runtime's, expected)"
    [ "$la" -ge 1 ] || bad "$p: no local allocator shim (the unit's own)"
    if [ -n "$unit_hash" ]; then
        leaked=$(nm "$p" | awk '$(NF-1) ~ /^[A-TV-Z]$/' | grep -c "Cs${unit_hash}_" || true)
        runtime_hash=$(nm "$p" | grep -E ' [A-Z] _?_RNvCs[0-9A-Za-z_]+_7___rustc12___rust_alloc$' | sed -E 's/.*_RNvCs([0-9A-Za-z_]+)_7___rustc.*/\1/')
        note "== $p: global symbols carrying the unit's crate hash: $leaked (the runtime's: $runtime_hash)"
        if [ "$runtime_hash" != "$unit_hash" ]; then
            [ "$leaked" = 0 ] || bad "$p: $leaked global symbols of the unit's standard library"
        else
            note "== $p: the unit and the runtime were built by one rustc (one crate hash): the leak check says nothing"
        fi
    fi
    if [ "$(uname -s)" = Darwin ] && command -v dyld_info >/dev/null 2>&1; then
        dyld_info -exports "$p" > "$p.exports.txt" 2>&1
        n=$(grep -c '_rl_' "$p.exports.txt" || true)
        u=0
        [ -n "$unit_hash" ] && u=$(grep -c "Cs${unit_hash}_" "$p.exports.txt" || true)
        note "== $p exports trie: $(wc -l < "$p.exports.txt" | tr -d ' ') lines, $n of the unit's C ABI, $u of the unit's standard library"
        [ "$u" = 0 ] || [ "$runtime_hash" = "$unit_hash" ] || bad "$p exports $u symbols of the unit's standard library"
    fi
done

if [ $fail -eq 0 ]; then note "CONSUMER OK"; else note "CONSUMER FAILED"; fi
exit $fail
