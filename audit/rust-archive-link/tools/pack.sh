#!/bin/bash
# pack.sh -- the fixture's packages as multi-target artifacts
# (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md, section 5):
#
#   rustlink           the Rust unit's binding (audit/rust-archive-link/
#                      package) and, per target, the localized unit
#   rustlink_provider  the provider of botlish_event_post2 (audit/
#                      rust-archive-link/provider/package) and, per target,
#                      its archive -- a package of its own, as the event
#                      loop's driver is beside http: in one package, the
#                      unit's weak fallback and the provider's strong
#                      definition are refused by the audit as a duplicate
#                      definition (tests/rust-archive-link.test's
#                      ral-pack-weak-beside-strong)
#
# Each archive is the one release-unit.tcl built on its target, added with
# `native add` -- every C function the package declares checked against the
# archive's symbol index (-symbol: on macos-aarch64 Apple's __.SYMDEF SORTED
# index, which the package manager reads since this milestone) -- audited,
# then packed twice: the two artifacts must be byte-identical.
#
#   pack.sh OUTDIR TARGET=DIR...      (e.g. linux-x86_64=units/linux)
#
# BOT: the compiler command (default: this checkout's main.tcl).
# OUTDIR/rustlink-0.1.0.botpkg, OUTDIR/rustlink_provider-0.1.0.botpkg,
# OUTDIR/stage (the staged packages).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
fixture=$(dirname "$here")
root=$(cd "$fixture/../.." && pwd)
out=${1:?usage: pack.sh OUTDIR TARGET=DIR...}
shift
mkdir -p "$out"
out=$(cd "$out" && pwd)
if [ -z "${BOT:-}" ]; then
    BOT="tclsh9.0 $root/main.tcl"
fi
rm -rf "$out/stage" "$out"/pack-* "$out"/*.botpkg
sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1"; else shasum -a 256 "$1"; fi; }

# stage NAME MODULE ARCHIVE SYMBOLS...: the staged package NAME with MODULE
# and, for each TARGET=DIR, DIR/ARCHIVE added under NAME.
stage() {
    local name=$1 module=$2 archive=$3
    shift 3
    local syms=("$@")
    local dir=$out/stage/$name
    mkdir -p "$dir"
    cp "$module" "$dir/"
    printf '{\n  "schema": 1,\n  "name": "%s",\n  "version": "0.1.0"\n}\n' "$name" > "$dir/botlish.json"
    for spec in "${specs[@]}"; do
        local target=${spec%%=*} from=${spec#*=}
        case "$from" in /*) ;; *) from=$PWD/$from ;; esac
        (cd "$dir" && $BOT native add "$from/$archive" -target "$target" -name "$name" "${syms[@]}" -license MIT)
    done
    (cd "$dir" && $BOT native audit .)
    $BOT package pack "$dir" -out "$out/pack-a"
    $BOT package pack "$dir" -out "$out/pack-b" > /dev/null
    cmp "$out/pack-a/$name-0.1.0.botpkg" "$out/pack-b/$name-0.1.0.botpkg"
    cp "$out/pack-a/$name-0.1.0.botpkg" "$out/"
    sha "$out/$name-0.1.0.botpkg"
}

specs=("$@")
unit_syms=()
for s in $(grep -oE '^private extern c fn rl_[a-z_]+' "$fixture/package/rustlink.bot" | awk '{print $5}' | sort -u); do
    unit_syms+=(-symbol "$s")
done
provider_syms=(-symbol botlish_event_post2)
for s in $(grep -oE '^private extern c fn rlp_[a-z_]+' "$fixture/provider/package/rustlink_provider.bot" | awk '{print $5}' | sort -u); do
    provider_syms+=(-symbol "$s")
done
stage rustlink "$fixture/package/rustlink.bot" librustlink.a "${unit_syms[@]}"
stage rustlink_provider "$fixture/provider/package/rustlink_provider.bot" librustlink_provider.a "${provider_syms[@]}"
