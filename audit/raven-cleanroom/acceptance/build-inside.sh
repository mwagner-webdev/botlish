#!/usr/bin/env bash
# build-inside.sh -- the clean-room half of tools/build-app.sh
# (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md): run in the container as the user
# dev, with the application's sources in /home/dev/app, the compiler and the
# release in /home/dev/inputs, and NAME and TITLE in the environment. It
# writes /home/dev/build.log and /home/dev/NAME-linux-x86_64.tar.gz.
set -uo pipefail
umask 022
B=/home/dev/inputs/botlish
log=/home/dev/build.log
: > "$log"
step() { # DESCRIPTION -- COMMAND...
  local d=$1; shift 2
  printf "\n### %s\n$ %s\n" "$d" "$*" >> "$log"
  "$@" >> "$log" 2>&1
  local s=$?
  echo "[exit $s]" >> "$log"
  if [[ $s != 0 ]]; then echo "FAILED: $d (exit $s)" | tee -a "$log"; exit 1; fi
}
cd /home/dev/app
step "the compiler" -- "$B" -version
step "install the package" -- "$B" add /home/dev/inputs/raven-*.botpkg
if [[ -f test.bot ]]; then
  step "the headless test" -- env -u DISPLAY "$B" -backend cranelift test.bot
fi
step "deploy the bundled libraries" -- "$B" native deploy -target linux-x86_64 -out "$NAME"
step "emit the executable" -- "$B" -emit-native-executable -runtime-path '$ORIGIN/lib' main.bot
mv main "$NAME/$NAME"
rm -f "$NAME/.botlish-deploy.json"
step "the executable" -- bash -c "LC_ALL=C readelf -d $NAME/$NAME | grep -E \"NEEDED|RUNPATH\"; ldd $NAME/$NAME | grep -E \"raven|X11\""

# A smoke run on a virtual display: the window found and closed from outside.
exec 9< <(exec Xvfb -displayfd 1 -screen 0 1024x768x24 -nolisten tcp 2>/dev/null)
xvfb=$!
read -r -t 20 number <&9 || { echo "FAILED: no virtual display" | tee -a "$log"; exit 1; }
export DISPLAY=":$number"
"./$NAME/$NAME" > smoke.out 2>&1 &
app=$!
step "the window" -- python3 -I /home/dev/harness/xsession.py find "$TITLE" 120
win=$(python3 -I /home/dev/harness/xsession.py find "$TITLE" 5 | cut -d" " -f1)
step "close it as a window manager does" -- python3 -I /home/dev/harness/xsession.py close "$win"
for i in $(seq 300); do kill -0 "$app" 2>/dev/null || break; sleep 0.1; done
if kill -0 "$app" 2>/dev/null; then kill "$app"; echo "FAILED: still running after the close" | tee -a "$log"; exit 1; fi
wait "$app"; status=$?
printf "\n### the smoke run (status %s)\n" "$status" >> "$log"
cat smoke.out >> "$log"
kill "$xvfb" 2>/dev/null
[[ $status == 0 ]] || { echo "FAILED: the program ended with status $status" | tee -a "$log"; exit 1; }

mkdir -p "$NAME/source"
cp *.bot "$NAME/source/"
glibc=$(LC_ALL=C readelf -V "$NAME/$NAME" "$NAME/lib/libraven.so.0" | grep -o "GLIBC_[0-9.]*" | sort -uV | tail -1)
cat > "$NAME/README.txt" <<EOF
$NAME -- a Raven desktop application written in Botlish, built by the
clean room of RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md from source/ with the
single-file compiler and $(basename /home/dev/inputs/raven-*.botpkg).

Run it from anywhere (it finds lib/libraven.so.0 beside itself):

    ./$NAME

It needs Linux x86-64 with the GNU C library (it requires $glibc), libX11
(Ubuntu: libx11-6), an X11 display, the Vulkan loader (libvulkan1) and a
Vulkan driver: the GPU vendor driver, or the Mesa software driver (mesa-vulkan-drivers).
Without a display, or with no usable Vulkan, it says why and exits.
EOF
tar czf "/home/dev/$NAME-linux-x86_64.tar.gz" "$NAME"
echo "built $NAME-linux-x86_64.tar.gz" | tee -a "$log"
