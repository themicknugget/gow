#!/bin/bash -e

gow_log "[start-launch-supertux] Begin"

if $LUTRIS -lo 2>/dev/null | grep "supertux"
then
    gow_log "[start-launch-supertux] Super Tux is already installed! Launching."
    LUTRIS_ARGS=("lutris:rungame/supertux")
else
    gow_log "[start-launch-supertux] Super Tux is not installed! Installing."
    LUTRIS_ARGS=("-i" "/opt/gow/supertux-appimage.yaml")
fi

gow_log "[start-launch-supertux] End"
