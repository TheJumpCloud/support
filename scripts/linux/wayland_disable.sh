#!/bin/bash
################################################################################
# This script will disable wayland windowing system
################################################################################

if [[ "${UID}" != 0 ]]; then
    (>&2 echo "Error:  $0 must be run as root")
    exit 1
fi

disable_wayland() {
    case ${linuxType} in
        ubuntu|\"rocky\"|\"centos\")
            `sed -i 's/^#.*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/custom.conf`
            ;;
        debian)
            `sed -i 's/^#.*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/daemon.conf`
            ;;
    esac
}

# Get the current windowing system
windowingSystem=$(echo $XDG_SESSION_TYPE)
if [ "$windowingSystem" == "" ]; then
    windowingSystem=`loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}'`
fi

windowingSystem="wayland"

# Get the linux type
linuxType=`awk -F= '$1=="ID" { print $2 ;}' /etc/os-release`
linuxType="$(echo -e "${linuxType}" | sed -e 's/^[[:space:]]*//')"

if [[ "$linuxType" == "linuxmint" ]]; then
    echo "Linuxmint does not support wayland. Nothing to be done for linuxmint."
    exit 0
fi

if [[ "$windowingSystem" == "wayland" ]]; then
    disable_wayland "$linuxType"
elif [[ "$windowingSystem" == "x11" ]]; then
    echo "Windowing System is already set to x11"
    exit 1
fi

echo "Now 'restart' the machine or run 'sudo systemctl restart gdm'."

exit 0
