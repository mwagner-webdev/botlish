#!/usr/bin/env bash
# build-audit-native.sh -- build the audit-only botlish-native used by
# profile-nir.sh (POST-R2A-DYNAMIC-CENSUS.md) WITHOUT touching the
# production crate: copies native/{Cargo.toml,Cargo.lock,src} into WORKDIR,
# applies this directory's audit-native.patch there (the post-M8.a patch,
# unchanged, plus the env-gated BOTLISH_AUDIT_SKIP_FIRST warm-up
# exclusion), and builds with its own target directory. Prints the
# binary's path. (A copy of audit/post-m8a-common-inefficiency/tools/
# build-audit-native.sh pointed at this directory's patch.)
#
#   bash audit/post-r2a-dynamic-census/tools/build-audit-native.sh WORKDIR
#
# The patch adds no code to any generated function and no work to any
# runtime helper: one never-inlined extern "C" frame around the timed call of
# the program entry (the toggle-collect anchor), and an env-gated,
# compile-time-only dump of JIT code addresses/bytes.
set -eu
work=${1:?usage: build-audit-native.sh WORKDIR}
root=$(cd "$(dirname "$0")/../../.." && pwd)
rm -rf "$work/native-audit"
mkdir -p "$work/native-audit"
cp -r "$root/native/Cargo.toml" "$root/native/Cargo.lock" "$root/native/src" "$work/native-audit/"
(cd "$work" && patch -s -p1 -d native-audit < "$root/audit/post-r2a-dynamic-census/tools/audit-native.patch")
cargo build --release --quiet --manifest-path "$work/native-audit/Cargo.toml" --target-dir "$work/target"
echo "$work/target/release/botlish-native"
