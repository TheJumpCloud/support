#### Name

Mac - Install Remote Assist | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/usr/bin/env bash
set -euo pipefail

declare -r REMOTE_PKG_URL="https://jumpcloud-windows-agent.s3.amazonaws.com/production/jumpcloud-remote-assist-agent.pkg"
declare -r LOCAL_PKG_TMP_PATH="$(mktemp -d)/jumpcloud-remote-assist.pkg"

function get_app_pid() {
    local -r APP_NAME=$1
    ps -eo pid,comm | awk "/${APP_NAME}$/ {print \$1}"
}

function kill_app_by_name() {
    local -r APP_NAME=$1
    if PID=$(get_app_pid "${APP_NAME}") && [[ -n "${PID}" ]]; then
        kill -s TERM "${PID}"
        sleep 1
    fi

    if PID=$(get_app_pid "${APP_NAME}") && [[ -n "${PID}" ]]; then
        kill -s KILL "${PID}"
    fi
}

# Clean up installs having legacy names
kill_app_by_name "Jumpcloud Assist App"

echo "Downloading JumpCloud Remote Assist installer"
curl --silent --output "${LOCAL_PKG_TMP_PATH}" "${REMOTE_PKG_URL}" >/dev/null
echo "Download complete"

( # Run in a subshell to ensure cleanup
set +e
SIGNATURE_OUT=$(pkgutil --check-signature "${LOCAL_PKG_TMP_PATH}")

if [[ $? != 0 ]] ; then
    echo "Installer lacks a valid signature, aborting installation"
    exit 1
fi

if ! echo "${SIGNATURE_OUT}" | grep "1. Developer ID Installer: JUMPCLOUD INC. (N985MXSH85)" &> /dev/null; then
    echo "Installer lacks a valid signature, aborting installation"
    exit 1
fi

echo "Installing JumpCloud Remote Assist"
installer -pkg "${LOCAL_PKG_TMP_PATH}" -target /
echo "Installation finished with exit code $?"
)
rm -f "${LOCAL_PKG_TMP_PATH}"
rmdir "$(dirname "${LOCAL_PKG_TMP_PATH}")"
```

#### Description

Downloads and installs the JumpCloud Remote Assist app on a Mac system.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20Remote%20Assist.md"
```
