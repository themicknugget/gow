#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

# If the host is using the proprietary Nvidia driver, make sure the
# corresponding xorg driver is installed
if [ -f /proc/driver/nvidia/version ]; then
    gow_log "Detected Nvidia drivers, installing them..."
    /opt/gow/ensure-nvidia-xorg-driver.sh
fi

# Cleaning up /tmp/ otherwise Xorg will error out if you stop and restart the container
DISPLAY_NUMBER=${DISPLAY:1}
DISPLAY_FILE=/tmp/.X11-unix/X${DISPLAY_NUMBER}
if [ -S "${DISPLAY_FILE}" ]; then
  gow_log "Removing ${DISPLAY_FILE} before starting"
  rm -f "/tmp/.X${DISPLAY_NUMBER}-lock"
  rm "${DISPLAY_FILE}"
fi

_kill_procs() {
  kill -TERM "$xorg"
  wait "$xorg"
  kill -TERM "$jwm"
  wait "$jwm"
}

# Setup a trap to catch SIGTERM and relay it to child processes
trap _kill_procs SIGTERM

# Start Xorg
echo "Starting Xorg (${DISPLAY}, log level ${XORG_VERBOSE})"
Xorg -logverbose "${XORG_VERBOSE}" -ac -noreset +extension GLX +extension RANDR +extension RENDER vt1 "${DISPLAY}" &
xorg=$!

jwm &
jwm=$!

# Setting up resolution
RESOLUTION=${RESOLUTION:-1920x1080}
REFRESH_RATE=${REFRESH_RATE:-60}

# wait for the X server to finish starting
for i in {0..120}; do
    if  xdpyinfo >/dev/null 2>&1; then
        break
    fi

    sleep 1s
done

output_log=$'Detected outputs:\n'
for out in $(xrandr --current | awk '/ (dis)?connected/ { print $1 }'); do
    output_log+="    - $out"
    output_log+=$'\n'
done
echo "$output_log"

CURRENT_OUTPUT=${CURRENT_OUTPUT:-$(xrandr --current | awk '/ connected/ { print $1; }')}
echo "Setting ${CURRENT_OUTPUT} output to: ${RESOLUTION}@${REFRESH_RATE}"

# First try to use an already set resolution, if available
if ! xrandr --output "${CURRENT_OUTPUT}" --mode "${RESOLUTION}" --rate "${REFRESH_RATE}"; then
  FORCE_RESOLUTION=${FORCE_RESOLUTION:-false}
  echo "${RESOLUTION} is not detected, FORCE_RESOLUTION=${FORCE_RESOLUTION}"

  # this line disables the check for the whole if block
  # shellcheck disable=SC2086
  if $FORCE_RESOLUTION; then
    WIDTH_HEIGHT=("${RESOLUTION//x/ }")
    MODELINE=$(cvt ${WIDTH_HEIGHT[0]} ${WIDTH_HEIGHT[1]} ${REFRESH_RATE} | awk 'FNR==2{print substr($0, index($0,$3))}')
    xrandr --newmode "${RESOLUTION}_${REFRESH_RATE}.00" ${MODELINE}
    xrandr --addmode ${CURRENT_OUTPUT} "${RESOLUTION}_${REFRESH_RATE}.00"
    xrandr --output ${CURRENT_OUTPUT} --mode "${RESOLUTION}_${REFRESH_RATE}.00" --rate ${REFRESH_RATE} --primary
  fi
fi

DISABLE_OUTPUTS=${DISABLE_OUTPUTS:-}
for i in ${DISABLE_OUTPUTS//,/ }; do
    xrandr --output "$i" --off
done

wait $xorg
wait $jwm
