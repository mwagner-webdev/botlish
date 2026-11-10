#!/usr/bin/env bash
# inspect-apk.sh APK OUT -- what the app's APK holds of the Botlish packages
# (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md, "ABI and Android
# packaging"), read from its bytes, never run:
#
#   * every native library and its ABI directory (arm64-v8a only);
#   * each Botlish library is the generated package's, as Android's build
#     packages it: byte for byte the NDK's `llvm-strip --strip-unneeded` of
#     the library the tool checked against its manifest (the build's
#     stripReleaseDebugSymbols), its code and dynamic symbols unchanged;
#   * every shared object's loadable segments aligned to 16 KiB, and the APK
#     zip-aligned for 16 KiB pages (zipalign -c -P 16);
#   * libappmodules.so needs the Botlish libraries by their SONAMEs and holds
#     no Botlish runtime of its own (no botlish_library_* symbol);
#   * the manifest's extractNativeLibs is true: the libraries are extracted
#     at installation (React Native's SoLoader and the native bridge).
#
# OUT is build.sh's output (its generated/ packages). Exit status 1 on any
# difference.
set -euo pipefail
apk=$(realpath "$1")
out=$(realpath "$2")
# The NDK the app's build used (its ndkVersion): its llvm-strip is the one
# whose output the APK holds.
ndkVersion=$(sed -n 's/^ *ndkVersion *= *"\(.*\)"/\1/p' "$out/app/android/build.gradle" 2>/dev/null)
ndk="$ANDROID_HOME/ndk/${ndkVersion:-missing}"
[[ -d $ndk ]] || ndk=$(ls -d "$ANDROID_HOME"/ndk/* | sort -V | tail -1)
bin="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin"
echo "ndk $(basename "$ndk") (the app's build's)"
build_tools=$(ls -d "$ANDROID_HOME"/build-tools/* | sort -V | tail -1)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
status=0
fail() { echo "FAIL $*"; status=1; }
echo "apk $(basename "$apk") $(stat -c %s "$apk") bytes sha256 $(sha256sum "$apk" | cut -d' ' -f1)"
(cd "$work" && unzip -q "$apk" 'lib/*')
abis=$(cd "$work/lib" && ls)
echo "abis $abis"
[[ $abis == arm64-v8a ]] || fail "the APK holds ABIs other than arm64-v8a: $abis"
for so in "$work"/lib/arm64-v8a/*.so; do
    align=$("$bin/llvm-readelf" -l "$so" | awk '$1 == "LOAD" { print $NF }' | sort -u | tr '\n' ' ')
    echo "so $(basename "$so") $(stat -c %s "$so") bytes, LOAD alignment $align"
    for a in $align; do
        (( a >= 16384 )) || fail "$(basename "$so") has a segment aligned to $a"
    done
done
for package in "$out"/generated/react-native-botlish-*; do
    lib=$(ls "$package/native/android/arm64-v8a")
    packaged="$work/lib/arm64-v8a/$lib"
    [[ -f $packaged ]] || { fail "$lib is not in the APK"; continue; }
    "$bin/llvm-strip" --strip-unneeded -o "$work/stripped.so" "$package/native/android/arm64-v8a/$lib"
    expected=$(sha256sum <"$work/stripped.so" | cut -d' ' -f1)
    actual=$(sha256sum <"$packaged" | cut -d' ' -f1)
    recorded=$(sed -n 's/.*"shared": "\([0-9a-f]*\)".*/\1/p' "$package/botlish-react-native.json")
    original=$(sha256sum <"$package/native/android/arm64-v8a/$lib" | cut -d' ' -f1)
    echo "botlish $lib package sha256 $original (manifest $recorded), packaged $actual, strip-unneeded of the package's $expected"
    [[ $original == "$recorded" ]] || fail "$lib in the package is not the manifest's"
    [[ $actual == "$expected" ]] || fail "$lib in the APK is not the package's library as the Android build strips it"
    for section in .text .rodata; do
        "$bin/llvm-objcopy" -O binary --only-section="$section" "$packaged" "$work/a"
        "$bin/llvm-objcopy" -O binary --only-section="$section" "$package/native/android/arm64-v8a/$lib" "$work/b"
        cmp -s "$work/a" "$work/b" || fail "$lib: $section differs from the package's"
    done
    cmp -s <("$bin/llvm-nm" -D "$packaged") <("$bin/llvm-nm" -D "$package/native/android/arm64-v8a/$lib") ||
        fail "$lib: the dynamic symbols differ from the package's"
    echo "botlish $lib .text, .rodata and dynamic symbols identical to the generated package's"
done
needed=$("$bin/llvm-readelf" -d "$work/lib/arm64-v8a/libappmodules.so" | sed -n 's/.*(NEEDED).*\[\(.*\)\]/\1/p' | sort | tr '\n' ' ')
echo "libappmodules.so needs $needed"
for lib in libgame.so libtextkit.so; do
    [[ " $needed " == *" $lib "* ]] || fail "libappmodules.so does not need $lib"
done
runtime=$("$bin/llvm-nm" -D --defined-only "$work/lib/arm64-v8a/libappmodules.so" | grep -c "botlish_library_\|botlish_fn_" || true)
echo "libappmodules.so defines $runtime Botlish runtime symbols"
[[ $runtime == 0 ]] || fail "libappmodules.so carries Botlish runtime symbols of its own"
if "$build_tools/zipalign" -c -P 16 4 "$apk" >/dev/null; then
    echo "zipalign -c -P 16 4: verification successful"
else
    fail "the APK is not zip-aligned for 16 KiB pages"
fi
# The native libraries are extracted at installation (the app's
# useLegacyPackaging): on a native-bridge device React Native's SoLoader finds
# an arm64-v8a-only app's libraries only in its native library directory
# (examples/react-native/app/android/app/build.gradle says why).
extract=$("$build_tools/aapt2" dump xmltree --file AndroidManifest.xml "$apk" | sed -n 's/.*:extractNativeLibs([^)]*)=\([a-z]*\).*/\1/p')
echo "manifest extractNativeLibs ${extract:-unset}"
[[ $extract == true ]] || fail "the APK keeps its native libraries unextracted (extractNativeLibs ${extract:-unset}): an arm64-v8a app does not start on a native-bridge device"
exit $status
