#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

gow_log "Starting dolphin-emu with DISPLAY=${DISPLAY}"
cd /Applications
./dolphin-emu.AppImage --appimage-extract-and-run
