#!/usr/bin/env bash
# author.sh -- the pinned author build environment of this repository's
# native packages (PACKAGE-MANAGER-MILESTONE-3.md, "Reproducibility").
#
#   author.sh image
#       build the image botlish-package-build from tools/package-build/
#       Dockerfile (a base image by digest, Ubuntu's archive at one
#       instant, Tcl 9 by SHA-256), through $HTTPS_PROXY and its CA
#       ($BOTLISH_PROXY_CA) when set -- the CA as a build secret, never in
#       the image
#   author.sh build OUT [NAME...]
#       a fresh container from the image, the repository's committed tree
#       (git archive HEAD) copied in at /src, an empty cache at /cache, and
#       tools/package-repository.tcl run there for NAME... (default: every
#       package); OUT receives the artifacts, their provenance records and
#       build.log. Every build starts from nothing: no cache, no earlier
#       container. The container reaches the network (the recipes fetch the
#       pinned sources and check them by commit and SHA-256).
#
# BOTLISH_AUTHOR_IMAGE, which the recipes record in each build's evidence,
# names the environment by its specification (the Dockerfile's SHA-256, the
# base image digest and the snapshot instant), never by a local image ID:
# two machines building the same Dockerfile get different image IDs (file
# times in its layers) and the same environment.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
image=botlish-package-build

spec() {
  local dockerfile base snapshot
  dockerfile=$(sha256sum "$here/Dockerfile" | cut -d' ' -f1)
  base=$(sed -n 's/^FROM \(.*\)$/\1/p' "$here/Dockerfile")
  snapshot=$(sed -n 's/^ARG SNAPSHOT=\(.*\)$/\1/p' "$here/Dockerfile")
  echo "botlish-package-build: Dockerfile sha256 $dockerfile, FROM $base, Ubuntu snapshot $snapshot"
}

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
  spec)
    spec
    ;;
  build)
    [[ $# -ge 2 ]] || { echo "usage: author.sh build OUT [NAME...]" >&2; exit 2; }
    out=$(realpath -m "$2")
    shift 2
    revision=$(git -C "$root" rev-parse HEAD)
    if [[ -n $(git -C "$root" status --porcelain --untracked-files=no) ]]; then
      echo "author.sh: the working tree has uncommitted changes; the build uses the committed tree $revision" >&2
    fi
    name=botlish-package-build-$$
    env=(-e "BOTLISH_AUTHOR_IMAGE=$(spec)" -e "BOTLISH_SOURCE_REVISION=$revision")
    if [[ -n ${HTTPS_PROXY:-} ]]; then
      env+=(-e "HTTPS_PROXY=$HTTPS_PROXY" -e "https_proxy=$HTTPS_PROXY"
            -e SSL_CERT_FILE=/tmp/proxy-ca.crt -e GIT_SSL_CAINFO=/tmp/proxy-ca.crt -e CURL_CA_BUNDLE=/tmp/proxy-ca.crt)
    fi
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker create --name "$name" --network host "${env[@]}" "$image" sleep infinity >/dev/null
    trap 'docker rm -f "$name" >/dev/null 2>&1 || true' EXIT
    git -C "$root" archive --format=tar --prefix=src/ HEAD | docker cp - "$name:/"
    if [[ -n ${HTTPS_PROXY:-} ]]; then
      ca=${BOTLISH_PROXY_CA:-${SSL_CERT_FILE:-}}
      docker cp "$ca" "$name:/tmp/proxy-ca.crt"
    fi
    docker start "$name" >/dev/null
    mkdir -p "$out"
    status=0
    docker exec -w /src "$name" bash -c 'mkdir -p /out /cache && tclsh9.0 tools/package-repository.tcl /out "$@" > /out/release.txt 2> /out/build.log' bash "$@" || status=$?
    docker cp "$name:/out/." "$out/"
    docker cp "$name:/etc/botlish-author-packages" "$out/environment-packages.txt"
    cat "$out/release.txt"
    exit $status
    ;;
  *)
    sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//;$d' >&2
    exit 2
    ;;
esac
