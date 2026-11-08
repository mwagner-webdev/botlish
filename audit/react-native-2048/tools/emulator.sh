#!/usr/bin/env bash
# emulator.sh IMAGE... -- boots the Android emulator with the first system
# image (sdkmanager packages, e.g. "system-images;android-34;google_apis;
# x86_64") that runs arm64-v8a code, on a GitHub Linux runner with KVM, and
# states what it is: its ABIs (an x86_64 image runs arm64-v8a apps through
# Android's native bridge, ro.dalvik.vm.native.bridge, when it lists
# arm64-v8a), its API level and its page size. An image that boots without
# arm64-v8a is shut down and the next one tried. Exit status 1 when none
# boots and runs arm64-v8a code. (From the React Native census's
# audit/react-native/ci/android-emulator.sh: the current command-line tools
# first, the AVD directory named for both avdmanager and the emulator.)
set -euo pipefail
[[ $# -gt 0 ]] || { echo "usage: emulator.sh IMAGE..." >&2; exit 2; }
sdk=${ANDROID_HOME:?}
sudo apt-get update -qq
sudo apt-get install -y -qq libpulse0 libgl1 libnss3 libxcomposite1 libxcursor1 libxi6 libxtst6 >/dev/null
old=$(ls -d "$sdk"/cmdline-tools/*/bin/sdkmanager | sort -V | tail -1)
yes | "$old" --licenses >/dev/null || true
for _ in 1 2 3; do "$old" --install "cmdline-tools;latest" >/dev/null && break || sleep 10; done
sm=$(ls -d "$sdk"/cmdline-tools/*/bin/sdkmanager | sort -V | tail -1)
yes | "$sm" --licenses >/dev/null || true
for _ in 1 2 3; do "$sm" --install emulator platform-tools >/dev/null && break || sleep 15; done
"$sdk/emulator/emulator" -version | head -1
export ANDROID_AVD_HOME=$HOME/.android/avd
export PATH="$sdk/platform-tools:$PATH"
mkdir -p "$ANDROID_AVD_HOME"
log=${RUNNER_TEMP:-/tmp}/emulator.log

# Boots IMAGE: 0 when it runs arm64-v8a code (left running), 1 otherwise
# (shut down).
boot() {
    local image=$1
    echo "== $image"
    for _ in 1 2 3; do "$sm" --install "$image" >/dev/null && break || sleep 15; done
    echo no | "$(dirname "$sm")/avdmanager" create avd --force -n botlish -k "$image" >/dev/null
    nohup "$sdk/emulator/emulator" -avd botlish -no-window -gpu swiftshader_indirect -no-snapshot \
        -noaudio -no-boot-anim -accel on -memory 4096 >"$log" 2>&1 &
    local emulator=$! started
    started=$(date +%s)
    for _ in $(seq 1 180); do
        if ! kill -0 "$emulator" 2>/dev/null; then
            echo "emulator: exited before boot"
            tail -40 "$log"
            return 1
        fi
        if [[ $(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') == 1 ]]; then
            echo "emulator booted in $(( $(date +%s) - started )) s"
            local abis
            abis=$(adb shell getprop ro.product.cpu.abilist | tr -d '\r')
            echo "image $image"
            echo "abilist $abis"
            echo "native.bridge $(adb shell getprop ro.dalvik.vm.native.bridge | tr -d '\r')"
            echo "sdk $(adb shell getprop ro.build.version.sdk | tr -d '\r') release $(adb shell getprop ro.build.version.release | tr -d '\r')"
            echo "page-size $(adb shell getconf PAGE_SIZE | tr -d '\r')"
            echo "kernel $(adb shell uname -r | tr -d '\r')"
            if [[ ,$abis, != *,arm64-v8a,* ]]; then
                echo "emulator: $image runs no arm64-v8a code (abilist $abis): shut down"
                adb emu kill >/dev/null 2>&1 || kill "$emulator"
                wait "$emulator" 2>/dev/null || true
                return 1
            fi
            adb shell settings put global window_animation_scale 0 || true
            adb shell settings put global transition_animation_scale 0 || true
            adb shell settings put global animator_duration_scale 0 || true
            return 0
        fi
        sleep 5
    done
    echo "emulator: $image not booted after fifteen minutes"
    tail -40 "$log"
    kill "$emulator" 2>/dev/null || true
    return 1
}

for image in "$@"; do
    boot "$image" && exit 0
done
echo "emulator: no image of $* boots and runs arm64-v8a code"
adb devices -l || true
exit 1
