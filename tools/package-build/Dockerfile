# The pinned author build environment of this repository's native packages
# (PACKAGE-MANAGER-MILESTONE-3.md, "Reproducibility"): where
# tools/package-repository.tcl builds SDL3's, Raven's and the event loop's
# native files and packs their releases. An author's environment, never a
# consumer's: installing a package runs nothing of it.
#
#   tools/package-build/author.sh image
#
# Every input is fixed by its content, not by a mutable name:
#
#   * the base image by its digest (ubuntu:24.04 as Docker Hub served it);
#   * every Ubuntu package from Ubuntu's snapshot service at one instant
#     (SNAPSHOT): the archive as it was then, so apt resolves the same
#     versions on every machine and every day (the instant's package set,
#     not "the latest");
#   * Tcl 9.0.1 (no Ubuntu 24.04 package) as the three .deb files the
#     repository's CI installs, from the same snapshot, checked by SHA-256.
#
# What the image does not fix: the network sources a build fetches (the
# pinned Raven and SDL3 commits, Khronos's Vulkan headers, the arm64 libX11
# packages), which the recipes check by commit and SHA-256 themselves, and
# the build machine's CPU and kernel, which no output depends on unless a
# build reads them.
FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852
ARG SNAPSHOT=20261101T000000Z
ARG HTTPS_PROXY
# The snapshot service is HTTPS only, and the base image has no CA
# certificates: the build is given a CA bundle as a secret (build-ca: the
# building host's own, or its proxy's), used for the build and never left in
# the image. apt verifies peers with it, and every package by the archive's
# signed index, as always.
RUN --mount=type=secret,id=build-ca,required=true \
    set -eu; \
    sed -i "s|http://archive.ubuntu.com/ubuntu/|https://snapshot.ubuntu.com/ubuntu/$SNAPSHOT/|; s|http://security.ubuntu.com/ubuntu/|https://snapshot.ubuntu.com/ubuntu/$SNAPSHOT/|" /etc/apt/sources.list.d/ubuntu.sources; \
    install -m 0644 /run/secrets/build-ca /tmp/build-ca.crt; \
    echo 'Acquire::https::CaInfo "/tmp/build-ca.crt";' > /etc/apt/apt.conf.d/99build; \
    if [ -n "${HTTPS_PROXY:-}" ]; then \
      echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/99build; \
    fi; \
    apt-get -o Acquire::Check-Valid-Until=false update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl git cmake ninja-build gcc libc6-dev libx11-dev clang \
      gcc-aarch64-linux-gnu libc6-dev-arm64-cross binutils-aarch64-linux-gnu \
      dpkg-dev xz-utils tzdata zlib1g; \
    cd /tmp; \
    for deb in libt/libtommath/libtommath1_1.3.0-1_amd64.deb:c28db717fd1e7d3ab0a534c924839b360e58eae6be397dfabb403af12efdcd6d \
               t/tcl9.0/libtcl9.0_9.0.1+dfsg-1_amd64.deb:b694c292598bcb640050bc10cdbd9d970f215f0e24854d63d0fcc85a5c24efb4 \
               t/tcl9.0/tcl9.0_9.0.1+dfsg-1_amd64.deb:83cf61f5f2acf0353db448dd56d69f71bb5466c067b83ad8b5a0392c7ed1df31; do \
      path=${deb%%:*}; sha=${deb##*:}; \
      curl -fsSL --cacert /tmp/build-ca.crt --retry 3 -o "$(basename "$path")" "https://snapshot.ubuntu.com/ubuntu/$SNAPSHOT/pool/universe/$path"; \
      echo "$sha  $(basename "$path")" | sha256sum -c -; \
    done; \
    dpkg -i libtommath1_*.deb libtcl9.0_*.deb tcl9.0_*.deb; \
    rm -f /tmp/*.deb /etc/apt/apt.conf.d/99build /tmp/build-ca.crt; \
    rm -rf /var/lib/apt/lists/*; \
    dpkg-query -W -f '${Package} ${Version} ${Architecture}\n' | sort > /etc/botlish-author-packages; \
    echo "snapshot $SNAPSHOT" > /etc/botlish-author-environment
ENV LANG=C.utf8 LC_ALL=C.utf8 BOTLISH_CACHE_DIR=/cache
WORKDIR /src
