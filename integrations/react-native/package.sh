#!/usr/bin/env bash
# package.sh -- the author's side of the botlish_react_native tool package
# (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md, "The external tool
# package"): compiles the `react-native` tool for linux-x86_64, its templates
# embedded, stages the package and packs it, as its author would.
#
#   integrations/react-native/package.sh OUT BOTLISH...
#
# BOTLISH... is the compiler command that packs it (`tclsh9.0 main.tcl` in a
# checkout, or the single-file compiler: `botlish package pack` either way).
# Writes OUT/repo/botlish_react_native-VERSION.botpkg and OUT/stage (the
# package directory). The tool is linked statically (it needs no shared
# library of the host) and stripped: no host path is in what ships. Nothing
# is downloaded. CC (default cc) is the C compiler.
set -euo pipefail
if [[ $# -lt 2 ]]; then
    echo "usage: package.sh OUT BOTLISH..." >&2
    exit 2
fi
out=$(realpath -m "$1")
shift
botlish=("$@")
here=$(cd "$(dirname "$0")" && pwd)
cc=${CC:-cc}
stage="$out/stage/botlish_react_native"
build="$out/build"
rm -rf "$stage" "$build"
mkdir -p "$stage/tools/linux-x86_64" "$build" "$out/repo"
"$cc" -std=c99 -O2 -Wall -Wextra -Werror -o "$build/embed" "$here/src/embed.c"
# The templates in a fixed order, by name relative to the package (no host
# path enters the program).
(cd "$here/templates" && "$build/embed" "$build/templates.h" $(LC_ALL=C ls *.in))
"$cc" -std=c99 -O2 -Wall -Wextra -Werror -static -ffile-prefix-map="$here"=. -I"$build" -I"$here/src" \
    -o "$stage/tools/linux-x86_64/react-native" "$here/src/main.c"
strip "$stage/tools/linux-x86_64/react-native" 2>/dev/null || true
cp "$here/package/botlish.json" "$here/README.md" "$stage/"
# The tool's source travels with it, for whoever audits what they run.
mkdir -p "$stage/source/src" "$stage/source/templates"
cp "$here"/src/*.c "$here"/src/*.h "$stage/source/src/"
cp "$here"/templates/*.in "$stage/source/templates/"
"${botlish[@]}" package pack "$stage" -out "$out/repo" -force
