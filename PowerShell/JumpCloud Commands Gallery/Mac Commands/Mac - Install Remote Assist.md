#### Name

Mac - Install Remote Assist | v1.0 JCCG

#### commandType

mac

#### Command

```
set -eu
set -o pipefail

REMOTE_DMG_URL="https://cdn.awsstg.jumpcloud.com/TheJumpCloud/jumpcloud-remote-assist-agent/latest/jumpcloud-assist-app.dmg"
APP_NAME="Jumpcloud Assist App.app"
LOCAL_DMG_PATH="/tmp/jumpcloud-assist-app.dmg"

for SIGNAL in TERM KILL; do
    PID=
    for _ in $(seq 5); do
        PID=$(ps -ef | grep -iE "Jumpcloud Assist App$" | awk '{print $2}')
        if [[ "$SIGNAL" == TERM ]]; then
            break
        elif [[ -n "$PID" ]]; then
            sleep 1
        fi
    done

    if [[ -n "$PID" ]]; then
        kill -s "$SIGNAL" "$PID"
    else
        break
    fi
done

echo "Downloading JumpCloud Remote Assist installer"
curl --silent --output "$LOCAL_DMG_PATH" "$REMOTE_DMG_URL" >/dev/null
echo "Download complete"
( # Run in a subshell to ensure cleanup
VOLUME=$(hdiutil attach "$LOCAL_DMG_PATH" | grep -Eo '(\/Volumes\/.*)')

echo "Verifying installer signature"
CODESIGN_OUT=$(codesign -dv --verbose=4 "$VOLUME/$APP_NAME" 2>&1)

if [[ $? != 0 ]] ; then
    echo "Installer lacks a valid signature, aborting installation"
    exit 1
fi

if ! echo "$CODESIGN_OUT" | grep "Authority=Developer ID Application: JUMPCLOUD INC. (N985MXSH85)" &> /dev/null; then
    echo "Installer lacks a valid signature, aborting installation"
    exit 1
fi

echo "Installing JumpCloud Remote Assist"
rm -rf "/Applications/$APP_NAME"
cp -a "$VOLUME/$APP_NAME" /Applications
echo "Installation complete"
)
set +e # Keep trying to clean up
hdiutil detach "$VOLUME" &> /dev/null
rm "$LOCAL_DMG_PATH"
```

#### Description

Downloads and installs the JumpCloud Remote Assist app on a Mac system.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20Remote%20Assist.md'
```
