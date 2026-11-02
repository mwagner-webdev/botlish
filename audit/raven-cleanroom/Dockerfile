# The clean room of RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md: a stock Ubuntu
# 24.04 with operating-system facilities only -- no Botlish, no Raven, no
# Tcl, Rust, CMake or Ninja, no Botlish or Raven source. The single-file
# compiler and the raven .botpkg are copied in when a container runs
# (tools/cleanroom.sh), never built into the image.
#
#   docker build --network host -t botlish-raven-cleanroom audit/raven-cleanroom
#
# (tools/cleanroom.sh image passes a proxy and its CA when HTTPS_PROXY is
# set.) What is installed, and why:
#
#   gcc, libc6-dev       a C compiler driver and the C library's link files:
#                        the native backend links a program that calls C
#                        with the system's linker (SINGLE-EXECUTABLE-FFI-
#                        MILESTONE-1.md) -- a host facility the developer
#                        needs, not a Botlish or Raven build dependency
#   libx11-6             libX11.so.6, which libraven loads
#   libvulkan1           the Vulkan loader, libvulkan.so.1 (Raven opens it
#                        when it starts its renderer)
#   mesa-vulkan-drivers  a Vulkan implementation: Mesa's software rasterizer
#                        (lavapipe), since the container has no GPU
#   xvfb                 an X11 display without a monitor
#   python3, libxtst6    the test harness only (tools/xsession.py: finds the
#                        window, clicks through XTest, reads pixels, asks the
#                        window to close): never needed to develop or run a
#                        Raven program
#
# A user `dev` owns /home/dev, where everything happens.
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
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gcc libc6-dev libx11-6 libvulkan1 mesa-vulkan-drivers xvfb python3 libxtst6; \
    rm -rf /var/lib/apt/lists/* /etc/apt/apt.conf.d/99build-proxy /tmp/build-proxy-ca.crt; \
    if [ -n "${HTTPS_PROXY:-}" ]; then sed -i 's|https://|http://|g' /etc/apt/sources.list.d/ubuntu.sources; fi; \
    useradd -m -s /bin/bash dev
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
USER dev
WORKDIR /home/dev
