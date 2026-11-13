#!/bin/bash
# pack.sh -- the fixture's package as one multi-target artifact
# (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md, section 5): the
# package's sources (audit/rust-archive-link/package) and, per target, the
# localized unit and the provider's archive that release-unit.tcl built on
# that target, added with `native add` -- every C function the package
# declares checked against each archive's symbol index (-symbol: on
# macos-aarch64 that is Apple's __.SYMDEF SORTED index, which the package
# manager reads since this milestone) -- audited, then packed twice: the two
# artifacts must be byte-identical.
#
#   pack.sh OUTDIR TARGET=DIR...      (e.g. linux-x86_64=units/linux)
#
# BOT: the compiler command (default: this checkout's main.tcl).
# OUTDIR/rustlink-0.1.0.botpkg, OUTDIR/stage (the staged package).
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
stage=$out/stage/rustlink
rm -rf "$out/stage" "$out"/pack-* "$out"/*.botpkg
mkdir -p "$stage"
cp "$fixture/package/rustlink.bot" "$stage/"
mkdir -p "$stage/rustlink"
cp "$fixture/package/rustlink/provider.bot" "$stage/rustlink/"
printf '{\n  "schema": 1,\n  "name": "rustlink",\n  "version": "0.1.0"\n}\n' > "$stage/botlish.json"
unit_syms=()
for s in $(grep -oE '^private extern c fn rl_[a-z_]+' "$fixture/package/rustlink.bot" | awk '{print $5}' | sort -u); do
    unit_syms+=(-symbol "$s")
done
provider_syms=(-symbol botlish_event_post2)
for s in $(grep -oE '^private extern c fn rlp_[a-z_]+' "$fixture/package/rustlink/provider.bot" | awk '{print $5}' | sort -u); do
    provider_syms+=(-symbol "$s")
done
for spec in "$@"; do
    target=${spec%%=*}
    dir=${spec#*=}
    case "$dir" in /*) ;; *) dir=$PWD/$dir ;; esac
    (cd "$stage" && $BOT native add "$dir/librustlink.a" -target "$target" -name rustlink "${unit_syms[@]}" -license MIT)
    (cd "$stage" && $BOT native add "$dir/librustlink_provider.a" -target "$target" -name rustlink_provider "${provider_syms[@]}" -license MIT)
done
(cd "$stage" && $BOT native audit .)
$BOT package pack "$stage" -out "$out/pack-a"
$BOT package pack "$stage" -out "$out/pack-b" > /dev/null
cmp "$out/pack-a/rustlink-0.1.0.botpkg" "$out/pack-b/rustlink-0.1.0.botpkg"
cp "$out/pack-a/rustlink-0.1.0.botpkg" "$out/"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$out/rustlink-0.1.0.botpkg"
else
    shasum -a 256 "$out/rustlink-0.1.0.botpkg"
fi
