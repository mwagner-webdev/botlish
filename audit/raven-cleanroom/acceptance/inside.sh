#!/usr/bin/env bash
# inside.sh -- the clean-room acceptance, run inside the clean-room container
# as the user `dev` (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md; started by
# tools/cleanroom.sh run).
#
# Inputs, copied in by cleanroom.sh, nothing else:
#   /home/dev/inputs/botlish             the single-file compiler
#   /home/dev/inputs/raven-*.botpkg      the raven release
#   /home/dev/harness/                   this script, window.bot (the test's
#                                        own application), desktop-session.sh
#                                        and xsession.py (an X client)
#
# Every command is written to $OUT/transcript with its output and status,
# and every check to $OUT/checks ("ok NAME" or "FAIL NAME"). The container
# has no network (--network none).
set -uo pipefail

OUT=${OUT:-/home/dev/out}
H=/home/dev/harness
mkdir -p "$OUT"
: > "$OUT/transcript"
: > "$OUT/checks"
BOTLISH=/home/dev/inputs/botlish
PKG=$(ls /home/dev/inputs/raven-*.botpkg)
failures=0

# run DESCRIPTION -- COMMAND...: the command, its output and status into
# the transcript; its output in $LAST, its status in $STATUS.
run() {
  local description=$1
  shift 2
  {
    echo
    echo "### $description"
    echo "\$ $*"
  } >> "$OUT/transcript"
  LAST=$("$@" 2>&1)
  STATUS=$?
  export LAST
  printf '%s\n[exit %s]\n' "$LAST" "$STATUS" >> "$OUT/transcript"
}

check() { # NAME CONDITION...
  local name=$1
  shift
  if "$@"; then
    echo "ok   $name" >> "$OUT/checks"
  else
    echo "FAIL $name" >> "$OUT/checks"
    failures=$((failures + 1))
  fi
}

has() { grep -qF -- "$1" <<< "$LAST"; }

# ---------------------------------------------------------------------------
# A. The environment

run "the system" -- bash -c 'grep PRETTY_NAME /etc/os-release; uname -m; id -un; ldd --version | head -1'
run "no network" -- bash -c 'cat /proc/net/route | wc -l; ls /sys/class/net'
check network-none bash -c "! grep -q eth0 <<< \"\$(ls /sys/class/net)\""
run "development tools that must be absent" -- bash -c 'for t in tclsh tclsh9.0 cargo rustc cmake ninja git curl wget clang; do printf "%s: %s\n" $t "$(command -v $t || echo absent)"; done'
check no-development-tools bash -c "! grep -v absent <<< \"\$LAST\" | grep -q ."
run "no Botlish or Raven checkout anywhere" -- bash -c 'find / -xdev \( -name main.tcl -o -name tests -path "*botlish*" -o -name "c-bindgen.tcl" -o -name "raven-package.tcl" -o -name "package-repository.tcl" -o -name Raven.h -o -name "raven_core.h" -o -name CMakeLists.txt -path "*aven*" \) -print 2>/dev/null | head; ls /home; echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-unset}"'
check no-checkout bash -c "! grep -qE 'main.tcl|c-bindgen|raven-package|package-repository|Raven.h|raven_core.h|CMakeLists' <<< \"\$LAST\""
check no-library-path bash -c "grep -q 'LD_LIBRARY_PATH=unset' <<< \"\$LAST\""
run "the operating system's graphics facilities" -- bash -c 'ls /usr/lib/x86_64-linux-gnu/libX11.so.6 /usr/lib/x86_64-linux-gnu/libvulkan.so.1; ls /usr/share/vulkan/icd.d; command -v Xvfb cc'
run "the two inputs" -- bash -c "ls -l $BOTLISH $PKG; sha256sum $BOTLISH $PKG"
run "the compiler" -- "$BOTLISH" -version

# ---------------------------------------------------------------------------
# B. Installation

mkdir -p /home/dev/app
cd /home/dev/app
run "install the package from the artifact" -- "$BOTLISH" add "$PKG"
check add-succeeds test "$STATUS" = 0
check add-checks-system-x11 has "view linux-x86_64: derived"
run "what was written" -- bash -c 'cat botlish.json; find .bot_modules -maxdepth 2 | sort | head -20; find .bot_modules -name "*.o" -o -name "*.c" -newer botlish.json | grep -v raven_bridge.c | head'
check installed-docs test -f .bot_modules/raven/README.md -a -f .bot_modules/raven/GUIDE.md -a -f .bot_modules/raven/examples/clicks/clicks.bot
check installed-binding test -f .bot_modules/.targets/linux-x86_64/raven/raven/core.bot
check installed-bridge test -f .bot_modules/.targets/linux-x86_64/raven/native/libraven_bridge.a
run "verify the installation" -- "$BOTLISH" verify
check verify-succeeds test "$STATUS" = 0
run "the native plan" -- "$BOTLISH" native plan
check plan-x11-system has "library X11: system shared"
check plan-x11-dpkg has "dpkg package libx11-6"
check plan-no-L has "no -L is needed"
run "an unsupported target is refused" -- "$BOTLISH" install -target macos-aarch64
check unsupported-target has "UNSUPPORTED"
run "the other Linux target's view (its binding and AArch64 libraries, from the same artifact)" -- "$BOTLISH" install -target linux-aarch64
check aarch64-view test "$STATUS" = 0
run "its native plan (system libX11 of another target: unverified)" -- "$BOTLISH" native plan -target linux-aarch64
check aarch64-plan has "ELF AArch64 shared object"
run "drop it again" -- "$BOTLISH" install -drop-target linux-aarch64

# ---------------------------------------------------------------------------
# C. The documentation's programs, compiled and run from the installed files only

cp .bot_modules/raven/examples/clicks/*.bot .
run "the example's headless test (no DISPLAY)" -- env -u DISPLAY "$BOTLISH" -warnings error -backend cranelift test.bot
check example-test has '["2", "2 clicks", "0", "0 clicks"]'
run "the same on cranelift-generic" -- env -u DISPLAY "$BOTLISH" -warnings error -backend cranelift-generic test.bot
check example-test-generic has '["2", "2 clicks", "0", "0 clicks"]'
run "the desktop entry compiles" -- "$BOTLISH" -check -warnings error main.bot
check example-main-checks has "ok"
run "the Tcl backends refuse a C call" -- "$BOTLISH" -backend interp test.bot
check interp-refuses has "NATIVE-ONLY"

# ---------------------------------------------------------------------------
# D. Failures that must say what is missing

cp "$H/window.bot" .
run "desktop with no display" -- env -u DISPLAY "$BOTLISH" -backend cranelift window.bot
check no-display-actionable has "X11: cannot open the display (is DISPLAY set?)"
exec 8< <(Xvfb -displayfd 1 -screen 0 800x600x24 -nolisten tcp 2>/dev/null)
read -r n <&8
run "a display, but no Vulkan driver (an empty driver list)" -- env DISPLAY=":$n" VK_ICD_FILENAMES=/nonexistent.json "$BOTLISH" -backend cranelift window.bot
check no-driver-actionable bash -c "grep -q 'RavenFailed Rinit_ex: Vulkan:' <<< \"\$LAST\""
pkill -f "Xvfb -displayfd 1" || true

# ---------------------------------------------------------------------------
# E. The real window: X11, Vulkan (lavapipe), clicks through the X server

run "desktop session, cranelift (the program compiled and linked by the native backend)" -- "$H/desktop-session.sh" "$OUT/session-cranelift" "$BOTLISH" -backend cranelift window.bot
check desktop-cranelift has "PASS"
run "desktop session, cranelift-generic" -- "$H/desktop-session.sh" "$OUT/session-generic" "$BOTLISH" -backend cranelift-generic window.bot
check desktop-generic has "PASS"

# ---------------------------------------------------------------------------
# F. Deployment: an executable and its libraries, moved, the packages removed

run "deploy the bundled shared libraries" -- "$BOTLISH" native deploy -target linux-x86_64 -out dist
check deploy-succeeds test -f dist/lib/libraven.so.0
run "emit the executable with a relative runtime path" -- "$BOTLISH" -emit-native-executable -runtime-path '$ORIGIN/lib' window.bot
run "emit the headless test as an executable too" -- "$BOTLISH" -emit-native-executable -runtime-path '$ORIGIN/lib' test.bot
mv window test dist/
run "the executable's dynamic section" -- bash -c 'cd dist && LC_ALL=C readelf -d window | grep -E "NEEDED|RUNPATH"'
check runpath-origin has 'Library runpath: [$ORIGIN/lib]'
mkdir -p /home/dev/elsewhere/deep
mv dist /home/dev/elsewhere/deep/moved
run "remove the package from the project" -- "$BOTLISH" remove raven
check remove-succeeds test "$STATUS" = 0
run "nothing of the package is left" -- bash -c 'ls -a /home/dev/app; find / -xdev -name "libraven.so*" 2>/dev/null'
check package-gone bash -c "! grep -q '/home/dev/app/.bot_modules' <<< \"\$LAST\""
run "which libraven the moved executable resolves (the loader's own trace)" -- bash -c 'cd /tmp && ldd /home/dev/elsewhere/deep/moved/window | grep -E "raven|X11"'
check loads-deployed-library has "/home/dev/elsewhere/deep/moved/lib/libraven.so.0"
# An executable prints no value of its own (PROGRAM-OUTPUT-MILESTONE-1.md):
# its value is read through the driver protocol, the words of the result
# file's `value V` line with their quoting removed.
run "the moved headless test runs" -- env -u DISPLAY BOTLISH_NATIVE_RESULT=/tmp/moved-test.result /home/dev/elsewhere/deep/moved/test
run "its value (the driver protocol's result file)" -- bash -c 'tr -d "\\\\{}" < /tmp/moved-test.result | tr -s " \n" " "'
check moved-test-runs has 'value list str 2 str 2 clicks str 0 str 0 clicks'
run "the moved desktop program on a real window" -- "$H/desktop-session.sh" "$OUT/session-moved" /home/dev/elsewhere/deep/moved/window
check desktop-moved has "PASS"
run "the libraries the running program mapped" -- cat "$OUT/session-moved/mapped"
check maps-deployed-library has "/home/dev/elsewhere/deep/moved/lib/libraven.so.0"
mkdir -p /tmp/decoy && cp /home/dev/elsewhere/deep/moved/lib/libraven.so.0 /tmp/decoy/
run "loader precedence: LD_LIBRARY_PATH is searched before RUNPATH" -- bash -c 'cd /tmp && LD_LIBRARY_PATH=/tmp/decoy ldd /home/dev/elsewhere/deep/moved/window | grep raven'
check precedence-documented has "/tmp/decoy/libraven.so.0"

echo >> "$OUT/checks"
if [[ $failures == 0 ]]; then echo "PASS" >> "$OUT/checks"; else echo "FAIL ($failures)" >> "$OUT/checks"; fi
cat "$OUT/checks"
exit $((failures > 0))
