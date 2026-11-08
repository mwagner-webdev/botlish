#!/usr/bin/env bash
# android-run.sh -- runs an Android AArch64 executable in an Android
# userspace: Android's own dynamic linker (/system/bin/linker64) and Bionic
# from a Google system image (tools/sysroot.sh), under qemu-aarch64's
# user-mode emulation (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md,
# "Android execution").
#
#   android-run.sh [-p PAGESIZE] ROOT PROGRAM [ARG...]
#
# ROOT is the system image's root (sysroot.sh's OUT/api-N/root): its /system
# and /apex are where Android's linker finds Bionic and the platform
# libraries. PROGRAM's directory is added to the linker's search path (the
# library beside it, as an application's lib directory). -p presents
# PAGESIZE as the page size (qemu's -p: AT_PAGESZ, sysconf and qemu's own
# mmap granularity), for the 16 KiB page-size checks.
#
# This is an Android process's userspace -- Android's linker, libc, libdl,
# libm and liblog loading and running the program -- on the host's Linux
# kernel, not a device or an emulator: no zygote, ART, property service,
# SELinux or Android kernel. The report says which evidence is which.
set -euo pipefail
page=""
if [[ ${1:-} == -p ]]; then
    page=$2
    shift 2
fi
if [[ $# -lt 2 ]]; then
    echo "usage: android-run.sh [-p PAGESIZE] ROOT PROGRAM [ARG...]" >&2
    exit 2
fi
root=$(realpath "$1")
program=$(realpath "$2")
shift 2
dir=$(dirname "$program")
export LD_LIBRARY_PATH="$dir"
args=(-L "$root")
if [[ -n $page ]]; then
    args+=(-p "$page")
fi
exec qemu-aarch64 "${args[@]}" "$program" "$@"
