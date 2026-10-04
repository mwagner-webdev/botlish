#!/usr/bin/env bash
# setup-host.sh -- prepare this (WSL2 Ubuntu) host for the fuzzing campaign.
#
# Everything is unprivileged: no sudo anywhere. The AFL++ toolchain is
# built from a pinned upstream source into fuzz/tools/afl (gitignored),
# including QEMU mode (-Q), which Ubuntu's afl++ package does not ship.
# Build-time dependencies that are missing as headers (glib, zlib, ninja,
# meson, flex, bison) are downloaded as .debs with `apt-get download` and
# extracted into a private sysroot -- never installed.
#
# Network is needed for this script only; the campaign itself runs offline
# (FUZZING-EXAMPLES-AOT.md).
#
# Idempotent: finished steps are skipped. Run from the repository root:
#
#   bash fuzz/scripts/setup-host.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
TOOLS="$ROOT/fuzz/tools"
AFL_PREFIX="$TOOLS/afl"
SYSROOT="$TOOLS/sysroot"
WORK="${BOTLISH_FUZZ_WORK:-/tmp/opencode/fuzz-setup}"

# The pinned toolchain. afl-qemu-trace must come from the same AFL++ source
# tree as afl-fuzz (they speak a private protocol), so both are built from
# this one tarball.
AFL_VERSION="4.09c"
AFL_TARBALL="https://github.com/AFLplusplus/AFLplusplus/archive/refs/tags/v${AFL_VERSION}.tar.gz"
QEMUAFL_COMMIT="a1321713c7502c152dd7527555e0f8a800d55225" # qemu_mode/QEMUAFL_VERSION

# Build dependencies fetched as .debs (Ubuntu noble) instead of installed.
# The pcre2/ffi/mount/selinux/sepol/blkid/uuid set exists because qemu's
# glib pkg-config chain pulls it in transitively when linking statically.
DEBS=(ninja-build libglib2.0-dev libglib2.0-dev-bin zlib1g-dev flex bison
      meson libpcre2-dev libffi-dev libmount-dev libselinux1-dev
      libsepol-dev libblkid-dev uuid-dev)

log() { printf '[setup-host] %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

mkdir -p "$TOOLS" "$WORK"

# --- 1. Host report and campaign-relevant kernel settings -----------------
log "host report:"
log "  kernel:   $(uname -r) ($(uname -m))"
log "  cores:    $(nproc)"
core_pattern="$(cat /proc/sys/kernel/core_pattern 2>/dev/null || echo '?')"
log "  core_pattern: ${core_pattern}"
if [[ "$core_pattern" == '|'* ]]; then
    # WSL2 routes crashes to its own handler; without root we cannot set
    # 'core'. AFL++ runs with this acknowledged: signal-based crash
    # detection still works, only core files are not produced.
    log "  -> pipe handler (WSL); the campaign exports AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1"
fi
if [[ ! -e /sys/devices/system/cpu/cpu0/cpufreq ]]; then
    log "  cpufreq:  no governor interface (WSL); the campaign exports AFL_SKIP_CPUFREQ=1"
else
    log "  cpufreq:  present; the campaign still exports AFL_SKIP_CPUFREQ=1 (WSL governors are host-controlled)"
fi
log "  memory:   $(free -h | awk '/Mem:/ {print $2}')"

# --- 2. Basic toolchain ----------------------------------------------------
for tool in tclsh9.0 rustc cargo cc curl git; do
    have "$tool" || { log "ERROR: $tool is required"; exit 1; }
done

# --- 3. AFL++ core from the pinned source ----------------------------------
if [[ -x "$AFL_PREFIX/bin/afl-fuzz" && -x "$AFL_PREFIX/lib/afl/afl-qemu-trace" ]]; then
    log "AFL++ already present: $($AFL_PREFIX/bin/afl-fuzz --version 2>/dev/null | head -1)"
else
    log "building AFL++ ${AFL_VERSION} (core) from source"
    mkdir -p "$WORK"
    cd "$WORK"
    if [[ ! -d "AFLplusplus-${AFL_VERSION}" ]]; then
        curl -fsSL -o "afl.tar.gz" "$AFL_TARBALL"
        tar xzf afl.tar.gz
    fi
    cd "AFLplusplus-${AFL_VERSION}"
    make -j"$(nproc)" >/dev/null
    make install PREFIX="$AFL_PREFIX" >/dev/null
    log "AFL++ core installed under $AFL_PREFIX"
    cd "$ROOT"
fi

# --- 4. QEMU mode from the same source -------------------------------------
if [[ ! -x "$AFL_PREFIX/lib/afl/afl-qemu-trace" ]]; then
    log "building afl-qemu-trace (static) from qemuafl ${QEMUAFL_COMMIT}"
    if [[ ! -x "$SYSROOT/usr/bin/ninja" ]]; then
        mkdir -p "$WORK/debs" "$SYSROOT"
        cd "$WORK/debs"
        apt-get download "${DEBS[@]}" >/dev/null
        for deb in ./*.deb; do dpkg -x "$deb" "$SYSROOT"; done
        log "build dependencies extracted into private sysroot $SYSROOT"
        cd "$ROOT"
    fi
    cd "$WORK/AFLplusplus-${AFL_VERSION}/qemu_mode"
    # The release tarball ships qemuafl/ empty (a gitlink); check out the
    # pinned commit this AFL++ build expects.
    if [[ ! -f qemuafl/configure ]]; then
        cd qemuafl
        if [[ ! -d .git ]]; then
            git init -q .
            git remote add origin https://github.com/AFLplusplus/qemuafl.git
        fi
        git fetch -q --depth 1 origin "$QEMUAFL_COMMIT"
        git checkout -q FETCH_HEAD
        cd ..
    fi
    # STATIC=1 so afl-qemu-trace needs no sysroot libraries at run time.
    # PKG_CONFIG_SYSROOT_DIR/LIBDIR make pkg-config resolve the extracted
    # .pc files' prefix=/usr against the sysroot, so configure finds the
    # headers and the 64-bit glibconfig.h it expects.
    env PATH="$SYSROOT/usr/bin:$PATH" \
         PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/x86_64-linux-gnu/pkgconfig:$SYSROOT/usr/share/pkgconfig" \
         PKG_CONFIG_SYSROOT_DIR="$SYSROOT" \
         LIBRARY_PATH="$SYSROOT/usr/lib/x86_64-linux-gnu" \
         CPU_TARGET=x86_64 STATIC=1 \
         sh build_qemu_support.sh >"$WORK/qemu-build.log" 2>&1 || {
            log "ERROR: qemu build failed; last lines of $WORK/qemu-build.log:" >&2
            tail -30 "$WORK/qemu-build.log" >&2
            exit 1
         }
    mkdir -p "$AFL_PREFIX/lib/afl"
    # build_qemu_support.sh leaves the trace binary one level up.
    cp ../afl-qemu-trace "$AFL_PREFIX/lib/afl/afl-qemu-trace"
    log "afl-qemu-trace installed"
    cd "$ROOT"
fi

# --- 5. The argv harness ----------------------------------------------------
if [[ ! -x "$ROOT/fuzz/harness/argv-file" ]]; then
    log "compiling fuzz/harness/argv-file"
    cc -O2 -o "$ROOT/fuzz/harness/argv-file" "$ROOT/fuzz/harness/argv-file.c"
fi

# --- 6. Smoke test: QEMU mode on a trivial target ---------------------------
log "smoke test: afl-showmap -Q over /bin/true via the harness"
printf 'hello' > "$WORK/smoke-input"
export AFL_PATH="$AFL_PREFIX/lib/afl" \
       AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 AFL_SKIP_CPUFREQ=1
"$AFL_PREFIX/bin/afl-showmap" -Q -m none -t 5000 -- \
    "$ROOT/fuzz/harness/argv-file" /bin/true "$WORK/smoke-input" \
    -o "$WORK/smoke-map" >/dev/null 2>&1 || { log "ERROR: QEMU smoke test failed"; exit 1; }
log "smoke test ok: $(wc -l < "$WORK/smoke-map") tuples"

log "host ready. Toolchain: $AFL_PREFIX/bin (AFL++ ${AFL_VERSION}, qemuafl ${QEMUAFL_COMMIT:0:9})"
