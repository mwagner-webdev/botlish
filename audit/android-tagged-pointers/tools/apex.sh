#!/usr/bin/env bash
# apex.sh -- more of an Android userspace: the APEXes beyond Bionic's
# runtime that a library a test loads needs
# (RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1.md, "SDL3
# integration"). audit/android-aarch64-target/tools/sysroot.sh unpacks
# /system/lib64 and the runtime APEX (Bionic); Android's libSDL3.so needs
# libandroid.so, whose libharfbuzz_ng.so needs ICU, which Android 10 and
# later keep in the i18n APEX. This unpacks named APEXes of the same pinned
# image into ROOT/apex/NAME.
#
#   apex.sh ROOT API APEX...      (e.g. apex.sh OUT/api-35/root 35 com.android.i18n)
#
# The image is the one sysroot.sh pins (its SHA-1 checked again); nothing
# is run from it. Needs curl, unzip, debugfs and python3.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
tools=$(cd "$here/../../android-aarch64-target/tools" && pwd)
root=$(realpath "${1:?usage: apex.sh ROOT API APEX...}")
api=${2:?usage: apex.sh ROOT API APEX...}
shift 2
[[ $# -gt 0 ]] || { echo "usage: apex.sh ROOT API APEX..." >&2; exit 2; }
declare -A file=([35]=arm64-v8a-35_r02.zip)
declare -A sha1=([35]=2026a06409db630b56711afdbffb457c1dbaed49)
[[ -n ${file[$api]:-} ]] || { echo "apex.sh: no pinned dynamic-partition image of API $api" >&2; exit 2; }
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -sS -fL -o "$work/image.zip" "https://dl.google.com/android/repository/sys-img/android/${file[$api]}"
got=$(sha1sum "$work/image.zip" | cut -d' ' -f1)
[[ $got == "${sha1[$api]}" ]] || { echo "apex.sh: ${file[$api]}: SHA-1 $got, not ${sha1[$api]}" >&2; exit 1; }
unzip -q -o "$work/image.zip" arm64-v8a/system.img -d "$work"
python3 -I "$tools/lpunpack.py" "$work/arm64-v8a/system.img" $((4096 * 512)) "$work/parts" >/dev/null
rm -f "$work/image.zip" "$work/arm64-v8a/system.img"
for apex in "$@"; do
    debugfs -R "dump /system/apex/$apex.apex $work/$apex.apex" "$work/parts/system.img" 2>/dev/null
    [[ -s $work/$apex.apex ]] || { echo "apex.sh: the image has no /system/apex/$apex.apex" >&2; exit 1; }
    unzip -q -o "$work/$apex.apex" apex_payload.img -d "$work/$apex"
    mkdir -p "$root/apex/$apex"
    debugfs -R "rdump / $root/apex/$apex" "$work/$apex/apex_payload.img" 2>/dev/null
    # The APEX's libraries, visible to the system's namespace as Android's
    # generated linker configuration makes its public ones (the userspace
    # has no /linkerconfig: android-run.sh's linker searches /system/lib64
    # and the program's directory): a relative link each, where
    # /system/lib64 has no library of that name.
    for library in "$root/apex/$apex"/lib64/*.so; do
        [[ -e $library ]] || continue
        name=${library##*/}
        [[ -e $root/system/lib64/$name || -L $root/system/lib64/$name ]] || ln -s "../../apex/$apex/lib64/$name" "$root/system/lib64/$name"
    done
    echo "$apex: $root/apex/$apex"
done
python3 -I "$tools/relink.py" "$root" >/dev/null
