#!/usr/bin/env bash
# cleanroom.sh -- the clean-room consumer of SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md.
#
#   cleanroom.sh image
#       build the image botlish-shared-cleanroom (Dockerfile beside this
#       script: Ubuntu 24.04, gcc and libc6-dev only), through $HTTPS_PROXY
#       and its CA ($BOTLISH_PROXY_CA) when set
#   cleanroom.sh run COMPILER REPOSITORY OUT
#       a fresh container from the image, with no network and nothing
#       mounted: the single-file compiler COMPILER, the .botpkg artifacts of
#       the directory REPOSITORY (the driver event_loop_linux's release, the
#       libraries beats and probes, and the conflicting future with the
#       driver release it locks) and the consumer's source
#       (examples/event-loop/shared/app/main.bot) copied in; inside.sh runs
#       as the user dev, and its transcript and checks are copied out to OUT.
#       Exit status 0 when every check passed.
#
# Nothing of the repository but the files named above reaches a container:
# no volume, no bind mount, no network, and the image holds no Botlish.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
image=botlish-shared-cleanroom

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
    name=botlish-shared-cleanroom-$$
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker create --name "$name" --network none --init "$image" sleep infinity >/dev/null
    stage=$(mktemp -d)
    trap 'rm -rf "$stage"; docker rm -f "$name" >/dev/null 2>&1 || true' EXIT
    mkdir -p "$stage/inputs/repo" "$stage/inputs/src" "$stage/harness"
    cp "$compiler" "$stage/inputs/botlish"
    cp "$repository"/*.botpkg "$stage/inputs/repo/"
    cp "$root/examples/event-loop/shared/app/main.bot" "$stage/inputs/src/"
    cp "$here/inside.sh" "$stage/harness/"
    docker cp "$stage/inputs" "$name:/home/dev/inputs"
    docker cp "$stage/harness" "$name:/home/dev/harness"
    docker start "$name" >/dev/null
    docker exec -u root "$name" chown -R dev:dev /home/dev
    status=0
    docker exec -u dev "$name" bash /home/dev/harness/inside.sh || status=$?
    mkdir -p "$out"
    docker cp "$name:/home/dev/out/." "$out/"
    exit $status
    ;;
  *)
    sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//;$d' >&2
    exit 2
    ;;
esac
