#!/bin/bash

windowingSystem=$(echo $XDG_SESSION_TYPE)

if [ "$windowingSystem" == "" ]; then
  windowingSystem=`loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}'`
fi

if [ "$windowingSystem" == "x11" ];
then
    echo "Windowing System is already set to x11"
    exit 1
fi

linuxType=`awk -F= '$1=="ID" { print $2 ;}' /etc/os-release`
linuxType="$(echo -e "${linuxType}" | sed -e 's/^[[:space:]]*//')"

if [[ "${UID}" != 0 ]]; then
  (>&2 echo "Error:  $0 must be run as root")
  exit 1
fi

case ${linuxType} in  
    ubuntu)
        `sudo sed -i 's/^#.*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/custom.conf`
        echo
        ;;
    debian)
        `sudo sed -i 's/^#.*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/daemon.conf`
        ;;
    rocky)
        `sudo sed -i 's/^#.*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm/custom.conf`
        echo
        ;;
    linuxmint)
        echo "Linuxmint does not support wayland. So nothing to be done for linuxmint"
        echo
        ;;
    \"centos\")
        `sudo sed -i 's/^#.*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm/custom.conf`
        echo
        ;;
esac
