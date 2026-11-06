#!/usr/bin/env bash
# cleanroom.sh -- the HTTP clean room of HTTP-CLIENT-PACKAGE-MILESTONE-1.md,
# section 14.
#
#   cleanroom.sh image
#       build the image botlish-http-cleanroom (Dockerfile beside this
#       script: Ubuntu 24.04 with gcc, g++, libc6-dev and ca-certificates
#       only), through $HTTPS_PROXY and its CA ($BOTLISH_PROXY_CA) when set
#   cleanroom.sh run COMPILER REPOSITORY OUT
#       starts the peers on this host -- tests/http/server.py (Python's
#       asyncio, ssl and h2), with the test PKI of tests/http/pki.sh: one
#       certified by the test CA, one by a CA nobody trusts, and a port where
#       nothing listens -- then a fresh container from the image, on the
#       host's network so that it reaches them and the public Internet,
#       with nothing mounted: the single-file compiler COMPILER, the .botpkg
#       artifacts of REPOSITORY (repository.sh), the consumer's source
#       (app/main.bot) and the test CA's certificate (the consumer's own
#       trust anchor, a file it reads) copied in. inside.sh runs as the user
#       dev; its transcript and checks are copied out to OUT. Exit status 0
#       when every check passed.
#
# Environment:
#   BOTLISH_CLEANROOM_PUBLIC_URL   workload A's URL (https://example.com/)
#   BOTLISH_CLEANROOM_SYSTEM_CA    a PEM file of certificates the network's
#       operator requires the machine to trust (a TLS-inspecting egress
#       gateway's root): installed into the container's system trust store
#       with update-ca-certificates before the consumer runs, and recorded
#       in the transcript. The http package trusts the system's store and
#       the program's own anchors; it has no other trust input.
#
# Nothing of the repository but the files named above reaches the container:
# no volume, no bind mount, and the image holds no Botlish.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
image=botlish-http-cleanroom

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
    name=botlish-http-cleanroom-$$
    stage=$(mktemp -d)
    pids=()
    cleanup() {
      for p in "${pids[@]}"; do kill "$p" 2>/dev/null || true; done
      docker rm -f "$name" >/dev/null 2>&1 || true
      rm -rf "$stage"
    }
    trap cleanup EXIT
    sh "$root/tests/http/pki.sh" "$stage/pki" >/dev/null 2>&1
    # A peer: its port, once it says "ready PORT".
    peer() {
      local log=$stage/peer-$1.log
      shift
      python3 -I "$root/tests/http/server.py" --port 0 "$@" > "$log" 2>/dev/null &
      pids+=($!)
      for _ in $(seq 100); do
        if grep -q '^ready ' "$log"; then sed -n 's/^ready \([0-9]*\)$/\1/p' "$log" | head -1; return; fi
        sleep 0.1
      done
      echo "cleanroom.sh: a peer did not start" >&2
      exit 1
    }
    good=$(peer good --tls "$stage/pki/good.pem" "$stage/pki/good.key")
    untrusted=$(peer untrusted --tls "$stage/pki/untrusted.pem" "$stage/pki/untrusted.key")
    closed=$(python3 -I -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')
    mkdir -p "$stage/inputs/repo" "$stage/inputs/src" "$stage/harness"
    cp "$compiler" "$stage/inputs/botlish"
    cp "$repository"/*.botpkg "$stage/inputs/repo/"
    cp "$repository"/*.provenance.json "$stage/inputs/repo/" 2>/dev/null || true
    cp "$here/app/main.bot" "$stage/inputs/src/"
    cp "$stage/pki/ca.pem" "$stage/inputs/test-ca.pem"
    cp "$here/inside.sh" "$stage/harness/"
    cat > "$stage/inputs/peers.env" <<ENV
BASE=https://localhost:$good
UNTRUSTED=https://localhost:$untrusted
CLOSED=http://127.0.0.1:$closed
PUBLIC=${BOTLISH_CLEANROOM_PUBLIC_URL:-https://example.com/}
ENV
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker create --name "$name" --network host --init "$image" sleep infinity >/dev/null
    docker cp "$stage/inputs" "$name:/home/dev/inputs"
    docker cp "$stage/harness" "$name:/home/dev/harness"
    docker start "$name" >/dev/null
    docker exec -u root "$name" chown -R dev:dev /home/dev
    if [[ -n ${BOTLISH_CLEANROOM_SYSTEM_CA:-} ]]; then
      docker cp "$BOTLISH_CLEANROOM_SYSTEM_CA" "$name:/usr/local/share/ca-certificates/operator.crt"
      docker exec -u root "$name" sh -c 'update-ca-certificates >/dev/null 2>&1; echo "operator CA: $(grep -c BEGIN /usr/local/share/ca-certificates/operator.crt) certificate(s) added to the system store" > /home/dev/inputs/system-ca.txt; chown dev:dev /home/dev/inputs/system-ca.txt'
    fi
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
