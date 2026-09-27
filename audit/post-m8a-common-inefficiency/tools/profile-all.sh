#!/usr/bin/env bash
# profile-all.sh -- callgrind profiles of the four canonical benchmarks
# (bench/*.ir) under the census configurations
# (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md). Observation only.
#
#   bash audit/post-m8a-common-inefficiency/tools/profile-all.sh AUDIT-BINARY OUTDIR
#
# RUNS per program are chosen so every profile collects >= ~1M
# instructions; every figure profile.sh reports is divided back to one run.
set -eu
bin=${1:?usage}; out=${2:?usage}
root=$(cd "$(dirname "$0")/../../.." && pwd)
tool="$root/audit/post-m8a-common-inefficiency/tools/profile.sh"
declare -A runs=([fib]=20 [loop-count]=2000 [sum-refined]=2000 [refined-checks]=20)
for prog in fib loop-count sum-refined refined-checks; do
    bash "$tool" "$bin" "$root/bench/$prog.ir" "${runs[$prog]}" "$out/$prog/cranelift"
    bash "$tool" "$bin" "$root/bench/$prog.ir" "${runs[$prog]}" "$out/$prog/vc-off" -virtual-construction-opt 0
    if [ "$prog" != refined-checks ]; then
        # refined-checks is not lowerable unspecialized (UriQueryValue? has
        # no native implementation; only specialization decides it).
        bash "$tool" "$bin" "$root/bench/$prog.ir" "${runs[$prog]}" "$out/$prog/generic" -specialize 0
    fi
done
