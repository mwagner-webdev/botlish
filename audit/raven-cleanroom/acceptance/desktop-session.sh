#!/usr/bin/env bash
# desktop-session.sh -- window.bot on a real X11 window, driven from outside
# (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, "Real desktop execution").
#
#   desktop-session.sh OUT COMMAND...
#
# Starts a virtual X server (Xvfb, its own display), runs COMMAND (which
# runs window.bot: `botlish -backend cranelift window.bot`, or an emitted
# executable) with DISPLAY set, and then acts only through the X server, as
# a user would: finds the window by its title, reads its pixels, clicks the
# controls window.bot reported (XTest), and closes the window as a window
# manager does (WM_DELETE_WINDOW). What the program printed, the pixels and
# a verdict line per check go to OUT; the last line is "PASS" or "FAIL".
#
# Needs python3 (tools/xsession.py: ctypes over libX11 and libXtst), Xvfb
# and, for the renderer, a Vulkan loader and driver -- no compiler, no
# Botlish source.
set -uo pipefail

out=$1
shift
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
xs="$here/xsession.py"
[[ -f $xs ]] || xs="$here/../tools/xsession.py"
mkdir -p "$out"
status=0
check() { # NAME CONDITION-RESULT(0/1) DETAIL
  if [[ $2 == 0 ]]; then echo "ok    $1 $3" | tee -a "$out/verdict"; else echo "FAIL  $1 $3" | tee -a "$out/verdict"; status=1; fi
}
: > "$out/verdict"

exec 9< <(exec Xvfb -displayfd 1 -screen 0 800x600x24 -nolisten tcp 2>"$out/xvfb.err")
xvfb_pid=$!
read -r -t 20 number <&9 || { echo "FAIL  xvfb no display" | tee -a "$out/verdict"; echo FAIL; exit 1; }
export DISPLAY=":$number"

"$@" >"$out/app.out" 2>"$out/app.err" &
app=$!

# Waits up to SECONDS for a line of app.out matching PATTERN.
await() {
  local pattern=$1 seconds=$2 i
  for ((i = 0; i < seconds * 10; i++)); do
    grep -qE "$pattern" "$out/app.out" 2>/dev/null && return 0
    kill -0 "$app" 2>/dev/null || { grep -qE "$pattern" "$out/app.out" 2>/dev/null; return $?; }
    sleep 0.1
  done
  return 1
}

if ! await '^ready$' 300; then
  check ready 1 "(the program did not report ready: $(tail -3 "$out/app.err" "$out/app.out" | tr '\n' ' '))"
  kill "$app" 2>/dev/null; kill "$xvfb_pid" 2>/dev/null
  echo FAIL; exit 1
fi
check ready 0 "$(grep -E '^frame ' "$out/app.out")"
# The shared libraries the program's processes mapped (the loader's choice,
# read from /proc while the window is open).
{
  for p in "$app" $(pgrep -P "$app"); do cat "/proc/$p/maps" 2>/dev/null; done
} | awk '$6 ~ /\.so/ { print $6 }' | sort -u > "$out/mapped"

read -r win wx wy ww wh < <(python3 -I "$xs" find "Raven clean room" 20) || true
check window "$([[ -n ${win:-} ]]; echo $?)" "id ${win:-none} at ${wx:-?},${wy:-?} size ${ww:-?}x${wh:-?}"
[[ -n ${win:-} ]] || { kill "$app" "$xvfb_pid" 2>/dev/null; echo FAIL; exit 1; }

centre() { # NAME -> "X Y" of the widget's middle, from window.bot's report
  awk -v n="$1" '$1 == "widget" && $2 == n { printf "%d %d\n", $3 + $5 / 2, $4 + $6 / 2 }' "$out/app.out"
}

read -r w h colors < <(python3 -I "$xs" snap "$win" "$out/0-start.ppm")
check rendered "$([[ ${colors:-0} -gt 8 ]]; echo $?)" "the window's pixels hold $colors colors (${w}x${h})"

step=0
press() { # WIDGET EXPECTED-STATE-LINE
  step=$((step + 1))
  python3 -I "$xs" click "$win" $(centre "$1")
  if await "^state $2\$" 30; then
    python3 -I "$xs" snap "$win" "$out/$step-$1.ppm" >/dev/null
    check "click-$1" 0 "-> state $2"
  else
    check "click-$1" 1 "expected state $2; the program printed: $(tail -2 "$out/app.out" | tr '\n' '|')"
  fi
}

press add '1 false 1 clicks true'
changed=$(python3 -I "$xs" diff "$out/0-start.ppm" "$out/1-add.ppm")
check pixels-changed "$([[ $changed -gt 0 ]]; echo $?)" "$changed pixels differ after the first click"
press shout '1 true 1 clicks! true'
press add '2 true 2 clicks! true'
press reset '0 true 0 clicks! true'

python3 -I "$xs" close "$win"
for ((i = 0; i < 300; i++)); do kill -0 "$app" 2>/dev/null || break; sleep 0.1; done
if kill -0 "$app" 2>/dev/null; then
  check closed 1 "(still running 30 s after the close request)"
  kill "$app"
else
  wait "$app"; code=$?
  check closed "$([[ $code == 0 ]] && grep -q '^closed 0$' "$out/app.out"; echo $?)" "exit status $code, $(grep -E '^closed' "$out/app.out")"
fi
kill "$xvfb_pid" 2>/dev/null
if [[ $status == 0 ]]; then echo PASS | tee -a "$out/verdict"; else echo FAIL | tee -a "$out/verdict"; fi
exit $status
