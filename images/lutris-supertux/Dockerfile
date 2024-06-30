ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

COPY --chmod=777 scripts/startup-20-launch-supertux.sh /opt/gow/startup.d/20-launch-supertux.sh
COPY scripts/supertux-appimage.yaml /opt/gow/supertux-appimage.yaml

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
