#!/usr/bin/env bash
# cleanroom.sh -- the clean room of RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md.
#
#   cleanroom.sh image
#       build the image botlish-raven-cleanroom (audit/raven-cleanroom/
#       Dockerfile: Ubuntu 24.04 and operating-system facilities only),
#       through $HTTPS_PROXY and its CA ($BOTLISH_PROXY_CA) when set
#   cleanroom.sh run COMPILER BOTPKG OUT
#       a fresh container from the image, with no network and nothing
#       mounted: the single-file compiler COMPILER and the release BOTPKG
#       copied in as /home/dev/inputs/, the harness (acceptance/: inside.sh,
#       window.bot, desktop-session.sh, and tools/xsession.py) as
#       /home/dev/harness/; acceptance/inside.sh runs as the user dev, and
#       its transcript, checks and window sessions are copied out to OUT.
#       Exit status 0 when every check passed.
#   cleanroom.sh start COMPILER BOTPKG NAME
#       the same container, left running with nothing executed (for a
#       person or an agent to work in: docker exec -u dev NAME ...); the
#       harness is not copied in
#
# Nothing of the repository but the files named above reaches a container:
# no volume, no bind mount, no network, and the image holds no Botlish.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
image=botlish-raven-cleanroom

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
  run | start)
    [[ $# == 4 ]] || { echo "usage: cleanroom.sh $1 COMPILER BOTPKG ${1/run/OUT}" >&2; exit 2; }
    compiler=$(realpath "$2")
    botpkg=$(realpath "$3")
    if [[ $1 == run ]]; then
      out=$(realpath -m "$4")
      name=botlish-raven-cleanroom-$$
    else
      name=$4
    fi
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker create --name "$name" --network none --init "$image" sleep infinity >/dev/null
    stage=$(mktemp -d)
    trap 'rm -rf "$stage"' EXIT
    mkdir -p "$stage/inputs" "$stage/harness"
    cp "$compiler" "$stage/inputs/botlish"
    cp "$botpkg" "$stage/inputs/"
    if [[ $1 == run ]]; then
      cp "$here/acceptance/inside.sh" "$here/acceptance/window.bot" "$here/acceptance/desktop-session.sh" \
        "$here/tools/xsession.py" "$stage/harness/"
    fi
    docker cp "$stage/inputs" "$name:/home/dev/inputs"
    [[ $1 == run ]] && docker cp "$stage/harness" "$name:/home/dev/harness"
    docker start "$name" >/dev/null
    docker exec -u root "$name" chown -R dev:dev /home/dev
    if [[ $1 == start ]]; then
      echo "$name"
      exit 0
    fi
    status=0
    docker exec -u dev "$name" bash /home/dev/harness/inside.sh || status=$?
    mkdir -p "$out"
    docker cp "$name:/home/dev/out/." "$out/"
    docker rm -f "$name" >/dev/null
    exit $status
    ;;
  *)
    sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//;$d' >&2
    exit 2
    ;;
esac
