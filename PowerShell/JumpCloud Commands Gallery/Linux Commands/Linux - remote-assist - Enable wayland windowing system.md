#### Name

Linux - remote-assist - Enable wayland windowing system | v2.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash
################################################################################
# This script will enable wayland windowing system
################################################################################

if [[ "${UID}" != 0 ]]; then
    (>&2 echo "Error:  $0 must be run as root")
    exit 1
fi

enable_wayland() {
    case ${linuxType} in
        ubuntu|\"rocky\"|\"centos\")
            `sed -i 's/WaylandEnable=.*/#WaylandEnable=false/' /etc/gdm3/custom.conf`
            ;;
        debian)
            `sed -i 's/WaylandEnable=.*/#WaylandEnable=false/' /etc/gdm3/daemon.conf`
            ;;
    esac
}

# Get the current windowing system
windowingSystem=$(echo $XDG_SESSION_TYPE)
if [[ "$windowingSystem" == "" ]]; then
    windowingSystem=`loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}'`
fi

# Get the linux type
linuxType=`awk -F= '$1=="ID" { print $2 ;}' /etc/os-release`
linuxType="$(echo -e "${linuxType}" | sed -e 's/^[[:space:]]*//')"

if [[ "$linuxType" == "linuxmint" ]]; then
    echo "Linuxmint does not support wayland. Nothing to be done for linuxmint."
    exit 0
fi

if [[ "$windowingSystem" == "wayland" ]]; then
    echo "Windowing System is already set to wayland"
    exit 1
elif [[ "$windowingSystem" == "x11" ]]; then
    enable_wayland "$linuxType"
fi

echo "Next step is to either 'reboot' the machine or run 'sudo systemctl restart gdm'."

exit 0
```

#### Description

This script enables the Wayland windowing system on the Linux machine.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Rename%20System%20HostName%20from%20JumpCloud.md"
```
