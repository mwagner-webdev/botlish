#!/bin/sh
# run.sh -- assemble, build and drive the census probes
# (HTTP-SSE-SERVER-CENSUS-MILESTONE-1.md). Each probe is assembled as an
# application directory in a temporary directory (its files, the shared
# probes/rawnet.bot and, for P2, the Linux driver package installed by
# tools/event-loop-linux.tcl), built with main.tcl -emit-native-executable
# and driven by its independent client in drivers/. Nothing is left behind.
#
#   sh audit/http-sse-server-census/tools/run.sh [p1|p2|p2-gc|p3|p4|protocol|bytes|alloc|all]
#
# Linux x86-64 with tclsh9.0, the native backend built (cargo build
# --release --manifest-path native/Cargo.toml), cc, ar, curl and python3.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
census=$(dirname "$here")
root=$(cd "$census/../.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export LANG=C.utf8 LC_ALL=C.utf8

app() {
    d="$work/$1"
    shift
    mkdir -p "$d"
    cp "$census/probes/rawnet.bot" "$d/"
    for f in "$@"; do
        cp "$census/probes/$f" "$d/"
    done
}

build() {
    (cd "$root" && tclsh9.0 main.tcl -warnings off -emit-native-executable "$work/$1/$2.bot" >/dev/null)
}

p1() {
    app p1 p1/listen.bot
    build p1 listen
    python3 -I "$census/drivers/p1_driver.py" "$work/p1/listen" 18081
}

p2_build() {
    if [ ! -x "$work/p2/server" ]; then
        app p2 p2/server.bot p2/srv.bot p2/http1.bot
        tclsh9.0 "$root/tools/event-loop-linux.tcl" install "$work/p2" >/dev/null
        build p2 server
    fi
}

p2() {
    p2_build
    python3 -I "$census/drivers/p2_driver.py" "$work/p2/server"
}

p2_gc() {
    p2_build
    BOTLISH_NATIVE_GC_STRESS=1 python3 -I "$census/drivers/p2_driver.py" "$work/p2/server"
}

p3() {
    app p3 p3/signal.bot
    build p3 signal
    python3 -I "$census/drivers/p3_driver.py" "$work/p3/signal"
}

p4() {
    app p4 p4/ipv6.bot
    build p4 ipv6
    "$work/p4/ipv6" 18301 &
    sleep 0.5
    curl -sS -6 --max-time 3 'http://[::1]:18301/' || echo "curl exit $?"
    wait
}

protocol() {
    for b in interp compile cranelift cranelift-generic; do
        echo "== $b"
        (cd "$root" && tclsh9.0 main.tcl -warnings off -backend "$b" "$census/probes/p2/protocol.bot" | grep 'value:')
    done
}

bytes() {
    for b in interp compile cranelift cranelift-generic; do
        echo "== $b"
        (cd "$root" && tclsh9.0 main.tcl -warnings off -backend "$b" "$census/probes/bytes_list.bot" | grep 'value:')
    done
}

alloc() {
    tclsh9.0 "$census/tools/alloc.tcl"
}

what=${1:-all}
case "$what" in
    all) p1; p2; p3; p4; protocol; bytes; alloc ;;
    p2-gc) p2_gc ;;
    p1|p2|p3|p4|protocol|bytes|alloc) "$what" ;;
    *) echo "usage: run.sh [p1|p2|p2-gc|p3|p4|protocol|bytes|alloc|all]" >&2; exit 2 ;;
esac
