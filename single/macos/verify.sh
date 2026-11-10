#!/usr/bin/env bash
# single/macos/verify.sh -- checks a built Botlish.app
# (MACOS-AARCH64-MILESTONE-9.md, "Verification").
#
#   single/macos/verify.sh [--checkout ROOT] [--no-developer-tools]
#                          [--signature adhoc|developer-id --team TEAM] APP
#
# Checks APP as single/macos/build.sh makes it, without running it:
#
#   layout        the bundle's files and nothing else: Contents/{Info.plist,
#                 MacOS/{botlish, botlish-native}, Frameworks/Tcl.framework,
#                 Resources/{botlish.zip, libbotlish_runtime.a},
#                 _CodeSignature}; the framework's standard links
#                 (Versions/Current, Tcl, Resources) as symbolic links; no
#                 headers or other development files in it
#   dependencies  every Mach-O is arm64; the launcher loads Tcl weakly as
#                 @rpath/Tcl.framework/Versions/9.0/Tcl through its one
#                 LC_RPATH, @executable_path/../Frameworks; the framework's
#                 install name is that @rpath path; every other library any
#                 of them loads is the system's (/usr/lib, /System/Library);
#                 no load path is absolute outside the system (a build
#                 directory, /Library/Frameworks, Homebrew)
#   signature     valid: codesign --verify --deep --strict of the
#                 application and --strict of each nested code (the
#                 framework's version, the driver), each with its own
#                 identifier, none merely linker-signed, the resources
#                 sealed, each with the hardened runtime and no entitlement
#                 (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md); ad hoc (the
#                 default, --signature adhoc), or --signature developer-id:
#                 each a Developer ID Application signature of team TEAM
#                 (Developer ID Certification Authority, Apple Root CA) with
#                 a secure timestamp
#   no JIT        the driver holds no JIT: no symbol of Cranelift's JIT
#                 crate, and no Mach-O of the bundle imports the functions
#                 that write JIT memory (pthread_jit_write_protect_np) or
#                 flush code made at run time (sys_icache_invalidate)
#   archive       Resources/botlish.zip holds the compiler (main.tcl,
#                 botlish/...), no native executable and no Tcl library,
#                 and its native-bin/ID names the bundled driver and runtime
#                 archive (CRC-32 and size); with --checkout ROOT, the
#                 compiler's directories hold exactly ROOT's files (the
#                 standard library, Compilerpedia, the compiler's sources)
#
# The dependency checks need Apple's developer tools (otool, lipo);
# --no-developer-tools skips them, saying so, on a host without them.
# Prints a line per group; a failure is "FAIL[GROUP]: ..." and exit 1.
set -euo pipefail

checkout=""
tools=1
signature=adhoc
team=""
while [[ $# -gt 1 ]]; do
  case $1 in
    --checkout) checkout=$2; shift 2 ;;
    --no-developer-tools) tools=0; shift ;;
    --signature) signature=$2; shift 2 ;;
    --team) team=$2; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ $# -eq 1 ]] || { echo "usage: single/macos/verify.sh [--checkout ROOT] [--no-developer-tools] [--signature adhoc|developer-id --team TEAM] APP" >&2; exit 2; }
case $signature in
  adhoc) ;;
  developer-id) [[ $team =~ ^[A-Z0-9]{10}$ ]] || { echo "single/macos/verify.sh: --signature developer-id needs --team TEAM (a 10-character Team ID)" >&2; exit 2; } ;;
  *) echo "single/macos/verify.sh: unknown signature kind $signature (adhoc, developer-id)" >&2; exit 2 ;;
esac
app=$(cd "$1" && pwd)
c="$app/Contents"
identifier=io.github.mwagner-webdev.botlish
v=9.0
fw="$c/Frameworks/Tcl.framework"
fail() { echo "FAIL[$1]: $2" >&2; exit 1; }
listing() { (cd "$1" && ls -A | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//'); }

# --- layout -------------------------------------------------------------------
for path in Info.plist MacOS/botlish MacOS/botlish-native Resources/botlish.zip Resources/libbotlish_runtime.a \
    "Frameworks/Tcl.framework/Versions/$v/Tcl" "Frameworks/Tcl.framework/Versions/$v/Resources/Info.plist" \
    "Frameworks/Tcl.framework/Versions/$v/Resources/Scripts/init.tcl" _CodeSignature/CodeResources; do
  [[ -f $c/$path && ! -L $c/$path ]] || fail layout "no file Contents/$path"
done
[[ $(listing "$c") == "Frameworks Info.plist MacOS Resources _CodeSignature" ]] || fail layout "Contents holds $(listing "$c")"
[[ $(listing "$c/MacOS") == "botlish botlish-native" ]] || fail layout "Contents/MacOS holds $(listing "$c/MacOS")"
[[ $(listing "$c/Resources") == "botlish.zip libbotlish_runtime.a" ]] || fail layout "Contents/Resources holds $(listing "$c/Resources")"
[[ $(listing "$c/Frameworks") == "Tcl.framework" ]] || fail layout "Contents/Frameworks holds $(listing "$c/Frameworks")"
[[ $(listing "$fw") == "Resources Tcl Versions" ]] || fail layout "Tcl.framework holds $(listing "$fw")"
[[ $(listing "$fw/Versions") == "$v Current" ]] || fail layout "Tcl.framework/Versions holds $(listing "$fw/Versions")"
[[ $(listing "$fw/Versions/$v") == "Resources Tcl _CodeSignature" ]] || fail layout "Tcl.framework/Versions/$v holds $(listing "$fw/Versions/$v")"
for link in "Versions/Current=$v" "Tcl=Versions/Current/Tcl" "Resources=Versions/Current/Resources"; do
  name=${link%%=*}
  [[ -L $fw/$name && $(readlink "$fw/$name") == "${link#*=}" ]] ||
    fail layout "Tcl.framework/$name is not the symbolic link to ${link#*=}"
done
for name in botlish botlish-native; do
  [[ -x $c/MacOS/$name ]] || fail layout "Contents/MacOS/$name is not executable"
done
[[ $(plutil -extract CFBundleExecutable raw "$c/Info.plist") == botlish ]] || fail layout "Info.plist's CFBundleExecutable is not botlish"
[[ $(plutil -extract CFBundleIdentifier raw "$c/Info.plist") == "$identifier" ]] || fail layout "Info.plist's CFBundleIdentifier is not $identifier"
echo "   layout: ok"

# --- dependencies -------------------------------------------------------------
if (( tools )); then
  for path in MacOS/botlish MacOS/botlish-native "Frameworks/Tcl.framework/Versions/$v/Tcl" Resources/libbotlish_runtime.a; do
    archs=$(lipo -archs "$c/$path" 2>/dev/null || true)
    if [[ $path == *.a ]]; then archs=$(lipo -info "$c/$path" 2>/dev/null | sed -n 's/.*architecture: //p'); fi
    [[ $archs == arm64 ]] || fail dependencies "Contents/$path is for '$archs', not arm64"
  done
  id=$(otool -D "$fw/Versions/$v/Tcl" | sed -n 2p)
  [[ $id == "@rpath/Tcl.framework/Versions/$v/Tcl" ]] || fail dependencies "the framework's install name is $id"
  # LC_LOAD_DYLIB, LC_LOAD_WEAK_DYLIB and LC_RPATH of FILE, as "COMMAND PATH".
  loads() { otool -l "$1" | awk '/^ *cmd /{cmd=$2} /^ *(name|path) /{if (cmd ~ /^LC_(LOAD|LOAD_WEAK|REEXPORT|LAZY_LOAD)_DYLIB$|^LC_RPATH$/) print cmd, $2}'; }
  launcher=$(loads "$c/MacOS/botlish")
  grep -qx "LC_LOAD_WEAK_DYLIB @rpath/Tcl.framework/Versions/$v/Tcl" <<<"$launcher" ||
    fail dependencies "the launcher does not load @rpath/Tcl.framework/Versions/$v/Tcl weakly: $(tr '\n' ';' <<<"$launcher")"
  [[ $(grep '^LC_RPATH ' <<<"$launcher") == "LC_RPATH @executable_path/../Frameworks" ]] ||
    fail dependencies "the launcher's LC_RPATH is not exactly @executable_path/../Frameworks: $(grep '^LC_RPATH ' <<<"$launcher" | tr '\n' ';')"
  for path in MacOS/botlish MacOS/botlish-native "Frameworks/Tcl.framework/Versions/$v/Tcl"; do
    while read -r cmd load; do
      [[ -z $cmd ]] && continue
      case $cmd:$load in
        LC_LOAD_WEAK_DYLIB:@rpath/Tcl.framework/Versions/$v/Tcl) [[ $path == MacOS/botlish ]] || fail dependencies "Contents/$path loads Tcl" ;;
        LC_RPATH:@executable_path/../Frameworks) [[ $path == MacOS/botlish ]] || fail dependencies "Contents/$path has LC_RPATH $load" ;;
        LC_LOAD_DYLIB:/usr/lib/*|LC_LOAD_DYLIB:/System/Library/*) ;;
        *) fail dependencies "Contents/$path: $cmd $load (not the system's, not the bundle's)" ;;
      esac
    done <<<"$(loads "$c/$path")"
  done
  # (awk reads to the end, printing the first minos: an awk that exited there
  # would leave otool writing into a closed pipe, which pipefail makes this
  # assignment's failure.)
  minos=$(for path in MacOS/botlish MacOS/botlish-native "Frameworks/Tcl.framework/Versions/$v/Tcl"; do
    otool -l "$c/$path" | awk '/LC_BUILD_VERSION/{b=1} b && /minos/ && !m {print $2; m=1}'
  done | sort -u | tr '\n' ' ')
  echo "   dependencies: ok (arm64; deployment target $minos)"
else
  echo "   dependencies: SKIPPED (--no-developer-tools: otool and lipo are the developer tools')"
fi

# --- signature ----------------------------------------------------------------
codesign --verify --deep --strict --verbose=2 "$app" >"${TMPDIR:-/tmp}/botlish-verify.$$" 2>&1 ||
  { cat "${TMPDIR:-/tmp}/botlish-verify.$$" >&2; rm -f "${TMPDIR:-/tmp}/botlish-verify.$$"; fail signature "codesign --verify --deep --strict rejects the application"; }
rm -f "${TMPDIR:-/tmp}/botlish-verify.$$"
signed() { # PATH IDENTIFIER [sealed]
  local details entitlements
  codesign --verify --strict "$1" 2>/dev/null || fail signature "${1#$app/} does not verify"
  details=$(codesign -dvvv "$1" 2>&1)
  if [[ $signature == adhoc ]]; then
    grep -qx 'Signature=adhoc' <<<"$details" || fail signature "${1#$app/} is not signed ad hoc: $(tr '\n' ';' <<<"$details")"
  else
    if grep -qx 'Signature=adhoc' <<<"$details"; then fail signature "${1#$app/} is signed ad hoc, not with the Developer ID"; fi
    [[ $(grep '^Authority=' <<<"$details" | sed 's/^Authority=//' | tr '\n' '|') == "Developer ID Application: "*"($team)|Developer ID Certification Authority|Apple Root CA|" ]] ||
      fail signature "${1#$app/}'s authority chain is not team $team's Developer ID Application, Developer ID Certification Authority, Apple Root CA: $(grep '^Authority=' <<<"$details" | tr '\n' ';')"
    grep -qx "TeamIdentifier=$team" <<<"$details" || fail signature "${1#$app/}'s team is not $team: $(grep '^TeamIdentifier=' <<<"$details")"
    grep -q '^Timestamp=' <<<"$details" || fail signature "${1#$app/} has no secure timestamp"
  fi
  grep -qx "Identifier=$2" <<<"$details" || fail signature "${1#$app/}'s identifier is not $2: $(grep '^Identifier=' <<<"$details")"
  if grep -q '^CodeDirectory.*flags=.*linker-signed' <<<"$details"; then fail signature "${1#$app/} is only linker-signed"; fi
  grep -q '^CodeDirectory.*flags=0x[0-9a-f]*(.*runtime.*)' <<<"$details" ||
    fail signature "${1#$app/} has no hardened runtime: $(grep '^CodeDirectory' <<<"$details")"
  entitlements=$(codesign -d --entitlements - --xml "$1" 2>/dev/null | tr -d '\0' || true)
  if grep -q '<key>' <<<"$entitlements"; then fail signature "${1#$app/} has entitlements (none is needed): $(grep -o '<key>[^<]*</key>' <<<"$entitlements" | tr '\n' ' ')"; fi
  if [[ ${3:-} == sealed ]]; then grep -q '^Sealed Resources version=2' <<<"$details" || fail signature "${1#$app/} has no sealed resources"; fi
}
signed "$fw/Versions/$v" com.tcltk.tcllibrary sealed
signed "$c/MacOS/botlish-native" "$identifier.native"
signed "$app" "$identifier" sealed
if [[ $signature == adhoc ]]; then
  echo "   signature: ok (ad hoc, hardened runtime, no entitlement; application, framework and driver verify strictly)"
else
  echo "   signature: ok (Developer ID of team $team, secure timestamps, hardened runtime, no entitlement; application, framework and driver verify strictly)"
fi

# --- no JIT -------------------------------------------------------------------
if (( tools )); then
  jit_symbols=$(nm "$c/MacOS/botlish-native" 2>/dev/null | grep -c 'cranelift_jit' || true)
  [[ $jit_symbols == 0 ]] || fail "no JIT" "the driver holds $jit_symbols symbols of Cranelift's JIT crate: it was built with its JIT"
  for path in MacOS/botlish MacOS/botlish-native "Frameworks/Tcl.framework/Versions/$v/Tcl"; do
    imports=$(nm -u "$c/$path" 2>/dev/null | grep -E '_pthread_jit_write_protect_np|_sys_icache_invalidate' || true)
    [[ -z $imports ]] || fail "no JIT" "Contents/$path imports $(tr '\n' ' ' <<<"$imports")(functions of code made at run time)"
  done
  echo "   no JIT: ok (no JIT crate in the driver; no Mach-O imports JIT memory or instruction-cache functions)"
else
  echo "   no JIT: SKIPPED (--no-developer-tools: nm is the developer tools')"
fi

# --- archive ------------------------------------------------------------------
zip="$c/Resources/botlish.zip"
entries=$(unzip -Z1 "$zip" | grep -v '/$' | sort)
for entry in main.tcl botlish/main.tcl botlish/BUILD botlish/LICENSE botlish/core/core.tcl botlish/stdlib/list.bot \
    botlish/compilerpedia/compilerpedia.tcl native-bin/ID; do
  grep -qx "$entry" <<<"$entries" || fail archive "botlish.zip has no $entry"
done
if grep -qE '^(tcl_library/|native-bin/(botlish-native|botlish-aot-stub|libbotlish_runtime\.a))' <<<"$entries"; then
  fail archive "botlish.zip holds a Tcl library or a native file: $(grep -E '^(tcl_library/|native-bin/[^I])' <<<"$entries" | head -3 | tr '\n' ' ')"
fi
crc() { printf '%08x-%s' "$(cksum -o 3 <"$1" | cut -d' ' -f1)" "$(wc -c <"$1" | tr -d ' ')"; }
want="$(crc "$c/MacOS/botlish-native")-$(crc "$c/Resources/libbotlish_runtime.a")"
got=$(unzip -p "$zip" native-bin/ID | tr -d '\n')
[[ $got == "$want" ]] || fail archive "botlish.zip's native-bin/ID is $got, the bundle's files are $want"
if [[ -n $checkout ]]; then
  # The packed compiler, file for file, against the checkout single/package.tcl packs.
  for dir in core compiler hir surface service lsp stdlib compilerpedia/topics compilerpedia/generated; do
    packed=$(grep "^botlish/$dir/" <<<"$entries" | sed "s|^botlish/||")
    there=$(cd "$checkout" && find "$dir" -type f | LC_ALL=C sort)
    [[ $(LC_ALL=C sort <<<"$packed") == "$there" ]] ||
      fail archive "botlish.zip's $dir differs from $checkout/$dir: $(diff <(LC_ALL=C sort <<<"$packed") <(echo "$there") | head -5 | tr '\n' ' ')"
  done
  packed=$(grep -c '^botlish/native/[^/]*\.tcl$' <<<"$entries" || true)
  there=$(cd "$checkout/native" && ls ./*.tcl | wc -l | tr -d ' ')
  [[ $packed == "$there" ]] || fail archive "botlish.zip has $packed native/*.tcl files, $checkout/native $there"
  echo "   archive: ok ($(wc -l <<<"$entries" | tr -d ' ') files; the compiler's directories are the checkout's, file for file)"
else
  echo "   archive: ok ($(wc -l <<<"$entries" | tr -d ' ') files)"
fi
