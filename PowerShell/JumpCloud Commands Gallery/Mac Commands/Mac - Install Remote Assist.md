#### Name

Mac - Install Remote Assist | v1.0 JCCG

#### commandType

mac

#### Command

```
set -euo pipefail

declare -r REMOTE_DMG_URL="https://cdn.jumpcloud.com/TheJumpCloud/jumpcloud-remote-assist-agent/latest/jumpcloud-assist-app.dmg"
declare -r LOCAL_DMG_TMP_PATH="/tmp/jumpcloud-assist-app.dmg"
declare -r APP_NAME="Jumpcloud Assist App"
declare -r APP_FILENAME="$APP_NAME.app"

function get_app_pid() {
    ps -ef | awk "/$APP_NAME$/ {print \$2}"
}

if PID=$(get_app_pid) && [[ -n "$PID" ]]; then
    kill -s TERM "$PID"
    sleep 1
fi

if PID=$(get_app_pid) && [[ -n "$PID" ]]; then
    kill -s KILL "$PID"
fi

echo "Downloading JumpCloud Remote Assist installer"
curl --silent --output "$LOCAL_DMG_TMP_PATH" "$REMOTE_DMG_URL" >/dev/null
echo "Download complete"
VOLUME=$(hdiutil attach "$LOCAL_DMG_TMP_PATH" | grep -Eo '(\/Volumes\/.*)')

( # Run in a subshell to ensure cleanup

echo "Verifying installer signature"
CODESIGN_OUT=$(codesign -dv --verbose=4 "$VOLUME/$APP_FILENAME" 2>&1)

if [[ $? != 0 ]] ; then
    echo "Installer lacks a valid signature, aborting installation"
    exit 1
fi

if ! echo "$CODESIGN_OUT" | grep "Authority=Developer ID Application: JUMPCLOUD INC. (N985MXSH85)" &> /dev/null; then
    echo "Installer lacks a valid signature, aborting installation"
    exit 1
fi

echo "Installing JumpCloud Remote Assist"
rm -rf "/Applications/$APP_FILENAME"
cp -a "$VOLUME/$APP_FILENAME" /Applications
echo "Installation complete"
)
set +e # Keep trying to clean up
hdiutil detach "$VOLUME" &> /dev/null
rm "$LOCAL_DMG_TMP_PATH"
```

#### Description

Downloads and installs the JumpCloud Remote Assist app on a Mac system.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20Remote%20Assist.md"
```
