#!/usr/bin/env bash
# emulator.sh IMAGE -- boots the Android emulator with the system image IMAGE
# (an sdkmanager package, e.g. "system-images;android-34;google_apis;x86_64")
# on a GitHub Linux runner with KVM, waits for it, and states what it is:
# its ABIs (an x86_64 image runs arm64-v8a apps through Android's native
# bridge, ro.dalvik.vm.native.bridge, when it lists arm64-v8a), its API
# level and its page size. Exit status 1 when it does not boot, or runs no
# arm64-v8a code. (From the React Native census's audit/react-native/ci/
# android-emulator.sh: the current command-line tools first, the AVD
# directory named for both avdmanager and the emulator.)
set -euo pipefail
image=${1:?usage: emulator.sh IMAGE}
sdk=${ANDROID_HOME:?}
sudo apt-get update -qq
sudo apt-get install -y -qq libpulse0 libgl1 libnss3 libxcomposite1 libxcursor1 libxi6 libxtst6 >/dev/null
old=$(ls -d "$sdk"/cmdline-tools/*/bin/sdkmanager | sort -V | tail -1)
yes | "$old" --licenses >/dev/null || true
for _ in 1 2 3; do "$old" --install "cmdline-tools;latest" >/dev/null && break || sleep 10; done
sm=$(ls -d "$sdk"/cmdline-tools/*/bin/sdkmanager | sort -V | tail -1)
yes | "$sm" --licenses >/dev/null || true
for _ in 1 2 3; do "$sm" --install emulator platform-tools "$image" >/dev/null && break || sleep 15; done
"$sdk/emulator/emulator" -version | head -1
export ANDROID_AVD_HOME=$HOME/.android/avd
mkdir -p "$ANDROID_AVD_HOME"
echo no | "$(dirname "$sm")/avdmanager" create avd --force -n botlish -k "$image" >/dev/null
log=${RUNNER_TEMP:-/tmp}/emulator.log
nohup "$sdk/emulator/emulator" -avd botlish -no-window -gpu swiftshader_indirect -no-snapshot \
    -noaudio -no-boot-anim -accel on -memory 4096 >"$log" 2>&1 &
emulator=$!
export PATH="$sdk/platform-tools:$PATH"
fail() {
    echo "emulator: $1"
    adb devices -l || true
    tail -80 "$log"
    exit 1
}
started=$(date +%s)
for _ in $(seq 1 180); do
    kill -0 "$emulator" 2>/dev/null || fail "exited before boot"
    if [[ $(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') == 1 ]]; then
        echo "emulator booted in $(( $(date +%s) - started )) s"
        adb shell settings put global window_animation_scale 0 || true
        adb shell settings put global transition_animation_scale 0 || true
        adb shell settings put global animator_duration_scale 0 || true
        abis=$(adb shell getprop ro.product.cpu.abilist | tr -d '\r')
        echo "image $image"
        echo "abilist $abis"
        echo "native.bridge $(adb shell getprop ro.dalvik.vm.native.bridge | tr -d '\r')"
        echo "sdk $(adb shell getprop ro.build.version.sdk | tr -d '\r') release $(adb shell getprop ro.build.version.release | tr -d '\r')"
        echo "page-size $(adb shell getconf PAGE_SIZE | tr -d '\r')"
        echo "kernel $(adb shell uname -r | tr -d '\r')"
        [[ ,$abis, == *,arm64-v8a,* ]] || fail "the image runs no arm64-v8a code (abilist $abis)"
        exit 0
    fi
    sleep 5
done
fail "not booted after fifteen minutes"
