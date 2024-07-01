#!/bin/bash -e

source /opt/gow/bash-lib/utils.sh

# Run additional startup scripts
for file in /opt/gow/startup.d/* ; do
    if [ -f "$file" ] ; then
        gow_log "[start] Sourcing $file"
        source $file
    fi
done

gow_log "[start] Starting Plasma Desktop"

source /opt/gow/launch-comp.sh
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_ID="${DISPLAY#*:}"

/usr/bin/startplasma-x11 
# launcher "/usr/bin/startplasma-x11" "${LUTRIS_ARGS[@]}"
