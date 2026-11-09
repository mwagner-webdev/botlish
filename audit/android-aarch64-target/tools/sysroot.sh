#!/usr/bin/env bash
# sysroot.sh -- Android userspaces to run Android AArch64 programs in
# (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, "Android execution"):
# Google's arm64-v8a emulator system images, downloaded from Google's SDK
# repository, checked against the SHA-1 the repository's manifest states
# (pinned here), and unpacked into ROOT/api-N/root -- /system/bin/linker64,
# /system/lib64 (Bionic, liblog, the platform libraries) and, from Android
# 10, /apex/com.android.runtime (where Bionic moved). tools/android-run.sh
# runs a program in one.
#
#   sysroot.sh OUT [API...]       (default: 21 24 35)
#
# Needs curl, unzip, debugfs (e2fsprogs) and python3. Nothing is run from
# the images: their files are read as data. An image's absolute symbolic
# links are made relative to the root (relink.py), so that the root works as
# a prefix; Android 10+'s dynamic-partition image is unpacked by lpunpack.py.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
out=$(realpath -m "${1:?usage: sysroot.sh OUT [API...]}")
shift
apis=("$@")
[[ ${#apis[@]} -gt 0 ]] || apis=(21 24 35)
base=https://dl.google.com/android/repository/sys-img/android
declare -A file=([21]=arm64-v8a-21_r04.zip [24]=arm64-v8a-24_r09.zip [35]=arm64-v8a-35_r02.zip)
declare -A sha1=([21]=c4375f1b4b4cd21a8617660e25f621cedcbd8332 [24]=e88ebdf4533efa0370603ee4ab0e7834e0cc364f [35]=2026a06409db630b56711afdbffb457c1dbaed49)
for api in "${apis[@]}"; do
    [[ -n ${file[$api]:-} ]] || { echo "sysroot.sh: no pinned image of API $api" >&2; exit 2; }
    dir="$out/api-$api"
    if [[ -x $dir/root/system/bin/linker64 || -L $dir/root/system/bin/linker64 ]]; then
        echo "api-$api: $dir/root (present)"
        continue
    fi
    rm -rf "$dir"
    mkdir -p "$dir/image" "$dir/root"
    zip="$dir/${file[$api]}"
    curl -sS -fL -o "$zip" "$base/${file[$api]}"
    got=$(sha1sum "$zip" | cut -d' ' -f1)
    [[ $got == "${sha1[$api]}" ]] || { echo "sysroot.sh: ${file[$api]}: SHA-1 $got, not ${sha1[$api]}" >&2; exit 1; }
    unzip -q -o "$zip" -d "$dir/image"
    img="$dir/image/arm64-v8a/system.img"
    mkdir -p "$dir/root/system"
    if file "$img" | grep -q 'DOS/MBR'; then
        # A GPT disk image holding a dynamic-partition "super" at its 2nd
        # partition's sector 4096; the system partition's root is /system.
        python3 -I "$here/lpunpack.py" "$img" $((4096 * 512)) "$dir/parts" >/dev/null
        debugfs -R "rdump /system/lib64 $dir/root/system" "$dir/parts/system.img" 2>/dev/null
        debugfs -R "rdump /system/etc $dir/root/system" "$dir/parts/system.img" 2>/dev/null
        mkdir -p "$dir/root/system/bin" "$dir/root/apex/com.android.runtime"
        debugfs -R "dump /system/apex/com.android.runtime.apex $dir/runtime.apex" "$dir/parts/system.img" 2>/dev/null
        mkdir -p "$dir/apex" && unzip -q -o "$dir/runtime.apex" apex_payload.img -d "$dir/apex"
        debugfs -R "rdump / $dir/root/apex/com.android.runtime" "$dir/apex/apex_payload.img" 2>/dev/null
        ln -sf /apex/com.android.runtime/bin/linker64 "$dir/root/system/bin/linker64"
        rm -rf "$dir/parts" "$dir/apex" "$dir/runtime.apex"
    else
        # An ext4 image whose root is /system.
        debugfs -R "rdump /lib64 $dir/root/system" "$img" 2>/dev/null
        debugfs -R "rdump /bin $dir/root/system" "$img" 2>/dev/null
    fi
    python3 -I "$here/relink.py" "$dir/root" >/dev/null
    rm -rf "$dir/image" "$zip"
    echo "api-$api: $dir/root"
done
