#!/usr/bin/env bash
# app.sh WORK LIBRARY-DIR PACKAGE-OPTION... -- HISTORY: the census's step,
# run by .github/workflows/react-native-probe.yml from the census's tree
# (its CENSUS_REF); this tree's rnpackage.tcl reads the compiler's library
# manifest instead (-manifest, NATIVE-LIBRARY-MILESTONE-1.md). An ordinary React Native 0.88
# app, `WORK/probe app` (a path with a space), with the generated package
# installed from its npm tarball and audit/react-native/app/App.tsx as its
# screen (REACT-NATIVE-TARGET-CENSUS.md). LIBRARY-DIR holds libmode.tcl's
# header and export manifest; the options go to rnpackage.tcl
# (-android-lib ABI LIB, -ios-lib LIB).
set -euo pipefail
work=$1
lib=$2
shift 2
root=$(cd "$(dirname "$0")/../../.." && pwd)
app="$work/probe app"
rm -rf "$app" "$work/package"
npx --yes @react-native-community/cli@20.2.0 init BotlishProbeApp --version 0.88.0 \
  --directory "$app" --pm npm --skip-git-init --install-pods false --package-name org.botlish.probeapp
tclsh9.0 "$root/audit/react-native/tools/rnpackage.tcl" -o "$work/package" \
  -exports "$lib/rnprobe_botlish.exports" -header "$lib/rnprobe_botlish.h" \
  -name react-native-botlish-probe "$@" -codegen-project "$app"
(cd "$work/package" && npm pack --pack-destination "$work")
(cd "$app" && npm install "$work/react-native-botlish-probe-0.1.0.tgz")
cp "$root/audit/react-native/app/App.tsx" "$app/App.tsx"
(cd "$app" && npx react-native config > "$work/react-native-config.json")
