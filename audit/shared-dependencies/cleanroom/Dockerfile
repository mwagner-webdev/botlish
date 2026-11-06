# The clean room of SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md: Ubuntu 24.04
# and operating-system facilities only -- a C compiler driver and the C
# library's development files, which the single-file compiler's system
# linker uses to link a program that calls C. No Tcl, no Rust, no Botlish,
# no checkout: the consumer gets the single-file compiler, the published
# .botpkg artifacts and its own source, copied in (cleanroom.sh).
FROM ubuntu:24.04
ARG HTTPS_PROXY
RUN --mount=type=secret,id=proxy-ca,required=false \
    set -eu; \
    if [ -n "${HTTPS_PROXY:-}" ]; then \
      sed -i 's|http://|https://|g' /etc/apt/sources.list.d/ubuntu.sources; \
      echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" > /etc/apt/apt.conf.d/99build-proxy; \
      if [ -s /run/secrets/proxy-ca ]; then \
        install -m 0644 /run/secrets/proxy-ca /tmp/build-proxy-ca.crt; \
        echo 'Acquire::https::CaInfo "/tmp/build-proxy-ca.crt";' >> /etc/apt/apt.conf.d/99build-proxy; \
      fi; \
    fi; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gcc libc6-dev; \
    rm -rf /var/lib/apt/lists/* /etc/apt/apt.conf.d/99build-proxy /tmp/build-proxy-ca.crt; \
    if [ -n "${HTTPS_PROXY:-}" ]; then sed -i 's|https://|http://|g' /etc/apt/sources.list.d/ubuntu.sources; fi; \
    useradd -m -s /bin/bash dev
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
USER dev
WORKDIR /home/dev
