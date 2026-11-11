#!/usr/bin/env bash
# cleanroom.sh -- the process_linux clean room of PROCESS-LINUX-PACKAGE-
# MILESTONE-1.md ("Clean room").
#
#   cleanroom.sh image
#       build the image botlish-process-cleanroom (Dockerfile beside this
#       script: Ubuntu 24.04 with gcc and libc6-dev only), through
#       $HTTPS_PROXY and its CA ($BOTLISH_PROXY_CA) when set
#   cleanroom.sh run COMPILER REPOSITORY OUT
#       builds the deterministic helper child (tests/process/child.c) with
#       this host's C compiler, then starts a fresh container from the image
#       with no network and nothing mounted: the single-file compiler
#       COMPILER, the .botpkg artifacts of REPOSITORY (repository.sh), the
#       consumer's source (app/) and the helper are copied in. inside.sh
#       runs as the user dev; its transcript and checks are copied out to
#       OUT. Exit status 0 when every check passed.
#
# Nothing of the repository but the files named above reaches the container:
# no volume, no bind mount, and the image holds no Botlish.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
image=botlish-process-cleanroom

case ${1:-} in
  image)
    args=(--network host -t "$image")
    if [[ -n ${HTTPS_PROXY:-} ]]; then
      args+=(--build-arg "HTTPS_PROXY=$HTTPS_PROXY")
      ca=${BOTLISH_PROXY_CA:-${SSL_CERT_FILE:-}}
      [[ -n $ca ]] && args+=(--secret "id=proxy-ca,src=$ca")
    fi
    docker build "${args[@]}" "$here"
    ;;
  run)
    [[ $# == 4 ]] || { echo "usage: cleanroom.sh run COMPILER REPOSITORY OUT" >&2; exit 2; }
    compiler=$(realpath "$2")
    repository=$(realpath "$3")
    out=$(realpath -m "$4")
    name=botlish-process-cleanroom-$$
    stage=$(mktemp -d)
    trap 'docker rm -f "$name" >/dev/null 2>&1 || true; rm -rf "$stage"' EXIT
    cc -O2 -Wall -Wextra -Werror "$root/tests/process/child.c" -o "$stage/child"
    mkdir -p "$stage/inputs/src" "$stage/inputs/repo"
    cp "$compiler" "$stage/inputs/botlish"
    cp "$repository"/*.botpkg "$stage/inputs/repo/"
    cp "$repository"/*.provenance.json "$stage/inputs/repo/" 2>/dev/null || true
    cp "$here"/app/*.bot "$stage/inputs/src/"
    cp "$stage/child" "$stage/inputs/child"
    cp "$here/inside.sh" "$stage/inputs/inside.sh"
    docker create --name "$name" --network none "$image" bash /home/dev/inputs/inside.sh >/dev/null
    docker cp "$stage/inputs" "$name:/home/dev/inputs"
    docker start "$name" >/dev/null
    status=$(docker wait "$name")
    rm -rf "$out"
    mkdir -p "$out"
    docker cp "$name:/home/dev/out/." "$out/" 2>/dev/null || true
    docker logs "$name" > "$out/container.log" 2>&1 || true
    echo "cleanroom: exit status $status; transcript $out/transcript.txt"
    grep -c '^PASS' "$out/checks.txt" | sed 's/^/passed: /'
    grep '^FAIL' "$out/checks.txt" || true
    exit "$status"
    ;;
  *)
    echo "usage: cleanroom.sh image | run COMPILER REPOSITORY OUT" >&2
    exit 2
    ;;
esac
