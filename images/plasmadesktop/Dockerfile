ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ENV RUN_SWAY=0

ARG REQUIRED_PACKAGES=" \
    kwin-x11 \
    libasound2-plugins:i386 \
    libsdl2-2.0-0:i386 \
    libdbus-1-3:i386 \
    libsqlite3-0:i386 \
    "

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends $REQUIRED_PACKAGES && \
    # Cleanup \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/gow/startup.d/
COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
